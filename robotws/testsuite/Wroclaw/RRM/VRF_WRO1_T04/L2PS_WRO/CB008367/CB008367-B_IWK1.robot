*** Settings ***
Documentation
...    copyright: Nokia

Force Tags    CLOUD_5G_I_LO_AP_LO   VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    CRT    SBTS00    RAN_5G
...   RAN_5G_TDD

Resource     ../resources/5G_SW_WRO_Keywords.robot
Resource    resources/CB008367-B_keywords.robot
Resource    ../CB007813/connect.robot
Library    ../resources/Python/webem_alarms.py
Library    CB008367.py
Library    OperatingSystem
Library     taf.collectors.tcpdump          WITH NAME    tcpdump
Library     taf.collectors.l2stream3        WITH NAME    tcl
Library     taf.collectors.core             WITH NAME    tcc
Library     taf.converters.eventdecoder     WITH NAME    tce
Library     taf.sbts.oam.coam.admin         WITH NAME    coam
Library     taf.transport.ssh               WITH NAME    ssh
Library    ../CB007813/CB007813-B_keywords.py
Library    Collections
Resource     ../resources/configuration_id.robot

Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/iphy_AEQE_IWK1.xml
    ...                        swconfig_flags_list=@{SWCONFIG_FLAGS}
    ...        AND             Start Default Logging
    ...        AND             Find Scfc And Fix And Send Full Commissioning
    ...                        scfc_filename=full_CB008367_IWK1_90_MHz_Large_Small_PWS_BWP.xml
    ...        AND             Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/basic_setup_IWK1.cfg

Suite Teardown   Run Keywords    Print Active Alarms
    ...    AND    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
@{SWCONFIG_FLAGS}=      0x580678=6      0x5808FF=2
# 0x580001 - Disable HARQ incremental redundancy DL      0x580678 - maximum number of NACKs at GNB for a HARQ process
# 0x580900-5 and 0x5808FF=1 - flags related to CB008367 events visibility in TTI Trace

${LOCAL_MOID}=         PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
${search_space_id_large} =          8
${search_space_id_small} =          13
${search_space_id_pws} =            18
${pdcch_start_symbol_large} =       1
${pdcch_start_symbol_small} =       17
${PDSCH_SUCC_ANY_64TBL_MCS_30} =    M55300C02030
${PDSCH_UNSUCC_64TBL_MCS_30} =      M55300C03030
${PDSCH_INIRE_VOL_64TBL_MCS30} =    M55304C02030
${PDSCH_RANK2_64TBL_MCS_30} =       M55301C01030

*** Test Cases ***
CB008367-B_IWK1_Adaptive_retransmission_enabled_with_dynamic_PDCCH_symbols_in_multi-BWPs
    Attach UEs with Large And Small BWP Capability
    Attach UEs with PWS BWP Capability
    Set PDSCH decoding BLER profile And CQI value
    Start Dl and UL Data Traffic For Small And Large BWP UEs
    Start Dl and UL Data Traffic For PWS BWP UEs
    Collect Tti Trace For 1 Seconds with CB008367_before_BLER
    Enable DL BLER and CQI test modes
    Collect Tti Trace For 1 Seconds with CB008367_BLER
    Verify Adaptive Retransmission Counters
    Disable DL BLER and CQI test modes
    Collect Tti Trace For 1 Seconds with CB008367_after_BLER
    CB008367.Check Avg Num Of PDCCH Symbols    csv_path=${OUTPUT_DIR}/TTI_TRACE_CB008367_before_BLER/
    ...    filename=TTI_TRACE_dl.csv
    ...    search_space_id=${search_space_id_pws}
    ...    num_of_symbols=2
    CB008367.Check Avg Num Of PDCCH Symbols    csv_path=${OUTPUT_DIR}/TTI_TRACE_CB008367_BLER/
    ...    filename=TTI_TRACE_dl.csv
    ...    search_space_id=${search_space_id_pws}
    ...    num_of_symbols=2
    CB008367.Check Avg Num Of PDCCH Symbols    csv_path=${OUTPUT_DIR}/TTI_TRACE_CB008367_after_BLER/
    ...    filename=TTI_TRACE_dl.csv
    ...    search_space_id=${search_space_id_pws}
    ...    num_of_symbols=2
    [Teardown]    Send Configuration ID To Scout

*** Keywords ***
Set PDSCH decoding BLER profile And CQI value
    Execute Egate Command       cmd=ue_testmode_decode_muxphychan decode_mux_phy_chan=decode_PDSCH
    Execute Egate Command       cmd=bler_testmode_nr profile_id=1 dl_bler=100,100,100,50
    Execute Egate Command       cmd=csi_override_testmode_nr profile_id=1 cqi=7 ri=1

Enable DL BLER and CQI test modes
	FOR    ${id}    IN RANGE    1    3
        Execute Egate Command       cmd=ue_testmode_set_nr id=${id} testmode=csi_override profile_id=1 action=activate

        Execute Egate Command       cmd=ue_testmode_set_nr id=${id} testmode=bler profile_id=1 action=activate
    END
    Execute Egate Command       cmd=ue_testmode_set_nr id=15 testmode=csi_override profile_id=1 action=activate

    Execute Egate Command       cmd=ue_testmode_set_nr id=15 testmode=bler profile_id=1 action=activate

    Sleep   30s

Disable DL BLER and CQI test modes
	FOR    ${id}    IN RANGE    1    3
        Execute Egate Command       cmd=ue_testmode_set_nr id=${id} testmode=csi_override profile_id=1 action=deactivate

        Execute Egate Command       cmd=ue_testmode_set_nr id=${id} testmode=bler profile_id=1 action=deactivate
    END
    Execute Egate Command       cmd=ue_testmode_set_nr id=15 testmode=csi_override profile_id=1 action=deactivate

    Execute Egate Command       cmd=ue_testmode_set_nr id=15 testmode=bler profile_id=1 action=deactivate

    Sleep   30s

Verify Adaptive Retransmission Counters
    Wait For Next Full Pm Interval
    ${pm_counters_filepath}=    Get Latest Unpacked Raw Pm Counters File

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PDSCH_SUCC_ANY_64TBL_MCS_30}
    ...    value=${2000}
    ...    local_moid=${LOCAL_MOID}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PDSCH_UNSUCC_64TBL_MCS_30}
    ...    value=${3}
    ...    local_moid=${LOCAL_MOID}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PDSCH_INIRE_VOL_64TBL_MCS30}
    ...    value=${1500000}
    ...    local_moid=${LOCAL_MOID}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PDSCH_RANK2_64TBL_MCS_30}
    ...    value=${10000}
    ...    local_moid=${LOCAL_MOID}
    ...    filepath=${pm_counters_filepath}

Start Dl and UL Data Traffic For Small And Large BWP UEs
	FOR    ${id}    IN RANGE    1    20
        Start 4mbs Data Traffic In DL And 2mbs In UL    ue_id=${id}
    END
    Sleep    30s

Start Dl and UL Data Traffic For PWS BWP UEs
    FOR    ${id}    IN RANGE    20    72
        Start Low Data Traffic For UE And Check Switch To PS BWP    ue_id=${id}
    END
    Sleep    30s

Attach UEs with Large And Small BWP Capability
    FOR    ${id}    IN RANGE    1    20
        Set Internal Traffic Type To UE    ue_id=${id}
        Attach Ue    ue_id=${id}
        Establish Pdu Session    ue_id=${id}     pdu_id=1     gw_id=${id}
    END

Attach UEs with PWS BWP Capability
    FOR    ${id}    IN RANGE    20    72
        Set Internal Traffic Type To UE    ue_id=${id}
        Attach Ue    ue_id=${id}
        Establish Pdu Session    ue_id=${id}     pdu_id=1     gw_id=${id}
    END

Set Internal Traffic Type To UE
    [Arguments]    ${ue_id}
    Execute Egate Command   cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal

Start 4mbs Data Traffic In DL And 2mbs In UL
    [Arguments]   ${ue_id}
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=1 dir=dl mbps=4 trf_id=1
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=1 dir=ul mbps=2 trf_id=1

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

