*** Settings ***
Documentation
...  Test Case verifies LTE A2-2 Uplink Test Model

Resource    ../../../../resources/hran_frame_sbts_siso.robot
Resource    ../../../../resources/ca_BSRF_LTE_Uplink_TestModels.robot

*** Variables ***

${USER_LTE_CELL}        #User can choose specific LTE cell IDs (use the format: LTE_cell_id1,LTE_cell_id2,
# e. g. 12858,12859). If you want run test for all LTE cells in configuration, leave this field empty!


*** Keywords ***
TC__BS-RF__Start_Stop_LTE_Uplink_TestModels_A2-2__RP001548__Automated
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-17051
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Test case should checked if BTS is in Test Dedicated State.
    ...  Start LTE Uplink Test Model A2-2 on all or selected by user LTE cells (according 3GPP TM A2-2 can be started on cells with BW 3 MHz),
    ...  check if started Test Model is active, stop LTE Uplink Test Model A2-2 and checked if some TM are active on BTS.
    ...  LTE Uplink Test Model A2-2 can be activated only for Resource Block Offset value 0.
    ...  Before this TC BTS should be in Test Dedicated State - for that purpose you can use TC
    ...  BS-RF__Enter_to_Test_Dedicated_State_via_WebEm__RP001548__Automated
    ...  or manually activated Test Dedicated State from Admin.
    ...  After this TC you can use TC BS-RF__Exit_from_Test_Dedicated_State_via_WebEm__RP001548 or do site reset to exit from Test Dedicate State).
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 31.07.2019 - https://jira3.int.net.nokia.com/browse/TAT-17051 - Initial creation
    ...  - 27.10.2021 - https://jira3.int.net.nokia.com/browse/TAT-21754 - Changes due to CNI-61110
    ...  - 01.12.2022 - hran_admin.robot resource remove
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-17051.png


    Set Tags    CA-BS-RF    OWNER-lukasz.wystup@nokia.com    AUTHOR-lukasz.wystup@nokia.com
    ...    MAINTAINER-mateusz.kawka@nokia.com    GROUP_IN_CHARGE-WRO_3_Vrf    PHASE-CRT    SW-SBTS18
    ...    FEATURE-RP001548_2SB_FD11    FEATURE-RP001548_2SB_FC11

    ca_BSRF_LTE_Uplink_TestModels.step0: Set Resource Block Offset
    ca_BSRF_LTE_Uplink_TestModels.step1: Check Input Data for LTE Uplink Test Model A2_2
    ca_BSRF_LTE_Uplink_TestModels.step2: Confirm Dedicated State
    ca_BSRF_LTE_Uplink_TestModels.step3: Check LTE Uplink Test Model


TC Setup
    Common Test Setup    expected_BTS_status=Test    cells_check=${false}

TC Teardown
    Common Test Teardown


