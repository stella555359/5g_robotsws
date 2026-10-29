*** Settings ***
Documentation    Suite description
...    Author:        qiang.1.zhou@nokia-sbell.com
...    Maintainer:    Zhou Qiang

Variables   ./env.py
Resource    ../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    ../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot

Force Tags  CA_RAN_PZ_HAZ_1  SBTS00  RAN_5G


Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
&{LTE4CC_6849_AEHC_Z}=
...   peak_rate_config={"107":[89,9.5],"109":[89,9.5]}
#...   peak_rate_config={"101":[82,8],"102":[101,8],"103":[82,8],"104":[82,8],"105":[82,8],"106":[82,8],
#...   "107":[82,8],"108":[101,8],"109":[82,8],"110":[41,3],"111":[82,8],"112":[41,3]}
...   HW_ID=Conf#12 Megafone:     site_mode=4G    ONAIR_TIME=40min
${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor_lte_6849.xml
#${GLO_SCOUT_TESTLINE_NAME}=    UTE5G163
##${SW_CONFIG_PATH}     /home/ute/robotlte/config/Hangzhou/1_5_UTE4G157/swconfig.txt
#@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}
#${INIT_CONFIG_ID}
#${EARFCN_CONFIG}    {'131': {'InRange': {'Dl':'394000'}, 'OutRange': {'Dl':'37900'}}}

${CHECK_CLIMATECONTROLPROFILING_DEFAULT}    ${False}

*** Test Cases ***
[1][1.0] Onair
    [Tags]    QC_    QCD_MN_RAN    QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=Onair    config_id=LTE4CC_6849_AEHC_Z
    Site Reset
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Data Transfer
    [Tags]    QC_33118    QCD_MN_RAN    QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=L3call    config_id=LTE4CC_6849_AEHC_Z
    test_fv.Data Transfer
    [Teardown]    Testcase Basic Postcondition

[1] Common_SiSo_State Management_RF Lock_Then_resetBBMOD_Then_RF unlock
    [Tags]    QC_33117    QCD_MN_RAN    QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=Common_SiSo_State Management_RF Lock_Then_resetBBMOD_Then_RF unlock
    ...    config_id=LTE4CC_6849_AEHC_Z
    Common_SiSo_State Management_RF Lock_Then_resetBBMOD_Then_RF unlock
    [Teardown]    Testcase Basic Postcondition

Cell Block And Unblock
    [Tags]    QC_33116    QCD_MN_RAN    QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=Cell_Block_And_Unblock    config_id=LTE4CC_6849_AEHC_Z
    Cell Block And Unblock All
    [Teardown]    Testcase Basic Postcondition
