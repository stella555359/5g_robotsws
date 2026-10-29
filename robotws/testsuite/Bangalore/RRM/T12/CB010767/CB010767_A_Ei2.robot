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
[1][1.0] CB010767_A_Ei2_9_1Verify 1RX redcap UE call is successful with 16DRB - 20MHz.
    [Documentation]     This test case shall help verify UE calls for 1Rx, 2Rx and non-Redcap UE when feature is enabled and disabled
    ...         it covers all scenarios : 1RX redcap UE call is successful with 16DRB, 1RX redcap UE call is successful with 8DRB,
    ...         1 RX UE supports PDCP/RLC SN lengths of 12 and 18 bits
#    [Tags]    QC_28307   QCD_MN_RAN    QCP_RAN_VRF
    ${Test_CaseNumber}=     Set Variable    CB010767_A_Ei2
    Link SCOUT SCF to Configuration ID for Reporting
    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Log to Console      \nStarting the test\n
    Log to Console      \nFeature Not enabled yet\n
    Start UTE WTS      basic_setup_redcap.cfg
    sleep     30s
    Log to Console      \nMake calls
    Wait For Next Full Pm Interval
    Make SA call Successfully      51      51
    Make UE Fail      54
    Make UE Fail      57
    Wait For Next Full Pm Interval
    Log to Console      \nEnable feature with cellbarring=0\n
    Start pcap collection in gNB CU     gnbTcpdump0
    GNB Delta commission     ${CURDIR}/config/gnb_scf/Delta_FeatureEnabled_NoCellBarring.json
    sleep      80s
    Stop pcap collection in gNB     gnbTcpdump0      ${Log_Path}
    Make SA call Successfully      51      51
    Log to Console      \nMake 2RX UE calls for long and short SN\n
    Wait For Next Full Pm Interval
    Make SA call Successfully      54      54
    Make SA call Successfully      55      55
    Wait For Next Full Pm Interval
#   Counters to be added for verified
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55166C00011   2     REDCAP_UE_RRC_STP_REQ
    ...     M55166C00012   2     REDCAP_UE_RRC_STP_SUCC
    ...     M55166C00013   2     REDCAP_UE_RRC_RELEASE
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...     file_path=${pm_counter_file}
#    Verify Last Counters In File
#    ...     M55138C00057   2     PEAK_OF_SA_RRC_REDCAP_CU
#    ...     M55138C00061   0     PEAK_OF_SA_RRC_REDCAP_1RX_CU
#    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
#    ...     file_path=${pm_counter_file}
    Log to Console      \nMake 1RX UE calls for long and short SN\n
    Wait For Next Full Pm Interval
    Make SA call Successfully      57      57
    Make SA call Successfully      58      58
    Wait For Next Full Pm Interval
#   Counters to be added for verification
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55166C00011   2     REDCAP_UE_RRC_STP_REQ
    ...     M55166C00012   2     REDCAP_UE_RRC_STP_SUCC
    ...     M55166C00013   2     REDCAP_UE_RRC_RELEASE
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...     file_path=${pm_counter_file}
#    Verify Last Counters In File
#    ...     M55138C00057   2     PEAK_OF_SA_RRC_REDCAP_CU
#    ...     M55138C00061   2     PEAK_OF_SA_RRC_REDCAP_1RX_CU
#    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
#    ...     file_path=${pm_counter_file}


***Keywords***
Change CellBarring Online
    [Arguments]         ${CB_Value}
    admin.Setup admin
    Online NIDD parameter change    paramName=cellBarredRedCap            paramValue=${CB_Value}
    ...                             paramDst=MRBTS-1/NRBTS-1/NRCELL-3
    admin.Teardown admin

Make SA call Successfully
    [Arguments]    ${UEID}=${UEID}    ${gw_ID}=${gw_ID}
    [Documentation]    This keyword shall register UE and establish GBR and Non-GBR data calls
    Start pcap collection in gNB CU     gnbTcpdump_UE ${UE_ID}
    sim log set
    Enable Internal TG   ${UEID}    1
    Enable Internal TG   ${UEID}    2
    Enable Internal TG   ${UEID}    3
    Enable Internal TG   ${UEID}    4
    sim log set
    wtsrunner.ue_register   id=${UEID}
    sleep   20s
    wtsrunner.smf_param     additional_qosflows_to_activate=4,5,6       id=1
    wtsrunner.ue_pdu_session_setup    pdu=1    ue=${UEID}   nwslice=1   gw=${gw_ID}
    Sleep   20s
    sim log set
    wtsrunner.smf_param     additional_qosflows_to_activate=4,5,6       id=1
    wtsrunner.ue_pdu_session_setup    pdu=2    ue=${UEID}   nwslice=1   gw=${gw_ID}
    Sleep   20s
    sim log set
    wtsrunner.smf_param     additional_qosflows_to_activate=4,5,6       id=1
    wtsrunner.ue_pdu_session_setup    pdu=3    ue=${UEID}   nwslice=1   gw=${gw_ID}
    Sleep   20s
    sim log set
    wtsrunner.smf_param     additional_qosflows_to_activate=4,5,6       id=1
    wtsrunner.ue_pdu_session_setup    pdu=4    ue=${UEID}   nwslice=1   gw=${gw_ID}
    Sleep   20s
    sim log set
    wtsrunner.ue_deregister         id=${UEID}      ue_deregister_type=switch_off
    Sleep   20s
    Stop pcap collection in gNB     gnbTcpdump_UE ${UE_ID}      ${Log_Path}

Make UE Fail
    [Arguments]    ${UEID}=${UEID}
    Start pcap collection in gNB CU     gnbTcpdump_UEFail ${UE_ID}
    sim log set
    Enable Internal TG   ${UEID}      1
    wtsrunner.ue_register   id=${UEID}
    sleep   20s
    Stop pcap collection in gNB     gnbTcpdump_UEFail ${UE_ID}      ${Log_Path}
