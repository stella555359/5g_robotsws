*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Marcin Kotula
...              :contact: marcin.kotula@nokia.com

Resource    resources/CB008367-A_keywords.robot

Library    CB008367.py
Library    taf.collectors.l2stream3  WITH NAME  tcl
Library    taf.collectors.core       WITH NAME  tcc
Library    taf.converters.eventdecoder  WITH NAME  tce

*** Variables ***
${iphy_CB008367}               ${CURDIR}/config/iphy_A_B2_AEQE.xml
${scf_CB008367}                ${CURDIR}/config/SBTS00/full_CB008367_A_B2.xml
${cfg_CB008367}                ${CURDIR}/config/basic_setup_A_B2_32UE.lua
&{SWCONFIG_FLAGS_CB008367}     0x5808FF=2

${search_space_id_large}              8
${search_space_id_small}              13
${ues_in_large_bwp_counter}           M55139C02502
${ues_in_small_bwp_counter}           M55139C02501

*** Keywords ***
CB008367-A_B2_1UE_tput_large-BWP_and_multi-UE_tput_small-BWP
    Wait For Next Full Pm Interval
    Attach And Pdu Session For Ues
    ...    ues=${32}
    ...    pass_regex=BandwidthpartIndicator: 1

    Start 1 Mbps Uplink Traffic For UEs 1-32
    Run 9Mbps DL Traffic For Small BWP UEs
    Run 64Mbps DL Traffic For Large BWP UEs
    Display Actual Traffic For UEs 1-32
    Sleep    5s
    Start Collecting TTI trace
    Sleep    1s
    Stop Collecting TTI trace
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Raw Pm Counters File

#   Verification of UE's connected to Small BWP
    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=${ues_in_small_bwp_counter}
    ...    value=24
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    filepath=${PM_COUNTERS}

#   Verification of UE's connected to Large BWP
    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=${ues_in_large_bwp_counter}
    ...    value=8
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    filepath=${PM_COUNTERS}
    Convert Collected TTI trace from pcap to excelCsv
    CB008367.Check Pdsch Correctness For Large And Small A B2    csv_path=${OUTPUT_DIR}/${SUITENAME}/${TESTNAME}/
    ...    filename=output_dl.csv
    ...    search_space_id_large=${search_space_id_large}
    ...    search_space_id_small=${search_space_id_small}
    ...    pdcch_start_symbol_large=1
    ...    pdcch_start_symbol_small=17
    CB008367.Check Pdsch Correctness For Large And Small A B2    csv_path=${OUTPUT_DIR}/${SUITENAME}/${TESTNAME}/
    ...    filename=output_dl.csv
    ...    search_space_id_large=${search_space_id_large}
    ...    search_space_id_small=${search_space_id_small}
    ...    pdcch_start_symbol_large=17
    ...    pdcch_start_symbol_small=17

    Deregister 32 UEs

Start Collecting TTI trace
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

Stop Collecting TTI trace
    tcc.Stop collectors
    ...  names=l2stream3
    tcc.Collect collectors
    ...  names=l2stream3
    tcc.Teardown collectors
    ...  names=l2stream3

Convert Collected TTI trace from pcap to excelCsv
    tce.Create eventDecoder converter
    ...  name=ttitrace_converter
    ...  input_file_path=${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/l2stream3/tcpdump/tcpdump.pcap
    ...  output_file_format=excelCsv
    ...  output_file_path=${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/output
    tce.Convert
    ...  name=ttitrace_converter
