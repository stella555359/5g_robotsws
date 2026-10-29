*** Settings ***
Documentation
...                 author:  Liu AnAn

Resource    ./Resource_CB014994.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/Module/Module.robot
Resource    ../../T02/Common_Case/common_resource_new.robot
Library     taf.sw.scout    WITH NAME    scout

Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF    CA_RAN_PZ_HAZ_1     CLOUD_5G_I_LOO_AP_LOOO

*** Test Cases ***

CB014994_SR_12_A-B2
#CB014994_SR_12_A-B2_from_RRC_CONNECTED_to_RRC_INACTIVE_based_on_RRCINACT_UEPROFILE_triggered_by_UEAssistanceInformation
    [Documentation]
    ...    author: Guo Qianqian
    ...    UE1(support RRC Inactive) mapped to NRUEPROFILE-1 via imeisvtac; mapped to NRUEPROFILE-2 via imeisvtac-?;
    ...    UE1 and UE2 mapped to NRUEPROFILE-3 via chipsetid.
    ...    UE2(support RRC Inactive) mapped to NRUEPROFILE-4 via imeisv; mapped to NRUEPROFILE-5 via imeisvtac;
    ...    UE1 and UE2 mapped to NRUEPROFILE-6 via imeisvtac-?.
    ...    NRBTS/RRCINACT_UEPROFILE-1 configured with nrUeProfileDN=MRBTS/NRBTS/NRUEPROFILE-1;
    ...    rrcInactStateAllowed=True.
    ...    NRBTS.maxUeRrcInactTimeS=60min;NRBTS.t380=30min;NRBTS.maxUeRrcInactTime=60min;
    ...    actRrcReleasePreference=true;NRBTS.outOfConnectedPreference=inactive;
    ...    DRB14:drbRrcInactInactivityTimerSA=65s;drbInactivityTimerSA=75s;
    ...    NRBTS.srbinactivitytimerSA=600s;
    [Tags]    QC_311893    CRT    CASE12
    #Setup_eGate_Env
    Load_Configuration
    detach_ue_with_power_off  ue_id=1-2
    delete_rlq_profile
    Log to Console  \n Change_UE_Location to cell1
    Execute Egate Command    cmd=ue_change_location id=1-2 enb=2 cell=1
    log to console    \n Start log: emil+syslog+snapshot
    start_log_collection    cell_id=1

#######################  RRC Connected State to Inactivate State  #######################################
    log to console  \n Wait for next 5min counter measure period
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     cudu_index=0
    ...                                                     counter_rule=${CURDIR}/counter_rule_case12.txt
    ...                                                     wait_for_next_counter_generate=${True}
    log to console    \nEnable IMEISV for all UEs
    Execute Egate Command    cmd=amf_dl_nas_transport_param id=1 ue=all include_masked_imeisv=on
    Execute Egate Command    cmd=amf_ue_ics_param id=1 ue=all include_masked_imeisv=on
    Execute Egate Command    cmd=amf_param id=1 send_ics_registration=on
    Log to Console  \n Pre-condition for trigger RRC_INACTIVE
    ${cmd_1}  Set Variable  amf_ue_ics_param id=1 ue=all core_network_assistance_info=on
    ${cmd_2}  Set Variable  ue_identity_index_value=1 ue_specific_drx=64
    ${cmd_3}  Set Variable  periodic_registration_update_timer=5:10hrs plmn_id=310:260 tac_id=200
    ${cmd}    Catenate  ${cmd_1}  ${cmd_2}  ${cmd_3}
    Execute Egate Command    cmd=${cmd}
    ...    pass_regexp=EGATE>
    sleep  2
    ${cmd_4}  Set Variable  amf_ue_path_switch_param id=1 core_network_assistance_info=on
    ${cmd_5}  Set Variable  ue_identity_index_value=1 ue_specific_drx=64
    ${cmd_6}  Set Variable  periodic_registration_update_timer=5:10hrs plmn_id=310:260 tac_id=200
    ${cmd7}    Catenate  ${cmd_4}  ${cmd_5}  ${cmd_6}
    Execute Egate Command    cmd=${cmd7}
    ...    pass_regexp=EGATE>
    sleep  2
    #Execute Egate Command    cmd=amf_ue_ics_param id=1 ue=all core_network_assistance_info=on ue_identity_index_value=1
    #...    ue_specific_drx=64 periodic_registration_update_timer=5:10hrs plmn_id=310:260 tac_id=200
    #Execute Egate Command    cmd=amf_ue_path_switch_param id=1 core_network_assistance_info=on ue_identity_index_value=1
    #...    ue_specific_drx=64 periodic_registration_update_timer=5:10hrs plmn_id=310:260 tac_id=200
    log to console  \n attach UE1 and UE2 with PDU
    Execute Egate Command    cmd=ue_register id=1-2
    ...    pass_regexp=Received REGISTRATION COMPLETE from UE
    sleep  2
    Execute Egate Command    cmd=set_pdu_param ue=1-2 pdu=1 trf_type=internal
    ...    pass_regexp=EGATE>
    Execute Egate Command    cmd=ue_pdu_session_setup pdu=1 ue=1-2 nwslice=1 gw=1
    ...    pass_regexp=rrcReconfigurationComplete
    sleep  20
    log to console    \n Trigger UE to RRC_INACTIVE based on UE assistance information
    Execute Egate Command    cmd=ue_assistance_send_nr ue_id=1 PreferredRRCState=inactive
    ...    pass_regexp=UE1: Is INACTIVE
    sleep  10
    Execute Egate Command    cmd=ue_assistance_send_nr ue_id=2 PreferredRRCState=inactive
    ...    pass_regexp=EGATE>
    sleep  10
    log to console    \n Check UE1 state
    CB014994_Check_UE_State  ue_id=1  ue_state=UE_INACTIVE
    log to console    \n Check UE2 state
    CB014994_Check_UE_State  ue_id=2  ue_state=IDLE
    Execute Egate Command    cmd=exit
    log to console  \nWait for next 5min counter measure period
    ${value}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0    cudu_index=0
    log to console  \n${value}
    detach_ue_with_power_off  ue_id=1-2
    [Teardown]  Teardown_for_CB014994

*** Keywords ***
Load_Configuration
    Setup_for_TMOUS  config_tag=tmous

CB013365_Send_EventA3_For_Handover_Xn
    [Arguments]  ${ue_id}  ${meas_id}  ${phycell_id}
    log to console  \nSend Event A3 Report for Handover for UE-${ue_id}
    ute_wtssim.Execute Egate Command
    ...  cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=30 phycell_id=${phycell_id} nrsrp_nr=60
    ...  pass_regexp=XN Handover Successfully completed
    ...  timeout=5s
    ...  return_output=${False}

CB013365_Send_EventA3_For_Handover_Xn_Fail
    [Arguments]  ${ue_id}  ${meas_id}  ${phycell_id}
    log to console  \nSend Event A3 Report for Handover for UE-${ue_id}
    ute_wtssim.Execute Egate Command
    ...  cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=30 phycell_id=${phycell_id} nrsrp_nr=60
    ...  pass_regexp=not-supported-5QI-value
    ...  timeout=5s
    ...  return_output=${False}

CB013365_Send_EventA3_For_Handover_NG
    [Arguments]  ${ue_id}  ${meas_id}  ${phycell_id}
    log to console  \nSend Event A3 Report for Handover for UE-${ue_id}
    ute_wtssim.Execute Egate Command
    ...  cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=30 phycell_id=${phycell_id} nrsrp_nr=60
    ...  pass_regexp=NG Handover successfully completed
    ...  timeout=5s
    ...  return_output=${False}

CB013365_Send_EventA3_For_Handover_NSA
    [Arguments]  ${ue_id}  ${meas_id}  ${phycell_id}
    log to console  \nSend Event A3 Report for Handover for UE-${ue_id}
    ute_wtssim.Execute Egate Command
    ...  cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=30 phycell_id=${phycell_id} nrsrp_nr=60
    ...  pass_regexp=Handover Successful,  HandoverType = sn_change
    ...  timeout=5s
    ...  return_output=${False}


CB013365_Change_actSupportAll5qiAndQci
    [Arguments]  ${value}
    @{gnb_para_list}          Create List    actSupportAll5qiAndQci
    @{gnb_mo_list}            Create List    MRBTS-1/NRBTS-1
    @{gnb_value_list}         Create List    ${value}
    CB013365_Change_Parameter  ${gnb_para_list}  ${gnb_mo_list}  ${gnb_value_list}

CB013365_Change_actARPBasedAC
    [Arguments]  ${cell_id}  ${value}
    @{gnb_para_list}          Create List    actARPBasedAC
    @{gnb_mo_list}            Create List    MRBTS-1/NRBTS-1/NRCELL-${cell_id}
    @{gnb_value_list}         Create List    ${value}
    CB013365_Change_Parameter  ${gnb_para_list}  ${gnb_mo_list}  ${gnb_value_list}

