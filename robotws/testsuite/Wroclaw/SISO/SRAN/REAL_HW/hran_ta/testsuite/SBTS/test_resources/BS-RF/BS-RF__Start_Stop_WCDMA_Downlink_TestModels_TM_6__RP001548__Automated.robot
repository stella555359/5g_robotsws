*** Settings ***
Documentation
...  Start and stop  WCDMA Downlink Test Model TM_6

Resource    ../../../../resources/hran_frame_sbts_siso.robot
Resource    ../../../../resources/ca_BSRF_WCDMA_Downlink_TestModels.robot

*** Variables ***

${USER_WCDMA_CELL}          #User can choose specific WCDMA cell IDs (use the format: WCDMA_cell_id1,WCDMA_cell_id2, e. g. 31001,31002).
# If you want run test for all WCDMA cells in configuration, leave this field empty!
${USER_PRIMARY_SCR_CODE}    #Primary scrambling code list created by user (use the format: PRIMARY_SCR_CODE1,PRIMARY_SCR_CODE2, e. g. 1,22).
# Allowed values from 0 to 511 - restriction for two layers WCDMA cells, allowed primary scr code value from 0 to 1! If you leave this field empty,
# test will be performed for default values 0 and 1.


*** Keywords ***
TC__BS-RF__Start_Stop_WCDMA_Downlink_TestModels_TM_6__RP001548__Automated
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-15070
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Test case should checked if BTS is in Test Dedicated State.
    ...  Start WCDMA Downlink Test Model TM_5 on all or selected by user WCDMA cells, check if started Test Model is active,
    ...  stop WCDMA Downlink Test Model and checked if some TM are active on BTS.
    ...  Before this TC BTS should be in Test Dedicated State - for that purpose you can use TC
    ...  BS-RF__Enter_to_Test_Dedicated_State_via_WebEm__RP001548__Automated
    ...  or manually activated Test Dedicated State from Admin.
    ...  After this TC you can use TC BS-RF__Exit_from_Test_Dedicated_State_via_WebEm__RP001548 or do site reset to exit from Test Dedicate State).
    ...  Primary scrambling code allowed values from 0 to 511 - restriction for two layers WCDMA cells, allowed primary scr code value from 0 to 1.
    ...  Test model will be started for value Number of HS-PDSCH: 8 and corresponding Number of DPCH: 30.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 15.07.2019 - https://jira3.int.net.nokia.com/browse/TAT-15070 - Initial creation
    ...  - 09.08.2019 - https://jira3.int.net.nokia.com/browse/TAT-17133 - change totTxPwr range to 90-100%
    ...  - 10.06.2020 - https://jira3.int.net.nokia.com/browse/TAT-19624 - Change of power level check method from SYSLOG prints to RMOD carriers
    ...  - 27.10.2021 - https://jira3.int.net.nokia.com/browse/TAT-21754 - Changes due to CNI-61110
    ...  - 01.12.2022 - hran_admin.robot resource remove
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-15070.png


    Set Tags    CA-BS-RF    OWNER-lukasz.wystup@nokia.com    AUTHOR-lukasz.wystup@nokia.com
    ...    MAINTAINER-mateusz.kawka@nokia.com    GROUP_IN_CHARGE-WRO_3_Vrf    PHASE-CRT    SW-SBTS18SP
    ...    FEATURE-RP001548_2SB_FC6    FEATURE-RP001548_2SB_FD6

    ca_BSRF_WCDMA_Downlink_TestModels.step0: Check Input Data for WCDMA Downlink Test Model TM_6
    ca_BSRF_WCDMA_Downlink_TestModels.step1: Confirm Dedicated State
    ca_BSRF_WCDMA_Downlink_TestModels.step2: Check WCDMA Downlink Test Model


TC Setup
    Common Test Setup    expected_BTS_status=Test    cells_check=${false}

TC Teardown
    Common Test Teardown


