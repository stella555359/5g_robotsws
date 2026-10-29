*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/selenium.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/coam.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/btslog_check.robot

#*** Variables ***
#
*** Keywords ***
KPI_17_Manual_block_unblock_cell_duration
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to verify bts block/unblock functionality.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 24.10.2022 - - Created
    ...    - 29.12.2023 - - Modify bolock durtion: https://jiradc.ext.net.nokia.com/browse/LEOPARD-1631
    ...    *******************
    ...    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${cell_block_durtion}=30    ${cell_unblock_durtion}=30
    ${cell_id_list}  Get All Cell Id    cell_type=${cell_type}
    run keyword and ignore error    Stop Btslog With Path Check
    Start Btslog With Path Check
    AlarmWatchdog.add_allow_alarms    fault_id=49
    Cell Block Unblock     cell_id_list=${cell_id_list}
    Stop Btslog With Path Check
    Btslog Check All Cells Block Unblock     cell_id_list=${cell_id_list}
    ...                                      cell_block_durtion=${cell_block_durtion}
    ...                                      cell_unblock_durtion=${cell_unblock_durtion}

Cell Block Unblock
    [Arguments]  ${cell_id_list}
    FOR    ${cell_id}    IN    @{cell_id_list}
        ${id_list}    create list    ${cell_id}
        SBTS Block cells and check status    block_list=${id_list}
        SBTS UnBlock Cells and check status    block_list=${id_list}
    END

Btslog Check All Cells Block Unblock
    [Arguments]  ${cell_id_list}    ${cell_block_durtion}=10    ${cell_unblock_durtion}=30
    FOR    ${cell_id}    IN    @{cell_id_list}
        Btslog Check Cell Block Duration    cell_id=${cell_id}    cell_block_durtion=${cell_block_durtion}
        Btslog Check Cell Unblock Duration    cell_id=${cell_id}    cell_unblock_durtion=${cell_unblock_durtion}
    END
