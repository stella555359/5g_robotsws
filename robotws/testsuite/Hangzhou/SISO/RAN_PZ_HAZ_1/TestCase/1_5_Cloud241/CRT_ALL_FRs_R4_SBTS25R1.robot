*** Settings ***
Documentation    Suite description
...    Author: xiaohong.h.chen@nokia.com
...    Maintainer: Author

Suite Setup    Suite Precondition
Suite Teardown    Suite Postcondition

Variables    ./env.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot
Library    taf.selenium.sbts    WITH NAME    sbts

Force Tags    CLOUD_RF_AIL_B1_AEHC_CRT2_UTE4G152    CA_RAN_PZ_HAZ_1    CA_4G_SISOPZ    SBTS00    RAN_4G    RAN_4G_TDD    CRT

Test Timeout    73h
*** Variables ***
${pk1_T4}    "111":[100,9.2],"112":[100,9.2],"113":[100,9.2],"114":[100,9.2]
${pk1_T3}    "111":[100,9.2],"112":[75,6],"113":[50,4]

&{CLOUD_RF_CRT2_UTE4G152_AEHC_T3_20M_15M_10M_SRSfalse_SBTS25R1}=    HW_ID=ABIO    ONAIR_TIME=20 min    site_mode=4G

&{CLOUD_RF_CRT2_UTE4G152_AEHC_T4x20M_SBTS25R1}=    HW_ID=ABIO    ONAIR_TIME=20 min    site_mode=4G
...    peak_rate_config={${pk1_T4}}

&{CLOUD_RF_CRT2_UTE4G152_AEHC_T4_TM8_SBTS25R1}=    HW_ID=ABIO    ONAIR_TIME=20 min    site_mode=4G

#${INIT_CONFIG_ID}=     CLOUD_RF_CRT2_UTE4G152_AEHC_T4_TM8_SBTS25R1

${GLO_TL_DESCRIPTOR_FILE_PATH}=    ${CURDIR}/TLdescriptor.xml

${TOP50}    True

${GLO_SCOUT_TESTLINE_NAME}    1_5_Cloud241


*** Test Cases ***

Test_Dedicated_downlink_3_8
    [Tags]    QC_83822    QCD_MN_RAN  QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=testmode_dl
    ...    config_id=CLOUD_RF_CRT2_UTE4G152_AEHC_T3_20M_15M_10M_SRSfalse_SBTS25R1
    [Timeout]    72h
    Test_Dedicated_downlink
    [Teardown]    Testcase Basic Postcondition

Functional_Test_Dedicated_uplink
    [Tags]    QC_83821    QCD_MN_RAN  QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=testmode_ul
    ...    config_id=CLOUD_RF_CRT2_UTE4G152_AEHC_T3_20M_15M_10M_SRSfalse_SBTS25R1
    [Timeout]    72h
    Test_Dedicated_uplink
    [Teardown]    Testcase Basic Postcondition

CONF_2_Common_SiSo_Call_Multicarrier Throughput Measurements when block one cell
    [Tags]    QC_137619    QCD_MN_RAN  QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=block
    ...    config_id=CLOUD_RF_CRT2_UTE4G152_AEHC_T4x20M_SBTS25R1
    [Timeout]    72h
    Common_SiSo_Call_Multicarrier Throughput Measurements when block one cell   L1202407675
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Exceptional_SWDL for factory load SW RRU
    [Tags]    QC_137618    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Factory
    ...    config_id=CLOUD_RF_CRT2_UTE4G152_AEHC_T4_TM8_SBTS25R1
    [Timeout]    72h
    SWDL For Factory Load SW RRU    L1202407675
    [Teardown]    Testcase Basic Postcondition
