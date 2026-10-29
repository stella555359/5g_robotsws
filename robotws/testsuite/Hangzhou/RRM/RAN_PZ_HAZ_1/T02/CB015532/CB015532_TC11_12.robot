*** Settings ***
Documentation
...                 author:  Liu AnAn

Resource    ./CB015532_Resource.robot

Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF    CA_RAN_PZ_HAZ_1     CLOUD_5G_O_E_AP_LOOO

*** Variables ***
${config_tag}  rjio_tc11

*** Test Cases ***
Load_Configuration
    Setup_for_CB015532  config_tag=${config_tag}

CB015532_TC_11
# CB015532_SR_3B_TC11_Successful_Intra-PLMN_Inter-gNB_intra-AMF_NG_Handover_with_non-emergency_UE_with_non-standard_slice_with_no_MRL
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_

    Setup_eGate_Env

    detach_ue_with_power_off  ue_id=1
    detach_ue_with_power_off  ue_id=2
    CB015532_Change_Feature_Flag  true  false  false

    start_log_collection
    Wait_for_Next_5min_Period
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     counter_rule=${CURDIR}/counter_rule_tc11.txt
    ...                                                     wait_for_next_counter_generate=${False}

    CB015532_Change_UE_Location  ue_id=1  enb_id=2  cell_id=1
    CB015532_Change_UE_Location  ue_id=2  enb_id=2  cell_id=1
    attach_ue_and_activate_pdu  ue_id=1
    sleep  2
    attach_ue_and_activate_pdu  ue_id=2
    sleep  2
    start_ue_dl_data_traffic  ue_id=1  pdu=1  qfi=1  trf_id=1  dl_rate=10
    sleep  2
    start_ue_dl_data_traffic  ue_id=2  pdu=1  qfi=1  trf_id=1  dl_rate=10
    sleep  2
    start_ue_vonr_call  ue_id=1  pdu=1  rtp_codec=amr_12_2
    sleep  2

    Log to Console  \nUE1 should perform Ng Handover and UE2 should not perform Ng Handover
    CB015532_Send_EventA3_Measurement_Report  ue_id=1  meas_id=3  phycell_id=7  regexp=pass_regexp
    sleep  5
    CB015532_Send_EventA3_Measurement_Report  ue_id=2  meas_id=3  phycell_id=7  regexp=fail_regexp
    sleep  5
    ${ue_location}  CB015532_Get_UE_Location  ue_id=1
    Should Be Equal  ${ue_location}[0]  3
    ${ue_location}  CB015532_Get_UE_Location  ue_id=2
    Should Be Equal  ${ue_location}[0]  2
    Log to Console  \nUE1 perform Ng Handover and UE2 not perform Ng Handover as expected

    Log to Console  \nUE1 HO back to original Cell
    CB015532_Send_EventA3_Measurement_Report  ue_id=1  meas_id=1  phycell_id=50  regexp=pass_regexp
    sleep  5
    ${ue_location}  CB015532_Get_UE_Location  ue_id=1
    Should Be Equal  ${ue_location}[0]  2
    Log to Console  \nUE1 HO back to original Cell as expected

    detach_ue_with_power_off  ue_id=1
    detach_ue_with_power_off  ue_id=1

    Wait_for_Next_5min_Period
    Wait_for_Next_5min_Period
    ${value}  Counter Operation  operation=collect_counter_and_check_rule  product_type=gnb  bts_index=0  cudu_index=0

    [Teardown]  Teardown_for_CB015532

CB015532_TC_12
# CB015532_SR_3B_TC12_Successful_Intra-PLMN_Inter-gNB_intra-AMF_NG_Handover_with_non-emergency_UE_with_non-standard_slice_with_no_MRL_...
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_

    Setup_eGate_Env

    detach_ue_with_power_off  ue_id=1
    detach_ue_with_power_off  ue_id=2
    CB015532_Change_UE_Location  ue_id=1  enb_id=2  cell_id=1
    CB015532_Change_UE_Location  ue_id=2  enb_id=2  cell_id=1

    start_log_collection
    CB015532_Change_Feature_Flag  true  false  true

    attach_ue_and_activate_pdu  ue_id=1
    sleep  2
    attach_ue_and_activate_pdu  ue_id=2
    sleep  2
    start_ue_dl_data_traffic  ue_id=1  pdu=1  qfi=1  trf_id=1  dl_rate=10
    sleep  2
    start_ue_dl_data_traffic  ue_id=2  pdu=1  qfi=1  trf_id=1  dl_rate=10
    sleep  2
    start_ue_vonr_call  ue_id=1  pdu=1  rtp_codec=amr_12_2
    sleep  2

    Log to Console  \nUE1 and UE2 should perform Ng Handover
    CB015532_Send_EventA3_Measurement_Report  ue_id=1  meas_id=3  phycell_id=7  regexp=pass_regexp
    sleep  5
    CB015532_Send_EventA3_Measurement_Report  ue_id=2  meas_id=3  phycell_id=7  regexp=pass_regexp
    sleep  5
    ${ue_location}  CB015532_Get_UE_Location  ue_id=1
    Should Be Equal  ${ue_location}[0]  3
    ${ue_location}  CB015532_Get_UE_Location  ue_id=2
    Should Be Equal  ${ue_location}[0]  3
    Log to Console  \nUE1 and UE2 perform Ng Handover as expected

    Log to Console  \nUE1 HO back to original Cell
    CB015532_Send_EventA3_Measurement_Report  ue_id=1  meas_id=1  phycell_id=50  regexp=pass_regexp
    sleep  5
    CB015532_Send_EventA3_Measurement_Report  ue_id=2  meas_id=1  phycell_id=50  regexp=pass_regexp
    sleep  5
    ${ue_location}  CB015532_Get_UE_Location  ue_id=1
    Should Be Equal  ${ue_location}[0]  2
    ${ue_location}  CB015532_Get_UE_Location  ue_id=2
    Should Be Equal  ${ue_location}[0]  2
    Log to Console  \nUE1 and UE2 HO back to original Cell as expected

    detach_ue_with_power_off  ue_id=1
    detach_ue_with_power_off  ue_id=2

    [Teardown]  Teardown_for_CB015532

*** Keywords ***
CB015532_Send_EventA3_Measurement_Report
    [Arguments]  ${ue_id}  ${meas_id}  ${phycell_id}  ${regexp}
    Log to Console  \nUE${ue_id} Send A3 report for Handover
    ute_wtssim.Execute Egate Command
    ...  cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=10 phycell_id=${phycell_id} nrsrp_nr=40
    ...  ${regexp}=UE${ue_id}: NG Handover successfully completed
    ...  timeout=5s
    ...  return_output=${False}

CB015532_Change_Feature_Flag
    [Arguments]    ${value_1}  ${value_2}  ${value_3}

    @{para_list}      Create List    actInterPlmnNgHoOnlyForVoNR  nonStanSlicePlmnNgHoAllowed  allowMultPlmnsInCandCellNgHo
    @{mo_list}        Create List    MRBTS-1/NRBTS-1   MRBTS-1/NRBTS-1  MRBTS-1/NRBTS-1
    @{value_list}     Create List    ${value_1}   ${value_2}  ${value_3}
    CB015532_Change_Parameter  ${para_list}  ${mo_list}  ${value_list}