# @Time    : 2024/6/28 14:21
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @Group   : NSB MN RAN RD VRF HAZ3 5
# @File    : CB010969.robot
# @Software: PyCharm
# @Doc     : Some Description

*** Settings ***
Documentation
...    author: Chen Jian
...    contact: jian.1.chen@nokia-sbell.com
...    squad group: NSB MN RAN RD VRF HAZ3 5
...    Feature CB010969 CB008253 ASOG/ASOH parity

Suite Setup         SISO Coam Suite Setup
Suite Teardown      SISO Coam Suite Teardown
Test Setup          MMW5 Common Case Setup    allowed_faults_ids=10,1806,4525,4589,4592,4681,4741,4715,6450
Test Teardown       Run Keywords    Power On For Restore RU    AND    MMW5 Common Case Teardown
Force Tags          CRT_TRUNK    PY36

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/feature/CB010969_common_keywords.robot


*** Variables ***
${if_commissioning}                False
${102_FULL_SCF}                    ${CURDIR}/Resource/102_FULL_SCF.xml
${102_PRE_SCF}                    ${CURDIR}/Resource/102_PRE_SCF.xml
${103_FULL_SCF}                    ${CURDIR}/Resource/103_FULL_SCF.xml
${103_NO_RU13_SCF}                ${CURDIR}/Resource/103_NO_RU13_SCF.xml
${103_NO_RU123_SCF}               ${CURDIR}/Resource/103_NO_RU123_SCF.xml
${103_FULL_25R2_SCF}                    ${CURDIR}/Resource/103_FULL_25R2_SCF.xml
${103_NO_RU13_25R2_SCF}                ${CURDIR}/Resource/103_NO_RU13_25R2_SCF.xml
${103_NO_RU123_25R2_SCF}               ${CURDIR}/Resource/103_NO_RU123_25R2_SCF.xml
${104_FULL_SCF}                  ${CURDIR}/Resource/104_FULL_SCF.xml
${104_PRE_SCF}                  ${CURDIR}/Resource/104_PRE_SCF.xml

# Pre-prepared
${ADD_CELLSCALCULATIONREQ_DELTA}    ${CURDIR}/Resource/ADD_CELLSCALCULATIONREQ_DELTA.json
${LOCK_CELL3456_DELTA}                ${CURDIR}/Resource/LOCK_CELL3456_DELTA.json
${REMOVE_RU2_DELTA}                ${CURDIR}/Resource/REMOVE_RU2_DELTA.json
${MODIFY_RU2_NO_RU13_DELTA}        ${CURDIR}/Resource/MODIFY_RU2_NO_RU13_DELTA.json

# Auto-generate
${CREATE_RU2_DELTA}                ${CURDIR}/Resource/CREATE_RU2_DELTA.json
${CREATE_RU2_NO_RU13_DELTA}        ${CURDIR}/Resource/CREATE_RU2_NO_RU13_DELTA.json
${CREATE_RU13_DELTA}                ${CURDIR}/Resource/CREATE_RU13_DELTA.json
${NO_USE_DELTA}                ${CURDIR}/Resource/NO_USE_DELTA.json

@{RU1_FAULT_10}        [CB010969_config1] MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
@{RU2_FAULT_10}        [CB010969_config1] MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-2
@{RU12_FAULT_10}    [CB010969_config1] MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
...    [CB010969_config1] MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-2
@{RU13_FAULT_10}    [CB010969_config1] MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
...    [CB010969_config1] MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-3
@{RU123_FAULT_10}    [CB010969_config1] MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
...    [CB010969_config1] MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-2
...    [CB010969_config1] MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-3
@{CELL12_FAULT_4715}    [CB010969_config1][AEHC] MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
...    [CB010969_config1][AEHC] MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
@{CELL123456_FAULT_4715}    [CB010969_config1][AEHC] MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
...    [CB010969_config1][AEHC] MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
...    [CB010969_config1][AZQJ] MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3
...    [CB010969_config1][AZQJ] MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-4
...    [CB010969_config1][AZQJ] MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-5
...    [CB010969_config1][AZQJ] MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-6
@{CELL3456_DISTNAMES}    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3
...    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-4
...    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-5
...    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-6

${RU_INDEX_12}       ${0}    ${1}
@{RU_INDEX_2RU}      ${0}    ${1}    ${2}

*** Test Cases ***
CB010969_CC_102_Full_commission_first_and_RU_HW_installation_later_disconnect_RU_then_delete_RU
    [Documentation]      Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/06/28 14:24
    ...    Origin exist RU3
    [Tags]    c102
    COAM Commission with scf file    ${102_PRE_SCF}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    15min    20s    Verify BTS 5G Cells Status Is Normal State
    Perform RU Power Off    ru_index=0
    Perform RU Power Off    ru_index=1
    coam.reset_site    connection=GNB_OAM
    Wait Until Keyword Succeeds    15min    20s    Verify BTS 5G Cells Status Is Normal State

    COAM Commission with scf file    ${102_FULL_SCF}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    30min    20s    Verify BTS Alarm Configuration Alarming Objects
    ...    fault_id=10    fault_name=No connection to unit
    ...    objects=${RU12_FAULT_10}

    Perform RU Power On    ru_index=0
    Wait Until Keyword Succeeds    30min    20s    Verify BTS Alarm Configuration Alarming Objects
    ...    fault_id=4715    fault_name=BTS cell re-calculation required
    ...    objects=${CELL12_FAULT_4715}
    Wait Until Keyword Succeeds    30min    20s    Verify BTS Alarm Configuration Alarming Objects
    ...    fault_id=10    fault_name=No connection to unit
    ...    objects=${RU2_FAULT_10}

    Sleep    5min
    Perform RU Power On    ru_index=1
    Wait Until Keyword Succeeds    30min    20s    Verify BTS Alarm Configuration Alarming Objects
    ...    fault_id=4715    fault_name=BTS cell re-calculation required
    ...    objects=${CELL123456_FAULT_4715}
    Wait Until Keyword Succeeds    20min    20s    Verify BTS Alarm Not Exist
    ...    fault_id=10    fault_name=No connection to unit

    coam.perform_delta_recommissioning    delta_file=${ADD_CELLSCALCULATIONREQ_DELTA}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
    Wait Until Keyword Succeeds    25min    15s    CI_commssion.Verify all cells should be Online

    coam.perform_delta_recommissioning    delta_file=${LOCK_CELL3456_DELTA}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
    FOR    ${cell}    IN    @{CELL3456_DISTNAMES}
        Wait Until Keyword Succeeds    20min    20s    Verify BTS Single Cell Status Is Locked State    dist_name=${cell}
    END

    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-2
    ...    parameter=administrativeState    value=Locked
    Wait Until Keyword Succeeds    20min    20s
    ...    Verify BTS Single RU Status Is Lock State    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-2
    FOR    ${cell}    IN    @{CELL3456_DISTNAMES}
        Wait Until Keyword Succeeds    20min    20s    Verify BTS Single Cell Status Is Locked State    dist_name=${cell}
    END

    Perform RU Power Off    ru_index=${1}
    Wait Until Keyword Succeeds    5min    20s
    ...    Verify BTS Single RU Status Is Offline State    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-2
    ...    availability_status=not installed    procedural_status=not initialized

    coam.perform_delta_recommissioning    delta_file=${REMOVE_RU2_DELTA}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
    Wait Until Keyword Succeeds    25min    15s    CI_commssion.Verify all cells should be Online
    Wait Until Keyword Succeeds    20min    20s    Verify BTS Alarm Not Exist
    ...    fault_id=10    fault_name=No connection to unit

    CPE UE Attach And Verify Throughput    cell_id=7

    Perform RU Power On    ru_index=${1}
    Sleep    5min

    COAM Commission with scf file    ${102_FULL_SCF}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    15min    20s    Verify BTS 5G Cells Status Is Normal State

CB010969_CC_103_Delta_commission_first_and_RU_HW_installation_later_with_smodBoardConfigType_change
    [Documentation]      Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/06/28 16:28
    ...    Origin exist RU4
    [Tags]    103
    CB010969 Precondition Delta Json

    COAM Commission with scf file    ${103_NO_RU123_SCF}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    15min    20s    Verify BTS 5G Cells Status Is Normal State
    Perform RU Power Off    ru_index=${0}
    Perform RU Power Off    ru_index=${1}
    Perform RU Power Off    ru_index=${2}
    coam.reset_site    connection=GNB_OAM
    Wait Until Keyword Succeeds    15min    20s    Verify BTS 5G Cells Status Is Normal State

    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-1/BBCAP-1
    ...    parameter=smodBoardConfigType    value=NRFDD_NRTDD
    Sleep    5min
    Wait Until Keyword Succeeds    15min    20s    Verify BTS 5G Cells Status Is Normal State

    coam.perform_delta_recommissioning    delta_file=${CREATE_RU2_NO_RU13_DELTA}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
    Wait Until Keyword Succeeds    30min    20s    Verify BTS Alarm Configuration Alarming Objects
    ...    fault_id=10    fault_name=No connection to unit
    ...    objects=${RU2_FAULT_10}

    Perform RU Power On    ru_index=${1}
    Wait Until Keyword Succeeds    15min    20s    Verify BTS 5G Cells Status Is Normal State

    coam.perform_delta_recommissioning    delta_file=${CREATE_RU13_DELTA}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
    Wait Until Keyword Succeeds    30min    20s    Verify BTS Alarm Configuration Alarming Objects
    ...    fault_id=10    fault_name=No connection to unit
    ...    objects=${RU13_FAULT_10}

    Perform RU Power On    ru_index=${0}
    Sleep    5min
    Perform RU Power On    ru_index=${2}
    Wait Until Keyword Succeeds    15min    20s    Verify BTS 5G Cells Status Is Normal State

    CPE UE Attach And Verify Throughput    cell_id=7

    COAM Commission with scf file    ${103_FULL_SCF}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    15min    20s    Verify BTS 5G Cells Status Is Normal State

CB010969_CC_104_Full_commission_first_and_RU_HW_installation_later_with_actCellAutoRecalculation_change
    [Documentation]      Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/06/28 15:50
    ...    Origin exist RU4
    [Tags]    c104
    COAM Commission with scf file    ${104_PRE_SCF}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    15min    20s    Verify BTS 5G Cells Status Is Normal State

    Perform RU Power Off    ru_index=0
    Perform RU Power Off    ru_index=1
    Perform RU Power Off    ru_index=2
    COAM Commission with scf file    ${104_FULL_SCF}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    30min    20s    Verify BTS Alarm Configuration Alarming Objects
    ...    fault_id=10    fault_name=No connection to unit
    ...    objects=${RU123_FAULT_10}

    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1
    ...    parameter=actCellAutoRecalculation    value=OnOperatorDemand

    Perform RU Power On    ru_index=2
    Wait Until Keyword Succeeds    30min    20s    Verify BTS Alarm Configuration Alarming Objects
    ...    fault_id=10    fault_name=No connection to unit
    ...    objects=${RU12_FAULT_10}
    Wait Until Keyword Succeeds    30min    20s    Verify BTS Single Cell Status Is Normal State
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-7

    Perform RU Power On    ru_index=1
    Wait Until Keyword Succeeds    30min    20s    Verify BTS Alarm Configuration Alarming Objects
    ...    fault_id=10    fault_name=No connection to unit
    ...    objects=${RU1_FAULT_10}
    Wait Until Keyword Succeeds    30min    20s    Verify BTS Single Cell Status Is Normal State
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3

    Perform RU Power On    ru_index=0
    Wait Until Keyword Succeeds    20min    20s    Verify BTS Alarm Not Exist
    ...    fault_id=10    fault_name=No connection to unit
    Wait Until Keyword Succeeds    30min    20s    Verify BTS Alarm Configuration Alarming Objects
    ...    fault_id=4715    fault_name=BTS cell re-calculation required
    ...    objects=${CELL12_FAULT_4715}

    coam.perform_delta_recommissioning    delta_file=${ADD_CELLSCALCULATIONREQ_DELTA}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
    Wait Until Keyword Succeeds    25min    15s    CI_commssion.Verify all cells should be Online

    CPE UE Attach And Verify Throughput    cell_id=7

    COAM Commission with scf file    ${104_FULL_SCF}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    15min    20s    Verify BTS 5G Cells Status Is Normal State
