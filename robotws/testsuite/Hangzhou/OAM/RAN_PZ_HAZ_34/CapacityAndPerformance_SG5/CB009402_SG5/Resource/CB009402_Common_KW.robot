*** Settings ***
Documentation      author: Zhang Xuewen
...                contact: xuewen.zhang@nokia-sbell.com
...                This robot file is for Operability Capacity & Performance

Resource           ../../CB008681_ASIL/Resources/OMKPI_KW_interface.robot
#Resource           ../../../../../resources/RAN_PZ_HAZ_34/robot/bts/common/selenium.robot

Variables           ./OAMKPI_TLDelta.py

*** Variables ***
${elapsed_time_xpath}=  SEPARATOR=
...  //rf-monitoring-rf-scan/div/div/rf-monitoring-progress/div/stopwatch/div
${download_dir}    /home/ute/Downloads/
${driver_alias}    mydriver

*** Keywords ***
Custom_WebEM.Login
    [Documentation]   parameter should be ${True} or ${False}
    [Arguments]      ${virtual_enable}=${TRUE}    ${url}=${WEBUI_URL}    ${version}=SBTS00
    UTE.CleanFirefox
    run keyword if     ${virtual_enable}     selenium_coam.enable_virtual_display
    run keyword and ignore error    selenium_coam.logout
    ${mydriver}   selenium_coam.create_firefox_web_driver   ${download_dir}    ${driver_alias}
    set test variable    ${mydriver}
    selenium_coam.login    url=${url}    username=${WEBUI_USERNAME}    password=${WEBUI_PASSWORD}
    ...    version=${version}   browser=${mydriver}   download_dir=${download_dir}
    selenium_coam.disable_message_box
    selenium_coam.disable_screen_lock
    sleep    15s
    ${res}    selenium_coam.start_up_view_window_exists
    run keyword if    '${res}'=='True'        selenium_coam.close_start_up_view_window
    [Return]  ${mydriver}


TC.RF_Scan_data_collection_duration
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24309
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This TC is created to performed RF Monitoring.
    ...  Flag actRfiTesting will be activated.
    ...  Start RF Monitoring via RF Scan.
    ...  The file is saving in BTSFile.
    ...  Deactivate actRfiTesting  flag
    ...  ******************
    ...  History of changes
    ...  ******************
    Custom_WebEM.Login
    Step1: Change paramter actRfiTesting to be true
    Step2: Start RF Scan Monitoring
    Step3: Change paramter actRfiTesting to be false
    COAM_WebEM.Logout

Step1: Change paramter actRfiTesting to be true
    run keyword and ignore error   COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...   abbr=Activate RFI testing   Abbreviation=actRfiTesting    value=true
    COAM_WebEM.ValidateAndActiveParameters

Step3: Change paramter actRfiTesting to be false
    run keyword and ignore error   COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...   abbr=Activate RFI testing   Abbreviation=actRfiTesting    value=false
    COAM_WebEM.ValidateAndActiveParameters

Step2: Start RF Scan Monitoring
    log to console   ${KPI}
    RF_Scan_data_collection_duration   case_name=RF_scan_duration
    ...   retry_times=${KPI["RF_Scan"]["retry_times"]}
    ...   Composite_Rx_elapsed_time=${KPI['RF_Scan']['Composite_Rx_elapsed_time']}
    ...   Carrier_Rx_elapsed_time=${KPI['RF_Scan']['Carrier_Rx_elapsed_time']}
    ...   fail_loop_max=${KPI['RF_Scan']['fail_loop_max']}

RF_Scan_data_collection_duration
    [Arguments]    ${case_name}=RF_scan_duration
    ...   ${retry_times}=${KPI["RF_Scan"]["retry_times"]}
    ...   ${Composite_Rx_elapsed_time}=${KPI['RF_Scan']['Composite_Rx_elapsed_time']}
    ...   ${Carrier_Rx_elapsed_time}=${KPI['RF_Scan']['Carrier_Rx_elapsed_time']}
    ...   ${fail_loop_max}=${KPI['RF_Scan']['fail_loop_max']}

    FOR    ${radio_item}    IN   @{KPI['RF_Scan']['radio_loops']}
        ${radio}   set variable   ${KPI['RF_Scan']['${radio_item}']['CompositeRx']['radio']}
        ${local_cell}   set variable   ${KPI['RF_Scan']['${radio_item}']['CompositeRx']['local_cell']}
        Check RF_Scan_data_elapsed_time   case_name=RF_scan_Composite_Rx_${radio}
        ...   retry_times=${KPI["RF_Scan"]["retry_times"]}
        ...   target_elapsed_time=${Composite_Rx_elapsed_time}
        ...   fail_loop_max=${KPI['RF_Scan']['fail_loop_max']}
        ...   capture_type=Composite Rx (HBF0)
        ...   radio=${radio}
        ...   antenna=${KPI['RF_Scan']['${radio_item}']['CompositeRx']['antenna']}
        ...   antenna_panel=${KPI['RF_Scan']['${radio_item}']['CompositeRx']['antenna_panel']}
        ...   local_cell=${None}

        ${radio}   set variable   ${KPI['RF_Scan']['${radio_item}']['CarrierRx']['radio']}
        ${local_cell}   set variable   ${KPI['RF_Scan']['${radio_item}']['CarrierRx']['local_cell']}
        Check RF_Scan_data_elapsed_time   case_name=RF_scan_Carrier_Rx_${radio}
        ...   retry_times=${KPI["RF_Scan"]["retry_times"]}
        ...   target_elapsed_time=${Carrier_Rx_elapsed_time}
        ...   fail_loop_max=${KPI['RF_Scan']['fail_loop_max']}
        ...   capture_type=Carrier Rx (FIR9)
        ...   radio=${radio}
        ...   antenna=${KPI['RF_Scan']['${radio_item}']['CarrierRx']['antenna']}
        ...   antenna_panel=${KPI['RF_Scan']['${radio_item}']['CarrierRx']['antenna_panel']}
        ...   local_cell=${local_cell}
    END

Check RF_Scan_data_elapsed_time
    [Arguments]    ${case_name}=RF_scan_duration
    ...   ${retry_times}=${KPI["RF_Scan"]["retry_times"]}
    ...   ${target_elapsed_time}=${60}
    ...   ${fail_loop_max}=${KPI['RF_Scan']['fail_loop_max']}
    ...   ${capture_type}=Composite Rx (HBF0)
    ...   ${radio}=RMOD-1 (AEQE)
    ...   ${antenna}=PHYANT 1
    ...   ${antenna_panel}=PHYANT-1 Full Array
    ...   ${local_cell}=NRCELL-1

    log to console   start check ${capture_type} elapsed time for ${radio} on cell:${local_cell}
    KW.CaseStatusInit    retry_times=${retry_times}
    @{result_list}    create list
    FOR    ${i}    IN RANGE    ${retry_times}
        Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
        ${res}    run keyword and ignore error    selenium_sbts.start_rf_scan   technology=NR TDD   radio=${radio}
        ...   capture_type=${capture_type}   local_cell=${local_cell}
        ...   antenna=${antenna}   antenna_panel=${antenna_panel}
        ${res_status}         set variable if    '${res[0]}'=='FAIL'      FAIL    ${res[0]}
        #${elapsed_time_xpath}=   Evaluate  "".join(${elapsed_time_xpath})
        #${screenshot}=  Evaluate    ${mydriver}.get_screenshot_as_file("rfscan.png")
        Call Method    ${mydriver}    get_screenshot_as_file    rfscan.png
#        ${element}=   Call Method    ${mydriver}    find_element   xpath   ${elapsed_time_xpath}
#        ${elapsed_time_text}=   set variable    ${element.text}
        ${elapsed_time_text}=  set variable   ${mydriver.find_element('xpath','${elapsed_time_xpath}').text}

        ${elapsed_time_tmp}    Split String   ${elapsed_time_text}   ${SPACE}
        ${duration_time_tmp}    set variable if    '${res[0]}'=='FAIL'      1800    ${elapsed_time_tmp}[-1]
        ${duration_time} =	robot.libraries.DateTime.Convert Time	${duration_time_tmp}    exclude_millis=yes
        ${res_status}   set variable if   ${duration_time}<${target_elapsed_time}   PASS   FAIL
        KW.CaseStatusCaluate    duration=${duration_time}    max=${target_elapsed_time}
        log to console     ${case_name} loop:${i+1} duration:${duration_time_tmp} result:${res_status}
#        Run Keyword And Ignore error     Get common info     case_result=${res_status}
#        ...    case_name=${case_name}   loop_number=${i+1}  duration_time=${duration_time_tmp}
        ${file_name}=    Evaluate    '${case_name}'.replace(' ','_')
        Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop    loop=${file_name}_${i+1}
        RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${res_status}    PASS
        ${snapshot_file}    Run Keyword If    '${res_status}'=='FAIL'
        ...    Run Keyword And Ignore error    WEBUI.Collect snapshot

        Append To List    ${result_list}    ${res_status}
        ${fail_num}    Count Values In List    ${result_list}     FAIL
        Exit for loop if    ${fail_num}>=${fail_loop_max}
    END
    KW.CaseStatusFinnal    case_avg=${target_elapsed_time}   max_loop=${retry_times}

TC.remote_power_reset_downtime_KPI11
     [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This TC is created to check downtime of remote power reset
    ...  Flag actGrflShdn will be deactivated.
    ...  ******************
    ...  History of changes
    ...  ******************
    Custom_WebEM.Login
    Step1: Change paramter actGrflShdn to be false
    Step2: Start remote power reset
    run keyword and ignore error    COAM_WebEM.Logout

Step1: Change paramter actGrflShdn to be false
    run keyword and ignore error   COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}
    ...   abbr=Activate graceful cell shutdown   Abbreviation=actGrflShdn    value=true
    COAM_WebEM.ValidateAndActiveParameters

Step2: Start remote power reset
    [Arguments]   ${retry_times}=${KPI['KPI11']['reset_times']}
    ...   ${fail_loop_max}=${KPI['KPI11']['fail_loop_max']}
    ...   ${KPI11_MAX}=${KPI['KPI11']['KPI11_MAX']}
    ...   ${KPI11_AVG}=${KPI['KPI11']['KPI11_AVG']}

    Controllter_RepeatJobWithStatistic   job_name=JOB.RemoteBTSPowerReset
    ...   retry_times=${retry_times}   fail_loop_max=${fail_loop_max}
    ...   KPI_MAX=${KPI11_MAX}    KPI_AVG=${KPI11_AVG}

Controllter_RepeatJobWithStatistic
    [Arguments]
    ...   ${job_name}
    ...   ${retry_times}=${2}
    ...   ${fail_loop_max}=${2}
    ...   ${KPI_MAX}=${0}
    ...   ${KPI_AVG}=${0}
    ...   &{kwargs}
    log to console   Start ${job_name}, repeat time:${retry_times}
    KW.CaseStatusInit    retry_times=${retry_times}
    @{result_list}    create list
    FOR    ${i}    IN RANGE    ${retry_times}
        ${res_status}   Controllter_RunAJob    job_name=${job_name}   loop=${i+1}
        ...   KPI_MAX=${KPI_MAX}   KPI_AVG=${KPI_AVG}   &{kwargs}
        RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${res_status}    PASS
        ${snapshot_file}    Run Keyword If    '${res_status}'=='FAIL'
        ...    Run Keyword And Ignore error    WEBUI.Collect snapshot
        Append To List    ${result_list}    ${res_status}
        ${fail_num}    Count Values In List    ${result_list}     FAIL
        Exit for loop if    ${fail_num}>=${fail_loop_max}
    END
    KW.CaseStatusFinnal    case_avg=${KPI_AVG}   max_loop=${retry_times}

Controllter_RunAJob
    [Arguments]
    ...   ${job_name}
    ...   ${loop}=${0}
    ...   ${fail_loop_max}=${2}
    ...   ${KPI_MAX}=${0}
    ...   ${KPI_AVG}=${0}
    ...   &{kwargs}
    Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
    ${res}    run keyword and ignore error    ${job_name}   KPI_MAX=${KPI_MAX}   &{kwargs}
    ${res_status}   set variable if    '${res[0]}'=='PASS'  ${res[1][0]}   FAIL
    ${duration_time_tmp}    set variable if    '${res[0]}'=='FAIL' or '${res[1][0]}'=='FAIL'      1800    ${res[1][1]}
    KW.CaseStatusCaluate    duration=${duration_time_tmp}    max=${KPI_MAX}
    log to console     ${job_name} loop:${loop} duration:${duration_time_tmp} result:${res_status}
    Run Keyword And Ignore error     Get common info     case_result=${res_status}
    ...    case_name=${job_name}   loop_number=${loop}  duration_time=${duration_time_tmp}
    Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop    loop=${job_name}_${loop}

    RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${res_status}    PASS
    ${snapshot_file}    Run Keyword If    '${res_status}'=='FAIL'
    ...    Run Keyword And Ignore error    WEBUI.Collect snapshot
    [Return]   ${res_status}


JOB.RemoteBTSPowerReset
    [Arguments]   ${KPI_MAX}=${1}
    wait until keyword succeeds    10x   1s    COAM_WebEM.Login   version=${StreamVersion}
    wait until keyword succeeds    10x   10s    selenium_coam.power_reset
    ...   with_snapshot_collection=${False}   with_graceful=${False}     timeout=600
    sleep  5min
    Wait until keyword succeeds    20 min   30 sec   COAM_WebEM.VerifyAllCellsAreOnline
    ${duration_time_tmp}=    SYSLOG.GetDuration    TimeStartString=${KEY_TIMESTART_KPI5}    TimeEndString=${kEY_TIMEEND_KPI5}
    ${reset_status}	   Set Variable If
    ...    1<${duration_time_tmp}<${KPI_MAX} 	    PASS      FAIL
    run keyword and ignore error    COAM_WebEM.Logout
    [Return]    ${reset_status}   ${duration_time_tmp}

TC.capacity_module_power_reset_KPI14
     [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This TC is created to check downtime of remote power reset
    ...  Flag actGrflShdn will be deactivated.
    ...  ******************
    ...  History of changes
    ...  ******************
    Custom_WebEM.Login
    Step1: Change paramter actGrflShdn to be false
    Step2: Start BaseBand Module Power Reset
    run keyword and ignore error    COAM_WebEM.Logout

Step2: Start BaseBand Module Power Reset
    [Arguments]   ${retry_times}=${KPI['KPI14']['reset_times']}
    ...   ${fail_loop_max}=${KPI['KPI14']['fail_loop_max']}
    ...   ${KPI_MAX}=${KPI['KPI14']['KPI_MAX']}
    ...   ${KPI_AVG}=${KPI['KPI14']['KPI_AVG']}
    ...   ${BBMOD_list}=${KPI['KPI14']['BBMOD_list']}

    ${BBMOD_list}   selenium_sbts.get_units_to_be_reset
    Remove BaseBand Module Without RMOD From List   ${BBMOD_list}
    log to console   After Remove Idle BBMOD: ${BBMOD_list}
    FOR    ${BBMOD}    IN    @{BBMOD_list}
        Controllter_RepeatJobWithStatistic   job_name=JOB.BaseBandModulePowerReset
        ...   retry_times=${retry_times}   fail_loop_max=${fail_loop_max}
        ...   KPI_MAX=${KPI_MAX}    KPI_AVG=${KPI_AVG}   baseband_unit=${BBMOD}
    END

Remove BaseBand Module Without RMOD From List
    [Arguments]   ${BBMOD_list}
     FOR    ${BBMOD}    IN    @{BBMOD_list}
         @{BBMOD_split}   Split String   ${BBMOD}   (
         ${stripped}=   Strip String   ${BBMOD_split}[0]   mode=right
         &{hw_info}    selenium_coam.get_hw_info   ${stripped}
         ${status}    set variable   ${hw_info['Status']['Usage state']}
         Run Keyword If  '${status}' != 'Active'   remove values from list  ${BBMOD_list}  ${BBMOD}
     END
     [Return]  ${BBMOD_list}


JOB.BaseBandModulePowerReset
    [Arguments]   ${KPI_MAX}=${1}   ${baseband_unit}=${BBMOD-1 / BBMOD_R-4 (ABIO)}
    log to console  BaseBand Module Power Reset: ${baseband_unit}
    wait until keyword succeeds    10x   1s    COAM_WebEM.Login   version=${StreamVersion}
    wait until keyword succeeds    10x   10s    selenium_coam.baseband_power_reset
    ...   baseband_unit=${baseband_unit}   with_graceful=${False}     timeout=600
    sleep  5min
    Wait until keyword succeeds    20 min   30 sec   COAM_WebEM.VerifyAllCellsAreOnline
    ${duration_time_tmp}=    SYSLOG.GetDuration    TimeStartString=${KEY_TIMESTART_KPI5}    TimeEndString=${kEY_TIMEEND_KPI5}
    ${reset_status}	   Set Variable If
    ...    1<${duration_time_tmp}<${KPI_MAX} 	    PASS      FAIL
    run keyword and ignore error    COAM_WebEM.Logout
    [Return]    ${reset_status}   ${duration_time_tmp}

TC.Cell_switching_duration
         [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This TC is created to check cell switching duration for 5GC000431
    ...  Flag actGrflShdn will be deactivated.
    ...  ******************
    ...  History of changes
    ...  ******************
    Loop Check Cell Switching Duration

Loop Check Cell Switching Duration
    [Arguments]   ${retry_times}=${KPI['CELL_Switch_Duration']['retry_times']}
    ...   ${fail_loop_max}=${KPI['CELL_Switch_Duration']['fail_loop_max']}
    ...   ${KPI_MAX}=${KPI['CELL_Switch_Duration']['off']}
    ...   ${KPI_AVG}=${KPI['CELL_Switch_Duration']['on']}
    wait until keyword succeeds    10x   1s    COAM_WebEM.Login   version=${StreamVersion}
    ${CellNum}    selenium_coam.get_number_of_cells
    FOR    ${cell_id}    IN RANGE    1   ${CellNum+1}
        Repeat Check Cell Switching Duration   retry_times=${retry_times}   cell_id=${cell_id}
        ...   fail_loop_max=${fail_loop_max}
    END
    [Teardown]   run keyword and ignore error   COAM_WebEM.Logout


Repeat Check Cell Switching Duration
    [Arguments]   ${retry_times}=${KPI['CELL_Switch_Duration']['retry_times']}
    ...   ${cell_id}=${1}
    ...   ${fail_loop_max}=${KPI['CELL_Switch_Duration']['fail_loop_max']}
    KW.CaseStatusInit    retry_times=${retry_times}
    @{result_list}    create list
    FOR    ${i}    IN RANGE   ${retry_times}
        ${res_status}   Controllter_RunAJob    job_name=JOB.CheckCellSwitchOffDuration
        ...   loop=${i+1}   fail_loop_max=${fail_loop_max}
        ...   KPI_MAX=${KPI['CELL_Switch_Duration']['off']}
        ...   KPI_AVG=$${KPI['CELL_Switch_Duration']['off']}   cell_id=${cell_id}
        Append To List    ${result_list}    ${res_status}

        ${res_status}   Controllter_RunAJob    job_name=JOB.CheckCellSwitchOnDuration
        ...   loop=${i+1}   fail_loop_max=${fail_loop_max}
        ...   KPI_MAX=${KPI['CELL_Switch_Duration']['on']}
        ...   KPI_AVG=${KPI['CELL_Switch_Duration']['on']}   cell_id=${cell_id}
        Append To List    ${result_list}    ${res_status}

        ${fail_num}    Count Values In List    ${result_list}     FAIL
        Exit for loop if    ${fail_num}>=${fail_loop_max}
    END
    KW.CaseStatusFinnal    case_avg=${KPI['CELL_Switch_Duration']['off']}   max_loop=${retry_times}


JOB.CheckCellSwitchOffDuration
    [Arguments]   ${KPI_MAX}=${1}   ${cell_id}=${1}
    log to console  Check Cell Switch Off Duration: NRCELL-${cell_id}
    #wait until keyword succeeds    10x   1s    COAM_WebEM.Login   version=${StreamVersion}
    Step1: Check Cell${cell_id} Energy saving state to be notEnergySaving
    Step2: Enable Cell${cell_id} parameters for 5GC000431 cell switch off
    Wait until keyword succeeds    10 min   20 sec   Step3: Check Cell${cell_id} Energy saving state to be energySaving
    log to console   Step4: Check cell switch off duration
    ${duration_time_tmp}=    SYSLOG.GetDuration    TimeStartString=${KEY_TIMESTART_CellSwitchingOff}
    ...    TimeEndString=${kEY_TIMEEND_CellSwitchingOff}
    ${res_status}	   Set Variable If   0<${duration_time_tmp}<${KPI_MAX} 	    PASS      FAIL
    #run keyword and ignore error    COAM_WebEM.Logout
    [Return]    ${res_status}   ${duration_time_tmp}

JOB.CheckCellSwitchOnDuration
    [Arguments]   ${KPI_MAX}=${1}    ${cell_id}=${1}
    log to console  Check Cell Switch On Duration: NRCELL-${cell_id}
    wait until keyword succeeds    10x   1s    COAM_WebEM.Login   version=${StreamVersion}
    Step5: Disable parameters for 5GC000431 cell switch off
    ${res_status_Tmp}   Wait until keyword succeeds    5 min   10 sec   Step6: Check Cell${cell_id} Energy saving state to be notEnergySaving
    log to console  Step7: Check cell switch on duration
#    ${res_status_Tmp}          Run Keyword And Return Status
#    ...  RUN KEYWORD AND CONTINUE ON FAILURE    COAM_WebEM.VerifyAllCellsAreOnline
    ${duration_time_tmp}=    SYSLOG.GetDuration    TimeStartString=${KEY_TIMESTART_CellSwitchingOn}
    ...    TimeEndString=${kEY_TIMEEND_CellSwitchingOn}
    ${res_status}	   Set Variable If
    ...    "${res_status_Tmp}"=="True" and 0<${duration_time_tmp}<${KPI_MAX} 	    PASS      FAIL
    #run keyword and ignore error    COAM_WebEM.Logout
    [Return]    ${res_status}   ${duration_time_tmp}

Step${index}: Check Cell${cell_id} ${parameter} to be ${value}
    Log  \nStep${index}: Check NRCELL-${cell_id} ${parameter} to be ${value}  console=true
    ${energyState}   COAM_WebEM.GetParameterValue   distName=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${cell_id}    abbr=Energy saving state
    ${result}   Evaluate   '${value}'=='${energyState}'
    should be true   ${result}
    [Return]  ${result}

Step2: Enable Cell${cell_id} parameters for 5GC000431 cell switch off
    run keyword and ignore error   COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}
    ...   abbr=Activate NR load-based power saving   Abbreviation=actNrLBPowerSaving    value=false
    COAM_WebEM.ValidateAndActiveParameters
    Run Keyword And Ignore Error    Online Delete ALL NRPGRP
    #${CELL_IDs}   create list   ${cell_id}
    Online Add NRPGRP with Cell ID    ${cell_id}
    run keyword and ignore error   COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}
    ...   abbr=Activate NR load-based power saving   Abbreviation=actNrLBPowerSaving    value=true
    COAM_WebEM.ValidateAndActiveParameters

Step${index}: Disable parameters for 5GC000431 cell switch off
    run keyword and ignore error   COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}
    ...   abbr=Activate NR load-based power saving   Abbreviation=actNrLBPowerSaving    value=false
    COAM_WebEM.ValidateAndActiveParameters


Online Add NRPGRP with Cell ID
    [Arguments]  @{CELL_IDs}  ${NRPGRP_ID}=${1}  ${lbpsSOMethod}=cell switch off
    log to console  \n Add NRPGRP-${NRPGRP_ID}
    selenium_coam.add_object    object_name=${MRBTS_ID}/${NRBTS_ID}
    ...    object_class_name=NRPGRP    is_load_default_values=${True}    id_value=${NRPGRP_ID}    timeout=15
    #set basic
    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRPGRP-${NRPGRP_ID}
    ...    filter_param=Load-based power saving last cell switch off enabled    abbr=lbpsLastCellSOEnabled
    ...    new_value=true
    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRPGRP-${NRPGRP_ID}
    ...    filter_param=Load-based power saving maximum load    abbr=lbpsMaxLoad    new_value=${15}
    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRPGRP-${NRPGRP_ID}
    ...    filter_param=Load-based power saving minimum load    abbr=lbpsMinLoad    new_value=${4}
    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRPGRP-${NRPGRP_ID}
    ...    filter_param=Load-based PS monitoring window for cell switch off    abbr=lbpsMonWinForCellSOff
    ...    new_value=${60}
    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRPGRP-${NRPGRP_ID}
    ...    filter_param=Load-based PS monitoring window for cell switch on    abbr=lbpsMonWinForCellSOn
    ...    new_value=${60}
    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRPGRP-${NRPGRP_ID}
    ...    filter_param=Load-based PS monitoring window for cell switch off    abbr=lbpsMonWinForCellSOff
    ...    new_value=${60}
    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRPGRP-${NRPGRP_ID}
    ...    filter_param=Load-based PS monitoring window for cell switch on    abbr=lbpsMonWinForCellSOn
    ...    new_value=${60}
    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRPGRP-${NRPGRP_ID}
        ...    filter_param=Load-based power saving switch off method    abbr=lbpsSOMethod
        ...    new_value=${lbpsSOMethod}
    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRPGRP-${NRPGRP_ID}
    ...    filter_param=Load-based power saving reduced TX switch off time    abbr=lbpsRTXSOffTime
    ...    new_value=${30}
    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRPGRP-${NRPGRP_ID}
    ...    filter_param=Load-based power saving reduced TX switch on time    abbr=lbpsRTXSOnTime
    ...    new_value=${30}
    #set lbpsCellList
    Run Keyword And Ignore Error    selenium_coam.remove_element    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRPGRP-${NRPGRP_ID}
    ...    filter_param=Load-based power saving cell period list    abbr=lbpsCellPeriodList
    ${cell_num}   Get Length   ${CELL_IDs}
    FOR    ${index}    IN RANGE    0    ${cell_num}
        ${lbpsCellSOOrder}   set variable if    '${index}'=='0'    ${60}    ${80}
        ${nrCellId}   set variable   ${CELL_IDs}[${index}]
        run keyword if    '${index}'!='0'    selenium_coam.add_element
        ...    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRPGRP-${NRPGRP_ID}
        ...    filter_param=Load-based power saving cell list    abbr=lbpsCellList    timeout=15
        selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRPGRP-${NRPGRP_ID}
        ...    filter_param=Load-based power saving cell switch off order    abbr=lbpsCellSOOrder
        ...    new_value=${lbpsCellSOOrder}    node_index=${index}
        selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRPGRP-${NRPGRP_ID}
        ...    filter_param=NR cell configuration identifier    abbr=nrCellId
        ...    new_value=${nrCellId}    node_index=${index}
        Run Keyword if   '${StreamVersion}'!='SBTS23R1' and '${StreamVersion}'!='SBTS23R2'
        ...    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRPGRP-${NRPGRP_ID}
        ...    filter_param=Use load-based power saving extended configurations    abbr=lbpsUseExtConfig
        ...    new_value=false    node_index=${index}
    END
    #set lbpsPeriodList
    FOR    ${index}    IN RANGE    0    7
        ${lbpsDayOfWeek}   set variable if
        ...     ${index}==0        Mon
        ...     ${index}==1        Tue
        ...     ${index}==2        Wed
        ...     ${index}==3        Thu
        ...     ${index}==4        Fri
        ...     ${index}==5        Sat
        ...     Sun
        run keyword if    '${index}'!='0'    selenium_coam.add_element
        ...    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRPGRP-${NRPGRP_ID}
        ...    filter_param=Load-based power saving period list    abbr=lbpsPeriodList    timeout=15
        selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRPGRP-${NRPGRP_ID}
        ...    filter_param=Load-based power saving day of week    abbr=lbpsDayOfWeek    new_value=${lbpsDayOfWeek}
        ...    node_index=${index}
        selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRPGRP-${NRPGRP_ID}
        ...    filter_param=Load-based power saving duration    abbr=lbpsDuration    new_value=${1440}
        ...    node_index=${index}
        selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRPGRP-${NRPGRP_ID}
        ...    filter_param=Load-based power saving start time hour    abbr=lbpsStartTimeHour    new_value=${1}
        ...    node_index=${index}
        selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRPGRP-${NRPGRP_ID}
        ...    filter_param=Load-based power saving start time minute    abbr=lbpsStartTimeMinute    new_value=${0}
        ...    node_index=${index}
        selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRPGRP-${NRPGRP_ID}
        ...    filter_param=Load-Based Power Saving Suspended    abbr=lbpsSuspended    new_value=notSuspended
        ...    node_index=${index}
    END
    selenium_coam.validate_plan
    selenium_coam.activate_plan

Online Delete ALL NRPGRP
    log to console  \n Online Delete ALL NRPGRP
    ${object_list}    selenium_coam.get_object_name_list    object_name=NRPGRP
    FOR  ${object_name}  IN  @{object_list}
        selenium_coam.remove_object    object_name=${object_name}    timeout=15
    END
    ${object_num}   Get Length   ${object_list}
    Run Keyword If  ${object_num}!=${0}    selenium_coam.validate_plan
    Run Keyword If  ${object_num}!=${0}    selenium_coam.activate_plan

TC.TRX_switching_duration
         [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This TC is created to check TRX switching duration for 5GC000431
    ...  Flag actNrLBmMimoRTXPowerSaving will be activated.
    ...  ******************
    ...  History of changes
    ...  ******************
    Loop Check TRX Switching Duration

Loop Check TRX Switching Duration
    [Arguments]   ${retry_times}=${KPI['TRX_Switch_Duration']['retry_times']}
    ...   ${fail_loop_max}=${KPI['TRX_Switch_Duration']['fail_loop_max']}
    ...   ${KPI_switch_off}=${KPI['TRX_Switch_Duration']['off']}
    ...   ${KPI_switch_on}=${KPI['TRX_Switch_Duration']['on']}
    wait until keyword succeeds    10x   1s    COAM_WebEM.Login   version=${StreamVersion}
    ${CellNum}    selenium_coam.get_number_of_cells
    FOR    ${cell_id}    IN RANGE    1   ${CellNum+1}
        Repeat Check TRX Switching Duration   retry_times=${retry_times}   cell_id=${cell_id}
        ...   fail_loop_max=${fail_loop_max}   KPI_switch_off=${KPI_switch_off}   KPI_switch_on=${KPI_switch_on}
    END
    [Teardown]   run keyword and ignore error   COAM_WebEM.Logout

Repeat Check TRX Switching Duration
    [Arguments]   ${retry_times}=${1}
    ...   ${cell_id}=${1}
    ...   ${fail_loop_max}=${1}
    ...   ${KPI_switch_off}=${90}
    ...   ${KPI_switch_on}=${30}
    KW.CaseStatusInit    retry_times=${retry_times}
    @{result_list}    create list
    FOR    ${i}    IN RANGE   ${retry_times}
        ${res_status}   Controllter_RunAJob    job_name=JOB.CheckTRXSwitchOffDuration
        ...   loop=${i+1}   fail_loop_max=${fail_loop_max}
        ...   KPI_MAX=${KPI_switch_off}   KPI_AVG=${KPI_switch_off}   cell_id=${cell_id}
        Append To List    ${result_list}    ${res_status}

        ${res_status}   Controllter_RunAJob    job_name=JOB.CheckTRXSwitchOnDuration
        ...   loop=${i+1}   fail_loop_max=${fail_loop_max}
        ...   KPI_MAX=${KPI_switch_on}
        ...   KPI_AVG=${KPI_switch_on}   cell_id=${cell_id}
        Append To List    ${result_list}    ${res_status}

        ${fail_num}    Count Values In List    ${result_list}     FAIL
        Exit for loop if    ${fail_num}>=${fail_loop_max}
    END
    KW.CaseStatusFinnal    case_avg=${KPI_switch_off}   max_loop=${retry_times}


JOB.CheckTRXSwitchOffDuration
    [Arguments]   ${KPI_MAX}=${1}   ${cell_id}=${1}
    log to console  Check TRX Switch Off Duration: NRCELL-${cell_id}
    wait until keyword succeeds    10x   1s    COAM_WebEM.Login    version=${StreamVersion}
    Step1: Check Cell${cell_id} Energy saving state to be notEnergySaving
    Step2: Enable Cell${cell_id} parameters for 5GC000431 TRX switch off
    Wait until keyword succeeds    10 min   20 sec   Step3: Check Cell${cell_id} Energy saving state to be reducedEnergySaving
    log to console   Step4: Check TRX switch off duration
    ${duration_time_tmp}=    SYSLOG.GetDuration    TimeStartString=${KEY_TIMESTART_TRXSwitchingOff}
    ...    TimeEndString=${kEY_TIMEEND_TRXSwitchingOff}
    ${res_status}	   Set Variable If   0<${duration_time_tmp}<${KPI_MAX} 	    PASS      FAIL
    run keyword and ignore error    COAM_WebEM.Logout
    [Return]    ${res_status}   ${duration_time_tmp}

JOB.CheckTRXSwitchOnDuration
    [Arguments]   ${KPI_MAX}=${1}    ${cell_id}=${1}
    log to console  Check TRX Switch On Duration: NRCELL-${cell_id}
    wait until keyword succeeds    10x   1s    COAM_WebEM.Login   version=${StreamVersion}
    Step5: Disable parameters for 5GC000431 TRX switch off
    Wait until keyword succeeds    10 min   20 sec   Step6: Check Cell${cell_id} Energy saving state to be notEnergySaving
    log to console  Step7: Check TRX switch off duration
    ${res_status_Tmp}          Run Keyword And Return Status
    ...  RUN KEYWORD AND CONTINUE ON FAILURE    COAM_WebEM.VerifyAllCellsAreOnline
    ${duration_time_tmp}=    SYSLOG.GetDuration    TimeStartString=${KEY_TIMESTART_TRXSwitchingOn}
    ...    TimeEndString=${kEY_TIMEEND_TRXSwitchingOn}
    ${res_status}	   Set Variable If
    ...    "${res_status_Tmp}"=="True" and 0<${duration_time_tmp}<${KPI_MAX} 	    PASS      FAIL
    run keyword and ignore error    COAM_WebEM.Logout
    [Return]    ${res_status}   ${duration_time_tmp}

Step2: Enable Cell${cell_id} parameters for 5GC000431 TRX switch off
    run keyword and ignore error   COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}
    ...   abbr=Activate NR load-based mMIMO TX power saving   Abbreviation=actNrLBmMimoRTXPowerSaving    value=false
    COAM_WebEM.ValidateAndActiveParameters
    Run Keyword And Ignore Error    Online Delete ALL NRPGRP
    #@{CELL_IDs}   create list   ${cell_id}
    Online Add NRPGRP with Cell ID     ${cell_id}   lbpsSOMethod=TX switch off
    run keyword and ignore error   COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}
    ...   abbr=Activate NR load-based mMIMO TX power saving   Abbreviation=actNrLBmMimoRTXPowerSaving    value=true
    COAM_WebEM.ValidateAndActiveParameters

Step${index}: Disable parameters for 5GC000431 TRX switch off
    run keyword and ignore error   COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}
    ...   abbr=Activate NR load-based mMIMO TX power saving   Abbreviation=actNrLBmMimoRTXPowerSaving    value=false
    COAM_WebEM.ValidateAndActiveParameters

TC.Time_duration_wake_up_radio_module_from_Deep_sleep_mode
         [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This TC is created to check RU wake up duration from deep sleep mode
    ...  Flag energySavingMode will be activated.
    ...  ******************
    ...  History of changes
    ...  ******************
    Loop Check RU Wake UP Duration From Deep Sleep Mode

Loop Check RU Wake UP Duration From Deep Sleep Mode
    [Arguments]   ${retry_times}=${KPI['DeepSleep_Wakeup_Duration']['retry_times']}
    ...   ${fail_loop_max}=${KPI['DeepSleep_Wakeup_Duration']['fail_loop_max']}
    ...   ${KPI_MAX}=${KPI['DeepSleep_Wakeup_Duration']['KPI_MAX']}
    ...   ${KPI_AVG}=${KPI['DeepSleep_Wakeup_Duration']['KPI_AVG']}
    wait until keyword succeeds    10x   1s    COAM_WebEM.Login   version=${StreamVersion}
    @{RMODs}    selenium_coam.get_object_name_list   object_name=RMOD-
    FOR    ${RMOD}    IN   @{RMODs}
        Controllter_RepeatJobWithStatistic   job_name=JOB.CheckDeepSleepWakeUpDuration
        ...   retry_times=${retry_times}   fail_loop_max=${fail_loop_max}
        ...   KPI_MAX=${KPI_MAX}  KPI_AVG=${KPI_AVG}   RMOD=${RMOD}
    END
    [Teardown]   run keyword and ignore error   COAM_WebEM.Logout

JOB.CheckDeepSleepWakeUpDuration
    [Arguments]   ${KPI_MAX}=${1}   ${RMOD}=${RMOD-1}
    log to console  Check Deep Sleep Wake Up Duration: ${RMOD}
    wait until keyword succeeds    10x   1s    COAM_WebEM.Login   version=${StreamVersion}
    Step1: Change ${RMOD} parameters to DEEPSLEEP for deep sleep mode
    Step2: Block CelLs in ${RMOD} and wait 5min
    Wait until keyword succeeds    10 min   30 sec   Step3: Check ${RMOD} Power State to be SLEEP
    Step4: Unblock CelLs in ${RMOD} and wait 3min
    Wait until keyword succeeds    10 min   30 sec   Step5: Check ${RMOD} Power State to be AWAKE
    Wait until keyword succeeds    10 min   30 sec   COAM_WebEM.VerifyAllCellsAreOnline
    log to console   Step6: Check Deep Sleep Wake Up duration
    ${duration_time_tmp}=    SYSLOG.GetDuration    TimeStartString=${KEY_TIMESTART_DeepSleepWakeUp}
    ...    TimeEndString=${KEY_TIMEEND_DeepSleepWakeUp}   option=-E
    ${res_status}	   Set Variable If   1<${duration_time_tmp}<${KPI_MAX} 	    PASS      FAIL
    Step7: Change ${RMOD} parameters to NORMAL for deep sleep mode
    run keyword and ignore error    COAM_WebEM.Logout
    [Return]    ${res_status}   ${duration_time_tmp}

Step${index}: Change ${RMOD} parameters to ${value} for deep sleep mode
    @{ru_index}    Split String   ${RMOD}   -
    ${ru_index}    set variable   ${ru_index}[1]
    wait until keyword succeeds    10x   1s    COAM_WebEM.Login   version=${StreamVersion}
    log to console  Step${index}: Change ${RMOD} parameters to ${value} for deep sleep mode
    run keyword and ignore error   COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/EQM-1/APEQM-1/${RMOD}
    ...   abbr=Energy Saving Mode Activation   Abbreviation=energySavingMode    value=${value}
    run keyword and ignore error   COAM_WebEM.ValidateAndActiveParameters

Step${index}: Check ${RMOD} Power State to be ${value}
    @{ru_index}    Split String   ${RMOD}   -
    ${ru_index}    set variable   ${ru_index}[1]
    Log  \nStep${index}: Check ${RMOD} Power State to be ${value}  console=true
    ${state}   COAM_WebEM.GetParameterValue   distName=${MRBTS_ID}/EQM_R-1/APEQM_R-1/RMOD_R-${ru_index}
    ...    abbr=Power state of RU
    should be true   '${value}'=='${state}'

Step${index}: Block CelLs in ${RMOD} and wait ${wait_time}
    log to console  Step${index}: Block CelLs in ${RMOD} and wait ${wait_time}
    @{ru_index}    Split String   ${RMOD}   -
    ${ru_info}    selenium_coam.get_ru_info   ru_index=${ru_index}[1]
    ${cell_list}    evaluate    ${ru_info}[Cell list].keys()
    FOR  ${cell}  IN   @{cell_list}
        @{cell_id}    Split String   ${cell}   -
        ${cell_id}   Split String   ${cell_id}[1]   ${SPACE}
        selenium_coam.block_cell   cell_idx=${cell_id}[0]
    END
    sleep   ${wait_time}

Step${index}: Unblock CelLs in ${RMOD} and wait ${wait_time}
    log to console  Step${index}: Unblock CelLs in ${RMOD} and wait ${wait_time}
    @{ru_index}    Split String   ${RMOD}   -
    ${ru_info}    selenium_coam.get_ru_info   ru_index=${ru_index}[1]
    ${cell_list}    evaluate    ${ru_info}[Cell list].keys()
    FOR  ${cell}  IN   @{cell_list}
        @{cell_id}    Split String   ${cell}   -
        ${cell_id}   Split String   ${cell_id}[1]   ${SPACE}
        selenium_coam.unblock_cell   cell_idx=${cell_id}[0]
    END
    sleep   ${wait_time}
