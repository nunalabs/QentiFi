// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/MemeTokenFactory.sol";
import "../src/QentiFiPoolManager.sol";
import "../src/QentiToken.sol";
import "../src/StakingVault.sol";
import "../src/QentiNFTBadges.sol";
import "../src/GamificationHook.sol";

/**
 * @title DeployAll
 * @notice Deploys all QentiFi contracts in the correct order
 * @dev Run with: forge script script/DeployAll.s.sol:DeployAll --rpc-url $ANDE_RPC_URL --broadcast --verify
 */
contract DeployAll is Script {
    // Deployment addresses
    address public factory;
    address public poolManager;
    address public qentiToken;
    address public stakingVault;
    address public nftBadges;
    address public gamificationHook;

    // Configuration
    address public communityRewards;
    address public daoTreasury;
    address public liquidityMining;
    address public teamAndAdvisors;
    address public publicSale;

    function setUp() public {
        // Set distribution addresses (replace with actual addresses)
        communityRewards = vm.envOr("COMMUNITY_REWARDS", address(0));
        daoTreasury = vm.envOr("DAO_TREASURY", address(0));
        liquidityMining = vm.envOr("LIQUIDITY_MINING", address(0));
        teamAndAdvisors = vm.envOr("TEAM_AND_ADVISORS", address(0));
        publicSale = vm.envOr("PUBLIC_SALE", address(0));

        // Default to deployer if not set
        if (communityRewards == address(0)) {
            communityRewards = msg.sender;
            console.log("Using deployer address for communityRewards");
        }
        if (daoTreasury == address(0)) {
            daoTreasury = msg.sender;
            console.log("Using deployer address for daoTreasury");
        }
        if (liquidityMining == address(0)) {
            liquidityMining = msg.sender;
            console.log("Using deployer address for liquidityMining");
        }
        if (teamAndAdvisors == address(0)) {
            teamAndAdvisors = msg.sender;
            console.log("Using deployer address for teamAndAdvisors");
        }
        if (publicSale == address(0)) {
            publicSale = msg.sender;
            console.log("Using deployer address for publicSale");
        }
    }

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        console.log("Deploying contracts with:", deployer);
        console.log("Deployer balance:", deployer.balance);

        vm.startBroadcast(deployerPrivateKey);

        // 1. Deploy QentiToken (Governance Token)
        console.log("\n=== Deploying QentiToken ===");
        QentiToken _qentiToken = new QentiToken(
            communityRewards,
            daoTreasury,
            liquidityMining,
            teamAndAdvisors,
            publicSale
        );
        qentiToken = address(_qentiToken);
        console.log("QentiToken deployed at:", qentiToken);

        // 2. Deploy NFT Badges
        console.log("\n=== Deploying QentiNFTBadges ===");
        QentiNFTBadges _nftBadges = new QentiNFTBadges();
        nftBadges = address(_nftBadges);
        console.log("QentiNFTBadges deployed at:", nftBadges);

        // 3. Deploy Gamification Hook
        console.log("\n=== Deploying GamificationHook ===");
        GamificationHook _gamificationHook = new GamificationHook(nftBadges);
        gamificationHook = address(_gamificationHook);
        console.log("GamificationHook deployed at:", gamificationHook);

        // 4. Grant MINTER_ROLE to GamificationHook
        console.log("\n=== Granting MINTER_ROLE to GamificationHook ===");
        _nftBadges.grantRole(_nftBadges.MINTER_ROLE(), gamificationHook);
        console.log("MINTER_ROLE granted");

        // 5. Deploy MemeTokenFactory
        console.log("\n=== Deploying MemeTokenFactory ===");
        MemeTokenFactory _factory = new MemeTokenFactory(deployer);
        factory = address(_factory);
        console.log("MemeTokenFactory deployed at:", factory);

        // 6. Set hooks contract in factory
        console.log("\n=== Setting Hooks Contract ===");
        _factory.setHooksContract(gamificationHook);
        console.log("Hooks contract set");

        // 7. Deploy PoolManager
        console.log("\n=== Deploying QentiFiPoolManager ===");
        QentiFiPoolManager _poolManager = new QentiFiPoolManager();
        poolManager = address(_poolManager);
        console.log("QentiFiPoolManager deployed at:", poolManager);

        // 8. Deploy StakingVault
        console.log("\n=== Deploying StakingVault ===");
        StakingVault _stakingVault = new StakingVault(qentiToken);
        stakingVault = address(_stakingVault);
        console.log("StakingVault deployed at:", stakingVault);

        // 9. Transfer initial QENTI rewards to StakingVault
        console.log("\n=== Transferring QENTI to StakingVault ===");
        uint256 stakingRewards = 50_000_000 * 10**18; // 50M QENTI for staking
        _qentiToken.transfer(stakingVault, stakingRewards);
        console.log("Transferred 50M QENTI to StakingVault");

        // 10. Create initial staking vaults
        console.log("\n=== Creating Initial Staking Vaults ===");

        // QENTI staking vault (30 days lock, 10 QENTI/second)
        _stakingVault.createVault(
            qentiToken,
            10 * 10**18, // 10 QENTI per second
            30 days
        );
        console.log("Created QENTI staking vault (30 days)");

        vm.stopBroadcast();

        // Print deployment summary
        console.log("\n=== DEPLOYMENT SUMMARY ===");
        console.log("QentiToken:", qentiToken);
        console.log("QentiNFTBadges:", nftBadges);
        console.log("GamificationHook:", gamificationHook);
        console.log("MemeTokenFactory:", factory);
        console.log("QentiFiPoolManager:", poolManager);
        console.log("StakingVault:", stakingVault);

        // Save deployment addresses to file
        string memory deploymentInfo = string(abi.encodePacked(
            "{\n",
            '  "qentiToken": "', vm.toString(qentiToken), '",\n',
            '  "nftBadges": "', vm.toString(nftBadges), '",\n',
            '  "gamificationHook": "', vm.toString(gamificationHook), '",\n',
            '  "factory": "', vm.toString(factory), '",\n',
            '  "poolManager": "', vm.toString(poolManager), '",\n',
            '  "stakingVault": "', vm.toString(stakingVault), '"\n',
            "}\n"
        ));

        vm.writeFile("deployments/ande-testnet.json", deploymentInfo);
        console.log("\nDeployment addresses saved to deployments/ande-testnet.json");
    }
}
