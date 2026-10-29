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


Suite Setup       Custom Suite Setup
Suite Teardown    common_setups_and_teardowns.Common Suite Teardown

Test Setup        Custom Test Setup
Test Teardown     common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed

*** Variables ***
${SOURCE_SW}                        SBTS24R3_ENB_0000_000991_000000
${TARGET_SW}                        SBTS00_ENB_9999_250102_000006
${CUSTOMERS_LIST}                   ${None}    # Customer list separated by comma
@{CUSTOM_ALARMS}                    61648    7115    4420    4123    4125    8150    4459    8000
${TESTLINE_SCOUT_NAME}              7_7_UTE5GCLOUDT11SK055_066

&{NODE1}                            testline_object=${tl.gnbs[0]}
...                                 source_sw=${SOURCE_SW}
...                                 target_sw=${TARGET_SW}
...                                 custom_allowed_alarms=${CUSTOM_ALARMS}
...                                 testline_scout_name=${TESTLINE_SCOUT_NAME}

@{NODES}                            ${NODE1}

${UPDATE_TEST_ITERATION}            1
${SITE_RESET_TEST_ITERATION}        1

${QC_DOMAIN}                        MN_RAN
${QC_PROJECT}                       RAN_VRF
${QC_ID_UPGRADE}                    105401
${QC_ID_RESET}                      105400

${RP_CA}                            VRF_OAM
${RP_ORGANIZATION}                  VRF_KRK_T07
${RP_LOCATION}                      VRF_KRK


*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Timeout]    96h
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${UPDATE_TEST_ITERATION}
    ...                                     report=${True}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_ID_UPGRADE}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}
    ...                                     restore_to_target_sw=${True}

    [Teardown]    Custom Test Teardown

E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
    [Timeout]    96h
    gnbbbu.Disconnect
    E2E TL SITE RESET WITHOUT HWF WITH OAM KPI
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${SITE_RESET_TEST_ITERATION}
    ...                                     report=${True}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_ID_RESET}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}


*** Keywords ***
Remove Dirs
    [Arguments]    @{directory_path}
    FOR    ${dir}    IN    @{directory_path}
        ${status}=    Run Keyword And Return Status    Directory Should Exist    ${dir}
        Run Keyword If    ${status}    Remove Directory    ${dir}    force=True
    END

Custom Suite Setup
    Common Suite Setup
    @{CUSTOMERS_LIST}=    Run Keyword If  '${CUSTOMERS_LIST}'!='${None}'
    ...                     Split String    ${CUSTOMERS_LIST}    ,
    ...                   ELSE
    ...                     Create List    Generic

    Set Global Variable  @{CUSTOMERS_LIST}

Custom Test Setup
    common_setups_and_teardowns.Common Preconditions    collect_syslog=${False}
    Remove Dirs       directory_path=/home/ute/.ute-ca/cache/bts/

Custom Test Teardown
    gnbbbu.connect    force=${True}
    common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed
