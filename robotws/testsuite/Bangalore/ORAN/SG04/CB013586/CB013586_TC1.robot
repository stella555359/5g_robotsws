*** Settings ***

Documentation
...   author: sudarshan.kanapuram@nokia.com
...   contact: sudarshan.kanapuram@nokia.com
...   Description: Test Suite for CB013586

Library     	Process
Library     	taf.file.pack
Library     	String
Library     	DateTime
Library     	Collections
Library     	OperatingSystem
Library     	taf.sbts.oam.coam.admin    WITH NAME    COAM
Resource    	./testsuite/Bangalore/ORAN/SG04/resources/reportingportal_Keywords.robot
Resource    	./testsuite/Bangalore/ORAN/SG04/resources/Common_resource.robot
Resource    	taf/rfrl/common_resources/common_step/interface.robot
Resource    	./testsuite/Bangalore/ORAN/SG04/resources/alarm.robot
Library     	taf.sw.scout    WITH NAME    scout
Library     	taf.config.scf.interface.scf     WITH NAME    scf
Library     	taf.ul.alarms_watchdog   WITH NAME    alarm
Variables   	./testsuite/Bangalore/ORAN/SG04/resources/CRT4_parameters.py



Test Setup      Test Setup
Test Teardown   Test Teardown

*** Variables ***

&{[1.0] CB013586_TC01_Verification of EPE counters for voltage and current after Radio Reset and Lock_Unlock}
...	QC_ID_FL00=QC_110939    QC_ID_SBTS25R2=QC_140914


*** Test Cases ***
[1.0] CB013586_TC01_Verification of EPE counters for voltage and current after Radio Reset and Lock_Unlock
    [Tags]    FL00    TRUNK_SG04    SBTS25R2    QCD_MN_RAN    QCP_RAN_VRF    13586
    [Teardown]    run keywords
    ...      Test teardown        AND    Set QC_Tag
    Link SCOUT SCF to Configuration ID for Reporting    tl_name_only=${scout_id1}
    EPE counters collection and validation
	${dcap_log_status}=    Set Variable    1.0
    Set suite variable    ${dcap_log_status}
    Log to console	DCAP_LOG_STATUS: ${dcap_log_status}


*** Keywords ***

Test Setup
    Log to console    \n--Test Setup--\n
    COAM.setup_admin	bts_host=${non_def_BTS_IP}
	${BTS_details}      taf.sbts.oam.coam.admin.get_bts_info       connection=default
    Log    ${BTS_details}
	Set global variable    ${BTS_ID}     ${BTS_details['mrbtsID']}
	Set global variable    ${dist_name}     MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1
    ${sw_version}=    COAM.get_sw_version
	Log to console  \n ${sw_version} \n
	Check BTS is OnAir    connection1=default
	##### Alarm validation start ###
	${Active_alarm}    COAM.get_active_alarms
    LOG     ${Active_alarm}
    ${allowed_alarms}    Expected alarm
    alarm.Watch alarms    allowed_alarms=${allowed_alarms}
    ...    reconnect=true    log_dir=/tmp
	##### Alarm validation end ###
    Log to console   \n--DCAP Started --\n
    ${trace_id}    DCAP Start
	Set global variable    ${trace_id}
    Log to console  \n--Epe_stats_update started-- \n
	Parameter value change	${dist_name}	miOranEpeStats    5min
	Log to console    \n--Test Setup finished--\n

Parameter value change
    [Arguments]    ${dist_name}     ${parameter}    ${value}
    [Documentation]     Change parameter valur=e in SCF and commision it
    Log to console      \nChanging gnb parameter ${parameter} to ${value}
	@{parameter_list}=    create list    ${parameter}
    ${current_value}    COAM.Get Parameter by distname   ${dist_name}    ${parameter_list}    connection=default
    LOG    ${current_value[0]['parameters']['miOranEpeStats']}
    Run Keyword If    '${current_value[0]['parameters']['miOranEpeStats']}'!='${value}'
    ...    COAM.Perform Parameter Recommissioning    dist_name=${dist_name}
    ...     parameter=${parameter}      operation=update    value=${value}    skip_parameter_relation_errors=True    connection=default
    ${current_value}    COAM.Get Parameter by distname   ${dist_name}    ${parameter_list}    connection=default
    LOG    ${current_value}
    Run keyword And Continue On Failure    Should Be Equal As Strings    ${current_value[0]['parameters']['miOranEpeStats']}    ${value}

EPE counters collection and validation
	Log to console   \n--Step2: EPE Counter Verification from BTS Started--\n
	Log to console   \n-- Wait 20Mins for the Counter to Report
	sleep    300s
    @{counter_list}=    create list    'M40021C0'    'M40021C1'    'M40021C2'    'M40021C3'    'M40021C4'    'M40021C5'
    ...    'M40021C6'    'M40021C4'    'M40021C8'    'M40021C9'    'M40021C10'    'M40021C11'

    ${result} =    coam.get_pm_counters    counter_ids=${epe_counter_nos}    timeout=600    connection=default
	FOR    ${I}    IN    @{counter_list}
		${values}=    Get Dictionary Values   ${result['BTS']['MRBTS-970']['EQM-1']['APEQM-1']['RMOD-1']['OEPE'][${I}]}
		${last_value}=     Set Variable     ${values[-1]}
		${float_value}=    Convert To Number    ${last_value}

		${int_part}=       Evaluate    int(${float_value})

		IF    ${I} in ['M40021C0', 'M40021C1', 'M40021C2']
			Should Be True          ${int_part} >= 180 and ${int_part} <= 380
		END
		IF    ${I} in ['M40021C3', 'M40021C4', 'M40021C5']
			Should Be True          ${int_part} >= 44 and ${int_part} <= 60
		END
		IF    ${I} in ['M40021C6', 'M40021C7', 'M40021C8']
			Should Be True          ${int_part} >= 50 and ${int_part} <= 60
		END
		IF    ${I} in ['M40021C9', 'M40021C10', 'M40021C11']
			Should Be True          ${int_part} >= 3 and ${int_part} <= 6
		END
	END

Test Teardown
    Log to console   --\n Test teardown Started\n--
	Log to console  \n--Epe_stats_update started-- \n
	Parameter value change	${dist_name}	miOranEpeStats    disabled
	Check BTS is OnAir
	##### Alarm validation start ###
	${Active_alarm}    COAM.get_active_alarms
    LOG     ${Active_alarm}
    alarm.stop_watching_alarms
	##### Alarm validation end ###
    Run Keyword If    ${dcap_log_status} == 1.0    Abort DCAP Trace
    ...    ELSE    DCAP Stop with log Transfer
    RP Settings
    coam.Teardown All Aliases For Admin
    interface.Common step trigger
    Log to console   --\n Test teardown COMPLETED \n--