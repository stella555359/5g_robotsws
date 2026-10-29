*** Settings ***
Documentation
...   author: Pawel Zabawczuk
...   contact: pawel.k.zabawczuk@nokia.com
...   Keywords for ANRs

Library     ute_ue
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T04/5GC001167/resources/delta_keywords.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/kpi.py   WITH NAME   wro4_scf
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/counters.py    WITH NAME    wro4_pm
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB009009/resources/specific_keywords_9009.py    WITH NAME    anr
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ue_keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB011041/resources/counters.robot

*** Variables ***
@{cells_used_during_handover}       500  510
${is_rsrp_need_to_check}            ${True}
${a3OffsetSsbRsrp}                  6  # value from NRCELL for intra_freq or related NRHOIF for inter_freq HO
&{rsrp_level}


*** Keywords ***
Attach UE to check RSRP Level for HO cells
    Show Text on Console    Check RSRP level for handover cells
    Set Attenuation  90dB  ${ATTENUATOR['AEHC_1']['ports']}  confirm=${TRUE}
    Set Attenuation  0dB  ${ATTENUATOR['AEHC_2']['ports']}  confirm=${TRUE}
    FOR  ${cell}  IN  @{cells_used_during_handover}
        Check RSRP Level for Given Cell   ${cell}
    END
    Set Suite Variable   ${is_rsrp_need_to_check}  ${False}
    Log To Console   RSRP levels for cells used in tests with ANR: ${rsrp_level}
    [Teardown]   Run Keywords
    ...           Set Attenuation  0dB  ${ATTENUATOR['AEHC_1']['ports']}  confirm=${TRUE}
    ...   AND     Set Attenuation  90dB  ${ATTENUATOR['AEHC_2']['ports']}  confirm=${TRUE}


Check RSRP Level for Given Cell
    [Arguments]   ${cell}
    set_preferred_cell   cell_id=${cell}
    Attach Ue   ${UE}
    BuiltIn.Sleep   3s   wait for rsrp level stabilized
    ${CELL_INFO}   Get UE Info   ${UE}  CELL_INFO
    Should Be Equal As Strings   ${cell}  ${CELL_INFO}[pci]
    Set To Dictionary   ${rsrp_level}   ${cell}=${CELL_INFO}[dbm]
    Set Suite Variable   ${rsrp_level}
    [Teardown]   Detach Ue   ue_alias=${UE}


Attach UE to Given Cell
    [Arguments]   ${cell}
    Show Text on Console    Attach UE to serving cell
    Attach Ue    ${UE}
    ${pci}   Verify 5G SA Attach   ${UE}
    Should Be Equal As Strings   ${cell}  ${pci}   ${UE} not attached to serving cell: ${cell}
    ${CELL_INFO}   Get UE Info   ${UE}  CELL_INFO
    Set To Dictionary   ${rsrp_level}   ${cell}=${CELL_INFO}[dbm]
    Set Suite Variable   ${rsrp_level}


Make NSA Attach to Given NR Cell
    [Arguments]   ${cell}
    Show Text on Console    Attach UE to serving cell
    logs.Start Tracing On SMOD   smod slave=False
    Attach Ue   ${UE}
    ${log_path}   logs.Stop Tracing And Download Logs From SMOD   offset=5s
    ${cells_info}   Verify 5G NSA Attach   ue_alias=${UE}  pcap_file=${log_path}
    Should Be Equal As Strings   ${cell}  ${cells_info}[1]   ${UE} not attached to serving cell: ${cell}
    ${CELL_INFO}   Get UE Info   ${UE}  CELL_INFO
    Set To Dictionary   ${rsrp_level}   ${cell}=${CELL_INFO}[nrDbm]
    Set Suite Variable   ${rsrp_level}


Make SA Handover
    [Arguments]   ${from_cell}  ${ho_cell}  ${ho_type}   ${nrrel_instance_no}  ${att_offset}=5
    Show Text on Console    Make SA Handover and verify ANR
    ${cell_to_block}   Block Cell to Force HO to Required Cell   ho_cell=${ho_cell}
    ${log_index}   Set Variable   _${ho_type}
    logs.Start Tracing On SMOD   smod slave=False
    Attenuate Serving Cell below HO Cell with A3 offset   ${from_cell}  ${ho_cell}  ${att_offset}
    Wait Until Keyword Succeeds   120   15   Verify SA HO to Given Cell   ${ho_cell}
    Log To Console   \n HO done successfully

    anr.increase_counters
    ...    SGNB_SA_CU_HO_ADMISSION_REQ
    ...    SGNB_SA_CU_HO_ADMISSION_SUCC
    ...    cell=${ho_cell}

    Wait Until Keyword Succeeds   120   20
    ...     Check if ANR NRREL Instance Created   from_cell=${from_cell}  ho_cell=${ho_cell}  expected_instance_no=${nrrel_instance_no}
    Log To Console   \n ANR NRCELL-${from_cell}\\NRREL-${nrrel_instance_no} to NRCELL: ${ho_cell} created successfully

    anr.increase_counters
    ...    NRRCC_NRCGI_REPORT_CONF_SENT
    ...    NRRCC_NRCGI_REPORT_RECV
    ...    NMOCU_ANR_NRREL_ADD
    ...    cell=${from_cell}

    Run Keyword If   '${ho_type}' == 'intra_freq'
    ...     anr.increase_counters
    ...        TOT_INTRA_FREQ_HO_DECISION_A3
    ...        cell=${from_cell}
    ...   ELSE
    ...     anr.increase_counters
    ...        TOT_INTER_FREQ_HO_DECISION_A3
    ...        cell=${from_cell}

    ${log_path}   logs.Stop Tracing And Download Logs From SMOD

    [Teardown]   Run Keywords
    ...           Detach Ue   ${UE}
    ...   AND     Run Keyword And Ignore Error   unblock_nr_cell   cell_id=${cell_to_block}


Make NSA Handover
    [Arguments]   ${from_cell}  ${ho_cell}  ${ho_type}   ${nrrel_instance_no}  ${att_offset}=12
    Show Text on Console    Make NSA Handover and verify ANR
    ${cell_to_block}   Block Cell to Force HO to Required Cell   ho_cell=${ho_cell}
    Set Test Variable   ${log_index}  _${ho_type}
    logs.Start Tracing On SMOD   smod slave=False
    Attenuate Serving Cell below HO Cell with A3 offset   ${from_cell}  ${ho_cell}  ${att_offset}
    #Wait Until Keyword Succeeds   120   15   Verify SA HO to Given Cell   ${ho_cell}

    anr.increase_counters
    ...    SGNB_NSA_HO_ADMISSION_REQ
    ...    SGNB_NSA_HO_ADMISSION_SUCC
    ...    cell=${ho_cell}

    Wait Until Keyword Succeeds   180   20
    ...     Check if ANR NRREL Instance Created   from_cell=${from_cell}  ho_cell=${ho_cell}  expected_instance_no=${nrrel_instance_no}
    Log To Console   \n ANR NRCELL-${from_cell}\\NRREL-${nrrel_instance_no} to NRCELL: ${ho_cell} created successfully

    anr.increase_counters
    ...    NRRCC_NRCGI_REPORT_CONF_SENT
    ...    NRRCC_NRCGI_REPORT_RECV
    ...    NMOCU_ANR_NRREL_ADD
    ...    cell=${from_cell}

    Run Keyword If   '${ho_type}' == 'inter_freq'
    ...     anr.increase_counters
    ...        IF_INTRA_DU_HO_ATT_NSA_MNB
    ...        cell=${from_cell}

    ${log_path}   logs.Stop Tracing And Download Logs From SMOD

    [Teardown]   Run Keywords
    ...           Detach Ue   ${UE}
    ...   AND     Run Keyword And Ignore Error   unblock_nr_cell   cell_id=${cell_to_block}


Make iRAT Handover
    [Arguments]   ${from_cell}  ${ho_cell}  ${nrrel_instance_no}
    Show Text on Console    Make inter RAT Handover and verify ANR
    logs.Start Tracing On SMOD   smod slave=False

    Set Attenuation  0dB  ${ATTENUATOR['AHFII_1']['ports']}  confirm=${TRUE}
    Set Attenuation  20dB  ${ATTENUATOR['AEHC_1']['ports']}  confirm=${TRUE}

    Wait Until Keyword Succeeds   120   15   Verify iRAT HO to Given Cell   ${ho_cell}
    Log To Console   \n HO done successfully

    Wait Until Keyword Succeeds   120   20
    ...     Check if ANR NRRELE Instance Created   from_cell=${from_cell}  ho_cell=${ho_cell}  expected_instance_no=${nrrel_instance_no}
    Log To Console   \n ANR NRCELL-${from_cell}\\NRRELE-${nrrel_instance_no} to LNCEL: ${ho_cell} created successfully

    anr.increase_counters
    ...    NRRCC_EUTRACGI_REPORT_CONF_SNT
    ...    NRRCC_EUTRACGI_REPORT_RECV
    ...    NMOCU_ANR_NRRELE_ADD
    ...    cell=${from_cell}

    ${log_path}   logs.Stop Tracing And Download Logs From SMOD


Block Cell to Force HO to Required Cell
    [Arguments]   ${ho_cell}
    @{cells_sec_2}   Set Variable   @{cells_used_during_handover}
    Remove Values From List   ${cells_sec_2}  ${ho_cell}
    ${cell_to_block}   Set Variable   ${cells_sec_2}[0]
    block_nr_cell   cell_id=${cell_to_block}
    [Return]   ${cell_to_block}


Attenuate Serving Cell below HO Cell with A3 offset
    [Arguments]   ${from_cell}  ${ho_cell}  ${att_offset}
    ${attenuation_serving_cell}   Evaluate   (${rsrp_level}[${from_cell}] - ${rsrp_level}[${ho_cell}]) + ${a3OffsetSsbRsrp} + ${att_offset}
    Log To Console   \n Clear attenuation for HO cell and attenuate serving cell about ${attenuation_serving_cell} dB
    Set Attenuation  0dB  ${ATTENUATOR['AEHC_2']['ports']}  confirm=${TRUE}
    Set Attenuation  ${attenuation_serving_cell}dB  ${ATTENUATOR['AEHC_1']['ports']}  confirm=${TRUE}


Verify SA HO to Given Cell
    [Arguments]   ${ho_cell}
    ${pci}   Verify 5G SA Attach   ${UE}  offset=0s
    Should Be Equal As Strings   ${ho_cell}  ${pci}   ${UE} is not in ho cell: ${ho_cell}


Verify iRAT HO to Given Cell
    [Arguments]   ${ho_cell}
    ${cell}   Verify 4G Attach   ue=${UE}
    Should Be Equal As Strings   ${ho_cell}  ${cell}   iRAT HO to cell: ${ho_cell} not successful


Check if ANR NRREL Instance Created
    [Arguments]   ${from_cell}  ${ho_cell}  ${expected_instance_no}
    ${ho_lcrid}   wro4_scf.get_parameter_value_from_scf
    ...              path=${scf_file}
    ...              parameter_dist_name=${bts_prefix}/NRCELL-${ho_cell}
    ...              parameter_abbreviation=lcrId
    ${current_instance_no}   find_nrrel_id   from_cell=${from_cell}  to_cell=${ho_lcrid}
    Should Be Equal As Numbers   ${expected_instance_no}   ${current_instance_no}


Check if ANR NRRELE Instance Created
    [Arguments]   ${from_cell}  ${ho_cell}  ${expected_instance_no}
    ${ho_lcrid}   wro4_scf.get_parameter_value_from_scf
    ...              path=${scf_file}
    ...              parameter_dist_name=MRBTS-${mrbts_id}/LNBTS-${nrbts_id}/LNCEL-${ho_cell}
    ...              parameter_abbreviation=lcrId
    ${current_instance_no}   find_nrrele_id   from_cell=${from_cell}  to_cell=${ho_lcrid}
    Should Be Equal As Numbers   ${expected_instance_no}   ${current_instance_no}
