
*** Settings ***

Documentation
...   author: Rubina Nath
...   contact: rubina.nath@nokia.com
...   Description: Test Suite for O-DU Conformance Feature Testing for every release.
...   It reduces manual testing efforts and validates netconf messages for each conformance as per specification.
...   "Test Case coverage in Documentation section for each case respectively"

Library     SSHLibrary
Library     taf.collectors.core   WITH NAME   core
Library     taf.collectors.btslog  WITH NAME   btslog
Library     BuiltIn
Library     DateTime
Library     OperatingSystem     WITH NAME    os
Library     taf.sbts.oam.coam.admin    WITH NAME    admin
Library     taf.file.pack

Suite Setup		        Suite_Setup
Test Setup	            Test Setup
Test Teardown           Test_Teardown
Suite Teardown		    Suite_Teardown

Resource       testsuite/Bangalore/ORAN/T02/resources/robot/ConformanceNetconfValidation.robot
Resource       testsuite/Bangalore/ORAN/T02/resources/robot/OperationKeywords.robot
Resource       testsuite/Bangalore/ORAN/T02/resources/robot/ETKeywordsResourceFileAPoABIO.robot
Library        testsuite/Bangalore/ORAN/T02/resources/python/snapshotFileIdentifier.py
Library        ./testsuite/Bangalore/ORAN/resources/python/netconf_validation.py

*** Variables ***

${BTS_ADDRESS} =            192.168.255.129
${netconf_password}=        xran-password
${Backdoor_cmd}=           /opt/UE_APP_OAM/service/oran/xml/backdoor
${Backdoor_ald_err}=       /opt/UE_APP_OAM/service/oran/xml/backdoor/ald/o-ran-ald-set-report-frames-with-error.xml
${Backdoor_ald_prt}=       /opt/UE_APP_OAM/service/oran/xml/backdoor/ald/o-ran-notif-ald-invalid-port-report.xml
${Backdoor_eac_inT}=       /opt/UE_APP_OAM/service/oran/xml/backdoor/externalio/o-ran-external-io-change_true.xml
${Backdoor_eac_inF}=       /opt/UE_APP_OAM/service/oran/xml/backdoor/externalio/o-ran-external-io-change.xml
${Backdoor_sw1}=           /opt/UE_APP_OAM/service/oran/xml/backdoor/swmgt/software-install-notif-test-ko_1.xml
${Backdoor_sw2}=           /opt/UE_APP_OAM/service/oran/xml/backdoor/swmgt/software-install-notif-test-ko_2.xml
${Backdoor_alr1_gen}=      /opt/UE_APP_OAM/service/oran/xml/backdoor/alarm/fm-test-1-alarm-fid_4.xml
${Backdoor_alr2_gen}=      /opt/UE_APP_OAM/service/oran/xml/backdoor/alarm/fm-test-1-alarm-fid_2.xml
${Backdoor_alr1_clr}=      /opt/UE_APP_OAM/service/oran/xml/backdoor/alarm/fm-test-1-alarm-fid_4-clearing.xml
${Backdoor_alr2_clr}=      /opt/UE_APP_OAM/service/oran/xml/backdoor/alarm/fm-test-1-alarm-fid_2-clearing.xml
${operation}=              update
${distEAC_name}=           MRBTS-1/EQM-1/APEQM-1/RMOD-1/EAC_OUT-1
${distRU_name}=            MRBTS-1/EQM-1/APEQM-1/RMOD-1
${distsup_name}=           MRBTS-1/EQM-1/APEQM-1/CABINET-1/BBMOD-1/SFP-1/LANE-1
${admstate}=               administrativeState
${distLBM_name}=           MRBTS-1/MNL-1/MNLENT-1/FEATCADM-1
${parameter_LBM}=          actLbmOnFronthaul
${value_true}=             true
${value_false}=            false
${inuse}=                  inUse
${connection}=             default
${timeout}=                600
${BTS_path}=               /home/ute/Logs
${laneUnlocked}=           Unlocked
${laneLocked}=             Locked
@{list_fault_4_2_17}=      4    2    17
@{list_faults_admin}=      4    2    4692    7115    7220    4654    61524    61649    4655
${sw1}=             	   /home/ute/ORUsoftware/FJ-RU-ET1---------0103.FGF.zip
${sw2}=             	   /home/ute/ORUsoftware/FJ-RU-ET1---------0202.FGF.zip
&{default_user}=    	   defaultNetconfAccountName=xranuser
...                    	   defaultNetconfAccountPwd=xran-password
&{faulty_user}=     	   defaultNetconfAccountName=xranuser123
...                 	   defaultNetconfAccountPwd=xran-passworddd
&{add_user}=        	   additionalNetconfAccountName=xranuser2
...                 	   additionalNetconfAccountPwd=XRANuser%$123
...                 	   additionalNetconfAccountType=sudo
&{dictn}=           	   defaultNetconfAccount=${default_user}
...                 	   additionalNetconfAccount=${add_user}
&{authen}=          	   publicKeySshServerFormat=EMPTY
...                 	   publicKeySshServerValue=EMPTY
&{authentication}   	   id=1    defaultNetconfAccount=&{default_user}    additionalNetconfAccount=&{add_user}
@{sudo_list}=       	   &{authentication}
&{authentication2}  	   id=1    defaultNetconfAccount=&{faulty_user}
@{sudo_list2}=      	   &{authentication2}
&{authentication1}  	   id=1    defaultNetconfAccount=&{default_user}
@{sudo_list1}=      	   &{authentication1}

${xmlfile_commonline1}=      	     <?xml version="1.0"?>\n<active-alarm-test-list xmlns="urn:o-ran-test:fm:1.0">\n<active-alarms>
${xmlfile_line4}=    		     <fault-name>EFaultId_NoExternalSynchronizationSourceAl</fault-name>\n<fault-id>17</fault-id>
${xmlfile_line6}=    		     <fault-source>N75N3N1-G-RU</fault-source>
${xmlfile_commonline7}=		     <affected-objects>\n<name>Object 1</name>\n</affected-objects>
${xmlfile_commonline10}=   	     <fault-severity>MAJOR</fault-severity>
${xmlfile_commonline11}=     	     <is-cleared>false</is-cleared>\n<fault-text>Fault caused by source 1 affecting 3 objects</fault-text>
${xmlfile_commonline12}=     	     <event-time>2020-08-13T15:13:28+02:00</event-time>\n</active-alarms>\n</active-alarm-test-list>
${xmlfile_commonline13_clear}=       <is-cleared>true</is-cleared>\n</active-alarms>\n</active-alarm-test-list>
@{faultListofXMLlines17}=            ${xmlfile_commonline1}    ${xmlfile_line4}    ${xmlfile_line6}
...                                  ${xmlfile_commonline7}    ${xmlfile_commonline10}     ${xmlfile_commonline11}    ${xmlfile_commonline12}
@{faultListofXMLlines17_clear}=      ${xmlfile_commonline1}    ${xmlfile_line4}    ${xmlfile_commonline13_clear}
${fault17_gen_xmlfilename}=          fm-test-17-alarm.xml
${fault17_clr_xmlfilename}=          fm-test-17-alarm-clearing.xml

@{miOranEpeStats_CounterList}=	     M40021C0    M40021C1	M40021C2	M40021C3	M40021C4	M40021C5
...	                             M40021C7    M40021C8	M40021C9	M40021C10	M40021C11       M40021C6
${miOranEpeStats_name}=     	     miOranEpeStats
${windowStatsValue}=       	     5min
${windowStatsValue_disable}=         disabled
${distname_pmmnl}=            	     MRBTS-1/MNL-1/MNLENT-1/PMMNL-1
@{EPE_capabilities}=                 POWER
${miOranEpeStats_Counter}=           BTS']['MRBTS-1']['EQM-1']['APEQM-1']['RMOD-1']['OEPE
@{active}=                           true    false

*** Test Cases ***

Conformance_Script_For_All_Positive_Cases
    [Documentation]    Transport and Handshake in IPv4 Environment for positive scenario - TEST CASE_3.1.1.1
	...    	Troubleshooting Test - TEST CASE_3.1.12.1
	...    	Subscription to Notifications - TEST CASE_3.1.2.1
	...    	O-RU configurability test (positive case) - TEST CASE_3.1.10.1
	...     EACin, EACout, filter applied, filter not applied, LBM, Alarms
	...     M-plane positive, ORU alarm gen
	...     Sudo
	[Tags]    TC1

    Reset Site
    Sleep    100s
    Configure Netconf Credentials    @{sudo_list}
    Sleep    300s
    Configure Netconf Credentials    @{sudo_list1}
    Sleep    100s
    os.Run    chmod 777 /home/ute/robotws/testsuite/Bangalore/ORAN/T02/resources/robot/x2link.sh
    os.Run    sh /home/ute/robotws/testsuite/Bangalore/ORAN/T02/resources/robot/x2link.sh
    Wait Until Keyword Succeeds     10m    10s    Check_BTS_State

    Log    Active Alarms Retrieval
    Send Cmd By Netopeer Cli xranuser APoabio    ${Backdoor_alr1_gen}
    Send Cmd By Netopeer Cli xranuser APoabio    ${Backdoor_alr2_gen}
    Sleep    60s
    Check ActiveFaultandAlarmID    @{list_faults_admin}
    Send Cmd By Netopeer Cli xranuser APoabio    ${Backdoor_alr1_clr}
    Send Cmd By Netopeer Cli xranuser APoabio    ${Backdoor_alr2_clr}
    Sleep    60s
    Create_alarm_xml    ${fault17_gen_xmlfilename}    @{faultListofXMLlines17}
    Create_alarm_xml    ${fault17_clr_xmlfilename}    @{faultListofXMLlines17_clear}
    Send Cmd By Netopeer Cli xranuser APoabio     ${Backdoor_cmd_apoabio}/${fault17_gen_xmlfilename}
    Sleep    60s
    Check ActiveFaultandAlarmID    @{list_faults_admin}
    Send Cmd By Netopeer Cli xranuser APoabio     ${Backdoor_cmd_apoabio}/${fault17_clr_xmlfilename}
    Log    LBM
    Perform Parameter Recommissioning    ${distLBM_name}    ${parameter_LBM}    ${value_true}
    Trigger_LBM
    Perform Parameter Recommissioning    ${distLBM_name}    ${parameter_LBM}    ${value_false}
    Log    EAC IN
    #####Make Sure Correct File is present in /backdoor/externalio path#####
    FOR    ${i}    IN RANGE    1    11
        Send Cmd By Netopeer Cli xranuser APoabio    ${Backdoor_eac_inF}
        Sleep    5s
        Send Cmd By Netopeer Cli xranuser APoabio    ${Backdoor_eac_inT}
        Sleep    5s
    END
    Log    EAC OUT
    FOR    ${i}    IN RANGE    1    11
        Perform Parameter Recommissioning    ${distEAC_name}    ${inuse}    ${value_false}
        Sleep    3s
        Perform Parameter Recommissioning    ${distEAC_name}    ${inuse}    ${value_true}
    END
    #####Make Sure Correct File is present in /backdoor/ald path #####
    Log    ALD Communications
    Send Cmd By Netopeer Cli xranuser APoabio    ${Backdoor_ald_err}
    Sleep    200s
    Reset Radio    ${distRU_name}
    Wait Until Keyword Succeeds     10m    10s    Check_BTS_State
    Send Cmd By Netopeer Cli xranuser APoabio    ${Backdoor_ald_prt}
    Sleep    60s
    Reset Radio    ${distRU_name}
    Wait Until Keyword Succeeds     10m    10s    Check_BTS_State
    Log    CHECK FRONTHAUL LOGS
    Netconf File Collection
    Run Keyword And Continue On Failure     MessageVerification_ald    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/${NetconfFileName}
    Run Keyword And Continue On Failure     MessageVerification_LBM    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/${NetconfFileName}
    Run Keyword And Continue On Failure     MessageVerification_eacIN    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/${NetconfFileName}
    Run Keyword And Continue On Failure     MessageVerification_eac_out    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/${NetconfFileName}
    Run Keyword And Continue On Failure     MessageVerification_alarm
	...    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/${NetconfFileName}    ${list_fault_4_2_17}
    Run Keyword And Continue On Failure     Authentication_check    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/${NetconfFileName}
    Run Keyword And Continue On Failure     MessageVerification_conf_subs_troubleshooting
    ...    	${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/${NetconfFileName}
    Run Keyword And Continue On Failure     MessageVerification_filter    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/${NetconfFileName}
    Run Keyword And Continue On Failure     MessageVerification_sup    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/${NetconfFileName}
    Run Keyword And Continue On Failure     MessageVerification_sudo    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/${NetconfFileName}
    #FILTER without filter APPLIED
    ${getWithoutFilerValue}=     snapshotFileIdentifier
    log     ${getWithoutFilerValue}

Software_Upgrade
    [Documentation]        O-RU Software Update and Install (positive case) - TEST CASE_ 3.1.6.1
	...                Software Activation without Reset - TEST CASE_3.1.7.1
	...                Supplemental Reset after Software Activation - TEST CASE_3.1.7.2
	[Tags]    TC2

    ORU Upgrade Reset
    Sleep    300s
    Print Radio Version
    ORU Upgrade Wo Reset
    Sleep    300s
    Print Radio Version
    Reset Radio    ${distRU_name}
    Print Radio Version
    Netconf File Collection
    Run Keyword And Continue On Failure     Software_Inventory    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/${NetconfFileName}
    Run Keyword And Continue On Failure     MessageVerification_software    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/${NetconfFileName}
    Run Keyword And Continue On Failure     MessageVerification_reset    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/${NetconfFileName}

Negative_Scenarios
    [Documentation]    EPE counters
	...    Transport negative
	...    	Mplane negative
	[Tags]    TC3

    Log     EPE counters
    Perform Parameter Recommissioning    ${distname_pmmnl}    ${miOranEpeStats_name}    ${windowStatsValue}
    Wait Until Keyword Succeeds     10m    10s    Check_BTS_State
    BuiltIn.Sleep    9m
    Run Keyword and Continue On Failure    Counter_Value_Check    ${miOranEpeStats_Counter}    @{miOranEpeStats_CounterList}
    Perform Parameter Recommissioning    ${distname_pmmnl}    ${miOranEpeStats_name}    ${windowStatsValue_disable}
    Wait Until Keyword Succeeds     10m    10s    Check_BTS_State
    Run Keyword And Continue On Failure
    ...    Netconf_MessageVerification_9196related_messages
    ...  	 ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/${NetconfFileName}    @{EPE_capabilities}
    Log    transport ipv4 negative
    Configure Netconf Credentials    @{sudo_list2}
    Run Keyword and Ignore Error     Reset Radio    ${distRU_name}
    Sleep    150s
    Get ActiveAlarms
    Configure Netconf Credentials    @{sudo_list1}
    Get ActiveAlarms
    Log    M-plane sup negative
    Perform Parameter Recommissioning    ${distsup_name}    ${admstate}     ${laneLocked}
    @{alarm_data}=    Get ActiveAlarms
    Log    ${alarm_data}
    Sleep    100s
    Perform Parameter Recommissioning    ${distsup_name}    ${admstate}     ${laneUnlocked}
    @{alarm_data}=    Get ActiveAlarms
    Log    ${alarm_data}
    Wait Until Keyword Succeeds     10m    10s    Check_BTS_State
    Netconf File Collection
    #Mplane sup negative
    Run Keyword And Continue On Failure     Authentication_check    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/${NetconfFileName}
    Run Keyword And Continue On Failure     MessageVerification_sup    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/${NetconfFileName}
    #IPV4 negative Transport
    Run Keyword And Continue On Failure     AuthenticationTransport_checkfailure
    ...    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/${NetconfFileName}

Negative_Scenarios_ipv6
    [Documentation]    ipv6 ssh positive
	...    ipv6 ssh negative
	[Tags]    TC4

    PerformRecommissioning     /home/ute/robotws/testsuite/Bangalore/ORAN/T02/resources/backupFiles/IPv6_SCF_APoABIO.xml
    Sleep    100s
    Configure Netconf Credentials    @{sudo_list1}
    Sleep    120s
    os.Run    chmod 777 /home/ute/robotws/testsuite/Bangalore/ORAN/T02/resources/robot/x2link.sh
    os.Run    sh /home/ute/robotws/testsuite/Bangalore/ORAN/T02/resources/robot/x2link.sh
    Wait Until Keyword Succeeds     10m    10s    Check_BTS_State
    Log    transport ipv6 negative
    Configure Netconf Credentials    @{sudo_list2}
    Run Keyword and Ignore Error     Reset Radio    ${distRU_name}
    Sleep    150s
    Get ActiveAlarms
    Configure Netconf Credentials    @{sudo_list1}
    Get ActiveAlarms
    Netconf File Collection
    # Negative Scenario
    Run Keyword And Continue On Failure     AuthenticationTransport_checkfailure
    ...    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/${NetconfFileName}
    # Positive Scenario
    Run Keyword And Continue On Failure     Authentication_check    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/${NetconfFileName}
    PerformRecommissioning     /home/ute/robotws/testsuite/Bangalore/ORAN/T02/resources/backupFiles/IPv4_SCF_APoABIO.xml
    Sleep    100s
    Configure Netconf Credentials    @{sudo_list1}
    Sleep    120s
    os.Run    chmod 777 /home/ute/robotws/testsuite/Bangalore/ORAN/T02/resources/robot/x2link.sh
    os.Run    sh /home/ute/robotws/testsuite/Bangalore/ORAN/T02/resources/robot/x2link.sh
    Wait Until Keyword Succeeds     10m    10s    Check_BTS_State

*** Keywords ***

PerformRecommissioning
    [Arguments]    ${scf_filepath}
    admin.perform_commissioning
    ...    scf_file=${scf_filepath}
    ...    should_activate=True
    ...    timeout=400
    ...    connection=default

Netconf File Collection
    Collect Snapshot
    Extract netconf from snapshot

snapshotFileIdentifier
    @{getWithoutFilerValue}=    snapshotFileIdentifier.snapshotGetWithoutFilter
    ...    filename=${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Snapshotfile.zip
    ...    path=${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}
    ...    fileToBeChecked=NetconfRpcMessageTrace
    RETURN    @{getWithoutFilerValue}

Extract netconf from snapshot
        @{getWithoutFilerValue}=     snapshotGetWithoutFilter    Snapshotfile.zip
        ...		${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/    RMOD_L-1_NetconfRpcMessageTrace
        log     ${getWithoutFilerValue}[0]
        log     ${getWithoutFilerValue}[1]
        log     ${getWithoutFilerValue}[2]
        ${netconf_file_path}=    String.Replace string    ${getWithoutFilerValue}[2]    ${TEST_NAME}//    ${TEST_NAME}/
        Extract
   	...    path=${netconf_file_path}
   	...    output_dir=${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/
   	...    .=*.log
        ${netconf_filename}=    os.List Files In Directory    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/    *_NetconfRpcMessageTrace.log
        os.Move file    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/*_NetconfRpcMessageTrace.log
    ...		${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/RMOD_L-1_NetconfRpcMessageTrace.log

Netconf_MessageVerification_9196related_messages
    [Arguments]    ${netconf_file}    @{message}
    ${pm}=    netconf_get_value     ${netconf_file}    rpc    edit-config    measurement-object
    FOR    ${i}    IN    @{message}
        ${Value to check}    Evaluate    '${i}' in [item[1] for item in ${pm}]
        run keyword and continue on failure   Should Be True    ${Value to check}
    END
    ${pm1}=    netconf_get_value    ${netconf_file}    rpc    edit-config    active
    ${len1}=    BuiltIn.Get Length    ${pm1}
    FOR    ${i}    IN    @{active}
        ${Value to check}    Evaluate    '${i}' in [item[1] for item in ${pm1}]
        run keyword and continue on failure   Should Be True    ${Value to check}
    END
    ${a}=    validate_netconf_reply_message    ${netconf_file}    edit-config    ok
    run keyword and continue on failure    Should not be empty    ${a}

Reset Radio
    [Arguments]    ${distname_radio}
    radio_reset_at_layer_1    dist_name=${distname_radio}
    ...                       reset_type=Soft
    ...                       timeout=300
    ...                       connection=${connection}
    ...                       detailed_output=False