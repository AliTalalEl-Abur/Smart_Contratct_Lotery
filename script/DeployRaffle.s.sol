// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";
import {Raffle} from "../src/Raffle.sol";
import {AddConsumer, CreateSubscription, FundSubscription} from "./Interactions.s.sol";

contract DeployRaffle is Script {
    function run() public {}

    function deployContract() public returns (Raffle, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        //deploy -> deploy mocks, get local config
        // sepolia get sepolia config
        HelperConfig.NetworkConfig memory networkConfig = helperConfig.getConfig();

        vm.startBroadcast();
        Raffle raffle = new Raffle(
            networkConfig.subscriptionId,
            networkConfig.gasLane,
            networkConfig.interval,
            networkConfig.entranceFee,
            networkConfig.callbackGasLimit,
            networkConfig.vrfCoordinator
        );
        vm.stopBroadcast();
        return (raffle, helperConfig);
    }



    }
