*** Settings ***
Documentation
...   Testsuite for regression testing of feature CNI114419
...   author: Maciej Russek, maciej.russek@nokia.com
...   maintainer: Maciej Russek, maciej.russek@nokia.com

Resource    testsuite/Krakow/SISO/resources/RAN_PZ_KRK2/CB011050/keywords.robot

Suite Setup       Run keywords
...               Common suite setup with onAir Test Line preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...               prefix_tag=CNI114419
...               AND    Common Suite Setup
Suite Teardown    Common suite teardown
Test Setup        CNI114419 Common test setup
Test Teardown     Common postconditions with watching alarms

*** Variables ***
${COLLECT_LOGS_DURING_DATA_TRANSFER}  ${False}
${ENABLE_RACH_OBSERVER}               ${False}
${TPUT_DL_5G}                         1000 Mbits/sec
${TPUT_UL_5G}                         135 Mbits/sec
${L3_CALL_STATUS}                     ${True}
${UE}                                 ONEPLUS

*** Test Cases ***
[1][1.0] CNI-114419_TC13_block_unblock_pRRHs_via_ASiR_WebEM
    Perform SISO block unblock all pRRHs
    Perform L3 call on all cells

[1][1.0] CNI-114419_TC16_reset_ASiR_HUB_via_ASiR_WebEM
    SISO reset all ASiR hubs
    Perform L3 call on all cells

*** Keywords ***
CNI114419 Common test setup
    Set global variable    ${L3_CALL_STATUS}    ${True}
    Common preconditions with watching alarms

Perform L3 call on all cells
    [Arguments]    ${tput_dl_5g}=${TPUT_DL_5G}    ${tput_ul_5g}=${TPUT_UL_5G}
    @{cells_list}     gnbcell.get_all_global_cell_ids
    Block all cells before L3 call
    Prepare UE for L3 call
    ...    capabilities=${UE}
    ...    alias=${UE}
    FOR    ${cell_id}    IN     @{cells_list}
        Perform L3 call on selected cell
        ...    cell_id=${cell_id}
        ...    tput_dl=${tput_dl_5g}
        ...    tput_ul=${tput_ul_5g}
        ...    deviation=20%
        ...    attach_timeout=30
    END
    Run keyword if    ${L3_CALL_STATUS}==${False}    Fail    Tput not as expected
    [Teardown]    L3 call teardown
