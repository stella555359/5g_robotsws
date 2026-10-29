*** Settings ***
Documentation     This contains common keywords which are needed to run PET L3 Calls.
Resource    ../QT/resources/Keywords/common_keywords.robot
Resource    ../QT/resources/Variables/common_variables.robot
Resource    ../QT/resources/Variables/mue_variables.robot
Resource    ../QT/resources/ute/coam.robot
Resource    variables.robot
Resource    pet_logs.robot
Library    taf.sw.ping    WITH NAME    ping
Library    ${CURDIR}/scripts/wrapper_methods.py    WITH NAME    wrapper_methods
Library    XML
Library    OperatingSystem
Library    String
Library    ${CURDIR}/scripts/ExcelLib.py

*** Keywords ***

###############      Suite setup and Teardown     #################

Common Optimized PET Suite Setup
    Check if wts Directory Exists
    Run Keyword And Ignore Error    Kill VNC BTS Logger tool
    Run    pkill -f /opt/wts/latest/sosReport_ASIL/sosReport_ASIL.sh
    Run Keyword And Ignore Error    Check Rotta Directory
    Run Keyword And Ignore Error    Create Execution Logs Dir
    Get AP Suite Configuration Variables
    Run Keyword And Ignore Error    PyYaml and Taf config Install
    ${CUSTOM_CONFIGS}=    Get Environment Variable    CUSTOM_CONFIGS    None
    Set Suite Variable    ${CUSTOM_CONFIGS}
    ${TEST_CONFIGURATION}=    Get Environment Variable    AP_CONFIGURATION    None
    Set Suite Variable    ${TEST_CONFIGURATION}
    ${EM_TRACES}    Get Variable Value    ${COLLECT_EM_TRACES}    ${EM_TRACES}
    Set Suite Variable    ${EM_TRACES}
    ${EM_PERF_STATS}    Get Variable Value    ${COLLECT_EM_PERF_STATS}    ${EM_PERF_STATS}
    Set Suite Variable    ${EM_PERF_STATS}
    ${TOP_INTERFACE_STATS}    Get Variable Value    ${Collect_WTS_Stats}    ${TOP_INTERFACE_STATS}
    Set Suite Variable    ${TOP_INTERFACE_STATS}
    ${SYSLOG}    Get Variable Value    ${COLLECT_SYSLOG}    ${SYSLOG}
    Set Suite Variable    ${SYSLOG}
    ${IQ_LOG_ENABLE}    Get Variable Value    ${IQ_LOG_CAPTURE}    ${IQ_LOG_ENABLE}
    Set Suite Variable    ${IQ_LOG_ENABLE}
    ${AP_TOP_INTERFACE_STATS}    Get Variable Value    ${AP_TOP_STATS}    ${AP_TOP}
    Set Suite Variable    ${AP_TOP_INTERFACE_STATS}
    ${WTS_WIRESHARK}    Get Variable Value    ${WTS_PCAP_WIRESHARK}    ${WTS_PCAP}
    Set Suite Variable    ${WTS_WIRESHARK}
    ${WTS_SCTP_STATS}    Get Variable Value    ${WTS_STATS}    ${WTS_SCTP}
    Set Suite Variable    ${WTS_SCTP_STATS}
    ${AP_SCTP_STATS}    Get Variable Value    ${AP_STATS}    ${AP_SCTP}
    Set Suite Variable    ${AP_SCTP_STATS}
    ${SCF_STATUS}    Get Variable Value    ${SCF_VALIDATION_STATUS}    ${SCF_VALIDATION}
    Set Suite Variable    ${SCF_STATUS}
    ${INPUT_COMMISSION_SCF}=    Set Variable    ${custom_perf_path}/${ute_ca_variant}/scfc.xml
    ${INPUT_SCF}    Get Variable Value    ${INPUT_SCF_PATH}    ${INPUT_COMMISSION_SCF}
    Set Suite Variable    ${INPUT_SCF}
    ${COUNTER_INPUT}    Get Variable Value    ${INPUT_COUNTER}
    Set Suite Variable    ${COUNTER_INPUT}
    ${PET_DICHOTOMY}    Get Variable Value    ${DICHOTOMY}    False
    Set Suite Variable    ${PET_DICHOTOMY}
    Get Component Carrier Variables
    Wait Coam Site to be Ready
    Remove old gNB and AP BIP Logs
    Run Keyword And Ignore Error    Modify Sosreport script for PET
    Run Keyword And Ignore Error    Disable gNB Ports And Update sosScripts
    ${start_time}   Run Keyword And Ignore Error    Get Current DateTime
    Set Suite Variable    ${start_time}
    Run Keyword and Ignore Error    Run    sudo umount ${ROTTA_SERVER}
    Run Keyword and Ignore Error    Run    sudo umount ${ROTTA_SERVER_NEW}
    Run Keyword If    '${AP_TOP_INTERFACE_STATS}' == 'True'
    ...    Run Keyword And Ignore Error    Start AP Top output Collection
    Run Keyword If    '${WTS_WIRESHARK}' == 'True'
    ...    Run Keyword And Ignore Error    Start WTS WireShark
    ${ap_count}=    Get Variable Value    ${AP_COUNT}    None
    Set Suite Variable    ${ap_count}
    Run Keyword And Ignore Error    log sync mount and set log directory check
    ${pre_data_dictionary}=    Create Dictionary
    Set Suite Variable    &{pre_data_dictionary}
    Run Keyword If    '${GNB_COUNT}' > '1'    Setting gNB IPs for Multiple gNBs
    Check Init file for gNB IPs
    Collect SosReport Parallel    ${Start_sos_ASIL}

Setting gNB IPs for Multiple gNBs
    Set Suite Variable    &{GNB_ASIK}    &{GNB_ASIK_1}
    Set Suite Variable    &{GNB_BTS}    &{GNB_BTS_ASIK_1}

Common PET Suite Teardown
    Collect SosReport Parallel    ${Stop_sos_ASIL}
    Run Keyword and Ignore Error    Collect wts cores logs for PET
    Run Keyword and Ignore Error    Set WTS Default Log Level to Error Level
    Run Keyword and Ignore Error    Conditional Logging Check for log Collection
    Run Keyword and Ignore Error    Copy PET SE files from WTS to logs
    Run Keyword and Ignore Error    Copy Config Files
    Run Keyword and Ignore Error    Admin Cli Process Cleanup
    Run Keyword and Ignore Error    Counters Directory Cleanup
    Run Keyword And Ignore Error    Check Rotta Directory
    Wait Until Keyword Succeeds    15min    30s    Check For Sosreport
    ${log_status}=    Run Keyword And Return Status    File Should Exist    ${vm_logdir}/SosReport*.tgz
    Run Keyword If    '${log_status}' == 'False'    Run    mv /opt/wts/latest/SosReport*.tgz ${vm_logdir}/
    Run Keyword and Ignore Error    Move logs to Execution Directory

Admin Cli Process Cleanup
    RUN    ps -ef | pgrep -f "Nemuadmin" | xargs sudo kill -9

PyYaml and Taf config Install
    Run    pip3 install pyYaml
    Run    pip3 install -i ${TAF_REPO} taf.config.scf

Modify Sosreport script for PET
    Run    sed -i 's/chk lx/ls/g' /opt/wts/latest/sosReport_ASIL/sosReport_ASIL.sh

Copy PET SE files from WTS to logs
    Run    mkdir ${vm_logdir}/${execution_logs_path}/${egate_logs_path}/
    Run    cp ${WTS_DIR}/*.lua* ${vm_logdir}/
    Run    cp ${WTS_DIR}/*.cfg* ${vm_logdir}/
    Run    cp ${WTS_DIR}/egate_console* ${vm_logdir}/${execution_logs_path}/${egate_logs_path}/
    Run Keyword If    '${wts_summary}' == 'True'    Run    mv ${WTS_DIR}/WTS_Summary_*.csv* ${vm_logdir}/${execution_logs_path}

Counters Directory Cleanup
    Run    rm -rf /home/ute/fdd_pmcounters

Start WTS
    [Documentation]    Kill running WTS binaries if any, configure ETH3, retrieve files and configure WTS SIM
    Stop Edaemon Egate
    ${BSR_TEST_FLAG}=    Run Keyword And Return Status    Variable Should Exist    ${BSR_TEST_DATA}
    Set Suite Variable    ${BSR_TEST_FLAG}
    Run Keyword If    '${BSR_TEST_FLAG}' == 'True'    Activate BSR Packages Dynamically
    ${VENDOR_FILE_UPDATE}=    Run Keyword And Return Status    Variable Should Exist    ${VENDOR_ACTIVATE}
    Set Suite Variable    ${VENDOR_FILE_UPDATE}
    Run Keyword If    '${VENDOR_FILE_UPDATE}' == 'True'    Download Vendor File Modify and Upload the Vendor file
    Log to Console                 Starting WTS...
    Add ca_5gair User in ssh config
    Connect To WTS VM
    Run    cd /opt/wts/latest && ulimit -c unlimited && sudo bash -c 'echo "core_%e.%p" > /proc/sys/kernel/core_pattern'
    ute_wtssim.Setup Edaemon    edaemon_port=${wts_sim_edaemon_port}    tool_dir=${WTS_DIR}    alias=edaemon
    ute_wtssim.Start Edaemon Process    alias=edaemon
    ute_wtssim.Setup Egate    egate_port=${wts_sim_egate_port}    tool_dir=${WTS_DIR}    save_egate=True
    ute_wtssim.Start Egate Process
    ${ls}    Run    ls ${WTS_DIR}/*cfg
    Log To Console    ${ls}
    Run Keyword If    '${SYSLOG}' == 'True'    Wait until keyword succeeds    6min    2min    Start PET syslog Service

Activate BSR Packages Dynamically
    ${BSR_FILE_STATUS}=    Run Keyword    Check If BSR Package exists
    Run Keyword If    '${BSR_FILE_STATUS}' != 'True'    Update BSR Package
    ...    ELSE    Log To Console    BSR Package already present.

Update BSR Package
    ${packages}=    Split String    ${BSR_TEST_DATA}    ,
    FOR    ${pkg}    IN    @{packages}
        ${path}=    Set Variable    tools/BSR_Package/${pkg}.zip
        Activate BSR File    ${pkg}    ${path}
    END

Start syslog
    [Documentation]    Start fsyslog daemon
    Run                 killall fsyslog
    ${dir_exist_status}=    Run Keyword And Return Status   Directory Should Exist    ${vm_logdir}
    Run Keyword If    '${dir_exist_status}' == 'False'    Run Keywords
    ...    Remove File    ${vm_logdir}    AND     Create Directory     ${vm_logdir}
    Run    rm -rf ${sys_log_directory}
    Run    mkdir -p ${sys_log_directory}
    ${command}          Catenate    ${WTS_DIR}/fsyslog --log-dir=/home/ute/udpsyslog
    ...                 --log-file-name=udpsyslog.log
    Run                 ${command}

################################################################################


Common Register and Traffic
    [Arguments]    ${dictionary_name}    ${tag_name}
    ${NEW_CFG_FORMAT}=    Run Keyword And Return Status    Variable Should Exist    ${New_Config}
    Set Suite Variable    ${NEW_CFG_FORMAT}
    ${ue_stats_var_exist}=    Run Keyword And Return Status    Variable Should Exist    ${UE_STATS_NR_LIMIT}
    Set Suite Variable    ${ue_stats_var_exist}
    ${calculate_kpi}=    Get Variable Value    ${KPI_CALCULATION}    ${kpi_calc_display}
    Set Suite Variable    ${calculate_kpi}
    Run Keyword If    '${calculate_kpi}' == 'True'    Create KPI Type List
    Set Suite Variable    ${test_label}    ${tag_name}
    Fetch Dictionary items    ${dictionary_name}
    ${LOOP_DELAY_SATUS}=    Run Keyword And Return Status    Variable Should Exist    ${LOOP_DELAY}
    Set Suite Variable    ${LOOP_DELAY_SATUS}
    ${mvp_condition}=    Catenate
    ...    '${test_label}' in @{MVP_TAGS}
    ...    and '${test_label}' != 'VTM_MVP_MP'
    ...    and '${test_label}' != 'Dual_Boost_VTM'
    ...    and '${test_label}' != 'TDD_SA_VTM_TCP'
    ${should_run}=    Evaluate    ${mvp_condition}
    Run Keyword If    ${should_run}    Calculate Traffic Time For PET SE MVP
    ...    ELSE IF    '${test_label}' in "@{VTM_TAGS}" and '${test_label}' not in "@{MVP_TAGS}"
    ...    Calculate Traffic Time For PET SE VTM
    ...    ELSE IF    '${test_label}' in "@{CNI113765_TAGS}"
    ...    Calculate Timer for CNI Test cases
    ...    ELSE IF    '${LOOP_DELAY_SATUS}' == 'True'
    ...    Calculate Additional Timers
    ...    ELSE    Calculate Traffic Time For PET SE
    ${RETRY_TC}=    Get Variable Value    ${RESET_ALL}    ${RETRY_TEST}
    Set Suite Variable    ${RETRY_TC}
    Run Keyword If    '${TOP_INTERFACE_STATS}' == 'True'    Run Keyword And Ignore Error    Collect Top and Interface stats
    Run Keyword If    '${L2L3_BIPLOG}' == 'True'
    ...    Run Keyword And Ignore Error    Enable L2L3 BIP Log
    Run Keyword If    '${L2L3_BIPLOG}' == 'True' or '${TRF_PERF_BIP_LOGS}' == 'True'
    ...    Start sosReport Tcpdump for PET
    Run Keyword If    '${test_label}' in "@{RESET_TAGS}"    Reset AP gNB and Check Ready State
    ${retry_tag}=    Run Keyword And Return Status    Environment Variable Should Be Set    RETRY_COUNT_TAG
    ${retry_tag_count}=    Run Keyword If    '${retry_tag}' == 'True'    Get Environment Variable    RETRY_COUNT_TAG
    ...    ELSE    Set Variable    0
    Run Keyword If    '${test_label}' in "@{WTS_RESET_BYPASS}" and '${RETRY_TC}' == 'False' and '${retry_tag_count}' == '0'
    ...    Check Process Status
    ...    ELSE IF    '${test_label}' in "@{WTS_RESET_BYPASS}" and '${RETRY_TC}' == 'False' and '${retry_tag_count}' != '0'
    ...    Reset All and Start WTS
    ...    ELSE    Start WTS and Check Cell Setup
    ${ALL_TOP_STATS}=    Get Variable Value    ${ALL_TOP_STATS}   ${WTS_TOP_STATS}
    ${AMF_STATS}=    Get Variable Value    ${SIM_AMF_STATS}   ${AMF_TOP}
    ${UPF_STATS}=    Get Variable Value    ${SIM_UPF_STATS}   ${UPF_TOP}
    ${UEC_STATS}=    Get Variable Value    ${SIM_UEC_STATS}   ${UEC_TOP}
    ${ENB_STATS}=    Get Variable Value    ${SIM_ENB_STATS}   ${ENB_TOP}
    ${EGATE_TOP_STATS}=    Get Variable Value    ${EGATE_STATS}   ${EGATE_TOP}
    ${L3_TOP_STATS}=    Get Variable Value    ${L3_STATS}   ${L3_TOP}
    ${ALL_AP_STATS}=    Get Variable Value    ${ALL_WTS_TOP_STATS}   ${AP_ALL_TOP}
    Run Keyword If    '${ALL_TOP_STATS}' == 'True'    Start Top Stats of All components
    Run Keyword If    '${AMF_STATS}' == 'True'    Start AMF Top Stats of All components
    Run Keyword If    '${UPF_STATS}' == 'True'    Start UPF Top Stats of All components
    Run Keyword If    '${UEC_STATS}' == 'True'    Start UEC Top Stats of All components
    Run Keyword If    '${ENB_STATS}' == 'True'    Start ENB Top Stats of All components
    Run Keyword If    '${EGATE_TOP_STATS}' == 'True'    Start EGATE Top Stats of All components
    Run Keyword If    '${L3_TOP_STATS}' == 'True'    Start L3 Top Stats of All components
    Run Keyword If    '${ALL_AP_STATS}' == 'True'    Start All Top Stats of All components
    Run Keyword If    '${IQ_LOG_ENABLE}' == 'True'    Start Collecting IQ Traces
    Run Keyword If    '${AP_SCTP_STATS}' == 'True'    Start AP sctp stats collection
    Run Keyword If    '${WTS_SCTP_STATS}' == 'True'    Start wts sctp stats collection
    ${TCP_TRF_STATS}=    Run Keyword And Return Status    Variable Should Exist    ${TCP_TRF_STATS}
    Set Suite Variable    ${TCP_TRF_STATS}
    Run Keyword If    '${TCP_TRF_STATS}' == 'True'    Start TCP Traces log collection
    ute_wtssim.Execute Egate Command    sim_param_set disable_events_on_telnet_session\=on
    ${no_register}=    Get Variable Value    ${NO_REG}    None
    Run Keyword If    '${no_register}' != 'True'    Initiate UE Register And Traffic
    Run Keyword If    '${IQ_LOG_ENABLE}' == 'True'    Stop And Collect IQ
    Create KPI List

Fetch Dictionary items
    [Arguments]    ${dictionary_name}
    ${status}   ${items}=     Run Keyword And Ignore Error    Get Dictionary Items   ${dictionary_name}
    Log To Console    ${status}
    FOR    ${key}    ${value}    IN    @{items}
        Set Suite Variable    ${${key}}    ${value}
    END

Copy SE files
    [Arguments]    ${sansa_lua_file}
    Run Keyword If    '${CUSTOM_CONFIGS}' != 'None'
    ...    Override Lua From Custom Config    ${sansa_lua_file}
    Copy SANSA Lua    ${sansa_lua_file}
    ${CAP_CFG_FILE}=    Catenate    ${CAPABILITY_CFG_FILE}
    Set Suite Variable    ${CAP_CFG_FILE}
    Run    cp ${CAP_CFG_FILE} ${WTS_DIR}
    Run Keyword If    '${CUSTOM_CONFIGS}' != 'None'
    ...    Override Lua From Custom Config    ${PET_COMMANDS_LUA}
    ${CMD_LUA}=    Set Variable    ${PET_COMMANDS_LUA}
    Set Suite Variable    ${CMD_LUA}
    Run    cp ${CMD_LUA} ${WTS_DIR}

    ${MULTI_UE_SCRIPT_NEW}=    Catenate    ${PET_MULTI_UE_SCRIPT}
    Set Suite Variable    ${MULTI_UE_SCRIPT_NEW}
    Run    cp ${MULTI_UE_SCRIPT_NEW} ${WTS_DIR}
    ${MULTI_UE_SCRIPT_v5NEW}=    Catenate    ${PET_MULTI_UE_v5SCRIPT}
    Set Suite Variable    ${MULTI_UE_SCRIPT_v5NEW}
    Run    cp ${MULTI_UE_SCRIPT_v5NEW} ${WTS_DIR}
    Log To Console    Copied PET SE Files
    ${LUA_COPY}=    Run Keyword And Return Status    Variable Should Exist    ${COPY_LUA}
    Run Keyword If    '${LUA_COPY}' == 'True'    Copy MVP Files

Copy SANSA Lua
    [Arguments]    ${sansa_lua_file}
    ${LUA_FILE}=    Catenate    ${sansa_lua_file}
    Set Suite Variable    ${LUA_FILE}
    Run    cp ${LUA_FILE} ${WTS_DIR}

Check NgLink and Cell Setup
    ${wts_lua_command}=    Set Variable    cfg_sim file=/opt/wts/latest/sansa.lua entry=run_configuration(${timer})
    ${mvp_condition}=    Catenate
    ...    '${test_label}' in @{MVP_TAGS}
    ...    and '${test_label}' != 'VTM_MVP_MP'
    ...    and '${test_label}' != 'Dual_Boost_VTM'
    ...    and '${test_label}' != 'TDD_SA_VTM_TCP'
    ${is_mvp}=    Evaluate    ${mvp_condition}
    ${wts_lua_command}=    Run Keyword If    '${test_label}' in "@{VTM_TAGS}"    Change lua upload command for VTM
    ...    ELSE IF    ${is_mvp}    Change lua upload command
    ...    ELSE IF    '${test_label}' == 'VTM_MVP_MP' and '${test_label}' == 'Dual_Boost_VTM' and '${test_label}' == 'TDD_SA_VTM_TCP'
    ...    Set Variable    cfg_sim file=/opt/wts/latest/sansa.lua entry=run_configuration()
    ...    ELSE    Set Variable    ${wts_lua_command}
    ute_wtssim.Execute Egate Command    ${wts_lua_command}    timeout=10minutes
    Wait Until Keyword Succeeds    15min    30s    Check Occurances from Egate Console    ${simmode_active}    1
    ${DSS_ENABLE}=    Get Variable Value    ${DSS}    None
    Run Keyword If    '${DSS_ENABLE}' == 'True'    Check Prerequsite for DSS and Cell Setup
    ...    ELSE    Check for Cell Setup SIB and Ng Link
    FOR    ${index}    IN RANGE    2    ${GNB_COUNT}+1
        Cell Setup Check
    END
    ${dist_percent}=    Get Variable Value    ${SCG_DIST_PERCENT}    None
    Run Keyword If    '${dist_percent}' != 'None'    Enable SCG Dist Percent

NSA ENBX2 Setup
    [Documentation]    Setting up of NSA ENBX2 connection
    ...                Modified Date: 22-August-2025
    ...                Last Modified by: rahul.20.singh@nokia.com
    ute_wtssim.Execute Egate Command
    ...    script file\=/opt/wts/latest/commands.lua entry\=${NSA_ENBX2_FUNC}
    ...    timeout=300

NSA ENBX2 Validate
    ${start}    ${end}=    Get NSA Enb Range From Func    ${NSA_ENBX2_FUNC}
    ${patterns}=    Generate NSA ENB Patterns    ${start}    ${end}
    FOR    ${nsa_pattern}    IN    @{patterns}
        Wait Until Keyword Succeeds    5min    10s    Check Occurances from Egate Console    ${nsa_pattern}    1
    END
    Wait Until Keyword Succeeds    3min    1min    Check Occurances from Egate Console    ${nsa_x2_connections_script_complete}    1

NSA ENBX2 Setup and Validation
    NSA ENBX2 Setup
    NSA ENBX2 Validate

Get NSA Enb Range From Func
    [Documentation]    Extracts the start and end eNB IDs from a function string like
    ...                "NSA_x2_connections(3,8)". Returns start and end as integers.
    ...                 Modified Date: 28-August-2025
    ...                 Last Modified by: rahul.20.singh@nokia.com
    [Arguments]    ${func}
    ${match}=    Evaluate    re.search(r"NSA_x2_connections\\((\\d+)(?:,\\s*(\\d+))?\\)", """${func}""")    re
    IF    $match is None
        Fail    Invalid function format: ${func}
    END
    ${start}=    Evaluate    int($match.group(1))    re
    ${end}=      Evaluate    int($match.group(2)) if $match.group(2) else int($match.group(1))    re
    [Return]    ${start}    ${end}

Generate NSA ENB Patterns
    [Documentation]    Generates a list of NSA ENB patterns based on the provided start and end values.
    ...                Modified Date: 28-August-2025
    ...                Last Modified by: rahul.20.singh@nokia.com
    [Arguments]    ${start}    ${end}
    ${patterns}=    Create List
    FOR    ${i}    IN RANGE    ${start}    ${end+1}
        ${pat}=    Set Variable    ENB-${i}: X2AP Link with GNB-2 \\(.*\\) is up
        Append To List    ${patterns}    ${pat}
    END
    [Return]    ${patterns}

Check for Cell Setup SIB and Ng Link
    [Documentation]    This KW is appplicable for all test cases other than DSS 2AP
    ...                Modified Date: 21-April-2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    Sleep    5m
    ${ENBX2_FLAG}=    Run Keyword And Return Status    Variable Should Exist    ${NSA_ENBX2_FUNC}
    Run Keyword If    '${NSA_CONFIGARTION}' != 'True'    Check Ng link
    ${X2_LINK_UP}=    Run Keyword And Return Status    Variable Should Exist    ${X2_LINK}
    Run Keyword If    '${X2_LINK_UP}' == 'True'    NSA ENBX2 Setup
    Sleep    5m
    Check Cells Setup
    Sleep    15s
    Run Keyword If    '${NSA_CONFIGARTION}' != 'True'    Check SIB Messages    ${NO_OF_CELLS}
    Sleep    30s
    Run Keyword If    '${NSA_CONFIGARTION}' == 'True' and '${NEW_CFG_FORMAT}' == 'True'    X2 link via sim config
    ...    ELSE IF    '${ENBX2_FLAG}' == 'True' and '${NEW_CFG_FORMAT}' != 'True'   NSA ENBX2 Setup and Validation
    Sleep    1m

Check Prerequsite for DSS and Cell Setup
    [Documentation]    Checks needed for DSS conenctions, XP, CRM
    ...                Cell Setup, eNB SIB
    ...                Modified Date: 21-April-2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    Check eNB1 SIBs
    XP Connection for DSS
    Wait Until Keyword Succeeds    3min    10s    Check Occurances from Egate Console    ${XpAP_pattern}    1
    Wait Until Keyword Succeeds    3min    10s    Check Occurances from Egate Console    ${X2AP_pattern}    1
    Check CRM Statements
    Parallel DSS Setup
    Sleep    2m
    Check Cells Setup
    Sleep    15s
    Check SIB Messages    ${NO_OF_CELLS}
    Sleep    30s

Initiate UE Register And Traffic
    ${test_entry}=    Set Variable If    '${test_label}' == 'VTM_MVP_TC'
    ...    ${entry}(${timer},${TIMER4},${TIMER5},${TIMER6},${TIMER7},${TIMER8})
    ...    '${test_label}' == 'MVP_VTM_FDD' or '${test_label}' == 'VTM_MVP_TDD' or '${test_label}' == 'FDD_DSS_VTM'    ${entry}(${timer})
    ...    ${entry}
    ${main_condition}=    Catenate
    ...    '${NEW_CFG_FORMAT}' != 'True'
    ...    and '${test_label}' != 'VTM_MVP_MP'
    ...    and '${test_label}' != 'Dual_Boost_VTM'
    ...    and '${test_label}' != 'TDD_SA_VTM_TCP'
    ${should_execute}=    Evaluate    ${main_condition}

    Run Keyword If    ${should_execute}
    ...    ute_wtssim.Execute Egate Command
    ...    script file\=/opt/wts/latest/commands.lua entry\=${test_entry}
    ...    timeout=300
	...    ELSE IF    '${test_label}' == 'VTM_MVP_MP' or '${test_label}' == 'Dual_Boost_VTM' or '${test_label}' == 'TDD_SA_VTM_TCP'
	...    ute_wtssim.Execute Egate Command
    ...    script file\=/opt/wts/latest/vtm.lua entry\=${test_entry}
    ...    timeout=300
    ...    ELSE    New Test Sequence Lua file
    ${SCRIPT_COMPLETE}=    Catenate    ${entry}    script completed
    Wait Until Keyword Succeeds    ${SCRIPT_COMPLETE_WAIT_TIME}    1min    Check Occurances from Egate Console
    ...    ${SCRIPT_COMPLETE}    1

Check Occurances from Egate Console
    [Arguments]    ${pattern}    ${expected_occurances}
    Ensure Egate Console Log Available
    ute_wtssim.Execute Egate Command    set_log flush
    ${file}=    Set Variable If    '${pattern}' in @{egate_pattern}    egate_console.log
    ...    '${pattern}' not in @{egate_pattern} and '${test_label}' in "@{VTM_MVP_TAGS}"    egate_console.*.*
    ...    egate_console.log
    ${grepArgs}    Set Variable    find /opt/wts/latest/ -iname '${file}' -exec grep -m ${expected_occurances}
    ${command}    Catenate    ${grepArgs}    '${pattern}'    {} \\;    |    wc -l
    ${result}     Run    ${command}
    Should Be Equal    ${result}     ${expected_occurances}    msg=Error Found in Egate Logs: ${pattern} Not Found

Counter Fetch
    [Arguments]    ${gNB_counter}
    FOR    ${ip}    ${folder}    IN ZIP    ${gNB_IP_list}    ${pmcouter_folder}
        Wait Until Keyword Succeeds    ${COUNTER_DURATION}min    ${COUNTER_RETRY_DURATION}min
        ...    Fetch Counter Value from GNB BTS    ${folder}    ${ip}
    END
    FOR    ${folder}    IN    @{pmcouter_folder}
        ${single_counter}    Fetch counter value from XML file    ${gNB_counter}    ${folder}
    END
    [Return]    ${single_counter}

Fetch Counter Value from GNB BTS
    [Arguments]    ${target_dir}    ${ip}    ${name}=gnb_pm_counters
    RUN    rm -rf ${target_dir}/gnb_pm_counters/
    ${duration}=    Evaluate    (${COUNTER_DURATION}*2)
    ${duration}=    Catenate    ${duration}    minutes
    ${webservice}=    Create Dictionary    host=${ip}    user=${GNB_BTS.Username}
    ...    password=${GNB_BTS.Password}    port=${GNB_BTS.Port}
    gnb_pmcounters.create PM collector    name=${name}    webservice=${webservice}    for_last=${duration}
    gnb_pmcounters.setup_collectors    names=${name}
    gnb_pmcounters.collect_collectors    names=${name}    target_dir=${target_dir}
    Directory Should Not Be Empty    ${target_dir}/gnb_pm_counters/
    [Teardown]    gnb_pmcounters.teardown_collectors    names=${name}

Traffic Duration Set
    ${TRF_DURATION}    Get Variable Value    ${PET_DURATION}    ${pet_trf_duration}
    Set Suite Variable    ${TRF_DURATION}

Create KPI List
    ${kpi_list}=    Create List
    Set Suite Variable    @{kpi_list}

Append To Kpi list
    [Arguments]    ${kpi_list}    ${achieved_rate}
    Run Keyword    Intermediate KPI Validation    ${achieved_rate}    ${kpi_list}

Intermediate KPI Validation
    [Arguments]    ${achieved_rate}    ${kpi_list}
    ${last_loop}=    Evaluate    ((${TRF_DURATION}-${COUNTER_TIMER})+1)
    Run Keyword If    '${trf_loop}' != '1' and '${trf_loop}' != '${last_loop}' and '${test_label}' in "@{VTM_TAGS}"
    ...    KPI Check    ${achieved_rate}
    ...    ELSE IF    '${test_label}' in "@{MVP_TAGS}"
    ...    Append To List    ${kpi_list}    ${achieved_rate}

KPI Check
    [Arguments]    ${achieved_rate}
    ${Kpi_Status}=    Evaluate    (${achieved_rate}) >= (${expected_rate}*${event_threshold})
    ${Achieved_Kpi}=    Set Variable    ${achieved_rate}
    Set Suite Variable    ${Achieved_Kpi}
    Should Be True    ${Kpi_Status}    msg=Achieved Rate is Not equal to Expected Rate

Validate Kpi and update testproperties MVP
    [Arguments]    ${tc_label}    ${MAIL_DATA}
    Setting up to dictionary    ${vtm_data_list}    ${MAIL_DATA}
    Validate Kpi    ${tc_label}    ${MAIL_DATA}

Setting up to dictionary
    [Arguments]    ${vtm_data_list}    ${MAIL_DATA}
    FOR    ${index}    ${keys}    ${expected}    IN ZIP    ${vtm_data_list}    ${keys_list}    ${expected_values}
        Set To Dictionary    ${MAIL_DATA}    ${keys}=${index}/${expected}
    END
    Set Suite Variable    ${MAIL_DATA}
    Run Keyword If   '${test_label}' not in "@{MVP_TAGS}"    Enable KPI Data in Mail

Enable KPI Data in Mail
    Run Keyword If    '${calculate_kpi}' == 'True'    Append Kpi Data
    ${json_mail_data}=    Evaluate   json.dumps(${MAIL_DATA})    json
    Set Suite Variable    ${json_mail_data}

PET Deregister
    [Timeout]    10 minutes
    ute_wtssim.Execute Egate Command    seq_stop rate\=5 id\=all
    Sleep    1m
    Wait Until Keyword Succeeds    5min    10s
    ...    Active UE Count To Zero Check

Active UE Count To Zero Check
    Check sim_uec process if active
    ${active_ues_summary}=    Run Keyword    Active UE Count Status Check
    ${zero_ue}=    Run Keyword If    '${active_ues_summary[0]}' == '0'    Set Variable    True
    Should Be True    ${zero_ue}    msg=Deregister in Progress

Active UE Count Status Check
    ${output}=    ute_wtssim.Execute Egate Command And Wait For Data    ue_summary    timeout=10
    ${active_ues}=    Get Regexp Matches    ${output}    Active +(\\d+)    1
    Should Not Be Empty    ${active_ues}    msg=ue_summary has no result. Retry
    [Return]    ${active_ues}

Validate RRC UEs and update testproperties
    [Arguments]    ${test_tag}
    ${active_sa}=    Create List
    Set Suite Variable    @{active_sa}
    ${rrc_ue}=    Evaluate    int(${END_UE}*${rrc_limit_pet})
    ${status}=    Run Keyword If    '${active_ues_total}' < '${rrc_ue}'    Set Variable    FAIL
    Append To List    ${active_sa}    ${status}
    Run Keyword If    '${test_tag}' != 'UL_GBR_NonGBR' and '${test_tag}' != 'DL_GBR_NonGBR'    Append To File    ${test_property_file}
    ...    ${\n}${test_tag}_TEST_RESULTS={"s1-t1":{"Active Number of UEs" : "${active_ues_total}/${END_UE}"}}${\n}
    List Should Not Contain Value    ${active_sa}    FAIL    msg=Active No Of UEs are Less than expected

Traffic Loop for duration
    FOR    ${index}    IN RANGE    1    ${TRF_DURATION}+1    1
        Sleep    1m
        ${active_ues}    Wait Until Keyword Succeeds    30s    2s    Active UE Count Status Check
        Log To Console    Active UEs:${active_ues[0]}
        Set Suite Variable    ${active_ues_total}    ${active_ues[0]}
        Run Keyword and Ignore Error    Collect EM Traces and Stats    ${index}
        Run Keyword If    '${active_ues[0]}' == '0'    FAIL    msg=Active No Of UEs are zero
        Run Keyword If    '${AP_Snapshot}' == 'True'
        ...    Run Keyword and Ignore Error    Collect AP Snapshot During Test    ${TRF_DURATION}   ${index}
    END

Convert Values to mbps
    [Arguments]    ${bits}
    ${achieved_tput}=    Evaluate    (${bits}[0]*8)/float(300000)
    ${achieved_tput}=    Evaluate    "%.2f" % ${achieved_tput}
    [Return]    ${achieved_tput}

Convert Bits to Mbps
    [Arguments]    ${bits}
    ${achieved_tput}=    Evaluate    (${bits}*8)/float(60000*${COUNTER_DURATION})
    ${achieved_tput}=    Evaluate    "%.2f" % ${achieved_tput}
    [Return]    ${achieved_tput}

Validate Throughput
    [Arguments]    ${dir}    ${test_tag}    ${tput}
    ${pm_counter_status}=    Create List
    ${tput_status}=    Evaluate    ${tput} >= (${OVERALL_${dir}}*${${dir}_LIMIT})
    Log To Console    Achieved ${dir} Tput ${tput}
    Set Suite Variable    ${achieved_Throughput}    ${tput}
    Run Keyword If    '${test_tag}' != 'UL_GBR_NonGBR' and '${test_tag}' != 'DL_GBR_NonGBR'
    ...    Update Testproperties    ${dir}    ${test_tag}    ${tput}
    ${status}    Run Keyword And Ignore Error    Should Be True    '${tput_status}' == 'True'
    ...    msg=Traffic failed in Throughput, see error above!
    Append To List    ${pm_counter_status}    ${status[0]}
    List Should Not Contain Value    ${pm_counter_status}    FAIL    msg=Traffic failed in Throughput, see error above!

Update Testproperties
    [Arguments]    ${dir}    ${tc_name}    ${tput}
    ${ue_data}=    Set Variable    ${active_ues_total}/${END_UE}
    Run Keyword If    '${dir}' == 'DL'
    ...    Append To File    ${test_property_file}
    ...    ${\n}${tc_name}_TEST_RESULTS={"s1-t1":{"Active Number of UEs" : "${ue_data}", "DL_RATE":"${tput}Mbps/${OVERALL_DL}Mbps"}}${\n}
    Run Keyword If    '${dir}' == 'UL'
    ...    Append To File    ${test_property_file}
    ...    ${\n}${tc_name}_TEST_RESULTS={"s1-t1":{"Active Number of UEs" : "${ue_data}", "UL_RATE":"${tput}Mbps/${OVERALL_UL}Mbps"}}${\n}
    Run Keyword If    '${dir}' == 'both'
    ...    Append To File    ${test_property_file}
    ...    ${\n}${tc_name}_TEST_RESULTS={"s1-t1":{"Active Number of UEs" : "${ue_data}", "DL_RATE":"${tput}Mbps/${OVERALL_DL}Mbps",
    ...    "UL_RATE":"${tput}Mbps/${OVERALL_UL}Mbps"}}${\n}

Check Ng link
    ${AMF_PAIR}=    Catenate    SEPARATOR=,    1    ${AMF_COUNT}
    ${output}=    ute_wtssim.Execute Egate Command And Wait For Data
    ...    script file\=/opt/wts/latest/multi_ue_sa_script_new.lua entry\=check_NgLInk(${AMF_PAIR})
    ...    pass_regexp=Ng Link Check Script Completed    timeout=600
    Log To Console    Config file loaded successfully for checking Ng Link
    Wait Until Keyword Succeeds    5mins    30secs    Check Occurances from Egate Console    ${success_ng_link_pattern}    ${AMF_COUNT}

Fetch counter value from XML file
    [Arguments]    ${COUNTER}    ${directory}=${pmcouter_folder[0]}
    ${single_counter}=    Create List
    Set Suite Variable    @{single_counter}
    ${zero_list}=    Create List    0
    ${pm_file_latest}=    Run    find ${directory} -type f -iname "*.xml" | sort -r | head -1
    ${pm_file_exists}=    Run Keyword And Return Status    Should Not Be Empty    ${pm_file_latest}
    ${pm_file}=    Set Variable If    '${pm_file_exists}' == 'True'    ${pm_file_latest}
    ...    Log To Console    PM Counter File do not exist
    Set Suite Variable    ${pm_file}
    ${cmd_output}=    Fetch from Left    ${pm_file}    \r
    ${cmd_output}=    Run    cat ${cmd_output}
    ${counter_list}=    Get Regexp Matches    ${cmd_output}     \<${COUNTER}\>([0-9]+)
    ${single_counter}=    Run Keyword If    ${counter_list} == []    Set Variable    ${zero_list}
    ...    ELSE    List of counter validation    ${counter_list}
    Run Keyword If    ${counter_list} == []
    ...    Append To List    ${missing_counter}    ${COUNTER}
    [Return]    ${single_counter}

List of counter validation
    [Arguments]    ${counter_list}
    FOR    ${index}    IN    @{counter_list}
        ${counter_string}=    Convert to String    ${index}
        ${counter_string}=    Fetch From Right    ${counter_string}    >
        ${counter_string}=    Fetch From Left    ${counter_string}    '
        ${counter_value}=    Convert to Integer    ${counter_string}
        Run Keyword If    '${counter_value}' >= '0'
        ...    Append To List    ${single_counter}    ${counter_value}
    END
    [Return]    ${single_counter}

Check Cells Setup
    ${Cell_Count}=    Catenate    SEPARATOR=,    1    ${NO_OF_CELLS}
    ${output}=    ute_wtssim.Execute Egate Command And Wait For Data
    ...    script file\=/opt/wts/latest/multi_ue_sa_script_new.lua entry\=check_CellSetup(${Cell_Count})
    ...    pass_regexp=Cell Setup Check Script Completed    timeout=600
    Log To Console    Config file loaded successfully for checking Cell Setup
    ${status}=    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    5mins    30secs
    ...    Check Occurances from Egate Console    ${success_cell_setup_pattern}    ${NO_OF_CELLS}
    Run Keyword If    '${status[0]}' == 'FAIL' and '${test_label}' not in "@{VRAN_TCs}"
    ...    Check AP And gNB Backhaul Status    ${status}

Append Data to Test Properties
    [Arguments]    ${output_MAIL}
    Append To File    ${test_property_file}    ${output_MAIL}

Update Delta Parameters and Commission
    [Arguments]    ${test_tag}
    Set Variable Stream NR
    ${scf_file}=    Set Variable    ${EXECDIR}/topology-configs/${ute_ca_label}/${stream_nr}/${ute_ca_variant}/scfc.xml
    Run    cp ${scf_file} ${custom_perf_path}/${ute_ca_variant}/scfc.xml
    ${command}=    Catenate     python3 ${delta_reader} ${custom_perf_path}/${ute_ca_variant}/scfc.xml ${test_tag}
    ${result}=    Run    ${command}
    Should Not Contain    ${result}    Traceback    msg=Yaml Update failure! Check taf.config.scf library
    ${iphy_update}=    Get Variable Value    ${iphy_update}    None
    Run Keyword If    '${iphy_update}' == 'True'    Update PET Iphy File    ${test_tag}
    ${command}    Catenate    mkdir    -p /home/ute/scripts
    Run    ${command}
    ${input_scf}=    Catenate    ${custom_perf_path}/${ute_ca_variant}/scfc.xml
    ${output_scf}=    Set Variable    ${input_scf}
    Modify Vlan for Perf    input_scf=${input_scf}    output_scf=${output_scf}
    ${command}=    Catenate    cd ${CURDIR}/../QT/resources/scripts/ &&
    ...            python3 -c
    ...            "import scf_comm_script;scf_comm_script.scf_comm('${GNB_ASIK.Ip}', '${output_scf}')"
    ${commission_result}=    Run    ${command}
    Should Not Contain    ${commission_result}    Traceback    msg=Commission Failure! Terminating the execution
    ${status}    Run Keyword And Return Status    Reset and Check BTS State
    Run Keyword If    '${status}' == 'False'    Reset and Check BTS State

Reset and Check BTS State
    Coam Site Reset PET
    Wait Until Keyword Succeeds    20min    15sec    Coam Site Ready for PET

Coam Site Reset PET
    Wait Until Keyword Succeeds    5min    30sec    CoamAdmin.Connect To    bts_host=${GNB_ASIK.Ip}
    Wait Until Keyword Succeeds    5min    30sec    CoamAdmin.Reset Site
    [Teardown]    CoamAdmin.Teardown

Coam Site Ready for PET
    [Documentation]     This keyword checks whether TL is in Configured state and BTS sw is populated.
    Wait Coam Site to be Ready
    Should Contain    ${stream_nr}    SBTS

Get counter value per Cell
    [Arguments]    ${cell_id}    ${return_list}
    ${command}=    Catenate    cd ${CURDIR}/scripts/ &&
    ...       python3 -c
    ...       "import wrapper_methods;wrapper_methods.add_list_entries(${return_list})"
    ${final_scell}=    Run    ${command}
    Should Not Contain    ${final_scell}    Traceback    msg=Exception during adding list entries
    ${final_scell}=    Remove String    ${final_scell}    [    ]    ${SPACE}
    ${final_list}=    Create List   ${final_scell.split(",")}
    ${cell_id}=    Evaluate    (${cell_id}-1)
    ${final_scell}=    Set Variable    ${final_list}[0][${cell_id}]
    [Return]    ${final_scell}

Check SIB Messages
    [Arguments]    ${cells}
    ...    ${command}=grep "Number of Expected SIBs" /opt/wts/latest/egate_console.log | tr "|" "\n"
    ${output}=    ute_wtssim.Execute Egate Command And Wait For Data
    ...    script file\=/opt/wts/latest/multi_ue_sa_script_new.lua entry\=check_SIBs_withUECcount(${start_cell},${cells},${UEC_COUNT})
    ...    pass_regexp=Total SIBs received    timeout=${SIB_TIMEOUT}
    ${result}     Run    ${command}
    ${result_list}=    Create List    ${result.split("\n")}
    @{expected_SIB}=    Split String    ${result_list[0][2]}    :
    @{received_SIB}=    Split String    ${result_list[0][3]}    :
    Should Be Equal As Integers    ${expected_SIB[1]}    ${received_SIB[1]}    msg=SIB not received

Convert Data To String
    ${list_length}=    Get Length    ${mail_data}
    ${mail_list}=     Get Slice From List    ${mail_data}    0    ${list_length}
    ${final_string}=    Evaluate    ",".join(${mail_list})
    Set Suite Variable    ${final_string}

Check The Index for Counter Check
    [Arguments]    ${index}
    ${mod}=    Evaluate    (${index}%${COUNTER_DURATION})
    [Return]    ${mod}

Loop for Counters
    [Arguments]    ${counter_list}    ${counter_index_data}
    ${missing_counter}=    Create List
    Set Suite Variable    @{missing_counter}
    Run Keyword If    '${test_label}' == 'TDD_FDD_CB012149' or '${test_label}' == 'CB012149_TC2' or '${test_label}' == 'TDD_DSS_ULCA'
    ...    Fetch Counter value with Index value
    ...    ${counter_list}    ${counter_index_data}
    ...    ELSE    Fetch Counter value without Index value    ${counter_list}
    Run Keyword If    '${test_label}' == 'TDD_DSS_ULCA'    Display Values with Pairing Ratio

Loop for vRAN Counters
    [Arguments]    ${counter_list}
    FOR    ${counter}    IN    @{counter_list}
        ${value}=    Run Keyword    Fetch Counter Value from vRAN vCU    ${counter}
        Append To List    ${pm_counter_list}    ${value}
    END

Deregister and Append Data
    [Arguments]    ${tc_name}    ${pre_data}=None
    ute_wtssim.Execute Egate Command    filter_sim_rfm enable\=all
    ute_wtssim.Execute Egate Command    set_log flush
    ${TCP_TRF_STATS}=    Get Variable Value    ${TCP_TRF_STATS}    None
    Run Keyword If    '${TCP_TRF_STATS}' == 'True'    Display Stats for TCP Traffic
    Run Keyword If    '${tc_name}' not in "@{VTM_MVP_TAGS}"    Append Data    ${tc_name}    ${pre_data}
    Run Keyword If    '${tc_name}' not in "@{VTM_MVP_TAGS}" and '${TEST STATUS}' != 'FAIL'
    ...    Wait Until Keyword Succeeds    60min    1min    Detach String Check During Teardown    ${detach_string}
    Run Keyword    Deregister PET_SE
    Run Keyword If    '${tc_name}' not in "@{MVP_TAGS}"    Run Keyword and Ignore Error    Seq Stats Status
    ...    ELSE    Run Keyword    Seq Stats MVP Status
    ${final_test_property_data}    Run Keyword If    '${PET_DICHOTOMY}' == 'True'
    ...    Append Dichotomy Validation Status to Mail    ${final_test_property_mail_data}
    Run Keyword And Ignore Error    Mark end of Test case
    ${deregister_fail}=    Get Variable Value    ${DEREGISTER_FLAG}    None
    Run Keyword If    '${deregister_fail}' == 'FAIL'    FAIL    Deregister failed!

Append Data
    [Arguments]    ${tc_name}    ${pre_data}=None
    Run keyword If     '${SCF_STATUS}' == 'True' and '${test_label}' in "@{SCF_ERROR_CHECK}"
    ...    SCF Error Validation    ${apConfiguration}
    Set To Dictionary    ${MAIL_DATA}    TEST_TAGS=${tc_name}
    ${final_data}=    Get Variable Value    ${DATA}    ${MAIL_DATA}
    ${type_of_pre_data}=    Evaluate    type(${pre_data}).__name__
    ${type_of_final_data}=    Evaluate    type(${final_data}).__name__
    ${final_test_property_data}=    Run Keyword If    '${type_of_pre_data}' != 'NoneType' and '${type_of_final_data}' != 'NoneType'
    ...    Run Keyword    Merge Dictionaries    ${final_data}    ${pre_data}
    ...    ELSE IF    '${type_of_final_data}' == 'NoneType' and '${type_of_pre_data}' != 'NoneType'
    ...    Set Variable    ${pre_data}
    ...    ELSE IF    '${type_of_final_data}' != 'NoneType' and '${type_of_pre_data}' == 'NoneType'
    ...    Set Variable    ${final_data}
    ...    ELSE    Set Variable    ${final_data}
    Set Suite Variable    ${final_test_property_mail_data}    ${final_test_property_data}
    ${final_test_property_data}    Run Keyword If    '${SCF_STATUS}' == 'True' and '${test_label}' in "@{SCF_ERROR_CHECK}"
    ...    Append SCF Validation Status to Mail    ${final_test_property_data}
    Run Keyword If    '${SCF_STATUS}' == 'True' and '${test_label}' in "@{SCF_ERROR_CHECK}"
    ...    Append Final mail Data to json    ${final_test_property_data}
    ...    ELSE    Append Final mail Data to json    ${final_test_property_mail_data}
    Append To File    ${test_property_file}
    ...    ${\n}${tc_name}_TEST_RESULTS={"s1-t1":${json_mail_data}}${\n}

Append Final mail Data to json
    [Arguments]    ${mail_data}
    ${json_mail_data}=    Evaluate   json.dumps(${mail_data})    json
    Set Suite Variable    ${json_mail_data}

Write Multiple Counters INI Entry
    [Arguments]    @{entries}    ${path}=${pm_counter_data_ini_file}
    ${blocks}=    Create List
    FOR    ${entry}    IN    @{entries}
        ${is_list}=    Run Keyword And Return Status    Get From List    ${entry}    0
        Run Keyword If    not ${is_list}    Log To Console    Skipping empty/non-list entry: ${entry}
        Run Keyword If    not ${is_list}    Continue For Loop
        ${counter}=    Get From List    ${entry}    0
        ${title}=      Get From List    ${entry}    1
        ${value}=      Get From List    ${entry}    2
        ${message}=    Get From List    ${entry}    3
        ${expected}=   Get From List    ${entry}    4
        IF    '${message}' == 'None'
            ${msg_line}=    Set Variable    message="None"
        ELSE
            ${msg_line}=    Set Variable    message="${message}"
        END
        ${limit_line}=    Set Variable
        IF    '${counter}' == '${RRC_UE_COUNTER}'
            ${limit_line}=    Set Variable    threshold=${rrc_limit_pet}
        ELSE IF    '${counter}' == '${DL_TPUT_COUNTER}'
            ${limit_line}=    Set Variable    threshold=${DL_LIMIT}
        ELSE IF    '${counter}' == '${UL_TPUT_COUNTER}'
            ${limit_line}=    Set Variable    threshold=${UL_LIMIT}
        END
        ${block}=    Catenate    SEPARATOR=\n
        ...    [${counter}]
        ...    title="${title}"
        ...    value=${value}
        ...    ${msg_line}
        ...    expected_value=${expected}
        IF    '${limit_line}' != ''
            ${block}=    Catenate    SEPARATOR=\n
            ...    ${block}
            ...    ${limit_line}
        END
        Append To List    ${blocks}    ${block}
    END
    ${blocks_len}=    Get Length    ${blocks}
    Run Keyword If    ${blocks_len} == 0    Log To Console    No entries to write; exiting.    RETURN
    ${contents}=    Catenate    SEPARATOR=\n\n
    ...    @{blocks}
    Create File    ${path}    ${contents}    encoding=UTF-8

Intermediate PET Traffic Validation
    [Arguments]    ${dir}    ${tput}
    Run Keyword If    '${PET_DICHOTOMY}' == 'True'    Counter Validation for Dichotomy
    ${tput_status}=    Evaluate    (${tput} >= (${OVERALL_${dir}}*${${dir}_LIMIT}))
    ${tput_data}=    Set Variable    "${dir}_RATE(Mbps)":"${tput}/${OVERALL_${dir}}"
    Log To Console    ${tput_data}
    ${status}    Run Keyword And Ignore Error    Should Be True    '${tput_status}' == 'True'
    ...    msg=Traffic failed in Throughput, see error above!
    IF    '${tput_status}' == 'False'
        ${message_text}=    Set Variable    Failing ${tput}/${OVERALL_${dir}}
    ELSE
        ${message_text}=    Set Variable    None
    END
    IF    '${dir}' == 'DL'
        ${counter}=    Set Variable    ${DL_TPUT_COUNTER}
    ELSE IF    '${dir}' == 'UL'
        ${counter}=    Set Variable    ${UL_TPUT_COUNTER}
    ELSE
        ${counter}=    Set Variable    unknown_counter
    END
    ${title}=    Set Variable    ${dir} validation
    ${dl_ul_entry}=    Create List    ${counter}    ${title}    ${tput}    ${message_text}    ${OVERALL_${dir}}
    Set Suite Variable    ${dl_ul_entry}    ${dl_ul_entry}
    Append To List    ${test_verdict}    ${status[0]}
    [Return]    ${dl_ul_entry}

Intermediate PET Traffic Validation DLandUL
    [Arguments]    ${dl_tput}    ${ul_tput}
    Run Keyword If    '${PET_DICHOTOMY}' == 'True'    Counter Validation for Dichotomy
    ${tput_dl_status}=    Evaluate    (${dl_tput} >= (${OVERALL_DL}*${DL_LIMIT}))
    ${tput_ul_status}=    Evaluate    (${ul_tput} >= (${OVERALL_UL}*${UL_LIMIT}))
    ${tput_dl_data}=    Set Variable    "DL RATE":"${dl_tput}/${OVERALL_DL}"
    Log To Console    ${tput_dl_data}
    ${tput_ul_data}=    Set Variable    "UL RATE":"${ul_tput}/${OVERALL_UL}"
    Log To Console    ${tput_ul_data}
    ${dl_status}    Run Keyword And Ignore Error    Should Be True    '${tput_dl_status}' == 'True'
    ...    msg=Traffic failed in Throughput, see error above!
    ${ul_status}    Run Keyword And Ignore Error    Should Be True    '${tput_ul_status}' == 'True'
    ...    msg=Traffic failed in Throughput, see error above!
    Append To List    ${test_verdict}    ${dl_status[0]}
    Append To List    ${test_verdict}    ${ul_status[0]}

Validate Active UEs Data
    ${ue_limit}=    Evaluate    (${END_UE}*${rrc_limit_pet})
    Set Suite Variable    ${active_ues_total}    ${pm_counter_list[0]}
    ${ue_data}=    Set Variable    "Active Number Of UEs":"${active_ues_total}/${END_UE}"
    Log To Console    ${ue_data}
    ${ue_stat}=    Evaluate    (${pm_counter_list[0]} >= ${ue_limit})
    ${ue_status}=    Run Keyword If    '${ue_stat}' == 'True'    Set Variable    True
    ...    ELSE    Set Variable    FAIL
    ${message_text}=    Run Keyword If    '${ue_status}' == 'FAIL'
    ...    Set Variable    Failing ${active_ues_total}/${END_UE}
    ...    ELSE
    ...    Set Variable    None
    ${ue_entry}=    Create List    ${RRC_UE_COUNTER}    Active UEs    ${active_ues_total}    ${message_text}    ${END_UE}
    Set Suite Variable    ${ue_status}
    Append To List    ${test_verdict}    ${ue_status}
    [Return]    ${ue_entry}

Validate Tput Data
    [Arguments]    ${dir}    ${test_tag}
    Log To Console    Validating ${test_tag}
    ${achieved_tput}=    Run Keyword If    '${dir}' == 'DL' or '${dir}' == 'UL' or '${dir}' == 'PDCP_UL'
    ...    Convert Bits to Mbps    ${pm_counter_list[1]}
    Run Keyword If    '${dir}' == 'DL' or '${dir}' == 'UL' or '${dir}' == 'PDCP_UL'    Set List Value    ${pm_counter_list}    1    ${achieved_tput}
    Run Keyword If    '${dir}' == 'DL' or '${dir}' == 'UL' or '${dir}' == 'PDCP_UL'    Set Suite Variable    ${final_tput}    ${achieved_tput}
    ${achieved_dl_tput}=    Run Keyword If    '${dir}' == 'both'
    ...    Convert Bits to Mbps    ${pm_counter_list[1]}
    Run Keyword If    '${dir}' == 'both'    Set List Value    ${pm_counter_list}    1    ${achieved_dl_tput}
    ${achieved_ul_tput}=    Run Keyword If    '${dir}' == 'both'
    ...    Convert Bits to Mbps    ${pm_counter_list[2]}
    Run Keyword If    '${dir}' == 'both'    Set List Value    ${pm_counter_list}    2    ${achieved_ul_tput}
    Run Keyword If    '${dir}' == 'both'    Set Suite Variable    ${final_dl_tput}    ${achieved_dl_tput}
    Run Keyword If    '${dir}' == 'both'    Set Suite Variable    ${final_ul_tput}    ${achieved_ul_tput}
    Run Keyword If    '${dir}' == 'DL' or '${dir}' == 'UL'    Intermediate PET Traffic Validation
    ...    ${dir}    ${final_tput}
    ...    ELSE IF    '${dir}' == 'PDCP_UL'    Intermediate PET Traffic Validation with range    ${dir}    ${final_tput}
    ...    ELSE    Intermediate PET Traffic Validation DLandUL    ${final_dl_tput}
    ...    ${final_ul_tput}

Fetch Counters and Add Data to mail dictionary
    [Arguments]    ${DATA}
    FOR    ${index_list}    ${keys}    ${expected}    IN ZIP    ${pm_counter_list}    ${keys_list}    ${expected_values}
        Set To Dictionary    ${DATA}    ${keys}=${index_list}/${expected}
    END
    Run Keyword If    '${NRDC_FR2}' == 'True'    Insert Into List    ${pm_counter_list}    0    ${accumulated_value}
    Run Keyword If    '${calculate_kpi}' == 'True'
    ...    Append Kpi Data    ${DATA}
    Set To Dictionary    ${DATA}    TEST_TAGS=${test_label}
    Set Suite Variable    ${DATA}

Check for Test Verdict
    List Should Not Contain Value    ${test_verdict}    FAIL    msg=Traffic failed in Throughput, see error above!

Merge Dictionaries
    [Arguments]    ${DATA}    ${dictionary_data}
    ${command}=    Catenate    cd ${CURDIR}/scripts/ &&
    ...       python3 -c
    ...       "import wrapper_methods;wrapper_methods.merge_dictionaries(${DATA},${dictionary_data})"
    ${final_dictionary}=    Run    ${command}
    Should Not Contain    ${final_dictionary}    Traceback    msg=Exception during Merging dictionaries
    Set Suite Variable    ${final_dictionary}
    [Return]    ${final_dictionary}

Validate Cell Data
    [Arguments]    ${TYPE}
    ${len}=    Get length    ${pm_counter_list}
    ${final_list}=    Get Slice From List    ${pm_counter_list}    ${${EXPECTED_${TYPE}_Pos}}    ${len}
    ${peak_value}=    Evaluate    sum(map(int, ${final_list}))
    ${counter_value}=    Convert to Integer    ${peak_value}
    Insert Into List    ${pm_counter_list}    ${EXPECTED_PEAKVoNR_Pos}    ${counter_value}
    ${bearer_value_check}=    Evaluate    (${counter_value} == ${EXPECTED_PEAKVoNR})
    ${bearer_stats}=    Set Variable If    '${bearer_value_check}' == 'True'    True    FAIL
    ${bearer_data}=    Set Variable    "${TYPE}" : "${counter_value}/${EXPECTED_PEAKVoNR}"
    Log To Console    ${bearer_data}
    Set Suite Variable    ${bearer_stats}
    Append To List    ${test_verdict}   ${bearer_stats}

Traffic Loop With Tput Validation
    [Arguments]    ${dir}    ${test_tag}    ${counter_list}    ${DATA}    ${counter_index_data}=None
    ${skip_raw}=    Get Variable Value    ${SKIP_INITIAL_ITERATIONS}    None
    @{skip_iteration_list}=    Create List    1
    ${skip_str}=    Convert To String    ${skip_raw}
    Run Keyword If
    ...    '${skip_raw}' != 'None' and ',' in '${skip_str}'
    ...    Extend Skip List (Comma)    ${skip_str}    ${skip_iteration_list}
    ...    ELSE IF    '${skip_raw}' != 'None' and ',' not in '${skip_str}'
    ...    Extend Skip List (Range)    ${skip_str}    ${skip_iteration_list}
    ${wts_summary}=    Get Variable Value    ${ENABLE_WTS_SUMMARY}    False
    Set Suite Variable    ${wts_summary}
    Run Keyword If    ${wts_summary}    Display WTS Summary
    Run Keyword If    '${test_label}' in "@{POST_REGISTRATION_TAGS}"    Validate Counter Accumulation    ${POST_REGISTRATION_COUNTERS}
    FOR    ${index}    IN RANGE    1    ${TRF_DURATION}+1    1
        Check sim_uec process if active
        Create PM counter local directory
        ${pm_counter_list}=    Create List
        Set Suite Variable    @{pm_counter_list}
        ${test_verdict}=    Create List
        Set Suite Variable    @{test_verdict}
        Set Suite Variable    ${iteration_to_check}    ${index}
        ${index_mod}=    Evaluate    ${index} % ${COUNTER_DURATION}
        ${validate_condition}=    Catenate    ${index} not in ${skip_iteration_list} and ${index_mod} == 0
        ...    and ${index} != ${COUNTER_DURATION} and '${test_label}' not in ${SKIP_VALIDATION_TAGS}
        ${should_validate}=    Evaluate    ${validate_condition}
        Run Keyword If    ${should_validate}
        ...    Loop and Validate Counters
        ...    ${test_tag}    ${dir}    ${counter_list}    ${DATA}    ${counter_index_data}
        ...    ELSE    Sleep    1m
        Run Keyword If    '${AP_Snapshot}' == 'True'
        ...    Run Keyword and Ignore Error    Collect AP Snapshot During Test    ${TRF_DURATION}    ${index}
        Run Keyword and Ignore Error    Collect EM Traces and Stats    ${index}
    END
    Run Keyword If    '${PET_DICHOTOMY}' == 'True'    Counter Validation for Dichotomy

Extend Skip List (Comma)
    [Arguments]    ${skip_str}    ${skip_iteration_list}
    Log To Console    Skipping iterations (comma list): ${skip_str}
    @{vals}=    Split String    ${skip_str}    ,
    FOR    ${v}    IN    @{vals}
        ${v}=    Convert To Integer    ${v}
        Run Keyword If    ${v} not in @{skip_iteration_list}
        ...    Append To List    ${skip_iteration_list}    ${v}
    END

Extend Skip List (Range)
    [Arguments]    ${skip_str}    ${skip_iteration_list}
    Log To Console    Skipping iterations (range): 1 to ${skip_str}
    ${limit}=    Convert To Integer    ${skip_str}
    FOR    ${i}    IN RANGE    1    ${limit}+1
        Run Keyword If    ${i} not in @{skip_iteration_list}
        ...    Append To List    ${skip_iteration_list}    ${i}
    END

Loop and Validate Counters
    [Arguments]    ${test_tag}    ${dir}    ${counter_list}    ${DATA}    ${counter_index_data}
    Run Keyword If     '${PET_VRAN}' != 'True'
    ...    Loop for Counters    ${counter_list}    ${counter_index_data}
    ...    ELSE    Loop for vRAN Counters    ${counter_list}
    Run Keyword If    '${PET_VRAN}' != 'True'    Create PM Counter List
    Run Keyword If    '${GNB_COUNT}' > '1'    Add the list entries of counters
    ...    ELSE IF    '${PET_VRAN}' == 'True'    Set Suite Variable    ${pm_counter_list}
    ...    ELSE    Set Suite Variable    ${pm_counter_list}    ${pm_counter_list_1}
    ${ue_entry}=      Set Variable    None
    Set Suite Variable    ${ue_entry}
    ${dl_ul_entry}=   Set Variable    None
    Set Suite Variable    ${dl_ul_entry}
    ${ue_entry}=    Validate Active UEs Data
    Set Suite Variable    ${ue_entry}
    Run Keyword If    '${calculate_kpi}' == 'True' and '${ue_status}' == 'True'
    ...    KPI Calculation and Validation
    ${DIST_NAME}=    Run Keyword And Return Status    Variable Should Exist    ${DIST_NAME}
    Run Keyword If    '${DIST_NAME}' == 'True'    Fetch and display parameters in real time from the gNB GUI
    ${DUAL_BOOST_MODE}=    Run Keyword And Return Status    Variable Should Exist    ${DUAL_BOOST_MODE}
    Run Keyword If    '${DUAL_BOOST_MODE}' == 'True'    Validate Cumulative Counters For DL UL Mode
    ${AvgDRB}=    Get Variable Value    ${AvgDRB}    None
    ${GNBCU_X2U_DATA}=    Get Variable Value    ${GNBCU_X2U_DATA}    None
    Run Keyword If    '${GNBCU_X2U_DATA}' == 'True'    Validate Incremental Split counter
    ...    GNBCU_X2U_DATA
    ${PeakVoNR}=    Get Variable Value    ${PeakVoNR}    None
    Run Keyword If    '${PeakVoNR}' == 'True'    Validate Cell Data    PeakVoNR
    ${CAP}=    Get Variable Value    ${CAP}    None
    Run Keyword If    '${CAP}' == 'True'    Validate UL TX values    CAP
    ${RX_POWER_LANE_MIN}=    Get Variable Value    ${RX_POWER_LANE_MIN}    None
    Validate All Counters    @{GENERIC_COUNTERS}
    ${CONF}=    Get Variable Value    ${CONF}    None
    Run Keyword If    '${CONF}' == 'True'    Validate UL TX values    CONF
    ${MIMO}=    Get Variable Value    ${MIMO}    None
    Run Keyword If    '${MIMO}' == 'True'    Pairing Success Ratio Calculation
    ${RLC_COUNTER}=    Get Variable Value    ${RLC_COUNTER}    None
    Run Keyword If    '${RLC_COUNTER}' == 'True'    RLC Tdd Fdd Counter Validation    ${dir}
    ${CELL_DATA}=    Get Variable Value    ${CELL_UE}    None
    Run Keyword If    '${CELL_DATA}' == 'True'    Validate Active UEs At Cell Level    CELL_UE
    Run Keyword If    '${dir}' != 'None'    Validate Tput Data    ${dir}    ${test_tag}
    ${CELL_Tput}=    Get Variable Value    ${CELL_Tput}    None
    Run Keyword If    '${CELL_Tput}' == 'True'    Validate CELL TPUT
    Run Keyword If    '${iteration_to_check}' == '10' and '${ue_stats_var_exist}' == 'True'
    ...    Validate UE_STATS_NR
    ${EXP}=    Get Variable Value    ${EXP}    None
    Run Keyword If    '${EXP}' == 'True'    Calculate expression
    Fetch Counters and Add Data to mail dictionary    ${DATA}
    ${all}=    Create List    ${ue_entry}    ${dl_ul_entry}
    Write Multiple Counters INI Entry    @{all}    path=${pm_counter_data_ini_file}
    List Should Not Contain Value    ${test_verdict}    FAIL    msg=TestCase Failed, Validation Criteria not met!

Validate All Counters
    [Arguments]    @{counter_list}
    FOR    ${counter}    IN    @{counter_list}
        ${flag}=    Get Variable Value    ${${counter}}    None
        Run Keyword If    '${flag}' == 'True'
        ...    Validate Counter Against Expected Value    ${counter}
    END

Validate Incremental Split counter
    [Arguments]    ${TYPE}
    ${increment_counter_value}=    Convert Bits to Mbps    ${pm_counter_list[${EXPECTED_${TYPE}_Pos}]}
    Set List Value    ${pm_counter_list}    ${EXPECTED_${TYPE}_Pos}    ${increment_counter_value}
    ${increment_counter_value_check}=    Evaluate    (${increment_counter_value} > ${EXPECTED_${TYPE}})
    ${increment_counter_stats}=    Set Variable If    '${increment_counter_value_check}' == 'True'    True    FAIL
    ${increment_counter_data}=    Set Variable    "${dir}_${TYPE}(Mbps)" : "${increment_counter_value}"
    Log To Console    ${increment_counter_data}
    Set Suite Variable    ${increment_counter_stats}
    Append To List    ${test_verdict}   ${increment_counter_stats}

Check MU_MIMO Pairing Counters
    [Arguments]    ${counters}
    ${MIMO_PAIR_VALUES}=    Create List
    Set Suite Variable    @{MIMO_PAIR_VALUES}
    FOR    ${counter}    IN    @{counters}
        ${value}=    Run Keyword    Counter Fetch   ${counter}
        Append To List    ${MIMO_PAIR_VALUES}    ${value[0]}
    END
    FOR    ${index}    IN    @{MIMO_PAIR_VALUES}
        Log To Console    MIMO PAIR Value ${index}
    END
    List Should Not Contain Value    ${MIMO_PAIR_VALUES}    '0'    msg=Failed at MIMO Pair check!

Update PET Iphy File
    [Arguments]    ${wft_label_fr1}
    ${command}    Catenate    mkdir    -p ${local_path}
    Run    ${command}
    SSH.Connect To    ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}    alias=${AP_ASIK.Connection}
    Download File    ${remote_path}/iphy.xml    ${local_path}/iphy.xml    ${AP_ASIK.Connection}
    ${command}        Catenate     python3 ${config_reader} ${local_path}/iphy.xml
    ...    ${wft_label_fr1}
    Run    ${command}
    Sleep    2s
    SSH.Upload File    ${local_path}/iphy.xml    /ffs/run/simmode/updated_iphy.xml    ${AP_ASIK.Connection}
    SSH.Send Command    ln -f -s /ffs/run/simmode/updated_iphy.xml /ffs/run/simmode/iphy.xml
    ...    timeout=60    connection=${AP_ASIK.Connection}
Activate BSR File
    [Arguments]    ${bsr_package}    ${bsr_package_path}
    Clone Entitytest Repo    ${bsr_package_path}
    Log To Console    Uploading and Activating BSR Package
    Wait Until Keyword Succeeds    5min    5sec    CoamAdmin.Connect To    bts_host=${GNB_ASIK.Ip}
    CoamAdmin.Update Software    ${bsr_package_path}
    Wait Until Keyword Succeeds    2 min    10 sec
    ...    Verify BSR Activated
    ...    ${bsr_package}
    Log To Console    BSR Package Matching
    [Teardown]    CoamAdmin.Teardown

Verify BSR Activated
    [Arguments]    ${bsr_package}
    ${active_bsr}=    Get BSR File
    Check If File Exists In BSR Dictionary    ${active_bsr}    ${bsr_package}
    Should Be True    ${file_found}    BSR Package Not Matching!

Check If File Exists In BSR Dictionary
    [Arguments]    ${bsr_data}    ${filename}
    ${bsr_inuse}    Set Variable    ${bsr_data['bsrFileInused']}
    ${file_found}    Set Variable    False
    FOR    ${item}    IN    @{bsr_inuse}
        ${current_file}    Set Variable    ${item['filename']}
        Run Keyword If    '${current_file}' == '${filename}'    Log To Console    ${filename} is present
        Run Keyword If    '${current_file}' == '${filename}'    Set Suite Variable    ${file_found}    True
    END
    Run Keyword If    '${file_found}' == 'False'    Set Suite Variable    ${file_found}    False

Get BSR File
    Wait Until Keyword Succeeds    5min    10sec    admin.Connect To    bts_host=${GNB_ASIK.Ip}
    ${bsr_files}    admin.Get Bsr Files
    ${type__string}=    Evaluate     type(${bsr_files})
    Log To Console    ${type__string}
    Set Suite Variable    ${active_bsr}    ${bsr_files}
    [Return]    ${active_bsr}

Seq Stats Status
    Check sim_uec process if active
    ute_wtssim.Execute Egate Command    filter_sim_rfm enable\=all
    FOR    ${index}    IN    @{stat_list}
        ute_wtssim.Execute Egate Command
        ...    script file\=/opt/wts/latest/commands.lua entry\=seq_stats_disp(${index[0]},${index[1]})
        ...    timeout=100
        Sleep    1m
        ute_wtssim.Execute Egate Command    script_stop
    END

Seq Stats MVP Status
    Check sim_uec process if active
    ${stat_list}=    Split String    ${SEQ_LIST}    ,
    Set Suite Variable    @{stat_list}
    ute_wtssim.Execute Egate Command    filter_sim_rfm enable\=all
    ute_wtssim.Execute Egate Command
    ...    script file\=/opt/wts/latest/commands.lua entry\=seq_stats_disp_mvp(${stat_list[0]},${stat_list[1]})
    ...    timeout=100
    Wait Until Keyword Succeeds    5min    1min    Check Occurances from Egate Console    ${seq_stat_completed}    1

Fetch Cummulative Values
    [Arguments]    ${counter}
    SSH.Connect To   ${GNB_ASIK.Ip}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}
    ...              alias=${GNB_ASIK.Connection}
    ${pm_file}=    SSH.Execute    ls -lrt /tmp/PM.*.ANY.xml.gz | tail -${pmcounter_iteration} | awk '{print $9}'    ${GNB_ASIK.Connection}
    @{list}=    Split To Lines    ${pm_file}
    ${main_list}=    Create List
    Set Suite Variable    @{main_list}
    FOR    ${index}    IN    @{list}
        ${cmd_output}=    SSH.Execute   zcat ${index}  ${GNB_ASIK.Connection}
        ${counter_list}=    Get regexp matches    ${cmd_output}     \<${counter}\>([0-9]+)
        ${result}=    Conversion To List and Append    ${counter_list}
        Append To List    ${main_list}    ${result}
    END
    [Return]    ${main_list}

Conversion To List and Append
    [Arguments]    ${counter_list}
    ${intermediate_list}=    Create List
    FOR    ${item}    IN    @{counter_list}
        ${counter_string}=    Convert to String    ${item}
        ${counter_string}=    Fetch From Right    ${counter_string}    >
        ${counter_string}=    Fetch From Left    ${counter_string}    '
        ${counter}=    Convert to Integer    ${counter_string}
        Append To List    ${intermediate_list}    ${counter}
    END
    [Return]    ${intermediate_list}

Fetch Sum of Counter lists for Multiple Counters
    [Arguments]    ${updated_counters}=${COUNTER_LIST}
    @{COUNTERS}=    Create List
    Set Suite Variable    ${COUNTERS}
    FOR    ${ID}    IN    @{updated_counters}
       ${VALUE}    Run Keyword    Fetch counter value from XML file    ${ID}
       Append To List    ${COUNTERS}    ${VALUE}
    END
    ${command}=    Catenate    cd ${CURDIR}/scripts/ &&
    ...       python3 -c
    ...       "import wrapper_methods;wrapper_methods.add_list_entries(${COUNTERS})"
    ${RATE}=    Run    ${command}
    Should Not Contain    ${RATE}    Traceback    msg=Exception during summation
    ${achieved_rate}=    Evaluate    (sum(${RATE})/((${COUNTER_DURATION})*60))
    Log To Console    ${achieved_rate}
    Run Keyword If    '${calculate_kpi}' == 'True'
    ...    KPI Calculation and Validation
    [Return]    ${achieved_rate}

Enable SIM RFM Logging
    ute_wtssim.Execute Egate Command    filter_sim_rfm disable\=all
    ute_wtssim.Execute Egate Command    filter_sim_rfm enable\=CSI,ACR,OERR,IERR,VIP

Start sosReport Tcpdump for PET
    [Timeout]    10 minutes
    Run Keyword If    '${SAVE_WTS_PCAP_FLAG}' == 'True'
    ...    Run Keyword and Ignore Error    Start WTS Tcpdump for PET    ${vm_logdir}/WTS.pcap
    Run    sudo chmod 777 ${sosReportStart}
    Log to Console        ${sosReportStop}
    SSH.Connect To        127.0.0.1    ute    ute    alias=sosReportConnection
    ${result}             SSH.Execute    ${sosReportStart}    sosReportConnection
    Log to Console        ${result}

Start WTS Tcpdump for PET
    [Arguments]    ${pcapFile}
    Run                   sudo rm -f ${pcapFile}
    Run                   sudo tcpdump -i any -p sctp -w ${pcapFile} > /dev/null 2>&1 &
    ${check}              Run    sudo pgrep -l tcpdump
    Log To Console        ${check} ${pcapFile}
    ${disown}             Run    disown --help
    Log To Console        ${disown}

Stop sosReport Tcpdump for PET
    [Arguments]    ${prefix}   ${exclude_pcap}=0
    [Timeout]    40 minutes
    Stop BIP and collect SOS for APoverABIO for PET    ${prefix}    ${exclude_pcap}

Stop BIP and collect SOS for APoverABIO for PET
    [Arguments]    ${prefix}=${EMPTY}    ${exclude_pcap}=0
    Run Keyword If    '${SAVE_WTS_PCAP_FLAG}' == 'True' and '${TTI_TRACE}' == 'False'
    ...    Run Keyword And Ignore Error
    ...                      Stop WTS sosReport pcap    ${prefix}   ${exclude_pcap}
    Run    sudo chmod 777 ${sosReportStop}
    ${command}               Catenate    cd ${uteEpcDir} && ./${sosReportStop}
    Log To Console           ${command}
    Run    ${command}
    Move BIP logs from ap and gnb    ${prefix}    ${exclude_pcap}

SCF Error Validation
    [Arguments]    ${test_label}
    ${input_scf}=    Catenate    ${INPUT_SCF}
    ${command}=    Catenate    cd ${CURDIR}/../QT/resources/scripts/ &&
    ...            python -c
    ...            "import scf_comm_script;scf_comm_script.scf_comm('${GNB_ASIK.Ip}', '${input_scf}', 'False', 'False')"
    ${result}=    Run Process    ${command}    shell=True
    Append To File    /home/ute/SCF_Activation.txt    ${result.stdout}
    Append To File    /home/ute/SCF_Activation.txt    ${result.stderr}
    Run    sudo chmod 777 ${SCF_JSON_CHECKER}
    Run    sudo chmod 777 ${SCF_JSON}
    ${cmd}=    Catenate    python    ${SCF_JSON_CHECKER}    ${SCF_JSON}    /home/ute/SCF_Activation.txt    ${test_label}
    ...    /home/ute/scf_errors.txt
    ${output}=    Run Process    ${cmd}    stdout=STRING    stderr=STRING    shell=True
    Log    ${output.stdout}
    @{lines}=    Split String    ${output.stdout}    \n
    Log To Console    ${lines}[-1]
    ${SCF_VALIDATION_STATUS}    Set variable    ${lines}[-1]
    Set Suite Variable    ${SCF_VALIDATION_STATUS}
    Run    mv /home/ute/SCF_Activation.txt ${vm_logdir}/
    Run    mv ${SCF_JSON} ${vm_logdir}/
    Run    mv /home/ute/scf_errors.txt ${vm_logdir}/

Append SCF Validation Status to Mail
    [Arguments]    ${final_test_property_data}
    @{lines}=    Split String    ${SCF_VALIDATION_STATUS}    :
    &{new_dict}=    Create Dictionary    ${lines}[0]=${lines}[1]
    ${final_test_property_data}=    Merge Dictionaries    ${final_test_property_data}    ${new_dict}
    [Return]    ${final_test_property_data}

Combine List to one List
    [Arguments]    ${value}
    ${pm_counter_list_1}=    Run Keyword If    '${CELL_UE}' == 'True'    Combine List With Index    ${value}
    ...    ELSE    Combine Lists    ${pm_counter_list_1}    ${value}
    Set Suite Variable    @{pm_counter_list_1}

Start already existing Egate and Edaemon Process
    ${BSR_TEST_FLAG}=    Run Keyword And Return Status    Variable Should Exist    ${BSR_TEST_DATA}
    Set Suite Variable    ${BSR_TEST_FLAG}
    Run Keyword If    '${BSR_TEST_FLAG}' == 'True'    Check If BSR Package exists
    ute_wtssim.Setup Egate    egate_port=${wts_sim_egate_port}    tool_dir=${WTS_DIR}    save_egate=True
    ute_wtssim.Setup Edaemon    edaemon_port=${wts_sim_edaemon_port}
    ute_wtssim.Link Edaemons To Egate    default
    Run Keyword If    '${SYSLOG}' == 'True'    Wait until keyword succeeds    3min    1min    Start PET syslog Service
    ${lock_test}=    Run Keyword And Return Status    Variable Should Exist    ${LOCK_TEST}
    Set Suite Variable    ${lock_test}
    Run Keyword If    '${lock_test}' != 'True'    Run Keyword And Ignore Error    Enable SIM RFM Logging

Mark end of Test case
    ute_wtssim.Execute Egate Command
        ...    script file\=/opt/wts/latest/commands.lua entry\=print_tc_end(${test_label})
        ...    timeout=100

Calculate Traffic Time For PET SE
    [Documentation]    Buffer Value is made as 0 for all VTM Test cases
    ...    This change has to be reverted once the PET SET fix is given for sim_var_echo
    ...    Author : Anjana
    ...    Modified date: 04/04/2025
    ${buffer}=    Evaluate    (${TRF_DURATION}*0.3)
    ${zero_buffer}=    Get Variable Value    ${NO_BUFFER}    False
    ${buffer}=    Run Keyword If    '${zero_buffer}' == 'True'    Set Variable    0
    ...    ELSE    Set Variable    ${buffer}
    ${REG_TIME}=    Get Variable Value    ${REG_TIME}    0
    ${traffic}=    Evaluate    (${TRF_DURATION}+${REG_TIME}+${buffer})
    ${timer}=    Evaluate    (${traffic}*60)
    Set Suite Variable    ${timer}

Start WTS and Check Cell Setup
    Start WTS
    Run Keyword If    '${NEW_CFG_FORMAT}' == 'True'    Copy New PET SE files
    ...    ELSE    Copy SE files    ${LUA_FILE}
    Run Keyword If    '${SYSLOG}' == 'True'    Wait until keyword succeeds    3min    1min    Start PET syslog Service
    Run Keyword If    '${NEW_CFG_FORMAT}' == 'True'    Check NgLink and Cell Setup With New Lua Format
    ...    ELSE    Check NgLink and Cell Setup
    ${lock_test}=    Run Keyword And Return Status    Variable Should Exist    ${LOCK_TEST}
    Set Suite Variable    ${lock_test}
    Run Keyword If    '${lock_test}' != 'True'    Run Keyword And Ignore Error    Enable SIM RFM Logging

Deregister PET_SE
    [Timeout]    33 minutes
    ${seq_stop}=    Get Variable Value    ${ENABLE_SEQ_STOP}    ${DEREGISTER_SEQ_STOP}
    Run Keyword If    '${TEST STATUS}' == 'FAIL' or '${seq_stop}' == 'True'
    ...    ute_wtssim.Execute Egate Command    seq_stop rate\=5 id\=all
    ...    ELSE    Deregister via PET SE

Deregister via PET SE
    ${status}=    Run Keyword And Return Status    Run Keyword and Continue on Failure
    ...    Wait Until Keyword Succeeds    30min    1min
    ...    Active UE Count To Zero Check
    Run Keyword If    '${status}' != 'True'    Deregister and Mark TC as Failed

Deregister and Mark TC as Failed
    PET Deregister
    Set Suite Variable    ${DEREGISTER_FLAG}    FAIL

Reset All and Start WTS
    Reset AP gNB and Check Ready State
    Start WTS and Check Cell Setup

Calculate Traffic Time For PET SE MVP
    Calculate Traffic Time For PET SE
    Calculate Sansa Lua delays
    ${commands_timers}=    Create List
    FOR    ${index}    IN    @{seq_stat_list}
        ${timer_calculated}=    Evaluate    int(${timer}*${index})
        Append To List    ${commands_timers}    ${timer_calculated}
    END
    Log To Console    ${commands_timers}
    Set Suite Variable    @{commands_timers}
        ${timers}=    Create List
    ${timers}=    Combine Lists    ${sansa_timers}    ${commands_timers}
    Set Suite variable    @{timers}
    Log To Console    ${timers}
    FOR    ${i}    ${j}    IN ZIP    ${timer_key_list}    ${timers}
        Set To Dictionary    ${TIMER_DATA}    ${i}=${j}
    END
    Fetch Dictionary items    ${TIMER_DATA}

Change lua upload command
    ${command}=    Set Variable
    ...    cfg_sim file=/opt/wts/latest/sansa.lua entry=run_configuration(${timer},${TIMER1},${TIMER2},${TIMER3})
    [Return]    ${command}

PET vRAN Setup
    Check if wts Directory Exists
    Run    pkill -f /opt/wts/latest/sosReport_ASIL/sosReport_ASIL.sh
    Run Keyword And Ignore Error    Check Rotta Directory
    Run Keyword And Ignore Error    Kill VNC BTS Logger tool
    Fetch Dynamic Ip Address for vCU and vDU
    Get AP Suite Configuration Variables
    Run Keyword And Ignore Error    Create Execution Logs Dir
    Run Keyword And Ignore Error    PyYaml and Taf config Install
    Run Keyword And Ignore Error    Modify Sosreport script for PET
    ${start_time}   Run Keyword And Ignore Error    Get Current DateTime
    Set Suite Variable    ${start_time}
    ${CUSTOM_CONFIGS}=    Get Environment Variable    CUSTOM_CONFIGS    None
    Set Suite Variable    ${CUSTOM_CONFIGS}
    ${TEST_CONFIGURATION}=    Get Environment Variable    AP_CONFIGURATION    None
    Set Suite Variable    ${TEST_CONFIGURATION}
    ${EM_TRACES}    Get Variable Value    ${COLLECT_EM_TRACES}    ${EM_TRACES}
    Set Suite Variable    ${EM_TRACES}
    ${EM_PERF_STATS}    Get Variable Value    ${COLLECT_EM_PERF_STATS}    ${EM_PERF_STATS}
    Set Suite Variable    ${EM_PERF_STATS}
    ${TOP_INTERFACE_STATS}    Get Variable Value    ${Collect_WTS_Stats}    ${TOP_INTERFACE_STATS}
    Set Suite Variable    ${TOP_INTERFACE_STATS}
    ${SYSLOG}    Get Variable Value    ${COLLECT_SYSLOG}    ${SYSLOG}
    Set Suite Variable    ${SYSLOG}
    ${IQ_LOG_ENABLE}    Get Variable Value    ${IQ_LOG_CAPTURE}    ${IQ_LOG_ENABLE}
    Set Suite Variable    ${IQ_LOG_ENABLE}
    ${AP_TOP_INTERFACE_STATS}    Get Variable Value    ${AP_TOP_STATS}    ${AP_TOP}
    Set Suite Variable    ${AP_TOP_INTERFACE_STATS}
    ${WTS_SCTP_STATS}    Get Variable Value    ${WTS_STATS}    ${WTS_SCTP}
    Set Suite Variable    ${WTS_SCTP_STATS}
    ${AP_SCTP_STATS}    Get Variable Value    ${AP_STATS}    ${AP_SCTP}
    Set Suite Variable    ${AP_SCTP_STATS}
    ${WTS_WIRESHARK}    Get Variable Value    ${WTS_PCAP_WIRESHARK}    ${WTS_PCAP}
    Set Suite Variable    ${WTS_WIRESHARK}
    ${SCF_STATUS}    Get Variable Value    ${SCF_VALIDATION_STATUS}    ${SCF_VALIDATION}
    Set Suite Variable    ${SCF_STATUS}
    ${PET_DICHOTOMY}    Get Variable Value    ${DICHOTOMY}    False
    Set Suite Variable    ${PET_DICHOTOMY}
    Run Keyword and Ignore Error    Run    sudo umount ${ROTTA_SERVER}
    Run Keyword and Ignore Error    Run    sudo umount ${ROTTA_SERVER_NEW}
    Run Keyword If    '${AP_TOP_INTERFACE_STATS}' == 'True'
    ...    Run Keyword And Ignore Error    Start AP Top output Collection
    Run Keyword If    '${WTS_WIRESHARK}' == 'True'
    ...    Run Keyword And Ignore Error    Start WTS WireShark
    ${RETRY_TC}=    Get Variable Value    ${RESET_ALL}    ${RETRY_TEST}
    Set Suite Variable    ${RETRY_TC}
    Collect SosReport Parallel    ${Start_sos_ASIL}

PET vRAN Teardown
    ute_wtssim.Execute Egate Command    sim_param_set disable_events_on_telnet_session\=off
    Collect SosReport Parallel    ${Stop_sos_ASIL}
    Run Keyword and Ignore Error    Collect wts cores logs for PET
    Run Keyword and Ignore Error    Get Counter XML Files for vRAN
    Run Keyword and Ignore Error    Sos Report Collection for PET vRAN
    Run Keyword and Ignore Error    Collection of DU and CU Snapshots for vRAN
    Run Keyword and Ignore Error    Set WTS Default Log Level to Error Level
    Run Keyword and Ignore Error    Stop and Collect WTS Interface Stats
    Run Keyword and Ignore Error    Stop Collecting WTS VM Statistics
    Run Keyword and Ignore Error    Copy PET SE files from WTS to logs
    Run Keyword and Ignore Error    Copy Config Files
    Run Keyword and Ignore Error    Conditional Logging Check for log Collection
    Run Keyword and Ignore Error    Copy PET SE files from WTS to logs
    Run Keyword and Ignore Error    Copy Config Files
    Run Keyword and Ignore Error    Counters Directory Cleanup
    Run Keyword And Ignore Error    Check Rotta Directory
    Run Keyword And Ignore Error    Copy vRAN custom Configs to Exec logs
    Wait Until Keyword Succeeds    15min    30s    Check For Sosreport
    ${log_status}=    Run Keyword And Return Status    File Should Exist    ${vm_logdir}/SosReport*.tgz
    Run Keyword If    '${log_status}' == 'False'    Run    mv /opt/wts/latest/SosReport*.tgz ${vm_logdir}/
    Run    pkill -f /opt/wts/latest/sosReport_ASIL/sosReport_ASIL.sh
    Run Keyword and Ignore Error    Move logs to Execution Directory

Common Register and Traffic vRAN
    [Arguments]    ${dictionary_name}    ${tag_name}
    ${NEW_CFG_FORMAT}=    Run Keyword And Return Status    Variable Should Exist    ${New_Config}
    Set Suite Variable    ${NEW_CFG_FORMAT}
    ${calculate_kpi}=    Get Variable Value    ${KPI_CALCULATION}    ${kpi_calc_display}
    Set Suite Variable    ${calculate_kpi}
    Run Keyword If    '${calculate_kpi}' == 'True'
    ...    Create KPI Type List
    Set Suite Variable    ${test_label}    ${tag_name}
    ${ue_stats_var_exist}=    Run Keyword And Return Status    Variable Should Exist    ${UE_STATS_NR_LIMIT}
    Set Suite Variable    ${ue_stats_var_exist}
    Fetch Dictionary items    ${dictionary_name}
    Calculate Traffic Time For PET SE
    Copy SE files    ${LUA_FILE}
    Run Keyword If    '${TOP_INTERFACE_STATS}' == 'True'    Run Keyword And Ignore Error    Collect Top and Interface stats
    Run Keyword If    '${AP_SCTP_STATS}' == 'True'    Start AP sctp stats collection
    Run Keyword If    '${WTS_SCTP_STATS}' == 'True'    Start wts sctp stats collection
    ${retry_tag}=    Run Keyword And Return Status    Environment Variable Should Be Set    RETRY_COUNT_TAG
    ${retry_tag_count}=    Run Keyword If    '${retry_tag}' == 'True'    Get Environment Variable    RETRY_COUNT_TAG
    ...    ELSE    Set Variable    0
    Run Keyword If    '${test_label}' in "@{WTS_RESET_BYPASS}" and '${RETRY_TC}' == 'False' and '${retry_tag_count}' == '0'
    ...    Start already existing Egate and Edaemon Process
    ...    ELSE    PET vRAN initial Setup
    ${ALL_TOP_STATS}=    Get Variable Value    ${ALL_TOP_STATS}   ${WTS_TOP_STATS}
    ${AMF_STATS}=    Get Variable Value    ${SIM_AMF_STATS}   ${AMF_TOP}
    ${UPF_STATS}=    Get Variable Value    ${SIM_UPF_STATS}   ${UPF_TOP}
    ${UEC_STATS}=    Get Variable Value    ${SIM_UEC_STATS}   ${UEC_TOP}
    ${ENB_STATS}=    Get Variable Value    ${SIM_ENB_STATS}   ${ENB_TOP}
    ${EGATE_TOP_STATS}=    Get Variable Value    ${EGATE_STATS}   ${EGATE_TOP}
    ${L3_TOP_STATS}=    Get Variable Value    ${L3_STATS}   ${L3_TOP}
    ${ALL_AP_STATS}=    Get Variable Value    ${ALL_WTS_TOP_STATS}   ${AP_ALL_TOP}
    Run Keyword If    '${ALL_TOP_STATS}' == 'True'    Start Top Stats of All components
    Run Keyword If    '${AMF_STATS}' == 'True'    Start AMF Top Stats of All components
    Run Keyword If    '${UPF_STATS}' == 'True'    Start UPF Top Stats of All components
    Run Keyword If    '${UEC_STATS}' == 'True'    Start UEC Top Stats of All components
    Run Keyword If    '${ENB_STATS}' == 'True'    Start ENB Top Stats of All components
    Run Keyword If    '${EGATE_TOP_STATS}' == 'True'    Start EGATE Top Stats of All components
    Run Keyword If    '${L3_TOP_STATS}' == 'True'    Start L3 Top Stats of All components
    Run Keyword If    '${ALL_AP_STATS}' == 'True'    Start All Top Stats of All components
    Run Keyword If    '${IQ_LOG_ENABLE}' == 'True'    Start Collecting IQ Traces
    Run Keyword If    '${AP_SCTP_STATS}' == 'True'    Start AP sctp stats collection
    Run Keyword If    '${WTS_SCTP_STATS}' == 'True'    Start wts sctp stats collection
    ${TCP_TRF_STATS}=    Run Keyword And Return Status    Variable Should Exist    ${TCP_TRF_STATS}
    Set Suite Variable    ${TCP_TRF_STATS}
    Run Keyword If    '${TCP_TRF_STATS}' == 'True'    Start TCP Traces log collection
    ute_wtssim.Execute Egate Command    sim_param_set disable_events_on_telnet_session\=on
    ${no_register}=    Get Variable Value    ${NO_REG}    None
    Run Keyword If    '${no_register}' != 'True'    Initiate UE Register And Traffic

PET vRAN initial Setup
    Start WTS
    ${wts_lua_command}=    Set Variable    cfg_sim file=/opt/wts/latest/sansa.lua entry=run_configuration(${timer})
    ute_wtssim.Execute Egate Command    ${wts_lua_command}    timeout=10minutes
    Wait Until Keyword Succeeds    15min    30s    Check Occurances from Egate Console    ${simmode_active}    1
    Sleep    10m
    Check Cells Setup
    Sleep    15s
    Check SIB Messages    ${NO_OF_CELLS}
    Sleep    30s

Fetch Counter Value from vRAN vCU
    [Arguments]    ${gNB_counter}
    coam_cu.connect_to    host=${vcu_host}    port=${vran_port}    username=Nemuadmin
    ...    password=${vdu_password}    secure=True
    ${status}    ${result}=    Run Keyword And Ignore Error    coam_cu.get_counter_objects    counter_id=${gNB_counter}
    Run Keyword If    '${status}' == 'FAIL'
    ...    Fail    Counter '${gNB_counter}' is not available in vCU.
    ${result_list}=    Run Keyword If    '${status}' == 'PASS'
    ...    Evaluate    list(${result}) if isinstance(${result}, list) else eval(${result})
    ...    ELSE    Set Variable    []
    ${total_counter_value}    Set Variable    0
    FOR    ${counter_dist_name}    IN    @{result_list}
        ${counter_dist_name}    Convert To String    ${counter_dist_name}
        ${return}    coam_cu.get_counter    measurement_id=${vran_measurement_id}    counter_id=${gNB_counter}
        ...    dimension_dist_name=${counter_dist_name}
        ${value}=    Get From Dictionary    ${return}    values
        ${counter_value}=   Get From Dictionary    ${value}[-1]    value
        ${total_counter_value}    Evaluate    ${total_counter_value} + ${counter_value}
    END
    coam_cu.disconnect
    [Return]    ${total_counter_value}

Pairing Success Ratio Calculation
    ${mimo1}=    Set Variable    ${pm_counter_list[${mimo1_pos}]}
    ${mimo2}=    Set Variable    ${pm_counter_list[${mimo2_pos}]}
    ${mimo3}=    Set Variable    ${pm_counter_list[${mimo3_pos}]}
    ${mimo4}=    Set Variable    ${pm_counter_list[${mimo4_pos}]}
    ${mimo5}=    Set Variable    ${pm_counter_list[${mimo5_pos}]}

    ${mimo_val1}=    Evaluate    1*${mimo1}
    ${mimo_val2}=    Evaluate    2*(${mimo2}+${mimo3})
    ${mimo_val3}=    Evaluate    3*${mimo4}
    ${mimo_val4}=    Evaluate    4*${mimo5}

    ${mimo_evaluted_sum}=    Evaluate    (${mimo_val1}+${mimo_val2}+${mimo_val3}+${mimo_val4})
    ${total_mimo_values}=    Evaluate    (${mimo1}+${mimo2}+${mimo3}+${mimo4}+${mimo5})
    ${achieved_success_ratio}=    Evaluate    ${mimo_evaluted_sum}/${total_mimo_values}
    ${pairing_success_ratio}=    Evaluate    "%.2f" % ${achieved_success_ratio}
    Log To Console    Pairing Success Ratio: ${pairing_success_ratio}
    Set Suite Variable    ${pairing_success_ratio}
    ${pariring_ratio}=    Evaluate    (${EXPECTED_PAIRING_SUCESS_RATIO}*${PAIRING_RATIO_PERCENTAGE})
    ${pairing_status}=    Run Keyword If    ${pairing_success_ratio} < ${pariring_ratio}
    ...    Set Variable    FAIL    ELSE    Set Variable    True
    Set Suite Variable    ${pairing_status}
    Append To List    ${test_verdict}   ${pairing_status}
    Set List Value    ${pm_counter_list}    4    ${pairing_success_ratio}

Validate UL TX values
   [Arguments]    ${TYPE}
   ${counter_value}=    Set Variable    ${pm_counter_list[${TX_COUNT_${TYPE}_Pos}]}
   ${actual_value}=    Evaluate    ${counter_value}/300
   ${ue_data}=    Set Variable    "Achived_UL_TX_${TYPE}_value":"${actual_value}/${EXPECTED_${TYPE}_TX_COUNT}"
   Log To Console    ${ue_data}
   ${value_check}=    Evaluate    (${actual_value} == ${EXPECTED_${TYPE}_TX_COUNT})
   ${ue_status}=    Run Keyword If    '${value_check}' == 'True'    Set Variable    True
    ...    ELSE    Set Variable    FAIL
    Set Suite Variable    ${ue_status}
    Append To List    ${test_verdict}   ${ue_status}

RLC Tdd Fdd Counter Validation
    [Arguments]    ${dir}
    ${value_cell2}=    Run Keyword If    '${dir}' == 'PDCP_UL'
    ...    Conversion of bits to Mbps    ${pm_counter_list[${UL_RLC_2_pos}]}
    Set List Value    ${pm_counter_list}    2    ${value_cell2}
    ${ue_data}=    Set Variable    "Achieved TPUT for Cell 2":"${value_cell2}/${EXPECTED_RANGE_CELL2}"
    Log To Console    ${ue_data}
    ${cell2_status}=    Run Keyword If    ${value_cell2} >= ${CELL_2_FDD_RLC_TPUT_MIN} and ${value_cell2} <= ${CELL_2_FDD_RLC_TPUT_MAX}
    ...    Set Variable    True
    ...    ELSE    Set Variable    FAIL
    Set Suite Variable    ${cell2_status}
    Append To List    ${test_verdict}   ${cell2_status}
    ${value_cell3}=    Run Keyword If    '${dir}' == 'PDCP_UL'
    ...    Conversion of bits to Mbps    ${pm_counter_list[${UL_RLC_3_pos}]}
    Set List Value    ${pm_counter_list}    3    ${value_cell3}
    ${achived_expected_UL_Value}=      Evaluate    (${EXPECTED_TPUT_CELL3}*${pairing_success_ratio}/4)
    ${EXPECTED_TPUT_UL_Value}=    Evaluate    "%.2f" % ${achived_expected_UL_Value}
    Log To Console    Calculated Expected TPUT for Cell 3: ${EXPECTED_TPUT_UL_Value}Mbps
    Set Suite Variable    ${EXPECTED_TPUT_UL_Value}
    Set List Value   ${expected_values}    3    ${EXPECTED_TPUT_UL_Value}
    ${tput_data}=    Set Variable    "Achieved TPUT for Cell 3":"${value_cell3}/${EXPECTED_TPUT_UL_Value}"
    Log To Console    ${tput_data}
    ${threshold_value_cell3}=    Evaluate    ${EXPECTED_TPUT_UL_Value}*${MUE_Tput_Limit}
    ${cell3_status}=    Run Keyword If    ${value_cell3} > ${threshold_value_cell3}
    ...    Set Variable    True
    ...    ELSE    Set Variable    FAIL
    Set Suite Variable    ${cell3_status}
    Append To List    ${test_verdict}   ${cell3_status}

Fetch Counter value without Index value
    [Arguments]    ${counter_list}
    FOR    ${ip}    ${folder}    IN ZIP    ${gNB_IP_list}    ${pmcouter_folder}
        Wait Until Keyword Succeeds    ${COUNTER_DURATION}min    ${COUNTER_RETRY_DURATION}min
        ...    Fetch Counter Value from GNB BTS    ${folder}    ${ip}
    END
    Run Keyword If    '${test_label}' not in "@{VTM_MVP_TAGS}" and '${test_label}' not in "@{VTM_TAGS}"
    ...    Detach String Check during Traffic    ${detach_string}
    FOR    ${counter}    IN    @{counter_list}
        Calling XML counter fetch    ${counter}
    END
    FOR    ${i}    IN RANGE    1    ${GNB_COUNT}+1    1
        Append To List    ${pmcouter_list_folder}    ${pm_counter_list_${i}}
    END

Calling XML counter fetch
    [Arguments]    ${counter}
    FOR    ${id}    ${folder}    IN ZIP    ${GNB_COUNT_LIST}    ${pmcouter_folder}
        ${value}=    Fetch counter value from XML file    ${counter}    ${folder}
        Run Keyword If    '${counter}' == 'M55125C09530' or '${counter}' == 'M55138C00033'
        ...    Combine List to one List    ${value}
        ...    ELSE    Append To List    ${pm_counter_list_${id}}    ${value[0]}
        Set Suite Variable    ${pm_counter_list_${id}}
    END

Fetch Counter value with Index value
    [Arguments]    ${counter_list}    ${counter_index_data}
    FOR    ${ip}    ${folder}    IN ZIP    ${gNB_IP_list}    ${pmcouter_folder}
        Wait Until Keyword Succeeds    ${COUNTER_DURATION}min    ${COUNTER_RETRY_DURATION}min
        ...    Fetch Counter Value from GNB BTS    ${folder}    ${ip}
    END
    Run Keyword If    '${test_label}' not in "@{VTM_MVP_TAGS}" and '${test_label}' not in "@{VTM_TAGS}"
    ...    Detach String Check during Traffic    ${detach_string}
    FOR    ${index}    ${pos}    IN ZIP    ${counter_list}    ${counter_index_data}
        ${value}=    Fetch counter value from XML file    ${index}
        Append To List    ${pm_counter_list_1}    ${value[${pos}]}
    END

Intermediate PET Traffic Validation with range
    [Arguments]    ${dir}    ${tput}
    ${min_tput_threshold}=    Evaluate    int(${CELL_2_FDD_RLC_TPUT_MIN}+${EXPECTED_TPUT_UL_Value})
    ${max_tput_threshold}=    Evaluate    int(${CELL_2_FDD_RLC_TPUT_MAX}+${EXPECTED_TPUT_UL_Value})
    ${tput_status}=    Set Variable If    '${tput}' < '${min_tput_threshold}'    False
    ...    '${tput}' > '${max_tput_threshold}'    False
    ...    True
    ${tput_data}=    Set Variable    "${dir}_RATE(Mbps)":"${tput}/${min_tput_threshold}-${max_tput_threshold}"
    Log To Console    ${tput_data}
    Set Suite Variable    ${EXPECTED_PDCP_UL_RANGE}    ${min_tput_threshold}-${max_tput_threshold}
    Set List Value    ${expected_values}    1    ${EXPECTED_PDCP_UL_RANGE}
    ${status}    Run Keyword And Ignore Error    Should Be True    '${tput_status}' == 'True'
    ...    msg=Traffic failed in Throughput, see error above!
    Append To List    ${test_verdict}    ${status[0]}

Conversion of bits to Mbps
    [Arguments]    ${bits}
    ${achieved_tput}=    Evaluate    ((${bits}*8)/300000000)
    ${achieved_tput}=    Evaluate    "%.2f" % ${achieved_tput}
    [Return]    ${achieved_tput}

Check If BSR Package exists
    ${packages}=    Split String    ${BSR_TEST_DATA}    ,
    ${pack_length}=    Get Length    ${packages}
    ${bsr_status_list}=    Create List
    Set Suite Variable    ${bsr_status_list}
    ${active_bsr}    Get BSR File
    FOR    ${file}    IN    @{packages}
        Check If File Exists In BSR Dictionary    ${active_bsr}    ${file}
        Append To List    ${bsr_status_list}    ${file_found}
    END
    ${BSR_FILE_STATUS}    Run Keyword And Return Status
    ...    Should Contain X Times    ${bsr_status_list}    True    ${pack_length}
    ${BSR_FILE_STATUS}=    Run Keyword If    '${BSR_FILE_STATUS}' == 'True'    Set Variable    True
    ...    ELSE    Set Variable    False
    [Teardown]    CoamAdmin.Teardown
    [Return]    ${BSR_FILE_STATUS}

Calculate KPI of NG
    [Arguments]    ${RATE2}    ${RATE3}
    ${vtm_data_list}=    Create List
    Set Suite Variable    @{vtm_data_list}
    ${test_verdict}=    Create List
    Set Suite Variable    @{test_verdict}
    ${NG_DL}=    Evaluate    "%.2f" % ((8*${RATE2})/(1000))
    ${ng_dl_data}=    Set Variable    "NG-U_DL":"${NG_DL}"
    ${NG_UL}=    Evaluate    "%.2f" % ((8*${RATE3})/(1000))
    ${ng_ul_data}=    Set Variable    "NG-U_UL":"${NG_UL}"
    Run Keywords    Set Suite Variable    ${NG_DL}    AND    Set Suite Variable    ${NG_UL}
    Log To Console    KPI-NR_1249-DL at NG-U:${NG_DL}
    Log To Console    KPI-NR_1250-UL at NG-U:${NG_UL}
    Append To List    ${vtm_data_list}    ${NG_DL}
    Append To List    ${vtm_data_list}    ${NG_UL}

Calculate KPI of PDCP
    [Arguments]    ${RATE4}    ${RATE5}
    ${PDCP_DL}=    Evaluate    "%.2f" % ((8*${RATE4})/(1000))
    ${PDCP_UL}=    Evaluate    "%.2f" % ((8*${RATE5})/(1000))
    ${pdcp_dl_data}=    Set Variable    "PDCP_DL":"${PDCP_DL}"
    ${pdcp_ul_data}=    Set Variable    "PDCP_UL":"${PDCP_UL}"
    Append To List    ${vtm_data_list}    ${PDCP_DL}
    Append To List    ${vtm_data_list}    ${PDCP_UL}
    Set Suite Variable    ${PDCP_DL}
    Set Suite Variable    ${PDCP_UL}
    Log To Console    KPI-NR_5094a-DL at PDCP:${PDCP_DL}
    Log To Console    KPI-NR_5095a-UL at PDCP:${PDCP_UL}
    ${final_dl}=    Evaluate    (${NG_DL}*0.95)
    ${final_ul}=    Evaluate    (${NG_UL}*0.95)
    ${pdcp_final_dl}=    Run Keyword If    '${PDCP_DL}' >= '${final_dl}'    Set Variable    True
    ${pdcp_final_ul}=    Run Keyword If    '${PDCP_UL}' >= '${final_ul}'    Set Variable    True
    ${pdcp_dl_status}=    Run Keyword And Ignore Error    Should Be True    ${pdcp_final_dl}
    ...    msg=PDCP Tput less than expected
    ${pdcp_ul_status}=    Run Keyword And Ignore Error    Should Be True    ${pdcp_final_ul}
    ...    msg=PDCP Tput less than expected
    Append To List    ${test_verdict}    ${pdcp_dl_status}    ${pdcp_ul_status}

Validate Kpi
    [Arguments]    ${tc_name}    ${MAIL_DATA}
    ${kpi_list_updated}=    Get Slice From List    ${kpi_list}    1    -1
    Set Suite Variable    ${kpi_list_updated}
    ${kpi_interval}=    Get Length    ${kpi_list_updated}
    Set Suite Variable    ${kpi_interval}
    ${Achieved_Kpi}=    Run Keyword If    '${kpi_interval}' == '0'    Set Variable    -
    ...    ELSE    Calculate Achieved Event
    Set Suite Variable    ${Achieved_Kpi}
    Set Achieved Event    ${tc_name}    ${MAIL_DATA}

Calculate Achieved Event
    ${Achieved_Kpi}=    Evaluate    "%.2f" % (sum(${kpi_list_updated})/${kpi_interval})
    ${Achieved_Kpi}=    Run Keyword If    '${Achieved_Kpi}' == 'None'    Set Variable    -
    ...    ELSE    Set Variable    ${Achieved_Kpi}
    [Return]    ${Achieved_Kpi}

Set Achieved Event
    [Arguments]    ${tc_name}    ${MAIL_DATA}
    Log To Console    Achieved Events per Second : ${Achieved_Kpi}
    ${Kpi_Status}=    Evaluate    (${Achieved_Kpi}) >= (${expected_rate}*${event_threshold})
    ${Kpi_Status}=    Set Variable If    '${Kpi_Status}' == 'True'    PASS
    ...    FAIL
    Run Keyword If    '${test_label}' != 'VTM_MVP_MP' and '${test_label}' != 'Dual_Boost_VTM' and '${test_label}' != 'TDD_SA_VTM_TCP'
    ...    Insert Into List    ${vtm_data_list}    0    ${Achieved_Kpi}
    Setting up to dictionary    ${vtm_data_list}    ${MAIL_DATA}
    Append To List    ${test_verdict}    ${Kpi_Status}
    Append To File    ${test_property_file}
    ...    ${\n}${tc_name}_TEST_RESULTS={"s1-t1":${json_mail_data}}${\n}

Update testproperties VTM
    [Arguments]    ${tc_name}    ${MAIL_DATA}
    Append To List    ${vtm_data_list}    ${Achieved_Kpi}
    Setting up to dictionary    ${vtm_data_list}    ${MAIL_DATA}
    Deregister and Append Data    ${tc_name}
    Append To File    ${test_property_file}
    ...    ${\n}${tc_name}_TEST_RESULTS={"s1-t1":${json_mail_data}}${\n}
    List Should Not Contain Value    ${test_verdict}    FAIL    msg=TestCase Failed, Validation Criteria not met!

Validate Kpi and Deregister
    [Arguments]    ${tc_name}    ${MAIL_DATA}
    Validate Kpi    ${tc_name}    ${MAIL_DATA}
    Deregister and Append Data    ${tc_name}
    List Should Not Contain Value    ${test_verdict}    FAIL    msg=TestCase Failed, Validation Criteria not met!

Check if wts Directory Exists
    Run    bash -c "test -d ${WTS_DIR}"
    ${return_code}    Run And Return Rc    bash -c "test -d ${WTS_DIR}"
    Run Keyword If    ${return_code} != 0    Fail    Directory ${WTS_DIR} does not exist

Fetch Dynamic Ip Address for vCU and vDU
    ${hostname}=    Get Hostname Details for Perf
    ${INIT_FILE_PATH}=    Catenate    ${testline_results_paths}/${hostname}/__init__.py
    Run    sudo chmod 777 ${FETCH_VRAN_IP}
    Run    sudo chmod 777 ${INIT_FILE_PATH}
    ${command}=    Catenate    python    ${FETCH_VRAN_IP}    ${INIT_FILE_PATH}
    ${output}=    Run Process    ${command}    stdout=STRING    stderr=STRING    shell=True
    @{lines}=    Split String    ${output.stdout}    \n
    FOR    ${line}    IN    @{lines}
        ${key_value}=    Split String    ${line}    =
        Run Keyword If    '${key_value[0]}' == 'vCUip'    Set Suite Variable    ${vcu_host}    ${key_value[1]}
        Run Keyword If    '${key_value[0]}' == 'vDUip'    Set Suite Variable    ${vdu_host}    ${key_value[1]}
    END

Calculate Traffic Time For PET SE VTM
    Calculate Traffic Time For PET SE
    Run Keyword If    '${test_label}' != 'VTM_FAKE_PAGING' and '${test_label}' != 'VTM_FAKE_PAGING_MP'
    ...    Calculate Delays and Set Timers

Calculate Delays and Set Timers
    ${sansa_lua_delays}=    Create List
    Set Suite Variable    @{sansa_lua_delays}
    Append To List    ${sansa_lua_delays}    ${INTRA_INTER_DELAY_1}    ${INTRA_INTER_DELAY_2}    ${SCELL_DELAY}
    ...    ${PAGING_DELAY}    ${UE_STATE_TRANS_DELAY}    ${UE_STATE_CA_TRANS_DELAY}
    ${sansa_timers}=    Create List
    FOR    ${index}    IN    @{sansa_lua_delays}
        ${timer_calculated}=    Evaluate    int(${timer}/${index})
        Append To List    ${sansa_timers}    ${timer_calculated}
    END
    Set Suite Variable    @{sansa_timers}
    ${TIMER_DATA}=    Create Dictionary    TIMER1=0    TIMER2=0    TIMER3=0    TIMER4=0    TIMER5=0    TIMER6=0
    Set Suite Variable    &{TIMER_DATA}
    Fetch Dictionary items    ${TIMER_DATA}
    ${timer_key_list}=    Get Dictionary Keys    ${TIMER_DATA}    sort_keys=False
    Set Suite Variable    @{timer_key_list}
    FOR    ${i}    ${j}    IN ZIP    ${timer_key_list}    ${sansa_timers}
        Set To Dictionary    ${TIMER_DATA}    ${i}=${j}
    END
    Fetch Dictionary items    ${TIMER_DATA}

Change lua upload command for VTM
    ${command}=    Set Variable If    '${test_label}' != 'VTM_FAKE_PAGING' and '${test_label}' != 'VTM_FAKE_PAGING_MP'
    ...    cfg_sim file=/opt/wts/latest/sansa.lua entry=run_configuration(${TIMER1},${TIMER2},${TIMER3},${TIMER4},${TIMER5},${TIMER6})
    ...    cfg_sim file=/opt/wts/latest/sansa.lua entry=run_configuration(${timer})
    [Return]    ${command}

Check Process Status
    FOR    ${index}    IN    @{sim_process}
        Exit For Loop If    '${SIM_MME_CHECK}' == 'False' and '${index}' == 'sim_mme'
        ${pi}=    Run    pidof ${index}
        Exit For Loop If    '${pi}' == '${EMPTY}'
    END
    Run Keyword If    '${pi}' == '${EMPTY}'    Reset All and Start WTS
    ...    ELSE    Start already existing Egate and Edaemon Process

Perform Lock Unlock cell
    [Arguments]    ${index}
    FOR    ${cell_id}    IN    @{cell_list}
        Lock unlock cells    ${cell_id}    ${index}
        Check Alarms    ${before_op_dict}    ${after_op_dict}
        Run Keyword And Ignore Error    SIB check with UECs    ${cell_id}    ${index}
    END

Lock unlock cells
    [Arguments]    ${cell_id}    ${index}
    Wait Until Keyword Succeeds    5min    30sec    CoamAdmin.Connect To    bts_host=${GNB_ASIK.Ip}
    Get Active gNB Alarms    ${before_op_dict}
    CoamAdmin.block_cell    dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_id}    detailed_output=True
    Log To Console    Iteration ${index}:Locking cell ${cell_id}
    Sleep    30s
    CoamAdmin.unblock_cell    dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_id}    detailed_output=True
    Log To Console    Iteration ${index}:Unlocking cell ${cell_id}
    Get Active gNB Alarms    ${after_op_dict}
    Sleep    30s
    CoamAdmin.Teardown

SIB check with UECs
    [Arguments]    ${cell_id}    ${index}
    ${command}=    Set Variable    ib_enb_cell_disp enb=\2 cell\=${cell_id}
    ${output}=    ute_wtssim.Execute Egate Command And Wait For Data    ${command}
    ...    timeout=${SIB_WAIT_TIME}
    ute_wtssim.Execute Egate Command    set_log flush
    ${sib_list}=    Create List
    Set Suite Variable    @{sib_list}
    FOR    ${i}    IN RANGE    1    ${NO_OF_CELLS}+1    1
        ${lines}=    Get Lines Containing String    ${output}    SIB${i}
        ${sib_status}=    Run Keyword And Return Status    Should Contain    ${lines}    yes
        Append To List    ${sib_list}    ${sib_status}
    END
    ${cell_verdict}=    Run Keyword And Return Status    List Should Not Contain Value    ${sib_list}    FAIL    msg=cell unblock failed
    ${cell_status}=    Set Variable If    '${cell_verdict}' == 'True'    PASS
    ...    FAIL
    Append To List    ${loop${index}}    CELL-${cell_id}:${cell_status}
    Append To List    ${cell_status_list}    ${cell_status}
    Log To Console    ${cell_status_list}

Unlock cells And Append Data
    [Arguments]    ${tc_name}
    FOR    ${i}    IN RANGE    1    ${LOOP_TIMES}+1    1
        ${list}=    Catenate    SEPARATOR=,    @{loop${i}}
        Run Keyword If    '${list}' != '${EMPTY}'    Set To Dictionary    ${MAIL_DATA}    Iter${i}=${list}
        ...    ELSE    Set To Dictionary    ${MAIL_DATA}    Iter${i}=SIBs Not received
    END
    Check Alarm List To Results    ${MAIL_DATA}
    ${json_mail_data}=    Evaluate   json.dumps(${MAIL_DATA})    json
    Append To File    ${test_property_file}
    ...    ${\n}${tc_name}_TEST_RESULTS={"s1-t1":${json_mail_data}}${\n}
    ${cell_stat}=    Checking State Of All Cells
    Run Keyword If    '${cell_stat}' == 'False'    Unblock All Cells
    Sleep    20s
    Should Be True    ${alarm_check_status}    msg=Active Alarms Present!
    List Should Not Contain Value    ${cell_status_list}    FAIL    msg=cell unblocked failed!

Checking State Of All Cells
    [Documentation]    This keyword checks whether cells are blocked or unblocked from GUI
    ...                Modified Date: 19-Mar-2024
    ...                Last Modified by: anil.1.pachauri@nokia.com
    ${cell_infor_lists}=    Create List
    Set Suite Variable    @{cell_infor_lists}
    Wait Until Keyword Succeeds    5min    30sec    CoamAdmin.Connect To    bts_host=${GNB_ASIK.Ip}
    ${cell_info}=    CoamAdmin.get_cells_info
    CoamAdmin.Teardown
    ${list_len}=    Get Length    ${cell_info}
    FOR    ${cell_id}   IN RANGE    ${list_len}
        ${cell_stat}=    Set Variable    ${cell_info[${cell_id}]['status']['blockingState']}
        Append To List    ${cell_infor_lists}    ${cell_stat}
    END
    ${end_cell_status}=    Run Keyword And Return Status    List Should Not Contain Value
    ...    ${cell_infor_lists}    Blocked    msg=cell unblocked failed!
    Run Keyword If    '${end_cell_status}' == 'False'    Unblock All Cells
    [Return]    ${end_cell_status}

Validate Kpi VTM MVP
    [Arguments]    ${tc_name}     ${MAIL_DATA}
    ${DL_TPUT}=    Validate Tput in VTM    ${dl_tput_list}    DL
    ${UL_TPUT}=    Validate Tput in VTM    ${ul_tput_list}    UL
    Setting up to dictionary    ${vtm_data_list}    ${MAIL_DATA}
    ${kpi_data}=    Calculate KPI Average    ${Avg_Kpi_Data}
    Log To Console    ${kpi_data}
    FOR    ${item}    IN    @{kpi_data}
        FOR    ${key}    ${value}    IN    &{item}
            Set To Dictionary    ${MAIL_DATA}    ${key}=${value}
        END
    END
    ${json_mail_data}=    Evaluate   json.dumps(${MAIL_DATA})    json
    Append To File    ${test_property_file}
    ...    ${\n}${tc_name}_TEST_RESULTS={"s1-t1":${json_mail_data}}${\n}
    Deregister and Append Data    ${tc_name}
    List Should Not Contain Value    ${test_verdict}    FAIL    msg=TestCase Failed, Validation Criteria not met!

Cell Wise Data Entry
    [Arguments]    ${cell_list}
    FOR    ${index}    IN    @{cell_list}
        ${cell_list_updated}=    Get Slice From List    ${index}    1    -1
        ${cell_interval}=    Get Length    ${cell_list_updated}
        ${Achieved_cell}=    Evaluate    (sum(${cell_list_updated})/${cell_interval})
        ${Achieved_cell}=    Run Keyword If    '${Achieved_cell}' == 'None'    Set Variable    -
        ...    ELSE    Set Variable    ${Achieved_cell}
        Append To List    ${vtm_data_list}    ${Achieved_cell}
        ${cell_status}=    Set Variable If    (${Achieved_cell} >= ${MIN_UE}) and (${Achieved_cell} <= ${MAX_UE})    PASS
        ...    FAIL
        Append To List    ${test_verdict}    ${cell_status}
    END

Calculate DL UL QoS
    [Arguments]    ${dl_list}
    ${pm_counter_list}=    Create List
    Set Suite Variable    @{pm_counter_list}
    Fetch Counter value without Index value    ${dl_list}
    ${qos_1}=    Evaluate    "%.2f" % ((${pm_counter_list[0]}*60*8)/(900*1000000))
    ${qos_2}=    Evaluate    "%.2f" % ((${pm_counter_list[1]}*1277*8)/(900*1000000))
    ${qos_3}=    Evaluate    "%.2f" % ((${pm_counter_list[2]}*1277*8)/(900*1000000))
    ${avg_qos}=    Evaluate    "%.2f" % ((${qos_1}+${qos_2}+${qos_3})*0.93)
    Log To Console    DL: ${avg_qos}
    ${qos_4}=    Evaluate    "%.2f" % ((${pm_counter_list[3]}*60*8)/(900*1000000))
    ${qos_5}=    Evaluate    "%.2f" % ((${pm_counter_list[4]}*355*8)/(900*1000000))
    ${qos_6}=    Evaluate    "%.2f" % ((${pm_counter_list[5]}*355*8)/(900*1000000))
    ${avg_qos}=    Evaluate    "%.2f" % (((${qos_4}+${qos_5}+${qos_6})*0.10)-5)
    Log To Console    UL: ${avg_qos}

Validate Tput in VTM
    [Arguments]    ${tput_list}    ${dir}
    ${list_updated}=    Get Slice From List    ${tput_list}    1    -1
    ${Achieved_tput}=    Evaluate    "%.2f" % (sum(map(float, ${list_updated})) / len(${list_updated}))
    ${Achieved_tput}=    Run Keyword If    '${Achieved_tput}' == 'None'    Set Variable    -
    ...    ELSE    Set Variable    ${Achieved_tput}
    Log To Console    Achieved ${dir} : ${Achieved_tput}
    Append To List    ${vtm_data_list}    ${Achieved_tput}
    [Return]    ${Achieved_tput}

Check sim_uec process if active
    ${pi}=    Run    pidof sim_uec
    Run Keyword If    '${pi}' == '${EMPTY}'    FAIL    msg=WTS Process Crashed!Terminating TC

Detach String Check during Traffic
    [Documentation]    Keyword Checks for detach string during traffic
    ...                PASS execution if its detach string is found
    ...                Modified Date: 21-May-2025
    [Arguments]    ${string_check}
    ute_wtssim.Execute Egate Command    set_log flush
    ${output}=    String Checker Python Method    ${string_check}
    Pass Execution If    '${output}' == 'True'    Detach Started During Counter validation

Append Kpi Data
    [Arguments]    ${MAIL_DATA}=${MAIL_DATA}
    FOR    ${i}    ${j}    IN ZIP    ${list_kpi}    ${kpi_result_list}
        Set To Dictionary    ${MAIL_DATA}    ${i}=${j}
    END

KPI Calculation and Validation
    ${command}=    KPI overall Calculation    ${KPI_LIST_MAPPING}    ${list_kpi}    ${pm_file}    ${COUNTER_DURATION}    ${EXECDIR}

Validate KPI Values FOR DSS VTM
    ${kpi_result_list}=    Create List
    Set Suite Variable    @{kpi_result_list}
    ${vtm_data_list}=    Create List
    Set Suite Variable    @{vtm_data_list}
    KPI Calculation and Validation
    ${Achieved_Kpi}=    Set Variable    ${kpi_result_list[${EVENT_KPI_Pos}]}
    Set Suite Variable    ${Achieved_Kpi}
    ${event_kpi_status}=    Evaluate    ${Achieved_Kpi} >= ${expected_rate}
    Should Be True    ${event_kpi_status}    msg=Event kpi is less than expected
    Append To List    ${vtm_data_list}    ${Achieved_Kpi}
    ${event_pdcp_dl_value}=    Set Variable    ${kpi_result_list[${event_pdcp_dl_Pos}]}
    ${event_pdcp_ul_value}=    Set Variable    ${kpi_result_list[${event_pdcp_ul_Pos}]}
    ${final_dl}=    Evaluate    (${OVERALL_PDCP_DL}*0.90)
    ${final_ul}=    Evaluate    (${OVERALL_PDCP_UL}*0.90)
    ${pdcp_final_dl}=    Run Keyword If    ${event_pdcp_dl_value} >= ${final_dl}    Set Variable    True
    Should Be True    ${pdcp_final_dl}    msg=PDCP DL Tput less than expected
    ${pdcp_final_ul}=    Run Keyword If    ${event_pdcp_ul_value} >= ${final_ul}    Set Variable    True
    Should Be True    ${pdcp_final_ul}    msg=PDCP UL Tput less than expected
    Append To List    ${vtm_data_list}    ${event_pdcp_dl_value}
    Append To List    ${vtm_data_list}    ${event_pdcp_ul_value}
    ${DL_BLER_value}=    Set Variable    ${kpi_result_list[${DL_BLER_Pos}]}
    ${DL_BLER_final}=    Run Keyword If    ${DL_BLER_value} <= ${OVERALL_DL_BLER}    Set Variable    True
    Should Be True    ${DL_BLER_final}    msg=BLER DL less than expected
    Append To List    ${vtm_data_list}    ${DL_BLER_value}
    ${UL_BLER_value}=    Set Variable    ${kpi_result_list[${UL_BLER_Pos}]}
    ${UL_BLER_final}=    Run Keyword If    ${UL_BLER_value} <= ${OVERALL_UL_BLER}    Set Variable    True
    Should Be True    ${UL_BLER_final}    msg=BLER UL less than expected
    Append To List    ${vtm_data_list}    ${UL_BLER_value}

Create KPI Type List
    ${kpi_result_list}=    Create List
    Set Suite Variable    @{kpi_result_list}
    ${kpi_var_exist}=    Run Keyword And Return Status    Variable Should Exist    ${KPI_TYPE_LIST}
    Set Suite Variable    ${kpi_var_exist}
    ${all_kpi_list}=    Run Keyword If    '${kpi_var_exist}' == 'True'
    ...    Set Variable    ${TC_KPIS},${KPI_TYPE_LIST}
    ...    ELSE    Set Variable    ${TC_KPIS}
    ${list_kpi}=    Split String    ${all_kpi_list}    ,
    Set Suite Variable    @{list_kpi}
    FOR    ${index}    IN    @{list_kpi}
        Set Suite Variable    @{${index}_list}    @{EMPTY}
    END
    ${Avg_Kpi_Data}=    Create List
    Set Suite Variable    @{Avg_Kpi_Data}

Counter Validation for Dichotomy
    FOR    ${counter}    IN    @{COUNTER_LIST}
        Run Keyword If    '${COUNTER_INPUT}' == '${counter}'
        ...    Store Failure Counter    ${COUNTER_INPUT}
    END

Store Failure Counter
    [Arguments]    ${failed_counter}
    Set Suite Variable    ${FAILURE_COUNTER}    ${failed_counter}
    Log To Console    Failure Counter: ${FAILURE_COUNTER}

Append Dichotomy Validation Status to Mail
   [Arguments]    ${final_test_property_data}
   ${LOAD_ID_AP}=    Get Environment Variable    LOAD_ID
   ${LOAD_ID_GNB}=    Get Environment Variable    GNB_LOAD_ID
   Set To Dictionary   ${final_test_property_data}    LOAD_ID=${LOAD_ID_AP}    GNB_LOAD_ID=${GNB_LOAD_ID}
   [Return]    ${final_test_property_data}

Check For Sosreport
    [Documentation]    Start the Sosreport at the beginning of the run.
    ...    during teardown we will wait until number of  sos reports are found in the path
    ...    Author: Anjana
    ...    Date Modified: 27/03/2025
    ${file_count}=    Run    find /opt/wts/latest/ -type f -name "SosReport*.tgz" | wc -l
    Should Not Be Equal As Integers    ${file_count}    0    msg=SosReport files not found in /opt/wts/latest/


Initialize Test Data
    [Arguments]    ${test_variable}    &{dict}
    [Documentation]    This keyword is used to extract values of counters, mail_data, and expected_values from dict.
    ...                It assigns values to lists and dictionaries and calls register and traffic-related keywords.
    ...                Modified Date: 26-March-2025
    ...                Last Modified by: kokila.b@nokia.com
    Traffic Duration Set
    Fetch Dictionary items    ${dict}
    ${COUNTER_LIST}=    Run Keyword If    '${test_variable}' in "@{large_lenght_tags}"    Set Variable    ${COUNTERS}
    ...    ELSE    Split String    ${COUNTERS}    ,
    Set Suite Variable    ${COUNTER_LIST}
    ${mail_keys}=    Run Keyword If    '${test_variable}' in "@{large_lenght_tags}"    Set Variable    ${MAIL_VALUE}
    ...    ELSE    Split String    ${MAIL_Value}    separator=,
    ${MAIL_DATA}=    Create Dictionary
    FOR    ${key}    IN    @{mail_keys}
        Set To Dictionary    ${MAIL_DATA}    ${key}=0
    END
    Set Suite Variable    &{MAIL_DATA}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    Set Suite Variable    @{keys_list}
    ${expected_data}=    Run Keyword If    '${test_variable}' == 'AXEGHA_CB013212'
    ...    Set Variable    ${EXPCTED_DATA_AXEGHA_CB013212}
    ...    ELSE IF   '${test_variable}' == 'SA_DCM_UL'
    ...    Set Variable    ${EXPCTED_SA_DCM_UL}
    ...    ELSE    Split String    ${expected_data}    separator=,
    ${expected_values}=    Create List
    FOR    ${key}    IN    @{expected_data}
        ${value}=    Get From Dictionary    ${dict}    ${key}
        Append To List    ${expected_values}    ${value}
    END
    Set Suite Variable    ${expected_values}
    ${SEQ_VALUE}=    Split String    ${SEQ_LIST}    ;
    ${stat_list} =    Create List
    FOR    ${item}    IN    @{SEQ_VALUE}
        ${seq_values_list}=    Split String    ${item}    ,
        Append To List    ${stat_list}    ${seq_values_list}
    END
    Set Suite Variable    ${stat_list}
    Run Keyword If    '${test_variable}' in "@{VRAN_TCs}"    Common Register and Traffic vRAN    ${dict}    ${test_variable}
    ...    ELSE    Common Register and Traffic    ${dict}    ${test_variable}
    ${PERCELL_VALIDATION}=    Run Keyword And Return Status    Variable Should Exist    ${PERCELL_COUNTERS}
    Run Keyword If    '${PERCELL_VALIDATION}' == 'True'    Validate Counter Values Per Cell    ${PERCELL_COUNTERS}
    ...    ${PERCELL_expected_data}    ${NO_OF_CELLS}
    Traffic Loop With Tput Validation    ${DIR}    ${test_variable}    ${COUNTER_LIST}    ${MAIL_DATA}

Validate Counter Values Per Cell
    [Documentation]    This keyword validates counter values for multiple cells by
    ...    comparing retrieved values with expected ones.
    ...    Author: rahul.20.singh@nokia.com
    ...    Date Modified: 02/04/2025
    [Arguments]    ${counter_id}    ${expected_value}    ${cell_count}
    Sleep    10m
    ${return_list}=    Fetch Cummulative Values    ${counter_id}
    ${scell_list_status}=    Create List
    ${cell_count}=    Convert To Integer    ${cell_count}
    FOR    ${index}    IN RANGE    1    ${cell_count}+1    1
        ${final_value}=    Get SA RRC counter value per Cell    ${index}    ${return_list}
        ${status}=    Run Keyword If    '${final_value}' == '${expected_value}'
        ...    Set Variable    True    ELSE    Set Variable    FAIL
        Append To List    ${scell_list_status}    ${status}
        Set To Dictionary    ${pre_data_dictionary}    Cell_${index}_UES    ${final_value}/${expected_value}
    END
    Log To Console   Cell value status just after registration: ${pre_data_dictionary}
    List Should Not Contain Value    ${scell_list_status}    FAIL
    ...    msg=per cell Validation failed

Get SA RRC counter value per Cell
    [Documentation]    This function retrieves the SA RRC counter value for a specified cell.
    ...    It extracts the value from a given list based on the provided cell ID.
    ...    Author: rahul.20.singh@nokia.com
    ...    Date Modified: 02/04/2025
    [Arguments]    ${cell_id}    ${return_list}
    ${final_scell}    Set Variable    ${return_list}[-1]
    ${cell_id}=    Evaluate    (${cell_id}-1)
    ${final_value}=    Set Variable    ${final_scell}[${cell_id}]
    [Return]    ${final_value}

Check AP And gNB Backhaul Status
    [Documentation]    Keyword that call to ping backhaul of AP and gNB to check the connectivity
    ...                Modified Date: 09-April-2025
    ...                Last Modified by: kokila.b@nokia.com
    [Arguments]    ${status}
    ${ap_bh_status}=    Run Keyword And Return Status    Backhaul Status Check    AP    ${AP_COUNT}    @{AP_backhaul}
    Set Suite Variable    ${ap_bh_status}
    ${gNB_bh_status}=    Run Keyword And Return Status    Backhaul Status Check    gNB    ${GNB_COUNT}    @{gNB_backhaul}
    Set Suite Variable    ${gNB_bh_status}
    Run Keyword If    '${ap_bh_status}' == 'True' and '${gNB_bh_status}' == 'True'    Fail    ${status[1]}
    ...    ELSE    Fail    Cell setup failed due to Backhaul connectivity failure

Backhaul Status Check
    [Documentation]    To check whether AP/gNB backhaul is reachable or not
    ...                Modified Date: 09-April-2025
    ...                Last Modified by: kokila.b@nokia.com
    [Arguments]    ${tag}    ${count}    @{bachkaul}
    FOR    ${ip}    IN    @{bachkaul[:${count}]}
        ${result} =    Run    ping -c 4 ${ip}
        ${status}    Run Keyword And Ignore Error    Should Contain    ${result}    bytes from
        Run Keyword If    '${status[0]}' == 'FAIL'    Log To Console    Ping failed! ${tag}:${ip} Backhaul is not reachable
    END

Perform Lock Unlock RUs
    [Documentation]    Lock, unlock RUs along with SIB check and Alarm check
    ...                Modified Date: 09/04/2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    [Arguments]    ${index}
    FOR    ${ru_id}    IN    @{ru_list}
        Lock unlock RUs    ${ru_id}    ${index}
        Check Alarms    ${before_op_dict}    ${after_op_dict}
        ${cell_list}=    Set Variable    ${RU_${ru_id}}
        @{ru_cell_lists}=    Split String    ${cell_list}    ,
        FOR    ${cell_id}    IN    @{ru_cell_lists}
            Run Keyword And Ignore Error    SIB check with UECs    ${cell_id}    ${index}
        END
    END

Lock unlock RUs
    [Documentation]    Lock, unlock RUs using TAF librarires
    ...                Modified Date: 09/04/2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    [Arguments]    ${ru_id}    ${index}
    Wait Until Keyword Succeeds    5min    30sec    CoamAdmin.Connect To    bts_host=${GNB_ASIK.Ip}
    Get Active gNB Alarms    ${before_op_dict}
    CoamAdmin.lock    dist_name=MRBTS-1/EQM-1/APEQM-1/RMOD-${ru_id}    detailed_output=True    timeout=50
    Log To Console    Iteration ${index}:Locking RU ${ru_id}
    Sleep    40s
    CoamAdmin.unlock    dist_name=MRBTS-1/EQM-1/APEQM-1/RMOD-${ru_id}    detailed_output=True    timeout=50
    Log To Console    Iteration ${index}:Unlocking RU ${ru_id}
    Sleep    40s
    Get Active gNB Alarms    ${after_op_dict}
    CoamAdmin.Teardown

Get Active gNB Alarms
    [Documentation]    Keyword to check the active gNB alarms before and after lock/unlock
    ...                Modified Date: 09/04/2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    [Arguments]    ${alaram_dict}
    ${alarm_list}=    CoamAdmin.get_active_alarms    timeout=50s
    ${alarm_len}=    Get Length    ${alarm_list}
    FOR    ${index}    IN RANGE    0    ${alarm_len}    1
        Set To Dictionary    ${alaram_dict}    ${alarm_list[${index}]['faultName']}=${alarm_list[${index}]['faultId']}
    END

Unlock RUs And Append Data
    [Documentation]    Teardown KW where all the RUs are checked for unlock state
    ...                Append Data to the test property file
    ...                Modified Date: 09/04/2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    [Arguments]    ${tc_name}
    FOR    ${i}    IN RANGE    1    ${LOOP_TIMES}+1    1
        ${list}=    Catenate    SEPARATOR=,    @{loop${i}}
        Run Keyword If    '${list}' != '${EMPTY}'    Set To Dictionary    ${MAIL_DATA}    Iter${i}=${list}
        ...    ELSE    Set To Dictionary    ${MAIL_DATA}    Iter${i}=SIBs Not received
    END
    Check Alarm List To Results    ${MAIL_DATA}
    ${json_mail_data}=    Evaluate   json.dumps(${MAIL_DATA})    json
    Append To File    ${test_property_file}
    ...    ${\n}${tc_name}_TEST_RESULTS={"s1-t1":${json_mail_data}}${\n}
    ${ru_stat}=    Checking State Of All Cells
    Run Keyword If    '${ru_stat}' == 'False'    Unblock All RUs
    Sleep    20s
    Should Be True    ${alarm_check_status}    msg=Active Alarms Present!
    List Should Not Contain Value    ${cell_status_list}    FAIL    msg=RU unblocked failed!

Check Alarms
    [Arguments]    ${before_op_dict}    ${after_op_dict}
    [Documentation]    Checking 2 alarms Dictionary for active gNB alarms
    ...                If different the delta alarms to be displayed in mail
    ...                Modified Date: 09/04/2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    ${values_after_op}=    Get Dictionary Values    ${after_op_dict}
    Set Suite Variable    @{values_after_op}
    ${values_before_op}=    Get Dictionary Values    ${before_op_dict}
    Set Suite Variable    @{values_before_op}
    ${alarm_check_status}=    Run Keyword And Return Status    List Should Contain Sub List
    ...    ${values_before_op}    ${values_after_op}
    Run Keyword If    '${alarm_check_status}' == 'False'    Display Delta Active Alarms
    Set Suite Variable    ${alarm_check_status}

Display Delta Active Alarms
    [Documentation]    Check Alarms gives the resultant list of delta active gNB alarm, which
    ...                 has to be displayed in the mail
    ...                Modified Date: 09/04/2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    ${key_before_op}=    Get Dictionary Keys    ${before_op_dict}
    Set Suite Variable    @{key_before_op}
    ${key_after_op}=    Get Dictionary Keys    ${after_op_dict}
    Set Suite Variable    @{key_after_op}
    FOR    ${alarm_index}    IN    @{key_after_op}
        ${alarm_status}=    Run Keyword And Return Status     Dictionary Should Contain Key    ${before_op_dict}    ${alarm_index}
        Run Keyword If    '${alarm_status}' != 'True'    Append Active Alarm List    ${alarm_index}
    END

Append Active Alarm List
    [Documentation]    Append Active Alarms to the mail along with Cell status
    ...                Modified Date: 09/04/2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    [Arguments]    ${alarm_index}
    ${alarm_id}=    Get From Dictionary    ${after_op_dict}    ${alarm_index}
    Append To List    ${active_alarm_list}    ${alarm_id}:${alarm_index}

Perfom Lock Unlock Operation
    [Documentation]    Comman steps for lock/unlock of
    ...                Takes dictionary, test label and list of cell/RU of the test case
    ...                Modified Date: 25/04/2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    ${MAIL_DATA}=    Create Dictionary
    Set Suite Variable    &{MAIL_DATA}
    ${before_op_dict}=    Create Dictionary
    ${after_op_dict}=    Create Dictionary
    Set Suite Variable    &{before_op_dict}
    Set Suite Variable    &{after_op_dict}
    FOR    ${index}    IN RANGE    1    ${LOOP_TIMES}+1    1
        Set To Dictionary    ${MAIL_DATA}    Iter${index}=NA
    END
    Fetch Dictionary items    ${MAIL_DATA}
    FOR    ${i}    IN RANGE    1    ${LOOP_TIMES}+1    1
        Set Suite Variable    @{loop${i}}    @{EMPTY}
    END
    ${active_alarm_list}=    Create List
    Set Suite Variable    @{active_alarm_list}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    Set Suite Variable    @{keys_list}

Cell Status List Creation and Perfom Lock Unlock of Cells
    [Arguments]    ${dictionary}    ${test_tag}
    Traffic Duration Set
    Run Keyword If    '${test_tag}' not in "@{VRAN_TCs}"
    ...    Common Register and Traffic    ${dictionary}    ${test_tag}
    ...    ELSE    Common Register and Traffic vRAN    ${dictionary}    ${test_tag}
    ${LOOP_TIMES}=    Get Variable Value    ${CELL_LOCK_UNLOCK}    ${LOOP_TIMES}
    Set Suite Variable    ${LOOP_TIMES}
    Perfom Lock Unlock Operation
    ${cell_status_list}=    Create List
    Set Suite Variable    @{cell_status_list}
    ${cell_list}=    Create List
    Set Suite Variable    @{cell_list}
    FOR    ${index}    IN RANGE    1    ${NO_OF_CELLS}+1    1
        Append To List    ${cell_list}    ${index}
    END
    ${no_register}=    Get Variable Value    ${NO_REG}    None
    FOR    ${index}    IN RANGE    1    ${LOOP_TIMES}+1    1
        Run Keyword If    '${test_tag}' in "@{VRAN_TCs}"    Perform Lock Unlock cell vRAN    ${index}
        ...    ELSE    Perform Lock Unlock cell    ${index}
    END

RUs Status List Creation and Perfom Lock Unlock of RUs
    [Arguments]    ${dictionary}    ${test_tag}
    Traffic Duration Set
    # Skip setup lock/unlock state for DCM_ORAN tests and the special AXEGHA cases
    Run Keyword If    '${DCM_ORAN}' != 'True' and '${test_tag}' not in "@{skip_serialno_tags}"
    ...    Setup lock/unlock state    ${dictionary}    ${test_tag}
    Perfom Lock Unlock Operation
    ${ru_status_list}=    Create List
    Set Suite Variable    @{ru_status_list}
    ${cell_status_list}=    Create List
    Set Suite Variable    @{cell_status_list}
    ${ru_list}=    Create List
    Set Suite Variable    @{ru_list}
    FOR    ${index}    IN RANGE    1    ${NO_OF_RUs}+1    1
        Append To List    ${ru_list}    ${index}
    END
    FOR    ${index}    IN RANGE    1    ${LOOP_TIMES}+1    1
        Perform Lock Unlock RUs    ${index}
    END

Check Alarm List To Results
    [Documentation]    Check the length of active alarm list and decide whether
    ...                the delta is present
    ...                Takes dictionary and test label of the test case
    ...                Modified Date: 09/04/2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    [Arguments]    ${MAIL_DATA}
    ${alarm_list_length}=    Get Length    ${active_alarm_list}
    Run Keyword If    '${alarm_list_length}' > '0'    Display Active Alarms    ${MAIL_DATA}

Display Active Alarms
    [Documentation]    Change the active_alarm_list to string format
    ...                Takes dictionary and test label of the test case
    ...                Modified Date: 09/04/2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    [Arguments]    ${MAIL_DATA}
    ${list_string}=    Catenate    SEPARATOR=\n    @{active_alarm_list}
    Set To Dictionary    ${MAIL_DATA}    Active Alarms Post Unlock=${list_string}
    Set Suite Variable    ${MAIL_DATA}

Unblock All RUs
    [Documentation]    Unblock All RUs to unblock during teardown for graceful termination
    ...                Modified Date: 09/04/2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    FOR    ${ru_id}    IN    @{ru_list}
        Wait Until Keyword Succeeds    5min    30sec    CoamAdmin.Connect To    bts_host=${GNB_ASIK.Ip}
        CoamAdmin.unlock    dist_name=MRBTS-1/EQM-1/APEQM-1/RMOD-${ru_id}    detailed_output=True    timeout=50
        Sleep    50s
    END
    CoamAdmin.Teardown

Unblock All Cells
    [Documentation]    Unblock All RUs to unblock during teardown for graceful termination
    ...                Modified Date: 09/04/2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    Wait Until Keyword Succeeds    5min    30sec    CoamAdmin.Connect To    bts_host=${GNB_ASIK.Ip}
    CoamAdmin.unblock_all_cells    rat=NR    detailed_output=True
    Sleep    50s
    CoamAdmin.Teardown

Kill VNC BTS Logger tool
    [Documentation]    It kills the BTS logger tool if opened via VNC
    ...                Modified Date: 16-April-2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    ${pid}=    Run    pidof /opt/btslog/btslog ss-style clearlooks
    ${bts_logger_status}=    Run Keyword And Return Status    Should Be empty    ${pid}
    ...    msg=BTS Syslogger process is Active
    Run Keyword If    '${bts_logger_status}' == 'False'    Run    sudo kill ${pid}
    ${pids}=    Run    pidof /opt/btslog/btslog ss-style clearlooks
    ${bts_logger_status}=    Run Keyword And Return Status    Should Be empty    ${pids}    msg=bts log not killed
    Should Be True    ${bts_logger_status}    msg=Unable to kill BTS GUI Syslogger process

Fetch Log Sync Jenkins Env Variables
    [Documentation]    This keyword fetches the jenkins variables required for log sync
    ...                Modified Date: 08-May-2025
    ...                Last Modified by: kushal.j@nokia.com
    ${week_ok}    Run Keyword And Return Status    Get Environment Variable    WEEK_NO
    ${WEEK_NO}    Run Keyword If    ${week_ok}    Get Environment Variable    WEEK_NO    ELSE    Generate Week Number
    Set Suite Variable    ${WEEK_NO}
    ${BUILD_NO}    Get Environment Variable    BUILD_NUMBER
    Set Suite Variable    ${BUILD_NO}
    ${result}    Catenate    SEPARATOR=_    ${WEEK_NO}    ${BUILD_NO}
    [Return]    ${result}

Generate Week Number
    ${week}=        Get Current Date    result_format=%V
    ${week_int}=    Convert To Integer    ${week}
    ${WEEK_NO}=     Set Variable    WK_${week_int}
    [Return]        ${WEEK_NO}

log sync mount and set log directory check
    [Documentation]    This keyword sets flags for log sync and non log sync
    ...                Modified Date: 08-May-2025
    ...                Last Modified by: kushal.j@nokia.com
    log sync mount check
    ${result}    Fetch Log Sync Jenkins Env Variables
    Set directory for LOG_SYNC    ${result}
    Run Keyword if    ${LOG_SYNC} == False    Set log collection flags false for non Log sync VM

log sync mount check
    [Documentation]    This keyword checks for the mount point on the VM required for log sync
    ...                Modified Date: 08-May-2025
    ...                Last Modified by: kushal.j@nokia.com
    ${output}    RUN    mountpoint /mnt/log-sync
    ${status}    Run Keyword And Return Status    Should Contain    ${output}    is a mountpoint
    ${LOG_SYNC_TMP}    Set Variable If    ${status} == True    True    False
    ${RUN_LOGSYNC}    Get Environment Variable    RUN_LOGSYNC    False
    ${RUN_LOGSYNC}    Evaluate    str('${RUN_LOGSYNC}').lower() == 'true'
    ${LOG_SYNC}    Set Variable If    ${LOG_SYNC_TMP} == True and ${RUN_LOGSYNC} == True    True    False
    set suite variable    ${LOG_SYNC}

Set directory for LOG_SYNC
    [Documentation]    This keyword sets the log directory to either log sync dir or the Exec dir
    ...                Modified Date: 08-May-2025
    ...                Last Modified by: kushal.j@nokia.com
    [Arguments]    ${result}
    ${log_folder}=    HASH Folder creation for LOG_SYNC    '${result}'
    IF  ${LOG_SYNC} == True
        Set Suite Variable    ${vm_logdir}    /mnt/log-sync/${log_folder}/rotta_logs
    ELSE
        Set Suite Variable    ${vm_logdir}    ${vm_logdir}
    END
    RUN    mkdir -p ${vm_logdir}

HASH Folder creation for LOG_SYNC
    [Documentation]    This keyword creates a unique hash folder for the enabled log sync
    ...                Modified Date: 08-May-2025
    ...                Last Modified by: kushal.j@nokia.com
    [Arguments]    ${result}
    ${hash_name}=    Evaluate    hashlib.sha256(${result}.encode()).hexdigest()    modules=hashlib
    ${half_length}=    Evaluate    len('${hash_name}') // 2
    ${hash_folder}=    Set Variable    ${hash_name}[:${half_length}]
    Create File     ${EXECDIR}/${LOG_SYNC_FILE}     ${hash_folder}
    [Return]    ${hash_folder}

XP Connection for DSS
    [Documentation]    Commands to enable XP connection for DSS
    ...                Modified Date: 21-April-2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    ute_wtssim.Execute Egate Command
    ...    script file\=/opt/wts/latest/${DSS_SETUP_FILE} entry\=${XP_CONNECTION_FUNC}
    ...    timeout=300
    Wait Until Keyword Succeeds    ${SCRIPT_COMPLETE_WAIT_TIME}    1min    Check Occurances from Egate Console    ${xp_dss_script_complete}    1

Parallel DSS Setup
    [Documentation]    Setting up of Parallel DSS
    ...                Modified Date: 21-April-2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    ute_wtssim.Execute Egate Command
    ...    script file\=/opt/wts/latest/${DSS_SETUP_FILE} entry\=${PARALLEL_DSS_FUNC}
    ...    timeout=300
    Wait Until Keyword Succeeds    ${SCRIPT_COMPLETE_WAIT_TIME}    1min    Check Occurances from Egate Console    ${parallel_dss_script_complete}    1

Check eNB1 SIBs
    [Documentation]    Check eNB1 SIBs for DSS
    ...                Modified Date: 21-April-2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    ute_wtssim.Execute Egate Command
    ...    script file\=/opt/wts/latest/multi_ue_sa_script_new.lua entry\=check_SIBs_eNB(1,${NO_OF_CELLS})
    ...    timeout=300
    Wait Until Keyword Succeeds    ${SCRIPT_COMPLETE_WAIT_TIME}    1min    Check Occurances from Egate Console    ${eNB_sib_script_complete}    1
    Check Occurances from Egate Console    ${total_eNB_sib}    ${NO_OF_CELLS}

Check CRM Statements
    [Documentation]    Validating CRM strings after DSS connection
    ...                Modified Date: 21-April-2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    ute_wtssim.Execute Egate Command
    ...    script file\=/opt/wts/latest/multi_ue_sa_script_new.lua entry\=check_CRM(1,${NO_OF_CELLS})
    ...    timeout=300
    Wait Until Keyword Succeeds    ${SCRIPT_COMPLETE_WAIT_TIME}    1min    Check Occurances from Egate Console    ${crm_script_complete}    1
    Check Occurances from Egate Console    ${total_crm}    ${NO_OF_CELLS}

Update AP swconfig files
    [Documentation]    Update AP Swconfig files via YAML
    ...                Modified Date: 21-April-2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    [Arguments]    ${test_tag}
    ${command}    Catenate    mkdir    -p ${local_path}
    Run    ${command}
    FOR    ${index}    IN RANGE    1    ${AP_COUNT}+1    1
        SSH.Connect To    ${${index}AP_ASIK.Ip}    ${${index}AP_ASIK.Username}    ${${index}AP_ASIK.Password}
        ...    alias=${${index}AP_ASIK.Connection}
        Download File    /ffs/run/swconfig.txt    ${local_path}/swconfig.txt    ${${index}AP_ASIK.Connection}
        ${command}        Catenate     python3 ${config_reader} ${local_path}/swconfig.txt
        ...    ${test_tag}
        Run    ${command}
        Sleep    2s
        SSH.Upload File    ${local_path}/swconfig.txt    /ffs/run/swconfig.txt   ${${index}AP_ASIK.Connection}
        ${stdout}=    ssh.execute    command=crasign /ffs/run/swconfig.txt    connection=${${index}AP_ASIK.Connection}
        Should Be Empty    ${stdout}    msg=failed Crasign
        ${stdout}=    ssh.execute    command=craverify /ffs/run/swconfig.txt    connection=${${index}AP_ASIK.Connection}
        SSH.Disconnect    ${${index}AP_ASIK.Connection}
    END
    ${status}    Run Keyword And Return Status    Reset and Check BTS State
    Run Keyword If    '${status}' == 'False'    Reset and Check BTS State

String Checker Python Method
    [Documentation]    Keyword uses the python method to check the detahc string
    ...                Modified Date: 21-May-2025
    [Arguments]    ${string_check}
    ${command}=    Catenate    cd ${CURDIR}/scripts/ &&
    ...       python3 -c "import wrapper_methods;
    ...       wrapper_methods.find_string_between_multiple_files('${WTS_DIR}', 'egate_console.*', '${entry}', '${string_check}')"
    ${output}=    Run    ${command}
    Should Not Contain    ${output}    Traceback    msg=Exception during end string check!
    [Return]    ${output}

Detach String Check During Teardown
    [Documentation]    Keyword Checks for detach string during teardown
    ...                Should be True in order to start the deregister
    ...                Modified Date: 21-May-2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    [Arguments]    ${string_check}
    ute_wtssim.Execute Egate Command    set_log flush
    ${output}=    String Checker Python Method    ${string_check}
    Should Be True    ${output}    msg=detach not started

Calculate Sansa Lua delays
    [Documentation]    Keyword Calculates delays present in sansa.lua files
    ...                In case of VTM Test cases where loops are present
    ...                Modified Date: 30-May-2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    ${sansa_timers}=    Create List
    FOR    ${index}    IN    @{sansa_lua_delays}
        ${timer_calculated}=    Evaluate    int(${timer}/${index})
        Append To List    ${sansa_timers}    ${timer_calculated}
    END
    Set Suite Variable    @{sansa_timers}

Calculate Timer for CNI Test cases
    [Documentation]    We used to have loop for VTM test cases alone
    ...                now there is CNI test cases where loops are involved in sansa lua file
    ...                Modified Date: 30-May-2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    Calculate Traffic Time For PET SE
    Calculate Sansa Lua delays
    ${timer}=    Set Variable    ${sansa_timers[0]}
    Set Suite Variable    ${timer}

Calculate Additional Timers
    [Documentation]    We used to have loop for VTM test cases alone
    ...                now there is CNI test cases where loops are involved in sansa lua file
    ...                Modified Date: 30-May-2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    Calculate Traffic Time For PET SE
    Calculate Sansa Lua delays
    ${timer}=    Catenate    SEPARATOR=,    ${timer}    ${sansa_timers[0]}
    Set Suite Variable    ${timer}

Validate Active UEs At Cell Level
    [Documentation]    This KW displays the cell level active UEs
    ...                Can be used generically by enabling CELL_UE : True in tC dict
    ...                Modified Date: 30-May-2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    [Arguments]    ${TYPE}
    ${cell_list}=    Get Slice From List    ${pm_counter_list}    3    9
    FOR    ${index}    ${cell}    IN ZIP    ${CELL_INDEX}    ${cell_list}
        ${ue_counter_value}=    Set Variable    ${cell}
        ${expected_var}=    Catenate    SEPARATOR=    UE_CELL    ${index}
        ${expected_val}=    Get Variable Value    ${${expected_var}}
        ${ue_value_check}=    Evaluate    (${ue_counter_value} == ${expected_val})
        ${ue_value_stats}=    Set Variable If    '${ue_value_check}' == 'True'    True    FAIL
        ${ue_value_data}=    Set Variable    "${TYPE}_${index}" : "${ue_counter_value}/${expected_val}"
        Log To Console    ${ue_value_data}
        Set Suite Variable    ${ue_value_stats}
        Append To List    ${test_verdict}    ${ue_value_stats}
    END

Combine List With Index
    [Documentation]    pm_counter_list by default will have all data irrespective of index/cells being used
    ...                This KW combines only the data which are cell-specifc and appends to the list
    ...                this data is needed when we display data in mail
    ...                Modified Date: 30-May-2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    [Arguments]    ${sublist}
    ${newlist}=    Create List
    FOR    ${index}    IN    @{CELL_INDEX}
        ${val}=    Set Variable    ${sublist[${index}-1]}
        Append To List    ${newlist}    ${val}
    END
    ${pm_counter_list_1}=    Combine Lists    ${pm_counter_list_1}    ${newlist}
    [Return]    ${pm_counter_list_1}

Validate CELL TPUT
    ${scell_list_status}=    Create List
    ${cell_index}=    Set Variable    1

    @{counters}=    Split String    ${COUNTER_CELL}    ,

    FOR    ${counter_id}    IN    @{counters}
        ${all_values}=    Fetch Cummulative Values    ${counter_id}
        ${return_list}=    Get From List    ${all_values}    -1
        ${cell_list_var}=    Catenate    SEPARATOR=_    ${counter_id}    cell
        ${cell_indexes}=    Get Variable Value    ${${cell_list_var}}
        @{cell_ids}=    Split String    ${cell_indexes}    ,
        FOR    ${cell_no}    IN    @{cell_ids}
            ${index}=    Evaluate    int(${cell_no}) - 1
            ${expected_key}=    Catenate    SEPARATOR=_    ${counter_id}    cell    ${cell_no}
            ${expected_mbps}=    Get Variable Value    ${${expected_key}}
            ${threshold}=    Evaluate    float(${expected_mbps}) * ${DL_LIMIT}
            ${raw_value}=    Get From List    ${return_list}    ${index}
            ${achieved_tput}=    Evaluate    (${raw_value} * 8) / float(300000000)
            ${achieved_tput}=    Evaluate    "%.2f" % ${achieved_tput}
            Append To List    ${pm_counter_list}    ${achieved_tput}
            ${status}=    Run Keyword If    ${achieved_tput} >= ${threshold}    Set Variable    True    ELSE    Set Variable    FAIL
            Append To List    ${scell_list_status}    ${status}
            Log To Console    CELL_${cell_no} throughput = ${achieved_tput} Mbps
            ${var_name}=    Catenate    SEPARATOR=_    CELL    ${cell_no}    tput
            Set Suite Variable    ${${var_name}}    ${achieved_tput}
            ${cell_index}=    Evaluate    ${cell_index} + 1
        END
    END

    Set Suite Variable    @{pm_counter_list}
    List Should Not Contain Value    ${scell_list_status}    FAIL
    ...    msg=Cell DL throughput validation failed!
    Log To Console    All cells validated successfully

Get current DL UL NR Cell Throughput
    [Documentation]    Fetch and validate current DL/UL throughput per cell from NR stats.
    ...    Handles direction='DL', 'UL', or 'BOTH'.
    [Arguments]    ${cell_id}    ${direction}

    ${regexp}=    Set Variable If    '${direction}' == 'DL'    DL Current Data Rate    UL Current Data Rate
    ${cmd}=    Set Variable    cell_stats_nr enb=${5G_gnb_id} id=${cell_id} format=long type=throughput
    ${stats}=    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}    pass_regexp=${regexp}    timeout=30

    ${command}=    Catenate    cd ${CURDIR}/scripts/ && python3 -c "import wrapper_methods;
    ...    print(wrapper_methods.get_nr_tput('''${stats}''', dir='${direction}'))"
    ${tput_dict}=    Run    ${command}
    Should Not Contain    ${tput_dict}    Traceback    msg=Exception during nr_stats
    ${tput_dict}=    Evaluate    ${tput_dict.strip()}

    FOR    ${cid}    IN    @{tput_dict.keys()}
        ${achieved_tput}=    Evaluate    round(${tput_dict}[${cid}]/1000, 2)
        Log To Console    Validating current ${direction} cell throughput for ue_nr_stats
        ...    Cell ${cid} = ${achieved_tput}/${OVERALL_${direction}_UE_STATS_NR} Mbps
        ${tput_status}=    Evaluate    ${achieved_tput} >= (${OVERALL_${direction}_UE_STATS_NR}*${UE_STATS_NR_LIMIT})
        Run keyword If     '${tput_status}' == 'False'
        ...    Log To Console    WARNING! Cell ${cid}, ${direction} throughput is less than expected!
        Run Keyword If    '${tput_status}' == 'True'
        ...    Log To Console    PASS: Cell ${cid}, ${direction} throughput validation passed
        ${key}=    Catenate    SEPARATOR=    UE_STATS_NR_CELL${cid}_${direction}
        ${value}=    Catenate    SEPARATOR=/    ${achieved_tput}    ${OVERALL_${direction}_UE_STATS_NR}
        Set To Dictionary    ${pre_data_dictionary}    ${key}=${value}
    END
    [Return]    ${pre_data_dictionary}

Get current RRC DL UL Cell Throughput
    [Documentation]    Fetch and validate current DL/UL RRC throughput per cell from 'ue_stats_nr' during active traffic.
    ...    If direction is 'NONE', both DL and UL are validated.
    [Arguments]    ${cell_list}    ${direction}
    &{rrc_limit_dict}=    Create Dictionary
    Set Suite Variable    ${rrc_limit_dict}
    ${regexp}=    Set Variable If    '${direction}' == 'DL'    DL Current Data Rate    UL Current Data Rate
    ${cmd}=    Set Variable    cell_stats_nr enb=${5G_gnb_id} id=${cell_list} format=long type=throughput
    ${stats}=    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}    pass_regexp=${regexp}    timeout=30

    ${command}=    Catenate    cd ${CURDIR}/scripts/ && python3 -c "import wrapper_methods;
    ...    print(wrapper_methods.get_nr_tput('''${stats}''', dir='${direction}'))"
    ${tput_dict}=    Run    ${command}
    Should Not Contain    ${tput_dict}    Traceback    msg=Excepion during nr_stats
    ${tput_dict}=    Evaluate    ${tput_dict.strip()}
    ${sorted_keys}=    Evaluate    sorted(${tput_dict}.keys())
    FOR    ${cid}    IN    @{sorted_keys}
        ${achieved_tput}=    Evaluate    (${tput_dict}[${cid}]/1000)
        Log To Console    Validate current ${direction} RRC throughput for ue_stats_nr Cell ${cid} = ${achieved_tput} Mbps
        ${tput_status}=    Evaluate    ${achieved_tput} > ${UE_STATS_NR_LIMIT}
        Run Keyword If    '${tput_status}' == 'False'
        ...    Log To Console    WARNING! Cell ${cid} ${direction} RRC throughput is less than expected!
        Run Keyword If    '${tput_status}' == 'True'
        ...    Log To Console    PASS: Cell ${cid}, ${direction} RRC throughput validation passed
        ${key}=    Catenate    SEPARATOR=    UE_STATS_NR_RRC_CELL${cid}_${direction}
        ${value}=    Set Variable    ${achieved_tput}
        Set To Dictionary    ${rrc_limit_dict}    ${key}=${value}
        ${pre_data_dictionary}=    Merge Dictionaries    ${pre_data_dictionary}    ${rrc_limit_dict}
        Set Suite Variable    ${pre_data_dictionary}
    END
    [Return]    ${pre_data_dictionary}

Validate UE_STATS_NR
    [Documentation]    Checks if the Test Case needs Validation of UE_STATS_NR
    ...    cell wise or overall throughput Validation with stats
    ...    Modified Date: 02-July-2025    Last Modified by: kushal.j@nokia.com
    ${cell_level_stats}=    Get Variable Value    ${CELL_LEVEL_UE_NR_STATS}    None
    Run Keyword If    '${cell_level_stats}' == 'True'    Validate Cell level Throughput for UE_STATS_NR
    ...     ELSE    Validate Overall Throughput for UE_STATS_NR

Validate Overall Throughput for UE_STATS_NR
    [Documentation]    Validate DL, UL, or RRC throughput per cell from 'ue_stats_nr' stats.
    ...    Selects appropriate validation based on the DIR flag ('DL', 'UL', 'both', or 'None')
    Run Keyword If    '${dir}' == 'None'    Run Keywords
    ...    Get current RRC DL UL Cell Throughput    ${cell_ue_stats_nr}    UL
    ...    AND
    ...    Get current RRC DL UL Cell Throughput    ${cell_ue_stats_nr}    DL
    ...    AND
    ...    Return From Keyword
    Run Keyword If    '${dir}' == 'both'    Run Keywords
    ...    Get current DL UL NR Cell Throughput    ${cell_ue_stats_nr}    UL
    ...    AND
    ...    Get current DL UL NR Cell Throughput    ${cell_ue_stats_nr}    DL
    ...    AND
    ...    Return From Keyword
    Run Keyword If    '${dir}' == 'UL'    Get current DL UL NR Cell Throughput    ${cell_ue_stats_nr}    ${dir}
    ...    ELSE IF    '${dir}' == 'DL'    Get current DL UL NR Cell Throughput    ${cell_ue_stats_nr}    ${dir}

Cell Setup Check
    [Documentation]    Verifies the cell setup for all configured gNBs.
    ...                Currently written for 2-gNB setup
    ...                Modified Date: 19-June-2025
    ...                Last Modified by: kokila.b@nokia.com
    Set Suite Variable    ${NO_OF_CELLS}    ${NO_OF_CELLS_value}
    Set Suite Variable    ${Cell_Count}    ${Cell_Count_value}
    Check Cells Setup

Validate Counter Accumulation
    [Arguments]    ${counter_name}
    [Documentation]    Validation UE transition from FR1 to FR2
    ...                Modified Date: 19-June-2025
    ...                Last Modified by: kokila.b@nokia.com
    FOR    ${index}    IN RANGE    1    ${max_iterations}
        Sleep    5m
        ${return_list}=    Fetch Cummulative Values    ${counter_name}
        ${accumulated_value}=    Set Variable    0
        FOR    ${sublist}    IN    @{return_list}
            ${value}=    Get From List    ${sublist}    0
            ${accumulated_value}=    Evaluate    ${accumulated_value} + ${value}
        END
        Set Suite Variable    ${accumulated_value}
        Log To Console     Addition UEs:${accumulated_value}
        Run Keyword If    ${accumulated_value} == ${END_UE}    Exit For Loop
    END

Display Stats for TCP Traffic
    ${dir}=    Convert To Lower Case    ${dir}
    ute_wtssim.Execute Egate Command    ue_ext_tcp_trf_stats ue\=1 pdu\=1 qfi\=1 at\=trf_gen dir\=${dir}

Validate Cell level Throughput for UE_STATS_NR
    [Documentation]    Validate DL, UL per cell from 'ue_stats_nr' stats.
    ...    Selects appropriate validation based on the DIR flag ('DL', 'UL', 'both')
    ${pre_data_dictionary}=    Create Dictionary
    Set Suite Variable    ${pre_data_dictionary}

    Run Keyword If    '${dir}' == 'both' or '${dir}' == 'None'    Run Keywords
    ...    Get current DL UL NR Cell Throughput Cell Wise    ${cell_ue_stats_nr}    UL
    ...    AND
    ...    Get current DL UL NR Cell Throughput Cell Wise    ${cell_ue_stats_nr}    DL
    ...    AND
    ...    ELSE    Get current DL UL NR Cell Throughput Cell Wise    ${cell_ue_stats_nr}    ${dir}

Get current DL UL NR Cell Throughput Cell Wise
    [Documentation]    Fetch and validate current DL/UL throughput per cell from NR stats.
    ...    Handles direction='DL', 'UL', or 'BOTH'
    ...    Modified Date: 02-July-2025    Last Modified by: kushal.j@nokia.com
    [Arguments]    ${cell_id}    ${direction}

    ${regexp}=    Set Variable If    '${direction}' == 'DL'    DL Current Data Rate    UL Current Data Rate
    ${cmd}=    Set Variable    cell_stats_nr enb=${5G_gnb_id} id=${cell_id} format=long type=throughput
    ${stats}=    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}    pass_regexp=${regexp}    timeout=30

    ${command}=    Catenate    cd ${CURDIR}/scripts/ && python3 -c "import wrapper_methods;
    ...    print(wrapper_methods.get_nr_tput('''${stats}''', dir='${direction}'))"
    ${tput_dict}=    Run    ${command}
    Should Not Contain    ${tput_dict}    Traceback    msg=Exception during nr_stats
    ${tput_dict}=    Evaluate    ${tput_dict.strip()}

    FOR    ${cid}    IN    @{tput_dict.keys()}
        ${achieved_tput}=    Evaluate    round(${tput_dict}[${cid}]/1000, 2)
        Log To Console    Validating current ${direction} cell throughput for ue_nr_stats
        ...    Cell ${cid} = ${achieved_tput}/${OVERALL_CELL${cid}_${direction}_UE_STATS_NR} Mbps
        ${tput_status}=    Evaluate    ${achieved_tput} >= (${OVERALL_CELL${cid}_${direction}_UE_STATS_NR}*${UE_STATS_NR_LIMIT})
        Run keyword If     '${tput_status}' == 'False'
        ...    Log To Console    WARNING! Cell ${cid}, ${direction} throughput is less than expected!
        Run Keyword If    '${tput_status}' == 'True'
        ...    Log To Console    PASS: Cell ${cid}, ${direction} throughput validation passed
        ${key}=    Catenate    SEPARATOR=    UE_STATS_NR_CELL${cid}_${direction}
        ${value}=    Catenate    SEPARATOR=/    ${achieved_tput}    ${OVERALL_CELL${cid}_${direction}_UE_STATS_NR}
        Set To Dictionary    ${pre_data_dictionary}    ${key}=${value}
    END
    [Return]    ${pre_data_dictionary}

Check Init file for gNB IPs
    [Documentation]    Check init files for No of gNBs
    ...    Modified Date: 14-July-2025    Last Modified by: anjana.kulkarni@nokia.com
    ${gNB_IP_list}=    Create List
    Set Suite Variable    @{gNB_IP_list}
    ${hostname}=    Get Hostname Details for Perf
    ${init_file}=   Get Init File Details for gNB     ${testline_config_path}    ${hostname}/__init__.py
    Run Keyword If    '${init_file}' != 'FAIL'    Set IPs for gNB from init file    ${init_file}
    Create List of gNB Count
    Get the gNB Prefix

Get Init File Details for gNB
    [Documentation]    Get Init file details
    ...    Modified Date: 14-July-2025    Last Modified by: anjana.kulkarni@nokia.com
    [Arguments]    ${main_path}    ${init_file_path}
    ${init_file}=    Catenate      SEPARATOR=/    ${main_path}    ${init_file_path}
    ${result}   ${value}=     Run Keyword And Ignore Error    File Should Exist    ${init_file}
    Return From Keyword If    '${result}' == 'PASS'      ${init_file}
    Return From Keyword If    '${result}' == 'FAIL'      FAIL

Set IPs for gNB from init file
    [Documentation]    Setting gNB IP list based on the data and gNB Count
    ...    Modified Date: 14-July-2025    Last Modified by: anjana.kulkarni@nokia.com
    [Arguments]    ${init_file}
    ${init_path}    Split String From Right    ${init_file}    /    1
    FOR    ${i}    IN RANGE    0    ${GNB_COUNT}    1
        ${command}=    Catenate    cd ${init_path}[0] &&
        ...       python -c
        ...       "from __init__ import tl;print(tl.gnbs[${i}].cu.oam_ssh_connection_details.addr)"
        ${gNB_ip}=    Run    ${command}
        Append To List    ${gNB_IP_list}    ${gNB_ip}
    END

Create List of gNB Count
    [Documentation]    Create List of gNB count range. This helps during
    ...    Common counter check
    ...    Modified Date: 14-July-2025    Last Modified by: anjana.kulkarni@nokia.com
    ${len}=    Get Length    ${gNB_IP_list}
    ${GNB_COUNT_LIST}=    Create List
    FOR    ${i}    IN RANGE    1    ${len+1}
        Append To List    ${GNB_COUNT_LIST}    ${i}
    END
    Set Suite Variable    @{GNB_COUNT_LIST}

Enable SCG Dist Percent
    ute_wtssim.Execute Egate Command    uec_param id\=1 ${SCG_DIST_PERCENT}\=${DIST_PER_VALUE}

Get the gNB Prefix
    [Documentation]    gNB IP prefix is set based on the gNB IP list
    ...    Modified Date: 14-July-2025    Last Modified by: anjana.kulkarni@nokia.com
    ${list}=    Split String    ${gNB_IP_list[0]}    .
    Set Suite Variable    @{list}
    ${nb}=    Remove From List    ${list}    -1
    ${gNB_IP_prefix}=    Evaluate    ".".join(@{list})
    Set Suite Variable    ${gNB_IP_Prefix}

Create PM counter local directory
    [Documentation]    Create local dir on TL for storing PM counter xml files for validation
    ...    Modified Date: 14-July-2025    Last Modified by: anjana.kulkarni@nokia.com
    ${pmcouter_folder}=    Create List
    Set Suite Variable    @{pmcouter_folder}
    ${pmcouter_list_folder}=    Create List
    Set Suite Variable    @{pmcouter_list_folder}
    FOR    ${i}    IN RANGE    1    ${GNB_COUNT}+1    1
        ${name}=    Catenate    SEPARATOR=    /home/ute/pmcounter_    ${i}
        Set Suite Variable    ${${name}}    ${EMPTY}
        Append To List    ${pmcouter_folder}    ${name}
        ${list_name}=    Catenate    SEPARATOR=    pm_counter_list_    ${i}
        Set Suite Variable    @{${list_name}}    ${EMPTY}
    END
    FOR    ${i}    IN RANGE    1    ${GNB_COUNT}+1    1
        Remove From List    ${pm_counter_list_${i}}    0
        Set Suite Variable    ${pm_counter_list_${i}}
    END

Add the list entries of counters
    [Documentation]    This is default KW used when gNB count is greater than 2
    ...    To add entries of multiple PM counter XML files
    ...    Modified Date: 14-July-2025    Last Modified by: anjana.kulkarni@nokia.com
    ${command}=    Catenate    cd ${CURDIR}/scripts/ &&
    ...       python3 -c
    ...       "import wrapper_methods;wrapper_methods.add_list_entries(${pmcouter_list_folder})"
    ${pm_counter_list}=    Run    ${command}
    Set Suite Variable    ${pm_counter_list}
    Log To Console    ${pm_counter_list}
    ${final_list}=    Remove String    ${pm_counter_list}    [    ]
    @{pm_counter_list}=    Split String    ${final_list}    ,
    Set Suite Variable    ${pm_counter_list}

Download Vendor File Modify and Upload the Vendor file
    [Documentation]    Downloads the def vendor file, modifies the xEC param and loads
    ...    vendor file
    ...    Modified Date: 14-July-2025    Last Modified by: anjana.kulkarni@nokia.com
    wrapper_methods.download_update_and_upload_vendor_file_to_gnb

Check AP2 and Add flag in default swconfig
    [Documentation]    Adds a proxy flag in AP2 swconfig file in order to avoid the 2nd AP active
    ...    Modified Date: 14-July-2025    Last Modified by: anjana.kulkarni@nokia.com
    ${ping_status}=    ping.ip_is_pingable    ${2AP_ASIK.Ip}    timeout=3s
    Run Keyword If    '${ping_status}' == 'True'    Add proxy IP

Add proxy IP
    [Documentation]    Calls the yaml update if AP2 is active to add proxy flag
    ...    Modified Date: 14-July-2025    Last Modified by: anjana.kulkarni@nokia.com
    ${command}    Catenate    mkdir    -p ${local_path}
    Run    ${command}
    SSH.Connect To    ${2AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}    alias=${AP_ASIK.Connection}
    Download File    ${remote_paths}swconfig_ap.txt    ${local_path}/swconfig_ap.txt    ${AP_ASIK.Connection}
    ${command}        Catenate     python3 ${config_reader} ${local_path}/swconfig_ap.txt
    ...    ${test_label}
    Run    ${command}
    Sleep    2s
    SSH.Upload File    ${local_path}/swconfig_ap.txt    /ffs/run/swconfig_ap.txt    ${AP_ASIK.Connection}
    SSH.Send Command    crasign
    ...    timeout=60    connection=${AP_ASIK.Connection}

Calculate expression
    [Documentation]    The KW takes an expression, Kpi ration and desired Tput var in order to
    ...    calculate a value via wrapper methods
    ...    Modified Date: 14-July-2025    Last Modified by: anjana.kulkarni@nokia.com
    ${var_data}=    Set Variable    ${${exp_data}}
    Set Suite Variable    ${var_data}
    ${command}=    Catenate    cd ${CURDIR}/scripts/ &&
    ...       python3 -c
    ...       "import wrapper_methods;wrapper_methods.calculate_formula(${expression}, ${var_data}, ${kpi_result})"
    ${value}=    Run    ${command}
    Log To Console    Achieved value : ${value}

Create PM Counter List
    ${pm_counter_list}=    Create List
    Set Suite Variable    @{pm_counter_list}

Ensure Egate Console Log Available
    [Documentation]    [Documentation]    Checks if Egate console log exists and is updated within the expected time.
    ...                Modified Date:12-11-2025
    ...                Last Modified by: rahul.20.singh@nokia.com
    ${egate_found}=    Get Variable Value    ${EGATE_LOG_FOUND}    False
    Run Keyword If    ${egate_found}    Return From Keyword

    FOR    ${i}    IN RANGE    30
        ${found}=    Run    /bin/sh -c "find /opt/wts/latest/ -type f -iname 'egate_console*' -print -quit || true"
        ${found_stripped}=    Strip String    ${found}

        IF    '${found_stripped}' != ''
            Log To Console    Egate console log found: ${found_stripped}
            Set Suite Variable    ${EGATE_LOG_FOUND}    True
            Return From Keyword
        END
        Sleep    10s
    END
    Fatal Error    Egate console log not found or not updated within the expected time limit.

Lane Status List Creation and Perfom Lock Unlock of lane
    [Documentation]    LOCK/UNLOCK LANE operation
    ...                Modified Date: 23/11/2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    Traffic Duration Set
    ${LOOP_TIMES}=    Get Variable Value    ${LANE_LOCK_UNLOCK}    ${LOOP_TIMES}
    Set Suite Variable    ${LOOP_TIMES}
    Perfom Lock Unlock Operation
    ${lane_status_list}=    Create List
    Set Suite Variable    @{lane_status_list}
    ${cell_status_list}=    Create List
    Set Suite Variable    @{cell_status_list}
    ${lane_list}=    Create List
    Set Suite Variable    @{lane_list}
    FOR    ${index}    IN RANGE    1    ${NO_OF_lane}+1    1
        Append To List    ${lane_list}    ${index}
    END
    FOR    ${index}    IN RANGE    1    ${LOOP_TIMES}+1    1
        Perform Lock Unlock lane    ${index}
    END

Perform Lock Unlock lane
    [Documentation]    LOCK/UNLOCK LANE and check SIB
    ...                Modified Date: 23/11/2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    [Arguments]    ${index}
    FOR    ${lane_id}    IN    @{lane_list}
        Lock unlock lane    ${lane_id}    ${index}
        Check Alarms    ${before_op_dict}    ${after_op_dict}
        FOR    ${cell_id}    IN    @{cell_list}
            Run Keyword And Ignore Error    SIB check with UECs    ${cell_id}    ${index}
        END
    END

Lock unlock lane
    [Documentation]    LOCK/UNLOCK LAnes
    ...                Modified Date: 23/11/2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    [Arguments]    ${lane_id}    ${index}
    Wait Until Keyword Succeeds    5min    30sec    CoamAdmin.Connect To    bts_host=${GNB_ASIK.Ip}
    Get Active gNB Alarms    ${before_op_dict}
    CoamAdmin.lock    dist_name=MRBTS-1/EQM-1/APEQM-1/CABINET-1/BBMOD-1/SFP-1/LANE-${lane_id}    timeout=200
    Log To Console    Iteration ${index}:Locking lane ${lane_id}
    Sleep    180s
    CoamAdmin.unlock    dist_name=MRBTS-1/EQM-1/APEQM-1/CABINET-1/BBMOD-1/SFP-1/LANE-${lane_id}    timeout=200
    Log To Console    Iteration ${index}:Unlocking lane ${lane_id}
    Sleep    180s
    Get Active gNB Alarms    ${after_op_dict}
    CoamAdmin.Teardown

AMF Status List Creation and Perfom Lock Unlock of AMF
    [Documentation]    LOCK/UNLOCK AMF operation
    ...                Modified Date: 23/11/2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    Traffic Duration Set
    ${LOOP_TIMES}=    Get Variable Value    ${AMF_LOCK_UNLOCK}    ${LOOP_TIMES}
    Set Suite Variable    ${LOOP_TIMES}
    Perfom Lock Unlock Operation
    ${amf_status_list}=    Create List
    Set Suite Variable    @{amf_status_list}
    ${amf_list}=    Create List
    Set Suite Variable    @{amf_list}
    FOR    ${index}    IN RANGE    1    ${AMF_COUNT}+1    1
        Append To List    ${amf_list}    ${index}
    END
    FOR    ${index}    IN RANGE    1    ${LOOP_TIMES}+1    1
        Perform Lock Unlock amf    ${index}
    END

Perform Lock Unlock amf
    [Documentation]    LOCK/UNLOCK AMF and check SIB and alarm check
    ...                Modified Date: 23/11/2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    [Arguments]    ${index}
    FOR    ${amf_id}    IN    @{amf_list}
        Lock unlock amf    ${amf_id}    ${index}
        Check Alarms    ${before_op_dict}    ${after_op_dict}
        FOR    ${cell_id}    IN    @{cell_list}
            Run Keyword And Ignore Error    SIB check with UECs    ${cell_id}    ${index}
        END
    END

Lock unlock amf
    [Documentation]    LOCK/UNLOCK AMF and check SIB
    ...                Modified Date: 23/11/2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    [Arguments]    ${amf_id}    ${index}
    Wait Until Keyword Succeeds    5min    30sec    CoamAdmin.Connect To    bts_host=${GNB_ASIK.Ip}
    Get Active gNB Alarms    ${before_op_dict}
    CoamAdmin.lock_ng_link    dist_name=MRBTS-1/NRBTS-1/SERVEDAMF-${amf_id}
    Log To Console    Iteration ${index}:Locking amf ${amf_id}
    Sleep    1m
    CoamAdmin.unlock_ng_link    dist_name=MRBTS-1/NRBTS-1/SERVEDAMF-${amf_id}
    Log To Console    Iteration ${index}:Unlocking amf ${amf_id}
    Get Active gNB Alarms    ${after_op_dict}
    Sleep    1m
    CoamAdmin.Teardown

Bbmod Status List Creation and Perfom Lock Unlock of bbmod
    [Documentation]    LOCK/UNLOCK BBMOD
    ...                Modified Date: 23/11/2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    Traffic Duration Set
    ${LOOP_TIMES}=    Get Variable Value    ${BBMOD_LOCK_UNLOCK}    ${LOOP_TIMES}
    Set Suite Variable    ${LOOP_TIMES}
    Perfom Lock Unlock Operation
    ${bbmod_status_list}=    Create List
    Set Suite Variable    @{bbmod_status_list}
    ${bbmod_list}=    Create List
    Set Suite Variable    @{bbmod_list}
    FOR    ${index}    IN RANGE    1    ${NO_OF_bbmod}+1    1
        Append To List    ${bbmod_list}    ${index}
    END
    FOR    ${index}    IN RANGE    1    ${LOOP_TIMES}+1    1
        Perform Lock Unlock bbmod    ${index}
    END

Perform Lock Unlock bbmod
    [Documentation]    LOCK/UNLOCK BBMOD and check SIB
    ...                Modified Date: 23/11/2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    [Arguments]    ${index}
    FOR    ${bbmod_id}    IN    @{bbmod_list}
        Lock unlock bbmod    ${bbmod_id}    ${index}
        Check Alarms    ${before_op_dict}    ${after_op_dict}
        FOR    ${cell_id}    IN    @{cell_list}
            Run Keyword And Ignore Error    SIB check with UECs    ${cell_id}    ${index}
        END
    END

Lock unlock bbmod
    [Documentation]    LOCK/UNLOCK of BBMODs
    ...                Modified Date: 23/11/2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    [Arguments]    ${bbmod_id}    ${index}
    Wait Until Keyword Succeeds    5min    30sec    CoamAdmin.Connect To    bts_host=${GNB_ASIK.Ip}
    Get Active gNB Alarms    ${before_op_dict}
    CoamAdmin.lock    dist_name=MRBTS-1/EQM-1/APEQM-1/CABINET-1/BBMOD-${bbmod_id}    timeout=200
    Log To Console    Iteration ${index}:Locking BBMOD ${bbmod_id}
    Sleep    180s
    CoamAdmin.unlock    dist_name=MRBTS-1/EQM-1/APEQM-1/CABINET-1/BBMOD-${bbmod_id}    timeout=200
    Log To Console    Iteration ${index}:Unlocking BBMOD ${bbmod_id}
    Get Active gNB Alarms    ${after_op_dict}
    Sleep    180s
    CoamAdmin.Teardown

Unlock Lanes And Append Data
    [Documentation]    Teardown KW where all the LANEs are checked for unlock state
    ...                Append Data to the test property file
    ...                Modified Date: 23/11/2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    [Arguments]    ${tc_name}
    FOR    ${i}    IN RANGE    1    ${LOOP_TIMES}+1    1
        ${list}=    Catenate    SEPARATOR=,    @{loop${i}}
        Run Keyword If    '${list}' != '${EMPTY}'    Set To Dictionary    ${MAIL_DATA}    Iter${i}=${list}
        ...    ELSE    Set To Dictionary    ${MAIL_DATA}    Iter${i}=SIBs Not received
    END
    Check Alarm List To Results    ${MAIL_DATA}
    ${json_mail_data}=    Evaluate   json.dumps(${MAIL_DATA})    json
    Append To File    ${test_property_file}
    ...    ${\n}${tc_name}_TEST_RESULTS={"s1-t1":${json_mail_data}}${\n}
    ${lane_stat}=    Checking State Of All Cells
    Run Keyword If    '${lane_stat}' == 'False'    Unblock All Lanes
    Sleep    20s
    Should Be True    ${alarm_check_status}    msg=Active Alarms Present!
    Log To Console    ${lane_status_list}
    List Should Not Contain Value    ${lane_status_list}    FAIL    msg=Lane unblocked failed!
    Log To Console    ${lane_status_list}

Unblock All Lanes
    [Documentation]    Unblock All Lanes to unblock during teardown for graceful termination
    ...                Modified Date: 23/11/2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    FOR    ${lane_id}    IN    @{lane_list}
        Wait Until Keyword Succeeds    5min    30sec    CoamAdmin.Connect To    bts_host=${GNB_ASIK.Ip}
        CoamAdmin.unlock    dist_name=MRBTS-1/EQM-1/APEQM-1/CABINET-1/BBMOD-1/SFP-1/LANE-${lane_id}
        ...    detailed_output=True
        ...    timeout=200
        Sleep    50s
    END
    CoamAdmin.Teardown

Unblock All BBmods
    [Documentation]    Unblock All BBMODs to unblock during teardown for graceful termination
    ...                Modified Date: 23/11/2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    FOR    ${bbmod_id}    IN    @{bbmod_list}
        Wait Until Keyword Succeeds    5min    30sec    CoamAdmin.Connect To    bts_host=${GNB_ASIK.Ip}
        CoamAdmin.unlock    dist_name=MRBTS-1/EQM-1/APEQM-1/CABINET-1/BBMOD-${bbmod_id}    timeout=200
        ...    detailed_output=True
        ...    timeout=200
        Sleep    50s
    END
    CoamAdmin.Teardown

Unblock All AMFs
    [Documentation]    Unblock All AMFs to unblock during teardown for graceful termination
    ...                Modified Date: 23/11/2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    FOR    ${amf_id}    IN    @{amf_list}
        Wait Until Keyword Succeeds    5min    30sec    CoamAdmin.Connect To    bts_host=${GNB_ASIK.Ip}
        CoamAdmin.unlock_ng_link    dist_name=MRBTS-1/NRBTS-1/SERVEDAMF-${amf_id}
        Sleep    50s
    END
    CoamAdmin.Teardown

Unlock Bbmods And Append Data
    [Documentation]    Teardown KW where all the BBMODs are checked for unlock state
    ...                Append Data to the test property file
    ...                Modified Date: 23/11/2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    [Arguments]    ${tc_name}
    FOR    ${i}    IN RANGE    1    ${LOOP_TIMES}+1    1
        ${list}=    Catenate    SEPARATOR=,    @{loop${i}}
        Run Keyword If    '${list}' != '${EMPTY}'    Set To Dictionary    ${MAIL_DATA}    Iter${i}=${list}
        ...    ELSE    Set To Dictionary    ${MAIL_DATA}    Iter${i}=SIBs Not received
    END
    Check Alarm List To Results    ${MAIL_DATA}
    ${json_mail_data}=    Evaluate   json.dumps(${MAIL_DATA})    json
    Append To File    ${test_property_file}
    ...    ${\n}${tc_name}_TEST_RESULTS={"s1-t1":${json_mail_data}}${\n}
    ${bbmod_stat}=    Checking State Of All Cells
    Run Keyword If    '${bbmod_stat}' == 'False'    Unblock All BBmods
    Sleep    20s
    Should Be True    ${alarm_check_status}    msg=Active Alarms Present!
    Log To Console    ${bbmod_status_list}
    List Should Not Contain Value    ${bbmod_status_list}    FAIL    msg=Bbmod unblocked failed!

Append Data and add lock/unlock status
    [Documentation]    FInal mail status for lock/unlock case
    ...                Modified Date: 23/11/2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    [Arguments]    ${final_data}    ${tc_name}
    ${new_mail}=    Create Dictionary
    Set Suite Variable    &{new_mail}
    ${mail_keys}=           Split String    ${MAIL_Value}    separator=,
    FOR    ${i}   ${j}    IN ZIP    ${final_data}    ${mail_keys}
        Set To Dictionary    ${new_mail}    ${j}=${i}
    END
    Log To Console    ${new_mail}
    ${json_mail_data}=    Evaluate   json.dumps(${new_mail})    json
    Set Suite Variable    ${json_mail_data}
    Append To File    ${test_property_file}
    ...    ${\n}${tc_name}_TEST_RESULTS={"s1-t1":${json_mail_data}}${\n}

Setup lock/unlock state
    [Documentation]    setup LOCK/UNLOCK for non-register scenarios
    ...                Modified Date: 23/11/2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    [Arguments]    ${dictionary}    ${test_tag}
    Common Register and Traffic    ${dictionary}    ${test_tag}

Initialize_And_Execute_DCM_IOT_Profile_Test
    [Documentation]    LOCK/UNLOCK of all entities for DCM ORAN
    ...                Modified Date: 23/11/2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    [Arguments]    ${dictionary_name}    ${test_tag}
    Run Keyword If    '${test_tag}' not in @{skip_serialno_tags}
    ...    Validate Serial Numbers for DCM ORAN Test cases    ${dictionary_name}    ${test_tag}
    Fetch Dictionary items    ${dictionary_name}
    ${FINAL_DATA}=    Create List
    Set Suite Variable    @{FINAL_DATA}
    ${LOOP_TIMES}=     Get Variable Value    ${CELL_LOCK_UNLOCK}     ${LOOP_TIMES}
    Set Suite Variable    ${LOOP_TIMES}
    ${cell_list}=    Create List
    FOR    ${i}    IN RANGE    1    ${NO_OF_CELLS}+1    1
        Append To List    ${cell_list}    ${i}
    END
    Set Suite Variable    @{cell_list}
    Cell Status List Creation and Perfom Lock Unlock of Cells    ${dictionary_name}    ${test_tag}
    Run Keyword    Unlock cells And Append Data    ${test_tag}
    Append To List    ${FINAL_DATA}    ${MAIL_DATA}
    RUs Status List Creation and Perfom Lock Unlock of RUs    ${dictionary_name}    ${test_tag}
    Run Keyword    Unlock RUs And Append Data    ${test_tag}
    Append To List    ${FINAL_DATA}    ${MAIL_DATA}
    Lane Status List Creation and Perfom Lock Unlock of lane
    Run Keyword    Unlock Lanes And Append Data    ${test_tag}
    Append To List    ${FINAL_DATA}    ${MAIL_DATA}
    ${AMF_LOCK_ON}=    Run Keyword And Return Status    Variable Should Exist    ${AMF_LOCK}
    Set Suite Variable    ${AMF_LOCK_ON}
    Run Keyword If    '${AMF_LOCK_ON}' == 'True'    AMF Operations    ${test_tag}
    Bbmod Status List Creation and Perfom Lock Unlock of bbmod
    Run Keyword    Unlock Bbmods And Append Data    ${test_tag}
    Append To List    ${FINAL_DATA}    ${MAIL_DATA}
    Reset RMODs and Check Cell Status
    Run Keyword    Unlock RUs And Append Data    ${test_tag}
    Append To List    ${FINAL_DATA}    ${MAIL_DATA}
    Reset BBMOD and Check Cell Status
    Run Keyword    Unlock Bbmods And Append Data    ${test_tag}
    Append To List    ${FINAL_DATA}    ${MAIL_DATA}
    Reset gNB and Check Cell Status
    Run Keyword    Unlock cells And Append Data    ${test_tag}
    Append To List    ${FINAL_DATA}    ${MAIL_DATA}

Reset RMODs and Check Cell Status
    [Documentation]    TO perform RMOD reset for LOOP TIMES
    ...                Modified Date: 23/11/2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    Traffic Duration Set
    Run Keyword If    '${DCM_ORAN}' != 'True'
    ...    Setup lock/unlock state    ${dictionary}    ${test_tag}
    ${LOOP_TIMES}=    Get Variable Value    ${RESET_RU_LOOP}    ${LOOP_TIMES}
    Set Suite Variable    ${LOOP_TIMES}
    Perfom Lock Unlock Operation
    ${ru_reset_list}=    Create List
    Set Suite Variable    @{ru_reset_list}
    ${cell_status_list}=    Create List
    Set Suite Variable    @{cell_status_list}
    ${ru_list}=    Create List
    Set Suite Variable    @{ru_list}
    FOR    ${index}    IN RANGE    1    ${NO_OF_RUs}+1    1
        Append To List    ${ru_list}    ${index}
    END
    FOR    ${index}    IN RANGE    1    ${LOOP_TIMES}+1    1
        Perform reset RUs    ${index}
    END

Perform reset RUs
    [Documentation]    KW to reset RMOD
    ...                Modified Date: 23/11/2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    [Arguments]    ${index}
    FOR    ${ru_id}    IN    @{ru_list}
        Reset RU    ${ru_id}    ${index}
        Check Alarms    ${before_op_dict}    ${after_op_dict}
        ${cell_list}=    Set Variable    ${RU_${ru_id}}
        @{ru_cell_lists}=    Split String    ${cell_list}    ,
        FOR    ${cell_id}    IN    @{ru_cell_lists}
            Run Keyword And Ignore Error    SIB check with UECs    ${cell_id}    ${index}
        END
    END

Reset RU
    [Documentation]    Reset RUs along with SIB check and Alarm check
    ...                Modified Date: 23/11/2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    [Arguments]    ${ru_id}    ${index}
    Wait Until Keyword Succeeds    5min    30sec    CoamAdmin.Connect To    bts_host=${GNB_ASIK.Ip}
    Get Active gNB Alarms    ${before_op_dict}
    CoamAdmin.reset_unit    dist_name=MRBTS-1/EQM-1/APEQM-1/RMOD-${ru_id}    timeout=200
    Log To Console    Iteration ${index}:RESET RU ${ru_id}
    Sleep    5m
    Get Active gNB Alarms    ${after_op_dict}
    CoamAdmin.Teardown

Reset BBMOD and Check Cell Status
    [Documentation]    Reset BBMOD for LOOP TIMES
    ...                Modified Date: 23/11/2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    Traffic Duration Set
    ${LOOP_TIMES}=    Get Variable Value    ${RESET_BBMOD_LOOP}    ${LOOP_TIMES}
    Set Suite Variable    ${LOOP_TIMES}
    Perfom Lock Unlock Operation
    ${bbmod_status_list}=    Create List
    Set Suite Variable    @{bbmod_status_list}
    ${cell_status_list}=    Create List
    Set Suite Variable    @{cell_status_list}
    ${bbmod_list}=    Create List
    Set Suite Variable    @{bbmod_list}
    FOR    ${index}    IN RANGE    1    ${NO_OF_bbmod}+1    1
        Append To List    ${bbmod_list}    ${index}
    END
    FOR    ${index}    IN RANGE    1    ${LOOP_TIMES}+1    1
        Perform reset BBMODs    ${index}
    END

Perform reset BBMODs
    [Documentation]    Lock, unlock BBMODs along with SIB check and Alarm check
    ...                Modified Date: 23/11/2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    [Arguments]    ${index}
    FOR    ${bbmod_id}    IN    @{bbmod_list}
        Reset BBMOD    ${bbmod_id}    ${index}
        Check Alarms    ${before_op_dict}    ${after_op_dict}
        FOR    ${cell_id}    IN    @{cell_list}
            Run Keyword And Ignore Error    SIB check with UECs    ${cell_id}    ${index}
        END
    END

Reset BBMOD
    [Documentation]    Reset BBMOD and alarms check
    ...                Modified Date: 23/11/2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    [Arguments]    ${bbmod_id}    ${index}
    Wait Until Keyword Succeeds    5min    30sec    CoamAdmin.Connect To    bts_host=${GNB_ASIK.Ip}
    Get Active gNB Alarms    ${before_op_dict}
    CoamAdmin.reset_unit    dist_name=MRBTS-1/EQM-1/APEQM-1/CABINET-1/BBMOD-${bbmod_id}    reset_type=PowerReset    timeout=900
    Log To Console    Iteration ${index}:RESET BBMOD ${bbmod_id}
    Sleep    7m
    Get Active gNB Alarms    ${after_op_dict}
    CoamAdmin.Teardown

Reset gNB and Check Cell Status
    [Documentation]    Reset gNB for LOOP times
    ...                Modified Date: 23/11/2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    Stop Edaemon Egate
    ute_wtssim.teardown_all_aliases_for_edaemon
    ute_wtssim.teardown_all_aliases_for_egate
    Traffic Duration Set
    ${LOOP_TIMES}=    Get Variable Value    ${RESET_GNB_LOOP}    ${LOOP_TIMES}
    Set Suite Variable    ${LOOP_TIMES}
    Perfom Lock Unlock Operation
    ${gNB_reset_list}=    Create List
    Set Suite Variable    @{gNB_reset_list}
    ${cell_status_list}=    Create List
    Set Suite Variable    @{cell_status_list}
    FOR    ${index}    IN RANGE    1    ${LOOP_TIMES}+1    1
        Perform reset gNB    ${index}
        Stop Edaemon Egate
        ute_wtssim.teardown_all_aliases_for_edaemon
        ute_wtssim.teardown_all_aliases_for_egate
    END

Perform reset gNB
    [Documentation]    KW to perform reset gNB
    ...                Modified Date: 23/11/2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    [Arguments]    ${index}
    Reset gNB    ${index}
    FOR    ${cell_id}    IN    @{cell_list}
        Run Keyword And Ignore Error    SIB check with UECs    ${cell_id}    ${index}
    END

Reset gNB
    [Documentation]    Reset gNB along with SIB check and Alarm check
    ...                Modified Date: 23/11/2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    [Arguments]    ${index}
    Wait Until Keyword Succeeds    5min    30sec    CoamAdmin.Connect To    bts_host=${GNB_ASIK.Ip}
    Get Active gNB Alarms    ${before_op_dict}
    Reset All and Start WTS
    Log To Console    Iteration ${index}:RESET gNB
    Sleep    10m
    Wait Until Keyword Succeeds    5min    30sec    CoamAdmin.Connect To    bts_host=${GNB_ASIK.Ip}
    Get Active gNB Alarms    ${after_op_dict}
    CoamAdmin.Teardown

AMF Operations
    [Documentation]    AMFs operations
    ...                Append Data to the test property file
    ...                Modified Date: 21/11/2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    [Arguments]    ${tc_name}
    AMF Status List Creation and Perfom Lock Unlock of AMF
    Unlock AMFs And Append Data    ${tc_name}
    Append To List    ${FINAL_DATA}    ${MAIL_DATA}

Unlock AMFs And Append Data
    [Documentation]    Teardown KW where all the AMFs are checked for unlock state
    ...                Append Data to the test property file
    ...                Modified Date: 21/11/2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    [Arguments]    ${tc_name}
    FOR    ${i}    IN RANGE    1    ${LOOP_TIMES}+1    1
        ${list}=    Catenate    SEPARATOR=,    @{loop${i}}
        Run Keyword If    '${list}' != '${EMPTY}'    Set To Dictionary    ${MAIL_DATA}    Iter${i}=${list}
        ...    ELSE    Set To Dictionary    ${MAIL_DATA}    Iter${i}=SIBs Not received
    END
    Check Alarm List To Results    ${MAIL_DATA}
    ${json_mail_data}=    Evaluate   json.dumps(${MAIL_DATA})    json
    Append To File    ${test_property_file}
    ...    ${\n}${tc_name}_TEST_RESULTS={"s1-t1":${json_mail_data}}${\n}
    ${amf_stat}=    Checking State Of All Cells
    Run Keyword If    '${amf_stat}' == 'False'    Unblock All AMFs
    Sleep    20s
    Should Be True    ${alarm_check_status}    msg=Active Alarms Present!
    Log To Console    ${amf_status_list}
    List Should Not Contain Value    ${amf_status_list}    FAIL    msg=AMFs unblocked failed!

############################### NEW LUA FORMAT KWs #########################################
New Test Sequence Lua file
    [Documentation]    test_sequence.lua file is used to call the tc entry function
    ...    Modified Date: 24-11-2025    Last Modified by: anjana.kulkarni@nokia.com
    ute_wtssim.Execute Egate Command
    ...    script file\=/opt/wts/latest/test_sequence.lua entry\=${entry}
    ...    timeout=300

Copy New PET SE files
    [Documentation]    copy all new .lua files to WTS_DIR
    ...    Modified Date: 24-11-2025    Last Modified by: anjana.kulkarni@nokia.com
    Run Keyword If    '${CUSTOM_CONFIGS}' != 'None'
    ...    Override Lua From Custom Config    ${sim_data_lua}
    Copy SANSA Lua    ${sim_data_lua}
    ${CAP_CFG_FILE}=    Catenate    ${CAPABILITY_CFG_FILE}
    Set Suite Variable    ${CAP_CFG_FILE}
    Run    cp ${CAP_CFG_FILE} ${WTS_DIR}
    Run Keyword If    '${CUSTOM_CONFIGS}' != 'None'
    ...    Override Lua From Custom Config    ${test_sequence_lua}
    ${TEST_SEQUENCE}=    Catenate    ${test_sequence_lua}
    Set Suite Variable    ${TEST_SEQUENCE}
    Run    cp ${TEST_SEQUENCE} ${WTS_DIR}
    ${SIM_CONFIG}=    Catenate    ${new_sim_config}
    Set Suite Variable    ${SIM_CONFIG}
    Run    cp ${SIM_CONFIG} ${WTS_DIR}
    ${MULTI_UE_SCRIPT_NEW}=    Catenate    ${PET_MULTI_UE_SCRIPT}
    Set Suite Variable    ${MULTI_UE_SCRIPT_NEW}
    Run    cp ${MULTI_UE_SCRIPT_NEW} ${WTS_DIR}
    ${MULTI_UE_SCRIPT_v5NEW}=    Catenate    ${PET_MULTI_UE_v5SCRIPT}
    Set Suite Variable    ${MULTI_UE_SCRIPT_v5NEW}
    Run    cp ${MULTI_UE_SCRIPT_v5NEW} ${WTS_DIR}


Override Lua From Custom Config
    [Documentation]    Smart optional Lua override. Does not fail if no custom folder found.
    ...    Modified Date: 10-02-2026    Last Modified by: rahul.20.singh@nokia.com
    [Arguments]    ${TARGET_LUA_PATH}
    ${file_name}=    Evaluate    __import__('os').path.basename(r'''${TARGET_LUA_PATH}''')
    @{ALLOWED_LUA_FILES}=    Create List
    ...    sim_data.lua
    ...    sansa.lua
    ...    test_sequence.lua
    ...    commands.lua
    List Should Contain Value    ${ALLOWED_LUA_FILES}    ${file_name}
    IF    '${CUSTOM_CONFIGS}' == '' or '${CUSTOM_CONFIGS}' == 'None'
        Log To Console    No custom config provided for ${file_name}. Using repo version.    WARN
        RETURN
    END
    ${config_list}=    Split String    ${CUSTOM_CONFIGS}    ,
    ${selected_folder}=    Set Variable    ${EMPTY}
    FOR    ${folder}    IN    @{config_list}
        ${folder}=    Strip String    ${folder}
        ${folder_name}=    Evaluate    __import__('os').path.basename(r'''${folder}''')
        IF    '${TEST_CONFIGURATION}' in '${folder_name}'
            ${selected_folder}=    Set Variable    ${folder}
            Exit For Loop
        END
    END

    IF    '${selected_folder}' == ''
        Log To Console    No matching custom folder for ${TEST_CONFIGURATION}. Using repo version.    WARN
        RETURN
    END
    ${custom_file}=    Evaluate    __import__('os').path.join(r'''${selected_folder}''', r'''${file_name}''')
    ${exists}=    Evaluate    __import__('os').path.exists(r'''${custom_file}''')
    IF    not ${exists}
        Log To Console    ${file_name} not present in ${selected_folder}. Using repo version.    WARN
        RETURN
    END
    Log To Console    Overriding ${file_name} from ${selected_folder}
    Copy File    ${custom_file}    ${TARGET_LUA_PATH}
    Log To Console    ${file_name} successfully overridden.

Check NgLink and Cell Setup With New Lua Format
    [Documentation]    sim_config.lua is used instead of sansa.lua
    ...    Modified Date: 24-11-2025    Last Modified by: anjana.kulkarni@nokia.com
    ${wts_lua_command}=    Set Variable    cfg_sim file=/opt/wts/latest/sim_config.lua entry=run_configuration(sim_data,${timer})
    ute_wtssim.Execute Egate Command    ${wts_lua_command}    timeout=10minutes
    Wait Until Keyword Succeeds    15min    30s    Check Occurances from Egate Console    ${simmode_active}    1
    Check for Cell Setup SIB and Ng Link
    FOR    ${index}    IN RANGE    2    ${GNB_COUNT}+1
        Cell Setup Check
    END

X2 link via sim config
    [Documentation]    Common x2 link called via sim_config.lua file
    ...    Modified Date: 24-11-2025    Last Modified by: anjana.kulkarni@nokia.com
    ute_wtssim.Execute Egate Command
    ...    script file\=/opt/wts/latest/sim_config.lua entry\=${X2LINK_SEQ_FUNC}(sim_data)
    ...    timeout=300

Display Values with Pairing Ratio
    ${cell2_val1}=    Evaluate    (${pm_counter_list_1[2]}/300)
    Log To Console    Cell2_M55165C00039:${cell2_val1}
    ${cell2_val2}=    Evaluate    (${pm_counter_list_1[3]}/300)
    Log To Console    Cell2_M55181C00013:${cell2_val2}
    ${pairing_ratio_val}=    Evaluate    (${kpi_result}/4)
    ${pv}=    Evaluate    (420*${pairing_ratio_val}+79)
    Log To Console    PDCP M55326C00502 value:${pv}
    ${OVERALL_UL}=    Set Variable    ${pv}
    Set Suite Variable    ${OVERALL_UL}
    ${cell2_val3}=    Evaluate    (${pm_counter_list_1[4]}/300000000)
    Log To Console    Cell2_M55310C03006:${cell2_val3}
    ${cell4_val}=    Evaluate    (${pm_counter_list_1[5]}/300000000)
    Log To Console    Cell4_M55310C03006:${cell4_val}

Connection to vdu vRAN
    [Documentation]    Establishes a secure connection to the vDU in vRAN using the
    ...                provided host,port and credentials.
    ...     Modified Date: 28-11-2025
    ...     Last Modified by: rahul.20.singh@nokia.com
    Wait Until Keyword Succeeds    2min    5sec   vDU.connect_to   host=${vdu_host}   port=${vran_port}
    ...    username=${vdu_username}   password=${vdu_password}
    ...    secure=True    connection_name=default

Perform Lock Unlock cell vRAN
    [Documentation]    This keyword performs lock and unlock operations on all given cells in vRAN.
    ...     Iterates through each cell ID and triggers lock/unlock via vDU
    ...     Modified Date: 28-11-2025
    ...     Last Modified by: rahul.20.singh@nokia.com
    [Arguments]    ${index}
    FOR    ${cell_id}    IN    @{cell_list}
        Lock unlock Cell In vDU    ${cell_id}    ${index}
        Check Alarms    ${before_op_dict}    ${after_op_dict}
    END

Lock unlock Cell In vDU
    [Documentation]    This keyword is used to lock/unlock cells in vRAN
    ...                Modified Date: 09-11-2025
    ...                Last Modified by: rahul.20.singh@nokia.com
    [Arguments]    ${cell_id}    ${index}
    Log To Console    Iteration-${index} Start locking cells: ${cell_id}
    Connection to vdu vRAN
    ${cell_id_list}=    Evaluate    [s.strip() for s in str(${cell_id}).split(',') if s.strip()]
    ${out}=    vDU.lock_cells    ${cell_id_list}
    Wait Until Keyword Succeeds    ${Total_Timeout}    ${Retry_Timeout}    Get state of locking cells    ${out}
    Sleep    20
    Log To Console    Iteration-${index} Start unlocking cells: ${cell_id}
    ${out}=    vDU.unlock_cells    ${cell_id_list}
    Wait Until Keyword Succeeds    ${Total_Timeout}    ${Retry_Timeout}    Get state of unlocking cells    ${out}
    vDU.disconnect

Alarm check And Append Data vRAN
    [Documentation]    Collects vRAN alarm results per iteration, updates MAIL_DATA,
    ...                writes results to test property file, and verifies no active alarms.
    ...    Modified Date: 09-11-2025
    ...    Last Modified by: rahul.20.singh@nokia.com
    [Arguments]    ${tc_name}
    FOR    ${i}    IN RANGE    1    ${LOOP_TIMES}+1    1
        ${list}=    Catenate    SEPARATOR=,    @{loop${i}}
        Run Keyword If    '${list}' != '${EMPTY}'    Set To Dictionary    ${MAIL_DATA}    Iter${i}=${list}
        ...    ELSE    Set To Dictionary    ${MAIL_DATA}    Iter${i}=SIBs Not received
    END
    Check Alarm List To Results    ${MAIL_DATA}
    ${json_mail_data}=    Evaluate   json.dumps(${MAIL_DATA})    json
    Append To File    ${test_property_file}
    ...    ${\n}${tc_name}_TEST_RESULTS={"s1-t1":${json_mail_data}}${\n}
    Should Be True    ${alarm_check_status}    msg=Active Alarms Present!

Copy MVP Files
    Run    cp ${VTM_LUA} ${WTS_DIR}
    Run    cp ${HW_VTM_LUA} ${WTS_DIR}
    Run    cp ${PET_SE_CFG} ${WTS_DIR}

Validate Cumulative Counters For DL UL Mode
    [Documentation]
    ...    Validates cumulative counters based on the DUAL_BOOST_MODE.
    ...    Supported modes:
    ...    - DL     : Validate DL counters only
    ...    - UL     : Validate UL counters only
    ...    - DL_UL  : Validate both DL and UL counters
    ...    Used for dual boost scenarios
    ...    Modified Date    : 23/12/2025
    ...    Last Modified by: rahul.20.singh@nokia.com
    ${mode}=    Get Variable Value    ${DUAL_BOOST_MODE}
    Run Keyword If    'DL' in '${mode}'    Validate DL Or UL Counter    DL
    Run Keyword If    'UL' in '${mode}'    Validate DL Or UL Counter    UL

Validate DL Or UL Counter
    [Documentation]
    ...    Validates cumulative counter values for the given direction (DL or UL).
    ...    Fetches the relevant counter, sums values across all cells,
    ...    and verifies the total against the expected threshold.
    ...    Modified Date    : 23/12/2025
    ...    Last Modified by: rahul.20.singh@nokia.com
    [Arguments]    ${DIRECTION}
    ${cell_count}=    Convert To Integer    ${NO_OF_CELLS}
    ${counter_pos}=    Set Variable If
    ...    '${DIRECTION}' == 'DL'    ${DUAL_BOOST_DL_pos}
    ...    ${DUAL_BOOST_UL_pos}
    ${expected}=    Set Variable If
    ...    '${DIRECTION}' == 'DL'    ${OVERALL_DUAL_BOOST_DL}
    ...    ${OVERALL_DUAL_BOOST_UL}
    ${COUNTER_LIST}=    Run Keyword If    '${test_label}' == 'AXEGHA_CB013212'    Set Variable    ${pm_counter_list}
    ...    ELSE    Split String    ${COUNTERS}    ,
    ${counter_id}=    Set Variable    ${counter_list}[${counter_pos}]
    ${return_list}=    Fetch Cummulative Values    ${counter_id}
    ${final_scell}=    Set Variable    ${return_list}[-1]
    ${total}=    Set Variable    0
    ${cell_selection}=    Get Variable Value    ${VALIDATE_SINGLE_CELL}    False
    IF    '${cell_selection}' != 'False' and '${cell_selection}' != ''
        ${cell_index}=    Evaluate    int(${cell_selection}) - 1
        Should Be True    ${cell_index} < ${cell_count}
        ...    msg=Invalid cell index provided: ${cell_selection}
        ${cell_value}=    Set Variable    ${final_scell}[${cell_index}]
        ${total}=    Evaluate    int(${cell_value})
    ELSE
        FOR    ${index}    IN RANGE    1    ${cell_count}+1
            ${cell_index}=    Evaluate    ${index}-1
            ${cell_value}=    Set Variable    ${final_scell}[${cell_index}]
            ${total}=    Evaluate    ${total} + int(${cell_value})
        END
    END
    ${check}=    Evaluate    (${total} >= ${expected})
    ${status}=   Set Variable If    '${check}' == 'True'    PASS    FAIL
    Log To Console    ${DIRECTION}_${TYPE} : ${total}/${expected}
    Set To Dictionary
    ...    ${pre_data_dictionary}
    ...    ${DIRECTION}_${TYPE}
    ...    ${total}/${expected}
    Append To List    ${test_verdict}    ${status}
    Should Be Equal    ${status}    PASS
    ...    msg=${DIRECTION} ${TYPE} validation failed

Validate Serial Numbers for DCM ORAN Test cases
    [Documentation]    Serial Numbers from VNC and NC snaphot file validation
    ...    Modified Date    : 03/02/2026
    ...    Author: anjana.kulkarni@nokia.com
    [Arguments]    ${dictionary_name}    ${test_tag}
    Fetch Dictionary items    ${dictionary_name}
    ${serial_vnc_list}=    Create List
    Set Suite Variable    @{serial_vnc_list}
    ${serial_oran_list}=    Create List
    Set Suite Variable    @{serial_oran_list}
    Wait Until Keyword Succeeds    5min    30sec    CoamAdmin.Connect To    bts_host=${GNB_ASIK.Ip}
    ${bts_info}=    CoamAdmin.Get bts info
    ${rmod}=    Set Variable    ${bts_info['radioModules']}
    ${res1}=    Set Variable    ${rmod['rmod']}
    FOR    ${index}    IN    @{res1}
        Append To List    ${serial_vnc_list}    ${index['serialNumber']}
    END
    Sort List    ${serial_vnc_list}
    ${jo_bringup}=    Run Keyword And Return Status    Environment Variable Should Be Set    JO_BRINGUP
    ${agent_bringup}=    Run Keyword And Return Status    Environment Variable Should Be Set    RUN_AGENT
    ${XML_PATH}=    Set Variable If    '${jo_bringup}' == 'True'    ${JO_BRING_ORAN_SNPASHOT}/${ute_ca_variant}
    ...    '${agent_bringup}' == 'True'    ${AGENT_ORAN_SNAPSHOT}/${ute_ca_variant}
    Set Suite Variable    ${XML_PATH}
    Run Keyword If    '${test_tag}' not in "@{DCM_snapshots_tags}"    Set Paths for XML Files
    ...    ELSE    Set Path for XML Oran
    Sort List    ${serial_oran_list}
    ${serial_status}=    Run Keyword And Return Status
    ...    Lists Should Be Equal    ${serial_vnc_list}    ${serial_oran_list}
    Run Keyword If    '${serial_status}' == 'False'    FAIL    msg=Serial Numbers in SNAPSHOT do not match!
    ...    ELSE    Log To Console    Serial Numbers validation Successful!

Set Paths for XML Files
    [Documentation]    XML paths for one or more files present
    ...    Modified Date    : 03/02/2026
    ...    Author: anjana.kulkarni@nokia.com
    @{NC_SNAPSHOT}=    Split String    ${NC_SNAPSHOT}    ,
    FOR    ${index}    IN    @{NC_SNAPSHOT}
        ${xml_file}=    Catenate    SEPARATOR=/    ${XML_PATH}    ${index}_AP_1.xml
        ${root}=    Parse XML    ${xml_file}
        @{serial_num}=    Get Elements    ${root}    .//serial-num[1]
        ${serial_num}=           Get Element Text    ${serial_num[0]}
        Append To List    ${serial_oran_list}    ${serial_num}
    END

Set Path for XML Oran
    [Documentation]    XML paths for one file with same pattern and multiple files
    ...    Modified Date    : 03/02/2026
    ...    Author: anjana.kulkarni@nokia.com
    FOR    ${ncs_index}    IN RANGE    1    ${NO_OF_RUs}+1    1
        ${xml_file}=    Catenate    SEPARATOR=/    ${XML_PATH}    ${NC_SNAPSHOT}_${ncs_index}_AP_1.xml
        ${root}=    Parse XML    ${xml_file}
        @{serial_num}=    Get Elements    ${root}    .//serial-num[1]
        ${serial_num}=           Get Element Text    ${serial_num[0]}
        Append To List    ${serial_oran_list}    ${serial_num}
    END

KPI overall Calculation
    [Arguments]    ${kpi_dict}    ${kpi_list}    ${pm_file}    ${duration}    ${EXECDIR}
    ${kpi_result}=    Evaluate
    ...    wrapper_methods.process_all_kpi(${kpi_dict}, ${kpi_list}, '${pm_file}', ${duration}, '${EXECDIR}')
    ...    wrapper_methods
    Log To Console    ${kpi_result}
    Set Suite Variable    ${kpi_result}
    Append To List    ${Avg_Kpi_Data}    ${kpi_result}
    Set Suite Variable    @{Avg_Kpi_Data}

Fetch and display parameters in real time from the gNB GUI
    [Documentation]    Connects to gNB, fetches parameters using DIST_NAME and PARAM_LIST,
        ...    prints values to console, and stores them in pre_data_dictionary.
        ...    Modified Date: 11-Feb-2026
        ...    Author: rahul.20.singh@nokia.com
    #Should Not Be Empty    ${DIST_NAME}
    #Should Not Be Empty    ${PARAM_LIST}
    Wait Until Keyword Succeeds
    ...    5min
    ...    30sec
    ...    CoamAdmin.Connect To
    ...    bts_host=${GNB_ASIK.Ip}
    ${response}=    CoamAdmin.get_parameter_by_distname
    ...    dist_name=${DIST_NAME}
    ...    parameter_list=${PARAM_LIST}
    ...    timeout=60

    ${first_entry}=    Get From List    ${response}    0
    ${parameters}=     Get From Dictionary    ${first_entry}    parameters
    FOR    ${key}    ${value}    IN    &{parameters}
    ${formatted}=    Evaluate    "{:<35} : {}".format("${key}", "${value}")
    Log To Console    ${formatted}
    END
    Set To Dictionary    ${pre_data_dictionary}    SFP Parameters    ${parameters}
    [Teardown]    CoamAdmin.Teardown

Validate Counter Against Expected Value
    [Arguments]    ${TYPE}
    ${bearer_counter_value}=    Set Variable    ${pm_counter_list[${EXPECTED_${TYPE}_Pos}]}
    ${bearer_value_check}=    Evaluate    (${bearer_counter_value} >= ${EXPECTED_${TYPE}})
    ${bearer_stats}=    Set Variable If    '${bearer_value_check}' == 'True'    True    FAIL
    ${bearer_data}=    Set Variable    "${TYPE}" : "${bearer_counter_value}/${EXPECTED_${TYPE}}"
    Log To Console    ${bearer_data}
    Set Suite Variable    ${bearer_stats}
    Append To List    ${test_verdict}   ${bearer_stats}

Calculate KPI Average
    [Arguments]    ${kpi_data}
    ${avg}=    Evaluate    wrapper_methods.avg_of_kpis(${kpi_data})    wrapper_methods
    [Return]    ${avg}
