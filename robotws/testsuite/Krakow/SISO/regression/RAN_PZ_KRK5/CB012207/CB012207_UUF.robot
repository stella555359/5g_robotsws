** Settings ***
Documentation
...                 author: Lukasz Klosinski
...                 contact: lukasz.klosinski@nokia.com
...                 Test suite for basic CSV4ALL Tests in loop:

Library             taf/rfrl/csv4all/CSV4AllTestCases.py
Resource            taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables           testsuite/Krakow/SISO/regression/RAN_PZ_KRK5/CB012207/resources/UUF_common_variables.py
Variables           taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup       Common Suite Setup With OnAir Test Line Preparation    upload_swconfig_to_neighbour=${True}
...                                                                      should_5G_neighbour_be_changed=${True}
...                                                                      list_of_additional_allowed_alarms=@{ALARMS_LIST}
Suite Teardown    Common Suite Teardown

Test Setup        Common Preconditions
Test Teardown     Common Postconditions With Restore Configuration If Test Failed

*** Variables ***
@{CUSTOMERS_LIST}               TMO US
${SOURCE_SW}                    None
${TARGET_SW}                    None
${UPDATE_TEST_ITERATION}        5
${SITE_RESET_TEST_ITERATION}    30
${SHOULD_BE_REPORTED}           True
${RP_CA}                        VRF_SiSo
${RP_LOCATION}                  VRF_KRK
${RP_ORGANIZATION}              VRF_KRK_T05
&{NODE1}                        testline_object=${tl.gnbs[0]}
...                             source_sw=${SOURCE_SW}
...                             target_sw=${TARGET_SW}
...                             testline_scout_name=7_7_T01SK220
@{NODES}                        ${NODE1}
@{ALARMS_LIST}                  No Xn link available

*** Test Cases ***
SW_upgrade_rollback_with_OAM_KPI
    [Timeout]   96h

    Set To Dictionary    ${NODE1}    source_sw    ${SOURCE_SW}
    Set To Dictionary    ${NODE1}    target_sw    ${TARGET_SW}

    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI    ${NODES}  ${NODE1}  ${UPDATE_TEST_ITERATION}
    ...         report=${SHOULD_BE_REPORTED}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         qc_domain=${kpi_qc_ids['qc_domain']}
    ...         qc_id=${kpi_qc_ids['qc_upgrade']}
    ...         qc_project=${kpi_qc_ids['qc_project']}
    ...         use_external_storage=False
    ...         download_path=/home/ute/UUF_SW
    ...         use_testpackage=False
    ...         restore_to_target_sw=True
    ...         sw_build=${TARGET_SW}
    [Teardown]    Custom Test Teardown

E2E_TL_Activation_Reset_with_OAM_KPI
    [Timeout]    96h
    E2E TL ACTIVATION RESET TEST    ${NODES}  ${NODE1}  ${SITE_RESET_TEST_ITERATION}
    ...         report=${SHOULD_BE_REPORTED}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         sw_build=${TARGET_SW}
    ...         qc_domain=${kpi_qc_ids['qc_domain']}
    ...         qc_id=${kpi_qc_ids['qc_site_reset']}
    ...         qc_project=${kpi_qc_ids['qc_project']}

*** Keywords ***
Custom Test Teardown
    gnbbbu.connect    force=${True}
    common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed
    ...    collect_snapshot_from_ru=${False}
