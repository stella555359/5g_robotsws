*** Settings ***
Documentation    This File contains all the commmon keywords required for the feature CB008159 counter benchmarking

Library         taf.sbts.oam.coam.admin         WITH NAME    admin
Library         ute_wtssim
Library         ta5g_commissioning              WITH NAME    tcom
Library         Collections
Variables       ta5g_global_var
Library         ute_fsmaccess
Library         ta5g_pm_counters
Library         ${CURDIR}/../../../resources/PythonLib/UTILS.py
#Library         ${CURDIR}/../../../resources/PythonLib/Hanging.py
Resource        ${CURDIR}/../../../resources/Keywords/ap_Keywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/generic_kw.robot
Resource        ${CURDIR}/../../../resources/Keywords/gnb_Keywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/PCMD_Related_KW.robot
Resource        ${CURDIR}/../../../resources/Keywords/tsharkPcapVerifyKeywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/HO_KW.robot
Resource        ${CURDIR}/../../../resources/Keywords/ute_wts_runner.robot
Resource        ${CURDIR}/../../../resources/Variables/common_variables.robot
Resource        ${CURDIR}/../../../resources/Keywords/common_keywords.robot

*** Variables ***
${TOPOLOGY}                              CLOUD_5G_O_E_AP_LOO
${DeltaConfigDir}                        ${CURDIR}/../../config/scf/
${AP_CONFIG_BASIC}                       ${CURDIR}/../../config/wts
${APCONFIGDIR}                           ${CURDIR}/../../config/ap_iphy/
${lua_file}                              ${CURDIR}/../../config/wts/multi_ue_sa_script_int.lua
${INITIAL_CONTEXT_SETUP_PATTERN_UE40}    Initial Context Setup Successful for UE with AMF UE ID \n40
#${INITIAL_CONTEXT_SETUP_PATTERN_UE25}    Initial Context Setup Successful for UE with AMF UE ID \n25
${INITIAL_CONTEXT_SETUP_PATTERN_UE100}    Initial Context Setup Successful for UE with AMF UE ID \n100
${INITIAL_CONTEXT_SETUP_PATTERN_UE110}    Initial Context Setup Successful for UE with AMF UE ID \n110
${UE_IDLE_PATTERN40}                       UE40: IS IDLE
${UE_IDLE_PATTERN100}                       UE100: IS IDLE
${UE_IDLE_PATTERN110}                       UE:110 IS IDLE
${idle_timer}                            90
${counter_json_file}    /home/ute/test_repository/testsuite/Bangalore/RRM/T12/Counter_benchmarking/resources/Keywords/counter_data.json
${host}                                  ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${user}                                  ${tl.gnbs[0].cu.oam_http_connection_details.username}
${password}                              ${tl.gnbs[0].cu.oam_http_connection_details.password}
${port}
${git_path}    https://gitlabe1.ext.net.nokia.com/BTS_TOOLS/counter_benchmarking/-/blob/main/Bangalore/VRF_BLR1/T12/counter.xlsx

*** Keywords ***
Prepare for test Case - CB008159
    [Documentation]     This Keyword is specifically used for setting up testcase for CB008159 counter
    ${Log_Path}    Create Log Directory      CounterBench
    Link SCOUT SCF To Configuration ID For Reporting
    Update BSR Package For RJIO
    Modify the DRBinactivitytimer
    log to console            \nRebooting GNB wait for 360 seconds...
    GNB Reboot
    Sleep   360s
#    Hanging Users Script
    Wait Coam Site to be Ready
    Start UTE WTS                       basic_setup.cfg
    Basic Bring up for gnb
    Get_active_alarms
    [Return]     ${Log_Path}

Modify the DRBinactivitytimer
    [Documentation]       This KW modifies the DRBinactivitytimer at gNB
    admin.Setup admin
    Online NIDD parameter change    paramName=drbInactivityTimerSA            paramValue=${idle_timer}
    ...                             paramDst=MRBTS-1/NRBTS-1
    sleep               60s
    [Teardown]          admin.Teardown admin

Tear Down for test Case - CB008159
    [Documentation]    Test teardown for CB008159
    Get_active_alarms
    Collect Logs For The Test           ${Log_Path}
    Copy Files      ${WTS_WORKING_DIR}/egate_console.log      ${LOG_PATH}
    Run     zip -r ${OUTPUTDIR}/CounterBench.zip ${LOG_PATH}


Basic Bring up for gnb
    [Documentation]     This keyword is for basic bring up the setup it setup config file and then
    ...                 Make sure NG link , X2AP link  and AP cell setup are done to reach on air
    ...                 Arguments passed is the cfg file from config/wts/setupfile.cfg
    [Arguments]         ${config_wts_basic_setup}=basic_setup.cfg
    Start UTE WTS       ${config_wts_basic_setup}
    log to console      \nconfig setup Done
    NG Link Should be UP
    log to console      \nNG link is up
#    X2AP Link Should be UP
#    log to console      X2AP link should be Up
    Sleep               60s

Cell1_MultiUE call with traffic
    [Documentation]       This KW allow multiUEs to connect to TDDcell1
    Pass Lua File_cell1      ${lua_file}

Cell2_MultiUE call with traffic
    [Documentation]       This KW allow multiUEs to connect to TDDcell2
    Pass Lua File_cell2      ${lua_file}

Cell3_MultiUE call with traffic
    [Documentation]       This KW allow multiUEs to connect to FDDcell3
    Pass Lua File_cell3     ${lua_file}

Cell4_MultiUE call with traffic
    [Documentation]       This KW allow multiUEs to connect to FDDcell4
    Pass Lua File_cell4      ${lua_file}

Pass Lua File_cell1
    [Documentation]       This KW shall allow for passing lua file at egate console prompt
    [Arguments]           ${lua_file}
    wtsrunner.Script      file=${lua_file}      entry=start_multiue_call(1,40,1,internal,10000000,10000000,both)
    Read WTS Output For Pattern And Print Matching Lines      ${INITIAL_CONTEXT_SETUP_PATTERN_UE40}     1500
    wtsrunner.Script_stop

#Pass Lua File_cell2
#    [Documentation]       This KW shall allow for passing lua file at egate console prompt
#    [Arguments]           ${lua_file}
#    wtsrunner.Script      file=${lua_file}      entry=start_multiue_call(14,25,1,internal,10000000,10000000,both)
#    Read WTS Output For Pattern And Print Matching Lines      ${INITIAL_CONTEXT_SETUP_PATTERN_UE25}     600
#    wtsrunner.Script_stop

Pass Lua File_cell3
    [Documentation]       This KW shall allow for passing lua file at egate console prompt
    [Arguments]           ${lua_file}
    wtsrunner.Script      file=${lua_file}      entry=start_multiue_call(81,100,1,internal,10000000,10000000,both)
    Read WTS Output For Pattern And Print Matching Lines      ${INITIAL_CONTEXT_SETUP_PATTERN_UE100}     800
    wtsrunner.Script_stop

Pass Lua File_cell4
    [Documentation]       This KW shall allow for passing lua file at egate console prompt
    [Arguments]           ${lua_file}
    wtsrunner.Script      file=${lua_file}      entry=start_multiue_call(101,110,1,internal,10000000,10000000,both)
    Read WTS Output For Pattern And Print Matching Lines      ${INITIAL_CONTEXT_SETUP_PATTERN_UE110}     800
    wtsrunner.Script_stop

Pass Lua File for logflush
    [Documentation]       This KW shall allow for passing lua file at egate console prompt
    [Arguments]           ${lua_file}
    wtsrunner.Script      file=${lua_file}      entry=sim_log_set_flush()
    Sleep    10s

Get gNB SW version
    [Documentation]       This KW fetches SW version from the gNB
    admin.Setup Admin
    ${sw_version}=    get_sw_version
    [Teardown]    admin.Teardown Admin
    [Return]      ${sw_version}

Stop traffic for all UEs and check UEs are in Idle state
     [Documentation]       This KW does UEs to move to idle state
     Pass Lua File_for UE idle Cell 1     ${LUA_FILE}
     Pass Lua File_for UE idle Cell 3     ${LUA_FILE}
#     Pass Lua File_for UE idle Cell 4     ${LUA_FILE}

Validate insession counters for normal and abnormal release
    [Documentation]       This KW validates insession counters after UE becomes idle
    ${start_date}=      Start_Fetching_Counter_Values
    log      ${start_date}
    Sleep   300s
    ${end_date}=      Stop_Fetching_Counter_Values
    log      ${end_date}
    Run Keyword And Continue On Failure    Collect_Counter_Logs      ${host}     ${user}      ${password}
    ...     ${Log_Path}    ${counter_json_file}         ${git_path}

Pass Lua File_for UE idle Cell 1
    [Documentation]       This KW shall allow for passing lua file at egate console prompt
    [Arguments]           ${lua_file}
    wtsrunner.Script      file=${lua_file}      entry=stop_internal_traffic(1,40,1)
    Read WTS Output For Pattern And Print Matching Lines      ${UE_IDLE_PATTERN40}     300
    wtsrunner.Script_stop

Pass Lua File_for UE idle Cell 3
    [Documentation]       This KW shall allow for passing lua file at egate console prompt
    [Arguments]           ${lua_file}
    wtsrunner.Script      file=${lua_file}      entry=stop_internal_traffic(81,100,1)
    Read WTS Output For Pattern And Print Matching Lines      ${UE_IDLE_PATTERN100}     300
    wtsrunner.Script_stop

Pass Lua File_for UE idle Cell 4
    [Documentation]       This KW shall allow for passing lua file at egate console prompt
    [Arguments]           ${lua_file}
    wtsrunner.Script      file=${lua_file}      entry=stop_internal_traffic(101,110,1)
    Read WTS Output For Pattern And Print Matching Lines      ${UE_IDLE_PATTERN110}     300
    wtsrunner.Script_stop

Get_active_alarms
    [Documentation]    This KW fetches active alarms from gNB
    admin.Setup Admin
    ${active_alarm}    admin.get_active_alarms
    [Teardown]    admin.Teardown Admin
    Log    ${active_alarm}

Hanging Users Script
    [Documentation]
    ...  This KW runs Hanging.py script and will fail if RC is not equal 0 or stdout does not
    ...  match '^No hanging users detected.*'.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  This KW runs Hanging.py script and will fail if RC is not equal 0 or stdout does not
    ...  match '^No hanging users detected.*'. Script Hanging.py is used to detect if any
    ...  hanging users/resources are left on BTS. This KW requires global variable
    ...  'HANGING_SCRIPT_PATH'. As a result of this KW a few files are created:
    ...  'hanging_resource_check_<timestamp1>.log.raw', 'hanging_resource_check_<timestamp1>.log',
    ...  'hanging_stderr_<timestamp2>.txt', 'hanging_stdout_<timestamp2>.txt'.
    ...
    ...  **Input Parameters:**
    ...
    ...  +---------------------+------+---------------------------------------------------------------------------+
    ...  | Parameter           | Man. | Description                                                               |
    ...  +=====================+======+===========================================================================+
    ...  | log_directory       | No   | Absolute path to directory where logs from script will be saved.          |
    ...  +---------------------+------+---------------------------------------------------------------------------+
    ...  | hanging_script_path | No   | Absolute path to Hanging.py script. Default value:                        |
    ...  |                     |      | ${CURDIR}/../testsuite/SBTS/test_resources/IWK/resources/Hanging.py       |
    ...  +---------------------+------+---------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Run Hanging Users Script

    [Arguments]  ${log_directory}=${Log_Path}
    ...  ${hanging_script_path}=${CURDIR}/../../../resources/PythonLib/Hanging.py
    Log  Hanging users script will be run from: ${HANGING_SCRIPT_PATH}  console=True
    ${timestamp} =  Get Time
    ${script_result} =  Run Process  python  ${HANGING_SCRIPT_PATH}  cwd=${log_directory}
    ...  stdout=${log_directory}/hanging_stdout_${timestamp}.txt  stderr=${log_directory}/hanging_stderr_${timestamp}.txt
    ...  timeout=1min  alias=hanging_script
    Should Be True  ${script_result.rc} == 0  msg=A problem with hanging.py script occured.
    Should Match Regexp  ${script_result.stdout}  ^No hanging users detected.*  msg=A problem related to hanging users occured.
    Log to console  Hanging users script executed.
    [Teardown]  Terminate Process  handle=hanging_script

