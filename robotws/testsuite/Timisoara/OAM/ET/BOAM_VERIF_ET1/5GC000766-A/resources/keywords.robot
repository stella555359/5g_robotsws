*** Settings ***
Library    OperatingSystem
Library    Collections
Library    String
Library    taf.transport.ssh
Library    taf.gnb.oam.coam.admin

Resource    ../../resources/admin.robot
Resource    ../../resources/fault_trigger.robot

Library  Collections
Resource    ../../resources/selenium.robot
Library         taf.gnb.oam.coam.admin                  WITH NAME       coam

*** Variables ***


*** Keywords ***

Get Cell Parameter
    [Arguments]     ${Cell_input}   ${ParameterToBeRead}   # e.g. input:  NRCELL-x
#    ${CellsName_List}    create list
    FOR     ${item}    IN       @{OUT_ADMIN_LNCELS_PARAMETERS}
        ${CellName}    Get From Dictionary    ${item}      cellName
        Exit For Loop IF    "${CellName}" == "${Cell_input}"
    END
#    ${cells}   Set Variable    ${ReturnParameter}
    ${ReturnParameter}   Get From Dictionary    ${item}    ${ParameterToBeRead}
    [Return]    ${ReturnParameter}

PREPOST Create List Of CELLGROUP Parameters
     ${out_cellgroup_parameters}=    ADMIN Get Parameters For All NRCELLGRP
     ...    alias=${ADMIN_ALIAS}
     Set Suite Variable    ${OUT_ADMIN_NRCELLGRP_PARAMETERS}    ${out_cellgroup_parameters}

ADMIN Get Parameters For All NRCELLGRP
    [Arguments]    ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_list_of_cellgroup_parameters_dict}=    ADMIN Get Parameters For All
    ...    class_name=NRCELLGRP
    ...    timeout=${timeout}
    ...    alias=${alias}
    [Return]    ${out_list_of_cellgroup_parameters_dict}

Get NRCELLGRP nrCellList Parameter Value
    ${NRCELLGRP_nrCellList_Values_List}    Create List
    FOR     ${item}    IN       @{OUT_ADMIN_NRCELLGRP_PARAMETERS}
        ${NRCELLGRP_nrCellList_Values}    Get From Dictionary    ${item}      nrCellList
        Append To List   ${NRCELLGRP_nrCellList_Values_List}     ${NRCELLGRP_nrCellList_Values}
    END
    [Return]    ${NRCELLGRP_nrCellList_Values_List}

Get BTS Parameter Value
    [Arguments]     ${BTS_Param}   ${ParameterToBeRead}   # e.g. input:  NRCELL-x    ParameterName
    ${ParametersList}    coam.Get parameters for    ${BTS_Param}
    ${BTS_Param_List_Values}    Create List
    FOR    ${BTS_params}    IN    ${ParametersList}
         ${BTS_Param_Value}    Get From Dictionary    ${BTS_params}    ${ParameterToBeRead}
         Append To List   ${BTS_Param_List_Values}    ${BTS_Param_Value}
    END
    [Return]    ${BTS_Param_List_Values}


Logout And Close Browser
    SELENIUM Logout User From Web Element Manager

SELENIUM Setup
    Log To Console    SELENIUM Setup
#    SELENIUM Prepare Enviroment
    SELENIUM Run Xvfb
    SELENIUM Export DISPLAY
    SELENIUM Login To Web Element Manager









