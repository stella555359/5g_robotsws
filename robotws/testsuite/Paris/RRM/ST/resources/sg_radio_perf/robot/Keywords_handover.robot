*** Settings ***
Documentation    Resource file for HO scenario usage
...              Author : Annie Wong          annie.wong@nokia.com
...                     : Florence Thepot     florence.thepot@nokia.com
...                     : Pape Diallo         pape.diallo@nokia.com
...                     : Yves Gorjux         yves.gorjux@nokia.com
...
...              last update : 02.10.2020 : add condition for qxdm trace capture (only QCT UE !)
...                            06.10.2020 : remove qxdm trace capture
...                            01.02.2021 : change measurement additional wait time value (from 70s to 50s)
...                            03.02.2021 : refactoring of code
...							   12.05.2021 : addition of keywords for 706 tests

Library           BuiltIn
Library           OperatingSystem
#Library           ../python/Qualcomm_logs.py
Resource          Keywords_UE.robot
Resource          Keywords_Attenuation.robot


*** Keywords ***
Collect only last PM file for one gNB
    [Documentation]    The purpose of this keyword is to collect PM and archive only the last PM file
    [Arguments]        ${gnb_id}=0		${pm_dir_suffix}=pmcounters    ${period_id}=1
	# Retrieve all PM files into a temporary directory
	${temp_path}=    set variable     ${OUTPUTDIR}/${SUITENAME}/pm_temp
    ${pm_file}=      Wait until Keyword Succeeds   3x     30s    Collect PM Files And Get Last Period Filename
    ...                oam_type=coam
    ...                name=pm_temp
    ...                scope=testsuite
    ...                gnb_id=${gnb_id}
    Log       last period pm file gNB${gnb_id}==${pm_file}   console=${DEBUG_MODE_CONSOLE}
    # Copy the last PM file into the archive directory
    ${res_path}=    set variable     ${OUTPUTDIR}/${SUITENAME}/gnb${gnb_id}_${pm_dir_suffix}
    Create directory        ${res_path}
    Copy file               ${temp_path}/${pm_file}       ${res_path}/${pm_file}
	Remove Directory		${temp_path}	recursive=True
    Set Suite Variable      ${PM_PATH_P${period_id}_GNB${gnb_id}}         ${res_path}
    Set Suite Variable      ${PM_FILENAME_P${period_id}_GNB${gnb_id}}     ${pm_file}


Collect only last PM file for all gNB
    [Documentation]    The purpose of this keyword is to collect PM for all gNB and archive only the last PM file
    [Arguments]        ${pm_dir_suffix}=pmcounters    ${period_id}=1
    ${_id}      set variable    0
    ${gNBs}=    tl_info.get_gNBs
    FOR    ${elem}    IN    @{gNBs}
        Collect only last PM file for one gNB    gnb_id=${_id}    pm_dir_suffix=${pm_dir_suffix}    period_id=${period_id}
        ${_id}   evaluate    ${_id} + 1
    END


Attach UE with retrial if fail
    [Documentation]    The purpose of this keyword is to try a UE attach and redo the attach if the first trial fails
    Log      Attach UE (1st trial)     console=${DEBUG_MODE_CONSOLE}
    ${passed}     ${msg}    Run Keyword And Ignore Error        Start UE attach
    Log      Attach UE (1st trial) status: ${passed} ${msg}     console=${DEBUG_MODE_CONSOLE}
    Return From Keyword If   '${passed}' == 'PASS'
    sleep      30s
    Log    Detach UE    console=${DEBUG_MODE_CONSOLE}
	Run Keyword And Continue On Failure			Release UE
    Log      Attach UE (2nd trial)     console=${DEBUG_MODE_CONSOLE}
    ${passed}     ${msg}    Run Keyword And Ignore Error        Start UE attach
    Log      Attach UE (2nd trial) status: ${passed} ${msg}     console=${DEBUG_MODE_CONSOLE}
    Run Keyword If   '${passed}' != 'PASS'      Fail    msg=${msg}


Set Attenuation Setup and Attach the UE and Check the UE IP address
    [Documentation]    The purpose of this keyword is :
    ...                 - set attenuations on source and target channels to values required for attach
    ...                 - reserve UE
    ...                 - start QXDM5 logs (if required)
    ...                 - attach UE
	...                 - check UE IP address
	...                 - If there is no UE IP address defined, detach the UE, attach it again and retry
    [Arguments]        ${qxdm_logs}=${False}
    ...                ${source}=${source_attenuations_attach}   ${target}=${target_attenuations_attach}

    #bypass robocop
    ${qxdm_logs}    set variable    ${qxdm_logs}
    Log      Source:${source}   console=${DEBUG_MODE_CONSOLE}
    Log      Target:${target}   console=${DEBUG_MODE_CONSOLE}
    Set Source Attenuations     signals=${source}    verify=${False}
    Set Target Attenuations     signals=${target}    verify=${False}
    Sleep    5s
    Log      Setup UE   console=${DEBUG_MODE_CONSOLE}
    Setup UE
    ${path1}     ${sce_path}      Split Path      ${OUTPUTDIR}
    ${path2}     ${camp_path}     Split Path      ${path1}
    Log     log_path: ${camp_path}    console=${DEBUG_MODE_CONSOLE}
	# Run Keyword If     ${qxdm_logs}		Run Keywords
    # ...		Log     Start QXDM5 logs for 10mn    console=${DEBUG_MODE_CONSOLE}
	# ...   AND
    # ...		Qualcomm_logs.start_qxdm5_logs
    # ...           ${custom['iPerf_VM_UL_ipaddress']}
    # ...           ${custom['iPerf_VM_UL_login']}
    # ...           ${custom['iPerf_VM_UL_passwd']}
    # ...           ${qxdm_log_file}   600
    # ...           D:/Qualcomm/Traces/Auto/${camp_path}
    Attach UE with retrial if fail
    sleep   30s
    ${status}	${ip_ue}= 			Run Keyword And Ignore Error		ue_addr.Get UE IP address
    ...                                                            ${ULserver_ip}
    ...                                                            ${ULserver_login}
    ...                                                            ${ULserver_pwd}
	Run Keyword If		'${status}' == 'PASS'		Run Keywords
    ...		Log           UE ip = ${ip_ue}  console=${DEBUG_MODE_CONSOLE}
	...   AND
	...     Return From Keyword		${ip_ue}
	Log    There is no UE IP address defined. So try a second attach.
    Log    Detach UE    console=${DEBUG_MODE_CONSOLE}
    Run Keyword And Continue On Failure			Release UE
    Attach UE with retrial if fail
    ${ip_ue}= 			ue_addr.Get UE IP address
    ...                                                            ${ULserver_ip}
    ...                                                            ${ULserver_login}
    ...                                                            ${ULserver_pwd}
    Log           UE ip = ${ip_ue}  console=${DEBUG_MODE_CONSOLE}
	Return From Keyword		${ip_ue}


Start traffic Wait PM period Perform Handover and Stop traffic after PM period
    [Documentation]    The purpose of this keyword is :
    ...                 - start traffic if required
    ...                 - wait next PM period
    ...                 - increment source channels to trigger A2 event
    ...                 - set target channels to A2 values
	...                 - decrement target channels to trigger HO
	...                 - wait next pm period
	...                 - if needed, stop traffic
    [Arguments]   ${traffic_direction}=none    ${ip_ue}=none    ${tput_dl}=300M    ${tput_ul}=50M    ${duration}=600
    Log      traffic direction: ${traffic_direction} and traffic duration=${duration}    console=${DEBUG_MODE_CONSOLE}
    Run Keyword If     '${traffic_direction}'=='DL'
    ...        Start Process TrafficDL    distantip=${ip_ue}   tput=${tput_dl}   duration=${duration}   ueid=1
    Run Keyword If     '${traffic_direction}'=='UL'
    ...        Start Process TrafficUL    distantip=${ip_ue}   tput=${tput_ul}   duration=${duration}   ueid=2
    Run Keyword If     '${traffic_direction}'=='ULDL'
    ...        Start Process Traffic Simultaneous ULDL    distantip=${ip_ue}    tput_ul=${tput_ul}   tput_dl=${tput_dl}
    ...                                                   duration=${duration}   ueid=0
    # wait the beginning of a new Period to start to vary attenuations (traffic is on going)
    pm_collection.Wait For Next Measurement Period
    ...        meas_period_in_minute=${MeasPeriod}
    ...        additional_waiting_time_sec=3
    ...        gnb=${reference_gnb_for_time}
    # Increment source Channels up to trigger A2 event
    Increment Channels To Final Values through Steps
    ...    input_channels=${source_channels}
    ...    final_signals=${source_attenuations_a2}
    ...    step=20
    ...    attenuator_id=${source_attenuator_id}
    ...    verify=${False}
    Sleep    5s
    Set Target Attenuations     signals=${target_attenuations_a2}    verify=${True}
    # Decrement target Channels down to trigger HO event
    Decrement Channels To Final Values through Steps
    ...    input_channels=${target_channels}
    ...    final_signals=${target_attenuations_ho_trigger}
    ...    step=20
    ...    attenuator_id=${target_attenuator_id}
    ...    verify=${False}
    Sleep   5s
    # wait that period is finished to collect PM files
    pm_collection.Wait For Next Measurement Period
    ...        meas_period_in_minute=${MeasPeriod}
    ...        additional_waiting_time_sec=70
    ...        gnb=${reference_gnb_for_time}
    Sleep   5s
	Run Keyword If    '${traffic_direction}'=='DL'       Stop TrafficDL          ueid=1
    Run Keyword If    '${traffic_direction}'=='UL'       Stop TrafficUL          ueid=2
	Run Keyword If    '${traffic_direction}'=='ULDL'     Stop Traffic Simultaneous ULDL


Wait PM period Trigger event A1 then event A2 and wait PM period
    [Documentation]    The purpose of this keyword is :
    ...                 - wait next PM period
    ...                 - decrement source channels to trigger A1 event
	...                 - increment source channels to trigger A2 event
	...                 - wait next pm period
    # wait the beginning of a new Period to start to vary attenuations (traffic is on going)
    pm_collection.Wait For Next Measurement Period
    ...        meas_period_in_minute=${MeasPeriod}
    ...        additional_waiting_time_sec=3
    ...        gnb=${reference_gnb_for_time}
    # Decrement source Channels down to trigger A1 event
    Decrement Channels To Final Values through Steps
    ...    input_channels=${source_channels}
    ...    final_signals=${source_attenuations_a1}
    ...    step=20
    ...    attenuator_id=${source_attenuator_id}
    ...    verify=${False}
    Sleep    5s
    # increment source channels to trigger A2 event
    Increment Channels To Final Values through Steps
    ...    input_channels=${source_channels}
    ...    final_signals=${source_attenuations_a2}
    ...    step=20
    ...    attenuator_id=${source_attenuator_id}
    ...    verify=${False}
    Sleep   5s
    # wait that period is finished to collect PM files
    pm_collection.Wait For Next Measurement Period
    ...        meas_period_in_minute=${MeasPeriod}
    ...        additional_waiting_time_sec=70
    ...        gnb=${reference_gnb_for_time}
    Sleep   5s


Collect PM and wait next period
    [Documentation]    The purpose of this keyword is :
    ...                 - collect PM
    ...                 - wait the next period
    [Arguments]         ${gnb_nb}=all		${pm_dir_suffix}=pmcounters    ${period_id}=1
    Run Keyword if      ${gnb_nb}==all     Collect only last PM file for all gNB
    ...                                     pm_dir_suffix=${pm_dir_suffix}
    ...                                     period_id=${period_id}
    Run Keyword if  ${gnb_nb}!=all     Collect only last PM file for one gNB
    ...                                     gnb_id=${gnb_nb}
    ...                                     pm_dir_suffix=${pm_dir_suffix}
    ...                                     period_id=${period_id}
    # wait that period is finished to collect PM files
    pm_collection.Wait For Next Measurement Period
    ...        meas_period_in_minute=${MeasPeriod}
    ...        additional_waiting_time_sec=70
    ...        gnb=${reference_gnb_for_time}
    Sleep   5s


Detach UE and collect PM
    [Documentation]    The purpose of this keyword is :
    ...                 - stop QXDM5 logs (if required)
    ...                 - detach the UE
    ...                 - collect PM on all gNB
    ...                 - collect UE traces (if required)
    [Arguments]       ${gnb_nb}=all    ${pm_dir_suffix}=pmcounters    ${period_id}=1    ${qxdm_logs}=${False}

    #bypass robocop
    ${qxdm_logs}    set variable    ${qxdm_logs}
    Log    Detach UE    console=${DEBUG_MODE_CONSOLE}
    Release UE
    Run Keyword if      ${gnb_nb}==all     Collect only last PM file for all gNB
    ...                                     pm_dir_suffix=${pm_dir_suffix}
    ...                                     period_id=${period_id}
    Run Keyword if  ${gnb_nb}!=all     Collect only last PM file for one gNB
    ...                                     gnb_id=${gnb_nb}
    ...                                     pm_dir_suffix=${pm_dir_suffix}
    ...                                     period_id=${period_id}


HO scenario with call and traffic and Collect Pm during period with HO
    [Documentation]    The purpose of this keyword is :
    ...        - set initial attenuations, reserve the UE, start QXDM5 logs, attach the UE and check the UE IP address
    ...        - start traffic if required, wait next PM period, perform HO and stop traffic after next PM period
    ...        - detach UE, and collect PM
    ...        - set attenuations on source and target to Max at the end of test
    [Arguments]     ${traffic_direction}=ULDL     ${tput_dl}=300M     ${tput_ul}=50M     ${duration}=600    ${gnb}=all

    #bypass robocop
    ${traffic_direction}    set variable    ${traffic_direction}
    ${ip_ue}=      Set Attenuation Setup and Attach the UE and Check the UE IP address      qxdm_logs=${False}
    Start traffic Wait PM period Perform Handover and Stop traffic after PM period
	...             traffic_direction=ULDL
	...             ip_ue=${ip_ue}
	...             tput_dl=${tput_dl}
	...             tput_ul=${tput_ul}
	...             duration=${duration}
    Detach UE and collect PM     gnb_nb=${gnb}		pm_dir_suffix=pmcounters	period_id=1		qxdm_logs=${False}
    Set Source Channels Max Attenuations    verify=${True}
    Set Target Channels Max Attenuations    verify=${True}


# old name : HO scenario with traffic Collect Pm during period with HO and wait additional period without traffic
HO scenario with traffic Collect Pm during period with HO and wait next period without traffic
    [Documentation]    The purpose of this keyword is :
    ...        - set initial attenuations, reserve the UE, start QXDM5 logs, attach the UE and check the UE IP address
    ...        - start traffic if required, wait next PM period, perform HO and stop traffic after next PM period
    ...        - collect PM and wait next PM period
    ...        - detach UE, and collect PM
    ...        - set attenuations on source and target to Max at the end of test
    [Arguments]     ${traffic_direction}=ULDL     ${tput_dl}=300M     ${tput_ul}=50M     ${duration}=600    ${gnb}=all

    #bypass robocop
    ${traffic_direction}    set variable    ${traffic_direction}

    ${ip_ue}=      Set Attenuation Setup and Attach the UE and Check the UE IP address      qxdm_logs=${False}
    Start traffic Wait PM period Perform Handover and Stop traffic after PM period
	...             traffic_direction=ULDL
	...             ip_ue=${ip_ue}
	...             tput_dl=${tput_dl}
	...             tput_ul=${tput_ul}
	...             duration=${duration}
	Collect PM and wait next period     gnb_nb=${gnb}		pm_dir_suffix=ho_pmcounters		period_id=1
	Detach UE and collect PM     gnb_nb=${gnb}    pm_dir_suffix=drx_pmcounters    period_id=2    qxdm_logs=${False}
    Set Source Channels Max Attenuations    verify=${False}
    Set Target Channels Max Attenuations    verify=${False}


Trigger event A1 then event A2 and Collect Pm
    [Documentation]    The purpose of this keyword is :
    ...                 - set initial attenuations with a value to trigger directly event A2, reserve the UE,
    ...                   start QXDM5 logs, attach the UE and check the UE IP address
    ...                 - wait next PM period, trigger event A1 then event A2
    ...                 - wait next PM period, detach UE, and collect PM
    ...                 - set attenuations on source and target to Max at the end of test
    [Arguments]         ${gnb}=0
	${ip_ue}=       Set Attenuation Setup and Attach the UE and Check the UE IP address     qxdm_logs=${False}
	...                    source=${source_attenuations_a2}
	...                    target=${target_attenuations_attach}
    Wait PM period Trigger event A1 then event A2 and wait PM period
    Detach UE and collect PM     gnb_nb=${gnb}     pm_dir_suffix=pmcounters   period_id=1    qxdm_logs=${False}
    Set Source Channels Max Attenuations    verify=${False}
    Set Target Channels Max Attenuations    verify=${False}


HO Intra gNB scenario with call and traffic and Collect Pm to Targetpath
    [Documentation]    The purpose of this keyword is :
    ...                 - run keyword UE Attach and Traffic Then HO Intra gNB in One Measurement Period
    ...                 - collect PM files at end of current meas period
    ...
    ...         if targetpath=testcase,  store pm files in  ${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/gnb${gNB}_pmcounters
    ...         if targetpath=testsuite, store pm files in  ${OUTPUTDIR}/${SUITENAME}/gnb${gNB}_pmcounters
    ...
    ...   Please take note that testcase variable can be set here:
    ...      ${PM_FILENAME_TC} and ${PM_PATH_TC}
    ...   Please take note that testsuite variable can be set here:
    ...      ${PM_FILENAME} and ${PM_PATH}

    [Arguments]     ${targetpath}=testcase    ${gNB}=0    ${ue_index}=${0}    ${ue_capabilities}=REAL_ANDROID_UE
    ...             ${traffic_direction}=None    ${tput_dl}=600M     ${tput_ul}=100M    ${duration}=600

    Run Keyword If      '${targetpath}'=='testcase' or '${targetpath}'=='testsuite'
    ...                 log      targetpath type for PM files = ${targetpath}        console=${DEBUG_MODE_CONSOLE}
    ...    ELSE    Fail    targetpath not set correctly (value:${targetpath} /expected: testsuite or testcase)

    UE Attach and Traffic Then HO Intra gNB in One Measurement Period
    ...        traffic_direction=${traffic_direction}
    ...        tput_dl=${tput_dl}
    ...        tput_ul=${tput_ul}
    ...        duration=${duration}
    ...        gNB=${gNB}
    ...        ue_index=${ue_index}
    ...        ue_capabilities=${ue_capabilities}
    ${res_file}=      Collect PM Files And Get Last Period Filename
    ...          oam_type=coam
    ...          name=gnb${gNB}_pmcounters
    ...          scope=${targetpath}
    ...          gnb_id=${gNB}
    Log       last period pm file gNB${gNB}=${res_file}   console=${DEBUG_MODE_CONSOLE}

    # case pm files to be store in testsuite directory:
    Run keyword if    '${targetpath}'=='testsuite'     run keywords
    ...              Set Suite Variable      ${PM_PATH}        ${OUTPUTDIR}/${SUITENAME}/gnb${gNB}_pmcounters
    ...      AND     Set Suite Variable      ${PM_FILENAME}    ${res_file}

    # case pm files to be store in testcase directory:
    Run keyword if    '${targetpath}'=='testcase'      run keywords
    ...           Set Test Variable     ${PM_PATH_TC}       ${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/gnb${gNB}_pmcounters
    ...    AND    Set Test Variable     ${PM_FILENAME_TC}   ${res_file}


UE Attach and Traffic Then HO Intra gNB in One Measurement Period
    [Documentation]    The purpose of this keyword is :
    ...                 - set attenuations on target channels to Max
    ...                 - set attenuations on source channels to level corresponding to attach db values
    ...                 - reserve UE
    ...                 - wait begining of one meas period (${MeasPeriod} is a suite variable)
    ...                 - attach UE
    ...                 - start traffic if any (UL or DL, not None)
    ...                 - vary attenuations on source through steps to reach level corresponding to values for event a2
    ...                 - decrement target Channels down to trigger HO event
    ...                 - detach UE
    ...                 - set attenuations on source and target to Max at the end of test

    [Arguments]        ${gNB}=0     ${ue_index}=${0}    ${ue_capabilities}=REAL_ANDROID_UE
    ...                ${traffic_direction}=None     ${tput_dl}=600M     ${tput_ul}=100M     ${duration}=600
    # ...                 ${qxdm_log_name}=qxdm_log.hdf     ${qxdm_log_duration}=600

    Set Source Attenuations     signals=${source_attenuations_attach}    verify=${True}
    Set Target Attenuations     signals=${target_attenuations_attach}    verify=${True}
    Sleep    5s
    Log      Setup UE   console=${DEBUG_MODE_CONSOLE}
    Setup UE       ue_capabilities=${ue_capabilities}

    # run keyword if  '${UE_Architecture}'=='QCT'    run keywords
    # ...       Log     Start QXDM5 logs for 10mn    console=${DEBUG_MODE_CONSOLE}          AND
    # ...       Qualcomm_logs.start_qxdm5_logs
    # ...                 ${custom['iPerf_VM_UL_ipaddress']}
    # ...                 ${custom['iPerf_VM_UL_login']}
    # ...                 ${custom['iPerf_VM_UL_passwd']}
    # ...                 ${qxdm_log_name}
    # ...                 ${qxdm_log_duration}

    Log         Attach UE (2 tries)    console=${DEBUG_MODE_CONSOLE}
    ${passed}       Run Keyword and return status        Start UE attach     ue_index=${ue_index}
    Run keyword if      ${passed} == ${False}      Start UE attach     ue_index=${ue_index}

    # case Prisma, get ip_ue from variable UE_ip (defined in var_test_suite...)
    sleep   40s
    ${ip_ue}=   run keyword if  '${UE_Architecture}'=='PRISMA'    set variable    ${UE_ip}
    ...               ELSE IF   '${UE_Architecture}'=='QCT'       ue_addr.Get UE IP address
    ...                                                            ${ULserver_ip}
    ...                                                            ${ULserver_login}
    ...                                                            ${ULserver_pwd}
    Log           UE ip = ${ip_ue}  console=${DEBUG_MODE_CONSOLE}
    Run Keyword If     '${traffic_direction}'=='DL'
    ...        Start Process TrafficDL    distantip=${ip_ue}   tput=${tput_dl}   duration=${duration}   ueid=${ue_index}
    Run Keyword If     '${traffic_direction}'=='UL'
    ...        Start Process TrafficUL    distantip=${ip_ue}   tput=${tput_ul}   duration=${duration}   ueid=${ue_index}

    # wait the beginning of a new Period to start to vary attenuations (traffic is on going)
    pm_collection.Wait For Next Measurement Period
    ...        meas_period_in_minute=${MeasPeriod}
    ...        additional_waiting_time_sec=3
    ...        gnb=${gNB}

    # Increment source Channels  with step of 1dB up to trigger A2 event
    Increment Channels To Final Values through Steps
    ...    input_channels=${source_channels}
    ...    final_signals=${source_attenuations_a2}
    ...    step=10
    ...    attenuator_id=${source_attenuator_id}
    ...    verify=${False}
    # Sleep    5s

    Set Target Attenuations     signals=${target_attenuations_a2}    verify=${True}

    # Decrement target Channels down to trigger HO event with step of 1dB
    Decrement Channels To Final Values through Steps
    ...    input_channels=${target_channels}
    ...    final_signals=${target_attenuations_ho_trigger}
    ...    step=10
    ...    attenuator_id=${target_attenuator_id}
    ...    verify=${False}
    Sleep   5s

    # wait that period is finished to collect PM files
    pm_collection.Wait For Next Measurement Period
    ...        meas_period_in_minute=${MeasPeriod}
    ...        additional_waiting_time_sec=50
    ...        gnb=${gNB}

	Run Keyword If    '${traffic_direction}'=='DL'    Stop TrafficDL     ueid=${ue_index}
    Run Keyword If    '${traffic_direction}'=='UL'    Stop TrafficUL     ueid=${ue_index}

    Log    Detach UE    console=${DEBUG_MODE_CONSOLE}
    Release UE          ue_index=${ue_index}
    Set Source Channels Max Attenuations    verify=${True}
    Set Target Channels Max Attenuations    verify=${True}
