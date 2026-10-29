*** Settings ***
Documentation
...                 author:  Liu AnAn

Resource    ./CB014553_Resource.robot

Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF    CA_RAN_PZ_HAZ_1     CLOUD_5G_I_[MP][MP]_AP_[LOOO]

*** Variables ***
${test_num}  10

*** Test Cases ***
Load_Configuration
    Setup_for_IntergNB  config_tag=2gnb

Load_Configuration_NRDC
    Setup_for_NRDC  config_tag=nrdc

CB013365_SR_TC09
# TC09_CB013365_SR_A_B5_Successful Xn based Intra-frequency Inter-gNB handover with unconfigured 5QIs

    CB013365_Delta_Commission    file_name=Enable_Xn_HO.json

    # Precondition
    # ToDO: Remove configured 5QI profile
    Setup_eGate_Env
    detach_ue_with_power_off  ue_id=1
    Change_UE_Location  ue_id=1  enb_id=2  cell_id=3
    send_ics_registration  flag=on
    ue_modify_default_qosflow  ue_id=1  qosflow=35  #5QI-9
    # ue_modify_default_qosflow  ue_id=1  qosflow=41  #5QI-77
    # smf_parameter_config_multi_qosflow  qosflow=42,43,45  #5QI-78/79/81

    # UE attach and activated unconfigured 5QIs PDU Session
    attach_ue_and_activate_pdu  ue_id=1
    sleep  2
    start_ue_dl_data_traffic  ue_id=1  trf_id=1  dl_rate=100
    start_ue_ul_data_traffic  ue_id=1  trf_id=1  ul_rate=10

    # UE perform Xn based Intra-frequency Inter-gNB handover to target gNB
    ${meas_id}  Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=649920  event_type=A3  report_on_leave=false  rsrp=0
    CB013365_Send_EventA3_For_Handover_Xn  ue_id=1  meas_id=${meas_id}  phycell_id=60
    ${ue_state}  Get_UE_State  ue_id=1
    Should be Equal  ${ue_state}  ACTIVE
    ${ue_location}  Get_UE_Location  ue_id=1
    Should Be Equal  ${ue_location}[0]  3
    sleep  5

    # UE perform Intra-frequency Inter-gNB handover back to source gNB
    ${meas_id}  Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=649920  event_type=A3  report_on_leave=false  rsrp=0
    CB013365_Send_EventA3_For_Handover_Xn  ue_id=1  meas_id=${meas_id}  phycell_id=53
    ${ue_state}  Get_UE_State  ue_id=1
    Should be Equal  ${ue_state}  ACTIVE
    ${ue_location}  Get_UE_Location  ue_id=1
    Should Be Equal  ${ue_location}[0]  2
    sleep  5

    send_ics_registration  flag=off
    smf_parameter_config_reset
    detach_ue_with_power_off  ue_id=1

CB013365_SR_TC10
# TC10_CB013365_SR_A_B5_ALT1_Successful Xn based Intra-frequency Inter-gNB handover with configured 5QIs

    CB013365_Delta_Commission    file_name=Enable_Xn_HO.json

    # Precondition
    Setup_eGate_Env
    detach_ue_with_power_off  ue_id=1
    Change_UE_Location  ue_id=1  enb_id=2  cell_id=3
    send_ics_registration  flag=on
    ue_modify_default_qosflow  ue_id=1  qosflow=35  #5QI-9
    # ue_modify_default_qosflow  ue_id=1  qosflow=41  #5QI-77
    # smf_parameter_config_multi_qosflow  qosflow=42,43,45  #5QI-78/79/81

    # UE attach and activated unconfigured 5QIs PDU Session
    attach_ue_and_activate_pdu  ue_id=1
    sleep  2
    start_ue_dl_data_traffic  ue_id=1  trf_id=1  dl_rate=100
    start_ue_ul_data_traffic  ue_id=1  trf_id=1  ul_rate=10

    # UE perform Xn based Intra-frequency Inter-gNB handover to target gNB
    ${meas_id}  Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=649920  event_type=A3  report_on_leave=false  rsrp=0
    CB013365_Send_EventA3_For_Handover_Xn  ue_id=1  meas_id=${meas_id}  phycell_id=60
    ${ue_state}  Get_UE_State  ue_id=1
    Should be Equal  ${ue_state}  ACTIVE
    ${ue_location}  Get_UE_Location  ue_id=1
    Should Be Equal  ${ue_location}[0]  3
    sleep  5

    # UE perform Intra-frequency Inter-gNB handover back to source gNB
    ${meas_id}  Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=649920  event_type=A3  report_on_leave=false  rsrp=0
    CB013365_Send_EventA3_For_Handover_Xn  ue_id=1  meas_id=${meas_id}  phycell_id=53
    ${ue_state}  Get_UE_State  ue_id=1
    Should be Equal  ${ue_state}  ACTIVE
    ${ue_location}  Get_UE_Location  ue_id=1
    Should Be Equal  ${ue_location}[0]  2
    sleep  5

    send_ics_registration  flag=off
    smf_parameter_config_reset
    detach_ue_with_power_off  ue_id=1

CB013365_SR_TC11
# TC11_CB013365_SR_A_B5_ALT2_Successful Xn based Inter-frequency Inter-gNB handover with unconfigured 5QIs

    CB013365_Delta_Commission    file_name=Enable_Xn_HO.json

    # Precondition
    # ToDO: Remove configured 5QI profile
    Setup_eGate_Env
    detach_ue_with_power_off  ue_id=1
    Change_UE_Location  ue_id=1  enb_id=2  cell_id=3
    send_ics_registration  flag=on
    ue_modify_default_qosflow  ue_id=1  qosflow=35  #5QI-9
    # ue_modify_default_qosflow  ue_id=1  qosflow=41  #5QI-77
    # smf_parameter_config_multi_qosflow  qosflow=42,43,45  #5QI-78/79/81

    # UE attach and activated unconfigured 5QIs PDU Session
    attach_ue_and_activate_pdu  ue_id=1
    sleep  2
    start_ue_dl_data_traffic  ue_id=1  trf_id=1  dl_rate=100
    start_ue_ul_data_traffic  ue_id=1  trf_id=1  ul_rate=10

    # UE perform Xn based Intra-frequency Inter-gNB handover to target gNB
    ${meas_id}  Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=649920  event_type=A2  report_on_leave=false  rsrp=0
    CB013365_Send_EventA2_For_Inter_F_Measurment  ue_id=1  meas_id=${meas_id}
    sleep  5
    ${meas_id}  Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=126750  event_type=A3  report_on_leave=false  rsrp=0
    CB013365_Send_EventA3_For_Handover_Xn  ue_id=1  meas_id=${meas_id}  phycell_id=56
    ${ue_state}  Get_UE_State  ue_id=1
    Should be Equal  ${ue_state}  ACTIVE
    ${ue_location}  Get_UE_Location  ue_id=1
    Should Be Equal  ${ue_location}[0]  3
    sleep  5

    # UE perform Intra-frequency Inter-gNB handover back to source gNB
    ${meas_id}  Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=126750  event_type=A2  report_on_leave=false  rsrp=0
    CB013365_Send_EventA2_For_Inter_F_Measurment  ue_id=1  meas_id=${meas_id}
    sleep  5
    ${meas_id}  Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=649920  event_type=A3  report_on_leave=false  rsrp=0
    CB013365_Send_EventA3_For_Handover_Xn  ue_id=1  meas_id=${meas_id}  phycell_id=53
    ${ue_state}  Get_UE_State  ue_id=1
    Should be Equal  ${ue_state}  ACTIVE
    ${ue_location}  Get_UE_Location  ue_id=1
    Should Be Equal  ${ue_location}[0]  2
    sleep  5

    send_ics_registration  flag=off
    smf_parameter_config_reset
    detach_ue_with_power_off  ue_id=1

CB013365_SR_TC13
# TC13_CB013365_SR_A_B6_Successful NG based Inter-gNB handover with unconfigured 5QIs

    CB013365_Delta_Commission    file_name=Enable_Ng_HO.json

    # Precondition
    # Todo: Remove configured 5QI profile
    Setup_eGate_Env
    detach_ue_with_power_off  ue_id=1
    sleep  2
    Change_UE_Location  ue_id=1  enb_id=2  cell_id=3
    send_ics_registration  flag=on
    ue_modify_default_qosflow  ue_id=1  qosflow=35  #5QI-9
    # ue_modify_default_qosflow  ue_id=1  qosflow=41  #5QI-77
    # smf_parameter_config_multi_qosflow  qosflow=42,43,45  #5QI-78/79/81

    # UE attach and activated unconfigured 5QIs PDU Session
    attach_ue_and_activate_pdu  ue_id=1
    sleep  2
    start_ue_dl_data_traffic  ue_id=1  trf_id=1  dl_rate=100
    start_ue_ul_data_traffic  ue_id=1  trf_id=1  ul_rate=10

    # UE perform Xn based Intra-frequency Inter-gNB handover to target gNB
    ${meas_id}  Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=649920  event_type=A3  report_on_leave=false  rsrp=0
    CB013365_Send_EventA3_For_Handover_Ng  ue_id=1  meas_id=${meas_id}  phycell_id=60
    ${ue_state}  Get_UE_State  ue_id=1
    Should be Equal  ${ue_state}  ACTIVE
    ${ue_location}  Get_UE_Location  ue_id=1
    Should Be Equal  ${ue_location}[0]  3
    sleep  5

    # UE perform Intra-frequency Inter-gNB handover back to source gNB
    ${meas_id}  Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=649920  event_type=A3  report_on_leave=false  rsrp=0
    CB013365_Send_EventA3_For_Handover_Xn  ue_id=1  meas_id=${meas_id}  phycell_id=53
    ${ue_state}  Get_UE_State  ue_id=1
    Should be Equal  ${ue_state}  ACTIVE
    ${ue_location}  Get_UE_Location  ue_id=1
    Should Be Equal  ${ue_location}[0]  2
    sleep  5

    send_ics_registration  flag=off
    smf_parameter_config_reset
    detach_ue_with_power_off  ue_id=1

CB013365_SR_TC14
# TC14_CB013365_SR_A_B6_ALT1_Successful NG based Inter-gNB handover with configured 5QIs

    CB013365_Delta_Commission    file_name=Enable_Ng_HO.json

    # Precondition
    Setup_eGate_Env
    detach_ue_with_power_off  ue_id=1
    sleep  2
    Change_UE_Location  ue_id=1  enb_id=2  cell_id=3
    send_ics_registration  flag=on
    ue_modify_default_qosflow  ue_id=1  qosflow=35  #5QI-9
    # ue_modify_default_qosflow  ue_id=1  qosflow=41  #5QI-77
    # smf_parameter_config_multi_qosflow  qosflow=42,43,45  #5QI-78/79/81

    # UE attach and activated unconfigured 5QIs PDU Session
    attach_ue_and_activate_pdu  ue_id=1
    sleep  2
    start_ue_dl_data_traffic  ue_id=1  trf_id=1  dl_rate=100
    start_ue_ul_data_traffic  ue_id=1  trf_id=1  ul_rate=10

    # UE perform Xn based Intra-frequency Inter-gNB handover to target gNB
    ${meas_id}  Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=649920  event_type=A3  report_on_leave=false  rsrp=0
    CB013365_Send_EventA3_For_Handover_Ng  ue_id=1  meas_id=${meas_id}  phycell_id=60
    ${ue_state}  Get_UE_State  ue_id=1
    Should be Equal  ${ue_state}  ACTIVE
    ${ue_location}  Get_UE_Location  ue_id=1
    Should Be Equal  ${ue_location}[0]  3
    sleep  5

    # UE perform Intra-frequency Inter-gNB handover back to source gNB
    ${meas_id}  Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=649920  event_type=A3  report_on_leave=false  rsrp=0
    CB013365_Send_EventA3_For_Handover_Xn  ue_id=1  meas_id=${meas_id}  phycell_id=53
    ${ue_state}  Get_UE_State  ue_id=1
    Should be Equal  ${ue_state}  ACTIVE
    ${ue_location}  Get_UE_Location  ue_id=1
    Should Be Equal  ${ue_location}[0]  2
    sleep  5

    send_ics_registration  flag=off
    smf_parameter_config_reset
    detach_ue_with_power_off  ue_id=1

*** Keywords ***
CB013365_Send_EventA3_For_Handover_Xn
    [Arguments]  ${ue_id}  ${meas_id}  ${phycell_id}
    log to console  \nSend Event A3 Report for Handover
    ute_wtssim.Execute Egate Command and Wait for Data
    ...  cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=30 phycell_id=${phycell_id} nrsrp_nr=40
    ...  pass_regexp=PATH SWITCH REQUEST ACK .* Sent
    ...  timeout=5s
    ...  return_output=${False}

CB013365_Send_EventA3_For_Handover_Ng
    [Arguments]  ${ue_id}  ${meas_id}  ${phycell_id}
    log to console  \nSend Event A3 Report for Handover
    ute_wtssim.Execute Egate Command and Wait for Data
    ...  cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=30 phycell_id=${phycell_id} nrsrp_nr=40
    ...  pass_regexp=Received HandoverNotify
    ...  timeout=5s
    ...  return_output=${False}

CB013365_Send_EventA2_For_Inter_F_Measurment
    [Arguments]  ${ue_id}  ${meas_id}
    log to console  \nSend Event A2 Report for Inter-F Measurement
    ute_wtssim.Execute Egate Command
    ...  cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=30
    ...  pass_regexp=EGATE>
    ...  timeout=5s
