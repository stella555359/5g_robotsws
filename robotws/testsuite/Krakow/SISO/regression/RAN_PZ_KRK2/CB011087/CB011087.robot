*** Settings ***
Documentation
...   Testsuite for regression testing of feature CB011087
...   author: Maciej Russek, maciej.russek@nokia.com
...   maintainer: Michal Maz, michal.maz@nokia.com

Library     taf.sbts.oam.coam.admin    WITH NAME    admin
Library     taf/rfrl/common_resources/python/reset_bts_configuration.py
Resource    testsuite/Krakow/SISO/resources/RAN_PZ_KRK2/CB011050/keywords.robot
Library     testsuite.Krakow.resources.RAN_PZ_KRK2.SMAWave.SMAWaveTput    WITH NAME    SMAWave
Library     Collections
Variables   variables.py

Suite Setup       CB011087 Suite setup
Suite Teardown    CB011087 Suite teardown
Test Setup        Common preconditions with watching alarms
Test Teardown     Common postconditions with watching alarms

*** Variables ***
${COLLECT_LOGS_DURING_DATA_TRANSFER}      ${False}
${ENABLE_RACH_OBSERVER}                   ${False}
${UE}                                     SAMSUNG

*** Test Cases ***
[1][1.0] Manual_SiSo_CM_Commissioning_Configuration_reset
    Run keyword if    ${CONFIG_RESET_STATUS}==${False}
    ...    Fail    Test failed because configuration reset in suite setup failed
    ...    ELSE
    ...    gnb_bbu.Verify gNB is onAir

[1][1.0] CB011087_CPRI_OBSAI_ASIR_configuration_block_A14_with_ASOG
    [Setup]    CB011087 Common test setup
    Perform L3 call on selected cells
    ...    selected_cells=&{all_cells_lte_nr}

# WARNING - below testcase needs to be executed after config reset,
#           so please remember to never select this testcase when using UTE Single Run with skip_agent options
[1][1.0] General_SiSo_load_ASiR_config_from_file_via_ASiR_WebEM
    [Setup]    CB011087 Common test setup
    Perform L3 call on selected cells
    ...    selected_cells=&{all_cells_lte_nr}

[1][2.0] Manual_SiSo_SM_BTS_Block_Site
    [Setup]    CB011087 Common test setup
    Perform BTS site block
    Perform L3 call on selected cells
    ...    selected_cells=&{all_cells_lte_nr}

[1][1.0] General_SiSo_RAT_Block_Unblock_with_L3call
    [Setup]    CB011087 Common test setup
    Perform RAT block unblock for 5G LTE GSM    rats_cell_ids=&{cell_ids_by_rat}
    Perform L3 call on selected cells
    ...    selected_cells=&{all_cells_lte_nr}

[1][1.0] General_SiSo_block_unblock_pRRHs_via_ASiR_WebEM
    [Setup]    CB011087 Common test setup
    Perform SISO block unblock all pRRHs
    Perform L3 call on selected cells
    ...    selected_cells=&{asir_cells}

*** Keywords ***
CB011087 Suite setup
    Common suite setup with onAir Test Line preparation
    ...    swconfig_from_path=commissionings/Krakow/7_7_UTE5GCLOUDT300/default_swconfig.txt
    ...    increase_time_for_checking_cells=600
    ...    list_of_additional_allowed_alarms=WiFi Enabled Alarm
    Set suite variable    ${CONFIG_RESET_STATUS}    ${False}
    ${status}    Run keyword and return status     Perform configuration reset
    Set suite variable    ${CONFIG_RESET_STATUS}    ${status}
    gnbbbu.Disconnect
    [Teardown]    Common suite setup with onAir Test Line preparation
    ...           swconfig_from_path=commissionings/Krakow/7_7_UTE5GCLOUDT300/default_swconfig.txt
    ...           increase_time_for_checking_cells=600
    ...           list_of_additional_allowed_alarms=WiFi Enabled Alarm

CB011087 Suite teardown
   Common suite teardown

CB011087 Common test setup
    Set test variable    ${L3_CALL_STATUS}    ${True}
    Common preconditions with watching alarms

CB011087 Common test teardown
    Common postconditions with watching alarms

Perform L3 call on selected cells
    [Arguments]    ${selected_cells}
    Block all LTE and NR cells before L3 call
    ${keys}    Get Dictionary Keys    ${selected_cells}
    Prepare UE for L3 call
    ...    capabilities=${UE}
    ...    alias=${UE}
    Verify GSM attach    expected_cell=2101
    FOR    ${cell_id}    IN     @{keys}
        Perform L3 call on selected cell
        ...    cell_id=${cell_id}
        ...    tput_dl=${selected_cells["${cell_id}"]["tput_dl"]}
        ...    tput_ul=${selected_cells["${cell_id}"]["tput_ul"]}
        ...    deviation=${selected_cells["${cell_id}"]["deviation"]}
        ...    attach_timeout=${80}
    END
    Run keyword if    ${L3_CALL_STATUS}==${False}    Fail    Tput not as expected
    [Teardown]    CB011087 L3 call teardown

Block all LTE and NR cells before L3 call
    gnb_alarm.Allow alarm    Cell blocked
    gnbcell.Block all cells from rat   rat=LTE
    Sleep    15s    Wait for cells to be blocked
    gnbcell.Block all cells from rat    rat=NR
    Sleep    15s    Wait for cells to be blocked

Unblock all LTE and NR cells after L3 call
    gnbcell.Unblock all cells from rat    rat=LTE
    gnbcell.Unblock all cells from rat    rat=NR
    Sleep    15s    Wait for cells to be unblocked

Verify GSM attach
    [Arguments]    ${expected_cell}
    ue.Attach UE    ${UE}
    Sleep    180s    Wait for GSM attach
    ${ue_info}    ue.Get UE info    ${UE}
    Should be equal    ${ue_info['cell_id']}    ${expected_cell}
    Should not be equal    ${ue_info['ip']}    ${None}
    [Teardown]    ue.Detach Ue    ${UE}

CB011087 L3 call teardown
    ${status}    Run keyword and return status    Unblock all LTE and NR cells after L3 call
    Run keyword if    ${status}==${False}    Reset gNB
    Wait until keyword succeeds    360 sec    10 sec   gnbcell.Verify All Cells are OnAir
    gnb_alarm.Disallow alarm    Cell blocked

Perform configuration reset
    ${connection}    admin.Setup admin
    Reset BTS configuration    connection=${connection}
    ...                        reset_admin_connection=${True}
    admin.Teardown admin    connection=${connection}
