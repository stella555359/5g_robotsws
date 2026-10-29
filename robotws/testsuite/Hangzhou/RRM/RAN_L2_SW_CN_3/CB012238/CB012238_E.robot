# @Time    : 2025/9/5 10:45
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @Group   : NSB MN RAN RD VRF HAZ3 5
# @File    : CB012238_E.robot
# @Software: PyCharm
# @Doc     : Some Description
*** Settings ***
Documentation
...    author: Chen Jian
...    Contact: jian.1.chen@nokia-sbell.com
...    Team: RAN RD VRF HAZ3 5
...    Feature: CB012238-SR-E - Effort Placeholder for CP1 based plan ST_HAZ3_SG5

Test Setup    Run Keywords    Common Suite Setup    AND    Common Test Setup
Test Teardown    Run Keywords    Common Test Teardown    AND    Common Suite Teardown
...    AND    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'before_onair' file '${None}'
Force Tags    AP    CRT    SBTS00   CLOUD_5G_I_LOO_AP_LOOO

Resource    CB012238_common.robot

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${E_COUNTERS}    M55910C00001,M55910C00025,M55308C10013,M55910C00002,M55910C00003,M55910C00026,M55308C10012,M55910C00004
&{E038_COMMON_VARIABLES}    SCFC_NAME=E_038.xml    AIRPHONE_NAME=E_common_ap.xml    WTS_NAME=E_common_wts.lua
...    GNBCUTYPE=SA    GNB_SWCONFIG_NAME=A_common_gnb.txt    AP_SWCONFIG_NAME=A_common_ap.txt
${E038_STEP1_UL_G1_EXCEPT}    ${65.38}
${E038_STEP1_UL_G9_EXCEPT}    ${12.21}
${E038_STEP1_UL_G18_EXCEPT}    ${22.4}
${E038_STEP1_DL_G1_EXCEPT}    ${68.15}
${E038_STEP1_DL_G9_EXCEPT}    ${10.7}
${E038_STEP1_DL_G18_EXCEPT}    ${21.15}

${E038_STEP2_UL_G1_EXCEPT}    ${70.38}
${E038_STEP2_UL_G9_EXCEPT}    ${16.54}
${E038_STEP2_UL_G18_EXCEPT}    ${13.08}
${E038_STEP2_DL_G1_EXCEPT}    ${68.25}
${E038_STEP2_DL_G9_EXCEPT}    ${10.76}
${E038_STEP2_DL_G18_EXCEPT}    ${20.99}

*** Test Cases ***
CB012238_SR_038_USCB012238-E#IWK1_Qos_fairness_slice_aware_scheduler_with_enhanced_SVC_interworking_with_MU-MIMO
    [Documentation]    TA Author: jian.1.chen@nokia-sbell.com
    ...    Test Author: hongna.zhang@nokia-sbell.com
    ...    Init Define: 2025/09/05 10:47
    [Tags]    038
    Airphone Set Common Test Variables    common_variables=${E038_COMMON_VARIABLES}    need_swconfig=True
    Sleep    300s
    Get and Update BSR File		par_of_bsr_name=BSR_AEHC_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    Wait Until Keyword Succeeds    3x    15s    E038 Need Retry

