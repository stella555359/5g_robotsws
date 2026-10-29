*** Settings ***
Resource    ../../../resources_mem/common.robot
Resource    ../../../resources_mem/scf.robot
Library     taf.config.scf   WITH NAME      scf

Documentation
...  TEST NAME:     SM.49_Cell_add_remove
...  AUTHORS:       sebastian.suwada@nokia.com
...  MAINTAINER:    VRF_WRO3_T02
...  *****************
...  Basic information
...  *****************
...  The test begins by generating a System Configuration File (SCF) and subsequently creates a delta file
...  that captures the differences. This delta is uploaded to the (BTS) without necessitating a site reset.
...  Following this, an LTE cell is established using parameters specified in the cellconfiguration.json file
...  located in the resources_mem directory. In the subsequent step, the created cells are deleted
...  and the process is repeated in a loop. The main goal is to check the DCS process in case of memory leak.
...  *****************
...  Pre-conditions
...  *****************
...  resources_mem Required: cellconfiguration.json file containing LTE cell parameters for specified BTS.
...  ******************
...  History of changes
...  ******************
...  07.08.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-23105 - Test creation
...  *******************
...  VRF_WRO3_01_VRF_OAM TEMPLATE

*** Variables ***
${SKIP_PARAMETER_RELATION_ERRORS}=  True
${SHOULD_ACTIVATE}=  True
${JSON_FILE}      testsuite/Wroclaw/OAM/VRF_WRO3_T02/resources_mem/cellconfiguration.json

*** Keywords ***
SM.49_Cell_add_remove
    SM.49_Cell_add_remove.Test_Step:0 Test Preparation
    SM.49_Cell_add_remove.Test_Step:1 Add Cells
    SM.49_Cell_add_remove.Test_Step:2 Delete Cells

SM.49_Cell_add_remove.Test_Step:0 Test Preparation
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    ${json_data}=      Load JSON File    ${JSON_FILE}
    ${cellData}=       Set Variable    ${json_data['${MRBTS_ID}']}
    Set Test Variable    ${cellData}
    ${COUNTER_BEFORE_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}  iteration=${ITERATION_INDEX}
    Set Test Variable  ${COUNTER_BEFORE_TEST}
    SCF Backup
    Cell mapping
    Set actMultipleCarrier     ${cellData[0]['actMultipleCarrier']}

SM.49_Cell_add_remove.Test_Step:1 Add Cells
    Log to console    \n========================================
    Log  Step: 1 Add copies of cells  console=${True}
    Log to console    ========================================
    Automated Cell Configuration Management
    Check SMODs State  ${SMOD_expected_states}
    Check RMODs State  ${RMOD_expected_states}
    Check If ALDs Are Connected And Achieved Expected State
    common.Check BTS State  ${BTS_expected_states}
    Check If NLWG Cells Are OnAir

SM.49_Cell_add_remove.Test_Step:2 Delete Cells
    Log to console    \n========================================
    Log  Step: 2 Delete created cells  console=${True}
    Log to console    ========================================
    Automated Cell Deletion Management
    Check SMODs State  ${SMOD_expected_states}
    Check RMODs State  ${RMOD_expected_states}
    Check If ALDs Are Connected And Achieved Expected State
    common.Check BTS State  ${BTS_expected_states}
    Check If NLWG Cells Are OnAir
    ${COUNTER_AFTER_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}  iteration=${ITERATION_INDEX}
    ${counter_diff}  Evaluate  abs(${COUNTER_AFTER_TEST} - ${COUNTER_BEFORE_TEST})
    Run Keyword If  ${counter_diff}!=${0}  Log  Reset Counter Changed  WARN

SM.49_Cell_add_remove.Test Case Teardown
    Restore MultipleCarrier parameter
    Run Keyword  common.Common Test Teardown - MEMORY

Cell mapping
    ${cell_list}    admin.get cells info    lte
    &{cell_dict}=    Create Dictionary
    &{technology_dict}=    Create Dictionary
    FOR  ${cell}  IN  @{cell_list}
        ${internal_value}=    Set Variable    ${cell['carrierList'][0]['id']['internal']}
        ${split_string}=    Split String    ${internal_value}    /
        ${seven}=    Get From List    ${split_string}    7
        ${splited_string_}=    Split String    ${seven}    -
        ${cell_number}=    Get From List    ${splited_string_}    1
        Set To Dictionary    ${cell_dict}    '${cell['globalCellId']}'=${cell_number}
        Set To Dictionary    ${technology_dict}    '${cell['globalCellId']}'=${cell['technology']}
    END
    Set Test Variable    ${cell_dict}
    Set Test Variable    ${technology_dict}

Set actMultipleCarrier
    [Arguments]    ${carrierOperation}
    scf.load_scf    file_path=${RESULTS}/SCF_BACKUP.xml
    ${distName}    Set Variable    MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}
    ${actMultipleCarrier}=       scf.get_value_from_scf   dist_name=${distName}   p_name=actMultipleCarrier
    Run Keyword If    '${actMultipleCarrier}' != '${carrierOperation}'    MultipleCarrier change  ${distName}  ${carrierOperation}

Restore MultipleCarrier parameter
    admin.get current scf file  ${RESULTS}/SCFs    restoreSCF.xml  timeout=60
    scf.load_scf    file_path=${RESULTS}/SCF_BACKUP.xml
    ${distName}    Set Variable    MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}
    ${actMultipleCarrierBefore}=       scf.get_value_from_scf   dist_name=${distName}   p_name=actMultipleCarrier
    scf.load_scf    file_path=${RESULTS}/SCFs/restoreSCF.xml
    ${actMultipleCarrierafter}=       scf.get_value_from_scf   dist_name=${distName}   p_name=actMultipleCarrier
    Run Keyword If    '${actMultipleCarrierBefore}' != '${actMultipleCarrierafter}'
    ...     MultipleCarrier change    ${distName}    ${actMultipleCarrierBefore}
    Log To Console    MultipleCarrier parameter restore!

MultipleCarrier change
    [Arguments]    ${distName}    ${value}
    ${scfPath}    Modify single parameter in SCF file  ${distName}  actMultipleCarrier  ${value}  carrierChange
    ${json_path}    Calculate delta    ${scfPath}    ${RESULTS}/SCFs/single_operation.xml    carrier_delta
    admin.perform delta recommissioning    ${json_path}
        ...  skip_parameter_relation_errors=${SKIP_PARAMETER_RELATION_ERRORS}  should_activate=${SHOULD_ACTIVATE}
    Log To Console    MultipleCarrier changed!

Automated Cell Configuration Management
    FOR    ${item}    IN    @{cellData}
        ${LCELLid}=    Get From Dictionary    ${cell_dict}    '${item['sourceCellId']}'
        ${LCELLid}=    Convert To Integer    ${LCELLid}
        ${technology}=    Get From Dictionary    ${technology_dict}    '${item['sourceCellId']}'
        Set Test Variable    ${LCELLid}
        ${scfPath}    Copy LTE Cell in SCF file  ${item['physicalCellId']}  ${item['earfcn']}
        ...    ${item['sourceCellId']}  ${LCELLid}  ${technology}
        ${json_path}    Calculate delta    ${scfPath}    ${RESULTS}/SCFs/SCF_BACKUP2.xml    cellsAddDelta
        admin.perform delta recommissioning    ${json_path}
            ...  skip_parameter_relation_errors=${SKIP_PARAMETER_RELATION_ERRORS}  should_activate=${SHOULD_ACTIVATE}
        Log To Console    Cell: ${item['physicalCellId']} Recommissioning performed (CELL ADDED)
    END
    Log To Console    === All cells added successfully! ===

Automated Cell Deletion Management
    ${json_path}  Calculate delta  ${RESULTS}/SCF_BACKUP.xml  ${RESULTS}/SCFs/modified.xml  cellsDeleteDelta
    admin.perform delta recommissioning    ${json_path}
        ...  skip_parameter_relation_errors=${SKIP_PARAMETER_RELATION_ERRORS}  should_activate=${SHOULD_ACTIVATE}
    Log To Console    === Added cells are deleted (Recommissioning performed) ===
