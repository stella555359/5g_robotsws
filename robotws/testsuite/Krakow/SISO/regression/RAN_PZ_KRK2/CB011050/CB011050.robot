*** Settings ***
Documentation
...   Testsuite for regression testing of feature CB011050
...   author: Maciej Russek, maciej.russek@nokia.com
...   maintainer: Maciej Russek, maciej.russek@nokia.com

Resource    testsuite/Krakow/SISO/resources/RAN_PZ_KRK2/CB011050/keywords.robot

Suite Setup       Run keywords
...               Common suite setup with onAir Test Line preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...               increase_time_for_checking_cells=600
...               prefix_tag=CB011050
...               AND    Common Suite Setup
Suite Teardown    Common suite teardown
Test Setup        CB011050 Common test setup
Test Teardown     Common postconditions with watching alarms

*** Variables ***
${COLLECT_LOGS_DURING_DATA_TRANSFER}      ${False}
${ENABLE_RACH_OBSERVER}                   ${False}
${TPUT_DL_5G}                             840 Mbits/sec
${TPUT_UL_5G}                             160 Mbits/sec
${TPUT_DL_LTE}                            112 Mbits/sec
${TPUT_UL_LTE}                            11 Mbits/sec
${NR_CELLS_FOR_L3_CALL}                   3
${LTE_CELLS_FOR_L3_CALL}                  6
${L3_CALL_STATUS}                         ${True}
${UE}                                     ONEPLUS

*** Test Cases ***
[1][1.0] CB011050_reset_pRRH_via_ASiR_WebEM
    Perform SISO reset all pRRHs
    Perform L3 call on random cells

[1][1.0] CB011050_block_unblock_pRRHs_via_ASiR_WebEM
    Perform SISO block unblock all pRRHs
    Perform L3 call on random cells

[1][1.0] CB011050_lock_unlock_ASiR_HUB_via_WebEM
    SISO Lock unlock all ASiR hubs
    Perform L3 call on random cells

[1][1.0] CB011050_reset_ASiR_HUB_via_ASiR_WebEM
    SISO reset all ASiR hubs
    Perform L3 call on random cells

[1][1.0] CB011050_General_SiSo_RU_module_reset_from_GUI
    Perform RU module reset from GUI
    Perform L3 call on random cells

*** Keywords ***
CB011050 Common test setup
    Set global variable    ${L3_CALL_STATUS}    ${True}
    Common preconditions with watching alarms

Perform L3 call on random cells
    [Arguments]    ${tput_dl_5g}=${TPUT_DL_5G}    ${tput_ul_5g}=${TPUT_UL_5G}    ${tput_dl_lte}=${TPUT_DL_LTE}
    ...            ${tput_ul_lte}=${TPUT_UL_LTE}

    @{random_lte_cells}    Get random LTE cell IDs for L3 call
    @{random_nr_cells}    Get random NR cell IDs for L3 call
    Block all cells before L3 call
    Prepare UE for L3 call
    ...    capabilities=${UE}
    ...    alias=${UE}
    FOR    ${cell_id}    IN    @{random_lte_cells}
        Perform L3 call on selected cell
        ...    cell_id=${cell_id}
        ...    tput_dl=${tput_dl_lte}
        ...    tput_ul=${tput_ul_lte}
        ...    deviation=20%
    END
    FOR    ${cell_id}    IN     @{random_nr_cells}
        Perform L3 call on selected cell
        ...    cell_id=${cell_id}
        ...    tput_dl=${tput_dl_5g}
        ...    tput_ul=${tput_ul_5g}
        ...    deviation=40%
    END
    Run keyword if    ${L3_CALL_STATUS}==${False}    Fail    Tput not as expected
    [Teardown]    L3 call teardown

Get random LTE cell IDs for L3 call
    @{all_lte_cells}    gnbcell.Get all global cell IDs    cell_type=lte
    @{random_lte_cells}    Get random cell IDs
    ...    all_cell_ids=${all_lte_cells}
    ...    target_number_of_cells=${LTE_CELLS_FOR_L3_CALL}
    [Return]    @{random_lte_cells}

Get random NR cell IDs for L3 call
    @{all_nr_cells}     gnbcell.Get all global cell IDs    cell_type=nr
    @{random_nr_cells}     Get random cell IDs
    ...    all_cell_ids=${all_nr_cells}
    ...    target_number_of_cells=${NR_CELLS_FOR_L3_CALL}
    [Return]    @{random_nr_cells}
