*** Settings ***
Documentation    This File contains all the commmon keywords required for the Feature CB008187
Library         taf.sbts.oam.coam.admin         WITH NAME    admin
Library         Collections
Library         DateTime
Library         String
Variables       ta5g_global_var
Library         taf.sw.syslog       WITH NAME   slog
Library         ute_fsmaccess
Library         ta5g_pm_counters
Library         ${CURDIR}/../../../resources/PythonLib/UTILS.py
Resource        ${CURDIR}/../../../resources/Keywords/ap_Keywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/generic_kw.robot
Resource        ${CURDIR}/../../../resources/Keywords/gnb_Keywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/PCMD_Related_KW.robot
Resource        ${CURDIR}/../../../resources/Keywords/tsharkPcapVerifyKeywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/HO_KW.robot
Resource        ${CURDIR}/../../../resources/Keywords/ute_wts_runner.robot
Resource        ${CURDIR}/../../../resources/Variables/common_variables.robot
Resource        ${CURDIR}/../../../resources/Keywords/common_keywords.robot


*** Variables ***
${TOPOLOGY}                  CLOUD_5G_I_LOO_AP_LOOO
${VLAN_ID}                   ${tl.gnbs[0].cu.x2c.vlan_id}
${MRBTS_DISTNAME}            MRBTS-1
${VLANIF_DISTNAME}           ${MRBTS_DISTNAME}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1
${DELTACONFIGDIR}            ${CURDIR}/../../config/scf/
${AP_CONFIG_BASIC}           ${CURDIR}/../../config/wts
${DUMMY4_UECAPINFO}          ngap.UERadioCapabilityInfoIndication_element
${UECAP_D4}                  nr-rrc.mAC_ParametersCommon.dummy -e nr-rrc.burstLength
...                          -e nr-rrc.maxSimultaneousResourceSetsPerCC
...                          -e nr-rrc.maxConfiguredResourceSetsPerCC -e nr-rrc.maxConfiguredResourceSetsAllCC
${APCONFIGDIR}               ${CURDIR}/../../config/ap_iphy/
${EUTRA_FIELDS}              nr-rrc.bandEUTRA -e nr-rrc.ca_BandwidthClassDL_EUTRA -e nr-rrc.ca_BandwidthClassUL_EUTRA
${DUMMY4_UERADACCCAPINFO}    ngap.id == 117
${FIL_UECAPENQ}              nr-rrc.ueCapabilityEnquiry_element
${EXP_PMAX_PC2}              26
${EXP_PMAX_PC1}              31
${FILTER_PC1_TMO_CELL7}      nr-rrc && nr-rrc.physCellId == 57 && nr-rrc.p_Max
${FILTER_PC2_TMO_CELL10}     nr-rrc && nr-rrc.physCellId == 60 && nr-rrc.p_Max


*** Keywords ***
Prepare For Test Case CB014062 Chipset
    [Documentation]     This Keyword is specifically used for setting up testcase for CB014062 PC2
    Link SCOUT SCF To Configuration ID For Reporting
    ${Log_Path}      Create Log Directory        CB014062
    Set Test Variable         ${Log_Path}
    GNB Delta Commission      ${DELTACONFIGDIR}/TCE_10_Delta.json
    Sleep   30s
    Wait Coam Site To Be Ready
    Start UTE WTS     basic_setup_chp_exchg.cfg
    NG Link Should Be UP
    Sleep   90s

Tear Down For Test Case CB014062 Chipset
    [Documentation]     This Keyword is used for reverting back all changes we have made to testcase
    [Arguments]        ${CompressLog}=CB014062.zip
    slog.Stop Syslog
    wtsrunner.sim_reset
    Sleep       5s
    ${hhmm}     Get Current Time As HHMM
    Snapshot Collection     ${LOG_PATH}     Snapshot_${hhmm}_${CompressLog}
    Copy Files      ${WTS_WORKING_DIR}/egate_console.log      ${LOG_PATH}
    Run     zip -r ${OUTPUTDIR}/${CompressLog} ${LOG_PATH}
    GNB Delta Commission      ${DELTACONFIGDIR}/TCE_10_Reverse_Delta.json
    Sleep   30s
    GNB Graceful Reset
    Log To Console       Rebooting GNB wait for 300 seconds...
    Sleep                300s
    Wait Coam Site to be Ready

Prepare For Test Case CB014062 CVR
    Link SCOUT SCF To Configuration ID For Reporting
    ${Log_Path}    Create Log Directory    CB014062_CVR
    Set Test Variable    ${Log_Path}
    Update And Put Iphy XML    ${APCONFIGDIR}/iphy_n66_n85.xml
    GNB Delta Commission    ${DELTACONFIGDIR}/Delta_CVR_n66_n85.json
    GNB Graceful Reset
    Sleep    300s
    Wait Coam Site To Be Ready
    Start UTE WTS    basic_setup_CVR.cfg
    Basic Bring Up
    Sleep    30s

Tear Down For Test Case CB014062
    [Arguments]    ${CompressLog}=CB014062_CVR.zip
    slog.Stop Syslog
    Stop Tcp Pcap on wts
    ${hhmm}    Get Current Time As HHMM
    Snapshot Collection    ${LOG_PATH}    Snapshot_${hhmm}_${CompressLog}
    Collect Logs For The Test    ${Log_Path}
    Copy Files    ${WTS_WORKING_DIR}/egate_console.log    ${LOG_PATH}
    Run    zip -r ${OUTPUTDIR}/${CompressLog} ${LOG_PATH}
    GNB Graceful Reset
    Sleep    300s
    RAT Block Unblock
    Wait Coam Site to be Ready

Get Current Time As HHMM
    [Documentation]     This keyword is used to create variable base on timein hour and min in HHMM format
    ${time}     Get Time    result_format=%H%M
    ${hh}       Get Substring       ${time}   11  13
    ${mm}       Get Substring       ${time}   14  16
    ${hhmm}     Set Variable        ${hh}${mm}
    [Return]    ${hhmm}

Get PMax Value
    [Documentation]    This Keyword is used to get PMAX Value from PCAP
    [Arguments]        ${pcap_file}     ${filter}=${FILTER_PC1_TMO_CELL7}      ${field}=nr-rrc.p_Max
    ${Pmax_values}     Get Fields from Pcap       ${pcap_file}        ${filter}        ${field}
    ${Pmax_list}       Split String      ${Pmax_values}     \n
    ${PMAX_VALUE}      Get From List     ${Pmax_list}       0
    [Return]           ${PMAX_VALUE}

Compare Received And Expected PMAX Value
    [Arguments]       ${PMAX_VALUE}=23      ${ExpVal}=${EXP_PMAX_PC2}
    Log To Console      Received Value ${PMAX_VALUE} and Expected Value is ${ExpVal}
    Should Be Equal     ${PMAX_VALUE}       ${ExpVal}

Get Chipset And RAN ID Info From UEcapinfo
    [Documentation]      this keyword helps to chipset and RAN information from the pcap file
    ...                  [Arguments]     pcap_file       =   need to give complete path of the pcap file
    ...                                  dummy4_filter       =   filter for UEcapinfo
    [Arguments]         ${pcap_file}            ${dummy4_filter}=${DUMMY4_UECAPINFO}
    ${d4_values}        Get Fields From Pcap    ${pcap_file}        ${dummy4_filter}           ${UECAP_D4}
    @{d4_value_list}    Split String And Return Multiple List            ${d4_values}
    Extract First Values    @{d4_value_list}

Get Eutra Information From UEcapinfo
    [Documentation]      this keyword helps to get eutra information from the pcap file
    ...                  [Arguments]     pcap_file       =   need to give complete path of the pcap file
    ...                                  eutra_filter       =   filter for eutra information
    [Arguments]         ${pcap_file}            ${eutra_filter}=${DUMMY4_UECAPINFO}
    ${eutra_op}         Get Fields From Pcap    ${pcap_file}        ${eutra_filter}           ${EUTRA_FIELDS}
    Extract And Compare Eutra Lists    ${eutra_op}

Check For Dummy4 Ueradioaccesscap Information
    [Documentation]      this keyword helps to chipset and RAN information from the pcap file
    ...                  [Arguments]     pcap_file       =   need to give complete path of the pcap file
    ...                                  dummy4_filter       =   filter for ueradioaccesscap
    [Arguments]         ${pcap_file}            ${dummy4_filter}=${DUMMY4_UERADACCCAPINFO}
    ${d4_values}         Get Fields from Pcap    ${pcap_file}        ${dummy4_filter}           ${UECAP_D4}
    @{d4_value_list}     Split String And Return Multiple List            ${d4_values}
    Extract First Values    @{d4_value_list}

Check If UEcapenquiry Is Not Sent By Gnb
    [Documentation]      this keyword helps to chipset and RAN information from the pcap file
    ...                  [Arguments]     pcap_file       =   need to give complete path of the pcap file
    ...                                  uecap_enq       =   filter for uecapenquiry
    [Arguments]         ${pcap_file}            ${uecap_enq}=${FIL_UECAPENQ}
    ${RES}      Get Fields from Pcap    ${pcap_file}    ${uecap_enq}    ${EUTRA_FIELDS}
    Run Keyword And Ignore Error    Should be Empty     ${RES}

Extract And Compare Eutra Lists
    [Documentation]      this keyword helps to extract and compare eutra band values
    [Arguments]    ${eutra_op}
    @{eutra_list1}     Create List        200    0    3
    @{eutra_list2}     Create List        201    0    3
    @{eutra_list3}     Create List        202    1    5
    @{eutragroups}     Split String    ${eutra_op}
    @{list1_group}     Split String    ${eutragroups[0]}    ,
    @{list2_group}     Split String    ${eutragroups[1]}    ,
    @{list3_group}     Split String    ${eutragroups[2]}    ,
    ${list1}    Create List    ${list1_group[0]}    ${list2_group[0]}    ${list3_group[0]}
    ${list2}    Create List    ${list1_group[1]}    ${list2_group[1]}    ${list3_group[1]}
    ${list3}    Create List    ${list1_group[2]}    ${list2_group[2]}    ${list3_group[2]}
    IF    ${list1} == ${eutra_list1}
            Log    List ${list1} matches eutra List ${eutra_list1}
    ELSE
            Log    List ${list1} does not match eutra List ${eutra_list1}
    END
    IF    ${list2} == ${eutra_list2}
            Log    List ${list2} matches eutra List ${eutra_list2}
    ELSE
            Log    List ${list2} does not match eutra List ${eutra_list2}
    END
    IF    ${list3} == ${eutra_list3}
            Log    List ${list3} matches eutra List ${eutra_list3}
    ELSE
            Log    List ${list3} does not match eutra List ${eutra_list3}
    END

Split String And Return Multiple List
    [Documentation]      this keyword helps to Split String And Return Multiple List
    [Arguments]    ${data}
    ${split_by_space}    Split String    ${data}
    ${list_of_lists}    Create List
    FOR    ${item}    IN    @{split_by_space}
        ${list}    Split String     ${item}     ,
        Append To List    ${list_of_lists}    ${list}
    END
    [Return]    ${list_of_lists}

Register And Establish Non-GBR call
    [Documentation]    This keyword shall register UE and establish Non-GBR data call
    ...                [arguments]    UE_ID           :   parse UE ID
    ...                               gw_ID           :   Gateway Id is required else it will take deffault value
    ...                               Pdu_session_ID  :   PDU Session Id is required deffault value set is 1
    ...                               traffic_dl_rate :   traffic downlink data rate is required deffault value set is 1
    ...                               traffic_ul_rate :   traffic uplink data rate is required deffault value set is 1
    [Arguments]         ${UE_ID}=${UE_ID}           ${Pdu_session_ID}=${Pdu_session_ID}
    ...                 ${traffic_dl_rate}=${traffic_dl_rate}               ${traffic_ul_rate}=${traffic_ul_rate}
    Enable Internal TG           ${UE_ID}           ${Pdu_session_ID}
    UE Register Should Be Successful
    Sleep               10s
    Traffic Should Be Successful For SA             ${traffic_dl_rate}          ${traffic_ul_rate}            ${UE_ID}
    Sleep               10s

Stop Pcap Collection In GNB CU
    [Documentation]    This keyword is to stop PCAP logs from gnB
    ...     [arguments]    name     : This is file name where pcap logs will be collected, default name is gnbTcpdump
    ...                    Log_path : Path where pcap log file will be stored, default path is Log_Path
    ...     [return]    pcap_file   : pcap file path captured on wts
    ...     [usage]     Stop pcap collection in gNB
    ...                 Stop pcap collection in gNB     name=PCAPLOG    Log_Path= dir/dir/filename
    ...                 Stop pcap collection in gNB     gnbTcpdump1     dir/dir/filename
    [Arguments]                     ${name}=gnbTcpdump                  ${Log_Path}=${Log_Path}
    core.Stop Collectors            names=${name}
    core.Collect Collectors         names=${name}       target_dir=${Log_Path}
    core.Teardown Collectors        names=${name}
    ${pcap_file}    Join Path       ${Log_Path}         ${name}         ${name}.pcap
    Log To Console                  pcap capture is stopped
    [Return]                        ${pcap_file}

Extract First Values
    [Documentation]    This keyword helps to extract first values from each list
    [Arguments]    @{d4_value_list}
    @{dummy4values}     Create List    0    1    5    64    128
    FOR    ${index}    IN RANGE    0    5
        ${first_value}    Get From List    ${d4_value_list[${index}]}   0
        ${predefined_value}    Get From List    ${dummy4values}    ${index}
        IF    '${first_value}' == '${predefined_value}'
            Log    ${first_value} matches ${predefined_value}
        ELSE
            Log    ${first_value} does not match ${predefined_value}
        END
    END

Verify BandNR In FrequencyBandList UE Cap
    [Documentation]     Verifying Frequency band in Given filter form PCAP
    [Arguments]             ${EXP_BandNR}=41           ${filter}=${NSETAPX_CAP_REQ_FIL}
    ...                     ${pcap_file}=eth3_tcp1.pcap          ${alias}=tcp_pcap
    @{BandNR_LIST}          Get Attribute Values From Tshark Messages       alias=${alias}
    ...     filter=${filter}
    ...     output_pdml_filepath=/home/ute/log_cu_test/pdml_tmp_file1.pdml
    ...     element_xpath=.//field[@name="nr-rrc.bandNR"]
    ...     attribute_xpath=.
    ...     attribute=show
    ...     pcap_file_path=${Log_Path}/${pcap_file}
    Should Not Be Empty    ${BandNR_LIST}
    @{BandNR_SET}    Remove Duplicates        ${BandNR_LIST}
    List Should Contain Value        ${BandNR_SET}     ${EXP_BandNR}

Verifying The PM Counter For CB014062
    [Documentation]    Verifying The PM Counter For CB014062
    Log To Console          This is for Cell7
    Wait For Next Full Pm Interval
    ${pm_counter_file}      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55124C00025    >0       UE_CHIPSET_VENDOR_NUM_SUP
    ...     M55124C00026    >0       UE_CHIPSET_VENDOR_NUM_SUP_ECHO
    ...     M55181C00009    >0       UE_CHIPSET_VENDOR_MAX_USERS
    ...     M55124C00027    0       UE_CHIPSET_VENDOR_RECV_ERR
    ...     M55124C00028    0       UE_CHIPSET_VENDOR_DIFF_CAP_ENQ
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-7
    ...     file_path=${pm_counter_file}

DL Traffic Should Be Successful CB014062
    [Documentation]    This Keywords helps to start Only DL Data
    ...     ${dl_rate} :    Gives the Quantity of data
    ...     ${UEID}    :    UE Id for which Data to be transferred
    ...     ${QFI}     :    QOS Flow We want for data
    ...     ${bps}     :    dl_rate in mbps/kbps required.
    [Arguments]    ${dl_rate}=30    ${UE_ID}=${UE_ID}       ${QFI}=1    ${bps}=mbps
    Log to Console    \nRunning DL Traffic
    wtsrunner.Trf Data Start     ue=${UE_ID}    pdu=1   qfi=${QFI}    dir=dl    ${bps}=${dl_rate}
    ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=UDP DL TRF: .*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    ${output}

UL Traffic Should Be Successful CB014062
    [Documentation]    This Keyword helps to start Only UL Data.
    ...     ${ul_rate} :    Gives the Quantity of data
    ...     ${UEID}    :    UE Id for which Data to be transferred
    ...     ${QFI}     :    QOS Flow We want for data
    ...     ${bps}     :    ul_rate in mbps/kbps required.
    [Arguments]    ${ul_rate}=30    ${UE_ID}=${UE_ID}       ${QFI}=1    ${bps}=mbps
    Log to Console    \nRunning UL Traffic
    wtsrunner.Trf Data Start     ue=${UE_ID}    pdu=1   qfi=${QFI}    dir=ul    ${bps}=${ul_rate}
    ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=UDP UL TRF: .*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    ${output}

Stop Data UL And DL CB014062
    [Documentation]     Stopping Data for both direction
    ...     ${UEID}    :    UE Id for which Data to be transferred for specific UE
    [Arguments]     ${UEID}=${UEID1}
    Log to Console    \nStopping UL/DL Traffic
    wtsrunner.Trf Data Stop     ue=${UE_ID}     pdu=1      qfi=1
    Sleep   5s

UE Trying To Page AMF
    [Documentation]     When UE in Idle State and Trying to reconnect it is Paging AMF
    [Arguments]     ${UEID}=${UE_ID1}     ${AMFID}=1
    wtsrunner.Amf Paging Start            id=${AMFID}    ue=${UE_ID}
    Read Wts Output For Pattern And Print Matching Lines          ${Initial_context_setup_pattern}      ${Timeout_SA}
