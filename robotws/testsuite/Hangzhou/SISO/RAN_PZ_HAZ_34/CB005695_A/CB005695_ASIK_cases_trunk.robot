# *** Settings ***
# Documentation    Suite description
# ...               author: Ruizzhan
# ...               contact: ruizhi.zhang@nokia-sbell.com
# ...               squad group: MMW_SG_04
# Force Tags        SBTS00    RAN_5G    RAN_5G_TDD    CRT_UTE    CLOUD_5G_CLASSICAL_ANDROID_SA_ASIKL_ABILB1_AEHC    STATE_SW_UPLOADED
# ...    PY36
# Suite Setup       Case Suite Steup
# Suite Teardown
# 
# Resource          ./resource/CB005695_common_keyword.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource          ../FGCR_8000/resource/FGCR_8000_common_keyword.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BW_common_case/lib/BW_step_keywords.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/aasyslog.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Throughput_checking_from_GNB.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Commercial_mobile_phone_adb_common_keywords.robot
# 
# *** Variables ***
# ${pb_status}   on
# ${bbu_powerstation_model}   HBTE
# ${DU_OAM_IP}              ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${DU_OAM_WEBUI_USER}      ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${DU_OAM_WEBUI_PASSWORD}  ${tl.gnbs[0].cu.oam_http_connection_details.password}
# ${GLONASS_only}           actGlonass
# ${Beidou_only}            actBeidou
# ${GPS_only}               actGps
# ${GNSSmode}               MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/GNSSE-1
# ${holdovermode}           gnssReceiverHoldoverMode
# ${Altitude}               35
# ${Latitude1}              301816900
# ${Longitude1}             1201383500
# ${Latitude2}              301817000
# ${Longitude2}             1201386700
# ${location1}              manual
# ${location2}              automatic
# ${GNSS1}                  gnssAntennaAltitudeConf
# ${GNSS2}                  gnssAntennaLatitudeConf
# ${GNSS3}                  gnssAntennaLongitudeConf
# ${GNSS4}                  locationMode
# ${GNSS5}                  gnssConstellationMode
# ${GNSS6}                  gnssAntennaAltitude
# ${GNSS7}                  gnssAntennaLatitude
# ${GNSS8}                  gnssAntennaLongitude
# ${GNSS9}                  gnssReceiverHoldoverMode
# ${ul_throughput1}         200M
# ${dl_throughput1}         400M
# ${ul_peak_50M}            5
# ${dl_peak_50M}            50
# ${server_port}            ${tl.ues[1].iperf_details.port}
# ${server_ip}              ${tl.ues[1].iperf_details.network_interface_address}
# ${MRBTS_ID}               ${tl.gnbs[0].instance_id}
# ${scf_path}              ${CURDIR}/../../../../../commissionings/HGZ/7_5_UTE5G402T710/
# 
# *** Test Cases ***
# [1]CB005695-A-005_AYGD_Startup_detection_with_the_GNSS_receiver_configured_to_different_location_mode
#     [Tags]
#     [Setup]
#     Run Keyword And Continue On Failure    Set Manual location mode
#     ...    Latitude=${Latitude1}    Longitude=${Longitude1}
#     PB off and on
#     Run Keyword And Continue On Failure    Check the Coordinate
#     ...     Latitude=${Latitude1}    Longitude=${Longitude1}
#     Run Keyword And Continue On Failure    Location Teardown
#     ...     Latitude=${Latitude1}    Longitude=${Longitude1}
#     [Teardown]    Case Teardown
# 
# *** Keywords ***
# Case Suite Steup
#     CI_interface.Common Case Setup
#     Suite Setup
# 
# Suite Setup
#     CB005695_common_keyword.Input default SCF
# 
# Change gnssControlMode
#     [Arguments]     ${GNSS_valueL}    ${Beidou_valueL}     ${GPS_valueL}
#     CB005695_common_keyword.Rest Login DU
#     ${fault_name_list}     ${faultlist1}     Get Alarm Info     timeout=1
#     sort list    ${faultlist1}
#     perform muti Parameter recommissioning    dist_name=${GNSSmode}    parameter=${GLONASS_only}     value=${GNSS_valueL}
#     ...    operation=update
#     perform muti Parameter recommissioning    dist_name=${GNSSmode}    parameter=${Beidou_only}     value=${Beidou_valueL}
#     ...    operation=update
#     perform muti Parameter recommissioning    dist_name=${GNSSmode}    parameter=${GPS_only}     value=${GPS_valueL}
#     ...    operation=update
# 
# PB off and on
#     Log To Console     PB power off
#     PB execution       pb_ip=${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
#     ...    pb_port=${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}   action=off
#     Sleep              10
#     PB execution       pb_ip=${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
#     ...    pb_port=${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}   action=on
#     Log To Console     Check BTS Should Be Normal
#     Wait Until Keyword Succeeds     250   10    Login DU
#     Wait Until BTS Should Be Normal
#     [Teardown]    CB005695_common_keyword.Disconnect from DU
# 
# Login DU
#     [Arguments]  ${ip_address}=${DU_OAM_IP}        ${alias}=default
#     ...          ${username}=${DU_OAM_WEBUI_USER}  ${password}=${DU_OAM_WEBUI_PASSWORD}
#     [Documentation]   Login DU
#     ${connection}   coam.Connect To  bts_host=${ip_address}  bts_port=443
#     ...                                    name=${alias}
#     ...                                    username=${username}  password=${password}
#     [Return]  ${connection}
# 
# Rest Logout DU
#     [Arguments]  ${alias}=default
#     [Documentation]   Rest Logout DU
#     coam.Teardown  connection=${alias}
# 
# PB execution
#     [Arguments]        ${pb_ip}   ${pb_port}   ${action}
#     pdu.setup_pdu      model=${bbu_powerstation_model}   host=${pb_ip}   alias=BBU
#     Run Keyword        pdu.power_${action}   port=${pb_port}   pdu_device=BBU
#     Set Suite Variable   ${pb_status}   ${action}
# 
# Set Manual location mode
#     [Arguments]    ${Latitude}    ${Longitude}
#     CB005695_common_keyword.Rest Login DU
#     perform muti Parameter recommissioning    dist_name=${GNSSmode}    parameter=${GNSS1}     value=${Altitude}
#     ...    operation=update
#     perform muti Parameter recommissioning    dist_name=${GNSSmode}    parameter=${GNSS2}     value=${Latitude}
#     ...    operation=update
#     perform muti Parameter recommissioning    dist_name=${GNSSmode}    parameter=${GNSS3}     value=${Longitude}
#     ...    operation=update
#     perform muti Parameter recommissioning    dist_name=${GNSSmode}    parameter=${GNSS4}     value=${location1}
#     ...    operation=update
#     CB005695_common_keyword.Disconnect from DU
#     sleep                 60
#     getParas and check    GNSSE_actual=${GNSS6}    GNSSvalue=${Altitude}
#     getParas and check    GNSSE_actual=${GNSS7}    GNSSvalue=${Latitude}
#     getParas and check    GNSSE_actual=${GNSS8}    GNSSvalue=${Longitude}
# 
# 
# Check the Coordinate
#     [Arguments]    ${Latitude}    ${Longitude}
#     getParas and check    GNSSE_actual=${GNSS6}    GNSSvalue=${Altitude}
#     getParas and check    GNSSE_actual=${GNSS7}    GNSSvalue=${Latitude}
#     getParas and check    GNSSE_actual=${GNSS8}    GNSSvalue=${Longitude}
#     [Teardown]
# 
# Location Teardown
#     [Arguments]    ${Latitude}    ${Longitude}
#     CB005695_common_keyword.Rest Login DU
#     Run Keyword And Continue On Failure     perform muti Parameter recommissioning    dist_name=${GNSSmode}
#     ...    parameter=${GNSS1}     value=${Altitude}     operation=delete     should_activate=${False}
#     Run Keyword And Continue On Failure     perform muti Parameter recommissioning    dist_name=${GNSSmode}
#     ...    parameter=${GNSS2}     value=${Latitude}     operation=delete     should_activate=${False}
#     Run Keyword And Continue On Failure     perform muti Parameter recommissioning    dist_name=${GNSSmode}
#     ...    parameter=${GNSS3}     value=${Longitude}     operation=delete     should_activate=${False}
#     Run Keyword And Continue On Failure    perform muti Parameter recommissioning    dist_name=${GNSSmode}
#     ...    parameter=${GNSS4}     value=${location2}     operation=update
#     DU GNSS Reset
#     [Teardown]    CB005695_common_keyword.Disconnect from DU
# 
# Case Teardown
#     CI_interface.Common Case Teardown
# 
# Set GNSS receiver to Manual location mode
#     [Arguments]    ${Latitude}    ${Longitude}
#     CB005695_common_keyword.Rest Login DU
#     ${fault_name_list}     ${faultlist4}     Get Alarm Info     timeout=1
#     sort list    ${faultlist4}
#     perform muti Parameter recommissioning    dist_name=${GNSSmode}    parameter=${GNSS1}     value=${Altitude}
#     ...    operation=update
#     perform muti Parameter recommissioning    dist_name=${GNSSmode}    parameter=${GNSS2}     value=${Latitude}
#     ...    operation=update
#     perform muti Parameter recommissioning    dist_name=${GNSSmode}    parameter=${GNSS3}     value=${Longitude}
#     ...    operation=update
#     perform muti Parameter recommissioning    dist_name=${GNSSmode}    parameter=${GNSS4}     value=${location1}
#     ...    operation=update
#     CB005695_common_keyword.Disconnect from DU
#     sleep    1min
#     getParas and check    GNSSE_actual=${GNSS6}    GNSSvalue=${Altitude}
#     getParas and check    GNSSE_actual=${GNSS7}    GNSSvalue=${Latitude}
#     getParas and check    GNSSE_actual=${GNSS8}    GNSSvalue=${Longitude}
#     Sleep    5min
#     ${connection}    CB005695_common_keyword.Rest Login DU
#     ${fault_name_list}     ${faultlist5}     Get Alarm Info     timeout=1
#     sort list    ${faultlist5}
#     ${status}=    run keyword and return status    lists should be equal    ${faultlist5}    ${faultlist4}
#     Run Keyword If    ${status}!=${True}    Collect snapshot coam
#     should be equal   ${status}    ${True}
#     CB005695_common_keyword.Disconnect from DU
#     [Teardown]          Location Teardown    ${Latitude}    ${Longitude}
# 
# UE Case Teardown
#     run keyword and ignore error    power_ue.UE Detach    ue_type=huawei
#     CI_interface.Common Case Teardown
# 
# Make Up Peak and Down Peak
#     [Arguments]    ${ul_peak}    ${dl_peak}    ${ul_throughput}    ${dl_throughput}
#     honor attach
#     UE start traffic hon     tp_direction=both    ul_throughput=${ul_throughput}    dl_throughput=${dl_throughput}    time=2s
#     ...                    duration=300
#     run keyword and continue on failure    power_ue.Check throughput
#     ...    ue_type=huawei    direction=ul    throughput=${ul_peak}     cellid=11632640
#     run keyword and continue on failure    power_ue.Check throughput
#     ...    ue_type=huawei    direction=dl    throughput=${dl_peak}     cellid=11632640
#     power_ue.Stop traffic    ue_type=huawei    direction=both    iperf_type=via_command
# 
# UE start traffic hon
#     [Documentation]    used for UE start traffic, ul/dl/both.
#     [Arguments]    ${ue_index}=${0}    ${protocol}=udp    ${tp_direction}=both    ${duration}=2000    ${iperf_type}=via_command
#     ...    ${ul_throughput}=100M    ${dl_throughput}=2048M    ${time}=2s    ${ue_type}=huawei
#     ...    ${iperf_port_ul}=default    ${iperf_port_dl}=default
#     Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    Start traffic hon    ue_index=${ue_index}
#     ...    direction=ul    throughput=${ul_throughput}    duration=${duration}    ue_type=${ue_type}    iperf_type=${iperf_type}
#     ...    protocol=${protocol}    iperf_port=${iperf_port_ul}
#     sleep    1s
#     Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'   Start traffic hon    ue_index=${ue_index}
#     ...     direction=dl    throughput=${dl_throughput}    duration=${duration}    ue_type=${ue_type}    protocol=${protocol}
#     ...    iperf_port=${iperf_port_dl}
#     sleep    ${time}
# 
# Start traffic hon
#     [Arguments]    ${direction}    ${duration}   ${throughput}    ${iperf_port}=default
#     ...            ${ue_index}=${0}    ${interval}=1    ${buffer_size}=1024B    ${protocol}=udp
#     ...            &{kwargs}
#     [Documentation]    Start data transfer for L3 call test.
#     ...  :param  direction: The traffic direction, ul or dl.
#     ...  :param  duration: Duration of traffic
#     ...  :param  throughput: Throughput of new data transfer
#     ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for traffic
#     ${default_port}    set variable if    '${direction}'=='ul'    ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
#     ...                                                           ${tl.ues[${ue_index}].iperf_details.port}
#     ${port}    set variable if   '${iperf_port}' == 'default'    ${default_port}    ${iperf_port}
#     run keyword if    '${direction}' == 'dl'    Start DL traffic and check the TP on EPC hon    ue_index=${ue_index}
#     ...                                                                                     time=${duration}
#     ...                                                                                     interval=${interval}
#     ...                                                                                     traffic=${throughput}
#     ...                                                                                     buffer_size=${buffer_size}
#     ...                                                                                     iperf_port=${port}
#     ...                                                                                     protocol=${protocol}
#     ...    ELSE IF    '${direction}' == 'ul'    Start UL traffic and check the TP on Commercial hon    time=${duration}
#     ...                                                                                            traffic=${throughput}
#     ...                                                                                            ue_index=${ue_index}
#     ...                                                                                            iperf_port=${port}
#     ...                                                                                            protocol=${protocol}
# 
# Start UL traffic and check the TP on Commercial hon
#     [Arguments]    ${time}=10    ${traffic}=10.00M    ${ue_index}=${0}    ${iperf_port}=${tl.appserver.iperf_details.port}    ${retry}=${3}
#     ...    ${iperf_type}=via_app    ${protocol}=udp    ${data_amount}=data_amount    ${buffer_size}=1024B
#     run keyword if    '${iperf_type}'=='via_app'    Start UL UDP traffic via iperf app     time=${time}    traffic=${traffic}
#     ...    iperf_port=${iperf_port}    ue_index=${ue_index}
#     ...    ELSE    Start UL traffic via iperf command hon    time=${time}    traffic=${traffic}
#     ...    UL_port=${iperf_port}    ue_index=${ue_index}    protocol=${protocol}     data_amount=${data_amount}    buffer_size=${buffer_size}
# 
# Start UL traffic via iperf command hon
#     [Arguments]    ${time}=10    ${traffic}=10.00M    ${ue_index}=${0}    ${UL_port}=${tl.appserver.iperf_details.port}
#     ...    ${protocol}=udp      ${data_amount}=data_amount    ${buffer_size}=1024B
#     run keyword if    '${protocol}'=='udp'    Start UL UDP traffic via iperf command hon    time=${time}    traffic=${traffic}
#     ...    UL_port=${UL_port}    ue_index=${ue_index}    buffer_size=${buffer_size}
#     ...    ELSE    Start UL TCP traffic via iperf command    time=${time}    traffic=${traffic}
#     ...    UL_port=${UL_port}    ue_index=${ue_index}     data_amount=${data_amount}    buffer_size=${buffer_size}
# 
# Start DL traffic and check the TP on EPC hon
#     [Documentation]    stat DL traffic
#     ...    :param  ue_index: The list index from tl.ues[]
#     ...    :param  time: Duration of traffic
#     ...    :param  interval: common which to get UE IP
#     ...    :param  traffic: Throughput of new data transfer
#     ...    :param  buffer_size: buffer size of new data transfer
#     ...    :param  protocal: Traffic protocal type. E.G udp/tcp
#     [Arguments]    ${ue_index}=${0}    ${time}=10    ${iperf_port}=${tl.ues[${ue_index}].iperf_details.port}
#     ...            ${interval}=1    ${traffic}=10.00M    ${buffer_size}=1024B    ${protocol}=udp
#     run keyword if    '${protocol}'=='udp'        Start DL traffic and check the TP on EPC with hon    ue_index=${ue_index}
#     ...                                                       time=${time}
#     ...                                                       interval=${interval}
#     ...                                                       traffic=${traffic}
#     ...                                                       buffer_size=${buffer_size}
#     ...                                                       DL_port=${iperf_port}
# 
# Start DL traffic and check the TP on EPC with hon
#     [Arguments]    ${Home_button}=${Home_button}    ${swipe}=${swipe}
#     ...            ${open_iperf_location}=${open_iperf_location}
#     ...            ${ue_index}=${0}    ${DL_port}=${tl.ues[${ue_index}].iperf_details.port}    ${time}=10
#     ...            ${interval}=1    ${traffic}=10.00M    ${buffer_size}=1024B    ${iperf_button}=${iperf_button}
#     Get Commercial UE IP    ue_index=${ue_index}
#     wait until keyword succeeds    1 min    10 sec    Connect to EPC APP    ue_index=${ue_index}
#     sleep   2s
#     csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${DL_port}| awk '{print $2}' |xargs kill -9    connection=EPCAPP
#     csn.send_command
#     ...    command=iperf -c ${UE_IP} -u -t ${time} -i ${interval} -p ${DL_port} -P 3 -b ${traffic}
#     ...    connection=EPCAPP
# 
# Start UL UDP traffic via iperf command hon
#     [Arguments]    ${EPC_IP}=${tl.appserver.iperf_details.network_interface_address}
#     ...    ${UL_port}=${tl.appserver.iperf_details.port}    ${buffer_size}=1024B    ${interval}=1    ${ue_index}=${0}
#     ...    ${time}=10    ${serial_number}=${tl.ues[${ue_index}].serial_number}
#     ...    ${traffic}=10.00M    ${window_size}=2M
#     sleep   2s
#     Connect to control pc via cygwin    ue_index=${ue_index}
#     csn.send_command    command=adb -s ${serial_number} root &
#     ...    connection=cygwin
#     csn.send_command    command=adb -s ${serial_number} shell ps -ef | grep iperf |grep ${UL_port} |grep -v grep |awk '{print $2}'
#     ...    connection=cygwin
#     ${pid}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=cygwin
#     csn.send_command    command=adb -s ${serial_number} shell kill -9 ${pid} &
#     ...    connection=cygwin
#     sleep    2s
#     ${cmd}=    catenate    adb -s ${serial_number} shell /data/local/tmp/iperf -c ${EPC_IP} -u -p ${UL_port}
#     ...    -t ${time} -P 1 -i 1 -b ${traffic}
#     csn.send_command    command=${cmd}
#     ...    connection=cygwin
#     csn.send_command    command=adb -s ${serial_number} shell ps -ef |grep iperf |grep ${UL_port} |grep -v grep |awk '{print $2}'
#     ...    connection=cygwin
#     ${pid}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=cygwin
#     log to console    .....UE_${ue_index} udp ul iperf start....
#     [Teardown]    csn.disconnect      connection=cygwin
# 
# Manually reset GNSS
#     CB005695_common_keyword.Rest Login DU
#     ${fault_name_list}     ${faultlist8}     Get Alarm Info     timeout=1
#     sort list    ${faultlist8}
#     DU GNSS Reset
#     CB005695_common_keyword.Disconnect from DU
#     Sleep    5min
#     CB005695_common_keyword.Rest Login DU
#     ${fault_name_list}     ${faultlist9}     Get Alarm Info     timeout=1
#     sort list    ${faultlist9}
#     ${status}=    run keyword and return status    lists should be equal    ${faultlist8}    ${faultlist9}
#     Run Keyword If    ${status}!=${True}    Collect snapshot coam
#     Run Keyword And Continue On Failure     should be equal   ${status}    ${True}
#     perform muti Parameter recommissioning    dist_name=${GNSSmode}
#     ...    parameter=${GNSS9}     value=${True}     operation=update
#     CB005695_common_keyword.Disconnect from DU
#     Sleep    5min
#     CB005695_common_keyword.Rest Login DU
#     ${fault_name_list}     ${faultlist10}     Get Alarm Info     timeout=1
#     sort list    ${faultlist10}
#     ${status}=    run keyword and return status    lists should be equal    ${faultlist9}    ${faultlist10}
#     Run Keyword If    ${status}!=${True}    Collect snapshot coam
#     Run Keyword And Continue On Failure     should be equal   ${status}    ${True}
#     [Teardown]    perform muti Parameter recommissioning    dist_name=${GNSSmode}
#     ...    parameter=${GNSS9}     value=${False}     operation=update
