*** Settings ***
Documentation
...   author: Szymon Misiolek
...   contact: szymon.misiolek@nokia.com
...   Test suite for basic UUF OAM Tests in loop:

Library      String
Library      taf.rfrl.csv4all.CSV4AllTestCases
Library      taf.rfrl.utilities.cloud_manager.artifacts
Library      testsuite/Krakow/resources/UUF/get_uuf_builds.py
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py


Force Tags    CA_VRF_KRK    QCD_MN_RAN    QCP_RAN_VRF

#Suite Setup       Common Suite Setup
Suite Setup       Custom Suite Setup


Suite Teardown    common_setups_and_teardowns.Common Suite Teardown
Test Setup        Custom Test Setup
Test Teardown     common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed

*** Variables ***
${SOURCE_SW}                                    SBTS00_ENB_9999_250720_000001
${TARGET_SW}                                    SBTS00_ENB_9999_250730_000011
${CUSTOMERS_LIST}                               ${None}     # Customer list separated by comma
@{CUSTOM_ALARMS}                                4694    61675
${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}  WiFi Configuration Issue    61675
${SYSLOG_IGNORED_PRINTS}                        INF     # String separated by |
@{additional_allowed_alarms}
...    WiFi Configuration Issue

&{NODE1}                            testline_object=${tl.gnbs[0]}
...                                 source_sw=${SOURCE_SW}
...                                 target_sw=${TARGET_SW}
...                                 custom_allowed_alarms=${CUSTOM_ALARMS}
...                                 syslog_ignored_prints=${SYSLOG_IGNORED_PRINTS}

@{NODES}                            ${NODE1}

${UPDATE_TEST_ITERATION}            5
${SITE_RESET_TEST_ITERATION}        30

${QC_DOMAIN}                        MN_RAN
${QC_PROJECT}                       RAN_VRF
#${QC_ID_UPGRADE}                    98533 - poprzednia wersja numeru ???
${QC_ID_UPGRADE}                    221125
${QC_ID_RESET}                      98605
#${QC_ID_RESET}                      83097 ??? ID testu na resety b?dzie inne
#${QC_ID_UPGRADE}                    ${None}
#${QC_ID_RESET}                      ${None}

${RP_CA}                            VRF_SiSo
${RP_ORGANIZATION}                  VRF_KRK_T04
${RP_LOCATION}                      VRF_KRK

${DISABLE_SYSLOG_CHECK}=            ${True}


*** Test Cases ***
CB010969_UUF4ALL_SW_UPGRADE_TEST
      [Timeout]    96h
      [Tags]    UUF

      Run Keyword If  '${QC_ID_UPGRADE}'!='${None}'    Set Tags    QC_${QC_ID_UPGRADE}
      Set To Dictionary    ${NODE1}    source_sw    ${SOURCE_SW}
      Set To Dictionary    ${NODE1}    target_sw    ${TARGET_SW}
      ##Sleep    18 minutes    reason=Waiting till scout connect to BTS(It is temporary WA)
      E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
      ...                                     nodes_details=${NODES}
      ...                                     test_nodes_details=${NODE1}
      ...                                     iterations_per_node=${UPDATE_TEST_ITERATION}
      ...                                     report=${True}
      ...                                     qc_domain=${QC_DOMAIN}
      ...                                     qc_project=${QC_PROJECT}
      ...                                     qc_id=${QC_ID_UPGRADE}
      ...                                     sw_build=${TARGET_SW}
      ...                                     customers_list=${CUSTOMERS_LIST}
      ...                                     restore_to_target_sw=${True}
      [Teardown]    Custom Test Teardown


#CB010969_UUF4ALL_RESET_TEST_without_HWF
#      [Timeout]    96h
#      [Tags]    SITE_RESET
#
#      Run Keyword If  '${QC_ID_RESET}'!='${None}'    Set Tags    QC_${QC_ID_RESET}
#      gnbbbu.Disconnect
#      E2E TL SITE RESET WITHOUT HWF WITH OAM KPI
##      E2E_TL_ACTIVATION_RESET_TEST -> to ma by? docelowy test zastosowany, trzeba dostosowac w QC
#      ...                                     nodes_details=${NODES}
#      ...                                     test_nodes_details=${NODE1}
#      ...                                     iterations_per_node=${SITE_RESET_TEST_ITERATION}
#      ...                                     report=${True}
#      ...                                     qc_domain=${QC_DOMAIN}
#      ...                                     qc_project=${QC_PROJECT}
#      ...                                     qc_id=${QC_ID_RESET}
#      ...                                     sw_build=${TARGET_SW}
#      ...                                     customers_list=${CUSTOMERS_LIST}


*** Keywords ***
Custom Suite Setup
    Common Suite Setup With OnAir Test Line Preparation
    ...                         increase_timeout_for_update_sw=${2400}
    ...                         list_of_additional_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}
    ...                         swconfig_from_path=commissionings/${CONFIGURATION.replace('.', '/')}/swconfig.txt
    ...                         prefix_tag=CB010969
#    ...                         AND    Common Suite Setup With Commissioning    prefix_tag=CB010969    asir_hub=${True}

    ${SOURCE_SW} =          IF    '${SOURCE_SW}'=='${None}'         Get CM Source Build    ELSE    Set Variable  ${SOURCE_SW}
    ${TARGET_SW} =          IF    '${TARGET_SW}'=='${None}'         Get Target Build       ELSE    Set Variable  ${TARGET_SW}
    @{CUSTOMERS_LIST} =     IF    '${CUSTOMERS_LIST}'!='${None}'    Split String    ${CUSTOMERS_LIST}    ,    ELSE    Create List    Generic

    Set Global Variable  ${SOURCE_SW}
    Set Global Variable  ${TARGET_SW}
    Set Global Variable  @{CUSTOMERS_LIST}

Custom Test Setup
    common_setups_and_teardowns.Common Preconditions
    ...    collect_syslog=${False}
    ...    collect_ru_console_log=${False}
    Run Keyword And Ignore Error    Remove Directory         path=/home/ute/.ute-ca/cache/bts/    recursive=${True}

Custom Test Teardown
    gnbbbu.connect    force=${True}
    common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed
    ...    collect_snapshot_from_ru=${False}
