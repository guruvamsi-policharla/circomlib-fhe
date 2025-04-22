#!/bin/bash

mkdir -p out

circom main_kyber.circom -l .. --r1cs --c -o out

cd out/main_kyber_cpp
 
make
 
echo "{\"h\": "9899303090184228545410536567201573092531122091338580681806905875454854859032"}" > input.json

./main_kyber input.json witness.wtns

cd ../..

rm -rf out/main_kyber_cpp