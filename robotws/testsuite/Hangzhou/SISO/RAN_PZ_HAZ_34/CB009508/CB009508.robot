# @Time    : 2024/3/4 11:09
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @Group   : NSB MN RAN RD VRF HAZ3 5
# @File    : CB009508.robot
# @Software: PyCharm
# @Doc     : Some Description
*** Settings ***
Documentation
...    some desc
...    RU1: AZQS (ABIO+ABIP)
...    RU2: AHLOA (ABIP)
...    RU3: AEHC (ABIP)
...    RU5: AHLOA (ABIP)
...    RU6: AHLOA (ABIP)
...    RU7: AHFII (ABIP)
...    RU8: AHFIB (ABIP)
...    RU9: AHFIB (ABIP)
...    RU11: AEHC (ABIP)
...    RU12: AEHC (ABIP)
...    RU13: AVQC (ABIP)
Suite Setup         Run Keywords    SISO Coam Suite Setup
Suite Teardown      SISO Coam Suite Teardown
Test Setup          Run Keywords    MMW5 Common Case Setup      allowed_faults_ids=4589
...    AND          COAM Commission with scf file    ${COMMON_SCF}    is_pdl_checking_needed=${False}    timeout=900
...    AND          Wait Until Keyword Succeeds    25min    30s    Verify BTS 5G Cells Status Is Normal State
...    AND          CB009508 Precondition Delta Json
Test Teardown       Run Keywords    Power on all RU    AND    Restore PA    AND    MMW5 Common Case Teardown
Force Tags          CRT_TRUNK    PY36

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/feature/CB009508_common_keywords.robot

*** Variables ***
${if_commissioning}                 False
${COMMON_SCF}                       ${CURDIR}/Resource_TMO/COMMON_SCF.xml
# Pre-prepared
${REMOVE_RU1_DELTA}                 ${CURDIR}/Resource_TMO/REMOVE_RU1_DELTA.json
${REMOVE_RU3_DELTA}                 ${CURDIR}/Resource_TMO/REMOVE_RU3_DELTA.json
${REMOVE_RU1_13_DELTA}                 ${CURDIR}/Resource_TMO/REMOVE_RU1_13_DELTA.json
${REMOVE_RU1_3_13_DELTA}              ${CURDIR}/Resource_TMO/REMOVE_RU1_3_13_DELTA.json
${REMOVE_ABIO_ABIP_RU113_DELTA}    ${CURDIR}/Resource_TMO/REMOVE_ABIO_ABIP_RU113_DELTA.json
#${REMOVE_ABIO_ABIP_RU3456_DELTA_NEW}    ${CURDIR}/Resource_TMO/REMOVE_ABIO_ABIP_RU3456_DELTA_NEW.json
#${REMOVE_BB13_RU12_DELTA}           ${CURDIR}/Resource_TMO/REMOVE_BB13_RU12_DELTA.json
${MODIFY_RU3_NO_RU1_13_DELTA}        ${CURDIR}/Resource_TMO/MODIFY_RU3_NO_RU1_13_DELTA.json
${ADD_CELLSCALCULATIONREQ_DELTA_PATH}    ${CURDIR}/Resource_TMO/ADD_CELLSCALCULATIONREQ.json

# Auto-generated
${CREATE_RU1_DELTA}                 ${CURDIR}/Resource_TMO/CREATE_RU1_DELTA.json
${CREATE_RU3_DELTA}                 ${CURDIR}/Resource_TMO/CREATE_RU3_DELTA.json
${CREATE_RU1_13_DELTA}              ${CURDIR}/Resource_TMO/CREATE_RU1_13_DELTA.json    # based on REMOVE_RU1_13_DELTA.json
${CREATE_RU1_3_13_DELTA}            ${CURDIR}/Resource_TMO/CREATE_RU3456_DELTA.json
${CREATE_ABIO_ABIP_RU113_DELTA}     ${CURDIR}/Resource_TMO/CREATE_ABIO_ABIP_RU113_DELTA.json
#${CREATE_BB13_RU12_DELTA}           ${CURDIR}/Resource_TMO/CREATE_BB13_RU12_DELTA.json
${CREATE_RU3_NO_RU1_13_DELTA}        ${CURDIR}/Resource_TMO/CREATE_RU3_NO_RU1_13_DELTA.json

${COMMON_110_SCF}                   ${CURDIR}/Resource_TMO/COMMON_110_SCF.xml
${COMMON_110_SCF_PMCCP}                   ${CURDIR}/../../../../../commissionings/HGZ/7_5_UTE5G402T2027/COMMON_110_SCF_PMCCP.xml
${NO_RU3_SCF}                       ${CURDIR}/Resource_TMO/NO_RU3_SCF.xml
${NO_RU3_CELL_SCF}                  ${CURDIR}/Resource_TMO/NO_RU3_CELL_SCF.xml
${NO_RU3_CELL_SCF_PMCCP}                  ${CURDIR}/../../../../../commissionings/HGZ/7_5_UTE5G402T2027/NO_RU3_CELL_SCF_PMCCP.xml
${REMOVE_RU3_DELTA_110}             ${CURDIR}/Resource_TMO/REMOVE_RU3_DELTA_110.json
${CREATE_RU3_NO_CELL_DELTA_110}         ${CURDIR}/Resource_TMO/CREATE_RU3_NO_CELL_DELTA_110.json
${CREATE_RU3_CELL_DELTA_110}            ${CURDIR}/Resource_TMO/CREATE_RU3_CELL_DELTA_110.json
${NO_USE_DELTA}                     ${CURDIR}/Resource_TMO/NO_USE_DALTA.json

${LOCK_RU113_DELTA}                  ${CURDIR}/Resource_TMO/LOCK_RU113_DELTA.json

@{RU_INDEX_1313}    ${1}    ${3}    ${13}
@{RU_INDEX_3}    ${3}
@{RU_INDEX_1}    ${1}
@{RU_INDEX_113}    ${1}    ${13}
@{RU113_FAULT_10}    [MRBTS-${MRBTS_ID}] MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
...    [MRBTS-${MRBTS_ID}] MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-13

@{RU3_FAULT_10}    [MRBTS-${MRBTS_ID}] MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-3
@{RU1_FAULT_10}    [MRBTS-${MRBTS_ID}] MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
@{NR_FAULT_4715}    [MRBTS-${MRBTS_ID}] MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-25
...    [MRBTS-${MRBTS_ID}] MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-26
...    [MRBTS-${MRBTS_ID}] MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-27
...    [MRBTS-${MRBTS_ID}] MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-28
...    [MRBTS-${MRBTS_ID}] MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-29

@{CELL8_DISTNAMES}    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-25
...    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-26
...    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-27
...    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-28
...    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-29
...    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-13
...    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-14
...    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-15

*** Test Cases ***
CB009508_A_102_Delta_commission_first_and_RMOD_HW_installation_later
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/03/04 11:42
    ...    Delete RU 1 3 13
    [Tags]    c102
    CB009508 Precondition Common Delete    ${REMOVE_RU1_3_13_DELTA}      ${RU_INDEX_1313}
    AlarmWatchdog.add_allow_alarms   fault_id=10
    AlarmWatchdog.add_allow_alarms   fault_id=4589
    # Step 1: add ru3, check fault 10
    coam.perform_delta_recommissioning    delta_file=${CREATE_RU3_NO_RU1_13_DELTA}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Wait Until Keyword Succeeds    20min    20s    Verify BTS Alarm Configuration Alarming Objects
    ...    fault_id=10    fault_name=No connection to unit
    ...    objects=@{RU3_FAULT_10}

    # Step 2: ru 3 power on, cell on air
    Log to console  step2 power on RU3
    FOR    ${index}    IN    @{RU_INDEX_3}
        Perform RU Power On    ru_index=${index}
    END

    #check original cell status
    Verify original Cell History Status Normal

    Wait Until Keyword Succeeds    20min    15s    CI_commssion.Verify all cells should be Online
    AlarmWatchdog.remove_allow_alarms   fault_id=10
    AlarmWatchdog.remove_allow_alarms   fault_id=4589

    Log to console    modify RU PA, keep only AEHC-3
    gnb_classical_hangzhou.Get Initial Attenuation Values For RU    vendor=HBTE
    ${channels_to_modify}    create dictionary    5=127    6=127
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=0
    ${channels_to_modify}    create dictionary    3=127    4=127
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=1
    ${channels_to_modify}    create dictionary    9=0    10=0    11=0    12=0
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=2
    ${channels_to_modify}    create dictionary    1=127    2=127
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=6
    ${channels_to_modify}    create dictionary    7=127    8=127
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=12

    # Step 3: ue attach ru3 lte cell ok
    UE Attach And Check Throughput With Detach    global_cell_id=5    ul_tp=10M    ul_tp_threshold=1
    ...    dl_tp=10M    dl_tp_threshold=1    min_percent=0

CB009508_A_106_Add_new_RMOD_split_between_two_BBMODs_which_equipped_with_no_RMOD_and_no_cells
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/03/04 11:42
    ...    Delete RU 3 4 5 6
    [Tags]    c106
    AlarmWatchdog.add_allow_alarms   fault_id=4589
    CB009508 Precondition Common Delete    ${REMOVE_RU1_13_DELTA}    ${RU_INDEX_113}

    FOR    ${index}    IN    @{RU_INDEX_113}
        Perform RU Power On    ru_index=${index}
    END
    Repeat Keyword    30 s    Verify gNB Is OnAir
    COAM Commission with scf file    ${COMMON_SCF}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    25min    30s    Verify BTS 5G Cells Status Is Normal State
    Log to console    fullcomissionend
    AlarmWatchdog.remove_allow_alarms   fault_id=4589
    Sleep    60s
    Verify Case106 Cell History Status Normal
    Wait Until Keyword Succeeds    20min    15s    Verify BTS 5G Cells Status Is Normal State

    #modify PA FOR CALL
    Set PA for AZQS call

    # Step 3: ue attach ru4 cell ok
    UE Attach And Check Throughput With Detach    global_cell_id=29    ul_tp=10M    ul_tp_threshold=1
    ...    dl_tp=10M    dl_tp_threshold=1    min_percent=0

CB009508_A_107_Add_new_RMOD_split_between_two_BBMODs_which_equipped_with_RMOD_and_serving_cells_on_air
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/03/04 11:42
    ...    Delete RU 4
    [Tags]    c107
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1
    ...    parameter=actCellAutoRecalculation    value=Autonomous
    CB009508 Precondition Common Delete    ${REMOVE_RU1_DELTA}    ${RU_INDEX_1}
    AlarmWatchdog.add_allow_alarms   fault_id=4589
    AlarmWatchdog.add_allow_alarms   fault_id=4715
    # Step 1: ru 1 power on
    Perform RU Power On    ru_index=${1}
    Repeat Keyword    30 s    Verify gNB Is OnAir

    #Connect to gnb coam via ssl
    Log to console    step1
    # Step 2: add ru 1, cell on air
    coam.perform_delta_recommissioning    delta_file=${CREATE_RU1_DELTA}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Sleep    100s
    Log to console    checkcellstatus
    Verify Case107 Cell History Status Normal
    Wait Until Keyword Succeeds    20min    15s    Verify BTS 5G Cells Status Is Normal State
    AlarmWatchdog.remove_allow_alarms   fault_id=4589
    AlarmWatchdog.remove_allow_alarms   fault_id=4715

    #modify PA FOR CALL
    Set PA for AZQS call

    Log to console    call
    # Step 3: ue attach ru1 cell ok
    UE Attach And Check Throughput With Detach    global_cell_id=29    ul_tp=10M    ul_tp_threshold=1
    ...    dl_tp=10M    dl_tp_threshold=1    min_percent=0

CB009508_A_112_Delta_commission_for_BBMOD_RMOD_deleted_first_then_BBMOD_and_RMOD_disconnected_later
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/03/04 11:42
    [Tags]    c112
    coam.perform_delta_recommissioning    delta_file=${LOCK_RU113_DELTA}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    FOR    ${cell}    IN    @{CELL8_DISTNAMES}
        Wait Until Keyword Succeeds    20min    20s    Verify BTS Single Cell Status Is Locked State    dist_name=${cell}
    END
    Verify BTS Single RU Status Is Lock State    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
    Verify BTS Single RU Status Is Lock State    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-13

    coam.perform_delta_recommissioning    delta_file=${REMOVE_ABIO_ABIP_RU113_DELTA}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Repeat Keyword    30 s    Verify gNB Is OnAir

    FOR    ${index}    IN    @{RU_INDEX_113}
        Perform RU Power Off    ru_index=${index}
    END
    Repeat Keyword    30 s   Verify gNB Is OnAir

    Control BBMOD Power Switch    power_status=1    slot=2
    Control BBMOD Power Switch    power_status=1    slot=7
    Repeat Keyword    30 s    Verify gNB Is OnAir

    # restore
    AlarmWatchdog.add_allow_alarms   fault_id=4663
    Connect to gnb coam via ssl
    FOR    ${index}    IN    @{RU_INDEX_113}
        Perform RU Power On    ru_index=${index}
    END
    Control BBMOD Power Switch    power_status=0    slot=2
    Control BBMOD Power Switch    power_status=0    slot=7

    Wait Until Keyword Succeeds    15min    60s    Verify BTS Single BB Status Is Normal
    ...    serial_number=L1223310009    usage_state=Idle
    Wait Until Keyword Succeeds    15min    60s    Verify BTS Single BB Status Is Normal
    ...    serial_number=L1233804722    usage_state=Idle
    Verify gNB Is OnAir
    COAM Commission with scf file    ${COMMON_110_SCF}     is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    25min    30s    Verify BTS 5G Cells Status Is Normal State
    AlarmWatchdog.remove_allow_alarms   fault_id=4663

CB009508_A_110_RMOD_disconnected_first_delta_commission_for_ROMD_deleted_later
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/03/04 11:42
    ...    Delete ABIO+ABIP, RU 3 4 5 6
    [Tags]    c110
    AlarmWatchdog.add_allow_alarms   fault_id=4589
    COAM Commission with scf file    ${COMMON_110_SCF}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    25min    30s    Verify BTS 5G Cells Status Is Normal State
    CB009508 Precondition Delta Json

    # Step 1: lock ru13 cells, lock ru3
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-4
    ...    parameter=administrativeState    value=Locked
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-5
    ...    parameter=administrativeState    value=Locked
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-3
    ...    parameter=administrativeState    value=Locked
    Verify BTS Single Cell Status Is Locked State    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-4
    Verify BTS Single Cell Status Is Locked State    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-5
    Verify BTS Single RU Status Is Lock State    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-3
    AlarmWatchdog.add_allow_alarms   fault_id=10
    # Step2: disconnect ru3
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-2/SFP-1/LANE-1
    ...    parameter=administrativeState    value=Locked
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-2/SFP-4/LANE-1
    ...    parameter=administrativeState    value=Locked
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-2/SFP-7/LANE-1
    ...    parameter=administrativeState    value=Locked
    Wait Until Keyword Succeeds    20min    20s    Verify BTS Alarm Exist
    ...    fault_id=10    fault_name=No connection to unit

    # Step3: delete ru3
    coam.perform_delta_recommissioning    delta_file=${REMOVE_RU3_DELTA_110}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Wait Until Keyword Succeeds    20min    15s    Verify BTS 5G Cells Status Is Normal State
    Wait Until Keyword Succeeds    20min    20s    Verify BTS Alarm Not Exist
    ...    fault_id=10    fault_name=No connection to unit
    coam.reset_site    connection=GNB_OAM
    Wait Until Keyword Succeeds    15min    20s    Verify BTS 5G Cells Status Is Normal State

    # Step4: add ru1 without cell
    coam.perform_delta_recommissioning    delta_file=${CREATE_RU3_NO_CELL_DELTA_110}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Wait Until Keyword Succeeds    20min    20s    Verify BTS Alarm Exist
    ...    fault_id=10    fault_name=No connection to unit

    # Step5: connect ru3 and add ru3 cell
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-2/SFP-1/LANE-1
    ...    parameter=administrativeState    value=Unlocked
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-2/SFP-4/LANE-1
    ...    parameter=administrativeState    value=Unlocked
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-2/SFP-7/LANE-1
    ...    parameter=administrativeState    value=Unlocked
    coam.perform_delta_recommissioning    delta_file=${CREATE_RU3_CELL_DELTA_110}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Wait Until Keyword Succeeds    20min    15s    Verify BTS 5G Cells Status Is Normal State
    Wait Until Keyword Succeeds    20min    20s    Verify BTS Alarm Not Exist
    ...    fault_id=10    fault_name=No connection to unit
    AlarmWatchdog.remove_allow_alarms   fault_id=10
    AlarmWatchdog.remove_allow_alarms   fault_id=4589
    COAM Commission with scf file    ${COMMON_110_SCF}     is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    25min    30s    Verify BTS 5G Cells Status Is Normal State

CB008253_C_301_First_full_commision_then_add_ecpri_TDD_RUs_in_FR1_dual_core_ASIK_ABIL
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/04/28 16:38
    [Tags]    c301
    Log to console    step1
    CB009508 Precondition Common Delete    ${REMOVE_RU1_DELTA}    ${RU_INDEX_1}
    Log to console    step2
    AlarmWatchdog.add_allow_alarms   fault_id=10
    AlarmWatchdog.add_allow_alarms   fault_id=4715
    AlarmWatchdog.add_allow_alarms   fault_id=4589
    AlarmWatchdog.add_allow_alarms   fault_id=4681
    Run Keyword And Ignore Error    CI_interface.Common Suite Setup
    Log to console    step3
    coam.reset_site    connection=GNB_OAM
    Sleep    1800s
    Log to console    step4
    Wait Until Keyword Succeeds    50min    20s    Verify BTS Alarm Configuration Alarming Objects
    ...    fault_id=10    fault_name=No connection to unit
    ...    objects=${RU1_FAULT_10}
    Log to console    step5
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-51    parameter=administrativeState
    ...    value=Locked
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-51    parameter=administrativeState
    ...    value=Unlocked
    Perform RU Power On    ru_index=${1}

    Verify original Cell History Status Normal

    Wait Until Keyword Succeeds    20min    20s    Verify BTS Alarm Configuration Alarming Objects
    ...    fault_id=4715    fault_name=BTS cell re-calculation required
    ...    objects=${NR_FAULT_4715}

    coam.perform_delta_recommissioning    delta_file=${ADD_CELLSCALCULATIONREQ_DELTA_PATH}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM

    #check cell Status
    Verify CB008253 Case301 Cell History Status Normal

    AlarmWatchdog.remove_allow_alarms   fault_id=10
    AlarmWatchdog.remove_allow_alarms   fault_id=4715
    AlarmWatchdog.remove_allow_alarms   fault_id=4589
    AlarmWatchdog.remove_allow_alarms   fault_id=4681
    #modify PA for AZQS call
    Set PA for AZQS call

    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-51    parameter=administrativeState
    ...    value=Locked
    UE Attach And Check Throughput With Detach    global_cell_id=29    ul_tp=10M    ul_tp_threshold=1
    ...    dl_tp=10M    dl_tp_threshold=1    min_percent=0
    Sleep    300s
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-51    parameter=administrativeState
    ...    value=Unlocked
    Wait Until Keyword Succeeds    25min    30s    Verify BTS 5G Cells Status Is Normal State
    MMW5 Collect Snapshot