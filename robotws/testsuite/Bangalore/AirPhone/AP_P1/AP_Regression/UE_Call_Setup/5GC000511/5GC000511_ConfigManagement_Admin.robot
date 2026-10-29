*** Settings ***
Documentation    This file contains 5GC000511 config management admin keywords

Library     Collections
Library     ../../../Resources/Python/ScfHelper.py    WITH NAME    scf_helper
Library     ../../../Resources/Python/AdminHelper.py    WITH NAME    admin_helper
Library     ../../../Resources/ParameterParser/src/ParameterParser.py    WITH NAME    yaml_parser
Resource    ../../../Resources/Variables/Common_Variables.robot
Resource    ./5GC000511_Delta_Keywords.robot

*** Variables ***
${yaml_file_path}      ${CURDIR}/Parameters.yaml

*** Keywords ***
Load Inuput Yaml File
    yaml_parser.load_parameter_file    ${yaml_file_path}

Fetch Prach Parameters From yaml
    [Arguments]    ${test_name}
    ${prach_params}    yaml_parser.get_feature_paramters_dict   test_name=${test_name}    param_section=prach_params
    [Return]    ${prach_params}

Get List of Prach Parameters From gNB
    [Arguments]    ${test_name}=TC_1
    ${prach_params}    Fetch Prach Parameters From yaml    ${test_name}
    ${scf_path}    admin_helper.download current scf file
    ${prach_dict}    scf_helper.get_feature_paramters_from_scf    ${scf_path}    ${prach_params}    ${NRCELL_DISTNAME}
    [Return]    ${prach_dict}

Update PRACH params in gNB
    [Arguments]    ${key}
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    ${prach_params_dict}    Fetch Prach Parameters From yaml    test_name=${key}
    Update Prach Parameters    nrcell_distname=${NRCELL_DISTNAME}    &{prach_params_dict}
    ${delta_store}    Collect Delta Store
    Recommission with Updated Prach Parameters    delta_json=${delta_store}    should_activate=${True}

Update Original Prach Params in gNB
    [Arguments]    ${prach_args}
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    Update Prach Parameters    nrcell_distname=${NRCELL_DISTNAME}    &{prach_args}
    ${delta_store}    Collect Delta Store
    Recommission with Updated Prach Parameters    delta_json=${delta_store}    should_activate=${True}

Recommission with Updated Prach Parameters
    [Arguments]    ${delta_json}    ${should_activate}=${True}
    admin_helper.Recommission With Delta From Admin    delta_json=${delta_json}    should_activate=${should_activate}
