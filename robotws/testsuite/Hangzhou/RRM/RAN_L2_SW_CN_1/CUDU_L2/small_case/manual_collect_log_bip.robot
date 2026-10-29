*** Settings ***
Documentation
...    to make TA work, actInternalTrace=true, actCli=true
Resource    ./../common_setup_teardown.robot

*** Variables ***
${LOG}    syslog,tti,sherpa,bip,sosreport,apbip,
${LOG_PATH}    ${OUTPUT_DIR}/mylog/
${STOP_CASE_FILE}    /home/ute/delete_me_to_stop_case.txt
*** Test Cases ***
Small Case For Catch Gnb BIP By gnbMirroring Continuously
    [Tags]    6137
    Start GNB BIP Log By gnbMirroring    L2_L1_BIP=true    CPRT_L2RT=false    BB_SLOT_1=true    BB_SLOT_2=true    BB_SLOT_5=false
    ...    NUMBER_OF_FILES=10    FILE_SIZE_MBYTES=100
    Wait Until User Manually Delete Stop Case File
    Stop Gnb BIP Log

Small Case For Catch Gnb BIP Log
    [Tags]    case1
    Start Gnb BIP Log
    Sleep    1s
    Stop Gnb BIP Log

Small Case For Catch Gnb BIP Log Continuously
    [Tags]    case2
    Start Gnb BIP Log
    Wait Until User Manually Delete Stop Case File
    Stop Gnb BIP Log

Small Case For Catch Gnb BIP Log Without Stop Step
    [Tags]    case3
    Start Gnb BIP Log    10s
    Sleep    10s
    Collect BIP Log From FCT By lfs-nw_switch-mirror-tool    ${CURDIR}

Small Case For Catch Gnb And AP Loki BIP Log
    [Tags]    case4
    Start Gnb And Airphone BIP Log On AP Loki Testline
    Wait Until User Manually Delete Stop Case File
    Stop Gnb And Airphone BIP Log On AP Loki Testline    ${CURDIR}

Small Case For Catch Gnb BIP By gnbMirroring Continuously 2
    [Tags]    gnbmirroring_cprt
    Start GNB BIP Log By gnbMirroring    L2_L1_BIP=false    CPRT_L2RT=true
    Online Change One Para With Admin    MRBTS-1/NRBTS-1/NRCELL-1    prachConfigurationIndex    98
    Wait Until User Manually Delete Stop Case File
    Stop Gnb BIP Log

Small Case For Catch Gnb BIP By Shell Script Continuously 3
    [Tags]    shell_scripts_cprt
    Start BIP Log By Shell Script    bip_ASIL_ABIO_fullstack_CPRT_L2RT.sh
    Online Change One Para With Admin    MRBTS-1/NRBTS-1/NRCELL-1    prachConfigurationIndex    98
    Wait Until User Manually Delete Stop Case File
    Stop Gnb BIP Log

Small Case For Catch Gnb BIP By Admin Without Stop Step
    Start GNB BIP By Admin Method    mirroring_time=10
    Sleep    10s
    Collect GNB BIP By Admin Method    ${CURDIR}

Small Case For Catch Gnb BIP By Admin With Stop Step
    Start GNB BIP By Admin Method    mirroring_time=600
    Sleep    10s
    Stop Gnb BIP By Admin Method    ${CURDIR}    #it include Keyword: Collect GNB BIP By Admin Method

Small Case For Catch Gnb BIP By Admin For L1bypass Testline
    Start GNB BIP By Admin Method    mirroring_time=600    interface=L2Hi-L2Lo
    Sleep    10s
    Stop Gnb BIP By Admin Method    ${CURDIR}

*** Keywords ***


