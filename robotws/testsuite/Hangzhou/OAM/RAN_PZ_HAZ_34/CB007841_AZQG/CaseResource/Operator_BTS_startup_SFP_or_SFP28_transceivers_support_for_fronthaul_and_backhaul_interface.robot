*** Settings ***
Documentation
...  author : liang.6.chen@nokia-sbell.com
...  contact: liang.6.chen@nokia-sbell.com

Resource          ../Resource/Common.robot
Resource          ../Resource/CB007841_common_keywords.robot
Variables         ../Resource/CB007841_modify_para.py
Library           taf.hw.optical_switch    WITH NAME    fiberswitch
Library           taf.selenium.sbts    WITH NAME    selenium_coam
Library           XML     use_lxml=True
Library           Collections
Library           String
Library           OperatingSystem
Library           taf.transport.ssh         WITH NAME    ssh
Library           taf.config.scf.interface.scf     WITH NAME   scf
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot

*** Variables ***

*** Keyword ***
Operator_BTS_startup_SFP+_or_SFP28_transceivers_support_for_fronthaul_and_backhaul_interface
    Set SFPWhiteList File Name
    Create dir
    Download whitelist file
    Delete parameter in sfpwhitelist    sfp_model=AOXC
    Delete parameter in sfpwhitelist    sfp_model=AOXD
    Delete parameter in sfpwhitelist    sfp_model=AOSD
    Delete parameter in sfpwhitelist    sfp_model=FOTB
    Upload whitelist file    upload_whitelist_path=${SFPwhitelist_PATH}${SFPwhitelist_NAME}
    Reset DU
    sleep    10s
    run keyword and ignore error    check fault 4657
    Check All SFP availability status    Degraded
    change sfpOperatorMode to true
    sleep    2s
    run keyword and continue on failure    check none fault 4657
    Check All SFP availability status    Online
    sleep    60s
    Check All SFP availability status    Online
    Reset DU
    run keyword and continue on failure    check none fault 4657
    sleep    10s
    Check All SFP availability status    Online
    sleep    5s
    change sfpOperatorMode to false
    sleep    20s
    run keyword and ignore error    check fault 4657
    sleep    2s
    Check All SFP availability status    Degraded
    sleep    60s
    Check All SFP availability status    Degraded

Case Setup: SFP_validation
