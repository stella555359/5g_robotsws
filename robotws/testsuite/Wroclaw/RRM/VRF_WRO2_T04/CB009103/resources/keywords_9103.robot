*** Settings ***
Documentation
...   author: Pawel Zabawczuk
...   contact: pawel.k.zabawczuk@nokia.com


Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/tput_keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB009103/resources/keywords_9103.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB008225/resources/keywords_8225.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB011041/resources/counters.robot
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB011041/resources/specific_keywords_11041.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB009103/resources/specific_keywords_9103.py    WITH NAME    interdlca
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB009103/resources/interdlca_pm_counters.py


*** Keywords ***
Check current scells added
    [Arguments]   ${num_of_scells}  ${scells}
    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD   stop_tracing=NO
    scells_added   pcap_file=${logs_path}  num_of_scells=${num_of_scells}  scells_id=${scells}


Wait Downlink CA Traffic Finish
    Await Data Transfer Finish    DT_DL_${ue}

    ${avg_tput}   Get Average Throughput   dt_name=DT_DL_${ue}
    ${avg_tput}   Evaluate   ${avg_tput} / 1000
    ${avg_tput}   Evaluate   "%.1f" % ${avg_tput}
    [Return]   ${avg_tput}


Verify Traffic from PM Counters vs NAA value
    [Arguments]   ${counter_values}  ${naa_avg_tput}
    Log   Calculate average tput in Mbits/sec for PCell and SCells from counters (volume in bytes) and compare with value from UE (NAA)
    ${pcell_vol}   Evaluate   ${counter_values}[M55310C20001][NRCELL-${pcell}] * 8 / 1000000
    ${pcell_avg_tput}   Evaluate   ${pcell_vol} / ${tput_duration}
    ${pcell_avg_tput}   Evaluate   "%.1f" % ${pcell_avg_tput}

    ${scells}   Create List   ${scell}  ${scell_2}  ${ext_scell_1}  ${ext_scell_2}
    FOR  ${sc}  IN  @{scells}
        ${scell_vol}   Evaluate   ${counter_values}[M55310C20000][NRCELL-${sc}] * 8 / 1000000
        ${scell_avg_tput}   Evaluate   ${scell_vol} / ${tput_duration}
        ${scell_avg_tput}   Evaluate   "%.1f" % ${scell_avg_tput}
        Set Test Variable   ${scell_${sc}_avg_tput}  ${scell_avg_tput}
    END

    ${pm_avg_tput_1}   Evaluate   ${pcell_avg_tput} + ${scell_${scell}_avg_tput} + ${scell_${scell_2}_avg_tput}
    ${pm_avg_tput_2}   Evaluate   ${scell_${ext_scell_1}_avg_tput} + ${scell_${ext_scell_2}_avg_tput}
    ${pm_avg_tput}   Evaluate   ${pm_avg_tput_1} + ${pm_avg_tput_2}
    ${pm_avg_tput}   Evaluate   "%.1f" % ${pm_avg_tput}

    ${tput_diff}   Evaluate   abs((${pm_avg_tput} - ${naa_avg_tput}) / ${pm_avg_tput} * 100)
    ${tput_diff}   Evaluate   "%.1f" % ${tput_diff}

    Log To Console   \nDL AVG TPUT measurements: \n NAA iperf: ${naa_avg_tput} Mbits/sec \n PM Volume Counters: ${pm_avg_tput} Mbits/sec
    Log To Console   ${SPACE*3} PCell: ${pcell_avg_tput} Mbits/sec
    Log To Console   ${SPACE*3} SCell: ${scell_${scell}_avg_tput} Mbits/sec
    Log To Console   ${SPACE*3} SCell 2: ${scell_${scell_2}_avg_tput} Mbits/sec
    Log To Console   ${SPACE*3} ext-SCell 1: ${scell_${ext_scell_1}_avg_tput} Mbits/sec
    Log To Console   ${SPACE*3} ext-SCell 2: ${scell_${ext_scell_2}_avg_tput} Mbits/sec
    Log To Console   ${SPACE}DL Tput Difference: ${tput_diff}% \n

    Run Keyword If   ${tput_diff} < ${tput_deviation}   Run Keywords
    ...    interdlca.increase_counters
    ...      NR_RLC_PDU_DL_VOL_CA_PCELL
    ...      multiplier=${counter_values}[M55310C20001][NRCELL-${pcell}]
    ...      cell=${pcell}     AND
    ...    interdlca.increase_counters
    ...      NR_RLC_PDU_DL_VOL_CA_SCELL
    ...      multiplier=${counter_values}[M55310C20000][NRCELL-${scell}]
    ...      cell=${scell}     AND
    ...    interdlca.increase_counters
    ...      NR_RLC_PDU_DL_VOL_CA_SCELL
    ...      multiplier=${counter_values}[M55310C20000][NRCELL-${scell_2}]
    ...      cell=${scell_2}     AND
    ...    interdlca.increase_counters
    ...      NR_RLC_PDU_DL_VOL_CA_SCELL
    ...      multiplier=${counter_values}[M55310C20000][NRCELL-${ext_scell_1}]
    ...      cell=${ext_scell_1}     AND
    ...    interdlca.increase_counters
    ...      NR_RLC_PDU_DL_VOL_CA_SCELL
    ...      multiplier=${counter_values}[M55310C20000][NRCELL-${ext_scell_2}]
    ...      cell=${ext_scell_2}


Collect Counters from Both BTSs
    [Arguments]   ${start_time}  ${stop_time}  ${pm_dict_name}  ${additional_dict_keys}=${None}
    Show Text on Console   [Counters collecting in progress... can take a while]
    ${pm_intervals_number}   wro4_pm.calculate_pm_intervals_number   ${start_time}   ${stop_time}

    Log   Get counters IDs from dictionary variable
    ${counters}   Get Dictionary Keys   ${${pm_dict_name}}
    ${counter_ids}   Create List
    FOR   ${ne_abbr}  IN   @{counters}
        Append To List  ${counter_ids}   ${${pm_dict_name}}[${ne_abbr}][PI_ID]
    END

    ${counter_values_local}   wro4_pm.get_sum_of_n_last_pm_counters_values
    ...                          ${counter_ids}
    ...                          n=${pm_intervals_number}
    ...                          additional_dict_keys=${additional_dict_keys}
    ${counter_values_remote}   wro4_pm.get_sum_of_n_last_pm_counters_values
    ...                          ${counter_ids}
    ...                          n=${pm_intervals_number}
    ...                          additional_dict_keys=${additional_dict_keys}
    ...                          remote_host=${remote_vm_ip}
    ${counter_values}   merge_two_dictionaries   ${counter_values_local}   ${counter_values_remote}
    [Return]   ${counter_values}


Get BTSs settings
    ${scf_local}   wro4_scf.download_scf   file_name=scf_local.xml
    ${pcell_a1SCellAddRsrpFDD}   wro4_scf.get_threshold   ${bts_prefix}/NRCELL-${pcell}  a1ThresholdSCellAddSsbRsrpFDD  ${scf_local}
    Set Test Variable   ${pcell_a1SCellAddRsrpFDD}
    ${pcell_a1SCellAddRsrpTDD}   wro4_scf.get_threshold   ${bts_prefix}/NRCELL-${pcell}  a1ThresholdSCellAddSsbRsrpTDD  ${scf_local}
    ${pcell_a1SCellAddRsrp}   Set Variable If   '${pcell_a1SCellAddRsrpFDD}' >= '${pcell_a1SCellAddRsrpTDD}'
    ...                            ${pcell_a1SCellAddRsrpFDD}
    ...                            ${pcell_a1SCellAddRsrpTDD}
    Set Test Variable   ${pcell_a1SCellAddRsrp}
    ${pcell_a4SCellAddRsrp}   wro4_scf.get_threshold   ${bts_prefix}/NRCELL-${pcell}/NRHOIF-5  a4ThresholdSCellAddSsbRsrp  ${scf_local}
    Set Test Variable   ${pcell_a4SCellAddRsrp}
    ${scf_remote}   wro4_scf.download_scf   file_name=scf_remote.xml   remote_host=${remote_vm_ip}
    Set Test Variable   ${bts_prefix_remote}   MRBTS-${tl.gnbs[2].instance_id}/NRBTS-${tl.gnbs[2].global_bts_id}
    ${ext_scell_1_a2SCellRelRsrp}   wro4_scf.get_threshold   ${bts_prefix_remote}/NRCELL-${ext_scell_1}  a2ThresholdSCellRelSsbRsrp  ${scf_remote}
    Set Test Variable   ${ext_scell_1_a2SCellRelRsrp}
    ${ext_scell_2_a2SCellRelRsrp}   wro4_scf.get_threshold   ${bts_prefix_remote}/NRCELL-${ext_scell_2}  a2ThresholdSCellRelSsbRsrp  ${scf_remote}
    Set Test Variable   ${ext_scell_2_a2SCellRelRsrp}


Attenuate Given Cell
    [Arguments]   ${cell_id}  ${cell_rsrp}  ${threshold}  ${att_offset}=8
    ${attenuation}   Evaluate   ${cell_rsrp} - ${threshold} + ${att_offset}
    Set Attenuation  ${attenuation}dB  ${ATTENUATOR['${cell_vs_radio}[${cell_id}]']['ports']}  confirm=${TRUE}
    ...                   attenuator_id=${ATTENUATOR['${cell_vs_radio}[${cell_id}]']['att_id']}


Check Average Traffic from given time period
    [Arguments]   ${from_last}=${120}
    Log To Console   \n Check average tput from next ${from_last} seconds
    Check Data Transfer Is Alive   DT_DL_${ue}
    BuiltIn.Sleep   ${from_last}  run traffic few second before verification

    ${avg_tput}   Get Average Throughput   dt_name=DT_DL_${ue}  from_last=${from_last}
    ${avg_tput}   Evaluate   ${avg_tput} / 1000
    ${avg_tput}   Evaluate   "%.2f" % ${avg_tput}
    Log To Console   ${SPACE} DL TPUT: ${avg_tput} Mbits/sec
    [Return]   ${avg_tput}


Get A2 PCell Switch Threshold
    ${scf_local}   wro4_scf.download_scf   file_name=scf_local.xml
    ${a2PCellSwitchRsrp}   wro4_scf.get_threshold   ${bts_prefix}/NRCELL-${pcell}  a2ThresholdPCellSwitchSsbRsrp  ${scf_local}
    [Return]   ${a2PCellSwitchRsrp}


Verify Attach to Given Cell
    [Arguments]   ${target_cell}
    ${pci}   Verify 5G SA Attach   ${ue}
    Should Be Equal As Strings   ${target_cell}  ${pci}   ${ue} not attached to target cell: ${target_cell}


Verification Additional PM Counters
    [Arguments]   ${counter_values}  ${pm_dict_name}
    ${counters}   Get Dictionary Keys   ${${pm_dict_name}}
    FOR  ${ne_abbr}  IN  @{counters}
        ${pi_id}   Set Variable   ${${pm_dict_name}}[${ne_abbr}][PI_ID]
        ${key}     Set Variable   ${${pm_dict_name}}[${ne_abbr}][key]
        Run Keyword If   '${key}' == 'MCC'
        ...     Verification Counters per MCC
        ...         ${pm_dict_name}
        ...         ${ne_abbr}
        ...         ${pi_id}
        ...         ${country_codes}
        ...         ${counter_values}
    END


Verification Counters per MCC
    [Arguments]   ${pm_dict_name}  ${ne_abbr}  ${pi_id}  ${country_codes}  ${counter_values}

    FOR  ${mcc}  IN  @{country_codes}
        ${expected_value}   Set Variable   ${${pm_dict_name}}[${ne_abbr}][value][MCC-${mcc}]
        ${measured_value}   Set Variable   ${counter_values}[${pi_id}][MCC-${mcc}]
        ${msg_on_console}   Set Variable If   '${measured_value}' == '0'   False   True

        Run Keyword And Continue On Failure   Run Keywords   Should Be Equal As Integers   ${expected_value}  ${measured_value}
        ...   \n ${ne_abbr} (MCC-${mcc}) counter is not correct, \n expected: ${expected_value}, \n current: ${measured_value}  values=False
        ...   AND   Log   ${SPACE} ${ne_abbr} (MCC-${mcc}) counter value: ${measured_value}   console=${msg_on_console}
    END
