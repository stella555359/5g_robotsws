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



${IEFR_a2meas_id}   1
${IEFR_a3meas_id}   3
${IEFR_a2meas_id_sim}   2
${gNB_id_RANSIM}   3
${gw_ID}    1
${meas id}    10
${pattern}      XnAP Link with


*** Test Cases ***
[1][1.0] CB010767_B_B1B2d_8_1Verify successful Intra frequency,IntergNB, Xn based HO for 1Rx redcap UE
    [Documentation]     Verification for IAIE Xn HO
    ...         Test scope also covers: CB008033_A_A2_9
    ...         Additional part added for coverage of PRID03883281
    [Tags]    QC_60582   QCD_MN_RAN    QCP_RAN_VRF
    ${Test_CaseNumber}=     Set Variable    CB010767_B_B1B2d
    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Log to Console      Starting the test
    [Setup]      Run Keywords     Create Basic Interface on UTE
    ...     AND     Link SCOUT SCF to Configuration ID for Reporting
    ...     AND     GNB Delta commission     ${CURDIR}/config/gnb_scf/Delta_Configuration_IAIEGNB_XN.json
    ...     AND     Sleep   20s
    ...     AND     GNB Delta commission     ${CURDIR}/config/gnb_scf/Delta_8127.json
    ...     AND     Sleep   20s
    ...     AND     GNB Delta commission     ${CURDIR}/config/gnb_scf/Delta_FeatureEnabled_NoCellBarring.json
    ...     AND     Sleep   30s
    Wait Coam Site to be Ready
    Start Pcap Collection In GNB CU     gnbTcpdump_xnsetup
    Sleep   15s
    Start UTE WTS      basic_setup_redcap_Xn.cfg
    Sleep    40s
    Stop Pcap Collection In GNB     gnbTcpdump_xnsetup      ${Log_Path}
    Log to console      \n================== (CB010767)1RX Redcap UE Testing ==================\n
    Wait For Next Full Pm Interval
    Make a SA call for GBR NonGBR bearer    ${UE_ID_Rx1}  ${gw_ID_Rx1}
    Flush console logs
    ${measID}   Display Measurement Configuration for UE    ${UE_ID_Rx1}     A3
    Sleep   10s
    Flush console logs
    Run keyword and ignore error    Trigger A3 Measurement    ${UE_ID_Rx1}    ${measID}       55
    Sleep   30s
    Flush console logs
    Run keyword and ignore error    wtsrunner.ue_deregister    id=${UE_ID_Rx1}     ue_deregister_type=switch_off
    Sleep   30s
    Flush console logs
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55138C00057   1     PEAK_OF_SA_RRC_REDCAP_CU
    ...     M55138C00061   1     PEAK_OF_SA_RRC_REDCAP_1RX_CU
    ...     M55178C00009   1     RED_CAP_IEGNB_HO_PR_ATT_SRC
    ...     M55178C00010   1     RED_CAP_IEGNB_HO_EX_ATT_SRC
    ...     M55178C00011    1     RED_CAP_IEGNB_HO_EX_SUC_SRC
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...     file_path=${pm_counter_file}
    Verify Last Counters In File
    ...     M55190C00001   1     SA_MEAS_PROFILE_SELECTED
    ...     local_moid=PLMN-PLMN/NRMASA-1
    ...     file_path=${pm_counter_file}
    Verify Last Counters In File
    ...     M55187C00001   1     IAF_MEAS_PROFILE_CONF_ATT
    ...     local_moid=PLMN-PLMN/NRMIAF-1
    ...     file_path=${pm_counter_file}
    Flush console logs
    Log to console      \n================== (CB009384) 2RX Redcap UE Testing ==================\n
    Wait For Next Full Pm Interval
    Make a SA call for GBR NonGBR bearer    ${UE_ID_Rx2}  ${gw_ID_Rx2}
    Flush console logs
    ${measID}   Display Measurement Configuration for UE    ${UE_ID_Rx2}     A3
    Sleep   10s
    Flush console logs
    Run keyword and ignore error    Trigger A3 Measurement    ${UE_ID_Rx2}    ${measID}       55
    Sleep   30s
    Flush console logs
    Run keyword and ignore error    wtsrunner.ue_deregister     id=${UE_ID_Rx2}     ue_deregister_type=switch_off
    Sleep   30s
    Flush console logs
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55138C00057   1     PEAK_OF_SA_RRC_REDCAP_CU
    ...     M55138C00061   0     PEAK_OF_SA_RRC_REDCAP_1RX_CU
    ...     M55178C00009   1     RED_CAP_IEGNB_HO_PR_ATT_SRC
    ...     M55178C00010   1     RED_CAP_IEGNB_HO_EX_ATT_SRC
    ...     M55178C00011    1     RED_CAP_IEGNB_HO_EX_SUC_SRC
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...     file_path=${pm_counter_file}
    Flush console logs
##    ${XNAP_BCAST_INFO}      Extract XnAP Bcast Information      /home/ute/logs/CB010767_B_B1B2d/gnbTcpdump_xnsetup/gnbTcpdump_xnsetup.pcap
##    Run Keyword If    '${XNAP_BCAST_INFO}' == 'c3'
##	...		Log To Console      \nXnAP supports bitmap for both Nokia and other gNB\n
    [Teardown]    Tear down for B8


[1][1.0] CB010767_B_B1B2e_9_1Verify successful Inter frequency,IntergNB, Xn based HO for 1Rx redcap UE
    [Documentation]     This test case shall help verify intergnb inter frequency HO for Redcap UE
    ...         The test scope covers:  CB009384_B_B1B2e_4 & CB008033_A_A2_8.robot
    ...         The test case covers LBT27659-A-B1-1 functionality which is trsffered from KRK to BLR.
    [Tags]    QC_60583   QCD_MN_RAN    QCP_RAN_VRF
    ${Test_CaseNumber}=     Set Variable    CB010767_B_B1B2e_9
    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    [Setup]      Run Keywords     Create Basic Interface on UTE
    ...     AND     Link SCOUT SCF to Configuration ID for Reporting
    ...     AND     Create Interface for Xn HO
    ...     AND     Run    sudo ip addr add 10.0.1.141/24 dev eth3
    ...     AND     GNB Delta commission     ${CURDIR}/config/gnb_scf/Delta_Configuration_scf_IEFXn.json
    ...     AND     GNB Delta commission     ${CURDIR}/config/gnb_scf/Delta_FeatureEnabled_NoCellBarring.json
    ...     AND     GNB Delta commission     ${CURDIR}/config/gnb_scf/Delta_8127.json
    ...     AND     Sleep   60s
    ...     AND     Wait Coam Site to be Ready
    ...     AND     Start UTE WTS      redcap_intergnb_XnHO.cfg
    sleep    30s
    Wait For Next Full Pm Interval
    Log to console      \n================== (CB010767)1RX Redcap UE Testing ==================\n
    Run keyword and ignore error    Make a SA call for GBR NonGBR bearer    ${UE_ID_Rx1}  ${gw_ID_Rx1}
    Flush console logs
    ${measID_1}   Display Measurement Configuration for UE    ${UE_ID_Rx1}     A2
    Sleep   30s
    Flush console logs
    Run keyword and ignore error    Trigger A2 Measurement      ${UE_ID_Rx1}    ${measID_1}    52
    Sleep   20s
    Flush console logs
    ${measID_a3}   Display Measurement Configuration for UE    ${UE_ID_Rx1}     A3
    Sleep   10s
    Flush console logs
    Run keyword and ignore error    Trigger A3 Measurement      ${UE_ID_Rx1}    3     55
    sleep    40s
    Flush console logs
    Run keyword and ignore error    wtsrunner.ue_deregister         id=${UE_ID_Rx1}     ue_deregister_type=switch_off
    Sleep   30s
    Flush console logs
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55138C00057   1     PEAK_OF_SA_RRC_REDCAP_CU
    ...     M55138C00061   1     PEAK_OF_SA_RRC_REDCAP_1RX_CU
    ...     M55178C00009   1     RED_CAP_IEGNB_HO_PR_ATT_SRC
    ...     M55178C00010   1     RED_CAP_IEGNB_HO_EX_ATT_SRC
    ...     M55178C00011   1     RED_CAP_IEGNB_HO_EX_SUC_SRC
    ...     M55178C00001   1     IEF_XN_HO_PR_ATT_SRC_VONR
    ...     M55178C00002   1     IEF_XN_HO_EX_ATT_SRC_VONR
    ...     M55178C00003   1     IEF_XN_HO_EX_SUC_SRC_VONR
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...     file_path=${pm_counter_file}
	Verify Last Counters In File
    ...     M55190C00001    3    SA_MEAS_PROFILE_SELECTED
    ...     local_moid=PLMN-PLMN/NRMASA-1
    ...     file_path=${pm_counter_file}
    Verify Last Counters In File
    ...     M55188C00001   1     IEF_MEAS_PROFILE_CONF_ATT
    ...     local_moid=PLMN-PLMN/NRMIEF-1
    ...     file_path=${pm_counter_file}
    Flush console logs
    Wait For Next Full Pm Interval
    Log to console      \n================== (CB009384) 2RX Redcap UE Testing ==================\n
    Run keyword and ignore error    Make a SA call for GBR NonGBR bearer    ${UE_ID_Rx2}  ${gw_ID_Rx2}
    ${measID_1}   Display Measurement Configuration for UE    ${UE_ID_Rx2}     A2
    Sleep   30s
    Flush console logs
    Run keyword and ignore error    Trigger A2 Measurement      ${UE_ID_Rx2}    ${measID_1}    52
    Sleep   20s
    Flush console logs
    ${measID_a3}   Display Measurement Configuration for UE    ${UE_ID_Rx2}     A3
    Sleep   10s
    Flush console logs
    Run keyword and ignore error    Trigger A3 Measurement      ${UE_ID_Rx2}    3     55
    sleep    40s
    Flush console logs
    Run keyword and ignore error    wtsrunner.ue_deregister         id=${UE_ID_Rx2}     ue_deregister_type=switch_off
    Sleep   30s
    Flush console logs
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55138C00057   1     PEAK_OF_SA_RRC_REDCAP_CU
    ...     M55138C00061   0     PEAK_OF_SA_RRC_REDCAP_1RX_CU
    ...     M55178C00009   1     RED_CAP_IEGNB_HO_PR_ATT_SRC
    ...     M55178C00010   1     RED_CAP_IEGNB_HO_EX_ATT_SRC
    ...     M55178C00011   1     RED_CAP_IEGNB_HO_EX_SUC_SRC
    ...     M55178C00001   1     IEF_XN_HO_PR_ATT_SRC_VONR
    ...     M55178C00002   1     IEF_XN_HO_EX_ATT_SRC_VONR
    ...     M55178C00003   1     IEF_XN_HO_EX_SUC_SRC_VONR
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...     file_path=${pm_counter_file}
    Log to Console    \n CB010767 test case execution completed
    LBT27659-A-B1-1 case
    [Teardown]    Tear down for CB010767_B_B1B2e_9


*** Keywords ***
LBT27659-A-B1-1 case
    [Documentation]    DESCRIPTION: This test scenario covers the sunny day scenario and describes the situation when
    ...  NRADJGNB-1 object is being configured with new correlated XNLINK-1. Additionally new XNLINK-2
    ...  object is being configured which is not correlated with any NRADJGNB objects. After XN SetupRequest
    ...  messages are sent for both XNLINKs to accordingly adjacent simgNB-3 and simgNB-4, successfull
    ...  establishment of both XNLINKs should be visible. In the next step new XNLINK-3 object
    ...  is being configured and after successfull link setup new NRADJGNB-3 object should be created.
    Log to Console    \n Starting of LBT27659-A-B1-1
    GNB Delta commission     ${CURDIR}/config/gnb_scf/Delta_Configuration_for_LBT27659.json
    Sleep   30s
    Wait Coam Site to be Ready
    Start UTE WTS      redcap_intergnb_XnHO.cfg
    Sleep    50s
    Log to Console    \ndropping xn link and waiting to come up
    link_drop     link=xn    by=gnb:3    to=gnb:2     msg_type=shutdown
    Check Pattern in Egate Console Log    ${pattern}
    GNB Delta commission     ${CURDIR}/config/gnb_scf/Delta_Configuration_for_LBT27659_reverse.json
    sleep    30s
