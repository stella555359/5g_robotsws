*** Settings ***
Documentation
...    Author: He winnie
...    Contact: winnie.he@nokia-sbell.com
...    Common KWs use to operate the bts
Library             BuiltIn
Library             Collections
Library             DateTime
Library             json
Library             OperatingSystem
Library             Process
Library             String
Library             ./kpi_operation/   WITH NAME    kpi_oper
Library             ./kpi_operation/kpi_operation_scout.py   WITH NAME    kpi_operation_scout

*** Keywords ***
_kpi_operation.interface
    [Arguments]    ${operation}
    ...    ${product_type}=gnb  #enb
    ...    ${bts_index}=${0}
    ...    ${du_index}=${0}
    ...    &{kwargs}
    ${value}    Run Keyword
    ...    _kpi_operation.${operation}    product_type=${product_type}
    ...    bts_index=${bts_index}
    ...    du_index=${du_index}
    ...    alias=kpi_operation_${product_type}_${bts_index}_${du_index}
    ...    &{kwargs}
    [Return]    ${value}

_kpi_operation.start_kpi_collection
    [Arguments]    ${product_type}=gnb  #enb
    ...    ${bts_index}=${0}
    ...    ${du_index}=${0}
    ...    ${server_type}=bk
    ...    &{kwargs}
    kpi_oper.start_kpi_collection    product_type=${product_type}
    ...    bts_index=${bts_index}
    ...    du_index=${du_index}
    ...    server_type=${server_type}
    ...    &{kwargs}

_kpi_operation.add_kpi_collection
    [Arguments]    ${alias}=default_kpi_operation
    ...    &{kwargs}
    Log To Console    ${alias}
    ${input_keys}    Get Dictionary Keys    ${kwargs}
    ${append_bts_index}    Set Variable If    'append_bts_index' in ${input_keys}
    ...    ${kwargs}[append_bts_index]
    ...    ${0}
    ${append_du_index}    Set Variable If    'append_du_index' in ${input_keys}
    ...    ${kwargs}[append_du_index]
    ...    ${0}
    ${append_product_type}    Set Variable If    'append_product_type' in ${input_keys}
    ...    ${kwargs}[append_product_type]
    ...    gnb
    ${oam_ip}    Set Variable If    'oam_ip' in ${input_keys}
    ...    ${kwargs}[oam_ip]
    ...    ${None}
    kpi_oper.add_kpi_collection    product_type=${append_product_type}
    ...    bts_index=${append_bts_index}
    ...    du_index=${append_du_index}
    ...    oam_ip=${oam_ip}
    ...    alias=${kwargs}[product_type]_${kwargs}[bts_index]_${kwargs}[du_index]

_kpi_operation.finish_kpi_collection
    [Arguments]    ${alias}=default_kpi_operation
    ...    &{kwargs}
    Log To Console    ${alias}
    ${pmfile_zip_path}    kpi_oper.finish_kpi_collection
    ...    alias=${kwargs}[product_type]_${kwargs}[bts_index]_${kwargs}[du_index]
    [Return]    ${pmfile_zip_path}

_kpi_operation.kpi_report_generate
    [Arguments]    ${template}=PMKPI_SBTS25R3_5G_up
    ...    ${pmfile_zip_path}=${None}
    ...    ${owner}=${None}
    ...    &{kwargs}
    Should Not Be Equal     ${pmfile_zip_path}    ${None}
    ${ret}    kpi_oper.kpi_report_generate
    ...    template=${template}
    ...    pmfile_zip_path=${pmfile_zip_path}
    ...    owner=${owner}
    [Return]    ${ret}

_kpi_operation.benchmark_report_generate
    [Arguments]    ${pmfile_zip_path1}=${None}
    ...    ${pmfile_zip_path2}=${None}
    ...    ${template1}=PMKPI_SBTS25R3_5G_up
    ...    ${template2}=PMKPI_SBTS25R3_5G_up
    ...    ${owner}=${None}
    ...    &{kwargs}
    Should Not Be Equal     ${pmfile_zip_path1}    ${None}
    Should Not Be Equal     ${pmfile_zip_path2}    ${None}
    ${ret}    kpi_oper.benchmark_report_generate
    ...    pmfile_zip_path1=${pmfile_zip_path1}
    ...    pmfile_zip_path2=${pmfile_zip_path2}
    ...    template1=${template1}
    ...    template2=${template2}
    ...    owner=${owner}
    [Return]    ${ret}

#############for scout################
_kpi_operation.start_kpi_collection_scout
    [Arguments]    ${product_type}=gnb  #enb
    ...    ${bts_index}=${0}
    ...    ${du_index}=${0}
    ...    ${scout_testline_name}=${None}
    ...    &{kwargs}
    ${keys}    Get Dictionary Keys    ${kwargs}
    # Run Keyword If    "api_key" in ${keys} and "${kwargs}[api_key]" != "${None}"
    # ...    kpi_operation_scout.set_api_key    api_key=${kwargs}[api_key]
    ${start_time}    kpi_operation_scout.start_kpi_collection_scout    product_type=${product_type}
    ...    bts_index=${bts_index}
    ...    du_index=${du_index}
    ...    alias=kpi_operation_${product_type}_${bts_index}_${du_index}
    ...    scout_testline_name=${scout_testline_name}
    ...    &{kwargs}
    RETURN   ${start_time}

_kpi_operation.finish_kpi_collection_scout
    [Arguments]    ${alias}=default_kpi_operation_scout
    ...    &{kwargs}
    Log To Console    ${alias}
    ${end_time}  kpi_operation_scout.finish_kpi_collection_scout
    ...    alias=kpi_operation_${kwargs}[product_type]_${kwargs}[bts_index]_${kwargs}[du_index]
    RETURN  ${end_time}

_kpi_operation.generate_comparator_report_scout
    [Arguments]  ${scout_testline_name}    ${product_type}    ${bts_index}    ${du_index}
    ...      ${report_name}   ${template_ids}   ${first_start_time}    ${first_end_time}   ${second_start_time}
    ...      ${second_end_time}    ${alias}=default_kpi_operation_scout    &{kwargs}
    Log   ${alias}
    ${res_link}   kpi_operation_scout.generate_comparator_report_scout    scout_testline_name=${scout_testline_name}    product_type=${product_type}
    ...    bts_index=${bts_index}     du_index=${du_index}
    ...    report_name=${report_name}   template_ids=${template_ids}  first_start_time=${first_start_time}
    ...    first_end_time=${first_end_time}    second_start_time=${second_start_time}    second_end_time=${second_end_time}
    ...    alias=kpi_operation_${product_type}_${bts_index}_${du_index}
    ...    &{kwargs}
    RETURN    ${res_link}
