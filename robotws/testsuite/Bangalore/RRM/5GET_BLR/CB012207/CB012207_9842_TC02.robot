*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO    OPTION_RELATED_ARTIFACTS_5G   SA+NSA_FS_ECPRI_MMWV_TDD
...             SBTS00   CONFIGURED   5G_RAN   RAN_5G   CRT

Documentation   :copyright: Nokia
...              :author: Shekhar
...              :contact: shekhar.vijay_barewar@nokia.com
...              This feature CB012207 extends FR2 Standalone operation mode with basic
...              mobility and measurement package up to 23R4 release including intra-frequency mobility
...              (Xn and Ng), Xn related features like Xn mesh, ANR, additional DRMS support,
...              positioning and tracing
...              This Sceanrio deals with ECID NR-TADV reporting CB009842(requirement 5G_RAN_USR_RRM_24792)
...              and CB008281(requirement 5G_RAN_USR_RRM_26125) multiimpact FR2 with requirements

Resource        CB012207_resource.robot


Suite Setup      Run keywords    Run Keyword and Ignore Error   Suite setup from scratch
...              AND    Perform SCF Delta Commissioning with DELTA_Config_12207.json
...              AND    Configure eth3 IP
...              AND    Load CFG and verify cell status   ${wts_cfg_file}    1    2

Test Teardown    Run Keywords   Run Keyword and Ignore Error    Get Snapshot
...              AND     Run Keyword and Ignore Error    Get Sos Report
...              AND     Link SCOUT SCF to Configuration ID for Reporting


*** Variable ***
${wts_cfg_file}    ${CURDIR}/config/basic_setup_12207.cfg
&{WTS}         Ip=127.0.0.1        Username=ute        Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${start_UE}    1
${end_UE}      3
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}    1
${QFI_ID}    1
${TRF_ID}    1
${Trf_rate_SA}  kbps
${DL_RATE}   2
${UL_RATE}   2
${start_DL_trfids}  1
${end_DL_trfids}    1
${EMPTY_VAR}
${delay_attach_1UE1}    5
${delay_attach_2UE2}    10
${delay_attach_3UE3}    20
${delay_RRCReestablishment_1UE1}    15
${delay_RRCReestablishment_2UE2}    22
${delay_RRCReestablishment_3UE3}    26
${SCFC}=    ${CURDIR}/config/SCF_iphy/12207_scf.xml
${AP_XML}=  ${CURDIR}/config/SCF_iphy/12207_iphy.xml


*** Test Cases ***
[1][1.0] CB012207_9842_TC02_MultiUEs_E-CID_Meas_Reporting_diff_delay_connected_state_multi_meas_req_with_diff_meas_quantity_each_UE_robust_TDD_FR2_SA
    [Documentation]   MultipleUEs with diff p intial delay in connected state measurment request with differnet measurement
    ...  quantity each UE robustness TDD FR2 SA
    ...   Brief Steps
    ...   1) giving delay to get diff intialTAs(l1&l2) before
    ...   2) Registring 3 Ues
    ...   3) greping  intialTAs for 3 Ues  and formulating it acc to get NTA index saving in list1
    ...   4) Send LMF ECID request on nrppa  for three 3 Ues for NRTADV,RSRP, RSRQ and save response NR-TADV in list2
    ...   5) list1 should be eqaul to list2
    ...   6) Counters should Peg
    ...   7) Do restablishment to get a new TA values
    ...   8) Repeat Step1-7

    Set Test Variable    ${LOG_PATH}
    Trigger Different delay simulation to get different InitialTAs for diff UEs before Attach    ${delay_attach_1UE1}    ${delay_attach_2UE2}
    ...    ${delay_attach_3UE3}
    Start Log    btslog    biptaf
    Multiple UEs SA L3 call should be successful    ${start_UE}    ${end_UE}    ${DL_RATE}    ${UL_RATE}
    ${intialTA_during_Registration}    stop log    btslog    biptaf    test_scenario=intialTA_during_Registration
    set test variable      ${intialTA_during_Registration}
    ${NTA_index_list_values_during_Registration}    Grep initialTA value and calculate NTA index    ${intialTA_during_Registration}
    ${nrtadv_list_after_Registration}
    ...  LMF MultiUE E-CID meas initiation req for RSRP_RSRQ_NR-TADV and Verify in E-CIDgNB res and create allUE NR-TADV list after Registration
    ...  ${start_UE}  ${end_UE}
    Calculated NTA Index from InitialTA should be equal TADV reported in NRppa    ${NTA_index_list_values_during_Registration}
    ...    ${nrtadv_list_after_Registration}
    Validate Counters after Registration and before RRCRestablishment of UEs
    Trigger Different delay simulation to get different InitialTAs for diff UEs before RRCReestablishment    ${delay_RRCReestablishment_1UE1}
    ...    ${delay_RRCReestablishment_2UE2}    ${delay_RRCReestablishment_3UE3}
    Start Log    btslog    biptaf
    MultiUE Reestablishment should be successful    ${start_UE}   ${end_UE}
    ${intialTA_during_RRCReestablishment}    stop log    btslog    biptaf    test_scenario=intialTA_during_RRCRestablishment
    set test variable      ${intialTA_during_RRCReestablishment}
    ${NTA_index_list_values_during_RRCReestablishment}    Grep initialTA value and calculate NTA index    ${intialTA_during_RRCReestablishment}
    ${nrtadv_list_after_RRCReestablishment}
    ...  LMF MultiUE E-CID meas initiation req for RSRP_RSRQ_NR-TADV and Verify in E-CIDgNB res and create allUE NR-TADV list after Restablishment
    ...  ${start_UE}  ${end_UE}
    Calculated NTA Index from InitialTA should be equal TADV reported in NRppa    ${NTA_index_list_values_during_RRCReestablishment}
    ...  ${nrtadv_list_after_RRCReestablishment}
    Validate Counters after RRCRestablishment of UEs

