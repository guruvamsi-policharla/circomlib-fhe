pragma circom 2.1.0;

include "add.circom";
include "mod.circom";
include "util.circom";
include "circomlib/circuits/bitify.circom";
include "circomlib/circuits/comparators.circom";
include "circomlib/circuits/compconstant.circom";

// addition of LWE ciphertexts: (a1, b1) + (a2, b2)
template AddLWE(n, q) {
    signal input a1[n], b1;
    signal input a2[n], b2;
    signal output a_out[n], b_out;

    for (var i=0; i<n; i++) {
        a_out[i] <== FastAddMod(q)([a1[i], a2[i]]);
    }
    b_out <== FastAddMod(q)([b1, b2]);
}

// subtraction of LWE ciphertexts: (a1, b1) - (a2, b2)
template SubLWE(n, q) {
    signal input a1[n], b1;
    signal input a2[n], b2;
    signal output a_out[n], b_out;

    for (var i=0; i<n; i++) {
        a_out[i] <== FastSubMod(q)([a1[i], a2[i]]);
    }
    b_out <== FastSubMod(q)([b1, b2]);
}

// computes round(num/den)
template RoundDiv() {
    signal input num, den;
    signal output out;

    signal quot <-- num \ den;
    signal rem <-- num % den;
    signal rem_bits[254] <== Num2Bits(254)(rem);

    num === den * quot + rem; // correct division
    rem_bits[253] === 0; // rem < 2^253
    rem_bits[252] === 0; // rem < 2^252
    _ <== LessThan(252)([rem, den]); // rem < den

    signal bit_add <== GreaterEqThan(252)([2*rem, den]);

    // out <== quot + (2*rem < den) ? 0 : 1
    out <== quot + bit_add;
}

// computes round(num/Q)
template RoundDivQ(Q) {
    assert(Q > 0);

    signal input num;
    signal output out;

    signal quot <-- num \ Q;
    signal rem <-- num % Q;
    signal rem_bits[254] <== Num2Bits(254)(rem);

    num === Q * quot + rem; // correct division
    
    component c1 = CompConstant(Q-1);
    c1.in <== rem_bits;
    c1.out === 0; // rem < Q

    // possible optimization: leverage previous bit decomposition of rem
    signal rem2_bits[254] <== Num2Bits(254)(2*rem);

    signal bit_add <== CompConstant(Q-1)(rem2_bits);

    // out <== quot + (2*rem < Q) ? 0 : 1
    out <== quot + bit_add;
}

// switches from modulus Q to modulus q
template ModSwitch(n, q, Q) {
    signal input a_in[n], b_in;
    signal output a_out[n], b_out;
    component modq[n+1];

    for (var i = 0; i < n; i++) {
        modq[i] = Mod(q);
        // modq[i].in <== RoundDiv()(q*a_in[i], Q);
        modq[i].in <== RoundDivQ(Q)(q*a_in[i]);
        a_out[i] <== modq[i].out;
    }

    modq[n] = Mod(q);
    // modq[n].in <== RoundDiv()(q*b_in, Q);
    modq[n].in <== RoundDivQ(Q)(q*b_in);
    b_out <== modq[n].out;
}

// switches from key with dimension N to key with dimension n
// NOT WORKING YET
template KeySwitch(n, N, q, B, kska, kskb) {
    signal input a_in[N], b_in;
    signal output a_out[n], b_out;

    var a[n], b;
    var digits = logb(q, B);
    
    for (var i=0; i<n; i++) {
        a[i] = 0;
    }
    b = b_in;

    for (var i=0; i<N; i++) {
        var atmp = a_in[i];
        for (var j=0; j<digits; j++) {
            var a0 = (atmp % B);
            // invalid expression below -> unknown index a0
            (a, b) = SubLWE(n, q)(a, b, kska[i][j][a0], kskb[i][j][a0]);
            atmp \= B;
        }
    }

    a_out <== a;
    b_out <== b;
}

// Examples of instantiations to check compilation:

// component main = AddLWE(10, 17);
// component main = SubLWE(10, 17);
// component main = RoundDiv();
// component main = RoundDivQ(5);
// component main = ModSwitch(5, 2, 6);
// component main = KeySwitch(2, 3, 5, 2, 
//     [[[[2, 3], [4, 2]], [[0, 0], [1, 2]], [[4, 3], [2, 1]]], [[[2, 3], [4, 2]], [[0, 0], [1, 2]], [[4, 3], [2, 1]]], [[[2, 3], [4, 2]], [[0, 0], [1, 2]], [[4, 3], [2, 1]]]],
//     [[[1, 1], [2, 0], [3, 1]], [[1, 1], [2, 0], [3, 1]], [[1, 1], [2, 0], [3, 1]]]);
