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


*** Test Cases ***
[1][1.0] CB010767_A_Ei5_24_1Verify that 1RX redcap UE can successfully re-establish to the same cell.
    [Documentation]     This test case shall help verify RedCap UE functionality for successful re-establishment on same cell.
    [Tags]    QC_28316   QCD_MN_RAN    QCP_RAN_VRF
    ${Test_CaseNumber}=     Set Variable    CB010767_24
    Link SCOUT SCF to Configuration ID for Reporting
    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Log to Console      Starting the test
    GNB Delta commission     ${CURDIR}/config/gnb_scf/Delta_FeatureEnabled_NoCellBarring.json
	GNB Delta commission     ${CURDIR}/config/gnb_scf/Delta_Configuration_scf_enableReestablishment.json
    Wait For Next Full Pm Interval
    Start UTE WTS      basic_setup_redcap.cfg
    Wait For Next Full Pm Interval
    Start pcap collection in gNB CU     gnbTcpdump
    Make SA call with reestablishment       54      54
    Make SA call with reestablishment       57      57
    [Teardown]     Run Keywords    GNB Delta commission    ${CURDIR}/config/gnb_scf/Delta_FeatureEnabled_NoCellBarring_reverse.json
    ...     AND    GNB Delta commission    ${CURDIR}/config/gnb_scf/Delta_Configuration_scf_enableReestablishment_reverse.json
    ...      AND    RAT Block Unblock


[1][1.0] CB010767_A_Ei6_26_1Verify 1Rx redcap UE can re-establish to cell under same DU. Via RRCSetup.
    [Documentation]     This test case shall help verify RedCap UE functionality for successful re-establishment to diff cell.
    [Tags]    QC_28315   QCD_MN_RAN    QCP_RAN_VRF
    ${Test_CaseNumber}=     Set Variable    CB010767_26
    Link SCOUT SCF to Configuration ID for Reporting
    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Log to Console      Starting the test
    GNB Delta commission     ${CURDIR}/config/gnb_scf/Delta_FeatureEnabled_NoCellBarring.json
	GNB Delta commission     ${CURDIR}/config/gnb_scf/Delta_Configuration_scf_RRCreest.json
    Wait For Next Full Pm Interval
    Start UTE WTS      basic_setup_redcap.cfg
    Wait For Next Full Pm Interval
    Start pcap collection in gNB CU     gnbTcpdump
    Make SA call with reestablishment Cell4       54      54
    Make SA call with reestablishment cell4      57      57
    [Teardown]     Run Keywords    GNB Delta commission    ${CURDIR}/config/gnb_scf/Delta_FeatureEnabled_NoCellBarring_reverse.json
    ...     AND    GNB Delta commission    ${CURDIR}/config/gnb_scf/Delta_Configuration_scf_RRCreest_reverse.json
    ...     AND    RAT Block Unblock


*** Keywords ***
Make SA call with reestablishment Cell4
    [Arguments]    ${UEID}=${UEID}    ${gw_ID}=${gw_ID}
    [Documentation]    This keyword shall register UE and establish GBR and Non-GBR data calls and re-establishment
#    Start pcap collection in gNB CU     gnbTcpdump_UE ${UE_ID}
    sim log set
    Enable Internal TG   ${UEID}    1
    sim log set
    wtsrunner.ue_register   id=${UEID}
    sleep   20s
    wtsrunner.ue_pdu_session_setup    pdu=1    ue=${UEID}   nwslice=1   gw=${gw_ID}
    Sleep   20s
    sim log set
    wtsrunner.ue_rrc_reestablish        id=${UEID}       gnb=2      cell=4       cause=otherFailure
    Sleep   20s
    wtsrunner.ue_deregister         id=${UEID}       ue_deregister_type=switch_off
#	Stop pcap collection in gNB     gnbTcpdump      ${Log_Path}
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55166C00011   1     REDCAP_UE_RRC_STP_REQ
    ...     M55166C00012   1     REDCAP_UE_RRC_STP_SUCC
    ...     M55166C00013   1     REDCAP_UE_RRC_RELEASE
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...     file_path=${pm_counter_file}
    Verify Last Counters In File
    ...     M55124C09007   1     REDCAP_RRC_REESTAB_FALLBACK
    ...     M55124C09008   1     REDCAP_REESTAB_ACC_FALLBACK
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4
    ...     file_path=${pm_counter_file}


Make SA call with reestablishment
    [Arguments]    ${UEID}=${UEID}    ${gw_ID}=${gw_ID}
    [Documentation]    This keyword shall register UE and establish GBR and Non-GBR data calls and re-establishment
#    Start pcap collection in gNB CU     gnbTcpdump_UE ${UE_ID}
    sim log set
    Enable Internal TG   ${UEID}    1
    sim log set
    wtsrunner.ue_register   id=${UEID}
    sleep   20s
    wtsrunner.ue_pdu_session_setup    pdu=1    ue=${UEID}   nwslice=1   gw=${gw_ID}
    Sleep   20s
    sim log set
    wtsrunner.ue_rrc_reestablish        id=${UEID}       gnb=2      cell=3       cause=otherFailure
    Sleep   20s
    wtsrunner.ue_deregister         id=${UEID}       ue_deregister_type=switch_off
#	Stop pcap collection in gNB     gnbTcpdump      ${Log_Path}
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55166C00011   1     REDCAP_UE_RRC_STP_REQ
    ...     M55166C00017   1     REDCAP_UE_NRD_RRC_REESTABREQ
    ...     M55166C00012   1     REDCAP_UE_RRC_STP_SUCC
    ...     M55166C00013   1     REDCAP_UE_RRC_RELEASE
    ...     M55166C00018   1     REDCAP_UE_NRD_RRC_REESTABSUCC
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...     file_path=${pm_counter_file}