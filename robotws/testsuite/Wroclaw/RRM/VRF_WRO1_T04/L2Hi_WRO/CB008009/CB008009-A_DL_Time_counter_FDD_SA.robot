*** Settings ***

Documentation
...    Author: Michal Gorski
...    Contact: michal.gorski@nokia.com
...    Documentation present in QC

Library        ta_logcollector
Library        ta5g_pm_counters
Library        resources/CB008009_resources_time_counters.py
Resource       ../resources/common_configuration.robot

Resource       resources/CB008009_resources.robot
Resource       resources/CB008009_counters.robot

Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_FDD    SBTS00
...           CLOUD_5G_I_LO_AP_LO
...           VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Suite Setup       Setup test environment
Suite Teardown    Clean suite environment

*** Variables ***
${scfc}=                       ${CURDIR}/config/FDD_CPRI_LO_AP_LO/scfc_FDD_SANSA_LO_AP_LO_2AWEUA_2cells.xml
${ap_xml}=                     ${CURDIR}/config/FDD_CPRI_LO_AP_LO/iphy_FDD_SANSA_LO_AP_LO_2AWEUA_2cells.xml
${lua_cfg_file}=               ${CURDIR}/config/basic_setup_FDD.cfg
${single_UE_iperf_log}=        iperf_client_single_ue.log
${multiple_UEs_iperf_log}=     iperf_client_multi_ues.log
${percent_error_margin}=       5

@{counters_to_report}=         @{counters_to_report_DL_Time_FDD_SA}

*** Test Cases ***
CB008009-A_DL_Throughput_Time_counter_modification_with_time_calculation_SA
    [Setup]    Prepare test environment

    Register UE  UE_ID=1  CELL_ID=1
    Establish PDU session  UE_ID=1
    Start DL data traffic for single UE
    Verify counters for single UE

    Register 3 additional UEs and establish PDUs sessions
    Start DL data traffic for multiple UEs
    Verify counters for multiple UEs

    [Teardown]    Run Keywords    Deregister UEs and clear up test environment
    ...    AND    Send Configuration ID To Scout

*** Keywords ***
Prepare test environment
    Configure SA PMQAP profiles
    Wait for next full PM interval

Start DL data traffic for single UE
    Start DL data traffic session for single UE with 140Mpbs throughput
    Start DL data traffic session for single UE with 145Mpbs throughput
    Start DL data traffic session for single UE with 150Mpbs throughput
    Start DL data traffic session for single UE with 150Mpbs throughput
    Start DL data traffic session for single UE with 145Mpbs throughput
    Start DL data traffic session for single UE with 140Mpbs throughput

Start DL data traffic session for single UE with ${tput}Mpbs throughput
    Start throughput on single UE    ue=UE1
    ...                              duration=30
    ...                              tput=${tput}m
    ...                              tput_type=SA_DL
    ...                              client_logfile=${single_UE_iperf_log}

Start DL data traffic for multiple UEs
    Start throughput on three UEs    tput1=40m
    ...                              tput2=50m
    ...                              tput3=60m
    ...                              duration=90
    ...                              tput_type=SA_DL
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
    Verify DL_PDCP_TIME_UE_TPUT_QOS_06 is equal to ${expected_values}[total_time]

    Verify DL_PDCP_VOL_UE_TPUT_PMQAP is equal to ${expected_values}[total_volume]
    Verify DL_PDCP_VOL_UE_TPUT_QOS_06 is equal to ${expected_values}[total_volume]
    Verify DL_PDCP_VOL_UE_TPUT_5G_QOS_06 is equal to ${expected_values}[total_volume]
    Verify DL_PDCP_VOL_UE_TPUT_LTE_QOS_06 is equal to 0

    Verify MAX_DL_PDCP_BURST_TPUT is equal to ${expected_values}[max_throughput]
    Verify MAX_DL_PDCP_BURST_TPUT_5GLEG is equal to ${expected_values}[max_throughput]
    Verify MAX_DL_PDCP_BURST_TPUT_LTELEG is equal to 0

    Verify QoS counters other than QoS_06 are not incremented

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

Verify QoS counters other than QoS_06 are not incremented
    FOR  ${i}  IN  01  02  03  04  05  07  08  09  10  11  12  13  14  15  16  17  18  19  20
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