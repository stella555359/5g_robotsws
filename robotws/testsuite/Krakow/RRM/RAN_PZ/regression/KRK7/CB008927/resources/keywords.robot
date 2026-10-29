*** Settings ***
Documentation
...    Test suite for regression testing for feature CB008927
...    authors: Jakub Bialon
...    maintainer: Jakub Bialon
...    group: RAN_PZ_KRK_SG_7
...    contact: jakub.bialon@nokia.com


Library    ute_ue
Library    tools.py    WITH NAME    tools
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    taf.rfrl.uuf4all.resources.python.uuf_rfrl_common
Library    testsuite/Krakow/resources/RAN_PZ_KRK7/tools/keywords.py    WITH NAME    sg7keywords
Library    testsuite/Krakow/resources/RAN_PZ_KRK7/Quectel_L3_Call/helpers.py    WITH NAME     helper
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py


*** Variables ***
@{EMAIL_NOTIFICATION_RECEIVERS}


*** Keywords ***
Check data transfer with Mediatek
    [Arguments]    ${throughput_DL}
    ...            ${throughput_UL}
    ...            ${parallel_streams_DL}=10
    ...            ${parallel_streams_UL}=5
    ...            ${ue_alias}=${UE_DEFAULT_ALIAS_NAME}
    ...            ${duration}=${DATA_TRANSFER_DEFAULT_DURATION}
    ...            ${packet}=${DEFAULT_PACKET_SIZE}
    ...            ${protocol}=${DEFAULT_PROTOCOL}
    ...            ${deviation}=${DEFAULT_DEVIATION}
    ute_ue.Attach UE    ${ue_alias}
    Sleep    10sec    reason=Waiting for attach procedure take effect
    ute_ue.Get UE Info    ${ue_alias}
    # DL
    ute_ue.Start Data Transfer    dt_name=DT_DL
    ...                           ue_alias=${ue_alias}
    ...                           direction=dl
    ...                           duration=${duration}
    ...                           packet=${packet}
    ...                           throughput=${throughput_DL}
    ...                           protocol=${protocol}
    ...                           parallel_streams=${parallel_streams_DL}
    ...                           linux_congestion=reno
    ...                           apn=5gsakrk
    # UL
    ute_ue.Start Data Transfer    dt_name=DT_UL
    ...                           ue_alias=${ue_alias}
    ...                           direction=ul
    ...                           duration=${duration}
    ...                           packet=${packet}
    ...                           throughput=${throughput_UL}
    ...                           protocol=${protocol}
    ...                           parallel_streams=${parallel_streams_UL}
    ...                           linux_congestion=reno
    ...                           apn=5gsakrk
    Sleep    10sec    reason=Waiting for data transfer stabilization
    ute_ue.Await Data Transfer Finish    dt_name=DT_DL
    ute_ue.Verify Average Throughput With Deviation    dt_name=DT_DL
    ...                                                tput=${throughput_DL}
    ...                                                deviation=${deviation}
    ute_ue.Await Data Transfer Finish    dt_name=DT_UL
    ute_ue.Verify Average Throughput With Deviation    dt_name=DT_UL
    ...                                                tput=${throughput_UL}
    ...                                                deviation=${deviation}
    [Teardown]    ute_ue.Detach UE    ${ue_alias}


Check data transfer with Mediatek With Block And Unblock Cell
    [Arguments]    ${throughput_DL}
    ...            ${throughput_UL}
    ...            ${cell_block}
    ...            ${cell_unblock}
    ...            ${desired_pci}
    ...            ${reverse}=${False}
    ...            ${parallel_streams_DL}=10
    ...            ${parallel_streams_UL}=5
    ...            ${ue_alias}=${UE_DEFAULT_ALIAS_NAME}
    ...            ${duration}=${DATA_TRANSFER_DEFAULT_DURATION}
    ...            ${packet}=${DEFAULT_PACKET_SIZE}
    ...            ${protocol}=${DEFAULT_PROTOCOL}
    ...            ${deviation}=${DEFAULT_DEVIATION}
    ute_ue.Attach UE    ${ue_alias}
    Sleep    10sec    reason=Waiting for attach procedure take effect
    ${UE_INFO}=    ute_ue.Get UE Info    ${ue_alias}    ALL
    ${pci}      convert to string     ${desired_pci}
    helper.Check PCI From Get UE Info    ${UE_INFO}    ${pci}
    Log to console       Start DL traffic
    ute_ue.Start Data Transfer    dt_name=DT_DL
    ...                           ue_alias=${ue_alias}
    ...                           direction=dl
    ...                           duration=${duration}
    ...                           packet=${packet}
    ...                           max_segment_size=${packet}
    ...                           throughput=${throughput_DL}
    ...                           protocol=${protocol}
    ...                           parallel_streams=${parallel_streams_DL}
    ...                           linux_congestion=reno
    Log to console       Start UL traffic
    ute_ue.Start Data Transfer    dt_name=DT_UL
    ...                           ue_alias=${ue_alias}
    ...                           direction=ul
    ...                           duration=${duration}
    ...                           packet=${packet}
    ...                           max_segment_size=${packet}
    ...                           throughput=${throughput_UL}
    ...                           protocol=${protocol}
    ...                           parallel_streams=${parallel_streams_UL}
    ...                           linux_congestion=reno
    Sleep    10sec    reason=Waiting for data transfer stabilization
    sg7keywords.Unblock cells    [${cell_unblock}]
    Sleep    15sec    reason=Triggering reestablishmen
    gnbcell.Verify Cell Is Unblocked    cell_id=${cell_unblock}
    sg7keywords.Block cells    [${cell_block}]
    Sleep    15sec    reason=Triggering reestablishmen
    gnbcell.Verify Cell Is Blocked    cell_id=${cell_block}
    ute_ue.Get UE Info    ${ue_alias}


    ${UE_INFO}=    ute_ue.Get UE Info    ${ue_alias}    ALL
    ${pci}      convert to string     13
    helper.Check PCI From Get UE Info    ${UE_INFO}    ${pci}


    Run Keyword If    ${reverse}    Run Keywords    sg7keywords.Unblock cells    [${cell_block}]    AND
    ...                                             Sleep    15sec    reason=Triggering reestablishmen    AND
    ...                                             gnbcell.Verify Cell Is Unblocked    cell_id=${cell_block}    AND
    ...                                             sg7keywords.Block cells    [${cell_unblock}]    AND
    ...                                             Sleep    15sec    reason=Triggering reestablishmen    AND
    ...                                             gnbcell.Verify Cell Is Blocked    cell_id=${cell_unblock}    AND
    ...                                             ute_ue.Get UE Info    ${ue_alias}


    ute_ue.Await Data Transfer Finish    dt_name=DT_DL
    ute_ue.Verify Average Throughput With Deviation    dt_name=DT_DL
    ...                                                tput=${throughput_DL}
    ...                                                deviation=${deviation}
    ute_ue.Await Data Transfer Finish    dt_name=DT_UL
    ute_ue.Verify Average Throughput With Deviation    dt_name=DT_UL
    ...                                                tput=${throughput_UL}
    ...                                                deviation=${deviation}
    [Teardown]    ute_ue.Detach UE    ${ue_alias}


Get data transfer with Mediatek
    [Arguments]    ${throughput_DL}
    ...            ${throughput_UL}
    ...            ${desired_pci}
    ...            ${parallel_streams_DL}=4
    ...            ${parallel_streams_UL}=2
    ...            ${ue_alias}=${UE_DEFAULT_ALIAS_NAME}
    ...            ${duration}=${DATA_TRANSFER_DEFAULT_DURATION}
    ...            ${packet}=${DEFAULT_PACKET_SIZE}
    ...            ${protocol}=${DEFAULT_PROTOCOL}
    ute_ue.Attach UE    ${ue_alias}
    Sleep    10sec    reason=Waiting for attach procedure take effect
    ${UE_INFO}=    ute_ue.Get UE Info    ${ue_alias}    ALL
    ${pci}      convert to string     ${desired_pci}
    helper.Check PCI From Get UE Info    ${UE_INFO}    ${pci}
    Log to console       Start DL traffic
    ute_ue.Start Data Transfer    dt_name=DT_DL
    ...                           ue_alias=${ue_alias}
    ...                           direction=dl
    ...                           duration=${duration}
    ...                           packet=${packet}
    ...                           max_segment_size=${packet}
    ...                           throughput=${throughput_DL}
    ...                           protocol=${protocol}
    ...                           parallel_streams=${parallel_streams_DL}
    ...                           linux_congestion=reno
    Log to console       Start UL traffic
    ute_ue.Start Data Transfer    dt_name=DT_UL
    ...                           ue_alias=${ue_alias}
    ...                           direction=ul
    ...                           duration=${duration}
    ...                           packet=${packet}
    ...                           max_segment_size=${packet}
    ...                           throughput=${throughput_UL}
    ...                           protocol=${protocol}
    ...                           parallel_streams=${parallel_streams_UL}
    ...                           linux_congestion=reno
    Sleep    10sec    reason=Waiting for data transfer stabilization
    ute_ue.Await Data Transfer Finish    dt_name=DT_DL
    ${dl_tput_value}    ute_ue.get_average_throughput    dt_name=DT_DL
    ute_ue.Await Data Transfer Finish    dt_name=DT_UL
    ${ul_tput_value}    ute_ue.get_average_throughput    dt_name=DT_UL
    [Return]    ${dl_tput_value}    ${ul_tput_value}
    [Teardown]    ute_ue.Detach UE    ${ue_alias}


Check ResourceAllocation Field Value In Pcap File
    [Arguments]    ${result_dir}    ${expected_result_list}    ${time_epoch_no}    ${additional_options}
    ${required_epoch_time}=    tools.Get Time Epoch Of First Rrcreconfiguration Message
    ...                        pcap_file_dir=${result_dir}/tcpdump
    ...                        result_dir=${result_dir}
    ...                        time_epoch_no=${time_epoch_no}
    @{options}    Create List    ${additional_options}
    @{fields_list}    Create List    nr-rrc.resourceAllocation
    @{filters_list}    Create List    nr-rrc
    ...                               nr-rrc.c1
    ...                               nr-rrc.pdsch_ConfigCommon
    ...                               nr-rrc.resourceAllocation
    ...                               (frame.time_epoch == ${required_epoch_time})
    tools.Check Pcap Messages    pcap_file_dir=${result_dir}/tcpdump
    ...                          result_dir=${result_dir}
    ...                          expected_result=${expected_result_list}
    ...                          fields_list=@{fields_list}
    ...                          filters_list=@{filters_list}
    ...                          options=@{options}


Check ResourceAllocation Field Value In Pcap File After Rrcreestablishment Message
    [Arguments]    ${result_dir}    ${expected_result_list}    ${time_epoch_no}    ${additional_options}
    ${required_epoch_time}=    tools.get_time_epoch_of_rrcreestablishment_message
    ...                        pcap_file_dir=${result_dir}/tcpdump
    ...                        result_dir=${result_dir}
    ...                        time_epoch_no=${time_epoch_no}
    @{options}    Create List    ${additional_options}
    @{fields_list}    Create List    nr-rrc.resourceAllocation
    @{filters_list}    Create List    nr-rrc
    ...                               nr-rrc.c1
    ...                               nr-rrc.pdsch_ConfigCommon
    ...                               nr-rrc.resourceAllocation
    ...                               (frame.time_epoch > ${required_epoch_time})
    tools.Check Pcap Messages    pcap_file_dir=${result_dir}/tcpdump
    ...                          result_dir=${result_dir}
    ...                          expected_result=${expected_result_list}
    ...                          fields_list=@{fields_list}
    ...                          filters_list=@{filters_list}
    ...                          options=@{options}


Check Rat0Bitmap Filed Value In Bip Logs
    [Arguments]    ${result_dir}    ${expected_result_list}
    @{filter_list}=    Create List    DlData_PdschGrant.rat0Bitmap !== 0
    tools.Check Pcap Messages    pcap_file_dir=${result_dir}/BipCollectorAdmin_GNB0_DU0
    ...                          result_dir=${result_dir}
    ...                          expected_result=@{expected_result_list}
    ...                          filters_list=@{filter_list}


Set attenuation level in dB for NR and LTE Cells
    [Arguments]       ${db_level_nr}      ${db_level_lte}      ${lte_cell_list}
    ...      ${nr_cell_list}
    FOR    ${port}    IN    @{nr_cell_list}
        tools.setup_attenuation_for_nr_and_lte_cells         port=${port}
        ...         value=${db_level_nr}
    END
    FOR    ${port}    IN    @{lte_cell_list}
        tools.setup_attenuation_for_nr_and_lte_cells         port=${port}
        ...         value=${db_level_lte}
    END


Prepare UE for NSA L3 Call
    [Arguments]      ${band_lte}      ${band_nr}
    Log to console         Preparing UE for NSA L3 Call
    ute_ue.Require UE      ${UE_DEFAULT_ALIAS_NAME}    capabilities=QUECTEL_UE
    Adjust Apn             ${UE_DEFAULT_ALIAS_NAME}    pdp_type=IP     apn_name=5gkrk
    Change Network Mode    ${UE_DEFAULT_ALIAS_NAME}    NR5G:LTE    ue_type=quectel
    Set Active Bands       ${UE_DEFAULT_ALIAS_NAME}    LTE     ${band_lte}
    Set Active Bands       ${UE_DEFAULT_ALIAS_NAME}    NSA_NR5G    ${band_nr}
    Run Keyword And Ignore Error    ute_ue.Detach UE    ${UE_DEFAULT_ALIAS_NAME}


Teardown_01_A
    Set attenuation level in dB for NR and LTE Cells     db_level_nr=110dB     db_level_lte=110dB
    ...      lte_cell_list=@{EMPTY}
    ...      nr_cell_list=@{CELL_ALL_PORTS}
    sg7keywords.Unblock cells    [11,12]
    ${delta}=    tools.Prepare Parameters Delta    distname=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-12
    ...                                            parameter=actRat1Alloc
    ...                                            value=false
    Perform Delta Commissioning On gNB    delta=${delta}
    ${delta}=    tools.Prepare Parameters Delta    distname=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-13
    ...                                            parameter=actRat1Alloc
    ...                                            value=false
    Perform Delta Commissioning On gNB    delta=${delta}


Teardown_13_L
    Set attenuation level in dB for NR and LTE Cells     db_level_nr=110dB     db_level_lte=110dB
    ...      lte_cell_list=@{EMPTY}
    ...      nr_cell_list=@{CELL_ALL_PORTS}
    sg7keywords.Unblock cells    [12,13]
    ${delta}=    tools.Prepare Parameters Delta    distname=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-11
    ...                                            parameter=actDlDynSwitchAlloc
    ...                                            value=false
    Perform Delta Commissioning On gNB    delta=${delta}
    ${delta}=    tools.Prepare Parameters Delta    distname=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-11
    ...                                            parameter=actRat1Alloc
    ...                                            value=false
    Perform Delta Commissioning On gNB    delta=${delta}


Teardown_17_E
    Set attenuation level in dB for NR and LTE Cells     db_level_nr=110dB     db_level_lte=110dB
    ...      lte_cell_list=@{EMPTY}
    ...      nr_cell_list=@{CELL_ALL_PORTS}
    sg7keywords.Unblock cells    [11,13]
    ${delta}=    tools.Prepare Parameters Delta    distname=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-12
    ...                                            parameter=actDlDynSwitchAlloc
    ...                                            value=false
    Perform Delta Commissioning On gNB    delta=${delta}
    ${delta}=    tools.Prepare Parameters Delta    distname=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-12
    ...                                            parameter=actRat1Alloc
    ...                                            value=false
    Perform Delta Commissioning On gNB    delta=${delta}


Teardown_10_J
    ${delta}=    tools.Prepare Parameters Delta    distname=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-121
    ...                                            parameter=actDlDynSwitchAlloc
    ...                                            value=false
    Perform Delta Commissioning On gNB    delta=${delta}
    ${delta}=    tools.Prepare Parameters Delta    distname=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-121
    ...                                            parameter=actRat1Alloc
    ...                                            value=false
    Perform Delta Commissioning On gNB    delta=${delta}
    sg7keywords.Unblock cells    [0,103]


Verify On-Air Status
    Wait Until Keyword Succeeds     180 sec    10 sec    gnbru.Verify All Radio Units are Online
    Wait Until Keyword Succeeds     180 sec    10 sec    gnbcell.Verify All Cells are OnAir
    Verify gNB is onAir
    ${antennas_expect_error}=    Set Variable
    ...    InvalidStatuses: status not found {'operationalstate': 'enabled', 'localstate': 'unblocked',
    Run Keyword And Expect Error    STARTS: ${antennas_expect_error}    gnb_asir.Verify All Antennas Are Enabled
    ${cell_expect_error}=    Set Variable    InvalidStatuses: Unexpected statuses
    Run Keyword And Expect Error    ${cell_expect_error}    gnb_asir.Verify Status Of All Asir Cells Is Operational
