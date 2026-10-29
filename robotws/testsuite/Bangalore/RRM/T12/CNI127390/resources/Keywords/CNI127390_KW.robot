*** Settings ***
Documentation    This contains the Keywrods specific to the Feature CB011006.
Library        BuiltIn
Library        Collections
Library        String
Library        OperatingSystem
Library        taf.sbts.oam.coam.admin         WITH NAME    admin
Library        taf.collectors.core    WITH NAME    core
Library        taf.collectors.btslog  WITH NAME   btslog
Library        ute_fsmaccess
Library        ta5g_pm_counters
Library        taf.analyzer.pcap    WITH NAME    cap
Variables      ta5g_global_var
Library         ${CURDIR}/../../../resources/PythonLib/UTILS.py
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
${MRBTS_DISTNAME}       MRBTS-1
${DELTACONFIGDIR}       ${CURDIR}/../../config/gnb_scf/
${APCONFIGDIR}          ${CURDIR}/../../config/ap_iphy/
${TOPOLOGY}             CLOUD_5G_O_E_AP_LOO
${TARGET_CELLS}         1
${LOG_DIR}              /home/ute/logs
${rad_parameter}        0x58057A=4;0x58057F=0x1800;0x5809B8=1
${AP_CONFIG_BASIC}      ${CURDIR}/../../config/wts


*** Keywords ***
Common Test Case Tear Down LO AP LO
    [Documentation]    Tear Down for Test Case to collect logs and making site updated with LO_AP_LO SCF And Iphy up
    Delete Basic Interface On UTE
    Collect Logs For The Test           ${LOG_PATH}

Prepare Test Case For CNI127390_B
    [Documentation]    Preparing Common test Setup for TestCases CNI127390_B
    ${LOG_PATH}     Create Log Directory       CNI127390
    Link SCOUT SCF To Configuration ID For Reporting
    Set Test Variable        ${LOG_PATH}
    Create Basic Interface On UTE
    Update BSR Package For RJIO
    GNB Delta commission     ${CURDIR}/../../config/gnb_scf/Delta_Feature_Enable.json
    Add RD Parameters Directly On GNB      ${rad_parameter}
    Sleep   10s
    GNB Reboot
    Sleep   360s
    Wait Coam Site To Be Ready
    Start UTE WTS      basic_setup.cfg
    Sleep   180s
    Basic Bring Up for rjio

Prepare Test Case For CNI127390_A
    [Documentation]    Preparing Common test Setup for TestCases CNI127390_A
    ${LOG_PATH}     Create Log Directory       CNI127390
    Link SCOUT SCF To Configuration ID For Reporting
    Set Test Variable        ${LOG_PATH}
    Create Basic Interface On UTE
    Update BSR Package For RJIO
    Sleep   10s
    GNB Reboot
    Sleep   360s
    Wait Coam Site To Be Ready
    Start UTE WTS      basic_setup.cfg
    Sleep    180s
    Basic Bring Up for rjio

Make SA Call
    [Documentation]    For SA Call UE Register is done for L3 Call
    [Arguments]    ${UE_ID}=${UE_ID}    ${GW_ID}=${GW_ID}
    Enable Internal TG      ${UE_ID}    1
    UE Register Should Be Successful For SA     ${UE_ID}    ${GW_ID}
    Sleep   10s

Validate GHOSTUERELEASE in SYSLOG
    [Documentation]    This KW is to verify UE is suspended for scheduling with cause GhostUErelease in Syslog
    ${result}    OperatingSystem.Run        if (grep -q "GHOSTUERELEASE" ${LOG_PATH}/btslog2/*.LOG) ; then echo 0; fi
    Run Keyword If    "${result}" == "0"    log to console  Syslog Validation Pass
    Run Keyword If   "${result}" != "0"    FAIL    Syslog Validation Fail

Validate rrcDelay in SYSLOG
    [Documentation]    This KW is to verify rrdelay in Syslog
    ${result}    OperatingSystem.Run    grep -q "rrcDelay" /home/ute/logs/CNI127390/btslog2/* && echo 0
    Run Keyword If    "${result}" == "0"    log to console  Syslog Validation Pass
    Run Keyword If   "${result}" != "0"    FAIL    Syslog Validation Fail

Suite teardown for 127390
    RAT Block Unblock
    Common Suite Teardown

Start Btslogs From Local Machine
    [Documentation]    path from where to get btslog files default value: "/tmp/btslog2"
    [Arguments]    ${log_alias}
    btslog.create_btslog_collector    ${log_alias}
    core.setup_collectors     ${log_alias}
    core.start_collectors     ${log_alias}
    core.Set Suite Alias    ${log_alias}

Stops Btslogs From Local Machine
    [Documentation]    path from where to get btslog files default value: "/tmp/btslog2"
    [Arguments]    ${log_alias}
    Run Keyword And Continue On Failure     core.stop_collectors      names=${log_alias}
    Run Keyword And Continue On Failure     core.collect_collectors      names=${log_alias}
    Run Keyword And Continue On Failure    core.teardown_collectors      names=${log_alias}

Basic Bring Up for rjio
    [Documentation]       This keyword is for basic Ng and AP cell setup
    NG Link Should Be UP
    Sleep   60s

Validate rrccontainertype in logs
    [Documentation]    This KW is to verify rrdelay in Syslog
    ${result}    OperatingSystem.Run    grep -q "rrcReconfigurationOthers" /home/ute/logs/CNI127390/btslog2/* && echo 0
    Run Keyword If    "${result}" == "0"    log to console  Syslog Validation Pass
    Run Keyword If   "${result}" != "0"    FAIL    Syslog Validation Fail
