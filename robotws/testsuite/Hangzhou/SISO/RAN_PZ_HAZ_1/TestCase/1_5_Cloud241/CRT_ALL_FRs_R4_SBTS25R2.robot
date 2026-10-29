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

Force Tags    CLOUD_RF_AIL_B1_AEHC_CRT2_UTE4G152    CA_RAN_PZ_HAZ_1    CA_4G_SISOPZ    SBTS25R2    RAN_4G    RAN_4G_TDD    CRT

Test Timeout    73h
*** Variables ***
${pk1_T4}    "111":[100,9.2],"112":[100,9.2],"113":[100,9.2],"114":[100,9.2]
${pk1_T3}    "111":[100,9.2],"112":[75,6],"113":[50,4]

&{CLOUD_RF_CRT2_UTE4G152_AEHC_T3_20M_15M_10M_SBTS25R2}=    HW_ID=ABIO    ONAIR_TIME=20 min    site_mode=4G
...    peak_rate_config={${pk1_T3}}

&{CLOUD_RF_CRT2_UTE4G152_AEHC_T3_20M_15M_10M_SRSfalse_SBTS25R2}=    HW_ID=ABIO    ONAIR_TIME=20 min    site_mode=4G

&{CLOUD_RF_CRT2_UTE4G152_AEHC_T4x20M_SBTS25R2}=    HW_ID=ABIO    ONAIR_TIME=20 min    site_mode=4G
...    peak_rate_config={${pk1_T4}}

&{CLOUD_RF_CRT2_UTE4G152_AEHC_T4_TM8_SBTS25R2}=    HW_ID=ABIO    ONAIR_TIME=20 min    site_mode=4G
&{CLOUD_RF_CRT2_UTE4G152_AEHC_T4_TM8_8899_SBTS25R2}=    HW_ID=ABIO    ONAIR_TIME=20 min    site_mode=4G

&{BTS_CLOUD_RF_CRT2_UTE4G152_AEHC_TMO_SBTS25R2}=    HW_ID=ABIP    ONAIR_TIME=20 min    site_mode=5G

#${INIT_CONFIG_ID}=     BTS_CLOUD_RF_CRT2_UTE4G152_AEHC_TMO_SBTS25R2

${GLO_TL_DESCRIPTOR_FILE_PATH}=    ${CURDIR}/TLdescriptor.xml

${TOP50}    True

${GLO_SCOUT_TESTLINE_NAME}    1_5_Cloud241


*** Test Cases ***
Test_Dedicated_downlink_3_8
    [Tags]    QC_146636    QCD_MN_RAN  QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=testmode_dl
    ...    config_id=BTS_CLOUD_RF_CRT2_UTE4G152_AEHC_TMO_SBTS25R2
    [Timeout]    72h
    Test_Dedicated_downlink
    [Teardown]    Testcase Basic Postcondition

Functional_Test_Dedicated_uplink
    [Tags]    QC_146633    QCD_MN_RAN  QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=testmode_ul
    ...    config_id=BTS_CLOUD_RF_CRT2_UTE4G152_AEHC_TMO_SBTS25R2
    [Timeout]    72h
    Test_Dedicated_uplink
    [Teardown]    Testcase Basic Postcondition

CONF_2_Common_SiSo_Call_Multicarrier Throughput Measurements when block one cell
    [Tags]    QC_146634    QCD_MN_RAN  QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=block
    ...    config_id=BTS_CLOUD_RF_CRT2_UTE4G152_AEHC_TMO_SBTS25R2
    [Timeout]    72h
    Common_SiSo_Call_Multicarrier Throughput Measurements when block one cell   L1202407675
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Exceptional_SWDL for factory load SW RRU
    [Tags]    QC_146635    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Factory
    ...    config_id=BTS_CLOUD_RF_CRT2_UTE4G152_AEHC_TMO_SBTS25R2
    [Timeout]    72h
    SWDL For Factory Load SW RRU    L1202407675
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Manual_SiSo_TEST_RF_Sniffing_RF_Scanning_(3G_4G_5G)_RxADC
    [Tags]    QC_146655    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=RF_scan_RXADC
    ...    config_id=BTS_CLOUD_RF_CRT2_UTE4G152_AEHC_TMO_SBTS25R2
    [Timeout]    72h
    Manual SiSo TEST RF Sniffing RF Scanning    NR TDD    RMOD-7 (AEHC)    Raw Composite Rx (RxADC)    PHYANT 1
    ...      PHYANT-1 Full Array      https://10.68.180.135    Nemuadmin    nemuuser
    [Teardown]    Testcase Basic Postcondition

[2][1.0] Manual_SiSo_TEST_RF_Sniffing_RF_Scanning_(3G_4G_5G)_FIR9
    [Tags]    QC_146656    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=RF_scan_FIR9
    ...    config_id=BTS_CLOUD_RF_CRT2_UTE4G152_AEHC_TMO_SBTS25R2
    [Timeout]    72h
    Manual SiSo TEST RF Sniffing RF Scanning    NR TDD    RMOD-7 (AEHC)    Carrier Rx (FIR9)    PHYANT 1
    ...      PHYANT-1 Full Array      https://10.68.180.135    Nemuadmin    nemuuser
    [Teardown]    Testcase Basic Postcondition

[3][1.0] Manual_SiSo_TEST_RF_Sniffing_RF_Scanning_(3G_4G_5G)_Tx_feedback
    [Tags]    QC_146657    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=RF_scan_Tx_feedback
    ...    config_id=BTS_CLOUD_RF_CRT2_UTE4G152_AEHC_TMO_SBTS25R2
    [Timeout]    72h
    Manual SiSo TEST RF Sniffing RF Scanning    NR TDD    RMOD-7 (AEHC)    Feedback Tx (PDRx)    PHYANT 1
    ...     PHYANT-1 Full Array      https://10.68.180.135    Nemuadmin    nemuuser
    [Teardown]    Testcase Basic Postcondition


*** Keywords ***

Manual SiSo TEST RF Sniffing RF Scanning
    [Arguments]    ${TECHNOLOGY_FOR_RF_SCAN}    ${RADIO_FOR_RF_SCAN}    ${CAPTURE_TYPE_FOR_RF_SCAN}
    ...     ${ANTENNA_FOR_RF_SCAN}      ${ANTENNA_PANEL}    ${WEBUI_URL}    ${WEBUI_NAME}    ${WEBUI_PWD}
    [Documentation]    Author:        deli.wang@nokia-sbell.com
    ...                Maintainer:    deli.wang@nokia-sbell.com
    sbts.enable_virtual_display
    sbts.login   ${WEBUI_URL}   ${WEBUI_NAME}   ${WEBUI_PWD}   version=SBTS25R1      browser=Chrome
    sbts.change_bts_rnd_parameters      69      Dynamic changes      [{"paramIndexNumber":39, "paramValue":1}]
    sbts.login   ${WEBUI_URL}   ${WEBUI_NAME}   ${WEBUI_PWD}   version=SBTS25R1      browser=Chrome
    ${NR_Cell_List}    Create List
    ${LTE_Cell_List}    Create List
    FOR    ${cell_info}    IN    @{ALL_CELL_LIST}
        ${is_need_to_operate}   Check Is Operation Cell    ${cell_info}
        Run Keyword If    ${is_need_to_operate} and "${cell_info["NetworkType"]}"=="SA"    Append To List
        ...      ${NR_Cell_List}    NRCELL-${cell_info['cellId']}
        ...     ELSE IF    ${is_need_to_operate} and "${cell_info["NetworkType"]}" == "4G"    Append To List
        ...     ${LTE_Cell_List}    LNCEL-${cell_info['cellId']}
    END
    set test variable    ${NR_CELL_LIST}    ${NR_Cell_List}
    set test variable    ${LTE_CELL_LIST}    ${LTE_Cell_List}
    FOR    ${LOCAL_CELL}     IN    @{NR_CELL_LIST}
        Exit For Loop If     '${TECHNOLOGY_FOR_RF_SCAN}'=='LTE TDD'
        Manual SiSo TEST RF Sniffing RF Scanning do capture      ${TECHNOLOGY_FOR_RF_SCAN}    ${RADIO_FOR_RF_SCAN}
        ...            ${CAPTURE_TYPE_FOR_RF_SCAN}    ${ANTENNA_FOR_RF_SCAN}
        ...            ${ANTENNA_PANEL}      ${LOCAL_CELL}
        Exit For Loop If     '${CAPTURE_TYPE_FOR_RF_SCAN}' != 'Carrier Rx (FIR9)'
    END
    FOR    ${LOCAL_CELL}     IN    @{LTE_Cell_List}
        Exit For Loop If     '${TECHNOLOGY_FOR_RF_SCAN}'=='NR TDD'
        Manual SiSo TEST RF Sniffing RF Scanning do capture      ${TECHNOLOGY_FOR_RF_SCAN}    ${RADIO_FOR_RF_SCAN}
        ...      ${CAPTURE_TYPE_FOR_RF_SCAN}    ${ANTENNA_FOR_RF_SCAN}
        ...            ${ANTENNA_PANEL}      ${LOCAL_CELL}
        Exit For Loop If     '${CAPTURE_TYPE_FOR_RF_SCAN}' != 'Carrier Rx (FIR9)'
    END
    sbts.logout
    sbts.disable_virtual_display

Manual SiSo TEST RF Sniffing RF Scanning do capture
    [Arguments]    ${TECHNOLOGY_FOR_RF_SCAN}    ${RADIO_FOR_RF_SCAN}    ${CAPTURE_TYPE_FOR_RF_SCAN}
    ...      ${ANTENNA_FOR_RF_SCAN}      ${ANTENNA_PANEL}      ${LOCAL_CELL}
	...      ${download_timeout}=${200}
    ${RF_SCAN_FILE_PATH}=    sbts.start_rf_scan   ${TECHNOLOGY_FOR_RF_SCAN}   ${RADIO_FOR_RF_SCAN}
	...    ${CAPTURE_TYPE_FOR_RF_SCAN}   ${ANTENNA_FOR_RF_SCAN}   ${ANTENNA_PANEL}    ${LOCAL_CELL}
	...    timeout=300
	Sleep   2min
    ${RF_SCAN_FILE_PATH}=    sbts.download_rf_scan_files   download_timeout=${download_timeout}
    ${size}=  OperatingSystem.get file size  ${RF_SCAN_FILE_PATH}
    should be true  ${size} > 100
	RUN    rm ${RF_SCAN_FILE_PATH}