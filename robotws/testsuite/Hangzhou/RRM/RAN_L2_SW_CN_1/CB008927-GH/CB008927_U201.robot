*** Settings ***
Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${Full_SCF_CB8927_H201}    iphy_file=${IPHY}    swconfig_param=${SWCONFIG}
...                        AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG}
...                        AND    Suite Setup Start WTS And Check OnAir With Egate Log
Test Setup        Common Test Setup
Suite Teardown    Common Suite Teardown
Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_I_LO_AP_LO    SBTS00    ST_SG11    CB008927
Resource          ../CUDU_L2/common_setup_teardown.robot
Resource          ./Resources/CB008927_G_H_Resource.robot


*** Variables ***
### Suite level ###
${SWCONFIG}               0x58057a=3;0x580582=8;0x58090b=1;0x5806df=12;0x58064f=0x82;0x580345=1;0x58057b=0x10000;0x58057f=256;0x580340=1;0x580954=1
${SCF_PATH}                     ${CURDIR}/Config
${WTS_CFG}                      CB008927_U.cfg
${WTS_LOCAL}                    ${CURDIR}/Resources/wts
${IPHY}                         ${CURDIR}/Resources/wts/iphy_CB008927_U201.xml
@{LOG_NAME_LIST}                snapshot    btsLog
@{LOG_NAME_SUITE_SETUP_ASIK}    snapshot
${UEC_REACTION_TIME}            100
### H201 ###
${Full_SCF_CB8927_H201}       Full_SCF_CB008927_U201.xml
${DL_DATA_001}              175
${UL_DATA_001}              10
${DL_DATA_002}              1
${UL_DATA_002}              1
${DL_DATA_003}              20
${UL_DATA_003}              1
@{ALL_UE_LIST}               @{UE_LIST_1}    @{UE_LIST_2}    @{UE_LIST_3}  
@{UE_LIST_1}               11    12    21    22    31    32
@{UE_LIST_2}               13    23    33    
@{UE_LIST_3}               15    25    35
@{BLER_UE_LIST}            11    21    13    15
&{COUNTER_1}                counter_id=M55308C00092    counter_path=CELLS/NRCELL-1/NCELA    min_value=79    max_value=200
&{COUNTER_2}                counter_id=M55308C00093    counter_path=CELLS/NRCELL-1/NCELA    min_value=1
&{COUNTER_3}                counter_id=M55365C00011    counter_path=CELLS/NRCELL-1/PDCCH2    min_value=1
@{COUNTER_ID_LIST_1}        ${COUNTER_1}    ${COUNTER_2}    ${COUNTER_3}
${TARGET001_TP_DL}          175
${TARGET001_TP_UL}          10
${TPUT_RATE}                0.9
${TARGET002_TP_DL}          1
${TARGET002_TP_UL}          1
${TARGET003_TP_DL}          20
${TARGET003_TP_UL}          1
@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}

*** Test Cases ***
CB008927-ET-H201_Verify_Start_PRB_Randomization_UseDedicatedBwp_With_Multi_Dedicated_BWP_And_Multi_PDSCH_SubArea
    [Tags]    Owner_zbu    CRT
    SA Multi NonCA UE Attach    ${ALL_UE_LIST}  
    Setup Multi UE GBR And Start DL UL Traffic    ${UE_LIST_2}    3    3    ${DL_DATA_002}    ${UL_DATA_002}
    Setup Multi UE GBR And Start DL UL Traffic    ${UE_LIST_3}    4    3    ${DL_DATA_003}    ${UL_DATA_003}
    SA Multi UE Start DL And UL BIG Traffic    ${UE_LIST_1}    ${DL_DATA_001}    ${UL_DATA_001}
    Override The MCS    1    10
    SET UE BLER ACTION OR DEACTION    ${BLER_UE_LIST}    bler    activate    1
    Sleep    5s    reason=wait BLER stable  
    SET UE BLER ACTION OR DEACTION    ${BLER_UE_LIST}    bler    deactivate    1
    Delete The MCS Override    1
    Start And Stop Tti Trace        ${TEST_LOG_DIRECTORY}/ttitrace_streaming/201
    Decode Ttitrace Log    ${TEST_LOG_DIRECTORY}/ttitrace_streaming/201
    Check DL All TP On Target For Single UE

*** Keywords ***
Start And Stop Tti Trace
    [Arguments]    ${ttitrace}
    Start Ttitrace With Streaming Mode
    Sleep    1s    reason=capture short ttitracelog
    Stop Ttitrace    l2stream3_ttitrace    ${ttitrace}

SA Multi UE Start DL And UL BIG Traffic
    [Arguments]    ${ue_id_list}    ${dl_mbps}    ${ul_mbps}    ${pdu_id}=1
    FOR    ${ue_id}    IN    @{ue_id_list}
        Start SA UE Big DL Traffic Internal    ${ue_id}    ${dl_mbps}
        Start SA UE Big UL Traffic Internal    ${ue_id}    ${ul_mbps}
    END

SET UE BLER ACTION OR DEACTION
    [Arguments]    ${ue_id_list}    ${testmode}    ${action}    ${profile_id}=1
    FOR    ${ue_id}    IN    @{ue_id_list}
        CUDU L2 Send Action To GNB    ${ue_id}    ${testmode}    ${action}    ${profile_id}
    END	


Check DL All TP On Target For Single UE
    Check Non CA UE DL UL Tput With In Range    11    12    ${TARGET001_TP_DL}    ${TARGET001_TP_UL}    ${TPUT_RATE}
    Check Non CA UE DL UL Tput With In Range    21    22    ${TARGET001_TP_DL}    ${TARGET001_TP_UL}    ${TPUT_RATE}
    Check Non CA UE DL UL Tput With In Range    31    32    ${TARGET001_TP_DL}    ${TARGET001_TP_UL}    ${TPUT_RATE}
    Check Non CA UE DL UL Tput With In Range    13    13    ${TARGET002_TP_DL}    ${TARGET002_TP_UL}    ${TPUT_RATE}
    Check Non CA UE DL UL Tput With In Range    23    23    ${TARGET002_TP_DL}    ${TARGET002_TP_UL}    ${TPUT_RATE}
    Check Non CA UE DL UL Tput With In Range    33    33    ${TARGET002_TP_DL}    ${TARGET002_TP_UL}    ${TPUT_RATE}
    Check Non CA UE DL UL Tput With In Range    15    15    ${TARGET003_TP_DL}    ${TARGET003_TP_UL}    ${TPUT_RATE}
    Check Non CA UE DL UL Tput With In Range    25    25    ${TARGET003_TP_DL}    ${TARGET003_TP_UL}    ${TPUT_RATE}
    Check Non CA UE DL UL Tput With In Range    35    35    ${TARGET003_TP_DL}    ${TARGET003_TP_UL}    ${TPUT_RATE}