*** Settings ***

Documentation
...    Author: Michal Gorski
...    Contact: michal.gorski@nokia.com
...    Documentation present in QC

Library        ta_logcollector
Library        ta5g_pm_counters
Library        resources/CB008009_resources_time_counters.py

Resource       resources/CB008009_resources.robot
Resource       resources/CB008009_counters.robot
Resource     ../resources/common_configuration.robot

Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    SKIPRUN
...           CLOUD_5G_I_LO_AP_LO
...           VARIANT_SA+NSA_FS_ECPRI_MMWV_TDD

Suite Setup       Setup test environment
Test Teardown    Send Configuration ID To Scout
Suite Teardown    Clean suite environment

*** Variables ***
${scfc}=                       ${CURDIR}/config/TDD_mmW_eCPRI_LO_AP_LO/scfc_TDD_NSA_LO_AP_LO_2AWEUA_2cells.xml
${ap_xml}=                     ${CURDIR}/config/TDD_mmW_eCPRI_LO_AP_LO/iphy_TDD_NSA_LO_AP_LO_2AWEUA_2cells.xml
${lua_cfg_file}=               ${CURDIR}/config/basic_setup_TDD_FR2.cfg
${single_UE_iperf_log}=        iperf_client_single_ue.log
${multiple_UEs_iperf_log}=     iperf_client_multi_ues.log
${percent_error_margin}=       5

@{counters_to_report}=         @{EMPTY}

*** Test Cases ***
CB008009-A_DL_Throughput_Time_counter_modification_without_time_calculation_NSA
    [Setup]    Prepare test environment

    Attach UE  UE_ID=11
    SgNB Addition  UE_ID=11  CELL_ID=1
    Start DL data traffic for single UE
    Verify counters for single UE

    Attach 3 additional UEs and start gNB Addition Procedure
    Start DL data traffic for multiple UEs
    Verify counters for multiple UEs

    [Teardown]    Detach NR-UEs and deconfigure gNB and clear environment

*** Keywords ***
Prepare test environment
    Configure NSA PMQAP profiles
    Set feature flag NRBTS-1/thpTimeCalc to disabled
    Set parameter in all objects to value    parameter=nsaDrbParam
    ...                                      nested_param=dlDataSplitMode
    ...                                      value=dlOverX2U
    Wait for next full PM interval

Start DL data traffic for single UE
    Start DL data traffic session for single UE with 125Mpbs throughput
    Start DL data traffic session for single UE with 125Mpbs throughput
    Start DL data traffic session for single UE with 125Mpbs throughput
    Start DL data traffic session for single UE with 125Mpbs throughput
    Start DL data traffic session for single UE with 125Mpbs throughput
    Start DL data traffic session for single UE with 125Mpbs throughput

Start DL data traffic session for single UE with ${tput}Mpbs throughput
    Start throughput on single UE    ue=UE11
    ...                              duration=30
    ...                              tput=${tput}m
    ...                              tput_type=NSA_DL
    ...                              client_logfile=${single_UE_iperf_log}

Start DL data traffic for multiple UEs
    Start throughput on three UEs    tput1=125m
    ...                              tput2=125m
    ...                              tput3=125m
    ...                              duration=90
    ...                              tput_type=NSA_DL
    ...                              client_logfile=${multiple_UEs_iperf_log}

Verify counters for single UE
    Verify counters based on ${single_UE_iperf_log}

Verify counters for multiple UEs
    Verify counters based on ${multiple_UEs_iperf_log}

Verify counters based on ${iperf_log}
    Read PM counter values
    ${expected_values}=    Get expected values
    ...                    iperf_log=${OUTPUT_DIR}/${iperf_log}

    Verify DL_PDCP_TIME_UE_TPUT is equal to ${expected_values}[total_time]
    Verify DL_PDCP_TIME_UE_TPUT_PMQAP is equal to ${expected_values}[total_time]
    Verify DL_PDCP_TIME_UE_TPUT_QOS_09 is equal to ${expected_values}[total_time]

    Verify DL_PDCP_VOL_UE_TPUT_PMQAP is equal to ${expected_values}[total_volume]
    Verify DL_PDCP_VOL_UE_TPUT_QOS_09 is equal to ${expected_values}[total_volume]
    Verify DL_PDCP_VOL_UE_TPUT_5G_QOS_09 is equal to 0
    Verify DL_PDCP_VOL_UE_TPUT_LTE_QOS_09 is equal to ${expected_values}[total_volume]

    Verify MAX_DL_PDCP_BURST_TPUT is equal to ${expected_values}[max_throughput]
    Verify MAX_DL_PDCP_BURST_TPUT_5GLEG is equal to 0
    Verify MAX_DL_PDCP_BURST_TPUT_LTELEG is equal to ${expected_values}[max_throughput]

    Verify QoS counters other than QoS_09 are not incremented

    Report counters

Read PM counter values
    ${counter_file}=    Wait for next PM interval and get counters

    Set test variable    ${counter_file}

    ${counter_values}=    Get values of specific counters
    ...                   counter_file_path=${counter_file}
    ...                   counter_ids=${counter_ids}
    ...                   local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1

    Set test variable    ${counter_values}

Verify ${counter_name} is equal to ${expected_value}
    Run keyword and continue on failure
    ...    Check counter value
    ...        counter_id=${counter_ids}[${counter_name}]
    ...        pm_counters_values=${counter_values}[${counter_name}]
    ...        expected_value=${expected_value}
    ...        margin=${percent_error_margin}

Verify QoS counters other than QoS_09 are not incremented
    FOR  ${i}  IN  01  02  03  04  05  06  07  08  10  11  12  13  14  15  16  17  18  19  20
        Verify DL_PDCP_TIME_UE_TPUT_QOS_${i} is equal to 0
        Verify DL_PDCP_VOL_UE_TPUT_QOS_${i} is equal to 0
        Verify DL_PDCP_VOL_UE_TPUT_5G_QOS_${i} is equal to 0
        Verify DL_PDCP_VOL_UE_TPUT_LTE_QOS_${i} is equal to 0
    END

Report counters
    Get counters value and report to RP
    ...    counters=${counters_to_report}
    ...    localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    filepath=${counter_file}