*** Settings ***
Documentation    ...
#Suite Setup       Suite Setup Update GNB
#Suite Teardown    Common Suite Teardown    debug
#Force Tags        CLOUD_5G_I_LO_AP_LO    SBTS00    CN1_SQ6    CNI110468    CRT    Owner_y7li    RAN_5G
#Resource          ./../CUDU_L2/common_setup_teardown.robot
##Resource          ./../5GC001917/5GC001917_Resource.robot
#
#*** Variables ***
##${RD_PARAM}                     0x590072=1;0x41001b=1;0x5900f1=1    # CP Debug
#${SCF_PATH}                     ${CURDIR}/Config
#${WTS_LOCAL}                    ${CURDIR}/Resources/wts
#${WTS_CFG}                      basic_setup_CNI110468.cfg
#${UE_ID}                        1
#${DL_DATA}                      1200
#${UL_DATA}                      100
#${DL_TPUT_TARGET}               600
#${UL_TPUT_TARGET}               50
#${FULL_SCF_CNI110468_103}       FULL_SCF_CNI110468_103.xml
#@{LOG_NAME_LIST}                snapshot    btsLog    sosreport
#@{LOG_NAME_SUITE_SETUP_ASIK}    snapshot
#${UEC_REACTION_TIME}            100
#${IPHY}                         ${CURDIR}/Resources/wts/iphy_CNI110468.xml
#@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
#
#*** Test Cases ***
#CNI110468_ET_103_MCS_Lower_Than_Threshold_With_Feature_Activate
#    [Tags]    Owner_xxx    CRT
#    Run Keywords    Test Setup Update GNB    scf_file=${FULL_SCF_CNI110468_103}    iphy_file=${IPHY}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG}
#    ...    AND    Suite Setup Start WTS And Check OnAir With Egate Log
#    ...    AND    Common Test Setup
#    Override The Rank    2    2
#    CUDU L2 Send Action To GNB    ${UE_ID}    csi_override    activate    2
#    Set SRS Testmode    profile_id=3    init_pos=0
#    CUDU L2 Send Action To GNB    ${UE_ID}    ue_srs_beam_pos    activate    3
#    SA Single UE Attach    ${UE_ID}
#    Start SA UE Big DL Traffic Internal    ${UE_ID}    ${DL_DATA}
#    Start SA UE Big UL Traffic Internal    ${UE_ID}    ${UL_DATA}
#    Sleep    3s    reason=wait T-put stable
#    SA Check UE Cell TPut On Target    ${UE_ID}    1    dl    ${DL_TPUT_TARGET}
#    SA Check UE Cell TPut On Target    ${UE_ID}    1    ul    ${UL_TPUT_TARGET}
#    Start Ttitrace With Streaming Mode
#    Sleep    1s    reason=capture short ttitracelog
#    Stop Ttitrace    l2stream3_ttitrace    ${TEST_LOG_DIRECTORY}/ttitrace_streaming/4
#    Override The MCS    1    20
#    CUDU L2 Send Action To GNB    ${UE_ID}    bler    activate    1
#    Sleep    5s    reason=wait BLER stable
#    Start Ttitrace With Streaming Mode
#    Sleep    1s    reason=capture short ttitracelog
#    Stop Ttitrace    l2stream3_ttitrace    ${TEST_LOG_DIRECTORY}/ttitrace_streaming/1
#    CUDU L2 Send Action To GNB    ${UE_ID}    bler    deactivate    1
#    Delete The MCS Override    1
#    Sleep    5s    reason=wait no BLER stable
#    Start Ttitrace With Streaming Mode
#    Sleep    1s    reason=capture short ttitracelog
#    Stop Ttitrace    l2stream3_ttitrace    ${TEST_LOG_DIRECTORY}/ttitrace_streaming/2
#    Override The MCS    1    20
#    CUDU L2 Send Action To GNB    ${UE_ID}    bler    activate    1
#    Sleep    5s    reason=wait BLER stable
#    Start Ttitrace With Streaming Mode
#    Sleep    1s    reason=capture short ttitracelog
#    Stop Ttitrace    l2stream3_ttitrace    ${TEST_LOG_DIRECTORY}/ttitrace_streaming/3
#    Decode Ttitrace Log    ${TEST_LOG_DIRECTORY}/ttitrace_streaming/1
#    Decode Ttitrace Log    ${TEST_LOG_DIRECTORY}/ttitrace_streaming/2
#    Decode Ttitrace Log    ${TEST_LOG_DIRECTORY}/ttitrace_streaming/3
#    Decode Ttitrace Log    ${TEST_LOG_DIRECTORY}/ttitrace_streaming/4
#    CUDU L2 Send Action To GNB    ${UE_ID}    bler    deactivate    1
#    Delete The MCS Override    1
#    CUDU L2 Send Action To GNB    ${UE_ID}    csi_override    deactivate    2
#    Delete The Rank Override    2
#    CUDU L2 Send Action To GNB    ${UE_ID}    ue_srs_beam_pos    deactivate    3
#    Delete The SRS beam    3
#    Check Log With Au2anlysis    ${CURDIR}/A2A/CNI110468_103.ini
#    ...    i    save_log_directory=${TEST_LOG_DIRECTORY}/ttitrace_streaming/
#
#    [Teardown]    Common Test Teardown
#
#**** Keywords ****
#Override The Rank
#    [Arguments]    ${profile_id}    ${ri}
#	ute_wtssim.Execute Egate Command    cmd=csi_override_testmode_nr profile_id\=${profile_id} cqi_mode=fixed cqi=15 ri_mode=fixed ri\=${ri}
#
#Delete The Rank Override
#    [Arguments]    ${profile_id}
#    ute_wtssim.Execute Egate Command    cmd=csi_override_testmode_nr profile_id\=${profile_id} delete=on
#
#Override The MCS
#    [Arguments]    ${profile_id}    ${mcs}
#    ute_wtssim.Execute Egate Command    cmd=bler_testmode_nr profile_id\=${profile_id} target_mcs\=${mcs}
#
#Delete The MCS Override
#    [Arguments]    ${profile_id}
#    ute_wtssim.Execute Egate Command    cmd=bler_testmode_nr profile_id\=${profile_id} delete=on
#
#Delete The SRS beam
#    [Arguments]    ${profile_id}
#    ute_wtssim.Execute Egate Command    cmd=ue_srs_beam_pos_nr profile_id\=${profile_id} delete=on
