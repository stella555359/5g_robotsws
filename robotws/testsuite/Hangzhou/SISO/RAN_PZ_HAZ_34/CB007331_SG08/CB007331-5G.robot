*** Settings ***
Suite Setup    Run keywords    SISO Coam Suite Setup    AND    Get PA Ports For All RUs    AND    Get PA Port For Subcells
Suite Teardown    run keywords    Connect to gnb coam via ssl    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}    AND
...    run keyword and ignore error    COAM Teardown gnb connections    AND    SISO Coam Suite Teardown
Test Setup    SISO Coam Test Setup
Test Teardown    run keywords    Run keyword and ignore error     Check ERR Or WRN From Syslog    sys_logs_path=/tmp/btslog2/
...    UTE_logs_path=${UTE_logs_path}    base_file=${Base_ERR_WRN_csv_path}    Expected_ERR_WRN_deviation=0.1      Delete_old_ERR_WRN=15
...    Fail_Case=${False}    Clear_log=${False}    FilesSystem=/dev/vda2      Max_used_space_ratio=0.85    AND
...    SISO Coam Test Teardown
Test Timeout         24h

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource     Resources/CB007331_common_keyword.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB007331_SG08/Resources/CNI-88795_common_keyword.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB008990/Resources/CB008990_common_keyword.robot
Resource     Resources/CB008434_common_keyword.robot
Resource     Resources/CB009104_common_keyword.robot
Variables    TestData/variable_88795.py
Variables    TestData/variable_7331.py
Variables    TestData/variable_8434.py
Variables    TestData/variable_9104.py
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008392-AZQF-SG8/Resources/CB008392-AZQF-keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot

Documentation
...    Author:jiangjing lin
...    contact:jiangjing/lin@nokia-sbell.com
...    squad group:SG_08
...    Feature CB007331 in SBTS00 program

Force Tags    RAN_5G_TDD    5G_RAN_TDD    master_classicalbts_all    RAN_5G    5G_RAN    STATE_SW_UPLOADED
...    PY36
...    SBTS00    CLOUD_5G_CLASSICAL_ANDROID_SA_ASILL_ABIOB1_2XAZQF    SBTS22R3    SBTS22R4    CRT_22R4    CRT_23R1

*** Variables ***
@{bandlist_30M}    30M    30M    30M
@{bandlist_40M}    40M    40M    40M
@{bandlist_50M}    50M    50M    50M
@{framestructlist_1116}    1116_0ms_GP1    1116_0ms_GP1    1116_0ms_GP1
@{framestructlist_1070}    1070_GP1    1070_GP1    1070_GP1
@{framestructlist_1208}    1208_GP1    1208_GP1    1208_GP1
@{cell_id}    ${1}
@{bandlist_60M}    60M    60M    60M
${PA_CALL_VALUE_7331}    ${15}
${PA_CALL_VALUE_9104}    ${20}
@{band}    60M_config1
@{bandlist_80M}    80M
@{framestructlist_80M}    1116_0ms_GP1

*** Test Cases ***
# CB007331-5G-A 40M
[1]CB007331-5G-A_3_General_SiSo_RU_module_reset_from_GUI_AZQF_40M
    [Tags]    CRT_UTE
    Init PA Ports Value For All RUs    value=${PA_CALL_VALUE_7331}
    Set LTE PA for 40M configuration
    Commission According Band And FrameStruct    bandlist=${bandlist_40M}    framestructlist=${framestructlist_1116}
    General_SiSo_RU_module_reset_from_GUI_AZQF    tput_self_define=${tput_40M_conf1}    cell_id=${cell_id}

[1]CB007331-5G-A_9_General_SiSo_E2E_system_setup_with_data_transfer_conducted_max_MCS_5GC001070_SA_call_40M
    [Tags]    CRT_UTE
    Init PA Ports Value For All RUs    value=${PA_CALL_VALUE_7331}
    Set LTE PA for 40M configuration
    Commission According Band And FrameStruct    bandlist=${bandlist_40M}    framestructlist=${framestructlist_1116}
    General_SiSo_E2E_system_setup_with_data_transfer_conducted_max_MCS_Concurrent    tput_self_define=${tput_40M_conf1}

[1]CB007331-5G-A_5_General_SiSo_Cell_block_and_unblock_AZQF_40M
    [Tags]    CRT_UTE
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _NR_LTE_50_40.xml
    ${scf_name}      set variable    ${SCF_upload.split("/")[-1]}
    COAM Commission with scf file    scf_file_path=${SCF_upload}    timeout=${600}
    Wait until keyword succeeds    5min    5s    verify all cells should be onair
    Get lnbtsID via SCF
    General_SISO_Cell_Block_Unblock_SG08_Config    mrbtsId=${mrbtsID}    nrbtsId=${nrbtsID}    lnBtsId=${lnBtsId}
    ...    tput_define_nr=${tput_50_40_nr}    tput_define_lte=${tput_50_40_lte}    scf_name=${scf_name}    process_num_ul=${5}
    ...    target_avg_percent_nr=${0.8}    min_percent_nr=${0.5}    target_avg_percent_lte=${0.8}    min_percent_lte=${0.1}    duration=${60}

[1][2.0] Manual_SiSo_SM_NR_RAT_reset
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _NR_LTE_50_40.xml
    ${scf_name}      set variable    ${SCF_upload.split("/")[-1]}
    COAM Commission with scf file    scf_file_path=${SCF_upload}    timeout=${600}
    Wait until keyword succeeds    5min    5s    verify all cells should be onair
    Get lnbtsID via SCF
    General_RAT_RESET_SG08_Config    mrbtsId=${mrbtsID}    nrbtsId=${nrbtsID}    lnBtsId=${lnBtsId}
    ...    tput_define_nr=${tput_50_40_nr}    tput_define_lte=${tput_50_40_lte}    scf_name=${scf_name}    process_num_ul=${5}
    ...    target_avg_percent_nr=${0.8}    min_percent_nr=${0.5}    target_avg_percent_lte=${0.8}    min_percent_lte=${0.1}    duration=${60}

# CB007331-5G-B 60M
[1][1.0] Manual_SiSo_SM_BTS_Site_Reset
    [Tags]    CRT_UTE
    Init PA Ports Value For All RUs    value=${PA_CALL_VALUE_7331}
    Set LTE PA for 60M configuration
    Commission According Band And FrameStruct    bandlist=${bandlist_60M}    framestructlist=${framestructlist_1116}
    Manual_SiSo_SM_BTS_Site_Reset    tput_self_define=${tput_60M}

[1]CB007331-5G-B_9_General_SiSo_E2E_system_setup_with_data_transfer_conducted_max_MCS_5GC001208_SA_call_60M
    [Tags]    CRT_UTE
    Init PA Ports Value For All RUs    value=${PA_CALL_VALUE_7331}
    Set LTE PA for 60M configuration
    Commission According Band And FrameStruct    bandlist=${bandlist_60M}    framestructlist=${framestructlist_1116}
    General_SiSo_E2E_system_setup_with_data_transfer_conducted_max_MCS_Concurrent    tput_self_define=${tput_60M}

[1]CB007331-5G-B_4_General_SiSo_RU_lock_unlock_AZQF_60M
    [Tags]    CRT_UTE
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _NR_LTE_50_40.xml
    ${scf_name}      set variable    ${SCF_upload.split("/")[-1]}
    COAM Commission with scf file    scf_file_path=${SCF_upload}    timeout=${600}
    Wait until keyword succeeds    5min    5s    verify all cells should be onair
    Get lnbtsID via SCF
    General_SISO_RU_Lock_Unlock_SG08_Config    mrbtsId=${mrbtsID}    nrbtsId=${nrbtsID}    lnBtsId=${lnBtsId}
    ...    tput_define_nr=${tput_50_40_nr}    tput_define_lte=${tput_50_40_lte}    scf_name=${scf_name}    process_num_ul=${5}
    ...    target_avg_percent_nr=${0.8}    min_percent_nr=${0.5}    target_avg_percent_lte=${0.8}    min_percent_lte=${0.1}    duration=${60}

[1]CB007331-5G-B_5_General_SiSo_Cell_block_and_unblock_AZQF_60M
    [Tags]    CRT_UTE
    Init PA Ports Value For All RUs    value=${PA_CALL_VALUE_7331}
    Set LTE PA for 60M configuration
    Commission According Band And FrameStruct    bandlist=${bandlist_60M}    framestructlist=${framestructlist_1116}
    General_SiSo_Cell_block_and_unblock_AZQF_60M    tput_self_define=${tput_60M}    cell_id=${cell_id}

# CB007331-5G-C 80M
[1]CB007331-5G-C_8_General_SiSo_E2E_system_setup_with_data_transfer_conducted_max_MCS_5GC001116_SA_call_80M
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_UTE
    Init PA Ports Value For All RUs    value=${PA_CALL_VALUE_7331}
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _PureNR_80_60_30.xml
    COAM Commission with scf file    scf_file_path=${SCF_upload}    timeout=${600}
    General_SiSo_E2E_system_setup_with_data_transfer_conducted_max_MCS    tput_self_define=${tput_80M}    cell_id=${cell_id}

# 5GC000956
[1]5GC000956_ABIO_Initiate_RF_Diagnostic_test_from_WebEM_normal_mode_without_L3_call
    [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3
    Commission SCF With Specific Band If Needed    band=${band}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type=${gNb_CuType}
    General_SiSo_Initiate_RF_diagnostic_test_from_BTS_Element_Manager_without_L3Call_AZQF    low_RSSI=-160   low_RTWP=-160

[1]5GC000956_ABIO_Initiate_RF_Diagnostic_test_from_WebEM_normal_mode_with_L3_call
    [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3    CRT_UTE
    Commission SCF With Specific Band If Needed    band=${band}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type=${gNb_CuType}
    General_SiSo_Initiate_RF_diagnostic_test_from_BTS_Element_Manager_with_L3Call_AZQF    tput_info=${tput_956}

# CB008434
[1]General_SiSo_SuperCell_activation_deactivation
    [Tags]    CRT_UTE
    Set Whole Attenuator Ports    attenuator_out_ports=${PA_OUT_PORTS}    attenuator_rows=${PA_ROWS}
    CB008434_Super cell Setup and delete

[1]General_SiSo_SuperCell_Subcell_failure_statemangement
    [Tags]    CRT_UTE
    Set Whole Attenuator Ports    attenuator_out_ports=${PA_OUT_PORTS}    attenuator_rows=${PA_ROWS}
    CB008434_Common_SiSo_State Management_Sub-cell failure in super cell configuration

[1]General_SiSo_SuperCell_Reconfiguration
    [Tags]    CRT_UTE
    Set Whole Attenuator Ports    attenuator_out_ports=${PA_OUT_PORTS}    attenuator_rows=${PA_ROWS}
    CB008434_Super_Cell_Reconfiguration

[1][2.0] Manual_SiSo_SM_RF_Module_lock_unlock
    [Tags]    CRT_UTE
    Set Whole Attenuator Ports    attenuator_out_ports=${PA_OUT_PORTS}    attenuator_rows=${PA_ROWS}
    Manual_SiSo_SM_RF_Module_lock_unlock    tput_self_define=${tput_cells}

[1][2.0] General_SiSo_Cell_block_and_unblock
    [Tags]    CRT_UTE
    Set Whole Attenuator Ports    attenuator_out_ports=${PA_OUT_PORTS}    attenuator_rows=${PA_ROWS}
    CB008434_General_SiSo_Cell_block_and_unblock    tput_self_define=${tput_cells}

[1][1.0] OAM_KPI_61a_SiSo_Auto_BTS_site_reset
    [Tags]    CRT_UTE
    Auto_BTS_site_reset_kpi

# CB009104 30M
[1]CB009104-5G-A_5_General_SiSo_Cell_block_and_unblock_AZQF
    [Tags]    CRT_UTE
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _PureNR_80_60_30.xml
    ${scf_name}      set variable    ${SCF_upload.split("/")[-1]}
    COAM Commission with scf file    scf_file_path=${SCF_upload}    timeout=${600}
    Wait until keyword succeeds    5min    5s    verify all cells should be onair
    General_SISO_Cell_Block_Unblock_SG08_Config    mrbtsId=${mrbtsID}    nrbtsId=${nrbtsID}
    ...    tput_define_nr=${tput_80_60_30_nr}    tput_define_lte=${None}    scf_name=${scf_name}    process_num_ul=${5}
    ...    target_avg_percent_nr=${0.8}    min_percent_nr=${0.5}    target_avg_percent_lte=${0.8}    min_percent_lte=${0.1}    duration=${60}

[1]CB009104-5G-A_2_General_SiSo_RF_module_power_reset
    [Tags]    CRT_UTE
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _PureNR_80_60_30.xml
    ${scf_name}      set variable    ${SCF_upload.split("/")[-1]}
    COAM Commission with scf file    scf_file_path=${SCF_upload}    timeout=${600}
    Wait until keyword succeeds    5min    5s    verify all cells should be onair
    General_SISO_RF_Module_Power_Reset_SG08_Config    mrbtsId=${mrbtsID}    nrbtsId=${nrbtsID}
    ...    tput_define_nr=${tput_80_60_30_nr}    tput_define_lte=${None}    scf_name=${scf_name}    process_num_ul=${5}
    ...    target_avg_percent_nr=${0.8}    min_percent_nr=${0.5}    target_avg_percent_lte=${0.8}    min_percent_lte=${0.1}    duration=${60}

[1]CB009104-5G-A_9_General_SiSo_E2E_system_setup_with_data_transfer_conducted_basic_MCS_5GC001070_SA_call
    [Tags]    CRT_UTE
    Init PA Ports Value For All RUs    value=${PA_CALL_VALUE_9104}
    Commission According Band And FrameStruct    bandlist=${bandlist_30M}    framestructlist=${framestructlist_1070}
    General_SiSo_E2E_system_setup_with_data_transfer_conducted_max_MCS_Concurrent_9104    tput_self_define=${tput_30M}    cell_id=${cell_id}

# CB009104 50M
[1]CB009104-5G-B_4_General_SiSo_RU_lock_unlock_AZQF
    [Tags]    CRT_UTE
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _PureNR_80_60_30.xml
    ${scf_name}      set variable    ${SCF_upload.split("/")[-1]}
    COAM Commission with scf file    scf_file_path=${SCF_upload}    timeout=${600}
    Wait until keyword succeeds    5min    5s    verify all cells should be onair
    General_SISO_RU_Lock_Unlock_SG08_Config    mrbtsId=${mrbtsID}    nrbtsId=${nrbtsID}
    ...    tput_define_nr=${tput_80_60_30_nr}    tput_define_lte=${None}    scf_name=${scf_name}
    ...    process_num_ul=${5}    target_avg_percent_nr=${0.8}    min_percent_nr=${0.5}    target_avg_percent_lte=${0.8}
    ...    min_percent_lte=${0.1}    duration=${60}

[1]CB009104-5G-B_9_General_SiSo_E2E_system_setup_with_data_transfer_conducted_basic_MCS_5GC001208_SA_call
    [Tags]    CRT_UTE
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _PureNR_80_60_30.xml
    ${scf_name}      set variable    ${SCF_upload.split("/")[-1]}
    COAM Commission with scf file    scf_file_path=${SCF_upload}    timeout=${600}
    Wait until keyword succeeds    5min    5s    verify all cells should be onair
    General_DATA_transfer_SG08_Config    mrbtsId=${mrbtsID}    nrbtsId=${nrbtsID}
    ...    tput_define_nr=${tput_80_60_30_RU2_nr}    tput_define_lte=${None}    scf_name=${scf_name}
    ...    process_num_ul=${5}target_avg_percent_nr=${0.95}    min_percent_nr=${0.85}    target_avg_percent_lte=${0.95}
    ...    min_percent_lte=${0.1}    duration=${300}

# CB007957
[1]CB007957-A_SISO_1_Power_consumption_checking_with_activate_micro-DTx_function_under_idle_load
    [Tags]    CRT_UTE
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _NR_LTE_50_40.xml
    Set LTE PA for 60M configuration
    COAM Commission with scf file    scf_file_path=${SCF_upload}    timeout=${600}
    ${mrbtsID_enb}    ${lnbtsID}    Get mrbtsID and lnbtsID via SCF    scf_path=${SCF_upload}
    set suite variable  ${lnbtsID}
    CB007957-A_SISO_1_Power_consumption_checking_with_activate_micro-DTx_function_under_idle_load    interval=15min

[1]CB007957-A_SISO_4_Manual_SiSo_CALL_LTE_data_call_with_activate_micro-DTx_function_2S_2CC
    [Tags]    CRT_UTE
    ${SCF_CB007957}    Replace String    ${Golden_SCF_Path}    .xml    _60M_config1.xml
    Set LTE PA for 60M configuration
    Commissioning SCF And Check On Air    scf_path=${SCF_CB007957}
    ${mrbtsID_enb}    ${lnbtsID}    Get mrbtsID and lnbtsID via SCF    scf_path=${SCF_CB007957}
    set suite variable  ${lnbtsID}
    CB007957-A_SISO_4_Manual_SiSo_CALL_LTE_data_call_with_activate_micro-DTx_function_2S_2CC

[1]CB008990-SR-A_RF5.1_Kylin_01_Manual_General_SiSo_RF_alarms_with_recovery_DFE-DFE_link_fault_activation
    AlarmWatchdog.add_allow_alarms    fault_id=1904
    DFE-DFE_link_fault_activation
    AlarmWatchdog.remove_allow_alarms    fault_id=1904

[1]CB008990-SR-A_RF5.1_Kylin_03_Manual_General_SiSo_RF_alarms_with_recovery_ DFE no TX Data fault activation
    AlarmWatchdog.add_allow_alarms    fault_id=1981
    DFE no TX Data fault activation
    AlarmWatchdog.remove_allow_alarms    fault_id=1981

[1]CB008392-A_15_View_Power_Saving_Performance_Management_Counters
    ${SCF_CB008392}    Replace String    ${Golden_SCF_Path}    .xml    _8392.xml
    Commissioning SCF And Check On Air    scf_path=${SCF_CB008392}
    CB008392-A_15_View_Power_Saving_Performance_Management_Counters

[1]CB008392-A Cell degraded due to cell and BTS level alarm
    ${SCF_CB008392}    Replace String    ${Golden_SCF_Path}    .xml    _8392.xml
    Commissioning SCF And Check On Air    scf_path=${SCF_CB008392}
    CB008392-A Cell degraded due to cell and BTS level alarm

[1]CB008392_A_5_Determine_Cell_TX_Path_Reduction_Power_Saving_Mode
    ${SCF_CB008392}    Replace String    ${Golden_SCF_Path}    .xml    _8392.xml
    ${PA}    attenuator.setup_attenuator    attenuator=${tl.attenuators[0]}
    FOR    ${port}    IN RANGE    ${1}    ${257}
        attenuator.set_attenuation    port=${port}    value=${127}    attenuator_device=${PA}
    END
    Set PA Value For Cell    cell_type=nr    cell_id=${3}    pa_call_default=${10}
    Commissioning SCF And Check On Air    scf_path=${SCF_CB008392}
    CB008392_A_5_Determine_Cell_TX_Path_Reduction_Power_Saving_Mode
