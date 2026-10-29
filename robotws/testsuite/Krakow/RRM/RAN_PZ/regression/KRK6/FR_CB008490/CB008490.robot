*** Settings ***
Documentation
...   author: Piotr Brzezicki piotr.brzezicki@nokia.com, Jakub Bak jakub.1.bak@nokia.com
...   maintainer: piotr.brzezicki@nokia.com

Library    testsuite.Krakow.RRM.RAN_PZ.regression.KRK6.FR_CB008490.resources.test_cases.TestCases    WITH NAME    tc
Library    testsuite.Krakow.RRM.RAN_PZ.regression.KRK6.FR_CB008490.resources.setups.Setups           WITH NAME    st
Library    testsuite.Krakow.RRM.RAN_PZ.regression.KRK6.FR_CB008490.resources.teardowns.Teardowns     WITH NAME    td

Variables    ./resources/variables/common.py

Suite Setup       st.cb008490_suite_setup
Suite Teardown    td.cb008490_suite_teardown

*** Test Cases ***
CB008490-C_101_#B1_UE_Release_due_to_AMF_initiated_Contex_Release
    [Setup]    st.cb008490_test_setup    ru=AZQO    reboot_ue=${REBOOT_UE}
    tc.cb008490_c_101_b1_ue_release_due_to_amf_initiated_context_release
    [Teardown]    td.cb008490_test_teardown

CB008490-K_101_#B1_Successful_FR2_8CC
    [Setup]    st.cb008490_test_setup    ru=APHG
    tc.cb008490_k_101_b1_successful_fr2_8cc
    [Teardown]    td.cb008490_test_teardown

CB008490-E_101_#B1_RRCReestablishment_to_same_gNB
    [Setup]    st.cb008490_test_setup    ru=AHEH
    tc.cb008490_e_101_b1_rrcreestablishment_to_same_gnb
    [Teardown]    td.cb008490_test_teardown

CB008490-EB_202_#B2A3_NG_Partial_reset-NR-DC-SN_cells_locked
    [Setup]    st.cb008490_test_setup    ru=AZQO
    tc.cb008490_eb_202_b2a3_ng_partial_reset_nr_dc_sn_cells_locked
    [Teardown]    td.cb008490_test_teardown

CB008490-EC_100#B1_NRDC_user_capacity_counters_for_release_procedure
    [Setup]    st.cb008490_test_setup    ru=AZQO
    tc.cb008490_ec_100_b1_nrdc_user_capacity_counters_for_release_procedure
    [Teardown]    td.cb008490_test_teardown

CB008490-EA_101_#B1_Offloaded_PDU_Session_Release
    [Setup]    st.cb008490_test_setup    ru=AHEH
    tc.cb008490_ea_101_b1_offloaded_pdu_session_release
    [Teardown]    td.cb008490_test_teardown

CB008490-QBW_101_#B1_Attach_3BWPs_TDD
    [Setup]    st.cb008490_test_setup    ru=AEQP
    tc.cb008490_qbw_101_b1_attach_3bwps_tdd
    [Teardown]    td.cb008490_test_teardown

CB008490-QBW_501_#B5_PWS_BWP
    [Setup]    st.cb008490_test_setup    ru=APHG
    tc.cb008490_qbw_501_b5_pws_bwp
    [Teardown]    td.cb008490_test_teardown

CB008490-DD_200#B3_UE_activity_resumption
    [Setup]    st.cb008490_test_setup    ru=AZQO
    tc.cb008490_dd_200_b3_ue_activity_resumption
    [Teardown]    td.cb008490_test_teardown

CB008490-LA_101_#B1A1_CSI-RS_capability_check_passed_in_MN_totalNumberPortsSimultaneousNZP-CSI-RS-PerCC_ge_4
    [Setup]    st.cb008490_test_setup    ue_alias=${MY_UE_ALIAS_UE2}    ru=AHEH    reboot_ue=${REBOOT_UE}
    tc.cb008490_la_101_b1a1_csi_rs_capability_check_passed_in_mn   ${MY_UE_ALIAS_UE2}
    [Teardown]    td.cb008490_test_teardown     ${MY_UE_ALIAS_UE2}

CB008490-LA_601_#B6_MN-SN_coordination_MTK_M80
    [Setup]    st.cb008490_test_setup    ue_alias=${MY_UE_ALIAS_UE2}    ru=AEQP
    tc.cb008490_la_601_b6_mn_sn_coordination_mtk_m80    ${MY_UE_ALIAS_UE2}
    [Teardown]    td.cb008490_test_teardown    ${MY_UE_ALIAS_UE2}

CB008490-LA_701_#B7A1_CSI-RS_capability_check_fail_in_MN_FR1_CA
    [Setup]    st.cb008490_test_setup   ue_alias=${MY_UE_ALIAS_UE2}    ru=AEQP
    tc.cb008490_la_701_b7a1_csi_rs_capability_check_fail_in_mn_fr1_ca    ${MY_UE_ALIAS_UE2}
    [Teardown]    td.cb008490_test_teardown    ${MY_UE_ALIAS_UE2}

CB008490-LD_101_Real_UE_pucchF2MaxCodeRate_zeroDot25_nrofReportedRS_2
    [Setup]    st.cb008490_test_setup    ru=AEQP
    tc.cb008490_ld_101_real_ue_pucchf2maxcoderate_zerodot25_nrofreportedrs_2
    [Teardown]    td.cb008490_test_teardown

CB008490-LD_201_Real_UE_pucchF2MaxCodeRate_zeroDot35_nrofReportedRS_1
    [Setup]    st.cb008490_test_setup    ru=AEQP
    tc.cb008490_ld_201_real_ue_pucchf2maxcoderate_zerodot35_nrofreportedrs_1
    [Teardown]    td.cb008490_test_teardown

CNI-125505_101_FAF_check_with_NRDC_call_actRrcReconfigAtBeamSwitch_false
    [Setup]    st.cb008490_test_setup    ru=AEQP
    tc.cni_125505_101_faf_check_with_nrdc_call_actrrcreconfigatbeamswitch_false
    [Teardown]    td.cb008490_test_teardown

CNI-125505_102_FAF_check_with_NRDC_call_actRrcReconfigAtBeamSwitch_true
    [Setup]    st.cb008490_test_setup    ru=AEQP
    tc.cni_125505_102_faf_check_with_nrdc_call_actrrcreconfigatbeamswitch_true
    [Teardown]    td.cb008490_test_teardown

CB008490-KA_101_#B1_FR2_cells_not_added_not_supported_PLMN_at_SN
    [Setup]    st.cb008490_test_setup    ru=AEQP
    tc.cb008490_ka_101_b1_fr2_cells_not_added_not_supported_plmn_at_sn
    [Teardown]    td.cb008490_test_teardown

CB008490-W-B1_101_NRDC_Single_UE_DL_Peak_Tput_MN_TDD
    [Setup]    st.cb008490_test_setup   disable_as_encryption=${False}    ru=AZQO
    tc.cb008490_w_b1_101_nrdc_single_ue_dl_peak_tput_mn_tdd
    [Teardown]     td.cb008490_test_teardown

CB008490_KPI_Benchmarking
    [Setup]    cb008490_kpi_bench_test_setup
    tc.cb008490_kpi_benchmarking
    [Teardown]    run_common_postconditions
