*** Settings ***
Documentation       Custom keywords for Vodafone NPI
...                 Maintainer: Agnieszka Bylica
...                 Contact: agnieszka.bylica@nokia.com


*** Keywords ***
Custom Suite Setup
    load_certificates_configuration    prefix_tag=${CERTIFICATES_PREFIX_TAG}
    prepare_netact_dict                netact_name=${NETACT_NAME}
    Common Suite Setup With OnAir Test Line Preparation
    ...                         prefix_tag=${SCF_PREFIX_TAG}
    ...                         increase_timeout_for_update_sw=${1800}
    ...                         swconfig_from_path=${SWCONFIG_PATH}
    ...                         bsr_config_file=${BSR_CONFIG_FILE}
    ...                         should_5G_neighbour_be_changed=${SHOULD_5G_NEIGHBOUR_BE_CHANGED}
    ...                         upload_swconfig_to_neighbour=${UPLOAD_SWCONFIG_TO_NEIGHBOUR}
    ...                         list_of_additional_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}
    ...                         certificates=${CERTIFICATES}
    ...                         rusw=${INDEPENDENT_RU_SW_PACKAGE_NAME}

    ${SOURCE_SW} =         IF     '${SOURCE_SW}'=='${None}'         artifacts.get_cm_source_build    ELSE    Set Variable  ${SOURCE_SW}
    ${TARGET_SW} =          IF    '${TARGET_SW}'=='${None}'         uuf_builds.get_target_build      ELSE    Set Variable  ${TARGET_SW}
    @{CUSTOMERS_LIST} =     IF    '${CUSTOMERS_LIST}'!='${None}'    Split String    ${CUSTOMERS_LIST}    ,    ELSE    Create List    Generic
    ${REPORT}=                  Evaluate    '${REPORT}'=='True'
    ${RESTORE_TO_TARGET_SW}=    Evaluate    '${RESTORE_TO_TARGET_SW}'=='True'

    Set Global Variable  ${SOURCE_SW}
    Set Global Variable  ${TARGET_SW}
    Set Global Variable  @{CUSTOMERS_LIST}
    Set Global Variable  ${REPORT}
    Set Global Variable  ${RESTORE_TO_TARGET_SW}

    Define Nodes

Custom Test Setup
    common_setups_and_teardowns.Common Preconditions
    ...    collect_syslog=${False}
    ...    collect_ru_console_log=${False}
    Run Keyword And Ignore Error    Remove Directory         path=/home/ute/.ute-ca/cache/bts/    recursive=${True}
    gnbbbu.disconnect    bts_id=0
    gnbbbu.disconnect    bts_id=1

Custom Mandatory Logs Collection
    [Arguments]    ${log_dir}=${None}    ${gnb_ids}=${None}    ${enb_ids}=${None}

    ${log_dir}    Run Keyword If    '${log_dir}' == 'None'
    ...                 Set Variable    ${LOG_PATH}
    ...           ELSE
    ...                 Set Variable    ${log_dir}

    operations.collect_ims_from_all_btsses                        log_dir=${log_dir}    gnb_ids=${gnb_ids}    enb_ids=${enb_ids}
    operations.collect_current_session_ims_from_all_btsses        log_dir=${log_dir}    gnb_ids=${gnb_ids}    enb_ids=${enb_ids}
    ${snapshot_paths_dict}        operations.collect_snapshot_from_all_btsses    log_dir=${log_dir}    gnb_ids=${gnb_ids}    enb_ids=${enb_ids}
    ${Is_Cloud} =    taf.rfrl.utilities.tl_config.Is Testline of Cloud Type
    Run Keyword If    ${Is_Cloud}    Collect CU Mandatory Logs


Pararell Postconditions
    [Arguments]     ${collect_syslog}=${True}
        ...         ${collect_snapshot_from_ru}=${False}
        ...         ${collect_ru_console_log}=${False}
    ${IS_ASIR_CONFIGURATION}        Get Variable Value  ${IS_ASIR_CONFIGURATION}
    gnbalarm.Wait Until Callback Logs Collection Finished
    Check TRUCK ROLL alarms
    ${TRUCK_ROLL_ALARMS_DETECTED}   Is Truck Roll Alarms Detected
    ${collect_snapshot_from_ru}     Set Variable If    ${TRUCK_ROLL_ALARMS_DETECTED}    ${True}    ${collect_snapshot_from_ru}
    gnbcell.Verify All Cells are OnAir
    operations.verify_all_btses_are_up_and_on_air
    Run Keyword If                  ${IS_ASIR_CONFIGURATION}    gnb_asir.verify_all_antennas_are_enabled
    Run Keyword If                  ${IS_ASIR_CONFIGURATION}    gnb_asir.verify_status_of_all_asir_cells_is_operational
    Verify Default Allowed Alarms on gNB
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Metadata to Report for All BTSs
    interface.Common step trigger
    gnbbbu.Teardown All Browsers
    [Teardown]    Run Keywords
    ...           gnbbbu.Check If BTS Connection Working and Reset If Needed
    ...           AND
    ...           Collect Logs After Test Finished              collect_syslog=${collect_syslog}
    ...                                                         collect_snapshot_from_ru=${collect_snapshot_from_ru}
    ...                                                         collect_ru_console_log=${collect_ru_console_log}
    ...           AND
    ...           Compress moler syslogs
    ...           AND
    ...           Stop Execution If TRUCK ROLL alarms detected
    ...           AND
    ...           Restore Origin TAF Testline Configuration

Custom Test Teardown
    [Arguments]     ${restore_only_if_not_onair}=${True}
        ...         ${collect_syslog}=${True}
        ...         ${collect_snapshot_from_ru}=${False}
        ...         ${collect_ru_console_log}=${False}

    Sleep    60s    reason=Wait for the restart procedure to begin after restore swconfig (UUF test teardown)
    gnbbbu.connect    force=${True}    timeout=${60}    reconnect_attempts=${3}

    Pararell Postconditions     collect_syslog=${collect_syslog}
    ...                         collect_snapshot_from_ru=${collect_snapshot_from_ru}
    ...                         collect_ru_console_log=${collect_ru_console_log}

    Run Keyword If Test Failed      Restore gNB Configuration After Test
    ...                             restore_only_if_not_onair=${restore_only_if_not_onair}
    gnbbbu.disconnect    bts_id=0
    gnbbbu.disconnect    bts_id=1
