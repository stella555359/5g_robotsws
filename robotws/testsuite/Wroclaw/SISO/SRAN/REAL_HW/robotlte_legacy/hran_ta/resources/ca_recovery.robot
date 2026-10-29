*** Settings ***
Resource      ca_BSRF_general.robot

*** Variables ***



*** Keywords ***
Check If Tested Cells Degraded
    [Documentation]  KW verifies is provided cells were degraded
    ...  '${cells}' are runtime objects
    ...  **Author:** daniel.bartkowiak@nokia.com
    [Arguments]  ${cells}  ${connection}=default
    FOR  ${cell}  IN  @{TESTED_CELLS}
      ${class}=  Get Regexp Matches  ${cell}  (?i)LNCEL|NRCEL|WNCEL|GNCEL
      ${degraded_st}=  Run Keyword And Return Status  admin.Assert  ${class[0]}  ${cell}  ${DEGRADED_CELL_REGEX}  connection=${connection}
      Run Keyword If  not ${degraded_st}  Fail  ${cell} is not degraded
    END

Find Cells By Antena
    [Documentation]   KW verifies is provided cells were degraded
    ...  '${tested_rmod}' is runtime object
    ...  **Author:** daniel.bartkowiak@nokia.com
    [Arguments]  ${tested_rmod}  ${pipe_number}  ${connection}=default
    ${tested_cells}=  Create List
    ${cells_on_rmod}=  admin.Get Cell Mapping By Module Id  ${tested_rmod}  connection=${connection}
    ${cmd}=  Set Variable  tx['direction']=='TX' and tx['antennaLineId']['internal']=='${tested_rmod}/ANTL_R-${pipe_number}'
    FOR  ${cell}  IN  @{cells_on_rmod}
      ${cell_inf}=  admin.Get Cell Specific Info  ${cell}  connection=${connection}
      ${stat}=  Evaluate  [True for tx in ${cell_inf['carrierList']} if ${cmd}]
      Run Keyword If  '${stat}'=='[True]'  Append To List  ${tested_cells}  ${cell}
    END
    ${num}=  Get Length  ${tested_cells}
    Run Keyword If  not ${num}  Fail  No cells commissioned on ${tested_rmod} ANT-${pipe_number}
    [Return]  ${tested_cells}

Check If BTS Components Were Unchanged
    [Documentation]   KW verifies if availabilityStatus remained unchanged based on provided ims
    ...  '${ims}' is path to ims file
    ...  '${components}'  runtime objects from any class that contain availabilityStatus
    ...  **Author:** daniel.bartkowiak@nokia.com
    [Arguments]  ${ims}  ${components}
    Log  Checking If BTS Components (HW and cells) Were OnAir During Test${\n}  console=${TRUE}
    FOR  ${object_dn}  IN  @{components}
      Run Keyword And Expect Error  No change found in*  Find Parameter Change  ${ims}  ${object_dn}  availabilityStatus
      Log  ${object_dn} remained unchanged  console=${TRUE}
    END

Bring Back BTS To Onair State
    [Documentation]   KW for additional BTS recovery -> brings BTS to Onair State
    ...  **Author:** daniel.bartkowiak@nokia.com
    [Arguments]  ${connection}=default
    ${onair_status}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  120s  10s
    ...  Check If All Cells Are OnAir  alias=${node}
    Run Keyword If  not ${onair_status}  admin.Reset Site  connection=${node}
    Run Keyword If  ${onair_status}  Return From Keyword
    ${onair_status}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  300s  30s
    ...  Check If All Cells Are OnAir  alias=${node}
    Run Keyword If  not ${onair_status}    Log To Console    BTS couldn't be recovered after test.

Prepare Tested Cell Ids
    [Documentation]   KW prepares globalCellId for call purposes
    ...  **Author:** daniel.bartkowiak@nokia.com
    [Arguments]  ${tested cells}  ${connection}=default
    ${cells}=  Create List
    FOR  ${cell_dn}  IN  @{tested_cells}
	  ${cel_inf}=  admin.Get Cell Specific Info  ${cell_dn}  connection=${node}
	  Append To List  ${cells}  ${cel_inf['globalCellId']}
	END
    [Return]  ${cells}
