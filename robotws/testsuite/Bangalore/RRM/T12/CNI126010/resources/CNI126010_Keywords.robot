*** Settings ***
Library         BuiltIn
Library         Collections
Library         OperatingSystem
Library         Process
Library         String
Library         XML
Library         re
Library         taf.sbts.oam.coam.admin         WITH NAME    admin
Library         taf.sw.syslog       WITH NAME   slog
Variables       ta5g_global_var
Resource        ${CURDIR}/../../resources/Keywords/generic_kw.robot
Resource        ${CURDIR}/../../resources/Keywords/gnb_Keywords.robot
Resource        ${CURDIR}/../../resources/Keywords/tsharkPcapVerifyKeywords.robot
Resource        ${CURDIR}/../../resources/Keywords/ute_wts_runner.robot
Resource        ${CURDIR}/../../resources/Keywords/ap_Keywords.robot
Resource        ${CURDIR}/../../resources/Keywords/common_keywords.robot
Resource        ${CURDIR}/../../resources/Variables/common_variables.robot
Documentation      Feature Related all common Keywords related to Feature.


*** Variables ***
${AP_CONFIG_BASIC}         ${CURDIR}/../config/wts
${DELTACONFIGDIR}      ${CURDIR}/../config/scf
${rd_parametrs}    0x6601E0=2;0x6601E1=0;0x58057A=4;0x58057F=262223;
...    0x5A00A4=1;0x5A00A5=1;0x5A0609=1;0x5A0610=1;0x5B023E=1;0x5B0234=1;0x5B0609=1;0x5B0610=1


*** Keywords ***
Prepare For TC01
    [Documentation]    Prepare For CNI126010
    ${Log_Path}    Create Log Directory    CNI126010
    Link SCOUT SCF To Configuration ID For Reporting
    Update BSR Package For RJIO
    Run    sudo ip addr add 10.0.1.101/24 dev eth3
    Run    sudo ip addr add 10.0.1.102/24 dev eth3
    GNB Delta Commission        ${DELTACONFIGDIR}/Delta_TC1.json
    Sleep       60s
    Add RD Parameters Directly On GNB    ${rd_parametrs}
    Gnb Reboot
    Sleep    360s
    Wait Coam Site To Be Ready
    Start UTE WTS     basic_setup_126010_MultiUE.cfg
    NG Link Should Be UP
    Sleep    60s
    Wait Coam Site To Be Ready

Teardown For TC01
    [Documentation]    Tear down for the case
    Snapshot Collection     ${Log_Path}     Snapshot.zip
    Collect Logs For The Test        ${Log_Path}
    Copy Files      ${WTS_WORKING_DIR}/egate_console.log      ${LOG_PATH}
    Run     zip -r ${OUTPUTDIR}/CNI126010.zip ${LOG_PATH}
    log to console      \nReverting sw config file in GNB...
    Delete Added RD Parameters From GNB   ${rd_parametrs}
    Gnb reboot
    Sleep    360s
    Wait Coam Site To Be Ready

Start and Validate DL Traffic
    [Documentation]    start DL traffic
    [Arguments]      ${UE_ID}=${UE_ID}    ${dl_rate}=10
    Log to Console    \nRunning DL Traffic
    wtsrunner.Trf Data Start     ue=${UE_ID}    pdu=1   qfi=1    dir=dl    mbps=${dl_rate}
    ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=UDP DL TRF: .*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    ${output}
