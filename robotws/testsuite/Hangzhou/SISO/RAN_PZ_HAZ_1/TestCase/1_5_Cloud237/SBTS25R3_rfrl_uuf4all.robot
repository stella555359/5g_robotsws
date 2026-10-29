*** Settings ***
Documentation    Suite description
...    Author:    Lisa Ding
...    Maintainer:    Lisa Ding

Library     taf/rfrl/csv4all/CSV4AllTestCases.py
Library     taf.sbts.oam.coam.admin    WITH NAME    coam_csv4all
Force Tags      CA_VRF_HZ1

*** Variables ***
&{5G_BTS11193}=        HW_ID=CB007605        site_mode=SA+NSA        ONAIR_TIME=30 min
...      peak_rate_config={"45":[1,1],"46":[1,1],"47":[1,1]}

${UPGRADE_TEST_ITERATION}            1
${SITE_RESET_TEST_ITERATION}         1
${RU_RESET_TEST_ITERATION}           1
#${BBMOD_TEST_ITERATION}              1
${CELL_LOCK_TEST_ITERATION}          1
${COMMISSIONING_TEST_ITERATION}      1

${REPORT}                     ${True}
${REPORT_COMMENT}=            ${None}
@{CUSTOMERS_LIST}             Optus
${QC_DOMAIN}=                 MN_RAN
${QC_PROJECT}=                RAN_VRF
${RP_CA}                      VRF_SiSo
${RP_LOCATION}                VRF_HAZ
${RP_ORGANIZATION}            VRF_HAZ_T08
${INITIAL_SW}                 SBTS25R1_FSM3_0000_000161_000000
${TARGET_SW}                  SBTS25R3_FSM3_0000_000013_000000

@{CUSTOM_ALLOWED_ALARMS_2284}         4654    4655    61524    61652    61649    4262    6261    1898    6283    6284
@{TEMPORARY_ALLOWED_FAULTS_2284}
#4654    4655    61524    61652    61649    7312    7313    2922    61030    61074    4298    7513
@{CUSTOM_ALLOWED_ALARMS_2288}         4654    4655    61524    61652    61649    4262    6261    1898    6283    6284
@{TEMPORARY_ALLOWED_FAULTS_2288}
@{CUSTOM_ALLOWED_ALARMS_2316}         4654    4655    61524    61652    61649    4262    6261    1898    6283    6284
@{TEMPORARY_ALLOWED_FAULTS_2316}


#${HW_TO_ONAIR_TIME}     20

&{NODE1}           testline_object=${tl.enbs[0]}
...                source_sw=${INITIAL_SW}
...                target_sw=${TARGET_SW}
...                temporary_allowed_alarms=${TEMPORARY_ALLOWED_FAULTS_2284}
...                custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_2284}


&{NODE2}           testline_object=${tl.enbs[1]}
...                source_sw=${INITIAL_SW}
...                target_sw=${TARGET_SW}
...                temporary_allowed_alarms=${TEMPORARY_ALLOWED_FAULTS_2288}
...                custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_2288}


&{NODE3}           testline_object=${tl.enbs[2]}
...                source_sw=${INITIAL_SW}
...                target_sw=${TARGET_SW}
...                temporary_allowed_alarms=${TEMPORARY_ALLOWED_FAULTS_2316}
...                custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_2316}



@{NODES}           ${NODE1}    ${NODE2}    ${NODE3}


*** Test Cases ***
Load_Initial_SW
    [Timeout]   3h
    coam_csv4all.Setup admin    bts_host=192.168.255.129    bts_port=443    use_ssl=True    alias=get_init_sw_BTS_1
    coam_csv4all.Setup admin    bts_host=192.168.255.129    bts_port=443    use_ssl=True    remote_host=10.68.181.46
    ...          alias=get_init_sw_BTS_2
    coam_csv4all.Setup admin    bts_host=192.168.255.129    bts_port=443    use_ssl=True    remote_host=10.68.181.47
    ...          alias=get_init_sw_BTS_3
    ${INIT_BTS_1}      coam_csv4all.get_sw_version      connection=get_init_sw_BTS_1
    ${INIT_BTS_2}      coam_csv4all.get_sw_version      connection=get_init_sw_BTS_2
    ${INIT_BTS_3}      coam_csv4all.get_sw_version      connection=get_init_sw_BTS_3
    ${result1}      Run Keyword And Ignore Error    should contain    ${INIT_BTS_1}    999
    ${result2}      Run Keyword And Ignore Error    should contain    ${INIT_BTS_2}    999
    ${result3}      Run Keyword And Ignore Error    should contain    ${INIT_BTS_3}    999
    Run Keyword If    '${result1[0]}'=='PASS'    Set Test Variable      ${INIT_BTS_1}    SBTS00_${INIT_BTS_1[9:]}
    Run Keyword If    '${result2[0]}'=='PASS'    Set Test Variable      ${INIT_BTS_2}    SBTS00_${INIT_BTS_2[9:]}
    Run Keyword If    '${result3[0]}'=='PASS'    Set Test Variable      ${INIT_BTS_3}    SBTS00_${INIT_BTS_3[9:]}
#    Run Keyword If    '${result1[0]}'=='PASS'    Set Test Variable      ${INIT_5G}    SBTS00_${INIT_5G[9:]}
#    Run Keyword If    '${result2[0]}'=='PASS'    Set Test Variable      ${INIT_4G}    SBTS00_${INIT_4G[9:]}

    Run Keyword If       "${INIT_BTS_1}"=="${INIT_BTS_2}"=="${INIT_BTS_3}"=="${INITIAL_SW}"    Pass Execution    TestCase skipped
    Run Keyword If       "${INIT_BTS_1}"!="${INITIAL_SW}"    coam_csv4all.rollback_software      alias=get_init_sw_BTS_1
    Run Keyword If       "${INIT_BTS_2}"!="${INITIAL_SW}"    coam_csv4all.rollback_software      alias=get_init_sw_BTS_2
    Run Keyword If       "${INIT_BTS_3}"!="${INITIAL_SW}"    coam_csv4all.rollback_software      alias=get_init_sw_BTS_3
    sleep    720s
    [Teardown]    Run Keywords    coam_csv4all.teardown admin    alias=get_init_sw_BTS_1
    ...    AND    coam_csv4all.teardown admin    alias=get_init_sw_BTS_2
    ...    AND    coam_csv4all.teardown admin    alias=get_init_sw_BTS_3


E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Timeout]   40h
    [Tags]    QC_202889   QCD_MN_RAN   QCP_RAN_VRF
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODES}
    ...		     iterations_per_node=${UPGRADE_TEST_ITERATION}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report=${REPORT}
    ...          report_comment=${REPORT_COMMENT}
#    ...          download_path=
    ...          qc_project=${QC_PROJECT}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=202889

#E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
#    [Timeout]   24h
#    [Tags]    QC_35811   QCD_MN_RAN   QCP_RAN_VRF
#    E2E TL SITE RESET WITHOUT HWF WITH OAM KPI
#    ...          nodes_details=${NODES}
#    ...          test_nodes_details=${NODES}
#    ...		     iterations_per_node=${SITE_RESET_TEST_ITERATION}
#    ...          customers_list=${CUSTOMERS_LIST}
#    ...          report=${REPORT}
#    ...          report_comment=${REPORT_COMMENT}
#    ...          qc_project=${QC_PROJECT}
#    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=35811

#QC_ID 25R1
E2E_TL_Cell_lock_Unlock_LTE_with_OAM_KPI
   [Timeout]   24h
   [Tags]    QC_202893   QCD_MN_RAN   QCP_RAN_VRF
   E2E TL CELL LOCK UNLOCK LTE WITH OAM KPI
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODES}
    ...		     iterations_per_node=${CELL_LOCK_TEST_ITERATION}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report=${REPORT}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_project=${QC_PROJECT}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=202893

E2E_TL_RU_Reset_with_OAM_KPI
   [Timeout]   24h
   [Tags]    QC_202897   QCD_MN_RAN   QCP_RAN_VRF
   E2E TL RU RESET WITH OAM KPI
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODES}
    ...		     iterations_per_node=${RU_RESET_TEST_ITERATION}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report=${REPORT}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_project=${QC_PROJECT}
    ...          qc_domain=${QC_DOMAIN}
   ...           qc_id=202897
   ...           qc_project=${QC_PROJECT}

E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Timeout]   24h
    [Tags]    QC_202887   QCD_MN_RAN   QCP_RAN_VRF
    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODES}
    ...		     iterations_per_node=${COMMISSIONING_TEST_ITERATION}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report=${REPORT}zz
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_project=${QC_PROJECT}
    ...          qc_domain=${QC_DOMAIN}
   ...           qc_id=202887
   ...           qc_project=${QC_PROJECT}

E2E_TL_Site_Reset_Test_with_OAM_KPI
    [Timeout]   24h
    [Tags]    QC_202885   QCD_MN_RAN   QCP_RAN_VRF
    E2E_TL_SITE_RESET_WITH_OAM_KPI
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODES}
    ...		     iterations_per_node=${SITE_RESET_TEST_ITERATION}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report=${REPORT}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_project=${QC_PROJECT}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=202885

E2E_TL_Activition_Reset_with_OAM_KPI
    [Timeout]   24h
    [Tags]    QC_202895   QCD_MN_RAN   QCP_RAN_VRF
    E2E_TL_SITE_RESET_WITH_OAM_KPI
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODES}
    ...		     iterations_per_node=${SITE_RESET_TEST_ITERATION}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report=${REPORT}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_project=${QC_PROJECT}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=202895

E2E_TL_Activition_Reset
    [Timeout]   24h
    [Tags]    QC_202895   QCD_MN_RAN   QCP_RAN_VRF
    E2E_TL_ACTIVATION_RESET_TEST
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODES}
    ...		     iterations_per_node=${SITE_RESET_TEST_ITERATION}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report=${REPORT}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_project=${QC_PROJECT}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=202895
