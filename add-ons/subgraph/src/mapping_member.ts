// #region =========== MEMBER =================

import { MemberDelegateCredit, MemberDeposit, MemberWithdraw } from "../generated/Floowdy/Floowdy";
import { Member } from "../generated/schema";

export function handleMemberDeposit(event:MemberDeposit ):void {
    _updateMember(event)
  }
  
  export function handleMemberStream(event:MemberDeposit ):void {
    _updateMember(event)
  }
  
  export function handleMemberWithdraw(event:MemberWithdraw ):void {
    let id = event.params.member.toHexString();
    let member = _getMember(id)
    member.deposit = member.deposit.minus(event.params.amount);
    member.save();
  }


  export function handleMemberDelegateCredit(event:MemberDelegateCredit ):void {
    let id = event.params.member.toHexString();
    let member = _getMember(id)
    member.amountLocked = member.amountLocked.plus(event.params.amountLocked);
    member.save();
  }

  
  function _updateMember(event: MemberDeposit):void {
    let id = event.params.member.member.toHexString();
   
    let member = _getMember(id)
    member.memberId =   event.params.member.id.toString();
    member.deposit = event.params.member.deposit;
    member.timestamp = event.params.member.timestamp;
    member.flow = event.params.member.flow;
    member.flowGelatoId =  event.params.member.flowGelatoId.toHexString();
    member.flowDuration =  event.params.member.flowDuration;
    member.initTimestamp =  event.params.member.initTimestamp;
    member.yieldAccrued =  event.params.member.yieldAccrued;
    member.amountLocked = event.params.member.amountLocked;
    member.amountLoss = event.params.member.amountLoss;
    member.currentYield = event.params.member.currentYield;
    member.memberSpan = event.params.member.memberSpan;
    
    member.save()
  }
  
  
 export function _getMember( id:string): Member {
  
      let member = Member.load(id);
      if (member === null) {
        member = new Member(id);
        member.member =id;
        member.save();
      }
      return member;
    }
  
    
  // #endregion =========== MEMBER =================
  