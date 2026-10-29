*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Resource    ../Resource/Common.robot


*** Keywords ***
Test_Case_General_SiSo_Auto_Cell_lock_and_unlock_with_L3call
    Case Setup: General_SiSo_Auto_Cell_lock_and_unlock_with_L3call
    General_SiSo_Auto_Cell_lock_and_unlock_with_L3call
    [Teardown]   Case Teardown: General_SiSo_Auto_Cell_lock_and_unlock_with_L3call


General_SiSo_Auto_Cell_lock_and_unlock_with_L3call
    Log To Console   General_SiSo_Auto_Cell_lock_and_unlock_with_L3call

    COAM Login

    @{all_cell_dn_list}   Create List
    ${nr_cells}   coam.get_cells_info   connection=COAM
    FOR   ${nr_cell}   IN   @{nr_cells}
        ${nr_cell_dn}   Set Variable   ${nr_cell["id"]["configuration"]}
        Log To Console   Block Cell: ${nr_cell_dn}
        coam.block_cell   ${nr_cell_dn}   connection=COAM   timeout=${600}
        Append To List   ${all_cell_dn_list}   ${nr_cell_dn}
    END

    FOR   ${nr_cell_dn}   IN   @{all_cell_dn_list}
        Log To Console   Unblock Cell: ${nr_cell_dn}
        coam.unblock_cell   ${nr_cell_dn}   connection=COAM   timeout=${600}
    END

    Wait Until Keyword Succeeds   15m   1m   COAM ADMIN Check Cell Onair

    # CB010820 L3 Call Common Keyword

    [Teardown]   Run Keyword And Ignore Error   COAM Logout


Case Setup: General_SiSo_Auto_Cell_lock_and_unlock_with_L3call
    Set Suite Variable   ${DEFINE_TEST_NAME}   General_SiSo_Auto_Cell_lock_and_unlock_with_L3call
    CB010820 Common Case Setup
    Wait Until Keyword Succeeds   10m   1m   COAM Login
    Wait Until Keyword Succeeds   15m   1m   COAM ADMIN Check Cell Onair
    [Teardown]   Run Keyword And Ignore Error   COAM Logout


Case Teardown: General_SiSo_Auto_Cell_lock_and_unlock_with_L3call
    CB010820 Common Case Teardown
