*** Settings ***
Documentation    CB013240:ENERGY SAVING MODE PM COUNTERS IMPROVEMENTS

Library             Process
Library             Collections
Library             OperatingSystem    WITH NAME     os
Library             taf.sw.dcap.rd       WITH NAME     dcap
Library             taf.sbts.oam.coam.admin    WITH NAME     admin
Library             String
Library             taf.collectors.core   WITH NAME   core
Library             taf.collectors.btslog  WITH NAME   btslog
Library             DateTime
Library             taf.ul.alarms_watchdog   WITH NAME    alarm
Library             taf.transport.ssh    WITH NAME    ssh
Library             SSHLibrary
Library             BuiltIn
Library             taf.sw.scout    WITH NAME    scout
Library             ute_fsmaccess
Library             taf.collectors.simple    WITH NAME    simple
Library             taf.collectors.pmcounters    WITH NAME    PM
Library             taf.analyzer.pmcounter    WITH NAME    analyser
Library             ./resources/UpdateCellSOParameters_LTE.py
Resource            taf/rfrl/common_resources/common_step/interface.robot
Resource            ./resources/CB013240_keywords.robot
Suite Setup		    Suite_Setup
Suite Teardown		Suite_Teardown


*** Variables ***
${bool}=    True

*** Test Cases ***
CB013240_TC01_Verification of NR FDD Cell state counters.
    ${bts_time}=    calculateDateTime
    LOG    ${bts_time}
	${time}  BuiltIn.Convert To String    ${bts_time}
	${day}    ${hour}    ${minute}=    Evaluate    ${time}
	LOG    ${day}
	LOG    ${hour}
	LOG    ${minute}
	Login To Admin
    Collect_SCF
	update_lbps_start_time    ${output_File}    ${output_File}    ${day}    ${hour}    ${minute}    ${cellSoduration}
	remove_ns_prefix    ${output_File}    ${output_File}
	SCF commissioning    ${output_File}
	BuiltIn.Sleep    600
	Wait Until Keyword Succeeds    15min    60s    Check Energy saving State    ${CellState_LTE}[0]
	Wait Until Keyword Succeeds    15min    60s    Check Energy saving State NR     ${CellState_NR}[0]
	Sleep    900
	Wait Until Keyword Succeeds    15min    60s    Check Energy saving State NR     ${CellState_NR}[1]
	Wait Until Keyword Succeeds    15min    60s    Check Energy saving State    ${CellState_LTE}[1]
    Counter Verification
	Counter Verification NR
    Test Teardown
