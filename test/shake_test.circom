pragma circom 2.1.0;

include "../circuits/sha3/sha3_bytes.circom";

template Test32Zeros() {
    log("\n******************** TESTING shake256 input 32 zeros ********************\n\n");

    var should_be_out[32]; 
    should_be_out[0] = 0xf5; 
    should_be_out[1] = 0x97; 
    should_be_out[2] = 0x7c;
    should_be_out[3] = 0x82;
    should_be_out[4] = 0x83;
    should_be_out[5] = 0x54;
    should_be_out[6] = 0x6a;
    should_be_out[7] = 0x63;
    should_be_out[8] = 0x72;
    should_be_out[9] = 0x3b;
    should_be_out[10] = 0xc3;
    should_be_out[11] = 0x1d;
    should_be_out[12] = 0x26;
    should_be_out[13] = 0x19;
    should_be_out[14] = 0x12;
    should_be_out[15] = 0x4f;
    should_be_out[16] = 0x11;
    should_be_out[17] = 0xdb;
    should_be_out[18] = 0x46;
    should_be_out[19] = 0x58;
    should_be_out[20] = 0x64;
    should_be_out[21] = 0x33;
    should_be_out[22] = 0x36;
    should_be_out[23] = 0x74;
    should_be_out[24] = 0x1d;
    should_be_out[25] = 0xf8;
    should_be_out[26] = 0x17;
    should_be_out[27] = 0x57;
    should_be_out[28] = 0xd5;
    should_be_out[29] = 0xad;
    should_be_out[30] = 0x30;
    should_be_out[31] = 0x62;
    component shake = SHAKE256_bytes(32, 32);
    for (var i = 0; i < 32; i++) {
        shake.inp_bytes[i] <== 0;
    }

    var RESULT = 1;
    for (var i=0; i<32; i++) {
        RESULT = RESULT && (shake.out_bytes[i] == should_be_out[i]);
    }

    signal output res <-- RESULT;
}

template TestAll() {
    var total = 1;
    var res;

    res = Test32Zeros()();

    log("********************\n", "TOTAL RESULT: ", total, "\n********************\n");
}

component main = TestAll();