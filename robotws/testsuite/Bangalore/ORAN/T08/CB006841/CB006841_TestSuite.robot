*** Settings ***
Documentation
...   author: Sreekumar Narimuri Kumaran
...   contact: sreekumar.narimuri_kumaran@nokia.com
...   Description: Test Suite for CB006841

Library    BuiltIn
Library    Collections
Library    String
Library    OperatingSystem
Library    SSHLibrary
Library    DateTime
Library    RequestsLibrary
Library    Process
Resource    testsuite/Bangalore/ORAN/T08/resources/robot/CommonKeywordResourceFile.robot
Resource    testsuite/Bangalore/ORAN/T08/resources/robot/Topyoung_Attenuator_T08.robot
Resource	testsuite/Bangalore/ORAN/T08/resources/robot/Reporting_Portal_Keywords.robot
Resource    ${CURDIR}/resources/CB006841_Keywords.robot
Library		testsuite/Bangalore/ORAN/resources/python/downloadwftpackage.py

Suite Setup    Run Keywords      UTE_ORAN_TL_Bringup_Precondition
...    AND    Check fault 23 and fix
...    AND    Wait Until BTS is OnAir
...    AND    Set export yml    ${VM_IP}
...    AND    Copy swconfig to BTS    ${swconfig_path}
...    AND    Suite Setup

Suite Teardown      Suite Postcondition
Test Setup      	Admin_setup
Test Teardown   	Admin_teardown


*** Variables ***
${VM_usn}    ute
${VM_pwd}    BT5l@bus3rl0g1n
${VM_IP}    10.58.238.125
${DURATION}    800s
@{timeout}=    100
@{UE_alias}=  UE_2
@{capabilities}    Legacy_2
${dt_name_dl}=    UDP
${dt_name_v}=    test_voice_call
${dl_name}=    iperf_dl_test_1
@{deviation_dl}=    100
@{throughput_dl}=    100
@{direction_dl}=      dl
${dt_name}=     iperf_dl_test_1
@{CALL_type}    UDP
#${DISTNAME}   MRBTS-1024/NRBTS-1024/NRCEL-0
${DISTNAME}   MRBTS-1024/MNL-1/MNLENT-1/FEATCADM-1
${Parameter_abbr}    	disableHwfMigrInSwUpgr
${BTS_IP}    10.58.239.191
${testcase_name_2}	CB006841_activated
${testcase_name_1}	CB006841_disabled
${pva_ip}    10.45.153.212
${pva_vendor}    TOPYOUNG
${pva_model}    TAS16T16-51-120-1N-DEJS
${swconfig_path}=     testsuite/Bangalore/ORAN/T08/resources/config/swconfig.txt

*** Test Cases ***
CB006841_SW_activation_downtime_reduction_by_feature_activation
    [Documentation]
    ...
    ...  DESCRIPTION: This testcase verifies sw activtaion downtime reduction when the feature is activated
    ...
    ${out}    set variable
    ...    ${SUITE_PATH}CB006841TESTSUITE/SW_activation_downtime_reduction/
    set test variable    ${out}
    create directory     ${out}
	log    Download latest sbts software
	${SBTS_type}=    Get_SBTS_build_type_from_BTS
	${current_trunk_prefix}=    Fetch_current_trunk_build_type
	IF   '${SBTS_type}'== '${current_trunk_prefix}'
		${SBTS_type}    Set Variable    SBTS00
	END
	${sw_path}=    latestSbtsBuild    downloadable_type=A54	  branch=${SBTS_type}
	log    ${sw_path}
	log    verifying downtime when feature is not enabled.
	parameter update   ${DISTNAME}    ${Parameter_abbr}    value=${False}
	log    Install SBTS software
	#Dcap Start Trace SA
	CoamAdmin.update_software   sw_package=${sw_path}    should_activate=True   timeout=600
	...    connection=oam   should_reset_radios=False    override_ru_software=None    independent_sw_update_type=None
	Wait Until Keyword Succeeds    10min    5s	Check BTS is Not OnAir    oam
	log to console      all cells are down and system went to reboot
	${time_before_reset}=  Get Current Date		result_format=datetime
        ${time_before_reset}    Convert Date    ${time_before_reset}       result_format=%I:%M:%S
        log to console   ${time_before_reset}

	Wait Until Keyword Succeeds    10min    5s	Check BTS is OnAir    oam
	#Dcap Stop Trace and Get results SA      ${testcase_name_1}
	Collect Snapshot
	Rename Snapshot   ${testcase_name_1}
	${time_after_reset}=  Get Current Date		result_format=datetime
        ${time_after_reset}    Convert Date    ${time_after_reset}       result_format=%I:%M:%S
        log to console   ${time_after_reset}
        ${Downtime_Feature_Disabled} =	Subtract Time From Time       ${time_after_reset}    ${time_before_reset}
#	${Downtime_Feature_Disabled}=    Evaluate    ${time_after_reset} - ${time_before_reset}
	log    Roll back to previous software build.
	CoamAdmin.rollback_software		timeout=300     connection=oam
	Wait Until Keyword Succeeds    10min    5s	Check BTS is Not OnAir    oam
	Wait Until Keyword Succeeds    10min    5s	Check BTS is OnAir    oam
	log    Enabling feature flag..
	parameter update   ${DISTNAME}    ${Parameter_abbr}    value=${True}
	log    Install SBTS software
	#Dcap Start Trace SA
	CoamAdmin.update_software   sw_package=${sw_path}    should_activate=True   timeout=600
	...    connection=oam   should_reset_radios=False    override_ru_software=None    independent_sw_update_type=None
	Wait Until Keyword Succeeds    10min    5s	Check BTS is Not OnAir    oam
	log to console      all cells are down and system went to reboot
	${time_before_reset}=  Get Current Date		result_format=datetime
        ${time_before_reset}    Convert Date    ${time_before_reset}       result_format=%I:%M:%S
        log to console   ${time_before_reset}
	Wait Until Keyword Succeeds    10min    5s	Check BTS is OnAir    oam
	#Dcap Stop Trace and Get results SA      ${testcase_name_2}
	Collect Snapshot
	Rename Snapshot   ${testcase_name_2}
	${time_after_reset}=  Get Current Date		result_format=datetime
        ${time_after_reset}    Convert Date    ${time_after_reset}       result_format=%I:%M:%S
        log to console   ${time_after_reset}
        ${Downtime_Feature_Enabled} =	Subtract Time From Time       ${time_after_reset}    ${time_before_reset}
#	${Downtime_Feature_Enabled}=    Evaluate    ${time_after_reset} - ${time_before_reset}
        ${Downtime_reduction} =	Subtract Time From Time       ${Downtime_Feature_Disabled}    ${Downtime_Feature_Enabled}
#	${Downtime_reduction}=    Evaluate    ${Downtime_Feature_Disabled} - ${Downtime_Feature_Enabled}
#	Should be True      ${Downtime_reduction} > 30
#	Should be True      ${Downtime_Feature_Disabled} > ${Downtime_Feature_Enabled}
    log    Downtime_Feature_Disabled=${Downtime_Feature_Disabled}
	log    Downtime_Feature_Enabled=${Downtime_Feature_Enabled}
	log    Difference in Downtime = ${Downtime_reduction}
	Attach UE and start throughput   ${UE_alias}    ${direction_dl}    ${timeout}

