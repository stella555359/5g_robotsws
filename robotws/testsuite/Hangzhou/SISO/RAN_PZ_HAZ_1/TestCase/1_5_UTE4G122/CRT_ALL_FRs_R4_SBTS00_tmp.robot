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
${para1}    1.1.1:1.3.1;1.1.2:1.3.2;1.1.3:1.3.3;1.1.4:1.3.4;1.1.5:1.3.5;1.1.6:1.3.6;1.1.7:1.3.7;1.1.8:1.3.8;
${para2}    1.2.5:1.4.1;1.2.6:1.4.2;1.2.7:1.4.3;1.2.8:1.4.4;1.2.1:1.4.5;1.2.2:1.4.6;1.2.3:1.4.7;1.2.4:1.4.8
&{2AAHF_T3_AZQF_AZNB_T4_FXED_T6}    SM=L1182811442|L1190601917
...                      RF=1M194603257|1M194603256|6Q181710305|6Q181710303|1M173634014|L1162105358
...                      GG=${para1}${para2}
...                      HW_ID=2AAHF_T3_AZQF_AZNB_T4_FXED_T6    ONAIR_TIME=20 min     site_mode=4G
&{2AEHB_T3_AZQF_AZNB_T4_FXED_T6}    SM=L1182811442|L1190601917
...                      RF=L1211113059|L1213414030|6Q181710305|6Q181710303|1M173634014|L1162105358
...                      GG=2.1.1:2.7.1;2.1.2:2.7.2
...                      HW_ID=2AEHB_T3_AZQF_AZNB_T4_FXED_T6    ONAIR_TIME=20 min     site_mode=4G
&{ET_AZQF_ABIC_ABIA}    SM=L1182811442|L1190601917
...                      RF=6Q181710303
#...                      GG=3.6.1:3.6.5;3.6.2:3.6.6
...                      HW_ID=ET_AZQF_ABIC_ABIA    ONAIR_TIME=20 min     site_mode=4G

${KEY_PERFORM_HW_SETUP}    True
${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml
${INIT_CONFIG_ID}    2AEHB_T3_AZQF_AZNB_T4_FXED_T6

#${attachs_aehb}    133:135:138:140:1:4:5:142:145:130:131:132:141:146:147
${attachs_aehb}    140
${required_cells}    142
#${attachs_aahf}    133:134:135:137:138:140:142:143:144:130:132:141
${target_ru_info_abic_abia}    [{'serialNo':'6Q181710303',
...    'breaklink':'3.6.6:3.6.2',  'linksec':'3.6.6:1.1.3'}]
${btsids}    [2396]
@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}    RX Power too low    Unstable eCPRI Link Detected
...    Auto-negotiation mismatch on SMOD-1, EIF3    LOS on SMOD-1, EIF3
${GLO_PERFORM_SAVE_LOG}    FAIL
${fr_serial_number}     6Q181710303
${timeout}    20s



*** Test Cases ***

[1][1.0] Common_SiSo_State Management_RF Lock & Unlock_with_RF Reset
    [Tags]    QC_33206    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Ru_lock_and_RU_reset_then_RU_unlock
    ...    config_id=2AEHB_T3_AZQF_AZNB_T4_FXED_T6
    [Timeout]    72h
    Common_SiSo_State Management_RF Lock & Unlock_with_RF Reset
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Common_SiSo_State Management_RF Lock_Then_resetBBMOD_Then_RF unlock
    [Tags]    QC_33205   QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Ru_lock_and_RU_reset_with_resetBBMOD
    ...    config_id=2AEHB_T3_AZQF_AZNB_T4_FXED_T6
    [Timeout]    72h
    Common_SiSo_State Management_RF Lock_Then_resetBBMOD_Then_RF unlock
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Common_SiSo_State Management_Cell block_Then_resetBBMOD_Then_Cell unblock
    [Tags]    QC_33204   QCD_MN_RAN  QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Cell_block_Then_resetBBMOD_Then_Cell_unblock
    ...    config_id=2AEHB_T3_AZQF_AZNB_T4_FXED_T6
    [Timeout]     72h
    Cell Block And Unblock All with rfreset
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Common_SiSo_Recovery_RF module reset_Then_RAT_reset
    [Tags]    QC_33207   QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=RF_RAT_Reset
    ...    config_id=2AEHB_T3_AZQF_AZNB_T4_FXED_T6
    [Timeout]     72h
    Common_SiSo_Recovery_RF_module_reset_Then_RAT_reset
    [Teardown]    Testcase Basic Postcondition

Test_Dedicated_downlink_3_8
    [Tags]    QC_33210    QCD_MN_RAN  QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=testmode_dl
    ...    config_id=2AEHB_T3_AZQF_AZNB_T4_FXED_T6
    [Timeout]    72h
    Test_Dedicated_downlink
    [Teardown]    Testcase Basic Postcondition

Functional_Test_Dedicated_uplink
    [Tags]    QC_33211    QCD_MN_RAN  QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=testmode_ul
    ...    config_id=2AEHB_T3_AZQF_AZNB_T4_FXED_T6
    [Timeout]    72h
    Test_Dedicated_uplink
    [Teardown]    Testcase Basic Postcondition

CONF_2_Common_SiSo_Call_Multicarrier Throughput Measurements when block one cell
    [Tags]    QC_33208    QCD_MN_RAN  QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=block
    ...    config_id=2AEHB_T3_AZQF_AZNB_T4_FXED_T6
    [Timeout]    72h
    Common_SiSo_Call_Multicarrier Throughput Measurements when block one cell   L1202407675
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Exceptional_SWDL for factory load SW RRU
    [Tags]    QC_33209    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Factory
    ...    config_id=2AEHB_T3_AZQF_AZNB_T4_FXED_T6
    [Timeout]    72h
    SWDL For Factory Load SW RRU    L1202407675
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Manual_SiSo_TEST_RF_Sniffing_RF_Scanning_(3G_4G_5G)_RxADC
    [Tags]    QC_50319    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=RF_scan_RXADC
    ...    config_id=2AEHB_T3_AZQF_AZNB_T4_FXED_T6
    [Timeout]    72h
    Manual SiSo TEST RF Sniffing RF Scanning    LTE TDD    RMOD-2 (AEHC)    Raw Composite Rx (RxADC)    PHYANT 1
    ...     PHYANT-1 Full Array      https://10.108.151.52   Nemuadmin    nemuuser
    Manual SiSo TEST RF Sniffing RF Scanning    NR TDD    RMOD-2 (AEHC)    Raw Composite Rx (RxADC)    PHYANT 1
    ...      PHYANT-1 Full Array      https://10.108.151.52    Nemuadmin    nemuuser
    [Teardown]    Testcase Basic Postcondition

[2][1.0] Manual_SiSo_TEST_RF_Sniffing_RF_Scanning_(3G_4G_5G)_FIR9
    [Tags]    QC_50320    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=RF_scan_FIR9
    ...    config_id=2AEHB_T3_AZQF_AZNB_T4_FXED_T6
    [Timeout]    72h
    Manual SiSo TEST RF Sniffing RF Scanning    LTE TDD    RMOD-2 (AEHC)    Carrier Rx (FIR9)    PHYANT 1
    ...      PHYANT-1 Full Array     https://10.108.151.52    Nemuadmin    nemuuser
    Manual SiSo TEST RF Sniffing RF Scanning    NR TDD    RMOD-2 (AEHC)    Carrier Rx (FIR9)    PHYANT 1
    ...      PHYANT-1 Full Array      https://10.108.151.52   Nemuadmin    nemuuser
    [Teardown]    Testcase Basic Postcondition

[3][1.0] Manual_SiSo_TEST_RF_Sniffing_RF_Scanning_(3G_4G_5G)_Tx_feedback
    [Tags]    QC_50321    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=RF_scan_Tx_feedback
    ...    config_id=2AEHB_T3_AZQF_AZNB_T4_FXED_T6
    [Timeout]    72h
	Manual SiSo TEST RF Sniffing RF Scanning    LTE TDD    RMOD-2 (AEHC)    Feedback Tx (PDRx)    PHYANT 1
	...      PHYANT-1 Full Array      https://10.108.151.52    Nemuadmin    nemuuser
    Manual SiSo TEST RF Sniffing RF Scanning    NR TDD    RMOD-2 (AEHC)    Feedback Tx (PDRx)    PHYANT 1
    ...     PHYANT-1 Full Array      https://10.108.151.52    Nemuadmin    nemuuser
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
