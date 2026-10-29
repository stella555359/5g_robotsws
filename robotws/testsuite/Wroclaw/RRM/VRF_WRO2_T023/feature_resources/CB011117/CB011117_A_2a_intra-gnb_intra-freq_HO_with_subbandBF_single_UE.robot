*** Settings ***
Documentation    Keywords for the CB011117

Library     Process
Library     OperatingSystem
Library     ta5g_tshark
Library     ta5g_ue_mobility
Library     ./resources/resource.py
Library     taf.sbts.oam.coam.admin   WITH NAME    coam
Library     taf.collectors.l2stream3     WITH NAME  tcl
Library     taf.collectors.core          WITH NAME  tcc
Library     taf.converters.eventdecoder  WITH NAME  tce
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T023/resources/airphone/L3_call.robot


*** Variables ***
${artifactory_location}=    https://artifactory-espoo1.ext.net.nokia.com/artifactory/list/mnpute-rotta-local/holowins/
${BSR_FILENAME}=    BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001.zip
${BSR_FILEPATH}=    ${artifactory_location}/${BSR_FILENAME}
${ARTI_USER}=    holowins
${ARTI_PASS}=    cmVmdGtuOjAxOjAwMDAwMDAwMDA6YWc5ZVlqZksxVEtDTWJoaFN6U2xwMGFWR0py
${BSR_TARGET_FILEPATH}=    ${CURDIR}/config


*** Keywords ***
TC__CB011117_A_2a_intra-gnb_intra-freq_HO_with_subbandBF_single_UE
        Perform UE Attach And Start Data Traffic Then Trigger Event A3 And Setup SB Beamforming    alias=SUBBAND

Perform UE Attach And Start Data Traffic Then Trigger Event A3 And Setup SB Beamforming
    [Arguments]          ${alias}
    Start Tcpdump On Remote Interface    log_filename_prefix=${alias}    alias=${alias}
    Attach UE And Establish PDU Session    ue_id=1    cell_id=1   enb_id=2    pdu_id=1    gw_id=1
    Activate Srs Beam Test Mode
    Start Specific Data DL Traffic    ue_id=1    pdu_id=1  mbps_per_trf_id=150    first_trf_id=1    last_trf_id=6
    Start TTI trace collection
    Sleep    3
    Trigger intra-gNB intra-frequency handover based on A3 event
    Sleep    3
    Deregister UE    ue_id=1
    Stop TTI trace collection
    Convert TTI trace from pcap    format=excelCsv    directory_name=${alias}
    Perform TTI Checks    alias=${alias}

Perform TTI Checks
    [Arguments]    ${alias}
    Log To Console     Start Check beamType in TTI Trace
    ${have_subband}    Contain Subband    file_path=${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/${alias}/output_dl.csv
    Should Be True    ${have_subband}

Install BSR package
    Run Process  wget --user ${ARTI_USER} --password ${ARTI_PASS} -P ${BSR_TARGET_FILEPATH} ${BSR_FILEPATH}    shell=yes
    coam.Setup Admin
    ${ret}     coam.Update Software      ${BSR_TARGET_FILEPATH}/${BSR_FILENAME}
    coam.teardown admin

Modify SCTP Timeout
    Run    sudo sysctl -w net.sctp.sack_timeout=10
    Run    sudo sysctl -w net.sctp.rto_min=200
    Run    sudo sysctl -w net.sctp.rto_initial=200
    Run    sudo sysctl -w net.sctp.rto_max=800
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.200.1 'sysctl -w net.sctp.sack_timeout=10'
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.200.1 'sysctl -w net.sctp.rto_min=200'
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.200.1 'sysctl -w net.sctp.rto_initial=200'
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.200.1 'sysctl -w net.sctp.rto_max=800'

Activate Srs Beam Test Mode
    Execute Egate Command    cmd=ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=SRS
    ...    multi_path_config=true num_of_nlos_paths=1 azimuth=0 zenith=0 srs_transmit_power_per_port=-250,-250,-250,-250
    Sleep    1
    Execute Egate Command    cmd=ue_testmode_set_nr id=1 testmode=ul_mimo_srs_beam_pos action=activate profile_id=1
    Sleep    1

Start Specific Data DL Traffic
    [Arguments]    ${ue_id}    ${pdu_id}    ${mbps_per_trf_id}=175    ${first_trf_id}=1    ${last_trf_id}=6
    FOR    ${INDEX}  IN RANGE    ${first_trf_id}   ${last_trf_id}+1
       Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=${INDEX} dir=dl mbps=${mbps_per_trf_id}
       Sleep    1
    END

Start TTI trace collection
    ${configurations}=  tcc.Load Configurations    ${CURDIR}/resources/tti_trace_collectors.yaml
    tcc.Create Collectors    names=l2stream3    configurations=${configurations['collectors']}
    tcl.Set Suite Alias     alias=l2stream3
    tcc.Setup Collectors    names=l2stream3
    tcc.Start Collectors    names=l2stream3
    Log To Console    ${\n}TTI traces collecting started

Stop TTI trace collection
    Log To Console    Stopping TTI traces collecting
    tcc.Stop Collectors    names=l2stream3
    tcc.Collect Collectors    names=l2stream3
    tcc.Teardown Collectors    names=l2stream3

Trigger intra-gNB intra-frequency handover based on A3 event
    Log To Console    Trigger intra-gNB intra-freq handover
    Execute Egate Command    cmd=ue_measurement_send_nr id=1 meas_id=2 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=51 nrsrp_nr=100 nrsrq_nr=100

Convert TTI trace from pcap
    [Arguments]  ${format}    ${directory_name}
    Log to console    Converting TTI traces to ${format}
    tce.Create eventDecoder Converter
    ...  name=ttitrace_converter
    ...  input_file_path=${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/l2stream3/tcpdump/tcpdump.pcap
    ...  output_file_format=${format}
    ...  output_file_path=${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/output
    tce.Convert
    ...  name=ttitrace_converter
    Remove Directory  ${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/${directory_name}/    recursive=True
    Move Files	    ${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/output*     ${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/${directory_name}/
    Move Directory	${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/l2stream3/  ${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/${directory_name}/
