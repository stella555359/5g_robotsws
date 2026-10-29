*** Settings ***
Documentation
...  The purpose of this case is to verify proper functionality of fault 4393: EFaultId_ReducedGuardBandConfNotMatchingHwAl.

Resource    ../../../../resources/hran_frame_sbts_siso.robot
Resource    ../../../../resources/ca_BSRF_general.robot
Resource    ../../../../../Resources/SiSo_L3_call.robot


*** Variables ***

${CELLS}        # Global NR cell ID deplayed on RMOD which doesn't support CB007769.
                #If is more than one, please separate cells with a comma, e.g. 12017,12016
${node}    default
${5MHz}    23
${10MHz}    46
${15MHz}    69
${20MHz}    92
&{NBROFBLANKEDPRBS_LIST}    5MHz=0  10MHz=1  15MHz=2  20MHz=3

*** Keywords ***
TC__SiSo_FM_NR_Fault4393_Configuration_and_RF_Module_mismatch_for_Reduced_Guard_Band
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-47233
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The purpose of this case is to verify proper functionality of fault 4393: EFaultId_ReducedGuardBandConfNotMatchingHwAl.
    ...  TC enables the feature reduces guard band on RF module which doesn't support CB007769 (feature is unsupported on OBSAI Radio Modules).
    ...  IMPORTANT:
    ...  TC works for RAT NR FDD SA and NSA.
    ...
    ...  TC tested on FXJB.
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 10.05.2024 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-47233 - Initial creation

    Set Tags
    ...    OWNER-lukasz.wystup@nokia.com
    ...    AUTHOR-lukasz.wystup@nokia.com
    ...    MAINTAINER-lukasz.wystup@nokia.com
    ...    FEATURE-CB007769


    step1: Preconditions
    step2: Enable Reduced NR Guard Band And Check Fault

step1: Preconditions

    Log To Console  --------------------
    Log To Console  step1: Preconditions
    Log To Console  --------------------${\n}


    ${cell_status}  Run Keyword And Return Status  Should Not Be Empty  ${CELLS}
    Run Keyword If  '${cell_status}'=='False'  Fail  Variable CELLS cannot be empty!
    ${cells_list}=  Split String  ${CELLS}  ,
    Set Test Variable  ${CELLS_LIST}
    Log To Console  Test will be performed for cells from list ${CELLS_LIST}.

step2: Enable Reduced NR Guard Band And Check Fault

    Log To Console  --------------------
    Log To Console  step2: Enable Reduced NR Guard Band And Check Fault
    Log To Console  --------------------${\n}

    @{NR_CELLS_ID_LIST}  admin.Get Ids For All  NRCEL  connection=${node}
    ${bts_obj}  admin.Get Parameters For All  BTS  connection=${node}
    ${bts_id}  Convert To String  ${bts_obj[0].btsId}
    FOR  ${cell}  IN  @{CELLS_LIST}
        ${NR_cell_ID}  Get Matches  ${NR_CELLS_ID_LIST}  *${cell}
        Run Keyword If  ${NR_cell_ID}  Log To Console  Checking Reduced NR Guard Band for cell ID ${NR_cell_ID}
        ...  ELSE  Fail  Defined cell nr ${cell} doesn't exist in configuration.
        ${cell_parameters}  admin.Get Cell Specific Info  ${NR_cell_ID[0]}  connection=${node}
        Log To Console  Testing NR Cell bandwidth is ${cell_parameters['chBwDl']}.
        ${nbrOfBlankedPRBs}  Get From Dictionary  ${NBROFBLANKEDPRBS_LIST}  ${cell_parameters['chBwDl']}
        ${distname_recom}  Set Variable  MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-${cell}
        Activate Reduced Guard Band For NR Cell
        ...  guard_band_values=${cell_parameters['chBwDl']}
        ...  distname_recom=${distname_recom}
        ...  nbrOfBlankedPRBs=${nbrOfBlankedPRBs}

        Verify FaultId 4393  fault_status=Active  severity=Critical
        Log To Console  Prepare delta recommissioning for cell ${distname_recom} to deactivate feature.
        Perform Delta Recommissioning For Reduced Guard Band
        ...  cell=${distname_recom}
        ...  redFreqOffset=${NONE}
        ...  actRedFreqOffset=false
        ...  actPRBBlanking=false
        ...  nbrOfBlankedPRBs=0
        ${cell_status}  Run Keyword And Return Status  Check If All Cells Are onAir  alias=${node}  timeout=120
        Run Keyword If  '${cell_status}'=='True'
        ...  Log To Console  All cells are onAir! Guard Band feature for cell ${distname_recom} is deactivate.${\n}${\n}
        ...  ELSE  Run Keyword And Continue On Failure
        ...  Fail  Cells doesn't reach onAir state after deactivating Guard Band feature for cell ${distname_recom}!
        Verify FaultId 4393  fault_status=Inactive  severity=Critical
    END

Activate Reduced Guard Band For NR Cell
    [Arguments]  ${guard_band_values}  ${distname_recom}  ${nbrOfBlankedPRBs}

    Log To Console  Prepare delta recommissioning for cell ${distname_recom} to activate feature.
    Perform Delta Recommissioning For Reduced Guard Band
    ...  cell=${distname_recom}
    ...  redFreqOffset=${${guard_band_values}}
    ...  actRedFreqOffset=true
    ...  actPRBBlanking=true
    ...  nbrOfBlankedPRBs=${nbrOfBlankedPRBs}

Perform Delta Recommissioning For Reduced Guard Band
    [Arguments]  ${cell}  ${redFreqOffset}  ${actRedFreqOffset}  ${actPRBBlanking}  ${nbrOfBlankedPRBs}

    ${delta_id}  Set Variable  1
    admin.Create Delta  ${delta_id}
    Log To Console  actRedFreqOffset updating to: ${actRedFreqOffset}

    Log To Console  Appending parameters update to delta for ${cell}.
    Run Keyword If  '${actRedFreqOffset}'=='true'
    ...  Run Keywords  Log To Console  actRedFreqOffset will be updated to -> true ${\n}redFreqOffset will be updated to -> ${redFreqOffset}
    ...  AND  admin.Append Parameter Update To Delta  ${cell}  actRedFreqOffset  ${actRedFreqOffset}  ${delta_id}
    ...  AND  admin.Append Parameter Update To Delta  ${cell}  redFreqOffset  ${redFreqOffset}  ${delta_id}
    ...  AND  admin.Append Parameter Update To Delta  ${cell}  actPRBBlanking  ${actPRBBlanking}  ${delta_id}
    ...  AND  admin.Append Parameter Update To Delta  ${cell}  nbrOfBlankedPRBsHighEdgeDL  ${nbrOfBlankedPRBs}  ${delta_id}
    ...  AND  admin.Append Parameter Update To Delta  ${cell}  nbrOfBlankedPRBsHighEdgeUL  ${nbrOfBlankedPRBs}  ${delta_id}
    ...  AND  admin.Append Parameter Update To Delta  ${cell}  nbrOfBlankedPRBsLowEdgeDL  ${nbrOfBlankedPRBs}  ${delta_id}
    ...  AND  admin.Append Parameter Update To Delta  ${cell}  nbrOfBlankedPRBsLowEdgeUL  ${nbrOfBlankedPRBs}  ${delta_id}
    Run Keyword If  '${actRedFreqOffset}'=='false'
    ...  Run Keywords  Log To Console  actRedFreqOffset will be updated to -> false
    ...  AND  admin.Append Parameter Update To Delta  ${cell}  actRedFreqOffset  ${actRedFreqOffset}  ${delta_id}
    ...  AND  admin.Append Parameter Delete To Delta  ${cell}  redFreqOffset  ${delta_id}
    ...  AND  admin.Append Parameter Update To Delta  ${cell}  actPRBBlanking  ${actPRBBlanking}  ${delta_id}
    ...  AND  admin.Append Parameter Update To Delta  ${cell}  nbrOfBlankedPRBsHighEdgeDL  ${nbrOfBlankedPRBs}  ${delta_id}
    ...  AND  admin.Append Parameter Update To Delta  ${cell}  nbrOfBlankedPRBsHighEdgeUL  ${nbrOfBlankedPRBs}  ${delta_id}
    ...  AND  admin.Append Parameter Update To Delta  ${cell}  nbrOfBlankedPRBsLowEdgeDL  ${nbrOfBlankedPRBs}  ${delta_id}
    ...  AND  admin.Append Parameter Update To Delta  ${cell}  nbrOfBlankedPRBsLowEdgeUL  ${nbrOfBlankedPRBs}  ${delta_id}

    Log To Console  Performing delta recommissioning, please wait !
    admin.Get Delta  ${delta_id}
    admin.Save Delta  delta_${delta_id}.json  ${delta_id}
    admin.Perform Delta Recommissioning  delta_${delta_id}.json  skip_parameter_relation_errors=True  connection=${node}
    admin.Remove Delta  ${delta_id}

Verify FaultId 4393
    [Arguments]    ${fault_status}  ${severity}
    Log To Console  Checking FID 4393 Configuration and RF Module mismatch for Reduced LTE Guard Band is ${fault_status}.
    ${4393}  Run Keyword If  '${fault_status}'=='Active'
    ...  Run Keyword And Return Status  admin.Assert Alarm Active  faultId=4393  severity=${severity}  timeout=120  connection=${node}
    ...  ELSE  Run Keyword And Return Status  admin.Assert Alarm Inactive  faultId=4393  severity=${severity}  connection=${node}
    Run Keyword If  ${4393} and '${fault_status}'=='Active'
    ...  Log To Console  ${\n}Active FID Configuration and RF Module mismatch for Reduced LTE Guard Band severity=${severity}
    ...  ELSE IF  ${4393} and '${fault_status}'=='Inactive'
    ...  Log To Console  ${\n}InActive FID Configuration and RF Module mismatch for Reduced LTE Guard Band
    ...  ELSE  Run Keyword And Continue On Failure
    ...  Fail  Alarm Configuration and RF Module mismatch for Reduced LTE Guard Band has unexpected status!

TC Setup
    Common Test Setup

TC Teardown
    Common Test Teardown
