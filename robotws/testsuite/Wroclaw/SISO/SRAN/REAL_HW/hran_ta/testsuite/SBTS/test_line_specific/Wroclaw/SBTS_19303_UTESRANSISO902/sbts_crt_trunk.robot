*** Settings ***
Documentation
...  Test Suite Author: Mateusz Kawka

#Force Tags        QCD_MN_SRAN    QCP_SRAN_SBTS    CRT    	CLOUD_SRAN_NLWG_1ASIL_1ABIA_1ABIO_1ASIL_2ABIA_1AHEB_2FXEE_1FXJB_DEV    SBTS00
#Resource          ../../../test_resources/BS-RF/BS-RF__EGPRS_throughputs_via_every_TRX__RP001637__Automated.robot
#Resource          ../../../test_resources/BS-RF/BS-RF__Embedded_Power_Meter_EEM_act_deact_in_WebEM__RP000951__Automated.robot
#Resource          ../../../test_resources/BS-RF/BS-RF__Embedded_Power_Meter_EEM_real_time_counters_during_RF_lock_unlock__RP000951__Automated.robot
#Resource          ../../../test_resources/BS-RF/BS-RF__Enter_Exit_to_Test_Dedicated_State_via_Commissioning__RP001548__Automated.robot
#Resource          ../../../test_resources/BS-RF/BS-RF__Enter_to_Test_Dedicated_State_via_WebEm__RP001548__Automated.robot
#Resource          ../../../test_resources/BS-RF/BS-RF__Exit_from_Test_Dedicated_State_via_WebEm__RP001548__Automated.robot
#Resource          ../../../test_resources/BS-RF/BS-RF__GSM_voice_call_via_every_TRX__RP001637__Automated.robot
#Resource          ../../../test_resources/BS-RF/BS-RF__HSPA_throughputs__RP001637__Automated.robot
#Resource          ../../../test_resources/BS-RF/BS-RF__LTE1530_Activation_Reconfiguration_in_WebEM_9.4MHz__CNI-18553__Automated.robot
#Resource
#...  ../../../test_resources/BS-RF/BS-RF__LTE1530_Alarm_Handling_4393_EFaultId_ReducedLteGuardBandConfNotMatchingFrHwAl__CNI-18553__Automated.robot
#Resource          ../../../test_resources/BS-RF/BS-RF__LTE_throughputs_10MHz__RP001637__Automated.robot
#Resource          ../../../test_resources/BS-RF/BS-RF__LTE_throughputs_5MHz__RP001637__Automated.robot
#Resource          ../../../test_resources/BS-RF/BS-RF__Long_Fibers_without_calls_200m__RP001637__Automated.robot
#Resource          ../../../test_resources/BS-RF/BS-RF__Physical_Layer_Measurement_Basic_RTT_Functionality_WCDMA__RP001637__Automated.robot
#Resource          ../../../test_resources/BS-RF/BS-RF__SBTS_GSM_Antenna_hopping__RP001637__Automated.robot
#Resource          ../../../test_resources/BS-RF/BS-RF__SBTS_GSM_BB_hopping__RP001637__Automated.robot
#Resource          ../../../test_resources/BS-RF/BS-RF__SBTS_GSM_RF_hopping__RP001637__Automated.robot
#Resource          ../../../test_resources/BS-RF/BS-RF__Start_Stop_LTE_Downlink_TestModels_E-TM1.1__RP001548__Automated.robot
#Resource          ../../../test_resources/BS-RF/BS-RF__Start_Stop_LTE_Uplink_TestModels_A1-2__RP001548__Automated.robot
#Resource          ../../../test_resources/BS-RF/BS-RF__Start_Stop_Simultaneously_NR_LTE_WCDMA_Test_Models__RP001548__Automated.robot
#Resource          ../../../test_resources/BS-RF/BS-RF__Start_Stop_WCDMA_BER_BLER_measurement__RP001548__Automated.robot
#Resource          ../../../test_resources/BS-RF/BS-RF__Start_Stop_WCDMA_Downlink_TestModels_TM_1__RP001548__Automated.robot
#Resource          ../../../test_resources/BS-RF/BS-RF__WCDMA_RF_RX_Level_Faults_133__RP001637__Automated.robot
#Resource          ../../../test_resources/BS-RF/DEV__Check_UE_Cell_Attach_IP_Address_And_Optional_Reattach.robot

#*** Variables ***
#${COMMISSIONING_PATH}    SEPARATOR=  /Home/ute/robotlte/testsuite/hran_ta/testsuite/SBTS/
#...  test_line_specific/Wroclaw/SBTS_19303_UTESRANSISO902/commissioning/TRUNK.xml
#${ABSTRACT_LIB_CONFIG}    SEPARATOR=  /home/ute/robotlte/testsuite/hran_ta/testsuite/SBTS/
#...  test_line_specific/Wroclaw/SBTS_19303_UTESRANSISO902/device/ue_config.yaml
#${HW_LOCATION_CODE}      Wroclaw
#${COLLECT_SNAPSHOT_FLAG}  Never

#*** Test Cases ***

#[1]DEV__Check_UE_Cell_Attach_IP_Address_And_Optional_Reattach
#    [Setup]    Run Keywords    Set Test Variable    ${CLEAR_TA_UE_LOGS}    True
#    ...    AND    Set Test Variable    ${CLEAR_TA_UE_PLUGIN}    True
#    ...    AND    Set Test Variable    ${CHECK_SW}    False
#    ...    AND    Set Test Variable    ${USER_DATA}    4941569=8d2161d3,4941572=b2f8b881,10965=ae09b8ab,24101=95794ec0
#    ...    AND    Set Test Variable    ${UE_SN}    95794ec0,ae09b8ab,8d2161d3,b2f8b881
#    ...    AND    Set Test Variable    ${RAT}    WCDMA,GSM,LTE,LTE
#    ...    AND    Set Test Variable    ${BAND}    900,1800,B3,B8
#    ...    AND    Set Test Variable    ${EARFCN}    3025,822,1370,3600
#    ...    AND    Set Test Variable    ${PSC/PCI}    1,,92,95
#    ...    AND    Set Test Variable    ${APN}        AP4,AP4,AP4,AP4
#    ...    AND 	  Import Variables    ${ABSTRACT_LIB_CONFIG}
#    ...    AND    DEV__Check_UE_Cell_Attach_IP_Address_And_Optional_Reattach.TC Setup
#    ...    AND    Set Library Search Order    DEV__Check_UE_Cell_Attach_IP_Address_And_Optional_Reattach
#    [Timeout]    14400
#    TC__DEV__Check_UE_Cell_Attach_IP_Address_And_Optional_Reattach
#    [Teardown]    DEV__Check_UE_Cell_Attach_IP_Address_And_Optional_Reattach.TC Teardown
#
#
#
#[1]BS-RF__Long_Fibers_without_calls_200m__RP001637__Automated
#    [Setup]    Run Keywords    Set Test Variable    ${user_data}    L9150900121=200;L1153711225=2;L1160506706=2
#    ...    AND    Set Test Variable    ${RADIO_TYPE}    FXJB
#    ...    AND    BS-RF__Long_Fibers_without_calls_200m__RP001637__Automated.TC Setup
#    ...    AND    Set Library Search Order    BS-RF__Long_Fibers_without_calls_200m__RP001637__Automated
#    [Timeout]    14400
#    TC__BS-RF__Long_Fibers_without_calls_200m__RP001637__Automated
#    [Teardown]    BS-RF__Long_Fibers_without_calls_200m__RP001637__Automated.TC Teardown
#
#
#[1]BS-RF__LTE_throughputs_5MHz__RP001637__Automated
#    [Setup]    Run Keywords    Set Test Variable    ${USER_DATA}    4941572=b2f8b881
#	...    AND 	  Import Variables    ${ABSTRACT_LIB_CONFIG}
#    ...    AND    Set Test Variable    ${DURATION}    20s
#    ...    AND    Set Test Variable    ${PROTOCOL}    udp
#    ...    AND    Set Test Variable    ${BANDWIDTH}    33Mbits/sec
#    ...    AND    Set Test Variable    ${DL_MAX}    71Mbits/sec
#    ...    AND    Set Test Variable    ${DL_MIN}    26Mbits/sec
#    ...    AND    Set Test Variable    ${UL_MAX}    11Mbits/sec
#    ...    AND    Set Test Variable    ${UL_MIN}    8Mbits/sec
#    ...    AND    Set Test Variable    ${FTP_LABEL}    FTP_1
#    ...    AND    Set Test Variable    ${TEST_TIMEOUT}    40
#    ...    AND    BS-RF__LTE_throughputs_5MHz__RP001637__Automated.TC Setup
#    ...    AND    Set Library Search Order    BS-RF__LTE_throughputs_5MHz__RP001637__Automated
#    [Timeout]    ${TEST_TIMEOUT}min
#    TC__BS-RF__LTE_throughputs_5MHz__RP001637__Automated
#    [Teardown]    BS-RF__LTE_throughputs_5MHz__RP001637__Automated.TC Teardown
#
#
#[1]BS-RF__HSPA_throughputs__RP001637__Automated
#    [Setup]    Run Keywords    Set Test Variable    ${USER_DATA}    24101=95794ec0
#    ...    AND 	  Import Variables    ${ABSTRACT_LIB_CONFIG}
#    ...    AND    Set Test Variable    ${DURATION}    15s
#    ...    AND    Set Test Variable    ${PROTOCOL}    udp
#    ...    AND    Set Test Variable    ${BANDWIDTH}    22Mbits/sec
#    ...    AND    Set Test Variable    ${DL_MAX}    21Mbits/sec
#    ...    AND    Set Test Variable    ${DL_MIN}    15Mbits/sec
#    ...    AND    Set Test Variable    ${UL_MAX}    8.4Mbits/sec
#    ...    AND    Set Test Variable    ${UL_MIN}    2.7Mbits/sec
#    ...    AND    Set Test Variable    ${FTP_LABEL}    FTP_1
#    ...    AND    Set Test Variable    ${TEST_TIMEOUT}    30
#    ...    AND    BS-RF__HSPA_throughputs__RP001637__Automated.TC Setup
#    ...    AND    Set Library Search Order    BS-RF__HSPA_throughputs__RP001637__Automated
#    [Timeout]    ${TEST_TIMEOUT}min
#    TC__BS-RF__HSPA_throughputs__RP001637__Automated
#    [Teardown]    BS-RF__HSPA_throughputs__RP001637__Automated.TC Teardown
#
#
#[1]BS-RF__Physical_Layer_Measurement_Basic_RTT_Functionality_WCDMA__RP001637__Automated
#    [Setup]    Run Keywords    Set Test Variable    ${CELL_ID}    24101
#    ...    AND 	  Import Variables    ${ABSTRACT_LIB_CONFIG}
#    ...    AND    Set Test Variable    ${UE_SN}    95794ec0
#    ...    AND    Set Test Variable    ${NUMBER}    0666002
#    ...    AND    BS-RF__Physical_Layer_Measurement_Basic_RTT_Functionality_WCDMA__RP001637__Automated.TC Setup
#    ...    AND    Set Library Search Order    BS-RF__Physical_Layer_Measurement_Basic_RTT_Functionality_WCDMA__RP001637__Automated
#    [Timeout]    14400
#    TC__BS-RF__Physical_Layer_Measurement_Basic_RTT_Functionality_WCDMA__RP001637__Automated
#    [Teardown]    BS-RF__Physical_Layer_Measurement_Basic_RTT_Functionality_WCDMA__RP001637__Automated.TC Teardown
#
#
#[1]BS-RF__WCDMA_Configurable_Carrier_Bandwidth_[DL=4.4_UL=3.8]__RP001637__Automated
#    [Setup]    Run Keywords    Set Test Variable    ${USER_DATA}    24101=95794ec0
#    ...    AND 	  Import Variables    ${ABSTRACT_LIB_CONFIG}
#    ...    AND    Set Test Variable    ${PS_DURATION}    15s
#    ...    AND    Set Test Variable    ${PROTOCOL}    udp
#    ...    AND    Set Test Variable    ${BANDWIDTH}    22Mbits/sec
#    ...    AND    Set Test Variable    ${DL_MAX}    21Mbits/sec
#    ...    AND    Set Test Variable    ${DL_MIN}    12Mbits/sec
#    ...    AND    Set Test Variable    ${UL_MAX}    8.4Mbits/sec
#    ...    AND    Set Test Variable    ${UL_MIN}    2.6Mbits/sec
#    ...    AND    Set Test Variable    ${FTP_LABEL}    FTP_1
#    ...    AND    Set Test Variable    ${NUMBER}    0666002
#    ...    AND    Set Test Variable    ${VOICE_CALL_DURATION}    15s
#    ...    AND    Set Test Variable    ${DURATION}    15s
#    ...    AND    BS-RF__WCDMA_Configurable_Carrier_Bandwidth_[DL=4.4_UL=3.8]__RP001637__Automated.TC Setup
#    ...    AND    Set Library Search Order    BS-RF__WCDMA_Configurable_Carrier_Bandwidth_[DL=4.4_UL=3.8]__RP001637__Automated
#    [Timeout]    14400
#    TC__BS-RF__WCDMA_Configurable_Carrier_Bandwidth_[DL=4.4_UL=3.8]__RP001637__Automated
#    [Teardown]    BS-RF__WCDMA_Configurable_Carrier_Bandwidth_[DL=4.4_UL=3.8]__RP001637__Automated.TC Teardown
#
#
#[1]BS-RF__WCDMA_Configurable_Carrier_Bandwidth_[DL=4.4_UL=4.2]__RP001637__Automated
#    [Setup]    Run Keywords    Set Test Variable    ${USER_DATA}    24101=95794ec0
#    ...    AND 	  Import Variables    ${ABSTRACT_LIB_CONFIG}
#    ...    AND    Set Test Variable    ${PS_DURATION}    15s
#    ...    AND    Set Test Variable    ${PROTOCOL}    udp
#    ...    AND    Set Test Variable    ${BANDWIDTH}    22Mbits/sec
#    ...    AND    Set Test Variable    ${DL_MAX}    21Mbits/sec
#    ...    AND    Set Test Variable    ${DL_MIN}    12Mbits/sec
#    ...    AND    Set Test Variable    ${UL_MAX}    8.4Mbits/sec
#    ...    AND    Set Test Variable    ${UL_MIN}    2.6Mbits/sec
#    ...    AND    Set Test Variable    ${FTP_LABEL}    FTP_1
#    ...    AND    Set Test Variable    ${NUMBER}    0666002
#    ...    AND    Set Test Variable    ${VOICE_CALL_DURATION}    15s
#    ...    AND    Set Test Variable    ${DURATION}    15s
#    ...    AND    BS-RF__WCDMA_Configurable_Carrier_Bandwidth_[DL=4.4_UL=4.2]__RP001637__Automated.TC Setup
#    ...    AND    Set Library Search Order    BS-RF__WCDMA_Configurable_Carrier_Bandwidth_[DL=4.4_UL=4.2]__RP001637__Automated
#    [Timeout]    14400
#    TC__BS-RF__WCDMA_Configurable_Carrier_Bandwidth_[DL=4.4_UL=4.2]__RP001637__Automated
#    [Teardown]    BS-RF__WCDMA_Configurable_Carrier_Bandwidth_[DL=4.4_UL=4.2]__RP001637__Automated.TC Teardown
#
#
#[1]BS-RF__WCDMA_Configurable_Carrier_Bandwidth_[DL=4.6_UL=4.0]__RP001637__Automated
#    [Setup]    Run Keywords    Set Test Variable    ${USER_DATA}    24101=95794ec0
#    ...    AND 	  Import Variables    ${ABSTRACT_LIB_CONFIG}
#    ...    AND    Set Test Variable    ${PS_DURATION}    15s
#    ...    AND    Set Test Variable    ${PROTOCOL}    udp
#    ...    AND    Set Test Variable    ${BANDWIDTH}    22Mbits/sec
#    ...    AND    Set Test Variable    ${DL_MAX}    21Mbits/sec
#    ...    AND    Set Test Variable    ${DL_MIN}    14Mbits/sec
#    ...    AND    Set Test Variable    ${UL_MAX}    8.4Mbits/sec
#    ...    AND    Set Test Variable    ${UL_MIN}    2.6Mbits/sec
#    ...    AND    Set Test Variable    ${FTP_LABEL}    FTP_1
#    ...    AND    Set Test Variable    ${NUMBER}    0666002
#    ...    AND    Set Test Variable    ${VOICE_CALL_DURATION}    15s
#    ...    AND    Set Test Variable    ${DURATION}    15s
#    ...    AND    BS-RF__WCDMA_Configurable_Carrier_Bandwidth_[DL=4.6_UL=4.0]__RP001637__Automated.TC Setup
#    ...    AND    Set Library Search Order    BS-RF__WCDMA_Configurable_Carrier_Bandwidth_[DL=4.6_UL=4.0]__RP001637__Automated
#    [Timeout]    14400
#    TC__BS-RF__WCDMA_Configurable_Carrier_Bandwidth_[DL=4.6_UL=4.0]__RP001637__Automated
#    [Teardown]    BS-RF__WCDMA_Configurable_Carrier_Bandwidth_[DL=4.6_UL=4.0]__RP001637__Automated.TC Teardown
#
#
#[1]BS-RF__WCDMA_Configurable_Carrier_Bandwidth_[DL=4.8_UL=3.8]__RP001637__Automated
#    [Setup]    Run Keywords    Set Test Variable    ${USER_DATA}    24101=95794ec0
#    ...    AND 	  Import Variables    ${ABSTRACT_LIB_CONFIG}
#    ...    AND    Set Test Variable    ${PS_DURATION}    15s
#    ...    AND    Set Test Variable    ${PROTOCOL}    udp
#    ...    AND    Set Test Variable    ${BANDWIDTH}    22Mbits/sec
#    ...    AND    Set Test Variable    ${DL_MAX}    21Mbits/sec
#    ...    AND    Set Test Variable    ${DL_MIN}    16Mbits/sec
#    ...    AND    Set Test Variable    ${UL_MAX}    8.4Mbits/sec
#    ...    AND    Set Test Variable    ${UL_MIN}    2.6Mbits/sec
#    ...    AND    Set Test Variable    ${FTP_LABEL}    FTP_1
#    ...    AND    Set Test Variable    ${NUMBER}    0666002
#    ...    AND    Set Test Variable    ${VOICE_CALL_DURATION}    15s
#    ...    AND    Set Test Variable    ${DURATION}    15s
#    ...    AND    BS-RF__WCDMA_Configurable_Carrier_Bandwidth_[DL=4.8_UL=3.8]__RP001637__Automated.TC Setup
#    ...    AND    Set Library Search Order    BS-RF__WCDMA_Configurable_Carrier_Bandwidth_[DL=4.8_UL=3.8]__RP001637__Automated
#    [Timeout]    14400
#    TC__BS-RF__WCDMA_Configurable_Carrier_Bandwidth_[DL=4.8_UL=3.8]__RP001637__Automated
#    [Teardown]    BS-RF__WCDMA_Configurable_Carrier_Bandwidth_[DL=4.8_UL=3.8]__RP001637__Automated.TC Teardown
#
#
#[1]BS-RF__WCDMA_Configurable_Carrier_Bandwidth_[DL=3.8_UL=3.8]__CNI-23159__Automated
#    [Setup]    Run Keywords    Set Test Variable    ${USER_DATA}    24101=95794ec0
#    ...    AND 	  Import Variables    ${ABSTRACT_LIB_CONFIG}
#    ...    AND    Set Test Variable    ${PS_DURATION}    15s
#    ...    AND    Set Test Variable    ${PROTOCOL}    udp
#    ...    AND    Set Test Variable    ${BANDWIDTH}    22Mbits/sec
#    ...    AND    Set Test Variable    ${DL_MAX}    21Mbits/sec
#    ...    AND    Set Test Variable    ${DL_MIN}    9Mbits/sec
#    ...    AND    Set Test Variable    ${UL_MAX}    6Mbits/sec
#    ...    AND    Set Test Variable    ${UL_MIN}    2.6Mbits/sec
#    ...    AND    Set Test Variable    ${FTP_LABEL}    FTP_1
#    ...    AND    Set Test Variable    ${NUMBER}    0666002
#    ...    AND    Set Test Variable    ${VOICE_CALL_DURATION}    15s
#    ...    AND    BS-RF__WCDMA_Configurable_Carrier_Bandwidth_[DL=3.8_UL=3.8]__CNI-23159__Automated.TC Setup
#    ...    AND    Set Library Search Order    BS-RF__WCDMA_Configurable_Carrier_Bandwidth_[DL=3.8_UL=3.8]__CNI-23159__Automated
#    [Timeout]    14400
#    TC__BS-RF__WCDMA_Configurable_Carrier_Bandwidth_[DL=3.8_UL=3.8]__CNI-23159__Automated
#    [Teardown]    BS-RF__WCDMA_Configurable_Carrier_Bandwidth_[DL=3.8_UL=3.8]__CNI-23159__Automated.TC Teardown
#
#
#[1]BS-RF__WCDMA_Configurable_Carrier_Bandwidth_[DL=4.2_UL=4.2]__RP002443__Automated
#    [Setup]    Run Keywords    Set Test Variable    ${USER_DATA}    24101=95794ec0
#    ...    AND 	  Import Variables    ${ABSTRACT_LIB_CONFIG}
#    ...    AND    Set Test Variable    ${PS_DURATION}    15s
#    ...    AND    Set Test Variable    ${PROTOCOL}    udp
#    ...    AND    Set Test Variable    ${BANDWIDTH}    22Mbits/sec
#    ...    AND    Set Test Variable    ${DL_MAX}    21Mbits/sec
#    ...    AND    Set Test Variable    ${DL_MIN}    12Mbits/sec
#    ...    AND    Set Test Variable    ${UL_MAX}    6Mbits/sec
#    ...    AND    Set Test Variable    ${UL_MIN}    2.6Mbits/sec
#    ...    AND    Set Test Variable    ${FTP_LABEL}    FTP_1
#    ...    AND    Set Test Variable    ${NUMBER}    0666002
#    ...    AND    Set Test Variable    ${VOICE_CALL_DURATION}    15s
#    ...    AND    BS-RF__WCDMA_Configurable_Carrier_Bandwidth_[DL=4.2_UL=4.2]__RP002443__Automated.TC Setup
#    ...    AND    Set Library Search Order    BS-RF__WCDMA_Configurable_Carrier_Bandwidth_[DL=4.2_UL=4.2]__RP002443__Automated
#    [Timeout]    14400
#    TC__BS-RF__WCDMA_Configurable_Carrier_Bandwidth_[DL=4.2_UL=4.2]__RP002443__Automated
#    [Teardown]    BS-RF__WCDMA_Configurable_Carrier_Bandwidth_[DL=4.2_UL=4.2]__RP002443__Automated.TC Teardown
#
#
#[1]BS-RF__WCDMA_Configurable_Carrier_Bandwidth_[DL=4.0_UL=4.0]__RP002443__Automated
#    [Setup]    Run Keywords    Set Test Variable    ${USER_DATA}    24101=95794ec0
#    ...    AND 	  Import Variables    ${ABSTRACT_LIB_CONFIG}
#    ...    AND    Set Test Variable    ${PS_DURATION}    15s
#    ...    AND    Set Test Variable    ${PROTOCOL}    udp
#    ...    AND    Set Test Variable    ${BANDWIDTH}    22Mbits/sec
#    ...    AND    Set Test Variable    ${DL_MAX}    21Mbits/sec
#    ...    AND    Set Test Variable    ${DL_MIN}    10Mbits/sec
#    ...    AND    Set Test Variable    ${UL_MAX}    6Mbits/sec
#    ...    AND    Set Test Variable    ${UL_MIN}    2.6Mbits/sec
#    ...    AND    Set Test Variable    ${FTP_LABEL}    FTP_1
#    ...    AND    Set Test Variable    ${NUMBER}    0666002
#    ...    AND    Set Test Variable    ${VOICE_CALL_DURATION}    15s
#    ...    AND    BS-RF__WCDMA_Configurable_Carrier_Bandwidth_[DL=4.0_UL=4.0]__RP002443__Automated.TC Setup
#    ...    AND    Set Library Search Order    BS-RF__WCDMA_Configurable_Carrier_Bandwidth_[DL=4.0_UL=4.0]__RP002443__Automated
#    [Timeout]    14400
#    TC__BS-RF__WCDMA_Configurable_Carrier_Bandwidth_[DL=4.0_UL=4.0]__RP002443__Automated
#    [Teardown]    BS-RF__WCDMA_Configurable_Carrier_Bandwidth_[DL=4.0_UL=4.0]__RP002443__Automated.TC Teardown
#
#
#[1]BS-RF__Enter_to_Test_Dedicated_State_via_WebEm__RP001548__Automated
#    [Setup]    Run Keywords    BS-RF__Enter_to_Test_Dedicated_State_via_WebEm__RP001548__Automated.TC Setup
#    ...    AND    Set Library Search Order    BS-RF__Enter_to_Test_Dedicated_State_via_WebEm__RP001548__Automated
#    [Timeout]    14400
#    TC__BS-RF__Enter_to_Test_Dedicated_State_via_WebEm__RP001548__Automated
#    [Teardown]    BS-RF__Enter_to_Test_Dedicated_State_via_WebEm__RP001548__Automated.TC Teardown
#
#
#[1]BS-RF__Start_Stop_LTE_Downlink_TestModels_E-TM1.1__RP001548__Automated
#    [Setup]    Run Keywords    Set Test Variable    ${USER_LTE_CELL}    12264
#    ...    AND    Set Test Variable    ${USER_PHY_CELL_ID}
#    ...    AND    BS-RF__Start_Stop_LTE_Downlink_TestModels_E-TM1.1__RP001548__Automated.TC Setup
#    ...    AND    Set Library Search Order    BS-RF__Start_Stop_LTE_Downlink_TestModels_E-TM1.1__RP001548__Automated
#    [Timeout]    14400
#    TC__BS-RF__Start_Stop_LTE_Downlink_TestModels_E-TM1.1__RP001548__Automated
#    [Teardown]    BS-RF__Start_Stop_LTE_Downlink_TestModels_E-TM1.1__RP001548__Automated.TC Teardown
#
#
#[1]BS-RF__Start_Stop_LTE_Downlink_TestModels_E-TM2a__RP001548__Automated
#    [Setup]    Run Keywords    Set Test Variable    ${USER_LTE_CELL}    12264
#    ...    AND    Set Test Variable    ${USER_PHY_CELL_ID}    1,4
#    ...    AND    BS-RF__Start_Stop_LTE_Downlink_TestModels_E-TM2a__RP001548__Automated.TC Setup
#    ...    AND    Set Library Search Order    BS-RF__Start_Stop_LTE_Downlink_TestModels_E-TM2a__RP001548__Automated
#    [Timeout]    14400
#    TC__BS-RF__Start_Stop_LTE_Downlink_TestModels_E-TM2a__RP001548__Automated
#    [Teardown]    BS-RF__Start_Stop_LTE_Downlink_TestModels_E-TM2a__RP001548__Automated.TC Teardown
#
#
#[1]BS-RF__Start_Stop_LTE_Downlink_TestModels_E-TM3.3__RP001548__Automated
#    [Setup]    Run Keywords    Set Test Variable    ${USER_LTE_CELL}    12264
#    ...    AND    Set Test Variable    ${USER_PHY_CELL_ID}    222,503
#    ...    AND    BS-RF__Start_Stop_LTE_Downlink_TestModels_E-TM3.3__RP001548__Automated.TC Setup
#    ...    AND    Set Library Search Order    BS-RF__Start_Stop_LTE_Downlink_TestModels_E-TM3.3__RP001548__Automated
#    [Timeout]    14400
#    TC__BS-RF__Start_Stop_LTE_Downlink_TestModels_E-TM3.3__RP001548__Automated
#    [Teardown]    BS-RF__Start_Stop_LTE_Downlink_TestModels_E-TM3.3__RP001548__Automated.TC Teardown
#
#
#[1]BS-RF__Start_Stop_LTE_Uplink_TestModels_A1-2__RP001548__Automated
#    [Tags]    STOPONFAIL
#    [Setup]    Run Keywords    Set Test Variable    ${USER_LTE_CELL}    12264
#    ...    AND    Set Test Variable    ${USER_RB_OFFSET}
#    ...    AND    BS-RF__Start_Stop_LTE_Uplink_TestModels_A1-2__RP001548__Automated.TC Setup
#    ...    AND    Set Library Search Order    BS-RF__Start_Stop_LTE_Uplink_TestModels_A1-2__RP001548__Automated
#    [Timeout]    14400
#    TC__BS-RF__Start_Stop_LTE_Uplink_TestModels_A1-2__RP001548__Automated
#    [Teardown]    BS-RF__Start_Stop_LTE_Uplink_TestModels_A1-2__RP001548__Automated.TC Teardown
#
#
#[1]BS-RF__Start_Stop_LTE_Uplink_TestModels_A1-3__RP001548__Automated
#    [Setup]    Run Keywords    Set Test Variable    ${USER_LTE_CELL}    12264
#    ...    AND    BS-RF__Start_Stop_LTE_Uplink_TestModels_A1-3__RP001548__Automated.TC Setup
#    ...    AND    Set Library Search Order    BS-RF__Start_Stop_LTE_Uplink_TestModels_A1-3__RP001548__Automated
#    [Timeout]    14400
#    TC__BS-RF__Start_Stop_LTE_Uplink_TestModels_A1-3__RP001548__Automated
#    [Teardown]    BS-RF__Start_Stop_LTE_Uplink_TestModels_A1-3__RP001548__Automated.TC Teardown
#
#
#[1]BS-RF__Start_Stop_LTE_Uplink_TestModels_A2-3__RP001548__Automated
#    [Setup]    Run Keywords    Set Test Variable    ${USER_LTE_CELL}    12264
#    ...    AND    BS-RF__Start_Stop_LTE_Uplink_TestModels_A2-3__RP001548__Automated.TC Setup
#    ...    AND    Set Library Search Order    BS-RF__Start_Stop_LTE_Uplink_TestModels_A2-3__RP001548__Automated
#    [Timeout]    14400
#    TC__BS-RF__Start_Stop_LTE_Uplink_TestModels_A2-3__RP001548__Automated
#    [Teardown]    BS-RF__Start_Stop_LTE_Uplink_TestModels_A2-3__RP001548__Automated.TC Teardown
#
#
#[1]BS-RF__Start_Stop_WCDMA_Downlink_TestModels_TM_1__RP001548__Automated
#    [Setup]    Run Keywords    Set Test Variable    ${USER_WCDMA_CELL}    24101,24102
#    ...    AND    Set Test Variable    ${USER_PRIMARY_SCR_CODE}
#    ...    AND    BS-RF__Start_Stop_WCDMA_Downlink_TestModels_TM_1__RP001548__Automated.TC Setup
#    ...    AND    Set Library Search Order    BS-RF__Start_Stop_WCDMA_Downlink_TestModels_TM_1__RP001548__Automated
#    [Timeout]    14400
#    TC__BS-RF__Start_Stop_WCDMA_Downlink_TestModels_TM_1__RP001548__Automated
#    [Teardown]    BS-RF__Start_Stop_WCDMA_Downlink_TestModels_TM_1__RP001548__Automated.TC Teardown
#
#
#[1]BS-RF__Start_Stop_WCDMA_Downlink_TestModels_TM_2__RP001548__Automated
#    [Setup]    Run Keywords    Set Test Variable    ${USER_WCDMA_CELL}    24101,24102
#    ...    AND    Set Test Variable    ${USER_PRIMARY_SCR_CODE}    0,1
#    ...    AND    BS-RF__Start_Stop_WCDMA_Downlink_TestModels_TM_2__RP001548__Automated.TC Setup
#    ...    AND    Set Library Search Order    BS-RF__Start_Stop_WCDMA_Downlink_TestModels_TM_2__RP001548__Automated
#    [Timeout]    14400
#    TC__BS-RF__Start_Stop_WCDMA_Downlink_TestModels_TM_2__RP001548__Automated
#    [Teardown]    BS-RF__Start_Stop_WCDMA_Downlink_TestModels_TM_2__RP001548__Automated.TC Teardown
#
#
#[1]BS-RF__Start_Stop_WCDMA_Downlink_TestModels_TM_3__RP001548__Automated
#    [Setup]    Run Keywords    Set Test Variable    ${USER_WCDMA_CELL}    24101,24102
#    ...    AND    Set Test Variable    ${USER_PRIMARY_SCR_CODE}
#    ...    AND    BS-RF__Start_Stop_WCDMA_Downlink_TestModels_TM_3__RP001548__Automated.TC Setup
#    ...    AND    Set Library Search Order    BS-RF__Start_Stop_WCDMA_Downlink_TestModels_TM_3__RP001548__Automated
#    [Timeout]    14400
#    TC__BS-RF__Start_Stop_WCDMA_Downlink_TestModels_TM_3__RP001548__Automated
#    [Teardown]    BS-RF__Start_Stop_WCDMA_Downlink_TestModels_TM_3__RP001548__Automated.TC Teardown
#
#
#[1]BS-RF__Start_Stop_WCDMA_Downlink_TestModels_TM_4__RP001548__Automated
#    [Setup]    Run Keywords    Set Test Variable    ${USER_WCDMA_CELL}    24101,24102
#    ...    AND    Set Test Variable    ${USER_PRIMARY_SCR_CODE}
#    ...    AND    BS-RF__Start_Stop_WCDMA_Downlink_TestModels_TM_4__RP001548__Automated.TC Setup
#    ...    AND    Set Library Search Order    BS-RF__Start_Stop_WCDMA_Downlink_TestModels_TM_4__RP001548__Automated
#    [Timeout]    14400
#    TC__BS-RF__Start_Stop_WCDMA_Downlink_TestModels_TM_4__RP001548__Automated
#    [Teardown]    BS-RF__Start_Stop_WCDMA_Downlink_TestModels_TM_4__RP001548__Automated.TC Teardown
#
#
#[1]BS-RF__Start_Stop_WCDMA_Downlink_TestModels_TM_5__RP001548__Automated
#    [Setup]    Run Keywords    Set Test Variable    ${USER_WCDMA_CELL}    24101,24102
#    ...    AND    Set Test Variable    ${USER_PRIMARY_SCR_CODE}
#    ...    AND    BS-RF__Start_Stop_WCDMA_Downlink_TestModels_TM_5__RP001548__Automated.TC Setup
#    ...    AND    Set Library Search Order    BS-RF__Start_Stop_WCDMA_Downlink_TestModels_TM_5__RP001548__Automated
#    [Timeout]    14400
#    TC__BS-RF__Start_Stop_WCDMA_Downlink_TestModels_TM_5__RP001548__Automated
#    [Teardown]    BS-RF__Start_Stop_WCDMA_Downlink_TestModels_TM_5__RP001548__Automated.TC Teardown
#
#
#[1]BS-RF__Start_Stop_WCDMA_Downlink_TestModels_TM_6__RP001548__Automated
#    [Setup]    Run Keywords    Set Test Variable    ${USER_WCDMA_CELL}    24101,24102
#    ...    AND    Set Test Variable    ${USER_PRIMARY_SCR_CODE}
#    ...    AND    BS-RF__Start_Stop_WCDMA_Downlink_TestModels_TM_6__RP001548__Automated.TC Setup
#    ...    AND    Set Library Search Order    BS-RF__Start_Stop_WCDMA_Downlink_TestModels_TM_6__RP001548__Automated
#    [Timeout]    14400
#    TC__BS-RF__Start_Stop_WCDMA_Downlink_TestModels_TM_6__RP001548__Automated
#    [Teardown]    BS-RF__Start_Stop_WCDMA_Downlink_TestModels_TM_6__RP001548__Automated.TC Teardown
#
#
#[1]BS-RF__Start_Stop_WCDMA_BER_BLER_measurement__RP001548__Automated
#    [Setup]    Run Keywords    Set Test Variable    ${USER_WCDMA_CELL}    24101,24102
#    ...    AND    Set Test Variable    ${USER_PRIMARY_SCR_CODE}
#    ...    AND    BS-RF__Start_Stop_WCDMA_BER_BLER_measurement__RP001548__Automated.TC Setup
#    ...    AND    Set Library Search Order    BS-RF__Start_Stop_WCDMA_BER_BLER_measurement__RP001548__Automated
#    [Timeout]    14400
#    TC__BS-RF__Start_Stop_WCDMA_BER_BLER_measurement__RP001548__Automated
#    [Teardown]    BS-RF__Start_Stop_WCDMA_BER_BLER_measurement__RP001548__Automated.TC Teardown
#
#
#[1]BS-RF__Start_Stop_Simultaneously_NR_LTE_WCDMA_Test_Models__RP001548__Automated
#    [Setup]    Run Keywords    Set Test Variable    ${USER_LTE_DL_TM}    E_TM1_1
#    ...    AND    Set Test Variable    ${USER_LTE_UL_TM}    A1_3
#    ...    AND    Set Test Variable    ${USER_LTE_CELL}    12264
#    ...    AND    Set Test Variable    ${USER_WCDMA_DL_TM}
#    ...    AND    Set Test Variable    ${USER_WCDMA_CELL}    24101
#    ...    AND    BS-RF__Start_Stop_Simultaneously_NR_LTE_WCDMA_Test_Models__RP001548__Automated.TC Setup
#    ...    AND    Set Library Search Order    BS-RF__Start_Stop_Simultaneously_NR_LTE_WCDMA_Test_Models__RP001548__Automated
#    [Timeout]    14400
#    TC__BS-RF__Start_Stop_Simultaneously_NR_LTE_WCDMA_Test_Models__RP001548__Automated
#    [Teardown]    BS-RF__Start_Stop_Simultaneously_NR_LTE_WCDMA_Test_Models__RP001548__Automated.TC Teardown
#
#
#[1]BS-RF__Exit_from_Test_Dedicated_State_via_WebEm__RP001548__Automated
#    [Setup]    Run Keywords    BS-RF__Exit_from_Test_Dedicated_State_via_WebEm__RP001548__Automated.TC Setup
#    ...    AND    Set Library Search Order    BS-RF__Exit_from_Test_Dedicated_State_via_WebEm__RP001548__Automated
#    [Timeout]    14400
#    TC__BS-RF__Exit_from_Test_Dedicated_State_via_WebEm__RP001548__Automated
#    [Teardown]    BS-RF__Exit_from_Test_Dedicated_State_via_WebEm__RP001548__Automated.TC Teardown
#
#
#[1]BS-RF__WCDMA_RF_RX_Level_Faults_133__RP001637__Automated
#    [Setup]    Run Keywords    Set Test Variable    ${RMOD_SN}    L9150900121
#    ...    AND    Set Test Variable    ${RMOD_ANTENNA_LINE}    1
#    ...    AND    BS-RF__WCDMA_RF_RX_Level_Faults_133__RP001637__Automated.TC Setup
#    ...    AND    Set Library Search Order    BS-RF__WCDMA_RF_RX_Level_Faults_133__RP001637__Automated
#    [Timeout]    14400
#    TC__BS-RF__WCDMA_RF_RX_Level_Faults_133__RP001637__Automated
#    [Teardown]    BS-RF__WCDMA_RF_RX_Level_Faults_133__RP001637__Automated.TC Teardown
#
#
#
#
#[1]DEV__Check_UE_Cell_Attach_IP_Address_And_Optional_Reattach2
#    [Tags]    STOPONFAIL
#    [Setup]    Run Keywords    Set Test Variable    ${CLEAR_TA_UE_LOGS}    False
#    ...    AND    Set Test Variable    ${CLEAR_TA_UE_PLUGIN}    False
#    ...    AND    Set Test Variable    ${CHECK_SW}    False
#    ...    AND    Set Test Variable    ${USER_DATA}    4941569=8d2161d3,4941572=b2f8b881,10965=ae09b8ab,10966=95794ec0
#    ...    AND    Set Test Variable    ${UE_SN}    95794ec0,ae09b8ab,b2f8b881,8d2161d3
#    ...    AND    Set Test Variable    ${RAT}    GSM,GSM,LTE,LTE
#    ...    AND    Set Test Variable    ${BAND}    900P,1800,B8,B3
#    ...    AND    Set Test Variable    ${EARFCN}    51,822,3600,1370
#    ...    AND    Set Test Variable    ${PSC/PCI}	,,95,92
#    ...    AND    Set Test Variable    ${APN}        AP4,AP4,AP4,AP4
#    ...    AND    Set Test Variable    ${COMMISSIONING_PATH}
#    ...  /home/ute/robotlte/testsuite/hran_ta/testsuite/SBTS/test_line_specific/Wroclaw/SBTS_19303_WRO3TestAuto3/commissioning/SCF_02_TRUNK.xml
#    ...    AND 	  Import Variables    ${ABSTRACT_LIB_CONFIG}
#    ...    AND    DEV__Check_UE_Cell_Attach_IP_Address_And_Optional_Reattach.TC Setup
#    ...    AND    Set Library Search Order    DEV__Check_UE_Cell_Attach_IP_Address_And_Optional_Reattach
#    [Timeout]    14400
#    TC__DEV__Check_UE_Cell_Attach_IP_Address_And_Optional_Reattach
#    [Teardown]    DEV__Check_UE_Cell_Attach_IP_Address_And_Optional_Reattach.TC Teardown
#
#
#
#[1]BS-RF__SBTS_GSM_BB_hopping__RP001637__Automated
#    [Setup]    Run Keywords    Set Test Variable    ${USER_DATA}    967=95794ec0
#    ...    AND 	  Import Variables    ${ABSTRACT_LIB_CONFIG}
#    ...    AND    Set Test Variable    ${NUMBER}    0666002
#    ...    AND    Set Test Variable    ${VOICE_CALL_DURATION}    30s
#    ...    AND    Set Test Variable    ${PS_DURATION}    30s
#    ...    AND    Set Test Variable    ${PROTOCOL}    udp
#    ...    AND    Set Test Variable    ${BANDWIDTH}    300Kbits/sec
#    ...    AND    Set Test Variable    ${DL_MAX}    400Kbits/sec
#    ...    AND    Set Test Variable    ${DL_MIN}    150Kbits/sec
#    ...    AND    Set Test Variable    ${UL_MAX}    300Kbits/sec
#    ...    AND    Set Test Variable    ${UL_MIN}    60Kbits/sec
#    ...    AND    Set Test Variable    ${FTP_LABEL}    FTP_1
#    ...    AND    Set Test Variable    ${DURATION}    30s
#    ...    AND    Set Test Variable    ${COMMISSIONING_PATH}
#    ...  /home/ute/robotlte/testsuite/hran_ta/testsuite/SBTS/test_line_specific/Wroclaw/SBTS_19303_WRO3TestAuto3/commissioning/SCF_02_TRUNK.xml
#    ...    AND    BS-RF__SBTS_GSM_BB_hopping__RP001637__Automated.TC Setup
#    ...    AND    Set Library Search Order    BS-RF__SBTS_GSM_BB_hopping__RP001637__Automated
#    [Timeout]    14400
#    TC__BS-RF__SBTS_GSM_BB_hopping__RP001637__Automated
#    [Teardown]    BS-RF__SBTS_GSM_BB_hopping__RP001637__Automated.TC Teardown
#
#
#[1]BS-RF__SBTS_GSM_RF_hopping__RP001637__Automated
#    [Setup]    Run Keywords    Set Test Variable    ${USER_DATA}    967=95794ec0=10
#    ...    AND 	  Import Variables    ${ABSTRACT_LIB_CONFIG}
#    ...    AND    Set Test Variable    ${NUMBER}    0666002
#    ...    AND    Set Test Variable    ${VOICE_CALL_DURATION}    30s
#    ...    AND    Set Test Variable    ${PS_DURATION}    30s
#    ...    AND    Set Test Variable    ${PROTOCOL}    udp
#    ...    AND    Set Test Variable    ${BANDWIDTH}    300Kbits/sec
#    ...    AND    Set Test Variable    ${DL_MAX}    400Kbits/sec
#    ...    AND    Set Test Variable    ${DL_MIN}    150Kbits/sec
#    ...    AND    Set Test Variable    ${UL_MAX}    300Kbits/sec
#    ...    AND    Set Test Variable    ${UL_MIN}    60Kbits/sec
#    ...    AND    Set Test Variable    ${FTP_LABEL}    FTP_1
#    ...    AND    Set Test Variable    ${DURATION}    30s
#    ...    AND    Set Test Variable    ${COMMISSIONING_PATH}
#    ...  /home/ute/robotlte/testsuite/hran_ta/testsuite/SBTS/test_line_specific/Wroclaw/SBTS_19303_WRO3TestAuto3/commissioning/SCF_02_TRUNK.xml
#    ...    AND    BS-RF__SBTS_GSM_RF_hopping__RP001637__Automated.TC Setup
#    ...    AND    Set Library Search Order    BS-RF__SBTS_GSM_RF_hopping__RP001637__Automated
#    [Timeout]    14400
#    TC__BS-RF__SBTS_GSM_RF_hopping__RP001637__Automated
#    [Teardown]    BS-RF__SBTS_GSM_RF_hopping__RP001637__Automated.TC Teardown
#
#
#[1]BS-RF__LTE_throughputs_10MHz__RP001637__Automated
#    [Setup]    Run Keywords    Set Test Variable    ${USER_DATA}    4941572=b2f8b881
#    ...    AND 	  Import Variables    ${ABSTRACT_LIB_CONFIG}
#    ...    AND    Set Test Variable    ${DURATION}    20s
#    ...    AND    Set Test Variable    ${PROTOCOL}    udp
#    ...    AND    Set Test Variable    ${BANDWIDTH}    71Mbits/sec
#    ...    AND    Set Test Variable    ${DL_MAX}    71Mbits/sec
#    ...    AND    Set Test Variable    ${DL_MIN}    56Mbits/sec
#    ...    AND    Set Test Variable    ${UL_MAX}    25Mbits/sec
#    ...    AND    Set Test Variable    ${UL_MIN}    20Mbits/sec
#    ...    AND    Set Test Variable    ${FTP_LABEL}    FTP_1
#    ...    AND    Set Test Variable    ${TEST_TIMEOUT}    40
#    ...    AND    Set Test Variable    ${COMMISSIONING_PATH}
#    ...  /home/ute/robotlte/testsuite/hran_ta/testsuite/SBTS/test_line_specific/Wroclaw/SBTS_19303_WRO3TestAuto3/commissioning/SCF_02_TRUNK.xml
#    ...    AND    BS-RF__LTE_throughputs_10MHz__RP001637__Automated.TC Setup
#    ...    AND    Set Library Search Order    BS-RF__LTE_throughputs_10MHz__RP001637__Automated
#    [Timeout]    ${TEST_TIMEOUT}min
#    TC__BS-RF__LTE_throughputs_10MHz__RP001637__Automated
#    [Teardown]    BS-RF__LTE_throughputs_10MHz__RP001637__Automated.TC Teardown
#
#
#[1]BS-RF__GSM_voice_call_via_every_TRX__RP001637__Automated **OK**
#    [Setup]    Run Keywords    Set Test Variable    ${USER_DATA}    967=95794ec0
#    ...    AND 	  Import Variables    ${ABSTRACT_LIB_CONFIG}
#    ...    AND    Set Test Variable    ${NUMBER}    0666002
#    ...    AND    Set Test Variable    ${RADIO_TYPE}    FXJB
#    ...    AND    Set Test Variable    ${COMMISSIONING_PATH}
#    ...  /home/ute/robotlte/testsuite/hran_ta/testsuite/SBTS/test_line_specific/Wroclaw/SBTS_19303_WRO3TestAuto3/commissioning/SCF_02_TRUNK.xml
#    ...    AND    BS-RF__GSM_voice_call_via_every_TRX__RP001637__Automated.TC Setup
#    ...    AND    Set Library Search Order    BS-RF__GSM_voice_call_via_every_TRX__RP001637__Automated
#    [Timeout]    14400
#    TC__BS-RF__GSM_voice_call_via_every_TRX__RP001637__Automated
#    [Teardown]    BS-RF__GSM_voice_call_via_every_TRX__RP001637__Automated.TC Teardown
#
#
#[1]BS-RF__SBTS_GSM_Antenna_hopping__RP001637__Automated
#    [Setup]    Run Keywords    Set Test Variable    ${USER_DATA}    967=95794ec0
#    ...    AND 	  Import Variables    ${ABSTRACT_LIB_CONFIG}
#    ...    AND    Set Test Variable    ${NUMBER}    0666002
#    ...    AND    Set Test Variable    ${VOICE_CALL_DURATION}    30s
#    ...    AND    Set Test Variable    ${PS_DURATION}    30s
#    ...    AND    Set Test Variable    ${PROTOCOL}    udp
#    ...    AND    Set Test Variable    ${BANDWIDTH}    300Kbits/sec
#    ...    AND    Set Test Variable    ${DL_MAX}    400Kbits/sec
#    ...    AND    Set Test Variable    ${DL_MIN}    150Kbits/sec
#    ...    AND    Set Test Variable    ${UL_MAX}    300Kbits/sec
#    ...    AND    Set Test Variable    ${UL_MIN}    60Kbits/sec
#    ...    AND    Set Test Variable    ${FTP_LABEL}    FTP_1
#    ...    AND    Set Test Variable    ${DURATION}    30s
#    ...    AND    Set Test Variable    ${COMMISSIONING_PATH}
#    ...  /home/ute/robotlte/testsuite/hran_ta/testsuite/SBTS/test_line_specific/Wroclaw/SBTS_19303_WRO3TestAuto3/commissioning/SCF_02_TRUNK.xml
#    ...    AND    BS-RF__SBTS_GSM_Antenna_hopping__RP001637__Automated.TC Setup
#    ...    AND    Set Library Search Order    BS-RF__SBTS_GSM_Antenna_hopping__RP001637__Automated
#    [Timeout]    14400
#    TC__BS-RF__SBTS_GSM_Antenna_hopping__RP001637__Automated
#    [Teardown]    BS-RF__SBTS_GSM_Antenna_hopping__RP001637__Automated.TC Teardown
#
#
#[1]BS-RF__LTE1530_Activation_Reconfiguration_in_WebEM_9.4MHz__CNI-18553__Automated
#    [Setup]    Run Keywords    Set Test Variable    ${RMOD_SN}    L1153711225
#    ...    AND    Set Test Variable    ${RMOD_SN_2}    L1160506706
#    ...    AND    Set Test Variable    ${CELLS}    12261,12262,12263
#    ...    AND    Set Test Variable    ${COMMISSIONING_PATH}
#    ...  /home/ute/robotlte/testsuite/hran_ta/testsuite/SBTS/test_line_specific/Wroclaw/SBTS_19303_WRO3TestAuto3/commissioning/SCF_02_TRUNK.xml
#    ...    AND    BS-RF__LTE1530_Activation_Reconfiguration_in_WebEM_9.4MHz__CNI-18553__Automated.TC Setup
#    ...    AND    Set Library Search Order    BS-RF__LTE1530_Activation_Reconfiguration_in_WebEM_9.4MHz__CNI-18553__Automated
#    [Timeout]    14400
#    TC__BS-RF__LTE1530_Activation_Reconfiguration_in_WebEM_9.4MHz__CNI-18553__Automated
#    [Teardown]    BS-RF__LTE1530_Activation_Reconfiguration_in_WebEM_9.4MHz__CNI-18553__Automated.TC Teardown
#
#
#[1]BS-RF__LTE1530_Maximum_LTE_Throughput_Test__CNI-18553__Automated
#    [Setup]    Run Keywords    Set Test Variable    ${RMOD_SN}    L1153711225
#    ...    AND 	  Import Variables    ${ABSTRACT_LIB_CONFIG}
#    ...    AND    Set Test Variable    ${RMOD_SN_2}    L1160506706
#    ...    AND    Set Test Variable    ${USER_DATA}    12261=8d2161d3
#    ...    AND    Set Test Variable    ${DURATION}    40s
#    ...    AND    Set Test Variable    ${PROTOCOL}    udp
#    ...    AND    Set Test Variable    ${BANDWIDTH}    70Mbits/sec
#    ...    AND    Set Test Variable    ${DL_MAX}    71Mbits/sec
#    ...    AND    Set Test Variable    ${DL_MIN}    56Mbits/sec
#    ...    AND    Set Test Variable    ${UL_MAX}    26Mbits/sec
#    ...    AND    Set Test Variable    ${UL_MIN}    20Mbits/sec
#    ...    AND    Set Test Variable    ${FTP_LABEL}    FTP_1
#    ...    AND    Set Test Variable    ${COMMISSIONING_PATH}
#    ...  /home/ute/robotlte/testsuite/hran_ta/testsuite/SBTS/test_line_specific/Wroclaw/SBTS_19303_WRO3TestAuto3/commissioning/SCF_02_TRUNK.xml
#    ...    AND    BS-RF__LTE1530_Maximum_LTE_Throughput_Test__CNI-18553__Automated.TC Setup
#    ...    AND    Set Library Search Order    BS-RF__LTE1530_Maximum_LTE_Throughput_Test__CNI-18553__Automated
#    [Timeout]    14400
#    TC__BS-RF__LTE1530_Maximum_LTE_Throughput_Test__CNI-18553__Automated
#    [Teardown]    BS-RF__LTE1530_Maximum_LTE_Throughput_Test__CNI-18553__Automated.TC Teardown
#
#
#[1]BS-RF__EGPRS_throughputs_via_every_TRX__RP001637__Automated
#    [Setup]    Run Keywords    Set Test Variable    ${USER_DATA}    967=95794ec0
#    ...    AND 	  Import Variables    ${ABSTRACT_LIB_CONFIG}
#    ...    AND    Set Test Variable    ${BANDWIDTH}    300Kbits/sec
#    ...    AND    Set Test Variable    ${PROTOCOL}    udp
#    ...    AND    Set Test Variable    ${DL_MAX}    400Kbits/sec
#    ...    AND    Set Test Variable    ${DL_MIN}    150Kbits/sec
#    ...    AND    Set Test Variable    ${UL_MAX}    300Kbits/sec
#    ...    AND    Set Test Variable    ${UL_MIN}    60Kbits/sec
#    ...    AND    Set Test Variable    ${FTP_LABEL}    FTP_1
#    ...    AND    Set Test Variable    ${DURATION}    180s
#    ...    AND    Set Test Variable    ${COMMISSIONING_PATH}
#    ...  /home/ute/robotlte/testsuite/hran_ta/testsuite/SBTS/test_line_specific/Wroclaw/SBTS_19303_WRO3TestAuto3/commissioning/SCF_02_TRUNK.xml
#    ...    AND    Set Test Variable    ${RADIO_TYPE}    FXJB
#    ...    AND    BS-RF__EGPRS_throughputs_via_every_TRX__RP001637__Automated.TC Setup
#    ...    AND    Set Library Search Order    BS-RF__EGPRS_throughputs_via_every_TRX__RP001637__Automated
#    [Timeout]    14400
#    TC__BS-RF__EGPRS_throughputs_via_every_TRX__RP001637__Automated
#    [Teardown]    BS-RF__EGPRS_throughputs_via_every_TRX__RP001637__Automated.TC Teardown
#
#
#[1]BS-RF__Embedded_Power_Meter_EEM_act_deact_in_WebEM__RP000951__Automated
#    [Setup]    Run Keywords    Set Test Variable    ${INTERVAL}    15
#    ...    AND    Set Test Variable    ${RMODS}    2
#    ...    AND    Set Test Variable    ${COMMISSIONING_PATH}
#    ...  /home/ute/robotlte/testsuite/hran_ta/testsuite/SBTS/test_line_specific/Wroclaw/SBTS_19303_WRO3TestAuto3/commissioning/SCF_02_TRUNK.xml
#    ...    AND    BS-RF__Embedded_Power_Meter_EEM_act_deact_in_WebEM__RP000951__Automated.TC Setup
#    ...    AND    Set Library Search Order    BS-RF__Embedded_Power_Meter_EEM_act_deact_in_WebEM__RP000951__Automated
#    [Timeout]    14400
#    TC__BS-RF__Embedded_Power_Meter_EEM_act_deact_in_WebEM__RP000951__Automated
#    [Teardown]    BS-RF__Embedded_Power_Meter_EEM_act_deact_in_WebEM__RP000951__Automated.TC Teardown
#
#
#[1]BS-RF__LTE1530_Alarm_Handling_4393_EFaultId_ReducedLteGuardBandConfNotMatchingFrHwAl__CNI-18553__Automated
#    [Setup]    Run Keywords    Set Test Variable    ${RMOD_SN}    L9150900121
#    ...    AND    Set Test Variable    ${RMOD_SN_2}
#    ...    AND    Set Test Variable    ${CELLS}    12264
#    ...    AND    Set Test Variable    ${COMMISSIONING_PATH}
#    ...  /home/ute/robotlte/testsuite/hran_ta/testsuite/SBTS/test_line_specific/Wroclaw/SBTS_19303_WRO3TestAuto3/commissioning/SCF_02_TRUNK.xml
#    ...    AND    BS-RF__LTE1530_Alarm_Handling_4393_EFaultId_ReducedLteGuardBandConfNotMatchingFrHwAl__CNI-18553__Automated.TC Setup
#    ...    AND    Set Library Search Order
#    ...  BS-RF__LTE1530_Alarm_Handling_4393_EFaultId_ReducedLteGuardBandConfNotMatchingFrHwAl__CNI-18553__Automated
#    [Timeout]    14400
#    TC__BS-RF__LTE1530_Alarm_Handling_4393_EFaultId_ReducedLteGuardBandConfNotMatchingFrHwAl__CNI-18553__Automated
#    [Teardown]
#    ...  BS-RF__LTE1530_Alarm_Handling_4393_EFaultId_ReducedLteGuardBandConfNotMatchingFrHwAl__CNI-18553__Automated.TC Teardown
#
#
#[1]BS-RF__Enter_Exit_to_Test_Dedicated_State_via_Commissioning__RP001548__Automated
#    [Setup]    Run Keywords    Set Test Variable    ${COMMISSIONING_PATH}
#    ...  /home/ute/robotlte/testsuite/hran_ta/testsuite/SBTS/test_line_specific/Wroclaw/SBTS_19303_WRO3TestAuto3/commissioning/SCF_02_TRUNK.xml
#    ...    AND    BS-RF__Enter_Exit_to_Test_Dedicated_State_via_Commissioning__RP001548__Automated.TC Setup
#    ...    AND    Set Library Search Order    BS-RF__Enter_Exit_to_Test_Dedicated_State_via_Commissioning__RP001548__Automated
#    [Timeout]    14400
#    TC__BS-RF__Enter_Exit_to_Test_Dedicated_State_via_Commissioning__RP001548__Automated
#    [Teardown]    BS-RF__Enter_Exit_to_Test_Dedicated_State_via_Commissioning__RP001548__Automated.TC Teardown
#

#[1]BS-RF__Embedded_Power_Meter_EEM_real_time_counters_during_RF_lock_unlock__RP000951__Automated
#    [Setup]    Run Keywords
#    ...    Set Test Variable    ${COMMISSIONING_PATH}
#    ...  /home/ute/robotlte/testsuite/hran_ta/testsuite/SBTS/test_line_specific/Wroclaw/SBTS_19303_WRO3TestAuto3/commissioning/SCF_02_TRUNK.xml
#    ...    AND    BS-RF__WCDMA_Fast_RTWP__RP002611__Automated.TC Setup
#    ...    AND    Set Library Search Order    BS-RF__WCDMA_Fast_RTWP__RP002611__Automated
#    [Timeout]    14400
#    TC__BS-RF__WCDMA_Fast_RTWP__RP002611__Automated
#    [Teardown]    BS-RF__WCDMA_Fast_RTWP__RP002611__Automated.TC Teardown


#*** Keywords ***

