*** Settings ***
Documentation
...    Author: valentyna.mykhaylets@nokia.com
...    Maintainer: valentyna.mykhaylets@nokia.com
...    Team in charge: I_EXT_5G_IV_WRO_OAM3_GMS

Library    taf.sbts.oam.coam.admin.admin   WITH NAME   admin_cli
Library    ./status_filtering.py
Library    ../../../PythonKeywords/tl_topology.py
Library     ../../../PythonKeywords/coam_resources.py
Library     ../../../PythonKeywords/admin_info_model.py


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
    ${GNSSE_objects}    Get Dictionary Keys    ${GNSS_statuses_response}
    FOR   ${obj}    IN    @{GNSSE_objects}
        ${obj_value}    Get From Dictionary    ${GNSS_statuses_response}    ${obj}
        ${result}    ${value}    Run Keyword And Ignore Error    should not be empty    ${obj_value}
        Run Keyword If    '${result}'=='PASS'    Set Test Variable    ${state}    ${GNSS_statuses_response['${obj}']}
        Run Keyword If    '${result}'=='PASS'    Exit For Loop
    END
    [Return]    ${state}

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

Admin Check System Module Status
    [Arguments]  ${connection}=admin
    ...          ${smod_index}=0
    ${bts_info}=  admin.get_bts_info  connection=${connection}
    Should Be Equal As Strings  ${bts_info["systemModules"][${smod_index}]["status"]["operationalState"]}   Enabled
    Should Be Equal As Strings  ${bts_info["systemModules"][${smod_index}]["status"]["availabilityStatus"]}  Online
    Log to console  \n System Module Availability Status is now: ${bts_info["systemModules"][${smod_index}]["status"]["availabilityStatus"]}

Admin Check Baseband Module Status
    [Arguments]  ${connection}=admin
    ...          ${bbmod_index}=0
    ${bts_info}=  admin.get_bts_info  connection=${connection}
    Should Be Equal As Strings  ${bts_info["basebandModules"][${bbmod_index}]["status"]["operationalState"]}   Enabled
    Should Be Equal As Strings  ${bts_info["basebandModules"][${bbmod_index}]["status"]["availabilityStatus"]}  Online
    Log to console
    ...   \n Baseband Module Availability Status is now: ${bts_info["basebandModules"][${bbmod_index}]["status"]["availabilityStatus"]}

Admin Check GPS Status
    [Arguments]    ${connection}=admin
    ${GPS_exist}    tl_topology.check_whether_GPS_exists   tl_topology=CLASSICAL
    Run keyword if   ${GPS_exist}    Check gps status  connection=${connection}

Check gps status
    [Arguments]  ${connection}=admin
    ${bts_info}=  admin.get_bts_info  connection=${connection}
    Should Be Equal As Strings  ${bts_info["gnsse"][0]["stateInfo"]["operationalState"]}   Enabled
    Should Be Equal As Strings  ${bts_info["gnsse"][0]["stateInfo"]["availabilityStatus"]}  Online
    Log to console  \n GPS Availability Status is now: ${bts_info["gnsse"][0]["stateInfo"]["availabilityStatus"]}

Admin Check Radio Module Status
    [Arguments]  ${status}=online  ${connection}=admin
    ${radios}=   get_admin_ru_conf   connection=${connection}
    : FOR  ${radio}    IN    @{radios}
    \    ${index}=    get_radio_index    mrbts=${radio}
    \    Private Admin Check Radio Module Status  status=${status}  connection=${connection}  rmod=${index}

Admin Check BTS OnAir State
    [Arguments]  ${connection}=admin
    ${bts_status}=  admin.get_bts_statuses  connection=${connection}
    Should Be Equal As Strings   ${bts_status["proceduralState"]}    OnAir
    Run Keyword If  '${bts_status["proceduralState"]}'=='OnAir'  Log To Console  \n BTS procedural state is now: ${bts_status["proceduralState"]}
    wait until keyword succeeds    5min     10s     Admin Check Radio Module Status
    ...                                                   status=online
    ...                                                   connection=${connection}

Private Admin Check Radio Module Status
    [Arguments]  ${status}  ${connection}  ${rmod}
    ${operational_state}  ${availability_status}
    ...  ${administrative_state}    Admin Get Radio Module State Info
    ...  connection=${connection}  rmod=${rmod}
    Check State of Radio   status=${status}     operational_state=${operational_state}
    ...                            availability_status=${availability_status}
    ...                            administrative_state=${administrative_state}

Admin Check Statuses For All Cells
    [Arguments]      ${connection}=admin
    ${cells_info}    get_cells_info_admin    connection=${connection}
    ${number_of_cells}    Get Length    ${cells_info}
    : FOR   ${index}   IN RANGE   ${number_of_cells}
    \  Should Contain   ${cells_info[${index}]["status"]["proceduralStatus"]}     configured
    \  Should Contain   ${cells_info[${index}]["status"]["availabilityStatus"]}   Online
    \  Should Contain   ${cells_info[${index}]["status"]["administrativeState"]}  Unlocked
    \  Should Contain   ${cells_info[${index}]["status"]["operationalState"]}     Enabled

Admin Get Radio Module State Info
    [Arguments]  ${connection}=admin
    ...          ${rmod}=0
    ${radio_conf}=    Admin Get Radio Module Configuration    connection=${connection}    rmod=${rmod}
    ${operational_state}=  set variable
    ...  ${radio_conf["status"]["operationalState"]}
    ${availability_status}=  set variable
    ...  ${radio_conf["status"]["availabilityStatus"]}
    ${administrative_state}=  set variable
    ...  ${radio_conf["status"]["administrativeState"]}
    [Return]  ${operational_state}  ${availability_status}  ${administrative_state}

Check State of Radio
    [Arguments]    ${status}    ${operational_state}    ${availability_status}    ${administrative_state}
    Run Keyword If  "${status}"=="online"  Run keywords
    ...  Should Be Equal As Strings  ${operational_state}  Enabled  AND
    ...  Should Be Equal As Strings  ${availability_status}  Online
    Run Keyword If  "${status}"=="offline"  Run keywords
    ...  Should Be Equal As Strings  ${operational_state}  Disabled  AND
    ...  Should Be Equal As Strings  ${availability_status}  Offline
    Run Keyword If  "${status}"=="locked"  Run keywords
    ...  Should Be Equal As Strings  ${operational_state}  Enabled  AND
    ...  Should Be Equal As Strings  ${availability_status}  Online  AND
    ...  Should Be Equal As Strings  ${administrative_state}  Locked
    Run Keyword If  "${status}"=="unlocked"  Run keywords
    ...  Should Be Equal As Strings  ${operational_state}  Enabled  AND
    ...  Should Be Equal As Strings  ${availability_status}  Online  AND
    ...  Should Be Equal As Strings  ${administrative_state}  Unlocked
    Run Keyword If  "${status}"=="unavailable"  Run keywords
    ...  Should Be Equal As Strings  ${operational_state}  Disabled  AND
    ...  Should Be Equal As Strings  ${availability_status}  NotInstalled
    Run Keyword If  "${status}"=="degraded"  Run keywords
    ...  Should Be Equal As Strings  ${operational_state}  Enabled  AND
    ...  Should Be Equal As Strings  ${availability_status}  Degraded

Admin Get Radio Module Configuration
    [Arguments]  ${connection}=admin
    ...          ${rmod}=0
    ${bts_info}=  admin.get_bts_info  connection=${connection}
    @{radios}=    set variable    ${bts_info["radioModules"]["rmod"]}
    ${radio_conf}=  set variable    ${None}
    FOR   ${radio}   IN   @{radios}
          ${radio_index}=    get_radio_index   ${radio["id"]["configuration"]}
          ${radio_conf}=    Set Variable If    ${radio_index} == ${rmod}    ${radio}    ${radio_conf}
    END
    [Return]  ${radio_conf}

