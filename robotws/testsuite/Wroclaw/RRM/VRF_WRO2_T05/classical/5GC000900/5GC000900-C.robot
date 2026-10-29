*** Settings ***
Documentation
...  author: Sebastian Mikos
...  contact: sebastian.mikos@nokia.com
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC001348/resources/resources.robot


*** Variables ***
${tput_DL_bandwith_900C}     10Mbits/sec
${tput_UL_bandwith_900C}     2MBits/sec
${tput_deviation}       15%
${tput_duration_900C}        300s
${Packet_Size}          1200

*** Keywords ***
[1]5GC000900-C_30_Successful_NSA_and_SA_calls_setup_in_NSA+SA_cell
    [Documentation]  The purpose of this test is to verify that gNB can handle NSA and SA users simultaneously
    ...              when cell is operating in mixed mode [1]
    Run Keyword And Ignore Error  Check adb devices
    Attach UE NSA For test
    Attach UE SA For test
    Start ULDL UDP SA   35Mbits/sec   15MBits/sec   300s  True
    Start ULDL UDP NSA    35Mbits/sec   15MBits/sec   300s  True
    Verify ULDL UDP SA    35Mbits/sec   15MBits/sec
    Verify ULDL UDP NSA   35Mbits/sec   15MBits/sec

[1]5GC000900-C_32_Unsuccessful_SA_call_due_to_user_limit
    [Documentation]  The purpose of this test is to verify that admission control functionality for user limit on gNB
    ...              is working as designed when cell is operating in mixed mode
    Set AT command to MTK   SA
    Set NRCELL gNB maxNum parameters  2  0  2  2
    Wait until keyword succeeds    10min    1min    Verify all cells are onair with admin
    Attach UE SA For test
    Attach UE NSA For test
    ${result_SA_NSA_attach}  Run Keyword And Return Status  Attach UE SA NSA For test
    should be equal as strings    ${result_SA_NSA_attach}    False
    [Teardown]     Run keywords
    ...     Set NRCELL gNB maxNum parameters  250  250  250  250   AND
    ...     Wait until keyword succeeds    20min    1min    Verify all cells are onair with admin

[1]5GC000900-C_33_Handling_of_NSA_and_SA_users_served_by_NSA+SA_cell_in_case_of_X2_link_failure
    [Documentation]  The purpose of this test is to verify that gNB can handle NSA and SA users simultaneously
    ...              when cell is operating in mixed mode [1]
    wait until keyword succeeds   20min   1min   Verify all cells are onair with admin
    Connect to LTE
    Attach UE SA For test
    Start ULDL UDP SA   ${tput_DL_bandwith_900C}   ${tput_UL_bandwith_900C}   ${tput_duration_900C}
    Set AT command to MTK    SA
    Attach UE SA_NSA For test
    Start ULDL UDP SA_NSA   ${tput_DL_bandwith_900C}   ${tput_UL_bandwith_900C}   ${tput_duration_900C}
    Attach UE NSA For test
    Start ULDL UDP NSA   ${tput_DL_bandwith_900C}   ${tput_UL_bandwith_900C}   ${tput_duration_900C}
    Get X2 IP from LTE side
    Break X2 Connection without reset site
    sleep  30s
    ${result_SA}  Run Keyword And Return Status  Verify ULDL UDP SA   ${tput_DL_bandwith_900C}   ${tput_UL_bandwith_900C}
    should be equal as strings    ${result_SA}    True
    ${result_SA_NSA}  Run Keyword And Return Status  Verify ULDL UDP SA_NSA   ${tput_DL_bandwith_900C}   ${tput_UL_bandwith_900C}
    should be equal as strings    ${result_SA_NSA}    True
    ${result_NSA}  Run Keyword And Return Status  Verify ULDL UDP NSA   ${tput_DL_bandwith_900C}   ${tput_UL_bandwith_900C}
    should be equal as strings    ${result_NSA}    False
    [Teardown]    Run keyword
    ...           Bring Up X2 Connection

[1]5GC000900-C_34_Handling_of_NSA_and_SA_users_served_by_NSA+SA_cell_in_case_of_NG_link_failure
    [Documentation]  The purpose of this test is to verify that gNB can handle NSA and SA users simultaneously
    ...              in case of cell removal event.
    wait until keyword succeeds   20x   10s   X2-C is available
    wait until keyword succeeds   20x   10s   NG-C is available
    Set attenuation and check  lines=${lines_LTE_157}   value=90
    Set AT command to MTK   SA
    Attach UE SA For test
    Start ULDL UDP SA   ${tput_DL_bandwith_900C}   ${tput_UL_bandwith_900C}   400s
    Attach UE SA_NSA For test
    Start ULDL UDP SA_NSA   ${tput_DL_bandwith_900C}   ${tput_UL_bandwith_900C}   400s
    Log to console  try to break AMF
    Break AMF connection without reset site
    Attach UE NSA For test
    Start ULDL UDP NSA   ${tput_DL_bandwith_900C}   ${tput_UL_bandwith_900C}   400s
    wait until keyword succeeds   20x   30s   NG-C is available    status=Inactive
    ${result_SA}  Run Keyword And Return Status  Verify ULDL UDP SA   ${tput_DL_bandwith_900C}   ${tput_UL_bandwith_900C}
    should be equal as strings    ${result_SA}    False
    ${result_SA_NSA}  Run Keyword And Return Status  Verify ULDL UDP SA_NSA   ${tput_DL_bandwith_900C}   ${tput_UL_bandwith_900C}
    should be equal as strings    ${result_SA_NSA}    False
    ${result_NSA}  Run Keyword And Return Status  Verify ULDL UDP NSA   ${tput_DL_bandwith_900C}   ${tput_UL_bandwith_900C}
    should be equal as strings    ${result_NSA}    True
    [Teardown]     Run keywords
    ...            Bring Up AMF by iptables

[1]5GC000900-C_31_Unsuccessful_NSA_call_due_to_user_limit
    [Documentation]  The purpose of this test is to verify that admission control functionality for user limit on gNB
    ...              is working as designed when cell is operating in mixed mode
    Set AT command to MTK   NSA
    Set NRCELL gNB maxNum parameters  2  2  0  2
    Wait until keyword succeeds    10min    1min    Verify all cells are onair with admin
    Attach UE SA For test
    Attach UE NSA For test
    ${result_SA_NSA_attach}  Run Keyword And Return Status  Attach UE SA NSA For test
    should be equal as strings    ${result_SA_NSA_attach}    False
    [Teardown]     Run keywords
    ...     Set NRCELL gNB maxNum parameters  250  250  250  250  AND
    ...     Wait until keyword succeeds    20min    1min    Verify all cells are onair with admin


[1]5GC000900-C_41_Handling_of_NSA_and_SA_users_after_NSA+SA_cell_deletion
    [Documentation]  The purpose of this test is to verify that gNB can handle NSA and SA users simultaneously in case
    ...               of cell removal event
    Attach UE SA For test
    Attach UE NSA For test
    Start ULDL UDP SA   ${tput_DL_bandwith_900C}   ${tput_UL_bandwith_900C}   ${tput_duration_900C}
    Start ULDL UDP NSA   ${tput_DL_bandwith_900C}   ${tput_UL_bandwith_900C}   ${tput_duration_900C}
    # Remove cell   cell_id=1  #working on final solution
    ${result_SA}  Run Keyword And Return Status  Verify ULDL UDP SA   ${tput_DL_bandwith_900C}   ${tput_UL_bandwith_900C}
    should be equal as strings    ${result_SA}    False
    ${result_NSA}  Run Keyword And Return Status  Verify ULDL UDP NSA   ${tput_DL_bandwith_900C}   ${tput_UL_bandwith_900C}
    should be equal as strings    ${result_NSA}    False
