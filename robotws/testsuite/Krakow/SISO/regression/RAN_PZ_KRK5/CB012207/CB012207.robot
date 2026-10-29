*** Settings ***
Documentation
...   Test suite for regression testing of feature CB012207
...   author: Mateusz Bugaj, Daniel Kulaga, Pawel Grabania
...   contact: mateusz.bugaj@nokia.com, daniel.kulaga@nokia.com, pawel.grabania@nokia.com

Resource     taf/rfrl/bts/robot/common/gnb_bbu.robot
Resource     taf/rfrl/bts/robot/common/gnb_cell.robot
Resource     taf/rfrl/bts/robot/common/gnb_counter.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     testsuite/Krakow/resources/RAN_VRF_KRK5/robot/call_procedure/call_procedure_keywords.robot
Resource     ./resources/common_keywords.robot
Library      taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations                       WITH NAME    gnb_cells
Library      taf.rfrl.utilities.utf_lab.ute_utf_lab.UteUtfLab                                WITH NAME    utf_lab
Library      taf.rfrl.utilities.logger.custom_logger                                         WITH NAME    logger
Library      taf.ue                                                                          WITH NAME    ue
Library      testsuite.Krakow.resources.RAN_VRF_KRK5.python.bts_operations.bts_operations    WITH NAME    bts_oper
Library      testsuite.Krakow.resources.RAN_VRF_KRK5.python.bts_operations.bts_additional_logs.bts_additional_logs.BtsAdditionalLogs
...    WITH NAME    bts_additional_logs
Library      testsuite.Krakow.resources.RAN_VRF_KRK5.python.bts_operations.bts_links_operations.bts_links_operations
...    WITH NAME    bts_links
Library      testsuite.Krakow.resources.RAN_VRF_KRK5.python.bts_operations.bts_pm_counters.bts_pm_counters
...    WITH NAME    pm_counters
Library      testsuite.Krakow.SISO.regression.RAN_PZ_KRK5.CB012207.resources.new_ue_operations.NewUeOperations
...    WITH NAME    new_ue_oper
Library      ./resources/resources.py

Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    ./resources/common_variables.py

Suite Setup       Common Suite Setup With OnAir Test Line Preparation    upload_swconfig_to_neighbour=${True}
...                                                                      should_5G_neighbour_be_changed=${True}
...                                                                      list_of_additional_allowed_alarms=@{ALARMS_LIST}
Suite Teardown    Common Suite Teardown

*** Variables ***
${library}    testsuite.Krakow.SISO.regression.RAN_PZ_KRK5.CB012207.resources.new_ue_operations.NewUeOperations
${ue_capabilities}    REAL_UE

@{mcshark_plugins}    mcshark
@{nsetap_plugins}     nsetapx    nsetap
${profile}            /testsuite/Krakow/SISO/regression/RAN_PZ_KRK5/CB012207/resources/wireshark_profile/pcmd_profile
${deltas_dir}         /testsuite/Krakow/SISO/regression/RAN_PZ_KRK5/CB012207/resources/deltas

@{tput_CellID}        NRCELL-901
@{bidirect_CellID}    NRCELL-801_2
@{ecid_CellID}        NRCELL-801_4
@{releases}           SBTS25R3    SBTS25R2

@{ALARMS_LIST}                  No Xn link available

*** Test Cases ***
CB012207__5GC001347_5G002015_DlPtrs_on_log_tput_comparison_dlDMRSAdditionalPosition_off_on
    [Setup]    Actions before test      alarms_for_test=${additional_alarms}[scf_load]
    Perform Full Commissioning on Classical gNB    bts_id=${0}    prefix_tag=DMRS
    Perform Full Commissioning on Classical gNB    bts_id=${1}    prefix_tag=DMRS
    bts_additional_logs.configure_wireshark_plugins    plugins=@{mcshark_plugins}
    ${case}=    Set Variable    dlDMRS_no_additional
    bts_oper.load_bts_delta_from_file    delta_json_file=${deltas_dir}/${case}.json
    ...                                  bts_id=0    delta_purpose=Change dlDMRSAdditionalPosition to `No additional DMRS`
    ${additional_logs_dir}=    bts_additional_logs.create_dir_for_additional_logs
    &{additional_params_during}=    Create Dictionary    logs_dir=${additional_logs_dir}/${case}    period=${0.1}
    ...                                                  bts_id=${0}    wait_time=${30}
    &{additional_params}=    Create Dictionary    during=${additional_params_during}
    &{additional_action}=    Create Dictionary    during=collect_bip_logs
    ${traffic_matrix}    Convert To Dictionary    ${TPUT_MATRIX}
    Run Keyword And Continue On Failure
    ...    Call To Selected Cells    cells_list=${tput_CellID}    duration=120s    traffic_matrix=${traffic_matrix}
    ...    ue_capabilities=${ue_capabilities}    deviation=10%    additional_action=${additional_action}
    ...    additional_action_params=${additional_params}    library_path=${library}    reboot_ue=${False}
    ${messages}=    Convert To List    ${bip_messages}[${case}]
    ${folders_with_bips}=    resources.get_folders_with_biplogs    case=${case}    logs_dir=${additional_logs_dir}
    resources.verify_bip_logs    logs_dir=${additional_logs_dir}/${folders_with_bips}[DL_tput]    bip_messages=${messages}
    Remove From List    ${messages}    -1
    resources.verify_bip_logs    logs_dir=${additional_logs_dir}/${folders_with_bips}[UL_tput]    bip_messages=${messages}

    ${case}=    Set Variable    dlDMRS_one_additional
    bts_oper.load_bts_delta_from_file    delta_json_file=${deltas_dir}/${case}.json
    ...                                  delta_purpose=Change dlDMRSAdditionalPosition to `One additional DMRS`
    BuiltIn.Sleep    60s
    &{additional_params_during}=    Create Dictionary    logs_dir=${additional_logs_dir}/${case}    period=${0.1}
    ...                                                  bts_id=${0}    wait_time=${30}
    &{additional_params}=    Create Dictionary    during=${additional_params_during}
    &{additional_action}=    Create Dictionary    during=collect_bip_logs
    Run Keyword And Continue On Failure
    ...    Call To Selected Cells    cells_list=${tput_CellID}    duration=120s    traffic_matrix=${traffic_matrix}
    ...    ue_capabilities=${ue_capabilities}    deviation=10%    additional_action=${additional_action}
    ...    additional_action_params=${additional_params}    library_path=${library}    run_num=2    reboot_ue=${True}
    ${messages}=    Convert To List    ${bip_messages}[${case}]
    ${folders_with_bips}=    resources.get_folders_with_biplogs    case=${case}    logs_dir=${additional_logs_dir}
    resources.verify_bip_logs    logs_dir=${additional_logs_dir}/${folders_with_bips}[DL_tput]    bip_messages=${messages}
    Remove From List    ${messages}    -1
    resources.verify_bip_logs    logs_dir=${additional_logs_dir}/${folders_with_bips}[UL_tput]    bip_messages=${messages}
    bts_additional_logs.remove_wireshark_plugins
    bts_oper.load_bts_delta_from_file    delta_json_file=${deltas_dir}/dlDMRS_auto.json
    ...                                  delta_purpose=Change dlDMRSAdditionalPosition to `Automatic DMRS`
    bts_additional_logs.remove_wireshark_plugins
    Wait Until Keyword Succeeds    600 sec    15 sec    gnb_cells.Verify All Cells are OnAir
    [Teardown]    Actions after test

CB012207__5GC001347_5G002015_UlPtrs_on_log_tput_comparison_ulDMRSAdditionalPosition_off_on
    [Setup]    Actions before test      alarms_for_test=${additional_alarms}[scf_load]
    Perform Full Commissioning on Classical gNB    bts_id=${0}    prefix_tag=DMRS
    Perform Full Commissioning on Classical gNB    bts_id=${1}    prefix_tag=DMRS
    bts_additional_logs.configure_wireshark_plugins    plugins=@{mcshark_plugins}
    ${case}=    Set Variable    ulDMRS_no_additional
    bts_oper.load_bts_delta_from_file    delta_json_file=${deltas_dir}/${case}.json
    ...                                  delta_purpose=Change ulDMRSAdditionalPosition to `No additional DMRS`
    ${additional_logs_dir}=    bts_additional_logs.create_dir_for_additional_logs
    &{additional_params_during}=    Create Dictionary    logs_dir=${additional_logs_dir}/${case}    period=${0.1}
    ...                                                  bts_id=${0}    wait_time=${30}
    &{additional_params}=    Create Dictionary    during=${additional_params_during}
    &{additional_action}=    Create Dictionary    during=collect_bip_logs
    ${traffic_matrix}    Convert To Dictionary    ${TPUT_MATRIX}
    Run Keyword And Continue On Failure
    ...    Call To Selected Cells    cells_list=${tput_CellID}    duration=120s    traffic_matrix=${traffic_matrix}
    ...    ue_capabilities=${ue_capabilities}    deviation=10%    additional_action=${additional_action}
    ...    additional_action_params=${additional_params}    library_path=${library}    reboot_ue=${True}
    ${messages}=    Convert To List    ${bip_messages}[${case}]
    ${folders_with_bips}=    resources.get_folders_with_biplogs    case=${case}    logs_dir=${additional_logs_dir}
    resources.verify_bip_logs    logs_dir=${additional_logs_dir}/${folders_with_bips}[DL_tput]    bip_messages=${messages}
    Remove From List    ${messages}    -1
    resources.verify_bip_logs    logs_dir=${additional_logs_dir}/${folders_with_bips}[UL_tput]    bip_messages=${messages}

    ${case}=    Set Variable    ulDMRS_one_additional
    bts_oper.load_bts_delta_from_file    delta_json_file=${deltas_dir}/${case}.json
    ...                                  delta_purpose=Change ulDMRSAdditionalPosition to `One additional DMRS`
    BuiltIn.Sleep    60s
    &{additional_params_during}=    Create Dictionary    logs_dir=${additional_logs_dir}/${case}    period=${0.1}
    ...                                                  bts_id=${0}    wait_time=${30}
    &{additional_params}=    Create Dictionary    during=${additional_params_during}
    &{additional_action}=    Create Dictionary    during=collect_bip_logs
    Run Keyword And Continue On Failure
    ...    Call To Selected Cells    cells_list=${tput_CellID}    duration=120s    traffic_matrix=${traffic_matrix}
    ...    ue_capabilities=${ue_capabilities}    deviation=10%    additional_action=${additional_action}
    ...    additional_action_params=${additional_params}    library_path=${library}    run_num=2    reboot_ue=${True}
    ${messages}=    Convert To List    ${bip_messages}[${case}]
    ${folders_with_bips}=    resources.get_folders_with_biplogs    case=${case}    logs_dir=${additional_logs_dir}
    resources.verify_bip_logs    logs_dir=${additional_logs_dir}/${folders_with_bips}[DL_tput]    bip_messages=${messages}
    Remove From List    ${messages}    -1
    resources.verify_bip_logs    logs_dir=${additional_logs_dir}/${folders_with_bips}[UL_tput]    bip_messages=${messages}
    bts_additional_logs.remove_wireshark_plugins
    bts_oper.load_bts_delta_from_file    delta_json_file=${deltas_dir}/ulDMRS_auto.json
    ...                                  delta_purpose=Change ulDMRSAdditionalPosition to `Automatic DMRS`
    bts_additional_logs.remove_wireshark_plugins
    Wait Until Keyword Succeeds    600 sec    15 sec    gnb_cells.Verify All Cells are OnAir
    [Teardown]    Actions after test

CB012207__CB008196_A2_Connection_establishment_triggered_by_Xn_Handover_Request_message
    [Setup]    Actions before test    alarms_for_test=${additional_alarms}[scf_load]
    Perform Full Commissioning on Classical gNB    bts_id=${0}    prefix_tag=Periodic_measurements
    Perform Full Commissioning on Classical gNB    bts_id=${1}    prefix_tag=Periodic_measurements
    Lock gNB Cell    cell_id=${3}    gnb_id=${1}
    logger.log_info to console     Waiting for next PM period    log_hierarchy=${2}
    gnb_counter.Wait for next PM period
    ${traffic_matrix}    Convert To Dictionary    ${TPUT_MATRIX}
    ${emil_file}=    new_ue_oper.perform_inter_bts_handover_with_emil_logs
    ...                           source_cell_id=NRCELL-801    target_cell_id=NRCELL-901    traffic_matrix=${traffic_matrix}
    ...                           ue_capabilities=${ue_capabilities}
    logger.log_info_to_console    emil_file=${emil_file}
    resources.verify_emil_logs_from_xn_handover    dcap_host=10.84.182.222
    ...                                            emil_filter="User data"="NRRRCMeasurementReport"
    ...                                            zip_with_emil_log=${emil_file}
    Unlock gNB Cell    cell_id=${3}    gnb_id=${1}
    logger.log_info to console     Waiting for next PM period    log_hierarchy=${2}
    gnb_counter.Wait for next PM period
    BuiltIn.Sleep    60s
    pm_counters.verify_counters    counters=${COUNTERS}[Periodic_measurements_target]
    pm_counters.verify_counters    counters=${COUNTERS}[Periodic_measurements_source]    bts_id=1
    [Teardown]    Actions after test

CB012207_5GC000637_Incoming_NG_RAN_Node_Configuration_Update_procedure
    [Setup]    Actions before test    alarms_for_test=${additional_alarms}[scf_load]
    Perform Full Commissioning on Classical gNB    bts_id=${0}    prefix_tag=${None}
    Perform Full Commissioning on Classical gNB    bts_id=${1}    prefix_tag=${None}
    logger.log_info to console     Waiting for next PM period    log_hierarchy=${2}
    gnb_counter.Wait for next PM period
    ${capture_file}=    Set Variable    creation_of_xnlink_bh_log.pcap
    bts_additional_logs.start_collect_bts_pcap    capture_file=${capture_file}
    bts_oper.load_bts_delta_from_file    delta_json_file=${deltas_dir}/adding_xnlink.json
    ...                                  bts_id=1    delta_purpose=Add xnLink
    Wait Until Keyword Succeeds    300 sec    10 sec
    ...    bts_links.verify_xn_link_status    ip_addr=10.84.150.220    status=available    bts_id=1
    ${capture_dir}=    bts_additional_logs.stop_collect_bts_pcap    capture_file=${capture_file}
    bts_additional_logs.verify_messages_in_pcap    pcap_file=${capture_dir}/${capture_file}
    ...                                            messages=${pcap_messages}[xnlink_creation]    log_type=bts_pcap

    ${capture_file}=    Set Variable    removing_cell_bh_log.pcap
    bts_additional_logs.start_collect_bts_pcap    capture_file=${capture_file}
    bts_oper.load_bts_delta_from_file    delta_json_file=${deltas_dir}/remove_cell.json
    ...                                  bts_id=0    delta_purpose=Remove cell from BTS1
    ${capture_dir}=    bts_additional_logs.stop_collect_bts_pcap    capture_file=${capture_file}
    bts_additional_logs.verify_messages_in_pcap       pcap_file=${capture_dir}/${capture_file}
    ...                                               messages=${pcap_messages}[removing_cell]    log_type=bts_pcap

    ${release}=    Get gNB Sw Release Name
    ${capture_file}=    Set Variable    adding_cell_bh_log.pcap
    bts_additional_logs.start_collect_bts_pcap    capture_file=${capture_file}
    ${release}=    Get gNB Sw Release Name
    ${release}=    Set Variable If    '${release}' not in ${releases}    SBTS00    ${release}
    bts_oper.load_bts_delta_from_file    delta_json_file=${deltas_dir}/add_cell_${release}.json
    ...                                  bts_id=0    delta_purpose=Add cell to BTS1
    Wait for cell to be OnAir    bts_id=0    cell_id=4
    ${capture_dir}=    bts_additional_logs.stop_collect_bts_pcap    capture_file=${capture_file}
    bts_additional_logs.verify_messages_in_pcap       pcap_file=${capture_dir}/${capture_file}
    ...                                               messages=${pcap_messages}[adding_cell]    log_type=bts_pcap

    logger.log_info to console     Waiting for next PM period    log_hierarchy=${2}
    gnb_counter.Wait for next PM period
    BuiltIn.Sleep    60s
    pm_counters.verify_counters    counters=${COUNTERS}[Xn_counters_76192]    bts_id=1
    pm_counters.verify_counters    counters=${COUNTERS}[Xn_counters_76220]
    bts_oper.load_bts_delta_from_file    delta_json_file=${deltas_dir}/remove_xnlink.json
    ...                                  bts_id=1    delta_purpose=Remove xnLink
    BuiltIn.Sleep    60s
    [Teardown]    Actions after test

CB012207__5GC000704_IFHO_C_EC7_Xn_gNB_is_closed_after_Xn_gNB_link_configuration_becomes_locked
    [Setup]    Actions before test    alarms_for_test=${additional_alarms}[scf_load]
    Perform Full Commissioning on Classical gNB    bts_id=${1}    prefix_tag=XNlink_locked
    Perform Full Commissioning on Classical gNB    bts_id=${0}    prefix_tag=XNlink_locked
    pm_counters.check_time_to_next_pm_period    time_buffer=600
    ${traffic_matrix}    Convert To Dictionary    ${TPUT_MATRIX}
    new_ue_oper.perform_xn_handover    source_cell_id=NRCELL-801    source_bts_id=${1}    target_cell_id=NRCELL-901
    ...                                traffic_matrix=${traffic_matrix}    ue_capabilities=${ue_capabilities}
    logger.log_info to console     Waiting for next PM period    log_hierarchy=${2}
    gnb_counter.Wait for next PM period
    BuiltIn.Sleep    60s
    pm_counters.verify_counters    counters=${COUNTERS}[Xnlink_locked]    bts_id=1
	[Teardown]    Actions after test
