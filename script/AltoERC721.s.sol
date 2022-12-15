// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "src/AltoERC721.sol";
import "src/AltoERC721Individual.sol";

contract AltoERC721Script is Script {

    AltoERC721Factory factory;
    AltoERC721CommonFactory commonFactory;
    uint256 deployerPK = vm.envUint("PRIVATE_KEY");

    function setUp() public {}

    function run() public {
        vm.startBroadcast(deployerPK);

            factory = new AltoERC721Factory(250 ether, 50 ether);
            commonFactory = new AltoERC721CommonFactory(1 ether);

        vm.stopBroadcast();
    }
}

//0xc5BFd7D6628b9017500700A1346467aC7BACdAAa

contract AltoERC721InitializeScript is Script {

    AltoERC721CommonFactory commonFactory;
    uint256 deployerPK = vm.envUint("PRIVATE_KEY");

    function setUp() public {}

    function run() public {
        vm.startBroadcast(deployerPK);

            commonFactory = AltoERC721CommonFactory(0xc5BFd7D6628b9017500700A1346467aC7BACdAAa);
            address collection = commonFactory.createCommonCollection();

        vm.stopBroadcast();
    }
}

//forge script script/AltoERC721.s.sol:AltoERC721InitializeScript --rpc-url $RPC_URL --broadcast --verify --verifier-url https://evm.explorer.canto.io/api --verifier blockscout --watch -vvvv

//0xDE6314A3BaA34319f05eFd2B24b12fef77C42fD9
//forge verify-contract 0xDE6314A3BaA34319f05eFd2B24b12fef77C42fD9 src/AltoERC721Individual.sol:AltoERC721Individual --chain-id 7700 --verifier-url https://evm.explorer.canto.io/api --verifier blockscout --watch