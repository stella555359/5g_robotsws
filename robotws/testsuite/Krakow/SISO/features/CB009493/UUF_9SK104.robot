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
${SOURCE_SW}                        ${None}
${TARGET_SW}                        ${None}
${CUSTOMERS_LIST}                   ${None}    # Customer list separated by comma
@{CUSTOM_ALARMS}                    @{EMPTY}

&{NODE1}                            testline_object=${tl.gnbs[0]}
...                                 source_sw=${SOURCE_SW}
...                                 target_sw=${TARGET_SW}
...                                 custom_allowed_alarms=${CUSTOM_ALARMS}

@{NODES}                            ${NODE1}

${UPDATE_TEST_ITERATION}            50
${SITE_RESET_TEST_ITERATION}        100

${QC_DOMAIN}                        MN_RAN
${QC_PROJECT}                       RAN_VRF
${QC_ID_UPGRADE}                    105403
${QC_ID_RESET}                      105402

${RP_CA}                            VRF_OAM
${RP_ORGANIZATION}                  VRF_KRK_T07
${RP_LOCATION}                      VRF_KRK


*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Timeout]    96h

    Run Keyword If  '${QC_ID_UPGRADE}'!='${None}'    Set Tags    QC_${QC_ID_UPGRADE}
    Set To Dictionary    ${NODE1}    source_sw    ${SOURCE_SW}
    Set To Dictionary    ${NODE1}    target_sw    ${TARGET_SW}

    Sleep    18 minutes    reason=Waiting till scout connect to BTS(It is temporary WA)

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

E2E_TL_Activation_Reset_with_OAM_KPI
    [Timeout]    96h

    Run Keyword If  '${QC_ID_RESET}'!='${None}'    Set Tags    QC_${QC_ID_RESET}
    gnbbbu.Disconnect
    E2E TL ACTIVATION RESET TEST
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
    Common Suite Setup With OnAir Test Line Preparation
    ...               increase_timeout_for_update_sw=${900}

    #    Uncomment for RF50
    #    ${SOURCE_SW} =    IF    '${SOURCE_SW}'=='${None}'  Get CM Source Build    ELSE    Set Variable  ${SOURCE_SW}
    #    ${TARGET_SW} =    IF    '${TARGET_SW}'=='${None}'  Get Target Build   ELSE    Set Variable  ${TARGET_SW}
    #    @{CUSTOMERS_LIST} =    IF    '${CUSTOMERS_LIST}'!='${None}'  Split String    ${CUSTOMERS_LIST}    ,    ELSE    Create List    Generic

    ${SOURCE_SW}=    run keyword if  '${SOURCE_SW}'=='${None}'  Get CM Source Build
    ...   ELSE  Set Variable  ${SOURCE_SW}
    ${TARGET_SW}=    run keyword if  '${TARGET_SW}'=='${None}'  Get Target Build
    ...   ELSE  Set Variable  ${TARGET_SW}

    @{CUSTOMERS_LIST}=    Run Keyword If  '${CUSTOMERS_LIST}'!='${None}'
    ...                     Split String    ${CUSTOMERS_LIST}    ,
    ...                   ELSE
    ...                     Create List    Generic

    Set Global Variable  ${SOURCE_SW}
    Set Global Variable  ${TARGET_SW}
    Set Global Variable  @{CUSTOMERS_LIST}

Custom Test Setup
    common_setups_and_teardowns.Common Preconditions    collect_syslog=${False}
    Remove Dirs       directory_path=/home/ute/.ute-ca/cache/bts/

Custom Test Teardown
    gnbbbu.connect    force=${True}
    common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed
