# @Time    : 2025/8/4 15:59
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @Group   : NSB MN RAN RD VRF HAZ3 5
# @File    : CB012238_A.robot
# @Software: PyCharm
# @Doc     : Some Description
*** Settings ***
Documentation
...    author: Chen Jian
...    Contact: jian.1.chen@nokia-sbell.com
...    Team: RAN RD VRF HAZ3 5
...    Feature: CB012238_A:Slice aware scheduler - QoS fairness

Test Setup    Run Keywords    Common Suite Setup    AND    Common Test Setup
Test Teardown    Run Keywords    Common Test Teardown    AND    Common Suite Teardown
...    AND    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'before_onair' file '${None}'
Force Tags    AP    CRT    SBTS00   CLOUD_5G_I_LOO_AP_LOOO

Resource    CB012238_common.robot

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${A_COUNTERS}    M55308C10013,M55910C00001,M55910C00002

&{A002_COMMON_VARIABLES}    SCFC_NAME=A_002.xml    AIRPHONE_NAME=A_common_ap.xml    WTS_NAME=A_common_wts.lua
...    GNBCUTYPE=NSA    GNB_SWCONFIG_NAME=A_common_gnb.txt    AP_SWCONFIG_NAME=A_common_ap.txt
&{A006_COMMON_VARIABLES}    SCFC_NAME=A_006.xml    AIRPHONE_NAME=A_common_ap.xml    WTS_NAME=A_common_wts.lua
...    GNBCUTYPE=NSA    GNB_SWCONFIG_NAME=A_common_gnb.txt    AP_SWCONFIG_NAME=A_common_ap.txt
${A002_A006_STEP1_G1_EXCEPT}    ${10+800/880*85}
${A002_A006_STEP1_G9_EXCEPT}    ${5+80/880*85}
${A002_A006_STEP2_G1_EXCEPT}    ${5+800/880*45}
${A002_A006_STEP2_G9_EXCEPT}    ${50+80/880*45}

&{A003_COMMON_VARIABLES}    SCFC_NAME=A_003.xml    AIRPHONE_NAME=A_common_ap.xml    WTS_NAME=A_common_wts.lua
...    GNBCUTYPE=NSA    GNB_SWCONFIG_NAME=A_common_gnb.txt    AP_SWCONFIG_NAME=A_common_ap.txt
&{A007_COMMON_VARIABLES}    SCFC_NAME=A_007.xml    AIRPHONE_NAME=A_common_ap.xml    WTS_NAME=A_common_wts.lua
...    GNBCUTYPE=NSA    GNB_SWCONFIG_NAME=A_common_gnb.txt    AP_SWCONFIG_NAME=A_common_ap.txt
${A003_A007_STEP1_G2_EXCEPT}    ${1+33/197*29}
${A003_A007_STEP1_G3_EXCEPT}    ${70+164/197*29}
${A003_A007_STEP2_G2_EXCEPT}    ${20+33/197*50}
${A003_A007_STEP2_G3_EXCEPT}    ${30+164/197*50}

&{A009_COMMON_VARIABLES}    SCFC_NAME=A_009.xml    AIRPHONE_NAME=A_015_ap.xml    WTS_NAME=A_009_wts.cfg
...    GNBCUTYPE=NSA    GNB_SWCONFIG_NAME=A_common_gnb.txt    AP_SWCONFIG_NAME=A_common_ap.txt
${A009_STEP1_G1_EXPECT}    ${10+85*2/802}
${A009_STEP1_G9_EXPECT}    ${5+85*800/802}
${A009_STEP2_G1_EXPECT}    ${10+85*800/804}
${A009_STEP2_G9_EXPECT}    ${5+85*4/804}

&{A010_COMMON_VARIABLES}    SCFC_NAME=A_010.xml    AIRPHONE_NAME=A_015_ap.xml    WTS_NAME=A_009_wts.cfg
...    GNBCUTYPE=NSA    GNB_SWCONFIG_NAME=A_common_gnb.txt    AP_SWCONFIG_NAME=A_common_ap.txt
${A010_STEP1_G1_EXPECT}    ${10+75*240/272}
${A010_STEP1_G9_EXPECT}    ${5+75*16/272}
${A010_STEP1_G18_EXPECT}   ${10+75*16/272}
${A010_STEP2_G1_EXPECT}    ${10+75*160/192}
${A010_STEP2_G9_EXPECT}    ${5+75*16/194}
${A010_STEP2_G18_EXPECT}   ${10+75*16/192}

&{A015_COMMON_VARIABLES}    SCFC_NAME=A_015.xml    AIRPHONE_NAME=A_015_ap.xml    WTS_NAME=A_015_wts.cfg
...    GNBCUTYPE=NSA    GNB_SWCONFIG_NAME=A_common_gnb.txt    AP_SWCONFIG_NAME=A_common_ap.txt
${A015_STEP1_G1_EXCEPT}    ${15+85/260*60}
${A015_STEP1_G9_EXCEPT}    ${20+80/260*60}
${A015_STEP1_G18_EXCEPT}    ${5+95/260*60}
${A015_STEP2_G1_EXCEPT}    ${31}
${A015_STEP2_G9_EXCEPT}    ${43}
${A015_STEP2_G18_EXCEPT}    ${26}

&{A018_COMMON_VARIABLES}    SCFC_NAME=A_018.xml    AIRPHONE_NAME=A_common_ap.xml    WTS_NAME=A_common_wts.lua
...    GNBCUTYPE=SANSA    GNB_SWCONFIG_NAME=A_common_gnb.txt    AP_SWCONFIG_NAME=A_common_ap.txt
${A018_STEP1_G1_EXPECT}    ${10+85*90/185}
${A018_STEP1_G9_EXPECT}    ${5+85*95/185}
${A018_STEP2_G1_EXPECT}    ${10+85*80/88}
${A018_STEP2_G9_EXPECT}    ${5+85*8/88}

&{A021_COMMON_VARIABLES}    SCFC_NAME=A_021.xml    AIRPHONE_NAME=A_021_ap.xml    WTS_NAME=A_common_wts.lua
...    GNBCUTYPE=NSA    GNB_SWCONFIG_NAME=A_common_gnb.txt    AP_SWCONFIG_NAME=A_common_ap.txt
${A021_STEP1_G1_EXCEPT}    ${59.1624}
${A021_STEP1_G9_EXCEPT}    ${10.1582}
${A021_STEP1_G18_EXCEPT}    ${30.6794}
${A021_STEP2_G1_EXCEPT}    ${60.7253}
${A021_STEP2_G9_EXCEPT}    ${14.8579}
${A021_STEP2_G18_EXCEPT}    ${24.4168}
${A021_STEP4_G1_EXCEPT}    ${24.1301}
${A021_STEP4_G9_EXCEPT}    ${75.8699}
${A021_STEP4_G18_EXCEPT}    ${0}

&{A022_COMMON_VARIABLES}    SCFC_NAME=A_022.xml    AIRPHONE_NAME=A_022_ap.xml    WTS_NAME=A_022_wts.cfg
...    GNBCUTYPE=NSA    GNB_SWCONFIG_NAME=A_common_gnb.txt    AP_SWCONFIG_NAME=A_common_ap.txt
${A022_STEP1_G1_EXCEPT}    ${0.1786}
${A022_STEP1_G2_EXCEPT}    ${0}
${A022_STEP1_G9_EXCEPT}    ${61.209}
${A022_STEP1_G18_EXCEPT}    ${0.1822}
${A022_STEP1_G32_EXCEPT}    ${38.431}
${A022_STEP2_G1_EXCEPT}    ${0.1819}
${A022_STEP2_G2_EXCEPT}    ${0}
${A022_STEP2_G9_EXCEPT}    ${56.45}
${A022_STEP2_G18_EXCEPT}    ${0.1823}
${A022_STEP2_G32_EXCEPT}    ${43.18}

*** Test Cases ***
CB012238_SR_002_USCB012238-A#B1_QoS_fairness_slice_aware_scheduler_with_basic_SVC_in_DL_ALT1
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Test Author: hongna.zhang@nokia-sbell.com
    ...    Init Define: 2025/08/04 16:09
    [Tags]    002
    Airphone Set Common Test Variables    common_variables=${A002_COMMON_VARIABLES}    need_swconfig=True
    Wait Until Keyword Succeeds    3x    15s    A002 006 Need Retry

CB012238_SR_006_USCB012238-A#B2_QoS_fairness_slice_aware_scheduler_with_enhanced_SVC_in_DL_ALT1
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Test Author: hongna.zhang@nokia-sbell.com
    ...    Init Define: 2025/08/04 16:09
    [Tags]    006
    Airphone Set Common Test Variables    common_variables=${A006_COMMON_VARIABLES}    need_swconfig=True
    Wait Until Keyword Succeeds    3x    15s    A002 006 Need Retry

CB012238_SR_003_USCB012238-A#B1_QoS_fairness_slice_aware_scheduler_with_basic_SVC_in_DL_ALT-2
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Test Author: hongna.zhang@nokia-sbell.com
    ...    Init Define: 2025/08/04 16:09
    [Tags]    003
    Airphone Set Common Test Variables    common_variables=${A003_COMMON_VARIABLES}    need_swconfig=True
    Wait Until Keyword Succeeds    3x    15s    A003 007 Need Retry

CB012238_SR_007_USCB012238-A#B2_QoS_fairness_slice_aware_scheduler_with_enhanced_SVC_in_DL_ALT2
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Test Author: hongna.zhang@nokia-sbell.com
    ...    Init Define: 2025/08/04 16:09
    [Tags]    007
    Airphone Set Common Test Variables    common_variables=${A007_COMMON_VARIABLES}    need_swconfig=True
    Wait Until Keyword Succeeds    3x    15s    A003 007 Need Retry

CB012238_SR_009_USCB012238-A#B2_QoS_fairness_slice_aware_scheduler_with_enhanced_SVC_in_DL_ALT4
    [Tags]    009
    Airphone Set Common Test Variables    common_variables=${A009_COMMON_VARIABLES}    need_swconfig=True
    Wait Until Keyword Succeeds    3x    15s    A009 Need Retry

CB012238_SR_010_USCB012238-A#B2_QoS_fairness_slice_aware_scheduler_with_enhanced_SVC_in_DL_ALT5
    [Tags]    010
    Airphone Set Common Test Variables    common_variables=${A010_COMMON_VARIABLES}    need_swconfig=True
    Prepare gnb onair
    Airphone Cleanup Egate Console Log
    Wait Until Keyword Succeeds    3x    15s    A010 Need Retry

CB012238_SR_015_USCB012238-A#B4_Qos_fairness_slice_aware_scheduler_with_basic_SVC_with_RG_configuration_change_via_online_modification_1
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Test Author: echo.xu@nokia-sbell.com
    ...    Init Define: 2025/08/04 16:09
    [Tags]    015
    Airphone Set Common Test Variables    common_variables=${A015_COMMON_VARIABLES}    need_swconfig=True
    Wait Until Keyword Succeeds    3x    15s    A015 Need Retry

CB012238_SR_018_USCB012238-A#B5_Qos_fairness_slice_aware_scheduler_with_enhanced_SVC_with_RG_configuration_change_via_online_modification_1
    [Documentation]    Author: di.yang@nokia-sbell.com
    ...    Test Author: di.yang@nokia-sbell.com
    ...    Init Define: 2025/08/04 16:09
    [Tags]    018
    Airphone Set Common Test Variables    common_variables=${A018_COMMON_VARIABLES}    need_swconfig=True
    Prepare gnb onair
    Airphone Cleanup Egate Console Log
    Wait Until Keyword Succeeds    3x    15s    A018 Need Retry

CB012238_SR_021_USCB012238-A#EC6_ Slice aware scheduler for QoS fairness for the UE with empty RG in the cell
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Test Author: hongna.zhang@nokia-sbell.com
    ...    Init Define: 2025/10/09 16:46
    [Tags]    021
    Airphone Set Common Test Variables    common_variables=${A021_COMMON_VARIABLES}    need_swconfig=True
    Wait Until Keyword Succeeds    3x    15s    A021 Need Retry

CB012238_SR_022_USCB012238-A#EC6_ Slice aware scheduler for QoS fairness for the UE with empty RG in the cell_ALT1
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Test Author: echo.xu@nokia-sbell.com
    ...    Init Define: 2025/10/09 16:31
    [Tags]    022
    Airphone Set Common Test Variables    common_variables=${A022_COMMON_VARIABLES}    need_swconfig=True
    Wait Until Keyword Succeeds    3x    15s    A022 Need Retry
