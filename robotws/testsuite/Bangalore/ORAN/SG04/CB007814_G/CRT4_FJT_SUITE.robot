*** Settings ***
Documentation    Maintainer:CB007814_G Feature Regression Script, NR_DOWNLINK on Samji ORU Moving to TDS  


Library             Process
Library             Collections
Library             OperatingSystem
Library             taf.sw.dcap.rd       WITH NAME     dcap
Library             taf.sbts.oam.coam.admin    WITH NAME     admin
Library             String
Library             taf.collectors.core   WITH NAME   core
Library             taf.collectors.btslog  WITH NAME   btslog
Library             DateTime 
Library             taf.transport.ssh    WITH NAME    ssh
Library             taf.rfrl.bts    WITH NAME    rfrl           
Library             SSHLibrary
Library             Process
Library             BuiltIn
Library             taf.sw.scout    WITH NAME    scout
Library             ute_fsmaccess
Library             String
Library             DateTime
Library             ./testsuite/Bangalore/ORAN/resources/python/netconf_validation.py
Library             taf.collectors.simple    WITH NAME    simple
Library             taf.collectors.pmcounters    WITH NAME    PM
Library             taf.analyzer.pmcounter    WITH NAME    analyser
Library             testsuite.Bangalore.ORAN.resources.python.ta_ultracaller     WITH NAME      ta_uc
Resource            ./testsuite/Bangalore/ORAN/resources/python/Macro/bts/gnb.robot
#Resource             ../resources/common/common_suite_setup_teardown.robot
Force Tags          CRT    FL00    SBTS00    SBTS23R4    QCP_RAN_ST    QCD_MN_RAN

Suite Setup         Suite Setup
Suite Teardown      Suite Postcondition  


*** Variables ***

${SCF_PATH}=    /home/ute/robotws/testsuite/Bangalore/ORAN/SG02/SCFC/

${commissioning_path_01}=                       ${SCF_PATH}SCFCCB010824_Concurrent.xml
@{Rollback_build}=    SBTS23R4 
${BTS_ADDRESS}     192.168.255.129
${BTS_ID}                          1207
${log_alias}    btslog
${bool}=    True
${str}=  SBTS00
${LOGS_PATH}=    /home/ute/logs
${VM_HOST_IP}=  10.41.209.136
${VM_username}=  ute
${VM_Password}=  BT5l@bus3rl0g1n
${BTSLOG_Path_for_validation}               /tmp/btslog2
&{BTS_Details}                     bts_host=192.168.255.129
...                                bts_port=443
...                                username=Nemuadmin
...                                password=nemuuser
...                                use_ssl=True
...                                update_interval=5000 
...                                admin_api_log_dir=${EXECDIR} 
...                                name=default
...                                bundle_path=None
...                                release=SBTS23R4
${btsremoteip}=    10.63.48.12
${dcaphost}=    10.41.209.120
${sw_release}=    SBTS23R4
${MCG_host}=    10.53.252.66
${UE_PC_IP}                 10.53.252.66                                              # Windows UE PC IP
${BTS_M_plane_ip}           10.63.48.12                                               # BTS M PLane IP
${DCAP_host}                10.41.209.120                                             #DCAP server IP
${Windows_user}             inbabtslabuser                                            # Windows UE PC username
${Windows_pass}             BT5l@bus3rl0g1n                                             
${file_path}=    pcilock.log
${dcap_log_timeout}=	800s
${btsuserremote}=    Nemuadmin
${btspassremote}=    nemuuser
${uepc_Log_path}            C://Users//inbabtslabuser//Documents//Automation_logs
${ABIO_Primary}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-5
${ABIO_Secondary}=	 /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-1
${resettype}=    HARD
${resettimeout}=    2000s
@{Check}    Create List    rrcConnectionSetupComplete-r13::selectedPLMN-Identity-r13 1
${NrcellId}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-970/NRCELL_R-2
${TestModel}=   TM1_1
@{BeamPatternId} =	0	0	0	0
${polarization}=    P_plus45_or_0
${powerBackoff}=   0
${ruMode}=   NR_Only
${PhyCellId}=    1
${pmax}=    40
${nrarfcnDl}=   432000
${nrarfcnUl}=	394000
${MIMOrank}=    1
${codebook2antports}=    0
${i11Codebook4antports}=   0
${i2codebook4antports}=    0
${i13codebook4antports}=    0
@{Required_bts_status} =   Test    OnAir  
${interval}=    30s
${cloud_TL_name}=    CLOUD_SRAN_LWG_1ASIL_1ABIA_1FRHF_1FXEB_1FRGU
${Output_file}=    /home/ute/logs/output.xml
${rep_por_cmd}=    ute_reporting_portal send -ro ${Output_file} -tl 1_2_CLOUD1207 -ca RAN_PZ_BLR -p CRT -l ${cloud_TL_name} --sw_version '${str}'
#############
## QC TAGS ##
#############

															 ...								QC_ID_FL00=QC_650529
&{[1][1.0] CB010918_O-RU fault management FH alarm generation and cancellation}                 QC_ID_SBTS23R4=QC_1234

*** Test Cases ***
CB007814G_Verification of NR DL Test Models 
 	
    [Setup]    Run Keywords    Start Btslogs from Local machine    AND     
    ...                        Get_Pre_Active_alarms    AND
    ...			       Set QC_Tag depending on SW version     
    Validate_BTS_STATUS    ${Required_bts_status}[1]
    move_to_test_dedicated_state_Enable
    start_downlinkNr_test
    stop_downlinkNr_test
    move_to_test_dedicated_state_Disable

    [Teardown]      Run Keywords    Stops Btslogs from Local machine    AND
    ...                             Test_Teardown_Keywords    AND
    ...                             Get_Post_Active_alarms  
	
	
*** Keywords ***

move_to_test_dedicated_state_Enable    
    admin.reset_to_test_dedicated     detailed_output=True
	
    sleep    8m    To check the state of BTS after enable.
	Validate_BTS_STATUS    ${Required_bts_status}[0]
	
	
move_to_test_dedicated_state_Disable  
    admin.reset_site
    sleep     10m     To check the state of BTS after disable.
	Validate_BTS_STATUS    ${Required_bts_status}[1]


start_downlinkNr_test
	admin.start_5g_downlink_test    dist_name=${NrcellId}
	...								test_model=${TestModel}   
	...								beam_pattern_id=@{BeamPatternId}
	...								polarization=${polarization}
	...								power_backoff=${powerBackoff}    
	...								ru_mode=${ruMode}
	...								phys_cell_id=${PhyCellId}
	...								codebook_2_antports=${codebook2antports}
	...								i11_codebook_4_antports=${i11Codebook4antports}
	...								i2_codebook_4_antports=${i2codebook4antports}
	...								i13_codebook_4_antports=${i13codebook4antports}
	...								mimo_rank=${MIMOrank}
	...								p_max=${pmax}
	...								nrarfcn_dl=${nrarfcnDl}
	...								nrarfcn_ul=${nrarfcnUl}
	sleep   5m
	
	
stop_downlinkNr_test
	admin.stop_5g_downlink_test    dist_name=${NrcellId}
	
	
Stops Btslogs from Local machine
    [Documentation]    path from where to get btslog files default value: \u201c/tmp/btslog2\u201d
    #[Arguments]    ${log_alias}   
    Run Keyword And Continue On Failure     core.stop_collectors      btslog   
    Run Keyword And Continue On Failure     core.collect_collectors      btslog   
    Run Keyword And Continue On Failure    core.teardown_collectors      btslog  


Start Btslogs from Local machine
    [Documentation]    path from where to get btslog files default value: \u201c/tmp/btslog2\u201d
    #[Arguments]    ${log_alias}    
    btslog.create_btslog_collector    btslog
    ...    log_dir=/tmp/btslog2    
    core.setup_collectors     btslog
    core.start_collectors     btslog 
    core.Set Suite Alias    btslog


Get Date
    [Documentation]     Get date to create testcase folder
    ${date}    Get Current Date    result_format=%d_%m_%Y_%H%M%S_%f
    ${date}    Convert to String    ${date}
    Set global variable    ${Folder}    ${date}


Create__logs_path_Directory
    Get Date
    #[Documentation]     Get date to create testcase folder
    ${date}    Get Current Date    result_format=%d_%m_%Y_%H%M%S_%f
    ${date}    Convert to String    ${date}
    Set global variable    ${date}
    Set global variable    ${Folder}    ${date}
    Create testcase folder


Create testcase folder
    [Documentation]     Create testcase folder in testpc
    ${val}    Run Keyword And Return Status    LOG    ${LOGS_PATH}/${TEST_NAME}
    #Run Keyword If    ${val} == False    Get Date
    create directory    ${SUITE NAME}${Folder}/${LOGS_PATH}/${TEST_NAME}/DCAP_Logs


Create_Suite_Directory
	create directory    ${SUITE NAME}${Folder}


Validate_BTS_STATUS
	[Arguments]    ${Required_BTS_Status}
	admin.connect_to
    	${bts_status}=  admin.get_bts_statuses
	${var}  Set Variable    ${bts_status['proceduralState']}
	${str}  BuiltIn.Convert To String    ${var}
	Should Be Equal    ${str}    ${Required_BTS_Status}


Set QC_Tag depending on SW version
    	admin.connect_to
	${v}=    admin.get_software_info    timeout=30
	LOG    ********* Active SW Version is ${v['Active SW version']}*********
	${ActiveSW}    Set Variable    ${v['Active SW version']}
	${ActiveSWstr}  BuiltIn.Convert To String    ${ActiveSW}
	Set Suite Variable    ${OUT_ENB_ACTIVE_SW}    ${ActiveSWstr}
	${release}=    Fetch From Left    ${OUT_ENB_ACTIVE_SW}    _
	${branch_check}=    Split string    ${OUT_ENB_ACTIVE_SW}     separator=_    max_split=3
	${sw_release}=    Run Keyword If    "${branch_check[2]}"=="9999"    Set Variable    FL00
    	...     ELSE    Set Variable    ${release}
    	Set Suite Variable    ${sw_release}
    	${QC_ID}=    Set Variable    &{${TEST_NAME}}[QC_ID_${sw_release}]
    	Set Tags    ${QC_ID}


Report_to_Scout
	admin.connect_to
	${v}=    admin.get_software_info    timeout=30
	${ActiveSW}    Set Variable    ${v['Active SW version']}
	${str}    BuiltIn.Convert To String    ${ActiveSW}
	LOG    ${ActiveSW}	
	LOG    ${str}
	SSHLibrary.Close All Connections
	SSHLibrary.Open Connection    host=${VM_HOST_IP}
	SSHLibrary.Login    username=${VM_username}    password=${VM_Password}    delay=10
	SSHLibrary.Execute Command    command=${rep_por_cmd}    
	SSHLibrary.Close All Connections  


Link SCOUT SCF to Configuration ID for Reporting
    [Documentation]
    ...    Associate the SCF to the Configuration ID in Reporting Portal using SCOUT.
    ...
    ...    Example:
    ...     |  Link SCOUT SCF to Configuration ID for Reporting    node_id=${0}    node_type=enb
    ...
    ...     |param node_id | (default=0) Id/Number of Node (eNB or gNB) |
    ...     |param node_type | (default=gnb) Node type; possible values: gnb or enb |

    [Arguments]    ${node_id}=${0}    ${node_type}=enb    ${tl_name_only}=1_2_CLOUD1207	
    ${node_type_Name}        Run Keyword If  "${node_type}"=="gnb"   Set Variable  gNB
    ...     ELSE IF     "${node_type}"=="enb"                   Set Variable  eNB
    ...     ELSE        Fail    Wrong node_type '${node_type}'! allowed: enb|gnb
    Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only}
    ${scout_testline_name}=    Set Variable    ${tl_name_only}
    ${external_scf_id}=   Request Scout SCF   ${scout_testline_name}
    ${TC_ID}=    Set Variable    ute:id:${external_scf_id}
    Set Tags  ${TC_ID}
	
	
Request Scout SCF
    [Arguments]   ${scout_testline_name}
    [Documentation]    :Author: Michele
    ...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    scout.setup_scout  scout_testline_name=${scout_testline_name}
    ${external_scf_id}=   scout.request_scf   use_scout_internal_id=True
    scout.teardown_scout_api
    [Return]   ${external_scf_id}
	
	
Get_Pre_Active_alarms
    [Documentation]    Active Alarms
    admin.connect_to
    ${Pre_Active_Alarm}    admin.get_active_alarms 


Get_Post_Active_alarms
    [Documentation]    Active Alarms
    ${Post_Active_Alarm}   admin.get_active_alarms

Suite Setup
    Log to console    \n--Suite Setup--\n
    Log to console    \n--TEST Started--\n
    Create_Suite_Directory

Suite Postcondition
	#Get_Pre_Active_alarms
	Report_to_Scout


Test_Teardown_Keywords
    [Documentation]    Test post condition
	#common_suite_teardown
    #Run Keyword And Continue On Failure    interface.Common step trigger
    admin.teardown_admin
	Link SCOUT SCF to Configuration ID for Reporting 


Dcap Start Trace
    #[Documentation]     Start DCAP logs with custom filter
    Create__logs_path_Directory
    dcap.connect_to  host=${dcaphost}   port=443    username=dcapuser   password=dcapadmin!  
    ...              rd_version=dcapv3  secure=True
    &{bts1_info}   create dictionary  host=${btsremoteip}    port=443    username=${btsuserremote}    password=${btspassremote}
    ${output}    dcap.start_trace     duration=-1    bts=&{bts1_info}    gnb_trace_profile=dcap-lite-default 
	...          bts_trace_profile=dcap-lite-default 
	...          enb_trace_profile=dcap-lite-default 
    Sleep       500s      reason=Wait for DCAP start
    ${START_TRACE_ID}      Get from Dictionary    ${output}    id
    Set Suite Variable  ${START_TRACE_ID}
    LOG      DCAP log collection has been started in the gNB


Dcap Stop Trace
    [Documentation]     Stops DCAP and collect logs
    Log to console      \nStopping DCAP trace ID ${START_TRACE_ID} and collecting logs
    dcap.stop_trace    trace_id=${START_TRACE_ID}
    Sleep    60
    LOG     DCAP logging stopped
    dcap.get_results    result_id=${START_TRACE_ID}    target_dir=${SUITE NAME}${Folder}/${LOGS_PATH}/${TEST_NAME}/DCAP_Logs    
	...                                                timeout=${dcap_log_timeout}

