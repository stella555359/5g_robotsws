*** Settings ***
Documentation
...   Test suite for regression testing of TMO
...   author: Jack Zeng
...   contact: jack.zeng@nokia-sbell.com
Force Tags        5G_SISO    CA_VRF_HAZ4

Library      String
Library     taf.hw.rf_attenuator    WITH NAME    atten
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_LTE.robot
Resource     taf/rfrl/uuf4all/uuf4all_test_cases.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Resource    taf/rfrl/common_resources/robot/coam_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Library     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/E2E_TMO/Resources/delta.py
Resource    Resources/E2E_TMO_common_keyword.robot
Library     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/E2E_TMO/Resources/E2E_TMO_get_cell_info.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
##Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007834/resources/CB007834_5G_A_common_keyword.robot

Suite Setup       UUF4ALL common Suite Setup with alarm checking    if_commissioning=${False}
Suite Teardown    common_setups_and_teardowns.Common Suite Teardown

*** Variables ***
@{customers}             TMO US
${ue_type}           ${tl.ues[0].capabilities[0]}
${ue_index}     0
#${5g_source_sw}
##${target_version}          SBTS00_ENB_9999_230703_000008
##${5g_target_sw}          SBTS00_ENB_9999_230703_000008
${runs_of_uuf_upgrade_withcall}   ${1}
${runs_of_uuf_reset}     ${1}
${runs_of_bbmod_reset}   ${1}
${runs_of_rmod_reset}    ${1}
${runs_of_uuf_reset_withcall}     ${1}
${runs_of_bbmod_reset_withcall}   ${1}
${runs_of_rmod_reset_withcall}    ${1}
${runs_of_nrcel_lock_withcall}    ${1}
${runs_of_nrcel_block_withcall}    ${1}
${runs_of_delta_commission_withcall}    ${1}
${runs_of_delta_commission}    ${1}
@{critical_faults}       10    16    1806    1868    4341    4352    4383
@{custom_alarms}         7312    7313
${testline_name}
${CONFIGURATION}    HGZ.${testline_name}
${delta_file}    delta.json

${UL_THROUGHPUT}    10Mbits/sec
${DL_THROUGHPUT}    10Mbits/sec

${DURATION}    6000
${UL_EXPECT_TP}    0
${DL_EXPECT_TP}    0

${apn1}    ${tl.core.pdns[0].apn}
#${cell_disname}    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-1
#&{cell_used_in_test}    NRCEL=${cell_disname}
@{nrCellIdentitys}     148729877
${gnb_instance}    ${tl.gnbs[0].instance_id}
${att_port_1_cell21_36311}                ${tl.attenuator[0].attenuator_ports[3]}
${att_port_2_cell21_36311}                ${tl.attenuator[0].attenuator_ports[4]}
${att_port_3_cell21_36311}                ${tl.attenuator[0].attenuator_ports[5]}
${att_port_4_cell21_36311}                ${tl.attenuator[0].attenuator_ports[6]}
${att_port_1_cell22_36311}                ${tl.attenuator[1].attenuator_ports[7]}
${att_port_2_cell22_36311}                ${tl.attenuator[1].attenuator_ports[8]}
${att_port_3_cell22_36311}                ${tl.attenuator[1].attenuator_ports[9]}
${att_port_4_cell22_36311}                ${tl.attenuator[1].attenuator_ports[10]}
${att_port_1_cell23_36311}                ${tl.attenuator[0].attenuator_ports[13]}
${att_port_2_cell23_36311}                ${tl.attenuator[0].attenuator_ports[14]}
${att_port_3_cell23_36311}                ${tl.attenuator[0].attenuator_ports[15]}
${att_port_4_cell23_36311}                ${tl.attenuator[0].attenuator_ports[16]}
${att_port_1_cell24_36311}                ${tl.attenuator[3].attenuator_ports[9]}
${att_port_2_cell24_36311}                ${tl.attenuator[3].attenuator_ports[10]}
${att_port_3_cell24_36311}                ${tl.attenuator[3].attenuator_ports[11]}
${att_port_4_cell24_36311}                ${tl.attenuator[3].attenuator_ports[12]}
${att_port_1_cell1_36311}                ${tl.attenuator[0].attenuator_ports[1]}
${att_port_2_cell1_36311}                ${tl.attenuator[0].attenuator_ports[2]}
${att_port_1_cell2_36311}                ${tl.attenuator[0].attenuator_ports[11]}
${att_port_2_cell2_36311}                ${tl.attenuator[0].attenuator_ports[12]}
${att_port_1_cell3_36311}                ${tl.attenuator[1].attenuator_ports[5]}
${att_port_2_cell3_36311}                ${tl.attenuator[1].attenuator_ports[6]}
${att_port_1_cell4_36311}                ${tl.attenuator[3].attenuator_ports[13]}
${att_port_2_cell4_36311}                ${tl.attenuator[3].attenuator_ports[14]}
${att_port_3_cell4_36311}                ${tl.attenuator[3].attenuator_ports[15]}
${att_port_4_cell4_36311}                ${tl.attenuator[3].attenuator_ports[16]}
${att_port_1_cell301_36311}                ${tl.attenuator[1].attenuator_ports[13]}
${att_port_2_cell301_36311}                ${tl.attenuator[1].attenuator_ports[14]}
${att_port_3_cell301_36311}                ${tl.attenuator[1].attenuator_ports[15]}
${att_port_4_cell301_36311}                ${tl.attenuator[1].attenuator_ports[16]}
${att_port_1_cell302_36311}                ${tl.attenuator[0].attenuator_ports[7]}
${att_port_2_cell302_36311}                ${tl.attenuator[0].attenuator_ports[8]}
${att_port_3_cell302_36311}                ${tl.attenuator[0].attenuator_ports[9]}
${att_port_4_cell302_36311}                ${tl.attenuator[0].attenuator_ports[10]}
${att_port_1_cell303_36311}                ${tl.attenuator[1].attenuator_ports[1]}
${att_port_2_cell303_36311}                ${tl.attenuator[1].attenuator_ports[2]}
${att_port_3_cell303_36311}                ${tl.attenuator[1].attenuator_ports[3]}
${att_port_4_cell303_36311}                ${tl.attenuator[1].attenuator_ports[4]}
${att_ipaddr_cell21_36311}                ${tl.attenuator[0].ip_addr}
${att_ipaddr_cell22_36311}                ${tl.attenuator[1].ip_addr}
${att_ipaddr_cell23_36311}                ${tl.attenuator[0].ip_addr}
${att_ipaddr_cell24_36311}                ${tl.attenuator[3].ip_addr}
${att_ipaddr_cell1_36311}                ${tl.attenuator[0].ip_addr}
${att_ipaddr_cell2_36311}                ${tl.attenuator[0].ip_addr}
${att_ipaddr_cell3_36311}                ${tl.attenuator[1].ip_addr}
${att_ipaddr_cell4_36311}                ${tl.attenuator[3].ip_addr}
${att_ipaddr_cell301_36311}                ${tl.attenuator[1].ip_addr}
${att_ipaddr_cell302_36311}                ${tl.attenuator[0].ip_addr}
${att_ipaddr_cell303_36311}                ${tl.attenuator[1].ip_addr}
@{allow_fault_list}    62003    7311    7307    7107    8000     7331
*** Test Cases ***

[1][1.0] E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_22R4    CRT_23R1    ABIO
    [Setup]    robot_common_operations.Common Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
	${5G_flag}    Run keyword and return status    should contain    ${testline_name}    5G
    ${mrbtsid}    Run keyword if    ${5G_flag}     set variable    ${tl.gnbs[0].instance_id}
    ...    ELSE    set variable    ${tl.enbs[0].instance_id}
    ${nrbtsid}    Run keyword if    ${5G_flag}     set variable    ${tl.gnbs[0].global_bts_id}
    ...    ELSE    set variable    ${tl.enbs[0].global_bts_id}
	set test variable    ${mrbtsid}
	set test variable    ${nrbtsid}
	${parameter_to_modification}   Prepare Delta
    ...     filename=${delta_file}
    ...     parameter_type=site_reset
	...     mrbts_id=${mrbtsid}
	...     nrbts_id=${nrbtsid}
	DELTA_COMMISSIONING_WITH_SITE_RESET_REQUIRED
	...    delta_file=${delta_file}
    ...    test_iteration=${runs_of_delta_commission_withcall}
    ...    custom_alarms=@{custom_alarms}
    ...    critical_faults=@{critical_faults}
    ...    customers_list=${customers}
    ...    attach_test_keyword=UE Attach and Check traffic for Sleeping Cells
     sleep  5s
    [Teardown]    robot_common_operations.Common Case Teardown

[1][1.0] E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_22R4    CRT_23R1    ABIO
    [Setup]    robot_common_operations.Common Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    AlarmWatchdog.add_allow_alarms    fault_id=49
    OAM_NRCEL_LOCK
    ...    test_iteration=${runs_of_nrcel_lock_withcall}
    ...    custom_alarms=@{custom_alarms}
    ...    critical_faults=@{critical_faults}
    ...    customers_list=${customers}
    ...    attach_test_keyword=UE Attach and Check traffic for Sleeping Cells
     sleep  5s
    [Teardown]    robot_common_operations.Common Case Teardown

[1][1.0] E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_22R4    CRT_23R1    ABIO
    [Setup]    robot_common_operations.Common Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    AlarmWatchdog.add_allow_alarms    fault_id=49
    OAM_NRCEL_BLOCK
    ...    test_iteration=${runs_of_nrcel_block_withcall}
    ...    custom_alarms=@{custom_alarms}
    ...    critical_faults=@{critical_faults}
    ...    customers_list=${customers}
    ...    attach_test_keyword=UE Attach and Check traffic for Sleeping Cells
    [Teardown]    robot_common_operations.Common Case Teardown

#[1]E2E_TL_Cell_Block_Unblock_NR_with_sleeping_cell_check
#    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_22R4    CRT_23R1    ABIO
#    [Setup]    robot_common_operations.Common Case Setup
#    OAM_NRCEL_BLOCK
#    ...    test_iteration=${runs_of_nrcel_block_withcall}
#    ...    custom_alarms=@{custom_alarms}
#    ...    critical_faults=@{critical_faults}
#    ...    customers_list=${customers}
#    ...    attach_test_keyword=UE Attach and Check traffic for Sleeping Cells
#     sleep  5s

*** Keywords ***

UUF4ALL common Suite Setup with alarm checking
    [Arguments]    ${if_commissioning}=${False}
	robot_common_operations.Common Suite Setup
	run keyword if     ${if_commissioning}    CI_interface.Common Suite Setup

UE Attach and Check traffic for Sleeping Cells
    [Arguments]    ${cell_used_in_test}=None    ${remote}=${False}    ${data_transfer_dl}=${DL_THROUGHPUT}
    ...            ${data_transfer_ul}=${UL_THROUGHPUT}    ${Expected_Throughput_DL}=${DL_EXPECT_TP}
    ...            ${Expected_Throughput_UL}=${UL_EXPECT_TP}    ${apn_address}=${apn1}    ${time}=5m   ${cap_index}=${0}
    #${ue_percell}    get_cells_info_for_attach    dependent_cells=${cell_used_in_test}    remote=True
    #Return From Keyword If    ${ue_percell} is None
    #${nrCellIdentitys}    Get Dictionary Keys    ${ue_percell}
    set variable    ${cell_used_in_test}
    set variable    ${remote}
    Adjust TL gNB_RU Attenuation    cell21_value=${20}
    FOR    ${nrCellIdentity}    IN    @{nrCellIdentitys}
        UE Attach and Check traffic for Sleeping Cell
        ...        nrCellIdentity=${nrCellIdentity}    data_transfer_dl=${data_transfer_dl}    data_transfer_ul=${data_transfer_ul}
        ...        Expected_Throughput_DL=${Expected_Throughput_DL}    Expected_Throughput_UL=${Expected_Throughput_UL}
        ...        ue_index=${ue_index}    apn_address=${apn_address}    time=${time}    cap_index=${cap_index}
    END
    Adjust TL gNB_RU Attenuation    cell21_value=${127}

UE Attach and Check traffic for Sleeping Cell
    [Arguments]    ${nrCellIdentity}    ${data_transfer_dl}=${DL_THROUGHPUT}    ${data_transfer_ul}=${UL_THROUGHPUT}
    ...            ${Expected_Throughput_DL}=${DL_EXPECT_TP}    ${Expected_Throughput_UL}=${UL_EXPECT_TP}    ${ue_index}=${ue_index}
    ...            ${apn_address}=${apn1}    ${time}=5m   ${cap_index}=${0}
    ##${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${ui_version}    Set Variable If    '${ue_type}' =='xiaomi'    Mi12UI13.0.12    default
    ${ue_index_list}    Create List    ${ue_index}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    ui_version=${ui_version}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    cap_index=${cap_index}
    Connect to Common Unit Master  alias=ASIK MASTER
    connect to gnb coam via ssl    connection=GNB_OAM
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${data_transfer_dl}    duration=${DURATION}
    ...                       ue_index=${ue_index}    apn_address=${apn_address}    cap_index=${cap_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${data_transfer_ul}
    ...                       duration=${DURATION}    ue_index=${ue_index}    apn_address=${apn_address}
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}     duration=${time}
    ${cell_id}    Create List    ${nrCellIdentity}
    run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    direction=DL    cells=${cell_id}
    ...                                    log=${tput_log}    target_throughput=${Expected_Throughput_DL}
    run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    direction=UL    cells=${cell_id}
    ...                                    log=${tput_log}    target_throughput=${Expected_Throughput_UL}
    [Teardown]    Run Keywords
    ...    Run Keyword And Ignore Error     ute_ue._stop_using_ue    ue_alias=UE_${ue_index}    AND
    ...    Run Keyword And Ignore Error     Stop UL DL data transfer
    ...    Run Keyword And Ignore Error     power_ue.UE Detach    ue_type=${ue_type}

### PA adjust ###
Adjust TL gNB_RU Attenuation
    [Arguments]     ${tl}=${gnb_instance}
    ...    ${cell21_value}=${127}    ${cell22_value}=${127}    ${cell23_value}=${127}    ${cell24_value}=${127}
    ...    ${cell1_value}=${127}    ${cell2_value}=${127}    ${cell3_value}=${127}    ${cell4_value}=${127}
    ...    ${cell301_value}=${127}    ${cell302_value}=${127}    ${cell303_value}=${127}
    ####create cell list#####
    @{att_ports_cell21}    Create List    ${att_port_1_cell21_${tl}}    ${att_port_2_cell21_${tl}}
    ...    ${att_port_3_cell21_${tl}}    ${att_port_4_cell21_${tl}}
    @{att_ports_cell22}    Create List    ${att_port_1_cell22_${tl}}    ${att_port_2_cell22_${tl}}
    ...    ${att_port_3_cell22_${tl}}    ${att_port_4_cell22_${tl}}
    @{att_ports_cell23}    Create List    ${att_port_1_cell23_${tl}}    ${att_port_2_cell23_${tl}}
    ...    ${att_port_3_cell23_${tl}}    ${att_port_4_cell23_${tl}}
    @{att_ports_cell24}    Create List    ${att_port_1_cell24_${tl}}    ${att_port_2_cell24_${tl}}
    ...    ${att_port_3_cell24_${tl}}    ${att_port_4_cell24_${tl}}
    @{att_ports_cell1}    Create List    ${att_port_1_cell1${tl}}    ${att_port_2_cell1_${tl}}
    @{att_ports_cell2}    Create List    ${att_port_1_cell2_${tl}}    ${att_port_2_cell2${tl}}
    @{att_ports_cell3}    Create List    ${att_port_1_cell3_${tl}}    ${att_port_2_cell3_${tl}}
    @{att_ports_cell4}    Create List    ${att_port_1_cell4_${tl}}    ${att_port_2_cell4_${tl}}
    ...    ${att_port_3_cell4_${tl}}    ${att_port_4_cell4_${tl}}
    @{att_ports_cell301}    Create List    ${att_port_1_cell301_${tl}}    ${att_port_2_cell301_${tl}}
    ...    ${att_port_3_cell301_${tl}}    ${att_port_4_cell301_${tl}}
    @{att_ports_cell302}    Create List    ${att_port_1_cell302_${tl}}    ${att_port_2_cell302_${tl}}
    ...    ${att_port_3_cell302_${tl}}    ${att_port_4_cell302_${tl}}
    @{att_ports_cell303}    Create List    ${att_port_1_cell303_${tl}}    ${att_port_2_cell303_${tl}}
    ...    ${att_port_3_cell303_${tl}}    ${att_port_4_cell303_${tl}}

    ###create value list####
    @{values_cell21}    Create List    ${cell21_value}    ${cell21_value}    ${cell21_value}    ${cell21_value}
    @{values_cell22}    Create List    ${cell22_value}    ${cell22_value}    ${cell22_value}    ${cell22_value}
    @{values_cell23}    Create List    ${cell23_value}    ${cell23_value}    ${cell23_value}    ${cell23_value}
    @{values_cell24}    Create List    ${cell24_value}    ${cell24_value}    ${cell24_value}    ${cell24_value}
    @{values_cell1}    Create List    ${cell1_value}    ${cell1_value}
    @{values_cell2}    Create List    ${cell2_value}    ${cell2_value}
    @{values_cell3}    Create List    ${cell3_value}    ${cell3_value}
    @{values_cell4}    Create List    ${cell4_value}    ${cell4_value}    ${cell4_value}    ${cell4_value}
    @{values_cell301}    Create List    ${cell301_value}    ${cell301_value}    ${cell301_value}    ${cell301_value}
    @{values_cell302}    Create List    ${cell302_value}    ${cell302_value}    ${cell302_value}    ${cell302_value}
    @{values_cell303}    Create List    ${cell303_value}    ${cell303_value}    ${cell303_value}    ${cell303_value}

    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_ports=${att_ports_cell21}    values=${values_cell21}
    ...    att_connection_port=${att_port_1_cell21_${tl}}    att_ipaddr=${att_ipaddr_cell21_${tl}}
    Set the attenuation value    att_ports=${att_ports_cell22}    values=${values_cell22}
    ...    att_connection_port=${att_port_1_cell22_${tl}}    att_ipaddr=${att_ipaddr_cell22_${tl}}
    Set the attenuation value    att_ports=${att_ports_cell23}    values=${values_cell23}
    ...    att_connection_port=${att_port_1_cell23_${tl}}    att_ipaddr=${att_ipaddr_cell23_${tl}}
    Set the attenuation value    att_ports=${att_ports_cell24}    values=${values_cell24}
    ...    att_connection_port=${att_port_1_cell24_${tl}}    att_ipaddr=${att_ipaddr_cell24_${tl}}
    Set the attenuation value    att_ports=${att_ports_cell1}    values=${values_cell1}
    ...    att_connection_port=${att_port_1_cell1_${tl}}    att_ipaddr=${att_ipaddr_cell1_${tl}}
    Set the attenuation value    att_ports=${att_ports_cell2}    values=${values_cell2}
    ...    att_connection_port=${att_port_1_cell2_${tl}}    att_ipaddr=${att_ipaddr_cell2_${tl}}
    Set the attenuation value    att_ports=${att_ports_cell3}    values=${values_cell3}
    ...    att_connection_port=${att_port_1_cell3_${tl}}    att_ipaddr=${att_ipaddr_cell3_${tl}}
    Set the attenuation value    att_ports=${att_ports_cell4}    values=${values_cell4}
    ...    att_connection_port=${att_port_1_cell4_${tl}}    att_ipaddr=${att_ipaddr_cell4_${tl}}
    Set the attenuation value    att_ports=${att_ports_cell301}    values=${values_cell301}
    ...    att_connection_port=${att_port_1_cell301_${tl}}    att_ipaddr=${att_ipaddr_cell301_${tl}}
    Set the attenuation value    att_ports=${att_ports_cell302}    values=${values_cell302}
    ...    att_connection_port=${att_port_1_cell302_${tl}}    att_ipaddr=${att_ipaddr_cell302_${tl}}
    Set the attenuation value    att_ports=${att_ports_cell303}    values=${values_cell303}
    ...    att_connection_port=${att_port_1_cell303_${tl}}    att_ipaddr=${att_ipaddr_cell303_${tl}}