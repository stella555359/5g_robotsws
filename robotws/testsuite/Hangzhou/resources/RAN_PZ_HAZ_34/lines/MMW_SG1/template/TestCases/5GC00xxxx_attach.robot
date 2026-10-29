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
...     scf_modify_parameters=${MODIFY_SCF_TEMPLATE}    prepare_ue=${True}
Suite Teardown    run keyword and ignore error    Common suite recovery


*** Test Cases ***
#Case_name_tempate_attach
#    [Tags]    todo
#    [Documentation]    Author: xxxx
#    ...    case description
#    [Setup]    Common case setup    is_log_required=${False}
#    Retry commercial ue attach if failed    prepare_ue_needed=${False}
#    [Teardown]    run keyword and ignore error    Common case teardown    is_log_required=${False}    detach_ue=${True}

*** Keywords ***
Case keyword
    [Documentation]    Author: xxxx
    ...    Define your own keywords
    [Arguments]    ${parameter}=${None}
    log to console     case keyword
