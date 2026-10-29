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
${SITE_RESET_TEST_ITERATION}         20
${RU_RESET_TEST_ITERATION}           20
${BBMOD_TEST_ITERATION}              20
${CELL_LOCK_TEST_ITERATION}          3
${COMMISSIONING_TEST_ITERATION}      1

${REPORT}                     ${False}
${REPORT_COMMENT}=            ${None}
@{CUSTOMERS_LIST}             Optus
${QC_DOMAIN}=                 MN_RAN
${QC_PROJECT}=                RAN_VRF
${RP_CA}                      VRF_SiSo
${RP_LOCATION}                VRF_HAZ1
${RP_ORGANIZATION}            VRF_HAZ1_T05

${INITIAL_SW}                 SBTS24R3_ENB_0000_000912_000019
${TARGET_SW}                  SBTS00_ENB_9999_241224_000017
${ITERATIONS}                 20
@{CUSTOM_ALLOWED_ALARMS_5G}         4459    4654    4655    61524    61652    61649    4298
@{CUSTOM_ALLOWED_ALARMS_BTSLOCK_5G}         7107
@{TEMPORARY_ALLOWED_FAULTS_5G}    7107
@{TEMPORARY_ALLOWED_FAULTS_BBReset_5G}
@{CUSTOM_ALLOWED_ALARMS_4G}         4654    4655    61524    61652    61649   6261    4297
@{CUSTOM_ALLOWED_ALARMS_BTSLOCK_4G}
@{TEMPORARY_ALLOWED_FAULTS_4G}      4385
@{TEMPORARY_ALLOWED_FAULTS_SiteReset_4G}      4385
@{TEMPORARY_ALLOWED_FAULTS_RuReset_4G}
@{TEMPORARY_ALLOWED_FAULTS_CellLock_4G}
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



*** Test Cases ***
Load_Initial_SW
    [Timeout]   3h
    coam_csv4all.Setup admin    bts_host=192.168.255.129    bts_port=443    use_ssl=True    alias=get_init_sw_5G
    #coam_csv4all.Setup admin    bts_host=192.168.255.129    bts_port=443    use_ssl=True    remote_host={tl.test_pcs[1].addr}    alias=get_init_sw_4G
    coam_csv4all.Setup admin    bts_host=192.168.255.129    bts_port=443    use_ssl=True    remote_host=10.68.181.103    alias=get_init_sw_4G
    ${INIT_5G}      coam_csv4all.get_sw_version      connection=get_init_sw_5G
    ${INIT_4G}      coam_csv4all.get_sw_version      connection=get_init_sw_4G
    ${result1}      Run Keyword And Ignore Error    should contain    ${INIT_5G}    999
    ${result2}      Run Keyword And Ignore Error    should contain    ${INIT_4G}    999
    Run Keyword If    '${result1[0]}'=='PASS'    Set Test Variable      ${INIT_5G}    SBTS00_${INIT_5G[9:]}
    Run Keyword If    '${result2[0]}'=='PASS'    Set Test Variable      ${INIT_4G}    SBTS00_${INIT_4G[9:]}
    Run Keyword If       "${INIT_5G}"=="${INITIAL_SW}" and "${INIT_4G}"=="${INITIAL_SW}"   Pass Execution    TestCase skipped
    Run Keyword If       "${INIT_5G}"!="${INITIAL_SW}"    coam_csv4all.rollback_software        alias=get_init_sw_5G
    Run Keyword If       "${INIT_4G}"!="${INITIAL_SW}"    coam_csv4all.rollback_software        alias=get_init_sw_4G
    sleep    720s
    [Teardown]    Run Keywords    coam_csv4all.teardown admin    alias=get_init_sw_5G
    ...    AND    coam_csv4all.teardown admin    alias=get_init_sw_4G


E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Timeout]   24h
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODES}
    ...		 iterations_per_node=${UPGRADE_TEST_ITERATION}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report=${REPORT}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_project=${QC_PROJECT}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=72575

E2E_TL_Activation_Reset_with_OAM_KPI
    [Timeout]   24h
    [Tags]    QC_72571   QCD_MN_RAN   QCP_RAN_VRF
    E2E TL ACTIVATION RESET TEST
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODES}
    ...		     iterations_per_node=${SITE_RESET_TEST_ITERATION}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report=${REPORT}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_project=${QC_PROJECT}
    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=72583

E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
    [Timeout]   24h
    E2E TL SITE RESET WITHOUT HWF WITH OAM KPI
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODES}
    ...		 iterations_per_node=${SITE_RESET_TEST_ITERATION}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report=${REPORT}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_project=${QC_PROJECT}
    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=72571

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
#   ...           qc_id=860341
   ...           qc_project=${QC_PROJECT}

#QC_ID 24R3
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
#   ...          qc_id=860064


E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Timeout]   24h
    E2E TL CELL LOCK UNLOCK NR WITH OAM KPI
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODES}
    ...		     iterations_per_node=${CELL_LOCK_TEST_ITERATION}
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
    ...		     iterations_per_node=${CELL_LOCK_TEST_ITERATION}
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
    ...		     iterations_per_node=${COMMISSIONING_TEST_ITERATION}
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
    ...		     iterations_per_node=${COMMISSIONING_TEST_ITERATION}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report=${REPORT}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_project=${QC_PROJECT}
    ...          qc_domain=${QC_DOMAIN}
#   ...           qc_id=35810
   ...           qc_project=${QC_PROJECT}

E2E_TL_BTS_Block_Unblock
    [Timeout]   24h
    E2E TL BTS BLOCK UNBLOCK
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODES}
    ...		     iterations_per_node=${ITERATIONS}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_project=${QC_PROJECT}
    ...          qc_domain=${QC_DOMAIN}
#   ...          qc_id=559185

#QC_ID 23R3
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
    ...          qc_id=808976

#E2E_TL_RU_Power_Reset
#    [Timeout]   24h
#    E2E TL RU POWER RESET
#    ...          nodes_details=${NODES}
#    ...          test_nodes_details=${NODES}
#    ...		     iterations_per_node=${ITERATIONS}
#    ...          customers_list=${CUSTOMERS_LIST}
#    ...          report_comment=${REPORT_COMMENT}
#    ...          qc_project=${QC_PROJECT}
#    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=808976

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
    ...          qc_id=808976
