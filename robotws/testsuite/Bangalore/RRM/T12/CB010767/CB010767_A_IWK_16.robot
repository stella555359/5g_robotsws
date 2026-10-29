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
${pcap_file_2RX}    /home/ute/logs/CB009384_A_IWK3/gnbTcpdump_UE_54/gnbTcpdump_UE_54.pcap
${pcap_file_1RX}    /home/ute/logs/CB009384_A_IWK3/gnbTcpdump_UE_57/gnbTcpdump_UE_57.pcap

*** Test Cases ***
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
