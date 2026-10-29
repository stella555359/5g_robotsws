*** Settings ***
Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${Full_SCF_CB8927_H202}    iphy_file=${IPHY}    swconfig_param=${SWCONFIG_PARAM}
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
### H101 ###
${Full_SCF_CB8927_H202}       Full_SCF_CB008927_H202.xml
${START_LARGEBWP_UE}         1
${STOP_LARGEBWP_UE}          4
${START_MIDBWP_UE}           5
${STOP_MIDBWP_UE}            8
${START_SMALLBWP_UE}         9
${STOP_SMALLBWP_UE}          12
${LARGE_MBPS_DL}            100
${LARGE_MBPS_UL}            10
${MID_MBPS_DL}              50
${MID_MBPS_UL}              10
${SMALL_MBPS_DL}            5
${SMALL_MBPS_UL}            1
${CAUSE_REASON}             NAS_normal_release
${START_PAGGING_UE}         12
${STOP_PAGGING_UE}          12
${A2A_H202_NAME}              CB008927_H202.ini
${A2A_PATH_H202}              H202
@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}


*** Test Cases ***
CB008927-ET-H202_Verify_Start_PRB_Randomization_UseInitialBwp_With_Multi_Dedicated_BWP_And_Multi_PDSCH_SubArea
    [Tags]    Owner_xxx    CRT
    SA Multi Continuous NonCA UE Attach    ${START_LARGEBWP_UE}    ${STOP_LARGEBWP_UE}
    SA Multi Continuous NonCA UE Attach    ${START_MIDBWP_UE}      ${STOP_MIDBWP_UE}
    SA Multi Continuous NonCA UE Attach    ${START_SMALLBWP_UE}    ${STOP_SMALLBWP_UE}
    SA Multi Continuous UE Start DL And UL Traffic    ${START_LARGEBWP_UE}    ${STOP_LARGEBWP_UE}    ${LARGE_MBPS_DL}    ${LARGE_MBPS_UL}
    SA Multi Continuous UE Start DL And UL Traffic    ${START_MIDBWP_UE}      ${STOP_MIDBWP_UE}       ${MID_MBPS_DL}      ${MID_MBPS_UL}
    SA Multi Continuous UE Start DL And UL Traffic    ${START_SMALLBWP_UE}    ${STOP_SMALLBWP_UE}     ${SMALL_MBPS_DL}    ${SMALL_MBPS_UL}
    Start Ttitrace With Streaming Mode
    Trigger Paging    ${START_PAGGING_UE}    ${STOP_PAGGING_UE}    ${CAUSE_REASON}
    Override The MCS    1    18
    Bler_Override_Actived      1
    Sleep    2s    reason=wait BLER stable  
    Bler_Override_Deactived    1
    Delete The MCS Override    1
    Stop Ttitrace    l2stream3_ttitrace    ${TEST_LOG_DIRECTORY}/ttitrace_streaming/1
    Decode Ttitrace Log    ${TEST_LOG_DIRECTORY}/ttitrace_streaming/1
    A2A Check TTI Log     ${A2A_H202_NAME}    ${TEST_LOG_DIRECTORY}/ttitrace_streaming/1      ${A2A_PATH_H202}
    [Teardown]    Common Test Teardown



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
    [Arguments]    ${ue_id}    ${type}=bler    ${action}=active    ${profile_id}=1
    FOR    ${ue_id}    IN RANGE    1    10    4
    CUDU L2 Send Action To GNB    ${ue_id}    ${type}    ${action}    ${profile_id}
    END	

Bler_Override_Deactived
    [Arguments]    ${ue_id}    ${type}=bler    ${action}=deactivate    ${profile_id}=1
    FOR    ${ue_id}    IN RANGE    1    10    4
    CUDU L2 Send Action To GNB    ${ue_id}    ${type}    ${action}    ${profile_id}
    END	
