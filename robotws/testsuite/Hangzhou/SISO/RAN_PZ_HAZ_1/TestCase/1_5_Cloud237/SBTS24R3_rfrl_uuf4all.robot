*** Settings ***
Documentation    Suite description
...    Author:    Lisa Ding
...    Maintainer:    Lisa Ding

Library     taf/rfrl/csv4all/CSV4AllTestCases.py


*** Variables ***
&{5G_BTS11193}=        HW_ID=CB007605        site_mode=SA+NSA        ONAIR_TIME=30 min
...      peak_rate_config={"45":[1,1],"46":[1,1],"47":[1,1]}

${UPGRADE_TEST_ITERATION}            3
${SITE_RESET_TEST_ITERATION}         20
${RU_RESET_TEST_ITERATION}           20
${BBMOD_TEST_ITERATION}              20
${CELL_LOCK_TEST_ITERATION}          3
${COMMISSIONING_TEST_ITERATION}      1

${REPORT}                     ${True}
${REPORT_COMMENT}=            ${None}
@{CUSTOMERS_LIST}             Optus
${QC_DOMAIN}=                 MN_RAN
${QC_PROJECT}=                RAN_ST
${RP_CA}                      VRF_SiSo
${RP_LOCATION}                VRF_HAZ1
${RP_ORGANIZATION}            VRF_HAZ1_T05
${INITIAL_SW}                 SBTS24R1_FSM3_0000_000189_000000
${TARGET_SW}                  SBTS24R3_FSM3_0000_000100_000000

@{CUSTOM_ALLOWED_ALARMS_2284}         4654    4655    61524    61652    61649    4262    6261    1898    6283
@{TEMPORARY_ALLOWED_FAULTS_2284}
#4654    4655    61524    61652    61649    7312    7313    2922    61030    61074    4298    7513
@{CUSTOM_ALLOWED_ALARMS_2288}         4654    4655    61524    61652    61649    4262    6261    1898    6283
@{TEMPORARY_ALLOWED_FAULTS_2288}
@{CUSTOM_ALLOWED_ALARMS_2316}         4654    4655    61524    61652    61649    4262    6261    1898    6283
@{TEMPORARY_ALLOWED_FAULTS_2316}

${HOSTNAME}                   1_5_CLOUD237_1

${HW_TO_ONAIR_TIME}     20

&{NODE1}           testline_object=${tl.enbs[0]}
...                source_sw=${INITIAL_SW}
...                target_sw=${TARGET_SW}
...                temporary_allowed_alarms=${TEMPORARY_ALLOWED_FAULTS_2284}
...                custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_2284}
...                hw_to_onair_timeout=${HW_TO_ONAIR_TIME}

&{NODE2}           testline_object=${tl.enbs[1]}
...                source_sw=${INITIAL_SW}
...                target_sw=${TARGET_SW}
...                temporary_allowed_alarms=${TEMPORARY_ALLOWED_FAULTS_2288}
...                custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_2288}
...                hw_to_onair_timeout=${HW_TO_ONAIR_TIME}

&{NODE3}           testline_object=${tl.enbs[2]}
...                source_sw=${INITIAL_SW}
...                target_sw=${TARGET_SW}
...                temporary_allowed_alarms=${TEMPORARY_ALLOWED_FAULTS_2316}
...                custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_2316}
...                hw_to_onair_timeout=${HW_TO_ONAIR_TIME}


@{NODES}           ${NODE1}    ${NODE2}    ${NODE3}

*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Timeout]   24h
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODES}
    ...		     iterations_per_node=${UPGRADE_TEST_ITERATION}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report=${REPORT}
    ...          report_comment=${REPORT_COMMENT}
    ...          download_path=
    ...          qc_project=${QC_PROJECT}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=860037

E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
    [Timeout]   24h
    E2E TL SITE RESET WITHOUT HWF WITH OAM KPI
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODES}
    ...		     iterations_per_node=${SITE_RESET_TEST_ITERATION}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report=${REPORT}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_project=${QC_PROJECT}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=860041

E2E_TL_RU_Reset_with_OAM_KPI
   [Timeout]   24h
   E2E TL RU RESET WITH OAM KPI
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODES}
    ...		     iterations_per_node=${RU_RESET_TEST_ITERATION}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report=${REPORT}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_project=${QC_PROJECT}
    ...          qc_domain=${QC_DOMAIN}
   ...           qc_id=860055
   ...           qc_project=${QC_PROJECT}

#QC_ID 23R3
E2E_TL_Capacity_Module_Reset_with_OAM_KPI
   [Timeout]   24h
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
