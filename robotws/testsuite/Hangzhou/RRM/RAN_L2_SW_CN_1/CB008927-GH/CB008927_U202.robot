*** Settings ***
Documentation    CB008927
Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${Full_SCF_CB8927_H202}    iphy_file=${IPHY}    swconfig_param=${SWCONFIG}
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
${SWCONFIG}    0x58057a=3;0x580582=8;0x58090b=1;0x5806df=12;0x58064f=0x82;0x580345=1;0x58057b=0x10000;0x58057f=256;0x580340=1;0x580954=1;0x580001=0
${SCF_PATH}                     ${CURDIR}/Config
${WTS_CFG}                      CB008927_U.cfg
${WTS_LOCAL}                    ${CURDIR}/Resources/wts
${IPHY}                         ${CURDIR}/Resources/wts/iphy_CB008927_U202.xml
@{LOG_NAME_LIST}                snapshot    btsLog
@{LOG_NAME_SUITE_SETUP_ASIK}    snapshot
${UEC_REACTION_TIME}            100
### H101 ###
${Full_SCF_CB8927_H202}       Full_SCF_CB008927_U202.xml
${CAUSE_REASON}             NAS_normal_release
${START_PAGGING_UE}         12
${STOP_PAGGING_UE}          12
${A2A_U202_NAME}              CB008927_U202.ini
${A2A_U202_NAME_IWK_G1101}    CB008927_U202_IWK_G1101.ini
${A2A_PATH_U202}              U202
${DL_DATA_001}              100
${UL_DATA_001}              10
${DL_DATA_002}              1
${UL_DATA_002}              1
${DL_DATA_003}              2
${UL_DATA_003}              1
@{ALL_UE_LIST}               @{UE_LIST_1}    @{UE_LIST_2}    @{UE_LIST_3}
@{UE_LIST_1}               11    12    21    22    31    32
@{UE_LIST_2}               13    23    33
@{UE_LIST_3}               15    25    35
@{BLER_UE_LIST}            11    21    13    15
@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}

*** Test Cases ***
CB008927-ET-H202_Verify_Start_PRB_Randomization_UseInitialBwp_With_Multi_Dedicated_BWP_And_Multi_PDSCH_SubArea
    [Tags]    Owner_xxx    CRT
    SA Multi NonCA UE Attach    ${ALL_UE_LIST}
    Setup Multi UE GBR And Start DL UL Traffic    ${UE_LIST_2}    3    3    ${DL_DATA_002}    ${UL_DATA_002}
    Setup Multi UE GBR And Start DL UL Traffic    ${UE_LIST_3}    4    3    ${DL_DATA_003}    ${UL_DATA_003}
    SA Multi UE Start DL And UL Traffic    ${UE_LIST_1}    ${DL_DATA_003}    ${UL_DATA_003}
    SA Multi UE Start DL And UL Traffic    ${UE_LIST_1}    ${DL_DATA_001}    ${UL_DATA_001}
    Start Ttitrace With Streaming Mode
    Trigger Paging    ${START_PAGGING_UE}    ${STOP_PAGGING_UE}    ${CAUSE_REASON}
    Stop Ttitrace    l2stream3_ttitrace    ${TEST_LOG_DIRECTORY}/ttitrace_streaming/1
    Override The MCS    1    22
    Bler_Override_Actived      1
    Sleep    5s    reason=wait BLER stable
    Start And Stop Tti Trace        ${TEST_LOG_DIRECTORY}/ttitrace_streaming/2
    Bler_Override_Deactived    1
    Delete The MCS Override    1
    Decode TTITRACE LATEST LOG
    A2A Check TTI Log     ${A2A_U202_NAME}    ${TEST_LOG_DIRECTORY}/ttitrace_streaming/1      ${A2A_PATH_U202}
    A2A Check TTI Log     ${A2A_U202_NAME_IWK_G1101}    ${TEST_LOG_DIRECTORY}/ttitrace_streaming/2      ${A2A_PATH_U202}

*** Keywords ***
Trigger Paging
    [Arguments]    ${start_ue_id}    ${stop_ue_id}    ${cause}    ${AMF}=1    ${default_drx}=256    ${max_paging_retries}=10
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+1
        Log To Console    ===============Trigger Time: ${ue_id}==============
        ute_wtssim.Execute Egate Command    cmd=amf_paging_param id=${AMF} default_drx=${default_drx} max_paging_retries=${max_paging_retries}
        ${output}    ute_wtssim.Execute Egate Command       cmd=ue_ng_ctx_release id=${ue_id} cause=${cause}
        ...       pass_regexp=OnReceiveUeContextReleaseComplete    timeout=3s
        ${output}    ute_wtssim.Execute Egate Command         cmd=amf_paging_start id=${AMF} ue=${ue_id}
        ...      pass_regexp=pagingRecordList    timeout=3s
    END

A2A Check TTI Log
    [Arguments]    ${A2A_File_name}    ${TTI_LOG_Path}    ${A2A_PATH}
    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A${/}${A2A_PATH}${/}${A2A_File_name}
    ...    i    save_log_directory=${TTI_LOG_Path}

Bler_Override_Actived
    [Arguments]    ${ue_id}    ${type}=bler    ${action}=activate    ${profile_id}=1
    FOR    ${ue_id}    IN RANGE    11    16    2
    CUDU L2 Send Action To GNB    ${ue_id}    ${type}    ${action}    ${profile_id}
    END

Bler_Override_Deactived
    [Arguments]    ${ue_id}    ${type}=bler    ${action}=deactivate    ${profile_id}=1
    FOR    ${ue_id}    IN RANGE    11    16    2
    CUDU L2 Send Action To GNB    ${ue_id}    ${type}    ${action}    ${profile_id}
    END

Start And Stop Tti Trace
    [Arguments]    ${ttitrace}
    Start Ttitrace With Streaming Mode
    Sleep    1s    reason=capture short ttitracelog
    Stop Ttitrace    l2stream3_ttitrace    ${ttitrace}

Decode TTITRACE LATEST LOG
    Decode Ttitrace Log    ${TEST_LOG_DIRECTORY}/ttitrace_streaming/1
    Decode Ttitrace Log    ${TEST_LOG_DIRECTORY}/ttitrace_streaming/2