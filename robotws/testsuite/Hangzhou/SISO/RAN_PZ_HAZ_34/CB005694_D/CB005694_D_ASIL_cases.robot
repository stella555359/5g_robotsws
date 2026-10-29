# *** Settings ***
# Force Tags    PY36
# Documentation     Suite description
# ...               author: chutian
# ...               contact: chun.tian@nokia-sbell.com
# ...               squad group: MMW_SG_04
# Suite Setup       Suite Setup
# Suite Teardown
# Resource          ../CB005694_A/resource/CB005694_common_keyword.robot
# Resource          ../CB005694_B/resource/CB005694_B_resource.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# 
# 
# *** Variables ***
# ${DU_OAM_IP}              ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${DU_OAM_WEBUI_USER}      ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${DU_OAM_WEBUI_PASSWORD}  ${tl.gnbs[0].cu.oam_http_connection_details.password}
# ${MRBTS_ID}            ${tl.gnbs[0].instance_id}
# ${Galileo_only}     actGalileo
# ${Galileo_name}    galileoState
# ${Glonass_only}        actGlonass
# ${Glonass_name}       glonassState
# ${GPS_only}         actGps
# ${GPS_name}        gpsState
# ${Beidou_only}          actBeidou
# ${Beidou_name}      beidouState
# ${Qzss_only}      actQzss
# ${Qzss_name}       qzssState
# ${GNSSmode}         MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/GNSSE-1
# ${Actual_state1}     Enabled
# ${Actual_state2}     Disabled
# 
# *** Test Cases ***
# [1]CB005694-D-002_AYGE_the_mode_validation_after_the_GNSS_set_QZSS_related_modes
#     [Tags]    CB005694_D_ASIK      CRT_22R1
#     [Setup]
#     Change gnssControlMode
#     ...    Galileo_valueL=false      Glonass_valueL=false      GPS_valueL=true      Beidou_valueL=true        Qzss_valueL=true
#     ...    Galileo_state=Disabled    Glonass_state=Disabled     GPS_state=Enabled      Beidou_state=Enabled     Qzss_state=Enabled
#     Change gnssControlMode
#     ...    Galileo_valueL=false     Glonass_valueL=true      GPS_valueL=true      Beidou_valueL=true      Qzss_valueL=true
#     ...    Galileo_state=Disabled    Glonass_state=Enabled     GPS_state=Enabled     Beidou_state=Enabled    Qzss_state=Enabled
#     Change gnssControlMode
#     ...    Galileo_valueL=true     Glonass_valueL=false     GPS_valueL=true      Beidou_valueL=true     Qzss_valueL=false
#     ...    Galileo_state=Enabled    Glonass_state=Disabled     GPS_state=Enabled     Beidou_state=Enabled     Qzss_state=Disabled
#     [Teardown]    Case Teardown
# 
# [1]CB005694-D-003_AYGE_the_mode_validation_after_the_GNSS_set_Galileo-QZSS_mixed_modes
#      [Tags]    CB005694_D_ASIK      CRT_22R1      CRT_trunk    CRT_22R2
#     [Setup]
#     Change gnssControlMode
#     ...    Galileo_valueL=true      Glonass_valueL=false      GPS_valueL=true      Beidou_valueL=false       Qzss_valueL=true
#     ...    Galileo_state=Enabled    Glonass_state=Disabled     GPS_state=Enabled      Beidou_state=Disabled     Qzss_state=Enabled
#     Change gnssControlMode
#     ...    Galileo_valueL=true     Glonass_valueL=true      GPS_valueL=true     Beidou_valueL=false      Qzss_valueL=true
#     ...    Galileo_state=Enabled    Glonass_state=Enabled     GPS_state=Enabled     Beidou_state=Disabled    Qzss_state=Enabled
#     Change gnssControlMode
#     ...    Galileo_valueL=true     Glonass_valueL=false      GPS_valueL=true      Beidou_valueL=true     Qzss_valueL=true
#     ...    Galileo_state=Enabled    Glonass_state=Disabled     GPS_state=Enabled     Beidou_state=Enabled     Qzss_state=Enabled
#     Change gnssControlMode
#     ...    Galileo_valueL=true     Glonass_valueL=true     GPS_valueL=true     Beidou_valueL=true    Qzss_valueL=true
#     ...    Galileo_state=Enabled    Glonass_state=Enabled    GPS_state=Enabled     Beidou_state=Enabled     Qzss_state=Enabled
#     [Teardown]    Case Teardown
# 
# *** Keywords ***
# Suite Setup
#     Input default SCF
# 
# Change gnssControlMode
#     [Arguments]   ${Galileo_valueL}    ${GPS_valueL}     ${Beidou_valueL}   ${Glonass_valueL}    ${Qzss_valueL}
#     ...    ${Galileo_state}     ${GPS_state}     ${Glonass_state}   ${Beidou_state}   ${Qzss_state}
#     ${connection}    CB005694_common_keyword.Rest Login DU
#     ${fault_name_list}     ${faultlist1}     Get Alarm Info     timeout=1
#     sort list    ${faultlist1}
#     perform muti Parameter recommissioning    dist_name=${GNSSmode}    parameter=${Galileo_only}     value=${Galileo_valueL}
#     ...    operation=update
#      perform muti Parameter recommissioning    dist_name=${GNSSmode}    parameter=${Glonass_only}    value=${Glonass_valueL}
#     ...    operation=update
#     perform muti Parameter recommissioning    dist_name=${GNSSmode}    parameter=${GPS_only}     value=${GPS_valueL}
#     ...    operation=update
#     perform muti Parameter recommissioning    dist_name=${GNSSmode}    parameter=${Beidou_only}     value=${Beidou_valueL}
#     ...    operation=update
#     perform muti Parameter recommissioning    dist_name=${GNSSmode}    parameter=${Qzss_only}     value=${Qzss_valueL}
#     ...    operation=update
#     run keyword and ignore error    CB005694_common_keyword.Disconnect from DU
#     getPara and check    GNSSE_actual=${Galileo_name}    GNSSvalue=${Galileo_state}
#     getPara and check    GNSSE_actual=${Glonass_name}    GNSSvalue=${Glonass_state}
#     getPara and check    GNSSE_actual=${GPS_name}    GNSSvalue=${GPS_state}
#     getPara and check    GNSSE_actual=${Beidou_name}    GNSSvalue=${Beidou_state}
#     getPara and check    GNSSE_actual=${Qzss_name}    GNSSvalue=${Qzss_state}
#     run keyword and ignore error    CB005694_common_keyword.Disconnect from DU
#     Sleep    5min
#     ${connection}    CB005694_common_keyword.Rest Login DU
#     ${fault_name_list}     ${faultlist2}     Get Alarm Info     timeout=1
#     sort list    ${faultlist2}
#     ${status}=    run keyword and return status    lists should be equal    ${faultlist1}    ${faultlist2}
#     Run Keyword If    ${status}!=${True}    Collect snapshot coam
#     should be equal   ${status}    ${True}
#     [Teardown]    run keyword and ignore error    CB005694_common_keyword.Disconnect from DU
# 
# Case Teardown
#     Run Keyword And Ignore Error    CB005694_common_keyword.Disconnect from DU
#     CI_interface.Common Case Teardown