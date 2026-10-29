*** Settings ***
Library    OperatingSystem
Library    Collections
Library    String
Library    BuiltIn
Library    DateTime

*** Variables ***

*** Keywords ***
Get SBTS SCF File Path
    [Arguments]    ${sw_version}
    ...    ${cur_relative_dir}=testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common
    @{result}    string.split string    ${sw_version}    separator=_
    # WESTLAKE-10625 trunk build contains 'ENB_9990' rather than 'ENB_9999' sometimes
    ${sbts_trunk}    run keyword and return status      Should Match Regexp    ${sw_version}    .*_ENB_(9999|9990)_.*
    ${SW_vesion_tmp}       set variable if      ${sbts_trunk}    SBTS00    ${result}[0]
    ${scf_base_path}    String.Replace String    ${CURDIR}    ${cur_relative_dir}    ${scf_relative_dir}
    ${ute_env}    run keyword and return status    run keywords
    ...    Variable Should Exist    ${CONFIGURATION}    AND    Variable Should Exist    ${ENB_BUILD}
    ${testline}   run keyword if    ${ute_env}    String.Fetch From Right    string=${CONFIGURATION}    marker=.
    ...           ELSE    set variable     ${testline_name}
    ${path}    Catenate    SEPARATOR=${/}    ${scf_base_path}    ${testline}    SCF_${SW_vesion_tmp}.xml
    [Return]    ${path}

Generate SBTS Test Case Log Path
    ${time_stamp}    DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${tc_name}=    Replace String    string=${TEST NAME}    search_for=${SPACE}    replace_with=_
    ${case_log_path}    Join path    ${SUITE_LOG_PATH}    TC_${tc_name}/${time_stamp}
    Set test variable    ${CASE_LOG_PATH}    ${case_log_path}
    Create directory    ${case_log_path}

get sw name
    [Arguments]    ${SW}=${Active_SW_version}
    ${sbts_status}    run keyword and return status     Should contain    ${SW}    SBTS
    @{result}    string.split string    ${SW}    separator=_
    # WESTLAKE-10625 trunk build contains 'ENB_9990' rather than 'ENB_9999' sometimes
    ${sbts_trunk}    run keyword and return status      Should Match Regexp    ${SW}    .*_ENB_(9999|9990)_.*
    ${sw_version}   run keyword if    ${sbts_trunk}    Replace String    ${SW}    ${result}[0]    SBTS00
    ...           ELSE    set variable     ${SW}
    ${sw_name}    set variable if      ${sbts_status}    ${sw_version}_release_BTSSM_downloadable_A54.zip
    ...    AirScale-${SW}.zip
    ${separator_temp}    set variable if      ${sbts_status}    _    .
    @{rest}    String.split string    string=${sw_version}    separator=${separator_temp}
    ${steam}    set variable if      ${sbts_status}    ${rest}[0]    ${rest}[0].${rest}[1]
    ${packages_path}    set variable if      ${sbts_status}    ${steam}_packages/
    ${arti_path}    run keyword if
    ...    ${sbts_status}==${True}      set variable     ${arti_hz_sbts}${packages_path}
    ...    ELSE      set variable    ${arti_hz}
    ${sw_full_url}  set variable     ${arti_path}${sw_version}/${sw_name}
    [Return]    ${sw_name}    ${sw_full_url}

get old sw version
    [Arguments]    ${SW}=${Active_SW_version}
    ${sbts_status}    run keyword and return status     Should contain    ${SW}    SBTS
    @{result}    string.split string    ${SW}    separator=_
    # WESTLAKE-10625 trunk build contains 'ENB_9990' rather than 'ENB_9999' sometimes
    ${sbts_trunk}    run keyword and return status      Should Match Regexp    ${SW}    .*_ENB_(9999|9990)_.*
    ${sw_version}   run keyword if    ${sbts_trunk}    Replace String    ${SW}    ${result}[0]    SBTS00
    ...           ELSE    set variable     ${SW}
    ${separator_temp}    set variable if      ${sbts_status}    _    .
    @{rest}    String.split string    string=${sw_version}    separator=${separator_temp}
    ${steam}    set variable if      ${sbts_status}    ${rest}[0]    ${rest}[0].${rest}[1]
    ${Old_SW_version}   get from dictionary  ${Old_SW_version_for_stream}  ${steam}
    ${Old_SW_version}    Set Variable If    '${target_old_version}' == 'null'   ${Old_SW_version}    ${target_old_version}
    [Return]    ${Old_SW_version}

Generate Modify cell lock unlock Parameters list
    [Arguments]    ${cell_info_list}    ${new_value}=locked
    ${modify_params}  create list
    FOR  ${cell}  IN  @{cell_info_list}
        ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/LNBTS-${NRBTS_ID}/LNCEL-${cell["cell_index"]}
        ...    filter_param=Administrative state  p_name=administrativeState  value=${new_value}
        append to list  ${modify_params}  ${item}
    END
    [Return]    ${modify_params}

get the boundary of stream
    [Arguments]    ${stream}
    ${boundary}    set variable if    '${stream}'=='SBTS22R1' or '${stream}'=='SBTS22R2'    old_version    new_version
    [Return]  ${boundary}

get the boundary of stream with 24R2
    [Documentation]
    ...    *****************
    ...    Determine whether it is 24R2, before 24R2, or after 24R2
    ...   Owner_kaihui.fan@nokia-sbell.com
    [Arguments]    ${stream}
    ${boundary}    set variable if    '${stream}'=='SBTS23R3' or '${stream}'=='SBTS23R4' or '${stream}'=='SBTS24R1' or '${stream}'=='SBTS24R2'
    ...  old_version    new_version
    [Return]  ${boundary}

Get CA modify parameters list
    [Arguments]    ${new_value}=true
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/LNBTS-${nrbtsID}
    ...    filter_param=Activation of downlink carrier aggregation  p_name=actDLCAggr  value=${new_value}
    append to list  ${modify_params}  ${item}
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/LNBTS-${nrbtsID}
    ...    filter_param=Activate inter-eNB DL carrier aggregation  p_name=actInterEnbDLCAggr  value=${new_value}
    append to list  ${modify_params}  ${item}
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/LNBTS-${nrbtsID}
    ...    filter_param=Activate CA algorithm trigger based on UE AMBR change  p_name=actAmbrModCaTrigger  value=${new_value}
    append to list  ${modify_params}  ${item}
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/LNBTS-${nrbtsID}
    ...    filter_param=Activate flexible carrier aggregation management  p_name=actFlexCaMgmt  value=${new_value}
    append to list  ${modify_params}  ${item}
    [Return]  ${modify_params}

add fault to the history allowed fault list
    [Arguments]    ${faultId}
    log to console    \n add Fault ${faultId} to ALLOWED HISTORY FAULT LIST
    ${ALLOWED_HISTORY_FAULT_TEMP}    Copy List    ${ALLOWED_HISTORY_FAULT}
    ${Fault_DIC}    Create Dictionary    faultId=${faultId}
    Append To List     ${ALLOWED_HISTORY_FAULT_TEMP}    ${Fault_DIC}
    Set suite Variable    ${ALLOWED_HISTORY_FAULT}    ${ALLOWED_HISTORY_FAULT_TEMP}

remove fault from history allowed fault list
    [Arguments]    ${faultId}
    log to console    \n remove Fault ${faultId} to ALLOWED HISTORY FAULT LIST
    ${ALLOWED_HISTORY_FAULT_TEMP}    Copy List    ${ALLOWED_HISTORY_FAULT}
    ${Fault_DIC}    Create Dictionary    faultId=${faultId}
    Remove Values From List     ${ALLOWED_HISTORY_FAULT_TEMP}    ${Fault_DIC}
    Set suite Variable    ${ALLOWED_HISTORY_FAULT}    ${ALLOWED_HISTORY_FAULT_TEMP}

Check cpri link state from BTSOM
    [Arguments]   ${output_links}
    @{links}    get regexp matches    ${output_links}    (\\d) with state: ECpriState_(.)    1    2
    &{link_d}=    create dictionary
    FOR    ${link}    IN    @{links}
       Set To Dictionary     ${link_d}     ${link[0]}    ${link[1]}
    END
    ${links_status}    Get Dictionary Values    ${link_d}
    FOR    ${link_status}    IN    @{links_status}
        Should be True    '${link_status}'=='F' or '${link_status}'=='G'
    END

Get CB007331 modify parameters list
    [Arguments]    ${cables_info_list}     ${cell_info_list}    ${carriermode}=true    ${iqcompression}=9bits
    ...    ${actdownsampling}=true
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-1
    ...    filter_param=Legacy wide carrier mode  p_name=legacyWideCarrierMode  value=${carriermode}
    append to list  ${modify_params}  ${item}
    FOR  ${cables_info}  IN  @{cables_info_list}
        ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/EQM-1/HWTOP-1/${cables_info}[objectname]
        ...    filter_param=IQ compression  p_name=iqCompression  value=${iqcompression}
        append to list  ${modify_params}  ${item}
    END
    FOR  ${cell_info}  IN  @{cell_info_list}
        ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_info}[cell_index]
        ...    filter_param=Activate down sampling  p_name=actDownSampling  value=${actdownsampling}
        append to list  ${modify_params}  ${item}
    END
    [Return]  ${modify_params}

Get split mode modify parameters list
    [Arguments]    ${cell_id}    ${band}    ${mMimoAntArrayMode}    ${nrCellType}=4DL4UL    ${actUlSrsBm}=false
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=Channel bandwidth  p_name=chBw  value=${band}MHz
    append to list  ${modify_params}  ${item}
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=Massive MIMO Antenna Array Mode  p_name=mMimoAntArrayMode  value=${mMimoAntArrayMode}
    append to list  ${modify_params}  ${item}
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=NR Cell type  p_name=nrCellType  value=${nrCellType}
    append to list  ${modify_params}  ${item}
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=Activate uplink SRS based beam management  p_name=actUlSrsBm  value=${actUlSrsBm}
    append to list  ${modify_params}  ${item}
    [Return]  ${modify_params}

generate core assembly modify files
    ${modify_file}  create list
    ${item}  create dictionary  current_name=core_assembly_product_code.txt  new_name=core_assembly_product_code_bak.txt
    append to list  ${modify_file}  ${item}
    ${item}  create dictionary  current_name=core_assembly_product_code.txt.md5  new_name=core_assembly_product_code_bak.txt.md5
    append to list  ${modify_file}  ${item}
    ${item}  create dictionary  current_name=core_assembly_serial_number.txt  new_name=core_assembly_serial_number_bak.txt
    append to list  ${modify_file}  ${item}
    ${item}  create dictionary  current_name=core_assembly_serial_number.txt.md5  new_name=core_assembly_serial_number_bak.txt.md5
    append to list  ${modify_file}  ${item}
    [Return]  ${modify_file}

Check if Tx parameters have a valid value for ports for BBMOD
    [Documentation]
    ...     This keyword make a for loop to select a proper link to check Tx parameters
    [Arguments]    ${links}    ${dict_of_links}     ${physicalPort}
    ${list_of_links}    Get Dictionary Keys    ${dict_of_links}
    FOR    ${port}    IN    @{list_of_links}
        Check if Tx parameters have a valid value for directions for BBMOD  ${links}    ${dict_of_links}    ${port}    ${physicalPort}
    END

Check if Tx parameters have a valid value for directions for BBMOD
    [Documentation]
    ...     This keyword make a for loop to select a proper direction to check Tx parameters
    [Arguments]    ${links}    ${dict_of_links}    ${port}     ${physicalPort}
    ${list_of_directions}=    Get From Dictionary    ${dict_of_links}    ${port}
    FOR    ${direction}    IN    @{list_of_directions}
        Run Keyword If  '${physicalPort}'=='Q_RF2' or '${physicalPort}'=='Q_RF1'
        ...    Run Keywords
        ...   Set Suite Variable   ${txPowerHighAlarmThreshold}
        ...    ${links["connected"][${port}]["details"]["thresholds"]["txPowerHighAlarmThreshold"]["${direction}"]}  AND
        ...    List Should Contain Value    ${txPower_list}      ${txPowerHighAlarmThreshold}    AND
        ...    Set Suite Variable   ${txPowerLowAlarmThreshold}
        ...    ${links["connected"][${port}]["details"]["thresholds"]["txPowerHighAlarmThreshold"]["${direction}"]}  AND
        ...    List Should Contain Value    ${txPower_list}      ${txPowerLowAlarmThreshold}    AND
        ...    Set Suite Variable     ${txPowerHighWarnThreshold}
        ...    ${links["connected"][${port}]["details"]["thresholds"]["txPowerHighWarnThreshold"]["${direction}"]}  AND
        ...    List Should Contain Value    ${txPower_list}       ${txPowerHighWarnThreshold}    AND
        ...    Set Suite Variable    ${txPowerLowWarnThreshold}
        ...    ${links["connected"][${port}]["details"]["thresholds"]["txPowerLowWarnThreshold"]["${direction}"]}  AND
        ...    List Should Contain Value    ${txPower_list}       ${txPowerLowWarnThreshold}
        ...    ELSE
        ...    Run Keywords
        ...    Set Suite Variable   ${txPowerHighAlarmThreshold}
        ...    ${links["connected"][${port}]["details"]["thresholds"]["txPowerHighAlarmThreshold"]["${direction}"]}  AND
        ...   Should Be True  -100<=${txPowerHighAlarmThreshold}<=100    AND
        ...   Set Suite Variable   ${txPowerLowAlarmThreshold}
        ...    ${links["connected"][${port}]["details"]["thresholds"]["txPowerLowAlarmThreshold"]["${direction}"]}  AND
        ...   Should Be True  -100<=${txPowerLowAlarmThreshold}<=100    AND
        ...   Set Suite Variable   ${txPowerHighWarnThreshold}
        ...    ${links["connected"][${port}]["details"]["thresholds"]["txPowerHighWarnThreshold"]["${direction}"]}  AND
        ...   Should Be True  -100<=${txPowerHighWarnThreshold}<=100    AND
        ...   Set Suite Variable   ${txPowerLowWarnThreshold}
        ...    ${links["connected"][${port}]["details"]["thresholds"]["txPowerLowWarnThreshold"]["${direction}"]}    AND
        ...   Should Be True  -100<=${txPowerLowWarnThreshold}<=100
    END

Check if temperature parameters have a valid value for ports for SMOD
    [Documentation]
    ...     This keyword make a for loop to select a proper link to check static parameters
    [Arguments]    ${links}    ${dict_of_links}
    ${list_of_links}    Get Dictionary Keys    ${dict_of_links}
    FOR    ${port}    IN    @{list_of_links}
        Check if temperature parameters have a valid value for directions for SMOD   ${links}    ${dict_of_links}    ${port}
    END

Check if temperature parameters have a valid value for directions for SMOD
    [Documentation]
    ...     This keyword make a for loop to select a proper direction to check static parameters
    [Arguments]    ${links}    ${dict_of_links}    ${port}
    ${list_of_directions}=    Get From Dictionary    ${dict_of_links}    ${port}
    FOR    ${direction}    IN    @{list_of_directions}
        Set Suite Variable   ${temperatureHighAlarmThreshold}
        ...    ${links["notConnected"][${port}]["details"]["thresholds"]["temperatureHighAlarmThreshold"]["${direction}"]}
        Should Be True  -128<=${temperatureHighAlarmThreshold}<=128
        Set Suite Variable   ${temperatureLowAlarmThreshold}
        ...    ${links["notConnected"][${port}]["details"]["thresholds"]["temperatureLowAlarmThreshold"]["${direction}"]}
        Should Be True  -128<=${temperatureLowAlarmThreshold}<=128
    END

Check if static parameters have a valid value for ports
    [Documentation]
    ...     This keyword make a for loop to select a proper link to check static parameters
    [Arguments]    ${links}    ${dict_of_links}
    ${list_of_links}    Get Dictionary Keys    ${dict_of_links}
    FOR    ${port}    IN    @{list_of_links}
        Check if static parameters have a valid value for directions   ${links}    ${dict_of_links}    ${port}
    END

Check if static parameters have a valid value for directions
    [Documentation]
    ...     This keyword make a for loop to select a proper direction to check static parameters
    [Arguments]    ${links}    ${dict_of_links}    ${port}
    ${list_of_directions}=    Get From Dictionary    ${dict_of_links}    ${port}
    FOR    ${direction}    IN    @{list_of_directions}
        Set Suite Variable   ${rxPowerHighAlarmThreshold}
        ...    ${links["connected"][${port}]["details"]["thresholds"]["rxPowerHighAlarmThreshold"]["${direction}"]}
        Should Be True  -100<=${rxPowerHighAlarmThreshold}<=100
        Set Suite Variable   ${rxPowerLowAlarmThreshold}
        ...    ${links["connected"][${port}]["details"]["thresholds"]["rxPowerLowAlarmThreshold"]["${direction}"]}
        Should Be True  -100<=${rxPowerLowAlarmThreshold}<=100
        Set Suite Variable   ${rxPowerHighWarnThreshold}
        ...    ${links["connected"][${port}]["details"]["thresholds"]["rxPowerHighWarnThreshold"]["${direction}"]}
        Should Be True  -100<=${rxPowerHighWarnThreshold}<=100
        Set Suite Variable   ${rxPowerLowWarnThreshold}
        ...    ${links["connected"][${port}]["details"]["thresholds"]["rxPowerLowWarnThreshold"]["${direction}"]}
        Should Be True  -100<=${rxPowerLowWarnThreshold}<=100
    END

Check if static data SFP QSFP have a valid value for ports for SMOD
    [Documentation]
    ...     This keyword make a for loop to select a proper link to check static data SFP QSFP
    [Arguments]    ${links}    ${dict_of_links}
    ${list_of_links}    Get Dictionary Keys    ${dict_of_links}
    FOR    ${port}    IN    @{list_of_links}
        Check if static data SFP QSFP have a valid value for directions for SMOD  ${links}    ${dict_of_links}    ${port}
    END

Check if static data SFP QSFP have a valid value for directions for SMOD
   [Documentation]
    ...     This keyword make a for loop to select a proper direction to check static data SFP QSFP
    [Arguments]    ${links}    ${dict_of_links}    ${port}    ${connection}=GNB_OAM
    ${list_of_directions}=    Get From Dictionary    ${dict_of_links}    ${port}
    FOR    ${direction}    IN    @{list_of_directions}
        Set Suite Variable   ${SFP_QSFP_Manufacturer_Date}
        ...    ${links["notConnected"][${port}]["details"]["staticParameters"]["dateCode"]["${direction}"]}
        Check SFP Manufactury Date    ${SFP_QSFP_Manufacturer_Date}
        Set Suite Variable   ${compliance_Code}
        ...    ${links["notConnected"][${port}]["details"]["hardwareParameters"]["complianceCode"]["${direction}"]}
        List Should Contain Value    ${compliance_Code_list}      ${compliance_Code}
        Set Suite Variable   ${vendor}
        ...    ${links["notConnected"][${port}]["details"]["hardwareParameters"]["vendor"]["${direction}"]}
        ${pre}    Fetch From Left    ${vendor}    ${SPACE}${SPACE}
        List Should Contain Value    ${vendor_list}      ${pre}
        Set Suite Variable   ${vendorPartNumber}
        ...    ${links["notConnected"][${port}]["details"]["hardwareParameters"]["vendorPartNumber"]["${direction}"]}
        Should Not Be Equal    ${vendorPartNumber}    N/A
        Should not be empty    ${vendorPartNumber}
        Set Suite Variable   ${vendorRevision}
        ...    ${links["notConnected"][${port}]["details"]["hardwareParameters"]["vendorRevision"]["${direction}"]}
        Should Not Be Equal    ${vendorRevision}    N/A
        Should Not Be Empty    ${vendorRevision}
        Set Suite Variable   ${serialNumber}
        ...    ${links["notConnected"][${port}]["details"]["hardwareParameters"]["serialNumber"]["${direction}"]}
        Should Not Be Equal    ${serialNumber}    N/A
        Should Not Be Empty    ${serialNumber}
        Set Suite Variable    ${connectorType}
        ...    ${links["notConnected"][${port}]["details"]["hardwareParameters"]["connectorType"]["${direction}"]}
        Should Not Be Equal    ${connectorType}    N/A
        Should Not Be Empty    ${connectorType}
        ${physicalPort}    coam.Get Parameters        ${links["notConnected"][${port}]["${direction}"]}    physicalPort
        ...    timeout=20    connection=${connection}
        ${physicalPort}    Get From Dictionary    ${physicalPort}    physicalPort
        Should Not Be Equal    ${physicalPort}    N/A
        Should Not Be Empty    ${physicalPort}
        Set Suite Variable   ${waveLength}
        ...    ${links["notConnected"][${port}]["details"]["staticParameters"]["waveLength"]["${direction}"]}
        Should Not Be Equal    ${waveLength}    N/A
        Should Not Be Empty    ${waveLength}
        Set Suite Variable   ${transmissionRate}
        ...    ${links["notConnected"][${port}]["details"]["staticParameters"]["transmissionRate"]["${direction}"]}
        Should Not Be Equal    ${transmissionRate}    N/A
        Should Not Be Empty    ${transmissionRate}
    END

Check SFP Manufactury Date
   [Documentation]
    ...     This keyword check whether it argument is a valid date,
     ...    not older than 01.20.2021 and not newer than from last month
    [Arguments]    ${SFP_QSFP_Manufacturer_Date}
    ${man_year}=    Get Substring    ${SFP_QSFP_Manufacturer_Date}    0    2
    ${man_month}=    Get Substring    ${SFP_QSFP_Manufacturer_Date}    2    4
    ${man_day}=    Get Substring    ${SFP_QSFP_Manufacturer_Date}    4    6
    ${check_if_date_exist}=    Convert Date     20${man_year}${man_month}${man_day} 00:00:00    exclude_millis=True
    ${man_year}=    Convert To Integer    ${man_year}
    ${man_month}=    Convert To Integer    ${man_month}
    ${current_date}=    robot.libraries.DateTime.Get Current Date    result_format=datetime
    ${short_cyear}=    Evaluate    ${current_date.year}-2000
    Should Be True    14<${man_year}<=${short_cyear}
    Run Keyword If    ${man_year}==${short_cyear}    Should Be True    ${man_month}<=${current_date.month}

Calculate Send Tput And Expected Tput
    [Arguments]   ${peak_dl_tp}  ${peak_ul_tp}
    ${unit}  Get Substring  ${peak_dl_tp}  -1
    ${value}  Get Substring  ${peak_dl_tp}  0  -1
    ${value}  convert to number  ${value}
    ${dl_exp}  run keyword if  '${unit.upper()}'=='G'  evaluate  ${value}*1024
    ...                ELSE  evaluate  ${value}*1.0
    ${dl_tp}  evaluate  ${value}*1.25
    ${dl_tp}  set variable  ${dl_tp}${unit}
    ${unit}  Get Substring  ${peak_ul_tp}  -1
    ${value}  Get Substring  ${peak_ul_tp}  0  -1
    ${value}  convert to number  ${value}
    ${ul_exp}  run keyword if  '${unit.upper()}'=='G'  evaluate  ${value}*1024
    ...                ELSE  evaluate  ${value}*1.0
    ${ul_tp}  evaluate  ${value}*1.25
    ${ul_tp}  set variable  ${ul_tp}${unit}
    [Return]  ${dl_tp}  ${ul_tp}  ${dl_exp}  ${ul_exp}

Check fault history log
    [Arguments]  ${log_name}=ru_log  ${log_path}=${SAVE LOG DIRECTORY}
    Run  rm -rf ${log_path}/${log_name}
    Run  unzip ${log_path}/${log_name}.zip -d ${log_path}/${log_name}
    ${content}  get_binary_file  ${log_path}/${log_name}/1011_fault_history_log.txt
    ${content}  Convert To String    ${content}
    ${fault_value}    create list    EFaultId_Bus_LcvDecodingErrorCriticalForElectricalPorts (1288)    EFaultId_TX_RFIC_JESD_Error (1316)
    ...    FaultId_FB_RFIC_JESD_Error (1317)    EfaultId_RxBeamformingCalibrationFailed (1364)    EfaultId_TxBeamformingCalibrationFailed (1363)
    FOR    ${value}    IN    @{fault_value}
        should not contain    ${content}     ${value}
    END

Get Old RU RuntimeLog
    [Arguments]  ${log_name}=ru_log     ${timestamp}=${None}
    Run  unzip ${TS_CASE_LOG_PATH}/${log_name}/${ru_runtime_zip} -d ${TS_CASE_LOG_PATH}/${log_name}
    Run  unxz ${TS_CASE_LOG_PATH}/${log_name}/${ru_runtime_xz}

Get RU RuntimeLog
    [Arguments]  ${log_name}=ru_log     ${timestamp}=${None}
    Run  tar -zxvf ${TS_CASE_LOG_PATH}/${log_name}/${ru_runtime_tar} -C ${TS_CASE_LOG_PATH}/${log_name}
    ${log_list}    List Directory  ${TS_CASE_LOG_PATH}/${log_name}/var/log/
    ${log_length}    Get Length    ${log_list}
    FOR    ${log_id}    IN RANGE    ${log_length}-2    0    -1
        Run  zcat ${TS_CASE_LOG_PATH}/${log_name}/var/log/${log_list[${log_id}]} >> ${TS_CASE_LOG_PATH}/${log_name}/runtime_DEFAULT.log
    END
    Run  cat ${TS_CASE_LOG_PATH}/${log_name}/var/log/runtime.log >> ${TS_CASE_LOG_PATH}/${log_name}/runtime_DEFAULT.log
	
Get Last LED Timestamp and Status
    [Arguments]  ${log_name}=ru_log    ${timestamp}=${None}
    Run  rm -rf ${TS_CASE_LOG_PATH}/${log_name}
    Run  unzip ${TS_CASE_LOG_PATH}/${log_name}.zip -d ${TS_CASE_LOG_PATH}/${log_name}
    ${zip_exists}  Run Keyword And Return Status  File Should Exist  ${TS_CASE_LOG_PATH}/${log_name}/${ru_runtime_zip}
    Run Keyword If  ${zip_exists}  Get Old RU RuntimeLog  ${log_name}  ${timestamp}
    ${tar_exists}  Run Keyword And Return Status  File Should Exist  ${TS_CASE_LOG_PATH}/${log_name}/${ru_runtime_tar}
    Run Keyword If  ${tar_exists}  Get RU RuntimeLog  ${log_name}  ${timestamp}
    ${content}  get_binary_file  ${TS_CASE_LOG_PATH}/${log_name}/runtime_DEFAULT.log
    ${content}  Convert To String  ${content}
    ${new_content}  ${new_timestamp}  Cut Out Runtime Log  content=${content}  timestamp=${timestamp}
    ${matches}  Get Regexp Matches  ${new_content}  New status for led 0: Colors: (.+?) Priority:  1
    [Return]  ${matches}  ${new_timestamp}

Cut Out Runtime Log
    [Arguments]  ${content}  ${timestamp}=${None}
    ${content_list}  split to lines    ${content}
    ${timestamp_line}  run keyword if  '${timestamp}'=='${None}'  set variable  ${content_list[${-2}]}
    ${matches}    run keyword if  '${timestamp}'=='${None}'  Get Regexp Matches    ${timestamp_line}     <(.+?)>    1
    ${new_timestamp}  set variable if  '${timestamp}'=='${None}'   ${matches[0]}  ${timestamp}
    return from keyword if  '${timestamp}'=='${None}'  ${content}  ${new_timestamp}
    ${matches}  Get Regexp Matches  ${content}   ${new_timestamp}\[\\s\\S]*
    ${len}    get length    ${matches}
    ${content}  set variable if   ${len}>0   ${matches[0]}    ${content}
    [Return]  ${content}  ${new_timestamp}

RU Should Be Reset
    [Arguments]    ${start_server_time}    ${end_server_time}    ${uptime}
    ${end_server_time}    Replace String    ${end_server_time}   \r\n    ${EMPTY}
    ${start_server_time}    Replace String    ${start_server_time}   \r\n    ${EMPTY}
    ${reset_recovery_time}    Subtract Time From Time    ${end_server_time}    ${start_server_time}
    ${reset_recovery_time}    Convert Time    ${reset_recovery_time}
    ${uptime}    Convert Time    ${uptime}
    should be true    ${uptime}<=${reset_recovery_time}

Get SFP Detail Info
    [Arguments]    ${link_info}
    ${detail}    set variable    ${link_info['details']}
    ${linkPorts}    set variable    ${link_info['data']['linkPorts']}
    ${directions}    Get Dictionary keys    ${linkPorts}
    FOR    ${direction}    IN    @{directions}
        ${linkport}    Get From Dictionary    ${linkPorts}    ${direction}
        ${Physical_port}    set variable    ${detail['hardwareParameters']['physicalPort']['${direction}']}
        ${Vendor}    set variable    ${detail['hardwareParameters']['vendor']['${direction}']}
        Should Not Be Equal    ${Vendor}    -    AND    Should not be empty    ${Vendor}
        ${Serial_number}    set variable    ${detail['hardwareParameters']['serialNumber']['${direction}']}
        Should Not Be Equal    ${Serial_number}    -    AND    Should not be empty    ${Serial_number}
        ${Wave_length}    set variable     ${detail['staticParameters']['waveLength']['${direction}']}
        Should Not Be Equal    ${Wave_length}    -    AND    Should not be empty    ${Wave_length}
        ${Nominal_transmission_rate}    set variable    ${detail['staticParameters']['transmissionRate']['${direction}']}
        Should Not Be Equal    ${Nominal_transmission_rate}    -    AND    Should not be empty    ${Nominal_transmission_rate}
        ${Tx_power_high_alarm_threshold}    set variable    ${detail['thresholds']['txPowerHighAlarmThreshold']['${direction}']}
        Should Not Be Equal    ${Tx_power_high_alarm_threshold}    -    AND    Should not be empty    ${Tx_power_high_alarm_threshold}
        ${Tx_power_low_alarm_threshold}    set variable    ${detail['thresholds']['txPowerLowAlarmThreshold']['${direction}']}
        Should Not Be Equal    ${Tx_power_low_alarm_threshold}    -    AND    Should not be empty    ${Tx_power_low_alarm_threshold}
        ${Tx_power_high_warning_threshold}    set variable    ${detail['thresholds']['txPowerHighWarnThreshold']['${direction}']}
        Should Not Be Equal    ${Tx_power_high_warning_threshold}    -    AND    Should not be empty    ${Tx_power_high_warning_threshold}
        ${Tx_power_low_warning_threshold}    set variable    ${detail['thresholds']['txPowerLowWarnThreshold']['${direction}']}
        Should Not Be Equal    ${Tx_power_low_warning_threshold}    -    AND    Should not be empty    ${Tx_power_low_warning_threshold}
        ${Rx_power_high_alarm_threshold}    set variable    ${detail['thresholds']['rxPowerHighAlarmThreshold']['${direction}']}
        Should Not Be Equal    ${Rx_power_high_alarm_threshold}    -    AND    Should not be empty    ${Rx_power_high_alarm_threshold}
        ${Rx_power_low_alarm_threshold}    set variable    ${detail['thresholds']['rxPowerLowAlarmThreshold']['${direction}']}
        Should Not Be Equal    ${Rx_power_low_alarm_threshold}    -    AND    Should not be empty    ${Rx_power_low_alarm_threshold}
        ${Rx_power_high_warning_threshold}    set variable    ${detail['thresholds']['rxPowerLowAlarmThreshold']['${direction}']}
        Should Not Be Equal    ${Rx_power_high_warning_threshold}    -    AND    Should not be empty    ${Rx_power_high_warning_threshold}
        ${Rx_power_low_warning_threshold}    set variable    ${detail['thresholds']['rxPowerLowWarnThreshold']['${direction}']}
        Should Not Be Equal    ${Rx_power_low_warning_threshold}    -    AND    Should not be empty    ${Rx_power_low_warning_threshold}
        ${Temperature_high_alarm_threshold}    set variable    ${detail['thresholds']['temperatureHighAlarmThreshold']['${direction}']}
        Should Not Be Equal    ${Temperature_high_alarm_threshold}    -    AND    Should not be empty    ${Temperature_high_alarm_threshold}
        ${Temperature_low_alarm_threshold}    set variable    ${detail['thresholds']['temperatureLowAlarmThreshold']['${direction}']}
        Should Not Be Equal    ${Temperature_low_alarm_threshold}    -    AND    Should not be empty    ${Temperature_low_alarm_threshold}
        ${Max_transmission_distance}    Get Max Transmission Distance
        ...    maxTransmissionDistanceList=${detail['staticParameters']['maxTransmissionDistanceList']}    direction=${direction}
    END

Get Max Transmission Distance
    [Arguments]    ${maxTransmissionDistanceList}    ${direction}
    &{Max_transmission_distance}    Create Dictionary
    FOR    ${item}    IN    @{maxTransmissionDistanceList}
        ${maxLinkLengthType}    Get From Dictionary     ${item['${direction}MaxLinkLength']}    maxLinkLengthType
        ${maxLinkLength}    Get From Dictionary     ${item['${direction}MaxLinkLength']}    maxLinkLength
        Should not be empty    ${maxLinkLength}
        Set To Dictionary    ${Max_transmission_distance}    ${maxLinkLengthType}    ${maxLinkLength}
    END
    [Return]    ${Max_transmission_distance}

check LED list
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE]check LED list
    ...    Author: zhenzhen.ren@nokia-sbell.com
    ...    *****************
    [Arguments]  ${matches}    ${led_status_list}    ${exclude_led_status}=GREEN GREEN
    ${new_led_status_list}  create list  ${matches[0]}
    ${len}  get length  ${matches}
    FOR  ${i}  IN RANGE  1  ${len}
        run keyword if  '${matches[${i}]}'!='${matches[${i}-1]}'  append to list  ${new_led_status_list}  ${matches[${i}]}
    END
    run keyword if  '${new_led_status_list[0]}'=='${exclude_led_status}' and ${len}>1    remove from list  ${new_led_status_list}  0
    lists should be equal  ${led_status_list}  ${new_led_status_list}

Get actMicroDTX modify parameters list
    [Arguments]  ${cell_id_list}    ${new_value}=true
    ${modify_params}  create list
    FOR  ${cell_id}  IN  @{cell_id_list}
        ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/LNBTS-${NRBTS_ID}/LNCEL-${cell_id}
        ...    filter_param=Activate eNode B power saving - Micro DTX    p_name=actMicroDTX    value=${new_value}
        append to list  ${modify_params}  ${item}
    END
    [Return]  ${modify_params}

Get Trafficconcentration modify parameters list
    [Arguments]  ${cell_id_list}    ${new_value}=true
    ${modify_params}  create list
    FOR  ${cell_id}  IN  @{cell_id_list}
        ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/LNBTS-${NRBTS_ID}/LNCEL-${cell_id}
        ...    filter_param=Allow traffic concentration    p_name=allowTrafficConcentration    value=${new_value}
        append to list  ${modify_params}  ${item}
    END
    [Return]  ${modify_params}

Get CPRI offest modify parameters list
    [Arguments]  ${cell_id_list}    ${cpri_offset}=true    ${frameStartOffset}=${3000}    ${sfnOffset}=${0}    ${cell_type}=nr
    log to console  \n change to cpri_offset:${cpri_offset};frameStartOffset:${frameStartOffset};sfnOffset:${sfnOffset}
    ${modify_params}    create list
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Activate CPRI-N cell timing offset    p_name=actCellTimingOffsetCpriN    value=${cpri_offset}
    append to list  ${modify_params}  ${item}
    FOR  ${cell_id}  IN  @{cell_id_list}
        ${dist_name}    Set Variable If    '${cell_type}'=='nr'    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...     MRBTS-${MRBTS_ID}/LNBTS-${NRBTS_ID}/LNCEL-${cell_id}
        ${item}  create dictionary  dist_name=${dist_name}
        ...    filter_param=Frame start offset    p_name=frameStartOffset    value=${frameStartOffset}
        append to list  ${modify_params}  ${item}
        ${item}  create dictionary  dist_name=${dist_name}
        ...    filter_param=SFN offset    p_name=sfnOffset    value=${sfnOffset}
        append to list  ${modify_params}  ${item}
    END
    [Return]  ${modify_params}

Get frame start offest modify parameters list
    [Arguments]  ${cell_id_list}    ${frameStartOffset}=${3000}    ${cell_type}=nr
    log to console  \n change frameStartOffset value to ${frameStartOffset}
    ${modify_params}  create list
    FOR  ${cell_id}  IN  @{cell_id_list}
        ${dist_name}    Set Variable If    '${cell_type}'=='nr'    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...     MRBTS-${MRBTS_ID}/LNBTS-${NRBTS_ID}/LNCEL-${cell_id}
        ${item}  create dictionary  dist_name=${dist_name}
        ...    filter_param=Frame start offset    p_name=frameStartOffset    value=${frameStartOffset}
        append to list  ${modify_params}  ${item}
    END
    [Return]  ${modify_params}

Get beamSet Parameters modify parameters list
    [Arguments]  ${actBeamforming}    ${basicBeamSet}    ${numberOfTransmittedSsBlocks}
    log to console  Get beamSet Parameters modify parameters list
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=Activate Beamforming  p_name=actBeamforming  value=${actBeamforming}
    append to list  ${modify_params}  ${item}
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=Basic Beam Set  p_name=basicBeamSet  value=${basicBeamSet}
    append to list  ${modify_params}  ${item}
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-0
    ...    filter_param=Number of transmitted Synchronization Signal Blocks  p_name=numberOfTransmittedSsBlocks  value=${numberOfTransmittedSsBlocks}
    append to list  ${modify_params}  ${item}
    [Return]  ${modify_params}

Check SBTS Ping Enable
    [Arguments]  ${bts_host}=${sbts_addr}    ${times}=5
    ${output}   Run    sudo ping -c ${times} -W 10 ${bts_host}
    Should Contain    ${output}    ${times} packets transmitted, ${times} received, 0% packet loss

Check SBTS Ping Disable
    [Arguments]  ${bts_host}=${sbts_addr}    ${times}=5
    ${output}   Run    sudo ping -c ${times} -W 10 ${bts_host}
    Should Contain    ${output}    ${times} packets transmitted, 0 received, 100% packet loss

Unzip And Check RF Scan File
    [Arguments]  ${rfscan_dir_path}=${SUITE_LOGS_DIR_PATH}  ${rfscan_filename}=rfscan.zip   ${files_count}=14
    [Documentation]    *****************
    ...    This keyword is used to retrieve the RF scan test file from the vDU and check its contents.
    ...    - [Keyword Details]
    ...    This keyword accepts the Antenna runtime managed object dist names, RF scan directory path, and RF scan filename as arguments.
    ...    It retrieves the RF scan test file and unzips it. It then checks the number of .rfcap and .xml files in the unzipped directory.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | ants_runtime_dns | Yes | The Antenna runtime managed object dist names. |
    ...    | rfscan_dir_path | No | The RF scan directory path. Default is suite logs directory path. |
    ...    | rfscan_filename | No | The RF scan filename. Default is 'rfscan.zip'. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 04.06.2024 - - Created
    ...    *******************
    ...    * Owner: kaihui.fan@nokia-sbell.com
    ...    * Group: VRF_HAZ4_04

    ${unzip_result}=  Run and Return Rc  command=unzip -o '${rfscan_dir_path}/${rfscan_filename}.zip' -d '${rfscan_dir_path}/${rfscan_filename}'
    Run Keyword If  ${unzip_result}!=0
    ...  Fail  Cannot unzip file ${rfscan_filename}.zip !!!
    log to console  \nFile ${rfscan_filename}.zip has been unziped successfully
    Check RF Scan File Count  rfscan_dir_path=${rfscan_dir_path}/${rfscan_filename}  files_count=${files_count}
    Log to Console  \nNumber of .rfcap and .xml files is correct
    Run  command=rm -fr ${rfscan_dir_path}/${rfscan_filename}


Check RF Scan File Count
    [Arguments]  ${rfscan_dir_path}  ${files_count}
    [Documentation]    *****************
    ...    This keyword is used to check the RF scan test file from the vDU.
    ...    - [Keyword Details]
    ...    This keyword accepts the RF scan directory path and the number of files as arguments.
    ...    It counts the number of .rfcap and .xml files in the directory and checks if they match the expected count.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | rfscan_dir_path | Yes | The RF scan directory path. |
    ...    | files_count | Yes | The expected number of .rfcap files. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 04.06.2024 - - Created
    ...    *******************
    ...    * Owner: kaihui.fan@nokia-sbell.com
    ...    * Group: VRF_HAZ4_04

    ${rfcap_files_count}=  Count Files In Directory  path=${rfscan_dir_path}  pattern=*.rfcap
    Should Be Equal As Integers  first=${rfcap_files_count}  second=${files_count}
    ...  msg=Number of .rfcap files doesn't meet conditions !!!
    ${xml_files_count}=  Count Files In Directory  path=${rfscan_dir_path}  pattern=*.xml
    Should Be Equal As Integers  first=${xml_files_count}  second=1
    ...  msg=Number of .xml files doesn't meet conditions !!!
