*** Settings ***
Documentation
...  This TC is checking SFP measurements.
...  First, SFP parameters and PM reporting Interval are set to 15min.
...  TC waits until new 15 min interval.
...  Values returned by get_sfp_data() from admin connection are saved as expected.
...  Snapshot is collected and the last PM RD file is analyzed.
...  SFP_TEMPERATURE, SFP_XCVR_TX_SUPPLY_VOLTAGE, SFP_XCVR_TX_BIAS_CURRENT values for each SFP with "SFP_SMOD" as measurement type from RD file
...  must be the same as get_sfp_data() output.
...  SFP_XCVR_TX_PWR, SFP_XCVR_RX_OPT_PWR values from RD file are ten times higher than get_sfp_data() output.
...  For each comparison 1 unit tolerance is used.
...  In the end, SFP parameters are set to disabled, except for mtSfp which must be 15min.

Resource  ../../common_resources/ca_PM_general.robot


*** Keywords ***
TC__PM__SFP_Dynamic_Data
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28741
    ...
    ...  *******************
    ...  History of changes
    ...  - 11.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28741 - Initial TAT creation
    ...  - 16.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29243 - Ignore mtSfp parameter for branches higher than 25R2

    Set Tags  CA-PM  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com  GROUP_IN_CHARGE-TIM_1_Vrf  FEATURE-LTE2379

    Step1: Enable SFP Monitoring
    Step2: Check SFP Dynamic Data From RD File


Step1: Enable SFP Monitoring
    Log  \nStep1: Enable SFP Monitoring  console=true
    Change SFP Parameters And Reporting Interval To 15min
    Sleep Until New Cycle  15min
    Sleep  1min  TC will wait until counters are fully loaded.


Step2: Check SFP Dynamic Data From RD File
    Log  \nStep2: Check SFP Dynamic Data From RD File  console=true
    ${sfp_data_from_admin}  Get Expected Sfp Data

    Collect Snapshot  target_file_name=${BTS_FILES}/snapshot_to_check_RD_file.zip  timeout=1200
    ${snapshot_archive}  Set Variable  snapshot_to_check_RD_file.zip
    ${sfp_objects_from_xml}  Get SFP Objects From XML RD Report  ${snapshot_archive}

    ${sfp_data_from_rd_file}  Create Dictionary
    FOR  ${sfp_xml_object}  IN  @{sfp_objects_from_xml}
        ${sfp_dn}  Get Regexp Matches  ${sfp_xml_object}  <DN>.+</DN>
        ${sfp_dn}  Remove String  ${sfp_dn}[-1]  <DN>  </DN>  PLMN-PLMN/
        ${meas_values_dict}  Get SFP Meas Dict From Xml  ${sfp_xml_object}
        Set To Dictionary  ${sfp_data_from_rd_file}  ${sfp_dn}=${meas_values_dict}
    END

    ${sfp_short_a_r_dns}  Get SFP A R Short Distnames
    FOR  ${sfp_dn}  IN  @{sfp_data_from_rd_file}
        ${sfp_short_a_dns}  Get Dictionary Keys  ${sfp_short_a_r_dns}
        List Should Contain Value  ${sfp_short_a_dns}  ${sfp_dn}  SFP Dynamic Data is not reported for ${sfp_dn}.
        Check Dynamic Data  ${sfp_dn}  ${sfp_data_from_admin}[${sfp_short_a_r_dns}[${sfp_dn}]]  ${sfp_data_from_rd_file}[${sfp_dn}]
    END


Change SFP Parameters And Reporting Interval To 15min
    ${delta_id}  Set Variable  change_sfp_meas
    Create Delta  ${delta_id}
    ${params}  Create List  mtSBTSSfpBBMOD  mtSbtsSfpBbmodLane  mtSBTSSfpRMOD  mtSbtsSfpRmodLane  mtSBTSSfpSMOD  mtSbtsSfpSmodLane
    ...  mtSbtsSfpFhs  mtSbtsSfpFhsLane
    IF  '${ENB_BRANCH}' <= '25R2'  Append To List  ${params}  mtSfp
    ${object_path}  Set Variable  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1
    ${sfp_params_values}  Get Parameter By Distname  ${object_path}  ${params}
    ${sfp_params_values}  Set Variable  ${sfp_params_values}[0][parameters]
    FOR  ${param}  IN  @{sfp_params_values}
        IF  '${sfp_params_values}[${param}]'!='15min'  Append Parameter Update To Delta  ${object_path}  ${param}  15min  ${delta_id}
    END

    ${param_list}  Create List  reportingIntervalPm
    ${parameter}  Get Parameter By Distname  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMCADM-1  ${param_list}
    IF  '${parameter}[0][parameters][reportingIntervalPm]'!='15min'  Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMCADM-1
    ...  reportingIntervalPm  15min  ${delta_id}

    ${delta}  Get Delta  ${delta_id}
    ${delta_is_empty}  Run Keyword And Return Status  Should Be Equal As Strings  ${delta}  []
    IF  ${delta_is_empty}  RETURN

    Save Delta  ${BTS_FILES}/enable_sfp_monitoring.json  ${delta_id}
    Perform Delta Recommissioning  ${BTS_FILES}/enable_sfp_monitoring.json  skip_parameter_relation_errors=True

    [Teardown]  Remove Delta  ${delta_id}


Get Expected Sfp Data
    ${sfp_data_from_admin}  Create Dictionary
    ${sfp_data}  Get Sfp Data
    ${connectors}  Set Variable  ${sfp_data}[connected]
    ${sfp_list}  Create List
    FOR  ${connector}  IN  @{connectors}
        Append To List  ${sfp_list}  ${connector}[source][connector]  ${connector}[destination][connector]
    END
    FOR  ${connector}  IN  @{sfp_list}
        ${sfp_dn}  Remove String  ${connector}[extendedId][runtime]  _R
        ${sfp_params}  Set Variable  ${connector}[sfp]
        ${current}  Remove String  ${sfp_params}[transceiverTxBiasCurrent]  [  ]
        ${tx_power}  Remove String  ${sfp_params}[opticalTxPowerInDbM]  [  ]
        ${rx_power}  Remove String  ${sfp_params}[opticalRxPowerInDbM]  [  ]
        ${sfp_measurements}  Create Dictionary  SFP_TEMPERATURE=${sfp_params}[temperature]  SFP_XCVR_TX_SUPPLY_VOLTAGE=${sfp_params}[voltage]
        ...  SFP_XCVR_TX_BIAS_CURRENT=${current}  SFP_XCVR_TX_PWR=${tx_power}  SFP_XCVR_RX_OPT_PWR=${rx_power}
        Set To Dictionary  ${sfp_data_from_admin}  ${sfp_dn}=${sfp_measurements}
    END

    RETURN  ${sfp_data_from_admin}


Get SFP Objects From XML RD Report
    [Arguments]  ${snapshot_archive}

    ${snapshot_files}  Get Data From Snapshot  ${BTS_FILES}/${snapshot_archive}
    ${snapshot_folder}  Remove String  ${snapshot_archive}  .zip
    OperatingSystem.Run  unzip "${BTS_FILES}/${snapshot_archive}" -d "${BTS_FILES}/${snapshot_folder}"
    ${path_to_snapshot_folder}  Join Path  ${BTS_FILES}  ${snapshot_folder}

    ${file_content}  OperatingSystem.Get File  ${path_to_snapshot_folder}/snapshot_file_list.txt
    ${rd_files}  Get Regexp Matches  ${file_content}  BTS[0-9_]+RD\.BTS-.+\.xml\.gz

    ${last_gz_rd_file_path}  Extract From Path  ${snapshot_files}[${rd_files}[-1]][0]  ${path_to_snapshot_folder}
    Log  \n${last_gz_rd_file_path} will be checked.  console=true
    ${last_xml_rd_file_path}  Remove String  ${last_gz_rd_file_path}  .gz
    Run  gzip -d -c ${last_gz_rd_file_path} > ${last_xml_rd_file_path}
    ${file_content}  OperatingSystem.Get File  ${last_xml_rd_file_path}

    ${sfp_objects}  Create List
    ${xml_objects}  Split String  ${file_content}  <PMMOResult>
    FOR  ${object}  IN  @{xml_objects}
        IF  'measurementType="SFP_SMOD"' in '${object}'  Append To List  ${sfp_objects}  <PMMOResult>${object}
    END

    RETURN  ${sfp_objects}
    [Teardown]  Run Keyword And Ignore Error  Remove Directory  ${BTS_FILES}/${snapshot_folder}  recursive=${TRUE}


Get SFP Meas Dict From Xml
    [Arguments]  ${sfp_xml_object}

    ${meas_values_dict}  Create Dictionary
    ${sfp_measurements}  Create List  SFP_TEMPERATURE  SFP_XCVR_TX_SUPPLY_VOLTAGE  SFP_XCVR_TX_BIAS_CURRENT  SFP_XCVR_TX_PWR  SFP_XCVR_RX_OPT_PWR
    FOR  ${meas_name}  IN  @{sfp_measurements}
        ${meas_line}  Get Regexp Matches  ${sfp_xml_object}  <${meas_name}>.+</${meas_name}>
        ${meas_value}  Remove String  ${meas_line}[-1]  <${meas_name}>  </${meas_name}>
        Set To Dictionary  ${meas_values_dict}  ${meas_name}=${meas_value}
    END

    RETURN  ${meas_values_dict}


Get SFP A R Short Distnames
    ${sfp_ids}  Get Ids For All  SFP
    ${sfp_short_a_r_dns}  Create Dictionary
    FOR  ${id}  IN  @{sfp_ids}
        ${new_id}  Remove String Using Regexp  ${id}  .*VIEW-\\d+/  _R
        ${new_id}  Replace String Using Regexp  ${new_id}  MRBTS-\\d+  MRBTS-${BTS_ID}
        ${id_a_short}  Get Module A Short Distname  ${id}  ${new_id}
        Set To Dictionary  ${sfp_short_a_r_dns}  ${id_a_short}=${new_id}
    END

    RETURN  ${sfp_short_a_r_dns}


Get Module A Short Distname
    [Arguments]  ${sfp_r_distname}  ${sfp_r_short_distname}
    ${module_r_distname}  Remove String Using Regexp  ${sfp_r_distname}  /SFP_R-\\d+
    ${module_r_params}  coam.Get Parameters  ${module_r_distname}
    ${module_a_id}  Fetch From Right  ${module_r_params}[configDN]  -
    ${module_type}  Set Variable If  'RMOD' in '${sfp_r_short_distname}'  RMOD  'BBMOD' in '${sfp_r_short_distname}'  BBMOD
    ...  'SMOD' in '${sfp_r_short_distname}'  SMOD
    ${sfp_a_short_distname}  Replace String Using Regexp  ${sfp_r_short_distname}  ${module_type}-\\d  ${module_type}-${module_a_id}

    RETURN  ${sfp_a_short_distname}


Check Dynamic Data
    [Documentation]  This KW checks if SFP values from RD file are the same as SFP values from admin.
    [Arguments]  ${sfp_dn}  ${meas_expected_values}  ${meas_rd_file_values}

    FOR  ${sfp_meas}  IN  @{meas_expected_values}
        IF  '${sfp_meas}' in ['SFP_XCVR_TX_PWR','SFP_XCVR_RX_OPT_PWR']
            ${expected_value}  Evaluate  round(float(${meas_expected_values}[${sfp_meas}]) * 10)
        ELSE
            ${expected_value}  Set Variable  ${meas_expected_values}[${sfp_meas}]
        END
        ${as_expected}  Run Keyword And Return Status  Should Be True  (${meas_rd_file_values}[${sfp_meas}] - ${expected_value}) in [-1,0,1]
        IF  not ${as_expected}  Fail  ${sfp_meas} for ${sfp_dn} is not as expected: ${meas_rd_file_values}[${sfp_meas}]!=${expected_value}.
    END


Restore SFP Parameters
    ${delta_id}  Set Variable  change_sfp_meas
    Create Delta  ${delta_id}
    ${params}  Create List  mtSBTSSfpBBMOD  mtSbtsSfpBbmodLane  mtSBTSSfpRMOD  mtSbtsSfpRmodLane  mtSBTSSfpSMOD  mtSbtsSfpSmodLane
    ...  mtSbtsSfpFhs  mtSbtsSfpFhsLane
    IF  '${ENB_BRANCH}'<='25R2'  Append To List  ${params}  mtSfp
    ${object_path}  Set Variable  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1
    ${sfp_params_values}  Get Parameter By Distname  ${object_path}  ${params}
    ${sfp_params_values}  Set Variable  ${sfp_params_values}[0][parameters]
    FOR  ${param}  IN  @{sfp_params_values}
        IF  '${param}'=='mtSfp'  CONTINUE
        IF  '${sfp_params_values}[${param}]'!='disabled'  Append Parameter Update To Delta  ${object_path}  ${param}  disabled  ${delta_id}
    END
    IF  '${ENB_BRANCH}'<='25R2'
        IF  '${sfp_params_values}[mtSfp]'!='15min'  Append Parameter Update To Delta  ${object_path}  ${param}  15min  ${delta_id}
    END

    ${delta}  Get Delta  ${delta_id}
    ${delta_is_empty}  Run Keyword And Return Status  Should Be Equal As Strings  ${delta}  []
    IF  ${delta_is_empty}  RETURN

    Save Delta  ${BTS_FILES}/restore_params.json  ${delta_id}
    Perform Delta Recommissioning  ${BTS_FILES}/restore_params.json  skip_parameter_relation_errors=True

    [Teardown]  Remove Delta  ${delta_id}


TC Setup
    Common Test Setup


TC Teardown
    Restore SFP Parameters
    Common Test Teardown
