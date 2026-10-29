*** Settings ***
Documentation
...  author : yin.4.chen@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
D_11_SA_ClassicalgNB_PCMD_Report_after_lock_second_cell
    ${cell_list}   Get All Cell Id
    Set Test Variable   ${CELL_LIST}
    ${cell_index}   Set Variable   ${CELL_LIST[-1]}
    ${cellgrp_id}   Get Cell Group From Cell   cell_id=${cell_index}
    Perform cell lock via rest api   cell_idx=${cell_index}
    Wait Until Keyword Succeeds   180 sec   30 sec   Cell Should Be Locked   cell_idx=${cell_index}  cell_group_idx=${cellgrp_id}
    Make L3CALL And Get ALL PCMD MSG
    ${flag}   Set Variable   ${False}
    FOR   ${crnti}   IN   @{ALL_PCMD_MSG.keys()}
        ${flag}   Run Keyword And Return Status   Dictionary Should Contain Key   ${ALL_PCMD_MSG['${crnti}']}   ulSchedulingRecord
        Exit For Loop If   ${flag}
    END
    run keyword if  not ${flag}   Fail   Message Not Found!

Case Setup: D_11
    robot_common_operations.Common Case Setup    allowed_faults_ids=8000
    Common Setup 1756
    Remove And Add PCMD Object
    Connect to gnb coam via ssl

Case Teardown: D_11
    Run Keyword And Ignore Error   COAM Teardown gnb connections
    Wait Until Keyword Succeeds   10m   1m   Connect to gnb coam via ssl
    FOR   ${cell_index}   IN   @{CELL_LIST}
        ${cellgrp_id}   Get Cell Group From Cell   cell_id=${cell_index}
        ${status}   Run Keyword And Return Status   Cell Should Be Unlocked   cell_idx=${cell_index}   cell_group_idx=${cellgrp_id}
        run keyword if  not ${status}   Run Keywords
        ...   Perform cell unlock via rest api    cell_idx=${cell_index}   AND
        ...   Wait Until Keyword Succeeds   240 sec    30 sec   Cell Should Be Unlocked   cell_idx=${cell_index}   cell_group_idx=${cellgrp_id}
    END
    Wait Until Keyword Succeeds   600 sec   60 sec   COAM Check GNB cell on air
    Run Keyword And Ignore Error   COAM Teardown gnb connections
    Common Teardown 1756
    robot_common_operations.Common Case Teardown
