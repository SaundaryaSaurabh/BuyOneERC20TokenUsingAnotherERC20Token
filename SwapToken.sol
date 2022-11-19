// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


contract TokenSwap is AccessControl,ReentrancyGuard {

    using Address for address;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

 // Token used for Swap Contract.
    IERC20 public immutable vpayContractAddress;
    IERC20 public immutable busdContractAddress;

    uint256 constant price = 100;
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");


    error OnlyAdmin(address caller);
    error ZeroAddress();
       
    constructor(IERC20 _vpay, IERC20 _busd )  {
        
        if (address(_vpay) == address(0)) {
            revert ZeroAddress();
        }
         if (address(_busd) == address(0)) {
            revert ZeroAddress();
        }

        vpayContractAddress = _vpay;
        busdContractAddress = _busd;
        //address owner = msg.sender;
         _grantRole(ADMIN_ROLE, msg.sender);
    }
      
      modifier onlyAdmin() {
        // check whether the caller has the ADMIN_ROLE.
        if (!hasRole(ADMIN_ROLE, msg.sender)) {
            // The caller doesnot have the role, revert.
            revert OnlyAdmin(msg.sender);
        }

        // Continue with function execution.
        _;
    }
    // Functions for Admin to be used in Functions
      function isAdmin(address account)
        public
        view
        returns (bool isRoleAssigned)
    {
        return hasRole(ADMIN_ROLE, account);
    }

    event BuyVPAYusingBUSD (address indexed buyer,  uint amount);
    event BuyBUSDusingVPAY (address indexed buyer,  uint amount);
    event ADD_VPAY_ToContract (address indexed Contract, uint amount);
    event ADD_BUSD_ToContract (address indexed Contract, uint amount);
    event Withdraw_VPAY_ToContract (address indexed eoa, uint amount);
    event Withdraw_BUSD_ToContract (address indexed eoa, uint amount);

    // Function To Add VPAY Token By Admin To The Smart Contract 
    function depositVpay (uint _amountToDeposit) onlyAdmin public returns (bool) {
        uint amount_Available = (vpayContractAddress.balanceOf(msg.sender)).div(1000000000000000000);
        require (amount_Available == _amountToDeposit);
        vpayContractAddress.transfer(address(this), _amountToDeposit);
        emit ADD_VPAY_ToContract(address(this),_amountToDeposit );
        return true;
    }
    // Function To Add BUSD Token By Admin To The Smart Contract 
     function depositBUSD (uint _amountToDeposit) onlyAdmin public returns (bool) {
        uint amount_Available = (busdContractAddress.balanceOf(msg.sender)).div(1000000000000000000);
        require (amount_Available == _amountToDeposit);
        busdContractAddress.transfer(address(this), _amountToDeposit);
        emit ADD_BUSD_ToContract(address(this),_amountToDeposit );
        return true;
    }

    // Function To Withdraw VPAY Token By Admin From The Smart Contract 
    function withdraw_VPAY (uint _amountToDeposit) onlyAdmin public returns (bool) {
        uint amount_Available = (vpayContractAddress.balanceOf(address(this))).div(1000000000000000000);
        require (amount_Available == _amountToDeposit);
        vpayContractAddress.transfer(msg.sender, _amountToDeposit);
        emit Withdraw_VPAY_ToContract(msg.sender,_amountToDeposit );
        return true;
    }

    // Function To Withdraw BUSD Token By Admin From The Smart Contract 
     function withdraw_BUSD (uint _amountToDeposit) onlyAdmin public returns (bool) {
        uint amount_Available = (busdContractAddress.balanceOf(address(this))).div(1000000000000000000);
        require (amount_Available == _amountToDeposit);
        busdContractAddress.transfer(msg.sender, _amountToDeposit);
        emit Withdraw_BUSD_ToContract(msg.sender,_amountToDeposit );
        return true;
    }

    // Function To Buy VPAY using BUSD Token
        function buyVPAYusingBUSD(uint busd) public returns(bool){
        uint amount_Available = (busdContractAddress.balanceOf(msg.sender)).div(1000000000000000000);
        require (amount_Available == busd);
        busdContractAddress.transfer(address(this), busd);
        uint vpayToTransferreed = price.mul(busd);
        vpayContractAddress.transfer(msg.sender, vpayToTransferreed);
        emit BuyVPAYusingBUSD(msg.sender , vpayToTransferreed);
        return true;  
    }

    // Function To Buy BUSD using VPAY Token
        function buyBUSDusingVPAY(uint vpay) public returns(bool){
        uint amount_Available = (vpayContractAddress.balanceOf(msg.sender)).div(1000000000000000000);
        require (amount_Available == vpay);
        vpayContractAddress.transfer(address(this), vpay);
        uint busdToTransferreed = price.div(vpay);
        busdContractAddress.transfer(msg.sender, busdToTransferreed);
        emit BuyBUSDusingVPAY(msg.sender , busdToTransferreed);
        return true;
    }

    // View Function To Retrive Total VPAY available in Smart Contract 
        function vpayValueInSmartContract () public view onlyAdmin  returns(uint){
            uint vpay_amount_Available = (vpayContractAddress.balanceOf(address(this))).div(1000000000000000000);
            return vpay_amount_Available;
        }

    // View Function To Retrive Total BUSD available in Smart Contract
        function busdValueInSmartContract () public view onlyAdmin returns(uint){
            uint busd_amount_Available = (busdContractAddress.balanceOf(address(this))).div(1000000000000000000);
            return busd_amount_Available;
        }


    fallback() external {
        revert();
    }

    receive() external payable {
        revert();
    }
}
