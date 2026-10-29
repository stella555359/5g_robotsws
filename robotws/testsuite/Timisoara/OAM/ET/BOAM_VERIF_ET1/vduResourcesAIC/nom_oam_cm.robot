*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   nom_oam_cm.robot



*** Variables ***



*** Keywords ***
Import VDU TLS Integrate Plan To NOM
    [Tags]   NOM_CM
    [Arguments]    ${mrbts_id}    ${ne_id}
    [Documentation]  Import VDU Integrate Plan To NOM.
    ...    author: lijuan.1.wang@nokia-sbell.com
    ...    modified by:        <28-07-2021>, <lijuwang>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  MRBTS_ID  | YES |    |
    ...    |  NE_ID  | YES |    |
    ...   Example
    ...  | Import VDU TLS Integrate Plan To NOM |

    ${import_plantime}   _Get CNMS TimeStamp
    log to console    ${import_plantime}

    ${vdu_oam_http_connection_info}   Get vDU OAM Http Connection Info
    ${vdu_oam_ip}   set variable  ${vdu_oam_http_connection_info["addr"]}

    #${ca_file}=   get file   ${CURDIR}/../../resources/nom/ca1_cacert
    ${ca_file}=   get file    ${CURDIR}/nom/ca1_cacert

    ${Plan_name}   Set Variable    ${mrbts_id}-TLS-Integrate${import_plantime[1]}

    ${plan_file}    _Generate NOM Integrate xml File With TLS    ${Plan_name}   ${mrbts_id}    ${vdu_oam_ip}   ${ne_id}   ${ca_file}
    ${integrate_plan}   set variable   ${OUTPUT_DIR}/${Plan_name}.xml
    create file   ${integrate_plan}   ${plan_file}

    nom_selenium.login     ${NOM_1_WEBUI_LINK}
    nom_selenium.import_plan       ${integrate_plan}    ${Plan_name}    integration_plan
    nom_selenium.logout
    [Return]   ${Plan_name}