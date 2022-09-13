// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./IWallet.sol";

contract MultiSigWallet is IWallet {

    address[] public owners;
    mapping(address => bool) public isOnwer;
    uint public confirmRequireCount;

    Transaction[] public txs;
    mapping(uint => mapping(address => bool)) public txConfirmed;

    modifier onlyOnwer() {
        require(isOnwer[msg.sender], "permission denied.");
        _;
    }

    modifier txExists(uint _txIndex) {
        require(txs.length > _txIndex, "tx not exists.");
        _;
    }

    modifier txNotConfirmed(uint _txIndex) {
        require(!txConfirmed[_txIndex][msg.sender], "tx already confirmed.");
        _;
    }

    modifier txNotExecuted(uint _txIndex) {
        require(!txs[_txIndex].executed, "tx already executed.");
        _;
    }

    modifier txAllConfirmed(uint _txIndex) {
        require(txs[_txIndex].confirmed >= confirmRequireCount, "tx not yet been all confirmed.");
        _;
    }

    constructor(address[] memory _owners) {
        require(_owners.length > 1, "minimum of two addresses are required.");
        
        for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "invalid owner address");

            isOnwer[owner] = true;
            owners.push(owner);
        }

        confirmRequireCount = _owners.length;
    }

    receive() external payable {
        emit WalletDepositEvent(msg.sender, msg.value, address(this).balance);
    }

    function getOwners() external view returns (address[] memory) {
        return owners;
    }

    function submitTx(address _to, uint _value) 
        external 
        onlyOnwer
    {
        uint txIndex = txs.length;
        txs.push(
            Transaction({
                to: _to,
                value: _value,
                executed: false,
                confirmed: 0
            })
        );

        emit WalletSubmitTxEvent(msg.sender, txIndex, _to, _value);
    }

    function confirmTx(uint _txIndex) 
        external 
        onlyOnwer
        txExists(_txIndex)
        txNotConfirmed(_txIndex)
        txNotExecuted(_txIndex)
    {
        Transaction storage order = txs[_txIndex];
        order.confirmed += 1;
        txConfirmed[_txIndex][msg.sender] = true;

        emit WalletConfirmTxEvent(msg.sender, _txIndex);
    }

    function cancelTx(uint _txIndex) 
        external 
        onlyOnwer
        txExists(_txIndex)
        txNotExecuted(_txIndex)
    {
        Transaction storage order = txs[_txIndex];
        require(txConfirmed[_txIndex][msg.sender], "tx not yet confirm.");

        order.confirmed -= 1;
        txConfirmed[_txIndex][msg.sender] = false;

        emit WalletCancelTxEvent(msg.sender, _txIndex);
    }

    function executeTx(uint _txIndex) 
        external 
        txAllConfirmed(_txIndex)
    {
        Transaction storage order = txs[_txIndex];
        order.executed = true;
        (bool success, ) = order.to.call{value: order.value}("");
        require(success, "tx execute failed.");

        emit WalletExecuteTxEvent(msg.sender, _txIndex);
    }
}