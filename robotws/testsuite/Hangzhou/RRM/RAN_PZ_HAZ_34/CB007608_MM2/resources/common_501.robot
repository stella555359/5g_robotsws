*** Settings ***
Documentation      author: Charlotte Wu
...                Group: I_NSB_MN_5GSC_MMW_SC_PZ_HZ_02_GMS
...                contact: charlotte.wu@nokia-sbell.com
...                Description
Library            OperatingSystem
Library            Process
Library            String
Library            DateTime
Library            taf.transport.ssh    WITH NAME    ssh
Library            Collections
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot

*** Variables ***
${A2_event_filter_1}    nr-rrc.eventA2_element
${A2_event_filter_2}    nr-rrc.measurementReport_element
${xpath_A2_report_1}    .//nr-rrc.eventA2_element/../../../../../../..//nr-rrc.reportConfigId

*** Keywords ***

Enable Feature 501
    [Documentation]  Author: charlotte.wu
    ...              Description: Enable 5GC000501 parameter
	${MRBTS_ID}=    Get MRBTS Id in COAM WebEM
	${feature_status}=    selenium_coam.get_parameter_value
    ...    dist_name=${MRBTS_ID}/NRBTS-1
    ...    filter_param=Activate graceful cell shutdown
    ...    abbr=actGrflShdn
    Run Keyword If    '${feature_status}'!='true'
	...    selenium_coam.set_parameter_value
        ...    dist_name=${MRBTS_ID}/NRBTS-1
        ...    abbr=actGrflShdn
        ...    new_value=true
        ...    filter_param=Activate graceful cell shutdown
    sleep    1s
    selenium_coam.validate_plan
    sleep    8s
    selenium_coam.activate_plan    activate_plan_despite_errors=True

Enable actA2SgnbRelease
    [Documentation]  Author: charlotte.wu
    ...              Description: Enable actA2SgnbRelease
	${MRBTS_ID}=    Get MRBTS Id in COAM WebEM
	${feature_status}=    selenium_coam.get_parameter_value
    ...    dist_name=${MRBTS_ID}/NRBTS-1
    ...    filter_param=Activate A2 based SgNB release
    ...    abbr=actA2SgnbRelease
    Run Keyword If    '${feature_status}'!='true'
	...    Enable actA2SgnbRelease and a2MeasReleaseEnabled

Enable actA2SgnbRelease and a2MeasReleaseEnabled
    [Documentation]  Author: charlotte.wu
    ...              Description: Enable actA2SgnbRelease related parameter
	${MRBTS_ID}=    Get MRBTS Id in COAM WebEM
    selenium_coam.set_parameter_value
    ...    dist_name=${MRBTS_ID}/NRBTS-1
    ...    abbr=actA2SgnbRelease
    ...    new_value=true
    ...    filter_param=Activate A2 based SgNB release
    selenium_coam.set_parameter_value
    ...    dist_name=${MRBTS_ID}/NRBTS-1/NRCELL-1
    ...    abbr=a2MeasReleaseEnabled
    ...    new_value=rsrp
    ...    filter_param=A2 measurement configuration for SgNB release enabled
	selenium_coam.add_element
	...    dist_name=${MRBTS_ID}/NRBTS-1/NRCELL-1
	...    abbr=a2MeasReleaseSsbRsrp
	...    filter_param=A2 measurement SSB RSRP for SgNB release
    selenium_coam.set_parameter_value
    ...    dist_name=${MRBTS_ID}/NRBTS-1/NRCELL-1
    ...    abbr=a2HysteresisReleaseSsbRsrp
    ...    new_value=0
    ...    filter_param=A2 hysteresis SSB RSRP for SgNB release
    selenium_coam.set_parameter_value
    ...    dist_name=${MRBTS_ID}/NRBTS-1/NRCELL-1
    ...    abbr=a2ThresholdReleaseSsbRsrp
    ...    new_value=86
    ...    filter_param=A2 threshold SSB RSRP for SgNB release
    selenium_coam.set_parameter_value
    ...    dist_name=${MRBTS_ID}/NRBTS-1/NRCELL-1
    ...    abbr=a2TimeToTriggerReleaseSsbRsrp
    ...    new_value=ms40
    ...    filter_param=A2 time to trigger SSB RSRP for SgNB release
    sleep    1s
    selenium_coam.validate_plan
    sleep    8s
    selenium_coam.activate_plan    activate_plan_despite_errors=True
	
Shutdown the first cell
    ${MRBTS_ID}=    Get MRBTS Id in COAM WebEM
    selenium_coam.set_parameter_value
    ...    dist_name=${MRBTS_ID}/NRBTS-1/NRCELL-1
    ...    abbr=administrativeState
    ...    new_value=Shutting Down
    ...    filter_param=Administrative state
    sleep    1s
    selenium_coam.validate_plan
    sleep    8s
    selenium_coam.activate_plan    activate_plan_despite_errors=True

Unlock the first cell
    ${MRBTS_ID}=    Get MRBTS Id in COAM WebEM
    selenium_coam.set_parameter_value
    ...    dist_name=${MRBTS_ID}/NRBTS-1/NRCELL-1
    ...    abbr=administrativeState
    ...    new_value=Unlocked
    ...    filter_param=Administrative state
    sleep    1s
    selenium_coam.validate_plan
    sleep    8s
    selenium_coam.activate_plan    activate_plan_despite_errors=True

Check Cell Status after plan activation
    Connect to gnb coam via ssl    connection=GNB_OAM
    #Conect to DU COAM    connection=GNB_OAM
    #Cloud DU connect to gnb coam via ssl    connection=GNB_OAM
    ${Status}=    Get Cell Status
	Log    ${Status}
	Should Be Equal As Strings  ${Status["administrativeState"]}  ShuttingDown
	[Teardown]   admin_cli.teardown    connection=GNB_OAM 
	
Check Cell Locked
    ${Status}=    Get Cell Status
    Should be equal as strings    ${Status["administrativeState"]}    Locked    msg=Current status is ${Status["administrativeState"]}
    ...                      ignore_case=${True}

Wait until cell lock
    Connect to gnb coam via ssl    connection=GNB_OAM
    #Conect to DU COAM    connection=GNB_OAM
    #Cloud DU connect to gnb coam via ssl    connection=GNB_OAM
    Wait Until Keyword Succeeds    10min    20s    Check Cell Locked
	[Teardown]   admin_cli.teardown    connection=GNB_OAM 
	
Check A2 report in x2 log
    [Documentation]    Author: charlottw wu
    ...                Description: Check A2 report exist in x2 log
    [Arguments]    ${pcap_file}
    ${filtered_packets_1}=    Load pcap with filter    pcap_file=${pcap_file}    filter_expression=${A2_event_filter_1}
	${x2_result}=    cap.get_field_value_by_xpath
	...    xpath=${xpath_A2_report_1}    attribute_name=show
	${reportId}=    Catenate
	...    SEPARATOR=    .//nr-rrc.reportConfigId[@show='    ${x2_result}[0]    ']/../../nr-rrc.MeasIdToAddMod_element/nr-rrc.measId
	${x2_result_1}=    cap.get_field_value_by_xpath
	...    xpath=${reportId}    attribute_name=show
	${filtered_packets_2}=    Load pcap with filter    pcap_file=${pcap_file}    filter_expression=${A2_event_filter_2}
	${xpath_A2_report_2}=    Catenate    SEPARATOR=    .//nr-rrc.measurementReport_element//nr-rrc.measId[@show='    ${x2_result_1}[0]    ']
	${x2_result_2}=    cap.get_field_value_by_xpath
	...    xpath=${xpath_A2_report_2}    attribute_name=show
    Should be true    ${x2_result_2}[0] == ${x2_result_1}[0]
