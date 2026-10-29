*** Settings ***
Documentation     [PURPOSE]
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot


*** Variables ***
#${scm_server}     http://10.42.7.10/builds/enb/base/    # http://files.ute.nsn-rdnet.net/builds/enb/base/
#${resource_path}    D:\\TA_Project\\Testcase\\Trunk\\resources
${Bts_B_name}    PLMN-PLMN/MRBTS-1415
${Bts_B_ip}      10.106.245.139
#${Bts_B_name}    PLMN-PLMN/MRBTS-10034
#${Bts_B_ip}      10.106.243.16
${Bts_C_name}    PLMN-PLMN/MRBTS-10875
${Bts_C_ip}      10.106.205.204
#${Bts_C_name}    PLMN-PLMN/MRBTS-2345
#${Bts_C_ip}      10.106.205.201
${http_port}=    8080
${https_port}=    8443
${security_mode}=  no TLS
${ip_version}=  IPv4


*** Keywords ***
#TD.OM.0240_SW DL_ Activation and SW Config File Upload for a Single eNB
#    [Arguments]    ${release}
#    ${release_list}    get enb    ${release}
#    #${release_list[-1]}    set variable    SBTS00_ENB_9999_210515_000011
#    set test variable    ${release_list[-1]}
#    ${full_path}    Download_Specify_Build_By_Aria    ${release_list[-1]}    Basic
#    Put_buid_from_local_to_netact    ${full_path}    ${release_list[-1]}    ${release_NUM}
#    set test variable    ${sw_release}    ${release_list[-1]}
#    import sw to netact    ${sw_release_changed}
#	${sw_release}    set variable    ${sw_release_changed}
#	set test variable    ${sw_release}
#    Wait Until Keyword Succeeds    40 min    30    _do SW provision from NetAct
#    sleep    10 min
#    Wait Until Keyword Succeeds    30min    30 sec    Check BTS Is Onair With Infomodel
#    _check SW version after provision

#_do SW provision from NetAct
#    Setup Ta Netact Swm Operations    web_url=${NETACT_SERVER_INFO.URL}
#                                 ...  web_user=${NETACT_SERVER_INFO.USERNAME}
#                                 ...  web_pass=${NETACT_SERVER_INFO.PASSWORD}
#                                 ...  was_host=${NETACT_SERVER_INFO.IP}
#                                 ...  was_ssh_user=${NETACT_SERVER_INFO.USERNAME}
#                                 ...  was_ssh_pass=${NETACT_SERVER_INFO.PASSWORD}
#    ${log}    Swm Provision    ${BTS_INFO.MRBTS}    ${sw_release}
#    Should Contain    ${log}    SUCCESS
#    [Teardown]    Teardown Ta Netact Swm Operations

_check SW version after provision
    [Documentation]    Short description.
    Setup eNB Fsm Access    alias=default
    ${active_version_after}=    Get Enb Sw Version    active    alias=default
    Teardown Enb Fsm Access    alias=default
    ${release_name}    Get Substring    ${sw_release}    12
    Should Contain    ${active_version_after}    ${release_name}

TD.OM.0228_Manual SW Configuration Upload
    [Documentation]    Short description.
    Comment    Wireshark Capture Log
    Wait Until Keyword Succeeds    1 min    30    _execute upload
    Comment    ${localLogPath}    Wireshark Stop Log    #stop wireshark for check wireshark log
    Comment    _check ws log    ${localLogPath}

_execute upload
    [Documentation]    Short description.
    Setup Ta Netact Swm Operations    ${NETACT_SERVER_INFO.URL}    ${NETACT_SERVER_INFO.USERNAME}
    ...  ${NETACT_SERVER_INFO.PASSWORD}
    ${log}    Swm Upload    ${BTS_INFO.MRBTS}
    Should Contain    ${log}    SUCCESS
    [Teardown]    Teardown Ta Netact Swm Operations

_check ws log
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${localLogPath}: <description>
    [Arguments]    ${localLogPath}
    ${retFilePath}    Common Transform Wireshark to Txt    ${localLogPath}
    ...  giop.request_op contains "sw" or om.messageType==3 or om.messageType==4
    Common_Analyze The Logs with A2A    ${CURDIR}${/}A2A_6550228${/}A2A.ini

CB009469.TD.OM.LTE655_05_11_01_Remote_mass_eNB_Rollback_request
    [Documentation]    Short description.
    Verify BTS states
    _precondition LTE655 0511_01
    Comment    Wireshark Capture Log
    Change parameter actSWRollbackReject with true
    sleep    15s
    Check rollback status
    Change parameter actSWRollbackReject with false
    sleep    15s
    Wait Until Keyword Succeeds    30 min    30    _do rollback from netact
    set test variable    ${rollback_expected_time}    900
    Operation_KPI_Check   ${sw_rollback_A_end}    ${sw_rollback_A_start}   ${rollback_expected_time}
    ...  SW_ROLLBACK_BTS_KPI
    sleep    5 min    #wait for rollback finish
    _wait until onAir for both bts
    _check SW version after rollback_01
    _precheck SW for Sw rollback by admin
    _Sw rollback by admin
    _check SW version after rollback_02
    Comment    ${localLogPath}    Wireshark Stop Log    #stop wireshark for check wireshark log
    Comment    _check ws log    ${localLogPath}    A2A_6550511_01

_precondition LTE655 0511_01
    [Documentation]    Short description.
    Setup eNB Fsm Access
    ${btsA_active_version}    Get Enb Sw Version    active
    ${btsA_passive_version}    Get Enb Sw Version    passive
    set test variable    ${btsA_active_version}
    set test variable    ${btsA_passive_version}
    Teardown eNB Fsm Access
    ${btsB_active_version}    Get active SW version by IP    ${Bts_B_ip}
    set Test Variable    ${btsB_active_version}
    ${btsB_passive_version}    Get Passive SW Version by IP    ${Bts_B_ip}
    set Test Variable    ${btsB_passive_version}
    _wait until onAir for both bts

_precheck SW for Sw rollback by admin
    [Documentation]    Short description.
    Setup eNB Fsm Access
    ${btsA_active_version_2}    Get Enb Sw Version    active
    Set Test Variable    ${btsA_active_version_2}
    ${btsA_passive_version_2}    Get Enb Sw Version    passive
    Set Test Variable    ${btsA_passive_version_2}
    Teardown eNB Fsm Access

_wait until onAir for both bts
    [Documentation]    Short description.
    Wait for target to be reachable  hostname=192.168.255.129  timeout=300
    Wait for target to be reachable  hostname=${Bts_B_ip}  timeout=300
    Verify BTS status for all models and cells
    Wait Until Keyword Succeeds    10 min    30 sec    _Check BTS Status By Admin    onair    ${Bts_B_ip}

_wait until onAir for both bts_CB007425
    [Documentation]    Short description.
    Wait for target to be reachable  hostname=192.168.255.129  timeout=300
    Wait for target to be reachable  hostname=${Bts_C_ip}  timeout=300
    Verify BTS status for all models and cells
    Wait Until Keyword Succeeds    10 min    30 sec    _Check BTS Status By Admin    onair    ${Bts_C_ip}

_do rollback from netact
    [Documentation]    Short description.
    taf.nms.netact.Add Node    cmwas    ${NETACT_SERVER_INFO.IP}    ${NETACT_SERVER_INFO.USERNAME}
    ...  ${NETACT_SERVER_INFO.PASSWORD}    alias=ta_netact
    ${sw_rollback_A_start}    Get Current Date
    ${status_A}=    taf.nms.netact.rollback_sw    PLMN-PLMN/${BTS_INFO.MRBTS}    alias=ta_netact
    ${sw_rollback_A_end}    Get Current Date
    set test variable    ${sw_rollback_A_start}
    set test variable    ${sw_rollback_A_end}
    ${operation_B}=    taf.nms.netact.Start SWM Operation     operation_type=rollback    dist_names=${Bts_B_name}
    ...  package=${btsB_active_version}    alias=ta_netact
    ${progress}=    taf.nms.netact.Get Progress Of SWM Operation    ${operation_B}    alias=ta_netact
    Log    \nProgress: ${progress}    console=${TRUE}
    taf.nms.netact.Wait For SWM Operation    ${operation_B}    timeout=1800    alias=ta_netact
    [Teardown]    taf.nms.netact.Clean All    alias=ta_netact

_check SW version after rollback_01
    [Documentation]    Short description.
    Setup eNB Fsm Access
    ${btsA_active_version_after}    Get Enb Sw Version    active
    ${btsA_passive_version_after}    Get Enb Sw Version    passive
    Should Be Equal    ${btsA_active_version_after}    ${btsA_passive_version}
    Should Be Equal    ${btsA_passive_version_after}    ${btsA_active_version}
    Teardown eNB Fsm Access
    ${btsB_active_version_after}    Get active SW version by IP    ${Bts_B_ip}
    Should Be Equal    ${btsB_active_version_after}    ${btsB_passive_version}
    ${btsB_passive_version_after}    Get Passive SW Version by IP    ${Bts_B_ip}
    Should Be Equal    ${btsB_passive_version_after}    ${btsB_active_version}

_check SW version after rollback_02
    [Documentation]    Short description.
    Setup eNB Fsm Access
    ${btsA_active_version_after}    Get Enb Sw Version    active
    ${btsA_passive_version_after}    Get Enb Sw Version    passive
    Should Be Equal    ${btsA_active_version_after}    ${btsA_passive_version_2}
    Should Be Equal    ${btsA_passive_version_after}    ${btsA_active_version_2}
    Teardown eNB Fsm Access

_recover env
    [Documentation]    Short description.
    Start Admin
    taf.sbts.oam.coam.admin.rollback_software    timeout=15min    alias=default
    Teardown Infomodel
    Start Admin    ${Bts_B_ip}
    taf.sbts.oam.coam.admin.rollback_software    timeout=15min    alias=default
    Teardown Infomodel

Import build to Netact
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${build_version}: <description>
    [Arguments]   ${build_version}
    ${release_NUM}    Fetch from left    ${build_version}    _
    ${full_path}    Download_Specify_Build_By_Aria    ${build_version}    Basic
    Put_buid_from_local_to_netact    ${full_path}    ${build_version}    ${release_NUM}
    set test variable    ${sw_release}    ${build_version}
    _import sw to netact     ${sw_release_changed}

CB009469.TD.OM.LTE655_05_10_NE triggered SW Download and Activation
    [Documentation]    precondition: passive distriction enb version must be old.
	Verify BTS states
	${sw_release}=    Get Active BTS Version
	set test variable    ${sw_release}
    ${release_version}    Fetch from left    ${sw_release}    _
    set test variable    ${release_version}
    ${release_NUM}=    should match regexp    ${sw_release}    SBTS\\d+..
    set test variable    ${release_NUM}
    ${build_version}    Run keyword If    '000000'in'${sw_release}'    set variable    ${sw_release}
    ...    ELSE IF    '9999'in'${sw_release}'    Replace String Using Regexp
    ...  ${sw_release}    SBTS[0-9][0-9][A-Z][0-9]?_    SBTS00_
    _Get Scf By Admin    /home/ute/BACK_SCF.xml
    Log  Check build in Netact otherwise Import
    ${Mid_Server}  ${Mid_Server_usr}  ${Mid_Server_pwd}=  Choose_Mid_Server4Netact  ${NETACT_SERVER_INFO.IP}
    build_download_upload_on_remote_server_and_import_to_Netact  target_sw=${sw_release}
                                                            ...  release_NUM=${release_NUM}
                                                            ...  remote_ip=${Mid_Server}
                                                            ...  remote_usr=${Mid_Server_usr}
                                                            ...  remote_pwd=${Mid_Server_pwd}
    Start Admin
    ${ru_ids}=    taf.sbts.oam.coam.admin.Get ids for all    RMOD    alias=default
    set test variable    ${ru_ids}
    taf.sbts.oam.coam.admin.Reset configuration    True    True    timeout=900    alias=default
    #disable_ethernet_port_security    timeout=300    alias=default
    Stop Admin
    _Wait Until FCT Ping Ok By Admin
	${Downgrade_list}    get enb    SBTS22R2
    ${Download_full_path}    Download_Specify_Build_By_Aria    ${Downgrade_list[-1]}    Basic
    #${target_release}    Fetch from right    ${build_version}    _
    #sleep    10min
	CNI_Infomodel_Adapter
	Wait RRU online
    Start Admin
    #sleep    5min
    taf.sbts.oam.coam.admin.update software    ${Download_full_path}    True    timeout=1800    alias=default
    Stop Admin
    linux_ping.wait_until_ping_failed    192.168.255.1     timeout=300
    linux_ping.Wait Until Ping Success    192.168.255.1     timeout=300
    Restore login by json removal from BTS_LTE
    _Wait Until FCT Ping Ok By Admin
	BuiltIn.Wait Until Keyword Succeeds    15min    30s    _Perform Full Commision By Admin
	...  /home/ute/testline_configuration/3_5_CLOUD665/node1/BTS_CLOUD_RF_AIL_B1_AZNB_Oper2_CRT2572_SBTS22R2.xml
    Verify BTS status for all models and cells
    taf.hw.pdu.Power Off    ${RRU2_INFO.POWERBREAK_IP }    ${RRU2_INFO.POWERBREAK_PORT}
    taf.hw.pdu.Power Off    ${RRU1_INFO.POWERBREAK_IP }    ${RRU1_INFO.POWERBREAK_PORT}
    Wait Until Keyword Succeeds    15 min    30    _Sw rollback by admin
	linux_ping.wait_until_ping_failed    ${BTS_LOCAL_INFO.FTM_IP}    timeout=600
    _Wait Until FCT Ping Ok By Admin
    sleep    3min
    BuiltIn.Wait Until Keyword Succeeds    15min    30s    _Perform Full Commision By Admin    /home/ute/BACK_SCF.xml
	${result}=    Integrate And Check NE Status
	Run keyword if    '${result}'=='FAIL'    Repair The NE3S And Integrate And Check BTS
    taf.hw.pdu.Power On    ${RRU2_INFO.POWERBREAK_IP }    ${RRU2_INFO.POWERBREAK_PORT}
    sleep    150s
    taf.hw.pdu.Power On    ${RRU1_INFO.POWERBREAK_IP }    ${RRU1_INFO.POWERBREAK_PORT}
    Start Admin    alias=default
    taf.sbts.oam.coam.admin.Get Active Alarms    alias=default
    Stop Admin
	${cmd}    Set Variable    tcpdump -i any -s 0 -n -nn ip host 10.108.151.128 -w /tmp/655_1.cap &
	${BTS_Connection_cpature}=    ta_ssh_telnet.connect to host    192.168.255.1    22    username=toor4nsn
	...  password=oZPS0POrRieRtu    conn_type=ssh    timeout=60s
    Set Shell Prompt    >
	set shell timeout    1h
    Run Keyword And Ignore Error    Execute Shell Command    ${cmd}
    Wait Until Keyword Succeeds    10min    5    _Check Exist Fault By Admin
    ...  fault_name=Incompatible SW version detected    fault_id=23
    ${HW_Enalbe_Start}    Get Current Date
	Run Keyword And Ignore Error    Switch Host Connection    ${BTS_Connection_cpature}
    Wait Until Keyword Succeeds    10min    10    _Check No Exist Fault By Admin
    ...  fault_name=Incompatible SW version detected    fault_id=23    fault_serverity=Critical
    ${HW_Enable_End}    Get Current Date
    Operation_KPI_Check    ${HW_Enable_End}    ${HW_Enalbe_Start}    300    Maximum_Duration_HW Enabling_KPI
    Verify BTS status for all models and cells
#_check provision triggered by NE
#    Precondition Netact with TAF
#	${output}    taf.nms.netact.Get Mo Status    dist_names=PLMN-PLMN/${BTS_INFO.MRBTS}    root_password=arthur
#    log    ${output}
#    ${result}    Get From Dictionary    ${output}    PLMN-PLMN/${BTS_INFO.MRBTS}
#    ${last_sw_op}    Get From Dictionary    ${result}    last_sw_op
#    Should Be Equal    ${last_sw_op}    SWProvision
#    ${last_op_status}    Get From Dictionary    ${result}    last_op_status
#    Should Be Equal    ${last_op_status}    SUCCESS
#    #[Teardown]    Teardown Ta Netact Swm Operations
#	[Teardown]    Postcondition Netact with TAF

TD.OM.LTE655_05_10_NE triggered SW Download and Activation_4934
    [Documentation]    precondition: passive distriction enb version must be old.
	Verify BTS states
	${sw_release}=    Get Active BTS Version
	set test variable    ${sw_release}
    ${release_version}    Fetch from left    ${sw_release}    _
    ${build_version}    Run keyword If    '000000'in'${sw_release}'    set variable    ${sw_release}
    ...    ELSE IF    '9999'in'${sw_release}'    Replace String Using Regexp
    ...  ${sw_release}    SBTS[0-3][0-3][A-C]_    SBTS00_
    ${full_path}    Download_Specify_Build_By_Aria    ${build_version}    Basic
    Put_buid_from_local_to_netact    ${full_path}    ${build_version}    ${release_NUM}
    set test variable    ${sw_release}    ${build_version}
    _import sw to netact     ${sw_release_changed}
    _Get Scf By Admin    /home/ute/BACK_SCF.xml
    Start Admin
    taf.sbts.oam.coam.admin.Reset configuration    True    True    timeout=800    alias=default
    Stop Admin
    _Wait Until FCT Ping Ok By Admin
	${Downgrade_list}    get enb    SBTS22R1
    ${Download_full_path}    Download_Specify_Build_By_Aria    ${Downgrade_list[-1]}    Basic
    Put_buid_from_local_to_netact    ${Download_full_path}    ${Downgrade_list[-1]}    SBTS22R1
    set test variable    ${sw_release}    ${Downgrade_list[-1]}
    _import sw to netact     ${sw_release_changed}
    sleep    5min
	Wait RRU online
    Start Admin
    taf.sbts.oam.coam.admin.update software    ${Download_full_path}    True    timeout=1800    alias=default
    Stop Admin
    _Wait Until FCT Ping Ok By Admin
    Restore login by json removal from BTS_LTE
    BuiltIn.Wait Until Keyword Succeeds    15min    30s    _Perform Full Commision By Admin
    ...  /home/ute/testline_configuration/3_5_CLOUD665/node1/BTS_CLOUD_RF_AIL_B1_AZNB_Oper2_CRT2572_SBTS22R1.xml
	Wait Until Keyword Succeeds    25min    5s    _Check Exist Fault By Admin
	...  fault_name=Incompatible SW version detected    fault_id=23
	Log    Start to update the same package to clear fault23, netact will provision the build automatically.
	${result}=    Integrate And Check NE Status
	Run keyword if    '${result}'=='PASS'    Verify BTS status for all models and cells
	Run keyword if    '${result}'=='FAIL'    Repair The NE3S And Integrate And Check BTS
	Log    Provision need a long time, so onair need check many times
	Verify BTS status for all models and cells
    taf.hw.pdu.Power Off    ${RRU1_INFO.POWERBREAK_IP }    ${RRU1_INFO.POWERBREAK_PORT}
    Wait Until Keyword Succeeds    15 min    30    _Sw rollback by admin
	linux_ping.wait_until_ping_failed    ${BTS_LOCAL_INFO.FTM_IP}    timeout=600
    _Wait Until FCT Ping Ok By Admin
    taf.hw.pdu.Power On    ${RRU1_INFO.POWERBREAK_IP }    ${RRU1_INFO.POWERBREAK_PORT}
    Wait Until Keyword Succeeds    30min    10    _Perform Full Commision By Admin    ${TEST_LOG_DIR}${/}BACK_SCF.xml
    Start Admin    alias=default
    taf.sbts.oam.coam.admin.Get Active Alarms    alias=default
    Stop Admin
    Wait Until Keyword Succeeds    15min    5    _Check Exist Fault By Admin
    ...  fault_name=Incompatible SW version detected    fault_id=23
    Wait Until Keyword Succeeds    10min    10    _Check No Exist Fault By Admin
    ...  fault_name=Incompatible SW version detected    fault_id=23    fault_serverity=Critical
    Verify BTS status for all models and cells

Restore login by json removal from BTS_LTE
    [Documentation]
    ...    Removes content of /ffs/run/config/users.json on BTS and performes reset
    Log    Restore login will be done by removal /ffs/run/config/users.json file    console=${TRUE}
    SSHLibrary.Open connection    192.168.255.1
    SSHLibrary.Login    toor4nsn    oZPS0POrRieRtu
    ${result1}=    Run keyword and ignore error    SSHLibrary.Execute Command    rm -rf /ffs/run/config/users.json
    ${result2}=   Run keyword and ignore error    SSHLibrary.Execute Command    reboot
    SSHLibrary.Close Connection
    linux_ping.wait_until_ping_failed      192.168.255.1      timeout=120
    linux_ping.Wait Until Ping Success    192.168.255.1     timeout=300

Integrate And Check NE Status
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${status}: <description>
    ${MRBTS_MO_DIST_NAME}    set variable    PLMN-PLMN/MRBTS-${BTS_INFO.ID}
    ${MRBTS_MO_ADDRESS}    set variable      ${BTS_INFO.IP}
    Precondition Netact with TAF
    ${MRBTS_MO_MR}=    Run Keyword If    '${NETACT_SERVER_INFO.IP}' == '10.110.144.154'
    ...  set variable    MRC-5GSC_HZ/MR-5GSC_HZ
	...    ELSE IF    '${NETACT_SERVER_INFO.IP}' == '10.107.183.26'    set variable    MRC-5GSC-HZ/MR-5GSC-HZ
	...    ELSE    set variable    MRC-COMMON/MR-COMMON
    ${status}   ${integration_output}=  Run keyword and ignore error    taf.nms.netact.Integrate MRBTS With Netact
    ...  release=${release_NUM}  mr=${MRBTS_MO_MR}  mrbts_address=${MRBTS_MO_ADDRESS}  dist_name=${MRBTS_MO_DIST_NAME}
    ...  http_port=${http_port}  https_port=${https_port}  ip_version=${ip_version}  security_mode=${security_mode}
    Log  \n${integration_output}  console=${TRUE}
    Postcondition Netact with TAF
    [Return]    ${status}

Repair The NE3S And Integrate And Check BTS
    [Documentation]    Short description.
    connect to host    host=192.168.255.129    port=22    username=toor4nsn
    ...  password=oZPS0POrRieRtu    conn_type=SSH
    Run keyword and ignore error    ta_ssh_telnet.Execute Shell Command
    ...  rm /ffs/run/config/ne3sadapt/configs/ne3sadaptdata.db
    Start Admin
    taf.sbts.oam.coam.admin.Reset Site    timeout=300    alias=default
    Stop Admin
    Sleep    3min
    ${status}=    Integrate And Check NE Status
    #Run keyword if    '${status}'=='PASS'    Verify BTS states
    Run keyword if    '${status}'=='Fail'    Log    repair or integrate failed.

Get object with expected states
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${RMOD_expected_states}: <description>
    ...        ${class name}: <description>
    ...
    ...    Returns:
    ...        ${status}: <description>
	[Arguments]    ${RMOD_expected_states}    ${class name}
	${RMOD_expected_states}  set variable   operationalState=${_Enabled},administrativeState=Unlocked,usageState=Idle
	Start Admin    alias=verify_obj
	${class_ids}=    taf.sbts.oam.coam.admin.Get ids for all    ${class name}    alias=verify_obj
	${matching_objects}=    Create list
	${matching_status}=    Create list
	FOR    ${item_id}    in    @{class_ids}
	   ${status}    ${item parameters}    run keyword and ignore error    Assert    ${class name}
	    ...  ${item_id}    ${RMOD_expected_states}    timeout=30    alias=verify_obj
		Run keyword if    '${status}'=='PASS'    Run keywords    Append to list    ${matching_objects}
	    ...  ${item parameters}    AND    Append to list    ${matching_status}    PASS
		${status}    ${item parameters}    run keyword if    '${status}'=='FAIL'   run keyword and ignore error
	    ...  Assert    ${class name}    ${item_id}    availabilityStatus=NotInstalled  timeout=20
		Run keyword if    '${status}'=='FAIL'    Append to list    ${matching_status}    'FAIL'
	END
	#${status}=    evaluate   "FAIL"   if "len(${class_ids})!=0" and "FAIL" in "${matching_status}" else "PASS"
	Log To Console     ${ru_ids}
	${bool_1}=         Evaluate      len(${class_ids})==len(${ru_ids})
	${bool_2}=         Evaluate      'FAIL' not in ${matching_status}
	Log To Console     ${bool_1},${bool_2}
	${status}=    set variable if    ${bool_1} and ${bool_2}   'PASS'  'FAIL'
	stop admin
	[Return]     ${status}

Wait RRU online
    [Documentation]    Short description.
	FOR    ${index}    IN RANGE    1    60
		${status}=    Get object with expected states    ${RMOD_expected_states}    RMOD
		Run keyword if    ${status}=='PASS'    exit for loop
    END

Change parameter actSWRollbackReject with true
    [Documentation]    Short description.
    Teardown Infomodel
    Setup Admin for BTS
    taf.sbts.oam.coam.admin.Perform Parameter Recommissioning
    ...  dist_name=MRBTS-${BTS_INFO.ID}/MNL-1/MNLENT-1/FEATCADM-1  parameter=actSWRollbackReject
    ...  operation=update  value=true
    ...  skip_parameter_relation_errors=True  should_activate=True  alias=default

Change parameter actSWRollbackReject with false
    [Documentation]    Short description.
    taf.sbts.oam.coam.admin.Perform Parameter Recommissioning
    ...  dist_name=MRBTS-${BTS_INFO.ID}/MNL-1/MNLENT-1/FEATCADM-1  parameter=actSWRollbackReject
    ...  operation=update  value=false
    ...  skip_parameter_relation_errors=True  should_activate=True  alias=default

Check rollback status
    [Documentation]    Short description.
    taf.nms.netact.Add Node    cmwas    ${NETACT_SERVER_INFO.IP}    ${NETACT_SERVER_INFO.USERNAME}
    ...  ${NETACT_SERVER_INFO.PASSWORD}    alias=ta_netact
    ${status_rollback}=    Run Keyword And Ignore Error    taf.nms.netact.rollback_sw    PLMN-PLMN/${BTS_INFO.MRBTS}    alias=ta_netact
    Should Be Equal    '${status_rollback}'    '('FAIL', 'SWMOperationFailedException: Status: FAILED')'

Get active SW version by IP
    [Arguments]    ${bts_ip}=192.168.255.129
    [Documentation]    Get the active SW version info of the BTS
    connect to host    host=${bts_ip}    port=22    username=toor4nsn    password=oZPS0POrRieRtu    conn_type=SSH
    Set Shell Prompt    >
    Execute Shell Command    cd /ffs/run
    ${targetBD}=    Execute Shell Command    ls TargetBD*.xml
    log    ${targetBD}
    ${targetBD}    Get Line    ${targetBD}    0
    ${active_build}    Fetch From Right    ${targetBD}    TargetBD_
    ${active_build}    Fetch From Left    ${active_build}    .xml
    Disconnect From Host
    [Return]    ${active_build}

Get Passive SW Version by IP
    [Arguments]    ${bts_ip}=192.168.255.129
    [Documentation]    Get the passive SW version info of the BTS
    connect to host    host=${bts_ip}    port=22    username=toor4nsn    password=oZPS0POrRieRtu    conn_type=SSH
    Set Shell Prompt    >
    Execute Shell Command    cd /ffs/stb
    ${targetBD}=    Execute Shell Command    ls TargetBD*.xml
    log    ${targetBD}
    ${targetBD}    Get Line    ${targetBD}    0
    ${passive_build}    Fetch From Right    ${targetBD}    TargetBD_
    ${passive_build}    Fetch From Left    ${passive_build}    .xml
	Disconnect From Host
    [Return]    ${passive_build}

_Check BTS Status By Admin
    [Arguments]    ${status}    ${host}=${BTS_LOCAL_INFO.FTM_IP}
    [Documentation]    | _Check BTS Status By Admin | onair|
    @{list}    Split String    ${status}    ${Empty}
    ${len}    Get Length    ${list}
    ${status}    Set Variable If    ${len}>1    ${list[0]}${list[1]}    ${status}
    ${im_status}    Set Variable If    '${status.lower()}'=='onair'    OnAir    '${status.lower()}'=='integrated'
    ...  integrated to RAN    '${status.lower()}'=='configured'
    ...    Configured    ${status}
    Setup Admin for BTS    ${host}
    ${lnbts_state}    taf.sbts.oam.coam.admin.Get Mrbts State    alias=default
    Should Be Equal As Strings    ${lnbts_state}    ${im_status}
    [Teardown]    taf.sbts.oam.coam.admin.Teardown All Aliases For Admin

_Sw rollback by admin
    [Documentation]    Short description.
    taf.sbts.oam.coam.admin.Teardown All Aliases For Admin
    Setup Admin for BTS
    Setup eNB Fsm Access
    taf.sbts.oam.coam.admin.rollback_software    timeout=20min    alias=default
    Teardown eNB Fsm Access
    sleep    5min
    Verify BTS status for all models and cells
#    [Teardown]    Teardown All Aliases For Admin

Verify BTS status
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${expected_BTS_status}: <description>
    ...        ${modules_check}: <description>
    ...        ${cells_check}: <description>
    ...        ${alarms_check}: <description>
    ...        ${expected_alarms}: <description>
    ...        ${ignored_alarms}: <description>
    ...        ${critical_alarms}: <description>
    ...        ${BTS_state_is_correct}: <description>
    ...        ${system_modules_working}: <description>
    ...        ${radio_modules_working}: <description>
    ...        ${cells_GSM_onair}: <description>
    ...        ${cells_WCDMA_onair}: <description>
    ...        ${cells_LTE_onair}: <description>
    ...        ${alarms_status}: <description>
    ...
    ...    Returns:
    ...        ${BTS_current_status_expect}: <description>
    [Arguments]    ${expected_BTS_status}=OnAir    ${modules_check}=${TRUE}    ${cells_check}=${TRUE}
    ...  ${alarms_check}=${TRUE}    ${expected_alarms}=@{EMPTY}    ${ignored_alarms}=@{EMPTY}
    ...  ${critical_alarms}=@{EMPTY}    ${BTS_state_is_correct}=${FALSE}    ${system_modules_working}=${FALSE}
    ...  ${radio_modules_working}=${FALSE}    ${cells_GSM_onair}=${FALSE}    ${cells_WCDMA_onair}=${FALSE}
    ...  ${cells_LTE_onair}=${FALSE}    ${alarms_status}=FAIL
    ${BTS_state_is_correct}    ${BTS_current_status}=    Verify BTS proceduralState    ${expected_BTS_status}
    ${system_modules_working}=    Run Keyword If    ${modules_check}    Verify system modules states
    ...    ELSE    Set Variable    ${TRUE}
    ${radio_modules_working}=    Run Keyword If    ${modules_check}    Verify radio modules states
    ...    ELSE    Set Variable    ${TRUE}
    ${alds_working}=    Run Keyword If    ${modules_check}    Verify ald states
    ...    ELSE    Set Variable    ${TRUE}
    ${cells_GSM_onair}=    Run Keyword If    ${cells_check}    Verify GSM cells states
    ...    ELSE    Set Variable    ${TRUE}
    ${cells_WCDMA_onair}=    Run Keyword If    ${cells_check}    Verify WCDMA cells states
    ...    ELSE    Set Variable    ${TRUE}
    ${cells_LTE_onair}=    Run Keyword If    ${cells_check}    Verify LTE cells states
    ...    ELSE    Set Variable    ${TRUE}
    ${cells_NR_onair}=    Run Keyword If    ${cells_check} and ${SCF_NR}    Verify NR cells states
    ...    ELSE    Set Variable    ${TRUE}
    ${ALL_AVAILABLE_CELLS}=    Run keyword if     '${SCF_NR}'=='False'    Admin Get ids for all cells
    ...    ELSE    Admin Get ids for all cells TAF
    Set test variable    ${ALL_AVAILABLE_CELLS}
    ${alarms_status}    ${alarms_msg}=    Run Keyword If    ${alarms_check}
    ...  Run Keyword And Ignore Error    Admin Check Active Alarms    expected_patterns=${expected_alarms}
    ...  ignored_patterns=${ignored_alarms}    critical_patterns=${critical_alarms}
    Run keyword if    '${alarms_status}'=='FAIL'
    ...  Log    Critical fail while checking alarms: ${alarms_msg}    console=${TRUE}
    ...    ELSE IF    ${alarms_msg}    Set test restriction    Unexpected alarms are present: ${alarms_msg}
    ${statuses_dictionary}=    Create Dictionary
    ...  BTS_state_is_correct=${BTS_state_is_correct}    system_modules_working=${system_modules_working}
    ...  radio_modules_working=${radio_modules_working}    alds_working=${alds_working}
    ...  cells_GSM_onair=${cells_GSM_onair}    cells_WCDMA_onair=${cells_WCDMA_onair}
    ...  cells_LTE_onair=${cells_LTE_onair}    alarms_status=${alarms_status}
    ${pretty_statuses}=    Evaluate    pprint.pformat(${statuses_dictionary}, indent=4)    modules=pprint
    ${cells_count_status}=    Run Keyword And Return Status    should be empty    ${ALL_AVAILABLE_CELLS}
    Set Test Variable    ${states_bool}      ${BTS_state_is_correct} and ${system_modules_working}
    Set Test Variable    ${states_bool2}     ${radio_modules_working} and ${cells_GSM_onair} and ${cells_WCDMA_onair}
    Run Keyword If
    ...  ${states_bool} and ${states_bool2} and ${cells_LTE_onair} and ${alds_working} and '${alarms_status}'!='FAIL'
    ...  Set Test Variable    ${BTS_current_status_expect}    ${TRUE}
    ...  ELSE
    ...  Set Test Variable    ${BTS_current_status_expect}    False
    ${BTS_current_status_expect}=    Convert To Boolean       ${BTS_current_status_expect}
    [Return]    ${BTS_current_status_expect}

Verify BTS status for all models and cells
    [Documentation]    Short description.
	FOR    ${index}    IN RANGE    1    20
	   sleep    30 s
	   taf.sbts.oam.coam.admin.Teardown All Aliases For Admin
	   Setup Admin for BTS
		${status}=    Verify BTS status
		Run keyword if    ${status}==True    exit for loop
    END

Setup Admin for BTS
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${bts_host}: <description>
    ...        ${bts_port}: <description>
    ...        ${username}: <description>
    ...        ${password}: <description>
    ...        ${use_ssl}: <description>
    ...        ${alias}: <description>
    [Arguments]    ${bts_host}=192.168.255.1    ${bts_port}=443    ${username}=Nemuadmin
    ...  ${password}=nemuuser    ${use_ssl}=TRUE    ${alias}=default
    Wait Until Keyword Succeeds    1 min    15 sec
    ...  taf.sbts.oam.coam.admin.Setup Admin    bts_host=${bts_host}    bts_port=${bts_port}    username=${username}
    ...  password=${password}    use_ssl=${use_ssl}    alias=${alias}    update_interval=1000
    ...  admin_api_log_dir=${BTSFiles}/
