*** Settings ***
Documentation    This file consit of Keywrds
...              specifically written for this Feature CB008229.

Library        BuiltIn
Library        Collections
Library        OperatingSystem
Library        String
Library        taf.sbts.oam.coam.admin         WITH NAME    admin
Resource       ${CURDIR}/../../../resources/Keywords/HO_KW.robot
Resource       ${CURDIR}/../../../resources/Keywords/generic_kw.robot
Resource       ${CURDIR}/../../../resources/Keywords/gnb_Keywords.robot
Resource       ${CURDIR}/../../../resources/Keywords/tsharkPcapVerifyKeywords.robot
Resource       ${CURDIR}/../../../resources/Keywords/ute_wts_runner.robot
Resource       ${CURDIR}/../../../resources/Keywords/ap_Keywords.robot
Resource       ${CURDIR}/../../../resources/Keywords/common_keywords.robot


*** Variables ***
${TOPOLOGY}         CLOUD_5G_I_LO_AP_LO
${NSA_UEID_11}      11
${NSA_UEID_151}     151
${UE_51}            51
${LOG_DIR}          /home/ute/logs
${VLAN_ID}          ${tl.gnbs[0].cu.x2c.vlan_id}
${MRBTS_DISTNAME}         MRBTS-1
${VLANIF_DISTNAME}        ${MRBTS_DISTNAME}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1
${DELTACONFIGDIR}         ${CURDIR}/../../config/gnb_scf
${APCONFIGDIR}            ${CURDIR}/../../config/ap_iphy
${AP_CONFIG_BASIC}     ${CURDIR}/../../config/wts


*** Keywords ***
Commision scf and iphy
    [Documentation]    This keyword is used to upload required iphy and commissioning GNB with required scf
    [Arguments]    ${scf}=${EMPTY}       ${iphy}=${EMPTY}
    Run Keyword If    '${iphy}' != '${EMPTY}'    Update And Put Iphy Xml
    ...      input_filepath=${iphy}
    Run Keyword If    '${scf}' != '${EMPTY}'     GNB Delta Commission
    ...    ${scf}

Prepare For Test Case - CB008229A
    [Documentation]    Preparing For Testcase of 'A' sub feature
    ${LOG_PATH}      Create Log Directory    CB008229_A_b
    Link SCOUT SCF to Configuration ID for Reporting
    Set Test Variable    ${LOG_PATH}
    Create Basic Interface On UTE
    Commision Scf And Iphy      scf=${DELTACONFIGDIR}/Delta_Configuration_8229_A.json
    ...       iphy=${APCONFIGDIR}/Iphy_updated.xml
    Log To Console         \n Rebooting GNB wait for 360s
    GNB Reboot
    Sleep   360s
    Wait Coam Site To Be Ready
    Start Pcap Collection In GNB CU
    Start UTE WTS     basic_MP_AP_LO.cfg

Prepare For Test Case - CB008229 TC06
    [Documentation]    Preparing For Testcase of 'TC06' sub feature
    ${LOG_PATH}      Create Log Directory    CB008229_A_f
    Link SCOUT SCF to Configuration ID for Reporting
    Set Test Variable    ${LOG_PATH}
    Create Basic Interface On UTE
    Commision Scf And Iphy      scf=${DELTACONFIGDIR}/Delta_Configuration_8229_A_HO.json
    ...       iphy=${APCONFIGDIR}/TC06_iphy.xml
    Log To Console         \n Rebooting GNB wait for 360s
    GNB Reboot
    Sleep   360s
    Wait Coam Site To Be Ready
    Start UTE WTS     new_basic.cfg

Common Test Case Tear Down LO AP LO
    [Documentation]    Common Teardown for all testCases.
    Delete Basic Interface On UTE
#    Collect Logs For The Test           ${Log_Path}
    RAT Block Unblock

Make SA Call
    [Documentation]    This is L3 SA Call for this Feature.
    [Arguments]    ${UE_ID}=${UE_51}    ${GW_ID}=${GW_ID}
    Enable Internal TG       51      1
    UE Register Should Be Successful For SA     ${UE_ID}     ${GW_ID}
    Sleep       10s
    Traffic Should Be Successful For SA    UE_ID=${UE_ID}
    Sleep       30s
    Stop Data Traffic For SA        ${UE_ID}

Make ENDC Call
    [Documentation]    This is for LTE NSA L3 Call Start for this Feature.
    [Arguments]    ${NSA_UEID}=${NSA_UEID_151}
    LTE Attach Should Be Successful For NSA         UE_ID=${NSA_UEID}
    Enb Endc Param      id=1    serving_cell_index_range_scg=5:31
    UE Attach Should Be Successful For NSA          ${NSA_UEID}       1

Common Test Case Tear Down MP AP LO
    [Documentation]    Common Teardown for all testCases.
    Delete Basic Interface On UTE
#    Collect Logs For The Test           ${Log_Path}
    RAT Block Unblock
    Link SCOUT SCF To Configuration ID For Reporting
