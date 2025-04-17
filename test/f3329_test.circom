pragma circom 2.1.0;

include "../circuits/add.circom";

template TestAdd() {
    log("\n********** TEST AddLWE **********\n");

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
    log("\n********** TEST SubLWE **********\n");

    var n = 1;
    var q = 3329;

    var in[2] = [1,2];
    var should_be_out = 3328;
    
    var out = FastSubMod(q)(in);

    var RESULT = (out == should_be_out);

    log("RESULT: ", RESULT);
    signal output result <-- RESULT;
}

template TestAll() {
    log("\n******************** TESTING lwe.circom ********************\n\n");

    var total = 1;
    var res;

    res = TestAdd()();
    total = total && res;  

    res = TestSub()();
    total = total && res;  

    log("********************\n", "TOTAL RESULT: ", total, "\n********************\n");
}

component main = TestAll();

