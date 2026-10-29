*** Settings ***
Documentation
...   Suite specific keywords for CB012268
...   author:       Dawid Chuchnowski
...   maintainer:   Jakub Matuszczyk
...   contact:      jakub.matuszczyk@nokia.com
...   team:         KRK6

Library     Dialogs
Library     DateTime                                                                  WITH NAME    dt
Library     ta5g_pm_counters
Library     ute_ue                                                                    WITH NAME    ue
Library     taf.rfrl.utilities.logger.custom_logger                                   WITH NAME    logger
Library     taf.rfrl.ue.ue_attach_verification.UeAttachVerification                   WITH NAME    ue_attach_verification
Library     taf.rfrl.ue.ute_ue_config.UteUeConfig                                     WITH NAME    uteueconfig
Library     taf.rfrl.bts.devices.ru.ru_operations.GnbRuOperations                     WITH NAME    gnbru
Library     tcp_runner.py

Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    testsuite/Krakow/RRM/RAN_PZ/resources/resources.robot

Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables   delta_commissionings.py

*** Variables ***
@{list_of_additional_allowed_alarms}    User Account has Default Password
${abstract_lib_config}                  ${NONE}
${current_config}                       ${NONE}
${MRBTS_ID}                             ${tl.gnbs[0].instance_id}
${NRBTS_ID}                             ${tl.gnbs[0].global_bts_id}
${UE_PC_IPERF}                          C:\\iperf\\iperf-3.1.3-win64\\iperf3.exe

*** Keywords ***
Set cells IDs
    ${gnb1_cell1_parameters}=  gnbcell.Get Cell Parameters    bts_id=0    cell_id=${260}    du_id=0
    Set Suite Variable    ${gnb1_cell1_id}      ${gnb1_cell1_parameters['physCellId']}
    Set Suite Variable    ${gnb1_cell1_nrid}    ${gnb1_cell1_parameters['nrCellIdentity']}
    ${gnb1_cell2_parameters}=  gnbcell.Get Cell Parameters    bts_id=0    cell_id=${261}    du_id=0
    Set Suite Variable    ${gnb1_cell2_id}      ${gnb1_cell2_parameters['physCellId']}
    Set Suite Variable    ${gnb1_cell2_nrid}    ${gnb1_cell2_parameters['nrCellIdentity']}
    ${gnb1_cell3_parameters}=  gnbcell.Get Cell Parameters    bts_id=0    cell_id=${262}    du_id=0
    Set Suite Variable    ${gnb1_cell3_id}      ${gnb1_cell3_parameters['physCellId']}
    Set Suite Variable    ${gnb1_cell3_nrid}    ${gnb1_cell3_parameters['nrCellIdentity']}
    ${gnb1_cell4_parameters}=  gnbcell.Get Cell Parameters    bts_id=0    cell_id=${263}    du_id=0
    Set Suite Variable    ${gnb1_cell4_id}      ${gnb1_cell4_parameters['physCellId']}
    Set Suite Variable    ${gnb1_cell4_nrid}    ${gnb1_cell4_parameters['nrCellIdentity']}

Suite Setup
    logger.Log Banner to Console    Suite Setup started
    Common Suite Setup With OnAir Test Line Preparation
    ...     prefix_tag=CB012268_SA
    ...     swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
    ...     should_LTE_neighbour_be_changed=False
    ...     should_5G_neighbour_be_changed=False
    ...     check_x2_link=False
    &{abstract_lib_config}=    Get ute UE Configuration Dict
    Set Suite Variable    ${abstract_lib_config}
    Set Suite Variable    ${current_config}
    Lock RU on neighbour BTS   bts_id=1  rmod_id=1
    logger.Log Banner to Console    Suite Setup finished

Wait until all cells are onair
    [Arguments]    ${waiting_time}=10min    ${checking_interval}=15s
    [Documentation]    The keyword waits until all cells will be in on air.
    ...                :param waiting_time:    time to wait
    ...                :param checking_interval: time between checking
    logger.Log Info to Console    Wait until all cells are onair
    Wait Until Keyword Succeeds    ${waiting_time}    ${checking_interval}
    ...    Verify All Cells Are OnAir    bts_id=0    du_id=0

Get NR Cell ID in hex
    [Arguments]    ${nr_cell_id}
    [Documentation]    This keyword converts  NR Cell Id from integer to hexadecimal value
    ...                :param nr_cell_id:    NR cell id in integerl
    ${hex_nr_cell_id} =    Evaluate    '{0:#0{1}x}'.format(int(${nr_cell_id}), 11)
    [Return]    ${hex_nr_cell_id}

Test Setup SA
    logger.Log Info to Console    Test setup started
    Common Preconditions With Watching Alarms
    ue.Require Ue    UE_1    QC_2
    Set cells IDs
    Set Suite Variable       ${current_config}      CB012268_SA
    Run Keyword And Ignore Error    ue.Detach UE    UE_1
    logger.Log Info to Console    Test setup finished

Test Teardown SA
    logger.Log Info to Console    Test teardown started
    Common Postconditions With Watching Alarms
    Run Keyword And Ignore Error    Detach UE
    logger.Log banner to Console    Test teardown finished

Attach 5G SA UE
    [Documentation]    This keyword performs UE attach to 5G SA cell and check if attach was performed to first cell
    logger.Log Info to Console    Attach 5G SA UE to cell 1
    ue.Attach UE   UE_1
    Sleep    5s
    ue_attach_verification.Verify_SA_Attach    ue_alias=UE_1     pci_5g=1295155460
    Sleep    5s


Run Downlink TCP Data Transmission
    [Arguments]    ${duration}    ${DL_port}=None
    [Documentation]    The keyword starts data transfer on UE with set duration.
    ...                :param duration:            duration of data transfer
    logger.Log Info to Console    Start DL TCP data traffic

    ${APP_SERVER_IPERF_PORT}=    Set Variable If    '${DL_port}' != 'None'    ${DL_port}         <APP_SERVER_IPERF_PORT>
    ${UE_IPERF_PORT}=    Set Variable If    '${DL_port}' != 'None'    ${DL_port}         <UE_IPERF_PORT>

    tcp_runner.Start Data Transfer    dt_name=DL_UE_DT    ue_alias=UE_1
    ...    app_server_cmd=iperf3 -s -B <APP_SERVER_BIND_IP> -p ${APP_SERVER_IPERF_PORT} -i 1
    ...    ue_cmd=cmd.exe /c "${UE_PC_IPERF} -c <APP_SERVER_BIND_IP> -p ${UE_IPERF_PORT} -t ${duration} -B <UE_IP> -i 1 -P 6 -R"

    tcp_runner.Stop Data Transfer    dt_name=DL_UE_DT
    logger.Log Info to Console    Data transfer stopped


Run Downlink And Uplink TCP Data Transmission
    [Arguments]    ${duration}    ${DL_port}=None   ${UL_port}=None
    [Documentation]    The keyword starts data transfer on UE with set duration.
    ...                :param duration:            duration of data transfer
    logger.Log Info to Console    Start TCP UL and DL data traffic

    ${APP_SERVER_IPERF_PORT}=    Set Variable If    '${UL_port}' != 'None'    ${UL_port}         <APP_SERVER_IPERF_PORT>
    ${UE_IPERF_PORT}=    Set Variable If    '${UL_port}' != 'None'    ${UL_port}         <UE_IPERF_PORT>

    tcp_runner.Start Data Transfer    dt_name=UL_UE_DT    ue_alias=UE_1
    ...    app_server_cmd=iperf3 -s -B <APP_SERVER_BIND_IP> -p ${APP_SERVER_IPERF_PORT}
    ...    ue_cmd=cmd.exe /c "${UE_PC_IPERF} -c <APP_SERVER_BIND_IP> -p ${UE_IPERF_PORT} -t ${duration} -B <UE_IP> -i 1 -P 4 -M 1360"

    ${APP_SERVER_IPERF_PORT}=    Set Variable If    '${DL_port}' != 'None'    ${DL_port}         <APP_SERVER_IPERF_PORT>
    ${UE_IPERF_PORT}=    Set Variable If    '${DL_port}' != 'None'    ${DL_port}         <UE_IPERF_PORT>

    tcp_runner.Start Data Transfer    dt_name=DL_UE_DT    ue_alias=UE_1
    ...    app_server_cmd=iperf3 -s -B <APP_SERVER_BIND_IP> -p ${APP_SERVER_IPERF_PORT} -i 1
    ...    ue_cmd=cmd.exe /c "${UE_PC_IPERF} -c <APP_SERVER_BIND_IP> -p ${UE_IPERF_PORT} -t ${duration} -B <UE_IP> -i 1 -P 6 -R"


    Sleep    ${duration}    reasone=Wait for TCP data traffic stop
    tcp_runner.Stop Data Transfer    dt_name=UL_UE_DT
    tcp_runner.Stop Data Transfer    dt_name=DL_UE_DT
    logger.Log Info to Console    Data transfer stopped


Run Downlink And Uplink UDP Data Transmission
    [Arguments]    ${duration}    ${throughput}    ${DL_port}=None   ${UL_port}=None
    [Documentation]    The keyword starts data transfer on UE with set duration.
    ...                :param duration:            duration of data transfer
    logger.Log Info to Console    Start UDP UL and DL data traffic

    ${APP_SERVER_IPERF_PORT}=    Set Variable If    '${UL_port}' != 'None'    ${UL_port}         <APP_SERVER_IPERF_PORT>
    ${UE_IPERF_PORT}=    Set Variable If    '${UL_port}' != 'None'    ${UL_port}         <UE_IPERF_PORT>

    tcp_runner.Start Data Transfer    dt_name=UL_UE_DT    ue_alias=UE_1
    ...    app_server_cmd=iperf3 -s -B <APP_SERVER_BIND_IP> -p ${APP_SERVER_IPERF_PORT}
    ...    ue_cmd=cmd.exe /c "${UE_PC_IPERF} -c <APP_SERVER_BIND_IP> -p ${UE_IPERF_PORT} -t ${duration} -B <UE_IP> -i 1 -M 1360 -u -b ${throughput}"

    ${APP_SERVER_IPERF_PORT}=    Set Variable If    '${DL_port}' != 'None'    ${DL_port}         <APP_SERVER_IPERF_PORT>
    ${UE_IPERF_PORT}=    Set Variable If    '${DL_port}' != 'None'    ${DL_port}         <UE_IPERF_PORT>

    tcp_runner.Start Data Transfer    dt_name=DL_UE_DT    ue_alias=UE_1
    ...    app_server_cmd=iperf3 -s -B <APP_SERVER_BIND_IP> -p ${APP_SERVER_IPERF_PORT} -i 1
    ...    ue_cmd=cmd.exe /c "${UE_PC_IPERF} -c <APP_SERVER_BIND_IP> -p ${UE_IPERF_PORT} -t ${duration} -B <UE_IP> -i 1 -u -b ${throughput} -R"

    Sleep    ${duration}    reasone=Wait for UDP data traffic stop
    tcp_runner.Stop Data Transfer    dt_name=UL_UE_DT
    tcp_runner.Stop Data Transfer    dt_name=DL_UE_DT
    logger.Log Info to Console    Data transfer stopped

Detach UE
    logger.Log Info to Console    Detach UE
    ue.Detach Ue    UE_1


Set reporting of DL MAC SDU user throughput PM counters
    [Arguments]    ${value}
    [Documentation]     This keyword sets reporting of DL MAC SDU user throughput PM counters per NR serving cell
    ...     :param value: actPerCellMacUserThpt value true/false
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...  param_name=actMacUserThpt  param_value=${value}  skip_parameter_relation_errors=true  operation=update
    ...  timeout=300
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...  param_name=actPerCellMacUserThpt  param_value=${value}  skip_parameter_relation_errors=true  operation=update
    ...  timeout=300

Enable DL MAC SDU measurements
    logger.Log Info to Console    Enable DL MAC SDU measurements
    perform delta commissioning on gnb    delta=${DL_MAC_SDU_meas_enabling}    timeout=120

Configure parameters for edge cell condition
    [Documentation]     This keyword sets cellEdgeUeDlPathlossThrPmCount and cellNearUeDlPathlossThrPmCount
    logger.Log Info to Console    Configure parameters for edge cell condition
    perform delta commissioning on gnb    delta=${cell_edge_DL_pathloss_thresholds}    timeout=120

Configure parameters for middle cell condition
    [Documentation]     This keyword sets cellEdgeUeDlPathlossThrPmCount and cellNearUeDlPathlossThrPmCount
    logger.Log Info to Console    Configure parameters for middle cell condition
    perform delta commissioning on gnb    delta=${cell_middle_DL_pathloss_thresholds}    timeout=120

Configure parameters for near cell condition
    [Documentation]     This keyword sets cellEdgeUeDlPathlossThrPmCount and cellNearUeDlPathlossThrPmCount
    logger.Log Info to Console    Configure parameters for near cell condition
    perform delta commissioning on gnb    delta=${cell_near_DL_pathloss_thresholds}    timeout=120

Lock RU on neighbour BTS
    [Documentation]  This keyword locks specified RMOD on selected BTS
    [Arguments]   ${rmod_id}   ${bts_id}
    logger.Log Info To Console   Lock RMOD-${rmod_id} on neighbour BTS
    gnbru.lock_radio_unit        bts_id=${bts_id}    radio_unit_id=${rmod_id}

Unlock RU on neighbour BTS
    [Documentation]  This keyword unlocks specified RMOD on selected BTS
    [Arguments]   ${rmod_id}   ${bts_id}
    logger.Log Info To Console   Unlock RMOD-${rmod_id} on neighbour BTS
    gnbru.unlock_radio_unit      bts_id=${bts_id}    radio_unit_id=${rmod_id}