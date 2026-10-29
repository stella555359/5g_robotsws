*** Settings ***
Documentation
...    copyright: Nokia

Force Tags    CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC    CONFIGURED
...           RAN_5G_TDD    RAN_5G    SBTS00

Resource     resources/8608_keywords.robot
Resource     resources/main_vran.robot
Resource     ../resources/5G_SW_WRO_Keywords.robot
Resource     ../CB008697/CB008697_variables.robot
Library      ../CB007262/CB007262_A/CB007262_keywords.py
Library      ../resources/Python/webem_alarms.py
Library      resources/commissioning_vran.py
Library      ta5g_commissioning
Library      ta5g_iphy
Library      ta5g_admin_operations
Library      ta5g_ue_mobility
Library     ../CB008697/CB008697_keywords.py
Library      resources/counters_vdu.py
Library     ../CB008367/CB008367-C.py
Library     taf.collectors.tcpdump          WITH NAME    tcpdump
Library     taf.collectors.l2stream3        WITH NAME    l2stream3
Library     taf.collectors.core             WITH NAME    core
Library     taf.converters.eventdecoder     WITH NAME    tce
Library     taf.sbts.oam.coam.admin         WITH NAME    coam
Library     taf.transport.ssh               WITH NAME    ssh
Library    taf.ccs.aashell   WITH NAME    aashell
Resource     ../resources/configuration_id.robot


Suite Setup    Run Keywords    Enable Cloud
...            AND             Create Suite Scope Variables
...            AND             Set RAD Parameters
...            AND             Update And Put Iphy Xml Aic
...                               input_filepath=${CURDIR}/config/iphy_8367_AEQP.xml
...                               output_dirpath=${OUTPUT_DIR}
...            AND             Call Ap Console Reboot
...            AND             Fix SerialNumberPlanned And ProdCodePlanned And Send Full Commissioning Vdu With Given Scf Filepath
...                               scfc_filepath=${CURDIR}/config/default/scf_8367_vdu.xml
...                               output_dirpath=${OUTPUT_DIR}
...            AND             Perform Commissioning Vcu Aic
...                               path_to_plan_file=${CURDIR}/config/default/scf_8367_vcu.xml
...            AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}
...            AND             Check Radios Availability Aic
...                               timeout=300
...            AND             Wait For F1 Links To Be Available Aic
...            AND             Reach Onair Aic
...                            check_edaemon_port=${True}
...                            lua_cfg=${CURDIR}/config/8367_n78.cfg

Suite Teardown   Run Keywords    Print Active Alarms
    ...    AND    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
@{K1K2_SLOTS}=                          5    6    15    16

*** Test Cases ***
CB008367-C_B2_basic_3BWPs_CCE_split_only_in_large_and_PS_BWPs_cRBStart_of_CS1=60_CS2=42_CS4=0
    Attach UE-1 with BWP Capability
    Attach UE-2 with BWP Capability
    Attach UE-3 with BWP Capability
    Start 175M DL And 50M UL Data Traffic For UE-1
    Start 100M DL And 50M UL Data Traffic For UE-2
    Start Low Data Traffic For UE-3 And Check Switch To PS BWP
    Collect Tti Trace For 2 Seconds with CB008367_enabled
    Check CCE Split Is Visible In Large And PS BWP
    [Teardown]    Run Keywords    Stop All Data Transfers And Detach UE-1
    ...    AND    Stop All Data Transfers And Detach UE-2
    ...    AND    Stop All Data Transfers And Detach UE-3
#    ...    AND    Send Configuration ID To Scout

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

Attach UE-${id} with BWP Capability
    Set Internal Traffic Type To UE    ue_id=${id}    pdu_id=${id}
    ta5g_ue_mobility.Attach Ue    ue_id=${id}
    Establish Pdu Session    ue_id=${id}     pdu_id=${id}     gw_id=${id}

Set Internal Traffic Type To UE
    [Arguments]    ${ue_id}    ${pdu_id}
    Execute Egate Command   cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal

Start ${amount_dl}M DL And ${amount_ul}M UL Data Traffic For UE-${id}
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${id} pdu=${id} dir=dl mbps=${amount_dl}
    ...    pass_regexp=UE${id}: Started Downlink Internal traffic Receiver on Ue:${id} Pdu:${id} Qfi:1 TrfId:1
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${id} pdu=${id} dir=ul mbps=${amount_ul}
    ...    pass_regexp=Started Uplink Internal traffic Receiver on Ue:${id} UpfId:1 Pdu:${id} Qfi:1 TrfId:1
    Sleep    10s

Start Low Data Traffic For UE-${id} And Check Switch To PS BWP
    Execute Egate Command    cmd=trf_data_start ue=${id} pdu=${id} dir=dl kbps=25 trf_id=1 period_ms=100
    Execute Egate Command    cmd=trf_data_start ue=${id} pdu=${id} dir=ul kbps=25 trf_id=1 period_ms=100
    ...    pass_regexp=Bwp Switched from bwpId 1 to 2
    Sleep    10s

Verify Tput For UE SA
    [Arguments]   ${ue_id}    ${dir}    ${expected_tput}
    ${avg_tput}=    Get Avg Data Traffic For Given Cc    ue_id=${ue_id}   cc=0   direction=${dir}    unit=Mbps
    Should Be True    ${avg_tput} > ${expected_tput}

Stop All Data Transfers And Detach UE-${id}
    Execute Egate Command    cmd=trf_data_stop ue=${id} pdu=${id}
    Sleep    5s
    Execute Egate Command    cmd=ue_deregister id=${id} ue_deregister_type=switch_off

Check CCE Split Is Visible In Large And PS BWP
    CCE Split Check
    ...    ul_trace_path=${TTI_TRACE_UL}
    ...    dl_trace_path=${TTI_TRACE_DL}
    ...    k1k2_slots=@{K1K2_SLOTS}
    ...    bwp_id=${1}
    ...    expected_cce_split=True

    CCE Split Check
    ...    ul_trace_path=${TTI_TRACE_UL}
    ...    dl_trace_path=${TTI_TRACE_DL}
    ...    k1k2_slots=@{K1K2_SLOTS}
    ...    bwp_id=${2}
    ...    expected_cce_split=False

    CCE Split Check
    ...    ul_trace_path=${TTI_TRACE_UL}
    ...    dl_trace_path=${TTI_TRACE_DL}
    ...    k1k2_slots=@{K1K2_SLOTS}
    ...    bwp_id=${3}
    ...    expected_cce_split=True

