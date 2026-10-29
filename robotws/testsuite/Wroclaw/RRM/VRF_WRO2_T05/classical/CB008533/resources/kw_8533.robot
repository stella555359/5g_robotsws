*** Settings ***
Documentation
...   author: PZ_2_WRO_5

Library         testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002640/resources/keywords_2640.py

*** Variables ***
${ssh_add}      toor4nsn@192.168.255.129

*** Keywords ***
Set attenuation for 8533-AB5-1
    Log to Console    >Attenuation set to 0dB for RMODs: 2-AHLOA, 4,5-AEHC, 8-AHFIB Others: -90dB.<
    Set attenuation and check    lines=${lines_gNB_410_AHLOA_1_FDD}   value=0
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AEHC_4_TDD}    value=0
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AHFIB_8_FDD}   value=0
    Log to Console  >Attenuators have been set for 8533-AB5-1.<

Set attenuation for 8533-AB11-1
    Log to Console    >Attenuation set to 0dB for RMODs: 2-AHLOA, 4-AEHC. Others: -90dB.<
    Set attenuation and check    lines=${lines_gNB_410_AHLOA_2_FDD}   value=0
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AEHC_4_TDD}    value=0
    Log to Console  >Attenuators have been set for 8533-AB5-1. Currently: 2CC CA F+T.<

Perform inter-frequency handover for 3CC CA
    Set attenuation and check    lines=${lines_gNB_410_AEHC_4_TDD}    value=70
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AEHC_4_TDD}    value=50
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AEHC_4_TDD}    value=30
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AEHC_4_TDD}    value=10
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AEHC_4_TDD}    value=0
    Sleep  3s
    Log to Console  >Handover and TDD SCellAddition completed. Currently: 3CC CA F+T+T.<

Perform inter-frequency handover for 4CC CA
    Set attenuation and check    lines=${lines_gNB_410_AHFIB_8_FDD}    value=70
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AHFIB_8_FDD}    value=50
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AHFIB_8_FDD}    value=30
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AHFIB_8_FDD}    value=10
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AHFIB_8_FDD}    value=0
    Sleep  3s
    Log to Console  >Handover and FDD SCellAddition completed. Currently: 4CC CA 2F+2T.<

Perform FDD and TDD SCells Release for 2CC CA
    Set attenuation and check    lines=${lines_gNB_410_AHFIB_7_FDD}    value=10
    Set attenuation and check    lines=${lines_gNB_410_AEHC_5_TDD}    value=10
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AHFIB_7_FDD}    value=30
    Set attenuation and check    lines=${lines_gNB_410_AEHC_5_TDD}    value=30
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AHFIB_7_FDD}    value=50
    Set attenuation and check    lines=${lines_gNB_410_AEHC_5_TDD}    value=50
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AHFIB_7_FDD}    value=70
    Set attenuation and check    lines=${lines_gNB_410_AEHC_5_TDD}    value=70
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AHFIB_7_FDD}    value=90
    Set attenuation and check    lines=${lines_gNB_410_AEHC_5_TDD}    value=90
    Sleep  3s
    Log to Console  >2 SCells have been released from CA. Currently: 2CC CA F+T.<

Verify Harq feedbacks are transmitted on Pucch or Pusch
    [Arguments]  ${dir}=${OUTPUT DIR}/PCAPs/tcpdump_L2L1_filtering_on-${test_name}.pcap
    ${msgs_HARQ}    check_HARQ  ${dir}
    should be true    ${msgs_HARQ}

Verify PM Counters 8533-A
    log to console      Verify PM counters values
    Sleep                       200s
    ${counters}                 Read Counters Value 8533-A
    ${A2MEAS_REL1DLSCELL_ATT_SA}    Get Counter Value From Single Cell      ${counters}     102    M55118C06501
    ${A2MEAS_REL1DLSCELL_SUCC_SA}   Get Counter Value From Single Cell      ${counters}     102    M55118C06502
    Should Be True      1<=${A2MEAS_REL1DLSCELL_ATT_SA}
    Should Be True      1<=${A2MEAS_REL1DLSCELL_SUCC_SA}

Verify PM Counters 8533-C
    [Arguments]  ${cell}=1
    Log to Console    Waiting for BTS counters to appear
    Sleep  300s
    log to console      Verify PM counters values
    ${counters}                 Read Counters Value 8533-C
    ${PUCCH_FORMAT3_NON_DTX}    Get Counter Value From Single Cell          ${counters}     ${cell}    M55303C18001
    ${GNB_SCELL_3_ADMI_REQ_SA}    Get Counter Value From Single Cell        ${counters}     ${cell}    M55138C03001
    ${GNB_SCELL_3_ADMI_SUCC_SA}   Get Counter Value From Single Cell        ${counters}     ${cell}    M55138C03002
    ${GNB_DU_SCELL_3_ADMI_REQ_SA}   Get Counter Value From Single Cell      ${counters}     ${cell}    M55139C03001
    ${GNB_DU_SCELL_3_ADMI_SUCC_SA}   Get Counter Value From Single Cell     ${counters}     ${cell}    M55139C03002
    ${RRC_RECONF_ADD3DLSCELL_ATT_SA}   Get Counter Value From Single Cell   ${counters}     ${cell}    M55118C09503
    ${RRC_RECONF_ADD3DLSCELL_SUCC_SA}   Get Counter Value From Single Cell  ${counters}     ${cell}    M55118C09502
    Should Be True      1<=${PUCCH_FORMAT3_NON_DTX}
    Should Be True      1<=${GNB_SCELL_3_ADMI_REQ_SA}
    Should Be True      1<=${GNB_SCELL_3_ADMI_SUCC_SA}
    Should Be True      1<=${GNB_DU_SCELL_3_ADMI_REQ_SA}
    Should Be True      1<=${GNB_DU_SCELL_3_ADMI_SUCC_SA}
    Should Be True      1<=${RRC_RECONF_ADD3DLSCELL_ATT_SA}
    Should Be True      1<=${RRC_RECONF_ADD3DLSCELL_SUCC_SA}

Read counters value 8533-A
    ${counters_values}=   Create List
    Collect Counters   n_last=15
    @{counters}   Create list    M55118C06501    M55118C06502
    FOR    ${counter}    IN      @{counters}
       ${value}    Get sum of n last counter values   4  ${counter}
       Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}

Read counters value 8533-C
    ${counters_values}=   Create List
    Collect Counters   n_last=15
    @{counters}   Create list  M55138C03001   M55138C03002   M55139C03001   M55139C03002   M55118C09503   M55118C09502
    ...                        M55303C18001
    FOR    ${counter}    IN      @{counters}
       ${value}    Get sum of n last counter values   4  ${counter}
       Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}

Setup attenuators for T186
    @{att_conf}  get_attenuators
    FOR    ${at}    IN    @{att_conf}
        ${success_num}    Evaluate    ${success_num} + 1
        Reset attenuator   ip_addr=10.42.61.34
        att.Setup attenuator    ip_addr=10.42.61.34    port=3001
        ...    attenuation_port_numbers=${at[2]}     max_attenuation=${max_attenuation_value}    vendor=${atten_vendor}
        ...    model=${atten_model}   alias=att_4
    END
#    Run Keyword If 	${is_second_attenuator} == True
#    ...    Reset attenuator   ip_addr=10.42.61.34
#    Run Keyword If 	${is_second_attenuator} == True
#    ...    att.Setup attenuator    ip_addr=10.42.61.34    port=3001
#    ...    attenuation_port_numbers=${atten_ports_2}    max_attenuation=${max_attenuation_value}    vendor=${atten_vendor_2}
#    ...    model=${atten_model_2}  alias=att_4

Set attenuation for 8533-AB11-1x-interGNB and check
    [Arguments]      ${lines}    ${value}
    FOR    ${line}    IN    @{lines}
        att.Set attenuation     port=${${line}}     value=${${value}}   attenuator_device=att_3
        ${value_port}    att.Read attenuation    port=${${line}}   attenuator_device=att_3
        Should be equal    ${value_port}    ${${value}}
    END

Set attenuation for 8533-AB11-1x-interGNB and check_2
    [Arguments]      ${lines}    ${value}
    FOR    ${line}    IN    @{lines}
        att.Set attenuation     port=${${line}}     value=${${value}}   attenuator_device=att_4
        ${value_port}    att.Read attenuation    port=${${line}}   attenuator_device=att_4
        Should be equal    ${value_port}    ${${value}}
    END

Set initial attenuation for interGNB handover 186
    Set attenuation for 8533-AB11-1x-interGNB and check_2    lines=${lines_gNB_186_AHLOA_1}    value=0
    Set attenuation for 8533-AB11-1x-interGNB and check_2    lines=${lines_gNB_186_AEHC_1}     value=0
    Log to Console    >Attenuation set to 0dB for RMODs: AHLOA AEHC<

Perform handover from 2CC T186 to 3CC T410
    Set attenuation and check    lines=${lines_gNB_410_AEHC_4_TDD}     value=0
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AHFIB_8_FDD}     value=0
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AHLOA_1_FDD}    value=0
    Sleep  3s
    Set attenuation for 8533-AB11-1x-interGNB and check_2   lines=${lines_gNB_186_AHLOA_1}    value=5
    Sleep  3s
    Set attenuation for 8533-AB11-1x-interGNB and check_2    lines=${lines_gNB_186_AHLOA_1}    value=10
    Sleep  3s
    Set attenuation for 8533-AB11-1x-interGNB and check_2    lines=${lines_gNB_186_AHLOA_1}    value=15
    Sleep  3s
    Set attenuation for 8533-AB11-1x-interGNB and check_2    lines=${lines_gNB_186_AHLOA_1}    value=20
    Sleep  3s
    Set attenuation for 8533-AB11-1x-interGNB and check_2    lines=${lines_gNB_186_AHLOA_1}    value=25
	Sleep  5s
    Set attenuation for 8533-AB11-1x-interGNB and check_2    lines=${lines_gNB_186_AHLOA_1}    value=35
    Sleep  3s
    Set attenuation for 8533-AB11-1x-interGNB and check_2    lines=${lines_gNB_186_AHLOA_1}    value=45
    Sleep  5s
    Log to Console  >Handover from 2CC F+T on T186 to 3CC F+2T on T410 has been completed.<

Perform handover from 4CC T410 to 2CC T186
    Set attenuation for 8533-AB11-1x-interGNB and check_2    lines=${lines_gNB_186_AEHC_1}    value=0
    Sleep  3s
    Set attenuation for 8533-AB11-1x-interGNB and check_2    lines=${lines_gNB_186_AHLOA_1}   value=0
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AHFIB_8_FDD}    value=55
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AHFIB_7_FDD}    value=55
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AHLOA_1_FDD}    value=20
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AHLOA_1_FDD}    value=25
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AHLOA_1_FDD}    value=30
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AHLOA_1_FDD}    value=35
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AHLOA_1_FDD}    value=55
    Sleep  3s
    #:FOR    ${index}   IN RANGE    1   11
    #\   ${attenuate}=   Evaluate    ${index} * 8
    #\   Set attenuation and check    lines=${lines_gNB_410_AHLOA_2_FDD}   value=${attenuate}
	#\   Set attenuation and check    lines=${lines_gNB_410_AEHC_4_TDD}    value=${attenuate}
	#\   Set attenuation and check    lines=${lines_gNB_410_AEHC_5_TDD}    value=${attenuate}
	#\   Set attenuation and check    lines=${lines_gNB_410_AHFIB_7_FDD}   value=${attenuate}
	#\   Sleep  1s
	#Sleep  3s
    Log to Console  >Handover from 4CC 2F+2T on T410 to 2CC F+T on T186 has been completed. Cell 60<

Perform handover from 2CC T186 to 4CC T410
    Set attenuation and check    lines=${lines_gNB_410_AHLOA_1_FDD}    value=0
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AEHC_4_TDD}     value=0
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AHFIB_8_FDD}    value=0
    Set attenuation for 8533-AB11-1x-interGNB and check_2    lines=${lines_gNB_186_AHLOA_1}    value=5
    Sleep  3s
    Set attenuation for 8533-AB11-1x-interGNB and check_2    lines=${lines_gNB_186_AHLOA_1}    value=10
    Sleep  3s
    Set attenuation for 8533-AB11-1x-interGNB and check_2   lines=${lines_gNB_186_AHLOA_1}    value=15
    Sleep  3s
    Set attenuation for 8533-AB11-1x-interGNB and check_2    lines=${lines_gNB_186_AHLOA_1}    value=20
    Sleep  3s
    Set attenuation for 8533-AB11-1x-interGNB and check_2    lines=${lines_gNB_186_AHLOA_1}    value=25
    Sleep  3s
    Set attenuation for 8533-AB11-1x-interGNB and check_2    lines=${lines_gNB_186_AHLOA_1}    value=35
    Sleep  3s
    Set attenuation for 8533-AB11-1x-interGNB and check_2    lines=${lines_gNB_186_AHLOA_1}    value=55

Start L1L2 logs on neighbour gNB
    Start New L1L2 Logs  ip=10.44.137.49  dir=${OUTPUT DIR}/PCAPs/tcpdump_L2L1_filtering_on-${test_name}_186.pcap

Stop L1L2 Logs And Download PCAP from neighbour gNB
    Stop New L1L2 Logs And Download PCAP
    ...                 ip=10.44.137.49
    ...                 dir=${OUTPUT DIR}/PCAPs/tcpdump_L2L1_filtering_on-${test_name}_186.pcap

Read counters value 8533-A-HO 186
    ${counters_values}=   Create List
    Collect counters ext gnb   n_last=50
    @{counters}   Create list    M55118C05507    M55118C05508
    FOR    ${counter}    IN      @{counters}
       ${value}    Get sum of n last counter values   15  ${counter}
       Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}

Verify PM Counters 2CC
    log to console              Verify PM counters values
    ${counters}                 Read Counters Value 8533-A-HO 186
    ${ca_ues_pcell}             get_counter_value_from_single_cell   ${counters}  1    M55118C05507
    ${ca_ues_scell}             get_counter_value_from_single_cell   ${counters}  4    M55118C05508
    Should Be True      15<=${ca_ues_pcell}
    Should Be True      15<=${ca_ues_scell}

Verify registration to FDD PCell 8533
    # [Arguments]    ${file_path}=${OUTPUT DIR}/${SUITE NAME}/${test_name}.log
    unpack collected syslog
    ${condition}=     Run keyword and Return Status
    ...               check if exist in syslog    AddedServingCellsList     Store addedSCellList:AddedServingCellsList
    Run keyword if    ${condition} == False
    ...               check if exist in syslog    AddedServingCellItem     Store addedSCellList
    check if exist in syslog    ScellAddition
    ...                         ScellAddition procedure Completed with No ScellAddition Error

Verify CNI 81817
    # [Arguments]    ${file_path}=${OUTPUT DIR}/${SUITE NAME}/${test_name}.log
    unpack collected syslog
#    check if exist in syslog    BandCombinationIndex     selectedBandCombinationIndex
#    check if exist in syslog    selectedFeatureSetEntryIndex     selectedFeatureSetEntryIndex
    check if exist in syslog    CNI81817     CNI81817: calculating

Verify PM Counters 8533-AB5-1
    log to console      Verify PM counters values
    Sleep                       240s
    ${counters}                 Read Counters Value 8533-AB5-1
    ${GNB_SCELL_3_ADMI_REQ_SA}     Get Counter Value From Single Cell      ${counters}     1    M55138C03001
    ${GNB_SCELL_3_ADMI_SUCC_SA}    Get Counter Value From Single Cell      ${counters}     1    M55138C03002
    ${EN_DSS_DL_NR_SLOTS}          Get Counter Value From Single Cell      ${counters}     1    M55332C00001
    ${EN_DSS_UL_PRBS_NR}           Get Counter Value From Single Cell      ${counters}     1    M55332C01001
    Should Be True      1<=${GNB_SCELL_3_ADMI_REQ_SA}
    Should Be True      1<=${GNB_SCELL_3_ADMI_SUCC_SA}
    Should Be True      1<=${EN_DSS_DL_NR_SLOTS}
    Should Be True      1<=${EN_DSS_UL_PRBS_NR}

Read counters value 8533-AB5-1
    ${counters_values}=   Create List
    Collect Counters   n_last=15
    @{counters}   Create list    M55138C03001    M55138C03002    M55332C00001    M55332C01001
    FOR    ${counter}    IN      @{counters}
       ${value}    Get sum of n last counter values   4  ${counter}
       Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}
