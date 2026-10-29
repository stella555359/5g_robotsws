*** Settings ***
Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${Full_SCF_CB8927_H201}    iphy_file=${IPHY}    swconfig_param=${SWCONFIG_PARAM}
...                        AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG}
...                        AND    Suite Setup Start WTS And Check OnAir With Egate Log
Test Setup        Common Test Setup
Suite Teardown    Common Suite Teardown
Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_I_BOO_AP_LOO    SBTS00    ST_SG11    CB008927
Resource          ../CUDU_L2/common_setup_teardown.robot
Resource          ./Resources/CB008927_G_H_Resource.robot


*** Variables ***
### Suite level ###
${SWCONFIG_PARAM}               0x58057a=3;0x580582=8;0x58090b=1;0x5806df=12;0x58064f=0x82;0x580345=1;0x58057b=0x10000
${SCF_PATH}                     ${CURDIR}/Config
${WTS_CFG}                      CB008927_H.cfg
${WTS_LOCAL}                    ${CURDIR}/Resources/wts
${IPHY}                         ${CURDIR}/Resources/wts/iphy_CB008927_G_H.xml
@{LOG_NAME_LIST}                snapshot    btsLog
@{LOG_NAME_SUITE_SETUP_ASIK}    snapshot
${UEC_REACTION_TIME}            100
### H201 ###
${Full_SCF_CB8927_H201}       Full_SCF_CB008927_H201.xml
${DL_DATA_001}              1
${UL_DATA_001}              1
${DL_DATA_002}              10
${UL_DATA_002}              1
${DL_DATA_003}              100
${UL_DATA_003}              1
@{ALL_UE_LIST}               1    2    3    4    5    6
@{UE_LIST_1}               1    2
@{UE_LIST_2}               3    4
@{UE_LIST_3}               5    6
&{COUNTER_1}                counter_id=M55308C00092    counter_path=CELLS/NRCELL-3/NCELA    min_value=150    max_value=220
&{COUNTER_2}                counter_id=M55308C00093    counter_path=CELLS/NRCELL-3/NCELA    min_value=1
&{COUNTER_3}                counter_id=M55365C00011    counter_path=CELLS/NRCELL-3/PDCCH2    min_value=1
@{COUNTER_ID_LIST_1}        ${COUNTER_1}    ${COUNTER_2}    ${COUNTER_3}
${TARGET001_TP_DL}                 1
${TARGET001_TP_UL}                 1
${TARGET002_TP_DL}                 10
${TARGET002_TP_UL}                 1
${TARGET003_TP_DL}                 100
${TARGET003_TP_UL}                 1
${TPUT_RATE}                       0.35
@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}

*** Test Cases ***
CB008927-ET-H201_Verify_Start_PRB_Randomization_UseDedicatedBwp_With_Multi_Dedicated_BWP_And_Multi_PDSCH_SubArea
    [Tags]    Owner_xxx    CRT
    SA Multi NonCA UE Attach    ${ALL_UE_LIST}  
    Setup Multi UE GBR And Start DL UL Traffic    ${UE_LIST_1}    3    3    ${DL_DATA_001}    ${UL_DATA_001}
    Setup Multi UE GBR And Start DL UL Traffic    ${UE_LIST_2}    4    3    ${DL_DATA_002}    ${UL_DATA_002}
    SA Multi UE Start DL And UL Traffic    ${UE_LIST_3}    ${DL_DATA_003}    ${UL_DATA_003}
    Override The MCS    1    10
    CUDU L2 Send Action To GNB    5    bler    activate    1
    CUDU L2 Send Action To GNB    6    bler    activate    1
    Sleep    5s    reason=wait BLER stable  
    CUDU L2 Send Action To GNB    5    bler    deactivate    1
    CUDU L2 Send Action To GNB    6    bler    deactivate    1
    Delete The MCS Override    1
    Start And Stop Tti Trace        ${TEST_LOG_DIRECTORY}/ttitrace_streaming/201
    Decode Ttitrace Log    ${TEST_LOG_DIRECTORY}/ttitrace_streaming/201
    Check Non CA UE DL UL Tput With In Range    1    2    ${TARGET001_TP_DL}    ${TARGET001_TP_UL}    ${TPUT_RATE}
#    Check Non CA UE DL UL Tput With In Range    3    4    ${TARGET002_TP_DL}    ${TARGET002_TP_UL}    ${TPUT_RATE}
#    Check Non CA UE DL UL Tput With In Range    5    6    ${TARGET003_TP_DL}    ${TARGET003_TP_UL}    ${TPUT_RATE}
#    Wait Until Keyword Succeeds     10min    3min     Check Multi PM Counters Latest Value From Admin    ${COUNTER_ID_LIST_1}
    [Teardown]    Common Test Teardown

*** Keywords ***
Start And Stop Tti Trace
    [Arguments]    ${ttitrace}
    Start Ttitrace With Streaming Mode
    Sleep    1s    reason=capture short ttitracelog
    Stop Ttitrace    l2stream3_ttitrace    ${ttitrace}
