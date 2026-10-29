*** Settings ***
Documentation     author: shasha liu
...               Group: HGZ_SG5
...               contact: shasha.liu@nokia-sbell.com

*** Keywords ***
### part-1: CB006293 ###
General_SiSo_Initiate_RF_diagnostic_test_from_BTS_Element_Manager_with_L3Call_AEQE
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this case is to verify that RF diagnostic test can be run by WebEM and test
    ...    result can be gotten successfully in BTS.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 08.05.2021 - - Created
    ...    - 17.11.2025 - - Updated
    ...      #Possible PIT Scenario for EDA 03794851:
    ...         1. Lock NR cell
    ...         2. Start RF diagnostic test for NR cell
    ...            - Start test is disabled when current select RAT is not on air and BTS is not in TDS mode.
    ...         3. Expect failure because of improper cell state
    ...         4. Unlock NR cell
    ...         5. Execute diagnostic check for NR cell with success
    ...    *******************
    ...    yue.2.liu@nokia-sbell.com
    [Arguments]  ${ue_index}=${0}    ${ul_tput}=100M    ${dl_tput}=300M    ${cell_id}=${1}
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    ${dl_tp}  ${ul_tp}  ${dl_exp}  ${ul_exp}    Calculate Send Tput And Expected Tput
    ...    peak_dl_tp=${dl_tput}    peak_ul_tp=${ul_tput}
    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity
    ${cell_id}    Convert To String    ${cell_mapping[${cell_id}]['nrCellIdentity']}
    ${cell_id}    Create List    ${cell_id}
    ${port_type}  COAM get ru port type
    #Delete RFTHLD If Exist
    Run Keyword If   '${stream}'=='SBTS23R1' or '${stream}'=='SBTS23R2'    Modify actRemoteRfDiag Parameter
    #Set default value for RFTHLD If Feature 956 Enabled
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tput}
    ...    protocol=udp    duration=600    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tput}
    ...    protocol=udp    duration=600    ue_index=${ue_index}
    sleep    1min
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=60    check_source=Aasyslog
    ${output}    power_ue.Check Bi Tput   ue_type=${ue_type}    log=${tput_log}    cells=${cell_id}
    ...    ultarget_throughput=${ul_exp}    dltarget_throughput=${dl_exp}    target_avg_percent=0.1
    ...    min_percent=0.1
    log to console    ${output}
    #rf_diagnostic_test_setup_aeqe    url=${url}
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    selenium_coam.configure_rf_diagnostic_test    technology=NR
    selenium_coam.start_rf_diagnostic_test    timeout=180
    sleep  30
    Check Detailed Antenna AEQE
    Run Keyword If  '${port_type}'!='PHYANT'    Check VSWR With L3 Call
    Check General Test Information
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}

    ##Possible PIT Scenario for EDA 03794851
    ${is_group}    set variable    ${False}
    ${output}   set variable if      ${is_group}==${False}   all cells    all cell groups
    log to console  \n***Lock ${output} and start rf diagnostic test***
    Get X2 link shutdown waiting time
    ${cell_id_list}  Get All Cell Id
    Lock cells or groups and check status  lock_list=${cell_id_list}  is_group=${is_group}  check_alarm=${False}  gnb_type='${gNb_CuType}'
    Selenium Login And Disable Screen Lock    version=${stream}
    selenium_coam.configure_rf_diagnostic_test    technology=NR
    ${Status}    Run Keyword And Return Status    selenium_coam.start_rf_diagnostic_test    timeout=180
    Should Not Be True    ${Status}    msg=Start test is disabled when current select RAT is not on air and BTS is not in TDS mode.
    sleep  30
    #${msg}    Run Keyword And Expect Error    rf_diagnostic_test.Check General Test Information
    #${Status}    Run Keyword And Return Status    rf_diagnostic_test.Check General Test Information

    log to console  \n***unLock ${output} and start rf diagnostic test***
    Unlock cells or groups and check status  lock_list=${cell_id_list}  is_group=${is_group}  check_alarm=${False}  gnb_type='${gNb_CuType}'
    Selenium Login And Disable Screen Lock    version=${stream}
    selenium_coam.configure_rf_diagnostic_test    technology=NR
    selenium_coam.start_rf_diagnostic_test    timeout=180
    sleep  30
    ${Status}    Run Keyword And Return Status    rf_diagnostic_test.Check General Test Information
    Should Be True    ${Status}
    [Teardown]  selenium logout and close browser

General_SiSo_Initiate_RF_Statistics_diagnostic_test_withL3call_AEQE
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this case is to verify that RF statistics diagnostic test can be run by WebEM
    ...    and test result can be gotten successfully in BTS.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 24.03.2022 - - Created
    ...    *******************
    ...    yue.2.liu@nokis-sbell
    [Arguments]  ${ue_index}=${0}    ${radio_id}=${1}    ${RF_temperature_high_threshold}=${90}
    ...          ${min_temperature}=40    ${max_temperature}=100    ${rf_port_id}=0
    log    ${rf_port_id}
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    #Delete RFTHLD If Exist
    Run Keyword If   '${stream}'=='SBTS23R1' or '${stream}'=='SBTS23R2'    Modify actRemoteRfDiag Parameter
    #Set default value for RFTHLD If Feature 956 Enabled
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=300M
    ...    protocol=udp    duration=600    ue_index=${ue_index}
    sleep   5min
    ${bts_thresholds}    create dictionary    RF temperature high threshold=${RF_temperature_high_threshold}
    Selenium Login And Disable Screen Lock    version=${stream}
    RF statistics diagnostic test setup    bts_thresholds=${bts_thresholds}    radio_id=${radio_id}
    sleep  30
    Check Statistics General Information    radio_id=${radio_id}
    Check RF Temperature Supervision    radio_id=${radio_id}    min_temperature=${min_temperature}    max_temperature=${max_temperature}
    Check RF Ethernet Packet Monitoring All Port    radio_id=${radio_id}
    run keyword and ignore error   power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
    run keyword and ignore error   power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}
    [Teardown]  selenium logout and close browser

Check RF Ethernet Packet Monitoring All Port
    [Arguments]    ${radio_id}=1
    ${Received_errored_frames_value}    Set Variable    0
    ${Received_frames_value}    Set Variable    0
    ${Received_multicast_frames_value}    Set Variable    0
    ${Received_octets_value}    Set Variable    0
    ${type_frames_value}    Set Variable    0
    ${vlan_frames_value}    Set Variable    0
    ${Transmitted_frames_value}    Set Variable    0
    ${Transmitted_multicast_frames_value}    Set Variable    0
    ${Transmitted_octets_value}    Set Variable    0
    ${rf_eth_packet_monitoring_result}    selenium_coam.get_rf_ethernet_packet_monitoring    radio_id=RMOD-${radio_id}
    FOR    ${item}    IN    @{rf_eth_packet_monitoring_result}
        ${index}    Get Index From List    ${rf_eth_packet_monitoring_result}    ${item}
        ${Received_errored_frames_value}    Evaluate
        ...    ${Received_errored_frames_value}+${rf_eth_packet_monitoring_result}[${index}][Received errored frames]
        ${Received_frames_value}    Evaluate
        ...    ${Received_frames_value}+${rf_eth_packet_monitoring_result}[${index}][Received frames]
        ${Received_multicast_frames_value}    Evaluate
        ...    ${Received_multicast_frames_value}+${rf_eth_packet_monitoring_result}[${index}][Received multicast frames]
        ${Received_octets_value}    Evaluate
        ...    ${Received_octets_value}+${rf_eth_packet_monitoring_result}[${index}][Received octets]
        ${type_frames_value}    Evaluate
        ...    ${type_frames_value}+${rf_eth_packet_monitoring_result}[${index}][Received unknown type frames]
        ${vlan_frames_value}    Evaluate
        ...    ${vlan_frames_value}+${rf_eth_packet_monitoring_result}[${index}][Received unknown VLAN frames]
        ${Transmitted_frames_value}    Evaluate
        ...    ${Transmitted_frames_value}+${rf_eth_packet_monitoring_result}[${index}][Transmitted frames]
        ${Transmitted_multicast_frames_value}    Evaluate
        ...    ${Transmitted_multicast_frames_value}+${rf_eth_packet_monitoring_result}[${index}][Transmitted multicast frames]
        ${Transmitted_octets_value}    Evaluate
        ...    ${Transmitted_octets_value}+${rf_eth_packet_monitoring_result}[${index}][Transmitted octets]
    END
    should be equal as integers    ${Received_errored_frames_value}     0
    should be true    0 < ${Received_frames_value} < 18446744073709551615
    should be true    0 < ${Received_multicast_frames_value} < 18446744073709551615
    should be true    0 < ${Received_octets_value} < 18446744073709551615
    should be equal as integers    ${type_frames_value}     0
    should be equal as integers    ${vlan_frames_value}     0
    should be true    0 < ${Transmitted_frames_value} < 18446744073709551615
    should be true    0 < ${Transmitted_multicast_frames_value} < 18446744073709551615
    should be true    0 < ${Transmitted_octets_value} < 18446744073709551615

Check Detailed Antenna AEQE
    [Arguments]    ${cell_id}=1    ${expected_low}=-1     ${expected_high}=120   ${error_low}=-8    ${error_high}=8
    ...    ${RSSI_low}=-180    ${RSSI_high}=-30    ${RTWP_low}=-180    ${RTWP_high}=-30    ${SINR_low}=-21    ${SINR_high}=41
    ...    ${total_low}=-1    ${total_high}=120    ${stream}=SBTS00
    log    ${error_low}
    log    ${error_high}
    log    ${RTWP_low}
    log    ${RTWP_high}
    log    ${total_low}
    log    ${total_high}
    ${detail_result}    selenium_coam.get_detailed_result_for_each_antenna    cell_id=${cell_id}
    ${radio_protocol}    get_radio_protocal_via_admin
    FOR    ${item}    IN    @{detail_result}
        ${value_VSWR}    get from dictionary    ${item}    VSWR
        should be equal    ${value_VSWR}     0
        #${value_RTWP}    get from dictionary    ${item}    RTWP (dBm)
        #Run Keyword If  '${radio_protocol}'=='CPRI'    should be true    ${RTWP_low} < ${value_RTWP} < ${RTWP_high}
        ${value_RSSI}    get from dictionary    ${item}    RSSI (dBm)
        Run Keyword If  '${stream}'=='SBTS00' or '${stream}'=='SBTS22R3'
        ...     should be true    ${RSSI_low} < ${value_RSSI} < ${RSSI_high}
        ${value_SINR}    get from dictionary    ${item}    SINR (dB)
        Run Keyword If  '${stream}'=='SBTS00' or '${stream}'=='SBTS22R3'
        ...     should be true    ${SINR_low} < ${value_SINR} < ${SINR_high}
        ${value_forward_expected}   Run Keyword If  '${stream}'!='SBTS00' and '${stream}'!='SBTS22R3'
        ...     get from dictionary    ${item}   Forward expected transmit RF power
#        ${value_forward_expected}   Run Keyword If  '${stream}'!='SBTS00' and '${stream}'!='SBTS22R3'
#        ...     get from dictionary    ${dict_forward_expected}     dBm
        Run Keyword If  '${stream}'!='SBTS00' and '${stream}'!='SBTS22R3'
        ...    should be true    ${expected_low} < ${value_forward_expected} < ${expected_high}
#        ${value_forward_error}    get from dictionary    ${item}    Forward transmit RF power error (dB)
#        should be true    ${error_low} < ${value_forward_error} < ${error_high}
    END

Get Forward expected transmit RF power
    [Arguments]    ${cell_id}=1
    ${general_result}    selenium_coam.get_general_test_information    cell_id=${cell_id}
    FOR    ${item}    IN    @{general_result}
        ${value_forward_expected}    get from dictionary    ${item}    Forward expected transmit RF power
    END
	[Return]    ${value_forward_expected}

Modify targetTotalLoad
    [Arguments]    ${new_value}    ${cell_id}=1
    ${modify_params}    create list
    ${item}    create dictionary    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-${cell_id}
	...    filter_param=Target total load with artificial load
    ...    p_name=targetTotalLoad    value=${new_value}
    append to list  ${modify_params}  ${item}
	Modify Parameters On Webem  ${modify_params}    despite_errors=${False}

General_SiSo_Auto_RF_Module_Stability_Run
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    ${port_type}  COAM get ru port type
    #Delete RFTHLD If Exist
    Run Keyword If   '${stream}'=='SBTS23R1' or '${stream}'=='SBTS23R2'    Modify actRemoteRfDiag Parameter
    #Set default value for RFTHLD If Feature 956 Enabled
	Modify targetTotalLoad    new_value=${0}
	#rf_diagnostic_test_setup_aeqe    url=${url}
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    run keyword and ignore error    selenium_coam.clear_finished_results
    selenium_coam.configure_rf_diagnostic_test    technology=NR
    selenium_coam.start_rf_diagnostic_test    timeout=180
	${value_forward_before}    Get Forward expected transmit RF power
	Modify targetTotalLoad    new_value=${100}
	#rf_diagnostic_test_setup_aeqe    url=${url}
    Selenium Logout And Close Browser
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    run keyword and ignore error    selenium_coam.clear_finished_results
    selenium_coam.configure_rf_diagnostic_test    technology=NR
    selenium_coam.start_rf_diagnostic_test    timeout=180
	${value_forward_after}    Get Forward expected transmit RF power
	${value_forward_before_new}    evaluate    ${value_forward_before}-3
	should be true    ${value_forward_after}>${value_forward_before_new}
    Should Not Be Equal    ${value_forward_before}    ${value_forward_after}
    FOR    ${i}    IN RANGE   1    7
	    log to console    ${i}
	    Check RF Temperature
	END
	[Teardown]    Run keywords     Reduce RU load to 0    AND
	...    Selenium Logout And Close Browser

Reduce RU load to 0
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    Modify targetTotalLoad    new_value=${0}
    [Teardown]    Selenium Logout And Close Browser

Check RF Temperature
    [Arguments]  ${radio_id}=${1}    ${RF_temperature_high_threshold}=${90}    ${outcome}=Pass
    ...          ${min_temperature}=40    ${max_temperature}=90    ${rf_port_id}=0
    sleep    10min
    log    ${rf_port_id}
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    #Delete RFTHLD If Exist
    Run Keyword If   '${stream}'=='SBTS23R1' or '${stream}'=='SBTS23R2'    Modify actRemoteRfDiag Parameter
    #Set default value for RFTHLD If Feature 956 Enabled
    ${bts_thresholds}    create dictionary    RF temperature high threshold=${RF_temperature_high_threshold}
    #RF statistics diagnostic test setup    bts_thresholds=${bts_thresholds}    radio_id=${radio_id}
    selenium_coam.configure_statistics_diagnostic_test    radio=RMOD-${radio_id}
    selenium_coam.start_statistics_diagnostic_test    timeout=180
    sleep  30
    Check Statistics General Information    radio_id=${radio_id}    outcome=${outcome}
    Check RF Temperature Supervision    radio_id=${radio_id}    min_temperature=${min_temperature}    max_temperature=${max_temperature}
    [Teardown]  selenium logout and close browser

RF_Diagnostic_and_RF_scan_Test_For_notReadyGNB
    [Arguments]    ${connection}=GNB_OAM    ${ru_index}=${1}    ${technology}=NR TDD
    ...    ${radio}=RMOD-2 (AEQK)    ${capture_type}=Composite Rx (HBF0)
    ...    ${atenna}=PHYANT 1      ${antenna_panel}=PHYANT-1 All Arrays      ${local_cell}=${EMPTY}
    Selenium Login And Disable Screen Lock
    log to console    enable RF scan
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1
    ...  filter_param=Activate RFI testing    abbr=actRfiTesting    new_value=true
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${False}
    log to console    lock NRCELL-1
    connect to gnb coam via ssl    connection=${connection}
    perform_cell_lock_via_admin    cell_id=${1}    connection=${connection}    lock_timeout=120
    Wait Until Keyword Succeeds   5 min  5 sec   Check cell should be locked   cell_id=${1}
    sleep    3s
    log to console   power off RMOD-1
    Perform RU Power Off    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
    Wait until keyword succeeds    10 min    20 sec    RU Should Be Power Off    ru_index=${ru_index}
    Wait until keyword succeeds    10min    30s    Expect Fault Should Present    faultId=10
    sleep    5s
    log to console    perform RF diagnostic test
    ${status}    Run keyword and return status    RF Diagnostic Test Setup
    Should be True    ${status}
    sleep    10s
    log to console    start RF scan
    ${status}    Run keyword and return status    selenium_coam.start_rf_scan   technology=${technology}
    ...    radio=${radio}    capture_type=${capture_type}    antenna=${atenna}
    ...    antenna_panel=${antenna_panel}    local_cell=${local_cell}    timeout=${120}
    Should be True    ${status}
    log to console    unlock NRCELL-1
    perform_cell_unlock_via_admin    cell_id=${1}    connection=${connection}    lock_timeout=120
    log to console   power on RMOD-1
    Perform RU Power on    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
    sleep    30s
    Wait Until Keyword Succeeds    10min    30s    Verify all cells should be onair
    [Teardown]    Selenium Logout And Close Browser
