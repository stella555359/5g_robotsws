*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Madhu
...              :contact: madhusudhan.y@nokia.com

Resource         ../../5GC000937/resources/5GC000937_Keywords.robot
Resource         ../../resources/robot/Airphone.robot
Resource         ../../resources/robot/WTS_Runner_Keywords.robot
Resource         ../../resources/robot/WTS_Runner_BF_CA_HO_Keywords.robot
Resource         ../../resources/robot/PM_Counters.robot
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../../resources/robot/Setup_Env.robot
Library          ../../resources/python/BIP_Capture.py
Library          ../../resources/python/CPRT_Capture.py
Library          ../../resources/python/avg_dl_data.py


#*** Variables ***

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
    ...  pi_id=${PM_counter}    moc=NRCELL-1

Validate PM Counters bigger than
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}
    PM_Counters.Check PM counter value bigger than    expected_value=${expected_value}   pm_files_location=${PM_dir}
    ...  pi_id=${PM_counter}    moc=NRCELL-1
