*** Settings ***
Documentation    This is common keywords for 5GC002540_E
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
*** Variables ***

*** Keywords ***
lock_unlock_cells_2CC
    [Arguments]   ${cell_1}=1    ${cell_2}=2    ${connection}=GNB_OAM    ${with_peak}=${False}
    Perform all cells lock    cell_1= ${cell_1}    cell_2= ${cell_2}
    Perform cell_1 cell_2 unlock sequence    cell_1= ${cell_1}    cell_2= ${cell_2}
    sleep    10s
    ${cell_list}    create list    ${2}
    Get UE From Init File and Make call    cell_list=${cell_list}    with_peak=${False}
    Perform all cells lock    cell_1= ${cell_1}    cell_2= ${cell_2}
    Perform cell_2 cell_1 unlock revert    cell_1= ${cell_1}    cell_2= ${cell_2}
    ${cell_list}    create list    ${2}
    Get UE From Init File and Make call    cell_list=${cell_list}    with_peak=${False}

Perform all cells lock
    [Arguments]    ${cell_1}=1    ${cell_2}=2    ${connection}=GNB_OAM
    @{cell_list}    create list     ${cell_1}    ${cell_2}
    connect to gnb coam via ssl    connection=${connection}
    FOR    ${idx}  IN  @{cell_list}
        perform_cell_lock_via_admin    cell_id=${idx}    connection=${connection}    lock_timeout=120
    END
Perform cell_1 cell_2 unlock sequence
     [Arguments]    ${cell_1}=1    ${cell_2}=2    ${connection}=GNB_OAM
    @{cell_list}    create list     ${cell_1}    ${cell_2}
    connect to gnb coam via ssl    connection=${connection}
    FOR    ${idx}  IN  @{cell_list}
        perform_cell_unlock_via_admin    cell_id=${idx}    connection=${connection}    lock_timeout=120
    END
Perform cell_2 cell_1 unlock revert
    [Arguments]    ${cell_1}=1    ${cell_2}=2    ${connection}=GNB_OAM
    @{cell_list}    create list     ${cell_2}     ${cell_1}
    #Reverse List    @{cell_list}
    connect to gnb coam via ssl    connection=${connection}
    FOR    ${idx}  IN  @{cell_list}
        perform_cell_unlock_via_admin    cell_id=${idx}    connection=${connection}    lock_timeout=120
    END