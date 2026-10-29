*** Settings ***

Documentation    :copyright: Nokia

Resource     testsuite/Wroclaw/RRM/resources/airphone/5G_SW_WRO_Keywords.robot
Variables    testsuite/Wroclaw/RRM/resources/airphone/tshark_filters/ngap.py
Library     ta5g_pm_counters
Library     ta5g_iphy
Library     ta5g_enb
Library     ta5g_testline_management
Library     ta5g_ue_measurements
Library     ta5g_delta
# Libraries for tti trace collecting and decoding
Library      taf.collectors.tcpdump    WITH NAME  tct
Library      taf.collectors.l2stream3  WITH NAME  tcl
Library      taf.collectors.core       WITH NAME  tcc
Library      taf.converters.eventdecoder  WITH NAME  tce


*** Keywords ***
Attach UE With Traffic And Send A1 Measurment
    [Arguments]   ${ue_id}    ${cell_id}    ${prefix_name}    ${pdu_session_amount}=1
    ${pdu_session_range}=    Set Variable    ${pdu_session_amount} + 1

    Start TTI Trace Collection
    Change UE Location    ue_id=${ue_id}   dst_enb=2    dst_cell=${cell_id}
    Wait Until Keyword Succeeds    2x    100ms    Attach UE    ue_id=${ue_id}   prb_check=${True}
    Establish Pdu Session With Traffic    ue_id=${ue_id}    pdu_id=${ue_id}    gw_id=${ue_id}

    Log To Console    UE SA additional DL traffic
    FOR    ${index}    IN RANGE    2   5
       Start Data Traffic   ues=${ue_id}    pdu=1    direction=dl     traffic_id=${index}
       ...                  throughput=100Mbps
    END
    Log To Console    UE SA additional UL traffic
    FOR    ${index}    IN RANGE    2   3
       Start Data Traffic   ues=${ue_id}    pdu=1    direction=ul     traffic_id=${index}
       ...                  throughput=100Mbps
    END

    Send A1 Event For S-Cell Addition    ue_id=${ue_id}    scellTechnology=TDD    pcell_id=${cell_id}
    Stop TTI Trace Collection    name=TTI_traces_${prefix_name}


Assert pCI Allocation
    [Arguments]   ${ue_id}    ${expected_pCSI_values_list}    ${nrofPRBs}

    ${pCsi_value1} =    Get Value Of CSI StartingPRB    ue_id=${ue_id}
    ${pCsi_value2} =    Get Value Of CSI SecondHopPRB    ue_id=${ue_id}
    ${nrofPRBs_value} =    Get Value Of NrofPRBs    ue_id=${ue_id}

    List Should Contain Value    ${expected_pCSI_values_list}    ${pCsi_value1}
    ...    msg=pCsi_value1 (${pCsi_value1}) is not in expected values list
    List Should Contain Value    ${expected_pCSI_values_list}    ${pCsi_value2}
    ...    msg=pCsi_value2 (${pCsi_value2}) is not in expected values list
    Should Be Equal    ${nrofPRBs_value}    ${nrofPRBs}
    ...    msg=nrofPRBs value (${nrofPRBs_value}) does not match expected (${nrofPRBs})


Assert Scheduling Request Allocation
    [Arguments]   ${ue_id}    ${expected_sr_values_list}

    ${sr_value1} =    Get Value Of SR startingPRB   ue_id=${ue_id}
    ${sr_value2} =    Get Value Of SR secondHopPRB    ue_id=${ue_id}

    List Should Contain Value    ${expected_sr_values_list}    ${sr_value1}
    ...    msg=pCsi_value1 (${sr_value1}) is not in expected values list
    List Should Contain Value    ${expected_sr_values_list}    ${sr_value2}
    ...    msg=pCsi_value2 (${sr_value2}) is not in expected values list


Start VoNR Data Traffic
    [Arguments]   ${ue_id}

    ${command_vonr_traffic_dl} =  catenate  SEPARATOR=
    ...           cmd=trf_data_start ue=${ue_id} dir=dl trf_id=3 protocol=udp
    ...           \ ack_mode=off cl_trf_stats=on kbps=175 pdu=1 qfi=3
    ${command_vonr_traffic_ul} =  catenate  SEPARATOR=
    ...           cmd=trf_data_start ue=${ue_id} dir=ul trf_id=3 protocol=udp
    ...           \ ack_mode=off cl_trf_stats=on kbps=175 pdu=1 qfi=3

    Execute Egate Command    cmd=${command_vonr_traffic_dl}
    Execute Egate Command    cmd=${command_vonr_traffic_ul}


################### MEASURMENT KEYWORDS ########################
Send A1 Event For S-Cell Addition
    [Arguments]    ${ue_id}=1    ${pcell_id}=1    ${scellTechnology}=FDD    ${srsrp}=127    ${srsrq}=127    ${ssinr}=127
    ...            ${pass_regexp}=message c1 : rrcReconfigurationComplete

    Send Ue Measurement Nr Event A1 Scell Addition With Aligned Meas Id
    ...    ue_id=${ue_id}
    ...    pcell_id=${pcell_id}
    ...    scellTechnology=${scellTechnology}
    ...    pass_regexp=${pass_regexp}
    ...    srsrp_nr=${srsrp}
    ...    srsrq_nr=${srsrq}
    ...    ssinr_nr=${ssinr}
    Sleep    3s    reason=ensure A1 event for S-Cell Addition is sent


Send A2 Event For A5 Configuration
    [Arguments]    ${ue_id}    ${pcell_id}    ${srsrp_nr}=1    ${srsrq_nr}=1
    ...            ${pass_regexp}=message c1 : rrcReconfigurationComplete    ${get_ue_meas_cfg}=${True}

    Send Ue Measurement Nr Event A2 Handover With Aligned Meas Id
    ...    ue_id=${ue_id}
    ...    pcell_id=${pcell_id}
    ...    pass_regexp=${pass_regexp}
    ...    get_ue_meas_cfg=${get_ue_meas_cfg}
    ...    srsrp_nr=${srsrp_nr}
    ...    srsrq_nr=${srsrq_nr}
    Sleep    2s    reason=ensure A2 event is sent


Send A5 Event For Inter-Frequency HO
    [Arguments]    ${ue_id}=1    ${srsrp}=1    ${ssinr}=1    ${srsrq}=1    ${neigh_phycellid}=54
    ...            ${nrsrp}=127    ${nrsrq}=127    ${nsinr}=127    ${pass_regexp}=message c1 : rrcReconfigurationComplete
    ...            ${carrier_freq}=518910

    Send Ue Measurement Nr Event A5 With Aligned Meas Id
    ...    ue_id=${ue_id}
    ...    carrier_freq=${carrier_freq}
    ...    pass_regexp=${pass_regexp}
    ...    srsrp_nr=${srsrp}
    ...    srsrq_nr=${srsrq}
    ...    ssinr_nr=${ssinr}
    ...    phycell_id=${neigh_phycellid}
    ...    nrsrp_nr=${nrsrp}
    ...    nrsrq_nr=${nrsrq}
    ...    nsinr_nr=${nsinr}
    Sleep    3s    reason=ensure A5 Event For Inter-Frequency HO is sent


################### ASSERTIONS KEYWORDS ########################
Verify SCell Addition Messages For 6CC For FDD PCell
    [Arguments]    ${ue_in_order}=1
    Verify Ngap Messages    packet_filter=${NGAP_INITIAL_CONTEXT_SETUP_RESPONSE}
    ...                     number_of_messages=${ue_in_order}    continue_on_failure=${True}
    Verify Tcpdump Log    packet_filter=${F1AP_SCELL_TO_BE_SETUP_MOD_LIST_FDD_PCell}
    ...                   number_of_messages=${ue_in_order}    continue_on_failure=${True}
    Verify Tcpdump Log    packet_filter=${F1AP_SCELL_TO_ADD_MOD_LIST_FDD_PCell}
    ...                   number_of_messages=${ue_in_order}    continue_on_failure=${True}


Verify UL_1_TxSwitching On FDD PCell and TDD Scell
    Verify Tcpdump Log    packet_filter=${UL_1_TXSWITCHING_ON_FDD_PCELL}     continue_on_failure=${True}
    Verify Tcpdump Log    packet_filter=${UL_1_TXSWITCHING_ON_TDD_SCELL}     continue_on_failure=${True}


Verify UL_1_TxSwitching Is Not Set On FDD PCell and TDD Scell
    Verify Tcpdump Log    packet_filter=${UL_1_TXSWITCHING_ON_FDD_PCELL}
    ...                   number_of_messages=0    continue_on_failure=${True}
    Verify Tcpdump Log    packet_filter=${UL_1_TXSWITCHING_ON_TDD_SCELL}
    ...                   number_of_messages=0    continue_on_failure=${True}


Verify UL_2_TxSwitching On FDD PCell and TDD Scell
    Verify Tcpdump Log    packet_filter=${UL_2_TXSWITCHING_ON_FDD_PCELL}     continue_on_failure=${True}
    Verify Tcpdump Log    packet_filter=${UL_2_TXSWITCHING_ON_TDD_SCELL}     continue_on_failure=${True}


Verify UL_2_TxSwitching Is Not Set On FDD PCell and TDD Scell
    Verify Tcpdump Log    packet_filter=${UL_2_TXSWITCHING_ON_FDD_PCELL}
    ...                   number_of_messages=0    continue_on_failure=${True}
    Verify Tcpdump Log    packet_filter=${UL_2_TXSWITCHING_ON_TDD_SCELL}
    ...                   number_of_messages=0    continue_on_failure=${True}


Verify Counters for UL TX
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55181C00010    >1    ACC_NUM_UL_TX_SW_OP1_UE_CAP
    ...    M55118C00053    >1    ACC_NUM_UL_TX_SW_OP1_UE_CONFG
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-7
    ...    file_path=${pm_counter_file}


Verify Counters for UL 2TX
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55181C00014    >1    ACC_NUM_UL_2TX_SW_OP1_UE_CAP
    ...    M55118C00112    >1    ACC_NUM_UL_2TX_SW_OP1_UE_CONFG
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-7
    ...    file_path=${pm_counter_file}


Verify UL TX Counters Are Not Pegged
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55181C00010    0    ACC_NUM_UL_TX_SW_OP1_UE_CAP
    ...    M55118C00053    0    ACC_NUM_UL_TX_SW_OP1_UE_CONFG
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-7
    ...    file_path=${pm_counter_file}


Verify UL 2TX Counters Are Not Pegged
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55181C00014    0    ACC_NUM_UL_2TX_SW_OP1_UE_CAP
    ...    M55118C00112    0    ACC_NUM_UL_2TX_SW_OP1_UE_CONFG
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-7
    ...    file_path=${pm_counter_file}


################### TTI TRACES KEYWORDS ########################
Start TTI Trace Collection
    [Arguments]    ${yaml_file}=tti_trace_collectors.yaml
    ${configurations}=  tcc.Load Configurations
    ...  ${CURDIR}/${yaml_file}
    tcc.Create Collectors    names=l2stream3    configurations=${configurations['collectors']}
    tcl.Set Suite Alias    alias=l2stream3
    tcc.Setup Collectors    names=l2stream3
    tcc.Start Collectors    names=l2stream3


Stop TTI Trace Collection
    [Arguments]    ${name}=default
    tcc.Stop Collectors    names=l2stream3
    tcc.Collect Collectors    names=l2stream3    target_dir=${OUTPUTDIR}/${TESTNAME}/${name}/
    tcc.Teardown Collectors    names=l2stream3
