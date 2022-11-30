pragma circom 2.1.0;

include "circomlib/circuits/bitify.circom";
include "circomlib/circuits/compconstant.circom";
include "circomlib/circuits/binsum.circom";
include "util.circom";


template parallel LtConstant(ct) {
	signal input in;
	signal res;
	
	var n = log2(ct);

	component n2b = Num2Bits(n+1);
	n2b.in <== in+ (1<<n) - ct;
	1-n2b.out[n] === 1;	
/*
	// assert(ct >= 1);
	signal input in;
	signal bits[254];
	signal res;

	bits <== Num2Bits_strict()(in);
	res <== CompConstant(ct-1)(bits);
	res === 0;
*/
}

template parallel LtConstantN(ct, N) {
	signal input in[N];
	
	for (var i = 0; i < N; i++) {
		parallel LtConstant(ct)(in[i]);
	}
}


template parallel Mod(q) {
	signal input in;
	signal quotient;
	signal output out;

	var p = 21888242871839275222246405745257275088548364400416034343698204186575808495617; // TODO: define modularly
	var delta = p \ q; // TODO: ceil? round?

	quotient <-- in \ q;
	out <-- in % q;
   
	parallel LtConstant(q-1)(out);
	parallel LtConstant(delta-1)(quotient); // TODO: or delta?

	in === quotient * q + out;
} 
