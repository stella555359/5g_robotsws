*** Settings ***
Documentation
...   Generic suite for  testing UUF
...   author: Wioleta Swies
...   contact: wioleta.swies@nokia.com

Library      String
Library      taf.rfrl.csv4all.CSV4AllTestCases
Library      taf.rfrl.utilities.cloud_manager.artifacts
Library      testsuite/Krakow/resources/UUF/get_uuf_builds.py
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Resource     ./resources/keywords.robot

Suite Setup       Common Suite Setup
Suite Teardown    common_setups_and_teardowns.Common Suite Teardown

Test Setup        Custom Test Setup
Test Teardown     common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed

*** Variables ***
${SOURCE_SW}                        SBTS24R3_ENB_0000_000425_000080
${TARGET_SW}                        SBTS25R1_ENB_0000_000509_000000

@{CUSTOM_ALARMS}                    61648    7115    4420    4123    4125    8150    4459    8000

&{NODE1}                            testline_object=${tl.gnbs[0]}
...                                 source_sw=${SOURCE_SW}
...                                 target_sw=${TARGET_SW}
...                                 custom_allowed_alarms=${CUSTOM_ALARMS}

&{NODE2}                            testline_object=${tl.enbs[0]}
...                                 node_alias=4gANCHOR
...                                 source_sw=${SOURCE_SW}
...                                 target_sw=${TARGET_SW}
...                                 custom_allowed_alarms=${CUSTOM_ALARMS}

@{NODES}                            ${NODE1}
@{UPGRADE_NODES}                    ${NODE1}    ${NODE2}

${UPDATE_TEST_ITERATION}                     10
${SITE_RESET_TEST_ITERATION}                 30

@{CUSTOMERS_LIST}                   TMO US
${QC_DOMAIN}                        MN_RAN
${QC_PROJECT}                       RAN_VRF

${RP_CA}                            VRF_OAM
${RP_ORGANIZATION}                  VRF_KRK_T07
${RP_LOCATION}                      VRF_KRK


*** Test Cases ***
E2E_TL_SW_upgrade_rollback_with_OAM_KPI_UUF
    [Tags]    UUF4ALL
    [Timeout]    96h
    ${QC_ID}=             bts_data.Get Qc Ids   ${TARGET_SW}
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    # Upgrade ONLY 5G
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}

    # Upgrade 5G + LTE
    ...                                     nodes_details=${UPGRADE_NODES}
    ...                                     test_nodes_details=${UPGRADE_NODES}

    ...                                     iterations_per_node=${UPDATE_TEST_ITERATION}
    ...                                     report=${True}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_ID['qc_upgrade_uuf']}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}
    ...                                     restore_to_target_sw=${True}
    [Teardown]    Custom Test Teardown

E2E_TL_Site_reset_without_HWF_with_OAM_KPI_UUF_gNB
    [Tags]    UUF4ALL
    [Timeout]    96h
    gnbbbu.Disconnect
    ${QC_ID}=                 bts_data.Get Qc Ids   ${TARGET_SW}
    E2E TL SITE RESET WITHOUT HWF WITH OAM KPI
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${SITE_RESET_TEST_ITERATION}
    ...                                     report=${True}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_ID['qc_reset_uuf']}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}

*** Keywords ***
Remove Dirs
    [Arguments]    @{directory_path}
    FOR    ${dir}    IN    @{directory_path}
        ${status}=    Run Keyword And Return Status    Directory Should Exist    ${dir}
        Run Keyword If    ${status}    Remove Directory    ${dir}    force=True
    END

Custom Test Setup
    common_setups_and_teardowns.Common Preconditions    collect_syslog=${False}
    Remove Dirs       directory_path=/home/ute/.ute-ca/cache/bts/

Custom Test Teardown
    gnbbbu.connect    force=${True}
    common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed
