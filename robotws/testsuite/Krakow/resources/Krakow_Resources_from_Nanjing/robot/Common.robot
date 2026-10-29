*** Settings ***
Documentation    Suite description

Library    taf.ul.sc.tl_config.TestLineConfiguration
Library    ../python/common.py
Library    taf.ul.sc.hub.Hub                     WITH NAME    Hub
Library    taf.ul.sc.gnb.airscale.AirScale    oam_ip=${tl.gnbs[0].cu.oam_http_connection_details.addr}    WITH NAME    AirScale
Library    taf.ul.sc.gnb.oam.rest.CommonOAM    oam_ip=${tl.gnbs[0].cu.oam_http_connection_details.addr}     WITH NAME    RestAPI
Library    taf.ul.sc.gnb.oam.selenium.CoamSelenium   WITH NAME    SeleniumAPI
Library    taf.ul.sc.syslog.Syslog               WITH NAME    Syslog
Library    taf.ul.sc.asimgr.AsiMgr               WITH NAME    AsiMgr
Resource   taf/rfrl/bts/robot/logs_collecting.robot
Resource   taf/rfrl/common_resources/common_step/interface.robot

*** Variables ***
${config_dir}=  ${OUTPUT DIR}/config/gnb1/
${debug_dir}=  ${OUTPUT DIR}/debug/gnb1/


*** Keywords ***
OAM Setup
    Connect To All Devices
    Set Suite Variables

Connect To All Devices
    AirScale.Connect To Gnb
    Hub.Connect To Hub
    #Syslog.Connect To Syslog
    Setup Logs Collectors
    AsiMgr.Connect To AsiMgr

OAM Teardown
    Run Keyword and Ignore Error  Teardown gNB Btslog Collector
    Log To Console    Suite Teardown

Preconditions
    Start Collecting gNB BtsLog
    Set Actasi To True If False   ${config_dir}
    Wait For OnAir
    Check Only Allowed Alarms Present
    Verify GNB Cells Setup

Check ASiR Container Status
    [Documentation]    Get the asi container id automatically, then check its status whether to be up
    ${container_id}  Wait Until Keyword Succeeds  3 min  30s  AirScale.Get Asi Container Id
    Wait Until Keyword Succeeds   2 min    30s    Wait For Container To Get Up    name=${container_id}

Postconditions
#    Run Keyword If Test Failed    RestAPI.Collect Snapshot    ${debug_dir}
#    Save ASiR Snapshot
    Run Keyword and Ignore Error    Stop Collecting gNB BtsLog
    Check ASiR Container Status
    Wait For OnAir
    #Verify gNB Cells setup
    Wait Until Keyword Succeeds  6min   30sec   Verify GNB Cells setup
    Check Only Allowed Alarms Present
    Log To Console    \n=====Start: Common step trigger=====
    interface.Common Step Trigger
    Log To Console    \n=====End: Common step trigger=====

Set Suite Variables
    ${required_variables}=    Get Oam Variables    ${CURDIR}/../
    Set Required Suite Variables    ${required_variables}

Postconditions With Selenium
    Run Keyword And Ignore Error  Wait Until Keyword Succeeds  2min  30sec  Logout via Selenium
    Postconditions

Postconditions For Hub Lock
    SeleniumAPI.unlock_hub_via_selenium
    Run Keyword And Ignore Error  Wait Until Keyword Succeeds  2min  30sec  Logout via Selenium
    Postconditions

Preconditions For Hub Unlock
    Preconditions
    Connect To Webui Via Selenium
    SeleniumAPI.block_hub_via_selenium
