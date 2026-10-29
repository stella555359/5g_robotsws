*** Settings ***
Documentation
...   author: Karol Palac
Resource   testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/resource/phase_shifter/ps.robot
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB009262/resources/keywords.py

*** Keywords ***
Check NRCELL shutdown
    &{cell_info}=       coam.get cell specific info     cell_id=MRBTS-50714/NRBTS-50714/NRCELL-400    connection=cOAM
    Should be equal as strings   ${cell_info['status']['administrativeState']}    Locked
    ...    msg=NRCELL-400 has not its administrativeState set to Shutting Down    ignore_case=${True}

Read Counter Value 9262-F
    ${counters_values}=   Create List
    Collect Counters   n_last=4
    @{counters}   Create list    M55147C00024
    FOR    ${counter}    IN      @{counters}
        ${value}    Get sum of n last counter values   4  ${counter}
        Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}

Verify PM Counter 9262-F
    log to console    Verify PM counter value
    Sleep             200s
    ${counters}       Read Counter Value 9262-F
    ${TOT_INTER_FREQ_HO_DECISION_A3}         Get Counter Value From Single Cell      ${counters}    400    M55147C00024
    Should Be True      1<=${TOT_INTER_FREQ_HO_DECISION_A3}

Read counters value 9262-I
    ${counters_values}=   Create List
    Collect Counters   n_last=6
    @{counters}   Create list  M55316C09000  M55118C05507  M55118C05508  M55311C42009  M55311C44009
    FOR    ${counter}    IN      @{counters}
        ${value}    Get sum of n last counter values   4  ${counter}
        Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}

Verify PM Counters 9262-I
    log to console              Waiting for BTS Counters update 240s
    sleep   240s
    log to console              Verify PM counters values
    ${counters}                 Read counters value 9262-I
    ${pcell}                    get_counter_value_from_single_cell   ${counters}  410    M55316C09000
    ${ca_ues_scell}             get_counter_value_from_single_cell   ${counters}  400    M55118C05507
    ${ca_ues_pcell}             get_counter_value_from_single_cell   ${counters}  410    M55118C05508
    ${RLC_PDU_vol_over_pcell}   get_counter_value_from_single_cell   ${counters}  1      M55311C42009
    ${RLC_PDU_vol_over_scell}   get_counter_value_from_single_cell   ${counters}  1      M55311C44009
    Should Be True      0<${pcell}
    Should Be True      30<=${ca_ues_scell}
    Should Be True      0<${RLC_PDU_vol_over_pcell}
    Should Be True      0<${RLC_PDU_vol_over_scell}

Trigger Transform Precoder
    @{lines_gNB_T215_AVHA}   Create List    9   10   11   12
    Set attenuation and check    lines=${lines_gNB_T215_AVHA}  value=18
    Sleep    3s
    Set attenuation and check    lines=${lines_gNB_T215_AVHA}  value=20
    Sleep    3s
    Set attenuation and check    lines=${lines_gNB_T215_AVHA}  value=21
    Sleep    3s
    Set attenuation and check    lines=${lines_gNB_T215_AVHA}  value=23
    Sleep    3s
    Set attenuation and check    lines=${lines_gNB_T215_AVHA}  value=26
    Sleep    3s
    Set attenuation and check    lines=${lines_gNB_T215_AVHA}  value=30
    Sleep    3s
    Set attenuation and check    lines=${lines_gNB_T215_AVHA}  value=36
    Sleep    3s
    Set attenuation and check    lines=${lines_gNB_T215_AVHA}  value=48
    Sleep    3s
    Set attenuation and check    lines=${lines_gNB_T215_AVHA}  value=52

Check Transform Precoder on from PCAP
    [Arguments]  ${dir}=${OUTPUT DIR}/PCAPs/tcpdump_L2L1_filtering_on-${test_name}.pcap
    ${msgs}   check_transform_precoder_on   ${dir}
    should be true    ${msgs}

Setup phase shifter
    ps.Setup phase shifter  server_ip=10.44.234.46  model=MCS2350A2-128B16-A5  frequency=3550_0.5_ALL

Update phase shifter config
    [Arguments]  ${config_file}
    ps.Create output channels lists  file=${config_file}
    ps.Update attenuations    length=128
    ps.Update phases    length=128

Teardown phase shifter
    ps.Teardown MCS
