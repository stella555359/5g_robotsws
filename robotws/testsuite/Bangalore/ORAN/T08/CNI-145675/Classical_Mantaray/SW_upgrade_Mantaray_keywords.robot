*** Settings ***
Documentation
...   author: T08
...   contact: Veena
...   Description: SW upgrade via Mantaray_keywords

Library    String
Library    Collections
Library     DateTime
Library    taf.collectors.core    WITH NAME    core
Library    taf.nms.netact
Library    taf.sbts.oam.coam.admin     WITH NAME     COAM
Library    OperatingSystem     WITH NAME    os
Library     taf.sw.dcap.rd    WITH NAME    rd
Library     taf.ul.alarms_watchdog   WITH NAME    alarm
Resource    taf/rfrl/common_resources/common_step/interface.robot
Library     ./testsuite/Bangalore/ORAN/resources/python/downloadwftpackage.py

*** Variables ***
${connection}=    admin1
${OUT_LOG_PATH}=    /home/ute/results
${web_url}=     https://${NETACT_NAME}lbwas.srnblr.nsn-rdnet.net/authentication/Login
${NETACT_NAME}=    srnclab1042
${web_user}=    test2
${web_pwd}=    Qwer_1234
${bts_ip}=      192.168.255.129
${PATH}=       /home/ute/logs
${Folder}=    SW_mantaray
${DCAP_host}       10.41.209.114
${ssh_port}    443
${rd_version}     dcapv3
${secure}       True
${fm_cm_itsmwas_hostIp}=   	10.43.48.16
${node_Username_fmwas}=	        omc
${node_password_fmwas}=         Medsql!_1893
${script_path}=    /home/ute/robotws/testsuite/Bangalore/ORAN/T07/Mantaray_scripts
${SBTS_build}=    SBTS00_GNB_9999_250703_000006
${target_build_name}=    SBTS00_ENB_9999_250707_000004
${mo_id}=     PLMN-PLMN/MRBTS-931

*** Keywords ***
Suite Setup
    Log to console    \n--Test Setup--\n
    COAM.setup_admin    bts_host=${bts_IP}    alias=${connection}
    ${BTS_details}      COAM.get_bts_info       connection=${connection}
    ${sw_info}=    get_sw_version     connection=${connection}
    ${CurrentDate}=    Get Current Date    result_format=%d_%m_%Y_%H%M
    ${CurrentDate}=    Convert to String     ${CurrentDate}
    os.Create Directory    ${PATH}/${SUITE NAME}/${CurrentDate}
    Set global variable    ${Date}    ${CurrentDate}
    os.Create Directory    ${OUT_LOG_PATH}/${SUITE NAME}/${CurrentDate}
    Set suite Variable     ${sw_info}
    Log    ${sw_info}
    Set global variable    ${BTS_ID}     ${BTS_details['mrbtsID']}
    Set global variable    ${dist_name}    MRBTS-${BTS_ID}/NRBTS-${BTS_ID}
    Set global variable    ${Cell2_dist}    MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-2
    Set global variable    ${NRDU_dist}    MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRDU-1
    Set global variable    ${NRREL1_dist}    MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCEL-3/NRREL-6
    ${Active_alarm}    COAM.get_active_alarms    connection=${connection}
    LOG     ${Active_alarm}
    ${allowed_alarms}    Expected alarm
    #alarm.Watch alarms    allowed_alarms=${allowed_alarms}        connection=${connection}
    #...    reconnect=true    log_dir=/tmp
    create testcase folder    ${testcase_name}
    Create dcap session

Suite Teardown
    Assert Mrbts Is In Onair State
    ${Active_alarm}    COAM.get_active_alarms    connection=${connection}
    LOG     ${Active_alarm}
    alarm.stop_watching_alarms
    COAM.teardown_all_aliases_for_admin
    interface.Common step trigger
	Check resource hanging
    Log to console  /n -- End of Test --/n

Setup_netact
    Log to console   \n--Setup_netact--\n
    taf.nms.netact.Add WEB URL    ${web_url}    ${web_user}    ${web_pwd}    alias=Netact
    Set Suite Variable    ${Netact}     Netact
    taf.nms.netact.Add Node    itsmwas    ${fm_cm_itsmwas_hostIp}    omc    Medsql!_1893    alias=Netact
    Add_cmwas_node

Expected alarm
    [Documentation]     Alarms which are ignored on runtime
    ${allowed_alarm_1}    Create alarm    alarm_id=7220     fault_id=61524    fault_name=SSH enabled
    ${allowed_alarm_2}    Create alarm    alarm_id=7220     fault_id=4654     fault_name=Ethernet port security is disabled
    ${allowed_alarm_3}    Create alarm    alarm_id=7220     fault_id=61649    fault_name=LMP access via port 443
    ${allowed_alarm_4}    Create alarm    alarm_id=7220     fault_id=4655     fault_name=Service account root access is enabled
    ${allowed_alarm_5}    Create alarm    alarm_id=7220     fault_id=61652    fault_name=R&D Service Port enabled
    ${allowed_alarm_6}    Create alarm    alarm_id=61641    fault_id=61641    fault_name=IP Traffic Capturing ongoing
    ${allowed_alarm_7}    Create alarm    alarm_id=7115     fault_id=4592     fault_name=BTS Reset Cause
    ${allowed_alarm_8}    Create alarm    alarm_id=7115     fault_id=8000     fault_name=Failure in connection between BTS and 3rd party tool
    ${allowed_alarm_9}    Create alarm    alarm_id=7102     fault_id=49       fault_name=Cell blocked
	${allowed_alarm_10}    Create alarm    alarm_id=7115     fault_id=4740     fault_name=EFaultId_ClearFaultNotifUnderMoAl
    ${allowed_alarm_11}    Create alarm    alarm_id=7115     fault_id=4681     fault_name=Sanity Check Error
    ${allowed_alarm_12}    Create alarm    alarm_id=7115     fault_id=4720
	...    fault_name=Mismatch of RU reported capabilities with static HW Validation information
	${allowed_alarm_13}    Create alarm    alarm_id=7115     fault_id=4602     fault_name=5G cell configuration mismatch
	${allowed_alarm_14}    Create alarm    alarm_id=7114     fault_id=7509
	...    fault_name=EN DSS Setup Failure - Max EN DSS Counter Value reached - No answer from CRM
	${allowed_alarm_15}    Create alarm    alarm_id=7110     fault_id=4293     fault_name=IP Traffic Capacity Limit
	${allowed_alarm_16}    Create alarm    alarm_id=7107     fault_id=7300     fault_name=No X2 link available
    ${allowed_alarm_17}    Create alarm    alarm_id=7115     fault_id=4282      fault_name=Configuration and hardware mismatch
    ${allowed_alarms}    Create list    ${allowed_alarm_1}    ${allowed_alarm_2}    ${allowed_alarm_3}    ${allowed_alarm_4}
    ...     ${allowed_alarm_5}  ${allowed_alarm_6}  ${allowed_alarm_7}  ${allowed_alarm_8}  ${allowed_alarm_9}  #${allowed_alarm_10}
    ...     ${allowed_alarm_11}  ${allowed_alarm_12}  ${allowed_alarm_13}  ${allowed_alarm_14}  ${allowed_alarm_15}  ${allowed_alarm_16}
	...    ${allowed_alarm_17}
    [Return]    ${allowed_alarms}

Assert Mrbts Is In Onair State
    [Arguments]    ${timeout}=50
    ...            ${alias}=${connection}
    ${mrbts_state}    COAM.Get Mrbts State    timeout=${timeout}
    ...                                        alias=${alias}
    Should Contain    ${mrbts_state}    OnAir
	${Active_alarm}    COAM.get_active_alarms     alias=${alias}

Check resource hanging
    [Documentation]  Ask on AAshell resources usages, after end of TC it is expected to have no user resources usage
    ${rc}  ${output} =  Run and Return RC and Output  ${script_path}/hanging.py ${OUTPUT_DIR}
    log to console  Resource hanging: ${output}
	...    ${script_path}/hanging.py ${OUT_LOG_PATH}
    run keyword if  '${rc}'=='1'  log to console  /!\ Warning /!\ It seems resources are hanging. Check for ghost CRNTI

create testcase folder
    [Arguments]      ${testcase_name}
    [Documentation]     Create testcase folder in testpc
    ${val} =    Run Keyword And Return Status    LOG    ${PATH}/${Folder}/${testcase_name}
    Run Keyword If    ${val} == False    Get Time
    create directory    ${PATH}/${Folder}/${testcase_name}/DCAP_Logs

Create dcap session
	Log to console   \n--Create dcap session--\n
    [Documentation]    Establish DCAP session
    rd.connect_to     host=${DCAP_host}     port=${ssh_port}    rd_version=${rd_version}
    ...    username=utfuser    password=utfadmin!        secure=${secure}

Add_cmwas_node
    Log to console   \n--Add_cmwas_node--\n
    taf.nms.netact.Add Node    cmwas    ${fm_cm_itsmwas_hostIp}
    ...                         ${node_Username_fmwas}
    ...                         ${node_password_fmwas}
    ...                         alias=Netact

Attach UE
	ta_ultracaller.require_ue    ${UE_alias}    ${capabilities}
	ta_ultracaller.Detach UE     ue_alias=${UE_alias}
	ta_ultracaller.Attach UE     ue_alias=${UE_alias}
	sleep    15s

Detach UE
    ta_ultracaller.require_ue    ${UE_alias}    ${capabilities}
    ta_ultracaller.Detach UE     ${UE_alias}

Start DL Throughput
    Log to console    \n--Staring dl Tput--\n
	ta_ultracaller.start_datatransfer    ${UE_alias}    ${udpcalltype}        ${direction_dl}
    sleep    30s
    ta_ultracaller.await_data_transfer_finish    ${UE_alias}    direction=${direction_dl}

Download target build and import to NMS
    Log to console   \n--Download target build--\n
	${sw_path}=    latestSbtsBuild    build_name=${target_build_name}    downloadable_type=A54
	${NMS_File_to_netact}    Set Variable      ${sw_path}
	${NMS_File_name}    Set Variable     ${target_build_name}
	Import build    ${NMS_File_to_netact}    ${NMS_File_name}

Import build
	[Arguments]    ${NMS_File_to_netact}    ${NMS_File_name}
    Log to console   \n--Import build--\n
    sleep    6
    taf.nms.netact.get_list_of_imported_builds    mo_type=MRBTS    alias=Netact
    taf.nms.netact.import build     ${NMS_File_to_netact}    version_id=${NMS_File_name}    alias=Netact
    sleep    10
    taf.nms.netact.get_list_of_imported_builds    mo_type=MRBTS    alias=Netact

Download and activate build from NMS
    Log to console  \n--Performing SW Update from NetAct--\n
    ${operation_id}=    Start SWM Operation    operation_type=provision    dist_names=${mo_id}
    ...                                        package=${target_build_name}     alias=Netact
    ${progress}=    Get Progress Of SWM Operation    ${operation_id}    alias=Netact
    Log    \nProgress: ${progress}    console=${TRUE}
    Sleep	1000s
    ${progress}=    Get Progress Of SWM Operation    ${operation_id}    alias=Netact
    Log    \nProgress: ${progress}    console=${TRUE}
    Clean All    alias=Netact
    ${progress1}=	Convert to Integer	${progress['Successful']}
    Log to console	\n SW Provision Successful Status: ${progress1}
    Should Be True    ${progress1}==1
    Log to console  \n--Wait for O-RUs to come UP --\n