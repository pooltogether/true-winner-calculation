pragma solidity ^0.5.0;

import "pooltogether-contracts/contracts/Pool.sol";
import "pooltogether-contracts/contracts/UniformRandomNumber.sol";
import "kleros/contracts/data-structures/SortitionSumTreeFactory.sol";
import "openzeppelin-eth/contracts/ownership/Ownable.sol";
import "openzeppelin-eth/contracts/math/SafeMath.sol";

contract PoolState is Ownable {
    using SafeMath for uint256;
    using SortitionSumTreeFactory for SortitionSumTreeFactory.SortitionSumTrees;

    struct Entry {
        address addr;
        int256 amount;
        uint256 ticketCount;
        int256 withdrawnNonFixed;
    }

    event BoughtTickets(address indexed sender, int256 count, int256 totalDeposit, uint256 totalPrice, int256 newTotal);

    bytes32 public constant SUM_TREE_KEY = "PoolPool";

    mapping (address => Entry) private entries;
    bytes32 public secret;
    bytes32 public blockHash;
    int256 public totalAmount;
    int256 public ticketPrice; //fixed point 24
    SortitionSumTreeFactory.SortitionSumTrees internal sortitionSumTrees;

    function init (bytes32 _secret, bytes32 _blockHash, int256 _ticketPrice, address _owner) public initializer {
        initialize(_owner);
        secret = _secret;
        blockHash = _blockHash;
        ticketPrice = FixidityLib.newFixed(_ticketPrice);
        sortitionSumTrees.createTree(SUM_TREE_KEY, 4);
    }

    function buyTickets(address _from, int256 _countNonFixed) public onlyOwner {
        require(_countNonFixed > 0, "number of tickets is less than or equal to zero");
        int256 count = FixidityLib.newFixed(_countNonFixed);
        int256 totalDeposit = FixidityLib.multiply(ticketPrice, count);
        uint256 totalDepositNonFixed = uint256(FixidityLib.fromFixed(totalDeposit));

        if (_hasEntry(_from)) {
            entries[_from].amount = FixidityLib.add(entries[_from].amount, totalDeposit);
            entries[_from].ticketCount = entries[_from].ticketCount.add(uint256(_countNonFixed));
        } else {
            entries[_from] = Entry(
                _from,
                totalDeposit,
                uint256(_countNonFixed),
                0
            );
        }

        int256 amountNonFixed = FixidityLib.fromFixed(entries[_from].amount);
        sortitionSumTrees.set(SUM_TREE_KEY, uint256(amountNonFixed), bytes32(uint256(_from)));

        totalAmount = FixidityLib.add(totalAmount, totalDeposit);

        emit BoughtTickets(_from, _countNonFixed, totalDeposit, totalDepositNonFixed, FixidityLib.fromFixed(totalAmount));
    }

    /**
    * @notice Selects and returns the winner's address
    * @return The winner's address
    */
    function winnerAddress() public view returns (address) {
        return selectWinner(selectRandom(entropy(), uint256(fixedTotal())));
    }

    function falseWinnerAddress() public view returns (address) {
        return selectWinner(selectRandom(uint256(secret), uint256(fixedTotal())));
    }

    function selectWinner(uint256 randomToken) public view returns (address) {
        return address(uint256(sortitionSumTrees.draw(SUM_TREE_KEY, randomToken)));
    }

    function fixedTotal() public view returns (int256) {
        return FixidityLib.fromFixed(totalAmount);
    }

    function selectRandom(uint256 entropy, uint256 total) public pure returns (uint256) {
        return UniformRandomNumber.uniform(entropy, total);
    }

    function entropy() public view returns (uint256) {
        return uint256(blockHash ^ secret);
    }

    function _hasEntry(address _addr) internal view returns (bool) {
        return entries[_addr].addr == _addr;
    }

}