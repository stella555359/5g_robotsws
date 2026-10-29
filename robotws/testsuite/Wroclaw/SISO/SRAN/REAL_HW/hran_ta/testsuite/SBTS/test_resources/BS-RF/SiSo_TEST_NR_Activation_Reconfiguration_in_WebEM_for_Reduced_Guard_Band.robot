*** Settings ***
Documentation
...  The purpose of this case is to verify proper functionality activation and reconfiguration Reduced NR GuardBand.

Resource    ../../../../resources/hran_frame_sbts_siso.robot
Resource    ../../../../resources/ca_BSRF_general.robot
Resource    ../../../../../Resources/SiSo_L3_call.robot


*** Variables ***

${CELLS}        # Global NR cell ID for activation Reduced Guard Band. If is more than one, please separate cells with a comma, e.g. 12017,12016
${SISO_L3_CALL}  False             # default value for L3 call is False, set test variable as True to perform test with L3 call
${CELLS_YAML_PATH}                 # mandatory path for ue_config.yaml if ${SISO_L3_CALL} is True
${LOGS_DIR}                        # path to store logs from L3 call
${node}    default
@{5MHz}    23  24  25
@{10MHz}    46  47  48  49  50
@{15MHz}    69  70  71  72  73  74  75
@{20MHz}    92  93  94  95  96  97  98  99  100
&{NBROFBLANKEDPRBS_LIST}    5MHz=0  10MHz=1  15MHz=2  20MHz=3

*** Keywords ***
TC__SiSo_TEST_NR_Activation_Reconfiguration_in_WebEM_for_Reduced_Guard_Band
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-47233
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The purpose of this case is to verify proper functionality activation and reconfiguration Reduced NR GuardBand.
    ...  TC enables the Feature CB007769 reduces guard band for specific NR FDD radio families.
    ...  TC run all Guard Band value for carrier bandwidths selected cell.
    ...  IMPORTANT:
    ...  TC works for RAT NR FDD SA and NSA.
    ...
    ...  TC works with RU families: 3.1*, 3.2*,5.1*, 6.2* tested on AHIB.
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
    step2: Enable Reduced NR Guard Band And Check Cell Status

step1: Preconditions

    Log To Console  --------------------
    Log To Console  step1: Preconditions
    Log To Console  --------------------${\n}


    ${cell_status}  Run Keyword And Return Status  Should Not Be Empty  ${CELLS}
    Run Keyword If  '${cell_status}'=='False'  Fail  Variable CELLS cannot be empty!
    ${cells_list}=  Split String  ${CELLS}  ,
    Set Test Variable  ${CELLS_LIST}
    Log To Console  Test will be performed for cells from list ${CELLS_LIST}.
    Set Test Variable  ${LOGS_DIR}  ${BTS Files}

step2: Enable Reduced NR Guard Band And Check Cell Status

    Log To Console  --------------------
    Log To Console  step2: Enable Reduced NR Guard Band And Check Cell Status
    Log To Console  --------------------${\n}

    @{NR_CELLS_ID_LIST}  admin.Get Ids For All  NRCEL  connection=${node}
    ${bts_obj}  admin.Get Parameters For All  BTS  connection=${node}
    ${bts_id}  Convert To String  ${bts_obj[0].btsId}
    FOR  ${cell}  IN  @{CELLS_LIST}
        ${NR_cell_ID}  Get Matches  ${NR_CELLS_ID_LIST}  *${cell}
        Set Test Variable  ${SELECTED_CELLS}  ${NR_cell_ID}
        Run Keyword If  ${NR_cell_ID}  Log To Console  Checking Reduced NR Guard Band for cell ID ${NR_cell_ID}
        ...  ELSE  Fail  Defined cell nr ${cell} doesn't exist in configuration.
        ${cell_parameters}  admin.Get Cell Specific Info  ${NR_cell_ID[0]}  connection=${node}
        Log To Console  Testing NR Cell bandwidth is ${cell_parameters['chBwDl']}.
        ${nbrOfBlankedPRBs}  Get From Dictionary  ${NBROFBLANKEDPRBS_LIST}  ${cell_parameters['chBwDl']}
        ${distname_recom}  Set Variable  MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-${cell}
        Activate Reduced Guard Band For NR Cell And Check Cell Status
        ...  guard_band_values=${cell_parameters['chBwDl']}
        ...  distname_recom=${distname_recom}
        ...  nbrOfBlankedPRBs=${nbrOfBlankedPRBs}

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
    END

Activate Reduced Guard Band For NR Cell And Check Cell Status
    [Arguments]  ${guard_band_values}  ${distname_recom}  ${nbrOfBlankedPRBs}

    FOR  ${guard_band}  IN  @{${guard_band_values}}
        Log To Console  Prepare delta recommissioning for cell ${distname_recom} to activate feature.
        Perform Delta Recommissioning For Reduced Guard Band
        ...  cell=${distname_recom}
        ...  redFreqOffset=${guard_band}
        ...  actRedFreqOffset=true
        ...  actPRBBlanking=true
        ...  nbrOfBlankedPRBs=${nbrOfBlankedPRBs}

        ${cell_status}  Run Keyword And Return Status  Check If All Cells Are onAir  alias=${node}  timeout=120
        Run Keyword If  '${cell_status}'=='True'
        ...  Log To Console  All cells are onAir! Guard Band ${guard_band} for cell ${distname_recom} is Active.${\n}
        ...  ELSE  Run Keyword And Continue On Failure
        ...  Fail  Cells doesn't reach onAir state after activating Guard Band ${guard_band} for cell ${distname_recom}!
        Run Keyword If  ${SISO_L3_CALL}  SiSo L3 Call
        ...  ELSE  Log  ${\n}Call skipped  console=True
    END

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


TC Setup
    Common Test Setup

TC Teardown
    Common Test Teardown
