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
${peak_rate1}    "331":[350,30],"332":[350,30],"333":[50,3],"334":[90,8],"335":[350,30],"336":[350,30],"337":[50,3],"338":[90,8]
${peak_rate2}    "339":[300,30],"340":[90,8],"341":[90,8],"342":[75,6],"343":[300,30],"344":[90,8],"345":[90,8],"346":[75,6]
${peak_rate3}    "331":[350,25],"332":[280,20],"333":[50,3],"334":[95,8]
${peak_rate4}    "335":[350,25],"336":[90,8],"337":[90,8],"338":[75,6],"339":[350,35],"340":[90,8],"341":[90,8],"342":[75,6]
${peak_rate5}    "331":[350,30],"332":[90,8],"333":[75,6],"334":[50,4]
${peak_rate6}    "335":[350,30],"336":[90,8],"337":[75,6],"338":[50,4],"339":[350,30],"340":[90,8],"341":[75,6],"342":[50,4]
&{5G_4G_CB009489_ASIL_AKQA_T2_2_8T8R}    HW_ID=AKQA   site_mode=5G_4G    ONAIR_TIME=15 min    GG=1:4;2:5
...	  peak_rate_config={"331":[350,30],"332":[350,25],"333":[50,3],"334":[95,8]}
&{5G_4G_CB009489_ASIL_2ABIO_AKQA_T2_2_4T4R}    HW_ID=AKQA   site_mode=5G_4G    ONAIR_TIME=15 min    GG=1:4;3:5
...	  peak_rate_config={"331":[330,35],"332":[250,30],"333":[100,8],"334":[75,6],"335":[350,35],"336":[250,30],"337":[100,8],"338":[75,6]}
&{5G_4G_CB009489_ASIL_2ABIO_AKQA_T2_2_1_3_2T2R}=    HW_ID=CB009489    site_mode=5G_4G     ONAIR_TIME=15 min    GG=1:4;3:5
...									peak_rate_config={${peak_rate1}, ${peak_rate2}}
&{5G_4G_CB009489_ASIL_2ABIO_AKQA_T2_2_1_3_Mix}=    HW_ID=CB009489    site_mode=5G_4G     ONAIR_TIME=15 min    GG=1:4;3:5
...									peak_rate_config={${peak_rate3}, ${peak_rate4}}
&{5G_4G_CB009489_ASIL_2ABIO_AKQA_T1_3_Mix}=    HW_ID=TL2:4G_CB009489    site_mode=5G_4G     ONAIR_TIME=15 min    GG=1:4;3:5
...									peak_rate_config={${peak_rate5}, ${peak_rate6}}
&{4G_CB010656_ASIL_AKNB_T3_8T8R}=    HW_ID=AKNB    site_mode=4G     ONAIR_TIME=15 min
...	  peak_rate_config={"331":[90,8],"332":[90,8],"333":[90,8],"334":[90,8]}
${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml
#${INIT_CONFIG_ID}    5G_4G_CB009489_ASIL_AKQA_T2_2_8T8R
#${ru_password_user}=    KRG3dFggxxHw+s0z64U0AR22VyjfnXdHrAVdSv5jpc4=
${GLO_PERFORM_SAVE_LOG}    NONE
@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}    NgGnbInitFullReset    Unit synchronization failed    ToP reference missing    NgGnbInitPartialReset
${GGMAP}    {"L1211508268":{"1": "1", "2": "2"}, "L1204101603":{"1": "3"}, "1M225120850": {"1": "4", "2": "5"}}
${INIT_SW_VERSION}    {'10769': 'SBTS23R3_ENB_0000_000443_000000'}
${TARGET_SW_VERSION}    {'10769': 'SBTS00_ENB_9999_230705_000010'}
${YAFT}    YES
${RB_TO_TARGET}    NO
*** Test Cases ***
[1][1.0] Common_SiSo_Call_Throughput_Measurements_UDP
    [Tags]    QC_764041    QCD_MN_RAN    QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=Tput    config_id=5G_4G_CB009489_ASIL_AKQA_T2_2_8T8R
    test_fv.Data Transfer    required_cells=332:334
    [Teardown]    Testcase Basic Postcondition

[1][2.0] Exceptional_RF Fiber Insert&Removal Break_both_Primary&Secondary_Link
    [Tags]    QC_764046    QCD_MN_RAN    QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=fiber_insert_remove    config_id=5G_4G_CB009489_ASIL_2ABIO_AKQA_T2_2_1_3_Mix
    SiSo Recovery Hot Remove And Insert RF Fibers    rflink={'1M225120850': 'secondary'}
    SiSo Recovery Hot Remove And Insert RF Fibers    rflink={'1M225120850': 'primary'}
    [Teardown]    Testcase Basic Postcondition

RF module reset Then RAT reset
    [Tags]    QC_764048    QCD_MN_RAN    QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=bbmodreset    config_id=5G_4G_CB009489_ASIL_2ABIO_AKQA_T1_3_Mix
    Common_SiSo_Recovery_RF_module_reset_Then_RAT_reset
    [Teardown]  Testcase Basic Postcondition

Ru Lock And Unlock then Cell block and unblock
    [Tags]    QC_764039    QCD_MN_RAN    QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=Ru_Lockunlock_And_Cell_lockunlock    config_id=5G_4G_CB009489_ASIL_AKQA_T2_2_8T8R
    Ru lock And Unlock All	required_cells=332:334
    Cell Block And Unblock All	required_cells=332:334
    [Teardown]    Testcase Basic Postcondition

[3]Cell Block with_resetBBMOD Then cell unblock
    [Tags]    QC_764040    QCD_MN_RAN    QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=bbmodreset    config_id=5G_4G_CB009489_ASIL_2ABIO_AKQA_T2_2_1_3_Mix
    Common_SiSo_State Management_cell Lock_Then_resetBBMOD_Then_cell unlock
     ...       bbmod_id_list=L1211508268:L1204101603    required_cells=331:332
    [Teardown]  Testcase Basic Postcondition

Remove Logs
    ${dirs}    OperatingSystem.List Directories In Directory    /home/ute/test_results
    FOR    ${dir}    IN    @{dirs}
        ${dir_path}    Join Path    /home/ute/test_results    ${dir}
        Run    rm -rf ${dir_path}
    END
