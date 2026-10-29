# @Time    : 2022/3/1 14:10
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : nidd_verify.robot
# @Software: PyCharm
*** Settings ***
Documentation    This is common nidd verify keyword
Library     ../python/csvanalyzer.py

*** Keywords ***
Verify NIDD Defination Params
    [Documentation]    Check Five Fields
    ...    Data Type    Description    Description of parameter relationships
    ...    Required on creation    Modification
    [Arguments]    ${file_path}    ${param_name}    ${param_details}
    ${nidd_defination_params}    get_the_special_item_row_values    ${file_path}    Abbreviation    ${param_name}
    Should Be Equal As Strings    ${nidd_defination_params['Data Type']}    ${param_details['Data type']}
    Should Be Equal As Strings    ${nidd_defination_params['Description']}    ${param_details['Description']}
    Should Be Equal As Strings    ${nidd_defination_params['Description of parameter relationships']}
    ...    ${param_details['Description of relationship']}
    Should Be Equal As Strings    ${nidd_defination_params['Required on creation']}    ${param_details['Creation priority']}
    Should Be Equal As Strings    ${nidd_defination_params['Modification']}    ${param_details['Modification type']}

Verify Parameter Same With NIDD Defination
    [Documentation]    Usage example
    ...    dist_name = MRBTS-2003/MNL-1
    ...    filter_param = Product variant planned
    ...    abbr = productVariantPlanned
    ...    nidd_file = ${CURDIR}/TestData/CB008797_nidd.csv
    [Arguments]    ${dist_name}    ${filter_param}    ${abbr}    ${nidd_file}
    Connect to gnb coam via ssl
    Selenium Login With Version
    ${details}    selenium_coam.get_parameter_details    dist_name=${dist_name}    filter_param=${filter_param}    abbr=${abbr}
    ${result}    ${release}    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
    Verify NIDD Defination Params    file_path=${nidd_file}    param_name=${abbr}-${release}    param_details=${details}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    Selenium Logout And Close Browser    AND
    ...    Run Keyword And Ignore Error    COAM Teardown gnb connections
