*** Settings ***
Documentation   O-RU Software Provision from NetAct.
Library    OperatingSystem     WITH NAME    os
Library    SSHLibrary
Library        Collections
Library        taf.pdu    WITH NAME    pdu
Library    ./testsuite/Bangalore/ORAN/SG04/resources/GetFileName.py
Resource   ./testsuite/Bangalore/ORAN/SG04/resources/collect_logs.robot
Resource   ./testsuite/Bangalore/ORAN/SG04/resources/reportingportal_Keywords.robot
Resource   ./testsuite/Bangalore/ORAN/SG04/resources/alarm.robot
Library    ./testsuite/Bangalore/ORAN/SG04/resources/sa_cell_id.py
Library    taf.transport.ssh
Library    ./testsuite/Bangalore/ORAN/SG04/resources/deletefiles.py
Library         SSHLibrary    WITH NAME    sshlib
Library        taf.selenium.gnb.oam.coam.classical    WITH NAME    classical
Library           taf.sbts.oam.coam.admin    WITH NAME    coam
Library       taf.collectors.simple    WITH NAME    simple
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
Force Tags       CRT  SBTS23R3    SBTS23R2    FL00    QCD_MN_RAN   QCP_RAN_VRF

*** Variables ***
&{[1][2.0] Test_Case_6-CB008480_B O-RU Software Download Operation from NetAct Failed due to Reset and connection failure.}
...	QC_ID_FL00=QC_31625    QC_ID_SBTS24R1=QC_692706    QC_ID_SBTS23R4=QC_625841

*** Test Cases ***
[1][2.0] Test_Case_6-CB008480_B O-RU Software Download Operation from NetAct Failed due to Reset and connection failure.
    [Tags]    TRUNK_SG04    QCD_MN_RAN    QCP_RAN_VRF	   8480B_FAILURE
    [Teardown]    run keywords
    ...      Test teardown
    ...      Set QC_Tag
    Link SCOUT SCF to Configuration ID for Reporting
    Step4:ORU Software upgrade without Reset via CLI
    Step5:ORU Software upgrade with Reset via CLI

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
    Log to console   \n --Setup finished--

Step1:ORU SW Download rejected due to ORU Reset
    Log to console    \n--Test Step-1: ORU SW Download rejected due to ORU Reset--\n
    ${runningSwVersion1}=	Get ORU Sw Version Before Provision
    Log to console	${runningSwVersion1}
    ${SW_VERSION}=
    ...     Run Keyword If    "${runningSwVersion1}"=="202"    Set Variable    ${oru_sw_ver3}
    ...     ELSE    Set Variable    ${oru_sw_ver1}
    Log to console	\n Initial SW Version used:${SW_VERSION}
    Add Node    itsmwas    ${NetAct_host}    ${NetAct_uname}    ${NetAct_pwd}    alias=${NETACT_NAME}
    Run Keyword And Ignore Error    Delete Build    ${SW_VERSION}    mo_type=MRBTS    alias=${NETACT_NAME}
    ${Build_status}=	Is Imported    ${SW_VERSION}    alias=${NETACT_NAME}
    Log to console   --\n ORU SW version Build status: ${Build_status} \n--
    Run Keyword If	${Build_status}==True    Log to console    \n-- ORU SW available in NetAct skip SW import--\n
    ...    ELSE    Import Build    ${resources_path}/${SW_VERSION}.zip    mo_type=MRBTS	alias=${NETACT_NAME}
    Sleep	60s
    Log to console    \n-- Start Software Provision from NetAct--\n
    ${operation_id}=    Start SWM Operation    operation_type=provision    dist_names=${DIST_NAME2}
    ...                                        package=${SW_VERSION}    alias=${NETACT_NAME}
    ${progress}=    Get Progress Of SWM Operation    ${operation_id}    alias=${NETACT_NAME}
    Log    \nProgress: ${progress}    console=${TRUE}
    #Wait For SWM Operation    ${operation_id}    timeout=1800    alias=${NETACT_NAME}
    Sleep	50s
    Log to console    \n-- Start Software Download opeartion from NetAct while ORU is in Restart--\n
    ${operation_id}=    Start SWM Operation    operation_type=download    dist_names=${DIST_NAME2}
    ...                                        package=${SW_VERSION}    alias=${NETACT_NAME}
    Sleep	15s
    ${progress}=    Get Progress Of SWM Operation    ${operation_id}    alias=${NETACT_NAME}
    Log    \nProgress: ${progress}    console=${TRUE}
    Clean All    alias=${NETACT_NAME}
    ${progress1}=	Convert to Integer	${progress['Failed']}
    Log to console	\n SW Provision Failed Status: ${progress1}
    Should Be True    ${progress1}==1
    Wait for BTS OnAir
    taf.sbts.oam.coam.admin.Get Active alarms
    ${allowed_alarms}=    Expected_alarm
    Log To Console    \n ${allowed_alarms}
    Log to console  \n-- Step-1 SW operation Failed as Expected --\n

Step2:ORU SW Download failed due to Connection failure
    Log to console    \n--Test Step-2: ORU SW Download failed due to Connection failure--\n
    Add Node    itsmwas    ${NetAct_host}    ${NetAct_uname}    ${NetAct_pwd}    alias=${NETACT_NAME}
    ${imported_builds}=    Get List Of Imported Builds    alias=${NETACT_NAME}
    FOR    ${build}    IN  @{imported_builds}
      ${is_TrunkBuild}=     Run Keyword and Return Status    Should Contain      ${build}      _9999_
      ${SW_VERSION}=     Run keyword if
      ...           ${is_Trunk_Build}==True        Set Variable    ${build}
    END
    Log to console   --\n ORU SW version Build status: ${SW_VERSION} \n--
    Log to console  \n--Performing SW Download from NetAct--\n
    ${operation_id}=    Start SWM Operation    operation_type=download    dist_names=${DIST_NAME2}
    ...                                        package=${SW_VERSION}    alias=${NETACT_NAME}
    Log to console  \n-- Performing Ethernet Link Down --\n
    Make Ethernet Link Down
    ${progress}=    Get Progress Of SWM Operation    ${operation_id}    alias=${NETACT_NAME}
    Log    \nProgress: ${progress}    console=${TRUE}
    Sleep	100s
    Log to console  \n-- Performing Ethernet Link Up --\n
    Make Ethernet Link Up
    Sleep	100s
    Log to console  \n-- Verifying Fault-27 in the BTS --\n
    Assert Fault 27
    Wait for BTS OnAir
    Log to console  \n-- Step-2 SW operation Failed and Fault verified as Expected --\n

Step3:start ORU Software Fallback detection
    Log to console    \n--Test Step-3: start ORU Software Fallback detection--\n
    ${runningSwVersion1}=	Get ORU Sw Version Before Provision
    Log to console	${runningSwVersion1}
    ${SW_VERSION}=	Set Variable    ${oru_sw_ver2}
    Log to console  \n--Performing SW Update from NetAct--\n
    Add Node    itsmwas    ${NetAct_host}    ${NetAct_uname}    ${NetAct_pwd}    alias=${NETACT_NAME}
    ${Build_status}=	Is Imported    ${SW_VERSION}    alias=${NETACT_NAME}
    Log to console   --\n ORU SW version Build status: ${Build_status} \n--
    Run Keyword If	${Build_status}==True    Log to console    \n-- ORU SW available in NetAct skip SW import--\n
    ...    ELSE    Import Build    ${resources_path}/${SW_VERSION}.zip    mo_type=MRBTS	alias=${NETACT_NAME}
    Sleep	60s
    ${operation_id}=    Start SWM Operation    operation_type=provision   dist_names=${DIST_NAME2}
    ...                                     custom_attributes="oruActivationType=withoutReset"	package=${SW_VERSION}    alias=${NETACT_NAME}
    ${progress}=    Get Progress Of SWM Operation    ${operation_id}    alias=${NETACT_NAME}
    Log    \nProgress: ${progress}    console=${TRUE}
    #Wait For SWM Operation    ${operation_id}    timeout=1800    alias=${NETACT_NAME}
    Sleep	90s
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
    Log to console  \n-- Step-3 Software Provision without Reset PASSED --\n
    ${BBMODS}  taf.sbts.oam.coam.admin.get_ids_for_all  BBMOD
    Log to console  \n--Performing BBMOD reset--\n
    FOR    ${BBMOD}    IN  @{BBMODS}
      taf.sbts.oam.coam.admin.reset_unit    dist_name=${BBMOD}    reset_type=Warm    timeout=300s
    END
    Log to console  \n--BBMOD reset Completed and waiting for BBMOD to come up--\n
    Sleep	150s
    Assert Fault 1850
    Log to console  \n-- Fault 1850 Verified Successfully! --\n
    Add Node    itsmwas    ${NetAct_host}    ${NetAct_uname}    ${NetAct_pwd}    alias=${NETACT_NAME}
    ${operation_id}=    Start SWM Operation    operation_type=provision   dist_names=${DIST_NAME2}
    ...                                     custom_attributes="oruActivationType=withoutReset"	package=${SW_VERSION}    alias=${NETACT_NAME}
    ${progress}=    Get Progress Of SWM Operation    ${operation_id}    alias=${NETACT_NAME}
    Log    \nProgress: ${progress}    console=${TRUE}
    #Wait For SWM Operation    ${operation_id}    timeout=1800    alias=${NETACT_NAME}
    Sleep	90s
    ${progress}=    Get Progress Of SWM Operation    ${operation_id}    alias=${NETACT_NAME}
    Log    \nProgress: ${progress}    console=${TRUE}
    Clean All    alias=${NETACT_NAME}
    ${progress1}=	Convert to Integer	${progress['Successful']}
    Log to console	\n SW Provision Successful Status: ${progress1}
    Should Be True    ${progress1}==1
    ${runningSwVersion2}=	Get ORU Sw Version After Provision
    Log to console	${runningSwVersion2}
    Should Be True    ${runningSwVersion2}==${runningSwVersion1}
    ${RMODS}  taf.sbts.oam.coam.admin.get_ids_for_all  RMOD
    Log to console  \n--Performing RMODs reset--\n
    FOR    ${RMOD}    IN  @{RMODS}
      taf.sbts.oam.coam.admin.reset_unit    dist_name=${RMOD}    reset_type=Warm    timeout=300s
    END
    Log to console  \n--Wait for O-RUs to come UP --\n
    Wait for BTS OnAir
    taf.sbts.oam.coam.admin.Get Active alarms
    ${allowed_alarms}=    Expected_alarm
    Log To Console    \n ${allowed_alarms}
    ${runningSwVersion2}=	Get ORU Sw Version After Provision
    Log to console	${runningSwVersion2}
    Should Be True    ${runningSwVersion2}!=${runningSwVersion1}
    Log to console  \n-- Step-3 SW Fallback Detection Passed --\n

Step4:ORU Software upgrade without Reset via CLI
    Log to console	\n-- Step-4: O-RU SWR without Reset via CLI in progress --\n
    ${runningSwVersion1}=	Get ORU Sw Version Before Provision
    Log to console	${runningSwVersion1}
    Activate CLI feature
    log  Start ORU SWR to version 1.2
    ${result}=  os.Run  cd ${resources_path}; chmod +x ORUswr4.sh; ./ORUswr4.sh
    Log to console  ${result}
    Sleep  60
    ${runningSwVersion2}=	Get ORU Sw Version After Provision
    Log to console	${runningSwVersion2}
    Should Be True    ${runningSwVersion2}==${runningSwVersion1}
    Sleep	5s
    Log to console  \n-- Software Provision without Reset PASSED --\n
    Log to console    \n-- Reset O-RUs--\n
    ${runningSwVersion1}=	Get ORU Sw Version Before Provision
    Log to console	${runningSwVersion1}
    ${RMODS}  taf.sbts.oam.coam.admin.get_ids_for_all  RMOD
    Log to console  \n--Performing RMODs reset--\n
    FOR    ${RMOD}    IN  @{RMODS}
      taf.sbts.oam.coam.admin.reset_unit    dist_name=${RMOD}    reset_type=Warm    timeout=300s
    END
    Sleep  20
    Log to console  \n--Wait for O-RUs to come UP --\n
    Wait for BTS OnAir
    taf.sbts.oam.coam.admin.Get Active alarms
    ${allowed_alarms}=    Expected_alarm
    Log To Console    \n ${allowed_alarms}
    ${runningSwVersion2}=	Get ORU Sw Version After Provision
    Log to console	${runningSwVersion2}
    Should Be True    ${runningSwVersion2}!=${runningSwVersion1}
    Log to console  \n-- Reset O-RUs PASSED --\n
    Log to console	\n-- Step-4: O-RU SWR via CLI PASSED --\n

Step5:ORU Software upgrade with Reset via CLI
    Log to console	\n-- Step-5: O-RU SWR with Reset via CLI in progress--\n
    #Download ADMIN_CLI Package
    #Transfer ADMIN_CLI scripts
    ${runningSwVersion1}=	Get ORU Sw Version Before Provision
    Log to console	${runningSwVersion1}
    log  Start ORU SWR to version 1.1
    ${result}=  os.Run  cd ${resources_path}; chmod +x ORUswr3.sh; ./ORUswr3.sh
    Log to console  ${result}
    Log to console  \n--Wait for O-RUs to come UP --\n
    Sleep	50s
    Wait for BTS OnAir
    ${runningSwVersion2}=	Get ORU Sw Version After Provision
    taf.sbts.oam.coam.admin.Get Active alarms
    ${allowed_alarms}=    Expected_alarm
    Log To Console    \n ${allowed_alarms}
    Log to console	${runningSwVersion2}
    Should Be True    ${runningSwVersion2}!=${runningSwVersion1}
    Log to console	\n-- Step-5: O-RU SWR via CLI PASSED --\n
    ${dcap_log_status}=    Set Variable    1.0
    Set suite variable    ${dcap_log_status}
    Log to console	DCAP_LOG_STATUS: ${dcap_log_status}

Test teardown
    Log to console   --\n Test teardown Started\n--
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

Make Ethernet Link Down
   taf.sbts.oam.coam.admin.Perform Parameter Recommissioning    dist_name=MRBTS-${btsid2}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1
   ...                                        parameter=vlanId
   ...                                        operation=update
   ...                                        value=410

Make Ethernet Link Up
   taf.sbts.oam.coam.admin.Perform Parameter Recommissioning    dist_name=MRBTS-${btsid2}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1
   ...                                        parameter=vlanId
   ...                                        operation=update
   ...                                        value=310

Assert Fault 27
    ${passed}=    Run Keyword And Return Status    taf.sbts.oam.coam.admin.Assert Alarm Active
    ...    faultName=regex"Error in file server during file upload or download operation", faultId=27, severity=Minor, alarmId=7115
    ...    timeout=360
    Run Keyword If    '${passed}' == 'False'	Fail	Fault 27 does not exist

Assert Fault 1850
    ${passed}=    Run Keyword And Return Status    taf.sbts.oam.coam.admin.Assert Alarm Active
    ...    faultName=regex"SW corrupted", faultId=1850, severity=Critical, alarmId=7111
    ...    timeout=360
    Run Keyword If    '${passed}' == 'False'	Fail	Fault 1850 does not exist

Activate CLI feature
   taf.sbts.oam.coam.admin.Perform Parameter Recommissioning    dist_name=MRBTS-${btsid2}/MNL-1/MNLENT-1/FEATCADM-1
   ...                                        parameter=actCli
   ...                                        operation=update
   ...                                        value=true

Deactivate CLI feature
   taf.sbts.oam.coam.admin.Perform Parameter Recommissioning    dist_name=MRBTS-${btsid2}/MNL-1/MNLENT-1/FEATCADM-1
   ...                                        parameter=actCli
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

Download ADMIN_CLI Package
    [Documentation]    Kw download Common Trunk AdminCLI from disc e.g.:
    ...    https://lterel.es-si-s3-z4.eecloud.nsn-net.net/build/SBTS00/SBTS00_ENB_9999_210505_000001_ADMIN_CLI.zip
    ${SW_Version}     taf.sbts.oam.coam.admin.get_sw_version
    ${is_TrunkBuild}=     Run Keyword and Return Status    Should Contain      ${SW_Version}      _9999_
    ${build_ver}=     Run keyword if
    ...           ${is_Trunk_Build}==True        Replace String Using Regexp    ${SW_Version}    ^SBTS[A-Za-z0-9]+_    SBTS00_
    ...  ELSE     Set variable   ${SW_Version}
    ${release}        Fetch from left   ${build_ver}  _ENB_
    ${fileExists}      Run Keyword and Return Status  OperatingSystem.File Should Exist   ${SW_DESTINATION}/${build_ver}_ADMIN_CLI.zip
    Run Keyword If     ${fileExists} is False   os.Run  wget ${lterel_disc}/${release}/${build_ver}_ADMIN_CLI.zip -nv -P ${SW_DESTINATION}
    ${fileExists}      Run Keyword and Return Status  OperatingSystem.File Should Exist   ${SW_DESTINATION}/${build_ver}_ADMIN_CLI.zip
    Should Be Equal As Strings  ${fileExists}  True
    os.Run  unzip -o ${SW_DESTINATION}/${build_ver}_ADMIN_CLI.zip -d ${SW_DESTINATION}/ADMIN_CLI
    Run Keyword And Ignore Error	os.Run  rm -rf ${SW_DESTINATION}/${build_ver}_ADMIN_CLI.zip
    Log to Console     --\n ADMIN CLI Download & Unzip completed \n --
    [Return]           ${build_ver}_ADMIN_CLI.zip

Transfer ADMIN_CLI scripts
    os.Run  cp ${resources_path}/ORUswr1.sh ${SW_DESTINATION}/ADMIN_CLI/
    os.Run  cp ${resources_path}/ORUswr2.sh ${SW_DESTINATION}/ADMIN_CLI/
    os.Run  cp ${resources_path}/ORU_package_1_1.zip ${SW_DESTINATION}/ADMIN_CLI/
    os.Run  cp ${resources_path}/ORU_package_1_2.zip ${SW_DESTINATION}/ADMIN_CLI/
    os.Run  chmod 777 ${SW_DESTINATION}/ADMIN_CLI/*
    Log to Console     --\n ADMIN CLI Scripts Transfer completed \n --

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
    Log to console    \n-- Stopped DCAP Traces & Skipping log Transfer --\n
    rd.stop_trace      trace_id=${trace_id}

DCAP Stop with log Transfer
    rd.stop_trace      trace_id=${trace_id}
    Log to console    \n-- Stopped DCAP Traces & Moving files to Logs Repo --\n
    rd.get_results    result_id=${trace_id}       target_dir=/home/ute/results/${TEST_NAME}    timeout=300
    os.Run    sudo mv '/home/ute/results/${TEST_NAME}' /sharedvolume/Execution_CRT_Logs/
