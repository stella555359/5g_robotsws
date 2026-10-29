*** Settings ***
Documentation
...                 author:  Liu AnAn

Resource    ./CB013365_Resource.robot

Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF    CA_RAN_PZ_HAZ_1     CLOUD_5G_O_E_AP_LOOO

*** Test Cases ***
Load_Configuration
    Setup_for_RJIO  config_tag=rjio


CB013365_SR_TC01
# TC01_CB013365_SR_A_B1_Successful setup of unconfigured 5QIs with PDU Session Resource Setup (initial) - nGBR
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_

    # TODO check counter + qfi-2/3/4 data traffic
    Setup_eGate_Env
    CB013365_Change_UE_Location  ue_id=1  enb_id=2  cell_id=1
    detach_ue_with_power_off  ue_id=1
    send_ics_registration  flag=on
    ue_modify_default_qosflow  ue_id=1  qosflow=41  #5QI-77
    smf_parameter_config_multi_qosflow  qosflow=42,43,45  #5QI-78/79/81

    attach_ue_and_activate_pdu  ue_id=1
    sleep  2
    start_ue_dl_data_traffic  ue_id=1  trf_id=1  dl_rate=150
    start_ue_ul_data_traffic  ue_id=1  trf_id=1  ul_rate=10
    sleep  5

    send_ics_registration  flag=off
    smf_parameter_config_reset
    ue_modify_default_qosflow  ue_id=1  qosflow=35  #5QI-9
    detach_ue_with_power_off  ue_id=1

CB013365_SR_TC09
# TC09_CB013365_SR_A_B5_Successful Xn based Intra-frequency Inter-gNB handover with unconfigured 5QIs
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_

    # qfi-2/3 data traffic
    CB013365_Delta_Commission    file_name=Enable_Xn_HO.json
    Setup_eGate_Env
    CB013365_Change_gNB_Handover_Type  gnb_id=3  ho_type=xn_based
    detach_ue_with_power_off  ue_id=1
    send_ics_registration  flag=on
    # ue_modify_default_qosflow  ue=1  qos_flow=48  # 5QI-100
    ue_modify_default_qosflow  ue_id=1  qosflow=35  #5QI-9
    smf_parameter_config_multi_qosflow  qosflow=46,47  #5QI-91/92
    CB013365_Change_UE_Location  ue_id=1  enb_id=3  cell_id=1
    ue_history_information_reset
    ue_history_information_add
    ue_add_ue_history_information  ue_id=1

    attach_ue_and_activate_pdu  ue_id=1
    sleep  2
    start_ue_dl_data_traffic  ue_id=1  qfi=1  trf_id=1  dl_rate=150
    start_ue_ul_data_traffic  ue_id=1  qfi=1  trf_id=1  ul_rate=10
    sleep  5

    ${meas_id}  CB013365_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=634080  event_type=A3  report_on_leave=False  rsrp=0
    CB013365_Send_EventA3_For_Handover_Xn  ue_id=1  meas_id=${meas_id}   phycell_id=50
    sleep  5

    ${dl_tput}  get_ue_dl_scell_tput  ue_id=1
    Log to Console  DL Tput:  ${dl_tput}
    ${ul_tput}  get_ue_ul_scell_tput  ue_id=1
    Log to Console  UL Tput:  ${dl_tput}
    Should Be True  ${dl_tput} > 145
    Should Be True  ${ul_tput} > 9.5

    send_ics_registration  flag=off
    smf_parameter_config_reset
    detach_ue_with_power_off  ue_id=1

CB013365_SR_TC18
# TC18_CB013365_SR_A_IWK3_Successful setup of Mission critical Qos flows(5QIs 67, 69, 70) when matching NRDRB_5QI is not configured
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_

    # TODO check counter for all 5QI
    Setup_eGate_Env
    detach_ue_with_power_off  ue_id=1
    send_ics_registration  flag=on
    ue_modify_default_qosflow  ue_id=1  qosflow=35  #5QI-9
    CB013365_Change_UE_Location  ue_id=1  enb_id=2  cell_id=1

    attach_ue_and_activate_pdu  ue_id=1
    sleep  2
    start_ue_dl_data_traffic  ue_id=1  qfi=1  trf_id=1  dl_rate=150
    start_ue_ul_data_traffic  ue_id=1  qfi=1  trf_id=1  ul_rate=10
    sleep  5

    ue_pdu_session_modify_add_qosflow  ue_id=1  qosflow=7,39,40  #5QI-67/69/70
    sleep  2
    start_ue_dl_data_traffic  ue_id=1  qfi=2  trf_id=1  dl_rate=10
    start_ue_ul_data_traffic  ue_id=1  qfi=2  trf_id=1  ul_rate=10
    sleep  2
    start_ue_dl_data_traffic  ue_id=1  qfi=3  trf_id=1  dl_rate=1
    start_ue_ul_data_traffic  ue_id=1  qfi=3  trf_id=1  ul_rate=1
    sleep  2
    start_ue_dl_data_traffic  ue_id=1  qfi=4  trf_id=1  dl_rate=1
    start_ue_ul_data_traffic  ue_id=1  qfi=4  trf_id=1  ul_rate=1
    sleep  2

    ${dl_tput}  get_ue_dl_scell_tput  ue_id=1
    Log to Console  DL Tput:  ${dl_tput}
    ${ul_tput}  get_ue_ul_scell_tput  ue_id=1
    Log to Console  UL Tput:  ${dl_tput}
    Should Be True  ${dl_tput} > 160
    Should Be True  ${ul_tput} > 10

    send_ics_registration  flag=off
    detach_ue_with_power_off  ue_id=1

CB013365_SR_TC29
# TC29_CB013365_SR_A_IWK5_Successful Inter-RAT handover for UE configured with new 5QIs supported by CB013365
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_

    # TODO check counter for all 5QI
    Setup_eGate_Env
    detach_ue_with_power_off  ue_id=1
    ue_modify_default_qosflow  ue_id=1  qosflow=35  #5QI-9
    CB013365_Change_UE_Location  ue_id=1  enb_id=2  cell_id=1

    attach_ue_and_activate_pdu  ue_id=1
    sleep  2
    start_ue_dl_data_traffic  ue_id=1  qfi=1  trf_id=1  dl_rate=150
    start_ue_ul_data_traffic  ue_id=1  qfi=1  trf_id=1  ul_rate=10
    sleep  5

    ${meas_id}  CB013365_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=634080  event_type=A2  report_on_leave=false  rsrp=46
    Should Not Be Equal  ${meas_id}  ${None}
    CB013365_Send_EventA2_For_InterFreq_Meas  ue_id=1  meas_id=${meas_id}  phycell_id=50
    sleep  10
    ${meas_id}  CB013365_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=1451  event_type=B2  report_on_leave=false  rsrp=40
    Should Not Be Equal  ${meas_id}  ${None}
    CB013365_Send_EventB2_For_InterRAT_Handover  ue_id=1  meas_id=${meas_id}  phycell_id=11
    sleep  10
    CB013365_Trigger_InterRAT_HO_from_LTE  ue_id=1  target_gnb=2  target_cell=1  plmn=311:489
    sleep  5

    detach_ue_with_power_off  ue_id=1

CB013365_SR_TC35
# TC35_CB013365_SR_A_IWK6_Measurement profile selection based on enhanced 5QI criteria during ICS for SA UE
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_

    # TODO check counter for all 5QI
    CB013365_Delta_Commission    file_name=Enable_Meas_Prof.json
    Setup_eGate_Env
    detach_ue_with_power_off  ue_id=1
    ue_modify_default_qosflow  ue_id=1  qosflow=35  #5QI-9
    CB013365_Change_UE_Location  ue_id=1  enb_id=2  cell_id=1

    attach_ue_and_activate_pdu  ue_id=1
    sleep  2
    start_ue_dl_data_traffic  ue_id=1  qfi=1  trf_id=1  dl_rate=150
    start_ue_ul_data_traffic  ue_id=1  qfi=1  trf_id=1  ul_rate=10
    sleep  5

    ${meas_id}  CB013365_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=634080  event_type=A2  report_on_leave=false  rsrp=40
    Should Not Be Equal  ${meas_id}  ${None}
    sleep  1
    ${meas_id}  CB013365_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=634080  event_type=A5  report_on_leave=false  rsrp=55
    Should Not Be Equal  ${meas_id}  ${None}
    sleep  1
    ${meas_id}  CB013365_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=634080  event_type=A2  report_on_leave=false  rsrp=46
    Should Not Be Equal  ${meas_id}  ${None}
    CB013365_Send_EventA2_For_InterFreq_Meas  ue_id=1  meas_id=${meas_id}  phycell_id=50
    sleep  2

    ${meas_id}  CB013365_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=634080  event_type=A1  report_on_leave=false  rsrp=65
    Should Not Be Equal  ${meas_id}  ${None}
    sleep  1
    ${meas_id}  CB013365_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=156510  event_type=A5  report_on_leave=false  rsrp=53
    Should Not Be Equal  ${meas_id}  ${None}
    sleep  1
    ${meas_id}  CB013365_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=1451  event_type=B2  report_on_leave=false  rsrp=40
    Should Not Be Equal  ${meas_id}  ${None}
    sleep  5

    detach_ue_with_power_off  ue_id=1
    CB013365_Delta_Commission    file_name=Disable_Meas_Prof.json

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

CB013365_Send_EventA2_For_InterFreq_Meas
    [Arguments]  ${ue_id}  ${meas_id}  ${phycell_id}
    log to console  \nSend Event A2 Report for InterFreq Measurement for UE-${ue_id}
    ute_wtssim.Execute Egate Command
    ...  cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=44 phycell_id=${phycell_id}

CB013365_Send_EventB2_For_InterRAT_Handover
    [Arguments]  ${ue_id}  ${meas_id}  ${phycell_id}
    log to console  \nSend Event B2 Report for InterRAT Handover for UE-${ue_id}
    ute_wtssim.Execute Egate Command
    ...  cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=B2 srsrp_nr=30 phycell_id=${phycell_id} nrsrp_nr=60 nrsrq_nr=30
    ...  pass_regexp=UE${ue_id}: IRAT Handover from NR to EUTRA completed
    ...  timeout=5s
    ...  return_output=${False}

CB013365_Trigger_InterRAT_HO_from_LTE
    [Arguments]  ${ue_id}=1  ${target_gnb}=2  ${target_cell}=1  ${plmn}=311:489
    log to console  \nTrigger InterRAT Handover from LTE to 5G for UE-${ue_id}
    ute_wtssim.Execute Egate Command
    ...  cmd=gnb_trigger_inter_rat_handover_to_5g ue=${ue_id} target_gnb=${target_gnb} target_cell=${target_cell} plmn=${plmn}
    ...  pass_regexp=UE${ue_id}: Inter-eNB handover from ENB.* to EXT_ENB.* performed
    ...  timeout=5s
    ...  return_output=${False}