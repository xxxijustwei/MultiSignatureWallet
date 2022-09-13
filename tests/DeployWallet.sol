// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../contracts/MultiSigWallet.sol";

contract DeployWallet {
    
    event Deploy(address);

    function deployWallet(address[] memory owners) 
        external
        returns (address walletAddress)
    {
        bytes memory code = abi.encodePacked(type(MultiSigWallet).creationCode, abi.encode(owners));
        
        assembly {
            walletAddress := create(callvalue(), add(code, 0x20), mload(code))
        }

        require(walletAddress != address(0), "deploy failed!");
        emit Deploy(walletAddress);
    }
}
