*** Settings ***
Documentation    :copyright: Nokia

#Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         taf/rfrl/common_resources/robot/libraries_instances.robot
Resource         ../resources/robot/TTI_Traces.robot
Resource         ../resources/NPS/SWENG/robot/PacketSearch.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         ../resources/robot/common_log_collection.robot
Library          taf.analyzer.pdml     WITH NAME    taf_pdml_analyser
Library          luashark_tools.analyzer       WITH NAME       analyzer
Library     taf.ul.ue.sim.env_setup
#Library          taf.gnb.oam.coam.admin    WITH NAME    COAM


*** Keywords ***
Start Default Logging Gnb ASIL_ABIO
    Start Log   btslog

Stop Default Logging Gnb ASIL_ABIO
    Stop Log   btslog    snapshot    sosreport

Start Default Logging Gnb ASIL_ABIO TC2
    Start Log   btslog    cprt

Stop Default Logging Gnb ASIL_ABIO TC2
    Stop Log   btslog    snapshot   sosreport

Prepare TL with config files
     Log To Console    Configure ENV with SCFC/AP.xml/LUA
     add gnb configuration    scfc=${SCFC}
     add simulator  sim_type=airphone  config=${AP_XML}
#     add 5gc  config=${BASIC_CFG}  edaemon_ports=10000
     configure environment       rmod_detection_timeout=300s
     Log To Console    After Configure ENV

Trigger High DL Traffic for SA
    [Arguments]    ${Traffic_rate}     ${dl_rate}
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
        ${TRF_ID}=      Evaluate     ${TRF_ID}+1
        sleep   2s
    END

Trigger High UL Traffic for SA
    [Arguments]    ${Traffic_rate}     ${ul_rate}
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


Verify fdm max ul and dl Counters
     [Arguments]    ${ul_expected}      ${dl_expected}
     [Documentation]    This keyword is to verify the FDM dl&ul counter
     ${counter_dl}           Get Counter Value With Admin          M55308C17002
     ${counter_ul}           Get Counter Value With Admin          M55308C18002
     Should Be True      ${counter_dl}==${dl_expected}
     Should Be True      ${counter_ul}==${ul_expected}

Get Counter Value With Admin
     [Arguments]    ${counter_id}
    [Documentation]    This keyword is to get the lastest value of couter from Admin
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${counter_id} | Yes | Counte id, such as M55323C14001 |
    ...
    ...    Examples:
    ...    | Get Latest PM Counter Value With Admin | M55323C14001 |
    ...
    COAM.Setup Admin
    ${counter}    COAM.Get Pm Counters    ${counter_id}
    ${counter_str}    Convert To String    ${counter}
    ${counter_list}    String.Get Regexp Matches    ${counter_str}
    ...    (?P<counter_time>\\d+)':\\s(?P<counter_num>\\d+)    counter_time    counter_num
    ${latest}    Evaluate    max(${counter_list})
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown
    [Return]    ${latest[-1]}

Verify crntiNonOverlappingPoolId In CellSetupReq
    [Arguments]      ${file}
    [Documentation]      this KW Verifies the crntiNonOverlappingPoolId In CellSetupReq captured in CPRT logs
    log to console       Verifying crntiNonOverlappingPoolId In CellSetupReq captured in CPRT logs
    ${pdmlFile}=                    analyzer.pcap_to_pdml        ${file}    pscell
    ${crntiNonOverlappingPoolId}      analyzer.get_shownames           pdmlFile=${pdmlFile}
    ...                                                packetName=itf_l2_ps_cell_cellsetupreq
    ...                                                path=itf_l2_ps_cell_CrntiPoolConfig.crntiNonOverlappingPoolId_item
    ...                                                endPacket=${1}
    ${len}      Get Length     ${crntiNonOverlappingPoolId}
    Should Be Equal    ${len}    ${4}

Get filtered PDML file from pcap
    [Arguments]                     ${pcapFile}       ${filterExp}=None
    [Documentation]                 Takes a PDML file as input, and returns it into a PDML file
    ${filterPcap}                   analyzer.filter_pcap            ${pcapFile}
    ...                             filterName=${filterExp}         filterExp=${filterExp}
    ${pdmlFile}=                    analyzer.pcap_to_pdml           ${filterPcap}
    [Return]    ${pdmlFile}
