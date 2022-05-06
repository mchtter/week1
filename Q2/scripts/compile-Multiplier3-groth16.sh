#!/bin/bash

cd contracts/circuits
mkdir -p build

if [ -f ./powersOfTau28_hez_final_16.ptau ]; then
    echo "powersOfTau28_hez_final_16.ptau already exists. Skipping."
else
    echo 'Downloading powersOfTau28_hez_final_16.ptau'
    wget https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_16.ptau
fi

echo "Compiling: Multiplier3..."

mkdir -p build/Multiplier3_groth16

# compile circuit

if [ -f ./build/Multiplier3.r1cs ]; then
    echo "Circuit already compiled. Skipping."
else
    circom Multiplier3.circom --r1cs --wasm --sym -o build
    snarkjs r1cs info build/Multiplier3.r1cs
fi

# Start a new zkey and make a contribution

if [ -f ./build/Multiplier3_groth16/verification_key.json ]; then
    echo "verification_key.json already exists. Skipping."
else
    snarkjs groth16 setup build/Multiplier3.r1cs powersOfTau28_hez_final_16.ptau build/Multiplier3_groth16/circuit_final.zkey #circuit_0000.zkey
    #snarkjs zkey contribute build/Multiplier3_groth16/circuit_0000.zkey build/Multiplier3_groth16/circuit_final.zkey --name="1st Contributor Name" -v -e="random text"
    snarkjs zkey export verificationkey build/Multiplier3_groth16/circuit_final.zkey build/Multiplier3_groth16/verification_key.json
fi

# generate solidity contract
snarkjs zkey export solidityverifier build/Multiplier3_groth16/circuit_final.zkey ../Multiplier3Verifier.sol