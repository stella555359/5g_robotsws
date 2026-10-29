*** Settings ***
Documentation     author: shasha liu
...               Group: HGZ_SG5
...               contact: shasha.liu@nokia-sbell.com

*** Keywords ***
### part-1: 5GC001178-A ###
Step2: Check NG link status
    log to console    Step2: Check NG link status
    Check AMF status

Logout WebUI
    log to console    Logout WebUI
    Run Keyword And Ignore Error    selenium_coam.set_lock_screen_time    lock_time=${15}
    run keyword and ignore error    WEBUI Logout

Wait idle time
    log to console    sleep to wait
    Run Keyword and Ignore Error    selenium_coam.refresh_page
    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    #run keyword and ignore error      selenium_coam.enable_screen_lock
    ${lock_screen_time}=    selenium_coam.get_lock_screen_time
    run keyword if    "${lock_screen_time}" != "${2}"     selenium_coam.set_lock_screen_time    lock_time=${2}
    sleep    130s
    selenium_coam.login_after_screen_lock    passwd=${WEBUI_PASSWORD}

Acquire login fail info
    sleep    10s
    @{fail_info}    run keyword and ignore error    selenium_coam.login     url=${WEBUI_URL}
    ...   username=${WEBUI_USER}     password=${WEBUI_PASSWORD}
    should be equal    ${fail_info}[0]    FAIL

Check AMF status
    &{amf_status}    selenium_coam.get_amf_info
    should be equal    ${amf_status}[NG link status]    Active

step1:Login WebUI
    log to console    step1:Login WebUI
    wait until keyword succeeds      3min    10s     WEBUI Login

step2:collect snapshot
    log to console    step2:collect snapshot
    save snapshot    coverage=Most important log files    save_location=Local
    wait until keyword succeeds      10min    30s   check snapshot collected in local driver and copy it

step3:check configuration files collected
    log to console    step3:check configuration files collected
    check the expected file collected    pattern=*.ims2

step4:logout webui
    log to console    step4:logout webui
        run keyword and ignore error     WEBUI Logout

step2:collect All log snapshot
    log to console    step2:collect All log snapshot
    save snapshot    coverage=All log files    save_location=Local
    wait until keyword succeeds    20 min    30 sec    check snapshot collected in local driver and copy it

step3:check summary file collected
    log to console    step3:check summary file collected
    check the expected file collected    pattern=*metadata.txt

### part-3: 5GC000643-B ###
Step1: Trigger RU sync error
    WEBUI Login
	  ${mrbts_id}  ${nrbts_id}    Get Gnb BTS ID
	  Change Parameter via webUI
    ...    expected_val=43
    ...    dist_name=MRBTS-${mrbts_id}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1
	  ...    filter_param=ToP domain number
    ...    p_name=topDomainNumber
    Check Parameter via webUI
    ...    expected_val=43
    ...    dist_name=MRBTS-${mrbts_id}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1
	  ...    filter_param=ToP domain number
    ...    p_name=topDomainNumber


Step2: Check cell disabled
    wait until keyword succeeds    10min    1min   Check cell disabled

Check cell disabled
    ${cur_value}    wait until keyword succeeds    6min    30s   Get Parameter via webUI
    ...    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}
    ...    filter_param=Operational state
    ...    p_name=operationalState
    Should Be True    '${cur_value}'=='integrated to RAN' or '${cur_value}'=='configured'

Step3: Check fault raised on WebEM
    ${BTS_Name}    wait until keyword succeeds    2min    30s
    ...    selenium_coam.get_parameter_value
    ...    dist_name=MRBTS-${mrbts_id}
    ...    filter_param=BTS name
    ...    abbr=btsName
	set test variable     ${BTS_Name}
    wait until keyword succeeds     5min    1min    Check active fault on WebEM
    ...    alarm_filter=Unit synchronization failed
    ...    Severity_expect=critical
    ...    AlarmID_expect=7116
    ...    AlarmName_expect=BASE STATION SERVICE PROBLEM
    ...    FaultID_expect=16
    ...    FaultName_expect=Unit synchronization failed
    ...    AlarmOB_expect=[${BTS_Name}] MRBTS-${mrbts_id}/EQM_R-1/APEQM_R-1/RMOD_R-1
#	  wait until keyword succeeds     5min    1min    Check active fault on WebEM
#    ...    alarm_filter=ToP reference missing
#    ...    Severity_expect=minor
#    ...    AlarmID_expect=7115
#    ...    AlarmName_expect=BASE STATION INFORMATION
#    ...    FaultID_expect=4298
#    ...    FaultName_expect=ToP reference missing
#    ...    AlarmOB_expect=[${BTS_Name}] MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/EQM_R-1/APEQM_R-1/RMOD_R-1

Step4: Trigger RU recover sync
    Change Parameter via webUI
    ...    expected_val=24
    ...    dist_name=MRBTS-${mrbts_id}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1
	  ...    filter_param=ToP domain number
    ...    p_name=topDomainNumber
    Check Parameter via webUI
    ...    expected_val=24
    ...    dist_name=MRBTS-${mrbts_id}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1
	  ...    filter_param=ToP domain number
    ...    p_name=topDomainNumber

Step5: Check fault disapper on WebEM
    wait until keyword succeeds    20min    1min    Check fault disapper on WebEM

Step6: Check cell onair
    wait until keyword succeeds     10min    1min    coam_resource.Check Cell is UP

Check fault disapper on WebEM
    @{alarm_active_16}=    wait until keyword succeeds    10min    1min    selenium_coam.get_active_alarm_info
    ...    alarm_filter=Unit synchronization failed    timeout=60
    should be empty    ${alarm_active_16}
#  	@{alarm_active_4298}=    wait until keyword succeeds    5min    1min    selenium_coam.get_active_alarm_info
#    ...    alarm_filter=ToP reference missing    timeout=60
#    should be empty    ${alarm_active_4298}

Recvoer parameter
    ${topDomainNumber}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbts_id}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1
	  ...    filter_param=ToP domain number    abbr=topDomainNumber
    run keyword if     ${topDomainNumber}!=24    Change Parameter via webUI    expected_val=24
   	...    dist_name=MRBTS-${mrbts_id}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1
   	...    filter_param=ToP domain number    p_name=topDomainNumber

Check active fault on WebEM
    [Arguments]   ${alarm_filter}   ${Severity_expect}    ${AlarmID_expect}   ${AlarmName_expect}   ${FaultID_expect}
    ...    ${FaultName_expect}    ${AlarmOB_expect}
    run keyword and ignore error    selenium_coam.logout
    selenium_coam.login    url=${WEBUI_URL}    username=${WEBUI_USER}    password=${WEBUI_PASSWORD}
    run keyword and ignore error      selenium_coam.disable_message_box
    sleep    15s
    Connect to gnb coam via ssl
    ${Active_SW}    Get Active SW Version
    ${stream}    get stream from version    ${Active_SW}
    @{alarm info}=    selenium_coam.get_active_alarm_info    alarm_filter=${alarm_filter}    timeout=60
    ${fault_dic}   set variable    ${alarm info}[0]
    ${Severity}    set variable    ${fault_dic}[Severity]
    ${Alarm_ID}    set variable    ${fault_dic}[Alarm ID]
    ${Alarm_name}    set variable    ${fault_dic}[Alarm name]
    ${Fault_ID}    set variable    ${fault_dic}[Fault ID]
    ${Fault_name}    set variable    ${fault_dic}[Fault name]
    ${Alarming_object}    set variable if   '${stream}'=='11.800'   ${fault_dic}[Alarming object]
    ...    ${fault_dic}[Configuration alarming object]
    should be equal     ${Severity}     ${Severity_expect}
    should be equal     ${Alarm_ID}     ${AlarmID_expect}
    should be equal     ${Alarm_name}   ${AlarmName_expect}
    should be equal     ${Fault_ID}     ${FaultID_expect}
    should be equal     ${Fault_name}   ${FaultName_expect}
    run keyword and ignore error    should be equal     ${Alarming_object}     ${AlarmOB_expect}

### part-5: 5GC002519_MA ###
Check M55318C00001 Counter
    [Arguments]    ${change_interval}
    connect to common unit master
    sleep  5min
    ${M55318C00001_value}    Get PM Counter via Webem    counter_id=M55318C00001    interval=${change_interval}
    ${M55318C00001_value}    convert to integer     ${M55318C00001_value}
    Should Be True    ${M55318C00001_value} >0
    [Teardown]  csn.Disconnect  connection=ASIK Master

### part-7: CB006293 ###
General_SiSo_Initiate_RF_diagnostic_test_from_BTS_Element_Manager_with_L3Call_AEQE
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this case is to verify that RF diagnostic test can be run by WebEM and test
    ...    result can be gotten successfully in BTS.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 08.05.2021 - - Created
    ...    *******************
    ...    yue.2.liu@nokis-sbell
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
    selenium logout and close browser
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

### part-3: 5GC000643-B: inherit testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC002118/Resource/5GC002118_common_KW.robot
Get Gnb BTS ID
    coam.connect to   bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...               bts_port=${443}  name=coam
    &{bts_info}   coam.get_bts_info   connection=coam   timeout=10
    ${mrbts_id}    set variable     ${bts_info['mrbtsID']}
    ${nrbts_id}    set variable     ${bts_info['nrBtsId']}
    coam.teardown          connection=coam
    [Return]    ${mrbts_id}    ${nrbts_id}

Check Parameter via webUI
    [Arguments]    ${expected_val}    ${dist_name}    ${filter_param}    ${p_name}
    ${current_val}    Get Parameter via webUI     dist_name=${dist_name}
    ...                                           filter_param=${filter_param}
    ...                                           p_name=${p_name}
    should be equal    ${current_val}    ${expected_val}

Get Parameter via webUI
    [Arguments]    ${dist_name}    ${filter_param}    ${p_name}
    ${current_val}    Run Keyword And Continue On Failure    selenium_coam.get_parameter_value
    ...                                                      dist_name=${dist_name}
    ...                                                      filter_param=${filter_param}
    ...                                                      abbr=${p_name}
    ...                                                      timeout=${120}
    [Return]    ${current_val}

Set Parameter value via webUI
    [Arguments]    ${expected_val}    ${dist_name}    ${filter_param}    ${p_name}
    ...            ${is_need_to_check_validation_errors}=${False}    ${need_active}=${True}
    Run Keyword and Ignore Error    WEBUI Login
    selenium_coam.set_parameter_value    dist_name=${dist_name}
    ...                              filter_param=${filter_param}
    ...                              new_value=${expected_val}
    ...                              abbr=${p_name}
    ...                              timeout=${120}
    selenium_coam.validate_plan
    ${errors}    Get Validate error
    Run keyword if    ${is_need_to_check_validation_errors}==${True}
    ...    Should be empty    ${errors}
    Run keyword if    ${need_active}==${True}
    ...    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    [Return]    ${errors}

#Get Validate error
#    ${defination_errors}    selenium_coam.get_definition_errors    timeout=${120}
#    ${relation_errors}      selenium_coam.get_relation_errors    timeout=${120}
#    ${hardware_errors}      selenium_coam.get_hardware_errors    timeout=${120}
#    ${errors}    Catenate    ${defination_errors}   ${relation_errors}    ${hardware_errors}
#    [Return]    ${errors}

Get Validate error
    ${defination_errors}    selenium_coam.get_definition_errors    timeout=${120}
    ${relation_errors}      selenium_coam.get_relation_errors    timeout=${120}
    ${hardware_errors}      selenium_coam.get_hardware_errors    timeout=${120}
#    ${errors}    Catenate    ${defination_errors}   ${relation_errors}    ${hardware_errors}
    [Return]    ${defination_errors}   ${relation_errors}   ${hardware_errors}


Change Parameter via webUI
    [Arguments]    ${expected_val}    ${dist_name}    ${filter_param}    ${p_name}
    ...            ${is_need_to_check_validation_errors}=${False}    ${need_active}=${True}
    ${current_val}    Run Keyword And Continue On Failure    selenium_coam.get_parameter_value
    ...                                                      dist_name=${dist_name}
    ...                                                      filter_param=${filter_param}
    ...                                                      abbr=${p_name}
    ${errors}    run keyword if  not '${current_val}'=='${expected_val}'
    ...                     Set Parameter value via webUI     expected_val=${expected_val}
    ...                                                       dist_name=${dist_name}
    ...                                                       filter_param=${filter_param}
    ...                                                       p_name=${p_name}
    ...                                                       is_need_to_check_validation_errors=${is_need_to_check_validation_errors}
    ...                                                       need_active=${need_active}
    ${current_val}    Run Keyword And Continue On Failure    selenium_coam.get_parameter_value
    ...                                                      dist_name=${dist_name}
    ...                                                      filter_param=${filter_param}
    ...                                                      abbr=${p_name}
    Run keyword if    ${need_active}==${True}
    ...    should be equal    ${current_val}    ${expected_val}
    [Return]    ${current_val}    ${errors}
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
