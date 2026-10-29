*** Settings ***
Documentation
...   author:  OAM
...   contact: I_MN_5GSC_PZ_5G_IV7_WRO_6@internal.nsn.com
...   Keywords related to admin

Library  BuiltIn
Library  Collections
Library  String
Library  taf.sbts.oam.coam.admin     WITH NAME     admin_cli

*** Variables ***
${gNB_IP_MPLANE_LOCAL}=    192.168.255.1
${gNB_MPLANE_IF_PORT}=     443
${save_snapshot_path}=     ${OUTPUT DIR}/Snapshot.zip

*** Keywords ***
ADMIN CLI connection
    [Documentation]
    ...     Common keyword to established connection with ADMIN API of tested gNB
    admin_cli.connect_to    bts_host=${gNB_IP_MPLANE_LOCAL}     bts_port=${gNB_MPLANE_IF_PORT}

Create admin client session with alias cOAM1
    [Arguments]    ${connection}=admin    ${timeout}=1min    ${bts_port}=443
    Wait Until Keyword Succeeds    ${timeout}    10s    admin.connect_to
    ...                            bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...                            bts_port=${bts_port}
    ...                            name=${connection}
    ...                            reconnect_with_default_on_failure=${True}

Admin Check BTS OnAir State cOAM1
    [Arguments]  ${connection}=admin
    ${bts_status}=  admin.get_bts_statuses  connection=${connection}
    Should Be Equal As Strings   ${bts_status["proceduralState"]}    OnAir
    Run Keyword If  '${bts_status["proceduralState"]}'=='OnAir'  Log To Console  \n BTS procedural state is now: ${bts_status["proceduralState"]}
    wait until keyword succeeds timer    5min     10s     BasicKeywords.Admin Check Radio Module Online Status
    ...                                                   connection=${connection}

ADMIN CLI disconnection
    [Documentation]
    ...     Disconnects connection to gNB ADMIN
    admin_cli.teardown

gNB in configured state
    [Documentation]
    ...     Keyword check if gNB is in configured state
    ${gNB_statuses}=      admin_cli.get_bts_statuses
    ${state}    get from dictionary   ${gNB_statuses}   key=proceduralState
    Should Contain Any      ${state}    Configured     OnAir
    [Return]    ${state}


gNB in onAir state
    [Documentation]
    ...     Keyword check if gNB is in configured state
    ${gNB_statuses}=      admin_cli.get_bts_statuses
    ${state}    get from dictionary   ${gNB_statuses}   key=proceduralState
    Should Be Equal     ${state}   OnAir
    [Return]    ${state}


gNB in conmissioned state
    [Documentation]
    ...     Keyword check if gNB is in Commissioned state
    ${gNB_statuses}=      admin_cli.get_bts_statuses
    ${state}    get from dictionary   ${gNB_statuses}   key=proceduralState
    Should Contain Any      ${state}    Commissioned    Configured
    [Return]    ${state}

gNB Site Reset
    [Documentation]
    ...     Trigger Site Reset using ADMIN cli
    ${site_reset_state}     admin_cli.reset_site

Validate commissioning SCF file
    [Documentation]
    ...     Commissioning SCF validation on gNB using SCF file
    [Arguments]     ${SCF_FILE_PATH}
    admin_cli.validate_scf      scf_file=${SCF_FILE_PATH}     timeout=30

Get active alarms on gNB
    [Documentation]
    ...     Get active Alarms from gNB
    ${alarm_active_list}=       admin_cli.get_active_alarms     timeout=40
    [Return]        ${alarm_active_list}

Get faultID from gNB
    [Documentation]
    ...     Check and provide the active alarm on gNB provoding the faultID number
    [Arguments]     ${FAULT_ID}
    ${active_fault_list}=    admin_cli.get_active_alarms
    ${alarm_list_str}=  convert to string    ${active_fault_list}
    ${fultId_match_alarm}=    Get Regexp Matches    ${alarm_list_str}      \'additionalFaultID\': ${FAULT_ID}
    ${fultId_match_status}=   run keyword and return status   should not be empty     ${fultId_match_alarm}
    run keyword if  'False'=='${fultId_match_status}'    FAIL
    [Return]      ${fultId_match_status}   ${fultId_match_alarm}

Trigger Snapshot Saving
    [Documentation]
    ...     Legacy Keyword from MegazoneKeywords - Snapshoat collections
    admin_cli.get_snapshot    target_file_name=${save_snapshot_path}
    ...                       coverage=Full    timeout=600

Admin Check Radio Module Online Status
    [Arguments]  ${connection}=admin
    ${bts_info}=  admin_cli.get_bts_info  connection=${connection}
    Should Be Equal As Strings  ${bts_info["radioModules"]["rmod"][0]["status"]["operationalState"]}   Enabled
    Should Be Equal As Strings  ${bts_info["radioModules"]["rmod"][0]["status"]["availabilityStatus"]}  Online

Fault Might Be Present
    [Documentation]
    ...  ___
    [Arguments]    ${fault_id}
    ${fault_id_status}=
    ...     run keyword and return status
    ...     wait until keyword succeeds   3min    10s     Check If Fault Occurs      ${fault_id}
    [Return]     ${fault_id_status}

Check If Fault Occurs
    [Arguments]     ${fault_id}
    ${active_alarms}    admin_cli.get_active_alarms    timeout=60
    ${len}    Get Length    ${active_alarms}
    ${alarm_id_list}    Create List
    FOR    ${i}    IN RANGE    ${len}
        ${tmp_id}    Get From Dictionary    ${active_alarms[${i}]}    faultId
        Append To List    ${alarm_id_list}    ${tmp_id}
    END
    ${list}     convert to string  ${alarm_id_list}
    List Should Contain Value    ${list}    ${fault_id}

Admin Check BTS Procedural State cOAM1
    [Arguments]  ${connection}=admin
    ${bts_status}=  admin.get_bts_statuses  connection=${connection}
    Log To Console  \n BTS procedural state is now: ${bts_status["proceduralState"]}
    [Return]   ${bts_status["proceduralState"]}

