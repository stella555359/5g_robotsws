*** Settings ***
Documentation       Test case for
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Keywords ***
CM__WCDMA_Cell_Block_And_Unblock
    [Documentation]    CM__WCDMA_Cell_Block_And_Unblock
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...
    ...    Block and unblock all WCDMA Cells.
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 05.02.2024 - Bin.7.Liu - Commit to robotws.
    Step 1: Block WCDMA Cell
    Step 2: Unblock WCDMA cell

Step ${index}: Block WCDMA Cell
    LOG    Step ${index}: Block WCDMA Cell    console=${True}
    SBTS WEM Expand Configuration Tree On Navigation Panel Under Pramater Editor
    ${wcells}    SBTS WEM Get Cells Name And Path    WCDMA
    ${wcell_names}    Get Dictionary Keys    ${wcells}
    Set Test Variable    ${wcell_names}
    SBTS WEM Block Cells    ${wcell_names}

Step ${index}: Unblock WCDMA Cell
    LOG    Step ${index}: Unblock WCDMA Cell    console=${True}
    SBTS WEM Unblock Cells    ${wcell_names}

Set Up
    SBTS WEM Logon    https://${MPLANE_IP}    skip_error=${True}    setup_param=${False}

Tear Down
    Run Keyword If Test Failed    Capture Page Screenshot    ${TEST_NAME}_FAIL.JPEG
    SBTS WEM Download Chrome Console Log
    Close All Browsers
