*** Settings ***
Documentation
...  Test Case should check RF hopping

Resource    ../../../../resources/hran_frame_sbts_siso.robot

Resource    ../../../../resources/ca_BSRF_RF_hopping_L3.robot


*** Variables ***
${USER_DATA}                       # user_data - FILL OUT BEFORE RUN! (BTSid1=MAL_1,BTSid2=MAL_2,
                                   # MAL_x MA list number from BSC e.g. 374=8,376=8)
${CELLS_YAML_PATH}                 # define cells yaml file path


*** Keywords ***
TC__BS-RF__SBTS_GSM_RF_hopping__RP002611__Automated_L3
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-18781
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  TC should activate RF hopping on selected by user GSM cells deployed on ARDA radio module, make voice call, data transfer on selected cells
    ...  and deactivate RF hopping on selected GSM cells. Proper MA list should be defined on BSC before TC execution.
    ...  User has to define this MA list number (MAL_1, MAL_2) for each tested GSM cell (BTSid).
    ...  More info about RF hopping: https://confluence.int.net.nokia.com/display/HRANBTSIV/RF+hopping
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 15.01.2020 - https://jira3.int.net.nokia.com/browse/TAT-18781 - initial creation
    ...  - 13.03.2020 - https://jira3.int.net.nokia.com/browse/TAT-19199 - code refactor to ute_ue library
    ...  - 27.10.2021 - https://jira3.int.net.nokia.com/browse/TAT-21754 - Changes due to CNI-61110
	...  - 05.09.2023 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-35836 - call refactoring
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/BS-RF__SBTS_GSM_RF_hopping__RP002611_TAT-18781.png


    Set Tags    CA-BS-RF    OWNER-anna.maciejewska@nokia.com    AUTHOR-anna.maciejewska@nokia.com
    ...    MAINTAINER-anna.maciejewska@nokia.com    GROUP_IN_CHARGE-WRO_3_Vrf    PHASE-CRT    SW-SBTS20A
    ...    FEATURE-RP002611_1_F1


    ca_BSRF_RF_hopping_L3.Step1: Check Input Data Defined By User
    ca_BSRF_RF_hopping_L3.Step2: Check If All Hopping Modes Are Disabled In Tested GSM Cells
    Step3: Activate RF hopping In Tested GSM Cells
    Step4: Check RF Hopping Activation In Tested GSM Cells
    ca_BSRF_RF_hopping_L3.Step5: Make Voice Call/Data Transfer In Tested GSM Cells
    Step6: Deactivate RF Hopping In Tested GSM Cells


TC Setup
    Common Test Setup

TC Teardown
    Run Keywords    Run Keyword If Test Failed    Run Keyword And Ignore Error    Deactivate RF Hopping    AND    Common Test Teardown
