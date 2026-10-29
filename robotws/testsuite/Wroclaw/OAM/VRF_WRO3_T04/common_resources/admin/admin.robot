*** Settings ***
Documentation   Keywords regarding ADMIN API connections and procedures.
...             Author:     Jakub Aniszewski
...             Contact:    jakub.aniszewski@nokia.com

Library         taf.sbts.oam.coam.admin    WITH NAME   coam_admin
Library         taf.transport.ssh        WITH NAME   ssh
Library         taf.config.scf           WITH NAME   scf
Library         admin_utils.py
Library         DateTime
Library         Collections
Library         String
Resource        ../connections/connections.robot
Resource        ../commissioning/parameters.robot

*** Variables ***
${TEMP_ADMIN_CONN}=         temporary_admin_connection

*** Keywords ***
Run Keyword With ADMIN Connection
    [Arguments]       @{keyword}    &{kwargs}
    ${connection}=    Connect to ADMIN    alias=${TEMP_ADMIN_CONN}
    ${results}=       Run Keyword    @{keyword}    &{kwargs}    connection=${connection}
    [Teardown]        admin.Disconnect From ADMIN    connection=${TEMP_ADMIN_CONN}
    [Return]          ${results}

Assert Every Class Item
    [Arguments]           ${class_name}  ${parameters}  ${timeout}=10s  ${connection}=${NONE}

    ${connection}=        admin_utils.create_connection_if_not_exist
    ...                   connection=${connection}
    ...                   alias=${TEMP_ADMIN_CONN}

    coam_admin.assert_every    class_name=${class_name}
    ...                   parameters=${parameters}
    ...                   timeout=${timeout}
    ...                   connection=${connection}

    [Teardown]            Run Keyword And Ignore Error
    ...                   admin.Disconnect From ADMIN
    ...                   connection=${TEMP_ADMIN_CONN}

Block All Cells on BTS
    [Arguments]              ${connection}=${NONE}  ${rat}=NR
    ${connection}=           admin_utils.create connection if not exist
    ...                      connection=${connection}
    ...                      alias=${TEMP_ADMIN_CONN}
    coam_admin.block_all_cells    rat=${rat}
    ...                      timeout=2400
    ...                      connection=${connection}
    [Teardown]               Run keyword and ignore error
    ...                      admin.Disconnect From ADMIN
    ...                      connection=${TEMP_ADMIN_CONN}

Block on BTS
    [Arguments]           ${mrbts_path}  ${connection}=${NONE}
    ${connection}=        admin_utils.create connection if not exist
    ...                   connection=${connection}
    ...                   alias=${TEMP_ADMIN_CONN}
    coam_admin.block      dist_name=${mrbts_path}
    ...                   timeout=2400
    ...                   connection=${connection}
    [Teardown]            Run keyword and ignore error
    ...                   admin.Disconnect From ADMIN
    ...                   connection=${TEMP_ADMIN_CONN}

Change Unit LED Status To Unit Led Colour
    [Documentation]  LED status: Enabled/Online - green, Failed - red, Degraded - yellow, Not installed/Offline/Disabled - gray
    [Arguments]  ${current_unit_status}
    ${green_led}=     Run Keyword And Return Status
    ...               Should Match RegExp   "${current_unit_status}"    ([Ee]nabled|[Oo]nline|[Oo]n line)
    ${red_led}=       Run Keyword And Return Status
    ...               Should Match RegExp   "${current_unit_status}"    ([Ff]ailed)
    ${yellow_led}=    Run Keyword And Return Status
    ...               Should Match RegExp   "${current_unit_status}"    ([Dd]egraded)
    ${gray_led}=      Run Keyword And Return Status
    ...               Should Match RegExp   "${current_unit_status}"    ([Nn]ot installed|[Oo]ffline|[Oo]ff line|[Dd]isabled)
    Run Keyword If    ${green_led}     Set Test Variable    ${LED_COLOUR}    Green
    Run Keyword If    ${red_led}       Set Test Variable    ${LED_COLOUR}    Red
    Run Keyword If    ${yellow_led}    Set Test Variable    ${LED_COLOUR}    Yellow
    Run Keyword If    ${gray_led}      Set Test Variable    ${LED_COLOUR}    Gray
    [Return]    ${LED_COLOUR}

Check current parameter value
    [Documentation]      This keyword check current BTS parameter value from SCF.
    [Arguments]          ${param_name}    ${dist_name}=${None}
    ...                  ${filename}=/tmp/full_scf.xml    ${local_path}=.
    ...                  ${timeout}=900    ${connection}=${NONE}
    ${connection}=               admin_utils.create connection if not exist
    ...                           connection=${connection}
    ...                           alias=${TEMP_ADMIN_CONN}_loop
    coam_admin.get_current_scf_file    local_dir_path=${local_path}
    ...                           file_name=${filename}
    ...                           export_type=configurationAndRuntimeObjects
    ...                           timeout=${timeout}
    ...                           connection=${connection}
#      coam_admin.collect_scf      target_file_name=/tmp/full_scf.xml DEPRECATED
#      ...                    export_type=configurationAndRuntimeObjects
#      ...                    connection=${connection}
    scf.load_scf                  /tmp/full_scf.xml
    ${value}=                     scf.get_all_values_from_scf    dist_name=${dist_name}    p_name=${param_name}
    Log    ${param_name} value is: ${value}    console=true
    [Return]          ${value}
    [Teardown]        Run keyword and ignore error
    ...               coam_admin.teardown  connection=${TEMP_ADMIN_CONN}_loop

Check If All Cells Are Degraded
    [Arguments]    ${timeout}=60s    ${connection}=${NONE}
    ${connection}=    admin_utils.create_connection_if_not_exist
    ...               connection=${connection}
    ...               alias=${TEMP_ADMIN_CONN}

    Assert Every   class_name=NRCEL
    ...            parameters=availabilityStatus=regex"[Dd]egraded"
    ...            timeout=${timeout}
    ...            connection=${connection}

    [Teardown]    Run Keyword And Ignore Error
    ...           admin.Disconnect From ADMIN
    ...           connection=${TEMP_ADMIN_CONN}

Check If All Cells Are OnAir
    [Arguments]       ${connection}=${NONE}
    [Documentation]   Check status of all cells configured on testline.

    ${connection}=        admin_utils.create_connection_if_not_exist
    ...                   connection=${connection}
    ...                   alias=checking_all_cell_conn

    ${GSM_cells}=     coam_admin.get_cells_info  gsm    connection=${connection}
    ${WCDMA_cells}=   coam_admin.get_cells_info  wcdma  connection=${connection}
    ${LTE_cells}=     coam_admin.get_cells_info  lte    connection=${connection}
    ${NR_cells}=      coam_admin.get_cells_info  nr     connection=${connection}

    ${GSM_exists}     Get Length            ${GSM_cells}
    ${WCDMA_exists}   Get Length            ${WCDMA_cells}
    ${LTE_exists}     Get Length            ${LTE_cells}
    ${NR_exists}      Get Length            ${NR_cells}

    Run Keyword If    ${GSM_exists} > 0     Check If GSM Cells Are Enabled
    Run Keyword If    ${WCDMA_exists} > 0   Check If WCDMA Cells Are Enabled
    Run Keyword If    ${LTE_exists} > 0     Check If LTE Cells Are Enabled
    Run Keyword If    ${NR_exists} > 0      Check If 5G Cells Are Enabled

    [Teardown]            Run Keyword And Ignore Error
    ...                   admin.Disconnect From ADMIN
    ...                   connection=checking_all_cell_conn

Check if BTS in given state
    [Arguments]           ${state}    ${connection}=${NONE}
    ${connection}=        admin_utils.create connection if not exist
    ...                   connection=${connection}
    ...                   alias=${TEMP_ADMIN_CONN}

    ${current_state}=     admin.Get Current BTS State
    ...                   connection=${connection}
    ${low_cur_state}=     Convert To Lowercase    ${current_state}
    ${low_state}=         Convert To Lowercase    ${state}
    Should Be Equal       ${low_cur_state}    ${low_state}

    [Teardown]            Run keyword and ignore error
    ...                   admin.Disconnect From ADMIN
    ...                   connection=${TEMP_ADMIN_CONN}

Check if BTS status is Configured or OnAir
    [Arguments]           ${connection}=${NONE}
    ${connection}=        admin_utils.create connection if not exist
    ...                   connection=${connection}
    ...                   alias=${TEMP_ADMIN_CONN}

    ${current_state}=     admin.Get Current BTS State
    ...                   connection=${connection}
    Should Match RegExp   "${current_state}"
    ...                   ([Oo]n[Aa]ir|[Cc]onfigured|[Ii]ntegratedToRan)

    [Teardown]            Run keyword and ignore error
    ...                   admin.Disconnect From ADMIN
    ...                   connection=${TEMP_ADMIN_CONN}

Check If GSM Cells Are Enabled
    Assert Every Class Item  GNCEL  availabilityStatus=regex"[Oo]nline"
    Assert Every Class Item  GNCEL  operationalState=regex"[Ee]nabled"
    Assert Every Class Item  GNCEL  administrativeState=regex"[Uu]nlocked"

Check If LTE Cells Are Enabled
    Assert Every Class Item  LNCEL  proceduralState=regex"[Oo]n[Aa]ir[Dd]one"
    Assert Every Class Item  LNCEL  operationalState=regex"[Ee]nabled"
    Assert Every Class Item  LNCEL  administrativeState=regex"[Uu]nlocked"

Check If NMS In Expected Status
    [Arguments]       ${manager_id}    ${expected_status}    ${connection}=${NONE}
    ${connection}=    admin_utils.create connection if not exist
    ...               connection=${connection}
    ...               alias=${TEMP_ADMIN_CONN}

    ${status}=        Get NMS Status by ManagerID
    ...               manager_id=${manager_id}
    ...               connection=${connection}
    Should be equal   "${status}"  "${expected_status}"

    [Teardown]        Run keyword and ignore error
    ...               admin.Disconnect From ADMIN
    ...               connection=${TEMP_ADMIN_CONN}

Check If Unit Reset Successful
     [Arguments]    ${BBMOD_path}
     ${current_unit_status}=    Get Unit Status Via Admin   ${BBMOD_path}
     Should Match RegExp   "${current_unit_status}"    ([Dd]isabled|[Oo]ffline|[Oo]ff line)

Check If WCDMA Cells Are Enabled
    Assert Every Class Item  WNCEL  availabilityStatus=regex"[Oo]nline"
    Assert Every Class Item  WNCEL  operationalState=regex"[Ee]nabled"

Check If 5G Cells Are Enabled
    Assert Every Class Item  NRCEL  operationalState=regex"[Ee]nabled"
    Assert Every Class Item  NRCEL  administrativeState=regex"[Uu]nlocked"

Check Unit LED
    [Arguments]    ${unit_name}
    @{UNIT_LIST}=     Get Infomodel Path To Object    ${unit_name}

    ${unit_nr}=    Set Variable    1
    FOR    ${unit}    IN    @{UNIT_LIST}
         Log    ----------------------- CHECK LED ${unit_name} ${unit_nr} -----------------------    console=True
         Log  Checking ${unit_name}: ${unit}    console=True
         ${LED_status}=    Check Unit LED Status    ${unit}
         ${LED_colour}=    Change Unit LED Status To Unit Led Colour    ${LED_status}
         Log    Checking ${unit_name} LED Colour is: \n${LED_colour}  console=True
         Should Be Equal  ${LED_colour}  Green
         ${unit_nr}=    Evaluate    ${unit_nr} + 1
    END

Check Unit LED Status
    [Documentation]  Keyword takes a path to an object and returns the status of that object, example:
    ...    param:    unit_path = '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1'
    ...    return:   current_unit_status = 'enabled'
    [Arguments]    ${unit_path}
    ${current_unit_status}=    Get Unit Status Via Admin    ${unit_path}
    [Return]    ${current_unit_status}

Configure TLS versions
    [Arguments]                 ${1_2}=false    ${1_3}=false    ${cert_type}=RSA    ${connection}=${NONE}
    ${connection}=              admin_utils.create_connection_if_not_exist
    ...                         connection=${connection}
    ...                         alias=${TEMP_ADMIN_CONN}
    Change Multiple Parameters on BTS
    ...                         dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/MPLANENW-1
    ...                         actEnableTLSv13=${1_3}
    ...                         tls12Enabled=${1_2}
    ...                         connection=${connection}

    Change parameter on BTS     MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                         certTypeForTlsAuth
    ...                         ${cert_type}
    [Teardown]                  Run Keyword And Ignore Error    admin.Disconnect From ADMIN
    ...                         connection=${TEMP_ADMIN_CONN}

Connect to ADMIN
    [Arguments]       ${ip_address}=${LMP_IP}        ${alias}=admin
    ...               ${username}=${WEBEM_USERNAME}  ${password}=${WEBEM_PASSWORD}  ${admin_logs_path}=${None}
    ...               ${timeout}=${90}    ${sw_release}=${None}
    ${date}=	      Get Current Date
    ${status}=        Run Keyword And Return Status    Should Not Be Empty    ${logs_path}
    Run Keyword If    ${status}
    ...               Set Global Variable      ${ADMIN_LOGS_DIR}    ${logs_path}/admin_logs/${date}
    ...    ELSE IF    '${admin_logs_path}' == 'None'
    ...               Set Global Variable      ${ADMIN_LOGS_DIR}    ${OUTPUT DIR}/admin_logs/${date}
    ...       ELSE    Set Global Variable      ${ADMIN_LOGS_DIR}    ${admin_logs_path}/${date}
    ${release_name}=  Run Keyword If    '${sw_release}'=='${None}'    Get Software Release Name
    ...               ip_address=${ip_address}
    ...               username=${username}
    ...               password=${password}
    ...               timeout=${timeout}
    ...               ELSE    Set Variable    ${sw_release}
    ${connection}=    coam_admin.connect_to
    ...               bts_host=${ip_address}
    ...               username=${username}
    ...               password=${password}
    ...               name=${alias}
    ...               release=${release_name}
    ...               admin_api_log_dir=${ADMIN_LOGS_DIR}
    ...               timeout=${timeout}
    [Return]          ${connection}


Get Software Release Name
    [Arguments]       ${ip_address}=${LMP_IP}        ${alias}=rel_name
    ...               ${username}=${WEBEM_USERNAME}  ${password}=${WEBEM_PASSWORD}
    ...               ${timeout}=${30}
    ${connection}=    coam_admin.connect_to
    ...               bts_host=${ip_address}
    ...               username=${username}
    ...               password=${password}
    ...               name=${alias}
    ...               timeout=${timeout}
    ${release_name}=  coam_admin.Get Sw Release Name    connection=${connection}
    [Return]   ${release_name}
    [Teardown]    admin.Disconnect From ADMIN    connection=${alias}

Disconnect from ADMIN
    [Arguments]     ${connection}=admin
    coam_admin.teardown  connection=${connection}

Download SCF
    [Arguments]     ${filename}=scf.xml   ${local_path}=.  ${timeout}=90s   ${connection}=${NONE}
    ${connection}=  admin_utils.create connection if not exist
    ...             connection=${connection}
    ...             alias=download_scf

#    ${dcap_active}=     Run Keyword And Return Status       RFRL Create DCAP Connection
#    ${scf_filepath}=    Run Keyword If       ${dcap_active}
#    ...                   RFRL Collect SCF from BTS DCAP    log_dir=${local_path}
#    ...                                                     with_name=${filename.replace("xml", "zip")}
#    ...                 ELSE
#    ...                   coam_admin.get_current_scf_file        local_dir_path=${local_path}
#    ...                                                     file_name=${filename}
#    ...                                                     timeout=${timeout}
#    ...                                                     connection=${connection}
    ${scf_filepath}=      coam_admin.get_current_scf_file        local_dir_path=${local_path}
    ...                                                     file_name=${filename}
    ...                                                     timeout=${timeout}
    ...                                                     connection=${connection}
    [Teardown]    Run keyword and ignore error
    ...           admin.Disconnect From ADMIN
    ...           connection=download_scf
    [Return]      ${scf_filepath}

Collect Snapshot Admin
    [Arguments]              ${filename}=admin_snapshot.zip   ${local_path}=.  ${timeout}=360s   ${connection}=${NONE}
    ${connection}=           admin_utils.create connection if not exist
    ...                      connection=${connection}
    ...                      alias=collect_snapshot
    ${target_file_name}=     Catenate                   SEPARATOR=/     ${local_path}       ${filename}
    ${snapshot_filepath}=    coam_admin.get_snapshot    target_file_name=${target_file_name}
    ...                                                 timeout=${timeout}
    ...                                                 connection=${connection}
    [Teardown]               Run keyword and ignore error
    ...                      admin.Disconnect From ADMIN
    ...                      connection=collect_snapshot
    [Return]                 ${snapshot_filepath}

eNB Should Be Unavailable
    [Arguments]  ${timeout}=300
    Wait Until Keyword Succeeds  ${timeout}x  1 sec  Run Keyword And Expect Error  *  Ping BTS Mplane IP

Get Active Alarms From BTS
    [Arguments]           ${connection}=${NONE}
    ${connection}=        admin_utils.create connection if not exist
    ...                   connection=${connection}
    ...                   alias=${TEMP_ADMIN_CONN}

    ${active_alarms}=     coam_admin.get_active_alarms
    ...                   connection=${connection}
    ${fault_ids}=         admin_utils.get fault ids from alarms
    ...                   active_alarms=${active_alarms}

    [Return]              ${fault_ids}
    [Teardown]            Run keyword and ignore error
    ...                   admin.Disconnect From ADMIN
    ...                   connection=${TEMP_ADMIN_CONN}

Get current BTS state
    [Arguments]       ${connection}=${NONE}
    ${connection}=    admin_utils.create connection if not exist
    ...               connection=${connection}
    ...               alias=${TEMP_ADMIN_CONN}

    ${statuses}=      coam_admin.get_bts_statuses
    ...               connection=${connection}
    ${state}=         Get From Dictionary
    ...               dictionary=${statuses}
    ...               key=proceduralState

    [Return]          ${state}
    [Teardown]        Run keyword and ignore error
    ...               admin.Disconnect From ADMIN
    ...               connection=${TEMP_ADMIN_CONN}

Get distName For All RMODs
    [Arguments]    ${connection}=${NONE}
    ${connection}=       admin_utils.create connection if not exist
    ...                  connection=${connection}
    ...                  alias=${TEMP_ADMIN_CONN}
    ${frm_info}=         coam_admin.Get Frm
    ...                  connection=${connection}
    ${rmods_distName}=    Create List
    FOR    ${element}    IN    @{frm_info}
        Append To list    ${rmods_distName}    ${element['id']['internal']}
    END
    [Return]             ${rmods_distName}
    [Teardown]           Run keyword and ignore error
    ...                  admin.Disconnect From ADMIN
    ...                  connection=${TEMP_ADMIN_CONN}

Get Id For Current BTS
    [Arguments]  ${connection}=${NONE}
    ${connection}=        admin_utils.create connection if not exist
    ...                   connection=${connection}
    ...                   alias=${TEMP_ADMIN_CONN}
    ${bts_id}=            coam_admin.get_id_for_current
    ...                   class_name=BTS
    ...                   timeout=2400
    ...                   connection=${connection}
    [Return]              ${bts_id}
    [Teardown]            Run keyword and ignore error
    ...                   admin.Disconnect From ADMIN
    ...                   connection=${TEMP_ADMIN_CONN}

Get Ids For All CELLS
    [Arguments]  ${connection}=${NONE}
    ${connection}=        admin_utils.create connection if not exist
    ...                   connection=${connection}
    ...                   alias=${TEMP_ADMIN_CONN}
    ${bts_id}=            coam_admin.get_ids_for_all
    ...                   class_name=LNCEL
    ...                   timeout=2400
    ...                   connection=${connection}
    [Return]              ${bts_id}
    [Teardown]            Run keyword and ignore error
    ...                   admin.Disconnect From ADMIN
    ...                   connection=${TEMP_ADMIN_CONN}

Get Ids For All RMOD
    [Arguments]  ${connection}=${NONE}
    ${connection}=        admin_utils.create connection if not exist
    ...                   connection=${connection}
    ...                   alias=${TEMP_ADMIN_CONN}
    ${bts_id}=            coam_admin.get_ids_for_all
    ...                   class_name=RMOD
    ...                   timeout=2400
    ...                   connection=${connection}
    [Return]              ${bts_id}
    [Teardown]            Run keyword and ignore error
    ...                   admin.Disconnect From ADMIN
    ...                   connection=${TEMP_ADMIN_CONN}

Get Infomodel Path To Object
    [Arguments]    ${search_object}
    Connect to ADMIN     alias=infomodel_object
    ${obj_path_list}=    admin_utils.get_object_path_infomodel    ${search_object}    connection=infomodel_object
    [Return]       ${obj_path_list}
    [Teardown]     Disconnect from ADMIN    connection=infomodel_object

Get NMS Status by ManagerID
    [Arguments]       ${manager_id}  ${connection}=${NONE}
    ${connection}=    admin_utils.create connection if not exist
    ...               connection=${connection}
    ...               alias=${TEMP_ADMIN_CONN}

    ${nms_list}=      coam_admin.get_nms_state
    ...               connection=${connection}
    ${status}=        admin_utils.get nms status
    ...               nms_list=${nms_list}
    ...               manager_id=${manager_id}
    [Return]          ${status}
    [Teardown]        Run keyword and ignore error
    ...               admin.Disconnect From ADMIN
    ...               connection=${TEMP_ADMIN_CONN}

Get Unit Status Via Admin
    [Arguments]    ${unit_path}
    Connect to ADMIN     alias=unit_status
    ${unit_status}=    admin_utils.get_unit_status    ${unit_path}    connection=unit_status
    [Return]       ${unit_status}
    [Teardown]     Disconnect from ADMIN    connection=unit_status

Install Software On BTS
    [Arguments]  ${sw_version}  ${connection}=${NONE}

    ${connection}=        admin_utils.create connection if not exist
    ...                   connection=${connection}
    ...                   alias=${TEMP_ADMIN_CONN}

    coam_admin.wait_sw_update_possible  readiness_timeout=1000    timeout=1200  connection=${connection}
    coam_admin.update_software          sw_package=${sw_version}  timeout=2400  connection=${connection}

    [Teardown]            Run keyword and ignore error
    ...                   admin.Disconnect From ADMIN
    ...                   connection=${TEMP_ADMIN_CONN}

Lock All RMODs on BTS
    [Arguments]  ${connection}=${NONE}  ${timeout}=30
    ${connection}=      admin_utils.create connection if not exist
    ...                 connection=${connection}
    ...                 alias=${TEMP_ADMIN_CONN}
    ${rmods_distName}=   Get distName For All RMODs
    FOR    ${element}    IN    @{rmods_distName}
                        coam_admin.lock
    ...                 dist_name=${element}
    ...                 timeout=${timeout}
    ...                 connection=${connection}
    END
    [Teardown]          Run keyword and ignore error
    ...                 admin.Disconnect From ADMIN
    ...                 connection=${TEMP_ADMIN_CONN}

Perform Configuration Reset
    [Arguments]  ${connection}=${NONE}
    ${connection}=      admin_utils.create connection if not exist
    ...                 connection=${connection}
    ...                 alias=${TEMP_ADMIN_CONN}
    Log  Reset Config Started ...  console=True
    coam_admin.reset_configuration    remove_user_account_credentials=True
    ...                         remove_site_id=True
    ...                         remove_security_credentials=True
    ...                         timeout=1800
    ...                         connection=${connection}
    Log  Reset Config Ended  console=True
    [Teardown]          Run keyword and ignore error
    ...                 admin.Disconnect From ADMIN
    ...                 connection=${TEMP_ADMIN_CONN}

Reboot BTS and wait until available
    admin.Connect to ADMIN
    Log                                 Rebooting BTS [Reset Site]...        console=True
    coam_admin.reset site                    connection=admin  timeout=1200
    Log                                 Shutting down BTS...                 console=True
    sleep                               30    reason=Time to shut down and wake up
    Log                                 Waiting until BTS is up...           console=True
    Wait until keyword succeeds         15 min  20sec  admin.Connect to ADMIN
    [Teardown]  Run keywords            admin.Disconnect From ADMIN

Reset Site And Reconnect
    [Documentation]       Perform site reset and wait for reconnection.
    [Arguments]           ${connection}=${NONE}     ${timeout}=1200   ${wait_for_reconnection}=True
    ${connection}=        admin_utils.create connection if not exist
    ...                   connection=${connection}
    ...                   alias=${TEMP_ADMIN_CONN}

    Log                   Resetting site...
    ...                   console=${TRUE}
    coam_admin.reset_site      connection=${connection}     timeout=${timeout}   wait_for_reconnection=${wait_for_reconnection}

    [Teardown]            Run keyword and ignore error
    ...                   admin.Disconnect From ADMIN
    ...                   connection=${TEMP_ADMIN_CONN}

Rollback Software On BTS
    [Arguments]  ${connection}=${NONE}

    ${connection}=        admin_utils.create connection if not exist
    ...                   connection=${connection}
    ...                   alias=${TEMP_ADMIN_CONN}

    coam_admin.rollback_software  timeout=2400  connection=${connection}

    [Teardown]            Run keyword and ignore error
    ...                   admin.Disconnect From ADMIN
    ...                   connection=${TEMP_ADMIN_CONN}

Setup Local user account
    [Documentation]       Perform setup Local User Account
    ...                   Account type:    BTSSecurity, BTSApplication, BTSRead
    [Arguments]           ${account_type}    ${new_password}    ${old_password}=${EMPTY}    ${connection}=${NONE}
    ${connection}=        admin_utils.create connection if not exist
    ...                   connection=${connection}
    ...                   alias=${TEMP_ADMIN_CONN}
    Log  Setup ${account_type} account    console=true
    coam_admin.set_user_account    old_username=${account_type}
    ...                       old_password=${old_password}
    ...                       new_password=${new_password}
    ...                       connection=${connection}
    ${account_type}       admin_utils.parse_local_user_name    ${account_type}
    coam_admin.change_local_account_state     account_type=${account_type}
    ...                                  enable=true
    ...                                  connection=${connection}

    [Teardown]            Run keyword and ignore error
    ...                   Disconnect from ADMIN
    ...                   connection=${TEMP_ADMIN_CONN}

Change Local User Account Credentials
    [Arguments]               ${old_username}    ${old_password}    ${new_username}    ${new_password}
    ${connection}=            Connect to ADMIN    username=${old_username}    password=${old_password}
    Log to console            Changing username and password for ${old_username}
    coam_admin.set_user_account    old_username=${old_username}
    ...                       old_password=${old_password}
    ...                       new_username=${new_username}
    ...                       new_password=${new_password}
    ...                       connection=${connection}
    [Teardown]                Run keyword and ignore error
    ...                       Disconnect from ADMIN    ${connection}

Change Local User Account Username
    [Arguments]               ${old_username}    ${old_password}    ${new_username}
    ${connection}=            Connect to ADMIN    username=${old_username}    password=${old_password}
    Log to console            Changing username for ${old_username}
    coam_admin.set_user_account    old_username=${old_username}
    ...                       old_password=${old_password}
    ...                       new_username=${new_username}
    ...                       connection=${connection}
    [Teardown]                Run keyword and ignore error
    ...                       Disconnect from ADMIN    ${connection}

Change Local User Account Password
    [Arguments]               ${old_username}    ${old_password}    ${new_password}
    ${connection}=            Connect to ADMIN    username=${old_username}    password=${old_password}
    Log to console            Changing username and password for ${old_username}
    coam_admin.set_user_account    old_username=${old_username}
    ...                       old_password=${old_password}
    ...                       new_password=${new_password}
    ...                       connection=${connection}
    [Teardown]                Run keyword and ignore error
    ...                       Disconnect from ADMIN    ${connection}

Turn Off TLS
    [Arguments]  ${skip_parameter_relation_errors}=${FALSE}
    [Documentation]
    ...             This keyword turn Off TLS protocol on gNB with coam_admin.

    ${TEMP_ADMIN_CONN}=             Connect to ADMIN
    Change Parameter On BTS         dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                             param_name=oamTls
    ...                             param_value=off
    ...                             skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...                             connection=${TEMP_ADMIN_CONN}
    Log           TLS turned OFF    console=True
    [Teardown]    coam_admin.Teardown    connection=${TEMP_ADMIN_CONN}

Turn On TLS
    [Arguments]  ${skip_parameter_relation_errors}=${FALSE}
    [Documentation]
    ...             This keyword turn On TLS protocol on gNB with coam_admin.

    ${TEMP_ADMIN_CONN}=             Connect to ADMIN
    Change Parameter On BTS         dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                             param_name=oamTls
    ...                             param_value=forced
    ...                             skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...                             connection=${TEMP_ADMIN_CONN}
    Log           TLS turned ON     console=True
    [Teardown]    coam_admin.Teardown    connection=${TEMP_ADMIN_CONN}

Unblock All Cells on BTS
    [Arguments]  ${connection}=${NONE}  ${rat}=NR
    ${connection}=             admin_utils.create connection if not exist
    ...                        connection=${connection}
    ...                        alias=${TEMP_ADMIN_CONN}
    coam_admin.unblock_all_cells    rat=${rat}
    ...                        timeout=2400
    ...                        connection=${connection}
    [Teardown]                 Run keyword and ignore error
    ...                        admin.Disconnect From ADMIN
    ...                        connection=${TEMP_ADMIN_CONN}

Unblock on BTS
    [Arguments]  ${mrbts_path}  ${connection}=${NONE}
    ${connection}=        admin_utils.create connection if not exist
    ...                   connection=${connection}
    ...                   alias=${TEMP_ADMIN_CONN}
    coam_admin.unblock         dist_name=${mrbts_path}
    ...                   timeout=2400
    ...                   connection=${connection}
    [Teardown]            Run keyword and ignore error
    ...                   admin.Disconnect From ADMIN
    ...                   connection=${TEMP_ADMIN_CONN}

Unlock All RMODs on BTS
    [Arguments]  ${connection}=${NONE}  ${timeout}=30
    ${connection}=       admin_utils.create connection if not exist
    ...                  connection=${connection}
    ...                  alias=${TEMP_ADMIN_CONN}
    ${rmods_distName}=   Get distName For All RMODs
    FOR    ${element}    IN    @{rmods_distName}
                         coam_admin.unlock
    ...                  dist_name=${element}
    ...                  timeout=${timeout}
    ...                  connection=${connection}
    END
    [Teardown]           Run keyword and ignore error
    ...                  admin.Disconnect From ADMIN
    ...                  connection=${TEMP_ADMIN_CONN}

Wait until BTS reach Configured or OnAir state
    [Arguments]                  ${connection}=${NONE}
    Log                          Waiting until BTS reach OnAir, Configured or IntegratedToRan state...
    ...                          console=${TRUE}
    ${connection}=               admin_utils.create connection if not exist
    ...                          connection=${connection}
    ...                          alias=${TEMP_ADMIN_CONN}_loop

    Wait Until Keyword Succeeds  30 min  20sec
    ...                          admin.Check If BTS Status Is Configured Or OnAir
    ...                          connection=${connection}

    [Teardown]                   Run keyword and ignore error
    ...                          admin.Disconnect From ADMIN
    ...                          connection=${TEMP_ADMIN_CONN}_loop

Wait until BTS reach state
    [Arguments]                  ${state}    ${connection}=${NONE}
    Log                          Waiting until BTS reach ${state} state...
    ...                          console=${TRUE}
    ${connection}=               admin_utils.create connection if not exist
    ...                          connection=${connection}
    ...                          alias=${TEMP_ADMIN_CONN}_loop

    Wait Until Keyword Succeeds  30 min  20sec
    ...                          Check if BTS in given state
    ...                          state=${state}
    ...                          connection=${connection}

    [Teardown]                   Run keyword and ignore error
    ...                          admin.Disconnect From ADMIN
    ...                          connection=${TEMP_ADMIN_CONN}_loop

Wait Until NMS in Not Connected Status
    [Arguments]                   ${manager_id}  ${connection}=${NONE}
    Log                           Waiting until NMS reach NotConnected state...
    ...                           console=${TRUE}
    ${connection}=                admin_utils.create connection if not exist
    ...                           connection=${connection}
    ...                           alias=${TEMP_ADMIN_CONN}_loop

    Wait Until Keyword Succeeds   10 min   20 sec
    ...                           Check If NMS In Expected Status
    ...                           manager_id=${manager_id}
    ...                           expected_status=notConnected
    ...                           connection=${connection}

    [Teardown]                    Run keyword and ignore error
    ...                           admin.Disconnect From ADMIN
    ...                           connection=${TEMP_ADMIN_CONN}_loop

Wait Until NMS in Secured Status
    [Arguments]                   ${manager_id}  ${connection}=${NONE}
    Log                           Waiting until NMS reach Secured state...
    ...                           console=${TRUE}
    ${connection}=                admin_utils.create connection if not exist
    ...                           connection=${connection}
    ...                           alias=${TEMP_ADMIN_CONN}_loop

    Wait Until Keyword Succeeds   20 min   20 sec
    ...                           Check If NMS In Expected Status
    ...                           manager_id=${manager_id}
    ...                           expected_status=secured
    ...                           connection=${connection}

    [Teardown]                    Run keyword and ignore error
    ...                           admin.Disconnect From ADMIN
    ...                           connection=${TEMP_ADMIN_CONN}_loop

Check If All Cells Are In Enabled State
    [Arguments]  ${cell_type}=NRCEL  ${connection}=${NONE}
    Log    Checking Cells    console=True
    ${cells}=    coam_admin.get_ids_for_all    ${cell_type}    connection=${connection}
    FOR    ${cell}    IN    @{cells}
        ${info}=    coam_admin.get_parameters    dist_name=${cell}
        ...         connection=${connection}
        ${opState}=    Get From Dictionary    ${info}    operationalState
        Should Be Equal    ${opState}    enabled    ${cell} is not enabled
    END

Check Cells
    [Arguments]  ${connection}=${NONE}
    ${is_LTE}=  Run Keyword And Return Status  coam_admin.assert_any  class_name=LNBTS  connection=${connection}
    Run Keyword If  ${is_LTE}==${True}  Wait Until Keyword Succeeds
    ...     15x
    ...     2min
    ...     Check If All Cells Are In Enabled State  cell_type=LNCEL  connection=${connection}
    ${is_NR}=  Run Keyword And Return Status  coam_admin.assert_any  class_name=BTS  connection=${connection}
    Run Keyword If  ${is_NR}==${True}  Wait Until Keyword Succeeds
    ...     15x
    ...     2min
    ...     Check If All Cells Are In Enabled State  cell_type=NRCEL  connection=${connection}
    ${statuses}=  Create List  ${is_LTE}  ${is_NR}
    Should Contain  ${statuses}  ${True}  msg=Cells heve not been detected!

Wait Until RU Will Automatically Reboot
    [Arguments]    ${connection}=${None}
    Wait Until Keyword Succeeds    15x    1min
    ...                            Check If All RUs operationalState have expected value   expected_value=[Dd]isabled    bts_host=${MPLANE_IPV4}
    Wait Until Keyword Succeeds    15x    1min
    ...                            Check If All RUs operationalState have expected value   expected_value=[Ee]nabled    bts_host=${MPLANE_IPV4}
    Check Cells    connection=${connection}

Check If All RUs operationalState have expected value
    [Arguments]    ${expected_value}  ${bts_host}=${LMP_IP}
    Log    Checking If RU operational state is ${expected_value}    console=True
    ${result}=  admin_utils.check_if_all_rus_operationalStates_have_expected_value  ${expected_value}  ${bts_host}
    Should Be True  ${result}

Check SMOD state is Online
    ${connection}=     coam_admin.connect_to
    ${output}=     coam_admin.get_fsm_info    timeout=30    connection=${connection}
    :FOR   ${elem}   IN    @{output}
        Should Contain    ${elem['status']['proceduralStatus']}      configured      ignore_case=True
    END

Wait until SMOD Online
    [Arguments]    ${retry}=300   ${retry_interval}=10
    Wait until keyword succeeds    ${retry}     ${retry_interval}    Check SMOD state is Online

Reset Local User Credentials By Removing users.json
	${connection}=  Connect To BTS
    Log  Reseting reset counter to prevent SW Fallback    console=true
	ssh.Execute    command=ddal -s ddal_boot_set_reset_loop_count 0
	...            connection=${connection}
	Log  Removing file: /ffs/run/config/users.json  console=true
	${console_output}=  ssh.Execute     command=rm /ffs/run/config/users.json
	...                                 connection=${connection}
	Should Not Contain  ${console_output}  No such file or directory
	Log  File removed! Now rebooting BTS...  console=true
	ssh.Execute     command=ddal -s ddal_reboot_sm_site_graceful DDAL_REBOOT_SM_SHELF_SIDE_OWN
	...             connection=${connection}
	Wait Until Keyword Succeeds    5min    30sec    Wait Until BTS Reach Configured Or OnAir State
	Log  Default credentails restored!  console=true

Cancel Collecting Snapshot From BTS
    [Documentation]       Cancel ongoing operation of collecting snapshot from BTS
    [Arguments]     ${timeout}=360s   ${connection}=${NONE}
    ${connection}=  admin_utils.create connection if not exist
    ...             connection=${connection}
    ...             alias=collect_snapshot
    coam_admin.snapshot_cancel    timeout=${timeout}    connection=${connection}
    [Teardown]    Run keyword and ignore error
    ...           admin.Disconnect From ADMIN
    ...           connection=collect_snapshot

Perform Reset and Wait for Expected State
    [Arguments]    ${state}
    admin.Connect to ADMIN
    Log                            Rebooting BTS [Reset Site]...        console=True
    coam_admin.reset site          timeout=900    connection=admin
    Log                            Shutting down BTS...    console=True
    Sleep    30s                   reason=Time to shut down and wake up
    Log                            Waiting until BTS is up...    console=True
    Wait Until Keyword Succeeds    15 min    20sec    Connect to ADMIN
    Wait Until Keyword Succeeds    15 min    20sec    Check if BTS in given state    state=${state}    connection=admin
    [Teardown]                     Disconnect From ADMIN
