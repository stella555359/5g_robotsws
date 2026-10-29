*** Settings ***
Documentation  This suite contains KWs used by KPI TCs

Library  hran_radio
Library  taf.ul.oam_kpi_calculations  WITH NAME  oam_kpi
Library  taf.sw.reporting_portal
Library  taf.rfrl.common_resources.oam_kpi.report_oam_kpi
Resource  ca_SBTS_general.robot


*** Variables ***
${ARTIFACTORY_SERVER}  https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build/
${DELTA_RESULTS_PATH}  /home/ute/test_results/Delta_results
${TARGET_SW_PATH}  /home/ute/btsauto/TARGET_SW


*** Keywords ***
Download Needed Software
    [Documentation]  This keyword is used to download needed software.

    Set Suite Variable  ${SBTS_DESIRED_SW_BUILD}  ${ENB_BUILD}
    Log  \nTarget software is: ${SBTS_DESIRED_SW_BUILD}.  console=true
    ${sbts_intermediate_sw_build}  Get Intermediate Software Version
    Set Suite Variable  ${SBTS_INTERMEDIATE_SW_BUILD}
    Log  \nIntermediate software is: ${SBTS_INTERMEDIATE_SW_BUILD}.  console=true
    ${download_location}  Set Variable  ${TARGET_SW_PATH}
    Run  mkdir ${download_location}
    Download And Check Software Package  ${SBTS_DESIRED_SW_BUILD}  ${download_location}
    Log  ${SBTS_DESIRED_SW_BUILD} was downloaded in ${download_location}.  console=true
    Download And Check Software Package  ${SBTS_INTERMEDIATE_SW_BUILD}  ${download_location}
    Log  ${SBTS_INTERMEDIATE_SW_BUILD} was downloaded in ${download_location}.  console=true


Get Intermediate Software Version
    [Documentation]  This keyword is used to get intermediate software version.

    Wait Until Keyword Succeeds  5 min  30 sec
    ...  Setup Admin  bts_host=${OAM_BTS_IP}  alias=active_sw_query
    ${active_sw_release_name}  Get Sw Release Name  connection=active_sw_query
    ${active_sw_version}  Get Sw Version  connection=active_sw_query
    ${sw_version}  Get Software From Database  ${active_sw_version}  ${active_sw_release_name}
    Teardown Admin  connection=active_sw_query

    RETURN  ${sw_version}


Get Software From Database
    [Documentation]  This KW is searching for intermediate software with 10 versions behind the active
    ...  software version. In case there are no 10 versions behind, the older one will be chosen.
    [Arguments]  ${active_sw_version}  ${active_sw_release_name}

    ${sw_versions}  Create List
    ${active_sw_version}  ${active_sw_release_name}  Change Active Sw Release Name If Needed  ${ARTIFACTORY_SERVER}  ${active_sw_version}
    ...  ${active_sw_release_name}
    ${link_to_sw_builds_on_specific_branch}  Catenate  SEPARATOR=  ${ARTIFACTORY_SERVER}  ${active_sw_release_name}  /
    ${curl_command_output}  Run  wget -O - ${link_to_sw_builds_on_specific_branch} | grep ENB
    ${lines}  Split To Lines  ${curl_command_output}
    FOR  ${line}  IN  @{lines}
        ${sw_version_matches}  Get Regexp Matches  ${line}  SBTS[A-Z0-9_]+
        IF  "${sw_version_matches}[0]"<"${active_sw_version}"  Append To List  ${sw_versions}  ${sw_version_matches}[0]
    END
    ${sw_versions_length}  Get Length  ${sw_versions}
    ${sw_version}  Set Variable If  ${sw_versions_length}<=10  ${sw_versions}[0]  ${sw_versions}[-10]

    RETURN  ${sw_version}


Change Active Sw Release Name If Needed
    [Documentation]  This keyword is used to change active sw release name if needed.
    [Arguments]  ${artifactory_server}  ${active_sw_version}  ${active_sw_release_name}

    ${curl_command_output}  Run  wget -O - ${artifactory_server} | grep ${active_sw_release_name}
    ${status}  Run Keyword And Return Status
    ...  Should Not Be Empty  ${curl_command_output}
    IF  ${status}  RETURN  ${active_sw_version}  ${active_sw_release_name}
    ${active_sw_version}  Replace String Using Regexp  ${active_sw_version}  SBTS[A-Z0-9]+  SBTS00
    ${active_sw_release_name}  Set Variable  SBTS00

    RETURN  ${active_sw_version}  ${active_sw_release_name}


Check If Cell Is Not Degraded
    [Documentation]  This keyword is used to check if cell is not degraded.
    [Arguments]  ${cell_type}  ${cell_id}

    ${status}  Run Keyword And Return Status
    ...  coam.Assert  ${cell_type}  ${cell_id}  availabilityStatus=${DEGRADED}
    IF  ${status}  Fail


Save Kpi Results
    [Documentation]  This KW moves all_kpi_results.json and all_delta_results.json in a new directory with timestamp format.

    ${current_timestamp}  Get Current Date  result_format=%Y-%m-%d_%H:%M
    ${delta_results_path}  Set Variable  ${DELTA_RESULTS_PATH}
    Create Directory  ${delta_results_path}/${current_timestamp}/
    Move File  ${delta_results_path}/all_kpi_results.json  ${delta_results_path}/${current_timestamp}/all_kpi_results.json
    Move File  ${delta_results_path}/all_delta_results.json  ${delta_results_path}/${current_timestamp}/all_delta_results.json


Save Delta Results
    [Documentation]  This keyword is used to save delta results.
    [Arguments]  ${kpi_name}  ${deltas_from_test_case}=@{EMPTY}

    ${kpi_id}  Fetch From Left  ${kpi_name}  _
    ${deltas}  oam_kpi.Get All Deltas  ${kpi_id}  skip_none=True
    ${deltas_is_empty}  Run Keyword And Return Status  Should Be Empty  ${deltas}
    ${deltas_is_none}  Run Keyword And Return Status  Should Be Equal As Strings  ${deltas}  None
    IF  ${deltas_is_empty} or ${deltas_is_none}  RETURN

    Create Directory  ${DELTA_RESULTS_PATH}/
    ${delta_path}  Set Variable  ${DELTA_RESULTS_PATH}/all_delta_results.json
    ${delta_file_exists}  Run Keyword And Return Status  OperatingSystem.File Should Exist  ${delta_path}
    IF  not ${delta_file_exists}  Create File  ${delta_path}
    IF  '${kpi_id}' in ['kpi16a', 'kpi16b', 'kpi17a', 'kpi17b', 'kpi19', 'kpicellreset']
        ${deltas}  Get Cells With Delta Values  ${kpi_id}  ${deltas}
    ELSE IF  "@{deltas_from_test_case}"!="@{EMPTY}"
        ${deltas}  Set Variable  ${deltas_from_test_case}
    ELSE
        ${deltas}  Set Variable  ${deltas}
    END
    ${delta_json}  OperatingSystem.Get File  ${delta_path}

    ${deltas_content}  Create Dictionary
    IF  ${delta_file_exists}
        ${deltas_content}  Evaluate  json.loads('''${delta_json}''')  json
    END
    IF  'kpi1a' in '${kpi_name}' or 'kpi1b' in '${kpi_name}' or 'kpisiteresettobtsresponding' in '${kpi_name}'
        ${deltas}  Append New KPI To Existing Ones From Json File  ${deltas_content}  ${kpi_name}  ${deltas}[-1]
    END

    Set To Dictionary  ${deltas_content}  ${kpi_name}=${deltas}
    ${delta_json_string}  Evaluate  json.dumps(${deltas_content}, indent=4)  json
    Create File  ${delta_path}  ${delta_json_string}
    oam_kpi.Save Results To File  ${DELTA_RESULTS_PATH}/all_kpi_results.json


Get Cells With Delta Values
    [Documentation]  This keyword is used to get cells with delta values.
    [Arguments]  ${kpi_id}  ${deltas}

    ${cells_ids_with_delta_value}  Create Dictionary
    ${results}  Get Results  ${kpi_id}
    ${length}  Get Length  ${deltas}
    FOR  ${index}  IN RANGE  0  ${length}
        ${dict_keys}  Get Dictionary Keys  ${results}[${index}][end_points]
        ${rat}  Get From List  ${dict_keys}  0
        ${cell_runtime_dn}  Get Dictionary Keys  ${results}[${index}][end_points][${rat}]
        ${cell_id}  Fetch From Right  ${cell_runtime_dn}[0]  /
        ${cell_id}  Remove String  ${cell_id}  _R
        ${cell_id_already_in_dict}  Run Keyword And Return Status  Dictionary Should Contain Key  ${cells_ids_with_delta_value}  ${cell_id}
        IF  ${cell_id_already_in_dict}
            ${values}  Get From Dictionary  ${cells_ids_with_delta_value}  ${cell_id}
            Append To List  ${values}  ${deltas}[${index}]
        ELSE
            ${values}  Create List  ${deltas}[${index}]
        END
        Set To Dictionary  ${cells_ids_with_delta_value}  ${cell_id}=${values}
    END

    RETURN  ${cells_ids_with_delta_value}


Append New KPI To Existing Ones From Json File
    [Documentation]  Each delta value is added one by one. This is useful for kpi1a and kpi1b where CB009301 is activated
    ...  and both kpi ids are split into 2 keys: kpi1a and kpi1a_CB009301 (same for kpi1b). Kpi results dict contains
    ...  kpi1a and kpi1b keys only and if kpi values would be written all at once, kpi1a and kpi1b will also contain CB009301
    ...  values which is not ok. CB009301 values should not be written twice in all_delta_results json file.
    [Arguments]  ${delta_json}  ${kpi_name}  ${new_delta}

    ${specific_kpi_is_saved}  Run Keyword And Return Status  Dictionary Should Contain Key  ${delta_json}  ${kpi_name}
    IF  ${specific_kpi_is_saved}
        ${kpi_values}  Get From Dictionary  ${delta_json}  ${kpi_name}
        Append To List  ${kpi_values}  ${new_delta}
    ELSE
        ${kpi_values}  Create List  ${new_delta}
    END

    RETURN  ${kpi_values}


Log Delta In Seconds
    [Documentation]  This keyword is used to log delta in seconds.
    [Arguments]  ${time}  ${kpi_name}

    ${kpi_id}  Fetch From Left  ${kpi_name}  _
    ${deltas}  oam_kpi.Get All Deltas  ${kpi_id}  skip_none=True
    Log  ${kpi_name} delta is: ${time} and converted in seconds: ${deltas}[-1].\n  console=true


Report KPI
    [Documentation]  This keyword is used to report KPI.
    [Arguments]  ${kpi_id}

    ${kpi_results}  Get Results  ${kpi_id}
    ${kpi_dict}  Create Dictionary  ${kpi_id}=${kpi_results}
    Set Reference Configuration ID  ref_configuration_id=${REFERENCE_CONFIGURATION_ID}
    Report OAM KPI  oam_kpi_results=${kpi_dict}  oam_kpi_targets=${OAM_KPI_TARGETS}


Activate Or Deactivate Graceful Cell Shutdown
    [Documentation]  This KW changes the value for LNBTS.enableGrflShdn and NRBTS.actGrflShdn.
    ...  In case of LNBTS, the parameter can have Enabled or Disabled (default) value.
    ...  For NRBTS, the parameter can be changed to true or false (default value).
    [Arguments]  ${enableGrflShdn_new_value}  ${actGrflShdn_new_value}

    IF  ${SCF_COUNT_LTE}  Change Value For EnableGrflShdn  ${enableGrflShdn_new_value}
    IF  ${SCF_COUNT_NR}  Change Value For ActGrflShdn  ${actGrflShdn_new_value}


Change Value For EnableGrflShdn
    [Documentation]  This keyword is used to change value for enableGrflShdn.
    [Arguments]  ${enableGrflShdn_new_value}

    ${lnbts_id}  Admin Get LNBTS ID
    coam.Perform Parameter Recommissioning  MRBTS-${BTS_ID}/LNBTS-${lnbts_id}  enableGrflShdn  update  ${enableGrflShdn_new_value}
    ...  skip_parameter_relation_errors=True  should_activate=True  timeout=300
    Log  enableGrflShdn was changed to ${enableGrflShdn_new_value}.  console=true


Change Value For ActGrflShdn
    [Documentation]  This keyword is used to change value for actGrflShdn.
    [Arguments]  ${actGrflShdn_new_value}

    ${nrbts_id}  Admin Get NRBTS ID
    coam.Perform Parameter Recommissioning  MRBTS-${BTS_ID}/NRBTS-${nrbts_id}  actGrflShdn  update  ${actGrflShdn_new_value}
    ...  skip_parameter_relation_errors=True  should_activate=True  timeout=300
    Log  actGrflShdn was changed to ${actGrflShdn_new_value}.  console=true


Set ActRatResetEnhancement Parameter To True
    [Documentation]  This keyword is used to set actRatResetEnhancement parameter to true.

    ${featcadm_a_object}  coam.Get Managed Objects  FEATCADM_A
    IF  '${featcadm_a_object}[0][parameters][actRatResetEnhancement]'=='False'
        Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1  parameter=actRatResetEnhancement  operation=update
        ...  value=true  skip_parameter_relation_errors=${TRUE}  timeout=120
    END


Check Alarm GPS Receiver Alarm: Firmware Upgrade Ongoing
    [Documentation]  KW to check if this alarm is active and waits until is cleared
    ...  Alarm must be inactive because it disables some funcionality on BTS.
    ...  eg: Rollback, SWR, Parameter Change.
    [Arguments]  ${timeout_active}=2m  ${timeout_inactive}=30m

    Log  Check if "GPS receiver alarm: firmware upgrade ongoing" is visible.  console=true
    ${alarm_parameters}  Catenate  SEPARATOR=${SPACE}  alarmId=7115,  faultId=4420,  alarmName="BASE STATION INFORMATION",
    ...  faultName="GPS receiver alarm: firmware upgrade ongoing"
    ${status_active}  Run Keyword And Return Status
    ...  Assert Alarm Active  ${alarm_parameters}  timeout=${timeout_active}
    IF  ${status_active}
        Log  Alarm ${alarm_parameters} is active. Wait up to ${timeout_inactive} to be inactive.  console=true
    ELSE
        RETURN
    END
    ${status_inactive}  Run Keyword And Return Status  Assert Alarm Inactive  ${alarm_parameters}  timeout=${timeout_inactive}
    IF  ${status_inactive}
        Log  Alarm ${alarm_parameters} cleared in under ${timeout_inactive}.  console=true
    ELSE
        Fatal Error  Test: ${TEST_NAME} failed because ${alarm_parameters} not cleared on time. Suite execution STOPPED.
    END


Check Snapshot To Contain Checkpoints For CP Components
    [Documentation]  This keyword is introduced due to CNI-123749. It must check if specific C-Plane checkpoints are visible in snapshot files and
    ...  save their timestamps which will be used to define intermediate kpis during first_cell_down to last_cell_up for KPI1a (Site reset TC)
    ...  and KPI2 (SWR TC).
    ...  *AUTHOR*: andrada-lavinia.baleti@nokia.com
    ...  *MAINTAINER*: andrada-lavinia.baleti@nokia.com
    [Arguments]  ${nrbts_type}

    ${files_and_folders}  OperatingSystem.List Directory  ${BTS_FILES}
    FOR  ${item}  IN  @{files_and_folders}
        IF  'snapshot.zip' in '${item}'  BREAK
    END
    IF  'snapshot.zip' not in '${item}'  RETURN
    ${snapshot_archive}  Set Variable  ${item}
    ${snapshot_files}  Get Data From Snapshot  ${BTS_FILES}/${snapshot_archive}
    ${snapshot_folder}  Remove String  ${snapshot_archive}  .zip
    OperatingSystem.Run  unzip "${BTS_FILES}/${snapshot_archive}" -d "${BTS_FILES}/${snapshot_folder}"
    ${path_to_snapshot_folder}  Join Path  ${BTS_FILES}  ${snapshot_folder}

    ${components}  Create List  CP-NRT  CP-RT  CP-IF
    ${component_node_id_dict}  Get Node Ids From NrCellMappingInfo file  ${snapshot_files}  ${components}  ${path_to_snapshot_folder}

    ${cp_nrt_checkpoints}  Create List  STRTCP_CP_E1_SETUP_START  STRTCP_CP_E1_SETUP_COMPLETE
    ${cp_rt_checkpoints}  Create List  STRTCP_CP_F1_SETUP_START  STRTCP_CP_F1_SETUP_COMPLETE
    ${component_checkpoints_dict}  Create Dictionary  CP-NRT=${cp_nrt_checkpoints}  CP-RT=${cp_rt_checkpoints}
    ${cp_if_listening_checkpoints}  Create List  STRTCP_CP_E1_SETUP_START_LISTENING  STRTCP_CP_F1_SETUP_START_LISTENING
    ${cp_if_checkpoints}  Create List
    IF  'NSA' in '${nrbts_type}'
        Append To List  ${cp_if_checkpoints}  STRTCP_CP_X2_SETUP_COMPLETE
        Append To List  ${cp_if_listening_checkpoints}  STRTCP_CP_X2_SETUP_START_LISTENING
    END
    IF  '${nrbts_type}'!='NSA'
        Append To List  ${cp_if_checkpoints}  STRTCP_CP_NG_SETUP_START  STRTCP_CP_NG_SETUP_COMPLETE
    END
    Set To Dictionary  ${component_checkpoints_dict}  CP-IF=${cp_if_checkpoints}

    ${CHECKPOINTS_NOT_FOUND}  Create List
    Set Test Variable  ${CHECKPOINTS_NOT_FOUND}
    ${TIMESTAMPS_FOR_CHECKPOINTS}  Create Dictionary
    Set Test Variable  ${TIMESTAMPS_FOR_CHECKPOINTS}
    Check If Checkpoints Are In Snapshot Files And Set Timestamps  ${snapshot_files}  ${component_node_id_dict}
    ...  ${component_checkpoints_dict}  ${cp_if_listening_checkpoints}  ${path_to_snapshot_folder}
    ${tc_name}  Remove String  ${BTS_FILES}  /BTSFiles
    ${tc_name}  Fetch From Right  ${tc_name}  /
    ${length}  Get Length  ${CHECKPOINTS_NOT_FOUND}
    IF  ${length}>0
        Log  Following checkpoints are NOT found for TC ${tc_name}: \n${CHECKPOINTS_NOT_FOUND}.\n  level=WARN
    END
    ${checkpoints_found}  Get Dictionary Keys  ${TIMESTAMPS_FOR_CHECKPOINTS}
    Log  \nFollowing checkpoints are found for TC ${tc_name}: \n${checkpoints_found}.  console=true
    Log  \nTimestamps for C-Plane checkpoints: ${TIMESTAMPS_FOR_CHECKPOINTS}.\n  console=true

    [Teardown]  Run Keyword And Ignore Error  Remove Directory  ${BTS_FILES}/${snapshot_folder}  recursive=${TRUE}


Get Node Ids From NrCellMappingInfo file
    [Documentation]  This keyword access NrCellMappingInfo.txt file from snapshot and returns node ids for CP-RT, CP-NRT and CP-IF components.
    [Arguments]  ${snapshot_files}  ${components}  ${path_to_snapshot_folder}

    FOR  ${file}  IN  @{snapshot_files}
        IF  'NrCellMappingInfo.txt' in '${file}'  BREAK
    END
    Should Contain  ${snapshot_files}[${file}][0]  NrCellMappingInfo.txt  NrCellMappingInfo.txt is not generated in snapshot archive.

    ${nr_cell_mapping_path}  Extract From Path  ${snapshot_files}[${file}][0]  ${path_to_snapshot_folder}
    ${file_content}  OperatingSystem.Get File  ${nr_cell_mapping_path}
    ${component_node_id_dict}  Create Dictionary
    FOR  ${component}  IN  @{components}
        Should Contain  ${file_content}  ${component}
        ${matches}  Get Regexp Matches  ${file_content}  ${component}\\s+0x[0-9]+
        ${node_id}  Fetch From Right  ${matches}[0]  ${SPACE}
        Set To Dictionary  ${component_node_id_dict}  ${component}=${node_id}
    END

    RETURN  ${component_node_id_dict}


Check If Checkpoints Are In Snapshot Files And Set Timestamps
    [Documentation]  This keyword checks if checkpoints from CP-RT, CP-NRT and CP_IF components are visible in snapshot files.
    ...  STRTCP_CP_E1_SETUP_START_LISTENING, STRTCP_CP_F1_SETUP_START_LISTENING and STRTCP_CP_X2_SETUP_START_LISTENING from CP-IF component
    ...  are verified separately because they must be found in startup_cp_sctp.log or runtime_cp_sctp.log. The other checkpoints should appear
    ...  in startup_cp_<rt/nrt/if>.log or runtime_cp_<rt/nrt/if>.log depending on C-Plane component.
    [Arguments]  ${snapshot_files}  ${component_node_id_dict}  ${component_checkpoints_dict}  ${cp_if_listening_checkpoints}
    ...  ${path_to_snapshot_folder}

    Log  \n\nCheck If Checkpoints Are In Snapshot Files And Set Timestamps.  console=true
    ${files}  Create List
    FOR  ${component}  IN  @{component_node_id_dict}
        ${node_id}  Set Variable  ${component_node_id_dict}[${component}]
        ${checkpoints}  Set Variable  ${component_checkpoints_dict}[${component}]
        ${startup_file_content}  Get File Content  ${snapshot_files}  startup  ${component}  ${node_id}  ${path_to_snapshot_folder}
        ${runtime_file_content}  Get File Content  ${snapshot_files}  runtime  ${component}  ${node_id}  ${path_to_snapshot_folder}
        Check If Files Contain Checkpoints  ${startup_file_content}  ${runtime_file_content}  ${checkpoints}
    END
    ${node_id}  Set Variable  ${component_node_id_dict}[CP-IF]
    ${startup_file_content}  Get File Content  ${snapshot_files}  startup  ${component}  ${node_id}  ${path_to_snapshot_folder}  sctp_file=yes
    ${runtime_file_content}  Get File Content  ${snapshot_files}  runtime  ${component}  ${node_id}  ${path_to_snapshot_folder}  sctp_file=yes
    Check If Files Contain Checkpoints  ${startup_file_content}  ${runtime_file_content}  ${cp_if_listening_checkpoints}

    RETURN  ${files}


Check If Files Contain Checkpoints
    [Documentation]  This keyword verifies if list of C-Plane checkpoints are visible in startup or runtime log files and saves timestamp for
    ...  each checkpoint in ${TIMESTAMPS_FOR_CHECKPOINTS} which must be set with test scope before calling this kw.
    [Arguments]  ${startup_file_content}  ${runtime_file_content}  ${checkpoints}

    FOR  ${checkpoint}  IN  @{checkpoints}
        ${checkpint_in_startup_file}  Run Keyword And Return Status  Should Contain  ${startup_file_content}  ${checkpoint}
        ${checkpint_in_runtime_file}  Run Keyword And Return Status  Should Contain  ${runtime_file_content}  ${checkpoint}
        IF  not ${checkpint_in_startup_file} and not ${checkpint_in_runtime_file}
            Append To List  ${CHECKPOINTS_NOT_FOUND}  ${checkpoint}
            CONTINUE
        END

        ${file_content}  Set Variable If  ${checkpint_in_startup_file}  ${startup_file_content}  ${runtime_file_content}
        ${lines}  Get Lines Containing String  ${file_content}  ${checkpoint}
        ${lines}  Split To Lines  ${lines}

        ${timestamp_matches}  Get Regexp Matches  ${lines}[0]  <[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]+Z>
        ${timestamp}  Remove String  ${timestamp_matches}[0]  <  >
        ${datetime}  Convert Date  ${timestamp}
        Set To Dictionary  ${TIMESTAMPS_FOR_CHECKPOINTS}  ${checkpoint}=${datetime}
    END


Get File Content
    [Documentation]  This keyword returns file content for C-Plane log file based on ${file_type} which can be startup or runtime.
    [Arguments]  ${snapshot_files}  ${file_type}  ${component}  ${node_id}  ${path_to_snapshot_folder}  ${sctp_file}=no

    ${node_id}  Remove String  ${node_id}  0x
    ${zip_name}  Set Variable  ${node_id}_${file_type}.zip
    ${file_exist_in_snapshot}  ${zip_path}  Run Keyword And Ignore Error  Get File Path From Snapshot  ${zip_name}  ${snapshot_files}
    IF  '${file_exist_in_snapshot}'=='FAIL'
        Log  There is no ${zip_name} file in snapshot.  level=WARN
        RETURN  ${EMPTY}
    END
    ${path_unzipped}  Extract From Path  ${zip_path}  ${path_to_snapshot_folder}
    ${component_lower_name}  Convert To Lower Case  ${component}
    ${component_lower_name}  Replace String  ${component_lower_name}  -  _
    ${cp_file}  Set Variable If  '${sctp_file}'=='no'  ${component_lower_name}  cp_sctp
    ${path}  Join Path  ${path_unzipped}  ${file_type}_${cp_file}.log
    OperatingSystem.Run  xz -d "${path}.xz" -c > "${path}"
    ${file_content}  OperatingSystem.Get File  ${path}

    RETURN  ${file_content}


Get File Path From Snapshot
    [Documentation]  This keyword returns specific file by ${file_name} from snapshot files.
    [Arguments]  ${file_name}  ${snapshot_files}

    FOR  ${snapshot_file}  IN  @{snapshot_files}
        IF  '${file_name}' in '${snapshot_file}'  RETURN  ${snapshot_files}[${snapshot_file}][0]
    END
    Fail


Set Variables For Linux Software And Software Update Type
    [Documentation]  This keyword sets LINUX_SW_VERSION_BEFORE_SW_UPDATE and SW_UPDATE_TYPE as test get environment variables to be used later in
    ...  calculating proper kpi resulted from software update operation.

    ${linux_sw_version_before_sw_update}  Get Embedded Linux Software Version
    Set Test Variable  ${LINUX_SW_VERSION_BEFORE_SW_UPDATE}
    ${sw_update_type}  Get Software Update Type
    Set Test Variable  ${SW_UPDATE_TYPE}


Get Embedded Linux Software Version
    [Documentation]  This keyword is getting linux software version through ssh connection to primary core.

    Open Connection To Primary Core
    SSHLibrary.Write  cat /etc/*psl_version
    ${linux_sw_version}  SSHLibrary.Read Until Prompt
    ${linux_sw_version}  Fetch From Left  ${linux_sw_version}  ${SPACE}
    [Teardown]  SSHLibrary.Close All Connections

    RETURN  ${linux_sw_version}


Get Software Update Type
    [Documentation]  This keyword determined if software update is intra or inter release by comparing active version with target software.

    ${active_software}  Infomodel Get Active SW Version  MSM  activeBuildDescriptorId
    ${target_software}  hran_file_operations.Get TargetBD Node Attribute Value  softwareReleaseVersion  ${TARGET_SW_PATH}
    ${desired_sw_release_name}  Get Regexp Matches  ${active_software}  SBTS[A-Z0-9]+
    ${active_sw_release_name}  Get Regexp Matches  ${target_software}  SBTS[A-Z0-9]+
    ${sw_update_type}  Set Variable If  '${desired_sw_release_name}[0]'=='${active_sw_release_name}[0]'  intra  inter

    RETURN  ${sw_update_type}


Get RMODs And Cablinks From Soc
    [Documentation]  This kw returns all cablink (synchro or not) and RMODs from Soc if cablink mode is synchronization.
    [Arguments]  ${module_r_dn}  ${soc_type}  ${soc_dn}

    ${cablinks_list}  coam.Get Managed Objects  CABLINK_R
    ${cablink_list}  Create List
    FOR  ${cablink}  IN  @{cablinks_list}
        IF  '${cablink}[parameters][firstEndpointDN]'=='${module_r_dn}'
            Append To List  ${cablink_list}  ${cablink}
        END
    END
    ${cablinks_on_soc}  Create List
    ${ports}  Get Loki Ports  ${soc_type}  ${soc_dn}
    ${rmods_synchro_on_soc}  Create List
    FOR  ${link}  IN  @{cablink_list}
        ${port_id}  Convert To String  ${link}[parameters][firstEndpointPortId]
        ${link_mode_is_synchro}  Run Keyword And Return Status
        ...  Should Match Regexp  '${link}[parameters][linkModeSynchronization]'  (true|True)
        ${status_first_endpoint_port_id}  Run Keyword And Return Status
        ...  List Should Contain Value  ${ports}  ${port_id}
        IF  ${link_mode_is_synchro} and ${status_first_endpoint_port_id}
            Append To List  ${rmods_synchro_on_soc}  ${link}[parameters][secondEndpointDN]
        END
        IF  ${status_first_endpoint_port_id}  Append To List  ${cablinks_on_soc}  ${link}[distName]
    END
    ${rmods_synchro_on_soc}  Remove Duplicates  ${rmods_synchro_on_soc}

    FOR  ${rmod_dn}  IN  @{rmods_synchro_on_soc}
        ${rmods_in_chain}  ${cablinks_in_chain}  Get RMODs And Cablinks Chained Starting From RMOD On SoC  ${rmod_dn}
    END
    ${rmods_in_chain}  Remove Duplicates  ${rmods_in_chain}
    ${cablinks_in_chain}  Remove Duplicates  ${cablinks_in_chain}

    ${rmods_impacted}  Combine Lists  ${rmods_synchro_on_soc}  ${RMODS_IN_CHAIN}
    ${cablinks_impacted}  Combine Lists  ${cablinks_on_soc}  ${CABLINKS_IN_CHAIN}

    RETURN  ${rmods_impacted}  ${cablinks_impacted}


Get RMODs And Cablinks Chained Starting From RMOD On SoC
    [Documentation]  This kw returns cablinks and rmods in chain. It starts from provided ${rmod_dn} and if
    ...  cablinks with ${rmod_dn} as first endpoint exists, then synchronization cablink and rmod from second endpoint
    ...  are added. Kw searches up to 3 RMODs in chain.
    [Arguments]  ${rmod_dn}

    ${rmods_in_chain}  Create List
    ${cablinks_in_chain}  Create List
    ${cablinks_list}  coam.Get Managed Objects  CABLINK_R
    ${cablinks_in_chain_exist}  Set variable  ${False}
    FOR  ${cablink}  IN  @{cablinks_list}
        IF  '${cablink}[parameters][firstEndpointDN]'=='${rmod_dn}'
            ${cablinks_in_chain_exist}  Set variable  ${True}
            BREAK
        END
    END
    IF  not ${cablinks_in_chain_exist}  RETURN  ${rmods_in_chain}  ${cablinks_in_chain}

    ${cablinks_list}  coam.Get Managed Objects  CABLINK_R
    ${cablink_rmod_to_rmod}  Create List
    FOR  ${cablink}  IN  @{cablinks_list}
        IF  '${cablink}[parameters][firstEndpointDN]'=='${rmod_dn}'
            Append To List  ${cablink_rmod_to_rmod}  ${cablink}
        END
    END
    ${link_mode_is_synchro}  Run Keyword And Return Status
    ...  Should Match Regexp  '${cablink_rmod_to_rmod}[0][parameters][linkModeSynchronization]'  (true|True)
    IF  ${link_mode_is_synchro}
        Append To List  ${rmods_in_chain}  ${cablink_rmod_to_rmod}[0][parameters][secondEndpointDN]
        Append To List  ${cablinks_in_chain}  ${cablink_rmod_to_rmod}[0][parameters][distName]
    END

    ${rmod_dn}  Set Variable  ${cablink_rmod_to_rmod}[0][parameters][secondEndpointDN]
    ${cablinks_list}  coam.Get Managed Objects  CABLINK_R
    ${cablinks_in_chain_exist}  Set variable  ${False}
    FOR  ${cablink}  IN  @{cablinks_list}
        IF  '${cablink}[parameters][firstEndpointDN]'=='${rmod_dn}'
            ${cablinks_in_chain_exist}  Set variable  ${True}
            BREAK
        END
    END
    IF  not ${cablinks_in_chain_exist}  RETURN  ${rmods_in_chain}  ${cablinks_in_chain}

    ${cablinks_list}  coam.Get Managed Objects  CABLINK_R
    ${cablink_rmod_to_rmod}  Create List
    FOR  ${cablink}  IN  @{cablinks_list}
        IF  '${cablink}[parameters][firstEndpointDN]'=='${rmod_dn}'
            Append To List  ${cablink_rmod_to_rmod}  ${cablink}
        END
    END
    ${link_mode_is_synchro}  Run Keyword And Return Status
    ...  Should Match Regexp  '${cablink_rmod_to_rmod}[0][parameters][linkModeSynchronization]'  (true|True)
    IF  ${link_mode_is_synchro}
        Append To List  ${rmods_in_chain}  ${cablink_rmod_to_rmod}[0][parameters][secondEndpointDN]
        Append To List  ${cablinks_in_chain}  ${cablink_rmod_to_rmod}[0][parameters][distName]
    END

    RETURN  ${rmods_in_chain}  ${cablinks_in_chain}


Get Additional Affected Cells Mapped On Loki
    [Documentation]  This kw returns cells from chosen Loki which are mapped on RMOD from other SoC.
    [Arguments]  ${cells_on_loki}  ${synchro_rmods_on_loki}

    ${additional_affected_cells}  Create List
    ${rmods}  Get Ids For All  RMOD
    Remove Values From List  ${rmods}  @{synchro_rmods_on_loki}
    FOR  ${rmod_dn}  IN  @{rmods}
        ${cells_on_rmod}  Get Cell Mapping By Module Id  ${rmod_dn}
        ${status}  Cells On Loki Are Mapped On RMOD From Other SoC  ${cells_on_loki}  ${cells_on_rmod}
        IF  not ${status}  CONTINUE
        Remove Values From List  ${cells_on_rmod}  @{cells_on_loki}
        Append To List  ${additional_affected_cells}  @{cells_on_rmod}
    END
    ${additional_affected_cells}  Remove Duplicates  ${additional_affected_cells}

    RETURN  ${additional_affected_cells}


Cells On Loki Are Mapped On RMOD From Other SoC
    [Documentation]  This kw checks id cells from chosen Loki are also mapped on RMOD from other SoC.
    [Arguments]  ${cells_on_loki}  ${cells_on_rmod}

     FOR  ${cell_dn}  IN  @{cells_on_loki}
         IF  '${cell_dn}' in ${cells_on_rmod}  RETURN  ${TRUE}
     END

     RETURN  ${FALSE}
