*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup    allowed_faults_ids=4291
Test Teardown        SISO Coam Test Teardown    allowed_faults_ids=4291
Test Timeout         3h

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_COMMON}/SBTS_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/Cell/E2E_SiSo_Cell_block_and_unblock_gNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/basic/simple_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/ue.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py

Documentation
...    Author:Wu Jerry
...    contact:jerry.wu@nokia-sbell.com
...    squad group:mmw02
...    Feature CB012838 in trunk program

*** Variables ***
${if_commissioning}    True


*** Test Cases ***
[1]CB012838-A_4_General_SiSo_Cell_block_and_unblock
    AlarmWatchdog.add_allow_alarms    fault_id=49
    E2E_SiSo_Cell_block_and_unblock_gNB    with_call=False
    AlarmWatchdog.remove_allow_alarms    fault_id=49

[1]CB012838-A_12_General_SiSo_E2E_system_setup_with_data_transfer_for_conducted_multicarrier_MADE2_radio_IWK9496
    ${SCF_Path}    Replace String    ${Golden_SCF_Path}    .xml    _12838_A.xml
    Commissioning SCF And Check On Air for Common    scf_path=${SCF_Path}
#    ${list_of_cell_ids}    Create List    667649
    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity
    ${cell_id}    Set Variable    ${cell_mapping[1]['nrCellIdentity']}
    ${list_of_cell_ids}    Create List    ${cell_id}
    peak_throughput    cells=${list_of_cell_ids}    Case_SCF_Path=${SCF_Path}

*** Keywords ***
L3 call case teardown
    Run Keyword And Ignore Error    Run keywords
    ...    power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=${ue_type}    iperf_type=via_command
    ...    AND    power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=${ue_type}
    Run Keyword And Ignore Error    Power_ue.UE Detach    ue_index=${0}    ue_type=${ue_type}

peak_throughput
    [Arguments]    ${ue_index}=${0}    ${dl_tp}=704    ${ul_tp}=94    ${duration}=360    ${ul_iperf_process}=1    ${cap_duration}=300
	...    ${pci}=1    ${cells}=${cells}    ${Case_SCF_Path}=${Case_SCF_Path}
    [Documentation]    params ${dl_tp}, ${ul_tp} unit:Mbits/sec

    ${peak_dl}    ${peak_ul}    get_theoretical_throughput    scf_path=${Case_SCF_Path}
    ...                                                       cell_id=1
    ...                                                 ue_ul_layer=${2}    ue_dl_layer=${4}

    log to console    \n***Prepare UE***
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}

    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    log to console    \n***UE Detach ***

    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}

    log to console    \n***UE Attach***
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    pci=${pci}    log_type=aasyslog    timeout=900

    log to console    \n***start traffic***
    ${start_traffic_duration}    evaluate    ${duration}+${60}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}Mbits/sec
    ...    duration=${start_traffic_duration}    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}Mbits/sec
    ...    duration=${start_traffic_duration}    ue_index=${ue_index}    process_num=${ul_iperf_process}
    ${Tput_logs}    power_ue.Collect Tput    ue_type=${ue_type}    duration=${cap_duration}    check_source=aasyslog

    log to console    \n***Stop traffic ***
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}

    log to console    \n***check tput ***
#    ${cells}    create list    ${2146312}

	${all_tp}    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${Tput_logs}    cells=${cells}
	...    check_source=aasyslog
    ...    ultarget_throughput=${peak_ul}    dltarget_throughput=${peak_dl}    actCarrierAggregation=${False}
    [Teardown]  power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}