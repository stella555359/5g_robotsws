# @Time    : 2025/9/29 17:13
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : General_SiSo_Static_HW_Capabilities_Validation.robot
# @Software: PyCharm
# @Doc     : Some Description
*** Settings ***
Documentation
...    author: Chen Jian
...    contact: jian.1.chen@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG05
...    Feature Common SISO

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/siso_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot

*** Keywords ***
General_SiSo_Static_HW_Capabilities_Validation_1.0
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/09/29 16:44
    # Common_HW_Validation_Rules_21: BTS shall validate that cell configured power is supported by Radio Module.
    Verify HW Validate Relation Error    error_xml=_pmax_error.xml    error_name=pMax    error_value=500
    # Common_HW_Validation_Rules_22:
    # BTS shall validate that cell configured bandwidth per each cell and iBW per each antenna is supported by Radio Module.
    Verify HW Validate Relation Error    error_xml=_chbw_error.xml    error_name=chBw    error_value=10MHz
    # Common_HW_Validation_Rules_24:BTS shall validate that cell configured power is supported by multiband Radio Module.
    Verify HW Validate Relation Error    error_xml=_freqBandIndicatorNR_error.xml
    ...    error_name=freqBandIndicatorNR    error_value=1024

Verify HW Validate Relation Error
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/09/29 16:20
    [Arguments]    ${error_xml}=_chbw_error.xml    ${error_name}=chBw    ${error_value}=10MHz    ${cell_id}=${1}
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}/SCF
    ${scf}    selenium_coam.save_bts_configuration    save_configuration_type=${0}
    ${scf_hw_error}    Replace String    ${scf}    .xml    ${error_xml}
    scf.load_scf    ${scf}
    scf.modify_scf_element    value=${error_value}    p_name=${error_name}
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    scf.save_scf    ${scf_hw_error}
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${scf_hw_error}
    ${relation_errors}    selenium_coam.get_relation_errors
    Should Not Be Empty    ${relation_errors}
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${scf}
    ${relation_errors}    selenium_coam.get_relation_errors
    Should Be Empty    ${relation_errors}
    Selenium Logout And Close Browser
