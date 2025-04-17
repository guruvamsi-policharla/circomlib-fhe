pragma circom 2.1.0;

include "../circuits/add.circom";
include "../circuits/mul.circom";

template TestAdd() {
    log("\n********** TEST Add **********\n");

    var n = 1;
    var q = 3329;

    var in[2] = [3328,1];
    var should_be_out = 0;
    
    var out = FastAddMod(q)(in);

    var RESULT = (out == should_be_out);

    log("RESULT: ", RESULT);
    signal output result <-- RESULT;
}

template TestSub() {
    log("\n********** TEST Sub **********\n");

    var n = 1;
    var q = 3329;

    var in[2] = [1,2];
    var should_be_out = 3328;
    
    var out = FastSubMod(q)(in);

    var RESULT = (out == should_be_out);

    log("RESULT: ", RESULT);
    signal output result <-- RESULT;
}

template TestMul() {
    log("\n********** TEST Mul **********\n");

    var n = 1;
    var q = 3329;

    var in1[1] = [3328];
    var in2[1] = [3328];
    var should_be_out[1] = [1];

    var out[1] = MulPointwise(1, q)(in1, in2);

    var RESULT = 1;
    for (var i=0; i<n; i++) {
        RESULT = RESULT && (out[i] == should_be_out[i]);
    }
    
    log("RESULT: ", RESULT);
    signal output result <-- RESULT;
}

template TestAll() {
    log("\n******************** TESTING f3329.circom ********************\n\n");

    var total = 1;
    var res;

    res = TestAdd()();
    total = total && res;  

    res = TestSub()();
    total = total && res; 

    res = TestMul()();
    total = total && res; 

    log("********************\n", "TOTAL RESULT: ", total, "\n********************\n");
}

component main = TestAll();

