// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "division by zero");
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "modulo by zero");
        return a % b;
    }
}

library Balances {
    
    using SafeMath for *;
    
    function move(mapping(address => uint256) storage balances, address sender, address receiver, uint amount) internal {
        require(balances[sender] >= amount);
        require(SafeMath.add(balances[receiver] , amount) >= balances[receiver]);
        balances[sender] = SafeMath.sub(balances[sender] ,amount);
        balances[receiver] = SafeMath.add(balances[receiver],amount);
    }
}

contract Token {
    
    using Balances for *;
    using SafeMath for uint;
    mapping(address => uint256) private balances;
    mapping(address => mapping (address => uint256)) private allowed;
    
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;
    
    address private contractOwner;
    
    constructor () {
        _name = "Visto Club Token";
        _symbol = "VCT";
        _decimals = 0;
        _totalSupply = 1000000000;
        balances[msg.sender] = _totalSupply;
        contractOwner = msg.sender;
    }
    
    modifier onlyOwner() {
    require(msg.sender == contractOwner ,"you are not allowed, call the owner");
    _;
    }
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    function transferOwnership(address _newOwner) external onlyOwner {
    require(_newOwner != address(0));
    emit OwnershipTransferred(contractOwner, _newOwner);
    contractOwner = _newOwner;
  }
    
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }
    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }

    event Transfer(address sender, address receiver, uint amount);
    event Approval(address owner, address spender, uint amount);

    function mint(uint mintAmount) external onlyOwner{
        _totalSupply = SafeMath.add(_totalSupply, mintAmount);
        balances[msg.sender] = SafeMath.add(balances[msg.sender], mintAmount);
    }
    
    function burn(uint burnAmount) external onlyOwner{
        _totalSupply = SafeMath.sub(_totalSupply, burnAmount);
        balances[msg.sender] = SafeMath.sub(balances[msg.sender], burnAmount);
    }

    function transfer(address receiver, uint amount) public returns (bool success) {
        balances.move(msg.sender, receiver, amount);
        emit Transfer(msg.sender, receiver, amount);
        return true;
    }

    function transferFrom(address sender, address receiver, uint amount) public returns (bool success) {
        require(allowed[sender][msg.sender] >= amount);
        allowed[sender][msg.sender] = SafeMath.sub(allowed[sender][msg.sender], amount);
        balances.move(sender, receiver, amount);
        emit Transfer(sender, receiver, amount);
        return true;
    }
    
    function allowance(address owner, address spender) public view returns (uint256) {
        return allowed[owner][spender];
    }

    function approve(address spender, uint amount) public returns (bool success) {
        require(msg.sender != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
   
}