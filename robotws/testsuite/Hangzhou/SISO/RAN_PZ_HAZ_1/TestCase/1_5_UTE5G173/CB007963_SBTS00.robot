*** Settings ***
Documentation    Suite description
...    Author:        wei.ren@nokia-sbell.com
...    Maintainer:    Ren Wei

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
${peak_rate5}    "331":[350,25],"332":[100,8],"333":[75,6],"334":[50,4]
${peak_rate6}    "335":[350,25],"336":[100,8],"337":[75,6],"338":[50,4],"339":[350,25],"340":[100,8],"341":[75,6],"342":[50,4]
&{5G_4G_CB007963_ASIL_AKQA_T2_2_8T8R}    HW_ID=AKQA   site_mode=5G_4G    ONAIR_TIME=15 min    GG=1:4;2:5
...	  peak_rate_config={"331":[350,25],"332":[350,25],"333":[50,3],"334":[90,8]}
&{5G_4G_CB009489_ASIL_2ABIO_AKQA_T2_2_4T4R}    HW_ID=AKQA   site_mode=5G_4G    ONAIR_TIME=15 min    GG=1:4;3:5
...	  peak_rate_config={"331":[330,30],"332":[250,25],"333":[100,8],"334":[75,6],"335":[350,30],"336":[250,25],"337":[100,8],"338":[75,6]}
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
@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}    NgGnbInitFullReset    NgGnbInitPartialReset
${GGMAP}    {"L1211508268":{"1": "1", "2": "2"}, "L1204101603":{"1": "3"}, "1M225120850": {"1": "4", "2": "5"}}
${INIT_SW_VERSION}    {'10769': 'SBTS23R3_ENB_0000_000443_000000'}
${TARGET_SW_VERSION}    {'10769': 'SBTS00_ENB_9999_230705_000010'}
${YAFT}    YES
${RB_TO_TARGET}    NO
${tsn_config}    {"account": {"ip": "10.68.252.24", "username": "cli", "username2": "admin", "password": "Admin@1830",
...               "prompt": "NE28#"},
...               "port": {"1": "port8", "2": "port10"}}


*** Test Cases ***
UE_traffic_test_with_sync_resiliency_activated_when_sync_master_switch
    [Tags]    QC_752260   QCD_MN_RAN   QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=UE_traffic_when_sync_master_switch   config_id=5G_4G_CB007963_ASIL_AKQA_T2_2_8T8R
    Append To List      ${GLO_ADMIN_HISTORY_ALLOWED_ALARM}    ToP master service RU eCPRI port #1 unusable
    Append To List      ${GLO_ADMIN_HISTORY_ALLOWED_ALARM}    ToP master service RU eCPRI port #2 unusable
    UE_traffic_test_with_sync_resiliency_activated_when_sync_master_switch    rf_sn=1M225120850
    ...    tsn_config=${tsn_config}   required_cell=331    dl=100    ul=10
	UE_traffic_test_with_sync_resiliency_activated_when_sync_master_switch    rf_sn=1M225120850
	...    tsn_config=${tsn_config}    required_cell=333  dl=50  ul=3
    Remove Values From List     ${GLO_ADMIN_HISTORY_ALLOWED_ALARM}    ToP master service RU eCPRI port #1 unusable
    Remove Values From List     ${GLO_ADMIN_HISTORY_ALLOWED_ALARM}    ToP master service RU eCPRI port #2 unusable
    [Teardown]    Testcase Basic Postcondition




Recovery_from_failure_of_current_best_ToP_Master_with_available_second-best_ToP_Master
    [Tags]    QC_752258 	QCD_MN_RAN    QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=Recovery_from_failure    config_id=5G_4G_CB007963_ASIL_AKQA_T2_2_8T8R
    Recovery_from_failure_of_current_best_ToP_Master_with_available_second-best_ToP_Master	rf_sn=1M225120850    tsn_config=${tsn_config}
    [Teardown]    Testcase Basic Postcondition


