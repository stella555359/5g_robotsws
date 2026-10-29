*** Settings ***
Resource          ./../Resources/5GC00xxxx_keywords.robot


Documentation    Suite description
...   author: xxxx
...   contact: xxxx@nokia-sbell.com
...   squad group: MMW_SG1
...   Feature 5GC00xxxx

Force Tags    5G_RRM
...   PY27
Suite Setup     Suite common setup preparation
...     scf_modify_parameters=${MODIFY_SCF_TEMPLATE}
Suite Teardown    run keyword and ignore error    Common suite recovery


*** Test Cases ***
#Case_name_tempate
#    [Tags]    todo
#    [Documentation]    Author: xxxx
#    ...    This test case is to verify the NIDD parameter actDynUlDataSplitMode can be online modified and taken into effect
#    ...    immediatel without any alarm or service interruption.
#    [Setup]    Common case setup    is_log_required=${False}
#    log to console    case template example
#    Case keyword
#    [Teardown]    run keyword and ignore error    Common case teardown    is_log_required=${False}

*** Keywords ***
Case keyword
    [Documentation]    Author: xxxx
    ...    Define your own keywords
    [Arguments]    ${parameter}=${None}
    log to console     case keyword
