*** Settings ***
Documentation     [PURPOSE]
*** Variables ***
&{NETACT_SERVER_INFO1}    IP=10.41.146.171
...    URL=srnclab1016lbwas.srnblr.nsn-rdnet.net    USERNAME=omc    PASSWORD=Nokia_150    PORT=22    # Netact 1016


*** Keyword ***
LBT5358-3
    [Documentation]    Short description.
    Precondition
    Print Log    Log Dir : ${TEST_LOG_DIR}
    TD_OM_LBT5358_SFP_Monitoring.Upload_interval_change    15min
#    ${Remain_Time}    Get Counter File Remaining Time
    ${Remain_Time}    set variable    900s
    sleep    ${Remain_Time}
    sleep    60s
    Login_with_multiway   192.168.255.129    toor4nsn    oZPS0POrRieRtu
    Write    cd /ram
    Write    ls > tx.txt
    sftp download    192.168.255.1    toor4nsn    oZPS0POrRieRtu    /ram/tx.txt     ${TEST_LOG_DIR}${/}tx.txt
    Write    rm tx.txt
    ${Rtn}    OperatingSystem.Get File    ${TEST_LOG_DIR}${/}tx.txt
    log    ${Rtn}
    Should match    ${Rtn}    *RD.BTS-${BTS_INFO.ID}*
    ${group}    ${file_name_RD}    Should Match Regexp    ${Rtn}    .*(PM.BTS-${BTS_INFO.ID}.*.ANY.xml.gz).*
    ${group}    ${unzip_file_name_RD}    Should Match Regexp    ${Rtn}    .*(PM.BTS-${BTS_INFO.ID}.*.ANY.xml).*
    Login_with_multiway   192.168.255.129    toor4nsn    oZPS0POrRieRtu
    Write    cd /tmp
    Write    mkdir PM
    Write    cp /ram/${file_name_RD} /tmp/PM
    Write    cd /tmp/PM
    Write    gunzip ${file_name_RD}
    Write    chmod 777 ${unzip_file_name_RD}
    sftp download    192.168.255.1    toor4nsn    oZPS0POrRieRtu    /tmp/PM/${unzip_file_name_RD}    ${TEST_LOG_DIR}${/}${unzip_file_name_RD}
    Write    rm -rf *
    ${Rtn2}    OperatingSystem.Get File    ${TEST_LOG_DIR}${/}${unzip_file_name_RD}
    Should Contain    ${Rtn2}    SFP_SMOD

LBT5358-1
    [Documentation]    Short description.
    taf.sbts.oam.coam.admin.Setup Admin
    ${Retn}    taf.sbts.oam.coam.admin.Get Sfp Links    1
    Log    ${Retn}
    ${Retn_sting}    Convert To String    ${Retn}
    Log    ${Retn_sting}
    Should Not Contain    ${Retn_sting}    None

LBT5358-1_CB007425
    [Documentation]    Short description.
    ${Retn}    taf.sbts.oam.coam.admin.Get Sfp Links
    Log    ${Retn}
    ${keys}=    Get Dictionary Keys   ${Retn}
    ${size_of_dict}    Evaluate   len(${Retn})
    FOR   ${item}  IN   @{keys}
        Run keyword if    '${item}' == 'notConnected'
        ...    Run keyword if    not ${Retn}[${item}]   continue for loop
        Remove From Dictionary   ${Retn}[${item}][0][details]     dwdmParameters
        ${Retn_sting}    Convert To String    ${Retn}[${item}][0]
        Should Not Contain    ${Retn_sting}    None
    END

Private_delete_PM_file
    [Documentation]    Short description.
    Connect to BTS
    Write    cd /ram
    Write    rm *PM.BTS-${BTS_INFO.ID}*
    Write    rm *RD.BTS-${BTS_INFO.ID}*

Private_check_PM_file_content
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${check_pm}: <description>
    [Arguments]    ${check_pm}
    ${FCTB_Connection} =    connect to BTS
    Switch Host Connection    ${FCTB_Connection}
    Write    cd /ram
    Write    rm -rf systemd-private-*;ls > tx.txt
    Ftp download    192.168.255.1    21    toor4nsn    oZPS0POrRieRtu    ${TEST_LOG_DIR}${/}tx.txt    tx.txt
    ...    /ram
    ${Rtn}    OperatingSystem.Get File    ${TEST_LOG_DIR}${/}tx.txt
    Write    rm tx.txt
    log    ${Rtn}
    ${group}    ${file_name_PM}    Should Match Regexp    ${Rtn}    .*(PM.BTS-${BTS_INFO.ID}.*.ANY.*.gz).*
    Ftp download    192.168.255.1    21    toor4nsn    oZPS0POrRieRtu    ${TEST_LOG_DIR}${/}${file_name_PM}    PM.BTS-${BTS_INFO.ID}.*.ANY.xml.gz
    ...    /ram
    Switch Host Connection    ${FCTB_Connection}
    Write    cd /ram
    ${file_decompress}    Write    gunzip ${file_name_PM}
    ${group}    ${file_decompress_PM}    Should Match Regexp    ${Rtn}    .*(PM.BTS-${BTS_INFO.ID}.*.ANY.*.xml).*
    Write    more ${file_decompress_PM} |grep ${check_pm} >PMfilecheck.txt
    Ftp download    192.168.255.1    21    toor4nsn    oZPS0POrRieRtu    ${TEST_LOG_DIR}${/}PMfilecheck.txt    PMfilecheck.txt
    ...    /ram
    Write    rm PMfilecheck.txt
    File Should Be Empty    ${TEST_LOG_DIR}${/}PMfilecheck.txt
    Ftp download    192.168.255.1    21    toor4nsn    oZPS0POrRieRtu    ${TEST_LOG_DIR}${/}${file_decompress_PM}    PM.BTS-${BTS_INFO.ID}.*
    ...    /ram

Private_download_new_PM_file
    [Documentation]    Short description.
    connect to BTS
    Write    cd /ram
    ${file_decompress}    Write    gunzip \ PM.BTS-${BTS_INFO.ID}*
    Write    cp PM.BTS-${BTS_INFO.ID}* \ \ PMCounter.xml
    sftp Download    192.168.255.1    toor4nsn    oZPS0POrRieRtu    ${TEST_LOG_DIR}${/}PMCounter.xml    PMCounter.xml
    ...    /ram
    Write    rm -rf PMCounter.xml

Update_radio_parameter
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${interval_15}: <description>
    ...        ${interval_30}: <description>
    [Arguments]    ${interval_15}    ${interval_30}
    create file    ${TEST_LOG_DIR}\\plan\\LTE877_05_15min.json
    create file    ${TEST_LOG_DIR}\\plan\\LTE877_05_30min.json
    file_operation.Update Json File    ${TEST_LOG_DIR}\\plan\\LTE877_05_15min.json    dist_operation=update
    ...    dist_name=${BTS_INFO.MRBTS}/${BTS_INFO.LNBTS}/PMRNL-1    parameter_operation=update
    ...    mtActUsersLatencyPMQAPProfile=${interval_15}    mtCellAvailability=${interval_15}
    ...    mtCellLoad=${interval_15}    mtCellRes=${interval_15}    mtCellThruput=${interval_15}
    ...    mtDataVolThrPMQAPProfile=${interval_15}    mtEPSBearer=${interval_15}    mtERABPMQAPProfile=${interval_15}
    ...    mtEutraFrequency=${interval_15}    mtGNSS=${interval_15}    mtHoRlf=${interval_15}
    ...    mtInterHomeeNBHo=${interval_15}    mtInterSysHo=${interval_15}    mtInterSysHoEhrpdBc=${interval_15}
    ...    mtInterSysHoGsmNb=${interval_15}    mtInterSysHoUtranNb=${interval_15}
    ...    mtIntereNBHo=${interval_15}    mtIntraeNBHo=${interval_15}    mtLTEHo=${interval_15}    mtM3SctpStatistics=${interval_15}
    ...    mtMAC=${interval_15}    mtMBMS=${interval_15}    mtMobilityEvents=${interval_15}
    ...    mtMroUtranFrequency=${interval_15}    mteNBload=${interval_15}    mtintraLTEHoNb=${interval_15}
    ...    mtBBPooling=${interval_15}    mtLTEM=${interval_15}    mtRIP=${interval_15}
    ...    mtPIMCancellation=${interval_15}    mtBroadcast=${interval_15}    mtIntereNBS1Ho=${interval_15}
    ...    mtIntereNBX2Ho=${interval_15}    mtIntraeNBHoExt=${interval_15}    mtLTEMbmsLNBTS=${interval_15}
    ...    mtLTEMbmsMbsfnArea=${interval_15}    mtLTEMperLNBTS=${interval_15}    mtVoLTEVoiceBPerioHist=${interval_15}
    ...    mtCellSpare=${interval_15}    mteNBSpare=${interval_15}    mtInterSiteX2=${interval_15}
    ...    mtX2gNB=${interval_15}    mtDacWordStatistics=${interval_15}    mtCatmAccessibility=${interval_15}
    ...    mtCatmMobility=${interval_15}    mtCatmRetainability=${interval_15}    mtX2gNBperCell=${interval_15}
    ...    mtCatmIntegrity=${interval_15}    mtCatmUsage=${interval_15}
    file_operation.Update Json File    ${TEST_LOG_DIR}\\plan\\LTE877_05_30min.json    dist_operation=update
    ...    dist_name=${BTS_INFO.MRBTS}/${BTS_INFO.LNBTS}/PMRNL-1    parameter_operation=update
    ...    mtPowQualDL=${interval_30}    mtPowQualUL=${interval_30}
    ...    mtQoS=${interval_30}    mtRLFPMQAPProfile=${interval_30}    mtRRC=${interval_30}
    ...    mtRSRPRSRQHist=${interval_30}    mtRadBearer=${interval_30}    mtRanSharing=${interval_30}
    ...    mtS1AP=${interval_30}    mtS1SctpStatistics=${interval_30}    mtSINR=${interval_30}
    ...    mtTranspLoad=${interval_30}    mtUEQuantity=${interval_30}    mtUEandServiceDiff=${interval_30}
    ...    mtUEstate=${interval_30}    mtVoLTEBLERHist=${interval_30}    mtX2AP=${interval_30}    mtX2SctpStatistics=${interval_30}
    file_operation.Update Json File    ${TEST_LOG_DIR}\\plan\\LTE877_05_30min.json    dist_operation=update
    ...    dist_name=${BTS_INFO.MRBTS}/${BTS_INFO.LNBTS}/PMRNL-1    parameter_operation=update    mtNBIoT=disabled    mtNBIoTBtsSpare=disabled
    ...    mtNBIoTCellSpare=disabled    mtNbIotPowerQuality=disabled    mtNbIotUsage=disabled    #
    _Perform Delta Commission By Admin    ${TEST_LOG_DIR}\\plan\\LTE877_05_15min.json
    _Perform Delta Commission By Admin    ${TEST_LOG_DIR}\\plan\\LTE877_05_30min.json

Upload_interval_change
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${interval_upload}: <description>
    [Arguments]    ${interval_upload}
    _Perform Single Parameter Commission By Admin    dist_name=${BTS_INFO.MRBTS}/MNL-1/MNLENT-1/PMCADM-1
    ...    parameter=reportingIntervalPm    operation=update    value=${interval_upload}

Update_trs_parameter
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${interval_15}: <description>
    ...        ${interval_30}: <description>
    [Arguments]    ${interval_15}    ${interval_30}
    create file    ${TEST_LOG_DIR}\\plan\\LTE877_05_15min.json
    create file    ${TEST_LOG_DIR}\\plan\\LTE877_05_30min.json
    file_operation.Update Json File    ${TEST_LOG_DIR}\\plan\\LTE877_05_15min.json    dist_operation=update
    ...    dist_name=${BTS_INFO.MRBTS}/TNLSVC-1/TNL-1/PMTNL-1    parameter_operation=update
    ...    bridgePortStatisticsInterval=${interval_15}    ethernetInterfaceStatisticsInterval=${interval_15}
    ...    ethernetLinkInterval=${interval_15}    firstLevelSchedulerStatisticsInterval=${interval_15}
    ...    ipFilteringInterval=${interval_15}    ipInterfaceStatisticsInterval=${interval_15}
    ...    ipNodeStatisticsInterval=${interval_15}    ipPerHopBehaviourStatisticsInterval=${interval_15}
    ...    ipSecSaStatisticsInterval=${interval_15}    ipSecStatisticsInterval=${interval_15}
    ...    ipV4AddressStatisticsInterval=${interval_15}    ipV4InterfaceStatisticsInterval=${interval_15}
    ...    ipV4RxPerHopBehaviourStatisticsInterval=${interval_15}    ipV4TxPerHopBehaviourStatisticsInterval=${interval_15}
    file_operation.Update Json File    ${TEST_LOG_DIR}\\plan\\LTE877_05_30min.json    dist_operation=update
    ...    dist_name=${BTS_INFO.MRBTS}/TNLSVC-1/TNL-1/PMTNL-1    parameter_operation=update
    ...    ipV6AddressStatisticsInterval=${interval_30}    ipV6InterfaceStatisticsInterval=${interval_30}
    ...    ipV6RxPerHopBehaviourStatisticsInterval=${interval_30}    ipV6TxPerHopBehaviourStatisticsInterval=${interval_30}
    ...    pdhInterfaceStatisticsInterval=${interval_30}    sctpStatisticsInterval=${interval_30}
    ...    secondLevelSchedulerStatisticsInterval=${interval_30}    tcpUdpStatisticsInterval=${interval_30}
    ...    twampStatisticsInterval=${interval_30}    vlanStatisticsInterval=${interval_30}
    _Perform Delta Commission By Admin    ${TEST_LOG_DIR}\\plan\\LTE877_05_15min.json
    _Perform Delta Commission By Admin    ${TEST_LOG_DIR}\\plan\\LTE877_05_30min.json

PM_NetAct_Check_CounterValueInDB
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${start_time}: <description>
    ...        ${end_time}: <description>
    [Arguments]    ${start_time}    ${end_time}
    Connect To NetAct
    Set Shell Timeout    30
    set shell prompt    SQL>
    Write    sqlplus omc/omc
    Write    set heading off
    ${dn_list}    Write
    ...    select to_char(co_gid) from utp_common_objects where co_object_instance\=${BTS_INFO.ID} and co_oc_id\=3129;
    ${bts_dn1}    Split String    ${dn_list}
    ${bts_dn}    Get From List    ${bts_dn1}    -2
    ${cmd_1}=    Catenate    select \ DL_CAC_EQUAL_ZERO , to_char(period_start_time,
    ...    'YYYY-MM-DD HH24:MI:SS') from NOKLTE_PS_LCELLR_MNC1_RAW where period_start_time >\= to_date('${start_time}',
    ...    'yyyy-mm-dd hh24:mi:ss') and period_start_time < to_date('${end_time}', 'yyyy-mm-dd hh24:mi:ss') \ and LNBTS_ID\= ${bts_dn};    #M8011C81
    Comment    ${sql_output}    Write    ${cmd_1}
    ${cmd_2}=    Catenate    select \ ENB_LOAD_ACT_UE_AVG , to_char(period_start_time,'YYYY-MM-DD HH24:MI:SS')
    ...    from NOKLTE_PS_LENBLD_LNBTS_RAW where period_start_time >\= to_date('${start_time}',
    ...    'yyyy-mm-dd hh24:mi:ss') and period_start_time < to_date('${end_time}', 'yyyy-mm-dd hh24:mi:ss') \ and LNBTS_ID\= ${bts_dn};    #M8018C0
    ${sql_output}    Write    ${cmd_2}
    ${result}    Split String    ${sql_output}
    ${counter_value}    Get From List    ${result}    24
    should be true    ${counter_value}==0

SSH To Server1
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        &{server_info}: <description>
    ...
    ...    Returns:
    ...        ${ssh_server_connection}: <description>
    [Arguments]    &{server_info}
    Comment    Comment    Switch Host Connection    ${BTS_PC_CONNECTION}
    Log Many    &{NETACT_SERVER_INFO1}[IP]    &{NETACT_SERVER_INFO1}[USERNAME]    &{NETACT_SERVER_INFO1}[PASSWORD]
    ${ssh_server_connection}    Login_with_multiway    &{NETACT_SERVER_INFO1}[IP]    &{NETACT_SERVER_INFO1}[USERNAME]
    ...    &{NETACT_SERVER_INFO1}[PASSWORD]    timeout=10s
    Switch Host Connection    ${ssh_server_connection}
    [Return]    ${ssh_server_connection}

PM_NetAct_Check_CounterValueInDB new
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${start_time}: <description>
    ...        ${end_time}: <description>
    [Arguments]    ${start_time}    ${end_time}
    Comment    Connect To NetAct
    ${netact_connection}    SSH To Server1    &{NETACT_SERVER_INFO1}
    Set Test Variable    ${netact_connection}
    Set Shell Timeout    30
    set shell prompt    SQL>
    Write    sqlplus omc/omc
    Write    set heading off
    ${dn_list}    Write
    ...    select to_char(co_gid) from utp_common_objects where co_object_instance\=${BTS_INFO.ID} and co_oc_id\=3129;
    ${bts_dn1}    Split String    ${dn_list}
    ${bts_dn}    Get From List    ${bts_dn1}    -2
    ${cmd_3}=    Catenate    select \ DL_CAC_EQUAL_ZERO , to_char(period_start_time,'YYYY-MM-DD HH24:MI:SS') from
    ...    NOKLTE_PS_LCELLR_MNC1_RAW where period_start_time >\= to_date('${start_time}',
    ...    'yyyy-mm-dd hh24:mi:ss') and period_start_time < to_date('${end_time}', 'yyyy-mm-dd hh24:mi:ss') \ and LNBTS_ID\= ${bts_dn};    #M8011C81
    Comment    ${sql_output}    Write    ${cmd_3}
    ${cmd_4}=    Catenate    select \ ENB_LOAD_ACT_UE_AVG , to_char(period_start_time,'YYYY-MM-DD HH24:MI:SS') from
    ...    NOKLTE_PS_LENBLD_LNBTS_RAW where period_start_time >\= to_date('${start_time}',
    ...    'yyyy-mm-dd hh24:mi:ss') and period_start_time < to_date('${end_time}', 'yyyy-mm-dd hh24:mi:ss') \ and LNBTS_ID\= ${bts_dn};    #M8018C0
    ${sql_output}    Write    ${cmd_4}
    ${result}    Split String    ${sql_output}
    ${counter_value}    Get From List    ${result}    24
    should be true    ${counter_value}==0

PM_NetAct_Check_no_CounterValueInDB
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${start_time}: <description>
    ...        ${end_time}: <description>
    [Arguments]    ${start_time}    ${end_time}
    Connect To NetAct
    Set Shell Timeout    30
    set shell prompt    SQL>
    Write    sqlplus omc/omc
    Write    set heading off
    ${dn_list}    Write
    ...    select to_char(co_gid) from utp_common_objects where co_object_instance\=${BTS_INFO.ID} and co_oc_id\=3129;
    ${bts_dn1}    Split String    ${dn_list}
    ${bts_dn}    Get From List    ${bts_dn1}    -2
    ${cmd_5}=    Catenate    select \ DL_CAC_EQUAL_ZERO , to_char(period_start_time,'YYYY-MM-DD HH24:MI:SS') from
    ...    NOKLTE_PS_LCELLR_MNC1_RAW where period_start_time >\= to_date('${start_time}',
    ...    'yyyy-mm-dd hh24:mi:ss') and period_start_time < to_date('${end_time}', 'yyyy-mm-dd hh24:mi:ss') \ and LNBTS_ID\= ${bts_dn};    #M8011C81
    Comment    ${sql_output}    Write    ${cmd_5}
    ${cmd_6}=    Catenate    select \ ENB_LOAD_ACT_UE_AVG , to_char(period_start_time,'YYYY-MM-DD HH24:MI:SS') from
    ...    NOKLTE_PS_LENBLD_LNBTS_RAW where period_start_time >\= to_date('${start_time}',
    ...    'yyyy-mm-dd hh24:mi:ss') and period_start_time < to_date('${end_time}', 'yyyy-mm-dd hh24:mi:ss') \ and LNBTS_ID\= ${bts_dn};    #M8018C0
    ${sql_output}    Write    ${cmd_6}
    ${result}    Split String    ${sql_output}
    ${counter_value}    Get From List    ${result}    24
    Run Keyword And Ignore Error    Should not contain    ${counter_value}    0

Tcpdump_check_msg
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${logname}: <description>
    [Arguments]    ${logname}
    ${BTS_Connection}    Connect To Bts
    ${original connection timeout}    Set Shell Timeout    2min
    ${listen port}    Set Variable    br1
#    ${vtime_remained}    Get Counter File Remaining Time    15min
    ${vtime_remained}    set variable    900s
    log    ${vtime_remained}
    ${w_time}    Evaluate    ${vtime_remained}-120+30    #
    sleep    ${w_time}s    #to caculate accurate time to wait
    ${cmd}    Set Variable    tcpdump -i ${listen port} -w /tmp/${logname}
    Run Keyword And Ignore Error    Write    ${cmd}
    Switch Host Connection    ${BTS_Connection}
    Write    pkill -f \ tcpdump
    Sftp Download    192.168.255.1    toor4nsn    oZPS0POrRieRtu    ${TEST_LOG_DIR}${/}${logname}    ${logname}
    ...    /tmp
    Common Transform Wireshark to Txt    ${TEST_LOG_DIR}${/}${logname}    http    tshark.txt
    Should Contain    ${TEST_LOG_DIR}${/}tshark.txt    Status Code: 200
    Should Contain    ${TEST_LOG_DIR}${/}tshark.txt    PLMN-PLMN/${BTS_INFO.MRBTS}
    Should Contain    ${TEST_LOG_DIR}${/}tshark.txt    ne3s_pm_uploadNotification

_Perform Single Parameter Commission By Admin
    [Arguments]    ${dist_name}    ${parameter}    ${operation}    ${value}    ${timeout}=10mins
    [Documentation]    dist_name (string) – Object dist name
    ...
    ...    parameter (string) – Parameter name
    ...
    ...    operation (string) – Parameter operation (create, update or delete)
    ...
    ...    value (string) – Parameter value
#    Start Admin
    taf.sbts.oam.coam.admin.Perform Parameter Recommissioning    dist_name=${dist_name}    parameter=${parameter}    operation=${operation}
    ...  value=${value}    skip_parameter_relation_errors=${True}    timeout=${timeout}
    ...  alias=default
#    [Teardown]    Stop Admin

Precondition
    [Documentation]    Short description.
    Run keyword and ignore error    taf.nms.netact.Delete Node    cmwas      alias=${alias}
    ${timestamp}    Get Timestamp
    ${FILE_NAME} =    Replace String Using Regexp    ${SUITE_NAME[:50]}    \\s+$    ${EMPTY}
    ${SUITE_LOG_DIRECTORY} =    Catenate    SEPARATOR=${/}    ${OUTPUT_DIR}    ev_logs    ${FILE_NAME}_${timestamp}
    ${SUITE_LOG_DIRECTORY}    Replace String    ${SUITE_LOG_DIRECTORY}    ${SPACE}    _
    Set Suite Variable    ${SUITE_LOG_DIRECTORY}
    Create Directory    ${SUITE_LOG_DIRECTORY}
    log    save log dir:${SUITE_LOG_DIRECTORY}
    ${TEST_LOG_DIR}    Catenate    SEPARATOR=${/}    ${SUITE_LOG_DIRECTORY}    ${TEST_NAME[:50]}
    ${TEST_LOG_DIR}    Replace String    ${TEST_LOG_DIR}    ${SPACE}    _
    Set Test Variable    ${TEST_LOG_DIR}
    Create Directory    ${TEST_LOG_DIR}
    log    save log dir:${TEST_LOG_DIR}

Print Log
    [Arguments]    ${log}
    [Documentation]    Author:fan-fonlan.yang@nokia.com
    ${timestamp}    get timestamp
    BuiltIn.Log To Console    ${EMPTY}
    BuiltIn.Log To Console    [ ${timestamp} ] ${log}
