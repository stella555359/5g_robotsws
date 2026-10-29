*** Settings ***
Documentation
...  **Useful keyword for SCF manipulation**
...  This library provides keywords to manipulate SCF parameters and configurations.

Library    ../python/scf_file_parser.py

*** Keywords ***
Get SCF Parameter Value
    [Documentation]    This keyword retrieves the value of a specific SCF parameter.
    [Arguments]    ${class_parameter_name}
    ${value}=    scf_file_parser.Get SCF Parameter Value    ${res_path}/current_conf_scf.xml    ${class_parameter_name}
    ...    namespace=nrbts
    [Return]    ${value}

Save SCF Parameters List To JSON
    [Documentation]    This keyword saves a list of SCF parameters to a JSON file.
    [Arguments]    ${scf_parameters_list}    ${delta_scf}
    # ${scf_dict}=    Create Dictionary    scf_parameters=${scf_parameters_list}
    ${json_data}=    json.dumps    ${scf_parameters_list}   indent=${4}
    Create File    ${delta_scf}    ${json_data}

Create ParameterName Dictionary
    [Documentation]    This keyword creates a dictionary for a parameter name with its value and operation.
    [Arguments]    ${dist_name}    ${parameterName}    ${value}    ${operation}=update
    ${dict}    create dictionary
    ...    dist_name=${dist_name}
    ...    parameterName=${parameterName}
    ...    value=${value}
    ...    operation=${operation}
    [Return]    ${dict}

Create Parameters Dictionary
    [Documentation]    This keyword creates a dictionary for a parameter with its value and operation.
    [Arguments]    ${parameters}    ${operation}=update
    ${dict}    create dictionary
    ...    parameters=${parameters}
    ...    value=${value}
    ...    operation=${operation}
    [Return]    ${dict}

Set Framestructure 5GC001116_0
    [Arguments]    ${bwpDN}    ${newIDs}    ${prach}=96    ${beamset}=beamSet_6    ${beams}=6 beams
    ${fs}      create dictionary
    ...     frameStructureType      tdLte
    ...     lteToNrFrameShift       0ms
    ...     ulDlDataSlotRatio       1/4
    ...     guardPeriodLength       4Symbols
    ...     tdLteUlDlConfig         tdLteConfig2
    Set Cell Framestructure Configuration
    ...    ${fs}    ${bwpDN}    ${newIDs}    ${prach}    ${beamset}    ${beams}

Set Framestructure 5GC001116_3
    [Arguments]    ${bwpDN}    ${newIDs}    ${prach}=98    ${beamset}=beamSet_8    ${beams}=8 beams
    ${fs}      create dictionary
    ...     frameStructureType      tdLte
    ...     lteToNrFrameShift       3ms
    ...     ulDlDataSlotRatio       1/4
    ...     guardPeriodLength       4Symbols
    ...     tdLteUlDlConfig         tdLteConfig2
    Set Cell Framestructure Configuration
    ...    ${fs}    ${bwpDN}    ${newIDs}    ${prach}    ${beamset}    ${beams}

Set Framestructure 5GC001208
    [Arguments]    ${bwpDN}    ${newIDs}    ${prach}=98    ${beamset}=beamSet_6    ${beams}=6 beams
    ${fs}      create dictionary
    ...     frameStructureType      semiStatic
    ...     ulDlDataSlotRatio       1/4
    ...     guardPeriodLength       2Symbols
    Set Cell Framestructure Configuration
    ...    ${fs}    ${bwpDN}    ${newIDs}    ${prach}    ${beamset}    ${beams}

Set Cell Framestructure Configuration
    [Arguments]     ${framestructure}    ${bwpDN}    ${newIDs}    ${prach}    ${beamset}    ${beams}
    ${BWP_PROFILE}    set variable    MRBTS-511/NRBTS-23363/BWP_PROFILE-
    ${param_list}     Create List
    FOR     ${nrcell_id}    IN RANGE       1   4
        ${tddFrameParam}        convert to String      ${framestructure}
        # ${tddFrameParam}        Replace String      ${tddFrameParam}     '    "
        ${tddFrameStructure}      Set Variable       NRCELL-${nrcell_id}:tddFrameStructure
        ${cellBwpList}      Set Variable       NRCELL-${nrcell_id}:cellBwpList

        ${scf_modifs}      create list
        ...     add:${tddFrameStructure}:${tddFrameParam}
        ...     modify:${cellBwpList}:bwpDN=${bwpDN}|cellBwpId=0
        ...     modify:${cellBwpList}:bwpDN=${bwpDN}${newIDs[${${nrcell_id}-1}]}|cellBwpId=1
        ...     modify:NRCELL-${nrcell_id}:prachConfigurationIndex=${prach}
        ...     modify:NRCELL-${nrcell_id}:basicBeamSet=${beamset}
        ...     modify:NRCELLGRP-${${nrcell_id}-1}:numberOfTransmittedSsBlocks=${beams}

        Append To List       ${param_list}     delete:${tddFrameStructure}
        Append To List       ${param_list}     add:${tddFrameStructure}
        Append To List       ${param_list}     @{scf_modifs}
    END
    [Return]    ${param_list}
