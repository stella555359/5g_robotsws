*** Settings ***
Force Tags    PY36
Documentation
...   author: zheyuan.chen@nokia-sbell.com
...   contact: zheyuan.chen@nokia-sbell.com
...   Dual Core SISO

#Suite Setup    suite_setup
Suite Setup    Run keywords    suite_setup    AND    robot_common_operations.Common Suite Setup
Suite Teardown    robot_common_operations.Common Suite Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    ./resources/comm_7876A.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot

*** Variables ***
@{BTS_counter_list}    M55302C00000     M55300C00000

*** Test Cases ***
[1]CB007876_A_FR2_004_HW inventory_state_change_in_dual-core_gNB
    [Documentation]
    ...    This case is to verify HW management procedures for dual-core gNB are handled in the same way as single-core gNB,
    ...    below aspects are covered:
    ...    - Basedband modules state change from both cores shall be notified.
    ...    - Radio modules state change from both cores shall be notified.
    ...    -13.09.2021,zheyuan.chen@nokia-sbell.com,case draft
    ...    contain CB006615_A_FR2_004_HW inventory_state_change_in_dual-core_gNB
    [Tags]    CRT_22R1    CRT_TRUNK    CRT_22R2    CB007876_A
    [Setup]    robot_common_operations.Common case Setup
    Check BTS Should Be Normal
    FOR    ${RU_index}    IN    @{RU_list}
        ${poweroff_list}    _get_poweroff_value_from_ru_dictionary    RU_index=${RU_index}
        ${status_list}    _get_status_value_from_ru_dictionary    RU_index=${RU_index}
        Power Off And Power On Repeat 3times    poweroff_list=${poweroff_list}    status_list=${status_list}
        ...    RU_index=${RU_index}
    END
    [Teardown]    robot_common_operations.Common Case Teardown

[1]CB006615_A_FR2_004_HW inventory_state_change_in_dual-core_gNB
    [Tags]    CRT_22R1    CRT_TRUNK    CRT_22R2    CB006615_A
    [Setup]    robot_common_operations.Common case Setup
    Should Be Equal As Strings   ${PREV_TEST_STATUS}   PASS
    [Teardown]    robot_common_operations.Common Case Teardown

[1]CB006615_A_FR2_005_Site_Reset_in_dual-core_gNB
    [Documentation]
    ...    This case is to verify site reset and BTS lock/unlock scenarios via webEM for dual-core gNB are handled in the same way
    ...    as single-core gNB.
    ...    -13.09.2021,zheyuan.chen@nokia-sbell.com,case draft
    ...    contain CB006615_A_FR2_005_Site_Reset_in_dual-core_gNB
    [Tags]    CRT_22R1    CB007876_A
    [Setup]
    Check BTS Should Be Normal
    Reset BTS And Wait Until On Air
    run keyword and continue on failure    Check if Unexpected History Alarm Exist
    ${Alarm_status}    run keyword and return status    Check if Unexpected History Alarm Exist
    run keyword if  not ${Alarm_status}    Save Snapshot Log
    Lock And Unlock BTS And Wait Until On Air
    run keyword and continue on failure    Check if Unexpected History Alarm Exist
    [Teardown]    CI_interface.Common Case Teardown

[1]CB007876_A_FR2_005_Site_Reset_in_dual-core_gNB
    [Tags]    CB006615_A
    Should Be Equal As Strings   ${PREV_TEST_STATUS}   PASS

[1]CB007876_A_FR2_013_Software_Update_in_dual-core_gNB
    [Documentation]
    ...    This case is to verify Software Management procedures for dual-core gNB are handled in the same way as single-core gNB,
    ...    below aspects are covered.
    ...    -13.09.2021,zheyuan.chen@nokia-sbell.com,case draft
    [Tags]    CB007876_A
    [Setup]
    Check BTS Should Be Normal
    [Teardown]    CI_interface.Common Case Teardown

[1]CB006615_A_FR2_013_Software_Update_in_dual-core_gNB
    [Tags]    CB006615_A
    Should Be Equal As Strings   ${PREV_TEST_STATUS}   PASS

[1]CB007876_A_FR2_006_Modules_Resets_in_dual-core_gNB
    [Documentation]
    ...    This case is to verify below reset scenarios via webEM for dual-core gNB are handled in the same way as single-core gNB:
    ...    - BB reset via webEM.
    ...    - RU reset via webEM.
    ...    - RU lock via webEM.
    ...    - Cell lock/unlock via webEM.
    ...    Note above execution can focus mainly on modules on secondary core.
    ...    -13.09.2021,zheyuan.chen@nokia-sbell.com,case draft
    ...    contain  CB006615_A_FR2_006_Modules_Resets_in_dual-core_gNB
    [Tags]    CRT_22R1    CRT_TRUNK    CRT_22R2    CB007876_A
    [Setup]    robot_common_operations.Common case Setup
    Check BTS Should Be Normal
    FOR    ${RU_index}    IN    @{RU_list}
        ${poweroff_list}    _get_poweroff_value_from_ru_dictionary    RU_index=${RU_index}
        ${status_list}    _get_status_value_from_ru_dictionary    RU_index=${RU_index}
        ${BBMOD_index}    run keyword if    ${status_list[1]} > ${3}    evaluate    ${status_list[1]}-1
        ...    ELSE    evaluate    ${status_list[1]}-0
        Restart BBMOD    BBMOD_idx=${BBMOD_index}
        Check Cells Status    cell_info=${status_list[2]}    operational_status=Disabled    usage_status=Idle
        wait until keyword succeeds    10min    10s    Check Cells Status    cell_info=${status_list[2]}
        Reset RMOD    RU_index=${status_list[1]}
        run keyword and continue on failure    Check Cells Status    cell_info=${status_list[2]}    operational_status=Disabled
        ...    usage_status=Idle
        wait until keyword succeeds    10min    10s    Check Cells Status    cell_info=${status_list[2]}
        Lock RMOD    RMOD_idx=${status_list[1]}
        run keyword and continue on failure    Check Cells Status    cell_info=${status_list[2]}    operational_status=Disabled
        ...    usage_status=Idle
        Unlock RMOD    RMOD_idx=${status_list[1]}
        wait until keyword succeeds    10min    10s    Check Cells Status    cell_info=${status_list[2]}
        ${cellgroup_index}    evaluate    ${status_list[1]}-1
        Lock Cellgroup    cellgrp_idx=${cellgroup_index}
        run keyword and continue on failure    Check Cells Status    cell_info=${status_list[2]}    operational_status=Disabled
        ...    usage_status=Idle
        Unlock Cellgroup    cellgrp_idx=${cellgroup_index}
        wait until keyword succeeds    10min    10s    Check Cells Status    cell_info=${status_list[2]}
    END
    [Teardown]    robot_common_operations.Common Case Teardown

[1]CB006615_A_FR2_006_Modules_Resets_in_dual-core_gNB
    [Tags]    CRT_22R1    CRT_TRUNK    CRT_22R2    CB006615_A
    [Setup]    robot_common_operations.Common case Setup
    Should Be Equal As Strings   ${PREV_TEST_STATUS}   PASS
    [Teardown]    robot_common_operations.Common Case Teardown

[1]CB007876_A_FR2_011_NSA_Call_on_PrimaryCore_in_dual-core_gNB
    [Documentation]
    ...    This case is to verify NSA call attach/detach on primary core cell(s) in dual-core BTS.
    ...    contain CB006615_A_FR2_009_PM_without_Call_in_dual-core_gNB
    ...    -13.09.2021,zheyuan.chen@nokia-sbell.com,case draft
    ...    contain CB006615_A_FR2_011_NSA_Call_on_PrimaryCore_in_dual-core_gNB
    [Tags]    CRT_22R2    CB007876_A
    [Setup]
    Check BTS Should Be Normal
    6615_case11_steps
    7876_case11_steps
#    ${if_22R1_version}    Judge Version
#    run keyword if    '${if_22R1_version}' == 'True'    Check BTS Counters    BTS_counter_list=${BTS_counter_list}    nrcell_index=${9}
    [Teardown]    CI_interface.Common Case Teardown

[1]CB006615_A_FR2_011_NSA_Call_on_PrimaryCore_in_dual-core_gNB
    [Tags]    CRT_22R2    CB006615_A
    Should Be Equal As Strings   ${PREV_TEST_STATUS}   PASS

[1]CB007876_A_FR2_012_NSA_Call_on_SecondaryCore_in_dual-core_gNB
    [Documentation]
    ...    This case is to verify NSA call attach/detach on secondary core cell(s) in dual-core BTS.
    ...    contain CB006615_A_FR2_009_PM_without_Call_in_dual-core_gNB
    ...    -13.09.2021,zheyuan.chen@nokia-sbell.com,case draft
    ...    contain CB006615_A_FR2_012_NSA_Call_on_SecondaryCore_in_dual-core_gNB
    [Tags]    CRT_22R2    CB007876_A
    [Setup]
    Check BTS Should Be Normal
    Change eNB Nrcellid    Actual_value=2076571
    6615_case12_steps
    7876_case12_steps
#    ${if_22R1_version}    Judge Version
#    run keyword if    '${if_22R1_version}' == 'True'    Check BTS Counters    BTS_counter_list=${BTS_counter_list}    nrcell_index=${17}
    Change eNB Nrcellid    Actual_value=2074843
    [Teardown]    CI_interface.Common Case Teardown

[1]CB006615_A_FR2_012_NSA_Call_on_SecondaryCore_in_dual-core_gNB
    [Tags]    CRT_22R2    CB006615_A
    Should Be Equal As Strings   ${PREV_TEST_STATUS}   PASS

[1]CB007876_A_FR2_009_PM_without_Call_in_dual-core_gNB
    [Tags]    CB007876_A
    Should Be Equal As Strings   ${PREV_TEST_STATUS}   PASS

[1]CB006615_A_FR2_009_PM_without_Call_in_dual-core_gNB
    [Tags]    CB006615_A
   Should Be Equal As Strings   ${PREV_TEST_STATUS}   PASS

[1]CB007876_A_FR2_019_NSA_Call_on_BothCore_in_dual-core_gNB
    [Documentation]
    ...    This case is to verify NSA call attach/detach on both core cell(s) in dual-core BTS.
    ...    -18.09.2021,zheyuan.chen@nokia-sbell.com,case draft
    ...    contain CB006615_A_FR2_019_NSA_Call_on_BothCore_in_dual-core_gNB
    [Tags]    CRT_22R1    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_22R4    CB007876_A
    [Setup]    case_setup
    Check BTS Should Be Normal
#    Change eNB Nrcellid    Actual_value=2076571
    6615_case19_steps
    7876_case19_steps
#    Change eNB Nrcellid    Actual_value=2074843
    [Teardown]    robot_common_operations.Common Case Teardown

[1]CB006615_A_FR2_019_NSA_Call_on_BothCore_in_dual-core_gNB
    [Tags]    CRT_22R1    CRT_TRUNK    CRT_22R2    CRT_22R3    CB006615_A
    [Setup]    robot_common_operations.Common case Setup
    Should Be Equal As Strings   ${PREV_TEST_STATUS}   PASS
    [Teardown]    robot_common_operations.Common Case Teardown

*** Keywords ***
case_setup
    [Arguments]    ${scf_file_path_4G}=${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/SCF_Trunk_707_4G.xml
    robot_common_operations.Common Case Setup
    Commission Default SCF    ip_address=${eNB2_OAM_IP}    default_scf=${scf_file_path_4G}
    Reboot UE by ADB Command
    
Power Off And Power On Repeat 3times
    [Arguments]    ${poweroff_list}    ${status_list}    ${RU_index}
    FOR    ${item}    IN RANGE    ${3}
        Power Off RU    model=${poweroff_list[0]}    RU_PDU_IP=${poweroff_list[1]}    RU_PDU_PORT=${poweroff_list[2]}
        Check RU Disabled Status And Alarm     expected_RU=${status_list[0]}   RMOD_index=${status_list[1]}     cell_info=${status_list[2]}
        Check Other RUs Normal    RU_list=${RU_list}    RU_index=${RU_index}
        Power On RU    model=${poweroff_list[0]}    RU_PDU_IP=${poweroff_list[1]}    RU_PDU_PORT=${poweroff_list[2]}
        Check BTS Should Be Normal
        Check RU Status And Alarm    expected_RU=${status_list[0]}    cell_info=${status_list[2]}
    END

Check RU Disabled Status And Alarm
    [Arguments]    ${expected_RU}    ${RMOD_index}    ${cell_info}
    Check Fiber Status    expected_RU=${expected_RU}
    ...    expect_operate_status=Disabled    expect_usage_status=Idle    expect_procedure_status=not initialized
    wait until keyword succeeds    5min    5s    Check Expected Alarm    RMOD_index=${RMOD_index}
    wait until keyword succeeds    5min    5s    Check Cells Status    cell_info=${cell_info}    operational_status=Disabled
    ...    usage_status=Idle

Check RU Status And Alarm
    [Arguments]    ${expected_RU}    ${cell_info}
    Check Fiber Status    expected_RU=${expected_RU}
    wait until keyword succeeds    5min    5s    Check No Expected Alarm
    wait until keyword succeeds    5min    5s    Check Cells Status    cell_info=${cell_info}

_get_poweroff_value_from_ru_dictionary
    [Arguments]    ${RU_index}
    ${model}    get from dictionary    ${RU_index}    PB_model
    ${PDU_IP}    get from dictionary    ${RU_index}    PDU_IP
    ${PDU_PORT}    get from dictionary    ${RU_index}    PDU_PORT
    ${poweroff_list}    create list    ${model}    ${PDU_IP}    ${PDU_PORT}
    [Return]    ${poweroff_list}

_get_status_value_from_ru_dictionary
    [Arguments]    ${RU_index}
    ${serial_number}    get from dictionary    ${RU_index}    RU_SN
    ${index}    get from dictionary    ${RU_index}    index
    ${cell_info}    get from dictionary    ${RU_index}     cell_info
    ${status_list}    create list    ${serial_number}    ${index}    ${cell_info}
    [Return]    ${status_list}

_get_other_ruindex
    [Arguments]    ${RU_list}    ${RU_index}
#    ${RU_index_list}    create list    ${0}    ${1}    ${2}    ${3}    ${4}
    ${RU_index_list}    create list    ${0}    ${1}    ${2}
    ${ru_i}     get index from list    ${RU_list}    ${RU_index}
    remove from list    ${RU_index_list}    ${ru_i}
    log    ${RU_index_list}
    [Return]    ${RU_index_list}

Check Other RUs Normal
    [Arguments]    ${RU_list}    ${RU_index}
    ${OtherRU_index_list}    _get_other_ruindex    RU_list=${RU_list}    RU_index=${RU_index}
    FOR    ${item}    IN    @{OtherRU_index_list}
        ${status_list}    _get_status_value_from_ru_dictionary    RU_index=${RU_list[${item}]}
        Check Fiber Status    expected_RU=${status_list[0]}
        wait until keyword succeeds    5min    5s    Check Cells Status    cell_info=${status_list[2]}
    END

Lock Primary Cells And Check UE Attach Fail
    [Arguments]    ${cellgrp_idx}=${0}    ${primary_ue_index}=${0}    ${secondary_ue_index}=${1}
    Log To Console    primary cells
    Lock Cellgroup    cellgrp_idx=${cellgrp_idx}
    UE Attach Failed    ue_index=${primary_ue_index}
    UE Attach Success    ue_index=${secondary_ue_index}
#    Log To Console    sleep 15min
#    sleep    15min
    [Teardown]    Unlock Cellgroup    cellgrp_idx=${cellgrp_idx}

Lock Secondary Cells And Check UE Attach Fail
    [Arguments]    ${cellgrp_idx}=${1}    ${ue_index}=${1}
    Log To Console    secondary cells
    Lock Cellgroup    cellgrp_idx=${cellgrp_idx}
    UE Attach Failed    ue_index=${ue_index}
#    Log To Console    sleep 15min
#    sleep    15min
    [Teardown]    Unlock Cellgroup    cellgrp_idx=${cellgrp_idx}

Check UE Normal And Detach Succeed
    [Arguments]    ${tp_nrcell_list}    ${ue_index}=${0}    ${port}=${0}
    ${connection}    Start Catch Trace Log And UE Attach    DU_OAM_IP=${eNB1_OAM_IP}    connection=eNB
    ...    command=tcpdump -s0 -i br1 -w /tmp/enb.pcap &    tp_nrcell_list=${tp_nrcell_list}    ue_index=${ue_index}    port=${port}
    sleep    5s
    Stop And Copy Log To UTE    connection=${connection}    filename=enb.pcap
    run keyword and continue on failure    Check eNB Detach Succeed    pcap_filename=enb.pcap    txt_filename=enb.txt

6615_case11_steps
    Log To Console    6615 case11 steps
    Lock RMOD    RMOD_idx=${1}    ip_address=${eNB2_OAM_IP}    BTS_ID=${eNB2_BTS_ID}
    Single UE Attach And Start Traffic And Check Throughput    tp_nrcell_list=${AEWD1_nrcell_list}
    Reset RMOD    RU_index=${1}
    Check BTS Should Be Normal
    Single UE Attach And Start Traffic And Check Throughput    tp_nrcell_list=${AEWD1_nrcell_list}
    Restart BBMOD    BBMOD_idx=${1}
    Check BTS Should Be Normal
    run keyword and continue on failure    Check if Unexpected History Alarm Exist
    Single UE Attach And Start Traffic And Check Throughput    tp_nrcell_list=${AEWD1_nrcell_list}
    [Teardown]    Unlock RMOD    RMOD_idx=${1}    ip_address=${eNB2_OAM_IP}    BTS_ID=${eNB2_BTS_ID}

7876_case11_steps
    Log To Console    7876 case11 steps
    Lock RMOD    RMOD_idx=${1}    ip_address=${eNB1_OAM_IP}    BTS_ID=${eNB1_BTS_ID}
    Single UE Attach And Start Traffic And Check Throughput    tp_nrcell_list=${AEWD2_nrcell_list}    ue_index=${2}    port=${2}
    Single UE Attach And Start Traffic And Check Throughput    tp_nrcell_list=${AWEUA2_nrcell_list}    ue_index=${3}    port=${3}
    Reset RMOD    RU_index=${3}
    Check BTS Should Be Normal
    Single UE Attach And Start Traffic And Check Throughput    tp_nrcell_list=${AEWD2_nrcell_list}    ue_index=${2}    port=${2}
    Reset RMOD    RU_index=${4}
    Check BTS Should Be Normal
    Single UE Attach And Start Traffic And Check Throughput    tp_nrcell_list=${AWEUA2_nrcell_list}    ue_index=${3}    port=${3}
    Restart BBMOD    BBMOD_idx=${3}
    Check BTS Should Be Normal
    run keyword and continue on failure    Check if Unexpected History Alarm Exist
    Single UE Attach And Start Traffic And Check Throughput    tp_nrcell_list=${AEWD2_nrcell_list}    ue_index=${2}    port=${2}
    Single UE Attach And Start Traffic And Check Throughput    tp_nrcell_list=${AWEUA2_nrcell_list}    ue_index=${3}    port=${3}
    [Teardown]    Unlock RMOD    RMOD_idx=${1}    ip_address=${eNB1_OAM_IP}    BTS_ID=${eNB1_BTS_ID}

6615_case12_steps
    Log To Console    6615 case12 steps
    Lock RMOD    RMOD_idx=${1}    ip_address=${eNB2_OAM_IP}    BTS_ID=${eNB2_BTS_ID}
    Single UE Attach And Start Traffic And Check Throughput    tp_nrcell_list=${AWEUA1_nrcell_list}    ue_index=${1}    port=${1}
    Reset RMOD    RU_index=${2}
    Check BTS Should Be Normal
    Single UE Attach And Start Traffic And Check Throughput    tp_nrcell_list=${AWEUA1_nrcell_list}    ue_index=${1}    port=${1}
    Restart BBMOD    BBMOD_idx=${2}
    Check BTS Should Be Normal
    run keyword and continue on failure    Check if Unexpected History Alarm Exist
    Single UE Attach And Start Traffic And Check Throughput    tp_nrcell_list=${AWEUA1_nrcell_list}    ue_index=${1}    port=${1}
    [Teardown]    Unlock RMOD    RMOD_idx=${1}    ip_address=${eNB2_OAM_IP}    BTS_ID=${eNB2_BTS_ID}

7876_case12_steps
    Log To Console    7876 case12 steps
    Lock RMOD    RMOD_idx=${1}    ip_address=${eNB1_OAM_IP}    BTS_ID=${eNB1_BTS_ID}
    Lock RMOD    RMOD_idx=${4}
    Single UE Attach And Start Traffic And Check Throughput    tp_nrcell_list=${AWEUA3_nrcell_list}    ue_index=${3}    port=${3}
    Reset RMOD    RU_index=${5}
    wait until keyword succeeds    10min    10s    Check Cells Status    cell_info=@{AWEUA3_cell_info}
    Single UE Attach And Start Traffic And Check Throughput    tp_nrcell_list=${AWEUA3_nrcell_list}    ue_index=${3}    port=${3}
    Restart BBMOD    BBMOD_idx=${4}
    wait until keyword succeeds    10min    10s    Check Cells Status    cell_info=@{AWEUA3_cell_info}
    run keyword and continue on failure    Check if Unexpected History Alarm Exist
    Single UE Attach And Start Traffic And Check Throughput    tp_nrcell_list=${AWEUA3_nrcell_list}    ue_index=${3}    port=${3}
    [Teardown]    run keywords    Unlock RMOD    RMOD_idx=${4}
    ...    AND    Unlock RMOD    RMOD_idx=${1}    ip_address=${eNB1_OAM_IP}    BTS_ID=${eNB1_BTS_ID}

6615_case19_steps
    Log To Console    6615 case19 steps
#    Lock RMOD    RMOD_idx=${1}    ip_address=${eNB2_OAM_IP}    BTS_ID=${eNB2_BTS_ID}
    Lock RMOD    RMOD_idx=${3}    
#    Single UE Attach And Start Traffic And Check Throughput    tp_nrcell_list=${AEWD1_nrcell_list}
    Single UE Attach And Start Traffic And Check Throughput    tp_nrcell_list=${AWEUA1_nrcell_list}    ue_index=${1}    port=${1}
#    Lock Primary Cells And Check UE Attach Fail
#    Lock Secondary Cells And Check UE Attach Fail
    Unlock RMOD    RMOD_idx=${3}
    Check BTS Should Be Normal
#    Single UE Attach And Start Traffic And Check Throughput    tp_nrcell_list=${AEWD1_nrcell_list}
#    Single UE Attach And Start Traffic And Check Throughput    tp_nrcell_list=${AWEUA1_nrcell_list}    ue_index=${1}    port=${1}
    Reset BTS And Wait Until On Air
    run keyword and continue on failure    Check if Unexpected History Alarm Exist
    ${Alarm_status}    run keyword and return status    Check if Unexpected History Alarm Exist
    run keyword if  not ${Alarm_status}    Save Snapshot Log
#    run keyword and ignore error    Check UE Normal And Detach Succeed    tp_nrcell_list=${AEWD1_nrcell_list}
#    run keyword and ignore error    Check UE Normal And Detach Succeed    tp_nrcell_list=${AWEUA1_nrcell_list}
    ...    ue_index=${1}    port=${1}
#    [Teardown]    Unlock RMOD    RMOD_idx=${1}    ip_address=${eNB2_OAM_IP}    BTS_ID=${eNB2_BTS_ID}

7876_case19_steps
    Log To Console    7876 case19 steps
#    Lock RMOD    RMOD_idx=${1}    ip_address=${eNB1_OAM_IP}    BTS_ID=${eNB1_BTS_ID}
    Lock RMOD    RMOD_idx=${2}
#    Single UE Attach And Start Traffic And Check Throughput    tp_nrcell_list=${AEWD2_nrcell_list}    ue_index=${2}    port=${2}
#    Single UE Attach And Start Traffic And Check Throughput    tp_nrcell_list=${AWEUA3_nrcell_list}    ue_index=${3}    port=${3}
#    Lock Primary Cells And Check UE Attach Fail    cellgrp_idx=${2}    primary_ue_index=${2}    secondary_ue_index=${3}
#    Lock Secondary Cells And Check UE Attach Fail    cellgrp_idx=${4}    ue_index=${3}
#    wait until keyword succeeds    10min    10s    Check Cells Status    cell_info=@{AWEUA3_cell_info}
    Single UE Attach And Start Traffic And Check Throughput    tp_nrcell_list=${AEWD2_nrcell_list}    ue_index=${2}    port=${2}
#    Single UE Attach And Start Traffic And Check Throughput    tp_nrcell_list=${AWEUA3_nrcell_list}    ue_index=${3}    port=${3}
    Unlock RMOD    RMOD_idx=${2}
    Reset BTS And Wait Until On Air
    run keyword and continue on failure    Check if Unexpected History Alarm Exist
    ${Alarm_status}    run keyword and return status    Check if Unexpected History Alarm Exist
    run keyword if  not ${Alarm_status}    Save Snapshot Log
#    [Teardown]    run keywords    Unlock RMOD    RMOD_idx=${4}
#    ...    AND    Unlock RMOD    RMOD_idx=${1}    ip_address=${eNB1_OAM_IP}    BTS_ID=${eNB1_BTS_ID}

Suite Setup
    Log To Console    Suite Setup
#    ${default_scf}    suite setup to prepare default scf    SBTS_scf_name=SCF_SBTS00_7876A.xml    22R3_scf_name=SCF_SBTS22R3.xml
#    ...    22R2_scf_name=SCF_SBTS22R2_7876A.xml
#    Commission Default SCF    default_scf=${default_scf}
    Suite variable

Suite variable
    set suite variable    &{AEWD1_dic}      RU_SN=AH195002696    index=${1}    PDU_IP=${AEWD1_PDU_IP}    PDU_PORT=${AEWD1_PDU_PORT}
    ...    cell_info=@{AEWD1_cell_info}    PB_model=TOPYOUNG
    set suite variable    &{AWEUA1_dic}    RU_SN=AH204600565    index=${2}    PDU_IP=${AWEUA1_PDU_IP}    PDU_PORT=${AWEUA1_PDU_PORT}
    ...    cell_info=@{AWEUA1_cell_info}    PB_model=HBTE
    set suite variable    &{AEWD2_dic}      RU_SN=AH195002648    index=${3}    PDU_IP=${AEWD2_PDU_IP}    PDU_PORT=${AEWD2_PDU_PORT}
    ...    cell_info=@{AEWD2_cell_info}    PB_model=TOPYOUNG
    set suite variable    &{AWEUA2_dic}    RU_SN=AH221900062    index=${4}    PDU_IP=${AWEUA2_PDU_IP}    PDU_PORT=${AWEUA2_PDU_PORT}
    ...    cell_info=@{AWEUA2_cell_info}    PB_model=HBTE
    set suite variable    &{AWEUA3_dic}    RU_SN=AH204600135    index=${5}    PDU_IP=${AWEUA3_PDU_IP}    PDU_PORT=${AWEUA3_PDU_PORT}
    ...    cell_info=@{AWEUA3_cell_info}    PB_model=HBTE
#    @{RU_list}    create list    ${AEWD1_dic}    ${AWEUA1_dic}   ${AEWD2_dic}    ${AWEUA2_dic}    ${AWEUA3_dic}
    @{RU_list}    create list    ${AEWD1_dic}    ${AWEUA1_dic}   ${AEWD2_dic}
    set suite variable     @{RU_list}
