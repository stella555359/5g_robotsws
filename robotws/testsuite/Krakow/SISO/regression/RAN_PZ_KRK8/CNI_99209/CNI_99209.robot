*** Settings ***
Documentation
...                 author/contact: Hubert Kowalczyk / hubert.kowalczyk@nokia.com
...                 maintainer/contact: Hubert Kowalczyk / hubert.kowalczyk@nokia.com
...                 Implementation of tests 04 and 07 for feature CNI_99209

Library             resources/CNI_99209_Keywords.py
Resource            taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource            taf/rfrl/bts/robot/gnb.robot
Resource            resources/CNI_99209_Keywords.robot
Variables           taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup         Suite Setup
Suite Teardown      Suite Teardown
Test Setup          Test Setup
Test Teardown       Test Teardown

Force Tags          RF50

*** Variables ***
@{CUSTOM_ALLOWED_ALARMS}
...    No X2 link available
...    No X2 link available for a specific LTEENB
...    Diagnostic Files collected
...    High memory consumption
...    GNSS satellite visibility degraded
${ne3s_user}    wsuser
${ne3s_default_password}    A0zY~rP#8Mx@
${hub_username}    toor4nsn
${hub_default_password}    oZPS0POrRieRtu
${hub_ip}    172.16.37.128
${bts_mplane_ip}    ${tl.gnbs[0].dus[0].oam_ip.v4.split('/')[0]}
${bts_username}    toor4nsn
${bts_password}    oZPS0POrRieRtu
${EMSSIM_download_link}    http://files.ute.nsn-rdnet.net/emssim/debs/emssim_4.54.0_amd64.deb

*** Test Cases ***

[1][1.0] CNI-99209_ET_04_CNUM_ASiR_NE3s_User_password_rules_verify
    Log    Setting invalid password    console=${True}
    Run Keyword And Retry On Error    Open asir login page    attempts=${3}
    ${invalid_password}=    Set variable    invalidpassword
    Enter account settings
    Run Keyword And Expect Error    *    Set Ne3s user account password    ${invalid_password}
    ${errors}=    Get validation errors
    Parse validation errors    ${errors}
    Sleep    5s
    Log    Setting new valid password    console=${True}
    ${ne3s_password}=    generate_valid_password
    Enter account settings
    Set Ne3s user account password    ${ne3s_password}
    Sleep    5s
    Log    Checking if new password works    console=${True}
    Run EMSSIM NE3S Activation and deactivation    ${ne3s_user}    ${ne3s_password}
    Log    Checking if old password doesn't work    console=${True}
    Run Keyword And Expect Error    *    Run EMSSIM NE3S Activation and deactivation    ${ne3s_user}    ${ne3s_default_password}
    Log    Resetting password to default    console=${True}
    Enter account settings
    Reset Ne3s user account password
    Sleep    5s
    Log    Checking if default password works    console=${True}
    Run EMSSIM NE3S Activation and deactivation    ${ne3s_user}    ${ne3s_default_password}
    Log    Checking if previously set new password doesn't work    console=${True}
    Run Keyword And Expect Error    *    Run EMSSIM NE3S Activation and deactivation    ${ne3s_user}    ${ne3s_password}

[1][1.0] CNI-99209_ET_07_ASiR_Hub_User_password_apply_after_ASiR_config_reset_and_then_rollback
    Log    Setting new password    console=${True}
    Run Keyword And Retry On Error    Open asir login page    attempts=${3}
    ${hub_password}=    generate_valid_password
    Enter account settings
    Set Hub user account password    ${hub_password}
    Sleep    15s
    Log    Checking if new password works    console=${True}
    Attempt ASIR Connection    ${hub_password}
    Log    Checking if old password doesn't work    console=${True}
    Run Keyword And Expect Error    *    Attempt ASIR Connection    ${hub_default_password}
    Log    Resetting config and password storage    console=${True}
    Perform config reset inlcuding ASI password storage
    Logout of asir webem
    Log    Logging out of ASIR webem    console=${True}
    Sleep    300s
    Perform asir scf recommissioning
    Log    Waiting for onair    console=${True}
    Wait For Site To Be Onair
    Log    Performing software rollback    console=${True}
    Perform software rollback
    Log    Checking if default password works    console=${True}
    Attempt ASIR Connection    ${hub_default_password}
    Log    Checking if previously set new password doesn't work    console=${True}
    Run Keyword And Expect Error    *    Attempt ASIR Connection    ${hub_password}
    fix_bts_connection
