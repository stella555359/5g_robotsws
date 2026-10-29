*** Settings ***
Documentation
...   Author: xiaofeng.nie@nokia-sbell.com
...   Contact: xiaofeng.nie@nokia-sbell.com
...   Description: This is CB009211-SR cases
Resource           ../Resources/common_resource.robot
Resource           ../../Resources/Classical/RRM_MultiBTS_Common_Resource.robot
Resource           ../../Resources/Classical/RRM_Common_Resource.robot
Resource           ../../Resources/Common/Airphone.robot
Suite Setup        Common MultiBTS Suite Setup For RRM
Test Setup         Common MultiBTS Test Setup For RRM
Test Teardown      Run Keywords    Common MultiBTS Test Teardown For RRM    AND
...                Run Keyword And Ignore Error    Get SCF Internal Id By Scout    no_ute=${False}
Suite Teardown     Common MutliBTS Suite Teardown For RRM
Force Tags         CRT    RAN_5G    SBTS00    RAN_PZ_HAZ_1
Test Timeout       120 minutes


*** Variables ***
&{fault_4334}            faultId=${4334}
&{fault_4293}            faultId=${4293}
&{fault_61510}           faultId=${61510}
&{fault_4459}            faultId=${4459}
&{fault_7300}            faultId=${7300}
&{fault_8000}            faultId=${8000}
&{fault_7523}            faultId=${7523}
&{fault_7107}            faultId=${7107}
&{fault_61616}            faultId=${61616}
@{Ohter_Allow_Alarms}    &{fault_4334}    &{fault_4293}    &{fault_7300}    &{fault_7523}    &{fault_4459}
...    &{fault_7107}     &{fault_61510}    &{fault_8000}    &{fault_61616}
${Ignore_Cell_Id_For_Sib}    5    6    9    12


*** Test Cases ***
CB009211_A-B3_early_HO
    [Documentation]
    ...    author: Xiaofeng Nie
    ...    UE attch to Cell1, HO to Cell3 failed and RRE to Cell1
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=CB009211-A    base_path=${CURDIR}/APCFG
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55124C00504;
    ...    Counter rule: max(M55124C00504)==1;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55142C00531;
    ...    Counter rule: max(M55142C00531)==1;
    ${rule3}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55200C00005;
    ...    Counter rule: max(M55200C00005)==1;
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    UE Attach To Cell1
    UE RRE To Cell1 During HO For AB3
    Counter Check CB009211

CB009211_A-B5_early_HO
    [Documentation]
    ...    author: Xiaofeng Nie
    ...    UE attch to Cell1, HO to Cell3 OK and then RRE to Cell1
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=CB009211-A    base_path=${CURDIR}/APCFG
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55124C00505;
    ...    Counter rule: max(M55124C00505)==1;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55142C00532;
    ...    Counter rule: max(M55142C00532)==1;
    ${rule3}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55200C00006;
    ...    Counter rule: max(M55200C00006)==1;
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    UE Attach To Cell1
    UE RRE To Cell1 After HO For AB5
    Counter Check CB009211

CB009211_A-B6_early_HO
    [Documentation]
    ...    author: Xiaofeng Nie
    ...    UE attch to Cell1, HO to Cell3 OK, then HO babck to Cell1 failed and RRE to Cell1
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=CB009211-A    base_path=${CURDIR}/APCFG
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55124C00505;
    ...    Counter rule: max(M55124C00505)==1;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55142C00531;
    ...    Counter rule: max(M55142C00531)==1;
    ${rule3}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55200C00005;
    ...    Counter rule: max(M55200C00005)==1;
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    UE Attach To Cell1
    UE RRE To Cell1 During HO Back For AB6
    Counter Check CB009211

CB009211_B-B1_wrong_HO
    [Documentation]
    ...    author: Xiaofeng Nie
    ...    UE attch to Cell1, HO to Cell3 failed and RRE to Cell8
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=CB009211-A    base_path=${CURDIR}/APCFG
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-8;
    ...    Counter: M55124C00504;
    ...    Counter rule: max(M55124C00504)==1;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55142C00533;
    ...    Counter rule: max(M55142C00533)==1;
    ${rule3}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55200C00007;
    ...    Counter rule: max(M55200C00007)==1;
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    UE Attach To Cell1
    UE RRE To Cell8 During HO In Cell1 For BB1
    Counter Check CB009211

CB009211_B-B2_wrong_HO
    [Documentation]
    ...    author: Xiaofeng Nie
    ...    UE attch to Cell1, HO to Cell3 OK and then RRE to Cell8
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=CB009211-A    base_path=${CURDIR}/APCFG
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-8;
    ...    Counter: M55124C00505;
    ...    Counter rule: max(M55124C00505)==1;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55142C00533;
    ...    Counter rule: max(M55142C00533)==1;
    ${rule3}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55200C00007;
    ...    Counter rule: max(M55200C00007)==1;
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    UE Attach To Cell1
    UE RRE To Cell8 After HO In Cell3 For BB2
    Counter Check CB009211

CB009211_B-B3_wrong_HO
    [Documentation]
    ...    author: Xiaofeng Nie
    ...    UE attch to Cell1, HO to Cell3 OK, then HO to Cell8 failed and RRE to Cell8
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=CB009211-A    base_path=${CURDIR}/APCFG
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-8;
    ...    Counter: M55124C00505;
    ...    Counter rule: max(M55124C00505)==1;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55142C00533;
    ...    Counter rule: max(M55142C00533)==1;
    ${rule3}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55200C00007;
    ...    Counter rule: max(M55200C00007)==1;
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    UE Attach To Cell1
    UE RRE To Cell8 During HO In Cell3 For BB3
    Counter Check CB009211

CB009211_B-B4_wrong_HO
    [Documentation]
    ...    author: Xiaofeng Nie
    ...    UE attch to Cell1, HO to Cell3 OK, then HO to Cell8 failed with RA and RRE to Cell1
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=CB009211-A    base_path=${CURDIR}/APCFG
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55124C00505;
    ...    Counter rule: max(M55124C00505)==1;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-3;
    ...    Counter: M55142C00534;
    ...    Counter rule: max(M55142C00534)==1;
    ${rule3}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-3;
    ...    Counter: M55200C00008;
    ...    Counter rule: max(M55200C00008)==1;
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    UE Attach To Cell1
    UE RRE To Cell1 During HO In Cell3 To Cell8 For BB4
    Counter Check CB009211

CB009211_C-B2_late_HO
    [Documentation]
    ...    author: Xiaofeng Nie
    ...    UE attch to Cell1, RRE to Cell3 during HO to Cell3
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=CB009211-A    base_path=${CURDIR}/APCFG
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-3;
    ...    Counter: M55124C00505;
    ...    Counter rule: max(M55124C00505)==1;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55142C00529;
    ...    Counter rule: max(M55142C00529)==1;
    ${rule3}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55200C00003;
    ...    Counter rule: max(M55200C00003)==1;
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    UE Attach To Cell1
    UE RRE To Cell3 During HO To Cell3 For CB2
    Counter Check CB009211

CB009211_C-B3_late_HO
    [Documentation]
    ...    author: Xiaofeng Nie
    ...    UE attch to Cell1, RRE to Cell3, and then RRE to Cell8
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=CB009211-A    base_path=${CURDIR}/APCFG
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-8;
    ...    Counter: M55124C00505;
    ...    Counter rule: max(M55124C00505)==1;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-3;
    ...    Counter: M55142C00527;
    ...    Counter rule: max(M55142C00527)==1;
    ${rule3}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-3;
    ...    Counter: M55200C00001;
    ...    Counter rule: max(M55200C00001)==1;
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    UE Attach To Cell1
    UE RRE To Cell3 And Then To Cell8 For CB3
    Counter Check CB009211

CB009211_D-B1_pingpong_HO
    [Documentation]
    ...    author: Xiaofeng Nie
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=CB009211-A    base_path=${CURDIR}/APCFG
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55142C00535;
    ...    Counter rule: max(M55142C00535)==1;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55200C00009;
    ...    Counter rule: max(M55200C00009)==1;
    ${rule3}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55145C00301;
    ...    Counter rule: max(M55145C00301)==1;
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    UE Attach To Cell1
    UE HO From Cell1 To Cell3 And Back To Cell1 For DB1
    Counter Check CB009211

CB009211_D-B2_pingpong_HO
    [Documentation]
    ...    author: Xiaofeng Nie
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=CB009211-A    base_path=${CURDIR}/APCFG
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55142C00535;
    ...    Counter rule: max(M55142C00535)==1;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55200C00009;
    ...    Counter rule: max(M55200C00009)==1;
    ${rule3}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55145C00301;
    ...    Counter rule: max(M55145C00301)==1;
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    UE Attach To Cell1
    UE HO From Cell1 To Cell3 And Cell8 Then Back To Cell1 For DB2
    Counter Check CB009211

CB009211_D-B3_pingpong_HO
    [Documentation]
    ...    author: Xiaofeng Nie
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=CB009211-A    base_path=${CURDIR}/APCFG
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55142C00535;
    ...    Counter rule: max(M55142C00535)==0;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55200C00009;
    ...    Counter rule: max(M55200C00009)==0;
    ${rule3}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55145C00301;
    ...    Counter rule: max(M55145C00301)==1;
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    UE Attach To Cell1
    UE HO From Cell1 To Cell3 And Cell8 With RRE Then Back To Cell1 For DB3
    Counter Check CB009211


*** Keywords ***
UE Attach To Cell1
    [Documentation]
    ...    AP command for UE attach
    Log To Console      ${\n}============= BTS, 5GCN and AP are ready. =============${\n}
    Sleep      30s
    Log To Console      ${\n}============= start UE Attach =============${\n}
    Airphone Execute Egate Command    cmd=ue_register id=1
    Sleep    3s
    Airphone Execute Egate Command    cmd=set_pdu_param ue=1 pdu=1 trf_type=internal
    Sleep    3s
    Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu=1 ue=1 nwslice=1 gw=1
    Sleep    3s

UE RRE To Cell1 During HO For AB3
    [Documentation]
    ...    AP command for RRE during HO of A-B3 scenario
    Log To Console      ${\n}============= start UE handover and RRE to Cell-1 =============${\n}
    Airphone Execute Egate Command    cmd=ue_meas_cfg_disp id=1 meas_obj_type=nr
    Sleep    3s
    Airphone Execute Egate Command
    ...    cmd=ue_nr_rrc_reconf_param id=1 if_contains=any action=reestablish cell=1 gnb=2 cause=handoverFailure
    Sleep    3s
    Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=1 meas_id=3 event=A3 srsrp_nr=15 phycell_id=53 nrsrp_nr=45
    Sleep    3s

UE RRE To Cell1 After HO For AB5
    [Documentation]
    ...    AP command for RRE after HO of A-B5 scenario
    Log To Console      ${\n}============= start UE handover and RRE to Cell-1 =============${\n}
    Airphone Execute Egate Command    cmd=ue_meas_cfg_disp id=1 meas_obj_type=nr
    Sleep    3s
    Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=1 meas_id=5 event=A5 srsrq_nr=35 phycell_id=53 nrsrq_nr=55
    Sleep    3s
    Airphone Execute Egate Command    cmd=ue_rrc_reestablish id=1 gnb=2 cell=1
    Sleep    3s

UE RRE To Cell1 During HO Back For AB6
    [Documentation]
    ...    AP command for RRE after HO and during HO back to Cell-1 of A-B6 scenario
    Log To Console      ${\n}============= start UE handover and RRE to Cell-1 =============${\n}
    Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=1 meas_id=3 event=A3 srsrp_nr=15 phycell_id=53 nrsrp_nr=45
    Sleep    3s
    Airphone Execute Egate Command
    ...    cmd=ue_nr_rrc_reconf_param id=1 if_contains=any action=reestablish cell=1 gnb=2
    Sleep    3s
    Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=1 meas_id=3 event=A3 srsrp_nr=15 phycell_id=51 nrsrp_nr=45
    Sleep    3s

UE RRE To Cell8 During HO In Cell1 For BB1
    [Documentation]
    ...    AP command for RRE during HO of B-B1 scenario
    Log To Console      ${\n}============= start UE handover and RRE to Cell-1 =============${\n}
    Airphone Execute Egate Command
    ...    cmd=ue_nr_rrc_reconf_param id=1 if_contains=any action=reestablish cell=8 gnb=2 cause=handoverFailure
    Sleep    3s
    Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=1 meas_id=3 event=A3 srsrp_nr=15 phycell_id=53 nrsrp_nr=45
    Sleep    3s

UE RRE To Cell8 After HO In Cell3 For BB2
    [Documentation]
    ...    AP command for RRE after HO of B-B2 scenario
    Log To Console      ${\n}============= start UE handover and RRE to Cell-1 =============${\n}
    Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=1 meas_id=3 event=A3 srsrp_nr=15 phycell_id=53 nrsrp_nr=45
    Sleep    3s
    Airphone Execute Egate Command    cmd=ue_rrc_reestablish id=1 gnb=2 cell=8
    Sleep    3s

UE RRE To Cell8 During HO In Cell3 For BB3
    [Documentation]
    ...    AP command for RRE after HO to Cell3 and during HO to Cell8 of B-B3 scenario
    Log To Console      ${\n}============= start UE handover and RRE to Cell-1 =============${\n}
    Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=1 meas_id=3 event=A3 srsrp_nr=15 phycell_id=53 nrsrp_nr=45
    Sleep    3s
    Airphone Execute Egate Command    cmd=ue_measurement_send_nr id=1 meas_id=1 event=A2
    Sleep    3s
    Airphone Execute Egate Command    cmd=ue_nr_rrc_reconf_param id=1 if_contains=any action=reestablish cell=8 gnb=2
    Sleep    3s
    Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=1 meas_id=9 event=A5 srsrq_nr=15 phycell_id=58 nrsrq_nr=45
    Sleep    3s

UE RRE To Cell1 During HO In Cell3 To Cell8 For BB4
    [Documentation]
    ...    AP command for RRE after HO to Cell3 and during HO with RA to Cell8 of B-B4 scenario
    Log To Console      ${\n}============= start UE handover and RRE to Cell-1 =============${\n}
    Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=1 meas_id=3 event=A3 srsrp_nr=15 phycell_id=53 nrsrp_nr=45
    Sleep    3s
    Airphone Execute Egate Command    cmd=ue_measurement_send_nr id=1 meas_id=1 event=A2
    Sleep    3s
    Airphone Execute Egate Command
    ...    cmd=ue_nr_rrc_reconf_param id=1 if_contains=any action=reestablish cell=1 gnb=2 crnti=target
    Sleep    3s
    Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=1 meas_id=9 event=A5 srsrq_nr=15 phycell_id=58 nrsrq_nr=45
    Sleep    3s

UE RRE To Cell3 During HO To Cell3 For CB2
    [Documentation]
    ...    AP command for RRE to Cell3 during HO for C-B2 scenario
    Log To Console      ${\n}============= RRE to Cell-3 during HO to Cell-3 =============${\n}
    Airphone Execute Egate Command
    ...    cmd=ue_nr_rrc_reconf_param id=1 if_contains=any action=reestablish cell=3 gnb=2
    Sleep    3s
    Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=1 meas_id=3 event=A3 srsrp_nr=15 phycell_id=53 nrsrp_nr=45
    Sleep    3s

UE RRE To Cell3 And Then To Cell8 For CB3
    [Documentation]
    ...    AP command for RRE to Cell3 and Cell8 for C-B3 scenario
    Log To Console      ${\n}============= RRE to Cell-3 and then RRE to Cell-8 =============${\n}
    Airphone Execute Egate Command    cmd=ue_rrc_reestablish id=1 gnb=2 cell=3
    Sleep    3s
    Airphone Execute Egate Command    cmd=ue_rrc_reestablish id=1 gnb=2 cell=8
    Sleep    3s

UE HO From Cell1 To Cell3 And Back To Cell1 For DB1
    [Documentation]
    ...    AP command for Pingpong Scenario
    Log To Console      ${\n}============= start UE Pingpong HO =============${\n}
    Airphone Execute Egate Command    cmd=ue_measurement_send_nr id=1 meas_id=3 event=A3 srsrp_nr=15 phycell_id=53 nrsrp_nr=45
    Sleep    3s
    Airphone Execute Egate Command    cmd=ue_measurement_send_nr id=1 meas_id=3 event=A3 srsrp_nr=15 phycell_id=51 nrsrp_nr=45
    Sleep    3s

UE HO From Cell1 To Cell3 And Cell8 Then Back To Cell1 For DB2
    [Documentation]
    ...    AP command for Pingpong Scenario
    Log To Console      ${\n}============= start UE Pingpong HO =============${\n}
    Airphone Execute Egate Command    cmd=ue_measurement_send_nr id=1 meas_id=3 event=A3 srsrp_nr=15 phycell_id=53 nrsrp_nr=45
    Sleep    1s
    Airphone Execute Egate Command    cmd=ue_measurement_send_nr id=1 meas_id=1 event=A2
    Sleep    1s
    Airphone Execute Egate Command    cmd=ue_measurement_send_nr id=1 meas_id=9 event=A5 srsrq_nr=15 phycell_id=58 nrsrq_nr=45
    Sleep    1s
    Airphone Execute Egate Command    cmd=ue_measurement_send_nr id=1 meas_id=11 event=A2
    Sleep    1s
    Airphone Execute Egate Command    cmd=ue_measurement_send_nr id=1 meas_id=16 event=A3 srsrq_nr=15 phycell_id=51 nrsrq_nr=45

UE HO From Cell1 To Cell3 And Cell8 With RRE Then Back To Cell1 For DB3
    [Documentation]
    ...    AP command for Pingpong Scenario
    Log To Console      ${\n}============= start UE Pingpong HO =============${\n}
    Airphone Execute Egate Command    cmd=ue_measurement_send_nr id=1 meas_id=3 event=A3 srsrp_nr=15 phycell_id=53 nrsrp_nr=45
    Sleep    1s
    Airphone Execute Egate Command    cmd=ue_measurement_send_nr id=1 meas_id=1 event=A2
    Sleep    1s
    Airphone Execute Egate Command    cmd=ue_nr_rrc_reconf_param id=1 if_contains=any action=reestablish cell=8 gnb=2
    Sleep    1s
    Airphone Execute Egate Command    cmd=ue_measurement_send_nr id=1 meas_id=9 event=A5 srsrq_nr=15 phycell_id=58 nrsrq_nr=45
    Sleep    1s
    Airphone Execute Egate Command    cmd=ue_measurement_send_nr id=1 meas_id=1 event=A2
    Sleep    1s
    Airphone Execute Egate Command    cmd=ue_measurement_send_nr id=1 meas_id=6 event=A3 srsrq_nr=15 phycell_id=51 nrsrq_nr=45

Counter Check CB009211
    [Documentation]
    ...    Check CB009211 PM Counters
    Log To Console      ${\n}============= RRE is done after or during HO =============${\n}
    Log To Console      ${\n}============= Sleep 5min for counters =============${\n}
    Sleep    300s
    Log To Console      ${\n}============= Check counters =============${\n}
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb
    Log To Console    ${value1}
