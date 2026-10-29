*** Settings ***
Library    taf.config.scf    WITH NAME    scf
Resource        ../resources/common.robot

Documentation
...  AUTHORS:       tomasz.marchewka@nokia.com, sebastian.suwada@nokia.com
...  MAINTAINER:    VRF_WRO3_01_VRF_OAM
...  *****************
...  Basic information
...  *****************
...  Internal WRO1 resource library repetitive keywords in multiple tests.
...  ******************
...  History of changes
...  ******************
...  05.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-593 - resource file creation
...  07.08.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-23105 - adding Keywords: Calculate delta,
...  Modify single parameter in SCF file, Copy LTE Cell in SCF file
...  *******************
...  VRF_WRO3_01_VRF_OAM TEMPLATE

*** Keywords ***
Get SCF Backup Value
    [Documentation]
    [Arguments]    ${p_name}
    scf.load scf    file_path=${RESULTS}/SCF_BACKUP.xml
    ${msg}    ${current_value}    Run Keyword And Ignore Error    scf.get value from scf    p_name=${p_name}
    ${current_value}    Set Variable If    '${msg}'=='FAIL'    No match found
    [Return]    ${current_value}

Calculate delta
    [Documentation]    This keyword facilitates the creation of a delta between two specified SCF files,
    ...     which should be stored in the ${RESULTS} directory. To perform this calculation, you need
    ...     to provide the names of the SCF files and specify the name under which the delta will be saved.
    ...     ${modifiedScf}: Modified SCF path.
    ...     ${mainScf}: Current SCF path.
    ...     ${deltaName}: Delta defined name, optional argument.
    ...     Example:    ${json_path}    Calculate delta    ${modifiedscfPath}    ${backupscfPath}    carrier_delta
    ...     **Author:** sebastian.suwada@nokia.com
    [Arguments]    ${modifiedScf}    ${mainScf}    ${deltaName}=delta
    scf.calculate delta scf
    ...  target_scf_path=${modifiedScf}
    ...  actual_scf_path=${mainScf}
    ...  delta_scf_path=${RESULTS}/${deltaName}.json
    ...  oam_type=COAM
    ${json_path}    Set Variable    ${RESULTS}/${deltaName}.json
    [Return]    ${json_path}

Modify single parameter in SCF file
    [Documentation]    Keyword is designed to update a specified parameter with a new value in the SCF file.
    ...     The process involves retrieving the current SCF file, applying the modification.
    ...     ${distName}: The name of the distribution of element to be modified.
    ...     ${param}: The parameter within the SCF file that needs modification.
    ...     ${value}: The new value to be assigned to the specified parameter.
    ...     ${XMLname}: Optional argument with a default value of scf, specifying the XML file name.
    ...     Return is a path to the new SCF file with changed parameter.
    ...     **Author:** sebastian.suwada@nokia.com
    [Arguments]    ${distName}    ${param}    ${value}    ${XMLname}=scf
    admin.get current scf file  ${RESULTS}/SCFs  single_operation.xml  timeout=60
    @{modifi}=    Create List    modify:${distName}:${param}=${value}
    scf.load_scf    file_path=${RESULTS}/SCFs/single_operation.xml
    Log  Single parameter modification: ${modifi}   console=TRUE
    scf.perform_scf_modification     modification_strings=${modifi}
    scf.save_scf    file_path=${RESULTS}/SCFs/${XMLname}.xml
    Log To Console    Changed SCF saved in file path: ${RESULTS}/${XMLname}.xml
    ${xml_path}    Set Variable    ${RESULTS}/SCFs/${XMLname}.xml
    [Return]    ${RESULTS}/SCFs/${XMLname}.xml

Copy LTE Cell in SCF file
    [Documentation]    Keyword facilitates the duplication of an LTE cell within an SCF file,
    ...     allowing modifications to specific parameters based on technology type.
    ...     ${phyCellId}: It is used to specify the target cell ID in the SCF file.
    ...     ${earfcnParam}: This argument specifies the EARFCN for LTE cells.
    ...     ${cloneBasedOn}: This argument indicates the source LTE cell from which the new cell will be cloned.
    ...     ${LCELLid}:  It is used to map the logical cell configuration in the SCF file.
    ...     ${technology}: This argument specifies the technology type for the LTE cell, such as FDD or TDD.
    ...     Example of usage:    ${scfPath}    Copy LTE Cell in SCF file  ${item['physicalCellId']}  ${item['earfcn']}
    ...     ${item['sourceCellId']}  ${LCELLid}  ${technology}
    ...     Return is a path to the new SCF file with added cell.
    ...     **Author:** sebastian.suwada@nokia.com
    [Arguments]    ${phyCellId}    ${earfcnParam}    ${cloneBasedOn}    ${LCELLid}    ${technology}
    ${earfcn} =    Run Keyword If  '${technology}'=='FDD'  Set Variable  earfcnDL  ELSE  Set Variable  earfcn
    @{modifi}=    Create List
    ...    modify:MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-${phyCellId}/LNCEL_${technology}-0:${earfcn}=${earfcnParam}
    ...    modify:MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-${phyCellId}:lcrId=${phyCellId}

    admin.get current scf file  ${RESULTS}/SCFs  SCF_BACKUP2.xml  timeout=60
    scf.load_scf    file_path=${RESULTS}/SCFs/SCF_BACKUP2.xml
    scf.clone_mo_with_descendant_mos    source_mo_dist_name=MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-${cloneBasedOn}
    ...                                 target_mo_dist_name=MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-${phyCellId}
    scf.clone_mo_with_descendant_mos    source_mo_dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-${LCELLid}
    ...                                 target_mo_dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-${phyCellId}
    scf.perform_scf_modification        modification_strings=${modifi}
    scf.save_scf    file_path=${RESULTS}/SCFs/modified.xml
    ${scf_path}    Set Variable    ${RESULTS}/SCFs/modified.xml
    [Return]    ${scf_path}
