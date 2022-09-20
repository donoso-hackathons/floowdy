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
    this.set("totalYield", Value.fromBigInt(BigInt.zero()));
    this.set("totalDelegated", Value.fromBigInt(BigInt.zero()));
    this.set("depositIndex", Value.fromBigInt(BigInt.zero()));
    this.set("flowIndex", Value.fromBigInt(BigInt.zero()));
    this.set("totalMembers", Value.fromBigInt(BigInt.zero()));
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

  get totalYield(): BigInt {
    let value = this.get("totalYield");
    return value!.toBigInt();
  }

  set totalYield(value: BigInt) {
    this.set("totalYield", Value.fromBigInt(value));
  }

  get totalDelegated(): BigInt {
    let value = this.get("totalDelegated");
    return value!.toBigInt();
  }

  set totalDelegated(value: BigInt) {
    this.set("totalDelegated", Value.fromBigInt(value));
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

  get totalMembers(): BigInt {
    let value = this.get("totalMembers");
    return value!.toBigInt();
  }

  set totalMembers(value: BigInt) {
    this.set("totalMembers", Value.fromBigInt(value));
  }
}

export class Credit extends Entity {
  constructor(id: string) {
    super();
    this.set("id", Value.fromString(id));

    this.set("requester", Value.fromString(""));
    this.set("initTimestamp", Value.fromBigInt(BigInt.zero()));
    this.set("denyPeriodTimestamp", Value.fromBigInt(BigInt.zero()));
    this.set("status", Value.fromBigInt(BigInt.zero()));
    this.set("amount", Value.fromBigInt(BigInt.zero()));
    this.set("rate", Value.fromBigInt(BigInt.zero()));
    this.set("delegatorsNr", Value.fromBigInt(BigInt.zero()));
    this.set("delegatorsAmount", Value.fromBigInt(BigInt.zero()));
    this.set("gelatoTaskId", Value.fromString(""));
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

  get initTimestamp(): BigInt {
    let value = this.get("initTimestamp");
    return value!.toBigInt();
  }

  set initTimestamp(value: BigInt) {
    this.set("initTimestamp", Value.fromBigInt(value));
  }

  get denyPeriodTimestamp(): BigInt {
    let value = this.get("denyPeriodTimestamp");
    return value!.toBigInt();
  }

  set denyPeriodTimestamp(value: BigInt) {
    this.set("denyPeriodTimestamp", Value.fromBigInt(value));
  }

  get status(): BigInt {
    let value = this.get("status");
    return value!.toBigInt();
  }

  set status(value: BigInt) {
    this.set("status", Value.fromBigInt(value));
  }

  get amount(): BigInt {
    let value = this.get("amount");
    return value!.toBigInt();
  }

  set amount(value: BigInt) {
    this.set("amount", Value.fromBigInt(value));
  }

  get rate(): BigInt {
    let value = this.get("rate");
    return value!.toBigInt();
  }

  set rate(value: BigInt) {
    this.set("rate", Value.fromBigInt(value));
  }

  get delegatorsNr(): BigInt {
    let value = this.get("delegatorsNr");
    return value!.toBigInt();
  }

  set delegatorsNr(value: BigInt) {
    this.set("delegatorsNr", Value.fromBigInt(value));
  }

  get delegatorsAmount(): BigInt {
    let value = this.get("delegatorsAmount");
    return value!.toBigInt();
  }

  set delegatorsAmount(value: BigInt) {
    this.set("delegatorsAmount", Value.fromBigInt(value));
  }

  get gelatoTaskId(): string {
    let value = this.get("gelatoTaskId");
    return value!.toString();
  }

  set gelatoTaskId(value: string) {
    this.set("gelatoTaskId", Value.fromString(value));
  }

  get delegators(): Array<string> {
    let value = this.get("delegators");
    return value!.toStringArray();
  }

  set delegators(value: Array<string>) {
    this.set("delegators", Value.fromStringArray(value));
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
