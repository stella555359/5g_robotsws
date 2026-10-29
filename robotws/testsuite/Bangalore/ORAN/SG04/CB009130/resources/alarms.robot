*** Settings ***
Documentation
...    Author: adam.superczynski@nokia.com
...    Maintainer: mateusz.kowalczyk@nokia.com; adam.superczynski@nokia.com; marek.lenartowicz@nokia.com;
...    jakub.pawlowski@nokia.com
...    Test Description: Alarms keywords
...    Confluence link: link
...    Group in charge: I_MN_RAN_BOAM_PZ_OM_ET_1_GMS <I_MN_RAN_BOAM_PZ_OM_ET_1@internal.nsn.com>
...    References: -
...    QualityCenter: tds://ran_et.mn_ran.qc-prod.ext.net.nokia.com/qcbin/TestLabModule-000000003649890581?EntityType=ITestSet&EntityID=22375
...    Sample execution:-
...    AC/REQ:-

Library    BuiltIn
Library    Collections

Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/ORAN.robot
Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/admin.robot
Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/admin_infomodel.robot
Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/pretest_posttest.robot

*** Variables ***

&{1500_LTE}     fault_id=1500
...         alarm_id=7652
...         alarm_severity=Minor
...         fault_name="alarm1"
...         notifier=

&{1500_NR}     fault_id=1500
...         alarm_id=7240
...         alarm_severity=Minor
...         fault_name="alarm1"
...         notifier=

&{26_LTE}      fault_id=26
...         alarm_id=7652
...         alarm_severity=Minor
...         fault_name="Fault caused by source 1 affecting 3 objects"
...         notifier=

&{26_NR}     fault_id=26
...         alarm_id=7241
...         alarm_severity=Minor
...         fault_name="Fault caused by source 1 affecting 3 objects"
...         notifier=

&{27}        fault_id=27
...         alarm_id=7241
...         alarm_severity=Major
...         fault_name="Fault caused by source 1 affecting 3 objects"
...         notifier=

&{2909}     fault_id=2909
...         alarm_id=
...         alarm_severity=Major
...         fault_name="Unexpected C/U-plane message content fault"
...         notifier=

&{1936}     fault_id=1936
...         alarm_id=
...         alarm_severity=Minor
...         fault_name="Unit (module) temperature is high"
...         notifier=

&{1986}     fault_id=1986
...         alarm_id=
...         alarm_severity=Critical
...         fault_name="SFP on RF Module faulty or unsupported"
...         notifier=

&{2908}     fault_id=2908
...         alarm_id=
...         alarm_severity=Major
...         fault_name="Interface Fault"
...         notifier=

&{1900_autonomous}     fault_id=1900
...         alarm_id=
...         alarm_severity=Warning
...         fault_name="Radio autonomous reset as recovery action"
...         notifier=

&{1932}     fault_id=1932
...         alarm_id=
...         alarm_severity=Minor
...         fault_name="No module fan detected"
...         notifier=

&{2907}     fault_id=2907
...         alarm_id=
...         alarm_severity=Minor
...         fault_name="C/U-plane logical Connection faulty"
...         notifier=

&{2910}     fault_id=2910
...         alarm_id=
...         alarm_severity=Major
...         fault_name="Power Amplifier faulty"
...         notifier=

&{1806_allowed}     fault_id=1806
...         alarm_id=7101
...         alarm_severity=Warning
...         fault_name="Radio autonomous reset as recovery action"
...         notifier=

&{1900_allowed}     fault_id=1900
...         alarm_id=7116
...         alarm_severity=Critical
...         alarm_resource=[1] MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1
...         fault_name="RF Module configuring failed"
...         notifier=

&{9}     fault_id=9
...         alarm_id=7241
...         alarm_severity=Major
...         fault_name="Fault caused by source 1 affecting 3 objects"
...         notifier=

&{8}        fault_id=8
...         alarm_id=7241
...         alarm_severity=Major
...         fault_name="Fault caused by source 1 affecting 3 objects"
...         notifier=

&{7241}        fault_id=7241
...         alarm_id=7241
...         alarm_severity=Major
...         fault_name="Fault caused by source 1 affecting 3 objects"
...         notifier=

&{4720}     fault_id=4720
...         alarm_id=7115
...         alarm_severity=Minor
...         fault_name="Mismatch of RU reported capabilities with static HW Validation information"
...         notifier=

&{4003}     fault_id=4003
...         alarm_id=7115
...         alarm_severity=Major
...         fault_name="Tx Failure Turn Mimo Off"
...         notifier=

&{1840}     fault_id=1840
...         alarm_id=7100
...         alarm_severity=Major
...         fault_name="Configuration file corrupted"
...         notifier=

@{ALLOWED_ALARMS_TC12}    &{1500_LTE}    &{1500_NR}    &{2909}    &{26_LTE}     &{26_NR}    &{9}
@{ALLOWED_ALARMS_TC6}    &{1932}    &{1936}    &{1986}    &{2908}    &{1900_autonomous}
@{ALLOWED_ALARMS_TC7}    &{2907}    &{2909}    &{2910}		&{4720}		&{9}		#&{27}
@{ALLOWED_ALARMS_TC17}   &{1900_allowed}    &{1806_allowed}
@{ALLOWED_ALARMS_TC3}   &{4720}		&{7241}		&{8}

*** Keywords ***
Trigger Fault 1500 With Severity Minor
    Copy Xml And Send Cmd By Netopeer Cli    fm-test-1500.xml    ${XML_FILES_PATH}/alarm

Trigger Fault 26 With Severity Minor
    Copy Xml And Send Cmd By Netopeer Cli    fm-test-26.xml    ${XML_FILES_PATH}/alarm

Trigger Fault 31 With Severity Major
    Copy Xml And Send Cmd By Netopeer Cli    fm-test-31.xml    ${XML_FILES_PATH}/alarm


Trigger Fault 6 With Severity Minor
    Copy Xml And Send Cmd By Netopeer Cli    fm-test-6.xml    ${XML_FILES_PATH}/alarm

Trigger Fault 1 With Severity Minor
    Copy Xml And Send Cmd By Netopeer Cli    fm-test-1.xml    ${XML_FILES_PATH}/alarm

Trigger Fault 29 With Severity Critical
    Copy Xml And Send Cmd By Netopeer Cli    fm-test-29.xml    ${XML_FILES_PATH}/alarm

Trigger Fault 30 With Severity Major
    Copy Xml And Send Cmd By Netopeer Cli    fm-test-30.xml    ${XML_FILES_PATH}/alarm

Trigger Fault 11 With Severity Critical
    Copy Xml And Send Cmd By Netopeer Cli    fm-test-11.xml    ${XML_FILES_PATH}/alarm

Trigger Fault 28 With Severity Minor
    Copy Xml And Send Cmd By Netopeer Cli    fm-test-28.xml    ${XML_FILES_PATH}/alarm

Trigger Fault 8_mj With Severity Major
        Copy Xml And Send Cmd By Netopeer Cli    fm-test-1-alarm-fid_8_mj.xml   ${XML_FILES_PATH}/alarm

Trigger Fault 7_false With Severity Critical
	Copy Xml And Send Cmd By Netopeer Cli    fm-test-1-alarm-fid_1_false.xml   ${XML_FILES_PATH}/alarm

Trigger Fault 7 With Severity Critical
	Copy Xml And Send Cmd By Netopeer Cli    fm-test-1-alarm-fid_1.xml   ${XML_FILES_PATH}/alarm

Trigger Fault 7_WA With Severity Critical
	Copy Xml And Send Cmd By Netopeer Cli    fm-test-1-alarm-fid_1_wa.xml   ${XML_FILES_PATH}/alarm

Trigger Fault 7_mj With Severity Major
	Copy Xml And Send Cmd By Netopeer Cli    fm-test-1-alarm-fid_7_mj.xml   ${XML_FILES_PATH}/alarm

Trigger Fault 7_mn With Severity Minor
	Copy Xml And Send Cmd By Netopeer Cli    fm-test-1-alarm-fid_7_mn.xml   ${XML_FILES_PATH}/alarm

Trigger Fault 7_cr With Severity Critical
	Copy Xml And Send Cmd By Netopeer Cli    fm-test-1-alarm-fid_7_cr.xml   ${XML_FILES_PATH}/alarm

Trigger Fault 7_wr With Severity Warning
	Copy Xml And Send Cmd By Netopeer Cli    fm-test-1-alarm-fid_7_wr.xml   ${XML_FILES_PATH}/alarm

Trigger Fault 1000_WA With Severity Major
	Copy Xml And Send Cmd By Netopeer Cli    fm-test-1-alarm-fid_1000_wa.xml   ${XML_FILES_PATH}/alarm

Trigger Fault 9 With Severity Major
	Copy Xml And Send Cmd By Netopeer Cli    fm-test-1-alarm-fid_9.xml   ${XML_FILES_PATH}/alarm

Trigger Fault 14 With Severity Major
	Copy Xml And Send Cmd By Netopeer Cli    fm-test-1-alarm-fid_14.xml   ${XML_FILES_PATH}/alarm

Trigger Fault 9_false With Severity Major
	Copy Xml And Send Cmd By Netopeer Cli    fm-test-1-alarm-fid_9_false.xml   ${XML_FILES_PATH}/alarm

Trigger Fault 14_false With Severity Major
	Copy Xml And Send Cmd By Netopeer Cli    fm-test-1-alarm-fid_14_false.xml   ${XML_FILES_PATH}/alarm

Trigger Fault 19 With Severity Critical
	Copy Xml And Send Cmd By Netopeer Cli    fm-test-1-alarm-fid_19.xml   ${XML_FILES_PATH}/alarm

Trigger Fault 20_mj With Severity Major
	Copy Xml And Send Cmd By Netopeer Cli    fm-test-1-alarm-fid_20_mj.xml   ${XML_FILES_PATH}/alarm

Trigger Fault 19_mj With Severity Major
	Copy Xml And Send Cmd By Netopeer Cli    fm-test-1-alarm-fid_19_mj.xml   ${XML_FILES_PATH}/alarm

Trigger Fault 27 With Severity Major
	Copy Xml And Send Cmd By Netopeer Cli    fm-test-1-alarm-fid_27.xml   ${XML_FILES_PATH}/alarm

Trigger Fault 27_false With Severity Major
	Copy Xml And Send Cmd By Netopeer Cli    fm-test-1-alarm-fid_27_false.xml   ${XML_FILES_PATH}/alarm

Trigger Fault 27_xx:1 With Severity Major
	Copy Xml And Send Cmd By Netopeer Cli    fm-test-1-alarm-fid_27_xx_1.xml   ${XML_FILES_PATH}/alarm

Trigger Fault 27_2:33 With Severity Major
	Copy Xml And Send Cmd By Netopeer Cli    fm-test-1-alarm-fid_27_2_33.xml   ${XML_FILES_PATH}/alarm

Assert Fault 31
    taf.sbts.oam.coam.admin.Assert Alarm Active    faultName=regex"Unexpected C/U-plane message content fault", faultId=2909, severity=Major
    ...    alias=${ADMIN_ALIAS}
    ${object_dict}    taf.sbts.oam.coam.admin.Get Parameters
    ...    ${BTS_L_PATH}/EQM_L-1/RMOD_L-1/RU_L-1/TX_PU_L-1/TX_L-8
    ...    alias=${ADMIN_ALIAS}
    ${object_str}    Convert To String    ${object_dict}
    Should Contain    ${object_str}    'operationalState': 'Enabled'
    Should Contain    ${object_str}    'availabilityStatus': 'Degraded'
    Should Contain    ${object_str}    'reasoningStatus': ['RfUnexpectedCuPlaneMessageContentMajor']
    ${message}    Check Message In Logs On Oru    notification.*fault-id\>31.*\<is-cleared\>false\<
    Should Contain     ${message}    fault-id>31

Assert Fault 4278
	taf.sbts.oam.coam.admin.Assert Alarm Active    faultId=4278		severity=Minor
    ...    alias=${ADMIN_ALIAS}
	${message}    Check Message In Logs On Oru    notification.*fault-id\>4278.*\<is-cleared\>false\<
    Should Contain     ${message}    fault-id>4278

Assert Inactive Fault 4278
	taf.sbts.oam.coam.admin.Assert Alarm Inactive	faultId=4278	severity=Minor
	...    alias=${ADMIN_ALIAS}
	${message}    Check Message In Logs On Oru    notification.*fault-id\>4278.*\<is-cleared\>true\<
    Should Contain     ${message}    fault-id>4278


Assert Fault 26 LTE
    taf.sbts.oam.coam.admin.Assert Alarm Active    alarmName=regex"BASE STATION NOTIFICATION", faultId=26, severity=Minor, alarmId=7652
    ...    alias=${ADMIN_ALIAS}
    ${message}    Check Message In Logs On Oru    notification.*fault-id\>26.*\<is-cleared\>false\<
    Should Contain     ${message}    fault-id>26

Assert Fault 26 NR
    taf.sbts.oam.coam.admin.Assert Alarm Active    alarmName=regex"ORAN RU EXTERNAL PROBLEM", faultId=26, severity=Minor, alarmId=7241
    ...    alias=${ADMIN_ALIAS}
    ${message}    Check Message In Logs On Oru    notification.*fault-id\>26.*\<is-cleared\>false\<
    Should Contain     ${message}    fault-id>26

Assert Fault 6
    taf.sbts.oam.coam.admin.Assert Alarm Active    faultName=regex"No module fan detected", faultId=1932, severity=Minor    alias=${ADMIN_ALIAS}
    ${message}    Check Message In Logs On Oru    notification.*fault-id\>6.*\<is-cleared\>false\<
    Should Contain     ${message}    fault-id>6

Assert Fault 1
    taf.sbts.oam.coam.admin.Assert Alarm Active    faultName=regex"Unit \\(module\\) temperature is high", faultId=1936, severity=Minor
    ...    alias=${ADMIN_ALIAS}
    ${message}    Check Message In Logs On Oru    notification.*fault-id\>1.*\<is-cleared\>false\<
    Should Contain     ${message}    fault-id>1

Assert Fault 29
    taf.sbts.oam.coam.admin.Assert Alarm Active    faultName=regex"SFP on RF Module faulty or unsupported", faultId=1986, severity=Critical
    ...    alias=${ADMIN_ALIAS}
    ${message}    Check Message In Logs On Oru    notification.*fault-id\>29.*\<is-cleared\>false\<
    Should Contain     ${message}    fault-id>29

Assert Fault 30
    taf.sbts.oam.coam.admin.Assert Alarm Active    faultName=regex"Interface Fault", faultId=2908, severity=Major    alias=${ADMIN_ALIAS}
    ${message}    Check Message In Logs On Oru    notification.*fault-id\>30.*\<is-cleared\>false\<
    Should Contain     ${message}    fault-id>30

Assert Fault 11
    ${passed}=    Run Keyword And Return Status    taf.sbts.oam.coam.admin.Assert Alarm Active
    ...    faultName=regex"Radio autonomous reset as recovery action", faultId=1900, severity=Warning
    ...    alias=${ADMIN_ALIAS}
    Run Keyword If    '${passed}' == 'False'    Assert Historical Fault 11
    ${message}    Check Message In Logs On Oru    notification.*fault-id\>11.*\<is-cleared\>false\<
    Should Contain     ${message}    fault-id>11

Assert Fault 28
    taf.sbts.oam.coam.admin.Assert Alarm Active    faultName=regex"C/U-plane logical Connection faulty", faultId=2907, severity=Minor
    ...    alias=${ADMIN_ALIAS}
    ${message}    Check Message In Logs On Oru    notification.*fault-id\>28.*\<is-cleared\>false\<
    Should Contain     ${message}    fault-id>28


Assert Historical Fault 11
    ${historic_alarms}    Get Historic Alarms    severity=Warning    alias=${ADMIN_ALIAS}
    ${fault_exists}    Set Variable    ${False}
    FOR    ${alarm}     IN      @{historic_alarms}
        ${fault_exists}    Set Variable    ${False}
        ${alarm_str}    Convert To String    ${alarm}
        ${fault_exists}    Run Keyword And Return Status    Should Contain    ${alarm_str}     u'faultId': 1900
        Continue For Loop If    ${fault_exists}==${False}
        ${fault_exists}    Run Keyword And Return Status    Should Contain
                            ...    ${alarm_str}
                            ...    u'faultName': u'Radio autonomous reset as recovery action'
        Continue For Loop If    ${fault_exists}==${False}
        ${fault_exists}    Run Keyword And Return Status    Should Contain    ${alarm_str}     u'severity': u'Warning'
        Exit For Loop If    ${fault_exists}==${True}
    END
    Run Keyword If    ${fault_exists}==${False}    Fail    Fault 11 does not exist

Assert Fault 1806
    ${passed}=    Run Keyword And Return Status    taf.sbts.oam.coam.admin.Assert Alarm Active
    ...    faultName=regex"Radio autonomous reset as recovery action", faultId=1806, severity=Warning, alarmId=7101
    ...    timeout=360
    ...    alias=${ADMIN_ALIAS}
    Run Keyword If    '${passed}' == 'False'    Assert Historical Fault 1806

Assert Historical Fault 1806
    ${historic_alarms}    Get Historic Alarms    severity=Warning    alias=${ADMIN_ALIAS}
    ${fault_exists}    Set Variable    ${False}
    FOR    ${alarm}     IN      @{historic_alarms}
        ${fault_exists}    Set Variable    ${False}
        ${alarm_str}    Convert To String    ${alarm}
        ${fault_exists}    Run Keyword And Return Status    Should Contain    ${alarm_str}     u'faultId': 1806
        Continue For Loop If    ${fault_exists}==${False}
        ${fault_exists}    Run Keyword And Return Status    Should Contain
                           ...    ${alarm_str}
                           ...    u'faultName': u'Radio autonomous reset as recovery action'
        Continue For Loop If    ${fault_exists}==${False}
        ${fault_exists}    Run Keyword And Return Status    Should Contain    ${alarm_str}     u'severity': u'Warning'
        Exit For Loop If    ${fault_exists}==${True}
    END
    Run Keyword If    ${fault_exists}==${False}    Fail    Fault 1806 does not exist

Assert Fault 1500 LTE
    taf.sbts.oam.coam.admin.Assert Alarm Active
    ...    alarmName=regex"BASE STATION NOTIFICATION", faultId=1500, severity=Minor, alarmId=7652
    ...    alias=${ADMIN_ALIAS}
    ${object_dict}    taf.sbts.oam.coam.admin.Get Parameters
    ...    ${BTS_L_PATH}/EQM_L-1/RMOD_L-1/RU_L-1/ORUF_L-1
    ...    alias=${ADMIN_ALIAS}
    ${object_str}    Convert To String    ${object_dict}
    Should Contain    ${object_str}    'faultId': 1500
    Should Contain    ${object_str}    'faultType': 'VendorSpecific'
    Should Contain    ${object_str}    'faultSeverity': 'Minor'
    Assert Fault 1500 Does Not Contain Meaning And Instruction LTE
    ${message}    Check Message In Logs On Oru    <active-alarms.*<fault-id>1500.*\<is-cleared>false<
    Should Contain     ${message}    1500

Assert Fault 1500 NRL
    taf.sbts.oam.coam.admin.Assert Alarm Active
    ...    alarmName=regex"ORAN RU VENDOR SPECIFIC INFORMATION", faultId=1500, severity=Minor, alarmId=7240
    ...    alias=${ADMIN_ALIAS}
    ${object_dict}    taf.sbts.oam.coam.admin.Get Parameters
    ...    ${BTS_L_PATH}/EQM_L-1/RMOD_L-1/RU_L-1/ORUF_L-1
    ...    alias=${ADMIN_ALIAS}
    ${object_str}    Convert To String    ${object_dict}
    Should Contain    ${object_str}    'faultId': 1500
    Should Contain    ${object_str}    'faultType': 'VendorSpecific'
    Should Contain    ${object_str}    'faultSeverity': 'Minor'
    Assert Fault 1500 Does Not Contain Meaning And Instruction NR
    ${message}    Check Message In Logs On Oru    <active-alarms.*<fault-id>1500.*\<is-cleared>false<
    Should Contain     ${message}    1500

Assert Fault 1000_WA
    taf.sbts.oam.coam.admin.Assert Alarm Active    faultName=regex"Fault caused by source 1 affecting 3 objects", faultId=1000, severity=Major
    ...    alias=${ADMIN_ALIAS}
    #${message}    Check Message In Logs On Oru    notification.*fault-id\>7.*\<is-cleared\>false\<
    #Should Contain     ${message}


Assert Fault 1000_WA Inactive
    taf.sbts.oam.coam.admin.Assert Alarm Inactive    faultName=regex"Fault caused by source 1 affecting 3 objects", faultId=1000, severity=Major
	...    alias=${ADMIN_ALIAS}
    #${message}    Check Message In Logs On Oru    notification.*fault-id\>7.*\<is-cleared\>true\<
    #Should Contain     ${message}    fault-id>7

Assert Fault 7_WA
    taf.sbts.oam.coam.admin.Assert Alarm Active    faultName=regex"Fault caused by source 1 affecting 3 objects", faultId=7, severity=Critical
    ...    alias=${ADMIN_ALIAS}
    #${message}    Check Message In Logs On Oru    notification.*fault-id\>7.*\<is-cleared\>false\<
    #Should Contain     ${message}

Assert Fault 7_WA Inactive
    taf.sbts.oam.coam.admin.Assert Alarm Inactive    faultName=regex"Fault caused by source 1 affecting 3 objects", faultId=7, severity=Critical
    ...    alias=${ADMIN_ALIAS}
    #${message}    Check Message In Logs On Oru    notification.*fault-id\>7.*\<is-cleared\>true\<
    #Should Contain     ${message}    fault-id>7

Assert Fault 7
    taf.sbts.oam.coam.admin.Assert Alarm Active    faultName=regex"Filter tuning failure", faultId=1840, severity=Critical    alias=${ADMIN_ALIAS}
    #${message}    Check Message In Logs On Oru    notification.*fault-id\>7.*\<is-cleared\>false\<
    #Should Contain     ${message}

Assert Fault 7 Inactive
    taf.sbts.oam.coam.admin.Assert Alarm Inactive    faultName=regex"Filter tuning failure", faultId=1840, severity=Critical    alias=${ADMIN_ALIAS}
    #${message}    Check Message In Logs On Oru    notification.*fault-id\>7.*\<is-cleared\>true\<
    #Should Contain     ${message}    fault-id>7

Assert Fault 8_mj
    taf.sbts.oam.coam.admin.Assert Alarm Active    faultName=regex"Fault caused by source 1 affecting 3 objects", faultId=8, severity=Major
    ...    alias=${ADMIN_ALIAS}
    #${message}    Check Message In Logs On Oru    notification.*fault-id\>7.*\<is-cleared\>false\<
    #Should Contain     ${message}

Assert Fault 8_mj Inactive
    taf.sbts.oam.coam.admin.Assert Alarm Inactive    faultName=regex"Fault caused by source 1 affecting 3 objects", faultId=8, severity=Major
    ...    alias=${ADMIN_ALIAS}
    #${message}    Check Message In Logs On Oru    notification.*fault-id\>7.*\<is-cleared\>true\<
    #Should Contain     ${message}    fault-id>7

Assert Fault 7_false
    taf.sbts.oam.coam.admin.Assert Alarm Active    faultName=regex"Fault caused by source 1 affecting 3 objects", faultId=7, severity=Critical
    ...    alias=${ADMIN_ALIAS}
    #${message}    Check Message In Logs On Oru    notification.*fault-id\>7.*\<is-cleared\>false\<
    #Should Contain     ${message}

Assert Fault 7 Inactive_false
    taf.sbts.oam.coam.admin.Assert Alarm Inactive    faultName=regex"Fault caused by source 1 affecting 3 objects", faultId=7, severity=Critical
    ...    alias=${ADMIN_ALIAS}
    #${message}    Check Message In Logs On Oru    notification.*fault-id\>7.*\<is-cleared\>true\<
    #Should Contain     ${message}    fault-id>7

Assert Fault 7_mj
    taf.sbts.oam.coam.admin.Assert Alarm Active    faultName=regex"Fault caused by source 1 affecting 3 objects", faultId=7, severity=Major
    ...    alias=${ADMIN_ALIAS}
    #${message}    Check Message In Logs On Oru    notification.*fault-id\>7.*\<is-cleared\>false\<
    #Should Contain     ${message}


Assert Fault 7 Inactive_mj
    taf.sbts.oam.coam.admin.Assert Alarm Inactive    faultName=regex"Fault caused by source 1 affecting 3 objects", faultId=7, severity=Major
    ...    alias=${ADMIN_ALIAS}
    #${message}    Check Message In Logs On Oru    notification.*fault-id\>7.*\<is-cleared\>true\<
    #Should Contain     ${message}    fault-id>7

Assert Fault 7_mn
    taf.sbts.oam.coam.admin.Assert Alarm Active    faultName=regex"Fault caused by source 1 affecting 3 objects", faultId=7, severity=Minor
    ...    alias=${ADMIN_ALIAS}
    #${message}    Check Message In Logs On Oru    notification.*fault-id\>7.*\<is-cleared\>false\<
    #Should Contain     ${message}


Assert Fault 7 Inactive_mn
    taf.sbts.oam.coam.admin.Assert Alarm Inactive    faultName=regex"Fault caused by source 1 affecting 3 objects", faultId=7, severity=Minor
    ...    alias=${ADMIN_ALIAS}
    #${message}    Check Message In Logs On Oru    notification.*fault-id\>7.*\<is-cleared\>true\<
    #Should Contain     ${message}    fault-id>7

Assert Fault 7_cr
    taf.sbts.oam.coam.admin.Assert Alarm Active    faultName=regex"Fault caused by source 1 affecting 3 objects", faultId=7, severity=Critical
    ...    alias=${ADMIN_ALIAS}
    #${message}    Check Message In Logs On Oru    notification.*fault-id\>7.*\<is-cleared\>false\<
    #Should Contain     ${message}


Assert Fault 7 Inactive_cr
    taf.sbts.oam.coam.admin.Assert Alarm Inactive    faultName=regex"Fault caused by source 1 affecting 3 objects", faultId=7, severity=Critical
    ...    alias=${ADMIN_ALIAS}
    #${message}    Check Message In Logs On Oru    notification.*fault-id\>7.*\<is-cleared\>true\<
    #Should Contain     ${message}    fault-id>7

Assert Fault 7_wr
    taf.sbts.oam.coam.admin.Assert Alarm Active    faultName=regex"Fault caused by source 1 affecting 3 objects", faultId=7, severity=Warning
    ...    alias=${ADMIN_ALIAS}
    #${message}    Check Message In Logs On Oru    notification.*fault-id\>7.*\<is-cleared\>false\<
    #Should Contain     ${message}


Assert Fault 7 Inactive_wr
    taf.sbts.oam.coam.admin.Assert Alarm Inactive    faultName=regex"Fault caused by source 1 affecting 3 objects", faultId=7241, severity=Warning
    ...    alias=${ADMIN_ALIAS}
    #${message}    Check Message In Logs On Oru    notification.*fault-id\>7.*\<is-cleared\>true\<
    #Should Contain     ${message}    fault-id>7


Assert Fault 9
    taf.sbts.oam.coam.admin.Assert Alarm Active    faultName=regex"Transmission quality deteriorated", faultId=1921, severity=Major
    ...    alias=${ADMIN_ALIAS}
    #${message}    Check Message In Logs On Oru    notification.*fault-id\>9.*\<is-cleared\>false\<
    #Should Contain     ${message}    7


Assert Fault 9 Inactive
    taf.sbts.oam.coam.admin.Assert Alarm Inactive    faultName=regex"Transmission quality deteriorated", faultId=1921, severity=Major
    ...    alias=${ADMIN_ALIAS}
    #${message}    Check Message In Logs On Oru    notification.*fault-id\>9.*\<is-cleared\>true\<
    #Should Contain     ${message}    fault-id>7


Assert Fault 14
    taf.sbts.oam.coam.admin.Assert Alarm Active    faultName=regex"Configuration file corrupted", faultId=1924, severity=Major
    ...    alias=${ADMIN_ALIAS}
    #${message}    Check Message In Logs On Oru    notification.*fault-id\>9.*\<is-cleared\>false\<
    #Should Contain     ${message}    7

Assert Fault 14 Inactive
    taf.sbts.oam.coam.admin.Assert Alarm Inactive    faultName=regex"Configuration file corrupted", faultId=1924, severity=Major
    ...    alias=${ADMIN_ALIAS}
    #${message}    Check Message In Logs On Oru    notification.*fault-id\>9.*\<is-cleared\>true\<
    #Should Contain     ${message}    fault-id>7

Assert Fault 9_false
    taf.sbts.oam.coam.admin.Assert Alarm Active    faultName=regex"Fault caused by source 1 affecting 3 objects", faultId=9, severity=Major
    ...    alias=${ADMIN_ALIAS}
    #${message}    Check Message In Logs On Oru    notification.*fault-id\>9.*\<is-cleared\>false\<
    #Should Contain     ${message}    7


Assert Fault 9 Inactive_false
    taf.sbts.oam.coam.admin.Assert Alarm Inactive    faultName=regex"Fault caused by source 1 affecting 3 objects", faultId=9, severity=Major
    ...    alias=${ADMIN_ALIAS}
    #${message}    Check Message In Logs On Oru    notification.*fault-id\>9.*\<is-cleared\>true\<
    #Should Contain     ${message}    fault-id>7

Assert Fault 14_false
    taf.sbts.oam.coam.admin.Assert Alarm Active    faultName=regex"Fault caused by source 1 affecting 3 objects", faultId=14, severity=Major
    ...    alias=${ADMIN_ALIAS}
    #${message}    Check Message In Logs On Oru    notification.*fault-id\>9.*\<is-cleared\>false\<
    #Should Contain     ${message}    7

Assert Fault 14 Inactive_false
    taf.sbts.oam.coam.admin.Assert Alarm Inactive    faultName=regex"Fault caused by source 1 affecting 3 objects", faultId=14, severity=Major
    ...    alias=${ADMIN_ALIAS}
    #${message}    Check Message In Logs On Oru    notification.*fault-id\>9.*\<is-cleared\>true\<
    #Should Contain     ${message}    fault-id>7

Assert Fault 19
    taf.sbts.oam.coam.admin.Assert Alarm Active      faultName=regex"TX out of order", faultId=1907, severity=Critical    alias=${ADMIN_ALIAS}
    #${message}    Check Message In Logs On Oru    notification.*fault-id\>9.*\<is-cleared\>false\<
    #Should Contain     ${message}    7

Assert Fault 19 Inactive
    taf.sbts.oam.coam.admin.Assert Alarm Inactive    faultName=regex"TX out of order", faultId=1907, severity=Critical    alias=${ADMIN_ALIAS}
    #${message}    Check Message In Logs On Oru    notification.*fault-id\>9.*\<is-cleared\>true\<
    #Should Contain     ${message}    fault-id>7

Assert Fault 20
    taf.sbts.oam.coam.admin.Assert Alarm Active      faultName=regex"Fault caused by source 1 affecting 3 objects", faultId=20, severity=Major
    ...    alias=${ADMIN_ALIAS}
    #${message}    Check Message In Logs On Oru    notification.*fault-id\>9.*\<is-cleared\>false\<
    #Should Contain     ${message}    7

Assert Fault 20 Inactive
    taf.sbts.oam.coam.admin.Assert Alarm Inactive    faultName=regex"Fault caused by source 1 affecting 3 objects", faultId=20, severity=Major
    ...    alias=${ADMIN_ALIAS}
    #${message}    Check Message In Logs On Oru    notification.*fault-id\>9.*\<is-cleared\>true\<
    #Should Contain     ${message}    fault-id>7

Assert Fault 19_mj
    taf.sbts.oam.coam.admin.Assert Alarm Active      faultName=regex"Fault caused by source 1 affecting 3 objects", faultId=19, severity=Major
    ...    alias=${ADMIN_ALIAS}
    #${message}    Check Message In Logs On Oru    notification.*fault-id\>9.*\<is-cleared\>false\<
    #Should Contain     ${message}    7

Assert Fault 19 Inactive_mj
    taf.sbts.oam.coam.admin.Assert Alarm Inactive    faultName=regex"Fault caused by source 1 affecting 3 objects", faultId=19, severity=Major
    ...    alias=${ADMIN_ALIAS}
    #${message}    Check Message In Logs On Oru    notification.*fault-id\>9.*\<is-cleared\>true\<
    #Should Contain     ${message}    fault-id>7

Assert Fault 20_mj
    taf.sbts.oam.coam.admin.Assert Alarm Active      faultName=regex"Fault caused by source 1 affecting 3 objects", faultId=20, severity=Major
    ...    alias=${ADMIN_ALIAS}
    #${message}    Check Message In Logs On Oru    notification.*fault-id\>9.*\<is-cleared\>false\<
    #Should Contain     ${message}    7

Assert Fault 20 Inactive_mj
    taf.sbts.oam.coam.admin.Assert Alarm Inactive    faultName=regex"Fault caused by source 1 affecting 3 objects", faultId=20, severity=Major
    ...    alias=${ADMIN_ALIAS}
    #${message}    Check Message In Logs On Oru    notification.*fault-id\>9.*\<is-cleared\>true\<
    #Should Contain     ${message}    fault-id>7

Assert Fault 27
    taf.sbts.oam.coam.admin.Assert Alarm Active      faultName=regex"Power Amplifier faulty", faultId=2910, severity=Major    alias=${ADMIN_ALIAS}
    #${message}    Check Message In Logs On Oru    notification.*fault-id\>9.*\<is-cleared\>false\<
    #Should Contain     ${message}    7

Assert Fault 27 Inactive
    taf.sbts.oam.coam.admin.Assert Alarm Inactive    faultName=regex"Power Amplifier faulty", faultId=2910, severity=Major    alias=${ADMIN_ALIAS}
    #${message}    Check Message In Logs On Oru    notification.*fault-id\>9.*\<is-cleared\>true\<
    #Should Contain     ${message}    fault-id>7

Assert Fault 27_false
    taf.sbts.oam.coam.admin.Assert Alarm Active      faultName=regex"Fault caused by source 1 affecting 3 objects", faultId=27, severity=Major
    ...    alias=${ADMIN_ALIAS}
    #${message}    Check Message In Logs On Oru    notification.*fault-id\>9.*\<is-cleared\>false\<
    #Should Contain     ${message}    7

Assert Fault 27 Inactive_false
    taf.sbts.oam.coam.admin.Assert Alarm Inactive    faultName=regex"Fault caused by source 1 affecting 3 objects", faultId=27, severity=Major
    ...    alias=${ADMIN_ALIAS}
    #${message}    Check Message In Logs On Oru    notification.*fault-id\>9.*\<is-cleared\>true\<
    #Should Contain     ${message}    fault-id>7

Assert Fault 27_xx:1
    taf.sbts.oam.coam.admin.Assert Alarm Active      faultName=regex"Fault caused by source 1 affecting 3 objects"", faultId=27, severity=Major
    ...    alias=${ADMIN_ALIAS}
    #${message}    Check Message In Logs On Oru    notification.*fault-id\>9.*\<is-cleared\>false\<
    #Should Contain     ${message}    7

Assert Fault 27 Inactive_xx:1
    taf.sbts.oam.coam.admin.Assert Alarm Inactive    faultName=regex"Fault caused by source 1 affecting 3 objects", faultId=27, severity=Major
    ...    alias=${ADMIN_ALIAS}
    #${message}    Check Message In Logs On Oru    notification.*fault-id\>9.*\<is-cleared\>true\<
    #Should Contain     ${message}    fault-id>7

Assert Fault 27_2:33
    taf.sbts.oam.coam.admin.Assert Alarm Active      faultName=regex"Fault caused by source 1 affecting 3 objects", faultId=27, severity=Major
    ...    alias=${ADMIN_ALIAS}
    #${message}    Check Message In Logs On Oru    notification.*fault-id\>9.*\<is-cleared\>false\<
    #Should Contain     ${message}    7

Assert Fault 27 Inactive_2:33
    taf.sbts.oam.coam.admin.Assert Alarm Inactive    faultName=regex"Fault caused by source 1 affecting 3 objects", faultId=27, severity=Major
    ...    alias=${ADMIN_ALIAS}
    #${message}    Check Message In Logs On Oru    notification.*fault-id\>9.*\<is-cleared\>true\<
    #Should Contain     ${message}    fault-id>7

Clear Fault 26
    Copy Xml And Send Cmd By Netopeer Cli    fm-test-26-clearing.xml    ${XML_FILES_PATH}/alarm

Clear Fault 31
    Copy Xml And Send Cmd By Netopeer Cli    fm-test-31-clearing.xml    ${XML_FILES_PATH}/alarm

Clear Fault 1500
    Copy Xml And Send Cmd By Netopeer Cli    fm-test-1500-clearing.xml    ${XML_FILES_PATH}/alarm

Clear Fault 9
    Copy Xml And Send Cmd By Netopeer Cli    fm-test-1-alarm-fid_9-clearing.xml     ${XML_FILES_PATH}/alarm

Clear Fault 7
    Copy Xml And Send Cmd By Netopeer Cli    fm-test-1-alarm-fid_1-clearing.xml    ${XML_FILES_PATH}/alarm

Clear Fault 8_mj
    Copy Xml And Send Cmd By Netopeer Cli    fm-test-1-alarm-fid_8_mj-clearing.xml    ${XML_FILES_PATH}/alarm

Clear Fault 7_false
    Copy Xml And Send Cmd By Netopeer Cli    fm-test-1-alarm-fid_1-clearing_false.xml    ${XML_FILES_PATH}/alarm

Clear Fault 7_WA
    Copy Xml And Send Cmd By Netopeer Cli    fm-test-1-alarm-fid_1_wa-clearing.xml    ${XML_FILES_PATH}/alarm

Clear Fault 7_mj
    Copy Xml And Send Cmd By Netopeer Cli    fm-test-1-alarm-fid_7_mj-clearing.xml    ${XML_FILES_PATH}/alarm

Clear Fault 7_mn
    Copy Xml And Send Cmd By Netopeer Cli    fm-test-1-alarm-fid_7_mn-clearing.xml    ${XML_FILES_PATH}/alarm

Clear Fault 7_cr
    Copy Xml And Send Cmd By Netopeer Cli    fm-test-1-alarm-fid_7_cr-clearing.xml    ${XML_FILES_PATH}/alarm

Clear Fault 7_wr
    Copy Xml And Send Cmd By Netopeer Cli    fm-test-1-alarm-fid_7_wr-clearing.xml    ${XML_FILES_PATH}/alarm

Clear Fault 1000_WA
    Copy Xml And Send Cmd By Netopeer Cli    fm-test-1-alarm-fid_1000_wa-clearing.xml    ${XML_FILES_PATH}/alarm

Clear Fault 14
    Copy Xml And Send Cmd By Netopeer Cli    fm-test-1-alarm-fid_14-clearing.xml    ${XML_FILES_PATH}/alarm

Clear Fault 19
    Copy Xml And Send Cmd By Netopeer Cli    fm-test-1-alarm-fid_19-clearing.xml    ${XML_FILES_PATH}/alarm

Clear Fault 9_false
    Copy Xml And Send Cmd By Netopeer Cli    fm-test-1-alarm-fid_9-clearing_false.xml    ${XML_FILES_PATH}/alarm

Clear Fault 14_false
    Copy Xml And Send Cmd By Netopeer Cli    fm-test-1-alarm-fid_14-clearing_false.xml    ${XML_FILES_PATH}/alarm

Clear Fault 19_false
    Copy Xml And Send Cmd By Netopeer Cli    fm-test-1-alarm-fid_19-clearing_false.xml    ${XML_FILES_PATH}/alarm

Clear Fault 27_false
    Copy Xml And Send Cmd By Netopeer Cli    fm-test-1-alarm-fid_27-clearing_false.xml    ${XML_FILES_PATH}/alarm

Clear Fault 28
    Copy Xml And Send Cmd By Netopeer Cli    fm-test-28-clearing.xml    ${XML_FILES_PATH}/alarm

Clear Fault 19_mj
    Copy Xml And Send Cmd By Netopeer Cli    fm-test-1-alarm-fid_19_mj-clearing.xml    ${XML_FILES_PATH}/alarm

Clear Fault 20_mj
    Copy Xml And Send Cmd By Netopeer Cli    fm-test-1-alarm-fid_20_mj-clearing.xml    ${XML_FILES_PATH}/alarm

Clear Fault 20
    Copy Xml And Send Cmd By Netopeer Cli    fm-test-1-alarm-fid_20-clearing.xml    ${XML_FILES_PATH}/alarm

Clear Fault 27
    Copy Xml And Send Cmd By Netopeer Cli    fm-test-1-alarm-fid_27-clearing.xml    ${XML_FILES_PATH}/alarm

Clear Fault 27_2:33
    Copy Xml And Send Cmd By Netopeer Cli    fm-test-1-alarm-fid_27_2_33-clearing.xml    ${XML_FILES_PATH}/alarm

Clear Fault 27_xx:1
    Copy Xml And Send Cmd By Netopeer Cli    fm-test-1-alarm-fid_27_xx_1-clearing.xml    ${XML_FILES_PATH}/alarm

Assert Inactive Fault 26 LTE
    taf.sbts.oam.coam.admin.Assert Alarm Inactive
	...		alarmName=regex"BASE STATION NOTIFICATION", faultId=26, severity=Minor, alarmId=7652
    ...    alias=${ADMIN_ALIAS}
    ${clearing_message}    Check Message In Logs On Oru     notification.*fault-id\>26.*\<is-cleared\>true\<
    Should Contain     ${clearing_message}    fault-id>26

Assert Inactive Fault 26 NR
    taf.sbts.oam.coam.admin.Assert Alarm Inactive    alarmName=regex"ORAN RU EXTERNAL PROBLEM", faultId=26, severity=Minor, alarmId=7241
    ...    alias=${ADMIN_ALIAS}
    ${clearing_message}    Check Message In Logs On Oru     notification.*fault-id\>26.*\<is-cleared\>true\<
    Should Contain     ${clearing_message}    fault-id>26

Assert Inactive Fault 1500 LTE
    taf.sbts.oam.coam.admin.Assert Alarm Inactive
    ...    alarmName=regex"BASE STATION NOTIFICATION", faultId=1500, severity=Minor, alarmId=7652
    ...    alias=${ADMIN_ALIAS}
    ${clearing_message}    Check Message In Logs On Oru     notification.*fault-id\>1500.*\<is-cleared\>true\<
    Should Contain     ${clearing_message}    fault-id>1500

Assert Inactive Fault 1500 NR
    taf.sbts.oam.coam.admin.Assert Alarm Inactive
    ...    alarmName=regex"ORAN RU VENDOR SPECIFIC INFORMATION", faultId=1500, severity=Minor, alarmId=7240
    ...    alias=${ADMIN_ALIAS}
    ${clearing_message}    Check Message In Logs On Oru     notification.*fault-id\>1500.*\<is-cleared\>true\<
    Should Contain     ${clearing_message}    fault-id>1500

Assert Active Fault 9
    taf.sbts.oam.coam.admin.Assert Alarm Active    alarmName=regex"ORAN RU EXTERNAL PROBLEM", faultId=9, severity=Major, alarmId=7241
    ...    alias=${ADMIN_ALIAS}
    ${message}    Check Message In Logs On Oru     notification.*fault-id\>9.*\<is-cleared\>false\<
    Should Contain     ${message}    fault-id>9

Assert Inactive Fault 9
    taf.sbts.oam.coam.admin.Assert Alarm Inactive    alarmName=regex"ORAN RU EXTERNAL PROBLEM", faultId=9, severity=Major, alarmId=7241
    ...    alias=${ADMIN_ALIAS}
    ${message}    Check Message In Logs On Oru     notification.*fault-id\>9.*\<is-cleared\>true\<
    Should Contain     ${message}    fault-id>9

Assert Inactive Fault 28
    taf.sbts.oam.coam.admin.Assert Alarm Inactive    faultName=regex"C/U-plane logical Connection faulty", faultId=2907, severity=Minor
    ...    alias=${ADMIN_ALIAS}
    ${message}    Check Message In Logs On Oru     notification.*fault-id\>28.*\<is-cleared\>true\<
    Should Contain     ${message}    fault-id>28

Assert Inactive Fault 31
    taf.sbts.oam.coam.admin.Assert Alarm Inactive    faultName=regex"Radio autonomous reset as recovery action", faultId=2909, severity=Major
    ...    alias=${ADMIN_ALIAS}
    ${message}    Check Message In Logs On Oru     notification.*fault-id\>31.*\<is-cleared\>true\<
    Should Contain     ${message}    fault-id>31

