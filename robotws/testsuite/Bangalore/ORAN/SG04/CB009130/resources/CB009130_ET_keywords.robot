*** Settings ***
Documentation
...    Author: rafal.zajac@nokia.com; pawel.kuzminski@nokia.com; jaroslaw.stolarczyk@nokia.com
...    Maintainer:
...    Test Description: Feature extends CB009098 by adding multi-band, multi-carrier and LTE support to the new
...    triple-band RU.
...    Confluence link: link
...    Group in charge:
...    References: https://gates.nsn-net.net/view/0002659b#o=0
...    QualityCenter:
...    Review: -
...    AC/REQ:

Library     BuiltIn
Library     Process
Library     Collections
Library     SeleniumLibrary
Library     taf.config.scf   WITH NAME    scf
Library     taf.sw.scout    WITH NAME    scout
Library     ute_fsmaccess

Resource    startup.robot
Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/ORAN.robot
Resource    ./testsuite/Bangalore/ORAN/SG04/CB009130/resources/alarms.robot
#Resource    selenium_keywords.robot
Resource    troubleshooting_logs.robot
Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/admin.robot
Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/admin_infomodel.robot
Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/pretest_posttest.robot
Resource    ./testsuite/Bangalore/ORAN/SG04/resources/reportingportal_Keywords.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

#Force Tags       CRT  SBTS23R2    SBTS23R1  FL00    QCD_MN_RAN   QCP_RAN_ST

*** Variables ***
&{[2.0] TC_02 O-DU shall process the alarm information from the retrieved O-RU active alarm list and from the receivedO-RUalarm notificationmessage}
...	QC_ID_FL00=QC_31616
&{[2.0] TC_04 O-DU shall map the received fault with O-RAN common fault ID to a Nokia fault ID when disableORUHWValidation is set to false}
...	QC_ID_FL00=QC_31617
&{[2.0] TC_06 O-DU shall support O-RAN common fault ID with antenna line fault source received from O-RU}
...	QC_ID_FL00=QC_31618
&{[2.0] TC_03 O-DU shall map the received fault with O-RAN common fault ID to a Nokia fault ID when disableORUHWValidation is set to true}
...	QC_ID_FL00=QC_31619
&{[2.0] TC_07 O-DU shall calculate the fault severity of TX RX path out of order fault}
...	QC_ID_FL00=QC_31620
${ORU_software_version}			oru-sw-r1
${SCF_PATH}                     ./configurations
${Current_config}               phyant
${Default_scf}                  ${RAT}_${Current_config}_scf.xml
${XML_FILES_PATH}        		${CURDIR}/xml_files
${ORU_SIM_IP}                   10.45.150.67
${Docker_files}                 ${CURDIR}/Scripts
${oran_alias}=                          oran_sim
${Docker_interface}             ens12f1
${Docker_instance}              1
${oran_version}                 2
${DOCKER_NAME}			orusim
${Docker_script_path}			/home/ute/orusim/Scripts
${Start_Docker}				 	Start_Docker_${Current_config}.sh
${oru_config_path}				${Docker_script_path}/orusim-config.xml
${SNAPSHOT_PATH}                /etc/orusim/snapshots/fjt_4T4R_FDD_n1_NR.xml
${SNAPSHOT_PATH1}               /home/ute/robotws/testsuite/Bangalore/ORAN/SG04/CB009130/configurations
${Scout_tl_name}          		10_2_SG4578

@{ALLOWED_ALARMS}    			&{4592}    &{7300}
@{Counter_name}		M55606C00001	M55606C00002	M55606C00003	M55606C00004
...		M55606C00005	M55606C00006	M55606C00007	M55606C00008	M55606C00009	M55606C00010
@{PARAMETERS_TO_CHECK}    "runningSwVersion": "oru-sw-r1_1.1"    "activeSwVersion": "oru-sw-r1_1.1"
...    "runningSwBuild": "1"    "activeSwBuild": "1"    "vendorCode": "NK"    "mPlaneLinkStatus": "Connected"
...    "synceLockState": "Locked"
@{ARRAY_FIRST_TYPE}    RX_PU_L-1/RX_L-8    RX_PU_L-3/RX_L-0    TX_PU_L-1/TX_L-0    TX_PU_L-3/TX_L-8
...    RX_PU_L-1/LOW_LEVEL_RX_LINK-8    RX_PU_L-1/LOW_LEVEL_RX_LINK-15    RX_PU_L-3/LOW_LEVEL_RX_LINK-0
...    RX_PU_L-3/LOW_LEVEL_RX_LINK-7    TX_PU_L-1/LOW_LEVEL_TX_LINK-0    TX_PU_L-3/LOW_LEVEL_TX_LINK-8
@{ARRAY_SECOND_TYPE}    RX_PU_L-1/RX_L-8    RX_PU_L-3/RX_L-1    TX_PU_L-1/TX_L-0    TX_PU_L-3/TX_L-9
...    RX_PU_L-1/LOW_LEVEL_RX_LINK-8    RX_PU_L-1/LOW_LEVEL_RX_LINK-15    RX_PU_L-3/LOW_LEVEL_RX_LINK-1
...    RX_PU_L-3/LOW_LEVEL_RX_LINK-6    TX_PU_L-1/LOW_LEVEL_TX_LINK-0    TX_PU_L-3/LOW_LEVEL_TX_LINK-9
@{ENDPOINT_OBJECTS}    RX_PU_L-1/LOW_LEVEL_ENDPOINT-1    RX_PU_L-1/LOW_LEVEL_ENDPOINT-2
...    RX_PU_L-3/LOW_LEVEL_ENDPOINT-1    RX_PU_L-3/LOW_LEVEL_ENDPOINT-2    TX_PU_L-1/LOW_LEVEL_ENDPOINT-1
...    TX_PU_L-3/LOW_LEVEL_ENDPOINT-1
&{ORU_STATUS_PARAMETERS}    Operational state=enabled
...                         Availability status=-
...                         Administrative state=Unlocked
...                         Usage state=Active
...                         Procedural status=configured

&{ORU_PARAMETERS}    runningSwVersion=Running sw version
...                  activeSwVersion=Active sw version
...                  runningSwBuild=Running sw build
...                  activeSwBuild=Active sw build
...                  vendorCode=Vendor code
...                  mPlaneLinkStatus=M-Plane link status
...                  productCode=Product code
...                  serialNumber=Serial number
...                  hwVersion=HW version

&{CELL_STATUS_PARAMETERS}    administrativeState=Administrative state
...                          availabilityStatus=Availability status
...                          operationalState=Operational state
...                          usageState=Usage state
...                          blockingState=Blocking state


&{ORU_CELL_A_PARAMETERS}    chBw=Channel bandwidth
...                   nrarfcn=NRARFCN
...                   lcrId=Global cell ID
...                   cellName=Cell name
...                   physCellId=Physical layer cell ID
...                   dlMimoMode=Downlink MIMO mode
...                   cellTechnology=Cell technology
...                   expectedCellSize=Expected cell size

&{ORU_CELL_R_PARAMETERS}    nrCellIdentity=NR cell ID
...                   energySavingState=Energy saving state
...                   barringStatus=Barring status
...                   proceduralStatus=Procedural status

&{FAN_PARAMETERS}    fanName=O-RU-DCM-FAN-1
...                  fanLocation=7
...                  fanPresent=True

&{FAN_STATUS_PARAMETERS}    administrativeState=Administrative state
...                         availabilityStatus=Availability status
...                         operationalState=Operational state
...                         usageState=Usage state

&{ORU_SFP_PARAMETERS}   vendorRevision=Vendor revision
...                   	vendorPartNumber=Vendor part number
...                   	vendorName=Vendor
...                   	serialNumber=Serial number
...                   	physicalPort=Physical port
...                   	connectorType=Connector type

&{INVUNIT_RMOD_PARAMETERS}    vendorUnitTypeNumber=475243A
...                           serialNumber=S01234567
...                           versionNumber=hw-rev01
...                           vendorName=NK

&{INVUNIT_RMOD_FAN_PARAMETERS}    		unitPosition=7
...                               		vendorName=1

&{4592}     fault_id=4592
...         alarm_id=
...         alarm_severity=
...         fault_name="BTS Reset Cause"
...         notifier=
&{1806}     fault_id=1806
...         alarm_id=7101
...         alarm_severity=Warning
...         alarm_resource=
...         fault_name=Radio autonomous reset as recovery action
&{4176}     fault_id=4176
...         alarm_id=7115
...         alarm_severity=Minor
...         alarm_resource=
...         fault_name=Failure in log file gathering
&{1900}     fault_id=1900
...         alarm_id=7116
...         alarm_severity=Critical
...         alarm_resource=
...         fault_name=RF Module configuring failed
&{10}       fault_id=10
...         alarm_id=7116
...         alarm_severity=Critical
...         alarm_resource=
...         fault_name=No connection to unit
#&{27}       fault_id=27
#...         alarm_id=7115
#...         alarm_severity=Minor
#...         alarm_resource=
#...         fault_name=Error in file server during file upload or download operation
&{4662}     fault_id=4662
...         alarm_id=7115
...         alarm_severity=Warning
...         alarm_resource=
...         fault_name=Number of supported O-RU objects exceeded
&{1982}     fault_id=1982
...         alarm_id=7115
...         alarm_severity=Minor
...         alarm_resource=
...         fault_name=RF Module External Alarm and Control lines configuration failed
&{4298}     fault_id=4298
...         alarm_id=7108
...         alarm_severity=Major
...         alarm_resource=
...         fault_name=ToP reference missing
&{16}       fault_id=16
...         alarm_id=7116
...         alarm_severity=Critical
...         alarm_resource=
...         fault_name=Unit synchronization failed
&{7}       fault_id=7
...         alarm_id=
...         alarm_severity=
...         alarm_resource=
...         fault_name=
...         notifier=
&{8}       fault_id=7241
...         alarm_id=8
...         alarm_severity=Major
...         alarm_resource=
...         fault_name=
...         notifier=
&{9}       fault_id=9
...         alarm_id=
...         alarm_severity=C
...         alarm_resource=
...         fault_name=
...         notifier=
&{14}       fault_id=14
...         alarm_id=
...         alarm_severity=
...         alarm_resource=
...         fault_name=
...         notifier=
&{19}       fault_id=19
...         alarm_id=
...         alarm_severity=
...         alarm_resource=
...         fault_name=
...         notifier=
&{20}       fault_id=20
...         alarm_id=
...         alarm_severity=
...         alarm_resource=
...         fault_name=
...         notifier=
&{27}       fault_id=27
...         alarm_id=
...         alarm_severity=
...         alarm_resource=
...         fault_name=
...         notifier=
&{7300}     fault_id=7300
...         alarm_id=7107
...         alarm_severity=Major
...         fault_name="No X2 link available"
...         notifier=
&{4069}     fault_id=4069
...         alarm_id=7115
...         alarm_severity=Minor
...         alarm_resource=
...         fault_name=ALD Port power failure
&{1807}     fault_id=1807
...         alarm_id=7112
...         alarm_severity=Critical
...         alarm_resource=
...         fault_name=Invalid frequency channel for the BTS HW
&{4044}     fault_id=4044
...         alarm_id=7115
...         alarm_severity=Minor
...         alarm_resource=
...         fault_name=Incoherency in cell configuration
&{4008}     fault_id=4008
...         alarm_id=7112
...         alarm_severity=Critical
...         alarm_resource=
...         fault_name=Power level not supported
&{1402}     fault_id=1402
...         alarm_id=7103
...         alarm_severity=Minor
...         alarm_resource=
...         fault_name=eac_2
&{4720}     fault_id=4720
...         alarm_id=7115
...         alarm_severity=Minor
...         alarm_resource=
...         fault_name=Mismatch of RU reported capabilities with static HW Validation information
...         notifier=
&{1924}     fault_id=1924
...         alarm_id=7111
...         alarm_severity=Minor
...         alarm_resource=
...         fault_name=Mismatch of RU reported capabilities with static HW Validation information
...         notifier=

@{ORU_CAPABILITES}    					writable-running    xpath    notifications    interleave
@{ORU_LOGS_FILES}=    					supervisord.log    orusw.log
@{TROUBLESHOOTING_FILES}=    			troubleshooting1    troubleshooting2    troubleshooting3
@{RMOD_PARAMETERS}=    					mPlaneLinkStatus    availabilityStatus    operationalState
@{RSL_PARAMETERS}=    					dcVoltageEnabled    operationalState    availabilityStatus
@{NRCELL_PARAMETERS}=    				administrativeState    availabilityStatus    operationalState
${REMOTE_TRACE_PATH}=    				/tmp/node_FHNET00/tmp/RMOD_L-*_NetconfRpcMessageTrace.log
${LOCAL_TRACE_PATH}=     				/home/ute/Downloads/RMOD_L-1_NetconfRpcMessageTrace.log
${EDIT_CMD}=             				edit-config --target running --config=/home/
${DEFAULT_ACCOUNT_NAME}=    			xranuser
${DEFAULT_ACCOUNT_PASS}=    			xran-password
${WebEM IP}                             https://192.168.255.129:3600
${CUSTOMER_LOGIN}=                      Nemuadmin
${CUSTOMER_PASSWORD}=                   nemuuser
${INPUT_NAME_FIELD}=                    login-username
${INPUT_PASSWORD_FIELD}=                login-password
${LOGIN_BUTTON}=                        //span[contains(text(), 'Login')]
${CONFIRM_BUTTON}=                      //ui-button[@a-text="Confirm"]
${CONFIGURATION_TAB}=                   //*[@id="main-view"]/div/div[1]/app-header/main-menu/nav-item[2]/div/nav-menu-link/span
${NETCONF_RADIO_MANAGEMENT_BUTTON}=     //span[contains(text(),'Netconf Radio Management')]
${CONFIGURE_DEFAULT_ACCOUNT_BUTTON}=    //span[contains(text(),'Configure Default Netconf Account')]
${SEND_BUTTON}=                         //span[contains(text(), 'Send')]
${CHECKBOX_RMOD_1}=                     //div[@class="ui-chkbox-box ui-widget ui-state-default"]
${CONFIGURE_RADIO_SUCCEEDED}=           //span[contains(text(), 'Configure netconf radio succeeded')]
${CONFIGURATION_MANAGEMENT_BUTTON}=     //span[contains(text(),'Configuration Management')]
${COMMISSIONING_WIZARD_BUTTON}=         //span[contains(text(),'Commissioning Wizard')]
${CONFIGURE_ADDITIONAL_ACCOUNT_BUTTON}	//span[contains(text(),'Configure Additional Netconf Account')]
${CONFIGURE_AUTHENTIFIER_BUTTON}=       //span[contains(text(),'Configure Authentifier SSH Server')]
${ADDITIONAL_ACCOUNT_NAME}=             xranuser2
${NRCELL_A_PATH}=                		/SCF-1/MRBTS_A-1/NRBTS_A-1/NRCELL_A-1
${NRCELLGRP_A_PATH}=             		/SCF-1/MRBTS_A-1/NRBTS_A-1/NRCELLGRP_A-0
${scf_path1}=                            /home/ute/robotws/testsuite/Bangalore/ORAN/SG04/CB009130/configurations/PHYNT.xml
${scf_path2}=                            /home/ute/robotws/testsuite/Bangalore/ORAN/SG04/CB009130/configurations/ANTL.xml
${btsid}=                                578
${grep_create_sub_message}
...    \<rpc\.*message-id=\".*\"\>\<create-subscription.*\>\<stream\>NETCONF\</stream\>\</create-subscription\>\</rpc\>
${grep_get_alarm_list}    rpc\ xmlns.*active-alarm-list.*/rpc\>
@{features_list}    oranFeatEnergySaving    oranFeatGranularityEaxcMeas    oranFeatGranularityTransportMeas
...    oranFeatOverCurrentSupp

*** Keywords ***


[2]O-DU shall process the alarm information from the retrieved O-RU active alarm list and from the received O-RU alarm notification message
        [Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST
        [Teardown]    run keywords
        ...      reportingportal_Keywords.Set QC_Tag
        Link SCOUT SCF to Configuration ID for Reporting
	Log To Console    Test 2 'O-DU shall process the alarm information from the retrieved O-RU active alarm list started!
        Preconditions TC2
        ADMIN Perform Commissioning    bts_id=${btsid}    scf_file=${scf_path2}
        Wait Until Mplane Is Connected
	ADMIN Add Allowed Alarms    faults_list=@{WHITELIST}
	ADMIN Add Allowed Alarms    faults_list=@{ALLOWED_ALARMS_TC7}
	Trigger Fault 7_WA With Severity Critical
        Assert Fault 7_WA
        Clear Fault 7_WA
	Assert Fault 7_WA Inactive
	Trigger Fault 1000_WA With Severity Major
        Assert Fault 1000_WA
        Clear Fault 1000_WA
	Assert Fault 1000_WA Inactive
        RP Settings

[3]O-DU shall map the received fault with O-RAN common fault ID to a Nokia fault ID when disableORUHWValidation is set to true
        [Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST
        [Teardown]    run keywords
        ...      reportingportal_Keywords.Set QC_Tag
        Link SCOUT SCF to Configuration ID for Reporting
	Log To Console    Test 3 'O-DU shall map the received fault with O-RAN common fault ID to a Nokia fault ID when disableORUHWValidation is setto
	...    true' started!
	ADMIN Add Allowed Alarms    faults_list=@{ALLOWED_ALARMS_TC7}
	Trigger Fault 7 With Severity Critical
        Sleep    30s
        Assert Fault 7
        Sleep    30s
        Clear Fault 7
	Assert Fault 7 Inactive
        Trigger Fault 8_mj With Severity Major
        Sleep    30s
        Assert Fault 8_mj
        Sleep    30s
        Clear Fault 8_mj
	Assert Fault 8_mj Inactive
        Trigger Fault 9 With Severity Major
        Sleep    30s
        Assert Fault 9
        Sleep    30s
        Clear Fault 9
	Assert Fault 9 Inactive
        Trigger Fault 14 With Severity Major
        Assert Fault 14
        Clear Fault 14
	Assert Fault 14 Inactive
        Trigger Fault 19_mj With Severity Major
        Sleep    30s
        Assert Fault 19_mj
        Sleep    30s
        Clear Fault 19_mj
	Assert Fault 19 Inactive_mj
        Trigger Fault 20_mj With Severity Major
        Sleep    30s
        Assert Fault 20_mj
        Sleep    30s
        Clear Fault 20_mj
	Assert Fault 20 Inactive_mj
        Trigger Fault 27 With Severity Major
        Sleep    30s
        Assert Fault 27
        Sleep    30s
        Clear Fault 27
	Assert Fault 27 Inactive
        RP Settings
	#[Teardown]    Reset Site And Prepare Oru

[4]O-DU shall map the received fault with O-RAN common fault ID to a Nokia fault ID when disableORUHWValidation is set to false
        [Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST
        [Teardown]    run keywords
        ...      reportingportal_Keywords.Set QC_Tag
        Link SCOUT SCF to Configuration ID for Reporting
	Log To Console    Test 4 'O-DU shall map the received fault with O-RAN common fault ID to a Nokia fault ID when disableORUHWValidation is setto
	...    false' started!
        Preconditions TC4
        ADMIN Perform Commissioning    bts_id=${btsid}    scf_file=${scf_path1}
        #Wait Until Mplane Is Connected 2 ORUs TC4
        ADMIN Add Allowed Alarms    faults_list=@{ALLOWED_ALARMS_TC7}
	Trigger Fault 7_false With Severity Critical
        Assert Fault 7_false
        Sleep    30s
        Clear Fault 7_false
	Assert Fault 7 Inactive_false
        Trigger Fault 9_false With Severity Major
        Sleep    30s
        Assert Fault 9_false
        Sleep    30s
        Clear Fault 9_false
	Assert Fault 9 Inactive_false
        Trigger Fault 14_false With Severity Major
        Assert Fault 14_false
        Clear Fault 14_false
	Assert Fault 14 Inactive
        #Trigger Fault 19 With Severity Critical
        #Sleep    30s
        #Assert Fault 19
        #Sleep    30s
        #Clear Fault 19
	#Assert Fault 19 Inactive
        #Trigger Fault 20 With Severity Major
        #Sleep    30s
        #Assert Fault 20
        #Sleep    30s
        #Clear Fault 20
	#Assert Fault 20 Inactive
        Trigger Fault 27_false With Severity Major
        Sleep    30s
        Assert Fault 27_false
        Sleep    30s
        Clear Fault 27_false
	Assert Fault 27 Inactive_false
        RP Settings

[6]O-DU shall support O-RAN common fault ID with antenna line fault source received from O-RU
        [Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST
        [Teardown]    run keywords
        ...      reportingportal_Keywords.Set QC_Tag
        Link SCOUT SCF to Configuration ID for Reporting
	Log To Console    Test 6 'O-DU shall support O-RAN common fault ID with antenna line fault source received from O-RU' started!
	ADMIN Add Allowed Alarms    faults_list=@{WHITELIST}
	ADMIN Add Allowed Alarms    faults_list=@{ALLOWED_ALARMS_TC7}
        Trigger Fault 27 With Severity Major
        Sleep    30s
        Assert Fault 27
        Sleep    30s
        Clear Fault 27
	Assert Fault 27 Inactive
        Trigger Fault 27_xx:1 With Severity Major
        Sleep    30s
        Assert Fault 27_xx:1
        Sleep    30s
        Clear Fault 27_xx:1
	Assert Fault 27 Inactive_xx:1
        Trigger Fault 27_2:33 With Severity Major
        Sleep    30s
        Assert Fault 27_2:33
        Sleep    30s
        Clear Fault 27_2:33
	Assert Fault 27 Inactive_2:33
        RP Settings

[7]O-DU shall calculate the fault severity of TX RX path out of order fault
        [Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST
        [Teardown]    run keywords
        ...      reportingportal_Keywords.Set QC_Tag
        Link SCOUT SCF to Configuration ID for Reporting
        Log To Console    Test 7 'O-DU shall calculate the fault severity of TX RX path out of order fault' started!
        ADMIN Add Allowed Alarms    faults_list=@{WHITELIST}
	ADMIN Add Allowed Alarms    faults_list=@{ALLOWED_ALARMS_TC7}
	Trigger Fault 7_mj With Severity Major
        Sleep    30s
        Assert Fault 7_mj
        Sleep    30s
        Clear Fault 7_mj
	Assert Fault 7 Inactive_mj
	Trigger Fault 7_mn With Severity Minor
        Sleep    30s
        Assert Fault 7_mn
        Sleep    30s
        Clear Fault 7_mn
	Assert Fault 7 Inactive_mn
	Trigger Fault 7_cr With Severity Critical
        Sleep    30s
        Assert Fault 7_cr
        Sleep    30s
        Clear Fault 7_cr
	Assert Fault 7 Inactive_cr
	Trigger Fault 7_wr With Severity Warning
        Sleep    30s
        Assert Fault 7_wr
        Sleep    30s
        Clear Fault 7_wr
	Assert Fault 7 Inactive_wr
        RP Settings

Check RAT
	[Arguments]    ${alias}=${admin_alias}
	Log To Console      ${\n}Checking current commisioned RAT
	ADMIN Setup Admin  		alias=${admin_alias}
    ...                     bts_port=${admin_port}
    ...                     admin_api_log_dir=${admin_api_log_dir}
	${BTS_details}		taf.sbts.oam.coam.admin.Get_Bts_Info    alias=${alias}
	Run keyword If	'${BTS_details['ratState']['${RAT}']}'=='NO_CELLS'
	...		Reset Site And Prepare Oru		alias=${alias}
	[Teardown]		ADMIN Teardown Admin  alias=${admin_alias}

Check Reset Messages In Logs
    ${reset_id}    Check Message Id In Oru    <reset
    Should Not Be Empty    ${reset_id}
    ${reset_message}    Check Message In Logs On Oru    ${reset_id}
    Should Contain     ${reset_message}    <ok/></rpc-reply>

Reset Site And Prepare Oru
	[Arguments]    ${alias}=${ADMIN_ALIAS}
    ...     ${Docker_script}=${Start_Docker}
    ...     ${SCF_File}=${SCF_PATH}/${Default_scf}
	Log To Console      ${\n}Peforming Reset Site And Prepare Oru
    ADMIN Perform Commissioning    bts_id=${mrbts_id}
    ...                            scf_file=${SCF_File}
	...						   	   alias=${alias}
    Docker Container Setup      ${Docker_script}
    Wait Until Mplane Is Connected				alias=${alias}

Assert Gnb Received software download success
    ${supervision_message_id}    Check Message Id    <software-download    tail -n 1
    Should Not Be Empty    ${supervision_message_id}
    ${supervision_message}    Check Message In Netconf Trace File    "${supervision_message_id}
    Should Contain     ${supervision_message}    <rpc-reply
	Should Contain     ${supervision_message}    STARTED
	${message}		Check Message In Logs On Oru    "${supervision_message_id}"
	Should Contain     ${message}	<rpc-reply
    ${supervision_message_id}    Check Message Id    <software-install    tail -n 1
    Should Not Be Empty    ${supervision_message_id}
    ${supervision_message}    Check Message In Netconf Trace File    "${supervision_message_id}
    Should Contain     ${supervision_message}    <rpc-reply
	Should Contain     ${supervision_message}    STARTED
	${message}		Check Message In Logs On Oru    "${supervision_message_id}"
	Should Contain     ${message}	<rpc-reply
    ${supervision_message_id}    Check Message Id    <software-activate    tail -n 1
    Should Not Be Empty    ${supervision_message_id}
    ${supervision_message}    Check Message In Netconf Trace File    "${supervision_message_id}
    Should Contain     ${supervision_message}    <rpc-reply
    Should Contain     ${supervision_message}    STARTED
	${message}		Check Message In Logs On Oru    "${supervision_message_id}"
	Should Contain     ${message}	<rpc-reply

Assert Gnb Received software re-download
	${message}		Check Message In Logs On Oru    <software-download
	Should Be Empty     ${message}
    ${message}		Check Message In Logs On Oru    <software-install
    Should Be Empty     ${message}
    ${message}		Check Message In Logs On Oru    <software-activate
    Should Be Empty     ${message}

Assert Gnb Received software download failure
    ${supervision_message_id}    Check Message Id    <software-download    tail -n 1
    Should Not Be Empty    ${supervision_message_id}
    ${supervision_message}    Check Message In Netconf Trace File    "${supervision_message_id}
    Should Contain     ${supervision_message}    <rpc-reply
    Should Contain     ${supervision_message}    FAILED

Assert Gnb Not Received Response To Supervision Watchdog Reset
    ${supervision_message_id}    Check Message Id    supervision-watchdog-reset    tail -n 1
    Should Not Be Empty    ${supervision_message_id}
    ${supervision_message}    Check Message In Netconf Trace File    "${supervision_message_id}
    Should Not Contain     ${supervision_message}    <rpc-reply

Check If Oru Didnt Receive Supervision And Check If Oru Performs Reset
    ${failure_id}    Check Message Id In Oru    <set-failure
    Should Not Be Empty    ${failure_id}
    ${failure_message}    Check Message In Logs On Oru    ${failure_id}
    Should Contain     ${failure_message}    <ok/></rpc-reply>
    ${id}    Get Substring    ${failure_id}    1
    ${close_session_id}    Evaluate    ${id}+1
    ${close_session_message}    Check Message In Logs On Oru    "${close_session_id}"
    Should Contain     ${close_session_message}    close-session
    ${restart_message}    Check Message In Logs On Oru    oranrestart Sleeping for 80 seconds
    Should Not Be Empty    ${restart_message}

Hard Reset With New Container
    [Arguments]    ${Docker_script}=${Start_Docker}
	Log To Console      ${\n}Performing Hard Reset With New Container
    ADMIN Reset Site
    Docker Container Setup      ${Docker_script}
    Wait Until Mplane Is Connected

Supervision Timer Recommissioning
    [Arguments]    ${supv_value}
    ...            ${guard}
    Parameter Recommissioning    MRBTS-${mrbts_id}/MNL-1
    ...    supvNtInr
    ...    ${supv_value}
    Parameter Recommissioning    MRBTS-${mrbts_id}/MNL-1
    ...    gdTmOvhd
    ...    ${guard}

Update ORU software
	[Arguments]    ${Software_path}=${ORU_Software_path}
	...		${should_reset_radio}=True
	Log To Console      ${\n}Updating ORU software
	taf.sbts.oam.coam.admin.update_software    sw_package=${Software_path}    should_activate=True
    ...     should_reset_radios=${should_reset_radio}	timeout=300    alias=${ADMIN_ALIAS}

Check ORU SW version
	${Sw_version}	Check HW details	class_name=RMOD		parameter=buildVersion
	Should Contain		${Sw_version}		${ORU_software_version}
	${supervision_message_id}    Check Message Id    <software-rev>${ORU_software_version}    tail -n 1
    Should Not Be Empty    ${supervision_message_id}
    ${supervision_message}    Check Message In Netconf Trace File    "${supervision_message_id}
    Should Contain     ${supervision_message}    <rpc-reply

Check HW details
	[Arguments]		${class_name}=${class_name}
	...				${alias}=${ADMIN_ALIAS}
	...				${parameter}=${parameter}
	...				${timeout}=${ADMIN_TIMEOUT}
	${RMOD_list}	taf.sbts.oam.coam.admin.Get Parameters For All
	...										class_name=${class_name}
	...										timeout=${timeout}
	...										connection=${alias}
	LOG		${RMOD_list}
	FOR    ${item}    IN    @{RMOD_list}
		${value} 	Collections.Get From Dictionary
		...						${item}
		...						${parameter}
	END
	[Return]		${value}

Check product code
	[Arguments]		${value}		${class_name}=${class_name}
	log		${value}
	log		${class_name}
	${product_code}		Check HW details	class_name=RMOD		parameter=productCode
	Should Contain		${product_code}		{value}
	[Return]		${product_code}

Check vendor code
	[Arguments]		${value}	${dist_name}
	${vendor_code}		Get Current Parameter Value		dist_name=${dist_name}
	...		param_name=vendorCode
	...		alias=${ADMIN_ALIAS}
	Should Contain		${vendor_code}		${value}
	[Return]		${vendor_code}

Get Current Parameter Value
    [Arguments]    ${dist_name}    ${param_name}	${alias}=${ADMIN_ALIAS}
    [Documentation]     Get current parameter value
    ${temp_scf_file}    taf.sbts.oam.coam.admin.Get Current Scf File
	...					local_dir_path=/tmp    file_name=temp_scf.xml    connection=${alias}
    scf.Load Scf    ${temp_scf_file}
    ${param_value}    scf.get_value_from_scf    dist_name=${dist_name}    p_name=${param_name}
    [Return]    ${param_value}

DisableORUHWValidation commissioning
    Reset Site And Prepare Oru
    ...     ${Docker_script}=Start_Docker_ANT.sh
    ...     ${SCF_File}=${SCF_PATH}/${RAT}_ant_scf.xml



Check Parameters When Fault 10 Is Active
    [Arguments]    ${dist_name}=${dist_name}
    FOR    ${item}    IN    @{RMOD_PARAMETERS}
        ${state}    Get Parameters    ${item}    ${dist_name}
        Run Keyword If     '${item}' == 'mPlaneLinkStatus'    Should Be Equal As Strings
                                                              ...    ${state}[${item}]
                                                              ...    Link Down
        ...    ELSE IF    '${item}' == 'availabilityStatus'    Should Be Equal As Strings
                                                               ...    ${state}[${item}]
                                                               ...    not installed
        ...    ELSE IF     '${item}' == 'operationalState'    Should Be Equal As Strings
                                                              ...    ${state}[${item}]
                                                              ...    disabled
    END

Check Parameters When Fault 10 Is Not Active
    [Arguments]    ${dist_name}=${dist_name}
    FOR    ${item}    IN    @{RMOD_PARAMETERS}
        ${state}    Get Parameters    ${item}    ${dist_name}
        Run Keyword If     '${item}' == 'mPlaneLinkStatus'    Should Be Equal As Strings
                                                              ...    ${state}[${item}]
                                                              ...    Connected
        ...    ELSE IF     '${item}' == 'availabilityStatus'    Should Be Equal As Strings
                                                                ...    ${state}[${item}]
                                                                ...    None
        ...    ELSE IF     '${item}' == 'operationalState'    Should Be Equal As Strings
                                                              ...    ${state}[${item}]
                                                              ...    enabled
    END

Check Reset Status Under Hwreset Object
    [Arguments]    ${parameter}=hwResetResult
    ...            ${distname}=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/MNL_CONF_M-1/CMD_CONF_M-1/HWRESETREQ_CONF_M-1/HWRESETRES_R-1
#    ...            ${distname}=MRBTS-1/MNL-1/CMD-1/HWRESETREQ-1/HWRESETRES-1
    ${state}    Get Parameters    ${parameter}    ${distname}
    Should Be Equal As Strings    ${state['${parameter}']}    success

Assert Parameter Under RU Object Has Expected Value
    [Arguments]    ${value_operational_state}
    ...            ${value_reasoning_status}
    ...            ${distname}=${BTS_L_PATH}/EQM_L-1/RMOD_L-1/RU_L-1
    ${operational_state}    Get Parameters    operationalState    ${distname}
    Should Be Equal As Strings    ${operational_state['stateInfo']['operationalState']}    ${value_operational_state}
    ${reasoning_status}    Get Parameters    reasoningStatus    ${distname}
    Should Be Equal As Strings    ${reasoning_status['stateInfo']['reasoningStatus']}    ${value_reasoning_status}

Check AdministrativeState Under Rmod
    [Arguments]    ${administrativeState_value}
    ADMIN Assert Rmod With Rmod Id Is In Expected Administrative State     ${EQM_PATH}/APEQM_R-1/RMOD_R-1
    ...    ${administrativeState_value}

Check Parameters For Nrcell When Rmod Is Locked
	${cells}    taf.sbts.oam.coam.admin.get_ids_for_all    NRCEL    timeout=30s    alias=${ADMIN_ALIAS}
    FOR    ${item}    IN    @{NRCELL_PARAMETERS}
        ${state}    Get Parameters    ${item}    @{cells}[0]
        Run Keyword If     '${item}' == 'administrativeState'    Should Be Equal As Strings
                                                                 ...    ${state['${item}']}
                                                                 ...    Unlocked
        ...    ELSE IF    '${item}' == 'availabilityStatus'    Should Be Equal As Strings
                                                               ...    ${state['${item}']}
                                                               ...    dependency
        ...    ELSE IF    '${item}' == 'operationalState'    Should Be Equal As Strings
                                                             ...    ${state['${item}']}
                                                             ...    disabled
    END

Check Parameters For Ltecell When Rmod Is Locked
	${cells}    taf.sbts.oam.coam.admin.get_ids_for_all    LNCEL    timeout=30s    alias=${ADMIN_ALIAS}
    FOR    ${item}    IN    @{NRCELL_PARAMETERS}
        ${state}    Get Parameters    ${item}   @{cells}[0]
        Run Keyword If     '${item}' == 'administrativeState'    Should Be Equal As Strings
                                                                 ...    ${state['${item}']}
                                                                 ...    unlocked
        ...    ELSE IF    '${item}' == 'availabilityStatus'    Should Be Equal As Strings
                                                               ...    ${state['${item}']}
                                                               ...    dependency
        ...    ELSE IF    '${item}' == 'operationalState'    Should Be Equal As Strings
                                                             ...    ${state['${item}']}
                                                             ...    disabled
    END

Check Parameters For Nrcell
	${cells}    taf.sbts.oam.coam.admin.get_ids_for_all    NRCEL    timeout=30s    alias=${ADMIN_ALIAS}
    FOR    ${item}    IN    @{NRCELL_PARAMETERS}
        ${state}    Get Parameters    ${item}    @{cells}[0]
        Run Keyword If     '${item}' == 'administrativeState'    Should Be Equal As Strings
                                                                 ...    ${state['${item}']}
                                                                 ...    Unlocked
        ...    ELSE IF    '${item}' == 'availabilityStatus'    Should Be Equal As Strings
                                                               ...    ${state['${item}']}
                                                               ...    None
        ...    ELSE IF    '${item}' == 'operationalState'    Should Be Equal As Strings
                                                             ...    ${state['${item}']}
                                                             ...    enabled
    END

Check Parameters For Ltecell
	${cells}    taf.sbts.oam.coam.admin.get_ids_for_all    LNCEL    timeout=30s    alias=${ADMIN_ALIAS}
    FOR    ${item}    IN    @{NRCELL_PARAMETERS}
        ${state}    Get Parameters    ${item}    @{cells}[0]
        Run Keyword If     '${item}' == 'administrativeState'    Should Be Equal As Strings
                                                                 ...    ${state['${item}']}
                                                                 ...    unlocked
        ...    ELSE IF    '${item}' == 'availabilityStatus'    Should Be Equal As Strings
                                                               ...    ${state['${item}']}
                                                               ...    None
        ...    ELSE IF    '${item}' == 'operationalState'    Should Be Equal As Strings
                                                             ...    ${state['${item}']}
                                                             ...    enabled
    END

Administrative State Recommissioning Under Rmod
    [Arguments]    ${value}
    Parameter Recommissioning    MRBTS-${mrbts_id}/EQM-1/APEQM-1/RMOD-1
    ...    administrativeState
    ...    ${value}

Link SCOUT SCF to Configuration ID for Reporting
    [Arguments]    ${node_id}=${0}    ${node_type}=gnb    ${tl_name_only}=${Scout_tl_name}
	log    ${node_id}
    ${node_type_Name}        Run Keyword If  "${node_type}"=="gnb"   Set Variable  gNB
    ...     ELSE IF     "${node_type}"=="enb"                   Set Variable  eNB
    ...     ELSE        Fail    Wrong node_type '${node_type}'! allowed: enb|gnb
    Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only}
    ${scout_testline_name}=    Set Variable    ${tl_name_only}
    ${external_scf_id}=   Request Scout SCF   ${scout_testline_name}
    ${TC_ID}=    Set Variable    ute:id:${external_scf_id}
    Set Tags  ${TC_ID}

Request Scout SCF
    [Arguments]    ${scout_testline_name}
    [Documentation]    :Author: Michele
    ...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    scout.setup_scout  scout_testline_name=${scout_testline_name}
    ${external_scf_id}=   Wait Until Keyword Succeeds	2min	10s	scout.request_scf   use_scout_internal_id=True
    scout.teardown_scout_api
    [Return]   ${external_scf_id}

Preconditions TC4
    Send Cmd To Docker Shell    supervisorctl stop all
    Send Cmd To Docker Shell    rm -f /dev/shm/sr*
    #Wait Until Mplane Is Link Down    300
    Sleep    30s
    Copy Snapshot To Container    PHYANT_orusim_config.xml
    Copy Snapshot To Snapshot Path    default_snapshot_Docker.xml
    Send Cmd To Docker Shell    oranrestart 1 2

Preconditions TC2
    Send Cmd To Docker Shell    supervisorctl stop all
    Send Cmd To Docker Shell    rm -f /dev/shm/sr*
    #Wait Until Mplane Is Link Down 2 ORUs    300
    Sleep    10s
    Copy Snapshot To Container    ANTL_orusim_config.xml
    Copy Snapshot To Snapshot Path    OFEGSA_snapshot_v7_Docker.xml
    Send Cmd To Docker Shell    oranrestart 1 7

Copy Snapshot To Container
    [Arguments]    ${snapshot_name}
    Run    sshpass -p BT5l@bus3rl0g1n scp ${SNAPSHOT_PATH1}/${snapshot_name} ute@${ORU_SIM_IP}:/home/ute
    SSHLibrary.Open Connection
    ...   host=${ORU_SIM_IP}
    ...   alias=${oran_alias}
    ...   timeout=180
    SSHLibrary.Login
    ...   username=ute
    ...   password=BT5l@bus3rl0g1n
    SSHLibrary.Write    sudo su
    SSHLibrary.Read Until    root@localhost ute]#
    SSHLibrary.Write    docker cp /home/ute/${snapshot_name} orusim:/tmp/orusim-config.xml
    SSHLibrary.Read Until    root@localhost ute]#
    SSHLibrary.Write    rm /home/ute/${snapshot_name}
    SSHLibrary.Read Until    rm: remove regular file
    SSHLibrary.Write    y
    SSHLibrary.Read Until    root@localhost ute]#
    [Teardown]  Clear SSH Session To Docker

Copy Snapshot To Snapshot Path
    [Arguments]    ${snapshot_name}
    Run    sshpass -p BT5l@bus3rl0g1n scp ${SNAPSHOT_PATH1}/${snapshot_name} ute@${ORU_SIM_IP}:/home/ute
    SSHLibrary.Open Connection
    ...   host=${ORU_SIM_IP}
    ...   alias=${oran_alias}
    ...   timeout=180
    SSHLibrary.Login
    ...   username=ute
    ...   password=BT5l@bus3rl0g1n
    SSHLibrary.Write    sudo su
    SSHLibrary.Read Until    root@localhost ute]#
    SSHLibrary.Write    docker cp /home/ute/${snapshot_name} orusim:/opt/dev/xml/snapshots
    SSHLibrary.Read Until    root@localhost ute]#
    SSHLibrary.Write    rm /home/ute/${snapshot_name}
    SSHLibrary.Read Until    rm: remove regular file
    SSHLibrary.Write    y
    SSHLibrary.Read Until    root@localhost ute]#
    [Teardown]  Clear SSH Session To Docker
