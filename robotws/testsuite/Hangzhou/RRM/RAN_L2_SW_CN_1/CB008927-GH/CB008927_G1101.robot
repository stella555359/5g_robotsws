*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_CB008927_G1101}    iphy_file=${IPHY}    swconfig_param=${SWCONFIG_PARAM}
#...                        AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG}
#...                        AND    Suite Setup Start WTS And Check OnAir With Egate Log
#Test Setup        Common Test Setup
#Suite Teardown    Common Suite Teardown
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    SBTS00    ST_SG11    CB008927
#Resource          ../CUDU_L2/common_setup_teardown.robot
#Resource          ./Resources/CB008927_G_H_Resource.robot
#
#
#*** Variables ***
#### Suite level ###
#${SWCONFIG_PARAM}               0x58090b=1;0x5806df=12
#${SCF_PATH}                     ${CURDIR}/Config
#${WTS_CFG}                      CB008927_H.cfg
#${WTS_LOCAL}                    ${CURDIR}/Resources/wts
#${IPHY}                         ${CURDIR}/Resources/wts/iphy_CB008927_G_H.xml
#@{LOG_NAME_LIST}                snapshot    btsLog
#@{LOG_NAME_SUITE_SETUP_ASIK}    snapshot
#${UEC_REACTION_TIME}            100
#### G1101 ###
#${FULL_CB008927_G1101}       Full_SCF_CB008927_G1101.xml
#${DL_DATA_001}              1
#${UL_DATA_001}              1
#${DL_DATA_002}              1
#${UL_DATA_002}              1
#${DL_DATA_003}              100
#${UL_DATA_003}              10
#@{ALL_UE_LIST}              @{MUILTI_UELIST1}    @{MUILTI_UELIST2}      @{MUILTI_UELIST3}
#@{MUILTI_UELIST1}           31    32    33    34    35
#@{MUILTI_UELIST2}           41    42    43    44    45
#@{MUILTI_UELIST3}           51    52    53    54    55
#${FILTER}                       uldata_puschreceivereq
#@{COLUMN}                       UlData_puschReceiveReqGrant_t.ulDmrsMappingType
#${NIDD_NAME_DIST}                 MRBTS-1/NRBTS-1/NRCELL-3
#${NIDD_PARAMETER}              actVoNRIncCodingGain
#${A2A_G1101_NAME}              CB008927_G1101.ini
#${A2A_PATH_G1101}              G1101
#@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
#
#
#*** Test Cases ***
#CB008927-ET-G1101_Verify_Increased_Coding_Gain_For_DL_Harq_Retrans_By_Allocating_MorePRBs_And_Reserved_MCS_For_VONR_UEs_With_DL_Rat1
#    [Tags]    Owner_zbu    CRT
#    SA Multi NonCA UE Attach    ${ALL_UE_LIST}
#    Setup Multi UE GBR And Start DL UL Traffic    ${MUILTI_UELIST2}    3    3    ${DL_DATA_001}    ${UL_DATA_001}
#    Setup Multi UE GBR And Start DL UL Traffic    ${MUILTI_UELIST3}    4    3    ${DL_DATA_002}    ${UL_DATA_002}
#    SA Multi UE Start DL And UL Traffic    ${MUILTI_UELIST2}    ${DL_DATA_003}    ${UL_DATA_003}
#    Start And Stop Tti Trace        ${TEST_LOG_DIRECTORY}/ttitrace_streaming/1
#    SA Multi UE Start DL And UL Traffic    ${MUILTI_UELIST2}    ${DL_DATA_003}    ${UL_DATA_003}
#    Online Change NIDD Parameter    dist_name=${NIDD_NAME_DIST}    parameter=${NIDD_PARAMETER}    value=true
#    Start And Stop Tti Trace        ${TEST_LOG_DIRECTORY}/ttitrace_streaming/2
#    SA Multi UE Start DL And UL Traffic    ${MUILTI_UELIST2}    ${DL_DATA_002}    ${UL_DATA_002}
#    Override The MCS    1    22
#    Multi UE Testmode Change Action    ${MUILTI_UELIST2}    bler    activate    1
#    Sleep    5s    reason=wait BLER stable
#    Start And Stop Tti Trace        ${TEST_LOG_DIRECTORY}/ttitrace_streaming/3
#    Multi UE Testmode Change Action    ${MUILTI_UELIST2}    bler    deactivate    1
#    Delete The MCS Override    1
#    Decode TTITRACE LATEST LOG
#    A2A Check TTI Log     ${A2A_G1101_NAME}    ${TEST_LOG_DIRECTORY}/ttitrace_streaming/3      ${A2A_PATH_G1101}
#
#
#
#*** Keywords ***
#Online Change NIDD Parameter
#    [Arguments]    ${dist_name}    ${parameter}    ${value}
#    COAM.Setup Admin
#    COAM.Perform Parameter Recommissioning
#    ...    dist_name=${dist_name}    parameter=${parameter}    operation=update    value=${value}    skip_parameter_relation_errors=True
#    [Teardown]    COAM.Teardown
#
#A2A Check TTI Log
#    [Arguments]    ${A2A_File_name}    ${TTI_LOG_Path}    ${A2A_PATH}
#    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A${/}${A2A_PATH}${/}${A2A_File_name}
#    ...    i    save_log_directory=${TTI_LOG_Path}
#
#Start And Stop Tti Trace
#    [Arguments]    ${ttitrace}
#    Start Ttitrace With Streaming Mode
#    Sleep    1s    reason=capture short ttitracelog
#    Stop Ttitrace    l2stream3_ttitrace    ${ttitrace}
#
#Decode TTITRACE LATEST LOG
#    Decode Ttitrace Log    ${TEST_LOG_DIRECTORY}/ttitrace_streaming/1
#    Decode Ttitrace Log    ${TEST_LOG_DIRECTORY}/ttitrace_streaming/2
#    Decode Ttitrace Log    ${TEST_LOG_DIRECTORY}/ttitrace_streaming/3
