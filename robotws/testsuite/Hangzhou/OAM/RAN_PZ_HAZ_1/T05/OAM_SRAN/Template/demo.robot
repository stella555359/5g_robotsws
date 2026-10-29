*** Settings ***
Documentation     [PURPOSE]
#Suite Setup       suite setup
#Suite Teardown    suite teardown
Force Tags        QCD_MN_RAN     QCP_RAN_ST    CA_RAN_PZ_HAZ_1  robot:no-dry-run
Library           Collections
Library           taf.sbts.oam.coam.admin
Library           OperatingSystem
Library           String


*** Variables ***
${lte_states}=    administrativeState=unlocked, operationalState=enabled, blockingState=Unblocked


*** Test Cases ***
Verify BTS Onair
    [Tags]    QC_XX  robot:no-dry-run
    [Setup]    Test setup
    ${LTE_cells_on}    Get status    ${lte_states}  LNCEL
    Run keyword if    ${LTE_cells_on}    Log    LTE cells onair.
    [Teardown]    Test teardown


*** Keyword ***
Get status
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${expected states}: <description>
    ...        ${class name}: <description>
    ...        ${alias}: <description>
    ...
    ...    Returns:
    ...        ${status}: <description>
    ...        ${matching_objects}: <description>
    ...        ${class_ids}: <description>
    [Arguments]  ${expected states}  ${class name}  ${alias}=default
    ${class_ids}=  Get ids for all  ${class name}  alias=${alias}
    ${matching_objects}=  Create list
    ${matching_statuses}=  Create list
    FOR  ${item_id}  IN  @{class_ids}
        ${status}  ${item_parameters}=  Run keyword and ignore error    Assert  ${class name}  ${item_id}
                                                                           ...  ${expected states}
                                                                           ...  timeout=120  alias=${alias}
        Run keyword if
        ...  '${status}'=='PASS'  Run keywords
        ...  Append to list  ${matching_objects}  ${item_parameters}  AND  Append to list  ${matching_statuses}  PASS
        ${iot_cell}=  Run keyword and return status  Should match regexp  ${item_id}  .*BTS_CONF.*SCF.*LNCEL
        Run keyword if  "${status}"=="FAIL" and ${iot_cell}  Append to list  ${matching_statuses}  PASS
        ${status}  ${item_parameters}=  Run keyword if  "${status}"=="FAIL" and not ${iot_cell}
        ...  Run keyword and ignore error  Assert  ${class name}  ${item_id}
                                              ...  availabilityStatus=NotInstalled  timeout=20
        ...  ELSE  Create list  PASS  NONE
        Run keyword if  "${status}"=="FAIL" and not ${iot_cell}  Append to list  ${matching_statuses}  FAIL
    END
    ${status}=  evaluate  "FAIL" if len(${class_ids})!=0 and "FAIL" in "${matching_statuses}" else "PASS"
    [Return]  ${status}  ${matching_objects}  ${class_ids}

Test setup
    [Documentation]    Short description.
    Create 'Test Results Dir' and Set Test Variable_demo
    Start Admin_demo

Start Admin_demo
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${bts_host}: <description>
    ...        ${bts_port}: <description>
    ...        ${username}: <description>
    ...        ${password}: <description>
    ...        ${use_ssl}: <description>
    ...        ${alias}: <description>
    [Arguments]  ${bts_host}=192.168.255.1
    ...    ${bts_port}=443
    ...    ${username}=Nemuadmin
    ...   ${password}=nemuuser
    ...    ${use_ssl}=TRUE
    ...    ${alias}=default
    Log    Trying to connect to admin (max 5 min)    level=INFO    console=${TRUE}
    ${admin_started}=    Run Keyword And Return Status    Wait Until Keyword Succeeds    5 min    15 sec
                                                                ...    taf.sbts.oam.coam.admin.Setup Admin
                                                                ...    bts_host=${bts_host}    bts_port=${bts_port}
                                                                ...    username=${username}    password=${password}
                                                                ...    use_ssl=${use_ssl}    alias=${alias}
                                                                ...    update_interval=1000
                                                                ...    admin_api_log_dir=${Test Results Dir}/

Create 'Test Results Dir' and Set Test Variable_demo
    [Documentation]    Short description.
    ${testtimestamp}=    OperatingSystem.Run    date +%F_%H-%M-%S
    ${testresultspath}=    OperatingSystem.Join Path    ${OUTPUT DIR}    ${testtimestamp}_TEST-${TEST NAME}
    Create Directory    ${testresultspath}
    Set Test Variable    ${Test Results Dir}    ${testresultspath}
    Log  'Test Results Dir' created: ${Test Results Dir}  DEBUG  console=${TRUE}

Test teardown
    [Documentation]    Short description.
    taf.sbts.oam.coam.admin.Teardown All Aliases For Admin
