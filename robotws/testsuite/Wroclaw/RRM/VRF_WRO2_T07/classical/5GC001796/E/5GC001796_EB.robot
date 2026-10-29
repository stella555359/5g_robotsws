*** Settings ***
Documentation
...   author: Maciej Dzimira
...   contact: maciej.dzimira@nokia.com
...   This is the TESTSUITE file for feature 5GC001796_EB

Library         testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/btslog.py    WITH NAME    1796_eb_btslog
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/swconfig.py
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC001796/E/resources/keywords_1796_EB.robot

Suite Setup      Run Keywords
...              initialise_attenuator                      AND
...              prepare_swconfig    custom_swconfig_flags=${syslog_ul_prints_flags}

Test Setup       Run Keywords
...              nullify_attenuation_on_all_ports    AND
...              start_btslog_on_local_machine

Test Teardown    Run Keywords
...              nullify_attenuation_on_all_ports    AND
...              stop_and_collect_btslog


*** Test Cases ***
[1]5GC001796_EB_TC42_ULDL_LA_64QAM-table_MIMO_4x4_PTRS-ON_MaxTput_20min_BW-20MHz_SA
    [Documentation]    Check max troughput and its stability in DL and UL
    [1]5GC001796_EB_TC42_ULDL_LA_64QAM-table_MIMO_4x4_PTRS-ON_MaxTput_20min_BW-20MHz_SA


[1]5GC001796_EB_TC36_UL_LA_64QAM-table_PTRS-ON_from_Edge_to_Near_Cell_radio_condition_NIDD_non_defaultBW-20MHz_SA
    [Documentation]    Check good table mapping
    [1]5GC001796_EB_TC36_UL_LA_64QAM-table_PTRS-ON_from_Edge_to_Near_Cell_radio_condition_NIDD_non_defaultBW-20MHz_SA


[1]5GC001796_EB_TC46_UL_LA_64QAM-table_PTRS-ON_from_Near_to_Edge_Cell_radio_condition_SingleTX_BW-20MHz_SA
    [Documentation]    Check good table mapping
    [1]5GC001796_EB_TC46_UL_LA_64QAM-table_PTRS-ON_from_Near_to_Edge_Cell_radio_condition_SingleTX_BW-20MHz_SA


[1]5GC001796_EB_TC115_DL_LA_256QAM-table_MIMO_4x4_PTRS-OFF_from_Near_to_Edge_Cell_radio_condition_NIDD_non_default_BW-20MHz_SA
    [Documentation]    Check good table mapping
    [1]5GC001796_EB_TC115_DL_LA_256QAM-table_MIMO_4x4_PTRS-OFF_from_Near_to_Edge_Cell_radio_condition_NIDD_non_default_BW-20MHz_SA
