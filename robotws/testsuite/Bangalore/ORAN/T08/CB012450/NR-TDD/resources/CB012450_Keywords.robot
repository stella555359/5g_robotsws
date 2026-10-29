*** Settings ***

Documentation
...   Author: rajesh.1.murmu@nokia.com
...   Group in charge: I_MN_RAN_RD_VRF_BLR1_T08_TESTER_GMS <I_MN_RAN_RD_VRF_BLR1_T08_TESTER@internal.nsn.com>
...   Description: Test Suite for CB012450_TDD


Library    taf.wts.runner    WITH NAME    wtsrunner
Library    taf.config.wts    WITH NAME    wts_conf
Library    Process
Library    BuiltIn
Library    Collections
Library    String
Library    OperatingSystem
Library    SSHLibrary
Library    DateTime
Library    RequestsLibrary
Library    ta5g_pm_counters
Library    taf.file.pack
Library    taf.config.scf   WITH NAME    scf
Library    taf.analyzer.pmcounter    WITH NAME    analyser
Library    taf.collectors.pmcounters    WITH NAME    PM
Library    taf.collectors.btslog  WITH NAME   btslog
Library    taf.collectors.core   WITH NAME   core
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    taf.collectors.tshark    WITH NAME    tshark
Library    taf.transport.ssh    WITH NAME    ssh
Library    taf.sw.scout    WITH NAME    scout
Library    taf.ue    WITH NAME    ue
Library    taf.ul.alarms_watchdog   WITH NAME    alarm
Library    taf.collectors.simple    WITH NAME    simple
Library    taf.sw.dcap.rd     WITH NAME   dcap
Library    taf.sbts.oam.coam.admin    WITH NAME   admin
Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/admin.robot
Resource    ./testsuite/Bangalore/ORAN/T08/resources/robot/Reporting_Portal_Keywords.robot


*** Variables ***
${bts_ip}=    192.168.255.129
${bts_username}=     Nemuadmin
${bts_password}=     nemuuser
${port}=    443
${target_dir}=    /home/ute/results
${duration}=    1 hour
${interval}=     5
${id}=    inbabtslabuser
${password}=    BT5l@bus3rl0g1n
${ADMIN_ALIAS}				admin_1
${INSTALL_OSQA}        ${CURDIR}/configurations/Install_OSQA_O-RU.sh
${WTS_DIR}               /opt/iphy/latest
${Timeout_SA}    120
${SUITE_WTS_CFG}    Basic_4Cell.cfg
${Total_Timeout}    5 min
${Retry_Timeout}    15 sec
${AMF_ID}    1
${Target_gNB}    2
${Ng_link_pattern}    NG primary peer address.*up
${X2_link_pattern}    ENB-1: X2AP Link with GNB-2 .* is up
${Pdu_session_ID}    1
${UE_attach_pattern}    reported successful RA
${UE_detach_pattern}    detached
${COMPONENT_CARRIER}    2
${test_property_file}    ${EXECDIR}/test.properties
${LTE_attach_pattern}    UE IS ACTIVE
${UE_5GDetach_pattern}    Bearer-type change from SCG-split to MCG
${DATA_TCP_ENABLE_FLAG}    False
${UE_deregister_pattern}    UE Context Release Complete
${wait_for_reconnection}    True
${UE_SIB_decoding_pattern}    SystemInformationBlockType1
${Ng_link_pattern_dual_stack}    NG link is Up
${S1_link_pattern_dual_stack}    S1 link is Up
${Register_complete_pattern}    REGISTRATION COMPLETE
${Cell_setup_complete_pattern}    Cell Setup completed
${UE_register_complete_pattern}    .*REGISTRATION COMPLETE.*
${Initial_UE_message_pattern}    I\nnitial UE Message Success
${Initial_UE_success_pattern}    .*Initial UE Message Success.*
${UE_SIB_decoding_pattern_eNB}    SystemInformationBlockType2
${Initial_context_setup_pattern}    Initial Context Setup Successful
${4G5G_Combo}    0
${nwslice_ID}    1
${count}=	  0
&{default_user}=    defaultNetconfAccountName=xranuser
...                 defaultNetconfAccountPwd=xran-password
&{authentication}=        id=1    defaultNetconfAccount=&{default_user}
@{sudo_list}=        &{authentication}
${artifactory_link}     https://lterel.es-si-s3-z2.eecloud.nsn-net.net/RFM_PLUGIN/RFMPlugin_O-RU_NK_475701A-102_0010.zip
${local_save_path}   /home/ute/Downloads
${RFplugin_file}    RFMPlugin_O-RU_NK_475701A-102_0010.zip
${DELTA_FILE_OLD}        ${CURDIR}/configurations/vlanid_old.json
${DELTA_FILE_NEW}        ${CURDIR}/configurations/vlanid_new.json
${scf_file_Config}      ${CURDIR}/configurations/Configuration_scf.xml
${Scout_tl_name}	2_4_UTE5GB17405408

${Pdu_session_mod_patten}      Pdu Session Resource Modify Response Message with RAN UE NGAP ID 0 handled successfully
${Pdu_session_qos_patten}      QoS Routing Table
${pdu_addition_pattern}        Pdu Session Resource Setup Response Message
&{GNB_BTS}     Ip=192.168.255.1    Username=Nemuadmin    Password=nemuuser    Port=443
&{AP_ASIL}     Ip=192.168.200.1    Username=toor4nsn    Password=oZPS0POrRieRtu    Connection=ApAsil
&{GNB_ASIL}    Ip=192.168.255.1    Username=toor4nsn    Password=oZPS0POrRieRtu    Connection=GnbAsil
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
&{ENB_BTS}     Ip=192.168.255.1    Username=Nemuadmin    Password=nemuuser    Port=443

#Netconf logs
@{netconf_file}          &{log1}     &{log2}
&{log1}       path=${OUTPUT_DIR}/RMOD_L-1_NetconfRpcMessageTrace.log
&{log2}       path=${OUTPUT_DIR}/RMOD_L-2_NetconfRpcMessageTrace.log

${netconf_file_1}	${OUTPUT_DIR}/RMOD_L-1_NetconfRpcMessageTrace.log


@{miRxWindowStats_CounterList}    M55604C00001    M55604C00006
@{miTrRxWindowStats_CounterList}    M55605C00001    M55605C00006
@{miOranTrxStats_CounterList}    'M40027C1'    'M40027C2'    'M40027C3'    'M40027C4'
    ...    'M40027C5'    'M40027C6'    'M40027C7'    'M40027C8'    'M40027C9'    'M40027C10'
@{DL_NUM_ROHC_COMP_HEADER_CounterList}    M55320C19001    M55320C19002    M55320C19003    M55320C19004

${counter_ids}    M55320C19001,M55320C19002,M55320C19003,M55320C19004,M55604C00001,M55604C00006,
...    M55605C00001,M55605C00006,M40027C1,M40027C2,M40027C3,M40027C4,M40027C5,M40027C6,M40027C7,M40027C8,M40027C9,M40027C10

@{WHITELIST}=    &{FAULT_61649}   &{FAULT_4592}
...   &{FAULT_61524}   &{FAULT_61652}
...   &{FAULT_4654}   &{FAULT_4655}   &{FAULT_4681}
...   &{FAULT_4720}   &{FAULT_4001}   &{FAULT_6202}   &{FAULT_4673}    &{FAULT_7313}
...   &{FAULT_4681}   &{FAULT_61649}   &{FAULT_4655}   &{FAULT_4654}   &{FAULT_61524}
...   &{FAULT_4673}

@{ALLOWED_ALARMS}    &{FAULT_61649}   &{FAULT_4592}
...   &{FAULT_61524}   &{FAULT_61652}
...   &{FAULT_4654}   &{FAULT_4655}   &{FAULT_4681}
...   &{FAULT_4720}   &{FAULT_4001}   &{FAULT_6202}   &{FAULT_4673}    &{FAULT_7313}
...   &{FAULT_4681}   &{FAULT_61649}   &{FAULT_4655}   &{FAULT_4654}   &{FAULT_61524}
...   &{FAULT_4673}

&{FAULT_4655}              fault_id=4655
...                        alarm_id=7220
...                        alarm_severity=regex"Warning|Minor|Major"
...                        fault_name=regex".*"
...                        notifier=regex".*"
&{FAULT_4654}              fault_id=4654
...                        alarm_id=7220
...                        alarm_severity=regex"Warning|Minor|Major"
...                        fault_name=regex".*"
...                        notifier=regex".*"
&{FAULT_61524}             fault_id=61524
...                        alarm_id=7220
...                        alarm_severity=regex"Warning|Minor|Major"
...                        fault_name=regex".*"
...                        notifier=regex".*"
&{FAULT_61652}             fault_id=61652
...                        alarm_id=7220
...                        alarm_severity=regex"Warning|Minor|Major"
...                        fault_name="R&D Service Port enabled"
...                        notifier=regex".*"
&{FAULT_61649}             fault_id=61649
...                        alarm_id=7220
...                        alarm_severity=regex"Warning|Minor|Major"
...                        fault_name=regex"LMP access via port \\d+"
...                        notifier=regex".*"
&{FAULT_4681}              fault_id=4681
...                        alarm_id=7115
...                        alarm_severity=regex"Warning|Minor|Major"
...                        fault_name="Sanity Check Error"
...                        notifier=regex".*"
&{FAULT_4720}              fault_id=4720
...                        alarm_id=7115
...                        alarm_severity=regex"Warning|Minor|Major"
...                        fault_name="Mismatch of RU reported capabilities with static HW Validation information"
...                        notifier=regex".*"
&{FAULT_4673}              fault_id=4673
...                        alarm_id=7115
...                        alarm_severity=regex"Warning|Minor|Major"
...                        fault_name="Configuration mismatch with O-RU capabilities"
...                        notifier=regex".*"
&{FAULT_6450}     		   fault_id=6450
...         			   alarm_id=regex".*"
...         			   alarm_severity=regex".*"
...         			   fault_name="Diagnostic Files collected"
...         			   notifier=regex".*"
&{FAULT_4001}     		   fault_id=4383
...         			   alarm_id=regex".*"
...        				   alarm_severity=regex".*"
...         			   fault_name="RAT autonomous reset as recovery action"
...         			   notifier=regex".*"
&{FAULT_4592}     		   fault_id=4592
...         			   alarm_id=regex".*"
...         			   alarm_severity=regex".*"
...         			   fault_name="BTS Reset Cause"
...         			   notifier=regex".*"
&{FAULT_6202}    		   fault_id=6202
...         			   alarm_id=regex".*"
...                        alarm_severity=regex".*"
...                        fault_name="Transport layer connection failure in S1 interface"
...                        notifier=regex".*"
&{FAULT_7313}     		   fault_id=7313
...         			   alarm_id=regex".*"
...         			   alarm_severity=regex".*"
...         			   fault_name="NgGnbInitPartialReset"
...         			   notifier=regex".*"

#############
## QC TAGS ##
#############
&{[TC_01]CB012450_Configuration of O-RU from WebEM along with L3 call validation}
...                     QC_ID_FL00=QC_114551     QC_ID_SBTS24R2=QC_774390
&{[TC_02]CB012450_Verification of Successful setup of Voice over NR call with ROHC enabled with TDD}
...                     QC_ID_FL00=QC_114550     QC_ID_SBTS24R2=QC_774395

*** Keywords ***
CB012450_Configuration of O-RU from WebEM along with L3 call validation
    ${log_path}    set variable    ${OUTPUT_DIR}/CB012450_CRT/CB012450_Configuration of O-RU from WebEM along with L3 call validation/
    set test variable    ${log_path}
    Log to console   \n--TC Started -> CB012450_Configuration of O-RU from WebEM along with L3 call validation--\n
	Check VlanId
	Load BTS Configuration
	Check if Radio state is enabled
	Change VlanId
	Run WTS configuration
    Check BTS state OnAir
	Verify Ng Link Status
	Check Cells are OnAir state
	Check if Radio state is enabled
    L3 Call For DL and UL for Cell_1
	sleep    100
    UE Deregister should be Successful	1


CB012450_Verification of Successful setup of Voice over NR call with ROHC enabled with TDD
    ${log_path}    set variable    ${OUTPUT_DIR}/CB012450CRT/CB012450_Verification of Voice over NR call with ROHC enabled with TDD/
    set test variable    ${log_path}
    Log to console   \n--TC Started--> CB012450_Verification of Successful setup of Voice over NR call with ROHC enabled with TDD--\n
    Check VlanId
    Load BTS Configuration
    Check if Radio state is enabled
    Change VlanId
    Run WTS configuration
    Check BTS state OnAir
    Verify Ng Link Status
    Check Cells are OnAir state
    Check if Radio state is enabled
    Attach Single SA UE		1
	Trigger VoNR DL and UL Traffic for SA
	sleep    500
	ROHC related counters verification
	ROHC related counters analyser

CB012450_Verification of delay parameters as per IOT profile
    ${log_path}    set variable    ${OUTPUT_DIR}/CB012450_CRT/CB012450_Verification of delay parameters as per IOT profile/
    set test variable    ${log_path}
    Log to console    \n--Activation of RURXWS for 5min duration--\n
    Activate reception windows measurement in O-RU object unit (RURXWS)
    Sleep    720s
    Log to console    \n--RURXWS counter verification--\n
    Verify BTS PM counter Result
    Log to console    \n--Deactivation of RURXWS--\n
    De-activate RURXWS measurements
    Log to console    \n--Activation of TRRXWS for 5min duration--\n
    Activate TRANSPORT object unit (TRRXWS)
    Sleep    720s
    Log to console    \n--TRRXWS counter verification--\n
    Verify Transport PM counter Result
    Log to console    \n--Deactivation of TRRXWS--\n
    De-activate TRRXWS measurements
    Log to console    \n--Activation of OTRST for 5min duration--\n
    Activate transceiver statistics (OTRST)
    Sleep    720s
    Log to console    \n--OTRST counter verification--\n
    Validate OTRST counter result
    Log to console    \n--Deactivation of OTRST--\n
    Deactivate the OTRST measurements

Suite Setup
    Log to console    \n--Suite Setup--\n
	admin.setup_admin    bts_host=${bts_IP}    alias=${ADMIN_ALIAS}
	${BTS_details}      admin.get_bts_info       connection=${ADMIN_ALIAS}
    Set global variable    ${BTS_ID}     ${BTS_details['mrbtsID']}
    Get and Update RFMplugin    ${RFplugin_file}      ${artifactory_link}
	Configure Netconf Credentials
	Sleep    30s
    Install OSQA O-RU

Suite Teardown
    Log to console   \n--End Test--\n
	Wait Until Keyword Succeeds    300s    20s	admin.Collect snapshot     ${OUTPUT_DIR}/snapshot.zip    alias=${ADMIN_ALIAS}
    admin.teardown_admin    connection=${ADMIN_ALIAS}

Configure Netconf Credentials
    admin.configure_netconf_accounts    unsecure_ciphering=false
    ...    authentication_method=NoAuthentication
    ...    timeout=60
    ...    connection=${ADMIN_ALIAS}
    ...    accounts=@{sudo_list}

Get and Update RFMplugin
     [Arguments]      ${sw_file_name}      ${artifactory_link}
     OperatingSystem.Run    wget ${artifactory_link} -P ${local_save_path}
     ADMIN Update Software With Activation
     ...           sw_package=${local_save_path}/${sw_file_name}

Set QC_Tag depending on SW version
    admin.connect_to
	${v}=    admin.get_software_info    timeout=30      connection=${ADMIN_ALIAS}
	LOG    ********* Active SW Version is ${v['Active SW version']}*********
	${ActiveSW}    Set Variable    ${v['Active SW version']}
	${ActiveSWstr}  BuiltIn.Convert To String    ${ActiveSW}
	Set Suite Variable    ${OUT_ENB_ACTIVE_SW}    ${ActiveSWstr}
	${release}=    Fetch From Left    ${OUT_ENB_ACTIVE_SW}    _
	${branch_check}=    Split string    ${OUT_ENB_ACTIVE_SW}     separator=_    max_split=3
	${sw_release}=
    	...     Run Keyword If    "${branch_check[2]}"=="9999"    Set Variable    FL00
    	...     ELSE    Set Variable    ${release}
    	Set Suite Variable    ${sw_release}
    	${QC_ID}=    Set Variable    &{${TEST_NAME}}[QC_ID_${sw_release}]
    	Set Tags    ${QC_ID}



Get BTS Id
    [Documentation]    This keyword is to get BTS id in current env
    ${cells_info}=    admin.Get Cell List      connection=${ADMIN_ALIAS}
    ${dist_name}=    Set Variable    ${cells_info['cells']['nr'][0]['id']['configuration']}
    Log    ${dist_name}
    ${mrbts}    ${nrbts}    ${nrcell}    String.Split String    ${dist_name}    /
    ${bts_id}    Fetch From Right    ${mrbts}    -
    [Return]    ${bts_id}

Install OSQA O-RU
    OperatingSystem.Run    sudo chmod a+x ${INSTALL_OSQA}
    OperatingSystem.Run    sh ${INSTALL_OSQA}
    sleep	150s
    Log to console    \n [INFO] Installing OSQA radio

Test Preconditions
    Log    \n+ Common Test Preconditions started    console=yes
	Start Syslogs
	Log Variables
    ADMIN Add Allowed Alarms    faults_list=${ALLOWED_ALARMS}
	Log    \n+ Common Test Preconditions finished    console=yes

Test Postconditions
	Log    \n+ Common Test Postconditions started    console=yes
	Stop Syslog
	Log Variables
    ADMIN Add Allowed Alarms    faults_list=${ALLOWED_ALARMS}
    Link SCOUT SCF to Configuration ID for Reporting
    Log    \n+ Common Test Postconditions finished    console=yes

Start Syslogs
    Log To Console    \n [INFO] bts collector creation is in progress
    btslog.create_btslog_collector
    ...   name=btslog
    ...   btslog_path=/opt/btslog/btslog
    ...   btslog_launcher_path=/opt/btslog/btslog_launcher
    ...   log_dir=/tmp/btslog2
	Log To Console    \n [INFO] bts collector creation success
    core.setup_collectors      names=btslog
    core.set_suite_alias    btslog
    core.start_collectors      names=btslog


Stop Syslog
    core.stop_collectors      names=btslog
    core.collect_collectors      names=btslog      target_dir=${OUTPUT_DIR}/${TEST_NAME}
    core.teardown_collectors      names=btslog



Check BTS state OnAir
    [Documentation]    \n Check if BTS state is onair
	sleep	300s
    ${mrbts_state}=    ADMIN Get Mrbts State    alias=${ADMIN_ALIAS}
    Log to console    \n [INFO] \MRBTS state: ${mrbts_state}
    Wait Until Keyword Succeeds    20 min    30 sec    Should Be Equal As Strings    ${mrbts_state}    onair    ignore_case=${TRUE}

Check O-RU M-plane connection is established
    Log to console   \n-- Started ->Check O-RU M-plane connection is established--
    Check M-Plane link status
    Netconf log validation
    ${log}=    OperatingSystem.Get file    ${OUTPUT_DIR}/RMOD_L-1_NetconfRpcMessageTrace.log
	${log_1}=    OperatingSystem.Get file    ${OUTPUT_DIR}/RMOD_L-2_NetconfRpcMessageTrace.log
    should contain    ${log}    Sending message:<hello
    should contain    ${log}    Received message:<hello
	should contain    ${log_1}    Sending message:<hello
    should contain    ${log_1}    Received message:<hello
    Log to console    Hello message verified in netconf log

Check M-Plane link status
    ${response}    admin.get_frm    connection=${ADMIN_ALIAS}
    Run Keyword If  '${response[0]['status']['mPlaneLinkStatus']}'=='Connected'
    ...    Log To Console    RU M-Plane link status is: ${response[0]['status']['mPlaneLinkStatus']}
    ...    ELSE    fail

Check if Radio state is enabled
    [Documentation]    \n Check if Operational State of all Radio's is enabled
    Radio State should be enabled
	ADMIN Assert All Rmods Are In Enabled State   timeout=900


Radio State should be enabled
    Wait Until Keyword succeeds     20min    30s    Verify Coam Radio is Online


Verify Coam Radio is Online
    ${bts_hw_info}                admin.Get Bts Info    connection=${ADMIN_ALIAS}
    ${radio_state}                Set Variable
    ...                           ${bts_hw_info['radioModules']['rmod'][0]['status']['operationalState']}
    Log to Console    \n [INFO] RADIO STATE : ${radio_state}
    Should Be Equal As Strings    ${radio_state}    enabled    ignore_case=${TRUE}



Validate the O_RU Call home procedure
    ###############example validations using netcinf keywords#############################

###################Message 12 #######################################
    ${if_description}=    netconf_get_value     ${netconf_file_1}     rpc      edit-config       if:description
    Log     ${if_description}
    ${oran_vlanid}=    netconf_get_value     ${netconf_file_1}     rpc      edit-config       o-ran-int:vlan-id
    Log     ${oran_vlanid}
	${oran_cplane_marking}=    netconf_get_value     ${netconf_file_1}     rpc      edit-config
	...		o-ran-int:c-plane-marking
    Log     ${oran_cplane_marking}
    ${oran_cplane_marking}=    netconf_get_value     ${netconf_file_1}     rpc      edit-config
	...		o-ran-int:u-plane-marking
    Log     ${oran_cplane_marking}
	${processing_elements}=    netconf_get_value     ${netconf_file_1}     rpc      edit-config
	...		processing-elements
	Log		${processing_elements}
	${lowest_vlanid}=    netconf_get_value     ${netconf_file_1}     rpc      edit-config
	...		lowest-vlan-id
	Log		${lowest_vlanid}
	${highest_vlanid}=    netconf_get_value     ${netconf_file_1}     rpc      edit-config
	...		highest-vlan-id
	Log		${highest_vlanid}
	${m-plane-marking}=    netconf_get_value     ${netconf_file_1}     rpc      edit-config
	...		o-ran-int:m-plane-marking
	Log		${m-plane-marking}
	${ptp-config}=    netconf_get_value     ${netconf_file_1}     rpc      edit-config       ptp-config  ##Doesnt work
    Log to console     ${ptp-config}
	${clock_classes}=    netconf_get_value     ${netconf_file_1}     rpc      edit-config       clock-classes
   Log to console     ${clock_classes}
	${ald_ports_io}=    netconf_get_value     ${netconf_file_1}     rpc      edit-config       ald-ports-io  #Doesnt work
    Log to console     ${ald_ports_io}
	${a}=    validate_netconf_reply_message      ${netconf_file_1}     edit-config    ok
	Log		${a}
###############Message 13 ###########################################
    ${name}=    netconf_get_value     ${netconf_file_1}     rpc      edit-config       name
    Log     ${name}
    ${scs}=    netconf_get_value     ${netconf_file_1}     rpc      edit-config       scs
    Log     ${scs}
	${number-of-prb}=    netconf_get_value     ${netconf_file_1}     rpc      edit-config       number-of-prb
    Log     ${number-of-prb}
    ${eaxc-id}=    netconf_get_value     ${netconf_file_1}     rpc      edit-config       eaxc-id
    Log     ${eaxc-id}
###Multiple message under different header looking for the above values ########################Open point to discuss
    ${absolute-frequency-center}=    netconf_get_value     ${netconf_file_1}     rpc      edit-config
	...		absolute-frequency-center
    Log     ${absolute-frequency-center}
    ${center-of-channel-bandwidth}=    netconf_get_value     ${netconf_file_1}     rpc      edit-config
	...		center-of-channel-bandwidth
    Log     ${center-of-channel-bandwidth}
	${channel-bandwidth}=    netconf_get_value     ${netconf_file_1}     rpc      edit-config       channel-bandwidth
    Log     ${channel-bandwidth}
    ${gain}=    netconf_get_value     ${netconf_file_1}     rpc      edit-config       gain
    Log     ${gain}
###Multiple message under different header looking for the above values ########################Open point to discuss
    ${low-level-tx-endpoint}=    netconf_get_value     ${netconf_file_1}     rpc      edit-config
	...		low-level-tx-endpoint
    Log     ${low-level-tx-endpoint}
	${low-level-rx-endpoint}=    netconf_get_value     ${netconf_file_1}     rpc      edit-config
	...		low-level-rx-endpoint
    Log     ${low-level-rx-endpoint}
###Multiple message under different header looking for the above values ########################Open point to discuss
###############################Message 15 ################################################
	${sync-state}=    netconf_get_value     ${netconf_file_1}     notification      synchronization-state-change
	...		sync-state
    Log     ${sync-state}
    ${ptp-state}=    netconf_get_value     ${netconf_file_1}     notification      ptp-state-change        ptp-state
    Log     ${ptp-state}
	${supervision-notification-interval}=    netconf_get_value     ${netconf_file_1}     notification
	...		supervision-notification        supervision-notification-interval
    Log     ${supervision-notification-interval}
    ${guard-timer-overhead}=         netconf_get_value     ${netconf_file_1}     notification
	...		supervision-notification       guard-timer-overhead
    Log     ${guard-timer-overhead}
###Multiple message under different header looking for the above values ########################Open point to discuss
#####Message16 -- same as above 1st msg field no valdation #####################################
###############################Message 17 ################################################ Initial message open
	${tx_carrier_name}=    netconf_get_value     ${netconf_file_1}     notification      tx-array-carriers-state-change
	...		name
    Log     ${tx_carrier_name}
    ${tx_carrier_state}=    netconf_get_value     ${netconf_file_1}     notification      tx-array-carriers-state-change
	...		state
    Log     ${tx_carrier_state}
	 ${hardware}=    netconf_get_value     ${netconf_file_1}     rpc      get         hardware
    Log     ${hardware}
	${rpc_name}=    validate_netconf_reply_message     ${netconf_file_1}     rpc-reply      hardware         name
    Log     ${rpc_name}
    ${admin-state}=    validate_netconf_reply_message     ${netconf_file_1}     rpc-reply      hardware
	...		admin-state
    Log     ${admin-state}
	${oper-state}=    validate_netconf_reply_message     ${netconf_file_1}     rpc-reply      hardware
	...		oper-state
    Log     ${oper-state}
	${usage-state}=    validate_netconf_reply_message     ${netconf_file_1}     rpc-reply      hardware
	...		usage-state
    Log     ${usage-state}
	${power-state}=    validate_netconf_reply_message     ${netconf_file_1}     rpc-reply      hardware
	...		power-state
    Log     ${power-state}
	${availability-state}=    validate_netconf_reply_message     ${netconf_file_1}     rpc-reply      hardware
	...		availability-state
    Log     ${availability-state}
	${next-update-at}=    validate_netconf_reply_message     ${netconf_file_1}     rpc-reply      next-update-at
    Log     ${next-update-at}


Check -DU retrieve O-RU SW information
    Log to console   \n--Step Started ->Check -DU retrieve O-RU SW information--
    ${a}=   netconf_get_message_id   ${netconf_file_1}   get   software-inventory
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=   validate_netconf_reply_message   ${netconf_file_1}   get   software-inventory   name
    run keyword and continue on failure   Should not be empty    ${a}
	${a}=    validate_netconf_reply_message      ${netconf_file_1}     get    software-inventory     product-code
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    validate_netconf_reply_message      ${netconf_file_1}     get    software-inventory     vendor-code
    run keyword and continue on failure   Should not be empty    ${a}
    Log to console   Checked DU retrieve O-RU SW information in netconf log


Check Sync
    Log to console   \n--Step Started ->Check Sync--
    ${a}=    netconf_get_message_id     ${netconf_file_1}    get    sync
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    validate_netconf_reply_message      ${netconf_file_1}     get    sync-status     sync-state
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    netconf_get_message_id    ${netconf_file_1}    get    ptp-status
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    validate_netconf_reply_message      ${netconf_file_1}     get    ptp-status     lock-state
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    validate_netconf_reply_message      ${netconf_file_1}     get    synce-config     acceptance-list-of-ssm
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    netconf_get_message_id     ${netconf_file_1}    get    synce-status
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    validate_netconf_reply_message      ${netconf_file_1}     get    synce-status     lock-state
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    netconf_get_message_id     ${netconf_file_1}    get    operational-info
    run keyword and continue on failure   Should not be empty    ${a}
    ${a}=    validate_netconf_reply_message      ${netconf_file_1}     get    operational-info     restart-cause
    run keyword and continue on failure   Should not be empty    ${a}
    Log to console   Checked Sync status in netconf log--\n


Run WTS configuration
    [Documentation]    \n To Start WTS configuration for AMF & MME Simulation
    Start UTE WTS

Start UTE WTS
    [Documentation]    Kill running WTS binaries if any, configure ETH3, retrieve files and configure WTS
    Stop Edaemon Egate
    Configure UTE ETH3 FOR BOAM_ET_CONF
    Connect To WTS VM
    wtsrunner.configure_wtsemu_edaemon    edaemon_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=22222
    ...                                   sudo_password=ute
    wtsrunner.configure_wtsemu_egate      egate_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=20000
    ...                                   nostats=True
    wtsrunner.start_wtsemu                egate_console_ip=${WTS.Ip}
    ...                                   egate_port=20000
    ${ls}    Run    ls ${WTS_DIR}/*cfg
    Log To Console    ${ls}
    ${cfg_filename}  set variable   ${WTS_DIR}/${SUITE_WTS_CFG}
    wtsrunner.configure                      file=${cfg_filename}
    wtsrunner.read_wtsemu_output_until_re    expected=SimMode is ready now     timeout=300
    Wait Until Keyword Succeeds    10 min    30 sec    Verify if sim state is active
	sleep	130s


Stop Edaemon Egate
    [Documentation]    Kill edaemon and egate if already running.
    ${edaemon_pid}=    Run    pgrep edaemon
    ${edaemon_status}    Run Keyword and Return Status    Should Not Be Empty    ${edaemon_pid}
    Run Keyword If    ${edaemon_status}    Run    sudo pkill -9 edaemon
    ${egate_pid}=    Run    pgrep egate
    ${egate_status}    Run Keyword and Return Status    Should Not Be Empty    ${egate_pid}
    Run Keyword If    ${egate_status}    Run    sudo pkill -9 egate
    Run Keyword If    ${edaemon_status} or ${egate_status}    sleep      5s

Configure UTE ETH3 FOR BOAM_ET_CONF
    Run    sudo ip addr add 10.0.1.121/24 dev eth3
    Run    sudo ip addr add 10.0.1.131/24 dev eth3
    Run    sudo ip addr add 10.0.1.132/24 dev eth3
    Run    sudo ip addr add 10.0.1.133/24 dev eth3
    Run    sudo ip addr add 10.0.1.134/24 dev eth3
    Run    sudo ip addr add 10.0.1.135/24 dev eth3
    Run    sudo ip addr add 10.0.1.136/24 dev eth3
    Run    sudo ip addr add 10.0.1.137/24 dev eth3
    Run    sudo ip addr add 10.0.1.138/24 dev eth3
    Run    sudo ip addr add 10.0.1.150/24 dev eth3
    Run    sudo ip addr add 10.0.1.112/24 dev eth3

Connect To WTS VM
    [Documentation]    Establish a ssh connection to the WTS machine where the simulator is present
    ssh.Connect to     hostname=${WTS.Ip}
    ...                username=${WTS.Username}
    ...                alias=${WTS.Connection}
    ${command}        Catenate    sysctl -w net.sctp.sack_timeout=10 &&
    ...               sysctl -w net.sctp.rto_min=200 &&
    ...               sysctl -w net.sctp.rto_initial=200 &&
    ...               sysctl -w net.sctp.rto_max=800
    Run               ${command}
    Run               cat /proc/sys/net/sctp/rto_min

Verify if sim state is active
    wtsrunner.sim_state_disp
    wtsrunner.read_wtsemu_output_until_re    expected=The state is ACTIVE   timeout=20

Verify Ng Link Status
    [Documentation]    \n -SA- Check if "NG link is UP" message can be found in egate console and egate_console.log
    NG Link Should be UP
	Log to console    \n NG Link Should is UP


NG Link Should be UP
    [Documentation]    This keyword checks if the NG link is up for the SA variant in egate_console.log file
    ...                Modified Date: 10-Jun-2021
    ...                Last Modified by: gopalakrishnan.n@nokia.com
    Wait Until Keyword Succeeds    ${Total_Timeout}    ${Retry_Timeout}
    ...    NG link check using AMF Link Status    ${AMF_ID}    ${TARGET_GNB}
    Sleep     240s
    Run Keyword If    '${4G5G_Combo}'=='1'    Log    "S1 link check for eNB"

NG link check using AMF Link Status
    [Arguments]    ${amf_id}=${AMF_ID}    ${gnb_id}=${Target_gNB}
    [Documentation]    This Keyword checks if the NG link status for the mentioned gNB ID using the amf_disp command
    ...    on egate console
    wtsrunner.amf_disp    id=${amf_id}    type=link_info    gnb=${gnb_id}
	${amf_link_status}=    Run Keyword And Return Status
    ...    wtsrunner.read_wtsemu_output_until_re    expected=${Ng_link_pattern}    timeout=60
    Run Keyword If    '${amf_link_status}'=='False' and '${4G5G_Combo}'=='1'
    ...    Search pattern should Exists In EGATE ${WTS_DIR}/egate_console.log ${Ng_link_pattern_dual_stack}
    ...    ELSE IF    '${amf_link_status}'=='True'    Log    "NG Link in UP"
    ...    ELSE    Fail    msg="NG Link is not Up"

Check Cells are OnAir state
    [Documentation]    \n Check if all cells are OnAir
	sleep	400s
    ${cell_status}=     Get Cell status
    cell status    ${cell_status}
    ADMIN Assert All NRCells Are In Enabled State    timeout=900
	Log to console    \n All cells are ON-Air

Get Cell status
    ${cell_status}=    admin.Get Subcells Status     connection=${ADMIN_ALIAS}
    return from keyword    ${cell_status}
    Should Be Equal As Strings    ${cell_status}    enabled    ignore_case=${TRUE}

cell status
    [Arguments]    ${cell_list}
    ${cnt}=    Get Length    ${cell_list}
    FOR    ${var}    IN RANGE    0    ${cnt}
        Log    ${cell_list}
        ${operational_state}    Set Variable    ${cell_list["NRCELLGRP-${var}"]["NRCELL-${${var}+1}"]["NRCELL_R"]["operationalState"]}
        Log    NRCELLGRP-${var} NRCELL-${var+1} NRCELL_R:${operational_state}
        Log to Console    \n [INFO] NRCELLGRP-${var} NRCELL-${var+1} NRCELL_R:${operational_state}
        Should Be Equal As Strings    ${operational_state}    enabled    ignore_case=${TRUE}
    END

ADMIN Assert All NRCells Are In Enabled State
    [Arguments]    ${timeout}=100
    ...            ${expected_state}=regex"Enabled|enabled"
    ...            ${class_name}=NRCEL
    CB012450_Keywords.ADMIN Assert All NRCells Are In Expected Operational State    expected_state=${expected_state}
    ...                                                         timeout=${timeout}
    ...                                                         class_name=${class_name}

ADMIN Assert All NRCells Are In Expected Operational State
    [Arguments]    ${expected_state}
    ...            ${timeout}=100
    ...            ${state_type}=operationalState
    ...            ${class_name}=NRCEL
    CB012450_Keywords.ADMIN Assert All NRCells Are In Expected State    expected_state=${expected_state}
    ...                                             state_type=${state_type}
    ...                                             timeout=${timeout}
    ...                                             class_name=${class_name}

ADMIN Assert All NRCells Are In Expected State
    [Arguments]    ${state_type}
    ...            ${expected_state}
    ...            ${timeout}=10
    ...            ${class_name}=NRCEL
    ADMIN Assert Every    parameters=${state_type}=${expected_state}
    ...                   timeout=${timeout}
    ...                   class_name=${class_name}


L3 Call For DL and UL for Cell_1
    [Arguments]    ${UE_ID}=${1}    ${dl_tp}=${175}    ${ul_tp}=${175}    ${start_id}=${1}    ${end_id}=${10}
    Attach Single SA UE    ${UE_ID}
    log    Triggering DL data call
	FOR	    ${trf_id}   IN RANGE    ${start_id}	  ${end_id}
        SA Start DL Traffic Internal    ${UE_ID}    pdu_id=1
        ...    mbps=${dl_tp}    trf_id=${trf_id}
    END
	log    Triggering UL data call
	FOR	    ${trf_id}   IN RANGE    ${start_id}	  ${end_id}
        SA Start UL Traffic Internal    ${UE_ID}    pdu_id=1
        ...    mbps=${ul_tp}    trf_id=${trf_id}
    END

    ${cell_1_dl_tp}=    Get Cell Average Throughput    ${UE_ID}    dir=dl    cell_type=pcell    scell_index=0
	${cell_1_ul_tp}=    Get Cell Average Throughput    ${UE_ID}    dir=ul    cell_type=pcell    scell_index=0
    log     DL Troughput of cell_1 is ${cell_1_dl_tp}
    log     UL Troughput of cell_1 is ${cell_1_ul_tp}
    Should Be True    ${cell_1_dl_tp}>0
    Should Be True    ${cell_1_ul_tp}>0

Trigger VoNR DL and UL Traffic for SA
    [Arguments]    ${ue_id}=${1}   ${pdu_id}=${1}    ${rtp_codec}=amr_wb_18_25
    [Documentation]    This keyword starts the VoNR DL Traffic for the SA variant having some rtp codec
    Log to Console    \nRunning VoNR DL Traffic for ${rtp_codec}...
	wtsrunner.ue_pdu_session_modify      ue=${ue_id}       pdu=${pdu_id}    qosflows_to_add=${2}    by=amf
	sleep    5
    ${output}    Read WTS Output Until Pattern Matches    ${Pdu_session_qos_patten}     ${Timeout_SA}
    Print Matching Lines from Output File    ${output}    ${Pdu_session_mod_patten}
    BuiltIn.Log               ue=${ue_id} qosflow=${2} added
	Log to Console            ue=${ue_id} qosflow=${2} added
	sleep    5
	wtsrunner.ue_pdu_session_modify      ue=${ue_id}       pdu=${pdu_id}    qosflows_to_add=${3}    by=amf
    ${output}    Read WTS Output Until Pattern Matches    ${Pdu_session_qos_patten}     ${Timeout_SA}
    Print Matching Lines from Output File    ${output}    ${Pdu_session_mod_patten}
    BuiltIn.Log               ue=${ue_id} qosflow=${3} added
	Log to Console            ue=${ue_id} qosflow=${3} added
	sleep    5
    wtsrunner.trf_data_start     ue=${ue_id}    pdu=${pdu_id}   qfi=${3}    dir=dl		rtp_codec=${rtp_codec}
	sleep    5
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Downlink RTP Internal traffic over UDP*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP DL TRF:    partial_match=${TRUE}
    Log to Console    ${output} VoNR_DL_traffic_data_is_started_successfully
    BuiltIn.Log    VoNR_DL_traffic_data_is_started_successfully
    sleep    5
    wtsrunner.trf_data_start     ue=${ue_id}    pdu=${pdu_id}   qfi=${3}    dir=ul		rtp_codec=${rtp_codec}
	sleep    5
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Uplink RTP Internal traffic over UDP*      timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP UL TRF:    partial_match=${TRUE}
	sleep    5
    Log to Console    ${output} VoNR_UL_traffic_data_is_started_successfully
    BuiltIn.Log    VoNR_UL_traffic_data_is_started_successfully

Trigger VoNR UL Traffic for SA
    [Documentation]    This keyword starts the VoNR UL Traffic for the SA variant having some rtp codec
    Log to Console    \nRunning VoNR UL Traffic for ${rtp_codec}...
	wtsrunner.ue_pdu_session_modify      ue=${ue_id}       pdu=${pdu_id}    qosflows_to_add=${2}    by=amf
    ${output}    Read WTS Output Until Pattern Matches    ${Pdu_session_qos_patten}     ${Timeout_SA}
    Print Matching Lines from Output File    ${output}    ${Pdu_session_mod_patten}
    BuiltIn.Log               ue=${ue_id} qosflow=${qosflows_to_add} added
	Log to Console            ue=${ue_id} qosflow=${qosflows_to_add} added
	wtsrunner.ue_pdu_session_modify      ue=${ue_id}       pdu=${pdu_id}    qosflows_to_add=${3}    by=amf
    ${output}    Read WTS Output Until Pattern Matches    ${Pdu_session_qos_patten}     ${Timeout_SA}
    Print Matching Lines from Output File    ${output}    ${Pdu_session_mod_patten}
    BuiltIn.Log               ue=${ue_id} qosflow=${qosflows_to_add} added
	Log to Console            ue=${ue_id} qosflow=${qosflows_to_add} added
    FOR	    ${trf_id}   IN RANGE    ${start_id}	  ${end_id}
        wtsrunner.trf_data_start     ue=${ue_id}    pdu=${pdu_id}   qfi=${3}    dir=ul    trf_id=${trf_id}    rtp_codec=${rtp_codec}
    END
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Uplink RTP Internal traffic over UDP*      timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP UL TRF:    partial_match=${TRUE}
    Log to Console    ${output} VoNR_UL_traffic_data_is_started_successfully
    BuiltIn.Log    VoNR_UL_traffic_data_is_started_successfully



Get Cell Average Throughput
    [Arguments]    ${UE_ID}    ${dir}    ${cell_type}    ${scell_index}
    [Documentation]    This keyword is to get Pcell/Scell Average throughput,1Mbps=1000Kbps
    ...    The unit of return throughput is Mbps.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${UE_ID} | Yes | ue_id |
    ...    | ${dir} | Yes | dl/ul |
    ...    | ${cell_type} | Yes | pcell/scell |
    ...    | ${scell_index} | Yes | 1/2/3...|
    ...
    ...    | Examples: |
    ...    | ${pcell_tput} | Get CA Cell Average Throughput | 1 | dl | pcell | 0 |
    ...    | ${scell1_tput} | Get CA Cell Average Throughput | 1 | dl | scell | 1 |
    ...    | ${scell2_tput} | Get CA Cell Average Throughput | 1 | ul | scell | 2 |
    ...
    ${type}    Set Variable If    '${dir}'=='dl'    pdsch    pusch
    wtsrunner.ue_stats_nr    id=${UE_ID}    type=${type}    scell=${scell_index}
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=Total       timeout=300
    ${regexp_cell}    Catenate    SEPARATOR=${EMPTY}    CellIndex-\\d{1,2}\\s+((\\d+.?\\d*\\s)(Mbps)?(Kbps)?(bps)?\\s+){3}
    ...    (?P<AvgTput>\\d+.?\\d*)\\s(?P<TputUnit>(Mbps)?(Kbps)?(bps)?)
    ${avg_tp_list}    String.Get Regexp Matches    ${output}    ${regexp_cell}    AvgTput
    ${cell_tp}=    Evaluate    sum(map(float,${avg_tp_list}))
    ${cell_tp}=    Set Variable If    "${cell_tp}"=="0.0"    0    ${cell_tp}
    ${tp_unit_list}    String.Get Regexp Matches    ${output}    ${regexp_cell}    TputUnit
    ${tp_unit_empty}    ${ret}    Run Keyword And Ignore Error    Should Be Empty    ${tp_unit_list[0]}
    Run Keyword If    "${cell_tp}"=="0"    Append To List    ${tp_unit_list}    Mbps
    ${Kbps_to_Mbps}    Evaluate    float(${cell_tp}/1000)
    ${bps_to_Mbps}    Evaluate    float(${cell_tp}/1000/1000)
    ${cell_tput_Mbps}    Set Variable If    '${tp_unit_list[0]}'=='Kbps'    ${Kbps_to_Mbps}
    ...                                     '${cell_tp}'!='0' and '${tp_unit_empty}'=='PASS'    ${bps_to_Mbps}
    ...                                     ${cell_tp}
    [Return]    ${cell_tput_Mbps}

Attach Single SA UE
    [Arguments]    ${UE_ID}
    SA 5G Attach    ${UE_ID}
    SA Set Traffic Type To Internal    ${UE_ID}    pdu_id=1
    SA 5G PDU Session Setup    ${UE_ID}

SA 5G Attach
    [Arguments]    ${UE_ID}
    [Documentation]    This keyword is used to simulate UE attach on 5GNR side during NSA L3 Call on eGate.
    ...    Expected output is: "UE1: Proxy (eNB 2 Cell 3 ) reported successful RA" on eGate.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    Example:
    ...    | SA 5G Attach | 1 |
    Log To Console    start 5G attach...
    wtsrunner.ue_register    id=${UE_ID}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    ${ret}=    Run Keyword And Return Status    Should Contain    ${output}    REGISTRATION COMPLETE
    Run Keyword If    "${ret}"=="${False}"    Fail    SA 5G Attach fails!!!
    Should Be True    ${ret}
    ${output1}    String.Get Lines Matching Regexp    ${output}    REGISTRATION COMPLETE    partial_match=${true}
    Log To Console    \n${output1}
    Should Match Regexp    ${output}	I\nnitial UE Message Success
    Sleep    3s    reason=wait 5G attach is stable

Read WTS Output Until Pattern Matches
    [Arguments]    ${pattern}    ${timeout}
    [Documentation]    This keyword checks the output file until the ${pattern} matches in the file.
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=${pattern}
    ...    timeout=${timeout}
    [Return]    ${output}

SA Set Traffic Type To Internal
    [Arguments]    ${UE_ID}    ${pdu_id}=1
    wtsrunner.set_pdu_param     ue=${UE_ID}    pdu=${pdu_id}    trf_type=internal

SA 5G PDU Session Setup
    [Arguments]    ${UE_ID}    ${pdu_id}=1
    [Documentation]    This keyword is used to simulate PDU session setup on 5GNR side.
    ...    Expected output is: " Initial Context Setup Successful " on eGate.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | A1_add | No | ${True} |
    ...    | drx_on | No | ${True} |
    ...    Example:
    ...    | SA CA 5G PDU Session Setup | 1 |
    Log To Console    start 5G PDU Session Setup...
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${UE_ID}    nwslice=1    gw=1
    ${output}    Read WTS Output For Pattern And Print matching Lines    ${Initial_context_setup_pattern}    ${Timeout_SA}
    Log To Console    ${output}

Read WTS Output For Pattern And Print matching Lines
    [Arguments]    ${pattern}    ${timeout}
    [Documentation]    This keyword checks if the ${pattern} is present in the output file and prints the line matching the pattern.
    ${output}    Read WTS Output Until Pattern Matches   ${pattern}    ${timeout}
    Print Matching Lines from Output File    ${output}    ${pattern}
    [Return]    ${output}

Print Matching Lines from Output File
    [Arguments]    ${output}    ${pattern}
    [Documentation]    This keyword Prints the lines which contains the ${pattern} from the output file ${output}
    ${output}        String.Get Lines Matching Regexp    ${output}    ${pattern}
    ...               partial_match=${TRUE}
    Log to Console    \n${output}

Get Cell Throughput From Btslog
    [Arguments]    ${duration}=20s    ${log_dir}=${OUTPUT_DIR}
    ${savepoint}=    ute_syslog.Capture Savepoint    alias=${GNB_SYSLOG.alias}
    Sleep    ${duration}
    ute_syslog.Collect From Savepoint    savepoint=${savepoint}    destination_file=${log_dir}/target_syslog.txt    alias=${GNB_SYSLOG.alias}
    ${tp}=    Analyze_syslog.get_tp_from_syslog    ${log_dir}/target_syslog.txt
    [Return]    ${tp}


Check Cell Throughput Quality From Btslog
    [Arguments]    ${tp_list}    ${cell_id}    ${direction}    ${target_tp}    ${aver_ratio}=${0.95}    ${min_ratio}=${0.85}
    [Documentation]    Check Throughput Quality from keyword "Get Cell Throughput From Btslog"
    ...    | Input Parameters | Man. | Description |
    ...    | ${tp_list} | YES | return value from keyword "Get Throughput From Bts" |
    ...    | ${cell_id} | YES | cell id|
    ...    | ${direction} | YES | dl/ul|
    Should Be True    ${tp_list}[${direction}][${cell_id}][ave]>${target_tp}*${aver_ratio}    Syslog average TP is lower than Target
    Should Be True    ${tp_list}[${direction}][${cell_id}][min]>${target_tp}*${min_ratio}    Syslog min TP is lower than Target




Check VlanId
    ${vlanId}=    admin.Get Parameters
	...		dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/TNLSVC_CONF_M-1/TNL_CONF_M-1/ETHSVC_CONF_M-1/ETHIF_CONF_M-1/VLANIF_CONF_M-1
    ...     connection=${ADMIN_ALIAS}
	${vlanId_1}=		Get From Dictionary    ${vlanId}    vlanId
    ${vlanId_str}=    Convert to String    ${vlanId_1}
    ${json}=   OperatingSystem.Get File    ${DELTA_FILE_OLD}
    ${replace}=     Replace String    ${json}    10000    ${vlanId_str}
    Create File   ${CURDIR}/configurations/vlanid_new.json      ${replace}



Change VlanId
	ADMIN Perform Delta Recommissioning
        ...    delta_file=${DELTA_FILE_NEW}
        ...    skip_parameter_relation_errors=${True}

Load BTS Configuration
    [Documentation]    Perform BTS Full Commissioning
	Log to console    \n Performing BTS commission...
    ADMIN Perform Commissioning     ${BTS_ID}     ${scf_file_Config}     ${ADMIN_ALIAS}

Collect SosReport
    [Arguments]    ${log_dir}
    Log to console	\n Start generating Sos Report
    OperatingSystem.Run    rm ${WTS_DIR}/SosReport*.tgz
    Create Directory    ${log_dir}/
    ${output}=		Run         cd ${WTS_DIR}/ && ${WTS_DIR}/sosReport_ASIK_ASIL.sh
    Wait Until Created	${WTS_DIR}/SosReport*.tgz	timeout=5 minute
    Wait Until Keyword Succeeds    100s    20s	OperatingSystem.Run    mv ${WTS_DIR}/SosReport*.tgz ${log_dir}/

SA Start DL Traffic Internal
    [Arguments]    ${UE_ID}    ${pdu_id}    ${mbps}    ${trf_id}
    Log To Console    start DL traffic...
    ${output}    wtsrunner.trf_data_start    ue=${UE_ID}    pdu=${pdu_id}    dir=dl    mbps=${mbps}
    ...    trf_id=${trf_id}
    sleep    5s

SA Start UL Traffic Internal
    [Arguments]    ${UE_ID}    ${pdu_id}    ${mbps}    ${trf_id}
    Log To Console    start UL traffic...
    ${output}    wtsrunner.trf_data_start    ue=${UE_ID}    pdu=${pdu_id}    dir=ul    mbps=${mbps}
    ...    trf_id=${trf_id}
    sleep    5s


ROHC related counters verification
    admin.teardown_admin    connection=${ADMIN_ALIAS}
    ${webservice}=  Create Dictionary
    ...  host=${bts_ip}
    ...  user=${bts_username}
    ...  password=${bts_password}
    ...  port=${port}
    PM.create PM collector
    ...  name=gnb_pm_counters
    ...  webservice=${webservice}
    ...  for_last=${duration}
    ...  intervals=${interval}
    PM.setup_collectors
    ...  names=gnb_pm_counters
    PM.collect_collectors
    ...  names=gnb_pm_counters     target_dir=${target_dir}
    PM.teardown_collectors
    ...  names=gnb_pm_counters
    admin.setup_admin    bts_host=${bts_ip}    alias=${ADMIN_ALIAS}

ROHC related counters analyser
    @{pi_list}=  Create List    @{DL_NUM_ROHC_COMP_HEADER_CounterList}
    ${pi_dict}=  get_pi_value
    ...  pi_list=${pi_list}
    ...  pi_dir=/home/ute/results/gnb_pm_counters/
    ...  pi_file_pattern=PM*
    Log  ${pi_dict}

    ${log_entry} =    admin.get_pm_counters    counter_ids=${counter_ids}    timeout=100
    ...    connection=${ADMIN_ALIAS}
    log    ${log_entry}

    FOR    ${pi_id}    IN    @{pi_list}
        log    ${pi_id}
        ${count}=    set variable    ${log_entry ['BTS']['MRBTS-${BTS_ID}']['NRBTS-${BTS_ID}']['PDCP2']['${pi_id}']}
        ${a}=    get dictionary values    ${count}
        ${pi_value}=    Set Variable    ${a[-1]}
        Log    ${pi_value}
        Log to console    \nCounter verification
        ${value}=    evaluate    ${pi_value}!=0
        should be true    ${value}
    END

Deregister UEs for Cell1 and Cell2
	[Arguments]    ${UE_ID1}=${1}    ${UE_ID2}=${2}
	wtsrunner.ue_deregister    id=${UE_ID1}
	wtsrunner.ue_deregister    id=${UE_ID2}
	log    UE1 and UE2 de-registered


UE Deregister should be Successful
    [Arguments]    ${ue_id}
    [Documentation]    This keyword checks the message for the UE Deregistration in the output file for the SA variant
    wtsrunner.ue_deregister    id=${ue_id}    ue_deregister_type=switch_off
    Read WTS Output For Pattern And Print matching Lines    ${UE_deregister_pattern}    ${Timeout_SA}
    BuiltIn.Log                ue_deregister_is_ok

Activate reception windows measurement in O-RU object unit (RURXWS)
    ${mrbts_id}=      Get BTS Id
    admin.perform_parameter_recommissioning
    ...    dist_name=MRBTS-${mrbts_id}/MNL-1/MNLENT-1/PMMNL-1
    ...    parameter=miRxWindowStats
    ...    operation=update
    ...    value=5min
    ...    skip_parameter_relation_errors=False
    ...    should_activate=True
    ...    timeout=300
    ...    connection=${ADMIN_ALIAS}

Verify BTS PM counter Result
    ${log_entry} =    admin.get_pm_counters    counter_ids=${counter_ids}    timeout=100    connection=${ADMIN_ALIAS}
    log    ${log_entry}
    FOR    ${pi_id}    IN    @{miRxWindowStats_CounterList}
    log    ${pi_id}
    ${count}=    set variable    ${log_entry ['BTS']['MRBTS-1']['EQM-1']['APEQM-1']['RMOD-1']['RURWS']['${pi_id}']}
    ${a}=    get dictionary values    ${count}
    ${pi_value}=    Set Variable    ${a[-1]}
    Log    ${pi_value}
    ${value}=    evaluate    ${pi_value}!=0
    should be true    ${value}
    END

De-activate RURXWS measurements
    ${mrbts_id}=      Get BTS Id
    admin.perform_parameter_recommissioning
    ...    dist_name=MRBTS-${mrbts_id}/MNL-1/MNLENT-1/PMMNL-1
    ...    parameter=miRxWindowStats
    ...    operation=update
    ...    value=disabled
    ...    skip_parameter_relation_errors=False
    ...    should_activate=True
    ...    timeout=300
    ...    connection=${ADMIN_ALIAS}

Activate TRANSPORT object unit (TRRXWS)
    ${mrbts_id}=      Get BTS Id
    admin.perform_parameter_recommissioning
    ...    dist_name=MRBTS-${mrbts_id}/MNL-1/MNLENT-1/PMMNL-1
    ...    parameter=miTrRxWindowStats
    ...    operation=update
    ...    value=5min
    ...    skip_parameter_relation_errors=False
    ...    should_activate=True
    ...    timeout=300
    ...    connection=${ADMIN_ALIAS}


Verify Transport PM counter Result
    ${log_entry} =    admin.get_counters_info    timeout=100    connection=${ADMIN_ALIAS}
    FOR    ${pi_id}    IN    @{miTrRxWindowStats_CounterList}
    log    ${pi_id}
    ${count}=    set variable    ${log_entry['TRS']['MRBTS-1']['TNLSVC-1']['TNL-2']['ETHSVC-1']['ETHLK-1']['TRRWS']['${pi_id}']}
    ${a}=    get dictionary values    ${count}
    ${pi_value}=    Set Variable    ${a[-1]}
    #${pi_value}=    Set Variable    ${log_entry.get_pi_value(pi_id=${pi_id})}
    Log    ${pi_value}
    ${value}=    evaluate    ${pi_value}!=0
    should be true    ${value}
    END

De-activate TRRXWS measurements
    ${mrbts_id}=      Get BTS Id
    admin.perform_parameter_recommissioning
    ...    dist_name=MRBTS-${mrbts_id}/MNL-1/MNLENT-1/PMMNL-1
    ...    parameter=miTrRxWindowStats
    ...    operation=update
    ...    value=disabled
    ...    skip_parameter_relation_errors=False
    ...    should_activate=True
    ...    timeout=300
    ...    connection=${ADMIN_ALIAS}


Activate transceiver statistics (OTRST)
    ${mrbts_id}=      Get BTS Id
    admin.perform_parameter_recommissioning
    ...    dist_name=MRBTS-${mrbts_id}/MNL-1/MNLENT-1/PMMNL-1
    ...    parameter=miOranTrxStats
    ...    operation=update
    ...    value=5min
    ...    skip_parameter_relation_errors=False
    ...    should_activate=True
    ...    timeout=300
    ...    connection=${ADMIN_ALIAS}

Validate OTRST counter result

    ${log_entry} =    admin.get_pm_counters    counter_ids=${counter_ids}    timeout=100    connection=${ADMIN_ALIAS}
    FOR    ${pi_id}    IN    @{miOranTrxStats_CounterList}
    log    ${pi_id}
    ${count}=    set variable    ${log_entry['BTS']['MRBTS-1']['EQM-1']['APEQM-1']['RMOD-1']['SFP-1']['OTRST'][${pi_id}]}
    ${a}=    get dictionary values    ${count}
    ${pi_value}=    Set Variable    ${a[-1]}
    Log    ${pi_value}
    ${value}=    evaluate    ${pi_value}!=0
    should be true    ${value}
    END

Deactivate the OTRST measurements
    ${mrbts_id}=      Get BTS Id
    admin.perform_parameter_recommissioning
    ...    dist_name=MRBTS-${mrbts_id}/MNL-1/MNLENT-1/PMMNL-1
    ...    parameter=miOranTrxStats
    ...    operation=update
    ...    value=disabled
    ...    skip_parameter_relation_errors=False
    ...    should_activate=True
    ...    timeout=300
    ...    connection=${ADMIN_ALIAS}

Check resource hanging
    [Documentation]  Ask on AAshell resources usages, after end of TC it is expected to have no user resources usage
    ${rc}  ${output} =  Run and Return RC and Output  python /home/ute/hanging.py ${OUTPUT_DIR}
    log to console  Resource hanging: ${output}
	...    /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T07/NR-TDD/hanging.py ${log_path}
    run keyword if  '${rc}'=='1'  log to console  /!\ Warning /!\ It seems resources are hanging. Check for ghost CRNTI
