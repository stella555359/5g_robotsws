*** Settings ***
Resource    ./Resource/5GC001881_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Library     taf.rfrl.common_resources.python.SWConfig    WITH NAME    SWConfig
Variables    ./Resource/variables.py
Documentation
...   author: feipeng.qian
...   contact: feipeng.qian@nokia-sbell.com
...   squad group: SG_03
...   Feature 5GC001881 in 5G20A program

Force Tags      5G_SISO    9.1800    10.1800    CRT_21A    CRT_20B    CRT_TRUNK    RAN_5G    RAN_5G_TDD
...    PY36
...    CRT_UTE    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ANDROID_ASIKL_ABILB1_AWHHI_ENB    SBTS00    5G_RAN_TDD

Suite Setup    Run Keywords
...    robot_common_operations.Common Suite Setup    AND
...    run keyword if   '${gnb_id}'=='${bts_id[0]}'    CI_interface.Common Suite Setup    AND
...    Pre Condition    AND
...    adjust the HBTE attenuation value    value_1=${0}    value_2=${0}    value_3=${0}    value_4=${0}    AND
...    adjust the enb HBTE attenuation value    value_1=${0}    value_2=${0}    AND
...    Prepare the enb dyntrig    AND
...    Common Case TestLine Setup    Is_Swconfig=True    swconfig_file=${SWCONFIG_DEFAULT_FILE_PATH}
...    swconfig_target_path=${TS_CASE_SWCONFIG_PATH}

Suite Teardown    Run Keywords
...    robot_common_operations.Common Suite Teardown    AND
...    Run Keyword If Any Tests Failed
...    Run Keyword And Ignore Error    Common Suite Teardown for COAM    AND
...    Run Keyword And Ignore Error    enb env recovery

*** Variables ***
&{fault_10}       faultId=${10}    source=RMOD_R-1    severity=Critical    # No connection to unit
&{fault_61524}    faultId=${61524}    source=SMOD_R-1    #faultId:SSH_ENABLED  source:RU1
&{fault_61652}    faultId=${61652}    source=SMOD_R-1    #faultId:R&D_SERVICE_PORT_ENABLED  source:RU1
&{fault_61649}    faultId=${61649}    source=SMOD_R-1    #faultId:LMP access via port 443  source:RU1
&{fault_7319}    faultId=${7319}    source=NRBTS     #faultId:EFaultId_X2LinkNotAvailableAl
&{fault_7300}    faultId=${7300}    source=NRBTS     #faultId:EFaultId_NoneX2LinkAvailableAl
&{fault_4476}    faultId=${4476}    #faultId:Increased BER detected on the optical connector
&{fault_4655}    faultId=${4655}    #Service account root access is enabled'
&{fault_4654}    faultId=${4654}
&{fault_61074}    faultId=${61074}
&{fault_4681}    faultId=${4681}
@{ALLOWED_FAULT_LIST}    &{fault_61524}    &{fault_61652}    &{fault_4476}    &{fault_61649}    &{fault_4655}
...    &{fault_4654}    &{fault_61074}    &{fault_4681}    &{fault_61649}
&{fault_1900}    faultId=${1900}   source=RMOD_R-1
&{fault_1807}    faultId=${1807}    #faultID:fault triggered out of nrarfcn range
${tl_scf_filename}    SCF_SBTS00.xml
${golden_scf_name}    ${tl_scf_filename}
@{ALLOWED_FAULT}    61652    61524    4655    4654    61074    4681    61649
${arfcn}    519000
${arfcn1}    517000
${arfcn2}    521000
${gnb_id}    ${tl.gnbs[0].instance_id}
@{bts_id}    356111    35911    36911
${702_RECOVERY_TIMEOUT}    15 min
${TS_CASE_LOG_PATH}      /opt/workspace/CIT/Master/Case_Logs/
@{allow_fault_list}    7311    7107    7523    4681

*** Test Cases ***
[1]5GC001881_B_20_General_SiSo_E2E_system_setup_with_data_transfer_conducted_4T2R_40M
    [Documentation]
    ...    This test scenario is used to verify the E2E data transfer functionality of RF in full-panel mode.
    [Tags]     classical    CRT_TRUNK    CRT_22R2    RAN_5G    RAN_5G_TDD    SBTS00    CRT_22R4    CRT_22R3
    [Timeout]    2 hour
    [Setup]
    robot_common_operations.Common Case Setup    allowed_faults_ids=7107,7523,4681
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    Prepare with COAM classical BTS cell onair    tl_scf_filename=${tl_scf_filename}
    Modify NIDD parameter    parameters_to_update=${Lock_gnb1_AMF1}
    Check the COAM gnb cell status onair
    Online delete NIDD parameter    parameters_to_delete=${PARAMETERS_TO_DELETE_B20_nsaDrbParam}
    Add NIDD parameter    parameters_to_add=${PARAMETERS_TO_UPDATE_B20_nsaDrbParam}
    Check the COAM gnb cell status onair
    ${cell1_id}=    run keyword if    '${gnb_id}'=='${btsid[0]}'    COAM Get nrcellid with lcrid    lcrid=${16383}
    ...    ELSE    COAM Get nrcellid with lcrid    lcrid=${1}
    ${list_of_cell_ids}    Create list    ${cell1_id}
    Precondition for Sansumg UE    ue_type=${ue_type}    ui_version=S21UI3.1
    Make huawei WR for avoid RLC-max-fail
    sleep    5s
    Common UE attach
    power_ue.Start traffic    ue_type=${ue_type}    direction=${ul_direction}
    ...    duration=${duration}   throughput=${ul_throughput}    iperf_port=${ue_ul_port}
    power_ue.Start traffic    ue_type=${ue_type}    direction=${dl_direction}    duration=${duration}
    ...    throughput=${dl_throughput}    iperf_port=${ue_dl_port}
    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=5m
    Power_ue.Check Tput    ue_type=${ue_type}    direction=UL    log=${log}   cells=${list_of_cell_ids}
    ...    target_throughput=${ul_expect_throughput}
    run keyword if   '${gnb_id}'=='${btsid[2]}'    Power_ue.Check Tput    ue_type=${ue_type}    direction=DL
    ...    log=${log}   cells=${list_of_cell_ids}    target_throughput=${dl_expect_throughput_22R1}
    ...    ELSE    Power_ue.Check Tput    ue_type=${ue_type}    direction=DL    log=${log}   cells=${list_of_cell_ids}
    ...    target_throughput=${dl_expect_throughput}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    iperf_port=${ue_ul_port}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    iperf_port=${ue_dl_port}
    sleep    300s
    power_ue.Start traffic    ue_type=${ue_type}    direction=${ul_direction}
    ...    duration=${duration}   throughput=${ul_throughput}    iperf_port=${ue_ul_port}
    power_ue.Start traffic    ue_type=${ue_type}    direction=${dl_direction}    duration=${duration}
    ...    throughput=${dl_throughput}    iperf_port=${ue_dl_port}
    sleep    12s
    run keyword if   '${gnb_id}'=='${btsid[2]}'
	...    UE.Check Both ULDL throughput for 40s    ue_type=${ue_type}     theory_ul_peak=${ul_expect_throughput}
    ...    theory_dl_peak=${dl_expect_throughput_22R1}    nr_cell_index=${1}
	...    ELSE
    ...    UE.Check Both ULDL throughput for 40s    ue_type=${ue_type}     theory_ul_peak=${ul_expect_throughput}
    ...    theory_dl_peak=${dl_expect_throughput}    nr_cell_index=${1}
    [Teardown]    Run keywords
    ...    robot_common_operations.Common Case Teardown    AND
    ...    Modify NIDD parameter    parameters_to_update=${Unlock_gnb1_AMF1}    AND
    ...    Run Keyword And Ignore Error    Common UE teardown    AND
    ...    Check hanging resource for gnb    gnb_ips=${gnb_ips}    ute_log_path=${ute_log_path}    AND
    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

#[1]5GC001881_B_09_General_SiSo_Cell_lock_and_unlock (under creation)
#    [Documentation]
#    ...    This case is used to verified cell lock and unlock
#    [Tags]     classical    CRT_TRUNK    CRT_22R2    RAN_5G    RAN_5G_TDD    SBTS00
#    [Timeout]    2 hour
#    [Setup]    robot_common_operations.Common Case Setup
#    Prepare with COAM classical BTS cell onair    tl_scf_filename=${tl_scf_filename}
#    Check the COAM gnb cell status onair
#    Run keyword if     '${gnb_id}'=='${btsid[0]}'    Online delete object    parameters_to_delete=${PARAMETERS_TO_UPDATE_B09_16383}
#    ...    ELSE    Online delete object    parameters_to_delete=${PARAMETERS_TO_UPDATE_B09_1}
#    Modify NIDD parameter    parameters_to_update=${PARAMETERS_TO_UPDATE_B09}
#    Check the COAM gnb cell status onair
#    Case preparation
#    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT_LIST}
#    cell lock unlock for gnbBts
#    ${cell1_id}=    run keyword if   '${gnb_id}'=='${btsid[0]}'    COAM Get nrcellid with lcrid    lcrid=${16383}
#    ...    ELSE    COAM Get nrcellid with lcrid    lcrid=${1}
#    power_ue.Prepare UE     ue_type=${ue_type}
#    wait until keyword succeeds    3X    10s    Common UE attach
#    power_ue.Start traffic    ue_type=${ue_type}    direction=${dl_direction}    duration=${duration}
#    ...    throughput=${dl_throughput}    iperf_port=${ue_dl_port}
#    wait until keyword succeeds    3X    30s    power_ue.Check throughput    ue_type=${ue_type}    direction=${dl_direction}
#    ...        cellid=${cell1_id}    throughput=${dl_expect_throughput1}
#    [Teardown]     Run key words
#    ...    robot_common_operations.Common Case Teardown    AND
#    ...    Run Keyword And Ignore Error    Case env recovery for cell lock    AND
#    ...    Run Keyword And Ignore Error    Common UE teardown    AND
#    ...    Check hanging resource for gnb    gnb_ips=${gnb_ips}    ute_log_path=${ute_log_path}    AND
#    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
#[1]5GC001881_B_10_General_SiSo_RU_block_unblock (under creation)
#   [Documentation]
#    ...    This case is used to verified RU block and unblock
#    ...             faultId=7319    EFaultId_X2LinkNotAvailableAl
#    ...             faultId=7300    EFaultId_NoneX2LinkAvailableAl
#    [Tags]     huawei    classical    CRT_TRUNK    CRT_22R2    RAN_5G    RAN_5G_TDD    SBTS00
#    [Timeout]    2 hour
#    [Setup]    robot_common_operations.Common Case Setup
#    Prepare with COAM classical BTS cell onair    tl_scf_filename=${tl_scf_filename}
#    Check the COAM gnb cell status onair
#    Run keyword if     '${gnb_id}'=='${btsid[0]}'    Online delete object    parameters_to_delete=${PARAMETERS_TO_UPDATE_B09_16383}
#    ...    ELSE    Online delete object    parameters_to_delete=${PARAMETERS_TO_UPDATE_B09_1}
#    Modify NIDD parameter    parameters_to_update=${PARAMETERS_TO_UPDATE_B09}
#    Check the COAM gnb cell status onair
#    Case preparation
#    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${ALLOWED_FAULT_LIST}
#    RU block unblock for gnbBts
#    ${cell1_id}=    run keyword if    '${gnb_id}'=='${btsid[0]}'    COAM Get nrcellid with lcrid    lcrid=${16383}
#    ...    ELSE    COAM Get nrcellid with lcrid    lcrid=${1}
#    power_ue.Prepare UE     ue_type=${ue_type}
#    wait until keyword succeeds    3X    30s    Common UE attach
#    power_ue.Start traffic    ue_type=${ue_type}    direction=${dl_direction}    duration=${duration}
#    ...    throughput=${dl_throughput}    iperf_port=${ue_dl_port}
#    sleep    30s
#    wait until keyword succeeds    3X    30s    power_ue.Check throughput    ue_type=${ue_type}    direction=${dl_direction}
#    ...        cellid=${cell1_id}    throughput=${dl_expect_throughput1}
#    [Teardown]   Run keywords
#    ...    robot_common_operations.Common Case Teardown    AND
#    ...    Run Keyword And Ignore Error    Case env recovery for RU lock    AND
#    ...    Run Keyword And Ignore Error    Common UE teardown    AND
#    ...    Check hanging resource for gnb    gnb_ips=${gnb_ips}    ute_log_path=${ute_log_path}    AND
#    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
#[1]5GC001881_A_14_General_SiSo_NR-ARFCN_check
#    [Documentation]
#    ...    This case is used to verified cell lock and unlock
#    [Tags]     classical    CRT_TRUNK    CRT_22R2    RAN_5G    RAN_5G_TDD    SBTS00
#    [Timeout]    2 hour
#    [Setup]    robot_common_operations.Common Case Setup
#    Prepare with COAM classical BTS cell onair    tl_scf_filename=${tl_scf_filename}
#    Check the COAM gnb cell status onair
#    Modify NIDD parameter    parameters_to_update=${PARAMETERS_TO_UPDATE_A14}
#    Check the COAM gnb cell status onair
#    Connect to gnb coam via ssl
#    ${nrarfcn_value}    Get parameter in SCF    para=nrarfcn    dist_value=NRBTS-${tl.gnbs[0].instance_id}/NRCELL-1
#    Should Be Equal     ${nrarfcn_value}   ${arfcn}
#    &{nrarfcn_param_min}    Create Dictionary    dist_name=NRBTS-${gnb_id}/NRCELL-1    parameter=nrarfcn    value=${arfcn1}
#    @{modify_param_min}    Create List    ${nrarfcn_param_min}
#    sleep    5s
#    COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_param_min}    timeout=600
#    COAM Wait for gnb ready and cell setup    timeout=15 min
#    &{nrarfcn_param_max}    Create Dictionary    dist_name=NRBTS-${gnb_id}/NRCELL-1    parameter=nrarfcn    value=${arfcn2}
#    @{modify_param_max}    Create List    ${nrarfcn_param_max}
#    sleep    5s
#    COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_param_max}    timeout=600
#    COAM Wait for gnb ready and cell setup    timeout=15 min
#    &{nrarfcn_param_exc}    Create Dictionary    dist_name=NRBTS-${gnb_id}/NRCELL-1    parameter=nrarfcn    value=${arfcn}
#    @{modify_param_exc}    Create List    ${nrarfcn_param_exc}
#    COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_param_exc}    timeout=600
#    COAM Wait for gnb ready and cell setup    timeout=15 min
#    wait until keyword succeeds    5min   1min        Check only default Fault Present
#    [Teardown]    Run key words
#    ...    robot_common_operations.Common Case Teardown    AND
#    ...    Run Keyword And Ignore Error    Case recovery    AND
#    ...    Check hanging resource for gnb    gnb_ips=${gnb_ips}    ute_log_path=${ute_log_path}    AND
#    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
#[1]5GC001881_B_37_General_SiSo_stability_with_L3Call
#    [Documentation]
#    ...    This test scenario is used to verify the E2E data transfer functionality of RF in full-panel mode.
#    [Tags]     classical    CRT_TRUNK    CRT_22R2    RAN_5G    RAN_5G_TDD    SBTS00
#    [Timeout]    8 hour
#    [Setup]    robot_common_operations.Common Case Setup
#    Prepare with COAM classical BTS cell onair    tl_scf_filename=${tl_scf_filename}
#    Check the COAM gnb cell status onair
#    Modify NIDD parameter    parameters_to_update=${PARAMETERS_TO_UPDATE_B37}
#    Online delete NIDD parameter    parameters_to_delete=${PARAMETERS_TO_UPDATE_B37_1}
#    Check COAM gnb classical start normally
#    Add NIDD parameter    parameters_to_add=${PARAMETERS_TO_UPDATE_B37_2}
#    Check the COAM gnb cell status onair
#    ${cell1_id}=    run keyword if    '${gnb_id}'=='${btsid[0]}'    COAM Get nrcellid with lcrid    lcrid=${16383}
#    ...    ELSE    COAM Get nrcellid with lcrid    lcrid=${1}
#    ${list_of_cell_ids}    Create list    ${cell1_id}
#    power_ue.Prepare UE     ue_type=${ue_type}
#    wait until keyword succeeds    3X    10s    Common UE attach
#    power_ue.Start traffic    ue_type=${ue_type}    direction=${dl_direction}    duration=${duration}
#    ...    throughput=${dl_throughput}    iperf_port=${ue_dl_port}
#    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=1m
#    Power_ue.Check Tput    ue_type=${ue_type}    direction=DL    log=${log}   cells=${list_of_cell_ids}
#    ...    target_throughput=${dl_expect_throughput1}
#    Common UE teardown
#    sleep    600s
#    ${cell1_id}=    run keyword if    '${gnb_id}'=='${btsid[0]}'    COAM Get nrcellid with lcrid    lcrid=${16383}
#    ...    ELSE    COAM Get nrcellid with lcrid    lcrid=${1}
#    ${list_of_cell_ids}    Create list    ${cell1_id}
#    wait until keyword succeeds    3X    10s    Common UE attach
#    power_ue.Start traffic    ue_type=${ue_type}    direction=${dl_direction}    duration=${duration}
#    ...    throughput=${dl_throughput}    iperf_port=${ue_dl_port}
#    sleep    30s
#    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=1m
#    Power_ue.Check Tput    ue_type=${ue_type}    direction=DL    log=${log}   cells=${list_of_cell_ids}
#    ...    target_throughput=${dl_expect_throughput1}
#    [Teardown]    Run keywords
#    ...    robot_common_operations.Common Case Teardown    AND
#    ...    Run Keyword And Ignore Error    Common UE teardown    AND
#    ...    Check hanging resource for gnb    gnb_ips=${gnb_ips}    ute_log_path=${ute_log_path}    AND
#    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

#[1]5GC000702_T_05_SiSo_Auto_RF_reset_success_rate_from_WebUI_AWHHF
#    [Documentation]    Author: Jack Zeng
#    ...                Description: The purpose of this test case is to verify success rate of Radio Unit reset activated from WebUI interface
#    [Tags]     classical    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_22R4
#    [Timeout]    3 hour
#    [Setup]    Common Case TestLine Setup    Is_Swconfig=True    swconfig_file=${SWCONFIG_PEAK_FILE_PATH}
#            ...    swconfig_target_path=${TS_CASE_SWCONFIG_PATH}    is_commission=True
#    robot_common_operations.Common Case Setup
#    ${cell1_id}=    run keyword if    '${gnb_id}'=='${btsid[0]}'    COAM Get nrcellid with lcrid    lcrid=${16383}
#    ...    ELSE    COAM Get nrcellid with lcrid    lcrid=${1}
#    ${list_of_cell_ids}    Create list    ${cell1_id}
#    power_ue.Prepare UE     ue_type=${ue_type}
#    wait until keyword succeeds    3X    10s    Common UE attach
#    power_ue.Start traffic    ue_type=${ue_type}    direction=${ul_direction}
#    ...    duration=${duration}   throughput=${ul_throughput}    iperf_port=${ue_ul_port}
#    power_ue.Start traffic    ue_type=${ue_type}    direction=${dl_direction}    duration=${duration}
#    ...    throughput=${dl_throughput}    iperf_port=${ue_dl_port}
#    sleep    10s
#    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=5m
#    Power_ue.Check Tput    ue_type=${ue_type}    direction=UL    log=${log}   cells=${list_of_cell_ids}
#    ...    target_throughput=${ul_expect_throughput}
#    run keyword if   '${gnb_id}'=='${btsid[2]}'    Power_ue.Check Tput    ue_type=${ue_type}    direction=DL
#    ...    log=${log}   cells=${list_of_cell_ids}    target_throughput=${dl_expect_throughput_22R1}
#    ...    ELSE    Power_ue.Check Tput    ue_type=${ue_type}    direction=DL    log=${log}   cells=${list_of_cell_ids}
#    ...    target_throughput=${dl_expect_throughput}
#    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul
#    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl
#    power_ue.UE Detach    ue_type=${ue_type}
#    Calculate BTS or ru reset pass rate    reset_type=ru    reset_times=5
#    wait until keyword succeeds    3X    10s    Common UE attach
#    power_ue.Start traffic    ue_type=${ue_type}    direction=${ul_direction}
#    ...    duration=${duration}   throughput=${ul_throughput}    iperf_port=${ue_ul_port}
#    power_ue.Start traffic    ue_type=${ue_type}    direction=${dl_direction}    duration=${duration}
#    ...    throughput=${dl_throughput}    iperf_port=${ue_dl_port}
#    sleep    10s
#    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=5m
#    Power_ue.Check Tput    ue_type=${ue_type}    direction=UL    log=${log}   cells=${list_of_cell_ids}
#    ...    target_throughput=${ul_expect_throughput}
#    run keyword if   '${gnb_id}'=='${btsid[2]}'    Power_ue.Check Tput    ue_type=${ue_type}    direction=DL
#    ...    log=${log}   cells=${list_of_cell_ids}    target_throughput=${dl_expect_throughput_22R1}
#    ...    ELSE    Power_ue.Check Tput    ue_type=${ue_type}    direction=DL    log=${log}   cells=${list_of_cell_ids}
#    ...    target_throughput=${dl_expect_throughput}
#    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    iperf_port=${ue_ul_port}
#    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    iperf_port=${ue_dl_port}
#    power_ue.UE Detach    ue_type=${ue_type}
#    [Teardown]    Run keywords
#    ...    robot_common_operations.Common Case Teardown    AND
#    ...    Run Keyword And Ignore Error    Common UE teardown    AND
#    ...    Check hanging resource for gnb    gnb_ips=${gnb_ips}    ute_log_path=${ute_log_path}    AND
#    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
#[1]FGCR-7256_01_General_SiSo_E2E_system_setup_with_data_transfer_peaktp_AWHHF_new_BW_20M
#    [Documentation]    Decription:The purpose of this test case is to check new Added BW 20M supported to AWHHF with TA.
#    ...    Measured TCP UDP UL/DL TCP UDP Throughput is corresponding to calculated
#    ...    throughput ( > 98% theoretical value of given mcs )
#    [Tags]     huawei    classical    CRT_TRUNK    CRT_23R1    CRT_22R3    CRT_22R4
#    [Timeout]    2 hour
#    [Setup]    Common Case TestLine Setup    Is_Swconfig=True    swconfig_file=${SWCONFIG_PEAK_FILE_PATH}
#            ...    swconfig_target_path=${TS_CASE_SWCONFIG_PATH}    is_commission=True
#    robot_common_operations.Common Case Setup
#    ${cell1_id}=    run keyword if    '${gnb_id}'=='${btsid[0]}'    COAM Get nrcellid with lcrid    lcrid=${16383}
#    ...    ELSE    COAM Get nrcellid with lcrid    lcrid=${1}
#    ${list_of_cell_ids}    Create list    ${cell1_id}
#    power_ue.Prepare UE     ue_type=${ue_type}
#    wait until keyword succeeds    3X    10s    Common UE attach
#    power_ue.Start traffic    ue_type=${ue_type}    direction=${ul_direction}
#    ...    duration=${duration}   throughput=${ul_throughput}    iperf_port=${ue_ul_port}
#    power_ue.Start traffic    ue_type=${ue_type}    direction=${dl_direction}    duration=${duration}
#    ...    throughput=${dl_throughput}    iperf_port=${ue_dl_port}
#    sleep    10s
#    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=5m
#    Power_ue.Check Tput    ue_type=${ue_type}    direction=UL    log=${log}   cells=${list_of_cell_ids}
#    ...    target_throughput=${ul_expect_throughput}
#    run keyword if   '${gnb_id}'=='${btsid[2]}'    Power_ue.Check Tput    ue_type=${ue_type}    direction=DL
#    ...    log=${log}   cells=${list_of_cell_ids}    target_throughput=${dl_expect_throughput_22R1}
#    ...    ELSE    Power_ue.Check Tput    ue_type=${ue_type}    direction=DL    log=${log}   cells=${list_of_cell_ids}
#    ...    target_throughput=${dl_expect_throughput}
#    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    iperf_port=${ue_ul_port}
#    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    iperf_port=${ue_dl_port}
#    power_ue.UE Detach    ue_type=${ue_type}
#    [Teardown]    Run keywords
#    ...    robot_common_operations.Common Case Teardown    AND
#    ...    Run Keyword And Ignore Error    Common UE teardown    AND
#    ...    Check hanging resource for gnb    gnb_ips=${gnb_ips}    ute_log_path=${ute_log_path}    AND
#    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
#[1]FGCR-7256_02_General_SiSo_E2E_system_setup_with_data_transfer_peaktp_AWHHF_new_BW_80M
#    [Documentation]    Decription:The purpose of this test case is to check new Added BW 80M supported to AWHHF with TA.
#    ...    Measured TCP UDP UL/DL TCP UDP Throughput is corresponding to calculated
#    ...    throughput ( > 98% theoretical value of given mcs )
#    [Tags]     huawei    classical    CRT_TRUNK    CRT_23R1    CRT_22R3    CRT_22R4
#    [Timeout]    2 hour
#    [Setup]    Common Case TestLine Setup    Is_Swconfig=True    swconfig_file=${SWCONFIG_PEAK_FILE_PATH}
#            ...    swconfig_target_path=${TS_CASE_SWCONFIG_PATH}    is_commission=True
#    robot_common_operations.Common Case Setup
#    ${cell1_id}=    run keyword if    '${gnb_id}'=='${btsid[0]}'    COAM Get nrcellid with lcrid    lcrid=${16383}
#    ...    ELSE    COAM Get nrcellid with lcrid    lcrid=${1}
#    ${list_of_cell_ids}    Create list    ${cell1_id}
#    power_ue.Prepare UE     ue_type=${ue_type}
#    wait until keyword succeeds    3X    10s    Common UE attach
#    power_ue.Start traffic    ue_type=${ue_type}    direction=${ul_direction}
#    ...    duration=${duration}   throughput=${ul_throughput}    iperf_port=${ue_ul_port}
#    power_ue.Start traffic    ue_type=${ue_type}    direction=${dl_direction}    duration=${duration}
#    ...    throughput=${dl_throughput}    iperf_port=${ue_dl_port}
#    sleep    10s
#    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=5m
#    Power_ue.Check Tput    ue_type=${ue_type}    direction=UL    log=${log}   cells=${list_of_cell_ids}
#    ...    target_throughput=${ul_expect_throughput}
#    run keyword if   '${gnb_id}'=='${btsid[2]}'    Power_ue.Check Tput    ue_type=${ue_type}    direction=DL
#    ...    log=${log}   cells=${list_of_cell_ids}    target_throughput=${dl_expect_throughput_22R1}
#    ...    ELSE    Power_ue.Check Tput    ue_type=${ue_type}    direction=DL    log=${log}   cells=${list_of_cell_ids}
#    ...    target_throughput=${dl_expect_throughput}
#    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    iperf_port=${ue_ul_port}
#    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    iperf_port=${ue_dl_port}
#    power_ue.UE Detach    ue_type=${ue_type}
#    [Teardown]    Run keywords
#    ...    robot_common_operations.Common Case Teardown    AND
#    ...    Run Keyword And Ignore Error    Common UE teardown    AND
#    ...    Check hanging resource for gnb    gnb_ips=${gnb_ips}    ute_log_path=${ute_log_path}    AND
#    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

*** Keywords ***
cell lock unlock for gnbBts
    Modify the parameter on gNB bts    parameters=${PARAMS_TO_MODIFY_LOCKG1}
    Wait Until Keyword Succeeds    180sec    30 sec    Cell Should Be Locked
    ${allowed_faults}    Create List    @{ALLOWED_FAULT_LIST}    ${fault_7319}    ${fault_7300}
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=${allowed_faults}
    Modify the parameter on gNB bts    parameters=${PARAMS_TO_MODIFY_UNLOCKG1}
    Wait Until Keyword Succeeds    5 min    30 sec     Cell Should Be Unlocked
    Wait Until Keyword Succeeds    5 min    30 sec     Check the COAM gnb cell status onair

cell lock unlock for 21B
    Modify the parameter on gNB bts    parameters=${PARAMS_TO_MODIFY_LOCKG2}
    Wait Until Keyword Succeeds    180sec    30 sec    Cell Should Be Locked    cell_idx=${2}   cell_group_idx=${1}
    ${allowed_faults}    Create List    @{ALLOWED_FAULT_LIST}    ${fault_7319}    ${fault_7300}
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=${allowed_faults}
    Modify the parameter on gNB bts    parameters=${PARAMS_TO_MODIFY_UNLOCKG2}
    Wait Until Keyword Succeeds    5 min    30 sec     Cell Should Be Unlocked    cell_idx=${2}   cell_group_idx=${1}
    Wait Until Keyword Succeeds    5 min    30 sec     Check the COAM gnb cell status onair

cell lock unlock for TL356
    Modify the parameter on gNB bts    parameters=${PARAMS_TO_MODIFY_LOCKG1}
    Wait Until Keyword Succeeds    180 sec    30 sec    Cell Should Be Locked
    ${allowed_faults}    Create List    @{ALLOWED_FAULT_LIST}    ${fault_7319}    ${fault_7300}
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=${allowed_faults}
    Modify the parameter on gNB bts    parameters=${PARAMS_TO_MODIFY_UNLOCKG1}
    Wait Until Keyword Succeeds    5 min    30 sec     Cell Should Be Unlocked
    Wait Until Keyword Succeeds    5 min    30 sec     Check the COAM gnb cell status onair

RU block unblock for gnbBts
    Modify the parameter on gNB bts    parameters=${PARAMS_TO_RU_LOCKED1}
    ${start_time}    Get Current Date
    Wait Until Keyword Succeeds    240 sec    3 sec    RU Should Be Locked
    Wait Until Keyword Succeeds    240 sec    5 sec    Cell Should Be Disabled
    ${allowed_faults}    Create List    @{ALLOWED_FAULT_LIST}    ${fault_7319}    ${fault_7300}
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=${allowed_faults}
    Modify the parameter on gNB bts    parameters=${PARAMS_TO_RU_UNLOCKED1}
    Wait Until Keyword Succeeds    4 min   3 sec     RU Should Be Unlocked
    Wait Until Keyword Succeeds    5 min    30 sec     Check the COAM gnb cell status onair

RU block unblock for 21B
    Modify the parameter on gNB bts    parameters=${PARAMS_TO_RU_LOCKED2}
    ${start_time}    Get Current Date
    Wait Until Keyword Succeeds    240 sec    3 sec    RU Should Be Locked    ru_index=${2}
    Wait Until Keyword Succeeds    240 sec    5 sec    Cell Should Be Disabled   cell_idx=${2}   cell_group_idx=${1}
    ${allowed_faults}    Create List    @{ALLOWED_FAULT_LIST}    ${fault_7319}    ${fault_7300}
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=${allowed_faults}
    Modify the parameter on gNB bts    parameters=${PARAMS_TO_RU_UNLOCKED2}
    Wait Until Keyword Succeeds    4 min   3 sec     RU Should Be Unlocked    ru_index=${2}
    Wait Until Keyword Succeeds    5 min    30 sec     Check the COAM gnb cell status onair


UE.Check Both ULDL throughput for 40s
    [Arguments]    ${ue_type}    ${theory_dl_peak}    ${theory_ul_peak}    #${deviation}=10
    ...            ${total_time}=40    ${duration_time_for_once}=15s    #${interval}=5s
    ...            ${acceptable_tput_percentage}=0.90    ${nr_cell_index}=1    ${du_index}=0
#    ...            ${gnb_ssl_connection}=GNB_OAM    ${is_need_to_capture_log}=${False}
#    ...            ${gnb_index}=${0}
    [Documentation]    Check Both ULDL throughputt from started traffic.
    [Timeout]      30min
    Log to console    \nINFO:power_ue.Check Both ULDL throughput for 40s
    Connect to gnb coam via ssl
    power_ue.Check peak throughput     ue_type=${ue_type}
    ...     theory_dl_peak=${theory_dl_peak}     theory_ul_peak=${theory_ul_peak}     nr_cell_index=${nr_cell_index}
    ...     total_time=${total_time}     duration_time_for_once=${duration_time_for_once}
    ...     acceptable_tput_percentage=${acceptable_tput_percentage}
    ...     du_index=${du_index}
    [Teardown]  COAM Teardown gnb connections

Set automatic rotation
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...    ${commond}=shell content insert --uri content://settings/system --bind name:s:accelerometer_rotation --bind value:i:
    ...    ${rotation_value}=0
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} ${commond}${rotation_value}
    ...    connection=cygwin${ue_index}
    sleep    5s

Calculate BTS or ru reset pass rate
    [Documentation]  Author: Jack Zeng
    ...              Description: this keyword is used for calculate the pass rate of BTS or RU after reset given times
    ...                           ${reset_type}: optional,value can be 'bts' or 'ru'
    ...                           ${reset_times}: given the reset times
    [Arguments]    ${reset_type}    ${reset_times}
    ${fail_times}    Set variable    ${0}
    FOR    ${0}    IN RANGE    ${reset_times}
        Run keyword if    '${reset_type}' == 'bts'    Perform BTS Site Reset
        ...    ELSE IF    '${reset_type}' == 'ru'    Perform gnb RU Reset
        ...    ELSE    Fail    ${reset_type} is invalid input,please retype!
        sleep    180s
        ${status}    run keyword and return status    Wait until cluster is on cell on air status    timeout=${702_RECOVERY_TIMEOUT}
        ...    is_all_cells_checking_needed=${True}
        ${fail_times}    Run keyword if    ${status}==${False}    Evaluate    ${fail_times}+1    ELSE    set variable    ${fail_times}
    END
    ${pass_rate}    Evaluate    (1-${fail_times}/${reset_times})*100
    Log to console    reset ${reset_type} ${reset_times} times,fail ${fail_times} times,pass rate is ${pass_rate}%
    Should be true    ${pass_rate}>90

Perform gnb RU Reset
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    [Arguments]    ${ru_index}=${1}   ${download_dir}=${TS_CASE_LOG_PATH}
    ${ru_index}  Convert To Integer    ${ru_index}
    COAM Navigate to login page via webUI   download_dir=${download_dir}    gnb_index=${0}
    selenium_coam.reset_ru  ru_index=${ru_index}
    [Teardown]  COAM selenium logout

Make huawei WR for avoid RLC-max-fail
    Common UE attach
    power_ue.Start traffic    ue_type=${ue_type}    direction=${ul_direction}
    ...    duration=${duration}   throughput=${ul_throughput}    iperf_port=${ue_ul_port}
    power_ue.Start traffic    ue_type=${ue_type}    direction=${dl_direction}    duration=${duration}
    ...    throughput=${dl_throughput}    iperf_port=${ue_dl_port}
    sleep    120s
    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    iperf_port=${ue_ul_port}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    iperf_port=${ue_dl_port}
    power_ue.UE Detach    ue_type=${ue_type}