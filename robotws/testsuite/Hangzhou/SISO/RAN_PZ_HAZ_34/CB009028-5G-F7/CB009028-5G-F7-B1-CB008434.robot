*** Settings ***
Documentation
...   author: zheyuan.chen@nokia-sbell.com
...   contact: zheyuan.chen@nokia-sbell.com
...   SISO

Suite Setup       Case Suite Setup
Suite Teardown    Case Suite Teardown

Resource    ../CB008434-SR/resources/comm_8434.robot
Resource    ./resources/comm_9028.robot
Resource    ../../../resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Test Cases ***
[2][1.0] CB008434_01_Super cell Setup and delete
    [Documentation]
    ...    The purpose of this test is to verify that super cell with up to max sub-cells for different BBMOD by the legacy user
    ...    plane deployment with CPRI/eCPRI fronthaul connection can setup and be deleted succussfully without any unexpected alarm and
    ...    super cell deletion successfully
    ...    -21.02.2023,zheyuan.chen@nokia-sbell.com,case draft
    [Tags]    CRT_23R3    CRT_TRUNK    CB009028
    [Setup]    Case Setup_normal
    Check One RU Throughput    nrcell_id=184755    port_value2=${0}
    Setup Supercell On Line
    Check BTS Should Be Normal
    Check History And Active Alarm
    Check One RU Throughput    nrcell_id=184753    port_value1=${0}
    Check One RU Throughput    nrcell_id=184753    port_value3=${0}
    Check RU Peak Throughput    nrcell_id=184753
    Input SCF    scf_name=_normal.xml
    Check History And Active Alarm
    Check One RU Throughput    nrcell_id=184758    port_value4=${0}
    [Teardown]    robot_common_operations.Common case Teardown

[2][2.0] CB008434_03_Super_Cell_Reconfiguration
    [Documentation]
    ...    The purpose of this test is to verify that super cells reconfiguration, including super expansion, deletion, and split.
    ...    -21.02.2023,zheyuan.chen@nokia-sbell.com,case draft
    [Tags]    CRT_23R3    CRT_TRUNK    CB009028
    [Setup]    Case Setup_supercell
    @{channelgrp_list}    create list    ${5}    ${6}
    Delete TL3 Channelgroup    channelgrp_list=${channelgrp_list}
    Check BTS Should Be Normal
    Check Unexpected Active Alarm
    Check Subcell Status    expected_list_length=${8}
    Check Number Of Subcell    expected_numofsubcells=${4}
    Check One RU Throughput    nrcell_id=184753    port_value2=${0}
    Check RU Peak Throughput    nrcell_id=184753
    Add TL3 Channelgroup    channelgrp_list=${channelgrp_list}
    Check BTS Should Be Normal
    Check Unexpected Active Alarm
    Check Subcell Status    expected_list_length=${12}
    Check Number Of Subcell    expected_numofsubcells=${6}
    Check RU Peak Throughput    nrcell_id=184753
    [Teardown]    robot_common_operations.Common case Teardown

[2][1.0] General_SiSo_RU_lock_unlock
    [Documentation]
    ...    The purpose of this test case is to verify that radio module and OAM behaves correctly during procedure of locking and unlocking.
    ...    -22.02.2023,zheyuan.chen@nokia-sbell.com,case draft
    [Tags]    CRT_23R3    CRT_TRUNK    CB009028
    [Setup]    Case Setup_supercell
    SBTS Login
    Lock RU And Check Locked Status    RMOD_idx=${3}    expected_RU=EB2232R0670    number=${6}    expect_admin_status=Locked
    ...    expect_usage_status=Idle    expect_procedure_status=configured
    Lock RU And Check Locked Status    RMOD_idx=${4}    expected_RU=EB2234R0007    number=${6}    expect_admin_status=Locked
    ...    expect_usage_status=Idle    expect_procedure_status=configured
    run keyword and continue on failure    Check One RU Throughput    nrcell_id=184753    port_value3=${0}
    run keyword and continue on failure    Check One RU Throughput    nrcell_id=184753    port_value4=${0}
    Unlock RU And Check Status    RMOD_idx=${3}    expected_RU=EB2232R0670    number=${6}
    Unlock RU And Check Status    RMOD_idx=${4}    expected_RU=EB2234R0007    number=${6}
    Log To Console    wait until bts should be normal
    wait until bts should be normal
    [Teardown]    run keywords    SBTS Logout    AND    robot_common_operations.Common case Teardown

[1][1.0] General_SiSo_BB_sub-unit_reset_with_L3_call
    [Documentation]
    ...    The purpose of this test case is to verify correctness of BB sub-unit (ABIL) reset procedure (by using provisioning plan),
    ...    triggered by an operator in WebEM. Verification with L3 call.
    ...    -22.02.2023,zheyuan.chen@nokia-sbell.com,case draft
    [Tags]    CRT_23R3    CRT_TRUNK    CB009028
    [Setup]    Case Setup_supercell
    SBTS Login
    Reset BBMOD    BBMOD_idx=${1}
    Log To Console    wait until bts should be normal
    wait until bts should be normal
    Check if Unexpected Active Alarm Without Login
#    Check RU Peak Throughput    nrcell_id=184753
    Check One RU Throughput    nrcell_id=184753    port_value1=${0}
    [Teardown]    run keywords    SBTS Logout    AND    robot_common_operations.Common case Teardown

*** Keywords ***
case teardown case3
    SBTS Logout
    Run Keyword if    "${TEST_STATUS}"=="FAIL"    Save Snapshot
    robot_common_operations.Common case Teardown


Input SCF
    [Arguments]    ${scf_name}=.xml
    ${default_scf}    suite setup to prepare default SCF
    ${default_scf}    set variable    ${default_scf}${scf_name}
    Commission Default SCF    default_scf=${default_scf}

Check One RU Throughput
    [Arguments]    ${nrcell_id}    ${ue_sn}=${UE0_SN}    ${port_value1}=${max_att_value}    ${port_value2}=${max_att_value}
    ...    ${port_value3}=${max_att_value}    ${port_value4}=${max_att_value}    ${tp_ul}=50M    ${tp_dl}=500M    ${target_tp_ul}=1
    ...    ${target_tp_dl}=200
    Log To Console    Check One RU Throughput
    Adjust HBTE Attenuation    port_value1=${port_value1}     port_value2=${port_value2}    port_value3=${port_value3}
    ...    port_value4=${port_value4}
    sleep    10s
    Xiaomi_UE_Attach    ue_sn=${ue_sn}
    Xiaomi_Start Traffic And Check TP    ue_sn=${ue_sn}    tp_ul=${tp_ul}    tp_dl=${tp_dl}    target_tp_ul=${target_tp_ul}
    ...    target_tp_dl=${target_tp_dl}    nrcell_id=${nrcell_id}
    Stop Traffic And UE Detach
    sleep    3s

Check RU Peak Throughput
    [Arguments]    ${nrcell_id}    ${ue_sn}=${UE1_SN}    ${tp_ul}=200M    ${tp_dl}=1500M    ${target_tp_ul}=80    ${target_tp_dl}=1380
    ...    ${target_avg_percent}=${0.6}    ${ue_index}=${1}
    Log To Console    Check RU Peak Throughput
    Xiaomi_UE_Attach    ue_sn=${ue_sn}    ue_index=${ue_index}
    Xiaomi_Start Traffic And Check TP    ue_sn=${ue_sn}    tp_ul=${tp_ul}    tp_dl=${tp_dl}    target_tp_ul=${target_tp_ul}
    ...    target_tp_dl=${target_tp_dl}    nrcell_id=${nrcell_id}    target_avg_percent=${target_avg_percent}    ue_index=${ue_index}
    Stop Traffic And UE Detach    ue_index=${ue_index}
    sleep    3s

Setup Supercell On Line
    Log To Console    setup supercell
    WEBUI Login
    Activate TL3 Supercell And Add Channelgroup
    Delete TL3 Nrcells Data
    ${error}    selenium_coam.validate_plan
    Log To Console    ${error}
    Log To Console    Activate plan
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    [Teardown]    WEBUI Logout

Lock RU And Check Locked Status
    [Arguments]    ${RMOD_idx}    ${expected_RU}    ${number}    ${expect_admin_status}    ${expect_usage_status}
    ...    ${expect_procedure_status}
    Lock RMOD    RMOD_idx=${RMOD_idx}
    Check RMOD Status    expected_RU=${expected_RU}    number=${number}    expect_admin_status=${expect_admin_status}
    ...    expect_usage_status=${expect_usage_status}    expect_procedure_status=${expect_procedure_status}

Unlock RU And Check Status
    [Arguments]    ${RMOD_idx}    ${expected_RU}    ${number}
    Unlock RMOD    RMOD_idx=${RMOD_idx}
    sleep    3s
    Check RMOD Status    expected_RU=${expected_RU}    number=${number}

Case Suite Setup
    CI_interface.Common Suite Setup
    robot_common_operations.Common Suite Setup
    Adapt to ute cloud commission scf

Case Suite Teardown
    robot_common_operations.Common Suite Teardown
    Input SCF    

Case Setup_normal
    robot_common_operations.Common case Setup
    Input SCF    scf_name=_normal.xml

Case Setup_supercell
    robot_common_operations.Common case Setup
    Input SCF    scf_name=_supercell.xml
