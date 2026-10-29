*** Settings ***
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/counter_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_powersaving_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG08_keywords_SISO_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB005763/Resources/CB005763_keyword.robot
Variables    ../TestData/9925_10766_variables.py
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common.py
Library    ../lib/CB014167.py
Library    ../lib/parse_soap_update.py
Library    parse_soap_update.SOAPParser    WITH NAME    soap_sg8


Documentation    This is for SG8 common keywords
...              Author: wangqingqing
...              Squard: HZ SG8

*** Variables ***
${CB009925_json_path}    ${CURDIR}/json
${disable_9925_and_10766}    ${CB009925_json_path}/disable_9925_and_10766.json
@{cell_id_common}    ${1}
@{nr_cell_1}    ${1}
@{nr_cell_2}    ${2}
${ui_version_xiaomi}    Mi12UI13.0.12
${sleep_power_AENB}    160
${sleep_power_RU}    120
${sleep_power_SBTS23R2}    160
${power_all}    0
${MAX_LOOP}    3
*** Keywords ***
data_transfer_check_10471
    [Arguments]    ${tput_self_define}    ${ru_index}=${None}    ${cell_id}=${None}    ${target_avg_percent}=${None}    ${min_percent}=${None}
    ...    ${protocol}=udp    ${duration}=${600}    ${gnb_index}=0    ${du_index}=0    ${tput_from}=tool
    ...    ${loop_times}=${2}    ${alias}=ASIK MASTER    ${connection}=GNB_OAM    ${process_num_ul}=1    ${ui_version}=default
    ...    ${pci}=${0}    ${scf_name}=${None}    ${buffer_size}=1400B    ${expect_energySavingState}=notEnergySaving
    ${tput_self_define}    get_self_define_tput_by_release    tput_info=${tput_self_define}
    ${cell_list}    run keyword if    ${cell_id}!=${None}    set variable    ${cell_id}
    ...    ELSE    Get All Cell Id    ru_index=${ru_index}
    ${avg_expect_rate}    Run Keyword If    ${target_avg_percent}==${None}    get_avg_expect_rate    ELSE
    ...    set variable    ${target_avg_percent}
    ${min_expect_rate}    Run keyword If    ${min_percent}==${None}    get_min_expect_rate    ELSE
    ...    set variable    ${min_percent}
    FOR  ${i}  IN RANGE  ${loop_times}
        ${status}    run keyword and return status    make_call_and_check_tput_for_all_cells_in 10471    tput_info=${tput_self_define}
        ...    cell_list=${cell_list}    tput_from=${tput_from}    protocol=${protocol}
        ...    duration=${duration}    gnb_index=${gnb_index}    du_index=${du_index}    target_avg_percent=${avg_expect_rate}
        ...    min_percent=${min_expect_rate}    alias=${alias}    connection=${connection}    process_num_ul=${process_num_ul}
        ...    ui_version=${ui_version}    pci=${pci}    scf_name=${scf_name}    buffer_size=${buffer_size}
        ...    expect_energySavingState=${expect_energySavingState}
        exit for loop if    ${status}
    END
    run keyword if      not ${status}    FAIL

make_call_and_check_tput_for_all_cells_in 10471
    [Arguments]    ${tput_info}    ${cell_list}    ${tput_from}=tool    ${protocol}=udp    ${duration}=600
    ...    ${gnb_index}=0    ${du_index}=0    ${target_avg_percent}=0.98    ${min_percent}=0.85    ${check_source}=Aasyslog
    ...    ${alias}=ASIK MASTER    ${connection}=GNB_OAM    ${process_num_ul}=1    ${ui_version}=default
    ...    ${pci}=${0}    ${scf_name}=${None}    ${buffer_size}=1400B    ${expect_energySavingState}=notEnergySaving
    ${tput_info_total}    create dictionary
    FOR  ${cell_index}  IN  @{cell_list}
        ${ue_index}    set variable    ${tput_info[${cell_index}]['ue_index']}
        log to console    use ue${ue_index} to make call on cell${cell_index}
        ${tput_cell}    run keyword if    '${tput_from}'=='tool'    get_tput_info_by_tool
        ...    cell_id=${cell_index}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    scf_name=${scf_name}
        ...    duration=${duration}    connection=${connection}    ue_index=${ue_index}    ELSE    set variable    ${tput_info[${cell_index}]}
        log to console    tput info for cell ${cell_index} is: ${tput_cell}
        set to dictionary    ${tput_info_total}    ${cell_index}    ${tput_cell}
        make_call    tput_info=${tput_cell}    ue_index=${ue_index}    protocol=${protocol}
        ...    gnb_index=${gnb_index}    du_index=${du_index}    alias=${alias}    connection=${connection}
        ...    process_num_ul=${process_num_ul}    ui_version=${ui_version}    pci=${pci}    buffer_size=${buffer_size}
    END
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=${check_source}
    FOR  ${cell_index}  IN  @{cell_list}
        ${ue_index}    set variable    ${tput_info[${cell_index}]['ue_index']}
        check_tput_for_each_cell    tput_info=${tput_info_total}    cell_id=${cell_index}    ue_index=${ue_index}    tput_log=${tput_log}
        ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    connection=${connection}
        Check cell EnergySaving state via COAM    cellID=${cell_index}    expect_energySavingState=${expect_energySavingState}
    END
    [Teardown]    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}    protocol=${protocol}

check counter M55601C02001 and M55601C02002
    ${wait_time}    CB009925 get wait value minutes    interval=15min
    Sleep    ${wait_time}min
    Sleep    60s
	${M55601C02001_value}    Get PM Counter via Webem    counter_id=M55601C02001    interval=15min
    ...    full_path=[TL948_TMO_DSM_test] MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-2/NCAV/NR_CELL_RTX_PWR_SAVING_CHNG_TO
	Should be True    ${M55601C02001_value} == 1
	${M55601C02002_value}    Get PM Counter via Webem    counter_id=M55601C02002    interval=15min
    ...    full_path=[TL948_TMO_DSM_test] MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-2/NCAV/NR_CELL_RTX_PWR_SAVING_SAMPLES
	Should be True    ${M55601C02002_value} > 0
    ${wait_time}    CB009925 get wait value minutes    interval=15min
    Sleep    ${wait_time}min
    Sleep    60s
	${M55601C02001_value}    Get PM Counter via Webem    counter_id=M55601C02001    interval=15min
    ...    full_path=[TL948_TMO_DSM_test] MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-2/NCAV/NR_CELL_RTX_PWR_SAVING_CHNG_TO
	Should be True    ${M55601C02001_value} == 0
	${M55601C02002_value}    Get PM Counter via Webem    counter_id=M55601C02002    interval=15min
    ...    full_path=[TL948_TMO_DSM_test] MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-2/NCAV/NR_CELL_RTX_PWR_SAVING_SAMPLES
	Should be True    ${M55601C02002_value} == 900

check counter M55601C02001 and M55601C02002 when M55601C02001 is equal 1
    ${wait_time}    CB009925 get wait value minutes    interval=15min
    Sleep    ${wait_time}min
    Sleep    60s
	${M55601C02001_value}    Get PM Counter via Webem    counter_id=M55601C02001    interval=15min
    ...    full_path=[TL948_TMO_DSM_test] MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-2/NCAV/NR_CELL_RTX_PWR_SAVING_CHNG_TO
	Should be True    ${M55601C02001_value} == 0
	${M55601C02002_value}    Get PM Counter via Webem    counter_id=M55601C02002    interval=15min
    ...    full_path=[TL948_TMO_DSM_test] MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-2/NCAV/NR_CELL_RTX_PWR_SAVING_SAMPLES
	Should be True    ${M55601C02002_value} == 900

CB010471_A_B12345_16TRX_Path_Switch_Off_On_Base_On_Pgload
    ${SCF_10471}    Replace String    ${Golden_SCF_Path}    .xml    _10471.xml
    Commissioning SCF And Check On Air   scf_path=${SCF_10471}
    ${wait_time}    CB009925 get wait value minutes    interval=15min
    Sleep    ${wait_time}min
    Change lbpsPeriodList by Coam
    online change actNrLBmMimoRTXPowerSaving    actNrLBmMimoRTXPowerSaving=true
    Wait until keyword succeeds    7min    30s    Check cell EnergySaving state via COAM    cellID=2    expect_energySavingState=reducedEnergySaving
    selenium login and disable screen lock
	${M55601C02001_value}    Get PM Counter via Webem    counter_id=M55601C02001    interval=15min
    ...    full_path=[TL948_TMO_DSM_test] MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-2/NCAV/NR_CELL_RTX_PWR_SAVING_CHNG_TO
	${M55601C02002_value}    Get PM Counter via Webem    counter_id=M55601C02002    interval=15min
    ...    full_path=[TL948_TMO_DSM_test] MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-2/NCAV/NR_CELL_RTX_PWR_SAVING_SAMPLES
    Run Keyword If    ${M55601C02001_value} != 1    check counter M55601C02001 and M55601C02002
    ...    ELSE    check counter M55601C02001 and M55601C02002 when M55601C02001 is equal 1
    data_transfer_check_10471    tput_self_define=${tput_define_992_10766_common}    cell_id=${nr_cell_2}    loop_times=${1}    duration=${120}
    ...    target_avg_percent=${0.5}    min_percent=${0.2}     process_num_ul=6    tput_from=self_define
    ...    expect_energySavingState=reducedEnergySaving
    Check cell EnergySaving state via COAM    cellID=2    expect_energySavingState=reducedEnergySaving
    data_transfer_check_10471    tput_self_define=${tput_define_992_10766_common}    cell_id=${nr_cell_2}    loop_times=${1}    duration=${300}
    ...    target_avg_percent=${0.2}    min_percent=${0.1}     process_num_ul=6
    Wait until keyword succeeds    7min    30s    Check cell EnergySaving state via COAM    cellID=2
    [Teardown]    selenium logout and close browser

CB010766-SR-A-5 Entering_Exiting_Deep_Sleep_Mode_IWK_With_CB009925
    log to console    ++++ enable 10766 431 and cell enter energysaving, RU enter deepsleep ++++
    ${nrcell_energysaving}    get_some_info_from_file_path    xml_file_path=${Golden_SCF_Path}    prefix=<p name="nrCellId">
    set test variable  ${nrcell_energysaving}
    ${ltecell_energysaving}    get_some_info_from_file_path    xml_file_path=${Golden_SCF_Path}    prefix=<p name="lnCelId">
    set test variable  ${ltecell_energysaving}
    SG8 modify the parameter    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    parameter_name=actRadioDeepSleepTimeSchedule    value=true
    ${lbpsDayOfWeek}    ${lbpsStartTimeHour}    ${lbpsStartTimeMinute}    get_lbps_current_week_and_time
    ${Week}    ${startTime}    get_deepsleep_start_time    hour=${lbpsStartTimeHour}    minute=${lbpsStartTimeMinute}
    SG8 Change deepSleepTimeSchedule by Coam    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-1    dayOfWeek=${lbpsDayOfWeek}
    ...    startTime=${startTime}    windowDuration=1440
    SG8 Change deepSleepTimeSchedule by Coam    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-2    dayOfWeek=${lbpsDayOfWeek}
    ...    startTime=${startTime}    windowDuration=1440
    SG8 common Change lbpsPeriodList by Coam Include lbpsSuspended    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-1
    ...    lbpsDayOfWeek=${lbpsDayOfWeek}    lbpsStartTimeHour=${lbpsStartTimeHour}    lbpsStartTimeMinute=${lbpsStartTimeMinute}    lbpsDuration=40
    SG8 modify the parameter    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}     parameter_name=actNrLBPowerSaving    value=true
    sleep    60s
    check nr and lte cell enter energysaving    nrcell_list=${nrcell_energysaving}    ltecell_list=${ltecell_energysaving}
    Wait Until Keyword Succeeds    8min    30s    SG8 Check RU Power State by ru index
    Wait Until Keyword Succeeds    8min    30s    SG8 Check RU Power State by ru index    ru_index=2
    log to console    ++++ disable 10766 9925 ++++
    coam.perform_delta_recommissioning    delta_file=${disable_9925_and_10766}    connection=GNB_OAM
    nr or lte cells should be keep in energysaving    nrcell_list=${nrcell_energysaving}    ltecell_list=${ltecell_energysaving}
    log to console    ++++ 431,7416 end time arrived ++++
    Wait until keyword succeeds    35min    30s    verify all cells should be onair

CB009925 get wait value minutes
    [Arguments]    ${interval}
    Connect to Common Unit Master
    ${interval_seconds}    Get Interval Seconds    ${interval}
    ${interval_minutes}    evaluate    ${interval_seconds}/60
    ${origin_time}    Get time from GNB
    ${origin_time}    convert_date    ${origin_time}   datetime
    ${minutes}    set variable    ${origin_time.minute}
    ${time}    evaluate    ${interval_minutes}-${minutes}%${interval_minutes}
    [Return]    ${time}

CB009925 check power after RU enter deep sleep by RU type
    [Arguments]    ${interval}
    ${RU_Type}   Get RU type
    ${wait_time}    CB009925 get wait value minutes    interval=${interval}
    sleep    ${wait_time}min
    sleep    ${interval}
    selenium login and disable screen lock
    ${counter_3C4}    Get PM Counter via Webem    counter_id=M40003C4    interval=${interval}
    ${counter_3C4}    Evaluate    ${counter_3C4}/1000
    ${release}    Get program version based on gNB active version
    ${AENB_diff}    Get the diff    ${counter_3C4}    ${sleep_power_AENB}
    ${AEQY_diff}    Run Keyword If   "${release}"=="SBTS23R2"
    ...    Get the diff    ${counter_3C4}    ${sleep_power_SBTS23R2}
    ...    ELSE    Get the diff    ${counter_3C4}    ${sleep_power_RU}
    ${tmp_AENB}=   Evaluate    ${sleep_power_AENB}*0.1
    ${tmp_AEQY}=   Evaluate    ${sleep_power_RU}*0.1
    Run Keyword If    '${RU_Type}'=='AENB'    Should be True    ${AENB_diff} < ${tmp_AENB}
    ...    ELSE    Should be True    ${AEQY_diff} < ${tmp_AEQY}
    [Teardown]    selenium logout and close browser

CB009925 recovery ENV due IWK
    [Arguments]   ${lbpsDayOfWeek}=Fri    ${lbpsDuration}=1    ${lbpsStartTimeHour}=0    ${lbpsStartTimeMinute}=0
    SG8 common Change lbpsPeriodList by Coam Include lbpsSuspended    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-1
    ...    lbpsDayOfWeek=${lbpsDayOfWeek}    lbpsStartTimeHour=${lbpsStartTimeHour}    lbpsStartTimeMinute=${lbpsStartTimeMinute}
    ...    lbpsDuration=${lbpsDuration}
    SG8 common Change lbpsPeriodList by Coam Include lbpsSuspended    dist_name=MRBTS-${mrbtsID}/LNBTS-2160/PSGRP-1    lbpsDayOfWeek=${lbpsDayOfWeek}
    ...    lbpsStartTimeHour=${lbpsStartTimeHour}    lbpsStartTimeMinute=${lbpsStartTimeMinute}    lbpsDuration=${lbpsDuration}
    SG8 modify the parameter    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}     parameter_name=actNrLBPowerSaving    value=true
    SG8 modify the parameter    dist_name=MRBTS-${mrbtsID}/LNBTS-2160     parameter_name=actLBPowerSaving    value=true

CB0010766 recovery ENV
    [Arguments]   ${lbpsDayOfWeek}=Fri    ${lbpsStartTimeHour}=0    ${lbpsStartTimeMinute}=0
    CB009925 recovery ENV due IWK    lbpsDayOfWeek=${lbpsDayOfWeek}    lbpsStartTimeHour=${lbpsStartTimeHour}
    ...    lbpsStartTimeMinute=${lbpsStartTimeMinute}
    SG8 modify the parameter    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    parameter_name=actRadioDeepSleepTimeSchedule    value=false

CB009925-SR-A RU entering deep sleep mode during low traffic periods with 5GC000431 enabled
    ${SCF_LTE}    Replace String    ${Golden_SCF_Path}    .xml    _9925_include_lte.xml
    Commissioning SCF And Check On Air   scf_path=${SCF_LTE}
    ${lbpsDayOfWeek}    ${lbpsStartTimeHour}    ${lbpsStartTimeMinute}    get_lbps_current_week_and_time
    SG8 common Change lbpsPeriodList by Coam Include lbpsSuspended    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-1
    ...    lbpsDayOfWeek=${lbpsDayOfWeek}    lbpsStartTimeHour=${lbpsStartTimeHour}    lbpsStartTimeMinute=${lbpsStartTimeMinute}
    SG8 common Change lbpsPeriodList by Coam Include lbpsSuspended    dist_name=MRBTS-${mrbtsID}/LNBTS-2160/PSGRP-1    lbpsDayOfWeek=${lbpsDayOfWeek}
    ...    lbpsStartTimeHour=${lbpsStartTimeHour}    lbpsStartTimeMinute=${lbpsStartTimeMinute}
    SG8 modify the parameter    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}     parameter_name=actNrLBPowerSaving    value=true
    sleep    60s
    Wait Until Keyword Succeeds    12min    30s    Check cell EnergySaving state via COAM    expect_energySavingState=energySaving
    ...    class_name=NRCELL_R
    Wait Until Keyword Succeeds    10min    30s    Check cell EnergySaving state via COAM    expect_energySavingState=energySaving
    ...    class_name=LNCEL_R
    Wait Until Keyword Succeeds    8min    30s    SG8 Check RU Power State by ru index
    CB009925 check power after RU enter deep sleep by RU type    interval=15min
    SG8 modify the parameter    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}     parameter_name=actNrLBPowerSaving    value=false
    sleep    30s
    Wait until keyword succeeds    12min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    [Teardown]    run keyword and ignore error    CB009925 recovery ENV due IWK    lbpsDayOfWeek=${lbpsDayOfWeek}
    ...    lbpsStartTimeHour=${lbpsStartTimeHour}    lbpsStartTimeMinute=${lbpsStartTimeMinute}

Get average power value when all cells onair
    sleep    5min
    selenium login and disable screen lock
    FOR    ${TEST_LOOP}    IN RANGE    0    ${MAX_LOOP}
        sleep    1min
        ${power}    ${wait_time}    Get real time power measurements via Webem    object_names=RMOD    interval=1min
        ${power_all}=    Evaluate    ${power}+${power_all}
    END
    ${power_average}=    Evaluate    ${power_all}/${MAX_LOOP}
    selenium logout and close browser
    [Return]    ${power_average}

check all cells always keep in energysaving
    FOR    ${TEST_LOOP}    IN RANGE    0    50
        Check cell EnergySaving state via COAM    expect_energySavingState=energySaving    class_name=NRCELL_R
        Check cell EnergySaving state via COAM    expect_energySavingState=energySaving    class_name=LNCEL_R
        ...    cellID=401    celltype=lte
        sleep    5s
    END
    Wait Until Keyword Succeeds    4min    5s    SG8 Check RU Power State by ru index    expect_state=AWAKE
    FOR    ${TEST_LOOP}    IN RANGE    0    25
        Check cell EnergySaving state via COAM    expect_energySavingState=energySaving    class_name=NRCELL_R
        Check cell EnergySaving state via COAM    expect_energySavingState=energySaving    class_name=LNCEL_R
        ...    cellID=401    celltype=lte
        sleep    5s
    END

CB010766-SR-A-8 Activate RU deep sleep mode when feature flag enable TL948
    FOR    ${TEST_LOOP}    IN RANGE    0    1
        log to console    ++++ start test loop ${TEST_LOOP} ++++
        Connect to gnb coam via ssl
        Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
        Wait until keyword succeeds    5min    30s    verify all cells should be onair
        ${power_average}    Get average power value when all cells onair
        data_transfer_common    tput_self_define=${tput_define_992_10766_common}    cell_id=${nr_cell_1}    loop_times=${1}
        ...    duration=${300}    target_avg_percent=0.2    min_percent=0.1    ui_version=${ui_version_xiaomi}
         ${average_old}    get_average_list    output_info_list=${output}
        ${dl_old}    set variable    ${average_old}[1]
        ${ul_old}    set variable    ${average_old}[0]
        log to console    ++++ enable 10766 431 and not reach deep sleep time window  ++++
        SG8 modify the parameter    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1
        ...    parameter_name=actRadioDeepSleepTimeSchedule    value=true
        ${lbpsDayOfWeek}    ${lbpsStartTimeHour}    ${lbpsStartTimeMinute}    get_lbps_current_week_and_time
        ${Week}    ${startTime}    get_deepsleep_start_time    hour=${lbpsStartTimeHour}    minute=${lbpsStartTimeMinute}    addonehour=True
        SG8 Change deepSleepTimeSchedule by Coam    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-1    dayOfWeek=${Week}
        ...    startTime=${startTime}
        SG8 common Change lbpsPeriodList by Coam Include lbpsSuspended    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-1
        ...    lbpsDayOfWeek=${lbpsDayOfWeek}    lbpsStartTimeHour=${lbpsStartTimeHour}    lbpsStartTimeMinute=${lbpsStartTimeMinute}
        SG8 common Change lbpsPeriodList by Coam Include lbpsSuspended    dist_name=MRBTS-${mrbtsID}/LNBTS-2160/PSGRP-1
        ...    lbpsDayOfWeek=${lbpsDayOfWeek}    lbpsStartTimeHour=${lbpsStartTimeHour}    lbpsStartTimeMinute=${lbpsStartTimeMinute}
        SG8 modify the parameter    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}     parameter_name=actNrLBPowerSaving    value=true
        SG8 modify the parameter    dist_name=MRBTS-${mrbtsID}/LNBTS-2160     parameter_name=actLBPowerSaving    value=true
        sleep    60s
        Wait Until Keyword Succeeds    12min    30s    Check cell EnergySaving state via COAM    expect_energySavingState=energySaving
        ...    class_name=NRCELL_R
        Wait Until Keyword Succeeds    10min    30s    Check cell EnergySaving state via COAM    expect_energySavingState=energySaving
        ...    class_name=LNCEL_R    cellID=401    celltype=lte
        sleep    360s
        SG8 Check RU Power State by ru index    expect_state=AWAKE
        log to console    ++++ reach deep sleep time window and check RU enter deep sleep ++++
        ${lbpsDayOfWeek}    ${lbpsStartTimeHour}    ${lbpsStartTimeMinute}    get_lbps_current_week_and_time
        ${Week}    ${startTime}    get_deepsleep_start_time    hour=${lbpsStartTimeHour}    minute=${lbpsStartTimeMinute}
        SG8 Change deepSleepTimeSchedule by Coam    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-1
        ...    dayOfWeek=${lbpsDayOfWeek}    startTime=${startTime}    windowDuration=1440
        Wait Until Keyword Succeeds    6min    30s    SG8 Check RU Power State by ru index
        CB009925 check power after RU enter deep sleep by RU type    interval=15min
        log to console    ++++ Exit Time Window and RU awake ++++
        SG8 Change deepSleepTimeSchedule by Coam    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-1
        ...    dayOfWeek=${lbpsDayOfWeek}    startTime=${startTime}    windowDuration=35
        SG8 modify the parameter    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-1
        ...    parameter_name=advanceTimeForRURestore    value=20
        check all cells always keep in energysaving
        ${power_average_new}    Get average power value when all cells onair
        Should be True    ${power_average_new} > ${sleep_power_AENB}
        log to console    ++++ disable actRadioDeepSleepTimeSchedule and RU enter deep sleep ++++
        SG8 modify the parameter    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1
        ...    parameter_name=actRadioDeepSleepTimeSchedule    value=false
        Wait Until Keyword Succeeds    8min    30s    SG8 Check RU Power State by ru index
        ${power_average_tmp}    Get average power value when all cells onair
        ${power_average_diff_tmp}    Get the diff    ${power_average_tmp}    ${sleep_power_AENB}
        ${tmp_power_average}=   Evaluate    ${sleep_power_AENB}*0.1
        Should be True    ${power_average_diff_tmp} < ${tmp_power_average}
        log to console    ++++ disable 431 and RU awake ++++
        SG8 modify the parameter    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}     parameter_name=actNrLBPowerSaving    value=false
        SG8 modify the parameter    dist_name=MRBTS-${mrbtsID}/LNBTS-2160     parameter_name=actLBPowerSaving    value=false
        Wait until keyword succeeds    12min    30s    Verify all lte cells should be onair    connection=GNB_OAM
        Wait until keyword succeeds    10min    30s    verify all cells should be onair
        Wait Until Keyword Succeeds    10min    30s    SG8 Check RU Power State by ru index    expect_state=AWAKE
        ${power_average_new}    Get average power value when all cells onair
        ${power_average_diff}    Get the diff    ${power_average_new}    ${power_average}
        ${tmp_power_average}=   Evaluate    ${power_average}*0.1
        Should be True    ${power_average_diff} < ${tmp_power_average}
        data_transfer_common    tput_self_define=${tput_define_992_10766_common}    cell_id=${nr_cell_1}    loop_times=${1}
        ...    duration=${300}    target_avg_percent=0.2    min_percent=0.1    ui_version=${ui_version_xiaomi}
        ${average_new}    get_average_list    output_info_list=${output}
        ${dl_new}    set variable    ${average_new}[1]
        ${ul_new}    set variable    ${average_new}[0]
        ${ul_diff}    Get the diff    ${ul_new}    ${ul_old}
        ${dl_diff}    Get the diff    ${dl_new}    ${dl_old}
        ${tmp_ul}=   Evaluate    ${ul_old}*0.1
        ${tmp_dl}=   Evaluate    ${dl_old}*0.1
        Should be True    ${ul_diff} < ${tmp_ul}
        Should be True    ${dl_diff} < ${tmp_dl}
        sleep    30s
        csn.reset_cache
    END
    [Teardown]    run keyword and ignore error    CB0010766 recovery ENV    lbpsDayOfWeek=${lbpsDayOfWeek}
    ...    lbpsStartTimeHour=${lbpsStartTimeHour}    lbpsStartTimeMinute=${lbpsStartTimeMinute}

ISTI_next_to_each_timestamp
    [Arguments]    ${ru_index}=2
    Special_RF_module_reset_from_GUI    ru_index=${ru_index}
    ${BBOX5_file_path}    Get BBOX5 file from RUlog    ru_index=${ru_index}
    ${Time_ISTI_check_result}    get_ISTI_and_timestamp_count_from_file    ${BBOX5_file_path}
    Should Be Equal    ${Time_ISTI_check_result}    ${True}

Information_about_last_RU_resets
    [Arguments]    ${ru_index}=2
    ${reset_two_time_date}    Create List
    ${reset_two_timestamp}    Create List
    FOR    ${i}    IN RANGE  1    3
        Log To Console    ${i}th time RMOD control reset
        ${release}    Get program version based on gNB active version
        ${reset_check_start_time}=    Run Keyword If    "${release}"=="master"
        ...    DateTime.Get Current Date    increment=08:00:00    result_format=timestamp
        ...    ELSE    DateTime.Get Current Date    result_format=timestamp
        Special_RF_module_reset_from_GUI    ru_index=${ru_index}
        ${reset_check_stop_time}=    Run Keyword If    "${release}"=="master"
        ...    DateTime.Get Current Date    increment=08:00:00    result_format=timestamp
        ...    ELSE    DateTime.Get Current Date    result_format=timestamp
        Append To List    ${reset_two_time_date}    ${reset_check_start_time}
        Append To List    ${reset_two_time_date}    ${reset_check_stop_time}
        ${reset_check_start_timestamp}    DateTime.Convert Date    ${reset_check_start_time}    result_format=epoch
        ${reset_check_stop_timestamp}    DateTime.Convert Date    ${reset_check_stop_time}    result_format=epoch
        Append To List    ${reset_two_timestamp}    ${reset_check_start_timestamp}
        Append To List    ${reset_two_timestamp}    ${reset_check_stop_timestamp}
    END
    ${BBOX5_file_path}    Get BBOX5 file from RUlog    ru_index=${ru_index}
    ${reset_reason_item_number}    ${reset_ISTI_item_number}    ${post_dict_content}    get_reset_result_content_from_file    ${BBOX5_file_path}
    Should Be Equal    ${reset_reason_item_number}    ${50}
    Should Be Equal    ${reset_ISTI_item_number}    ${50}
    ${reset_reason}    Set Variable    9 - soft_reset
    ${reset_cause}    Set Variable    4 - BTS
    Should Be Equal    ${post_dict_content['Reset[1] Reset Reason']}    ${reset_reason}
    Should Be Equal    ${post_dict_content['Reset[1] Reset Cause']}    ${reset_cause}
    ${time_zone_align}=    Add Time To Date    ${post_dict_content['Reset[1] Write']}      08:00:00    result_format=%Y-%m-%d %H:%M:%S
    ${reset_timestamp}    DateTime.Convert Date    ${time_zone_align}   result_format=epoch
    Should Be True     ${reset_timestamp} > ${reset_two_timestamp[0]}
    ...  msg=RMOD 1th reset start time ${reset_two_time_date[0]} after reset write time ${time_zone_align}
    Should Be True     ${reset_timestamp} < ${reset_two_timestamp[1]}
    ...  msg=reset write time ${time_zone_align} after RMOD 1th reset stop time ${reset_two_time_date[1]}

SFP_info_per_SFP_slot_update_with_RU_startup
    [Arguments]    ${ru_index}=1
    ${BBOX5_file_path}    Get BBOX5 file from RUlog    ru_index=${ru_index}
    ${all_sfps_info_list_coam}    ${sfp_name_list}    get rmod all sfp info list    ru_index=${ru_index}
    ${all_sfps_info_list_sort_BBOX5}    ${sfp_check_result}    get_all_sfp_info_from_BBOX5    ${BBOX5_file_path}    ${sfp_name_list}
    Should Be Equal    ${sfp_check_result}    ${True}
    ${all_sfps_info_list_length_coam}    Get Length    ${all_sfps_info_list_coam}
    ${all_sfps_info_list_length_BBOX5}    Get Length    ${all_sfps_info_list_sort_BBOX5}
    Should Be Equal    ${all_sfps_info_list_length_coam}    ${all_sfps_info_list_length_BBOX5}
    FOR    ${i}    IN RANGE    ${all_sfps_info_list_length_coam}
        Should Be Equal    ${all_sfps_info_list_coam[${i}]['SFP_name']}    ${all_sfps_info_list_sort_BBOX5[${i}]['Item id']}
        Should Be Equal    ${all_sfps_info_list_coam[${i}]['serialNumber']}    ${all_sfps_info_list_sort_BBOX5[${i}]['SFP_info[0] SN']}
        Should Be Equal    ${all_sfps_info_list_coam[${i}]['speed']}    ${all_sfps_info_list_sort_BBOX5[${i}]['SFP_info[0] Speed']}
        Should Be Equal    ${all_sfps_info_list_coam[${i}]['vendor']}    ${all_sfps_info_list_sort_BBOX5[${i}]['SFP_info[0] Vendor']}
        Should Be Equal    ${all_sfps_info_list_coam[${i}]['vendorPartNumber']}    ${all_sfps_info_list_sort_BBOX5[${i}]['SFP_info[0] Part no']}
    END

RU_blackbox_versioning
    [Arguments]    ${check_field}='BlackBox ver:'    ${contain_field}=5.    ${ru_index}=1
    ${BBOX5_file_path}    Get BBOX5 file from RUlog    ru_index=${ru_index}
    ${Black_BOX_vsersion}    Run    command=grep ${check_field} ${BBOX5_file_path}
    Should Contain    ${Black_BOX_vsersion}    ${contain_field}

RU_configuration_data
    [Arguments]    ${ru_index}=1
    Special_RF_module_reset_from_GUI    ru_index=${ru_index}
    ${all_soap_path}    Get startup soap log from RUlog    ru_index=${ru_index}
    ${all_txcarrier_info_list_soap}    soap_sg8.get_carrier_info_update
    ...    log_path=${all_soap_path}
    ...    class_value=TxArrayCarrier
    ${all_rxcarrier_info_list_soap}    soap_sg8.get_carrier_info_update
    ...    log_path=${all_soap_path}
    ...    class_value=RxArrayCarrier
    Sleep    1min
    Special_RF_module_reset_from_GUI    ru_index=${ru_index}
    ${BBOX5_file_path}    Get BBOX5 file from RUlog    ru_index=${ru_index}
    ${tx_carrier_array_list_BBOX5}    ${tx_carrier_dict_content_BBOX5}    ${rx_carrier_array_list_BBOX5}
    ...    ${rx_carrier_dict_content_BBOX5}    get_all_carriers_info_from_BBOX5    ${BBOX5_file_path}
    ${all_txcarrier_info_list_soap_align_BBOX5}    ${all_rxcarrier_info_list_soap_align_BBOX5}    soap_carriers_index_align_with_BBOX5
    ...    ${all_txcarrier_info_list_soap}    ${tx_carrier_array_list_BBOX5}    ${all_rxcarrier_info_list_soap}    ${rx_carrier_array_list_BBOX5}
    ${all_txcarrier_info_list_num}    Get Length    ${all_txcarrier_info_list_soap_align_BBOX5}
    ${all_rxcarrier_info_list_num}    Get Length    ${all_rxcarrier_info_list_soap_align_BBOX5}
    FOR    ${i}    IN RANGE    ${all_txcarrier_info_list_num}
        Should Be Equal    ${all_txcarrier_info_list_soap_align_BBOX5[${i}]['distName']}    ${tx_carrier_dict_content_BBOX5['Carrier[${i}] name']}
        Should Be Equal    ${all_txcarrier_info_list_soap_align_BBOX5[${i}]['array']}    ${tx_carrier_dict_content_BBOX5['Carrier[${i}] antenna']}
        Should Be Equal    ${all_txcarrier_info_list_soap_align_BBOX5[${i}]['bandwidth']}
        ...    ${tx_carrier_dict_content_BBOX5['Carrier[${i}] bandwidth']}
        Should Be Equal    ${all_txcarrier_info_list_soap_align_BBOX5[${i}]['frequency']}
        ...    ${tx_carrier_dict_content_BBOX5['Carrier[${i}] frequency']}
        Should Be Equal    ${all_txcarrier_info_list_soap_align_BBOX5[${i}]['type']}    ${tx_carrier_dict_content_BBOX5['Carrier[${i}] type']}
        Should Be Equal    ${all_txcarrier_info_list_soap_align_BBOX5[${i}]['power']}    ${tx_carrier_dict_content_BBOX5['Carrier[${i}] power']}
    END
    FOR    ${i}    IN RANGE    ${all_rxcarrier_info_list_num}
        Should Be Equal    ${all_rxcarrier_info_list_soap_align_BBOX5[${i}]['distName']}    ${rx_carrier_dict_content_BBOX5['Carrier[${i}] name']}
        Should Be Equal    ${all_rxcarrier_info_list_soap_align_BBOX5[${i}]['array']}    ${rx_carrier_dict_content_BBOX5['Carrier[${i}] antenna']}
        Should Be Equal    ${all_rxcarrier_info_list_soap_align_BBOX5[${i}]['bandwidth']}
        ...    ${rx_carrier_dict_content_BBOX5['Carrier[${i}] bandwidth']}
        Should Be Equal    ${all_rxcarrier_info_list_soap_align_BBOX5[${i}]['frequency']}
        ...    ${rx_carrier_dict_content_BBOX5['Carrier[${i}] frequency']}
        Should Be Equal    ${all_rxcarrier_info_list_soap_align_BBOX5[${i}]['type']}    ${rx_carrier_dict_content_BBOX5['Carrier[${i}] type']}
        Should Be Equal    ${rx_carrier_dict_content_BBOX5['Carrier[${i}] power']}    0
    END

Get BBOX5 file from RUlog
    [Arguments]    ${log_path}=${TS_CASE_LOG_PATH}    ${ru_index}=1    ${log_name}=14167_AQQA_rflog
    Collect RF Logs To TestPC    log_name=${log_name}    ru_index=${ru_index}
    Run  rm -rf ${log_path}/${log_name}
    Run  unzip ${log_path}/${log_name}.zip -d ${log_path}/${log_name}
    Run  unzip ${log_path}/${log_name}/1011_BBOX5*.zip -d ${log_path}/${log_name}
    ${BBOX5_file_path}    set variable    ${log_path}/${log_name}/BBOX5
    [Return]    ${BBOX5_file_path}

Get startup soap log from RUlog
    [Arguments]    ${log_path}=${TS_CASE_LOG_PATH}    ${ru_index}=1    ${log_name}=14167_AQQA_rflog_check_soap
    ${all_soap_path}    Create List
    Collect RF Logs To TestPC    log_name=${log_name}    ru_index=${ru_index}
    Run    rm -rf ${log_path}/${log_name}
    Run    unzip ${log_path}/${log_name}.zip -d ${log_path}/${log_name}
    ${UOAM_soap_file_name}=    Run    command=ls '${log_path}/${log_name}' | grep -E "1011_UnitOAM_SOAP_Log\.(zip|tar)"
    ${UOAM_soap_file_type}=    Split String    ${UOAM_soap_file_name}    .
    Run Keyword If    '${UOAM_soap_file_type[1]}'=='zip'
    ...    Run    unzip ${log_path}/${log_name}/1011_UnitOAM_SOAP_Log*.zip -d ${log_path}/${log_name}
    ...    ELSE IF    '${UOAM_soap_file_type[1]}'=='tar'
    ...    Run    tar -xvf ${log_path}/${log_name}/1011_UnitOAM_SOAP_Log*.tar -C ${log_path}/${log_name}/UnitOAM_SOAP_Startup_LBTS_log
    Sleep    10s
    Run    unzip ${log_path}/${log_name}/UnitOAM_SOAP_Startup_LBTS_OM*.zip -d ${log_path}/${log_name}/UnitOAM_SOAP_Startup_LBTS_log
    Sleep    10s
    ${all_soap_file}=    Run    command= ls ${log_path}/${log_name}/UnitOAM_SOAP_Startup_LBTS_log
    ${all_soap_file}    Split String    ${all_soap_file}    \n
    ${soap_file_num}    Get Length    ${all_soap_file}
    FOR    ${i}    IN RANGE    ${soap_file_num}
        ${filename}    Split String    ${all_soap_file[${i}]}    .
        ${filename}    Set Variable    ${filename[0]}
        Run    command=gunzip -d ${log_path}/${log_name}/UnitOAM_SOAP_Startup_LBTS_log/${all_soap_file[${i}]}
        Append To List    ${all_soap_path}    ${log_path}/${log_name}/UnitOAM_SOAP_Startup_LBTS_log/${filename}.xml
    END
    [Return]    ${all_soap_path}

Special_RF_module_reset_from_GUI
    [Arguments]  ${ru_index}=2    ${gnb_index}=${0}    ${connection}=GNB_OAM
    ${ru_index_list}  Get All RU Index    connection=${connection}
    wait until keyword succeeds    3x    5sec    Selenium Login And Disable Screen Lock    gnb_index=${gnb_index}
    log to console    \n***RF Module index ${ru_index} Reset from GUI***
    ${ru_index}  Convert To Integer    ${ru_index}
    selenium_coam.reset_ru  ru_index=${ru_index}
    Wait Until Keyword Succeeds    5min    5s    RU Should Be Offline    ru_index=${ru_index}    connection=${connection}
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'    gnb_index=${gnb_index}    connection=${connection}
    [Teardown]  Selenium Logout And Close Browser

get rmod all sfp info list
    [Arguments]  ${connection}=GNB_OAM    ${ru_index}=1
    ${ru_name}    Catenate    SEPARATOR=-    RMOD    ${ru_index}
	${links}    coam.get_sfp_links   timeout=20    connection=${connection}
	${sfp_name_list}    Create List
	${connected_link_ports_list}    set variable    ${links['connected']}
    ${all_sfps_info_list_coam}    create list
	${not_connected_link_ports_list}    set variable    ${links['notConnected']}
    FOR  ${link}  IN  @{connected_link_ports_list}
        ${OPT_name}    Set Variable    ${link['details']['hardwareParameters']['physicalPort']['source']}
        ${SFP_name}=    Run Keyword If    '${OPT_name}'=='OPT_IF1'    Set Variable    SFP0
        ...    ELSE IF    '${OPT_name}'=='OPT_IF2'    Set Variable    SFP1
        ...    ELSE IF    '${OPT_name}'=='OPT_IF3'    Set Variable    SFP2
        ...    ELSE IF    '${OPT_name}'=='OPT_IF4'    Set Variable    SFP3
        ${status}    Run Keyword And Return Status    Should Contain    ${link['data']['linkPorts']['source']}    ${ru_name}
        Run Keyword If    '${SFP_name}'!='None' and ${status}    Append To List    ${sfp_name_list}    ${SFP_name}
        ${item}  create dictionary  linkPort=${link['data']['linkPorts']['source']}
        ...    SFP_name=${SFP_name}
        ...     vendor=${link['details']['hardwareParameters']['vendor']['source']}
        ...     vendorPartNumber=${link['details']['hardwareParameters']['vendorPartNumber']['source']}
        ...     serialNumber=${link['details']['hardwareParameters']['serialNumber']['source']}
        ...     speed=${link['details']['staticParameters']['nominalSignalingRate']['source']}
        Run Keyword If    ${status}     Append To List    ${all_sfps_info_list_coam}    ${item}
    END
    FOR  ${link}  IN  @{not_connected_link_ports_list}
        ${OPT_name}    Set Variable    ${link['details']['hardwareParameters']['physicalPort']['source']}
        ${SFP_name}=    Run Keyword If    '${OPT_name}'=='OPT_IF1'    Set Variable    SFP0
        ...    ELSE IF    '${OPT_name}'=='OPT_IF2'    Set Variable    SFP1
        ...    ELSE IF    '${OPT_name}'=='OPT_IF3'    Set Variable    SFP2
        ...    ELSE IF    '${OPT_name}'=='OPT_IF4'    Set Variable    SFP3
        ${status}    Run Keyword And Return Status    Should Contain    ${link['data']['linkPorts']['source']}    ${ru_name}
        Run Keyword If    '${SFP_name}'!='None' and ${status}    Append To List    ${sfp_name_list}    ${SFP_name}
        ${item}  create dictionary  linkPort=${link['data']['linkPorts']['source']}
        ...    SFP_name=${SFP_name}
        ...     vendor=${link['details']['hardwareParameters']['vendor']['source']}
        ...     vendorPartNumber=${link['details']['hardwareParameters']['vendorPartNumber']['source']}
        ...     serialNumber=${link['details']['hardwareParameters']['serialNumber']['source']}
        ...     speed=${link['details']['staticParameters']['nominalSignalingRate']['source']}
        Run Keyword If    ${status}     Append To List    ${all_sfps_info_list_coam}    ${item}
    END
    [Return]   ${all_sfps_info_list_coam}    ${sfp_name_list}


CB005763-DC_Dying_Gasp_alarm_check_ecpri_AQQJ
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}
    AlarmWatchdog.add_allow_alarms    fault_id=10
    verify all cells should be onair
    ${model}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[1].pdu_port.pdu.__class__.__name__}
    ${address}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[1].pdu_port.pdu.addr}
    ${port}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[1].pdu_port.port_no}
    log to console    model is ${model}, pb ip is ${address}, pb port is ${port}
    pdu.Setup Pdu    model=${model}   host=${address}    alias=pdu_ru_2
    pdu.power off    port=${port}    pdu_device=pdu_ru_2
    ${release}    Get program version based on gNB active version
    ${Supplementary_info}    Run Keyword If    "${release}"=="SBTS25R3"    Set Variable    RU connection was lost in runtime;RU power loss    ELSE
    ...    Set Variable    RU connection was lost in runtime. RU power loss.
    Wait Until Keyword Succeeds    5 min    10 sec    Check Specific Alarm in Alarm List    type=Active
    ...    faultId=10    Supplementary=${Supplementary_info}
    pdu.power on    port=${port}    pdu_device=pdu_ru_2
    Wait Until Keyword Succeeds    5 min    10 sec    Verify all cells should be onair
    [Teardown]    run keyword and ignore error    Perform RU Power On    ru_index=${2}
