import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deployer } = await hre.getNamedAccounts();
    const { deploy } = hre.deployments;

    const votes = await deploy("Votes", {
        from: deployer,
        log: true,
    });

    console.log(`Votes contract: ` , votes.address);
};
export default func;
func.id = "deploy_votes";
func.tags = ["Votes"];

//   import { DeployFunction } from "hardhat-deploy/types";
//   import { HardhatRuntimeEnvironment } from "hardhat/types";
  
//   const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
//     const { deployer } = await hre.getNamedAccounts();
//     const { deploy } = hre.deployments;
  
//     const greeter = await deploy("Greeter", {
//       from: deployer,
//       args: ["Bonjour, le monde!"],
//       log: true,
//     });
  
//     console.log(`Greeter contract: `, greeter.address);
//   };
//   export default func;
//   func.id = "deploy_greeter"; // id required to prevent reexecution
//   func.tags = ["Greeter"];