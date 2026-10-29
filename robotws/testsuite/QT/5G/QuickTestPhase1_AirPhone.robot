*** Settings ***
Force Tags    PY39    RF50

Documentation
...        author: Mateusz Porzucek
...        contact: mateusz.porzucek@nokia.com
...        description: Automated triggerring UTE agent and testsuite for L3 call test with AirPhone.

Library    String
Library    OperatingSystem
Library    robot.libraries.DateTime
Library    BuiltIn
Library    Collections
Library    Telnet
Library    taf.transport.ssh        WITH NAME    ssh
Library    taf.collectors.btslog    WITH NAME    btslog
Library    taf.collectors.core
Library    ${CURDIR}/../SRAN/resources/python/QTListener.py
Library    ${CURDIR}/../SRAN/resources/python/airphone.py
Library    ${CURDIR}/../SRAN/resources/python/nidd_check.py
Library    ${CURDIR}/../SRAN/resources/python/NIDD_update.py
Library    ${CURDIR}/../SRAN/resources/python/TestCaseRequirement.py
Resource   ${CURDIR}/../SRAN/resources/robot/common.robot
Resource   ${CURDIR}/../SRAN/resources/robot/additional_check.robot

Suite Setup       QT Setup for UTE
Suite Teardown    Run Keyword And Ignore Error    VMCleanUp And Copy Logs


*** Variables ***
${LOGFILE}    bash_output.log

${topology_config_base_url}           https://gitlabe2.ext.net.nokia.com
${prodzn_token}                       glpat-5kShfyes2MPLTaTp6KRx
${topology_config_project_id}         39803
${TAF_VENV}                           taf_venv
${install_taf_lib_max_try}            3

*** Test Cases ***
Prepare TL via UTE agent
    [Tags]              FULL    Agent
    [Timeout]           90 min
    [Setup]             Run Keywords    Run    rm -rf /home/ute/.ute-ca/logs_*tar.gz
    ...                          AND    Run    rm -rf /home/ute/.ute-ca/ute_ca_logs*.zip
    ...                          AND    Run    rm -rf /home/ute/.ute-ca/executions/*
    Run    cd /home/ute/logs ; sudo touch ap_testcase_log.txt ; sudo chmod 777 ap_testcase_log.txt
    # clean /tmp directory from VM tmp logs:
    ${clean_cmd}        Catenate    sudo rm -rf /home/ute/logs/* /tmp/tmp* /var/tmp* /home/ute/ute_agent_logs/* /home/ute/Desktop/*.zip
    ...                             /home/ute/trunk /home/ute/yaft* /home/ute/YAFT* /home/ute/BTS_T_YAFT*
    ...                             /home/ute/Downloads/*.zip /home/ute/*.zip /opt/wts/*
    Run    ${clean_cmd}
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    2min  1min    Kill egate & edaemon
    Preparation TL via UTE agent
    # debug agent issue:
    Run Keyword And Ignore Error    Run    ls -lh /tmp
    Run Keyword If      '${tl_preparation}'=='False'    Fail    ERROR OCCURRED in common-agent execution.
    Run    rm -rf /home/ute/logs; mkdir -p /home/ute/logs
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    Agent Teardown    ${agent_logs}
    ...                    AND    Run Keyword If Test Failed      Additional check in TC
    ...                    AND    Run Keyword If Test Failed      Collect SosReport

Run Testsuite L3call_Sequential robot
    [Tags]              FULL    AP_Agent    sosreport    ATT_DT    TELECOM
    [Timeout]           65 min
    [Setup]             Run Keywords    Requires TC    Prepare TL via UTE agent
    ...                          AND    Run Keyword And Ignore Error    Start BTSlogs Collection
    ${sosreport_tag}    Run         ps aux | grep python | grep sosreport | grep -v grep
    ${loging_on_off}    Set Variable If    'sosreport' in '${sosreport_tag}'    False    True
    ${component_carrier}    Set Variable If    'ASIL_ABIO_5G_SANSA_FDD_TDD_Airphone' in '${cellConfiguration}'    2    1
    ${command}       Catenate       cd /home/ute && python -m robot -L TRACE
    ...                             -d ${OUTPUT DIR} -l ${AP_L3call_log_name}_log.html -r ${AP_L3call_log_name}_report.html
    ...                             -b ${AP_L3call_log_name}_debug.log -o ${AP_L3call_log_name}_output.xml
    ...                             -v TRF_DURATION:3mins -v MTp_FR1_TDD_SA_dl:300 -v MTp_FR1_TDD_SA_ul:30
    ...                             -v MTp_FR1_TDD_NSA_dl:300 -v MTp_FR1_TDD_NSA_ul:30 -i ${test_tag}
    ...                             -v TOPOLOGY:${cloud_topology} -v COMPONENT_CARRIER:${component_carrier}
    ...                             -v CONDITIONAL_LOGGING:${loging_on_off} -v ENABLE_CRASH_DETECTION:False
    ...                             -V /home/ute/testline_configuration/$(hostname|tr '-' '_')/
    ...                             /home/ute/robotws/testsuite/Bangalore/AirPhone/QT/${testsuite}
    Log To Console      \n\nExecute: ${command}
    ${output}    Run    ${command}
    Should Not Contain Any    ${output}
    ...    No space left on device    ERROR: ResolutionImpossible    ERROR: Could not open requirements file
    ...    The system will reboot now
    ...    msg=env preparation failed, please check!!!
    Run    cp /opt/wts/latest/egate_console.log ${OUTPUT DIR}/gNB_AP_Logs/egate_console.log

Verify Ng Link Status
    [Tags]              FULL    AP_Agent    ATT_DT    TELECOM   SA    5G0
    [Setup]             Requires TC    Run Testsuite L3call_Sequential robot
    Check AP Debug Log  ng_link_status_is_ok
    [Teardown]          L3call Case Teardown

Verify Address Distribution
    [Tags]              FULL    AP_Agent    ATT_DT    TELECOM   SA    NSA    SANSA    5G0
    [Setup]             Requires TC    Run Testsuite L3call_Sequential robot
    Check AP Debug Log  address_distribution_is_ok
    [Teardown]          L3call Case Teardown

UE SIB Decoding
    [Tags]              FULL    AP_Agent    ATT_DT    TELECOM   SA    5G0
    [Setup]             Requires TC    Run Testsuite L3call_Sequential robot
    Check AP Debug Log  ue_sib_decoding_is_ok
    [Teardown]          L3call Case Teardown

X2 Connection
    [Tags]              FULL    AP_Agent    ATT_DT    TELECOM   SA    NSA    5G0
    [Setup]             Requires TC    Run Testsuite L3call_Sequential robot
    Check AP Debug Log  x2_is_ok
    [Teardown]          L3call Case Teardown

Verify Cell Setup for AP
    [Tags]              FULL    AP_Agent    ATT_DT    TELECOM    SA    NSA    SANSA
    [Setup]             Requires TC    Run Testsuite L3call_Sequential robot
    Check AP Debug Log  cell_setup_is_ok
    [Teardown]          L3call Case Teardown

UE Register
    [Tags]              FULL    AP_Agent    ATT_DT    TELECOM    SA   L3call
    [Setup]             Requires TC    Run Testsuite L3call_Sequential robot
    Check AP Debug Log  ue_register_is_ok
    [Teardown]          L3call Case Teardown

LTE Attach
    [Tags]              FULL    AP_Agent    ATT_DT    TELECOM   NSA    L3call
    [Setup]             Requires TC    Run Testsuite L3call_Sequential robot
    Check AP Debug Log  lte_attach_is_ok
    [Teardown]          L3call Case Teardown

UE Attach
    [Tags]              FULL    AP_Agent    ATT_DT    TELECOM    NSA    L3call
    [Setup]             Requires TC    Run Testsuite L3call_Sequential robot
    Check AP Debug Log  ue_attach_is_ok
    [Teardown]          L3call Case Teardown

SA Traffic
    [Tags]              FULL    AP_Agent    ATT_DT    TELECOM   SA    L3call
    [Setup]             Requires TC    Run Testsuite L3call_Sequential robot
    Check AP Debug Log  sa_traffic_is_ok
    [Teardown]          L3call Case Teardown

NSA Traffic
    [Tags]              FULL    AP_Agent    ATT_DT    TELECOM    NSA    L3call
    [Setup]             Requires TC    Run Testsuite L3call_Sequential robot
    Check AP Debug Log  nsa_traffic_is_ok
    [Teardown]          L3call Case Teardown

UE Deregister
    [Tags]              FULL    AP_Agent    ATT_DT    TELECOM    SA    L3call
    [Setup]             Requires TC    Run Testsuite L3call_Sequential robot
    Check AP Debug Log  ue_deregister_is_ok
    [Teardown]          L3call Case Teardown

UE Reregister
    [Tags]              FULL    AP_Agent    ATT_DT    TELECOM    SA    L3call
    [Setup]             Requires TC    Run Testsuite L3call_Sequential robot
    Check AP Debug Log  ue_re-register_is_ok
    [Teardown]          L3call Case Teardown

SA UE Deregister
    [Tags]              FULL    AP_Agent    ATT_DT    TELECOM   SA    L3call
    [Setup]             Requires TC    Run Testsuite L3call_Sequential robot
    Check AP Debug Log  sa_ue_deregister_is_ok
    [Teardown]          L3call Case Teardown

UE 5GDetach
    [Tags]              FULL    AP_Agent    ATT_DT    TELECOM    NSA    L3call
    [Setup]             Requires TC    Run Testsuite L3call_Sequential robot
    Check AP Debug Log  5gdetach_is_ok
    [Teardown]          L3call Case Teardown

UE Detach
    [Tags]              FULL    AP_Agent    ATT_DT    TELECOM    NSA    L3call
    [Setup]             Requires TC    Run Testsuite L3call_Sequential robot
    Check AP Debug Log  detach_is_ok
    [Teardown]          L3call Case Teardown

UE Reattach
    [Tags]              FULL    AP_Agent    ATT_DT    TELECOM    NSA    L3call
    [Setup]             Requires TC    Run Testsuite L3call_Sequential robot
    Check AP Debug Log  reattach_is_ok
    [Teardown]          L3call Case Teardown

Check Active And Historical Alarms
    [Tags]    FULL    ATT_DT    TELECOM    L3call    SA    NSA
    [Setup]             Requires TC    Run Testsuite L3call_Sequential robot
    Check AP Debug Log  check_allowed_alarms_is_ok
    [Teardown]          L3call Case Teardown

*** Keywords ***
QT Setup for UTE
    Set Suite Variable    ${LOG_PATH}    ${OUTPUT_DIR}/Additional_Execution_Logs
    Create Directory    ${LOG_PATH}
    Create Directory    ${OUTPUT DIR}/gNB_AP_Logs
    ${duplex}           Get Variable Value    ${duplex}    XXX
    ${is_FDD}           Evaluate    "fdd" in """${STREAM}""" or "FDD" in """${STREAM}""" or "${duplex}"=="FDD" or "${duplex}"=="fdd"
    ${fdd_tdd}          Set Variable If    '${is_FDD}' == 'True'    fdd    tdd
    ${FDD/TDD}          Set Variable If    '${is_FDD}' == 'True'    FDD    TDD
    ${streamVersion}    Set Variable If    'SBTS' in '${loadBuild}'    ${branch}    ${streamVersion}
    Set Suite Variable    ${configuration}              Airphone_ASIL_ABIO_TDD_eCPRI_cmwv
    Set Suite Variable    ${testsuite}                  L3call_Sequential.robot
    Set Suite Variable    ${topology_config_variant}    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC
    Set Suite Variable    ${tl_topology}                CLOUD_5G_I_LO_AP_LO
    Set Suite Variable    ${cloud_topology}    CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC
    Set Suite Variable    ${test_tag}          FULL_RUN
    Set Suite Variable    ${deployment}        SANSA
    Set Suite Variable    ${streamVersion}
    Set Suite Variable    ${fdd_tdd}
    Set Suite Variable    ${FDD/TDD}
    Set Suite Variable    ${AP_configs}     ${WORKSPACE}/AP_configs_repo
    Set Suite Variable    ${AP_L3call_log_name}    ${testsuite.split('.robot')[0]}
    Set Suite Variable    ${fail_msg_info}    \n >>>>> Check ${AP_L3call_log_name}_log.html for more info ! <<<<< \n

Kill egate & edaemon
    Log To Console      \n--> INFO: Kill egate & edaemon...     no_newline=True
    Run         sudo pkill egate
    Run         sudo pkill edaemon
    BuiltIn.Sleep               2s
    ${egate}            Run    ps aux | grep egate
    Should Not Contain  ${egate}       --port
    ${edaemon}          Run    ps aux | grep edaemon
    Should Not Contain  ${edaemon}     --port
    Log To Console      --> [DONE]

Check UTE INFO_log
    [Arguments]         ${agent_logs}
    Set Suite Variable  ${tl_preparation}    in_progress
    ${console_log}      Run     tail -n 8 ${agent_logs}/ute_ca_logs/agent.log
    Log To Console      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * \n\ ${console_log}
    ${check_log}        Run     cat ${agent_logs}/ute_ca_logs/agent.log | grep -i 'EXECUTION FINISHED WITH STATE: Passed'
    ${check_err}        Run     cat ${agent_logs}/ute_ca_logs/agent.log | grep -i 'EXIT CODE'
    IF    $check_log is not None and ${{len($check_log)}} > 0 and 'No such file or directory' not in '''${check_log.replace("'", "")}'''
        Set Suite Variable  ${tl_preparation}    True
    ELSE IF    $check_err is not None and ${{len($check_err)}} > 0
        Set Suite Variable    ${tl_preparation}    False
    END
    Log To Console    ${check_log}

Check AP Debug Log
    [Arguments]         ${grep_text}
    ${debug_check}      Run    cat ${OUTPUT DIR}/${AP_L3call_log_name}_debug.log | grep "INFO - ${grep_text}"
    Should Contain      ${debug_check}    ${grep_text}

Check Throughput
    ${check_throughput}    Run    cat /home/ute/logs/l3call_tp.txt
    Log To Console         \n ${check_throughput} \n
    Run            rm /home/ute/logs/l3call_tp.txt

Get gnb build nr for AP
    ${split_PATH}       Split String From Right   ${AF_PATH}   separator=/   max_split=1
    ${build_tmp}        Split String      ${split_PATH[1]}     separator=-   max_split=1  # ['AirScale', '0.800.1553-2ft3h.zip']
    ${build_num}        Get Substring     ${build_tmp[1]}      0    -4                    # ['0.800.1553-2ft3h', 'ASIK_ABIL.zip']
    Set Suite Variable  ${GNB_LOAD}       ${build_num}                                    # '0.800.1553-2ft3h'

Preparation TL via UTE agent
    ${agent_log_check_loop}        Set Variable    120
    ${diff_status_true_false}      Set Variable    False
    ${timestamp}        robot.libraries.DateTime.Get Current Date    result_format=%Y%m%d-%H%M%S
    ${agent_logs}       Catenate    SEPARATOR=/    /home/ute/ute_agent_logs    ${timestamp}
    Set Suite Variable  ${agent_logs}
    ${is_knife}         Run Keyword and Return Status    Should Contain    ${knife_url}    knife
    Set Suite Variable    ${is_knife}
    Run Keyword If      'SBTS' in '${AF_PATH}'    Set Suite Variable    ${GNB_LOAD}    ${loadBuild}
    ...       ELSE                                Get gnb build nr for AP
    Log To Console      --> BUILD gNB: ${GNB_LOAD}
    Run    mkdir /home/ute/.ute-ca/cache/bts/; ln -s /media/builds/${GNB_LOAD} /home/ute/.ute-ca/cache/bts/${GNB_LOAD}
    # Run Keyword If      '${branch}' != 'Testbuild' and '${is_knife}' == 'False'
    # ...                 Run Keyword And Ignore Error    Wait Until Keyword Succeeds    2min  30s    Send AP Attribute To WFT
    Run Keyword And Ignore Error    Kill Apt Process And Reconfigure Dpkg
    Install Common Agent
    Run                 echo ${agent_version} > ${LOG_PATH}/common_agent_version.txt
    Run                 sudo apt-get update; sudo apt-get install procps
    Run Keyword If      '${branch}' != 'Testbuild' and '${is_knife}' == 'False' and '${nidd_ver_ap}'!='${EMPTY}'    Run Keywords
    ...                 Run Keyword And Ignore Error    Get NIDD Sub Version AP
    ...        AND      Run Keyword And Ignore Error    Update configs repo
    ...        ELSE IF  '${branch}' != 'Testbuild' and '${is_knife}' == 'False' and '${nidd_ver_ap}'=='${EMPTY}'
    ...        log    Skip NIDD check as nidd_ver_ap is NOT available!!! Please check if nidd_ver_ap is successfuly accquired in pipeline!   WARN
    ${command}          Catenate    mkdir -p ${agent_logs}; cd ${agent_logs};
    ...                             sudo systemctl daemon-reload; sudo systemctl restart ute-ca.service;
    ...                             agentctl exec --label '${tl_topology}'
    ...                             --sm-build '${GNB_LOAD}' --airphone-build '${AP_BUILD}'
    ...                             --required-state 'configured' --variant '${topology_config_variant}' --tools-profile CUS_WTS
    ${local_config}     Catenate    ${command} --local-topology-config '/home/ute/AP_configs_repo/${tl_topology}/${release}/'
    ${command}     Set Variable If    '${diff_status_true_false}'=='${True}' or '${custom_config}'=='${True}'    ${local_config}
    ...                               ${command}
    Log To Console      \nCommand sent: ${command} \n
    Run    nohup ${command} > /home/ute/logs/command_output.log 2>&1 &
    FOR    ${_}    IN RANGE    100
        Log    Attempt ${_} to check if file exists
        ${file_exists}    Run Keyword And Return Status    File Should Exist    ${agent_logs}/ute_ca_logs/agent.log
        Run Keyword If    '${file_exists}' == 'True'    Exit For Loop
        Log    File not found, waiting for 10s
        BuiltIn.Sleep               10s
    END
    IF    not ${file_exists}
        ${output}    Run    cat /home/ute/logs/command_output.log
        Fail    ${agent_logs}/ute_ca_logs/agent.log doesn't exist, pls check:\n${output}
    END
    Log    File exists, proceeding with further steps
    BuiltIn.Sleep    30
    ${console_log}      Run    head -n 40 ${agent_logs}/ute_ca_logs/agent.log
    Log To Console      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * \n\n ${console_log}
    FOR    ${index}    IN RANGE    ${agent_log_check_loop}
        Check UTE INFO_log    ${agent_logs}
        Exit For Loop If  '${tl_preparation}' != 'in_progress'
        IF    ${index} == ${${agent_log_check_loop}-1}
            Set Suite Variable    ${tl_preparation}    False
        ELSE
            BuiltIn.Sleep    45s
        END
    END


Log And Write To File
    [Arguments]    ${stream}    ${line}
    Log    ${stream}: ${line}
    Append To File    ${LOGFILE}    ${stream}: ${line}\n

VMCleanUp And Copy Logs
    Get test timestamp
    Run Keyword And Ignore Error    Check Throughput
    Log To Console      \n [INFORMATION] * * * * * X2 is dropped by Testsuite Teardown * * * * * \n
    Run Keyword And Ignore Error    Copy Logs From UTE VM To Workspace
    Run    rm -rf /home/ute/ute_agent_logs/*/builds/*; rm -rf /home/ute/.ute-ca/cache/*
    Run Keyword And Ignore Error    Run    rm /home/ute/logs/ap_testcase_log.txt
    ${tl_preparation}    Get Variable Value    ${tl_preparation}    True
    Run Keyword If      '${tl_preparation}'=='False'    Run Keyword And Ignore Error
    ...                                                 Wait Until Keyword Succeeds    10min  15s
    ...                                                 Copy SoSReport logs    ${agent_logs}/results/logs/
    Run Keyword If All Tests Passed    Run Keywords    Run Keyword And Ignore Error    Run Keyword If    'INT' not in '${branch}'
    ...    Check NIDD and make update on topologyconfigs repo
    ...    AND    Run Keyword And Ignore Error    Send Tag With gNB Load To Topology Configs Repo
    Run Keyword If Any Tests Failed    Run Keyword And Ignore Error    Copy Snapshot logs from gNB and AP
    Run Keyword If Any Tests Failed    Run Keyword And Continue On Failure
    ...    Check Error in Snapshot    snapshot_path=${snapshot_gnb_path}
    Run Keyword And Ignore Error    Run    rm -rf ${AP_configs}
    Run Keyword And Ignore Error    Stop BTSlogs Collection And Get Logs    target_path=${OUTPUT_DIR}
    Run Keyword And Ignore Error    Run    rm -rf ${OUTPUT DIR}/messaging.* ; rm -rf ${OUTPUT DIR}/al.*

Start BTSlogs Collection
    [Documentation]     Used to Start BTSlog collection in debug PC.
    Log To Console      \n\n\t\t - - - Starting BTSLOG [...] - - -
    BuiltIn.Sleep       3s
    &{executor}         Create Dictionary    host=${tl.test_pc.default_ssh_connection_details.addr}
    ...                                      user=${tl.test_pc.default_ssh_connection_details.username}
    ...                                      password=UtE4fiVeG.2022
    btslog.create_btslog_collector    name=btslog    btslog_path=/opt/btslog/btslog
    ...                               btslog_launcher_path=/opt/btslog/btslog_launcher    executor=${executor}
    btslog.Set Suite Alias     btslog
    taf.collectors.core.setup_collectors    names=btslog
    taf.collectors.core.start_collectors    names=btslog
    BuiltIn.Sleep       10s
    ${syslog_file}      Run    find /tmp/btslog2 -name \"*.LOG\"
    Run Keyword If      '${syslog_file.strip()}' != ''    Log To Console    \t\t - - - BTSLOG started - - -
    ...       ELSE      Log To Console    \n\t\t > > > Problem occured during BTSLOG start < < < [ !!! ]
    BuiltIn.Set Suite Variable    ${syslog_file}

Stop Btslog Collection
    [Arguments]
    ${btslog_stopped}    Run Keyword And Return Status    taf.collectors.core.stop_collectors      names=btslog
    ${index}             Run    /opt/btslog/btslog_launcher current_index
    taf.collectors.core.teardown_collectors    names=btslog
    BuiltIn.Set Suite Variable    ${btslog_stopped}
    Run Keyword If      '${syslog_file.strip()}' != ''    Log To Console    \n\t\t- - - BTSLOG stopped = SYSLOG_${index.strip()}.LOG - - -
    ...                                           ELSE    Log To Console    \n\t\t> > > Problem occured with BTSLOG < < < [ !!! ]\n
    @{btslog_file_list}    Create List
    Set Suite Variable    @{btslog_file_list}
    ${btslog_file}      Run    find /tmp/btslog2 -name \"*.LOG\"
    ${flist}    Get Regexp Matches  ${btslog_file}    pattern=SYSLOG.*.LOG
    Get test timestamp
    FOR    ${file}    IN    @{flist}
        ${new_file}    Set Variable   ${file.split('.')[0]}_${timestamp}.LOG
        Append To List    ${btslog_file_list}    ${new_file}
        ${command}    Catenate    cd /tmp/btslog2 && mv ${file} ${new_file} &&
        ...    cp ${new_file} /tmp/${new_file}
        Run    ${command}
    END

Stop BTSlogs Collection and get logs
    [Arguments]         ${target_path}=${None}
    ${skip_btslog_collection}    Get Variable Value    ${btslog_stopped}    ${False}
    IF    not ${skip_btslog_collection}
        Stop Btslog Collection
    ELSE
        FOR    ${file}    IN    @{btslog_file_list}
            Run    cp /tmp/${file} /tmp/btslog2/${file} && rm -f /tmp/${file}
        END
    END
    ${merge_command}   Set Variable   cd /tmp/btslog2 && ls -ltr | grep 'SYSLOG_*' | awk '{print $9}' | xargs cat | sponge SYSLOG_${timestamp}.LOG
    Run    ${merge_command}
    ${command}         Set Variable    cd /tmp/btslog2 && tar zcvf /tmp/SYSLOG_${timestamp}.tgz SYSLOG_${timestamp}.LOG
    Run    ${command}
    Run    sudo cp /tmp/SYSLOG_${timestamp}.tgz ${target_path}/SYSLOG_${timestamp}.tgz
    Run Keyword and continue on failure    Additonal Check in Logs
    ...    file_path=/tmp/btslog2/SYSLOG_${timestamp}.LOG
    ...    L3call_check=${False}
    ${remove_command}    Catenate    rm -f /tmp/SYSLOG_${timestamp}.tgz &&
    ...                       cd /tmp/btslog2 && rm -f BTSLOG_TRACE_*.bin *.LOG* executionlog*.txt
    Run    ${remove_command}

Check If WFT Reporting Enabled
    ${wft_check}        check_if_tl_reports_to_wft    ${WORKSPACE}    UTE${tl.tl_cloud_topology}    ${STREAM}
    Should Not Contain  'UTE${tl.tl_cloud_topology}'    '${wft_check}'

Send AP Attribute To WFT
    ${wft_sbts_attr}    Catenate   SEPARATOR=    curl -X POST "https://wft.int.net.nokia.com:8091/api/v1/SBTS/CI_ENB/
    ...                            builds/${GNB_LOAD}/attributes/airphone_version.json?value=${AP_BUILD}&access_key=
    ...                            QF5oQmJRkaK4UWIDMGH0Ore6RcQMzseZ459IdCIB" -H "accept: application/json"
    ${wft_5g_attr}      Catenate   SEPARATOR=    curl -X POST "https://wft.int.net.nokia.com:8091/api/v1/5G/5G_Central/
    ...                            builds/${branch}_${GNB_LOAD}/attributes/airphone_version.json?value=${AP_BUILD}&access_key=
    ...                            5TcoeCTeUsAbxCgMgdsxTGsJBaWCH9IntpMKpvZD" -H "accept: application/json"
    ${wft_attr}         Set Variable If    'SBTS' in '${GNB_LOAD}'    ${wft_sbts_attr}    ${wft_5g_attr}
    Log To Console      --> trying to send airphone_version=${AP_BUILD} to build attributes for ${GNB_LOAD}...
    ${out_put}          Run    ${wft_attr}
    Should Contain      ${out_put}    created successfuly
    Log                 ${out_put}
    Log To Console      --> [SUCCESS] airphone_version=${AP_BUILD} has been sent to build attributes for ${GNB_LOAD}. \n

Copy Logs From UTE VM To Workspace
    [Timeout]           10min
    ${logs_tgz}         Set Variable    logs.tgz
    ${logs_path}        Set Variable    ${OUTPUT DIR}/gNB_AP_Logs
    Log To Console      \n Downloading logs from UTE VM to workspace...\n
    ${sosreport}        Run     ls /home/ute/logs | grep -i SosReport | grep -i tgz
    ${sosreport}        Split String    ${sosreport}    separator=.
    ${sosreport}        Catenate    SEPARATOR=.    ${sosreport[0]}    tgz
    Run Keyword And Continue On Failure    Run    cd /home/ute/logs; mkdir SosReport; mv ${sosreport} SosReport
    Run Keyword And Continue On Failure    Run    cd /home/ute/logs; tar czf ${logs_tgz} *.tgz *.txt *.log *.xml *.cfg *.html
    Run Keyword And Continue On Failure    Run    sudo cp /home/ute/logs/SosReport/${sosreport} ${logs_path}/${sosreport}
    Run    sudo cp /home/ute/logs/${logs_tgz} ${logs_path}/${logs_tgz}

Agent Teardown
    [Arguments]         ${agent_logs}
    Run Keyword And Continue On Failure    Run    rm -rf ${agent_logs}/YAFT_IMAGE
    ${timestamp}    Get Timestamp
    Run Keyword And Continue On Failure    Run    sudo cp ${agent_logs}/ute_ca_logs/agent.log ${OUTPUT DIR}/agent_INFO_log.txt
    Run Keyword If    '${tl_preparation}'=='False'    Run Keyword And Continue On Failure    Run Keywords
    ...                Run    agentctl collect-logs --directory=/home/ute/.ute-ca
    ...       AND      Run    sudo cp /home/ute/.ute-ca/ute_ca_logs*.zip ${OUTPUT DIR}/

Update configs repo
    Run Keyword And Ignore Error    Add Prodzn User In SSH Config
    Set Suite Variable  ${AP_configs}    ${WORKSPACE}/AP_configs_repo
    Run                 git clone git@gitlabe2.ext.net.nokia.com:uca/ran/topology-configs.git ${AP_configs}
    Run                 cd ${AP_configs} && git config user.name prodzn && git config user.email 5g_qt.prodzn@nokia.com

    ${gnb_swconfig}     get_config_filename_new_repo     swconfig    sm     ${topology_config_variant}
    ...                 ${AP_configs}/${tl_topology}/${release}
    ${scf_gnb}          get_config_filename_new_repo     scf         sm     ${topology_config_variant}
    ...                 ${AP_configs}/${tl_topology}/${release}
    ${AP_swconfig}      get_config_filename_new_repo     swconfig    sim    ${topology_config_variant}
    ...                 ${AP_configs}/${tl_topology}/${release}
    ${AP_iphy_xml}      get_config_filename_new_repo     iphy_xml    sim    ${topology_config_variant}
    ...                 ${AP_configs}/${tl_topology}/${release}
    ${wts_cfg}          get_config_filename_new_repo     wts_cfg      vm    ${topology_config_variant}
    ...                 ${AP_configs}/${tl_topology}/${release}
    ${gnb_swconfig_link}     Set Variable
    ...    https://gitlabe2.ext.net.nokia.com/uca/ran/topology-configs/-/tree/master/${tl_topology}/${release}/${gnb_swconfig}
    ${gnb_scf_link}          Set Variable
    ...    https://gitlabe2.ext.net.nokia.com/uca/ran/topology-configs/-/tree/master/${tl_topology}/${release}/${scf_gnb}
    ${ap_swconfig_link}      Set Variable
    ...   https://gitlabe2.ext.net.nokia.com/uca/ran/topology-configs/-/tree/master/${tl_topology}/${release}/${AP_swconfig}
    ${ap_scf_link}           Set Variable
    ...   https://gitlabe2.ext.net.nokia.com/uca/ran/topology-configs/-/tree/master/${tl_topology}/${release}/${AP_iphy_xml}
    Log To Console      \n--> INFO: Common Agent uses config files directly from the repository. Links to the used files are below:
    Log To Console      gNB swconfig link: ${gnb_swconfig_link}
    Log To Console      gNB SCF link: ${gnb_scf_link}
    Log To Console      AP swconfig link: ${ap_swconfig_link}
    Log To Console      AP SCF link: ${ap_scf_link}
    Set Suite Variable    ${scf_from_repo}    ${AP_configs}/${tl_topology}/${release}/${scf_gnb}
    Set Suite Variable    ${scf_gnb}
    Set Test Variable     ${gnb_swconfig}
    Set Test Variable     ${AP_swconfig}
    Set Test Variable     ${AP_iphy_xml}
    Set Test Variable     ${wts_cfg}
    ${nidd1_scf_repo}     nidd_check.Get NIDD Version From SCF File    ${AP_configs}/${tl_topology}/${release}/${scf_gnb}    1
    ${nidd2_scf_repo}     nidd_check.Get NIDD Version From SCF File    ${AP_configs}/${tl_topology}/${release}/${scf_gnb}    2
    ${diff_status}        Run Keyword If    '${nidd_ver_ap}'!='${EMPTY}'
    ...    compare_nidd_ver_for_ap      ${nidd_sub_ver}    ${nidd1_scf_repo}    ${nidd2_scf_repo}
    ...    ELSE    Create List    ${False}
    Set Suite Variable    ${diff_status_true_false}    ${diff_status}[0]
    Set Suite Variable    ${commit}    ${None}
    Run Keyword If        ${diff_status_true_false}    Set Repo Version    ${nidd_sub_ver}[0]
    Run Keyword If       '${custom_config}'=='${True}'    Run Keyword And Ignore Error    Set Custom Config

Check NIDD and make update on testconfigs repo
    [Documentation]     This keyword is checking NIDD versions from the SCF file used for commissioning (from 'testconfigs'
    ...                 repository) and from the SCF file collected from the TestLine after commissioning.
    ...                 If checked NIDD versions are different AND all TC's in the testsuite have PASSED, then SCF file
    ...                 collected from the TL will be updated on the 'testconfigs' repository automatically.
    Run                 cd ${AP_configs} && git checkout master && git pull origin
    ${python_cmd}       Catenate    python /home/ute/Auto5G/testsuite/QT/SRAN/resources/python/nidd_check.py
    Set Suite Variable  ${scf_from_tl}    /home/ute/logs/scf_from_tl.xml
    ${nidd2_scf_repo}   nidd_check.Get NIDD Version From SCF File    ${scf_from_repo}   2
    ${eqm1}     Fetch From Left    ${nidd2_scf_repo}    _
    ${nidd2_scf_repo_fetch}     Fetch From Right    ${nidd2_scf_repo}    ${eqm1}
    ${nidd2_scf_repo_remove}    Remove String       ${nidd2_scf_repo_fetch}    _
    ${nidd2_scf_repo_int}       Convert To Integer    ${nidd2_scf_repo_remove}
    Run         mkdir -p /home/ute/logs; ${python_cmd} get_scf ${scf_from_tl}
    ${nidd2_scf_tl}     Run     ${python_cmd} get_nidd ${scf_from_tl} 2
    ${nidd2_scf_tl}     Fetch From Right    ${nidd2_scf_tl}    .\r\n
    ${nidd2_scf_tl}     Fetch From Left     ${nidd2_scf_tl}    \r\n
    ${nidd2_scf_tl}     Strip String    ${nidd2_scf_tl}
    ${eqm2}     Fetch From Left    ${nidd2_scf_tl}    _
    ${nidd2_scf_tl_fetch}     Fetch From RIght    ${nidd2_scf_tl}          ${eqm2}
    ${nidd2_scf_tl_remove}    Remove String       ${nidd2_scf_tl_fetch}    _
    ${nidd2_scf_tl_int}       Convert To Integer    ${nidd2_scf_tl_remove}
    Set Suite Variable   ${nidd2_scf_repo}
    Set Suite Variable   ${nidd2_scf_tl}
    Set Suite Variable   ${nidd2_scf_repo_int}
    Set Suite Variable   ${nidd2_scf_tl_int}
    ${nidd_condition}   Catenate    ('${nidd2_scf_repo}' not in '${nidd2_scf_tl}' and 'error' not in '${nidd2_scf_repo}'
    ...                             and 'error' not in '${nidd2_scf_tl}' and '${nidd2_scf_repo}' != '' and '${nidd2_scf_tl}' != ''
    ...                             and ${nidd2_scf_repo_int} < ${nidd2_scf_tl_int})
    ${nidd_condition}   Evaluate    ${nidd_condition}
    ${nidd_value}       Get NIDD version    ${nidd2_scf_repo}    ${nidd2_scf_tl}
    Run Keyword If      ${nidd_condition}    Update SCF on testconfigs    ${scf_from_tl}    ${scf_from_repo}    ${nidd_value}
    ...       ELSE      Log To Console    NIDD version is the same before and after commissioning, no need to update SCF on repo.

Check NIDD and make update on topologyconfigs repo
    [Documentation]     This keyword is checking NIDD versions from the SCF file used for commissioning (from 'testconfigs'
    ...                 repository) and from the SCF file collected from the TestLine after commissioning.
    ...                 If checked NIDD versions are different AND all TC's in the testsuite have PASSED, then SCF file
    ...                 collected from the TL will be updated on the 'testconfigs' repository automatically.
    ${python_cmd}       Catenate    python /home/ute/Auto5G/testsuite/QT/SRAN/resources/python/nidd_check.py
    Set Suite Variable  ${scf_from_tl}            /home/ute/logs/scf_from_tl.xml
    Set Suite Variable  ${scf_from_tl_qt_node}    /home/ute/scfc.xml
    ${nidd2_scf_repo}   nidd_check.Get NIDD Version From SCF File    ${scf_from_repo}   2
    ${eqm1}     Fetch From Left    ${nidd2_scf_repo}    _
    ${nidd2_scf_repo_fetch}     Fetch From Right    ${nidd2_scf_repo}    ${eqm1}
    ${nidd2_scf_repo_remove}    Remove String       ${nidd2_scf_repo_fetch}    _
    ${nidd2_scf_repo_int}       Convert To Integer    ${nidd2_scf_repo_remove}
    Run         mkdir -p /home/ute/logs; ${python_cmd} get_scf ${scf_from_tl}
    ${nidd2_scf_tl}     Run     ${python_cmd} get_nidd ${scf_from_tl} 2
    ${nidd2_scf_tl}     Fetch From Right    ${nidd2_scf_tl}    .\r\n
    ${nidd2_scf_tl}     Fetch From Left     ${nidd2_scf_tl}    \r\n
    ${nidd2_scf_tl}     Strip String    ${nidd2_scf_tl}
    ${eqm2}     Fetch From Left    ${nidd2_scf_tl}    _
    ${nidd2_scf_tl_fetch}     Fetch From RIght    ${nidd2_scf_tl}          ${eqm2}
    ${nidd2_scf_tl_remove}    Remove String       ${nidd2_scf_tl_fetch}    _
    ${nidd2_scf_tl_int}       Convert To Integer    ${nidd2_scf_tl_remove}
    Set Suite Variable   ${nidd2_scf_repo}
    Set Suite Variable   ${nidd2_scf_tl}
    Set Suite Variable   ${nidd2_scf_repo_int}
    Set Suite Variable   ${nidd2_scf_tl_int}
    ${nidd_condition}   Catenate    ('${nidd2_scf_repo}' not in '${nidd2_scf_tl}' and 'error' not in '${nidd2_scf_repo}'
    ...                             and 'error' not in '${nidd2_scf_tl}' and '${nidd2_scf_repo}' != '' and '${nidd2_scf_tl}' != ''
    ...                             and ${nidd2_scf_repo_int} < ${nidd2_scf_tl_int})
    ${nidd_condition}   Evaluate    ${nidd_condition}
    ${nidd_value}       Get NIDD version    ${nidd2_scf_repo}    ${nidd2_scf_tl}
    Run         sudo chmod 777 -R /home/ute/logs/*
    #check scf file from repo
    Run    ls ${AP_configs}/${tl_topology}/${release}/${topology_config_variant}
    #check scf file
    Run    ls /home/ute/ | grep scfc
    Run And Return Rc And Output    echo "" >> ${scf_from_tl_qt_node}
    Run Keyword If    ${nidd_condition}    update_topologyconfig_repo    URL=${topology_config_base_url}
    ...    private_token=${prodzn_token}    project_id=${topology_config_project_id}
    ...    branch_name=${nidd_value}_${cloud_topology}
    ...    repo_file_path=${tl_topology}/${release}/${scf_gnb}    tl_file_path=${scf_from_tl_qt_node}    nidd_version=${nidd_value}
    ...    topology=${cloud_topology}
    ...    ELSE     Log    NIDD version is the same before and after commissioning, no need to update SCF on repo.

Get NIDD version
    [Arguments]    ${nidd2_scf_repo}    ${nidd2_scf_tl}
    ${nidd_value}   Catenate        '${nidd2_scf_tl}' if ('${nidd2_scf_tl}' not in '${nidd2_scf_repo}' and ${nidd2_scf_repo_int}
    ...                             < ${nidd2_scf_tl_int}) else None
    ${nidd_value}   Evaluate        ${nidd_value}
    RETURN    ${nidd_value}

Update SCF on testconfigs
    [Arguments]    ${scf_from_tl}    ${scf_from_repo}    ${nidd_value}
    Log To Console      \n NIDD changed, updating SCF from TL to 'testconfigs' repository...
    Run         sudo chmod 777 -R /home/ute/logs/*
    ${diff_cmd}    Catenate
    ...    cd ${AP_configs}
    ...    && git diff --no-index ${scf_from_tl} ${scf_from_repo} > gnb_scf_patch_with_head.patch
    ${rc_git_diff}    RUN    ${diff_cmd}
    Run Keyword And Return If    ${rc_git_diff} == None    Fail    msg=GIT DIFF command failed!!
    ${rc_apply_patch}    Run Keyword If    ${rc_git_diff} == 0
    ...    Log To Console    There is no difference between SCF file used during install and HEAD.
    ...    ELSE IF    ${rc_git_diff} == 1    Apply git patch    gnb_scf_patch_with_head.patch    ${scf_from_repo}
    Run Keyword And Return If    ${rc_apply_patch} == 1    Fail    msg=git patch apply command failed with error code ${rc_apply_patch}
    ${push_change}    Catenate
    ...    cd ${AP_configs} && git ls-files --modified | xargs git add
    ...    && git commit -m '[Auto] SCF file update with new NIDD version:${nidd_value}'
    ...    && git push origin master
    ${rc_git_push}    RUN    ${push_change}
    Should Be Equal As Integers    ${rc_git_push}    0    msg=git patch apply command failed with error code ${rc_git_push}

Apply git patch
    [Arguments]    ${patch_file}    ${scf_from_repo}
    Log To Console    Applying GIT Patch...
    copy file    ${AP_configs}/${patch_file}    ${EXECDIR}/logs
    ${apply_patch}    Catenate
    ...    cd ${AP_configs}
    ...    && patch -i ${patch_file} -l -p1 ${scf_from_repo}
    ${rc}    ${output}    Run and Return RC and Output    ${apply_patch}
    Log To Console    ${output}
    Run Keyword If    ${rc} != 0    Log    git patch apply command failed with error code ${rc} ${output}    level=WARN
    RETURN    ${rc}

Copy SoSReport logs
    [Arguments]    ${sosreport_dir}
    ${sosreport}         Run    ls ${sosreport_dir} | grep -i SosReport | grep -i tgz
    ${sosreport_file}    Strip String   ${sosreport}    characters=\r\n
    ${sosreport_path}    Set Variable   ${sosreport_dir}/${sosreport_file}
    Run    sudo cp ${sosreport_path} ${OUTPUT DIR}/${sosreport_file}

Copy Snapshot logs from gNB and AP
    [Timeout]           10 min
    Log To Console      \t - - - Start gNB and AP snapshots collecting via telnet - - -
    ssh.connect_to      hostname=192.168.255.129
    ...                 username=toor4nsn
    ...                 password=oZPS0POrRieRtu
    ...                 alias=snapshot_gnb
    ssh.execute         command=(echo "log -a -c full -z /ram/Snapshot.zip"; sleep 50; echo "quit")|telnet 0 15007
    ...                 connection=snapshot_gnb
    ssh.download_file   remote_path=/ram/Snapshot.zip
    ...                 local_path=${OUTPUT DIR}/Snapshot_gNB_${timestamp}.zip
    ...                 connection=snapshot_gnb
    ssh.disconnect      connection=snapshot_gnb
    Log To Console      \t - - - Snapshot collected from gNB via telnet. - - -

    ssh.connect_to      hostname=192.168.200.1
    ...                 username=toor4nsn
    ...                 password=oZPS0POrRieRtu
    ...                 alias=snapshot_ap
    ssh.execute         command=(echo "log -a -c full -z /ram/Snapshot.zip"; sleep 50; echo "quit")|telnet 0 15007
    ...                 connection=snapshot_ap
    ssh.download_file   remote_path=/ram/Snapshot.zip
    ...                 local_path=${OUTPUT DIR}/Snapshot_AP_${timestamp}.zip
    ...                 connection=snapshot_ap
    ssh.disconnect      connection=snapshot_ap
    Set Suite Variable    ${snapshot_gnb_path}    ${OUTPUT DIR}/Snapshot_gNB_${timestamp}.zip
    Log To Console      \t - - - Snapshot collected from AP via telnet. - - -

Add Prodzn User In SSH Config
    ${grep_status}    Get Status Of SSH Config For Prodzn User Details
    Return From Keyword If    '${grep_status}' == 'True'    ${grep_status}
    ${ssh_config_value}    Catenate    \nHost gitlabe2.ext.net.nokia.com\n    \tIdentityFile ~/.ssh/gerrit\n    \tUser prodzn\n
    Append To File    /home/ute/.ssh/config    ${ssh_config_value}
    ${command}    Catenate    sudo systemctl restart ssh.service
    Run    ${command}
    ${grep_status}    Get Status of SSH Config For prodzn User Details
    Run Keyword If    ${grep_status}!=${True}    Log    SSH configuration failure
    RETURN    ${grep_status}

Get Status Of SSH Config For Prodzn User Details
    ${command}    Catenate    grep -i "gitlabe2" ~ute/.ssh/config
    ${output}    Run    ${command}
    ${grep_status}    Run Keyword And Return Status    Should Contain    ${output}    gitlabe2
    RETURN    ${grep_status}

Set Custom Config
    ${AP_configs}         Set Variable    /home/ute/AP_configs_repo
    ${custom_conf_dir}    Set Variable    /home/ute/QT_custom_configs
    ${ap_repo_dir}        Set Variable    ${AP_configs}/${tl_topology}/${release}/${topology_config_variant}
    Run    rm -rf {AP_configs}
    Run    git clone git@gitlabe2.ext.net.nokia.com:uca/ran/topology-configs.git ${AP_configs}
    Run    cd ${AP_configs} && git checkout master && git pull origin
    Run    cp ${custom_conf_dir}/gnb/scfc.xml ${ap_repo_dir}/scfc.xml
    Run    cp ${custom_conf_dir}/gnb/swconfig_gnb.txt ${ap_repo_dir}/swconfig_gnb.txt
    Run    cp ${custom_conf_dir}/ap/iphy.xml ${ap_repo_dir}/iphy.xml
    Run    cp ${custom_conf_dir}/ap/swconfig_ap.txt ${ap_repo_dir}/swconfig_ap.txt

Kill Apt Process And Reconfigure Dpkg
    ${pid}            Run    pidof apt
    ${pid}            Fetch From Left    ${pid}    \r\n
    ${is_pid}         Run Keyword And Return Status    Should Match Regexp    ${pid}    \\d{5}
    Run Keyword If    ${is_pid}    Run    sudo kill -9 ${pid} ; yes | sudo dpkg --configure -a

Set Repo Version
    [Arguments]           ${commit_msg}
    ${AP_configs}         Set Variable    /home/ute/AP_configs_repo
    Run           sudo rm -rf ${AP_configs}
    Run           git clone git@gitlabe2.ext.net.nokia.com:uca/ran/topology-configs.git ${AP_configs}
    Run           cd ${AP_configs} && git config user.name prodzn && git config user.email 5g_qt.prodzn@nokia.com
    ${commit}    ${commit_nidd_ver}    get_commit_hash_and_nidd_ver_for_ap_scf
    ...    ap_configs_path=${AP_configs}
    ...    commit_msg=${commit_msg}
    ...    alias=UTE_VM
    Set Suite Variable    ${commit}
    IF    '${commit}'!=""
        Run    cd ${AP_configs}; git checkout ${commit}
        Log To Console    \n gNB SCF has been updated to NIDD ${commit_nidd_ver}, checkout AP configs repo to commit: ${commit} \n
    ELSE
        Log    \n NIDD SCF update needed, commit with properly SCF was not found in the repository! \n    WARN
    END

Send Tag With gNB Load To Topology Configs Repo
    ${last_commit}    Run    cd ${AP_configs}; git log -n 1 --oneline | awk '{print \$1}' | xargs echo -n
    ${tag_prefix}     Set Variable If    'SBTS' in '${loadBuild}'     ${EMPTY}     ${release}_
    ${commit}         Set Variable If    ${diff_status_true_false} and '${commit}'!=""    ${commit}    ${last_commit}
    Run               cd ${AP_configs}; git reset --hard origin/master && git pull
    Run               cd ${AP_configs}; git tag -af ${tag_prefix}${GNB_LOAD} -m ${tag_prefix}${GNB_LOAD} ${commit}
    Run               cd ${AP_configs}; git push -f origin ${tag_prefix}${GNB_LOAD}

Connect to UTE_VM
    [Arguments]         ${conn_alias}=UTE_VM
    ${res_bool}=  Run Keyword And Return Status  Wait Until Keyword Succeeds    3min  20s    ssh.connect_to
    ...                 hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...                 username=${tl.test_pc.default_ssh_connection_details.username}
    ...                 key_path=/home/ute/.ssh/id_rsa
    ...                 password=UtE4fiVeG.2022
    ...                 alias=${conn_alias}
    Run Keyword If  '${res_bool}' == 'False'  Fail  !!!Warning!!! connect to ute vm failed, please check!

L3call Case Teardown
    [Documentation]    Log fail message to console only when L3call case is tested and failed
    ${Run_Testsuite_L3call_Sequential_robot_case_status}
    ...    get_test_case_status_by_name    Run Testsuite L3call_Sequential robot
    IF    '${Run_Testsuite_L3call_Sequential_robot_case_status}'=='PASS'
        Run Keyword If Test Failed    Log To Console    ${fail_msg_info}
    END

Install Common Agent
    ${ute-ca_version}     Set Variable If    '${common_agent_ver}'!='' and '${common_agent_ver}' != 'not_set'
    ...    ute-ca=${common_agent_ver}    ute-ca
    ${command_0}          Catenate    sudo apt-get update && sudo apt-get install -y --allow-downgrades ${ute-ca_version}
    Log To Console        Execute: ${command_0}
    Run                   ${command_0}
    ${agent_version}      Run    dpkg -s ute-ca | grep Version
    Set Suite Variable    ${agent_version}
    IF    '${common_agent_ver}'!='' and '${common_agent_ver}' != 'not_set'
        ${check_agent_ver}    Run Keyword And Return Status    Should Contain    ${agent_version}    ${common_agent_ver}
        IF    not ${check_agent_ver}
            Fail    Common Agent version: ${agent_version} is not the same as provided in pipeline: ${common_agent_ver}, pls check logs manually!
        ELSE
            Log To Console    \n--> UTE Common-Agent installed, ${agent_version}
        END
    ELSE
        Should Not Contain    ${agent_version}    is not installed    msg=ute-ca installation failed, pls check!!!
        Log To Console    \n--> UTE Common-Agent installed, ${agent_version}
    END

Collect SosReport
    Run     rm /opt/wts/latest/sosReport_ASIL/SosReport*.tgz
    ${output}    Run    cd /opt/wts/latest/sosReport_ASIL; ./sosReport_ASIL.sh
    ${sosreport_status}    Run Keyword And Return Status    Should Contain    ${output}    created
    IF    ${sosreport_status}
        Copy SoSReport logs    /opt/wts/latest/sosReport_ASIL
        Log To Console   Sosreport collection done successfully.
    ELSE
        Log To Console   Sosreport collection failed.
    END