*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Marcin Kotula
...              :contact: marcin.kotula@nokia.com

Resource    resources/CB008367-B_keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/resources/common_keywords.robot

Library     CB008367.py
Library     taf.collectors.tcpdump          WITH NAME    tcpdump
Library     taf.collectors.l2stream3        WITH NAME    tcl
Library     taf.collectors.core             WITH NAME    tcc
Library     taf.converters.eventdecoder     WITH NAME    tce


*** Variables ***
${iphy_CB008367_B5}               ${CURDIR}/config/iphy_AEQE_A_B5.xml
${scf_CB008367_B5}                ${CURDIR}/config/SBTS00/full_CB008367_A_B5_60_MHz_Large_PWS_BWP.xml
${cfg_CB008367_B5}                ${CURDIR}/config/basic_setup_A_B5.cfg
&{SWCONFIG_FLAGS_CB008367}        0x5808FF=2
# 0x580900-5 and 0x5808FF=1 - flags related to CB008367 events visibility in TTI Trace

${search_space_id_large} =          8
${search_space_id_pws} =            13

*** Keywords ***
CB008367-A_B5_control_UEs_switching_from_large-BWP_to_PS-BWP
    Attach UEs with Large And PWS BWP Capability
    Start Dl and UL Data Traffic For All UE
    Collect Tti Trace For 1 Seconds with CB008367_enabled
    CB008367.Check Avg Num Of PDCCH Symbols    csv_path=${OUTPUT_DIR}/TTI_TRACE_CB008367_enabled/
    ...    filename=TTI_TRACE_dl.csv
    ...    search_space_id=${search_space_id_large}
    ...    num_of_symbols=2
    CB008367.Check Avg Num Of PDCCH Symbols    csv_path=${OUTPUT_DIR}/TTI_TRACE_CB008367_enabled/
    ...    filename=TTI_TRACE_dl.csv
    ...    search_space_id=${search_space_id_pws}
    ...    num_of_symbols=1
    Switch UEs To PS BWP
    Collect Tti Trace For 1 Seconds with UEs_switch
    CB008367.Check Avg Num Of PDCCH Symbols    csv_path=${OUTPUT_DIR}/TTI_TRACE_UEs_switch/
    ...    filename=TTI_TRACE_dl.csv
    ...    search_space_id=${search_space_id_large}
    ...    num_of_symbols=1
    CB008367.Check Avg Num Of PDCCH Symbols    csv_path=${OUTPUT_DIR}/TTI_TRACE_UEs_switch/
    ...    filename=TTI_TRACE_dl.csv
    ...    search_space_id=${search_space_id_pws}
    ...    num_of_symbols=2


Switch UEs To PS BWP
    FOR    ${id}    IN RANGE    3    32
        Start Low Data Traffic For UE And Check Switch To PS BWP    ue_id=${id}
    END
    Sleep    30s

Start Dl and UL Data Traffic For All UE
    FOR    ${id}    IN RANGE    1    32
        Start 2mbs Data Traffic In DL And 2mbs In UL    ue_id=${id}
    END
    FOR    ${id}    IN RANGE    32    63
        Start Low Data Traffic For UE And Check Switch To PS BWP    ue_id=${id}
    END
    Sleep    30s

Attach UEs with Large And PWS BWP Capability
    FOR    ${id}    IN RANGE    1    63
        Set Internal Traffic Type To UE    ue_id=${id}    pdu_id=1
        Attach Ue    ue_id=${id}
        Establish Pdu Session    ue_id=${id}     pdu_id=1     gw_id=${id}
    END


Start 2mbs Data Traffic In DL And 2mbs In UL
    [Arguments]   ${ue_id}
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=1 dir=dl mbps=2 trf_id=1
    ...    pass_regexp=UE${ue_id}: Started Downlink Internal traffic Receiver on Ue:${ue_id} Pdu:1 Qfi:1 TrfId:1
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
    tce.Convert
    ...  name=ttitrace_converter

    Move File    ${OUTPUT_DIR}/l2stream3/tcpdump/tcpdump.pcap    ${OUTPUT_DIR}/TTI_TRACE_${feature_status}/tcpdump.pcap
    Move File    ${OUTPUT_DIR}/TTI_TRACE_dl*.csv   ${OUTPUT_DIR}/TTI_TRACE_${feature_status}/TTI_TRACE_dl.csv
    Move File    ${OUTPUT_DIR}/TTI_TRACE_ul*.csv   ${OUTPUT_DIR}/TTI_TRACE_${feature_status}/TTI_TRACE_ul.csv
