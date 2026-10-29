*** Settings ***
Documentation
...    author: zhenzhen.guo
...    contact:zhenzhen.guo@nokia-sbell.com
...    squad group: RAN_PZ_HAZ3_SG03
...    feature : CB008392
Library     taf.sbts.oam.coam.admin   WITH NAME    coam
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
#Library     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/compare_alarm_list.py
Library     taf.hw.rf_attenuator    WITH NAME    att

Variables    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB008392/Resources/CB08392_variables.py
#Variables    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001358/Resources/5GC001358_variables.py


*** Variables ***
${ue_type}    ${tl.ues[-1].capabilities[-1]}
${ute_host}    ${tl.test_pc.default_ssh_connection_details.addr}
${ute_user}    ${tl.test_pc.default_ssh_connection_details.username}
${ute_password}    ${tl.test_pc.default_ssh_connection_details.password}
#${ue_type}    ${tl.ues[-1].capabilities[-1]}
${asik_addr}    ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${asik_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asik_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${att_ipaddr}               ${tl.attenuator.ip_addr}
${att_port_number}         ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${att_port_0}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${att_port_1}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${att_port_2}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${att_port_3}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
${att_port_4}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[4].port_no}
${att_port_5}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[5].port_no}
${att_port_6}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[6].port_no}
${att_port_7}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[7].port_no}
${att_port_8}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[8].port_no}
${att_port_9}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[9].port_no}
${att_port_10}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[10].port_no}
${att_port_11}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[11].port_no}
${att_api_port}             ${tl.attenuator.port}
${vendor}                   HBTE
${HBTE_max_value}           ${127}    ##no sig
${scf_path}                 ${commissionings_path}/HGZ/${testline_name}
${8T8R_scf_name}            SCF_8T8R_SBTS00.xml
${BF_scf_name}              SCF_8T8R_SBTS00.xml
${nonBF_scf_name}           SCF_nonBF_SBTS00.xml
${Muti_RF_scf_name}         SCF_8T8R_SBTS00.xml
${default_scf}              ${scf_path}/SCF_8T8R_SBTS00.xml

*** Keywords ***
Feature CB008392 Active
    log to console    \nFeature CB008392 Active
    Selenium Login And Disable Screen Lock    download_dir=/tmp
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate NR load-based reduced TX power saving  p_name=actNrLBRTXPowerSaving  value=true
    append to list  ${modify_params}  ${item}
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-1
    ...    filter_param=Load-based power saving switch off method    p_name=lbpsSOMethod  value=TX switch off
    append to list  ${modify_params}  ${item}
    Modify Parameters On Webem    modify_params=${modify_params}
    Verify all cells should be onair    connection=GNB_OAM
    [teardown]    Selenium Logout And Close Browser



Feature CB008392 Active using admin
    log to console    \nFeature CB008392 Active using admin
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-1
    ...    parameter=lbpsSOMethod
    ...    value=TX switch off
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    parameter=actNrLBRTXPowerSaving
    ...    value=true
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM

Feature CB008392 Deactive
    log to console    \nFeature CB008392 Deactive
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    parameter=actNrLBRTXPowerSaving
    ...    value=false
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM

Feature 5GC000431 Active using admin
    [Arguments]    ${NRPGRP_id}=1
    log to console    \nFeature 5GC000431 Active using admin
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-${NRPGRP_id}
    ...    parameter=lbpsSOMethod
    ...    value=cell switch off
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    parameter=actGrflShdn
    ...    value=true
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    parameter=actNrLBPowerSaving
    ...    value=true
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM

Feature 5GC000431 Deactive
    log to console    \nFeature 5GC000431 Deactive
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    parameter=actNrLBPowerSaving
    ...    value=false
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM

Set lbpsDuration
    [Arguments]    ${lbpsDuration}
    log to console    \nSet lbpsDuration
    ${modify_lbps_params}    create list
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=Activate NR load-based power saving    p_name=actNrLBPowerSaving    value=true
    append to list    ${modify_lbps_params}    ${item}
    ${item}    create dictionary    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-1
    ...    filter_param=Load-based power saving day of week    p_name=lbpsDayOfWeek    value=${curr_week}
    append to list    ${modify_lbps_params}    ${item}
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-1
    ...    parameter=lbpsDuration
    ...    value=${lbpsDuration}
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM

Suspend cells which is in reduced energy saving state
    log to console    \nSuspend cells which is in reduced energy saving state
    Selenium Login And Disable Screen Lock    download_dir=/tmp
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-1
    ...    filter_param=Load-Based Power Saving Suspended    p_name=lbpsSuspended  value=suspended
    append to list  ${modify_params}  ${item}
    Modify Parameters On Webem    modify_params=${modify_params}
    Verify all cells should be onair    connection=GNB_OAM
    [teardown]    Selenium Logout And Close Browser

Unsuspend cells which is in not energy saving state
    log to console    \nUnsuspend cells which is in reduced energy saving state
    Selenium Login And Disable Screen Lock    download_dir=/tmp
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-1
    ...    filter_param=Load-Based Power Saving Suspended    p_name=lbpsSuspended  value=notSuspended
    append to list  ${modify_params}  ${item}
    Modify Parameters On Webem    modify_params=${modify_params}
    Verify all cells should be onair    connection=GNB_OAM
    [teardown]    Selenium Logout And Close Browser

Cell_switch_off_conditions_meet_before_and_during_start_power_saving_time_period
    log to console    \nEnergy Saving met
    [Arguments]    ${NRPGRP_id}=1
    run keyword and ignore error    Verify cell is not energy saving state
    csn.Connect to    hostname=${ute_host}    username=${ute_user}    password=${ute_password}    alias=ute
    ${curr_week}    csn.Execute   command=date +%A    connection=ute
	${curr_week}    Fetch From Left    ${curr_week}    marker=\r\n
	${curr_week}    Get Substring    ${curr_week}    0    3
	log to console    ${curr_week}
    csn.Disconnect     connection=ute
    log to console    \nactive feature 431
    ${modify_lbps_params}    create list
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=Activate graceful cell shutdown    p_name=actGrflShdn    value=true
    append to list    ${modify_lbps_params}    ${item}
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=Activate NR load-based power saving    p_name=actNrLBPowerSaving    value=true
    append to list    ${modify_lbps_params}    ${item}
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP_id}
    ...    filter_param=Load-based power saving switch off method    p_name=lbpsSOMethod  value=cell switch off
    append to list  ${modify_lbps_params}  ${item}
    ${item}    create dictionary    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP_id}
    ...    filter_param=Load-based power saving day of week    p_name=lbpsDayOfWeek    value=${curr_week}
    append to list    ${modify_lbps_params}    ${item}
    ${curr_date}   DateTime.Get Current Date
    ${datetime}   DateTime.Convert Date    ${curr_date}    datetime
    ${item}    create dictionary    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP_id}
    ...    filter_param=Load-based power saving start time hour    p_name=lbpsStartTimeHour    value=${datetime.hour}
    append to list    ${modify_lbps_params}    ${item}
    ${item}    create dictionary    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP_id}
    ...    filter_param=Load-based power saving start time minute    p_name=lbpsStartTimeMinute    value=${datetime.minute}
    append to list    ${modify_lbps_params}    ${item}
    Selenium Login And Disable Screen Lock    download_dir=/tmp
    Modify Parameters On Webem    modify_params=${modify_lbps_params}    despite_errors=${True}
    #Wait until keyword succeeds    10min    30s    Verify cell is energy saving state
    [Teardown]    Selenium Logout And Close Browser

Verify cell is not energy saving state
    [Arguments]      ${connection}=GNB_OAM    ${cell_index}=1
    log to console    \nVerify cell is not energy saving state
    ${cell_info}    coam.get_cell_specific_info    cell_id=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_index}    connection=${connection}
    ${energysaving_status}    Set Variable    ${cell_info['energySavingState']}
    log    cell_${cell_index}: ${energysaving_status}
    should be equal    ${energysaving_status}    notEnergySaving

Verify cell is energy saving state
    [Arguments]      ${connection}=GNB_OAM    ${cell_index}=1
    log to console    \nVerify cell is energy saving state
    ${cell_info}    coam.get_cell_specific_info    cell_id=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_index}    connection=${connection}
    ${energysaving_status}    Set Variable    ${cell_info['energySavingState']}
    log    cell_${cell_index}: ${energysaving_status}
    should be equal    ${energysaving_status}    energySaving

Verify cell is switching off state
    [Arguments]      ${connection}=GNB_OAM    ${cell_index}=1
    log to console    \nVerify cell is switching off state
    ${cell_info}    coam.get_cell_specific_info    cell_id=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_index}    connection=${connection}
    ${energysaving_status}    Set Variable    ${cell_info['energySavingState']}
    should be equal    ${energysaving_status}    switchingOff


Verify cell is reduced Energy Saving
    [Arguments]      ${connection}=GNB_OAM    ${cell_index}=1
    log to console    \nVerify cell is reduced Energy Saving
    ${cell_info}    coam.get_cell_specific_info    cell_id=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_index}    connection=${connection}
    ${energysaving_status}    Set Variable    ${cell_info['energySavingState']}
    log    cell_${cell_index}: ${energysaving_status}
    should be equal    ${energysaving_status}    reducedEnergySaving

Verify cell is switchingOffRTX state
    [Arguments]      ${connection}=GNB_OAM    ${cell_index}=1
    log to console    \nVerify cell is switchingOffRTX state
    ${cell_info}    coam.get_cell_specific_info    cell_id=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_index}    connection=${connection}
    ${energysaving_status}    Set Variable    ${cell_info['energySavingState']}
    should be equal    ${energysaving_status}    switchingOffRTX

Verify cell is switchingOnTX state
    [Arguments]      ${connection}=GNB_OAM    ${cell_index}=1
    log to console    \nVerify cell is switchingOnTX state
    ${cell_info}    coam.get_cell_specific_info    cell_id=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_index}    connection=${connection}
    ${energysaving_status}    Set Variable    ${cell_info['energySavingState']}
    should be equal    ${energysaving_status}    switchingOffRTX

Deactive cell which is in reducedEnergySaving state
    log to console    \nDeactive cell which is in reducedEnergySaving state
    run keyword and ignore error    Verify cell is reduced Energy Saving
    Feature CB008392 Deactive

Deactive cell which is in EnergySaving state
    log to console    \nDeactive cell which is in reducedEnergySaving state
    run keyword and ignore error    Verify cell is energy saving state
    Feature 5GC000431 Deactive


Modify to open loop
    log to console    \nModify to open loop
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    parameter=dlMimoMode
    ...    value=4x4 or 4x2 Open Loop Spatial Multiplexing
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM

Modify to close loop
    log to console    \nModify to close loop
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    parameter=dlMimoMode
    ...    value=4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM


Verify TP after CB008392 enabled
    log to console    \nVerify DL TP is only half of peak
    log to console    \nVerify UL TP does not impact

Modify precondition for IRC case
    log to console    \nModify precondition for IRC case
    ${modify_params}    create list
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1
    ...    filter_param=Downlink MIMO Mode    p_name=dlMimoMode    value=4x4 or 4x2 Closed Loop Spatial Multiplexing
    append to list    ${modify_params}    ${item}
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1
    ...    filter_param=NR Cell type    p_name=nrCellType  value=4DL4UL
    append to list  ${modify_params}  ${item}
    ${item}    create dictionary    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1
    ...    filter_param=Number of Rx beamforming    p_name=numberOfRxBeamforming    value=4Rx
    append to list    ${modify_params}    ${item}
    ${item}    create dictionary    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=Activate frequency domain scheduling    p_name=actFdmScheduling    value=true
    append to list    ${modify_params}    ${item}
    ${item}    create dictionary    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=Activate enhanced frequency domain scheduling    p_name=actFdmEnhancedScheduling    value=true
    append to list    ${modify_params}    ${item}
    Selenium Login And Disable Screen Lock    download_dir=/tmp
    Modify Parameters On Webem    modify_params=${modify_params}    despite_errors=${True}
   	Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=GNB_OAM
    [Teardown]    Selenium Logout And Close Browser

Check If there is new alarm
    Log To Console    Check If there is new alarm
    Selenium Login And Disable Screen Lock    download_dir=/tmp
    @{alarm_info}=    Wait Until Keyword Succeeds    5min    10s    selenium_coam.get_active_alarm_info    timeout=100
	${alarm_numbler}=        Get Length    ${alarm_info}
	run keyword and ignore error    should be true    ${alarm_numbler} == 4
    sleep    5s
	${alarm_info_history}=    coam.get_historic_alarms    timeout=60    connection=GNB_OAM
    [Teardown]    Selenium Logout And Close Browser

TX_switch_off_conditions_meet_before_and_during_start_power_saving_time_period
    log to console    \nReduceEnergy Saving met
    [Arguments]    ${NRPGRP_id}=1
    run keyword and ignore error    Verify cell is not energy saving state
    csn.Connect to    hostname=${ute_host}    username=${ute_user}    password=${ute_password}    alias=ute
    ${curr_week}    csn.Execute   command=date +%A    connection=ute
    ${curr_week}    Fetch From Left    ${curr_week}    marker=\r\n
    ${curr_week}    Get Substring    ${curr_week}    0    3
    log to console    ${curr_week}
    csn.Disconnect     connection=ute
    ${modify_lbps_params}    create list
	#Feature CB008392 Active using admin
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=Activate NR load-based reduced TX power saving    p_name=actNrLBRTXPowerSaving    value=true
    append to list    ${modify_lbps_params}    ${item}
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP_id}
    ...    filter_param=Load-based power saving switch off method    p_name=lbpsSOMethod  value=TX switch off
    append to list  ${modify_lbps_params}  ${item}
    ${item}    create dictionary    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP_id}
    ...    filter_param=Load-based power saving day of week    p_name=lbpsDayOfWeek    value=${curr_week}
    append to list    ${modify_lbps_params}    ${item}
    ${curr_date}   DateTime.Get Current Date
    ${datetime}   DateTime.Convert Date    ${curr_date}    datetime
    ${item}    create dictionary    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP_id}
    ...    filter_param=Load-based power saving duration    p_name=lbpsDuration    value=60
    append to list    ${modify_lbps_params}    ${item}
    ${item}    create dictionary    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP_id}
    ...    filter_param=Load-based power saving start time hour    p_name=lbpsStartTimeHour    value=${datetime.hour}
    append to list    ${modify_lbps_params}    ${item}
    ${item}    create dictionary    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP_id}
    ...    filter_param=Load-based power saving start time minute    p_name=lbpsStartTimeMinute    value=${datetime.minute}
    append to list    ${modify_lbps_params}    ${item}
    Selenium Login And Disable Screen Lock    download_dir=/tmp
    Modify Parameters On Webem    modify_params=${modify_lbps_params}    despite_errors=${True}
    #Wait until keyword succeeds    10min    30s    Verify cell is reduced Energy Saving
    [Teardown]    Selenium Logout And Close Browser

Block dedicated cell
    log to console    block dedicated cell
	[Arguments]    ${cell_id}=1
    coam.block_cell    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-${cell_id}    connection=GNB_OAM

Unblock dedicated cell
    log to console    unbock dedicated cell
    [Arguments]    ${cell_id}=1
    coam.unblock_cell    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-${cell_id}    connection=GNB_OAM

Set lbpsLastCellSOEnabled to true
    log to console    \nSet lbpsLastCellSOEnabled to true
    [Arguments]    ${NRPGRP_id}=1
    Selenium Login And Disable Screen Lock    download_dir=/tmp
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP_id}
    ...    filter_param=Load-based power saving last cell switch off enabled    p_name=lbpsLastCellSOEnabled    value=true
    append to list  ${modify_params}  ${item}
    Modify Parameters On Webem    modify_params=${modify_params}
    Verify all cells should be onair    connection=GNB_OAM
    [teardown]    Selenium Logout And Close Browser

Set limit time value of TX power saving on and off
    log to console    \nSet limit time value of TX power saving on and off
	[Arguments]    ${NRPGRP_id}=1    ${off_time}=300    ${on_time}=300
	Selenium Login And Disable Screen Lock    download_dir=/tmp
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP_id}
    ...    filter_param=Load-based power saving reduced TX switch off time    p_name=lbpsRTXSOffTime    value=${off_time}
    append to list  ${modify_params}  ${item}
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP_id}
    ...    filter_param=Load-based power saving reduced TX switch on time    p_name=lbpsRTXSOnTime    value=${on_time}
    append to list  ${modify_params}  ${item}
    Modify Parameters On Webem    modify_params=${modify_params}
   	Wait until keyword succeeds    10min    30s    Verify all cells should be onair    connection=GNB_OAM
    [teardown]    Selenium Logout And Close Browser

Vefify cell switch off order
    log to console    \nVefify cell switch off order
    Wait until keyword succeeds    30min    1s    Verify cell is reduced Energy Saving    cell_id=5
    Verify cell is not energy saving state    cell_id=6
    Wait until keyword succeeds    30min    1s    Verify cell is reduced Energy Saving    cell_id=6


Start traffic and check UE DL and UL TP seperately
    log to console    \nStart traffic and check UE DL and UL TP seperately
    [Arguments]    ${expect_dl_tp}=1300    ${expect_ul_tp}=60    ${dl_traffic}=1500M    ${ul_traffic}=90M
    UE start traffic   tp_direction=dl   ul_tp=0    dl_tp=${dl_traffic}
    sleep    10s
    UE check throughput by syslog    tp_direction=dl    exp_ul_tp=0    exp_dl_tp=${expect_dl_tp}    check_times=60
    power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=${UE_TYPE}
    UE start traffic   tp_direction=ul   ul_tp=${ul_traffic}    dl_tp=0
    sleep    10s
    UE check throughput by syslog    tp_direction=ul    exp_ul_tp=${expect_ul_tp}    exp_dl_tp=0    check_times=60s
    power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=${UE_TYPE}

Check UE TP
    log to console    \nCheck UE TP
    [Arguments]    ${tp_direction}=both    ${expect_dl_tp}=1300    ${expect_ul_tp}=60
    Run keyword and continue on failure    UE check throughput by syslog    tp_direction=${tp_direction}
    ...   exp_ul_tp=${expect_ul_tp}    exp_dl_tp=${expect_dl_tp}

UE check throughput by syslog
    [Arguments]    ${tp_direction}=both    ${exp_ul_tp}=100    ${exp_dl_tp}=100    ${check_times}=60s
    log to console    UE check throughput by syslog
    AAsys log captrue    stop_aasys_flag=${False}
    sleep    ${check_times}
    ${all_tp}    Get ul and dl peak and ave throughput and return result    aasys_start_flag=${False}
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'    Run keyword and continue on failure
    ...      should be true    ${all_tp[1]}>${exp_dl_tp}
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    Run keyword and continue on failure
    ...     should be true    ${all_tp[4]}>${exp_ul_tp}
    Set Suite Variable    ${all_tp}

Get ul and dl peak and ave throughput and return result
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${aasys_start_flag}=${true}
    ${cell_number}    Get cell numbers in gnb    gnb_index=${gnb_index}    du_index=${du_index}
    run keyword if    '${aasys_start_flag}'=='${true}'    AAsys log captrue    gnb_index=${gnb_index}
    ...    du_index=${du_index}
    ${cell_id}    Get nrcellid from aasys log    gnb_index=${gnb_index}    du_index=${du_index}
    ${dl_traffic_data}    ${ul_traffic_data}    Get traffic data from aasys log for TRUNK
    ...    gnb_index=${gnb_index}    du_index=${du_index}
    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    Calculate Throughput and retrun result in gnb
    ...    data=${dl_traffic_data}
    ...    cell_numbers=${cell_number}
    ${ul_peak_tp}    ${ul_average_tp}    ${ul_minimum_tp}    Calculate Throughput and retrun result in gnb
    ...    data=${ul_traffic_data}
    ...    cell_numbers=${cell_number}
    [Return]    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    ${ul_peak_tp}
    ...    ${ul_average_tp}    ${ul_minimum_tp}
    [teardown]    Run Keyword and Ignore Error    admin_cli.teardown    connection=COAM

UE stop traffic
    [Arguments]    ${tp_direction}=both
    log to console    UE stop traffic
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'   power_ue.Stop traffic
	...    direction=dl    ue_index=${0}    ue_type=${UE_TYPE}
    sleep    3s
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Stop traffic
	...    direction=ul    ue_index=${0}    ue_type=${UE_TYPE}

UE Prepare
    Log To Console    \n ### Prepare UE ###
    #power_ue.Prepare UE    ue_index=${0}    ue_type=${UE_TYPE}    reset_sol=ue_reboot
	power_ue.Prepare UE    ue_type=${UE_TYPE}

Attach UE
    Log To Console    \n ### UE Attach ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    log_type=Aasyslog
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=False

UE Prepare and UE attach
    Log To Console    \n ### Prepare UE ###
    power_ue.Prepare UE    ue_index=${0}    ue_type=${UE_TYPE}        reset_sol=ue_reboot
	sleep    40s
    Log To Console    \n ### UE Attach ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    log_type=Aasyslog
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=False

UE start traffic
    [Arguments]    ${tp_direction}=both    ${ul_tp}=100M    ${dl_tp}=100M
    log to console    UE start traffic
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'   power_ue.Start traffic    ue_index=${0}
    ...     direction=dl    throughput=${dl_tp}   duration=900000    ue_type=${ue_type}    buffer_size=1400B
    sleep    3s
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Start traffic    ue_index=${0}
    ...    direction=ul    throughput=${ul_tp}    duration=900000    ue_type=${ue_type}    iperf_type=via_command

Suite Setup
    Connect to gnb coam via ssl
	${sw_version} =     coam.get_sw_version    connection=GNB_OAM
    Set Suite Variable    ${sw_version}
    Set Suite Variable    ${Active_SW_version}    ${sw_version}
    ${stream}    get stream from version    ${SW_version}
    Set Suite Variable    ${stream}
    @{SBTS_release}    string.split string    ${stream}    separator=SBTS
    ${release_id}    set variable    ${SBTS_release}[1]
    Set Suite Variable    ${release_id}
    ${8T8R_scf_name}    Run keyword if   '${stream}'=='SBTS00'     set variable   SCF_8T8R_SBTS00.xml
    ...   ELSE    set variable    SCF_8T8R_SBTS00_${release_id}.xml
    Set Suite Variable    ${8T8R_scf_name}
    ${BF_scf_name}    Run keyword if   '${stream}'=='SBTS00'     set variable   SCF_8T8R_SBTS00.xml
    ...   ELSE    set variable    SCF_8T8R_SBTS${release_id}.xml
    Set Suite Variable    ${BF_scf_name}
    ${Muti_RF_scf_name}    Run keyword if   '${stream}'=='SBTS00'     set variable   SCF_8T8R_SBTS00.xml
    ...   ELSE    set variable    SCF_8T8R_SBTS${release_id}.xml
    Set Suite Variable    ${Muti_RF_scf_name}

Suite Teardown
    [Arguments]    ${gnb_index}=0
    log to console    \n***SISO Coam Suite Teardown***
    Check If there is new alarm
    Run keyword if    '${stream}'=='SBTS00'    Scf commition and wair for on-air    scf_name=${default_scf}
    ...   ELSE    Feature CB008392 Active using admin
	#Set limit time value of TX power saving on and off    off_time=300    on_time=120
	Run Keyword And Ignore Error    Detach UE for case finished
    ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ...    connection=${connection}    gnb_index=${gnb_index}
    ${ru_status}    Run Keyword And Return Status    COAM Check GNB RU status    connection=${connection}
    ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair    connection=${connection}
    #Run Keyword If    ${ru_status}==${False} or ${cell_status}==${False} and ${if_teardown_commissioning}
    #...    Run Keyword And Ignore Error    Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}
    COAM Teardown gnb connections    connection=${connection}
    Run Keyword And Ignore Error    process.Terminate All Processes    kill=True
    csn.Connect to    hostname=${ute_host}    username=${ute_user}    password=${ute_password}    alias=ute
	csn.execute    command=rm -rf /tmp/*.log    connection=ute
	csn.execute    command=rm -rf /tmp/*.html    connection=ute
	#csn.execute    command=rm -rf /tmp/*    connection=ute
    csn.Disconnect     connection=ute



Detach UE for case finished
    Log To Console    \n ### UE Detach ###
    Run Keyword And Ignore Error    UE stop traffic
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}

Modify parameter administrativeState
    log to console    Modify parameter administrativeState
	[Arguments]    ${cell_id}=1    ${value}=Shutting Down
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    parameter=actGrflShdn
    ...    value=true
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    parameter=administrativeState
    ...    value=${value}
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM

Adjust HBTE ATT Values seperate
    [Arguments]      ${attenuation_values_of_all_ports}
    log to console    Adjust HBTE ATT Value
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_port_1}   max_attenuation=${HBTE_max_value}    vendor=${vendor}
    FOR  ${port_num}    IN RANGE    0    4
        ${att_value}    set variable    ${attenuation_values_of_all_ports['atten_value_of_port${port_num}']}
        att.set_attenuation    port=${att_port_${port_num}}    value=${att_value}
        ${value_port}    att.read_attenuation    port=${att_port_${port_num}}
        should be equal    ${value_port}    ${att_value}
    END
    FOR  ${port_num}    IN RANGE    8    12
        ${att_value}    set variable    ${attenuation_values_of_all_ports['atten_value_of_port${port_num}']}
        att.set_attenuation    port=${att_port_${port_num}}    value=${att_value}
        ${value_port}    att.read_attenuation    port=${att_port_${port_num}}
        should be equal    ${value_port}    ${att_value}
    END


Adjust HBTE ATT Values
    [Arguments]      ${attenuation_values_of_all_ports}
    log to console    Adjust HBTE ATT Value
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_port_1}   max_attenuation=${HBTE_max_value}    vendor=${vendor}
    FOR  ${port_num}    IN RANGE    0    8
        ${att_value}    set variable    ${attenuation_values_of_all_ports['atten_value_of_port${port_num}']}
        att.set_attenuation    port=${att_port_${port_num}}    value=${att_value}
        ${value_port}    att.read_attenuation    port=${att_port_${port_num}}
        should be equal    ${value_port}    ${att_value}
    END


Make one cell fail or recovery cell
    [Arguments]    ${cell_id}=1    ${gscn_value}=1
    log to console    \nMake one cell fail or recovery cell
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    parameter=gscnOrSsPbchArfcn
    ...    value=${gscn_value}
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM

Scf xml modify
    [Arguments]      ${scf_file_path}    ${parameters_to_update_xml}
    log to console    Scf xml modify
    ${scf_file_name}    Fetch from right    ${scf_file_path}    /
    ${scf_dir_path}    String.Replace string    ${scf_file_path}    /${scf_file_name}    ${EMPTY}
    ${file_name_without_extention}    String.Replace string    ${scf_file_name}    .xml    ${EMPTY}
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    ${scf_file_name_after_modify}    catenate  SEPARATOR=${EMPTY}    ${file_name_without_extention}
    ...    _${timestamp}_updated.xml
    ${modified_scf_file_path}    set variable    ${scf_dir_path}/${scf_file_name_after_modify}
    scf.Load Scf    ${scf_file_path}
    FOR  ${modify_para}  IN  @{parameters_to_update_xml}
      run keyword if    '${modify_para['operate']}'=='update'    scf.modify_scf_element
      ...    value=${modify_para['new_value']}    dist_name=${modify_para['dist_name']}
      ...    p_name=${modify_para['p_name']}
      run keyword if    '${modify_para['operate']}'=='delete'    scf.remove_mo_with_descendant_mos
      ...    dist_name=${modify_para['dist_name']}
      run keyword if    '${modify_para['operate']}'=='add_mo'    scf.add_object_to_scf
      ...    class_name=${modify_para['class_name']}    dist_name=${modify_para['dist_name']}
      ...    version=${modify_para['version']}
    END
    scf.save_scf    ${modified_scf_file_path}
    [Return]  ${modified_scf_file_path}

Scf commition and wair for on-air
    [Arguments]    ${scf_name}    ${is_pdl_checking_needed}=${True}
    log to console    Scf commition and wair for on-air
    Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${scf_name}    is_pdl_checking_needed=${is_pdl_checking_needed}    connection=GNB_OAM
    Wait Until Keyword Succeeds    20min    20s    COAM Check GNB cell on air
    Run Keyword And Ignore Error    ssh.force_reconnect    connection=ASIK Master



Scf muti-radio commition and wair for on-air
    [Arguments]    ${scf_name}    ${is_pdl_checking_needed}=${True}
    log to console    Scf muti-radio commition and wair for on-air
    Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${scf_name}    timeout=600
	...    is_pdl_checking_needed=${is_pdl_checking_needed}    connection=GNB_OAM
    Wait Until Keyword Succeeds    20min    20s    COAM Check GNB cell on air
    Run Keyword And Ignore Error    ssh.force_reconnect    connection=ASIK Master
