*** Settings ***
Documentation
...    Author:yin zhang
...    contact:yin.zhang@nokia-sbell.com
...    squad group:VRF3_7
Resource    ../common_robot/DevHZ5_common_resource.robot

*** Variables ***
${UE1}  1
${UE2}  2
${UE3}  3
${UE4}  4
${UE5}  5

*** Keywords ***

Ap UE Reestablish
  [Arguments]  ${enb}=1  ${cell}=1  ${ue}=1  ${cause}=otherFailure
  [Documentation]  EGATE> help ue_rrc_reestablish
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

SA UE attach with single PDU
    [Arguments]    ${ue_id}=1    ${target_cells}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${target_cells}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal    sleep_time=5
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    pass_regexp=Initial Context Setup Successful
