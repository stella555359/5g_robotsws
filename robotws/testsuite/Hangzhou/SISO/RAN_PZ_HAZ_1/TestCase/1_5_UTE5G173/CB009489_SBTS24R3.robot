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
${peak_rate1}    "331":[350,25],"332":[350,20],"333":[50,3],"334":[90,8],"335":[350,25],"336":[350,25],"337":[50,3],"338":[100,8]
${peak_rate2}    "339":[300,25],"340":[100,8],"341":[100,8],"342":[75,6],"343":[300,25],"344":[100,8],"345":[100,8],"346":[75,6]
${peak_rate3}    "331":[350,25],"332":[280,20],"333":[50,3],"334":[90,8]
${peak_rate4}    "335":[350,25],"336":[100,8],"337":[100,8],"338":[75,6],"339":[350,35],"340":[100,8],"341":[100,8],"342":[75,6]
${peak_rate5}    "331":[300,25],"332":[100,8],"333":[75,6],"334":[50,4]
${peak_rate6}    "335":[300,25],"336":[100,8],"337":[75,6],"338":[50,4],"339":[350,25],"340":[100,8],"341":[75,6],"342":[50,4]
&{5G_4G_CB007963_ASIL_AKQA_T2_2_8T8R}    HW_ID=AKQA   site_mode=5G_4G    ONAIR_TIME=15 min    GG=1:4;2:5
...	  peak_rate_config={"331":[350,25],"332":[350,25],"333":[46,3],"334":[90,8]}
&{5G_4G_CB009489_ASIL_AKQA_T2_2_8T8R}    HW_ID=AKQA   site_mode=5G_4G    ONAIR_TIME=15 min    GG=1:4;2:5
...	  peak_rate_config={"331":[350,25],"332":[350,25],"333":[50,3],"334":[90,8]}
&{5G_4G_CB009489_ASIL_2ABIO_AKQA_T2_2_4T4R}    HW_ID=AKQA   site_mode=5G_4G    ONAIR_TIME=15 min    GG=1:4;3:5
...	  peak_rate_config={"331":[300,25],"332":[250,25],"333":[100,8],"334":[75,6],"335":[300,30],"336":[250,25],"337":[100,8],"338":[75,6]}
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
${GLO_PERFORM_SAVE_LOG}    FAIL
@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}    NgGnbInitFullReset    NgGnbInitPartialReset    ToP reference missing
${GGMAP}    {"L1211508268":{"1": "1", "2": "2"}, "L1204101603":{"1": "3"}, "1M225120850": {"1": "4", "2": "5"}}
${INIT_SW_VERSION}    {'10769': 'SBTS23R3_ENB_0000_000443_000000'}
${TARGET_SW_VERSION}    {'10769': 'SBTS00_ENB_9999_230705_000010'}
${YAFT}    YES
${RB_TO_TARGET}    NO
${tsn_config}    {"account": {"ip": "10.68.252.24", "username": "cli", "username2": "admin", "password": "Admin@1830",
...               "prompt": "NE28#"},
...               "port": {"1": "port8", "2": "port10"}}

*** Test Cases ***
Ru Lock And Unlock then Cell block and unblock
    [Tags]    QC_862429 	QCD_MN_RAN    QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=Ru_Lockunlock_And_Cell_lockunlock    config_id=5G_4G_CB009489_ASIL_AKQA_T2_2_8T8R
    Ru lock And Unlock All	required_cells=332:334
    Cell Block And Unblock All	required_cells=332:334
    [Teardown]    Testcase Basic Postcondition

#[1][1.0] Common_SiSo_Startup_Onair
#    [Tags]    QC_471207   QCD_MN_RAN   QCP_RAN_ST
#    [Setup]    Testcase Basic Precondition    case_name=Onair    config_id=5G_4G_CB009489_ASIL_AKQA_T2_2_8T8R
#    Site Reset
#    [Teardown]    Testcase Basic Postcondition

#[1][1.0] Common_SiSo_Performance_Management_TX_and_RX_Antenna_Calibration_Checking
 #   [Tags]    QC_847804   QCD_MN_RAN   QCP_RAN_ST
  #  [Setup]    Testcase Basic Precondition    case_name=Calibration    config_id=5G_4G_CB009489_ASIL_AKQA_T2_2_8T8R
   # ${ru_password_user}    Set Variable    KRG3dFggxxHw+s0z64U0AR22VyjfnXdHrAVdSv5jpc4=
    #Append To List    ${GLO_ADMIN_ALLOWED_ALARM}     Unit synchronization failed
    #test_fv.SISO Antenna Calibration Check ECPRI    required_rfs=1M225120850    ru_password_user=${ru_password_user}
    #Remove Values From List    ${GLO_ADMIN_ALLOWED_ALARM}     Unit synchronization failed
    #[Teardown]    Testcase Basic Postcondition

#[1][1.0] Common_SiSo_Recovery_RF_Module_Reset
#    [Tags]    QC_471283    QCD_MN_RAN   QCP_RAN_ST
#    [Setup]    Testcase Basic Precondition    case_name=RF_Reset    config_id=5G_4G_CB009489_ASIL_AKQA_T2_2_8T8R
#    SISO_Recovery RF module reset       required_cells=332:333
#    [Teardown]    Testcase Basic Postcondition

#[1][1.0] Common_SiSo_Call_Throughput_Measurements_UDP
 #   [Tags]    QC_847793   QCD_MN_RAN   QCP_RAN_ST
  #  [Setup]    Testcase Basic Precondition    case_name=Tput    config_id=5G_4G_CB009489_ASIL_AKQA_T2_2_8T8R
   # test_fv.Data Transfer    required_cells=332:334
    #[Teardown]    Testcase Basic Postcondition

#UE_traffic_test_with_sync_resiliency_activated_when_sync_master_switch
 #   [Tags]    QC_847843   QCD_MN_RAN   QCP_RAN_ST
  #  [Setup]    Testcase Basic Precondition    case_name=UE_traffic_when_sync_master_switch   config_id=5G_4G_CB007963_ASIL_AKQA_T2_2_8T8R
   # Append To List      ${GLO_ADMIN_HISTORY_ALLOWED_ALARM}    ToP master service RU eCPRI port #1 unusable
    #Append To List      ${GLO_ADMIN_HISTORY_ALLOWED_ALARM}    ToP master service RU eCPRI port #2 unusable
    #UE_traffic_test_with_sync_resiliency_activated_when_sync_master_switch    rf_sn=1M225120850
    #...    tsn_config=${tsn_config}   required_cell=331    dl=100    ul=10
	#UE_traffic_test_with_sync_resiliency_activated_when_sync_master_switch    rf_sn=1M225120850
	#...    tsn_config=${tsn_config}    required_cell=333  dl=50  ul=3
    #Remove Values From List     ${GLO_ADMIN_HISTORY_ALLOWED_ALARM}    ToP master service RU eCPRI port #1 unusable
    #Remove Values From List     ${GLO_ADMIN_HISTORY_ALLOWED_ALARM}    ToP master service RU eCPRI port #2 unusable
    #[Teardown]    Testcase Basic Postcondition

#Recovery_from_failure_of_current_best_ToP_Master_with_available_second-best_ToP_Master
 #   [Tags]    QC_847842 	QCD_MN_RAN    QCP_RAN_ST
  #  [Setup]    Testcase Basic Precondition    case_name=Recovery_from_failure    config_id=5G_4G_CB007963_ASIL_AKQA_T2_2_8T8R
   # Recovery_from_failure_of_current_best_ToP_Master_with_available_second-best_ToP_Master	rf_sn=1M225120850    tsn_config=${tsn_config}
    #[Teardown]    Testcase Basic Postcondition

#5G_4G_CB009489_ASIL_2ABIO_AKQA_T2_2_4T4R
#[1][1.0] Ru Lock And Unlock
#    [Tags]    QC_471287 	QCD_MN_RAN    QCP_RAN_ST
#    [Setup]    Testcase Basic Precondition    case_name=Ru_Lock_And_Unlock    config_id=5G_4G_CB009489_ASIL_2ABIO_AKQA_T2_2_4T4R
#    set suite variable   ${GLO_TL_DESCRIPTOR_FILE_PATH}      ${CURDIR}/TLdescriptor_4T4R.xml
#    Ru lock And Unlock All	required_cells=335:336:337:338
#    [Teardown]    Testcase Basic Postcondition

#[1][1.0] Common_SiSo_State Management_Cell_Block_Unblock
#    [Tags]    QC_471292   QCD_MN_RAN   QCP_RAN_ST
#    [Setup]    Testcase Basic Precondition    case_name=Cell_Block    config_id=5G_4G_CB009489_ASIL_2ABIO_AKQA_T2_2_4T4R
#    Cell Block And Unblock All      required_cells=331:332:333:334
#    [Teardown]    Testcase Basic Postcondition

#[2][1.0] Common_SiSo_Call_Throughput_Measurements_UDP
 #   [Tags]    QC_847800   QCD_MN_RAN   QCP_RAN_ST
  #  [Setup]    Testcase Basic Precondition    case_name=Tput    config_id=5G_4G_CB009489_ASIL_2ABIO_AKQA_T2_2_4T4R
   # test_fv.Data Transfer    required_cells=331
    #[Teardown]    Testcase Basic Postcondition
#5G_4G_CB009489_ASIL_2ABIO_AKQA_T2_2_1_3_2T2R
#[1][1.1] General_SiSo_Commissioning_BTS_Template_Commissioning
 #   [Tags]    QC_847802    QCD_MN_RAN    QCP_RAN_ST
  #  [Setup]    Testcase Basic Precondition    case_name=Recommissioning    config_id=5G_4G_CB009489_ASIL_2ABIO_AKQA_T2_2_1_3_2T2R
   # #set suite variable   ${GLO_TL_DESCRIPTOR_FILE_PATH}      ${CURDIR}/TLdescriptor.xml
    #Append To List    ${GLO_ADMIN_ALLOWED_ALARM}     Unit synchronization failed
    #General_SiSo_Commissioning_BTS_Template_Commissioning
    #Remove Values From List    ${GLO_ADMIN_ALLOWED_ALARM}     Unit synchronization failed
    #[Teardown]    Testcase Basic Postcondition

#[1][1.0] SISO_RF module power reset
 #   [Tags]    QC_847801    QCD_MN_RAN    QCP_RAN_ST
  #  [Setup]    Testcase Basic Precondition    case_name=RF_Power_Reset    config_id=5G_4G_CB009489_ASIL_2ABIO_AKQA_T2_2_1_3_2T2R
   # SISO_RF module power reset     required_cells=331:332:333:334
    #[Teardown]    Testcase Basic Postcondition

#[3][1.0] Common_SiSo_Call_Throughput_Measurements_UDP
 #   [Tags]    QC_847798   QCD_MN_RAN   QCP_RAN_ST
  #  [Setup]    Testcase Basic Precondition    case_name=Tput   config_id=5G_4G_CB009489_ASIL_2ABIO_AKQA_T2_2_1_3_2T2R
   # test_fv.Data Transfer       required_cells=339:340:341:342
    #[Teardown]    Testcase Basic Postcondition

#5G_4G_CB009489_ASIL_2ABIO_AKQA_T2_2_1_3_Mix
#[4][1.0] Common_SiSo_Call_Throughput_Measurements_UDP
 #   [Tags]    QC_847794    QCD_MN_RAN   QCP_RAN_ST
  #  [Setup]    Testcase Basic Precondition    case_name=Tput    config_id=5G_4G_CB009489_ASIL_2ABIO_AKQA_T2_2_1_3_Mix
   # test_fv.Data Transfer       required_cells=331:332:335:336
    #[Teardown]    Testcase Basic Postcondition

#[1][1.0] General_SiSo_Online_Cell_Addition_Deletion
 #   [Setup]    Testcase Basic Precondition    case_name=cell_add_delete    config_id=5G_4G_CB009489_ASIL_2ABIO_AKQA_T2_2_1_3_Mix
  #  [Tags]    QC_847799    QCD_MN_RAN   QCP_RAN_ST
   # General SISO Online Cell Addition Deletion    addition_deletion_cell=331:336    required_cells=331:332:336      repetition=1
    #[Teardown]    Testcase Basic Postcondition

#5G_4G_CB009489_ASIL_2ABIO_AKQA_T1_3_Mix
#[5][1.0] Common_SiSo_Call_Throughput_Measurements_UDP
 #   [Tags]    QC_847803    QCD_MN_RAN   QCP_RAN_ST
  #  [Setup]    Testcase Basic Precondition    case_name=Tput    config_id=5G_4G_CB009489_ASIL_2ABIO_AKQA_T1_3_Mix
   # test_fv.Data Transfer       required_cells=331
    #[Teardown]    Testcase Basic Postcondition

#[1.0] Manual_SiSo_SM_NR_RAT_reset_for_concurrent
#    [Tags]    QC_471339    QCD_MN_RAN    QCP_RAN_ST
#    [Setup]    Testcase Basic Precondition    case_name=RAT_reset_from_WebEm    config_id=5G_4G_CB009489_ASIL_2ABIO_AKQA_T1_3_Mix
#    NR_RAT_reset_for_concurrent    required_cells=335:336:337:338:339
#    [Teardown]    Testcase Basic Postcondition

#[1][2.0] Exceptional_RF Fiber Insert&Removal Break_both_Primary&Secondary_Link
 #   [Tags]    QC_847797   QCD_MN_RAN   QCP_RAN_ST
  #  [Setup]    Testcase Basic Precondition    case_name=fiber_insert_remove    config_id=5G_4G_CB009489_ASIL_2ABIO_AKQA_T2_2_1_3_Mix
   # SiSo Recovery Hot Remove And Insert RF Fibers    rflink={'1M225120850': 'secondary'}
    #SiSo Recovery Hot Remove And Insert RF Fibers    rflink={'1M225120850': 'primary'}
    #[Teardown]    Testcase Basic Postcondition

#[1] General_SiSo_SBTS_reset_without_HWF_in_loop
#    [Tags]    QC_592236    QCD_MN_RAN    QCP_RAN_ST
#    [Setup]    Testcase Basic Precondition    case_name=hwf    config_id=5G_4G_CB009489_ASIL_AKQA_T2_2_8T8R
#    [Timeout]    72h
#    FOR    ${num}    IN RANGE    ${50}
#        Site Reset with Remove Hwbin
#        Sleep    5min
#    END
#    [Teardown]    Testcase Basic Postcondition

#[1][1.0] UUF
#    [Tags]    QC_592235    QCD_MN_RAN    QCP_RAN_ST
#    [Documentation]   Auther: lisa.ding@nokia-sbell.com
#    [Setup]    Testcase UUF Precondition    case_name=UUF    config_id=5G_4G_CB009489_ASIL_2ABIO_AKQA_T2_2_4T4R
#    Update Sw To Target
#    [Teardown]    Testcase Basic Postcondition

[3]Cell Block with_resetBBMOD Then cell unblock
    [Tags]    QC_862428    QCD_MN_RAN   QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=bbmodreset    config_id=5G_4G_CB009489_ASIL_2ABIO_AKQA_T2_2_1_3_Mix
    Append To List    ${GLO_ADMIN_ALLOWED_ALARM}     Unit synchronization failed
    Common_SiSo_State Management_cell Lock_Then_resetBBMOD_Then_cell unlock
     ...       bbmod_id_list=L1211508268:L1204101603    required_cells=331:332
    Remove Values From List    ${GLO_ADMIN_ALLOWED_ALARM}     Unit synchronization failed
    [Teardown]  Testcase Basic Postcondition

#RF module reset Then RAT reset
 #   [Tags]    QC_847796    QCD_MN_RAN   QCP_RAN_ST
  #  [Setup]    Testcase Basic Precondition    case_name=bbmodreset    config_id=5G_4G_CB009489_ASIL_2ABIO_AKQA_T1_3_Mix
   # Common_SiSo_Recovery_RF_module_reset_Then_RAT_reset
    #[Teardown]  Testcase Basic Postcondition

#[6][1.0] Common_SiSo_Call_Throughput_Measurements_UDP_8T8R
 #   [Tags]    QC_847805    QCD_MN_RAN   QCP_RAN_ST
  #  [Setup]    Testcase Basic Precondition    case_name=Tput    config_id=4G_CB010656_ASIL_AKNB_T3_8T8R
   # test_fv.Data Transfer       required_cells=332:333
    #[Teardown]    Testcase Basic Postcondition


#[1][1.0] SiSo_Exploratory
#    [Tags]    QC_604154 	QCD_MN_RAN    QCP_RAN_ST
#    [Setup]    Testcase Basic Precondition    case_name=Ru_Lock_And_Unlock    config_id=5G_4G_CB009489_ASIL_2ABIO_AKQA_T2_2_4T4R
#    set suite variable   ${GLO_TL_DESCRIPTOR_FILE_PATH}      ${CURDIR}/TLdescriptor_4T4R.xml
#    Ru lock And Unlock All	required_cells=335:336:337:338
#    [Teardown]    Testcase Basic Postcondition

