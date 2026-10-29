*** Settings ***
Documentation
...    author: Qingqing Wang
...    contact: qingqing.1.wang@nokia-sbell.com
...    squad group: SG_08
...    feature : 5GC000433-A

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    ../../common/coam_resource.robot

*** Variables ***

*** Keywords ***
Online Delta Commission
    [Arguments]    ${dist_name}    ${filter_param}    ${target_value}
    ${current_value}    selenium_coam.get_parameter_value    dist_name=${dist_name}
	...    filter_param=${filter_param}
    run keyword if  not '${current_value}'=='${target_value}'
    ...    selenium_coam.set_parameter_value    dist_name=${dist_name}    filter_param=${filter_param}
    ...    new_value=${target_value}

Modify Parameters for Energy Consumption Measurement
    [Arguments]    ${actPowerMeter}    ${mtBtsEnergyMonitoring}
    ...    ${mtSBTSRfModuleInputVoltageMeasurementInt}    ${mtSBTSSmEnergyMonitoring}
	wait until keyword succeeds    2min    20s    WEBUI Login
    Online Delta Commission  dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Power meter enabled    target_value=${actPowerMeter}
    Online Delta Commission  dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/PMMNL-1
    ...    filter_param=BTS energy monitoring    target_value=${mtBtsEnergyMonitoring}
	${release}    Get program version based on gNB active version
	${flitervalue}=   Run Keyword If   "${release}"=="21A"
    ...     Set Variable       SBTS RF module input voltage measurement interval
	...     ELSE    Set Variable     SBTS RFM energy monitoring
    Online Delta Commission  dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/PMMNL-1
    ...    filter_param=${flitervalue}
	...    target_value=${mtSBTSRfModuleInputVoltageMeasurementInt}
    Online Delta Commission  dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/PMMNL-1
    ...    filter_param=SBTS SM energy monitoring    target_value=${mtSBTSSmEnergyMonitoring}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    COAM Wait for gnb ready and cell setup    timeout=15min    gnb_type='NSA'
	selenium logout and close browser

Get wait value minutes
    [Arguments]    ${interval}
    Connect to Common Unit Master
    ssh.force_reconnect    connection=ASIK Master
    ${interval_seconds}    Get Interval Seconds    ${interval}
    ${interval_minutes}    evaluate    ${interval_seconds}/60
    ${origin_time}    Get time from GNB
    ${origin_time}    convert_date    ${origin_time}   datetime
    ${minutes}    set variable    ${origin_time.minute}
    ${wait_time}    evaluate    ${interval_minutes}-${minutes}%${interval_minutes}
    [Return]    ${wait_time}

Set Power meter
    [Arguments]  ${power_meter}
    log to console   \nChange Power meter to ${power_meter}
    selenium login and disable screen lock
    Online Delta Commission    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Power meter enabled    target_value=${power_meter}
	selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    COAM Wait for gnb ready and cell setup    timeout=15min    gnb_type='NSA'
    selenium logout and close browser

Check and Get BTS Counter Length M40002C
    ${content_2C0}    Get PM Counter content via Webem    counter_id=M40002C0
    ${len_2C0}    get length  ${content_2C0}
    ${content_2C1}    Get PM Counter content via Webem    counter_id=M40002C1
    ${len_2C1}    get length  ${content_2C1}
    Should be True    (${len_2C0}-1) <= ${len_2C1} <= ${len_2C0}
    ${content_2C2}    Get PM Counter content via Webem    counter_id=M40002C2
    ${len_2C2}    get length  ${content_2C2}
    Should be True    ${len_2C2} == ${len_2C0}
    [Return]      ${len_2C0}

Check BTS Counter M40002C
    [Arguments]    ${interval}
	Connect to Common Unit Master
	selenium login and disable screen lock
	${value_2C0}    Get PM Counter via Webem for 5GC000433-H-K    counter_id=M40002C0    interval=${interval}
	Should be True    ${value_2C0} > 0
    ${value_2C1}    Get PM Counter via Webem for 5GC000433-H-K    counter_id=M40002C1    interval=${interval}
    Should be True    ${value_2C1} > 0
	${value_2C2}    Get PM Counter via Webem for 5GC000433-H-K    counter_id=M40002C2    interval=${interval}
	Should be True    ${value_2C2} > 0
    selenium logout and close browser

Check and Get BTS Counter Length M40004C
    ${content_4C0}    Get PM Counter content via Webem    counter_id=M40004C0
    ${len_4C0}    get length  ${content_4C0}
    ${content_4C1}    Get PM Counter content via Webem    counter_id=M40004C1
    ${len_4C1}    get length  ${content_4C1}
    Should be True    ${len_4C1} == ${len_4C0}
    ${content_4C2}    Get PM Counter content via Webem    counter_id=M40004C2
    ${len_4C2}    get length  ${content_4C2}
    Should be True    ${len_4C2} == ${len_4C1}
    ${content_4C3}    Get PM Counter content via Webem    counter_id=M40004C3
    ${len_4C3}    get length  ${content_4C3}
    Should be True    ${len_4C3} == ${len_4C2}
    ${content_4C4}    Get PM Counter content via Webem    counter_id=M40004C4
    ${len_4C4}    get length  ${content_4C4}
    Should be True    ${len_4C4} == ${len_4C3}
    ${content_4C5}    Get PM Counter content via Webem    counter_id=M40004C5
    ${len_4C5}    get length  ${content_4C5}
    Should be True    ${len_4C5} == ${len_4C4}
    [Return]      ${len_4C0}

Check BTS Counter M40004C
    [Arguments]    ${interval}
	Connect to Common Unit Master
	selenium login and disable screen lock
	${value_4C0}    Get PM Counter via Webem for 5GC000433-H-K    counter_id=M40004C0    interval=${interval}
	Should be True    ${value_4C0} > 0
    ${value_4C1}    Get PM Counter via Webem for 5GC000433-H-K    counter_id=M40004C1    interval=${interval}
    Should be True    ${value_4C1} > 0
	${value_4C2}    Get PM Counter via Webem for 5GC000433-H-K    counter_id=M40004C2    interval=${interval}
	Should be True    ${value_4C2} > 0
	${value_4C3}    Get PM Counter via Webem for 5GC000433-H-K    counter_id=M40004C3    interval=${interval}
	Should be True    ${value_4C3} > 0
	${value_4C4}    Get PM Counter via Webem for 5GC000433-H-K    counter_id=M40004C4    interval=${interval}
	Should be True    ${value_4C4} > 0
	${value_4C5}    Get PM Counter via Webem for 5GC000433-H-K    counter_id=M40004C5    interval=${interval}
	Should be True    ${value_4C5} > 0
    selenium logout and close browser

Check and Get BTS Counter Length M40003C
    ${content_3C0}    Get PM Counter content via Webem    counter_id=M40003C0
    ${len_3C0}    get length  ${content_3C0}
    ${content_3C1}    Get PM Counter content via Webem    counter_id=M40003C1
    ${len_3C1}    get length  ${content_3C1}
    Should be True    ${len_3C1} == ${len_3C0}
    ${content_3C2}    Get PM Counter content via Webem    counter_id=M40003C2
    ${len_3C2}    get length  ${content_3C2}
    Should be True    ${len_3C2} == ${len_3C1}
    ${content_3C3}    Get PM Counter content via Webem    counter_id=M40003C3
    ${len_3C3}    get length  ${content_3C3}
    Should be True    ${len_3C3} == ${len_3C2}
    ${content_3C4}    Get PM Counter content via Webem    counter_id=M40003C4
    ${len_3C4}    get length  ${content_3C4}
    Should be True    ${len_3C4} == ${len_3C3}
    ${content_3C5}    Get PM Counter content via Webem    counter_id=M40003C5
    ${len_3C5}    get length  ${content_3C5}
    Should be True    ${len_3C5} == ${len_3C4}
    [Return]      ${len_3C0}

Check BTS Counter M40003C
    [Arguments]    ${interval}
	Connect to Common Unit Master
	selenium login and disable screen lock
	${value_3C0}    Get PM Counter via Webem for 5GC000433-H-K    counter_id=M40003C0    interval=${interval}
	Should be True    ${value_3C0} > 0
    ${value_3C1}    Get PM Counter via Webem for 5GC000433-H-K    counter_id=M40003C1    interval=${interval}
    Should be True    ${value_3C1} > 0
	${value_3C2}    Get PM Counter via Webem for 5GC000433-H-K    counter_id=M40003C2    interval=${interval}
	Should be True    ${value_3C2} > 0
	${value_3C3}    Get PM Counter via Webem for 5GC000433-H-K    counter_id=M40003C3    interval=${interval}
	Should be True    ${value_3C3} > 0
	${value_3C4}    Get PM Counter via Webem for 5GC000433-H-K    counter_id=M40003C4    interval=${interval}
	Should be True    ${value_3C4} > 0
	${value_3C5}    Get PM Counter via Webem for 5GC000433-H-K    counter_id=M40003C5    interval=${interval}
	Should be True    ${value_3C5} > 0
    selenium logout and close browser

Disable Energy Consumption Measurement Collectection
    [Arguments]  ${interval}
    log to console  \nDisable Energy Consumption Measurement Collectection
    Set Power meter    power_meter=false
    selenium login and disable screen lock
    ${orig_len_2C}    Check and Get BTS Counter Length M40002C
	${orig_len_3C}    Check and Get BTS Counter Length M40003C
    ${orig_len_4C}    Check and Get BTS Counter Length M40004C
    ${wait_time}    Get wait value minutes    ${interval}
    selenium logout and close browser
    sleep    ${wait_time}min
    sleep    30
    FOR  ${i}  IN RANGE  ${2}
        selenium login and disable screen lock
        ${new_len_2C}    Check and Get BTS Counter Length M40002C
        Should be True    ${new_len_2C} == ${orig_len_2C}
		${new_len_3C}    Check and Get BTS Counter Length M40003C
        Should be True    ${new_len_3C} == ${orig_len_3C}
        ${new_len_4C}    Check and Get BTS Counter Length M40004C
        Should be True    ${new_len_4C} == ${orig_len_4C}
        selenium logout and close browser
        exit for loop if   ${i} == 1
        sleep    ${interval}
	END

Wait for New Interval BTS counters Generate
    [Arguments]  ${interval}
    log to console  \nWait for New Interval BTS counters Generate
    ${wait_time}    Get wait value minutes    ${interval}
    sleep    ${wait_time}min
    sleep    30
    selenium login and disable screen lock
    ${orig_len_2C}    Check and Get BTS Counter Length M40002C
	${orig_len_3C}    Check and Get BTS Counter Length M40003C
    ${orig_len_4C}    Check and Get BTS Counter Length M40004C
    selenium logout and close browser
    sleep    ${interval}
    selenium login and disable screen lock
    ${new_len_2C}    Check and Get BTS Counter Length M40002C
    Should be True    ${new_len_2C} > ${orig_len_2C}
	${new_len_3C}    Check and Get BTS Counter Length M40003C
    Should be True    ${new_len_3C} > ${orig_len_3C}
    ${new_len_4C}    Check and Get BTS Counter Length M40004C
    Should be True    ${new_len_4C} > ${orig_len_4C}
    selenium logout and close browser

Get real time measurements via Webem
    [Documentation]  Author: qingqing.1.wang@nokia-sbell.com
    [Arguments]    ${object_names}    ${interval}
    ${content}    selenium_coam.get_real_time_measurements    object_names=${object_names}
    ${value_list}    get dictionary values    ${content}
	${time_list}    get dictionary keys   ${value_list[0]}
    sort list    ${time_list}
    ${status}    ${last_time}   run keyword and ignore error    set variable    ${time_list[-1]}
	Connect to Common Unit Master
    ${current_time}   get time from gnb
    ${end_time}    add_time_to_date    ${last_time}    ${interval}
    ${diff}    subtract_date_from_date    ${end_time}    ${current_time}
    ${diff1}    subtract_time_from_time    ${diff}    ${interval}
    should be true    ${diff1}<0
	${wait_time}=  evaluate  ${diff1} + 60
    ${power_voltage}    get_from_dictionary   ${value_list[0]}    ${last_time}
	${Voltage}    get_from_dictionary    ${power_voltage}    Voltage
	${Power}    get_from_dictionary    ${power_voltage}    Power
    [Return]     ${Voltage}    ${Power}    ${wait_time}

Check real time measurements
    [Documentation]  Author: qingqing.1.wang@nokia-sbell.com
    [Arguments]    ${object_names}    ${interval}
    FOR  ${i}  IN RANGE  ${2}
	    ${Voltage}    ${Power}    ${wait_time}    Get real time measurements via Webem
        ...    object_names=${object_names}    interval=${interval}
	    Should be True    ${Voltage} > 0
        Should be True    ${Power} > 0
	    exit for loop if   ${i} == 1
	    sleep    ${wait_time}
	    sleep    10
	END

RU Lock Unlock and Check PM Counter Update Value
    [Arguments]    ${interval}
	Connect to Common Unit Master
	selenium login and disable screen lock
	${value_2C0}    Get PM Counter via Webem for 5GC000433-H-K    counter_id=M40002C0    interval=${interval}
    ${value_2C1}    Get PM Counter via Webem for 5GC000433-H-K    counter_id=M40002C1    interval=${interval}
    selenium logout and close browser
    Perform RU Lock
    Wait Until Keyword Succeeds    2 min    3 sec    RU Should Be Locked
    Wait Until Keyword Succeeds    3 min    5 sec    Cell Should Be Disabled
    ${wait_time}    Get wait value minutes    ${interval}
    sleep    ${wait_time}min
    sleep    30
	FOR  ${i}  IN RANGE  ${2}
        selenium login and disable screen lock
		${value_2C0_locked}    Get PM Counter via Webem for 5GC000433-H-K    counter_id=M40002C0
	    ...    interval=${interval}
        ${value_2C1_locked}    Get PM Counter via Webem for 5GC000433-H-K    counter_id=M40002C1
	    ...    interval=${interval}
		Should be True    ${value_2C0_locked} > 0
        Should be True    0 < ${value_2C1_locked} < ${value_2C1}
        selenium logout and close browser
        exit for loop if   ${i} == 1
        sleep    ${interval}
    END
    Perform RU Unlock
    Wait Until Keyword Succeeds    4 min   3 sec    RU Should Be Unlocked
	Wait Until Keyword Succeeds    4 min   3 sec    Cell Should Be Enabled
	${wait_time}    Get wait value minutes    ${interval}
    sleep    ${wait_time}min
    sleep    30
	FOR  ${i}  IN RANGE  ${2}
        selenium login and disable screen lock
		${value_2C0_unlock}    Get PM Counter via Webem for 5GC000433-H-K    counter_id=M40002C0
	    ...    interval=${interval}
        ${value_2C1_unlock}    Get PM Counter via Webem for 5GC000433-H-K    counter_id=M40002C1
	    ...    interval=${interval}
		Should be True    ${value_2C0_unlock} > 0
        Should be True    ${value_2C1_unlock} > 0
        selenium logout and close browser
        exit for loop if   ${i} == 1
        sleep    ${interval}
	END

RF Power Off On and Check Energy Consumption Counters
    [Arguments]    ${interval}
	selenium login and disable screen lock
	Check real time measurements    object_names=SMOD    interval=${interval}
	Check real time measurements    object_names=RMOD    interval=${interval}
	${content_origin}    selenium_coam.get_real_time_measurements    object_names=RMOD
	${len_origin}    get length  ${content_origin}
	Perform RU Power Off
	Wait until keyword succeeds      5 min    10 sec    RU Should Be Power Off
	sleep    ${interval}
 	${content_new}    selenium_coam.get_real_time_measurements    object_names=RMOD
	${len_new}    get length  ${content_new}
	Should be True    ${len_origin} == ${len_new}
	Perform RU Power On
	Wait until keyword succeeds      240 sec    5 sec     RU Should Be Online
	Wait Until Keyword Succeeds    480 sec   5 sec     COAM Check GNB cell on air
	sleep    ${interval}
	Check real time measurements    object_names=SMOD    interval=${interval}
	Check real time measurements    object_names=RMOD    interval=${interval}
	selenium logout and close browser

Case Preparation
    log to console   \n*** set precondition: Energy_Consumption activate ***
    Modify Parameters for Energy Consumption Measurement
    ...    actPowerMeter=true
    ...    mtBtsEnergyMonitoring=15min
    ...    mtSBTSRfModuleInputVoltageMeasurementInt=15min
    ...    mtSBTSSmEnergyMonitoring=15min
	${wait_time}    Get wait value minutes    interval=15min
    sleep    ${wait_time}min
	sleep    15min
