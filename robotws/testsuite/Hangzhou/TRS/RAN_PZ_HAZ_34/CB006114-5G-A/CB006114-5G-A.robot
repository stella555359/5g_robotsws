# *** Settings ***
# Force Tags    PY36
# Documentation     author: deng xueqin
# ...               contact: xueqin.deng@nokia-sbell.com
# ...               squad group: 5G_PZ_MMW_HZ_2_SG
# 
# 
# Suite Setup       Test Suite Setup
# Suite Teardown    Test Suite Teardown
# 
# Resource          Resources/common_keyword.robot
# 
# *** Variables ***
# 
# 
# *** Test Cases ***
# [1]CB006114-5G-A_04_Activation of the feature CB006114 in RuProtectEnabled mode from WebEM
#     [Documentation]    Activate of the feature CB006114 in RuProtectEnabled mode from WebEM
#     [Tags]
#     [Setup]   Case04 setup
#     Capture log on fhnet
#     Set actEcpriRuMPlaneSecurity value    act_ipsec_value=RuProtectEnabled
#     Wait until keyword succeeds    5 min    15 sec
#     ...    Check RU resetted    
#     Wait until keyword succeeds    10 min    30 sec
#     ...    Du Check cell on air via WebUI without login
#     Stop capture log and download
#     Check IPSec established
#     [Teardown]
# 
# [1]CB006114-5G-A_05_Activation of the feature CB006114 in RuProtectOptional mode from WebEM
#     [Documentation]    Activate of the feature CB006114 in RuProtectOptional mode from WebEM
#     [Tags]
#     ${MRBTS-ID}    Get MRBTS Id in COAM WebEM
#     #Set IPSec Optional    plain_allowed_value=false    MRBTS-ID=${MRBTS-ID}
#     #selenium_coam.Reset Ru
#     #sleep    30s
#     #Wait until keyword succeeds    10 min    30 sec
#     #...    Du Check cell on air via WebUI without login
#     #Check IPSec established
#     Set IPSec Optional    plain_allowed_value=true    MRBTS-ID=${MRBTS-ID}
#     selenium_coam.Reset Ru
#     sleep    30s
#     Wait until keyword succeeds    10 min    30 sec
#     ...    Du Check cell on air via WebUI without login
#     Check IPSec established
# 
# [1]CB006114-5G-A_06_Deactivation of the feature CB006114 from WebEM
#     [Documentation]    Deactivate of the feature CB006114 in RuProtectEnabled mode from WebEM
#     [Tags]
#     run keyword if    '${src_act_ipsec_value}'=='RuProtectDisabled'
#     ...    Check disable IPSec from WebEM
# 
# [1]CB006114-5G-A_09_IPSec_connection_establishment_between_RU_as_Initiator_and_DU_as_Responder
#     [Documentation]    Establishment of IPSec tunnel between RU and DU over eCPRI link to protect M-plane traffic
#     [Tags]
#     Check IKE process    pcap_file=${local_log_path}
#     
# *** Keywords ***
# Test Suite Setup
#     Du login page via webUI
#     Du Check cell on air via WebUI without login
#     ${src_act_ipsec_value}    Get actEcpriRuMPlaneSecurity value
#     set global variable    ${src_act_ipsec_value}    
#     ssh.Connect to     hostname=${du_ip}    username=${du_username}    password=${du_password}    alias=DU
#     ${ru_ip_addr}    Get RU IP from config file
#     ${rlan0_ecpri_ip}    Get rlan0 ecpri ip
#     Set Suite Variable    ${ru_ip_addr}
#     Set Suite Variable    ${rlan0_ecpri_ip}
#     ssh.disconnect    connection=DU
# 
# Test Suite Teardown
#     Set actEcpriRuMPlaneSecurity value    act_ipsec_value=${src_act_ipsec_value}
#     sleep    60s
#     Wait until keyword succeeds    15 min    30 sec
#     ...    Du Check cell on air via WebUI without login
# 	Run Keyword And Ignore Error    DU COAM selenium logout
# 
# Case04 setup
#     run keyword if    '${src_act_ipsec_value}'!='RuProtectDisabled'
#     ...    Check disable IPSec from WebEM
# 
