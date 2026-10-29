*** Settings ***
Documentation
...                 author: Michal Kornacki
...                 contact: michal.kornacki@nokia.com
...                 Test suite for basic CSV4ALL Tests in loop:

Library             taf/rfrl/csv4all/CSV4AllTestCases.py


*** Variables ***
${QC_DOMAIN}=               MN_RAN
${QC_PROJECT}=              RAN_ST
#${COLLECT_SNAPSHOT_FLAG}    always     # possible values: failed_verdict / always
@{CUSTOMERS_LIST}=          TPG Telecom
${INITIAL_SW}               SBTS24R3_ENB_0000_000529_000000
${TARGET_SW}                SBTS24R3_ENB_0000_000540_000000
${ITERATIONS}               ${None}
&{NODE1}                    testline_object=${tl.enbs[0]}
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=6327 6322 4681 1838 7300 4655 7319 62003
@{NODES}                    ${NODE1}
${ONLINE_PARAMETER_DELTA}=      ${CURDIR}/delta_files/delta_online_parameter.json
${SITE_RESET_DELTA}=            ${CURDIR}/delta_files/site_reset_parameter.json
${NR_RAT_RESET_DELTA}=          ${CURDIR}/delta_files/delta_nr_rat_reset.json
${LTE_RAT_RESET_DELTA}=         ${CURDIR}/delta_files/delta_lte_rat_reset.json


*** Test Cases ***
E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
    [Timeout]   24h
    E2E TL SITE RESET WITHOUT HWF WITH OAM KPI    ${NODES}    ${NODE1}
    ...         iterations_per_node=8
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${859689}      #NPI


E2E_TL_RU_Reset_with_OAM_KPI
    [Timeout]   24h
    E2E TL RU RESET WITH OAM KPI    ${NODES}    ${NODE1}
    ...         iterations_per_node=5
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${859688}      #NPI

E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Timeout]   24h
    E2E TL CAPACITY MODULE RESET WITH OAM KPI    ${NODES}    ${NODE1}
    ...         iterations_per_node=5
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${859679}      #NPI
#
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Timeout]   24h
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI    ${NODES}  ${NODE1}
    ...         iterations_per_node=2
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${859691}      #NPI
    ...         restore_to_target_sw=${False}


E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Timeout]   24h
    E2E TL CELL LOCK UNLOCK NR WITH OAM KPI    ${NODES}  ${NODE1}
    ...         iterations_per_node=8
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${859683}      #NPI


E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI
    [Timeout]   24h
    E2E TL CELL LOCK UNLOCK LTE WITH OAM KPI    ${NODES}  ${NODE1}
    ...         iterations_per_node=8
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${859682}      #NPI


E2E_TL_Cell_Block_Unblock_LTE_with_OAM_KPI
    [Timeout]   24h
    E2E TL CELL BLOCK UNBLOCK LTE WITH OAM KPI    ${NODES}  ${NODE1}
    ...         iterations_per_node=8
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${859680}      #NPI

E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
    [Timeout]   24h
    E2E TL CELL BLOCK UNBLOCK NR WITH OAM KPI    ${NODES}  ${NODE1}
    ...         iterations_per_node=8
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${859681}      #NPI

E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Timeout]   24h
    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION    ${NODES}  ${NODE1}
    ...         delta=${ONLINE_PARAMETER_DELTA}
    ...         iterations_per_node=8
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${859686}      #NPI

E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Timeout]   24h
    E2E TL DELTA COMMISSIONING WITH SITE RESET REQUIRED    ${NODES}  ${NODE1}
    ...         delta=${SITE_RESET_DELTA}
    ...         iterations_per_node=3
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${859687}      #NPI

E2E_TL_Delta_Commissioning_With_LTE_Rat_Reset
    [Timeout]   24h
    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION    ${NODES}  ${NODE1}
    ...         delta=${LTE_RAT_RESET_DELTA}
    ...         iterations_per_node=5
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${859684}      #NPI
#
E2E_TL_Delta_Commissioning_With_NR_Rat_Reset
    [Timeout]   24h
    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION    ${NODES}  ${NODE1}
    ...         delta=${NR_RAT_RESET_DELTA}
    ...         iterations_per_node=5
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${859685}      #NPI
