*** Settings ***
Documentation
...                 author:  Liu AnAn

Resource    ./CB013365_Resource.robot
Variables   ./Variables.py

Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF    CA_RAN_PZ_HAZ_1     CLOUD_5G_I_LOO_AP_LOOO

*** Test Cases ***
Load_Configuration
    Setup_for_TMOUS  config_tag=tmous

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
    smf_parameter_config_multi_qosflow  qosflow=42,43,45,44  #5QI-78/79/81/80

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
    CB013365_Delta_Commission    file_name=Enable_Xn_HO.json  bts_index=0
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

    ${meas_id}  CB013365_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=520110  event_type=A3  report_on_leave=False  rsrp=0
    CB013365_Send_EventA3_For_Handover_Xn  ue_id=1  meas_id=${meas_id}   phycell_id=51
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


CB013365_SR_TC13
# TC13_CB013365_SR_A_B6_Successful NG based Inter-gNB handover with unconfigured 5QIs
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_

    # qfi-2/3 data traffic
    CB013365_Delta_Commission    file_name=Enable_Ng_HO.json  bts_index=0
    Setup_eGate_Env
    CB013365_Change_gNB_Handover_Type  gnb_id=3  ho_type=ng_based
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

    ${meas_id}  CB013365_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=520110  event_type=A3  report_on_leave=False  rsrp=0
    CB013365_Send_EventA3_For_Handover_Ng  ue_id=1  meas_id=${meas_id}   phycell_id=51
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

CB013365_SR_TC17
# TC17_CB013365_SR_A_Successful 5QI modification of an existing nonGBR Qos flow with PDU Session Resource Modify (nonGBR to nonGBR modification)
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_

    Setup_eGate_Env
    CB013365_Change_UE_Location  ue_id=1  enb_id=2  cell_id=1
    detach_ue_with_power_off  ue_id=1
    send_ics_registration  flag=on
    ue_modify_default_qosflow  ue_id=1  qosflow=35  #5QI-9

    attach_ue_and_activate_pdu  ue_id=1
    sleep  2
    start_ue_dl_data_traffic  ue_id=1  trf_id=1  dl_rate=150
    start_ue_ul_data_traffic  ue_id=1  trf_id=1  ul_rate=10
    sleep  5

    ue_pdu_session_modify_modify_qosflow  ue_id=1  qosflow=35  5qi=81
    sleep  5
    ${dl_tput}  get_ue_dl_scell_tput  ue_id=1
    Log to Console  DL Tput:  ${dl_tput}
    ${ul_tput}  get_ue_ul_scell_tput  ue_id=1
    Log to Console  UL Tput:  ${dl_tput}
    Should Be True  ${dl_tput} > 145
    Should Be True  ${ul_tput} > 9.5

    ue_pdu_session_modify_modify_qosflow  ue_id=1  qosflow=35  5qi=9
    sleep  5
    ${dl_tput}  get_ue_dl_scell_tput  ue_id=1
    Log to Console  DL Tput:  ${dl_tput}
    ${ul_tput}  get_ue_ul_scell_tput  ue_id=1
    Log to Console  UL Tput:  ${dl_tput}
    Should Be True  ${dl_tput} > 145
    Should Be True  ${ul_tput} > 9.5

    send_ics_registration  flag=off
    ue_modify_default_qosflow  ue_id=1  qosflow=35  #5QI-9
    detach_ue_with_power_off  ue_id=1

CB013365_SR_TC43
# TC43_CB013365_SR_B_B2_Setup of successful non GBR QCI(s) received by gNB in X2AP_SgNBAdditionRequest
# in the case where no matching NRBTS_NRDRB_QCI is configured
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_

    Setup_eGate_Env
    detach_ue_nsa  ue_id=51
    attach_ue_nsa  ue_id=51
    # Need change bearer to unsupported qci and check counter
    activate_endc_nsa  ue_id=51  target_gnb_id=2  target_cell_id=1  bearer=2 #Bearer-2: QCI-9
    sleep  2
    start_ue_dl_data_traffic_nsa  ue_id=51  bearer=2  trf_id=1  dl_rate=150
    start_ue_ul_data_traffic_nsa  ue_id=51  bearer=2  trf_id=1  ul_rate=10
    sleep  5

    detach_ue_with_power_off  ue_id=1

CB013365_SR_TC45
# TC45_CB013365_SR_B_B4_Setup of successful non GBR QCI(s) received by gNB in X2AP_SgNBModificationRequest
# in the case where no matching NRBTS_NRDRB_QCI is configured
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_

    start_log_collection

    Setup_eGate_Env
    ute_wtssim.Execute Egate Command
    ...    cmd=sim_trace enb=1 protocol=xn,s1,x2 on
    detach_ue_nsa  ue_id=61
    attach_ue_nsa  ue_id=61
    # Need change bearer to unsupported qci and check counter
    activate_endc_nsa  ue_id=61  target_gnb_id=2  target_cell_id=1  bearer=2
    sleep  2
    start_ue_dl_data_traffic_nsa  ue_id=61  bearer=2  trf_id=1  dl_rate=150
    start_ue_ul_data_traffic_nsa  ue_id=61  bearer=2  trf_id=1  ul_rate=10
    sleep  5

    ue_bearer_add_nsa  ue_id=61  bearer=3  filter=1  precedence=1
    sleep  2
    ue_bearer_add_nsa  ue_id=61  bearer=6  filter=2  precedence=2
    sleep  2
    modify_endc_nsa  ue_id=61  action=bearer_to_add  bearer=3,6
    sleep  2
    start_ue_dl_data_traffic_nsa  ue_id=61  bearer=3  trf_id=1  dl_rate=50
    start_ue_dl_data_traffic_nsa  ue_id=61  bearer=6  trf_id=1  dl_rate=50
    start_ue_ul_data_traffic_nsa  ue_id=61  bearer=3  trf_id=1  ul_rate=10
    start_ue_ul_data_traffic_nsa  ue_id=61  bearer=6  trf_id=1  ul_rate=10
    sleep  5

    modify_endc_nsa  ue_id=61  action=bearer_to_release  bearer=3,6
    sleep  2

    detach_ue_nsa  ue_id=61

    Run Keyword And Ignore Error  stop_log_collection

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




