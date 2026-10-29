*** Settings ***
Documentation    Suite description
Variables    ./TLConfigurationDefault.py
Variables    ./CaseConfiguration.py
Resource     ../../../../RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3Call.robot
Resource     ../../../../OAM/RAN_PZ_HAZ_34/5GC002479/Resources/5GC002479_CP_Resource.robot
#Resource     ../../../../OAM/RAN_PZ_HAZ_34/5GC002479/Resources/5GC002479_Resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_alarms_without_recovery.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_lock_and_unlock.robot
Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_block_and_unblock.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_power_reset.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_BTS_startup_with_RF_delayed_startup.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RU_lock_unlock.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_alarms_with_recovery.robot

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/log/symptom_collectors_hangzhou.robot

*** Variables ***
${WEBUI_URL}           https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}      ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}      ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_IP}            ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${ASIK_IP_Mplane}      ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${ASIK_IP}             ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_username}	   ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${ASIK_password}	   ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${MRBTS_ID}            ${tl.gnbs[0].instance_id}
${NRBTS_ID}            ${tl.gnbs[0].global_bts_id}

&{condition_ru_same}     rf-FRU6=diff

*** Keywords ***
TC.x85_L3Call_For_N53
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] This case is to frame structure
    ...    ******************
    ...    History of changes
   [Arguments]   ${peak_use_tool}=False
    MultiUE.L3Call    UECFG=${TLCommonConfig['MultiUECFG_X85']}    peak_use_tool=${peak_use_tool}

TC.01_General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module
    [Documentation]
    ...    ****************
    ...    - [TEST PURPOSE] The Purpose of this case is to check RF module support in SW build.
    ...    ******************
    [Arguments]   ${variable_from_CFAM}=${Variables_CFAM}
    General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module    variable_from_CFAM=${variable_from_CFAM}

TC.02_General_SiSo_Commissioning_BTS_Template_Commissioning
    General_SiSo_Commissioning_BTS_Template_Commissioning

TC.03_5GC000399_eCPRI_Basic_configuration_over_RP1
    5GC000399_eCPRI_Basic_configuration_over_RP1

TC.04_5GC000399_eCPRI_Carier_activation
    5GC000399_eCPRI_Carier_activation

TC.05_General_SiSo_U-plane_Fast_C-plane_counters
    General_SiSo_U-plane_Fast_C-plane_counters

TC.06_5GC000399_eCPRI_FREERUN_state_handling
    5GC000399_eCPRI_FREERUN_state_handling

TC.07_5GC000561_eCPRI_sync_generic_startup_at_RAU
    5GC000561_eCPRI_sync_generic_startup_at_RAU

TC.08_5GC000561_eCPRI_sync_counters
    5GC000561_eCPRI_sync_counters

TC.09_General_SiSo_SOAP_RP1_verification
    General_SiSo_SOAP_RP1_verification

TC.10_General_SiSo_Auto_Automatic_RAT_SW_upgrade
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to check functionality of the automatic software upgrade of RFSW
    ...    in case of incompatible RFSW.
    ...    ******************
    ...    Notice: run this kw can add as -v target_old_version:10.1800.xxxx
    General_SiSo_Auto_Automatic_RAT_SW_upgrade

TC.11_General_SiSo_RF_module_power_reset
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    Description in reStructuredText format on what is tested
    ...    *****************
    ...    - [TEST PURPOSE] To check RU recovery after power reset
    ...      during normal operation (OnAir state).
    # [Arguments]  ${ru_index}=${TCCB005845_TC11['ru_index']}
    General_SiSo_RF_module_power_reset

TC.12_General_SiSo_RF_module_reset_from_GUI
    General_SiSo_RF_module_reset_from_GUI

TC.13_General_SiSo_RF_module_reset_triggered_by_user_as_part_of_BTS_reset
    General_SiSo_RF_module_reset_triggered_by_user_as_part_of_BTS_reset

TC.14_General_SiSo_BTS_reset_with_RF_power_reset
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to verify Reset site shouldn't be performed after RU power reset
    ...    ******************
    [Arguments]  ${ru_index}=${TCCB005845_TC14['ru_index']}
    General_SiSo_BTS_reset_with_RF_power_reset    ru_index=${ru_index}

TC.15_General_SiSo_BTS_startup_with_RF_delayed_startup
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to check the RU connection,
    ...    detection and configuration to the BTS in a reliable time.
    ...    RU should be powered on with delay after the BTS (RAC and RAU) is online, connected.
    ...    ******************
    General_SiSo_BTS_startup_with_RF_delayed_startup

TC.16_General_SiSo_Cell_lock_and_unlock
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    Description in reStructuredText format on what is tested
    ...    *****************
    ...    - [TEST PURPOSE] To verify cell and group cell lock/ unlock functionality
    ...      during normal operation (OnAir state).
    ...    *******************
    [Arguments]  ${with_call}=${TCCB005845_TC16['with_call']}  ${with_peak}=${TCCB005845_TC16['with_peak']}
    General_SiSo_Cell_lock_and_unlock    with_call=${with_call}    with_peak=${with_peak}

TC.16_01_General_SiSo_Cell_lock_and_unlock
    [Documentation]
    Get X2 link shutdown waiting time
    ${cell_id_list}  Get All Cell Id
    ${cell_num}    get length  ${cell_id_list}
    COAM_WebEM.Login
    FOR    ${cell_idx}    IN    @{cell_id_list}
        COAM_WebEM.SetParameterValue    distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_idx}
        ...                                    abbr=Administrative state    value=Locked
    END
    COAM_WebEM.ValidateAndActiveParameters
    FOR    ${cell_idx}    IN    @{cell_id_list}
        Wait Until Keyword Succeeds    3 times    30s    COAM_WEBEM.CheckLockUnlcokCellStatus    cell_idx=${cell_idx}
        ...    status=Locked
        COAM_WebEM.SetParameterValue    distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_idx}
        ...                                    abbr=Administrative state    value=Unlocked
    END
    COAM_WebEM.ValidateAndActiveParameters
    FOR    ${cell_idx}    IN    @{cell_id_list}
        Wait Until Keyword Succeeds    3 times    30s    COAM_WEBEM.CheckLockUnlcokCellStatus    cell_idx=${cell_idx}
        ...    status=Unlocked
    END
    COAM_WebEM.Logout

TC.17_General_SiSo_RU_lock_unlock
    General_SiSo_RU_lock_unlock    with_call=${TCCB005845_TC17['with_call']}

TC.18_General_SiSo_Online_Cell_addition_deletion
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to verify that cell addition and cell deletion function works well on WebEM
    ...    ******************
   # [Arguments]    ${addition_deletion_cell}=${TCCB005845_TC18['addition_deletion_cell']}
   # ...            ${addition_deletion_cellgrp}=${TCCB005845_TC18['addition_deletion_cellgrp']}
#    General_SiSo_Online_Cell_addition_deletion    addition_deletion_cell=${addition_deletion_cell}
#    ...            addition_deletion_cellgrp=${addition_deletion_cellgrp}
    log    test

TC.19_General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed_PMAX
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    Description in reStructuredText format on what is tested
    ...    *****************
    ...    - [TEST PURPOSE] To verify that 5G BTS can report fault 1900: EFaultId_FrConfiguringFailed
    ...      after configuring pmax to out of range value of supported power.
    ...    *******************
    [Arguments]  ${cell_id}=${TCCB005845_TC19['cell_id']}
    #  ${variable_from_CFAM}=${Variables_CFAM}
    General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed_PMAX    cell_id=${cell_id}

TC.20_General_SiSo_LED_states_management_basic
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] This case is to frame structure
    ...    ******************
    [Arguments]  ${ru_index}=${TCCB005845_TC20['ru_index']}
    General_SiSo_LED_states_management_basic    ru_index=${ru_index}

TC.21_General_SiSo_RF_alarms_with_recovery
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    Description in reStructuredText format on what is tested
    ...    *****************
    ...    - [TEST PURPOSE] To verify RU connection and fault reporting in WebUI.
    ...    RU should be affected by recoverable error triggered during normal BTS run
    ...    *******************
    # [Arguments]  ${ru_index}=${TCCB005845_TC21['ru_index']}
    # General_SiSo_RF_alarms_with_recovery    ru_index=${ru_index}
    ${ru_index_list}    Get All RU Index
    FOR   ${ru_index}   IN   @{ru_index_list}
        General_SiSo_RF_alarms_with_recovery    ru_index=${ru_index}
    END


TC.22_General_SiSo_RF_alarms_without_recovery
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is verification of RU connection and lack of attempt of RU recovery from fault state.
    ...    RU should be affected by unrecoverable error triggered during normal BTS run.
    ...    *******************
    # [Arguments]  ${ru_index}=${TCCB005845_TC22['ru_index']}
    # ...          ${Tdanger_target}=${TCCB005845_TC22['Tdanger_target']}
    # General_SiSo_RF_alarms_without_recovery    ru_index=${ru_index}    Tdanger_target=${Tdanger_target}
    [Arguments]  ${Tdanger_target}=${TCCB005845_TC22['Tdanger_target']}
    ${ru_index_list}    Get All RU Index
    FOR   ${ru_index}   IN   @{ru_index_list}
        General_SiSo_RF_alarms_without_recovery    ru_index=${ru_index}    Tdanger_target=${Tdanger_target}
    END

TC.23_General_SiSo_NR-ARFCN_check
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] This case is to test SiSo_NR-ARFCN_check
    ...    ******************
    [Arguments]  ${cell_id}=${TCCB005845_TC23['cell_id']}
    #...          ${radio_type}=${ru_type_init}  ${variable_from_CFAM}=${Variables_CFAM}
    General_SiSo_NR-ARFCN_check    cell_id=${cell_id}

TC.24_General_SiSo_E2E_system_setup_with_data_transfer
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] This case is to frame structure
    ...    ******************
    ...    History of changes
    ...     2023/11/3 Shitaotao update: 1.In full SCF, block irrelevant cells and do L3Call
    [Arguments]  ${attach_cell_index}=1
    ...          ${UECFG}=NULL
    ...          ${UE_index}=0
    ...          ${peak_use_tool}=False
    [Timeout]    120 minutes
#    ...          ${ru_index}=${TCCB005845_TC24['ru_index']}
#    ...          ${cell_id}=${TCCB005845_TC24['cell_id']}
#    ...          ${ue_num_each_call}=1  ${random_access}=${False}
#    ...    ${protocol}=udp    ${iperf_type}=${None}    ${duration}=${600}    &{kwargs}
#    General_SiSo_E2E_system_setup_with_data_transfer    band=${band}    ru_index=${ru_index}    cell_id=${cell_id}
#    ...    ue_num_each_call=${ue_num_each_call}    random_access=${random_access}    protocol=${protocol}
#    ...    iperf_type=${iperf_type}    duration=${duration}    &{kwargs}
    log    ${UECFG}
    ${cell_id_list}  Get All Cell Id
    ${cell_list_temp}    create list    ${attach_cell_index}
    Set To Dictionary    ${UECFG["${UE_index}"]}
    ...    cell_index_list=${cell_list_temp}
    Run Keyword And Continue On Failure    MultiUE.PrepareUE
    ...    UECFG=${UECFG}    default_ue_index=${UE_index}
    AlarmWatchdog.add_allow_alarms    fault_id=49
    COAM_WebEM.Login
    FOR   ${cell_index}   IN   @{cell_id_list}
        run keyword if    ${attach_cell_index}!=${cell_index}
        ...    COAM_WEBEM.BlockUnBlcokCell    cell_idx=${cell_index}  action=block
    END
    Run Keyword And Ignore error    COAM_WebEM.Logout
    MultiUE.L3Call    UECFG=${UECFG}    peak_use_tool=${peak_use_tool}
    COAM_WebEM.Login
    FOR   ${cell_index}   IN   @{cell_id_list}
        run keyword if    ${attach_cell_index}!=${cell_index}
        ...    COAM_WEBEM.BlockUnBlcokCell    cell_idx=${cell_index}  action=unblock
    END
    Run Keyword And Ignore error    COAM_WebEM.Logout
    Wait Until Keyword Succeeds    10min    10s     Du Check cell on air via WebUI
    AlarmWatchdog.remove_allow_alarms    fault_id=49
    [Teardown]    Run Keyword And Ignore error    KW.UnblockAllCells


TC.25_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to collect Snapshot logs in WebUI
    ...    and check if RFSW logs from Radio Unit are included in Snapshot.
    ...    ******************
    General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot    is_get_snapshot_via_selenium=${True}

TC.26_General_SiSo_RF_module_IP_adress_allocation
    General_SiSo_RF_module_IP_adress_allocation

TC.27_OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_from_WebUI_with_L3Call
    [Documentation]  Aim to test RF Reset success rate
    ...    Steps:
    ...    Step1: loop defined times to reset ru on webui and onair
    ...    Step2: check the duration and pass rate of ru reset
    ...    Case Input:
    ...    please refer to [Arguments]
    [Arguments]  ${retry_times}=${CASE_INPUT_5GC002479['5GC002479_HA_KPI51']['RF_reset_times']}
    #...          ${ru_index}=${CASE_INPUT_5GC002479['5GC002479_HA_KPI51']['ru_index']}
    #...          ${kpi_max}=${CASE_INPUT_5GC002479['5GC002479_HA_KPI51']['KPI51_MAX']}
    #...          ${kpi_avg}=${CASE_INPUT_5GC002479['5GC002479_HA_KPI51']['KPI51_AVG']}
    TC.5GC002479_HA_08_OAM_KPI_51_RU_Reset_Time    RF_reset_times=${retry_times}
    TC.5GC002479_HA_09_OAM_KPI_651_RU_Software_Reset_Startup_Success_Rate

TC.28_OAM_KPI_61a_SiSo_Auto_BTS_site_reset
    [Arguments]  ${retry_times}=${CASE_INPUT_5GC002479['5GC002479_HA_KPI1a']['WebUI_reset_times']}
    #...    ${kpi_max}=${CASE_INPUT_5GC002479['5GC002479_HA_KPI1a']['KPI1a_MAX']}
    #...    ${kpi_avg}=${CASE_INPUT_5GC002479['5GC002479_HA_KPI1a']['KPI1a_AVG']}
    TC.GC002479_HA_01_OAM_KPI_1a_Site_Reset_Outage_Duration_Single_Core
    ...    WebUI_reset_times= ${retry_times}

TC.29_OAM_KPI_64_SiSo_Auto_RU_SW_upgrade_success_rate
    [Documentation]  Aim to test SW upgrade success rate
    ...    Steps:
    ...    Step1: Prepare target sw and intermediate sw
    ...    Step2: loop defined times to Yaft BTS active/passive to intermediate sw, then upgrade to target sw
    ...    Step3: check the duration and password of upgrade to target sw.
    ...    Case Input:
    ...    please refer to [Arguments]
    [Arguments]  ${retry_times}=${CASE_INPUT_5GC002479['5GC002479_IA_KPI2d']['SW_update_times']}
    #...          ${kpi_max}=${CASE_INPUT_5GC002479['5GC002479_IA_KPI2d']['KPI2d_MAX']}
    KW.CaseStatusInit      retry_times=${retry_times}
    FOR    ${i}    IN RANGE    ${retry_times}
        set suite variable     ${SWM}                            ${0}
        set suite variable     ${SW_active_duration}             ${18000}
        run keyword and ignore error    KW.SWM.CheckIfSWActiveRun    stream=${TargetBTSStream}   conditions=&{condition_ru_same}
        KW.CaseStatusCaluate    duration=${SW_active_duration}    max=${CASE_INPUT_5GC002479['5GC002479_IA_KPI2d']['KPI2d_MAX']}
    END
    KW.CaseStatusFinnal    case_avg=${18000}    max_loop=${retry_times}
    KW.PassRateStatusFinal

TC.30_General_SiSo_Link_Diagnostic_and_Monitoring
    General_SiSo_Link_Diagnostic_and_Monitoring

TC.31_General_RU_Module_Certificate_Integrity
    General_RU_Module_Certificate_Integrity

TC.32_General_SiSo_ALD_Configuration_Management_ALD_site_commissioning
    General_SiSo_ALD_Configuration_Management_ALD_site_commissioning

TC.33_General_SiSo_ALD_HW_inventory_ALD_HW_properties_retrieval_and_visualization
    General_SiSo_ALD_HW_inventory_ALD_HW_properties_retrieval_and_visualization

TC.34_General_SiSo_ALD_State_Management_ALD_state_management_handling_and_visibility
    [Arguments]   ${ald_type}=${TCCB005845_TC34['ald_type']}
    General_SiSo_ALD_State_Management_ALD_state_management_handling_and_visibility    ald_type=${ald_type}

TC.35_General_SiSo_ALD_FM_Antenna_Line_Device_faulty_notification_recovery_action_indication_and_visualization
    [Arguments]    ${ald_type}=${TCCB005845_TC35['ald_type']}
    General_SiSo_ALD_FM_Antenna_Line_Device_faulty_notification_recovery_action_indication_and_visualization    ald_type=${ald_type}

TC.36_General_SiSo_RF_module_addition_in_BIM_and_WebUI
    General_SiSo_RF_module_addition_in_BIM_and_WebUI

TC.44_5GC000560_eLLF_PTP_Failure
    5GC000560_eLLF_PTP_Failure

TC.51_5GC000560_eLLF_sync_generic_startup_at_RU
    5GC000560_eLLF_sync_generic_startup_at_RU

TC.52_5GC000399_eCPRI_RP1_Supervision_failure
    [Documentation]  The purpose of this test is to verify RP1 connection supervision failure detected on RAU
    ...    Steps:
    ...    Step1: Supervision failure is raised due to RP1 Specification Chapter 3.11.1 (Figure 6 Supervision)
    ...    Step2: Cells in WebUI has operational state as disabled and availability status as offline
    ...    Step3: RU was reset automaticlly
    ...    Step4: Set back value before step1
    ...    Step5: check cell on air
    ...    Case Input:
    ...    please refer to [Arguments]
#    5GC000399_eCPRI_RP1_Supervision_failure
    Log    TO BE Implement

TC.53_General_SiSo_eCPRI_synchronization_status_NIDD_parameters
    [Documentation]  The purpose of this test is to verify synchronization eCPRI NIDD parameter status in WebUI
    ...    Steps: cell should be on air and ECPRI related Parameters exsit in webui
    ...    Case Input:
    ...    ECPRI related Parameters ,please refer to [Arguments]
    [Arguments]  ${parameters_list}=${TCCB005845_TC53}
    General_SiSo_eCPRI_synchronization_status_NIDD_parameters   parameters_list=${parameters_list}

TC.54_General_SiSo_Automatic_factory_RFSW_update
    [Arguments]  ${target_old_version}=${TCCB005845_TC54['target_old_version']}
    set test variable    ${target_old_version}
    General_SiSo_Auto_Automatic_RAT_SW_upgrade

TC.55_General_SiSo_LED_states_management_additional_scenarios
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to verify that LEDs on radio module works as specified
    ...    check LEDs after triggering  alarm such as 1937
    ...    check LEDS after 1937 is disappered
    ...    ******************
    [Arguments]  ${ru_index}=${TCCB005845_TC55['ru_index']}
    ...          ${Tdanger_target}=${TCCB005845_TC55['Tdanger_target']}
    General_SiSo_LED_states_management_additional_scenarios    ru_index=${ru_index}   Tdanger_target=${Tdanger_target}

TC.56_General_SiSo_ALD_SW_Management_Create_ALD_Build_Descriptor_file
    [Documentation]  Aim to test the ALD Vender package generation
    ...    Steps:
    ...    1. Load ALD vender bin file
    ...    2. Fill the corresponding parameters
    ...    3. Save to generate ALD vender package to local.
    ...    Condigurations:
    ...    {CASE_INPUT_CB005845['TC56']['ALDBinFilePath']} path to bin file
   [Arguments]   ${ALDBinFilePath}=${TCCB005845_TC56['ALDBinFilePath']}
    ...          ${TargetSWversion}=1.0.0.
    ${minor_version}    evaluate   random.randint(1,100)   modules=random
    set suite variable    ${ALD_Version}    ${TargetSWversion}.${minor_version}
    COAM_WebEM.Login
    selenium_coam.restore_hw_info    sw_file=${ALDBinFilePath}
    ...    target_sw_version=${ALD_Version}
    ${ALD_FilePath}    selenium_coam.save_ald_sw_file
    COAM_WebEM.Logout
    set suite variable    ${ALD_FilePath}    ${ALD_FilePath}

TC.57_General_SiSo_ALD_Configuration_Management_RET_calibration_via_command
    [Documentation]  Aim to test calibration for RETU
    ...    Steps:
    ...    1. login to WebEM and calibration for RETU
    ...    Condigurations:
    ...    ${TCCB005845_TC57['retu_index']} indicate which RETU to calibrate
    [Arguments]  ${retu_index}=${TCCB005845_TC57['retu_index']}
    COAM_WebEM.Login
    Selenium_coam.calibrate_retu   retu_index=${retu_index}
    COAM_WebEM.Logout

TC.58_General_SiSo_ALD_SW_Management_ALD_SW_Download_and_Activation
    [Documentation]  Aim to test RETU software download and active
    ...    Steps:
    ...    1. load RETU software package from WebEM
    ...    2. click start button to download.
    ...    3. check the version is correct.
    ...    Condigurations:
    ...    ${TCCB005845_TC58['retu_index']} indicate which RETU to check
    [Arguments]  ${retu_index}=${TCCB005845_TC58['retu_index']}    #${ALDFilePath}=Depend on the output to case56     #${'TC58']['ALDFilePath']}
    KW.UpGradeForRU    filename=${ALDFilePath}
    COAM_WebEM.Login
    ${ALD_info}    selenium_coam.get_ald_info      ald_index=${retu_index}
    log to console    ${ALD_info}
    #should be equal    ${ALD_info[xxx]}   ${ALD_Version}
    COAM_WebEM.Logout

TC.59_General_SiSo_ALD_Configuration_Management_RET_tilt_modification
    [Documentation]  Aim to test RETU parameter modification
    ...    Steps:
    ...    1. Mofidy RETU parameters and active
    ...    3. check the parameters is correctly actived.
    ...    Condigurations:
    ...    ${TCCB005845_TC59['retu_index']} indicate which RETU to change
    [Arguments]    ${retu_index}=${TCCB005845_TC59['retu_index']}
    COAM_WebEM.Login
    ${retu_info}    selenium_coam.get_retu_info    retu_index=${retu_index}
    log to console    ${retu_info}
    ${angle}    get regexp matches    ${retu_info['Angle']}    [0-9]+
    ${angle}    get regexp matches    ${angle[0]}    [0-9]+
    FOR  ${i}    IN RANGE    ${10}
        ${min}    get regexp matches    ${retu_info['Angle range']}    from [0-9]+
        ${min}    get regexp matches    ${min[0]}    [0-9]+
        ${max}    get regexp matches    ${retu_info['Angle range']}    to [0-9]+
        ${max}    get regexp matches    ${max[0]}    [0-9]+
        ${angle_value}    evaluate   random.randint(${min[0]},${max[0]})   modules=random
        Exit For Loop If    ${angle[0]}!=${angle_value}
    END
    &{angle_configuration}    Create Dictionary    angle=${angle_value}
    selenium_coam.set_retu_angles    configuration=${angle_configuration}    retu_index=${retu_index}
    FOR  ${i}    IN RANGE    ${15}
        Sleep    20
        ${retu_info}    selenium_coam.get_retu_info    retu_index=${retu_index}
        ${angle}    get regexp matches    ${retu_info['Angle']}    [0-9]+
        ${angle}    get regexp matches    ${angle[0]}    [0-9]+
        Exit For Loop If    ${angle[0]}==${angle_value}
    END
    COAM_WebEM.Logout

TC.60_General_SiSo_Auto_Cell_lock_and_unlock_with_L3call
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    Description in reStructuredText format on what is tested
    ...    *****************
    ...    - [TEST PURPOSE] To verify cell and group cell lock/ unlock functionality
    ...      during normal operation (OnAir state).
    ...    *******************
    [Arguments]  ${times}=${CASE_INPUT_CB005845['TC60']['lock_unlock_retry_times']}
    FOR  ${i}   IN RANGE  ${times}
        General_SiSo_Cell_lock_and_unlock    with_call=${false}
        MultiUE.L3Call    ue_index=${CASE_INPUT_CB005845['ue_index']}    ue_mode=${CASE_INPUT_CB005845['ue_mode']}
        ...    apn=${CASE_INPUT_CB005845['apn']}
    END

TC.61_General_SiSo_stability_with_L3Call
    MultiUE.L3Call    ue_index=${CASE_INPUT_CB005845['ue_index']}    ue_mode=${CASE_INPUT_CB005845['ue_mode']}
    ...    apn=${CASE_INPUT_CB005845['apn']}    check_throughput_duration=21600
    ...    dl_target_throughput=800    ul_target_throughput=120    target_avg_percent=0.5

TC.62_Manual_SiSo_SM_BTS_Site_Reset
    [Documentation]   detail steps
    ...    1. Site reset and wait onair
    COAM_WebEM.Login
    selenium_coam.reset_site
    sleep    30s
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    Run Keyword And Ignore Error     COAM_WebEM.Logout


TC.63_General_SiSo_Cell_block_and_unblock
    [Arguments]  ${with_call}=${False}  ${with_peak}=${False}
    General_SiSo_Cell_block_and_unblock    with_call=${with_call}    with_peak=${with_peak}
# KW Part
KW.commission_Base_SCF
    [Arguments]    ${scf1}=${CFGFILE_PATH}/SCF_SBTS00.xml    ${scf2}=${CFGFILE_PATH}/SCF_SBTS00.xml
    COAM_Admin.Login
    ${version}    COAM_Admin.GetActiveSoftwareVersion
    ${longStreamPrefix}    ${fullVersion}    Basic.GetStreamAndVersion    vstring=${version}
    ${shortStreamPrefix}    Basic.GetSBTSStreamPrefix    vstring=${version}
    set suite variable     ${shortStreamPrefix}
#    ${shortStreamPrefix}    Set Variable If    ${longStreamPrefix.count('ENB_9999')}>0    SBTS00    ${shortStreamPrefix}
    run keyword if    ${longStreamPrefix.count('ENB_9999')}>0   COAM_Admin.commission  scf_file=${scf1}
    ...   ELSE     COAM_Admin.commission  scf_file=${scf2}

KW.CaseSetupForOAMKPI
    #rf-FRU6=diff
    set suite variable   ${OAM_TYPE}    COAM
    set suite variable    ${SCFPrepared}    notstart
    set suite variable    ${StopCase}       false
    set suite variable    ${CaseState}      notstart
    COAM_Admin.Login
    ${version}    COAM_Admin.GetActiveSoftwareVersion
    Run Keyword And Ignore Error     COAM_Admin.Logout
    ${stream}    ${version_Target}    Basic.GetStreamAndVersion     vstring=${version}
    set suite variable    ${TargetBTSVersion}    ${version_Target}
    set suite variable    ${TARGETSW}            ${version_Target}
    set suite variable    ${TargetBTSStream}     ${stream}
    set suite variable    ${TargetStream}        ${stream}
    Set Suite Variable    ${OldCommissionSCF}    ${CFGFILE_PATH}/OldCommissionSCF.xml
#    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479']['LoopTimeout']    default_value=30
#    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479']['LoopTimeoutForSWUpdate']    default_value=90
#    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_IA_15']['UpdateByYAFT']    default_value=false

    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_HA_KPI51']['RF_reset_times']      default_value=5
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_HA_KPI51']['ru_index']            default_value=1
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_HA_KPI51']['KPI51_AVG']           default_value=360    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_HA_KPI51']['KPI51_MAX']           default_value=432    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_HA_KPI51']['KPI51_AVG_ADJ']       default_value=0      is_digit=True

    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_HA_KPI1a']['WebUI_reset_times']   default_value=5
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_HA_KPI1a']['KPI1a_AVG']           default_value=450    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_HA_KPI1a']['KPI1a_MAX']           default_value=540    is_digit=True

    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_IA_KPI2d']['SW_update_times']   default_value=1      is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_IA_KPI2d']['KPI2d_MAX']         default_value=864    is_digit=True

    Basic.CheckVariableValid    var=CASE_INPUT_CB005845['TC60']['lock_unlock_retry_times']         default_value=5
    Basic.CheckVariableValid    var=CASE_INPUT_CB005845['ue_index']                    default_value=0
    Basic.CheckVariableValid    var=CASE_INPUT_CB005845['apn']                         default_value=wap1nokiacom
    Basic.CheckVariableValid    var=CASE_INPUT_CB005845['ue_mode']                     default_value=SA
    Basic.CheckVariableValid    var=CASE_INPUT_CB005845['CASE_24']['DL']               default_value=800
    Basic.CheckVariableValid    var=CASE_INPUT_CB005845['CASE_24']['UL']               default_value=100
    Basic.CheckVariableValid    var=CASE_INPUT_CB005845['CASE_24']['Check_TP']         default_value=0.5
    Basic.CheckVariableValid    var=CASE_INPUT_CB005845['CASE_24']['duration']         default_value=30

    KW.CaseStatusInit    retry_times=${100}
    ${CurrentStreamSCF}   COAM_Admin.BackupSCF
    Set Suite Variable    ${CurrentStreamSCF}     ${CurrentStreamSCF}

KW.AdaptCaseInput
    Basic.CheckVariableValid    var=CB005845['DeltaSCFCellNumber']    default_value=None
    Basic.CheckVariableValid    var=CB005845['CellType']    default_value=SA
    Basic.CheckVariableValid    var=TCCB005845_TC11['ru_index']     default_value=${1}
    Basic.CheckVariableValid    var=TCCB005845_TC14['ru_index']     default_value=${1}
    Basic.CheckVariableValid    var=TCCB005845_TC16['with_call']    default_value=${False}
    Basic.CheckVariableValid    var=TCCB005845_TC16['with_peak']    default_value=${False}
    Basic.CheckVariableValid    var=TCCB005845_TC17['with_call']    default_value=${True}
    Basic.CheckVariableValid    var=TCCB005845_TC18['addition_deletion_cell']       default_value=${1}
    Basic.CheckVariableValid    var=TCCB005845_TC18['addition_deletion_cellgrp']    default_value=${0}
    Basic.CheckVariableValid    var=TCCB005845_TC19['cell_id']     default_value=${1}
    Basic.CheckVariableValid    var=TCCB005845_TC20['ru_index']    default_value=${1}
    Basic.CheckVariableValid    var=TCCB005845_TC21['ru_index']    default_value=${1}
    Basic.CheckVariableValid    var=TCCB005845_TC22['ru_index']    default_value=${1}
    Basic.CheckVariableValid    var=TCCB005845_TC22['Tdanger_target']    default_value=30.0
    Basic.CheckVariableValid    var=TCCB005845_TC23['cell_id']     default_value=${1}
    Basic.CheckVariableValid    var=TCCB005845_TC24['band']        default_value=${71}
    Basic.CheckVariableValid    var=TCCB005845_TC24['ru_index']    default_value=${1}
    Basic.CheckVariableValid    var=TCCB005845_TC24['cell_id']     default_value=${1}
    Basic.CheckVariableValid    var=TCCB005845_TC37['ru_index']    default_value=${1}
    Basic.CheckVariableValid    var=TCCB005845_TC39['ue_index']    default_value=${0}
    Basic.CheckVariableValid    var=TCCB005845_TC47['frame_structure']    default_value=${1}
    Basic.CheckVariableValid    var=TCCB005845_TC47['ru_index']    default_value=${1}
    Basic.CheckVariableValid    var=TCCB005845_TC47['cell_id']     default_value=${1}
    Basic.CheckVariableValid    var=TCCB005845_TC47['ue_num_each_call']    default_value=${1}
    Basic.CheckVariableValid    var=TCCB005845_TC47['random_access']    default_value=${False}
    Basic.CheckVariableValid    var=TCCB005845_TC48['cell_band_frame_structure_list']    default_value=${1}
    Basic.CheckVariableValid    var=TCCB005845_TC48['cell_id']    default_value=${1}
    Basic.CheckVariableValid    var=TCCB005845_TC48['ue_num_each_call']    default_value=${1}
    Basic.CheckVariableValid    var=TCCB005845_TC48['random_access']    default_value=${False}
#COMMON SISO SETUP AND TEARDOWM
SISO Suite Setup
    log to console    \n***SISO Coam Suite Setup***
#    Run Keyword If    '${testline_name}'!='null'    UTECloud.ForceAdaptCommissionFiles
#    ...    ELSE     UTECloud.AdaptCommissionFiles
    UTECloud.ForceAdaptCommissionFiles
    TestSuite.Start
    KW.AdaptCaseInput
    KW.CaseSetupForOAMKPI
    set suite variable    ${testline_scf}   ${CurrentStreamSCF}
    set suite variable    ${Case_SCF_Path}    ${testline_scf}
#    Get TestLine SCF
    ${res}    Run Keyword And Ignore error    gNB.GenerateTestLineSCFs      vstring=${TargetBTSVersion}
    run keyword if    '${res[0]}'=='PASS'
    ...    Commission    scf_file=${LOG_PATH}/TestLineSCF${TLSCF_CELL_NUMs[0]}Cell.xml
    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    set suite variable      ${Active_SW_version}
    @{SW1}    string.split string    string=${Active_SW_version}    separator=_
    ${Branch_version}     convert to string    ${SW1}[-5]
    set suite variable    ${Branch_version}
    ${gNb_CuType}   Get gNB CU type
    set suite variable      ${gNb_CuType}
    Generate suite log path
    set suite variable      ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ${mrbtsID}    ${nrbtsID}   Get mrbtsID and nrbtsID via SCF for gNB    scf_path=${testline_scf}
    log to console  MRBTS_ID:${mrbtsID}, NRBTS_ID:${nrbtsID}
    set suite variable  ${mrbtsID}
    set suite variable  ${nrbtsID}

SISO Suite Setup AWHNA
    log to console    \n***SISO Coam Suite Setup***
#    Run Keyword If    '${testline_name}'!='null'    UTECloud.ForceAdaptCommissionFiles
#    ...    ELSE     UTECloud.AdaptCommissionFiles
    UTECloud.ForceAdaptCommissionFiles
    TestSuite.Start
    KW.AdaptCaseInput
    KW.CaseSetupForOAMKPI
    set suite variable    ${testline_scf}   ${CurrentStreamSCF}
    set suite variable    ${Case_SCF_Path}    ${testline_scf}
#    Get TestLine SCF
    ${res}    Run Keyword And Ignore error    gNB.GenerateTestLineSCFs      vstring=${TargetBTSVersion}
    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    set suite variable      ${Active_SW_version}
    @{SW1}    string.split string    string=${Active_SW_version}    separator=_
    ${Branch_version}     convert to string    ${SW1}[-5]
    set suite variable    ${Branch_version}
    ${gNb_CuType}   Get gNB CU type
    set suite variable      ${gNb_CuType}
    Generate suite log path
    set suite variable      ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ${mrbtsID}    ${nrbtsID}   Get mrbtsID and nrbtsID via SCF for gNB    scf_path=${testline_scf}
    log to console  MRBTS_ID:${mrbtsID}, NRBTS_ID:${nrbtsID}
    set suite variable  ${mrbtsID}
    set suite variable  ${nrbtsID}
    run keyword if    '${res[0]}'=='PASS' and '${Branch_version}'=='24R2'
    ...    Commission    scf_file=${LOG_PATH}/TestLineSCF${TLSCF_CELL_NUMs[0]}Cell.xml

SISO Suite Teardown
    log to console    \n***SISO Coam Suite Teardown***
    KW.commission_Base_SCF    scf1=${CFGFILE_PATH}/IWK_TL_BASE_SCF_NR.xml    scf2=${CFGFILE_PATH}/SCF_SBTS00.xml
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=nr
#    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
#    ${ru_status}    Run Keyword And Return Status    COAM Check GNB RU status
#    ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair
#    Run Keyword If    ${ru_status}==${False} or ${cell_status}==${False}
#    ...    Commission
#    Run Keyword And Ignore Error    COAM Teardown gnb connections
#    Run Keyword And Ignore Error    process.Terminate All Processes    kill=True

SISO Test Setup
    log to console    \n***SISO Coam Test Setup***
    log to console    Active_SW_version:${Active_SW_version}
    Generate test case log path
    ${time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    set test variable  ${TS_CASE_LOG_PATH}    ${TS_CASE_LOG_PATH}/${time_stamp}/
    create directory   ${TS_CASE_LOG_PATH}
    Set Test Variable    ${SAVE LOG DIRECTORY}    ${TS_CASE_LOG_PATH}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ${ru_status}    Run Keyword And Return Status    COAM Check GNB RU status
    ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair
    Run Keyword If    ${ru_status}==${False} or ${cell_status}==${False}    Fail    TEST
#    ...    Commission
    Start Btslog With Path Check
    Run Keyword And Ignore Error    selenium.close_browser

SISO Test Teardown
    log to console    \n***SISO Coam Test Teardown***
    Connect to gnb coam via ssl
#    ${ru_status}   run keyword and ignore error   COAM Check GNB RU status
#    log to console  RU status: ${ru_status}
#    ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair
#    should be true    ${cell_status}
#    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=@{ALLOWED_FAULT}
#    should be true    ${alarm_status}
#    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
#    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
    ${rc}    ${output} =    Run and Return RC and Output    ps -ef | grep ${btslog_dir} | grep -v grep
    run keyword if    '${btslog_dir}'!='none' and ${rc}==${0}    Stop Btslog Collect    target_dir=${SAVE LOG DIRECTORY}
    run keyword if test failed     gNB.CollectSnapshot
    COAM Teardown gnb connections
    CI_interface.Common Case Teardown

Get TestLine SCF
    Log    get test line scf from golden scf
    set suite variable     ${testline_scf}      ${CURDIR}/${testline_name}_scf.xml
    UTECloud.ForceAdaptCommissionFiles
    KW.AdaptCaseInput
    GNB.FormatBTSID
    ${res}    run keyword and ignore error    should not be equal  '${CB005845['DeltaSCFCellNumber']}'  'None'
    ${scffile}    run keyword if    '${res[0]}'!='FAIL'    gNB.Generate TL SCF
    ...    GoldenSCF_PATH=${GoldenSCF_PATH}    TLDelta_PATH=${CFGFILE_PATH}
    ...    TestLineSCF_cell_num=${CB005845['DeltaSCFCellNumber']}
    ...    cell_type=${CB005845['CellType']}    MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
    run keyword if    '${res[0]}'!='FAIL'    run keyword and ignore error    gNB.Commission
    ...    scf_file=${scffile}    timeout=${1800}
    run keyword if    '${res[0]}'!='FAIL'    Check all cells Should Be On Air
    run keyword if    '${res[0]}'!='FAIL'    set suite variable    ${testline_scf}    ${scffile}
    set suite variable      ${Golden_SCF_Path}     ${testline_scf}

Commission
    [Arguments]    ${scf_file}=${testline_scf}
    COAM_Admin.commission    scf_file=${scf_file}
    wait until keyword succeeds   10x   2min  COAM_Admin.VerifyCellOnAir

General_SiSo_eCPRI_synchronization_status_NIDD_parameters
    [Arguments]    ${parameters_list}=parameters_list   ${local_dir}=${OUTPUT_DIR}   ${file_name}=full_commission.xml
    ...   ${connection}=GNB_OAM
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'
    coam.get_current_scf_file   local_dir_path=${local_dir}   file_name=${file_name}   connection=${connection}   timeout=30
    ${xml}   ParseXML.Parse XML   ${OUTPUT_DIR}/${file_name}
    FOR   ${item}   IN   @{parameters_list}
       ${class_name}   Set Variable   ${item['class_name']}
       ${parameter}   Set Variable   ${item['parameter']}
    run Keyword And continue on failure    ParseXML.Element Should Exist
    ...   ${xml}   cmData/managedObject[@class="${class_name}"]/p[@name="${parameter}"]
    END
    Selenium Logout And Close Browser

TC.60_General_SiSo_RU_lock_unlock
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] To verify RMOD lock/ unlock functionality
    ...      during normal operation (OnAir state).
    ...    *******************
    ...    History of changes
    ...        2023/11/3 ShiTaotao update: execute all RUs lock and unlock
    Du login page via webUI
    ${ru_index_list}    Get All RU Index
    FOR   ${ru_index}   IN   @{ru_index_list}
        Perform RU Lock    ru_index=${ru_index}
        Wait Until Keyword Succeeds    5min    30s    RU Should Be Locked    ru_index=${ru_index}
    END
    FOR   ${ru_index}   IN   @{ru_index_list}
        Perform RU Unlock    ru_index=${ru_index}
        Wait Until Keyword Succeeds    5min    30s    RU Should Be Unlocked    ru_index=${ru_index}
    END
    Wait Until Keyword Succeeds    10min    10s     Du Check cell on air via WebUI

KW.UnblockAllCells
    ${BTSInfo}=     COAM_Admin.GetBTSInfo
    COAM_WebEM.Login
    FOR    ${CELL}   IN    @{BTSInfo['cells']['nr']}
        @{RMODsName}=  Create List
        ${cell_config}=    Split String From Right    ${CELL['id']['configuration']}     /
        ${nrcell}   Set Variable     ${cell_config[-1]}
        ${tmp_cell}=    Split String From Right    ${nrcell}     -
        ${CELL_INDEX}   Set Variable     ${tmp_cell[-1]}
        ${cell_info}    selenium_coam.get_cell_info    cell_idx=${CELL_INDEX}
        run keyword if    '${cell_info['Status']['Blocking state']}'=="Blocked"
        ...    selenium_sbts.unblock_cell    cell_idx=${CELL_INDEX}
        sleep   10s
    END
    COAM_WebEM.Logout

IWK_Commission
    [Arguments]     ${scf}
    COAM_Admin.Login    alias=IWK_Commission
    ${version}    COAM_Admin.GetActiveSoftwareVersion
    ${longStreamPrefix}    ${fullVersion}    Basic.GetStreamAndVersion    vstring=${version}
    ${shortStreamPrefix}    Basic.GetSBTSStreamPrefix    vstring=${version}
    set suite variable     ${shortStreamPrefix}
#    ${shortStreamPrefix}    Set Variable If    ${longStreamPrefix.count('ENB_9999')}>0    SBTS00    ${shortStreamPrefix}
    run keyword if    ${longStreamPrefix.count('ENB_9999')}>0   COAM_Admin.commission  scf_file=${scf}
    COAM_Admin.Logout  connection=IWK_Commission
