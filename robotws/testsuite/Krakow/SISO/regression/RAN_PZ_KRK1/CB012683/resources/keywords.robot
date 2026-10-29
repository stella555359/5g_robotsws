*** Settings ***
Documentation
...   Keywords for call for CB012683
...   author: Julia Luszcz
...   author/contact: julia.luszcz@nokia.com

Library     taf.rfrl.utilities.logger.custom_logger                   WITH NAME    custom_logger
Library     taf.rfrl.bts.devices.du.commissioning.EnbCommissioning    WITH NAME    enbscf
Library     taf.ue                                                    WITH NAME    ue
Library     taf.config.scf.interface.scf
Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/ue/robot/REAL_UE.robot


*** Keywords ***
Change defaultLnRelGnbCellId on eNB
    [Arguments]    ${defaultLnRelGnbCellId_value}
    enbscf.perform_configuration_parameter_recommissioning    dist_name=MRBTS-{}/LNBTS-{}/LNCEL-1
    ...                                                       parameter=defaultLnRelGnbCellId
    ...                                                       operation=update
    ...                                                       value=${defaultLnRelGnbCellId_value}

Verify L3 call
    [Arguments]       ${sectors_parameters}      ${timeout_reboot_ue}

    FOR    ${sector_parameters}    IN    @{sectors_parameters}
        custom_logger.Log banner to Console     Perform call ${sector_parameters}[sector_id] sector
        custom_logger.Log info to Console       Sector details: ${sector_parameters}[sector_name]
        Change defaultLnRelGnbCellId on eNB     defaultLnRelGnbCellId_value=${sector_parameters}[defaultLnRelGnbCellId_value]
        ue.Reboot UE                            UE      timeout=${timeout_reboot_ue}
        Verify L3 Call Data Transfer DL&UL      duration=${sector_parameters}[duration]
        ...                                     tput_dl=${sector_parameters}[tput_dl]
        ...                                     tput_ul=${sector_parameters}[tput_ul]
        ...                                     protocol=${sector_parameters}[protocol]
        ...                                     deviation_dl=${sector_parameters}[deviation_dl]
        ...                                     deviation_ul=${sector_parameters}[deviation_ul]
        ...                                     parallel_streams_dl=${sector_parameters}[parallel_streams_dl]
        ...                                     parallel_streams_ul=${sector_parameters}[parallel_streams_ul]
        ...                                     size_packet_dl=${sector_parameters}[size_packet_dl]
        ...                                     size_packet_ul=${sector_parameters}[size_packet_ul]
        ...                                     linux_congestion_dl=${sector_parameters}[linux_congestion_dl]
    END

Custom Suite Setup
    Common Suite Setup With OnAir Test Line Preparation
    ...                         increase_timeout_for_update_sw=${1800}
    ...                         list_of_additional_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}
    ...                         swconfig_from_path=${SWCONFIG_PATH}

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
