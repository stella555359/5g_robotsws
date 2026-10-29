*** Settings ***
Documentation       Test suite for basic CSV4ALL Tests in loop
...                 Author: Damian Pietrzyk
...                 Contact: damian.pietrzyk@nokia.com

Library             taf/rfrl/csv4all/CSV4AllTestCases.py
#Library             /home/ute/.pyenv/versions/3.9.14/lib/python3.9/site-packages/taf/rfrl/csv4all/CSV4AllTestCases.py
#Resource            taf/rfrl/uuf4all/uuf4all_keywords.robot
#Resource           /home/ute/MN/UTE/robotws/testsuite/Wroclaw/UUF/resources/common/uuf_keywords.robot
#Variables         /home/ute/.pyenv/versions/3.9.14/lib/python3.9/site-packages/taf/config/testline/__init__.py

#Suite Setup        Standalone Common Suite Setup

*** Variables ***

${UPDATE_TEST_ITERATION}    1
${RP_CA}   VRF_RRM
${RP_LOCATION}    VRF_BLR1
${RP_ORGANIZATION}    VRF_BLR1_T05
${EMAIL_RECIPIENTS}         rashmi.singh@nokia.com
${INITIAL_SW}               SBT25R2_ENB_0000_000218_000000
${TARGET_SW}                SBTS00_ENB_9999_250325_000008
#&{vm_dict}                 host=10.43.54.206
#...                        user=ute
#...                        password=BT5l@bus3rl0g1n
&{NODE1}                    node_alias=LAA
...                         node_vm=10.43.54.224
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALLOWED}
...                         temporary_allowed_alarms=${EMPTY}
#...                         testline_scout_name=7_2_DU431_4G

#&{NODE2}                    node_alias=DU_LTE
#...                         node_vm=10.43.54.230
#...                         source_sw=${INITIAL_SW}
#...                         target_sw=${TARGET_SW}
#...                         testline_scout_name=7_2_DU431_5G
#${ITERATIONS}               1
@{CUSTOM_ALLOWED}           4655      61524      4654      61652      61649
${SHOULD_BE_REPORTED}		True
${RESTORE_TARGET_SW}		True
@{CUSTOMERS}			    Generic
${QC_DOMAIN}				MN_RAN
${QC_PROJECT}				RAN_VRF
#${DOWNLOAD_PATH}=           /home/ute/UUF_SW
# List of nodes passed to test keywords
@{NODES}                     ${NODE1}
#@{UPGRADE_NODES}             ${NODE1}    ${NODE2}


*** Test Cases ***
#E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI_single_node_upgrade
#[Timeout]   24h
#    Set Test Variable  &{OAM_KPI_TARGETS}     kpi2a=600
#    ...                                       kpi2b=600
#    ...                                       kpi2c=600
#    ...                                       kpi2d=600
#    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI    ${NODES}  ${NODE1}  ${1}
#
#    ...          report=${SHOULD_BE_REPORTED}
#    ...          customers_list=${CUSTOMERS_LIST}
#    ...          restore_to_target_sw=${RESTORE_TARGET_SW}
#    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=${50324}
##    ...          qc_id=${852714}
##    ...          qc_id=${788976}
#    ...          qc_project=${QC_PROJECT}

#E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI_multiple_node_upgrade
#    [Timeout]   24h
#    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
#    ...           ${NODES}
#    ...           ${NODE1}
#    ...           ${NODE2}
#    ...           ${ITERATIONS}
#    ...           customers_list=${CUSTOMERS}
#    Set Test Variable  &{OAM_KPI_TARGETS}     kpi2a=600
#    ...                                       kpi2b=600
#    ...                                       kpi2c=600
#    ...                                       kpi2d=600
#    ...          report=${SHOULD_BE_REPORTED}
#    ...          restore_to_target_sw=${RESTORE_TARGET_SW}
#    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=${50324}
#    ...          qc_project=${QC_PROJECT}


#E2E_TL_Parallel_SW_Upgrade_Rollback_with_OAM_KPI
#    [Timeout]   24h
##    Log      ${UPDATE_TEST_ITERATION}
#    E2E PARALLEL SW UPGRADE ROLLBACK WITH OAM KPI
#    ...             ${NODES}
#    ...             ${NODES}
#    #...             ${NODE1}
#    #...             ${NODE2}
#    ...             ${UPDATE_TEST_ITERATION}
#    ...             customers_list=${CUSTOMERS}
##    Set Test Variable  &{OAM_KPI_TARGETS}     kpi2a=600
##    ...                                       kpi2b=600
##    ...                                       kpi2c=600
##    ...                                       kpi2d=600
#    ...            report=${SHOULD_BE_REPORTED}
#    ...            restore_to_target_sw=${RESTORE_TARGET_SW}
#    ...            qc_domain=${QC_DOMAIN}
#    ...            qc_id=${None}
#    ...            qc_project=${QC_PROJECT}


#E2E_TL_RU_Reset_with_OAM_KPI
#    [Timeout]   24h
#    E2E TL RU RESET WITH OAM KPI
#
#    ...          ${NODES}
#    ...          ${NODE1}
#    ...          ${UPDATE_TEST_ITERATION}
#    ...          customers_list=${CUSTOMERS}
#    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=${31491}
#    ...          qc_project=${QC_PROJECT}
#    ...          report=${SHOULD_BE_REPORTED}

#E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
#    [Timeout]   24h
#    Log      ${UPDATE_TEST_ITERATION}
#    e2e_tl_cell_lock_unlock_nr_with_oam_kpi
#    ...            ${Nodes}
#    ...            ${NODE1}
##    ...            ${NODE2}
#    ...            ${UPDATE_TEST_ITERATION}
#    ...            customers_list=${CUSTOMERS}
#    Set Test Variable  &{OAM_KPI_TARGETS}     kpi2a=630
#    ...                                       kpi2b=500
#    ...                                       kpi2c=620
#    ...                                       kpi2d=500
#    ...                                       kpi51a=500
#    ...                                       kpi51b=500
#    ...                                       kpi16a=500
#    ...                                       kpi16b=500
#    ...          report=${SHOULD_BE_REPORTED}
#    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=${31490}
#    ...          customers_list=${CUSTOMERS}
##    ...          qc_id=${78897}
##    ...          qc_id=${852717}
#    ...          qc_project=${QC_PROJECT}

#E2E_TL_RU_Power_Reset
#    [Timeout]   24h
#    E2E TL RU POWER RESET    ${NODES}  ${NODE1}  ${ITERATIONS}


E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
    [Timeout]   24h
    E2E TL SITE RESET WITHOUT HWF WITH OAM KPI
    ...          ${NODES}
    ...          ${NODE1}
    ...          ${UPDATE_TEST_ITERATION}
    ...          customers_list=${CUSTOMERS}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${None}
    ...          qc_project=${QC_PROJECT}
    ...          report=${SHOULD_BE_REPORTED}

