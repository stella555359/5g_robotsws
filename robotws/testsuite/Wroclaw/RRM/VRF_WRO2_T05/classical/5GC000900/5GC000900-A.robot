*** Settings ***
Documentation
...  author: Piotr Szlegel
...  contact: piotr.szlegel@nokia.com
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC001348/resources/resources.robot

*** Variables ***
${tput_DL_bandwith_900A}     10Mbits/sec
${tput_UL_bandwith_900A}     2MBits/sec
${tput_deviation}       10%
${tput_duration_900A}        300s
${Packet_Size}          1200
${resource_path_900A}    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000900/resources
${subfeature_name900A}           5GC000900-A

*** Keywords ***

[1]5GC000900-A_01_Successful_NSA_and_SA_cells_setup
    [Documentation]    This test case checks if BTS can start with 1 cell NSA & 1 cell SA.
    Reset and wait OnAir
    wait until keyword succeeds   20min   1min   Verify all cells are onair with admin
    Fail if critical alarms occurs and show other alarms

[1]5GC000900-A_02_Successful_NSA_cell_addition_when_gNB_operating_in_mixed_mode
    [Documentation]    This test case removes NSA cell and then adds this cell with checking
    ...                if any critical error occurs.
    Set diverse cell DepType for all cells    nsa_type=2    sa_type=1
    Run Keyword And Ignore Error  Check adb devices
    Get SCF
    Compare DepType of cells    no_SA_cells=1    no_NSA_cells=2
    Remove cell    cell_id=${NSA_id}
    ${no_cells_removed}       AdminHelper.Get number of cells
    Add cell
    ${no_cells_added}    AdminHelper.Get number of cells
    Evaluate    ${no_cells_added}==${no_cells_removed}+1
    Compare cell DepType    type=NSA    cell_id=${NSA_id}
    Fail if critical alarms occurs and show other alarms

[1]5GC000900-A_03_Successful_SA_cell_addition_when_gNB_is_operating_in_mixed_mode
    [Documentation]    This test case removes SA cell and then adds this cell with checking
    ...                if any critical error occurs.
    # Adjust proper scf to current stream    ${resource_path_900A}    ${subfeature_name900A}
    Wait until keyword succeeds    20 min    1 min      X2-C is available
    Run Keyword And Ignore Error  Check adb devices
    Compare DepType of cells    no_SA_cells=1    no_NSA_cells=2
    Remove cell    cell_id=${SA_id}
    ${no_cells_removed}       AdminHelper.Get number of cells
    Add cell
    ${no_cells_added}    AdminHelper.Get number of cells
    Evaluate    ${no_cells_added}==${no_cells_removed}+1
    Compare cell DepType    type=SA    cell_id=${SA_id}
    Fail if critical alarms occurs and show other alarms

[1]5GC000900-A_09_Successful_NSA_and_SA_calls_setup_when_gNB_is_operating_in_mixed_mode
    [Documentation]    The purpose of this test is to verify that gNB can handle NSA and SA
    ...                users simultaneously while operating in NSA+SA mode.
    wait until keyword succeeds   20x   10s   X2-C is available
    wait until keyword succeeds   20x   10s   NG-C is available
    Run Keyword And Ignore Error  Check adb devices
    Attach UE NSA For test
    Start ULDL UDP NSA   ${tput_DL_bandwith_900A}   ${tput_UL_bandwith_900A}   ${tput_duration_900A}
    Attach UE SA For test
    Start ULDL UDP SA   ${tput_DL_bandwith_900A}   ${tput_UL_bandwith_900A}   ${tput_duration_900A}
    sleep  350s
    Check Data Transfer Is Alive               DT_DL_SA
    Check Data Transfer Is Alive               DT_UL_SA
    Check Data Transfer Is Alive               DT_DL_NSA
    Check Data Transfer Is Alive               DT_UL_NSA
    ${result_SA}  Run Keyword And Return Status  Verify ULDL UDP SA  ${tput_DL_bandwith_900A}   ${tput_UL_bandwith_900A}
    should be equal as strings    ${result_SA}    True
    ${result_NSA}  Run Keyword And Return Status  Verify ULDL UDP NSA  ${tput_DL_bandwith_900A}   ${tput_UL_bandwith_900A}
    should be equal as strings    ${result_NSA}    True
    ${result_DETACH}  Run Keyword And Return Status  Detach UEs Used By Test
    should be equal as strings    ${result_DETACH}    True

[1]5GC000900-A_13_Handling_of_NSA_and_SA_users_in_case_of_NG_link_failure
    [Documentation]    The purpose of this test is to verify that gNB can handle NSA and SA
    ...                users simultaneously while operating in NSA+SA mode.
    verify all cells are onair with admin
    Attach UE NSA For test
    Start ULDL UDP NSA   ${tput_DL_bandwith_900A}   ${tput_UL_bandwith_900A}   ${tput_duration_900A}
    Attach UE SA For test
    Start ULDL UDP SA   ${tput_DL_bandwith_900A}   ${tput_UL_bandwith_900A}   ${tput_duration_900A}
    Break AMF connection without reset site
    sleep   100s
    ${result_SA}  Run Keyword And Return Status  Verify ULDL UDP SA  ${tput_DL_bandwith_900A}   ${tput_UL_bandwith_900A}
    should be equal as strings    ${result_SA}    False
    wait until keyword succeeds   20x   10s   X2-C is available
    ${result_NSA}  Run Keyword And Return Status  Verify ULDL UDP NSA  ${tput_DL_bandwith_900A}   ${tput_UL_bandwith_900A}
    should be equal as strings    ${result_NSA}    True
    [Teardown]     Run keywords
    ...            Reset and Wait OnAir

[1]5GC000900-A_12_Handling_of_NSA_and_SA_users_in_case_of_X2_link_failure
    [Documentation]    The purpose of this test is to verify that gNB can handle NSA and SA
    ...                users simultaneously while operating in NSA+SA mode.
    verify all cells are onair with admin
    Connect to LTE
    Get X2 IP from LTE side
    Attach UE NSA For test
    Start ULDL UDP NSA   ${tput_DL_bandwith_900A}   ${tput_UL_bandwith_900A}   ${tput_duration_900A}
    Attach UE SA For test
    Start ULDL UDP SA   ${tput_DL_bandwith_900A}   ${tput_UL_bandwith_900A}   ${tput_duration_900A}
    Wait until keyword succeeds     10x    15s     Break X2 Connection without Reset Site
    Lock LTE Site
    Sleep  20s
    ${result_SA}  Run Keyword And Return Status  Verify ULDL UDP SA   ${tput_DL_bandwith_900A}   ${tput_UL_bandwith_900A}
    should be equal as strings    ${result_SA}    True
    ${result_NSA}  Run Keyword And Return Status  Verify ULDL UDP NSA   ${tput_DL_bandwith_900A}   ${tput_UL_bandwith_900A}
    should be equal as strings    ${result_NSA}    False
    Unlock LTE Site
    [Teardown]    Run keyword
    ...           Bring Up X2 Connection
