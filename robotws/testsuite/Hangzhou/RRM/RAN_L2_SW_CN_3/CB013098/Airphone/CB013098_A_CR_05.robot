*** Settings ***
Documentation     Author: qianqian.ren@nokia-sbell.com
...
...               13098_vran_case

Test Timeout    180 minutes
Suite Setup    AiC Common Suite Setup
Suite Teardown     #AiC Common Suite Teardown
Test Setup    AiC Common Test Setup
Test Teardown     #AiC Common Test Teardown
Force Tags       AP    SBTS00    RAN_5G_TDD    RAN_5G
Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot
#Library     ./scripts/python/tti_stream_mode_convert.py    WITH NAME    TtiSMConvert

*** Variables ***
${UE_1}    1
${CONFIG_DIR_PATH}    ${CURDIR}/config
${DU_SCF}          vdu_scf.xml
${CU_SCF}          vcu_scf.xml
${AIRPHONE_NAME}      new_iphy.xml
${WTS_CFG}           basic_setup.cfg

*** Test Cases ***
CB013098-A-CR_05_GBR_call_ulRateThresholdVoN_and_trigger_BWP_switch
    AIC Perform Full Commission And Reach Onair DC    ${CONFIG_DIR_PATH}/${DU_SCF}
    ...    ${CONFIG_DIR_PATH}/${WTS_CFG}     ${CONFIG_DIR_PATH}/${CU_SCF}
    SA Register UE ${UE_1}
    Vonr Bear Setup
    Start GBR And NonGBR UL Data Check UE To Large BWP
    Reduce UL Data Check UE To PsBWP
    Online Change Parameter
    Recover UL Data And Check Ue Still PsBWP
    Big traffic To Trigger Large BWP



*** Keywords ***
SA Register UE ${UE_ID}
    Airphone SA Attach    ue_id=${UE_ID}
    Airphone Set Traffic Type    ${UE_ID}    1    internal
    Airphone Pdu Session Setup   ${UE_ID}    1    1    ${UE_ID}
    Wait '2s' for stabible
    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${UE_ID}   unzip=TRUE

Vonr Bear Setup
    sleep   5s
    airphone_execute_egate_command
    ...    ue_pdu_session_modify ue\=${UE_1} pdu\=1 qosflows_to_add\=2 by\=amf
    sleep   1s
    airphone_execute_egate_command
    ...    ue_pdu_session_modify ue\=${UE_1} pdu\=1 qosflows_to_add\=3 by\=amf
Start GBR And NonGBR UL Data Check UE To Large BWP
    airphone_execute_egate_command
    ...    trf_data_start ue\=${UE_1} pdu\=1 qfi\=3 trf_id\=1 kbps\=50 dir\=ul protocol\=udp
    airphone_execute_egate_command
    ...    trf_data_start ue\=${UE_1} pdu\=1 trf_id\=1 kbps\=50 dir\=ul protocol\=udp


Reduce UL Data Check UE To PsBWP
    Airphone_cleanup_egate_console_log
    airphone_execute_egate_command
    ...    trf_data_start ue\=${UE_1} pdu\=1 qfi\=3 trf_id\=1 kbps\=10 dir\=ul protocol\=udp
    airphone_execute_egate_command
    ...    trf_data_start ue\=${UE_1} pdu\=1 trf_id\=1 kbps\=10 dir\=ul protocol\=udp
    sleep   2s
    Check UE enter into psbwp

Online Change Parameter
    VDU Login  vdu_index=0
    vdu.perform_delta_recommissioning    delta_file=./JSON/13098_A_05_delta_scfc.json
    #Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
    VDU Logout

Recover UL Data And Check Ue Still PsBWP
    Airphone_cleanup_egate_console_log
    airphone_execute_egate_command
    ...    trf_data_start ue\=${UE_1} pdu\=1 qfi\=3 trf_id\=1 kbps\=50 dir\=ul protocol\=udp
    airphone_execute_egate_command
    ...    trf_data_start ue\=${UE_1} pdu\=1 trf_id\=1 kbps\=50 dir\=ul protocol\=udp
     sleep   2s
    Check there is no bwp change


Big traffic To Trigger Large BWP
     Airphone_cleanup_egate_console_log
     airphone_execute_egate_command
     ...    trf_data_start ue\=${UE_1} pdu\=1 qfi\=3 trf_id\=1 kbps\=50 dir\=ul protocol\=udp
     airphone_execute_egate_command
     ...    trf_data_start ue\=${UE_1} pdu\=1 trf_id\=1 kbps\=1200 dir\=ul protocol\=udp
     sleep   2s
    Check UE to large bwp

Check UE enter into psbwp
      airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_to_psbwp   unzip=TRUE
      airphone_execute_egate_command    sim_log_set flush
      ${content}    OperatingSystem.Get File    path=${TEST_LOG_DIRECTORY()}/All/egate_to_psbwp/egate_console.log
      ${to_psbwp}    Set Variable     Bwp switch received from bwpId 1 to 2
      ${match_list}     Get Regexp Matches    ${content}    ${to_psbwp}
      ${check_rst}    Get Length    ${match_list}
      Should Be True    ${check_rst}>=1

Check UE to large bwp
      airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_to_large_bwp   unzip=TRUE
      ${to_psbwp}    Set Variable     Bwp switch received from bwpId 2 to 1
      ${content}    OperatingSystem.Get File    path=${TEST_LOG_DIRECTORY()}/All/egate_to_large_bwp/egate_console.log
      ${match_list}     Get Regexp Matches    ${content}    ${to_psbwp}
      ${check_rst}    Get Length    ${match_list}
      Should Be True    ${check_rst}>=1

 Check there is no bwp change
      airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_no_bwp_change   unzip=TRUE
      ${to_psbwp}    Set Variable     Bwp switch received from bwpId 2 to 1
      ${content}    OperatingSystem.Get File    path=${TEST_LOG_DIRECTORY()}/All/egate_no_bwp_change/egate_console.log
      ${match_list}     Get Regexp Matches    ${content}    ${to_psbwp}
      ${check_rst}    Get Length    ${match_list}
      Should Be True    ${check_rst}==0
