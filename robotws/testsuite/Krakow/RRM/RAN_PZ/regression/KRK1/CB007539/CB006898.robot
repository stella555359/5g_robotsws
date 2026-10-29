*** Settings ***
Documentation
...    Author: Julia Luszcz, Marek Kobosko
...    Contact: julia.luszcz@nokia.com, marek.kobosko@nokia.com
...    Feature CB006898 PMQAP Profiles for NR -I


Library      taf.ue    WITH NAME    ue
Library      taf.rfrl.ue.parsers.tput_kpi_parsers.L1L2TracesKPIParser   WITH NAME      parser
Library      taf.rfrl.bts.devices.du.logs_collecting.basic_logs.EnbLog     WITH NAME   enb_log
Library      taf.rfrl.utilities.logger.custom_logger  WITH NAME    logger
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     taf/rfrl/bts/robot/logs_collecting.robot
Resource     taf/rfrl/ue/robot/REAL_UE.robot
Resource     taf/rfrl/bts/robot/gnb.robot
Resource     ./resources/CB006898_keywords.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Force Tags    STATE_SW_UPLOADED     CRT     PY36

Suite Setup     Common Suite Setup With OnAir Test Line Preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
Suite Teardown  Common Suite Teardown


*** Variables ***
${dist_name}=        MRBTS-{}/NRBTS-{}/NRPMRNL-1/NRPMQAP-1
${scf_dist_name}=        MRBTS-{}/NRBTS-{}/NRPMRNL-1
${expected_du_error}=   *AdminApiProcedureFailureException:*
${wrong_profile_value}=     0
${capabilities}=    REAL_UE
${alias}=    UE
${measurement_period}=    5min
${network_element_dist_name}=    MRBTS-{}/NRBTS-{}/NRCELL-1


${addition_req}=    x2ap.SgNBAdditionRequest_element
${addition_ack}=    x2ap.SgNBAdditionRequestAcknowledge_element
${release}=    x2ap.SgNBReleaseConfirm_element
${reconfiguration}=     x2ap.SgNBReconfigurationComplete_element
${release_reset}=     x2ap.ResetResponse_element
${transfer}=    x2ap.SNStatusTransfer_element

${COLLECT_LOGS_DURING_DATA_TRANSFER}    False

${file1}=  tcpdump1.pcap
${file2}=  tcpdump2.pcap
${file3}=  tcpdump3.pcap
${dir1}=   CB006898-D-SyVe_15_Counter_for_Nr_of_NSA_ERAB_Released_Initiated_by_MeNB
${dir2}=   CB006898-D-SyVe_19_Counter_for_Nr_of_NSA_ERABs_Released_Due_To_Normal_Causes_Initiated_by_SgNB
${dir3}=   CB006898-E-SyVe_23_NSA_Accessibility_counters_NX2CC_ERAB_ack_SN_status_Transfer_Message
${interface}=  br1

*** Test Cases ***
[1]CB006898-B_6_CB006898-B-SyVe_6_VCounter_for_Avg_Nr_of_NSA_Ues
    [Setup]    Run Keywords    Verify All Cell Status    AND
    ...        Prepare Ue for L3 Call    capabilities=${capabilities}
    logger.log_info_to_console    Activate measurements
    Set Test Variable    ${counter_id}    M55160C00001
    Create pmqap instance on DU  instance_id=1
    Set QCI profile on DU       ${dist_name}
    Activate feature on DU
    Activate Measurements    ${scf_dist_name}    ${measurement_period}
    ${counter_before_pm_interval}    Get Counter Value    counter_id=${counter_id}
    ...    full_path=CELLS/NRCELL-1/NRPMQAP-1/ACCNQ/AVE_NUMBER_OF_NSA_USERS_PMQAP
    Perform Attach and Verify UE Properly Attached    alias=UE
    logger.log_info_to_console    Wait for measurements
    gnb_counter.Wait for PM measurements    interval=${measurement_period}   measurements=1
    ${counter_after_pm_interval}    Get Counter Value    counter_id=${counter_id}
    ...    full_path=CELLS/NRCELL-1/NRPMQAP-1/ACCNQ/AVE_NUMBER_OF_NSA_USERS_PMQAP
    logger.log_info_to_console    Validate measurements
    Should Be True    ${counter_before_pm_interval}<${counter_after_pm_interval}
    [Teardown]    Run Keywords    Deactivate Measurements and Dettach UE   alias=${alias}    AND
    ...           Remove PMQAP instances

[1]CB006898-B_7_CB006898-B-SyVe_7_Counter_for_Peak_Nr_of_NSA_Ues
    [Setup]    Run Keywords    Verify All Cell Status    AND
    ...        Prepare Ue for L3 Call    capabilities=${capabilities}
    logger.log_info_to_console    Activate measurements
    Set Test Variable    ${counter_id}    M55160C00003
    Create pmqap instance on DU  instance_id=1
    Set QCI profile on DU       ${dist_name}
    Activate feature on DU
    Activate ACCNQ measurement on DU    dist_name=${scf_dist_name}    interval=${measurement_period}
    logger.log_info_to_console    Wait for pm period
    gnb_counter.Wait for next PM period    interval=15
    logger.log_info_to_console    Validate measurement
    ${counter_before_pm_interval}    Get Counter Value    counter_id=${counter_id}
    ...    full_path=CELLS/NRCELL-1/NRPMQAP-1/ACCNQ/PEAK_NUMBER_OF_NSA_USERS_PMQAP
    Should Be Equal As Numbers    ${counter_before_pm_interval}    0
    Perform Attach and Verify UE Properly Attached    alias=${alias}
    logger.log_info_to_console    Wait for measurements
    gnb_counter.Wait for next PM period    interval=5
    ${counter_after_pm_interval}    Get Counter Value    counter_id=${counter_id}
    ...    full_path=CELLS/NRCELL-1/NRPMQAP-1/ACCNQ/PEAK_NUMBER_OF_NSA_USERS_PMQAP
    Should Be Equal As Numbers    ${counter_after_pm_interval}    1
    [Teardown]    Run Keywords    Deactivate Measurements and Dettach UE   alias=${alias}    AND
    ...     Remove PMQAP instances

[1]CB006898-D_15_CB006898-D-SyVe_15_Counter_for_Nr_of_NSA_ERAB_Released_Initiated_by_MeNB
    [Tags]
    ...     RAN_5G__WITH__SBTS00__WITH__CLOUD_5G_CLASSICAL_ANDROID_ASOE_AWEUA
    ...     RAN_5G__WITH__SBTS22R4__WITH__CLOUD_5G_CLASSICAL_ANDROID_ASOE_AWEUA
    [Setup]    Run Keywords    Common Preconditions    AND
    ...        Verify All Cell Status    AND
    ...        Prepare Ue for L3 Call    capabilities=${capabilities}
    Set Test Variable    ${counter_id}    M55112C06001
    Create PMQAP profiles
    Activate X2CCQ measurement on DU    dist_name=${scf_dist_name}    interval=15min
    logger.log_info_to_console    Wait for measurements and validate them
    gnb_counter.Wait for next PM period    interval=15
    ${counter_value_before}    Get Counter Value    counter_id=${counter_id}
    ...    full_path=CELLS/NRCELL-1/NX2CC/NX2CC_RAB_REL_ATT_MENB
    Should Be Equal As Numbers    ${counter_value_before}    0
    logger.log_info_to_console    Start tcpdump
    enb_log.start_tcpdump_on_smod    interface=${interface}    capture_file=${file1}    background=${True}
    Perform Attach and Verify UE Properly Attached    alias=${alias}
    Sleep   40s
    enb_log.stop_tcpdump_on_smod
    ${directory}=   Get tcpdump dir   sub_dir=${dir1}   log_file_name=${file1}
    ${filtered}=    parser.verify_x2ap_values    pcap_dir=${directory}    filter_expression=${addition_req}
    ${filtered}=    parser.verify_x2ap_values    pcap_dir=${directory}    filter_expression=${addition_ack}
    ${filtered}=    parser.verify_x2ap_values    pcap_dir=${directory}    filter_expression=${reconfiguration}
    enb_log.start_tcpdump_on_smod    interface=${interface}    capture_file=${file1}    background=${True}
    Sleep   40s
    Lock X2 link
    logger.log_info_to_console    Wait for measurements and validate them
    gnb_counter.Wait for next PM period    interval=15
    ${counter_value_after}    Get Counter Value    counter_id=${counter_id}
    ...    full_path=CELLS/NRCELL-1/NX2CC/NX2CC_RAB_REL_ATT_MENB
    Should Be Equal As Numbers    ${counter_value_after}    1
    enb_log.stop_tcpdump_on_smod
    ${directory}=   Get tcpdump dir   sub_dir=${dir1}   log_file_name=${file1}
    ${filtered}=    parser.verify_x2ap_values      pcap_dir=${directory}    filter_expression=${release_reset}
    [Teardown]    Run Keywords    Deactivate Measurements and Dettach UE    AND
    ...     Remove PMQAP instances    AND
    ...     Unlock X2 link     AND
    ...     Wait Until Keyword Succeeds    200s    30s    Verify All Cell Status    AND
    ...     Common Postconditions

[1]CB006898-D_19_CB006898-D-SyVe_19_Counter_for_Nr_of_NSA_ERABs_Released_Due_To_Normal_Causes_Initiated_by_SgNB
    [Tags]
    ...     RAN_5G__WITH__SBTS00__WITH__CLOUD_5G_CLASSICAL_ANDROID_ASOE_AWEUA
    ...     RAN_5G__WITH__SBTS22R4__WITH__CLOUD_5G_CLASSICAL_ANDROID_ASOE_AWEUA
    [Setup]    Run Keywords    Common Preconditions    AND
    ...        Wait Until Keyword Succeeds    300s    10s    Verify All Cell Status    AND
    ...        Prepare Ue for L3 Call    capabilities=${capabilities}
    Set Test Variable    ${counter_id}    M55162C00005
    Create PMQAP profiles
    logger.log_info_to_console    Wait for measurements and validate
    Activate X2CCQ measurement on DU    dist_name=${scf_dist_name}    interval=15min
    gnb_counter.Wait for next PM period    interval=15
    ${counter_value_before}    Get Counter Value    counter_id=${counter_id}
    ...    full_path=CELLS/NRCELL-1/NRPMQAP-1/X2CCQ/NX2CC_RAB_REL_NORM_SGNB_PMQAP
    Should Be Equal As Numbers    ${counter_value_before}    0
    enb_log.start_tcpdump_on_smod    interface=${interface}    capture_file=${file2}    background=${True}
    logger.log_info_to_console    Cause UE inactivity
    Cause UE inactivity
    Perform Attach and Verify UE Properly Attached    alias=${alias}
    Sleep   60s
    enb_log.stop_tcpdump_on_smod
    ${directory}=   Get tcpdump dir   sub_dir=${dir2}   log_file_name=${file2}
    ${filtered}=    parser.verify_x2ap_values    pcap_dir=${directory}    filter_expression=${addition_ack}
    ${filtered}=    parser.verify_x2ap_values    pcap_dir=${directory}    filter_expression=${transfer}
    logger.log_info_to_console    tcpdump in ${directory}
    gnb_counter.Wait for next PM period    interval=15
    logger.log_info_to_console    Wait for measurements and validate
    ${counter_value_after}    Get Counter Value    counter_id=${counter_id}
    ...    full_path=CELLS/NRCELL-1/NRPMQAP-1/X2CCQ/NX2CC_RAB_REL_NORM_SGNB_PMQAP
    Should Be Equal As Numbers    ${counter_value_after}    1
    ${filtered}=    parser.verify_x2ap_values    pcap_dir=${directory}    filter_expression=${release}
    [Teardown]    Run Keywords      Deactivate Measurements and Dettach UE      AND
    ...           Fix UE inactivity     AND
    ...           Remove PMQAP instances     AND
    ...           Common Postconditions

[1]CB006898-E_23_CB006898-E-SyVe_23_NSA_Accessibility_counters_NX2CC_ERAB_ack_SN_status_Transfer_Message
    [Tags]
    ...     RAN_5G__WITH__SBTS00__WITH__CLOUD_5G_CLASSICAL_ANDROID_ASOE_AWEUA
    ...     RAN_5G__WITH__SBTS22R4__WITH__CLOUD_5G_CLASSICAL_ANDROID_ASOE_AWEUA
    [Setup]    Run Keywords    Common Preconditions    AND
    ...        Verify All Cell Status    AND
    ...        Prepare Ue for L3 Call    capabilities=${capabilities}
    Set Test Variable    ${counter_id}    M55162C00009
    Create PMQAP profiles
    logger.log_info_to_console    Wait for measurements and validate
    Activate X2CCQ measurement on DU    dist_name=${scf_dist_name}    interval=15min
    gnb_counter.Wait for next PM period    interval=15
    ${counter_value_before}    Get Counter Value    counter_id=${counter_id}
    ...    full_path=CELLS/NRCELL-1/NRPMQAP-1/X2CCQ/NX2CC_RAB_SETUP_SN_PMQAP
    Should Be Equal As Numbers    ${counter_value_before}    0
    enb_log.start_tcpdump_on_smod    interface=${interface}    capture_file=${file3}    background=${True}
    Perform Attach and Verify UE Properly Attached    alias=${alias}
    Sleep   60s
    enb_log.stop_tcpdump_on_smod
    ${directory}=   Get tcpdump dir   sub_dir=${dir3}   log_file_name=${file3}
    ${filtered}=    parser.verify_x2ap_values    pcap_dir=${directory}    filter_expression=${addition_req}
    ${filtered}=    parser.verify_x2ap_values    pcap_dir=${directory}    filter_expression=${addition_ack}
    ${filtered}=    parser.verify_x2ap_values    pcap_dir=${directory}    filter_expression=${reconfiguration}
    logger.log_info_to_console    Wait for measurements and validate
    gnb_counter.Wait for next PM period    interval=15
    ${counter_value_after}    Get Counter Value    counter_id=${counter_id}
    ...    full_path=CELLS/NRCELL-1/NRPMQAP-1/X2CCQ/NX2CC_RAB_SETUP_SN_PMQAP
    Should Be Equal As Numbers    ${counter_value_after}    1
    [Teardown]    Run Keywords      Deactivate Measurements and Dettach UE      AND
    ...           Remove PMQAP instances    AND
    ...           Common Postconditions

*** Keywords ***
Deactivate Measurements and Dettach UE
    [Arguments]    ${alias}=UE
    Deactivate Measurements    ${scf_dist_name}
    ue.Detach Ue    ${alias}
