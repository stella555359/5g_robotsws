# *** Settings ***
# Documentation     author: deng xueqin
# ...               contact: xueqin.deng@nokia-sbell.com
# ...               squad group: 5G_PZ_MMW_HZ_2_SG
# 
# 
# Suite Setup       Test Suite Setup
# Suite Teardown    Test Suite Teardown
# 
# Force Tags    RAN_5G    RAN_5G_TDD    SBTS00    CLOUD_5G_CLASSICAL_MTK_SA_ASILL_ABILB1_AEQU    STATE_SW_UPLOADED
# ...   PY36
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource          ./Resources/common_keyword.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# *** Variables ***
# 
# 
# *** Test Cases ***
# [1]CB006114-5G-A_04_Activation of the feature CB006114 in RuProtectEnabled mode from WebEM
#     [Documentation]    Activate of the feature CB006114 in RuProtectEnabled mode from WebEM
#     [Tags]    CIT
#     [Setup]   Case04 setup
#     Capture log on fhnet
#     Set actEcpriRuMPlaneSecurity value    act_ipsec_value=RuProtectEnabled
#     Wait until keyword succeeds    5 min    15 sec
#     ...    Check RU resetted
#     Wait until keyword succeeds    10 min    30 sec
#     ...    Du Check cell on air via WebUI without login
#     Stop capture log and download
#     Wait until keyword succeeds    3 min    3 sec
#     ...    Check IPSec established
#     [Teardown]    Test Case Teardown
# 
# [1]CB006114-5G-A_05_Activation of the feature CB006114 in RuProtectOptional mode from WebEM
#     [Documentation]    Activate of the feature CB006114 in RuProtectOptional mode from WebEM
#     [Tags]    CIT
#     [Setup]   Test Case Setup
#     Du login page via webUI
#     ${MRBTS-ID}    Get MRBTS Id in COAM WebEM
#     #Set IPSec Optional    plain_allowed_value=false    MRBTS-ID=${MRBTS-ID}
#     #selenium_coam.Reset Ru
#     #sleep    30s
#     #Wait until keyword succeeds    10 min    30 sec
#     #...    Du Check cell on air via WebUI without login
#     #Check IPSec established
#     Set IPSec Optional    plain_allowed_value=true    MRBTS-ID=${MRBTS-ID}
#     selenium_coam.Reset Ru
#     sleep    180s
#     Wait until keyword succeeds    10 min    30 sec
#     ...    Du Check cell on air via WebUI without login
#     Wait until keyword succeeds    3 min    3 sec
#     ...    Check IPSec established
#     [Teardown]    Test Case Teardown
# 
# [1]CB006114-5G-A_06_Deactivation of the feature CB006114 from WebEM
#     [Documentation]    Deactivate of the feature CB006114 in RuProtectEnabled mode from WebEM
#     [Tags]    CRT
#     [Setup]   Case06 setup
#     run keyword if    '${src_act_ipsec_value}'=='RuProtectDisabled'
#     ...    Check disable IPSec from WebEM
#     [Teardown]    Test Case Teardown
# 
# [1]CB006114-5G-A_09_IPSec_connection_establishment_between_RU_as_Initiator_and_DU_as_Responder
#     [Documentation]    Establishment of IPSec tunnel between RU and DU over eCPRI link to protect M-plane traffic
#     [Tags]    CIT
#     [Setup]   Test Case Setup
#     Check IKE process    pcap_file=${local_log_path}
#     [Teardown]    Test Case Teardown
# 
# *** Keywords ***
# Test Suite Setup
#     Sleep    600s
#     robot_common_operations.Common Suite Setup
#     #CI_interface.Common Suite Setup
#     SISO Coam Suite Setup
#     Du login page via webUI
#     #Du Check cell on air via WebUI without login
#     ${src_act_ipsec_value}    Get actEcpriRuMPlaneSecurity value
#     set global variable    ${src_act_ipsec_value}
#     #ssh.Reset_cache
#     csn.Connect to     hostname=${du_ip}    username=${du_username}    password=${du_password}    alias=DU
#     ${ru_ip_addr}    Get RU IP from config file
#     ${rlan0_ecpri_ip}    Get rlan0 ecpri ip
#     Set Suite Variable    ${ru_ip_addr}
#     Set Suite Variable    ${rlan0_ecpri_ip}
#     csn.disconnect    connection=DU
# 
# Test Suite Teardown
#     Run Keyword And Ignore Error   Set actEcpriRuMPlaneSecurity value    act_ipsec_value=${src_act_ipsec_value}
#     sleep    60s
#     #Wait until keyword succeeds    15 min    30 sec
#     #...    Du Check cell on air via WebUI without login
#     Run Keyword And Ignore Error     SISO Coam Suite Teardown
# 
# Case04 setup
#     #CI_interface.Common Case Setup
#     Test Case Setup
#     Du login page via webUI
#     run keyword if    '${src_act_ipsec_value}'!='RuProtectDisabled'
#     ...    Check disable IPSec from WebEM
#     
# Case06 setup
#     Test Case Setup
#     Du login page via webUI
#     run keyword if    '${src_act_ipsec_value}'!='RuProtectEnabled'
#     ...    Check enable IPSec from WebEM
# 
# Test Case Setup
#     #CI_interface.Common Case Setup
#     SISO Coam Test Setup
# 
# Test Case Teardown
#     #CI_interface.Common Case Teardown
#     SISO Coam Test Teardown
