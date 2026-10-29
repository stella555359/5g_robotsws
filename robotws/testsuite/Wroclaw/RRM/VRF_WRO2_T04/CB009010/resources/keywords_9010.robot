*** Settings ***
Documentation
...   author: Pawel Zabawczuk
...   contact: pawel.k.zabawczuk@nokia.com
...   Keywords for ANRs

Library     ute_ue
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T04/5GC001167/resources/delta_keywords.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/kpi.py   WITH NAME   wro4_scf
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/counters.py    WITH NAME    wro4_pm
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/delta_utils.py    WITH NAME    delta
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB009010/resources/specific_keywords_9010.py    WITH NAME    interanr
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB009009/resources/keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB011041/resources/counters.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB009103/CB009103_Inter_gNB_DL_CA.robot

*** Variables ***
&{rsrp_level}                       50=-77


*** Keywords ***
Make inter gNB Handover
    [Arguments]   ${from_cell}  ${ho_cell}  ${att_offset}=3
    Show Text on Console    Make inter gNB Handover
    Set test Variable   ${log_index}   _cell_not_reserved
    logs.Start Tracing On SMOD   smod slave=False

    ${a3OffsetSsbRsrp}   wro4_scf.get_parameter_value_from_scf
    ...                      parameter_abbreviation=a3OffsetSsbRsrp
    ...                      path=${scf_file}
    ...                      parameter_dist_name=${bts_prefix}/NRCELL-${from_cell}/NRHOIF-2
    ${attenuation_serving_cell}   Evaluate   (${rsrp_level}[${from_cell}] - ${rsrp_level}[${ho_cell}]) + ${a3OffsetSsbRsrp} + ${att_offset}
    Log To Console   \n Clear attenuation for HO cell and attenuate serving cell about ${attenuation_serving_cell}dB
    Set Attenuation  0dB  ${ATTENUATOR['AZHL']['ports']}  confirm=${TRUE}
    ...              attenuator_id=${ATTENUATOR['AZHL']['att_id']}
    Set Attenuation  ${attenuation_serving_cell}dB  ${ATTENUATOR['AEHC_1']['ports']}
    ...              confirm=${TRUE}  attenuator_id=${ATTENUATOR['AEHC_1']['att_id']}

    Wait Until Keyword Succeeds   120   15   Verify SA HO to Given Cell   ${ho_cell}

    ${log_path}   logs.Stop Tracing And Download Logs From SMOD
    verify_handover   status=success   pcap_file=${log_path}

    Wait Until Keyword Succeeds   120s   20s
    ...     find_existing_ANR_NRADJNRCELL   nradjnrcell_id=${nradjnrcell_instance_no}
    Wait Until Keyword Succeeds   60s   20s
    ...     Check if ANR ADJ_NRPLMNSET_SA for given NRADJNRCELL Exist   nradjnrcell_id=${nradjnrcell_instance_no}
    Wait Until Keyword Succeeds   60s   20s
    ...     Check if ANR NRREL Exist   from_cell=${serving_cell}  ho_cell=${ho_cell}  expected_instance_no=${nrrel_instance_no}
    Log To Console   \n ANR NRADJNRCELL-${nradjnrcell_instance_no} created successfully
    Log To Console   ${SPACE}ANR ADJ_NRPLMNSET_SA for given NRADJNRCELL-${nradjnrcell_instance_no} created successfully
    Log To Console   ${SPACE}ANR NRCELL-${serving_cell}\\NRREL-${nrrel_instance_no} to NRCELL: ${ho_cell} created successfully \n

    interanr.increase_counters
    ...    NRRCC_NRCGI_REPORT_CONF_SENT
    ...    NRRCC_NRCGI_REPORT_RECV
    ...    NMOCU_ANR_NRREL_ADD
    ...    TOT_INTER_FREQ_HO_DECISION_A3
    ...    XN_HO_REQ_SENT
    ...    XN_HO_REQ_ACK_RECEIVED
    ...    IEF_XN_HO_PR_ATT_SRC
    ...    cell=${from_cell}

    interanr.increase_counters
    ...    SGNB_SA_CU_HO_ADMISSION_REQ
    ...    SGNB_SA_CU_HO_ADMISSION_SUCC
    ...    XN_HO_REQ__RECEIVED
    ...    XN_HO_REQ_ACK_SENT
    ...    cell=${ho_cell}

    [Teardown]   Run Keywords
    ...         Detach Ue   ${UE}
    ...   AND   Set Attenuation  90dB  ${ATTENUATOR['AZHL']['ports']}  confirm=${TRUE}
    ...             attenuator_id=${ATTENUATOR['AZHL']['att_id']}
    ...   AND   Set Attenuation  0dB  ${ATTENUATOR['AEHC_1']['ports']}   confirm=${TRUE}
    ...             attenuator_id=${ATTENUATOR['AEHC_1']['att_id']}
    ...   AND   remove_relation_object   cell_id=${serving_cell}  instance_number=${nrrel_instance_no}
    ...   AND   remove_adj_nrplmnset_objects   instance_number=${nradjnrcell_instance_no}


Try inter gNB Handover
    [Arguments]   ${from_cell}  ${ho_cell}  ${att_offset}=3
    Show Text on Console    Try to do inter gNB Handover
    Set test Variable   ${log_index}   _cell_reserved
    logs.Start Tracing On SMOD   smod slave=False

    ${a3OffsetSsbRsrp}   wro4_scf.get_parameter_value_from_scf
    ...                      parameter_abbreviation=a3OffsetSsbRsrp
    ...                      path=${scf_file}
    ...                      parameter_dist_name=${bts_prefix}/NRCELL-${from_cell}/NRHOIF-2
    ${attenuation_serving_cell}   Evaluate   (${rsrp_level}[${from_cell}] - ${rsrp_level}[${ho_cell}]) + ${a3OffsetSsbRsrp} + ${att_offset}
    Log To Console   \n Clear attenuation for HO cell and attenuate serving cell about ${attenuation_serving_cell}dB
    Set Attenuation  0dB  ${ATTENUATOR['AZHL']['ports']}  confirm=${TRUE}
    ...              attenuator_id=${ATTENUATOR['AZHL']['att_id']}
    Set Attenuation  ${attenuation_serving_cell}dB  ${ATTENUATOR['AEHC_1']['ports']}
    ...              confirm=${TRUE}  attenuator_id=${ATTENUATOR['AEHC_1']['att_id']}

    BuiltIn.Sleep   15s   wait to prove ho failed
    Check UE still in serving cell   ${serving_cell}

    ${log_path}   logs.Stop Tracing And Download Logs From SMOD
    verify_handover   status=fail   pcap_file=${log_path}

    Wait Until Keyword Succeeds   120s   20s
    ...     find_existing_ANR_NRADJNRCELL   nradjnrcell_id=${nradjnrcell_instance_no}
    Wait Until Keyword Succeeds   60s   20s
    ...     Check if ANR ADJ_NRPLMNSET_SA for given NRADJNRCELL Exist   nradjnrcell_id=${nradjnrcell_instance_no}
    Log To Console   \n ANR NRADJNRCELL-${nradjnrcell_instance_no} created successfully
    Log To Console   ${SPACE}ANR ADJ_NRPLMNSET_SA for given NRADJNRCELL-${nradjnrcell_instance_no} created successfully

    Run Keyword And Expect Error    *   Wait Until Keyword Succeeds   60s   20s
    ...     Check if ANR NRREL Exist   from_cell=${serving_cell}  ho_cell=${ho_cell}  expected_instance_no=${nrrel_instance_no}
	Log To Console   ${SPACE}NRREL-${nrrel_instance_no} to NRCELL: ${ho_cell} not created due to FAILED Handover

    interanr.increase_counters
    ...    NRRCC_NRCGI_REPORT_CONF_SENT
    ...    NRRCC_NRCGI_REPORT_RECV
    ...    cell=${from_cell}

    interanr.increase_counters
    ...    TOT_INTER_FREQ_HO_DECISION_A3
    ...    XN_HO_REQ_SENT
    ...    XN_HO_PREP_FAIL_RECEIVED
    ...    IEF_XN_HO_PR_ATT_SRC
    ...    cell=${from_cell}
    ...    multiplier=5

    interanr.increase_counters
    ...    XN_HO_REQ__RECEIVED
    ...    cell=${ho_cell}
    ...    multiplier=5

    [Teardown]   Detach Ue   ${UE}


Check if ANR NRREL Exist
    [Arguments]   ${from_cell}  ${ho_cell}  ${expected_instance_no}
    ${current_instance_no}   find_nrrel_id   from_cell=${from_cell}  to_cell=${ho_cell}
    Should Be Equal As Numbers   ${expected_instance_no}   ${current_instance_no}


Check if ANR ADJ_NRPLMNSET_SA for given NRADJNRCELL Exist
    [Arguments]   ${nradjnrcell_id}
    ${plmns}   find_existing_ANR_ADJ_NRPLMNSET_SA   nradjnrcell_id=${nradjnrcell_id}
    List Should Contain Value   ${plmns}  ${1}
    List Should Contain Value   ${plmns}  ${2}



Check UE still in serving cell
    [Arguments]   ${cell}
    ${pci}   Verify 5G SA Attach   ${UE}
    Should Be Equal As Strings   ${cell}  ${pci}   ${UE} not attached to serving cell: ${cell}
    Log To Console   \n ${UE} still in serving cell \n


Set HO cell as ${value} on remote gNB
    delta.update_parameter
    ...    parameter=cellReservedForOperatorUse
    ...    value=${value}
    ...    distname=MRBTS-${tl.gnbs[2].instance_id}/NRBTS-${tl.gnbs[2].global_bts_id}/NRCELL-${ho_cell}/NRPLMNSET_SA-1
    ...    remote_host=${remote_vm_ip}
