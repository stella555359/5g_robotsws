*** Settings ***
Documentation    Suite description
...    Author:        chen.feng@nokia-sbell.com
...    Maintainer:    Feng Chen

Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/affa.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_model.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/variables.robot
Variables   ./env.py

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
&{5G_4G_CB010656_ASIL_AKNB_T3_8T8R}    HW_ID=AKNB   site_mode=5G_4G    ONAIR_TIME=15 min
...	  peak_rate_config={"331":[100,8],"332":[100,8],"333":[300,30]}
&{5G_4G_CB010656_ASIL_AKNB_T33_4T4R}    HW_ID=AKNB   site_mode=5G_4G    ONAIR_TIME=15 min
...	  peak_rate_config={"331":[50,2.8],"332":[50,2.8],"333":[300,30],"334":[50,2.8],"335":[50,2.8],"336":[300,30]}
&{5G_4G_CB010656_ASIL_ABIO_AKNB_T332_2T2R}    HW_ID=AKNB   site_mode=5G_4G    ONAIR_TIME=15 min
...	  peak_rate_config={"331":[100,8],"332":[100,8],"333":[280,30],"334":[50,4],"335":[50,4],"336":[390,50],"337":[50,4],"338":[450,70]}
&{5G_4G_CB010656_ASIL_2ABIO_AKNB_T2222_2T2R}    HW_ID=AKNB   site_mode=5G_4G    ONAIR_TIME=15 min
...	  peak_rate_config={"331":[100,8],"332":[140,9],"333":[80,5.5],"334":[400,40],"335":[100,8],"336":[280,23],"337":[50,2.8],"338":[450,60]}
&{5G_4G_CB010656_ASIL_2ABIO_AKNB_T233_Mix}    HW_ID=AKNB   site_mode=5G_4G    ONAIR_TIME=15 min
...	  peak_rate_config={"331":[80,5.5],"332":[400,40],"333":[100,8],"334":[50,2.8],"335":[300,30],"336":[80,5.5],"337":[50,2.8],"338":[300,30]}
${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml
${INIT_CONFIG_ID}    5G_4G_CB010656_ASIL_AKNB_T3_8T8R
#${ru_password_user}=    KRG3dFggxxHw+s0z64U0AR22VyjfnXdHrAVdSv5jpc4=
${GLO_PERFORM_SAVE_LOG}    NONE
@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}    NgGnbInitFullReset

*** Test Cases ***
[1][1.1] General_SiSo_Commissioning_BTS_Template_Commissioning
    [Tags]    QC_420895    QCD_MN_RAN    QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=Recommissioning    config_id=5G_4G_CB010656_ASIL_AKNB_T3_8T8R
    General_SiSo_Commissioning_BTS_Template_Commissioning
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Common_SiSo_Performance_Management_TX_and_RX_Antenna_Calibration_Checking
    [Tags]    QC_420896   QCD_MN_RAN   QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=Calibration
    ${ru_password_user}    Set Variable    KRG3dFggxxHw+s0z64U0AR22VyjfnXdHrAVdSv5jpc4=
    test_fv.SISO Antenna Calibration Check ECPRI    required_rfs=1M222812813    ru_password_user=${ru_password_user}
    [Teardown]    Testcase Basic Postcondition

[1][1.0] SISO_RF module power reset
    [Tags]    QC_420897    QCD_MN_RAN    QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=RF_Power_Reset
    SISO_RF module power reset     required_cells=331:332:333
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Common_SiSo_State Management_Cell_Block_Unblock
    [Tags]    QC_420898   QCD_MN_RAN   QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=Cell_Block
    Cell Block And Unblock All      required_cells=331:332:333
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Common_SiSo_Call_Throughput_Measurements_UDP
    [Tags]    QC_420899   QCD_MN_RAN   QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=Tput
    test_fv.Data Transfer    required_cells=331:332:333
    [Teardown]    Testcase Basic Postcondition

[2][1.0] Common_SiSo_Call_Throughput_Measurements_UDP
    [Tags]    QC_420900   QCD_MN_RAN   QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=Tput   config_id=5G_4G_CB010656_ASIL_AKNB_T33_4T4R
    test_fv.Data Transfer       required_cells=331:333:335:336
    [Teardown]    Testcase Basic Postcondition

[3][1.0] Common_SiSo_Call_Throughput_Measurements_UDP
    [Tags]    QC_420901   QCD_MN_RAN   QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=Tput   config_id=5G_4G_CB010656_ASIL_ABIO_AKNB_T332_2T2R
    test_fv.Data Transfer       required_cells=331:333:334:336
    [Teardown]    Testcase Basic Postcondition

#2ABIO C3 2T2R T2222
[1][1.0] Common_SiSo_Startup_Onair
    [Tags]    QC_420863   QCD_MN_RAN   QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=Onair    config_id=5G_4G_CB010656_ASIL_2ABIO_AKNB_T2222_2T2R
    Site Reset
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Common_SiSo_Recovery_RF_Module_Reset
    [Tags]    QC_420865   QCD_MN_RAN   QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=RF_Reset
    SISO_Recovery RF module reset       required_cells=331:332:333:334
    [Teardown]    Testcase Basic Postcondition

[2][1.0] Common_SiSo_State Management_Cell_Block_Unblock
    [Tags]    QC_420866   QCD_MN_RAN   QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=Cell_Block
    Cell Block And Unblock All      required_cells=333:334:335:336
    [Teardown]    Testcase Basic Postcondition

[4][1.0] Common_SiSo_Call_Throughput_Measurements_UDP
    [Tags]    QC_420890   QCD_MN_RAN   QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=Tput    #config_id=5G_4G_CB010656_ASIL_2ABIO_AKNB_T2222_2T2R
    test_fv.Data Transfer       required_cells=331:332:333:334:335:336
    [Teardown]    Testcase Basic Postcondition

[1][1.0] General_SiSo_Online_Cell_Addition_Deletion
    [Setup]    Testcase Basic Precondition    case_name=cell_add_delete
    [Tags]    QC_420864   QCD_MN_RAN   QCP_RAN_ST
    General SISO Online Cell Addition Deletion    addition_deletion_cell=335:336    required_cells=331:332:335:336      repetition=1
    [Teardown]    Testcase Basic Postcondition

[2][1.1] General_SiSo_Commissioning_BTS_Template_Commissioning
    [Tags]    QC_420891    QCD_MN_RAN    QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=Recommissioning    config_id=5G_4G_CB010656_ASIL_2ABIO_AKNB_T233_Mix
    General_SiSo_Commissioning_BTS_Template_Commissioning
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Ru Lock And Unlock
    [Tags]    QC_420892 	QCD_MN_RAN    QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=Ru_Lock_And_Unlock
    Ru lock And Unlock All	required_cells=331:332:333:334:335
    [Teardown]    Testcase Basic Postcondition

[3][1.0] Common_SiSo_State Management_Cell_Block_Unblock
    [Tags]    QC_420893   QCD_MN_RAN   QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=Cell_Block
    Cell Block And Unblock All      required_cells=331:332:336:337:338
    [Teardown]    Testcase Basic Postcondition

[5][1.0] Common_SiSo_Call_Throughputee_Measurements_UDP
    [Tags]    QC_420894   QCD_MN_RAN   QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=Tput
    test_fv.Data Transfer       required_cells=331:332:333:334:335
    [Teardown]    Testcase Basic Postcondition

#[1][1.0] Common_SiSo_Recovery_BTS_Site_Reset
#    [Tags]    QC_413045   QCD_MN_RAN   QCP_RAN_ST
#    [Setup]    Testcase Basic Precondition    case_name=Site_Reset
#    Site Reset
#    [Teardown]    Testcase Basic Postcondition

