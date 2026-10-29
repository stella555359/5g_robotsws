*** Settings ***

*** Variables ***
${PCELL_PCI}                   52
${WTS_DIR}    /opt/iphy/latest
#${CUR_WTS_DIR}       /opt/iphy/latest
${LOCAL_WTS_DIR}      ${CURDIR}/config/WTS_CFG
${LOCAL_IPHY_DIR}     ${CURDIR}/config/IPHY
${LOCAL_CFG_DIR}      ${CURDIR}/config/
${RIGHT_GNB_SH}       ABIO_BIP_mirroring_2slot_right.sh
${config_path}        ${EMPTY}
${WTS_XML}            wts_ASIB_ABIO_L1BYPASS.xml
${gNB_swconfig}    swconfig_gnb.txt
${ap_swconfig}     swconfig_ap.txt
${GNB2_XN_ADDR}        10.0.3.151/32
${GNB2_NG_ADDR}        10.0.3.153/32
${PROXY_SERVER2_IP}    192.168.6.252/32

&{GNB_ASIK}       ip=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=GNBDU
&{AP_ASIK}        ip=192.168.200.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=AP

*** Keywords ***
Capture TTItrace
    Log To Console     start ttitrace...
    Start Ttitrace With Streaming Mode
    Sleep    3s    reason=Wait for logs
    Stop Ttitrace    log_dir=${OUTPUT_DIR}

Common Suite Setup
    Suite Setup Update GNB    log=${False}
    Modify UTE SCTP Timeout
    Modify AP SCTP Timeout
    Configure UTE ETH3
    Set SCF Path
    Deploy GNB BIP Script

Set SCF Path
    [Documentation]    This keyword is to set the direcotry of delta json.
    Log To Console    ${SW_VERSION}
    Set Suite Variable    ${SCF_DIR}    ${CURDIR}/config/${SW_VERSION}/SCF
    Log To Console    ${SCF_DIR}

Deploy GNB BIP Script
    [Documentation]    This keyword is to deploy gnb bip script to gnb
    Log To Console    start deploy gNB BIP script...
    OperatingSystem.Run And Return Rc And Output    scp ${LOCAL_CFG_DIR}/${RIGHT_GNB_SH} toor4nsn@192.168.255.1:/user/toor4nsn/

Setup TL For Each Case
    [Arguments]    ${scf_file}    ${iphy_name}    ${wts_cfg_name}    ${wts_xml_name}
    Verify Coam Site Is Ready
    ###Send Swconfig for GNB    ${LOCAL_CFG_DIR}/${gNB_swconfig}
    ###Send Swconfig for AP    ${LOCAL_CFG_DIR}/${ap_swconfig}
    Modify IPHY File And Send to Airphone    ${LOCAL_IPHY_DIR}/${iphy_name}
    #Configure Gnb With Full SCF For Local TL    ${scf_file}
    Suite Setup Update GNB    scf_file=${scf_file}
    Sleep    60s    \nFor Site reset
    Verify Coam Site Is Ready With New Cfg
    Set WTS Files Name For Each Cases    ${wts_cfg_name}    ${wts_xml_name}
    Common Test Setup 2
    Start UTE WTS And Check Cell Setup    ${wts_cfg_name}

Start UTE WTS And Check Cell Setup For B04
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
    Sleep     90s    \nFor each scells status
#    Verify Cell Setup
    Sleep    60s    wait for all cells' sib come up...\n

Setup TL For Each Case For B04
    [Arguments]    ${scf_file}    ${iphy_name}    ${wts_cfg_name}    ${wts_xml_name}
    Verify Coam Site Is Ready
    ###Send Swconfig for GNB    ${LOCAL_CFG_DIR}/${gNB_swconfig}
    ###Send Swconfig for AP    ${LOCAL_CFG_DIR}/${ap_swconfig}
    Modify IPHY File And Send to Airphone    ${LOCAL_IPHY_DIR}/${iphy_name}
    #Configure Gnb With Full SCF For Local TL    ${scf_file}
    Suite Setup Update GNB    scf_file=${scf_file}
    Sleep    60s    \nFor Site reset
    Verify Coam Site Is Ready With New Cfg
    Set WTS Files Name For Each Cases    ${wts_cfg_name}    ${wts_xml_name}
    Common Test Setup 2
    Start UTE WTS And Check Cell Setup For B04    ${wts_cfg_name}

Setup TL For B04
    [Arguments]    ${scf_file}    ${iphy_name}    ${wts_cfg_name}    ${wts_xml_name}
    ${status}    Run Keyword And Return Status    Setup TL For Each Case For B04     ${scf_file}    ${iphy_name}    ${wts_cfg_name}    ${wts_xml_name}
    Run Keyword If    '${status}'=='False'    Run Keywords    common_log_capture.Teardown All Connections
    ...    AND    ute_wtssim.Teardown All Aliases For Wts
    ...    AND    Run Keyword And Ignore Error    Stop Edaemon Egate
    ...    AND    Hard Reboot Testline
    ...    AND    Setup TL For Each Case For B04     ${scf_file}    ${iphy_name}    ${wts_cfg_name}    ${wts_xml_name}


Full Commission With SCF File For UTE
    [Arguments]    ${scf_file}
    [Documentation]    This keyword is to update parameters with delta file
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | scf_file | Yes | SCF file name.It usual exist in ${scf_path}/${SW_BRANCH}/SCF/${scf_file}. |
    ...    |  |  | ${SW_BRANCH} is get in keyword 'Suite Setup Update GNB', like 5G20A |
    ...
    ...    Examples:
    ...    | *** Variables *** |
    ...    | ${scf_path} | Set Variable | ${CURDIR}/config |
    ...    | Full Commission With SCF File | SCF_5GC002504.xml |    |
    ...    Example2:
    ...    | ${scf_file} | Set Variable | ${CURDIR}/scf.xml |
    ...    | Full Commission With SCF File | ${scf_file} |    |
    Log To Console    Perform full commissioning，please use the scf with full configuration saved.
    #Get Software Version
    #${scf_pull_path}=    Check Config File Absolute Path Or Relative Path    ${scf_file}
    ${NRBTS_DISTNAME}    Set Variable If    '${NRBTS_DISTNAME}'==''    MRBTS-1/NRBTS-1    ${NRBTS_DISTNAME}
    Modify File Parameter    ${SCF_DIR}/${scf_file}    MRBTS-[0-9]+/NRBTS-[0-9]+    ${NRBTS_DISTNAME}
    Modify VlanId In SCF File    ${SCF_DIR}/${scf_file}
    ${new_scf_path}    Run Keyword If    "${ENB_BUILD}"=="SBTS"    Migration SCF To New Release    ${SCF_DIR}/${scf_file}
    ${new_scf_path}=    Set Variable If    "${new_scf_path}"=="${None}"    ${SCF_DIR}/${scf_file}    ${new_scf_path}
    File Should Exist    ${new_scf_path}
    ${bts_id}    Get Regexp Matches    MRBTS-1/NRBTS-1    MRBTS-(?P<bts_id>\\d+)\\/    bts_id
    COAM.Setup Admin
    COAM.Perform Commissioning
    ...    bts_id=${bts_id[0]}
    ...    scf_file=${new_scf_path}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=300
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown

Verify Coam Site Is Ready With New Cfg
    ${res}    Run Keyword And Return Status    Verify Coam Site Is Ready
    Run Keyword If    '${res}'=='False'    Reboot TL And Check Configured
	
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

Verify TDD 2Scells Addition
    [Arguments]    ${physCellId_1}=53    ${physCellId_2}=54
    ute_wtssim.Execute Egate Command    sim_log_set flush
    ${Scellindex}=    Set Variable    sCellIndex[\\s\\S]{1,150}physCellId\\s(\\d{1,2})
    ${content}=    OperatingSystem.Get File    ${WTS_DIR}/egate_console.log
    ${Scellindex_list}=    String.Get Regexp Matches    ${content}    ${Scellindex}    1
    List Should Contain Value    ${Scellindex_list}    ${physCellId_1}
    List Should Contain Value    ${Scellindex_list}    ${physCellId_2}

SA Start UL Traffic
    [Arguments]    ${mbps}=10    ${duration}=10    ${len}=1300
    [Documentation]    This keyword is to start UL traffic by iperf.
    ...    | Input Parameters | Man. | Description |
    ...    | mbps | Yes | mbps, default is 10M |
    ...    | duration | Yes | duration, default is 10s |
    ...    | len  | Yes | traffic length, default is 1300 Byte |
    ...    Example:
    ...    | SA Start UL Traffic | 10 | 10 | 1300 |
    Log To Console                     start UL traffic...
    Execute Iperf In Linux             args=-c 72.23.0.1 -u -p ${UL_PORT} -l ${len} -b ${mbps}M -i 1 -t ${duration}
    Execute Iperf In Linux             args=-s -u -p ${UL_PORT} -i 1 -B 10.0.2.1
    ...                                pipe_args=| tee /tmp/iperf_ul.txt
    Log To Console                     Running UL Traffic ${mbps}M for ${duration}s

SA Start DL TrafficWithPort
    [Arguments]    ${mbps}=10    ${duration}=10    ${PORT}=7070    ${len}=1300
    [Documentation]    This keyword is to start DL traffic by iperf.
    ...    | Input Parameters | Man. | Description |
    ...    | mbps | Yes | mbps, default is 10M |
    ...    | duration | Yes | duration, default is 10s |
    ...    | len  | Yes | traffic length, default is 1300 Byte |
    ...    Example:
    ...    | SA Start DL Traffic | 10 | 10 | 1300 |
    Log To Console                     \nstart DL traffic...
    Execute Iperf In Linux             args=-c 1.2.4.2 -u -p ${PORT} -l ${len} -b ${mbps}M -i 1 -t ${duration}
    Execute Iperf In Linux             args=-s -u -p ${PORT} -i 1 -B 10.0.2.1
    ...                                pipe_args=| tee /tmp/iperf_dl${PORT}.txt
    Log To Console                     Running DL Traffic ${mbps}M for ${duration}s

Verfiy Scells Are Activation
    [Arguments]    ${cell_nums}    ${times}    ${scell_index_start}=1
    Log To Console    \nverify Scell Activation Info...
    ute_wtssim.Execute Egate Command    sim_log_set flush
    FOR    ${id}    IN RANGE    ${scell_index_start}    ${cell_nums}
    ${scell_activation}    Set Variable    SCellIndex ${id} activated successfully.
    ${check_rst}    Run    cat ${WTS_DIR}/egate_console.log|grep -i "${scell_activation}"|wc -l
    Should Be True    ${check_rst}==${times}
    END

Verfiy Scells Are Activation After Deactive
    [Arguments]    ${cell_nums}    ${times}    ${scell_index_start}=1
    Log To Console    \nverify Scell Activation Info...
    ute_wtssim.Execute Egate Command    sim_log_set flush
    FOR    ${id}    IN RANGE    ${scell_index_start}    ${cell_nums}
    ${scell_activation}    Set Variable    SCellIndex ${id} activated successfully.
    ${check_rst}    Run    cat ${WTS_DIR}/egate_console.log|grep -i "${scell_activation}"|wc -l
    Should Be True    ${check_rst}>=${times}
    END

Get And Check Cells TP For DL after Scell Addition
    [Arguments]    ${dir}    ${cell_nums}
    sleep    60s    reason=Wait for average traffic is stable.
    ${pcell_tput}    Get CA Cell Average Throughput    1    ${dir}    pcell    0
    Should Be True    ${pcell_tput}>0    Pcell Throughtput of ${dir} is abnormal.
    FOR    ${id}    IN RANGE    1    ${cell_nums}
        ${scell_tput}    Get CA Cell Average Throughput    1    ${dir}    scell    ${id}
        Should Be True    ${scell_tput}>0    Scell${id} Throughtput of ${dir} is abnormal.
    END

New Get And Check Cells TP For DL after Scell Addition
    [Arguments]    ${dir}    ${cell_nums}    ${Tpcell_tput}    ${Tscell_tput}
    sleep    40s    reason=Wait for average traffic is stable.
    ${pcell_tput}    Get CA Cell Average Throughput    1    ${dir}    pcell    0
    Should Be True    ${pcell_tput}>=${Tpcell_tput}   Pcell Throughtput of ${dir} is abnormal.
    FOR    ${id}    IN RANGE    1    ${cell_nums}
        ${scell_tput}    Get CA Cell Average Throughput    1    ${dir}    scell    ${id}
        Should Be True    ${scell_tput}>=${Tscell_tput}    Scell${id} Throughtput of ${dir} is abnormal.
    END

Get And Check Tput for UL
    [Arguments]    ${dir}    ${Tpcell_tput}
    ${pcell_tput}    Get CA Cell Average Throughput    1    ${dir}    pcell    0
    Should Be True    ${pcell_tput}>=${Tpcell_tput}   Pcell Throughtput of ${dir} is abnormal.

Check TP for B04 Before Scell change
    Wait Until Keyword Succeeds    3min    5s    New Get And Check Cells TP For DL after Scell Addition    dl    4    50    10
    Wait Until Keyword Succeeds    3min    5s    Get And Check Tput for UL     ul    5

Kill All Iperf Process
    [Documentation]    This keyword is to kill all iperf process.
    OperatingSystem.Run    ps -ef|grep iperf|grep -v grep| awk '{print $2}' |xargs sudo kill -9
	
Check Rate With Cell
    [Arguments]    ${physCellId}=0
    Check Rate    ${physCellId}    dlFdSchedData.ackNack    ["ACK", "NACK","DTX"]    ["NACK","DTX"]
    Check Rate    ${physCellId}    dlFdSchedData.speculativeDtxAckDtx    ["ACK", "NACK","DTX"]    ["NACK","DTX"]
    Check Rate    ${physCellId}    dlHarqRxDataArray.dtx    ["NON_DTX","DTX"]    ["DTX"]

Check Rate
    [Arguments]    ${name}=dlFdSchedData.ackNack    ${total}=["ACK", "NACK","DTX"]    ${failed}=["NACK","DTX"]
    [Documentation]    This keyword is to check rate.
    ...    | Input Parameters | Man. | Description |
    ...    | name | Yes |the column title to check, default is dlFdSchedData.ackNack |
    ...    | total | Yes | all the status , default is ["ACK", "NACK","DTX"]|
    ...    | failed  | Yes | failed status, default is ["NACK","DTX"] |
    ...    Example:
    ...    | Check Rate | dlFdSchedData.ackNack | ["ACK", "NACK","DTX"] | ["NACK","DTX"] |
    ${total_number}    Get Total Number    ${name}    ${total}
    ${failed_number}    Get Total Failed Number    ${name}    ${failed}
    ${rate}    Evaluate    float(${failed_number})/(${total_number})
    Log To Console    \n${name} rate is ${rate}\n
    Should Be True    ${rate}<0.1
	
Get Total Number
    [Arguments]    ${name}=dlFdSchedData.ackNack    ${total}=["ACK", "NACK","DTX"]
    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${OUTPUT_DIR}/output_dl.csv    ${name}    ${total}    include    no
    ${count}    Get Length    ${data_list}
    [Return]    ${count}
	
Get Total Failed Number
    [Arguments]    ${name}=dlFdSchedData.ackNack    ${failed}=["NACK","DTX"]
    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${OUTPUT_DIR}/output_dl.csv    ${name}     ${failed}    include    no
    ${count}    Get Length    ${data_list}
    [Return]    ${count}
	
	
Check ACSI Not Configed
    ute_wtssim.Execute Egate Command    sim_log_set flush
    ${check_rst}    Run    cat ${WTS_DIR}/egate_console.log|grep -i reportConfigType
    Should Not Contain    ${check_rst}    aperiodic

Verfiy CSIRS Number
    [Arguments]    ${csirs_nums}
    Log To Console    \nverify CSIRS Number Info...
    ute_wtssim.Execute Egate Command    sim_log_set flush
    ${csirs_activation}    Set Variable    nrofPorts p8
    ${check_rst}    Run    cat ${WTS_DIR}/egate_console.log|grep -i "${csirs_activation}"|wc -l
    Should Be True    ${check_rst}==${csirs_nums}

SA Stop DL Data Traffic Internal
    [Arguments]    ${ue_id}    ${pdu_id}
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue\=${ue_id} pdu\=${pdu_id} dir=dl

Scell Addition Triggered By A1 Event
    [Arguments]    ${ue_id}=1    ${meas_id}=1    ${srsrp_nr}=100
    ${output}=    ute_wtssim.execute egate command and wait for data
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${srsrp_nr}
    #...    pass_regexp=activated successfully    timeout=60
    Log To Console    \n${output}
    sleep    5s    reason=Wait for Scell Addition ...

Verify TDD Scells Addition
    [Arguments]    ${scellid1}=53    ${scellid2}=54
    ute_wtssim.Execute Egate Command    sim_log_set flush
    ${Scellindex}=    Set Variable    sCellIndex[\\s\\S]{1,150}physCellId\\s(\\d{1,2})
    ${content}=    OperatingSystem.Get File    ${WTS_DIR}/egate_console.log
    ${Scellindex_list}=    String.Get Regexp Matches    ${content}    ${Scellindex}    1
    List Should Contain Value    ${Scellindex_list}    ${scellid1}
    List Should Contain Value    ${Scellindex_list}    ${scellid2}

Trigger A2 Release
   [Arguments]    ${UE_ID}    ${meas_id}=1    ${SCellIndex}=1    ${phyid}=50
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=${meas_id} event=A2 scell=${SCellIndex} scell_rsrp=20 phycell_id=${phyid}
    ...    pass_regexp=rrcReconfigurationComplete

Check ACSI from TTI
    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${OUTPUT_DIR}/output_dl.csv    csiSrReportData.reportType    ["APERIODIC_CSI"]    include    no
    ${count}    Get Length    ${data_list}
    Should Be True    ${count}>1

Check NO ACSI from TTI
    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${OUTPUT_DIR}/output_dl.csv    csiSrReportData.reportType    ["APERIODIC_CSI"]    include    no
    ${count}    Get Length    ${data_list}
    Should Be True    ${count}==0

Get sCellToReleaseList
    ${sCellToReleaseList}=    Set Variable    sCellToReleaseList[\\s\\S]{1,35}(\\d{1,2})
#    ${content}=    OperatingSystem.Get File    ${CURDIR}/egate_console.log
    ${content}=    OperatingSystem.Get File    /opt/iphy/latest/egate_console.log
    ${sCellToRelease_list}=    String.Get Regexp Matches    ${content}    ${sCellToReleaseList}    1
    [Return]    ${sCellToRelease_list}

SA Start Traffic Internal
    [Arguments]    ${ue_id}    ${pdu_id}    ${mbps}
    SA Start DL Traffic Internal    ${ue_id}     ${pdu_id}    ${mbps}    trf_id=1
    SA Start DL Traffic Internal    ${ue_id}     ${pdu_id}    ${mbps}    trf_id=2
    SA Start DL Traffic Internal    ${ue_id}     ${pdu_id}    ${mbps}    trf_id=3
    SA Start DL Traffic Internal    ${ue_id}     ${pdu_id}    ${mbps}    trf_id=4
    SA Start DL Traffic Internal    ${ue_id}     ${pdu_id}    ${mbps}    trf_id=5
    SA Start DL Traffic Internal    ${ue_id}     ${pdu_id}    ${mbps}    trf_id=6
    SA Start UL Traffic Internal    ${ue_id}     ${pdu_id}    ${mbps}    trf_id=1
    Sleep    25s    reason=Wait for traffic stable

Start SA UE More small DL Traffic Internal
    [Arguments]    ${ue_id}    ${mbps}    ${mbpsPtrf}    ${trf_id}=1
    [Documentation]    This keyword is to start single UE big dl udp traffic which more than 175.
    ${dl_times}    Evaluate    int(${mbps}/${mbpsPtrf})
    ${pdu_id}    Calculate PDUID    ${ue_id}
    FOR    ${t_time}    IN RANGE    1    ${dl_times}+1
        SA Start DL Traffic Internal    ${ue_id}    ${pdu_id}    mbps=${mbpsPtrf}    trf_id=${t_time}
        Sleep   30s     reason=Wait for traffic stable
    END
    ${last_mbps}    Evaluate    ${mbps}-${mbpsPtrf}*${dl_times}
    SA Start DL Traffic Internal    ${ue_id}    ${pdu_id}    mbps=${last_mbps}    trf_id=${dl_times+1}

SA Stop Data Traffic Internal By Trfid
    [Arguments]    ${ue_id}    ${pdu_id}    ${trf_id}
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue\=${ue_id} pdu\=${pdu_id} trf_id\=${trf_id}

SA Stop Traffic Internal To Trigger Scell Deactivated
    [Arguments]    ${ue_id}    ${mbps}
    [Documentation]    this keyword is to stop big dl udp traffic to trigger scell deactivated one by one.
    ${dl_times}    Evaluate    int(${mbps}/${80})
    ${pdu_id}    Calculate PDUID    ${ue_id}
    : FOR    ${t_time}    IN RANGE    2    ${dl_times}+2
        SA Stop Data Traffic Internal By Trfid    ${UE_ID}    ${pdu_id}   trf_id=${t_time}
        Sleep   40s     reason=Wait for traffic stable
    END

Start SA UE DL Traffic Internal To Active Scell
    [Arguments]    ${ue_id}    ${mbps}    ${trf_id}=1
    [Documentation]    This keyword is to start single UE big dl udp traffic which more than 175.
    ${dl_times}    Evaluate    int(${mbps}/${60})
    ${pdu_id}    Calculate PDUID    ${ue_id}
    SA Start DL Traffic Internal    ${ue_id}    ${pdu_id}    mbps=175    trf_id=${dl_times}+1
    Sleep   25s     reason=Wait for traffic stable
    SA Start DL Traffic Internal    ${ue_id}    ${pdu_id}    mbps=175    trf_id=${dl_times}
    Sleep   25s     reason=Wait for traffic stable
    Verfiy Scells Are Activation    3    1

Capture And Decode TTItrace
    [Arguments]    ${file_name}
    Capture TTItrace
    Sleep    5s
    Log To Console    \nstart convert ttitrace to csv...\n
    Convert Ttitrace From Pcap To Excelcsv    ${OUTPUT_DIR}/
    OperatingSystem.Copy Files    ${OUTPUT_DIR}/output_dl.csv    ${SUITE_LOG_DIRECTORY}/${file_name}

Check DTXNACK Rate
    Check Rate    dlFdSchedData.ackNack    ["ACK", "NACK","DTX"]    ["NACK","DTX"]
    Check Rate    dlFdSchedData.speculativeDtxAckDtx    ["ACK", "NACK","DTX"]    ["NACK","DTX"]
    Check Rate    dlHarqRxDataArray.dtx    ["NON_DTX","DTX"]    ["DTX"]

Check A2 Release
	ute_wtssim.Execute Egate Command    sim_log_set flush
    sleep    5s
    Save Egate Log    log_path=${Egatelog_path}
    ${sCellToReleaseList}    Get sCellToReleaseList
    Log To Console    \nScellindex_list is ${sCellToReleaseList}\n
    List Should Contain Value    ${sCellToReleaseList}    1

Start small dl traffic and check deactivation
    CB007949_resource.SA Start DL TrafficWithPort    10    3600    7072
    SA Stop Traffic    7070
    sleep    10s    #for traffic stable
    Verfiy Scells Are Deactivation    3
    Get And Check Cells TP For DL after Scell Addition    dl    1

Start big dl traffic and chek activate again
    SA Start DL TrafficWithPort    1000    3600    7070
    sleep    10s    #for traffic stable
    Verfiy Scells Are Activation     4    2
    Get And Check Cells TP For DL after Scell Addition    dl    4
    SA Check Average Traffic Bigger Than Target    ul    5

SA Stop Traffic
    [Arguments]    ${PORT}
    OperatingSystem.Run    ps -ef|grep iperf|grep -v grep|grep ${PORT}| awk '{print $2}' |xargs sudo kill -9

Verfiy Scells Are Deactivation
    [Arguments]    ${scell_nums}
    Log To Console    \nverify Scell Deactivation Info...
    ute_wtssim.Execute Egate Command    sim_log_set flush
    FOR    ${id}    IN RANGE    1    ${scell_nums}
    ${scell_deactivation}    Set Variable    SCellIndex ${id} deactivated successfully.
    ${check_rst}    Run    cat /opt/iphy/latest/egate_console.log|grep -i "${scell_deactivation}"|wc -l
    Should Be True    ${check_rst}==1
    END

Verfiy Scells Are Deactivation for A03
    [Arguments]    ${scell_nums}
    Log To Console    \nverify Scell Deactivation Info...
    ute_wtssim.Execute Egate Command    sim_log_set flush
    FOR    ${id}    IN RANGE    1    ${scell_nums}
    ${scell_deactivation}    Set Variable    SCellIndex ${id} deactivated successfully.
    ${check_rst}    Run    cat /opt/iphy/latest/egate_console.log|grep -i "${scell_deactivation}"|wc -l
    Should Be True    ${check_rst}>=1
    END

Verify maxPayloadSize
    [Arguments]    ${maxPayload}
    ute_wtssim.Execute Egate Command    sim_log_set flush
    ${ret}    OperatingSystem.Run    cat ${WTS_DIR}/egate_console.log|grep maxPayloadSize
    Should Contain    ${ret}    ${maxPayload}

Check mute cells
    [Arguments]    ${case_id}
    ${res}    Run Keyword And Return Status      A2A_Check_CSV_Table
    ...    ${CURDIR}/Resource/ttitrace_slotmute${case_id}.ini    ${OUTPUT_DIR}/output_dl.csv
    Run Keyword If    '${res}'=='True'    Log To Console    '\n!!!Mute slot is abnormal...\n'
    Should Be True    '${res}'!='True'
    Log To Console    '\nMute slot is OK...\n'

Scell Change Triggered By A1 Event
    [Arguments]    ${ue_id}=1    ${meas_id}=1    ${srsrp_nr}=100
    ${output}=    ute_wtssim.execute egate command and wait for data
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${srsrp_nr}
    #...    pass_regexp=activated successfully    timeout=60
    Log To Console    \n${output}

Verify FDD Scells Addition
    ute_wtssim.Execute Egate Command    sim_log_set flush
    ${Scellindex}=    Set Variable    sCellIndex[\\s\\S]{1,150}physCellId\\s(\\d{1,2})
    ${content}=    OperatingSystem.Get File    ${WTS_DIR}/egate_console.log
    ${Scellindex_list}=    String.Get Regexp Matches    ${content}    ${Scellindex}    1
    List Should Contain Value    ${Scellindex_list}    50
    List Should Contain Value    ${Scellindex_list}    51
    List Should Contain Value    ${Scellindex_list}    54

Verfiy FDD Scells Are Activation
    [Arguments]    ${cell_nums}    ${times}
    Log To Console    \nverify FDD Scell Activation Info...
    ute_wtssim.Execute Egate Command    sim_log_set flush
    FOR    ${id}    IN RANGE    3    ${cell_nums}+2
    ${scell_activation}    Set Variable    SCellIndex ${id} activated successfully.
    ${check_rst}    Run    cat ${WTS_DIR}/egate_console.log|grep -i "${scell_activation}"|wc -l
    Should Be True    ${check_rst}==${times}
    END

Get And Check Cells TP For DL after Scell Change
    [Arguments]    ${dir}    ${cell_nums}    ${scellstart_id}
    ${pcell_tput}    Get CA Cell Average Throughput    1    ${dir}    pcell    0
    Should Be True    ${pcell_tput}>0    Pcell Throughtput of ${dir} is abnormal.
    FOR    ${id}    IN RANGE    ${scellstart_id}    ${cell_nums}+2
        ${scell_tput}    Get CA Cell Average Throughput    1    ${dir}    scell    ${id}
        Should Be True    ${scell_tput}>0    Scell${id} Throughtput of ${dir} is abnormal.
    END

Check TP for B04 After Scell change
    Wait Until Keyword Succeeds    3min    5s    Get And Check Cells TP For DL after Scell Change    dl    4    4
    Wait Until Keyword Succeeds    3min    5s    Get And Check Tput for UL    ul    5

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
    ${filter}=    Set Variable    (dldata_pdcchsendreq) && (DlData_DciInfo.dciScramblingSequenceInit == 52)
    @{csv_title_list}=    Create List    DlData_PdcchSendReq_t.beamId
    ${bip_names}    Set Variable    ${SUITE_LOG_DIRECTORY}_beamID${beamId}/5GBipL2L1_filtering_off.pcap
    Convert BIP To CSV By MCShark   ${bip_names}    ${OUTPUT_DIR}/${beamId}_Pdcchsendreq.csv    ${filter}    ${csv_title_list}

Check BeamID In Pdcchsendreq
    [Arguments]    ${beamId}
    ${data_list_1}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${OUTPUT_DIR}/${beamId}_Pdcchsendreq.csv    DlData_PdcchSendReq_t.beamId    ["${beamId}"]    include    no
    ${count1}    Get Length    ${data_list_1}
    Should Be True    ${count1}!=0

Check DL Rank
    Check Rate    dlFdSchedData.numOfLayers    ["RANK4", "RANK2"]    ["RANK2"]

Configure UE History Info For HO
    [Arguments]    ${real_gnb_id}    ${real_cell_id}    ${sim_gnb_id}    ${sim_cell_id}
    [Documentation]    This keyword is to configure Simulated GNB info and UE history info.
    Log To Console    configure VM interfaces...
    ${history_1}    Catenate    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x0${real_cell_id}
    ...    gnb_id=${real_gnb_id} time_ue_stayed_in_cell=97
    ${history_2}    Catenate    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x0${sim_cell_id}
    ...    gnb_id=${sim_gnb_id} time_ue_stayed_in_cell=98
    ${history_3}    Set Variable    ue_history_information_list id=1 action=commit
    ${history_4}    Set Variable    ue_enb_param id=1 ue_history_list=1
    ute_wtssim.Execute Egate Command    ${history_1}
    ute_wtssim.Execute Egate Command    ${history_2}
    ute_wtssim.Execute Egate Command    ${history_3}
    ute_wtssim.Execute Egate Command    ${history_4}
    ute_wtssim.Execute Egate Command    cmd=gnb_param id=3 xn_listening_socket=1 send_xn_setup=true measEvent=A3
    ${output}    ute_wtssim.Execute Egate Command    cmd=gnb_xn_link_up gnb=3 target=2
    ...    pass_regexp=is up    timeout=60
    Log To Console    ${output}

Configure VM Interface For HO
    [Arguments]    ${ip_addr_1}    ${ip_addr_2}    ${ip_addr_3}
    [Documentation]    This keyword is to configure HO related interfaces on VM interfaces including GNB2 NG, XN and proxy.
    Log To Console    configure VM interfaces...
    OperatingSystem.Run    sudo ip addr add ${ip_addr_1} dev eth3
    OperatingSystem.Run    sudo ip addr add ${ip_addr_2} dev eth3
    OperatingSystem.Run    sudo ip addr add ${ip_addr_3} dev eth2

Setup TL For CaseF03
    [Arguments]    ${scf_file}    ${iphy_name}    ${wts_cfg_name}    ${wts_xml_name}
    Verify Coam Site Is Ready
    Common Test Setup 2
    ###Send Swconfig for GNB    ${LOCAL_CFG_DIR}/${gNB_swconfig}
    ###Send Swconfig for AP     ${LOCAL_CFG_DIR}/${ap_swconfig}
    Modify IPHY File And Send to Airphone    ${LOCAL_IPHY_DIR}/${iphy_name}
    #Configure Gnb With Full SCF For Local TL    ${scf_file}
    Suite Setup Update GNB    scf_file=${scf_file}
    Sleep     60s     \nFor Site reset
    Verify Coam Site Is Ready With New Cfg
    Set WTS Files Name For Each Cases    ${wts_cfg_name}    ${wts_xml_name}
    Configure VM Interface For HO    ${GNB2_XN_ADDR}    ${GNB2_NG_ADDR}    ${PROXY_SERVER2_IP}
    Start UTE WTS And Check Cell Setup    ${wts_cfg_name}

Attach SA UE
    [Arguments]    ${UE_ID}=1
    SA 5G Attach    ue_id=${UE_ID}
    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
    SA 5G PDU Session Setup     ue_id=${UE_ID}

Check MeasConfig in RRCReconfiguration
    [Arguments]    ${egate_output}    ${checkpoint}
    ${egate_log}    Remove Blank Character    ${egate_output}
    FOR    ${i}    IN    @{checkpoint}
         ${i}    Remove Blank Character    ${i}
         should contain    ${egate_log}    ${i}

    END

Trigger A2 Event
    [Arguments]    ${meas_id}
    ${cmd}=    Set Variable    ue_measurement_send_nr id=1 meas_id=${meas_id} event=A2 srsrp_nr=8 srsrq_nr=8
    ${A2_egate_log}=    ute_wtssim.Execute Egate Command    ${cmd}    pass_regexp=eventA1
    Set Test Variable    ${A2_egate_log}
    sleep    2s

Check MeasGap Setup
    should contain    ${A2_egate_log}    gapOffset 0
    should contain    ${A2_egate_log}    mgl ms6
    should contain    ${A2_egate_log}    mgrp ms20
    should contain    ${A2_egate_log}    mgta ms0

Trigger A2 Event And Check MeasGap Setup
    [Arguments]    ${meas_id}
    Trigger A2 Event    ${meas_id}
    Check MeasGap Setup

Trigger A1 Event
    [Arguments]    ${meas_id}
    ${cmd}=    Set Variable    ue_measurement_send_nr id=1 meas_id=${meas_id} event=A1 srsrp_nr=76 srsrq_nr=76
    ${A1_egate_log}=    ute_wtssim.Execute Egate Command    ${cmd}    pass_regexp=eventA2
    Set Test Variable    ${A1_egate_log}
    sleep    2s


Check MeasGap Release
    [Arguments]    ${log_for_check}
    should contain    ${log_for_check}    gapUE release : NULL

Trigger A1 Event And Check MeasGap Release
    [Arguments]    ${meas_id}
    Trigger A1 Event    ${meas_id}
    Check MeasGap Release    ${A1_egate_log}

Get And Check Pcell TP For DL
    [Arguments]    ${dir}
    sleep    60s    reason=Wait for average traffic is stable.
    ${pcell_tput}    Get CA Cell Average Throughput    1    ${dir}    pcell    0
    Should Be True    ${pcell_tput}>0    Pcell Throughtput of ${dir} is abnormal.

Check DL Slot On Pcell And DTXNACK Rate
    [Arguments]    ${dir}    ${cell_nums}
    Capture TTItrace
    Sleep    5s
    Convert Ttitrace From Pcap To Excelcsv    ${OUTPUT_DIR}/
    Get And Check Cells TP For DL after Scell Addition    ${dir}    ${cell_nums}
    Check DTXNACK Rate

Inter-frequency HO To Sim GNB
    [Arguments]    ${meas_id}
    Log To Console
    ...    | SA 5G    start Intra-frequency handover from real gNB to simulated gNB for UE...
    ${ho_to_sim}    Catenate    ue_measurement_send_nr id=1 meas_id=${meas_id} event=A3 srsrp_nr=8 srsrq_nr=8 phycell_id=49
    ...    nrsrp_nr=30 nrsrq_nr=30 rs_type=ssb index=0 nrs_result=30:30:30
    ${output}    ute_wtssim.Execute Egate Command    ${ho_to_sim}
    ...    pass_regexp=PATH_SWITCH_REQUEST_ACK Received
    ...    timeout=3minutes
    Log To Console    ${output}

Inter-frequency HO To Real GNB
    [Arguments]    ${meas_id}
    Log To Console
    ...    | SA 5G    start Intra-frequency handover from simulated gNB to real gNB for UE...
    ${ho_to_real}    Catenate    ue_measurement_send_nr id=1 meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=52
    ...    nrsrp_nr=30 nrsrq_nr=30 rs_type=ssb index=0 nrs_result=30:30:30
    ${output}    ute_wtssim.Execute Egate Command    ${ho_to_real}
    ...    pass_regexp=PATH SWITCH REQUEST ACK [\\s\\S]+ to GNB - 2
    ...    timeout=3minutes
    Log To Console    ${output}

Verfiy Any Scell Is Deactivation
    Log To Console    \nverify Any Scell Deactivation Info...
    ute_wtssim.Execute Egate Command    sim_log_set flush
    ${scell_deactivation}    Set Variable    SCellIndex [0-9] deactivated successfully.
    ${check_rst}    Run    cat /opt/iphy/latest/egate_console.log|grep -i "${scell_deactivation}"|wc -l
    Should Be True    ${check_rst}>=1

Check mute cells for Pcell
    [Arguments]    ${case_id}
    ${res}    Run Keyword And Return Status      A2A_Check_CSV_Table
    ...    ${A2A_CHECK_DIR}/ttitrace_slotmute${case_id}_pcell.ini    ${OUTPUT_DIR}/output_dl.csv
    Run Keyword If    '${res}'=='True'    Log To Console    '\n!!!Mute slot is abnormal...\n'
    Should Be True    '${res}'!='True'
    Log To Console    '\nPcell Mute slot is OK...\n'

Check mute cells for Scell
    [Arguments]    ${case_id}
    ${res}    Run Keyword And Return Status      A2A_Check_CSV_Table
    ...    ${A2A_CHECK_DIR}/ttitrace_slotmute${case_id}_scell.ini    ${OUTPUT_DIR}/output_dl.csv
    Run Keyword If    '${res}'=='True'    Log To Console    '\n!!!Mute slot is abnormal...\n'
    Should Be True    '${res}'!='True'
    Log To Console    '\nScell Mute slot is OK...\n'

Get MeasID A1
    [Arguments]    ${ueid}
    ${reportConfigIdregex}=    Set Variable    reportConfigId (?P<report_id>\\d)[\\s\\S]{1,150}eventId eventA1
    ${content}=    OperatingSystem.Get File    /opt/iphy/latest/egate_console.log
    ${report_id_list}=    String.Get Regexp Matches    ${content}    ${reportConfigIdregex}    report_id
#	${measorder}    Evaluate    int(${ueid})-1
    ${report_id}=    Set Variable    @{report_id_list}[-1]
    ${measIdregex}=    Set Variable    measId (?P<measId>\\d)[\\s\\S]{1,100}reportConfigId ${report_id}
    ${measId_list}=    String.Get Regexp Matches    ${content}    ${measIdregex}    measId
    ${measIdA1}=    Set Variable    @{measId_list}[-1]
    [Return]    ${measIdA1}

Start small dl traffic and check deactivation for A03
    CB007949_resource.SA Start DL TrafficWithPort    10    3600    7072
    SA Stop Traffic    7070
    sleep    10s    #for traffic stable
    Verfiy Scells Are Deactivation for A03    3
    New Get And Check Cells TP For DL after Scell Addition    dl    1    0    0

Start big dl traffic and chek activate again for A03
    SA Start DL TrafficWithPort    1000    3600    7070
    sleep    10s    #for traffic stable
    Verfiy Scells Are Activation After Deactive     3    2
    New Get And Check Cells TP For DL after Scell Addition    dl    3    50    50
    Check UL Tput Is Always Normal Even Deactive and Active Scells For A03    1    1
    
Check UL Tput Is Always Normal Even Deactive and Active Scells For A03
    [Arguments]    ${ue_id}    ${TPcell_ulTP}
    ${cmd}    Set Variable    ue_stats_nr id\=${ue_id} type=pusch scell=0
    ${output}    ute_wtssim.Execute Egate Command    ${cmd}    pass_regexp=CellIndex
    ${regexp_cell}    Set Variable    CellIndex-\\d{1,2}\\s+((\\d+.?\\d*\\s)(Mbps)?(Kbps)?\\s+){3}(?P<AvgTput>\\d+.?\\d*)
    ${avg_tp_list}    String.Get Regexp Matches    ${output}    ${regexp_cell}    AvgTput
    ${all_cell_tp}=    EVALUATE    sum(map(float,${avg_tp_list}))
    Should Be True    ${all_cell_tp}>=${TPcell_ulTP}
    log    UL Troughput for Pcell is ${all_cell_tp}    console=True

Attach SA CA Muti UE and Get Throughput
    [Arguments]    ${UE_ID}=3    ${dl_tp_set}=175    ${ul_tp_set}=175    ${dl_tp_threshold}=100    ${ul_tp_threshold}=20
    SA 5G Attach    ue_id=${UE_ID}
    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
    SA 5G PDU Session Setup    ue_id=${UE_ID}
    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=2
    SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${ul_tp_set}    trf_id=1
    Capture TTItrace
    ${dl_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=1    dir=dl
    ${ul_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=1    dir=ul
    log    DL Troughput is ${dl_tp}    console=True
    log    UL Troughput is ${ul_tp}    console=True
    ${pcell_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=pcell    scell_index=0
    ${scell1_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=scell    scell_index=1
    log    Pcell Troughput is ${pcell_tp}    console=True
    log    Scell1 Troughput is ${scell1_tp}    console=True
    Should Be True    "${pcell_tp}">"0" and "${scell1_tp}">"0"

Attach SA CA UE and Get Throughput for A10
    [Arguments]    ${UE_ID}=1    ${dl_tp_set}=175    ${ul_tp_set}=175    ${dl_tp_threshold}=100    ${ul_tp_threshold}=20
    SA 5G Attach    ${UE_ID}
    SA Set Traffic Type To Internal    ${UE_ID}    1
    SA 5G PDU Session Setup    ${UE_ID}
    Start SA UL Big Traffic Internal    ${UE_ID}    ${ul_tp_set}    1
    Start SA DL Big Traffic Internal    ${UE_ID}    ${dl_tp_set}    1
    Capture TTItrace
    ${dl_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=1    dir=dl
    ${ul_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=1    dir=ul
    log    DL Troughput is ${dl_tp}    console=True
    log    UL Troughput is ${ul_tp}    console=True
    ${pcell_dltp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=pcell    scell_index=0
    ${scell1_dltp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=scell    scell_index=1
    ${pcell_ultp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=ul    cell_type=pcell    scell_index=0
    log    Pcell DL Troughput is ${pcell_dltp}    console=True
    log    Scell1 DL Troughput is ${scell1_dltp}    console=True
    log    Pcell UL Troughput is ${pcell_ultp}    console=True
    Should Be True    ${pcell_dltp}>${dl_tp_threshold} and ${scell1_dltp}>${dl_tp_threshold}
    ...    and ${pcell_ultp}>${ul_tp_threshold}

Start SA UL Big Traffic Internal
    [Arguments]    ${ue_id}    ${mbps}    ${trf_id}=1
    [Documentation]    this keyword is to start big ul udp traffic which more than 175.
    ${ul_times}    Evaluate    int(${mbps}/${175})
    : FOR    ${t_time}    IN RANGE    1    ${ul_times}+1
    \    SA Start UL Traffic Internal    ${ue_id}    pdu_id=1    mbps=175    trf_id=${t_time}
    ${last_mbps}    Evaluate    ${mbps}-${175}*${ul_times}
    SA Start UL Traffic Internal    ${ue_id}    pdu_id=1    mbps=${last_mbps}    trf_id=${ul_times+1}

Start SA DL Big Traffic Internal
    [Arguments]    ${ue_id}    ${mbps}    ${trf_id}=1
    [Documentation]    this keyword is to start big dl udp traffic which more than 175.
    ${dl_times}    Evaluate    int(${mbps}/${175})
    : FOR    ${t_time}    IN RANGE    1    ${dl_times}+1
    \    SA Start DL Traffic Internal    ${ue_id}    pdu_id=1    mbps=175    trf_id=${t_time}
    ${last_mbps}    Evaluate    ${mbps}-${175}*${dl_times}
    SA Start DL Traffic Internal    ${ue_id}    pdu_id=1    mbps=${last_mbps}    trf_id=${dl_times+1}

Verify SCell Configured For UE
    [Arguments]    ${pcap_file}
    BuiltIn.Log To Console    Verify SCell Configured For UE
    cap.Read Cap    cap_file=${pcap_file}    display_filter=f1ap
    ${physCellId} =    cap.get_element_value    element_expression=nr-rrc.physCellId    element_idx=${0}    default_value=True
    ...    condition_expression=nr-rrc.physCellId==51
    Should contain    ${physCellId}    51

Verify maxPayloadSize Configured For UE
    [Arguments]    ${pcap_file}
    BuiltIn.Log To Console    Verify maxPayloadSize Configured For UE
    cap.Read Cap    cap_file=${pcap_file}    display_filter=f1ap
    ${maxPayloadSize} =    cap.get_element_value    element_expression=nr-rrc.maxPayloadSize    element_idx=${0}    default_value=True
    ...    condition_expression=nr-rrc.maxPayloadSize==8
    Should contain    ${maxPayloadSize}    8

Verfiy Scells Are Activation For F03
    [Arguments]    ${cell_nums}    ${times}    ${scell_index_start}=1
    Log To Console    \nverify Scell Activation Info...
    ute_wtssim.Execute Egate Command    sim_log_set flush
    FOR    ${id}    IN RANGE    ${scell_index_start}    ${cell_nums}
    ${scell_activation}    Set Variable    SCellIndex ${id} activated successfully.
    ${check_rst}    Run    cat ${WTS_DIR}/egate_console.log|grep -i "${scell_activation}"|wc -l
    Should Be True    ${check_rst}>=${times}
    END
