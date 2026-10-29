*** Settings ***
Documentation   :copyright: Nokia
...             :authors: Kiran Vilas Gawade
...             :contact: kiran.vilas_gawade@nokia.com
...            Reference TC : /5GET_BLR/CB007149/CB007149-C-B1_30MHz_Cell_Bandwidth_FR1-FDD_CA_With_AHFIB_Radio_SA.robot

Resource    ../../../5GC000937/resources/5GC000937_Keywords.robot
Resource    ../../../resources/robot/Airphone.robot
Resource    ../../../resources/robot/WTS_Runner_Keywords.robot
Resource    ../../../resources/robot/WTS_Runner_BF_CA_HO_Keywords.robot
Resource    ../../../resources/robot/PM_Counters.robot
Library     taf.transport.ssh    WITH NAME     taf_ssh
Library     taf.wts.runner   WITH NAME        wtsrunner
Resource    taf/rfrl/common_resources/robot/coam.robot
Resource    ../../../resources/robot/Setup_Env.robot
Library     ../../../resources/python/BIP_Capture.py
Library     ../../../resources/python/CPRT_Capture.py
Library     ../../../resources/python/avg_dl_data.py

*** Variables ***

${scell_pattern}    .*SCellIndex 1 act.*

*** Keywords ***
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
    Should Be True    ${pcell_tput} < ${90}
    Verify There is No TPUT On Scell    ue_id=${UE_ID}    scell_idx=1


Verify Scell added successfully
    [Arguments]     ${ue_id}        ${loc_BW}=
	${output}   wtsrunner.read_wtsemu_output_until_re    expected=${scell_pattern}  timeout=15
    Get Lines Matching Regexp    ${output}    SCellIndex \\d+ activated successfully  partial_match=${TRUE}
#    Run Keyword and Continue on failure     BuiltIn.Should Match Regexp     ${output}    locationAndBandwidth\\s${loc_BW}
    Run Keyword and Continue on failure     BuiltIn.Should Match Regexp     ${output}
    ...     sCellConfigDedicated.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*locationAndBandwidth\\s${loc_BW}
    Log to Console    ${output}

Start DL data Transfer for 2CC
    log to console   verify Scell activation...
    Run keyword and ignore error    Start Collecting Syslog       NAME=scell_add
    Start 400 Mbps Big DL Data Transfer And Check SCell Activation for 2CC
    sleep    5s
    Run Keyword And Continue on Failure    Validate DL Traffic For SA for high data   ue_id=${UE_ID}     dl_rate=400
    ...   qfi_id=${QFI_ID}
    Run Keyword And Ignore Error    Validate DL Traffic For SA for high data   ue_id=${UE_ID}     dl_rate=400        qfi_id=${QFI_ID}
#    Run Keyword And Continue on Failure    Verify DL Tput For 2CC TDD FDD CA

Start Big DL data and verify Scell activation through A1 measurement based
    log to console   verify Scell activation...
    Run keyword and ignore error    Start Collecting Syslog       NAME=scell_add
    Start 400 Mbps Big DL Data Transfer And Check SCell Activation for 2CC
    sleep    5s
    Run Keyword And Continue on Failure    Validate DL Traffic For SA for high data   ue_id=${UE_ID}     dl_rate=310
    ...   qfi_id=${QFI_ID}
    Get Configured Measurements of UE${UE_ID}
    Start CPRT Trace Capturing
#    Start L2 BIP Trace Capturing
    Trigger A1 Measurement and verify Scell added successfully     3     1     13750
#    Run Keyword And Ignore Error    Stop L1L2 capture  ${CaptureL1L2}
    Run Keyword And Ignore Error     Stop CPRT capture   ${CaptureCPRT}
    Run keyword and ignore error    Stop Collecting Syslog       NAME=scell_add
#    Run Keyword And Ignore Error    Move File    ${LOG_PATH}/L1L2_GNB_L1B_BO.pcap       ${LOG_PATH}/BIP_Scell_activation_highdata.pcap
    Run Keyword And Ignore Error    Move File    ${LOG_PATH}/NODECPRT_GNB.pcap          ${LOG_PATH}/Scell_activation_highdata_cprt.pcap
    Run Keyword And Ignore Error    Validate DL Traffic For SA for high data   ue_id=${UE_ID}     dl_rate=350        qfi_id=${QFI_ID}
#    Run Keyword And Continue on Failure    Verify DL Tput For 2CC TDD FDD CA

Start low DL data and verify Scell deactivation
    log to console   verify Scell deactivation...
#    Run keyword and ignore error    Start Collecting Syslog     NAME=scell_remove
#   Start CPRT Trace Capturing
#    Start L2 BIP Trace Capturing
	Start Low Data Traffic And Check Scell Deactivation
    sleep    5s
#	Stop CPRT capture   ${CaptureCPRT}
#    Stop L1L2 capture  ${CaptureL1L2}
#   Run keyword and ignore error    Stop Collecting Syslog       NAME=scell_remove
#   Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_GNB_scell_remove.pcap
#    Move File    ${LOG_PATH}/L1L2_GNB_L1B_BO.pcap    ${LOG_PATH}/BIP_scellremove.pcap
    Verify Low Data Traffic
    Run Keyword And Continue on Failure    Validate DL Traffic For SA for high data   ue_id=${UE_ID}     dl_rate=0.010
    ...      qfi_id=${QFI_ID}

Start 400 Mbps Big DL Data Transfer And Check SCell Activation for 2CC
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=150       trf_id=1
    sleep   5s
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=150       trf_id=2
    sleep   5s    reason=Wait for successful traffic start
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=150       trf_id=3
    sleep   5s

Start UL Data Transfer for 2CC
    Trigger UL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     ul_rate=15       trf_id=1
    sleep   5s
    Trigger UL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     ul_rate=15       trf_id=2
    sleep   5s    reason=Wait for successful traffic start

Start Low Data Traffic And Check Scell Deactivation
	Trigger DL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=kbps     dl_rate=10       trf_id=7      qfi_id=${QFI_ID}
    sleep   5s
    Trigger UL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=kbps     ul_rate=10       trf_id=7      qfi_id=${QFI_ID}
    sleep   5s    reason=Wait for successful traffic start
	TRF Data Stop for SA    ue_id=${UE_ID}    trf_id=1    dir=dl     pdu_id=${Pdu_session_ID}
	Sleep  2s
	TRF Data Stop for SA    ue_id=${UE_ID}    trf_id=2    dir=dl     pdu_id=${Pdu_session_ID}
	Sleep  2s
	TRF Data Stop for SA    ue_id=${UE_ID}    trf_id=3    dir=dl     pdu_id=${Pdu_session_ID}
	Sleep  2s

Validate PM Counters_pcell_scell
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}    ${moc}
    PM_Counters.Check PM counter value equal    expected_value=${expected_value}   pm_files_location=${PM_dir}
    ...  pi_id=${PM_counter}    moc=${moc}

Validate PM Counters_pcell_scell_tput
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}    ${moc}
    PM_Counters.Check PM counter value not equal    not_expected_value=${expected_value}   pm_files_location=${PM_dir}
    ...  pi_id=${PM_counter}    moc=${moc}

Verify Counters 2CC_FDD_TDD_CA
    [Arguments]     ${EXPECTED_PCELL_VALUE}     ${EXPECTED_PCELL_VALUE1}
    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER1}       expected_value=${EXPECTED_PCELL_VALUE}
    ...     moc=NRCELL-2
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER2}       expected_value=${EXPECTED_PCELL_VALUE}
    ...      moc=NRCELL-2
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_SCELL_COUNTER1}       expected_value=${EXPECTED_PCELL_VALUE}
    ...      moc=NRCELL-1
    Validate PM Counters_pcell_scell_tput    PM_dir=${PM_dir_1}    PM_counter=${PM_tput_COUNTER_dl}      expected_value=${EXPECTED_PCELL_VALUE1}
    ...     moc=NRCELL-2
    Validate PM Counters_pcell_scell_tput    PM_dir=${PM_dir_1}    PM_counter=${PM_tput_COUNTER_ul}      expected_value=${EXPECTED_PCELL_VALUE1}
    ...     moc=NRCELL-2
    Validate PM Counters_pcell_scell_tput    PM_dir=${PM_dir_1}    PM_counter=${PM_tput_COUNTER_dl}      expected_value=${EXPECTED_PCELL_VALUE1}
    ...     moc=NRCELL-1
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_tput_COUNTER_ul}      expected_value=${EXPECTED_PCELL_VALUE1}
    ...     moc=NRCELL-1

Verify Counters 2CC_TDD_FDD_CA
    [Arguments]     ${EXPECTED_PCELL_VALUE}     ${EXPECTED_PCELL_VALUE1}
    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER1}       expected_value=${EXPECTED_PCELL_VALUE}
    ...     moc=NRCELL-1
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER2}       expected_value=${EXPECTED_PCELL_VALUE}
    ...      moc=NRCELL-1
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_SCELL_COUNTER1}       expected_value=${EXPECTED_PCELL_VALUE}
    ...      moc=NRCELL-2
    Validate PM Counters_pcell_scell_tput    PM_dir=${PM_dir_1}    PM_counter=${PM_tput_COUNTER_dl}      expected_value=${EXPECTED_PCELL_VALUE1}
    ...     moc=NRCELL-1
    Validate PM Counters_pcell_scell_tput    PM_dir=${PM_dir_1}    PM_counter=${PM_tput_COUNTER_ul}      expected_value=${EXPECTED_PCELL_VALUE1}
    ...     moc=NRCELL-1
    Validate PM Counters_pcell_scell_tput    PM_dir=${PM_dir_1}    PM_counter=${PM_tput_COUNTER_dl}      expected_value=${EXPECTED_PCELL_VALUE1}
    ...     moc=NRCELL-2
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_tput_COUNTER_ul}      expected_value=${EXPECTED_PCELL_VALUE1}
    ...     moc=NRCELL-2

Verify DL Tput For 2CC TDD FDD CA
    ${pcell_tput}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${UE_ID}    scell_idx=0    unit=Mbps
    ${scell_tput}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${UE_ID}    scell_idx=1    unit=Mbps
    Should Be True    ${pcell_tput} > ${250}
    Should Be True    ${scell_tput} > ${50}
