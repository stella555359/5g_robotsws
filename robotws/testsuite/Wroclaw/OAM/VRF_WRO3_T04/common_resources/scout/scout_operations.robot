*** Settings ***
Documentation
...             Common keywords
...             Authors: Michal Wlosek, michal.wlosek@nokia.com
...                      Mariusz Wojcik, mariusz.wojcik@nokia.com

Library   ./scout_operations.py
Library   OperatingSystem
Library   Collections
Resource  ../../common_resources/vm/vm_operations.robot
Library         taf.sw.scout  WITH NAME  scout
Library         taf.sw.reporting_portal

*** Keywords ***
Generate and Send Configuration ID to ReP
    [Documentation]  Sends request to Scout to fetch new SCF. Returns Scout SCF id.
    ...
    ...  +-----------------------+---------+----------------------------------------------------------------------+
    ...  | Variable              | Value   | Description                                                          |
    ...  +=======================+=========+======================================================================+
    ...  | use_scout_internal_id | False   | If you use single run, collected SCF file will be analyzed in Scout  |
    ...  |                       |         | and the analysis will be send to Reporting Portal (default value).   |
    ...  +-----------------------+---------+----------------------------------------------------------------------+
    ...  | use_scout_internal_id | True    | If you want to report outside robot tests. Include returned Scout SCF|
    ...  |                       |         | id in report send to Reporting Portal.                               |
    ...  +-----------------------+---------+----------------------------------------------------------------------+
    ...
    [Arguments]  ${timeout}=600
    Run Keyword and Ignore Error   scout.Teardown Scout Api
    Wait Until Keyword Succeeds    10 min    30 sec    Wait until BTS reach state    state=OnAir
    ${TESTLINE_NAME}=  scout_operations.Get testline name
    ${is_ute_run}  Run Keyword And Return Status  Environment Variable Should Be Set  CM_EXECUTION_ID
    Log Environment Variables
    scout.Setup Scout  scout_testline_name=${TESTLINE_NAME}  environment=production
    ${scout_scf_id}  Run Keyword If  ${is_ute_run}  Wait Until Keyword Succeeds    20 min    60 sec    scout.Request Scf
    ...                                             use_scout_internal_id=${False}  timeout=${timeout}
    ...                                             ELSE  Wait Until Keyword Succeeds    20 min    60 sec    scout.Request Scf
    ...                                             use_scout_internal_id=${True}   timeout=${timeout}
    Run Keyword If  not ${is_ute_run}  taf.sw.reporting_portal.Add To Test Data  data={"tc_execution_id": "${scout_scf_id}"}
    [Teardown]  scout.Teardown Scout Api

Get testline name
    [Documentation]    Getting testline in scout format. In WRO3 4 it is the name as btsName parameter, so value of this parameter is assigned.
    ...                TLs 280 and 281 (TMO US testlines) are exceptions so "if" cases are added.
    ${current_param_value}=    Check current parameter value
    ...                        dist_name=MRBTS-${BTS_ID}
    ...                        param_name=btsName
    ${tl_name}    Set variable    ${current_param_value}[0]
    ${tl_name}     Set variable if    '${tl_name}'=='TMO-2'    7_16_UTE5G281    ${tl_name}
    ${tl_name}     Set variable if    '${tl_name}'=='TMO-1'    7_16_UTE5G280    ${tl_name}
    [Return]    ${tl_name}

Request SCF From Scout And Generate Configuration ID
    [Arguments]    ${vm_address}=192.168.255.126
    ${hostname}=          Get VM Hostname    ${vm_address}
    ${process_status}=    Run                              ps -ef | grep CM_EXECUTION_ID
    ${process_status_to_be_checked}=    Run                              ps -ef
    log  ${process_status_to_be_checked}  console=true
    ${is_ute_run}=        Run Keyword And Return Status    Should Match Regexp    ${process_status}    CM_RESERVATION_ID
    ${scout_scf_id}=      Run Keyword If  ${is_ute_run}    Request SCF From Scout Until Available      ${hostname}
    ...                                                                                                ${False}
    ...                   ELSE                             Request SCF From Scout Until Available      ${hostname}
    ...                                                                                                ${True}
    [Return]              ${scout_scf_id}

Request SCF From Scout Until Available
    [Arguments]    ${hostname}    ${use_internal_id}
    FOR  ${request}  IN RANGE  10
        ${request_status}=    Run Keyword And Ignore Error    request_scf_from_scout    ${hostname}
        ...                                                                             ${use_internal_id}
        ${status}=            Get From List                   ${request_status}         0
        ${scf_id}=            Get From List                   ${request_status}         1
        Exit For Loop If      '${status}' == 'PASS'
    END
    [Return]    ${scf_id}
