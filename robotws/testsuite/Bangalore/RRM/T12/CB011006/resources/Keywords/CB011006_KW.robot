*** Settings ***
Documentation    This contains the Keywrods specific to the Feature CB011006.
Library        BuiltIn
Library        Collections
Library        String
Library        OperatingSystem
Library        taf.sbts.oam.coam.admin         WITH NAME    admin
Library        ute_fsmaccess
Library        ta5g_pm_counters
Library        taf.analyzer.pcap    WITH NAME    cap
Variables      ta5g_global_var
Library        ${CURDIR}/../../../resources/PythonLib/UTILS.py
Resource       ${CURDIR}/../../../resources/Keywords/ap_Keywords.robot
Resource       ${CURDIR}/../../../resources/Keywords/generic_kw.robot
Resource       ${CURDIR}/../../../resources/Keywords/gnb_Keywords.robot
Resource       ${CURDIR}/../../../resources/Keywords/tsharkPcapVerifyKeywords.robot
Resource       ${CURDIR}/../../../resources/Keywords/HO_KW.robot
Resource        ${CURDIR}/../../../resources/Keywords/ute_wts_runner.robot
Resource        ${CURDIR}/../../../resources/Variables/common_variables.robot
Resource        ${CURDIR}/../../../resources/Keywords/common_keywords.robot


*** Variables ***
${VLAN_ID}              ${tl.gnbs[0].cu.x2c.vlan_id}
${MRBTS_DISTNAME}       MRBTS-1
${vlanif_distname}      ${MRBTS_DISTNAME}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1
${DELTACONFIGDIR}       ${CURDIR}/../../config/gnb_scf/
${APCONFIGDIR}          ${CURDIR}/../../config/ap_iphy/
${TOPOLOGY}             CLOUD_5G_I_LO_AP_LO
${UE_STATS_PDSCH_PATTERN}       NR PDSCH Throughput
${UE_STATS_PUSCH_PATTERN}       NR PUSCH Throughput
${TARGET_CELLS}     1
${LOG_PATH}    /home/ute/logs
${AP_CONFIG_BASIC}         ${CURDIR}/../../config/wts


*** Keywords ***
Common Test Case Tear Down LO AP LO
    [Documentation]    Tear Down for Test Case to collect logs and making site updated with LO_AP_LO SCF And Iphy up
    Delete Basic Interface On UTE
    Collect Logs For The Test           ${LOG_PATH}
    Update And Put Iphy Xml             ${APCONFIGDIR}/LO_AP_LO_iphy.xml
    Full Commission With SCF File For UTE      ${DELTACONFIGDIR}/LO_AP_LO_SCF.xml
    Sleep   360s

Common Test Case Tear Down BOO AP LOO
    [Documentation]    Tear Down for Test Case to collect logs and making site updated with BOO_AP_LOO SCF And Iphy up
    Delete Basic Interface On UTE
    Collect Logs For The Test           ${LOG_PATH}
    Update And Put Iphy Xml             ${APCONFIGDIR}/BOO_AP_LOO_iphy.xml
    Full Commission With SCF File For UTE      ${DELTACONFIGDIR}/BOO_AP_LOO_SCF.xml
    Sleep   360s

Prepare Test Case For CB011006_TC3_TC4_TC8_TC9
    [Documentation]    Preparing Common test Setup for TestCases CB011006_A_B2_TC3_TC4_TC8_TC9
    ${LOG_PATH}     Create Log Directory       CB011006_A_B2_TC3_TC4_TC8_TC9
    Link SCOUT SCF To Configuration ID For Reporting
    Set Test Variable        ${LOG_PATH}
    Create Basic Interface On UTE
    Update And Put Iphy Xml                ${APCONFIGDIR}/iphy_AHEGG_TC3_TC4_TC8_TC9.xml
    Full Commission With SCF File For UTE      ${DELTACONFIGDIR}/SCF_TC3_TC4_TC8_TC9.xml
    Sleep   360s
    Wait Coam Site To Be Ready
    Start UTE WTS      basic_setup_TC3_TC4_TC8_TC9.cfg

Prepare Test Case For CB011006_TC12
    [Documentation]    Preparing Common test Setup for TestCases CB011006_B_B2_TC12
    ${LOG_PATH}     Create Log Directory       CB011006_B_B2_TC12
    Link SCOUT SCF To Configuration ID For Reporting
    Set Test Variable        ${LOG_PATH}
    Create Basic Interface On UTE
    Update And Put Iphy Xml            ${APCONFIGDIR}/iphy_TC12.xml
    Full Commission With SCF File For UTE      ${DELTACONFIGDIR}/SCF_TC12.xml
    Sleep   360s
    Wait Coam Site To Be Ready
    Start UTE WTS      basic_setup_TC12.cfg

Prepare Test Case For CB011006_TC13
    [Documentation]    Preparing Common test Setup for TestCases CB011006_B_B2_TC13
    ${LOG_PATH}     Create Log Directory       CB011006_B_B2_TC13
    Link SCOUT SCF To Configuration ID For Reporting
    Set Test Variable        ${LOG_PATH}
    Create Basic Interface On UTE
    Update And Put Iphy Xml            ${APCONFIGDIR}/iphy_AHEGHA_N7_TC13.xml
    Full Commission With SCF File For UTE      ${DELTACONFIGDIR}/SCF_TC13.xml
    Sleep   360s
    Wait Coam Site To Be Ready
    Start UTE WTS      basic_setup_TC13.cfg

Make ENDC Call
    [Documentation]     For NSA Call LTE Attach is Done for L3 Call
    [Arguments]    ${UE_ID}=${UE_ID}    ${TARGET_CELLS}=${TARGET_CELLS}    ${TRF_DL}=5    ${TRF_UL}=2
    LTE Attach Should Be Successful For NSA     ${UE_ID}
    Enb Endc Param      id=1    serving_cell_index_range_scg=5:31
    UE Attach Should Be Successful For NSA      ${UE_ID}    ${TARGET_CELLS}
    Sleep    10s
    Traffic Should Be Successful For NSA    ${UE_ID}    ${TRF_DL}    ${TRF_UL}

Make SA Call
    [Documentation]    For SA Call UE Register is done for L3 Call
    [Arguments]    ${UE_ID}=${UE_ID}    ${GW_ID}=${GW_ID}
    Enable Internal TG      ${UE_ID}    1
    UE Register Should Be Successful For SA     ${UE_ID}    ${GW_ID}
    Sleep   10s
