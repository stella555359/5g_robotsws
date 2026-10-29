*** Settings ***
Documentation    Suite description
...    Author: vinton.dong@nokia-sbell.com
...    Maintainer: Author

Suite Setup    Suite Precondition
Suite Teardown    Suite Postcondition

Variables    ./env.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot

Force Tags    CLOUD_RF_F_CRT1_1026    CA_RAN_PZ_HAZ_1      SBTS00  RAN_4G    RAN_4G_TDD    #CRT
Test Timeout    73h

*** Variables ***
${INFO_MODEL_MANDATORY_ALARM_FAULT_ID_10_SCHEME}=
...    {'alarmDetail': 'Failure in optical interface', 'faultId': '10', 'alarmSeverity': 'Critical'}
${INFO_MODEL_MANDATORY_ALARM_FAULT_ID_23_SCHEME}=
...    {'alarmDetail': 'Incompatible SW version detected', 'faultId': '23', 'alarmSeverity': 'Minor|Critical'}
${BTSSM_MANDATORY_ALARM_FAULT_ID_10_SCHEME}=
...    {'alarmDetail': 'Failure in optical interface', 'faultId': '0010\\D*', 'alarmSeverity': 'a3'}
${BTSSM_MANDATORY_ALARM_FAULT_ID_23_SCHEME}=
...    {'alarmDetail': 'Incompatible SW version detected', 'faultId': '0023\\D*', 'alarmSeverity': 'a1|a3'}
${RF_VARIANT_OPTIMIZED}=  True
${RF_fault_info}
${fault_1907}       ${CURDIR}/dpd_dlpath1_1907.json
${fault_1907_file}  dpd_dlpath1_1907.json
${original_fault}     ${CURDIR}/dpd_dlpath1_origin.json
${original_fault_file}     dpd_dlpath1_origin.json
${scfc_config_t3}   BTS_CLOUD_RF_AIL_B1_B3_CRT1_1026_SBTS00_AZNA.xml
${SW_CONFIG_FILE_PATH}   ${CURDIR}/swconfig.txt
#@{GLO_ALLOWED_ALARMS}=               @{config_module.ALLOWED_ALARMS}
${GLO_TL_DESCRIPTOR_FILE_PATH}=    ${CURDIR}/TLdescriptor.xml
&{CLOUD_RF_AIL_B1_B3_CRT1_1026_SBTS00_AZNA}=    site_mode=4G    HW_ID=T4-M     ONAIR_TIME=15 min
...   peak_rate_config={"101":[103,9],"102":[103,9],"103":[103,9],"104":[103,9]}

&{1_5_1112_T3333_C2_F_267}=    site_mode=4G    HW_ID=1_5_1112_T3333_C2_F_267
...    ONAIR_TIME=20 min
&{5314_2OBCL3_T1122_I_MT_246}=    HW_ID=5314_2OBCL3_T1122_I_MT_246    site_mode=4G    ONAIR_TIME=20 min
...    peak_rate_config={"1":[11,9]}
${INIT_CONFIG_ID}=    CLOUD_RF_AIL_B1_B3_CRT1_1026_SBTS00_AZNA


*** Test Cases ***
#NOTE This test case should be available only once in the whole test suite as the first one
#[4][1.0] Automated__SiSo__FV_Testing_SW_Download_and_Activation
#    [Setup]       Setup Testing_FSM_SW_Update
#    Automated__SiSo__FV_Testing_FSM_SW_Update
#    [Teardown]    Teardown Testing_FSM_SW_Update

#AHED        SerNum: 6Q190208576


[1][1.0] CP_UP_Throughput Measurement_UDP_BW20M
    [Tags]      QC_49923   QCD_MN_RAN    QCP_RAN_VRF
    [Setup]     Testcase Basic Precondition    case_name=Tput    config_id=CLOUD_RF_AIL_B1_B3_CRT1_1026_SBTS00_AZNA
    [Timeout]    72h
    sleep     50s
    test_fv.Data Transfer    required_cells=101
    sleep     10s
    test_fv.Data Transfer    required_cells=102
    sleep     10s
    test_fv.Data Transfer    required_cells=103
    sleep     10s
    test_fv.Data Transfer    required_cells=104
    [Teardown]    Testcase Basic Postcondition


SISO_FaultManagement_RF_Module_alarm_With_Recovery_Action_1901
    [Tags]    QC_33201    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=fault      config_id=CLOUD_RF_AIL_B1_B3_CRT1_1026_SBTS00_AZNA
    [Timeout]    72h
    Upload SWconfig File          ${SW_CONFIG_FILE_PATH}
#   upload the file needed to change
    RF Fault Without Recovery Action AZNA    faultid=1901    required_rfs=6Q190208576
    Upload SWconfig File          ${SW_CONFIG_FILE_PATH}
    [Teardown]    Testcase Basic Postcondition


SISO_FaultManagement_RF_Module_alarm_Without_Recovery_Action_1923
    [Tags]    QC_33200    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=fault  config_id=CLOUD_RF_AIL_B1_B3_CRT1_1026_SBTS00_AZNA
    [Timeout]    72h
    Upload SWconfig File          ${SW_CONFIG_FILE_PATH}
#   upload the file needed to change
    RF Fault Without Recovery Action AZNA    faultid=1923    required_rfs=6Q190208576
    Upload SWconfig File          ${SW_CONFIG_FILE_PATH}
    [Teardown]    Testcase Basic Postcondition



[1][1.0] Exceptional_SWDL for factory load SW RRU
    [Tags]    QC_33202    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Factory    config_id=CLOUD_RF_AIL_B1_B3_CRT1_1026_SBTS00_AZNA
    [Timeout]    72h
    SWDL For Factory Load SW RRU    6Q190208576
    [Teardown]    Testcase Basic Postcondition


[1][1.0] Power Reduction With Static DVM Parameters Into AZNA/AZHA
    [Tags]    QC_33199    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Power    config_id=CLOUD_RF_AIL_B1_B3_CRT1_1026_SBTS00_AZNA
    [Timeout]    72h
    Power Reduction With Static DVM Parameters Into AZNA/AZHA   power_origin=262   M40002C1_origin=6569
    ...    M40003C2_origin=6065   wait_for_counter=15min
    [Teardown]    Testcase Basic Postcondition

#CONF_1_5_1112_T3333_C2_F_267_Throughput
#    [Tags]    QC_21065   QCD_MN_RAN    QCP_RAN_VRF
#    [Setup]    Testcase Basic Precondition    case_name=L3call    config_id=1_5_1112_T3333_C2_F_267
#    [Timeout]    72h
#    test_fv.Data Transfer
#    [Teardown]    Testcase Basic Postcondition

[11][1.0] LTERLCR-28018_Operational_RF module reset
    [Tags]    QC_33221   QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=rf_reset    config_id=5314_2OBCL3_T1122_I_MT_246
    Common_SiSo_Recovery_RF module reset_Then_BBMOD_reset
    [Teardown]    Testcase Basic Postcondition
