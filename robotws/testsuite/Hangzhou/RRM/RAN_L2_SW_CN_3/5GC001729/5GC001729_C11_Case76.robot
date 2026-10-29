*** Settings ***
Suite Setup       Qualcomm Common Suite Setup
Suite Teardown    Qualcomm Common Suite Teardown
Test Setup        Qualcomm Common Test Setup
Test Teardown     Qualcomm Common Test Teardown
Force Tags        qualcomm    owner_l3gao    SBTS22R2   SBTS22R4   SBTS00    SBTS23R1
Resource          ../resources/KISS/robot/common_resource.robot
Resource          ../resources/sg10/internal_resource/internal_resource.robot
Library           taf.sbts.oam.coam.admin
Documentation     beamform_beamset6 8mhz_80mhz refinebeam_false 8DL4UL dlmimo_8X4 SA frame_1208_2symbol_4DL1UL
...     actPdschAtSsbSlots_P_enable_S_disable prach_98
...     peak downlink_112_102  uplink 114


*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
@{LOG_NAME_LIST}    gnb_snapshot     sosreport
${UE1_ID}         10a5c6e6
${UE1_DL_PORT_1}    5001
${UE1_DL_PORT_2}    5002
${UE1_UL_PORT}    5003
${UE1_DL_SERVER_LOG}    /tmp/iperf_server_on_ue_log.txt
${UE1_UL_SERVER_LOG}    /tmp/iperf_server_on_pc_log.txt
${UE1_DL_CLIENT_EXTRA_CMD}    -u -t 800 -i 1 -P 1 -f m -b 1400.00M -l 1400B -T 64
${UE1_UL_CLIENT_EXTRA_CMD}    -u -c 192.168.255.1 -P 1 -i 1 -f m -w 4M -b 200M -t 600
${EXPORT_GRID}    Common Displays;Events and Debug Msgs vs. Time
${SCFC_NAME}      1729_CASE76_SCFC.xml
${GNB_SWCONFIG_QUAL_NAME}    qual_swconfig_126.txt
${GNB_SWCONFIG_QUAL_NAME_127}    qual_swconfig_127.txt
${TTITRACE_TAG}    ttitrace

*** Test Cases ***
5GC001729_Case76_C11_Cell_Unlock_of_TDD_SCell
    Qualcomm prepare gnb onair
    Start capture only gnb syslog in 'after_onair' file
    Attach one qualcomm ue and make call stable
    Qualcomm detach ue    ${UE1_ID}
    Qualcomm attach ue    ${UE1_ID}
    Qualcomm Start DL Data    ${UE1_ID}    ${UE1_DL_PORT_1}    ${UE1_DL_SERVER_LOG}    ${UE1_DL_CLIENT_EXTRA_CMD}
    Qualcomm Start DL Data    ${UE1_ID}    ${UE1_DL_PORT_2}    ${UE1_DL_SERVER_LOG}    ${UE1_DL_CLIENT_EXTRA_CMD}
    Qualcomm Start UL Data    ${UE1_ID}    ${UE1_UL_PORT}    ${UE1_UL_SERVER_LOG}    ${UE1_UL_CLIENT_EXTRA_CMD}
    Wait '50s' for stabible
    ${log_path_dl_ul}    Get qualcomm log    ${UE1_ID}
    Download qualcomm log    ${log_path_dl_ul}.hdf    ${EXPORT_GRID}   Throughput_${UE1_ID}_raw.txt
    ${pcell_tput}    ${scell_tput}    ${pcell_bler}    ${scell_bler}    Get ue DL throughput and bler    Throughput_${UE1_ID}_raw.txt
    ${pcell_tput_ul}    ${pcell_bler_ul}    Get ue UL throughput and bler    Throughput_${UE1_ID}_raw.txt
    run keyword and continue on failure    should_be_true    ${pcell_tput} > 1000000
    run keyword and continue on failure    should_be_true    ${scell_tput} > 980000
    run keyword and continue on failure    should_be_true    ${pcell_bler} < 3
    run keyword and continue on failure    should_be_true    ${scell_bler} < 3
    run keyword and continue on failure    should_be_true    ${pcell_tput_ul} > 90000
    run keyword and continue on failure    should_be_true    ${pcell_bler_ul} < 10
    Block Cell    189    gNB10316
    Wait '20s' for stabible
    ${log_path_block}    Get qualcomm log    ${UE1_ID}
    Qualcomm Stop DL Data    ${UE1_ID}    ${UE1_DL_PORT_1}
    Qualcomm Stop DL Data    ${UE1_ID}    ${UE1_DL_PORT_2}
    Qualcomm Stop UL Data    ${UE1_ID}    ${UE1_UL_PORT}
    Qualcomm detach ue    ${UE1_ID}
    Download qualcomm log    ${log_path_block}.hdf    ${EXPORT_GRID}    Throughput_${UE1_ID}_raw_Scell_blocked.txt
    ${pcell_tput}    ${scell_tput}    ${pcell_bler}    ${scell_bler}    Get ue DL throughput and bler   Throughput_${UE1_ID}_raw_Scell_blocked.txt
    run keyword and continue on failure    should_be_true    ${pcell_tput} > 1000000
    run keyword and continue on failure    should_be_true    ${scell_tput} == 0
    run keyword and continue on failure    should_be_true    ${pcell_bler} < 3
    run keyword and continue on failure    should_be_true    ${scell_bler} < 3
    Unblock Cell   189    gNB10316
    Wait until keyword succeeds    1500s    60s    Verify BTS Is Onair
    Wait '20s' for stabible
    Attach one qualcomm ue and make call stable
    Qualcomm detach ue    ${UE1_ID}
    Qualcomm attach ue    ${UE1_ID}
    Qualcomm Start DL Data    ${UE1_ID}    ${UE1_DL_PORT_1}    ${UE1_DL_SERVER_LOG}    ${UE1_DL_CLIENT_EXTRA_CMD}
    Qualcomm Start DL Data    ${UE1_ID}    ${UE1_DL_PORT_2}    ${UE1_DL_SERVER_LOG}    ${UE1_DL_CLIENT_EXTRA_CMD}
    Qualcomm Start UL Data    ${UE1_ID}    ${UE1_UL_PORT}    ${UE1_UL_SERVER_LOG}    ${UE1_UL_CLIENT_EXTRA_CMD}
    wait '20s' for stabible
    ${log_path_unlock}    Get qualcomm log    ${UE1_ID}
    Qualcomm Stop DL Data    ${UE1_ID}    ${UE1_DL_PORT_1}
    Qualcomm Stop DL Data    ${UE1_ID}    ${UE1_DL_PORT_2}
    Qualcomm Stop UL Data    ${UE1_ID}    ${UE1_UL_PORT}
    Qualcomm detach ue    ${UE1_ID}
    Download qualcomm log    ${log_path_unlock}.hdf    ${EXPORT_GRID}   Throughput_${UE1_ID}_raw_scell_unblocked.txt
    ${pcell_tput}    ${scell_tput}    ${pcell_bler}    ${scell_bler}    Get ue DL throughput and bler    Throughput_${UE1_ID}_raw_scell_unblocked.txt
    ${pcell_tput_ul}    ${pcell_bler_ul}    Get ue UL throughput and bler    Throughput_${UE1_ID}_raw.txt
    run keyword and continue on failure    should_be_true    ${pcell_tput} > 1000000
    run keyword and continue on failure    should_be_true    ${scell_tput} > 980000
    run keyword and continue on failure    should_be_true    ${pcell_bler} < 3
    run keyword and continue on failure    should_be_true    ${scell_bler} < 3
    run keyword and continue on failure    should_be_true    ${pcell_tput_ul} > 90000
    run keyword and continue on failure    should_be_true    ${pcell_bler_ul} < 10
    Stop capture only gnb syslog in 'after_onair' file

*** Keywords ***
Get ue DL throughput and bler
    [Arguments]    ${txt_file_name}
    log to console    start to get ue throughput and bler
    ${UE1_pcell_tput}    get_dl_pcell_tput    ${test_log_directory()}/${txt_file_name}
    ${UE1_scell_tput}    get_dl_scell_tput    ${test_log_directory()}/${txt_file_name}
    ${UE1_pcell_bler}    get_dl_pcell_bler    ${test_log_directory()}/${txt_file_name}
    ${UE1_scell_bler}    get_dl_scell_bler    ${test_log_directory()}/${txt_file_name}
    [Return]    ${UE1_pcell_tput}    ${UE1_scell_tput}    ${UE1_pcell_bler}    ${UE1_scell_bler}

Get ue UL throughput and bler
    [Arguments]    ${txt_file_name}
    log to console    start to get ue throughput and bler
    ${UE1_pcell_tput_ul}    get_ul_pcell_tput    ${test_log_directory()}/${txt_file_name}
    ${UE1_pcell_bler_ul}    get_ul_pcell_bler    ${test_log_directory()}/${txt_file_name}
    [Return]    ${UE1_pcell_tput_ul}    ${UE1_pcell_bler_ul}


Block Cell
    [Arguments]    ${phy_cell_id}    ${alias}
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=${alias}
    ${nrcel_list}=    TAF_ADMIN.Get Parameters For All    NRCEL    timeout=30    connection=${alias}
    FOR    ${nrcel}    IN    @{nrcel_list}
        Run Keyword If    '${nrcel.physCellId}'=='${phy_cell_id}' and '${nrcel.administrativeState}'=='Unlocked'
         ...    Run Keywords    TAF_ADMIN.lock    ${nrcel.id}    timeout=60    connection=${alias}  AND    sleep    60
    END    
    TAF_ADMIN.teardown    connection=${alias}

Unblock Cell
    [Arguments]    ${phy_cell_id}    ${alias}
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=${alias}
    ${nrcel_list}=    TAF_ADMIN.Get Parameters For All    NRCEL    timeout=30    connection=${alias}
    FOR    ${nrcel}    IN    @{nrcel_list}
        Run Keyword If    '${nrcel.physCellId}'=='${phy_cell_id}' and '${nrcel.administrativeState}'=='Locked'
         ...    Run Keywords    TAF_ADMIN.unlock    ${nrcel.id}    timeout=60    connection=${alias}  AND    sleep    60
    END    
    TAF_ADMIN.teardown    connection=${alias}

Attach one qualcomm ue and make call stable
    Qualcomm detach ue    ${UE1_ID}
    Qualcomm attach ue    ${UE1_ID}
    Qualcomm Start DL Data    ${UE1_ID}    ${UE1_DL_PORT_1}    ${UE1_DL_SERVER_LOG}    ${UE1_DL_CLIENT_EXTRA_CMD}
    Qualcomm Start DL Data    ${UE1_ID}    ${UE1_DL_PORT_2}    ${UE1_DL_SERVER_LOG}    ${UE1_DL_CLIENT_EXTRA_CMD}
    Wait '30s' for stabible
    Qualcomm Stop DL Data    ${UE1_ID}    ${UE1_DL_PORT_1}
    Qualcomm Stop DL Data    ${UE1_ID}    ${UE1_DL_PORT_2}