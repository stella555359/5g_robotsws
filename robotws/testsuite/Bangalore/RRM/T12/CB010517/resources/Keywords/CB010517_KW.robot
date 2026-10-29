*** Settings ***
Documentation        This File consists Keywords specific to Feature CB010517

Library         BuiltIn
Library         Collections
Library         OperatingSystem
Library         String
Library         taf.sbts.oam.coam.admin         WITH NAME    admin
Library         ute_fsmaccess
Library         ta5g_pm_counters
Library         taf.analyzer.pcap    WITH NAME    cap
Variables       ta5g_global_var
Library         ${CURDIR}/../../../resources/PythonLib/UTILS.py
Resource        ${CURDIR}/../../../resources/Keywords/ap_Keywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/generic_kw.robot
Resource        ${CURDIR}/../../../resources/Keywords/gnb_Keywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/PCMD_Related_KW.robot
Resource        ${CURDIR}/../../../resources/Keywords/tsharkPcapVerifyKeywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/HO_KW.robot
Resource        ${CURDIR}/../../../resources/Keywords/ute_wts_runner.robot
Resource        ${CURDIR}/../../../resources/Variables/common_variables.robot
Resource        ${CURDIR}/../../../resources/Keywords/common_keywords.robot


*** Variables ***
${DELTACONFIGDIR}       ${CURDIR}/../../config/gnb_scf/
${APCONFIGDIR}          ${CURDIR}/../../config/ap_iphy/
${TOPOLOGY}             CLOUD_5G_I_LO_AP_LO
${UE1}                  51
${UE2}                  71
${GW_ID}                1
${GNBDUCONFIGURATIONUPDATE_FILTER_N71}     nr-rrc.physCellId == 52 and nr-rrc.p_Max == 31 and f1ap.procedureCode == 7
${GNBDUCONFIGURATIONUPDATE_FILTER_N85}     nr-rrc.physCellId == 53 and nr-rrc.p_Max == 31 and f1ap.procedureCode == 7
${FIELD}        f1ap.UEContextModificationResponse_element
${AP_CONFIG_BASIC}         ${CURDIR}/../../config/wts


*** Keywords ***
Commision Scf And Iphy
    [Documentation]    This keyword is used to upload required iphy and commissioning GNB with required scf
    [Arguments]    ${scf}=${EMPTY}       ${iphy}=${EMPTY}
    Run Keyword If    '${iphy}' != '${EMPTY}'    Update And Put Iphy Xml
    ...      input_filepath=${iphy}
    Run Keyword If    '${scf}' != '${EMPTY}'     GNB Delta Commission
    ...    ${scf}

Prepare For CB010517 N71 And N85 PC1 Alignment
    [Documentation]    Prepare Test Setup for CB010517 N71 Test Case.
    Link SCOUT SCF To Configuration ID For Reporting
    Create Basic Interface On UTE
    ${LOG_PATH}     Create Log Directory        CB010517_N71
    Set Test Variable    ${LOG_PATH}
    Commision Scf And Iphy      scf=${DELTACONFIGDIR}/Delta_Config_n71_n85.json
    ...       iphy=${APCONFIGDIR}/iphy_n71_n85.xml
    Log To Console         \n Rebooting GNB wait for 360s
    GNB Reboot
    Sleep       360s
    Wait Coam Site To Be Ready
    Start Pcap Collection In GNB CU
    Start UTE WTS     basic_setup_n71_n85_updated_ue_capa.cfg
    Basic Bring Up

Stop Pcap Collection In GNB CU
    [Documentation]    This keyword is to stop PCAP logs from gnB
    ...     [arguments]    name     : This is file name where pcap logs will be collected, default name is gnbTcpdump
    ...                    Log_path : Path where pcap log file will be stored, default path is Log_Path
    ...     [return]    pcap_file   : pcap file path captured on wts
    ...     [usage]     Stop pcap collection in gNB
    ...                 Stop pcap collection in gNB     name=PCAPLOG    Log_Path= dir/dir/filename
    ...                 Stop pcap collection in gNB     gnbTcpdump1     dir/dir/filename
    [Arguments]                     ${NAME}=gnbTcpdump                  ${LOG_PATH}=${LOG_PATH}
    core.Stop Collectors            names=${NAME}
    core.Collect Collectors         names=${NAME}       target_dir=${LOG_PATH}
    core.Teardown Collectors        names=${NAME}
    ${pcap_file}    Join Path       ${LOG_PATH}         ${NAME}         ${NAME}.pcap
    Log To Console                  pcap capture is stopped
    [Return]                        ${pcap_file}

Common Test Case Tear Down LO AP LO
    [Documentation]    Tearing down and cleaning up the testline.
    Delete Basic Interface On UTE
    Collect Logs For The Test           ${LOG_PATH}
    Commision Scf And Iphy      scf=${DELTACONFIGDIR}/Delta_reverse.json
    ...       iphy=${APCONFIGDIR}/LO_AP_LO_iphy.xml
    Log To Console         \n Rebooting GNB wait for 360s
    GNB Reboot
    Sleep   300s

Check Pmax Is Correct For N71
    [Documentation]    Checking Pmax Value for  N71
    [Arguments]     ${pcap_file}
    ${pmax_value}      Get Fields From Pcap        ${pcap_file}
    ...        ${GNBDUConfigurationUpdate_filter_n71}         ${field}
    Should Not Be Empty         ${pmax_value}

Check Pmax Is Correct For N85
    [Documentation]    Checking Pmax correct for N85
    [Arguments]     ${pcap_file}
    ${pmax_value}      Get Fields From Pcap        ${pcap_file}
    ...        ${GNBDUConfigurationUpdate_filter_n85}         ${field}
    Should Not Be Empty         ${pmax_value}

Prepare Config To Validate Band N105 PDL Alignment
    [Documentation]    Validating N105 PDL alignment
    Commision Scf And Iphy      scf=${DELTACONFIGDIR}/Delta_Config_n105.json
    ...     iphy=${APCONFIGDIR}/LO_AP_LO_iphy.xml
    Sleep       200s
