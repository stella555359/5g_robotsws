*** Settings ***
Documentation    :copyright: Nokia

Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         taf/rfrl/common_resources/robot/libraries_instances.robot
Resource         ../resources/robot/TTI_Traces.robot
Resource         ../resources/NPS/SWENG/robot/PacketSearch.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         ../resources/robot/common_log_collection.robot

Library     taf.ul.ue.sim.env_setup


*** Keywords ***
Start Default Logging Gnb ASIL_ABIO
    Start Log   btslog

Stop Default Logging Gnb ASIL_ABIO
    Stop Log   btslog    snapshot    sosreport

Prepare TL with config files
     Log To Console    Configure ENV with SCFC/AP.xml/LUA
     add gnb configuration    scfc=${SCFC}
     add simulator  sim_type=airphone  config=${AP_XML}
#     add 5gc  config=${BASIC_CFG}  edaemon_ports=10000
     configure environment       rmod_detection_timeout=300s
     Log To Console    After Configure ENV

Trigger High DL Traffic for SA
    [Arguments]    ${sa_ue_id1}     ${Traffic_rate}     ${dl_rate}
    [Documentation]    This keyword starts the DL Traffic for the SA variant for higher data rate
    ${dl_rate_loop}=      Evaluate      ${dl_rate}//175
    ${dl_rate_reminder}=     Evaluate      ${dl_rate}%175
    ${dl_rate_loop}=      Evaluate     ${dl_rate_loop}+1
    ${TRF_ID}=   Set Variable   1
    FOR   ${loop}   IN RANGE   0   ${dl_rate_loop}
        Run Keyword if    ${loop}==0    Trigger DL Data Traffic for SA   ue_id=${sa_ue_id1}    Traffic_rate=${Traffic_rate}
        ...   dl_rate=${dl_rate_reminder}     pdu_id=1    trf_id=${TRF_ID}
        Run Keyword if    ${loop}>0     Trigger DL Data Traffic for SA   ue_id=${sa_ue_id1}    Traffic_rate=${Traffic_rate}
        ...   dl_rate=175     pdu_id=1    trf_id=${TRF_ID}
#        Run Keyword if    ${loop}==0    Log Many    ${dl_rate_reminder}   ${TRF_ID}     ${loop}
#        Run Keyword if    ${loop}>0     Log Many    ${175}   ${TRF_ID}     ${loop}
        ${TRF_ID}=      Evaluate     ${TRF_ID}+1
        sleep   2s
    END

Trigger High UL Traffic for SA
    [Arguments]    ${sa_ue_id1}     ${Traffic_rate}     ${ul_rate}
    [Documentation]    This keyword starts the UL Traffic for the SA variant for higher data rate
    ${ul_rate_loop}=      Evaluate      ${ul_rate}//175
    ${ul_rate_reminder}=     Evaluate      ${ul_rate}%175
    ${ul_rate_loop}=      Evaluate     ${ul_rate_loop}+1
    ${TRF_ID}=   Set Variable   1
    FOR   ${loop}   IN RANGE   0   ${ul_rate_loop}
        Run Keyword if    ${loop}==0    Trigger UL Data Traffic for SA   ue_id=${sa_ue_id1}    Traffic_rate=${Traffic_rate}
        ...   ul_rate=${ul_rate_reminder}     pdu_id=1    trf_id=${TRF_ID}
        Run Keyword if    ${loop}>0     Trigger UL Data Traffic for SA   ue_id=${sa_ue_id1}    Traffic_rate=${Traffic_rate}
        ...   ul_rate=175     pdu_id=1    trf_id=${TRF_ID}
        ${TRF_ID}=      Evaluate     ${TRF_ID}+1
        sleep   2s
    END

