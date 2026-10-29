*** Setting ***
Documentation
...    author: Cuicui Wang
...    contact: cuicui.wang@nokia-sbell.com
...    Purpose: This file inculde commom suite setup/teardown, test setup/teardowm, suggestion feature team use them

Resource          ${CURDIR}/../../../Krakow_Resources_from_Nanjing/robot/Common.robot
Resource          ${CURDIR}/../../../Krakow_Resources_from_Nanjing/robot/OAM5G_keywords.robot
Resource          taf/rfrl/bts/robot/logs_collecting.robot
Resource          ./DevNJ_asicli.robot
Resource          ./DevNJ_epcsim_setup.robot
Resource          taf/rfrl/common_resources/common_step/interface.robot
Library           OperatingSystem
Library           String
Library           Process
Library           ${CURDIR}/../python/DevNJ_CM_lib


*** Variables ***
${SCF_TEMPLATE_PATH}    ${CURDIR}${/}configuration_file
${FLAG}    ${True}
${tl_type}  ${tl.tl_cloud_topology}
${config_dir}  ${OUTPUT DIR}/config/gnb1/

*** Keywords ***
Common Suite Setup And Setup OAM Env
    [Arguments]    ${subtype}=null    ${FLAG}=True
    DevNJ_common_resource.Common Suite Setup NJI    FLAG=${FLAG}
    Setup OAM Env   ${subtype}    FLAG=${FLAG}
    Setup gNB Btslog Collector

Common Suite Teardown And Restore BTS Configuration Parameters
    [Arguments]    ${FLAG}=True
    Run Keyword If  ${FLAG}==${True}  Run Keyword And Ignore Error  Recover Swconfig File
    Run Keyword and Ignore Error  Teardown gNB Btslog Collector
    Log To Console    Suite Teardown

Common Test Setup And Start To Capture Logs
    Create Test Log Directory
    Start Collecting gNB BtsLog
	Run Keyword If  'DAS' not in '${tl_type}' and 'CDD' not in '${tl_type}'
    ...  Wait Until Keyword Succeeds  6x  20s  Check Only Allowed Alarms Present
    Verify GNB Cells Setup

Common Test Teardown And Stop Capture Logs
    Run Keyword and Ignore Error    Stop Collecting gNB BtsLog  log_dir=${TEST_LOG_DIR}
    Wait Until Keyword Succeeds  20min   30sec   Verify gNB Cells setup
	Run Keyword If  'DAS' not in '${tl_type}' and 'CDD' not in '${tl_type}'
    ...  Wait Until Keyword Succeeds  6x  20s  Check Only Allowed Alarms Present
    Log To Console    \n=====Start: Common step trigger=====
    interface.Common Step Trigger
    Log To Console    \n=====End: Common step trigger=====

Common Suite Setup NJI
    [Arguments]    ${FLAG}
    ${time}    Get Time
    Log To Console    current time is ${time}
    Log To Console    CURDIR=${CURDIR}
    Execute Command On Enb    ls
    Log Variables
    Run Keyword And Ignore Error    Execute Cmd On Pc    df -h ${OUTPUT_DIR}
    Create Suite Log Directory
    Get Testline Info
    Log To Console    \nSetup EPCsim
    Run Keyword If  ${FLAG}==${True}  Setup EPCSim
    Run Keyword If  'DAS' not in '${tl_type}' and 'CDD' not in '${tl_type}'  Run Keywords
    ...  Log To Console    \nPerpare CLI  AND
    ...  Install ASI CLI For UTE Cloud
    [Teardown]    Analyze Failure Of eNB SSH Issue
