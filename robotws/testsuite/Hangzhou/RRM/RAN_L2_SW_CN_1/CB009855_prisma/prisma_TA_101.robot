*** Settings ***
Documentation    ...
#Documentation    pybot -V ./init_99/ -L trace prisma_TA_99.robot
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Library           taf.ue.prisma     WITH NAME    prisma
#Suite Setup       Create Suite Directory
#Suite Teardown
#Test Setup        Create Test Directory
##Test Teardown     Prisma Teardown
#
#*** Variables ***
#${prisma_set_file}    ${CURDIR}/prisma_99.yml
#${prisma_config_path}    ${CURDIR}${/}prisma_99${/}
#${sce_file}    0320udg.sce
#${sid_name}     0323.sid
#${lsu_s1}       lsu_s1
#${lsu_uu}         lsu_uu
#${tstm_uu}     tstm_uu
#${airmosaic}      airmosaic
#${node_name}      airmosaic
#${5gcell_path1}    /res/sdr/state/r5gnr.ue/01
#${5gcell_path2}    /res/sdr/state/r5gnr.ue/02
#${ltecell_path}    /res/sdr/state/ltefdd.ue/05
#${SYNC}           STATE_00 = SYNC
#${check_attach}    trcinfo -p 0-5|grep RA_S
#${ue_num}    40
#${interval_time}    2
##&{iperf_server}    ip=10.57.205.40    username=ute    password=ute    connection=iperf_server
##&{iperf_server}    ip=10.57.212.158    username=nokia    password=nokia123    connection=iperf_server
##&{prisma_pc}    ip=10.64.55.99    username=mn5gran    password=nokia123@    connection=prisma_pc
#
#*** Test Cases ***
#prisma_case
##    Backup Scf    ${SUITE_LOG_DIRECTORY}    before_test
#    # Get All Testline Information And Set Suite Variable
##    Verify Coam Site Is Ready
#    Prisma Setup    ${prisma_set_file}    ${tl.ues[0]}
#    Prisma Start Lsu And Wait Cell Ready
#    Prisma Airmosaic Start    ${sid_name}    ${/}${prisma_config_path}
#    Prisma Execute Case SCE    ${sce_file}
#
#*** Keywords ***
#Verify Coam Site Is Ready
#    [Documentation]    This keyword is to check the state of gNB is configured and Radio is online.
#    Log To Console    verify bts site is ready...
#    Wait Until Keyword Succeeds    ${MAX_WAITTIME_CELL_SETUP}    30s    Verify BTS Is Configured
#    Wait Until Keyword Succeeds    ${MAX_WAITTIME_CELL_SETUP}    30s    Verify Radio Is Online
#
#Verify BTS Is Configured
#    [Documentation]    This keyword is to check the state of gNB is Configured or IntegratedToRan
#    Log To Console    verify BTS is configured...
#    Run Keyword And Ignore Error    COAM.Setup Admin
#    ${bts_state}    COAM.Get Mrbts State
#    Log To Console    [INFO] BTS STATE : ${bts_state}
#    Should Contain Any    ${bts_state}    Configured    IntegratedToRan    OnAir    ignore_case=True
#    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown
#
#Verify Radio Is Online
#    [Documentation]    This keyword is to check the state of Radios are online
#    Log To Console    verify Radio is online...
#    Run Keyword And Ignore Error    COAM.Setup Admin
#    ${cell_info}    Get Cell List
#    ${ru_nums}    Evaluate    len(${cell_info['cells']['nr']})
#    FOR    ${id}    IN RANGE    0    ${ru_nums}
#        ${radio_state}    Set Variable    ${cell_info['cells']['nr'][${id}]['status']['operationalState']}
#        ${cell_id}    Set Variable    ${cell_info['cells']['nr'][${id}]['globalCellId']}
#        Log To Console    [INFO]    Cell_${cell_id}    STATE : ${radio_state}
#        Should Be Equal As Strings    ${radio_state}    enabled    ignore_case=True
#    END
#    Log To Console    All raido is online
#    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown Admin
#
#Save Snapshot Log
#    [Arguments]    ${log_dir}=${SUITE_LOG_DIRECTORY}
#    [Documentation]    This keyword is to save snapshot log from admin.
#    Log To Console    Save Snapshot Log...
#    Run Keyword And Ignore Error    COAM.Setup Admin
#    COAM.Collect Snapshot    ${log_dir}//Snapshot.zip
#    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown
#
#Prisma Setup
#    [Arguments]    ${yaml_path}    ${tl_info}
#    [Documentation]    This keyword is used to setup prisma.
#    ...    | Input Parameters | Man. | Description |
#    ...    | yaml_path | Yes | path of yaml file |
#    ...    | tl_info | Yes | variable for prisma |
#    ...    Example:
#    ...    | Prisma Setup | ${CURDIR}/risma.yml | ${tl.ues[0]} |
#    prisma.load_config    ${yaml_path}    ${tl_info}
#    prisma.setup
#    Log To Console    Prisma Setup done
#
#Prisma Teardown
#    [Documentation]    This keyword is used to teardown prisma.
#    Run Keyword And Ignore Error    prisma.get_tstm_log    ${tstm_uu}
#    Run Keyword And Ignore Error    prisma.get_bug_report    ${TEST_LOG_DIRECTORY}/prisma_bug_report.zip
#    Run Keyword And Ignore Error    prisma.close_mosaic
#    # Save Snapshot Log
#    prisma.teardown
#
#Prisma Start Lsu And Wait Cell Ready
#    [Documentation]    This keyword is used to start lsu and wait cell ready.
#    ...    lsustop;lsuclean;lsustart
#    # Put swconfig file to gnb    ${CONFIG_DIR_PATH}/${SW_BRANCH}/SWCONFIG/${GNB_SWCONFIG_QUAL_NAME}
#    # Do Full Commissioning    ${CONFIG_DIR_PATH}/${SW_BRANCH}/SCF/${SCFC_NAME}
#    ${response}=    prisma.start_lsu    ${lsu_s1}    200
#    should contain    ${response[1]}    lsustart completed correctly
#    #prisma doesn't need this step now.prisma can sync automatically
##    ${ret_5g_cell}    prisma.create_5g_cell    ${lsu_uu}
##    ${ret_4g_cell}    prisma.create_4g_cell    ${lsu_uu}
#    #can't find sync file on current eLSU now.
##    wait until keyword succeeds    7 min    20 sec    Check NRcell Sync    ${5gcell_path1}
##    wait until keyword succeeds    7 min    20 sec    Check NRcell Sync    ${5gcell_path2}
##    wait until keyword succeeds    3 min    20 sec    Check LTECell Sync    ${ltecell_path}
#    Sleep    60s    wait for Lsu cell sync...
#    Log To Console    Prisma Start Lsu and all cells are sync now.
#
#Check NRcell Sync
#    [Arguments]    ${5gcell_path}
#    ${output}    prisma.execute_script    node_name=${lsu_uu}    script_cmd=cat ${5gcell_path} | grep SYNC
#    Should Contain    ${output[1]}    ${SYNC}
#    Log To Console    NRcell sync now.
#
#Check LTECell Sync
#    [Arguments]    ${ltecell_path}
#    ${output}    prisma.execute_script    node_name=${lsu_uu}    script_cmd=cat ${ltecell_path}
#    Should Not Contain    ${output[1]}    NOT_SYNCHRONIZED
#    Log To Console    LTECell sync now.
#
#Prisma Airmosaic Start
#    [Arguments]    ${sid_name}    ${sce_path}
#    [Documentation]    This keyword is used to start prisma Airmosaic.
#    ...    note:DefaultLabDeviceFromSID.mdl and Milan_template_100ue_sq6.usr must be with fie.sid together.
#    ...    | Input Parameters | Man. | Description |
#    ...    | sid_name | Yes | name of sid |
#    ...    | sce_path | Yes | path of sce |
#    ...    Example:
#    ...    | Prisma Airmosaic Start | gaolei.sid | ${CURDIR}${/}SA_scenario |
#    prisma.close_mosaic
#    ${output}    prisma.start_mosaic
#    Should Contain    ${output[1]}    Harness enabled
#    Sleep    15s
#    Run Keyword And Ignore Error    prisma.stop_tstm    ${tstm_uu}
#    ${output}    prisma.start_tstm    ${tstm_uu}
#    Sleep    60s
#    prisma.prepare_test    ${sid_name}    ${prisma_config_path}    180
#    ${ret}    prisma.get_scenario_status
#    Should Contain    ${ret}    SIMINIT_COMPLETED
#    Log To Console    Start mosaic and tstm done. SIMINIT_COMPLETED
#
#Prisma Execute Case SCE
#    [Arguments]    ${sce}
#        prisma.Execute Test    ${sce}
#
#Prisma Ue Attach
#    [Arguments]    ${ue_num}=1    ${interval_time}=2
#    [Documentation]    This keyword is used to ue attach.
#    ...
#    ...    | Input Parameters | Man. | Description |
#    ...    | ${ue_num} | No | the number of UE needed to attach in scenario file, the default value is 1 |
#    ...    | ${interval_time} | No | the interval_time between UE attach set in scenario file, the default value is 2(s) |
#    ...
#    ...    Examples:
#    ...    | Prisma Ue Attach | 40 | 3 |
#    prisma.ue_attach
#    ${sce_status}    prisma.get_scenario_status
#    Should Be Equal    ${sce_status}    RUNNING_SCENARIO
#    # sleep    60
#    ${wait_time}    Evaluate    ${ue_num}*${interval_time}+5
#    Wait Until Keyword Succeeds    ${wait_time}s    10s    Check Ue Attach Sucessful    ${ue_num}
#    Log To Console    ${ue_num} UE attach done.
#
#Check Ue Attach Sucessful
#    [Arguments]    ${ue_num}
#    ${output}    prisma.execute_script    node_name=${lsu_uu}    script_cmd=${check_attach}
#    ${output}    Convert To String    ${output}
#    ${times}    Evaluate    ${ue_num}*2
#    Get Count    ${output}    RA_SuccessCompletion
#    Should Contain X Times    ${output}    RA_SuccessCompletion    ${times}
#    Log To Console    ${ue_num} UE attach successful.
#
#Get UE IP
#    ${ret}    prisma.get_scenario_logger
#    ${ret}    Convert To String    ${ret}
#    ${regexp}    Set Variable    UE Attached[\\s\\S]*?PDN address assigned: IPv4=(?P<IP>\\d+.\\d+.\\d+.\\d+)
#    ${ue_ip_list}    Get Regexp Matches    ${ret}    ${regexp}    IP
#    [Return]    ${ue_ip_list}
#
#Check Scenario Status Is SCENARIO_COMPLETED
#    ${sce_status}    prisma.get_scenario_status
#    Should Be Equal    ${sce_status}    SCENARIO_COMPLETED
#
#_check Scenario Logger
#    [Arguments]    ${msg}    ${times}
#    ${ret}    prisma.get_scenario_logger
#    ${ret}    Convert To String    ${ret}
#    Should Contain X Times    ${ret}    ${msg}    ${times}
#    set suite variable    ${scenario_log}    ${ret}
#
#Prisma Ue Detach
#    prisma.ue_detach
#
#Check Ue Dettach Sucessful
#    [Arguments]    ${ue_num}
#    ${ret}    prisma.get_tstm_log    ${tstm_uu}
#    ${ret}    Convert To String    ${ret}
#    Should Contain X Times    ${ret}    DETACH SUCCESSFUL    ${ue_num}
#    Log To Console    ${ue_num} UE detach successful.
#
#Prisma get counters
#    [Documentation]    This keyword is used to get counters.
#    ...    Example:
#    ...    | ${tp} | Prisma get counters |
#    ...    | should be true | ${tp['DigitalBeams_1_0_bNrPdschGenIniThroughput']} > 500000 |
#    ${ret}    prisma.get_counters
#    ${counters}    Create Dictionary
#    : FOR    ${counter}    IN    @{ret}
#    \    Set To Dictionary    ${counters}    ${counter['category']}_${counter['instance']}_${counter['name']}    ${counter['value']}
#    [Return]    ${counters}
#
#Start DL UDP Tranffic With Iperf
#    [Arguments]    ${ue_ip}    ${dlmbps}    ${len}    ${duration}    ${dl_port}=54048
#    ${dl_cmd}    Set Variable    iperf -c ${ue_ip} -u -b ${dlmbps}M -i 1 -l ${len} -t ${duration} -p ${dl_port}
#    ${result}    Run Keyword    Process.Start Process
#    ...    sshpass -p ${iperf_server.password} ssh ${iperf_server.username}@${iperf_server.ip} ${dl_cmd}    shell=${TRUE}
#    Log To Console     Running DL Traffic ${dlmbps}M for ${duration}s
#    [Return]    ${result}
#
## Stop DL UDP Tranffic With Iperf
##     [Arguments]    ${ue_ip}
##     ${cmd}    Set Variable    ps aux | grep '${ue_ip}' | grep -v 'grep' |awk '{print $2}'|xargs kill -9
##     ${result}    Run Keyword    Process.Start Process
##     ...    sshpass -p ${iperf_server.password} ssh ${iperf_server.username}@${iperf_server.ip} ${cmd}    shell=${TRUE}
##     Log To Console     Stop DL Traffic for UE ${ue_ip}
##     [Return]    ${result}
#
#Stop DL UDP Tranffic With Iperf
#    [Arguments]    ${ue_ip}
#    ${IPERF_CONNECTION}    SSH.Connect To    hostname=${iperf_server.ip}    username=${iperf_server.username}
#    ...    password=${iperf_server.password}    alias=${iperf_server.connection}
#    ${cmd}    Set Variable    ps aux | grep '${ue_ip}' | grep -v 'grep' |awk '{print $2}'|xargs kill -9
#    ${process}    SSH.Execute    command=${cmd}    connection=${IPERF_CONNECTION}
#    SSH.Disconnect    connection=${IPERF_CONNECTION}
#
#Get APC UE IP From Sce file
#    [Arguments]    ${sce_file}
#    ${content}    OperatingSystem.Get File    path=${sce_file}
#    ${apc_ue_ip_list}    String.Get Regexp Matches    ${content}    :(?P<apc_ue_ip>\\d+.\\d+.\\d+.\\d+)    apc_ue_ip
#    [Return]    ${apc_ue_ip_list}
#
#Start UL UDP Tranffic With Iperf
#    [Arguments]    ${ue_ip}    ${ulmbps}    ${len}    ${duration}    ${ul_port}=50019
#    ${ul_iperf_path}    Set Variable    /cygdrive/c/Users/Prisma/iperf_TA/iperf.exe
#    ${ul_cmd}    Set Variable    -c 10.57.205.26 -t ${duration} -u -p ${ul_port} -l ${len} -i 1 -B ${ue_ip} -b ${ulmbps}M
#    ${result}    Run Keyword    Process.Start Process
#    ...    sshpass -p ${prisma_pc.password} ssh ${prisma_pc.username}@${prisma_pc.ip} ${ul_iperf_path} ${ul_cmd}
#    ...    shell=${TRUE}
#    Log To Console     Running UL Traffic ${ulmbps}M for ${duration}s
#    [Return]    ${result}
#
## Stop UL UDP Tranffic With Iperf
##     ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output
##     ...    sshpass -p ${prisma_pc.password} ssh ${prisma_pc.username}@${prisma_pc.ip} ps -ef |grep iperf
##     ${cmd}    Set Variable    taskkill /f /im iperf.exe
##     ${result}    Run Keyword    Process.Start Process
##     ...    sshpass -p ${prisma_pc.password} ssh ${prisma_pc.username}@${prisma_pc.ip} ${cmd}    shell=${TRUE}
##     ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output
##     ...    sshpass -p ${prisma_pc.password} ssh ${prisma_pc.username}@${prisma_pc.ip} ps -ef |grep iperf
##     Log To Console     Stop UL Traffic
##     [Return]    ${result}
#
#Stop UL UDP Tranffic With Iperf
#    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output
#    ...    sshpass -p ${prisma_pc.password} ssh ${prisma_pc.username}@${prisma_pc.ip} ps -ef |grep iperf
#    ${PRISMA_CONNECTION}    SSH.Connect To    hostname=${prisma_pc.ip}    username=${prisma_pc.username}
#    ...    password=${prisma_pc.password}    alias=${prisma_pc.connection}
#    ${cmd}    Set Variable    taskkill /f /im iperf.exe
#    ${process}    SSH.Execute    command=${cmd}    connection=${PRISMA_CONNECTION}
#    SSH.Disconnect    connection=${PRISMA_CONNECTION}
#    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output
#    ...    sshpass -p ${prisma_pc.password} ssh ${prisma_pc.username}@${prisma_pc.ip} ps -ef |grep iperf
#    Log To Console     Stop UL Traffic
