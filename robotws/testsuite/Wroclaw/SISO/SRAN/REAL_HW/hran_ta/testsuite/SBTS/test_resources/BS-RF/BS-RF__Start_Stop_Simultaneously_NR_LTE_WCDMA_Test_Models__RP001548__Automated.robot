*** Settings ***
Documentation
...  Start NR/LTE/WCDMA Downlink and Uplink Test Model on all or selected by user cells.

Resource    ../../../../resources/ca_BSRF_Simultaneously_NR_LTE_WCDMA_TestModels.robot
Resource    ../../../../resources/hran_frame_sbts_siso.robot
Resource    ../../../../resources/ca_BSRF_general.robot

*** Variables ***

${USER_RAT_TO_LAUNCH}  4G-3G  # Possible input: 5G-4G-3G, 5G-4G, 4G-3G.
${USER_NR_DL_TM}       # Possible input: TM1_1, TM1_2, TM2, TM2A, TM3_1, TM3_1A, TM3_2, TM3_3, TM3_1N. Default is TM1_1.
${USER_NR_UL_TM}       # Possible input: G_FR1_A1_1, G_FR1_A1_2, G_FR1_A1_5, G_FR1_A2_1, G_FR1_A2_4, G GFR2_A1_2, G_FR2_A1_3. Default is G_FR1_A1_1.
${USER_NR_CELL}        # Specific NR cell (format: NR_cell_id1,NR_cell_id2, e.g. 1,2). Leave empty to run for all NR cells.
${USER_LTE_DL_TM}      # Possible input: E_TM1_1,E_TM1_2,E_TM2,E_TM2a,E_TM3_1a,E_TM3_1,E_TM3_2,E_TM3_3. Default is E_TM1_1.
${USER_LTE_UL_TM}      # Possible input: A1_1, A1_2, A1_3, A1_4, A1_5, A2_1, A2_2, A2_3. Default is A1_3.
${USER_LTE_CELL}       # Specific LTE cell (format: LTE_cell_id1,LTE_cell_id2, e.g. 12858,12859). Leave empty to run for all LTE cells.
${USER_WCDMA_DL_TM}    # Possible input: TM_1, TM_2, TM_3, TM_4, TM_5, TM_6. Default is TM_1.
${USER_WCDMA_CELL}     # Specific WCDMA cell (format: WCDMA_cell_id1,WCDMA_cell_id2, e.g. 31001,31002). Leave empty to run for all WCDMA cells.


*** Keywords ***
TC__BS-RF__Start_Stop_Simultaneously_NR_LTE_WCDMA_Test_Models__RP001548__Automated
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-17110
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Test case perform enter to Test Dedicated State.
    ...  Default test case starts simultaneously LTE, WCDMA and NR test models.
    ...  By USER_RAT_TO_LAUNCH variable, user can choose for which RATs TMs will be launch.
    ...  Start NR/LTE/WCDMA Downlink and Uplink Test Model on all or selected by user cells.
    ...  Check if started Test Models are active.
    ...  Stop NR/LTE/WCDMA Uplink and Downlink Test Model.
    ...  Checked if TMs are not active on BTS.
    ...  Exit from Test Dedicate State.
    ...  Test Models will be checked for Physical_Cell_Id = 1, Resource_block_offset = 0, Primary_scrambling_code = 0
    ...  All input parameters can be check in ca_BSRF_simulatneously_NR_LTE_WCDMA_TestModels.robot
    ...
    ...  Allowed LTE cell bandwidth for LTE Uplink Test Models:
    ...
    ...  | BW             | A1_1 | A1_2 | A1_3 | A1_4 | A1_5 | A2_1 | A2_2 | A2_3 |
    ...  | ---            |  --- |  --- |  --- | ---  |  --- | ---  |  --- |  --- |
    ...  | 1,4 MHz        |  X   |      |      |  X   |      |  X   |      |      |
    ...  | 3 MHz          |      |  X   |      |      |  X   |      |  X   |      |
    ...  | 5 MHz          |      |  X   |  X   |      |      |      |      |  X   |
    ...  | 10, 15, 20MHz  |      |      |  X   |      |      |      |      |  X   |
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 17.09.2019 - https://jira3.int.net.nokia.com/browse/TAT-17110 - Initial creation
    ...  - 21.11.2019 - https://jira3.int.net.nokia.com/browse/TAT-18312 - change TC name
    ...  - 06.12.2019 - https://jira3.int.net.nokia.com/browse/TAT-18474 - change TC name
    ...  - 10.06.2020 - https://jira3.int.net.nokia.com/browse/TAT-19624 - Remove check prints in SYSLOG in WCDMA Downlink TM
    ...  - 27.10.2021 - https://jira3.int.net.nokia.com/browse/TAT-21754 - Changes due to CNI-61110
    ...  - 27.10.2021 - https://jira3.int.net.nokia.com/browse/TAT-22459 - Added 5G Test Models with power checking
    ...  - 21.05.2025 - enter and exit TDS added


    Set Tags    CA-BS-RF    OWNER-lukasz.wystup@nokia.com    AUTHOR-lukasz.wystup@nokia.com
    ...    MAINTAINER-mateusz.kawka@nokia.com    GROUP_IN_CHARGE-WRO_3_Vrf    PHASE-CRT    SW-SBTS18SP
    ...    FEATURE-RP001548_2SB_FC17    FEATURE-RP001548_2SB_FD17

    step0: Set Input Data
    Run Keyword If  '5G' in '${USER_RAT_TO_LAUNCH}'  Run Keywords
    ...  ca_BSRF_Simultaneously_NR_LTE_WCDMA_TestModels.step1: Check Input Data for NR Downlink Test Model ${USER_NR_DL_TM}
    ...  AND  ca_BSRF_Simultaneously_NR_LTE_WCDMA_TestModels.step2: Check Input Data for NR Uplink Test Model ${USER_NR_UL_TM}
    Run Keyword If  '4G' in '${USER_RAT_TO_LAUNCH}'  Run Keywords
    ...  ca_BSRF_Simultaneously_NR_LTE_WCDMA_TestModels.step1: Check Input Data for LTE Downlink Test Model ${USER_LTE_DL_TM}
    ...  AND  ca_BSRF_Simultaneously_NR_LTE_WCDMA_TestModels.step2: Check Input Data for LTE Uplink Test Model ${USER_LTE_UL_TM}
    Run Keyword If  '3G' in '${USER_RAT_TO_LAUNCH}'
    ...  ca_BSRF_Simultaneously_NR_LTE_WCDMA_TestModels.step1: Check Input Data for WCDMA Downlink Test Model ${USER_WCDMA_DL_TM}
    ca_BSRF_Simultaneously_NR_LTE_WCDMA_TestModels.step4: Start Dedicated State
    ca_BSRF_Simultaneously_NR_LTE_WCDMA_TestModels.step5: Start Test Models
    ca_BSRF_Simultaneously_NR_LTE_WCDMA_TestModels.step6: Check Test Models Status After Start
    ca_BSRF_Simultaneously_NR_LTE_WCDMA_TestModels.step7: Stop Test Models
    ca_BSRF_Simultaneously_NR_LTE_WCDMA_TestModels.step8: Check Test Models Status After Stop
    ca_BSRF_Simultaneously_NR_LTE_WCDMA_TestModels.step9: Exit Test Dedicated State via WebEM


step0: Set Input Data

    Run Keyword If  '${USER_NR_DL_TM}'=='${EMPTY}'     Set Test Variable  ${USER_NR_DL_TM}     TM1_1
    Run Keyword If  '${USER_NR_UL_TM}'=='${EMPTY}'     Set Test Variable  ${USER_NR_UL_TM}     G_FR1_A1_1
    Run Keyword If  '${USER_LTE_DL_TM}'=='${EMPTY}'    Set Test Variable  ${USER_LTE_DL_TM}    E_TM1_1
    Run Keyword If  '${USER_LTE_UL_TM}'=='${EMPTY}'    Set Test Variable  ${USER_LTE_UL_TM}    A1_3
    Run Keyword If  '${USER_WCDMA_DL_TM}'=='${EMPTY}'  Set Test Variable  ${USER_WCDMA_DL_TM}  TM_1

TC Setup
    Common Test Setup



TC Teardown
    Common Test Teardown



