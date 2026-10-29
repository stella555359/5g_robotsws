*** Settings ***
Documentation
...    Author: damian.muszynski@nokia.com
...    Maintainer: damian.muszynski@nokia.com
...    Team in charge: I_EXT_5G_IV_WRO_OAM3_GMS

Library    XML  lxml=True
Library    String
Library    taf.sbts.oam.coam.admin.admin   WITH NAME   admin_cli

*** Keywords ***
Get NRBTS Status
    [Documentation]
    ...    Description: NRBTS_R-{current_mrbtsId_number} in VM on cOAM test lines
    [Arguments]  ${status}
    ${NRBTS_id}=    get nrbtsid
    ${NRBTS_status_response}=    run keyword and ignore error   admin_cli.get_parameters
    ...                        dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-${NRBTS_id}
    ...                        pattern=${status}

    ${NRBTS_status_response2}=    run keyword and ignore error   admin_cli.get_parameters
    ...                        dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1
    ...                        pattern=${status}

    ${NRBTS_status_response3}=    run keyword and ignore error   admin_cli.get_parameters
    ...                        dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-${NRBTS_id}
    ...                        pattern=${status}

    ${NRBTS_status_response4}=    run keyword and ignore error   admin_cli.get_parameters
    ...                        dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-1
    ...                        pattern=${status}

    [Return]    ${NRBTS_status_response['${status}']}

    return from keyword if    "${NRBTS_status_response[0]}" == "PASS"  ${NRBTS_status_response[1]["${status}"]}
    return from keyword if    "${NRBTS_status_response2[0]}" == "PASS"  ${NRBTS_status_response2[1]["${status}"]}
    return from keyword if    "${NRBTS_status_response3[0]}" == "PASS"  ${NRBTS_status_response3[1]["${status}"]}
    return from keyword if    "${NRBTS_status_response4[0]}" == "PASS"  ${NRBTS_status_response4[1]["${status}"]}
    fail  failed to get NRBTS status: "${status}"

Get nrbtsId
    [Documentation]     nrbtsID is the same as mrbtsID
    admin_cli.get_current_scf_file      /home/ute    scf.xml
    ${XML}=   Parse XML   /home/ute/scf.xml
    ${mrbtsId_element}=   Get Element   ${XML}   //managedObject[@class="com.nokia.srbts:MRBTS"]
    @{mrbts_and_mrbtsId}=    Split String    ${mrbtsId_element.attrib['distName']}    -
    [Return]    @{mrbts_and_mrbtsId}[1]
