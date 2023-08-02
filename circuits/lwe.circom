pragma circom 2.1.0;

include "add.circom";
include "fast_compconstant.circom";
include "util.circom";
include "array_access.circom";
include "circomlib/circuits/bitify.circom";
include "circomlib/circuits/comparators.circom";

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

    num === den * quot + rem; // correct division
    signal less <== LessThan(252)([rem, den]);
    less === 1; // rem < den

    signal bit_add <== GreaterEqThan(252)([2*rem, den]);

    // out <== quot + (2*rem < den) ? 0 : 1
    out <== quot + bit_add;
}

// computes round(num/Q)
template RoundDivQ(Q) {
    assert(Q > 0);
    assert(Q < (1<<252));

    signal input num;
    signal output out;

    signal quot <-- num \ Q;
    signal rem <-- num % Q;

    num === Q * quot + rem; // correct division
    
    LtConstant(Q)(rem); // rem < Q

    var nbits = log2(Q)+1;
    var rem2_bits[nbits] = Num2Bits(nbits)(2*rem);

    signal bit_add <== IsGeqtConstant(Q, nbits)(rem2_bits);

    // out <== quot + (2*rem < Q) ? 0 : 1
    out <== quot + bit_add;
}

// switches from modulus Q to modulus q
template ModSwitch(n, q, Q) {
    assert(log2(q)+log2(Q) < 252);

    signal input a_in[n], b_in;
    signal output a_out[n], b_out;
    component modq[n+1];

    for (var i = 0; i < n; i++) {
        modq[i] = Mod(q);
        modq[i].in <== RoundDivQ(Q)(q*a_in[i]);
        a_out[i] <== modq[i].out;
    }

    modq[n] = Mod(q);
    modq[n].in <== RoundDivQ(Q)(q*b_in);
    b_out <== modq[n].out;
}

// switches from key with dimension N to key with dimension n
// the base Bks is assumed to be a power of 2
// ksk has dimension N x logb(Qks,Bks) x Bks x (n+1)
template KeySwitch(n, N, Qks, Bks, ksk) {
    signal input a_in[N], b_in;
    signal output a_out[n], b_out;

    var a[n], b;
    
    var nbitsB = log2(Bks);
    var dks = logb(Qks, Bks);
    var nbits = nbitsB * dks;
    
    for (var i=0; i<n; i++) {
        a[i] = 0;
    }
    b = b_in;

    for (var i=0; i<N; i++) {

        var a_bin[nbits] = Num2Bits(nbits)(a_in[i]);

        for (var j=0; j<dks; j++) {

            var a0_bin[nbitsB];
            
            for (var l=0; l<nbitsB; l++) {
                a0_bin[l] = a_bin[l + j*nbitsB];
            }

            var key[n+1] = ArrayAccessBin(nbitsB, n+1)(ksk[i][j], a0_bin);
            // key = [a_1,..., a_n, b]

            var key_a[n];
            for (var h=0; h<n; h++) {
                key_a[h] = key[h];
            }
            var key_b = key[n];

            (a, b) = SubLWE(n, Qks)(a, b, key_a, key_b);
        }
    }

    a_out <== a;
    b_out <== b;
}
