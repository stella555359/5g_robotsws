*** Settings ***
Documentation
...                 author:  Sun Shuangfeng

Resource    ./CB013365_Resource_SSF.robot
Variables   ./Variables.py

Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF    CA_RAN_PZ_HAZ_1     CLOUD_5G_I_LOO_AP_LOOO

*** Test Cases ***
Load_Configuration
    Setup_for_TMOUS  config_tag=tmous_SSF

CB013365_SR_TC68
# TC68_CB013365_SR_A_PMO_ALT1_PMQAP profile configuration with the unsupported 5QIs
    [Documentation]
    ...    author: Sun Shuangfeng
    [Tags]    QC_289524
    Setup_for_TMOUS  config_tag=tmous_SSF
    start_log_collection
#    CB013365_Change_UE_Location  ue_id=1  enb_id=2  cell_id=1
#    detach_ue_with_power_off  ue_id=1
    Start Counter For CB013365_TC68
    send_ics_registration  flag=on
    ue_modify_default_qosflow  ue_id=1  qosflow=42  #5QI-78
    smf_parameter_config_multi_qosflow  qosflow=45,38,10,12,43,16  #non-GBR 81/68/73/75/79/90
    attach_ue_and_activate_pdu  ue_id=1
    sleep  2
    start_ue_dl_data_traffic  ue_id=1  trf_id=1  dl_rate=150
    start_ue_ul_data_traffic  ue_id=1  trf_id=1  ul_rate=10
    sleep  5
    send_ics_registration  flag=off
    smf_parameter_config_reset
    ue_modify_default_qosflow  ue_id=1  qosflow=35  #5QI-9
    detach_ue_with_power_off  ue_id=1
    Wait_for_Next_5min_Period
    Wait_for_Next_5min_Period
    Collect And Check Counter

*** Keywords ***
CB013365_Send_EventA3_For_Handover_Xn
    [Arguments]  ${ue_id}  ${meas_id}  ${phycell_id}
    log to console  \nSend Event A3 Report for Handover for UE-${ue_id}
    ute_wtssim.Execute Egate Command
    ...  cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=30 phycell_id=${phycell_id} nrsrp_nr=60
    ...  pass_regexp=XN Handover Successfully completed
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

Start Counter For CB013365_TC68
    ${rule1}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...         Counter: M55125C08501;
    ...         Counter rule: max(M55125C08501)==7;
    ${rule2}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...         Counter: M55125C08502;
    ...         Counter rule:max(M55125C08502)==7;
    ${rule3}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-3;
    ...         Counter: M55163C00001,M55163C00002;
    ...         Counter rule: max(M55163C00001)==1 and max(M55163C00002)==1;
    ${rule4}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-5;
    ...         Counter: M55163C00001,M55163C00002;
    ...         Counter rule: max(M55163C00001)==2 and max(M55163C00002)==2;
    ${rule5}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-7;
    ...         Counter: M55163C00001,M55163C00002;
    ...         Counter rule: max(M55163C00001)==2 and max(M55163C00002)==2;
    ${rule6}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-8;
    ...         Counter: M55163C00001,M55163C00002;
    ...         Counter rule: max(M55163C00001)==1 and max(M55163C00002)==1;
    ${rule7}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-9;
    ...         Counter: M55163C00001,M55163C00002;
    ...         Counter rule: max(M55163C00001)==1 and max(M55163C00002)==1;
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}    ${rule4}    ${rule5}    ${rule6}    ${rule7}
    Log To Console    \nThe rule list is: ${rule_list}
    Counter Operation    operation=start_collect_counter    product_type=gnb    bts_index=0
    ...                                                     counter_rule=${rule_list}

Collect And Check Counter
    ${result}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb
    ...                               bts_index=0    cudu_index=0
    Log To Console    \nCounter Rule Collect and Check Result is: ${result}
