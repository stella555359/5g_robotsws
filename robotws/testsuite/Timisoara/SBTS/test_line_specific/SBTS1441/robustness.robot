*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  RAN_MRAT  SRAN
...    SBTS00    STATE_SKIP_AGENT
Library           XML  use_lxml=True
Resource    ../../CIT/test_resources/CM_CABLE_SPEED_CHANGE.robot
Resource    ../../CIT/test_resources/SWM__SBTS_SOAM_rollback_to_SBTS_SOAM.robot
Resource    ../../CIT/test_resources/SWM__SW_download_and_activation__SBTS_to_SBTS.robot
Resource    ../../CIT/test_resources/STATE__Site_reset.robot
Resource    ../../CIT/test_resources/STATE__LTE_RAT_reset_from_ADMIN.robot
Resource    ../../FM/test_resources/FM__Recovery_whole_multiple_Link_Break.robot
Resource    ../../CIT/test_resources/STATE__sbts_block_unblock.robot
Resource    ../../CIT/test_resources/STATE__S1_lock_reset_unlock.robot
Resource    ../../FM/test_resources/FM__WCDMA_DSP_crash_RAT_recovery_reset.robot




Suite Setup      Set Library Search Order  coam   ute_admin   hran_frame_sbts_taf   hran_frame_sbts_siso   ca_CIT_general   ca_swm_general


*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${ENB_BUILD}    SBTS00_ENB_9999_211207_000006
${DISABLE_WATCHDOG}    ${TRUE}
${COMMISSIONING_PATH}
...  /home/ute/testline_configuration/10_18_UTESRANCLOUD1441/node1/BTS_CLOUD_SRAN_LWG_1ASIA_3ABIA_2AHEB_1AHED_3AHEGA_SBTS00.xml



*** Test Cases ***
[1]Automated__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Tags]    STOPONFAIL
    [Timeout]    14400
    [Setup]    Run Keywords    Set Test Variable    ${Target SW name}    ${None}
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    3600
    ...    AND    Set Test Variable    ${Ping loss timeout}    900
    ...    AND    Set Test Variable    ${Ping regain timeout}    1900
    ...    AND    Set Test Variable    ${onAir Check Number}    150
    ...    AND    Set Test Variable    ${First Cell On Air Timeout}    35
    ...    AND    Set Test Variable    ${Test Timeout}    120
    ...    AND    Modify Resource Search Order    SWM__SW_download_and_activation__SBTS_to_SBTS
    ...    AND    SWM__SW_download_and_activation__SBTS_to_SBTS.TC Setup

    Run  mkdir ${Target SW dir}
    Run  sudo chmod 777 ${Target SW dir} -R
    Run  wget files.ute.nsn-rdnet.net/builds/enb/base/${ENB_BUILD}/${ENB_BUILD}_release_BTSSM_downloadable.zip -P ${Target SW dir}
    TC__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    SWM__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__SWM__SBTS_SOAM_rollback_to_SBTS_SOAM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${PASSIVE_SW_STATE}    commissioned
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    30m
    ...    AND    Set Test Variable    ${CONNECTION_RESET_ON_DEMAND}    ${FALSE}
    ...    AND    Set Test Variable    ${PING_LOSS_TIMEOUT}    600
    ...    AND    Set Test Variable    ${PING_REGAIN_TIMEOUT}    600
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    Modify Resource Search Order    SWM__SBTS_SOAM_rollback_to_SBTS_SOAM
    ...    AND    SWM__SBTS_SOAM_rollback_to_SBTS_SOAM.TC Setup
    TC__SWM__SBTS_SOAM_rollback_to_SBTS_SOAM
    [Teardown]    Run Keywords    SWM__SBTS_SOAM_rollback_to_SBTS_SOAM.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  CIT Recover Test Line By Power Reset


[1]Automated__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Tags]    STOPONFAIL
    [Timeout]    14400
    [Setup]    Run Keywords    Set Test Variable    ${Target SW name}    ${None}
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    3600
    ...    AND    Set Test Variable    ${Ping loss timeout}    900
    ...    AND    Set Test Variable    ${Ping regain timeout}    1900
    ...    AND    Set Test Variable    ${onAir Check Number}    150
    ...    AND    Set Test Variable    ${First Cell On Air Timeout}    35
    ...    AND    Set Test Variable    ${Test Timeout}    120
    ...    AND    Modify Resource Search Order    SWM__SW_download_and_activation__SBTS_to_SBTS
    ...    AND    SWM__SW_download_and_activation__SBTS_to_SBTS.TC Setup

    Run  mkdir ${Target SW dir}
    Run  sudo chmod 777 ${Target SW dir} -R
    Run  wget files.ute.nsn-rdnet.net/builds/enb/base/${ENB_BUILD}/${ENB_BUILD}_release_BTSSM_downloadable.zip -P ${Target SW dir}
    TC__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    SWM__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__SWM__SBTS_SOAM_rollback_to_SBTS_SOAM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${PASSIVE_SW_STATE}    commissioned
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    30m
    ...    AND    Set Test Variable    ${CONNECTION_RESET_ON_DEMAND}    ${FALSE}
    ...    AND    Set Test Variable    ${PING_LOSS_TIMEOUT}    600
    ...    AND    Set Test Variable    ${PING_REGAIN_TIMEOUT}    600
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    Modify Resource Search Order    SWM__SBTS_SOAM_rollback_to_SBTS_SOAM
    ...    AND    SWM__SBTS_SOAM_rollback_to_SBTS_SOAM.TC Setup
    TC__SWM__SBTS_SOAM_rollback_to_SBTS_SOAM
    [Teardown]    Run Keywords    SWM__SBTS_SOAM_rollback_to_SBTS_SOAM.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  CIT Recover Test Line By Power Reset


[1]Automated__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Tags]    STOPONFAIL
    [Timeout]    14400
    [Setup]    Run Keywords    Set Test Variable    ${Target SW name}    ${None}
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    3600
    ...    AND    Set Test Variable    ${Ping loss timeout}    900
    ...    AND    Set Test Variable    ${Ping regain timeout}    1900
    ...    AND    Set Test Variable    ${onAir Check Number}    150
    ...    AND    Set Test Variable    ${First Cell On Air Timeout}    35
    ...    AND    Set Test Variable    ${Test Timeout}    120
    ...    AND    Modify Resource Search Order    SWM__SW_download_and_activation__SBTS_to_SBTS
    ...    AND    SWM__SW_download_and_activation__SBTS_to_SBTS.TC Setup

    Run  mkdir ${Target SW dir}
    Run  sudo chmod 777 ${Target SW dir} -R
    Run  wget files.ute.nsn-rdnet.net/builds/enb/base/${ENB_BUILD}/${ENB_BUILD}_release_BTSSM_downloadable.zip -P ${Target SW dir}
    TC__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    SWM__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__SWM__SBTS_SOAM_rollback_to_SBTS_SOAM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${PASSIVE_SW_STATE}    commissioned
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    30m
    ...    AND    Set Test Variable    ${CONNECTION_RESET_ON_DEMAND}    ${FALSE}
    ...    AND    Set Test Variable    ${PING_LOSS_TIMEOUT}    600
    ...    AND    Set Test Variable    ${PING_REGAIN_TIMEOUT}    600
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    Modify Resource Search Order    SWM__SBTS_SOAM_rollback_to_SBTS_SOAM
    ...    AND    SWM__SBTS_SOAM_rollback_to_SBTS_SOAM.TC Setup
    TC__SWM__SBTS_SOAM_rollback_to_SBTS_SOAM
    [Teardown]    Run Keywords    SWM__SBTS_SOAM_rollback_to_SBTS_SOAM.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  CIT Recover Test Line By Power Reset


[1]Automated__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Tags]    STOPONFAIL
    [Timeout]    14400
    [Setup]    Run Keywords    Set Test Variable    ${Target SW name}    ${None}
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    3600
    ...    AND    Set Test Variable    ${Ping loss timeout}    900
    ...    AND    Set Test Variable    ${Ping regain timeout}    1900
    ...    AND    Set Test Variable    ${onAir Check Number}    150
    ...    AND    Set Test Variable    ${First Cell On Air Timeout}    35
    ...    AND    Set Test Variable    ${Test Timeout}    120
    ...    AND    Modify Resource Search Order    SWM__SW_download_and_activation__SBTS_to_SBTS
    ...    AND    SWM__SW_download_and_activation__SBTS_to_SBTS.TC Setup

    Run  mkdir ${Target SW dir}
    Run  sudo chmod 777 ${Target SW dir} -R
    Run  wget files.ute.nsn-rdnet.net/builds/enb/base/${ENB_BUILD}/${ENB_BUILD}_release_BTSSM_downloadable.zip -P ${Target SW dir}
    TC__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    SWM__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__SWM__SBTS_SOAM_rollback_to_SBTS_SOAM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${PASSIVE_SW_STATE}    commissioned
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    30m
    ...    AND    Set Test Variable    ${CONNECTION_RESET_ON_DEMAND}    ${FALSE}
    ...    AND    Set Test Variable    ${PING_LOSS_TIMEOUT}    600
    ...    AND    Set Test Variable    ${PING_REGAIN_TIMEOUT}    600
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    Modify Resource Search Order    SWM__SBTS_SOAM_rollback_to_SBTS_SOAM
    ...    AND    SWM__SBTS_SOAM_rollback_to_SBTS_SOAM.TC Setup
    TC__SWM__SBTS_SOAM_rollback_to_SBTS_SOAM
    [Teardown]    Run Keywords    SWM__SBTS_SOAM_rollback_to_SBTS_SOAM.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  CIT Recover Test Line By Power Reset


[1]Automated__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Tags]    STOPONFAIL
    [Timeout]    14400
    [Setup]    Run Keywords    Set Test Variable    ${Target SW name}    ${None}
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    3600
    ...    AND    Set Test Variable    ${Ping loss timeout}    900
    ...    AND    Set Test Variable    ${Ping regain timeout}    1900
    ...    AND    Set Test Variable    ${onAir Check Number}    150
    ...    AND    Set Test Variable    ${First Cell On Air Timeout}    35
    ...    AND    Set Test Variable    ${Test Timeout}    120
    ...    AND    Modify Resource Search Order    SWM__SW_download_and_activation__SBTS_to_SBTS
    ...    AND    SWM__SW_download_and_activation__SBTS_to_SBTS.TC Setup

    Run  mkdir ${Target SW dir}
    Run  sudo chmod 777 ${Target SW dir} -R
    Run  wget files.ute.nsn-rdnet.net/builds/enb/base/${ENB_BUILD}/${ENB_BUILD}_release_BTSSM_downloadable.zip -P ${Target SW dir}
    TC__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    SWM__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order


[1][UUF4ALL]Site_reset_without_HWF_in_loop
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    60
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    Modify Resource Search Order    STATE__Site_reset
    ...    AND    STATE__Site_reset.TC Setup
    TC__STATE__Site_reset
    [Teardown]    Run Keywords    STATE__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  CIT Recover Test Line By Power Reset


[2][UUF4ALL]Site_reset_without_HWF_in_loop
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    60
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    Modify Resource Search Order    STATE__Site_reset
    ...    AND    STATE__Site_reset.TC Setup
    TC__STATE__Site_reset
    [Teardown]    Run Keywords    STATE__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  CIT Recover Test Line By Power Reset


[3][UUF4ALL]Site_reset_without_HWF_in_loop
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    60
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    Modify Resource Search Order    STATE__Site_reset
    ...    AND    STATE__Site_reset.TC Setup
    TC__STATE__Site_reset
    [Teardown]    Run Keywords    STATE__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  CIT Recover Test Line By Power Reset


[4][UUF4ALL]Site_reset_without_HWF_in_loop
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    60
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    Modify Resource Search Order    STATE__Site_reset
    ...    AND    STATE__Site_reset.TC Setup
    TC__STATE__Site_reset
    [Teardown]    Run Keywords    STATE__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order    
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  CIT Recover Test Line By Power Reset


[5][UUF4ALL]Site_reset_without_HWF_in_loop
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    60
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    Modify Resource Search Order    STATE__Site_reset
    ...    AND    STATE__Site_reset.TC Setup
    TC__STATE__Site_reset
    [Teardown]    Run Keywords    STATE__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  CIT Recover Test Line By Power Reset


[1]Automated__CM_CABLE_SPEED_CHANGE
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${TIMEOUT}    900
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    ...    AND    Modify Resource Search Order    CM_CABLE_SPEED_CHANGE
    ...    AND    CM_CABLE_SPEED_CHANGE.TC Setup
    TC__CM_Cable_Speed_Change
    [Teardown]    Run Keywords    CM_CABLE_SPEED_CHANGE.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  CIT Recover Test Line By Power Reset


[1]Automated__CM_CABLE_SPEED_CHANGE
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${TIMEOUT}    900
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    ...    AND    Modify Resource Search Order    CM_CABLE_SPEED_CHANGE
    ...    AND    CM_CABLE_SPEED_CHANGE.TC Setup
    TC__CM_Cable_Speed_Change
    [Teardown]    Run Keywords    CM_CABLE_SPEED_CHANGE.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  CIT Recover Test Line By Power Reset


[1]Automated__CM_CABLE_SPEED_CHANGE
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${TIMEOUT}    900
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    ...    AND    Modify Resource Search Order    CM_CABLE_SPEED_CHANGE
    ...    AND    CM_CABLE_SPEED_CHANGE.TC Setup
    TC__CM_Cable_Speed_Change
    [Teardown]    Run Keywords    CM_CABLE_SPEED_CHANGE.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  CIT Recover Test Line By Power Reset


[1]Automated__CM_CABLE_SPEED_CHANGE
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${TIMEOUT}    900
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    ...    AND    Modify Resource Search Order    CM_CABLE_SPEED_CHANGE
    ...    AND    CM_CABLE_SPEED_CHANGE.TC Setup
    TC__CM_Cable_Speed_Change
    [Teardown]    Run Keywords    CM_CABLE_SPEED_CHANGE.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  CIT Recover Test Line By Power Reset


[1]Automated__CM_CABLE_SPEED_CHANGE
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${TIMEOUT}    900
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    ...    AND    Modify Resource Search Order    CM_CABLE_SPEED_CHANGE
    ...    AND    CM_CABLE_SPEED_CHANGE.TC Setup
    TC__CM_Cable_Speed_Change
    [Teardown]    Run Keywords    CM_CABLE_SPEED_CHANGE.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  CIT Recover Test Line By Power Reset


[1]Automated__STATE__LTE_RAT_reset_from_ADMIN
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LTE_RAT_RESET_TIMEOUT}    3600
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    Modify Resource Search Order    STATE__LTE_RAT_reset_from_ADMIN
    ...    AND    STATE__LTE_RAT_reset_from_ADMIN.TC Setup
    TC__STATE__LTE_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  CIT Recover Test Line By Power Reset


[1]Automated__STATE__LTE_RAT_reset_from_ADMIN
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LTE_RAT_RESET_TIMEOUT}    3600
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    Modify Resource Search Order    STATE__LTE_RAT_reset_from_ADMIN
    ...    AND    STATE__LTE_RAT_reset_from_ADMIN.TC Setup
    TC__STATE__LTE_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  CIT Recover Test Line By Power Reset


[1]Automated__STATE__LTE_RAT_reset_from_ADMIN
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LTE_RAT_RESET_TIMEOUT}    3600
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    Modify Resource Search Order    STATE__LTE_RAT_reset_from_ADMIN
    ...    AND    STATE__LTE_RAT_reset_from_ADMIN.TC Setup
    TC__STATE__LTE_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  CIT Recover Test Line By Power Reset


[1]Automated__STATE__LTE_RAT_reset_from_ADMIN
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LTE_RAT_RESET_TIMEOUT}    3600
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    Modify Resource Search Order    STATE__LTE_RAT_reset_from_ADMIN
    ...    AND    STATE__LTE_RAT_reset_from_ADMIN.TC Setup
    TC__STATE__LTE_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  CIT Recover Test Line By Power Reset


[1]Automated__STATE__LTE_RAT_reset_from_ADMIN
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LTE_RAT_RESET_TIMEOUT}    3600
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    Modify Resource Search Order    STATE__LTE_RAT_reset_from_ADMIN
    ...    AND    STATE__LTE_RAT_reset_from_ADMIN.TC Setup
    TC__STATE__LTE_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  CIT Recover Test Line By Power Reset


[1]Automated__FM__Recovery_whole_multiple_Link_Break
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${NUMBER_OF_LOOPS}    6
    ...    AND    Set Test Variable    ${TIMEOUT_AFTER_RESTOR}    3600
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    ...    AND    Modify Resource Search Order    FM__Recovery_whole_multiple_Link_Break
    ...    AND    FM__Recovery_whole_multiple_Link_Break.TC Setup
    TC__FM__Recovery_whole_multiple_Link_Break
    [Teardown]    Run Keywords    FM__Recovery_whole_multiple_Link_Break.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  CIT Recover Test Line By Power Reset


[1]Automated__FM__Recovery_whole_multiple_Link_Break
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${NUMBER_OF_LOOPS}    6
    ...    AND    Set Test Variable    ${TIMEOUT_AFTER_RESTOR}    3600
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    ...    AND    Modify Resource Search Order    FM__Recovery_whole_multiple_Link_Break
    ...    AND    FM__Recovery_whole_multiple_Link_Break.TC Setup
    TC__FM__Recovery_whole_multiple_Link_Break
    [Teardown]    Run Keywords    FM__Recovery_whole_multiple_Link_Break.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  CIT Recover Test Line By Power Reset


[1]Automated__FM__Recovery_whole_multiple_Link_Break
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${NUMBER_OF_LOOPS}    6
    ...    AND    Set Test Variable    ${TIMEOUT_AFTER_RESTOR}    3600
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    ...    AND    Modify Resource Search Order    FM__Recovery_whole_multiple_Link_Break
    ...    AND    FM__Recovery_whole_multiple_Link_Break.TC Setup
    TC__FM__Recovery_whole_multiple_Link_Break
    [Teardown]    Run Keywords    FM__Recovery_whole_multiple_Link_Break.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  CIT Recover Test Line By Power Reset


[1]Automated__FM__Recovery_whole_multiple_Link_Break
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${NUMBER_OF_LOOPS}    6
    ...    AND    Set Test Variable    ${TIMEOUT_AFTER_RESTOR}    3600
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    ...    AND    Modify Resource Search Order    FM__Recovery_whole_multiple_Link_Break
    ...    AND    FM__Recovery_whole_multiple_Link_Break.TC Setup
    TC__FM__Recovery_whole_multiple_Link_Break
    [Teardown]    Run Keywords    FM__Recovery_whole_multiple_Link_Break.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  CIT Recover Test Line By Power Reset


[1]Automated__FM__Recovery_whole_multiple_Link_Break
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${NUMBER_OF_LOOPS}    6
    ...    AND    Set Test Variable    ${TIMEOUT_AFTER_RESTOR}    3600
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    ...    AND    Modify Resource Search Order    FM__Recovery_whole_multiple_Link_Break
    ...    AND    FM__Recovery_whole_multiple_Link_Break.TC Setup
    TC__FM__Recovery_whole_multiple_Link_Break
    [Teardown]    Run Keywords    FM__Recovery_whole_multiple_Link_Break.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  CIT Recover Test Line By Power Reset


[1]Automated__STATE__SBTS_block_unblock
    [Timeout]    14400 
    [Setup]    Run Keywords
    ...    Set Test Variable    ${CUSTOM_BLOCKED_BTS_DISTNAME}    
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT_BEFORE_BLOCK}    301
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT_AFTER_BLOCK}    301
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT_AFTER_UNBLOCK}    1200

    ...    AND    Set Test Variable    ${bts_host}    192.168.255.129
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    Modify Resource Search Order    STATE__sbts_block_unblock
    ...    AND    STATE__sbts_block_unblock.TC Setup
    TC__STATE__SBTS_block_unblock
    [Teardown]    Run Keywords    STATE__sbts_block_unblock.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  CIT Recover Test Line By Power Reset


[1]Automated__STATE__SBTS_block_unblock
    [Timeout]    14400 
    [Setup]    Run Keywords
    ...    Set Test Variable    ${CUSTOM_BLOCKED_BTS_DISTNAME}    
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT_BEFORE_BLOCK}    301
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT_AFTER_BLOCK}    301
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT_AFTER_UNBLOCK}    1200

    ...    AND    Set Test Variable    ${bts_host}    192.168.255.129
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    Modify Resource Search Order    STATE__sbts_block_unblock
    ...    AND    STATE__sbts_block_unblock.TC Setup
    TC__STATE__SBTS_block_unblock
    [Teardown]    Run Keywords    STATE__sbts_block_unblock.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  CIT Recover Test Line By Power Reset


[1]Automated__STATE__SBTS_block_unblock
    [Timeout]    14400 
    [Setup]    Run Keywords
    ...    Set Test Variable    ${CUSTOM_BLOCKED_BTS_DISTNAME}    
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT_BEFORE_BLOCK}    301
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT_AFTER_BLOCK}    301
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT_AFTER_UNBLOCK}    1200

    ...    AND    Set Test Variable    ${bts_host}    192.168.255.129
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    Modify Resource Search Order    STATE__sbts_block_unblock
    ...    AND    STATE__sbts_block_unblock.TC Setup
    TC__STATE__SBTS_block_unblock
    [Teardown]    Run Keywords    STATE__sbts_block_unblock.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  CIT Recover Test Line By Power Reset


[1]Automated__STATE__SBTS_block_unblock
    [Timeout]    14400 
    [Setup]    Run Keywords
    ...    Set Test Variable    ${CUSTOM_BLOCKED_BTS_DISTNAME}    
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT_BEFORE_BLOCK}    301
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT_AFTER_BLOCK}    301
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT_AFTER_UNBLOCK}    1200

    ...    AND    Set Test Variable    ${bts_host}    192.168.255.129
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    Modify Resource Search Order    STATE__sbts_block_unblock
    ...    AND    STATE__sbts_block_unblock.TC Setup
    TC__STATE__SBTS_block_unblock
    [Teardown]    Run Keywords    STATE__sbts_block_unblock.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  CIT Recover Test Line By Power Reset


[1]Automated__STATE__SBTS_block_unblock
    [Timeout]    14400 
    [Setup]    Run Keywords
    ...    Set Test Variable    ${CUSTOM_BLOCKED_BTS_DISTNAME}    
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT_BEFORE_BLOCK}    301
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT_AFTER_BLOCK}    301
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT_AFTER_UNBLOCK}    1200

    ...    AND    Set Test Variable    ${bts_host}    192.168.255.129
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    Modify Resource Search Order    STATE__sbts_block_unblock
    ...    AND    STATE__sbts_block_unblock.TC Setup
    TC__STATE__SBTS_block_unblock
    [Teardown]    Run Keywords    STATE__sbts_block_unblock.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  CIT Recover Test Line By Power Reset


[1]Automated__STATE__S1_Lock_Reset_Unlock
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LTE_STATES}
    ...    availabilityStatus=Online, blockingState=Unblocked, administrativeState=Unlocked, operationalState=Enabled
    ...    AND    Set Test Variable    ${LTE_STATES_S1_LOCKED}
    ...    availabilityStatus=Offline, blockingState=Unblocked, administrativeState=Unlocked, operationalState=Disabled
    ...    AND    Set Test Variable    ${WCDMA_STATES}
    ...    availabilityStatus=Online, blockingState=Unblocked, operationalState=Enabled, usageState=Active
    ...    AND    Set Test Variable    ${GSM_STATES}
    ...    administrativeState=Unlocked, availabilityStatus=Online, blockingState=Unblocked, operationalState=Enabled, usageState=Active
    ...    AND    Set Test Variable    ${RMOD_STATES}
    ...    administrativeState=Unlocked, availabilityStatus=Online, blockingState=Unblocked, operationalState=Enabled, usageState=Active
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    10
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    Modify Resource Search Order    STATE__S1_lock_reset_unlock
    ...    AND    STATE__S1_lock_reset_unlock.TC Setup
    TC__STATE__S1_Lock_Reset_Unlock
    [Teardown]    Run Keywords    STATE__S1_lock_reset_unlock.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  CIT Recover Test Line By Power Reset


[1]Automated__STATE__S1_Lock_Reset_Unlock
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LTE_STATES}
    ...    availabilityStatus=Online, blockingState=Unblocked, administrativeState=Unlocked, operationalState=Enabled
    ...    AND    Set Test Variable    ${LTE_STATES_S1_LOCKED}
    ...    availabilityStatus=Offline, blockingState=Unblocked, administrativeState=Unlocked, operationalState=Disabled
    ...    AND    Set Test Variable    ${WCDMA_STATES}
    ...    availabilityStatus=Online, blockingState=Unblocked, operationalState=Enabled, usageState=Active
    ...    AND    Set Test Variable    ${GSM_STATES}
    ...    administrativeState=Unlocked, availabilityStatus=Online, blockingState=Unblocked, operationalState=Enabled, usageState=Active
    ...    AND    Set Test Variable    ${RMOD_STATES}
    ...    administrativeState=Unlocked, availabilityStatus=Online, blockingState=Unblocked, operationalState=Enabled, usageState=Active
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    10
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    Modify Resource Search Order    STATE__S1_lock_reset_unlock
    ...    AND    STATE__S1_lock_reset_unlock.TC Setup
    TC__STATE__S1_Lock_Reset_Unlock
    [Teardown]    Run Keywords    STATE__S1_lock_reset_unlock.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  CIT Recover Test Line By Power Reset


[1]Automated__STATE__S1_Lock_Reset_Unlock
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LTE_STATES}
    ...    availabilityStatus=Online, blockingState=Unblocked, administrativeState=Unlocked, operationalState=Enabled
    ...    AND    Set Test Variable    ${LTE_STATES_S1_LOCKED}
    ...    availabilityStatus=Offline, blockingState=Unblocked, administrativeState=Unlocked, operationalState=Disabled
    ...    AND    Set Test Variable    ${WCDMA_STATES}
    ...    availabilityStatus=Online, blockingState=Unblocked, operationalState=Enabled, usageState=Active
    ...    AND    Set Test Variable    ${GSM_STATES}
    ...    administrativeState=Unlocked, availabilityStatus=Online, blockingState=Unblocked, operationalState=Enabled, usageState=Active
    ...    AND    Set Test Variable    ${RMOD_STATES}
    ...    administrativeState=Unlocked, availabilityStatus=Online, blockingState=Unblocked, operationalState=Enabled, usageState=Active
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    10
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    Modify Resource Search Order    STATE__S1_lock_reset_unlock
    ...    AND    STATE__S1_lock_reset_unlock.TC Setup
    TC__STATE__S1_Lock_Reset_Unlock
    [Teardown]    Run Keywords    STATE__S1_lock_reset_unlock.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  CIT Recover Test Line By Power Reset


[1]Automated__STATE__S1_Lock_Reset_Unlock
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LTE_STATES}
    ...    availabilityStatus=Online, blockingState=Unblocked, administrativeState=Unlocked, operationalState=Enabled
    ...    AND    Set Test Variable    ${LTE_STATES_S1_LOCKED}
    ...    availabilityStatus=Offline, blockingState=Unblocked, administrativeState=Unlocked, operationalState=Disabled
    ...    AND    Set Test Variable    ${WCDMA_STATES}
    ...    availabilityStatus=Online, blockingState=Unblocked, operationalState=Enabled, usageState=Active
    ...    AND    Set Test Variable    ${GSM_STATES}
    ...    administrativeState=Unlocked, availabilityStatus=Online, blockingState=Unblocked, operationalState=Enabled, usageState=Active
    ...    AND    Set Test Variable    ${RMOD_STATES}
    ...    administrativeState=Unlocked, availabilityStatus=Online, blockingState=Unblocked, operationalState=Enabled, usageState=Active
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    10
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    Modify Resource Search Order    STATE__S1_lock_reset_unlock
    ...    AND    STATE__S1_lock_reset_unlock.TC Setup
    TC__STATE__S1_Lock_Reset_Unlock
    [Teardown]    Run Keywords    STATE__S1_lock_reset_unlock.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  CIT Recover Test Line By Power Reset


[1]Automated__STATE__S1_Lock_Reset_Unlock
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LTE_STATES}
    ...    availabilityStatus=Online, blockingState=Unblocked, administrativeState=Unlocked, operationalState=Enabled
    ...    AND    Set Test Variable    ${LTE_STATES_S1_LOCKED}
    ...    availabilityStatus=Offline, blockingState=Unblocked, administrativeState=Unlocked, operationalState=Disabled
    ...    AND    Set Test Variable    ${WCDMA_STATES}
    ...    availabilityStatus=Online, blockingState=Unblocked, operationalState=Enabled, usageState=Active
    ...    AND    Set Test Variable    ${GSM_STATES}
    ...    administrativeState=Unlocked, availabilityStatus=Online, blockingState=Unblocked, operationalState=Enabled, usageState=Active
    ...    AND    Set Test Variable    ${RMOD_STATES}
    ...    administrativeState=Unlocked, availabilityStatus=Online, blockingState=Unblocked, operationalState=Enabled, usageState=Active
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    10
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    Modify Resource Search Order    STATE__S1_lock_reset_unlock
    ...    AND    STATE__S1_lock_reset_unlock.TC Setup
    TC__STATE__S1_Lock_Reset_Unlock
    [Teardown]    Run Keywords    STATE__S1_lock_reset_unlock.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  CIT Recover Test Line By Power Reset


[1]FM__WCDMA_DSP_crash_RAT_recovery_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    
    ...    AND    FM__WCDMA_DSP_crash_RAT_recovery_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__WCDMA_DSP_crash_RAT_recovery_reset
    TC__FM__WCDMA_DSP_crash_RAT_recovery_reset
    [Teardown]    Run Keywords    FM__WCDMA_DSP_crash_RAT_recovery_reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__WCDMA_DSP_crash_RAT_recovery_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    
    ...    AND    FM__WCDMA_DSP_crash_RAT_recovery_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__WCDMA_DSP_crash_RAT_recovery_reset
    TC__FM__WCDMA_DSP_crash_RAT_recovery_reset
    [Teardown]    Run Keywords    FM__WCDMA_DSP_crash_RAT_recovery_reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__WCDMA_DSP_crash_RAT_recovery_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    
    ...    AND    FM__WCDMA_DSP_crash_RAT_recovery_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__WCDMA_DSP_crash_RAT_recovery_reset
    TC__FM__WCDMA_DSP_crash_RAT_recovery_reset
    [Teardown]    Run Keywords    FM__WCDMA_DSP_crash_RAT_recovery_reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__WCDMA_DSP_crash_RAT_recovery_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    
    ...    AND    FM__WCDMA_DSP_crash_RAT_recovery_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__WCDMA_DSP_crash_RAT_recovery_reset
    TC__FM__WCDMA_DSP_crash_RAT_recovery_reset
    [Teardown]    Run Keywords    FM__WCDMA_DSP_crash_RAT_recovery_reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__WCDMA_DSP_crash_RAT_recovery_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    
    ...    AND    FM__WCDMA_DSP_crash_RAT_recovery_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__WCDMA_DSP_crash_RAT_recovery_reset
    TC__FM__WCDMA_DSP_crash_RAT_recovery_reset
    [Teardown]    Run Keywords    FM__WCDMA_DSP_crash_RAT_recovery_reset.TC Teardown
    ...    AND    Restore Resource Search Order
