*** Settings ***
Documentation
...   E2E_TL_Activation_Reset_Test Keyword

Library      String
Library      taf.rfrl.csv4all.CSV4AllTestCases
Library      taf.rfrl.utilities.cloud_manager.artifacts
Library      testsuite/Krakow/resources/UUF/get_uuf_builds.py
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Variables ***
${TARGET_SW}                                    ${None}
@{CUSTOMERS_LIST}                               Generic
@{CUSTOM_ALARMS}                                @{EMPTY}
${SYSLOG_IGNORED_PRINTS}                        ${None}     # String separated by |
${REPORT}                                       ${False}

&{NODE1}                            testline_object=${tl.gnbs[0]}
...                                 target_sw=${TARGET_SW}
...                                 custom_allowed_alarms=${CUSTOM_ALARMS}
...                                 syslog_ignored_prints=${SYSLOG_IGNORED_PRINTS}

@{NODES}                            ${NODE1}

${SITE_RESET_TEST_ITERATION}        1

${QC_DOMAIN}                        MN_RAN
${QC_PROJECT}                       RAN_VRF
${QC_ID_RESET}                      ${None}

${RP_CA}                            VRF_OAM
${RP_ORGANIZATION}                  ${None}
${RP_LOCATION}                      VRF_KRK


*** Keywords ***
E2E_TL_Activation_Reset
    [Timeout]    96h
    [Tags]    SITE_RESET
    ${TARGET_SW}          Get Target Build
    ${REPORT}             Evaluate    '${REPORT}'=='True'
    Run Keyword If  '${QC_ID_RESET}'!='${None}'    Set Tags    QC_${QC_ID_RESET}
    Set To Dictionary    ${NODE1}    target_sw    ${TARGET_SW}
    gnbbbu.Disconnect
    E2E TL ACTIVATION RESET TEST
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${SITE_RESET_TEST_ITERATION}
    ...                                     report=${REPORT}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_ID_RESET}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}
