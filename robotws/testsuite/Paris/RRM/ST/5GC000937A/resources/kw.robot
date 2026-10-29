*** Settings ***
Documentation
...     Test Suite Purpose:
...         Generic purpose kws
...
...     AUTHOR (mmW&SC Pz NPS 4 SG):
...         I_MNP_5G_NPS_IVU_SISO_MOBILITY@nokia.com

*** Variables ***


*** Keywords ***
Extract Number Of Cells from Scf
    [Documentation]      Return number of cells declarered in scf
    Run Keyword If      '${oam_type}' == 'cloud_coam'       Get Number Of Cells from Scf CU
    ...         ELSE    Get Nrbts Number Of Cells From Scf      ${resultBaseDir}/SCFC_start.xml

Get Number Of Cells from Scf CU
     [Documentation]    [PRIVATE]     for coam_cloud gNB CU
     Get Nrbts Number Of Cells From Scf      ${resultBaseDir}/CU_SCFC_start.xml    CU

Get Nrbts Number Of Cells From Scf
     [Documentation]    [PRIVATE]     extract number of ccells from provided SCF
     [Arguments]    ${scf_file}     ${unit}=${EMPTY}      ${du_id}=${EMPTY}
     Set Suite Variable     ${local_xpath}     .//managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]

     ${parsed_SCF}    parse xml     ${scf_file}
     ${NB_Cell}    get element Count   ${parsed_SCF}      xpath=${local_xpath}
     Set Suite Variable     ${NB_Cell}

Get physCellId from SCF
    [Arguments]                             ${cellDistName}
    ${scf_file}       Run Keyword If    '${oam_type}' == 'cloud_coam'       set variable   CU_SCFC_start.xml
    ...               ELSE                                                  set variable   SCFC_start.xml
    ${parsed_SCF}     parse XML          ${resultBaseDir}/${scf_file}
    ${xpath_param}    get from dictionary    ${xpath_vars_SCF}    physCellId
    ${bts_distName}     set variable    ${CU_bts_distName}

    ${cell_distName}    set variable    ${cellDistName}
    ${xpath_param_replaced}    Replace Variables    ${xpath_param}
    ${pci}    get element text    ${parsed_SCF}    xpath=${xpath_param_replaced}
    [Return]     ${pci}

Get physCellId from SCF ext01
    [Arguments]       ${cellDistName}   ${gnb_id}
    ${scf_file}       Run Keyword If    '${gnb_${gnb_id}_oam_type}' == 'cloud_coam'       set variable   CU_SCFC_start_gnb_${gnb_id}.xml
    ...               ELSE                                                  set variable   SCFC_start_gnb_${gnb_id}.xml
    ${parsed_SCF}     parse XML          ${resultBaseDir}/${scf_file}
    ${xpath_param}    get from dictionary    ${xpath_vars_SCF}    physCellId
    ${bts_distName}   Run Keyword If    '${gnb_${gnb_id}_oam_type}' == 'cloud_coam'
    ...    set variable    ${gnb_${gnb_id}_CU_bts_distName}
    ...    ELSE
    ...    set variable    ${gnb_${gnb_id}_bts_distName}

    ${cell_distName}    set variable    ${cellDistName}
    ${xpath_param_replaced}    Replace Variables    ${xpath_param}
    ${pci}    get element text    ${parsed_SCF}    xpath=${xpath_param_replaced}
    [Return]     ${pci}

Extract cellIndex from cellDistName ext01
    [Arguments]       ${cellDistName}=NRCELL-1
    ${rest}   ${last}   Split String   ${cellDistName}   -   1
    ${val}  Convert To Integer   ${last}
    ${cellId}    evaluate   ${val} - 1
    [Return]   ${cellId}
