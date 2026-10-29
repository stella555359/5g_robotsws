*** Settings ***
Documentation   :copyright: Nokia
...             :author   : Amitha
...             :contact  : amitha.kadambi@nokia.com
Library     ute_fsmaccess
Library     ta5g_pm_counters
Library     ta5g_tshark
Resource    ${CURDIR}/resources/Keywords/CB010767_KW.robot

Suite Setup       Updated Suite Setup
Suite Teardown    Common Suite Teardown


*** Variables  ***
${UE_ID_Rx1}        57
${gw_ID_Rx1}        57
${UE_ID_Rx2}        55
${gw_ID_Rx2}        55


*** Test Cases ***
[1][1.0] CB010767-B B6a_23_1Verify that 1Rx redcap UE supports Inter gNB intra frequency NG based HO
    [Documentation]     This test case shall help verify NG HO and counters for redcap.
    ...         Test scope also covers CB009384_B_B6a_18.robot & CB008033_A_A3_11.robot
#    [Tags]    QC_28309   QCD_MN_RAN    QCP_RAN_VRF
    ${Test_CaseNumber}=     Set Variable    CB010767_B6a
    Link SCOUT SCF to Configuration ID for Reporting
    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Log to Console      Starting the test
    [Setup]      Run Keywords     Create Basic Interface on UTE
    ...     AND     GNB Delta commission     ${CURDIR}/config/gnb_scf/Delta_8127.json
    ...     AND     GNB Delta commission     ${CURDIR}/config/gnb_scf/Delta_FeatureEnabled_NoCellBarring.json
    ...     AND     GNB Delta commission     ${CURDIR}/config/gnb_scf/Delta_Configuration_APoABIL_IANG_FDD.json
    ...     AND     GNB Reboot
    ...     AND     Sleep   360s
    ...     AND     Wait Coam Site to be Ready
    ...     AND     Start UTE WTS                basic_setup_redcap_Xn.cfg
    sleep    40s
    Basic Bring up
    Log to console      \n================== (CB010767)1RX Redcap UE Testing ==================\n
    Wait For Next Full Pm Interval
    Make a SA call for GBR NonGBR bearer    ${UE_ID_Rx1}      ${gw_ID_Rx1}
    Sleep   30s
    ${measID}   Display Measurement Configuration for UE    ${UE_ID_Rx1}     A3
    Sleep   10s
    Flush console logs
    Run keyword and ignore error    Trigger NG HO from Real to RANSIM with A3    ${UE_ID_Rx1}    ${measID}       55
    Sleep   30s
    Flush console logs
    Run keyword and ignore error    wtsrunner.ue_deregister         id=${UE_ID_Rx1}     ue_deregister_type=switch_off
    Sleep   30s
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55178C00009   1     RED_CAP_IEGNB_HO_PR_ATT_SRC
    ...     M55178C00010   1     RED_CAP_IEGNB_HO_EX_ATT_SRC
    ...     M55178C00011    1     RED_CAP_IEGNB_HO_EX_SUC_SRC
    ...     M55138C00057   1     PEAK_OF_SA_RRC_REDCAP_CU
    ...     M55138C00061   1     PEAK_OF_SA_RRC_REDCAP_1RX_CU
    ...     M55125C13016    1     IAF_NG_HO_PR_ATT_SRC_VONR
    ...     M55125C13017    1     IAF_NG_HO_EX_ATT_SRC_VONR
    ...     M55125C13018    1     IAF_NG_HO_EX_SUC_SRC_VONR
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...     file_path=${pm_counter_file}
    Verify Last Counters In File
    ...     M55190C00001    1    SA_MEAS_PROFILE_SELECTED
    ...     local_moid=PLMN-PLMN/NRMASA-1
    ...     file_path=${pm_counter_file}
    Verify Last Counters In File
    ...     M55187C00001   1     IAF_MEAS_PROFILE_CONF_ATT
    ...     local_moid=PLMN-PLMN/NRMIAF-1
    ...     file_path=${pm_counter_file}
    Log to console      \n================== (CB009384)2RX Redcap UE Testing ==================\n
    Wait For Next Full Pm Interval
    Flush console logs
    Make a SA call for GBR NonGBR bearer    ${UE_ID_Rx2}      ${gw_ID_Rx2}
    Sleep   30s
    ${measID}   Display Measurement Configuration for UE    ${UE_ID_Rx2}     A3
    Sleep   10s
    Flush console logs
    Run keyword and ignore error    Trigger NG HO from Real to RANSIM with A3    ${UE_ID_Rx2}    ${measID}       55
    Sleep   30s
    Flush console logs
    Run keyword and ignore error    wtsrunner.ue_deregister         id=${UE_ID_Rx2}     ue_deregister_type=switch_off
    Sleep   30s
    Flush console logs
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55178C00009   1     RED_CAP_IEGNB_HO_PR_ATT_SRC
    ...     M55178C00010   1     RED_CAP_IEGNB_HO_EX_ATT_SRC
    ...     M55178C00011    1     RED_CAP_IEGNB_HO_EX_SUC_SRC
    ...     M55138C00057   1     PEAK_OF_SA_RRC_REDCAP_CU
    ...     M55138C00061   0     PEAK_OF_SA_RRC_REDCAP_1RX_CU
    ...     M55125C13016    1     IAF_NG_HO_PR_ATT_SRC_VONR
    ...     M55125C13017    1     IAF_NG_HO_EX_ATT_SRC_VONR
    ...     M55125C13018    1     IAF_NG_HO_EX_SUC_SRC_VONR
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...     file_path=${pm_counter_file}
