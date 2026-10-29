# @Time    : 2025/6/11 14:27
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @Group   : NSB MN RAN RD VRF HAZ3 5
# @File    : CB008600_check_counter.robot
# @Software: PyCharm
# @Doc     : This is common robot keywords template
*** Settings ***
Documentation
...    Feature: CB008600:Delay-critical GBR services
Resource    ../../RAN_L2_SW_CN_3/resources/VRF3_T05/internal_resource/internal_resource.robot
Resource    ../../RAN_L2_SW_CN_3/resources/sg10/internal_resource/internal_resource.robot

*** Keywords ***
Check Counters For A108
    [Documentation]    Author: chun.li@nokia-sbell.com
    ...    Counters checking for 8600 TC A108
    [Arguments]    ${counters}    ${dcgbr_pmqapid}
    ${counter_values}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NNGCC']}
    Should Be True    ${counter_values['M55125C08501']}==3
    Should Be True    ${counter_values['M55125C08502']}==3
    Should Be True    ${counter_values['M55125C03501']}==1
    Should Be True    ${counter_values['M55125C03502']}==1
    ${counter_values}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-2']['NGCCQ']}
    Should Be True    ${counter_values['M55163C00001']}==1
    Should Be True    ${counter_values['M55163C00002']}==1
    ${counter_values}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-5']['NGCCQ']}
    Should Be True    ${counter_values['M55163C00001']}==1
    Should Be True    ${counter_values['M55163C00002']}==1
    ${counter_values}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-${dcgbr_pmqapid}']['NGCCQ']}
    Should Be True    ${counter_values['M55163C00001']}==1
    Should Be True    ${counter_values['M55163C00002']}==1
    ${counter_values}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['RSACU']}
    Should Be True    ${counter_values['M55138C00075']}==1
    Should Be True    ${counter_values['M55138C00076']}==1
    Should Be True    ${counter_values['M55138C01001']}==2
    Should Be True    ${counter_values['M55138C01002']}==2
    ${counter_values}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['RSADU']}
    Should Be True    ${counter_values['M55139C00034']}==1
    Should Be True    ${counter_values['M55139C00035']}==1
    Should Be True    ${counter_values['M55139C00501']}==2
    Should Be True    ${counter_values['M55139C00502']}==2

Check Counters For A114
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/05/26 10:39
    [Arguments]    ${connection}=GNB_OAM
    ${tc114_counters}        Catenate    SEPARATOR=    M55125C08501,M55125C08502,M55125C02502,M55125C02501,M55145C04029,M55145C04030,
    ...    M55138C00075,M55138C00076,M55138C01001,M55138C01002,M55139C00034,M55139C00035,M55139C00501,M55139C00502,
    ...    M55125C05501,M55125C05502,M55163C00001,M55163C00002
    coam.connect_to    name=${connection}
    ${counters}    coam.get_pm_counters    counter_ids=${tc114_counters}
    ...    connection=${connection}
    coam.teardown    connection=${connection}

    ${counter_values}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NNGCC']}
    Should Be True    ${counter_values['M55125C08501']}==3    #NG_FLOW_SETUP_ATT_TOT
    Should Be True    ${counter_values['M55125C08502']}==3    #NG_FLOW_SETUP_SUCC
    Should Be True    ${counter_values['M55125C02502']}==3    #NNGCC_UE_CTXT_STP_RESP_SENT
    Should Be True    ${counter_values['M55125C02501']}==3    #NNGCC_UE_CTXT_STP_REQ_RECD
    Should Be True    ${counter_values['M55125C05501']}==3    #NNGCC_UE_CTXT_STP_REQ_EC_RECD
    Should Be True    ${counter_values['M55125C05502']}==3    #NNGCC_UE_CTXT_STP_RESP_EC_SENT
    ${counter_values}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['MCC-311']['MNC-489']['NRANS']}
    Should Be True    ${counter_values['M55145C04029']}==3    #NG_UE_CTXT_STP_REQ_REC_PLMN
    Should Be True    ${counter_values['M55145C04030']}==3    #NG_UE_CTXT_STP_RESP_SENT_PLMN
    ${counter_values}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['RSACU']}
    Should Be True    ${counter_values['M55138C00075']}==3    #SA_DC_GBR_DRB_REQ
    Should Be True    ${counter_values['M55138C00076']}==3    #SA_DC_GBR_DRB_SUCC
    Should Be True    ${counter_values['M55138C01001']}==3    #SA_GBR_DRB_REQ
    Should Be True    ${counter_values['M55138C01002']}==3    #SA_GBR_DRB_SUCC
    ${counter_values}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['RSADU']}
    Should Be True    ${counter_values['M55139C00034']}==3    #SA_DC_GBR_DRB_REQ_DU
    Should Be True    ${counter_values['M55139C00035']}==3    #SA_DC_GBR_DRB_SUCC_DU
    Should Be True    ${counter_values['M55139C00501']}==3    #SA_DU_GBR_DRB_REQ
    Should Be True    ${counter_values['M55139C00502']}==3    #SA_DU_GBR_DRB_SUCC
    ${counter_values}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-10']['NGCCQ']}
    Should Be True    ${counter_values['M55163C00001']}==3    #NG_FLOW_SETUP_ATT_TOT_PMQAP
    Should Be True    ${counter_values['M55163C00002']}==3    #NG_FLOW_SETUP_SUCC_PMQAP
    ${counter_values}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-7']['NGCCQ']}
    Should Be True    ${counter_values['M55163C00001']}==1    #NG_FLOW_SETUP_ATT_TOT_PMQAP
    Should Be True    ${counter_values['M55163C00002']}==1    #NG_FLOW_SETUP_SUCC_PMQAP
    ${counter_values}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-8']['NGCCQ']}
    Should Be True    ${counter_values['M55163C00001']}==1    #NG_FLOW_SETUP_ATT_TOT_PMQAP
    Should Be True    ${counter_values['M55163C00002']}==1    #NG_FLOW_SETUP_SUCC_PMQAP
    ${counter_values}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-9']['NGCCQ']}
    Should Be True    ${counter_values['M55163C00001']}==1    #NG_FLOW_SETUP_ATT_TOT_PMQAP
    Should Be True    ${counter_values['M55163C00002']}==1    #NG_FLOW_SETUP_SUCC_PMQAP

Check Counters For A236
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/06/27 11:50
    [Arguments]    ${connection}=GNB_OAM
    ${tc236_counters}    Catenate    SEPARATOR=    M55125C08501,M55125C08502,M55163C00001,M55163C00002,M55125C02504,
    ...    M55125C02506,M55138C01001,M55138C01002,M55139C00034,M55139C00035,M55139C00501,M55139C00502,
    ...    M55125C09012,M55163C00512,M55138C00075,M55138C00076
    coam.connect_to    name=${connection}
    ${counters}    coam.get_pm_counters    counter_ids=${tc236_counters}
    ...    connection=${connection}
    coam.teardown    connection=${connection}

    ${counter_values}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NNGCC']}
    Should Be True    ${counter_values['M55125C02504']}==1    #NNGCC_PDU_SES_STP_REQ_RECD M55125C02504
    Should Be True    ${counter_values['M55125C08501']}==3    #NG_FLOW_SETUP_ATT_TOT M55125C08501
    Should Be True    ${counter_values['M55125C08502']}==2    #NG_FLOW_SETUP_SUCC M55125C08502
    Should Be True    ${counter_values['M55125C09012']}==1    #NG_FLOW_SETUP_FAIL_WRONG_MSG M55125C09012
    ${counter_values}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['RSACU']}
    Should Be True    ${counter_values['M55138C01001']}==1    #SA_GBR_DRB_REQ M55138C01001
    Should Be True    ${counter_values['M55138C01002']}==1    #SA_GBR_DRB_SUCC M55138C01002
    Should Be True    ${counter_values['M55138C00075']}==1    #SA_DC_GBR_DRB_REQ M55138C00075
    Should Be True    ${counter_values['M55138C00076']}==1    #SA_DC_GBR_DRB_SUCC M55138C00076
    ${counter_values}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['RSADU']}
    Should Be True    ${counter_values['M55139C00501']}==1    #SA_DU_GBR_DRB_REQ M55139C00501
    Should Be True    ${counter_values['M55139C00502']}==1    #SA_DU_GBR_DRB_SUCC M55139C00502
    Should Be True    ${counter_values['M55139C00034']}==1    #SA_DC_GBR_DRB_REQ_DU M55139C00034
    Should Be True    ${counter_values['M55139C00035']}==1    #SA_DC_GBR_DRB_SUCC_DU M55139C00035
    ${counter_values}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-11']['NGCCQ']}
    Should Be True    ${counter_values['M55163C00001']}==1    #NG_FLOW_SETUP_ATT_TOT_PMQAP M55163C00001
    Should Be True    ${counter_values['M55163C00002']}==1    #NG_FLOW_SETUP_SUCC_PMQAP M55163C00002
    Should Be True    ${counter_values['M55163C00512']}==0    #NG_FLOW_STP_FAIL_WRG_MSG_PMQAP M55163C00512
    ${counter_values}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-6']['NGCCQ']}
    Should Be True    ${counter_values['M55163C00001']}==1    #NG_FLOW_SETUP_ATT_TOT_PMQAP M55163C00001
    Should Be True    ${counter_values['M55163C00002']}==0    #NG_FLOW_SETUP_SUCC_PMQAP M55163C00002
    Should Be True    ${counter_values['M55163C00512']}==1    #NG_FLOW_STP_FAIL_WRG_MSG_PMQAP M55163C00512

Check Counters For A236 Step2
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/09/04 10:01
    [Arguments]    ${connection}=GNB_OAM
    ${tc236_counters}        Catenate    SEPARATOR=    M55159C00013,M55159C00014,M55159C00015,M55159C00016,M55159C00024
    coam.connect_to    name=${connection}
    ${counters}    coam.get_pm_counters    counter_ids=${tc236_counters}    connection=${connection}
    coam.teardown    connection=${connection}
    log to console    ${counters}

    ${c}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-11']['PDLTQ']}
    Should Be True    ${c['M55159C00014']}==0
    Should Be True    ${c['M55159C00015']}<=2500
    Should Be True    ${c['M55159C00024']}<=2500
    ${ul_per}    Evaluate    (${c['M55159C00013']}+${c['M55159C00014']})/(${c['M55159C00013']}+${c['M55159C00014']}+${c['M55159C00015']})
    Should Be True    ${ul_per}<0.01
    ${ul_pdb}    Evaluate    ${c['M55159C00016']}/(1000*${c['M55159C00024']})
    Should Be True    ${ul_pdb}<50

Check Counters For B003
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/05/16 14:25
    [Arguments]    ${connection}=M5_DCAP
    coam.connect_to    name=${connection}
    ${counters}    coam.get_pm_counters    counter_ids=M55352C02004,M55320C20003,M55320C20019,M55320C20006
    ...    connection=${connection}
    coam.teardown    connection=${connection}

    ${counter1_values_tmp1}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-1']['PDCPQ']}
    ${counter1_values_tmp2}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-6']['PDCPQ']}
    ${counter1_values}    Evaluate    ${counter1_values_tmp1['M55352C02004']} + ${counter1_values_tmp2['M55352C02004']}
    Should Be True    ${counter1_values}>0
    ${counter2_values}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-20']['PDCPQ']}
    Should Be True    ${counter2_values['M55352C02004']}==0
    ${counter3_values_tmp}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['PDCP2']}
    ${counter3_values}    Evaluate    ${counter3_values_tmp['M55320C20003']} + ${counter3_values_tmp['M55320C20006']}
    Should Be True    ${counter3_values}==${counter1_values}
    Should Be True    ${counter3_values_tmp['M55320C20019']}==0
    [Return]    ${counter1_values}

Check Counters For B005
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/05/26 10:39
    [Arguments]    ${connection}=GNB_OAM
    coam.connect_to    name=${connection}
    ${counters}    coam.get_pm_counters    counter_ids=M55320C20010,M55320C20011,M55320C20012,M55352C02004
    ...    connection=${connection}
    coam.teardown    connection=${connection}

    ${counter1_values}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-11']['NRPMQAP-10']['PDCPQ']}
    Should Be True    ${counter1_values['M55352C02004']}>0
    ${counter2_values}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['PDCP2']}
    Should Be True    ${counter2_values['M55320C20010']}==0
    Should Be True    ${counter2_values['M55320C20011']}==0
    Should Be True    ${counter2_values['M55320C20012']}==0

Check Counters For C103
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/06/04 14:39
    [Arguments]    ${connection}=GNB_OAM
    ${tc103_counters}        Catenate    SEPARATOR=    M55320C20002,M55320C20003,M55320C20004,M55320C20005,
    ...    M55320C20006,M55320C20007,M55320C20008,M55320C20009,M55320C20010,M55320C20011,M55352C02004
    coam.connect_to    name=${connection}
    ${counters}    coam.get_pm_counters    counter_ids=${tc103_counters}
    ...    connection=${connection}
    coam.collect_snapshot    target_file_name=${TEST_LOG_DIRECTORY()}/c103_snapshot.zip    connection=${connection}
    coam.teardown    connection=${connection}

    ${counter_values}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['PDCP2']}
    Should Be True    ${counter_values['M55320C20002']}==0
    Should Be True    ${counter_values['M55320C20003']}==0
    Should Be True    ${counter_values['M55320C20004']}==0
    Should Be True    ${counter_values['M55320C20005']}==0
    Should Be True    ${counter_values['M55320C20006']}==0
    Should Be True    ${counter_values['M55320C20007']}==0
    Should Be True    ${counter_values['M55320C20008']}==0
    Should Be True    ${counter_values['M55320C20009']}==0
    Should Be True    ${counter_values['M55320C20010']}==0
    Should Be True    ${counter_values['M55320C20011']}==0

    install_and_download_tlda    ${TEST_LOG_DIRECTORY()}/c103_snapshot.zip
    tlda_analysis_snapshot    ${TEST_LOG_DIRECTORY()}/c103_snapshot.zip    ${TEST_LOG_DIRECTORY()}/TLDA_decode
    ${count_from_csv}    filter_and_count_by_minutes    ${TEST_LOG_DIRECTORY()}/TLDA_decode
    ${count_from_csv2}    filter_and_count_by_minutes    ${TEST_LOG_DIRECTORY()}/TLDA_decode
    ...    handle_min_58_59=False
    ${count_from_counter}    convert_timestamps_to_minutes
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-2']['PDCPQ']['M55352C02004']}
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['PDCP2']}
    ${result}    Run Keyword And Return Status    assert_common_parts_equal    ${count_from_csv}    ${count_from_counter}
    Run Keyword If    ${result}==False    assert_common_parts_equal    ${count_from_csv2}    ${count_from_counter}

Check Counters For CA111
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/06/06 14:34
    [Arguments]    ${M55352C02003}=1000    ${M55352C02004}=0    ${M55350C00024}=1000
    ...    ${M55159C00002}=1000    ${M55159C00010}=0    ${M55159C00012}=0    ${connection}=GNB_OAM
    coam.connect_to    name=${connection}
    ${counters}    coam.get_pm_counters
    ...    counter_ids=M55352C02003,M55352C02004,M55350C00024,M55159C00010,M55159C00012,M55159C00001,M55159C00002
    ...    connection=${connection}
    coam.teardown    connection=${connection}

    ${counter_values}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-1']['PDCPQ']}
    Should Be True    ${counter_values['M55352C02003']}==${M55352C02003}
    Should Be True    ${counter_values['M55352C02004']}==${M55352C02004}
    ${counter_values}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['PDCPC']}
    Should Be True    ${counter_values['M55350C00024']}==${M55350C00024}
    ${counter_values}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-1']['PDLTQ']}
    Should Be True    ${counter_values['M55159C00002']}==${M55159C00002}
    Should Be True    ${counter_values['M55159C00010']}==${M55159C00010}
    Should Be True    ${counter_values['M55159C00012']}==${M55159C00012}
    ${NR_2332a}    Evaluate    ${counter_values['M55159C00001']}/(1000*${counter_values['M55159C00002']})
    Should Be True    ${NR_2332a}<0.9

Check Counters For CA112
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/06/10 10:44
    [Arguments]    ${M55159C00003}=0    ${M55159C00010}=0    ${M55159C00011}=0    ${M55159C00012_max}=10
    ...    ${M55350C00025}=0    ${M55376C00006}=0    ${M55376C00007_max}=1000
    ...    ${M55362C00005_max}=1000    ${M55362C00006}=0
    ...    ${M55376C00007_add_M55159C00012}=1000    ${connection}=GNB_OAM
    ${tc112_counters}        Catenate    SEPARATOR=    M55159C00011,M55376C00006,M55362C00006,M55350C00037,M55159C00009,
    ...    M55362C00005,M55376C00007,M55362C00005,M55350C00025,M55159C00003,M55159C00010,M55159C00012
    coam.connect_to    name=${connection}
    ${counters}    coam.get_pm_counters    counter_ids=${tc112_counters}    connection=${connection}
    coam.teardown    connection=${connection}

    ${counter1_values}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-1']['F1UDP']}
    Should Be True    ${counter1_values['M55376C00006']}==${M55376C00006}
    Should Be True    ${counter1_values['M55376C00007']}<=${M55376C00007_max}
    ${counter2_values}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-1']['F1UPQ']}
    Should Be True    ${counter2_values['M55362C00005']}<=${M55362C00005_max}
    Should Be True    ${counter2_values['M55362C00006']}==${M55362C00006}
    ${counter3_values}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['PDCPC']}
    Should Be True    ${counter3_values['M55350C00025']}==${M55350C00025}
    ${counter4_values}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-1']['PDLTQ']}
    Should Be True    ${counter4_values['M55159C00003']}==${M55159C00003}
    Should Be True    ${counter4_values['M55159C00010']}==${M55159C00010}
    Should Be True    ${counter4_values['M55159C00011']}==${M55159C00011}
    Should Be True    ${counter4_values['M55159C00012']}<=${M55159C00012_max}
    Should Be True    ${counter1_values['M55376C00007']}==${counter2_values['M55362C00005']}
    Should Be True    ${counter1_values['M55376C00007']}+${counter4_values['M55159C00012']}==${M55376C00007_add_M55159C00012}

Check Counters And Snapshot For CA112
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/06/17 15:20
    [Arguments]    ${connection}=GNB_OAM
    coam.connect_to    name=${connection}
    ${counters}    coam.get_pm_counters    counter_ids=M55159C00012    connection=${connection}
    coam.collect_snapshot    target_file_name=${TEST_LOG_DIRECTORY()}/ca112_snapshot.zip    connection=${connection}
    coam.teardown    connection=${connection}

    install_and_download_tlda    ${TEST_LOG_DIRECTORY()}/ca112_snapshot.zip
    tlda_analysis_snapshot    ${TEST_LOG_DIRECTORY()}/ca112_snapshot.zip    ${TEST_LOG_DIRECTORY()}/TLDA_decode
    ${count_from_csv}    filter_and_count_by_minutes    ${TEST_LOG_DIRECTORY()}/TLDA_decode
    ${count_from_csv2}    filter_and_count_by_minutes    ${TEST_LOG_DIRECTORY()}/TLDA_decode
    ...    handle_min_58_59=False
    ${count_from_counter}    convert_timestamps_to_minutes
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-1']['PDLTQ']['M55159C00012']}
    ${result}    Run Keyword And Return Status    assert_common_parts_equal_handle_5min    ${count_from_csv}    ${count_from_counter}
    Run Keyword If    ${result}==False    assert_common_parts_equal_handle_5min    ${count_from_csv2}    ${count_from_counter}

Check Counters For CA114 Step1
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/06/17 15:58
    [Arguments]    ${connection}=GNB_OAM
    ${tc114_counters}        Catenate    SEPARATOR=    M55310C00007,M55310C00015,M55158C00009,M55158C00017,M55158C00018,
    ...    M55158C00019,M55158C00020,M55158C00021,M55158C00029
    coam.connect_to    name=${connection}
    ${counters}    coam.get_pm_counters    counter_ids=${tc114_counters}    connection=${connection}
    coam.teardown    connection=${connection}

    ${counter1_values}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NLRLC']}
    Should Be True    ${counter1_values['M55310C00007']}==${counter1_values['M55310C00015']}
    ${c}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-1']['HRLTQ']}
    Should Be True    ${c['M55158C00009']}==${c['M55158C00017']}
    Should Be True    ${c['M55158C00009']}==${counter1_values['M55310C00007']}
    Should Be True    ${c['M55158C00018']}==0
    Should Be True    ${c['M55158C00019']}==0
    ${delay}    Evaluate    ${c['M55158C00021']}/(1000*${c['M55158C00029']})
    ${dl_per}    Evaluate    (${c['M55158C00018']}+${c['M55158C00019']})/(${c['M55158C00018']}+${c['M55158C00019']}+${c['M55158C00020']})
    Should Be True    ${delay} < 5
    Should Be True    ${dl_per} < 0.0001
    [Return]    ${delay}

Check Counters For CA114 Step2
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/06/17 15:58
    [Arguments]    ${delay1}    ${connection}=GNB_OAM
    ${tc114_counters}        Catenate    SEPARATOR=    M55310C00007,M55310C00015,M55158C00009,M55158C00017,M55158C00018,
    ...    M55158C00019,M55158C00020,M55158C00021,M55158C00029
    coam.connect_to    name=${connection}
    ${counters}    coam.get_pm_counters    counter_ids=${tc114_counters}    connection=${connection}
    coam.teardown    connection=${connection}

    ${counter1_values}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NLRLC']}
    Should Be True    ${counter1_values['M55310C00015']}<${counter1_values['M55310C00007']}
    ${c}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-1']['HRLTQ']}
    Should Be True    ${c['M55158C00017']}<${c['M55158C00009']}
    Should Be True    ${c['M55158C00018']}>0
    Should Be True    ${c['M55158C00019']}>0
    ${delay2}    Evaluate    ${c['M55158C00021']}/(1000*${c['M55158C00029']})
    ${dl_per}    Evaluate    (${c['M55158C00018']}+${c['M55158C00019']})/(${c['M55158C00018']}+${c['M55158C00019']}+${c['M55158C00020']})
    Should Be True    ${delay2} > ${delay1}
    Should Be True    ${dl_per} > 0.0001

Check Counters For CA119
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/06/27 14:06
    [Arguments]    ${connection}=GNB_OAM
    ${tc119_counters}        Catenate    SEPARATOR=    M55310C00013,M55158C00015,M55310C00009,M55158C00011,M55362C00001,
    ...    M55352C02001,M55350C00028,M55159C00006,M55362C00002,M55352C02002,M55159C00013,
    ...    M55159C00015,M55159C00014,M55159C00024,M55159C00016,
    ...    M55310C00012,M55158C00014,M55310C00008,M55158C00010,M55350C00027,M55159C00005
    coam.connect_to    name=${connection}
    ${counters}    coam.get_pm_counters    counter_ids=${tc119_counters}    connection=${connection}
    coam.teardown    connection=${connection}

    ${c1}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NLRLC']}
    Should Be True    ${c1['M55310C00008']}>0
    Should Be True    ${c1['M55310C00009']}>=2500
    Should Be True    ${c1['M55310C00012']}>0
    Should Be True    ${c1['M55310C00013']}>2500

    ${c2}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-1']['F1UPQ']}
    Should Be True    ${c2['M55362C00001']}>=2500
    Should Be True    ${c2['M55362C00002']}==0

    ${c3}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-1']['HRLTQ']}
    Should Be True    ${c3['M55158C00010']}>0
    Should Be True    ${c3['M55158C00011']}>=2500
    Should Be True    ${c3['M55158C00014']}>0
    Should Be True    ${c3['M55158C00015']}>2500
    ${M55310C00012_M55158C00014}=    Is Values Close    ${c1['M55310C00012']}    ${c3['M55158C00014']}
    Should Be True    ${M55310C00012_M55158C00014}
    ${M55310C00008_M55158C00010}=    Is Values Close    ${c1['M55310C00008']}    ${c3['M55158C00010']}
    Should Be True    ${M55310C00008_M55158C00010}

    ${c4}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-1']['PDCPQ']}
    Should Be True    ${c4['M55352C02001']}>=2500
    Should Be True    ${c4['M55352C02002']}==0

    ${c}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-1']['PDLTQ']}
    Should Be True    ${c['M55159C00005']}>0
    Should Be True    ${c['M55159C00006']}>=2500
    Should Be True    ${c['M55159C00013']}==0
    Should Be True    ${c['M55159C00014']}==0
    Should Be True    ${c['M55159C00015']}<=2500
    Should Be True    ${c['M55159C00024']}<=2500
    ${ul_per}    Evaluate    (${c['M55159C00013']}+${c['M55159C00014']})/(${c['M55159C00013']}+${c['M55159C00014']}+${c['M55159C00015']})
    Should Be True    ${ul_per}<0.0001
    ${ul_pdb}    Evaluate    ${c['M55159C00016']}/(1000*${c['M55159C00024']})
    Should Be True    ${ul_pdb}<5

    ${c5}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['PDCPC']}
    Should Be True    ${c5['M55350C00027']}>0
    Should Be True    ${c5['M55350C00028']}>=2500
    ${M55159C00005_M55350C00027}=    Is Values Close    ${c['M55159C00005']}    ${c5['M55350C00027']}
    Should Be True    ${M55159C00005_M55350C00027}

Check Counters For CA119 Step2
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/06/27 15:14
    [Arguments]    ${connection}=GNB_OAM
    ${tc119_counters}        Catenate    SEPARATOR=    M55159C00013,M55159C00014,M55159C00015,M55159C00024
    coam.connect_to    name=${connection}
    ${counters}    coam.get_pm_counters    counter_ids=${tc119_counters}    connection=${connection}
    coam.teardown    connection=${connection}

    ${c}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-1']['PDLTQ']}
    Should Be True    ${c['M55159C00013']}>0
    # Should Be True    ${c['M55159C00014']}>0
    Should Be True    ${c['M55159C00015']}<2500
    Should Be True    ${c['M55159C00024']}<2500
    ${ul_per}    Evaluate    (${c['M55159C00013']}+${c['M55159C00014']})/(${c['M55159C00013']}+${c['M55159C00014']}+${c['M55159C00015']})
    Should Be True    ${ul_per}>0.0001

Check Counters For F202
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/06/13 15:19
    [Arguments]    ${connection}=GNB_OAM
    ${f202_counters}        Catenate    SEPARATOR=    M55125C08501,M55163C00001,M55163C02000,M55138C01001,M55138C01002,
    ...    M55138C00075,M55139C00034,M55139C00502,M55139C00035,M55125C08502,M55163C00002
    coam.connect_to    name=${connection}
    ${counters}    coam.get_pm_counters    counter_ids=${f202_counters}    connection=${connection}
    coam.teardown    connection=${connection}

    ${counter1_values}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NNGCC']}
    Should Be True    ${counter1_values['M55125C08501']}==3
    Should Be True    ${counter1_values['M55125C08502']}==1
    ${counter2_values}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-1']['NGCCQ']}
    Should Be True    ${counter2_values['M55163C00001']}==3
    Should Be True    ${counter2_values['M55163C02000']}==2
    Should Be True    ${counter2_values['M55163C00002']}==1
    ${counter3_values}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['RSACU']}
    Should Be True    ${counter3_values['M55138C01001']}==1
    Should Be True    ${counter3_values['M55138C01002']}==1
    Should Be True    ${counter3_values['M55138C00075']}==1
    ${counter4_values}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['RSADU']}
    Should Be True    ${counter4_values['M55139C00034']}==1
    Should Be True    ${counter4_values['M55139C00502']}==0
    Should Be True    ${counter4_values['M55139C00035']}==0
