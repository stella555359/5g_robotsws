*** Settings ***
Documentation    This File Consist of the Keywords specific to this Feature CB011075.

Library        BuiltIn
Library        Collections
Library        String
Library        OperatingSystem
Library        taf.sbts.oam.coam.admin         WITH NAME    admin
Library        ute_fsmaccess
Library        ta5g_pm_counters
Library        taf.analyzer.pcap    WITH NAME    cap
Library        ${CURDIR}/../Keywords/table.py
Variables      ta5g_global_var
Library        ${CURDIR}/../../../resources/PythonLib/UTILS.py
Library        UTILS
Resource       ${CURDIR}/../../../resources/Keywords/ap_Keywords.robot
Resource       ${CURDIR}/../../../resources/Keywords/generic_kw.robot
Resource       ${CURDIR}/../../../resources/Keywords/gnb_Keywords.robot
Resource       ${CURDIR}/../../../resources/Keywords/tsharkPcapVerifyKeywords.robot
Resource       ${CURDIR}/../../../resources/Keywords/HO_KW.robot
Resource        ${CURDIR}/../../../resources/Keywords/ute_wts_runner.robot
Resource        ${CURDIR}/../../../resources/Variables/common_variables.robot
Resource        ${CURDIR}/../../../resources/Keywords/common_keywords.robot


*** Variables ***
${VLAN_ID}               ${tl.gnbs[0].cu.x2c.vlan_id}
${MRBTS_DISTNAME}        MRBTS-1
${VLANIF_DISTNAME}       ${MRBTS_DISTNAME}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1
${DELTACONFIGDIR}        ${CURDIR}/../../config/gnb_scf/
${APCONFIGDIR}           ${CURDIR}/../../config/ap_iphy/
${TOPOLOGY}              CLOUD_5G_I_LO_AP_LO
${EXPECTED_DELAY}        20
${UE_STATS_PDSCH_PATTERN}        NR PDSCH Throughput
${UE_STATS_PUSCH_PATTERN}        NR PUSCH Throughput
${GNBDU_CONFIG_FILTER_N77}       nr-rrc.physCellId == 51 and nr-rrc.p_Max >= 29 and f1ap.procedureCode == 7
${FIELD}                         f1ap.UEContextModificationResponse_element
${TP_PATTERN}           transformPrecoder enabled
${QFI2_PATTERN}         Added QosFlow with QFI:2 fiveQI:5
${QFI3_PATTERN}         Added QosFlow with QFI:3 fiveQI:1
${SAG_PATTERN}          numberOfRepetitions-r16
${AP_CONFIG_BASIC}         ${CURDIR}/../../config/wts


*** Keywords ***
Commision Scf And Iphy
    [Documentation]    This keyword is used to upload required iphy and commissioning GNB with required scf
    [Arguments]    ${scf}=${EMPTY}       ${iphy}=${EMPTY}
    Run Keyword If    '${iphy}' != '${EMPTY}'    Update And Put Iphy Xml
    ...      input_filepath=${iphy}
    Run Keyword If    '${scf}' != '${EMPTY}'     GNB Delta Commission
    ...    ${scf}

Prepare For Test Case - CB011075
    [Documentation]    Test Case preparation for setup before running testcase.
    ${LOG_PATH}      Create Log Directory        CB011075
    Link SCOUT SCF To Configuration ID For Reporting
    Set Test Variable        ${LOG_PATH}
    Create Basic Interface On UTE
    Log To Console      \n Sending  delta commission and iphy
    Commision Scf And Iphy      scf=${DELTACONFIGDIR}/Delta_config.json
    ...                         iphy=${APConfigDir}/50Mhz_FDD_n3_n7_IPHY.xml
    Log To Console      \n rebooting gnb
    Sleep   60s
    GNB Reboot
    Sleep   360s
    Wait Coam Site To Be Ready
    Start Pcap Collection In GNB CU
    Start UTE WTS        CB011075_G_CA_wts.cfg
    Basic Bring Up

Common Test Case Tear Down LO AP LO
    [Documentation]    Teardown for the Test Case for collecting logs and reverting site to original state.
    Delete Basic Interface On UTE
    Collect Logs For The Test           ${LOG_PATH}
    Commision Scf And Iphy      scf=${DELTACONFIGDIR}/Delta_reverse_config.json       iphy=${APConfigDir}/LO_AP_LO_iphy.xml
    Log To Console         \n Rebooting GNB wait for 360s
    GNB Reboot
    Sleep   300s

Stop Pcap Collection In GNB CU
    [Documentation]    This keyword is to stop PCAP logs from gnB
    ...     [arguments]    name     : This is file name where pcap logs will be collected, default name is gnbTcpdump
    ...                    LOG_PATH : Path where pcap log file will be stored, default path is LOG_PATH
    ...     [return]    PCAP_FILE   : pcap file path captured on wts
    ...     [usage]     Stop Pcap Collection In GNB
    ...                 Stop Pcap Collection In GNB     name=PCAPLOG    LOG_PATH= dir/dir/filename
    ...                 Stop Pcap Collection In GNB     gnbTcpdump1     dir/dir/filename
    [Arguments]                     ${name}=gnbTcpdump                  ${LOG_PATH}=${LOG_PATH}
    core.Stop Collectors            names=${name}
    core.Collect Collectors         names=${name}       target_dir=${LOG_PATH}
    core.Teardown Collectors        names=${name}
    ${PCAP_FILE}    Join Path       ${LOG_PATH}         ${name}         ${name}.pcap
    Log To Console                  pcap capture is stopped
    [Return]                        ${PCAP_FILE}

Verification Of Downlink Throughput
    [Documentation]    This is used for Downlink Throughput.
    [Arguments]             ${id}
    wtsrunner.UE Stats NR       scell=0-1    type=pdsch    id=${id}
    ${output}           Read WTS Output Until Pattern Matches          ${UE_STATS_PDSCH_PATTERN}       ${Timeout_SA}
    ${result}       table.GetPDSCH       ${output}
    Run Keyword If    ${result} == 1       Log     pass

Verification Of Uplink Throughput
    [Documentation]        This is to Verify uplink Throughput.
    [Arguments]             ${id}
    wtsrunner.UE Stats NR       scell=0-1    type=pusch    id=${id}
    ${output}           Read WTS Output Until Pattern Matches          ${UE_STATS_PUSCH_PATTERN}       ${Timeout_SA}
    ${result}      table.GetPDSCH    ${output}
    Run Keyword If    ${result} == 1       Log     pass

Start VONR Call
    [Documentation]    This is used to start PDU Session.
    [Arguments]         ${UE_ID}=${UE_ID}
    Log To Console      addition of qosflow=2 to UE71\n
    wtsrunner.Ue Pdu Session Modify     ue=${UE_ID}     pdu=1   qosflows_to_add=2  by=amf
    Sleep    30s
    Log To Console      addition of qosflow=3 to UE71\n
    wtsrunner.Ue Pdu Session Modify     ue=${UE_ID}     pdu=1   qosflows_to_add=3   by=amf
    Sleep    10s

Start Uplink Traffic For VONR
    [Documentation]    This is used to Start Trafiic for uplink for different Trf Ids
    [Arguments]         ${UE_ID}=${UE_ID}
    wtsrunner.Trf Data Start    ue=${UE_ID}    pdu=1   qfi=2   dir=ul  trf_id=2    mbps=10
    Sleep    30s
    wtsrunner.Trf Data Start    ue=${UE_ID}     pdu=1   qfi=3   dir=ul  trf_id=3    mbps=10
    Sleep    30s

Activate Testmode Profile And Validate TP And SAG
    [Documentation]    This is used to for TestMode Profile and Validating data.
    [Arguments]         ${UE_ID}=${UE_ID}
    wtsrunner.Ul Sinr Testmode NR   profile_id=2    sinr_target_pusch=-30
    Sleep   5s
    wtsrunner.UE Testmode Set NR    id=${UE_ID}     testmode=ul_sinr    profile_id=1    action=activate
    Sleep   60s
    wtsrunner.Ul Sinr Testmode NR   profile_id=1    pathloss=130
    Sleep    10s
    wtsrunner.UE Testmode Set NR    id=${UE_ID}     testmode=ul_sinr    profile_id=1    action=activate
    Log To Console   Verification of TransformPrecoder\n
    Read WTS Output Until Pattern Matches    ${TP_PATTERN}    ${Timeout_SA}
    Log To Console   Verification of slot aggregation\n
    Read WTS Output Until Pattern Matches    ${SAG_pattern}    ${Timeout_SA}

Start And Validate Traffic For CA
    [Documentation]        This keywords is used to start Traffic for the CA TestCase.
    [Arguments]    ${dl_rate}=150    ${ul_rate}=150    ${UE_ID}=${UE_ID}    ${id}=${id}
    Log To Console    \nRunning DL + UL Traffic for ${id}
    wtsrunner.Trf Data Start     ue=${UE_ID}    pdu=1   qfi=1    dir=dl    mbps=${dl_rate}
    ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=UDP DL TRF: .*    timeout=10
    ${output}   Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log To Console    \n${output}
    wtsrunner.Trf Data Start     ue=${UE_ID}   pdu=1   qfi=1    dir=ul    mbps=${ul_rate}
    ${output}    wtsrunner.Read Wtsemu Output Until Re    expected=UDP UL TRF: .*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log To Console    \n${output}

Verification Of NgSetupResponse Timer
    [Documentation]      this keyword helps to verify the time difference between ngsetupfailure and ngsetuprequest
    ...                  from the pcap file
    ...                  [Arguments]     PCAP_FILE       =   need to give complete path of the pcap file
    ...                                  ngap_ID_filter  =   need to pass the filter for the ngap.RANUE_NGAP_ID
    [Arguments]         ${PCAP_FILE}            ${ngap_filter}      ${field_name}
    ${ngap_req_time_delay}         Get Fields From Pcap    ${PCAP_FILE}        ${ngap_filter}           ${field_name}
    @{ngrequest_deltaTime}     Split String And Return List          ${ngap_req_time_delay}                 \n
    ${string}                  Convert To Number       ${ngrequest_deltaTime}[-1]
    ${delay}          Convert To Integer      ${string}
    ${expected_delay}          Convert To Integer      ${expected_delay}
    Should Be Equal   ${delay}      ${expected_delay}
    Log To Console     \nThe time difference between ngsetupfailure and ngsetup response is ${delay}

Check Pmax Is Correct For N77
    [Documentation]    Checking Pmax Value for the N77 band.
    [Arguments]     ${PCAP_FILE}
    ${PMAX_VALUE}      Get Fields From Pcap        ${PCAP_FILE}        ${GNBDU_CONFIG_FILTER_N77}         ${FIELD}
    Should Not Be Empty         ${PMAX_VALUE}

Check Pattern In Egate Console Log
    [Documentation]    This keyword checks if the pattern is present in the egate_console.log file for the SA variant
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    [Arguments]    ${pattern}    ${file}=${run_script_log_set}
    Run Keyword If    '${variant_name}' != '4G5G_COMBO_MultiUE'
    ...    wtsrunner.Script    file=${file}    entry=sim_log_set_flush()
    Wait Until Keyword Succeeds    ${Total_Timeout}    ${Retry_Timeout}    Search Pattern Should Exists In EGATE
    ...                            ${WTS_DIR}/egate_console.log     ${pattern}
