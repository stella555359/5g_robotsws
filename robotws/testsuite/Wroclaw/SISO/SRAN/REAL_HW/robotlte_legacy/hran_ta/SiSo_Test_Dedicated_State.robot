*** Settings ***
Documentation
...  Test -> SiSo_Test_Dedicated_State

Resource    resources/ca_BSRF_general.robot
Library  taf.sbts.oam.coam.admin    WITH NAME    admin
Library     ute_admin_infomodel
Library     Collections
Library     String



*** Keywords ***
SiSo_Test_Dedicated_State
    [Documentation]
    ...   *****************
    ...   Basic information
    ...   *****************
    ...
    ...  The purpose of this TC is to check if enabling / disabling "Test Dedicated State" has unexpected influence on BTS.
    ...  After reaching TDS TC checks value of RATs state from Infomodel and RAT's state from WeBem -
    ...  - in both cases it should be changed to "test".
    ...  After exiting TDS (by performing Site Reset) TC checks if BTS reaches onAir.
    ...
    ...  ***IMPORTANT***
    ...
    ...  Individual Keywords are based on "ca_BSRF_general.robot" file. Any changes of Keywords:
    ...  Check If All Cells Are OnAir,
    ...  Time To Sleep,
    ...  have influence on this testcase!!!
    ...
    ...    References: LTE_OPR_REQ_8956, LTE_OPR_REQ_9378, LTE_OPR_REQ_19958
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 24.10.2022 - initial creation
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  ::image:: https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-13236.png


    Set Tags    CA-BS-RF    OWNER-szymon.natanek@nokia.com    AUTHOR-szymon.natanek@nokia.com
    ...    MAINTAINER-mateusz.kawka@nokia.com    GROUP_IN_CHARGE-WRO_3_Vrf    PHASE-CRT    SW-SBTS22R3
    ...    FEATURE-RP001548
  Common Test Setup
  Logging With Timestamp
  ...  message=Execute Recommissioning On Every Node on list : @{CFG.active_bts_list} will be executed
  ...  style=ONGOING
    SiSo_Test_Dedicated_State.step1: Preconditions
    step2: Enable Test Dedicated State
    step3: Check Test Dedicated State on specified RAT
    step4: Disable Test Dedicated State
  [Teardown]    Common Test Teardown


step1: Preconditions

    Log to console  -------------------------------------------
    Log to console  Step1: Preconditions - check avaliable RATs
    Log to console  -------------------------------------------

    ${AVAILABLE_RAT_LIST}  Create List

    ${lncell_list}  Get Ids For All  LNCEL  search_for_iot_cells=${True}  connection=${node}
    Run Keyword If  len(${lncell_list}) != 0  Run Keywords
    ...  Print Available Cells  ${lncell_list}
    ...  AND  Append To List  ${AVAILABLE_RAT_LIST}  LNBTS

    ${nrcell_list}  Get Ids For All  NRCEL  connection=${node}
    Run Keyword If  len(${nrcell_list}) != 0  Run Keywords
    ...  Print Available Cells  ${nrcell_list}
    ...  AND  Append To List  ${AVAILABLE_RAT_LIST}  NRBTS

    ${wncell_list}  Get Ids For All  WNCEL  connection=${node}
    Run Keyword If  len(${wncell_list}) != 0  Run Keywords
    ...  Print Available Cells  ${wncell_list}
    ...  AND  Append To List  ${AVAILABLE_RAT_LIST}  WNBTS

    ${gncell_list}  Get Ids For All  GNCEL  connection=${node}
    Run Keyword If  len(${gncell_list}) != 0  Run Keywords
    ...  Print Available Cells  ${gncell_list}
    ...  AND  Append To List  ${AVAILABLE_RAT_LIST}  GNBTS

    Set Test Variable  ${AVAILABLE_RAT_LIST}


step2: Enable Test Dedicated State

    Log to console  ----------------------------------
    Log to console  Step2: Enable Test Dedicated State
    Log to console  ----------------------------------${\n}

    Log to console  Resetting to TDS State...
    Reset To Test Dedicated  timeout=1200  connection=${node}

    Wait Until Keyword Succeeds  30min  10s  Check MrBTS State  Test


step3: Check Test Dedicated State on specified RAT

    Log to console  --------------------------------------------------
    Log to console  step3: Check Test Dedicated State on specified RAT
    Log to console  --------------------------------------------------${\n}

    Log to console  Checking if specified RAT turned operationalState to Test

    Wait Until Keyword Succeeds  40min  10s  Check RAT State from Infomodel  test


step4: Disable Test Dedicated State

    Log to console  --------------------------------------------
    Log to console  step4: Disable Test Dedicated State
    Log to console  -------------------------------------------${\n}

    Log to console  Exiting Test Dedicated State...

    Reset Site  timeout=1200  connection=${node}

    Wait Until Keyword Succeeds  40min  10s  Check MrBTS State  OnAir

    Wait Until Keyword Succeeds  40min  10s  Check RAT State from Infomodel  onAir

    ${cell_status}  Run Keyword And Return Status  Check If All Cells Are onAir  alias=${node}  timeout=120
    Run Keyword If  '${cell_status}'=='True'
    ...  Log to console  All cells are onAir !${\n}
    ...  ELSE
    ...  Fail  Cells doesn't reach onAir state!


Check MrBTS State
    [Arguments]  ${expected_state}

    ${expected_state}  Convert To Lower Case  ${expected_state}

    ${bts_state}  Get Mrbts State  connection=${node}
    ${bts_state}  Convert To Lower Case  ${bts_state}

    Run Keyword If  '${bts_state}' == '${expected_state}'
    ...  Log to console  MrBTS has required state! -> ${expected_state}${\n}
    ...  ELSE
    ...  Fail  MrBTS has not required state! -> ${expected_state}


Check RAT State from Infomodel
    [Arguments]  ${expected_state}

    @{temp_list}  Create List
    FOR  ${RAT}  IN  @{AVAILABLE_RAT_LIST}
        ${temp_status}  Run Keyword And Return Status
        ...  admin_im.Query Infomodel
        ...  query=check /MRBTS-1/RAT-1/RUNTIME_VIEW-*/MRBTS_R-*/${RAT}_R-* is [operationalState=regex"(?i)${expected_state}"]
        ...  alias=${node}
        Run Keyword If  '${temp_status}' == 'False'
        ...  Run Keywords
        ...  Append To List  ${temp_list}  ${RAT}
        ...  AND  Log to console  ${RAT} is not in expected state! -> ${expected_state}
        ...  ELSE
        ...  Log to console  ${RAT} is in expected state! -> ${expected_state}
    END

    Should Be Empty  ${temp_list}


Print Available Cells
    [Arguments]  ${cells_list}

    ${rat_name}  Get Regexp Matches  ${cells_list}[0]  [a-zA-Z]+BTS
    Log To Console  ${\n}List of cells for ${rat_name}[-1]:${\n}

    FOR  ${cell_dn}  IN  @{cells_list}
        ${cell}  Evaluate  '${cell_dn}'.split('/')[-1]
        Log To Console  ${cell}
    END




