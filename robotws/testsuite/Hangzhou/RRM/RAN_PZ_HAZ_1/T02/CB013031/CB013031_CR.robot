*** Settings ***

Documentation
...    Author: jim.3.liu
...    Contact: jim.3.liu@nokia-sbell@nokia-sbell.com
...    This is a robot scripts for Jim CB013031 SR part

Force Tags
...      TRUNK             #Tag Item
...      CA_RAN_PZ_HAZ_1             #Competence Area
...      RAN_PZ_HAZ1_SG02_ST_RRM  #Organization
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout           6h

Suite Setup       Common Suite Setup For RRM
Suite Teardown    Common Suite Teardown For RRM

Resource    ../../Resources/Classical/RRM_Common_Resource.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/Module/Module.robot


*** Variables ***

${was_host}            10.99.113.46
${was_user}            omc
${was_password}        Medsql!_1893
${PLAN_NAME}           Disable_CB013031_Plan
${PLAN_DESCRIPTION}    For CB013031 Test
${MRBTS_ID}            37469
${DIST_NAMES}          PLMN-PLMN/MRBTS-37469
${MO_ADDR}             PLMN-PLMN/MRBTS-37469/MNL-1/MNLENT-1/FEATCADM-1

*** Test Cases ***

[TC01]CB013031_CR_01_Delta_or_full_configuration_plan_Parameters_calculation_check_in_NMS
    [Tags]    QC_235164    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: jim.3.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    08.10.2024,jim.3.liu@nokia-sbell.com, draft
    [Setup]    Case Precondition
    Function of CB013031    true
    [Teardown]    Case Postcondition


# [TC34]CB013031_SR_34_Detailed Panel for Parameter Check
#     [Tags]    QC_203510    QCD_MN_RAN      QCP_RAN_VRF
#     [Documentation]
#     ...    Author: jim.3.liu@nokia-sbell.com
#     ...    history change: <date>,<who>,<what and how>
#     ...    08.10.2024,jim.3.liu@nokia-sbell.com, draft
#     [Setup]    Case Precondition

#     [Teardown]    Case Postcondition

*** Keywords ***

Setup NetAct
    netact.Add Node    cmwas    ${was_host}    ${was_user}    ${was_password}    alias=netrc_server
    ${web_url}=    netact.Detect WEB URL    alias=netrc_server
    netact.Add WEB URL    ${web_url}    ${was_user}    ${was_password}    alias=netrc_server

Teardown NetAct
    netact.Delete Node    cmwas     alias=netrc_server
    netact.Clean All     alias=netrc_server

Get Actual Configuration MO Data
    [Arguments]    ${mo_id}
    ${actual_conf}=    netact.Get Actual Configuration    alias=netrc_server
    ${managed_object}=    netact.Get Managed Object    ${actual_conf}    ${mo_id}    alias=netrc_server
    Log    \nManaged Object: ${managed_object}    console=${TRUE}
    Log    Meta Class: ${managed_object.meta_class}    console=${TRUE}
    Log    Meta Version: ${managed_object.meta_version}    console=${TRUE}
    Log    Parameters: ${managed_object.parameters}    console=${TRUE}
    [RETURN]    ${managed_object.meta_class}     ${managed_object.meta_version}    ${managed_object.parameters}

Function of CB013031
    [Arguments]    ${actCACVAS}
    [Documentation]    Disable or Enable CB013031 verified by jim 250903
    ${mo_id}=    Set Variable    PLMN-PLMN/MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    Run Keyword And Ignore Error    netact.Delete Plan    ${PLAN_NAME}    alias=netrc_server
    ${plan_conf}=    netact.Create Plan Configuration    ${PLAN_NAME}    ${PLAN_DESCRIPTION}    alias=netrc_server
    ${meta_class}     ${meta_version}    ${parameters}=    Get Actual Configuration MO Data   ${mo_id}
    ${managed_object}=    netact.Create Managed Object    ${plan_conf}    ${meta_class}    ${meta_version}    ${mo_id}    CREATE
    ...                                            alias=netrc_server    actCondAutoConfValCalc=${actCACVAS}
    Log    Managed Object: ${managed_object}    console=${TRUE}
    Log    para value: ${managed_object.parameters['actCondAutoConfValCalc']}    console=${TRUE}
    netact.Edit Managed Object    ${managed_object}    UPDATE    actCondAutoConfValCalc=${actCACVAS}
    Log    para value: ${managed_object.parameters['actCondAutoConfValCalc']}    console=${TRUE}
    netact.Provision Plan    ${PLAN_NAME}    backup_plan_name=${PLAN_NAME}-backup
    ...               create_backup_plan=${TRUE}    provisioning_operation=preactivate    alias=netrc_server
    netact.Validate Plan    ${PLAN_NAME}    alias=netrc_server
    netact.Activate Preactivated Plan    ${PLAN_NAME}    alias=netrc_server
    netact.Delete Managed Object    ${managed_object}
    Run Keyword And Expect Error    ManagedObjectNotFound*    netact.Get Managed Object    ${plan_conf}    ${mo_id}    alias=netrc_server
    [Teardown]    netact.Delete Plan Configuration    ${plan_conf}

Run Provision
    ${operation_id}=    netact.Start SWM Operation    operation_type=provision    dist_names=${DIST_NAMES}
    ...                                        package=${SW_VERSION}    alias=netrc_server
    ${progress}=    netact.Get Progress Of SWM Operation    ${operation_id}    alias=netrc_server
    Log    \nProgress: ${progress}    console=${TRUE}
    netact.Wait For SWM Operation    ${operation_id}    timeout=1800    alias=netrc_server
    netact.Upload SW    ${DIST_NAMES}    alias=netrc_server
    ${status}=    netact.Get MO Status    ${DIST_NAMES}    alias=netrc_server
    Log    Status: ${status}    console=${TRUE}\

Rollback SW Process
    netact.Rollback SW    ${DIST_NAMES}    alias=netrc_server
    netact.Upload SW    ${DIST_NAMES}    alias=netrc_server
    ${status}=    netact.Get MO Status    ${DIST_NAMES}    alias=netrc_server
    Log    \nStatus: ${status}    console=${TRUE}

Case Precondition
    log to console    Case Precondition
    Common Test Setup For RRM

Common Test Setup For RRM
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${tc_name}=    Replace String    ${TEST_NAME}    ${SPACE}    _
    ${case_log_path}    Join path    ${SUITE_LOG_DIRECTORY}    ${tc_name}_${timestamp}
    Set Suite Variable    ${TEST_LOG_DIRECTORY}    ${case_log_path}
    Create directory    ${TEST_LOG_DIRECTORY}

Common Suite Setup For RRM
    _Create Suite Directory
    Run Keyword And Ignore Error    Get Testline Type
    Run Keyword And Ignore Error    Get TestLine Name
    Run Keyword And Ignore Error    Get Expect Sw Version
    Setup NetAct

Common Suite Teardown For RRM
    Teardown NetAct

Case Postcondition
    log to console    Case Postcondition
    Run Keyword And Ignore Error    Get SCF Internal Id By Scout    no_ute=${False}