*** Settings ***
Documentation
...    Author: Qianqian Guo
...    Contact: qianqian.guo@nokia-sbell.com
...    this file is module case template,you can create your test case according to this template.
...    Please do not modify the file without notification to author


Suite Setup    Common Suite Setup For AIC
Suite Teardown    Common Suite Teardown For AIC

Force Tags
...      Robustness             #Tag Item
...      VRF_HAZ1             #Competence Area
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout    600 minutes

Resource          ../../Resources/Cloud/AIC_Common_Resource.robot
Resource          ../../T02/Common_Case/common_resource_new.robot
Resource          ../../../../resources/RAN_PZ_HAZ_1/Module/Module.robot

*** Variables ***
${ns}    Get vCU Namespace From Config File

*** Test Cases ***
Cloud10870_Robustness_case1_cell_lock_unlock_more_times_in_VCU
    [Tags]    1N    2N    Robustness    case1    lock    cell    VCU
    [Documentation]    cells lock and unlock more times
    ...    Author: qianqian.guo@nokia-sbell.com
    ...    history change: 2025-01-18,Guo Qianqian,Create the test case
    [Setup]    Case Precondition
    FOR    ${i}    IN RANGE    5
        Log To Console    \n***run${i}***
        Log To Console    step1: lock cell1 in VCU
        BTS Operation    operation=cell_lock    product_type=vcu    bts_index=0    distname_id=NRCELL-1
        ...    need_verify=True
        Sleep    10s
        Log To Console    unlock cell1 in VCU
        BTS Operation    operation=cell_unlock    product_type=vcu    bts_index=0    distname_id=NRCELL-1
        ...    need_verify=True
        Sleep    20s
        Log To Console    step2: lock cell2 in VCU
        BTS Operation    operation=cell_lock    product_type=vcu    bts_index=0    distname_id=NRCELL-2
        ...    need_verify=True
        Sleep    10s
        Log To Console    unlock cell2 in VCU
        BTS Operation    operation=cell_unlock    product_type=vcu    bts_index=0    distname_id=NRCELL-2
        ...    need_verify=True
        Sleep    20s
        Log To Console    step3: lock cell3 in VCU
        BTS Operation    operation=cell_lock    product_type=vcu    bts_index=0    distname_id=NRCELL-3
        ...    need_verify=True
        Sleep    10s
        Log To Console    unlock cell3 in VCU
        BTS Operation    operation=cell_unlock    product_type=vcu    bts_index=0    distname_id=NRCELL-3
        ...    need_verify=True
        Sleep    20s
    END
    Sleep    120s
    Log To Console    \n***step4: Check alarms in VCU and VDU***
    Check Alarm for cell lock and unlock in VCU
    Check Alarm for cell lock and unlock in VDU
    Log To Console    \n***step5: VCU_VDU_Health_Check***
    VCU_VDU_Health_Check
    Log to console    \n***step6:Start DL and UL Call For UE***
    Prepare And Attach UE    ue_index=1
    Start DL and UL Call For UE    ue_index=${1}
    Sleep    60s
    [Teardown]    Case Postcondition

Cloud10870_Robustness_case2_cell_block_unblock_more_times_in_VDU
    [Tags]    1N    2N    Robustness    case2    block    cell    VDU
    [Documentation]    cells lock and unlock more times
    ...    Author: qianqian.guo@nokia-sbell.com
    ...    history change: 2025-01-18,Guo Qianqian,Create the test case
    [Setup]    Case Precondition
    FOR    ${i}    IN RANGE    5
        Log To Console    \n***run${i}***
        Log To Console    step1: block cell1 in VDU
        BTS Operation    operation=cell_block    product_type=vdu    bts_index=0    distname_id=NRCELL-1
        ...    need_verify=True
        Sleep    10s
        Log To Console    unblock cell1 in VDU
        BTS Operation    operation=cell_unblock    product_type=vdu    bts_index=0    distname_id=NRCELL-1
        ...    need_verify=True
        Sleep    20s
        Log To Console    step2: block cell2 in VDU
        BTS Operation    operation=cell_block    product_type=vdu    bts_index=0    distname_id=NRCELL-2
        ...    need_verify=True
        Sleep    10s
        Log To Console    unblock cell2 in VDU
        BTS Operation    operation=cell_unblock    product_type=vdu    bts_index=0    distname_id=NRCELL-2
        ...    need_verify=True
        Sleep    20s
        Log To Console    step3: block cell3 in VDU
        BTS Operation    operation=cell_block    product_type=vdu    bts_index=0    distname_id=NRCELL-3
        ...    need_verify=True
        Sleep    10s
        Log To Console    unblock cell3 in VDU
        BTS Operation    operation=cell_unblock    product_type=vdu    bts_index=0    distname_id=NRCELL-3
        ...    need_verify=True
        Sleep    20s
    END
    Sleep    120s
    Log To Console    \n***step4: Check alarms in VCU and VDU***
    Check Alarm for cell block and unblock in VCU
    Check Alarm for cell block and unblock in VDU
    Log To Console    \n***step5:VCU_VDU_Health_Check***
    VCU_VDU_Health_Check
    Log to console    \n***step6:Start DL Call For UE***
    ${ue_type}    Prepare And Attach UE    ue_index=1
    Start traffic    ue_type=${ue_type}    ue_index=1   direction=dl    dt_index=1
    ...    throughput=110M    duration=${600}
    Sleep    60s
    [Teardown]    Case Postcondition

Cloud10870_Robustness_case3_RU_lock_unlock_more_times
    [Tags]    1N    2N    Robustness    case3    lock    RU
    [Documentation]    RUs lock and unlock more times
    ...    Author: qianqian.guo@nokia-sbell.com
    ...    history change: 2025-01-14,Guo Qianqian,Create the test case
    [Setup]    Case Precondition
    FOR    ${i}    IN RANGE    5
        Log To Console    \n***run${i}***
        Log To Console    step1: lock RMOD-1
        BTS Operation    operation=ru_lock    product_type=vdu    bts_index=0    distname_id=RMOD-1
        ...    need_verify=True
        Sleep    30s
        Log To Console    unblock RMOD-1
        BTS Operation    operation=ru_unlock    product_type=vdu    bts_index=0    distname_id=RMOD-1
        ...    need_verify=True
        Sleep    30s
        Log To Console    step2: lock RMOD-2
        BTS Operation    operation=ru_lock    product_type=vdu    bts_index=0    distname_id=RMOD-2
        ...    need_verify=True
        Sleep    30s
        Log To Console    unblock RMOD-2
        BTS Operation    operation=ru_unlock    product_type=vdu    bts_index=0    distname_id=RMOD-2
        ...    need_verify=True
        Sleep    30s
        Log To Console    step3: lock RMOD-3
        BTS Operation    operation=ru_lock    product_type=vdu    bts_index=0    distname_id=RMOD-3
        ...    need_verify=True
        Sleep    30s
        Log To Console    unblock RMOD-3
        BTS Operation    operation=ru_unlock    product_type=vdu    bts_index=0    distname_id=RMOD-3
        ...    need_verify=True
        Sleep    30s
    END
    Sleep    60s
    Log To Console    \n***step4: Check alarms in VCU and VDU***
    Check Alarm for cell block and unblock in VCU
    Check Alarm for cell lock and unlock in VDU
    Log To Console    \n***step5:VCU_VDU_Health_Check***
    VCU_VDU_Health_Check
    Log to console    \n***step6:Start DL Call For UE***
    ${ue_type}    Prepare And Attach UE    ue_index=1
    Start traffic    ue_type=${ue_type}    ue_index=1   direction=dl    dt_index=1
    ...    throughput=110M    duration=${600}
    Sleep    60s
    [Teardown]    Case Postcondition

Cloud10870_Robustness_case4_NG_link_lock_unlock_more_times
    [Tags]    1N    2N    Robustness    case4    lock    NG
    [Documentation]    NG links lock and unlock more times
    ...    Author: qianqian.guo@nokia-sbell.com
    ...    history change: 2025-01-18,Guo Qianqian,Create the test case
    [Setup]    Case Precondition
    FOR    ${i}    IN RANGE    5
        Log To Console    \n***run${i}***
        Log To Console    step1: lock NG-Link-1
        BTS Operation    operation=nglink_lock    product_type=vcu    bts_index=0
        ...    distname_id=nglink-1    need_verify=True
        Sleep    30s
        Log To Console    unblock NG-Link-1
        BTS Operation    operation=nglink_unlock    product_type=vcu    bts_index=0
        ...    distname_id=nglink-1    need_verify=True
        Sleep    30s
        Log To Console    step2: lock NG-Link-2
        BTS Operation    operation=nglink_lock    product_type=vcu    bts_index=0
        ...    distname_id=nglink-2    need_verify=True
        Sleep    30s
        Log To Console    unblock NG-Link-2
        BTS Operation    operation=nglink_unlock    product_type=vcu    bts_index=0
        ...    distname_id=nglink-2    need_verify=True
        Sleep    30s
    END
    Sleep    120s
    Log To Console    \n***step4: Check alarms in VCU and VDU***
    Check Alarm for cell lock and unlock in VCU
    Check Alarm for cell lock and unlock in VDU
    Log To Console    \n***step5:VCU_VDU_Health_Check***
    VCU_VDU_Health_Check
    Log to console    \n***step6:Start DL Call For UE***
    ${ue_type}    Prepare And Attach UE    ue_index=1
    Start traffic    ue_type=${ue_type}    ue_index=1   direction=dl    dt_index=1
    ...    throughput=110M    duration=${600}
    Sleep    60s
    [Teardown]    Case Postcondition

Cloud10870_Robustness_case5_cell_reset_more_times_in_VCU
    [Tags]    1N    2N    Robustness    case5    reset    cell    VCU
    [Documentation]    cells reset more times
    ...    Author: qianqian.guo@nokia-sbell.com
    ...    history change: 2025-01-18,Guo Qianqian,Create the test case
    [Setup]    Case Precondition
    FOR    ${i}    IN RANGE    5
        Log To Console    \n***run${i}***
        Log To Console    step1: reset cell1 in VCU
        BTS Operation    operation=cell_reset    product_type=vcu    bts_index=0    distname_id=NRCELL-1
        ...    need_verify=yes
        Sleep    30s
        Log To Console    step2: reset cell2 in VCU
        BTS Operation    operation=cell_reset    product_type=vcu    bts_index=0    distname_id=NRCELL-2
        ...    need_verify=yes
        Sleep    30s
        Log To Console    step3: reset cell3 in VCU
        BTS Operation    operation=cell_reset    product_type=vcu    bts_index=0    distname_id=NRCELL-3
        ...    need_verify=yes
        Sleep    30s
    END
    Sleep    120s
    Log To Console    \n***step4: Check alarms in VCU and VDU***
    Check Alarm for cell lock and unlock in VCU
    Check Alarm for cell lock and unlock in VDU
    Log To Console    \n***step5: VCU_VDU_Health_Check***
    VCU_VDU_Health_Check
    Log to console    \n***step6:Start DL Call For UE***
    ${ue_type}    Prepare And Attach UE    ue_index=1
    Start traffic    ue_type=${ue_type}    ue_index=1   direction=dl    dt_index=1
    ...    throughput=110M    duration=${600}
    Sleep    60s
    [Teardown]    Case Postcondition

Cloud10870_Robustness_case6_cell_reset_more_times_in_VDU
    [Tags]    1N    Robustness    case6    reset    cell    VDU
    [Documentation]    cells reset more times
    ...    Author: qianqian.guo@nokia-sbell.com
    ...    history change: 2025-01-18,Guo Qianqian,Create the test case
    [Setup]    Case Precondition
    FOR    ${i}    IN RANGE    5
        Log To Console    \n***run${i}***
        Log To Console    step1: reset cell1 in VDU
        BTS Operation    operation=cell_reset    product_type=vdu    bts_index=0    distname_id=NRCELL-1
        ...    need_verify=yes
        Sleep    30s
        Log To Console    step2: reset cell2 in VDU
        BTS Operation    operation=cell_reset    product_type=vdu    bts_index=0    distname_id=NRCELL-2
        ...    need_verify=yes
        Sleep    30s
        Log To Console    step3: reset cell3 in VDU
        BTS Operation    operation=cell_reset    product_type=vdu    bts_index=0    distname_id=NRCELL-3
        ...    need_verify=yes
        Sleep    30s
    END
    Sleep    120s
    Log To Console    \n***step4: Check alarms in VCU and VDU***
    Check Alarm for cell block and unblock in VCU
    Check Alarm for cell block and unblock in VDU
    Log To Console    \n***step5:VCU_VDU_Health_Check***
    VCU_VDU_Health_Check
    Log to console    \n***step6:Start DL and UL Call For UE***
    ${ue_type}    Prepare And Attach UE    ue_index=1
    Start traffic    ue_type=${ue_type}    ue_index=1   direction=dl    dt_index=1
    ...    throughput=110M    duration=${600}
    Sleep    60s
    [Teardown]    Case Postcondition

Cloud10870_Robustness_case7_RU_reset_more_times
    [Tags]    1N    2N    Robustness    case7    reset    RU    VDU
    [Documentation]    RUs reset more times
    ...    Author: qianqian.guo@nokia-sbell.com
    ...    history change: 2025-01-17,Guo Qianqian,Create the test case
    [Setup]    Case Precondition
    FOR    ${i}    IN RANGE    5
        Log To Console    \n***run${i}***
        Log To Console    step1: reset RMOD-1
        BTS Operation    operation=ru_reset    product_type=vdu    bts_index=0    distname_id=RMOD-1
        ...    need_verify=True
        Sleep    600s
        Log To Console    step2: reset RMOD-2
        BTS Operation    operation=ru_reset    product_type=vdu    bts_index=0    distname_id=RMOD-2
        ...    need_verify=True
        Sleep    600s
        Log To Console    step3: reset RMOD-3
        BTS Operation    operation=ru_reset    product_type=vdu    bts_index=0    distname_id=RMOD-3
        ...    need_verify=True
        Sleep    600s
    END
    Sleep    60s
    Log To Console    \n***step4: Check alarms in VCU and VDU***
    Check Alarm for cell block and unblock in VCU
    Check Alarm for RU reset in VDU
    Log To Console    \n***step5:VCU_VDU_Health_Check***
    VCU_VDU_Health_Check
    Log to console    \n***step6:Start DL For UE***
    ${ue_type}    Prepare And Attach UE    ue_index=1
    Start traffic    ue_type=${ue_type}    ue_index=1   direction=dl    dt_index=1
    ...    throughput=110M    duration=${600}
    Sleep    60s
    [Teardown]    Case Postcondition

Cloud10870_Robustness_case8_VCU_reset_more_times
    [Tags]    1N    2N    Robustness    case8    reset    VCU
    [Documentation]    VCU reset more times
    ...    Author: qianqian.guo@nokia-sbell.com
    ...    history change: 2025-01-17,Guo Qianqian,Create the test case
    [Setup]    Case Precondition
    FOR    ${i}    IN RANGE    5
        Log To Console    \n***run${i}***
        Log To Console    step1: reset VCU
        BTS Operation    operation=vcu_reset    product_type=vcu    bts_index=0
        Sleep    600s
    END
    Sleep    60s
    Log To Console    \n***step4: Check alarms in VCU and VDU***
    Check Alarm for VCU reset in VCU
    Check Alarm for VCU reset in VDU
    Log To Console    \n***step5:VCU_VDU_Health_Check***
    VCU_VDU_Health_Check
    Log to console    \n***step6:Start DL For UE***
    ${ue_type}    Prepare And Attach UE    ue_index=1
    Start traffic    ue_type=${ue_type}    ue_index=1   direction=dl    dt_index=1
    ...    throughput=110M    duration=${600}
    Sleep    60s
    [Teardown]    Case Postcondition

Cloud10870_Robustness_case9_VDU_reset_more_times
    [Tags]    1N    2N    Robustness    case9    reset    VDU
    [Documentation]    VDU reset more times
    ...    Author: qianqian.guo@nokia-sbell.com
    ...    history change: 2025-01-17,Guo Qianqian,Create the test case
    [Setup]    Case Precondition
    FOR    ${i}    IN RANGE    5
        Log To Console    \n***run${i}***
        Log To Console    step1: reset VDU
        BTS Operation    operation=vdu_reset    product_type=vdu    bts_index=0
        Sleep    600s
    END
    Sleep    60s
    Log To Console    \n***step4: Check alarms in VCU and VDU***
    Check Alarm for cell block and unblock in VCU
    Check Alarm for VDU reset in VDU
    Log To Console    \n***step5:VCU_VDU_Health_Check***
    VCU_VDU_Health_Check
    Log to console    \n***step6:Start DL For UE***
    ${ue_type}    Prepare And Attach UE    ue_index=1
    Start traffic    ue_type=${ue_type}    ue_index=1   direction=dl    dt_index=1
    ...    throughput=110M    duration=${600}
    Sleep    60s
    [Teardown]    Case Postcondition

Cloud10870_Robustness_case10_cell-group_lock_unlock_more_times_in_VCU
    [Tags]    1N    2N    Robustness    case10    lock    cell-group    VCU
    [Documentation]    cell-groups lock and unlock more times
    ...    Author: qianqian.guo@nokia-sbell.com
    ...    history change: 2025-01-18,Guo Qianqian,Create the test case
    [Setup]    Case Precondition
    FOR    ${i}    IN RANGE    5
        Log To Console    \n***run${i}***
        Log To Console    step1: lock cell-group1 in VCU
        BTS Operation    operation=cell_group_lock    product_type=vcu    bts_index=0    distname_id=NRCELLGRP-1
        ...    need_verify=True
        Sleep    10s
        Log To Console    unlock cell_group1 in VCU
        BTS Operation    operation=cell_group_unlock    product_type=vcu    bts_index=0    distname_id=NRCELLGRP-1
        ...    need_verify=True
        Sleep    20s
        Log To Console    step2: lock cell_group2 in VCU
        BTS Operation    operation=cell_group_lock    product_type=vcu    bts_index=0    distname_id=NRCELLGRP-2
        ...    need_verify=True
        Sleep    10s
        Log To Console    unlock cell_group2 in VCU
        BTS Operation    operation=cell_group_unlock    product_type=vcu    bts_index=0    distname_id=NRCELLGRP-2
        ...    need_verify=True
        Sleep    20s
        Log To Console    step3: lock cell_group3 in VCU
        BTS Operation    operation=cell_group_lock    product_type=vcu    bts_index=0    distname_id=NRCELLGRP-3
        ...    need_verify=True
        Sleep    10s
        Log To Console    unlock cell_group3 in VCU
        BTS Operation    operation=cell_group_unlock    product_type=vcu    bts_index=0    distname_id=NRCELLGRP-3
        ...    need_verify=True
        Sleep    20s
    END
    Sleep    120s
    Log To Console    \n***step4: Check alarms in VCU and VDU***
    Check Alarm for cell lock and unlock in VCU
    Check Alarm for cell lock and unlock in VDU
    Log To Console    \n***step5: VCU_VDU_Health_Check***
    VCU_VDU_Health_Check
    Log to console    \n***step6:Start DL For UE***
    ${ue_type}    Prepare And Attach UE    ue_index=1
    Start traffic    ue_type=${ue_type}    ue_index=1   direction=dl    dt_index=1
    ...    throughput=110M    duration=${600}
    Sleep    60s
    [Teardown]    Case Postcondition

Cloud10870_Robustness_case11_RANNIC_reset_more_times
    [Tags]    1N    2N    Robustness    case11    reset    RANNIC
    [Documentation]    RANNIC reset more times
    ...    Author: qianqian.guo@nokia-sbell.com
    ...    history change: 2025-01-19,Guo Qianqian,Create the test case
    [Setup]    Case Precondition
    FOR    ${i}    IN RANGE    5
        Log To Console    \n***run${i}***
        Log To Console    step1: reset RANNIC
        BTS Operation    operation=rannic_reset    product_type=vdu    bts_index=0
        ...    distname_id=RNICMOD_R-1    need_verify=True
        Sleep    300s
    END
    Sleep    60s
    Log To Console    \n***step4: Check alarms in VCU and VDU***
    Check Alarm for cell block and unblock in VCU
    Check Alarm for RANNIC reset in VDU
    Log To Console    \n***step5:VCU_VDU_Health_Check***
    VCU_VDU_Health_Check
    Log to console    \n***step6:Start DL For UE***
    ${ue_type}    Prepare And Attach UE    ue_index=1
    Start traffic    ue_type=${ue_type}    ue_index=1   direction=dl    dt_index=1
    ...    throughput=110M    duration=${600}
    Sleep    60s
    [Teardown]    Case Postcondition

Cloud10870_Robustness_case12_CP-UE_Pod_Failure
    [Tags]    2N    Robustness    pod_failure    cpue    case12
    [Documentation]
    ...    Author: qianqian.guo@nokia-sbell.com
    ...    history change: 2024/11/28,qianqian Guo,
    ...    This case is to test CP-UE pod failure without site reset.
    [Setup]    Case Precondition
    Set Initialize PA Value    pa_port=9-11;12;15;    pa_value=127;0;127;
    Start Counter In vCU
    ${ue_type}    Prepare And Attach UE    ue_index=1
    Start traffic    ue_type=${ue_type}    ue_index=1   direction=dl    dt_index=1
    ...    throughput=110M    duration=${600}
    FOR    ${i}    IN RANGE    6
        Log To Console    \n***run${i}***
        log to console    trigger active cpue failuer
        ${ns}    Get vCU Namespace From Config File
        ${conn}    tafssh.connect_to    hostname=${VCU_HOSTNAME}
        ...                             username=${VCU_USERNAME}
        ...                             password=${VCU_PASSWORD}
        ...                             alias=vcu_master
        ${pod_name}    Get Active Pod Name For Redundant layout of CNF    pod_abbr=cpue    connection=${conn}
        Trigger cmd    cmd=kubectl delete pod ${pod_name} -n ${VCU_NAMESPACE}
        sleep    60s
        log to console    trigger cpue-0 and cpue-1 failuer
	    ${kill_all_pods_cmd}    Catenate
        ...    kubectl delete pod po-${VCU_NAMESPACE}-cpue-0 -n ${VCU_NAMESPACE}
        ...    && kubectl delete pod po-${VCU_NAMESPACE}-cpue-1 -n ${VCU_NAMESPACE}
        Trigger cmd    cmd=${kill_all_pods_cmd}
	    sleep    60s
	    Check Alarm Not Exist
	END
	sleep    300s
    Collect And Check Counter    product_type=vcu    bts_index=${0}    cudu_index=${0}
    [Teardown]    Case Postcondition

Cloud10870_Robustness_case13_CP-CL_Pod_Failure
    [Tags]    2N    Robustness    pod_failure    cpcl    case13
    [Documentation]
    ...    Author: qianqian.guo@nokia-sbell.com
    ...    history change: 2024/11/28,qianqian Guo,
    ...    This case is to test CP-CL pod failure without site reset.
    [Setup]    Case Precondition
    Set Initialize PA Value    pa_port=9-11;12;15;    pa_value=127;0;127;
    Start Counter In vCU For CP-CL Failure
    ${ue_type}    Prepare And Attach UE    ue_index=1
    Start traffic    ue_type=${ue_type}    ue_index=1   direction=dl    dt_index=1
    ...    throughput=110M    duration=${600}
    FOR    ${i}    IN RANGE    6
        Log To Console    \n***run${i}***
        log to console    trigger active cpcl failuer
        ${ns}    Get vCU Namespace From Config File
        ${conn}    tafssh.connect_to    hostname=${VCU_HOSTNAME}
        ...                             username=${VCU_USERNAME}
        ...                             password=${VCU_PASSWORD}
        ...                             alias=vcu_master
        ${pod_name}    Get Active Pod Name For Redundant layout of CNF    pod_abbr=cpcl    connection=${conn}
        Trigger cmd    cmd=kubectl delete pod ${pod_name} -n ${VCU_NAMESPACE}
        sleep    60s
        log to console    trigger cpcl-0 and cpcl-1 failuer
	    ${kill_all_pods_cmd}    Catenate
        ...    kubectl delete pod po-${VCU_NAMESPACE}-cpcl-0 -n ${VCU_NAMESPACE}
        ...    && kubectl delete pod po-${VCU_NAMESPACE}-cpcl-1 -n ${VCU_NAMESPACE}
        Trigger cmd    cmd=${kill_all_pods_cmd}
	    sleep    60s
	    Check Alarm Not Exist
	END
	sleep    300s
    Collect And Check Counter    product_type=vcu    bts_index=${0}    cudu_index=${0}
    [Teardown]    Case Postcondition

Cloud10870_Robustness_case14_CP-NB_Pod_Failure
    [Tags]    2N    Robustness    pod_failure    cpnb    case14
    [Documentation]
    ...    Author: qianqian.guo@nokia-sbell.com
    ...    history change: 2024/11/28,qianqian Guo,
    ...    This case is to test CP-NB pod failure without site reset.
    [Setup]    Case Precondition
    Set Initialize PA Value    pa_port=9-11;12;15;    pa_value=127;0;127;
    ${ue_type}    Prepare And Attach UE    ue_index=1
    Start traffic    ue_type=${ue_type}    ue_index=1   direction=dl    dt_index=1
    ...    throughput=110M    duration=${600}
    FOR    ${i}    IN RANGE    6
        Log To Console    \n***run${i}***
        log to console    trigger active cpnb failuer
        ${ns}    Get vCU Namespace From Config File
        ${conn}    tafssh.connect_to    hostname=${VCU_HOSTNAME}
        ...                             username=${VCU_USERNAME}
        ...                             password=${VCU_PASSWORD}
        ...                             alias=vcu_master
        ${pod_name}    Get Active Pod Name For Redundant layout of CNF    pod_abbr=cpnb    connection=${conn}
        Trigger cmd    cmd=kubectl delete pod ${pod_name} -n ${VCU_NAMESPACE}
        sleep    60s
        log to console    trigger cpnb-0 and cpnb-1 failuer
	    ${kill_all_pods_cmd}    Catenate
        ...    kubectl delete pod po-${VCU_NAMESPACE}-cpnb-0 -n ${VCU_NAMESPACE}
        ...    && kubectl delete pod po-${VCU_NAMESPACE}-cpnb-1 -n ${VCU_NAMESPACE}
        Trigger cmd    cmd=${kill_all_pods_cmd}
	    sleep    60s
	    Check Alarm Not Exist
	END
	sleep    300s
    [Teardown]    Case Postcondition

Cloud10870_Robustness_case15_CP-NRT_Pod_Failure
    [Tags]    2N    Robustness    pod_failure    cpnrt    case15
    [Documentation]
    ...    Author: qianqian.guo@nokia-sbell.com
    ...    history change: 2024/11/28,qianqian Guo,
    ...    This case is to test CP-NRT pod failure without site reset.
    [Setup]    Case Precondition
    Set Initialize PA Value    pa_port=9-11;12;15;    pa_value=127;0;127;
    Start Counter In vCU For CP-NRT Failure
    ${ue_type}    Prepare And Attach UE    ue_index=1
    Start traffic    ue_type=${ue_type}    ue_index=1   direction=dl    dt_index=1
    ...    throughput=110M    duration=${600}
    FOR    ${i}    IN RANGE    6
        Log To Console    \n***run${i}***
        log to console    trigger active cpue failuer
        ${ns}    Get vCU Namespace From Config File
        ${conn}    tafssh.connect_to    hostname=${VCU_HOSTNAME}
        ...                             username=${VCU_USERNAME}
        ...                             password=${VCU_PASSWORD}
        ...                             alias=vcu_master
        ${pod_name}    Get Active Pod Name For Redundant layout of CNF    pod_abbr=cpnrt    connection=${conn}
        Trigger cmd    cmd=kubectl delete pod ${pod_name} -n ${VCU_NAMESPACE}
        log to console    check fault 4350 VNFC unavailable and 4695 VNFC unavailable
        Check Alarm Exist
        sleep    60s
        log to console    trigger cpnrt-0 and cpnrt-1 failuer
	    ${kill_all_pods_cmd}    Catenate
        ...    kubectl delete pod po-${VCU_NAMESPACE}-cpnrt-0 -n ${VCU_NAMESPACE}
        ...    && kubectl delete pod po-${VCU_NAMESPACE}-cpnrt-1 -n ${VCU_NAMESPACE}
        Trigger cmd    cmd=${kill_all_pods_cmd}
	    sleep    60s
	    Check Alarm Not Exist
	END
	sleep    300s
    Collect And Check Counter    product_type=vcu    bts_index=${0}    cudu_index=${0}
    [Teardown]    Case Postcondition

Cloud10870_Robustness_case16_TC_Configurator_Failure
    [Tags]    2N    Robustness    pod_failure    TCC    case16
    [Documentation]
    ...    Author: qianqian.guo@nokia-sbell.com
    ...    history change: 2025/02/21,qianqian Guo,
    ...    This case is to test TCC failure without site reset.
    [Setup]    Case Precondition
        #Open DCAP
    Set Initialize PA Value    pa_port=9-10;11;12;15;    pa_value=127;0;127;127;
    #${webem_info}    Get WebEM Info    ne_type=vcu
    #${vcu_profile}    Create List    tracerVcu    syslogVcu
    #${vcu_trace_id}    Start Capture Log By Dcap    webem_info=${webem_info}    vcu_custom_profile=${vcu_profile}
    ${ue_type}    Prepare And Attach UE    ue_index=1
    Start traffic    ue_type=${ue_type}    ue_index=1   direction=dl    dt_index=1
    ...    throughput=110M    duration=${600}
    sleep    10s    reason=wait call stable
    FOR    ${i}    IN RANGE    50
        Log To Console    \n***run${i}***
        Trigger BTC failure    instance_abbr=TCC
        sleep    300s    reason=wait TCC instance restarted
        ${ns}    Get vCU Namespace From Config File
        ${conn}    tafssh.connect_to    hostname=${VCU_HOSTNAME}
        ...                             username=${VCU_USERNAME}
        ...                             password=${VCU_PASSWORD}
        ...                             alias=vcu_master
        ${pod_name}    Get Active Pod Name For Redundant layout of CNF    pod_abbr=oamext    connection=${conn}
        Check TCP Connection Between Two DCAPs and VCU
        ${restarts}    Get Pod Restarts    ${ns}    ${pod_name}    ${conn}
        Should Be Equal    ${restarts}    0
        #Traffic UE Operation    detach    ue_index=1
        #Traffic UE Operation    attach    ue_index=1
        #Traffic UE Operation    start traffic    ue_index=1    option=udp_dl      bandwidth=100M    port=5000
        #sleep    5s    reason=wait call stable
    END
    #sleep    10s    reason=wait log generated
    #Stop Trace In DCAP    btsip=${webem_info['host']}
    #${trace_file_path}    Get Trace Log    btsip=${webem_info['host']}
    #Check Log For CB009795    ${trace_file_path}    dcap-master
    [Teardown]    Case Postcondition

Cloud10870_Robustness_case17_TC_Master_Failure
    [Tags]    2N    Robustness    pod_failure    TCM    case17
    [Documentation]
    ...    Author: qianqian.guo@nokia-sbell.com
    ...    history change: 2025/02/21,qianqian Guo,
    ...    This case is to test TCM failure without site reset.
    [Setup]    Case Precondition
    #Open DCAP
    Set Initialize PA Value    pa_port=9-11;12;15;    pa_value=127;0;127;
    #${webem_info}    Get WebEM Info    ne_type=vcu
    #${vcu_profile}    Create List    tracerVcu    syslogVcu
    #${vcu_trace_id}    Start Capture Log By Dcap    webem_info=${webem_info}    vcu_custom_profile=${vcu_profile}
    ${ue_type}    Prepare And Attach UE    ue_index=1
    Start traffic    ue_type=${ue_type}    ue_index=1   direction=dl    dt_index=1
    ...    throughput=110M    duration=${600}
    sleep    10s    reason=wait call stable
    FOR    ${i}    IN RANGE    6
        Log To Console    \n***run${i}***
        Trigger BTC failure    instance_abbr=TCM
        sleep    300s    reason=wait TCM instance restarted
        Detach UE    ue_index=${1}
        ${ue_type}    Prepare And Attach UE    ue_index=1
        Start traffic    ue_type=${ue_type}    ue_index=1   direction=dl    dt_index=1
        ...    throughput=110M    duration=${600}
        sleep    10s    reason=wait call stable
    END
    #sleep    10s    reason=wait log generated
    #Stop Trace In DCAP    btsip=${webem_info['host']}
    #${trace_file_path}    Get Trace Log    btsip=${webem_info['host']}
#   Check Log For CB009795    ${trace_file_path}    dcap-master
    [Teardown]    Case Postcondition

*** Keywords ***
Case Precondition
    log to console    Case Precondition
    Common Test Setup For AIC

Case Postcondition
    log to console    Case Postcondition
    vDU Login By Rest
    #Run Keyword And Ignore Error    Detach UE    ue_index=${1}
    Common Test Teardown For AIC
    Run Keyword And Ignore Error    vDU Logout By Rest

Set PA Value
    ${pa_port_list}    ${pa_value_list}    Split And Expand PA Parameters    pa_port=9;10-12;15;    pa_value=0;127;127;
    &{source}    Create Dictionary    att_index=${0}    pa_port=${pa_port_list}    pa_value=${pa_value_list}
    ...                               step=${3}
    PA Operation    operation=Initialize PA Value    source=&{source}

Get TCP Connection Status
    [Arguments]    ${ns}    ${pod_name}    ${dcap_server}    ${connection}=${None}
    ${cmd}=    Catenate    kubectl exec -it ${pod_name} -n ${ns} -- bash -c
    ...                                "netstat -tan | grep ${dcap_server} | awk '{print \\$6}'"
    ${out}    tafssh.execute    command=${cmd}    connection=${connection}
    ${status}=    Strip String    ${out}
    [Return]    ${status}

Check TCP Connection Between Two DCAPs and VCU
    ${ns}    Get vCU Namespace From Config File
    ${conn}    tafssh.connect_to    hostname=${VCU_HOSTNAME}
    ...                             username=${VCU_USERNAME}
    ...                             password=${VCU_PASSWORD}
    ...                             alias=vcu_master
    ${pod_name}    Get Active Pod Name For Redundant layout of CNF    pod_abbr=oamext    connection=${conn}
    ${max_wait}    Set Variable    120
    ${interval}    Set Variable    5
    ${elapsed}     Set Variable    0
    WHILE    ${elapsed} < ${max_wait}
        ${conn_status1}    Get TCP Connection Status    ${ns}    ${pod_name}    10.56.218.136    ${conn}
        ${conn_status2}    Get TCP Connection Status    ${ns}    ${pod_name}    10.56.197.7      ${conn}
        Run Keyword If    '${conn_status1}' == 'ESTABLISHED' and '${conn_status2}' == 'ESTABLISHED'    Exit For Loop
        Sleep    ${interval}
        ${elapsed}    Evaluate    ${elapsed} + ${interval}
    END
    Should Be Equal    ${conn_status1}    ESTABLISHED
    Should Be Equal    ${conn_status2}    ESTABLISHED

Get Pod Restarts
    [Arguments]    ${ns}    ${pod_name}    ${connection}=${None}
    ${cmd}=    Catenate    kubectl get pods -n ${ns}|egrep ${pod_name} |awk '{print \$4}'
    ${out}    tafssh.execute    command=${cmd}    connection=${connection}
    ${restarts}=    Strip String    ${out}
    [Return]    ${restarts}

Open DCAP
    OperatingSystem.Run    DCAP_Basic_controller startLS

Start Capture Log By Dcap
    [Arguments]    ${webem_info}=${None}    ${vdu_custom_profile}=${None}   ${vcu_custom_profile}=${None}
    Connect To DCAP    ${tl.test_pcs[0].default_ssh_connection_details.addr}    9443    ${None}    ${None}    dcapv3
    ...    ${TRUE}    dcap-master
    Make Sure BTS Integrated In DCAP    bts_dic=${webem_info}
    ${trace_id}    Run Keyword If   '''${vdu_custom_profile}'''!='''${None}'''
    ...         Start Trace In DCAP    ${webem_info}    vdu_custom_profile=${vdu_custom_profile}
    ...  ELSE IF  '''${vcu_custom_profile}'''!='''${None}'''
    ...         Start Trace In DCAP    ${webem_info}    vcu_custom_profile=${vcu_custom_profile}
    Log To Console     Trace Collection start on DCAP
    [Return]    ${trace_id}

Get Trace Log
    [Arguments]    ${btsip}
    ${trace_file_path}    Download Trace File    btsip=${btsip}
    @{zip_file_name}    OperatingSystem.List Files In Directory    ${trace_file_path}    *.zip
    ${zip_file_path}    Set Variable    ${trace_file_path}/${zip_file_name[0]}
    ${target_dir}=    Join Path  ${trace_file_path}  unzip-files
    ${log_file_paths}    Extract log from trace file    tti_archive=${zip_file_path}    directory=${target_dir}    postfix=.lcbin
    [Return]    ${log_file_paths}

Get WebEM Info
    [Arguments]    ${ne_type}=vdu   ${gnb_index}=0    ${vdu_index}=0
    ${oam_httpaddr}    Set Variable If    '${ne_type.upper()}'=='VDU'
    ...                 ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.addr}
    ...                                   '${ne_type.upper()}'=='VCU'
    ...                 ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ${oam_web_ip}    set variable if    ':' in '''${oam_httpaddr}'''   [${oam_httpaddr}]    ${oam_httpaddr}
    &{webem_info}=    create dictionary    host=${oam_web_ip}    username=Nemuadmin    password=Nokia@123    port=443
	Set Test Variable    ${webem_info}
    [return]    ${webem_info}

Check Emil Log For CB009795
    [Arguments]    ${trace_file}    ${connection}
    log to console    Check Emil log for CB009795
    ${json_file_path}    Get Emil Decoded Data In Json    file_path=${trace_file}    connection=${connection}
    #...                filter=@{message_filter}
    Check Message In JSON File    ${json_file_path}
    should not be empty    ${json_file_path}

Check Message In JSON File
    [Arguments]    ${trace_file}
    ${parsed_json}    OperatingSystem.Get File    ${trace_file}
    ${context_dict}    json.Loads    ${parsed_json}
    ${trace_info}=    Set Variable    ${context_dict}[emil_data][rows]
    Should Contain X Times    ${trace_info}    'Message_name': '${Message_start_recording}'    ${3}
    Should Contain X Times    ${trace_info}    'Message_name': '${Message_stop_recording}'    ${3}
    Should Contain X Times    ${trace_info}    'User_data': '${User_data_RRCReconfigurationComplete}'    ${3}
    Should Contain X Times    ${trace_info}    'User_data': '${User_data_PDUSessionResourceSetupResponse}'    ${3}

Trigger cmd
    [Arguments]    ${cmd}    ${hostname}=${VCU_HOSTNAME}    ${username}=${VCU_USERNAME}    ${password}=${VCU_PASSWORD}
    ...            ${alias}=vcu_master
    ${conn}=    basic.master_connect    hostname=${hostname}
    ...                           username=${username}
    ...                           password=${password}
    ...                           alias=${alias}
    tafssh.execute    command=${cmd}    connection=${conn}
    [Teardown]    Run Keyword And Ignore Error    basic.master_close    alias=${alias}

Get Active Pod Name For Redundant layout of CNF
    [Arguments]    ${pod_abbr}=oamext    ${connection}=${None}
#    oc get pods --selector='healing-controller.rcpha/service-selector' | grep oamext | awk '{print $1}'
    ${get_active_pod}=    Catenate    oc get pods --selector='healing-controller.rcpha/service-selector' |
    ...                               grep ${pod_abbr} | awk '{print \$1}'
    ${active_pod}    tafssh.execute    command=${get_active_pod}    connection=${connection}
    ${active_pod_list}=    split_string    ${active_pod}    \r\n
    ${active_pod_name}    set variable    ${active_pod_list}[0]
    [Return]    ${active_pod_name}

Check Alarm Exist
    &{expected_alarm1}        Create Dictionary    fault_id=4350    fault_name=VNFC unavailable
    &{expected_alarm2}        Create Dictionary    fault_id=4695    fault_name=gNB Capacity Degraded
    @{expected_list}          Create List     ${expected_alarm1}    ${expected_alarm2}
    &{ignored_alarms1}        Create Dictionary    fault_id=7311    fault_name=No Xn link available
    &{ignored_alarms2}        Create Dictionary    fault_id=7307    fault_name=Xn SCTP setup fail
    &{ignored_alarms3}        Create Dictionary    fault_id=7306    fault_name=Xn SCTP endpoint broken
    @{ignored_alarms_list}    Create List     ${ignored_alarms1}    ${ignored_alarms2}    ${ignored_alarms3}
    &{CRITICAL_ALARM1}        Create Dictionary    severity=critical
    @{CRITICAL}               Create List     ${CRITICAL_ALARM1}
    ${res}    Alarm Operation    operation=check_active_alarms    product_type=vcu    bts_index=0    cudu_index=0
    ...                          expected_alarms=${expected_list}
    ...                          ignored_alarms=${ignored_alarms_list}
    ...                          critical_alarms=${CRITICAL}
    should be equal    ${res["flag_expect_alarm"]}    ${True}

Check Alarm Exist for CP-CL Failure
    &{expected_alarm1}        Create Dictionary    fault_id=4350    fault_name=VNFC unavailable
    @{expected_list}          Create List     ${expected_alarm1}
    &{ignored_alarms1}        Create Dictionary    fault_id=7311    fault_name=No Xn link available
    &{ignored_alarms2}        Create Dictionary    fault_id=7307    fault_name=Xn SCTP setup fail
    &{ignored_alarms3}        Create Dictionary    fault_id=7306    fault_name=Xn SCTP endpoint broken
    @{ignored_alarms_list}    Create List     ${ignored_alarms1}    ${ignored_alarms2}    ${ignored_alarms3}
    &{CRITICAL_ALARM1}        Create Dictionary    severity=critical
    @{CRITICAL}               Create List     ${CRITICAL_ALARM1}
    ${res}    Alarm Operation    operation=check_active_alarms    product_type=vcu    bts_index=0    cudu_index=0
    ...                          expected_alarms=${expected_list}
    ...                          ignored_alarms=${ignored_alarms_list}
    ...                          critical_alarms=${CRITICAL}
    should be equal    ${res["flag_expect_alarm"]}    ${True}

Check Alarm Not Exist
    &{ignored_alarms1}        Create Dictionary    fault_id=7311    fault_name=No Xn link available
    &{ignored_alarms2}        Create Dictionary    fault_id=7307    fault_name=Xn SCTP setup fail
    &{ignored_alarms3}        Create Dictionary    fault_id=7306    fault_name=Xn SCTP endpoint broken
    @{ignored_alarms_list}    Create List     ${ignored_alarms1}    ${ignored_alarms2}    ${ignored_alarms3}
    &{CRITICAL_ALARM1}        Create Dictionary    severity=critical
    @{CRITICAL}               Create List     ${CRITICAL_ALARM1}
    ${res}    Alarm Operation    operation=check_active_alarms    product_type=vcu    bts_index=0    cudu_index=0
    ...                          expected_alarms=${None}
    ...                          ignored_alarms=${ignored_alarms_list}
    ...                          critical_alarms=${CRITICAL}
    should be equal    ${res["flag_expect_alarm"]}    ${False}

Start Counter In vCU
    ${rule1}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID};
    ...         Counter: M55119C00011,M55119C00014,M55121C00501,M55121C00502;
    ...         Counter rule: max(M55119C00011)>=2 and max(M55119C00014)>=2 and
    ...         max(M55121C00501)>=2 and max(M55121C00502)>=2;
	${rule2}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRDU-1;
    ...         Counter: M55150C00008,M55150C00009;
    ...         Counter rule: max(M55150C00008)>=2 and max(M55150C00009)>=2;
    ${rule_list}    Create List    ${rule1}    ${rule2}
    Start Counter    rule_list=${rule_list}    product_type=vcu    bts_index=${0}

Start Counter In vCU For CP-CL Failure
    ${rule1}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID};
    ...         Counter: M55119C00011,M55119C00014,M55121C00501,M55121C00502;
    ...         Counter rule: max(M55119C00011)>=2 and max(M55119C00014)>=2 and
    ...         max(M55121C00501)>=2 and max(M55121C00502)>=2;
    ${rule_list}    Create List    ${rule1}
    Start Counter    rule_list=${rule_list}    product_type=vcu    bts_index=${0}

Start Counter In vCU For CP-NRT Failure
    Start Counter In vCU
    ${rule1}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID};
    ...         Counter: M55119C00011,M55119C00014;
    ...         Counter rule: max(M55119C00011)>=2 and max(M55119C00014)>=2;
	${rule2}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRDU-1;
    ...         Counter: M55150C00008,M55150C00009;
    ...         Counter rule: max(M55150C00008)>=2 and max(M55150C00009)>=2;
    ${rule_list}    Create List    ${rule1}    ${rule2}
    Start Counter    rule_list=${rule_list}    product_type=vcu    bts_index=${0}

Add Value To Dictionary Key
    [Arguments]    ${message_count_dict}    ${update_key}    ${add_value}
    ${new_value}    Evaluate    ${message_count_dict}[${update_key}] + ${add_value}
    Set To Dictionary    ${message_count_dict}    ${update_key}=${new_value}

Check Alarm for cell lock and unlock in VCU
    &{ignored_alarms1}        Create Dictionary    fault_id=7311    fault_name=No Xn link available
    &{ignored_alarms2}        Create Dictionary    fault_id=7307    fault_name=Xn SCTP setup fail
    &{ignored_alarms3}        Create Dictionary    fault_id=7306    fault_name=Xn SCTP endpoint broken
    @{ignored_alarms_list}    Create List     ${ignored_alarms1}    ${ignored_alarms2}    ${ignored_alarms3}
    &{CRITICAL_ALARM1}        Create Dictionary    severity=critical
    @{CRITICAL}               Create List     ${CRITICAL_ALARM1}
    ${res}    Alarm Operation    operation=check_active_alarms    product_type=vcu    bts_index=0    cudu_index=0
    ...                          expected_alarms=${None}
    ...                          ignored_alarms=${ignored_alarms_list}
    ...                          critical_alarms=${CRITICAL}
    should be equal    ${res["flag_expect_alarm"]}    ${False}

Check Alarm for cell lock and unlock in VDU
    &{CRITICAL_ALARM1}        Create Dictionary    severity=critical
    @{CRITICAL}               Create List     ${CRITICAL_ALARM1}
    ${res}    Alarm Operation    operation=check_active_alarms    product_type=vdu    bts_index=0    cudu_index=0
    ...                          expected_alarms=${None}
    ...                          ignored_alarms=${None}
    ...                          critical_alarms=${CRITICAL}
    should be equal    ${res["flag_expect_alarm"]}    ${False}

Check Alarm for cell block and unblock in VCU
    &{expected_alarms1}    Create Dictionary    fault_id=7104    fault_name=Matching ServedCell not found over F1-C
    @{expected_list}          Create List     ${expected_alarms1}
    &{ignored_alarms1}        Create Dictionary    fault_id=7311    fault_name=No Xn link available
    &{ignored_alarms2}        Create Dictionary    fault_id=7307    fault_name=Xn SCTP setup fail
    &{ignored_alarms3}        Create Dictionary    fault_id=7306    fault_name=Xn SCTP endpoint broken
    @{ignored_alarms_list}    Create List     ${ignored_alarms1}    ${ignored_alarms2}    ${ignored_alarms3}
    &{CRITICAL_ALARM1}        Create Dictionary    severity=critical
    @{CRITICAL}               Create List     ${CRITICAL_ALARM1}
    ${res}    Alarm Operation    operation=check_active_alarms    product_type=vcu    bts_index=0    cudu_index=0
    ...                          expected_alarms=${expected_list}
    ...                          ignored_alarms=${ignored_alarms_list}
    ...                          critical_alarms=${CRITICAL}
    should be equal    ${res["flag_expect_alarm"]}    ${True}

Check Alarm for cell block and unblock in VDU
    &{expected_alarms1}        Create Dictionary    fault_id=49    fault_name=Cell blocked
    @{expected_list}          Create List     ${expected_alarms1}
    &{CRITICAL_ALARM1}        Create Dictionary    severity=critical
    @{CRITICAL}               Create List     ${CRITICAL_ALARM1}
    ${res}    Alarm Operation    operation=check_active_alarms    product_type=vdu    bts_index=0    cudu_index=0
    ...                          expected_alarms=${expected_list}
    ...                          ignored_alarms=${None}
    ...                          critical_alarms=${CRITICAL}
    should be equal    ${res["flag_expect_alarm"]}    ${True}

Check Alarm for RU reset in VDU
    &{expected_alarms1}        Create Dictionary    fault_id=4675    fault_name=PTP Master port Q_RF1_1 disabled
    &{expected_alarms2}        Create Dictionary    fault_id=4675    fault_name=PTP Master port Q_RF1_2 disabled
    &{expected_alarms3}        Create Dictionary    fault_id=4675    fault_name=PTP Master port Q_RF1_3 disabled
    @{expected_list}          Create List     ${expected_alarms1}    ${expected_alarms2}    ${expected_alarms3}
    &{CRITICAL_ALARM1}        Create Dictionary    severity=critical
    @{CRITICAL}               Create List     ${CRITICAL_ALARM1}
    ${res}    Alarm Operation    operation=check_active_alarms    product_type=vdu    bts_index=0    cudu_index=0
    ...                          expected_alarms=${expected_list}
    ...                          ignored_alarms=${None}
    ...                          critical_alarms=${CRITICAL}
    should be equal    ${res["flag_expect_alarm"]}    ${True}

Check Alarm for VCU reset in VCU
    &{expected_alarms1}    Create Dictionary    fault_id=7104    fault_name=Matching ServedCell not found over F1-C
    &{expected_alarms2}        Create Dictionary    fault_id=4592    fault_name=BTS Reset Cause
    @{expected_list}          Create List     ${expected_alarms1}    ${expected_alarms2}
    &{ignored_alarms1}        Create Dictionary    fault_id=7311    fault_name=No Xn link available
    &{ignored_alarms2}        Create Dictionary    fault_id=7307    fault_name=Xn SCTP setup fail
    &{ignored_alarms3}        Create Dictionary    fault_id=7306    fault_name=Xn SCTP endpoint broken
    @{ignored_alarms_list}    Create List     ${ignored_alarms1}    ${ignored_alarms2}    ${ignored_alarms3}
    &{CRITICAL_ALARM1}        Create Dictionary    severity=critical
    @{CRITICAL}               Create List     ${CRITICAL_ALARM1}
    ${res}    Alarm Operation    operation=check_active_alarms    product_type=vcu    bts_index=0    cudu_index=0
    ...                          expected_alarms=${expected_list}
    ...                          ignored_alarms=${ignored_alarms_list}
    ...                          critical_alarms=${CRITICAL}
    should be equal    ${res["flag_expect_alarm"]}    ${True}

Check Alarm for VCU reset in VDU
    &{expected_alarms1}        Create Dictionary    fault_id=7504    fault_name=F1 SCTP endpoint in DU
    @{expected_list}          Create List     ${expected_alarms1}
    &{CRITICAL_ALARM1}        Create Dictionary    severity=critical
    @{CRITICAL}               Create List     ${CRITICAL_ALARM1}
    ${res}    Alarm Operation    operation=check_active_alarms    product_type=vdu    bts_index=0    cudu_index=0
    ...                          expected_alarms=${expected_list}
    ...                          ignored_alarms=${None}
    ...                          critical_alarms=${CRITICAL}
    should be equal    ${res["flag_expect_alarm"]}    ${True}

Check Alarm for VDU reset in VDU
    &{expected_alarms1}        Create Dictionary    fault_id=4592    fault_name=BTS Reset Cause
    @{expected_list}          Create List     ${expected_alarms1}
    &{CRITICAL_ALARM1}        Create Dictionary    severity=critical
    @{CRITICAL}               Create List     ${CRITICAL_ALARM1}
    ${res}    Alarm Operation    operation=check_active_alarms    product_type=vdu    bts_index=0    cudu_index=0
    ...                          expected_alarms=${expected_list}
    ...                          ignored_alarms=${None}
    ...                          critical_alarms=${CRITICAL}
    should be equal    ${res["flag_expect_alarm"]}    ${True}

Check Alarm for RANNIC reset in VDU
    &{ignored_alarms1}        Create Dictionary    fault_id=4298    fault_name=ToP reference missing
    &{ignored_alarms2}        Create Dictionary    fault_id=16    fault_name=Unit synchronization failed
    &{ignored_alarms3}        Create Dictionary    fault_id=4405    fault_name=No usable time reference available
    @{ignored_alarms_list}    Create List     ${ignored_alarms1}    ${ignored_alarms2}    ${ignored_alarms3}
    &{CRITICAL_ALARM1}        Create Dictionary    severity=critical
    @{CRITICAL}               Create List     ${CRITICAL_ALARM1}
    ${res}    Alarm Operation    operation=check_active_alarms    product_type=vdu    bts_index=0    cudu_index=0
    ...                          expected_alarms=${None}
    ...                          ignored_alarms=${ignored_alarms_list}
    ...                          critical_alarms=${CRITICAL}
    should be equal    ${res["flag_expect_alarm"]}    ${False}

VCU_VDU_Health_Check
    BTS Operation    operation=verify    product_type=vcu    distname_id=NRCELL-ALL           verify_status=CELL_ONAIR
    BTS Operation    operation=verify    product_type=vdu    distname_id=RMOD-ALL             verify_status=RRU_ONAIR
    BTS Operation    operation=verify    product_type=vdu    distname_id=NRCELL-ALL           verify_status=CELL_ONAIR