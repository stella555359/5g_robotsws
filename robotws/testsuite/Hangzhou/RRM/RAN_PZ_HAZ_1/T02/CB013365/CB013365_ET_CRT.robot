*** Settings ***
Documentation
...                 author:  Liu AnAn

Resource    ./CB013365_Resource.robot

Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF    CA_RAN_PZ_HAZ_1     CLOUD_5G_I_LOO_AP_LOOO

*** Test Cases ***
CB013365_SR_TC20
#TC20_CB013365_SR_A_EC4_Admission control failure in Target gNB due to unconfigured 5QIs received during Xn handover
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_
    # Setup_eGate_Env
    Setup_for_TMOUS  config_tag=tmous
    CB013365_Delta_Commission    file_name=Enable_Xn_HO.json  bts_index=0
    CB013365_Change_actSupportAll5qiAndQci    value=false
    CB013365_Change_actARPBasedAC  cell_id=1  value=off

    start_log_collection

    ute_wtssim.Execute Egate Command
    ...    cmd=sim_trace enb=1,3 protocol=xn,s1,x2 on
    CB013365_Change_UE_Location  ue_id=1  enb_id=3  cell_id=1
    CB013365_Change_gNB_Handover_Type  gnb_id=3  ho_type=xn_based
    detach_ue_with_power_off  ue_id=1
    send_ics_registration  flag=on
    ue_modify_default_qosflow  ue_id=1  qosflow=36  #5QI-10
    smf_parameter_config_multi_qosflow  qosflow=11,42,15  #5qi-74(GBR)/78(nGBR non-standard)/89(DC-GBR)
    ue_history_information_reset
    ue_history_information_add
    ue_add_ue_history_information  ue_id=1

    ${ue_location}  get_ue_location  ue_id=1
    attach_ue_and_activate_pdu  ue_id=1
    sleep  2

    CB013365_Send_EventA3_For_Handover_Xn_Fail  ue_id=1  meas_id=1  phycell_id=51
    sleep  2

    ${ue_location}  get_ue_location  ue_id=1
    Should Be Equal  ${ue_location}[0]  3
    ${ue_state}  get_ue_state  ue_id=1
    Should Be Equal  ${ue_state}  ACTIVE

    sleep  2

    detach_ue_with_power_off  ue_id=1

    [Teardown]  Teardown_for_CB013365

CB013365_SR_TC22
#TC22_CB013365_SR_A_IWK4_Partial Admission control for unconfigured 5QIs received during Xn handover in Target gNB
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_

    Setup_for_TMOUS  config_tag=tmous
    CB013365_Delta_Commission    file_name=Enable_Xn_HO.json  bts_index=0
    CB013365_Change_actSupportAll5qiAndQci    value=false
    CB013365_Change_actARPBasedAC  cell_id=1  value=on

    start_log_collection

    # Setup_eGate_Env
    ute_wtssim.Execute Egate Command
    ...    cmd=sim_trace enb=1,3 protocol=xn,s1,x2 on
    CB013365_Change_UE_Location  ue_id=1  enb_id=3  cell_id=1
    CB013365_Change_gNB_Handover_Type  gnb_id=3  ho_type=xn_based
    detach_ue_with_power_off  ue_id=1
    send_ics_registration  flag=on
    ue_modify_default_qosflow  ue_id=1  qosflow=35  #5QI-9
    # smf_parameter_config_multi_qosflow  qosflow=10,42,15  #5qi-73(GBR)/78(nGBR non-standard)/89(DC-GBR) ==AP Issue
    smf_parameter_config_multi_qosflow  qosflow=10,36
    ue_history_information_reset
    ue_history_information_add
    ue_add_ue_history_information  ue_id=1

    ${ue_location}  get_ue_location  ue_id=1
    attach_ue_and_activate_pdu  ue_id=1
    sleep  5

    CB013365_Send_EventA3_For_Handover_Xn_Fail  ue_id=1  meas_id=1  phycell_id=51
    sleep  5

    ${ue_location}  get_ue_location  ue_id=1
    Should Be Equal  ${ue_location}[0]  2
    ${ue_state}  get_ue_state  ue_id=1
    Should Be Equal  ${ue_state}  ACTIVE

    detach_ue_with_power_off  ue_id=1

    [Teardown]  Teardown_for_CB013365

CB013365_SR_TC45
# TC45_CB013365_SR_B_B4_Setup of successful non GBR QCI(s) received by gNB in X2AP_SgNBModificationRequest
# in the case where no matching NRBTS_NRDRB_QCI is configured
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_

    Setup_for_TMOUS  config_tag=tmous

    start_log_collection

    # Setup_eGate_Env
    ute_wtssim.Execute Egate Command
    ...    cmd=sim_trace enb=1 protocol=xn,s1,x2 on
    attach_ue_nsa  ue_id=61
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

    ${ue_dc_state}  get_ue_dc_state  ue_id=61
    Should Be Equal  ${ue_dc_state}  ACTIVE

    modify_endc_nsa  ue_id=61  action=bearer_to_release  bearer=3,6
    sleep  5

    ${ue_dc_state}  get_ue_dc_state  ue_id=61
    Should Be Equal  ${ue_dc_state}  ACTIVE

    sleep  5

    detach_ue_nsa  ue_id=61

    [Teardown]  Teardown_for_CB013365

CB013365_SR_TC46
# TC46_CB013365_SR_B_B5_Successful inter en-gNB mobility for non-standardized non GBR QCI(s)
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_283121

    Setup_for_TMOUS  config_tag=tmous

    start_log_collection

    # Setup_eGate_Env
    ute_wtssim.Execute Egate Command
    ...    cmd=sim_trace enb=1 protocol=xn,s1,x2 on
    attach_ue_nsa  ue_id=61
    sleep  2
    ue_bearer_add_nsa  ue_id=61  bearer=3  filter=1  precedence=1
    sleep  2
    ue_bearer_add_nsa  ue_id=61  bearer=6  filter=2  precedence=2
    sleep  2

    activate_endc_nsa  ue_id=61  target_gnb_id=5  target_cell_id=1  bearer=2,3,6
    sleep  5

    start_ue_dl_data_traffic_nsa  ue_id=61  bearer=2  trf_id=1  dl_rate=150
    start_ue_ul_data_traffic_nsa  ue_id=61  bearer=2  trf_id=1  ul_rate=10
    start_ue_dl_data_traffic_nsa  ue_id=61  bearer=3  trf_id=1  dl_rate=10
    start_ue_ul_data_traffic_nsa  ue_id=61  bearer=3  trf_id=1  ul_rate=10
    start_ue_dl_data_traffic_nsa  ue_id=61  bearer=6  trf_id=1  dl_rate=10
    start_ue_ul_data_traffic_nsa  ue_id=61  bearer=6  trf_id=1  ul_rate=10
    sleep  5

    ${ue_dc_state}  get_ue_dc_state  ue_id=61
    Should Be Equal  ${ue_dc_state}  ACTIVE

    CB013365_Send_EventA3_For_Handover_NSA  ue_id=61  meas_id=1  phycell_id=51
    sleep  5
    CB013365_Send_EventA3_For_Handover_NSA  ue_id=61  meas_id=5  phycell_id=10
    sleep  5

    ${ue_dc_state}  get_ue_dc_state  ue_id=61
    Should Be Equal  ${ue_dc_state}  ACTIVE

    sleep  5

    detach_ue_nsa  ue_id=61

    [Teardown]  Teardown_for_CB013365

*** Keywords ***
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

