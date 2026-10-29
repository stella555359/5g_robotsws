*** Settings ***
Documentation  This suite contains PM__NR_counters_are_available_on_ram_disk_versus_NIDD_counter_list TC

Resource  ../test_resources/PM__NR_counters_are_available_on_ram_disk_versus_NIDD_counter_list.robot


*** Test Cases ***
PM__NR_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Setup]  TC Setup
    TC__PM__NR_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Teardown]  TC Teardown
