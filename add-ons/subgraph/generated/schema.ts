// THIS IS AN AUTOGENERATED FILE. DO NOT EDIT THIS FILE DIRECTLY.

import {
  TypedMap,
  Entity,
  Value,
  ValueKind,
  store,
  Address,
  Bytes,
  BigInt,
  BigDecimal
} from "@graphprotocol/graph-ts";

export class Member extends Entity {
  constructor(id: string) {
    super();
    this.set("id", Value.fromString(id));

    this.set("memberId", Value.fromString(""));
    this.set("member", Value.fromString(""));
    this.set("timestamp", Value.fromBigInt(BigInt.zero()));
    this.set("initTimestamp", Value.fromBigInt(BigInt.zero()));
    this.set("deposit", Value.fromBigInt(BigInt.zero()));
    this.set("flow", Value.fromBigInt(BigInt.zero()));
    this.set("flowGelatoId", Value.fromString(""));
    this.set("flowDuration", Value.fromBigInt(BigInt.zero()));
    this.set("yieldAccrued", Value.fromBigInt(BigInt.zero()));
    this.set("amountLocked", Value.fromBigInt(BigInt.zero()));
    this.set("amountLoss", Value.fromBigInt(BigInt.zero()));
    this.set("currentYield", Value.fromBigInt(BigInt.zero()));
    this.set("memberSpan", Value.fromBigInt(BigInt.zero()));
  }

  save(): void {
    let id = this.get("id");
    assert(id != null, "Cannot save Member entity without an ID");
    if (id) {
      assert(
        id.kind == ValueKind.STRING,
        "Cannot save Member entity with non-string ID. " +
          'Considering using .toHex() to convert the "id" to a string.'
      );
      store.set("Member", id.toString(), this);
    }
  }

  static load(id: string): Member | null {
    return changetype<Member | null>(store.get("Member", id));
  }

  get id(): string {
    let value = this.get("id");
    return value!.toString();
  }

  set id(value: string) {
    this.set("id", Value.fromString(value));
  }

  get memberId(): string {
    let value = this.get("memberId");
    return value!.toString();
  }

  set memberId(value: string) {
    this.set("memberId", Value.fromString(value));
  }

  get member(): string {
    let value = this.get("member");
    return value!.toString();
  }

  set member(value: string) {
    this.set("member", Value.fromString(value));
  }

  get timestamp(): BigInt {
    let value = this.get("timestamp");
    return value!.toBigInt();
  }

  set timestamp(value: BigInt) {
    this.set("timestamp", Value.fromBigInt(value));
  }

  get initTimestamp(): BigInt {
    let value = this.get("initTimestamp");
    return value!.toBigInt();
  }

  set initTimestamp(value: BigInt) {
    this.set("initTimestamp", Value.fromBigInt(value));
  }

  get deposit(): BigInt {
    let value = this.get("deposit");
    return value!.toBigInt();
  }

  set deposit(value: BigInt) {
    this.set("deposit", Value.fromBigInt(value));
  }

  get flow(): BigInt {
    let value = this.get("flow");
    return value!.toBigInt();
  }

  set flow(value: BigInt) {
    this.set("flow", Value.fromBigInt(value));
  }

  get flowGelatoId(): string {
    let value = this.get("flowGelatoId");
    return value!.toString();
  }

  set flowGelatoId(value: string) {
    this.set("flowGelatoId", Value.fromString(value));
  }

  get flowDuration(): BigInt {
    let value = this.get("flowDuration");
    return value!.toBigInt();
  }

  set flowDuration(value: BigInt) {
    this.set("flowDuration", Value.fromBigInt(value));
  }

  get yieldAccrued(): BigInt {
    let value = this.get("yieldAccrued");
    return value!.toBigInt();
  }

  set yieldAccrued(value: BigInt) {
    this.set("yieldAccrued", Value.fromBigInt(value));
  }

  get amountLocked(): BigInt {
    let value = this.get("amountLocked");
    return value!.toBigInt();
  }

  set amountLocked(value: BigInt) {
    this.set("amountLocked", Value.fromBigInt(value));
  }

  get amountLoss(): BigInt {
    let value = this.get("amountLoss");
    return value!.toBigInt();
  }

  set amountLoss(value: BigInt) {
    this.set("amountLoss", Value.fromBigInt(value));
  }

  get currentYield(): BigInt {
    let value = this.get("currentYield");
    return value!.toBigInt();
  }

  set currentYield(value: BigInt) {
    this.set("currentYield", Value.fromBigInt(value));
  }

  get memberSpan(): BigInt {
    let value = this.get("memberSpan");
    return value!.toBigInt();
  }

  set memberSpan(value: BigInt) {
    this.set("memberSpan", Value.fromBigInt(value));
  }

  get creditsRequested(): Array<string> {
    let value = this.get("creditsRequested");
    return value!.toStringArray();
  }

  set creditsRequested(value: Array<string>) {
    this.set("creditsRequested", Value.fromStringArray(value));
  }

  get creditsDelegated(): Array<string> | null {
    let value = this.get("creditsDelegated");
    if (!value || value.kind == ValueKind.NULL) {
      return null;
    } else {
      return value.toStringArray();
    }
  }

  set creditsDelegated(value: Array<string> | null) {
    if (!value) {
      this.unset("creditsDelegated");
    } else {
      this.set("creditsDelegated", Value.fromStringArray(<Array<string>>value));
    }
  }
}

export class Pool extends Entity {
  constructor(id: string) {
    super();
    this.set("id", Value.fromString(id));

    this.set("poolId", Value.fromString(""));
    this.set("timestamp", Value.fromBigInt(BigInt.zero()));
    this.set("totalDeposit", Value.fromBigInt(BigInt.zero()));
    this.set("totalFlow", Value.fromBigInt(BigInt.zero()));
    this.set("totalYieldStake", Value.fromBigInt(BigInt.zero()));
    this.set("depositIndex", Value.fromBigInt(BigInt.zero()));
    this.set("flowIndex", Value.fromBigInt(BigInt.zero()));
    this.set("totalStaked", Value.fromBigInt(BigInt.zero()));
    this.set("totalDelegated", Value.fromBigInt(BigInt.zero()));
    this.set("percentageLocked", Value.fromBigInt(BigInt.zero()));
    this.set("totalYieldCredit", Value.fromBigInt(BigInt.zero()));
    this.set("liquidatedIndex", Value.fromBigInt(BigInt.zero()));
    this.set("totalLiquidated", Value.fromBigInt(BigInt.zero()));
    this.set("nrMembers", Value.fromBigInt(BigInt.zero()));
    this.set("apy", Value.fromBigInt(BigInt.zero()));
    this.set("apySpan", Value.fromBigInt(BigInt.zero()));
  }

  save(): void {
    let id = this.get("id");
    assert(id != null, "Cannot save Pool entity without an ID");
    if (id) {
      assert(
        id.kind == ValueKind.STRING,
        "Cannot save Pool entity with non-string ID. " +
          'Considering using .toHex() to convert the "id" to a string.'
      );
      store.set("Pool", id.toString(), this);
    }
  }

  static load(id: string): Pool | null {
    return changetype<Pool | null>(store.get("Pool", id));
  }

  get id(): string {
    let value = this.get("id");
    return value!.toString();
  }

  set id(value: string) {
    this.set("id", Value.fromString(value));
  }

  get poolId(): string {
    let value = this.get("poolId");
    return value!.toString();
  }

  set poolId(value: string) {
    this.set("poolId", Value.fromString(value));
  }

  get timestamp(): BigInt {
    let value = this.get("timestamp");
    return value!.toBigInt();
  }

  set timestamp(value: BigInt) {
    this.set("timestamp", Value.fromBigInt(value));
  }

  get totalDeposit(): BigInt {
    let value = this.get("totalDeposit");
    return value!.toBigInt();
  }

  set totalDeposit(value: BigInt) {
    this.set("totalDeposit", Value.fromBigInt(value));
  }

  get totalFlow(): BigInt {
    let value = this.get("totalFlow");
    return value!.toBigInt();
  }

  set totalFlow(value: BigInt) {
    this.set("totalFlow", Value.fromBigInt(value));
  }

  get totalYieldStake(): BigInt {
    let value = this.get("totalYieldStake");
    return value!.toBigInt();
  }

  set totalYieldStake(value: BigInt) {
    this.set("totalYieldStake", Value.fromBigInt(value));
  }

  get depositIndex(): BigInt {
    let value = this.get("depositIndex");
    return value!.toBigInt();
  }

  set depositIndex(value: BigInt) {
    this.set("depositIndex", Value.fromBigInt(value));
  }

  get flowIndex(): BigInt {
    let value = this.get("flowIndex");
    return value!.toBigInt();
  }

  set flowIndex(value: BigInt) {
    this.set("flowIndex", Value.fromBigInt(value));
  }

  get totalStaked(): BigInt {
    let value = this.get("totalStaked");
    return value!.toBigInt();
  }

  set totalStaked(value: BigInt) {
    this.set("totalStaked", Value.fromBigInt(value));
  }

  get totalDelegated(): BigInt {
    let value = this.get("totalDelegated");
    return value!.toBigInt();
  }

  set totalDelegated(value: BigInt) {
    this.set("totalDelegated", Value.fromBigInt(value));
  }

  get percentageLocked(): BigInt {
    let value = this.get("percentageLocked");
    return value!.toBigInt();
  }

  set percentageLocked(value: BigInt) {
    this.set("percentageLocked", Value.fromBigInt(value));
  }

  get totalYieldCredit(): BigInt {
    let value = this.get("totalYieldCredit");
    return value!.toBigInt();
  }

  set totalYieldCredit(value: BigInt) {
    this.set("totalYieldCredit", Value.fromBigInt(value));
  }

  get liquidatedIndex(): BigInt {
    let value = this.get("liquidatedIndex");
    return value!.toBigInt();
  }

  set liquidatedIndex(value: BigInt) {
    this.set("liquidatedIndex", Value.fromBigInt(value));
  }

  get totalLiquidated(): BigInt {
    let value = this.get("totalLiquidated");
    return value!.toBigInt();
  }

  set totalLiquidated(value: BigInt) {
    this.set("totalLiquidated", Value.fromBigInt(value));
  }

  get nrMembers(): BigInt {
    let value = this.get("nrMembers");
    return value!.toBigInt();
  }

  set nrMembers(value: BigInt) {
    this.set("nrMembers", Value.fromBigInt(value));
  }

  get apy(): BigInt {
    let value = this.get("apy");
    return value!.toBigInt();
  }

  set apy(value: BigInt) {
    this.set("apy", Value.fromBigInt(value));
  }

  get apySpan(): BigInt {
    let value = this.get("apySpan");
    return value!.toBigInt();
  }

  set apySpan(value: BigInt) {
    this.set("apySpan", Value.fromBigInt(value));
  }
}

export class Credit extends Entity {
  constructor(id: string) {
    super();
    this.set("id", Value.fromString(id));

    this.set("requester", Value.fromString(""));
    this.set("initTimestamp", Value.fromBigInt(BigInt.zero()));
    this.set("finishPhaseTimestamp", Value.fromBigInt(BigInt.zero()));
    this.set("gelatoTaskId", Value.fromString(""));
    this.set("status", Value.fromBigInt(BigInt.zero()));
    this.set("nrInstallments", Value.fromBigInt(BigInt.zero()));
    this.set("interval", Value.fromBigInt(BigInt.zero()));
    this.set("installment", Value.fromBigInt(BigInt.zero()));
    this.set("currentInstallment", Value.fromBigInt(BigInt.zero()));
    this.set("installmentPrincipal", Value.fromBigInt(BigInt.zero()));
    this.set("installmentRateAave", Value.fromBigInt(BigInt.zero()));
    this.set("installmentRatePool", Value.fromBigInt(BigInt.zero()));
    this.set("amount", Value.fromBigInt(BigInt.zero()));
    this.set("rateAave", Value.fromBigInt(BigInt.zero()));
    this.set("ratePool", Value.fromBigInt(BigInt.zero()));
    this.set("totalYield", Value.fromBigInt(BigInt.zero()));
    this.set("GelatoRepaymentTaskId", Value.fromString(""));
    this.set("delegatorsNr", Value.fromBigInt(BigInt.zero()));
    this.set("delegatorsRequired", Value.fromBigInt(BigInt.zero()));
    this.set("delegatorsAmount", Value.fromBigInt(BigInt.zero()));
    this.set("delegatorsGlobalFee", Value.fromBigInt(BigInt.zero()));
  }

  save(): void {
    let id = this.get("id");
    assert(id != null, "Cannot save Credit entity without an ID");
    if (id) {
      assert(
        id.kind == ValueKind.STRING,
        "Cannot save Credit entity with non-string ID. " +
          'Considering using .toHex() to convert the "id" to a string.'
      );
      store.set("Credit", id.toString(), this);
    }
  }

  static load(id: string): Credit | null {
    return changetype<Credit | null>(store.get("Credit", id));
  }

  get id(): string {
    let value = this.get("id");
    return value!.toString();
  }

  set id(value: string) {
    this.set("id", Value.fromString(value));
  }

  get requester(): string {
    let value = this.get("requester");
    return value!.toString();
  }

  set requester(value: string) {
    this.set("requester", Value.fromString(value));
  }

  get handle(): string | null {
    let value = this.get("handle");
    if (!value || value.kind == ValueKind.NULL) {
      return null;
    } else {
      return value.toString();
    }
  }

  set handle(value: string | null) {
    if (!value) {
      this.unset("handle");
    } else {
      this.set("handle", Value.fromString(<string>value));
    }
  }

  get bio(): string | null {
    let value = this.get("bio");
    if (!value || value.kind == ValueKind.NULL) {
      return null;
    } else {
      return value.toString();
    }
  }

  set bio(value: string | null) {
    if (!value) {
      this.unset("bio");
    } else {
      this.set("bio", Value.fromString(<string>value));
    }
  }

  get initTimestamp(): BigInt {
    let value = this.get("initTimestamp");
    return value!.toBigInt();
  }

  set initTimestamp(value: BigInt) {
    this.set("initTimestamp", Value.fromBigInt(value));
  }

  get finishPhaseTimestamp(): BigInt {
    let value = this.get("finishPhaseTimestamp");
    return value!.toBigInt();
  }

  set finishPhaseTimestamp(value: BigInt) {
    this.set("finishPhaseTimestamp", Value.fromBigInt(value));
  }

  get gelatoTaskId(): string {
    let value = this.get("gelatoTaskId");
    return value!.toString();
  }

  set gelatoTaskId(value: string) {
    this.set("gelatoTaskId", Value.fromString(value));
  }

  get status(): BigInt {
    let value = this.get("status");
    return value!.toBigInt();
  }

  set status(value: BigInt) {
    this.set("status", Value.fromBigInt(value));
  }

  get nrInstallments(): BigInt {
    let value = this.get("nrInstallments");
    return value!.toBigInt();
  }

  set nrInstallments(value: BigInt) {
    this.set("nrInstallments", Value.fromBigInt(value));
  }

  get interval(): BigInt {
    let value = this.get("interval");
    return value!.toBigInt();
  }

  set interval(value: BigInt) {
    this.set("interval", Value.fromBigInt(value));
  }

  get installments(): Array<string> {
    let value = this.get("installments");
    return value!.toStringArray();
  }

  set installments(value: Array<string>) {
    this.set("installments", Value.fromStringArray(value));
  }

  get installment(): BigInt {
    let value = this.get("installment");
    return value!.toBigInt();
  }

  set installment(value: BigInt) {
    this.set("installment", Value.fromBigInt(value));
  }

  get currentInstallment(): BigInt {
    let value = this.get("currentInstallment");
    return value!.toBigInt();
  }

  set currentInstallment(value: BigInt) {
    this.set("currentInstallment", Value.fromBigInt(value));
  }

  get installmentPrincipal(): BigInt {
    let value = this.get("installmentPrincipal");
    return value!.toBigInt();
  }

  set installmentPrincipal(value: BigInt) {
    this.set("installmentPrincipal", Value.fromBigInt(value));
  }

  get installmentRateAave(): BigInt {
    let value = this.get("installmentRateAave");
    return value!.toBigInt();
  }

  set installmentRateAave(value: BigInt) {
    this.set("installmentRateAave", Value.fromBigInt(value));
  }

  get installmentRatePool(): BigInt {
    let value = this.get("installmentRatePool");
    return value!.toBigInt();
  }

  set installmentRatePool(value: BigInt) {
    this.set("installmentRatePool", Value.fromBigInt(value));
  }

  get amount(): BigInt {
    let value = this.get("amount");
    return value!.toBigInt();
  }

  set amount(value: BigInt) {
    this.set("amount", Value.fromBigInt(value));
  }

  get rateAave(): BigInt {
    let value = this.get("rateAave");
    return value!.toBigInt();
  }

  set rateAave(value: BigInt) {
    this.set("rateAave", Value.fromBigInt(value));
  }

  get ratePool(): BigInt {
    let value = this.get("ratePool");
    return value!.toBigInt();
  }

  set ratePool(value: BigInt) {
    this.set("ratePool", Value.fromBigInt(value));
  }

  get totalYield(): BigInt {
    let value = this.get("totalYield");
    return value!.toBigInt();
  }

  set totalYield(value: BigInt) {
    this.set("totalYield", Value.fromBigInt(value));
  }

  get GelatoRepaymentTaskId(): string {
    let value = this.get("GelatoRepaymentTaskId");
    return value!.toString();
  }

  set GelatoRepaymentTaskId(value: string) {
    this.set("GelatoRepaymentTaskId", Value.fromString(value));
  }

  get delegatorsNr(): BigInt {
    let value = this.get("delegatorsNr");
    return value!.toBigInt();
  }

  set delegatorsNr(value: BigInt) {
    this.set("delegatorsNr", Value.fromBigInt(value));
  }

  get delegatorsRequired(): BigInt {
    let value = this.get("delegatorsRequired");
    return value!.toBigInt();
  }

  set delegatorsRequired(value: BigInt) {
    this.set("delegatorsRequired", Value.fromBigInt(value));
  }

  get delegators(): Array<string> {
    let value = this.get("delegators");
    return value!.toStringArray();
  }

  set delegators(value: Array<string>) {
    this.set("delegators", Value.fromStringArray(value));
  }

  get delegatorsAmount(): BigInt {
    let value = this.get("delegatorsAmount");
    return value!.toBigInt();
  }

  set delegatorsAmount(value: BigInt) {
    this.set("delegatorsAmount", Value.fromBigInt(value));
  }

  get delegatorsGlobalFee(): BigInt {
    let value = this.get("delegatorsGlobalFee");
    return value!.toBigInt();
  }

  set delegatorsGlobalFee(value: BigInt) {
    this.set("delegatorsGlobalFee", Value.fromBigInt(value));
  }
}

export class MemberCredit extends Entity {
  constructor(id: string) {
    super();
    this.set("id", Value.fromString(id));

    this.set("member", Value.fromString(""));
    this.set("credit", Value.fromString(""));
  }

  save(): void {
    let id = this.get("id");
    assert(id != null, "Cannot save MemberCredit entity without an ID");
    if (id) {
      assert(
        id.kind == ValueKind.STRING,
        "Cannot save MemberCredit entity with non-string ID. " +
          'Considering using .toHex() to convert the "id" to a string.'
      );
      store.set("MemberCredit", id.toString(), this);
    }
  }

  static load(id: string): MemberCredit | null {
    return changetype<MemberCredit | null>(store.get("MemberCredit", id));
  }

  get id(): string {
    let value = this.get("id");
    return value!.toString();
  }

  set id(value: string) {
    this.set("id", Value.fromString(value));
  }

  get member(): string {
    let value = this.get("member");
    return value!.toString();
  }

  set member(value: string) {
    this.set("member", Value.fromString(value));
  }

  get credit(): string {
    let value = this.get("credit");
    return value!.toString();
  }

  set credit(value: string) {
    this.set("credit", Value.fromString(value));
  }
}

export class Installment extends Entity {
  constructor(id: string) {
    super();
    this.set("id", Value.fromString(id));

    this.set("nr", Value.fromBigInt(BigInt.zero()));
    this.set("credit", Value.fromString(""));
    this.set("timestamp", Value.fromBigInt(BigInt.zero()));
  }

  save(): void {
    let id = this.get("id");
    assert(id != null, "Cannot save Installment entity without an ID");
    if (id) {
      assert(
        id.kind == ValueKind.STRING,
        "Cannot save Installment entity with non-string ID. " +
          'Considering using .toHex() to convert the "id" to a string.'
      );
      store.set("Installment", id.toString(), this);
    }
  }

  static load(id: string): Installment | null {
    return changetype<Installment | null>(store.get("Installment", id));
  }

  get id(): string {
    let value = this.get("id");
    return value!.toString();
  }

  set id(value: string) {
    this.set("id", Value.fromString(value));
  }

  get nr(): BigInt {
    let value = this.get("nr");
    return value!.toBigInt();
  }

  set nr(value: BigInt) {
    this.set("nr", Value.fromBigInt(value));
  }

  get credit(): string {
    let value = this.get("credit");
    return value!.toString();
  }

  set credit(value: string) {
    this.set("credit", Value.fromString(value));
  }

  get timestamp(): BigInt {
    let value = this.get("timestamp");
    return value!.toBigInt();
  }

  set timestamp(value: BigInt) {
    this.set("timestamp", Value.fromBigInt(value));
  }
}

export class ChartMonth extends Entity {
  constructor(id: string) {
    super();
    this.set("id", Value.fromString(id));

    this.set("month", Value.fromString(""));
    this.set("year", Value.fromString(""));
    this.set("timestamp", Value.fromBigInt(BigInt.zero()));
    this.set("balance", Value.fromBigInt(BigInt.zero()));
    this.set("staked", Value.fromBigInt(BigInt.zero()));
  }

  save(): void {
    let id = this.get("id");
    assert(id != null, "Cannot save ChartMonth entity without an ID");
    if (id) {
      assert(
        id.kind == ValueKind.STRING,
        "Cannot save ChartMonth entity with non-string ID. " +
          'Considering using .toHex() to convert the "id" to a string.'
      );
      store.set("ChartMonth", id.toString(), this);
    }
  }

  static load(id: string): ChartMonth | null {
    return changetype<ChartMonth | null>(store.get("ChartMonth", id));
  }

  get id(): string {
    let value = this.get("id");
    return value!.toString();
  }

  set id(value: string) {
    this.set("id", Value.fromString(value));
  }

  get month(): string {
    let value = this.get("month");
    return value!.toString();
  }

  set month(value: string) {
    this.set("month", Value.fromString(value));
  }

  get year(): string {
    let value = this.get("year");
    return value!.toString();
  }

  set year(value: string) {
    this.set("year", Value.fromString(value));
  }

  get timestamp(): BigInt {
    let value = this.get("timestamp");
    return value!.toBigInt();
  }

  set timestamp(value: BigInt) {
    this.set("timestamp", Value.fromBigInt(value));
  }

  get balance(): BigInt {
    let value = this.get("balance");
    return value!.toBigInt();
  }

  set balance(value: BigInt) {
    this.set("balance", Value.fromBigInt(value));
  }

  get staked(): BigInt {
    let value = this.get("staked");
    return value!.toBigInt();
  }

  set staked(value: BigInt) {
    this.set("staked", Value.fromBigInt(value));
  }
}
