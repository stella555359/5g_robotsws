# @Time    : 2025/1/14 11:09
# @Author  : Echo.Xu
# @Email   : echo.xu@nokia-sbell.com
# @Group   : NSB MN RAN RD VRF HAZ3 5
# @File    : CB009514.robot
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
...    RU14: AVQC (ABIP) 72e 8D4U
Suite Setup         Run Keywords    SISO Coam Suite Setup
Suite Teardown      SISO Coam Suite Teardown
Test Setup          Run Keywords    MMW5 Common Case Setup      allowed_faults_ids=4589
...    AND          COAM Commission with scf file    ${COMMON_SCF}    is_pdl_checking_needed=${False}    timeout=900
...    AND          Wait Until Keyword Succeeds    25min    30s    Verify BTS 5G Cells Status Is Normal State
...    AND          CB009514 Precondition Delta Json
Test Teardown       Run Keywords    Restore PA    AND    Power On For Restore RU
...    AND          MMW5 Common Case Teardown
Force Tags          CRT_TRUNK    PY36

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/feature/CB009514_common_keywords.robot

*** Variables ***
${if_commissioning}               False
${COMMON_SCF}                     ${CURDIR}/../../../../../commissionings/HGZ/7_5_UTE5G402T2027/72e_only_COMMON_SCF.xml
${NO_RU13_SCF}                    ${CURDIR}/../../../../../commissionings/HGZ/7_5_UTE5G402T2027/SCF_101_no_RU13.xml
${ADD_CELLSCALCULATIONREQ_DELTA_PATH}    ${CURDIR}/Resource/ADD_CELLSCALCULATIONREQ.json
${COMMON_SCF_103}                 ${CURDIR}/../../../../../commissionings/HGZ/7_5_UTE5G402T2027/72e_COMMON_SCF.xml
${NO_RU113_SCF}                   ${CURDIR}/../../../../../commissionings/HGZ/7_5_UTE5G402T2027/NO_RU113_SCF.xml

# Pre-prepared
${REMOVE_RU13_AND_CELL}           ${CURDIR}/Resource/REMOVE_RU13_AND_CELL.json
${REMOVE_RU113_DELTA_103}         ${CURDIR}/Resource/REMOVE_RU113_DELTA_103.json


# Auto-generated
${CREATE_RU13_AND_CELL}           ${CURDIR}/Resource/CREATE_RU13_AND_CELL.json
${CREATE_RU113_DELTA_103}         ${CURDIR}/Resource/CREATE_RU113_DELTA_103.json


@{RU_INDEX_13}                    ${13}
@{RU_INDEX_2RU}                   ${1}    ${13}
@{RU13_FAULT_10}                  [MRBTS-${MRBTS_ID}] MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-13
@{NR_FAULT_4715}                  [MRBTS-${MRBTS_ID}][AVQC] MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-13
@{RU113_FAULT_10}    [MRBTS-${MRBTS_ID}] MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
...    [MRBTS-${MRBTS_ID}] MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-13
@{RU_INDEX_1}                     ${1}


*** Test Cases ***
CB009514_A_101_Delta_commission_first_then_RMOD_HW_installation_later
    [Documentation]    Author: echo.xu@nokia-sbell.com
    ...    Init Define: 2025/01/22 11:42
    ...    Delete RU 13, actCellAutoRecalculation set to OnOperatorDemand
    [Tags]    c101
    #Step1: delete RU13,reset site
    Log To Console    delete RU13 config
    CB009514 Precondition Common Delete    ${REMOVE_RU13_AND_CELL}    ${RU_INDEX_13}

    #Step2:delta to add RU13 and related cell
    Log To Console  delta commission to add RU13 and related CELL
    AlarmWatchdog.add_allow_alarms   fault_id=10
    coam.perform_delta_recommissioning    delta_file=${CREATE_RU13_AND_CELL}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Wait Until Keyword Succeeds    20min    20s    Verify BTS Alarm Configuration Alarming Objects
    ...    fault_id=10    fault_name=No connection to unit
    ...    objects=@{RU13_FAULT_10}
    Log to console    checkcellstatus
    Verify Cell expect 72e History Status Normal

    #Step3: connect RU13, fault4715 appear, send CMD
    Log To Console    connect RU13
    FOR    ${index}    IN    @{RU_INDEX_13}
        Perform RU Power On    ru_index=${index}
    END
    Wait Until Keyword Succeeds    20min    15s    Verify BTS 5G Cells Status Is Normal State

    #Step4: ue attach ru13 NRCELL ok
    Set PA for RU-13 CALL
    Log To Console    MAKE CALL
    UE Attach And Check Throughput With Detach    global_cell_id=13    ul_tp=10M    ul_tp_threshold=1
    ...    dl_tp=10M    dl_tp_threshold=1    min_percent=0

CB009514_A_102_RMOD_HW_installation_first_then_Delta_commission_later
    [Documentation]    Author: echo.xu@nokia-sbell.com
    ...    Init Define: 2025/01/22 11:42
    ...    Delete RU 13, actCellAutoRecalculation set to Autonomous
    #Step1: delete RU13, reset site, modify actCellAutoRecalculation to antonomous
    CB009514 Precondition Common Delete    ${REMOVE_RU13_AND_CELL}    ${RU_INDEX_13}
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1
    ...    parameter=actCellAutoRecalculation    value=Autonomous

    #Step2: connect RU13
    FOR    ${index}    IN    @{RU_INDEX_13}
        Perform RU Power On    ru_index=${index}
    END
    Wait Until Keyword Succeeds    20min    15s    CI_commssion.Verify all cells should be Online

    #Step3:delta to add RU13 and related cell
    Log to console    delta commission to add RU13 and cell
    coam.perform_delta_recommissioning    delta_file=${CREATE_RU13_AND_CELL}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Sleep    200s
    Log to console    checkcellstatus
    Verify Cell expect 72e History Status Normal
    Wait Until Keyword Succeeds    20min    15s    Verify BTS 5G Cells Status Is Normal State
    AlarmWatchdog.remove_allow_alarms   fault_id=4589

    #Step4: ue attach ru13 NRCELL ok
    Set PA for RU-13 CALL
    Log to console    make call
    UE Attach And Check Throughput With Detach    global_cell_id=13    ul_tp=10M    ul_tp_threshold=1
    ...    dl_tp=10M    dl_tp_threshold=1    min_percent=0

CB009514_A_103_Full_commission_first_then_RMOD_HW_installation_later
    [Documentation]    Author: echo.xu@nokia-sbell.com
    ...    Init Define: 2025/01/22 11:42
    ...    actCellAutoRecalculation set to Autonomous, full commission then connect RU1 then RU13
    #Step1: CB009514 Precondition Delta Json create, delete RU1 RU13 config
    COAM Commission with scf file    ${COMMON_SCF_103}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    25min    30s    Verify BTS 5G Cells Status Is Normal State
#    generate_delta_jsons_from_3_scf    ${cur_scf}    ${${COMMON_SCF_103}}    ${NO_RU113_SCF}
#    ...    ${REMOVE_RU113_DELTA_103}    ${NO_USE_DELTA}
    ${cur_scf}    COAM Download scf from cluster    ${TS_LOG_PATH_BASE}
    generate_add_json_base_delete_json_and_cur_scf    ${cur_scf}    ${REMOVE_RU113_DELTA_103}    ${CREATE_RU113_DELTA_103}
    Log To Console  delete RU1 RU13 config
    CB009514 Precondition Common Delete    ${REMOVE_RU113_DELTA_103}    ${RU_INDEX_2RU}

    #Step2: full commission to add RU1, RU13 and related cell
    Log To Console  full commission to add RU13 and related CELL
    AlarmWatchdog.add_allow_alarms   fault_id=10
    AlarmWatchdog.add_allow_alarms   fault_id=4681
    COAM Commission with scf file    ${COMMON_SCF_103}    is_pdl_checking_needed=${False}    timeout=900
    Sleep    600s
    Wait Until Keyword Succeeds    20min    20s    Verify BTS Alarm Configuration Alarming Objects
    ...    fault_id=10    fault_name=No connection to unit
    ...    objects=@{RU113_FAULT_10}

    #step3: conncet RU1
    Log To Console  CONNECT RU1
    FOR    ${index}    IN    @{RU_INDEX_1}
        Perform RU Power On    ru_index=${index}
    END
    Sleep    200s
    Verify Cell History Status Normal For Case103_STEP3
    Wait Until Keyword Succeeds    20min    20s    Verify BTS Alarm Configuration Alarming Objects
    ...    fault_id=10    fault_name=No connection to unit
    ...    objects=@{RU13_FAULT_10}

    #step4: conncet RU13, check fault4715
    Log To Console  CONNECT RU13
    AlarmWatchdog.add_allow_alarms   fault_id=4715
    FOR    ${index}    IN    @{RU_INDEX_13}
        Perform RU Power On    ru_index=${index}
    END
    Log To Console    check fault4715
    Wait Until Keyword Succeeds    20min    15s    Verify BTS Alarm Configuration Alarming Objects
    ...    fault_id=4715    fault_name=BTS cell re-calculation ongoing
    ...    objects=${NR_FAULT_4715}
    Verify Cell History Status Normal For Case103_STEP4
    AlarmWatchdog.remove_allow_alarms   fault_id=10
    AlarmWatchdog.remove_allow_alarms   fault_id=4715
    AlarmWatchdog.remove_allow_alarms   fault_id=4589
    AlarmWatchdog.remove_allow_alarms   fault_id=4681

    #Step5: ue attach ru13 NRCELL ok
    Set PA for RU-13 CALL
    Log to console    make call
    UE Attach And Check Throughput With Detach    global_cell_id=13    ul_tp=10M    ul_tp_threshold=1
    ...    dl_tp=10M    dl_tp_threshold=1    min_percent=0
    Sleep    200s
    MMW5 Collect Snapshot
