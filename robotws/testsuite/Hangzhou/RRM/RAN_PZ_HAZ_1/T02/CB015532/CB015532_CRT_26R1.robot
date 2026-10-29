*** Settings ***
Documentation
...                 author:  Liu AnAn

Resource    ./CB015532_Resource.robot

Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF    CA_RAN_PZ_HAZ_1     CLOUD_5G_O_E_AP_LOOO

*** Test Cases ***
CB015532_TC_05
# CB015532_SR_1B_TC05_Successful_Inter-PLMN_Inter-gNB_intra-AMF_NG_Handover_with_non-emergency_UE_with_non-standard_slice_with_no_MRL
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_

    Setup_for_CB015532  config_tag=rjio_tc05

    detach_ue_with_power_off  ue_id=1
    detach_ue_with_power_off  ue_id=2

    start_log_collection
    CB015532_Change_Feature_Flag_1  false  false

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

    Log to Console  \nUE1 and UE2 should not perform Ng Handover
    CB015532_Send_EventA3_Measurement_Report  ue_id=1  meas_id=3  phycell_id=7  regexp=fail_regexp
    sleep  5
    CB015532_Send_EventA3_Measurement_Report  ue_id=2  meas_id=3  phycell_id=7  regexp=fail_regexp
    sleep  5
    ${ue_location}  CB015532_Get_UE_Location  ue_id=1
    Should Be Equal  ${ue_location}[0]  2
    ${ue_location}  CB015532_Get_UE_Location  ue_id=2
    Should Be Equal  ${ue_location}[0]  2
    Log to Console  \nUE1 and UE2 not perform Ng Handover as expected

    CB015532_Change_Feature_Flag_1  true  false
    Log to Console  \nUE1 perform Ng Handover and UE2 should not perform Ng Handover
    CB015532_Send_EventA3_Measurement_Report  ue_id=1  meas_id=3  phycell_id=7  regexp=pass_regexp
    sleep  5
    CB015532_Send_EventA3_Measurement_Report  ue_id=2  meas_id=3  phycell_id=7  regexp=fail_regexp
    sleep  5
    ${ue_location}  CB015532_Get_UE_Location  ue_id=1
    Should Be Equal  ${ue_location}[0]  3
    ${ue_location}  CB015532_Get_UE_Location  ue_id=2
    Should Be Equal  ${ue_location}[0]  2
    Log to Console  \nUE1 perform Ng Handover and UE2 not perform Ng Handover as expected

    CB015532_Change_Feature_Flag_1  false  true
    Log to Console  \nUE2 perform Ng Handover
    CB015532_Send_EventA3_Measurement_Report  ue_id=2  meas_id=3  phycell_id=7  regexp=pass_regexp
    sleep  5
    ${ue_location}  CB015532_Get_UE_Location  ue_id=1
    Should Be Equal  ${ue_location}[0]  3
    ${ue_location}  CB015532_Get_UE_Location  ue_id=2
    Should Be Equal  ${ue_location}[0]  3
    Log to Console  \nUE2 perform Ng Handover as expected

    Log to Console  \nUE1 and UE2 HO back to original Cell
    CB015532_Send_EventA3_Measurement_Report  ue_id=1  meas_id=1  phycell_id=50  regexp=pass_regexp
    sleep  5
    CB015532_Send_EventA3_Measurement_Report  ue_id=2  meas_id=1  phycell_id=50  regexp=pass_regexp
    sleep  5
    ${ue_location}  CB015532_Get_UE_Location  ue_id=1
    Should Be Equal  ${ue_location}[0]  2
    ${ue_location}  CB015532_Get_UE_Location  ue_id=2
    Should Be Equal  ${ue_location}[0]  2
    Log to Console  \nUE1 and UE2 HO back to original Cell as expected
    sleep  5

    detach_ue_with_power_off  ue_id=1
    detach_ue_with_power_off  ue_id=2

    [Teardown]  Teardown_for_CB015532

CB015532_TC_09
# CB015532_SR_2B_TC09_Successful_Inter-PLMN_Inter-gNB_intra-AMF_NG_Handover_with_non-emergency_UE_with_non-standard_slice_with_MRL
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_

    Setup_for_CB015532  config_tag=rjio_tc05
    CB015532_Config_MRL

    start_log_collection
    CB015532_Change_Feature_Flag_1  false  false

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

    Log to Console  \nUE1 and UE2 should not perform Ng Handover
    CB015532_Send_EventA3_Measurement_Report  ue_id=1  meas_id=3  phycell_id=7  regexp=fail_regexp
    sleep  5
    CB015532_Send_EventA3_Measurement_Report  ue_id=2  meas_id=3  phycell_id=7  regexp=fail_regexp
    sleep  5
    ${ue_location}  CB015532_Get_UE_Location  ue_id=1
    Should Be Equal  ${ue_location}[0]  2
    ${ue_location}  CB015532_Get_UE_Location  ue_id=2
    Should Be Equal  ${ue_location}[0]  2
    Log to Console  \nUE1 and UE2 not perform Ng Handover as expected

    CB015532_Change_Feature_Flag_1  true  false
    Log to Console  \nUE1 perform Ng Handover and UE2 should not perform Ng Handover
    CB015532_Send_EventA3_Measurement_Report  ue_id=1  meas_id=3  phycell_id=7  regexp=pass_regexp
    sleep  5
    CB015532_Send_EventA3_Measurement_Report  ue_id=2  meas_id=3  phycell_id=7  regexp=fail_regexp
    sleep  5
    ${ue_location}  CB015532_Get_UE_Location  ue_id=1
    Should Be Equal  ${ue_location}[0]  3
    ${ue_location}  CB015532_Get_UE_Location  ue_id=2
    Should Be Equal  ${ue_location}[0]  2
    Log to Console  \nUE1 perform Ng Handover and UE2 not perform Ng Handover as expected

    CB015532_Change_Feature_Flag_1  false  true
    Log to Console  \nUE2 perform Ng Handover
    CB015532_Send_EventA3_Measurement_Report  ue_id=2  meas_id=3  phycell_id=7  regexp=pass_regexp
    sleep  5
    ${ue_location}  CB015532_Get_UE_Location  ue_id=1
    Should Be Equal  ${ue_location}[0]  3
    ${ue_location}  CB015532_Get_UE_Location  ue_id=2
    Should Be Equal  ${ue_location}[0]  3
    Log to Console  \nUE2 perform Ng Handover as expected

    Log to Console  \nUE1 and UE2 HO back to original Cell
    CB015532_Send_EventA3_Measurement_Report  ue_id=1  meas_id=1  phycell_id=50  regexp=pass_regexp
    sleep  5
    CB015532_Send_EventA3_Measurement_Report  ue_id=2  meas_id=1  phycell_id=50  regexp=pass_regexp
    sleep  5
    ${ue_location}  CB015532_Get_UE_Location  ue_id=1
    Should Be Equal  ${ue_location}[0]  2
    ${ue_location}  CB015532_Get_UE_Location  ue_id=2
    Should Be Equal  ${ue_location}[0]  2
    Log to Console  \nUE1 and UE2 HO back to original Cell as expected
    sleep  5

    detach_ue_with_power_off  ue_id=1
    detach_ue_with_power_off  ue_id=2
    CB015532_Reset_MRL

    [Teardown]  Teardown_for_CB015532

CB015532_TC_11
# CB015532_SR_3B_TC11_Successful_Intra-PLMN_Inter-gNB_intra-AMF_NG_Handover_with_non-emergency_UE_with_non-standard_slice_with_no_MRL
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_

    Setup_for_CB015532  config_tag=rjio_tc11
    detach_ue_with_power_off  ue_id=1
    detach_ue_with_power_off  ue_id=2
    CB015532_Change_Feature_Flag_3  true  false  false

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
    detach_ue_with_power_off  ue_id=2

    Wait_for_Next_5min_Period
    Wait_for_Next_5min_Period
    ${value}  Counter Operation  operation=collect_counter_and_check_rule  product_type=gnb  bts_index=0  cudu_index=0

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

CB015532_Change_Feature_Flag_1
    [Arguments]    ${value_1}  ${value_2}

    @{para_list}      Create List    actInterPlmnNgHoOnlyForVoNR  nonStanSlicePlmnNgHoAllowed
    @{mo_list}        Create List    MRBTS-1/NRBTS-1   MRBTS-1/NRBTS-1
    @{value_list}     Create List    ${value_1}   ${value_2}
    CB015532_Change_Parameter  ${para_list}  ${mo_list}  ${value_list}

CB015532_Change_Feature_Flag_2
    [Arguments]    ${value_1}  ${value_2}  ${value_3}

    &{staged_dict}    Create Dictionary   emergencyCallMrListIgnore=true  emergencyCallPlmnHoAllowed=${value_3}
    @{staged_param_list}     Create List   ${staged_dict}

    @{para_list}      Create List    actInterPlmnNgHoOnlyForVoNR  nonStanSlicePlmnNgHoAllowed  emergencyCallRestrictions
    @{mo_list}        Create List    MRBTS-1/NRBTS-1   MRBTS-1/NRBTS-1  MRBTS-1/NRBTS-1/NRCELL-1
    @{value_list}     Create List    ${value_1}   ${value_2}  ${staged_param_list}
    CB015532_Change_Parameter  ${para_list}  ${mo_list}  ${value_list}

CB015532_Change_Feature_Flag_3
    [Arguments]    ${value_1}  ${value_2}  ${value_3}

    @{para_list}      Create List    actInterPlmnNgHoOnlyForVoNR  nonStanSlicePlmnNgHoAllowed  allowMultPlmnsInCandCellNgHo
    @{mo_list}        Create List    MRBTS-1/NRBTS-1   MRBTS-1/NRBTS-1  MRBTS-1/NRBTS-1
    @{value_list}     Create List    ${value_1}   ${value_2}  ${value_3}
    CB015532_Change_Parameter  ${para_list}  ${mo_list}  ${value_list}

CB015532_Reset_MRL
    [Arguments]  ${amf_id}=1
    Log to Console  \nReset Mobility Restriction List
    ute_wtssim.Execute Egate Command
    ...  cmd=amf_mobility_restriction_list_param id=1 reset
    ute_wtssim.Execute Egate Command
    ...  cmd=amf_ue_ics_param id=${amf_id} reset
    # ute_wtssim.Execute Egate Command
    # ...  cmd=amf_ue_ng_handover_request_param id=${amf_id} reset
    # ute_wtssim.Execute Egate Command
    # ...  cmd=amf_ul_nas_transport_param id=${amf_id} reset
    # ute_wtssim.Execute Egate Command
    # ...  cmd=amf_dl_nas_transport_param id=${amf_id} reset
    # ute_wtssim.Execute Egate Command
    # ...  cmd=amf_mobility_restriction_list_param id=${amf_id} reset

CB015532_Config_MRL
    [Arguments]  ${amf_id}=1
    Log to Console  \nConfigure AMF-${amf_id} MRL:Equiv PLMN:311:402
    ute_wtssim.Execute Egate Command
    ...  cmd=amf_mobility_restriction_list_param id=1 equiv_plmn=311:402
    ute_wtssim.Execute Egate Command
    ...  cmd=amf_ue_ics_param id=${amf_id} mobility_restriction_list_id=1
    # ute_wtssim.Execute Egate Command
    # ...  cmd=amf_ue_ng_handover_request_param id=${amf_id} mobility_restriction_list_id=1
    # ute_wtssim.Execute Egate Command
    # ...  cmd=amf_ul_nas_transport_param id=${amf_id} mobility_restriction_list_id=1
    # ute_wtssim.Execute Egate Command
    # ...  cmd=amf_dl_nas_transport_param id=${amf_id} mobility_restriction_list_id=1

CB015532_Configure_Emergency_Call
    [Arguments]  ${ue_id}
    Log to Console  \nUE${ue_id} Configure Emergency Call
    ute_wtssim.Execute Egate Command
    ...  cmd=qosflow_modify qos_flow=11 default=on
    ute_wtssim.Execute Egate Command
    ...  cmd=smf_param id=1 additional_qosflows_to_activate=1
    ute_wtssim.Execute Egate Command
    ...  cmd=qosflow_modify qos_flow=11 priority=1
    ute_wtssim.Execute Egate Command
    ...  cmd=qosflow_modify qos_flow=1 priority=1
    # Below Command looks not mandatory for Emergency Call
    ute_wtssim.Execute Egate Command
    ...  cmd=ue_nr_rrc_setup_param id=1 establishment_cause=emergency

CB015532_Deconfigure_Emergency_Call
    [Arguments]  ${ue_id}
    Log to Console  \nUE${ue_id} Configure Emergency Call
    ute_wtssim.Execute Egate Command
    ...  cmd=qosflow_modify qos_flow=15 default=on
    ute_wtssim.Execute Egate Command
    ...  cmd=smf_param id=1 reset
    # Below Command looks not mandatory for Emergency Call
    ute_wtssim.Execute Egate Command
    ...  cmd=ue_nr_rrc_setup_param id=1 establishment_cause=mo-Signalling