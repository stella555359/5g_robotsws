*** Settings ***
Documentation
...    :copyright: Nokia
...    :author: Sylwester Sowa
...    :maintainer: Sylwester Sowa, Krzysztof Wojnar
...    :contact: sylwester.sowa@nokia.com; krzysztof.wojnar@nokia.com

...    This test suite covers U-Plane overload cases, including robustness scenarios.



Force Tags    CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC    RF50

Resource    ./resources/CB012584_keywords.robot


Suite Setup       Suite Setup Uplane Overload

Suite Teardown    Suite Teardown Uplane Overload

*** Test Cases ***
CB012584_gNB-DU_uplane_and_cplane_successively_enter_overload_state
    [Documentation]    This test case verifies the gNB-DU behaviour when UPlane and CPlane enter overload condition
    ...                successively.
    [Tags]     TC1
    [Setup]    Run Keywords    Start Default Logging Aic      output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...    AND    Setup RRC inactive UE    wait_for_inactivity=no    only_one_ue=yes
    [Teardown]    Run Keywords    Stop Default Logging Aic
    ...    AND    Execute Egate Command    cmd=ue_kill id=1-154
    ...    AND    Change CPRT Flags To Default Values

    Wait For Next Full Pm Interval Aic    vdu=1
    Register Multiple UEs with PDU session    first_ue_id=1    last_ue_id=19    attach_delay=2.2    pdu_delay=0.8
    Start Traffic For Multiple UEs    first_ue_id=1    last_ue_id=19    dir=ul    traffic=5    unit=Mbps
    Check If RRCReject Is Not Visible

    Attach UE    ue_id=21    pass_regexp=UE21: Registering
    Verify Count of RRC Rejects    count=1

    Enable full overload on CPRT pod
    Attach UE    ue_id=22    pass_regexp=UE22: Registering
    Resume RRC inactive UE    traffic=10    delay=2
    Attach UE    ue_id=40    cell=3    enb=2    pass_regexp=UE40: Registering
    Verify Count of RRC Rejects    count=4
    Execute Egate Command    cmd=ue_kill id=151

    Register emergency UE and verify RRC reject is not visible    ue_id=153    pcap=Uu_1.pcap    alias=pcap1
    Change UE location    ue_id=154    dst_enb=2    dst_cell=3
    Register emergency UE and verify RRC reject is not visible    ue_id=154    pcap=Uu_2.pcap    alias=pcap2

    Start Tshark    log_filename=Uu_3.pcap    eth_interface=eth4    capture_filter=sctp    alias=pcap3    log_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Stop Traffic For Multiple UEs    first_ue_id=1    last_ue_id=19    dir=ul
    Attach UE    ue_id=23    pass_regexp=UE23: Registering
    Attach UE    ue_id=41    cell=3    enb=2    pass_regexp=UE41: Registering
    Verify Count of RRC Rejects    count=2    log_filename=Uu_3.pcap    alias=pcap3
    Stop Tshark    alias=pcap3

    Wait For Next Full Pm Interval Aic    vdu=1
    ${PM_COUNTER_FILE}=    Get Latest Unpacked Full PM Counters File Aic    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}/counters_vdu1    vdu=1
    ${PM_COUNTER_FILE_RD}=    Get Latest Unpacked Full RD Counters File Aic    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}/counters_vdu1_rd    vdu=1
    Verify Any Counters In File
    ...    M55166C00019    0    SA_RRC_RESUME1_NEME_FAIL_OVLDU
    ...    M55166C00020    2    RRC_ESTAB_NEME_FAIL_OVLDU_UP
    ...    M55166C00021    1    RRC_RESUME1_NEME_FAIL_OVLDU_UP
    ...    M55124C00023    1    SA_RRC_ESTAB_NEME_FAIL_OVLDU
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True
    Verify Any Counters In File
    ...    M55124C00023    2    SA_RRC_ESTAB_NEME_FAIL_OVLDU
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    file_path=${PM_COUNTER_FILE}
    Verify Any Counters In File
    ...    RRC_NEME_FAIL_SCH_OVLDU_UP    3    RRC_NEME_FAIL_SCH_OVLDU_UP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE_RD}
    ...    report_pm_counter=True

    Deregister UE without confirmation    ue_id=1-23
    Deregister UE without confirmation    ue_id=40-41

CB012584_UPlane_scheduling_overload_multiple_activation_and_deactivation
    [Documentation]    This test case verifies the gNB-DU behaviour when UPlane enters and leaves scheduling overload
    ...                condition multiple times in multiple ways.
    [Tags]     TC4
    [Setup]    Start Default Logging Aic      output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    [Teardown]    Run Keywords    Stop Default Logging Aic
    ...    AND    Execute Egate Command    cmd=ue_kill id=1-123

    Register Multiple UEs with PDU session    first_ue_id=1    last_ue_id=12    attach_delay=1.5    pdu_delay=0.7
    # Adding more UEs but with less traffic possible in case of throughput instability in egate
    Start Traffic For Multiple UEs    first_ue_id=1    last_ue_id=12    dir=dl    traffic=8    unit=Mbps    stabi_time=1
    Check If RRCReject Is Not Visible

    Wait For Next Full Pm Interval Aic    vdu=1
    Attach UE    ue_id=21    pass_regexp=UE21: Registering
    Verify Count of RRC Rejects    count=1

    Verify Tcpdump Log    packet_filter=${F1AP_GNBDU_OVERLOADED_INFORMATION}    number_of_messages=0
    Perform EN-DC for UE and verify result    result=success    ue_id=808    log_filename=x2ap1.pcap    alias=pcap1_x2ap

    Change multiple UEs location without confirmation    first_ue_id=61    last_ue_id=72    dst_enb=2    dst_cell=2
    Change multiple UEs location without confirmation    first_ue_id=81    last_ue_id=92    dst_enb=2    dst_cell=3
    Change multiple UEs location without confirmation    first_ue_id=101    last_ue_id=112    dst_enb=2    dst_cell=4
    Register Multiple UEs with PDU session    first_ue_id=61    last_ue_id=72    attach_delay=1.5    pdu_delay=0.8
    Start Traffic For Multiple UEs    first_ue_id=61    last_ue_id=72    dir=dl    traffic=8    unit=Mbps    stabi_time=3
    Register Multiple UEs with PDU session    first_ue_id=81    last_ue_id=92    attach_delay=1.5    pdu_delay=0.9
    Start Traffic For Multiple UEs    first_ue_id=81    last_ue_id=92    dir=dl    traffic=8    unit=Mbps    stabi_time=3
    Register Multiple UEs with PDU session    first_ue_id=101    last_ue_id=112    attach_delay=1.5    pdu_delay=1
    Start Traffic For Multiple UEs    first_ue_id=101    last_ue_id=112    dir=dl    traffic=8    unit=Mbps    stabi_time=15
    Verify Tcpdump Log    packet_filter=${F1AP_GNBDU_OVERLOADED_INFORMATION}    relation_symbol= >

    Attach UE    ue_id=40    cell=2    enb=2    pass_regexp=UE40: Registering
    Attach UE    ue_id=41    cell=3    enb=2    pass_regexp=UE41: Registering
    Attach UE    ue_id=42    cell=4    enb=2    pass_regexp=UE42: Registering
    Verify Count of RRC Rejects    count=4    # one old + 3 new

    Start Tshark    log_filename=x2ap2.pcap    eth_interface=eth3    capture_filter=sctp    alias=pcap2_x2ap
    ...    log_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Trigger Dual Connectivity For NSA UE 804 To Cell 2
    Trigger Dual Connectivity For NSA UE 805 To Cell 3
    Trigger Dual Connectivity For NSA UE 808 To Cell 4
    Verify SgNBAdditionRequestReject count    count=3    log_filename=x2ap2.pcap    alias=pcap2_x2ap
    Stop Tshark    alias=pcap2_x2ap
    Detach UE    ue_id=804
    Detach UE    ue_id=805
    Detach UE    ue_id=808

    Establish PDU session and verify it is rejected    ue_id=1    pdu_id=2
    Deregister UE without confirmation    ue_id=81-92
    Deregister UE without confirmation    ue_id=101-112

    Start Tshark    log_filename=Uu_3.pcap    eth_interface=eth4    capture_filter=sctp    alias=pcap3    log_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Verify Tcpdump Log    packet_filter=${F1AP_GNBDU_NOT_OVERLOADED_INFORMATION}    relation_symbol= >=
    Attach UE    ue_id=121    cell=3    enb=2
    Attach UE    ue_id=122    cell=4    enb=2
    Check If RRCReject Is Not Visible    pcap_file_path=Uu_3.pcap    alias=pcap3
    Attach UE    ue_id=123    pass_regexp=UE123: Registering
    Verify Count of RRC Rejects    count=1    log_filename=Uu_3.pcap    alias=pcap3
    Stop Tshark    alias=pcap3

    Perform EN-DC for UE and verify result    result=success    ue_id=808    log_filename=x2ap3.pcap    alias=pcap3_x2ap
    Perform EN-DC for UE and verify result    result=success    ue_id=809    endc_cells=4    log_filename=x2ap4.pcap    alias=pcap4_x2ap

    Wait For Next Full Pm Interval Aic    vdu=1
    ${PM_COUNTER_FILE}=    Get Latest Unpacked Full PM Counters File Aic    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}/counters_vdu1    vdu=1
    ${PM_COUNTER_FILE_RD}=    Get Latest Unpacked Full RD Counters File Aic    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}/counters_vdu1_rd    vdu=1
    ${PM_COUNTER_FILE_VCU}=    Get Latest Unpacked Full Pm Counters File Aic    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}/counters_vcu
    Verify Any Counters In File
    ...    M55166C00020    2    RRC_ESTAB_NEME_FAIL_OVLDU_UP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True
    Verify Any Counters In File
    ...    M55166C00020    1    RRC_ESTAB_NEME_FAIL_OVLDU_UP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${PM_COUNTER_FILE}
    Verify Any Counters In File
    ...    M55166C00020    1    RRC_ESTAB_NEME_FAIL_OVLDU_UP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    file_path=${PM_COUNTER_FILE}
    Verify Any Counters In File
    ...    M55166C00020    1    RRC_ESTAB_NEME_FAIL_OVLDU_UP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4
    ...    file_path=${PM_COUNTER_FILE}
    Verify Any Counters In File
    ...    M55112C05501  0  X2_SGNB_ADD_PREP_FAIL_OVLCP
    ...    M55125C06001  1  SA_PDU_SES_NEME_STP_FAIL_OVLCP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE_VCU}
    ...    report_pm_counter=True
    Verify Any Counters In File
    ...    M55112C05501  1  X2_SGNB_ADD_PREP_FAIL_OVLCP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${PM_COUNTER_FILE_VCU}
    Verify Any Counters In File
    ...    M55112C05501  1  X2_SGNB_ADD_PREP_FAIL_OVLCP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    file_path=${PM_COUNTER_FILE_VCU}
    Verify Any Counters In File
    ...    M55112C05501  1  X2_SGNB_ADD_PREP_FAIL_OVLCP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4
    ...    file_path=${PM_COUNTER_FILE_VCU}
    Verify Any Counters In File
    ...    RRC_NEME_FAIL_SCH_OVLDU_UP    2    RRC_NEME_FAIL_SCH_OVLDU_UP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE_RD}
    Verify Any Counters In File
    ...    RRC_NEME_FAIL_SCH_OVLDU_UP    1    RRC_NEME_FAIL_SCH_OVLDU_UP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${PM_COUNTER_FILE_RD}
    Verify Any Counters In File
    ...    RRC_NEME_FAIL_SCH_OVLDU_UP    1    RRC_NEME_FAIL_SCH_OVLDU_UP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    file_path=${PM_COUNTER_FILE_RD}
    Verify Any Counters In File
    ...    RRC_NEME_FAIL_SCH_OVLDU_UP    1    RRC_NEME_FAIL_SCH_OVLDU_UP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4
    ...    file_path=${PM_COUNTER_FILE_RD}
    ...    report_pm_counter=True

    Perform Parameter Commissioning Vdu Aic    parameter=actOvlProtL2Sched    value=false    dist_name=MRBTS-1/NRBTS-1

    Start Tshark    log_filename=Uu_4.pcap    eth_interface=eth4    capture_filter=sctp    alias=pcap4    log_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Attach UE    ue_id=22
    Attach UE    ue_id=23    cell=2    enb=2
    Check If RRCReject Is Not Visible    pcap_file_path=Uu_4.pcap    alias=pcap4
    Stop Tshark    alias=pcap4
    Deregister UE    ue_id=22
    Deregister UE    ue_id=23

    Perform Parameter Commissioning Vdu Aic    parameter=actOvlProtL2Sched    value=true    dist_name=MRBTS-1/NRBTS-1

    Start Tshark    log_filename=Uu_5.pcap    eth_interface=eth4    capture_filter=sctp    alias=pcap5    log_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Attach UE    ue_id=22    pass_regexp=UE22: Registering
    Attach UE    ue_id=23    cell=2    enb=2    pass_regexp=UE23: Registering
    Verify Count of RRC Rejects    count=2    log_filename=Uu_5.pcap    alias=pcap5
    Stop Tshark    alias=pcap5

    Deregister UE without confirmation    ue_id=1-123

CB012584_multiple_gNB-DU_UPlane_overload_criteria_met_for_the_same_cell
    [Documentation]    This test case verifies the gNB-DU behaviour when multiple UPlane overload conditions are
    ...                met for the same cell.
    [Tags]     TC5
    [Setup]    Run Keywords    Start Default Logging Aic      output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...    AND    Wait For Next Full Pm Interval Aic    vdu=1
    ...    AND    Setup RRC inactive UE    wait_for_inactivity=no    only_one_ue=yes
    [Teardown]    Run Keywords    Stop Default Logging Aic
    ...    AND    Execute Egate Command    cmd=ue_kill id=1-34

    Register Multiple UEs with PDU session    first_ue_id=1    last_ue_id=19    attach_delay=2.2    pdu_delay=0.8
    Start Traffic For Multiple UEs    first_ue_id=1    last_ue_id=19    dir=dl    traffic=1    unit=kbps
    Check If RRCReject Is Not Visible
    Perform Parameter Commissioning Vdu Aic    parameter=actOvlProtL2Sig    value=true    dist_name=MRBTS-1/NRBTS-1

    Start Tshark    log_filename=Uu_1.pcap    eth_interface=eth4    capture_filter=sctp    alias=pcap1    log_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Register UEs In Loop Signaling    ue_range=51-60
    Check RRC Reject For At Least Given Number Of Messages    num_of_msg=1
    ${num_of_rejects_signaling}=    Get number of RRC Rejects in pcap file    pcap=Uu_1.pcap    alias=pcap1
    Stop Tshark    alias=pcap1

    Start Traffic For Multiple UEs    first_ue_id=1    last_ue_id=19    dir=dl    traffic=5    unit=Mbps

    Start Tshark    log_filename=Uu_2.pcap    eth_interface=eth4    capture_filter=sctp    alias=pcap2    log_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Resume RRC inactive UE
    Attach UE    ue_id=31    pass_regexp=UE31: Registering
    Attach UE    ue_id=32    pass_regexp=UE32: Registering
    Verify Count of RRC Rejects    count=3    log_filename=Uu_2.pcap    alias=pcap2
    Execute Egate Command    cmd=ue_kill id=151
    Stop Tshark    alias=pcap2

    Stop Traffic For Multiple UEs    first_ue_id=1    last_ue_id=19    dir=dl

    Start Tshark    log_filename=Uu_3.pcap    eth_interface=eth4    capture_filter=sctp    alias=pcap3    log_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Attach UE    ue_id=33    pass_regexp=UE33: Registering
    Verify Count of RRC Rejects    count=1    log_filename=Uu_3.pcap    alias=pcap3
    Stop Tshark    alias=pcap3

    Wait For Next Full Pm Interval Aic    vdu=1
    ${PM_COUNTER_FILE}=    Get Latest Unpacked Full PM Counters File Aic    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}/counters_vdu1    vdu=1
    ${PM_COUNTER_FILE_RD}=    Get Latest Unpacked Full RD Counters File Aic    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}/counters_vdu1_rd    vdu=1
    ${signaling_setup_reject_count}=    Get Sum of Rejects    ${num_of_rejects_signaling}    3
    ${all_reject_count}=    Get Sum of Rejects    ${num_of_rejects_signaling}    4
    Verify Any Counters In File
    ...    M55166C00020    ${signaling_setup_reject_count}    RRC_ESTAB_NEME_FAIL_OVLDU_UP  # count with additional setup reject minus resume reject
    ...    M55166C00021    1    RRC_RESUME1_NEME_FAIL_OVLDU_UP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True
    Verify Any Counters In File
    ...    RRC_NEME_FAIL_SIG_OVLDU_UP    ${all_reject_count}    RRC_NEME_FAIL_SIG_OVLDU_UP
    ...    RRC_NEME_FAIL_SCH_OVLDU_UP    3    RRC_NEME_FAIL_SCH_OVLDU_UP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE_RD}
    ...    report_pm_counter=True

    Deregister UE without confirmation    ue_id=1-33
