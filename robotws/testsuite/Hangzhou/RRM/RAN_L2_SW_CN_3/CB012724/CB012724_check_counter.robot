# @Time    : 2025/8/20 10:20
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @Group   : NSB MN RAN RD VRF HAZ3 5
# @File    : CBO12724_check_counter.robot
# @Software: PyCharm
# @Doc     : Some Description
*** Settings ***
Documentation
...    Feature: NR Counters of Utilization and Quality Measurements
Resource    ../../RAN_L2_SW_CN_3/resources/VRF3_T05/internal_resource/internal_resource.robot
Resource    ../../RAN_L2_SW_CN_3/resources/sg10/internal_resource/internal_resource.robot

*** Keywords ***
Check Counters For B103
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/10/17 10:53
    [Arguments]    ${except_counters}    ${connection}=GNB_OAM
    wait_until_next_5_min    extra_sleep_time=60
    coam.connect_to    name=${connection}
    ${counters}    coam.get_pm_counters
    ...    counter_ids=M55363C00005,M55363C00006,M55363C00007,M55363C00008,M55363C00011,M55363C00012,M55308C00005,M55308C00015
    ...    connection=${connection}
    coam.teardown    connection=${connection}

    ${p12}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-12']['PTHPQ']}
    Should Be True    ${p12['M55363C00007']}>0
    Should Be True    ${p12['M55363C00008']}>0
    Should Be True    ${p12['M55363C00011']}>0
    Should Be True    ${p12['M55363C00012']}>0
    ${p3}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-3']['PTHPQ']}
    Should Be True    ${p3['M55363C00007']}>0
    Should Be True    ${p3['M55363C00008']}>0
    ${p16}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-16']['PTHPQ']}
    Should Be True    ${p16['M55363C00007']}>0
    Should Be True    ${p16['M55363C00008']}>0
    ${p37}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-37']['PTHPQ']}
    Should Be True    ${p16['M55363C00005']}>${p37['M55363C00005']}
    Should Be True    ${p37['M55363C00007']}>0
    Should Be True    ${p37['M55363C00008']}>0

    ${NCELA}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NCELA']}
    ${M55363C00006_except}    Evaluate    ${NCELA['M55308C00005']}+${NCELA['M55308C00015']}
    Should Be True    ${M55363C00006_except}==${p37['M55363C00006']}

    Should Be Equal As Numbers    ${except_counters["NRPMQAP-3"]}    ${p3['M55363C00005']}
    Should Be Equal As Numbers    ${except_counters["NRPMQAP-12"]}    ${p12['M55363C00005']}
    Should Be Equal As Numbers    ${except_counters["NRPMQAP-16"]}    ${p16['M55363C00005']}
    Should Be Equal As Numbers    ${except_counters["NRPMQAP-37"]}    ${p37['M55363C00005']}

Check Counters For B106
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/09/24 11:24
    [Arguments]    ${except_counters}    ${connection}=GNB_OAM
    wait_until_next_5_min    extra_sleep_time=60
    coam.connect_to    name=${connection}
    ${counters}    coam.get_pm_counters    counter_ids=M55363C00009,M55363C00010,M55308C00006,M55308C00010
    ...    connection=${connection}
    coam.teardown    connection=${connection}

    ${r1}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NCELA']}
    ${r2}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-12']['PTHPQ']}
    ${M55363C00010_except}    Evaluate    ${r1['M55308C00006']}+${r1['M55308C00010']}
    Should Be Equal As Numbers    ${M55363C00010_except}    ${r2['M55363C00010']}
    Should Be Equal As Numbers    ${except_counters["NRPMQAP-12"]}    ${M55363C00010_except}

    ${p3}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-3']['PTHPQ']}
    ${p16}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-16']['PTHPQ']}
    ${p37}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-37']['PTHPQ']}
    ${p38}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-38']['PTHPQ']}
    Should Be Equal As Numbers    ${except_counters["NRPMQAP-3"]}    ${p3['M55363C00009']}
    Should Be Equal As Numbers    ${except_counters["NRPMQAP-16"]}    ${p16['M55363C00009']}
    Should Be Equal As Numbers    ${except_counters["NRPMQAP-37"]}    ${p37['M55363C00009']}
    Should Be Equal As Numbers    ${except_counters["NRPMQAP-38"]}    ${p38['M55363C00009']}

Check Counters For B108
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/09/30 11:02
    [Arguments]    ${except_counters}    ${connection}=GNB_OAM
    wait_until_next_5_min    extra_sleep_time=60
    coam.connect_to    name=${connection}
    ${counters}    coam.get_pm_counters    counter_ids=M55363C00011,M55363C00012
    ...    connection=${connection}
    coam.teardown    connection=${connection}

    ${p22}    Get Recent Multi Counters Value        ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-11']['NRPMQAP-22']['PTHPQ']}
    ${p4}    Get Recent Multi Counters Value        ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-11']['NRPMQAP-4']['PTHPQ']}
    Should Be Equal As Numbers    ${except_counters["NRPMQAP-22"]}    ${p22['M55363C00011']}
    Should Be Equal As Numbers    2    ${p22['M55363C00012']}
    Should Be Equal As Numbers    ${except_counters["NRPMQAP-4"]}    ${p4['M55363C00011']}
    Should Be Equal As Numbers    3    ${p4['M55363C00012']}

Check Counters For D202
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/10/22 10:23
    [Arguments]    ${connection}=GNB_OAM
    wait_until_next_5_min    extra_sleep_time=60
    coam.connect_to    name=${connection}
    ${counters}    coam.get_pm_counters
    ...    counter_ids=M55207C00005,M55207C00006,M55207C00007
    ...    connection=${connection}
    coam.teardown    connection=${connection}

    ${r}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['BBPOOL-11']['BBPOL']}
    Should Be True    ${r['M55207C00005']}==5
    Should Be True    ${r['M55207C00006']}==2
    Should Be True    ${r['M55207C00007']}==5
    ${r2}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['BBPOOL-12']['BBPOL']}
    Should Be True    ${r2['M55207C00005']}==1
    Should Be True    ${r2['M55207C00006']}==0
    Should Be True    ${r2['M55207C00007']}==0
    ${r3}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['BBPOOL-22']['BBPOL']}
    Should Be True    ${r3['M55207C00005']}==1
    Should Be True    ${r3['M55207C00006']}==1
    Should Be True    ${r3['M55207C00007']}==2

Check Counters For D204
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/09/29 17:30
    [Arguments]   ${BBPOOL1_M55207C00005}=14    ${BBPOOL2_M55207C00005}=0
    ...    ${BBPOOL1_M55207C00006}=2    ${BBPOOL2_M55207C00006}=0
    ...    ${BBPOOL1_M55207C00007}=14    ${BBPOOL2_M55207C00007}=0    ${connection}=GNB_OAM
    wait_until_next_5_min    extra_sleep_time=60
    coam.connect_to    name=${connection}
    ${counters}    coam.get_pm_counters    counter_ids=M55207C00005,M55207C00006,M55207C00007
    ...    connection=${connection}
    coam.teardown    connection=${connection}

    ${r}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['BBPOOL-11']['BBPOL']}
    Should Be True    ${r['M55207C00005']}==${BBPOOL1_M55207C00005}
    Should Be True    ${r['M55207C00006']}==${BBPOOL1_M55207C00006}
    Should Be True    ${r['M55207C00007']}==${BBPOOL1_M55207C00007}
    ${r2}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['BBPOOL-21']['BBPOL']}
    Should Be True    ${r2['M55207C00005']}==${BBPOOL2_M55207C00005}
    Should Be True    ${r2['M55207C00006']}==${BBPOOL2_M55207C00006}
    Should Be True    ${r2['M55207C00007']}==${BBPOOL2_M55207C00007}

Check Counters For H304
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/09/16 11:28
    [Arguments]    ${M55335C00034}    ${M55335C00034_DTX}   ${connection}=GNB_OAM
    wait_until_next_5_min    extra_sleep_time=60
    ${h_304_counters}        Catenate    SEPARATOR=    M55335C00033,M55335C00034,M55335C00001,M55335C00002,
    ...    M55335C00003,M55335C00004,M55335C00005,M55365C00001,M55365C00002,M55365C00003,M55365C00004,
    ...    M55335C03001,M55335C03002,M55335C03003,M55335C03004,M55335C03005,
    ...    M55365C03001,M55365C03002,M55365C03003,M55365C03004
    coam.connect_to    name=${connection}
    ${counters}    coam.get_pm_counters    counter_ids=${h_304_counters}
    ...    connection=${connection}
    coam.teardown    connection=${connection}

    # Checkponit2: UL_grant and ack for bwp0 both equal 0.
    ${r}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-11']['PDCCH']}
    Should Be True    ${r['M55335C00001']}==0
    Should Be True    ${r['M55335C00002']}==0
    Should Be True    ${r['M55335C00003']}==0
    Should Be True    ${r['M55335C00004']}==0
    Should Be True    ${r['M55335C00005']}==0
    Should Be True    ${r['M55335C00033']}==0
    ${r2}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-11']['PDCCH2']}
    Should Be True    ${r2['M55365C00001']}==0
    Should Be True    ${r2['M55365C00002']}==0
    Should Be True    ${r2['M55365C00003']}==0
    Should Be True    ${r2['M55365C00004']}==0
    # Sum the legacy counters, UL_GRANT_AL1_CBWP1 to  UL_GRANT_AL16_CBWP1, UL_GRANT_HR_AL1_CBWP1 - UL_GRANT_HR_AL8_CBWP1
    # Compare with the UL_GRANT_ACK_CBWP1
    ${except}    Evaluate    ${r['M55335C03002']}+${r['M55335C03003']}+${r2['M55365C03002']}+${r2['M55365C03003']}+${r2['M55365C03004']}
    Should Be True    ${except}==${M55335C00034_DTX}
    Should Be True    ${M55335C00034}==${r['M55335C00034']}

Check Counters For H310
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/09/17 14:54
    [Arguments]    ${M55335C00034}    ${M55335C03003}
    ...    ${M55335C00043_44}    ${M55335C03008}    ${connection}=GNB_OAM
    wait_until_next_5_min    extra_sleep_time=60
    coam.connect_to    name=${connection}
    ${counters}    coam.get_pm_counters    counter_ids=M55335C00043,M55335C00044,M55335C03008,M55335C00034,M55335C03003
    ...    connection=${connection}
    coam.teardown    connection=${connection}

    ${r}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['PDCCH']}
    assert_values_close    ${r['M55335C00034']}    ${M55335C00034}
    assert_values_close    ${r['M55335C03003']}    ${M55335C03003}
    assert_values_close    ${r['M55335C00044']}    ${M55335C00043_44}
    assert_values_close    ${r['M55335C03008']}    ${M55335C03008}

Check Counters For H312
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/08/20 10:02
    [Arguments]    ${M55335C00066}    ${M55335C10001}    ${connection}=GNB_OAM
    wait_until_next_5_min    extra_sleep_time=60
    ${h_312_counters}        Catenate    SEPARATOR=    M55335C00063,M55335C00064,M55335C00065,M55335C00066,
    ...    M55335C00067,M55335C00068,M55335C00069,M55335C00070,M55335C00071,M55335C00072,M55335C10001,
    ...    M55335C01001,M55335C04001,M55335C07001,M55335C13001,M55335C16001,M55335C19001,
    ...    M55335C22001,M55335C25001,M55335C28001
    coam.connect_to    name=${connection}
    ${counters}    coam.get_pm_counters    counter_ids=${h_312_counters}
    ...    connection=${connection}
    coam.teardown    connection=${connection}
    ${counter_values}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['PDCCH']}
    Should Be True    ${counter_values['M55335C00066']}==${M55335C00066}
    Should Be True    ${counter_values['M55335C10001']}==${M55335C10001}
    Should Be True    ${counter_values['M55335C10001']}>${counter_values['M55335C00066']}
    Should Be True    ${counter_values['M55335C00063']}==0
    Should Be True    ${counter_values['M55335C00064']}==0
    Should Be True    ${counter_values['M55335C00065']}==0
    Should Be True    ${counter_values['M55335C00067']}==0
    Should Be True    ${counter_values['M55335C00068']}==0
    Should Be True    ${counter_values['M55335C00069']}==0
    Should Be True    ${counter_values['M55335C00070']}==0
    Should Be True    ${counter_values['M55335C00071']}==0
    Should Be True    ${counter_values['M55335C00072']}==0
    Should Be True    ${counter_values['M55335C01001']}==0
    Should Be True    ${counter_values['M55335C04001']}==0
    Should Be True    ${counter_values['M55335C07001']}==0
    Should Be True    ${counter_values['M55335C13001']}==0
    Should Be True    ${counter_values['M55335C16001']}==0
    Should Be True    ${counter_values['M55335C19001']}==0
    Should Be True    ${counter_values['M55335C22001']}==0
    Should Be True    ${counter_values['M55335C25001']}==0
    Should Be True    ${counter_values['M55335C28001']}==0
