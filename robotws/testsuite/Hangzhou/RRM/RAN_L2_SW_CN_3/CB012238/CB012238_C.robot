*** Settings ***
Documentation
...    author: Yang Di
...    Contact: di.yang@nokia-sbell.com
...    Team: RAN RD VRF HAZ3 5
...    Feature: CB012238_C: QoS fairness slice aware scheduler interworking with PLMN aware scheduler with PRB sharing

Force Tags       AP    CRT    SBTS00   CLOUD_5G_I_LOO_AP_LOOO
Resource         CB012238_common.robot

Test Setup       Run Keywords    Common Suite Setup    AND    Common Test Setup
Test Teardown    Run Keywords    Common Test Teardown    AND    Common Suite Teardown
...       AND    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'before_onair' file '${None}'

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${C_COUNTERS}         M55308C10013,M55910C00001,M55910C00002,M55338C00001,M55338C00003,M55338C00005

&{C023_COMMON_VARIABLES}    SCFC_NAME=C_023.xml    AIRPHONE_NAME=E_common_ap.xml    WTS_NAME=C_common_wts.lua
...    GNBCUTYPE=SANSA    GNB_SWCONFIG_NAME=A_common_gnb.txt    AP_SWCONFIG_NAME=A_common_ap.txt
${C023_G1_EXPECT}    ${72.5}
${C023_G2_EXPECT}    ${11.25}
${C023_G3_EXPECT}    ${16.25}
${C023_G4_EXPECT}    ${47.2}
${C023_G5_EXPECT}    ${23.9}
${C023_G6_EXPECT}    ${28.9}
${C023_G7_EXPECT}    ${57.2}
${C023_G8_EXPECT}    ${18.9}
${C023_G9_EXPECT}    ${23.9}

*** Test Cases ***
CB012238_SR_023_USCB012238-C#B3_QoS_fairness_slice_aware_scheduler_interworking_with_PLMN-aware_scheduler_and_PLMN_PRB_sharing_disabled_in_DL
    [Tags]    023
    Airphone Set Common Test Variables    common_variables=${C023_COMMON_VARIABLES}    need_swconfig=True
    Get and Update BSR File		par_of_bsr_name=BSR_AEHC_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    Wait Until Keyword Succeeds    3x    15s    C023 Need Retry

