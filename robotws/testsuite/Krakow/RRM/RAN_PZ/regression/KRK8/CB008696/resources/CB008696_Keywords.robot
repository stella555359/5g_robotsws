*** Settings ***
Documentation
...    Author: Jacek Dziedzicki
...    Contact: Jacek.Dziedzicki@nokia.com
...    Description: Keywords for CB008696 Idle mode Traffic Steering from NR SA to LTE EN-DC carrier


Library      CB008696_Keywords.py
Library      TimerKeywords.py
Library      testsuite/Krakow/RRM/RAN_PZ/resources/pm_counters.py
Library      taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME    gnbcell
Library      taf.file.pack                                                WITH NAME    pack
Library      taf.converters.emil                                          WITH NAME    emil
Library      taf.rfrl.procedures.resources.python.vm                      WITH NAME    vm
Library      ta5g_pm_counters                                             WITH NAME    pmcount
Library      ute_fsmaccess
Resource     taf/rfrl/utilities/utf_lab/utf_lab.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     taf/rfrl/ue/robot/REAL_UE.robot
Resource     testsuite/Krakow/resources/RAN_PZ_KRK8/keywords.robot
Variables    CB008696_Variables.py
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Variables ***
${freq_priority_04a}        ${freq_priority_expected_04a}
${freq_priority_04b}        ${freq_priority_expected_04b}
${freq_priority_06a}        ${freq_priority_expected_06a}
${freq_priority_06b}        ${freq_priority_expected_06b}
${freq_priority_10}         ${freq_priority_expected_10}
${global_cell_id_301}       324038957
${sw_config_path}           commissionings/Krakow/swconfig/default_swconfig.txt
@{CUSTOM_ALLOWED_ALARMS}    Cell blocked    Not able to synchronize baseband bus

${ue_pc_address}=           PLKR-P08-UE02.intra.noklab.net
${ue_pc_login}=             pzkrk
${ue_pc_password}=          NokiaBts2003

${output_dirpath}=          ${LOG_PATH}/counters
${remote_host}=             ${tl.test_pcs[0].default_ssh_connection_details.addr}
${PCELL_MOID}=              PLMN-PLMN/MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-301

*** Keywords ***
Test Suite Setup
    logger.Log info To Console   --Start Suite Setup--\n
    tl_prep.Power On All Pdu Ports
    Restart Ue Proxy On Ue PC
    Verify if BTS and RMODs are Online
    Upload Swconfig On Classical Gnb      sw_config_path=${sw_config_path}
    Perform Commissioning on BTS    prefix_tag=CB008696_8SK111_TC04
    Perform Commissioning on BTS    prefix_tag=CB008696_8SK113    bts_id=${1}
    Update UTF Lab on UTE VM
    Start UTF Lab on UTE VM    timeout=${600}
    Common Suite Setup
    logger.Log info To Console   --Suite Setup DONE--\n

Test Suite Teardown
    logger.Log info To Console   --Start Test Suite Teardown--\n
    Stop UTF Lab on UTE VM    timeout=${240}
    Common Suite Teardown
    logger.Log info To Console   --Test Suite Teardown DONE--\n

Test Setup
    [Arguments]    ${prefix_tag}=None
    Run Keyword If    '${prefix_tag}'!='None'    Perform Commissioning on BTS    prefix_tag=${prefix_tag}
    ...  ELSE    logger.Log info To Console   -- No commissioning performed in Test Setup --\n
    keywords.Test Setup
    Block eNB and gNB Cells
    ue.Require Ue    UE_1      capabilities=REAL_ANDROID_UE
    logger.Log info To Console   --Require Ue DONE--\n
    ue.Detach Ue    UE_1

Block eNB and gNB Cells
    Run keyword And Ignore Error    gnbcell.Block Cell    cell_id=311
    Run keyword And Ignore Error    gnbcell.Block Cell    cell_id=3
    Run keyword And Ignore Error    gnbcell.Block Cell    cell_id=21
    Run keyword And Ignore Error    gnbcell.Block Cell    cell_id=41
    Run keyword And Ignore Error    gnbcell.Block Cell    bts_id=1  cell_id=31
    Run keyword And Ignore Error    gnbcell.Block Cell    bts_id=1  cell_id=221
    Run keyword And Ignore Error    gnbcell.Block Cell    bts_id=1  cell_id=23
    Run keyword And Ignore Error    gnbcell.Block Cell    bts_id=1  cell_id=63
    logger.Log info To Console   --Cells blocked--\n

Attach UE
    logger.Log info To Console   --Attach UE...--\n
    Sleep    60s
    ue.Attach Ue    UE_1    timeout=${60}
    ${timer_end_time}=    Start Timer    40
    ${5G_CELL}      ue.Get Ue Info    UE_1    cell_id
    Run Keyword If  '${5G_CELL}'=='${global_cell_id_301}'
    ...             logger.log_info_to_console    UE attached properly to the 5G cell: ${5G_CELL} (cell id)\n
    ...     ELSE    Fail And Log Error   msg= UE cannot attach to proper 5G cell
    Set Suite Variable    ${timer_end_time}    ${timer_end_time}
    [Teardown]    Run keyword And Ignore Error    Unblock eNB and gNB Cells

Unblock eNB and gNB Cells
    gnbcell.Unblock Cell    cell_id=311
    gnbcell.Unblock Cell    cell_id=3
    gnbcell.Unblock Cell    cell_id=21
    gnbcell.Unblock Cell    cell_id=41
    gnbcell.Unblock Cell    bts_id=1  cell_id=31
    gnbcell.Unblock Cell    bts_id=1  cell_id=221
    gnbcell.Unblock Cell    bts_id=1  cell_id=23
    gnbcell.Unblock Cell    bts_id=1  cell_id=63
    logger.Log info To Console   --Cells unblocked--\n
    Wait for cells to be OnAir

Wait for UE release and cell reselection
    [Arguments]    ${timeout}=${10}
    Wait For Timer    ${timer_end_time}
    logger.Log info To Console    Wait ${timeout}s for UE cell reselection ... and detach it\n
    Sleep      ${timeout}s
    Detach Ue    UE_1

Wait for next pm period
    [Arguments]    ${timeout}=${5}
    logger.Log info To Console   --Waiting for next pm period if ${timeout} minutes (or less) left--\n
    Wait for next pm period if little time left   min_minutes_left=${timeout}

Verify RRC Release and t320 timer and reselection
    [Arguments]    ${freq_priority}
    ...            ${t320}
#    ...            ${rat}
    ...            ${json_file}
    ${release_reseletion_list}=  CB008696_Keywords.expect_flow  ${json_file}
    ...                                                         display_filter=rrc    item=cellReselectionPriorities
    Verify rrc release message freq reselection priority    release_freq_prio_list=${release_reseletion_list}
    ...                                                     expected_freq_priority_list=${freq_priority}
    Run Keyword If    '${t320}' == 'timer not configured'
    ...    Verify that t320 timer not configured in rrc release message    file_path=${json_file}
    ...  ELSE
    ...    Verify that t320 timer configured in rrc release message    file_path=${json_file}
           ...                                                         expected_value=${t320}
#    Run Keyword If    '${rat}' == '4G'
#    ...    Verify if UE reselect to proper lte primary target    file_path=${file_path}
#           ...                                                   expected_freq_priority_list=${freq_priority}
#    ...    ELSE IF    '${rat}' == '5G'
#    ...    Verify if UE reselect to proper nr primary target    file_path=${file_path}
#           ...                                                  expected_freq_priority_list=${freq_priority}
#    logger.Log info To Console   --UE reselected to proper cell--\n

Extract Emil from UTF logs and decode to json
    [Documentation]    Extract Emil files from UTF logs and decode to json
    ...                :param utf_zip_file: path to the zip archive with UTF logs
    [Arguments]    ${utf_zip_file}    ${output_dir}=${LOG_PATH}/UTF_Logs_Extracted
    logger.Log info To Console    Extract Emil file from UTF logs and decode to json
    pack.Extract
    ...  path=${utf_zip_file}
    ...  output_dir=${output_dir}
    ...  .=*/*/*.5gm
    ${json_file}    Decode emil to json    ${output_dir}
    [return]    ${json_file}

Decode emil to json
    [Documentation]    Search for all Emil files in indicated directory and decode it to json via UTF
    ...                :param output_dir: path with extracted UTF logs
    [Arguments]    ${output_dir}
    ${utf}=  Create Dictionary
    ...    host=127.0.0.1
    ...    port=9443
    emil.create_emil_converter_for_source
    ...    name=emil_json
    ...    file_path_pattern=${output_dir}/*/*/*.5gm
    ...    dcap=${utf}
    ...    output_directory=${output_dir}
    emil.setup    emil_json
    emil.convert    emil_json
    emil.teardown    emil_json
    ${emil_to_json}    vm.find_files_in_directory_by_regex    ${output_dir}    .*\.json

    [Return]    ${output_dir}/${emil_to_json[-1]}

Verify in RRC messages that UE was candidate for EN-DC aware steering
    [Documentation]    Verify in json file, that in decoded RRC messages:
    ...                field "includeNR-DC true" is present in ueCapabilityEnquiry, ueCapabilityInformation
    ...                field cellReselectionPriorities is present in rrcRelease
    [Arguments]    ${json_file}
    expect_flow_uecap    ${json_file}    ${awaited_messages}    display_filter=rrc

Verify LTE Primary Target counters
    logger.Log info To Console    Verify counters for gNB Pcell
    Sleep    120s    waiting for properly set counters
    ${absolute_log_file_gnb_0}=    pmcount.Get Latest Unpacked Full Pm Counters File
                                   ...    output_dirpath=${output_dirpath}
                                   ...    remote_host=${remote_host}

    # M55124C07501:NRRCC_RRC_RELEASE_IMM_ENDC_LTE
    # M55124C00001:NRRCC_RRC_RELEASE_SENT
    ${counter_list} =    Create List        M55124C07501    M55124C00001
    verify_if_latest_pm_counters_from_the_list_are_bigger_than_the_given_value
    ...    counter_list=${counter_list}
    ...    value=0
    ...    local_moid=${PCELL_MOID}
    ...    filepath=${absolute_log_file_gnb_0}

    Verify Last Counters In File
    ...    M55124C07502    0      NRRCC_A4_MEAS_IMM_REC
    ...    M55157C00033    0      NRMOP_SA_PROFILE_SELECTED_01
    ...    M55124C07503    0      NRRCC_IMM_A4_TIMER_EXP
    ...    M55124C05501    0      NRRCC_RRC_RELEASE_IMM_NR
    ...    M55124C05502    0      NRRCC_RRC_RELEASE_IMM_LTE
    ...    local_moid=${PCELL_MOID}    file_path=${absolute_log_file_gnb_0}

Verify NR Primary Target counters
    logger.Log info To Console    Verify counters for gNB Pcell
    Sleep    120s    waiting for properly set counters
    ${absolute_log_file_gnb_0}=    pmcount.Get Latest Unpacked Full Pm Counters File
                                   ...    output_dirpath=${output_dirpath}
                                   ...    remote_host=${remote_host}

    # M55124C00001: NRRCC_RRC_RELEASE_SENT
    # M55124C05501: NRRCC_RRC_RELEASE_IMM_NR
    ${counter_list} =    Create List        M55124C00001    M55124C05501
    verify_if_latest_pm_counters_from_the_list_are_bigger_than_the_given_value
    ...    counter_list=${counter_list}
    ...    value=0
    ...    local_moid=${PCELL_MOID}
    ...    filepath=${absolute_log_file_gnb_0}

    Verify Last Counters In File
    ...    M55124C07501    0      NRRCC_RRC_RELEASE_IMM_ENDC_LTE
    ...    M55124C07502    0      NRRCC_A4_MEAS_IMM_REC
    ...    M55157C00033    0      NRMOP_SA_PROFILE_SELECTED_01
    ...    M55124C07503    0      NRRCC_IMM_A4_TIMER_EXP
    ...    M55124C05502    0      NRRCC_RRC_RELEASE_IMM_LTE
    ...    local_moid=${PCELL_MOID}    file_path=${absolute_log_file_gnb_0}

Verify Mobility Profile and Mode Mobility EN-DC aware steering counters
    logger.Log info To Console    Verify counters for gNB Pcell
    Sleep    120s    waiting for properly set counters
    ${absolute_log_file_gnb_0}=    pmcount.Get Latest Unpacked Full Pm Counters File
                                   ...    output_dirpath=${output_dirpath}
                                   ...    remote_host=${remote_host}

    # M55124C07501: NRRCC_RRC_RELEASE_IMM_ENDC_LTE
    # M55124C07502: NRRCC_A4_MEAS_IMM_REC
    # M55157C00033: NRMOP_SA_PROFILE_SELECTED_01
    # M55124C00001: NRRCC_RRC_RELEASE_SENT
    ${counter_list} =    Create List        M55124C07501    M55124C07502    M55157C00033    M55124C00001
    verify_if_latest_pm_counters_from_the_list_are_bigger_than_the_given_value
    ...    counter_list=${counter_list}
    ...    value=0
    ...    local_moid=${PCELL_MOID}
    ...    filepath=${absolute_log_file_gnb_0}

    Verify Last Counters In File
    ...    M55124C07503    0      NRRCC_IMM_A4_TIMER_EXP
    ...    M55124C05501    0      NRRCC_RRC_RELEASE_IMM_NR
    ...    M55124C05502    0      NRRCC_RRC_RELEASE_IMM_LTE
    ...    M55125C09006    0      NG_FLOW_REL_GNB_UNSPECIFIED
    ...    local_moid=${PCELL_MOID}    file_path=${absolute_log_file_gnb_0}

UTF Lab Stop Tracing
    [Documentation]     Description: Stops UTF Lab tracing
    ...                 param   trace_id (optional): stops trace by trace_id
    [Arguments]         ${trace_id}=None
    logger.Log info To Console    UTF Lab Stopping Tracing... (wait max 15 minutes)
    Wait until keyword succeeds  15 min  60s   utf_lab.stop_trace     trace_id=${trace_id}

UTF Lab Collect Results
    [Documentation]     Description: Collects the results of UTF Lab
    ...                 param   trace_id (optional): collects the results from the trace_id
    ...                 param   log_dir (optional): directory to collect the results in
    ...                 param   with_name (optional): the filename of collected zip archive
    [Arguments]         ${trace_id}=None    ${log_dir}=None     ${with_name}=None    ${timeout}=600
    ${results_path}    utf_lab.get_results    trace_id=${trace_id}    log_dir=${log_dir}
    ...                                       with_name=${with_name}    timeout=${timeout}
    utf_lab.delete_trace   trace_id=${trace_id}
    [Return]    ${results_path}    ${trace_id}
