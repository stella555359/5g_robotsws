*** Settings ***
Documentation
...   This ue related keywords

#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Throughput_checking_from_GNB.robot
#Library     ./lib/verify_throughput_from_GNB_log.py    WITH NAME    verify_tput
Library     ./lib/mmw1_util.py

*** Keywords ***
Convert scf parameters to dict type
    [Documentation]    Author: Cui Lingxue
    ...    Description: parameters are organized into list type when used to modify scf file. This keyword is to convert them to
    ...    a dict type variable WITHOUT DIST_NAME, so it is convenient to use as criteria for event trace analysis.
    ...    Input data example: [dict(value='true', dist_name=NR_CELL_NAME, p_name='actDynUlDataSplitMode'),
    ...                         dict(value='30', dist_name=NR_CELL_NAME, p_name='pucchDataDtxNumOfSamples'), ...]
    ...    Return example:  {b'actDynUlDataSplitMode': b'true', b'pucchDataDtxNumOfSamples': b'30', b'puschDataDtxNumOfSamples': b'30', ...}
    [Arguments]    ${scf_parameter_list}    ${is_rest_api_para}=${False}
    ${scf_parameter_dict}    create dictionary
    FOR    ${parameter}    IN    @{scf_parameter_list}
        run keyword if    '${is_rest_api_para}'=='${False}'
        ...    set_to_dictionary    ${scf_parameter_dict}    ${parameter['p_name']}    ${parameter['value']}
        run keyword if    '${is_rest_api_para}'=='${True}'
        ...    convert_rest_api_paras_to_dict    ${scf_parameter_dict}    ${parameter}
    END
    [Return]    ${scf_parameter_dict}

Convert variable to list type
    [Documentation]    Author: Cui Lingxue
    ...    convert int or str type variable to a list.
    ...    Example: ${input_var}=12345 --> ${output_var}=['12345']
    [Arguments]    ${input_var}
    ${is_list}    evaluate    isinstance(${input_var},list)
    ${output_var}    run keyword if    ${is_list}==${False}    create list    ${input_var}
    ...    ELSE    set variable    ${input_var}
    [Return]    ${output_var}

Combine params for online modify
    [Documentation]  Author: Ding Binmei
    ...    Combine params with dict format as bellow and return with dict.
    ...    ${dict_params1}/${dict_params2}: can be in bellow format:
    ...    {'param_to_upd': [{'dist_name': 'MRBTS-413/NRBTS-11171/NRCELL-1', 'parameter': 'actCDrx', 'value': 'true')}],
    ...        'param_to_add': [{'dist_name': 'MRBTS-37241/NRBTS-37241/NRCELL-1','parameter': 'drxProfile2',  'value': [{'drxLongCycle':'20ms'}]}],
    ...        'object_to_add': [{'dist_name': dist_name_nradj, 'parameter': 'cellDepType', 'value': 'SA'},
    ...                        {'dist_name': dist_name_nradj, 'parameter': 'cellReservedForOperatorUse', 'value': 'notReserved'}],
    ...        'param_to_del': [dict(dist_name='MRBTS-37241/NRBTS-37241/NRDU-1/NRECPRI-1', parameter='uPlanePcp')],
    ...            Note: delete list type parameter(like drxProfile2) is not supported by this method in cloud
    ...        'object_to_del': [dict(dist_name= 'MRBTS-37241/NRBTS-37241/NRADJNRCELL-1')]}
    ...    Return format are same as above: {key1:[{},{}]}
    [Arguments]  ${dict_params1}    ${dict_params2}
    @{keys_params1}    Get dictionary keys    ${dict_params1}
    @{keys_params2}    Get dictionary keys    ${dict_params2}
    @{keys}    Evaluate    list(set(${keys_params1}+${keys_params2}))
    &{dict_combine_params}    Create dictionary
    FOR    ${key}   IN    @{keys}
        ${is_key_exist_in_dict_params1}    Run keyword and return status    Dictionary Should Contain key    ${dict_params1}    ${key}
        @{param_in_dict_params1}    Run keyword if    ${is_key_exist_in_dict_params1}    Get from dictionary    ${dict_params1}    ${key}
        ...    ELSE    Create List
        ${is_key_exist_in_dict_params2}    Run keyword and return status    Dictionary Should Contain key    ${dict_params2}    ${key}
        @{param_in_dict_params2}    Run keyword if    ${is_key_exist_in_dict_params2}    Get from dictionary    ${dict_params2}    ${key}
        ...    ELSE    Create List
        @{params_after_combine}    Combine lists    ${param_in_dict_params1}    ${param_in_dict_params2}
        Set to dictionary    ${dict_combine_params}    ${key}=${params_after_combine}
    END
    [Return]    ${dict_combine_params}
