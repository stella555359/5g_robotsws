*** Settings ***
Documentation
...   Regression UUF test suite for the feature CB008772
...   author: Aleksandra Faliszek
...   contact: aleksandra.faliszek@nokia.com

Library             taf/rfrl/csv4all/CSV4AllTestCases.py       WITH NAME    CSV4ALL
Resource            taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables           taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup         Common Suite Setup With OnAir Test Line Preparation
...                 prefix_tag=CB008772
Suite Teardown      Common Suite Teardown

Test Setup          Common Preconditions
Test Teardown       Common Postconditions

*** Variables ***
@{CUSTOMERS_LIST}                               Generic
${QC_DOMAIN}                                    MN_RAN
${QC_PROJECT}                                   RAN_VRF
${SHOULD_BE_REPORTED}                           False
${RP_CA}                                        VRF_SiSo
${RP_LOCATION}                                  VRF_KRK
${RP_ORGANIZATION}                              VRF_KRK_T03
${ITERATIONS_UPGRADE}                           ${25}
${5G_SOURCE_SW}                                 ${None}
${5G_TARGET_SW}                                 ${None}
&{NODE1}                                        testline_object=${tl.gnbs[0]}
...                                             source_sw=${5G_SOURCE_SW}
...                                             target_sw=${5G_TARGET_SW}
@{NODES}                                        ${NODE1}

*** Test Cases ***
CB008772-SR-A-UUF4ALL_SW_UPGRADE_TEST_ASOE_3CC
    CSV4ALL.E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${ITERATIONS_UPGRADE}
    ...                                     report=${SHOULD_BE_REPORTED}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     sw_build=${5G_TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}
    ...                                     restore_to_target_sw=${False}
