*** Settings ***
Documentation
...              :author: Mateusz Kuropka
...              :contact: mateusz.kuropka@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     taf/ul/ettf/main.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/traffic.robot
Resource     ../keywords/L3_Call.robot
Resource    ../keywords/tshark_verifying.robot
Resource     ta_messaging/flow.robot
Library      ta5g_tshark
Library      Process
Library      ta5g_ue_mobility
Library      taf.ul.ettf.setups
Library      ta5g_testline_management
Library      ta5g_iphy
Library      taf.ul.ettf.throughput.ue
Library      ta5g_throughput
Library      ute_wtssim
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/testline_preparation/testline_preparation.robot
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/tools/daily_activities/resources/daily_activities_keywords.py
Library      taf.sbts.oam.coam.admin   WITH NAME    coam
Variables    logging_policy.py
Library      ./resource.py
Library      taf.collectors.l2stream3     WITH NAME  tcl
Library      taf.collectors.core          WITH NAME  tcc
Library      taf.converters.eventdecoder  WITH NAME  tce

*** Variables ***
${artifactory_location}=    https://artifactory-espoo1.ext.net.nokia.com/artifactory/list/mnpute-rotta-local/holowins/
${BSR_FILENAME}=    BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001.zip
${BSR_FILEPATH}=    ${artifactory_location}/${BSR_FILENAME}
${ARTI_USER}=    holowins
${ARTI_PASS}=    cmVmdGtuOjAxOjAwMDAwMDAwMDA6YWc5ZVlqZksxVEtDTWJoaFN6U2xwMGFWR0py
${BSR_TARGET_FILEPATH}=    ${CURDIR}/config

*** Keywords ***
Download TTI Trace Decoder
    ${admin_alias}=  Wait Until Keyword Succeeds  10x  60s  coam.Connect To
    ${gnb_sw}=    Check Software Version    ${admin_alias}
    ${gnb_sw}=    testline_preparation.Fix Branch    ${gnb_sw}
    Prepare Main Vm Tools    ${gnb_sw}


Install BSR package
    Run Process  wget --user ${ARTI_USER} --password ${ARTI_PASS} -P ${BSR_TARGET_FILEPATH} ${BSR_FILEPATH}    shell=yes
    coam.setup admin
    ${ret}     coam.Update Software      ${BSR_TARGET_FILEPATH}/${BSR_FILENAME}
    coam.teardown admin


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


Start TTI trace collection
    ${configurations}=  tcc.Load Configurations    ${CURDIR}/tti_trace_collectors.yaml
    tcc.Create Collectors    names=l2stream3    configurations=${configurations['collectors']}
    tcl.Set Suite Alias     alias=l2stream3
    tcc.Setup Collectors    names=l2stream3
    tcc.Start Collectors    names=l2stream3
    Log to console    ${\n}TTI traces collecting started


Stop TTI trace collection
    Log to console    Stopping TTI traces collecting
    tcc.Stop Collectors    names=l2stream3
    tcc.Collect Collectors    names=l2stream3
    tcc.Teardown Collectors    names=l2stream3


Modify SCTP Timeout
    Run    sudo sysctl -w net.sctp.sack_timeout=10
    Run    sudo sysctl -w net.sctp.rto_min=200
    Run    sudo sysctl -w net.sctp.rto_initial=200
    Run    sudo sysctl -w net.sctp.rto_max=800
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.200.1 'sysctl -w net.sctp.sack_timeout=10'
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.200.1 'sysctl -w net.sctp.rto_min=200'
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.200.1 'sysctl -w net.sctp.rto_initial=200'
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.200.1 'sysctl -w net.sctp.rto_max=800'


Trigger intra-gNB intra-frequency handover based on A3 event
    Log to console    Trigger intra-gNB intra-freq handover
    execute egate command    cmd=ue_measurement_send_nr id=1 meas_id=2 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=51 nrsrp_nr=100 nrsrq_nr=100

