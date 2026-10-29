*** Settings ***
Documentation
...   Author: Winnie He
...   Contact: winnie.he@nokia-sbell.com
...   Module for the traffic module in airphone env
...   Operation = traffic module

Resource    ../Module/KPI_Operation.robot
Library     ../Module/library/module_utils/module_utils.py    WITH NAME    module_utils
*** Keywords ***
RRM Traffic With Airphone
    [Arguments]    ${traffic_module_config_path}
    ...    ${operation}=simple_traffic_with_airphone
    ...    ${lua_path}=${CURDIR}/library/traffic_model_for_et/cer1.lua
    ...    ${product_type}=gnb
    ...    ${bts_index}=${0}
    ...    ${du_index}=${0}
    ...    ${email}=winnie.he@nokia-sbell.com
    ...    ${need_generate_report}=${TRUE}
    ...    ${timeout}=1 hours
    ...    &{kwargs}
    Log    ${operation} is not used
    ${dire}    module_utils.setup_module_directory    module_name=rrm_traffic_with_airphone
    ${timedelta}    Convert Time    ${timeout}    timedelta
    ${cmd}    Catenate    python
    ...    ${CURDIR}/library/traffic_model_for_et/traffic_model_for_et.py
    ...    --config_path
    ...    ${traffic_module_config_path}
    ...    --lua_path
    ...    ${lua_path}
    ...    --timeout
    ...    ${timedelta}
    ...    --output
    ...    ${dire}
    Log    Start to run the traffic model ${cmd} > ${output_file} 2>&1
    ${offset_time}=    Run Keyword If    'offset_time' in ${kwargs}
    ...    Get From Dictionary    ${kwargs}    offset_time
    ...    ELSE    Set Variable    0
    KPI Operation    start_kpi_collection    product_type=${product_type}
    ...    bts_index=${bts_index}
    ...    du_index=${du_index}
    ...    offset_time=${offset_time}
    ${output_file}    Set Variable    ${dire}/traffic_model_output.log
    OperatingSystem.Run     ${cmd} > ${output_file} 2>&1
    ${zip_path1}    KPI Operation    finish_kpi_collection
    ...    product_type=${product_type}
    ...    bts_index=${bts_index}
    ...    du_index=${du_index}
    Run Keyword If    "${need_generate_report}"=="${True}"
    ...    KPI Operation    kpi_report_generate    pmfile_zip_path=${zip_path1}
    ...    owner=${email}
    [Return]    ${zip_path1}

