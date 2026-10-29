*** Settings ***
Documentation
...    copyright: Nokia

Force Tags    CLOUD_5G_I_LO_AP_LO   VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    CRT    SBTS00    RAN_5G
...   RAN_5G_TDD

Resource    ../resources/5G_SW_WRO_Keywords.robot
Resource    ../CB007813/connect.robot
Resource    resources/main_vran.robot
Resource    ../resources/5G_SW_WRO_Keywords.robot

Library     ../resources/Python/webem_alarms.py
Library     ../CB008367/CB008367.py
Library     OperatingSystem
Library     taf.collectors.tcpdump          WITH NAME    tcpdump
Library     taf.collectors.l2stream3        WITH NAME    l2stream3
Library     taf.collectors.core             WITH NAME    core
Library     taf.converters.eventdecoder     WITH NAME    tce
Library     taf.sbts.oam.coam.admin         WITH NAME    coam
Library     taf.transport.ssh               WITH NAME    ssh
Library     ../CB007813/CB007813-B_keywords.py
Library     ../CB007813/vendor_file_modifier.py
Library     Collections
Library      ../CB010411_vRAN/resources/commissioning_vran.py
Library      resources/traffic.py
Library      ta5g_commissioning
Library      ta5g_iphy
Library      ta5g_admin_operations
Library      ../CB008697/CB008697_keywords.py
Library     taf.ccs.aashell   WITH NAME    aashell


Suite Setup    Run Keywords    Enable Cloud
...            AND             Create Suite Scope Variables
...            AND             Set RAD Parameters
...            AND             Update And Put Iphy Xml Aic
...                               input_filepath=${CURDIR}/config/iphy_8367_ab2.xml
...                               output_dirpath=${OUTPUT_DIR}
...            AND             Call Ap Console Reboot
...            AND             Fix SerialNumberPlanned And ProdCodePlanned And Send Full Commissioning Vdu With Given Scf Filepath
...                               scfc_filepath=${CURDIR}/config/default/scf_ab2_vdu.xml
...                               output_dirpath=${OUTPUT_DIR}
...            AND             Perform Commissioning Vcu Aic
...                               path_to_plan_file=${CURDIR}/config/scf_ab2_cu.xml
...            AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}
...            AND             Check Radios Availability Aic
...                               timeout=300
...            AND             Wait For F1 Links To Be Available Aic
...            AND             Reach Onair Aic
...                            check_edaemon_port=${True}
...                            lua_cfg=${CURDIR}/config/basic_setup_A_B2_32UE.lua

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${search_space_id_large} =          8
${search_space_id_small} =          13

@{K1K2_SLOTS}=                      2    7    12    17

*** Test Cases ***
CB008367_A_B2_Multi_UE_Small_BWP_and_1x_UE_Large_BWP
    Attach And Pdu Session For Ues
    ...    ues=${32}
    ...    pass_regex=BandwidthpartIndicator: 1

    Start 1 Mbps Uplink Traffic For UEs 1-32
    Run 9Mbps DL Traffic For Small BWP UEs
    Run 64Mbps DL Traffic For Large BWP UEs

    Display Actual Traffic For UEs 1-32

    Collect Tti Trace For 1 Seconds with CB008367_enabled
    CB008367.Check Pdsch Correctness For Large And Small A B2    csv_path=${OUTPUTDIR}/TTI_TRACE_CB008367_enabled/
    ...    filename=TTI_TRACE_dl.csv
    ...    search_space_id_large=${search_space_id_large}
    ...    search_space_id_small=${search_space_id_small}
    ...    pdcch_start_symbol_large=1
    ...    pdcch_start_symbol_small=17
    CB008367.Check Pdsch Correctness For Large And Small A B2    csv_path=${OUTPUTDIR}/TTI_TRACE_CB008367_enabled/
    ...    filename=TTI_TRACE_dl.csv
    ...    search_space_id_large=${search_space_id_large}
    ...    search_space_id_small=${search_space_id_small}
    ...    pdcch_start_symbol_large=17
    ...    pdcch_start_symbol_small=17


*** Keywords ***
Set RAD Parameters
    &{k8s_DU}=    Create Dictionary
    ...    host=${MASTER_DU}[hostname]
    ...    user=${MASTER_DU}[username]
    ...    password=${MASTER_DU}[password]

    aashell.create_aashell_cli
    ...    name=aashell_cprt
    ...    hops=${k8s_DU}
    ...    namespace=${NAMESPACE_DU}
    ...    pod=ute-${NAMESPACE_DU}-cprt-0
    ...    port=15057

    ${params}=    Create List
    ...    0x5808FF  2

    aashell.setup    aashell_cprt
    aashell.change_rad_params    aashell_cprt    ${params}    is_permanent=True
    aashell.execute_aashell_command  aashell_cprt  command=rad -u

    [Teardown]  aashell.teardown   aashell_cprt

Start ${amount} ${unit} Uplink Traffic For UEs ${first_ue}-${last_ue}
    FOR    ${index}    IN RANGE    ${first_ue}-${1}    ${last_ue}
        ${ue_id}=    Evaluate    ${index}+${1}
        ${pdu_index}=    Evaluate    ${index}%${15}+${1}
        Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_index} dir=ul ${unit}=${amount}
        ...    pass_regexp=Started Uplink Internal traffic Receiver on Ue:${ue_id} UpfId:1 Pdu:${pdu_index} Qfi:1 TrfId:1
    END

Run 9Mbps DL Traffic For Small BWP UEs
    FOR    ${index3}    IN RANGE    1    7
        Pump Traffic By 2Mbit For UEs 1-24 With Trfid${index3}
    END

Run 64Mbps DL Traffic For Large BWP UEs
    FOR    ${index2}    IN RANGE    1    7
        Pump Traffic By 13Mbit For UEs 25-32 With Trfid${index2}
        Sleep    1s
    END

Display Actual Traffic For UEs ${start_ue}-${last_ue}
    FOR    ${ue_id}    IN RANGE    ${start_ue}    ${last_ue}+${1}
        Verify Tput On Scell    ue_id=${ue_id}    cc=0     tput_expected=True
    END

Pump Traffic By ${x}Mbit For UEs ${start_ue}-${last_ue} With Trfid${trf_id}
    FOR    ${index}    IN RANGE    ${start_ue}-${1}    ${last_ue}
        ${pdu_index}=    Evaluate    ${index}%${15}+${1}
        ${ue_id}=    Evaluate    ${index}+${1}
        Start Data Dl X    ue_id=${ue_id}    pdu_id=${pdu_index}    trf_id1=${trf_id}    x=${x}
    END

Run DL Traffic For Small BWP UEs
    FOR    ${index3}    IN RANGE    1    7
        Pump Traffic By 2Mbit For UEs 1-24 With Trfid${index3}
    END

Run DL Traffic For Large BWP UEs
    FOR    ${index2}    IN RANGE    1    7
        Pump Traffic By 13Mbit For UEs 25-32 With Trfid${index2}
        Sleep    1s
    END

Run UL Traffic For ${ues} UEs
    FOR    ${index}    IN RANGE    0    ${ues}
        ${ue_id}=    Evaluate    ${index}+${1}
        ${pdu_index}=    Evaluate    ${index}%${15}+${1}
        Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_index} dir=ul mbps=1
        ...    pass_regexp=Started Uplink Internal traffic Receiver on Ue:${ue_id} UpfId:1 Pdu:${pdu_index} Qfi:1 TrfId:1
    END

Attach And Pdu Session For Ues
    [Arguments]    ${ues}    ${pass_regex}
    FOR    ${index1}    IN RANGE    0    ${ues}
        ${pdu_index}=    Evaluate    ${index1}%${15}+${1}
        ${ue_id}=    Evaluate    ${index1}+${1}
        Execute Egate Command   cmd=set_pdu_param ue=${ue_id} pdu=${pdu_index} trf_type=internal
        ta5g_ue_mobility.Attach Ue    ue_id=${ue_id}
        Execute Egate Command And Wait For Data
        ...    cmd=ue_pdu_session_setup pdu=${pdu_index} ue=${ue_id} nwslice=1 gw=${ue_id}
        ...    pass_regexp=${pass_regex}
    END

Start Dl and UL Data Traffic For All UEs
    FOR    ${id}    IN RANGE    1    25
        Start 2mbs Data Traffic In DL And 3mbs In UL    ue_id=${id}
    END
    FOR    ${id}    IN RANGE    25    33
        Start 17mbs Data Traffic In DL And 3mbs In UL    ue_id=${id}
    END
    Sleep    30s

Attach UEs with Large And PWS BWP Capability
    FOR    ${id}    IN RANGE    1    33
        Set Internal Traffic Type To UE    ue_id=${id}    pdu_id=1
        ta5g_ue_mobility.Attach Ue    ue_id=${id}
        Establish Pdu Session    ue_id=${id}     pdu_id=1     gw_id=${id}
    END

Set Internal Traffic Type To UE
    [Arguments]    ${ue_id}
    Execute Egate Command   cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal

Start 2mbs Data Traffic In DL And 3mbs In UL
    [Arguments]   ${ue_id}
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=1 dir=dl mbps=4 trf_id=1
    ...    pass_regexp=UE${ue_id}: Started Downlink Internal traffic Receiver on Ue:${ue_id} Pdu:1 Qfi:1 TrfId:1
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=1 dir=ul mbps=3 trf_id=1
    ...    pass_regexp=Started Uplink Internal traffic Receiver on Ue:${ue_id} UpfId:1 Pdu:1 Qfi:1 TrfId:1

Start 17mbs Data Traffic In DL And 3mbs In UL
    [Arguments]   ${ue_id}
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=1 dir=dl mbps=2 trf_id=1
    ...    pass_regexp=UE${ue_id}: Started Downlink Internal traffic Receiver on Ue:${ue_id} Pdu:1 Qfi:1 TrfId:1
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=1 dir=ul mbps=3 trf_id=1
    ...    pass_regexp=Started Uplink Internal traffic Receiver on Ue:${ue_id} UpfId:1 Pdu:1 Qfi:1 TrfId:1

Collect Tti Trace For ${time} Seconds with ${feature_status}
    Start TTI trace
    Sleep    ${time}s
    Stop TTI trace
    Convert TTI trace from pcap to excelCsv    ${feature_status}

Start TTI trace
    ${webservice}=  Create Dictionary
    ...  host=192.168.255.129
    ...  user=Nemuadmin
    ...  password=Nokia@123
    @{nr_cell_dns}    Create List    MRBTS-1/NRBTS-1/NRCELL-1
    ${l2_stream_config}=  Create Dictionary
    ...  trace_type=Component
    ...  target_component=L2Ps
    ...  nr_cell_dn_list=${nr_cell_dns}
    @{l2_stream_configuration}    Create List    ${l2_stream_config}
    tcpdump.create tcpdump collector
    ...  name=tcpdump
    ...  options=-i eth9 udp and dst 172.16.2.10 and dst port 5678
    ...  sudo_password=ute
    l2stream3.create vdu l2stream collector
    ...  name=l2stream
    ...  webservice=${webservice}
    ...  destination_ip_addr=172.16.2.10
    ...  collector=tcpdump
    ...  l2_stream_configuration=${l2_stream_configuration}
    l2stream3.Set Suite Alias     l2stream
    core.setup_collectors      names=l2stream
    core.start_collectors      names=l2stream

Stop TTI trace
    core.stop_collectors      names=l2stream
    core.collect_collectors      names=l2stream
    ...  target_dir=${OUTPUT_DIR}
    core.teardown_collectors      names=l2stream

Convert TTI trace from pcap to excelCsv
    [Arguments]    ${feature_status}
    tce.Create eventDecoder converter
    ...  name=ttitrace_converter
    ...  input_file_path=${OUTPUT_DIR}/l2stream/tcpdump/tcpdump.pcap
    ...  output_file_format=excelCsv
    ...  output_file_path=${OUTPUTDIR}/TTI_TRACE/
    tce.Convert
    ...  name=ttitrace_converter

    Move File    ${OUTPUT_DIR}/l2stream/tcpdump/tcpdump.pcap    ${OUTPUT_DIR}/TTI_TRACE_${feature_status}/tcpdump.pcap
    Move File    ${OUTPUT_DIR}/TTI_TRACE_dl.csv   ${OUTPUT_DIR}/TTI_TRACE_${feature_status}/TTI_TRACE_dl.csv
    Move File    ${OUTPUT_DIR}/TTI_TRACE_ul.csv   ${OUTPUT_DIR}/TTI_TRACE_${feature_status}/TTI_TRACE_ul.csv

    Set Global Variable      ${TTI_TRACE_DL}      ${OUTPUT_DIR}/TTI_TRACE_${feature_status}/TTI_TRACE_dl.csv
    Set Global Variable      ${TTI_TRACE_UL}      ${OUTPUT_DIR}/TTI_TRACE_${feature_status}/TTI_TRACE_ul.csv
