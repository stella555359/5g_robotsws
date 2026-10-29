*** Settings ***
Documentation    This file contains feature related keywords.
Library        ${CURDIR}/../Keywords/table.py
Resource       ${CURDIR}/../../../resources/Keywords/HO_KW.robot
Resource       ${CURDIR}/../../../resources/Keywords/generic_kw.robot
Resource       ${CURDIR}/../../../resources/Keywords/gnb_Keywords.robot
Resource       ${CURDIR}/../../../resources/Keywords/tsharkPcapVerifyKeywords.robot
Resource       ${CURDIR}/../../../resources/Keywords/ute_wts_runner.robot
Resource       ${CURDIR}/../../../resources/Keywords/ap_Keywords.robot
Resource       ${CURDIR}/../../../resources/Keywords/common_keywords.robot


*** Variables ***
${DeltaConfigDir}       ${CURDIR}/../../config/gnb_scf/
${APConfigDir}          ${CURDIR}/../../config/ap_iphy/
${AP_CONFIG_BASIC}     ${CURDIR}/../../config/wts
${TOPOLOGY}     CLOUD_5G_I_LO_AP_LO
${UE1}        51
${UE_stats_pdsch_pattern}        NR PDSCH Throughput
${UE_stats_pusch_pattern}       NR PUSCH Throughput
${VLAN_ID}        ${tl.gnbs[0].cu.x2c.vlan_id}
${MRBTS_DISTNAME}         MRBTS-1
${vlanif_distname}         ${MRBTS_DISTNAME}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1


*** Keywords ***
Commision scf and iphy
    [Documentation]    This keyword is used to upload required iphy and commissioning GNB with required scf
    [Arguments]    ${scf}=${EMPTY}       ${iphy}=${EMPTY}
    Run Keyword If    '${iphy}' != '${EMPTY}'    Update And Put Iphy Xml
    ...      input_filepath=${iphy}
    Run Keyword If    '${scf}' != '${EMPTY}'     GNB Delta Commission
    ...    ${scf}

Prepare for test Case - CB008251_TC7_TC8
    Create Basic Interface on UTE
    Link SCOUT SCF to Configuration ID for Reporting
    Update And Put Iphy XML         ${APConfigDir}/FTiphy.xml
    Log to Console      \n Sending full commission
    Full Commission With SCF File For UTE      ${DeltaConfigDir}/CAFT_SCF.xml
    Sleep   300s
    Wait Coam Site to be Ready
    Start UTE WTS      basic_setup_ca.cfg
    Basic Bring up

UE Register should be Successful for SA Updated
    [Arguments]    ${UE_ID51}    ${gw_ID}
    wtsrunner.ue_register   id=${UE_ID51}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    wtsrunner.set_pdu_param   ue=${UE_ID51}    pdu=${Pdu_session_ID}    trf_type=${Trf_type}
    wtsrunner.ue_pdu_session_setup    pdu=${Pdu_session_ID}    ue=${UE_ID51}   nwslice=${nwslice_ID}   gw=${gw_ID}
    Read WTS Output For Pattern And Print matching Lines    ${Initial_context_setup_pattern}    ${Timeout_SA}

Start and Validate Traffic For CA
    [Arguments]        ${UE_ID}    ${dl_rate}=170    ${ul_rate}=170
    Log to Console    \nRunning DL + UL Traffic
    wtsrunner.trf_data_start     ue=${UE_ID}    pdu=1   qfi=1    dir=dl    mbps=${dl_rate}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=UDP DL TRF: .*    timeout=10
    ${output}   Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    \n${output}
    wtsrunner.trf_data_start     ue=${UE_ID}   pdu=1   qfi=1    dir=ul    mbps=${ul_rate}
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=UDP UL TRF: .*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    \n${output}

Common test case tear down LO AP LO
    Delete Basic Interface on UTE
    Collect Logs For The Test           ${Log_Path}
    RAT Block Unblock

Verification of Downlink throughput
    [Arguments]             ${id}
    wtsrunner.ue_stats_nr       scell=0-1    type=pdsch    id=${id}
    ${output}           Read WTS Output Until Pattern Matches          ${UE_stats_pdsch_pattern}       ${Timeout_SA}
    ${result}       table.GetPDSCH       ${output}
    Run Keyword If    ${result} == 1       Log     pass

Verification of Uplink throughput
    [Arguments]             ${id}
    wtsrunner.ue_stats_nr       scell=0-1    type=pusch    id=${id}
    ${output}           Read WTS Output Until Pattern Matches          ${UE_stats_pusch_pattern}       ${Timeout_SA}
    ${result}      table.GetPDSCH    ${output}
    Run Keyword If    ${result} == 1       Log     pass

Test case tear down MP AP LO
    Delete Basic Interface on UTE
    Collect Logs For The Test           ${Log_Path}
    RAT Block Unblock

Prepare For Test Case 10915
    Link SCOUT SCF to Configuration ID for Reporting
    ${Log_Path}      Create Log Directory   CB010915
    Set Suite Variable      ${Log_Path}
    Create Basic Interface on UTE
    Commision Scf And Iphy      ${scf}      ${iphy}
	Sleep    120s
	GNB Delta Commission    ${scf1}
	GNB Reboot
    Sleep   320s
    Wait Coam Site to be Ready

Stop Pcap Collection In GNB With Path
    [Arguments]     ${name}   ${Log_Path}
    core.stop_collectors    names=${name}
    core.collect_collectors    names=${name}    target_dir=${Log_Path}
    core.teardown_collectors    names=${name}
    ${pcap_file_path}=   set variable    ${Log_Path}/${name}/${name}.pcap
    [Return]     ${pcap_file_path}

Make SA Call
    [Arguments]    ${UE_ID51}=${UE1}    ${gw_ID}=${gw_ID}
    Enable Internal TG   51  1
    UE Register should be Successful for SA Updated    ${UE_ID51}    ${gw_ID}
    Sleep   10s
    Start and Validate Traffic For CA       UE_ID=${UE1}

Verify Relaxed Measurement 17 From PCAP
    [Arguments]   ${pcap_file_path}
    ${q2}    Get Fields from Pcap     ${pcap_file_path}     ${filter}   ${S_sercch_TH_Q2}
    Log to console     \n ${q2}
    Should Be Equal    ${q2}    15,15
    ${p2}    Get Fields from Pcap     ${pcap_file_path}        ${filter}   ${S_search_TH_P2}
    Log to console     \n ${p2}
    Should Be Equal    ${p2}    15,15
    ${S_Delta_P}    Get Fields from Pcap     ${pcap_file_path}        ${filter}    ${S_search_deltaP}
    Log to console     \n${S_Delta_P}
    Should Be Equal    ${S_Delta_P}   3,3
    ${t_Delta_P}    Get Fields from Pcap     ${pcap_file_path}        ${filter}    ${t_search_DeltaP}
    Log to console     \n${t_Delta_P}
    Should Be Equal    ${t_Delta_P}   5,5
    ${r}    Get Fields from Pcap     ${pcap_file_path}        ${filter}    ${combine}
    Log to console     \n${r}
    Should Be Equal    ${r}   0,0

Check Pattern in Egate Console Log
    [Arguments]    ${pattern}    ${file}=${run_script_log_set}
    [Documentation]    This keyword checks if the ${pattern} is present in the egate_console.log file for the SA variant
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    Run Keyword If    '${variant_name}' != '4G5G_COMBO_MultiUE'
    ...    wtsrunner.script    file=${file}    entry=sim_log_set_flush()
    Wait Until Keyword Succeeds    ${Total_Timeout}    ${Retry_Timeout}    Search pattern should Exists In EGATE
    ...                            ${WTS_DIR}/egate_console.log     ${pattern}
