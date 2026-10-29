*** Settings ***
#Force Tags
Documentation    Suite description
...    Author:        qiang.1.zhou@nokia-sbell.com
...    Maintainer:    Zhou Qiang

Resource    ../resources/common_setup.robot
Resource    ../resources/test_fv.robot
Resource    ../resources/oam_kpi_test_fv.robot
Variables    ./env.py

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition
Test Timeout      73h
*** Variables ***
&{5880}=     peak_rate_config={"112":[60,20],"111":[216,9],"128":[110,20]}
...   HW_ID=Conf#12 Megafone:    site_mode=MULTI_RAT   ONAIR_TIME=10min

${YAFT}       YES
${INIT_SW_VERSION}        {'6478': 'SBTS23R3_ENB_0000_000496_000000'}
${TARGET_SW_VERSION}         {'6478': 'SBTS23R4_ENB_0000_000057_000000'}
${RB_TO_TARGET}     YES 
${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml
${param1}     No X2 link available for a specific LTEENB
${param2}     No X2 link available
${param3}     Unutilized hardware baseband resources by WCDMA
${param4}     Setup of X2 connectivity to gNB failed
${param5}     NgGnbInitFullReset
@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}=    ${param1}    ${param2}     ${param3}     ${param4}    ${param5}
#@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}=   No X2 link available for a specific LTEENB
# ...                                  No X2 link available
#${TOP50}                             True
${GLO_SCOUT_TESTLINE_NAME}           UTE4G126

*** Test Cases ***

[1][1.0] Onair
    [Tags]    QC_2102    QCD_MN_RAN    QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=Onair    config_id=5880
    [Timeout]     72h
    Site Reset
    [Teardown]    Testcase Basic Postcondition
#
[1][1.0] Data Transfer
    [Tags]    QC_626724    QCD_MN_RAN    QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=L3call    config_id=5880
    [Timeout]     72h
    #${extra_peak_rate_config}    Evaluate    {"301":[140,75],"302":[140,75],"303":[140,75]}
    test_fv.Data Transfer
    [Teardown]    Testcase Basic Postcondition

[3]Cell Block And Unblock All_with_resetBBMOD
    [Tags]    QC_626725    QCD_MN_RAN   QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=bbmodreset       config_id=5880
    [Timeout]     72h
    Common_SiSo_State Management_cell Lock_Then_resetBBMOD_Then_cell unlock
     ...       bbmod_id_list=EA184380689:EA200950182:DH212563609
    [Teardown]  Testcase Basic Postcondition

[4]Ru lock And Unlock All_with_resetBBMO
    [Tags]    QC_626723    QCD_MN_RAN   QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=Cell Block And Unblock All_with_resetBBMOD    config_id=5880
	[Timeout]     72h
    Common_SiSo_State Management_RF Lock_Then_resetBBMOD_Then_RF unlock
    ...       bbmod_id_list=EA184380689:EA200950182:DH212563609
    [Teardown]  Testcase Basic Postcondition

[5] General_SiSo_Auto_Automatic_RAT_SW_upgrade
    [Tags]    QC_626726     QCD_MN_RAN      QCP_RAN_ST
    [Setup]    Testcase UUF Precondition    case_name=UUF_kpi    config_id=5880
    SW Upgrade And RollBack KPI2    L3Call=YES
    [Teardown]     Testcase KPI postcondition
