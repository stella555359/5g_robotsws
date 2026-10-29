*** Settings ***
Documentation
...   author: Michal Halucha
...   contact: michal.halucha@nokia.com

Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/CB008717/resources/test_specific_keywords_CB008717.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/testline_preparation/testline_preparation.robot

Force Tags      CA_VRF_WRO2
Suite Setup    Workaround commissioning    /home/ute/.ute-ca/executions/1/configs/topology_configs/node_2/node2.xml
Test Teardown    Test Teardown

*** Test Cases ***
CB008717_5G_H_B1_Successful_Configuration_of_A4_measurement_for_NR-DC_PSCell_addition_non_optimized
    [Setup]    Test Setup    ${H_B1}
    Successful PSCELL addition with A4 configured and NR-DC activated

CB008717_5G_H_B3_B4_Supverisiontimer_and_retrytimer_expiration
    [Setup]  Test Setup    ${H_B2_3}
    Supervision and Retry timer verification NRDC_on A4_configured

CB008717_5G_I_B2_More_than_one_NR-DC_PSCell_candidate_cell_reported_in_A4_measurementReport_best_reported_NR_DC_SN
    [Setup]  Test Setup    ${I_B2}
    More than one NR-DC PSCell candidate best reported cell from Idle

CB008717_EA_B2_NRDC_PSCell_Addition_by_A4_measurement_after_Resume_procedure
    [Setup]  Test Setup    ${EA}
    NRDC PSCell Addition by A4 measurement after Resume procedure

CB008717-M_B2a_TC01_Successful_NR-DC_PSCell_Addition_after_intra-gNB_intra-freq_handover
    [Setup]  Test Setup    ${H_B1}
    Successful NR-DC PSCell Addition after intra-gNB inter-freq handover

CB008717-M_B4_TC02_Not_configure_a4_event_due_to_lack_of_a4MeasNrDcEnabled_after_inter-gNB_handover_via_XN_Link
    [Setup]  Test Setup    ${H_B1}
    Not configure a4 event for NRDC PSCell addition due to lack of a4MeasNrDcEnabled configuration

CB008717-M_B5_TC03_Not_configure_a4_event_for_NR-DC_PSCell_Addition_for_not_FWA_UE_after_inter-gNB_handover_via_Xn_Link
    [Setup]  Test Setup    ${H_B1}
    Not configure a4 event for NR-DC PSCell Addition for not FWA UE after inter-gNB handover

CB008717-M_B7_TC04_Successful_NR-DC_PSCell_Addition_after_inter-gNB_HO_via_NG_Link_with_insufficient_UE_Capabilities
    [Setup]  Test Setup    ${H_B1}
    Successful NR-DC PSCell Addition after inter-gNB HO via NG Link with insufficient UE Capabilities

CB008717-M_B8_TC05_Successful_NR-DC_PSCell_Addition_after_inter-RAT_HO_with_sufficient_UE_Capabilities
    [Setup]  Test Setup    ${H_B1}
    Successful NR-DC PSCell Addition after inter-RAT HO with sufficient UE Capabilities

CB008717-HA_B2_TC01_Start_A4_retryTimer_after_inter-gNB_HO_via_NG_with_NR-DC_ineligible_PDU_Session
    [Setup]  Test Setup    ${HA}
    Start A4 retryTimer after inter gNB HO via NG with NRDC ineligible PDU Session
