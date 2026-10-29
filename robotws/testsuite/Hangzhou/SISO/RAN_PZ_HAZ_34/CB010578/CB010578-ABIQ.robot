# @Time    : 2023/11/20 20:53
# @Author  : YINHUA ZHANG
# @Email   : yinhua.zhang@nokia-sbell.com
# @File    : CB010578.robot runing on TL2022 ABIQ
# @Software: PyCharm
# @Doc     : Some Description
*** Settings ***
Documentation
...    author: YINHUA ZHANG
...    contact: yinhua.zhang@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG05
...    CB010578.robot runing on TL2022 ABIQ

Suite Setup         SISO Coam Suite Setup
Suite Teardown      Run Keywords    Connect to gnb coam via ssl
...                 AND    COAM Commission with scf file    ${COMMON_10543_SCF_FEADEP}
...                 is_pdl_checking_needed=${False}    timeout=900
...                 AND    SISO Coam Suite Teardown
Test Setup          MMW5 Common Case Setup
Test Teardown       MMW5 Common Case Teardown
Force Tags          CRT_TRUNK    PY39

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/siso_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_commssion.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/siso/General_SiSo_RAT_Block_Unblock.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/siso/General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB009181/CB009181_keywords.robot

*** Variables ***
${if_commissioning}              False
${COMMON_10543_SCF_FEADEP}       ${CURDIR}/../CB010543/resource/COMMON_10543_FeaDep.xml
${SCF_L1_ON_ABIQ}                ${CURDIR}/ABIQ_resource/TL2022_CB010578_L1_SCF.xml
${SCF_N1_ON_ABIQ}                ${CURDIR}/ABIQ_resource/TL2022_CB010578_N1_SCF.xml
${SCF_L1_TDD}                    ${CURDIR}/ABIQ_resource/TL2022_CB010578_L1_TDD_SCF.xml
${SCF_N1_FDD}                    ${CURDIR}/ABIQ_resource/TL2022_CB010578_N1_FDD_SCF.xml
${SCF_N1_FDD_CONCURRENTMOD}      ${CURDIR}/ABIQ_resource/TL2022_CB010578_N1_FDD_SCF_CONCURRENTMOD.xml
${ru1_enable}                    ${CURDIR}/ABIQ_resource/lock_rus1.json
${ru2_enable}                    ${CURDIR}/ABIQ_resource/lock_rus2.json
${unlock_all_ru}                 ${CURDIR}/ABIQ_resource/unlock_all_ru.json
${TDD_ru_enable}                 ${CURDIR}/ABIQ_resource/lock_rus4.json
${NOT_BARRY_CELL_1}              ${CURDIR}/ABIQ_resource/NOT_BARRY_CELL_1.json
${NOT_BARRY_ALL_CELLS}           ${CURDIR}/ABIQ_resource/NOT_BARRY_ALL_CELLS.json
${204_DELETE_1RU}                ${CURDIR}/ABIQ_resource/204_DELETE_1RU.json
${204_ADD_1RU}                   ${CURDIR}/ABIQ_resource/204_ADD_1RU.json
${211_DELETE_TDD}                ${OUTPUT DIR}/211_DELETE_TDD.json
${211_ADD_TDD}                   ${OUTPUT DIR}/211_ADD_TDD.json
${BARRY_TDD_CELLS}               ${CURDIR}/ABIQ_resource/BARRY_TDD_CELLS.json
${204_WITH_6RUS}                 ${CURDIR}/ABIQ_resource/204_WITH_6RUS_SCF.xml
${204_WITH_5RUS}                 ${CURDIR}/ABIQ_resource/204_WITH_5RUS_SCF.xml
@{RU_INDEX_FDD}                  ${2}    ${6}    ${7}
@{RU_INDEX_FDD_ARPA}             ${2}
@{RU_INDEX_FDD_2}                ${6}    ${7}
@{RU_INDEX_TDD}                  ${3}    ${4}    ${5}
@{RU_INDEX_TDD_AEHC}             ${3}
@{RU_INDEX_TDD_2}                ${4}    ${5}

*** Test Cases ***
[1]CB010578-D_202_General_SiSo_RAT_Block_Unblock_with_L3Call
    [Tags]    202
    @{RATs}    Create List    lte    nr
    #precondition
    COAM Commission with scf file    ${SCF_L1_ON_ABIQ}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    20min    15s    Verify BTS All Cells Status Is Normal State
    Selenium login and disable screen lock

    AlarmWatchdog.add_allow_alarms    fault_id=4614
    #test LTE RAT
    #step1&2
    General_SiSo_RAT_Block_Unblock      target_rat=lte    other_rat=nr

    #step 3&4  make a call and data transfer
    #call on OBSAI RMOD
    coam.perform_delta_recommissioning    delta_file=${ru1_enable}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    LTE UE Attach And Verify DL Throughput    ue_type=${tl.ues[0].capabilities[-1]}    duration=3min
    ...    ui_version=${None}
    ...    mode_name_4G=LTE
    ...    mode_name_5G=NR/LTE/TDSCDMA/CDMA/EvDo/GSM/WCDMA

    #call on CPRI RMOD
    coam.perform_delta_recommissioning    delta_file=${ru2_enable}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    #unlock cpri ru and lock other RUs before make a call
    sleep    10s
    Wait Until Keyword Succeeds    10min    30s    Verify Cells Of Specified Rmod On Air    rmod=RMOD-2
    ...    RAT_list=${RATs}        administrative_state=unlocked

    #call LTE function
    LTE UE Attach And Verify DL Throughput    ue_type=${tl.ues[0].capabilities[-1]}    duration=3min
    ...    ui_version=${None}
    ...    mode_name_4G=LTE
    ...    mode_name_5G=NR/LTE/TDSCDMA/CDMA/EvDo/GSM/WCDMA

    #restore ru status
    coam.perform_delta_recommissioning    delta_file=${unlock_all_ru}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Wait Until Keyword Succeeds    20min    15s    Verify BTS All Cells Status Is Normal State

    #test NR RAT
    #step1&2
    General_SiSo_RAT_Block_Unblock      target_rat=nr    other_rat=lte

    #step 3&4  make a call and data transfer
    #lock FDD ru before make a call
    coam.perform_delta_recommissioning    delta_file=${TDD_ru_enable}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    UE Attach And Check Throughput With Detach    global_cell_id=51    ul_tp=10M    ul_tp_threshold=1
    ...    dl_tp=10M    dl_tp_threshold=1    min_percent=0
    AlarmWatchdog.remove_allow_alarms    fault_id=4614

[1]CB010578-D_203_Manual_SiSo_SM_LTE Cell_block_unblock
    [Tags]    203
    ${ue_type}=    set variable    ${tl.ues[0].capabilities[-1]}
    ${ui_version}=    set variable    one ui 3.1
    ${mode_name_4G}=    set variable    LTE/3G/2G (auto connect)
    ${mode_name_5G}=    set variable    5G/LTE/3G/2G (auto connect)
    #precondition
    COAM Commission with scf file    ${SCF_L1_ON_ABIQ}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    20min    15s    Verify BTS All Cells Status Is Normal State

    # check tput on a tested cell before all operations, take ${target_cell} as tested cell
    # make a call and data transfer
    coam.perform_delta_recommissioning    delta_file=${NOT_BARRY_CELL_1}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
    LTE UE Attach And Verify DL Throughput    ue_type=${ue_type}    duration=10min
    ...    ui_version=${ui_version}
    ...    mode_name_4G=${mode_name_4G}
    ...    mode_name_5G=${mode_name_5G}

    #need perform delta scf to enable all cells onair
    coam.perform_delta_recommissioning    delta_file=${NOT_BARRY_ALL_CELLS}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
    AlarmWatchdog.add_allow_alarms    fault_id=49
    Manual_SiSo_SM_LTE Cell_block_unblock    target_cell=11    target_ru=1
    AlarmWatchdog.remove_allow_alarms    fault_id=49

    # make a call and data transfer
    coam.perform_delta_recommissioning    delta_file=${NOT_BARRY_CELL_1}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
    LTE UE Attach And Verify DL Throughput    ue_type=${ue_type}    duration=10min
    ...    ui_version=${ui_version}
    ...    mode_name_4G=${mode_name_4G}
    ...    mode_name_5G=${mode_name_5G}

[1]CB010578-D_204_RAT_change_between_NRTDD3cells_single_duplex mode_to_LTEFDD16cells_NRTDD3cells_concurrent_mode
    [Tags]    204
    ${ue_type}=    set variable    ${tl.ues[0].capabilities[-1]}
    ${ui_version}=    set variable    one ui 3.1
    ${mode_name_4G}=    set variable    LTE/3G/2G (auto connect)
    ${mode_name_5G}=    set variable    5G/LTE/3G/2G (auto connect)
    # precondition: 3 FDD RU is power off and current scf is with only NRTDD_3 cells on air
    # ru index is the index of ru in init file, not in scf
    # call CB009181 method "MMW5 Rus Power On" and "MMW5 Rus Power Off"
    AlarmWatchdog.add_allow_alarms    fault_id=10
    AlarmWatchdog.add_allow_alarms    fault_id=4715
    AlarmWatchdog.add_allow_alarms    fault_id=1815
    AlarmWatchdog.add_allow_alarms    fault_id=4589
    MMW5 Rus Power Off    RU_INDEX=${RU_INDEX_FDD}
    COAM Commission with scf file    ${SCF_L1_TDD}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    20min    15s    Verify BTS 5G Cells Status Is Normal State


    # Step 1: activate full commission with 3 TDD RUs and 3 NRTDD cells + 3 FDD RUs and 16 LTEFDD cells.
    COAM Commission with scf file    ${SCF_L1_ON_ABIQ}    is_pdl_checking_needed=${False}    timeout=900
    Sleep    15m
    Verify BTS 5G Cells Status Is Normal State
    FOR    ${idx}    IN    @{RU_INDEX_FDD}
        Wait Until Keyword Succeeds    180s    30s    Verify Specified Object Alarm Exist
        ...    fault_id=10    fault_name=No connection to unit    object_name=RMOD-${idx}
    END

    # Step 2: connect to FDD RUs, then LTE cells can on air
    MMW5 Rus Power On    RU_INDEX=${RU_INDEX_FDD_ARPA}
    Sleep    10s
    MMW5 Rus Power On    RU_INDEX=${RU_INDEX_FDD_2}
    #Verify BTS All Cells Status Is Normal State  will verify LTE and NR cells
    Wait Until Keyword Succeeds    15min    60s    Verify BTS All Cells Status Is Normal State
    AlarmWatchdog.remove_allow_alarms    fault_id=10
    AlarmWatchdog.remove_allow_alarms    fault_id=4715
    AlarmWatchdog.remove_allow_alarms    fault_id=1815
    ${cur_scf}    COAM Download scf from cluster    ${TS_LOG_PATH_BASE}
    generate_delta_jsons_from_3_scf    ${cur_scf}    ${204_WITH_6RUS}    ${204_WITH_5RUS}
    ...    ${204_DELETE_1RU}    ${204_ADD_1RU}

    # Step 3: make a call on any of FDD cells
    coam.perform_delta_recommissioning    delta_file=${BARRY_TDD_CELLS}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Wait Until Keyword Succeeds    15min    20s    CI_commssion.Verify all cells should be Online
    LTE UE Attach And Verify DL Throughput    ue_type=${ue_type}    duration=10min
    ...    ui_version=${ui_version}
    ...    mode_name_4G=${mode_name_4G}
    ...    mode_name_5G=${mode_name_5G}
    AlarmWatchdog.remove_allow_alarms    fault_id=4589

    # Step 4: delta commission: remove CPRI RU and LTEFDD cells under this RU
    coam.perform_delta_recommissioning    delta_file=${204_DELETE_1RU}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Verify BTS All Cells Status Is Normal State

[1]CB010578-D_211_RAT_change_between_NRFDD12cells_single_duplex mode_to_NRFDD12cells_NRTDD3cells_concurrent_mode
    [Tags]    211
    COAM Commission with scf file    ${SCF_N1_ON_ABIQ}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    20min    15s    Verify BTS 5G Cells Status Is Normal State
    ${cur_scf}    COAM Download scf from cluster    ${TS_LOG_PATH_BASE}
    #generate_delta_jsons_from_3_scf    ${cur_scf}    ${SCF_N1_ON_ABIQ}    ${SCF_N1_FDD}
    #...    ${211_DELETE_TDD}    ${211_ADD_TDD}
    AlarmWatchdog.add_allow_alarms    fault_id=4525
    COAM Commission with scf file    ${SCF_N1_FDD}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    20min    15s    Verify BTS 5G Cells Status Is Normal State
    ${cur_scf2}    COAM Download scf from cluster    ${TS_LOG_PATH_BASE}
    generate_delta_jsons_from_3_scf    ${cur_scf}    ${cur_scf}    ${cur_scf2}
    ...    ${211_DELETE_TDD}    ${211_ADD_TDD}
    MMW5 Rus Power Off    RU_INDEX=${RU_INDEX_TDD}
    AlarmWatchdog.add_allow_alarms    fault_id=10
    AlarmWatchdog.add_allow_alarms    fault_id=4715

    # Step 1: activate delta commission to add NRTDD RUs+CELLs, change bbmodBoardConfigType to LTEFDD_NRTDD
    Log To Console    step 1
    coam.perform_delta_recommissioning    delta_file=${211_ADD_TDD}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    # verify FDD cells still can on air
    @{rat_list}    Create List    nr
    FOR    ${rmod_index}    IN    @{RU_INDEX_FDD}
        Wait Until Keyword Succeeds    15min    20s    Verify Cells Of Specified Rmod On Air    rmod=RMOD-${rmod_index}
        ...    RAT_list=${rat_list}
    END
    # wait for about 5min more after FDD cells on air, TDD RUs will report fault 10 alarm
    Sleep    5m
    FOR    ${idx}    IN    @{RU_INDEX_TDD}
        Wait Until Keyword Succeeds    180s    30s    Verify Specified Object Alarm Exist
        ...    fault_id=10    fault_name=No connection to unit    object_name=RMOD-${idx}
    END

    # step 2: connect 3 TDD RUs physically
    Log To Console    step 2
    AlarmWatchdog.add_allow_alarms    fault_id=4589
    MMW5 Rus Power On    RU_INDEX=${RU_INDEX_TDD_AEHC}
    Sleep    3m
    MMW5 Rus Power On    RU_INDEX=${RU_INDEX_TDD_2}
    Wait Until Keyword Succeeds    8min    60s    Verify BTS RUs Status Is Normal State
    # 5 minutes after TDD RU is enbled, TDD cells will be on air.  during the period, should verify FDD cell normal
    @{ratlist}    Create List    nr
    Repeat Keyword    6 min    Verify Already On Air Cell Still On Air    target_cell_rmod=${RU_INDEX_FDD}
    ...    rat_list=${ratlist}
    Wait Until Keyword Succeeds    10min    15s    Verify BTS 5G Cells Status Is Normal State
    AlarmWatchdog.remove_allow_alarms    fault_id=10
    AlarmWatchdog.remove_allow_alarms    fault_id=4715
    AlarmWatchdog.remove_allow_alarms    fault_id=4525
    AlarmWatchdog.remove_allow_alarms    fault_id=4589

    # step 3: make a call on any TDD cell
    Log To Console    step 3
    SISO Common L3 CALL

    # step 4: activate delta commission to delete NRTDD RUs+CELLs
    Log To Console    step 4
    generate_delta_jsons_from_3_scf    ${cur_scf}    ${SCF_N1_ON_ABIQ}    ${SCF_N1_FDD_CONCURRENTMOD}
    ...    ${211_DELETE_TDD}    ${211_ADD_TDD}
    coam.perform_delta_recommissioning    delta_file=${211_DELETE_TDD}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Wait Until Keyword Succeeds    10min    15s    Verify BTS 5G Cells Status Is Normal State

*** *** Keywords ***
Verify Already On Air Cell Still On Air
    [Arguments]    ${target_cell_rmod}    ${rat_list}
    FOR    ${rmod_index}    IN    @{target_cell_rmod}
        Verify Cells Of Specified Rmod On Air    rmod=RMOD-${rmod_index}
        ...    RAT_list=${rat_list}
    END
