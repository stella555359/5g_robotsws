*** Settings ***
Suite Setup          Run Keywords     SISO Coam Suite Setup
...                   AND     Case Preparation
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
#Test Teardown        SISO Coam Test Teardown
Test Timeout         180 min

Resource      Resource/5GC000430_commonKW.robot

Documentation
...    Author:annie hu
...    contact:annie.hu@nokia-sbell.com
...    squad group:SG_05
...    Feature 5GC000430 benchmark testing

Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G
...    PY36

*** Variables ***

*** Test Cases ***
[1]5GC000430-Power_Consumption_and_Power_Saving_percentage_measured_when_cell_locked
     [Tags]    CRT_TRUNK   CRT_20B    CRT_21B    master_classicalbts_all
     [Teardown]    Run Keywords    Case Teardown      AND
     ...                           SISO Coam Test Teardown
     log to console   \n disable then enable Power Saving mode when cell locked
     wait until keyword succeeds    1min    2sec    Connect to gnb coam via ssl
     ${cell_list}   Get All Cell Id   connection=GNB_OAM
      Connect to gnb coam via ssl
     #:FOR   ${cell_idx}   IN   @{cell_list}
           #Perform cell lock via rest api   cell_idx=${cell_idx}
     #END
     Run Keyword And Continue On Failure    Perform cell lock via rest api    cell_idx=${1}
     Sleep    10s
     Modify RMOD Power Parameter    power_status=false
     #sleep  20
     sleep    5min
     selenium login and disable screen lock
     #Check real time measurements    object_names=RMOD    interval=1min
     Check real time measurements of RMOD    interval=1min
     #Check real time measurements    object_names=SMOD    interval=1min
     Check real time measurements of SMOD    interval=1min
     sleep  20
     Modify RMOD Power Parameter    power_status=true
     sleep  20
     selenium login and disable screen lock
     #Check real time measurements    object_names=RMOD    interval=1min
     Check real time measurements of RMOD     interval=1min
     #Check real time measurements    object_names=SMOD    interval=1min
     Check real time measurements of SMOD    interval=1min
     selenium logout and close browser


[1]5GC000430-Power_Consumption_and_Power_Saving_percentage_measured_when_cell_onair
      [Tags]    CRT_TRUNK   CRT_20B    CRT_21B    master_classicalbts_all
      log to console   \n disable then enable Power Saving mode when cell on air
      Modify RMOD Power Parameter    power_status=false
      sleep  120
      selenium login and disable screen lock
      ${rmod_power_meassure_1}    Get RMOD Power Measurement via Webem    interval=1min
      ${smod_power_meassure_1}    Get SMOD Power Measurement via Webem    interval=1min
      #${power_meassure_after}   Get RMOD Power Measurement
      Modify RMOD Power Parameter    power_status=true
      sleep  120s
      selenium login and disable screen lock
      ${rmod_power_meassure_2}    Get RMOD Power Measurement via Webem    interval=1min
      ${smod_power_meassure_2}    Get SMOD Power Measurement via Webem    interval=1min

      ${rmod_p_value}    Evaluate
      ...    "%.2f" % ((${rmod_power_meassure_1}-${rmod_power_meassure_2})/${rmod_power_meassure_1})
      ${rmod_per_value}    Evaluate    ${rmod_p_value}*100
      log to console   \n RMOD Power Saving Percent when cell on air:${rmod_per_value}%
      should be true      ${rmod_per_value} > 8
      ${smod_p_value}    Evaluate
      ...    "%.2f" % ((${smod_power_meassure_1}-${smod_power_meassure_2})/${smod_power_meassure_1})
      ${smod_per_value}    Evaluate    ${smod_p_value}*100
      log to console   \n SMOD Power Saving Percent when cell on air:${smod_per_value}%
      should be true      -1 < ${smod_per_value} < 1



[1]5GC000430-Power_Consumption_and_Power_Saving_percentage_measured_in_half_Load
      [Tags]    CRT_TRUNK   CRT_20B    CRT_21B    master_classicalbts_all
      Power_Consumption_and_Power_Saving_percentage_measured_in_Half_Load    ul_tput=4M    dl_tput=700M


[1]5GC000430-Power_Consumption_and_Power_Saving_percentage_measured_in_full_Load
     [Tags]    CRT_TRUNK   CRT_20B    CRT_21B    master_classicalbts_all
     Power_Consumption_and_Power_Saving_percentage_measured_in_Half_Load    ul_tput=8M    dl_tput=1400M


[1]5GC000430-Power_Consumption_and_Power_Saving_percentage_measured_with_5GC000526
      [Tags]    CRT_TRUNK   CRT_20B    CRT_21B    master_classicalbts_all
      [Teardown]    Run Keywords     Restore targetTotalLoad in webui      AND
        ...                           SISO Coam Test Teardown
      log to console   \n disable then enable Power Saving mode when set targetTotalLoad
      #Set Parameter to activate 5GC000526
      Modify RMOD Power Parameter    power_status=false
      Set Parameter to activate 5GC000526
      selenium login and disable screen lock
      ${rmod_power_meassure_1}    Get RMOD Power Measurement via Webem    interval=1min
      ${smod_power_meassure_1}    Get SMOD Power Measurement via Webem    interval=1min
      Modify RMOD Power Parameter    power_status=true
      sleep  120s
      selenium login and disable screen lock
      ${rmod_power_meassure_2}    Get RMOD Power Measurement via Webem    interval=1min
      ${smod_power_meassure_2}    Get SMOD Power Measurement via Webem    interval=1min

      ${rmod_p_value}    Evaluate
      ...    "%.2f" % ((${rmod_power_meassure_1}-${rmod_power_meassure_2})/${rmod_power_meassure_1})
      ${rmod_per_value}    Evaluate    ${rmod_p_value}*100
      log to console   \n RMOD Power Saving Percent when cell on air:${rmod_per_value}%
      should be true      ${rmod_per_value} > -1
      ${smod_p_value}    Evaluate
      ...    "%.2f" % ((${smod_power_meassure_1}-${smod_power_meassure_2})/${smod_power_meassure_1})
      ${smod_per_value}    Evaluate    ${smod_p_value}*100
      log to console   \n SMOD Power Saving Percent when cell on air:${smod_per_value}%
      should be true      ${smod_per_value} >= -1




*** Keywords ***
Set Parameter to activate 5GC000526
    Wait Until Keyword Succeeds    2min    30s    WEBUI Login
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...    filter_param=Target total load with artificial load     new_value=${100}
    Validate and activate and check activate plan status
    sleep   60s
    wait until keyword succeeds   10m   60s   Verify all cells should be onair


Restore targetTotalLoad in webui
     Wait Until Keyword Succeeds    2min    30s    WEBUI Login
     selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
     ...    filter_param=Target total load with artificial load     new_value=${0}
     Validate and activate and check activate plan status
     sleep   60s
     wait until keyword succeeds   10m   60s   Verify all cells should be onair

Power_Consumption_and_Power_Saving_percentage_measured_in_Half_Load
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test is to verify Power Saving percentage measured in Half Load
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    Owner_annie.hu@nokia-sbell.com
    [Arguments]  ${cell_id}=${1}    ${ue_index}=${0}    ${ul_tput}=100M    ${dl_tput}=300M
    ${dl_tp}  ${ul_tp}  ${dl_exp}  ${ul_exp}    Calculate Send Tput And Expected Tput
    ...    peak_dl_tp=${dl_tput}    peak_ul_tp=${ul_tput}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity
    ${cell_id}    Convert To String    ${cell_mapping[${cell_id}]['nrCellIdentity']}
    ${cell_id}    Create List    ${cell_id}
    log to console   \n enable Power Saving mode
    Modify RMOD Power Parameter    power_status=true
    sleep  20
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}
    ...    protocol=udp    duration=720    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}
    ...    protocol=udp    duration=720    ue_index=${ue_index}
    sleep  40
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=60
    ${output}    power_ue.Check Bi Tput   ue_type=${ue_type}    log=${tput_log}    cells=${cell_id}    ultarget_throughput=${ul_exp}
    ...    dltarget_throughput=${dl_exp}    target_avg_percent=0.1    min_percent=0.1
    log to console    ${output}
    #${power_enable_with_call}  Get RMOD Power Measurement
    selenium login and disable screen lock
    ${power_enable_with_call}    Get RMOD Power Measurement via Webem    interval=1min
    ${smod_power_meassure_1}    Get SMOD Power Measurement via Webem    interval=1min
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}
    log to console   \n disable Power Saving mode
    Modify RMOD Power Parameter    power_status=false
    sleep  20
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}
    ...    protocol=udp    duration=720    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}
    ...    protocol=udp    duration=720    ue_index=${ue_index}
    sleep  40
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=60
    ${output}    power_ue.Check Bi Tput   ue_type=${ue_type}    log=${tput_log}    cells=${cell_id}    ultarget_throughput=${ul_exp}
    ...    dltarget_throughput=${dl_exp}    target_avg_percent=0.1    min_percent=0.1
    log to console    ${output}
    #${power_disable_with_call}  Get RMOD Power Measurement
    selenium login and disable screen lock
    ${power_disable_with_call}    Get RMOD Power Measurement via Webem    interval=1min
    ${smod_power_meassure_2}    Get SMOD Power Measurement via Webem    interval=1min
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}
    ${p_value}    Evaluate    "%.3f" % ((${power_disable_with_call}-${power_enable_with_call})/${power_disable_with_call})
    ${per_value}    Evaluate    ${p_value}*100
    log to console   \n Power Saving Percent with half load:${per_value}%
    should be true       ${per_value} > -1
    ${smod_p_value}    Evaluate
      ...    "%.2f" % ((${smod_power_meassure_2}-${smod_power_meassure_1})/${smod_power_meassure_2})
    ${smod_per_value}    Evaluate    ${smod_p_value}*100
    log to console   \n SMOD Power Saving Percent when cell on air:${smod_per_value}%
    should be true      ${smod_per_value} >= -1
