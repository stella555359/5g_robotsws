*** Settings ***
Documentation
...   feature keywords for CB009543

Library       taf.sbts.oam.coam.admin                                                      WITH NAME     coam
Library       testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/color_log.py                    WITH NAME     line
Library       testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB009543/resources/keywords_9543.py
Library       testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/DeltaStore.py            WITH NAME     ds
Library       testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/AdminHelper.py           WITH NAME     ah
Library       testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB010442/resources/keywords.py            WITH NAME     10442_lib
Resource      testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB010442/resources/keywords_10442.robot
Resource      testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB013553/resources/keywords.robot


*** Variables ***
${BTS_ID}                  ${tl.gnbs[0].instance_id}
${MAIN_SCF_PATH}           MRBTS-${bts_id}/NRBTS-${bts_id}
${empty}
${5G_CONNECTION_ALIAS}     gNB
@{cell_41}=   ${9}    ${10}
@{cell_31}=   ${7}    ${8}


*** Keywords ***
perform Shutting Down for nrcell
    [Documentation]
    ...    Preform shutting down for specific cell

    [Arguments]
    ...    ${NRCELL}=41
    ...    ${administrativeState}=Shutting Down
    line.write line               \n __Perform ${administrativeState} for cell-${NRCELL}
    ds.initialise_delta_store
    ds.Add Param To Delta    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${NRCELL}    administrativeState      value=${administrativeState}
    ${delta}       ds.collect_delta_store
    ah.recommission_with_delta_from_admin  ${delta}


Check cell is Shutting Down Interval
    [Arguments]
    ...    ${timeout}=3min
    ...    ${retry_interval}=30sec
    ...    ${cell_status}=Shutting Down
    ...    ${5g_cell}=41

    line.write line               \n __CHeck if ${cell_status} for cell-${5g_cell}
    Conect to gNB admin
    ${5g_bts_info}    coam.get_bts_info    30    ${5G_CONNECTION_ALIAS}
    ${5g_cells_info}  Set Variable    ${5g_bts_info['cells']['nr']}
    Wait Until Keyword Succeeds    ${timeout}    ${retry_interval}    verify_State    ${5g_cell}    ${cell_status}    @{5g_cells_info}
