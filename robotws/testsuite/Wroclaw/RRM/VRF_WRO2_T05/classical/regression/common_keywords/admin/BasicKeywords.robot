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
${gNB_IP_MPLANE_LOCAL}=    192.168.255.129
${gNB_MPLANE_IF_PORT}=     443
${save_snapshot_path}=     ${OUTPUT DIR}/Snapshot.zip

*** Keywords ***
ADMIN CLI connection
    [Documentation]
    ...     Common keyword to established connection with ADMIN API of tested gNB
    Log     establishing admin connection    console=True
    admin_cli.connect_to    bts_host=${gNB_IP_MPLANE_LOCAL}     bts_port=${gNB_MPLANE_IF_PORT}

ADMIN CLI remote connection
    [Documentation]
    ...     Common keyword to established connection with ADMIN API of tested remote gNB
    [Arguments]    ${remote_host}    ${bts_port}=443
    ${remote_admin1}=  admin_cli.setup_admin    remote_host=${remote_host}     bts_port=${bts_port}  name=remote_admin1
    ...    remote_host_password=UTE.debian12
    ${REMOTE_ADMIN}=  Set suite variable  ${remote_admin1}

Reconnect ADMIN CLI remote connection
    [Arguments]    ${remote_host}    ${connection}=default
    ADMIN CLI disconnection  connection=${connection}
    sleep    10s
    wait until keyword succeeds    20min     10s     ADMIN CLI remote connection  remote_host=${remote_host}

Create admin client session with alias cOAM1
    [Arguments]    ${connection}=admin    ${timeout}=1min    ${bts_port}=443
    Wait Until Keyword Succeeds    ${timeout}    10s    admin_cli.connect_to
    ...                            bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...                            bts_port=${bts_port}
    ...                            name=${connection}
    ...                            reconnect_with_default_on_failure=${True}

Admin Check BTS OnAir State cOAM1
    [Arguments]  ${connection}=admin
    ${bts_status}=  admin_cli.get_bts_statuses  connection=${connection}
    Should Be Equal As Strings   ${bts_status["proceduralState"]}    OnAir
    Run Keyword If  '${bts_status["proceduralState"]}'=='OnAir'  Log To Console  \n BTS procedural state is now: ${bts_status["proceduralState"]}
    wait until keyword succeeds    5min     10s     BasicKeywords.Admin Check Radio Module Online Status
    ...                                                   connection=${connection}

ADMIN CLI disconnection
    [Documentation]
    ...     Disconnects connection to gNB ADMIN
    [Arguments]    ${connection}=default
    admin_cli.teardown  connection=${connection}

gNB in configured state
    [Documentation]
    ...     Keyword check if gNB is in configured state
    ${gNB_statuses}=      admin_cli.get_bts_statuses
    ${state}    get from dictionary   ${gNB_statuses}   key=proceduralState
    Should Contain Any      ${state}    Configured     OnAir
    [Return]    ${state}


gNB in onAir state
    [Documentation]
    ...     Keyword check if gNB is in onAir state
    [Arguments]    ${connection}=default
    ${gNB_statuses}=      admin_cli.get_bts_statuses  connection=${connection}
    ${state}    get from dictionary   ${gNB_statuses}   key=proceduralState
    Should Be Equal     ${state}   OnAir
    [Return]    ${state}

gNB in Disabled operationalState
    [Documentation]
    ...     Keyword check if gNB is in configured state
    ${gNB_statuses}=      admin_cli.get_bts_statuses
    ${operationalState}    get from dictionary   ${gNB_statuses}   key=operationalState
    Should Be Equal     ${operationalState}   Disabled
    [Return]    ${operationalState}


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
    [Arguments]    ${connection}=default
    ${site_reset_state}     admin_cli.reset_site  connection=${connection}

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
    Should Contain    ${list}    ${fault_id}

Admin Check BTS Procedural State cOAM1
    [Arguments]  ${connection}=admin
    ${bts_status}=  admin_cli.get_bts_statuses  connection=${connection}
    Log To Console  \n BTS procedural state is now: ${bts_status["proceduralState"]}
    [Return]   ${bts_status["proceduralState"]}

Admin Get Software Version
    [Arguments]  ${connection}=admin
    ${swVer}=     admin_cli.get_sw_version    connection=${connection}
    [Return]   ${swVer}

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
