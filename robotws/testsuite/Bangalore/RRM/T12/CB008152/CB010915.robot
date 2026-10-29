*** Settings ***
Documentation   :copyright: Nokia
...             :author   : Adarsha
...             :contact  : adarsha.p_hegde@nokia.com
...             :Editor   : bhakti.ka_patel@nokia.com
...             :Note     : Along with 8152 , we have added CB010915 functionality.
...                       1) Verify changes in System Information Block (SIB) content when CB006598 is enabled first,
...                          followed by enabling CB010915.
...                       2) Validate SA Intra-gNB Inter-Frequency handover between cells configured with different bandwidths.
...                          This test case specifically verifies RedCap UE Intra-gNB handover.
Resource    resources/Keywords/CB008152_KW.robot
Suite Setup       Updated Suite Setup
Suite Teardown    Common Suite Teardown


*** Variables  ***
${CELL1}        50
${CELL2}        51
${TOPOLOGY}     CLOUD_5G_I_MP_AP_LO
${iphy}         ${CURDIR}/config/ap_iphy/MP_AP_LO_FDD_8152.xml
${scf}          ${CURDIR}/config/gnb_scf/MP_AP_LO_FDD_8152.json
${scf1}             ${CURDIR}/config/gnb_scf/Delta_for_CB010915.json
${S_sercch_TH_Q2}   nr-rrc.s_SearchThresholdQ2_r17
${filter}           (nr-rrc.s_SearchDeltaP_Stationary_r17) && (nr-rrc.t_SearchDeltaP_Stationary_r17) &&
...                 (nr-rrc.s_SearchThresholdP2_r17 ) && (nr-rrc.combineRelaxedMeasCondition2_r17)
${S_search_TH_P2}   nr-rrc.s_SearchThresholdP2_r17
${S_search_deltaP}  nr-rrc.s_SearchDeltaP_Stationary_r17
${t_search_DeltaP}  nr-rrc.t_SearchDeltaP_Stationary_r17
${combine}          nr-rrc.combineRelaxedMeasCondition2_r17


*** Test Cases ***
[1][1.0] CB010915_B_IWK1_TC08_Verify_the_GNB_behaviour_by_online_modification_of_6598_and_10915_in_different_order
    [Documentation]     The purpose of this TC is to verify Intra-gNB Inter-frequency handover of RedCap UE
	...					with different bandwidth in SA mode.
    [Tags]    QC_64561     QCD_MN_RAN    QCP_RAN_VRF
    ${Test_CaseNumber}=     Set Variable    CB010915
    Run         sudo rm -rf ${LOG_DIR}/${Test_CaseNumber}
    ${Log_Path}     Create Log Directory        ${Test_CaseNumber}
    Log to Console          \nStarting the test.....
    [Setup]    Prepare For Test Case 10915
    Start Pcap Collection In GNB CU
    Start UTE WTS      MP_AP_LO_FDD_8152.cfg
    Basic Bring Up
    Make SA call        UE_ID51=${UE1}
    Log to Console      \n Starting A2 event
    ${Meas_id_for_UE51}      Display Measurement Configuration for UE      51     A2
    Log to Console      ${Meas_id_for_UE51}
    Trigger A2 Measurement       ue_id=${UE1}      meas_id=${Meas_id_for_UE51}     phycell_id=${CELL1}
    Sleep    5s
    Log to Console      \nStarting HO based on A3 event
    ${Meas_id_for_UE51}      Display Measurement Configuration for UE      51     A3
    Log to Console      ${Meas_id_for_UE51}
    Trigger A3 Measurement       ue_id=${UE1}      meas_id=${Meas_id_for_UE51}     phycell_id=${CELL2}
    Sleep   5s
    Stop Data Traffic for SA    ${UE_ID51}
    ${pcap_file}    Stop Pcap Collection in GNB With Path    gnbTcpdump    ${Log_Path}
    Log to Console      \nPCAP file stored at ${pcap_file}
    Verify Relaxed Measurement 17 From PCAP     ${pcap_file}
    [Teardown]     Test case tear down MP AP LO
