# *** Settings ***
# Force Tags    PY36
# Documentation     Suite description
# ...               author: chutian
# ...               contact: chun.tian@nokia-sbell.com
# ...               squad group: MMW_SG_04
# Suite Setup      Suite Setup
# Suite Teardown
# Resource          ../CB005694_A/resource/CB005694_common_keyword.robot
# Resource          ../CB005694_B/resource/CB005694_B_resource.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource          testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007608_B-573/Resources/5GC000573_common_keyword.robot
# 
# *** Variables ***
# ${DU_IP}              ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${WEBUI_USER}      ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${WEBUI_PASSWORD}  ${tl.gnbs[0].cu.oam_http_connection_details.password}
# ${MRBTS_ID}            ${tl.gnbs[0].instance_id}
# ${Galileo_only}     actGalileo
# ${Galileo_name}    galileoState
# ${QZSS_only}        actQzss
# ${QZSS_name}       qzssState
# ${GPS_only}        actGps
# ${GPS_name}        gpsState
# ${GNSSmode}        MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/GNSSE-1
# 
# *** Test Cases ***
# [1]CB005695-B-001_AYGD_the_mode_validation_after_the_GNSS_set_different_modes
#     [Tags]    CB005694_B_ASIB       CRT_trunk    CRT_22R4
#     [Setup]
#     Run Keyword And Continue On Failure    Change gnssControlMode        Galileo_valueL=true     GPS_valueL=false
#     ...    QZSS_valueL=false     Galileo_state=Enabled      GPS_state=Disabled     QZSS_state=Disabled
#     Run Keyword And Continue On Failure    Change gnssControlMode     Galileo_valueL=false    GPS_valueL=true
#     ...    QZSS_valueL=true      Galileo_state=Disabled      GPS_state=Enabled     QZSS_state=Enabled
#     Run Keyword And Continue On Failure    Change gnssControlMode    Galileo_valueL=true     GPS_valueL=true
#     ...    QZSS_valueL=false     Galileo_state=Enabled      GPS_state=Enabled    QZSS_state=Disabled
#     [Teardown]    Case Teardown
# 
# [1]CB005695-B-004_AYGD_new_counters_of_Galileo_and_QZSS_checking_based_on_the_related_constellation
#    [Tags]    CB005694_B_ASIK    CRT_22R1
#    Change parameter    Galileo_valueL=false     Galileo_state=Disabled
#    Wait for counter to be gathered after guard peroid         interval=15
#    Change parameter    Galileo_valueL=true     Galileo_state=Enabled
#    ${counter_list}     Check New Counter Period    counter_id=M55800C00501
#    ${counter_value_sum}    set variable    ${0}
#    FOR    ${item}    IN    @{counter_list}
#        ${counter_value_sum}    evaluate    ${item}+${counter_value_sum}
#    END
#    Should be true     ${counter_value_sum}>${0}
#    [Teardown]    Case Teardown
# 
# *** Keywords ***
# Suite Setup
#     Input default SCF
# 
# Change gnssControlMode
#     [Arguments]     ${Galileo_valueL}    ${GPS_valueL}     ${QZSS_valueL}
#     ...    ${Galileo_state}     ${GPS_state}     ${QZSS_state}
#     ${connection}    CB005694_common_keyword.Rest Login DU
#     ${fault_name_list}     ${faultlist1}     Get Alarm Info     timeout=1
#     sort list    ${faultlist1}
#     perform muti Parameter recommissioning    dist_name=${GNSSmode}    parameter=${Galileo_only}     value=${Galileo_valueL}
#     ...    operation=update
#     perform muti Parameter recommissioning    dist_name=${GNSSmode}    parameter=${GPS_only}     value=${GPS_valueL}
#     ...    operation=update
#     perform muti Parameter recommissioning    dist_name=${GNSSmode}    parameter=${QZSS_only}     value=${QZSS_valueL}
#     ...    operation=update
#     CB005694_common_keyword.Disconnect from DU
#     sleep      60s
#     getPara and check    GNSSE_actual=${Galileo_name}    GNSSvalue=${Galileo_state}
#     getPara and check    GNSSE_actual=${GPS_name}    GNSSvalue=${GPS_state}
#     getPara and check    GNSSE_actual=${QZSS_name}    GNSSvalue=${QZSS_state}
#     Sleep    5min
#     ${connection}    CB005694_common_keyword.Rest Login DU
#     ${fault_name_list}     ${faultlist2}     Get Alarm Info     timeout=1
#     sort list    ${faultlist2}
#     ${status}=    run keyword and return status    lists should be equal    ${faultlist1}    ${faultlist2}
#     Run Keyword If    ${status}!=${True}    Collect snapshot coam
#     should be equal   ${status}    ${True}
#     CB005694_common_keyword.Disconnect from DU
# 
# Change parameter
#     [Arguments]      ${Galileo_valueL}         ${Galileo_state}
#     ${connection}    CB005694_common_keyword.Rest Login DU
#     perform muti Parameter recommissioning    dist_name=${GNSSmode}    parameter=${Galileo_only}     value=${Galileo_valueL}
#     ...    operation=update
#     getPara and check    GNSSE_actual=${Galileo_name}    GNSSvalue=${Galileo_state}
# 
# 
# Case Teardown
#     CI_interface.Common Case Teardown
