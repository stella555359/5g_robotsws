*** Settings ***
Documentation    Suite description
...    Author:        qiang.1.zhou@nokia-sbell.com
...    Maintainer:    Zhou Qiang

Variables   ./env.py
Resource    ../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    ../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot
Resource    ../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/oam_kpi_test_fv.robot

Force Tags  CA_RAN_PZ_HAZ_1  SBTS00  RAN_5G


Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
&{NR1CC_LTE2CC_8163_9_Z_AEHC}=
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
#${INIT_CONFIG_ID}
#${EARFCN_CONFIG}    {'131': {'InRange': {'Dl':'394000'}, 'OutRange': {'Dl':'37900'}}}

${CELL_DIST_NAME_1}    MRBTS-10424/LNBTS-10424/LNCEL-1/LNCEL_TDD-0
${CELL_DIST_NAME_2}    MRBTS-10424/LNBTS-10424/LNCEL-4/LNCEL_TDD-0
${CELL_DIST_NAME_3}    MRBTS-10424/LNBTS-10424/LNCEL-7/LNCEL_TDD-0

${parameters}    [{"dist_name":"${CELL_DIST_NAME_1}","para_name":"The maximum multiplexing layers per MU RBG for downlink MU-MIMO of TDD mMIMO",
...    "para_value":"4","require_reset":False},
...    {"dist_name":"${CELL_DIST_NAME_2}","para_name":"The maximum multiplexing layers per MU RBG for downlink MU-MIMO of TDD mMIMO",
...    "para_value":"4","require_reset":False},
...    {"dist_name":"${CELL_DIST_NAME_3}","para_name":"The maximum multiplexing layers per MU RBG for downlink MU-MIMO of TDD mMIMO",
...    "para_value":"4","require_reset":False}]


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

[1][1.0] Onair
    [Tags]    QC_    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Onair    config_id=NR2CC_LTE2CC_6023_AEHC_Z
    Site Reset
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Data Transfer
    [Tags]    QC_33162    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=L3call
    test_fv.Data Transfer    83:86:84:87
    Set Test Variable    ${GLO_TL_DESCRIPTOR_FILE_PATH}    ${GLO_4G_TL_DESCRIPTOR_FILE_PATH}
    test_fv.Data Transfer    101:102:104:105
    Set Test Variable    ${GLO_TL_DESCRIPTOR_FILE_PATH}    ${GLO_5G_TL_DESCRIPTOR_FILE_PATH}
    [Teardown]    Run Keywords
    ...     Set Test Variable    ${GLO_TL_DESCRIPTOR_FILE_PATH}    ${GLO_5G_TL_DESCRIPTOR_FILE_PATH}    AND
    ...     Testcase Basic Postcondition

[1][1.0] Cell Block And Unblock
    [Tags]    QC_33160    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Cell_Block_And_Unblock
    #Cell Block And Unblock All    extra_peak_rate_config=${extra_peak_rate_config}
    Cell Block And Unblock All   required_cells=86:87:88:101:102:103
    [Teardown]    Testcase Basic Postcondition

#[1] SISO_Recovery RF module reset
#    [Tags]    QC_196576    QCD_MN_RAN    QCP_RAN_VRF
#    [Setup]    Testcase Basic Precondition    case_name=rf_reset
#    SISO_Recovery RF module reset
#    [Teardown]    Testcase Basic Postcondition

[1][1.0] Common_SiSo_Recovery_RF module reset_Then_BBMOD_reset
    [Tags]    QC_33161    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=RF_module_reset_Then_BBMOD_reset
    Common_SiSo_Recovery_RF module reset_Then_BBMOD_reset   required_cells=86
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Common_SiSo_Recovery_hot remove and insert RF fibers
    [Tags]    QC_33159    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=SiSo_Recovery_hot
    ...    config_id=NR2CC_LTE2CC_6023_AEHC_Z
    [Timeout]    72h
    SiSo Recovery Hot Remove And Insert RF Fibers    rflink={'L1202707603': ['primary', 'secondary']}
    [Teardown]    Testcase Basic Postcondition


[8163_8][1.0] Onair
    [Tags]    QC_    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Onair    config_id=NR2CC_LTE3CC_8163_8_Z_AEHC
    Site Reset
    [Teardown]    Testcase Basic Postcondition

[8163_8][1.0] Ru Lock And Unlock
    [Tags]    QC_33156    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Ru_Lock_And_Unlock   config_id=NR2CC_LTE3CC_8163_8_Z_AEHC
    Ru lock And Unlock All
    [Teardown]    Testcase Basic Postcondition

Manual_SiSo_CM_Recommissioning
    [Tags]    QC_33158   QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Recommissioning    config_id=NR2CC_LTE3CC_8163_8_Z_AEHC
    ${parameters}    Evaluate    ${parameters}
    SiSo Multi Parameters Recommissioning    ${parameters}    required_cells=101:104:107
    ...    ping=${False}
    [Teardown]    Testcase Basic Postcondition

[1.0] E2E_TL_SW_upgrade_rollback_with_OAM_KPI_and_L3_Call
    [Tags]    QC_33157     QCD_MN_RAN      QCP_RAN_VRF
    [Setup]    Testcase UUF Precondition    case_name=UUF_kpi    config_id=NR2CC_LTE3CC_8163_8_Z_AEHC
    SW Upgrade And RollBack KPI2    L3Call=NO
    [Teardown]     Testcase KPI postcondition
