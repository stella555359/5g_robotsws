# *** Settings ***
# Documentation     Suite description
# ...               author: chutian
# ...               contact: chun.tian@nokia-sbell.com
# ...               squad group: MMW_SG_04
# 
# Force Tags        SBTS00   RAN_5G   RAN_5G_TDD    CRT_UTE   CLOUD_5G_CLASSICAL_ANDROID_ASILR_ABIOB4_AEQE_ENB   STATE_SW_UPLOADED
# ...    PY36
# 
# Suite Setup       CI_interface.Common Suite Setup
# Suite Teardown
# 
# Resource          ../CB005694_A/resource/CB005694_common_keyword.robot
# Resource          ./resource/CB005694_common_resource.robot
# Resource          testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007608_B-573/Resources/5GC000573_common_keyword.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# 
# *** Variables ***
# ${DU_OAM_IP}              ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${DU_OAM_WEBUI_USER}      ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${DU_OAM_WEBUI_PASSWORD}  ${tl.gnbs[0].cu.oam_http_connection_details.password}
# ${MRBTS_ID}            ${tl.gnbs[0].instance_id}
# ${Galileo_only}     actGalileo
# ${Galileo_name}    galileoState
# ${QZSS_only}        actQzss
# ${QZSS_name}       qzssState
# ${GPS_only}         actGps
# ${GPS_name}        gpsState
# ${GNSSmode}         MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/GNSSE-1
# ${Actual_state1}     Enabled
# ${Actual_state2}     Disabled
# ${Glonass_only}        actGlonass
# ${Glonass_name}       glonassState
# ${Beidou_only}          actBeidou
# ${Beidou_name}      beidouState
# 
# 
# *** Test Cases ***
# [1]CB005694-B-004_AYGE_new_counters_of_Galileo_and_QZSS_checking_based_on_the_related_constellation
#    [Tags]
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
# [1]CB005694-D-002_AYGE_the_mode_validation_after_the_GNSS_set_QZSS_related_modes
#     [Tags]
#     Change gnssControlMode1
#     ...    Galileo_valueL=false      Glonass_valueL=false      GPS_valueL=true      Beidou_valueL=true        Qzss_valueL=true
#     ...    Galileo_state=Disabled    Glonass_state=Disabled     GPS_state=Enabled      Beidou_state=Enabled     Qzss_state=Enabled
#     Change gnssControlMode1
#     ...    Galileo_valueL=false     Glonass_valueL=true      GPS_valueL=true      Beidou_valueL=true      Qzss_valueL=true
#     ...    Galileo_state=Disabled    Glonass_state=Enabled     GPS_state=Enabled     Beidou_state=Enabled    Qzss_state=Enabled
#     Change gnssControlMode1
#     ...    Galileo_valueL=true     Glonass_valueL=false     GPS_valueL=true      Beidou_valueL=true     Qzss_valueL=false
#     ...    Galileo_state=Enabled    Glonass_state=Disabled     GPS_state=Enabled     Beidou_state=Enabled     Qzss_state=Disabled
#     [Teardown]    Case Teardown
