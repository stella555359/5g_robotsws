*** Settings ***
Force Tags    PY36
Documentation
...    Author: Tingting Dong
...    Contact: tingting.dong@nokia-sbell.com
...    Group: VRF_HAZ3_2
...    Feature: CB010696

Suite Setup         run keywords    Setup Suite For Cloud    AND    Set_scf_name_for_cases
#Suite Setup         Setup Suite For Cloud
Test Setup          Setup Test For Cloud
Test Teardown       Teardown Test For Cloud
Suite Teardown      Teardown Suite For Cloud
#Resource          ../CB010411/Resource/CB010411_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG08_keywords_cloud.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot

*** Variables ***
${scf_path_cu}    ${commissionings_path}/HGZ/${testline_name}/gnbs_0/cu
${scf_path_du}    ${commissionings_path}/HGZ/${testline_name}/gnbs_0/dus_0

*** Test Cases ***
[1][1.1] General_SiSo_Commissioning_BTS_Template_Commissioning
    Log to console    \n CB010696 Commissioning test
    commission scf    vdu_scf_path=${scf_path_du}/${scf_name_du_AVQE_AQQC}    cu_scf_path=${scf_path_cu}/${scf_name_cu_AVQE_AQQC}

[1][1.0] General_SiSo_Commissioning_BTS_Recommissioning
    Log to console    \n CB010696 Recommissioning test
    commission scf    vdu_scf_path=${scf_path_du}/${scf_name_du_AVQE_AQQC}    cu_scf_path=${scf_path_cu}/${scf_name_cu_AVQE_AQQC}

[1][2.1] General_SiSo_Cell_block_and_unblock
    Log to console    \n CB010696 Cell_block_and_unblock test
    Cell_block_and_unblock

[1][2.0] General_SiSo_RU_module_reset_from_GUI
    Log to console    \n CB010696 RU_module_reset_from_GUI test
    RU_module_Reset_from_Web

[1][1.1] General_SiSo_E2E_system_setup_with_data_transfer_conducted
    Log to console    \n CB010696 data_transfer_conducted test
#    Log to console    \n Manual test passed, scripts debug and update later
    Basic_L3_call

*** Keywords ***
Basic_L3_call
    [Arguments]    ${ue_index}=${0}    ${dl_tp}=50    ${ul_tp}=3    ${duration}=30    ${target_avg_percent}=0.9
    [Documentation]    params ${dl_tp}, ${ul_tp} unit:Mbits/sec
    log to console    \n***Prepare UE***
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
# Here we use keyword from ue.py to get last value of TL ue capabilities.
# It can also be hard coded with ue_type like ue_type=nokia_fastmile.
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}

    log to console    \n***UE Detach ***
    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}


    log to console    \n***UE Attach***
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}     log_type=aasyslog

    log to console    \n***start traffic***
    ${start_traffic_duration}    evaluate    ${duration}+${60}
# If huawei_sigspark.Start traffic, :paramthroughput should be like "100Kbits/sec", MKbits/sec, MKByte/sec ...
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}Mbits/sec
    ...    duration=${start_traffic_duration}    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}Mbits/sec
    ...    duration=${start_traffic_duration}    ue_index=${ue_index}
#    power_ue.Collect Tput    ue_type=${ue_type}    duration=${duration}    check_source=aasyslog
    ${Tput_logs}    power_ue.Collect Tput    ue_type=${ue_type}    duration=${duration}
# check_source can be iperf when ue_type support iperf checking. Same for attach and check tput

    log to console    \n***Stop traffic ***
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}

    log to console    \n***check tput ***
#    ${cells}    create list    ${607617026}
    power_ue.Check Tput    ue_type=${ue_type}    direction=dl    target_throughput=${dl_tp}    log=${Tput_logs}
    ...    target_avg_percent=${target_avg_percent}    ue_index=${ue_index}
    power_ue.Check Tput    ue_type=${ue_type}    direction=ul    target_throughput=${ul_tp}    log=${Tput_logs}
    ...    target_avg_percent=${target_avg_percent}    ue_index=${ue_index}

# ***UE Detach ***
#    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}
    log to console    \nBasic_L3_call test passed

Set_scf_name_for_cases
    set suite variable    ${scf_name_cu_AVQE_AQQC}    SCF_SBTS${release_cu}_${version_cu}_AVQE_AQQC.xml
    set suite variable    ${scf_name_du_AVQE_AQQC}    SCF_SBTS${release_du}_${version_du}_AVQE_AQQC.xml
#SCF_SBTS24R2_0.250_AVQE_AQQC
#SCF_SBTS24R2_0.300_AVQE_AQQC


Cell_block_and_unblock
    [Arguments]     ${tput_self_define}=null    ${target_avg_percent}=0.95
    ...    ${min_percent}=0.85    ${duration}=600    ${process_num}=3    ${fault_check}=True
    ${cell_number}    Get vDU Cell numbers
    FOR    ${index}    IN RANGE    1    ${cell_number}+1
        log to console    \nblock cell ${index} for du...
        Block Cell In vDU    cell_id=${index}
        log to console    check cell ${index} should be blocked for du...
        wait until keyword succeeds     3min    5s    Check Cell Should Be Blocked On vDU    cell_id=${index}
        Run keyword If    ${fault_check}==True    Expect Fault Should Present On vDU    fault_id=49
        ...                                       alarming_object=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${index}
    END
    log to console    check cell should be disabled for cu...
    Verify All Cells Are Disabled for CU
    FOR    ${index}    IN RANGE    1    ${cell_number}+1
        log to console    unblock cell ${index} for du...
        Unblock Cell In vDU   cell_id=${index}
    END
    log to console    check cell status should be on air for du...
    wait until keyword succeeds     3min    5s    Verify All Cells Status Should Be Onair for vDU
    log to console    check cell status should be  enabled for cu...
    wait until keyword succeeds     3min    5s    Verify All Cells Are Enabled for CU
#    Run keyword If    ${tput_self_define}!=null    log to console    make call on cells
#    Run keyword If    ${tput_self_define}!=null
#    ...    data_transfer_common    tput_self_define=${tput_self_define}    target_avg_percent=${target_avg_percent}
#    ...    min_percent=${min_percent}    ue_type=${ue_type_NR}    duration=${duration}    process_num=${process_num}
#    ...    appserver=APPserversim
    [Teardown]    Run keyword and ignore error    Unblock Cells In vDU

RU_module_Reset_from_Web
    [Arguments]    ${tput_self_define}=null    ${target_avg_percent}=0.95
    ...    ${min_percent}=0.85    ${duration}=30    ${process_num}=3
    ${rmods}    Get Rmod List
    log to console    reset ru for du
    Reset Rmod By Rest    rmods_list=${rmods}
    log to console    check cell status should be disabled for du...
    wait until keyword succeeds     3min    5s    Verify All Cells Are Disabled for vDU
    log to console    check cell status should be disabled for cu...
    wait until keyword succeeds     3min    5s    Verify All Cells Are Disabled for CU
#    log to console    check fault 10 reported on du
#    Expect Fault Should Present On vDU    fault_id=10
    log to console    check cell should be on air for du...
    wait until keyword succeeds     5min    5s    Verify All Cells Status Should Be Onair for vDU
    log to console    check cell should be on air for cu...
    wait until keyword succeeds     5min    5s    Verify All Cells Are Enabled for CU
    log to console    check fault 10 canceled on du
    Expect Fault Should Absent On vDU    fault_id=10
#    Run keyword If    ${tput_self_define}!=null    log to console    make call on cells
#    Run keyword If    ${tput_self_define}!=null
#    ...    data_transfer_common    tput_self_define=${tput_self_define}    target_avg_percent=${target_avg_percent}
#    ...    min_percent=${min_percent}    ue_type=${ue_type_NR}    duration=${duration}    process_num=${process_num}
#    ...    appserver=APPserversim