*** Settings ***
Library      ../../python/ta_kiss_gnb/    WITH NAME    ta_kiss_gnb

Resource    ./../../CUDU_L2/common_setup_teardown.robot
Resource    ./../../CB006137/CB006137_resource.robot

*** Keywords ***
Start BIP Log By lfs-nw_switch-mirror-tool Script
    [Arguments]    ${shell_script}    ${shell_script_path}=${SCRIPT_PATH}/shell/    ${shell_script_config}=None
    [Documentation]    user provide shell script
    ...    GNB_ASIB_1ABIO_L1Bypass:    bip_ASIB_ABIO.sh
    ...    GNB_ASIB_2ABIO_L1Bypass:    bip_ASIB_2ABIO.sh
    ...    GNB_ASIL_1ABIO_L1Bypass:    bip_ASIL_ABIO.sh
    Clear The BIP File Dir On FCT
    Log To Console    INFO:Start GNB BIP log...
    Modify File Parameter    ${shell_script_path}/${shell_script}    tcpdumpL2L1    5GBipL2L1    #gnb_mirroring
    Modify File Parameter    ${shell_script_path}/${shell_script}    tcpdump_L2L1_bip    5GBipL2L1    #shell scrip ASIM_ABIO
    Modify File Parameter    ${shell_script_path}/${shell_script}    -C 100    -C 50
    Modify File Parameter    ${shell_script_path}/${shell_script}    -W 20    -W 2
    OperatingSystem.Run
    ...    sshpass -p ${GNB.password} scp ${shell_script_path}/${shell_script} ${GNB.username}@${GNB.ip}:/ffs/run/config/scripts/
    OperatingSystem.Run
    ...    sshpass -p ${GNB.password} scp ${shell_script_path}/${lfs} ${GNB.username}@${GNB.ip}:/usr/bin/
    Run Keyword If    "${shell_script_config}"!="None"    OperatingSystem.Run
    ...    sshpass -p ${GNB.password} scp ${shell_script_path}/${shell_script_config} ${GNB.username}@${GNB.ip}:/ffs/run/config/scripts/
    ${gnb_hostname}=    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 hostname 2>/dev/null
    #${slot_id}=    Set Variable If    '${gnb_hostname}'=='fct-4a'    5    1
    #${exec_script}    Set Variable If    "${shell_script_config}"=="None"    ${shell_script} ${slot_id}    ${shell_script}
    OperatingSystem.Run    sshpass -p ${GNB.password} ssh ${GNB.username}@${GNB.ip} chmod +x /ffs/run/config/scripts/${shell_script}
    OperatingSystem.Run    sshpass -p ${GNB.password} ssh ${GNB.username}@${GNB.ip} chmod +x /usr/bin/${lfs}
    SSH.Connect To    ${GNB.ip}    ${GNB.username}    ${GNB.password}    alias=BIP_GNB
    SSH.Send Command    command=chmod 777 /usr/bin/${lfs}    connection=BIP_GNB
    SSH.Send Command    command=sh /ffs/run/config/scripts/${shell_script} 1>/dev/null 2>&1 &    connection=BIP_GNB
    Set Suite Variable    ${BIP_CMD}           tcpdump -i
    Wait Until Keyword Succeeds    1min    2s    Verify Process Start Success    5GBipL2L1_filtering_off    ${BIP_CMD}    BIP_GNB
    Log To Console   INFO:bip start success...


Check RRC Reconfig For DRX Configuration For CB009169-UPD006
    [Arguments]    ${profile1_timer}    ${times1}    ${profile2_timer}    ${times2}    ${log_dir}
    Save Egate Log
    OperatingSystem.Run    cp ${SUITE_LOG_DIRECTORY}/egate_console.log ${log_dir}/egate_console-Drx.log
    ${egate_console_file}=    Set Variable    ${log_dir}/egate_console-Drx.log
    ${Drx}=    Grep File    ${egate_console_file}    drx-InactivityTimer
    Should Contain X Times    ${Drx}    drx-InactivityTimer ${profile1_timer},    ${times1}
    Should Contain X Times    ${Drx}    drx-InactivityTimer ${profile2_timer},    ${times2}

Release 5QI 5 And 5QI 1
    ${cmd3}    Set Variable    ue_pdu_session_modify ue=1 pdu=1 qosflows_to_del=2,3
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${cmd3}    pass_regexp=rrcReconfigurationComplete    timeout=3minutes

Check DRX InactivityTimer From BIP For CB009169-UPD006
    [Arguments]    ${SCellID}    ${cell_id}    ${drxprofile}
    Log To Console    Check DRX InactivityTimer on SCell...
    Convert BIP To CSV By MCShark For CB009169-UPD006    ${SCellID}    ${cell_id}    ${drxprofile}
    A2A_Check_CSV_Table    ${CURDIR}/../A2A/CB009169_C/ttitrace_upd001_06_${drxprofile}.ini    ${OUTPUT_DIR}/csv_drx_${drxprofile}.csv


Trigger A1 Scell Addition
   [Arguments]    ${ue_id}=${UE_ID}    ${meas_id}=1    ${srsrp_nr}=120
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=${meas_id} event=A1 srsrp_nr=${srsrp_nr}

Trigger A6 Scell Swap
    [Arguments]    ${ue_id}=${UE_ID}    ${meas_id}=5    ${srsrp_nr}=100
    ${cmd}    Catenate    ue_measurement_send_nr id=${UE_ID} meas_id=${meas_id} event=A6 srsrp_nr=${srsrp_nr} scell=1
    ...     scell_rsrp=20 scell_rsrq=90 phycell_id=52 nrsrp_nr=100 nrsrq_nr=100
    ute_wtssim.Execute Egate Command    ${cmd}    pass_regexp=SCellIndex 2 activated successfully at airphone

Trigger A2 MR Scell Release
    [Arguments]    ${ue_id}=${UE_ID}    ${meas_id}=2    ${scell_index}=2    ${scell_rsrp}=50
    ${command}    Set Variable    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=${scell_index} scell_rsrp=${scell_rsrp}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    pass_regexp=ReconfigurationComplete
    [Return]    ${output}

Check Scell Release Infos After A2 MR
    [Arguments]    ${output}    ${scell_index}=2
    ${releaseidregex}=    Set Variable    sCellToReleaseList[\\s\\S]*?{([\\s\\S]*?)}
    #ute_wtssim.Execute Egate Command    sim_log_set flush
    #${content}=    OperatingSystem.Get File    /opt/iphy/latest/egate_console.log
    ${release_id_list}=    String.Get Regexp Matches    ${output}    ${releaseidregex}    1
    ${release_id}=    String.Get Regexp Matches    @{release_id_list}[0]    \\d+
    List Should Contain Value    ${release_id}    ${scell_index}

Check P0 Value Not Changed
    ${ret}    OperatingSystem.Run    cat /opt/iphy/latest/egate_console.log |grep -E "p0 0"|wc -l
    Should Be True     ${ret}==3

Check Conservative MCS
    ${result}    OperatingSystem.Run    cat ${TEST_LOG_DIRECTORY}/Gnb_syslog_*|grep -i "iniDeltaCqi set = -15.000000"
    Should Contain    ${result}    iniDeltaCqi set = -15.000000

Check LocationAndBandwidth From Egate Log
    [Arguments]    ${locationAndBandwidth}=31624
    Log To Console    Start check locationAndBandwidth info from egate log.
    ${check_rst}    Run    cat /opt/iphy/latest/egate_console.log.001|grep -i "locationAndBandwidth"
    Should Contain    ${check_rst}     locationAndBandwidth ${locationAndBandwidth}

Check PM Counter For Large BWP
    Wait Until Keyword Succeeds    15min    1min    Get PM File
    ${rd_counter_value}    Get PM Counter Value From Xml    1    NCADC    M55167C00001    1
    Should Be True    ${rd_counter_value}>0
    ${rd_counter_value}    Get PM Counter Value From Xml    2    NCADC    M55167C00003    1
    Should Be True    ${rd_counter_value}>0
    ${rd_counter_value}    Get PM Counter Value From Xml    2    RSADU    M55139C04002    1
    Should Be True    ${rd_counter_value}>0

Get PM Counter Value From Xml
    [Arguments]    ${mode}    ${meas_type}    ${counter}    ${cellid}    ${flag}=CA
    ${counter_info}    OperatingSystem.Run    cat ${SUITE_LOG_DIRECTORY}/PMFile/${flag}/PM.BTS*.xml|grep ${counter}
    ${pcell_var}    Set Variable    PLMN-PLMN\/MRBTS-1\/NRBTS-1\/NRCELL-${cellid}<\/DN><\/MO><NE-WBTS_1.0 measurementType="${meas_type}">
    ${count_var}    Set Variable    <${counter}>(?P<couner_num>\\d+)<\/${counter}>
    ${count_var2}    Set Variable    \\S+<${counter}>(?P<couner_num>\\d+)<\/${counter}>
    ${regex} =    Run Keyword If    '${mode}' == '1'
    ...    Catenate    SEPARATOR=    ${pcell_var}    ${count_var}
    ...    ELSE    Catenate    SEPARATOR=    ${pcell_var}    ${count_var2}
    Log To Console    ${regex}
    ${list}    Get Regexp Matches    ${counter_info}    ${regex}    1
    BuiltIn.Log    ${list}
    ${len}    Get Length    ${list}
    FOR    ${id}    IN RANGE    0    ${len}
        ${counter_value}    Get From List    ${list}    ${id}
        LOG    ${counter_value}
        Exit Loop Based On Flag    ${counter_value}    ${flag}
    END
    Run Keyword And Ignore Error  SSH.Disconnect
    [Return]    ${counter_value}

Exit Loop Based On Flag
    [Arguments]    ${counter_value}    ${flag}=CA
    Run Keyword If    '${flag}' == 'CA'
    ...    Exit For Loop If    '${counter_value}'>'0'
    ...    ELSE    Exit For Loop If    '${counter_value}'=='0'

Get PM File
    [Arguments]    ${log_path}=${SUITE_LOG_DIRECTORY}/PMFile/CA
    Check PM File
    Get PM File To Local    ${log_path}

Connect To GNB DU
    SSH.Connect To    hostname=${GNB_ASIK.ip}    username=${GNB_ASIK.username}    password=${GNB_ASIK.password}    alias=GNB-DU

Check PM File
    Connect To GNB DU
    ${output}    SSH.Execute    ls -lrt /tmp/PM.BTS*|wc -l    connection=GNB-DU
    ${num}    Replace String   ${output}   \r\n   ${EMPTY}
    Should Be True    ${num}>=1
    [Teardown]    Run Keyword And Ignore Error    SSH.Disconnect    connection=GNB-DU

Get PM File To Local
    [Arguments]    ${log_path}
    OperatingSystem.Run And Return Rc And Output    rm -rf ${log_path}/*
    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.255.1:/tmp/PM.BTS* ${log_path}
    OperatingSystem.Run And Return Rc And Output    gunzip ${log_path}/PM.BTS*.gz
    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.255.1:/tmp/RD.BTS* ${log_path}
    OperatingSystem.Run And Return Rc And Output    gunzip ${log_path}/RD.BTS*.gz

Clear PM Counter Reports
    ${cmd}    Set Variable    rm /tmp/PM.BTS*
    OperatingSystem.Run And Return Rc And Output
    ...    sshpass -p ${GNB_ASIK.password} ssh ${GNB_ASIK.username}@${GNB_ASIK.ip} '${cmd}'
    Sleep    5s    reason=wait for handling

Check PRB For FDD 25MHz
    [Arguments]    ${csv_file_path}
    A2A_Check_CSV_Table    ${CURDIR}/../A2A/CB009169_C/CB009169_CA001_25MHz.ini    output_ul.csv    ${csv_file_path}

Robustness Testing For Scell Active Deactivate
    [Arguments]    ${times}
    FOR    ${id}    IN RANGE    0    ${times}
        ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 dir\=ul mbps\=5 trf_id\=${id}
        ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 dir\=ul mbps\=150 trf_id\=${id}+1
        Sleep    10s
        ute_wtssim.Execute Egate Command    cmd=trf_data_stop ue\=1 pdu\=1 dir\=ul trf_id\=${id}+1
        Sleep    10s
        ute_wtssim.Execute Egate Command    sim_log_set flush
        ${scell_activation}    Set Variable    SCellIndex 2 activated successfully
        ${scell_deactivation}    Set Variable    SCellIndex 2 deactivated successfully
        ${check_rst1}    Run    cat /opt/iphy/latest/egate_console.log|grep -i "${scell_activation}"|wc -l
        ${check_rst2}    Run    cat /opt/iphy/latest/egate_console.log|grep -i "${scell_deactivation}"|wc -l
        Should Be True    ${check_rst1}==1 and ${check_rst2}==1
        SA Stop Data Traffic Internal    ${UE_ID}    1
    END

Check Pcsi And BeamManagementReport
    [Arguments]    ${csv_file_path}
    A2A_Check_CSV_Table    ${CURDIR}/../A2A/CB009169_C/CB009169_UPD013.ini    output_dl.csv    ${csv_file_path}

Check Slot For TDDFrame
    [Arguments]    ${log_dir}    ${prbstyle}    ${pci}    ${slotlist}
    ${value}    Read Csv Columns    ${log_dir}    slot    filter=((${prbstyle}!=EMPTY)&(physCellId=${pci}))
    ${list}     Evaluate      list(set(${value}))
    Log     ${list}
    Should Be True    ${list} == ${slotlist}

Check UL DMRS By Csv
    [Arguments]    ${save_log_directory}    ${ini_file}=${CURDIR}/../A2A/CB009169_C/CB009169_CA003_ulDmrs.ini
    A2A_Check_CSV_Table    ${ini_file}    ${save_log_directory}/csv_ul_dmrs.csv    ${save_log_directory}

Check DL DMRS By Csv
    [Arguments]    ${save_log_directory}    ${ini_file}=${CURDIR}/../A2A/CB009169_C/CB009169_CA003_ulDmrs.ini
    A2A_Check_CSV_Table    ${ini_file}    ${save_log_directory}/csv_dl_dmrs.csv    ${save_log_directory}

Get UL DMRS Info From BIP
    [Arguments]    ${log_id}=1 
    Log To Console  verify UL DMRS Info of pcell and scell from bip...
    ${filter}=    Catenate    uldata_puschreceivereq && 3gpp.rnti !=65535
    @{csv_title_list}=    Create List    3gpp.dmrsScramblingSequenceInt    UlData_puschReceiveReqGrant_t.ulDmrsAddPos
    ...    UlData_puschReceiveReqGrant_t.ulDmrsMappingType
    Convert BIP to CSV By MCShark    ${TEST_LOG_DIRECTORY}/bip/${log_id}/5GBipL2L1_filtering_off.pcap
    ...    ${TEST_LOG_DIRECTORY}/bip/${log_id}/csv_ul_dmrs.csv    ${filter}    ${csv_title_list}

Get DL DMRS Info From BIP
    [Arguments]    ${log_id}=1 
    Log To Console  verify DL DMRS Info of pcell and scell from bip...
    ${filter}=    Catenate    DlData_PdschGrant.dlDmrsAddPos && 3gpp.rnti !=65535
    @{csv_title_list}=    Create List    3gpp.dmrsScramblingSequenceInt    DlData_PdschGrant.dlDmrsAddPos
    ...    DlData_PdschGrant.dlDmrsMappingType
    Convert BIP to CSV By MCShark    ${TEST_LOG_DIRECTORY}/bip/${log_id}/5GBipL2L1_filtering_off.pcap
    ...    ${TEST_LOG_DIRECTORY}/bip/${log_id}/csv_dl_dmrs.csv    ${filter}    ${csv_title_list}

Get And Check UL And DL DMRS
    [Arguments]   ${save_log_directory}=${OUTPUT_DIR}    ${log_id}=1
    Get UL DMRS Info From BIP    ${log_id}
    Get DL DMRS Info From BIP    ${log_id}
    Check UL DMRS By Csv    ${save_log_directory}
    Check DL DMRS By Csv    ${save_log_directory}

Adjust UE To High Speed
    [Arguments]    ${ue_id}=1    ${profile_id}=1    ${scenario}=VELOCITY_APPROACHING_GNB_AT_350KMPH
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_ta_nr profile_id=${profile_id} ue_fo_velocity=${scenario}
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_testmode_set_nr id\=${ue_id} testmode=ta action=activate profile_id=${profile_id}

Verify Period Of Beam Or PCSI Report For CA Cells
    [Arguments]    ${cell_list}    ${log_dir}    ${type}=pcsi    ${case_id}=CA008    ${period}=16    ${csv_file}=output_ul.csv
    Log    ${cell_list}
    FOR    ${id}    IN     @{cell_list}
        CUDU_L2 Verify Period Of Beam Or PCSI Report    ${id}    ${log_dir}    ${type}    ${period}    ${log_dir}/${csv_file}
        Run    mv ${log_dir}/m_ttitrace_report_period.csv ${log_dir}/m_ttitrace_${type}_report_period_${case_id}_${id}.csv
    END

Check No Scheduled Slot For Scell
    [Arguments]    ${save_log_directory}    ${ini_file}=${CURDIR}/../A2A/CB009169_C/CB009169_CA008_slots.ini
    A2A_Check_CSV_Table    ${ini_file}    ${save_log_directory}/output_ul.csv    ${save_log_directory}

Get And Check Nrofports For CSI-RS
    [Arguments]    ${nrofports}=p4    ${nums}=1
    ${csirs_resource}    Set Variable    nrofPorts ${nrofports}
    ${check_rst}    Run    cat ${WTS_DIR}/egate_console.log|grep -i "${csirs_resource}"|wc -l
    Should Be True    ${check_rst}==${nums}

Get And Check SrsType
    [Arguments]    ${nums_codebook}    ${nums_antennaswitch}
    ${srs_codebook}    Set Variable    usage codebook
    ${srs_antennaswitch}    Set Variable    usage antennaSwitching
    ${check_rst1}    Run    cat ${WTS_DIR}/egate_console.log|grep -i "${srs_codebook}"|wc -l
    ${check_rst2}    Run    cat ${WTS_DIR}/egate_console.log|grep -i "${srs_antennaswitch}"|wc -l
    Should Be True    ${check_rst1}==${nums_codebook} and ${check_rst2}==${nums_antennaswitch}

Check CSI-RS Resource Are Multiplexed
    [Arguments]    ${egate_file}=${WTS_DIR}/egate_console.log
    ${content}    OperatingSystem.Get File    path=${egate_file}
    ${regexp}    Catenate    SEPARATOR=    row4\\s+:\\s+'(?P<frequencyDomainAllocation>\\d+)'B,
    ...    [\\s\\S]*?firstOFDMSymbolInTimeDomain\\s(?P<firstOFDMSymbolInTimeDomain>\\d+),[\\s\\S]*?slots320\\s+:\\s+(?P<periodicityAndOffset>\\d+)
    ${ret}    String.Get Regexp Matches    ${content}    ${regexp}    frequencyDomainAllocation    firstOFDMSymbolInTimeDomain    periodicityAndOffset
    Set Test Variable    ${UE1_CSIRS}    @{ret}[0]
    Set Test Variable    ${UE2_CSIRS}    @{ret}[1]
    Should Be True    '${UE1_CSIRS}[0]'!='${UE2_CSIRS}[0]' and '${UE1_CSIRS}[1]'=='${UE2_CSIRS}[1]' and '${UE1_CSIRS}[2]'=='${UE2_CSIRS}[2]'

Convert BIP To CSV By MCShark For SRS Check
    [Arguments]    ${log_path}
    ${filter}=    Set Variable    uldata_srsreceivereq || uldata_puschreceivereq || (dldata_pdschsendreq&&3gpp.dmrsScramblingSequenceInt == 61)
    @{csv_title_list}=    Create List    3gpp.sfn    3gpp.slot    3gpp.dmrsScramblingSequenceInt
    ...    UlData_srsBmCsInfo_t.srsResourceIdentity    UlData_puschReceiveReqGrant_t.numOfPuschSymbols
    ${bip_names}    OperatingSystem.List Files In Directory    ${log_path}   5GBipL2L1_filtering_off*.pcap*    ${True}
    Convert BIP To CSV By MCShark   @{bip_names}    ${OUTPUT_DIR}/srs.csv    ${filter}    ${csv_title_list}

Check Srs Period And NumOfPuschSymbols
    Convert BIP To CSV By MCShark For SRS Check    ${TEST_LOG_DIRECTORY}
    A2A_Check_CSV_Table    ${CURDIR}/../A2A/CB009169_C/CB009169_srs_period_numofpuschsymbols.ini    ${OUTPUT_DIR}/srs.csv

Check PatternID Of DL And UL For Multi Ues
    [Arguments]    ${csv_file_path}    ${start_ue_num}    ${end_ue_num}
    FOR    ${UE_ID}    IN RANGE    ${start_ue_num}    ${end_ue_num}+1
    ${UE_CRNTI}=    Get Crnti From Egate Log    ${UE_ID}
    Set Test Variable    ${UE_CRNTI}
    A2A_Check_CSV_Table    ${CURDIR}/../A2A/CB009169_C/CB009169_PatternId_DL.ini    output_dl.csv    ${csv_file_path}
    A2A_Check_CSV_Table    ${CURDIR}/../A2A/CB009169_C/CB009169_PatternId_UL.ini    output_ul.csv    ${csv_file_path}
    END

Check Muted Slots For Pcell
    [Arguments]    ${ini_file}     ${log_dir}
    ${res}    Run Keyword And Return Status      A2A_Check_CSV_Table
    ...    ${CURDIR}/../A2A/CB009169_C/${ini_file}    output_dl.csv    ${log_dir}
    Run Keyword If    '${res}'=='True'    Log To Console    '\n!!!Mute slot is abnormal...\n'
    Should Be True    '${res}'!='True'
    Log To Console    '\nPcell Mute slot is OK...\n'

Check Scheduled slots
    [Arguments]    ${ini_file}     ${log_dir}
    Log To Console    '\nCheck Scheduled slots...\n'
    ${res}    Run Keyword And Return Status      A2A_Check_CSV_Table
    ...    ${CURDIR}/../A2A/CB009169_C/${ini_file}    output_ul.csv    ${log_dir}
    Run Keyword If    '${res}'!='True'    Log To Console    '\n!!!Scheduled slot is abnormal...\n'
    Should Be True    '${res}'=='True'
    Log To Console    '\nScheduled slot is OK...\n'

Get Number
    [Arguments]    ${name}=dlFdSchedData.ackNack    ${content}=["ACK","NACK","DTX"]    ${logpath}=${TEST_LOG_DIRECTORY}/ttitrace/output_dl.csv
    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${logpath}    ${name}    ${content}    include    no
    ${count}    Get Length    ${data_list}
    [Return]    ${count}

Check Slot Type Muted From Gnb_syslog
    [Arguments]    @{slot_info}
    Log To Console    \nCheck Mute Slots slot from Gnb_syslog...
    ${real_muted_nums}    Set Variable    0
    ${syslog_names}    OperatingSystem.List Files In Directory    ${TEST_LOG_DIRECTORY}    Gnb_syslog_*    ${True}
    ${content_num}    OperatingSystem.Run    cat ${TEST_LOG_DIRECTORY}/Gnb_syslog_*|grep -i "SLOT_TYPE_MUTED"|wc -l
    Should Be True    ${content_num}>1
    ${content}    OperatingSystem.Run    cat ${TEST_LOG_DIRECTORY}/Gnb_syslog_*|grep -i "SLOT_TYPE_MUTED"
    ${slot_items}    Get Length    ${slot_info}
    FOR    ${index}    IN RANGE    0    ${slot_items}
        ${slot_nums}    Set Variable    0
        ${slot}    Get Regexp Matches    ${content}    (Slot[\\s\\S]${slot_info}[${index}])    1
        ${slot_nums}    Get Length    ${slot}
        Should Be True    ${slot_nums}>=1
        ${real_muted_nums}    Evaluate    ${real_muted_nums}+${slot_nums}
    END
    Should Be True    ${content_num} == ${real_muted_nums}

Check 7737 Actived
    [Arguments]    ${csv_file_path}    ${case_id}
    A2A_Check_CSV_Table    ${CURDIR}/../A2A/CB009169_C/${case_id}.ini    output_dl.csv    ${csv_file_path}

Check DL DTXNACK Rate
    [Arguments]    ${csv_file_path}
    Check Rate    ${csv_file_path}    output_dl.csv    dlFdSchedData.ackNack    ["ACK", "NACK","DTX"]    ["NACK","DTX"]
    Check Rate    ${csv_file_path}    output_dl.csv    dlFdSchedData.speculativeDtxAckDtx    ["ACK", "NACK","DTX"]    ["NACK","DTX"]
    Check Rate    ${csv_file_path}    output_dl.csv    dlHarqRxDataArray.dtx    ["NON_DTX","DTX"]    ["DTX"]

Check UL DTXCRC Rate
    [Arguments]    ${csv_file_path}
    Check Rate    ${csv_file_path}    output_ul.csv    ulHarqRxData.crcResult    ["OK","NOK"]    ["NOK"]
    Check Rate    ${csv_file_path}    output_ul.csv    ulHarqRxData.dtx    ["NON_DTX","DTX"]    ["DTX"]

Convert BIP To CSV By MCShark For CB009169-UPD006
    [Arguments]    ${SCellID}    ${cell_id}    ${drxprofile}
    ${filter}=    Set Variable    (${BIP_FILTER1}&&(${BIP_FILTER2} == ${SCellID})) || ((${BIP_FILTER3} == ${cell_id}))
    @{csv_title_list}=    Create List    3gpp.sfn    3gpp.slot    itf_l2_ps_peerctrl_ScellDrxState_t.isInactivityTimerOn
    ...    itf_l2_ps_peerctrl_ScellDrxInactivityTimerStatusInd_t.sCellNrCellIdentity
    ${bip_names}    OperatingSystem.List Files In Directory    ${OUTPUT_DIR}   5GBipL2L1_filtering_off${drxprofile}.pcap*    ${True}
    FOR    ${index}    ${name}    IN ENUMERATE    @{bip_names}
         Convert BIP To CSV By MCShark   ${name}    ${OUTPUT_DIR}/csv_drx_${drxprofile}.csv    ${filter}    ${csv_title_list}
    END

Check Pmax Info From Gnb_syslog
    [Arguments]    ${pcell_pmax}=23    ${scell_pmax}=23    ${bandcomb_pmax}=26
    Log To Console    \nCheck Pmax Info from Gnb_syslog...
    ${syslog_names}    OperatingSystem.List Files In Directory    ${TEST_LOG_DIRECTORY}    Gnb_syslog_*    ${True}
    ${pcell_info}    OperatingSystem.Run
    ...    cat ${TEST_LOG_DIRECTORY}/Gnb_syslog_*|grep -i "pcell minOfPmax ${pcell_pmax}, bandCombinationPowerClass ${bandcomb_pmax}"|wc -l
    Should Be True    ${pcell_info}>=1
    ${scell_info}    OperatingSystem.Run
    ...    cat ${TEST_LOG_DIRECTORY}/Gnb_syslog_*|grep -i "scell minOfPmax ${scell_pmax}, bandCombinationPowerClass ${bandcomb_pmax}"|wc -l
    Should Be True    ${scell_info}>=1

Check 5QI-9 Is Correct
    ${ret1}=    OperatingSystem.Run    cat /opt/iphy/latest/egate_console.log
    Should Contain    ${ret1}=    Setup QosFlow with QFI:1 5QI:9
    Should Contain    ${ret1}=    ul-AM-RLC
    Should Contain    ${ret1}=    dl-AM-RLC
    Should Not Contain    ${ret1}=    dl-UM-RLC
    Should Not Contain    ${ret1}=    ul-UM-RLC

Trigger UE 5QI6 setup successfully
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qosflows_to_add}=2
    ${ret1}=    Execute Egate Command    cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qosflows_to_add} by=amf
    ...    pass_regexp=QoS Routing Table    timeout=20s
    Sleep    2s    Reason=Wait for 5QI6 setup successfully
    Should Contain    ${ret1}=    Adding QosFlow with QFI:${qosflows_to_add} 5QI:6
    Should Contain    ${ret1}=    ul-UM-RLC
    Should Contain    ${ret1}=    dl-UM-RLC
    Should Not Contain    ${ret1}=    dl-AM-RLC
    Should Not Contain    ${ret1}=    ul-AM-RLC

Start 5QI-6 And 5QI-9 Traffic And Check For UPD011
    #5QI-6  traffic
    Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=2 dir\=ul trf_id\=1 mbps\=80 protocol\=tcp    pass_regexp=Started Uplink
    Sleep    1s    Reason=Wait for traffic stable
    Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=2 dir\=dl trf_id\=1 mbps\=175 protocol\=tcp    pass_regexp=Started Downlink
    Sleep    1s    Reason=Wait for traffic stable
    Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=2 dir=\dl trf_id\=2 mbps\=175 protocol\=tcp    pass_regexp=Started Downlink
    Sleep    5s    Reason=Wait for scells activate.
    #5QI-9 traffic
    Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=ul trf_id\=1 mbps\=80 protocol\=tcp    pass_regexp=Started Uplink
    Sleep    1s    Reason=Wait for traffic stable
    Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl trf_id\=1 mbps\=175 protocol\=tcp    pass_regexp=Started Downlink
    Sleep    1s    Reason=Wait for traffic stable
    Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl trf_id\=2 mbps\=175 protocol\=tcp    pass_regexp=Started Downlink
    Sleep    1s    Reason=Wait for traffic stable
    Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl trf_id\=3 mbps\=175 protocol\=tcp    pass_regexp=Started Downlink
    Sleep    1s    Reason=Wait for traffic stable
    Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl trf_id\=4 mbps\=175 protocol\=tcp    pass_regexp=Started Downlink
    Sleep    1s    Reason=Wait for traffic stable
    Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl trf_id\=5 mbps\=175 protocol\=tcp    pass_regexp=Started Downlink
    #check point 4.1
    Wait Until Keyword Succeeds    1min    3s    Execute Egate Command    cmd=ue_stats_nr id\=1 type\=pdsch scell\=0-3    pass_regexp=CellIndex
    Wait Until Keyword Succeeds    1min    3s    Execute Egate Command    cmd=ue_stats_nr id\=1 type\=pusch scell\=0-3    pass_regexp=CellIndex
    #check point 4.2
    ${ul_pcell}      Get CA Cell Average Throughput    1    ul    pcell    0
    ${ul_scell_2}    Get CA Cell Average Throughput    1    ul    pcell    2
    ${dl_pcell}      Get CA Cell Average Throughput    1    dl    pcell    0
    ${dl_scell_1}    Get CA Cell Average Throughput    1    dl    pcell    1
    ${dl_scell_2}    Get CA Cell Average Throughput    1    dl    pcell    2
    ${dl_scell_3}    Get CA Cell Average Throughput    1    dl    pcell    3
    Should Be True    ${ul_pcell}!=0

Trigger 5QI9 Release And Check
    ${ret1}=    Execute Egate Command    cmd=ue_pdu_session_modify ue\=1 pdu\=1 qosflows_to_del\=1 by\=amf
    ...    pass_regexp=deactivated successfully at airphone    timeout=20s
    Should Contain    ${ret1}=    AMF-1: Deleting QosFlow with QFI:1 5QI:9
    Should Contain    ${ret1}=    UPF-1: Deleted QoSFlow with QFI 1
    Should Contain    ${ret1}=    UE1: Ue 1 PduId 1 Removed FiveQi:Qfi mapping fiveQi 9 qfi 1
    #check point 5.1
    Sleep    10s    Reason=Wait for traffic stable
    Wait Until Keyword Succeeds    1min    3s    Execute Egate Command    ue_stats_nr id\=1 type\=pdsch scell\=0-31
    Wait Until Keyword Succeeds    1min    3s    Execute Egate Command    ue_stats_nr id\=1 type\=pusch scell\=0-31
    
Check 5QI6 Scheduled From BIP
    [Arguments]    ${log_id}=1
    Log To Console  \nverify 5QI6 Scheduled the ${log_id}time...
    #check dl   
    ${filter}=    Catenate    mac-nr.dlsch.lcid==0x05
    @{csv_title_list}=    Create List    3gpp.subcellid    mac-nr.dlsch.lcid
    Convert BIP to CSV By MCShark    ${TEST_LOG_DIRECTORY}/bip/${log_id}/5GBipL2L1_filtering_off.pcap
    ...    ${TEST_LOG_DIRECTORY}/bip/dlsch_lcid${log_id}.csv    ${filter}    ${csv_title_list}
    ${value1}    Read Csv Columns    ${TEST_LOG_DIRECTORY}/bip/dlsch_lcid${log_id}.csv    3gpp.subcellid
    ${subcellid_list1}     Evaluate      list(set(${value1}))
    ${filter}=    Catenate    dldata_pdschsendreq && 3gpp.dmrsScramblingSequenceInt == 60
    @{csv_title_list}=    Create List    3gpp.subcellid    3gpp.dmrsScramblingSequenceInt
    Convert BIP to CSV By MCShark    ${TEST_LOG_DIRECTORY}/bip/${log_id}/5GBipL2L1_filtering_off.pcap
    ...    ${TEST_LOG_DIRECTORY}/bip/dlsch_lcid${log_id}_2.csv    ${filter}    ${csv_title_list}
    ${value2}    Read Csv Columns    ${TEST_LOG_DIRECTORY}/bip/dlsch_lcid${log_id}_2.csv    3gpp.subcellid
    ${subcellid_list2}     Evaluate      list(set(${value2}))
    Should Be True    ${subcellid_list1} == ${subcellid_list2}
    #check ul 
    ${filter}=    Catenate    mac-nr.ulsch.lcid==0x05
    @{csv_title_list}=    Create List    3gpp.subcellid    mac-nr.ulsch.lcid
    Convert BIP to CSV By MCShark    ${TEST_LOG_DIRECTORY}/bip/${log_id}/5GBipL2L1_filtering_off.pcap
    ...    ${TEST_LOG_DIRECTORY}/bip/ulsch_lcid${log_id}.csv    ${filter}    ${csv_title_list}
    ${value1}    Read Csv Columns    ${TEST_LOG_DIRECTORY}/bip/ulsch_lcid${log_id}.csv    3gpp.subcellid
    ${subcellid_ullist1}     Evaluate      list(set(${value1}))
    ${filter}=    Catenate    uldata_puschreceivereq && (3gpp.dmrsScramblingSequenceInt == 60||3gpp.dmrsScramblingSequenceInt == 52)
    @{csv_title_list}=    Create List    3gpp.subcellid    3gpp.dmrsScramblingSequenceInt
    Convert BIP to CSV By MCShark    ${TEST_LOG_DIRECTORY}/bip/${log_id}/5GBipL2L1_filtering_off.pcap
    ...    ${TEST_LOG_DIRECTORY}/bip/ulsch_lcid${log_id}_2.csv    ${filter}    ${csv_title_list}
    ${value2}    Read Csv Columns    ${TEST_LOG_DIRECTORY}/bip/ulsch_lcid${log_id}_2.csv    3gpp.subcellid
    ${subcellid_ullist2}     Evaluate      list(set(${value2}))
    [Return]    ${subcellid_list1}    ${subcellid_list2}    ${subcellid_ullist1}    ${subcellid_ullist2}

Check Power Split State
    [Arguments]    ${log_dir}
    A2A_Check_CSV_Table    ${CURDIR}/../A2A/CB009169_C/ttitrace_powersplit_state.ini    output_ul.csv    ${log_dir}

Check L1Pool Info From Gnb_syslog
    [Arguments]    ${nrcellid}    ${l1SubPoolId}=1
    Log To Console    \nCheck L1 Info from Gnb_syslog...
    ${syslog_names}    OperatingSystem.List Files In Directory    ${TEST_LOG_DIRECTORY}    Gnb_syslog_*    ${True}
    ${reg_dl}    Set Variable    NrCellId:${nrcellid} l1PoolId:\\d+ l1SubPoolId:${l1SubPoolId} dir:DOWNLINK
    ${reg_ul}    Set Variable    NrCellId:${nrcellid} l1PoolId:\\d+ l1SubPoolId:${l1SubPoolId} dir:UPLINK
    ${output}    OperatingSystem.Run    cat ${TEST_LOG_DIRECTORY}/Gnb_syslog_*|grep -i NrCellIdentityNumberOfPrbManagerMapper
    Should Match Regexp    ${output}    ${reg_dl}
    Should Match Regexp    ${output}    ${reg_ul}

Check L1Pool Info Of Three TDDs
    Check L1Pool Info From Gnb_syslog    16385    1
    Check L1Pool Info From Gnb_syslog    16387    0
    Check L1Pool Info From Gnb_syslog    16390    0

Check Adapt Retransmission 
    [Arguments]    ${save_log_directory}    ${ini_file}=${CURDIR}/../A2A/CB009169_C/CB009169_CB023_adaptRetrans.ini
    A2A_Check_CSV_Table    ${ini_file}    ${save_log_directory}/output_ul.csv    ${save_log_directory}

Check Nums Of Allocated Pool Resources Decreased
    [Arguments]    ${save_log_directory}    ${cellid}=55
    ${ret}    Read Csv Columns    ${save_log_directory}/output_ul.csv    ulAllocatedPooledResourcesData.numAllocCellPrbUl
    ...    filter=physCellId=${cellid}
    Log    ${ret}
    Should be True     ${ret[0]}>${ret[-1]}

Check Srsreceivereq With A2A
    [Arguments]    ${log_id}    ${file_ini}
    Convert BIP To CSV By MCShark For UlData_SrsReceiveReq With Slots    ${log_id}
    Run    sed -i 's/"//g' ${TEST_LOG_DIRECTORY}/${log_id}/csv_Srsreceivereq.csv
    A2A_Check_CSV_Table    ${CURDIR}/../A2A/CB009169_C/${file_ini}    ${TEST_LOG_DIRECTORY}/${log_id}/csv_Srsreceivereq.csv
    ...    ${TEST_LOG_DIRECTORY}/${log_id}
