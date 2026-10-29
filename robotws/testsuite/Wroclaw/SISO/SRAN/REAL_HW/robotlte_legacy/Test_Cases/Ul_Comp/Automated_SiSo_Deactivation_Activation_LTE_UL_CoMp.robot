*** Settings ***
Documentation
...    Author:        szymon.przybylak@nokia.com
...    Maintainer:    Szymon Przybylak


Library     taf.sbts.oam.coam.admin  WITH NAME  admin

#Library     ../../hran_ta/resources/ims2_parser.py
#Resource    ../../rd_config.robot
#Resource    ../../../Resources/SiSo_L3_call.robot
Resource    ./Ul_Comp_common.robot
*** Variables ***
@{UL_COMP_LIST}            # eutranCellId of cells which are going to be included in ulComp set,
                                 # example:  386314  386317
${CELLS_YAML_PATH}               # path to reference yaml file with cells parameters
${CALL_IN_UL_COMP}  ${True}
${SINGLE_NODE}    ${False}    #set in robot suite to TRUE in order to test only 1 node on testline. Need to add additional
# variable  eg.  ${SINGLE_NODE_NUMBER}    1404
*** Keywords ***
Deactivating Activating UL CoMP
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The purpose of this test case is to verify Deactivation and Activation of UL CoMP feature on BTS and calls on cells.
    ...  To deactivate set parameter actCoMp to disabled.
    ...  To activate set parameter actCoMp to the one that fits type of Ul CoMP
    ...  For Basic and Fixed to activate: set the Activate CoMP (actCoMp) parameter to fixedULCoMp or measBasedCoMp
    ...  For Flexible: set the Activate CoMP (actCoMp) parameter to measBasedCoMp
    ...  History of change
    ...  *****************
    ...   21.02.2024 - Initial creation
  Common Test Setup
  Logging With Timestamp
  ...  message=Deactivating Activating UL CoMP
  ...  style=ONGOING
    Set Tags
    ...    OWNER-szymon.przybylak@nokia.com
    ...    AUTHOR-szymon.przybylak@nokia.com
    ...    MAINTAINER-szymon.przybylak@nokia.com
    Deactivating Activating UL CoMP All Steps
  [Teardown]  Run Keywords
  ...  Force Recommissioning With Current Branch On Every Node
  ...  AND  Common Test Teardown


Deactivating Activating UL CoMP All Steps
   FOR  ${node}  IN  @{cfg.active_bts_list}
        Run Keyword If    ${SINGLE_NODE}    Continue For Loop If    '${node}'!='${SINGLE_NODE_NUMBER}'
        Precondition UlComp  ${node}
        Precondition Deactivation Activation  ${node}
    END
    FOR  ${node}  IN  @{cfg.active_bts_list}
        Run Keyword If    ${SINGLE_NODE}    Continue For Loop If    '${node}'!='${SINGLE_NODE_NUMBER}'
        Run Keyword  Set Test Variable  ${BTS_ID}  ${node}
        step1: Call To Cells In Ul CoMP
        step2: Deactivate Ul CoMP  ${node}
        step3: Call To Cells with Ul CoMP deactivated
        step4: Activate Ul CoMP  ${node}
        step5: Call To Cells In Ul CoMP
    END


Precondition Deactivation Activation
    [Arguments]  ${node}
    Set Test Variable  ${LNBTS_OBJECT}  MRBTS-${node}/LNBTS-${node}
    ${reference_dict}  Create Dictionary
    ${parameter}  admin.Get Scf  export_type=configurationAndRuntimeObjects  parameters_save_variant=actualValues  alias=${node}
    ${scfc_xml}  Parse XML  source=${parameter}
    ${actComp_scf}  Evaluate Xpath  ${scfc_xml}
    ...  string(.//managedObject[@distName='${LNBTS_OBJECT}']/p[@name='actCoMp']/text())
    Set To Dictionary  ${reference_dict}  actCoMp  ${actComp_scf}
    Set Test Variable    ${REFERENCE_DICT}

step1: Call To Cells In Ul CoMP
    Log To Console  === Step 1: Call To Cells In Ul CoMP
    Set Test Variable  ${SELECTED_CELLS}  ${UL_COMP_LIST}
    Log  ${SELECTED_CELLS}
    Run Keyword If  ${CALL_IN_UL_COMP}  SiSo L3 Call  cells_input=${SELECTED_CELLS}
    ...  ELSE    Log To Console    Call skipped    console=True

step2: Deactivate Ul CoMP
    [Arguments]  ${node}
    Log To Console  === Step 2: Deactivate Ul CoMP
    admin.Perform Parameter Recommissioning  dist_name=${LNBTS_OBJECT}  parameter=actCoMp
    ...  operation=update  value=disabled  should_activate=True  alias=${node}
    Log To Console  Perform recommissioning done, set:${\n}actCoMp-> disabled${\n}

step3: Call To Cells with Ul CoMP deactivated
    Log To Console  === Step 3: Call To Cells after Ul CoMP deactivation
    Log  ${SELECTED_CELLS}
    Run Keyword If  ${CALL_IN_UL_COMP}  SiSo L3 Call  cells_input=${SELECTED_CELLS}
    ...  ELSE    Log To Console    Call skipped    console=True

step4: Activate Ul CoMP
    [Arguments]  ${node}
    Log To Console  === Step 4: Activate Ul Comp
    admin.Perform Parameter Recommissioning  dist_name=${LNBTS_OBJECT}  parameter=actCoMp
    ...  operation=update  value=${REFERENCE_DICT['actCoMp']}  should_activate=True  alias=${node}
    Log To Console  Perform recommissioning done, set:${\n}actCoMp -> ${REFERENCE_DICT['actCoMp']} ${\n}

step5: Call To Cells In Ul CoMP
    Log To Console  === Step 5: Call To Cells after Ul CoMP activation
    Log  ${SELECTED_CELLS}
    Run Keyword If  ${CALL_IN_UL_COMP}  SiSo L3 Call  cells_input=${SELECTED_CELLS}
    ...  ELSE    Log To Console    Call skipped    console=True
