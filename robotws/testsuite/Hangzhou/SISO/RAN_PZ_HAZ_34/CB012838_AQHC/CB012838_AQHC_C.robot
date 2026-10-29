*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup    allowed_faults_ids=4291
Test Teardown        SISO Coam Test Teardown    allowed_faults_ids=4291
Test Timeout         3h

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_LTE.robot
Resource    ${BASIC_PATH_COMMON}/SBTS_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RU_lock_unlock.robot
Resource    ${BASIC_PATH_5G}/BTS/Manual_SiSo_SM_NR_RAT_reset.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Commissioning_BTS_Template_Commissioning.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/basic/simple_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/ue.robot


Documentation
...    Author:Wu Jerry
...    contact:jerry.wu@nokia-sbell.com
...    squad group:mmw02
...    Feature CB012838 in trunk program

Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G    STATE_SW_UPLOADED
...   PY310

*** Variables ***
${if_commissioning}    True

*** Test Cases ***
[1]CB012838-C_18_General_SiSo_E2E_system_setup_with_data_transfer_for_conducted_multicarrier_MADE2_radio_30M_NR+3x20M_LTE
    [Documentation]    basic L3call with MTK M80
    [Tags]    AQHC
    AlarmWatchdog.add_allow_alarms    fault_id=4291
    L3 Call NR and LTE    nr_dl_tp=408    nr_ul_tp=51    lte_dl_tp=125   lte_ul_tp=12    scf_path=${SCF_Path}
    AlarmWatchdog.remove_allow_alarms    fault_id=4291

[1]CB012838-C_2_General_SiSo_Commissioning_BTS_Template_Commissioning
    General_SiSo_Commissioning_BTS_Template_Commissioning

[1]CB012838-C_19_General_SiSo_E2E_system_setup_with_data_transfer_for_conducted_multicarrier_MADE2_radio_2x10M_NR+2x10M_LTE
    [Tags]    AQHC
    ${SCF_Path}    Replace String    ${Golden_SCF_Path}    .xml    _2x10NR_2x10LTE.xml
    Commissioning SCF And Check On Air for Common    scf_path=${SCF_Path}
    L3 Call NR and LTE    nr_dl_tp=100    nr_ul_tp=9.6    lte_dl_tp=60   lte_ul_tp=7    scf_path=${SCF_Path}

*** Keywords ***
L3 Call NR and LTE
    [Arguments]  ${nr_dl_tp}    ${nr_ul_tp}    ${lte_dl_tp}    ${lte_ul_tp}    ${log}=${SAVE LOG DIRECTORY}
    ...    ${scf_path}=${Case_SCF_Path}    ${gnb_ssl_connection}=GNB_OAM
    ${ue_info_dict}    create dictionary
    ${nr_cell_id_list}    Get All Cell Id    cell_type=nr
    ${nr_ue_index_list}    ${nr_cell_list}    Get UE List for Given Cell List    cell_list=${nr_cell_id_list}
	...    scf_path=${scf_path}
    ${lte_cell_id_list}    Get All Cell Id    cell_type=lte
    ${lte_ue_index_list}    ${lte_cell_list}    Obtain UE List for Given Cell List    cell_list=${lte_cell_id_list}
    ...    scf_path=${scf_path}
    ${ue_index_list}    combine lists    ${nr_ue_index_list}    ${lte_ue_index_list}
    Simple Ue Prepare    ue_index_list=${ue_index_list}
    Simple Ue Attach_local    ue_index_list=${nr_ue_index_list}    log_type=Aasyslog
    Simple Ue Attach_local    ue_index_list=${lte_ue_index_list}    log_type=Iperf
    Simple Ue Start DL UL Traffic    ue_index_list=${nr_ue_index_list}    dl_tp=${nr_dl_tp}M    ul_tp=${nr_ul_tp}M    duration=${600}
    Simple Ue Start DL UL Traffic    ue_index_list=${lte_ue_index_list}    dl_tp=${lte_dl_tp}    ul_tp=${lte_ul_tp}    duration=${600}
    ${tput_log}    Simple Ue Collect Tput    ue_index_list=${nr_ue_index_list}    check_source=Aasyslog    duration=300
    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity    connection_alias=${gnb_ssl_connection}
    ${cell_id}    Convert To String    ${cell_mapping[${nr_cell_list[0]}]['nrCellIdentity']}
    ${cell_id}    Create List    ${cell_id}
    Simple Ue Stop DL UL Traffic    ue_index_list=${ue_index_list}
    Simple UE Verify Peak Throughput    ue_index_list=${nr_ue_index_list}    dl_tp=${nr_dl_tp}    ul_tp=${nr_ul_tp}
    ...    target_avg_percent=0.9    min_percent=0.8    log=${tput_log}    check_source=Aasyslog    cells=${cell_id}
    Simple UE Verify Peak Throughput    ue_index_list=${lte_ue_index_list}    dl_tp=${lte_dl_tp}    ul_tp=${lte_ul_tp}
    ...    target_avg_percent=0.9    min_percent=0.8    log=${log}
    Simple Ue Detach    ue_index_list=${ue_index_list}

Simple Ue Attach_local
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${ue_index_list}    ${log_type}=Iperf    ${scf_path}=${Golden_SCF_Path}    ${power_reset}=${False}
    ...    ${mobile_network_system}=LTE
    log to console    \nUe Attach
    FOR  ${ue_index}  IN  @{ue_index_list}
        ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
        ${pci}    Get Ue should attached pci    ue_index=${ue_index}    scf_path=${scf_path}    mobile_network_system=${mobile_network_system}
        ${status}    run keyword and return status      power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
        ...    log_type=${log_type}    pci=${pci}    power_reset=${power_reset}    timeout=900
        run keyword if    not ${status}      power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
        ...    log_type=${log_type}    pci=${pci}    power_reset=${False}    timeout=900
    END