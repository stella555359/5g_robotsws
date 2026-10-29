*** Settings ***
Documentation    :copyright: Nokia

Library    Collections
Library    OperatingSystem
Library    String
Library    taf.collectors.core        WITH NAME    core
Library    taf.collectors.l1l2bip     WITH NAME    l1l2bip
Library    taf.collectors.tcpdump     WITH NAME    tcpdump
Library    taf.sbts.oam.coam.admin    WITH NAME    admin
Library    taf.transport.ssh          WITH NAME    ssh
Library    testsuite.Wroclaw.RRM.VRF_WRO1_T04.resources.Tokens
Library    ../../CB007262/CB007262_A/CB007262_keywords.py
Library    ./CB010784_C_keywords.py

*** Variables ***
${shell_script}     /opt/wts/latest/sosReport_ASIL/airphone_mirror.sh    # This can be where you have kept the file
${python_script}    /opt/wts/latest/sosReport_ASIL/gnbMirroring.py       # This can be where you have kept the file

*** Keywords ***
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

ADMIN Setup Admin
    [Arguments]    ${alias}=admin
    admin.Setup Admin
    ...    alias=${alias}

ADMIN Teardown Admin
    [Arguments]    ${alias}=admin
    admin.Teardown Admin
    ...    connection=${alias}

ADMIN Get Managed Objects With Parameters
    [Documentation]    Get managed objects with parameters
    ...    class_name example: SMOD, RMOD_R, GNSS_L, NRCELL_A, NRCELL_L, NRCELL_R ...
    [Arguments]    ${class_name}    ${timeout}=60    ${alias}=admin
    ${out_list_of_objects_parameters_dict}    admin.get_managed_objects
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
    [Arguments]    ${class_name}    ${alias}=admin
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
    [Arguments]    ${dist_name}    ${parameter}    ${timeout}=10    ${connection}=admin
    ${out_parameters}    admin.get_parameters
    ...    dist_name=${dist_name}
    ...    pattern=${parameter}
    ...    timeout=${timeout}
    ...    connection=${connection}
    [Return]    ${out_parameters}

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

Check guardPeriodLength Value For Cell
    [Arguments]    ${cell_id}    ${expected_value}
    ADMIN Setup Admin
    ${out}    Get guardPeriodLength Value For Cell    cell_id=${cell_id}
    log to console    NRCELL-${cell_id}.guardPeriodLength = ${out}
    Should Be Equal    ${out}    ${expected_value}
    ADMIN Teardown Admin

Set Internal Traffic Type To UE
    [Arguments]   ${ue}=1    ${pdu}=1
    Execute Egate Command   cmd=set_pdu_param ue=${ue} pdu=${pdu} trf_type=internal

Start DL and UL Data Traffic
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

Verify Average Tput For UE SA
    [Arguments]   ${ue_id}    ${pdu}    ${qfi}    ${dir}    ${unit}    ${expected_tput}    ${accuracy}=99
    ${avg_tput}=    Get Avg Data Traffic Sa    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    dir=${dir}    unit=${unit}
    Should Be True    ${avg_tput} > ${expected_tput}*0.${accuracy}

Stop All Data Transfers And Detach UE SA
    Execute Egate Command    cmd=trf_data_stop ue=1 pdu=1
    Sleep    5s
    Execute Egate Command    cmd=ue_deregister id=1 ue_deregister_type=switch_off

Convert pcap File To pdml
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

Get ssburstoffloadreceiveresp Data List
    [Arguments]    ${pdml_file_path}=${OUTPUT_DIR}/airphonel1l2bip/BIP_log.pdml
    ${out_ssburstoffloadreceiveresp_data}    get_ssburstoffloadreceiveresp_data    pdml_path=${pdml_file_path}
    [Return]    ${out_ssburstoffloadreceiveresp_data}

Check Transmission Of SSB Is On 19PRBs On 2nd OFDM symbol
    ${data_item_list}    Get ssburstoffloadreceiveresp Data List
    ${list_len}    Get Length    ${data_item_list}
    ${zeros_amount}    Count Values In List    ${data_item_list}    ${0}
    Should Be Equal    ${zeros_amount}    ${list_len}

Check Transmission Of SSB Is On 20PRBs On 2nd OFDM symbol
    ${data_item_list}    Get ssburstoffloadreceiveresp Data List
    List Should Not Contain Value    ${data_item_list}    ${0}

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
    ...                curl -H "${token_header}" -s ${url}${ap_sw}/ | grep REL_LOKI_UE+buster.so | cut -d'"' -f2 | head -1
    [Return]    ${out}

Get Plugin From URL
    [Arguments]    ${ap_sw}    ${plugin_name}    ${plugin_path}    ${url}
    ${token}=    get_ca_ute_artifactory_token
    Run    sudo wget --header='Authorization:Bearer ${token}' ${url}${ap_sw}/${plugin_name} -P ${plugin_path}
    ${out}    Run    ls -h -s ${plugin_path} | grep ${plugin_name}
    log to console    plugin downloaded: ${out} \nto path: ${plugin_path}

Check If AP MCshark Plugin Is Downloaded
    [Arguments]    ${plugin_path}    ${plugin_name}
    ${out}    Run    ls ${plugin_path} | grep ${plugin_name}
    Should Not Be Empty    ${out}

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
