*** Settings ***
Documentation
...    Author: valentyna.mykhaylets@nokia.com
...    Maintainer: valentyna.mykhaylets@nokia.com
...    Team in charge: I_EXT_5G_IV_WRO_OAM3_GMS

Library    taf.sbts.oam.coam.admin.admin   WITH NAME   admin_cli
Library    ./status_filtering.py

*** Keywords ***
Get SMOD Statuses
    [Arguments]  ${component_id}
    ${SMOD_statuses_response}=    admin_cli.get_fsm_info
    ${specific}=   get_info_on_specific_component  ${SMOD_statuses_response}    ${component_id}
    [Return]    ${specific['status']}

Get BBMOD Statuses
    [Arguments]  ${component_id}
    ${BBMOD_statuses_response}=    admin_cli.get_fbb_info
    ${specific}=   get_info_on_specific_component  ${BBMOD_statuses_response}   ${component_id}
    [Return]    ${specific['status']}

Get GNSS Statuses
    ${GNSS_statuses_response}=    admin_cli.get_gnsses_statuses
    [Return]    ${GNSS_statuses_response['GNSSE_R-1']}

Get RU Statuses
    [Arguments]  ${component_id}
    ${RU_statuses_response}=    admin_cli.get_frm
    ${specific}=   get_info_on_specific_ru  ${RU_statuses_response}  ${component_id}
    [Return]    ${specific['status']}

Get Cell Statuses
    [Arguments]  ${component_id}
    ${Cell_statuses_response}=    admin_cli.get_cells_info
    ${specific}=   get_info_on_specific_component  ${Cell_statuses_response}    ${component_id}
    [Return]    ${specific['status']}

Get Cablink Statueses
    [Arguments]  ${component_id}
    ${Cablink_statuses_response}=    admin_cli.get_managed_objects    CABLINK_R
    ${specific}=   get_info_on_specific_component  ${Cablink_statuses_response}    ${component_id}
    [Return]  ${specific['parameters']['stateInfo']}

Get cOAM BTS Statuses
    ${cOAM_BTS_statuses_response}=    admin_cli.get_bts_info
    [Return]    ${cOAM_BTS_statuses_response['status']}
