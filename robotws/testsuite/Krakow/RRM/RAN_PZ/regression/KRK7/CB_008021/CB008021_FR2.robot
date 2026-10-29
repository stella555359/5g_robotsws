*** Settings ***
Documentation
...    Test suite for regression testing for feature CB008021-FR2
...    authors: Lubomir Krzeminski, Jakub Bialon
...    maintainer: Lubomir Krzeminski
...    group: RAN_PZ_KRK_SG_7
...    contact: lubomir.krzeminski@nokia.com

Library    DateTime
Library    OperatingSystem
Library    Process
Library    taf.nms.netact
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.ue
Library    taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME    gnbcell
Library    on_air_tl_preparation.testline_preparation
Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    resources/KeywordsFR2.robot
Resource    resources/Variables.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup    Run Keywords    Common Suite Setup With OnAir Test Line Preparation
...                                swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...                                increase_timeout_for_update_sw=1800
...                                increase_time_for_checking_radios=2100    AND
...                            Suite Precondition    AND
...                            Install pandas with pip
Suite Teardown    Run Keywords    Suite Postcondition    AND    Common Suite Teardown

Force Tags    STATE_SW_UPLOADED
...           CRT
...           CLOUD_5G_CLASSICAL_ANDROID_ASIB_ABIO_AWEUB_ENB_NETACT
...           RAN_5G__WITH__SBTS00
...           RAN_5G__WITH__SBTS22R4


*** Test Cases ***
[1][2.0] CB008021-5G-A-08_Verification_NetAct_filtering_for_PM_counters_after_few_hours
    [Setup]    Run Keywords    Common Preconditions With Watching Alarms    AND
    ...                        Prepare before TC
    ${cell_list}    gnbcell.Get All Cells Id
    FOR     ${cell}    IN    @{cell_list}
        coam.perform_parameter_recommissioning    dist_name=${cell_dist_name}${cell}
        ...                                       parameter=${adjustPrach_name}
        ...                                       value=30
        ...                                       operation=update
        ...                                       skip_parameter_relation_errors=${True}
    END
    Sleep    ${netact_measurement_hours}h
    ${counter_dic_list}=     get_netact_pm_counters_nrulrip    ${netact_measurement_hours}
    Should Be True    ${counter_dic_list}
    ${result}=    tools.verify_netact_pm_counters    ${counter_dic_list}    ${cell_list}
    Should Be True    ${result}
    [Teardown]    Run Keywords    Cleanup After TC    AND
    ...                           Common Postconditions With Watching Alarms


[1][2.0] CB008021-5G-A-09_Verification_PM_counters_for_ghost_preambles_which_lead_to_DTX_or_DTXes
    [Setup]    Run Keywords    Common Preconditions With Watching Alarms    AND
    ...                        Prepare before TC    AND
    ...                        Get UE Config
    ${cell_list}    gnbcell.Get All Cells Id
    FOR     ${cell}    IN    @{cell_list}
        coam.perform_parameter_recommissioning    dist_name=${cell_dist_name}${cell}
        ...                                       parameter=msg1FrequencyStart
        ...                                       value=0
        ...                                       operation=update
        ...                                       skip_parameter_relation_errors=${True}
    END

    coam.perform_parameter_recommissioning    dist_name=${cell_dist_name}1
    ...                                       parameter=${adjustPrach_name}
    ...                                       value=-30
    ...                                       operation=update
    ...                                       skip_parameter_relation_errors=${True}
    FOR     ${cell}    IN    @{not_tested_cells}
        coam.perform_parameter_recommissioning    dist_name=${cell_dist_name}${cell}
        ...                                       parameter=${adjustPrach_name}
        ...                                       value=30
        ...                                       operation=update
        ...                                       skip_parameter_relation_errors=${True}
    END
    ${WEB_time_stamp}=    tools.schedule_delay    delay=3.5
    ${actNrUlRip}=    Set Variable    enabledWithoutPRACH_PUCCH_F1
    bipcollector.Start Bip Trace Log Capturing    mirroring_script_params=${mirroring_script_params}
    Sleep     500s     Sleeping to collect 5min counter interval and neighbour packets
    bipcollector.Stop Bip Trace Log Capturing
    ${bip_log_path}=    KeywordsFR2.Download and Process BIP Log    asfn_step=${80}
    ...                                                             WEB_time_stamp=${WEB_time_stamp}
    ...                                                             puch_mode=short
    ...                                                             tx_tech=TDD
    ...                                                             msg1_freq_start=0
    ...                                                             actNrUlRip=${actNrUlRip}
    ${threshold}    Set Variable    ${3}
    ${pm_counters_path}=    KeywordsFR2.Download Pm Counters    ${WEB_time_stamp}    ${bts_connection}
    Compare pm_counters with BIP_log    ${pm_counters_path}    ${bip_log_path}     ${threshold}
    [Teardown]    Run Keywords    Cleanup after TC    AND
    ...                           Test DTX Teardown    AND
    ...                           Common Postconditions With Watching Alarms

