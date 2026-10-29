*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
    ...    CLOUD_5G_I_LPQ_AP_LOO

Documentation    :copyright: Nokia
...              :authors: Lukasz Klimowicz
...              :contact: lukasz.klimowicz@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     ../../../WRO_2/keywords/messaging.robot
Resource     ../../../WRO_2/keywords/traffic.robot
Resource     ../../../WRO_2/keywords/L3_Call.robot
Resource     ../../../WRO_2/keywords/tshark_verifying.robot
Resource     ../../resources/common_airphone_keywords.robot
Resource     ../../resources/common_keywords.robot
Resource     ../../resources/ute_report.robot
Resource     variables_TC_11.robot
Resource     keywords.robot
Resource     ta_messaging/flow.robot
Library      ta5g_tshark
Library      ta_messaging
Library      taf.ul.ettf.retry_context
Library      taf.ul.ettf.setups
Library      ta5g_testline_management
Library      ta5g_delta
Library      ta5g_iphy
Variables    logging_policy.py
Library      ta5g_pm_counters
Library      keywords.py


*** Variables ***
${KEEP_ALIVE}=    ${True}
${LOGS_COMPRESSION}=    ${True}
${LOGGING_POLICY}=    NO_LOGS
${BASIC_SETUP}=       ${CURDIR}/config/wts_CB013438_TC_11.cfg
${SCFC}=              TC_11_online_mod_legacy_enhanced_WRR_scfc.xml
${IPHY_SETUP}=        ${CURDIR}/config/iphy_CB013438.xml


*** Test Cases ***
TC11_CB013438_A_A5_Online_modification_of_scheduling_weight_and_comparision_of_resources_sharing_between_legacy_and_enhanced_WRR_with_KPI_verification
    [Setup]    Run Keywords        Log to console    Full scfc commissioning with iphy.xml upload
    ...            AND             Set Max Rx Tx Queue Sizes For AP Simulated Traffic Performance
    ...            AND             Update And Put Iphy Xml    input_filepath=${IPHY_SETUP}
    ...            AND             With Gnb Configuration    commissioning=${SCFC}
    ...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
    ...            AND             With Simulator Configuration    config=${BASIC_SETUP}



    Register UE And Start Specific UL and DL Traffic    ue_id=5    nwslice=1    dl_trf_id_list=${UE5_dl_trf_ids}    ul_trf_id_list=${UE5_ul_trf_ids}
    ...    mbps_dl_list=${UE5_dl_mbps}    mbps_ul_list=${UE5_ul_mbps}    qfi_dl_id_list=${UE5_dl_qfi_ids}    qfi_ul_id_list=${UE5_ul_qfi_ids}
    Register UE And Start Specific UL and DL Traffic    ue_id=50    nwslice=2    dl_trf_id_list=${UE50_dl_trf_ids}
    ...    ul_trf_id_list=${UE50_ul_trf_ids}    mbps_dl_list=${UE50_dl_mbps}    mbps_ul_list=${UE50_ul_mbps}    qfi_dl_id_list=${UE50_dl_qfi_ids}
    ...    qfi_ul_id_list=${UE50_ul_qfi_ids}
    Register UE And Start Specific UL and DL Traffic    ue_id=51    nwslice=3    dl_trf_id_list=${UE51_dl_trf_ids}
    ...    ul_trf_id_list=${UE51_ul_trf_ids}    mbps_dl_list=${UE51_dl_mbps}    mbps_ul_list=${UE51_ul_mbps}    qfi_dl_id_list=${UE51_dl_qfi_ids}
    ...    qfi_ul_id_list=${UE51_ul_qfi_ids}
    Wait For Traffic to Stabilize And Fill UEs Buffers

    Verify That Throughput Is Reached On Specific Cells    ue_id=5    cells_list=${PCell_id}
    ...    expected_throughput=300Mbps    direction=dl    margin=15%    selection_type=Maximum
    Verify That Throughput Is Reached On Specific Cells    ue_id=50    cells_list=${PCell_id}
    ...    expected_throughput=150Mbps    direction=dl    margin=15%    selection_type=Maximum
    Verify That Throughput Is Reached On Specific Cells    ue_id=51    cells_list=${PCell_id}
    ...    expected_throughput=50Mbps    direction=dl    margin=15%    selection_type=Maximum

    Verify That Throughput Is Reached On Specific Cells    ue_id=5    cells_list=${PCell_id}
    ...    expected_throughput=60Mbps    direction=ul    margin=15%    selection_type=Maximum
    Verify That Throughput Is Reached On Specific Cells    ue_id=50    cells_list=${PCell_id}
    ...    expected_throughput=8Mbps    direction=ul    margin=15%    selection_type=Maximum
    Verify That Throughput Is Reached On Specific Cells    ue_id=51    cells_list=${PCell_id}
    ...    expected_throughput=0.05Mbps    direction=ul    margin=15%    selection_type=Maximum

    Change CB013438 Configuration And Schedul Weights    faf_CB013438=ExtendedRange_LegacyWrr    SNSSAI_1_sched_weight=1000
    ...    SNSSAI_2_sched_weight=100

    Stop Data Traffic    ue_id=5   pdu_id=5    qfi_id=1    dir=bi
    Stop Data Traffic    ue_id=50   pdu_id=5    qfi_id=1    dir=bi
    Stop Data Traffic    ue_id=51   pdu_id=5    qfi_id=1    dir=bi

    Start Specific UL and DL Traffic    ue_id=5    dl_trf_id_list=${UE5_dl_trf_ids_restart}    ul_trf_id_list=${UE5_ul_trf_ids_restart}
    ...    mbps_dl_list=${UE5_dl_mbps_restart}    mbps_ul_list=${UE5_ul_mbps_restart}    qfi_dl_id_list=${UE5_dl_qfi_ids_restart}
    ...    qfi_ul_id_list=${UE5_ul_qfi_ids_restart}
    Start Specific UL and DL Traffic    ue_id=50    dl_trf_id_list=${UE50_dl_trf_ids_restart}
    ...    ul_trf_id_list=${UE50_ul_trf_ids_restart}    mbps_dl_list=${UE50_dl_mbps_restart}    mbps_ul_list=${UE50_ul_mbps_restart}
    ...    qfi_dl_id_list=${UE50_dl_qfi_ids_restart}
    ...    qfi_ul_id_list=${UE50_ul_qfi_ids_restart}
    Start Specific UL and DL Traffic    ue_id=51    dl_trf_id_list=${UE51_dl_trf_ids_restart}
    ...    ul_trf_id_list=${UE51_ul_trf_ids_restart}    mbps_dl_list=${UE51_dl_mbps_restart}    mbps_ul_list=${UE51_ul_mbps_restart}
    ...    qfi_dl_id_list=${UE51_dl_qfi_ids_restart}
    ...    qfi_ul_id_list=${UE51_ul_qfi_ids_restart}

    Register UE And Start Specific UL and DL Traffic    ue_id=6    nwslice=1    dl_trf_id_list=${UE6_dl_trf_ids}    ul_trf_id_list=${UE6_ul_trf_ids}
    ...    mbps_dl_list=${UE6_dl_mbps}    mbps_ul_list=${UE6_ul_mbps}    qfi_dl_id_list=${UE6_dl_qfi_ids}    qfi_ul_id_list=${UE6_ul_qfi_ids}
    Register UE And Start Specific UL and DL Traffic    ue_id=60    nwslice=2    dl_trf_id_list=${UE60_dl_trf_ids}
    ...    ul_trf_id_list=${UE60_ul_trf_ids}    mbps_dl_list=${UE60_dl_mbps}    mbps_ul_list=${UE60_ul_mbps}    qfi_dl_id_list=${UE60_dl_qfi_ids}
    ...    qfi_ul_id_list=${UE60_ul_qfi_ids}
    Register UE And Start Specific UL and DL Traffic    ue_id=61    nwslice=3    dl_trf_id_list=${UE61_dl_trf_ids}
    ...    ul_trf_id_list=${UE61_ul_trf_ids}    mbps_dl_list=${UE61_dl_mbps}    mbps_ul_list=${UE61_ul_mbps}    qfi_dl_id_list=${UE61_dl_qfi_ids}
    ...    qfi_ul_id_list=${UE61_ul_qfi_ids}
    Wait For Traffic to Stabilize And Fill UEs Buffers


    Verify That Throughput Is Reached On Specific Cells    ue_id=5    cells_list=${PCell_id}
    ...    expected_throughput=155Mbps    direction=dl    margin=15%    selection_type=Maximum
    Verify That Throughput Is Reached On Specific Cells    ue_id=50    cells_list=${PCell_id}
    ...    expected_throughput=24Mbps    direction=dl    margin=15%    selection_type=Maximum
    Verify That Throughput Is Reached On Specific Cells    ue_id=51    cells_list=${PCell_id}
    ...    expected_throughput=0.3Mbps    direction=dl    margin=15%    selection_type=Maximum
    Verify That Throughput Is Reached On Specific Cells    ue_id=6    cells_list=${PCell_id}
    ...    expected_throughput=165Mbps    direction=dl    margin=15%    selection_type=Maximum
    Verify That Throughput Is Reached On Specific Cells    ue_id=60    cells_list=${PCell_id}
    ...    expected_throughput=155Mbps    direction=dl    margin=15%    selection_type=Maximum
    Verify That Throughput Is Reached On Specific Cells    ue_id=61    cells_list=${PCell_id}
    ...    expected_throughput=0.3Mbps    direction=dl    margin=15%    selection_type=Maximum

    Verify That Throughput Is Reached On Specific Cells    ue_id=5    cells_list=${PCell_id}
    ...    expected_throughput=10Mbps    direction=ul    margin=5%    selection_type=Maximum
    Verify That Throughput Is Reached On Specific Cells    ue_id=50    cells_list=${PCell_id}
    ...    expected_throughput=1Mbps    direction=ul    margin=15%    selection_type=Maximum
    Verify That Throughput Is Reached On Specific Cells    ue_id=51    cells_list=${PCell_id}
    ...    expected_throughput=0.1Mbps    direction=ul    margin=15%    selection_type=Maximum
    Verify That Throughput Is Reached On Specific Cells    ue_id=6    cells_list=${PCell_id}
    ...    expected_throughput=50Mbps    direction=ul    margin=15%    selection_type=Maximum
    Verify That Throughput Is Reached On Specific Cells    ue_id=60    cells_list=${PCell_id}
    ...    expected_throughput=9Mbps    direction=ul    margin=15%    selection_type=Maximum
    Verify That Throughput Is Reached On Specific Cells    ue_id=61    cells_list=${PCell_id}
    ...    expected_throughput=0.1Mbps    direction=ul    margin=15%    selection_type=Maximum

    Wait For Next Full Pm Interval
    ${pm_counter_file_legacy_algo}=    Get Next Unpacked Full Pm Counters File
    ${counters_to_be_decreased_legacy_algo}=    Get Counters Values For Enhanced Algo Verification    counter_id_list=${counters_to_be_decreased}
    ...    local_moid=${local_moid_decreasing_counters}    pm_counter_file=${pm_counter_file_legacy_algo}
    ${counters_to_be_increased_legacy_algo}=    Get Counters Values For Enhanced Algo Verification    counter_id_list=${counters_to_be_increased}
    ...    local_moid=${local_moid_increasing_counters}    pm_counter_file=${pm_counter_file_legacy_algo}
    ${counters_to_be_equal_legacy_algo}=    Get Counters Values For Enhanced Algo Verification    counter_id_list=${counters_to_be_equal}
    ...    local_moid=${local_moid_equal_counters}    pm_counter_file=${pm_counter_file_legacy_algo}
    ${counters_for_KPI_5192e_verification_legacy_algo}=    Get Counters Values For Enhanced Algo Verification    counter_id_list=${KPI_NR_5192e}
    ...    local_moid=${KPI_NR_5192e_local_moid}    pm_counter_file=${pm_counter_file_legacy_algo}
    ${counters_for_KPI_5193b_verification_legacy_algo}=    Get Counters Values For Enhanced Algo Verification    counter_id_list=${KPI_NR_5193b}
    ...    local_moid=${KPI_NR_5193b_local_moid}    pm_counter_file=${pm_counter_file_legacy_algo}
    ${counters_for_KPI_5888a_verification_legacy_algo}=    Get Counters Values For Enhanced Algo Verification    counter_id_list=${KPI_NR_5888a}
    ...    local_moid=${KPI_NR_5888a_local_moid}    pm_counter_file=${pm_counter_file_legacy_algo}
    ${counters_for_KPI_5887a_verification_legacy_algo}=    Get Counters Values For Enhanced Algo Verification    counter_id_list=${KPI_NR_5887a}
    ...    local_moid=${KPI_NR_5887a_local_moid}    pm_counter_file=${pm_counter_file_legacy_algo}

    ${KPI_NR_5244e_local_moid}=    Create List With Local Moids For NRCELL    counter_id_list=${KPI_NR_5244e}    cell_id=5
    ${KPI_NR_5245d_local_moid}=    Create List With Local Moids For NRCELL    counter_id_list=${KPI_NR_5245d}    cell_id=5
    ${counters_for_KPI_5244e_verification_legacy_algo}=    Get Counters Values For Enhanced Algo Verification    counter_id_list=${KPI_NR_5244e}
    ...    local_moid=${KPI_NR_5244e_local_moid}    pm_counter_file=${pm_counter_file_legacy_algo}
    ${counters_for_KPI_5245d_verification_legacy_algo}=    Get Counters Values For Enhanced Algo Verification    counter_id_list=${KPI_NR_5245d}
    ...    local_moid=${KPI_NR_5245d_local_moid}    pm_counter_file=${pm_counter_file_legacy_algo}

    Change CB013438 Configuration And Schedul Weights    faf_CB013438=ExtendedRange_EnhancedWrr    SNSSAI_1_sched_weight=1000
    ...    SNSSAI_2_sched_weight=100

    Stop Data Traffic    ue_id=5   pdu_id=5    qfi_id=1    dir=bi
    Stop Data Traffic    ue_id=50   pdu_id=5    qfi_id=1    dir=bi
    Stop Data Traffic    ue_id=51   pdu_id=5    qfi_id=1    dir=bi
    Stop Data Traffic    ue_id=6   pdu_id=5    qfi_id=1    dir=bi
    Stop Data Traffic    ue_id=60   pdu_id=5    qfi_id=1    dir=bi
    Stop Data Traffic    ue_id=61   pdu_id=5    qfi_id=1    dir=bi

    Start Specific UL and DL Traffic    ue_id=5    dl_trf_id_list=${UE5_dl_trf_ids_enhanced}    ul_trf_id_list=${UE5_ul_trf_ids_enhanced}
    ...    mbps_dl_list=${UE5_dl_mbps_enhanced}    mbps_ul_list=${UE5_ul_mbps_enhanced}    qfi_dl_id_list=${UE5_dl_qfi_ids_enhanced}
    ...    qfi_ul_id_list=${UE5_ul_qfi_ids_enhanced}
    Start Specific UL and DL Traffic    ue_id=50    dl_trf_id_list=${UE50_dl_trf_ids_enhanced}
    ...    ul_trf_id_list=${UE50_ul_trf_ids_enhanced}    mbps_dl_list=${UE50_dl_mbps_enhanced}    mbps_ul_list=${UE50_ul_mbps_enhanced}
    ...    qfi_dl_id_list=${UE50_dl_qfi_ids_enhanced}    qfi_ul_id_list=${UE50_ul_qfi_ids_enhanced}
    Start Specific UL and DL Traffic    ue_id=51    dl_trf_id_list=${UE51_dl_trf_ids_enhanced}
    ...    ul_trf_id_list=${UE51_ul_trf_ids_enhanced}    mbps_dl_list=${UE51_dl_mbps_enhanced}    mbps_ul_list=${UE51_ul_mbps_enhanced}
    ...    qfi_dl_id_list=${UE51_dl_qfi_ids_enhanced}    qfi_ul_id_list=${UE51_ul_qfi_ids_enhanced}
    Start Specific UL and DL Traffic    ue_id=6    dl_trf_id_list=${UE6_dl_trf_ids_enhanced}    ul_trf_id_list=${UE6_ul_trf_ids_enhanced}
    ...    mbps_dl_list=${UE6_dl_mbps_enhanced}    mbps_ul_list=${UE6_ul_mbps_enhanced}    qfi_dl_id_list=${UE6_dl_qfi_ids_enhanced}
    ...    qfi_ul_id_list=${UE6_ul_qfi_ids_enhanced}
    Start Specific UL and DL Traffic    ue_id=60    dl_trf_id_list=${UE60_dl_trf_ids_enhanced}
    ...    ul_trf_id_list=${UE60_ul_trf_ids_enhanced}    mbps_dl_list=${UE60_dl_mbps_enhanced}    mbps_ul_list=${UE60_ul_mbps_enhanced}
    ...    qfi_dl_id_list=${UE60_dl_qfi_ids_enhanced}    qfi_ul_id_list=${UE60_ul_qfi_ids_enhanced}
    Start Specific UL and DL Traffic    ue_id=61    dl_trf_id_list=${UE61_dl_trf_ids_enhanced}
    ...    ul_trf_id_list=${UE61_ul_trf_ids_enhanced}    mbps_dl_list=${UE61_dl_mbps_enhanced}    mbps_ul_list=${UE61_ul_mbps_enhanced}
    ...    qfi_dl_id_list=${UE61_dl_qfi_ids_enhanced}    qfi_ul_id_list=${UE61_ul_qfi_ids_enhanced}

    Wait For Traffic to Stabilize And Fill UEs Buffers


    Verify That Throughput Is Reached On Specific Cells    ue_id=5    cells_list=${PCell_id}
    ...    expected_throughput=98Mbps    direction=dl    margin=15%    selection_type=Maximum
    Verify That Throughput Is Reached On Specific Cells    ue_id=50    cells_list=${PCell_id}
    ...    expected_throughput=9Mbps    direction=dl    margin=15%    selection_type=Maximum
    Verify That Throughput Is Reached On Specific Cells    ue_id=51    cells_list=${PCell_id}
    ...    expected_throughput=1Mbps    direction=dl    margin=15%    selection_type=Maximum
    Verify That Throughput Is Reached On Specific Cells    ue_id=6    cells_list=${PCell_id}
    ...    expected_throughput=290Mbps    direction=dl    margin=15%    selection_type=Maximum
    Verify That Throughput Is Reached On Specific Cells    ue_id=60    cells_list=${PCell_id}
    ...    expected_throughput=98Mbps    direction=dl    margin=15%    selection_type=Maximum
    Verify That Throughput Is Reached On Specific Cells    ue_id=61    cells_list=${PCell_id}
    ...    expected_throughput=1Mbps    direction=dl    margin=15%    selection_type=Maximum

    Verify That Throughput Is Reached On Specific Cells    ue_id=5    cells_list=${PCell_id}
    ...    expected_throughput=6Mbps    direction=ul    margin=15%    selection_type=Maximum
    Verify That Throughput Is Reached On Specific Cells    ue_id=50    cells_list=${PCell_id}
    ...    expected_throughput=0.7Mbps    direction=ul    margin=15%    selection_type=Maximum
    Verify That Throughput Is Reached On Specific Cells    ue_id=51    cells_list=${PCell_id}
    ...    expected_throughput=0.06Mbps    direction=ul    margin=15%    selection_type=Maximum
    Verify That Throughput Is Reached On Specific Cells    ue_id=6    cells_list=${PCell_id}
    ...    expected_throughput=58Mbps    direction=ul    margin=15%    selection_type=Maximum
    Verify That Throughput Is Reached On Specific Cells    ue_id=60    cells_list=${PCell_id}
    ...    expected_throughput=6Mbps    direction=ul    margin=15%    selection_type=Maximum
    Verify That Throughput Is Reached On Specific Cells    ue_id=61    cells_list=${PCell_id}
    ...    expected_throughput=0.09Mbps    direction=ul    margin=15%    selection_type=Maximum

    Wait For Next Full Pm Interval
    ${pm_counter_file_enh_algo}=    Get Next Unpacked Full Pm Counters File
    ${counters_to_be_decreased_enhanced_algo}=    Get Counters Values For Enhanced Algo Verification    counter_id_list=${counters_to_be_decreased}
    ...    local_moid=${local_moid_decreasing_counters}    pm_counter_file=${pm_counter_file_enh_algo}
    ${counters_to_be_increased_enhanced_algo}=    Get Counters Values For Enhanced Algo Verification    counter_id_list=${counters_to_be_increased}
    ...    local_moid=${local_moid_increasing_counters}    pm_counter_file=${pm_counter_file_enh_algo}
    ${counters_to_be_equal_enhanced_algo}=    Get Counters Values For Enhanced Algo Verification    counter_id_list=${counters_to_be_equal}
    ...    local_moid=${local_moid_equal_counters}    pm_counter_file=${pm_counter_file_enh_algo}
    ${counters_for_KPI_5192e_verification_enhanced_algo}=    Get Counters Values For Enhanced Algo Verification    counter_id_list=${KPI_NR_5192e}
    ...    local_moid=${KPI_NR_5192e_local_moid}    pm_counter_file=${pm_counter_file_enh_algo}
    ${counters_for_KPI_5193b_verification_enhanced_algo}=    Get Counters Values For Enhanced Algo Verification    counter_id_list=${KPI_NR_5193b}
    ...    local_moid=${KPI_NR_5193b_local_moid}    pm_counter_file=${pm_counter_file_enh_algo}
    ${counters_for_KPI_5888a_verification_enhanced_algo}=    Get Counters Values For Enhanced Algo Verification    counter_id_list=${KPI_NR_5888a}
    ...    local_moid=${KPI_NR_5888a_local_moid}    pm_counter_file=${pm_counter_file_enh_algo}
    ${counters_for_KPI_5887a_verification_enhanced_algo}=    Get Counters Values For Enhanced Algo Verification    counter_id_list=${KPI_NR_5887a}
    ...    local_moid=${KPI_NR_5887a_local_moid}    pm_counter_file=${pm_counter_file_enh_algo}
    ${counters_for_KPI_5244e_verification_enhanced_algo}=    Get Counters Values For Enhanced Algo Verification    counter_id_list=${KPI_NR_5244e}
    ...    local_moid=${KPI_NR_5244e_local_moid}    pm_counter_file=${pm_counter_file_enh_algo}
    ${counters_for_KPI_5245d_verification_enhanced_algo}=    Get Counters Values For Enhanced Algo Verification    counter_id_list=${KPI_NR_5245d}
    ...    local_moid=${KPI_NR_5245d_local_moid}    pm_counter_file=${pm_counter_file_enh_algo}

    Compare Counters After Algorithm Switch    counters_legacy_wrr=${counters_to_be_decreased_legacy_algo}
    ...    counters_enh_wrr=${counters_to_be_decreased_enhanced_algo}    expected_behavior=decreased
    Compare Counters After Algorithm Switch    counters_legacy_wrr=${counters_to_be_increased_legacy_algo}
    ...    counters_enh_wrr=${counters_to_be_increased_enhanced_algo}    expected_behavior=increased
    Compare Counters After Algorithm Switch    counters_legacy_wrr=${counters_to_be_equal_legacy_algo}
    ...    counters_enh_wrr=${counters_to_be_equal_enhanced_algo}    expected_behavior=equal

    Compare KPIs After Algorithm Switch    counters_legacy_wrr=${counters_for_KPI_5192e_verification_legacy_algo}
    ...    counters_enh_wrr=${counters_for_KPI_5192e_verification_enhanced_algo}    expected_behavior=decreased    KPI_name=NR_5192e
    Compare KPIs After Algorithm Switch    counters_legacy_wrr=${counters_for_KPI_5193b_verification_legacy_algo}
    ...    counters_enh_wrr=${counters_for_KPI_5193b_verification_enhanced_algo}    expected_behavior=decreased    KPI_name=NR_5193b
    Compare KPIs After Algorithm Switch    counters_legacy_wrr=${counters_for_KPI_5887a_verification_legacy_algo}
    ...    counters_enh_wrr=${counters_for_KPI_5887a_verification_enhanced_algo}    expected_behavior=undefined    KPI_name=NR_5887a
    Compare KPIs After Algorithm Switch    counters_legacy_wrr=${counters_for_KPI_5888a_verification_legacy_algo}
    ...    counters_enh_wrr=${counters_for_KPI_5888a_verification_enhanced_algo}    expected_behavior=undefined    KPI_name=NR_5888a

    Compare KPIs After Algorithm Switch    counters_legacy_wrr=${counters_for_KPI_5245d_verification_legacy_algo}
    ...    counters_enh_wrr=${counters_for_KPI_5245d_verification_enhanced_algo}    expected_behavior=increased    KPI_name=NR_5245d
    Compare KPIs After Algorithm Switch    counters_legacy_wrr=${counters_for_KPI_5244e_verification_legacy_algo}
    ...    counters_enh_wrr=${counters_for_KPI_5244e_verification_enhanced_algo}    expected_behavior=increased    KPI_name=NR_5244e

    [Teardown]    Run Keywords    Change CB013438 Configuration And Schedul Weights    faf_CB013438=disabled    SNSSAI_1_sched_weight=100
    ...            SNSSAI_2_sched_weight=10
    ...            AND            Release Multiple UEs    ue_ids=${UE_AP_ids}    pdu_ids=${UE_PDU_AP_ids}
    ...            AND            Add Scout Data Info To Testcase


*** Keywords ***
Register UE And Start Specific UL and DL Traffic
    [Arguments]    ${ue_id}    ${nwslice}    ${dl_trf_id_list}    ${ul_trf_id_list}    ${mbps_dl_list}    ${mbps_ul_list}
    ...    ${qfi_dl_id_list}    ${qfi_ul_id_list}
    Attach UE And Establish PDU Session    ue_id=${ue_id}   cell_id=5    enb_id=2    pdu_id=5    gw_id=5    nwslice=${nwslice}
    Start Data Traffic    ue_id=${ue_id}   pdu_id=5    qfi_id_list=${qfi_dl_id_list}
    ...    trf_id_list=${dl_trf_id_list}
    ...    dir=dl
    ...    mbps_list=${mbps_dl_list}
    ...    protocol=tcp
    Start Data Traffic    ue_id=${ue_id}   pdu_id=5    qfi_id_list=${qfi_ul_id_list}
    ...    trf_id_list=${ul_trf_id_list}
    ...    dir=ul
    ...    mbps_list=${mbps_ul_list}
    ...    protocol=tcp

Start Specific UL and DL Traffic
    [Arguments]    ${ue_id}    ${dl_trf_id_list}    ${ul_trf_id_list}    ${mbps_dl_list}    ${mbps_ul_list}
    ...    ${qfi_dl_id_list}    ${qfi_ul_id_list}
    Start Data Traffic    ue_id=${ue_id}   pdu_id=5    qfi_id_list=${qfi_dl_id_list}
    ...    trf_id_list=${dl_trf_id_list}
    ...    dir=dl
    ...    mbps_list=${mbps_dl_list}
    ...    protocol=tcp
    Start Data Traffic    ue_id=${ue_id}   pdu_id=5    qfi_id_list=${qfi_ul_id_list}
    ...    trf_id_list=${ul_trf_id_list}
    ...    dir=ul
    ...    mbps_list=${mbps_ul_list}
    ...    protocol=tcp

Stop Data Traffic
    [Arguments]    ${ue_id}   ${pdu_id}    ${dir}    ${qfi_id}=1
    Execute Egate Command    cmd=trf_data_stop ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=${dir}
