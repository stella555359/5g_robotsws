*** Settings ***
Documentation    author：Hongyu Jiang
...              contact: hongyu.jiang@nokia-sbell.com
...              squad group: mmw_SG_04


Resource    ./Resources/CB013440_common_keyword.robot
Variables   ./Resources/TLConfigration_13440.py

Suite Setup    CB013440 Suite Setup

*** Variables ***
@{all_cell_id}    2   5   6
@{all_rmod_id}    2   3   4   5

*** Test Cases ***
[1]BLock cells And Un Unblock Cells
    FOR   ${i}    IN RANGE    ${20}
        vDU Block or Unblock Cells    cell_id_list=${all_cell_id}    is_block=${True}
        vDU Block or Unblock Cells    cell_id_list=${all_cell_id}    is_block=${False}
    END
    [Teardown]    Run Keyword If    "${TEST_STATUS}"=="FAIL"    Collect vdu snapshot

[1]Lock cells And Unlock Cells
    FOR   ${i}    IN RANGE    ${20}
        vDU lock or Unlock Cells    cell_id_list=${all_cell_id}    is_lock=${True}
        vDU lock or Unlock Cells    cell_id_list=${all_cell_id}    is_lock=${False}
    END
    [Teardown]    Run Keyword If    "${TEST_STATUS}"=="FAIL"    Collect vdu snapshot

[1]Lock RMOD And Unlock RMOD
    FOR   ${i}   IN RANGE    ${20}
        vDU lock or Unlock Rmods    rmod_id_list=${all_rmod_id}    is_lock=${True}
        vDU lock or Unlock Rmods    rmod_id_list=${all_rmod_id}    is_lock=${False}
    END
    [Teardown]    Run Keyword If    "${TEST_STATUS}"=="FAIL"    Collect vdu snapshot

[1]Reset RMOD Mutil Times
    @{rmods_list}    Create List
    FOR  ${id}   IN   @{all_rmod_id}
        Append To List   MRBTS-${tl.gnbs[0].dus[0].instance_id}/EQM-1/APEQM-1/RMOD-${id}
    END
    FOR    ${i}   IN RANGE    ${20}
        vDU RU Reset And Check cell status    rmods_list=${rmods_list}
    END

[1]Reset Runnic
    ${runnic_r_dn}    Set Variable    MRBTS-${tl.gnbs[0].dus[0].instance_id}/EQM_R-1/APEQM_R-1/RNICMOD_R-1
    FOR   ${i}   IN RANGE    ${20}
        vDU RANNIC Reset And Check cell status    runnic_r_dn=${runnic_r_dn}
    END
    [Teardown]    Run Keyword If    "${TEST_STATUS}"=="FAIL"    Collect vdu snapshot

[1]Reset vDU
    FOR    ${i}    IN RANGE   ${40}
        vDU Reset And Check cell status
    END
    [Teardown]    Run Keyword If    "${TEST_STATUS}"=="FAIL"    Collect vdu snapshot
