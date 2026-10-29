*** Settings ***
Documentation
...    author: Marcin Kotula
...    maintainer: Marcin Kotula (marcin.kotula@nokia.com)
...    testline: CLOUD_5G_I_[MP][MP]_AP_[LOOO]
...    release: 25R2

Resource    resources/CB008367-B_keywords.robot
Library     CB008367.py
Library     taf.collectors.tcpdump          WITH NAME    tcpdump
Library     taf.collectors.l2stream3        WITH NAME    tcl
Library     taf.collectors.core             WITH NAME    tcc
Library     taf.converters.eventdecoder     WITH NAME    tce
Library     taf.sbts.oam.coam.admin         WITH NAME    coam10.0.108.14
Library     taf.transport.ssh               WITH NAME    ssh


*** Variables ***
${iphy_CB008367}               ${CURDIR}/config/iphy_AEQE_IWK3_ABIP.xml
${scf_CB008367}                ${CURDIR}/config/SBTS00/full_CB008367_IWK3_2_ABIP_100_MHz_Large_Small_PWS_BWP.xml
${cfg_CB008367}                ${CURDIR}/config/basic_setup_IWK3_ABIP.cfg
@{SWCONFIG_FLAGS_CB008367}     0x420068=1          0x420062=1     0x580900=8388640    0x580901=0    0x580902=4096
...                            0x580903=4194304    0x580904=0     0x580905=0          0x5808FF=2
# 0x420068 - rdTddPoolingFeaturesEnable      0x420062=1 : new cell slot model, rest of flags related to TTI filtering
# 0x580900-5 and 0x5808FF=1 - flags related to CB008367 events visibility in TTI Trace

${LOCAL_MOID}                  PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
${search_space_id_large}       8
${search_space_id_small}       13
${search_space_id_pws}         18
${pdcch_start_symbol_large}    1
${pdcch_start_symbol_small}    17
${PRB_AVAIL_PDSCH_BB_POOL}     M55308C10005

*** Keywords ***
CB008367-B_IWK3_with_CB008940_CB010513_BB_pooling_1UE_in_large-BWP_and_multi-UEs_in_small and_PS-BWPs
    Attach UEs with Large And Small BWP Capability
    Attach UEs with PWS BWP Capability
    Start Dl and UL Data Traffic For Small And Large BWP UEs
    Start Dl and UL Data Traffic For PWS BWP And Other UEs
    Collect Tti Trace For 1 Seconds with CB008367_enabled
    Switch PWS UEs to Small BWP
    Collect Tti Trace For 0.5 Seconds with CB008367_switch
    Verify PDCCH And PDSCH Before Switch
    Verify PDCCH And PDSCH After Switch
    Check DL PRB Allocated by BBRM
    Verify PRBs available for PDSCH Counter


Verify PDCCH And PDSCH Before Switch
    CB008367.Check Avg Num Of PDCCH Symbols    csv_path=${OUTPUT_DIR}/TTI_TRACE_CB008367_enabled/
    ...    filename=TTI_TRACE_dl.csv
    ...    search_space_id=${search_space_id_pws}
    ...    num_of_symbols=2

    CB008367.Check PDSCH Correctness For Large And Small
    ...    filename=TTI_TRACE_dl.csv
    ...    csv_path=${OUTPUT_DIR}/TTI_TRACE_CB008367_enabled/
    ...    search_space_id_large=${search_space_id_large}
    ...    search_space_id_small=${search_space_id_small}
    ...    pdcch_start_symbol_large=${pdcch_start_symbol_large}
    ...    pdcch_start_symbol_small=${pdcch_start_symbol_small}
    ...    coreset_size_large=192
    ...    coreset_size_small=168
    ...    pdsch_num_of_symbols_large=1
    ...    pdsch_num_of_symbols_small=2

Verify PDCCH And PDSCH After Switch
    CB008367.Check Avg Num Of PDCCH Symbols    csv_path=${OUTPUT_DIR}/TTI_TRACE_CB008367_switch/
    ...    filename=TTI_TRACE_dl.csv
    ...    search_space_id=${search_space_id_pws}
    ...    num_of_symbols=1

    CB008367.Check PDSCH Correctness For Large And Small
    ...    filename=TTI_TRACE_dl.csv
    ...    csv_path=${OUTPUT_DIR}/TTI_TRACE_CB008367_switch/
    ...    search_space_id_large=${search_space_id_large}
    ...    search_space_id_small=${search_space_id_small}
    ...    pdcch_start_symbol_large=${pdcch_start_symbol_large}
    ...    pdcch_start_symbol_small=${pdcch_start_symbol_small}
    ...    coreset_size_large=192
    ...    coreset_size_small=168
    ...    pdsch_num_of_symbols_large=1
    ...    pdsch_num_of_symbols_small=2

Verify PRBs available for PDSCH Counter
    Wait For Next Full Pm Interval
    ${pm_counters_filepath}=    Get Latest Unpacked Raw Pm Counters File

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PRB_AVAIL_PDSCH_BB_POOL}
    ...    value=10000000
    ...    local_moid=${LOCAL_MOID}
    ...    filepath=${pm_counters_filepath}

Switch PWS UEs to Small BWP
    FOR    ${id}    IN RANGE    18    71
        Start 2mbs Data Traffic In DL And 2mbs In UL    ue_id=${id}
    END
    Sleep    30s

Start Dl and UL Data Traffic For Small And Large BWP UEs
    FOR    ${id}    IN RANGE    5    18
        Start 2mbs Data Traffic In DL And 2mbs In UL    ue_id=${id}
    END

Start Dl and UL Data Traffic For PWS BWP And Other UEs
    Start 2mbs Data Traffic In DL And 2mbs In UL   ue_id=1
    Start 450mbs Data Traffic In DL And 2mbs In UL   ue_id=2
    Start 450mbs Data Traffic In DL And 2mbs In UL   ue_id=3
    Start 450mbs Data Traffic In DL And 2mbs In UL   ue_id=4
    FOR    ${id}    IN RANGE    18    72
        Start Low Data Traffic For UE And Check Switch To PS BWP    ue_id=${id}
    END
    Sleep    30s

Attach UEs with Large And Small BWP Capability
    FOR    ${id}    IN RANGE    1    18
        Set Internal Traffic Type To UE    ue_id=${id}    pdu_id=1
        Attach Ue    ue_id=${id}
        Establish Pdu Session    ue_id=${id}     pdu_id=1     gw_id=${id}
    END

Attach UEs with PWS BWP Capability
    FOR    ${id}    IN RANGE    18    72
        Set Internal Traffic Type To UE    ue_id=${id}    pdu_id=1
        Attach Ue    ue_id=${id}
        Establish Pdu Session    ue_id=${id}     pdu_id=1     gw_id=${id}
    END

Start 2mbs Data Traffic In DL And 2mbs In UL
    [Arguments]   ${ue_id}
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=1 dir=dl mbps=2 trf_id=1
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=1 dir=ul mbps=2 trf_id=1

Start 450mbs Data Traffic In DL And 2mbs In UL
    [Arguments]   ${ue_id}
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=1 dir=dl mbps=150 trf_id=1
    ...    pass_regexp=UE${ue_id}: Started Downlink Internal traffic Receiver on Ue:${ue_id} Pdu:1 Qfi:1 TrfId:1
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=1 dir=dl mbps=150 trf_id=2
    ...    pass_regexp=UE${ue_id}: Started Downlink Internal traffic Receiver on Ue:${ue_id} Pdu:1 Qfi:1 TrfId:2
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=1 dir=dl mbps=150 trf_id=3
    ...    pass_regexp=UE${ue_id}: Started Downlink Internal traffic Receiver on Ue:${ue_id} Pdu:1 Qfi:1 TrfId:3
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=1 dir=ul mbps=2 trf_id=1
    ...    pass_regexp=Started Uplink Internal traffic Receiver on Ue:${ue_id} UpfId:1 Pdu:1 Qfi:1 TrfId:1

Start Low Data Traffic For UE And Check Switch To PS BWP
    [Arguments]   ${ue_id}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 dir=dl kbps=150 trf_id=1
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 dir=ul kbps=5 trf_id=1
    ...    pass_regexp=Bwp switch received from bwpId 1 to 2

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
    ...  excel_csv_options=-d dl
    tce.Convert
    ...  name=ttitrace_converter

    Move File    ${OUTPUT_DIR}/l2stream3/tcpdump/tcpdump.pcap    ${OUTPUT_DIR}/TTI_TRACE_${feature_status}/tcpdump.pcap
    Move File    ${OUTPUT_DIR}/TTI_TRACE_dl*.csv   ${OUTPUT_DIR}/TTI_TRACE_${feature_status}/TTI_TRACE_dl.csv
