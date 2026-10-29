*** Settings ***
Documentation
...               author: Xiaofeng Nie
...               contact: xiaofeng.nie@nokia-sbell.com
...               CB007123
Resource           ../../../resources/RAN_PZ_HAZ_34/lines/SG6/Module_And_KW/interface_resource.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/TMO/TMO_common_keywords.robot
# Suite Setup    Common MultiBTS Suite Setup For RRM Migration
# Suite Teardown    Common Suite Teardown For RRM Migration
# Test Setup        Common Test Setup For RRM Migration
# Test Teardown     Common Test Teardown For RRM Migration
# Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF    CA_RAN_PZ_HAZ_1    VRF_HAZ_T06
# ...    CLOUD_5G_CLASSICAL_ANDROIDX2_CA_ASIA_ABIAL_AZNC_FXEB
# Test Timeout      120 minutes

Suite Setup     TMO_Common_Suite_Setup   is_commission=${True}   ute_space=10    whether_do_prepare_ue=${False}
...    gnb_scf_name=CB007123
Suite Teardown   Run Keyword And Ignore Error    Teardown for CB007123
Force Tags   SG_06


*** Variables ***
${SERIALS}      RFCWA0G52XE
${COUNTER_TIME}    120s
${DL_IPERF_SERVER}    10.68.254.195
${IPERF_OPTION}    -b 200M -t 1800 -u -i 1 -l 1024 -p 5504


*** Test Cases ***
CB007123_TC01_B1-NR activated by DL buffer overflow indication
    [Documentation]
    ...    author: xiaofeng.nie@nokia-sbell.com
    ...    06.13.2022 initail create
    [Setup]    TMO_AZHL_case_setup
    Log Collection    operation=start   log_type=syslog   product_type=gnb   bts_index=${0}
    Trun Off All PA Ports
    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    RU_id=0   value=25
    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    RU_id=3   value=25
    ${rule1}    Catenate
    ...    Distname: MRBTS-819/LNBTS-8191/LNCEL-11;
    ...    Counter: M8080C171;
    ...    Counter rule: max(M8080C171)>=1;
    ${rule2}    Catenate
    ...    Distname: MRBTS-819/LNBTS-8191/LNCEL-11;
    ...    Counter: M8001C45;
    ...    Counter rule: max(M8001C45)<=100;
    ${rule3}    Catenate
    ...    Distname: MRBTS-819/LNBTS-8191/LNCEL-11;
    ...    Counter: M8001C46;
    ...    Counter rule: max(M8001C46)<=100;
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    Procedures.Start UE Prepare    ue_index=${0}    ue_type=${ue_type}
    power_ue.UE Attach    ue_type=${ue_type}
    ...                                  ue_index=${0}
    ...                                  gnb_index=${0}
    ...                                  hwcheck_index=${0}
    ...                                  du_index=${0}
    ...                                  power_reset=${False}
    ...                                  ue_alias=UE_0
    ...                                  attach_mode=5G_NSA
    power_ue.Start traffic     ue_type=${ue_type}
    ...                        direction=dl
    ...                        throughput=200MKbits/sec
    ...                        duration=180
    ...                        apn_address=${tl.core.pdns[0].apn}
    ...                        dt_name=DT_dl
    ...                        ue_index=${0}
    ...                        ue_mode=NSA
    sleep    5 min
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    interval=5
    Log To Console    ${value1}
    Log Collection    operation=stop_and_download   log_type=syslog   product_type=gnb   bts_index=${0}
    [Teardown]   TMO_Common_Case_Teardown   ue_index=${0}    is_power_ue_code=${False}

CB007123_TC04_B1-NR activated by UL buffer overflow indication
    [Documentation]
    ...    author: xiaofeng.nie@nokia-sbell.com
    ...    06.13.2022 initail create
    [Setup]    TMO_AZHL_case_setup
    Log Collection    operation=start   log_type=syslog   product_type=gnb   bts_index=${0}
    ${rule1}    Catenate
    ...    Distname: MRBTS-819/LNBTS-8191/LNCEL-11;
    ...    Counter: M8080C172;
    ...    Counter rule: max(M8080C172)>=1;
    ${rule2}    Catenate
    ...    Distname: MRBTS-819/LNBTS-8191/LNCEL-11;
    ...    Counter: M8001C16;
    ...    Counter rule: max(M8001C16)<=100;
    ${rule3}    Catenate
    ...    Distname: MRBTS-819/LNBTS-8191/LNCEL-11;
    ...    Counter: M8001C17;
    ...    Counter rule: max(M8001C17)<=100;
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    Procedures.Start UE Prepare    ue_index=${0}    ue_type=${ue_type}
    power_ue.UE Attach    ue_type=${ue_type}
    ...                                  ue_index=${0}
    ...                                  gnb_index=${0}
    ...                                  hwcheck_index=${0}
    ...                                  du_index=${0}
    ...                                  power_reset=${False}
    ...                                  ue_alias=UE_0
    ...                                  attach_mode=5G_NSA
    power_ue.Start traffic     ue_type=${ue_type}
    ...                        direction=ul
    ...                        throughput=100MKbits/sec
    ...                        duration=180
    ...                        apn_address=${tl.core.pdns[0].apn}
    ...                        dt_name=DT_ul
    ...                        ue_index=${0}
    ...                        ue_mode=NSA
    sleep    5 min
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    interval=5
    Log To Console    ${value1}
    [Teardown]   TMO_Common_Case_Teardown   ue_index=${0}    is_power_ue_code=${True}


*** Keywords ***
Teardown for CB007123
    COAM Teardown gnb connections
    ${out}   Parameter Operation    operation=full_commission   product_type=gnb
    ...    scf_path=/home/ute/SCF/T819_gNB_master.xml
    BTS Operation    operation=verify    product_type=gnb    bts_index=0    verify_status=CELL_ONAIR

