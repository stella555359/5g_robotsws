# robocop: off
*** Settings ***
Documentation
...  Resource for Simultaneously NR LTE WCDMA TestModels

Resource          hran_frame_sbts_siso.robot
Resource          ca_BSRF_general.robot
Resource          ca_siso_general.robot
Library           taf.selenium.sbts  WITH NAME  selenium_coam

*** Keywords ***

step${step_number}: Check Input Data for NR Downlink Test Model ${USER_NR_DL_TM}

    ## NR ##
    Set Test Variable  @{NR_DL_TM_LIST}   TM1_1  TM1_2  TM2  TM2A  TM3_1  TM3_1A  TM3_2  TM3_3  TM3_1N
    @{BEAM_PATTERN_ID}  Create list  ${1}
    Set Test Variable  ${BEAM_PATTERN_ID}
    Set Test Variable  ${POLARIZATION}  P_both
    Set Test Variable  ${POWER_BACKOFF}  0
    Set Test Variable  ${RU_MODE}  NR_Only
    Set Test Variable  ${PHY_NR_CELL_ID}  1    #Default values Physical Cell Id
    Set Test Variable  ${codebook_2_antports}  0
    Set Test Variable  ${i11_codebook_4_antports}  0
    Set Test Variable  ${i2_codebook_4_antports}  0
    Set Test Variable  ${i13_codebook_4_antports}  0
    Set Test Variable  ${MIMO_RANK}  1

    Log To Console  step${step_number}: Check Input Data for NR Downlink Test Model ${USER_NR_DL_TM}${\n}
    Set Test Variable  ${USER_NR_DL_TM}
    ${tm_select_status}  Run Keyword And Return Status  Should Contain  ${NR_DL_TM_LIST}  ${USER_NR_DL_TM}
    Run Keyword If  ${tm_select_status}==False
    ...  Fail  Input name Test Model '${USER_NR_DL_TM}' is incorrect. Possible input is one element from the list: ${NR_DL_TM_LIST}
    Run Keyword If  '${USER_NR_CELL}'=='${EMPTY}'  ca_BSRF_Simultaneously_NR_LTE_WCDMA_TestModels.Get Ids For All NR Cells
    ...  ELSE  ca_BSRF_Simultaneously_NR_LTE_WCDMA_TestModels.Get Ids For User NR Cell
    Log To Console  NR Downlink Test Model ${USER_NR_DL_TM} will be performed for Cell:\n${NR_CELLS_ID_LIST}

step${step_number}: Check Input Data for NR Uplink Test Model ${USER_LTE_UL_TM}

    Set Test Variable  @{NR_UL_TM_LIST}   G_FR1_A1_1  G_FR1_A1_2  G_FR1_A1_4  G_FR1_A1_5  G_FR1_A1_7
    ...  G_FR1_A2_1  G_FR1_A2_4  G_FR1_A2_5  GFR2_A1_2  G_FR2_A1_3
    Set Test Variable  ${INTERVAL}  1
    Set Test Variable  ${PRB_OFFSET}  0

    Log To Console  ${\n}step${step_number}: Check Input Data for NR Uplink Test Model ${USER_NR_UL_TM}${\n}
    Set Test Variable  ${USER_NR_UL_TM}
    ${tm_select_status}  Run Keyword And Return Status  Should Contain  ${NR_UL_TM_LIST}  ${USER_NR_UL_TM}
    Run Keyword If  ${tm_select_status}==False
    ...  Fail  Input name Test Model '${USER_NR_UL_TM}' is incorrect. Possible input is one element from the list: ${LTE_UL_TM_LIST}
    Log To Console  LTE Uplink Test Model ${USER_NR_UL_TM} will be performed for Cell:\n${NR_CELLS_ID_LIST}
    Log To Console  LTE Uplink Test Model ${USER_NR_UL_TM} will be performed for Resource Block Offset -> ${PRB_OFFSET}


step${step_number}: Check Input Data for LTE Downlink Test Model ${USER_LTE_DL_TM}

    ## LTE ##
    Set Test Variable  @{LTE_DL_TM_LIST}   E_TM1_1  E_TM1_2  E_TM2  E_TM2a  E_TM3_1a  E_TM3_1  E_TM3_2  E_TM3_3
    Set Test Variable  ${PHY_CELL_ID}  1    #Default values Physical Cell Id

    Set Test Variable  @{LTE_UL_TM_LIST}   A1_1  A1_2  A1_3  A1_4  A1_5  A2_1  A2_2  A2_3
    Set Test Variable  ${RB_OFFSET_ID}    0    #Default values Resource block offset
    Set Test Variable  @{A1_1}         1.4 MHz    #Allowed cell bandwidth
    Set Test Variable  @{A1_2}         3 MHz  5 MHz    #Allowed cell bandwidth
    Set Test Variable  @{A1_3}         5 MHz  10 MHz  15 MHz  20 MHz    #Allowed cell bandwidth
    Set Test Variable  @{A1_4}         1.4 MHz    #Allowed cell bandwidth
    Set Test Variable  @{A1_5}         3 MHz    #Allowed cell bandwidth
    Set Test Variable  @{A2_1}         1.4 MHz    #Allowed cell bandwidth
    Set Test Variable  @{A2_2}         3 MHz    #Allowed cell bandwidth
    Set Test Variable  @{A2_3}         5 MHz  10 MHz  15 MHz  20 MHz    #Allowed cell bandwidth

    Log To Console  ${\n}step${step_number}: Check Input Data for LTE Downlink Test Model ${USER_LTE_DL_TM}${\n}
    Set Test Variable  ${USER_LTE_DL_TM}
    ${tm_select_status}  Run Keyword And Return Status  Should Contain  ${LTE_DL_TM_LIST}  ${USER_LTE_DL_TM}
    Run Keyword If  ${tm_select_status}==False
    ...  Fail  Input name Test Model '${USER_LTE_DL_TM}' is incorrect. Possible input is one element from the list: ${LTE_DL_TM_LIST}
    ...  ELSE  ca_BSRF_Simultaneously_NR_LTE_WCDMA_TestModels.Get Ids For User LTE Cell
    Log To Console  LTE Downlink Test Model ${USER_LTE_DL_TM} will be performed for Cell:\n${LTE_CELLS_ID_LIST}
    Log To Console  LTE Downlink Test Model ${USER_LTE_DL_TM} will be performed for Physical cell ID -> ${PHY_CELL_ID}

step${step_number}: Check Input Data for LTE Uplink Test Model ${USER_LTE_UL_TM}

    Log To Console  ${\n}step${step_number}: Check Input Data for LTE Uplink Test Model ${USER_LTE_UL_TM}${\n}
    Set Test Variable  ${USER_LTE_UL_TM}
    ${tm_select_status}  Run Keyword And Return Status  Should Contain  ${LTE_UL_TM_LIST}  ${USER_LTE_UL_TM}
    Run Keyword If  ${tm_select_status}==False
    ...  Fail  Input name Test Model '${USER_LTE_UL_TM}' is incorrect. Possible input is one element from the list: ${LTE_UL_TM_LIST}
    Log To Console  LTE Uplink Test Model ${USER_LTE_UL_TM} will be performed for Cell:\n${LTE_CELLS_ID_LIST}
    ca_BSRF_Simultaneously_NR_LTE_WCDMA_TestModels.Check Possibility Run LTE Test Model
    Log To Console  LTE Uplink Test Model ${USER_LTE_UL_TM} will be performed for Resource Block Offset -> ${RB_OFFSET_ID}

step${step_number}: Check Input Data for WCDMA Downlink Test Model ${USER_WCDMA_DL_TM}

    ## WCDMA ##
    Set Test Variable  @{WCDMA_DL_TM_LIST}    TM_1  TM_2  TM_3  TM_4  TM_5  TM_6
    Set Test Variable  ${PRIMARY_SCR_CODE}    0   #Default values Primary scrambling code
    Set Test Variable  ${TM_1_DPCH}    16     #Number of DPCH
    Set Test Variable  ${TM_2_DPCH}    3    #Number of DPCH
    Set Test Variable  ${TM_2_DPCHPower}    -28    #DPCH power
    Set Test Variable  ${TM_3_DPCH}    16    #Number of DPCH
    Set Test Variable  ${TM_4_PCCPCH_SCH}    -6    #P-CCPCH + SCH power
    Set Test Variable  ${TM_4_DPCH}    0    #Number of DPCH
    Set Test Variable  ${TM_5_6_HS_PDSCH}    8    #Number of HS-PDSCH
    Set Test Variable  ${TM_5_6_DPCH}    30   #Number of DPCH
    Set Test Variable  ${USER_WCDMA_UL_TM}    BER/BLER


    Log To Console  ${\n}step${step_number}: Check Input Data for WCDMA Downlink Test Model ${USER_WCDMA_DL_TM} and ${USER_WCDMA_UL_TM}${\n}
    Set Test Variable  ${USER_WCDMA_DL_TM}
    ${tm_select_status}  Run Keyword And Return Status  Should Contain  ${WCDMA_DL_TM_LIST}  ${USER_WCDMA_DL_TM}
    Run Keyword If    ${tm_select_status}==False
    ...  Fail  Input name Test Model '${USER_WCDMA_DL_TM}' is incorrect. Possible input is one element from the list: ${WCDMA_DL_TM_LIST}
#    ${wcdma_configured}  Run Keyword And Return Status
#    ...  ute_admin_infomodel.Query infomodel  query=check /MRBTS-1/RAT-*/MCTRL-*/BBTOP_M-*/MRBTS_M-*/WNBTS_M-1 is [stateInfo.proceduralState=Test]
#    Run Keyword If  ${wcdma_configured}==False  Fail  No WCDMA cell in configuration
    Run Keyword If  '${USER_WCDMA_CELL}'=='${EMPTY}'  ca_BSRF_Simultaneously_NR_LTE_WCDMA_TestModels.Get Ids For All WCDMA Cells
    ...  ELSE  ca_BSRF_Simultaneously_NR_LTE_WCDMA_TestModels.Get Ids For User WCDMA Cell
    Log To Console  WCDMA Downlink Test Model ${USER_WCDMA_DL_TM} will be performed for Cell:\n${WCDMA_CELLS_ID_LIST}
    Log To Console  WCDMA Uplink Test Model ${USER_WCDMA_UL_TM} will be performed for Cell:\n${WCDMA_CELLS_ID_LIST}
    Log To Console  WCDMA Downlink Test Model ${USER_WCDMA_DL_TM} will be performed for Primary scrambling code -> ${PRIMARY_SCR_CODE}
    Log To Console  WCDMA Uplink Test Model ${USER_WCDMA_UL_TM} will be performed for scrambling code -> ${PRIMARY_SCR_CODE}

step${step_number}: Start Dedicated State

    Log To Console  ${\n}step${step_number}: Start Dedicated State${\n}
#    ${wcdma_configured}  Run Keyword And Return Status
#    ...  ute_admin_infomodel.Query infomodel  query=check /MRBTS-1/RAT-*/MCTRL-*/BBTOP_M-*/MRBTS_M-*/WNBTS_M-1 is [stateInfo.proceduralState=Test]
#    ${TDS_status}  Run Keyword And Return Status
#    ...  ca_BSRF_Simultaneously_NR_LTE_WCDMA_TestModels.Check if BTS is in Test Dedicated State  ${wcdma_configured}
#    Run Keyword If  ${TDS_status}==False  Fail  Set BTS in Test Dedicated State before run TC
#    Log to console  BTS is in Test Dedicated State


    Log To Console    Reset to Test Dedicated State

    ${is_lte}  Run Keyword And Return Status    admin.Get Ids For All  LNCEL  search_for_iot_cells=${True}
    admin.Reset To Test Dedicated
    ${TDS_status}  Run Keyword And Return Status
    ...  ca_BSRF_Simultaneously_NR_LTE_WCDMA_TestModels.Check if BTS is in Test Dedicated State  ${is_lte}
    Run Keyword If    ${TDS_status}==False    Fail    Problem with enter to Test Dedicated State
    Log to console  BTS is in Test Dedicated State

Check if BTS is in Test Dedicated State
    [Arguments]    ${is_lte}

    Log To Console  Reset To Test Dedicated Test procedure completed, waiting for MRBTS state -> Test ...${\n}
    Wait Until Keyword Succeeds  10min  10s  Check MrBTS State  expected_state=Test

    Log To Console  MRBTS state -> Test${\n}Waiting for all RAT(s) state -> Test ...${\n}
    Wait Until Keyword Succeeds  5min  10s  Check RAT State from Infomodel  expected_state=Test

    Run Keyword If  ${is_lte}  Wait Until Keyword Succeeds  5m  10s
    ...  admin.Assert Every  LNCEL  proceduralState=regex"(?i)Prevalidated"  search_for_iot_cells=${True}



step${step_number}: Start Test Models

    Log To Console  ${\n}step${step_number}: Start Test Models${\n}

    Run Keyword If  '5G' in '${USER_RAT_TO_LAUNCH}'  Run Keywords
    ...  ca_BSRF_Simultaneously_NR_LTE_WCDMA_TestModels.Start Downlink NR Test Model
    ...  AND  ca_BSRF_Simultaneously_NR_LTE_WCDMA_TestModels.Start Uplink NR Test Model

    Run Keyword If  '4G' in '${USER_RAT_TO_LAUNCH}'  Run Keywords
    ...  ca_BSRF_Simultaneously_NR_LTE_WCDMA_TestModels.Start Downlink LTE Test Model  ${phy_cell_id}
    ...  AND  ca_BSRF_Simultaneously_NR_LTE_WCDMA_TestModels.Start Uplink LTE Test Model    ${rb_offset_id}

    Return From Keyword If  '3G' not in '${USER_RAT_TO_LAUNCH}'

    Run Keyword If  '${USER_WCDMA_DL_TM}'=='TM_1' or '${USER_WCDMA_DL_TM}'=='TM_3'
    ...  ca_BSRF_Simultaneously_NR_LTE_WCDMA_TestModels.Start Downlink Test Model TM_1 or TM_3  ${PRIMARY_SCR_CODE}  ${TM_1_DPCH}
    Run Keyword If  '${USER_WCDMA_DL_TM}'=='TM_2'
    ...  ca_BSRF_Simultaneously_NR_LTE_WCDMA_TestModels.Start Downlink Test Model TM_2  ${PRIMARY_SCR_CODE}  ${TM_2_DPCH}  ${TM_2_DPCHPower}
    Run Keyword If  '${USER_WCDMA_DL_TM}'=='TM_4'
    ...  ca_BSRF_Simultaneously_NR_LTE_WCDMA_TestModels.Start Downlink Test Model TM_4  ${PRIMARY_SCR_CODE}  ${TM_4_DPCH}  ${TM_4_PCCPCH_SCH}
    Run Keyword If  '${USER_WCDMA_DL_TM}'=='TM_5' or '${USER_WCDMA_DL_TM}'=='TM_6'
    ...  ca_BSRF_Simultaneously_NR_LTE_WCDMA_TestModels.Start Downlink Test Model TM_5 Or TM_6
    ...  ${PRIMARY_SCR_CODE}  ${TM_5_6_DPCH}  ${TM_5_6_HS_PDSCH}
    ca_BSRF_Simultaneously_NR_LTE_WCDMA_TestModels.Start Uplink Test Model BER/BLER  ${PRIMARY_SCR_CODE}

step${step_number}: Check Test Models Status After Start

    Log To Console    ${\n}step${step_number}: Check Test Models Status After Start${\n}

    ${active_DL_NR_tm_list}  Run Keyword If  '5G' in '${USER_RAT_TO_LAUNCH}'
    ...  ca_BSRF_Simultaneously_NR_LTE_WCDMA_TestModels.Check Active Downlink Test Models  NR
    ${active_UL_NR_tm_list}  Run Keyword If  '5G' in '${USER_RAT_TO_LAUNCH}'
    ...  ca_BSRF_Simultaneously_NR_LTE_WCDMA_TestModels.Check Active NR Uplink Test Models

    ${active_DL_LTE_tm_list}  Run Keyword If  '4G' in '${USER_RAT_TO_LAUNCH}'
    ...  ca_BSRF_Simultaneously_NR_LTE_WCDMA_TestModels.Check Active Downlink Test Models  LTE
    ${active_UL_LTE_tm_list}  Run Keyword If  '4G' in '${USER_RAT_TO_LAUNCH}'
    ...  ca_BSRF_Simultaneously_NR_LTE_WCDMA_TestModels.Check Active LTE Uplink Test Models  ${rb_offset_id}  after start TM action

    ${active_DL_WCDMA_tm_list}  Run Keyword If  '3G' in '${USER_RAT_TO_LAUNCH}'
    ...  ca_BSRF_Simultaneously_NR_LTE_WCDMA_TestModels.Check Active WCDMA Downlink Test Models
    ${active_UL_WCDMA_tm_list}  Run Keyword If  '3G' in '${USER_RAT_TO_LAUNCH}'
    ...  ca_BSRF_Simultaneously_NR_LTE_WCDMA_TestModels.Check Active Test Models BER/BLER

    Run Keyword If  '5G' in '${USER_RAT_TO_LAUNCH}'
    ...  Check Test Model Status After Start  ${active_DL_NR_tm_list}  ${active_UL_NR_tm_list}  NR

    Run Keyword If  '4G' in '${USER_RAT_TO_LAUNCH}'
    ...  Check Test Model Status After Start  ${active_DL_LTE_tm_list}  ${active_UL_LTE_tm_list}  LTE

    Run Keyword If  '3G' in '${USER_RAT_TO_LAUNCH}'
    ...  Check Test Model Status After Start  ${active_DL_WCDMA_tm_list}  ${active_UL_WCDMA_tm_list}  WCDMA

step${step_number}: Stop Test Models

    Log To Console    ${\n}step${step_number}: Stop Test Models${\n}
    Run Keyword If  '5G' in '${USER_RAT_TO_LAUNCH}'  Run Keywords
    ...  ca_BSRF_Simultaneously_NR_LTE_WCDMA_TestModels.Stop Downlink NR Test Model
    ...  AND  ca_BSRF_Simultaneously_NR_LTE_WCDMA_TestModels.Stop Uplink NR Test Model

    Run Keyword If  '4G' in '${USER_RAT_TO_LAUNCH}'  Run Keywords
    ...  ca_BSRF_Simultaneously_NR_LTE_WCDMA_TestModels.Stop Uplink LTE Test Model    ${rb_offset_id}
    ...  AND  ca_BSRF_Simultaneously_NR_LTE_WCDMA_TestModels.Stop Downlink LTE Test Model    ${phy_cell_id}

    Run Keyword If  '3G' in '${USER_RAT_TO_LAUNCH}'  Run Keywords
    ...  ca_BSRF_Simultaneously_NR_LTE_WCDMA_TestModels.Stop Uplink WCDMA Test Model    ${PRIMARY_SCR_CODE}
    ...  AND  ca_BSRF_Simultaneously_NR_LTE_WCDMA_TestModels.Stop Downlink WCDMA Test Model    ${PRIMARY_SCR_CODE}

step${step_number}: Check Test Models Status After Stop

    Log To Console    ${\n}step${step_number}: Check Test Models Status After Stop${\n}

    ${inactive_DL_NR_tm_list}  Run Keyword If  '5G' in '${USER_RAT_TO_LAUNCH}'
    ...  ca_BSRF_Simultaneously_NR_LTE_WCDMA_TestModels.Check Active Downlink Test Models  NR
    ${inactive_UL_NR_tm_list}  Run Keyword If  '5G' in '${USER_RAT_TO_LAUNCH}'
    ...  ca_BSRF_Simultaneously_NR_LTE_WCDMA_TestModels.Check Active NR Uplink Test Models

    ${inactive_DL_LTE_tm_list}  Run Keyword If  '4G' in '${USER_RAT_TO_LAUNCH}'
    ...  ca_BSRF_Simultaneously_NR_LTE_WCDMA_TestModels.Check Active Downlink Test Models  LTE
    ${inactive_UL_LTE_tm_list}  Run Keyword If  '4G' in '${USER_RAT_TO_LAUNCH}'
    ...  ca_BSRF_Simultaneously_NR_LTE_WCDMA_TestModels.Check Active LTE Uplink Test Models    ${rb_offset_id}    after stop TM action

    ${inactive_DL_WCDMA_tm_list}  Run Keyword If  '3G' in '${USER_RAT_TO_LAUNCH}'
    ...  ca_BSRF_Simultaneously_NR_LTE_WCDMA_TestModels.Check Active WCDMA Downlink Test Models
    ${inactive_UL_WCDMA_tm_list}  Run Keyword If  '3G' in '${USER_RAT_TO_LAUNCH}'
    ...  ca_BSRF_Simultaneously_NR_LTE_WCDMA_TestModels.Check Active Test Models BER/BLER

    Run Keyword If  '5G' in '${USER_RAT_TO_LAUNCH}'
    ...  Check Test Model Status After Stop  ${inactive_DL_NR_tm_list}  ${inactive_UL_NR_tm_list}  NR

    Run Keyword If  '4G' in '${USER_RAT_TO_LAUNCH}'
    ...  Check Test Model Status After Stop  ${inactive_DL_LTE_tm_list}  ${inactive_UL_LTE_tm_list}  LTE

    Run Keyword If  '3G' in '${USER_RAT_TO_LAUNCH}'
    ...  Check Test Model Status After Stop  ${inactive_DL_WCDMA_tm_list}  ${inactive_UL_WCDMA_tm_list}  WCDMA


step${step_number}: Exit Test Dedicated State via WebEM

    Log To Console    ${\n}step${step_number}: Exit Test Dedicated State via WebEM${\n}
    Log to console  Checking Google Chrome and Chrome Driver compatibility !${\n}
    Check And Repair Google Chrome And Chrome Driver Compatibility

    ca_BSRF_Simultaneously_NR_LTE_WCDMA_TestModels.Selenium Login And Disable Screen Lock TDS
    selenium_coam.Disable Test Dedicated State    timeout=300
    ca_BSRF_Simultaneously_NR_LTE_WCDMA_TestModels.Selenium Logout And Close Browser TDS
    Log To Console    Reset to Test Dedicated State Disabled succeeds
    Log To Console    Reset BTS to OnAir State
    Log To Console    Check if BTS is in OnAir State
    Wait Until Keyword Succeeds    15 min  15 sec    ca_BSRF_Simultaneously_NR_LTE_WCDMA_TestModels.Check If Modules And Cells Are OnAir

Check If Modules And Cells Are OnAir
    [Documentation]
    ...  KW checks if all cells are onAir and modules are Enabled
    Check If All Cells Are OnAir
    admin.Assert Every    RMOD    operationalState=regex"(?i)Enabled"
    admin.Assert Every    SMOD    operationalState=regex"(?i)Enabled"

Selenium Login And Disable Screen Lock TDS
    [Arguments]    ${download_dir}=${TestFiles}/selenium   ${screenshot_dir}=${TestFiles}/selenium
    ${browser}=  selenium_coam.Create Firefox Browser  download_dir=${download_dir}  screenshot_dir=${screenshot_dir}  name=firefox_browser
    ${sw_release}    admin.Get Sw Release Name
    selenium_coam.login  https://192.168.255.129/  Nemuadmin  nemuuser  version=${sw_release}  browser=${browser}
    ${view_exists}  selenium_coam.start_up_view_window_exists
    Run Keyword If  ${view_exists}  selenium_coam.close_start_up_view_window
    selenium_coam.disable_message_box
    selenium_coam.disable_screen_lock

Selenium Logout And Close Browser TDS
    Run Keyword And Ignore Error  selenium_coam.logout
    Run Keyword And Ignore Error  selenium_coam.close_browser

Get RMOD Id And Ants For Cell
    [Documentation]
    ...  KW returns rmod_id and antenna lines on which cell is deployed
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com

    [Arguments]  ${cell}
    ${cell_info}  admin.Get Cell Specific Info  ${cell}
    ${carriers}  Get From Dictionary  ${cell_info}  carrierList

    ${ants_list}  Create List
    FOR  ${carrier}  IN  @{carriers}
        Continue For Loop If  '${carrier['direction']}'!='TX'
        Append To List  ${ants_list}  ${carrier['antennaLineId']['internal']}
    END

    ${ants_list}  Remove Duplicates  ${ants_list}
    ${rmod_id}  Evaluate  '${ants_list}[0]'.rsplit('/',1)[0]

    [Return]  ${rmod_id}  ${ants_list}

Check Test Model Status After Start
    [Documentation]
    ...  Check TMs status after start
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com

    [Arguments]  ${DL_tm}  ${UL_tm}  ${rat}

    ${DL_tm_status}  Run Keyword And Return Status  Run Keyword If  '${rat}'!='WCDMA'  Should Not Contain  ${DL_tm}  FAIL
    ...  ELSE  Should Not Contain  ${DL_tm}  ${False}
    Run Keyword If  '${DL_tm_status}'=='False'  Fail  ${USER_${rat}_DL_TM} Downlink TM was not activated on all selected ${rat} cells

    ${UL_tm_status}  Run Keyword And Return Status  Run Keyword If  '${rat}'!='WCDMA'  Should Not Contain  ${UL_tm}  FAIL
    ...  ELSE  Should Not Contain  ${DL_tm}  ${False}
    Run Keyword If  '${UL_tm_status}'=='False'  Fail  ${USER_${rat}_UL_TM} Uplink TM was not activated on all selected ${rat} cells

Check Test Model Status After Stop
    [Documentation]
    ...  Check TMs status after stop
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com

    [Arguments]  ${DL_tm}  ${UL_tm}  ${rat}

    ${DL_tm_status}  Run Keyword And Return Status  Run Keyword If  '${rat}'!='WCDMA'  Should Not Contain  ${DL_tm}  PASS
    ...  ELSE  Should Not Contain  ${DL_tm}  ${True}
    Run Keyword If  '${DL_tm_status}'=='False'  Fail  ${USER_${rat}_DL_TM} Downlink TM was not activated on all selected ${rat} cells

    ${UL_tm_status}  Run Keyword And Return Status  Run Keyword If  '${rat}'!='WCDMA'  Should Not Contain  ${UL_tm}  PASS
    ...  ELSE  Should Not Contain  ${DL_tm}  ${True}
    Run Keyword If  '${UL_tm_status}'=='False'  Fail  ${USER_${rat}_UL_TM} Uplink TM was not activated on all selected ${rat} cells


Start Downlink NR Test Model
    [Documentation]
    ...  Start Downlink NR Test Model procedure
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW launch NR Downlink test models and logs tx power for all RU in configuration
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------+------+--------------------------------+
    ...  | Parameter name | Man. | Description                    |
    ...  +================+======+================================+
    ...  | phy_cell_id    | yes  | Physical Cell Id               |
    ...  +----------------+------+--------------------------------+
    ...  | USER_LTE_DL_TM | yes  | Tesy model from LTE_DL_TM_LIST |
    ...  +----------------+------+--------------------------------+

    ${sum_of_ants}  Create List
    Log To Console  NR Test model ${USER_NR_DL_TM} will be started for cell: \n${NR_CELLS_ID_LIST}
    FOR    ${NR_cell_ID}    IN    @{NR_CELLS_ID_LIST}
        ${cell_parameters}  admin.Get Parameters For  NRCEL  ${NR_cell_ID}
        ${rmod_id}  ${ants_list}  Get RMOD Id And Ants For Cell  ${NR_cell_ID}
        ${diff_ants}  Evaluate  list(set(${ants_list})-set(${sum_of_ants}))
        ${sum_of_ants}  Combine Lists  ${sum_of_ants}  ${ants_list}
        ${rmod_sn}  Get RU Serial Number For DistName  ${rmod_id}
        Log To Console    Power before Start 5G Downlink Test Model ${USER_NR_DL_TM} for ${cell_parameters.cellName}
        Log All TX Antenna Lines Power
        ${power_before_start}    Get TX Pipes Power From DAPD    ${rmod_sn}
        Log To Console    Start 5G Downlink Test Model ${USER_NR_DL_TM} for ${cell_parameters.cellName}
        admin.Start 5G Downlink Test  ${NR_cell_id}  ${USER_NR_DL_TM}  ${BEAM_PATTERN_ID}  ${POLARIZATION}  ${POWER_BACKOFF}  ${RU_MODE}
        ...  ${PHY_NR_CELL_ID}  ${codebook_2_antports}  ${i11_codebook_4_antports}
        ...  ${i2_codebook_4_antports}  ${i13_codebook_4_antports}  ${MIMO_RANK}
        Sleep    10s
        Log To Console    Power after Start 5G Downlink Test Model ${USER_NR_DL_TM} for ${cell_parameters.cellName}
        Log All TX Antenna Lines Power
        ${power_after_start}  Get TX Pipes Power From DAPD    ${rmod_sn}
        Compare Power For 5G TM  ${power_before_start}  ${power_after_start}  ${diff_ants}
    END

    Set Test Variable  ${sum_of_ants}

Compare Power For 5G TM
    [Arguments]  ${first_dict}  ${second_dict}  ${sum_of_ants}

    ${first_values}  Get Dictionary Values  ${first_dict}
    ${second_values}  Get Dictionary Values  ${second_dict}

    ${off_ants_first}  Get Match Count  ${first_values}  OFF
    ${off_ants_second}  Get Match Count  ${second_values}  OFF

    ${diff}  Evaluate  ${off_ants_first}-${off_ants_second}

    ${ants_count}  Get Length  ${sum_of_ants}

    Run Keyword And Continue On Failure
    ...  Should Be Equal  ${diff}  ${ants_count}
    ...  Lack of TX power on antenna lines !${\n}Power on ${diff} ants, must be on ${ants_count}!${\n}

Stop Downlink NR Test Model
    [Documentation]
    ...  Stop Downlink NR Test Model
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW stops active NR test models.

    Log To Console   Test model ${USER_NR_DL_TM} will be stopped for cell: \n${NR_CELLS_ID_LIST}
    FOR    ${NR_cell_ID}    IN    @{NR_CELLS_ID_LIST}
        ${cell_parameters}=    admin.Get Parameters For    NRCEL    ${NR_cell_ID}
        Log To Console    Power before Stop Downlink Test Model ${USER_NR_DL_TM} for NR cell ${cell_parameters.cellName}
        Log All TX Antenna Lines Power
        ${rmod_id}  ${ants_list}  Get RMOD Id And Ants For Cell  ${NR_cell_ID}
        ${rmod_sn}  Get RU Serial Number For DistName  ${rmod_id}
        ${power_before_stop}  Get TX Pipes Power From DAPD    ${rmod_sn}
        #${power_before_stop}  Get DAPD TX Power For All Pipes  ${rmod_sn}  print_table=False
        Log To Console    Stop Downlink Test Model ${USER_NR_DL_TM} for NR cell ${cell_parameters.cellName}
        ${stop_tm_status}  Run Keyword And Return Status  admin.Stop 5G Downlink Test  ${NR_cell_ID}
        Run Keyword If    '${stop_tm_status}'=='False'
        ...  Log To Console  No active Test Model ${USER_NR_DL_TM} for ${cell_parameters.cellName} to stoped
        Sleep    10s
        Log To Console    Power after Stop Downlink Test Model ${USER_NR_DL_TM} for ${cell_parameters.cellName}
        Log All TX Antenna Lines Power
    END

#    ${power_after_stop}  Get DAPD TX Power For All Pipes  ${rmod_sn}  print_table=False
#
#    ${ants_values}  Get Dictionary Values  ${power_after_stop}
#    ${ants_count}  Get Length  ${ants_values}
#    ${off_count}  Get Match Count  ${ants_values}  OFF
#    ${status}  Run Keyword And Return Status  Should Be Equal  ${ants_count}  ${off_count}
#
#    Run Keyword If  ${status}  Log to console  All Antenna Lines has no power after TM stop !${\n}
#    ...  ELSE  Run Keyword And Continue On Failure  Fail  Not all antenna lines has no power after TM stop !

    ${active_tm}  admin.Get Active Tests
    Log To Console  Test model ${USER_NR_DL_TM} for NR cell ${NR_CELLS_ID_LIST} was stopped succesfully.

Start Uplink NR Test Model
    [Documentation]
    ...  Start Uplink NR Test Model procedure
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW starts NR uplink test model on selected NR cells.
    ...
    ...  **Input Parameters:**

    Log To Console    Test model ${USER_NR_UL_TM} will be started for cell: \n${NR_CELLS_ID_LIST}
    FOR    ${NR_cell_ID}    IN    @{NR_CELLS_ID_LIST}
        ${cell_parameters}    admin.Get Parameters For    NRCEL    ${NR_cell_ID}
        Log To Console    Start 5G Uplink Test Model ${USER_NR_UL_TM} for NR cell ${cell_parameters.cellName}
        admin.Start 5G Uplink Test  ${NR_cell_ID}  ${USER_NR_UL_TM}  ${BEAM_PATTERN_ID}  ${INTERVAL}  ${PRB_OFFSET}
        ...  ${RU_MODE}  ${PHY_NR_CELL_ID}
    END

Stop Uplink NR Test Model
    [Documentation]
    ...  Stop Uplink NR Test Model
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW stops active test models.
    ...
    ...  **Input Parameters:**

    Log To Console   Test model ${USER_NR_UL_TM} will be stopped for cell: \n${NR_CELLS_ID_LIST}
    FOR    ${NR_cell_ID}    IN    @{NR_CELLS_ID_LIST}
        ${cell_parameters}  admin.Get Parameters For  NRCEL  ${NR_cell_ID}
        Log To Console    Stop Uplink 5G Test Model ${USER_NR_UL_TM} for ${cell_parameters.cellName}
        ${stop_tm_status}    Run Keyword And Return Status  admin.Stop 5G Uplink Test  ${NR_cell_ID}
        Run Keyword If    '${stop_tm_status}'=='False'
        ...  Log To Console    No active Test Model ${USER_NR_UL_TM} for ${cell_parameters.cellName} to stopped
        Run Keyword If    '${stop_tm_status}'=='True'
        ...  Log To Console    Test model ${USER_NR_UL_TM} for ${cell_parameters.cellName} was stopped succesfully.
        Sleep    10s
    END

Start Downlink LTE Test Model
    [Arguments]    ${phy_cell_id}
    [Documentation]
    ...  Start Downlink LTE Test Model procedure
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW logs Tx power on all RM before activate test model, starts downlink LTE test model and
    ...  | logs Tx power on all RM after activate test model.
    ...  | KW set test to NoRun, when meet some problem with start LTE downlink test.
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------+------+--------------------------------+
    ...  | Parameter name | Man. | Description                    |
    ...  +================+======+================================+
    ...  | phy_cell_id    | yes  | Physical Cell Id               |
    ...  +----------------+------+--------------------------------+
    ...  | USER_LTE_DL_TM | yes  | Tesy model from LTE_DL_TM_LIST |
    ...  +----------------+------+--------------------------------+

    Log To Console    ${\n}LTE Test model ${USER_LTE_DL_TM} will be started for cell: \n${LTE_CELLS_ID_LIST}
    FOR    ${LTE_cell_ID}    IN    @{LTE_CELLS_ID_LIST}
        ${cell_name}  Evaluate  '${LTE_cell_ID}'.split('/')[-1]
        ${cell_parameters}  admin.Get Parameters For  LNCEL  ${LTE_cell_ID}
        Log To Console    Power before Start Downlink Test Model ${USER_LTE_DL_TM} for LTE cell ${cell_name}
        # Log Tx Power For All RU
        Log To Console    Start Downlink Test Model ${USER_LTE_DL_TM} for LTE cell ${cell_name}
        Start Downlink Test    ${LTE_cell_ID}    ${USER_LTE_DL_TM}    ${cell_parameters.earfcnDL}    phy_cell_id=${phy_cell_id}
        Sleep    10s
        Log To Console    Power after Start Downlink Test Model ${USER_LTE_DL_TM} for LTE cell ${cell_name}
        # Log Tx Power For All RU
    END

Start Uplink LTE Test Model
    [Arguments]    ${rb_offset_id}
    [Documentation]
    ...  Start Uplink LTE Test Model procedure
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW starts LTE uplink test model on selected LTE cells.
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------+------+-------------------------+
    ...  | Parameter name | Man. | Description             |
    ...  +================+======+=========================+
    ...  | rb_offset_id   | yes  | Resource block offset   |
    ...  +----------------+------+-------------------------+

    Log To Console    Test model ${USER_LTE_UL_TM} will be started for cell: \n${LTE_CELLS_ID_LIST}
    FOR    ${LTE_cell_ID}    IN    @{LTE_CELLS_ID_LIST}
        ${cell_parameters}  admin.Get Parameters For  LNCEL  ${LTE_cell_ID}
        ${cell_name}  Evaluate  '${LTE_cell_ID}'.split('/')[-1]
        Log To Console    Start Uplink Test Model ${USER_LTE_UL_TM} for LTE cell ${cell_name}
        admin.Start Uplink Test    ${LTE_cell_ID}    ${USER_LTE_UL_TM}    1    ${rb_offset_id}    ${cell_parameters.earfcnUL}  BinaryHarq
    END

Start Downlink Test Model TM_1 Or TM_3
    [Arguments]    ${scr_code_id}    ${number_of_dpch}
    [Documentation]
    ...  Start Downlink Test Model TM_1 or TM_3 procedure
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW logs Tx power on all RM before activate test model, starts downlink test model TM_1 or TM_3 and
    ...  | logs Tx power on all RM after activate test model.
    ...  | KW set test to NoRun, when meet some problem with start WCDMA downlink test.
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------+------+-------------------------+
    ...  | Parameter name | Man. | Description             |
    ...  +================+======+=========================+
    ...  | scr_code_id    | yes  | Primary scrambling code |
    ...  +----------------+------+-------------------------+
    ...  | number_of_dpch | yes  | Number of DPCH          |
    ...  +----------------+------+-------------------------+

    Log To Console    Test model ${USER_WCDMA_DL_TM} will be started for cell: \n${WCDMA_CELLS_ID_LIST}
    FOR    ${WCDMA_cell_ID}    IN    @{WCDMA_CELLS_ID_LIST}
        ${WCDMA_cell_Id_str}=    Convert To String   ${WCDMA_cell_ID}
        ${WCDMA_cell_Id_scf_object}=    Replace String     ${WCDMA_cell_Id_str}    R    A
        ${cell_parameters}=    Get Infomodel Object    //${WCDMA_cell_Id_scf_object}
        Log To Console    Power before Start Downlink Test Model ${USER_WCDMA_DL_TM} for WCDMA cell ${WCDMA_cell_ID}
        # Log Tx Power For All RU
        Log To Console    Start Downlink Test Model ${USER_WCDMA_DL_TM} for WCDMA cell ${WCDMA_cell_ID}
        ${start_tm_status}    ${start_tm_print}    Run Keyword And Ignore Error
        ...  Start Wcdma Downlink Test  ${WCDMA_cell_ID}  ${cell_parameters.defaultCarrier}  ${USER_WCDMA_DL_TM}  ${scr_code_id}  ${number_of_dpch}
        Run Keyword If    '${start_tm_status}'=='FAIL'    Fail    ${start_tm_print}
        ...  ELSE  Log To Console
        ...  Command Start Downlink Test Model ${USER_WCDMA_DL_TM} for WCDMA cell ${WCDMA_cell_ID} has status ${start_tm_status}
        Sleep    10s
        Log To Console    Power after Start Downlink Test Model ${USER_WCDMA_DL_TM} for WCDMA cell ${WCDMA_cell_ID}
        # Log Tx Power For All RU
    END

Start Downlink Test Model TM_2
    [Arguments]    ${scr_code_id}    ${number_of_dpch}    ${dpch_power}
    [Documentation]
    ...  Start Downlink Test Model TM_2 procedure
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW logs Tx power on all RM before activate test model, starts downlink test model TM_2 and
    ...  | logs Tx power on all RM after activate test model.
    ...  | KW set test to NoRun, when meet some problem with start WCDMA downlink test.
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------+------+-------------------------+
    ...  | Parameter name | Man. | Description             |
    ...  +================+======+=========================+
    ...  | scr_code_id    | yes  | Primary scrambling code |
    ...  +----------------+------+-------------------------+
    ...  | dpch_power     | yes  | DPCH power              |
    ...  +----------------+------+-------------------------+
    ...  | number_of_dpch | yes  | Number of DPCH          |
    ...  +----------------+------+-------------------------+

    Log To Console    Test model ${USER_WCDMA_DL_TM} will be started for cell: \n${WCDMA_CELLS_ID_LIST}
    FOR    ${WCDMA_cell_ID}    IN    @{WCDMA_CELLS_ID_LIST}
        ${WCDMA_cell_Id_str}  Convert To String  ${WCDMA_cell_ID}
        ${WCDMA_cell_Id_scf_object}  Replace String  ${WCDMA_cell_Id_str}  R  A
        ${cell_parameters}  Get Infomodel Object  //${WCDMA_cell_Id_scf_object}
        Log To Console  Power before Start Downlink Test Model ${USER_WCDMA_DL_TM} for WCDMA cell ${WCDMA_cell_ID}
        # Log Tx Power For All RU
        Log To Console  Start Downlink Test Model ${USER_WCDMA_DL_TM} for WCDMA cell ${WCDMA_cell_ID}
        ${start_tm_status}  ${start_tm_print}  Run Keyword And Ignore Error
        ...  admin.Start Wcdma Downlink Test
        ...  dist_name=${WCDMA_cell_ID}
        ...  uarfcn=${cell_parameters.defaultCarrier}
        ...  test_model=${USER_WCDMA_DL_TM}
        ...  primary_scrambling_code=${scr_code_id}
        ...  number_of_dpch=${number_of_dpch}
        ...  dpch_tx_power=${dpch_power}
        ...  dpch_tx_pwr_ctrl_step_size=0_0
        Run Keyword If    '${start_tm_status}'=='FAIL'  Fail  ${start_tm_print}
        ...  ELSE  Log To Console
        ...  Command Start Downlink Test Model ${USER_WCDMA_DL_TM} for WCDMA cell ${WCDMA_cell_ID} has status ${start_tm_status}
        Sleep    10s
        Log To Console  Power after Start Downlink Test Model ${USER_WCDMA_DL_TM} for WCDMA cell ${WCDMA_cell_ID}
        # Log Tx Power For All RU
    END

Start Downlink Test Model TM_4
    [Arguments]    ${scr_code_id}    ${number_of_dpch}    ${pccpch_sch_power}
    [Documentation]
    ...  Start Downlink Test Model TM_4 procedure
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW logs Tx power on all RM before activate test model, starts downlink test model TM_4 and
    ...  | logs Tx power on all RM after activate test model.
    ...  | KW set test to NoRun, when meet some problem with start WCDMA downlink test.
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+-------------------------+
    ...  | Parameter name   | Man. | Description             |
    ...  +==================+======+=========================+
    ...  | scr_code_id      | yes  | Primary scrambling code |
    ...  +------------------+------+-------------------------+
    ...  | pccpch_sch_power | yes  | P-CCPCH + SCH power     |
    ...  +------------------+------+-------------------------+
    ...  | number_of_dpch   | yes  | Number of DPCH          |
    ...  +------------------+------+-------------------------+

    Log To Console    Test model ${USER_WCDMA_DL_TM} will be started for cell: \n${WCDMA_CELLS_ID_LIST}
    FOR    ${WCDMA_cell_ID}    IN    @{WCDMA_CELLS_ID_LIST}
        ${WCDMA_cell_Id_str}  Convert To String  ${WCDMA_cell_ID}
        ${WCDMA_cell_Id_scf_object}  Replace String  ${WCDMA_cell_Id_str}  R  A
        ${cell_parameters}  Get Infomodel Object  //${WCDMA_cell_Id_scf_object}
        Log To Console  Power before Start Downlink Test Model ${USER_WCDMA_DL_TM} for WCDMA cell ${WCDMA_cell_ID}
        # Log Tx Power For All RU
        Log To Console  Start Downlink Test Model ${USER_WCDMA_DL_TM} for WCDMA cell ${WCDMA_cell_ID}
        ${start_tm_status}  ${start_tm_print}  Run Keyword And Ignore Error
        ...  admin.Start Wcdma Downlink Test
        ...  dist_name=${WCDMA_cell_ID}
        ...  uarfcn=${cell_parameters.defaultCarrier}
        ...  test_model=${USER_WCDMA_DL_TM}
        ...  primary_scrambling_code=${scr_code_id}
        ...  number_of_dpch=${number_of_dpch}
        ...  primary_ccpch_tx_power=${pccpch_sch_power}
        Run Keyword If  '${start_tm_status}'=='FAIL'  Fail  ${start_tm_print}
        ...  ELSE
        ...  Log To Console  Command Start Downlink Test Model ${USER_WCDMA_DL_TM} for WCDMA cell ${WCDMA_cell_ID} has status ${start_tm_status}
        Sleep  10s
        Log To Console  Power after Start Downlink Test Model ${USER_WCDMA_DL_TM} for WCDMA cell ${WCDMA_cell_ID}
        # Log Tx Power For All RU
    END

Start Downlink Test Model TM_5 or TM_6
    [Arguments]    ${scr_code_id}    ${number_of_dpch}    ${number_of_hs_pdsch}
    [Documentation]
    ...  Start Downlink Test Model TM_5 or TM_6 procedure
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW logs Tx power on all RM before activate test model, starts downlink test model TM_5 or TM_6 and
    ...  | logs Tx power on all RM after activate test model.
    ...  | KW set test to NoRun, when meet some problem with start WCDMA downlink test.
    ...
    ...  **Input Parameters:**
    ...
    ...  +--------------------+------+-------------------------+
    ...  | Parameter name     | Man. | Description             |
    ...  +====================+======+=========================+
    ...  | scr_code_id        | yes  | Primary scrambling code |
    ...  +--------------------+------+-------------------------+
    ...  | number_of_hs_pdsch | yes  | Number of HS-PDSCH      |
    ...  +--------------------+------+-------------------------+
    ...  | number_of_dpch     | yes  | Number of DPCH          |
    ...  +--------------------+------+-------------------------+

    Log To Console    Test model ${USER_WCDMA_DL_TM} will be started for cell: \n${WCDMA_CELLS_ID_LIST}
    FOR    ${WCDMA_cell_ID}    IN    @{WCDMA_CELLS_ID_LIST}
        ${WCDMA_cell_Id_str}  Convert To String  ${WCDMA_cell_ID}
        ${WCDMA_cell_Id_scf_object}  Replace String  ${WCDMA_cell_Id_str}  R  A
        ${cell_parameters}  Get Infomodel Object  //${WCDMA_cell_Id_scf_object}
        Log To Console  Power before Start Downlink Test Model ${USER_WCDMA_DL_TM} for WCDMA cell ${WCDMA_cell_ID}
        # Log Tx Power For All RU
        Log To Console  Start Downlink Test Model ${USER_WCDMA_DL_TM} for WCDMA cell ${WCDMA_cell_ID}
        ${start_tm_status}  ${start_tm_print}  Run Keyword And Ignore Error
        ...  admin.Start Wcdma Downlink Test
        ...  dist_name=${WCDMA_cell_ID}
        ...  uarfcn=${cell_parameters.defaultCarrier}
        ...  test_model=${USER_WCDMA_DL_TM}
        ...  primary_scrambling_code=${scr_code_id}
        ...  number_of_dpch=${number_of_dpch}
        ...  number_of_hs_pdsch=${number_of_hs_pdsch}
        Run Keyword If  '${start_tm_status}'=='FAIL'  Fail  ${start_tm_print}
        ...  ELSE
        ...  Log To Console  Command Start Downlink Test Model ${USER_WCDMA_DL_TM} for WCDMA cell ${WCDMA_cell_ID} has status ${start_tm_status}
        Sleep  10s
        Log To Console  Power after Start Downlink Test Model ${USER_WCDMA_DL_TM} for WCDMA cell ${WCDMA_cell_ID}
        # Log Tx Power For All RU
    END

Start Uplink Test Model BER/BLER
    [Arguments]    ${scr_code_id}
    [Documentation]
    ...  Start Uplink Test Model BER/BLER procedure
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW logs Tx power on all RM before activate test model, starts uplink test model BER/BLER
    ...  | and logs Tx power on all RM after activate test model.
    ...  | KW set test to Fail, when meet some problem with start WCDMA uplink test.
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------+------+-------------------------+
    ...  | Parameter name | Man. | Description             |
    ...  +================+======+=========================+
    ...  | scr_code_id    | yes  | Scrambling code         |
    ...  +----------------+------+-------------------------+

    Log To Console    Test model ${USER_WCDMA_UL_TM} will be started for cell: \n${WCDMA_CELLS_ID_LIST}
    FOR    ${WCDMA_cell_ID}    IN    @{WCDMA_CELLS_ID_LIST}
        ${WCDMA_cell_Id_str}  Convert To String  ${WCDMA_cell_ID}
        ${WCDMA_cell_Id_scf_object}  Replace String  ${WCDMA_cell_Id_str}  R  A
        ${cell_parameters}  Get Infomodel Object  //${WCDMA_cell_Id_scf_object}
        Log To Console  Start Uplink Test Model ${USER_WCDMA_UL_TM} for WCDMA cell ${WCDMA_cell_ID}
        ${start_tm_status}  ${start_tm_print}  Run Keyword And Ignore Error
        ...  admin.Start Wcdma Uplink Test
        ...  dist_name=${WCDMA_cell_ID}
        ...  uarfcn=${cell_parameters.defaultCarrier}
        ...  uplink_scrambling_code=${scr_code_id}
        Run Keyword If  '${start_tm_status}'=='FAIL'  Fail    ${start_tm_print}
        ...  ELSE
        ...  Log To Console  Command Start Uplink Test Model ${USER_WCDMA_UL_TM} for WCDMA cell ${WCDMA_cell_ID} has status ${start_tm_status}
    END

Stop Uplink WCDMA Test Model
    [Arguments]    ${scr_code_id}
    [Documentation]
    ...  Stop Uplink WCDMA Test Model
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW stops active test models.
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------+------+-------------------------+
    ...  | Parameter name | Man. | Description             |
    ...  +================+======+=========================+
    ...  | scr_code_id    | yes  | Scrambling code         |
    ...  +----------------+------+-------------------------+

    Log To Console   Test model ${USER_WCDMA_UL_TM} will be stopped for cell: \n${WCDMA_CELLS_ID_LIST}
    FOR    ${WCDMA_cell_ID}    IN    @{WCDMA_CELLS_ID_LIST}
        ${WCDMA_cell_Id_str}  Convert To String  ${WCDMA_cell_ID}
        ${WCDMA_cell_Id_scf_object}  Replace String   ${WCDMA_cell_Id_str}  R  A
        ${cell_parameters}  Get Infomodel Object  //${WCDMA_cell_Id_scf_object}
        Log To Console  Stop Uplink Test Model ${USER_WCDMA_UL_TM} for WCDMA cell ${WCDMA_cell_ID}
        ${stop_tm_status}  Run Keyword And Return Status  admin.Stop Wcdma Uplink Test  ${WCDMA_cell_ID}
        Run Keyword If  '${stop_tm_status}'=='False'
        ...  Log To Console  No active Test Model ${USER_WCDMA_UL_TM} for WCDMA cell ${WCDMA_cell_ID} to stoped
        ...  ELSE
        ...  Log To Console  Command Stop Uplink Test Model ${USER_WCDMA_UL_TM} for WCDMA cell ${WCDMA_cell_ID} has status ${stop_tm_status}
    END
    Log To Console  Test model ${USER_WCDMA_UL_TM} for WCDMA cell ${WCDMA_CELLS_ID_LIST} was stopped succesfully.

Stop Downlink WCDMA Test Model
    [Arguments]    ${scr_code_id}
    [Documentation]
    ...  Stop Downlink WCDMA Test Model
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW stops active test models.
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------+------+-------------------------+
    ...  | Parameter name | Man. | Description             |
    ...  +================+======+=========================+
    ...  | scr_code_id    | yes  | Primary scrambling code |
    ...  +----------------+------+-------------------------+

    Log To Console   Test model ${USER_WCDMA_DL_TM} will be stopped for cell: \n${WCDMA_CELLS_ID_LIST}
    FOR    ${WCDMA_cell_ID}    IN    @{WCDMA_CELLS_ID_LIST}
        ${WCDMA_cell_Id_str}  Convert To String  ${WCDMA_cell_ID}
        ${WCDMA_cell_Id_scf_object}  Replace String  ${WCDMA_cell_Id_str}  R  A
        ${cell_parameters}  Get Infomodel Object  //${WCDMA_cell_Id_scf_object}
        Log To Console  Power before Stop Downlink Test Model ${USER_WCDMA_DL_TM} for WCDMA cell ${WCDMA_cell_ID}
        # Log Tx Power For All RU
        Log To Console  Stop Downlink Test Model ${USER_WCDMA_DL_TM} for WCDMA cell ${WCDMA_cell_ID}
        ${stop_tm_status}  Run Keyword And Return Status  admin.Stop Wcdma Downlink Test  ${WCDMA_cell_ID}
        Run Keyword If  '${stop_tm_status}'=='False'
        ...  Log To Console   No active Test Model ${USER_WCDMA_DL_TM} for WCDMA cell ${WCDMA_cell_ID} to stoped
        ...  ELSE
        ...  Log To Console  Command Stop Downlink Test Model ${USER_WCDMA_DL_TM} for WCDMA cell ${WCDMA_cell_ID} has status ${stop_tm_status}
        Log To Console  Power after Stop Downlink Test Model ${USER_WCDMA_DL_TM} for WCDMA cell ${WCDMA_cell_ID}
        # Log Tx Power For All RU
    END
    Log To Console  Test model ${USER_WCDMA_DL_TM} for WCDMA cell ${WCDMA_CELLS_ID_LIST} was stopped succesfully.

Stop Uplink LTE Test Model
    [Arguments]    ${rb_offset_id}
    [Documentation]
    ...  Stop Uplink LTE Test Model
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW stops active test models.
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------+------+-------------------------+
    ...  | Parameter name | Man. | Description             |
    ...  +================+======+=========================+
    ...  | rb_offset_id   | yes  | Resource block offset   |
    ...  +----------------+------+-------------------------+

    Log To Console  Test model ${USER_LTE_UL_TM} will be stopped for cell: \n${LTE_CELLS_ID_LIST}
    FOR    ${LTE_cell_ID}    IN    @{LTE_CELLS_ID_LIST}
        ${cell_parameters}  admin.Get Parameters For  LNCEL  ${LTE_cell_ID}
        Log To Console  Stop Uplink Test Model ${USER_LTE_UL_TM} for LTE cell ${cell_parameters.id}
        ${stop_tm_status}  Run Keyword And Return Status  admin.Stop Uplink Test  ${LTE_cell_ID}
        Run Keyword If  '${stop_tm_status}'=='False'
        ...  Log To Console  No active Test Model ${USER_LTE_UL_TM} for LTE cell ${cell_parameters.id} to stopped
        Run Keyword If  '${stop_tm_status}'=='True'  Log To Console  Test model ${USER_LTE_UL_TM} for LTE cell ${LTE_cell_ID} was stopped succesfully
        Sleep  10s
    END

Stop Downlink LTE Test Model
    [Arguments]    ${phy_cell_id}
    [Documentation]
    ...  Stop Downlink LTE Test Model
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW stops active LTE test models.
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------+------+-------------------------+
    ...  | Parameter name | Man. | Description             |
    ...  +================+======+=========================+
    ...  | phy_cell_id    | yes  | Physical Cell Id        |
    ...  +----------------+------+-------------------------+

    Log To Console  Test model ${USER_LTE_DL_TM} will be stopped for cell: \n${LTE_CELLS_ID_LIST}
    FOR    ${LTE_cell_ID}    IN    @{LTE_CELLS_ID_LIST}
        ${cell_parameters}  admin.Get Parameters For  LNCEL  ${LTE_cell_ID}
        Log To Console  Power before Stop Downlink Test Model ${USER_LTE_DL_TM} for LTE cell ${cell_parameters.id}
        # Log Tx Power For All RU
        Log To Console  Stop Downlink Test Model ${USER_LTE_DL_TM} for LTE cell ${cell_parameters.id}
        ${stop_tm_status}  Run Keyword And Return Status  admin.Stop Downlink Test  ${LTE_cell_ID}
        Run Keyword If  '${stop_tm_status}'=='False'
        ...  Log To Console  No active Test Model ${USER_LTE_DL_TM} for LTE cell ${cell_parameters.id} to stoped
        Sleep  10s
        Log To Console  Power after Stop Downlink Test Model ${USER_LTE_DL_TM} for LTE cell ${cell_parameters.id}
        # Log Tx Power For All RU
    END
    ${active_tm}  admin.Get Active Tests
    Log To Console  Test model ${USER_LTE_DL_TM} for LTE cell ${LTE_CELLS_ID_LIST} was stopped succesfully.

Check Active Downlink Test Models
    [Documentation]
    ...  Check Active NR Downlink Test Models procedure
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW check if NR TM is Active in Admin Api.
    ...  | KW use Get Active Tests. If TM is Active, KW return ${active_tm_status} value "PASS".
    ...  | If TM is inActive, KW return ${active_tm_status} value "FAIL".
    ...
    ...  **Input Parameters:**
    ...
    ...  +--------------------+------+------------------------------------------+
    ...  | Parameter name     | Man. | Description                              |
    ...  +====================+======+==========================================+
    ...  | phy_cell_id        | yes  | Physical Cell Id                         |
    ...  +--------------------+------+------------------------------------------+

    [Arguments]  ${rat}
    Log To Console  Checking active ${rat} Downlink Test Models ...${\n}
    ${number_cells}  Run Keyword If  '${rat}'=='NR'  Get Length  ${NR_CELLS_ID_LIST}
    ...  ELSE  Get Length  ${LTE_CELLS_ID_LIST}
    Sleep  10s
    ${active_tm}  admin.Get Active Tests
    ${active_tm_str}  Convert To String  ${active_tm}
    ${active_downlink_tm}   Run Keyword If  '${rat}'=='NR'  Get Regexp Matches  ${active_tm_str}  NR_DOWNLINK
    ...  ELSE  Get Regexp Matches  ${active_tm_str}  LTE_DOWNLINK
    ${active_tm_status}  ${active_tm_msg}   Run Keyword And Ignore Error
    ...  Should Not Be Empty  ${active_tm}  msg=No active ${rat} Downlink Test Models
    Run Keyword If  '${active_tm_status}'=='FAIL'  Log To Console  ${active_tm_msg}
    ${active_tm_status}  ${active_tm_msg}  Run Keyword And Ignore Error
    ...  Length Should Be  ${active_downlink_tm}  ${number_cells}  msg=Tested ${rat} Downlink Test Model is not active on all chosen cells
    Run Keyword If  '${active_tm_status}'=='FAIL'  Log To Console  ${active_tm_msg}
    Run Keyword If  '${active_tm_status}'=='PASS'  Log To Console  ${rat} Downlink Test Model(s) is active for ${number_cells} cells !${\n}
    [Return]    ${active_tm_status}

Check Active NR Uplink Test Models
    [Documentation]
    ...  Check Active LTE Uplink Test Models procedure
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW check if LTE TM is Active in Admin Api.
    ...  | KW use Assert Uplink Test Results.
    ...  | If TM is Active, KW append value "PASS" in list ${active_tm_status}.
    ...  | If TM is inActive, KW append value "FAIL" in list ${active_tm_status}.
    ...  | KW returns ${active_tm_status} containing items "PASS" and "FAIL".

    Log To Console  Check Active NR Uplink Test Models${\n}
    ${active_tm_status}  Create List
    FOR    ${NR_cell_ID}    IN    @{NR_CELLS_ID_LIST}
        ${cell_parameters}  admin.Get Parameters For  NRCEL  ${NR_cell_ID}
        ${active_tm}  ${active_tm_msg}  Run Keyword And Ignore Error  admin.Watch 5G Uplink Test Results  ${NR_cell_ID}  timeout=10
        Run Keyword If  '${active_tm}'=='FAIL'  Log To Console  No active NR Uplink Test Model for ${cell_parameters.cellName}!
        Run Keyword If  '${active_tm}'=='PASS'  Log To Console  NR Uplink Test Model ${USER_NR_UL_TM} for ${cell_parameters.cellName} is active!
        Append To List  ${active_tm_status}  ${active_tm}
    END
    Log to console  ${\n}

    [Return]    ${active_tm_status}

Check Active LTE Uplink Test Models
    [Arguments]    ${rb_offset_id}    ${check_active_tm_info}
    [Documentation]
    ...  Check Active LTE Uplink Test Models procedure
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW check if LTE TM is Active in Admin Api.
    ...  | KW use Assert Uplink Test Results.
    ...  | If TM is Active, KW append value "PASS" in list ${active_tm_status}.
    ...  | If TM is inActive, KW append value "FAIL" in list ${active_tm_status}.
    ...  | KW returns ${active_tm_status} containing items "PASS" and "FAIL".
    ...
    ...  **Input Parameters:**
    ...
    ...  +---------------------+------+------------------------------------------+
    ...  | Parameter name      | Man. | Description                              |
    ...  +=====================+======+==========================================+
    ...  | rb_offset_id        | yes  | Resource block offset                    |
    ...  +---------------------+------+------------------------------------------+
    ...  | check_active_tm_info| yes  | Active TM Info after start/stop TM       |
    ...  +---------------------+------+------------------------------------------+

    Log To Console  Check Active LTE Uplink Test Models ${check_active_tm_info}
    ${active_tm_status}  Create List
    FOR    ${LTE_cell_ID}    IN    @{LTE_CELLS_ID_LIST}
        ${cell_name}  Evaluate  '${LTE_cell_ID}'.split('/')[-1]
        ${cell_parameters}  admin.Get Parameters For  LNCEL  ${LTE_cell_ID}
        ${active_tm}  ${active_tm_msg}  Run Keyword And Ignore Error  admin.Assert Uplink Test Results  ${LTE_cell_ID}  timeout=10
        Run Keyword If  '${active_tm}'=='FAIL'  Log To Console  No active LTE Uplink Test Model for LTE cell ${LTE_cell_ID}
        Run Keyword If  '${active_tm}'=='PASS'  Log To Console  LTE Uplink Test Model ${USER_LTE_UL_TM} or ${cell_name} is active!
        Append To List  ${active_tm_status}  ${active_tm}
    END
    [Return]    ${active_tm_status}

Check Active WCDMA Downlink Test Models
    [Documentation]
    ...  Check Active Test Models TM_1 or TM_3 procedure
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW check if TM is Active in Info Model.
    ...  | KW check in Info Model if WCDMA_DOWNLINK_TEST has status Active. If TM is Active, KW append value "True" in list ${tm_status_list}.
    ...  | If TM is inActive, KW append value "False" in list ${tm_status_list}.
    ...  | KW returns ${tm_status_list} containing items "True" and "False".


    Log To Console    Check Active WCDMA Downlink Test Models

    ${tm_status_list}  Create List
    FOR    ${WCDMA_cell_ID}    IN    @{WCDMA_CELLS_ID_LIST}
        ${active_tm_status}  Run Keyword And Return Status
        ...  Wait until keyword succeeds  0 min  15 sec
        ...  ute_admin_infomodel.Query infomodel  query=check //${WCDMA_cell_ID}/WCDMA_DOWNLINK_TEST-* is [stateInfo.usageState=Active]
        Run Keyword If  '${active_tm_status}'=='False'
        ...  Log To Console  For WCDMA cell ${WCDMA_cell_ID}, ${USER_WCDMA_DL_TM} Downlink Test Model is NOT active
        ...  ELSE  Log To Console  For WCDMA cell ${WCDMA_cell_ID}, ${USER_WCDMA_DL_TM} Downlink Test Model is active
        Append To List  ${tm_status_list}  ${active_tm_status}
    END

    [Return]    ${tm_status_list}

Check Active Test Models BER/BLER
    [Documentation]
    ...  Check Active Test Models BER/BLER procedure
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW check if TM is Active in Info Model and Admin Api output.
    ...  | KW check in Info Model if WCDMA_UPLINK_TEST has status Active. If TM is Active, KW append value "True" in list ${tm_status_list}.
    ...  | If TM is inActive, KW append value "False" in list ${tm_status_list}.
    ...  | KW check last watch Periodic Result. If TM is Active, KW append value "True" in list ${tm_status_list}
    ...  | If TM is inActive, KW append value "False" in list ${tm_status_list}.
    ...  | KW returns ${tm_status_list} containing items "True" and "False".
    ...
    ...  **Input Parameters:**
    ...
    ...  +--------------------+------+------------------------------------------+
    ...  | Parameter name     | Man. | Description                              |
    ...  +====================+======+==========================================+
    ...  | scr_code_id        | yes  | Scrambling code                          |
    ...  +--------------------+------+------------------------------------------+

    Log To Console    Check Active WCDMA Uplink Test Model
    ${tm_status_list}  Create List
    FOR    ${WCDMA_cell_ID}    IN    @{WCDMA_CELLS_ID_LIST}
        ${active_tm_status}  Run Keyword And Return Status
        ...  Wait until keyword succeeds  0 min  15 sec
        ...  ute_admin_infomodel.Query infomodel  query=check //${WCDMA_cell_ID}/WCDMA_UPLINK_TEST-* is [stateInfo.usageState=Active]
        Run Keyword If  '${active_tm_status}'=='False'
        ...  Log To Console  For WCDMA cell ${WCDMA_cell_ID}, ${USER_WCDMA_UL_TM} Uplink Test Model is NOT active
        ...  ELSE
        ...  Log To Console  For WCDMA cell ${WCDMA_cell_ID}, ${USER_WCDMA_UL_TM} Uplink Test Model is active
        ${active_tm_admin}  ${active_tm_admin_msg}  Run Keyword And Ignore Error
        ...  admin.Watch Periodic Results    ${WCDMA_cell_ID}    watch_time=10
        Run Keyword If  '${active_tm_admin}'=='PASS'
        ...  Log To Console    Admin Api output - active ${USER_WCDMA_UL_TM} for cell ${WCDMA_cell_ID}: \n${active_tm_admin_msg}
        ...  ELSE  Log To Console  Admin Api output - inactive ${USER_WCDMA_UL_TM} for cell ${WCDMA_cell_ID}
        Run Keyword If  '${active_tm_admin}'=='PASS'  Append To List  ${tm_status_list}  ${True}
        ...  ELSE  Append To List  ${tm_status_list}  ${False}
        Append To List  ${tm_status_list}  ${active_tm_status}
    END
    [Return]    ${tm_status_list}

#Check if BTS is in Test Dedicated State
#    [Arguments]    ${wcdma_configured}
#    [Documentation]
#    ...  Check if BTS is in Test Dedicated State
#    ...
#    ...  | **Author:** lukasz.wystup@nokia.com
#    ...  | **Maintainer:** lukasz.wystup@nokia.com
#    ...
#    ...  | **Full description:**
#    ...  | This KW check in Info Model if TDS is active. KW failed if can't find information about testing state activity during 1 min.
#
#    Wait until keyword succeeds  1 min  5 sec
#    ...  ute_admin_infomodel.Query infomodel  query=check /MRBTS-1/RAT-*/MCTRL-*/BBTOP_M-1/MRBTS_M-1 is [stateInfo.testingState=Enabled]
#    Run Keyword If  ${wcdma_configured}==True
#    ...  Wait until keyword succeeds  1 min  5 sec
#    ...  ute_admin_infomodel.Query infomodel  query=check /MRBTS-1/RAT-*/WTS-*/WBTS_L-1 is [stateInfo.testingState=Enabled]

Get Ids For User NR Cell
    [Documentation]
    ...  Get Ids For User NR Cell
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW creates list with NRCEL_R-* objects from input string with NR Cell Ids.
    ...  | If enter Cell Id does not exist in configuration KW Fail.
    ...  | KW create test variable ${NR_CELLS_ID_LIST}.

    ${user_NR_cell_list}  Split String  ${USER_NR_CELL}  separator=,
    ${NR_CELLS_ID_LIST}   Create List
    FOR    ${USER_NR_CELL}    IN    @{user_NR_cell_list}
        ${exist_NR_cell_dist}  ${NR_cell_dist}  Run Keyword And Ignore Error
        ...  Get Infomodel Object   /MRBTS-1/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/NRBTS_R-*/NRCELL_R-${USER_NR_CELL}
        Run Keyword If  '${exist_NR_cell_dist}'=='PASS'  Append To List  ${NR_CELLS_ID_LIST}  ${NR_cell_dist.dist_name}
        Run Keyword If  '${exist_NR_cell_dist}'=='FAIL'
        ...  Fail  Incorrect input data - NR cell ID ${USER_NR_CELL} does not exist in configuration
    END
    Set Test Variable    ${NR_CELLS_ID_LIST}

Get Ids For All NR Cells
    [Documentation]
    ...  Get Ids For All NR Cells
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW creates list with NRCELL_R-* objects for NR Cells in configuration.
    ...  | KW create test variable ${NR_CELLS_ID_LIST}.

    @{NR_CELLS_ID_LIST}  admin.Get Ids For All  NRCEL
    Set Test Variable  ${NR_CELLS_ID_LIST}

Get Ids For User LTE Cell
    [Documentation]
    ...  Get Ids For User LTE Cell
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW creates list with LNCEL_R-* objects from input string with LTE Cell Ids.
    ...  | If enter Cell Id does not exist in configuration KW Fail.
    ...  | KW create test variable ${LTE_CELLS_ID_LIST}.

    ${user_LTE_cell_list}  Split String  ${USER_LTE_CELL}  separator=,
    ${LTE_CELLS_ID_LIST}  Create List
    FOR    ${USER_LTE_CELL}    IN    @{user_LTE_cell_list}
        ${exist_LTE_cell_dist}  ${LTE_cell_dist}  Run Keyword And Ignore Error
        ...  Get Infomodel Object   /MRBTS-1/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-*/LNCEL_R-${USER_LTE_CELL}
        Run Keyword If  '${exist_LTE_cell_dist}'=='PASS'  Append To List  ${LTE_CELLS_ID_LIST}  ${LTE_cell_dist.dist_name}
        Run Keyword If  '${exist_LTE_cell_dist}'=='FAIL'
        ...  Fail  Incorrect input data - LTE cell ID ${USER_LTE_CELL} does not exist in configuration
    END
    Set Test Variable    ${LTE_CELLS_ID_LIST}

Get Ids For All LTE Cells
    [Documentation]
    ...  Get Ids For All LTE Cells
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW creates list with LNCEL_R-* objects for LTE Cells in configuration.
    ...  | KW create test variable ${LTE_CELLS_ID_LIST}.

    @{LTE_CELLS_ID_LIST}  admin.Get Ids For All  LNCEL
    Set Test Variable  ${LTE_CELLS_ID_LIST}

Get Ids For All WCDMA Cells
    [Documentation]
    ...  Get Ids For All WCDMA Cells
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW creates list with WNCEL_R-* objects for WCDMA Cells in configuration.
    ...  | KW create test variable ${WCDMA_CELLS_ID_LIST}.

    @{WCDMA_CELLS_ID_LIST}  admin.Get All Items By Class Name  WNCEL
    Set Test Variable  ${WCDMA_CELLS_ID_LIST}

Get Ids For User WCDMA Cell
    [Documentation]
    ...  Get Ids For User WCDMA Cell
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW creates list with WNCEL_R-* objects from input string with WCDMA CellIds. If enter CellId does not exist in configuration KW Fail.
    ...  | KW create test variable ${WCDMA_CELLS_ID_LIST}.

    ${user_WCDMA_cell_list}  Split String  ${USER_WCDMA_CELL}  separator=,
    ${WCDMA_CELLS_ID_LIST}  Create List
    ${all_WCDMA_cell}  admin.Get All Items By Class Name  WNCEL
    FOR    ${USER_WCDMA_CELL}    IN    @{user_WCDMA_cell_list}
        ${exist_WCDMA_cell_class}  Run Keyword And Return Status  Should Contain  ${all_WCDMA_cell}  WNCEL_R-${USER_WCDMA_CELL}
        Run Keyword If  '${exist_WCDMA_cell_class}'=='True'  Append To List  ${WCDMA_CELLS_ID_LIST}  WNCEL_R-${USER_WCDMA_CELL}
        Run Keyword If  '${exist_WCDMA_cell_class}'=='False'
        ...  Fail  Incorrect input data - WCDMA cell ID ${USER_WCDMA_CELL} does not exist in configuration
    END
    Set Test Variable  ${WCDMA_CELLS_ID_LIST}

Check Possibility Run LTE Test Model
    [Documentation]
    ...  Check Possibility Run LTE Test Model
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    ...
    ...  | **Full description:**
    ...  | This KW check if selected LTE cells have correct ChBw for select LTE Uplink Test Model.
    ...  | If not set test to NoRun.

    FOR    ${LTE_cell_ID}    IN    @{LTE_CELLS_ID_LIST}
        ${cell_parameters}  admin.Get Parameters For  LNCEL  ${LTE_cell_ID}
        ${bandwidth_correctness}  Run Keyword And Return Status
        ...  Should Contain  ${${USER_LTE_UL_TM}}  ${cell_parameters.downlinkChannelBandwidth}
        Run Keyword If  '${bandwidth_correctness}'=='True'
        ...  Log To Console
        ...  Bandwidth ${cell_parameters.downlinkChannelBandwidth} cell ${cell_parameters.id} allows run LTE Uplink Test Model ${USER_LTE_UL_TM}
        ...  ELSE
        ...  Fail  LTE Uplink Test Model ${USER_LTE_UL_TM} can be run only for cell bandwidth: ${${USER_LTE_UL_TM}}
    END
