*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Nagesh K V
...              :contact: nagesh.k_v@nokia.com

#Resource         ../../5GC000937/resources/5GC000937_Keywords.robot
Resource         ../../resources/robot/Airphone.robot
Resource         ../../resources/robot/WTS_Runner_Keywords.robot
Resource         ../../resources/robot/WTS_Runner_BF_CA_HO_Keywords.robot
Resource         ../../resources/robot/PM_Counters.robot
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
#Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../../resources/robot/Setup_Env.robot
Library          ../../resources/python/BIP_Capture.py
Library          ../../resources/python/CPRT_Capture.py
Library          ../../resources/python/avg_dl_data.py
Library          taf.sbts.oam.coam.admin     WITH NAME    coam

*** Variables ***
${Ng_link_pattern}    NG link is Up
${Address_distribution_pattern}      Address Distribution is complete
${Cell_setup_complete_pattern}       Cell Setup completed
${UE_SIB_decoding_pattern}           SystemInformationBlockType1
${UE_register_complete_pattern}      .*REGISTRATION COMPLETE.*
${Register_complete_pattern}         REGISTRATION COMPLETE
${Initial_context_setup_pattern}     Initial Context Setup Successful
${Initial_UE_message_pattern}        I\nnitial UE Message Success
${Initial_UE_success_pattern}        .*Initial UE Message Success.*
${Pdu_session_mod_patten}      Pdu Session Resource Modify Response Message with RAN UE NGAP ID 0 handled successfully
${Pdu_session_qos_patten}      QoS Routing Table
${pdu_addition_pattern}        Pdu Session Resource Setup Response Message
${pdu_del_pattern}             Received Pdu Session Resource Release Response Message
${UE_deregister_pattern}       UE Context Release Complete
${X2_link_pattern}             ENB-1: X2AP Link with GNB-2 .* is up
${LTE_attach_pattern}          UE IS ACTIVE
${UE_attach_pattern}           reported successful RA
${UE_5GDetach_pattern}         Bearer-type change from SCG-split to MCG
${UE_detach_pattern}           detached
${UE_reattach_pattern}         UE IS ACTIVE
${UE_RLF_pattern}     radioNetwork: rl-failure-rlc
${Trf_type}    internal
${GUI_Snapshot}    False

${Timeout_SA}    40
${Timeout_NSA}    300
${Total_Timeout}    5 min
${Retry_Timeout}    15 sec
${UE_Reattach_sleep}    20 sec
${UE_ID_SANSA}    11
${eNB_ID}    1
${eNB_target}    2
${Target_gNB}    2
${Target_Cells}    1
${Target_Cells_tdd}    1
${bearer_id}    2
${Traffic_ul_rate_SA}    3
${Traffic_ul_rate_FDD}    3
${Traffic_ul_rate_TDD}    5
${Traffic_dl_rate}    5
${Traffic_ul_rate_TDD_mmwv}    2
${EXPECTED_PCELL_VALUE1}    0

*** Keywords ***

UE Attach should be Successful  #NSA
    [Arguments]    ${UE_ID}
    [Documentation]    This keyword is used to Attach the UE with gNB and check the completion message in output file.
    wtsrunner.enb_ue_dc_start    target_gnb=${Target_gNB}    target_cells=${Target_Cells}    ue=${UE_ID}
    ...                         bearer=${Bearer_ID}    type=split_scg
    ${output}    Read WTS Output For Pattern And Print matching Lines    ${UE_attach_pattern}    ${Timeout_NSA}
    [Return]      ${output}

UE Attach for HO should be Successful  #NSA
    [Arguments]    ${UE_ID}
    [Documentation]    This keyword is used to Attach the UE with gNB and check the completion message in output file.
    wtsrunner.enb_ue_dc_start    target_gnb=3    target_cells=3    ue=${UE_ID}
    ...                         bearer=${Bearer_ID}    type=split_scg
    ${output}    Read WTS Output For Pattern And Print matching Lines    ${UE_attach_pattern}    ${Timeout_NSA}
    [Return]      ${output}

UE Attach for IntraGnb HO should be Successful  #NSA
    [Arguments]    ${UE_ID}
    [Documentation]    This keyword is used to Attach the UE with gNB and check the completion message in output file.
    wtsrunner.enb_ue_dc_start    target_gnb=2    target_cells=1    ue=${UE_ID}
    ...                         bearer=${Bearer_ID}    type=split_scg
    ${output}    Read WTS Output For Pattern And Print matching Lines    ${UE_attach_pattern}    ${Timeout_NSA}
    [Return]      ${output}

TDD UE Attach should be Successful  #NSA
    [Arguments]    ${UE_ID}
    [Documentation]    This keyword is used to Attach the UE with gNB and check the completion message in output file.
    wtsrunner.enb_ue_dc_start    target_gnb=${Target_gNB}    target_cells=${Target_Cells_tdd}    ue=${UE_ID}
    ...                         bearer=${Bearer_ID}    type=split_scg
    ${output}    Read WTS Output For Pattern And Print matching Lines    ${UE_attach_pattern}    ${Timeout_NSA}
    [Return]      ${output}

Trigger DL Traffic for NSA
    [Arguments]    ${ue_id}        ${Traffic_rate}     ${dl_rate}       ${id}=${bearer_id}    ${trf_id}=${TRF_ID}
    [Documentation]    This keyword starts the DL Traffic for the SA variant
    Log to Console    \nRunning DL Traffic for ${dl_rate} ${Traffic_rate}...
    wtsrunner.trf_data_start     ue=${ue_id}    id=${id}   dir=dl    trf_id=${trf_id}      ${Traffic_rate}=${dl_rate}
    ${output}   wtsrunner.read_wtsemu_output_until_re        expected=UDP DL TRF: .*    timeout=10
#    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    ${output}         Get Lines Matching Regexp    ${output}    UDP DL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
    BuiltIn.Log    DL_traffic_data_is_started_successfully

Trigger UL Traffic for NSA
    [Arguments]    ${ue_id}        ${Traffic_rate}     ${ul_rate}       ${id}=${bearer_id}    ${trf_id}=${TRF_ID}
    [Documentation]    This keyword starts the UL Traffic for the SA variant
    Log to Console    \nRunning UL Traffic for ${ul_rate} ${Traffic_rate}...
    wtsrunner.trf_data_start     ue=${ue_id}    id=${id}   dir=ul    trf_id=${trf_id}     ${Traffic_rate}=${ul_rate}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=UDP UL TRF: .*    timeout=10
#    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    ${output}         Get Lines Matching Regexp    ${output}    UDP UL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
    BuiltIn.Log    UL_traffic_data_is_started_successfully

Validate DL Traffic For NSA
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. DL Bytes Received must be equal to ALL Bytes Sent
    [Arguments]    ${ue_id}     ${id}=${bearer_id}
    ${output1}       wtsrunner.bearer_stats  ue=${ue_id}   id=${id}   dir=dl
#    ${bearer_stat_dl}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
#    ...                     timeout=30
#    Check Average Rate      ${bearer_stat_dl}    DL    ${dl_rate}
#    Check DL Data Loss      ${bearer_stat_dl}    ${bearer_stat_dl}
    Log to Console    ${output1}

Fetch the egateconsole prints
    [Arguments]
    [Documentation]    This keyword starts the max 175 UL data Traffic for the SA variant
    Log to Console    \nFetching the egate console
#    wtsrunner.trf_data_start     ue=${ue_id}    pdu=${pdu_id}    dir=ul    ${Traffic_rate}=${ul_rate}    trf_id=${trf_id}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=*UE16:*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UE16:    partial_match=${TRUE}
    Log to Console    ${output}
    BuiltIn.Log    Fetched the egate logs

Verify locationAndBandwith for allocated BWP on Scelladdition
    [Arguments]      ${logpath}     ${locationandbandwidth_value}
    [Documentation]      this KW Verifies the largeBWP or smallBWP or PSBWP from locationAndBandwith IE captured CPRT logs
    log to console       Verifies the value of largeBWP or smallBWP or PSBWP from locationAndBandwith IE captured CPRT logs
    ${pdmlFile} =    Get filtered PDML file from pcap     ${logpath}    nr-rrc.rrcReconfiguration_element
    ${pdml_entries}    taf_pdml_analyser.get_pdml_entries     ${pdmlFile}
	...          field_name=nr-rrc.sCellConfigDedicated_element      attrib_name=showname     attrib_value=sCellConfigDedicated
	${attrib_values}    taf_pdml_analyser.get_attrib_value_from_pdml_entries    ${pdml_entries}
    ...    field_name=nr-rrc.locationAndBandwidth    attrib_name=showname
    ${attrib_values}     convert to string    ${attrib_values}
    should contain    ${attrib_values}     ${locationandbandwidth_value}

Verify locationAndBandwith for allocated BWP during Initial access
    [Arguments]      ${logpath}     ${locationandbandwidth_value}
    [Documentation]      this KW Verifies the value of largeBWP or smallBWP or PSBWP from locationAndBandwith IE captured CPRT logs
    log to console       Verifies the value of largeBWP or smallBWP or PSBWP from locationAndBandwith IE captured CPRT logs
    ${pdmlFile} =    Get filtered PDML file from pcap     ${logpath}    nr-rrc.rrcReconfiguration_element
    ${pdml_entries}    taf_pdml_analyser.get_pdml_entries     ${pdmlFile}
	...          field_name=nr-rrc.spCellConfigDedicated_element      attrib_name=showname     attrib_value=spCellConfigDedicated
	${attrib_values}    taf_pdml_analyser.get_attrib_value_from_pdml_entries    ${pdml_entries}
    ...    field_name=nr-rrc.locationAndBandwidth    attrib_name=showname
    ${attrib_values}     convert to string    ${attrib_values}
    should contain    ${attrib_values}    ${locationandbandwidth_value}

Start Big DL Data Transfer And Check SCell Activation for 2CC
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=170       trf_id=${TRF_ID}
    sleep   5s
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=170       trf_id=${TRF_ID2}
    sleep   15s    reason=Wait for successful traffic start

Start Big DL Data Transfer And Check SCell Activation for 3CC
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=170       trf_id=${TRF_ID}
    sleep   5s
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=170       trf_id=${TRF_ID2}
    sleep   5s
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=170       trf_id=${TRF_ID4}
    sleep   15s    reason=Wait for successful traffic start

Start Low Data Traffic And Check Scell Deactivation for 2CC
	Trigger DL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=kbps     dl_rate=10       trf_id=${TRF_ID3}      qfi_id=${QFI_ID}
    sleep   5s
    Trigger UL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=kbps     ul_rate=10       trf_id=${TRF_ID3}      qfi_id=${QFI_ID}
    sleep   5s    reason=Wait for successful traffic start
	TRF Data Stop for SA    ue_id=${UE_ID}    trf_id=${TRF_ID}    dir=dl     pdu_id=${Pdu_session_ID}
	TRF Data Stop for SA    ue_id=${UE_ID}    trf_id=${TRF_ID2}    dir=dl    pdu_id=${Pdu_session_ID}
    Sleep    10s

Start Low Data Traffic And Check Scell Deactivation for 3CC
	DL TRF Data Stop for SA    ue_id=${UE_ID}    pdu_id=${Pdu_session_ID}    dir=dl    trf_id=${TRF_ID}
	sleep   5s
	DL TRF Data Stop for SA    ue_id=${UE_ID}    pdu_id=${Pdu_session_ID}    dir=dl    trf_id=${TRF_ID2}
	sleep   5s
	DL TRF Data Stop for SA    ue_id=${UE_ID}    pdu_id=${Pdu_session_ID}    dir=dl    trf_id=${TRF_ID4}
    Sleep    5s
    Trigger DL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=kbps     dl_rate=10       trf_id=${TRF_ID3}      qfi_id=${QFI_ID}
    sleep   5s
    Trigger UL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=kbps     ul_rate=10       trf_id=${TRF_ID3}      qfi_id=${QFI_ID}
    sleep   5s    reason=Wait for successful traffic start

Verify DL Tput For 2CC
    ${pcell_tput}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${UE_ID}    scell_idx=0    unit=Mbps
    ${scell_tput}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${UE_ID}    scell_idx=1    unit=Mbps
    Should Be True    ${pcell_tput} > ${150}
    Should Be True    ${scell_tput} > ${130}

Verify DL Tput For 2CC NSA
    ${pcell_tput}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${UE_ID}    scell_idx=8    unit=Mbps
    ${scell_tput}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${UE_ID}    scell_idx=9    unit=Mbps
    Should Be True    ${pcell_tput} > ${150}
    Should Be True    ${scell_tput} > ${150}

Verify DL Tput For 3CC
    ${pcell_tput}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${UE_ID}    scell_idx=0    unit=Mbps
    ${scell_tput}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${UE_ID}    scell_idx=1    unit=Mbps
    ${scell_tput1}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${UE_ID}    scell_idx=2    unit=Mbps
    Should Be True    ${pcell_tput} > ${100}
    Should Be True    ${scell_tput} > ${150}
    Should Be True    ${scell_tput1} > ${150}

Verify Low Data Traffic
    ${pcell_tput}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${UE_ID}    scell_idx=0    unit=Kbps
    Should Be True    ${pcell_tput} < ${60}
    Verify There is No TPUT On Scell    ue_id=${UE_ID}    scell_idx=1

Verify Low Data Traffic NSA
    ${pcell_tput}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${UE_ID}    scell_idx=8    unit=Kbps
    Should Be True    ${pcell_tput} < ${60}
    Verify There is No TPUT On Scell    ue_id=${UE_ID}    scell_idx=9

Start Low Data Traffic And Check Scell Deactivation 2CC NSA
	Trigger DL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=kbps     dl_rate=10       trf_id=${TRF_ID3}
    sleep   5s
    Trigger DL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=kbps     dl_rate=10       trf_id=${TRF_ID3}
    sleep   5s    reason=Wait for successful traffic start
	TRF Data Stop for SA    ue_id=${UE_ID}    pdu_id=${Pdu_session_ID}    trf_id=${TRF_ID}    dir=dl
	TRF Data Stop for SA    ue_id=${UE_ID}    pdu_id=${Pdu_session_ID}     trf_id=${TRF_ID2}    dir=dl
    Sleep    10s

Start Big DL Data Transfer And Check SCell Activation for 2CC NSA
    Trigger DL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=170       trf_id=${TRF_ID}
    sleep   5s
    Trigger DL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=170       trf_id=${TRF_ID2}
    sleep   5s
    Trigger DL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=170       trf_id=${TRF_ID3}
    Sleep   5s
    Trigger DL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=170       trf_id=${TRF_ID4}
    sleep   15s    reason=Wait for successful traffic start

Verify Counters
    sleep    600s
    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Validate PM Counters    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER1}    expected_value=${EXPECTED_PCELL_VALUE1}
    Validate PM Counters    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER2}    expected_value=${EXPECTED_PCELL_VALUE2}
    Validate PM Counters    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER3}    expected_value=${EXPECTED_PCELL_VALUE3}
    Validate PM Counters    PM_dir=${PM_dir_1}    PM_counter=${PM_SCELL_COUNTER1}    expected_value=${EXPECTED_SCELL_VALUE1}
    Validate PM Counters    PM_dir=${PM_dir_1}    PM_counter=${PM_SCELL_COUNTER2}    expected_value=${EXPECTED_SCELL_VALUE2}

Validate PM Counters
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}
    PM_Counters.Check PM counter value equal    expected_value=${expected_value}   pm_files_location=${PM_dir}
    ...  pi_id=${PM_counter}    moc=NRCELL

Validate PM Counters for BTS
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}
    PM_Counters.Check PM counter value equal    expected_value=${expected_value}   pm_files_location=${PM_dir}
    ...  pi_id=${PM_counter}    moc=NRBTS-1

Validate PM Counters bigger than
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}
    PM_Counters.Check PM counter value bigger than    expected_value=${expected_value}   pm_files_location=${PM_dir}
    ...  pi_id=${PM_counter}    moc=NRCELL-1

Validate PM Counters bigger than for BTS
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}
    PM_Counters.Check PM counter value bigger than    expected_value=${expected_value}   pm_files_location=${PM_dir}
    ...  pi_id=${PM_counter}    moc=NRBTS-1

Validate PM Counters bigger than for cell3
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}
    PM_Counters.Check PM counter value bigger than    expected_value=${expected_value}   pm_files_location=${PM_dir}
    ...  pi_id=${PM_counter}    moc=NRCELL-3

Verify Counters CB007564 CFRA INIT
    sleep    240s
    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Validate PM Counters bigger than    PM_dir=${PM_dir_1}    PM_counter=M55306C09000    expected_value=0
    Validate PM Counters bigger than    PM_dir=${PM_dir_1}    PM_counter=M55306C09003    expected_value=0
    Validate PM Counters bigger than    PM_dir=${PM_dir_1}    PM_counter=M55125C09021    expected_value=0

Verify Counters CB007564 CBRA INIT
    sleep    240s
    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Validate PM Counters bigger than    PM_dir=${PM_dir_1}    PM_counter=M55306C09006    expected_value=0
    Validate PM Counters bigger than    PM_dir=${PM_dir_1}    PM_counter=M55306C09008    expected_value=0

Verify Counters CB007564 CBRA HO
    sleep    240s
    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Validate PM Counters bigger than for cell3    PM_dir=${PM_dir_1}    PM_counter=M55306C09007    expected_value=0

Verify Counters CB007564 CFRA HO
    sleep    240s
    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Validate PM Counters bigger than for cell3    PM_dir=${PM_dir_1}    PM_counter=M55125C09022    expected_value=0
    Validate PM Counters bigger than for cell3    PM_dir=${PM_dir_1}    PM_counter=M55306C09001    expected_value=0
    Validate PM Counters bigger than for cell3    PM_dir=${PM_dir_1}    PM_counter=M55306C09004    expected_value=0

Check counter value is non zero
    [Arguments]   ${Counter_on}
    Run keyword and continue on failure  Should be true  ${Counter_on} > 0

Validate PM Counters equal to for cell3
	[Arguments]      ${PM_dir_1}       ${PM_counter}    ${expected_value}
    PM_Counters.Check PM counter value equal     expected_value=${expected_value}    pm_files_location=${PM_dir_1}
    ...  pi_id=${PM_counter}    moc=NRCELL-3

Validate PM Counters equal to for cell4
	[Arguments]      ${PM_dir_1}       ${PM_counter}    ${expected_value}
    PM_Counters.Check PM counter value equal     expected_value=${expected_value}    pm_files_location=${PM_dir_1}
    ...  pi_id=${PM_counter}    moc=NRCELL-4

Validate PM Counters equal to for cell2
    [Arguments]      ${PM_dir_1}     ${PM_counter}      ${expected_value}
    PM_Counters.Check PM counter value equal     expected_value=${expected_value}    pm_files_location=${PM_dir_1}
    ...  pi_id=${PM_counter}    moc=NRCELL-2

Verify Counters CB007564 CFRA HO EDA
#    sleep    200s
    Wait until the current Measurement Period stops
    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Validate PM Counters equal to for cell2     ${PM_dir_1}     PM_counter=M55306C09006     expected_value=1
    Validate PM Counters equal to for cell2     ${PM_dir_1}     PM_counter=M55306C09007     expected_value=1
    Validate PM Counters equal to for cell2     ${PM_dir_1}     PM_counter=M55306C09011     expected_value=1
    Validate PM Counters equal to for cell3     ${PM_dir_1}     PM_counter=M55306C09001     expected_value=1
	Validate PM Counters equal to for cell3     ${PM_dir_1}     PM_counter=M55125C09022     expected_value=1
    Validate PM Counters equal to for cell2     ${PM_dir_1}     PM_counter=M55306C09015     expected_value=2

Verify Counters CB007564 CBRA HO EDA
#    sleep    200s
    Wait until the current Measurement Period stops
    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
#    Run Keyword and Ignore Error    Validate PM Counters equal to for cell2    ${PM_dir_1}    PM_counter=M55306C09006
    Validate PM Counters equal to for cell3     ${PM_dir_1}    PM_counter=M55306C09007     expected_value=1
#    Run Keyword and Ignore Error    Validate PM Counters equal to for cell3    ${PM_dir_1}    PM_counter=M55306C09011
#    Run Keyword and Ignore Error    Validate PM Counters equal to for cell2    ${PM_dir_1}    PM_counter=M55306C09015
	Validate PM Counters equal to for cell3     ${PM_dir_1}    PM_counter=M55306C09015     expected_value=1

Verify Counters CB007564 CFRA HO EDA GMC
#    sleep    200s
    Wait until the current Measurement Period stops
    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Validate PM Counters equal to for cell3     ${PM_dir_1}     PM_counter=M55306C09006     expected_value=1
    Validate PM Counters equal to for cell3     ${PM_dir_1}     PM_counter=M55306C09007     expected_value=1
    Validate PM Counters equal to for cell3     ${PM_dir_1}     PM_counter=M55306C09011     expected_value=1
    Validate PM Counters equal to for cell4     ${PM_dir_1}     PM_counter=M55306C09001     expected_value=1
	Validate PM Counters equal to for cell4     ${PM_dir_1}     PM_counter=M55125C09022     expected_value=1
    Validate PM Counters equal to for cell3     ${PM_dir_1}     PM_counter=M55306C09015     expected_value=2

Verify Counters CB007564 CBRA HO EDA GMC
#    sleep    200s
    Wait until the current Measurement Period stops
    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
#    Run Keyword and Ignore Error    Validate PM Counters equal to for cell2    ${PM_dir_1}    PM_counter=M55306C09006
    Validate PM Counters equal to for cell4     ${PM_dir_1}    PM_counter=M55306C09007     expected_value=1
#    Run Keyword and Ignore Error    Validate PM Counters equal to for cell3    ${PM_dir_1}    PM_counter=M55306C09011
#    Run Keyword and Ignore Error    Validate PM Counters equal to for cell2    ${PM_dir_1}    PM_counter=M55306C09015
	Validate PM Counters equal to for cell4     ${PM_dir_1}    PM_counter=M55306C09015     expected_value=1
