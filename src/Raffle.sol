//layout of contract:
//version
//imports
//errors
//interfaces, libraries, contracts
//type declarations
//state variables
//events
//modifiers
//functions

//layout of functions:

//constructor
//receive function (if exists)
//fallback function (if exists)
//external
//public
//internal
//private
//view / pure functions

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts@1.1.1/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts@1.1.1/src/v0.8/vrf/dev/VRFV2PlusClient.sol";

/**
 * @title A sample Raffle contract
 * @author Ali Talal
 * @notice This contract is a sample Raffle contract
 * @dev Implements Chainlink VRF v2.5
 */

contract Raffle is VRFConsumerBaseV2Plus {

    /** Errors */
    error Raffle__SendMoreToEnterRaffle();
    error Raffle__TransferFailed();
    error Raffle__RaffleNotOpen();

    /** Type declarations */
    enum RaffleState{
        OPEN,                //1
        CALCULATING          //2
    }
   

    /** State variables */
    unit16 private constant REQUEST_CONFIRMATIONS = 3;
    uint256 private immutable i_entranceFee;
    uint32 private constant NUM_WORDS = 1;
    //@dev the duration of the interval in seconds
    uint256 private immutable i_interval;
    bytes32 private immutable i_keyHash;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    address payable[] private s_players;
    uint256 private s_lastTimeStamp;
    address private s_recentWinner;
    RaffleState private s_raffleState;

    /** Events */
    event RaffleEnter(address indexed player);
    event RaffleWinner(address indexed winner);

    constructor(uint256 entranceFee, uint256 interval, address vrfCoordinator,bytes32 gasLane,
    uint64 subscriptionId, uint32 callbackGasLimit)
    
    VRFConsumerBaseV2Plus(vrfCoordinator){
        i_entranceFee = entranceFee;
        i_interval = interval;
        s_lastTimeStamp = block.timestamp;
        i_keyHash = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        s_raffleState = RaffleState.OPEN;
    }
    function enterRaffle() external payable{
        //require(msg.value > i_entranceFee, "Not enough ETH");
        //require(msg.value >= i_entranceFee, SendMoreToEnterRaffle());

        if (msg.value < i_entranceFee){
            revert Raffle__SendMoreToEnterRaffle();

        if(s_raffleState != RaffleState.OPEN){
            revert Raffle__RaffleNotOpen();
        }
        }
        s_players.push(payable(msg.sender));
        //1. make migration easier
        //2. makes frontend integration easier
        emit RaffleEnter(msg.sender);

        //1. Get a random number
        //2. Use the random number to pick a winner
        //3. Be automatically called
    }
    
    function pickWinner() external{
        //check to see if time interval has passed

        //1000 - 900 = 100, 50
        if((block.timestamp - lastTimeStamp) < i_interval){
            revert()
        }
            s_raffleState = RaffleState.CALCULATING;
            VRFV2PlusClient.RandomWordsRequest memory request = VRFV2PlusClient.RandomWordsRequest({
                keyHash: s_keyHash,
                subId: s_subscriptionId,
                requestConfirmations: REQUEST_CONFIRMATIONS,
                callbackGasLimit: callbackGasLimit,
                numWords: NUM_WORDS,
                extraArgs: VRFV2PlusClient.argsToBytes(
                    //Set native payment to true to pay for VRF request with SEPOLIA ethereum instead of LINK tokens
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            })
        uint256requestId = s_vrfCoordinator.requestRandomWords();
    }

    //CEI Checks Effects Interactions Patterns

    function fulfillRandomWords(uint256 RequestId, uint256[] calldata randomWords) internal override{

        //Checks

        // s_player: 10
        // rng: 12
        // 12%10 = 2
        // winner = s_players[2]

        //Effects (Internal Contract State)
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable winner = s_players[indexOfWinner];
        s_recentWinner = winner;


        s_raffleState = RaffleState.OPEN;
        s_players = new address payable[](0);
        s_lastTimeStamp = block.timestamp;
        emit WinnerPicked(s_recentWinner);

        //Interactions (External Contract Interactions)
        (bool success, ) = recentWinner.call{value: address(this).balance}("");
        if(!success){
            revert Raffle__TransferFailed();
        }
        
    }

    /**Getter functions */
    function getEntranceFee() external view returns (uint256){
        return i_entranceFee;

        
    }
}
