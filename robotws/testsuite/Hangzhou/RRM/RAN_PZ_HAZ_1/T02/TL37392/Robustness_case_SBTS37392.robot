*** Settings ***
Documentation
...   Author: qianqian.guo@nokia-sbell.com
...   Contact: qianqian.guo@nokia-sbell.com
...   Description: this robot case focus on paging and PDCCH tools using in MantaRay


Suite Setup       Common Suite Setup For RRM
Suite Teardown    Common Suite Teardown For RRM


Force Tags
...      Robustness             #Tag Item
...      TRUNK
...      RAN_PZ_HAZ_1             #Competence Area
...      RAN_PZ_HAZ1_TG02_ST_RRM  #Organization
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout    600 minutes

Library           SSHLibrary
Resource          ../../Resources/Classical/RRM_Common_Resource.robot
Resource          ../../T02/Common_Case/common_resource_new.robot

*** Variables ***
${NEED_RECOVERY}    False
${Trunk_Prefix}    SBTS00
${mplan_ip}    10.69.53.14
${COMMISSIONING_PATH}    /home/ute/testline_configuration/10_5_UTESRAN003T37392/37392_scf_plan_for_CB012125_case11.xml
${serials}    7TD5T21423000785
${dn_list}    PLMN-PLMN/MRBTS-37392

*** Test Cases ***
SBTS37392_Robustness_case1_cell_block_unblock_more_times
    [Tags]    Robustness    case1    lock    cell
    [Documentation]    cells block and unblock more times
    ...    Author: qianqian.guo@nokia-sbell.com
    ...    history change: 2025-01-11,Guo Qianqian,Create the test case
    [Setup]    Case Precondition
    FOR    ${i}    IN RANGE    5
        Log To Console    \n***run${i}***
        Log To Console    step1: block cell1
        BTS Operation    operation=cell_block    product_type=gnb    bts_index=0    distname_id=NRCELL-1
        ...    need_verify=True
        Sleep    10s
        Log To Console    unblock cell1
        BTS Operation    operation=cell_unblock    product_type=gnb    bts_index=0    distname_id=NRCELL-1
        ...    need_verify=True
        Sleep    20s
        Log To Console    step2: block cell2
        BTS Operation    operation=cell_block    product_type=gnb    bts_index=0    distname_id=NRCELL-2
        ...    need_verify=True
        Sleep    10s
        Log To Console    unblock cell2
        BTS Operation    operation=cell_unblock    product_type=gnb    bts_index=0    distname_id=NRCELL-2
        ...    need_verify=True
        Sleep    20s
        Log To Console    step3: block cell3
        BTS Operation    operation=cell_block    product_type=gnb    bts_index=0    distname_id=NRCELL-3
        ...    need_verify=True
        Sleep    10s
        Log To Console    unblock cell3
        BTS Operation    operation=cell_unblock    product_type=gnb    bts_index=0    distname_id=NRCELL-3
        ...    need_verify=True
        Sleep    20s
    END
    Sleep    120s
    Log To Console    step4: Check alarms
    Check Alarm for cell lock and unlock
    Log To Console    cell_BBMOD_RRU_Site_ONAIR_Check
    Cell_BBMOD_RRU_Site_ONAIR
    #Log To Console    step5:make voice call under NRCELL-3 and NRCELL-2    console=${True}
    #Make Voice call under NRCELL-3 and NRCELL-2
    [Teardown]    Case Postcondition

SBTS37392_Robustness_case2_RU_lock_unlock_more_times
    [Tags]    Robustness    case2    lock    RU
    [Documentation]    RUs lock and unlock more times
    ...    Author: qianqian.guo@nokia-sbell.com
    ...    history change: 2025-01-14,Guo Qianqian,Create the test case
    [Setup]    Case Precondition
    FOR    ${i}    IN RANGE    5
        Log To Console    \n***run${i}***
        Log To Console    step1: lock RMOD-1
        BTS Operation    operation=ru_lock    product_type=gnb    bts_index=0    distname_id=RMOD-1
        ...    need_verify=True
        Sleep    30s
        Log To Console    unblock RMOD-1
        BTS Operation    operation=ru_unlock    product_type=gnb    bts_index=0    distname_id=RMOD-1
        ...    need_verify=True
        Sleep    30s
        Log To Console    step2: lock RMOD-2
        BTS Operation    operation=ru_lock    product_type=gnb    bts_index=0    distname_id=RMOD-2
        ...    need_verify=True
        Sleep    30s
        Log To Console    unblock RMOD-2
        BTS Operation    operation=ru_unlock    product_type=gnb    bts_index=0    distname_id=RMOD-2
        ...    need_verify=True
        Sleep    30s
        Log To Console    step3: lock RMOD-3
        BTS Operation    operation=ru_lock    product_type=gnb    bts_index=0    distname_id=RMOD-3
        ...    need_verify=True
        Sleep    30s
        Log To Console    unblock RMOD-3
        BTS Operation    operation=ru_unlock    product_type=gnb    bts_index=0    distname_id=RMOD-3
        ...    need_verify=True
        Sleep    30s
    END
    Sleep    120s
    Log To Console    step4: Check alarms
    Check Alarm for RU lock and unlock
    Log To Console    cell_BBMOD_RRU_Site_ONAIR_Check
    Cell_BBMOD_RRU_Site_ONAIR
    [Teardown]    Case Postcondition

SBTS37392_Robustness_case3_BBMOD_lock_unlock_more_times
    [Tags]    Robustness    case3    lock    BBMOD
    [Documentation]    BBMODs lock and unlock more times
    ...    Author: qianqian.guo@nokia-sbell.com
    ...    history change: 2025-01-17,Guo Qianqian,Create the test case
    [Setup]    Case Precondition
    FOR    ${i}    IN RANGE    5
        Log To Console    \n***run${i}***
        Log To Console    step1: lock BBMOD-1
        BTS Operation    operation=bbmod_lock    product_type=gnb    bts_index=0    distname_id=BBMOD-1
        ...    need_verify=True
        Sleep    30s
        Log To Console    unblock BBMOD-1
        BTS Operation    operation=bbmod_unlock    product_type=gnb    bts_index=0    distname_id=BBMOD-1
        ...    need_verify=True
        Sleep    30s
        Log To Console    step2: lock BBMOD-2
        BTS Operation    operation=bbmod_lock    product_type=gnb    bts_index=0    distname_id=BBMOD-2
        ...    need_verify=True
        Sleep    30s
        Log To Console    unblock BBMOD-2
        BTS Operation    operation=bbmod_unlock    product_type=gnb    bts_index=0    distname_id=BBMOD-2
        ...    need_verify=True
        Sleep    30s
        Log To Console    step3: lock BBMOD-3
        BTS Operation    operation=bbmod_lock    product_type=gnb    bts_index=0    distname_id=BBMOD-3
        ...    need_verify=True
        Sleep    30s
        Log To Console    unblock BBMOD-3
        BTS Operation    operation=bbmod_unlock    product_type=gnb    bts_index=0    distname_id=BBMOD-3
        ...    need_verify=True
        Sleep    30s
    END
    Sleep    120s
    Log To Console    step4: Check alarms
    Check Alarm for BBMOD lock and unlock
    Log To Console    cell_BBMOD_RRU_Site_ONAIR_Check
    Cell_BBMOD_RRU_Site_ONAIR
    [Teardown]    Case Postcondition

SBTS37392_Robustness_case4_NR-RAT_lock_unlock_more_times
        [Tags]    Robustness    case4    lock    RAT
    [Documentation]    NR-RAT lock and unlock more times
    ...    Author: qianqian.guo@nokia-sbell.com
    ...    history change: 2025-01-17,Guo Qianqian,Create the test case
    [Setup]    Case Precondition
    FOR    ${i}    IN RANGE    5
        Log To Console    \n***run${i}***lock NR-RAT***
        BTS Operation    operation=rat_lock    product_type=gnb    bts_index=0    distname_id=NRCELL-ALL
        ...    need_verify=True
        Sleep    30s
        Log To Console    \n***unblock NR-RAT***
        BTS Operation    operation=rat_unlock    product_type=gnb    bts_index=0    distname_id=NRCELL-ALL
        ...    need_verify=True
        Sleep    30s
    END
    Sleep    120s
    Check Alarm for NR-RAT lock and unlock
    Log To Console    cell_BBMOD_RRU_Site_ONAIR_Check
    Cell_BBMOD_RRU_Site_ONAIR
    [Teardown]    Case Postcondition

SBTS37392_Robustness_case5_NG_link_lock_unlock_more_times
    [Tags]    Robustness    case5    lock    NG
    [Documentation]    NG links lock and unlock more times
    ...    Author: qianqian.guo@nokia-sbell.com
    ...    history change: 2025-01-17,Guo Qianqian,Create the test case
    [Setup]    Case Precondition
    FOR    ${i}    IN RANGE    5
        Log To Console    \n***run${i}***
        Log To Console    step1: lock NG-Link-1
        BTS Operation    operation=nglink_lock    product_type=gnb    bts_index=0
        ...    distname_id=NRBTS-${NRBTS_ID}/SERVEDAMF-1    need_verify=True
        Sleep    30s
        Log To Console    unblock NG-Link-1
        BTS Operation    operation=nglink_unlock    product_type=gnb    bts_index=0
        ...    distname_id=NRBTS-${NRBTS_ID}/SERVEDAMF-1    need_verify=True
        Sleep    30s
        Log To Console    step2: lock NG-Link-2
        BTS Operation    operation=nglink_lock    product_type=gnb    bts_index=0
        ...    distname_id=NRBTS-${NRBTS_ID}/SERVEDAMF-2    need_verify=True
        Sleep    30s
        Log To Console    unblock NG-Link-2
        BTS Operation    operation=nglink_unlock    product_type=gnb    bts_index=0
        ...    distname_id=NRBTS-${NRBTS_ID}/SERVEDAMF-2    need_verify=True
        Sleep    30s
    END
    Sleep    120s
    Check Alarm for BBMOD lock and unlock
    Log To Console    cell_BBMOD_RRU_Site_ONAIR_Check
    Cell_BBMOD_RRU_Site_ONAIR
    [Teardown]    Case Postcondition

SBTS37392_Robustness_case6_BBMOD_Reset_more_times
    [Tags]    Robustness    case6    reset    BBMOD
    [Documentation]    BBMODs reset more times
    ...    Author: qianqian.guo@nokia-sbell.com
    ...    history change: 2025-01-17,Guo Qianqian,Create the test case
    [Setup]    Case Precondition
    FOR    ${i}    IN RANGE    5
        Log To Console    \n***run${i}***
        Log To Console    step1: reset BBMOD-1
        BTS Operation    operation=bbmod_reset    product_type=gnb    bts_index=0    distname_id=BBMOD-1
        ...    need_verify=True
        Sleep    300s
        Log To Console    step2: reset BBMOD-2
        BTS Operation    operation=bbmod_reset    product_type=gnb    bts_index=0    distname_id=BBMOD-2
        ...    need_verify=True
        Sleep    300s
        Log To Console    step3: reset BBMOD-3
        BTS Operation    operation=bbmod_reset    product_type=gnb    bts_index=0    distname_id=BBMOD-3
        ...    need_verify=True
        Sleep    300s
    END
    Sleep    120s
    Log To Console    step4: Check alarms
    Check Alarm for BBMOD lock and unlock
    Log To Console    cell_BBMOD_RRU_Site_ONAIR_Check
    Cell_BBMOD_RRU_Site_ONAIR
    [Teardown]    Case Postcondition

SBTS37392_Robustness_case7_cell_Reset_more_times
    [Tags]    Robustness    case7    reset    cell
    [Documentation]    cells reset more times
    ...    Author: qianqian.guo@nokia-sbell.com
    ...    history change: 2025-01-11,Guo Qianqian,Create the test case
    [Setup]    Case Precondition
    FOR    ${i}    IN RANGE    5
        Log To Console    \n***run${i}***
        Log To Console    step1: reset cell1
        BTS Operation    operation=cell_reset    product_type=gnb    bts_index=0    distname_id=NRCELL-1
        ...    need_verify=True
        Sleep    30s
        Log To Console    step2: reset cell2
        BTS Operation    operation=cell_reset    product_type=gnb    bts_index=0    distname_id=NRCELL-2
        ...    need_verify=True
        Sleep    30s
        Log To Console    step3: reset cell3
        BTS Operation    operation=cell_reset    product_type=gnb    bts_index=0    distname_id=NRCELL-3
        ...    need_verify=True
        Sleep    30s
    END
    Sleep    60s
    Log To Console    step4: Check alarms
    Check Alarm for BBMOD lock and unlock
    Log To Console    cell_BBMOD_RRU_Site_ONAIR_Check
    Cell_BBMOD_RRU_Site_ONAIR
    [Teardown]    Case Postcondition

SBTS37392_Robustness_case8_NR-RAT_Reset_more_times
        [Tags]    Robustness    case8    reset    RAT
    [Documentation]    NR-RAT reset more times
    ...    Author: qianqian.guo@nokia-sbell.com
    ...    history change: 2025-01-17,Guo Qianqian,Create the test case
    [Setup]    Case Precondition
    FOR    ${i}    IN RANGE    5
        Log To Console    \n***run${i}***step1: reset NR-RAT Hard
        BTS Operation    operation=rat_reset    product_type=gnb    bts_index=0    distname_id=NRCELL-ALL
        ...    need_verify=True    reset_type=Hard
        Sleep    200s
    END
    Sleep    60s
    Log To Console    Check alarms
    Check Alarm for BBMOD lock and unlock
    Log To Console    cell_BBMOD_RRU_Site_ONAIR_Check
    Cell_BBMOD_RRU_Site_ONAIR
    FOR    ${i}    IN RANGE    5
        Log To Console    \n***run${i}***step2: reset NR-RAT Soft***
        BTS Operation    operation=rat_reset    product_type=gnb    bts_index=0    distname_id=NRCELL-ALL
        ...    need_verify=True    reset_type=Soft
        Sleep    200s
    END
    Sleep    60s
    Log To Console    Check alarms
    Check Alarm for BBMOD lock and unlock
    Log To Console    cell_BBMOD_RRU_Site_ONAIR_Check
    Cell_BBMOD_RRU_Site_ONAIR
    [Teardown]    Case Postcondition

SBTS37392_Robustness_case9_RU_reset_more_times
    [Tags]    Robustness    case9    reset    RU
    [Documentation]    RUs reset more times
    ...    Author: qianqian.guo@nokia-sbell.com
    ...    history change: 2025-01-17,Guo Qianqian,Create the test case
    [Setup]    Case Precondition
    FOR    ${i}    IN RANGE    5
        Log To Console    \n***run${i}***
        Log To Console    step1: reset RMOD-1
        BTS Operation    operation=ru_reset    product_type=gnb    bts_index=0    distname_id=RMOD-1
        ...    need_verify=True
        Sleep    600s
        Log To Console    step2: reset RMOD-2
        BTS Operation    operation=ru_reset    product_type=gnb    bts_index=0    distname_id=RMOD-2
        ...    need_verify=True
        Sleep    600s
        Log To Console    step3: reset RMOD-3
        BTS Operation    operation=ru_reset    product_type=gnb    bts_index=0    distname_id=RMOD-3
        ...    need_verify=True
        Sleep    600s
    END
    Sleep    60s
    Log To Console    step4: Check alarms
    Check Alarm for RU lock and unlock
    Log To Console    cell_BBMOD_RRU_Site_ONAIR_Check
    Cell_BBMOD_RRU_Site_ONAIR
    [Teardown]    Case Postcondition

SBTS37392_Robustness_case10_BTS_Reset_more_times
        [Tags]    Robustness    case10    reset    BTS
    [Documentation]    BTS reset more times
    ...    Author: qianqian.guo@nokia-sbell.com
    ...    history change: 2025-01-17,Guo Qianqian,Create the test case
    [Setup]    Case Precondition
    FOR    ${i}    IN RANGE    5
        Log To Console    \n***run${i}***step1: reset BTS without RU Reset***
        BTS Operation    operation=bts_reset    product_type=gnb    bts_index=0    need_verify=True
        ...    reset_without_ru=${True}
        Sleep    600s
    END
    Sleep    60s
    Log To Console    Check alarms
    Check Alarm for BBMOD lock and unlock
    Log To Console    cell_BBMOD_RRU_Site_ONAIR_Check
    Cell_BBMOD_RRU_Site_ONAIR
    FOR    ${i}    IN RANGE    5
        Log To Console    \n***run${i}***step2: reset BTS with RU Reset***
        BTS Operation    operation=rat_reset    product_type=gnb    bts_index=0    need_verify=True
        ...    reset_without_ru=${False}
        Sleep    600s
    END
    Sleep    60s
    Log To Console    Check alarms
    Check Alarm for BBMOD lock and unlock
    Log To Console    cell_BBMOD_RRU_Site_ONAIR_Check
    Cell_BBMOD_RRU_Site_ONAIR
    [Teardown]    Case Postcondition

*** Keywords ***
Case Precondition
    log to console    Case Precondition
    Common Test Setup For RRM

Case Postcondition
    log to console    Case Postcondition
    Common Test Teardown For RRM
    #Get SCF Internal Id By Scout    no_ute=False

Cell_BBMOD_RRU_Site_ONAIR
    BTS Operation    operation=verify    product_type=gnb    bts_index=0
    ...    verify_status=SITE_ONAIR+CELL_ONAIR+RRU_ONAIR+BBU_ONAIR

Make Voice call under NRCELL-3 and NRCELL-2
    Log To Console    setup PA for cell2
    Initialize PA Value
    PA Operation For cell2
    Log To Console    make call under cell2
    Prepare for UE
    Traffic UE Operation    attach    ue_index=0
    Sleep    60s
    Traffic UE Operation    start voice call    ue_index=0    dial=006688    duration=300s
    #Sleep    400s
    Traffic UE Operation    stop voice call    ue_index=0
    Log To Console    setup PA for cell3
    PA Operation For cell3
    Log To Console    make call under cell3
    Traffic UE Operation    detach    ue_index=0
    Sleep    60s
    Traffic UE Operation    attach    ue_index=0
    Sleep    60s
    Traffic UE Operation    start voice call    ue_index=0    dial=006688    duration=200s
    #Sleep    400s
    Traffic UE Operation    stop voice call    ue_index=0

Initialize PA Value
    ${pa_port_list}    ${pa_value_list}    Split And Expand PA Parameters    pa_port=1-16;    pa_value=127;
    &{source}    Create Dictionary    att_index=${1}    pa_port=${pa_port_list}    pa_value=${pa_value_list}
    ...                               step=${2}
    PA Operation    operation=Initialize PA Value    source=&{source}

PA Operation For cell2
    ${source_pa_port_list}     Create List     5-8
    ${source_pa_value_list}    Create List     0    2
    &{source}    Create Dictionary    att_index=${1}    pa_port=${source_pa_port_list}    pa_value=${source_pa_value_list}
    ...                               step=${2}    pa_type=16*16
    PA Operation    source=&{source}    target=none

PA Operation For cell3
    ${source_pa_port_list}     Create List     5-8
    ${source_pa_value_list}    Create List     120    127
    ${target_pa_port_list}     Create List     3-4
    ${target_pa_value_list}    Create List     0    2
    &{source}    Create Dictionary    att_index=${1}    pa_port=${source_pa_port_list}    pa_value=${source_pa_value_list}
    ...                               step=${2}    pa_type=16*8
    &{target}    Create Dictionary    att_index=${1}    pa_port=${source_pa_port_list}    pa_value=${source_pa_value_list}
    ...                               step=${2}    pa_type=16*8
    PA Operation    source=&{source}    target=&{target}


Prepare for UE
    FOR    ${ue}    IN    @{uelist}
        ${ue.obj}=    Pet UE Setup    ue_type=android    host=${ue.info.pc}    serialno=${ue.info.serial}
        Run keyword and ignore error    Pet Ue Cancel Voice Call    ue=${ue.obj}
        Pet UE deattach    ue=${ue.obj}    points=${ue.info.attach_point}
    END

Get Nrcell Name
    ${nrcell_name_list}  Create List
    COAM_Admin.Login    bts_host=${mplan_ip}    username=Nemuadmin    password=nemuuser
    ${cell_list}    Get All Cell Id    connection=COAM
    FOR    ${cell_id}    IN    @{cell_list}
        append to list    ${nrcell_name_list}    NRCELL-${cell_id}
    END
    Set Test Variable    ${nrcell_name_list}
    [Teardown]    COAM_Admin.Logout
    [Return]    ${nrcell_name_list}

Check Alarm for cell lock and unlock
    &{ignored_alarms1}        Create Dictionary    fault_id=4654    fault_name=Ethernet port security is disabled
    &{ignored_alarms2}        Create Dictionary    fault_id=61524    fault_name=SSH enabled
    &{ignored_alarms3}        Create Dictionary    fault_id=61652    fault_name=R&D Service Port enabled
    &{ignored_alarms4}        Create Dictionary    fault_id=4655    fault_name=Service account root access is enabled
    &{ignored_alarms5}        Create Dictionary    fault_id=7307    fault_name=Xn SCTP setup fail
    &{ignored_alarms6}        Create Dictionary    fault_id=61649    fault_name=LMP access via port 443
    @{ignored_alarms_list}    Create List     ${ignored_alarms1}     ${ignored_alarms2}
                              ...    ${ignored_alarms3}    ${ignored_alarms4}    ${ignored_alarms5}    ${ignored_alarms6}
    &{expected_alarms1}        Create Dictionary    fault_id=49    fault_name=Cell blocked
    @{expected_list}          Create List     ${expected_alarms1}
    &{CRITICAL_ALARM1}        Create Dictionary    severity=critical
    @{CRITICAL}               Create List     ${CRITICAL_ALARM1}
    ${res}    Alarm Operation    operation=check_active_alarms    product_type=enb    bts_index=0
    ...                          expected_alarms=${expected_list}
    ...                          ignored_alarms=${ignored_alarms_list}
    ...                          critical_alarms=${CRITICAL}
    should be equal    ${res["flag_expect_alarm"]}    ${True}

Check Alarm for RU lock and unlock
    &{ignored_alarms1}        Create Dictionary    fault_id=4654    fault_name=Ethernet port security is disabled
    &{ignored_alarms2}        Create Dictionary    fault_id=61524    fault_name=SSH enabled
    &{ignored_alarms3}        Create Dictionary    fault_id=61652    fault_name=R&D Service Port enabled
    &{ignored_alarms4}        Create Dictionary    fault_id=4655    fault_name=Service account root access is enabled
    &{ignored_alarms5}        Create Dictionary    fault_id=7307    fault_name=Xn SCTP setup fail
    &{ignored_alarms6}        Create Dictionary    fault_id=61649    fault_name=LMP access via port 443
    @{ignored_alarms_list}    Create List     ${ignored_alarms1}     ${ignored_alarms2}
                              ...    ${ignored_alarms3}    ${ignored_alarms4}    ${ignored_alarms5}    ${ignored_alarms6}
    &{CRITICAL_ALARM1}        Create Dictionary    severity=critical
    @{CRITICAL}               Create List     ${CRITICAL_ALARM1}
    ${res}    Alarm Operation    operation=check_active_alarms    product_type=enb    bts_index=0
    ...                          expected_alarms=${None}
    ...                          ignored_alarms=${ignored_alarms_list}
    ...                          critical_alarms=${CRITICAL}
    should be equal    ${res["flag_expect_alarm"]}    ${True}

Check Alarm for BBMOD lock and unlock
    &{ignored_alarms1}        Create Dictionary    fault_id=4654    fault_name=Ethernet port security is disabled
    &{ignored_alarms2}        Create Dictionary    fault_id=61524    fault_name=SSH enabled
    &{ignored_alarms3}        Create Dictionary    fault_id=61652    fault_name=R&D Service Port enabled
    &{ignored_alarms4}        Create Dictionary    fault_id=4655    fault_name=Service account root access is enabled
    &{ignored_alarms5}        Create Dictionary    fault_id=7307    fault_name=Xn SCTP setup fail
    &{ignored_alarms6}        Create Dictionary    fault_id=61649    fault_name=LMP access via port 443
    @{ignored_alarms_list}    Create List     ${ignored_alarms1}     ${ignored_alarms2}
                              ...    ${ignored_alarms3}    ${ignored_alarms4}    ${ignored_alarms5}    ${ignored_alarms6}
    &{CRITICAL_ALARM1}        Create Dictionary    severity=critical
    @{CRITICAL}               Create List     ${CRITICAL_ALARM1}
    ${res}    Alarm Operation    operation=check_active_alarms    product_type=enb    bts_index=0
    ...                          expected_alarms=${None}
    ...                          ignored_alarms=${ignored_alarms_list}
    ...                          critical_alarms=${CRITICAL}
    should be equal    ${res["flag_expect_alarm"]}    ${True}

Check Alarm for NR-RAT lock and unlock
    &{ignored_alarms1}        Create Dictionary    fault_id=4654    fault_name=Ethernet port security is disabled
    &{ignored_alarms2}        Create Dictionary    fault_id=61524    fault_name=SSH enabled
    &{ignored_alarms3}        Create Dictionary    fault_id=61652    fault_name=R&D Service Port enabled
    &{ignored_alarms4}        Create Dictionary    fault_id=4655    fault_name=Service account root access is enabled
    &{ignored_alarms5}        Create Dictionary    fault_id=7307    fault_name=Xn SCTP setup fail
    &{ignored_alarms6}        Create Dictionary    fault_id=61649    fault_name=LMP access via port 443
    @{ignored_alarms_list}    Create List     ${ignored_alarms1}     ${ignored_alarms2}
                              ...    ${ignored_alarms3}    ${ignored_alarms4}    ${ignored_alarms5}    ${ignored_alarms6}
    &{expected_alarms1}        Create Dictionary    fault_id=4614    fault_name=RAT blocked
    @{expected_list}          Create List     ${expected_alarms1}
    &{CRITICAL_ALARM1}        Create Dictionary    severity=critical
    @{CRITICAL}               Create List     ${CRITICAL_ALARM1}
    ${res}    Alarm Operation    operation=check_active_alarms    product_type=enb    bts_index=0
    ...                          expected_alarms=${expected_list}
    ...                          ignored_alarms=${ignored_alarms_list}
    ...                          critical_alarms=${CRITICAL}
    should be equal    ${res["flag_expect_alarm"]}    ${True}