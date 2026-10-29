*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
    ...    CLOUD_5G_I_LO_AP_LO

Documentation    :copyright: Nokia
...              :authors: Marcin Holowinski
...              :contact: Marcin.Holowinski@nokia.com


Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/traffic.robot
Resource     ../keywords/L3_Call.robot
Resource    ../keywords/tshark_verifying.robot
Resource     ta_messaging/flow.robot
Library      ta5g_tshark
Library      ta5g_enb
Library      Process
Library      ta5g_ue_mobility
Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_throughput
Library      ute_wtssim
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/testline_preparation/testline_preparation.robot
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/tools/daily_activities/resources/daily_activities_keywords.py
Library      taf.sbts.oam.coam.admin   WITH NAME    coam
Library      ./resource.py


Library     taf.collectors.l2stream3     WITH NAME  tcl
Library     taf.collectors.core          WITH NAME  tcc
Library     taf.converters.eventdecoder  WITH NAME  tce


Suite Setup    Run Keywords    Remove And Replace File    new_file=${new_file}    target_path=${target_path}
...            AND             Install BSR package
...            AND             Backup And Modify Swconfig File    parameters_list=@{SWCONFIG_FLAGS_LIST}
...            AND             Update And Put Iphy Xml    input_filepath=${CURDIR}/config/${IPHY}
...            AND             Find Scfc And Fix And Send Full Commissioning    scfc_filename=${scfc}
...            AND             Modify SCTP Timeout
...            AND             Reach Onair    lua_cfg=${BASIC_SETUP}


Suite Teardown    Run Keywords    Stop Default Logging
...            AND                stop_tcpdump_on_remote_interface
...            AND                Stop Default Processes And Gather Logs And Compress Logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Variables ***
${IPHY}=              airphone_aqql_sub_beamforming.xml
${scfc}=              full_scfc_cb011117_E_actUnlimitedDataRateDl_false.xml
${BASIC_SETUP}=       ${CURDIR}/config/wts_config_ASIL_ABIO_TDD_AQQL_eCPRI_cmwv_SANSA_FS_1S_1CC_UEs.lua
@{SWCONFIG_FLAGS_LIST}=        ${rdActNoAddDlDmrsSwitch}    ${rdComponentBitMapProfile}
${rdActNoAddDlDmrsSwitch}=        0x59026A=1   # rdActNoAddDlDmrsSwitch
${rdComponentBitMapProfile}=        0x5808FF=2  # Activate profile: 1 - All events in tti
${artifactory_location}=    https://artifactory-espoo1.ext.net.nokia.com/artifactory/list/mnpute-rotta-local/holowins
${BSR_FILENAME}=    BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001.zip
${BSR_FILEPATH}=    ${artifactory_location}/${BSR_FILENAME}
${ARTI_USER}=    holowins
${ARTI_PASS}=    cmVmdGtuOjAxOjAwMDAwMDAwMDA6YWc5ZVlqZksxVEtDTWJoaFN6U2xwMGFWR0py
${BSR_TARGET_FILEPATH}=    ${CURDIR}/config/
${new_file}=          ${CURDIR}/config/packet_iphy.lua
${target_path}=       /home/ute/.local/lib/wireshark/plugins/packet_iphy.lua

*** Test Cases ***
CB011117_E#2_unlimited_DL_data_rate_for_subbandBF_one_DMRS_type2
    [Documentation]   This case will verify peak throughput is increased according when unlimited data rate is enabled.
    ...               0x59026A=1  rdActNoAddDlDmrsSwitch
    ...               actUnlimitedDataRateDl flase vs true
    ...               actPdcchSharingWithPdsch false, dlDmrsType typ1

    ${max_tput_before}=    Perform UE Attach Then Start Max Traffic And Setup SB Beamforming And Get Throughput Value    alias=unlimited_false
    Activate actUnlimitedDataRateDl
    ${max_tput_after}=    Perform UE Attach Then Start Max Traffic And Setup SB Beamforming And Get Throughput Value    alias=unlimited_true
    Should Be True    ${max_tput_after} > ${max_tput_before}
    [Teardown]    Run Keywords    Add Scout Data Info To Testcase

*** Keywords ***
Download TTI Trace Decoder
    ${admin_alias}=  Wait Until Keyword Succeeds  10x  60s  coam.Connect To
    ${gnb_sw}=    Check Software Version    ${admin_alias}
    ${gnb_sw}=    testline_preparation.Fix Bran ch    ${gnb_sw}
    Prepare Main Vm Tools    ${gnb_sw}

Perform UE Attach Then Start Max Traffic And Setup SB Beamforming And Get Throughput Value
    [Arguments]          ${alias}
    start_tcpdump_on_remote_interface    log_filename_prefix=${alias}    alias=${alias}
    Attach UE And Establish PDU Session    ue_id=1    cell_id=1   enb_id=2    pdu_id=1    gw_id=1
    Activate Srs Beam Test Mode
    Start Specific Data DL Traffic    ue_id=1    pdu_id=1  mbps_per_trf_id=150    first_trf_id=1    last_trf_id=6
    Start TTI trace collection
    Sleep    5    Traffic to stabilize
    ${avg_tput}=    Get Max Data Traffic For Given Cc    ue_id=1   cc=0   direction=dl    unit=Mbps
    Log To Console    ${avg_tput}
    ${packet_filter}    Set Variable If	   "${alias}"=="unlimited_false"
    ...    itf_l2_ps_pdsch_PdschConfig.maxDataRateDl == 104330
    ...    itf_l2_ps_pdsch_PdschConfig.maxDataRateDl == 4294967295
    Verify Tshark
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
    ...    pass_criteria=>=1
    ...    pcap_file_path=${OUTPUTDIR}/${alias}.pcap
    [Teardown]    run keywords    Deregister UE    ue_id=1
    ...    AND    Stop TTI trace collection
    ...    AND    Convert TTI trace from pcap  format=excelCsv  directory_name=${alias}
    ...    AND    Perform TTI Checks    alias=${alias}
    [Return]    ${avg_tput}

Perform TTI Checks
    [Documentation]    When actUnlimitedDataRateDl is false then gNB downgrade TBS size in use so downgradedTbSize should be bigger than tbSize in use
    ...    When actUnlimitedDataRateDl is true then tbSize is same as downgradedTbSize (downgradedTbSize is max possible to be used in theory)
    [Arguments]    ${alias}
    ${downgradedTbSize}    get_max_DlBufBasedDowngradedTbSize    file_path=${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/${alias}/output_dl.csv
    ${tbSize}    get_max_TbSize    file_path=${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/${alias}/output_dl.csv
    Run Keyword If    "${alias}"=="unlimited_false"
    ...    Should Be True    ${downgradedTbSize} > ${tbSize}
    Run Keyword If    "${alias}"=="unlimited_true"
    ...    Should Be True    ${downgradedTbSize} == ${tbSize}

Install BSR package
    Run Process  wget --user ${ARTI_USER} --password ${ARTI_PASS} -P ${BSR_TARGET_FILEPATH} ${BSR_FILEPATH}    shell=yes
    coam.setup admin
    ${ret}     coam.Update Software      ${BSR_TARGET_FILEPATH}/${BSR_FILENAME}
    coam.teardown admin

Verify That Throughput Is Reached
    [Arguments]    ${ue_id}    ${expected_throughput}    ${num_of_scells}=0    ${direction}=dl
    ${num_of_cells}=    Evaluate    int(${num_of_scells}) + int(1)
    Assert That UE Throughput    ue_id=${ue_id}
            With Direction    ${direction}
            With Layer        physical
            With SCell        0-${num_of_scells}
        FOR    ${cell_index}    IN RANGE    0    ${num_of_cells}
            Is Reached            parameter=CellIndex-${cell_index}    expected_throughput=${expected_throughput}
        END
    Finalize

Activate Srs Beam Test Mode
    Execute Egate Command    cmd=ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=SRS
    ...    multi_path_config=true num_of_nlos_paths=1 azimuth=0 zenith=0 srs_transmit_power_per_port=-250,-250,-250,-250
    Sleep    1
    Execute Egate Command    cmd=ue_testmode_set_nr id=1 testmode=ul_mimo_srs_beam_pos action=activate profile_id=1
    Sleep    1

Start Specific Data DL Traffic
    [Arguments]    ${ue_id}    ${pdu_id}    ${qfi}=1    ${mbps_per_trf_id}=100    ${first_trf_id}=1    ${last_trf_id}=8
    FOR    ${INDEX}  IN RANGE    ${first_trf_id}   ${last_trf_id}+1
       Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} trf_id=${INDEX} dir=dl mbps=${mbps_per_trf_id}
       Sleep    1
    END

Activate actUnlimitedDataRateDl
    Find Scfc and Send Delta Commissioning    scfc_filename=delta_actUnlimitedDataRateDl_true.json


Collect TTI Traces during ${duration} seconds and save to directory ${directory_name}
    ${parent_directory}  Set variable  ${directory_name}
    Set Test Variable  ${parent_directory}
    Start TTI trace collection
    Log to console    Collecting duration is ${duration}
    Sleep  ${duration}
    Stop TTI trace collection
    Convert TTI trace from pcap  format=excelCsv  directory_name=${directory_name}


Convert TTI trace from pcap
    [Arguments]  ${format}  ${directory_name}
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

Remove And Replace File
    [Arguments]    ${new_file}    ${target_path}
    Log  \n==== Replace file to solve the problem with dissecting nr-rrc packets with ute-wireshark 4.4.7 ====  console=True
    # Ensure the new file exists
    File Should Exist    ${new_file}

    # Remove the target file if it exists
    Run Keyword And Ignore Error    Remove File    ${target_path}

    # Copy the new file to the target location
    Copy File    ${new_file}    ${target_path}
