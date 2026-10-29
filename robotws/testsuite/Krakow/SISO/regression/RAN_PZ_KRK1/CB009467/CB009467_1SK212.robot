*** Settings ***
Documentation
...   Test suite for regression testing of feature CB009467
...   author: Michal Haszko, Tomasz Krol
...   contact: michal.haszko@nokia.com, tomasz.krol@nokia.com


Library         taf.rfrl.bts.devices.du.pm_counters.ComparePmCounters    WITH NAME       cpmc
Library         ./resources/GnbCellCustomKeywords.py
Library         ./resources/UeAttachDetachObserver.py
Library         taf/rfrl/utilities/logger/custom_logger.py
Library         ./resources/counter_keywords.py
Resource        taf/rfrl/ue/robot/REAL_UE.robot
Resource        taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables       taf/rfrl/procedures/resources/python/common_allowed_alarms.py



Force Tags        CA_VRF_KRK    RF50

Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...               prefix_tag=8CC_NSA
...               list_of_additional_allowed_alarms=@{ADDITIONAL_ALLOWED_ALARMS}

Suite Teardown    Common Suite Teardown

Test Setup        Custom Test Precondition with Require UE
Test Teardown     Common Postconditions With Watching Alarms and Restore Configuration If Test Failed

*** Variables ***
${ENABLE_RACH_OBSERVER}                 ${False}
${SHOULD_BE_REPORTED}=                  True
@{CRITICAL_FAULTS}=                     0010  0016  1806  1868  4341  4352  4383
${QC_DOMAIN}=                           MN_RAN
${QC_PROJECT}=                          RAN_VRF
@{CUSTOM_ALARMS}=                       ${None}
${COLLECT_LOGS_DURING_DATA_TRANSFER}    ${False}
@{ADDITIONAL_ALLOWED_ALARMS}	        Create List
...                                     Wifi Enabled Alarm
...                                     NRRELNotConfiguredA3A5
...                                     GPS receiver alarm: firmware upgrade ongoing
...                                     PPS reference missing

# TPUT VARIABLES
${tput_duration}                        60s
${tput_dl}                              3000 Mbits/sec
${tput_ul}                              400 Mbits/sec
${tput_protocol}                        UDP
${tput_parallel_streams_dl}             8
${ul_size_packet}                       1350B


*** Test Cases ***
[1][1.0] CB009467_W_003_NSA_DL_UL_peak_Tput_FR2_NR_8CCDL_4CCUL
    custom_logger.Log Info to Console    Start DL and UL NSA traffic for ${tput_duration}
    Verify L3 Call Data Transfer DL&UL
    ...                                 duration=${tput_duration}
    ...                                 tput_dl=${tput_dl}
    ...                                 tput_ul=${tput_ul}
    ...                                 protocol=${tput_protocol}
    ...                                 parallel_streams_dl=${tput_parallel_streams_dl}
    ...                                 size_packet_ul=${ul_size_packet}


[1][1.0] CB009469_F_06_8CCDL_4CCUL_UL_counters
    gnbcounter.Wait for Next PM Period    interval=5min    delay=${120}
    ${counters_before_tput}    Get UL Counters

    Start UE Attach and Detach Observer
    Verify L3 Call One Way Data Transfer
    ...                                   direction=UL
    ...                                   duration=30s
    ...                                   tput=${tput_ul}
    ...                                   protocol=${tput_protocol}
    ...                                   size_packet=${ul_size_packet}

    ${attach_detach_diff_time}      Get Attach Detach diff Time in Seconds

    gnbcounter.Wait for Next PM Period    interval=5min    delay=${120}
    ${counters_after_tput}    Get UL Counters
    ${diff_counters}          cpmc.Calculate PM Counter Diff    ${counters_before_tput}     ${counters_after_tput}

    Run Keyword And Continue On Failure    Verify that UL 3 SCell Configration Counters are Updated  ${diff_counters}
    Run Keyword And Continue On Failure    Verify that UL SCell Configration Counters are Updated    ${diff_counters}    ${attach_detach_diff_time}
    Run Keyword And Continue On Failure    Verify that UL PSCell Act Counters are Updated            ${diff_counters}    ${attach_detach_diff_time}
    Run Keyword And Continue On Failure    Verify that UL 3 SCells Act Counters are Updated          ${diff_counters}    ${attach_detach_diff_time}
    Run Keyword And Continue On Failure    Verify that UL 3 SCells Act Max Counter is Updated        ${diff_counters}


[1][1.0] CB009469_F_07_8CCDL_4CCUL_DL_counters
    gnbcounter.Wait for Next PM Period    interval=5min    delay=${120}
    ${counters_before_tput}    Get DL Counters

    Start UE Attach and Detach Observer
    Verify L3 Call One Way Data Transfer
    ...                                   direction=DL
    ...                                   duration=30s
    ...                                   tput=${tput_dl}
    ...                                   protocol=${tput_protocol}
    ...                                   parallel_streams=${tput_parallel_streams_dl}
    ${attach_detach_diff_time}      Get Attach Detach diff Time in Seconds

    gnbcounter.Wait for Next PM Period    interval=5min    delay=${120}
    ${counters_after_tput}    Get DL Counters
    ${diff_counters}          cpmc.Calculate PM Counter Diff    ${counters_before_tput}     ${counters_after_tput}

    Run Keyword And Continue On Failure    Verify that DL 7 SCell Configration Counters are Updated  ${diff_counters}
    Run Keyword And Continue On Failure    Verify that DL SCell Configration Counters are Updated    ${diff_counters}    ${attach_detach_diff_time}
    Run Keyword And Continue On Failure    Verify that DL PSCell Act Counters are Updated            ${diff_counters}    ${attach_detach_diff_time}
    Run Keyword And Continue On Failure    Verify that DL 7 SCells Act Counters are Updated          ${diff_counters}    ${attach_detach_diff_time}
    Run Keyword And Continue On Failure    Verify that DL 7 SCells Act Max Counter is Updated        ${diff_counters}


*** Keywords ***
Custom Test Precondition with Require UE
    REAL_UE.Prepare Ue for L3 Call
    Common Preconditions With Watching Alarms

Block all SA cells
    custom_logger.Log Info to Console    Block all SA cells
    FOR   ${cell_id}    IN    @{SA_CELL_IDS}
        gnbcell.Block Cell    cell_id=${cell_id}
    END

Block all NSA cells
    custom_logger.Log Info to Console    Block all NSA cells
    FOR   ${cell_id}    IN    @{NSA_CELL_IDS}
        gnbcell.Block Cell    cell_id=${cell_id}
    END

Unblock all SA cells
    custom_logger.Log Info to Console    Unblock all SA cells
    FOR   ${cell_id}    IN    @{SA_CELL_IDS}
        gnbcell.Unblock Cell    cell_id=${cell_id}
    END

Unblock all NSA cells
    custom_logger.Log Info to Console    Unblock all NSA cells
    FOR   ${cell_id}    IN    @{NSA_CELL_IDS}
        gnbcell.Unblock Cell    cell_id=${cell_id}
    END
