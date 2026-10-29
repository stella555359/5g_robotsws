*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com   lei.nie@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
Upgrade_to_Target_build_and_check_default_value
    ${para_details}   COAM WEBUI Get Parameter Details
    ...   dist_name=${MO_NAME}/MNL-1/AMGR-1
    ...   filter_param=Enable default password alarm
    ...   abbr=enableDefaultPasswdAlarm
    ${default_value}   Set Variable   ${para_details['Default value']}
    ${description}   Set Variable   ${para_details['Description']}
    Should Be Equal As Strings   ${default_value}   false
    ${dcuser}   Run Keyword And Return Status   Should Contain   ${description}   dcuser
    ${only_sran}   Run Keyword And Return Status   Should Contain   ${description}   only in SRAN
    Should Be True   not ${dcuser} or ${only_sran}
    Should Contain   ${description}   Local Operator System Administrator
    Should Contain   ${description}   Root Service User
    Should Contain   ${description}   Non-root Service User

Case Setup 001
    Common Setup
    COAM WEBUI Login

Case Teardown 001
    Run Keyword And Ignore Error   COAM WEBUI Logout
    Run Keyword And Ignore Error   COAM Logout
    Check Extra Reset From Blackbox
    CI_interface.Common Case Teardown
