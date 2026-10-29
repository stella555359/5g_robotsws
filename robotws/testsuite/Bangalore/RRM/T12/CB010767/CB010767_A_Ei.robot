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
${cellID}       52
${pcap_file_0}    /home/ute/logs/CB010767_A_Ei1/gnbTcpdump0/gnbTcpdump0.pcap
${pcap_file_1}    /home/ute/logs/CB010767_A_Ei1/gnbTcpdump1/gnbTcpdump1.pcap
${pcap_file_2}    /home/ute/logs/CB010767_A_Ei1/gnbTcpdump2/gnbTcpdump2.pcap
${pcap_file_2RX}    /home/ute/logs/CB009384_A_IWK3/gnbTcpdump_UE_54/gnbTcpdump_UE_54.pcap
${pcap_file_1RX}    /home/ute/logs/CB009384_A_IWK3/gnbTcpdump_UE_57/gnbTcpdump_UE_57.pcap


*** Test Cases ***
[1][1.0] CB010767_A_Ei1_4_2Verify SIB1 message is configured with 1RX not barred and 2RX not barred when cellbarred redcap = 0
    [Documentation]     This test case shall help verify SIB1 message broadcast for when Redcap feature is enabled
    ...     and cellbarring is set to 0,1,2. This implicilty verifies, Ei1_4,Ei1_5,Ei1_6 and Ei1_7 test cases.
    ...     [covering cell barring 0,1,2 and online feature enabling]
	...		Test scope also covers: CB009384_A_B1_2
    [Tags]    QC_28314   QCD_MN_RAN    QCP_RAN_VRF
    ${Test_CaseNumber}=     Set Variable    CB010767_A_Ei1
    Link SCOUT SCF to Configuration ID for Reporting
    set test variable    ${Test_status}     False
    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Log to Console      \nStarting the test\n
    Log to Console      \nFeature Not enabled yet\n
    Start pcap collection in gNB CU     gnbTcpdump_default
    Start UTE WTS      basic_setup_redcap.cfg
    sleep     30s
    Stop pcap collection in gNB     gnbTcpdump_default      ${Log_Path}
    Flush console logs
    Log to Console      Enable feature with cellbarring=0\n
    Start pcap collection in gNB CU     gnbTcpdump0
    GNB Delta commission     ${CURDIR}/config/gnb_scf/Delta_FeatureEnabled_NoCellBarring.json
    sleep     40s
    Stop pcap collection in gNB     gnbTcpdump0      ${Log_Path}
    Flush console logs
    Log to Console      \nEnable feature with cellbarring=1\n
    Start pcap collection in gNB CU     gnbTcpdump1
    Change CellBarring Online     1RX barring
    sleep     40s
    Stop pcap collection in gNB     gnbTcpdump1      ${Log_Path}
    ${Barring_status_2RX}   ${Barring_status_1RX}          Get cellBarring Status      ${pcap_file_1}      ${cellID}
    Run Keyword If    '${Barring_status_2RX}' == '1'        Log to console      \ncellBarredRedCap2Rx_r17 : notBarred\n
    Run Keyword If    '${Barring_status_1RX}' == '0'        Log to console      cellBarredRedCap1Rx_r17 : barred\n
    Flush console logs
    Log to Console      \nEnable feature with cellbarring=2\n
    Start pcap collection in gNB CU     gnbTcpdump2
    Change CellBarring Online     2RX barring
    sleep     40s
    Stop pcap collection in gNB     gnbTcpdump2      ${Log_Path}
    ${Barring_status_2RX}   ${Barring_status_1RX}          Get cellBarring Status      ${pcap_file_2}      ${cellID}
    Run Keyword If    '${Barring_status_2RX}' == '0'        Log to console      \ncellBarredRedCap2Rx_r17 : barred\n
    Run Keyword If    '${Barring_status_1RX}' == '1'        Log to console      cellBarredRedCap1Rx_r17 : notBarred\n
    [Teardown]     Run Keywords    GNB Delta commission    ${CURDIR}/config/gnb_scf/Delta_FeatureEnabled_NoCellBarring_reverse.json
    ...      AND    RAT Block Unblock


[1][1.0] CB010767_A_Ei2_9_1Verify 1RX redcap UE call is successful with 16DRB - 20MHz.
    [Documentation]     This test case shall help verify UE calls for 1Rx, 2Rx and non-Redcap UE when feature is enabled and disabled
    ...         it covers all scenarios : 1RX redcap UE call is successful with 16DRB, 1RX redcap UE call is successful with 8DRB,
    ...         1 RX UE supports PDCP/RLC SN lengths of 12 and 18 bits
    [Tags]    QC_28307   QCD_MN_RAN    QCP_RAN_VRF
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
     [Teardown]     Run Keywords    GNB Delta commission    ${CURDIR}/config/gnb_scf/Delta_FeatureEnabled_NoCellBarring_reverse.json
    ...      AND    RAT Block Unblock


[1][1.0] CB010767_A_Ei4_16_5GC000784 - Verify successful setup of Emergency call for 1Rx Redcap UE1
    [Documentation]     This test case shall help verify RedCap UE functionality when emergency call is enabled.
    ...     Test scope also covers CB009384_A_IWK3_14.robot
    [Tags]    QC_28317   QCD_MN_RAN    QCP_RAN_VRF
    ${Test_CaseNumber}=     Set Variable    CB009384_A_IWK3
    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Log to Console      Starting the test
	[Setup]      Run Keywords     Create Basic Interface on UTE
    ...     AND     Link SCOUT SCF to Configuration ID for Reporting
    ...     AND     GNB Delta commission     ${CURDIR}/config/gnb_scf/Delta_Configuration_scf_EnableEmergency.json
	...     AND     GNB Delta commission     ${CURDIR}/config/gnb_scf/Delta_FeatureEnabled_NoCellBarring.json
#    ...     AND     GNB Reboot
#    ...     AND     Sleep   360s
    ...     AND     Wait Coam Site to be Ready
    ...     AND     Start UTE WTS      basic_setup_redcap.cfg

    Basic Bring up
    Log to console      \n==============(CB009384)2RX Redcap UE Testing ===============\n
    Make a emergency call   54      54
    ${Emergency_call_status}    ${Redcap_status}    Verify emergency call   ${pcap_file_2RX}
    Run Keyword If    '${Emergency_call_status}' == '0' and '${Redcap_status}'=='0'
    ...        Log to console      \nEmergency Call Successful for 2RX Redcap UE\n
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55138C00057   1     PEAK_OF_SA_RRC_REDCAP_CU
    ...     M55138C00061   0     PEAK_OF_SA_RRC_REDCAP_1RX_CU
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...     file_path=${pm_counter_file}

    Wait For Next Full Pm Interval
    Log to console      \n================== (CB010767)1RX Redcap UE Testing ==================\n
    Make a emergency call   57      57
    ${Emergency_call_status}    ${Redcap_status}    Verify emergency call   ${pcap_file_1RX}
    Run Keyword If    '${Emergency_call_status}' == '0' and '${Redcap_status}'=='0'
    ...        Log to console      \nEmergency Call Successful for 1RX Redcap UE\n
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55138C00057   2     PEAK_OF_SA_RRC_REDCAP_CU
    ...     M55138C00061   1     PEAK_OF_SA_RRC_REDCAP_1RX_CU
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...     file_path=${pm_counter_file}
	Delete Basic Interface on UTE
	[Teardown]  Run Keywords    GNB Delta commission    ${CURDIR}/config/gnb_scf/Delta_FeatureEnabled_NoCellBarring_reverse.json
    ...    AND    GNB Delta commission    ${CURDIR}/config/gnb_scf/Delta_Configuration_scf_EnableEmergency_reverse.json
    ...    AND    RAT Block Unblock


*** Keywords ***
Make a emergency call
    [Arguments]     ${UE_ID}=${UE_ID}    ${gw_ID}=${gw_ID}
    Start pcap collection in gNB CU     gnbTcpdump_UE_${UE_ID}
    Flush console logs
    Enable Internal TG   ${UE_ID}    1
    Enable Internal TG   ${UE_ID}    2
    Enable Internal TG   ${UE_ID}    3
    Enable Internal TG   ${UE_ID}    4
    Flush console logs
    wtsrunner.ue_param     id=${UE_ID}    nr_usage_setting=voice_centric
    wtsrunner.amf_param    id=1    ims_voice_3gpp=On
    wtsrunner.ue_nr_rrc_setup_param     id=${UEID}       establishment_cause=emergency
    wtsrunner.qosflow_modify       qos_flow=1      priority=5
    wtsrunner.qosflow_modify       qos_flow=2       priority=5

    wtsrunner.ue_register   id=${UE_ID}
    sleep   20s
    wtsrunner.ue_im_exit       id=${UE_ID}     by=ue       service_type=emergency_services

    wtsrunner.smf_param     additional_qosflows_to_activate=1,2       id=1
    wtsrunner.ue_pdu_session_setup    pdu=1    ue=${UE_ID}   nwslice=1   gw=${gw_ID}
    Sleep   30s
    Flush console logs

    wtsrunner.smf_param     additional_qosflows_to_activate=1,2       id=1
    wtsrunner.ue_pdu_session_setup    pdu=2    ue=${UE_ID}   nwslice=1   gw=${gw_ID}
    Sleep   30s
    Flush console logs

    wtsrunner.smf_param     additional_qosflows_to_activate=1,2       id=1
    wtsrunner.ue_pdu_session_setup    pdu=3    ue=${UE_ID}   nwslice=1   gw=${gw_ID}
    Sleep    30s
    Flush console logs
    wtsrunner.smf_param     additional_qosflows_to_activate=4,5,6       id=1
    wtsrunner.ue_pdu_session_setup    pdu=4    ue=${UE_ID}   nwslice=1   gw=${gw_ID}
    Sleep    30s
    Flush console logs
#    UE Deregister should be Successful for SA
    Sleep   30s
    Stop pcap collection in gNB     gnbTcpdump_UE_${UE_ID}      ${Log_Path}

Verify emergency call
    [Arguments]          ${pcap_file}
    ${Emergency_call_stat}          Get Fields from Pcap     ${pcap_file}
        ...     (ngap.procedureCode == 15)         ngap.RRCEstablishmentCause
    ${Redcap_stat}          Get Fields from Pcap     ${pcap_file}
        ...     (ngap.procedureCode == 15)         ngap.RedCapIndication
    [Return]             ${Emergency_call_stat}    ${Redcap_stat}

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
