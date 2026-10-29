*** Settings ***
Documentation   O-RU Software Provision from NetAct.
Library    OperatingSystem     WITH NAME    os
Library        Collections
Library        taf.pdu    WITH NAME    pdu
Library    ./testsuite/Bangalore/ORAN/SG04/resources/GetFileName.py
#Resource   ./testsuite/Bangalore/ORAN/SG04/resources/collect_logs.robot
Resource   ./testsuite/Bangalore/ORAN/SG04/resources/reportingportal_Keywords.robot
Resource   ./testsuite/Bangalore/ORAN/SG04/resources/alarm.robot
Library    ./testsuite/Bangalore/ORAN/SG04/resources/sa_cell_id.py
Library    taf.transport.ssh
Library    ./testsuite/Bangalore/ORAN/SG04/resources/deletefiles.py
Library         SSHLibrary    WITH NAME    sshlib
Library        taf.selenium.gnb.oam.coam.classical    WITH NAME    classical
Library           taf.sbts.oam.coam.admin
#Library       taf.collectors.simple    WITH NAME    simple
Library       taf.collectors.core    WITH NAME    core
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    taf.nms.netact
Library     taf.rfrl.utilities.tl_config
Library     taf.rfrl.bts.commissioning
Library     taf.sw.dcap.rd   WITH NAME   rd
Library    taf.config.scf     WITH NAME    scf
Library    DateTime
Library    taf.sw.scout    WITH NAME    scout
Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Variables   ./testsuite/Bangalore/ORAN/SG04/resources/CRT4_parameters.py

Test Setup      Preconditions
Test Teardown	Test teardown
#Force Tags       CRT   FL00    QCD_MN_RAN   QCP_RAN_VRF

*** Variables ***
&{[1][2.0] Test_Case_4-CB008480_B O-RU Software Provision Operation Triggered from NetAct.}    QC_ID_FL00=QC_31626    QC_ID_SBTS24R3=QC_852853
...    QC_ID_SBTS25R1=QC_78984


*** Test Cases ***
[1][2.0] Test_Case_4-CB008480_B O-RU Software Provision Operation Triggered from NetAct.
    [Tags]    TRUNK_SG04    24R3    25R1    8480B    QCD_MN_RAN    QCP_RAN_VRF
    [Teardown]    run keywords
    ...      Test teardown
    ...      Set QC_Tag

    Link SCOUT SCF to Configuration ID for Reporting
    Step1:start Software Provision from NetAct and verify new SW version
    Step2:Set oruDisableSWUpdate to True
    Step3:start Software Provision from NetAct and verify SW operation failed
    Step4:Set oruDisableSWUpdate to False
    Step5:start Software Provision without Reset using Multizipfile from NetAct
    Step6:Reset all ORUs
    Step7:Trigger ORU software downgrade to older version and verify new SW version

*** Keywords ***
Preconditions
    Log to console   --Test setup--
    taf.sbts.oam.coam.admin.setup_admin	bts_host=10.58.239.89    timeout=300
    ${sw_version}=    taf.sbts.oam.coam.admin.get_sw_version
    Log to console  \n ${sw_version} \n
    Check BTS is OnAir
    taf.sbts.oam.coam.admin.Get Active alarms
    ${allowed_alarms}=    Expected_alarm
    Log To Console    ${allowed_alarms}
    DCAP Start
    Log to console   --Setup finished--

Step1:start Software Provision from NetAct and verify new SW version
    Log to console    \n--Test Step-1 Software Provision from NetAct--\n
    ${runningSwVersion1}=	Get ORU Sw Version Before Provision
    Log to console	${runningSwVersion1}
    ${SW_VERSION}=
    ...     Run Keyword If    "${runningSwVersion1}"=="202"    Set Variable    ${oru_sw_ver3}
    ...     ELSE    Set Variable    ${oru_sw_ver1}
    Log to console	\n Initial SW Version to be used:${SW_VERSION}
    Add Node    itsmwas    ${NetAct_host}    ${NetAct_uname}    ${NetAct_pwd}    alias=${NETACT_NAME}
    Run Keyword And Ignore Error    Delete Build    ${SW_VERSION}    mo_type=MRBTS    alias=${NETACT_NAME}
    ${Build_status}=	Is Imported    ${SW_VERSION}    alias=${NETACT_NAME}
    Log to console   --\n ORU SW version Build status: ${Build_status} \n--
    Run Keyword If	${Build_status}==True    Log to console    \n-- ORU SW available in NetAct skip SW import--\n
    ...    ELSE   Import Build    ${resources_path}/${SW_VERSION}.zip    mo_type=MRBTS	alias=${NETACT_NAME}
    Sleep	60s
    Log to console  \n--Performing SW Update from NetAct--\n
    ${operation_id}=    Start SWM Operation    operation_type=provision    dist_names=${DIST_NAME2}
    ...                                        package=${SW_VERSION}    alias=${NETACT_NAME}
    ${progress}=    Get Progress Of SWM Operation    ${operation_id}    alias=${NETACT_NAME}
    Log    \nProgress: ${progress}    console=${TRUE}
    #Wait For SWM Operation    ${operation_id}    timeout=1800    alias=${NETACT_NAME}
    Sleep	360s
    ${progress}=    Get Progress Of SWM Operation    ${operation_id}    alias=${NETACT_NAME}
    Log    \nProgress: ${progress}    console=${TRUE}
    Clean All    alias=${NETACT_NAME}
    ${progress1}=	Convert to Integer	${progress['Successful']}
    Log to console	\n SW Provision Successful Status: ${progress1}
    Should Be True    ${progress1}==1
    Log to console  \n--Wait for O-RUs to come UP --\n
    Wait for BTS OnAir
    taf.sbts.oam.coam.admin.Get Active alarms
    ${allowed_alarms}=    Expected_alarm
    Log To Console    ${allowed_alarms}
    ${runningSwVersion2}=	Get ORU Sw Version After Provision
    Log to console	${runningSwVersion2}
    Should Be True    ${runningSwVersion2}!=${runningSwVersion1}
    Log to console  \n-- Step-1 Software Provision from NetAct PASSED --\n

Step2:Set oruDisableSWUpdate to True
    Log to console    \n--Test Step-2: Disable O-RU SW Update--\n
    Disable ORU SW Upgrade
    Sleep	10s
    ${config_status}=    Set Variable    2.0
    Set suite variable    ${config_status}
    	Log to console  \n-- Step-2 PASSED --\n
    Log to console  \n-- Step-2 Disable O-RU SW Update PASSED --\n

Step3:start Software Provision from NetAct and verify SW operation failed
    Log to console    \n--Test Step-3: Software Provision Failed from NetAct --\n
    ${runningSwVersion1}=	Get ORU Sw Version Before Provision
    Log to console	${runningSwVersion1}
    ${SW_VERSION}=	Set Variable    ${oru_sw_ver2}
    Log to console  \n ORU SW version to be Used: ${SW_VERSION} \n
    Add Node    itsmwas    ${NetAct_host}    ${NetAct_uname}    ${NetAct_pwd}    alias=${NETACT_NAME}
     Run Keyword And Ignore Error    Delete Build    ${SW_VERSION}    mo_type=MRBTS    alias=${NETACT_NAME}
    ${Build_status}=	Is Imported    ${SW_VERSION}    alias=${NETACT_NAME}
    Log to console   --\n ORU SW version Build status: ${Build_status} \n--
    Run Keyword If	${Build_status}==True    Log to console    \n-- ORU SW available in NetAct skip SW import--\n
    ...    ELSE    Import Build    ${resources_path}/${SW_VERSION}.zip    mo_type=MRBTS	alias=${NETACT_NAME}
    Sleep	60s
    Log to console  \n--Performing SW Update from NetAct--\n
    ${operation_id}=    Start SWM Operation    operation_type=provision    dist_names=${DIST_NAME2}
    ...                                        package=${SW_VERSION}    alias=${NETACT_NAME}
    ${progress}=    Get Progress Of SWM Operation    ${operation_id}    alias=${NETACT_NAME}
    Log    \nProgress: ${progress}    console=${TRUE}
    #Wait For SWM Operation    ${operation_id}    timeout=1800    alias=${NETACT_NAME}
    Sleep	90s
    ${progress}=    Get Progress Of SWM Operation    ${operation_id}    alias=${NETACT_NAME}
        Log    \nProgress: ${progress}    console=${TRUE}
    Clean All    alias=${NETACT_NAME}
    ${progress1}=	Convert to Integer	${progress['Failed']}
    Log to console	\n SW Provision Failed Status: ${progress1}
    Should Be True    ${progress1}==1
    Wait for BTS OnAir
    taf.sbts.oam.coam.admin.Get Active alarms
    ${allowed_alarms}=    Expected_alarm
    Log To Console    ${allowed_alarms}
    ${runningSwVersion2}=	Get ORU Sw Version After Provision
    Log to console	${runningSwVersion2}
    Should Be True    ${runningSwVersion2}==${runningSwVersion1}
    Log to console  \n-- Step-3 SW operation Failed as Expected --\n

Step4:Set oruDisableSWUpdate to False
    Log to console    \n--Test Step-4: Enable O-RU SW Update--\n
    Enable ORU SW Upgrade
    Sleep	10s
    ${config_status}=     Set Variable    3.0
    Set suite variable    ${config_status}
    Log to console  \n-- Step-4 Enable O-RU SW Update PASSED --\n
    RP Settings
Step5:start Software Provision without Reset using Multizipfile from NetAct
    Log to console    \n--Test Step-5: Software Provision without Reset--\n
    ${runningSwVersion1}=	Get ORU Sw Version Before Provision
    Log to console	${runningSwVersion1}
    ${SW_VERSION}=	Set Variable    ${oru_sw_ver2}
    Log to console  \n--Performing SW Update from NetAct--\n
    Add Node    itsmwas    ${NetAct_host}    ${NetAct_uname}    ${NetAct_pwd}    alias=${NETACT_NAME}
    ${operation_id}=    Start SWM Operation    operation_type=provision   dist_names=${DIST_NAME2}
    ...                                     custom_attributes="oruActivationType=withoutReset"	package=${SW_VERSION}    alias=${NETACT_NAME}
    ${progress}=    Get Progress Of SWM Operation    ${operation_id}    alias=${NETACT_NAME}
    Log    \nProgress: ${progress}    console=${TRUE}
    #Wait For SWM Operation    ${operation_id}    timeout=1800    alias=${NETACT_NAME}
    Sleep	360s
    ${progress}=    Get Progress Of SWM Operation    ${operation_id}    alias=${NETACT_NAME}
    Log    \nProgress: ${progress}    console=${TRUE}
    Clean All    alias=${NETACT_NAME}
    ${progress1}=	Convert to Integer	${progress['Successful']}
    Log to console	\n SW Provision Successful Status: ${progress1}
    Should Be True    ${progress1}==1
    ${runningSwVersion2}=	Get ORU Sw Version After Provision
    Log to console	${runningSwVersion2}
    Should Be True    ${runningSwVersion2}==${runningSwVersion1}
    Sleep	5s
    Log to console  \n-- Step-5 Software Provision without Reset PASSED --\n

Step6:Reset all ORUs
    Log to console    \n--Test Step-6: Reset O-RUs--\n
    ${runningSwVersion1}=	Get ORU Sw Version Before Provision
    Log to console	${runningSwVersion1}
    ${RMODS}  taf.sbts.oam.coam.admin.get_ids_for_all  RMOD
    Log to console  \n--Performing RMODs reset--\n
    FOR    ${RMOD}    IN  @{RMODS}
      taf.sbts.oam.coam.admin.reset_unit    dist_name=${RMOD}    reset_type=Warm    timeout=300s
    END
    Log to console  \n--Wait for O-RUs to come UP --\n
    Wait for BTS OnAir
    taf.sbts.oam.coam.admin.Get Active alarms
    ${allowed_alarms}=    Expected_alarm
    Log To Console    ${allowed_alarms}
    ${runningSwVersion2}=	Get ORU Sw Version After Provision
    Log to console	${runningSwVersion2}
    Should Be True    ${runningSwVersion2}!=${runningSwVersion1}
    Log to console  \n-- Step-6 Reset O-RUs PASSED --\n

Step7:Trigger ORU software downgrade to older version and verify new SW version
    Log to console  \n--Test Step-7: Performing SW downgrade from NetAct when ORU is in Locked State--\n
    ${runningSwVersion1}=	Get ORU Sw Version Before Provision
    Log to console	${runningSwVersion1}
    ${SW_VERSION}=	Set Variable    ${oru_sw_ver1}
    Log to console  \n ORU SW version to be Used: ${SW_VERSION} \n
    Add Node    itsmwas    ${NetAct_host}    ${NetAct_uname}    ${NetAct_pwd}    alias=${NETACT_NAME}
     Run Keyword And Ignore Error    Delete Build    ${SW_VERSION}    mo_type=MRBTS    alias=${NETACT_NAME}
    ${Build_status}=	Is Imported    ${SW_VERSION}    alias=${NETACT_NAME}
    Log to console   --\n ORU SW version Build status: ${Build_status} \n--
    Run Keyword If	${Build_status}==True    Log to console    \n-- ORU SW available in NetAct skip SW import--\n
    ...    ELSE    Import Build    ${resources_path}/${SW_VERSION}.zip    mo_type=MRBTS	alias=${NETACT_NAME}
    Sleep	60s
    Log to console  \n--Lock ORU--\n
    ${RMODS}  taf.sbts.oam.coam.admin.get_ids_for_all  RMOD
    Log to console  \n--Performing RMODs Lock--\n
    FOR    ${RMOD}    IN  @{RMODS}
      taf.sbts.oam.coam.admin.lock    dist_name=${RMOD}    timeout=300s
    END
    Log to console  \n--Performing SW Update from NetAct--\n
    ${operation_id}=    Start SWM Operation    operation_type=provision    dist_names=${DIST_NAME2}
    ...                                        package=${SW_VERSION}    alias=${NETACT_NAME}
    ${progress}=    Get Progress Of SWM Operation    ${operation_id}    alias=${NETACT_NAME}
    Log    \nProgress: ${progress}    console=${TRUE}
    #Wait For SWM Operation    ${operation_id}    timeout=1800    alias=${NETACT_NAME}
    Sleep	360s
    ${progress}=    Get Progress Of SWM Operation    ${operation_id}    alias=${NETACT_NAME}
    Log    \nProgress: ${progress}    console=${TRUE}
    Clean All    alias=${NETACT_NAME}
    ${progress1}=	Convert to Integer	${progress['Successful']}
    Log to console	\n SW Provision Successful Status: ${progress1}
    Should Be True    ${progress1}==1
    Log to console  \n--Wait for O-RUs to come UP --\n
    Sleep    60s
    ${RMODS}  taf.sbts.oam.coam.admin.get_ids_for_all  RMOD
    Log to console  \n--Performing RMODs Unlock--\n
    FOR    ${RMOD}    IN  @{RMODS}
      taf.sbts.oam.coam.admin.unlock    dist_name=${RMOD}    timeout=300s
    END
    Wait for BTS OnAir
    taf.sbts.oam.coam.admin.Get Active alarms
    ${allowed_alarms}=    Expected_alarm
    Log To Console    ${allowed_alarms}
    ${runningSwVersion2}=	Get ORU Sw Version After Provision
    Log to console	${runningSwVersion2}
    Should Be True    ${runningSwVersion2}!=${runningSwVersion1}
    Sleep	5s
    Log to console  \n-- Step-7 SW downgrade from NetAct PASSED --\n
    ${dcap_log_status}=    Set Variable    1.0
    Set suite variable    ${dcap_log_status}
    Log to console	DCAP_LOG_STATUS: ${dcap_log_status}

Test teardown
    Log to console   --\n Test teardown Started\n--
    Check Site Configurations Status
    Check BTS is OnAir
    #${Timestamp}=  Get Current Date  result_format=%Y-%m-%d %H:%M:%S.%f
    #Log to console   \n Date Time:  ${Timestamp}
    #Set suite variable    ${Timestamp}
    Run Keyword If		"${dcap_log_status}" == "1.0"   DCAP Stop
    ...    ELSE    DCAP Stop with log Transfer
    taf.sbts.oam.coam.admin.teardown_all_aliases_for_admin
    RP Settings
    Run Keyword If		"${sw_release}" == "None"
    ...   Log   -- RP Settings step is for reporting portal purpose only, if this step alone fails, you can update QC manually-- 	html=true
    ...   console=true
    Log to console   --\n Test teardown COMPLETED \n--
    interface.Common step trigger


Get ORU Sw Version Before Provision
    ${bts_info}=    taf.sbts.oam.coam.admin.get_bts_info
    ${SwVersion_tmp1}=    Create List	${bts_info['radioModules']['rmod'][0]['swInfo']['runningSwVersion']}
    Log To Console	\n O-RU SW Version Before Provision: ${SwVersion_tmp1[0]}
    ${SwVersion_tmp2}=    Split string    ${SwVersion_tmp1[0]}     separator=_    max_split=3
    #${SwVersion_tmp3}=    Split string    ${SwVersion_tmp2[0]}     separator=-    max_split=2
    #${SwVersion_tmp4}=    Split String To Characters    ${SwVersion_tmp3[2]}
    ${runningSwVersion}=	Convert to Integer	${SwVersion_tmp2[1]}
    [Return]    ${runningSwVersion}

Get ORU Sw Version After Provision
    ${bts_info}=    taf.sbts.oam.coam.admin.get_bts_info
    ${SwVersion_tmp1}=    Create List	${bts_info['radioModules']['rmod'][0]['swInfo']['runningSwVersion']}
    Log To Console	\n O-RU SW Version After Provision: ${SwVersion_tmp1[0]}
    ${SwVersion_tmp2}=    Split string    ${SwVersion_tmp1[0]}     separator=_    max_split=3
    #${SwVersion_tmp3}=    Split string    ${SwVersion_tmp2[0]}     separator=-    max_split=2
    #${SwVersion_tmp4}=    Split String To Characters    ${SwVersion_tmp3[2]}
    ${runningSwVersion}=	Convert to Integer	${SwVersion_tmp2[1]}
    [Return]    ${runningSwVersion}

Check Site Configurations Status
    Log to console   --\n Check Site Configurations Status Started\n--
    Run Keyword If    "${config_status}"=="2.0"   Enable ORU SW Upgrade
    ...     ELSE    Log to console   --\n Site Configurations already reverted \n --

Disable ORU SW Upgrade
   taf.sbts.oam.coam.admin.Perform Parameter Recommissioning    dist_name=MRBTS-${btsid2}/EQM-1/APEQM-1/RMOD-1
   ...                                        parameter=oruDisableSWUpdate
   ...                                        operation=update
   ...                                        value=true

Enable ORU SW Upgrade
   taf.sbts.oam.coam.admin.Perform Parameter Recommissioning    dist_name=MRBTS-${btsid2}/EQM-1/APEQM-1/RMOD-1
   ...                                        parameter=oruDisableSWUpdate
   ...                                        operation=update
   ...                                        value=false

Netconf File Collection
    ${proxy}       Create Dictionary    host=10.58.238.65    user=ute    password=BT5l@bus3rl0g1n
    ${executor}    Create Dictionary    host=192.168.255.129    user=toor4nsn    password=oZPS0POrRieRtu
    ...     proxy=${proxy}
    simple.create_simple_collector
    ...    name=coredump
    ...    dir_path=/tmp/node_FHNET00/tmp
    ...    file_pattern=.*
    ...    executor=${executor}
    ...    target_file_name=coredump1.log
    core.setup_collectors    names=coredump
    #core.start_collectors    names=coredump
    sleep    30s
    #core.stop_collectors    names=coredump
    core.collect_collectors    names=coredump    target_dir=/home/ute/results
    core.teardown_collectors    names=coredump
    os.Run    tar -zxvf /home/ute/results/coredump/coredump1.log.tgz -C /home/ute/results/coredump
    os.Copy File    /home/ute/results/coredump/RMOD_L-1_NetconfRpcMessageTrace.log
    ...    /home/ute/logs/{tc4}_${Timestamp}/RMOD_L-1_NetconfRpcMessageTrace.log

Check BTS is OnAir
    [Documentation]    Check the BTS current status
    ${bts_status}    taf.sbts.oam.coam.admin.get_bts_statuses
    Should Be Equal As Strings    ${bts_status["proceduralState"]}    OnAir
    Run Keyword If    '${bts_status["proceduralState"]}'=='OnAir'    LOG    BTS procedural state is now: ${bts_status["proceduralState"]}
    ...    ELSE    fail
    Log to console    \nBTS procedural state : ${bts_status["proceduralState"]}

Wait for BTS OnAir
    Log to console      \nWaiting for BTS to be OnAir
    FOR    ${a}    IN RANGE    1    10
        ${bts_status}=    taf.sbts.oam.coam.admin.get_bts_statuses
        Exit For Loop IF    '${bts_status["proceduralState"]}'=='OnAir'
        Sleep    1m    reason=Wait for BTS status OnAir
    END
    ${bts_status}    taf.sbts.oam.coam.admin.get_bts_statuses
    Run Keyword If    '${bts_status["proceduralState"]}'=='OnAir'    LOG    BTS procedural state is now: ${bts_status["proceduralState"]}
    ...    ELSE    fail
    Log to console    \nBTS procedural state : ${bts_status["proceduralState"]}

Request Scout SCF
    [Arguments]   ${scout_testline_name}
    [Documentation]    :Author: Michele
    ...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    scout.setup_scout  scout_testline_name=${scout_testline_name}
    ${external_scf_id}=   scout.request_scf   use_scout_internal_id=True
    scout.teardown_scout_api
    [Return]   ${external_scf_id}


Link SCOUT SCF to Configuration ID for Reporting
    [Documentation]
    ...    Associate the SCF to the Configuration ID in Reporting Portal using SCOUT.
    ...
    ...    Example:
    ...     |  Link SCOUT SCF to Configuration ID for Reporting    node_id=${0}    node_type=enb
    ...
    ...     |param node_id | (default=0) Id/Number of Node (eNB or gNB) |
    ...     |param node_type | (default=gnb) Node type; possible values: gnb or enb |

    [Arguments]    ${node_id}=${0}    ${node_type}=enb    ${tl_name_only}=${scout_id2}
    log    ${node_id}
    ${node_type_Name}        Run Keyword If  "${node_type}"=="gnb"   Set Variable  gNB
    ...     ELSE IF     "${node_type}"=="enb"                   Set Variable  eNB
    ...     ELSE        Fail    Wrong node_type '${node_type}'! allowed: enb|gnb


    Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only}

    ${scout_testline_name}=    Set Variable    ${tl_name_only}
    ${external_scf_id}=	Wait Until Keyword Succeeds	2min	10s	Request Scout SCF	${scout_testline_name}
    ${TC_ID}=    Set Variable    ute:id:${external_scf_id}
    Set Tags  ${TC_ID}

DCAP Start
    Log to console    \n-- Connecting to DCAP Server--\n
    rd.connect_to     host=${dcaphost}      port=${dcapport}     rd_version=${dcap_version}    username=${dcap_uname}
    ...     password=${dcap_pwd}    secure=True
    ${bts_info}=    create dictionary    host=${btshost1}    port=${btsport}    username=${bts_uname}     password=${bts_pwd}
    #${gnb_custom_profile}=    Create List    condor5gSyslog
    ${output}=     rd.start_trace    tag=start_trace      duration=-1     bts=${bts_info}    tag=newtrace
    ...    gnb_trace_profile=dcap-lite-default    bts_trace_profile=dcap-lite-default
    Log to console    \n-- Started GNB Custom Traces --\n
    ${trace_d}=    Get Dictionary Values   ${output}
	${trace_id}=    Set Variable    ${trace_d}[0]
    Log to console    \n DCAP Trace ID: ${trace_id} \n
    Set suite variable    ${trace_id}

DCAP Stop
    Log to console    \n-- Stop DCAP Traces & Skipping log Transfer --\n
    rd.stop_trace      trace_id=${trace_id}

DCAP Stop with log Transfer
    rd.stop_trace      trace_id=${trace_id}
    Log to console    \n-- Stopped DCAP Traces & Moving files to Logs Repo --\n
    rd.get_results    result_id=${trace_id}       target_dir=/home/ute/results/${TEST_NAME}    timeout=200
    os.Run    sudo mv '/home/ute/results/${TEST_NAME}' /sharedvolume/Execution_CRT_Logs/
