*** Settings ***
Library    testsuite/Timisoara/L3/ET/L3_ET_TIM3/resourcesKRK/pm_analyze_listener/listener.py
...    testsuite/Timisoara/L3/ET/L3_ET_TIM3/resourcesKRK/pm_analyze_listener/default_template.yaml    15min

Resource   testsuite/Timisoara/L3/ET/L3_ET_TIM3/resourcesKRK/common_5GC001756.robot

Test Setup    Test Setup Keywords

Test Teardown    Test Teardown KWs


*** Variables ***
${WTS_CONFIG}                       /opt/wts/latest/basic_setup.cfg
${LOG_DIR}                          ${OUTPUT DIR}/Logs/
${WTS_DIR}                          ${LOG_DIR}/WTS/
${WTS_CONFIG_NEW}                   ${WTS_DIR}/basic_setup_mod.cfg
${WTS_LATEST_DIR}                   /opt/wts/latest

*** Test Cases ***
demo_test
    Attach UE    ue_id=1
    Establish PDU Session
    Start Downlink And Uplink Traffic    duration=900 sec
    Sleep    30s

*** Keywords ***
Test Setup Keywords
    Create Directory    ${WTS_DIR}
    Change Edaemon Port    ${WTS_CONFIG}
#    Change Airphone XML Path For Loki WTS
    Configure UTE ETH3
    Reach Onair
    ...    lua_cfg=${WTS_CONFIG_NEW}
    ...    logs_dirpath=${WTS_DIR}
    ...    align_tac_values=False

Test Teardown KWs
    Stop All Traffics
    Deregister UE    ue_id=1
