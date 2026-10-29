*** Settings ***
Documentation
...    :copyright: Nokia
...    :author: Sylwester Sowa
...    :maintainer: Sylwester Sowa, Krzysztof Wojnar
...    :contact: sylwester.sowa@nokia.com; krzysztof.wojnar@nokia.com

...    This test suite covers C-Plane overload cases, including robustness scenarios.


Force Tags    CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC    RF50

Library     testsuite.Wroclaw.RRM.VRF_WRO2_T07.airphone.CB012584.resources.ocp_operations.OcpOperator
Resource    ./resources/CB012584_keywords.robot


Suite Setup    Suite Setup CPlane Overload

Suite Teardown    Suite Teardown CPlane Overload

*** Test Cases ***
CB012584_DU_CPlane_overload_multiple_activation_and_deactivation
    [Documentation]    This user scenario validates the gNB-DU and gNB-CU behaviour when CPlane enters DU
    ...    overload condition.
    [Tags]     TC2
    [Setup]    Run Keywords    Setup RRC inactive UE
    ...    AND                 Start Default Logging Aic      output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    [Teardown]    Run Keywords    Stop Tcpdump on remote interface
    ...     AND                   Stop Default Logging Aic
    ...     AND                   Change CPRT Flags To Default Values
    ...     AND                   Change CPUE Flags To Default Values

    Enable partial overload on CPRT pod
    Register Multiple UEs    first_ue_id=1    last_ue_id=10
    Check RRC Reject For At Least Given Number Of Messages    1

    Wait For Next Full Pm Interval Aic    vdu=1
    ${pm_counter_file}=    Get Latest Unpacked Full PM Counters File Aic    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}/counters1_vdu    vdu=1
    Verify Last Counters In File
    ...    M55124C00023    >0    SA_RRC_ESTAB_NEME_FAIL_OVLDU
    ...    M55124C00023    <10    SA_RRC_ESTAB_NEME_FAIL_OVLDU
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counter_file}
    Execute Egate Command    cmd=ue_kill id=1-10

    Create List With R&D Flags    0x5901FB    1    # Enabling full overload by changing one flag is enough here
    Setup R&D Flags    name=default    port=15057    flags=${flags_list}    pod=${CPRT_POD}
    Verify Tcpdump Log    packet_filter=${F1AP_GNBDU_OVERLOADED_INFORMATION}    relation_symbol= >

    Start Tshark    log_filename=Uu_1.pcap    eth_interface=eth4    alias=pcap1    log_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Change multiple UE location    first_ue_id=6    last_ue_id=10    dst_enb=2    dst_cell=3
    Register Multiple UEs    first_ue_id=1    last_ue_id=10
    Resume RRC inactive UE
    Attach UE    ue_id=11    cell=2    enb=2    pass_regexp=UE11: Registering
    Attach UE    ue_id=12    cell=4    enb=2    pass_regexp=UE12: Registering
    Verify Count of RRC Rejects    count=13    log_filename=Uu_1.pcap    alias=pcap1
    Execute Egate Command    cmd=ue_kill id=151
    Stop Tshark    alias=pcap1

    Register high priority access UE and verify RRC reject is not visible    pcap=Uu_2.pcap    alias=pcap2

    Trigger Dual Connectivity For NSA UE 808 To Cell 1
    Trigger Dual Connectivity For NSA UE 809 To Cell 2
    Verify Ngap Messages    packet_filter=${X2AP_SGNB_ADDITION_REJECT}    number_of_messages=2
    Detach UE    ue_id=808
    Detach UE    ue_id=809

    Wait For Next Full Pm Interval Aic    vdu=1
    ${PM_COUNTER_FILE_VDU}=    Get Latest Unpacked Full PM Counters File Aic    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}/counters2_vdu1    vdu=1
    ${PM_COUNTER_FILE_VCU}=    Get Latest Unpacked Full Pm Counters File Aic    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}/counters_vcu
    Verify Any Counters In File    M55112C05501  +1  X2_SGNB_ADD_PREP_FAIL_OVLCP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE_VCU}
    Verify Any Counters In File    M55112C05501  +1  X2_SGNB_ADD_PREP_FAIL_OVLCP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${PM_COUNTER_FILE_VCU}
    ...    report_pm_counter=True
    Verify Last Counters In File    M55124C00023    5    SA_RRC_ESTAB_NEME_FAIL_OVLDU
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE_VDU}
    Verify Any Counters In File    M55166C00019    +1    SA_RRC_RESUME1_NEME_FAIL_OVLDU
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE_VDU}
    ...    report_pm_counter=True
    Verify Any Counters In File    M55124C00023    +5    SA_RRC_ESTAB_NEME_FAIL_OVLDU
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    file_path=${PM_COUNTER_FILE_VDU}
    Verify Any Counters In File    M55124C00023    +1    SA_RRC_ESTAB_NEME_FAIL_OVLDU
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${PM_COUNTER_FILE_VDU}
    Verify Any Counters In File    M55124C00023    +1    SA_RRC_ESTAB_NEME_FAIL_OVLDU
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4
    ...    file_path=${PM_COUNTER_FILE_VDU}

    ${proc}    ${log_path}    ${pcap3_alias}=    Start Tcpdump on remote interface Aic    log_filename_prefix=F1AP_1
    ...    log_dirpath=${OUTPUT_DIR}/${TEST_NAME}    alias=pcap3
    Perform online overload deactivation
    Verify Tcpdump Log    packet_filter=${F1AP_GNBDU_NOT_OVERLOADED_INFORMATION}    pcap_file_path=${log_path}    alias=pcap3
    Start Tshark    log_filename=x2_uu_1.pcap    eth_interface=any    capture_filter=sctp    alias=pcap4    log_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Attach UE    ue_id=13
    Deregister UE    ue_id=13
    Attach Ue To Enb    ue_id=807
    Start Gnb Addition Procedure    ue=807    target_gnb=2    target_cells=1    bearer=2    dc_type=split_scg
    Detach UE    ue_id=807
    Check If RRCReject Is Not Visible    pcap_file_path=x2_uu_1.pcap    alias=pcap4
    Verify successful SgNBAddition    log_filename=x2_uu_1.pcap    alias=pcap4
    Stop Tshark    alias=pcap4

    ${proc}    ${log_path}    ${pcap5_alias}=    Start Tcpdump on remote interface Aic    log_filename_prefix=F1AP_2
    ...    log_dirpath=${OUTPUT_DIR}/${TEST_NAME}    alias=pcap5
    Perform online overload activation
    Verify Tcpdump Log    packet_filter=${F1AP_GNBDU_OVERLOADED_INFORMATION}    pcap_file_path=${log_path}    relation_symbol= >    alias=pcap5
    Start Tshark    log_filename=x2_uu_2.pcap    eth_interface=any    capture_filter=sctp    alias=pcap6    log_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Register Multiple UEs    first_ue_id=5    last_ue_id=6
    Trigger Dual Connectivity For NSA UE 806 To Cell 3
    Verify Count of RRC Rejects    count=2    log_filename=x2_uu_2.pcap    alias=pcap6
    Verify SgNBAdditionRequestReject count    count=1    log_filename=x2_uu_2.pcap    alias=pcap6
    Detach UE    806
    Stop Tshark    alias=pcap6

    ${proc}    ${log_path}    ${pcap7_alias}=    Start Tcpdump on remote interface Aic    log_filename_prefix=F1AP_3
    ...    log_dirpath=${OUTPUT_DIR}/${TEST_NAME}    alias=pcap7
    Change CPRT Flags To Default Values
    Verify Tcpdump Log    packet_filter=${F1AP_GNBDU_NOT_OVERLOADED_INFORMATION}    pcap_file_path=${log_path}    alias=pcap7
    Start Tshark    log_filename=x2_uu_3.pcap    eth_interface=eth3    alias=pcap8    log_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Attach Ue To Enb    ue_id=808
    Start Gnb Addition Procedure    ue=808    target_gnb=2    target_cells=1    bearer=2    dc_type=split_scg
    Verify successful SgNBAddition    log_filename=x2_uu_3.pcap    alias=pcap8
    Detach UE    ue_id=808
    Attach UE    ue_id=13
    Deregister UE    ue_id=13
    Check If RRCReject Is Not Visible    pcap_file_path=x2_uu_3.pcap    alias=pcap8
    Stop Tshark    alias=pcap8

CB012584_CU_and_both_CU_and_DU_CPlane_overload_multiple_activation_and_deactivation
    [Documentation]    This user scenario validates the gNB-DU and gNB-CU behaviour when CPlane enters DU or CU or both
    ...                CU and DU overload condition.
    [Tags]     TC3
    [Setup]    Run Keywords    Setup RRC inactive UE
    ...    AND                 Start Default Logging Aic      output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    [Teardown]    Run Keywords    Stop Tcpdump on remote interface
    ...     AND                   Stop Default Logging Aic
    ...     AND                   Change CPRT Flags To Default Values
    ...     AND                   Change CPUE Flags To Default Values

    Enable full overload on CPUE pod
    Change multiple UE location    first_ue_id=26    last_ue_id=30    dst_enb=2    dst_cell=3
    Register Multiple UEs    first_ue_id=21    last_ue_id=30
    Resume RRC inactive UE
    Trigger Dual Connectivity For NSA UE 808 To Cell 1
    Trigger Dual Connectivity For NSA UE 809 To Cell 3
    Verify Count of RRC Rejects    count=11
    Verify Ngap Messages    packet_filter=${X2AP_SGNB_ADDITION_REJECT}    number_of_messages=2
    Verify Tcpdump Log    packet_filter=${F1AP_CU_OVERLOADED_INFORMATION}    relation_symbol= >
    Execute Egate Command    cmd=ue_kill id=151
    Detach UE    ue_id=808
    Detach UE    ue_id=809

    Register emergency UE and verify RRC reject is not visible

    Wait For Next Full Pm Interval Aic    vdu=1
    ${PM_COUNTER_FILE_VDU}=    Get Latest Unpacked Full PM Counters File Aic    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}/counters_vdu    vdu=1
    ${PM_COUNTER_FILE}=    Get Latest Unpacked Full Pm Counters File Aic    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}/counters_vcu
    Verify Any Counters In File    M55112C05501  +1  X2_SGNB_ADD_PREP_FAIL_OVLCP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
    Verify Any Counters In File    M55112C05501  +1  X2_SGNB_ADD_PREP_FAIL_OVLCP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True
    Verify Any Counters In File    M55124C00023    +5    SA_RRC_ESTAB_NEME_FAIL_OVLDU
    ...    M55166C00019    +1    SA_RRC_RESUME1_NEME_FAIL_OVLDU
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE_VDU}
    ...    report_pm_counter=True
    Verify Any Counters In File    M55124C00023    +5    SA_RRC_ESTAB_NEME_FAIL_OVLDU
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    file_path=${PM_COUNTER_FILE_VDU}

    ${proc}    ${log_path}    ${pcap2_alias}=    Start Tcpdump on remote interface Aic    log_filename_prefix=F1AP_1
    ...    log_dirpath=${OUTPUT_DIR}/${TEST_NAME}    alias=pcap2
    Perform online overload deactivation
    Verify Tcpdump Log    packet_filter=${F1AP_CU_NOT_OVERLOADED_INFORMATION}    pcap_file_path=${log_path}    alias=pcap2
    Start Tshark    log_filename=x2_uu_1.pcap    eth_interface=any    capture_filter=sctp    alias=pcap3    log_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Attach UE    ue_id=11
    Deregister UE    ue_id=11
    Attach Ue To Enb    ue_id=807
    Start Gnb Addition Procedure    ue=807    target_gnb=2    target_cells=1    bearer=2    dc_type=split_scg
    Detach UE    ue_id=807
    Check If RRCReject Is Not Visible    pcap_file_path=x2_uu_1.pcap    alias=pcap3
    Verify successful SgNBAddition    log_filename=x2_uu_1.pcap    alias=pcap3
    Stop Tshark    alias=pcap3

    ${proc}    ${log_path}    ${pcap4_alias}=    Start Tcpdump on remote interface Aic    log_filename_prefix=F1AP_2
    ...    log_dirpath=${OUTPUT_DIR}/${TEST_NAME}    alias=pcap4
    Perform online overload activation
    Verify Tcpdump Log    packet_filter=${F1AP_CU_OVERLOADED_INFORMATION}    pcap_file_path=${log_path}    relation_symbol= >    alias=pcap4
    Start Tshark    log_filename=x2_uu_2.pcap    eth_interface=any    capture_filter=sctp    alias=pcap5    log_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Register Multiple UEs    first_ue_id=5    last_ue_id=6
    Trigger Dual Connectivity For NSA UE 806 To Cell 3
    Verify Count of RRC Rejects    count=2    log_filename=x2_uu_2.pcap    alias=pcap5
    Verify SgNBAdditionRequestReject count    count=1    log_filename=x2_uu_2.pcap    alias=pcap5
    Detach UE    ue_id=806
    Stop Tshark    alias=pcap5

    ${proc}    ${log_path}    ${pcap6_alias}=    Start Tcpdump on remote interface Aic    log_filename_prefix=F1AP_3
    ...    log_dirpath=${OUTPUT_DIR}/${TEST_NAME}    alias=pcap6
    Change CPUE Flags To Default Values
    Verify Tcpdump Log    packet_filter=${F1AP_CU_NOT_OVERLOADED_INFORMATION}    pcap_file_path=${log_path}    alias=pcap6
    Start Tshark    log_filename=x2_uu_3.pcap    eth_interface=any    capture_filter=sctp    alias=pcap7    log_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Attach Ue To Enb    ue_id=808
    Start Gnb Addition Procedure    ue=808    target_gnb=2    target_cells=1    bearer=2    dc_type=split_scg
    Verify successful SgNBAddition    log_filename=x2_uu_3.pcap    alias=pcap7
    Detach UE    ue_id=808
    Attach UE    ue_id=12
    Deregister UE    ue_id=12
    Check If RRCReject Is Not Visible    pcap_file_path=x2_uu_3.pcap    alias=pcap7
    Stop Tshark    alias=pcap7

    ${proc}    ${log_path}    ${pcap8_alias}=    Start Tcpdump on remote interface Aic    log_filename_prefix=F1AP_4
    ...    log_dirpath=${OUTPUT_DIR}/${TEST_NAME}    alias=pcap8
    Enable full overload on CPUE pod
    Enable full overload on CPRT pod
    Verify Tcpdump Log    packet_filter=${F1AP_CU_OVERLOADED_INFORMATION}    pcap_file_path=${log_path}    relation_symbol= >    alias=pcap8
    Verify Tcpdump Log    packet_filter=${F1AP_GNBDU_OVERLOADED_INFORMATION}    pcap_file_path=${log_path}    relation_symbol= >    alias=pcap8
    Start Tshark    log_filename=x2_uu_4.pcap    eth_interface=any    capture_filter=sctp    alias=pcap9    log_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Register Multiple UEs    first_ue_id=5    last_ue_id=6
    Trigger Dual Connectivity For NSA UE 805 To Cell 3
    Detach UE    ue_id=805
    Change CPUE Flags To Default Values
    Verify Tcpdump Log    packet_filter=${F1AP_CU_NOT_OVERLOADED_INFORMATION}    pcap_file_path=${log_path}    alias=pcap8
    Verify Tcpdump Log    packet_filter=${F1AP_GNBDU_NOT_OVERLOADED_INFORMATION}    number_of_messages=0    pcap_file_path=${log_path}    alias=pcap8
    Trigger Dual Connectivity For NSA UE 808 To Cell 3
    Detach UE    ue_id=808
    Verify SgNBAdditionRequestReject count    count=2    log_filename=x2_uu_4.pcap    alias=pcap9
    Register Multiple UEs    first_ue_id=1    last_ue_id=2
    Verify Count of RRC Rejects    count=4    log_filename=x2_uu_4.pcap    alias=pcap9
    Stop Tshark    alias=pcap9

    ${proc}    ${log_path}    ${pcap10_alias}=    Start Tcpdump on remote interface Aic    log_filename_prefix=F1AP_5
    ...    log_dirpath=${OUTPUT_DIR}/${TEST_NAME}    alias=pcap10
    Enable full overload on CPUE pod
    Verify Tcpdump Log    packet_filter=${F1AP_CU_OVERLOADED_INFORMATION}    pcap_file_path=${log_path}    relation_symbol= >    alias=pcap10
    Verify Tcpdump Log    packet_filter=${F1AP_GNBDU_OVERLOADED_INFORMATION}    pcap_file_path=${log_path}    relation_symbol= >    alias=pcap10
    Change CPRT Flags To Default Values
    Verify Tcpdump Log    packet_filter=${F1AP_CU_NOT_OVERLOADED_INFORMATION}    number_of_messages=0    pcap_file_path=${log_path}    alias=pcap10
    Verify Tcpdump Log    packet_filter=${F1AP_GNBDU_NOT_OVERLOADED_INFORMATION}    pcap_file_path=${log_path}    alias=pcap10
    Start Tshark    log_filename=x2_uu_5.pcap    eth_interface=any    capture_filter=sctp    alias=pcap11    log_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Trigger Dual Connectivity For NSA UE 810 To Cell 1
    Verify SgNBAdditionRequestReject count    count=1    log_filename=x2_uu_5.pcap    alias=pcap11
    Detach UE    ue_id=810
    Attach UE    ue_id=13    pass_regexp=UE13: Registering
    Verify Count of RRC Rejects    count=1    log_filename=x2_uu_5.pcap    alias=pcap11
    Stop Tshark    alias=pcap11

CB012584_Additional_countermeasures_applying_during_CU_and_DU_overload
    [Documentation]    This user scenario validates the gNB-DU and gNB-CU behaviour when CPlane enters DU or CU or both
    ...                CU and DU overload condition.
    [Tags]     TC6
    [Setup]    Run Keywords    Start Default Logging Aic      output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...    AND                 Start netcat
    ...    AND                 Start TCE trace
    ...    AND                 Perform delta recommissioning vCU    ${CURDIR}/config/initial_delta_TC6_vcu.json
    ...    AND                 Commission handover params if needed    ${CURDIR}/config/handover_params.json
    [Teardown]    Run Keywords    Stop Tcpdump on remote interface
    ...     AND                   Stop netcat
    ...     AND                   Stop Tshark    alias=tce_trace_pcap
    ...     AND                   Perform delta recommissioning vCU    ${CURDIR}/config/teardown_delta_TC6_vcu.json
    ...     AND                   Perform delta recommissioning vDU    ${CURDIR}/config/teardown_delta_TC6_vdu.json
    ...     AND                   Stop Default Logging Aic
    ...     AND                   Change CPRT Flags To Default Values
    ...     AND                   Change CPUE Flags To Default Values

    Wait For Next Full Pm Interval Aic
    Register UE and start data traffic    ue_id=1
    Enable full overload on CPRT pod
    Verify Tcpdump Log    packet_filter=${F1AP_GNBDU_OVERLOADED_INFORMATION}    relation_symbol= >
    Change UE location    ue_id=100    dst_enb=3    dst_cell=1
    Register UE and start data traffic    ue_id=100
    Perform UE handover    ue_id=100    tgt_phycell_id=50
    Verify NG Handover Failure
    Verify TCE Messages    packet_filter=${NSETAPX_REPORT} && ${NGAP_HANDOVER_FAILURE_OVERLOAD}

    Perform UE handover    ue_id=1    tgt_phycell_id=51    type=intra-gNB
    Verify TCE Messages    packet_filter=${NSETAPX_REPORT} && ${NRRRC_MEASUREMENT_REPORT_PCI_51}
    Verify current cell for UE    ue_id=1    cell=1

    Perform EN-DC for UE with bearer addition and verify result    result=reject    ue_id=808    target_gnb=2
    ...    target_cells=1    log_filename=x2ap0.pcap    alias=pcap0_x2ap
    Verify TCE Messages    packet_filter=${NSETAPX_REPORT} && ${X2AP_MODIFICATION_REJECT_OVL}

    Attach Ue To Enb    ue_id=809
    Start Gnb Addition Procedure    ue=809    target_gnb=2    target_cells=1    bearer=2    dc_type=split_scg
    Sleep    1    reason=countermeasure will not be applied immediately after SgNBAddition
    IntraENB handover    ue_id=809    dst_cell=2
    # Same message as in previous step, so second message will be visible in default pcap:
    Verify Ngap Messages    packet_filter=${X2AP_MODIFICATION_REJECT_OVL}    number_of_messages=2
    Verify TCE Messages    packet_filter=${NSETAPX_REPORT} && ${X2AP_MODIFICATION_REJECT_OVL}    number_of_messages=2
    Detach UE    ue_id=809

    Change CPRT Flags To Default Values
    Enable full overload on CPUE pod
    Verify Tcpdump Log    packet_filter=${F1AP_GNBDU_NOT_OVERLOADED_INFORMATION}
    Verify Tcpdump Log    packet_filter=${F1AP_CU_OVERLOADED_INFORMATION}    relation_symbol= >

    Start TCE trace    log_filename=tce1.pcap    alias=pcap1_tce
    Perform UE handover    ue_id=1    tgt_phycell_id=51    type=intra-gNB
    Verify TCE Messages    packet_filter=${NSETAPX_REPORT} && ${NRRRC_MEASUREMENT_REPORT_PCI_51}    pcap_file_path=tce1.pcap    alias=pcap1_tce
    Verify current cell for UE    ue_id=1    cell=1

    Start Tshark    log_filename=ngap1.pcap    eth_interface=eth7    alias=pcap1_ngap    log_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Perform UE handover    ue_id=100    tgt_phycell_id=50
    Verify NG Handover Failure    log_filename=ngap1.pcap    alias=pcap1_ngap
    Verify TCE Messages    packet_filter=${NSETAPX_REPORT} && ${NGAP_HANDOVER_FAILURE_OVERLOAD}    pcap_file_path=tce1.pcap    alias=pcap1_tce
    Stop Tshark    alias=pcap1_ngap

    Perform EN-DC for UE with bearer addition and verify result    result=reject    ue_id=808    target_gnb=2
    ...    target_cells=1    log_filename=x2ap1.pcap    alias=pcap1_x2ap
    Verify TCE Messages    packet_filter=${NSETAPX_REPORT} && ${X2AP_MODIFICATION_REJECT_OVL}    pcap_file_path=tce1.pcap    alias=pcap1_tce
    Stop Tshark    alias=pcap1_tce

    Start TCE trace    log_filename=tce2.pcap    alias=pcap2_tce
    Perform EN-DC for UE with intra-LTE HO and verify result    result=reject    ue_id=809    endc_gnb=2    endc_cells=1
    ...    destination_lte_cell=1    log_filename=x2ap2.pcap    alias=pcap2_x2ap
    Verify TCE Messages    packet_filter=${NSETAPX_REPORT} && ${X2AP_MODIFICATION_REJECT_OVL}    pcap_file_path=tce2.pcap    alias=pcap2_tce
    Stop Tshark    alias=pcap2_tce

    Wait For Next Full Pm Interval Aic
    ${PM_COUNTER_FILE}=    Get Latest Unpacked Full Pm Counters File Aic    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}/counters_vcu
    Verify Any Counters In File
    ...    M55112C05502  2  NX2CC_BEARER_FAIL_OVLCP
    ...    M55125C07527  2  NG_HO_RES_ALC_F_OVLCP_TRG
    ...    M55124C04503  2  NRRCC_SA_MEAS_DISCARD_OVLCP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True
    Verify Any Counters In File
    ...    M55128C01501  2  X2_HO_FAIL_OVLCP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True

    Perform delta recommissioning vCU    ${CURDIR}/config/delta_TC6_vcu.json
    Perform delta recommissioning vDU    ${CURDIR}/config/delta_TC6_vdu.json

    Start Tshark    log_filename=uu1.pcap    eth_interface=eth4    alias=pcap1_uu    log_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Start TCE trace    log_filename=tce3.pcap    alias=pcap3_tce
    Attach UE    ue_id=2    pass_regexp=UE2: Registering
    Verify Count of RRC Rejects    count=1    packet_filter=${NRRRC_REJECT_16s}    alias=pcap1_uu
    Verify TCE Messages    packet_filter=${NSETAPX_REPORT} && ${NRRRC_REJECT_16s}    pcap_file_path=tce3.pcap    alias=pcap3_tce
    Stop Tshark    alias=pcap1_uu
    Stop Tshark    alias=pcap3_tce

    Perform NG handover and verify if it is successful    ue_id=100    phycell_id=50    log_filename=ngap2.pcap
    ...    alias=pcap2_ngap
    Verify current cell for UE    ue_id=100    cell=1    enb=2

    Start TCE trace    log_filename=tce4.pcap    alias=pcap4_tce
    Perform UE handover    ue_id=1    tgt_phycell_id=51    type=intra-gNB
    ...    pass_regex=UE1: Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
    Verify current cell for UE    ue_id=1    cell=2
    Verify TCE Messages    packet_filter=${NSETAPX_REPORT} && ${RRC_RECONFIGURATION_COMPLETE}    alias=pcap4_tce

    Perform EN-DC for UE with bearer addition and verify result    result=success    ue_id=810    target_gnb=2
    ...    target_cells=1    log_filename=x2ap3.pcap    alias=pcap3_x2ap
    Verify TCE Messages    packet_filter=${NSETAPX_REPORT} && ${X2AP_SGNB_MODIFICATION_CONFIRM}    pcap_file_path=tce4.pcap    alias=pcap4_tce
    Stop Tshark    alias=pcap4_tce

    Start TCE trace    log_filename=tce5.pcap    alias=pcap5_tce
    Perform EN-DC for UE with intra-LTE HO and verify result    result=success    ue_id=809    endc_gnb=2    endc_cells=1
    ...    destination_lte_cell=2    log_filename=x2ap4.pcap    alias=pcap4_x2ap
    Verify TCE Messages    packet_filter=${NSETAPX_REPORT} && ${X2AP_SGNB_MODIFICATION_CONFIRM}    pcap_file_path=tce5.pcap    alias=pcap5_tce
    Stop Tshark    alias=pcap5_tce

    Deregister UE    ue_id=1
    Deregister UE    ue_id=100

    Wait For Next Full Pm Interval Aic
    ${PM_COUNTER_FILE}=    Get Latest Unpacked Full Pm Counters File Aic    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}/counters2_vcu
    Verify Any Counters In File
    ...    M55124C04501  1  SA_RRC_ESTAB_NEME_FAIL_OVLCP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True

CB012584_Failure_in_receiving_CU_and_DU_overload_status_due_to_F1_link_break_with_cell_block_unblock
    [Documentation]    This user scenario validates the gNB-DU and gNB-CU behaviour when CPlane enters DU or CU or both
    ...                CU and DU overload condition.
    [Tags]     TC7
    [Setup]    Start Default Logging Aic      output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    [Teardown]    Run Keywords    Stop Tcpdump on remote interface
    ...     AND                   Stop Default Logging Aic
    ...     AND                   Change CPRT Flags To Default Values
    ...     AND                   Change CPUE Flags To Default Values

    Enable full overload on CPRT pod
    Attach Ue To Enb    ue_id=808
    Change Interface Status on Pod    entity=vdu1    pod=cprt    container=nwmgmt    interface=f1c    status=down
    ${proc}    ${log_path}    ${pcap1_alias}=    Start Tcpdump on remote interface Aic    log_filename_prefix=F1AP_1
    ...    log_dirpath=${OUTPUT_DIR}/${TEST_NAME}    alias=pcap1
    Sleep    2    reason=Wait for RepeatOverloadIndicationPeriod timer expiry in CP-RT
    Verify Tcpdump Log    packet_filter=${F1AP_GNBDU_STATUS_INDICATION_ELEMENT}    number_of_messages=0    pcap_file_path=${log_path}    alias=pcap1
    Change Interface Status on Pod    entity=vdu1    pod=cprt    container=nwmgmt    interface=f1c    status=up
    Start Gnb Addition Procedure    ue=808    target_gnb=2    target_cells=1    bearer=2    dc_type=split_scg
    Verify successful SgNBAddition
    Verify SgNBAdditionRequestReject count    count=0
    Verify Tcpdump Log    packet_filter=${F1AP_GNBDU_OVERLOADED_INFORMATION}    pcap_file_path=${log_path}    relation_symbol= >    alias=pcap1

    Trigger Dual Connectivity For NSA UE 809 To Cell 1
    Verify SgNBAdditionRequestReject count    count=1
    Detach UE    ue_id=809
    Lock Single Cell Aic    cell_id=1
    Unlock Single Cell Aic    cell_id=1
    Trigger Dual Connectivity For NSA UE 809 To Cell 1
    Verify SgNBAdditionRequestReject count    count=2    # new reject additional to the old one in default pcap file
    Detach UE    ue_id=808
    Detach UE    ue_id=809

    ${proc}    ${log_path}    ${pcap2_alias}=    Start Tcpdump on remote interface Aic    log_filename_prefix=F1AP_2
    ...    log_dirpath=${OUTPUT_DIR}/${TEST_NAME}    alias=pcap2
    Change CPRT Flags To Default Values
    Enable full overload on CPUE pod
    Verify Tcpdump Log    packet_filter=${F1AP_GNBDU_NOT_OVERLOADED_INFORMATION}    pcap_file_path=${log_path}    alias=pcap2
    Verify Tcpdump Log    packet_filter=${F1AP_CU_OVERLOADED_INFORMATION}    pcap_file_path=${log_path}    relation_symbol= >    alias=pcap2

    Start Tshark    log_filename=x2_uu_1.pcap    eth_interface=eth3    alias=pcap3    log_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Trigger Dual Connectivity For NSA UE 809 To Cell 1
    Verify SgNBAdditionRequestReject count    count=1    log_filename=x2_uu_1.pcap    alias=pcap3
    Detach UE    ue_id=809
    Change Interface Status on Pod    entity=vdu1    pod=cprt    container=nwmgmt    interface=f1c    status=down
    Sleep    2    reason=Wait for RepeatOverloadIndicationPeriod timer expiry

    Start Tshark    log_filename=Uu_1.pcap    eth_interface=eth4    alias=pcap4    log_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Change Interface Status on Pod    entity=vdu1    pod=cprt    container=nwmgmt    interface=f1c    status=up
    Attach UE    ue_id=1
    Check If RRCReject Is Not Visible    pcap_file_path=Uu_1.pcap    alias=pcap4
    Attach UE    ue_id=2    pass_regexp=UE2: Registering
    Verify Count of RRC Rejects    count=1    log_filename=Uu_1.pcap    alias=pcap4
    Deregister UE    ue_id=1
    Stop Tshark    alias=pcap3
    Stop Tshark    alias=pcap4
