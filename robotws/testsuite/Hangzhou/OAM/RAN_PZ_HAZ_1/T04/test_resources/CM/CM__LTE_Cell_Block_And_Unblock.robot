*** Settings ***
Documentation       Test case for
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Keywords ***
CM__LTE_Cell_Block_And_Unblock
    [Documentation]    CM__LTE_Cell_Block_And_Unblock
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...
    ...    Block and unblock all LTE Cells.
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 05.02.2024 - Bin.7.Liu - Commit to robotws.
    Step 1: Block LTE Cell
    Step 2: Unblock LTE cell

Step ${index}: Block LTE Cell
    LOG    Step ${index}: Block LTE Cell    console=${True}
    SBTS WEM Expand Configuration Tree On Navigation Panel Under Pramater Editor
    ${lcells}    SBTS WEM Get Cells Name And Path    LTE
    ${lcell_names}    Get Dictionary Keys    ${lcells}
    Set Test Variable    ${lcell_names}
    SBTS WEM Block Cells    ${lcell_names}

Step ${index}: Unblock LTE Cell
    LOG    Step ${index}: Unblock LTE Cell    console=${True}
    SBTS WEM Unblock Cells    ${lcell_names}

Set Up
    SBTS WEM Logon    https://${MPLANE_IP}    skip_error=${True}    setup_param=${False}

Tear Down
    Run Keyword If Test Failed    Capture Page Screenshot    ${TEST_NAME}_FAIL.JPEG
    SBTS WEM Download Chrome Console Log
    Close All Browsers
