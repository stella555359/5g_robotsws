*** Settings ***
Documentation
...   author: zheyuan.chen@nokia-sbell.com
...   contact: zheyuan.chen@nokia-sbell.com
...   SISO

Suite Setup    Suite variable
Suite Teardown    suite teardown

Resource    ./resources/comm_8434.robot
Resource    ../../../resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF_NEW/Resource/UUF_LogCollection.robot
Variables     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF_NEW/Config/UUF_Vars.py


*** Variables ***
@{ru_serial_list}    EB2232R0689    EB2232R0703    EB2232R0707


*** Test Cases ***
[1]CB008434_04_supercell_Super cell Setup
    [Documentation]
    ...    The purpose of this test is to verify that super cell with up to max sub-cells for different BBMOD by the legacy user plane
    ...    deployment with CPRI/eCPRI fronthaul connection can setup and be deleted succussfully without any unexpected alarm.
    ...    -10.10.2022,zheyuan.chen@nokia-sbell.com,case draft
    ...    TL7015
    [Tags]    CRT_23R1    CRT_TRUNK    CB008434
    [Setup]    case_setup    scf_name=_normal.xml
    Check One Cell Throughput
    Setup TL5 Supercell
    Modify Default gNBCellid    Actual_value=${10}    LNCEL_idx=${54726}    connection=eNB
    Check Each RU Throughput       RU_LIST=${TL5_exceptpeak_RU_list}
    Check RU Peak Throughput
    Delete TL5 Supercell
    Check Each Cell Throughput
    [Teardown]    case_teardown

[1]CB008434_05_supercell_delete
    [Documentation]    TL7015
    [Tags]    CRT_23R1    CRT_TRUNK    CB008434
    Should Be Equal As Strings   ${PREV_TEST_STATUS}   PASS

[1]CB008434_03_Super_Cell_Reconfiguration
    [Documentation]
    ...    The purpose of this test is to verify that super cells reconfiguration, including super expansion, deletion, and split.
    ...    -12.10.2022,zheyuan.chen@nokia-sbell.com,case draft
    ...    TL7015
    [Tags]    CRT_23R1    CRT_TRUNK    CB008434
    [Setup]    case_setup    scf_name=_supercell.xml
    Modify Default gNBCellid    Actual_value=${10}    LNCEL_idx=${54726}    connection=eNB
    Delete TL5 Channelgroup
    Check Subcell Status    expected_list_length=${4}
    Check Reconfiguration RU Throughput
    Add TL5 Channelgroup
    Check Subcell Status    expected_list_length=${6}
    Check Each RU Throughput
    case_setup    scf_name=.xml
    [Teardown]    case_teardown

[1][1.0]CB008434_01_Super cell Setup and delete
    [Documentation]
    ...    The purpose of this test is to verify that super cell with up to max sub-cells for different BBMOD by the legacy user
    ...    plane deployment with CPRI/eCPRI fronthaul connection can setup and be deleted succussfully without any unexpected alarm
    ...    and super cell deletion successfully
    ...    -13.10.2022,zheyuan.chen@nokia-sbell.com,case draft
    ...    TL7012
    [Tags]    CRT_23R1    CRT_TRUNK    CB008434
    [Setup]    case_setup    scf_name=_supercell.xml
    Check Supercell Each RU Throughput    nrcell_id=187564035    Actual_value=10    RU_LIST=${TL5RU_list}
    [Teardown]    run keywords    CI_interface.Common Case Teardown    AND    robot_common_operations.Common case Teardown

[1][2.0]General_SiSo_Auto_RF_lock_unlock_with_L3call
    [Documentation]
    ...    Purpose of this case is to check if radio module is operating after lock and unlock procedure.
    ...    -18.10.2022,zheyuan.chen@nokia-sbell.com,case draft
    ...    TL7012
    [Tags]    CRT_23R1    CRT_TRUNK    CB008434
    [Setup]    case_setup    scf_name=_supercell.xml
    FOR    ${item}    IN RANGE    ${3}
        Lock Unlock All RU    RU_LIST=${TL5RU_list}
    END
    Check Supercell One RU Throughput    nrcell_id=187564035    Actual_value=10    RU_dic=${AWHQX3_dic}
    [Teardown]    case_teardown

[1][1.0]General_SiSo_Auto_Cell_block_and_unblock_with_L3call
    [Documentation]
    ...    The purpose of this test case is to verify cell and group cell lock/ unlock functionality.
    ...    -19.10.2022,zheyuan.chen@nokia-sbell.com,case draft
    ...    TL7012
    [Tags]    CRT_23R1    CRT_TRUNK    CB008434
    [Setup]    case_setup    scf_name=_supercell.xml
    SBTS Login
    AlarmWatchdog.add_allow_alarms    fault_id=49
    run keyword and continue on failure    Block Cell And Check Cell Status    cell_idx=${3}    cell_info=${TL2_cell_info1}
    wait until keyword succeeds    10s    1s    Check Expected Alarm    faultID=${49}    expected_alarmid=${7102}
    ...    expected_objectname=${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3
    Unblock Cell And Check Cell Status    cell_idx=${3}    cell_info=${TL2_cell_info1}
    wait until keyword succeeds    5min    10s    Check No Expected Alarm    fault_id=${49}
    AlarmWatchdog.remove_allow_alarms    fault_id=49
    SBTS Logout
    Check Supercell One RU Throughput    nrcell_id=187564035    Actual_value=10    RU_dic=${AWHQX3_dic}
    [Teardown]    case_teardown

*** Keywords ***
case_teardown
    CI_interface.Common Case Teardown
    robot_common_operations.Common case Teardown
    Run Keyword if    "${TEST_STATUS}"=="FAIL"    Save Snapshot
    Run Keyword if    "${TEST_STATUS}"=="FAIL"    Capture LMI Log    ru_serial_list=${ru_serial_list}    gnb_index=${0}


Capture LMI Log
    [Arguments]    ${gnb_index}    ${ru_serial_list}    ${log_dir}=${OUTPUT_DIR}/${TEST_NAME}
    Log To Console   //TODO: UUF Catch RU Log
    Log To Console   ${RU_LOG_FLAG}
    ${log_dir_not_exist}   Run Keyword And Return Status   OperatingSystem.Directory Should Not Exist   ${log_dir}
    Run Keyword If   ${log_dir_not_exist}   OperatingSystem.Create Directory   ${log_dir}
    ${RU_serial_pc_info}    UUF Get RU PC Info Accordind To Serial    ru_serial_list=${ru_serial_list}
    UUF Catch RU Log From LMI    testline=gnb_${gnb_index}    ru_list=${RU_serial_pc_info}



Save Snapshot
    [Arguments]    ${connection}=cOAM    ${timeout}=10min
    log to console    Save Snapshot...
    run keyword and ignore error     coam.teardown    connection=${connection}
    Connect to gnb coam via ssl    bts_host=${DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${connection}
    ${snapshot_path}    coam.Get Snapshot From BTS    alias=${connection}    timeout=${timeout}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}
    [Return]    ${snapshot_path}

case_setup
    [Arguments]  ${scf_name}=.xml
    robot_common_operations.Common Case Setup    allowed_faults_ids=7316
    ${default_scf}    suite setup to prepare default scf
    ${default_scf}    set variable    ${default_scf}${scf_name}
    Commission Default SCF    default_scf=${default_scf}

Check Each Cell Throughput
    [Arguments]    ${RU_LIST}=${TL5RU_list}    ${tp_ul}=100M    ${tp_dl}=300M    ${target_tp_ul}=50     ${target_tp_dl}=100
    Log To Console    Check Each Cell Throughput
    SBTS Login
    Wait Until BTS Should Be Normal
    FOR    ${RU_dic}    IN    @{RU_LIST}
        ${nrcell_id}    get from dictionary    ${RU_dic}    nrcell_id
        ${default_id}    get from dictionary    ${RU_dic}    default_id
        Modify Default gNBCellid    Actual_value=${default_id}    LNCEL_idx=${54726}    connection=eNB
        _lock_other_ru    RU_list=${RU_LIST}    RU_dic=${RU_dic}
        Start Traffic And Check Throughput    tp_ul=${tp_ul}    tp_dl=${tp_dl}    target_tp_ul=${target_tp_ul}    target_tp_dl=${target_tp_dl}
        ...    nrcell_id=${nrcell_id}
        Stop Traffic And UE Detach
        sleep    10s
        _unlock_other_ru    RU_list=${RU_LIST}    RU_dic=${RU_dic}
    END
    [Teardown]    SBTS Logout

Check One Cell Throughput
    [Arguments]    ${RU_LIST}=${TL5RU_list}    ${RU_dic}=${AWHQX2_dic}    ${nrcell_id}=183170
    Log To Console    check one cell throughput
    Modify Default gNBCellid    Actual_value=${6}    LNCEL_idx=${54726}    connection=eNB
    SBTS Login
    _lock_other_ru    RU_list=${RU_LIST}    RU_dic=${RU_dic}
    Start Traffic And Check Throughput    tp_ul=100M    tp_dl=300M    target_tp_ul=50    target_tp_dl=100    nrcell_id=${nrcell_id}
    Stop Traffic And UE Detach
    sleep    10s
    _unlock_other_ru    RU_list=${RU_LIST}    RU_dic=${RU_dic}
    Wait Until BTS Should Be Normal
    [Teardown]    SBTS Logout

Setup TL5 Supercell
    Log To Console    setup supercell
    WEBUI Login
    Activate TL5 Supercell And Add Channelgroup
    Delete TL5 Nrcells Data
    ${error}    selenium_coam.validate_plan
    Log To Console    ${error}
    Log To Console    Activate plan
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    [Teardown]    WEBUI Logout

Check Each RU Throughput
    [Arguments]    ${RU_LIST}=${TL5RU_list}    ${tp_ul}=100M    ${tp_dl}=300M    ${target_tp_ul}=45     ${target_tp_dl}=100
    ...    ${nrcell_id}=187564035
    Log To Console    Check Each RU Throughput
    SBTS Login
    Wait Until BTS Should Be Normal
    FOR    ${RU_dic}    IN    @{RU_LIST}
        _lock_other_ru    RU_list=${RU_LIST}    RU_dic=${RU_dic}
        Start Traffic And Check Throughput    tp_ul=${tp_ul}    tp_dl=${tp_dl}    target_tp_ul=${target_tp_ul}    target_tp_dl=${target_tp_dl}
        ...    nrcell_id=${nrcell_id}
        Stop Traffic And UE Detach
        sleep    10s
        _unlock_other_ru    RU_list=${RU_LIST}    RU_dic=${RU_dic}
    END
    [Teardown]    SBTS Logout

Check RU Peak Throughput
    [Arguments]    ${tp_ul}=100M    ${tp_dl}=1600M    ${target_tp_ul}=70     ${target_tp_dl}=1400    ${nrcell_id}=187564035
    ...    ${target_avg_percent}=${1}
    Log To Console    Check RU Peak Throughput
    SBTS Login
    FOR    ${item}    IN RANGE    ${2}
        ${RMOD_idx}    evaluate    ${item} + 1
        Lock RMOD    RMOD_idx=${RMOD_idx}
    END
    Start Traffic And Check Throughput    tp_ul=${tp_ul}    tp_dl=${tp_dl}    target_tp_ul=${target_tp_ul}    target_tp_dl=${target_tp_dl}
    ...    nrcell_id=${nrcell_id}    target_avg_percent=${target_avg_percent}
    Stop Traffic And UE Detach
    sleep    10s
    FOR    ${item}    IN RANGE    ${2}
        ${RMOD_idx}    evaluate    ${item} + 1
        Unlock RMOD    RMOD_idx=${RMOD_idx}
    END
    Wait Until BTS Should Be Normal
    [Teardown]    SBTS Logout

Check Reconfiguration RU Throughput
    [Arguments]    ${tp_ul}=100M    ${tp_dl}=300M    ${target_tp_ul}=45     ${target_tp_dl}=100    ${nrcell_id}=187564035
    Log To Console    Check Reconfiguration RU Throughput
    SBTS Login
    FOR    ${item}    IN RANGE    ${2}
        ${RMOD_idx}    evaluate    ${item} + 2
        Lock RMOD    RMOD_idx=${RMOD_idx}
        Start Traffic And Check Throughput    tp_ul=${tp_ul}    tp_dl=${tp_dl}    target_tp_ul=${target_tp_ul}    target_tp_dl=${target_tp_dl}
        ...    nrcell_id=${nrcell_id}
        Stop Traffic And UE Detach
        sleep    10s
        Unlock RMOD    RMOD_idx=${RMOD_idx}
        Wait Until BTS Should Be Normal
    END
    [Teardown]    SBTS Logout

Delete TL5 Supercell
    Log To Console    delete supercell
    WEBUI Login
    Add TL5 Nrcells Data
    Delete Supercell Configuration
    ${error}    selenium_coam.validate_plan
    Log To Console    ${error}
    Log To Console    Activate plan
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    [Teardown]    WEBUI Logout

Block Cell And Check Cell Status
    [Arguments]    ${cell_idx}    ${cell_info}    ${operational_status}=disabled    ${usage_status}=Idle    ${block_status}=Blocked
    block_cell    cell_idx=${cell_idx}
    wait until keyword succeeds    5min    10s    Check Cells Status    cell_info=${cell_info}
    ...    operational_status=${operational_status}    usage_status=${usage_status}    block_status=${block_status}

Unblock Cell And Check Cell Status
    [Arguments]    ${cell_idx}    ${cell_info}    ${usage_status}=Active    ${block_status}=Unblocked
    unblock_cell    cell_idx=${cell_idx}
    wait until keyword succeeds    10min    10s    Check Cells Status    cell_info=${cell_info}
    ...    usage_status=${usage_status}    block_status=${block_status}

Check Supercell Each RU Throughput
    [Arguments]    ${nrcell_id}    ${Actual_value}    ${RU_LIST}=${TL2RU_list}    ${tp_ul}=100M    ${tp_dl}=300M
    ...    ${target_tp_ul}=50     ${target_tp_dl}=100
    Log To Console    Check Supercell Each RU Throughput
    Modify Default gNBCellid    Actual_value=${Actual_value}
    SBTS Login
    FOR    ${RU_dic}    IN    @{RU_LIST}
        _lock_other_ru    RU_list=${RU_LIST}    RU_dic=${RU_dic}
        sleep    5s
        Start Traffic And Check Throughput    tp_ul=${tp_ul}    tp_dl=${tp_dl}    target_tp_ul=${target_tp_ul}    target_tp_dl=${target_tp_dl}
        ...    nrcell_id=${nrcell_id}
        Stop Traffic And UE Detach
        sleep    10s
        _unlock_other_ru    RU_list=${RU_LIST}    RU_dic=${RU_dic}
        wait until bts should be normal
    END
    [Teardown]    SBTS Logout

Check Supercell One RU Throughput
    [Arguments]    ${nrcell_id}    ${Actual_value}     ${RU_LIST}=${TL5RU_list}    ${RU_dic}=${AWHQX1_dic}    ${tp_ul}=100M    ${tp_dl}=300M
    ...    ${target_tp_ul}=30     ${target_tp_dl}=100
    Log To Console    Check Supercell One RU Throughput
    Modify Default gNBCellid    Actual_value=${Actual_value}
    SBTS Login
    _lock_other_ru    RU_list=${RU_LIST}    RU_dic=${RU_dic}
    sleep    5s
    Start Traffic And Check Throughput    tp_ul=${tp_ul}    tp_dl=${tp_dl}    target_tp_ul=${target_tp_ul}    target_tp_dl=${target_tp_dl}
    ...    nrcell_id=${nrcell_id}
    Stop Traffic And UE Detach
    sleep    10s
    _unlock_other_ru    RU_list=${RU_LIST}    RU_dic=${RU_dic}
    [Teardown]    SBTS Logout

Lock Unlock All RU
    [Arguments]    ${RU_LIST}
    Log To Console    Lock Unlock All RU
    SBTS Login
    FOR    ${RU_dic}    IN    @{RU_LIST}
        ${index}    get from dictionary    ${RU_dic}    index
        ${expected_RU}    get from dictionary    ${RU_dic}     RU_SN
        Lock RMOD    RMOD_idx=${index}
        Check RMOD Status    expected_RU=${expected_RU}    connection=default
        ...    expect_admin_status=Locked    expect_usage_status=Idle    expect_procedure_status=configured
        Unlock RMOD    RMOD_idx=${index}
        Check RMOD Status    expected_RU=${expected_RU}    expect_usage_status=Active
        Log To Console    wait until bts should be normal
        wait until bts should be normal
    END
    [Teardown]    SBTS Logout


Suite variable
    robot_common_operations.Common Suite Setup
    set suite variable    &{AWHQX1_dic}      RU_SN=EB2232R0689    index=${1}    nrcell_id=187564033    default_id=${5}
    set suite variable    &{AWHQX2_dic}      RU_SN=EB2232R0703    index=${2}    nrcell_id=187564034    default_id=${6}
    set suite variable    &{AWHQX3_dic}      RU_SN=EB2232R0707    index=${3}    nrcell_id=187564035    default_id=${10}
    set suite variable    &{AWHHD_dic}      RU_SN=EB2121R0170    index=${1}
    set suite variable    &{AWHHF1_dic}      RU_SN=EB2110R1108    index=${2}
    set suite variable    &{AWHHF2_dic}      RU_SN=AH222130037    index=${3}
    @{TL5RU_list}    create list    ${AWHQX1_dic}    ${AWHQX2_dic}   ${AWHQX3_dic}
    @{TL5_exceptpeak_RU_list}    create list    ${AWHQX1_dic}    ${AWHQX2_dic}
    @{TL2RU_list}    create list    ${AWHHD_dic}    ${AWHHF1_dic}    ${AWHHF2_dic}
    set suite variable     @{TL5RU_list}
    set suite variable     @{TL5_exceptpeak_RU_list}
    set suite variable     @{TL2RU_list}
    CI_interface.Common Suite Setup
    Adapt to ute cloud commission scf
    Adapt to ute cloud enb info


suite teardown
    robot_common_operations.Common Suite Teardown
    Modify Default gNBCellid    Actual_value=${10}    LNCEL_idx=${54726}    connection=eNB
    ${default_scf}    suite setup to prepare default scf
    Commission Default SCF    default_scf=${default_scf}.xml