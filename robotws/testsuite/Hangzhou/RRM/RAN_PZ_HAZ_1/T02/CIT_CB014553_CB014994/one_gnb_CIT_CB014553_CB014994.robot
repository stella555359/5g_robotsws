*** Settings ***
Documentation
...                 author:  Guo Qianqian

Resource    ./Resource_CB014994.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/Module/Module.robot
Resource    ../../T02/Common_Case/common_resource_new.robot
Library     taf.sw.scout    WITH NAME    scout

Force Tags        CIT    QCD_MN_RAN    QCP_RAN_VRF    CA_RAN_PZ_HAZ_1     CLOUD_5G_I_LOO_AP_LOOO

*** Test Cases ***
CIT_CB014553_CB014994
#CB014994_SR_05_A-B1
    [Documentation]
    ...    author: Guo Qianqian
    ...    UE1(support RRC Inactive) mapped to NRUEPROFILE-1 via imeisvtac;
    ...    NRBTS/RRCINACT_UEPROFILE-1 configured with nrUeProfileDN=MRBTS/NRBTS/NRUEPROFILE-1;
    ...    rrcInactStateAllowed=false.
    ...    NRBTS.maxUeRrcInactTimeS=60min;NRBTS.t380=30min;NRBTS.maxUeRrcInactTime=60min;
    ...    actRrcReleasePreference=true;NRBTS.outOfConnectedPreference=inactive;
    ...    DRB14:drbRrcInactInactivityTimerSA=65s;drbInactivityTimerSA=75s;
    ...    NRBTS.srbinactivitytimerSA=20s;
    [Tags]    QC_    CASE5    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65_2S
    #Setup_eGate_Env
    Load_Configuration
    detach_ue_with_power_off  ue_id=1
    delete_rlq_profile
    Log to Console  \n Change_UE_Location to cell1
    Execute Egate Command    cmd=ue_change_location id=1 enb=2 cell=1
    log to console    \n Start log: emil+syslog+snapshot
    start_log_collection    cell_id=1

#######################  RRC Connected State to Inactivate State  #######################################
    log to console  \n Wait for next 5min counter measure period
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     cudu_index=0
    ...                                                     counter_rule=${CURDIR}/counter_rule_case5.txt
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
    log to console  \n attach UE1 with PDU
    Execute Egate Command    cmd=ue_register id=1
    ...    pass_regexp=Received REGISTRATION COMPLETE from UE
    sleep  2
    Execute Egate Command    cmd=set_pdu_param ue=1 pdu=1 trf_type=internal
    ...    pass_regexp=EGATE>
    Execute Egate Command    cmd=ue_pdu_session_setup pdu=1 ue=1 nwslice=1 gw=1
    ...    pass_regexp=rrcReconfigurationComplete
    sleep  100
    log to console    \n Check UE1 state
    CB014994_Check_UE_State  ue_id=1  ue_state=IDLE
    Execute Egate Command    cmd=exit
    log to console  \nWait for next 5min counter measure period
    ${value}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0    cudu_index=0
    log to console  \n${value}
    detach_ue_with_power_off  ue_id=1
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

