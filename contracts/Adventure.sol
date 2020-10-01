// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >= 0.6.0 < 0.7.0;

/*
*  Adventure.sol
*  TWA V1 deflationary index token smart contract
*  2020-09-29
**/

interface IERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
  function transferFrom(address from, address to, uint256 value) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

  function ceil(uint256 a, uint256 m) internal pure returns (uint256) {
    uint256 c = add(a,m);
    uint256 d = sub(c,1);
    return mul(div(d,m),m);
  }
}

abstract contract ERC20Detailed is IERC20 {

  string private _name;
  string private _symbol;
  uint8 private _decimals;

  constructor(string memory name, string memory symbol, uint8 decimals) public {
    _name = name;
    _symbol = symbol;
    _decimals = decimals;
  }

  function name() public view returns(string memory) {
    return _name;
  }

  function symbol() public view returns(string memory) {
    return _symbol;
  }

  function decimals() public view returns(uint8) {
    return _decimals;
  }
}

contract Adventure is ERC20Detailed {

  using SafeMath for uint256;
  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowed;

  string constant tokenName = "Adventure";
  string constant tokenSymbol = "TWA";
  uint8  constant tokenDecimals = 18;
//   address constant twaFoundation = 0xD5677663C673cB48b05a4d51514ebdcb30FA4234;
//   address constant twaCommunity = 0xC5a0EAdd963cBb0F7E9A6F5753f6bFAD12df1BaA;
//   address constant twaMarketing = 0xc77019fE9825E65F56F4C079d010944C3ea1B598;
  address public twaFoundation = 0x7D6c6B479b247f3DEC1eDfcC4fAf56c5Ff9A5F40;
  address public twaCommunity = 0x0921B5A15c48C7a3A30A7d9Bd0cC2425801D59DC;
  address public twaMarketing = 0x567157ffD7012c19f9bD900A9b280D839041acd4;
  uint twaMarketingLockedUntilBlock;
  uint256 _totalSupply = 101000000000000000000000000;
  uint256 public basePercent = 100;

  constructor() public payable ERC20Detailed(tokenName, tokenSymbol, tokenDecimals) {
    _issue(twaFoundation, 30000000000000000000000000);
    _issue(twaCommunity, 55000000000000000000000000);
    _issue(twaMarketing, 16000000000000000000000000);
    
    // 24 months with an average block time of 13 seconds is 4851692 blocks
    twaMarketingLockedUntilBlock = block.number.add(4851692);
  }
  
  function getTwaMarketingLockedUntilBlock() public view returns (uint256) {
      return twaMarketingLockedUntilBlock;
  }

  function totalSupply() public override view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address owner) public override view returns (uint256) {
    return _balances[owner];
  }

  function allowance(address owner, address spender) public override view returns (uint256) {
    return _allowed[owner][spender];
  }

  function cut(uint256 value) public view returns (uint256)  {
    uint256 roundValue = value.ceil(basePercent);
    uint256 cutValue = roundValue.mul(basePercent).div(10000);
    return cutValue;
  }

  function transfer(address to, uint256 value) public override returns (bool) {
    require(value <= _balances[msg.sender]);
    require(to != address(0));
    require(canTransact(msg.sender) == true);

    uint256 tokensToBurn = cut(value);
    uint256 tokensToTransfer = value.sub(tokensToBurn);

    _balances[msg.sender] = _balances[msg.sender].sub(value);
    _balances[to] = _balances[to].add(tokensToTransfer);

    _totalSupply = _totalSupply.sub(tokensToBurn);

    emit Transfer(msg.sender, to, tokensToTransfer);
    emit Transfer(msg.sender, address(0), tokensToBurn);
    return true;
  }


  function approve(address spender, uint256 value) public override returns (bool) {
    require(spender != address(0));
    require(canTransact(msg.sender) == true);
    emit Approval(msg.sender, spender, value);
    return true;
  }

  function transferFrom(address from, address to, uint256 value) public override returns (bool) {
    require(value <= _balances[from]);
    require(value <= _allowed[from][msg.sender]);
    require(to != address(0));
    require(canTransact(from) == true);

    _balances[from] = _balances[from].sub(value);

    uint256 tokensToBurn = cut(value);
    uint256 tokensToTransfer = value.sub(tokensToBurn);

    _balances[to] = _balances[to].add(tokensToTransfer);
    _totalSupply = _totalSupply.sub(tokensToBurn);

    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

    emit Transfer(from, to, tokensToTransfer);
    emit Transfer(from, address(0), tokensToBurn);

    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    require(spender != address(0));
    _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    require(spender != address(0));
    _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  function _issue(address account, uint256 amount) internal {
    require(amount != 0);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

  function destroy(uint256 amount) external {
    _destroy(msg.sender, amount);
  }

  function _destroy(address account, uint256 amount) internal {
    require(amount != 0);
    require(amount <= _balances[account]);
    _totalSupply = _totalSupply.sub(amount);
    _balances[account] = _balances[account].sub(amount);
    emit Transfer(account, address(0), amount);
  }

  function destroyFrom(address account, uint256 amount) external {
    require(amount <= _allowed[account][msg.sender]);
    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(amount);
    _destroy(account, amount);
  }
   
  function canTransact(address account) public view returns (bool) {
      if (account != twaFoundation) {
          return true;
      }
      
      if (block.number < twaMarketingLockedUntilBlock) {
        return false;
      }
      
      return true;
  }
}