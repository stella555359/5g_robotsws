*** Settings ***
Documentation
...   Suite for testing UUF

Library      String
Library      taf.rfrl.csv4all.CSV4AllTestCases
Library      taf.rfrl.utilities.cloud_manager.artifacts
Library      testsuite/Krakow/resources/UUF/get_uuf_builds.py
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py


Force Tags    CA_VRF_KRK    QCD_MN_RAN    QCP_RAN_VRF

Suite Setup       Custom Suite Setup
Suite Teardown    common_setups_and_teardowns.Common Suite Teardown

Test Setup        Custom Test Setup
Test Teardown     common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed

*** Variables ***
${SOURCE_SW}                                    ${None}
${TARGET_SW}                                    ${None}
${CUSTOMERS_LIST}                               TMO US     # Customer list separated by comma
@{CUSTOM_ALARMS}                                @{EMPTY}
${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}  ${None}
${SYSLOG_IGNORED_PRINTS}                        ${None}     # String separated by |

&{NODE1}                            testline_object=${tl.gnbs[0]}
...                                 source_sw=${SOURCE_SW}
...                                 target_sw=${TARGET_SW}
...                                 custom_allowed_alarms=${CUSTOM_ALARMS}
...                                 syslog_ignored_prints=${SYSLOG_IGNORED_PRINTS}

@{NODES}                            ${NODE1}

${SITE_RESET_TEST_ITERATION}        30

${QC_DOMAIN}                        MN_RAN
${QC_PROJECT}                       RAN_VRF
${QC_ID_UPGRADE}                    ${None}
${QC_ID_RESET}                      179581

${RP_CA}                            VRF_OAM
${RP_ORGANIZATION}                  VRF_KRK_T04
${RP_LOCATION}                      VRF_KRK

${SW_DIR}    /home/ute/.ute-ca/cache/bts
@{additional_allowed_alarms}
...    User Account has Default Password

*** Test Cases ***
E2E_TL_Site_Reset_with_OAM_KPI
    [Timeout]    96h
    [Tags]    SITE_RESET_OLD

    Run Keyword If  '${QC_ID_RESET}'!='${None}'    Set Tags    QC_${QC_ID_RESET}
    gnbbbu.Disconnect
    E2E TL SITE RESET WITH OAM KPI
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
Custom Suite Setup
    gnbscf.reset_configuration                   bts_id=${1}    timeout=1200
    ${SW_VERSION}    Get gNB Sw Version
    ${SW_PATH}       download_sw_package         sw_version=${SW_VERSION}    target_dir=${SW_DIR}
    gnbbbu.wait_until_smod_is_online             bts_id=${1}
    gnbbbu.verify_bts_is_not_commissioned        bts_id=${1}
    gnbswupdate.wait_sw_update_possible          readiness_timeout=${600}    bts_id=${1}
    gnbswupdate.update_software                  sw_package_dir=${SW_PATH}    bts_id=${1}    timeout=${1200}
    sleep    180
    Perform Full Commissioning on Classical gNB    bts_id=${1}       force_reconnect=${True}    verify_another_sw_upload=${False}
    Perform Full Commissioning on gNB ASIR hub     bts_id=${1}

    upload_swconfig_on_classical_gnb    sw_config_path=commissionings/Krakow/swconfig/default_swconfig.txt
    Common Suite Setup With Commissioning

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
