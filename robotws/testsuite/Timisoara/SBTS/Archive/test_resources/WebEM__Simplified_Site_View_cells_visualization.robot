*** Settings ***
Resource    ../../common_resources/ca_WebEM_mobile.robot


*** Variables ***
${RECOVERY_TIMEOUT}    1200           #Timeout for SBTS to recover
${LOCKED_TIMEOUT}      180            #Timeout for cell to be locked


*** Keywords ***
TC__WebEM__Simplified_Site_View_cells_visualization
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-22514
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This test case lock/unlock a random cell.
    ...  Perform this TC on SBTS with NR and LTE.
    ...  Verify if GSM cells exist and check "GSM cells" text to be visible.
    ...  Verify if WCDMA cells exist and check "WCDMA cells" text to be visible.
    ...  Verify if LTE cells exist and check "LTE cells" text to be visible. If doesn't exist LTE cells, test will be failed.
    ...  Verify if NR cells exist and check "NR cells" text to be visible. If doesn't exist NR cells, test will be failed.
    ...  A random LTE or NR cell is taken.
    ...  This cell will be locked.
    ...  Verify if locked icon is visible on the specific cell.
    ...  Unlock cell will be performed.
    ...  Verify all cells to be online.
    ...  History of changes
    ...  ******************
    ...  - 20.01.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22514 - Initial TAT creation
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice
    ...  - 15.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24316 - Refactor WebEM TCs and resources to use KWs from ca_SBTS_general

    Set Tags    CA-WebEM    OWNER-george.gheban@nokia.com    AUTHOR-andreea.burtic@nokia.com
    ...    MAINTAINER-andreea.burtic@nokia.com    GROUP_IN_CHARGE-TIM_3_Vrf     PHASE-CRT    SW-SBTS22

    Step1: Verify all cells on SBTS
    Step2: Get a random LTE or NR cell
    Step3: Lock cell
    Step4: Unlock cell


Step1: Verify all cells on SBTS
    Log  Step1: Verify all cells on SBTS  console=true
    Log  Check if GSM cells exist...  console=true
    Run keyword if  ${SCF_COUNT_GSM}
    ...  Verify specific cells  GSM
    ...  ELSE
    ...  Log  There are no GSM cells on SBTS!  console=true
    Log  Check if WCDMA cells exist...  console=true
    Run keyword if  ${SCF_COUNT_WCDMA}
    ...  Verify specific cells  WCDMA
    ...  ELSE
    ...  Log  There are no WCDMA cells on SBTS!  console=true
    Log  Check if LTE cells exist...  console=true
    Run keyword if  ${SCF_COUNT_LTE}
    ...  Verify specific cells  LTE
    ...  ELSE
    ...  Fail  There are no LTE cells on SBTS!
    Log  Check if NR cells exist...  console=true
    Run keyword if  ${SCF_COUNT_NR}
    ...  Verify specific cells  NR
    ...  ELSE
    ...  Fail  There are no NR cells on SBTS!
    Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}

Step2: Get a random LTE or NR cell
    Log  Step2: Get a random LTE or NR cell  console=true
    ${LTE_NR_DISTNAME}  Create List
    ${LTE_NR_SHORT_DISTNAME}  Create List
    Set test variable  ${LTE_NR_DISTNAME}
    Set test variable  ${LTE_NR_SHORT_DISTNAME}
    Set cells object R dist_name  LNCEL
    Set cells object R dist_name  NRCELL
    Set short dist_name
    ${number_of_cells}=  get length  ${LTE_NR_SHORT_DISTNAME}
    ${cell_index}=  Evaluate  random.randint(0, ${number_of_cells}-1)  modules=random
    ${cell}=  Get From List  ${LTE_NR_SHORT_DISTNAME}  ${cell_index}
    Set Test Variable  ${CELL_DISTNAME}  ${cell}
    Log  Distname for cell to be locked: ${CELL_DISTNAME}  console=true
    ${cell_id}  Fetch from right  ${CELL_DISTNAME}  L-
    Set Test Variable  ${CELL_ID}  ${cell_id}

Step3: Lock cell
    Log  Step3: Lock cell  console=true
    ${cell}  Fetch from right  ${CELL_DISTNAME}  /
    ${cell_technology}  Fetch from left  ${cell}  -
    Set Test Variable  ${CELL_TECHNOLOGY}  ${cell_technology}
    ${new_value}  Run keyword if  '${CELL_TECHNOLOGY}'=='LNCEL'
    ...  Set variable  locked
    ...  ELSE
    ...  Set variable  Locked
    Perform Parameter Recommissioning  ${CELL_DISTNAME}  administrativeState  update  ${new_value}  skip_parameter_relation_errors=${True}
    Wait Until Keyword Succeeds  ${LOCKED_TIMEOUT}  2  Click Element  locator=//div[@class='cell-content']//div[@class='locked-icon']
    Wait Until Element Is Visible  locator=//div[@class='cell-content']//div[text()='${CELL_ID}']/../..//div[contains(@class, 'gray-diode')]
    ...  timeout=${LOCKED_TIMEOUT}
    ${status}  Run keyword and return status  Wait Until Element Is Visible
    ...  locator=//div[@class='cell-content']//div[text()='${CELL_ID}']/../..//div[contains(@class, 'locked-icon')]  timeout=${LOCKED_TIMEOUT}
    Run keyword if  ${status}
    ...  Log  Cell is locked![OK]  console=true
    ...  ELSE
    ...  Fail  Cell is not locked![NOK]

Step4: Unlock cell
    Log  Step4: Unlock cell  console=true
    ${new_value}  Run keyword if  '${CELL_TECHNOLOGY}'=='LNCEL'
    ...  Set variable  unlocked
    ...  ELSE
    ...  Set variable  Unlocked
    Perform Parameter Recommissioning  ${CELL_DISTNAME}  administrativeState  update  ${new_value}  skip_parameter_relation_errors=${True}
    ${status}  Run keyword and return status  Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}
    Run keyword if  ${status}
    ...  Log  Cell is unlocked![OK]  console=true
    ...  ELSE
    ...  Fail  Cell is not unlocked![NOK]

Verify specific cells
    [Arguments]  ${technology}
    Log  Check if "${technology} cells" text is visible in Site view...  console=true
    ${status}  Run keyword and return status  Wait Until Element Is Visible  locator=//div[@class='title' and text()='${technology} cells']
    ...  timeout=30
    Run keyword if  ${status}
    ...  Log  "${technology} cells" text is visible in Site view![OK]  console=true
    ...  ELSE
    ...  Set Test Restriction  "${technology} cells" text is not visible in Site view![NOK]

Set cells object R dist_name
    [Arguments]  ${cell_type}
    ${cells_object}  Query Infomodel  get list //${cell_type}_R-*
    ${cells_r_dist_name}  Create list
    FOR  ${cell_obj}  IN  @{cells_object}
       Append to list  ${LTE_NR_DISTNAME}  ${cell_obj}[dist_name]
    END

Set short dist_name
    ${bts_id}  Admin Get BTS Id
    FOR  ${cell}  IN  @{LTE_NR_DISTNAME}
        ${cell_dn}  Remove String Using Regexp  ${cell}  .*VIEW-\\d/
        ${cell_dn}  Replace String Using Regexp  ${cell_dn}  _R  ${EMPTY}
        ${cell_dn}  Replace String Using Regexp  ${cell_dn}  MRBTS-\\d  MRBTS-${bts_id}
        Append To List  ${LTE_NR_SHORT_DISTNAME}  ${cell_dn}
    END


TC Setup
    Common test setup
    WebEM Setup via Mobile

TC Teardown
    WebEM Teardown via Mobile
    Common test teardown
