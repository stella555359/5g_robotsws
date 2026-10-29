# @Time    : 2025/8/6 15:19
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @Group   : NSB MN RAN RD VRF HAZ3 5
# @File    : CB012238_common.robot
# @Software: PyCharm
# @Doc     : Some Description
*** Settings ***
Documentation
...    author: Chen Jian
...    Contact: jian.1.chen@nokia-sbell.com
Resource    ../../RAN_L2_SW_CN_3/resources/VRF3_T05/internal_resource/internal_resource.robot
Resource    ../../RAN_L2_SW_CN_3/resources/sg10/internal_resource/internal_resource.robot

*** Keywords ***
Batch Execute UE Traffic 002 006
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/08/06 14:08
    [Arguments]    ${start_ue}    ${end_ue}    ${nwslice}=1    ${trf_id}=1    ${mbps}=10
    FOR    ${ue_id}    IN RANGE    ${start_ue}    ${end_ue}+1
        airphone_execute_egate_command    ue_register id\=${ue_id}
        Sleep    1s
        airphone_execute_egate_command    ue_pdu_session_setup pdu\=1 ue\=${ue_id} nwslice\=${nwslice}
        Sleep    1s
        airphone_execute_egate_command    trf_data_start ue\=${ue_id} pdu\=1 qfi\=1 trf_id\=${trf_id} dir\=dl mbps\=${mbps}
        Sleep    1s
    END

Batch Execute UE Traffic 003 007
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/08/06 10:44
    [Arguments]    ${start_ue}    ${end_ue}    ${spid}=5    ${mbps}=10
    FOR    ${ue_id}    IN RANGE    ${start_ue}    ${end_ue}+1
        airphone_execute_egate_command    ue_attach id\=${ue_id} profile\=1
        Sleep    1s
        airphone_execute_egate_command    ue_enb_param id\=${ue_id} spid\=${spid}
        Sleep    1s
        airphone_execute_egate_command    ue_dc_enb_start ue\=${ue_id} target_gnb\=2 target_cells\=1 bearer\=2 type\=split_scg
        Sleep    1s
        airphone_execute_egate_command    trf_data_start id\=2 ue\=${ue_id} dir\=dl mbps\=${mbps} trf_id\=1
        Sleep    1s
    END

A003 007 Common Step
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/08/06 10:44
    [Arguments]    ${G2_except}    ${G3_except}    ${connection}=GNB_OAM
    Batch Execute UE Traffic 003 007    start_ue=61    end_ue=65    spid=5    mbps=110
    Batch Execute UE Traffic 003 007    start_ue=66    end_ue=70    spid=6    mbps=10
    Batch Execute UE Traffic 003 007    start_ue=71    end_ue=75    spid=11    mbps=110
    Batch Execute UE Traffic 003 007    start_ue=76    end_ue=120    spid=11    mbps=10
    Sleep    200s

    coam.connect_to    name=${connection}
    ${counters}    coam.get_pm_counters    counter_ids=${A_COUNTERS}
    ...    connection=${connection}
    coam.teardown    connection=${connection}
    ${G2}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRRESOURCEGROUP-2']['NCUPNRG']}
    ${G3}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRRESOURCEGROUP-3']['NCUPNRG']}
    ${sum_prb}    Evaluate    ${G2['M55910C00001']} + ${G3['M55910C00001']}
    ${G2_actual}    Evaluate    ${G2['M55910C00001']}/${sum_prb}*100
    ${G3_actual}    Evaluate    ${G3['M55910C00001']}/${sum_prb}*100

    assert_values_close    ${G2_actual}    ${G2_except}
    assert_values_close    ${G3_actual}    ${G3_except}

A003 007 Need Retry
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/08/06 15:21
    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'before_onair' file
    Prepare gnb onair

    A003 007 Common Step    G2_except=${A003_A007_STEP1_G2_EXCEPT}    G3_except=${A003_A007_STEP1_G3_EXCEPT}

    COAM.Setup Admin
    COAM.perform_delta_recommissioning    delta_file=${CURDIR}/003_007_modify_minquota.json
    COAM.Teardown Admin

    A003 007 Common Step    G2_except=${A003_A007_STEP2_G2_EXCEPT}    G3_except=${A003_A007_STEP2_G3_EXCEPT}

A002 006 Common Step
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/08/06 14:07
    [Arguments]    ${G1_except}    ${G9_except}    ${connection}=GNB_OAM
    Batch Execute UE Traffic 002 006    start_ue=1    end_ue=5    nwslice=1    mbps=100
    Batch Execute UE Traffic 002 006    start_ue=6    end_ue=10    nwslice=1    mbps=20
    Batch Execute UE Traffic 002 006    start_ue=11    end_ue=20    nwslice=9    mbps=100
    Sleep    200s

    coam.connect_to    name=${connection}
    ${counters}    coam.get_pm_counters    counter_ids=${A_COUNTERS}
    ...    connection=${connection}
    coam.teardown    connection=${connection}
    ${G1}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRRESOURCEGROUP-1']['NCUPNRG']}
    ${G9}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRRESOURCEGROUP-9']['NCUPNRG']}
    ${sum_prb}    Evaluate    ${G1['M55910C00001']} + ${G9['M55910C00001']}
    ${G1_actual}    Evaluate    ${G1['M55910C00001']}/${sum_prb}*100
    ${G9_actual}    Evaluate    ${G9['M55910C00001']}/${sum_prb}*100

    assert_values_close    ${G1_actual}    ${G1_except}
    assert_values_close    ${G9_actual}    ${G9_except}

A002 006 Need Retry
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/08/06 15:21
    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'before_onair' file
    Prepare gnb onair

    A002 006 Common Step    G1_except=${A002_A006_STEP1_G1_EXCEPT}    G9_except=${A002_A006_STEP1_G9_EXCEPT}

    COAM.Setup Admin
    COAM.perform_delta_recommissioning    delta_file=${CURDIR}/002_006_modify_minquota.json
    COAM.Teardown Admin

    A002 006 Common Step    G1_except=${A002_A006_STEP2_G1_EXCEPT}    G9_except=${A002_A006_STEP2_G9_EXCEPT}

A015 Common Step
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/08/06 14:07
    [Arguments]    ${G1_except}    ${G9_except}    ${G18_except}    ${connection}=GNB_OAM
    airphone_execute_egate_command    script file\=${CONFIG_DIR_PATH}/${SW_BRANCH}/WTS/A_015_wts.lua
    Sleep    200s

    coam.connect_to    name=${connection}
    ${counters}    coam.get_pm_counters    counter_ids=${A_COUNTERS}
    ...    connection=${connection}
    coam.teardown    connection=${connection}
    ${G1}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-7']['NRRESOURCEGROUP-1']['NCUPNRG']}
    ${G9}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-7']['NRRESOURCEGROUP-9']['NCUPNRG']}
    ${G18}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-7']['NRRESOURCEGROUP-18']['NCUPNRG']}
    ${sum_prb}    Evaluate    ${G1['M55910C00001']} + ${G9['M55910C00001']} + ${G18['M55910C00001']}
    ${G1_actual}    Evaluate    ${G1['M55910C00001']}/${sum_prb}*100
    ${G9_actual}    Evaluate    ${G9['M55910C00001']}/${sum_prb}*100
    ${G18_actual}    Evaluate    ${G18['M55910C00001']}/${sum_prb}*100

    assert_values_close    ${G1_actual}    ${G1_except}
    assert_values_close    ${G9_actual}    ${G9_except}
    assert_values_close    ${G18_actual}    ${G18_except}

A015 Need Retry
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/08/06 15:21
    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'before_onair' file
    Prepare gnb onair

    A015 Common Step    G1_except=${A015_STEP1_G1_EXCEPT}    G9_except=${A015_STEP1_G9_EXCEPT}
    ...    G18_except=${A015_STEP1_G18_EXCEPT}

    COAM.Setup Admin
    COAM.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1    parameter=actSliceAwareSchQosFairness
    ...    operation=update    value=true
    COAM.Teardown Admin

    A015 Common Step    G1_except=${A015_STEP2_G1_EXCEPT}    G9_except=${A015_STEP2_G9_EXCEPT}
    ...    G18_except=${A015_STEP2_G18_EXCEPT}

A021 Common Step
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/10/09 17:30
    [Arguments]    ${G1_except}    ${G9_except}    ${G18_except}    ${connection}=GNB_OAM
    Batch Execute UE Traffic 002 006    start_ue=1    end_ue=3    nwslice=1    mbps=110
    Batch Execute UE Traffic 002 006    start_ue=4    end_ue=10    nwslice=1    mbps=5
    Batch Execute UE Traffic 002 006    start_ue=11    end_ue=13    nwslice=9    mbps=110
    Batch Execute UE Traffic 002 006    start_ue=14    end_ue=20    nwslice=9    mbps=5
    Batch Execute UE Traffic 002 006    start_ue=21    end_ue=24    nwslice=18    trf_id=2    mbps=110
    Batch Execute UE Traffic 002 006    start_ue=25    end_ue=60    nwslice=18    trf_id=2    mbps=5
    Sleep    200s

    coam.connect_to    name=${connection}
    ${counters}    coam.get_pm_counters    counter_ids=${A_COUNTERS}
    ...    connection=${connection}
    coam.teardown    connection=${connection}
    ${G1}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRRESOURCEGROUP-1']['NCUPNRG']}
    ${G9}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRRESOURCEGROUP-9']['NCUPNRG']}
    ${G18}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRRESOURCEGROUP-18']['NCUPNRG']}
    ${sum_prb}    Evaluate    ${G1['M55910C00001']} + ${G9['M55910C00001']} + ${G18['M55910C00001']}
    ${G1_actual}    Evaluate    ${G1['M55910C00001']}/${sum_prb}*100
    ${G9_actual}    Evaluate    ${G9['M55910C00001']}/${sum_prb}*100
    ${G18_actual}    Evaluate    ${G18['M55910C00001']}/${sum_prb}*100

    assert_values_close    ${G1_actual}    ${G1_except}
    assert_values_close    ${G9_actual}    ${G9_except}
    assert_values_close    ${G18_actual}    ${G18_except}

    FOR    ${ue_id}    IN RANGE    1    61
        airphone_execute_egate_command    ue_deregister id\=${ue_id} ue_deregister_type\=switch_off
        Sleep    1s
    END

A021 Common Step2
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/10/09 17:30
    [Arguments]    ${G1_except}    ${G9_except}    ${G18_except}    ${connection}=GNB_OAM
    Batch Execute UE Traffic 002 006    start_ue=1    end_ue=1    nwslice=1    mbps=110
    Batch Execute UE Traffic 002 006    start_ue=11    end_ue=15    nwslice=9    mbps=110
    Batch Execute UE Traffic 002 006    start_ue=16    end_ue=60    nwslice=9    mbps=5
    Sleep    200s

    coam.connect_to    name=${connection}
    ${counters}    coam.get_pm_counters    counter_ids=${A_COUNTERS}
    ...    connection=${connection}
    coam.teardown    connection=${connection}
    ${G1}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRRESOURCEGROUP-1']['NCUPNRG']}
    ${G9}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRRESOURCEGROUP-9']['NCUPNRG']}
    ${G18}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRRESOURCEGROUP-18']['NCUPNRG']}
    ${sum_prb}    Evaluate    ${G1['M55910C00001']} + ${G9['M55910C00001']} + ${G18['M55910C00001']}
    ${G1_actual}    Evaluate    ${G1['M55910C00001']}/${sum_prb}*100
    ${G9_actual}    Evaluate    ${G9['M55910C00001']}/${sum_prb}*100

    assert_values_close    ${G1_actual}    ${G1_except}
    assert_values_close    ${G9_actual}    ${G9_except}
    Should Be True    ${G18['M55910C00001']}==${G18_except}

    airphone_execute_egate_command    ue_deregister id\=1 ue_deregister_type\=switch_off
    FOR    ${ue_id}    IN RANGE    11    61
        airphone_execute_egate_command    ue_deregister id\=${ue_id} ue_deregister_type\=switch_off
        Sleep    1s
    END

A021 Need Retry
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/10/09 17:29
    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'before_onair' file
    Prepare gnb onair

    A021 Common Step    G1_except=${A021_STEP1_G1_EXCEPT}    G9_except=${A021_STEP1_G9_EXCEPT}
    ...    G18_except=${A021_STEP1_G18_EXCEPT}

    COAM.Setup Admin
    COAM.perform_delta_recommissioning    delta_file=${CURDIR}/021_delete_group.json
    COAM.Teardown Admin

    A021 Common Step    G1_except=${A021_STEP1_G1_EXCEPT}    G9_except=${A021_STEP1_G9_EXCEPT}
    ...    G18_except=${A021_STEP1_G18_EXCEPT}

    A021 Common Step2    G1_except=${A021_STEP4_G1_EXCEPT}    G9_except=${A021_STEP4_G9_EXCEPT}
    ...    G18_except=${A021_STEP4_G18_EXCEPT}

    COAM.Setup Admin
    COAM.perform_delta_recommissioning    delta_file=${CURDIR}/021_modify_minquota.json
    COAM.Teardown Admin

    A021 Common Step    G1_except=${A021_STEP2_G1_EXCEPT}    G9_except=${A021_STEP2_G9_EXCEPT}
    ...    G18_except=${A021_STEP2_G18_EXCEPT}

A022 Common Step
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/10/09 17:30
    [Arguments]    ${G1_except}    ${G2_except}    ${G9_except}    ${G18_except}    ${G32_except}    ${connection}=GNB_OAM
    airphone_execute_egate_command    script file\=${CONFIG_DIR_PATH}/${SW_BRANCH}/WTS/A_022_wts.lua
    Sleep    200s

    coam.connect_to    name=${connection}
    ${counters}    coam.get_pm_counters    counter_ids=${A_COUNTERS}
    ...    connection=${connection}
    coam.teardown    connection=${connection}
    ${G1}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-7']['NRRESOURCEGROUP-1']['NCUPNRG']}
    ${G2}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-7']['NRRESOURCEGROUP-2']['NCUPNRG']}
    ${G9}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-7']['NRRESOURCEGROUP-9']['NCUPNRG']}
    ${G18}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-7']['NRRESOURCEGROUP-18']['NCUPNRG']}
    ${G32}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-7']['NRRESOURCEGROUP-32']['NCUPNRG']}
    ${sum_prb}    Evaluate    ${G1['M55910C00001']} + ${G2['M55910C00001']} + ${G9['M55910C00001']}
    ${sum_prb}    Evaluate     ${sum_prb} + ${G18['M55910C00001']} + ${G32['M55910C00001']}
    ${G1_actual}    Evaluate    ${G1['M55910C00001']}/${sum_prb}*100
    ${G9_actual}    Evaluate    ${G9['M55910C00001']}/${sum_prb}*100
    ${G18_actual}    Evaluate    ${G18['M55910C00001']}/${sum_prb}*100
    ${G32_actual}    Evaluate    ${G32['M55910C00001']}/${sum_prb}*100

    assert_values_close    ${G1_actual}    ${G1_except}
    Should Be True    ${G2['M55910C00001']}==${G2_except}
    assert_values_close    ${G9_actual}    ${G9_except}
    assert_values_close    ${G18_actual}    ${G18_except}
    assert_values_close    ${G32_actual}    ${G32_except}

    FOR    ${ue_id}    IN RANGE    1    11
        airphone_execute_egate_command    trf_data_stop id\=${ue_id}
        Sleep    1s
    END

A022 Need Retry
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/10/09 17:29
    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'before_onair' file
    Prepare gnb onair

    A022 Common Step    G1_except=${A022_STEP1_G1_EXCEPT}    G2_except=${A022_STEP1_G2_EXCEPT}    G9_except=${A022_STEP1_G9_EXCEPT}
    ...    G18_except=${A022_STEP1_G18_EXCEPT}    G32_except=${A022_STEP1_G32_EXCEPT}

    COAM.Setup Admin
    COAM.perform_delta_recommissioning    delta_file=${CURDIR}/022_modify_minquota.json
    COAM.Teardown Admin

    A022 Common Step    G1_except=${A022_STEP2_G1_EXCEPT}    G2_except=${A022_STEP2_G2_EXCEPT}    G9_except=${A022_STEP2_G9_EXCEPT}
    ...    G18_except=${A022_STEP2_G18_EXCEPT}    G32_except=${A022_STEP2_G32_EXCEPT}

A018 Check Counters
    [Arguments]    ${G1_expect}    ${G9_expect}    ${connection}=GNB_OAM
    Sleep    200s
    coam.connect_to    name=${connection}
    ${counters}    coam.get_pm_counters    counter_ids=${A_COUNTERS}    connection=${connection}
    coam.teardown    connection=${connection}
    ${G1}    Get Recent Multi Counters Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRRESOURCEGROUP-1']['NCUPNRG']}
    ${G9}    Get Recent Multi Counters Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRRESOURCEGROUP-9']['NCUPNRG']}
    ${sum_prb}    Evaluate    ${G1['M55910C00001']} + ${G9['M55910C00001']}
    ${G1_actual}    Evaluate    ${G1['M55910C00001']}/${sum_prb}*100
    ${G9_actual}    Evaluate    ${G9['M55910C00001']}/${sum_prb}*100
    assert_values_close    ${G1_actual}    ${G1_expect}
    assert_values_close    ${G9_actual}    ${G9_expect}
    Should Be True    ${G1['M55910C00002']}>0
    Should Be True    ${G9['M55910C00002']}>0
    ${DL_PRB}    Get Recent Multi Counters Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NCELA']}
    ${PRB_Utilization}    Evaluate    ${sum_prb}/${DL_PRB['M55308C10013']}*100
    Should Be True    ${PRB_Utilization}>85

A018 Need Retry
    Modify actSliceAwareSchQosFairness    value=false
    MultiUE Attach And Run DL Traffic
    A018 Check Counters    G1_expect=${A018_STEP1_G1_EXPECT}    G9_expect=${A018_STEP1_G9_EXPECT}
    Modify actSliceAwareSchQosFairness    value=true
    A018 Check Counters    G1_expect=${A018_STEP2_G1_EXPECT}    G9_expect=${A018_STEP2_G9_EXPECT}
    Airphone SA Detach    1
    Airphone SA Detach    2

Modify actSliceAwareSchQosFairness
    [Arguments]    ${value}=false
    COAM.Setup Admin
    COAM.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1    parameter=actSliceAwareSchQosFairness
    ...    operation=update    value=${value}
    COAM.Teardown Admin

MultiUE Attach And Run DL Traffic
    SA Register UE    UE_ID=1    nwslice=1
    SA Register UE    UE_ID=2    nwslice=9
    Wait '1s' for stabible
    Airphone SA Start Data Traffic    1...2    DL    110M    trf_id=1    pdu_id=1    duration=${2400}
    Wait '5s' for stabible

SA Register UE
    [Arguments]    ${UE_ID}=1    ${nwslice}=1
    Airphone SA Attach    ue_id=${UE_ID}
    Airphone Set Traffic Type    ${UE_ID}    1    internal
    Airphone Pdu Session Setup   ${UE_ID}    1    ${nwslice}    ${UE_ID}
    Wait '2s' for stabible

E038 Common Step
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/09/05 11:07
    [Arguments]    ${G1_UL_except}    ${G1_DL_except}    ${G9_UL_except}    ${G9_DL_except}
    ...    ${G18_UL_except}    ${G18_DL_except}    ${connection}=GNB_OAM
    Sleep    300s
    airphone_execute_egate_command    script file\=${CONFIG_DIR_PATH}/${SW_BRANCH}/WTS/E_038_wts.lua
    Sleep    180s

    coam.connect_to    name=${connection}
    ${counters}    coam.get_pm_counters    counter_ids=${E_COUNTERS}
    ...    connection=${connection}
    coam.teardown    connection=${connection}
    ${G1}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRRESOURCEGROUP-1']['NCUPNRG']}
    ${G9}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRRESOURCEGROUP-9']['NCUPNRG']}
    ${G18}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRRESOURCEGROUP-18']['NCUPNRG']}
    ${sum_dl_prb}    Evaluate    ${G1['M55910C00001']} + ${G9['M55910C00001']} + ${G18['M55910C00001']}
    ${G1_DL_actual}    Evaluate    ${G1['M55910C00001']}/${sum_dl_prb}*100
    ${G9_DL_actual}    Evaluate    ${G9['M55910C00001']}/${sum_dl_prb}*100
    ${G18_DL_actual}    Evaluate    ${G18['M55910C00001']}/${sum_dl_prb}*100
    assert_values_close    ${G1_DL_actual}    ${G1_DL_except}
    assert_values_close    ${G9_DL_actual}    ${G9_DL_except}
    assert_values_close    ${G18_DL_actual}    ${G18_DL_except}

    ${sum_ul_prb}    Evaluate    ${G1['M55910C00003']} + ${G9['M55910C00003']} + ${G18['M55910C00003']}
    ${G1_UL_actual}    Evaluate    ${G1['M55910C00003']}/${sum_ul_prb}*100
    ${G9_UL_actual}    Evaluate    ${G9['M55910C00003']}/${sum_ul_prb}*100
    ${G18_UL_actual}    Evaluate    ${G18['M55910C00003']}/${sum_ul_prb}*100
    assert_values_close    ${G1_UL_actual}    ${G1_UL_except}
    assert_values_close    ${G9_UL_actual}    ${G9_UL_except}
    assert_values_close    ${G18_UL_actual}    ${G18_UL_except}
    airphone_execute_egate_command    script file\=${CONFIG_DIR_PATH}/${SW_BRANCH}/WTS/E_038_wts2.lua

E038 Need Retry
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/09/05 15:21
    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'before_onair' file
    Prepare gnb onair

    E038 Common Step    G1_UL_except=${E038_STEP1_UL_G1_EXCEPT}    G1_DL_except=${E038_STEP1_DL_G1_EXCEPT}
    ...    G9_UL_except=${E038_STEP1_UL_G9_EXCEPT}    G9_DL_except=${E038_STEP1_DL_G9_EXCEPT}
    ...    G18_UL_except=${E038_STEP1_UL_G18_EXCEPT}    G18_DL_except=${E038_STEP1_DL_G18_EXCEPT}

    COAM.Setup Admin
    COAM.perform_delta_recommissioning    delta_file=${CURDIR}/038_modify_minquota.json
    COAM.Teardown Admin

    E038 Common Step    G1_UL_except=${E038_STEP2_UL_G1_EXCEPT}    G1_DL_except=${E038_STEP2_DL_G1_EXCEPT}
    ...    G9_UL_except=${E038_STEP2_UL_G9_EXCEPT}    G9_DL_except=${E038_STEP2_DL_G9_EXCEPT}
    ...    G18_UL_except=${E038_STEP2_UL_G18_EXCEPT}    G18_DL_except=${E038_STEP2_DL_G18_EXCEPT}

A009 Need Retry
    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'before_onair' file
    Prepare gnb onair
    Airphone Cleanup Egate Console Log
    A009 UE Attach And Run Traffic
    A018 Check Counters    G1_expect=${A009_STEP1_G1_EXPECT}    G9_expect=${A009_STEP1_G9_EXPECT}
    MultiUE Detach
    Modify nrDrbDN
    A009 UE Attach And Run Traffic
    A018 Check Counters    G1_expect=${A009_STEP2_G1_EXPECT}    G9_expect=${A009_STEP2_G9_EXPECT}
    MultiUE Detach

A009 UE Attach And Run Traffic
    Airphone SA Attach    ue_id=1
    Airphone Execute Egate Command    set_pdu_param ue\=1 pdu\=1 trf_type\=internal default_qos_flow\=5
    Airphone Pdu Session Setup   1    1    1    1
    Airphone SA Attach    ue_id=2
    Airphone Execute Egate Command    set_pdu_param ue\=2 pdu\=1 trf_type\=internal default_qos_flow\=5
    Airphone Pdu Session Setup   2    1    1    1
    SA Register UE    UE_ID=3    nwslice=2
    SA Register UE    UE_ID=4    nwslice=2
    Airphone SA Start Data Traffic    1...4    DL    80M    trf_id=1    pdu_id=1    duration=${2400}

A010 Check Counters
    [Arguments]    ${G1_expect}    ${G9_expect}    ${G18_expect}    ${close}=${True}    ${connection}=GNB_OAM
    Sleep    200s
    coam.connect_to    name=${connection}
    ${counters}    coam.get_pm_counters    counter_ids=${A_COUNTERS}    connection=${connection}
    coam.teardown    connection=${connection}
    ${G1}    Get Recent Multi Counters Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRRESOURCEGROUP-1']['NCUPNRG']}
    ${G9}    Get Recent Multi Counters Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRRESOURCEGROUP-9']['NCUPNRG']}
    ${G18}    Get Recent Multi Counters Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRRESOURCEGROUP-18']['NCUPNRG']}
    ${sum_prb}    Evaluate    ${G1['M55910C00001']} + ${G9['M55910C00001']} + ${G18['M55910C00001']}
    ${G1_actual}     Evaluate    ${G1['M55910C00001']}/${sum_prb}*100
    ${G9_actual}     Evaluate    ${G9['M55910C00001']}/${sum_prb}*100
    ${G18_actual}    Evaluate    ${G18['M55910C00001']}/${sum_prb}*100
    Run Keyword If    ${close}    Run Keywords    assert_values_close    ${G1_actual}     ${G1_expect}
    ...    AND    assert_values_close    ${G9_actual}     ${G9_expect}    AND    assert_values_close    ${G18_actual}
    ...    ${G18_expect}    ELSE    Run Keywords    Should be true
    ...    (${G1_actual} < ${G1_expect}) and (${G1_actual} > 0)    AND    Should be true    ${G9_actual} > ${G9_expect}
    ...    AND    Should be true    ${G18_actual} > ${G18_expect}
    Should Be True    ${G1['M55910C00002']}>0
    Should Be True    ${G9['M55910C00002']}>0
    Should Be True    ${G18['M55910C00002']}>0
    ${DL_PRB}    Get Recent Multi Counters Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NCELA']}
    ${PRB_Utilization}    Evaluate    ${sum_prb}/${DL_PRB['M55308C10013']}*100
    Should Be True    ${PRB_Utilization}>85

A010 Need Retry
    A010 Step1 UE Attach And Run Traffic
    A010 Check Counters    G1_expect=${A010_STEP1_G1_EXPECT}    G9_expect=${A010_STEP1_G9_EXPECT}
    ...    G18_expect=${A010_STEP1_G18_EXPECT}
    Check SA UE throughput
    MultiUE Detach    end_ue=7
    A010 Step2 UE Attach And Run Traffic
    A010 Check Counters    G1_expect=${A010_STEP2_G1_EXPECT}    G9_expect=${A010_STEP2_G9_EXPECT}
    ...    G18_expect=${A010_STEP2_G18_EXPECT}    close=False
    Check SA UE throughput    end_ue=6
    [Teardown]  run keyword and ignore error  MultiUE Detach    end_ue=7

A010 Step1 UE Attach And Run Traffic
    SA Register UE    UE_ID=1    nwslice=1
    SA Register UE    UE_ID=2    nwslice=1
    Airphone SA Attach    ue_id=3
    Airphone Execute Egate Command    set_pdu_param ue\=3 pdu\=1 trf_type\=internal default_qos_flow\=2
    Airphone Pdu Session Setup   3    1    2    1
    Airphone SA Attach    ue_id=4
    Airphone Execute Egate Command    set_pdu_param ue\=4 pdu\=1 trf_type\=internal default_qos_flow\=2
    Airphone Pdu Session Setup   4    1    2    1
    Airphone SA Attach    ue_id=5
    Airphone Execute Egate Command    set_pdu_param ue\=5 pdu\=1 trf_type\=internal default_qos_flow\=3
    Airphone Pdu Session Setup   5    1    3    1
    Airphone SA Attach    ue_id=6
    Airphone Execute Egate Command    set_pdu_param ue\=6 pdu\=1 trf_type\=internal default_qos_flow\=3
    Airphone Pdu Session Setup   6    1    3    1
    SA Register UE    UE_ID=7    nwslice=1
    Airphone SA Start Data Traffic    1...6    DL    50M    trf_id=1    pdu_id=1    duration=${2400}
    Airphone SA Start Data Traffic    7        DL    20M    trf_id=1    pdu_id=1    duration=${2400}
    Wait '5s' for stabible

A010 Step2 UE Attach And Run Traffic
    SA Register UE    UE_ID=1    nwslice=1
    SA Register UE    UE_ID=2    nwslice=1
    Airphone SA Attach    ue_id=3
    Airphone Execute Egate Command    set_pdu_param ue\=3 pdu\=1 trf_type\=internal default_qos_flow\=2
    Airphone Pdu Session Setup   3    1    2    1
    Airphone SA Attach    ue_id=4
    Airphone Execute Egate Command    set_pdu_param ue\=4 pdu\=1 trf_type\=internal default_qos_flow\=2
    Airphone Pdu Session Setup   4    1    2    1
    Airphone SA Attach    ue_id=5
    Airphone Execute Egate Command    set_pdu_param ue\=5 pdu\=1 trf_type\=internal default_qos_flow\=3
    Airphone Pdu Session Setup   5    1    3    1
    Airphone SA Attach    ue_id=6
    Airphone Execute Egate Command    set_pdu_param ue\=6 pdu\=1 trf_type\=internal default_qos_flow\=3
    Airphone Pdu Session Setup   6    1    3    1
    Wait '2s' for stabible
    Airphone SA Start Data Traffic    1...2    DL    20M    trf_id=1    pdu_id=1    duration=${2400}
    Airphone SA Start Data Traffic    3...6    DL    50M    trf_id=1    pdu_id=1    duration=${2400}
    Wait '5s' for stabible

_Calculate Counter Total Value
    [Arguments]    ${counters}    ${counter_name}
    ${sum}    Set Variable    0
    ${values}    Get Dictionary Values    ${counters['${counter_name}']}
    FOR    ${value}    IN    @{values}
        ${sum}    Evaluate    ${sum} + ${value}
    END
    [Return]    ${sum}

Check SA UE throughput
    [Arguments]    ${end_ue}=7    ${cell_tp}=4    ${type}=pdsch
    FOR    ${num}    IN RANGE    1    ${end_ue}+1
       Log To Console    Check throughput UE${num}
       ${tput_kb}=    airphone_get_throughput_on_specific_scell    ${num}    0    type=${type}    tput_type=ave
       ${tput_Mb}    evaluate    ${tput_kb}/1000
       Log To Console   ${type} ${tput_Mb}
       should be true    ${tput_Mb}>=${cell_tp}
    END

D033 Check Counters
    [Arguments]    ${DL_G1_expect}    ${DL_G9_expect}    ${UL_G1_expect}    ${UL_G9_expect}    ${connection}=GNB_OAM
    ...    ${sa_nbr_req}=2
    Sleep    200s
    coam.connect_to    name=${connection}
    ${counters1}    coam.get_pm_counters    counter_ids=${D_COUNTERS_1}    connection=${connection}
    ${counters2}    coam.get_pm_counters    counter_ids=${D_COUNTERS_2}    connection=${connection}
    coam.teardown    connection=${connection}
    ${G1}    Get Recent Multi Counters Value
    ...    ${counters1['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRRESOURCEGROUP-1']['NCUPNRG']}
    ${G9}    Get Recent Multi Counters Value
    ...    ${counters1['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRRESOURCEGROUP-9']['NCUPNRG']}

    ${dl_sum_prb}      Evaluate    ${G1['M55910C00001']} + ${G9['M55910C00001']}
    ${DL_G1_actual}    Evaluate    ${G1['M55910C00001']}/${dl_sum_prb}*100
    ${DL_G9_actual}    Evaluate    ${G9['M55910C00001']}/${dl_sum_prb}*100
    assert_values_close    ${DL_G1_actual}    ${DL_G1_expect}
    assert_values_close    ${DL_G9_actual}    ${DL_G9_expect}
    Should Be True    ${G1['M55910C00002']}>0
    Should Be True    ${G9['M55910C00002']}>0

    ${PRB_AVAIL}    Get Recent Multi Counters Value
    ...    ${counters1['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NCELA']}
    ${DL_PRB_Utilization}    Evaluate    ${dl_sum_prb}/${PRB_AVAIL['M55308C10013']}*100
    Should Be True    ${DL_PRB_Utilization}>85
    ${DRB_NBR}    Get Recent Multi Counters Value
    ...    ${counters2['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['RSADU']}
    should be true    ${DRB_NBR['M55139C03509']}==120
    ${DL_DEPRIO}    Get Recent Multi Counters Value
    ...    ${counters1['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NDLHQ']}
    should be true     ${DL_DEPRIO['M55300C12010']}==0

    ${ul_sum_prb}      Evaluate    ${G1['M55910C00003']} + ${G9['M55910C00003']}
    ${UL_G1_actual}    Evaluate    ${G1['M55910C00003']}/${ul_sum_prb}*100
    ${UL_G9_actual}    Evaluate    ${G9['M55910C00003']}/${ul_sum_prb}*100
    assert_values_close    ${UL_G1_actual}    ${UL_G1_expect}
    assert_values_close    ${UL_G9_actual}    ${UL_G9_expect}
    Should Be True    ${G1['M55910C00004']}>0
    Should Be True    ${G9['M55910C00004']}>0

    ${UL_PRB_Utilization}    Evaluate    ${ul_sum_prb}/${PRB_AVAIL['M55308C10012']}*100
    Should Be True    ${UL_PRB_Utilization}>85
    should be true    ${DRB_NBR['M55139C03510']}==120
    ${UL_DEPRIO}      Get Recent Multi Counters Value
    ...    ${counters2['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NULH']}
    should be true    ${UL_DEPRIO['M55370C00041']}==0
    ${RSADU}    Set Variable    ${counters2['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['RSADU']}
    ${nbr_req}    _Calculate Counter Total Value    ${RSADU}    M55139C03506
    should be true    ${nbr_req}==${sa_nbr_req}
    ${admit_with_nbr}    _Calculate Counter Total Value    ${RSADU}    M55139C03507
    should be true    ${admit_with_nbr}==${sa_nbr_req}
    ${admit_not_nbr}    _Calculate Counter Total Value    ${RSADU}    M55139C03508
    should be true    ${admit_not_nbr}==0
    should be true    ${DRB_NBR['M55139C03511']}==60

D033 Common Step
    [Arguments]    ${DL_G1_expect}    ${DL_G9_expect}    ${UL_G1_expect}    ${UL_G9_expect}    ${sa_nbr_req}=2
    D033 UE Attach And Run Traffic
    Run Keyword And Continue On Failure    D033 Check Counters    DL_G1_expect=${DL_G1_expect}
    ...    DL_G9_expect=${DL_G9_expect}    UL_G1_expect=${UL_G1_expect}
    ...    UL_G9_expect=${UL_G9_expect}    sa_nbr_req=${sa_nbr_req}
    GNB Ttitrace Collection    step=${sa_nbr_req}
    MultiUE Detach    end_ue=3

D033 Need Retry
    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'before_onair' file
    Prepare gnb onair
    Airphone Cleanup Egate Console Log
    D033 Common Step    DL_G1_expect=${D033_DL_STEP1_G1_EXPECT}    DL_G9_expect=${D033_DL_STEP1_G9_EXPECT}
    ...    UL_G1_expect=${D033_UL_STEP1_G1_EXPECT}    UL_G9_expect=${D033_UL_STEP1_G9_EXPECT}
    COAM.Setup Admin
    COAM.perform_delta_recommissioning    delta_file=${CURDIR}/002_006_modify_minquota.json
    COAM.Teardown Admin
    D033 Common Step    DL_G1_expect=${D033_DL_STEP2_G1_EXPECT}    DL_G9_expect=${D033_DL_STEP2_G9_EXPECT}
    ...    UL_G1_expect=${D033_UL_STEP2_G1_EXPECT}    UL_G9_expect=${D033_UL_STEP2_G9_EXPECT}    sa_nbr_req=4

D033 UE Attach And Run Traffic
    SA Register UE    UE_ID=1    nwslice=1
    Airphone Set Traffic Type    1    2    internal
    Airphone Execute Egate Command    ue_pdu_session_setup pdu\=2 ue\=1 nwslice\=20 gw\=1
    SA Register UE    UE_ID=2    nwslice=2
    Airphone SA Attach    ue_id=3
    Airphone Execute Egate Command    set_pdu_param ue\=3 pdu\=1 trf_type\=internal default_qos_flow\=17
    Airphone Pdu Session Setup   3    1    2    1
    Wait '2s' for stabible
    Airphone SA Start Data Traffic    1...2    DL    120M    pdu_id=1    duration=2400s    trf_id=1
    Airphone SA Start Data Traffic    1...2    DL    120M    pdu_id=1    duration=2400s    trf_id=2
    Airphone SA Start Data Traffic    1        DL    5M      pdu_id=2    duration=2400s    trf_id=1
    Airphone SA Start Data Traffic    3        DL    500K    pdu_id=1    duration=2400s    trf_id=1
    Airphone SA Start Data Traffic    1...2    UL    30M     pdu_id=1    duration=2400s    trf_id=1
    Airphone SA Start Data Traffic    1        UL    5M      pdu_id=2    duration=2400s    trf_id=1
    Airphone SA Start Data Traffic    3        UL    500K    pdu_id=1    duration=2400s    trf_id=1
    Wait '5s' for stabible

D034 Common Step
    [Arguments]    ${DL_G1_expect}    ${DL_G9_expect}    ${UL_G1_expect}    ${UL_G9_expect}    ${sa_nbr_req}=2
    D034 UE Attach And Run Traffic
    Run Keyword And Continue On Failure    D033 Check Counters    DL_G1_expect=${DL_G1_expect}
    ...    DL_G9_expect=${DL_G9_expect}    UL_G1_expect=${UL_G1_expect}
    ...    UL_G9_expect=${UL_G9_expect}    sa_nbr_req=${sa_nbr_req}
    Run Keyword And Ignore Error    Check SA UE throughput    end_ue=5    type=pusch    cell_tp=0
    GNB Ttitrace Collection    step=${sa_nbr_req}
    MultiUE Detach    end_ue=5

D034 Need Retry
    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'before_onair' file
    Prepare gnb onair
    Airphone Cleanup Egate Console Log
    D034 Common Step    DL_G1_expect=${D034_DL_STEP1_G1_EXPECT}    DL_G9_expect=${D034_DL_STEP1_G9_EXPECT}
    ...    UL_G1_expect=${D034_UL_STEP1_G1_EXPECT}    UL_G9_expect=${D034_UL_STEP1_G9_EXPECT}
    COAM.Setup Admin
    COAM.perform_delta_recommissioning    delta_file=${CURDIR}/038_modify_minquota.json
    COAM.Teardown Admin
    D034 Common Step    DL_G1_expect=${D034_DL_STEP2_G1_EXPECT}    DL_G9_expect=${D034_DL_STEP2_G9_EXPECT}
    ...    UL_G1_expect=${D034_UL_STEP2_G1_EXPECT}    UL_G9_expect=${D034_UL_STEP2_G9_EXPECT}    sa_nbr_req=4

D034 UE Attach And Run Traffic
    SA Register UE    UE_ID=1    nwslice=1
    Airphone Set Traffic Type    1    2    internal
    Airphone Execute Egate Command    ue_pdu_session_setup pdu\=2 ue\=1 nwslice\=20 gw\=1
    SA Register UE    UE_ID=2    nwslice=1
    SA Register UE    UE_ID=3    nwslice=2
    SA Register UE    UE_ID=4    nwslice=2
    Airphone SA Attach    ue_id=5
    Airphone Execute Egate Command    set_pdu_param ue\=5 pdu\=1 trf_type\=internal default_qos_flow\=17
    Airphone Pdu Session Setup   5    1    2    1
    Airphone SA Start Data Traffic    1...4    DL    120M     pdu_id=1    duration=2400s    trf_id=1
    Airphone SA Start Data Traffic    1...4    DL    120M     pdu_id=1    duration=2400s    trf_id=2
    Airphone SA Start Data Traffic    1        DL    50M      pdu_id=2    duration=2400s    trf_id=1
    Airphone SA Start Data Traffic    5        DL    500K     pdu_id=1    duration=2400s    trf_id=1
    Airphone SA Start Data Traffic    1...4    UL    30M      pdu_id=1    duration=2400s    trf_id=1
    Airphone SA Start Data Traffic    1        UL    15M      pdu_id=2    duration=2400s    trf_id=1
    Airphone SA Start Data Traffic    5        UL    500K     pdu_id=1    duration=2400s    trf_id=1
    Wait '5s' for stabible

D037 Check Counters
    [Arguments]    ${G1_expect}    ${G9_expect}    ${G18_expect}    ${cong_handing}=${FALSE}    ${connection}=GNB_OAM
    Sleep    300s
    coam.connect_to    name=${connection}
    ${counters}    coam.get_pm_counters    counter_ids=${D_COUNTERS_3}    connection=${connection}
    coam.teardown    connection=${connection}
    ${G1}    Get Recent Multi Counters Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRRESOURCEGROUP-1']['NCUPNRG']}
    ${G9}    Get Recent Multi Counters Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRRESOURCEGROUP-9']['NCUPNRG']}
    ${G18}    Get Recent Multi Counters Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRRESOURCEGROUP-18']['NCUPNRG']}
    ${sum_prb}    Evaluate    ${G1['M55910C00003']} + ${G9['M55910C00003']} + ${G18['M55910C00003']}
    ${G1_actual}     Evaluate    ${G1['M55910C00003']}/${sum_prb}*100
    ${G9_actual}     Evaluate    ${G9['M55910C00003']}/${sum_prb}*100
    ${G18_actual}    Evaluate    ${G18['M55910C00003']}/${sum_prb}*100
    assert_values_close    ${G1_actual}     ${G1_expect}
    assert_values_close    ${G9_actual}     ${G9_expect}
    assert_values_close    ${G18_actual}    ${G18_expect}
    Should Be True    ${G1['M55910C00004']}>0
    Should Be True    ${G9['M55910C00004']}>0
    Should Be True    ${G18['M55910C00004']}>0
    ${PRB_AVAIL}    Get Recent Multi Counters Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NCELA']}
    ${PRB_Utilization}    Evaluate    ${sum_prb}/${PRB_AVAIL['M55308C10012']}*100
    Should Be True    ${PRB_Utilization}>85
    ${DRB_NBR}    Get Recent Multi Counters Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['RSADU']}
    should be true    ${DRB_NBR['M55139C03510']}==120
    ${UL_DEPRIO}      Get Recent Multi Counters Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NULH']}
    Run Keyword If    ${cong_handing}    should be true    ${UL_DEPRIO['M55370C00041']}>0    ELSE    should be true
    ...    ${UL_DEPRIO['M55370C00041']}==0
    ${RSADU}    Set Variable    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['RSADU']}
    ${nbr_req}    _Calculate Counter Total Value    ${RSADU}    M55139C03506
    should be true    ${nbr_req}==2
    ${admit_with_nbr}    _Calculate Counter Total Value    ${RSADU}    M55139C03507
    should be true    ${admit_with_nbr}==2
    ${admit_not_nbr}    _Calculate Counter Total Value    ${RSADU}    M55139C03508
    should be true    ${admit_not_nbr}==0
    should be true    ${DRB_NBR['M55139C03511']}==60
    [Teardown]  run keyword and ignore error    GNB Ttitrace Collection    step=0

D037 Need Retry
    Modify nbrPuschCongHandling    value=false
    D037 UE Attach And Run Traffic
    D037 Check Counters    G1_expect=${D037_UL_G1_EXPECT_STEP1}
    ...    G9_expect=${D037_UL_G9_EXPECT_STEP1}    G18_expect=${D037_UL_G18_EXPECT_STEP1}
    Run Keyword And Ignore Error    Check SA UE throughput    end_ue=8    type=pusch    cell_tp=0
    GNB Ttitrace Collection    step=1
    Modify nbrPuschCongHandling    value=true
    D037 Check Counters    G1_expect=${D037_UL_G1_EXPECT_STEP2}
    ...    G18_expect=${D037_UL_G18_EXPECT_STEP2}    cong_handing=${True}    G9_expect=${D037_UL_G9_EXPECT_STEP2}
    Run Keyword And Ignore Error    Check SA UE throughput    end_ue=8    type=pusch    cell_tp=0
    GNB Ttitrace Collection    step=2
    [Teardown]  run keyword and ignore error    MultiUE Detach    end_ue=8

D037 UE Attach And Run Traffic
    SA Register UE    UE_ID=1    nwslice=19
    SA Register UE    UE_ID=2    nwslice=19
    SA Register UE    UE_ID=3    nwslice=1
    SA Register UE    UE_ID=4    nwslice=1
    SA Register UE    UE_ID=5    nwslice=2
    SA Register UE    UE_ID=6    nwslice=2
    SA Register UE    UE_ID=7    nwslice=3
    SA Register UE    UE_ID=8    nwslice=3
    Airphone SA Start Data Traffic    1...2    DL    20M     pdu_id=1    duration=2400s    trf_id=1
    Airphone SA Start Data Traffic    3...8    DL    40M     pdu_id=1    duration=2400s    trf_id=1
    Airphone SA Start Data Traffic    1        UL    5M      pdu_id=1    duration=2400s    trf_id=1
    Airphone SA Start Data Traffic    2...8    UL    20M     pdu_id=1    duration=2400s    trf_id=1
    Wait '5s' for stabible

Modify nbrPuschCongHandling
    [Arguments]    ${value}=false
    COAM.Setup Admin
    COAM.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    parameter=nbrPuschCongHandling
    ...    operation=update    value=${value}
    COAM.Teardown Admin

Modify nrDrbDN
    COAM.Setup Admin
    COAM.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1/NRDRB_5QI-2    parameter=nrDrbDN
    ...    operation=update    value=MRBTS-1/NRBTS-1/NRDRB-44
    COAM.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1/NRDRB_5QI-5    parameter=nrDrbDN
    ...    operation=update    value=MRBTS-1/NRBTS-1/NRDRB-18
    COAM.Teardown Admin

MultiUE Detach
    [Arguments]    ${end_ue}=4    ${start_ue}=1
    FOR    ${num}    IN RANGE    ${start_ue}    ${end_ue}+1
        Airphone SA Detach    ${num}
    END

GNB Ttitrace Collection
    [Arguments]    ${step}=2
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}${step}
    Start GNB Ttitrace With Streaming Mode    lcr_cell_id=1
    Wait '5s' for stabible
    ${pcap}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#    Run Keyword And Ignore Error    Decoder Tttirace From Pcap To Csv    ${pcap}    ${save_log}/tti

C023 Check Counters
    [Arguments]    ${G1_expect}    ${G2_expect}    ${G3_expect}    ${G4_expect}    ${G5_expect}    ${G6_expect}
    ...    ${G7_expect}    ${G8_expect}    ${G9_expect}    ${connection}=GNB_OAM
    Sleep    200s
    coam.connect_to    name=${connection}
    ${counters}    coam.get_pm_counters    counter_ids=${C_COUNTERS}    connection=${connection}
    coam.teardown    connection=${connection}
    ${G1}    Get Recent Multi Counters Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRRESOURCEGROUP-1']['NCUPNRG']}
    ${G2}    Get Recent Multi Counters Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRRESOURCEGROUP-2']['NCUPNRG']}
    ${G3}    Get Recent Multi Counters Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRRESOURCEGROUP-3']['NCUPNRG']}
    ${G4}    Get Recent Multi Counters Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRRESOURCEGROUP-4']['NCUPNRG']}
    ${G5}    Get Recent Multi Counters Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRRESOURCEGROUP-5']['NCUPNRG']}
    ${G6}    Get Recent Multi Counters Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRRESOURCEGROUP-6']['NCUPNRG']}
    ${G7}    Get Recent Multi Counters Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRRESOURCEGROUP-7']['NCUPNRG']}
    ${G8}    Get Recent Multi Counters Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRRESOURCEGROUP-8']['NCUPNRG']}
    ${G9}    Get Recent Multi Counters Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRRESOURCEGROUP-9']['NCUPNRG']}
    ${sum_prb_1}     Evaluate    ${G1['M55910C00001']} + ${G2['M55910C00001']} + ${G3['M55910C00001']}
    ${sum_prb_2}     Evaluate    ${G4['M55910C00001']} + ${G5['M55910C00001']} + ${G6['M55910C00001']}
    ${sum_prb_3}     Evaluate    ${G7['M55910C00001']} + ${G8['M55910C00001']} + ${G9['M55910C00001']}
    ${G1_actual}     Evaluate    ${G1['M55910C00001']}/${sum_prb_1}*100
    ${G2_actual}     Evaluate    ${G2['M55910C00001']}/${sum_prb_1}*100
    ${G3_actual}     Evaluate    ${G3['M55910C00001']}/${sum_prb_1}*100
    ${G4_actual}     Evaluate    ${G4['M55910C00001']}/${sum_prb_2}*100
    ${G5_actual}     Evaluate    ${G5['M55910C00001']}/${sum_prb_2}*100
    ${G6_actual}     Evaluate    ${G6['M55910C00001']}/${sum_prb_2}*100
    ${G7_actual}     Evaluate    ${G7['M55910C00001']}/${sum_prb_3}*100
    ${G8_actual}     Evaluate    ${G8['M55910C00001']}/${sum_prb_3}*100
    ${G9_actual}     Evaluate    ${G9['M55910C00001']}/${sum_prb_3}*100
    assert_values_close    ${G1_actual}     ${G1_expect}
    assert_values_close    ${G2_actual}     ${G2_expect}
    assert_values_close    ${G3_actual}     ${G3_expect}
    assert_values_close    ${G4_actual}     ${G4_expect}
    assert_values_close    ${G5_actual}     ${G5_expect}
    assert_values_close    ${G6_actual}     ${G6_expect}
    assert_values_close    ${G7_actual}     ${G7_expect}
    assert_values_close    ${G8_actual}     ${G8_expect}
    assert_values_close    ${G9_actual}     ${G9_expect}
    ${sum_prb}    Evaluate    ${sum_prb_1} + ${sum_prb_2} + ${sum_prb_3}
    ${PLMN1_actual}     Evaluate    ${sum_prb_1}/${sum_prb}*100
    ${PLMN2_actual}     Evaluate    ${sum_prb_2}/${sum_prb}*100
    ${PLMN3_actual}     Evaluate    ${sum_prb_3}/${sum_prb}*100
    assert_values_close    ${PLMN1_actual}     ${20}
    assert_values_close    ${PLMN2_actual}     ${20}
    assert_values_close    ${PLMN3_actual}     ${60}
    ${PLMN1}    Get Recent Multi Counters Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['MCC-311']['MNC-489']['NCUPL']}
    ${PLMN2}    Get Recent Multi Counters Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['MCC-311']['MNC-490']['NCUPL']}
    ${PLMN3}    Get Recent Multi Counters Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['MCC-311']['MNC-491']['NCUPL']}
    ${PLMN1_PRB_Utilization}    Evaluate    ${PLMN1['M55338C00001']}/${PLMN1['M55338C00003']}*100
    ${PLMN2_PRB_Utilization}    Evaluate    ${PLMN2['M55338C00001']}/${PLMN2['M55338C00003']}*100
    ${PLMN3_PRB_Utilization}    Evaluate    ${PLMN3['M55338C00001']}/${PLMN3['M55338C00003']}*100
    assert_values_close    ${PLMN1_PRB_Utilization}     ${20}
    assert_values_close    ${PLMN2_PRB_Utilization}     ${20}
    assert_values_close    ${PLMN3_PRB_Utilization}     ${60}
    Should Be True    ${PLMN1['M55338C00005']}>0
    Should Be True    ${PLMN2['M55338C00005']}>0
    Should Be True    ${PLMN3['M55338C00005']}>0
    ${DL_PRB}    Get Recent Multi Counters Value
    ...    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NCELA']}
    Should Be True    ${sum_prb}/${DL_PRB['M55308C10013']}*100>85

C023 Need Retry
    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'before_onair' file
    Prepare gnb onair
    Airphone Cleanup Egate Console Log
    C023 UE Attach And Run Traffic
    C023 Check Counters    G1_expect=${C023_G1_EXPECT}    G2_expect=${C023_G2_EXPECT}
    ...    G3_expect=${C023_G3_EXPECT}    G4_expect=${C023_G4_EXPECT}    G5_expect=${C023_G5_EXPECT}
    ...    G6_expect=${C023_G6_EXPECT}    G7_expect=${C023_G7_EXPECT}    G8_expect=${C023_G8_EXPECT}
    ...    G9_expect=${C023_G9_EXPECT}
    MultiUE Detach    end_ue=3
    MultiUE Detach    end_ue=23    start_ue=21
    MultiUE Detach    end_ue=43    start_ue=41

C023 UE Attach And Run Traffic
    SA Register UE    UE_ID=1     nwslice=1
    SA Register UE    UE_ID=2     nwslice=9
    SA Register UE    UE_ID=3     nwslice=18
    SA Register UE    UE_ID=21    nwslice=1
    SA Register UE    UE_ID=22    nwslice=9
    SA Register UE    UE_ID=23    nwslice=18
    SA Register UE    UE_ID=41    nwslice=1
    SA Register UE    UE_ID=42    nwslice=9
    SA Register UE    UE_ID=43    nwslice=18
    Airphone SA Start Data Traffic    1...3      DL    150M    trf_id=1    pdu_id=1    duration=${2400}
    Airphone SA Start Data Traffic    21...23    DL    150M    trf_id=1    pdu_id=1    duration=${2400}
    Airphone SA Start Data Traffic    41...43    DL    150M    trf_id=1    pdu_id=1    duration=${2400}

