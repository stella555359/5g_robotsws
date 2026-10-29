*** Settings ***
Documentation
...    author:
...     - Michal Chrzanowski (michal.a.chrzanowski@nokia.com)
...    contact:
...     - Michal Chrzanowski
...     - Nelsadnro Sampaio (nelsandro.sampaio@nokia.com)

Library         BuiltIn
Library         ./tools.py
Library         taf.ue                                                             WITH NAME    ue
Library         taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations          WITH NAME    gnbcell
Library         taf.rfrl.bts.devices.du.alarm_verification.GnbAlarmVerification    WITH NAME    Alarms
Library         taf.sbts.oam.coam.admin                                            WITH NAME    SbtsAdmin
Library         taf.rfrl.utilities.logger.custom_logger                            WITH NAME    logger
Library         taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Library         testsuite.Krakow.resources.alarm.Alarm
Resource        taf/rfrl/bts/robot/common/gnb_alarm.robot
Resource        taf/rfrl/bts/robot/gnb.robot
Resource        taf/rfrl/ue/robot/REAL_UE.robot
Resource        taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables       ./delta.py

*** Variables ***
#--------------------------    UE capabilities   ----------------------------------
${capabilities}                                 REAL_UE
${reboot_ue}                                    False
${timeout_reboot_ue}                            100
${alias}                                        UE
#-------------------------    L3 call variables    --------------------------------

${duration}                                     300s
${tput_dl}                                      600 Mbits/sec
${tput_ul}                                      130 Mbits/sec
${protocol}                                     tcp
${deviation}                                    25%
${deviation_dl}                                 ${deviation}
${deviation_ul}                                 ${deviation}
${parallel_streams_dl}                          4
${parallel_streams_ul}                          2
${size_packet}                                  1400B
${size_packet_dl}                               ${size_packet}
${size_packet_ul}                               ${size_packet}
${buffer_client_dl}                             None
${buffer_server_dl}                             None
${buffer_client_ul}                             None
${buffer_server_ul}                             None
${interval}                                     1
${linux_congestion_dl}                          reno
${linux_congestion_ul}                          reno
${bts_type}                                     GNB
${clear_source_dir}                             False
${attach_timeout}                               100
${ENABLE_RACH_OBSERVER}                         False
#--------------------- alarms -----------------------------
@{additional_allowed_alarms}                   61675    61673
@{allowed_alarms_during_lane_block}            1815    10    16    1868
#--------------------- param reconfiguration -----------------------------
${timeout}                                     240
${skip_parameter_relation_errors}              False
${should_activate}                             True


*** Keywords ***
Lock and unlock SFP LANE and check alarms
    [Arguments]    ${sfp_lane_dist_name}
    gnbalarm.allow_alarm                    alarm=@{allowed_alarms_during_lane_block}
    Lock SFP LANE    ${sfp_lane_dist_name}
    Alarms.Wait For Alarm Activation        fault_id=1815     awaiting_time=300
    Alarms.Verify Alarm Is Not Active       fault_name=No connection to unit    fault_id=10

    Unlock SFP LANE    ${sfp_lane_dist_name}
    Alarms.Wait For Alarm Deactivation      fault_id=1815     awaiting_time=300
    Alarms.Verify Alarm Is Not Active       fault_name=Not able to synchronize baseband bus    fault_id=1815
    gnbalarm.disallow_alarm                 alarm=@{allowed_alarms_during_lane_block}
    Verify Allowed Alarms on gNB            allowed_alarms=@{allowed_alarms}
    Wait Until Keyword Succeeds  3 min  30 sec  gnbcell.verify all cells statuses
    ...                                                 operational_state=enabled
    ...                                                 procedural_status=configured
    ...                                                 availability_status=online
    ...                                                 administrative_state=unlocked

Perform reconfiguration parameter
    Perform Delta Commissioning On gNB    ${delta}    timeout=${timeout}
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}    should_activate=${should_activate}
    Wait for site to be onair
    Sleep    30s    reason=Waiting for stabilization after reconfiguration
    Verify Allowed Alarms on gNB          allowed_alarms=@{allowed_alarms}

Attach ${ue_alias}
    [Documentation]    KW perfroms UE attach with cell verification using taf.ue KWs
    ...    :param ue_alias: taf.ue UE alias
    logger.Log Info To Console    Attach ${ue_alias}
    ue.Attach Ue    ${ue_alias}
    ${CELL_ID}=     ue.Get Ue Info    ${ue_alias}   CELL_ID

Detach ${ue_alias}
    [Documentation]    KW perfroms UE dettach using taf.ue KWs
    Run Keyword and Ignore Error    ue.Detach Ue    ${ue_alias}

Start and Verify TCP DL and UL data transfer for UE
    [Arguments]     ${ue_alias}=UE1
    ...             ${apn}=${None}
    ...             ${dl_tput}=4200 Mbits/sec
    ...             ${ul_tput}=530 Mbits/sec
    ...             ${data_transfer_time}=30s
    ...             ${omit}=5
    ...             ${deviation}=20%
    ...             ${protocol}=tcp
    ...             ${parallel_streams}=4
    ...             ${max_segment_size}=1310

    [Documentation]    The keyword executes TCP DL and UL data transmission for a specific time and checks if throughput
    ...                was within allowed deviation
    ...    :param ue_alias: taf.ue UE alias
    ...    :param dl_tput: DL throughput value of data transfer
    ...    :param ul_tput: UL throughput value of data transfer
    ...    :param data_transfer_time: for how data transfer will last
    ...    :param omit: it is a delay in seconds to start counting the tput ex. '20'
    ...                 1st 20 seconds of datatransfer will be omited.

    ${dl_dt_name}=            Set Variable    TCP_DL_DataTransfer_1
    ${ul_dt_name}=            Set Variable    TCP_UL_DataTransfer_1

    ue.Start Data Transfer    dt_name=${dl_dt_name}    ue_alias=${ue_alias}    apn=${apn}    direction=dl
    ...                       duration=${data_transfer_time}    protocol=${protocol}   max_segment_size=${max_segment_size}
    ...                       parallel_streams=${parallel_streams}    deviation=${deviation}    omit=${omit}
    logger.Log Info To Console    DL TCP data transfer started    log_hierarchy=2
    ue.Await Data Transfer Finish    ${dl_dt_name}
    ue.Stop Data Transfer    dt_name=${dl_dt_name}
    ue.Verify Average Throughput With Deviation    dt_name=${dl_dt_name}    tput=${dl_tput}    omit=${omit}
    ...                                            deviation=${deviation}
    logger.Log Info To Console    DL TCP data transfer OK    log_hierarchy=3

    ue.Start Data Transfer    dt_name=${ul_dt_name}    ue_alias=${ue_alias}    apn=${apn}    direction=ul
    ...                       duration=${data_transfer_time}    protocol=${protocol}    max_segment_size=${max_segment_size}
    ...                       parallel_streams=${parallel_streams}    deviation=${deviation}    omit=${omit}
    logger.Log Info To Console    UL TCP data transfer started    log_hierarchy=2
    ue.Await Data Transfer Finish    ${ul_dt_name}
    ue.Stop Data Transfer    dt_name=${ul_dt_name}
    ue.Verify Average Throughput With Deviation    dt_name=${ul_dt_name}    tput=${ul_tput}     omit=${omit}
    ...                                            deviation=${deviation}
    logger.Log Info To Console    UL TCP data transfer OK    log_hierarchy=3
