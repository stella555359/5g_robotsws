*** Settings ***
Documentation
...    copyright: Nokia

Force Tags    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD    CRT    SBTS00    RAN_5G    RAN_5G_TDD

Resource    ../resources/5G_SW_WRO_Keywords.robot
Library     ../resources/Python/webem_alarms.py
Library     ../CB007813/CB007813-B_keywords.py
Library     CB008367-C.py
Library     taf.collectors.tcpdump          WITH NAME    tcpdump
Library     taf.collectors.l2stream3        WITH NAME    tcl
Library     taf.collectors.core             WITH NAME    tcc
Library     taf.converters.eventdecoder     WITH NAME    tce
Library     taf.sbts.oam.coam.admin         WITH NAME    coam
Library     taf.transport.ssh               WITH NAME    ssh
Resource     ../resources/configuration_id.robot


Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/iphy_1AEQE_GSCN_7853.xml
    ...                        swconfig_flags_list=@{SWCONFIG_FLAGS}
    ...        AND             Start Default Logging
    ...        AND             Find Scfc And Fix And Send Full Commissioning
    ...                        scfc_filename=CB008367-C_B2_large_100M_small_80M_PS_20M_basic.xml
    ...        AND             Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/basic_setup_C-B2.cfg

Suite Teardown   Run Keywords    Print Active Alarms
    ...    AND    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
@{SWCONFIG_FLAGS}=                      0x58057A = 4  #rdFeatureFlagBitMapLevel
...                                     0x58057d = 1073741824  #L2.L2_PS.PDCCH.DYN_TD_MGT 0x58057d 30
...                         0x5808FF=2
# 0x580900-5 and 0x5808FF=1 - flags related to CB008367 events visibility in TTI Trace

${DELTA_8367_ACT}=                      delta_CB008367_activation_C-B2.json
${LOCAL_MOID}=                          PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
@{K1K2_SLOTS}=                          1    6    11    16

*** Test Cases ***
CB008367-C_B2_basic_3BWPs_CCE_split_only_in_large_and_PS_BWPs_cRBStart_of_CS1=60_CS2=42_CS4=0
    Attach UE-1 with BWP Capability
    Attach UE-2 with BWP Capability
    Attach UE-3 with BWP Capability
    Start 175M DL And 50M UL Data Traffic For UE-1
    Start 100M DL And 50M UL Data Traffic For UE-2
    Start Low Data Traffic For UE-3 And Check Switch To PS BWP
    Activate CB008367 Online
    Collect Tti Trace For 2 Seconds with CB008367_enabled
    Check CCE Split Is Visible In Large And PS BWP
    [Teardown]    Run Keywords    Stop All Data Transfers And Detach UE-1
    ...    AND    Stop All Data Transfers And Detach UE-2
    ...    AND    Stop All Data Transfers And Detach UE-3
    ...    AND    Send Configuration ID To Scout

*** Keywords ***
Collect Tti Trace For ${time} Seconds with ${feature_status}
    Start TTI trace
    Sleep    ${time}s
    Stop TTI trace
    Convert TTI trace from pcap to excelCsv    ${feature_status}

Start TTI trace
    ${configurations}=  tcc.Load Configurations
    ...  ${CURDIR}/ttitrace_collectors.yaml
    tcc.Create collectors
    ...  names=l2stream3
    ...  configurations=${configurations['collectors']}
    tcl.Set suite alias
    ...  alias=l2stream3
    tcc.Setup collectors
    ...  names=l2stream3
    tcc.Start collectors
    ...  names=l2stream3

Stop TTI trace
    tcc.Stop collectors
    ...  names=l2stream3
    tcc.Collect collectors
    ...  names=l2stream3
    ...  target_dir=${OUTPUT_DIR}
    tcc.Teardown collectors
    ...  names=l2stream3

Convert TTI trace from pcap to excelCsv
    [Arguments]    ${feature_status}
    tce.Create eventDecoder converter
    ...  name=ttitrace_converter
    ...  input_file_path=${OUTPUT_DIR}/l2stream3/tcpdump/tcpdump.pcap
    ...  output_file_format=excelCsv
    ...  output_file_path=${OUTPUTDIR}/TTI_TRACE/
    tce.Convert
    ...  name=ttitrace_converter

    Move File    ${OUTPUT_DIR}/l2stream3/tcpdump/tcpdump.pcap    ${OUTPUT_DIR}/TTI_TRACE_${feature_status}/tcpdump.pcap
    Move File    ${OUTPUT_DIR}/TTI_TRACE_dl.csv   ${OUTPUT_DIR}/TTI_TRACE_${feature_status}/TTI_TRACE_dl.csv
    Move File    ${OUTPUT_DIR}/TTI_TRACE_ul.csv   ${OUTPUT_DIR}/TTI_TRACE_${feature_status}/TTI_TRACE_ul.csv

    Set Global Variable      ${TTI_TRACE_DL}      ${OUTPUT_DIR}/TTI_TRACE_${feature_status}/TTI_TRACE_dl.csv
    Set Global Variable      ${TTI_TRACE_UL}      ${OUTPUT_DIR}/TTI_TRACE_${feature_status}/TTI_TRACE_ul.csv

Attach UE-${id} with BWP Capability
    Set Internal Traffic Type To UE    ue_id=${id}    pdu_id=${id}
    Attach Ue    ue_id=${id}
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
    ...    pass_regexp=Bwp switch received from bwpId 1 to 2
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

Activate CB008367 Online
    Find Scfc and Send Delta Commissioning    scfc_filename=${DELTA_8367_ACT}
    Sleep    5s
