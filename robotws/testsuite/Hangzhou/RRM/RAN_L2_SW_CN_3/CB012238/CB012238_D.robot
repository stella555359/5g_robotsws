*** Settings ***
Documentation
...    author: Yang Di
...    Contact: di.yang@nokia-sbell.com
...    Team: RAN RD VRF HAZ3 5
...    Feature: CB012238_D: QoS fairness slice aware scheduler interworking with NBR DRBs with NBR congestion

Force Tags       AP    CRT    SBTS00   CLOUD_5G_I_LOO_AP_LOOO
Resource         CB012238_common.robot

Test Setup       Run Keywords    Common Suite Setup    AND    Common Test Setup
Test Teardown    Run Keywords    Common Test Teardown    AND    Common Suite Teardown
...       AND    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'before_onair' file '${None}'

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${D_COUNTERS_1}  M55910C00001,M55910C00002,M55910C00003,M55910C00004,M55308C10012,M55308C10013,M55300C12010
${D_COUNTERS_2}  M55139C03506,M55139C03507,M55139C03508,M55139C03509,M55139C03510,M55139C03511,M55370C00041
${D_COUNTERS_3}  M55910C00003,M55910C00004,M55308C10012,M55370C00041,M55139C03506,M55139C03507,M55139C03508,M55139C03510,M55139C03511

&{D033_COMMON_VARIABLES}    SCFC_NAME=D_033.xml    AIRPHONE_NAME=A_015_ap.xml    WTS_NAME=D_common_wts.cfg
...    GNBCUTYPE=NSA    GNB_SWCONFIG_NAME=A_common_gnb.txt    AP_SWCONFIG_NAME=A_common_ap.txt
${D033_DL_STEP1_G1_EXPECT}     ${87.4}
${D033_DL_STEP1_G9_EXPECT}     ${12.6}
${D033_DL_STEP2_G1_EXPECT}     ${46.6}
${D033_DL_STEP2_G9_EXPECT}     ${53.4}

${D033_UL_STEP1_G1_EXPECT}     ${87.1}
${D033_UL_STEP1_G9_EXPECT}     ${12.9}
${D033_UL_STEP2_G1_EXPECT}     ${87}
${D033_UL_STEP2_G9_EXPECT}     ${13}

&{D034_COMMON_VARIABLES}    SCFC_NAME=D_034.xml    AIRPHONE_NAME=A_common_ap.xml    WTS_NAME=D_common_wts.lua
...    GNBCUTYPE=SANSA    GNB_SWCONFIG_NAME=A_common_gnb.txt    AP_SWCONFIG_NAME=A_common_ap.txt
${D034_DL_STEP1_G1_EXPECT}     ${87.1}
${D034_DL_STEP1_G9_EXPECT}     ${12.9}
${D034_DL_STEP2_G1_EXPECT}     ${86.2}
${D034_DL_STEP2_G9_EXPECT}     ${13.8}

${D034_UL_STEP1_G1_EXPECT}     ${88.9}
${D034_UL_STEP1_G9_EXPECT}     ${11.1}
${D034_UL_STEP2_G1_EXPECT}     ${83.9}
${D034_UL_STEP2_G9_EXPECT}     ${16.1}

&{D037_COMMON_VARIABLES}    SCFC_NAME=D_037.xml    AIRPHONE_NAME=A_015_ap.xml    WTS_NAME=D_common_wts.cfg
...    GNBCUTYPE=NSA    GNB_SWCONFIG_NAME=A_common_gnb.txt    AP_SWCONFIG_NAME=A_common_ap.txt
${D037_UL_G1_EXPECT_STEP1}     ${84.4}
${D037_UL_G9_EXPECT_STEP1}     ${5.3}
${D037_UL_G18_EXPECT_STEP1}    ${10.3}
${D037_UL_G1_EXPECT_STEP2}     ${85.0}
${D037_UL_G9_EXPECT_STEP2}     ${5.5}
${D037_UL_G18_EXPECT_STEP2}    ${9.5}

*** Test Cases ***
CB012238_SR_033_USCB012238-D#B1_QoS_fairness_Slice_aware_scheduler_interacts_with_NBR_with_enhanced_SVC
    [Tags]    033
    Airphone Set Common Test Variables    common_variables=${D033_COMMON_VARIABLES}    need_swconfig=True
    Wait Until Keyword Succeeds    3x    15s    D033 Need Retry

CB012238_SR_034_USCB012238-D#B1_QoS_fairness_Slice_aware_scheduler_interacts_with_NBR_with_enhanced_SVC_ALT1
    [Tags]    034
    Airphone Set Common Test Variables    common_variables=${D033_COMMON_VARIABLES}    need_swconfig=True
    Wait Until Keyword Succeeds    1x    15s    D034 Need Retry

CB012238_SR_037_USCB012238-D#B3_Qos_fairness_slice_aware_uplink_scheduler_interacts_with_NBR_congestion
    [Tags]    037
    Airphone Set Common Test Variables    common_variables=${D037_COMMON_VARIABLES}    need_swconfig=True
    Prepare gnb onair
    Airphone Cleanup Egate Console Log
    Wait Until Keyword Succeeds    1x    15s    D037 Need Retry

