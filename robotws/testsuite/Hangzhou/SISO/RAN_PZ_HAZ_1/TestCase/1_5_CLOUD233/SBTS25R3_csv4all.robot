*** Settings ***
Documentation    Suite description
...    Author:    Lisa Ding
...    Maintainer:    Lisa Ding

Library     Collections
Library     taf/rfrl/csv4all/CSV4AllTestCases.py
Library     taf.sbts.oam.coam.admin    WITH NAME    coam_csv4all


*** Variables ***
&{5G_BTS11193}=        HW_ID=CB007605        site_mode=SA+NSA        ONAIR_TIME=30 min
...      peak_rate_config={"45":[1,1],"46":[1,1],"47":[1,1]}

${EMAIL_RECIPIENTS}           lisa.ding@nokia-sbell.com

${UPGRADE_TEST_ITERATION}            3
${SITE_RESET_TEST_ITERATION}         10
${RU_RESET_TEST_ITERATION}           2
${BBMOD_TEST_ITERATION}              2
${CELL_LOCK_TEST_ITERATION}          2
${COMMISSIONING_TEST_ITERATION}      2

${REPORT}                     ${True}
${REPORT_COMMENT}=            ${None}
@{CUSTOMERS_LIST}             Optus
${QC_DOMAIN}=                 MN_RAN
${QC_PROJECT}=                RAN_VRF
${RP_CA}                      VRF_SiSo
${RP_LOCATION}                VRF_HAZ
${RP_ORGANIZATION}            VRF_HAZ_T08

${INITIAL_SW}                 SBTS25R1_ENB_0000_000756_200025
${TARGET_SW}                  SBTS25R3_ENB_0000_000334_000015
#${ITERATIONS}                 2
@{CUSTOM_ALLOWED_ALARMS_5G}         4459    4654    4655    61524    61652    61649    4298
@{CUSTOM_ALLOWED_ALARMS_BTSLOCK_5G}         4459    4654    4655    61524    61652    61649    4298    7513    7511
@{TEMPORARY_ALLOWED_FAULTS_5G}      7312    7513    7107    62003    7300      7319    6134    10    16    1815    7509    7511    7513
...    7509    4592
@{TEMPORARY_ALLOWED_FAULTS_BBReset_5G}      4385    6134    10    16    1815    62003    4530    6327    4592    7511    7513    7509
@{TEMPORARY_ALLOWED_FAULTS_Celllock_5G}      4385    6134    10    16    1815    62003    4530    6327    4592    7511    7513    7509
@{CUSTOM_ALLOWED_ALARMS_4G}         4654    4655    61524    61652    61649   6261    4297
@{CUSTOM_ALLOWED_ALARMS_BTSLOCK_4G}         4654    4655    61524    61652    61649   6261    4297    6134    6129
@{TEMPORARY_ALLOWED_FAULTS_4G}      4385    6134    10    16    1815    62003    4530    6327    4592    6351    6134    6129
@{TEMPORARY_ALLOWED_FAULTS_SiteReset_4G}      4385    6134    10    16    1815    62003    4530    6327    4592    6351    6134    6129
@{TEMPORARY_ALLOWED_FAULTS_RuReset_4G}      4385    6134    10    16    1815    62003    4530    6327    4592    4773    6351    6134    6129
@{TEMPORARY_ALLOWED_FAULTS_CellLock_4G}      4385    6134    10    16    1815    62003    4530    6327    4592    4773    6351    6134    6129
${ONLINE_PARAMETER_DELTA}       ${CURDIR}${/}online_parameter.json
${SITE_RESET_DELTA}             ${CURDIR}${/}site_reset_parameter.json
${NR_RAT_RESET_DELTA}           ${CURDIR}${/}rat_reset_parameter.json


&{NODE1}           testline_object=${tl.gnbs[0]}
...                source_sw=${INITIAL_SW}
...                target_sw=${TARGET_SW}
...                temporary_allowed_alarms=${TEMPORARY_ALLOWED_FAULTS_5G}
...                custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_5G}
#...                hw_to_onair_timeout=${HW_TO_ONAIR_TIME}

&{NODE2}           testline_object=${tl.enbs[0]}
...                source_sw=${INITIAL_SW}
...                target_sw=${TARGET_SW}
...                temporary_allowed_alarms=${TEMPORARY_ALLOWED_FAULTS_4G}
...                custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_4G}
#...                hw_to_onair_timeout=${HW_TO_ONAIR_TIME}


@{NODES}           ${NODE1}    ${NODE2}
@{TEST_NODE1}      ${NODE1}

*** Test Cases ***

E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Timeout]   24h
    [Tags]    QC_204342   QCD_MN_RAN   QCP_RAN_VRF
    e2e_tl_sw_upgrade_rollback_with_oam_kpi
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODES}
    ...		     iterations_per_node=${UPGRADE_TEST_ITERATION}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report=${REPORT}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_project=${QC_PROJECT}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=204342

E2E_TL_Site_Reset_with_OAM_KPI
    [Timeout]   24h
    [Tags]    QC_217671   QCD_MN_RAN   QCP_RAN_VRF
    e2e_tl_site_reset_with_oam_kpi
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODES}
    ...		 iterations_per_node=${SITE_RESET_TEST_ITERATION}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report=${REPORT}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_project=${QC_PROJECT}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=217671

E2E_TL_RU_Reset_with_OAM_KPI
   [Timeout]   24h
   Set To Dictionary
    ...    ${NODE2}    temporary_allowed_alarms=${TEMPORARY_ALLOWED_FAULTS_RuReset_4G}
   E2E TL RU RESET WITH OAM KPI
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODE1}
    ...		     iterations_per_node=${RU_RESET_TEST_ITERATION}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report=${REPORT}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_project=${QC_PROJECT}
    ...          qc_domain=${QC_DOMAIN}
#   ...          qc_id=860055
   ...          qc_project=${QC_PROJECT}
   Set To Dictionary
    ...    ${NODE2}    temporary_allowed_alarms=${TEMPORARY_ALLOWED_FAULTS_4G}

#QC_ID 23R3
E2E_TL_Capacity_Module_Reset_with_OAM_KPI
   [Timeout]   24h
   Set To Dictionary
    ...    ${NODE2}    temporary_allowed_alarms=${TEMPORARY_ALLOWED_FAULTS_CellLock_4G}
    Set To Dictionary
    ...    ${NODE1}    temporary_allowed_alarms=${TEMPORARY_ALLOWED_FAULTS_Celllock_5G}
   E2E TL CAPACITY MODULE RESET WITH OAM KPI
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODES}
    ...		     iterations_per_node=${BBMOD_TEST_ITERATION}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report=${REPORT}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_project=${QC_PROJECT}
    ...          qc_domain=${QC_DOMAIN}
#   ...          qc_id=559185
    Set To Dictionary
    ...    ${NODE2}    temporary_allowed_alarms=${TEMPORARY_ALLOWED_FAULTS_4G}
    Set To Dictionary
    ...    ${NODE1}    temporary_allowed_alarms=${TEMPORARY_ALLOWED_FAULTS_5G}


#QC_ID 23R3
E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Timeout]   24h
    [Tags]    QC_   QCD_MN_RAN   QCP_RAN_VRF
    Set To Dictionary
    ...    ${NODE2}    temporary_allowed_alarms=${TEMPORARY_ALLOWED_FAULTS_CellLock_4G}
    Set To Dictionary
    ...    ${NODE1}    temporary_allowed_alarms=${TEMPORARY_ALLOWED_FAULTS_Celllock_5G}
    E2E TL CELL LOCK UNLOCK NR WITH OAM KPI
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODES}
    ...		     iterations_per_node=${CELL_LOCK_TEST_ITERATION}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report=${REPORT}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_project=${QC_PROJECT}
    ...          qc_domain=${QC_DOMAIN}
    Set To Dictionary
    ...    ${NODE2}    temporary_allowed_alarms=${TEMPORARY_ALLOWED_FAULTS_4G}
    Set To Dictionary
    ...    ${NODE1}    temporary_allowed_alarms=${TEMPORARY_ALLOWED_FAULTS_5G}

E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
    [Timeout]   24h
    [Tags]    QC_   QCD_MN_RAN   QCP_RAN_VRF
    Set To Dictionary
    ...    ${NODE2}    temporary_allowed_alarms=${TEMPORARY_ALLOWED_FAULTS_CellLock_4G}
    Set To Dictionary
    ...    ${NODE1}    temporary_allowed_alarms=${TEMPORARY_ALLOWED_FAULTS_Celllock_5G}
    E2E TL CELL BLOCK UNBLOCK NR WITH OAM KPI
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODES}
    ...		     iterations_per_node=${CELL_LOCK_TEST_ITERATION}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report=${REPORT}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_project=${QC_PROJECT}
    ...          qc_domain=${QC_DOMAIN}
    Set To Dictionary
    ...    ${NODE2}    temporary_allowed_alarms=${TEMPORARY_ALLOWED_FAULTS_4G}
    Set To Dictionary
    ...    ${NODE1}    temporary_allowed_alarms=${TEMPORARY_ALLOWED_FAULTS_5G}


E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Timeout]   24h
    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODES}
#    ...          delta=${ONLINE_PARAMETER_DELTA}
    ...		     iterations_per_node=${COMMISSIONING_TEST_ITERATION}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report=${REPORT}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_project=${QC_PROJECT}
    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=35810
   ...           qc_project=${QC_PROJECT}

E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Timeout]   24h
    E2E TL DELTA COMMISSIONING WITH SITE RESET REQUIRED
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODES}
#    ...          delta=${SITE_RESET_DELTA}
    ...		     iterations_per_node=${COMMISSIONING_TEST_ITERATION}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report=${REPORT}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_project=${QC_PROJECT}
    ...          qc_domain=${QC_DOMAIN}
#   ...           qc_id=35810
   ...           qc_project=${QC_PROJECT}

E2E_TL_Activation_Reset_with_OAM_KPIl
    [Timeout]   24h
    [Tags]    QC_204340   QCD_MN_RAN   QCP_RAN_VRF
    E2E TL ACTIVATION RESET TEST
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODES}
    ...		     iterations_per_node=${SITE_RESET_TEST_ITERATION}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report=${REPORT}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_project=${QC_PROJECT}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=204340