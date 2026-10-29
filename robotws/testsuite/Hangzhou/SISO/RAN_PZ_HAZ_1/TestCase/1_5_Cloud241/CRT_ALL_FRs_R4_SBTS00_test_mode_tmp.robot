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
Library    taf.sbts.oam.coam.admin    WITH NAME    coam

Force Tags    CLOUD_4G_5G_CLASSICAL_ASIB_ABIO_AEHC_CLOUD241    CA_RAN_PZ_HAZ_1    CA_4G_SISOPZ    SBTS00    RAN_4G    RAN_4G_TDD    CRT

Test Timeout    73h
*** Variables ***
#${pk1_T4}    "111":[100,9.2],"112":[100,9.2],"113":[100,9.2],"114":[100,9.2]
#${pk1_T3}    "111":[100,9.2],"112":[75,6],"113":[50,4]

#&{CLOUD_RF_CRT2_UTE4G152_AEHC_T3_20M_15M_10M_SBTS00}=    HW_ID=ABIO    ONAIR_TIME=20 min    site_mode=4G
#...    peak_rate_config={${pk1_T3}}

#&{CLOUD_RF_CRT2_UTE4G152_AEHC_T3_20M_15M_10M_SRSfalse_SBTS00}=    HW_ID=ABIO    ONAIR_TIME=20 min    site_mode=4G

#&{CLOUD_RF_CRT2_UTE4G152_AEHC_T4x20M_SBTS00}=    HW_ID=ABIO    ONAIR_TIME=20 min    site_mode=4G
#...    peak_rate_config={${pk1_T4}}

#&{CLOUD_RF_CRT2_UTE4G152_AEHC_T4_TM8_SBTS00}=    HW_ID=ABIO    ONAIR_TIME=20 min    site_mode=4G
#&{CLOUD_RF_CRT2_UTE4G152_AEHC_T4_TM8_8899_SBTS00}=    HW_ID=ABIO    ONAIR_TIME=20 min    site_mode=4G
&{CLOUD_RF_CRT2_UTE4G152_AEHC_TMO_SBTS00}=    HW_ID=ABIP    ONAIR_TIME=20 min    site_mode=5G

${INIT_CONFIG_ID}=     CLOUD_RF_CRT2_UTE4G152_AEHC_TMO_SBTS00

${GLO_TL_DESCRIPTOR_FILE_PATH}=    ${CURDIR}/TLdescriptor.xml

${TOP50}    True

${GLO_SCOUT_TESTLINE_NAME}    1_5_Cloud241_1


*** Test Cases ***

Test_Dedicated_downlink_3_8
    [Tags]    QC_33210    QCD_MN_RAN  QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=testmode_dl
    ...    config_id=CLOUD_RF_CRT2_UTE4G152_AEHC_TMO_SBTS00
    [Timeout]    72h
    Test_Dedicated_downlink_Cloud241
    [Teardown]    Testcase Basic Postcondition

Functional_Test_Dedicated_uplink
    [Tags]    QC_33211    QCD_MN_RAN  QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=testmode_ul
    ...    config_id=CLOUD_RF_CRT2_UTE4G152_AEHC_TMO_SBTS00
    [Timeout]    72h
    Test_Dedicated_downlink_Cloud241
    [Teardown]    Testcase Basic Postcondition


*** Keywords ***

Test_Dedicated_downlink_Cloud241
    [Arguments]    ${timeout}=15 min
	FOR    ${bts_id}    IN    @{BTS_LIST}
        coam.Reset_to_Test_Dedicated   timeout=360   alias=${CASE_NAME}_${bts_id}
        Wait Until Keyword Succeeds    ${timeout}    20 sec   Verify Test Dedicated   ${bts_id}
    END


Verify Test Dedicated
    [Arguments]    ${bts_id}
    ${require_objects_list}    coam.Get Managed Objects    class_name=MRBTS_M    connection=${CASE_NAME}_${bts_id}
    ${require_parameters}    coam.get_parameters    dist_name=${require_objects_list[0]["distName"]}    pattern=testingState
    ...  connection=${CASE_NAME}_${bts_id}
    Should be equal as strings  ${require_parameters["stateInfo"]["testingState"]}  Enabled
