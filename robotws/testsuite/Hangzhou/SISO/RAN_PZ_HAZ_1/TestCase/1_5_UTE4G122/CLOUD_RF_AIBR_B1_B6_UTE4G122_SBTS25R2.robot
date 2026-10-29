*** Settings ***
Documentation    Suite description
...    Author:        nick.1.wu@nokia-sbell.com
...    Maintainer:    Wu Nick

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot
Variables   ./env.py
Library   taf.selenium.sbts    WITH NAME    selenium_coam

Force Tags        CLOUD_RF_AILR_B1_B6_AAHD_AZQF_FRPA    CA_GVe    RAN_5G_TDD    RAN_5G    SBTS25R2
...    STATE_SW_UPLOADED

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

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
#${target_ru_info_abic_abia}    [{'serialNo':'6Q181710303',
#...    'breaklink':'3.6.6:3.6.2',  'linksec':'3.6.6:1.1.3'}]
${btsids}    [2396]
@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}    RX Power too low    Unstable eCPRI Link Detected
...    Auto-negotiation mismatch on SMOD-1, EIF3    LOS on SMOD-1, EIF3
${GLO_PERFORM_SAVE_LOG}    FAIL
${fr_serial_number}     6Q181710303
${timeout}    20s

*** Test Cases ***
[2][1.0] 1UE ULDL Peak rate
    [Tags]    QC_33239    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]   Testcase Basic Precondition    case_name=L3call    config_id=2AEHB_T3_AZQF_AZNB_T4_FXED_T6
    Make Tput   required_cells=${attachs_aehb}
    [Teardown]    Testcase Basic Postcondition

[2] SISO SFP transceiver temperrature too high on RRU
    [Tags]    QC_146637    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Fault_4698    config_id=2AEHB_T3_AZQF_AZNB_T4_FXED_T6
    RF Fault 4698 SFP transceiver temperrature too high    rf_sn=6Q181710305
    [Teardown]    Testcase Basic Postcondition

[1][2.0] Manual_SiSo_Antenna_Online_Monitoring
    [Tags]    QC_146664    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Monitoring    config_id=ET_AZQF_ABIC_ABIA
      Antenna Line Online Monitoring check with break
    [Teardown]    Testcase Basic Postcondition

[1][4.0] Manual_SiSo_TEST_LTE_NR_RF_Diagnostic_Test
    [Tags]    QC_14665    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Diagnostic    config_id=ET_AZQF_ABIC_ABIA
	Make L3Call    required_cells=${required_cells}
    RF Diagnostic Test Setup and start
	Check General Test Information
	Check Detailed Antenna
	Make L3Call    required_cells=${required_cells}
    [Teardown]    Testcase Basic Postcondition

*** Keywords ***
Antenna Line Online Monitoring check with break
     FOR    ${bts_id}    IN    @{ALL_BTS_ID_LIST}
         ${connection_id}    Set Variable   ${CASE_NAME}_${bts_id}
         ${antennas}    coam.get_antennas     connection=${connection_id}
         ${rmods}     Get Dictionary Keys      ${antennas}
         ${ANTL_R}     Get_Antl_List     ${rmods}     ${antennas}
         ${ANTL_R_List}     Remove Duplicates      ${ANTL_R}
         coam.start_antl_online_monitoring    target_dns=${ANTL_R_List}      connection=${connection_id}
         sleep     15s
         Make L3Call    required_cells=${required_cells}
         sleep     120s
         coam.stop_antl_online_monitoring    output_file_name=${TEST_LOGS_DIR_PATH}/AntOnlineMonitor.json
         ...    connection=${connection_id}
         modify_json.check_antenna_line_online_monitoring    ${TEST_LOGS_DIR_PATH}/AntOnlineMonitor.json     RTWP
         coam.start_antl_online_monitoring    target_dns=${ANTL_R_List}      connection=${connection_id}
         sleep     15s
         Radio Reset    ${fr_serial_number}
         Wait For All Cells OnAir    timeout=${timeout}
         Make L3Call    required_cells=${required_cells}
         coam.stop_antl_online_monitoring    output_file_name=${TEST_LOGS_DIR_PATH}/AntOnlineMonitor.json
         ...    connection=${connection_id}
     END

RF Diagnostic Test Setup and start
    [Arguments]    ${bts_thresholds}=${None}     ${bands_thresholds}=${None}
	Log To Console    \n *** ssh ***
    selenium_coam.enable_virtual_display
	selenium_coam.login   https://10.108.151.52    Nemuadmin    nemuuser   version=SBTS25R1      browser=Chrome
    Log To Console    \n *** RF Diagnostic Test Setup ***
    selenium_coam.configure_rf_diagnostic_test      cell=All LTE cells     bts_thresholds=${bts_thresholds}
    ...    bands_thresholds=${bands_thresholds}     technology=LTE
    selenium_coam.start_rf_diagnostic_test    timeout=100

Check General Test Information
    [Arguments]    ${cell_id}=1    ${forward_expected_result}=Pass    ${reverse_expected_result}=Pass
    ...    ${expected_outcome}=Pass    ${expected_low}=-2     ${expected_high}=120
    ${general_result}    selenium_coam.get_general_test_information    cell_id=${cell_id}
    FOR    ${item}    IN    @{general_result}
        ${start_time}    get from dictionary    ${item}    BTS test start time GMT +0800
        ${stop_time}    get from dictionary    ${item}    BTS test stop time GMT +0800
        ${start_time_value}    split string    ${start_time}    ${SPACE}
        ${stop_time_value}    split string    ${stop_time}    ${SPACE}
        ${time_differ}    robot.libraries.DateTime.subtract_time_from_time    ${stop_time_value}[-1]    ${start_time_value}[-1]
        should be true    ${time_differ} < ${30.0}
        ${forward_result}    get from dictionary    ${item}    Forward test disposition
        should be equal    ${forward_result}    ${forward_expected_result}
        ${reverse_result}    get from dictionary    ${item}    Reverse test disposition
        should be equal    ${reverse_result}    ${reverse_expected_result}
        ${outcome}    get from dictionary    ${item}    Outcome
        should be equal    ${outcome}    ${expected_outcome}
        ${result}    get from dictionary    ${item}   Result
        should be equal    ${result}    success
        ${value_forward_expected}   get from dictionary    ${item}   Forward expected transmit RF power
        should be true    ${expected_low} < ${value_forward_expected} < ${expected_high}
    END

Check Detailed Antenna
    [Arguments]    ${cell_id}=1    ${total_low}=-2     ${total_high}=120   ${error_low}=-8    ${error_high}=8
    ...    ${RSSI_low}=-180    ${RSSI_high}=-30    ${RTWP_low}=-180    ${RTWP_high}=-30    ${VSWR_high}=3
    ${detail_result}    selenium_coam.get_detailed_result_for_each_antenna    cell_id=${cell_id}
    FOR    ${item}    IN    @{detail_result}
        ${dict_forward_total}    get from dictionary    ${item}   Forward total transmit RF power
        ${value_forward_total}    get from dictionary    ${dict_forward_total}     dBm
        should be true    ${total_low} < ${value_forward_total} < ${total_high}
        ${value_forward_error}    get from dictionary    ${item}    Forward transmit RF power error (dB)
        should be true    ${error_low} < ${value_forward_error} < ${error_high}
        ${value_RSSI}    get from dictionary    ${item}    RSSI (dBm)
        should be true    ${RSSI_low} < ${value_RSSI} < ${RSSI_high}
        ${value_RTWP}    get from dictionary    ${item}    RTWP (dBm)
        should be true    ${RTWP_low} < ${value_RTWP} < ${RTWP_high}
        ${value_VSWR}    get from dictionary    ${item}    VSWR
        should be true    ${value_VSWR} < ${VSWR_high}
    END
    selenium_coam.logout
    selenium_coam.disable_virtual_display
