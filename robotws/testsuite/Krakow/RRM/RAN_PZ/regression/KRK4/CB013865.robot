*** Settings ***
Documentation
...    Suite for testing UUF CB013865

Library      String
Library      ute_wtssim
Library      ta5g_enb
Library      ta5g_egate
Library      ta5g_pm_counters
Library      ute_fsmaccess
Library      taf.rfrl.csv4all.CSV4AllTestCases
Library      taf.rfrl.utilities.cloud_manager.artifacts
Library      taf.rfrl.utilities.test_config.DefaultFileLocation
Library      on_air_tl_preparation.bts.bts_operations.GnbBtsPreparator
Library      testsuite/Krakow/resources/UUF/get_uuf_builds.py
Library      testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.Python.common_wts
Library      testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.Python.common_gnb
Library      testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.Python.iphy_management.IphyManagement
Library      testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.Python.swconfig.ApFileManager
Library      testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.Python.file_management
Resource     taf/rfrl/ue/robot/REAL_UE.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py


Force Tags    CA_VRF_KRK    QCD_MN_RAN    QCP_RAN_VRF

Suite Setup       Custom Suite Setup
Suite Teardown    Custom Suite Teardown

Test Setup        Custom Test Setup
Test Teardown     common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed

*** Variables ***
${SOURCE_SW}                                    SBTS00_ENB_9999_260128_000003
${TARGET_SW}                                    SBTS00_ENB_9999_260128_000004
${CUSTOMERS_LIST}                               ${None}     # Customer list separated by comma
@{CUSTOM_ALARMS}                                6134    7317    7316    7305    10
@{CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}  7305    7316    10
@{ADDITIONAL_ALLOWED_ALARMS}                    7305    10
${SYSLOG_IGNORED_PRINTS}                        ${None}     # String separated by |
${UUF_TEMPORARY_ALLOWED_ALARMS}                 ${None}
${SWCONFIG_PATH}                                commissionings/Krakow/swconfig/default_swconfig.txt
${REPORT}                                       ${True}
${RESTORE_TO_TARGET_SW}                         ${True}
${SCF_PREFIX_TAG}                               ${None}
${BSR_CONFIG_FILE}                              ${None}

&{NODE1}                            testline_object=${tl.gnbs[0]}
...                                 source_sw=${SOURCE_SW}
...                                 target_sw=${TARGET_SW}
...                                 custom_allowed_alarms=${CUSTOM_ALARMS}
...                                 syslog_ignored_prints=${SYSLOG_IGNORED_PRINTS}

@{NODES}                            ${NODE1}

${UPDATE_TEST_ITERATION}            1

${QC_DOMAIN}                        MN_RAN
${QC_PROJECT}                       RAN_VRF
${QC_ID_UPGRADE}                    ${None}

${RP_CA}                            VRF_OAM
${RP_ORGANIZATION}                  ${None}
${RP_LOCATION}                      VRF_KRK

@{SIB_LIST}                         ${40}    ${41}    ${42}
&{SIB_DICT_FOR_AP_CELLS}            ${2}=@{SIB_LIST}
${AP_IP}    192.168.200.1
${NOKIA_USERNAME}    toor4nsn
${NOKIA_PASS}    oZPS0POrRieRtu

*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Timeout]    96h
    [Tags]    UUF
    ue.Require UE  UE  capabilities=QUECTEL_UE
    Run Keyword If  '${QC_ID_UPGRADE}'!='${None}'    Set Tags    QC_${QC_ID_UPGRADE}
    Set To Dictionary    ${NODE1}    source_sw    ${SOURCE_SW}
    Set To Dictionary    ${NODE1}    target_sw    ${TARGET_SW}

    ${copy_node1}        Copy Dictionary    ${NODE1}
    Set To Dictionary    ${copy_node1}      temporary_allowed_alarms    ${UUF_TEMPORARY_ALLOWED_ALARMS}
    ${copy_nodes}        Create List        ${copy_node1}

    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...                                     nodes_details=${copy_nodes}
    ...                                     test_nodes_details=${copy_node1}
    ...                                     iterations_per_node=${UPDATE_TEST_ITERATION}
    ...                                     report=${REPORT}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_ID_UPGRADE}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}
    ...                                     restore_to_target_sw=${RESTORE_TO_TARGET_SW}
    ...                                     l3_call_method=Data Transfer With Throughput Verification

    [Teardown]    Custom Test Teardown

*** Keywords ***
Custom Suite Setup
    ${COMMISSIONING_PATH}    Get Commissioning Dir
    ${WTS_PATH}    Format String    {}/WTS.cfg    ${COMMISSIONING_PATH}
    ${IPHY_PATH}    Format String    {}/iphy.xml    ${COMMISSIONING_PATH}
    ${SWCONF_AP_PATH}    Format String    {}/swconfig_ap.txt    ${COMMISSIONING_PATH}
    ${SW_LIST}    Create List    ${SWCONF_AP_PATH}
    Run On Unit    rm /rom/simmode/iphy.xml
    Upload Iphy To Airphone    local_iphy_filepath=${IPHY_PATH}
    upload_files_to_ap    remote_path=/ffs/run/    files=@{SW_LIST}
    Run On Unit    crasign /ffs/run/swconfig.txt;craverify /ffs/run/swconfig.txt*;sync;sync
    Run On Unit Via Moler    /usr/bin/system-module-reboot
    Log To Console    AP rebooted, waiting 2 mins for AP to be up and running...
    Sleep    2m
    Common Suite Setup With OnAir Test Line Preparation
    ...                         prefix_tag=${SCF_PREFIX_TAG}
    ...                         increase_timeout_for_update_sw=${1800}
    ...                         list_of_additional_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}
    ...                         swconfig_from_path=${SWCONFIG_PATH}
    ...                         bsr_config_file=${BSR_CONFIG_FILE}
    ...                         wait_for_on_air=${False}
    Start Wts    wts_config_filename=${WTS_PATH}
    wait_for_bts_on_air_state    increase_time_for_checking_radios=${False}    increase_time_for_checking_cells=${False}

    ${SOURCE_SW} =          IF    '${SOURCE_SW}'=='${None}'         Get CM Source Build    ELSE    Set Variable  ${SOURCE_SW}
    ${TARGET_SW} =          IF    '${TARGET_SW}'=='${None}'         Get Target Build       ELSE    Set Variable  ${TARGET_SW}
    @{CUSTOMERS_LIST} =     IF    '${CUSTOMERS_LIST}'!='${None}'    Split String    ${CUSTOMERS_LIST}    ,    ELSE    Create List    Generic
    ${REPORT}=                  Evaluate    '${REPORT}'=='True'
    ${RESTORE_TO_TARGET_SW}=    Evaluate    '${RESTORE_TO_TARGET_SW}'=='True'

    Set Global Variable  ${SOURCE_SW}
    Set Global Variable  ${TARGET_SW}
    Set Global Variable  @{CUSTOMERS_LIST}
    Set Global Variable  ${REPORT}
    Set Global Variable  ${RESTORE_TO_TARGET_SW}

Custom Suite Teardown
    common_setups_and_teardowns.Common Suite Teardown
    Stop Wts And Clear

Custom Test Setup
    common_setups_and_teardowns.Common Preconditions
    ...    collect_syslog=${False}
    ...    collect_ru_console_log=${False}
    Run Keyword And Ignore Error    Remove Directory         path=/home/ute/.ute-ca/cache/bts/    recursive=${True}

Custom Test Teardown
    gnbbbu.connect    force=${True}
    common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed
    ...    collect_snapshot_from_ru=${False}

Data Transfer With Throughput Verification
    [Arguments]                             ${cell_used_in_test}
    Log To Console  ${cell_used_in_test}
    ue.Attach UE    UE
    sleep    15
    Perform Bidirectional Data Transfer With Throughput Verification
    ...     duration=120s
    ...     dl_throughput=300 Mbits/sec       # 5G
    ...     ul_throughput=90 Mbits/sec        # 5G
    ...     max_deviation=20%
    ue.Detach UE    UE

Perform Bidirectional Data Transfer With Throughput Verification
    [Arguments]    ${duration}    ${dl_throughput}    ${ul_throughput}    ${max_deviation}
    log to console   \nStart UL Data Transfer
    ue.Start Data Transfer    dt_name=DT_UL    ue_alias=UE    direction=ul    protocol=tcp    duration=${duration}
    ...  tput=${ul_throughput}
    ...  size_packet=1400B
    ...  parallel_streams=16
#    ...  max_segment_size=1408
#    ...  linux_congestion=cubic
#    ...  apn=${apn}
    log to console   \nStart DL Data Transfer
    ue.Start Data Transfer    dt_name=DT_DL    ue_alias=UE    direction=dl    protocol=tcp    duration=${duration}
    ...  tput=${dl_throughput}
    ...  size_packet=1400B
    ...  parallel_streams=1
#    ...  max_segment_size=1408
#    ...  linux_congestion=cubic
#    ...  apn=${apn}
#    REAL_UE.Wait for truput stabilization
    log to console   \nAwait Data Transfer Finish
    ue.Await Data Transfer Finish       dt_name=DT_UL
    ue.Await Data Transfer Finish       dt_name=DT_DL
    log to console   \nAverage Throughput Verification
    ue.Verify Average Throughput With Deviation   dt_name=DT_DL   tput=${dl_throughput}  deviation=${max_deviation}
    log to console   \nDL Throughput OK
    ue.Verify Average Throughput With Deviation   dt_name=DT_UL   tput=${ul_throughput}   deviation=${max_deviation}
    log to console   \nUL Throughput OK
