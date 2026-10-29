*** Settings ***
Documentation
...  author: Jakub Migdalek
...  contact: jakub.migdalek@nokia.com
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC001348/resources/resources.robot


*** Variables ***
${tput_DL_bandwith}     30Mbits/sec
${tput_UL_bandwith}     10MBits/sec
${tput_deviation}       10%
${tput_duration}        450s
${Packet_Size}          1200
${resource_path_2197-M}        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002197/resources


*** Keywords ***
[1]5GC002197-M_Handling_of_NSA_and_SA_users_served_by_NSA+SA_cell_with_NIDD_based_PDCCH_configuration_enabled_in_case_of_NG_and_X2_links_failure
    [Documentation]  The purpose of this test is to verify that gNB can handle NSA and SA users simultaneously
	...    while operating in NSA+SA mode when dynamic PDCCH configuration is enabled
    Commission with scf file    ${resource_path_2197-M}/SCF_basic.xml    is_pdl_checking_needed=${True}
    Wait until keyword succeeds    20 min    1 min    Verify all cells are onair with admin
    Connect to LTE
    Run Keyword And Ignore Error  Check adb devices
    Set AT command to MTK   SA
    Attach UE NSA For test
    Start ULDL UDP NSA    30MBits/sec    10MBits/sec    450s
    Attach UE SA For test
    Start ULDL UDP SA    30MBits/sec    10MBits/sec    450s
    ${result_SA2}  Run Keyword And Return Status  Attach UE SA_NSA For test
    should be equal as strings    ${result_SA2}    False
    Get X2 IP from LTE side
    Break X2 Connection without reset site
    sleep  30s
    ${result_NSA}  Run Keyword And Return Status  Verify ULDL UDP NSA
    should be equal as strings    ${result_NSA}    False
    Break AMF connection without reset site
    sleep  30s
    ${result_SA}  Run Keyword And Return Status  Verify ULDL UDP SA
    should be equal as strings    ${result_SA}    False
    Run Keyword And Ignore Error    Bring Up X2 Connection
    [Teardown]     Run keyword
    ...            Reset and wait OnAir
