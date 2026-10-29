*** Settings ***
Documentation
...   Testsuite for regression testing of feature CB009826
...   author: Maciej Russek, maciej.russek@nokia.com
...   maintainer: Przemyslaw Gajewski, przemyslaw.gajewski@nokia.com

Resource    testsuite/Krakow/SISO/regression/RAN_PZ_KRK2/FR_CB010652/resources/keywords.robot
Resource    testsuite/Krakow/SISO/resources/RAN_PZ_KRK2/CB011050/keywords.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables   variables.py

Suite Setup      Run keywords
...              Common suite setup with onAir Test Line preparation
...              swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...              increase_time_for_checking_cells=600
...              prefix_tag=CB009826
...              AND    Common Suite Setup
Suite Teardown   Common suite teardown
Test Setup       CB009826 Common test setup
Test Teardown    CB009826 Common test teardown

*** Test Cases ***
L3_call_test
    Perform L3 call on all cells    cells_for_l3_call=&{all_cells}

[1][1.0] General_SiSo_block_unblock_pRRHs_via_ASiR_WebEM
    Perform SISO block unblock all pRRHs
    Perform L3 call on all cells    cells_for_l3_call=&{all_cells}

[1][1.0] General_SiSo_Auto_Cell_block_and_unblock_with_L3call
    Perform all cells block unblock
    Perform L3 call on all cells    cells_for_l3_call=&{all_cells}

[1][1.0] General_SiSo_reset_ASiR_HUB_via_ASiR_WebEM
    SISO reset all ASiR hubs
    Perform L3 call on all cells    cells_for_l3_call=&{all_cells}

[1][1.0] General_SiSo_Auto_RF_lock_unlock_with_L3call_multiple_BBMODs
    Perform RU lock unlock
    Perform L3 call on all cells    cells_for_l3_call=&{all_cells}

[1][1.0] General_SiSo_Auto_RAT_reset_with_L3call
    Perform RAT reset for 5G LTE    rats_cell_ids=&{cell_ids_by_rat}
    Perform L3 call on all cells    cells_for_l3_call=&{all_cells}

[1][1.0] General_SiSo_Auto_gNB_Site_Reset_From_WebUI
    Allow alarm for site reset
    Reset BTS via WebEM
    Wait for all cells to be operating correctly
    Verify cell status on ASiR WebEM
    [Teardown]    Disallow alarms for site reset with common postconditions and logout from Gui

*** Keywords ***
Perform L3 call on all cells
    [Arguments]    ${cells_for_l3_call}
    ${keys}    Get dictionary keys    ${cells_for_l3_call}
    Block all cells before L3 call
    FOR    ${cell_id}    IN    @{keys}
        Perform L3 call on selected cell on Smawave
        ...    cell_id=${cell_id}
        ...    tput_dl=${cells_for_l3_call["${cell_id}"]["tput_dl"]}
        ...    tput_ul=${cells_for_l3_call["${cell_id}"]["tput_ul"]}
        ...    deviation=20%
    END
    Run keyword if    ${L3_CALL_STATUS}==${False}    Fail    Tput not as expected
    [Teardown]    L3 call teardown

Perform L3 call on selected cell on Smawave
    [Arguments]    ${cell_id}    ${tput_dl}    ${tput_ul}    ${deviation}
    Unblock cell before L3 call    ${cell_id}
    Log to console    Run tput on cell ${cell_id}
    ${status}    Run keyword and ignore error
        ...    smawave.Run bidirectional traffic multistream
        ...    uepc_ip=10.84.174.139
        ...    smawave_ip=192.168.1.1
        ...    smawave_password=Ty5Dp1Qi0Ke8
        ...    tput_command_dl=1400
        ...    tput_command_ul=1400
        ...    appserver_ip=10.84.168.70
        ...    appserver_traffic_ip=10.84.169.54
        ...    duration_time=120
        ...    tput_expected_dl=${tput_dl}
        ...    tput_expected_ul=${tput_ul}
        ...    deviation=${deviation}
        ...    key_algorithm=-p 22 -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedKeyTypes=+ssh-rsa
        ...    parallel_streams_dl=4
        ...    parallel_streams_ul=8
        ...    ssh_method=ssh
    Block cell after L3 call    ${cell_id}
    Analyse L3 call status
    ...    l3_call_status=${status}
    ...    cell_id=${cell_id}

CB009826 Common test setup
    Set test variable    ${L3_CALL_STATUS}    ${True}
    Common preconditions with watching alarms

CB009826 Common test teardown
    Common postconditions with watching alarms
