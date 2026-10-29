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
${UE_ID_Rx2}        54
${gw_ID_Rx2}        54
${iphy}         ${CURDIR}/config/ap_iphy/iphy_IEF.xml
${Default_iphy}    ${CURDIR}/config/ap_iphy/new_iphy.xml
${UE_ID_Rx22}        55
${gw_ID_Rx22}        55


*** Test Cases ***
[1][1.0] CB010767_B_B1B2a_2_1Verify successful Intra DU Intra frequency HO for 1Rx redcap UE
    [Documentation]     Verify Intra DU Intra frequency HO
#    [Tags]    QC_28312   QCD_MN_RAN    QCP_RAN_VRF
    ${Test_CaseNumber}=     Set Variable    CB010767_B_2
    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    [Setup]      Run Keywords     Create Basic Interface on UTE
    ...     AND     Link SCOUT SCF to Configuration ID for Reporting
	...     AND     GNB Delta commission     ${CURDIR}/config/gnb_scf/Delta_FeatureEnabled_NoCellBarring.json
    ...     AND     GNB Delta commission     ${CURDIR}/config/gnb_scf/Delta_Configuration_scf_intraDU.json
    ...     AND     GNB Delta commission     ${CURDIR}/config/gnb_scf/Delta_8127.json
    ...     AND     GNB Reboot
    ...     AND     Sleep   360s
    ...     AND     Wait Coam Site to be Ready
    ...     AND     Start UTE WTS      basic_setup_redcap_IAF.cfg
    sleep   30s
    Log to Console      \nHO for 2Rx Redcap UE\n
    Wait For Next Full Pm Interval
    Make a SA call for GBR and NonGBR bearer        ${UE_ID_Rx2}      ${gw_ID_Rx2}
    ${measID}   Display Measurement Configuration for UE    ${UE_ID_Rx2}     A3
    Sleep   10s
    Flush console logs
    Trigger A3 Measurement      ${UE_ID_Rx2}    ${measID}     53
    Flush console logs
    sleep    40s
    wtsrunner.ue_deregister    id=${UE_ID_Rx2}     ue_deregister_type=switch_off
    Log to Console      \nCounter verification\n
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55166C00011   1     REDCAP_UE_RRC_STP_REQ
    ...     M55166C00012   1     REDCAP_UE_RRC_STP_SUCC
    ...     M55177C00015   1     RED_CAP_IAGNB_HO_PR_ATT_SA
    ...     M55177C00016   1     RED_CAP_IAGNB_HO_EX_ATT_SA
    ...     M55177C00017   1     RED_CAP_IAGNB_HO_EX_SUC_SA
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...     file_path=${pm_counter_file}
    Wait For Next Full Pm Interval
    Log to Console      \nHO for 1Rx Redcap UE\n
    Make a SA call for GBR and NonGBR bearer        ${UE_ID_Rx1}      ${gw_ID_Rx1}
    ${measID}   Display Measurement Configuration for UE    ${UE_ID_Rx1}     A3
    Sleep   10s
    Flush console logs
    Trigger A3 Measurement      ${UE_ID_Rx1}    ${measID}     53
    sleep    40s
    Flush console logs
    wtsrunner.ue_deregister    id=${UE_ID_Rx1}     ue_deregister_type=switch_off
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55166C00011   1     REDCAP_UE_RRC_STP_REQ
    ...     M55166C00012   1     REDCAP_UE_RRC_STP_SUCC
    ...     M55177C00015   1     RED_CAP_IAGNB_HO_PR_ATT_SA
    ...     M55177C00016   1     RED_CAP_IAGNB_HO_EX_ATT_SA
    ...     M55177C00017   1     RED_CAP_IAGNB_HO_EX_SUC_SA
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...     file_path=${pm_counter_file}
    [Teardown]    Run keywords    GNB Delta commission     ${CURDIR}/config/gnb_scf/Delta_FeatureEnabled_NoCellBarring_reverse.json
    ...     AND     GNB Delta commission     ${CURDIR}/config/gnb_scf/Delta_Configuration_scf_intraDU_reverse.json
    ...     AND     GNB Delta commission     ${CURDIR}/config/gnb_scf/Delta_8127_reverse.json
    ...     AND     GNB Reboot
    ...     AND     Sleep   360s
    ...     AND     Wait Coam Site to be Ready


[1][1.0] CB010767_B_B1B2b_6_Verify that A2 or A3 or A5 measurements are configured successfully for 1Rx redcap UE upon re-establishment
    [Documentation]  This script contains optimized test procedure for three fetures listed below:
	...		1. To test (CB010767) 1RX Reduced Capability UE RRC re-establishment to same cell, followed by A2 measurement
    ...		and finally A3 measurement HO to neighbouring cell.
    ...     2. To test (CB009384) 2RX Reduced Capability UE RRC re-establishment to same cell, followed by A2 measurement
    ...		and finally A3 measurement HO to neighbouring cell. CB009384_B_B1B2b_6.robot
    ...		3. This test also contains VoNR (CB008033) related counter check for both 1RX redcap UE and 2RX redcap UE
    [Tags]    QC_28306   QCD_MN_RAN    QCP_RAN_VRF
    ${Test_CaseNumber}=     Set Variable    CB010767_B_2
    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    [Setup]      Run Keywords     Create Basic Interface on UTE
    ...     AND     Link SCOUT SCF to Configuration ID for Reporting
    ...     AND     update_and_put_iphy_xml      input_filepath=${iphy}
    ...     AND     GNB Delta commission     ${CURDIR}/config/gnb_scf/Delta_FeatureEnabled_NoCellBarring.json
    ...     AND     Sleep   120s
    ...     AND     GNB Delta commission     ${CURDIR}/config/gnb_scf/Delta_Configuration_scf_IEF.json
    ...     AND     Sleep   120s
    ...     AND     GNB Delta commission     ${CURDIR}/config/gnb_scf/Delta_8127.json
    ...     AND     Sleep   120s
    ...     AND     GNB Delta commission     ${CURDIR}/config/gnb_scf/Delta_Configuration_scf_10767_RsrpSA_updated_param.json
    ...     AND     Sleep   120s
    ...     AND     GNB Delta commission     ${CURDIR}/config/gnb_scf/Delta_Configuration_VoNR.json
    ...     AND     GNB Delta commission     ${CURDIR}/config/gnb_scf/Delta_Configuration_scf_enableReestablishment.json
    ...     AND     GNB Reboot
    ...     AND     Sleep   420s
    ...     AND     Wait Coam Site to be Ready
    ...     AND     Start UTE WTS      basic_setup_redcap_IEF.cfg
    sleep   30s
    Log to console      \n================== (CB010767)1RX Redcap UE Testing ==================\n
    Make a SA call for GBR NonGBR bearer       ${UE_ID_Rx1}      ${gw_ID_Rx1}
    Flush console logs
    Wait For Next Full Pm Interval
	Log to console      \n---Triggering 1RX redcap UE RRC Re-establishment to same cell---\n
    wtsrunner.ue_rrc_reestablish        id=${UE_ID_Rx1}       gnb=2      cell=3       cause=otherFailure
    Sleep   20s
    Flush console logs
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55166C00017   1     REDCAP_UE_NRD_RRC_REESTABREQ
    ...     M55166C00018   1     REDCAP_UE_NRD_RRC_REESTABSUCC
    ...     M55138C00057   1     PEAK_OF_SA_RRC_REDCAP_CU
    ...     M55138C00061   1     PEAK_OF_SA_RRC_REDCAP_1RX_CU
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...     file_path=${pm_counter_file}
	Log to console      \n---Triggering 1RX redcap UE A2 Measurement---\n
    ${measID_a2}   Display Measurement Configuration for UE    ${UE_ID_Rx1}      A2
    Log to console      \nA2 Measurement ID:${measID_a2}\n
    Start pcap collection in gNB CU     gnbTcpdump_1RX
    Wait For Next Full Pm Interval
    Trigger A2 Measurement      ${UE_ID_Rx1}     ${measID_a2}    52
    Sleep   20s
    Flush console logs
	Log to console      \n---Triggering 1RX redcap UE A3 Measurement---\n
    ${measID_a3}   Display Measurement Configuration for UE    ${UE_ID_Rx1}     A3
    Log to console      \nA3 Measurement ID: ${measID_a3}\n
    Sleep   10s
    Flush console logs
    Trigger A3 Measurement      ${UE_ID_Rx1}    ${measID_a3}     53
    Flush console logs
    Stop pcap collection in gNB     gnbTcpdump_1RX      ${Log_Path}
    sleep    30s
    wtsrunner.ue_deregister    id=${UE_ID_Rx1}     ue_deregister_type=switch_off
    Flush console logs
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55177C00015   1     RED_CAP_IAGNB_HO_PR_ATT_SA
    ...     M55177C00016   1     RED_CAP_IAGNB_HO_EX_ATT_SA
    ...     M55177C00017   1     RED_CAP_IAGNB_HO_EX_SUC_SA
    ...     M55177C00003   1     IEF_IADU_HO_PR_ATT_SA_VONR
    ...     M55177C00004   1     IEF_IADU_HO_EX_ATT_SA_VONR
    ...     M55177C00005   1     IEF_IADU_HO_EX_SUC_SA_VONR
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...     file_path=${pm_counter_file}
	Verify Last Counters In File
    ...     M55190C00001    2    SA_MEAS_PROFILE_SELECTED
    ...     local_moid=PLMN-PLMN/NRMASA-1
    ...     file_path=${pm_counter_file}
    Verify Last Counters In File
    ...     M55188C00001   1     IEF_MEAS_PROFILE_CONF_ATT
    ...     local_moid=PLMN-PLMN/NRMIEF-1
    ...     file_path=${pm_counter_file}
    Flush console logs
    Log to console      \n==============(CB009384)2RX Redcap UE Testing ===============\n
    Make a SA call for GBR NonGBR bearer     ${UE_ID_Rx22}      ${gw_ID_Rx22}
    Flush console logs
    Wait For Next Full Pm Interval
	Log to console      \n---Triggering 2RX redcap UE RRC Re-establishment to same cell---\n
    wtsrunner.ue_rrc_reestablish        id=${UE_ID_Rx22}       gnb=2      cell=3       cause=otherFailure
    Sleep   20s
    Flush console logs
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55166C00017   1     REDCAP_UE_NRD_RRC_REESTABREQ
    ...     M55166C00018   1     REDCAP_UE_NRD_RRC_REESTABSUCC
    ...     M55138C00057   1     PEAK_OF_SA_RRC_REDCAP_CU
    ...     M55138C00061   0     PEAK_OF_SA_RRC_REDCAP_1RX_CU
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...     file_path=${pm_counter_file}
	Log to console      \n---Triggering 1RX redcap UE A2 Measurement---\n
    ${measID_a2}   Display Measurement Configuration for UE    ${UE_ID_Rx22}     A2
    Log to console      \nA2 Measurement ID: ${measID_a2}\n
    Start pcap collection in gNB CU     gnbTcpdump_2RX
    Wait For Next Full Pm Interval
    Trigger A2 Measurement      ${UE_ID_Rx22}    ${measID_a2}    52
    Sleep   20s
    Flush console logs
    ${measID_a3}   Display Measurement Configuration for UE    ${UE_ID_Rx22}     A3
    Log to console      \nA3 Measurement ID: ${measID_a3}\n
    Sleep   10s
    Flush console logs
	Log to console      \n---Triggering 1RX redcap UE A3 Measurement---\n
    Trigger A3 Measurement      ${UE_ID_Rx22}    ${measID_a3}     53
    Flush console logs
    Stop pcap collection in gNB     gnbTcpdump_2RX      ${Log_Path}
    sleep    30s
    wtsrunner.ue_deregister    id=${UE_ID_Rx22}     ue_deregister_type=switch_off
    Flush console logs
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55177C00015   1     RED_CAP_IAGNB_HO_PR_ATT_SA
    ...     M55177C00016   1     RED_CAP_IAGNB_HO_EX_ATT_SA
    ...     M55177C00017   1     RED_CAP_IAGNB_HO_EX_SUC_SA
    ...     M55177C00003   1     IEF_IADU_HO_PR_ATT_SA_VONR
    ...     M55177C00004   1     IEF_IADU_HO_EX_ATT_SA_VONR
    ...     M55177C00005   1     IEF_IADU_HO_EX_SUC_SA_VONR
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...     file_path=${pm_counter_file}
    Flush console logs
    [Teardown]    Rat block unblock


*** Keywords ***
Make SA call with reestablishment
    [Arguments]    ${UE_ID}=${UE_ID}    ${gw_ID}=${gw_ID}
    Enable Internal TG   1  1
    wtsrunner.ue_register   id=${UE_ID}
    Sleep   30s
    wtsrunner.ue_pdu_session_setup    pdu=${Pdu_session_ID}    ue=${UE_ID}    nwslice=${nwslice_ID}    gw=${gw_ID}
    Sleep   30s
    Trigger Reestablishment     1   2   1   otherFailure
    Sleep   20s

Make a SA call for GBR and NonGBR bearer
    [Arguments]     ${UE_ID}=${UE_ID}    ${gw_ID}=${gw_ID}
    Flush console logs
    Enable Internal TG   ${UEID}    1
    wtsrunner.ue_register   id=${UEID}
    sleep   20s
    Flush console logs
    wtsrunner.smf_param     additional_qosflows_to_activate=1,2       id=1
    Flush console logs
    wtsrunner.ue_pdu_session_setup    pdu=1    ue=${UEID}   nwslice=1   gw=${gw_ID}
    Sleep   30s
    Flush console logs
