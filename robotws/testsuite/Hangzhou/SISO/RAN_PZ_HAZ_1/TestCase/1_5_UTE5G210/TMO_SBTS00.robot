*** Settings ***
Documentation    Suite description
...    Author:        lei.10.huang@nokia-sbell.com
...    Maintainer:    Huang Lei

Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/reportportal.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/oam_kpi_test_fv.robot
Variables    ./env.py

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition


*** Variables ***
&{TMO_3AVHA_with_100M_86M}    HW_ID=CB013711   site_mode=SA   ONAIR_TIME=20 min
...									peak_rate_config={"811":[580,79],"812":[180,25],"821":[580,79],"822":[180,25],"831":[580,79],"832":[180,25]}
&{TMO_2AVHA_with_100_34_49point5M_and_55_38_44M}    HW_ID=CB013711   site_mode=SA   ONAIR_TIME=20 min
...									peak_rate_config={"811":[580,79],"812":[162,21],"813":[250,33],"831":[267,39],"832":[178,25],"833":[217,28]}
&{TMO_2AVHA_with_49point5_49_38point5_38M_and_86_57point5M}    HW_ID=CB013711   site_mode=SA   ONAIR_TIME=20 min
...									peak_rate_config={"811":[250,33],"812":[250,33],"813":[178,25],"814":[178,25],"831":[443,67],"832":[265,41]}

&{TMO_3AVHA_with_72e_49point5_49_38point5_38M_and_49_34_15_10M_and_55_38_44M}    HW_ID=CB013711   site_mode=SA   ONAIR_TIME=20 min
...									peak_rate_config={"811":[250,33],"813":[178,25],"814":[178,25],"821":[250,33],"822":[162,21],"831":[267,39],"833":[217,28]}
&{TMO_3AVHA_with_72e_49point5_49_44_40M_and_44_33_20_10M_and_86_57point5M}    HW_ID=CB013711   site_mode=SA   ONAIR_TIME=20 min
...									peak_rate_config={"811":[250,33],"812":[250,33],"814":[220,27],"821":[217,29],"822":[162,21],"831":[443,67],"832":[265,41]}
&{TMO_3AVHA_with_72e_100_38point5M_and_44_33M_and_86_57point5M}    HW_ID=CB013711   site_mode=SA   ONAIR_TIME=20 min
...									peak_rate_config={"811":[580,79],"812":[180,25],"821":[217,29],"822":[162,21],"831":[443,67],"832":[265,41]}
&{TMO_3AVHA_with_100_38point5M_and_44_33M_and_86_57point5M}    HW_ID=CB013711   site_mode=SA   ONAIR_TIME=20 min
...									peak_rate_config={"811":[580,79],"812":[180,25],"821":[217,29],"822":[162,21],"831":[443,67],"832":[265,41]}

${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml
${INIT_CONFIG_ID}    TMO_3AVHA_with_100M_86M
${GLO_PERFORM_SAVE_LOG}      FAIL
@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}    NgGnbInitFullReset    NgGnbInitPartialReset    ToP reference missing
...									LOS on SMOD-1, EIF4
${YAFT}    YES
${RB_TO_TARGET}    NO
${delta_json_modify_nrCellType}      ${CURDIR}/AVHA_modify_nrCellType_from_16D8U_to_8D4U.xml
${delta_json_modify_to_normal}      ${CURDIR}/AVHA_modify_from_slim_to_normal.xml
${delta_json_modify_to_slim}      ${CURDIR}/AVHA_modify_from_normal_to_slim.xml
#${if_reporting_rep}    True

*** Test Cases ***
[1][2.0] [1.1]Common_SiSo_Configuration Management_Delta plan Commissioning
    [Tags]    QC_188016    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=nrCellType_from_16DL8UL_to_8DL4UL     config_id=TMO_2AVHA_with_100_34_49point5M_and_55_38_44M
    FOR    ${bts_id}    IN    @{ALL_BTS_ID_LIST}
        coam.Perform delta recommissioning    ${delta_json_modify_nrCellType}    skip_parameter_relation_errors=True
		...    should_activate=true
		...    timeout=600
        ...    connection=${CASE_NAME}_${bts_id}

        ${status}    Run Keyword And Return Status     coam.Assert Any     class_name=BBMOD
        ...     parameters=availabilityStatus=regex"(?i)degraded|off\\sline"
        ...     timeout=300s
        ...     connection=${CASE_NAME}_${bts_id}
        Run Keyword If     ${status}     Fail
    END

    Wait For All Cells OnAir    timeout=60s
    Check Alarms
    Check Historical Alarms
    General_SiSo_Commissioning_BTS_Template_Commissioning
#    Make L3call    extra_peak_rate_config=${extra_peak_rate_config}     required_cells=${required_cells}
    [Teardown]    Testcase Basic Postcondition

[2][2.0] [1.1]Common_SiSo_Configuration Management_Delta plan Commissioning
    [Tags]    QC_188125    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=active_deactive_slim_carrier
	...       config_id=TMO_2AVHA_with_49point5_49_38point5_38M_and_86_57point5M
    FOR    ${bts_id}    IN    @{ALL_BTS_ID_LIST}
        coam.Perform delta recommissioning    ${delta_json_modify_to_normal}    skip_parameter_relation_errors=True
		...    should_activate=true
		...    timeout=600
        ...    connection=${CASE_NAME}_${bts_id}

        ${status}    Run Keyword And Return Status     coam.Assert Any     class_name=BBMOD
        ...     parameters=availabilityStatus=regex"(?i)degraded|off\\sline"
        ...     timeout=300s
        ...     connection=${CASE_NAME}_${bts_id}
        Run Keyword If     ${status}     Fail
    END
    Wait For All Cells OnAir    timeout=60s
    Check Alarms
    Check Historical Alarms

    FOR    ${bts_id}    IN    @{ALL_BTS_ID_LIST}
        coam.Perform delta recommissioning    ${delta_json_modify_to_slim}    skip_parameter_relation_errors=True
		...    should_activate=true
		...    timeout=600
        ...    connection=${CASE_NAME}_${bts_id}

        ${status}    Run Keyword And Return Status     coam.Assert Any     class_name=BBMOD
        ...     parameters=availabilityStatus=regex"(?i)degraded|off\\sline"
        ...     timeout=300s
        ...     connection=${CASE_NAME}_${bts_id}
        Run Keyword If     ${status}     Fail
    END
    Wait For All Cells OnAir    timeout=60s
    Check Alarms
    Check Historical Alarms
#    Make L3call    extra_peak_rate_config=${extra_peak_rate_config}     required_cells=${required_cells}
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Common_SiSo_Recovery_power off then on secondary core
    [Tags]    QC_188122    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=RAT_reset_from_WebEm
	...       config_id=TMO_3AVHA_with_72e_49point5_49_44_40M_and_44_33_20_10M_and_86_57point5M
    Common_SiSo_Recovery_power off then on secondary core    required_cells=811:812:822:831:832
    [Teardown]    Testcase Basic Postcondition

[1][2.0] Common_SiSo_Call_Throughput Measurements
    [Tags]    QC_182824    QCD_MN_RAN   QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Tput    config_id=TMO_3AVHA_with_72e_100_38point5M_and_44_33M_and_86_57point5M
    test_fv.Data Transfer    required_cells=811:812:821:822:831:832
    [Teardown]    Testcase Basic Postcondition

[2][2.0] Common_SiSo_Call_Throughput Measurements
    [Tags]    QC_188027    QCD_MN_RAN   QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Tput    config_id=TMO_3AVHA_with_100_38point5M_and_44_33M_and_86_57point5M
    test_fv.Data Transfer    required_cells=811:812:821:822:831:832
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Common_SiSo_State Management_RF Lock & Unlock_Then_Cell Block & unblock
    [Tags]    QC_182822   QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=RF_Lock_Unlock_Then_Cell_Block_unblock     config_id=TMO_3AVHA_with_100M_86M
    Ru lock And Unlock All    required_cells=812
    Cell Block And Unblock All    required_cells=811
    [Teardown]    Testcase Basic Postcondition

[1][2.0] Common_SiSo_Recovery_RF module reset_Then_BBMOD_reset
    [Tags]    QC_182825    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=RFReset_with_BBmodReset
...       config_id=TMO_3AVHA_with_72e_49point5_49_38point5_38M_and_49_34_15_10M_and_55_38_44M
    Common_SiSo_Recovery_RF module reset_Then_BBMOD_reset
     ...       bbmod_id_list=L1231609449:L1214206710    required_cells=811:813:821:831
    [Teardown]    Testcase Basic Postcondition

#[1][2.0] Manual_SiSo_Exploratory
#    [Tags]    QC_188028     QCD_MN_RAN      QCP_RAN_VRF
#    [Setup]    Testcase Basic Precondition    case_name=test    config_id=TMO_3AVHA_with_72e_49point5_49_38point5_38M_and_49_34_15_10M_and_55_38_44M
#    SISO_RF module power reset    required_power_rfs=L1244910557:L1251101933:L1245007160    required_cells=811
#    [Teardown]    Testcase Basic Postcondition
#
#[1][1.0] Common_SiSo_Recovery_RF_module_reset_Then_RAT_reset
#    [Tags]    QC_216197    QCD_MN_RAN    QCP_RAN_VRF
#    [Setup]    Testcase Basic Precondition    case_name=RFReset_with_ratReset     config_id=TMO_3AVHA_with_100M_86M
#    Common_SiSo_Recovery_RF_module_reset_Then_RAT_reset    required_cells=811:812
#    [Teardown]    Testcase Basic Postcondition
#
*** Keywords ***
Common_SiSo_Recovery_power off then on secondary core
    [Arguments]    ${required_cells}=${EMPTY}
    PDU Turn Off Unit    pdu_type=${BTS_CONFIG['FSM']['DH244039928']['pdu']['type']}
    ...    pdu_ip=${BTS_CONFIG['FSM']['DH244039928']['pdu']['ip_addr']}
    ...    pdu_port=${BTS_CONFIG['FSM']['DH244039928']['pdu']['port']}
    sleep    1 min
    PDU Turn On Unit    pdu_type=${BTS_CONFIG['FSM']['DH244039928']['pdu']['type']}
    ...    pdu_ip=${BTS_CONFIG['FSM']['DH244039928']['pdu']['ip_addr']}
    ...    pdu_port=${BTS_CONFIG['FSM']['DH244039928']['pdu']['port']}
    Run Keyword And Continue On Failure    Wait For All Cells OnAir    timeout=${ONAIR_TIME}
    Check Alarms
    ${alarm1}    Set Variable    BTS secondary core autonomous reset as recovery action:Fault signature for crash or failure
    ${alarm2}    Set Variable    RAT autonomous reset as recovery action:No connection between primary and BTS extension system module
    Check Historical Alarms    additional_allowed_alarms=${alarm1}:${alarm2}
    Make L3call    required_cells=${required_cells}
