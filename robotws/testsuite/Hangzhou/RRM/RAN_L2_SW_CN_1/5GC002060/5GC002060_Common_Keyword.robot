*** Settings ***

Library    OperatingSystem
Resource    ../CUDU_L2/common_setup_teardown.robot
Resource    ../CUDU_L2/common_log_capture.robot

*** Variables ***
${SCF_DIR}    ${CURDIR}/config
${LOCAL_WTS_DIR}    ${CURDIR}/config/WTS_CFG/
${tti_ul_csv}    ${OUTPUT_DIR}/ttitrace_streaming/output_ul.csv
*** Keywords ***
Setup TL For Each Case
    [Arguments]    ${scf_file}    ${wts_cfg_name}=${empty}    ${swconfig_param}=${empty}    ${wts_xml_name}=${empty}
    Suite Setup Update GNB    swconfig_param=${swconfig_param}    scf_file=${scf_file}
    Sleep    60s    \nFor Site reset
    Verify Coam Site Is Ready
    Set WTS Files Name For Each Cases    ${wts_cfg_name}    ${wts_xml_name}
    Start UTE WTS And Check Cell Setup    ${wts_cfg_name}

Prepare Test TL
    Modify UTE SCTP Timeout
    Modify AP SCTP Timeout
    Configure UTE ETH3

NSA L3 UE attach
    [Arguments]    ${ue_id}   ${gnb_id}    ${cell_id}    ${bearer_id}
    Setup X2 Connection
    NSA LTE Attach    ${ue_id}
    NSA 5G Attach    ${ue_id}    ${gnb_id}    ${cell_id}    ${bearer_id}
    NSA Verify If Attach Passed

Stop Ttitrace And Convert To CSV
    Sleep     30s    \nFor DRX status collected in ttitrace......
    Log to Console    Stop Ttitrace starts......
    Stop Ttitrace
    Convert Ttitrace From Pcap To Excelcsv    ${OUTPUT_DIR}/ttitrace_streaming/

Periodic Read PM Counter
    [Arguments]    ${counter_id}    ${time}=10min
    ${counter_list}    wait until keyword succeeds    ${time}    20sec    PM Counter Value Exists    ${counter_id}
    [Return]    ${counter_list}

PM Counter Value Exists
    [Arguments]    ${counter_id}
    ${counter_list}    Get PM Counter    ${counter_id}
    Should Not Be Empty    ${counter_list}
    [Return]    ${counter_list}

Get PM Counter
    [Arguments]    ${counter_id}
    Log To Console    check ${counter_id}
    ssh.connect to    &{GNB_ASIK}[ip]    &{GNB_ASIK}[username]    &{GNB_ASIK}[password]
    ssh.execute    gunzip /tmp/PM.BTS*.gz
    ssh.execute    rm /tmp/PM.BTS*.xml
    ${counter_info1}    ssh.execute    cat /tmp/PM.BTS* | grep ${counter_id}
    ${counter_list}    get regexp matches    ${counter_info1}    <${counter_id}>(\\d+)</${counter_id}>    1
    Log To Console    The PM counter ${counter_id} contains following values:
    Log To Console    ${counter_list}
    [Return]    ${counter_list}
    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect

Check PM Counter for CaseA_01
    Log To Console    wait 30min for counter is complete...
    ${counter1_value}    wait until keyword succeeds    30min    3min    Get Counter    M55308C11001
    ${counter2_value}    wait until keyword succeeds    30min    3min    Get Counter    M55308C11002

Set WTS Files Name For Each Cases
    [Arguments]    ${wts_cfg_name}    ${wts_xml_name}
    Set Suite Variable    ${WTS_CFG}    ${wts_cfg_name}
    Log To Console    ${WTS_CFG}
    Set Suite Variable    ${WTS_AP_XML}    ${wts_xml_name}
    Log To Console    ${WTS_AP_XML}
    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}

Start UTE WTS And Check Cell Setup
    [Documentation]    This keyword is to kill Running WTS Binaries,start edaemon, egate and clean log files.
    [Arguments]    ${local_wts_cfg}
    Log To Console    \nStarting WTS...
    Run Keyword And Ignore Error    Stop Edaemon Egate
    ute_wtssim.Setup Edaemon    edaemon_port=22222    tool_dir=${WTS_DIR}    alias=edaemon
    ute_wtssim.Start Edaemon Process    alias=edaemon
    ute_wtssim.Setup Egate    egate_port=20000    tool_dir=${WTS_DIR}    save_egate=${True}
    ute_wtssim.Start Egate Process
    OperatingSystem.Run    sudo rm -rf ${WTS_DIR}/*.log*
    ute_wtssim.Execute Egate Command    cfg file\=${WTS_DIR}/${local_wts_cfg}
    ...    pass_regexp=SystemInformationBlockType4-NR updated    timeout=5min
    Sleep     60s    \nFor each scells status
    Verify Cell Setup
    Sleep    60s    wait for all cells' sib come up...\n

Verify DRX period from ttitrace
    [Arguments]    ${Drx_period}
    ${SFN_list}    TTITRACEANALYZER.filter_source_column_return_other
    ...    ${tti_ul_csv}    ulIntraDlToUlDrxSyncDlData.dlDrxOndurationTimerOn    ["0", "", "0.0"]    except    sfn    no
    ${sfn_interval_lt}    TTITRACEANALYZER.count_interval    ${SFN_list}
    Log To Console    ${sfn_interval_lt}
    Should Contain    ${sfn_interval_lt}     ${${Drx_period}}

Verify DRX period
    [Arguments]    ${Drx_period}
    ${SFN_list}    TTITRACEANALYZER.filter_source_column_return_other
    ...    ${tti_ul_csv}    ulPreSchedData.csListEvent    ["EXITDRXSTATUSEXCEPTRETXTIMER"]    include    sfn    no
    ${sfn_interval_lt}    TTITRACEANALYZER.count_interval    ${SFN_list}
    Log To Console    ${sfn_interval_lt}
    Should Contain    ${sfn_interval_lt}     ${${Drx_period}}

Recover TL
    Common Suite Teardown 2
    Recover Config
    Sleep    60s    \nFor Site reset
    Verify Coam Site Is Ready
    Clean Edaemon And Egate

Recover Config
    ${bts_id}    Get BTS Id
    COAM.Setup Admin    bts_host=${GNB_ASIK.ip}
    Log To Console    recover gnb configuratio...
    COAM.Perform Commissioning
    ...    bts_id=${bts_id}
    ...    scf_file=${OUTPUT_DIR}/SCF_before_suite.xml
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=500
    Run Keyword And Ignore Error    COAM.Teardown

SA Start Traffic Internal
    [Arguments]    ${ue_id}    ${pdu_id}    ${mbps}
    SA Start DL Traffic Internal    ${ue_id}     ${pdu_id}    ${mbps}    trf_id=1
    SA Start UL Traffic Internal    ${ue_id}     ${pdu_id}    ${mbps}    trf_id=1
    Sleep    25s    reason=Wait for traffic stable

UE Beamforming Profile And Association
    ${CMD_BC_PRF_1}    Set Variable
    ...    beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=1,0,2,3,4,5 ssbeam_bestbeam=1 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50
    ${CMD_BC_PRF_2}    Set Variable
    ...    beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=2,0,1,3,4,5 ssbeam_bestbeam=2 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-70
    ${CMD_TESTMODE_ATTACH_1}    Set Variable
    ...    ue_testmode_set_nr id=1 testmode=beam_control action=activate profile_id=1 beamaction=attach
    ute_wtssim.Execute Egate Command    cmd=${CMD_BC_PRF_1}
    ute_wtssim.Execute Egate Command    cmd=${CMD_BC_PRF_2}
    ute_wtssim.Execute Egate Command    cmd=${CMD_TESTMODE_ATTACH_1}

UE Beamforming Switch
    [Arguments]    ${profile_id}    ${scell}
    ${CMD_TESTMODE_SWITCH}    Set Variable
    ...   ue_testmode_set_nr id=1 testmode=beam_control action=activate profile_id=${profile_id} beamaction=switch scell=${scell}
    Log To Console    ******Beam Control UE$1 Switch to Profile ${profile_id} ******
    ute_wtssim.Execute Egate Command    cmd=${CMD_TESTMODE_SWITCH}

Check PatternID From Wirshark
    [Arguments]    ${beamId}
    Start Gnb BIP Log
    Sleep    2s
    Stop Gnb BIP Log    ${SUITE_LOG_DIRECTORY}_beamID${beamId}
    Convert BIP To CSV By MCShark For Pdcchsendreq    ${beamId}
    Check BeamID In Pdcchsendreq    ${beamId}

Convert BIP To CSV By MCShark For Pdcchsendreq
    [Arguments]    ${beamId}
    ${filter}=    Set Variable    dldata_pdcchsendreq && !(3gpp.rnti == 65535)
    @{csv_title_list}=    Create List    DlData_PdcchSendReq_t.beamId
    ${bip_names}    Set Variable    ${SUITE_LOG_DIRECTORY}_beamID${beamId}/5GBipL2L1_filtering_off.pcap*
    Convert BIP To CSV By MCShark   ${bip_names}    ${OUTPUT_DIR}/${beamId}_Pdcchsendreq.csv    ${filter}    ${csv_title_list}

Check BeamID In Pdcchsendreq
    [Arguments]    ${beamId}
    ${data_list_1}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${OUTPUT_DIR}/${beamId}_Pdcchsendreq.csv    DlData_PdcchSendReq_t.beamId    ["${beamId}"]    include    no
    ${count1}    Get Length    ${data_list_1}
    Should Be True    ${count1}!=0

#Check DRX on time and sleep time is right
#    Wait Until Keyword Succeeds    1min    10min     Get Actual Ratio of DRX ON time and sleep time    0.14

Check DRX on time and sleep time is right
    [Arguments]    ${Ratio}
    Sleep    10min    reason=Wait for next pm counter
    @{DRX_ON_time}    Periodic Read PM Counter    M55308C11001
    @{Sleep_time}    Periodic Read PM Counter    M55308C11002
    ${Real Ratio}    Evaluate    float(@{DRX_ON_time}[1]/@{Sleep_time}[1])
    Should Be True     ${Real Ratio}>${Ratio}-0.05 and ${Real Ratio}<${Ratio}+0.05


