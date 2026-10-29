# *** Settings ***
# Documentation    Suite description
# ...               author: Ruizzhan
# ...               contact: ruizhi.zhang@nokia-sbell.com
# ...               squad group: MMW_SG_04
# Force Tags        SBTS00    RAN_5G    RAN_5G_TDD    CRT_UTE    CLOUD_5G_CLASSICAL_ANDROID_SA_ASIKL_ABILB1_AEHC    STATE_SW_UPLOADED
# ...    PY36
# Suite Setup       Case Suite Steup
# Suite Teardown
# Resource          ./resource/CB005694_common_keyword.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource          ../FGCR_8000/resource/FGCR_8000_common_keyword.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BW_common_case/lib/BW_step_keywords.robot
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
# [1]CB005694-A-005_AYGE_Startup_detection_with_the_GNSS_receiver_configured_to_different_location_mode
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
#     Adapt to ute cloud commission scf
#     Suite Setup
# 
# Suite Setup
#     CB005694_common_keyword.Input default SCF
# 
# Change gnssControlMode
#     [Arguments]     ${GNSS_valueL}    ${Beidou_valueL}     ${GPS_valueL}
#     ${connection}    CB005694_common_keyword.Rest Login DU
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
#     Wait Until Keyword Succeeds     250   10    Rest Login DU
#     Wait Until BTS Should Be Normal
#     [Teardown]    CB005694_common_keyword.Disconnect from DU
# 
# Rest Login DU
#     [Arguments]  ${ip_address}=${DU_OAM_IP}        ${alias}=default
#     ...          ${username}=${DU_OAM_WEBUI_USER}  ${password}=${DU_OAM_WEBUI_PASSWORD}
#     [Documentation]   Rest Login DU
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
#     ${connection}    CB005694_common_keyword.Rest Login DU
#     perform muti Parameter recommissioning    dist_name=${GNSSmode}    parameter=${GNSS1}     value=${Altitude}
#     ...    operation=update
#     perform muti Parameter recommissioning    dist_name=${GNSSmode}    parameter=${GNSS2}     value=${Latitude}
#     ...    operation=update
#     perform muti Parameter recommissioning    dist_name=${GNSSmode}    parameter=${GNSS3}     value=${Longitude}
#     ...    operation=update
#     perform muti Parameter recommissioning    dist_name=${GNSSmode}    parameter=${GNSS4}     value=${location1}
#     ...    operation=update
#     CB005694_common_keyword.Disconnect from DU
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
# 
# Location Teardown
#     [Arguments]    ${Latitude}    ${Longitude}
#     ${connection}    CB005694_common_keyword.Rest Login DU
#     Run Keyword And Continue On Failure     perform muti Parameter recommissioning    dist_name=${GNSSmode}
#     ...    parameter=${GNSS1}     value=${Altitude}     operation=delete     should_activate=${False}
#     Run Keyword And Continue On Failure     perform muti Parameter recommissioning    dist_name=${GNSSmode}
#     ...    parameter=${GNSS2}     value=${Latitude}     operation=delete     should_activate=${False}
#     Run Keyword And Continue On Failure     perform muti Parameter recommissioning    dist_name=${GNSSmode}
#     ...    parameter=${GNSS3}     value=${Longitude}     operation=delete     should_activate=${False}
#     Run Keyword And Continue On Failure    perform muti Parameter recommissioning    dist_name=${GNSSmode}
#     ...    parameter=${GNSS4}     value=${location2}     operation=update
#     DU GNSS Reset
#     [Teardown]    CB005694_common_keyword.Disconnect from DU
# 
# Case Teardown
#     CI_interface.Common Case Teardown
# 
# Set GNSS receiver to Manual location mode
#     [Arguments]    ${Latitude}    ${Longitude}
#     ${connection}    CB005694_common_keyword.Rest Login DU
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
#     sleep    1min
#     CB005694_common_keyword.Disconnect from DU
#     getParas and check    GNSSE_actual=${GNSS6}    GNSSvalue=${Altitude}
#     getParas and check    GNSSE_actual=${GNSS7}    GNSSvalue=${Latitude}
#     getParas and check    GNSSE_actual=${GNSS8}    GNSSvalue=${Longitude}
#     Sleep    5min
#     ${connection}    CB005694_common_keyword.Rest Login DU
#     ${fault_name_list}     ${faultlist5}     Get Alarm Info     timeout=1
#     sort list    ${faultlist5}
#     ${status}=    run keyword and return status    lists should be equal    ${faultlist5}    ${faultlist4}
#     Run Keyword If    ${status}!=${True}    Collect snapshot coam
#     should be equal   ${status}    ${True}
#     CB005694_common_keyword.Disconnect from DU
#     [Teardown]          Location Teardown    ${Latitude}    ${Longitude}
# 
# UE Case Teardown
#     run keyword and ignore error    power_ue.UE Detach    ue_type=huawei
#     CI_interface.Common Case Teardown
# 
# Make Up Peak and Down Peak
#     [Arguments]    ${ul_peak}    ${dl_peak}    ${ul_throughput}    ${dl_throughput}
#     honor attach
#     UE start traffic       tp_direction=both    ul_throughput=${ul_throughput}    dl_throughput=${dl_throughput}    time=2s
#     ...                    duration=300
#     run keyword and continue on failure    power_ue.Check throughput
#     ...    ue_type=huawei    direction=ul    throughput=${ul_peak}     cellid=11468801
#     run keyword and continue on failure    power_ue.Check throughput
#     ...    ue_type=huawei    direction=dl    throughput=${dl_peak}     cellid=11468801
#     power_ue.Stop traffic    ue_type=huawei    direction=both    iperf_type=via_command
# 
# Manually reset GNSS
#     ${connection}    CB005694_common_keyword.Rest Login DU
#     ${fault_name_list}     ${faultlist8}     Get Alarm Info     timeout=1
#     sort list    ${faultlist8}
#     DU GNSS Reset
#     CB005694_common_keyword.Disconnect from DU
#     Sleep    5min
#     ${connection}    CB005694_common_keyword.Rest Login DU
#     ${fault_name_list}     ${faultlist9}     Get Alarm Info     timeout=1
#     sort list    ${faultlist9}
#     ${status}=    run keyword and return status    lists should be equal    ${faultlist8}    ${faultlist9}
#     Run Keyword If    ${status}!=${True}    Collect snapshot coam
#     Run Keyword And Continue On Failure     should be equal   ${status}    ${True}
#     perform muti Parameter recommissioning    dist_name=${GNSSmode}
#     ...    parameter=${GNSS9}     value=${True}     operation=update
#     CB005694_common_keyword.Disconnect from DU
#     Sleep    5min
#     ${connection}    CB005694_common_keyword.Rest Login DU
#     ${fault_name_list}     ${faultlist10}     Get Alarm Info     timeout=1
#     sort list    ${faultlist10}
#     ${status}=    run keyword and return status    lists should be equal    ${faultlist9}    ${faultlist10}
#     Run Keyword If    ${status}!=${True}    Collect snapshot coam
#     Run Keyword And Continue On Failure     should be equal   ${status}    ${True}
#     [Teardown]    perform muti Parameter recommissioning    dist_name=${GNSSmode}
#     ...    parameter=${GNSS9}     value=${False}     operation=update
