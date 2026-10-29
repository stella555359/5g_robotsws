*** Settings ***
Documentation   :copyright: Nokia
...             :author   : amitha
...             :contact  : amitha.kadambi@nokia.com
Library     ute_fsmaccess
Library     ta5g_pm_counters
Library     ta5g_tshark
Resource    ${CURDIR}/resources/Keywords/CB010767_KW.robot

Suite Setup       Updated Suite Setup
Suite Teardown    Common Suite Teardown


*** Variables  ***
${UE_ID_Rx1}        1
${UE_ID_Rx2}        2
${IEFR_a2meas_id}  1
${phycell_id_realgNB}  52
${IEFR_b2meas_id}  3
${phycell_id_remote}  11
${gw_ID_Rx1}    1
${gw_ID_Rx2}    2
${iphy}    ${CURDIR}/config/ap_iphy/irat.xml

*** Test Cases ***
[1][1.0] CB010767-B B8a_30_1Verify 1Rx Redcap UE HO from 5G to LTE is successful
    [Documentation]     This test case shall help verify IRAT HO for RedCap UE to and from a 5G cell.
    ...     The counters for incoming and outgoing IRAT HO also are verified for both 1Rx and 2Rx redcap UEs.
    ...     Test coverage also contains CB008033_B_B1_TC6.robot and  CB009384_B_B7a_22.robot
#    [Tags]    QC_28308   QCD_MN_RAN    QCP_RAN_VRF
    ${Test_CaseNumber}=     Set Variable    CB010767_B_30
    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Log to Console      Starting the test
    [Setup]      Run Keywords     Create Basic Interface on UTE
    ...     AND     Link SCOUT SCF to Configuration ID for Reporting
    ...     AND     Commision iphy   ${iphy}
    ...     AND     Sleep   20s
    ...     AND     GNB Delta commission     ${CURDIR}/config/gnb_scf/Delta_8127.json
    ...     AND     Sleep   120s
    ...     AND     GNB Delta commission     ${CURDIR}/config/gnb_scf/Delta_FeatureEnabled_NoCellBarring.json
    ...     AND     Sleep   120s
    ...     AND     GNB Delta commission     ${CURDIR}/config/gnb_scf/IRAT.json
    ...     AND     Sleep   60s
    ...     AND     GNB Delta commission     ${CURDIR}/config/gnb_scf/Delta_Configuration_VoNR.json
    ...     AND     Sleep   60s
    ...     AND     GNB Reboot
    ...     AND     Sleep   420s
    ...     AND     Wait Coam Site to be Ready
    ...     AND     Start UTE WTS      irat_redcap.cfg
    Log to console      \n================== (CB010767) 1RX Redcap UE Testing ==================\n
    Wait For Next Full Pm Interval
    Sleep       40s
    Make a SA call for GBR NonGBR bearer        ${UE_ID_Rx1}    ${gw_ID_Rx1}
    Flush console logs
    Log to Console     \nA2\n
    Run Keyword And Ignore Error    Trigger A2 for IRAT HO     ${UE_ID_Rx1}        ${IEFR_a2meas_id}       ${phycell_id_realgNB}
    Sleep       30s
    Flush console logs
    Log to Console      \nB2\n
    Run Keyword And Ignore Error    Trigger B2 measurement     ${UE_ID_Rx1}        ${IEFR_b2meas_id}       ${phycell_id_remote}
    Flush console logs
    Sleep       40s
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55142C00517   1     RED_CAP_OUT_IRAT_HO_PR_ATT_SRC
    ...     M55142C00518   1     RED_CAP_OUT_IRAT_HO_PR_SUC_SRC
    ...     M55142C00519   1     RED_CAP_OUT_IRAT_HO_EX_SUC_SRC
    ...     M55138C00057   1     PEAK_OF_SA_RRC_REDCAP_CU
    ...     M55138C00061   1     PEAK_OF_SA_RRC_REDCAP_1RX_CU
    ...     M55125C13028   1     NG_O_IRAT_HO_EX_ATT_VONR
    ...     M55125C13029   1     NG_O_IRAT_HO_EX_SUC_VONR
    ...     M55125C13027   1     NG_O_IRAT_HO_PR_ATT_VONR
    ...     M55125C13024    >0    AVG_TIME_O_NG_IRAT_HO_EX_VONR
    ...     M55125C13025    >0    MAX_TIME_O_NG_IRAT_HO_EX_VONR
    ...     M55125C13001    >0    AVG_TIME_O_NG_IRAT_HO_EX
    ...     M55125C13002    >0    MAX_TIME_O_NG_IRAT_HO_EX
    ...     M55125C13003    >0    AVG_TIME_O_NG_IRAT_HO_PR
    ...     M55125C13004    >0    MAX_TIME_O_NG_IRAT_HO_PR
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...     file_path=${pm_counter_file}
    Wait For Next Full Pm Interval
    Run Keyword And Ignore Error     Trigger eNB initiated inter-rat handover to 5g   ${UE_ID_Rx1}  2   3
    Flush console logs
    Sleep       40s
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55142C00520   1     RED_CAP_INC_IRAT_HO_PR_ATT_TRG
    ...     M55142C00521   1     RED_CAP_INC_IRAT_HO_PR_SUC_TRG
    ...     M55142C00522   1     RED_CAP_INC_IRAT_HO_EX_SUC_TRG
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...     file_path=${pm_counter_file}
    Run Keyword And Ignore Error     wtsrunner.ue_deregister    id=${UE_ID_Rx1}     ue_deregister_type=switch_off
    Flush console logs
    Log to console      \n================== (CB009384) 2RX Redcap UE Testing ==================\n
    Wait For Next Full Pm Interval
    Sleep       40s
    Make a SA call for GBR NonGBR bearer        ${UE_ID_Rx2}    ${gw_ID_Rx2}
    Flush console logs
    Log to Console     \nA2\n
    Run Keyword And Ignore Error    Trigger A2 for IRAT HO     ${UE_ID_Rx2}        ${IEFR_a2meas_id}       ${phycell_id_realgNB}
    Sleep       30s
    Flush console logs
    Log to Console      \nB2\n
    Run Keyword And Ignore Error    Trigger B2 measurement     ${UE_ID_Rx2}        ${IEFR_b2meas_id}       ${phycell_id_remote}
    Flush console logs
    Sleep       40s
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55142C00517   1     RED_CAP_OUT_IRAT_HO_PR_ATT_SRC
    ...     M55142C00518   1     RED_CAP_OUT_IRAT_HO_PR_SUC_SRC
    ...     M55142C00519   1     RED_CAP_OUT_IRAT_HO_EX_SUC_SRC
    ...     M55138C00057   1     PEAK_OF_SA_RRC_REDCAP_CU
    ...     M55138C00061   0     PEAK_OF_SA_RRC_REDCAP_1RX_CU
    ...     M55125C13028   1     NG_O_IRAT_HO_EX_ATT_VONR
    ...     M55125C13029   1     NG_O_IRAT_HO_EX_SUC_VONR
    ...     M55125C13027   1     NG_O_IRAT_HO_PR_ATT_VONR
    ...     M55125C13024    >0    AVG_TIME_O_NG_IRAT_HO_EX_VONR
    ...     M55125C13025    >0    MAX_TIME_O_NG_IRAT_HO_EX_VONR
    ...     M55125C13001    >0    AVG_TIME_O_NG_IRAT_HO_EX
    ...     M55125C13002    >0    MAX_TIME_O_NG_IRAT_HO_EX
    ...     M55125C13003    >0    AVG_TIME_O_NG_IRAT_HO_PR
    ...     M55125C13004    >0    MAX_TIME_O_NG_IRAT_HO_PR
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...     file_path=${pm_counter_file}
    Wait For Next Full Pm Interval
    Run Keyword And Ignore Error      Trigger eNB initiated inter-rat handover to 5g   ${UE_ID_Rx2}   2   3
    Flush console logs
    Sleep       40s
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55142C00520   1     RED_CAP_INC_IRAT_HO_PR_ATT_TRG
    ...     M55142C00521   1     RED_CAP_INC_IRAT_HO_PR_SUC_TRG
    ...     M55142C00522   1     RED_CAP_INC_IRAT_HO_EX_SUC_TRG
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...     file_path=${pm_counter_file}
    Run Keyword And Ignore Error     wtsrunner.ue_deregister    id=${UE_ID_Rx2}     ue_deregister_type=switch_off
    Flush console logs
