// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {Raffle} from "../../src/Raffle.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {Test} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "../../test/mocks/LinkToken.sol";
import {CodeConstants} from "../../script/HelperConfig.s.sol";

contract RaffleTest is Test{

    Raffle public raffle;
    HelperConfig public helperConfig;

    uint256 entranceFee;
    uint256 interval;
    uint256 gasLane;
    uint64 subscriptionId;
    address vrfCoordinator;
    address link;
    uint32 callbackGasLimit;

    
    

    address public PLAYER = makeAddr("player");
    uint256 public constant STARTING_PLAYER_BALANCE = 10 ether;
    event RaffleEnter(address indexed player);
    event RequestedRaffleWinner(uint256 indexed requestId);
    event WinnerPicked(address indexed winner);

    function setUp() external {
        DeployRaffle deployer = new DeployRaffle();
        (raffle, helperConfig) = deployer.deployContract();
        HelperConfig.NetworkConfig memory networkConfig = helperConfig.getConfig();
        entranceFee = networkConfig.entranceFee;
        interval = networkConfig.interval;
        gasLane = networkConfig.gasLane;
        subscriptionId = networkConfig.subscriptionId;
        vrfCoordinator = networkConfig.vrfCoordinator;
        link = networkConfig.link;
        callbackGasLimit = networkConfig.callbackGasLimit;

        vm.deal(PLAYER, STARTING_PLAYER_BALANCE);
    }
    fucntion testRaffleInitializesInOpenState() public view {
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }

    function test_RaffleRevertsWhenYouDontPayEnough() public {
        // Arrange
        vm.prank(PLAYER);
        // Act // Assert
        vm.expectRevert(Raffle.Raffle__SendMoreToEnterRaffle.selector);
        raffle.enter()
        
       
    }
    
    function test_RaffleRecordsPlayerWhenTheyEnter() public {
        // Arrange
        vm.prank(PLAYER);
        // Act
        raffle.enterRaffle{value: entranceFee}();
        // Assert
        address playerRecord = raffle.getPlayer(0);
        assert(playerRecord == PLAYER);
    }

    function test_EnteringRaffleEmitsEvent() public {
        // Arrange
        vm.prank(PLAYER);
        // Act
        vm.expectEmit(true, false, false, false, address(raffle));
        emit RaffleEnter(PLAYER);
        // Assert
        raffle.enterRaffle{value: entranceFee}();
    }
}
