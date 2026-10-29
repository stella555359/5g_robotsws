*** Settings ***
Documentation
...    Author: Yang Mengli
...    Contact: mengli.yang@nokia-sbell.com
...    this file is upgrade Ap for local env,you can use it in your case directly.
...    Please do not modify the file without notification to author


#Suite Setup    Common Suite Setup For AIC
#Suite Teardown    Common Suite Teardown For AIC

Force Tags
...      CRT             #Tag Item
...      RAN_PZ_HAZ_1             #Competence Area
...      RAN_PZ_HAZ1_SG03_ST_RRM  #Organization
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout    600 minutes

Resource          ../../Resources/Cloud/AIC_Common_Resource.robot
Resource          ../../T02/Common_Case/common_resource_new.robot



*** Test Cases ***
AP Upgrade For ENV 248
    [Tags]        ap248
    [Documentation]
    ...    Author: mengli.yang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
#    [Setup]        Case Precondition
    ${AP_BUILD_NAME}    Get AP Build Name From UTE Cloud
     Config Iphy Ip For Local Env_248    ap_version=${AP_BUILD_NAME}
#    [Teardown]        Case Postcondition

AP Upgrade For ENV 250
    [Tags]        CRT      ap250
    [Documentation]
    ...    Author: mengli.yang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
#    [Setup]        Case Precondition
     ${AP_BUILD_NAME}    Get AP Build Name From UTE Cloud
     Config Iphy Ip For Local Env_250
#    [Teardown]        Case Postcondition

*** Keywords ***
Case Precondition
    log to console    Case Precondition
    Common Test Setup For AIC
    ${vdu_hostname_dict}    ${vdu_username_dict}    ${vdu_password_dict}    ${vdu_ns_dict}
    ...                                               Get SSH Connection Infor For Multiple vDU With Different vCU
    Set Test Variable    ${vdu_hostname_dict}
    Set Test Variable    ${vdu_username_dict}
    Set Test Variable    ${vdu_password_dict}
    Set Test Variable    ${vdu_ns_dict}
    ${vcu_hostname_list}  ${vcu_username_list}  ${vcu_password_list}  ${vcu_ns_list}
    ...                                               Get SSH Connection Infor For Multiple vCU K8s Master
    Set Test Variable    ${vcu_hostname_list}
    Set Test Variable    ${vcu_username_list}
    Set Test Variable    ${vcu_password_list}
    Set Test Variable    ${vcu_ns_list}
    ${NEW_PLAN_NAME}     Get Test Case Name
    Set Test Variable    ${NEW_PLAN_NAME}

Case Postcondition
    log to console    Case Postcondition
    Common Test Teardown For AIC
    run keyword and ignore error  Stop Wireshark Log    container_name=nwmgmt    pod_name=cpif    NE=vCU
    ...                                                 vcu_log_name=vcu_wireshark
    run keyword and ignore error  Detach UE    ue_index=0
