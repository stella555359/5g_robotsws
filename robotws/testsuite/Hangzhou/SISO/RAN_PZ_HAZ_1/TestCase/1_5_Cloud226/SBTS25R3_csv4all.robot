*** Settings ***
Documentation    Suite description
...    Author:    Lisa Ding
...    Maintainer:    Lisa Ding

Library            Collections
Library            taf/rfrl/csv4all/CSV4AllTestCases.py
Library            taf.sbts.oam.coam.admin    WITH NAME    coam_csv4all


*** Variables ***
&{5G_BTS11193}=        HW_ID=CB007605        site_mode=SA+NSA        ONAIR_TIME=30 min
...      peak_rate_config={"45":[1,1],"46":[1,1],"47":[1,1]}

${UPGRADE_TEST_ITERATION}            3
${SITE_RESET_TEST_ITERATION}         10
${RU_RESET_TEST_ITERATION}           3
${BBMOD_TEST_ITERATION}              3
${CELL_LOCK_TEST_ITERATION}          3
${COMMISSIONING_TEST_ITERATION}      3
${ITERATIONS}                        0

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

#rat_type: RAT name - NR, LTE, WCDMA or GSM
#reset_type: ["Soft"|"Hard"] <optional, default value is Soft>
@{RAT_TYPE}                      NR
@{RESET_TYPE}                    Hard
${RATRESET_GRACEFUL_CELL_SHUTDOWN}     False

@{CUSTOM_ALLOWED_ALARMS}         4654    4655    61524    61652    61649    61030    61074    4334
@{TEMPORARY_ALLOWED_FAULTS}      4589


&{NODE1}           testline_object=${tl.gnbs[0]}
...                source_sw=${INITIAL_SW}
...                target_sw=${TARGET_SW}
...                temporary_allowed_alarms=${TEMPORARY_ALLOWED_FAULTS}
...                custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS}
#...                hw_to_onair_timeout=${HW_TO_ONAIR_TIME}



@{NODES}           ${NODE1}

#${ONLINE_PARAMETER_DELTA}       ${CURDIR}${/}/online_parameter.json
#${SITE_RESET_DELTA}             ${CURDIR}${/}site_reset_parameter.json
#${NR_RAT_RESET_DELTA}           ${CURDIR}${/}rat_reset_parameter.json

*** Test Cases ***

E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Timeout]   24h
    [Tags]    QC_204344   QCD_MN_RAN   QCP_RAN_VRF
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODES}
    ...		 iterations_per_node=${UPGRADE_TEST_ITERATION}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report=${REPORT}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_project=${QC_PROJECT}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=204344

E2E_TL_Site_Reset_with_OAM_KPI
    [Timeout]   24h
    [Tags]    QC_217672   QCD_MN_RAN   QCP_RAN_VRF
    e2e_tl_site_reset_with_oam_kpi
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODES}
    ...		 iterations_per_node=${SITE_RESET_TEST_ITERATION}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report=${REPORT}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_project=${QC_PROJECT}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=217672


E2E_TL_RU_Reset_with_OAM_KPI
   [Timeout]   24h
   E2E TL RU RESET WITH OAM KPI
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODES}
    ...		 iterations_per_node=${ITERATIONS}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report=${REPORT}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_project=${QC_PROJECT}
    ...          qc_domain=${QC_DOMAIN}
#   ...           qc_id=860341
   ...           qc_project=${QC_PROJECT}

#QC_ID 24R3
E2E_TL_Capacity_Module_Reset_with_OAM_KPI
   [Timeout]   24h
   E2E TL CAPACITY MODULE RESET WITH OAM KPI
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODES}
    ...		     iterations_per_node=${ITERATIONS}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report=${REPORT}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_project=${QC_PROJECT}
    ...          qc_domain=${QC_DOMAIN}
#   ...          qc_id=860064


E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Timeout]   24h
    E2E TL CELL LOCK UNLOCK NR WITH OAM KPI
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODES}
    ...		     iterations_per_node=${ITERATIONS}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report=${REPORT}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_project=${QC_PROJECT}
    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=35812

E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
    [Timeout]   24h
    E2E TL CELL BLOCK UNBLOCK NR WITH OAM KPI
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODES}
    ...		     iterations_per_node=${ITERATIONS}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_project=${QC_PROJECT}
    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=808976

E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Timeout]   24h
    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODES}
#    ...          delta=${ONLINE_PARAMETER_DELTA}
    ...		     iterations_per_node=${ITERATIONS}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report=${REPORT}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_project=${QC_PROJECT}
    ...          qc_domain=${QC_DOMAIN}
#   ...           qc_id=35810
   ...           qc_project=${QC_PROJECT}


E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Timeout]   24h
    E2E TL DELTA COMMISSIONING WITH SITE RESET REQUIRED
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODES}
#    ...          delta=${NR_RAT_RESET_DELTA}
    ...		     iterations_per_node=${ITERATIONS}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report=${REPORT}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_project=${QC_PROJECT}
    ...          qc_domain=${QC_DOMAIN}
#   ...           qc_id=35810
   ...           qc_project=${QC_PROJECT}

E2E_TL_Activation_Reset_with_OAM_KPI
    [Timeout]   24h
    [Tags]    QC_204343   QCD_MN_RAN   QCP_RAN_VRF
    E2E TL ACTIVATION RESET TEST
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODES}
    ...		     iterations_per_node=${SITE_RESET_TEST_ITERATION}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report=${REPORT}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_project=${QC_PROJECT}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=204343

E2E_TL_RU_Lock_Unlock
    [Timeout]   24h
    E2E TL RU LOCK UNLOCK
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODES}
    ...		     iterations_per_node=${ITERATIONS}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_project=${QC_PROJECT}
    ...          qc_domain=${QC_DOMAIN}

E2E_TL_Capacity_Module_Lock_Unlock
    [Timeout]   24h
    E2E TL CAPACITY MODULE LOCK UNLOCK
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODES}
    ...		     iterations_per_node=${ITERATIONS}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_project=${QC_PROJECT}
    ...          qc_domain=${QC_DOMAIN}