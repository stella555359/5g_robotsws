*** Settings ***
Documentation    This is for SG8 powersaving common keywords
...              Author: wangqingqing
...              Squard: HZ SG8

Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/counter_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG08_keywords_SISO_operation.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot

*** Variables ***
${time_gap}    10

*** Keywords ***
Block All cells in RMOD
    [Arguments]     ${ru_index}=1
    ${nr_cell_id_ru}    Get All Cell Id    cell_type=nr    ru_index=${ru_index}
    ${nr_cell_num}    get length  ${nr_cell_id_ru}
    run keyword if  ${nr_cell_num}>0  Block all nr cell  block_list=${nr_cell_id_ru}
    ${lte_cell_id_ru}    Get All Cell Id    cell_type=lte    ru_index=${ru_index}
    ${lte_cell_num}    get length  ${lte_cell_id_ru}
    run keyword if  ${lte_cell_num}>0  Block all lte cell  block_list=${lte_cell_id_ru}

Unblock All cells in RMOD
    [Arguments]     ${ru_index}=1
    ${nr_cell_id_ru}    Get All Cell Id    cell_type=nr    ru_index=${ru_index}
    ${nr_cell_num}    get length  ${nr_cell_id_ru}
    run keyword if  ${nr_cell_num}>0  UnBlock all nr cell  block_list=${nr_cell_id_ru}
    ${lte_cell_id_ru}    Get All Cell Id    cell_type=lte    ru_index=${ru_index}
    ${lte_cell_num}    get length  ${lte_cell_id_ru}
    run keyword if  ${lte_cell_num}>0  UnBlock all lte cell  block_list=${lte_cell_id_ru}

Unblock All cells
    ${ru_index_list}    Get All RU Index    connection=GNB_OAM
    FOR    ${ru_index}    IN    @{ru_index_list}
        ${ru_index}    Convert To Integer    ${ru_index}
        ${powerState}    SG8 get RU Power State by ru index    ru_index=${ru_index}
        run keyword if  not '${powerState}' == 'UNAVAILABLE'
        ...    Unblock All cells in RMOD    ru_index=${ru_index}
    END

Set 9925 10766 flag and time schedule
    ${ru_index_list}    Get All RU Index    connection=GNB_OAM
    FOR    ${ru_index}    IN    @{ru_index_list}
        SG8 modify the parameter    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_index}    parameter_name=energySavingMode
        ...    value=DEEPSLEEP
    END
    SG8 modify the parameter    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    parameter_name=actRadioDeepSleepTimeSchedule    value=true
    FOR    ${ru_index}    IN    @{ru_index_list}
        check and change time schedule by rmodid    rmodid=${ru_index}
    END

only set 9925 10766 flag
    ${ru_index_list}    Get All RU Index    connection=GNB_OAM
    FOR    ${ru_index}    IN    @{ru_index_list}
        SG8 modify the parameter    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_index}    parameter_name=energySavingMode
        ...    value=DEEPSLEEP
    END
    SG8 modify the parameter    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    parameter_name=actRadioDeepSleepTimeSchedule    value=true

only set 9925 flag
    ${ru_index_list}    Get All RU Index    connection=GNB_OAM
    FOR    ${ru_index}    IN    @{ru_index_list}
        SG8 modify the parameter    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_index}    parameter_name=energySavingMode
        ...    value=DEEPSLEEP
    END
    SG8 modify the parameter    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    parameter_name=actRadioDeepSleepTimeSchedule    value=false

Check if RU enter deepsleep due to cell block and CB010766_CB009925
    [Arguments]     ${9925_flag}=true    ${10766_flag}=true    ${need_script_set_time}=true
    All RMODs should be awake if support 9925
    ${ru_index_list}    Get All RU Index    connection=GNB_OAM
    FOR    ${ru_index}    IN    @{ru_index_list}
        ${ru_index}    Convert To Integer    ${ru_index}
        ${powerState}    SG8 get RU Power State by ru index    ru_index=${ru_index}
        run keyword if  not '${powerState}' == 'UNAVAILABLE'
        ...    Block All cells in RMOD    ru_index=${ru_index}
    END
    run keyword if    '${9925_flag}'=='true' and '${10766_flag}'=='true' and '${need_script_set_time}'=='true'
        ...    run keywords    Set 9925 10766 flag and time schedule    AND
        ...    All RMODs should be sleep if support 9925
        ...    ELSE    run keyword if    '${9925_flag}'=='true' and '${10766_flag}'=='true' and '${need_script_set_time}'=='false'
        ...    run keywords    only set 9925 10766 flag    AND
        ...    All RMODs should be awake if support 9925
        ...    ELSE    run keyword if    '${9925_flag}'=='true' and '${10766_flag}'=='false' and '${need_script_set_time}'=='false'
        ...    run keywords    only set 9925 flag    AND
        ...    All RMODs should be sleep if support 9925
        ...    ELSE
        ...    log to console    now case does not include this scenario !!!

check and change all 431 lbpsPeriodList
    [Arguments]    ${scf_path}
    ${lbpsDayOfWeek}    ${lbpsStartTimeHour}    ${lbpsStartTimeMinute}    get_lbps_current_week_and_time
    ${nrpgrp}    get_some_info_from_file_path    xml_file_path=${scf_path}
    ...    prefix="MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-    suffix="
    set test variable    ${nrpgrp}
    FOR    ${nrpgrp_index}    IN    @{nrpgrp}
        ${nrpgrp_index}    Convert To Integer    ${nrpgrp_index}
        SG8 common Change lbpsPeriodList by Coam    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${nrpgrp_index}
        ...    lbpsDayOfWeek=${lbpsDayOfWeek}    lbpsStartTimeHour=${lbpsStartTimeHour}    lbpsStartTimeMinute=${lbpsStartTimeMinute}
    END
    ${lnbtsID}    Get lnbts ID via online SCF
    set test variable    ${lnbtsID}
    ${psgrp}    get_some_info_from_file_path    xml_file_path=${scf_path}
    ...    prefix="MRBTS-${mrbtsID}/LNBTS-${lnbtsID}/PSGRP-    suffix="
    set test variable    ${psgrp}
    FOR    ${psgrp_index}    IN    @{psgrp}
        ${psgrp_index}    Convert To Integer    ${psgrp_index}
        SG8 common Change lbpsPeriodList by Coam    dist_name=MRBTS-${mrbtsID}/LNBTS-${lnbtsID}/PSGRP-${psgrp_index}
        ...    lbpsDayOfWeek=${lbpsDayOfWeek}    lbpsStartTimeHour=${lbpsStartTimeHour}    lbpsStartTimeMinute=${lbpsStartTimeMinute}
    END

Check if RU enter deepsleep due to cell energysaving and CB010766_CB009925
    [Arguments]     ${9925_flag}=true    ${10766_flag}=true    ${need_script_set_time}=true
    ${SCF_9925}    Replace String    ${Golden_SCF_Path}    .xml    _only_10766_431_9925.xml
    set test variable  ${SCF_9925}
    Commissioning SCF And Check On Air   scf_path=${SCF_9925}
    Wait until keyword succeeds    10min    30s    Check all cells info should be onair
    All RMODs should be awake if support 9925
    check and change all 431 lbpsPeriodList    scf_path=${SCF_9925}
    ${nrcell_energysaving}    get_some_info_from_file_path    xml_file_path=${SCF_9925}    prefix=<p name="nrCellId">
    set test variable  ${nrcell_energysaving}
    ${ltecell_energysaving}    get_some_info_from_file_path    xml_file_path=${SCF_9925}    prefix=<p name="lnCelId">
    set test variable  ${ltecell_energysaving}
    check nr and lte cell enter energysaving    nrcell_list=${nrcell_energysaving}    ltecell_list=${ltecell_energysaving}
    run keyword if    '${9925_flag}'=='true' and '${10766_flag}'=='true' and '${need_script_set_time}'=='true'
        ...    run keywords    Set 9925 10766 flag and time schedule    AND
        ...    All RMODs should be sleep if support 9925
        ...    ELSE    run keyword if    '${9925_flag}'=='true' and '${10766_flag}'=='true' and '${need_script_set_time}'=='false'
        ...    run keywords    only set 9925 10766 flag    AND
        ...    All RMODs should be awake if support 9925
        ...    ELSE    run keyword if    '${9925_flag}'=='true' and '${10766_flag}'=='false' and '${need_script_set_time}'=='false'
        ...    run keywords    only set 9925 flag    AND
        ...    All RMODs should be sleep if support 9925
        ...    ELSE
        ...    log to console    now case does not include this scenario !!!

RU_exit_deepsleep_due_to_disbale_9925_AND_enter_due_to_cell_block
    Check if RU enter deepsleep due to cell block and CB010766_CB009925    9925_flag=true    10766_flag=true    need_script_set_time=true
    ${ru_index_list}    Get All RU Index    connection=GNB_OAM
    SG8 modify the parameter    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    parameter_name=actRadioDeepSleepTimeSchedule    value=false
    FOR    ${ru_index}    IN    @{ru_index_list}
        SG8 modify the parameter    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_index}    parameter_name=energySavingMode
        ...    value=NORMAL
    END
    All RMODs should be awake if support 9925
    Unblock All cells
    Wait until keyword succeeds    5min    30s    Check all cells info should be onair
    [Teardown]    run keyword and ignore error    Unblock All cells

RU_exit_deepsleep_due_to_10766_expire_AND_enter_due_to_cell_energysaving
    ${SCF_9925}    Replace String    ${Golden_SCF_Path}    .xml    _only_10766_431_9925.xml
    set test variable  ${SCF_9925}
    Commissioning SCF And Check On Air   scf_path=${SCF_9925}
    Check if RU enter deepsleep due to cell energysaving and CB010766_CB009925    9925_flag=true    10766_flag=true    need_script_set_time=true
    check and change all time schedule to expired by rmodid
    All RMODs should be awake if support 9925
    ${nrcell_energysaving}    get_some_info_from_file_path    xml_file_path=${SCF_9925}    prefix=<p name="nrCellId">
    set test variable  ${nrcell_energysaving}
    ${ltecell_energysaving}    get_some_info_from_file_path    xml_file_path=${SCF_9925}    prefix=<p name="lnCelId">
    set test variable  ${ltecell_energysaving}
    check more times to ensure nr or lte cells should be keep in energysaving
    ${nrpgrp}    get_some_info_from_file_path    xml_file_path=${SCF_9925}
    ...    prefix="MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-    suffix="
    ${lnbtsID}    Get lnbts ID via online SCF
    set test variable    ${lnbtsID}
    ${psgrp}    get_some_info_from_file_path    xml_file_path=${scf_path}
    ...    prefix="MRBTS-${mrbtsID}/LNBTS-${lnbtsID}/PSGRP-    suffix="
    run keyword if  ${nrpgrp}    SG8 modify the parameter    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    parameter_name=actNrLBPowerSaving    value=false
    run keyword if  ${psgrp}    SG8 modify the parameter    dist_name=MRBTS-${mrbtsID}/LNBTS-${lnbtsID}
    ...    parameter_name=actLBPowerSaving    value=false
    Wait until keyword succeeds    5min    30s    Check all cells info should be onair

Get deepSleepTimeSchedule by Coam
    [Arguments]    ${rmodid}=1    ${connection}=GNB_OAM
    ${MO_R}    coam.get_managed_objects    class_name=RMOD_A    connection=${connection}
    ${distname_tmp}    Set variable    ${MO_R[0]['distName']}
    ${distname}    generate_correct_rmod_distname    distname_before=${distname_tmp}    rmodid=${rmodid}
    ${deepSleepTimeSchedule}    coam.get_parameters   dist_name=${distname}    pattern=deepSleepTimeSchedule   connection=${connection}
    [Return]    ${deepSleepTimeSchedule}

Get energySavingMode By rmod index
    [Arguments]    ${rmodid}=1    ${connection}=GNB_OAM
    ${MO_R}    coam.get_managed_objects    class_name=RMOD_A    connection=${connection}
    ${distname_tmp}    Set variable    ${MO_R[0]['distName']}
    ${distname}    generate_correct_rmod_distname    distname_before=${distname_tmp}    rmodid=${rmodid}
    ${dict_pattern}     coam.get_parameters   dist_name=${distname}    pattern=energySavingMode   connection=${connection}
    ${energySavingMode}    set variable     ${dict_pattern['energySavingMode']}
    [Return]    ${energySavingMode}

Get actRadioDeepSleepTimeSchedule by coam
    [Arguments]    ${connection}=GNB_OAM
    ${MO_R}    coam.get_managed_objects    class_name=FEATCADM_A    connection=${connection}
    ${distname}    Set variable    ${MO_R[0]['distName']}
    ${dict_pattern}     coam.get_parameters   dist_name=${distname}    pattern=actRadioDeepSleepTimeSchedule   connection=${connection}
    ${10766_flag}    set variable     ${dict_pattern['actRadioDeepSleepTimeSchedule']}
    [Return]    ${10766_flag}

check and judge if RU enter deepsleep and output report
    [Arguments]    ${connection}=GNB_OAM
    ${10766_flag}    Get actRadioDeepSleepTimeSchedule by coam
    ${ru_index_list}    Get All RU Index    connection=${connection}
    ${lbpsDayOfWeek}    ${lbpsStartTimeHour}    ${lbpsStartTimeMinute}    get_lbps_current_week_and_time
    ${Week}    ${startTime}    get_deepsleep_start_time    hour=${lbpsStartTimeHour}    minute=${lbpsStartTimeMinute}    addonehour=False
    FOR    ${ru_index}    IN    @{ru_index_list}
        ${energySavingMode}    Get energySavingMode By rmod index    rmodid=${ru_index}
        ${TimeSchedule}    Get deepSleepTimeSchedule by Coam    rmodid=${ru_index}
	    ${tmp}    run keyword if    ${TimeSchedule}[deepSleepTimeSchedule]
        ...    set variable    ${TimeSchedule}[deepSleepTimeSchedule][0]
        ...    ELSE    Set Variable       NULL
        run keyword if    '${energySavingMode}'=='NORMAL'
        ...    log to console    RU:RMOD_${ru_index}, DSM: Disable, SleepWindow: None, None, None
        ...    ELSE    run keyword if    '${10766_flag}'=='False'
        ...    log to console    RU:RMOD_${ru_index}, DSM: Enable, SleepWindow: Every day, ${startTime}, ALL
        ...    ELSE    run keyword if    ${TimeSchedule}[deepSleepTimeSchedule]
        ...    log to console    RU:RMOD_${ru_index}, DSM: Enable, SleepWindow: ${tmp}[dayOfWeek], ${tmp}[startTime], ${tmp}[windowDuration]
        ...    ELSE
        ...    log to console    RU:RMOD_${ru_index}, DSM: Enable, SleepWindow: Every day, ${startTime}, ALL
    END

SG8 get RU Power State by ru index
    [Arguments]     ${ru_index}=1   ${connection}=GNB_OAM
    &{ru_status}    COAM get ru detial info by ru index     ru_index=${ru_index}    connection=${connection}
	[Return]    ${ru_status['status']['powerState']}

SG8 Check RU Power State by ru index
    [Arguments]     ${ru_index}=1   ${expect_state}=SLEEP
    ${powerState}    SG8 get RU Power State by ru index    ru_index=${ru_index}
	Should Be Equal As Strings  ${powerState}  ${expect_state}

SG8 modify the parameter
    [Arguments]    ${dist_name}    ${parameter_name}    ${value}
    coam.perform_parameter_recommissioning        dist_name=${dist_name}
    ...                                            parameter=${parameter_name}
    ...                                            value=${value}
    ...                                            operation=update
    ...                                            connection=GNB_OAM

SG8 create deepSleepTimeSchedule list
    [Arguments]    ${dayOfWeek}=Sun    ${startTime}=00:00    ${windowDuration}=35
    ${tmp}    create dictionary
    ...    dayOfWeek    ${dayOfWeek}
    ...    startTime    ${startTime}
    ...    windowDuration    ${windowDuration}
    ${tmp}     Create List    ${tmp}
    [Return]    ${tmp}

SG8 Change deepSleepTimeSchedule by Coam
    [Arguments]    ${dist_name}    ${dayOfWeek}=Sun    ${startTime}=00:00    ${windowDuration}=35    ${connection}=GNB_OAM
    ${tmp}    SG8 create deepSleepTimeSchedule list    dayOfWeek=${dayOfWeek}    startTime=${startTime}    windowDuration=${windowDuration}
    ${deepSleepTimeSchedule}      create dictionary
    ...    dist_name    ${dist_name}
    ...    parameter    deepSleepTimeSchedule
    ...    value        ${tmp}
    ${parameters}    Create List    ${deepSleepTimeSchedule}
    ${delta_file}=   coam_parameter.create_update_parameters_delta  parameters=${parameters}  connection=${connection}
    coam_parameter.perform_scf_delta_commission  delta_file=${delta_file['updated']}    connection=${connection}
    sleep    20s

Block all nr cell
    [Arguments]  ${block_list}
    FOR  ${block_id}  IN  @{block_list}
        coam.block_cell    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbts_id}/NRCELL-${block_id}    connection=GNB_OAM
    END

Block all lte cell
    [Arguments]  ${block_list}
    ${lnbtsID}    Get lnbts ID via online SCF
    FOR  ${block_id}  IN  @{block_list}
        coam.block_cell    dist_name=MRBTS-${mrbtsID}/LNBTS-${lnbtsID}/LNCEL-${block_id}    connection=GNB_OAM
    END

UnBlock all nr cell
    [Arguments]  ${block_list}
    FOR  ${block_id}  IN  @{block_list}
        coam.unblock_cell    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbts_id}/NRCELL-${block_id}    connection=GNB_OAM
    END

UnBlock all lte cell
    [Arguments]  ${block_list}
    ${lnbtsID}    Get lnbts ID via online SCF
    FOR  ${block_id}  IN  @{block_list}
        coam.unblock_cell    dist_name=MRBTS-${mrbtsID}/LNBTS-${lnbtsID}/LNCEL-${block_id}    connection=GNB_OAM
    END

check and change time schedule by rmodid
    [Arguments]    ${rmodid}=1    ${addonehour}=False    ${windowDuration}=1440
    ${lbpsDayOfWeek}    ${lbpsStartTimeHour}    ${lbpsStartTimeMinute}    get_lbps_current_week_and_time
    ${Week}    ${startTime}    get_deepsleep_start_time    hour=${lbpsStartTimeHour}    minute=${lbpsStartTimeMinute}    addonehour=${addonehour}
    ${TimeSchedule}    Get deepSleepTimeSchedule by Coam    rmodid=${rmodid}
    run keyword if    ${TimeSchedule}[deepSleepTimeSchedule]
    ...    SG8 Change deepSleepTimeSchedule by Coam    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${rmodid}
    ...    dayOfWeek=${Week}    startTime=${startTime}    windowDuration=${windowDuration}

SG8 common Change lbpsPeriodList by Coam
    [Arguments]    ${dist_name}    ${lbpsDayOfWeek}=Fri    ${lbpsDuration}=1440    ${lbpsStartTimeHour}=0    ${lbpsStartTimeMinute}=0
    ...    ${connection}=GNB_OAM
    ${tmp}    create lbpsPeriodList list    lbpsDayOfWeek=${lbpsDayOfWeek}    lbpsDuration=${lbpsDuration}    lbpsStartTimeHour=${lbpsStartTimeHour}
    ...    lbpsStartTimeMinute=${lbpsStartTimeMinute}
    ${lbpsPeriodList}      create dictionary
    ...    dist_name    ${dist_name}
    ...    parameter    lbpsPeriodList
    ...    value        ${tmp}
    ${parameters}    Create List    ${lbpsPeriodList}
    ${delta_file}=   coam_parameter.create_update_parameters_delta  parameters=${parameters}  connection=${connection}
    coam_parameter.perform_scf_delta_commission  delta_file=${delta_file['updated']}    connection=${connection}
    sleep    20s

SG8 common Change lbpsPeriodList by Coam Include lbpsSuspended
    [Arguments]    ${dist_name}    ${lbpsDayOfWeek}=Fri    ${lbpsDuration}=1440    ${lbpsStartTimeHour}=0    ${lbpsStartTimeMinute}=0
    ...    ${lbpsSuspended}=notSuspended    ${connection}=GNB_OAM
    ${tmp}    create lbpsPeriodList list    lbpsDayOfWeek=${lbpsDayOfWeek}    lbpsDuration=${lbpsDuration}    lbpsStartTimeHour=${lbpsStartTimeHour}
    ...    lbpsStartTimeMinute=${lbpsStartTimeMinute}    lbpsSuspended=${lbpsSuspended}
    ${lbpsPeriodList}      create dictionary
    ...    dist_name    ${dist_name}
    ...    parameter    lbpsPeriodList
    ...    value        ${tmp}
    ${parameters}    Create List    ${lbpsPeriodList}
    ${delta_file}=   coam_parameter.create_update_parameters_delta  parameters=${parameters}  connection=${connection}
    coam_parameter.perform_scf_delta_commission  delta_file=${delta_file['updated']}    connection=${connection}
    sleep    20s

check and change all 10766 time schedule and 431 lbpsPeriodList
    [Arguments]    ${connection}=GNB_OAM
    ${lbpsDayOfWeek}    ${lbpsStartTimeHour}    ${lbpsStartTimeMinute}    get_lbps_current_week_and_time
    ${Week}    ${startTime}    get_deepsleep_start_time    hour=${lbpsStartTimeHour}    minute=${lbpsStartTimeMinute}
    ${ru_index_list}    Get All RU Index    connection=${connection}
    FOR    ${ru_index}    IN    @{ru_index_list}
        ${ru_index}    Convert To Integer    ${ru_index}
        ${TimeSchedule}    Get deepSleepTimeSchedule by Coam    rmodid=${ru_index}
        run keyword if    ${TimeSchedule}[deepSleepTimeSchedule]
        ...    SG8 Change deepSleepTimeSchedule by Coam    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_index}
        ...    dayOfWeek=${Week}    startTime=${startTime}    windowDuration=1440
    END
    ${nrpgrp}    get_some_info_from_file_path    xml_file_path=${SCF_9925}
    ...    prefix="MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-    suffix="
    set test variable    ${nrpgrp}
    FOR    ${nrpgrp_index}    IN    @{nrpgrp}
        ${nrpgrp_index}    Convert To Integer    ${nrpgrp_index}
        SG8 common Change lbpsPeriodList by Coam    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${nrpgrp_index}
        ...    lbpsDayOfWeek=${Week}    lbpsStartTimeHour=${lbpsStartTimeHour}    lbpsStartTimeMinute=${lbpsStartTimeMinute}
    END
    ${lnbtsID}    Get lnbts ID via online SCF
    set test variable    ${lnbtsID}
    ${psgrp}    get_some_info_from_file_path    xml_file_path=${SCF_9925}
    ...    prefix="MRBTS-${mrbtsID}/LNBTS-${lnbtsID}/PSGRP-    suffix="
    set test variable    ${psgrp}
    FOR    ${psgrp_index}    IN    @{psgrp}
        ${psgrp_index}    Convert To Integer    ${psgrp_index}
        SG8 common Change lbpsPeriodList by Coam    dist_name=MRBTS-${mrbtsID}/LNBTS-${lnbtsID}/PSGRP-${psgrp_index}
        ...    lbpsDayOfWeek=${Week}    lbpsStartTimeHour=${lbpsStartTimeHour}    lbpsStartTimeMinute=${lbpsStartTimeMinute}
    END

All RMODs should be awake if support 9925
    ${ru_index_list}    Get All RU Index    connection=GNB_OAM
    FOR    ${ru_index}    IN    @{ru_index_list}
        ${ru_index}    Convert To Integer    ${ru_index}
        ${powerState}    SG8 get RU Power State by ru index    ru_index=${ru_index}
        run keyword if  not '${powerState}' == 'UNAVAILABLE'
        ...    Wait Until Keyword Succeeds    8min    5s    SG8 Check RU Power State by ru index    ru_index=${ru_index}    expect_state=AWAKE
    END

All RMODs should be sleep if support 9925
    ${ru_index_list}    Get All RU Index    connection=GNB_OAM
    FOR    ${ru_index}    IN    @{ru_index_list}
        ${ru_index}    Convert To Integer    ${ru_index}
        ${powerState}    SG8 get RU Power State by ru index    ru_index=${ru_index}
        run keyword if  not '${powerState}' == 'UNAVAILABLE'
        ...    Wait Until Keyword Succeeds    5min    5s    SG8 Check RU Power State by ru index    ru_index=${ru_index}    expect_state=SLEEP
    END

check RMOD deepsleep status if 10766 time window expired
    ${ru_index_list}    Get All RU Index    connection=GNB_OAM
    FOR    ${ru_index}    IN    @{ru_index_list}
        ${ru_index}    Convert To Integer    ${ru_index}
        ${powerState}    SG8 get RU Power State by ru index    ru_index=${ru_index}
        ${TimeSchedule}    Get deepSleepTimeSchedule by Coam    rmodid=${ru_index}
        run keyword if    '${powerState}' != 'UNAVAILABLE' and ${TimeSchedule}[deepSleepTimeSchedule]
        ...    Wait Until Keyword Succeeds    5min    5s    SG8 Check RU Power State by ru index    ru_index=${ru_index}    expect_state=AWAKE
    END

All RMODs should be activate energysaving if support 9925
    ${ru_index_list}    Get All RU Index    connection=GNB_OAM
    FOR    ${ru_index}    IN    @{ru_index_list}
        ${ru_index}    Convert To Integer    ${ru_index}
        ${powerState}    SG8 get RU Power State by ru index    ru_index=${ru_index}
        run keyword if  not '${powerState}' == 'UNAVAILABLE'
        ...    SG8 modify the parameter    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_index}    parameter_name=energySavingMode
        ...    value=DEEPSLEEP
    END

check and change all time schedule to expired by rmodid
    ${ru_index_list}    Get All RU Index    connection=GNB_OAM
    FOR    ${ru_index}    IN    @{ru_index_list}
        ${ru_index}    Convert To Integer    ${ru_index}
        check and change time schedule by rmodid    rmodid=${ru_index}    addonehour=True
    END

check and change all time schedule to normal by rmodid
    ${ru_index_list}    Get All RU Index    connection=GNB_OAM
    FOR    ${ru_index}    IN    @{ru_index_list}
        ${ru_index}    Convert To Integer    ${ru_index}
        check and change time schedule by rmodid    rmodid=${ru_index}
    END

check nr and lte cell enter energysaving
    [Arguments]    ${nrcell_list}    ${ltecell_list}
    FOR    ${index}    IN    @{nrcell_list}
        ${index}    Convert To Integer    ${index}
        Wait Until Keyword Succeeds    20min    30s    Check cell EnergySaving state via COAM    expect_energySavingState=energySaving
        ...    cellID=${index}
    END
    FOR    ${index}    IN    @{ltecell_list}
        ${index}    Convert To Integer    ${index}
        Wait Until Keyword Succeeds    20min    30s    Check cell EnergySaving state via COAM    expect_energySavingState=energySaving
        ...    class_name=LNCEL_R    cellID=${index}    celltype=lte
    END

nr or lte cells should be keep in energysaving
    [Arguments]    ${nrcell_list}    ${ltecell_list}
    FOR    ${index}    IN    @{nrcell_list}
        ${index}    Convert To Integer    ${index}
        Check cell EnergySaving state via COAM    expect_energySavingState=energySaving
        ...    cellID=${index}
    END
    FOR    ${index}    IN    @{ltecell_list}
        ${index}    Convert To Integer    ${index}
        Check cell EnergySaving state via COAM    expect_energySavingState=energySaving
        ...    class_name=LNCEL_R    cellID=${index}    celltype=lte
    END

check more times to ensure nr or lte cells should be keep in energysaving
    FOR    ${TEST_LOOP}    IN RANGE    0    50
        nr or lte cells should be keep in energysaving    nrcell_list=${nrcell_energysaving}    ltecell_list=${ltecell_energysaving}
        sleep    5s
    END

all cells enter energysaving by ru
    [Arguments]    ${ru_index}
    ${nr_cell_id_ru}    Get All Cell Id    cell_type=nr    ru_index=${ru_index}
    FOR    ${nr_cell_index_ru}    IN    @{nr_cell_id_ru}
        ${nr_cell_index_ru}    Convert To Integer    ${nr_cell_index_ru}
        Check cell EnergySaving state via COAM    expect_energySavingState=energySaving
        ...    cellID=${nr_cell_index_ru}
    END
    ${lte_cell_id_ru}    Get All Cell Id    cell_type=lte    ru_index=${ru_index}
    FOR    ${lte_cell_index_ru}    IN    @{lte_cell_id_ru}
        ${lte_cell_index_ru}    Convert To Integer    ${lte_cell_index_ru}
        Check cell EnergySaving state via COAM    expect_energySavingState=energySaving
        ...    class_name=LNCEL_R    cellID=${lte_cell_index_ru}    celltype=lte
    END

check ru enter deepsleep due 431
    [Arguments]    ${connection}=GNB_OAM
    ${ru_index_list}    Get All RU Index    connection=${connection}
    FOR    ${ru_index}    IN    @{ru_index_list}
        ${ru_index}    Convert To Integer    ${ru_index}
        ${powerState}    SG8 get RU Power State by ru index    ru_index=${ru_index}
		${energysaving_status}    Run Keyword And Return Status    all cells enter energysaving by ru    ru_index=${ru_index}
        Run Keyword If    ${energysaving_status} and '${powerState}' != 'UNAVAILABLE'
        ...    Wait Until Keyword Succeeds    10min    30s    SG8 Check RU Power State by ru index    ru_index=${ru_index}    expect_state=SLEEP
    END

check nr and lte cell enter energysaving by nr lte cell id
    [Arguments]    ${nrcell_index}    ${ltecell_index}
    FOR    ${LOOP}    IN RANGE    0    1000
	    Connect to Common Unit Master
        ${nr_energy}    Run Keyword If   '${nrcell_index}'!='None'
        ...    SG8_common_keywords.COAM get parameter value    class_name=NRCELL_R    pattern=energySavingState    cellID=${nrcell_index}
        ...    ELSE    set variable    None
        ${lte_energy}    Run Keyword If   '${ltecell_index}'!='None'
        ...    SG8_common_keywords.COAM get parameter value    class_name=LNCEL_R    pattern=energySavingState    cellID=${ltecell_index}
        ...    celltype=lte
        ...    ELSE    set variable    None
        ${origin_time}    Get time from GNB
        ${origin_time}    convert_date    ${origin_time}   datetime
        exit for loop if  '${nr_energy}' == 'energySaving' or '${lte_energy}' == 'energySaving'
        sleep    1s
        csn.Disconnect    connection=ASIK Master
    END
    ${nr_enter_energysaving_time}    Set variable    ${origin_time}
    ${lte_enter_energysaving_time}    Set variable    ${origin_time}
    FOR    ${LOOP}    IN RANGE    0    1000
        exit for loop if  '${nr_energy}' == 'energySaving' or '${nr_energy}'=='None'
        Connect to Common Unit Master
        ${nr_energy}    SG8_common_keywords.COAM get parameter value    class_name=NRCELL_R    pattern=energySavingState    cellID=${nrcell_index}
        ${origin_time}    Get time from GNB
        ${origin_time}    convert_date    ${origin_time}   datetime
        ${nr_enter_energysaving_time}    Set variable    ${origin_time}
        sleep    1s
        csn.Disconnect    connection=ASIK Master
    END
    FOR    ${LOOP}    IN RANGE    0    1000
        exit for loop if  '${lte_energy}' == 'energySaving' or '${lte_energy}'=='None'
        Connect to Common Unit Master
        ${lte_energy}    SG8_common_keywords.COAM get parameter value    class_name=LNCEL_R    pattern=energySavingState    cellID=${ltecell_index}
        ...    celltype=lte
        ${origin_time}    Get time from GNB
        ${origin_time}    convert_date    ${origin_time}   datetime
        ${lte_enter_energysaving_time}    Set variable    ${origin_time}
        sleep    1s
        csn.Disconnect    connection=ASIK Master
    END
    set test variable  ${nr_enter_energysaving_time}
    set test variable  ${lte_enter_energysaving_time}

check nr and lte cell exit energysaving by nr lte cell id
    [Arguments]    ${nrcell_index}    ${ltecell_index}
    FOR    ${TEST_LOOP}    IN RANGE    0    1000
        Connect to Common Unit Master
        ${nr_energy}    Run Keyword If   '${nrcell_index}'!='None'
        ...    SG8_common_keywords.COAM get parameter value    class_name=NRCELL_R    pattern=energySavingState    cellID=${nrcell_index}
        ...    ELSE    set variable    None
        ${lte_energy}    Run Keyword If   '${ltecell_index}'!='None'
        ...    SG8_common_keywords.COAM get parameter value    class_name=LNCEL_R    pattern=energySavingState    cellID=${ltecell_index}
        ...    celltype=lte
        ...    ELSE    set variable    None
        ${origin_time}    Get time from GNB
        ${origin_time}    convert_date    ${origin_time}   datetime
        exit for loop if  '${nr_energy}' == 'notEnergySaving' or '${lte_energy}' == 'notEnergySaving'
        sleep    1s
       csn.Disconnect    connection=ASIK Master
    END
    ${nr_exit_energysaving_time}    Set variable    ${origin_time}
    ${lte_exit_energysaving_time}    Set variable    ${origin_time}
    FOR    ${TEST_LOOP}    IN RANGE    0    1000
        exit for loop if  '${nr_energy}' == 'notEnergySaving' or '${nr_energy}'=='None'
        Connect to Common Unit Master
        ${nr_energy}   SG8_common_keywords.COAM get parameter value    class_name=NRCELL_R    pattern=energySavingState    cellID=${nrcell_index}
        ${origin_time}    Get time from GNB
        ${origin_time}    convert_date    ${origin_time}   datetime
        ${nr_exit_energysaving_time}    Set variable    ${origin_time}
        sleep    1s
        csn.Disconnect    connection=ASIK Master
    END
    FOR    ${TEST_LOOP}    IN RANGE    0    1000
        exit for loop if  '${lte_energy}' == 'notEnergySaving' or '${lte_energy}'=='None'
        Connect to Common Unit Master
        ${lte_energy}    SG8_common_keywords.COAM get parameter value    class_name=LNCEL_R    pattern=energySavingState    cellID=${ltecell_index}
        ...    celltype=lte
        ${origin_time}    Get time from GNB
        ${origin_time}    convert_date    ${origin_time}   datetime
        ${lte_exit_energysaving_time}    Set variable    ${origin_time}
        sleep    1s
        csn.Disconnect    connection=ASIK Master
    END
    set test variable  ${nr_exit_energysaving_time}
    set test variable  ${lte_exit_energysaving_time}

Get time from energy saving to the cycle point
    [Arguments]    ${interval}    ${energysaving_time}
    ${interval_seconds}    Get Interval Seconds    ${interval}
    ${interval_minutes}    evaluate    ${interval_seconds}/60
    ${minutes}    set variable    ${energysaving_time.minute}
    ${second}    set variable    ${energysaving_time.second}
    ${second}    convert to integer     ${second}
    ${energy_minutes}    evaluate    ${interval_minutes}-${minutes}%${interval_minutes}
    ${energy_minutes}    convert to integer     ${energy_minutes}
    ${energy_time}    Evaluate    ${energy_minutes}*60
    ${energy_time}    Evaluate    ${energy_time}-${second}
    [Return]    ${energy_time}

Get time from the cycle point to not energy saving
    [Arguments]    ${interval}    ${not_energysaving_time}
    ${energy_time}    Get time from energy saving to the cycle point    interval=${interval}    energysaving_time=${not_energysaving_time}
	${not_energy_time}    Evaluate    900-${energy_time}
    [Return]    ${not_energy_time}

SG8 Get wait value minutes
    [Arguments]    ${interval}
    Connect to Common Unit Master
    ${interval_seconds}    Get Interval Seconds    ${interval}
    ${interval_minutes}    evaluate    ${interval_seconds}/60
    ${origin_time}    Get time from GNB
    ${origin_time}    convert_date    ${origin_time}   datetime
    ${minutes}    set variable    ${origin_time.minute}
    ${wait_time}    evaluate    ${interval_minutes}-${minutes}%${interval_minutes}
    [Return]    ${wait_time}

get and check counter M55601C01001 M55601C00501 and M55601C01003
    [Arguments]    ${M55601C01001_full_path}    ${M55601C00501_full_path}    ${M55601C01003_full_path}    ${M55601C00502_full_path}
    ...    ${energysaving_status}    ${counters_info}
    ${M55601C01001_value}    Get counter latest value    BTS_or_TRS=BTS    counter_id=M55601C01001
    ...    counters_info=${counters_info}    counter_full_path=${M55601C01001_full_path}
    ${M55601C01001_value}    convert to integer     ${M55601C01001_value}
    ${M55601C00501_value}    Get counter latest value    BTS_or_TRS=BTS    counter_id=M55601C00501
    ...    counters_info=${counters_info}    counter_full_path=${M55601C00501_full_path}
    ${M55601C00501_value}    convert to integer     ${M55601C00501_value}
    ${diff}    Get the diff    num1=${M55601C01001_value}    num2=${M55601C00501_value}
    Should Be True    ${diff}<3
    ${time}    Run Keyword If    '${energysaving_status}' == 'energySaving'
    ...    Get time from energy saving to the cycle point    interval=15min     energysaving_time=${nr_enter_energysaving_time}
    ...    ELSE    Get time from the cycle point to not energy saving    interval=15min     not_energysaving_time=${nr_exit_energysaving_time}
    ${diff}    Get the diff    num1=${M55601C01001_value}    num2=${time}
    Should Be True    ${diff}<${time_gap}
    ${M55601C00502_value}    Get counter latest value    BTS_or_TRS=BTS    counter_id=M55601C00502    counters_info=${counters_info}
    ...    counter_full_path=${M55601C00502_full_path}
    ${M55601C00502_value}    convert to integer     ${M55601C00502_value}
    Run Keyword If    '${energysaving_status}' == 'energySaving'    Should Be True    ${M55601C00502_value} == 1
    ...    ELSE    Should Be True    ${M55601C00502_value} == 0
    ${M55601C01003_value}    Get counter latest value    BTS_or_TRS=BTS    counter_id=M55601C01003    counters_info=${counters_info}
    ...    counter_full_path=${M55601C01003_full_path}
    ${M55601C01003_value}    convert to integer     ${M55601C01003_value}
#    Should Be True    ${M55601C01003_value} == 0

get and check counter M8020C4 M8020C5 and M8020C7
    [Arguments]    ${M8020C4_full_path}    ${M8020C7_full_path}    ${M8020C5_full_path}    ${M8020C8_full_path}    ${energysaving_status}
    ...    ${counters_info}
    ${M8020C4_value}    Get counter latest value    BTS_or_TRS=BTS    counter_id=M8020C4
    ...    counters_info=${counters_info}    counter_full_path=${M8020C4_full_path}
    ${M8020C4_value}    convert to integer     ${M8020C4_value}
    ${M8020C7_value}    Get counter latest value    BTS_or_TRS=BTS    counter_id=M8020C7
    ...    counters_info=${counters_info}    counter_full_path=${M8020C7_full_path}
    ${M8020C7_value}    convert to integer     ${M8020C7_value}
    ${diff}    Get the diff    num1=${M8020C4_value}    num2=${M8020C7_value}
    Run Keyword If    '${energysaving_status}' == 'energySaving'
    ...    Should Be True    ${diff}<2
    ...    ELSE    Should Be True    ${M8020C4_value} == ${M8020C7_value}
    ${time}    Run Keyword If    '${energysaving_status}' == 'energySaving'
    ...    Get time from energy saving to the cycle point    interval=15min     energysaving_time=${lte_enter_energysaving_time}
    ...    ELSE    Get time from the cycle point to not energy saving    interval=15min     not_energysaving_time=${lte_exit_energysaving_time}
    ${diff}    Get the diff    num1=${M8020C4_value}    num2=${time}
    Should Be True    ${diff}<${time_gap}
    ${M8020C5_value}    Get counter latest value    BTS_or_TRS=BTS    counter_id=M8020C5    counters_info=${counters_info}
    ...    counter_full_path=${M8020C5_full_path}
    ${M8020C5_value}    convert to integer     ${M8020C5_value}
#    Should Be True    ${M8020C5_value} == 0
    ${M8020C8_value}    Get counter latest value    BTS_or_TRS=BTS    counter_id=M8020C8    counters_info=${counters_info}
    ...    counter_full_path=${M8020C8_full_path}
    ${M8020C8_value}    convert to integer     ${M8020C8_value}
    Run Keyword If    '${energysaving_status}' == 'energySaving'
    ...    Should Be True    ${M8020C8_value} == 1
    ...    ELSE    Should Be True    ${M8020C8_value} == 0

random get nr and lte cell id
    ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}
    ${nrcell_energysaving}    get_some_info_from_file_path    xml_file_path=${scf_path}    prefix=<p name="nrCellId">
    set test variable  ${nrcell_energysaving}
    ${ltecell_energysaving}    get_some_info_from_file_path    xml_file_path=${scf_path}    prefix=<p name="lnCelId">
    set test variable  ${ltecell_energysaving}
    ${nr_cell_num}    get length  ${nrcell_energysaving}
    ${lte_cell_num}    get length  ${ltecell_energysaving}
    ${lte_cell_index}    Run Keyword If    ${lte_cell_num}>0    evaluate   random.choice(${ltecell_energysaving})   random
    ...    ELSE    set variable    None
    ${nr_cell_index}    Run Keyword If    ${nr_cell_num}>0    evaluate   random.choice(${nrcell_energysaving})   random
    ...    ELSE    set variable    None
    [Return]  ${nr_cell_index}  ${lte_cell_index}

Get counter table and check all necessary counters
    [Arguments]    ${nr_cell_index}    ${lte_cell_index}    ${energysaving_status}    ${connection}=GNB_OAM
    ${counters_info}    coam.get_counters_info    connection=${connection}    timeout=120
    Run Keyword If   '${nr_cell_index}'!='None'    get and check counter M55601C01001 M55601C00501 and M55601C01003
	...    M55601C00501_full_path=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${nr_cell_index}/NCAV/SAMPLES_NR_CELL_POWER_SAVING
    ...    M55601C01001_full_path=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${nr_cell_index}/NCAV/NR_CELL_PLAN_UNAVAIL_SAMPLES
    ...    M55601C01003_full_path=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${nr_cell_index}/NCAV/NR_CELL_UNPLAN_UNAVAIL_SAMPLE
    ...    M55601C00502_full_path=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${nr_cell_index}/NCAV/CHNG_TO_NR_CELL_POWER_SAVING
    ...    energysaving_status=${energysaving_status}    counters_info=${counters_info}
    Run Keyword If   '${lte_cell_index}'!='None'    get and check counter M8020C4 M8020C5 and M8020C7
	...    M8020C4_full_path=MRBTS-${mrbtsID}/LNBTS-${lnbtsID}/LNCEL-${lte_cell_index}/MCC-262/MNC-03/LTE_Cell_Avail/SAMPLES_CELL_PLAN_UNAVAIL
    ...    M8020C7_full_path=MRBTS-${mrbtsID}/LNBTS-${lnbtsID}/LNCEL-${lte_cell_index}/MCC-262/MNC-03/LTE_Cell_Avail/SAMPLES_CELL_POWER_SAVING
    ...    M8020C5_full_path=MRBTS-${mrbtsID}/LNBTS-${lnbtsID}/LNCEL-${lte_cell_index}/MCC-262/MNC-03/LTE_Cell_Avail/SAMPLES_CELL_UNPLAN_UNAVAIL
    ...    M8020C8_full_path=MRBTS-${mrbtsID}/LNBTS-${lnbtsID}/LNCEL-${lte_cell_index}/MCC-262/MNC-03/LTE_Cell_Avail/CHNG_TO_CELL_POWER_SAVING
    ...    energysaving_status=${energysaving_status}    counters_info=${counters_info}
    ${wait_time}    SG8 Get wait value minutes    interval=15min
    sleep    ${wait_time}min
    sleep    60
    ${counters_info}    coam.get_counters_info    connection=${connection}    timeout=120
    FOR    ${index}    IN    @{nrcell_energysaving}
	    ${M55601C01001_value}    Get counter latest value    BTS_or_TRS=BTS    counter_id=M55601C01001    counters_info=${counters_info}
        ...        counter_full_path=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${index}/NCAV/NR_CELL_PLAN_UNAVAIL_SAMPLES
        ${M55601C01001_value}    convert to integer     ${M55601C01001_value}
        ${M55601C00501_value}    Get counter latest value    BTS_or_TRS=BTS    counter_id=M55601C00501    counters_info=${counters_info}
        ...    counter_full_path=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${index}/NCAV/SAMPLES_NR_CELL_POWER_SAVING
        ${M55601C00501_value}    convert to integer     ${M55601C00501_value}
        ${diff}    Get the diff    num1=${M55601C01001_value}    num2=${M55601C00501_value}
        Should Be True    ${diff}<3
	    ${M55601C01003_value}    Get counter latest value    BTS_or_TRS=BTS    counter_id=M55601C01003    counters_info=${counters_info}
        ...    counter_full_path=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${index}/NCAV/NR_CELL_UNPLAN_UNAVAIL_SAMPLES
        ${M55601C01003_value}    convert to integer     ${M55601C01003_value}
        Should Be True    ${M55601C01003_value} == 0
        ${M55601C00502_value}    Get counter latest value    BTS_or_TRS=BTS    counter_id=M55601C00502    counters_info=${counters_info}
        ...    counter_full_path=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${index}/NCAV/CHNG_TO_NR_CELL_POWER_SAVING
        ${M55601C00502_value}    convert to integer     ${M55601C00502_value}
        Should Be True    ${M55601C00502_value} == 0
    END
    FOR    ${index}    IN    @{ltecell_energysaving}
	    ${M8020C4_value}    Get counter latest value    BTS_or_TRS=BTS    counter_id=M8020C4    counters_info=${counters_info}
        ...    counter_full_path=MRBTS-${mrbtsID}/LNBTS-${lnbtsID}/LNCEL-${index}/MCC-262/MNC-03/LTE_Cell_Avail/SAMPLES_CELL_PLAN_UNAVAIL
        ${M8020C4_value}    convert to integer     ${M8020C4_value}
        ${M8020C7_value}    Get counter latest value    BTS_or_TRS=BTS    counter_id=M8020C7    counters_info=${counters_info}
        ...    counter_full_path=MRBTS-${mrbtsID}/LNBTS-${lnbtsID}/LNCEL-${index}/MCC-262/MNC-03/LTE_Cell_Avail/SAMPLES_CELL_POWER_SAVING
        ${M8020C7_value}    convert to integer     ${M8020C7_value}
        ${diff}    Get the diff    num1=${M8020C4_value}    num2=${M8020C7_value}
        Run Keyword If    '${energysaving_status}' == 'energySaving'
        ...    Should Be True    ${diff}<2
        ...    ELSE    Should Be True    ${M8020C4_value} == ${M8020C7_value}
	    ${M8020C5_value}    Get counter latest value    BTS_or_TRS=BTS    counter_id=M8020C5    counters_info=${counters_info}
        ...    counter_full_path=MRBTS-${mrbtsID}/LNBTS-${lnbtsID}/LNCEL-${index}/MCC-262/MNC-03/LTE_Cell_Avail/SAMPLES_CELL_UNPLAN_UNAVAIL
        ${M8020C5_value}    convert to integer     ${M8020C5_value}
        Should Be True    ${M8020C5_value} == 0
        ${M8020C8_value}    Get counter latest value    BTS_or_TRS=BTS    counter_id=M8020C8    counters_info=${counters_info}
        ...    counter_full_path=MRBTS-${mrbtsID}/LNBTS-${lnbtsID}/LNCEL-${index}/MCC-262/MNC-03/LTE_Cell_Avail/CHNG_TO_CELL_POWER_SAVING
        ${M8020C8_value}    convert to integer     ${M8020C8_value}
        Should Be True    ${M8020C8_value} == 0
    END

check power saving counters after cell enter energysaving
    ${nr_cell_index}    ${lte_cell_index}    random get nr and lte cell id
    check nr and lte cell enter energysaving by nr lte cell id    nrcell_index=${nr_cell_index}    ltecell_index=${lte_cell_index}
    ${wait_time}    SG8 Get wait value minutes    interval=15min
    sleep    ${wait_time}min
    sleep    60
    Get counter table and check all necessary counters     nr_cell_index=${nr_cell_index}    lte_cell_index=${lte_cell_index}
    ...    energysaving_status=energySaving

check power saving counters after cell exit energysaving
    ${nr_cell_index}    ${lte_cell_index}    random get nr and lte cell id
    check nr and lte cell exit energysaving by nr lte cell id    nrcell_index=${nr_cell_index}    ltecell_index=${lte_cell_index}
    ${wait_time}    SG8 Get wait value minutes    interval=15min
    sleep    ${wait_time}min
    sleep    60
    Get counter table and check all necessary counters     nr_cell_index=${nr_cell_index}    lte_cell_index=${lte_cell_index}
    ...    energysaving_status=notEnergySaving

Power Saving counters Testing
    ${SCF_9925}    Replace String    ${Golden_SCF_Path}    .xml    _only_10766_431_9925.xml
    set test variable  ${SCF_9925}
    ${nrcell_energysaving}    get_some_info_from_file_path    xml_file_path=${SCF_9925}    prefix=<p name="nrCellId">
    set test variable  ${nrcell_energysaving}
    ${ltecell_energysaving}    get_some_info_from_file_path    xml_file_path=${SCF_9925}    prefix=<p name="lnCelId">
    set test variable  ${ltecell_energysaving}
    Commissioning SCF And Check On Air   scf_path=${SCF_9925}
    Wait until keyword succeeds    10min    30s    Check all cells info should be onair
    All RMODs should be awake if support 9925
    log to console    ---------------------------------------------------------------------------------------
    log to console    Step 1 enable 431 10766 and check RU enter deep sleep
    log to console    ---------------------------------------------------------------------------------------
    SG8 modify the parameter    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    parameter_name=actRadioDeepSleepTimeSchedule    value=true
    All RMODs should be activate energysaving if support 9925
    check and change all 10766 time schedule and 431 lbpsPeriodList
    run keyword if  ${nrpgrp}    SG8 modify the parameter    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    parameter_name=actNrLBPowerSaving    value=true
    run keyword if  ${psgrp}    SG8 modify the parameter    dist_name=MRBTS-${mrbtsID}/LNBTS-${lnbtsID}
    ...    parameter_name=actLBPowerSaving    value=true
    ${nr_cell_index}    ${lte_cell_index}    random get nr and lte cell id
    check nr and lte cell enter energysaving by nr lte cell id    nrcell_index=${nr_cell_index}    ltecell_index=${lte_cell_index}
    ${wait_time}    SG8 Get wait value minutes    interval=15min
    sleep    ${wait_time}min
    sleep    60
    Get counter table and check all necessary counters     nr_cell_index=${nr_cell_index}    lte_cell_index=${lte_cell_index}
    ...    energysaving_status=energySaving
    check nr and lte cell enter energysaving    nrcell_list=${nrcell_energysaving}    ltecell_list=${ltecell_energysaving}
    check ru enter deepsleep due 431
    log to console    ---------------------------------------------------------------------------------------
    log to console    Step 4 enable 10766 and disable 431
    log to console    ---------------------------------------------------------------------------------------
    SG8 modify the parameter    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    parameter_name=actRadioDeepSleepTimeSchedule    value=true
    run keyword if  ${nrpgrp}    SG8 modify the parameter    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    parameter_name=actNrLBPowerSaving    value=false
    run keyword if  ${psgrp}    SG8 modify the parameter    dist_name=MRBTS-${mrbtsID}/LNBTS-${lnbtsID}
    ...    parameter_name=actLBPowerSaving    value=false
    check and change all time schedule to normal by rmodid
    ${nr_cell_index}    ${lte_cell_index}    random get nr and lte cell id
    check nr and lte cell exit energysaving by nr lte cell id    nrcell_index=${nr_cell_index}    ltecell_index=${lte_cell_index}
    ${wait_time}    SG8 Get wait value minutes    interval=15min
    sleep    ${wait_time}min
    sleep    60
    Get counter table and check all necessary counters     nr_cell_index=${nr_cell_index}    lte_cell_index=${lte_cell_index}
    ...    energysaving_status=notEnergySaving
    All RMODs should be awake if support 9925
    Wait until keyword succeeds    10min    30s    Check all cells info should be onair

RU_exit_deepsleep_due_to_431_expire_AND_enter_due_to_cell_energysaving
    ${SCF_9925}    Replace String    ${Golden_SCF_Path}    .xml    _only_10766_431_9925.xml
    set test variable  ${SCF_9925}
    ${nrcell_energysaving}    get_some_info_from_file_path    xml_file_path=${SCF_9925}    prefix=<p name="nrCellId">
    set test variable  ${nrcell_energysaving}
    ${ltecell_energysaving}    get_some_info_from_file_path    xml_file_path=${SCF_9925}    prefix=<p name="lnCelId">
    set test variable  ${ltecell_energysaving}
    Commissioning SCF And Check On Air   scf_path=${SCF_9925}
    log to console    Step 1 enable 431 10766 and check RU enter deep sleep
    SG8 modify the parameter    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    parameter_name=actRadioDeepSleepTimeSchedule    value=true
    All RMODs should be activate energysaving if support 9925
    check and change all 10766 time schedule and 431 lbpsPeriodList
    check nr and lte cell enter energysaving    nrcell_list=${nrcell_energysaving}    ltecell_list=${ltecell_energysaving}
    check ru enter deepsleep due 431
	${lbpsDayOfWeek}    ${lbpsStartTimeHour}    ${lbpsStartTimeMinute}    get_lbps_current_week_and_time
    SG8 common Change lbpsPeriodList by Coam Include lbpsSuspended    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-1
    ...    lbpsDayOfWeek=${lbpsDayOfWeek}    lbpsStartTimeHour=${lbpsStartTimeHour}    lbpsStartTimeMinute=${lbpsStartTimeMinute}    lbpsDuration=1
    All RMODs should be awake if support 9925
    Wait until keyword succeeds    10min    30s    Check all cells info should be onair

use new scf in case
    ${SCF_9925}    Replace String    ${Golden_SCF_Path}    .xml    _only_10766_431_9925.xml
    set test variable  ${SCF_9925}

CB010766-SR-A-3 Entering_Exiting_Deep_Sleep_Mode_IWK_With_5GC000431
    [Arguments]    ${if_check_counter}=${True}    ${if_need_new_scf}=${True}
    run keyword if     ${if_need_new_scf}==${True}
    ...    use new scf in case
    ${nrcell_energysaving}    get_some_info_from_file_path    xml_file_path=${SCF_9925}    prefix=<p name="nrCellId">
    set test variable  ${nrcell_energysaving}
    ${ltecell_energysaving}    get_some_info_from_file_path    xml_file_path=${SCF_9925}    prefix=<p name="lnCelId">
    set test variable  ${ltecell_energysaving}
    FOR    ${TEST_LOOP}    IN RANGE    0    2
        log to console    ++++++++++++++++++++++++++++++++++++ Loop ${TEST_LOOP} ++++++++++++++++++++++++++++++++++++
        Connect to gnb coam via ssl
        Commissioning SCF And Check On Air   scf_path=${SCF_9925}
        Wait until keyword succeeds    10min    30s    Check all cells info should be onair
        All RMODs should be awake if support 9925
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 1 enable 431 10766 and check RU enter deep sleep
        log to console    ---------------------------------------------------------------------------------------
        SG8 modify the parameter    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1
        ...    parameter_name=actRadioDeepSleepTimeSchedule    value=true
        All RMODs should be activate energysaving if support 9925
        check and change all 10766 time schedule and 431 lbpsPeriodList
        Run keyword if    ${if_check_counter}==True    check power saving counters after cell enter energysaving
        check nr and lte cell enter energysaving    nrcell_list=${nrcell_energysaving}    ltecell_list=${ltecell_energysaving}
        check ru enter deepsleep due 431
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 2 Change 10766 period to an expired time and check RU awake
        log to console    ---------------------------------------------------------------------------------------
        check and change all time schedule to expired by rmodid
        check more times to ensure nr or lte cells should be keep in energysaving
        check RMOD deepsleep status if 10766 time window expired
        check more times to ensure nr or lte cells should be keep in energysaving
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 3 disable actRadioDeepSleepTimeSchedule and RU enter deep sleep
        log to console    ---------------------------------------------------------------------------------------
        SG8 modify the parameter    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1
        ...    parameter_name=actRadioDeepSleepTimeSchedule    value=false
        All RMODs should be sleep if support 9925
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 4 enable 10766 and disable 431
        log to console    ---------------------------------------------------------------------------------------
        SG8 modify the parameter    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1
        ...    parameter_name=actRadioDeepSleepTimeSchedule    value=true
        run keyword if  ${nrpgrp}    SG8 modify the parameter    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
        ...    parameter_name=actNrLBPowerSaving    value=false
        run keyword if  ${psgrp}    SG8 modify the parameter    dist_name=MRBTS-${mrbtsID}/LNBTS-${lnbtsID}
        ...    parameter_name=actLBPowerSaving    value=false
        Run keyword if    ${if_check_counter}==True    check power saving counters after cell exit energysaving
        check and change all time schedule to normal by rmodid
        All RMODs should be awake if support 9925
        Wait until keyword succeeds    10min    30s    Check all cells info should be onair
        sleep    10s
        csn.reset_cache
    END
    [Teardown]    Run keyword and ignore error     Check ERR Or WRN From Syslog    sys_logs_path=/tmp/btslog2/
    ...    UTE_logs_path=${UTE_logs_path}    base_file=${Base_ERR_WRN_csv_path}    Expected_ERR_WRN_deviation=0.1
    ...    Delete_old_ERR_WRN=15    Fail_Case=${False}    Clear_log=${False}    FilesSystem=/dev/vda2
    ...    Max_used_space_ratio=0.85

RU support deep sleep and do RU Recovery during deep sleep mode due to RU restart
    [Arguments]    ${ru_index}=1    ${connection}=GNB_OAM
    &{fault_49}     Create Dictionary     faultId=${49}
    ${ALLOWED_FAULT}   Create List   @{ALLOWED_FAULT}   ${fault_49}
    set test variable  ${ALLOWED_FAULT}
    SG8 modify the parameter    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_index}    parameter_name=energySavingMode
    ...    value=DEEPSLEEP
    check and change time schedule by rmodid    rmodid=${ru_index}
    sleep    10s
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    log to console    ++++ block cell ++++
    ${nr_cell_id_ru}    Get All Cell Id    cell_type=nr    ru_index=${ru_index}
    ${nr_cell_num}    get length  ${nr_cell_id_ru}
    run keyword if  ${nr_cell_num}>0  Block all nr cell  block_list=${nr_cell_id_ru}
    ${lte_cell_id_ru}    Get All Cell Id    cell_type=lte    ru_index=${ru_index}
    ${lte_cell_num}    get length  ${lte_cell_id_ru}
    run keyword if  ${lte_cell_num}>0  Block all lte cell  block_list=${lte_cell_id_ru}
    Wait Until Keyword Succeeds    10min    30s    SG8 Check RU Power State by ru index    ru_index=${ru_index}
    ...    expect_state=SLEEP
    sleep    10s
    coam.reset_unit    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_index}    force_radio_reset=${True}
    ...    timeout=${600}    connection=${connection}
#    Wait Until Keyword Succeeds    5min    5s    RU Should Be Offline    ru_index=${ru_index}
    Wait Until Keyword Succeeds    10min    30s    SG8 Check RU Power State by ru index    ru_index=${ru_index}
    ...    expect_state=AWAKE
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    ...    connection=GNB_OAM
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist With Event Time
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    case_start_timestamp=${timestamp}    connection=GNB_OAM
    should be true    ${history_alarm_status}
    sleep    30s
    Wait Until Keyword Succeeds    25min    30s    SG8 Check RU Power State by ru index    ru_index=${ru_index}
    ...    expect_state=SLEEP
    log to console    ++++ unblock cell ++++
    run keyword if  ${nr_cell_num}>0  UnBlock all nr cell  block_list=${nr_cell_id_ru}
    run keyword if  ${lte_cell_num}>0  UnBlock all lte cell  block_list=${lte_cell_id_ru}
    sleep    30s
    Wait Until Keyword Succeeds    10min    30s    SG8 Check RU Power State by ru index    ru_index=${ru_index}
    ...    expect_state=AWAKE
    Wait until keyword succeeds    5min    30s    Check all cells info should be onair

SG8 RU Recovery during deep sleep mode due to RU restart
    SG8 modify the parameter    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    parameter_name=actRadioDeepSleepTimeSchedule    value=true
    ${ru_index_list}    Get All RU Index    connection=GNB_OAM
    FOR    ${ru_index}    IN    @{ru_index_list}
        ${ru_index}    Convert To Integer    ${ru_index}
        ${powerState}    SG8 get RU Power State by ru index    ru_index=${ru_index}
        run keyword if  not '${powerState}' == 'UNAVAILABLE'
        ...    RU support deep sleep and do RU Recovery during deep sleep mode due to RU restart	ru_index=${ru_index}
    END

RU Recovery during deep sleep mode due to RU restart loop
    [Arguments]     ${Max_loop}=${100}
    FOR    ${TEST_LOOP}    IN RANGE    ${Max_loop}
        log to console    ++++ start test loop ${TEST_LOOP} ++++
        Connect to gnb coam via ssl
        SG8 RU Recovery during deep sleep mode due to RU restart
        csn.reset_cache
    END
    [Teardown]    run keywords    run keyword and ignore error    RU Recovery case recovery ENV    AND
    ...    Run keyword and ignore error     Check ERR Or WRN From Syslog    sys_logs_path=/tmp/btslog2/      UTE_logs_path=${UTE_logs_path}
    ...    base_file=${Base_ERR_WRN_csv_path}    Expected_ERR_WRN_deviation=0.1      Delete_old_ERR_WRN=15    Fail_Case=${False}
    ...    Clear_log=${False}    FilesSystem=/dev/vda2      Max_used_space_ratio=0.85

RU Recovery case recovery ENV
    Connect to gnb coam via ssl
    ${ru_index_list}    Get All RU Index    connection=GNB_OAM
    FOR    ${ru_index}    IN    @{ru_index_list}
        ${ru_index}    Convert To Integer    ${ru_index}
        ${nr_cell_id_ru}    Get All Cell Id    cell_type=nr    ru_index=${ru_index}
        ${nr_cell_num}    get length  ${nr_cell_id_ru}
        run keyword if  ${nr_cell_num}>0  UnBlock all nr cell  block_list=${nr_cell_id_ru}
        ${lte_cell_id_ru}    Get All Cell Id    cell_type=lte    ru_index=${ru_index}
        ${lte_cell_num}    get length  ${lte_cell_id_ru}
        run keyword if  ${lte_cell_num}>0  UnBlock all lte cell  block_list=${lte_cell_id_ru}
    END
