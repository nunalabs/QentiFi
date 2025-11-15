// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/MemeTokenFactory.sol";
import "../src/MemeToken.sol";
import "../src/BondingCurveAMM.sol";

/**
 * @title DeployScript
 * @notice Deployment script for QentiFi contracts
 * @dev Run with: forge script script/Deploy.s.sol:DeployScript --rpc-url <network> --broadcast
 */
contract DeployScript is Script {
    // Deployment addresses will be saved here
    MemeTokenFactory public factory;

    // Configuration
    uint256 public constant CREATION_FEE = 0.01 ether; // 0.01 ANDE

    function run() external {
        // Get deployer private key from environment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        console.log("Deploying contracts with account:", deployer);
        console.log("Account balance:", deployer.balance);

        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);

        // Deploy MemeTokenFactory
        factory = new MemeTokenFactory(deployer, CREATION_FEE);
        console.log("MemeTokenFactory deployed at:", address(factory));

        // Verify deployment
        require(address(factory) != address(0), "Factory deployment failed");
        require(factory.owner() == deployer, "Owner mismatch");
        require(factory.creationFee() == CREATION_FEE, "Creation fee mismatch");

        console.log("Deployment successful!");
        console.log("Factory address:", address(factory));
        console.log("Owner:", factory.owner());
        console.log("Creation fee:", factory.creationFee());

        vm.stopBroadcast();

        // Save deployment addresses to file
        saveDeployment();
    }

    function saveDeployment() internal {
        string memory obj = "deployment";
        vm.serializeAddress(obj, "factory", address(factory));
        vm.serializeAddress(obj, "deployer", factory.owner());
        vm.serializeUint(obj, "creationFee", factory.creationFee());
        string memory finalJson = vm.serializeUint(obj, "chainId", block.chainid);

        string memory filename = string.concat(
            "./deployments/",
            vm.toString(block.chainid),
            ".json"
        );
        vm.writeJson(finalJson, filename);
        console.log("Deployment info saved to:", filename);
    }
}

/**
 * @title CreateTestTokenScript
 * @notice Script to create a test meme token
 * @dev Run after deployment to test the factory
 */
contract CreateTestTokenScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address factoryAddress = vm.envAddress("FACTORY_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        MemeTokenFactory factory = MemeTokenFactory(payable(factoryAddress));

        // Create test token
        (address token, address bondingCurve) = factory.createMemeToken{
            value: factory.creationFee()
        }(
            "Qenti Test Token",
            "QTEST",
            "ipfs://QmTestImageHash"
        );

        console.log("Test token created:");
        console.log("Token address:", token);
        console.log("Bonding curve:", bondingCurve);

        vm.stopBroadcast();
    }
}
