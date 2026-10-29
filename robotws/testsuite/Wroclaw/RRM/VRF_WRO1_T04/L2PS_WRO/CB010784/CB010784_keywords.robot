*** Settings ***
Documentation
...    copyright: Nokia
...    maintainer: Wojciech Szczesniak (wojciech.szczesniak@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO
...    variant: SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC

Library    Collections
Library    OperatingSystem
Library    String
Library    taf.sbts.oam.coam.admin
Library    testsuite.Wroclaw.RRM.VRF_WRO1_T04.resources.Tokens
Library    taf.ul.gnb.bip.collection    WITH NAME    bip_collection
Library    taf.collectors.core          WITH NAME    core
Library    taf.collectors.l1l2bip       WITH NAME    l1l2bip
Library    taf.collectors.tcpdump       WITH NAME    tcpdump
Library    taf.sbts.oam.coam.admin      WITH NAME    admin
Library    taf.transport.ssh            WITH NAME    ssh
Library    ./CB010784_keywords.py

*** Variables ***
${LOCAL_MOID}=                   PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1

${TA_RACH_RESP_BIN_26}=           M55307C01026

${ADMIN_INFOMODEL_ALIAS}=         infomodel_1
${ADMIN_INFOMODEL_LOG_DIR}=       ${OUTPUT_DIR}
${ADMIN_INFOMODEL_FILENAME}=      infomodel.ims2

${TSHARK_ALIAS}=                  tshark_uu_alias_01
${TSHARK_DIR}=                    ${OUTPUT_DIR}/Tshark_logs

${shell_script}     /opt/wts/latest/sosReport_ASIL/airphone_mirror.sh    # This can be where you have kept the file
${python_script}    /opt/wts/latest/sosReport_ASIL/gnbMirroring.py       # This can be where you have kept the file

*** Keywords ***
Commmon Test Setup
    [Arguments]    ${iphy_config_file_name}   ${scf_file_name}   ${lua_config_file_name}
    Update Iphy Configuration And Modify Swconfig    iphy_xml_filepath=${iphy_config_file_name}
    Find Scfc And Fix And Send Full Commissioning    scfc_filename=${scf_file_name}
    Check Radios Availability
    Reach Onair    lua_cfg=${lua_config_file_name}

Start AP L1l2bipLogs Collector
    &{executor_airphone}    Create Dictionary
    ...    host=192.168.200.1
    ...    user=toor4nsn
    ...    password=oZPS0POrRieRtu
    ${script_path}    Create List
    ...    ${shell_script}
    ...    ${python_script}
    tcpdump.create_tcpdump_collector
    ...    name=tcpdump
    ...    options=-i any
    ...    executor=${executor_airphone}
    l1l2bip.create_airphone_l1l2bip_collector
    ...    name=airphonel1l2bip
    ...    collector=tcpdump
    ...    executor=${executor_airphone}
    ...    script_paths=${script_path}
    core.setup_collectors    names=airphonel1l2bip
    core.start_collectors    names=airphonel1l2bip
    core.set_suite_alias     airphonel1l2bip
    Log To console    AP L1l2bipLogs Collector started

Stop AP L1l2bipLogs Collector
    core.stop_collectors        names=airphonel1l2bip
    core.collect_collectors     names=airphonel1l2bip    target_dir=${OUTPUT_DIR}
    core.teardown_collectors    names=airphonel1l2bip
    Log To Console    L1l2bipLogs collected

Verify NR of Downlink Symbols
    [Arguments]    ${expected_pattern}
    Verify Egate Content    expected_pattern=${expected_pattern}

Verify Guard Period Lengh
    [Arguments]    ${expected_value}
    ${out}    Check guardPeriodLength Value For Cell      cell_id=1
    Should Contain   ${out}    ${expected_value}

Attach Ue To Enb And Start Gnb Addition
    [Arguments]    ${ue_id}    ${target_cells}
    Attach Ue To Enb    ue_id=${ue_id}
    Execute Egate Command    cmd=ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg

ADMIN Setup Admin
    [Arguments]    ${alias}=${ADMIN_ALIAS}
    taf.sbts.oam.coam.admin.Setup Admin
    ...    alias=${alias}

ADMIN Teardown Admin
    [Arguments]    ${alias}=${ADMIN_ALIAS}
    taf.sbts.oam.coam.admin.Teardown Admin
    ...    connection=${alias}

ADMIN Get Managed Objects With Parameters
    [Documentation]    Get managed objects with parameters
    ...    class_name example: SMOD, RMOD_R, GNSS_L, NRCELL_A, NRCELL_L, NRCELL_R ...
    [Arguments]    ${class_name}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_list_of_objects_parameters_dict}    taf.sbts.oam.coam.admin.get_managed_objects
    ...    class_name=${class_name}
    ...    timeout=${timeout}
    ...    connection=${alias}
    [Return]    ${out_list_of_objects_parameters_dict}

ADMIN Get Object Distname And Id List
    [Documentation]    Get object dist name (im path) and separetly list of object's ids
    ...    usage example: for class_name=NRCELL_A keyword returns full distname without id (output example below):
    ...    out_object_distName: /MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1/NP-15/SCF-1/MRBTS_A-50370/NRBTS_A-50370/NRCELL_A
    ...    and list of object's ids (output example below):
    ...    out_object_id_list: [u'2', u'1']
    ...    class_name example: SMOD, RMOD_R, GNSS_L, NRCELL_A, NRCELL_L, NRCELL_R ...
    [Arguments]    ${class_name}
    ...            ${alias}=${ADMIN_ALIAS}
    ${object_parameters}    ADMIN Get Managed Objects With Parameters
    ...    class_name=${class_name}
    ...    alias=${alias}
    ${out_object_id_list}    Create List
    FOR    ${element}    IN    @{object_parameters}
        ${distName}    Get From Dictionary    ${element}    distName
        ${out_object_distName}    ${id}    Split String From Right    ${distName}    -    1
        Append To List    ${out_object_id_list}    ${id}
    END
    [Return]    ${out_object_distName}    ${out_object_id_list}

ADMIN Get Parameter
    [Arguments]    ${dist_name}
    ...            ${parameter}
    ...            ${timeout}=10
    ...            ${connection}=${ADMIN_ALIAS}
    ${out_parameters}    taf.sbts.oam.coam.admin.get_parameters
    ...    dist_name=${dist_name}
    ...    pattern=${parameter}
    ...    timeout=${timeout}
    ...    connection=${connection}
    [Return]    ${out_parameters}

Check guardPeriodLength Value For Cell
    [Arguments]    ${cell_id}
    ${nrcell_a_distname}    ${id_list}    ADMIN Get Object Distname And Id List
    ...    alias=admin
    ...    class_name=NRCELL_A
    ${parameter}    ADMIN Get Parameter
    ...    dist_name=${nrcell_a_distname}-${cell_id}
    ...    parameter=guardPeriodLength
    ...    connection=admin
    [Return]    ${parameter['tddFrameStructure']['guardPeriodLength']}

Check Guard Period Length
    [Arguments]      ${expected_value}
    Start Infomodel Logging
    Query Infomodel And Expect List Parameter Value
    ...    dist_name=/MRBTS-1/RAT-1/BTS_L-4/BTS_CONF-1/NP-1/SCF-1/MRBTS_A-1/NRBTS_A-1/NRCELL_A-1
    ...    parameter=guardPeriodLength
    ...    list=tddFrameStructure
    ...    value=${expected_value}
    Stop Infomodel Logging

Start Infomodel Logging
    ute_admin_infomodel.Setup infomodel    address=192.168.255.129    port=443    alias=${ADMIN_INFOMODEL_ALIAS}
    ute_admin_infomodel.Connect infomodel    alias=${ADMIN_INFOMODEL_ALIAS}

Stop Infomodel Logging
    [Arguments]    ${filename}=${ADMIN_INFOMODEL_FILENAME}
    ...            ${log_dir}=${ADMIN_INFOMODEL_LOG_DIR}
    ...            ${alias}=${ADMIN_INFOMODEL_ALIAS}
    ute_admin_infomodel.Save Infomodel Log    filename=${log_dir}/${filename}  alias=${alias}
    ute_admin_infomodel.Disconnect Infomodel  alias=${alias}
    ute_admin_infomodel.Teardown Infomodel    alias=${alias}

Query Infomodel And Expect List Parameter Value
    [Arguments]    ${dist_name}
    ...            ${parameter}
    ...            ${list}
    ...            ${value}
    ...            ${timeout}=60
    ${out_query_result}=   ute_admin_infomodel.Query Infomodel    query=${dist_name} is [${list}.${parameter}=${value}]
    ...      timeout=${timeout}  alias=${ADMIN_INFOMODEL_ALIAS}

Set Internal Traffic Type To UE
    Execute Egate Command   cmd=set_pdu_param ue=1 pdu=1 trf_type=internal

Start DL and UL Data Traffic SA B2
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=100
    ...    pass_regexp=UE1: Started Downlink Internal traffic Receiver on Ue:1 Pdu:1 Qfi:1 TrfId:1
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=ul mbps=100
    ...    pass_regexp=Started Uplink Internal traffic Receiver on Ue:1 UpfId:1 Pdu:1 Qfi:1 TrfId:1
    Sleep    30s

Start DL and UL Data Traffic SA HighSpeed
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=175 trf_id=6
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=175 trf_id=5
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=175 trf_id=4
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=175 trf_id=3
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=175 trf_id=2
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=175 trf_id=1
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=ul mbps=175 trf_id=1
    Sleep    20s

Start DL and UL Data Traffic
    [Arguments]    ${ue_id}
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start id=2 ue=${ue_id} dir=dl mbps=100
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start id=2 ue=${ue_id} dir=ul mbps=90

Start DL and UL Data Traffic SA A B4
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=100
    ...    pass_regexp=UE1: Started Downlink Internal traffic Receiver on Ue:1 Pdu:1 Qfi:1 TrfId:1
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=ul mbps=100
    ...    pass_regexp=Started Uplink Internal traffic Receiver on Ue:1 UpfId:1 Pdu:1 Qfi:1 TrfId:1
    Sleep    30s

Verify Timing Advance Counters
     [Arguments]   ${counter_id}
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Raw Pm Counters File
	Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=${counter_id}
    ...    value=1
    ...    local_moid=${LOCAL_MOID}
    ...    filepath=${PM_COUNTERS}

Verify Tput For UE SA
    [Arguments]   ${ue_id}    ${pdu}    ${qfi}    ${dir}    ${unit}    ${expected_tput}
    ${avg_tput}=    Get Avg Data Traffic Sa    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    dir=${dir}    unit=${unit}
    Should Be True    ${avg_tput} >= ${expected_tput}

Verify Tput For UE NSA
    [Arguments]   ${ue_id}    ${id}    ${dir}    ${unit}    ${expected_tput}
    ${avg_tput}=    Get Avg Data Traffic Nsa    ue_id=${ue_id}    id=${id}    dir=${dir}    unit=${unit}
    Should Be True    ${avg_tput} > ${expected_tput}

Verify DL and UL Tput SA
    ${cell_tput_dl}=    Get Avg Data Traffic For Given Cc    ue_id=1    cc=0    direction=dl    unit=Mbps
    ${cell_tput_ul}=    Get Avg Data Traffic For Given Cc    ue_id=1    cc=0    direction=ul    unit=Mbps
    Should Be True    ${cell_tput_dl} > ${800}
    Should Be True    ${cell_tput_ul} > ${120}

Stop All Data Transfers And Detach UE B2
    Execute Egate Command    cmd=trf_data_stop ue=1 pdu=1
    Sleep    5s
    Execute Egate Command    cmd=ue_deregister id=1 ue_deregister_type=switch_off

Stop All Data Transfers And Detach UE B3
    Execute Egate Command    cmd=trf_data_stop id=2 ue=11
    Sleep    5s
    Execute Egate Command    cmd=ue_detach id=11

Stop All Data Transfers And Detach UE SA
    [Arguments]    ${ue_id}
    Execute Egate Command    cmd=trf_data_stop ue=${ue_id} pdu=1
    Sleep    5s
    Execute Egate Command    cmd=ue_deregister id=${ue_id} ue_deregister_type=switch_off

Attach SA UE-${ue_id} to TDD Cell
    Check nrofDownlinkSymbols Is Aligned With GP Length      expected_value=8
    Set Internal Traffic Type To UE
    Set HighSpeed Testmodel
    Activate HighSpeed Test Model      profile_id=1
    Attach Ue    ue_id=${ue_id}
    Establish Pdu Session    ue_id=${ue_id}    pdu_id=1    gw_id=1

Check nrofDownlinkSymbols Is Aligned With GP Length
    [Arguments]      ${expected_value}
    Stop Capturing    alias=${TSHARK_ALIAS}
    Verify Tshark For At Least Given Number Of Messages
    ...    alias=${TSHARK_ALIAS}
    ...    packet_filter=nr-rrc.nrofDownlinkSymbols==${expected_value}
    ...    number_of_messages=1
    ...    source_ip='10.0.2.1/24'

Set HighSpeed Testmodel
    Execute Egate Command      cmd=ue_ta_nr profile_id=1 ue_fo_velocity=VELOCITY_APPROACHING_GNB_AT_350KMPH
    Execute Egate Command      cmd=ue_ta_nr profile_id=2 ue_fo_velocity=VELOCITY_LEAVING_GNB_AT_350KMPH

Activate HighSpeed Test Model
    [Arguments]      ${profile_id}
    Execute Egate Command     cmd=ue_testmode_set_nr id=1 testmode=ta action=activate profile_id=${profile_id}

Check Timing Advance Counters
    Wait For Next Full Pm Interval
    ${PM_COUNTERS_FILE}=    Get Latest Unpacked Raw Pm Counters File

    Create Timing Advance Counter List

    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=${TA_RACH_RESP_BIN_26}
    ...    value=1
    ...    local_moid=${LOCAL_MOID}
    ...    filepath=${PM_COUNTERS_FILE}

    Remove Values From List   ${TA_COUNTERS}    ${TA_RACH_RESP_BIN_26}

    Verify If Latest Pm Counters In Counter Id List Have Exact Value
    ...    counter_id_list=@{TA_COUNTERS}
    ...    value=0
    ...    local_moid=${LOCAL_MOID}
    ...    filepath=${PM_COUNTERS_FILE}

Create Timing Advance Counter List
    @{TA_COUNTERS}=    Create List
    FOR    ${ID}    IN RANGE    ${1}    ${10}
        Append To List    ${TA_COUNTERS}    M55307C0100${ID}
    END
    FOR    ${ID}    IN RANGE    ${10}    ${33}
        Append To List    ${TA_COUNTERS}    M55307C010${ID}
    END
    Set Test Variable    @{TA_COUNTERS}

Start Tshark With Alias
    Start Tshark
    ...    log_filename=10784_uu.pcapng
    ...    alias=${TSHARK_ALIAS}
    ...    eth_interface=eth4
    ...    capture_filter=''
    ...    log_dirpath=${TSHARK_DIR}

Stop Tshark With Alias
    Stop Tshark    alias=${TSHARK_ALIAS}
    Remove Directory    path=${TSHARK_DIR}    recursive=True

Start Gathering BIP Logs
    [Documentation]     Collect L1L2 BIP Logs using taf.ul.gnb.bip.collection - scripting approach
    ...     -   :param alias:     Alias for l1l2bip which is also a directory name (default L1L2_BIP_Logs)
    ...     -   :param bb_mods:   List of BB modules to start collection from them, default: [ABIO]
    [Arguments]
    ...     ${bb_mods}=[ABIO]

    bip_collection.Configure Bip Collection     l1_type=FS
    ...                                         gNB_common_unit=ASIL
    ...                                         gNB_capacity_units=${bb_mods}
    ...                                         use_script=True
    bip_collection.Start Bip Trace
    Log to console  BIP logs collecting started

Stop gnbMirroring And Gather L1L2 Bip
    [Documentation]     Stop collecting BIP Logs and save them at selected location
    ...     -   :param alias:       Alias for l1l2bip which is also a directory name without spaces (default L1L2_BIP_Logs)
    ...     -   :param dir_path:    Path where BIP logs should be copied (default ${OUTPUT_DIR}/
    ...     -   :param delay:       Time to wait before collecting the logs
    [Arguments]
    ...     ${alias}=L1L2_BIP_Logs
    ...     ${dir_path}=${OUTPUT_DIR}
    ...     ${delay}=5
    Sleep  ${delay}
    Create directory  path=${dir_path}/${alias}
    Create directory  path=/tmp/${alias}
    bip_collection.Stop Bip Trace   target_dir=/tmp/${alias}
    ${rc}=    Run And Return Rc  mergecap -a /tmp/${alias}/BTS1_*.pcap* -w /tmp/${alias}/tcpdump.pcap
    Run keyword if    ${rc}!=0    Fail    PCAP merging failed, check if alias does not contain spaces
    Copy File    /tmp/${alias}/tcpdump.pcap    ${dir_path}/BIP_L1L2.pcap
    Remove directory    /tmp/${alias}    recursive=True
    Log to console  BIP logs collecting finished
    Convert pcap file to pdml A B4

Convert pcap file to pdml A B4
    [Documentation]     Using luashark converting BIP log from pcap to pdml.
    [Arguments]   ${input_file}=${OUTPUT_DIR}/BIP_L1L2.pcap
    Log to console    Converting pcap to pdml
    ${tshark_cmd} =    Catenate    tshark
    ...    -r ${input_file}
    ...    -Y "dldata_pdschsendreql1sw && DlData_PdschGrantL1sw.rateMatchingOption ==1 && DlData_PdschGrantL1sw.numRateMatchingRes !=0"
    ...    -T pdml > ${OUTPUT_DIR}/BIP_log.pdml
    Run    ${tshark_cmd}
    Log to console    Pcap->Pdml conversion done...
    Sleep    5s

Convert pcap File To pdml C C1
    [Documentation]     Using luashark converting BIP log from pcap to pdml.
    [Arguments]         ${input_file}=${OUTPUT_DIR}/airphonel1l2bip/tcpdump.pcap
    Log to console    Converting pcap to pdml
    ${tshark_cmd} =   Catenate    tshark
    ...    -r ${input_file}
    ...    -Y "((sw_l1xue_ssburstoffloadreceiveresp) && (sw_L1xUe_SSBurstOffloadReceiveResp_t.ssbProcessingStatus == 0))
    ...    && (sw_L1xUe_SSBurstOffloadReceiveResp_t.slot == 0)"
    ...    -T pdml > ${OUTPUT_DIR}/airphonel1l2bip/BIP_log.pdml
    Run    ${tshark_cmd}
    Log to console    Pcap->Pdml conversion done...
    Sleep    5s

Verify CSI-RS In Some BI Slots
    ${rateMatchingOption}    ${numRateMatchingRes}    Get rateMatchingOption And numRateMatchingRes    pdml_path=${OUTPUT_DIR}/BIP_log.pdml
    Should Be True    ${rateMatchingOption}==${1}
    Should Be True    ${numRateMatchingRes}!=${0}

Check Transmission Of SSB Is On 19PRBs On 2nd OFDM symbol
    ${data_item_list}    Get ssburstoffloadreceiveresp Data List
    ${list_len}    Get Length    ${data_item_list}
    ${zeros_amount}    Count Values In List    ${data_item_list}    ${0}
    Should Be Equal    ${zeros_amount}    ${list_len}

Get ssburstoffloadreceiveresp Data List
    [Arguments]    ${pdml_file_path}=${OUTPUT_DIR}/airphonel1l2bip/BIP_log.pdml
    ${out_ssburstoffloadreceiveresp_data}    get_ssburstoffloadreceiveresp_data    pdml_path=${pdml_file_path}
    [Return]    ${out_ssburstoffloadreceiveresp_data}

Check guardPeriodLength Value For Cell C C1
    [Arguments]    ${cell_id}    ${expected_value}
    ${out}    Get guardPeriodLength Value For Cell    cell_id=${cell_id}
    log to console    NRCELL-${cell_id}.guardPeriodLength = ${out}
    Should Be Equal    ${out}    ${expected_value}

Get guardPeriodLength Value For Cell
    [Arguments]    ${cell_id}
    ${nrcell_a_distname}    ${id_list}    ADMIN Get Object Distname And Id List
    ...    alias=admin
    ...    class_name=NRCELL_A
    ${parameter}    ADMIN Get Parameter
    ...    dist_name=${nrcell_a_distname}-${cell_id}
    ...    parameter=guardPeriodLength
    ...    connection=admin
    [Return]    ${parameter['tddFrameStructure']['guardPeriodLength']}

Start DL and UL Data Traffic C C1
    [Arguments]    ${dl_tput}    ${ul_tput}    ${ue}=1    ${pdu}=1    ${quantity}=1
    FOR    ${i}    IN RANGE    ${quantity}
        Execute Egate Command And Wait For Data
        ...    cmd=trf_data_start ue=${ue} pdu=${pdu} qfi=1 trf_id=${i+1} mbps=${dl_tput} dir=dl seconds=180 size=8000
        ...    pass_regexp=UE${ue}: Started Downlink Internal traffic Receiver on Ue:${ue} Pdu:${pdu} Qfi:1 TrfId:${i+1}
        Execute Egate Command And Wait For Data
        ...    cmd=trf_data_start ue=${ue} pdu=${pdu} qfi=1 trf_id=${i+1} mbps=${ul_tput} dir=ul seconds=180 size=8000
        ...    pass_regexp=Started Uplink Internal traffic Receiver on Ue:${ue} UpfId:1 Pdu:${pdu} Qfi:1 TrfId:${i+1}
        Sleep    1s
    END

Verify Average Tput For UE SA C C1
    [Arguments]   ${ue_id}    ${pdu}    ${qfi}    ${dir}    ${unit}    ${expected_tput}    ${accuracy}=99
    ${avg_tput}=    Get Avg Data Traffic Sa    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    dir=${dir}    unit=${unit}
    Should Be True    ${avg_tput} > ${expected_tput}*0.${accuracy}

Stop All Data Transfers And Detach UE SA C C1
    Execute Egate Command    cmd=trf_data_stop ue=1 pdu=1
    Sleep    5s
    Execute Egate Command    cmd=ue_deregister id=1 ue_deregister_type=switch_off

Download AP MCshark Plugin
    [Arguments]    ${url}=https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/MCShark_AirPhone/
    ...            ${plugin_path}=/usr/lib/x86_64-linux-gnu/wireshark/plugins/3.6/epan
    ${ap_sw}    Get AP SW release
    ${plugin_name}    Get Proper AP MCshark Plugin Name    ap_sw=${ap_sw}    url=${url}
    ${mcshark_downloaded}    Run Keyword And Return Status    Check If AP MCshark Plugin Is Downloaded
    ...                                                       plugin_path=${plugin_path}
    ...                                                       plugin_name=${plugin_name}
    Run Keyword If    not ${mcshark_downloaded}    Get Plugin From URL    ap_sw=${ap_sw}
    ...                                                                   plugin_name=${plugin_name}
    ...                                                                   plugin_path=${plugin_path}
    ...                                                                   url=${url}
    Run Keyword If    ${mcshark_downloaded}    Log To Console    plugin already downloaded \n${plugin_name}

Get AP SW release
    ssh.Connect to  192.168.200.1   toor4nsn    oZPS0POrRieRtu   alias=iphy
    ${output}=  ssh.Execute  head -n1 /ffs/run/TargetBD*xml  connection=iphy
    ${version}=  Get regexp matches  ${output}  cbtsSoftwareReleaseVersion="5G_([\\d\.]+)"  1
    Log to console    AP version: ${version}[0]
    [Teardown]  ssh.Disconnect  connection=iphy
    [Return]    ${version}[0]

Get Proper AP MCshark Plugin Name
    [Arguments]    ${ap_sw}    ${url}
    ${token}=    get_ca_ute_artifactory_token
    ${token_header}=    Catenate    Authorization:Bearer ${token}
    ${rc}    ${out}    Run And Return Rc And Output
    ...      curl -H "${token_header}" -s ${url}${ap_sw}/ | grep REL_LOKI_UE+buster.so | cut -d'"' -f2 | head -1
    [Return]    ${out}

Check If AP MCshark Plugin Is Downloaded
    [Arguments]    ${plugin_path}    ${plugin_name}
    ${out}    Run    ls ${plugin_path} | grep ${plugin_name}
    Should Not Be Empty    ${out}

Get Plugin From URL
    [Arguments]    ${ap_sw}    ${plugin_name}    ${plugin_path}    ${url}
    ${token}=    get_ca_ute_artifactory_token
    Run    sudo wget --header='Authorization:Bearer ${token}' ${url}${ap_sw}/${plugin_name} -P ${plugin_path}
    ${out}    Run    ls -h -s ${plugin_path} | grep ${plugin_name}
    log to console    plugin downloaded: ${out} \nto path: ${plugin_path}
