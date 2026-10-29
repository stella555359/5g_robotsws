*** Settings ***
Resource  DevHZ5_startup_aic.robot

*** Variables ***
${UE1}  1
${UE2}  2
${UE3}  3
${UE4}  4
${UE5}  5

*** Keywords ***
#Ap Release Dedicate Bearer
#  [Arguments]  ${qci}=1  ${ue_id}=${UE1}
#  [Documentation]  in our test env, the qci is configured same as bearer_id
#  ${cmd_out}  Execute Egate Command  bearer_del ue=${ue_id} id=${qci}
#  ...  deleted in result of PGW-initiated Bearer Deletion procedure
#  [Return]  ${cmd_out}
#
#Ap Setup Dedicate Bearer
#  [Arguments]  ${qci}=1  ${ue_id}=${UE1}  ${filter_id}=1  ${precedence_id}=0
#  [Documentation]  in our test env, the qci is configured same as bearer_id
#  ...  qci 1~4: GBR bearer
#  ...  qci 5~9: non-GBR bearer
#  ${cmd_out}  Execute Egate Command
#  ...  bearer_add ue=${ue_id} id=${qci} filter=${filter_id} precedence=${precedence_id}
#  ...  PGW-initiated Bearer Creation
#  [Return]  ${cmd_out}
#
#Ap UE Enter Into Idle Mode
#  [Arguments]  ${ue_id}=${UE1}  ${wait_string}=IS IDLE
#  Execute Egate Command  sim_trace protocol=ng on amf=1
#  Execute Egate Command  ue_im_entry by=ue id=${ue_id}  ${wait_string}  timeout=30
#
#Ap UE Enter Into RRC Connected Mode
#  [Arguments]  ${ue_id}=${UE1}
#  Execute Egate Command  ue_mba_mdt_disp id=${ue_id}
#  Execute Egate Command  ue_im_exit by=ue id=${ue_id}  UE IS ACTIVE

Ap UE Reestablish
  [Arguments]  ${enb}=1  ${cell}=1  ${ue}=${UE1}  ${cause}=otherFailure
  [Documentation]  EGATE> help ue_rrc_reestablish
  ...
  ...  COMMAND:
  ...
  ...  ue_rrc_reestablish
  ...
  ...  DESCRIPTION:
  ...
  ...  Initiates UE RRC reestablishment procedure.
  ...
  ...  ARGUMENTS:
  ...
  ...  <id=1..25000+>   - local identifier of UE
  ...
  ...  [enb=1..147]  - eNB index for reestablishment (current if omitted)
  ...
  ...  [cell=1..257]   - cell index for reestablishment (current if omitted)
  ...
  ...  [cause=one of the following:]  - reestablishment cause (otherFailure if omitted)
  ...
  ...  reconfigurationFailure - Set reestablishment cause to reconfigurationFailure(0x0)
  ...
  ...  handoverFailure  - Set reestablishment cause to handoverFailure(0x1)
  ...
  ...  otherFailure - Set reestablishment cause to otherFailure(0x2)
  Execute Egate Command  ue_rrc_reestablish id=${ue} enb=${enb} cell=${cell} cause=${cause}
  ...  RRC Reestablishment sucessfully completed

#Ap intra Cell HO
#  [Arguments]  ${ue_id}=${UE1}
#  Execute Egate Command  ue_reauth id=${ue_id}  REAUTHENTICATION

Disable NG Link${number}
  ${delta_param}  Create List  SERVEDAMF-${number}:administrativeState=Locked  NRBTS:actNgcFlexSaMode=true
  Delta Commission Parameters Cu  ${delta_param}
  Object Should Exist In Cu  SERVEDAMF-${number}:ngLinkStatus=Inactive

Enable NG Link${number}
  Delta Commission Parameters Cu  SERVEDAMF-${number}:administrativeState=Unlocked
  Object Should Exist In Cu  SERVEDAMF-${number}:ngLinkStatus=Active

# Block Cell/Unblock Cell operation in vDU KW need use by case owner due to cell id in different vDU.
Lock Cell${number}
  [Documentation]  This operation action in vCU
  Delta Commission Parameters Cu  NRCELL-${number}:administrativeState=Locked
  Object Should Exist In Cu  NRCELL-${number}:administrativeState=Locked

Unlock Cell${number}
  [Documentation]  This operation action in vCU
  Delta Commission Parameters Cu  NRCELL-${number}:administrativeState=Unlocked
  Object Should Exist In Cu  NRCELL-${number}:administrativeState=Unlocked


