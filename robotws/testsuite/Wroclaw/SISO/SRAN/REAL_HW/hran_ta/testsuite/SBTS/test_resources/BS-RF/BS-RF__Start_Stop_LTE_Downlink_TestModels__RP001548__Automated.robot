*** Settings ***
Documentation
...  Test Case verifies LTE Downlink Test Models

Resource    ../../../../resources/hran_frame_sbts_siso.robot
Resource    ../../../../resources/ca_BSRF_LTE_Downlink_TestModels.robot

*** Variables ***

${USER_TM}             #FILL OUT BEFORE RUN! Possible input is one element from the list:
# E_TM1_1,E_TM1_2,E_TM2,E_TM2a,E_TM3_1a,E_TM3_1,E_TM3_2,E_TM3_3
${USER_LTE_CELL}       #User can choose specific LTE cell IDs (use the format: LTE_cell_id1,LTE_cell_id2,
# e. g. 12858,12859). If you want run test for all LTE cells in configuration, leave this field empty!
${USER_PHY_CELL_ID}    #Physical Cell Id list created by user (use the format: phy_cell_id1,phy_cell_id2,
# e. g. 1,22). Allowed values from 1 to 503! If you leave this field empty, test will be performed for default values 1 and 503.


*** Keywords ***
TC__BS-RF__Start_Stop_LTE_Downlink_TestModels__RP001548__Automated
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-10714
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Test case should activate Reset to Test Dedicated State on BTS via Admin, start choosed LTE Downlink Test Model on all or selected by user
    ...  LTE cells,
	...  check if started Test Model is active, stop LTE Downlink Test Model and deactivate Test Dedicated State.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 02.07.2018 - https://jira3.int.net.nokia.com/browse/TAT-10714 - Initial creation
    ...  - 09.11.2018 - https://jira3.int.net.nokia.com/browse/TAT-13074 - TC name change
    ...  - 13.11.2018 - https://jira3.int.net.nokia.com/browse/TAT-13075 - After SiteReset TC checked if BTS is OnAir
    ...  - 11.01.2019 - https://jira3.int.net.nokia.com/browse/TAT-13988 - Temporary resignation from one method of checking active TDS
    ...  - 02.08.2019 - https://jira3.int.net.nokia.com/browse/TAT-14241 - move TC body to resources and code refactoring
    ...  - 27.10.2021 - https://jira3.int.net.nokia.com/browse/TAT-21754 - Changes due to CNI-61110
    ...  - 01.12.2022 - hran_admin.robot resource remove
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-13075.png


    Set Tags    CA-BS-RF    OWNER-lukasz.wystup@nokia.com    AUTHOR-lukasz.wystup@nokia.com
    ...    MAINTAINER-mateusz.kawka@nokia.com    GROUP_IN_CHARGE-WRO_3_Vrf    PHASE-CRT    SW-SBTS18
    ...    FEATURE-RP001548_2SB_FC3    FEATURE-RP001548_2SB_FD3

    ca_BSRF_LTE_Downlink_TestModels.step0: Check Input Data for LTE Downlink Test Model ${USER_TM}
    ca_BSRF_LTE_Downlink_TestModels.step1: Start Dedicated State
    ca_BSRF_LTE_Downlink_TestModels.step2: Confirm Dedicated State
    ca_BSRF_LTE_Downlink_TestModels.step3: Check LTE Downlink Test Model - General


TC Setup
    Common Test Setup

TC Teardown
    Common Test Teardown


