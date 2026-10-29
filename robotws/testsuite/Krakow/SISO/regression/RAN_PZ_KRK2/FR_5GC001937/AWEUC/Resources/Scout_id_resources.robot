*** Settings ***
Documentation  File contains Robot keywords to assist in performing common tests
...            author: Patryk Lamch, patryk.lamch@nokia.com
...            maintainer: Patryk Lamch, patryk.lamch@nokia.com

Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    taf/rfrl/bts/robot/common/gnb_ru.robot
Library     taf.sw.scout    WITH NAME    scout
Library     ../automated_reporter.py

*** Variables ***
${USE_SCOUT_INTERNAL_ID}              False

*** Keywords ***
Get Testline Name
    [Documentation]    This keyword get name TL from Configuration
     ...
     ...       **Example:**
     ...       | Get Testline Name

    ${testline_name_list}=  taf.rfrl.utilities.tl_config.get_configuration
    ${testline_name}=   Get From List   ${testline_name_list}   1
    [Return]   ${testline_name}

Request Scout SCF
    [Documentation]    This keyword get external_scf_id from Scout
    [Arguments]   ${scout_testline_name}

    scout.setup_scout  scout_testline_name=${scout_testline_name}
    ${is_cm_execution}=    Is CM Execution
    ${USE_SCOUT_INTERNAL_ID}=    Set Variable If
    ...                          ${is_cm_execution}==${True}    ${False}
    ...                          ${is_cm_execution}==${False}    ${True}
    ${scf_id}=    scout.request_scf   use_scout_internal_id=${USE_SCOUT_INTERNAL_ID}
    scout.teardown_scout_api
    [Return]   ${scf_id}

Refresh SCF ID
    [Documentation]    This keyword Report To RePo With Execution ID
    ${scout_testline_name}=   Get Testline Name
    ${scf_id}=                Request Scout SCF   ${scout_testline_name}
    ${is_cm_execution}=       Is CM Execution
    Run Keyword If    ${is_cm_execution}==${False}
    ...     add_tc_exec_id_to_test    tc_exec_id=${scf_id}
