*** Settings ***
Documentation
...  Test Case verifies LTE E-TM1.1 Downlink Test Model

Resource    ../../../../resources/hran_frame_sbts_siso.robot
Resource    ../../../../resources/ca_BSRF_LTE_Downlink_TestModels.robot

*** Variables ***

${USER_LTE_CELL}       #User can choose specific LTE cell IDs (use the format: LTE_cell_id1,LTE_cell_id2,
# e. g. 12858,12859). If you want run test for all LTE cells in configuration, leave this field empty!
${USER_PHY_CELL_ID}    #Physical Cell Id list created by user (use the format: phy_cell_id1,phy_cell_id2,
# e. g. 1,22). Allowed values from 1 to 503! If you leave this field empty, test will be performed for default values 1 and 503.


*** Keywords ***
TC__BS-RF__Start_Stop_LTE_Downlink_TestModels_E-TM1_1__RP001548__Automated
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-13322
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Test case perform enter to Test Dedicated State.
    ...  Start LTE Downlink Test Model E-TM1.1 on all or selected by user LTE cells, check if started Test Model is active,
    ...  stop LTE Downlink Test Model and checked if some TM are active on BTS.
    ...  Exit from Test Dedicate State.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 12.12.2018 - https://jira3.int.net.nokia.com/browse/TAT-13322 - Initial creation
    ...  - 03.07.2019 - https://jira3.int.net.nokia.com/browse/TAT-16762 - change expected BTS status to Test
    ...  - 27.10.2021 - https://jira3.int.net.nokia.com/browse/TAT-21754 - Changes due to CNI-61110
    ...  - 01.12.2022 - hran_admin.robot resource remove
    ...  - 21.05.2025 - enter and exit TDS added
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-13322.png


    Set Tags    CA-BS-RF    OWNER-lukasz.wystup@nokia.com    AUTHOR-lukasz.wystup@nokia.com
    ...    MAINTAINER-mateusz.kawka@nokia.com    GROUP_IN_CHARGE-WRO_3_Vrf    PHASE-CRT    SW-SBTS18
    ...    FEATURE-RP001548_2SB_FC3    FEATURE-RP001548_2SB_FD3

    ca_BSRF_LTE_Downlink_TestModels.step0: Check Input Data for LTE Downlink Test Model E_TM1_1
    ca_BSRF_LTE_Downlink_TestModels.step1: Start Dedicated State
    ca_BSRF_LTE_Downlink_TestModels.step2: Check LTE Downlink Test Model
    ca_BSRF_LTE_Downlink_TestModels.step3: Exit Test Dedicated State via WebEM


TC Setup
    Common Test Setup

TC Teardown
    Common Test Teardown


