// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IWallet {

    struct Transaction {
        address to;
        uint value;
        bool executed;
        uint confirmed;
    }

    event WalletSubmitTxEvent(address indexed sender, uint indexed txIndex, address indexed to, uint value);
    event WalletDepositEvent(address indexed from, uint amount, uint balance);
    event WalletConfirmTxEvent(address indexed sender, uint indexed txIndex);
    event WalletCancelTxEvent(address indexed sender, uint indexed txIndex);
    event WalletExecuteTxEvent(address indexed sender, uint indexed txIndex);

    function getOwners() external view returns (address[] memory);

    function submitTx(address _to, uint _value) external;

    function confirmTx(uint _txIndex) external;

    function cancelTx(uint _txIndex) external;

    function executeTx(uint _txIndex) external;
}