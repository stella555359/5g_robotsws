*** Settings ***
Documentation
...                 author:  Liu AnAn

Resource    ./CB013365_Resource_kpi.robot
Variables   ./Variables_enh.py

Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF    CA_RAN_PZ_HAZ_1     CLOUD_5G_I_LOO_AP_LOOO

*** Variables ***
# ${owner_email}   anan.liu@nokia-sebll.com
${owner_email}   tacase_auto@nokia-sbell.com

${test_num}    10

*** Test Cases ***
Load_Configuration
    Setup_for_TMOUS  config_tag=tmous

CB013365_KPI_Test
    Setup_eGate_Env
    Test_Env_Clean_Up
    Test_Env_Setup

    # Precondition
    CB013365_Change_actSupportAll5qiAndQci  value=false
    send_ics_registration  flag=on
    ue_modify_default_qosflow  ue_id=all  qosflow=35
    mue_change_ue_location  @{ue_list_sa}  enb_id=2  cell_id=1

    start_log_collection

    # Procedures
    # Wait_for_Next_5min_Period
    Log to Console  \n=== Start KPI Test Procedure ===
    ${test_start_time}  Get_Current_Time
    # KPI Operation    start_kpi_collection    product_type=gnb

    # FOR  ${i}  IN RANGE  ${test_num}
    FOR  ${i}  IN RANGE  1
        Log to Console  \n=== Iteration ${i} ===
        ${start_time}  Get_Current_Time
        CB013365_Mix_Traffic_RLQ_SANSA
        ${end_time}  Get_Current_Time
        ${test_duration}  Evaluate  ${end_time} - ${start_time}
        Log to Console  \nTest Iteration ${i} duration: ${test_duration} seconds
    END
    ${test_end_time}  Get_Current_Time
    ${test_duration}  Evaluate  ${test_end_time} - ${test_start_time}
    Log to Console  \nKPI Test Duration: ${test_duration} seconds

    # Wait_for_Next_5min_Period
    # ${zip_path1}    KPI Operation    finish_kpi_collection    product_type=gnb
    # KPI Operation    kpi_report_generate    pmfile_zip_path=${zip_path1}    owner=${owner_email}  template=PMKPI_SBTS26R2_5G_up
    Log to Console  \n-------------------------------------Test is stopped!-------------------------------

    Run Keyword And Ignore Error  stop_log_collection

    # Post-condition
    Test_Env_Clean_Up

CB013365_KPI_Benchmark_Test
# Including:  PDU session setup/pdu session modification/vonr/inter-gNB NG handover/NSA SgNB Addition/NSA SgNB Modification
# NSA inter-engnb Handover + different RF condition (low/mid/high BLER, low/mid/high CQI value)
#########################################################  1st Round  #########################################################
    # Setup_eGate_Env
    Setup_for_TMOUS  config_tag=tmous
    CB013365_Change_actSupportAll5qiAndQci  value=false
    Test_Env_Setup

    # Precondition
    send_ics_registration  flag=on
    ue_modify_default_qosflow  ue_id=all  qosflow=35
    mue_change_ue_location  @{ue_list_sa}  enb_id=2  cell_id=1

    start_log_collection

    # Procedure
    # Wait_for_Next_15min_Period
    Wait_for_Next_5min_Period
    Log to Console  \n=== Start KPI Test Procedure ===
    ${test_start_time}  Get_Current_Time
    KPI Operation    start_kpi_collection    product_type=gnb
    FOR  ${i}  IN RANGE  ${test_num}
        Log to Console  \n=== Iteration ${i} ===
        ${start_time}  Get_Current_Time
        CB013365_Mix_Traffic_RLQ_SANSA
        ${end_time}  Get_Current_Time
        ${test_duration}  Evaluate  ${end_time} - ${start_time}
        Log to Console  \nTest Iteration ${i} duration: ${test_duration} seconds
    END
    ${test_end_time}  Get_Current_Time
    ${test_duration}  Evaluate  ${test_end_time} - ${test_start_time}
    Log to Console  \nKPI Test Duration: ${test_duration} seconds

    Wait_for_Next_5min_Period
    ${zip_path1}    KPI Operation    finish_kpi_collection    product_type=gnb
    # KPI Operation    kpi_report_generate    pmfile_zip_path=${zip_path1}    owner=${owner_email}
    Log to Console  \n-------------------------------------Test is finished!-------------------------------

    Run Keyword And Ignore Error  stop_log_collection

#########################################################  2nd Round  #########################################################
    # Setup_eGate_Env
    Setup_for_TMOUS  config_tag=tmous
    CB013365_Change_actSupportAll5qiAndQci  value=true
    Test_Env_Setup

    # Precondition
    send_ics_registration  flag=on
    ue_modify_default_qosflow  ue_id=all  qosflow=35
    mue_change_ue_location  @{ue_list_sa}  enb_id=2  cell_id=1

    start_log_collection

    # Procedure
    Wait_for_Next_5min_Period
    # Wait_for_Next_15min_Period
    Log to Console  \n=== Start KPI Test Procedure ===
    ${test_start_time}  Get_Current_Time
    KPI Operation    start_kpi_collection    product_type=gnb

    FOR  ${i}  IN RANGE  ${test_num}
        Log to Console  \n=== Iteration ${i} ===
        ${start_time}  Get_Current_Time
        CB013365_Mix_Traffic_RLQ_SANSA
        ${end_time}  Get_Current_Time
        ${test_duration}  Evaluate  ${end_time} - ${start_time}
        Log to Console  \nTest Iteration ${i} duration: ${test_duration} seconds
    END
    ${test_end_time}  Get_Current_Time
    ${test_duration}  Evaluate  ${test_end_time} - ${test_start_time}
    Log to Console  \nKPI Test Duration: ${test_duration} seconds

    Wait_for_Next_5min_Period
    # Wait_for_Next_5min_Period
    # Wait_for_Next_15min_Period
    ${zip_path2}    KPI Operation    finish_kpi_collection    product_type=gnb
    # KPI Operation    kpi_report_generate    pmfile_zip_path=${zip_path2}    owner=${owner_email}
    Log to Console  \n-------------------------------------Test is finished!-------------------------------

    Run Keyword And Ignore Error  stop_log_collection

    KPI Operation    benchmark_report_generate    pmfile_zip_path1=${zip_path1}    pmfile_zip_path2=${zip_path2}
    ...  owner=${owner_email}  template1=PMKPI_SBTS26R2_5G_up  templlate2=PMKPI_SBTS26R2_5G_up

# Test
#     Setup_eGate_Env
#     ${dl_tput}  get_ue_dl_scell_tput  ue_id=1
#     Log to Console  DL Tput:  ${dl_tput}
#     ${ul_tput}  get_ue_ul_scell_tput  ue_id=1
#     Log to Console  UL Tput:  ${dl_tput}
#     Should Be True  ${dl_tput} > 450
#     Should Be True  ${ul_tput} > 30

*** Keywords ***
CB013365_Send_EventA3_For_Handover_SA
    [Arguments]  ${ue_id}  ${meas_id}  ${phycell_id}
    log to console  \nSend Event A3 Report for Handover for UE-${ue_id}
    ute_wtssim.Execute Egate Command
    ...  cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=30 phycell_id=${phycell_id} nrsrp_nr=60
    ...  pass_regexp=UE${ue_id}: Inter-eNB handover from.*performed
    ...  timeout=3
    ...  return_output=${False}

CB013365_Send_EventA3_For_Handover_NSA
    [Arguments]  ${ue_id}  ${meas_id}  ${phycell_id}
    log to console  \nSend Event A3 Report for Handover for UE-${ue_id}
    ute_wtssim.Execute Egate Command
    ...  cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=30 phycell_id=${phycell_id} nrsrp_nr=60
    ...  pass_regexp=Handover Successful,  HandoverType = sn_change
    ...  timeout=3
    ...  return_output=${False}

CB013365_Change_actSupportAll5qiAndQci
    [Arguments]  ${value}
    @{gnb_para_list}          Create List    actSupportAll5qiAndQci
    @{gnb_mo_list}            Create List    MRBTS-1/NRBTS-1
    @{gnb_value_list}         Create List    ${value}
    CB013365_Change_Parameter  ${gnb_para_list}  ${gnb_mo_list}  ${gnb_value_list}

Test_Env_Clean_Up
    mue_deactivate_bler_test_mode  @{ue_list_sa}  profile_id=2
    mue_deactivate_bler_test_mode  @{ue_list_sa}  profile_id=3
    mue_deactivate_bler_test_mode  @{ue_list_sa}  profile_id=4
    mue_deactivate_bler_test_mode  @{ue_list_nsa}  profile_id=2
    mue_deactivate_bler_test_mode  @{ue_list_nsa}  profile_id=3
    mue_deactivate_bler_test_mode  @{ue_list_nsa}  profile_id=4
    delete_multiple_bler_profile

    mue_deactivate_csi_report_test_mode  @{ue_list_sa}  profile_id=12
    mue_deactivate_csi_report_test_mode  @{ue_list_sa}  profile_id=13
    mue_deactivate_csi_report_test_mode  @{ue_list_sa}  profile_id=14
    mue_deactivate_csi_report_test_mode  @{ue_list_sa}  profile_id=22
    mue_deactivate_csi_report_test_mode  @{ue_list_sa}  profile_id=23
    mue_deactivate_csi_report_test_mode  @{ue_list_sa}  profile_id=24
    mue_deactivate_csi_report_test_mode  @{ue_list_nsa}  profile_id=12
    mue_deactivate_csi_report_test_mode  @{ue_list_nsa}  profile_id=13
    mue_deactivate_csi_report_test_mode  @{ue_list_nsa}  profile_id=14
    mue_deactivate_csi_report_test_mode  @{ue_list_nsa}  profile_id=22
    mue_deactivate_csi_report_test_mode  @{ue_list_nsa}  profile_id=23
    mue_deactivate_csi_report_test_mode  @{ue_list_nsa}  profile_id=24
    delete_multiple_csi_report_profile

    # Do NOT add below, otherwise, DL bler profile will not work!!!!!
    # ute_wtssim.Execute Egate Command
    # ...    cmd=uec_l2_testmode_params fixed_csi_report=true

Test_Env_Setup
    create_multiple_bler_profile
    create_multiple_csi_report_profile

    mue_activate_bler_test_mode  @{ue_good_rlq_list_sa}  profile_id=2
    mue_activate_bler_test_mode  @{ue_mid_rlq_list_sa}  profile_id=3
    mue_activate_bler_test_mode  @{ue_bad_rlq_list_sa}  profile_id=4
    mue_activate_csi_report_test_mode  @{ue_good_rlq_list_sa}  profile_id=12
    mue_activate_csi_report_test_mode  @{ue_mid_rlq_list_sa}  profile_id=13
    mue_activate_csi_report_test_mode  @{ue_bad_rlq_list_sa}  profile_id=14

    mue_activate_bler_test_mode  @{ue_good_rlq_list_nsa}  profile_id=2
    mue_activate_bler_test_mode  @{ue_mid_rlq_list_nsa}  profile_id=3
    mue_activate_bler_test_mode  @{ue_bad_rlq_list_nsa}  profile_id=4
    mue_activate_csi_report_test_mode  @{ue_good_rlq_list_nsa}  profile_id=12
    mue_activate_csi_report_test_mode  @{ue_mid_rlq_list_nsa}  profile_id=13
    mue_activate_csi_report_test_mode  @{ue_bad_rlq_list_nsa}  profile_id=14

    sleep  5

CB013365_Mix_Traffic_RLQ_SANSA
    # Start attach SA UE and data service
    mue_attach_and_activate_pdu  @{ue_list_sa}
    mue_start_dl_data_service  @{ue_good_rlq_list_sa}  dl_rate=100
    mue_start_ul_data_service  @{ue_good_rlq_list_sa}  ul_rate=20
    mue_start_dl_data_service  @{ue_mid_rlq_list_sa}  dl_rate=20
    mue_start_ul_data_service  @{ue_mid_rlq_list_sa}  ul_rate=4
    mue_start_dl_data_service  @{ue_bad_rlq_list_sa}  dl_rate=1
    mue_start_ul_data_service  @{ue_bad_rlq_list_sa}  ul_rate=1

    mue_start_vonr_service  @{ue_vonr_list}
    #  5QI-10(nGBR)/73(GBR)/74(GBR)/78(non-standard)/90(DC-GBR)
    mue_pdu_session_modify_add_qosflow  @{ue_mdrb_list}  qosflow=36,10,11,42,16
    mue_start_dl_data_service  @{ue_mdrb_list}  qfi=2  dl_rate=5
    mue_start_dl_data_service  @{ue_mdrb_list}  qfi=3  dl_rate=1
    mue_start_dl_data_service  @{ue_mdrb_list}  qfi=4  dl_rate=1
    mue_start_dl_data_service  @{ue_mdrb_list}  qfi=5  dl_rate=3
    mue_start_dl_data_service  @{ue_mdrb_list}  qfi=6  dl_rate=1
    # mue_start_small_dl_data_service  @{ue_mdrb_list}  qfi=2  dl_rate=500
    # mue_start_small_dl_data_service  @{ue_mdrb_list}  qfi=3  dl_rate=30
    # mue_start_small_dl_data_service  @{ue_mdrb_list}  qfi=4  dl_rate=30
    # mue_start_small_dl_data_service  @{ue_mdrb_list}  qfi=5  dl_rate=100
    # mue_start_small_dl_data_service  @{ue_mdrb_list}  qfi=6  dl_rate=10

    # Start attach NSA UE and data service
    mue_attach_nsa  @{ue_list_nsa}
    mue_activate_endc_nsa  @{ue_non_mdrb_list_nsa}  target_gnb_id=2  target_cell_id=1  bearer=2
    # QCI-68/120
    mue_bearer_add_nsa  @{ue_mdrb_list_nsa}  bearer=5  filter=1  precedence=1
    mue_bearer_add_nsa  @{ue_mdrb_list_nsa}  bearer=6  filter=2  precedence=2
    mue_activate_endc_nsa  @{ue_mdrb_list_nsa}  target_gnb_id=2  target_cell_id=1  bearer=2,5,6
    # In case bearer 5/6 activation failure when CB013365 off
    mue_start_dl_data_service_nsa  @{ue_good_rlq_list_nsa}  bearer=2  dl_rate=10
    mue_start_ul_data_service_nsa  @{ue_good_rlq_list_nsa}  bearer=2  ul_rate=3
    mue_start_dl_data_service_nsa  @{ue_mid_rlq_list_nsa}  bearer=2  dl_rate=5
    mue_start_ul_data_service_nsa  @{ue_mid_rlq_list_nsa}  bearer=2  ul_rate=2
    mue_start_dl_data_service_nsa  @{ue_bad_rlq_list_nsa}  bearer=2  dl_rate=1
    mue_start_ul_data_service_nsa  @{ue_bad_rlq_list_nsa}  bearer=2  ul_rate=1

    # mue_start_dl_data_service_nsa  @{ue_mdrb_list_nsa}  bearer=5  dl_rate=3
    # mue_start_ul_data_service_nsa  @{ue_mdrb_list_nsa}  bearer=5  ul_rate=1
    # mue_start_dl_data_service_nsa  @{ue_mdrb_list_nsa}  bearer=6  dl_rate=3
    # mue_start_ul_data_service_nsa  @{ue_mdrb_list_nsa}  bearer=6  ul_rate=1
    mue_start_small_dl_data_service_nsa  @{ue_mdrb_list_nsa}  bearer=5  dl_rate=200
    mue_start_small_ul_data_service_nsa  @{ue_mdrb_list_nsa}  bearer=5  ul_rate=100
    mue_start_small_dl_data_service_nsa  @{ue_mdrb_list_nsa}  bearer=6  dl_rate=200
    mue_start_small_ul_data_service_nsa  @{ue_mdrb_list_nsa}  bearer=6  ul_rate=100

    sleep  30

    # Trigger Intra-F Inter-gNB NG HO for SA UE
    FOR  ${ue_id}  IN  @{ue_ho_list_sa}
        ${meas_id}  CB013365_Get_NR_Meas_Config_Id  ue_id=${ue_id}  nrarfcn=520110  event_type=A3  report_on_leave=False  rsrp=0
        IF  ${meas_id} != ${None}
            Run Keyword And Ignore Error
            ...  CB013365_Send_EventA3_For_Handover_SA  ue_id=${ue_id}  meas_id=${meas_id}  phycell_id=7
        END
        sleep  2
    END

    # Trigger Intra-F Inter-engNB HO for NSA UE
    FOR  ${ue_id}  IN  @{ue_ho_list_nsa}
        ${meas_id}  CB013365_Get_NR_Meas_Config_Id  ue_id=${ue_id}  nrarfcn=520110  event_type=A3  report_on_leave=False  rsrp=0
        IF  ${meas_id} != ${None}
            Run Keyword And Ignore Error
            ...  CB013365_Send_EventA3_For_Handover_NSA  ue_id=${ue_id}  meas_id=${meas_id}  phycell_id=10
            sleep  2
        END
    END

    sleep  30

    # Trigger Intra-F Inter-gNB NG HO for SA UE
    FOR  ${ue_id}  IN  @{ue_ho_list_sa}
        ${meas_id}  CB013365_Get_NR_Meas_Config_Id  ue_id=${ue_id}  nrarfcn=520110  event_type=A3  report_on_leave=False  rsrp=0
        IF  ${meas_id} != ${None}
            Run Keyword And Ignore Error
            ...  CB013365_Send_EventA3_For_Handover_SA  ue_id=${ue_id}  meas_id=${meas_id}  phycell_id=51
        END
        sleep  2
    END

    # Trigger Intra-F Inter-engNB HO for NSA UE
    FOR  ${ue_id}  IN  @{ue_ho_list_nsa}
        ${meas_id}  CB013365_Get_NR_Meas_Config_Id  ue_id=${ue_id}  nrarfcn=520110  event_type=A3  report_on_leave=False  rsrp=0
        IF  ${meas_id} != ${None}
            Run Keyword And Ignore Error
            ...  CB013365_Send_EventA3_For_Handover_NSA  ue_id=${ue_id}  meas_id=${meas_id}  phycell_id=51
            sleep  2
        END
    END

    sleep  30

    # Stop data service for SA and NSA UE
    mue_stop_data_service  @{ue_list_sa}
    mue_stop_data_service_nsa  @{ue_list_nsa}

    sleep  1

    # Detach SA UE and NSA UE
    mue_detach_with_power_off  @{ue_list_sa}
    mue_detach_nsa  @{ue_list_nsa}

    sleep  1
