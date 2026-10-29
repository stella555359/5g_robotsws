*** Settings ***
Documentation    Author: tomasz.blaszczyszyn@nokia.com; kacper.halas@nokia.com; filip.radwanski@nokia.com; michal.laski@nokia.com
...              Maintainer: tomasz.blaszczyszyn@nokia.com; kacper.halas@nokia.com; filip.radwanski@nokia.com; michal.laski@nokia.com
...              Description: These keywords handles actions performed with coam library refering to ADMIN functionalities
...              FT in charge: name + mailing list
...              Confluence link:
...              References: (documentation link(e.g. doors or sphinx))
...              QualityCenter: (test set url to QC)
...              Sample execution:

Library          OperatingSystem
Library          taf.sbts.oam.coam.admin    WITH NAME    coam
#Library          taf.collectors.infomodel

*** Variables ***
${ADMIN_BTS_HOST}=                  192.168.255.129
${ADMIN_BTS_PORT}=                  443
${ADMIN_USERNAME}=                  Nemuadmin
${ADMIN_PASSWORD}=                  nemuuser
${ADMIN_USE_SSL}=                   True
${ADMIN_UPDATE_INTERVAL}=           5000
${ADMIN_API_LOG_DIR}=               ${OUTPUT_DIR}
${ADMIN_TIMEOUT}=                   30
${ADMIN_ALIAS}=                     admin_1

*** Keywords ***
ADMIN Setup Admin
    [Arguments]    ${bts_host}=${ADMIN_BTS_HOST}
    ...            ${bts_port}=${ADMIN_BTS_PORT}
    ...            ${username}=${ADMIN_USERNAME}
    ...            ${password}=${ADMIN_PASSWORD}
    ...            ${use_ssl}=${ADMIN_USE_SSL}
    ...            ${update_interval}=${ADMIN_UPDATE_INTERVAL}
    ...            ${admin_api_log_dir}=${ADMIN_API_LOG_DIR}
    ...            ${timeout}=${ADMIN_TIMEOUT}
    ...            ${alias}=${ADMIN_ALIAS}
    coam.Setup Admin    bts_host=${bts_host}
    ...                      bts_port=${bts_port}
    ...                      username=${username}
    ...                      password=${password}
    ...                      use_ssl=${use_ssl}
    ...                      update_interval=${update_interval}
    ...                      admin_api_log_dir=${admin_api_log_dir}
    ...                      timeout=${timeout}
    ...                      alias=${alias}

ADMIN Abort Software Update
    [Arguments]    ${timeout}=60
    ...            ${alias}=${ADMIN_ALIAS}
    coam.Abort Software Update    timeout=${timeout}
    ...                                alias=${alias}

ADMIN Activate Plan
    [Arguments]    ${plan_id}
    ...            ${timeout}=300
    ...            ${alias}=${ADMIN_ALIAS}
    coam.Activate Plan    plan_id=${plan_id}
    ...                        timeout=${timeout}
    ...                        alias=${alias}

ADMIN Add Allowed Alarm
    [Arguments]    ${fault_id}
    ...            ${alarm_id}=None
    ...            ${alarm_severity}=None
    ...            ${notifier}=None
    ...            ${fault_name}=None
    ...            ${alias}=${ADMIN_ALIAS}
    coam.Add Allowed Alarm   faultId=${fault_id}
    ...                                         alarmId=${alarm_id}
    ...                                         severity=${alarm_severity}
    ...                                         notifier=${notifier}
    ...                                         faultName=${fault_name}
    ...                                         alias=${alias}

ADMIN Add Allowed Alarms
    [Arguments]    ${faults_list}
    ...            ${alias}=${ADMIN_ALIAS}
    FOR  ${index}  IN  @{faults_list}
        ADMIN Add Allowed Alarm   fault_id=&{index}[fault_id]
        ...    alarm_id=&{index}[alarm_id]
        ...    alarm_severity=&{index}[alarm_severity]
        ...    notifier=&{index}[notifier]
        ...    fault_name=&{index}[fault_name]
        ...    alias=${alias}
    END

ADMIN Assert
    [Arguments]    ${class_name}
    ...            ${id}
    ...            ${parameters}
    ...            ${alias}=${ADMIN_ALIAS}
    ...            ${timeout}=60
    coam.Assert    class_name=${class_name}
    ...                 id=${id}
    ...                 parameters=${parameters}
    ...                 timeout=${timeout}
    ...                 alias=${alias}

ADMIN Assert No
    [Arguments]    ${class_name}
    ...            ${parameters}
    ...            ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    coam.Assert No    class_name=${class_name}
    ...                    parameters=${parameters}
    ...                    timeout=${timeout}
    ...                    alias=${alias}

ADMIN Assert Alarm Active
    [Arguments]    ${fault_id}
    ...            ${alarm_id}
    ...            ${alarm_severity}
    ...            ${alarm_resource}
    ...            ${fault_name}
    ...            ${timeout}=30
    ...            ${alias}=${ADMIN_ALIAS}
    coam.Assert Alarm Active    parameters=faultId=${fault_id}
    ...                                            alarmId=${alarm_id}
    ...                                            severity=${alarm_severity}
    ...                                            alarmingResource=${alarm_resource},
    ...                                            faultName=${fault_name}
    ...                                            timeout=${timeout}
    ...                                            alias=${alias}

ADMIN Assert Many Alarms Active
    [Arguments]    ${faults_parameters}
    ...            ${timeout}=30
    ...            ${alias}=${ADMIN_ALIAS}
   FOR    ${index}    IN    @{faults_parameters}
        ADMIN Assert Alarm Active    fault_parameters=${index}
        ...    timeout=${timeout}
        ...    alias=${alias}
    END

ADMIN Assert Alarm Inactive
    [Arguments]    ${fault_id}
    ...            ${alarm_id}
    ...            ${alarm_severity}
    ...            ${alarm_resource}
    ...            ${fault_name}
    ...            ${timeout}=50
    ...            ${alias}=${ADMIN_ALIAS}
    coam.Assert Alarm Inactive  parameters=faultId=${fault_id}
    ...                                            alarmId=${alarm_id}
    ...                                            severity=${alarm_severity}
    ...                                            alarmingResource=${alarm_resource},
    ...                                            faultName=${fault_name}
    ...                                            timeout=${timeout}
    ...                                            alias=${alias}

ADMIN Assert Many Alarms Inactive
    [Arguments]    ${faults_parameters}
    ...            ${timeout}=30
    ...            ${alias}=${ADMIN_ALIAS}
    FOR    ${index}    IN    @{faults_parameters}
        ADMIN Assert Alarm Inactive    fault_parameters=${index}
        ...    timeout=${timeout}
        ...    alias=${alias}
    END

ADMIN Assert Any
    [Arguments]    ${class_name}
    ...            ${parameters}
    ...            ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    coam.Assert Any    class_name=${class_name}
    ...                     parameters=${parameters}
    ...                     timeout=${timeout}
    ...                     alias=${alias}

ADMIN Assert Every
    [Arguments]    ${class_name}
    ...            ${parameters}
    ...            ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    coam.Assert Every    class_name=${class_name}
    ...                       parameters=${parameters}
    ...                       timeout=${timeout}
    ...                       alias=${alias}

ADMIN Assert No Unexpected Active Alarms
    [Arguments]    ${alias}=admin_1
    coam.Assert No Unexpected Active Alarms    alias=${alias}

ADMIN Assert No Unexpected Historical Alarms
    [Arguments]    ${load_history}=False
    ...            ${timeout}=60
	...            ${alias}=${ADMIN_ALIAS}
    coam.Assert No Unexpected Historical Alarms    load_history=${load_history}
	...                                                 timeout=${timeout}
    ...                                                 alias=${alias}

ADMIN Assert No Unexpected Active And Historical Alarms
    ADMIN Assert No Unexpected Active Alarms
    ADMIN Assert No Unexpected Historical Alarms

ADMIN Lock
    [Arguments]    ${dist_name}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_ALIAS}
    coam.Lock    dist_name=${dist_name}
    ...                timeout=${timeout}
    ...                alias=${alias}

ADMIN Unlock
    [Arguments]    ${dist_name}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_ALIAS}
    coam.Unlock    dist_name=${dist_name}
    ...                  timeout=${timeout}
    ...                  alias=${alias}

ADMIN Block Bts
    [Arguments]
    ...            ${timeout}=60
	...            ${detailed_output}=${False}
    ...            ${alias}=${ADMIN_ALIAS}
    coam.Block
	...                timeout=${timeout}
	...                detailed_output=${detailed_output}
    ...                connection=${alias}

ADMIN Unblock Bts
    [Arguments]
    ...            ${wait_for_reconnection}=${True}
	...            ${timeout}=60
	...            ${detailed_output}=${False}
    ...            ${alias}=${ADMIN_ALIAS}
    coam.Unblock
    ...                  wait_for_reconnection=${wait_for_reconnection}
	...                  timeout=${timeout}
	...                  detailed_output=${detailed_output}
    ...                  connection=${alias}

ADMIN Block Cell
    [Arguments]
    ...            ${dist_name}
    ...            ${timeout}=60
    ...            ${detailed_output}=${False}
    ...            ${alias}=${ADMIN_ALIAS}
    coam.Block cell
    ...                 dist_name=${dist_name}
    ...                 timeout=${timeout}
    ...                 detailed_output=${detailed_output}
    ...                 connection=${alias}

ADMIN Unblock Cell
    [Arguments]
    ...            ${dist_name}
    ...            ${timeout}=60
    ...            ${detailed_output}=${False}
    ...            ${alias}=${ADMIN_ALIAS}
    coam.Unblock cell
    ...                 dist_name=${dist_name}
    ...                 timeout=${timeout}
    ...                 detailed_output=${detailed_output}
    ...                 connection=${alias}

ADMIN Block All Cells           #Zmiana nazwy keyworda na ADMIN Block All Cells From Specific RAT
    [Arguments]
    ...            ${rat}
    ...            ${timeout}=60
    ...            ${detailed_output}=${False}
    ...            ${alias}=${ADMIN_ALIAS}
    coam.Block All Cells
    ...                 rat=${rat}
    ...                 timeout=${timeout}
    ...                 detailed_output=${detailed_output}
    ...                 connection=${alias}

ADMIN Unblock All Cells         #Zmiana nazwy keyworda na ADMIN Unblock All Cells From Specific RAT
    [Arguments]
    ...            ${rat}
    ...            ${timeout}=60
    ...            ${detailed_output}=${False}
    ...            ${alias}=${ADMIN_ALIAS}
    coam.Unblock All Cells
    ...                 rat=${rat}
    ...                 timeout=${timeout}
    ...                 detailed_output=${detailed_output}
    ...                 connection=${alias}

ADMIN Block Cell By Cell Id
    [Arguments]    ${cell_id}
    ADMIN Block Cell    dist_name=${cell_id}

ADMIN Unblock Cell By Cell Id
    [Arguments]    ${cell_id}
    ADMIN Unblock Cell    dist_name=${cell_id}

ADMIN Block All Cells By Cell Id
    [Arguments]    ${cells_id_list}
    FOR    ${index}    IN    ${cells_id_list}
        ADMIN Block Cell By Cell Id    cell_id=${index}
    END

ADMIN Unblock All Cells By Cell Id
    [Arguments]    ${cells_id_list}
    FOR    ${index}    IN    ${cells_id_list}
        ADMIN Unblock Cell By Cell Id    cell_id=${index}
    END

ADMIN Block Lncel And Check Blocking State Is Blocked
#Zmiana nazwy keyworda na ADMIN Block LTE Cell And Check If Blocking State Is Blocked
    [Arguments]    ${cell_id}
    ADMIN Block Cell By Cell Id    cell_id=${cell_id}
    ADMIN Assert Cell With Cell Id Is In Blocked State    cell_id=${cell_id}

ADMIN Block LTE Cell And Check If Blocking State Is Blocked
    [Arguments]    ${cell_id}
    ADMIN Block Cell By Cell Id    cell_id=${cell_id}
    ADMIN Assert Cell With Cell Id Is In Blocked State    cell_id=${cell_id}

ADMIN Unblock Lncel And Check Blocking State Is Unblocked
#Zmiana nazwy keyworda na ADMIN Block LTE Cell And Check If Blocking State Is Blocked
    [Arguments]    ${cell_id}
    ADMIN Unblock Cell By Cell Id    cell_id=${cell_id}
    ADMIN Assert Cell With Cell Id Is In Unblocked State    cell_id=${cell_id}

ADMIN Block All Lncels And Check Blocking State Is Blocked
#Zmiana nazwy keyworda na ADMIN Block All LTE Cells And Check If Blocking State Is Blocked
    [Arguments]    ${lncels_id_list}
    FOR    ${index}    IN    @{lncels_id_list}
        ADMIN Block Lncel And Check Blocking State Is Blocked    cell_id=${index}
    END

ADMIN Block All LTE Cells And Check If Blocking State Is Blocked
    [Arguments]    ${lncels_id_list}
    FOR    ${index}    IN    @{lncels_id_list}
        ADMIN Block Lncel And Check Blocking State Is Blocked    cell_id=${index}
    END

ADMIN Unblock All Lncels And Check Blocking State Is Unblocked
#Zmiana nazwy keyworda na ADMIN Unblock All LTE Cells And Check If Blocking State Is Unblocked
    [Arguments]    ${lncels_id_list}
    FOR    ${index}    IN    @{lncels_id_list}
        ADMIN Unblock Lncel And Check Blocking State Is Unblocked    cell_id=${index}
    END

ADMIN Unblock All LTE Cells And Check If Blocking State Is Unblocked
    [Arguments]    ${lncels_id_list}
    FOR    ${index}    IN    @{lncels_id_list}
        ADMIN Unblock Lncel And Check Blocking State Is Unblocked    cell_id=${index}
    END

ADMIN Lock Rmod By Rmod Id
    [Arguments]    ${rmod_id}
    ADMIN Lock    dist_name=${rmod_id}

ADMIN Unlock Rmod By Rmod Id
    [Arguments]    ${rmod_id}
    ADMIN Unlock    dist_name=${rmod_id}

ADMIN Lock All Rmods By Rmod Id
    [Arguments]    ${rmods_id_list}
    FOR    ${index}    IN    @{rmods_id_list}
        ADMIN Lock Rmod By Rmod Id    rmod_id=${index}
    END

ADMIN Unlock All Rmods By Rmod Id
    [Arguments]    ${rmods_id_list}
    FOR    ${index}    IN    @{rmods_id_list}
        ADMIN Unlock Rmod By Rmod Id    rmod_id=${index}
    END

ADMIN Lock Rmod And Check Blocking State Is Locked
#Zmiana nazwy keyworda na ADMIN Lock RMOD And Check If Its Administrative State Is Locked
    [Arguments]    ${rmod_id}
    ADMIN Lock Rmod By Rmod Id   rmod_id=${rmod_id}
    ADMIN Assert Rmod With Rmod Id Is In Locked State    rmod_id=${rmod_id}

ADMIN Lock RMOD And Check If Its Administrative State Is Locked
    [Arguments]    ${rmod_id}
    ADMIN Lock Rmod By Rmod Id   rmod_id=${rmod_id}
    ADMIN Assert Rmod With Rmod Id Is In Locked State    rmod_id=${rmod_id}

ADMIN Unlock Rmod And Check Blocking State Is Unlocked
#Zmiana nazwy keyworda na ADMIN Unlock RMOD And Check If Its Administrative State Is Unlocked
    [Arguments]    ${rmod_id}
    ADMIN Unlock Rmod By Rmod Id   rmod_id=${rmod_id}
    ADMIN Assert Rmod With Rmod Id Is In Unlocked State    rmod_id=${rmod_id}

ADMIN Unlock RMOD And Check If Its Administrative State Is Unlocked
    [Arguments]    ${rmod_id}
    ADMIN Unlock Rmod By Rmod Id   rmod_id=${rmod_id}
    ADMIN Assert Rmod With Rmod Id Is In Unlocked State    rmod_id=${rmod_id}

ADMIN Lock All Rmods And Check Blocking State Is Locked
#Zmiana nazwy keyworda na ADMIN Lock All Rmods And Check If Its Administrative States Are Locked
    [Arguments]    ${rmods_id_list}
    FOR    ${index}    IN    @{rmods_id_list}
        ADMIN Lock Rmod And Check Blocking State Is Locked    rmod_id=${index}
    END

ADMIN Lock All RMODs And Check If Its Administrative States Are Locked
    [Arguments]    ${rmods_id_list}
    FOR    ${index}    IN    @{rmods_id_list}
        ADMIN Lock Rmod And Check Blocking State Is Locked    rmod_id=${index}
    END

ADMIN Unlock All Rmods And Check Blocking State Is Unlocked
#Zmiana nazwy keyworda na ADMIN Unlock All Rmods And Check If Its Administrative States Are Unlocked
    [Arguments]    ${rmods_id_list}
    FOR    ${index}    IN    @{rmods_id_list}
        ADMIN Unlock Rmod And Check Blocking State Is Unlocked    rmod_id=${index}
    END

ADMIN Unlock All Rmods And Check If Its Administrative States Are Unlocked
    [Arguments]    ${rmods_id_list}
    FOR    ${index}    IN    @{rmods_id_list}
        ADMIN Unlock Rmod And Check Blocking State Is Unlocked    rmod_id=${index}
    END

ADMIN Clear Allowed Alarm List
    [Arguments]    ${alias}=${ADMIN_ALIAS}
    coam.Clear Allowed Alarms List    alias=${alias}

ADMIN Collect IM Snapshot
    [Arguments]    ${snapshot_name}=${ADMIN_API_LOG_DIR}/IM_Snapshot.ims2
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_ALIAS}
    coam.Collect IM Snapshot    target_file_name=${snapshot_name}
    ...                              timeout=${timeout}
    ...                              alias=${alias}
    ADMIN Verify IMS Saved Correctly    filename=${snapshot_name}

ADMIN Verify IMS Saved Correctly
    [Arguments]    ${filename}
    ${ims_status}=    Run Keyword And Return Status
    ...    OperatingSystem.File Should Exist
    ...    path=${filename}
    ${ims_status}=    Run Keyword And Return Status
    ...    OperatingSystem.File Should Not Be Empty
    ...    path=${filename}
    ${warn}=    Evaluate  "\\033[33mWARN\\033[0m"
    Run Keyword If    not ${ims_status}
    ...    Log To Console    [ ${warn} ] IMS Log saving failed.

ADMIN Collect Keyword Result
    [Arguments]    ${background_process}
    ...            ${timeout}=120
    ${out_background_process_result}=    coam.Collect Keyword Result    task=${background_process}
    ...                                                                      timeout=${timeout}
    [Return]    ${out_background_process_result}

ADMIN Collect PM Files
    [Arguments]    ${target_file_name}=PM_Files.zip
    ...            ${timeout}=120
    ...            ${alias}=${ADMIN_ALIAS}
    coam.Collect PM Files    target_file_name=${target_file_name}
    ...                           timeout=${timeout}
    ...                           alias=${alias}

ADMIN Collect Raw Alarm History File
    [Arguments]    ${target_file_name}
    ...            ${timeout}=120
    ...            ${alias}=${ADMIN_ALIAS}
    coam.Collect Raw Alarm History File    target_file_name=${target_file_name}
    ...                                         timeout=${timeout}
    ...                                         alias=${alias}

ADMIN Get Current Scf File
    [Arguments]    ${local_dir_path}
    ...            ${file_name}
    ...            ${timeout}=30
    ...            ${export_type}=None
    ...            ${parameters_save_variant}=None
    ...            ${alias}=${ADMIN_ALIAS}

    coam.Get Current Scf File    local_dir_path=${local_dir_path}
    ...                                         file_name=${file_name}
    ...                                         timeout=${timeout}
    ...                                         export_type=${export_type}
    ...                                         parameters_save_variant=${parameters_save_variant}
    ...                                         connection=${alias}

ADMIN Collect Scf
    [Arguments]    ${target_file_name}
    ...            ${export_type}=None
    ...            ${timeout}=120
    ...            ${parameters_save_variant}=None
    ...            ${alias}=${ADMIN_ALIAS}

    coam.Collect Scf    target_file_name=${target_file_name}
    ...                                    export_type=${export_type}
    ...                                    timeout=${timeout}
    ...                                    parameters_save_variant=${parameters_save_variant}
    ...                                    alias=${alias}

ADMIN Collect Snapshot
    [Arguments]    ${snapshot_name}=${ADMIN_API_LOG_DIR}/Snapshot.zip
    ...            ${coverage}=Full
    ...            ${force}=True
    ...            ${timeout}=900
    ...            ${alias}=${ADMIN_ALIAS}
    coam.Collect Snapshot    target_file_name=${snapshot_name}
    ...                           coverage=${coverage}
    ...                           force=${force}
    ...                           timeout=${timeout}
    ...                           alias=${alias}

ADMIN Disable Ethernet Port Security
    [Arguments]    ${timeout}=60
    ...            ${alias}=${ADMIN_ALIAS}
    coam.Disable Ethernet Port Security    timeout=${timeout}
    ...                                         alias=${alias}

ADMIN Enable Ethernet Port Security
    [Arguments]    ${timeout}=60
    ...            ${alias}=${ADMIN_ALIAS}
    coam.Enable Ethernet Port Security    timeout=${timeout}
    ...                                        alias=${alias}

ADMIN Enable SSH Access
    [Arguments]    ${timeout}=30
    ...            ${alias}=${ADMIN_ALIAS}
    coam.enable_ssh_access    timeout=${timeout}
    ...                            alias=${alias}

ADMIN Disable SSH Access
    [Arguments]    ${timeout}=30
    ...            ${alias}=${ADMIN_ALIAS}
    coam.disable_ssh_access    timeout=${timeout}
    ...                             alias=${alias}

ADMIN Download And Activate Software
    [Arguments]    ${host}
    ...            ${port}
    ...            ${target_bd}
    ...            ${should_activate}=True
    ...            ${timeout}=600
    ...            ${alias}=${ADMIN_ALIAS}
    Download And Update Software    host=${host}
    ...                                       port=${port}
    ...                                       target_bd=${target_bd}
    ...                                       should_activate=${should_activate}
    ...                                       timeout=${timeout}
    ...                                       alias=${alias}

ADMIN Download And Dont Activate Software
    [Arguments]    ${host}
    ...            ${port}
    ...            ${target_bd}
    ...            ${should_activate}=False
    ...            ${timeout}=300
    ...            ${alias}=${ADMIN_ALIAS}
    coam.Download And Update Software    host=${host}
    ...                                       port=${port}
    ...                                       target_bd=${target_bd}
    ...                                       should_activate=${should_activate}
    ...                                       timeout=${timeout}
    ...                                       alias=${alias}

ADMIN Get Active Alarms
    [Arguments]    ${severity}=None
    ...            ${timeout}=120
    ...            ${alias}=${ADMIN_ALIAS}
    Log    ${severity}
    ${out_alarms objects_list}=    coam.Get Active Alarms
    ...                                                           timeout=${timeout}
    ...                                                           alias=${alias}
    [Return]    ${out_alarms objects_list}

ADMIN Get Adj Id By Configuration Id
    [Arguments]    ${configuration_id}
    ...            ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_adj_id}=    coam.Get Adj Id By Configuration Id    configuration_id=${configuration_id}
    ...                                                           timeout=${timeout}
    ...                                                           alias=${alias}
    [Return]    ${out_adj_id}

ADMIN Get ALD ID By Module Connector
    [Arguments]    ${module_id}
    ...            ${connector_label}=None
    ...            ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_ald_id}=    coam.Get Ald Id By Module Connector    module_id=${module_id}
    ...                                                           connector_label=${connector_label}
    ...                                                           timeout=${timeout}
    ...                                                           alias=${alias}
    [Return]    ${out_ald_id}

ADMIN Get Autoconnection Status
    [Arguments]    ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_autoconnection_status}=    coam.Get_Autoconnection_Status    timeout=${timeout}
    ...                                                                     alias=${alias}
    [Return]    ${out_autoconnection_status}

ADMIN Bbu Id By Node Id     #Keyword name change to ADMIN Get BBU ID By Module Connector
    [Arguments]    ${node_id}
    ...            ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_bbu_id}=    coam.Get Bbu Id By Module Connector    node_id=${node_id}
    ...                                                           timeout=${timeout}
    ...                                                           alias=${alias}
    [Return]    ${out_bbu_id}

ADMIN Get BBU ID By Module Connector
    [Arguments]    ${node_id}
    ...            ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_bbu_id}=    coam.Get Bbu Id By Module Connector    node_id=${node_id}
    ...                                                           timeout=${timeout}
    ...                                                           alias=${alias}
    [Return]    ${out_bbu_id}

ADMIN Get Bts Rad Parameters
    [Arguments]    ${component}
    ...            ${type}
    ...            ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    coam.Get Bts Rad Parameters    component=${component}
    ...                                 type=${type}
    ...                                 timeout=${timeout}
    ...                                 alias=${alias}

ADMIN Get Bts Sync Mode
    [Arguments]    ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_bts_sync_mode}=    coam.Get Bts Sync Mode    timeout=${timeout}
    ...                                                     alias=${alias}
    [Return]    ${out_bts_sync_mode}

ADMIN Get Bts Time Zone
    [Arguments]    ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_bts_time_zone}=    coam.Get Bts Time Zone    timeout=${timeout}
    ...                                                     alias=${alias}
    [Return]    ${out_bts_time_zone}

ADMIN Get Cell Id By Configuration Id
    [Arguments]    ${rat}
    ...            ${configuration_id}
    ...            ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_cell_id}=    coam.Get Cell Id By Configuration Id    rat=${rat}
    ...                                                             configuration_id=${configuration_id}
    ...                                                             alias=${alias}
    ...                                                             timeout=${timeout}
    [Return]    ${out_cell_id}

ADMIN Get Cell Mapping By Module Id
    [Arguments]    ${module_id}
    ...            ${connector_label}=None
    ...            ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_cell_id}=    coam.Get Cell Mapping By Module Id    module_id=${module_id}
    ...                                                           connector_label=${connector_label}
    ...                                                           timeout=${timeout}
    ...                                                           alias=${alias}
    [Return]    ${out_cell_id}

ADMIN Get Historic Alarms
    [Arguments]
    ...            ${timeout}=60
    ...            ${severity}=${None}
    ...            ${load_history}=${False}
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_alarms_objects_list}=    coam.Get Historic Alarms
    ...                                                     timeout=${timeout}
    ...                                                     severity=${severity}
    ...                                                     load_history=${load_history}
    ...                                                     connection=${alias}
    [Return]    ${out_alarms_objects_list}

ADMIN Get Historical Critical Alarms
    ${out_alarms_objects_list}=    ADMIN Get Historic Alarms   severity=critical
    [Return]    ${out_alarms_objects_list}

ADMIN Get Historical Major Alarms
    ${out_alarms_objects_list}=    ADMIN Get Historic Alarms   severity=major
    [Return]    ${out_alarms_objects_list}

ADMIN Get Historical Minor Alarms
    ${out_alarms_objects_list}=    ADMIN Get Historic Alarms   severity=Mmnor
    [Return]    ${out_alarms_objects_list}

ADMIN Get Historical Warning Alarms
    ${out_alarms_objects_list}=    ADMIN Get Historic Alarms   severity=warning
    [Return]    ${out_alarms_objects_list}

ADMIN Get Id For Current
    [Arguments]    ${class_name}
    ...            ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_current_id}=    coam.Get Id For Current    class_name=${class_name}
    ...                                                   timeout=${timeout}
    ...                                                   alias=${alias}
    [Return]    ${out_current_id}

ADMIN Get Id For Current SMOD
    ${out_current_smod_id}=    ADMIN Get Id For Current    class_name=SMOD
    [Return]    ${out_current_smod_id}

ADMIN Get Id For Current BTS
    ${out_current_bts_id}=    ADMIN Get Id For Current    class_name=BTS
    [Return]    ${out_current_bts_id}

ADMIN Get Id For Current LNBTS
    ${out_current_lnbts_id}=    ADMIN Get Id For Current    class_name=LNBTS
    [Return]    ${out_current_lnbts_id}

ADMIN Get Id For Current WNBTS
    ${out_current_wnbts_id}=    ADMIN Get Id For Current    class_name=WNBTS
    [Return]    ${out_current_wnbts_id}

ADMIN Get Id For Current GNBTS
    ${out_current_gnbts_id}=    ADMIN Get Id For Current    class_name=GNBTS
    [Return]    ${out_current_gnbts_id}

ADMIN Get Ids For All
    [Arguments]    ${class_name}
    ...            ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_unit_ids_list}=        coam.Get Ids For All    class_name=${class_name}
    ...                                                       timeout=${timeout}
    ...                                                       alias=${alias}
    [Return]    ${out_unit_ids_list}

ADMIN Get Ids For All SMOD
    ${out_smod_ids_list}=    ADMIN Get Ids For All    class_name=SMOD
    [Return]    ${out_smod_ids_list}

ADMIN Get Ids For All BTS
    ${out_bts_ids_list}=    ADMIN Get Ids For All    class_name=BTS
    [Return]    ${out_bts_ids_list}

ADMIN Get Ids For All BBMOD
    ${out_bbmod_ids_list}=    ADMIN Get Ids For All    class_name=BBMOD
    [Return]    ${out_bbmod_ids_list}

ADMIN Get Ids For All RMOD
    ${out_rmod_ids_list}=    ADMIN Get Ids For All    class_name=RMOD
    [Return]    ${out_rmod_ids_list}

ADMIN Get Ids For All ALD
    ${out_ald_ids_list}=    ADMIN Get Ids For All    class_name=ALD
    [Return]    ${out_ald_ids_list}

ADMIN Get Ids For All LNCEL
    ${out_lncel_ids_list}=    ADMIN Get Ids For All    class_name=LNCEL
    [Return]    ${out_lncel_ids_list}

ADMIN Get Ids For All GNCEL
    ${out_gncel_ids_list}=    ADMIN Get Ids For All    class_name=GNCEL
    [Return]    ${out_gncel_ids_list}

ADMIN Get Ids For All WNCEL
    ${out_wncel_ids_list}=    ADMIN Get Ids For All    class_name=WNCEL
    [Return]    ${out_wncel_ids_list}

ADMIN Get Module Id By Bbu Id
    [Arguments]    ${bbu_id}
    ...            ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_module_id}=    coam.Get Module Id By Bbu Id    bbu_id=${bbu_id}
    ...                                                       timeout=${timeout}
    ...                                                       alias=${alias}
    [Return]    ${out_module_id}

ADMIN Get Module Id By Node Id
    [Arguments]    ${node_id}
    ...            ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_module_id}=    coam.Get Module Id By Node Id    node_id=${node_id}
    ...                                                        timeout=${timeout}
    ...                                                        alias=${alias}
    [Return]    ${out_module_id}

ADMIN Get Mrbts State
    [Arguments]    ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_mrbts_state}=    coam.Get Mrbts State    timeout=${timeout}
    ...                                                 alias=${alias}
    [Return]    ${out_mrbts_state}

ADMIN Get Nms State
    [Arguments]    ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_nms_state}=    coam.Get Nms State    timeout=${timeout}
    ...                                             alias=${alias}
    [Return]    ${out_nms_state}

ADMIN Get Parameters For
    [Arguments]    ${class_name}
    ...            ${id_num}
    ...            ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_parameters_dict}=    coam.Get Parameters For   class_name=${class_name}
    ...                                                       id_num=${id_num}
    ...                                                       timeout=${timeout}
    ...                                                       alias=${alias}
    [Return]    ${out_parameters_dict}

ADMIN Get Parameters For SMOD By Id
    [Arguments]    ${id}=1
    ${out_smod_parameters_dict}=    ADMIN Get Parameters For    class_name=SMOD
    ...                                                         id=${id}
    ...                                                         timeout=10
    ...                                                         alias=${ADMIN_ALIAS}
    [Return]    ${out_smod_parameters_dict}

ADMIN Get Parameters For BTS By Id
    [Arguments]    ${id}=1
    ${out_bts_parameters_dict}=    ADMIN Get Parameters For    class_name=BTS
    ...                                                        id=${id}
    ...                                                        timeout=10
    ...                                                        alias=${ADMIN_ALIAS}
    [Return]    ${out_bts_parameters_dict}

ADMIN Get Parameters For BBMOD By Id
    [Arguments]    ${id}=1
    ${out_bbmod_parameters_dict}=    ADMIN Get Parameters For    class_name=BBMOD
    ...                                                        id=${id}
    ...                                                        timeout=10
    ...                                                        alias=${ADMIN_ALIAS}
    [Return]    ${out_bbmod_parameters_dict}

ADMIN Get Parameters For RMOD By Id
    [Arguments]    ${id}=1
    ${out_rmod_parameters_dict}=    ADMIN Get Parameters For    class_name=RMOD
    ...                                                         id=${id}
    ...                                                         timeout=10
    ...                                                         alias=${ADMIN_ALIAS}
    [Return]    ${out_rmod_parameters_dict}

ADMIN Get Parameters For ALD By Id
    [Arguments]    ${id}=1
    ${out_ald_parameters_dict}=    ADMIN Get Parameters For    class_name=ALD
    ...                                                        id=${id}
    ...                                                        timeout=10
    ...                                                        alias=${ADMIN_ALIAS}
    [Return]    ${out_ald_parameters_dict}

ADMIN Get Parameters For LNCEL By Id
    [Arguments]    ${id}=1
    ${out_lncel_parameters_dict}=    ADMIN Get Parameters For    class_name=LNCEL
    ...                                                          id=${id}
    ...                                                          timeout=10
    ...                                                          alias=${ADMIN_ALIAS}
    [Return]    ${out_lncel_parameters_dict}

ADMIN Get Parameters For WNCEL By Id
    [Arguments]    ${id}=1
    ${out_wncel_parameters_dict}=    ADMIN Get Parameters For    class_name=WNCEL
    ...                                                          id=${id}
    ...                                                          timeout=10
    ...                                                          alias=${ADMIN_ALIAS}
    [Return]    ${out_wncel_parameters_dict}

ADMIN Get Parameters For GNCEL By Id
    [Arguments]    ${id}=1
    ${out_gncel_parameters_dict}=    ADMIN Get Parameters For    class_name=GNCEL
    ...                                                          id=${id}
    ...                                                          timeout=10
    ...                                                          alias=${ADMIN_ALIAS}
    [Return]    ${out_gncel_parameters_dict}

ADMIN Get Parameters For All
    [Arguments]    ${class_name}
    ...            ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_list_of_parameters_dict}=    coam.Get Parameters For All   class_name=${class_name}
    ...                                                                   timeout=${timeout}
    ...                                                                   connection=${alias}
    [Return]    ${out_list_of_parameters_dict}

ADMIN Get Parameters For All SMOD
    [Arguments]    ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_list_of_smod_parameters_dict}=    ADMIN Get Parameters For All    class_name=SMOD
    ...                                                                     timeout=${timeout}
    ...                                                                     alias=${alias}
    [Return]    ${out_list_of_smod_parameters_dict}

ADMIN Get Parameters For All BBMODs
    [Arguments]    ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_list_of_bbmods_parameters_dict}=    ADMIN Get Parameters For All    class_name=BBMOD
    ...                                                                       timeout=${timeout}
    ...                                                                       alias=${alias}
    [Return]    ${out_list_of_bbmods_parameters_dict}

ADMIN Get Parameters For All BTS
    [Arguments]    ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_list_of_bts_parameters_dict}=    ADMIN Get Parameters For All    class_name=BTS
    ...                                                                    timeout=${timeout}
    ...                                                                    alias=${alias}
    [Return]    ${out_list_of_bts_parameters_dict}

ADMIN Get Parameters For All RMODs
    [Arguments]    ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_list_of_rmod_parameters_dict}=    ADMIN Get Parameters For All    class_name=RMOD
    ...                                                                     timeout=${timeout}
    ...                                                                     alias=${alias}
    [Return]    ${out_list_of_rmod_parameters_dict}

ADMIN Get Parameters For All ALDs
    [Arguments]    ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_list_of_ald_parameters_dict}=    ADMIN Get Parameters For All    class_name=ALD
    ...                                                                    timeout=${timeout}
    ...                                                                    alias=${alias}
    [Return]    ${out_list_of_ald_parameters_dict}

ADMIN Get Parameters For All LNCELs
    [Arguments]    ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_list_of_lncel_parameters_dict}=    ADMIN Get Parameters For All    class_name=LNCEL
    ...                                                                      timeout=${timeout}
    ...                                                                      alias=${alias}
    [Return]    ${out_list_of_lncel_parameters_dict}

ADMIN Get Parameters For All NRCELs
    [Arguments]    ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_list_of_nrcel_parameters_dict}=    ADMIN Get Parameters For All    class_name=NRCEL
    ...                                                                      timeout=${timeout}
    ...                                                                      alias=${alias}
    [Return]    ${out_list_of_nrcel_parameters_dict}

ADMIN Get Parameters For All WNCELs
    [Arguments]    ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_list_of_wncel_parameters_dict}=    ADMIN Get Parameters For All    class_name=WNCEL
    ...                                                                      timeout=${timeout}
    ...                                                                      alias=${alias}
    [Return]    ${out_list_of_wncel_parameters_dict}

ADMIN Get Parameters For All GNCELs
    [Arguments]    ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_list_of_gncel_parameters_dict}=    ADMIN Get Parameters For All    class_name=GNCEL
    ...                                                                      timeout=${timeout}
    ...                                                                      alias=${alias}
    [Return]    ${out_list_of_gncel_parameters_dict}

ADMIN Get Counters Info
    [Arguments]    ${dist_name}=all
    ...            ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_pm_counters_list}=    coam.Get Counters Info    dist_name=${dist_name}
    ...                                                      timeout=${timeout}
    ...                                                      connection=${alias}
    [Return]    ${out_pm_counters_list}

ADMIN Get Raw Alarm History File
    [Arguments]    ${timeout}=120
    ...            ${alias}=${ADMIN_ALIAS}
    coam.Get Raw Alarm History File    timeout=${timeout}
    ...                                     alias=${alias}

ADMIN Get Rmod Id By Module Connector
    [Arguments]    ${module_id}
    ...            ${connector_label}=None
    ...            ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    Log    ${timeout}
    ${out_rmod_id}=    coam.Get Rmod Id By Module Connector        module_id=${module_id}
    ...                                                                 connector_label=${connector_label}
    ...                                                                 timeout=10
    ...                                                                 alias=${alias}
    [Return]    ${out_rmod_id}

ADMIN Get Scf
    [Arguments]    ${export_type}=None
    ...            ${timeout}=120
    ...            ${parameters_save_variant}=None
    ...            ${detailed_output}=False
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_scfc_file_content}=    coam.Get Scf    export_type=${export_type}
    ...                                               timeout=${timeout}
    ...                                               parameters_save_variant=${parameters_save_variant}
    ...                                               detailed_output=${detailed_output}
    ...                                               alias=${alias}
    [Return]    ${out_scfc_file_content}

ADMIN Get Sfp Id By Module Connector
    [Arguments]    ${module_id}
    ...            ${connector_label}=None
    ...            ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    Log    ${timeout}
    ${out_sfp_id}=    coam.Get Sfp Id By Module Connector   module_id=${module_id}
    ...                                                          connector_label=${connector_label}
    ...                                                          timeout=10
    ...                                                          alias=${alias}
    [Return]    ${out_sfp_id}

ADMIN Get Sfp Links
    [Arguments]    ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_sfp_links_list}=    coam.Get Sfp Links    timeout=${timeout}
    ...                                                  alias=${alias}
    [Return]    ${out_sfp_links_list}

ADMIN Get Smod Position
    [Arguments]    ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_smod_position}=    coam.Get Smod Position    timeout=${timeout}
    ...                                                     alias=${alias}
    [Return]    ${out_smod_position}

ADMIN Get Software Info
    [Arguments]    ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_software_info}=    coam.Get Software Info    timeout=${timeout}
    ...                                                     alias=${alias}
    [Return]    ${out_software_info}

ADMIN Get Trs Autoconnection Status
    [Arguments]    ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_trs_autoconnection_status}=    coam.Get Trs Autoconnection Status    timeout=${timeout}
    ...                                                                             alias=${alias}
    [Return]    ${out_trs_autoconnection_status}

ADMIN Get User Login Info
    [Arguments]    ${timeout}=60
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_user_login_info}=    coam.Get User Login Info    timeout=${timeout}
    ...                                                         alias=${alias}
    [Return]    ${out_user_login_info}

ADMIN Migrate Scf
    [Arguments]    ${input_scf_file}
    ...            ${output_scf_file}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_ALIAS}
    coam.Migrate Scf    input_scf_file=${input_scf_file}
    ...                      output_scf_file=${output_scf_file}
    ...                      timeout=${timeout}
    ...                      alias=${alias}

ADMIN Perform Commissioning
    [Arguments]    ${bts_id}
    ...            ${scf_file}
    ...            ${skip_parameter_relation_errors}=False
    ...            ${should_activate}=True
    ...            ${timeout}=300
    ...            ${alias}=${ADMIN_ALIAS}
    coam.Perform Commissioning    bts_id=${bts_id}
    ...                                scf_file=${scf_file}
    ...                                skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...                                should_activate=${should_activate}
    ...                                timeout=${timeout}
    ...                                alias=${alias}

ADMIN Perform Delta Recommissioning
    [Arguments]    ${delta_file}
    ...            ${skip_parameter_relation_errors}=False
    ...            ${should_activate}=True
    ...            ${timeout}=300
    ...            ${alias}=${ADMIN_ALIAS}
    coam.Perform Delta Recommissioning    delta_file=${delta_file}
    ...                                        skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...                                        should_activate=${should_activate}
    ...                                        timeout=${timeout}
    ...                                        alias=${alias}

ADMIN Perform Parameter Recommissioning
    [Arguments]    ${dist_name}
    ...            ${parameter}
    ...            ${value}
    ...            ${operation}
    ...            ${skip_parameter_relation_errors}=${TRUE}
    ...            ${should_activate}=${TRUE}
    ...            ${timeout}=300
    ...            ${connection}=${ADMIN_ALIAS}
    coam.Perform Parameter Recommissioning
    ...                     dist_name=${dist_name}
    ...                     parameter=${parameter}
    ...                     value=${value}
    ...                     operation=${operation}
    ...                     skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...                     should_activate=${should_activate}
    ...                     timeout=${timeout}
    ...                     connection=${connection}

ADMIN Perform Parameter Update
    [Arguments]    ${dist_name}
    ...            ${parameter}
    ...            ${value}
    ...            ${timeout}=300
    ...            ${alias}=${ADMIN_ALIAS}
    ADMIN Perform Parameter Recommissioning    dist_name=${dist_name}
    ...                                        parameter=${parameter}
    ...                                        operation=update
    ...                                        value=${value}
    ...                                        timeout=${timeout}
    ...                                        connection=${alias}

ADMIN Perform Parameter Create
    [Arguments]    ${dist_name}
    ...            ${parameter}
    ...            ${value}
    ...            ${timeout}=300
    ...            ${alias}=${ADMIN_ALIAS}
    ADMIN Perform Parameter Recommissioning    dist_name=${dist_name}
    ...                                        parameter=${parameter}
    ...                                        operation=create
    ...                                        value=${value}
    ...                                        timeout=${timeout}
    ...                                        connection=${alias}

ADMIN Perform Parameter Delete
    [Arguments]    ${dist_name}
    ...            ${parameter}
    ...            ${value}
    ...            ${timeout}=300
    ...            ${alias}=${ADMIN_ALIAS}
    ADMIN Perform Parameter Recommissioning    dist_name=${dist_name}
    ...                                        parameter=${parameter}
    ...                                        operation=delete
    ...                                        value=${value}
    ...                                        timeout=${timeout}
    ...                                        connection=${alias}

ADMIN Reset Bts Rad Parameters
    [Arguments]    ${component}
    ...            ${params}
    ...            ${timeout}=300
    ...            ${alias}=${ADMIN_ALIAS}
    coam.Reset Bts    component=${component}
    ...                    params=${params}
    ...                    timeout=${timeout}
    ...                    alias=${alias}

ADMIN Reset Configuration
    [Arguments]    ${remove_operator_certificates}=False
    ...            ${remove_user_account_credentials}=False
    ...            ${detailed_output}=False
    ...            ${timeout}=300
    ...            ${alias}=${ADMIN_ALIAS}
    coam.Reset Configuration    remove_operator_certificates=${remove_operator_certificates}
    ...                              remove_user_account_credentials=${remove_user_account_credentials}
    ...                              timeout=${timeout}
    ...                              detailed_output=${detailed_output}
    ...                              alias=${alias}

ADMIN Reset Rat
    [Arguments]    ${rat}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_ALIAS}
    coam.Reset Rat   rat_type=${rat}
    ...                   timeout=${timeout}
    ...                   alias=${alias}

ADMIN Reset LTE
    ADMIN Reset Rat    rat=LTE

ADMIN Reset WCDMA
    ADMIN Reset Rat    rat=WCDMA

ADMIN Reset GSM
    ADMIN Reset Rat    rat=GSM

ADMIN Reset NR
    ADMIN Reset Rat    rat=NR

ADMIN Reset Site
    [Arguments]    ${timeout}=300
    ...            ${wait_for_reconnection}=True
    ...            ${detailed_output}=False
    ...            ${alias}=${ADMIN_ALIAS}
    coam.Reset Site   timeout=${timeout}
    ...                     wait_for_reconnection=${wait_for_reconnection}
    ...                     detailed_output=${detailed_output}
    ...                     connection=${alias}

#ADMIN Reset Unit
#    [Arguments]    ${dist_name}
#    ...            ${timeout}=120
#    ...            ${alias}=${ADMIN_ALIAS}
#    ute_admin.Reset Unit   dist_name=${dist_name}
#    ...                    timeout=${timeout}
#    ...                    alias=${alias}

ADMIN Reset Unit
    [Arguments]    ${dist_name}
    ...            ${reset_type}=Soft
    ...            ${force_radio_reset}=False
    ...            ${timeout}=120
    ...            ${detailed_output}=False
    ...            ${alias}=${ADMIN_ALIAS}
    coam.Reset Unit   dist_name=${dist_name}
    ...                        reset_type=${reset_type}
    ...                        force_radio_reset=${force_radio_reset}
    ...                        timeout=${timeout}
    ...                        detailed_output=${detailed_output}
    ...                        connection=${alias}

ADMIN Reset Rmod By Rmod Id
    [Arguments]    ${rmod_id}
    ADMIN Reset Unit    ${rmod_id}

ADMIN Reset All Rmods
    [Arguments]    ${rmods_id_list}
    FOR    ${index}    IN    @{rmods_id_list}
        ADMIN Reset Rmod By Rmod Id    ${index}
    END

ADMIN Rollback Software
    [Arguments]    ${timeout}=300
    ...            ${detailed_output}=False
    ...            ${alias}=${ADMIN_ALIAS}
    coam.Rollback Software   timeout=${timeout}
    ...                           detailed_output=${detailed_output}
    ...                           connection=${alias}

ADMIN Run Keyword In Background
    [Arguments]    ${background_process}
    ...            ${alias}=${ADMIN_ALIAS}     @{args}    &{kwargs}
    ${out_background_process}=    coam.Run Keyword In Background   name=${background_process}
    ...                                                                               alias=${alias}   &{kwargs}
    [Return]    ${out_background_process}

ADMIN Send Hwapi Api Alarm Msg
    [Arguments]    ${sender}
    ...            ${receiver}
    ...            ${fault_id}
    ...            ${unit_id}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_ALIAS}
    coam.Send Hwapi Api Alarm Msg   sender=${sender}
    ...                                  receiver=${receiver}
    ...                                  fault_id=${fault_id}
    ...                                  unit_id=${unit_id}
    ...                                  timeout=${timeout}
    ...                                  alias=${alias}

ADMIN Send Hwapi Api Sfp Status Ind Msg
    [Arguments]    ${sender}
    ...            ${receiver}
    ...            ${board_id}
    ...            ${sfp_connector_id}
    ...            ${status_type}
    ...            ${status}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_ALIAS}
    coam.Send Hwapi Api Sfp Status Ind Msg   sender=${sender}
    ...                                           receiver=${receiver}
    ...                                           board_id=${board_id}
    ...                                           sfp_connector_id=${sfp_connector_id}
    ...                                           status_type=${status_type}
    ...                                           status=${status}
    ...                                           timeout=${timeout}
    ...                                           alias=${alias}

ADMIN Send Hwapi Api2 Alarm Msg
    [Arguments]    ${sender}
    ...            ${receiver}
    ...            ${fault_state}
    ...            ${fault_id}
    ...            ${unit_id}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_ALIAS}
    coam.Send Hwapi Api2 Alarm Msg    sender=${sender}
    ...                                    receiver=${receiver}
    ...                                    fault_state=${fault_state}
    ...                                    fault_id=${fault_id}
    ...                                    unit_id=${unit_id}
    ...                                    timeout=${timeout}
    ...                                    alias=${alias}

ADMIN Send Hwapi Send Fault Report
    [Arguments]    ${sender}
    ...            ${receiver}
    ...            ${fault_id}
    ...            ${unit_id}
    ...            ${state}
    ...            ${severity}
    ...            ${object_type}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_ALIAS}
    coam.Send Hwapi Send Fault Report   sender=${sender}
    ...                                      receiver=${receiver}
    ...                                      fault_id=${fault_id}
    ...                                      unit_id=${unit_id}
    ...                                      state=${state}
    ...                                      severity=${severity}
    ...                                      object_type=${object_type}
    ...                                      timeout=${timeout}
    ...                                      alias=${alias}

ADMIN Send Lom Fault Ind Msg
    [Arguments]    ${sender}
    ...            ${receiver}
    ...            ${fault_id}
    ...            ${unit_id}
    ...            ${state}
    ...            ${severity}
    ...            ${object_type}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_ALIAS}
    coam.Send Lom Fault Ind Msg    sender=${sender}
    ...                                 receiver=${receiver}
    ...                                 fault_id=${fault_id}
    ...                                 unit_id=${unit_id}
    ...                                 state=${state}
    ...                                 severity=${severity}
    ...                                 object_type=${object_type}
    ...                                 timeout=${timeout}
    ...                                 alias=${alias}

ADMIN Send Fault Ind Msg
    [Arguments]    ${sender}
    ...            ${receiver}
    ...            ${fault_id}
    ...            ${state}
    ...            ${alias}=${ADMIN_ALIAS}
    coam.Send Fault Ind Msg    sender=${sender}
    ...                             receiver=${receiver}
    ...                             fault_id=${fault_id}
    ...                             state=${state}
    ...                             alias=${alias}

ADMIN Send Lom Fault Request Msg
    [Arguments]    ${sender}
    ...            ${receiver}
    ...            ${fault_id}
    ...            ${unit_id}
    ...            ${subunit_id}
    ...            ${faulty_cpid}
    ...            ${state}
    ...            ${severity}
    ...            ${object_type}
    ...            ${detecting_unit}
    ...            ${detecting_subunit}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_ALIAS}
    coam.Send Lom Fault Request Msg    sender=${sender}
    ...                                     receiver=${receiver}
    ...                                     fault_id=${fault_id}
    ...                                     unit_id=${unit_id}
    ...                                     subunit_id=${subunit_id}
    ...                                     faulty_cpid=${faulty_cpid}
    ...                                     state=${state}
    ...                                     severity=${severity}
    ...                                     object_type=${object_type}
    ...                                     detecting_unit=${detecting_unit}
    ...                                     detecting_subunit=${detecting_subunit}
    ...                                     timeout=${timeout}
    ...                                     alias=${alias}


ADMIN Send Saa Pro Ce Cpu Load Over Load Ind Msg
    [Arguments]    ${sender}
    ...            ${receiver}
    ...            ${status}
    ...            ${type}
    ...            ${normal_cpu_load}
    ...            ${background_cpu_load}
    ...            ${irq_cpu_load}
    ...            ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    coam.Send Saa Pro Ce Cpu Load Over Load Ind Msg    sender=${sender}
    ...                                                     receiver=${receiver}
    ...                                                     status=${status}
    ...                                                     type=${type}
    ...                                                     normal_cpu_load=${normal_cpu_load}
    ...                                                     background_cpu_load=${background_cpu_load}
    ...                                                     irq_cpu_load=${irq_cpu_load}
    ...                                                     timeout=${timeout}
    ...                                                     alias=${alias}

ADMIN Send Saa Pro Ce Memory Over Load Ind Msg
    [Arguments]    ${sender}
    ...            ${receiver}
    ...            ${status}
    ...            ${memory_usage}
    ...            ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    coam.Send Saa Pro Ce Memory Over Load Ind Msg    sender=${sender}
    ...                                                   receiver=${receiver}
    ...                                                   status=${status}
    ...                                                   memory_usage=${memory_usage}
    ...                                                   timeout=${timeout}
    ...                                                   alias=${alias}

ADMIN Start Ip Capture File
    [Arguments]    ${measurement_point}
    ...            ${uplane_capturing}
    ...            ${password}
    ...            ${timeout}=120
    ...            ${alias}=${ADMIN_ALIAS}
    coam.Start Ip Capture File    measurement_point=${measurement_point}
    ...                                uplane_capturing=${uplane_capturing}
    ...                                password=${password}
    ...                                timeout=${timeout}
    ...                                alias=${alias}

ADMIN Ip Capture Streaming
    [Arguments]    ${measurement_point}
    ...            ${uplane_capturing}
    ...            ${dst_mac_addr}
    ...            ${timeout}=120
    ...            ${alias}=${ADMIN_ALIAS}
    coam.Ip Capture Streaming   measurement_point=${measurement_point}
    ...                              uplane_capturing=${uplane_capturing}
    ...                              dst_mac_addr=${dst_mac_addr}
    ...                              egress_port_dn=${egress_port_dn}
    ...                              timeout=${timeout}
    ...                              alias=${alias}

ADMIN Stop Ip Capture File
    [Arguments]    ${timeout}=120
    ...            ${alias}=${ADMIN_ALIAS}
    coam.Stop Ip Capture File    timeout=${timeout}
    ...                               alias=${alias}

ADMIN Stop Ip Capture Streaming
    [Arguments]    ${timeout}=120
    ...            ${alias}=${ADMIN_ALIAS}
    coam.Stop Ip Capture Streaming    timeout=${timeout}
    ...                                    alias=${alias}

ADMIN Teardown Admin
    [Arguments]    ${alias}=${ADMIN_ALIAS}
    coam.Teardown Admin   alias=${alias}

ADMIN Update Software
    [Arguments]    ${sw_package}
    ...            ${should_activate}
    ...            ${timeout}=240
    ...            ${alias}=${ADMIN_ALIAS}
    coam.Update Software    sw_package=${sw_package}
    ...                          should_activate=${should_activate}
    ...                          timeout=${timeout}
    ...                          alias=${alias}

ADMIN Update Software With Activation
    [Arguments]    ${sw_package}
    ...            ${timeout}=240
    ...            ${alias}=${ADMIN_ALIAS}
    ADMIN Update Software    sw_package=${sw_package}
    ...                      should_activate=True
    ...                      timeout=${timeout}
    ...                      alias=${alias}

ADMIN Update Software Without Activation
    [Arguments]    ${sw_package}
    ...            ${timeout}=240
    ...            ${alias}=${ADMIN_ALIAS}
    ADMIN Update Software    sw_package=${sw_package}
    ...                      should_activate=False
    ...                      timeout=${timeout}
    ...                      alias=${alias}

ADMIN Validate Scf
    [Arguments]    ${scf_file}
    ...            ${skip_parameter_relation_errors}=False
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_ALIAS}
    coam.Validate Scf    scf_file=${scf_file}
    ...                       skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...                       timeout=${timeout}
    ...                       alias=${alias}

ADMIN Assert All Bbmods Are In Expected State
    [Arguments]    ${state_type}
    ...            ${expected_state}
    ...            ${timeout}=10
    ADMIN Assert Every    parameters=${state_type}=${expected_state}
    ...                   timeout=${timeout}
    ...                   class_name=BBMOD

ADMIN Assert All Bbmods Are In Expected Procedural State
    [Arguments]    ${expected_state}
    ...            ${timeout}=10
    ADMIN Assert All Bbmods Are In Expected State   expected_state=${expected_state}
    ...                                             state_type=proceduralState
    ...                                             timeout=${timeout}

ADMIN Assert All Bbmods Are In Expected Blocking State
    [Arguments]    ${expected_state}
    ...            ${timeout}=10
    ADMIN Assert All Bbmods Are In Expected State    expected_state=${expected_state}
    ...                                              state_type=blockingState
    ...                                              timeout=${timeout}

ADMIN Assert All Bbmods Are In Expected Administrative State
    [Arguments]    ${expected_state}
    ...            ${timeout}=10
    ADMIN Assert All Bbmods Are In Expected State    expected_state=${expected_state}
    ...                                              state_type=administrativeState
    ...                                              timeout=${timeout}

ADMIN Assert All Bbmods Are In Expected Operational State
    [Arguments]    ${expected_state}
    ...            ${timeout}=10
    ADMIN Assert All Bbmods Are In Expected State    expected_state=${expected_state}
    ...                                              state_type=operationalState
    ...                                              timeout=${timeout}

ADMIN Assert All Bbmods Are In Expected Availability State
    [Arguments]    ${expected_state}
    ...            ${timeout}=10
    ADMIN Assert All Bbmods Are In Expected State    expected_state=${expected_state}
    ...                                              state_type=availabilityStatus
    ...                                              timeout=${timeout}

ADMIN Assert All Bbmods Are In Locked State
    [Arguments]    ${timeout}=10
    ADMIN Assert All Bbmods Are In Expected Administrative State    timeout=${timeout}
    ...                                                             expected_state=regex"Locked|locked"

ADMIN Assert All Bbmods Are In Unlocked State
    [Arguments]    ${timeout}=10
    ADMIN Assert All Bbmods Are In Expected Administrative State    timeout=${timeout}
    ...                                                             expected_state=regex"Unlocked|unlocked"

ADMIN Assert All Bbmods Are In Enabled State
    [Arguments]    ${timeout}=10
    ADMIN Assert All Bbmods Are In Expected Operational State    timeout=${timeout}
    ...                                                          expected_state=regex"Enabled|enabled"

ADMIN Assert All Bbmods Are In Disabled State
    [Arguments]    ${timeout}=10
    ADMIN Assert All Bbmods Are In Expected Operational State    timeout=${timeout}
    ...                                                          expected_state=regex"Disabled|disabled"

ADMIN Assert All Bbmods Are In Online State
    [Arguments]    ${timeout}=10
    ADMIN Assert All Bbmods Are In Expected Availability State    timeout=${timeout}
    ...                                                           expected_state=regex"Online|"

ADMIN Assert All Bbmods Are In Offline State
    [Arguments]    ${timeout}=10
    ADMIN Assert All Bbmods Are In Expected Availability State    timeout=${timeout}
    ...                                                           expected_state=regex"Offline|off line"

ADMIN Assert Bbmod Is In Expected State
    [Arguments]    ${bbmod_id}
    ...            ${state_type}
    ...            ${expected_state}
    ...            ${timeout}=10
    ADMIN Assert    id=${bbmod_id}
    ...             parameters=${state_type}=${expected_state}
    ...             timeout=${timeout}
    ...             class_name=BBMOD


ADMIN Assert Bbmod Is In Expected Administrative State
    [Arguments]    ${bbmod_id}
    ...            ${expected_state}
    ...            ${timeout}=10
    ADMIN Assert Bbmod Is In Expected State   bbmod_id=${bbmod_id}
    ...                                                     expected_state=${expected_state}
    ...                                                     timeout=${timeout}
    ...                                                     state_type=administrativeState

ADMIN Assert Bbmod Is In Expected Operational State
    [Arguments]    ${bbmod_id}
    ...            ${expected_state}
    ...            ${timeout}
    ADMIN Assert Bbmod Is In Expected State    bbmod_id=${bbmod_id}
    ...                                                      expected_state=${expected_state}
    ...                                                      timeout=${timeout}
    ...                                                      state_type=operationalState

ADMIN Assert Bbmod Is In Expected Availability State
    [Arguments]    ${bbmod_id}
    ...            ${expected_state}
    ...            ${timeout}=10
    ADMIN Assert Bbmod Is In Expected State    bbmod_id=${bbmod_id}
    ...                                                      expected_state=${expected_state}
    ...                                                      timeout=${timeout}
    ...                                                      state_type=availabilityStatus

ADMIN Assert Bbmod Is In Locked State
    [Arguments]    ${bbmod_id}
    ...            ${timeout}=10
    ADMIN Assert Bbmod Is In Expected Administrative State    bbmod_id=${bbmod_id}
    ...                                                       timeout=${timeout}
    ...                                                       expected_state=regex"Locked|locked"

ADMIN Assert Bbmod Is In Unlocked State
    [Arguments]    ${bbmod_id}
    ...            ${timeout}=10
    ADMIN Assert Bbmod Is In Expected Administrative State    bbmod_id=${bbmod_id}
    ...                                                       timeout=${timeout}
    ...                                                       expected_state=regex"Unlocked|unlocked"

ADMIN Assert Bbmod Is In Enabled State
    [Arguments]    ${bbmod_id}
    ...            ${timeout}=10
    ADMIN Assert Bbmod Is In Expected Operational State    bbmod_id=${bbmod_id}
    ...                                                    timeout=${timeout}
    ...                                                    expected_state=regex"Enabled|enabled"

ADMIN Assert Bbmod Is In Disabled State
    [Arguments]    ${bbmod_id}
    ...            ${timeout}=10
    ADMIN Assert Bbmod Is In Expected Operational State    bbmod_id=${bbmod_id}
    ...                                                    timeout=${timeout}
    ...                                                    expected_state=regex"Disabled|disabled"

ADMIN Assert Bbmod Is In Online State
    [Arguments]    ${bbmod_id}
    ...            ${timeout}=10
    ADMIN Assert Bbmod Is In Expected Availability State    bbmod_id=${bbmod_id}
    ...                                                     timeout=${timeout}
    ...                                                     expected_state=regex"Online|"

ADMIN Assert Bbmod Is In Offline State
    [Arguments]    ${bbmod_id}
    ...            ${timeout}=10
    ADMIN Assert Bbmod Is In Expected Availability State    bbmod_id=${bbmod_id}
    ...                                                     timeout=${timeout}
    ...                                                     expected_state=regex"Offline|off line"

ADMIN Assert Cell With Cell Id Is In Expected State
    [Arguments]    ${cell_id}
    ...            ${state_type}
    ...            ${expected_state}
    ...            ${timeout}=10
    ...            ${class_name}=LNCEL
    ADMIN Assert    id=${cell_id}
    ...             parameters=${state_type}=${expected_state}
    ...             timeout=${timeout}
    ...             class_name=${class_name}

ADMIN Assert Cell With Cell Id Is In Expected Procedural State
    [Arguments]    ${cell_id}
    ...            ${expected_state}
    ...            ${timeout}=10
    ...            ${state_type}=proceduralState
#    ...            ${state_type}=proceduralStatus
    ...            ${class_name}=LNCEL
    ADMIN Assert Cell With Cell Id Is In Expected State    cell_id=${cell_id}
    ...                                                    expected_state=${expected_state}
    ...                                                    timeout=${timeout}
    ...                                                    state_type=${state_type}
    ...                                                    class_name=${class_name}

ADMIN Assert Cell With Cell Id Is In Expected Blocking State
    [Arguments]    ${cell_id}
    ...            ${expected_state}
    ...            ${timeout}=10
    ...            ${state_type}=blockingState
    ...            ${class_name}=LNCEL
    ADMIN Assert Cell With Cell Id Is In Expected State    cell_id=${cell_id}
    ...                                                    expected_state=${expected_state}
    ...                                                    timeout=${timeout}
    ...                                                    state_type=${state_type}
    ...                                                    class_name=${class_name}

ADMIN Assert Cell With Cell Id Is In Expected Administrative State
    [Arguments]    ${cell_id}
    ...            ${expected_state}
    ...            ${timeout}=10
    ...            ${state_type}=administrativeState
    ...            ${class_name}=LNCEL
    ADMIN Assert Cell With Cell Id Is In Expected State    cell_id=${cell_id}
    ...                                                    expected_state=${expected_state}
    ...                                                    timeout=${timeout}
    ...                                                    state_type=${state_type}
    ...                                                    class_name=${class_name}

ADMIN Assert Cell With Cell Id Is In Expected Operational State
    [Arguments]    ${cell_id}
    ...            ${expected_state}
    ...            ${timeout}=10
    ...            ${state_type}=operationalState
    ...            ${class_name}=LNCEL
    ADMIN Assert Cell With Cell Id Is In Expected State    cell_id=${cell_id}
    ...                                                    expected_state=${expected_state}
    ...                                                    timeout=${timeout}
    ...                                                    state_type=${state_type}
    ...                                                    class_name=${class_name}

ADMIN Assert Cell With Cell Id Is In Expected Availability State
    [Arguments]    ${cell_id}
    ...            ${expected_state}
    ...            ${timeout}=10
    ...            ${state_type}=availabilityStatus
    ...            ${class_name}=LNCEL
    ADMIN Assert Cell With Cell Id Is In Expected State    cell_id=${cell_id}
    ...                                                    expected_state=${expected_state}
    ...                                                    timeout=${timeout}
    ...                                                    state_type=${state_type}
    ...                                                    class_name=${class_name}

ADMIN Assert Cell With Cell Id Is In OnAirDone State
    [Arguments]    ${cell_id}
    ...            ${timeout}=10
    ...            ${expected_state}=regex"OnAir|onAir"
    ...            ${class_name}=LNCEL
    ADMIN Assert Cell With Cell Id Is In Expected Procedural State    cell_id=${cell_id}
    ...                                                               timeout=${timeout}
    ...                                                               expected_state=${expected_state}
    ...                                                               class_name=${class_name}

ADMIN Assert Cell With Cell Id Is In Validated State
    [Arguments]    ${cell_id}
    ...            ${timeout}=10
    ...            ${expected_state}=Validated
    ...            ${class_name}=LNCEL
    ADMIN Assert Cell With Cell Id Is In Expected Procedural State    cell_id=${cell_id}
    ...                                                               timeout=${timeout}
    ...                                                               expected_state=${expected_state}
    ...                                                               class_name=${class_name}

ADMIN Assert Cell With Cell Id Is In Configured State
    [Arguments]    ${cell_id}
    ...            ${timeout}=10
    ...            ${expected_state}=regex"Configured|configured"
    ...            ${class_name}=LNCEL
    ADMIN Assert Cell With Cell Id Is In Expected Procedural State    cell_id=${cell_id}
    ...                                                               timeout=${timeout}
    ...                                                               expected_state=${expected_state}
    ...                                                               class_name=${class_name}

ADMIN Assert Cell With Cell Id Is In Initializing State
    [Arguments]    ${cell_id}
    ...            ${timeout}=10
    ...            ${expected_state}=regex"Initializing|initializing"
    ...            ${class_name}=LNCEL
    ADMIN Assert Cell With Cell Id Is In Expected Procedural State    cell_id=${cell_id}
    ...                                                               timeout=${timeout}
    ...                                                               expected_state=${expected_state}
    ...                                                               class_name=${class_name}

ADMIN Assert Cell With Cell Id Is In Blocked State
    [Arguments]    ${cell_id}
    ...            ${timeout}=10
    ...            ${expected_state}=Blocked
    ...            ${class_name}=LNCEL
    ADMIN Assert Cell With Cell Id Is In Expected Blocking State    cell_id=${cell_id}
    ...                                                             timeout=${timeout}
    ...                                                             expected_state=${expected_state}
    ...                                                             class_name=${class_name}

ADMIN Assert Cell With Cell Id Is In Unblocked State
    [Arguments]    ${cell_id}
    ...            ${timeout}=10
    ...            ${expected_state}=Unblocked
    ...            ${class_name}=LNCEL
    ADMIN Assert Cell With Cell Id Is In Expected Blocking State    cell_id=${cell_id}
    ...                                                             timeout=${timeout}
    ...                                                             expected_state=${expected_state}
    ...                                                             class_name=${class_name}

ADMIN Assert Cell With Cell Id Is In Locked State
    [Arguments]    ${cell_id}
    ...            ${timeout}=10
    ...            ${expected_state}=regex"Locked|locked"
    ...            ${class_name}=LNCEL
    ADMIN Assert Cell With Cell Id Is In Expected Administrative State    cell_id=${cell_id}
    ...                                                                   timeout=${timeout}
    ...                                                                   expected_state=${expected_state}
    ...                                                                   class_name=${class_name}

ADMIN Assert Cell With Cell Id Is In Unlocked State
    [Arguments]    ${cell_id}
    ...            ${timeout}=10
    ...            ${expected_state}=regex"Unlocked|unlocked"
    ...            ${class_name}=LNCEL
    ADMIN Assert Cell With Cell Id Is In Expected Administrative State    cell_id=${cell_id}
    ...                                                                   timeout=${timeout}
    ...                                                                   expected_state=${expected_state}
    ...                                                                   class_name=${class_name}

ADMIN Assert Cell With Cell Id Is In Enabled State
    [Arguments]    ${cell_id}
    ...            ${timeout}=10
    ...            ${expected_state}=regex"Enabled|enabled"
    ...            ${class_name}=LNCEL
    ADMIN Assert Cell With Cell Id Is In Expected Operational State    cell_id=${cell_id}
    ...                                                                timeout=${timeout}
    ...                                                                expected_state=${expected_state}
    ...                                                                class_name=${class_name}

ADMIN Assert Cell With Cell Id Is In Disabled State
    [Arguments]    ${cell_id}
    ...            ${timeout}=10
    ...            ${expected_state}=regex"Disabled|disabled"
    ...            ${class_name}=LNCEL
    ADMIN Assert Cell With Cell Id Is In Expected Operational State    cell_id=${cell_id}
    ...                                                                timeout=${timeout}
    ...                                                                expected_state=${expected_state}
    ...                                                                class_name=${class_name}

ADMIN Assert Cell With Cell Id Is In Online State
    [Arguments]    ${cell_id}
    ...            ${timeout}=10
    ...            ${expected_state}=regex"Online|online"
    ...            ${class_name}=LNCEL
    ADMIN Assert Cell With Cell Id Is In Expected Availability State    cell_id=${cell_id}
    ...                                                                 timeout=${timeout}
    ...                                                                 expected_state=${expected_state}
    ...                                                                 class_name=${class_name}

ADMIN Assert Cell With Cell Id Is In Offline State
    [Arguments]    ${cell_id}
    ...            ${timeout}=10
    ...            ${expected_state}=regex"Offline|off line"
    ...            ${class_name}=LNCEL
    ADMIN Assert Cell With Cell Id Is In Expected Availability State    cell_id=${cell_id}
    ...                                                                 timeout=${timeout}
    ...                                                                 expected_state=${expected_state}
    ...                                                                 class_name=${class_name}

ADMIN Assert Cell With Cell Id Is In Degraded State
    [Arguments]    ${cell_id}
    ...            ${timeout}=10
    ...            ${expected_state}=regex"Degraded|degraded"
    ...            ${class_name}=LNCEL
    ADMIN Assert Cell With Cell Id Is In Expected Availability State    cell_id=${cell_id}
    ...                                                                 timeout=${timeout}
    ...                                                                 expected_state=${expected_state}
    ...                                                                 class_name=${class_name}

ADMIN Assert All Cells Are In Expected State
    [Arguments]    ${state_type}
    ...            ${expected_state}
    ...            ${timeout}=10
    ...            ${class_name}=LNCEL
    ADMIN Assert Every    parameters=${state_type}=${expected_state}
    ...                   timeout=${timeout}
    ...                   class_name=${class_name}

ADMIN Assert All LNCells Are In Expected State
    [Arguments]    ${state_type}
    ...            ${expected_state}
    ...            ${timeout}=10
    ...            ${class_name}=LNCEL
    ADMIN Assert Every    parameters=${state_type}=${expected_state}
    ...                   timeout=${timeout}
    ...                   class_name=${class_name}

ADMIN Assert All NRCells Are In Expected State
    [Arguments]    ${state_type}
    ...            ${expected_state}
    ...            ${timeout}=10
    ...            ${class_name}=NRCEL
    ADMIN Assert Every    parameters=${state_type}=${expected_state}
    ...                   timeout=${timeout}
    ...                   class_name=${class_name}

ADMIN Assert All WNCells Are In Expected State
    [Arguments]    ${state_type}
    ...            ${expected_state}
    ...            ${timeout}=10
    ...            ${class_name}=WNCEL
    ADMIN Assert Every    parameters=${state_type}=${expected_state}
    ...                   timeout=${timeout}
    ...                   class_name=${class_name}

ADMIN Assert All Cells Are In Expected Procedural State
    [Arguments]    ${expected_state}
    ...            ${timeout}=10
#    ...            ${state_type}=proceduralStatus
    ...            ${state_type}=proceduralState
    ...            ${class_name}=LNCEL
    ADMIN Assert All Cells Are In Expected State    expected_state=${expected_state}
    ...                                             state_type=${state_type}
    ...                                             timeout=${timeout}
    ...                                             class_name=${class_name}

ADMIN Assert All Cells Are In Expected Blocking State
    [Arguments]    ${expected_state}
    ...            ${timeout}=10
    ...            ${state_type}=blockingState
    ...            ${class_name}=LNCEL
    ADMIN Assert All Cells Are In Expected State    expected_state=${expected_state}
    ...                                             state_type=${state_type}
    ...                                             timeout=${timeout}
    ...                                             class_name=${class_name}

ADMIN Assert All Cells Are In Expected Administrative State
    [Arguments]    ${expected_state}
    ...            ${timeout}=10
    ...            ${state_type}=administrativeState
    ...            ${class_name}=LNCEL
    ADMIN Assert All Cells Are In Expected State    expected_state=${expected_state}
    ...                                             state_type=${state_type}
    ...                                             timeout=${timeout}
    ...                                             class_name=${class_name}

ADMIN Assert All Cells Are In Expected Operational State
    [Arguments]    ${expected_state}
    ...            ${timeout}=10
    ...            ${state_type}=operationalState
    ...            ${class_name}=LNCEL
    ADMIN Assert All Cells Are In Expected State    expected_state=${expected_state}
    ...                                             state_type=${state_type}
    ...                                             timeout=${timeout}
    ...                                             class_name=${class_name}

ADMIN Assert All Cells Are In Expected Availability State
    [Arguments]    ${expected_state}
    ...            ${timeout}=10
    ...            ${state_type}=availabilityStatus
    ...            ${class_name}=LNCEL
    ADMIN Assert All Cells Are In Expected State    expected_state=${expected_state}
    ...                                             state_type=${state_type}
    ...                                             timeout=${timeout}
    ...                                             class_name=${class_name}

ADMIN Assert All Cells Are In OnAirDone State
    [Arguments]    ${timeout}=10
    ...            ${expected_state}=regex"OnAir|onAir"
    ...            ${class_name}=LNCEL
    ADMIN Assert All Cells Are In Expected Procedural State    expected_state=${expected_state}
    ...                                                        timeout=${timeout}
    ...                                                        class_name=${class_name}

ADMIN Assert All Cells Are In Validated State
    [Arguments]    ${timeout}=10
    ...            ${expected_state}=Validated
    ...            ${class_name}=LNCEL
    ADMIN Assert All Cells Are In Expected Procedural State    expected_state=${expected_state}
    ...                                                        timeout=${timeout}
    ...                                                        class_name=${class_name}

ADMIN Assert All Cells Are In Configured State
    [Arguments]    ${timeout}=10
    ...            ${expected_state}=regex"Configured|configured"
    ...            ${class_name}=LNCEL
    ADMIN Assert All Cells Are In Expected Procedural State    expected_state=${expected_state}
    ...                                                        timeout=${timeout}
    ...                                                        class_name=${class_name}

ADMIN Assert All Cells Are In Initializing State
    [Arguments]    ${timeout}=10
    ...            ${expected_state}=regex"Initializing|initializing"
    ...            ${class_name}=LNCEL
    ADMIN Assert All Cells Are In Expected Procedural State    expected_state=${expected_state}
    ...                                                        timeout=${timeout}
    ...                                                        class_name=${class_name}

ADMIN Assert All Cells Are In Blocked State
    [Arguments]    ${timeout}=10
    ...            ${expected_state}=Blocked
    ...            ${class_name}=LNCEL
    ADMIN Assert All Cells Are In Expected Blocking State    expected_state=${expected_state}
    ...                                                      timeout=${timeout}
    ...                                                      class_name=${class_name}

ADMIN Assert All Cells Are In Unblocked State
    [Arguments]    ${timeout}=10
    ...            ${expected_state}=Unblocked
    ...            ${class_name}=LNCEL
    ADMIN Assert All Cells Are In Expected Blocking State    expected_state=${expected_state}
    ...                                                      timeout=${timeout}
    ...                                                      class_name=${class_name}

ADMIN Assert All Cells Are In Locked State
    [Arguments]    ${timeout}=10
    ...            ${expected_state}=regex"Locked|locked"
    ...            ${class_name}=LNCEL
    ADMIN Assert All Cells Are In Expected Administrative State    expected_state=${expected_state}
    ...                                                            timeout=${timeout}
    ...                                                            class_name=${class_name}

ADMIN Assert All Cells Are In Unlocked State
    [Arguments]    ${timeout}=10
    ...            ${expected_state}=regex"Unlocked|unlocked"
    ...            ${class_name}=LNCEL
    ADMIN Assert All Cells Are In Expected Administrative State    expected_state=${expected_state}
    ...                                                            timeout=${timeout}
    ...                                                            class_name=${class_name}

ADMIN Assert All Cells Are In Enabled State
    [Arguments]    ${timeout}=10
    ...            ${expected_state}=regex"Enabled|enabled"
    ...            ${class_name}=LNCEL
    ADMIN Assert All Cells Are In Expected Operational State    expected_state=${expected_state}
    ...                                                         timeout=${timeout}
    ...                                                         class_name=${class_name}

ADMIN Assert All Cells Are In Disabled State
    [Arguments]    ${timeout}=10
    ...            ${expected_state}=regex"Disabled|disabled"
    ...            ${class_name}=LNCEL
    ADMIN Assert All Cells Are In Expected Operational State    expected_state=${expected_state}
    ...                                                         timeout=${timeout}
    ...                                                         class_name=${class_name}

ADMIN Assert All Cells Are In Online State
    [Arguments]    ${timeout}=10
    ...            ${expected_state}=regex"Online|online"
    ...            ${class_name}=LNCEL
    ADMIN Assert All Cells Are In Expected Availability State    expected_state=${expected_state}
    ...                                                          timeout=${timeout}
    ...                                                          class_name=${class_name}

ADMIN Assert All Cells Are In Offline State
    [Arguments]    ${timeout}=10
    ...            ${expected_state}=regex"Offline|off line"
    ...            ${class_name}=LNCEL
    ADMIN Assert All Cells Are In Expected Availability State    expected_state=${expected_state}
    ...                                                          timeout=${timeout}
    ...                                                          class_name=${class_name}

ADMIN Assert All Cells Are In Degraded State
    [Arguments]    ${timeout}=10
    ...            ${expected_state}=regex"Degraded|degraded"
    ...            ${class_name}=LNCEL
    ADMIN Assert All Cells Are In Expected Availability State    expected_state=${expected_state}
    ...                                                          timeout=${timeout}
    ...                                                          class_name=${class_name}

ADMIN Assert Rmod With Rmod Id Is In Expected State
    [Arguments]    ${rmod_id}
    ...            ${state_type}
    ...            ${expected_state}
    ...            ${timeout}=10
    ...            ${class_name}=RMOD
    ...            ${alias}=${ADMIN_ALIAS}
    ADMIN Assert    id=${rmod_id}
    ...             parameters=${state_type}=${expected_state}
    ...             timeout=${timeout}
    ...             class_name=${class_name}
    ...             alias=${alias}

ADMIN Assert Rmod With Rmod Id Is In Expected Blocking State
    [Arguments]    ${rmod_id}
    ...            ${expected_state}
    ...            ${timeout}=10
    ADMIN Assert Rmod With Rmod Id Is In Expected State    rmod_id=${rmod_id}
    ...                                                    expected_state=${expected_state}
    ...                                                    timeout=${timeout}
    ...                                                    state_type=blockingState

ADMIN Assert Rmod With Rmod Id Is In Expected Administrative State
    [Arguments]    ${rmod_id}
    ...            ${expected_state}
    ...            ${timeout}=10
    ADMIN Assert Rmod With Rmod Id Is In Expected State    rmod_id=${rmod_id}
    ...                                                    expected_state=${expected_state}
    ...                                                    timeout=${timeout}
    ...                                                    state_type=administrativeState

ADMIN Assert Rmod With Rmod Id Is In Expected Operational State
    [Arguments]    ${rmod_id}
    ...            ${expected_state}
    ...            ${timeout}
    ADMIN Assert Rmod With Rmod Id Is In Expected State    rmod_id=${rmod_id}
    ...                                                    expected_state=${expected_state}
    ...                                                    timeout=${timeout}
    ...                                                    state_type=operationalState

ADMIN Assert Rmod With Rmod Id Is In Expected Availability State
    [Arguments]    ${rmod_id}
    ...            ${expected_state}
    ...            ${timeout}=10
    ADMIN Assert Rmod With Rmod Id Is In Expected State    rmod_id=${rmod_id}
    ...                                                    expected_state=${expected_state}
    ...                                                    timeout=${timeout}
    ...                                                    state_type=availabilityStatus

ADMIN Assert Rmod With Rmod Id Is In Locked State
    [Arguments]    ${rmod_id}
    ...            ${timeout}=10
    ADMIN Assert Rmod With Rmod Id Is In Expected Administrative State    rmod_id=${rmod_id}
    ...                                                                   timeout=${timeout}
    ...                                                                   expected_state=regex"Locked|locked"

ADMIN Assert Rmod With Rmod Id Is In Unlocked State
    [Arguments]    ${rmod_id}
    ...            ${timeout}=10
    ADMIN Assert Rmod With Rmod Id Is In Expected Administrative State    rmod_id=${rmod_id}
    ...                                                                   timeout=${timeout}
    ...                                                                   expected_state=regex"Unlocked|unlocked"

ADMIN Assert Rmod With Rmod Id Is In Enabled State
    [Arguments]    ${rmod_id}
    ...            ${timeout}=10
    ADMIN Assert Rmod With Rmod Id Is In Expected Operational State    rmod_id=${rmod_id}
    ...                                                                timeout=${timeout}
    ...                                                                expected_state=regex"Enabled|enabled"

ADMIN Assert Rmod With Rmod Id Is In Disabled State
    [Arguments]    ${rmod_id}
    ...            ${timeout}=10
    ADMIN Assert Rmod With Rmod Id Is In Expected Operational State    rmod_id=${rmod_id}
    ...                                                                timeout=${timeout}
    ...                                                                expected_state=regex"Disabled|disabled"

ADMIN Assert Rmod With Rmod Id Is In Online State
    [Arguments]    ${rmod_id}
    ...            ${timeout}=10
    ADMIN Assert Rmod With Rmod Id Is In Expected Availability State    rmod_id=${rmod_id}
    ...                                                                 timeout=${timeout}
    ...                                                                 expected_state=regex"Online|"

ADMIN Assert Rmod With Rmod Id Is In Offline State
    [Arguments]    ${rmod_id}
    ...            ${timeout}=10
    ADMIN Assert Rmod With Rmod Id Is In Expected Availability State    rmod_id=${rmod_id}
    ...                                                                 timeout=${timeout}
    ...                                                                 expected_state=regex"Offline|off line"

ADMIN Assert Rmod With Rmod Id Is In Not Installed State
    [Arguments]    ${rmod_id}
    ...            ${timeout}=10
    ADMIN Assert Rmod With Rmod Id Is In Expected Availability State    rmod_id=${rmod_id}
    ...                                                                 timeout=${timeout}
    ...                                                                 expected_state=regex"NotInstalled|not installed"

ADMIN Assert All Rmods Are In Expected State
    [Arguments]    ${state_type}
    ...            ${expected_state}
    ...            ${timeout}=10
    ...            ${class_name}=RMOD
    ADMIN Assert Every    parameters=${state_type}=${expected_state}
    ...                   timeout=${timeout}
    ...                   class_name=${class_name}

ADMIN Assert All Rmods Are In Expected Blocking State
    [Arguments]    ${expected_state}
    ...            ${timeout}=10
    ADMIN Assert All Rmods Are In Expected State    expected_state=${expected_state}
    ...                                             timeout=${timeout}
    ...                                             state_type=blockingState

ADMIN Assert All Rmods Are In Expected Administrative State
    [Arguments]    ${expected_state}
    ...            ${timeout}=10
    ADMIN Assert All Rmods Are In Expected State    expected_state=${expected_state}
    ...                                             timeout=${timeout}
    ...                                             state_type=administrativeState

ADMIN Assert All Rmods Are In Expected Operational State
    [Arguments]    ${expected_state}
    ...            ${timeout}=10
    ADMIN Assert All Rmods Are In Expected State    expected_state=${expected_state}
    ...                                             timeout=${timeout}
    ...                                             state_type=operationalState

ADMIN Assert All Rmods Are In Expected Availability State
    [Arguments]    ${expected_state}
    ...            ${timeout}=10
    ...            ${class_name}=RMOD
    ...            ${state_type}=availabilityStatus
#    ...            ${state_type}=availabilityState
    ADMIN Assert All Rmods Are In Expected State    expected_state=${expected_state}
    ...                                             timeout=${timeout}
    ...                                             class_name=${class_name}
    ...                                             state_type=${state_type}

ADMIN Assert All Rmods Are In Blocked State
    [Arguments]    ${timeout}=10
    ADMIN Assert All Rmods Are In Expected Blocking State    expected_state=Blocked
    ...                                                      timeout=${timeout}

ADMIN Assert All Rmods Are In Unblocked State
    [Arguments]    ${timeout}=10
    ADMIN Assert All Rmods Are In Expected Blocking State    expected_state=Unblocked
    ...                                                      timeout=${timeout}

ADMIN Assert All Rmods Are In Locked State
    [Arguments]    ${timeout}=10
    ADMIN Assert All Rmods Are In Expected Administrative State    expected_state=regex"Locked|locked"
    ...                                                            timeout=${timeout}

ADMIN Assert All Rmods Are In Unlocked State
    [Arguments]    ${timeout}=10
    ADMIN Assert All Rmods Are In Expected Administrative State    expected_state=regex"Unlocked|unlocked"
    ...                                                            timeout=${timeout}

ADMIN Assert All Rmods Are In Enabled State
    [Arguments]    ${timeout}=10
    ADMIN Assert All Rmods Are In Expected Operational State    expected_state=regex"Enabled|enabled"
    ...                                                         timeout=${timeout}

ADMIN Assert All Rmods Are In Disabled State
    [Arguments]    ${timeout}=10
    ADMIN Assert All Rmods Are In Expected Operational State    expected_state=regex"Disabled|disabled"
    ...                                                         timeout=${timeout}

ADMIN Assert All Rmods Are In Online State
    [Arguments]    ${timeout}=10
    ADMIN Assert All Rmods Are In Expected Availability State    expected_state=regex"Online|"
    ...                                                          timeout=${timeout}

ADMIN Assert All Rmods Are In Offline State
    [Arguments]    ${timeout}=10
    ADMIN Assert All Rmods Are In Expected Availability State    expected_state=regex"Offline|off line"
    ...                                                          timeout=${timeout}

ADMIN Assert All Rmods Are In Not Installed State
    [Arguments]    ${timeout}=10
    ADMIN Assert All Rmods Are In Expected Availability State    expected_state=regex"NotInstalled|not installed"
    ...                                                          timeout=${timeout}

ADMIN Assert MRBTS State Is In Expected State
    [Arguments]    ${mrbts_id}
    ...            ${state_type}
    ...            ${expected_state}
    ...            ${alias}=${ADMIN_ALIAS}
    ...            ${timeout}=10
    ...            ${class_name}=BTS

    ADMIN Assert    parameters=${state_type}=${expected_state}
    ...             id=${mrbts_id}
    ...             timeout=${timeout}
    ...             alias=${alias}
    ...             class_name=${class_name}


ADMIN Assert MRBTS Procedural State Is In Expected State
    [Arguments]    ${mrbts_id}
    ...            ${expected_state}
    ...            ${alias}=${ADMIN_ALIAS}
    ...            ${timeout}=10
    ...            ${class_name}=BTS
    ADMIN Assert MRBTS State Is In Expected State    state_type=proceduralState
    ...                                              mrbts_id=${mrbts_id}
    ...                                              expected_state=${expected_state}
    ...                                              alias=${alias}
    ...                                              timeout=${timeout}
    ...                                              class_name=${class_name}


ADMIN Assert MRBTS State Is In OnAir State
    [Arguments]    ${mrbts_id}
    ...            ${alias}=${ADMIN_ALIAS}
    ...            ${timeout}=10
    ...            ${class_name}=BTS
    ADMIN Assert MRBTS Procedural State Is In Expected State   mrbts_id=${mrbts_id}
    ...                                                        expected_state=regex"OnAir|onAir"
    ...                                                        alias=${alias}
    ...                                                        timeout=${timeout}
    ...                                                        class_name=${class_name}


ADMIN Assert MRBTS State Is In Configured State
    [Arguments]    ${mrbts_id}
    ...            ${timeout}=10
    ADMIN Assert MRBTS Procedural State Is In Expected State    mrbts_id=${mrbts_id}
    ...                                                         expected_state=regex"Configured|configured"
    ...                                                         timeout=${timeout}

ADMIN Assert MRBTS State Is In Commissioned State
    [Arguments]    ${mrbts_id}
    ...            ${timeout}=10
    ADMIN Assert MRBTS Procedural State Is In Expected State    mrbts_id=${mrbts_id}
    ...                                                         expected_state=regex"Commissioned|commissioned"
    ...                                                         timeout=${timeout}

ADMIN Assert MRBTS State Is In Integrated State
    [Arguments]    ${mrbts_id}
    ...            ${timeout}=10
    ADMIN Assert MRBTS Procedural State Is In Expected State    mrbts_id=${mrbts_id}
    ...                                                         expected_state=regex"IntegratedToRan|integrated to RAN"
    ...                                                         timeout=${timeout}

ADMIN Assert MRBTS And All Cells Are In OnAir States
    [Arguments]    ${mrbts_id}
    ...            ${timeout}=10
    ADMIN Assert MRBTS State Is In OnAir State      mrbts_id=${mrbts_id}
    ...                                             timeout=${timeout}
    ...                                             class_name=BTS
    ADMIN Assert All Cells Are In OnAirDone State   timeout=${timeout}
    ...                                             class_name=LNCEL

ADMIN Assert All MRBTSes States Are In Expected State
    [Arguments]    ${state_type}
    ...            ${expected_state}
    ...            ${timeout}=10
    ...            ${class_name}=BTS
    ADMIN Assert Every    parameters=${state_type}=${expected_state}
    ...                   timeout=${timeout}
    ...                   class_name=${class_name}

ADMIN Assert All MRBTSes Procedural State Are In Expected State
    [Arguments]    ${expected_state}
    ...            ${timeout}=10
    ...            ${class_name}=BTS
    ADMIN Assert All MRBTSes States Are In Expected State    state_type=proceduralState
    ...                                                      expected_state=${expected_state}
    ...                                                      timeout=${timeout}
    ...                                                      class_name=${class_name}

ADMIN Assert All MRBTSes State Are In OnAir State
    [Arguments]    ${timeout}=10
    ...            ${class_name}=BTS
    ADMIN Assert All MRBTSes Procedural State Are In Expected State   expected_state=regex"OnAir|onAir"
    ...                                                               timeout=${timeout}
    ...                                                               class_name=${class_name}

ADMIN Assert All MRBTSes State Are In Configured State
    [Arguments]    ${timeout}=10
    ADMIN Assert All MRBTSes Procedural State Are In Expected State   expected_state=regex"Configured|configured"
    ...                                                                timeout=${timeout}

ADMIN Assert All MRBTSes State Are In Commissioned State
    [Arguments]    ${timeout}=10
    ADMIN Assert All MRBTSes Procedural State Are In Expected State    expected_state=regex"Commissioned|commissioned"
    ...                                                                timeout=${timeout}

ADMIN Assert All MRBTSes State Are In Integrated State
    [Arguments]    ${timeout}=10
    ADMIN Assert All MRBTSes Procedural State Are In Expected State    expected_state=regex"IntegratedToRan|integrated to RAN"
    ...                                                                timeout=${timeout}

ADMIN Assert All MRBTSes And All Cells Are In OnAir States
    [Arguments]    ${timeout}=10
    ADMIN Assert All MRBTSes State Are In OnAir State   timeout=${timeout}
    ...                                                 class_name=BTS
    ADMIN Assert All Cells Are In OnAirDone State       timeout=${timeout}
    ...                                                 class_name=LNCEL

ADMIN Check Amount Of Fault With Alarm Number And Alarm Resource In Given Faults Lists
    [Arguments]    ${alarms}
    ...            ${expected_number_of_occurrences}
    ...            ${fault_id}
    ...            ${alarm_id}
    ...            ${alarm_resource}
    ${counter}=    Set Variable    0
    FOR    ${index}   IN    @{alarms}
        ${faultId_index}=    Get From Dictionary    ${index}    faultId
        ${alarmId_index}=    Run Keyword If    ${faultId_index}==${fault_id}    Get From Dictionary    ${index}    alarmId
        ${alarmResource_index}=    Run Keyword If    ${alarmId_index}==${alarm_id}    Get From Dictionary    ${index}    alarmingResource
        ${counter}=    Run Keyword If    '${alarmResource_index}'=='${alarm_resource}'    Set Variable    ${counter}+1
    END
    Should Be Equal    ${counter}   ${expected_number_of_occurrences}
    ...    Amount of fault_id=${fault_id} with alarm_id=${alarm_id} is not equal to expected!

ADMIN Check If There Was Correct Amount Of Fault With Alarm Number And Alarming Resource
    [Arguments]    ${expected_number_of_occurrences}
    ...            ${fault_id}
    ...            ${alarm_id}
    ...            ${alarm_resource}
    @{alarms}=  ADMIN Get Historic Alarms
    ADMIN Check Amount Of Fault With Alarm Number And Alarm Resource In Given Faults Lists    alarms=@{alarms}
    ...                                                                         expected_number_of_occurrences=${expected_number_of_occurrences}
    ...                                                                         fault_id=${fault_id}
    ...                                                                         alarm_id=${alarm_id}
    ...                                                                         alarm_resource=${alarm_resource}

ADMIN Check If There Is Correct Amount Of Fault With Alarm Number And Alarming Resource
    [Arguments]    ${expected_number_of_occurrences}
    ...            ${fault_id}
    ...            ${alarm_id}
    ...            ${alarm_resource}
    @{alarms}=    ADMIN Get Active Alarms
    ADMIN Check Amount Of Fault With Alarm Number And Alarm Resource In Given Faults Lists    alarms=@{alarms}
    ...                                                                         expected_number_of_occurrences=${expected_number_of_occurrences}
    ...                                                                         fault_id=${fault_id}
    ...                                                                         alarm_id=${alarm_id}
    ...                                                                         alarm_resource=${alarm_resource}

ADMIN Assert Given Object Parameter Has A Given Value
    [Arguments]    ${class_name}
    ...            ${id}
    ...            ${parameter_name}
    ...            ${parameter_value}
    ...            ${timeout}=60
    ADMIN Assert   class_name=${class_name}
    ...            id=${id}
    ...            parameters=${parameter_name}=${parameter_value}
    ...            timeout=${timeout}

ADMIN Assert Cell Parameter Has A Given Value
    [Arguments]    ${cell_id}
    ...            ${parameter_name}
    ...            ${parameter_value}
    ...            ${timeout}
    ...            ${class_name}=LNCEL
    ADMIN Assert Given Object Parameter Has A Given Value    id=${cell_id}
    ...                                                      parameters=${parameter_name}=${parameter_value}
    ...                                                      timeout=${timeout}
    ...                                                      class_name=${class_name}

ADMIN Assert Given Object Parameter Has Not A Given Value
    [Arguments]    ${class_name}
    ...            ${id}
    ...            ${parameter_name}
    ...            ${parameter_value}
    ...            ${timeout}
    ADMIN Assert No   class_name=${class_name}
    ...               id=${id}
    ...               parameters=${parameter_name}=${parameter_value}
    ...               timeout=${timeout}

ADMIN Assert Cell Parameter Has Not A Given Value
    [Arguments]    ${cell_id}
    ...            ${parameter_name}
    ...            ${parameter_value}
    ...            ${timeout}
    ...            ${class_name}=LNCEL
    ADMIN Assert Given Object Parameter Has Not A Given Value    id=${cell_id}
    ...                                                          parameters=${parameter_name}=${parameter_value}
    ...                                                          timeout=${timeout}
    ...                                                          class_name=${class_name}

ADMIN Assert Cell Carriers State Is In Expected State
    [Arguments]    ${cell_id}
    ...            ${expected_state}
    ...            ${timeout}
    ...            ${parameter_name}=carriersState
    ...            ${class_name}=LNCEL
    ADMIN Assert Cell Parameter Has A Given Value    cell_id=${cell_id}
    ...                                              parameter_name=${parameter_name}
    ...                                              parameter_value=${expected_state}
    ...                                              timeout=${timeout}
    ...                                              class_name=${class_name}

ADMIN Assert Cell Carriers State Is Not In Expected State
    [Arguments]    ${cell_id}
    ...            ${expected_state}
    ...            ${timeout}
    ...            ${parameter_name}=carriersState
    ...            ${class_name}=LNCEL
    ADMIN Assert Cell Parameter Has Not A Given Value    cell_id=${cell_id}
    ...                                                  parameter_name=${parameter_name}
    ...                                                  parameter_value=${expected_state}
    ...                                                  timeout=${timeout}
    ...                                                  class_name=${class_name}

ADMIN Assert Cell With Cell Id Carriers State Is Activated
    [Arguments]    ${cell_id}
    ...            ${timeout}=60
    ...            ${expected_state}=Activated
    ...            ${parameter_name}=carriersState
    ...            ${class_name}=LNCEL
    ADMIN Assert Cell Carriers State Is In Expected State    cell_id=${cell_id}
    ...                                                      parameter_name=${parameter_name}
    ...                                                      expected_state=${expected_state}
    ...                                                      timeout=${timeout}
    ...                                                      class_name=${class_name}

ADMIN Assert Cell With Cell Id Carriers State Is Uninitialized
    [Arguments]    ${cell_id}
    ...            ${timeout}=60
    ...            ${parameter_name}=carriersState
    ...            ${expected_state}=Uninitialized
    ...            ${class_name}=LNCEL
    ADMIN Assert Cell Carriers State Is In Expected State    cell_id=${cell_id}
    ...                                                      parameter_name=${parameter_name}
    ...                                                      expected_state=${expected_state}
    ...                                                      timeout=${timeout}
    ...                                                      class_name=${class_name}

ADMIN Assert Cell With Cell Id Carriers State Is UpdatedTiming
    [Arguments]    ${cell_id}
    ...            ${timeout}=60
    ...            ${parameter_name}=carriersState
    ...            ${expected_state}=UpdatedTiming
    ...            ${class_name}=LNCEL
    Log    ${parameter_name}
    ADMIN Assert Cell Carriers State Is In Expected State    cell_id=${cell_id}
    ...                                                      parameter_name=carriersState
    ...                                                      expected_state=${expected_state}
    ...                                                      timeout=${timeout}
    ...                                                      class_name=${class_name}l

ADMIN Assert Cell With Cell Id Carriers State Is Not Activated
    [Arguments]    ${cell_id}
    ...            ${timeout}=60
    ...            ${expected_state}=Activated
    ...            ${parameter_name}=carriersState
    ...            ${class_name}=LNCEL
    Log    ${parameter_name}
    ADMIN Assert Cell Carriers State Is Not In Expected State    cell_id=${cell_id}
    ...                                                          parameter_name=carriersState
    ...                                                          expected_state=${expected_state}
    ...                                                          timeout=${timeout}
    ...                                                          class_name=${class_name}

ADMIN Assert Cell With Cell Id Carriers State Is Not Unitialized
    [Arguments]    ${cell_id}
    ...            ${timeout}=60
    ...            ${parameter_name}=carriersState
    ...            ${expected_state}=Uninitialized
    ...            ${class_name}=LNCEL
    ADMIN Assert Cell Carriers State Is Not In Expected State    cell_id=${cell_id}
    ...                                                          parameter_name=${parameter_name}
    ...                                                          expected_state=${expected_state}
    ...                                                          timeout=${timeout}
    ...                                                          class_name=${class_name}

ADMIN Assert Cell With Cell Id Carriers State Is Not UpdatedTiming
    [Arguments]    ${cell_id}
    ...            ${timeout}=60
    ...            ${parameter_name}=carriersState
    ...            ${expected_state}=UpdatedTiming
    ...            ${class_name}=LNCEL
    ADMIN Assert Cell Carriers State Is Not In Expected State    cell_id=${cell_id}
    ...                                                          parameter_name=${parameter_name}
    ...                                                          expected_state=${expected_state}
    ...                                                          timeout=${timeout}
    ...                                                          class_name=${class_name}

ADMIN Check If Cell With Cell Id Is Detected
    [Arguments]    ${cell_id}
    ...            ${timeout}=30
    ...            ${class_name}=LNCEL
    ADMIN Assert Cell With Cell Id Is In OnAirDone State    cell_id=${cell_id}    timeout=${timeout}    class_name=${class_name}
    ADMIN Assert Cell With Cell Id Is In Enabled State    cell_id=${cell_id}    timeout=${timeout}    class_name=${class_name}
    ADMIN Assert Cell With Cell Id Carriers State Is Activated    cell_id=${cell_id}    timeout=${timeout}    class_name=${class_name}

ADMIN Check If Cell With Cell Id Is Not Detected
    [Arguments]    ${cell_id}
    ...            ${timeout}=30
    ...            ${class_name}=LNCEL
    ADMIN Assert Cell With Cell Id Is In Initializing State    cell_id=${cell_id}    timeout=${timeout}    class_name=${class_name}
    ADMIN Assert Cell With Cell Id Is In Disabled State    cell_id=${cell_id}    timeout=${timeout}    class_name=${class_name}
    ADMIN Assert Cell With Cell Id Carriers State Is Uninitialized    cell_id=${cell_id}    timeout=${timeout}    class_name=${class_name}


ADMIN Assert All Given Object Parameters Have A Given Value
    [Arguments]    ${class_name}
    ...            ${parameter_name}
    ...            ${parameter_value}
    ...            ${timeout}=60
    ADMIN Assert Every   class_name=${class_name}
    ...                  parameters=${parameter_name}=${parameter_value}
    ...                  timeout=${timeout}

ADMIN Assert All Cells Parameter Have A Given Value
    [Arguments]    ${parameter_name}
    ...            ${parameter_value}
    ...            ${timeout}
    ...            ${class_name}=LNCEL
    ADMIN Assert All Given Object Parameters Have A Given Value    parameter_name=${parameter_name}
    ...                                                            timeout=${timeout}
    ...                                                            parameter_value=${parameter_value}
    ...                                                            class_name=${class_name}

ADMIN Assert Given Object Parameters Have Not A Given Value
    [Arguments]    ${class_name}
    ...            ${parameter_name}
    ...            ${parameter_value}
    ...            ${timeout}
    ADMIN Assert Any    class_name=${class_name}
    ...                 parameters=${parameter_name}=${parameter_value}
    ...                 timeout=${timeout}

ADMIN Assert All Cells Parameter Have Not A Given Value
    [Arguments]    ${parameter_name}
    ...            ${parameter_value}
    ...            ${timeout}
    ...            ${class_name}=LNCEL
    ADMIN Assert Given Object Parameters Have Not A Given Value    parameters=${parameter_name}=${parameter_value}
    ...                                                            timeout=${timeout}
    ...                                                            class_name=${class_name}

ADMIN Assert All Cells Carriers State Are In Expected State
    [Arguments]    ${expected_state}
    ...            ${timeout}
    ...            ${parameter_name}=carriersState
    ...            ${class_name}=LNCEL
    ADMIN Assert Cell Parameter Has A Given Value    parameter_name=${parameter_name}
    ...                                              parameter_value=${expected_state}
    ...                                              timeout=${timeout}
    ...                                              class_name=${class_name}

ADMIN Assert All Cells Carriers State Are Not In Expected State
    [Arguments]    ${cell_id}
    ...            ${expected_state}
    ...            ${timeout}
    ...            ${parameter_name}=carriersState
    ...            ${class_name}=LNCEL
    Log    ${cell_id}
    ADMIN Assert Cell Parameter Has Not A Given Value    parameter_name=${parameter_name}
    ...                                                  parameter_value=${expected_state}
    ...                                                  timeout=${timeout}
    ...                                                  class_name=${class_name}

ADMIN Assert All Cells Carriers State Are Activated
    [Arguments]    ${timeout}=60
    ...            ${parameter_name}=carriersState
    ...            ${expected_state}=Activated
    ...            ${class_name}=LNCEL
    ADMIN Assert All Cells Carriers State Are In Expected State    parameter_name=${parameter_name}
    ...                                                            expected_state=${expected_state}
    ...                                                            timeout=${timeout}
    ...                                                            class_name=${class_name}

ADMIN Assert All Cells Carriers State Are Uninitialized
    [Arguments]    ${timeout}=60
    ...            ${parameter_name}=carriersState
    ...            ${expected_state}=Uninitialized
    ...            ${class_name}=LNCEL
    ADMIN Assert All Cells Carriers State Are In Expected State    parameter_name=${parameter_name}
    ...                                                            expected_state=${expected_state}
    ...                                                            timeout=${timeout}
    ...                                                            class_name=${class_name}

ADMIN Assert All Cells Carriers State Are UpdatedTiming
    [Arguments]    ${timeout}=60
    ...            ${parameter_name}=carriersState
    ...            ${expected_state}=UpdatedTiming
    ...            ${class_name}=LNCEL
    ADMIN Assert All Cells Carriers State Are In Expected State    parameter_name=${parameter_name}
    ...                                                            expected_state=${expected_state}
    ...                                                            timeout=${timeout}
    ...                                                            class_name=${class_name}

ADMIN Assert All Cells Carriers State Are Not Activated
    [Arguments]    ${timeout}=60
    ...            ${parameter_name}=carriersState
    ...            ${expected_state}=Activated
    ...            ${class_name}=LNCEL
    ADMIN Assert All Cells Carriers State Are Not In Expected State    parameter_name=${parameter_name}
    ...                                                                expected_state=${expected_state}
    ...                                                                timeout=${timeout}
    ...                                                                class_name=${class_name}

ADMIN Assert All Cells Carriers State Are Not Unitialized
    [Arguments]    ${timeout}=60
    ...            ${parameter_name}=carriersState
    ...            ${expected_state}=Uninitialized
    ...            ${class_name}=LNCEL
    ADMIN Assert All Cells Carriers State Are Not In Expected State    parameter_name=${parameter_name}
    ...                                                                expected_state=${expected_state}
    ...                                                                timeout=${timeout}
    ...                                                                class_name=${class_name}

ADMIN Assert All Cells Carriers State Are Not UpdatedTiming
    [Arguments]    ${timeout}=60
    ...            ${parameter_name}=carriersState
    ...            ${expected_state}=UpdatedTiming
    ...            ${class_name}=LNCEL
    ADMIN Assert All Cells Carriers State Are Not In Expected State    parameter_name=${parameter_name}
    ...                                                                expected_state=${expected_state}
    ...                                                                timeout=${timeout}
    ...                                                                class_name=${class_name}

ADMIN Check If All Cells Are Detected
    [Arguments]    ${timeout}=60
    ADMIN Assert All Cells Are In OnAirDone State    timeout=${timeout}
    ADMIN Assert All Cells Are In Enabled State    timeout=${timeout}
    ADMIN Assert All Cells Carriers State Are Activated    timeout=${timeout}

ADMIN Check If All Cells Are Not Detected
    [Arguments]    ${timeout}=60
    ADMIN Assert All Cells Are In Initializing State    timeout=${timeout}
    ADMIN Assert All Cells Are In Disabled State    timeout=${timeout}
    ADMIN Assert All Cells Carriers State Are Uninitialized    timeout=${timeout}

ADMIN Assert All Cells Calculation State Are In Expected State
    [Arguments]    ${expected_state}
    ...            ${timeout}=60
    ADMIN Assert All Cells Parameter Have A Given Value     parameter_name=bbCalcState
    ...                                                     parameter_value=${expected_state}
    ...                                                     timeout=${timeout}

ADMIN Assert All Cells Calculation State Are CalculationDone
    [Arguments]    ${timeout}=60
    ADMIN Assert All Cells Calculation State Are In Expected State    expected_state=CalculationDone
    ...                                                               timeout=${timeout}

ADMIN Assert All Cells Calculation State Are Not In Expected State
    [Arguments]    ${expected_state}
    ...            ${timeout}=60
    ADMIN Assert All Cells Parameter Have Not A Given Value     parameter_name=bbCalcState
    ...                                                         parameter_value=${expected_state}
    ...                                                         timeout=${timeout}

ADMIN Assert All Cells Calculation State Are Not CalculationDone
    [Arguments]    ${timeout}=60
    ADMIN Assert All Cells Calculation State Are In Expected State    expected_state=CalculationDone
    ...                                                               timeout=${timeout}

ADMIN Assert SMOD Is In Expected State
    [Arguments]    ${class_name}
    ...            ${id}
    ...            ${parameter_name}
    ...            ${parameter_value}
    ...            ${alias}=${ADMIN_ALIAS}
    ...            ${timeout}=120
    ADMIN Assert   class_name=${class_name}
    ...            id=${id}
    ...            parameters=${parameter_name}=${parameter_value}
    ...            alias=${alias}
    ...            timeout=${timeout}

ADMIN Assert SMOD Is In Enabled State
    [Arguments]    ${parameter_name}=operationalState
    ...            ${parameter_value}=Enabled
    ...            ${alias}=${ADMIN_ALIAS}
    ...            ${timeout}=120
    Log    ${alias}
    ADMIN Assert SMOD Is In Expected State    class_name=SMOD
    ...                                       id=${OUT_SMODS_IDS_LIST[0]}
    ...                                       parameter_name=${parameter_name}
    ...                                       parameter_value=${parameter_value}
    ...                                       alias=${ADMIN_ALIAS}
    ...                                       timeout=${timeout}

#ADMIN Start Logging Infomodel
#    [Arguments]    ${bts_host}=${ADMIN_BTS_HOST}
#    ...            ${bts_port}=${ADMIN_BTS_PORT}
#    ...            ${username}=${ADMIN_USERNAME}
#    ...            ${password}=${ADMIN_PASSWORD}
#    ...            ${im_alias}=im_log
#    ...            ${timeout}=${480}
#    ...            ${filename}=infomodel_log.ims2
#    ${webservice}=    Create Dictionary
#    ...    host=${bts_host}
#    ...    user=${username}
#    ...    password=${password}
#    ...    port=${bts_port}
#    Create Im Log Collector
#    ...    name=${im_alias}
#    ...    webservice=${webservice}
#    ...    timeout=${timeout}
#    ...    target_file_name=${filename}
#    Set Suite Alias    ${im_alias}
#    Setup Collectors
#    ...    names=${im_alias}

#ADMIN Stop Logging Infomodel
#    [Arguments]    ${log_dir}=${admin_api_log_dir}
#    ...            ${im_alias}=im_log
#    Collect Collectors
#    ...    names=${im_alias}
#    ...    target_dir=${log_dir}
#    Teardown Collectors
#    ...    names=${im_alias}

####DO PRZEROBIENIA
ADMIN Wait '${time}' min for alarm '${id}' on '${master/slave}' eNB '${appear/disappear}'
    ${msg}=     catenate    Wait ${time} min for alarm     ${id}     on       ${master/slave}      eNB         ${appear/disappear}
    log to console      ${msg}
    run keyword if   '${appear/disappear}' == 'appear'
    ...   wait for infomodel event    event=update /MRBTS-1/RAT-1/LTS-1/LNBTS_L-1//ALARM_L-* [alarmInformation.faultId:empty->${id}]
    ...   timeout=${time}min
    ...   alias=${master/slave}
    run keyword if   '${appear/disappear}' == 'disappear'
    ...   wait for infomodel event    event=remove /MRBTS-1/RAT-1/LTS-1/LNBTS_L-1//ALARM_L-* [alarmInformation.faultId=${id}]
    ...   timeout=${time}min
    ...   alias=${master/slave}
