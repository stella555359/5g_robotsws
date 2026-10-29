*** Settings ***
# https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=5GFTPARIS&title=ET+Coding+Rules
#
# --------------------------------------------------------------------------------------------------------------------------------------------------
Documentation     [SUITE PURPOSE]   CB012738-A Common Keywords
...               Scope : Common keywords for CB012738-A sub-features
#
...               Test Case Scenario author : vincent.boulet@nokia.com
...               Creation Date             : 2025-02-10
...               Modified Date             : 2026-03-04
#
#                 Version    Date       Author                          Notes
#                 0.1        FB2503     vincent.boulet@nokia.com        Creation robot
#                 0.2        FB2518     vincent.boulet@nokia.com        Set n_handover=30 instead of 100
#                 0.3        FB2601     vincent.boulet@nokia.com        ulFdSchedData.pdcchPowerBoostType no more decoded with mcshark DLL
#                 0.4        FB2605     vincent.boulet@nokia.com        Add with_auto_configured_parameters=${True} in Oam.OAM Get SCF File
# --------------------------------------------------------------------------------------------------------------------------------------------------

# Libraries
Library                               OperatingSystem
Library                               ../../../../../resources/SWENG/python/Archi.py
#OBSOLETE#Library                     taf.sbts.oam.coam.admin       WITH NAME    coam    # already defined into SWENG robot/Oam.robot
Library                               taf.wts.runner                WITH NAME    wtsemu
#OBSOLETE# Both following python libraries can be included only to use directly pyhton methods instead of robot resources as wrappers
#OBSOLETE#Library                     ../../../../../resources/SWENG/python/TtiTrace/tti_extractor.py    WITH NAME    TtiExtractor
#OBSOLETE#Library                     ../../../../../resources/SWENG/python/TtiTrace/TtiAnalysis.py    ${path_to_json}

# Resources
Resource                              ../../../resources/common/TtiTrace/ttitrace.robot
Resource                              ../../../../../resources/SWENG/robot/Container.robot
Resource                              ../../../../../resources/SWENG/robot/GenericTest.robot
Resource                              ../../../../../resources/SWENG/robot/GnbXmlTools.robot
Resource                              ../../../../../resources/SWENG/robot/KPIs.robot
Resource                              ../../../../../resources/SWENG/robot/PacketSearch.robot
Resource                              ../../../../../resources/SWENG/robot/Scf.robot
Resource                              ../../../../../resources/SWENG/robot/Syslogs.robot
Resource                              ../../../../../resources/SWENG/robot/Tools.robot
Resource                              ../../../../../resources/SWENG/robot/Topology.robot
Resource                              ../../../../../resources/SWENG/robot/Traffic.robot
Resource                              ../../../../../resources/SWENG/robot/WtsCfgConfig.robot
Resource                              ../../../../../resources/SWENG/robot/WtsXmlConfig.robot
# Following resources are defined to access wrappers for TTI Analysis and Convert interfaces
Resource                              ../../../../../resources/SWENG/robot/TtiConvertInterface.robot
Resource                              ../../../../../resources/SWENG/robot/TtiAnalysisInterface.robot
#OBSOLETE#Resource                    ../../../../../resources/SWENG/robot/TtiMultiAnalysisInterface.robot
#
Resource                              ./CB012738-Commissioning.robot

*** Variables ***
${TestSharkTool}                      MC_SHARK
${AUTO_SAVE_DEBUG_DATA}               ${True}
${CALL_ENABLED}                       ${True}
#USELESS#${SUITE_DEBUG_MODE}          ${True}
@{protocol_exclusion}                 ARP    UDP   ICMP   #PB_DETECTED_241129#TCP
${path_to_json}                       /tmp/TTI_traces.json    # internal usage for decoding TTI pcap
# --------------------------------------------------------------------------------------------------------------------------------------------------
*** Keywords ***
# Suite #
Suite Setup Common Private
    [Arguments]             ${keep_all_data_in_file}=${False}

    Dated Log New Line                ----Suite Setup Common Private----
    ${timestamp_suite_setup}=         DateTime.Get Current Date    result_format=%Y%m%d-%H%M%S
    Set Suite Variable                ${timestamp_suite_setup}
    Setup.Suite Setup From Scratch    automaticTeardown=${True}    keepAllUeDataInCfgFile=${keep_all_data_in_file}
    Backup.Backup Files
    ${scf_suite_setup_backup}=        Oam.OAM Get SCF File    file=SCF_DU_Backup.xml    with_auto_configured_parameters=${True}
    Set Suite Variable                ${scf_suite_setup_backup}
    Dated Log                         > DU backup file is ${scf_suite_setup_backup}
    ${scf_vcu_suite_setup_backup}=    Run Keyword If    ${isAic}    Oam.OAM Get Cu SCF File    file=SCF_CU_Backup.xml
    Run Keyword If    ${isAic}        Run Keywords    Set Suite Variable    ${scf_vcu_suite_setup_backup}
    ...    AND    Dated Log           > CU backup file is ${scf_vcu_suite_setup_backup}
    Dated Log New Line                ----------------------------------


Test Teardown Common Private
    [Arguments]             ${is_snapshot}=${False}

    Dated Log New Line                ----Test Teardown Common Private----
    GenericTest.Display diagnosis
    Dated Log New Line                ----Produce Scout Data----
    Produce Scout Data
    Dated Log New Line                ----Restore And Clean environment----
    Save and Clear Egate Console Log    pattern=TestTeardown
    Restore Files
    Run Keyword If    ${AUTO_SAVE_DEBUG_DATA}    Run Keywords    Run    command=cp -f /opt/wts/latest/egate_console.log ${LOG_PATH}
    ...    AND    Dated Log           > Save the egate_console.log because AUTO_SAVE_DEBUG_DATA mode is set
    # Saving snapshots for debugging if AUTO_SAVE_DEBUG_DATA mode is set
    Dated Log                         > Get snapshot just if requested and not already generated after failure...
    ${snapshot_path}=                 Set Variable    ${LOG_PATH}/SNAPSHOT_GNB*.zip
    ${status}   ${ret}   Run Keyword And Ignore Error    OperatingSystem.File Should Exist    ${snapshot_path}
    Run Keyword If   "${status}" == "PASS"
    ...    Dated Log                  > ${snapshot_path} is already present
    ...         ELSE IF    ${AUTO_SAVE_DEBUG_DATA} and ${is_snapshot}    Setup.Get Snapshot
    #
    Run                               command=cp /opt/wts/latest/basic_*.modified.cfg ${LOG_PATH}
    # Restoring backups scf
    ${scf_suite_teardown_restore}=    Get Variable Value    ${scf_suite_setup_backup}    None
    ${scf_vcu_suite_teardown_restore}=    Run Keyword If    ${isAic}    Get Variable Value    ${scf_vcu_suite_setup_backup}    None
    Run Keyword If    ${isAic}        Oam.OAM Perform Full Commissioning    scf_file=${scf_vcu_suite_teardown_restore}    oam=${GNB_CU.oam}
    Oam.OAM Perform Full Commissioning    scf_file=${scf_suite_teardown_restore}    oam=${GNB_DU.oam}
    Run Keyword If    ${isAic}        Restart.Wait Airphone Available
    ...         ELSE                  Oam.OAM wait available
    # Cleaning-up debugging files if AUTO_SAVE_DEBUG_DATA mode is not set
    Run                               command=rm -f ${LOG_PATH}/L1L2/*.pdml
    Dated Log                         > Remove the generated pdml files
    Run                               command=rm -f ${LOG_PATH}/L1L2/*.__*.pcap
    Dated Log                         > Remove the intermediate pcap files
    Run                               command=rm -f ${LOG_PATH}/TTITraces/*.json
    Dated Log                         > Remove the TTI json files
    Run Keyword If    not ${AUTO_SAVE_DEBUG_DATA} and ${isAic}    Run Keywords    Run    command=rm -f ${scf_vcu_suite_setup_backup}
    ...    AND    Dated Log           > Remove the scf_vcu_suite_setup_backup because AUTO_SAVE_DEBUG_DATA mode is not set
    Run                               command=rm -f ${LOG_PATH}/SCF.xml
    ${timestamp_suite_teardown}=      DateTime.Get Current Date    result_format=%Y%m%d-%H%M%S
    Set Suite Variable                ${timestamp_suite_teardown}
    Dated Log New Line                ---------------------------------------------
    Dated Log                         > RUNTIME: ${timestamp_suite_setup} -> ${timestamp_suite_teardown}
    Dated Log New Line                ---------------------------------------------
    Run                               command=mv ${LOG_PATH} ${OUTPUT_DIR}/Logs/Results
    Run keyword if    "${TEST_STATUS}" == "FAIL"    Test Teardown if Fail
# --------------------------------------------------------------------------------------------------------------------------------------------------
# RAD Parameters #
Set RAD Parameters Common Private
    [Arguments]             ${rad_0x58046F_val}=${None}

    @{list_rad_param}=                Create List
    #
    #L2PS#rdStaticPdcchPowerOffset#disabled#
    &{rad_0x58046F}=    Run Keyword If    ${rad_0x58046F_val} != ${None}    Create Dictionary    field=0x58046f    value=${rad_0x58046F_val}
    Run Keyword If    ${rad_0x58046F_val} != ${None}    Append To List    ${list_rad_param}    ${rad_0x58046F}
    #
    ${length_list_rad_param}=         Get Length    ${list_rad_param}
    Dated Log                         > RAD params list is ${list_rad_param} with length= ${length_list_rad_param}
    Run Keyword If    ${length_list_rad_param} > 0    SetConfig.Set Fields in swconfig DU    param_list=${list_rad_param}
# --------------------------------------------------------------------------------------------------------------------------------------------------
# basic_setup #
Configure Parameter In WTS basic_setup File
    [Arguments]             ${identifier}
    ...                     ${param}
    ...                     ${value}

    Dated Log New Line                ----Configure Parameter In WTS basic_setup File----
    WtsCfgConfig.startSession
    ${default_value}=                 getParam    prefix=${identifier}    param=${param}
    Dated Log                         > default value for ${identifier}: ${param}= ${default_value}
    replaceValue                      prefix=${identifier}    param=${param}    oldValue=${default_value}    newValue=${value}
    Dated Log                         > new value updated for ${identifier} for ${param} is ${value}
    WtsCfgConfig.stopSession          rename=modified


#iphy#
Configure Parameter In AP iphy File
    [Arguments]             ${identifier}
    ...                     ${param}
    ...                     ${value}

    Dated Log New Line                ----Configure Parameter In AP iphy File----
    WtsXmlConfig.startSession         file=iphy
    WtsXmlConfig.setTextUsingIndex    path=//${param}    val=${value}    idx=${identifier}
    Dated Log                         > new value updated for ${param} idx= ${identifier} is ${value}
    WtsXmlConfig.stopSession          file=iphy
# --------------------------------------------------------------------------------------------------------------------------------------------------
# UE
Display List UEs Settings
    [Arguments]             ${list_elem}

    Dated Log New Line                ----Display List UEs Settings----
    FOR    ${current_elem}    IN    @{list_elem}
        Dated Log    ue= ${current_elem}[ue], call= ${current_elem}[call_type], rnti=${current_elem}[c_rnti], cell=${current_elem}[target_cells]
    END


Get List UEs Settings
    [Arguments]             ${param}
    ...                     ${dict_settings}

    Dated Log New Line                ----Get List UEs Settings----
    @{list_ue}=                       Create List
    @{cell_id_streaming}=             Create List
    FOR    ${current_id}    IN RANGE    0    ${param.total_nb_ue}
        ${current_call_type}=         Set Variable    ${dict_settings[${current_id}].call_type}
        ${current_ue_id}=             Set Variable    ${dict_settings[${current_id}].ue_id}
        ${current_ue_setting}=    Run Keyword If    "${current_call_type}" == "SA"    Copy Dictionary     ${BASIC_UE_SA}
        ...                                   ELSE    Copy Dictionary     ${UE_SIMPLE}
        Set To Dictionary             ${current_ue_setting}    ue                       ${current_ue_id}
        Set To Dictionary             ${current_ue_setting}    trf_id                   1
        Run Keyword If    "${current_call_type}" == "SA"
        ...    Set To Dictionary      ${current_ue_setting}    pdu                      1
        Run Keyword If    "${current_call_type}" == "NSA"
        ...    Set To Dictionary      ${current_ue_setting}    bearer                   2
        Set To Dictionary             ${current_ue_setting}    target_gnb               ${param.target_gnb}
        # Dispatching the ue on the requested original cell for the call establishment
        Set To Dictionary             ${current_ue_setting}    target_cells             ${dict_settings[${current_id}].original_cell}
        ${nb_values}=                 Count Values In List    ${cell_id_streaming}    ${current_ue_setting.target_cells}
        Run Keyword If    ${nb_values} == 0    Append To List    ${cell_id_streaming}     ${current_ue_setting.target_cells}
        # Set the correct requested throughput per ue
        Set To Dictionary             ${current_ue_setting}    throughput               ${dict_settings[${current_id}].throughput}
        Set To Dictionary             ${current_ue_setting}    throughput_ul            ${dict_settings[${current_id}].throughput_ul}
        Set To Dictionary             ${current_ue_setting}    call_type                ${current_call_type}
        Set To Dictionary             ${current_ue_setting}    paging                   ${dict_settings[${current_id}].paging}
        ${k_csi_override_cqi}=        Is Parameter A Dictionary Key    dict=${dict_settings[${current_id}]}    parameter=csi_override_cqi
        Run Keyword If    "${param.csi_override_cqi}" != "${None}" and ${k_csi_override_cqi}
        ...    Set To Dictionary    ${current_ue_setting}    csi_override_cqi    ${dict_settings[${current_id}].csi_override_cqi}
        ${k_ue_measurement_nr}=       Is Parameter A Dictionary Key    dict=${dict_settings[${current_id}]}    parameter=ue_measurement_nr
        Run Keyword If    "${param.ue_measurement_nr}" != "${None}" and ${k_ue_measurement_nr}
        ...    Set To Dictionary    ${current_ue_setting}    ue_measurement_nr    ${dict_settings[${current_id}].ue_measurement_nr}
        ${k_target_handover}=         Is Parameter A Dictionary Key    dict=${dict_settings[${current_id}]}    parameter=target_handover
        Run Keyword If    "${param.ue_measurement_nr}" != "${None}" and ${k_target_handover}
        ...    Set To Dictionary    ${current_ue_setting}    target_handover    ${dict_settings[${current_id}].target_handover}
        Append To List                ${list_ue}    ${current_ue_setting}
        ${nb_values}=    Run Keyword If    "${param.ue_measurement_nr}" != "${None}" and ${k_target_handover}    Count Values In List
        ...                                                         ${cell_id_streaming}    ${current_ue_setting.target_handover}
        ...                          ELSE    Set Variable    1
        Run Keyword If    ${nb_values} == 0    Append To List    ${cell_id_streaming}     ${current_ue_setting.target_handover}
    END
    #DEBUG_LOG#Dated Log              >> UE's list is ${list_ue}
    #DEBUG_LOG#Dated Log              >> Cells list for TTI streaming is ${cell_id_streaming}
    [Return]                          ${list_ue}    ${cell_id_streaming}


Set CRNTI Into UEs Settings
    [Arguments]             ${list_ue}
    ...                     ${list_crnti}

    Dated Log New Line                ----Set CRNTI Into UEs Settings----
    ${nb_crnti}=                      Get Length    ${list_crnti}
    FOR    ${iteration_crnti}    IN RANGE    0    ${nb_crnti}
        Set To Dictionary             ${list_ue[${iteration_crnti}]}    c_rnti    ${list_crnti[${iteration_crnti}]}
    END
# --------------------------------------------------------------------------------------------------------------------------------------------------
# Captures #
Captures Init
    Dated Log New Line                ----Captures Init----
    ${capture_l1l2}=                  Capture L1L2 Set Upon Config    airscale=${GNB_DU}
    ${capture_l1l2.filter}=           Get Filter To Exclude protocols    capture=${capture_l1l2}    protocolList=${protocol_exclusion}
    ${capture_core}=                  Capture CORE Set Upon Config    airscale=${GNB_DU}
    ${capture_cprt}=                  Capture CPRT Set Upon Config    airscale=${GNB_DU}
    Capture Init                      ${capture_l1l2}    #withTN=True
    Capture Init                      ${capture_core}    #withTN=True
    Capture Init                      ${capture_cprt}    #withTN=True
    Set Suite Variable                ${capture_l1l2}
    Set Suite Variable                ${capture_core}
    Set Suite Variable                ${capture_cprt}


# L1L2 #
# L1L2 pcap and pdml data analysis functions #
CB012738 Create Filter Message List
    Dated Log New Line                ----CB012738 Create Filter Message List----
    #&{dict_filter_1}=   Create Dictionary    filter_name=__dldata_csirssendreq    request_pdml=${False}   message_filter=dldata_csirssendreq
    &{dict_filter_2}=    Create Dictionary    filter_name=__dldata_pdcchsendreq    request_pdml=${True}    message_filter=dldata_pdcchsendreql1sw
    #&{dict_filter_3}=   Create Dictionary    filter_name=__dldata_pdschsendreq    request_pdml=${False}   message_filter=dldata_pdschsendreq
    #&{dict_filter_4}=   Create Dictionary    filter_name=__uldata_prachrecvreq    request_pdml=${False}   message_filter=uldata_prachreceivereq
    #&{dict_filter_5}=   Create Dictionary    filter_name=__uldata_pucchrecvreq    request_pdml=${False}   message_filter=uldata_pucchreceivereq
    #&{dict_filter_6}=   Create Dictionary    filter_name=__uldata_puschrecvreq    request_pdml=${False}   message_filter=uldata_puschreceivereq
    #&{dict_filter_7}=   Create Dictionary    filter_name=__uldata_srsrecvreq      request_pdml=${False}   message_filter=uldata_srsreceivereq
    #&{dict_filter_8}=   Create Dictionary    filter_name=__uldata_puXchrecvreq    request_pdml=${False}
    #...    message_filter=uldata_pucchreceivereq or uldata_puschreceivereq
    #&{dict_filter_9}=   Create Dictionary    filter_name=__ul_dl_rach_msg         request_pdml=${False}
    #...    message_filter=DlData_PdschGrant.rachStatus>=1 or DlData_DciInfo.rachStatus>=1 or UlData_puschReceiveReqGrant_t.rachStatus>=1
    #&{dict_no_filter}=  Create Dictionary    filter_name=_no_filter               request_pdml=${False}   message_filter=${EMPTY}

    # list of messages for filtering
    @{list_filters_messages}=         Create List    ${dict_filter_2}
    [Return]                          ${list_filters_messages}


CB012738 Create Filter Message List Per CRNTI
    [Arguments]             ${list_elem}    # List of dictionaries

    Dated Log New Line                ----CB012738 Create Filter Message List Per CRNTI----
    @{list_filters_messages}=         Create List
    FOR    ${current_elem}    IN    @{list_elem}
        &{dict_filter}=               Create Dictionary    c_rnti=${current_elem.c_rnti}
        ...                                                         message_filter=3gpp.rnti==${current_elem.c_rnti}
        ...                                                         filter_name=_ue_${current_elem.ue}_crnti_${current_elem.c_rnti}
        ...                                                         request_pdml=${False}
        Append To List    ${list_filters_messages}    ${dict_filter}
    END
    [Return]                          ${list_filters_messages}


CB012738 Analyze pcap and pdml
    [Arguments]             ${pcap_file}
    ...                     ${list_message}    # List of dictionaries

    #DEBUG_LOG#Dated Log              ----CB012738 Analyze pcap and pdml of ${pcap_file}----
    FOR    ${current_elem}    IN    @{list_message}
        ${pcap_file_filtered}=    Run Keyword If    "${pcap_file}" != "${None}"
        ...                           analyzer.filter_pcap    pcapInFile=${pcap_file}
        ...                                                         filterName=${current_elem}[filter_name]
        ...                                                         filterExp=${current_elem}[message_filter]
        ...                           ELSE    Set Variable    ${None}
        Set To Dictionary             ${current_elem}    pcap_file_filtered    ${pcap_file_filtered}
        ${pdml_file_result}=    Run Keyword If    "${pcap_file_filtered}" != "${None}" and ${current_elem}[request_pdml] == ${True}
        ...                           analyzer.pcap_to_pdml    ${pcap_file_filtered}
        ...                           ELSE    Set Variable    ${None}
        Set To Dictionary             ${current_elem}    pdml_file_result    ${pdml_file_result}
    END
    Run Keyword If    "${pcap_file}" != "${None}"
    ...    Dated Log                  > list of messages AFTER filtering: ${list_message}


Post Processing L1L2 Traces
    [Arguments]             ${pcap_file}
    ...                     ${list_crnti_filters}
    ...                     ${list_messages_filters}

    Dated Log New Line                ----Post Processing L1L2 Traces----
    Dated Log                         >> list_crnti_filters= ${list_crnti_filters}
    FOR    ${current_elem}    IN    @{list_crnti_filters}
        ${pcap_file_filtered}=    Run Keyword If    "${current_elem}[c_rnti]" != "${None}"
        ...                           analyzer.filter_pcap    pcapInFile=${pcap_file}
        ...                                                         filterName=${current_elem}[filter_name]
        ...                                                         filterExp=${current_elem}[message_filter]
        ...                           ELSE    Set Variable    ${None}
        Set To Dictionary             ${current_elem}    pcap_crnti_filtered    ${pcap_file_filtered}
        Run Keyword If    "${current_elem}[pcap_crnti_filtered]" != "${None}"    Run Keywords
        ...    Dated Log              > filtering with ${current_elem}[message_filter]
        ...    AND                    CB012738 Analyze pcap and pdml    pcap_file=${current_elem}[pcap_crnti_filtered]
        ...                                                         list_message=${list_messages_filters}
    END
# --------------------------------------------------------------------------------------------------------------------------------------------------
# TTI #
Start TTI Logs Common
    [Arguments]             ${cell_id_list}

    Dated Log New Line                ----Start TTI Logs----
    ${TTIdir}=                        Get TTI Trace Path
    Run Keyword If    ${isAic}        ttitrace.Start TTI Traces in Streaming mode    src_ip=10.0.1.2    nrcell_id_list_aic=${cell_id_list}
    ...         ELSE                  ttitrace.Start TTI Traces in Streaming mode    src_ip=10.0.1.2    cell_distid=${cell_id_list}
    Set Suite Variable                ${TTIdir}


Stop and Get TTI Logs Common
    [Arguments]             ${trace_name}=TTI

    Dated Log New Line                ----Stop TTI Logs----
    ${TTIpcap}=                       ttitrace.Stop TTI Traces in Streaming mode    tti_trace_path=${TTIdir}    tti_trace_filename=${trace_name}
    #OBSOLETE#Dated Log                         > Convert TTI to json and csv is started
    #OBSOLETE#${TTIjson}=                       ttitrace.Convert TTI trace from pcap to others    input_file_path=${TTIpcap}
    #OBSOLETE#${TTIcsv}=                        decode_tti_traces_json_using_TtitraceReaderEvtDec    jsonPathName=${TTIjson}    num_of_events=200000
    #OBSOLETE#Set Suite Variable                ${TTIjson}
    #OBSOLETE#[Return]                          ${TTIjson}


Get List Cells Retained For TTI Streaming
    [Arguments]             ${cell_id_streaming}
    ...                     ${oam_type}=${GNB_DU.oam}

    Dated Log New Line                ----Get List Cells Retained For TTI Streaming----
    @{list_cell_id}=                  Create List
    @{cellsNr}=                       Oam.OAM Get Cells Nr    oam=${oam_type}
    #DEBUG_LOG#Dated Log              >> CellsNr=@{cellsNr}
    FOR    ${current_cell}    IN    @{cellsNr}
        #DEBUG_LOG#Dated Log          >> cell NR is ${current_cell}
        #DEBUG_LOG#Dated Log          >> internal distname ${current_cell['id']['internal']}
        ${cell_status_}=              Set variable  ${current_cell['status']}
        ${operationalState}=          Set Variable   ${cell_status_['operationalState']}
        #DEBUG_LOG#Dated Log          >> operationalState for DN [${current_cell['id']['internal']}] is ${operationalState}
        ${globalCellId}=              Set Variable   ${current_cell['globalCellId']}
        ${is_global_cell_id}=    Is Global Cell Id Retained For Streaming    global_cell_id=${globalCellId}    cell_list=${cell_id_streaming}
        Run Keyword If    ${is_global_cell_id}    Append to List    ${list_cell_id}    ${current_cell['id']['internal']}
    END
    #DEBUG_LOG#Dated Log              >> Distname list of cells retained for TTI streaming ${list_cell_id}
    [Return]                          ${list_cell_id}


Is Global Cell Id Retained For Streaming
    [Arguments]             ${global_cell_id}
    ...                     ${cell_list}

    ${result_global_cell}=            Set Variable    ${False}
    FOR    ${current_cell}    IN    @{cell_list}
        #DEBUG_LOG#Dated Log          >> global cell id ${global_cell_id} vs. current cell ${current_cell}
        #DEBUG_LOG#Run Keyword If    ${result_global_cell} or ${global_cell_id}==${current_cell}
        #DEBUG_LOG#...    Dated Log   >> True    ELSE    Dated Log    >> False
        ${result_global_cell}=    Run Keyword If    ${result_global_cell} or ${global_cell_id}==${current_cell}    Set Variable    ${True}
        ...                                   ELSE    Set Variable    ${False}
    END
    #DEBUG_LOG#Dated Log              >> final result returned is ${result_global_cell}
    [Return]                          ${result_global_cell}
# --------------------------------------------------------------------------------------------------------------------------------------------------
# Counter And KPI #
Check Counter And KPI Constraints Common
    [Arguments]             ${pm_path}
    ...                     ${test_name}
    ...                     ${localKpiFileName}=${None}

    Dated Log New Line                ----Check Counter And KPI Constraints----
    ${localKpiFile}=    Run Keyword If    "${localKpiFileName}" == "${None}"    Set Variable   ${None}
    ...                             ELSE    Set Variable   ${CURDIR}/../../config/counter/constraint/${localKpiFileName}
    KPIs.KPI Evaluate                 pmFile=${pm_path}
    ...                               constraintsFile=${CURDIR}/../../config/counter/constraint/${test_name}.csv
    ...                               failOnError=${True}
    ...                               localKpiFile=${localKpiFile}
    Dated Log                         > Check counter and KPI constraints is ended
# --------------------------------------------------------------------------------------------------------------------------------------------------
# Traffic #
DL+UL Traffic Not Stopped Common
    [Arguments]             ${param}
    ...                     ${current_ue_setting}
    ...                     ${current_trf_id}=1

    Set To Dictionary                 ${current_ue_setting}    trf_id    ${current_trf_id}
    Run Keyword If    ${current_ue_setting.throughput} > 0    Traffic UE DL    ueSetting=${current_ue_setting}
    ...                                                             throughput=${current_ue_setting.throughput}
    ...                                                             captureCallback=None
    ...                                                             capture=None
    ...                                                             captureDuration=0
    ...                                                             duration=${param.duration}
    ...                                                             shouldBeStop=False
    ...                                                             deviation=${param.deviation}

    ${current_trf_id}=                Evaluate    ${current_trf_id} + 9
    Set To Dictionary                 ${current_ue_setting}    trf_id    ${current_trf_id}
    Run Keyword If    ${current_ue_setting.throughput_ul} > 0    Traffic UE UL    ueSetting=${current_ue_setting}
    ...                                                             throughput=${current_ue_setting.throughput_ul}
    ...                                                             captureCallback=None
    ...                                                             capture=None
    ...                                                             captureDuration=0
    ...                                                             duration=${param.duration}
    ...                                                             shouldBeStop=False
    ...                                                             deviation=${param.deviation}
# --------------------------------------------------------------------------------------------------------------------------------------------------
# Alarm #
Get Number Of Alarm
    [Arguments]             ${oam_type}=${GNB_DU.oam}

    @{alarms}=                        OAM Get Active Alarms    oam=${oam_type}
    ${nb_of_alarm}=                   Get Length    ${alarms}
    [Return]                          ${nb_of_alarm}


Detection Alarm Id
    [Arguments]             ${alarm_id}=7101
    ...                     ${fault_id}=4383
    ...                     ${oam_type}=${GNB_DU.oam}

    Dated Log New Line                ----Detection Alarm----
    @{alarms}=                        OAM Get Active Alarms    oam=${oam_type}
    ${flag_alarm_id}=                 Set Variable    ${False}
    ${i}=                             Set Variable    ${0}
    FOR    ${alarm}    IN    @{alarms}
        ${i}=                         Evaluate    ${i}+${1}
        ${output_alarm}=              Replace String    ${alarm}    ]    [
        @{words}=                     Split String    ${output_alarm}    [
        #DEBUG_LOG#Dated Log          >> alarm words after split= ${words}
        ${flag_alarm_id}=             Run Keyword If    ${words[1]} == ${alarm_id}     Set Variable    ${True}     ELSE    Set Variable    ${False}
        Exit For Loop If    ${flag_alarm_id} == ${True}
    END
    ${iteration_alarm}=    Run Keyword If    ${flag_alarm_id} == ${True}    Set Variable    ${alarm}    ELSE    Set Variable    ${None}
    ${fault_id_word}=    Run Keyword If    ${flag_alarm_id} == ${True}    Set Variable    ${words[3]}    ELSE    Set Variable    ${None}
    Run Keyword If    ${flag_alarm_id} == ${True}    Run Keywords
    ...           Dated Log           \t> Alarm [${alarm_id}] with fault [${fault_id_word}] is detected
    ...    AND    Dated Log           > GNB_DU_OAM_ALARM[${i}]=${iteration_alarm}
    ...         ELSE    Dated Log     \t> Alarm is NOT detected
    Run Keyword If    ${flag_alarm_id} == ${True} and ${fault_id} != ${None}
    ...    Should Be True             "${fault_id}" == "${fault_id_word}"
    [Return]                          ${iteration_alarm}


Is Alarm Present
    [Arguments]             ${alarm_id}
    ...                     ${fault_id}

    FOR    ${iteration}    IN RANGE    1    5
        Dated Log                     ----Detection alarm attempt ${iteration}----
        ${alarm_information}=         Detection Alarm Id    alarm_id=${alarm_id}    fault_id=${fault_id}
        #DEBUG_LOG#Dated Log          >> alarm_information= ${alarm_information}
        Exit For Loop If              "${alarm_information}" != "${None}"
        Sleep                         5s
    END
    # Alarm must be found after 5 attempts
    Should Be True                    "${alarm_information}" != "${None}"
# --------------------------------------------------------------------------------------------------------------------------------------------------
# Verifications # CB008375-D #
Execute Command And Check Content
    [Arguments]             ${command}

    #DEBUG_LOG#Dated Log              >> ${command}
    ${result}=                        OperatingSystem.Run    ${command}
    #DEBUG_LOG#Dated Log              >> ${result}
    @{result_splitted}=               Split String    ${result}    separator=${SPACE}
    Remove Values From List           ${result_splitted}    ${EMPTY}
    #DEBUG_LOG#Dated Log              >> result found is ${result_splitted}
    ${list_length}=                   Get Length    ${result_splitted}
    ${log_size}=    Run Keyword If    ${list_length} != 0    Convert To Integer    ${result_splitted[0]}    ELSE    Set Variable    0
    Should Be True                    ${log_size} > 0
    #DEBUG_LOG#Dated Log              >> check is successful because log size= ${log_size} is well > 0
    [Return]                          ${result_splitted}
# --------------------------------------------------------------------------------------------------------------------------------------------------
# Verifications # CB012738-A #
CB012738 Execute Command And Check Content
    [Arguments]             ${cmd}
    ...                     ${msg}
    ...                     ${expected_res}=${False}

    Dated Log                         > ${msg}
    Dated Log                         >> ${cmd}
    ${res}=                           OperatingSystem.Run    ${cmd}
    ${len_res}=                       Get Length    ${res}
    Run Keyword If    ${expected_res}
    ...                               Should Be True    ${len_res} > 0
    ...         ELSE                  Should Be True    ${len_res} == 0
    Dated Log                         > check is passed and length result is ${len_res}


Create Dictionary With Common Parameters To Filter
    [Arguments]             ${list_nrcell}
    ...                     ${pos_nrcell}
    ...                     ${list_dico_rnti}

    Dated Log New Line                ----Create Common Param For Filtering----
    @{list_lcr_id}=                   Create List
    @{list_phys_cell_id}=             Create List
    @{list_rnti}=                     Create List
    FOR    ${position}    IN    @{pos_nrcell}
        ${internal_pos}=              Evaluate    ${position}-1
        ${current_nrcell_id}=         Set Variable    ${list_nrcell[${internal_pos}].nrCellId}
        ${current_dn_nrcell}=         Set Variable    ${dn_nrbts}/NRCELL-${current_nrcell_id}
        # NRCELL.lcriId / get
        ${current_param}=             Set Variable    lcrId
        ${nb_match}    ${current_lcr_id}     Get Values From Object    dist_name=${current_dn_nrcell}    p_name=${current_param}
        ...                                                         current_scf=${updated_scf}
        Should Be True                ${nb_match} > 0
        #DEBUG_LOG#Dated Log          >> match for ${current_dn_nrcell}: ${current_param}= ${current_lcr_id}
        ${convert_lcr_id}=            Convert To Integer    ${current_lcr_id}[0]
        Append To List                ${list_lcr_id}    ${convert_lcr_id}
        ${convert_phys_cell_id}=      Convert To Integer    ${list_nrcell[${internal_pos}].physCellId}
        Append To List                ${list_phys_cell_id}    ${convert_phys_cell_id}
    END
    FOR    ${current_elem}    IN    @{list_dico_rnti}
        ${convert_rnti}=              Convert To Integer    ${current_elem}[c_rnti]
        Append To List                ${list_rnti}    ${convert_rnti}
    END
    #DEBUG_LOG#Dated Log              >> lcrId= ${list_lcr_id}
    #DEBUG_LOG#Dated Log              >> physCellId= ${list_phys_cell_id}
    #DEBUG_LOG#Dated Log              >> rnti= ${list_rnti}
    &{dico_param}=                    Create Dictionary
    Set To Dictionary                 ${dico_param}    lcrId         ${list_lcr_id}
    Set To Dictionary                 ${dico_param}    physCellId    ${list_phys_cell_id}
    Set To Dictionary                 ${dico_param}    rnti          ${list_rnti}
    #DEBUG_LOG#Dated Log              >> ${dico_param}
    [Return]                          ${dico_param}
# --------------------------------------------------------------------------------------------------------------------------------------------------
# Testmode #
Create Csi Override Nr Profile
    [Arguments]             ${profile_id}
    ...                     ${cqi_val}
    ...                     ${cqi_mode}=fixed
    ...                     ${ri_val}=${None}
    ...                     ${pmi_val}=${None}

    Dated Log New Line                ----Create Csi Override Nr Profile----
    Run Keyword If    "${cqi_mode}" != "${None}"    Run Keywords
    ...                               wtsemu.csi_override_testmode_nr    profile_id=${profile_id}    cqi=${cqi_val}    cqi_mode=fixed
    ...    AND                        wtsemu.read_wtsemu_output_until_prompt    timeout=10
    ...    AND    Dated Log           > csi_override_testmode_nr profile_id=${profile_id} cqi=${cqi_val} cqi_mode=fixed
    ...         ELSE    Run Keywords    wtsemu.csi_override_testmode_nr    profile_id=${profile_id}    cqi=${cqi_val}    ri=${ri_val}
    ...                                                             pmi=${pmi_val}
    ...    AND                        wtsemu.read_wtsemu_output_until_prompt    timeout=10
    ...    AND    Dated Log           > csi_override_testmode_nr profile_id=${profile_id} cqi=${cqi_val} ri=${ri_val} pmi=${pmi_val}


Execute Testmode Csi Override
    [Arguments]             ${profile_id}
    ...                     ${nrcell}
    ...                     ${ue_id}
    ...                     ${action}

    Dated Log New Line                ----Execute Testmode Csi Override----
    wtsemu.ue_testmode_set_nr         id=${ue_id}    scell=${nrcell}    testmode=csi_override    profile_id=${profile_id}    action=${action}
    wtsemu.read_wtsemu_output_until_prompt    timeout=10
    Dated Log                         > ue_testmode_set_nr id=${ue_id} scell=${nrcell} testmode=csi_override prof_id=${profile_id} action=${action}


Execute Testmode Paging Start
    [Arguments]             ${ue_id}
    ...                     ${default_drx}=128
    ...                     ${max_paging}=5
    ...                     ${cause_release}=NAS_normal_release

    Dated Log New Line                ----Execute Testmode Paging Start for UE${ue_id}----
    wtsemu.amf_paging_param           id=1    default_drx=${default_drx}    max_paging_retries=${max_paging}
    wtsemu.read_wtsemu_output_until_prompt    timeout=10
    #
    wtsemu.ue_ng_ctx_release          id=${ue_id}    cause=${cause_release}
    ${status}    ${output}            Run Keyword And Ignore Error    wtsemu.read_wtsemu_output_until
    ...                                                             expected=UE${ue_id}: IS IDLE    timeout=10
    Run Keyword If    "${status}" == "FAIL"    Fail    ACTIVE-IDLE state is not found
    Return From Keyword If    "${status}" == "FAIL"
    ${output_1}=                      Get Lines Matching Regexp    ${output}    UE.*in NAS-.*ACTIVE-IDLE    partial_match=${TRUE}
    Log to Console                    ${output_1}
    ${output_2}=                      Get Lines Matching Regexp    ${output}    UE.*IS IDLE    partial_match=${TRUE}
    Log to Console                    ${output_2}
    #
    ${output}=                        wtsemu.amf_paging_start    id=1    ueid=${ue_id}
    ${status}    ${output}            Run Keyword And Ignore Error    wtsemu.read_wtsemu_output_until
    ...                                                             expected=PagingProcedure is in progress    timeout=10
    Run Keyword If    "${status}" == "FAIL"    Fail    PagingProcedure in progress state is not found
    Return From Keyword If    "${status}" == "FAIL"
    ${output_1}=                      Get Lines Matching Regexp    ${output}    Paging UE with.*    partial_match=${TRUE}
    Log to Console                    ${output_1}
    ${output_2}=                      Get Lines Matching Regexp    ${output}    UE.*paged on.*    partial_match=${TRUE}
    Log to Console                    ${output_2}
    ${output_3}=                      Get Lines Matching Regexp    ${output}    UE.*Paging.*is in progress    partial_match=${TRUE}
    Log to Console                    ${output_3}
    Sleep                             1s
    #
    ${output}=                        wtsemu.amf_paging_param_disp    id=1    ue=${ue_id}
    wtsemu.read_wtsemu_output_until_prompt    timeout=10


Execute Testmode UE Measurement Send NR
    [Arguments]             ${ue_id}
    ...                     ${physical_target_cell_id}
    ...                     ${meas_id}=1
    ...                     ${event_type}=A3


    Dated Log New Line                ----Execute Testmode UE Measurement Send NR----
    Dated Log                         > meas_id= ${meas_id} event= ${event_type} target= ${physical_target_cell_id} requested for ue= ${ue_id}
    # wtsemu.ue_measurement_send_nr    id=1    meas_id=1    event=A3    srsrp_nr=20    phycell_id=51    nrsrp_nr=90
    # rs_type=ssb    index=0    nrs_result=11:12:13 <= to avoid cp_rt warning when ssb-result is empty
    wtsemu.ue_measurement_send_nr     id=${ue_id}    meas_id=${meas_id}    event=${event_type}    phycell_id=${physical_target_cell_id}
    ...                               srsrp_nr=20    nrsrp_nr=90    rs_type=ssb    index=0    nrs_result=11:12:13
    Dated Log                         > waiting for measurement report message
    ${output}=                        wtsemu.Read Wtsemu Output Until    expected=measurementReport    timeout=10
    Dated Log                         > waiting for RRC reconfiguration complete message
    ${output_2}=                      wtsemu.Read Wtsemu Output Until    expected=rrcReconfigurationComplete    timeout=10
    #EGATE>  10:14:43.960  INF : UEC-1: UE1: reconfigurationWithSync with physCellId 51 is pres
    #ent in masterCellGroup. Handover will be triggered using CFRA.
    #Should Contain                   ${output_2}    reconfigurationWithSync with physCellId
    #${pattern_match_1}=    Set Variable    ^.*UE${ue_id}:\\s+reconfigurationWithSync\\s+with\\s+physCellId\\s+${physical_target_cell_id}.*$
    ${pattern_match_1}=    Set Variable    UE${ue_id}:\\s+reconfigurationWithSync\\s+with\\s+physCellId\\s+${physical_target_cell_id}
    ${result_match_1}=                Should Match Regexp    string=${output_2}    pattern=${pattern_match_1}
    Dated Log                         > match= ${result_match_1}
    #EGATE>  10:14:43.973  INF : UEC-1: UE1: CTRL_ADD_UE_HO_NR_RSP_T Received
    #${pattern_match_2}=              Set Variable    ^.*UE${ue_id}:\\s+CTRL_ADD_UE_HO_NR_RSP_T\\s+Received.*$
    ${pattern_match_2}=               Set Variable    UE${ue_id}:\\s+CTRL_ADD_UE_HO_NR_RSP_T\\s+Received
    ${result_match_2}=                Should Match Regexp    string=${output_2}    pattern=${pattern_match_2}
    Dated Log                         > match= ${result_match_2}
    #EGATE>  10:14:43.984  INF : UEC-1: UE1: CTRL_RACH_COMPLETE Received
    #${pattern_match_3}=              Set Variable    ^.*UE${ue_id}:\\s+CTRL_RACH_COMPLETE\\s+Received.*$
    ${pattern_match_3}=               Set Variable    UE${ue_id}:\\s+CTRL_RACH_COMPLETE\\s+Received
    ${result_match_3}=                Should Match Regexp    string=${output_2}    pattern=${pattern_match_3}
    Dated Log                         > match= ${result_match_3}
    #EGATE>  10:14:43.984  INF : UEC-1: UE1: Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2
    #performed (crnti: 49042 = 0xBF92)
    #${pattern_match_4}=              Set Variable    ^.*UE${ue_id}:\\s+Intra-eNB\\s+handover\\s+from.*to\\s+EXT_ENB-\\d+\.\\d+.*$
    ${pattern_match_4}=               Set Variable    UE${ue_id}:\\s+Intra-eNB\\s+handover\\s+from.*to\\s+EXT_ENB-\\d+\.\\d+
    ${result_match_4}=                Should Match Regexp    string=${output_2}    pattern=${pattern_match_4}
    Dated Log                         > match= ${result_match_4}
    #${pattern_match_5}=              Set Variable    ^.*performed\\s+\\(crnti:\\s+(\\d+)\\s+=\\s+0x\\w+\\).*$
    ${pattern_match_5}=               Set Variable    performed\\s+\\(crnti:\\s+(\\d+)\\s+=\\s+0x\\w+\\)
    ${result_match_5}    ${group_1}=    Should Match Regexp    string=${output_2}    pattern=${pattern_match_5}
    Dated Log                         > match= ${result_match_5}
    Dated Log                         > ue= ${ue_id}, new c_rnti= ${group_1}
    [Return]                          ${group_1}
# --------------------------------------------------------------------------------------------------------------------------------------------------
UE Register And CRNTI Backup
    [Arguments]             ${ue_settings}

    ${output_crnti}=                  CallSetup.UE Register    ue=${ue_settings}[ue]
    Set To Dictionary                 ${ue_settings}    c_rnti    ${output_crnti}
    Dated Log                         > The CRNTI ${ue_settings}[c_rnti] is saved for the UE Id ${ue_settings}[ue]


UE Establish NSA Call
    [Arguments]             ${ue_settings}

    CallSetup.UE Attach Enb           ueSetting=${ue_settings}
    Sleep                             5s
    CallSetup.UE Attach Gnb           ueSetting=${ue_settings}
# --------------------------------------------------------------------------------------------------------------------------------------------------
# Call And Then Traffic #
Call And Then Traffic For CB012738
    [Arguments]             ${param}
    ...                     ${ues_settings}
    ...                     ${capture_settings}

    ${param.total_nb_ue}=    Run Keyword If    ${CALL_ENABLED}    Get Length    ${ues_settings}
    ...                                  ELSE    Set Variable    0
    ${list_ue}    ${cell_id_for_streaming}    Get List UEs Settings    param=${param}    dict_settings=${ues_settings}
    Display List UEs Settings         ${list_ue}
    Dated Log                         > Cells list for TTI streaming is ${cell_id_for_streaming}
    #
    Dated Log New Line                ----CallSetup WTS Setup----
    Critical Step                     CallSetup.WTS Setup           nbUe=${param.total_nb_ue}
    ...                                                             nbSaUe=${param.nb_sa_ue}
    ...                                                             shouldUseLua=${False}
    ...                                                             nbCell=${param.total_nb_cell}
    #
    @{cell_id_list}=                  Get List Cells Retained For TTI Streaming    cell_id_streaming=${cell_id_for_streaming}
    Dated Log                         > Distname list of the cells retained for TTI streaming ${cell_id_list}
    #
    Run Keyword If    "${param.csi_override_cqi}" != "${None}"    Run Keywords
    ...                   Step        Create Csi Override Nr Profile   profile_id=1    cqi_val=${param.csi_override_cqi}
    ...    AND                        Sleep    2s
    ...    AND            Step        Execute Testmode Csi Override    profile_id=1    nrcell=${list_ue[0].target_cells}
    ...                                                             ue_id=${list_ue[0].ue}
    ...                                                             action=activate
    ...    AND                        Sleep    2s
    # Capture SYSLOG logs during call
    ${syslog}=    Run Keyword If    ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_syslog]    Run Keywords
    ...           Dated Log           ----Capture SYSLOG Start----
    ...    AND                        Syslogs.SYSLOG Start    host=${GNB_DU.sys[0].M}    name=_call
    # Capture L1L2 traces during call setup
    Run Keyword If    ${AUTO_SAVE_DEBUG_DATA} and ${param.total_nb_ue} > 0 and ${capture_settings}[is_capture_l1l2]    Run Keywords
    ...           Dated Log           ----Capture L1L2 Start----
    ...    AND                        Captures Init
    ...    AND                        Capture Start    capture=${capture_l1l2}
    ...    AND                        Sleep    3s
    # Capture CPRT during call setup
    Run Keyword If    ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_l1l2] and ${capture_settings}[is_capture_cprt]    Run Keywords
    ...           Dated Log           ----Capture CPRT Start----
    ...    AND                        Capture Start    capture=${capture_cprt}
    Dated Log New Line                ----Call Establishment----
    FOR    ${current_elem}    IN    @{list_ue}
        Run Keyword If    "${current_elem.call_type}" == "SA"    Run Keywords
        ...          Critical Step    UE Register And CRNTI Backup    ue_settings=${current_elem}
        ...                   depends=CallSetup.WTS Setup
        ...    AND        Step        CallSetup.Launch PDU Session    ue=${current_elem.ue}    pdu=${current_elem.pdu}    gw=${current_elem.ue}
        ...                   depends=UE Register And CRNTI Backup
        ...         ELSE
        ...          Critical Step    UE Establish NSA Call    ue_settings=${current_elem}
        ...                   depends=CallSetup.WTS Setup
    END
    Run Keyword If    ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_l1l2] and ${capture_settings}[is_capture_cprt]    Run Keywords
    ...           Dated Log           ----Capture CPRT Stop----
    ...    AND                        Capture Stop    capture=${capture_cprt}
    ${list_l1l2_crnti_filters}=       CB012738 Create Filter Message List Per CRNTI    list_elem=${list_ue}
    ${list_l1l2_messages_filters}=    CB012738 Create Filter Message List
    ${capture_l1l2_output}=           Set Variable    ${LOG_PATH}/L1L2/L1L2_call_setup.pcap
    Run Keyword If    ${AUTO_SAVE_DEBUG_DATA} and ${param.total_nb_ue} > 0 and ${capture_settings}[is_capture_l1l2]    Run Keywords
    ...           Dated Log           ----Capture L1L2 Stop----
    ...    AND                        Capture Stop    capture=${capture_l1l2}
    ...    AND    Dated Log           > capture l1l2 input= ${capture_l1l2.path}
    ...    AND    Dated Log           > capture l1l2 output= ${capture_l1l2_output}
    ...    AND                        Run    command=mkdir -p ${LOG_PATH}/L1L2
    ...    AND                        Run    command=mv ${capture_l1l2.path} ${capture_l1l2_output}
    ...    AND                        Post Processing L1L2 Traces    pcap_file=${capture_l1l2_output}
    ...                                                             list_crnti_filters=${list_l1l2_crnti_filters}
    ...                                                             list_messages_filters=${list_l1l2_messages_filters}
    #
    Display List UEs Settings         ${list_ue}
    Dated Log New Line                ----Traffic----
    FOR    ${current_elem}    IN    @{list_ue}
        Run Keyword If    "${param.dir}" != "${None}"
        ...               Step        ${param.dir} Traffic Not Stopped Common    param=${param}    current_ue_setting=${current_elem}
    END
    # Capture L1L2 traces during traffic
    Run Keyword If    ${AUTO_SAVE_DEBUG_DATA} and ${param.total_nb_ue} > 0 and ${capture_settings}[is_capture_l1l2]    Run Keywords
    ...           Dated Log           ----Capture L1L2 Start----
    ...    AND                        Captures Init
    ...    AND                        Capture Start    capture=${capture_l1l2}
    ...    AND                        Sleep    3s
    FOR    ${current_elem}    IN    @{list_ue}
        Run Keyword If    ${current_elem.paging} == ${True}    Step        Execute Testmode Paging Start    ue_id=${current_elem.ue}
    END
    Traced Sleep                      duration=8s    msg=traffic and before stopping capture L1L2
    Run Keyword If    ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_syslog]    Run Keywords
    ...           Dated Log           ----Capture SYSLOG Stop----
    ...    AND                        Syslogs.SYSLOG Stop    syslog=${syslog}
    ${list_l1l2_crnti_filters}=       CB012738 Create Filter Message List Per CRNTI    list_elem=${list_ue}
    ${list_l1l2_messages_filters}=    CB012738 Create Filter Message List
    ${capture_l1l2_output}=           Set Variable    ${LOG_PATH}/L1L2/L1L2_traffic.pcap
    Run Keyword If    ${AUTO_SAVE_DEBUG_DATA} and ${param.total_nb_ue} > 0 and ${capture_settings}[is_capture_l1l2]    Run Keywords
    ...           Dated Log           ----Capture L1L2 Stop----
    ...    AND                        Capture Stop    capture=${capture_l1l2}
    ...    AND    Dated Log           > capture l1l2 input= ${capture_l1l2.path}
    ...    AND    Dated Log           > capture l1l2 output= ${capture_l1l2_output}
    ...    AND                        Run    command=mkdir -p ${LOG_PATH}/L1L2
    ...    AND                        Run    command=mv ${capture_l1l2.path} ${capture_l1l2_output}
    ...    AND                        Post Processing L1L2 Traces    pcap_file=${capture_l1l2_output}
    ...                                                             list_crnti_filters=${list_l1l2_crnti_filters}
    ...                                                             list_messages_filters=${list_l1l2_messages_filters}
    # Capture TTI traces during traffic
    Run Keyword If    ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_tti]    Run Keywords
    ...           Dated Log           ----Capture TTI Start----
    ...    AND                        Start TTI Logs Common    cell_id_list=${cell_id_list}
    FOR    ${current_elem}    IN    @{list_ue}
        Run Keyword If    ${current_elem.paging} == ${True}    Step        Execute Testmode Paging Start    ue_id=${current_elem.ue}
    END
    Traced Sleep                      duration=8s    msg=traffic and before stopping capture L1L2
    Run Keyword If    ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_tti]    Run Keywords
    ...           Dated Log           ----Capture TTI Stop----
    ...    AND                        Stop and Get TTI Logs Common    trace_name=TTI_traffic
    Dated Log New Line                ----Check Counter And KPI Constraints----
    Run Keyword If    ${param.pm_waiting_period} > 0    Wait PM availability    pmPeriodSec=300    #pmAvailDelay=60 #Sleep Until PM Availability
    # Waiting time added for observation and allow generation of multiple count periods
    FOR    ${iteration_pm}    IN RANGE    0    ${param.pm_waiting_period}
        Wait PM availability    pmPeriodSec=300    #pmAvailDelay=60
        ${pm_path}=    Run Keyword If    not ${isAic}    Counters.Collect PM files from BTS    ${LOG_PATH}/PM
        Run Keyword If    not ${isAic}
        ...               Step    Check Counter And KPI Constraints Common    pm_path=${pm_path}    test_name=${param.test_name}
    END
    # Deregister all the ue's
    FOR    ${current_elem}    IN    @{list_ue}
        Run Keyword If    "${current_elem.call_type}" == "SA"
        ...               Step        CallSetup.UE Deregister    id=${current_elem.ue}    ue_deregister_type=switch_off    by=ue
        ...                   depends=Ue Register And CRNTI Backup
        ...         ELSE
        ...               Step        CallSetup.UE Detach Enb    ueSetting=${current_elem}
        ...                   depends=UE Establish NSA Call
    END
    ${capture_cprt_input}=            Set Variable    ${LOG_PATH}/CPRT_NODE_GNB0.pcap
    ${capture_cprt_output}=           Set Variable    ${LOG_PATH}/CPRT/CPRT_NODE_GNB0_syscom.pcap
    Run Keyword If    ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_cprt]    Run Keywords
    ...           Dated Log           > capture_cprt_input= ${capture_cprt_input}
    ...    AND    Dated Log           > capture_cprt_output= ${capture_cprt_output}
    ...    AND                        Run    command=mkdir -p ${LOG_PATH}/CPRT
    ...    AND                        Run    command=tshark -r ${capture_cprt_input} -Y 'sctp and syscom' -w ${capture_cprt_output}
    ...    AND                        Run    command=rm -rf ${capture_cprt_input}
# --------------------------------------------------------------------------------------------------------------------------------------------------
Call And Then Traffic For CB012738 With Cqi Customization Bis
    [Arguments]             ${param}
    ...                     ${ues_settings}
    ...                     ${capture_settings}

    ${param.total_nb_ue}=    Run Keyword If    ${CALL_ENABLED}    Get Length    ${ues_settings}
    ...                                  ELSE    Set Variable    0
    ${list_ue}    ${cell_id_for_streaming}    Get List UEs Settings    param=${param}    dict_settings=${ues_settings}
    Display List UEs Settings         ${list_ue}
    Dated Log                         > Cells list for TTI streaming is ${cell_id_for_streaming}
    #
    Dated Log New Line                ----CallSetup WTS Setup----
    Critical Step                     CallSetup.WTS Setup           nbUe=${param.total_nb_ue}
    ...                                                             nbSaUe=${param.nb_sa_ue}
    ...                                                             shouldUseLua=${False}
    ...                                                             nbCell=${param.total_nb_cell}
    #
    @{cell_id_list}=                  Get List Cells Retained For TTI Streaming    cell_id_streaming=${cell_id_for_streaming}
    Dated Log                         > Distname list of the cells retained for TTI streaming ${cell_id_list}
    #
    FOR    ${current_id}    IN RANGE    0    ${param.total_nb_ue}
        ${current_ri}=    Run Keyword If    "${param.csi_override_cqi}" != "${None}" and ${list_ue[${current_id}].csi_override_cqi} <= 6
        ...                           Set Variable    0    ELSE    Set Variable    1
        ${current_pmi}=    Run Keyword If    "${param.csi_override_cqi}" != "${None}" and ${list_ue[${current_id}].csi_override_cqi} <= 6
        ...                           Set Variable    0    ELSE    Set Variable    1
        Run Keyword If    "${param.csi_override_cqi}" != "${None}"    Run Keywords
        ...                           Create Csi Override Nr Profile   profile_id=${list_ue[${current_id}].ue}
        ...                                                         cqi_val=${list_ue[${current_id}].csi_override_cqi}
        ...                                                         cqi_mode=${None}
        ...                                                         ri_val=${current_ri}
        ...                                                         pmi_val=${current_pmi}
        ...    AND                    Sleep    2s
        ...    AND                    Execute Testmode Csi Override    profile_id=${list_ue[${current_id}].ue}
        ...                                                         nrcell=${list_ue[${current_id}].target_cells}
        ...                                                         ue_id=${list_ue[${current_id}].ue}
        ...                                                         action=activate
        ...    AND                    Sleep    2s
    END
    # Capture SYSLOG logs during call
    ${syslog}=    Run Keyword If    ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_syslog]    Run Keywords
    ...           Dated Log           ----Capture SYSLOG Start----
    ...    AND                        Syslogs.SYSLOG Start    host=${GNB_DU.sys[0].M}    name=_call
    # Capture L1L2 traces during call setup
    Run Keyword If    ${AUTO_SAVE_DEBUG_DATA} and ${param.total_nb_ue} > 0 and ${capture_settings}[is_capture_l1l2]    Run Keywords
    ...           Dated Log           ----Capture L1L2 Start----
    ...    AND                        Captures Init
    ...    AND                        Capture Start    capture=${capture_l1l2}
    ...    AND                        Sleep    3s
    # Capture CPRT during call setup
    Run Keyword If    ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_l1l2] and ${capture_settings}[is_capture_cprt]    Run Keywords
    ...           Dated Log           ----Capture CPRT Start----
    ...    AND                        Capture Start    capture=${capture_cprt}
    Dated Log New Line                ----Call Establishment----
    FOR    ${current_elem}    IN    @{list_ue}
        Run Keyword If    "${current_elem.call_type}" == "SA"    Run Keywords
        ...          Critical Step    UE Register And CRNTI Backup    ue_settings=${current_elem}
        ...                   depends=CallSetup.WTS Setup
        ...    AND        Step        CallSetup.Launch PDU Session    ue=${current_elem.ue}    pdu=${current_elem.pdu}    gw=${current_elem.ue}
        ...                   depends=UE Register And CRNTI Backup
        ...         ELSE
        ...          Critical Step    UE Establish NSA Call    ue_settings=${current_elem}
        ...                   depends=CallSetup.WTS Setup
    END
    Run Keyword If    ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_l1l2] and ${capture_settings}[is_capture_cprt]    Run Keywords
    ...           Dated Log           ----Capture CPRT Stop----
    ...    AND                        Capture Stop    capture=${capture_cprt}
    ${list_l1l2_crnti_filters}=       CB012738 Create Filter Message List Per CRNTI    list_elem=${list_ue}
    ${list_l1l2_messages_filters}=    CB012738 Create Filter Message List
    ${capture_l1l2_output}=           Set Variable    ${LOG_PATH}/L1L2/L1L2_call_setup.pcap
    Run Keyword If    ${AUTO_SAVE_DEBUG_DATA} and ${param.total_nb_ue} > 0 and ${capture_settings}[is_capture_l1l2]    Run Keywords
    ...           Dated Log           ----Capture L1L2 Stop----
    ...    AND                        Capture Stop    capture=${capture_l1l2}
    ...    AND    Dated Log           > capture l1l2 input= ${capture_l1l2.path}
    ...    AND    Dated Log           > capture l1l2 output= ${capture_l1l2_output}
    ...    AND                        Run    command=mkdir -p ${LOG_PATH}/L1L2
    ...    AND                        Run    command=mv ${capture_l1l2.path} ${capture_l1l2_output}
    ...    AND                        Post Processing L1L2 Traces    pcap_file=${capture_l1l2_output}
    ...                                                             list_crnti_filters=${list_l1l2_crnti_filters}
    ...                                                             list_messages_filters=${list_l1l2_messages_filters}
    #
    Display List UEs Settings         ${list_ue}
    Dated Log New Line                ----Traffic----
    FOR    ${current_elem}    IN    @{list_ue}
        Run Keyword If    "${param.dir}" != "${None}"
        ...               Step        ${param.dir} Traffic Not Stopped Common    param=${param}    current_ue_setting=${current_elem}
    END
    # Capture L1L2 traces during traffic
    Run Keyword If    ${AUTO_SAVE_DEBUG_DATA} and ${param.total_nb_ue} > 0 and ${capture_settings}[is_capture_l1l2]    Run Keywords
    ...           Dated Log           ----Capture L1L2 Start----
    ...    AND                        Captures Init
    ...    AND                        Capture Start    capture=${capture_l1l2}
    ...    AND                        Sleep    3s
    FOR    ${current_elem}    IN    @{list_ue}
        Run Keyword If    ${current_elem.paging} == ${True}    Step        Execute Testmode Paging Start    ue_id=${current_elem.ue}
    END
    Traced Sleep                      duration=8s    msg=traffic and before stopping capture L1L2
    Run Keyword If    ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_syslog]    Run Keywords
    ...           Dated Log           ----Capture SYSLOG Stop----
    ...    AND                        Syslogs.SYSLOG Stop    syslog=${syslog}
    ${list_l1l2_crnti_filters}=       CB012738 Create Filter Message List Per CRNTI    list_elem=${list_ue}
    ${list_l1l2_messages_filters}=    CB012738 Create Filter Message List
    ${capture_l1l2_output}=           Set Variable    ${LOG_PATH}/L1L2/L1L2_traffic.pcap
    Run Keyword If    ${AUTO_SAVE_DEBUG_DATA} and ${param.total_nb_ue} > 0 and ${capture_settings}[is_capture_l1l2]    Run Keywords
    ...           Dated Log           ----Capture L1L2 Stop----
    ...    AND                        Capture Stop    capture=${capture_l1l2}
    ...    AND    Dated Log           > capture l1l2 input= ${capture_l1l2.path}
    ...    AND    Dated Log           > capture l1l2 output= ${capture_l1l2_output}
    ...    AND                        Run    command=mkdir -p ${LOG_PATH}/L1L2
    ...    AND                        Run    command=mv ${capture_l1l2.path} ${capture_l1l2_output}
    ...    AND                        Post Processing L1L2 Traces    pcap_file=${capture_l1l2_output}
    ...                                                             list_crnti_filters=${list_l1l2_crnti_filters}
    ...                                                             list_messages_filters=${list_l1l2_messages_filters}
    # Capture TTI traces during traffic
    Run Keyword If    ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_tti]    Run Keywords
    ...           Dated Log           ----Capture TTI Start----
    ...    AND                        Start TTI Logs Common    cell_id_list=${cell_id_list}
    FOR    ${current_elem}    IN    @{list_ue}
        Run Keyword If    ${current_elem.paging} == ${True}    Step        Execute Testmode Paging Start    ue_id=${current_elem.ue}
    END
    Traced Sleep                      duration=8s    msg=traffic and before stopping capture L1L2
    Run Keyword If    ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_tti]    Run Keywords
    ...           Dated Log           ----Capture TTI Stop----
    ...    AND                        Stop and Get TTI Logs Common    trace_name=TTI_traffic
    Dated Log New Line                ----Check Counter And KPI Constraints----
    Run Keyword If    ${param.pm_waiting_period} > 0    Wait PM availability    pmPeriodSec=300    #pmAvailDelay=60 #Sleep Until PM Availability
    # Waiting time added for observation and allow generation of multiple count periods
    FOR    ${iteration_pm}    IN RANGE    0    ${param.pm_waiting_period}
        Wait PM availability    pmPeriodSec=300    #pmAvailDelay=60
        ${pm_path}=    Run Keyword If    not ${isAic}    Counters.Collect PM files from BTS    ${LOG_PATH}/PM
        Run Keyword If    not ${isAic}
        ...               Step    Check Counter And KPI Constraints Common    pm_path=${pm_path}    test_name=${param.test_name}
    END
    # Deregister all the ue's
    FOR    ${current_elem}    IN    @{list_ue}
        Run Keyword If    "${current_elem.call_type}" == "SA"
        ...               Step        CallSetup.UE Deregister    id=${current_elem.ue}    ue_deregister_type=switch_off    by=ue
        ...                   depends=Ue Register And CRNTI Backup
        ...         ELSE
        ...               Step        CallSetup.UE Detach Enb    ueSetting=${current_elem}
        ...                   depends=UE Establish NSA Call
    END
    ${capture_cprt_input}=            Set Variable    ${LOG_PATH}/CPRT_NODE_GNB0.pcap
    ${capture_cprt_output}=           Set Variable    ${LOG_PATH}/CPRT/CPRT_NODE_GNB0_syscom.pcap
    Run Keyword If    ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_cprt]    Run Keywords
    ...           Dated Log           > capture_cprt_input= ${capture_cprt_input}
    ...    AND    Dated Log           > capture_cprt_output= ${capture_cprt_output}
    ...    AND                        Run    command=mkdir -p ${LOG_PATH}/CPRT
    ...    AND                        Run    command=tshark -r ${capture_cprt_input} -Y 'sctp and syscom' -w ${capture_cprt_output}
    ...    AND                        Run    command=rm -rf ${capture_cprt_input}
# --------------------------------------------------------------------------------------------------------------------------------------------------
# Handover #
Perform Handover By Using meas_id 1 and event A3
    [Arguments]             ${current_elem}
    ...                     ${csi_override_cqi}=3

    Dated Log New Line                ----Perform Handover By Using meas_id 1 and event A3----
    ${backup_serving_cell_id}=        Set Variable    ${current_elem.target_cells}
    ${current_param}=                 Set Variable    physCellId
    ${dn_target_nrcell_for_ho}=   Set Variable    ${dn_nrbts}/NRCELL-${current_elem.target_handover}
    # NRCELL.physCellId / get / target
    ${nb_match}    ${result}      Get Values From Object    dist_name=${dn_target_nrcell_for_ho}    p_name=${current_param}
    ...                                                             current_scf=${updated_scf}
    Should Be True                ${nb_match} > 0
    ${physical_target_cell_id_for_ho}=    Set Variable    ${result}[0]
    Dated Log                     >> match for ${dn_target_nrcell_for_ho}: ${current_param}= ${physical_target_cell_id_for_ho}
    ${output_crnti}=              Execute Testmode UE Measurement Send NR    ue_id=${current_elem.ue}
    ...                                                             physical_target_cell_id=${physical_target_cell_id_for_ho}
    Run Keyword If    "${csi_override_cqi}" != "${None}"    Run Keywords
    ...                           Execute Testmode Csi Override    profile_id=${current_elem.ue}
    ...                                                         nrcell=${current_elem.target_cells}
    ...                                                         ue_id=${current_elem.ue}
    ...                                                         action=deactivate
    ...    AND                    Execute Testmode Csi Override    profile_id=${current_elem.ue}
    ...                                                         nrcell=${current_elem.target_handover}
    ...                                                         ue_id=${current_elem.ue}
    ...                                                         action=activate
    Set To Dictionary    ${current_elem}    target_cells    ${current_elem.target_handover}
    Set To Dictionary    ${current_elem}    target_handover    ${backup_serving_cell_id}
    Set To Dictionary    ${current_elem}    c_rnti    ${output_crnti}


Perform Handovers By Using meas_id 1 and event A3
    [Arguments]             ${list_ue}
    ...                     ${param}

    FOR    ${current_elem}    IN    @{list_ue}
        Run Keyword If    "${param.ue_measurement_nr}" == "${True}" and ${current_elem.ue_measurement_nr} == ${True}
        ...                           Perform Handover By Using meas_id 1 and event A3    ${current_elem}
    END


Perform N Handovers By Using meas_id 1 and event A3
    [Arguments]             ${list_elem}
    ...                     ${param}
    ...                     ${n_handover}=50

    Dated Log New Line                ----Perform ${n_handover} Handovers By Using meas_id 1 and event A3----
    FOR    ${iteration}    IN RANGE    1    ${n_handover} + 1
        Dated Log                     > Loop ${iteration} / ${n_handover}
        Perform Handovers By Using meas_id 1 and event A3    list_ue=${list_elem}    param=${param}
        Sleep                         1s
    END


Call And Then Traffic For CB012738 With Handover
    [Arguments]             ${param}
    ...                     ${ues_settings}
    ...                     ${capture_settings}
    ...                     ${list_position_nrcell}

    ${param.total_nb_ue}=    Run Keyword If    ${CALL_ENABLED}    Get Length    ${ues_settings}
    ...                                  ELSE    Set Variable    0
    ${list_ue}    ${cell_id_for_streaming}    Get List UEs Settings    param=${param}    dict_settings=${ues_settings}
    Display List UEs Settings         ${list_ue}
    Dated Log                         > Cells list for TTI streaming is ${cell_id_for_streaming}
    #
    Dated Log New Line                ----CallSetup WTS Setup----
    Critical Step                     CallSetup.WTS Setup           nbUe=${param.total_nb_ue}
    ...                                                             nbSaUe=${param.nb_sa_ue}
    ...                                                             shouldUseLua=${False}
    ...                                                             nbCell=${param.total_nb_cell}
    #
    @{cell_id_list}=                  Get List Cells Retained For TTI Streaming    cell_id_streaming=${cell_id_for_streaming}
    Dated Log                         > Distname list of the cells retained for TTI streaming ${cell_id_list}
    #
    FOR    ${current_id}    IN RANGE    0    ${param.total_nb_ue}
        ${current_ri}=    Run Keyword If    "${param.csi_override_cqi}" != "${None}" and ${list_ue[${current_id}].csi_override_cqi} <= 6
        ...                           Set Variable    0    ELSE    Set Variable    1
        ${current_pmi}=    Run Keyword If    "${param.csi_override_cqi}" != "${None}" and ${list_ue[${current_id}].csi_override_cqi} <= 6
        ...                           Set Variable    0    ELSE    Set Variable    1
        Run Keyword If    "${param.csi_override_cqi}" != "${None}"    Run Keywords
        ...                           Create Csi Override Nr Profile   profile_id=${list_ue[${current_id}].ue}
        ...                                                         cqi_val=${list_ue[${current_id}].csi_override_cqi}
        ...                                                         cqi_mode=${None}
        ...                                                         ri_val=${current_ri}
        ...                                                         pmi_val=${current_pmi}
        ...    AND                    Sleep    2s
        ...    AND                    Execute Testmode Csi Override    profile_id=${list_ue[${current_id}].ue}
        ...                                                         nrcell=${list_ue[${current_id}].target_cells}
        ...                                                         ue_id=${list_ue[${current_id}].ue}
        ...                                                         action=activate
        ...    AND                    Sleep    2s
    END
    # Capture SYSLOG logs during call
    ${syslog}=    Run Keyword If    ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_syslog]    Run Keywords
    ...           Dated Log           ----Capture SYSLOG Start----
    ...    AND                        Syslogs.SYSLOG Start    host=${GNB_DU.sys[0].M}    name=_call
    # Capture L1L2 traces during call setup
    Run Keyword If    ${AUTO_SAVE_DEBUG_DATA} and ${param.total_nb_ue} > 0 and ${capture_settings}[is_capture_l1l2]    Run Keywords
    ...           Dated Log           ----Capture L1L2 Start----
    ...    AND                        Captures Init
    ...    AND                        Capture Start    capture=${capture_l1l2}
    ...    AND                        Sleep    3s
    # Capture CPRT during call setup
    Run Keyword If    ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_l1l2] and ${capture_settings}[is_capture_cprt]    Run Keywords
    ...           Dated Log           ----Capture CPRT Start----
    ...    AND                        Capture Start    capture=${capture_cprt}
    Dated Log New Line                ----Call Establishment----
    FOR    ${current_elem}    IN    @{list_ue}
        Run Keyword If    "${current_elem.call_type}" == "SA"    Run Keywords
        ...          Critical Step    UE Register And CRNTI Backup    ue_settings=${current_elem}
        ...                   depends=CallSetup.WTS Setup
        ...    AND        Step        CallSetup.Launch PDU Session    ue=${current_elem.ue}    pdu=${current_elem.pdu}    gw=${current_elem.ue}
        ...                   depends=UE Register And CRNTI Backup
        ...         ELSE
        ...          Critical Step    UE Establish NSA Call    ue_settings=${current_elem}
        ...                   depends=CallSetup.WTS Setup
    END
    Run Keyword If    ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_l1l2] and ${capture_settings}[is_capture_cprt]    Run Keywords
    ...           Dated Log           ----Capture CPRT Stop----
    ...    AND                        Capture Stop    capture=${capture_cprt}
    #OBSOLETE#${list_l1l2_crnti_filters}=       CB012738 Create Filter Message List Per CRNTI    list_elem=${list_ue}
    #OBSOLETE#${list_l1l2_messages_filters}=    CB012738 Create Filter Message List
    ${capture_l1l2_output}=           Set Variable    ${LOG_PATH}/L1L2/L1L2_call_setup.pcap
    Run Keyword If    ${AUTO_SAVE_DEBUG_DATA} and ${param.total_nb_ue} > 0 and ${capture_settings}[is_capture_l1l2]    Run Keywords
    ...           Dated Log           ----Capture L1L2 Stop----
    ...    AND                        Capture Stop    capture=${capture_l1l2}
    ...    AND    Dated Log           > capture l1l2 input= ${capture_l1l2.path}
    ...    AND    Dated Log           > capture l1l2 output= ${capture_l1l2_output}
    ...    AND                        Run    command=mkdir -p ${LOG_PATH}/L1L2
    ...    AND                        Run    command=mv ${capture_l1l2.path} ${capture_l1l2_output}
    #OBSOLETE#...    AND              Post Processing L1L2 Traces    pcap_file=${capture_l1l2_output}
    #OBSOLETE#...                                                   list_crnti_filters=${list_l1l2_crnti_filters}
    #OBSOLETE#...                                                   list_messages_filters=${list_l1l2_messages_filters}
    #
    Display List UEs Settings         ${list_ue}
    Dated Log New Line                ----Traffic----
    FOR    ${current_elem}    IN    @{list_ue}
        Run Keyword If    "${param.dir}" != "${None}"
        ...               Step        ${param.dir} Traffic Not Stopped Common    param=${param}    current_ue_setting=${current_elem}
    END
    # Capture L1L2 traces during traffic
    Run Keyword If    ${AUTO_SAVE_DEBUG_DATA} and ${param.total_nb_ue} > 0 and ${capture_settings}[is_capture_l1l2]    Run Keywords
    ...           Dated Log           ----Capture L1L2 Start----
    ...    AND                        Captures Init
    ...    AND                        Capture Start    capture=${capture_l1l2}
    Traced Sleep                      duration=3s    msg=traffic and capture L1L2 start before handover
    Dated Log New Line                ----Handover----
    Step                              Perform Handovers By Using meas_id 1 and event A3    list_ue=${list_ue}    param=${param}
    Display List UEs Settings         ${list_ue}
    Traced Sleep                      duration=3s    msg=traffic after handover and before capture L1L2 stop
    Run Keyword If    ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_syslog]    Run Keywords
    ...           Dated Log           ----Capture SYSLOG Stop----
    ...    AND                        Syslogs.SYSLOG Stop    syslog=${syslog}
    #OBSOLETE#${list_l1l2_crnti_filters}=       CB012738 Create Filter Message List Per CRNTI    list_elem=${list_ue}
    #OBSOLETE#${list_l1l2_messages_filters}=    CB012738 Create Filter Message List
    ${capture_l1l2_output}=           Set Variable    ${LOG_PATH}/L1L2/L1L2_traffic.pcap
    Run Keyword If    ${AUTO_SAVE_DEBUG_DATA} and ${param.total_nb_ue} > 0 and ${capture_settings}[is_capture_l1l2]    Run Keywords
    ...           Dated Log           ----Capture L1L2 Stop----
    ...    AND                        Capture Stop    capture=${capture_l1l2}
    ...    AND    Dated Log           > capture l1l2 input= ${capture_l1l2.path}
    ...    AND    Dated Log           > capture l1l2 output= ${capture_l1l2_output}
    ...    AND                        Run    command=mkdir -p ${LOG_PATH}/L1L2
    ...    AND                        Run    command=mv ${capture_l1l2.path} ${capture_l1l2_output}
    #OBSOLETE#...    AND              Post Processing L1L2 Traces    pcap_file=${capture_l1l2_output}
    #OBSOLETE#...                                                   list_crnti_filters=${list_l1l2_crnti_filters}
    #OBSOLETE#...                                                   list_messages_filters=${list_l1l2_messages_filters}
    #
    # Capture TTI traces during traffic
    Run Keyword If    ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_tti]    Run Keywords
    ...           Dated Log           ----Capture TTI Start----
    ...    AND                        Start TTI Logs Common    cell_id_list=${cell_id_list}
    Traced Sleep                      duration=3s    msg=traffic and capture TTI start before handover
    Dated Log New Line                ----Handover----
    Step                              Perform Handovers By Using meas_id 1 and event A3    list_ue=${list_ue}    param=${param}
    Display List UEs Settings         ${list_ue}
    Traced Sleep                      duration=3s    msg=traffic after handover and before capture TTI stop
    Run Keyword If    ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_tti]    Run Keywords
    ...           Dated Log           ----Capture TTI Stop----
    ...    AND                        Stop and Get TTI Logs Common    trace_name=TTI_traffic
    #
    #
    # decoding only recommended events from pcap to json temporary file
    ${capture_tti_output}=            Set Variable    ${LOG_PATH}/TTITraces/TTI_traffic.pcap
    ${csv_tti_output}=                Set Variable    ${LOG_PATH}/TTITraces/TTI_traffic.csv
    ${json_tti_output}=               Set Variable    ${LOG_PATH}/TTITraces/TTI_traffic_filtered.json
    #OBSOLETE#${tti_decoder_path}=    Set Variable    /opt/tti-dec/tti-dec-bin/
    @{list_events_to_filter}=         Create List    utcTimestampData    dlFdSchedData    ulFdSchedData
    ...                                                             dlPdcchDciData    ulPdcchDciData    dlPagingOrSibSchedData
    Run Keyword If    ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_tti]    Run Keywords
    ...           Dated Log           ----TTI Decoding----
    ...    AND    Dated Log           > TTI pcap to decode is ${capture_tti_output}
    #DEBUG_LOG#...    AND    Dated Log    > with only events: ${list_events_to_filter}
    ...    AND                        TtiConvertInterface.Convert TTI capture    pcap_file_path=${capture_tti_output}
    ...                                                                 events_list=${list_events_to_filter}
    ${status}   ${ret}   Run Keyword And Ignore Error    OperatingSystem.File Should Exist    ${json_tti_output}
    Run Keyword If   ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_tti] and "${status}" != "PASS"    Run Keywords
    ...           Dated Log           > TTI decoding is failed because ${json_tti_output} is not found
    ...    AND    Should Be True      "${status}" == "PASS"
    Run Keyword If   ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_tti]    Run Keywords
    ...           Dated Log           > TTI decoding is passed in ${json_tti_output}
    ...    AND    Dated Log           ----TTI Export----
    # ${path_to_json} is mandatory for decoding then create a symbolic link to ${json_tti_output}
    Run                               command=ln -fs ${json_tti_output} ${path_to_json}
    # export a list of parameters in csv by using filters
    @{list_param_to_export}=          Create List    timeStamp    sfn    slot    rnti    lcrId    physCellId
    # dlFdSchedData
    ...                                                             dlFdSchedData.startCce
    ...                                                             dlFdSchedData.aggregationLevel
    ...                                                             dlFdSchedData.pdcchPowerBoostType
    ...                                                             dlFdSchedData.pdcchStartSymbol
    ...                                                             dlFdSchedData.SLIV
    ...                                                             dlFdSchedData.dciFormat
    ...                                                             dlFdSchedData.searchSpaceId
    ...                                                             dlFdSchedData.cqiAlSelection
    ...                                                             dlFdSchedData.pdcchCqi
    # ulFdSchedData
    ...                                                             ulFdSchedData.startCce
    ...                                                             ulFdSchedData.aggregationLevel
#    ...                                                             ulFdSchedData.pdcchPowerBoostType
    ...                                                             ulFdSchedData.pdcchStartSymbol
    ...                                                             ulFdSchedData.SLIV
    ...                                                             ulFdSchedData.dciFormat
    ...                                                             ulFdSchedData.searchSpaceId
    ...                                                             ulFdSchedData.cqiAlSelection
    ...                                                             ulFdSchedData.pdcchCqi
    #KEY_ERROR_NOT_IN_INDEX## dlPdcchDciData
    #...                                                            dlPdcchDciData.ueDciInfoList.rnti
    #...                                                            dlPdcchDciData.ueDciInfoList.dciFormat
    #...                                                            dlPdcchDciData.ueDciInfoList.dciTransmitPower
    #KEY_ERROR_NOT_IN_INDEX## ulPdcchDciData
    #...                                                            ulPdcchDciData.ueDciInfoList.rnti
    #...                                                            ulPdcchDciData.ueDciInfoList.dciFormat
    #...                                                            ulPdcchDciData.ueDciInfoList.dciTransmitPower
    #KEY_ERROR_NOT_IN_INDEX## dlPagingOrSibSchedData for rnti 64534 and 65535
    #...                                                            dlPagingOrSibSchedData.dciFormat
    #...                                                            dlPagingOrSibSchedData.startCce
    #...                                                            dlPagingOrSibSchedData.searchSpaceId
    #...                                                            dlPagingOrSibSchedData.aggregationLevel
    # dictionary of common parameters to filter, optional and can be set to none
    #TEST#&{dico_common_param_to_filter}=   Create Dictionary    lcrId=[1, 2]    physCellId=[50, 51]    rnti=[23080, 54928, 53088, 28966, 60814]
    &{dico_common_param_to_filter}=   Run Keyword If   ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_tti]
    ...                               Create Dictionary With Common Parameters To Filter    list_nrcell=${TDD_Cell_list}
    ...                                                             pos_nrcell=${list_position_nrcell}
    ...                                                             list_dico_rnti=${list_ue}
    # dictionary of specific parameters to filter, optional and can be set to none
    #TEST#&{dico_specif_param_to_filter}=   Run Keyword If   ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_tti]
    #TEST#...                         Create Dictionary    dlFdSchedData.pdcchCqi=6    ulFdSchedData.pdcchCqi=6
    Run Keyword If   ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_tti]    Run Keywords
    ...           Dated Log           > TTI export in csv is started
    ...    AND    Dated Log           > from json input ${path_to_json}
    ...    AND    Dated Log New Line    > for only parameters ${list_param_to_export}
    ...    AND    Dated Log New Line    > after applying filters ${dico_common_param_to_filter}
    ...    AND                        TtiAnalysisInterface.Export Specific Parameters To CSV and Dataframe    path_to_csv=${csv_tti_output}
    ...                                                             parameters=${list_param_to_export}
    ...                                                             common_parameters_filter=${dico_common_param_to_filter}
    ...                                                             specific_parameters_filter=${None}
    ...                                                             path_to_json=${path_to_json}    #TEST1#
    #TEST2#...                                                      specific_parameters_filter=${dico_specif_param_to_filter}
    ${status}   ${ret}   Run Keyword And Ignore Error    OperatingSystem.File Should Exist    ${csv_tti_output}
    Run Keyword If   ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_tti] and "${status}" != "PASS"    Run Keywords
    ...           Dated Log           > TTI export in csv is failed because ${csv_tti_output} is not found
    ...    AND    Should Be True      "${status}" == "PASS"
    Run Keyword If   ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_tti]    Run Keywords
    ...           Dated Log           > TTI export is passed in ${csv_tti_output}
    ...    AND    Dated Log           ----Post-conditions TTI Verification----
    # dlFdSchedData
    # case should be true: dlFdSchedData[aggregationLevel,2,pdcchPowerBoostType,POWERBOOSTDUECCE,dciFormat,DL_11] on first nrcell
    ${message}=    Set Variable       check if dlFdSchedData[aggregationLevel,2,pdcchPowerBoostType,POWERBOOSTDUECCE,dciFormat,DL_11] is true
    ${command}=                       Catenate    grep -iG ",50.0,.*,2.0,POWERBOOSTDUECCE,.*,DL_11," ${csv_tti_output}
    Run Keyword If   ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_tti]    CB012738 Execute Command And Check Content    cmd=${command}
    ...                                                             msg=${message}    expected_res=${True}
    # case should be true: dlFdSchedData[aggregationLevel,2,pdcchPowerBoostType,POWERBOOSTDUECCE,dciFormat,DL_11] on second nrcell
    ${message}=    Set Variable       check if dlFdSchedData[aggregationLevel,2,pdcchPowerBoostType,POWERBOOSTDUECCE,dciFormat,DL_11] is true
    ${command}=                       Catenate    grep -iG ",51.0,.*,2.0,POWERBOOSTDUECCE,.*,DL_11," ${csv_tti_output}
    Run Keyword If   ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_tti]    CB012738 Execute Command And Check Content    cmd=${command}
    ...                                                             msg=${message}    expected_res=${True}
    # case should be true: dlFdSchedData[aggregationLevel,2,pdcchPowerBoostType,NONE,dciFormat,DL_10_MSG2]
    ${message}=    Set Variable       check if dlFdSchedData[aggregationLevel,2,pdcchPowerBoostType,NONE,dciFormat,DL_10_MSG2] is true
    ${command}=                       Catenate    grep -iG ",2.0,NONE,.*,DL_10_MSG2," ${csv_tti_output}
    Run Keyword If   ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_tti]    CB012738 Execute Command And Check Content    cmd=${command}
    ...                                                             msg=${message}    expected_res=${True}
    # case should be true: dlFdSchedData[aggregationLevel,4,pdcchPowerBoostType,NONE,dciFormat,DL_11]
    ${message}=    Set Variable       check if dlFdSchedData[aggregationLevel,4,pdcchPowerBoostType,NONE,dciFormat,DL_11] is true
    ${command}=                       Catenate    grep -iG ",4.0,NONE,.*,DL_11," ${csv_tti_output}
    Run Keyword If   ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_tti]    CB012738 Execute Command And Check Content    cmd=${command}
    ...                                                             msg=${message}    expected_res=${True}
    # case should be false: dlFdSchedData[aggregationLevel,4,pdcchPowerBoostType,POWERBOOST.*,dciFormat,DL_11]
    ${message}=    Set Variable       check if dlFdSchedData[aggregationLevel,4,pdcchPowerBoostType,POWERBOOST.*,dciFormat,DL_11] is false
    ${command}=                       Catenate    grep -iG ",4.0,POWERBOOST.*,DL_11," ${csv_tti_output}
    Run Keyword If   ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_tti]    CB012738 Execute Command And Check Content    cmd=${command}
    ...                                                             msg=${message}    expected_res=${False}
    # case should be true: dlFdSchedData[aggregationLevel,2,pdcchPowerBoostType,POWERBOOSTDUECFG,dciFormat,DL_11]
    ${message}=    Set Variable       check if dlFdSchedData[aggregationLevel,2,pdcchPowerBoostType,POWERBOOSTDUECFG,dciFormat,DL_11] is false
    ${command}=                       Catenate    grep -iG ",2.0,POWERBOOSTDUECFG,.*,DL_11," ${csv_tti_output}
    Run Keyword If   ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_tti]    CB012738 Execute Command And Check Content    cmd=${command}
    ...                                                             msg=${message}    expected_res=${False}
#    #
#    # ulFdSchedData
#    # case should be true: ulFdSchedData[aggregationLevel,4,pdcchPowerBoostType,NONE,dciFormat,UL_01]
#    ${message}=    Set Variable       check if ulFdSchedData[aggregationLevel,4,pdcchPowerBoostType,NONE,dciFormat,UL_01] is true
#    ${command}=                       Catenate    grep -iG ",4.0,NONE,.*,UL_01," ${csv_tti_output}
#    Run Keyword If   ${capture_settings}[is_capture_tti]    CB012738 Execute Command And Check Content    cmd=${command}
#    ...                                                             msg=${message}    expected_res=${True}
#    # case should be false: ulFdSchedData[aggregationLevel,4,pdcchPowerBoostType,POWERBOOST.*,dciFormat,UL_01]
#    ${message}=    Set Variable       check if ulFdSchedData[aggregationLevel,4,pdcchPowerBoostType,POWERBOOST.*,dciFormat,UL_01] is false
#    ${command}=                       Catenate    grep -iG ",4.0,POWERBOOST.*,UL_01," ${csv_tti_output}
#    Run Keyword If   ${capture_settings}[is_capture_tti]    CB012738 Execute Command And Check Content    cmd=${command}
#    ...                                                             msg=${message}    expected_res=${False}
#    # case should be true: ulFdSchedData[aggregationLevel,2,pdcchPowerBoostType,POWERBOOSTDUECFG,dciFormat,UL_01]
#    ${message}=    Set Variable       check if ulFdSchedData[aggregationLevel,2,pdcchPowerBoostType,POWERBOOSTDUECFG,dciFormat,UL_01] is false
#    ${command}=                       Catenate    grep -iG ",2.0,POWERBOOSTDUECFG,.*,UL_01," ${csv_tti_output}
#    Run Keyword If   ${capture_settings}[is_capture_tti]    CB012738 Execute Command And Check Content    cmd=${command}
#    ...                                                             msg=${message}    expected_res=${False}
    #
    Dated Log New Line                ----Check Counter And KPI Constraints----
    Run Keyword If    ${param.pm_waiting_period} > 0    Wait PM availability    pmPeriodSec=300    #pmAvailDelay=60 #Sleep Until PM Availability
    # Waiting time added for observation and allow generation of multiple count periods
    FOR    ${iteration_pm}    IN RANGE    0    ${param.pm_waiting_period}
        Dated Log                     ----Handovers----
        Step    Perform N Handovers By Using meas_id 1 and event A3    list_elem=${list_ue}    param=${param}    n_handover=30
        Wait PM availability    pmPeriodSec=300    #pmAvailDelay=60
        ${pm_path}=    Run Keyword If    not ${isAic}    Counters.Collect PM files from BTS    ${LOG_PATH}/PM
        Run Keyword If    not ${isAic}
        ...               Step    Check Counter And KPI Constraints Common    pm_path=${pm_path}    test_name=${param.test_name}
    END
    # Deregister all the ue's
    FOR    ${current_elem}    IN    @{list_ue}
        Run Keyword If    "${current_elem.call_type}" == "SA"
        ...               Step        CallSetup.UE Deregister    id=${current_elem.ue}    ue_deregister_type=switch_off    by=ue
        ...                   depends=Ue Register And CRNTI Backup
        ...         ELSE
        ...               Step        CallSetup.UE Detach Enb    ueSetting=${current_elem}
        ...                   depends=UE Establish NSA Call
    END
    ${capture_cprt_input}=            Set Variable    ${LOG_PATH}/CPRT_NODE_GNB0.pcap
    ${capture_cprt_output}=           Set Variable    ${LOG_PATH}/CPRT/CPRT_NODE_GNB0_syscom.pcap
    Run Keyword If    ${AUTO_SAVE_DEBUG_DATA} and ${capture_settings}[is_capture_cprt]    Run Keywords
    ...           Dated Log           > capture_cprt_input= ${capture_cprt_input}
    ...    AND    Dated Log           > capture_cprt_output= ${capture_cprt_output}
    ...    AND                        Run    command=mkdir -p ${LOG_PATH}/CPRT
    ...    AND                        Run    command=tshark -r ${capture_cprt_input} -Y 'sctp and syscom' -w ${capture_cprt_output}
    ...    AND                        Run    command=rm -rf ${capture_cprt_input}
# --------------------------------------------------------------------------------------------------------------------------------------------------
