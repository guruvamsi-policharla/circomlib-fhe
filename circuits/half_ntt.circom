pragma circom 2.1.0;

include "util.circom";
include "mod.circom";

// half NTT from Kyber spec. We store intermediate values at each layer and place constraints between consecutive layers.
// If we ensure the inputs come from the correct field, then we can delay the modular reduction until the end.
// This is because we start with 12 bit valyes and at each layer they only grow by at most 12 bits -- and there are 7 layers
// The proof systems field size is ~256 bits
template parallel halfNTT(n) {
    signal input p[n]; //the polynomial to be NTT-ed
    signal output out[n];

    var q = 3329;
    var roots[128] = [ 1, 1729, 2580, 3289, 2642, 630, 1897, 848,
        1062, 1919, 193, 797, 2786, 3260, 569, 1746,
        296, 2447, 1339, 1476, 3046, 56, 2240, 1333,
        1426, 2094, 535, 2882, 2393, 2879, 1974, 821,
        289, 331, 3253, 1756, 1197, 2304, 2277, 2055,
        650, 1977, 2513, 632, 2865, 33, 1320, 1915,
        2319, 1435, 807, 452, 1438, 2868, 1534, 2402,
        2647, 2617, 1481, 648, 2474, 3110, 1227, 910,
        17, 2761, 583, 2649, 1637, 723, 2288, 1100,
        1409, 2662, 3281, 233, 756, 2156, 3015, 3050,
        1703, 1651, 2789, 1789, 1847, 952, 1461, 2687,
        939, 2308, 2437, 2388, 733, 2337, 268, 641,
        1584, 2298, 2037, 3220, 375, 2549, 2090, 1645,
        1063, 319, 2773, 757, 2099, 561, 2466, 2594,
        2804, 1092, 403, 1026, 1143, 2150, 2775, 886,
        1722, 1212, 1874, 1029, 2110, 2935, 885, 2154 
    ];

    var neg_roots[128];
    for (var i = 0; i < 128; i++) {
        neg_roots[i] = q - roots[i];
    }

    // intermediate values at each layer of the FFT
    // (input) f[0] -> f[1] -> f[2] -> f[3] -> f[4] -> f[5] -> f[6] -> f[7] (out)
    signal f[8][n];
    for (var i = 0; i < n; i++) {
        f[7][i] <== p[i];
    }

    var i = 0;
    for (var l = 7; l >= 1; l--) {
        var len = 1 << l;
        for (var start = 0; start < 256; start += 2*len) {
            i++;
            for (var j = start; j < start + len; j++) {
                f[l-1][j + len] <== f[l][j] + neg_roots[i] * f[l][j + len];
                f[l-1][j] <== f[l][j] + roots[i] * f[l][j + len];
            }            
        }
    }

    // Final reduction mod q
    for (var i = 0; i < n; i++) {
        out[i] <== ModBound(q, (1 << 92))(f[0][i]);
    }
}