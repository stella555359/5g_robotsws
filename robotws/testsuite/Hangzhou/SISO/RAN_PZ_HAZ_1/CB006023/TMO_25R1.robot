*** Settings ***
Documentation    Suite description
...    Author:        qiang.1.zhou@nokia-sbell.com
...    Maintainer:    Zhou Qiang

#Resource    taf/rfrl/uuf4all/uuf4all_test_cases.robot
Variables   ./env_2.py
Resource    ../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    ../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot
Resource    ../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/oam_kpi_test_fv.robot

Force Tags  CA_RAN_PZ_HAZ_1  SBTS00  RAN_5G


Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
&{TMO_B}=
...   peak_rate_config={"86":[190,10],"87":[190,10],"88":[190,10]}
...   HW_ID=Conf#12 Megafone:     site_mode=SA    ONAIR_TIME=40min

&{TMO_B_base}=
...   peak_rate_config={"86":[190,10],"87":[190,10],"88":[190,10]}
...   HW_ID=Conf#12 Megafone:     site_mode=SA    ONAIR_TIME=40min

${GLO_5G_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml
${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml
${GLO_4G_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor_lte.xml
${CHECK_CLIMATECONTROLPROFILING_DEFAULT}    ${False}

${delta_json_add_AEHC_path}      ${CURDIR}/TMO_add_AEHC_25R1.xml
${delta_json_modify_bandwidth_path}      ${CURDIR}/AEHC_modify_bandwith.xml

*** Test Cases ***
#[8163_9][1.0] Onair
#    [Tags]    QC_259779    QCD_MN_RAN    QCP_RAN_VRF
#    [Setup]    Testcase Basic Precondition    case_name=Onair    config_id=NR1CC_LTE2CC_8163_9_Z_AEHC
#    Site Reset
#    [Teardown]    Testcase Basic Postcondition
#
#[8163_9][1.0] Data Transfer
#    [Tags]    QC_259777    QCD_MN_RAN    QCP_RAN_VRF
#    [Setup]    Testcase Basic Precondition    case_name=L3call    config_id=NR1CC_LTE2CC_8163_9_Z_AEHC
#    test_fv.Data Transfer    86:87:88
#    Set Test Variable    ${GLO_TL_DESCRIPTOR_FILE_PATH}    ${GLO_4G_TL_DESCRIPTOR_FILE_PATH}
#    test_fv.Data Transfer    101:102:103:104:105:106
#    [Teardown]    Testcase Basic Postcondition

[8163_8][1.0] Onair
    [Tags]    QC_    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Onair    config_id=TMO_B
    Site Reset
    [Teardown]    Testcase Basic Postcondition


[8163_8][1.0] Ru Lock And Unlock
    [Tags]    QC_83280    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Ru_Lock_And_Unlock   config_id=TMO_B
    Ru lock And Unlock All
    [Teardown]    Testcase Basic Postcondition

[8163_8][1.0] Common_SiSo_Configuration Management_Delta plan Commissioning_Addition of RU with cells
    [Tags]    QC_110631    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Onair     config_id=TMO_B_base

    PDU Turn On Unit    pdu_type=${BTS_CONFIG['FR']['L1210403325']['pdu']['type']}
    ...    pdu_ip=${BTS_CONFIG['FR']['L1210403325']['pdu']['ip_addr']}
    ...    pdu_port=${BTS_CONFIG['FR']['L1210403325']['pdu']['port']}
    FOR    ${bts_id}    IN    @{ALL_BTS_ID_LIST}
        coam.Perform delta recommissioning    ${delta_json_add_AEHC_path}    skip_parameter_relation_errors=True
		...    should_activate=true
		...    timeout=600
        ...    connection=${CASE_NAME}_${bts_id}

        ${status}    Run Keyword And Return Status     coam.Assert Any     class_name=BBMOD
        ...     parameters=availabilityStatus=regex"(?i)degraded|off\\sline"
        ...     timeout=300s
        ...     connection=${CASE_NAME}_${bts_id}
        Run Keyword If     ${status}     Fail


        coam.Assert Any     class_name=RMOD
        ...     parameters=operationalState=regex"(?i)Enabled|Disabled", serialNumber=L1210403325
        ...     timeout=120s
        ...     connection=${CASE_NAME}_${bts_id}
    END

    Create Node Parameters From Current SCF
    Wait For All Cells OnAir    timeout=300s
    Check Alarms
    Check Historical Alarms      additional_allowed_alarms=Unit power reset
#    Make L3call    extra_peak_rate_config=${extra_peak_rate_config}     required_cells=${required_cells}
    [Teardown]    Testcase Basic Postcondition


[8163_8][1.0] Common_SiSo_Configuration Management_Delta plan Commissioning_Modify Parameter
    [Tags]    QC_110632    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Onair     config_id=TMO_B

    FOR    ${bts_id}    IN    @{ALL_BTS_ID_LIST}
        coam.Perform delta recommissioning    ${delta_json_modify_bandwidth_path}    skip_parameter_relation_errors=True
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
