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
#    Start pcap collection in gNB CU     gnbTcpdump
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
#    Log to Console      \nA Pong HO\n
#    ${measID}   Display Measurement Configuration for UE    54     A5
#    Sleep   10s
#    Trigger A3 Measurement      54    ${measID}     52
#    sleep    40s
#    Log to Console      \n
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
#    Log to Console      \nA Pong HO\n
#    ${measID}   Display Measurement Configuration for UE    57     A5
#    Sleep   10s
#    Trigger A3 Measurement      57    ${measID}     52
#    sleep    40s
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
