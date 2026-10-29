# # Feature  5GC002478-A
# #########################################################################
# 
# *** Settings ***
# Documentation
# ...     Test Line Configuration is NSA type with one eNB and one gNB (classical BTS).
# ...     Keywords related to feature in file 5GC002478A_cOAM_keywords.robot
# 
# Library                     BuiltIn
# Library                     OperatingSystem
# Library                     Collections
# Library                     String
# Library                     ute_ue
# Library                     SSHLibrary                  WITH NAME    robssh
# Library                     taf.transport.ssh           WITH NAME    ssh
# Library                     taf.collectors.core         WITH NAME    core
# Library                     taf.collectors.tcpdump      WITH NAME    tcpdump
# 
# #Variables                   %{ABSTRACT_LIB_CONFIG}
# Resource                    ./5GC002478A_cOAM_keywords.robot
# #Resource                    ./5GC002478_A_Askey.robot
# Resource                    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
# Force Tags                  CRT_TRUNK    CRT_22R4    CRT_22R2    CRT_UTE    RAN_5G    RAN_5G_TDD
# ...    PY36
# ...    CLOUD_5G_CLASSICAL_ANDROID_ASILR_ABILB4_AEWD    STATE_SW_UPLOADED    SBTS00
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# #Suite Setup     robot_common_operations.Common Suite Setup
# Suite Setup      Run keywords      CI_interface.Common Suite Setup  AND  robot_common_operations.Common Suite Setup
# Suite Teardown   robot_common_operations.Common Suite Teardown
# Test Setup       robot_common_operations.Common Case Setup
# Test Teardown    robot_common_operations.Common Case Teardown
# 
# 
# 
# *** Variables ***
# # Setting of values from parameters in the file __init__.py
# ${ip_addr}          ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
# #${Log_directory}    /home/ute/robot_temporary
# 
# 
# 
# *** Test Cases ***
# [1][1.0] 5GC002478_A_01_Cell_deactivation_due_to_X2_link_locked_at_gNB
# 
#     Test Setup TC01
# 
#     gNB Get CellId and BTSId DN in SCF
#     Log to console        ${physCellId}
# 
# 
#     COAM.TC01 Check Preconditions
# 
# 
#     ssh.connect_to      hostname=${OAM_IP_GNB}    username=${DU_LOGIN}   password=${DU_PASSWORD}    alias=asik_master
#     Start To Capture pcap
#     ...                 host_ip=${X2_IP_ENB1}
#     ...                 filename_pcap=tcpdump_2478A-TC01-postcheck.pcap
#     ...                 connection=asik_master
# 
#     sleep   10s
# 
#     connect to COAM        ${OAM_IP_ENB1}
#     COAM Check and Set Parameter
# 	...         dist_name=MRBTS-${MRBTS_ID_ENB1}/LNBTS-${LNBTS_ID_ENB1}/LNADJGNB-${LNADJGNB_ID_ENB1}
#     ...         parameter=administrativeState
#     ...         parameterValue=locked
# 
# 	Log to console      X2 link to eNB1 is locked
#     COAM teardown
# 
# 
#     Check X2 lock failure       TC_id=2478A-TC01-postcheck      connection=asik_master
# 
#     ssh.disconnect       connection=asik_master
# 
#     COAM.TC01 Teardown
# 
# 
# [1][1.0] 5GC002478_A_08_Cell_deactivation_due_to_all_X2_links_unavailable
# 
#     Test Setup TC08
# 
# 
#     gNB Get CellId and BTSId DN in SCF
#     Log to console        ${physCellId}
# 
#     COAM.TC08 Check Preconditions
# 
#     connect to COAM        ${OAM_IP_ENB2}
#     COAM Check and Set Parameter
#     ...         dist_name=MRBTS-${MRBTS_ID_ENB2}/LNBTS-${LNBTS_ID_ENB2}/LNADJGNB-${LNADJGNB_ID_ENB2}
#     ...         parameter=administrativeState
#     ...         parameterValue=locked
# 	COAM teardown
# 
# 
#     COAM.TC08 Check Step A
# 
#     ssh.connect_to      hostname=${OAM_IP_GNB}    username=${DU_LOGIN}   password=${DU_PASSWORD}    alias=asik_master
#     Check NSA call                host_ip=${X2_IP_ENB1}
#     ...                             PCI=${physCellId}
#     ...                             TC_id=2478A-TC08-checkA
#     ...                             connection=asik_master
#     ssh.disconnect      connection=asik_master
# 
# 
#     ssh.connect_to      hostname=${OAM_IP_GNB}      username=${DU_LOGIN}        password=${DU_PASSWORD}
# 
#     Sctp Failure                    address_ip=${X2_IP_ENB1}
# 
# 	Log to console                  SCTP failure on X2 link to eNB1
#     COAM.TC08 Check Step B
# 
#     ssh.disconnect
#     Log to console                  TC08 Step B completed
# 
#     COAM.TC08 Teardown
# 
# 
# [1][1.0] 5GC002478_A_09_Cell_activation_when_at_least_one_X2_link_is_available
# 
#     Test Setup TC09
#     gNB Get CellId and BTSId DN in SCF
#     Log to console        ${physCellId}
# 
#     COAM.TC09 Check Preconditions
# 
# 
#     connect to COAM        ${OAM_IP_ENB1}
# 	COAM Check and Set Parameter
# 	...         dist_name=MRBTS-${MRBTS_ID_ENB1}/LNBTS-${LNBTS_ID_ENB1}/LNADJGNB-${LNADJGNB_ID_ENB1}
#     ...         parameter=administrativeState
#     ...         parameterValue=unlocked
#     COAM teardown
# 
#     COAM.TC09 Check Postconditions
# 
#     Log to console    TC09 Check Postconditions
# 
#     ssh.connect_to      hostname=${OAM_IP_GNB}    username=${DU_LOGIN}    password=${DU_PASSWORD}    alias=asik_master
# 
#     Check NSA call                  host_ip=${X2_IP_ENB1}
#     ...                             PCI=${physCellId}
#     ...                             TC_id=2478A-TC09-check
#     ...                             connection=asik_master
# 
#     ssh.disconnect    connection=asik_master
# 
#     Log to console    TC09 check call restared
# 
#     COAM.TC09 Teardown
# 
# 
# *** Keywords ***
# 
# COAM.TC01 Check Preconditions
# 
#   	power_ue.Prepare UE    ue_type=samsung
# 
# 
# 	connect to COAM        ${OAM_IP_ENB2}
#     COAM Check and Set Parameter
#     ...         dist_name=MRBTS-${MRBTS_ID_ENB2}/LNBTS-${LNBTS_ID_ENB2}/LNADJGNB-${LNADJGNB_ID_ENB2}
#     ...         parameter=administrativeState
#     ...         parameterValue=locked
# 	COAM teardown
# 
# 
#     ssh.connect_to      hostname=${OAM_IP_GNB}    username=${DU_LOGIN}    password=${DU_PASSWORD}   alias=asik_master
# 
#     Check NSA call                  host_ip=${X2_IP_ENB1}
#     ...                             PCI=${physCellId}
#     ...                             TC_id=2478A-TC01-precheck
#     ...                             connection=asik_master
# 
#     ssh.disconnect       connection=asik_master
# 
#     Log to console                  TC01 preconditions checked
# 	
#     sleep    30
# 	
# 	connect to COAM        ${OAM_IP_GNB}
# 	
#     COAM check_x2_is_locked    ${OAM_IP_ENB1}    available
# 	
# 	COAM check_x2_is_locked    ${OAM_IP_ENB2}    unavailable
# 	
# 	COAM teardown
# 	
#     Log to console                  TC01 preconditions checked
# 
# 
# COAM.TC01 Teardown
# 
#     connect to COAM        ${OAM_IP_ENB1}
# 	COAM Check and Set Parameter
# 	...         dist_name=MRBTS-${MRBTS_ID_ENB1}/LNBTS-${LNBTS_ID_ENB1}/LNADJGNB-${LNADJGNB_ID_ENB1}
#     ...         parameter=administrativeState
#     ...         parameterValue=unlocked
#     COAM teardown
# 	
#     connect to COAM        ${OAM_IP_ENB2}
#     COAM Check and Set Parameter
#     ...         dist_name=MRBTS-${MRBTS_ID_ENB2}/LNBTS-${LNBTS_ID_ENB2}/LNADJGNB-${LNADJGNB_ID_ENB2}
#     ...         parameter=administrativeState
#     ...         parameterValue=unlocked
# 	COAM teardown
# 
# 
# 
# COAM.TC08 Check Preconditions
# 
#     power_ue.Prepare UE    ue_type=samsung
# 
# 
#     connect to COAM        ${OAM_IP_ENB1}
# 	COAM Check and Set Parameter
# 	...         dist_name=MRBTS-${MRBTS_ID_ENB1}/LNBTS-${LNBTS_ID_ENB1}/LNADJGNB-${LNADJGNB_ID_ENB1}
#     ...         parameter=administrativeState
#     ...         parameterValue=unlocked
#     COAM teardown
# 
#     connect to COAM        ${OAM_IP_ENB2}
#     COAM Check and Set Parameter
#     ...         dist_name=MRBTS-${MRBTS_ID_ENB2}/LNBTS-${LNBTS_ID_ENB2}/LNADJGNB-${LNADJGNB_ID_ENB2}
#     ...         parameter=administrativeState
#     ...         parameterValue=unlocked
# 	COAM teardown
# 
#     connect to COAM        ${OAM_IP_GNB}
# 
#     COAM check_x2_is_locked    ${OAM_IP_ENB1}    available
# 
# 	COAM check_x2_is_locked    ${OAM_IP_ENB2}    available
# 
#     ${msg}    Run Keyword And Return Status      Expect Fault Should Present new    faultId=7308    connection=COAM
#     log        ${msg}
#     should be equal    '${msg}'    'False'
# 
# 	COAM teardown
#     Log to console                  TC08 preconditions checked
# 
# COAM.TC08 Check Step A
# 
#     connect to COAM        ${OAM_IP_GNB}
# 
#     COAM check_x2_is_locked    ${OAM_IP_ENB1}    available
# 
# 	COAM check_x2_is_locked    ${OAM_IP_ENB2}    unavailable
# 
# 	COAM teardown
# 
#     Log to console      check step A
# 
# COAM.TC08 Check Step B
# 
#     connect to COAM        ${OAM_IP_GNB}
# 
#     Wait Until Keyword Succeeds     5min     20s    COAM check_x2_is_locked    ${OAM_IP_ENB1}    unavailable
# 	#COAM check_x2_is_locked    ${OAM_IP_ENB1}    available
# 
# 	Wait Until Keyword Succeeds     5min     20s    COAM check_x2_is_locked    ${OAM_IP_ENB2}    unavailable
# 
# 	Wait Until Keyword Succeeds     10min     2min  Expect Fault Should Present new    faultId=7308    connection=COAM       alarmId=7107
# 
# 	COAM teardown
# 
# 	Log to console                  TC08 postconditions checked
# 
# 
# 
# COAM.TC08 Teardown
#     [Documentation]         TC08 Teardown:
#     connect to COAM        ${OAM_IP_ENB2}
#     COAM Check and Set Parameter
#     ...         dist_name=MRBTS-${MRBTS_ID_ENB2}/LNBTS-${LNBTS_ID_ENB2}/LNADJGNB-${LNADJGNB_ID_ENB2}
#     ...         parameter=administrativeState
#     ...         parameterValue=unlocked
# 	COAM teardown
# 
#     ssh.connect_to              hostname=${OAM_IP_GNB}      username=${DU_LOGIN}        password=${DU_PASSWORD}
# 
#     Sctp Recovery               address_ip=${X2_IP_ENB1}
# 
#     ssh.disconnect
#     sleep    120
#     Log to console      TC08 Test setup completed
# 
# 
# COAM.TC09 Check Preconditions
# 
#     power_ue.Prepare UE    ue_type=samsung
# 
#     connect to COAM        ${OAM_IP_GNB}
# 
#     Wait Until Keyword Succeeds     5min     20s    COAM check_x2_is_locked    ${OAM_IP_ENB1}    unavailable
# 
# 	Wait Until Keyword Succeeds     5min     20s    COAM check_x2_is_locked    ${OAM_IP_ENB2}    unavailable
# 
# 	COAM teardown
# 
#     Log to console      TC09 preconditions checked
# 
# 
# COAM.TC09 Check Postconditions
# 
#     connect to COAM        ${OAM_IP_GNB}
# 
#     Wait Until Keyword Succeeds     5min     20s    COAM check_x2_is_locked    ${OAM_IP_ENB1}    available
# 
# 	Wait Until Keyword Succeeds     5min     20s    COAM check_x2_is_locked    ${OAM_IP_ENB2}    unavailable
# 
# 	COAM teardown
# 
#     Log to console          TC09 postconditions checked
# 
# 
# 
# COAM.TC09 Teardown
#     [Documentation]         TC09 Teardown:
# 
#     ssh.connect_to              hostname=${OAM_IP_GNB}      username=${DU_LOGIN}        password=${DU_PASSWORD}
#     Sctp Recovery               address_ip=${X2_IP_ENB2}
#     ssh.disconnect
# 
# 
#     connect to COAM        ${OAM_IP_ENB1}
# 	COAM Check and Set Parameter
# 	...         dist_name=MRBTS-${MRBTS_ID_ENB1}/LNBTS-${LNBTS_ID_ENB1}/LNADJGNB-${LNADJGNB_ID_ENB1}
#     ...         parameter=administrativeState
#     ...         parameterValue=unlocked
#     COAM teardown
# 
#     connect to COAM        ${OAM_IP_ENB2}
#     COAM Check and Set Parameter
#     ...         dist_name=MRBTS-${MRBTS_ID_ENB2}/LNBTS-${LNBTS_ID_ENB2}/LNADJGNB-${LNADJGNB_ID_ENB2}
#     ...         parameter=administrativeState
#     ...         parameterValue=unlocked
# 	COAM teardown
# 
# 
#     Log to console      TC09 Test setup completed
# 
