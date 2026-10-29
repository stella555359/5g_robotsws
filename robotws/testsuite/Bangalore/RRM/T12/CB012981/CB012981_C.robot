*** Settings ***
Documentation       :copyright: Nokia
...                 :author   : Anandapriya Mani
...                 :contact  : anandapriya.mani@nokia.com
...                 The aim of the feature is to verify UE Power Class 1 support for FR1 TDD band n78
...                 This test case is used to check robustness with 20 times ping pong HO

Resource            resources/Keywords/CB012981_Keyword.robot

Suite Setup         Updated Suite Setup
Suite Teardown      Common Suite Teardown


*** Variables ***
${UE_ID}=    1
${measID}=   4
${gw_ID}=    1
${TRAFFIC_DL_RATE}=    2
${TRAFFIC_UL_RATE}=    2
${iterations}=    21
${TOPOLOGY}         CLOUD_5G_I_LO_AP_LO


*** Test Cases ***
[1][1.0] CB012981_C_6_Verify_gNB_display_a_PDL_validation_error_when_setting_inappropriate_scs_configuration_for_n31_band
    [Documentation]      This testcase is used to verify PDL validation error for FR1_n31_band_with_5_MHz_bandwidth
    [Tags]    QC_120602   QCD_MN_RAN    QCP_RAN_VRF
    Log to Console       Starting the test......
    [Setup]              Prepare for test Case - CB012981_C_5
    ${output}        Run Keyword And Ignore Error        GNB validate scf online
    ${pdl_error_value}    set variable
    ...    it is required that \${NRCELL-1.ssbScs} (value: 30 KHz) equal to 15KHz
    should be true  """${pdl_error_value}""" in """${output}"""
    [Teardown]     Run Keyword And Ignore Error     Tear Down for test Case - CB012981_C_5
