*** Settings ***
Documentation
...    Author: Julia Luszcz, Pawel Nowak
...    Contact: julia.luszcz@nokia.com, pawel.5.nowak@nokia.com
...    Feature CB006898 PMQAP Profiles for NR -I


Library     taf.ue    WITH NAME    ue
Library      taf.rfrl.ue.parsers.tput_kpi_parsers.L1L2TracesKPIParser   WITH NAME      parser

Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    taf/rfrl/bts/robot/logs_collecting.robot
Resource    taf/rfrl/ue/robot/REAL_UE.robot
Resource    taf/rfrl/bts/robot/gnb.robot
Resource    ./resources/CB006898_keywords.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Force Tags      STATE_GNB_NOT_COMMISSIONED       PY36       CRT
...     RAN_5G_TDD__WITH__pDU22R2__WITH__CLOUD_5G_ANDROID_ASOD_AEUD_ENB_BRANCH

Suite Setup     Common Suite Setup With Commissioning
Suite Teardown  Common Suite Teardown


*** Variables ***
${dist_name}=        MRBTS-{}/NRBTS-{}/NRPMRNL-1/NRPMQAP-1

${expected_du_error}=   *AdminApiProcedureFailureException:*
${expected_cu_error}=  *TimeoutException: Message:*
${wrong_profile_value}=     0
${capabilities}=    SAMSUNG
${alias}=    UE
${measurement_period}=    5min
${network_element_dist_name}=    MRBTS-{}/NRBTS-{}/NRCELL-1


${reconfiguration}=   x2ap.SgNBReconfigurationComplete_element
${addition_req}=    x2ap.SgNBAdditionRequest_element
${addition_ack}=    x2ap.SgNBAdditionRequestAcknowledge_element
${release}=    x2ap.SgNBReleaseConfirm_element
${release_reset}=     x2ap.ResetResponse_element
${transfer}=    x2ap.SNStatusTransfer_element

${COLLECT_LOGS_DURING_DATA_TRANSFER}    False

${file}=  tcpdump.pcap
${interface}=  CPIF

*** Test Cases ***
[1]CB006898-A_2_CB006898-A-SyVe_2_Activation_of_NRPMQAP_Profiles_with_measurements
    Create PMQAP profiles
    Activate Measurements
    [Teardown]  run keywords  Remove PMQAP instances        AND
    ...     Deactivate Measurements

[1]CB006898-A_4_CB006898-A-SyVe_4_PMQAP_range_validation
    Create PMQAP profiles
    Run Keyword and Expect Error    ${expected_du_error}     Set ARP profile on DU  dist_name=${dist_name}
    ...     value=${wrong_profile_value}
    Run Keyword and Expect Error    ${expected_du_error}     Set QCI profile on DU  dist_name=${dist_name}
    ...     value=${wrong_profile_value}
    Set ARP profile on DU  dist_name=${dist_name}   value=1
    Set QCI profile on DU  dist_name=${dist_name}   value=5
    Run Keyword and Expect Error    ${expected_cu_error}     Set ARP profile on CU  instance_id=1
    ...     value=${wrong_profile_value}
    Run Keyword and Expect Error    ${expected_cu_error}     Set QCI profile on CU  instance_id=1
    ...     value=${wrong_profile_value}
    Set ARP profile on CU   instance_id=1
    Set QCI profile on CU   instance_id=1
    [Teardown]  Remove PMQAP instances

[1]CB006898-B_6_CB006898-B-SyVe_6_VCounter_for_Avg_Nr_of_NSA_Ues
    [Setup]    Run Keywords    Verify All Cell Status    AND
    ...        Prepare Ue for L3 Call    capabilities=${capabilities}
    Set Test Variable    ${counter_id}    M55160C00001
    Create pmqap instance on DU  instance_id=1
    Set QCI profile on DU       ${dist_name}
    Create pmqap instance on CU     instance_id=1
    Set QCI profile on CU       instance_id=1
    Activate feature on DU
    Activate feature on CU
    Activate Measurements
    ${counter_before_pm_interval}    Get CU PM Counter Value    counter_id=${counter_id}
    ...    network_element_dist_name=${network_element_dist_name}
    Perform Attach and Verify UE Properly Attached    alias=UE
    ${CU_PM_interval}    Get CU Parameter Value via GUI    dist_name=MRBTS-{}/NRBTS-{}/NRPMRNL-1
    ...    param_name=Measurement interval for X2 Connection Control NRPMQAP
    ...    param_abbr=miNrX2ccNrpmqap
    gnb_counter.Wait for PM measurements    interval=${CU_PM_interval}    measurements=1
    ${counter_after_pm_interval}    Get CU PM Counter Value    counter_id=${counter_id}
    ...    network_element_dist_name=${network_element_dist_name}
    Verify CU PM Counter Incrementation    value_before_incrementation=${counter_before_pm_interval}
    ...    value_after_incrementation=${counter_after_pm_interval}
    [Teardown]    Run Keywords    Deactivate Measurements and Dettach UE   alias=${alias}    AND
    ...           Remove PMQAP instances

[1]CB006898-B_7_CB006898-B-SyVe_7_Counter_for_Peak_Nr_of_NSA_Ues
    [Setup]    Run Keywords    Verify All Cell Status    AND
    ...        Prepare Ue for L3 Call    capabilities=${capabilities}
    Set Test Variable    ${counter_id}    M55160C00003
    Create pmqap instance on DU  instance_id=1
    Set QCI profile on DU       ${dist_name}
    Create pmqap instance on CU     instance_id=1
    Set QCI profile on CU       instance_id=1
    Activate feature on DU
    Activate feature on CU
    Activate ACCNQ measurement on CU    value=${measurement_period}
    gnb_counter.Wait for next PM period    interval=15
    Verify CU PM Counter Value    counter_id=${counter_id}    network_element_dist_name=${network_element_dist_name}
    ...    counter_value=0
    Perform Attach and Verify UE Properly Attached    alias=${alias}
    gnb_counter.Wait for next PM period    interval=5
    Verify CU PM Counter Value    counter_id=${counter_id}    network_element_dist_name=${network_element_dist_name}
    ...    counter_value=1
    [Teardown]    Run Keywords    Deactivate Measurements and Dettach UE   alias=${alias}    AND
    ...     Remove PMQAP instances

[1]CB006898-D_15_CB006898-D-SyVe_15_Counter_for_Nr_of_NSA_ERAB_Released_Initiated_by_MeNB
    [Setup]    Run Keywords    Verify All Cell Status    AND
    ...        Prepare Ue for L3 Call    capabilities=${capabilities}
    Set Test Variable    ${counter_id}    M55112C06001
    Create PMQAP profiles
    Activate X2CCQ measurement on CU    value=15min
    gnb_counter.Wait for next PM period    interval=15
    Verify CU PM Counter Value    counter_id=${counter_id}  network_element_dist_name=${network_element_dist_name}
    ...    counter_value=0
    Start tcpdump Collection on X2 CPIF Interface    ${file}   background=${True}
    Perform Attach and Verify UE Properly Attached    alias=${alias}
    Sleep   40s
    Stop tcpdump Collection on CPIF Interface
    ${directory}=   Get tcpdump dir
    ${all_packets}     parse_pcap    pcap_dir=${directory}
    ${filtered}=    parser.verify_x2ap_values      pdml_file=${all_packets}    filter_expression=${addition_ack}
    ${filtered}=    parser.verify_x2ap_values      pdml_file=${all_packets}    filter_expression=${transfer}
    Start tcpdump Collection on X2 CPIF Interface    ${file}   background=${True}
    Sleep   40s
    Lock X2 link
    gnb_counter.Wait for next PM period    interval=15
    Verify CU PM Counter Value    counter_id=${counter_id}    network_element_dist_name=${network_element_dist_name}
    ...    counter_value=1
    Stop tcpdump Collection on CPIF Interface
    ${directory}=   Get tcpdump dir
    ${all_packets}     parse_pcap    pcap_dir=${directory}
    ${filtered}=    parser.verify_x2ap_values      pdml_file=${all_packets}    filter_expression=${release_reset}
    [Teardown]    Run Keywords      Reset CU        AND
    ...     Deactivate Measurements and Dettach UE      AND
    ...     Remove PMQAP instances

[1]CB006898-D_19_CB006898-D-SyVe_19_Counter_for_Nr_of_NSA_ERABs_Released_Due_To_Normal_Causes_Initiated_by_SgNB
    [Setup]    Run Keywords    Verify All Cell Status    AND
    ...        Prepare Ue for L3 Call    capabilities=${capabilities}
    Set Test Variable    ${counter_id}    M55162C00005
    Create PMQAP profiles
    Activate X2CCQ measurement on CU    value=15min
    gnb_counter.Wait for next PM period    interval=15
    Verify CU PM Counter Value    counter_id=${counter_id}  network_element_dist_name=${network_element_dist_name}
    ...    counter_value=0
    Start tcpdump Collection on X2 CPIF Interface    ${file}   background=${True}
    Cause UE inactivity
    Perform Attach and Verify UE Properly Attached    alias=${alias}
    Sleep   60s
    Stop tcpdump Collection on CPIF Interface
    ${directory}=   Get tcpdump dir
    log to console  ${directory}
    ${all_packets}     parse_pcap    pcap_dir=${directory}
    ${filtered}=    parser.verify_x2ap_values      pdml_file=${all_packets}    filter_expression=${addition_ack}
    ${filtered}=    parser.verify_x2ap_values      pdml_file=${all_packets}    filter_expression=${transfer}
    gnb_counter.Wait for next PM period    interval=15
    Verify CU PM Counter Value    counter_id=${counter_id}    network_element_dist_name=${network_element_dist_name}
    ...    counter_value=1
    ${filtered}=    parser.verify_x2ap_values      pdml_file=${all_packets}    filter_expression=${release}
    [Teardown]    Run Keywords      Deactivate Measurements and Dettach UE      AND
    ...           Fix UE inactivity     AND
    ...           Remove PMQAP instances

[1]CB006898-E_23_CB006898-E-SyVe_23_NSA_Accessibility_counters_NX2CC_ERAB_ack_SN_status_Transfer_Message
    [Setup]    Run Keywords    Verify All Cell Status    AND
    ...        Prepare Ue for L3 Call    capabilities=${capabilities}
    Set Test Variable    ${counter_id}    M55162C00009
    Create PMQAP profiles
    Activate X2CCQ measurement on CU    value=15min
    gnb_counter.Wait for next PM period    interval=15
    Verify CU PM Counter Value    counter_id=${counter_id}  network_element_dist_name=${network_element_dist_name}
    ...    counter_value=0
    Start tcpdump Collection on X2 CPIF Interface    ${file}   background=${True}
    Perform Attach and Verify UE Properly Attached    alias=${alias}
    Sleep   60s
    Stop tcpdump Collection on CPIF Interface
    ${directory}=   Get tcpdump dir
    log to console  ${directory}
    ${all_packets}     parse_pcap    pcap_dir=${directory}
    ${filtered}=    parser.verify_x2ap_values      pdml_file=${all_packets}    filter_expression=${addition_req}
    ${filtered}=    parser.verify_x2ap_values      pdml_file=${all_packets}    filter_expression=${addition_ack}
    ${filtered}=    parser.verify_x2ap_values      pdml_file=${all_packets}    filter_expression=${reconfiguration}
    gnb_counter.Wait for next PM period    interval=15
    Verify CU PM Counter Value    counter_id=${counter_id}    network_element_dist_name=${network_element_dist_name}
    ...    counter_value=1
    [Teardown]    Run Keywords      Deactivate Measurements and Dettach UE      AND
    ...           Remove PMQAP instances

*** Keywords ***
Deactivate Measurements and Dettach UE
    [Arguments]    ${alias}=UE
    Deactivate Measurements
    ue.Detach Ue    ${alias}

