*** Settings ***

Documentation
...  author:  Krzysztof Michalski, Jakub Bąk
...  contact: jakub.1.bak@nokia.com, krzysztof.michalski@nokia.com

Library      testsuite/Krakow/resources/UUF/get_uuf_builds.py
Library      testsuite/Krakow/resources/UUF/upgrade_and_commission_bts.py
Library      taf/rfrl/csv4all/CSV4AllTestCases.py
Library      testsuite/Krakow/RRM/RAN_PZ/regression/KRK6/FR_CB007219/resources/qc_ids.py

Resource    taf/rfrl/uuf4all/uuf4all_keywords.robot
Resource    testsuite/Krakow/RRM/RAN_PZ/regression/KRK6/FR_CB007219/resources/suite_specific_keywords.robot
Resource    testsuite/Krakow/RRM/RAN_PZ/regression/KRK6/FR_CB007219/resources/fr2_specific_keywords.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Test Timeout    100h

Suite Setup     Suite Setup
Test Setup      Common Preconditions

*** Variables ***
${band_n257}   1
${band_n258}   2
${band_n261}   16

###UUF variables###

${ITERATION_SITE_RESET}                    50
${ITERATION_SW_UPGRADE_ROLLBACK}           5

${SOURCE_SW}                               ${EMPTY}
${TARGET_SW}                               ${EMPTY}

${SITE_RESET_TEST_QC_ID}                   191653
${SW_UPGRADE_ROLLBACK_TEST_QC_ID}          191648

@{CRITICAL_ALARMS}                         0010  0016  1806  1868  4341  4352  4383
${SERIAL_CONSOLE}                          ${False}

${REPORT}                                  ${True}
${QC_REPORT}                               ${True}
${STOP_TEST_AFTER_FAIL}                    ${False}

@{CUSTOMERS}                               TMO US
${QC_DOMAIN}                               MN_RAN
${QC_PROJECT}                              RAN_VRF
${RP_LOCATION}                             VRF_KRK
${RP_ORGANIZATION}                         VRF_KRK_T06
${RP_CA}                                   VRF_RRM

&{GNB}                                     node_alias=1SK070
...                                        testline_object=${tl.gnbs[0]}
...                                        source_sw=${SOURCE_SW}
...                                        target_sw=${TARGET_SW}
...                                        critical_alarms=${CRITICAL_ALARMS}
@{NODES}                                   ${GNB}

*** Test Cases ***

CB007219-CB_B1_de-activation_of_FR2_CA
    [TAGS]    ${CB_B1_CA_QC_TAG}
    [Setup]       FR2 NSA Test Setup   scf_prefix_tag=BC_B1    dec_band_value=${band_n258}
    Check CA with MFBI    pcell_id=51  scell_ids=None  scell_freqBands=None  pcell_freqBand=258
    Check If actMfbiNrCaSupportFr2 Change To NSA Not Impact Already Attached UE
    Check CA with MFBI    pcell_id=51
    ...                   scell_ids=52,53,54,55,56,57,58
    ...                   scell_freqBands=258,258,258,258,258,258,258
    ...                   pcell_freqBand=258
    Check If actMfbiNrCaSupportFr2 Change To none Not Impact Already Attached UE
    Check CA with MFBI    pcell_id=51  scell_ids=None  scell_freqBands=None  pcell_freqBand=258
    [Teardown]    FR2 NSA Test Teardown


CB007219-CB_B3.2_CA_configuration
    [TAGS]    ${CB_B3.2_CA_QC_TAG}
    [Setup]       FR2 NSA Test Setup   scf_prefix_tag=BC_B3    dec_band_value=${band_n261}
    Check CA with MFBI    pcell_id=51
    ...                   scell_ids=52,53,54,55,56,57,58
    ...                   scell_freqBands=261,261,261,261,261,261
    ...                   pcell_freqBand=261
    Start DL and UL data transmission for specified time
    ...    tput_dl_min=3300 Mbits/sec
    ...    tput_ul_min=300 Mbits/sec
    [Teardown]    FR2 NSA Test Teardown


CB007219-CB_B5_CA_configuration
    [TAGS]    ${CB_B5_CA_QC_TAG}
    [Setup]       FR2 NSA Test Setup   scf_prefix_tag=BC_B5    dec_band_value=${band_n257}
    Check CA with MFBI    pcell_id=51
    ...                   scell_ids=52,53,54,55,56,57,58
    ...                   scell_freqBands=257,257,257,257,257,257,257
    ...                   pcell_freqBand=257
    Attach UE
    Wait For Next PM measurements period
    Check SCELL_CONFG_ALT_BAND_NSA counters incremented
    Check SCELL_CONFG_ALT_BAND_SA counters not incremented
    Detach UE
    Start DL and UL data transmission for specified time
    ...    tput_dl_min=3300 Mbits/sec
    ...    tput_ul_min=300 Mbits/sec
    [Teardown]    FR2 NSA Test Teardown

E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    [Setup]    Test_Setup_E2E_TL_SW_upgrade_rollback
    e2e_tl_sw_upgrade_rollback_with_oam_kpi
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    iterations_per_node=${ITERATION_SW_UPGRADE_ROLLBACK}
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${SW_UPGRADE_ROLLBACK_TEST_QC_ID}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    [Teardown]    Test Teardown

E2E_TL_Activation_Reset_with_OAM_KPI
    e2e_tl_activation_reset_test
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    iterations_per_node=${ITERATION_SITE_RESET}
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${SITE_RESET_TEST_QC_ID}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    [Teardown]    Test Teardown

EDA_PR814200_intra_eNB_intra_freq_HO_without_PSCell_no_configured_Scells_and_added_mfbi
    [Setup]       FR2 NSA Test Setup   scf_prefix_tag=BC_B5_EDA    dec_band_value=${band_n257}
    Lock Cell
    Check CA with MFBI    pcell_id=51
    ...                   scell_ids=52,53,54,55,56,57,58
    ...                   scell_freqBands=257,257,257,257,257,257,257
    ...                   pcell_freqBand=257
    Start DL and UL data transmission for specified time
    ...    tput_dl_min=3300 Mbits/sec
    ...    tput_ul_min=200 Mbits/sec
    Check CA with MFBI without detach    pcell_id=51  scell_ids=None  scell_freqBands=None  pcell_freqBand=257
    [Teardown]    FR2 NSA Test Teardown
