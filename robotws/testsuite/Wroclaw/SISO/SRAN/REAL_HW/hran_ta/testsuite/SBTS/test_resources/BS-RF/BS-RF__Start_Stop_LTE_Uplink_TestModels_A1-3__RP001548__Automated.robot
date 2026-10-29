*** Settings ***
Documentation
...  Test Case verifies LTE A1-3 Uplink Test Model

Resource    ../../../../resources/hran_frame_sbts_siso.robot
Resource    ../../../../resources/ca_BSRF_LTE_Uplink_TestModels.robot

*** Variables ***

${USER_LTE_CELL}       #User can choose specific LTE cell IDs (use the format: LTE_cell_id1,LTE_cell_id2,
# e. g. 12858,12859). If you want run test for all LTE cells in configuration, leave this field empty!


*** Keywords ***
TC__BS-RF__Start_Stop_LTE_Uplink_TestModels_A1-3__RP001548__Automated
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-13708
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Test case perform enter to Test Dedicated State.
    ...  Start LTE Uplink Test Model A1-3 on all or selected by user LTE cells (according 3GPP TM A1-3 can be started on cells
    ...  with BW 5, 10, 15 or 20 MHz),
    ...  check if started Test Model is active, stop LTE Uplink Test Model A1-3 and checked if some TM are active on BTS.
    ...  Exit from Test Dedicate State.
    ...  LTE Uplink Test Model A1-3 can be activated only for Resource Block Offset value 0.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 21.12.2018 - https://jira3.int.net.nokia.com/browse/TAT-13708 - Initial creation
    ...  - 03.07.2019 - https://jira3.int.net.nokia.com/browse/TAT-16762 - change expected BTS status to Test
    ...  - 27.10.2021 - https://jira3.int.net.nokia.com/browse/TAT-21754 - Changes due to CNI-61110
    ...  - 01.12.2022 - hran_admin.robot resource remove
    ...  - 21.05.2025 - enter and exit TDS added
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-13708.png


    Set Tags    CA-BS-RF    OWNER-lukasz.wystup@nokia.com    AUTHOR-lukasz.wystup@nokia.com
    ...    MAINTAINER-mateusz.kawka@nokia.com    GROUP_IN_CHARGE-WRO_3_Vrf    FEATURE-RP001548_2    PHASE-CRT
    ...    SW-SBTS18

    ca_BSRF_LTE_Uplink_TestModels.step0: Set Resource Block Offset
    ca_BSRF_LTE_Uplink_TestModels.step1: Check Input Data for LTE Uplink Test Model A1_3
    ca_BSRF_LTE_Uplink_TestModels.step2: Start Dedicated State
    ca_BSRF_LTE_Uplink_TestModels.step3: Check LTE Uplink Test Model
    ca_BSRF_LTE_Uplink_TestModels.step3: Exit Test Dedicated State via WebEM


TC Setup
    Common Test Setup

TC Teardown
    Common Test Teardown


