// This script can be used to deploy the "MultiSigWallet" contract using ethers.js library.
// Please make sure to compile "./contracts/MultiSigWallet.sol" file before running this script.
// And use Right click -> "Run" from context menu of the file to run the script. Shortcut: Ctrl+Shift+S

import { deploy } from './ethers-lib'

(async () => {
    try {
        const result = await deploy('MultiSigWallet', [["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4", "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2"]])
        console.log(`address: ${result.address}`)
    } catch (e) {
        console.log(e.message)
    }
  })()