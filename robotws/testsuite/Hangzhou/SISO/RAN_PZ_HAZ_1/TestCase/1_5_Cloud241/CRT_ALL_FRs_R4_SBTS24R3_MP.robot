*** Settings ***
Documentation    Suite description
...    Author: deli.wang@nokia.com
...    Maintainer: Author

Suite Setup    Suite Precondition
Suite Teardown    Suite Postcondition

Variables    ./env.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot
Library    taf.selenium.sbts    WITH NAME    sbts

Force Tags    CLOUD_RF_AIL_B1_AEHC_CRT2_UTE4G152    CA_RAN_PZ_HAZ_1    CA_4G_SISOPZ    SBTS24R3    RAN_4G    RAN_4G_TDD    CRT

Test Timeout    73h
*** Variables ***
${pk1_T4}    "111":[100,9.2],"112":[100,9.2],"113":[100,9.2],"114":[100,9.2]
${pk1_T3}    "111":[100,9.2],"112":[75,6],"113":[50,4]

&{CLOUD_RF_CRT2_UTE4G152_AEHC_T3_20M_15M_10M_SBTS24R3}=    HW_ID=ABIO    ONAIR_TIME=20 min    site_mode=4G
...    peak_rate_config={${pk1_T3}}

&{CLOUD_RF_CRT2_UTE4G152_AEHC_T3_20M_15M_10M_SRSfalse_SBTS24R3}=    HW_ID=ABIO    ONAIR_TIME=20 min    site_mode=4G

&{CLOUD_RF_CRT2_UTE4G152_AEHC_T4x20M_SBTS24R3}=    HW_ID=ABIO    ONAIR_TIME=20 min    site_mode=4G
...    peak_rate_config={${pk1_T4}}

&{CLOUD_RF_CRT2_UTE4G152_AEHC_T4_TM8_SBTS24R3}=    HW_ID=ABIO    ONAIR_TIME=20 min    site_mode=4G
&{CLOUD_RF_CRT2_UTE4G152_AEHC_T4_TM8_8899_SBTS24R3}=    HW_ID=ABIO    ONAIR_TIME=20 min    site_mode=4G

#${INIT_CONFIG_ID}=     CLOUD_RF_CRT2_UTE4G152_AEHC_T4_TM8_SBTS24R3

${GLO_TL_DESCRIPTOR_FILE_PATH}=    ${CURDIR}/TLdescriptor.xml

${GLO_SCOUT_TESTLINE_NAME}    1_5_Cloud241


*** Test Cases ***
CONF_2_Common_SiSo_Call_Multicarrier Throughput Measurements when block one cell
    [Tags]    QC_861975    QCD_MN_RAN    QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=block
    ...    config_id=CLOUD_RF_CRT2_UTE4G152_AEHC_T4x20M_SBTS24R3
    [Timeout]    72h
    Common_SiSo_Call_Multicarrier Throughput Measurements when block one cell   L1202407675
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Exceptional_SWDL for factory load SW RRU
    [Tags]    QC_861978    QCD_MN_RAN    QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=Factory
    ...    config_id=CLOUD_RF_CRT2_UTE4G152_AEHC_T4_TM8_SBTS24R3
    [Timeout]    72h
    SWDL For Factory Load SW RRU    L1202407675
    [Teardown]    Testcase Basic Postcondition
