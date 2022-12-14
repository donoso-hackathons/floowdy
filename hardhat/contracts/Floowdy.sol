//SPDX-License-Identifier: UnlicenseIERC20
pragma solidity >=0.4.22 <0.9.0;

// import "hardhat/console.sol";

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
// import "@openzeppelin/contracts/token/ERC777/ERC777.sol";
// import "@openzeppelin/contracts/token/ERC777/IERC777.sol";
import "@openzeppelin/contracts/utils/introspection/IERC1820Registry.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777Recipient.sol";

// import "@openzeppelin/contracts/access/Ownable.sol";

// import {IPoolAddressesProvider} from "./aave/IPoolAddressesProvider.sol";
import {IPool} from "./aave/IPool.sol";
// import {IERC20} from "./aave/IERC20.sol";
import {DataTypesAAVE} from "./aave/DataTypes.sol";
import {ICreditDelegationToken} from "./aave/ICreditDelegationToken.sol";

import {ISuperfluid, ISuperAgreement, ISuperToken, ISuperApp, SuperAppDefinitions} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";
import {IConstantFlowAgreementV1} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/agreements/IConstantFlowAgreementV1.sol";
import {SuperAppBase} from "@superfluid-finance/ethereum-contracts/contracts/apps/SuperAppBase.sol";
import {CFAv1Library} from "@superfluid-finance/ethereum-contracts/contracts/apps/CFAv1Library.sol";

import {IOps} from "./gelato/IOps.sol";

// import {IPUSHCommInterface} from "./epns/IPUSHCommInterface.sol";

import {DataTypes} from "./libraries/DataTypes.sol";
import {Events} from "./libraries/Events.sol";

contract Floowdy is SuperAppBase, IERC777Recipient {
  using SafeMath for uint256;

  uint256 MAX_INT;

  ISuperfluid public host; // host
  IConstantFlowAgreementV1 public cfa; // the stored constant flow agreement class address
  ISuperToken superToken;

  IERC20 token;
  IERC20 aToken;

  IPool aavePool;
  address stableDebtToken;
  address debtToken;
   bytes32 public aaveTaksId;

  using CFAv1Library for CFAv1Library.InitData;
  CFAv1Library.InitData internal _cfaLib;

  mapping(address => DataTypes.Member) public members;
  mapping(uint256 => address) public memberAdressById;

  uint256 nrMembers;
  mapping(uint256 => DataTypes.Pool) public poolByTimestamp;
  uint256 public poolId;
  uint256 public poolTimestamp;

  address immutable owner;

  //////// CREDIT STATE
  uint256 public totalCredits;
  mapping(uint256 => DataTypes.Credit) public creditsById;
  mapping(address => uint256) public creditIdByAddresse;
  mapping(uint256 => mapping(address => uint256)) public delegatorsStatus;

  uint256 MAX_ALLOWANCE = 50;
  uint256 CREDIT_FEE = 3;
  uint256 CREDIT_PHASES_INTERVAL = 300;

  address public ops;
  address payable public gelato;
  address public constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

  address public epnsComm;
  address public epnsChannel;

  uint256 PRECISSION = 1_000_000_000_000_000_000;

  constructor(DataTypes.Floowdy_Init memory floowdy_init) {
    require(address(floowdy_init.host) != address(0), "host is zero address");
    require(
      address(floowdy_init.superToken) != address(0),
      "acceptedToken is zero address"
    );
    owner = msg.sender;

    host = floowdy_init.host;
    superToken = floowdy_init.superToken;
    token = floowdy_init.token;
    aavePool = floowdy_init.pool;
    aToken = floowdy_init.aToken;
    debtToken = floowdy_init.debtToken;
    stableDebtToken = floowdy_init.stableDebtToken;
    epnsComm = floowdy_init.epnsComm;
    epnsChannel = floowdy_init.epnsChannel;

    cfa = IConstantFlowAgreementV1(
      address(
        host.getAgreementClass(
          keccak256(
            "org.superfluid-finance.agreements.ConstantFlowAgreement.v1"
          )
        )
      )
    );
    _cfaLib = CFAv1Library.InitData(host, cfa);
    uint256 configWord = SuperAppDefinitions.APP_LEVEL_FINAL |
      SuperAppDefinitions.BEFORE_AGREEMENT_CREATED_NOOP |
      SuperAppDefinitions.BEFORE_AGREEMENT_UPDATED_NOOP |
      SuperAppDefinitions.BEFORE_AGREEMENT_TERMINATED_NOOP;

    host.registerApp(configWord);

    MAX_INT = 2**256 - 1;
    token.approve(address(aavePool), MAX_INT);
    IERC20(debtToken).approve(address(aavePool), MAX_INT);
    IERC20(address(token)).approve(address(superToken), MAX_INT);

    //// tokens receie implementation
    ops = floowdy_init.ops;
    gelato = IOps(ops).gelato();

    //// tokens receie implementation
    IERC1820Registry _erc1820 = IERC1820Registry(
      0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24
    );
    bytes32 TOKENS_RECIPIENT_INTERFACE_HASH = keccak256(
      "ERC777TokensRecipient"
    );

    _erc1820.setInterfaceImplementer(
      address(this),
      TOKENS_RECIPIENT_INTERFACE_HASH,
      address(this)
    );

   aaveTaksId =  _launchStakeToAaveTask();
  }

  /**
   * @notice ERC277 call back allowing deposit tokens via .send()
   * @param from Member (user sending tokens / depositing)
   * @param amount amount received
   */
  function tokensReceived(
    address operator,
    address from,
    address to,
    uint256 amount,
    bytes calldata userData,
    bytes calldata operatorData
  ) external override {
    require(msg.sender == address(superToken), "INVALID_TOKEN");
    require(amount > 0, "AMOUNT_TO_BE_POSITIVE");

    _deposit(from, amount);
  }

  // ============= ============= Members ============= ============= //
  // #region Members

  function _deposit(address _member, uint256 amount) internal {
    _poolRebalance();

    _memberUpdate(_member);
    DataTypes.Member storage member = members[_member];
    // poolByTimestamp[block.timestamp].totalShares = poolByTimestamp[block.timestamp].totalShares + inDeposit - outDeposit;
    poolByTimestamp[block.timestamp].totalDeposit += amount;
    member.deposit += amount;

    if (member.flow > 0) {
      member.deposit +=
        uint96(member.flow) *
        (block.timestamp - member.timestamp);
    }

    member.timestamp = block.timestamp;
    emit Events.MemberDeposit(member);
    poolByTimestamp[poolTimestamp].nrMembers = nrMembers;
    emit Events.PoolUpdated(poolByTimestamp[poolTimestamp]);
  }

  function memberWithdraw(uint256 amount) external onlyMember {
    uint256 available = _getMemberAvailable(msg.sender);
    require(amount < available, "NOT_ENOUGH:BALANCE");

    _poolRebalance();
    _memberUpdate(msg.sender);

    DataTypes.Member storage member = members[msg.sender];
    member.deposit = member.deposit - amount;

    aavePool.withdraw(address(token), amount.div(10**12), address(this));

    superToken.upgrade(amount);
    IERC20(address(superToken)).transfer(msg.sender, amount);
    uint256 aTokenBalance = aToken.balanceOf(address(this));

    poolByTimestamp[poolTimestamp].totalStaked = aTokenBalance;

    emit Events.MemberWithdraw(msg.sender, amount);
  }

  // #region Task Close Stream scdellued by member

  function createStopStreamTask(address _member, uint256 _duration)
    internal
    returns (bytes32 taskId)
  {
    taskId = IOps(ops).createTimedTask(
      uint128(block.timestamp + _duration),
      600,
      address(this),
      this.stopStreamExec.selector,
      address(this),
      abi.encodeWithSelector(this.checkStopStream.selector, _member),
      ETH,
      false
    );
  }

  // called by Gelato Execs
  function checkStopStream(address _receiver)
    external
    pure
    returns (bool canExec, bytes memory execPayload)
  {
    canExec = true;

    execPayload = abi.encodeWithSelector(
      this.stopStreamExec.selector,
      address(_receiver)
    );
  }

  /// called by Gelato
  function stopStreamExec(address _receiver) external onlyOps {
    //// check if

    //  _poolRebalance();

    //// every task will be payed with a transfer, therefore receive(), we have to fund the contract
    uint256 fee;
    address feeToken;

    (fee, feeToken) = IOps(ops).getFeeDetails();

    _transfer(fee, feeToken);

    (, int96 inFlowRate, , ) = cfa.getFlow(
      superToken,
      _receiver,
      address(this)
    );

    if (inFlowRate > 0) {
      _cfaLib.deleteFlow(_receiver, address(this), superToken);

      _updateFlow(_receiver, 0, 0, 0);
    }
  }

  // #endregion #region Task Close Stream

  // #endregion

  // #region  ============= =============  Internal Member Functions ============= ============= //

  function _getMember(address _member)
    internal
    returns (DataTypes.Member storage)
  {
    DataTypes.Member storage member = members[_member];

    if (member.id == 0) {
      nrMembers++;
      member.member = _member;
      member.initTimestamp = block.timestamp;
      member.id = nrMembers;

      memberAdressById[member.id] = _member;
    }

    return member;
  }

  /**
   * @notice Calculate the total balance of a user/member
   * @dev it calculate the yield earned and add the total deposit (send+stream)
   * @return realtimeBalance the realtime balance multiplied by precission (10**6)
   */
  function _getMemberBalance(address _member)
    internal
    view
    returns (uint256 realtimeBalance)
  {
    DataTypes.Member storage member = members[_member];

    uint256 yieldMember = totalYieldStakeEarnedMember(_member);

    realtimeBalance =
      yieldMember +
      (member.deposit) +
      uint96(member.flow) *
      (block.timestamp - member.timestamp);
  }

  function _getMemberAvailable(address _member)
    public
    view
    returns (uint256 availableBalance)
  {
    DataTypes.Member storage member = members[_member];

    uint256 balance = _getMemberBalance(_member);
    availableBalance = balance - member.amountLocked;
  }

  function _memberUpdate(address _member) internal {
    DataTypes.Member storage member = _getMember(_member);

    if (member.timestamp < block.timestamp) {
      uint256 memberBalance = _getMemberBalance(_member);
      // uint256 memberShares = balanceOf(_member);

      // member.shares = memberShares;

      int256 memberDepositUpdate = int256(memberBalance) -
        int256(member.deposit);

      uint256 yieldMember = totalYieldStakeEarnedMember(_member);

      if (member.flow > 0) {
        poolByTimestamp[block.timestamp].totalDepositFlow =
          poolByTimestamp[block.timestamp].totalDepositFlow -
          uint96(member.flow) *
          (block.timestamp - member.timestamp);
        poolByTimestamp[block.timestamp].totalDeposit =
          poolByTimestamp[block.timestamp].totalDeposit +
          uint256(memberDepositUpdate);
      }
      member.deposit = memberBalance;
      member.timestamp = block.timestamp;
    }
  }

  function _updateFlow(
    address _member,
    int96 _inFlow,
    bytes32 _taskId,
    uint256 _duration
  ) internal {
    DataTypes.Member storage member = members[_member];
    require(_inFlow >= 0, "ONLY_STREAM_IN_POSITIONS");
    _poolRebalance();
    _memberUpdate(_member);

    if (member.flowGelatoId != bytes32(0)) {
      cancelTask(member.flowGelatoId);
    }
    member.flowGelatoId = _taskId;
    member.flowDuration = _duration;

    poolByTimestamp[block.timestamp].totalFlow =
      poolByTimestamp[block.timestamp].totalFlow -
      member.flow +
      _inFlow;

    member.flow = _inFlow;

    emit Events.MemberStream(member);
    emit Events.PoolUpdated(poolByTimestamp[poolTimestamp]);
  }

  function _calculateYieldMember(address _member)
    internal
    view
    returns (uint256 yieldMember)
  {
    DataTypes.Member storage member = members[_member];

    uint256 lastTimestamp = member.timestamp;

    ///// Yield from deposit

    uint256 yieldFromDeposit = (member.deposit *
      (poolByTimestamp[poolTimestamp].depositIndex -
        poolByTimestamp[lastTimestamp].depositIndex)).div(PRECISSION);

    yieldMember = yieldFromDeposit;
    if (member.flow > 0) {
      ///// Yield from flow
      uint256 yieldFromFlow = uint96(member.flow) *
        (poolByTimestamp[poolTimestamp].flowIndex -
          poolByTimestamp[lastTimestamp].flowIndex).div(PRECISSION);

      yieldMember = yieldMember + yieldFromFlow;
    }
  }

  function totalYieldStakeEarnedMember(address _member)
    public
    view
    returns (uint256 yieldMember)
  {
    uint256 yieldEarned = _calculateYieldMember(_member);

    (
      uint256 yieldDepositNew,
      uint256 yieldFlowNew,
      uint256 yieldPool
    ) = _calculateIndexes();

    DataTypes.Member storage member = members[_member];

    uint256 yieldDeposit = (yieldDepositNew * member.deposit).div(PRECISSION);
    uint256 yieldInFlow = (uint96(member.flow) * yieldFlowNew).div(PRECISSION);

    yieldMember = yieldEarned + yieldDeposit + yieldInFlow;
  }

  // #endregion

  // ============= ============= Pool ============= ============= //
  // #region Pool

  function poolRebalance() external {
    _poolRebalance();
    emit Events.PoolUpdated(poolByTimestamp[poolTimestamp]);
  }

  function _poolRebalance() internal {
    poolId++;

    DataTypes.Pool memory currentPool = poolByTimestamp[block.timestamp];
    currentPool.id = poolId;

    currentPool.timestamp = uint64(block.timestamp);

    DataTypes.Pool memory lastPool = poolByTimestamp[poolTimestamp];

    uint256 poolSpan = currentPool.timestamp - lastPool.timestamp;

    currentPool.totalDeposit = lastPool.totalDeposit;
    currentPool.totalDepositFlow =
      uint96(lastPool.totalFlow) *
      poolSpan +
      lastPool.totalDepositFlow;

    currentPool.totalFlow = lastPool.totalFlow;
    uint256 yieldPool;
    (
      currentPool.depositIndex,
      currentPool.flowIndex,
      yieldPool
    ) = _calculateIndexes();

    currentPool.totalYieldStake = lastPool.totalYieldStake + yieldPool;
    currentPool.totalStaked = lastPool.totalStaked + yieldPool;
    currentPool.delegation.totalDelegated = lastPool.delegation.totalDelegated;
    currentPool.delegation.totalYieldCredit = lastPool
      .delegation
      .totalYieldCredit;
    currentPool.depositIndex = currentPool.depositIndex + lastPool.depositIndex;
    currentPool.flowIndex = currentPool.flowIndex + lastPool.flowIndex;

    currentPool.totalFlow = lastPool.totalFlow;

    currentPool.nrMembers = nrMembers;

    ////// APY CALCULATION
    // uint256 balance = currentPool.totalDeposit;
    //  uint256 apyPeriod = (yieldPool.mul(PRECISSION)).div(currentPool.totalDeposit);

    // uint256 newApy = (apyPeriod.mul(poolSpan) + lastPool.apy.mul(lastPool.apyDuration)).div(lastPool.apyDuration +poolSpan);

    // currentPool.apy = newApy;
    // currentPool.apyDuration = lastPool.apyDuration+ poolSpan;

    currentPool.poolSpan = poolSpan;
    currentPool.yieldPeriod = yieldPool;

    // console.log(452, balance);
    // console.log(newApy);

    currentPool.timestamp = uint64(block.timestamp);

    poolByTimestamp[block.timestamp] = currentPool;

    poolTimestamp = block.timestamp;
  }

  function _calculateIndexes()
    internal
    view
    returns (
      uint256 depositIndex,
      uint256 flowIndex,
      uint256 yieldPool
    )
  {
    DataTypes.Pool memory lastPool = poolByTimestamp[poolTimestamp];

    uint256 poolSpan = block.timestamp - lastPool.timestamp;

    uint256 averageFlowDeposit = (
      (uint96(lastPool.totalFlow) + lastPool.totalDepositFlow * poolSpan)
    ).div(2);

    uint256 totalDepositToYield = averageFlowDeposit + lastPool.totalDeposit;

    yieldPool = _calculatePoolYield(lastPool.totalStaked);

    if (totalDepositToYield == 0 || yieldPool == 0) {
      depositIndex = 0;
      flowIndex = 0;
    } else {
      if (lastPool.totalDeposit != 0) {
        depositIndex = (
          (lastPool.totalDeposit * yieldPool * PRECISSION).div(
            (lastPool.totalDeposit.div(10**12)) * totalDepositToYield
          )
        );
      }
      if (lastPool.totalFlow != 0) {
        flowIndex = (
          (averageFlowDeposit * yieldPool * PRECISSION).div(
            uint96(lastPool.totalFlow) * totalDepositToYield
          )
        );
      }
    }
  }

  function _calculatePoolYield(uint256 staked)
    internal
    view
    returns (uint256 yield)
  {
    yield = (IERC20(aToken).balanceOf(address(this))).sub(staked);
  }

  // #endregion Pool

  // ============= ============= Aave ============= ============= //
  // #region Aave

  function getAaveData()
    public
    view
    returns (
      uint256 totalDebtBase,
      uint256 availableBorrowsBase,
      uint256 depositAPR,
      uint256 stableBorrowAPR
    )
  {
    (, totalDebtBase, availableBorrowsBase, , , ) = aavePool.getUserAccountData(
      address(this)
    );

    DataTypesAAVE.ReserveData memory reserveData = aavePool.getReserveData(
      address(token)
    );

    depositAPR = reserveData.currentLiquidityRate;
    stableBorrowAPR = reserveData.currentStableBorrowRate;

    //  depositAPY = ((1 + (depositAPR / SECONDS_PER_YEAR)) ** SECONDS_PER_YEAR) - 1;
    //  stableBorrowAPY  = (1 + ((stableBorrowAPR / SECONDS_PER_YEAR)) ** SECONDS_PER_YEAR) - 1;
  }

  // #region Task GElATO CREDIT PHASE PERIOD
  function _launchStakeToAaveTask() internal returns (bytes32 taskId) {
    taskId = IOps(ops).createTaskNoPrepayment(
      address(this),
      this.supplyStakeToAave.selector,
      address(this),
      abi.encodeWithSelector(this.checkStakeAvailable.selector),
      ETH
    );
  }

  // called by Gelato Execs
  function checkStakeAvailable()
    external
    view
    returns (bool canExec, bytes memory execPayload)
  {
    canExec = superToken.balanceOf(address(this)) > 5 * 10**18;

    execPayload = abi.encodeWithSelector(this.supplyStakeToAave.selector);
  }

  /// called by Gelato
  function supplyStakeToAave() external onlyOps {
    //// check if

    uint256 balanceToStake = superToken.balanceOf(address(this)).div(10**12);


    //// every task will be payed with a transfer, therefore receive(), we have to fund the contract
    uint256 fee;
    address feeToken;

    (fee, feeToken) = IOps(ops).getFeeDetails();

    _transfer(fee, feeToken);

    // uint256 poolSuperTokenBalance = (superToken.balanceOf(address(this))).div(
    //   10**12
    // );

    superToken.downgrade(balanceToStake * 10**12);

    uint256 poolTokenBalance = token.balanceOf(address(this));

    _poolRebalance();
    aavePool.supply(address(token), poolTokenBalance, address(this), 0);

    DataTypes.Pool storage pool = poolByTimestamp[poolTimestamp];
    pool.totalStaked += poolTokenBalance;

    emit Events.PoolUpdated(pool);
  }

  // #endregion Task GElato CREDIT PHASE PERIOD

  // #endregion Aave

  // ============= ============= Credit Delegation ============= ============= //
  // #region Credit Delegation

  function requestCredit(DataTypes.CreditRequestOptions memory options)
    external
    onlyMember
    onlyOneCredit
  {
    // require(options.rateAave + options.ratePool >= CREDIT_FEE, "RATE_TOO_LOW");
    // uint256 maxAmount = getMaxAmount();

    // require(options.amount <= maxAmount, "NOT_ENOUGH_COLLATERAL");

    totalCredits++;
    DataTypes.Credit storage credit = creditsById[totalCredits];

    credit.id = totalCredits;
    credit.requester = msg.sender;
    credit.initTimestamp = block.timestamp;
    credit.finishPhaseTimestamp = block.timestamp + CREDIT_PHASES_INTERVAL;
    credit.status = DataTypes.CreditStatus.PHASE1;

    credit.delegatorsOptions.delegatorsRequired = 1;
    credit.delegatorsOptions.delegatorsAmount = options.amount;

    credit.gelatoTaskId = createCreditPhasesTask(
      credit.id,
      CREDIT_PHASES_INTERVAL
    );

    //// Getting aave

    //// Repayment Options
    uint256 totalYieldAave = options
      .amount
      .mul((options.rateAave) * options.interval * options.nrInstallments)
      .div(365 * 24 * 3600)
      .div(100);
    uint256 totalYieldPool = options
      .amount
      .mul((options.ratePool) * options.interval * options.nrInstallments)
      .div(365 * 24 * 3600)
      .div(100);

    uint256 installment = (
      options.amount.add(totalYieldAave.add(totalYieldPool))
    ).div(options.nrInstallments);

    uint256 installmentPrincipal = (options.amount).div(options.nrInstallments);

    DataTypes.CreditRepaymentOptions memory options = DataTypes
      .CreditRepaymentOptions(
        options.nrInstallments,
        options.interval,
        installment,
        installmentPrincipal,
        totalYieldAave.div(options.nrInstallments),
        totalYieldPool.div(options.nrInstallments),
        installment * options.nrInstallments,
        options.rateAave,
        options.ratePool,
        totalYieldAave + totalYieldPool,
        0,
        bytes32(0)
      );

    credit.repaymentOptions = options;

    /// notify
    emit Events.CreditRequested(credit);
  }

  function cancelCredit(uint256 creditId) external onlyMember {
    DataTypes.Credit storage credit = creditsById[creditId];
    require(credit.requester == msg.sender, "NOT_CREDIT_OWNER");
    credit.status = DataTypes.CreditStatus.CANCELLED;
    for (uint256 i = 0; i < credit.delegatorsOptions.delegatorsNr; i++) {
      DataTypes.Member storage member = members[
        credit.delegatorsOptions.delegators[i]
      ];
      member.amountLocked -= credit.delegatorsOptions.delegatorsAmount;
    }
    emit Events.CreditCancelled(credit);
  }

  function creditCheckIn(uint256 creditId) public onlyMember {
    uint256 balance = _getMemberAvailable(msg.sender);
    DataTypes.Credit storage credit = creditsById[creditId];
    DataTypes.Member storage member = members[msg.sender];
    // require(
    //   credit.status == DataTypes.CreditStatus.PHASE1 ||
    //     credit.status == DataTypes.CreditStatus.PHASE2 ||
    //     credit.status == DataTypes.CreditStatus.PHASE3,
    //   "CREDIT_NOT_AVAILABLE"
    // );
    // require(
    //   balance > credit.delegatorsOptions.delegatorsAmount,
    //   "NOT_ENOUGH_COLLATERAL"
    // );
    // require(
    //   delegatorsStatus[creditId][msg.sender] == 0,
    //   "MEMBER_ALREADY_CHECK_IN"
    // );
    // require(
    //   credit.delegatorsOptions.delegatorsNr <
    //     credit.delegatorsOptions.delegatorsRequired,
    //   "ALREADY_ENOUGH_DELEGATORS"
    // );
    credit.delegatorsOptions.delegatorsNr++;
    credit.delegatorsOptions.delegators.push(msg.sender);
    delegatorsStatus[creditId][msg.sender] = credit
      .delegatorsOptions
      .delegatorsNr;

    member.amountLocked += credit.delegatorsOptions.delegatorsAmount;
    emit Events.CreditCheckIn(creditId, msg.sender);
    emit Events.MemberDelegateCredit(msg.sender, member.amountLocked);
  }

  function creditCheckOut(uint256 creditId) public onlyMember {
    DataTypes.Credit storage credit = creditsById[creditId];
    DataTypes.Member storage member = members[msg.sender];
    require(delegatorsStatus[creditId][msg.sender] != 0, "MEMBER_NOT_CHECK_IN");
    require(
      credit.status == DataTypes.CreditStatus.PHASE1 ||
        credit.status == DataTypes.CreditStatus.PHASE2 ||
        credit.status == DataTypes.CreditStatus.PHASE3,
      "NOT_POSSIBLE"
    );

    uint256 toDeleteDelegatorPosition = delegatorsStatus[creditId][msg.sender];
    address lastDelegator = credit.delegatorsOptions.delegators[
      credit.delegatorsOptions.delegatorsNr - 1
    ];
    credit.delegatorsOptions.delegators[
      toDeleteDelegatorPosition - 1
    ] = lastDelegator;
    delegatorsStatus[creditId][lastDelegator] = toDeleteDelegatorPosition;
    credit.delegatorsOptions.delegators.pop();
    credit.delegatorsOptions.delegatorsNr--;
    delegatorsStatus[creditId][msg.sender] = 0;
    member.amountLocked -= credit.delegatorsOptions.delegatorsAmount;
    emit Events.CreditCheckOut(creditId, msg.sender);
  }

  function creditApproved(uint256 creditId) public onlyRequester(creditId) {
    DataTypes.Credit storage credit = creditsById[creditId];
    require(
      credit.status == DataTypes.CreditStatus.PHASE4,
      "NOT_COLLAERAL_AVAILABLE"
    );
    credit.status = DataTypes.CreditStatus.APPROVED;
    cancelTask(credit.gelatoTaskId);
    credit.repaymentOptions.GelatoRepaymentTaskId = _launchCreditAndRepayment(
      credit.id,
      credit.repaymentOptions.interval
    );

    emit Events.CreditApproved(credit);

    poolByTimestamp[poolTimestamp].delegation.totalDelegated += credit
      .repaymentOptions
      .amount;
    _poolRebalance();
    emit Events.PoolUpdated(poolByTimestamp[poolTimestamp]);
  }

  function rejectCredit(uint256 creditId) public onlyMember {
    DataTypes.Credit storage credit = creditsById[creditId];
    require(
      credit.status == DataTypes.CreditStatus.PHASE3,
      "CREDIT_NOT_AVAILABLE"
    );
    credit.status = DataTypes.CreditStatus.REJECTED;
    credit.delegatorsOptions.delegatorsRequired = 10;
    credit.finishPhaseTimestamp += CREDIT_PHASES_INTERVAL;
    //// Notify
    cancelTask(credit.gelatoTaskId);
    emit Events.CreditRejected(credit);
  }

  function getMaxAmount() public view returns (uint256 maxAmount) {
    uint256 balance = _getMemberAvailable(msg.sender);

    maxAmount = (100 + (100 - MAX_ALLOWANCE)).mul(balance);
  }

  modifier onlyOneCredit() {
    uint256 id = creditIdByAddresse[msg.sender];
    DataTypes.Credit storage credit = creditsById[id];

    require(
      credit.status == DataTypes.CreditStatus.NONE ||
        credit.status == DataTypes.CreditStatus.REJECTED ||
        credit.status == DataTypes.CreditStatus.CANCELLED ||
        credit.status == DataTypes.CreditStatus.REPAYED ||
        credit.status == DataTypes.CreditStatus.LIQUIDATED,
      "ALREADY_CREDIT_REQUEST"
    );
    _;
  }

  modifier onlyRequester(uint256 creditId) {
    DataTypes.Credit storage credit = creditsById[creditId];

    require(credit.requester == msg.sender, "NOT_cREDIT_OWNER");
    _;
  }

  modifier onlyMember() {
    DataTypes.Member memory _member = members[msg.sender];
    require(_member.id > 0, "NOT_MEMBER");
    _;
  }

  // #region Task GElATO CREDIT PHASE PERIOD
  function createCreditPhasesTask(uint256 _creditId, uint256 _dennyPeriod)
    internal
    returns (bytes32 taskId)
  {
    taskId = IOps(ops).createTimedTask(
      uint128(block.timestamp) + uint128(_dennyPeriod),
      uint128(_dennyPeriod),
      address(this),
      this.stopCreditPeriodExec.selector,
      address(this),
      abi.encodeWithSelector(this.checkCreditPeriod.selector, _creditId),
      ETH,
      false
    );
  }

  // called by Gelato Execs
  function checkCreditPeriod(uint256 _creditId)
    external
    pure
    returns (bool canExec, bytes memory execPayload)
  {
    canExec = true;

    execPayload = abi.encodeWithSelector(
      this.stopCreditPeriodExec.selector,
      _creditId
    );
  }

  function checkDelegation(uint256 amount) public {
    ICreditDelegationToken(address(stableDebtToken)).approveDelegation(
      msg.sender,
      amount
    );
  }

  /// called by Gelato
  function stopCreditPeriodExec(uint256 creditId) external {
    //// check if

    DataTypes.Credit storage credit = creditsById[creditId];

    //// every task will be payed with a transfer, therefore receive(), we have to fund the contract
    uint256 fee;
    address feeToken;

    (fee, feeToken) = IOps(ops).getFeeDetails();

    _transfer(fee, feeToken);

    if (credit.status == DataTypes.CreditStatus.PHASE1) {
      credit.finishPhaseTimestamp += CREDIT_PHASES_INTERVAL;
      if (
        credit.delegatorsOptions.delegatorsNr == 1 &&
        credit.delegatorsOptions.delegators.length == 1
      ) {
        credit.status = DataTypes.CreditStatus.PHASE4;

        ICreditDelegationToken(address(stableDebtToken)).approveDelegation(
          credit.requester,
          credit.repaymentOptions.amount
        );

        emit Events.CreditChangePhase(credit);
      } else {
        credit.status = DataTypes.CreditStatus.PHASE2;
        credit.delegatorsOptions.delegatorsRequired = 10;
        credit.delegatorsOptions.delegatorsAmount = credit
          .repaymentOptions
          .amount
          .div(10);

        emit Events.CreditChangePhase(credit);
      }

      //do the dance
    } else if (credit.status == DataTypes.CreditStatus.PHASE2) {
      if (
        credit.delegatorsOptions.delegatorsNr == 10 &&
        credit.delegatorsOptions.delegators.length == 10
      ) {
        ICreditDelegationToken(address(stableDebtToken)).approveDelegation(
          credit.requester,
          credit.repaymentOptions.amount
        );
        credit.status = DataTypes.CreditStatus.PHASE4;
        emit Events.CreditChangePhase(credit);
      } else {
        credit.status = DataTypes.CreditStatus.REJECTED;
        // credit.delegatorsOptions.delegatorsRequired = 5;
        // credit.delegatorsOptions.delegatorsAmount = credit
        //     .repaymentOptions
        //     .amount
        //     .div(5);
      }

      //do the dance
    }
    // else if (credit.status == DataTypes.CreditStatus.PHASE3) {
    //     if (
    //         credit.delegatorsOptions.delegatorsNr == 5 &&
    //         credit.delegatorsOptions.delegators.length == 5
    //     ) {
    //         credit.status = DataTypes.CreditStatus.PHASE4;
    //         ICreditDelegationToken(address(stableDebtToken)).approveDelegation(credit.requester, credit.repaymentOptions.amount);
    //         emit Events.CreditChangePhase(credit);
    //     } else {
    //         credit.status = DataTypes.CreditStatus.REJECTED;
    //     }
    //     //do the dance
    // }
    else if (credit.status == DataTypes.CreditStatus.PHASE4) {
      // ICreditDelegationToken(address(stableDebtToken)).approveDelegation(credit.requester, credit.repaymentOptions.amount);
      credit.status = DataTypes.CreditStatus.REJECTED;
    }

    if (credit.status == DataTypes.CreditStatus.REJECTED) {
      for (uint256 i = 0; i < credit.delegatorsOptions.delegatorsNr; i++) {
        DataTypes.Member storage member = members[
          credit.delegatorsOptions.delegators[i]
        ];
        member.amountLocked -= credit.delegatorsOptions.delegatorsAmount;
      }
      cancelTask(credit.gelatoTaskId);
      emit Events.CreditRejected(credit);
    }
  }

  // #endregion Task GElato CREDIT PHASE PERIOD

  // #endregion Credit Delegation

  // ============= ============= Credit OPS by Gelato ============= ============= //
  // #region Credit OPS

  // #region GELAT TO

  function _launchCreditAndRepayment(uint256 creditId, uint256 interval)
    internal
    returns (bytes32 taskId)
  {
    taskId = IOps(ops).createTimedTask(
      uint128(block.timestamp + interval),
      uint128(interval),
      address(this),
      this.triggerRepayment.selector,
      address(this),
      abi.encodeWithSelector(this.checkRepayment.selector, creditId),
      ETH,
      false
    );
  }

  // called by Gelato Execs
  function checkRepayment(uint256 creditId)
    external
    pure
    returns (bool canExec, bytes memory execPayload)
  {
    canExec = true;

    execPayload = abi.encodeWithSelector(
      this.triggerRepayment.selector,
      creditId
    );
  }

  /// called by Gelato
  function triggerRepayment(uint256 creditId) external onlyOps {
    DataTypes.Credit storage credit = creditsById[creditId];

    uint256 fee;
    address feeToken;

    (fee, feeToken) = IOps(ops).getFeeDetails();

    _transfer(fee, feeToken);

    if (
      credit.repaymentOptions.currentInstallment <=
      credit.repaymentOptions.nrInstallments
    ) {
      try
        IERC20(debtToken).transferFrom(
          credit.requester,
          address(this),
          credit.repaymentOptions.installment
        )
      returns (bool success) {
        credit.repaymentOptions.currentInstallment += 1;
        emit Events.CreditInstallment(creditId);

        for (uint256 i = 0; i < credit.delegatorsOptions.delegatorsNr; i++) {
          DataTypes.Member storage member = members[
            credit.delegatorsOptions.delegators[i]
          ];
          member.amountLocked -= credit.repaymentOptions.installmentPrincipal;
          member.yieldAccrued += credit
            .repaymentOptions
            .installmentRatePool
            .div(credit.delegatorsOptions.delegatorsNr);
        }

 

        // uint256 bal = IERC20(debtToken).balanceOf(address(this));
        aavePool.repay(
          debtToken,
          credit.repaymentOptions.installmentPrincipal +
            credit.repaymentOptions.installmentRateAave,
          1,
          address(this)
        );

        poolByTimestamp[poolTimestamp].delegation.totalYieldCredit =
          poolByTimestamp[poolTimestamp].delegation.totalYieldCredit +
          credit.repaymentOptions.installmentRatePool;
        _poolRebalance();
        emit Events.PoolUpdated(poolByTimestamp[poolTimestamp]);

        // recalculate credit conditions
      } catch {
        // console.log(972);
        credit.status = DataTypes.CreditStatus.LIQUIDATED;
        /// Liquidate the credit
        emit Events.CreditLiquidated(creditId);
      }
    }

    if (
      credit.repaymentOptions.currentInstallment ==
      credit.repaymentOptions.nrInstallments &&
      credit.status == DataTypes.CreditStatus.APPROVED
    ) {
      credit.status = DataTypes.CreditStatus.REPAYED;
       emit Events.CreditRepayed(creditId);
      //credit done
    }
  }

  // #endregion GELATO TASK REPAY

  // endregion CREDIT OPS

  // ============= ============= Super App Calbacks ============= ============= //
  // #region Super App Calbacks
  function afterAgreementCreated(
    ISuperToken _superToken,
    address _agreementClass,
    bytes32, // _agreementId,
    bytes calldata _agreementData,
    bytes calldata, // _cbdata,
    bytes calldata _ctx
  )
    external
    override
    onlyExpected(_superToken, _agreementClass)
    onlyHost
    returns (bytes memory newCtx)
  {
    newCtx = _ctx;

    (address sender, address receiver) = abi.decode(
      _agreementData,
      (address, address)
    );

    (, int96 inFlowRate, , ) = cfa.getFlow(superToken, sender, address(this));
    ISuperfluid.Context memory decodedContext = host.decodeCtx(_ctx);

    uint256 duration = 0;
    bytes32 taskId = bytes32(0);

    if (decodedContext.userData.length > 0) {
      duration = parseLoanData(host.decodeCtx(_ctx).userData);
      taskId = createStopStreamTask(sender, duration);
    }
    _updateFlow(sender, inFlowRate, taskId, duration);

    return newCtx;
  }

  function afterAgreementUpdated(
    ISuperToken _superToken,
    address _agreementClass,
    bytes32, // _agreementId,
    bytes calldata _agreementData,
    bytes calldata, //_cbdata,
    bytes calldata _ctx
  )
    external
    override
    onlyExpected(_superToken, _agreementClass)
    onlyHost
    returns (bytes memory newCtx)
  {
    newCtx = _ctx;

    (address sender, address receiver) = abi.decode(
      _agreementData,
      (address, address)
    );

    (, int96 inFlowRate, , ) = cfa.getFlow(superToken, sender, address(this));
    ISuperfluid.Context memory decodedContext = host.decodeCtx(_ctx);

    uint256 duration = 0;
    bytes32 taskId = bytes32(0);
    if (decodedContext.userData.length > 0) {
      duration = parseLoanData(host.decodeCtx(_ctx).userData);
      taskId = createStopStreamTask(sender, duration);
    }
    _updateFlow(sender, inFlowRate, taskId, duration);

    return newCtx;
  }

  function afterAgreementTerminated(
    ISuperToken, /*superToken*/
    address, /*agreementClass*/
    bytes32, // _agreementId,
    bytes calldata _agreementData,
    bytes calldata, /*cbdata*/
    bytes calldata _ctx
  ) external virtual override returns (bytes memory newCtx) {
    (address sender, address receiver) = abi.decode(
      _agreementData,
      (address, address)
    );
    newCtx = _ctx;
    _updateFlow(sender, 0, 0, 0);
    return newCtx;
  }

  function parseLoanData(bytes memory data)
    public
    pure
    returns (uint256 duration)
  {
    duration = abi.decode(data, (uint256));
  }

  function _isCFAv1(address agreementClass) private view returns (bool) {
    return
      ISuperAgreement(agreementClass).agreementType() ==
      keccak256("org.superfluid-finance.agreements.ConstantFlowAgreement.v1");
  }

  function _isSameToken(ISuperToken _superToken) private view returns (bool) {
    return address(_superToken) == address(superToken);
  }

  modifier onlyHost() {
    require(msg.sender == address(host), "RedirectAll: support only one host");
    _;
  }

  modifier onlyExpected(ISuperToken _superToken, address agreementClass) {
    require(_isSameToken(_superToken), "RedirectAll: not accepted token");
    require(_isCFAv1(agreementClass), "RedirectAll: only CFAv1 supported");
    _;
  }

  // endregion Super App Calbacks

  // ============= =============  Gelato ============= ============= //
  // #region Gelato Tasks

  modifier onlyOps() {
    require(msg.sender == ops, "OpsReady: onlyOps");
    _;
  }

  function cancelTask(bytes32 _taskId) public {
    IOps(ops).cancelTask(_taskId);
  }

  function withdraw() external returns (bool) {
    (bool result, ) = payable(msg.sender).call{value: address(this).balance}(
      ""
    );
    return result;
  }

  receive() external payable {}

  function _transfer(uint256 _amount, address _paymentToken) internal {
    (bool success, ) = gelato.call{value: _amount}("");
    require(success, "_transfer: ETH transfer failed");
  }

  // #endregion Gelato functions

  // // ============= =============  EPNS  ============= ============= //
  // // #region  EPNS

  // function sendNotif() public {
  //     IPUSHCommInterface(epnsComm).sendNotification(
  //         epnsChannel, // from channel - recommended to set channel via dApp and put it's value -> then once contract is deployed, go back and add the contract address as delegate for your channel
  //         address(this), // to recipient, put address(this) in case you want Broadcast or Subset. For Targetted put the address to which you want to send
  //         bytes(
  //             string(
  //                 // We are passing identity here: https://docs.epns.io/developers/developer-guides/sending-notifications/advanced/notification-payload-types/identity/payload-identity-implementations
  //                 abi.encodePacked(
  //                     "0", // this is notification identity: https://docs.epns.io/developers/developer-guides/sending-notifications/advanced/notification-payload-types/identity/payload-identity-implementations
  //                     "+", // segregator
  //                     "1", // this is payload type: https://docs.epns.io/developers/developer-guides/sending-notifications/advanced/notification-payload-types/payload (1, 3 or 4) = (Broadcast, targetted or subset)
  //                     "+", // segregator
  //                     "Title", // this is notificaiton title
  //                     "+", // segregator
  //                     "Body" // notification body
  //                 )
  //             )
  //         )
  //     );
  // }

  // // endregion EPNS

  // ============= =============  PARAMETERS ONLY OWNER  ============= ============= //
  // #region ONLY OWNER

  modifier onlyOwner() {
    require(msg.sender == owner, "nly Owner");
    _;
  }

  // function setCreditFee(uint256 _CREDIT_FEE) external onlyOwner {
  //     require(
  //         _CREDIT_FEE > 0 && _CREDIT_FEE < 100,
  //         "CREDIT_FEE_MUS_BE_BETWEEN_0_100"
  //     );
  //     CREDIT_FEE = _CREDIT_FEE;
  // }

  // function setMaxAllowance(uint256 _MAX_ALLOWANCE) external onlyOwner {
  //     require(
  //         _MAX_ALLOWANCE > 0 && _MAX_ALLOWANCE < 100,
  //         "MAX_ALLOWANCE_MUS_BE_BETWEEN_0_100"atoken
  //     );
  //     MAX_ALLOWANCE = _MAX_ALLOWANCE;
  // }

  // function setVotingPeriod(uint256 _CREDIT_PHASES_INTERVAL)
  //     external
  //     onlyOwner
  // {
  //     require(
  //         _CREDIT_PHASES_INTERVAL > 600,
  //         "CREDIT_PHASES_INTERVALE_GREATER_THAN_10_MINUTS"
  //     );
  //     CREDIT_PHASES_INTERVAL = _CREDIT_PHASES_INTERVAL;
  // }

  // #endregion
}
