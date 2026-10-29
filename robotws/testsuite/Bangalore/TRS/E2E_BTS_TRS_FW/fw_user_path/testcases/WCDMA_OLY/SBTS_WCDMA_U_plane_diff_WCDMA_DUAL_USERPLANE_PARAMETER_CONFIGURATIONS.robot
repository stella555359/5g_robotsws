*** Settings ***
Documentation
...     [Author]        "Shankar Manurwar"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [Validation_status]     "Validated"
...     [Validated_TestLine]    "CLOUD_5G_I_MP_AP_LO"



variables       ta_e2e_bts_trs_fw
Library         ta_emss

Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot

Resource        ${CURDIR}/../resources/common_keywords.robot
Suite Setup       Pre-conditions for testsuite
Suite Teardown    Post-conditions for testteardown
#Suite Setup         Setup Oamops
#Suite Teardown      Teardown Oamops

*** Test Cases ***
[1][1.0] SBTS_WCDMA_U_plane_diff_WCDMA_DUAL_USERPLANE_PARAMETER_CONFIGURATIONS

    Precondition
    Verify BTS status   req_rat=wcdma   should_be_onair=${True}
    Sleep     10
    Verify default values
    Verify upper and lower range for committedBitRateCommon
    Verify upper and lower range for committedBitRate
    Verify validation scenario for commonmode
    Reset Bts   wait_for=600    verify_bts=True     should_be_onair=True
    ${output}=      Run     ping -c 5 192.168.255.129
    Should Contain  ${output}   0% packet loss

***Keywords***

Precondition
    Perform Commissioning       scf_file=${base_scf_wcdma}   verify_bts_status=true     timeout=400     alias=default
    Sleep    300

Verify default values
    ${output_1}=    Get Parameter	param_path=WNBTS-1:cacMode
    Should contain      ${output_1}      dedicatedCac
    ${output_2}=    Get Parameter   param_path=WNBTS-1:committedBitRateCommon
    Set Suite Variable     ${output_2}
    Should Be Equal As Integers     ${output_2}     ${value}

    ${output_3}=    Get Parameter   param_path=WNBTS-1:uPlaneList:committedBitRate
    Set Suite Variable     ${output_3}
    Should Be Equal As Integers     ${output_3}     ${value}
Verify upper and lower range for committedBitRateCommon
    Run Keyword And Expect Error        *VALUE_IS_TOO_SMALL*    Perform Recommissioning    type=param    param_path=WNBTS-1:committedBitRateCommon
    ...    operation=update    value=300     skip_parameter_relation_errors=${True}    timeout=300
    Sleep   30
    Perform Recommissioning     type=param  param_path=WNBTS-1:committedBitRateCommon    operation=update    value=400     timeout=300
    Sleep   30

    Run Keyword And expect Error        *VALUE_IS_TOO_BIG*    Perform Recommissioning    type=param    param_path=WNBTS-1:committedBitRateCommon
    ...    operation=update    value=999901     skip_parameter_relation_errors=${False}    timeout=300
    Sleep   30
    Perform Recommissioning     type=param  param_path=WNBTS-1:committedBitRateCommon    operation=update    value=999900     timeout=300
    Sleep   60


Verify upper and lower range for committedBitRate
    ${output_error_small}=  Run Keyword And Expect Error    *VALUE_IS_TOO_SMALL*        Perform Recommissioning     type=delta
    ...      delta_file=delta_bit_rate_wrong_value_small.xml     timeout=600     skip_parameter_relation_errors=${False}
    Sleep   30
    Perform Recommissioning     type=delta      delta_file=delta_bit_rate_actual_value_small.xml    timeout=600
    ...     skip_parameter_relation_errors=${False}
    Sleep   30

    ${output_error_big}=  Run Keyword And Expect Error    *VALUE_IS_TOO_BIG*        Perform Recommissioning     type=delta
    ...      delta_file=delta_bit_rate_wrong_value_big.xml     timeout=600     skip_parameter_relation_errors=${False}
    Sleep   30
    Perform Recommissioning     type=delta      delta_file=delta_bit_rate_actual_value_small.xml    timeout=600
    ...     skip_parameter_relation_errors=${False}
    Sleep   30



Verify validation scenario for commonmode

    Perform Recommissioning     type=param  param_path=WNBTS-1:cacMode    operation=update    value=commonCac     timeout=300
    Sleep   60
    Perform Recommissioning     rat=all_rat     type=param  param_path=MRBTS-3737/WNBTS-1:uPlaneList:committedBitRate
    ...    operation=delete    timeout=300
    Sleep   10

    ${output_4}=    Get Parameter   param_path=WNBTS-1:cacMode
    Should contain      ${output_4}      commonCac
