*** Settings ***
Documentation
...    Author:          Bartlomiej Lebda | Jakub Klein
...    Maintainer:      Bartlomiej Lebda | Jakub Klein
...    Contact:         bartlomiej.lebda@nokia.com jakub.klein@nokia.com
...    Team in charge:  I_EXT_PZ_1_WRO_6_GMS
...    Keywords related to admin

Library  BuiltIn
Library  Collections
Library  String
Library  taf.sbts.oam.coam.admin     WITH NAME     admin_cli

*** Variables ***
${gNB_IP_MPLANE_LOCAL}=    192.168.255.129
${gNB_MPLANE_IF_PORT}=     443
${save_snapshot_path}=     ${OUTPUT DIR}/Snapshot.zip

*** Keywords ***
Check if BTS is OnAir state cOAM1
    [Arguments]  ${connection}=admin
    ${bts_status}=  admin_cli.get_bts_statuses  connection=${connection}
    Should Be Equal As Strings   ${bts_status["proceduralState"]}    OnAir
    Run Keyword If  '${bts_status["proceduralState"]}'=='OnAir'  Log To Console  \n BTS procedural state is now: ${bts_status["proceduralState"]}
    wait until keyword succeeds    5min     10s     BasicKeywords.Admin Check Radio Module Online Status
    ...                                                   connection=${connection}

Check If proceduralState Of gNB Is Configured Or OnAir
    [Documentation]
    ...     Keyword checks whether proceduralState of gNB is configured or OnAir
    [Arguments]    ${connection}=default
    ${gNB_statuses}=      admin_cli.get_bts_statuses    connection=${connection}
    ${state}    get from dictionary   ${gNB_statuses}   key=proceduralState
    Should Contain Any      ${state}    Configured     OnAir
    [Return]    ${state}

Check If proceduralState Of gNB Is OnAir
    [Documentation]
    ...     Keyword checks whether proceduralState of gNB is OnAir
    [Arguments]    ${connection}=default
    ${gNB_statuses}=      admin_cli.get_bts_statuses    connection=${connection}
    ${state}    get from dictionary   ${gNB_statuses}   key=proceduralState
    Should Be Equal     ${state}   OnAir
    [Return]    ${state}

Check If operationalState Of gNB Is OnAir
    [Documentation]
    ...     Keyword checks whether operationalState of gNB is disabled
    [Arguments]    ${connection}=default
    ${gNB_statuses}=      admin_cli.get_bts_statuses    connection=${connection}
    ${operationalState}    get from dictionary   ${gNB_statuses}   key=operationalState
    Should Contain Any    ${operationalState}   Disabled    disabled
    [Return]    ${operationalState}

Check If proceduralState Of gNB Is Commissioned Or Configured
    [Documentation]
    ...     Keyword checks whether proceduralState of gNB is commissioned or configured
    [Arguments]    ${connection}=default
    ${gNB_statuses}=      admin_cli.get_bts_statuses    connection=${connection}
    ${state}    get from dictionary   ${gNB_statuses}   key=proceduralState
    Should Contain Any      ${state}    Commissioned    Configured
    [Return]    ${state}

Admin Check Radio Module Online Status
    [Arguments]  ${connection}=admin
    ${bts_info}=  admin_cli.get_bts_info  connection=${connection}
    Should Be Equal As Strings  ${bts_info["radioModules"]["rmod"][0]["status"]["operationalState"]}   Enabled
    Should Be Equal As Strings  ${bts_info["radioModules"]["rmod"][0]["status"]["availabilityStatus"]}  Online

Admin Check BTS Procedural State cOAM1
    [Arguments]  ${connection}=admin
    ${bts_status}=  admin_cli.get_bts_statuses  connection=${connection}
    Log To Console  \n BTS procedural state is now: ${bts_status["proceduralState"]}
    [Return]   ${bts_status["proceduralState"]}

Admin get operationalState
    [Arguments]    ${connection}=admin
    ${btsStatus}=    Admin get bts status    connection=${connection}
    ${operationalState}=    Get From Dictionary    ${btsStatus}    status
    ${operationalState}=    Get From Dictionary    ${operationalState}    operationalState
    [Return]    ${operationalState}

Admin get bts status
    [Arguments]    ${connection}=admin
    ${btsStatus}=     admin_cli.get_bts_info    connection=${connection}
    [Return]    ${btsStatus}

Verify number of cells onAir
    [Arguments]    ${num_of_cells}    ${connection}=default
    ${cell_info}=    cli.get_cells_info    connection=${connection}
    ${cell_list}    Create List
    FOR    ${i}    IN   @{cell_info}
        ${status}    Get From Dictionary    ${i}    status
        ${operstate}    Get From Dictionary    ${status}    operationalState
        ${id}           Get From Dictionary    ${i}   id
        ${cell}                 Get From Dictionary    ${id}    configuration
        Run Keyword If     "${operstate}"=="enabled"
        ...    Append To List    ${cell_list}    ${cell}
    END
    ${length_onair_cells}    Get Length   ${cell_list}
    ${state}=    Run Keyword And Return Status    Should Be Equal As Integers      ${length_onair_cells}    ${num_of_cells}
    [Return]    ${state}
