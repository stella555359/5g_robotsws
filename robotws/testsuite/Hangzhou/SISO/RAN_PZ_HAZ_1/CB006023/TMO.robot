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

&{NR2CC_LTE3CC_8163_8_Z_AEHC}=
...   peak_rate_config={"83":[190,10],"84":[190,10],"85":[190,10],"86":[190,10],"87":[190,10],"88":[190,10]}
...   HW_ID=Conf#12 Megafone:     site_mode=SA    ONAIR_TIME=40min

&{NR2CC_LTE2CC_6023_AEHC_Z}=
...   peak_rate_config={"83":[190,10],"84":[190,10],"85":[190,10],"86":[190,10],"87":[190,10],"88":[190,10]}
...   HW_ID=Conf#12 Megafone:     site_mode=SA    ONAIR_TIME=40min

${GLO_5G_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml
${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml
${GLO_4G_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor_lte.xml
#${GLO_SCOUT_TESTLINE_NAME}=    UTE5G163
##${SW_CONFIG_PATH}     /home/ute/robotlte/config/Hangzhou/1_5_UTE4G157/swconfig.txt
#@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}
#${INIT_CONFIG_ID}     TMO_B
#${EARFCN_CONFIG}    {'131': {'InRange': {'Dl':'394000'}, 'OutRange': {'Dl':'37900'}}}

${bbmod_1}    MRBTS-10424/EQM-1/APEQM-1/CABINET-1/BBMOD-1
${bbmod_3}    MRBTS-10424/EQM-1/APEQM-1/CABINET-1/BBMOD-3

${parameters}    [{"dist_name":"${bbmod_1}","para_name":"Baseband board configuration type",
...    "para_value":"NRTDD","require_reset":False},
...    {"dist_name":"${bbmod_3}","para_name":"Baseband board configuration type",
...    "para_value":"NRTDD","require_reset":False}]

${TOP50}                             True
${GLO_SCOUT_TESTLINE_NAME}=    1_5_UTE5G163

${INIT_SW_VERSION}    {'10424': 'SBTS24R2_ENB_0000_000092_000000'}
${TARGET_SW_VERSION}    {'10424': 'SBTS00_ENB_9999_231207_000009'}
${RB_TO_TARGET}    YES
${YAFT}    YES
${force_recommission}    True

${RU}    3*AEHC
${SA_OR_NSA}
${TDD_OR_FDD}    TDD
${HW_ID}    ASIB+ABIO+3*AEHC
${CHECK_CLIMATECONTROLPROFILING_DEFAULT}    ${False}

${GGMAP}   {'L1202707603': {'1':'3.6.6','2':'3.6.8','3':'3.7.6','4':'3.3.6'},
...    'L1213010417': {'1':'3.6.1','7':'3.6.3'},'L1213010383': {'1':'3.7.1','7':'3.3.1'}}

@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}    Unstable eCPRI Link Detected

${delta_json_add_AEHC_path}      ${CURDIR}/TMO_add_AEHC.xml
${delta_json_modify_bandwidth_path}      ${CURDIR}/AEHC_modify_bandwith.xml
${delta_json_add_cells}      ${CURDIR}/add_cells_25R2.xml
${delta_json_remove_cells}      ${CURDIR}/remove_cells.xml

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
    [Tags]    QC_33156    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Ru_Lock_And_Unlock   config_id=TMO_B
    Ru lock And Unlock All
    [Teardown]    Testcase Basic Postcondition

Manual_SiSo_CM_Recommissioning
    [Tags]    QC_33158   QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Recommissioning
    ${parameters}    Evaluate    ${parameters}
    SiSo Multi Parameters Recommissioning    ${parameters}    required_cells=101:104:107
    ...    ping=${False}
    [Teardown]    Testcase Basic Postcondition

[8163_8][1.0] Common_SiSo_Configuration Management_Delta plan Commissioning_Addition of RU with cells
    [Tags]    QC_110629    QCD_MN_RAN    QCP_RAN_VRF
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
    [Tags]    QC_110630    QCD_MN_RAN    QCP_RAN_VRF
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

CB012329-B&C_Common_SiSo_Configuration Management_Delta plan Commissioning_RAT Addition or Deletion
    [Tags]    QC_164236    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Onair     config_id=TMO_B

    FOR    ${bts_id}    IN    @{ALL_BTS_ID_LIST}
        coam.Perform delta recommissioning    ${delta_json_add_cells}    skip_parameter_relation_errors=True
		...    should_activate=true
		...    timeout=600
        ...    connection=${CASE_NAME}_${bts_id}

        ${status}    Run Keyword And Return Status     coam.Assert Any     class_name=BBMOD
        ...     parameters=availabilityStatus=regex"(?i)degraded|off\\sline"
        ...     timeout=300s
        ...     connection=${CASE_NAME}_${bts_id}
        Run Keyword If     ${status}     Fail
    END

    Create Node Parameters From Current SCF
    Wait For All Cells OnAir    timeout=60s
    Check Alarms
    Check Historical Alarms

    FOR    ${bts_id}    IN    @{ALL_BTS_ID_LIST}
        coam.Perform delta recommissioning    ${delta_json_remove_cells}    skip_parameter_relation_errors=True
		...    should_activate=true
		...    timeout=600
        ...    connection=${CASE_NAME}_${bts_id}

        ${status}    Run Keyword And Return Status     coam.Assert Any     class_name=BBMOD
        ...     parameters=availabilityStatus=regex"(?i)degraded|off\\sline"
        ...     timeout=300s
        ...     connection=${CASE_NAME}_${bts_id}
        Run Keyword If     ${status}     Fail
    END

    Create Node Parameters From Current SCF
    Wait For All Cells OnAir    timeout=60s
    Check Alarms
    Check Historical Alarms

#    Make L3call    extra_peak_rate_config=${extra_peak_rate_config}     required_cells=${required_cells}
    [Teardown]    Testcase Basic Postcondition

[1.0] E2E_TL_SW_upgrade_rollback_with_OAM_KPI_and_L3_Call
    [Tags]    QC_33157     QCD_MN_RAN      QCP_RAN_VRF
    [Setup]    Testcase UUF Precondition    case_name=UUF_kpi    config_id=TMO_B
    SW Upgrade And RollBack KPI2    L3Call=NO
    [Teardown]     Testcase KPI postcondition
