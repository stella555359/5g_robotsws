*** Settings ***
Documentation   :copyright: Nokia
...             :authors: Joanna Kutrowska-Girzycka
...             :contact: joanna.kutrowska-girzycka@nokia.com

Resource         ../../resources/airphone/5G_SW_WRO_Keywords.robot
Resource         ../../resources/airphone/wro_2/keywords/logging.robot
Resource         ../resources/Error_finder.robot

Library          ta5g_file_system
Library          ta5g_enb
Library          ta5g_tshark
Library          ta5g_throughput
Library          ta5g_testline_management
Library          ta5g_setups_and_teardowns
Library          testsuite/Wroclaw/RRM/resources/scout_report.py
Library          testsuite/Wroclaw/RRM/resources/syslog_checker.py
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T06/resources/xml_parser.py
Library          ute_wtssim  # must be imported before ta5g_iphy to avoid error
Library          ute_fsmaccess
Library          ta5g_iphy
Library          ta5g_ue_mobility
Library          taf.sbts.oam.coam.admin    WITH NAME   coam
Library          OperatingSystem
Library          BuiltIn

*** Variables ***
@{FAULT_IDS_LIST}=        6450    4383
${rdFeatureFlagBitmapLevel}=     0x58057A=0x3 #rdFeatureFlagBitmapLevel to enable feature logs in L2-PS
${rdFeatureFlagBitmap7}=         0x580582=0x3 # rdFeatureFlagBitmap7 to enable PCMD logs in L2-PS
@{SWCONFIG_FLAGS_LIST_PCMD}=         ${rdFeatureFlagBitmapLevel}    ${rdFeatureFlagBitmap7}
${TCPDUMP_FILTER}         tcp port 49140
${ARTI_USER}=    holowins
${ARTI_PASS}=    cmVmdGtuOjAxOjAwMDAwMDAwMDA6YWc5ZVlqZksxVEtDTWJoaFN6U2xwMGFWR0py
@{metrics_to_check_DL}=    nsetapx.timeOfUeSched    nsetapx.numOf1stMacPduTx
@{metrics_to_check_DL_bad}=    nsetapx.numOfBad1stMacPduTx    nsetapx.numOfBadLastMacPduTx
@{metrics_to_check_UL}=    nsetapx.timeOfUeSched    nsetapx.numOf1stMacPduTx
${sumOfMacPduRxTime}=    nsetapx.sumOfMacPduRxTime

*** Keywords ***
Prepare Test Teardown For CB014648 Feature
    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Collect Selected Debug Files    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    omit_collectors=sos_report
    Find Errors
    Run Keyword If Test Passed    Find Suspicious Logs
    Run Keyword And Ignore Error    Execute Syslog Error Filtering    ${syslog_path_WRO6}
    Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}
    Add Scout Scf Id To Test Data

Start Tshark Nsetapx
    [Arguments]    ${alias}=${default_alias}    ${port}=49140
    Start Tshark
    ...    log_filename=${alias}.pcap
    ...    alias=${alias}
    ...    eth_interface=eth3
    ...    capture_filter=${TCPDUMP_FILTER}
    ...    capture_filter=tcp port ${port}
    ...    log_dirpath=${OUTPUT_DIR}/${TEST_NAME}/nsetapx

Start Vm Ethernet Interfaces
    Start Vm Ethernet Interface    if_name=eth3:TCE             ip_with_mask=10.0.1.11/24

Update BSR Package
    Log To Console    BSR package uploading...
    Run     mkdir ${CURDIR}/BSR
    ${dllink}   Set Variable     https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnpute-rotta-local/BSR
    ${filename}    Set variable     BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
    Run     sudo wget ${dllink}/${filename} --user=${ARTI_USER} --password=${ARTI_PASS} -P ${CURDIR}/BSR
    coam.setup admin
    ${ret}     coam.Update Software      ${CURDIR}/BSR/BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
    coam.teardown admin

Set Internal Traffic Type To UE
    [Arguments]    ${ue_id}    ${pdu_id}
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal

Trigger PDU Session Modify Procedure By Adding 5QI
    [Arguments]     ${ue_id}     ${5QI}
    ${QoS_To_Add}=     Set variable if
    ...     '${5QI}'=='7'             1
    ...     '${5QI}'=='5'             2
    ...     '${5QI}'=='1'             3
    ...     '${5QI}'=='2'             4
    Modify Pdu Session       ue_id=${ue_id}   pdu_id=1    qos_to_add=${QoS_To_Add}
    Wait For Data    2

Wait For Data
    [Arguments]    ${time_seconds}=3
    Sleep    ${time_seconds}s

Start Data Traffic for UE
    [Arguments]    ${UE_ID}    ${PDU_ID}    ${QFI_ID}    ${TRF_ID}    ${DIR}    ${KBPS}
    Execute Egate Command    cmd=trf_data_start ue=${UE_ID} pdu=${PDU_ID} qfi=${QFI_ID} trf_id=${TRF_ID} dir=${DIR} kbps=${KBPS}
    Wait For Data    2

Verify UL thoughput for UE
    [Arguments]    ${UE_ID}    ${TPUT}
    Wait Until Keyword Succeeds    5x    5sec    Expected Throughput For Ue Should Be Reached    ue_id=${UE_ID}    retry=0
    ...    throughput=${TPUT}    direction=ul    selection_type=average    layer=physical    scells=0-0    margin=0.25
    Wait For Data

Verify DL thoughput for UE
    [Arguments]    ${UE_ID}    ${TPUT}
    Wait Until Keyword Succeeds    5x    5sec    Expected Throughput For Ue Should Be Reached    ue_id=${UE_ID}    retry=0
    ...    throughput=${TPUT}    direction=dl    selection_type=average    layer=physical    scells=0-0    margin=0.25

Start subscriber trace session for UE#${first_UE}-UE#${last_UE}
    FOR    ${UE}     IN RANGE   ${first_UE}    ${last_UE}+1
    ${command_prepare}=    Catenate
    ...    amf_ue_ics_param id=1 ue=${UE} object_id=${UE} location_reporting_reference_id=${UE} trace_activation=on trace_plmn=311:489
    ...    trace_ref_id=${UE} trace_rec_session_ref_id=${UE} trace_depth=medium ifaces_to_trace=Uu,NG-C,Xn-C,F1-C tce_ip=0.0.0.0
    Execute Egate Command
    ...    cmd=${command_prepare}
    Wait For Data    3
    ${command_start}=    Catenate
    ...    ng_ue_trace_start id=${UE} trace_plmn=311:489 trace_ref_id=${UE} trace_rec_session_ref_id=${UE}
    ...    ifaces_to_trace=E1,F1-C,NG-C,Uu,Xn-C trace_depth=maximum tce_ip=0.0.0.0
    Execute Egate Command
    ...    cmd=${command_start}
    Wait For Data    3
    END

Activate DTX Profile For UE
    [Arguments]    ${UE_ID}
    Execute Egate Command    cmd=ue_testmode_set_nr id=${UE_ID} testmode=bler action=activate profile_id=1
    Wait For Data    10

Configure DTX Profile
    ${command_prepare}=    Catenate
    ...    bler_testmode_nr profile_id=1 ul_bler=800,400,200,100,400,200,100,800 dl_bler=100,200,300,400,500,600,700,800
    Execute Egate Command
    ...    cmd=${command_prepare}

Stop simulate DTX for UE
    [Arguments]    ${UE_ID}
    Execute Egate Command    cmd=ue_testmode_set_nr id=${UE_ID} profile_id=1 testmode=bler action=deactivate
    Wait For Data    10

Start Ncat Listener On Port
    [Arguments]    ${port}=49140
    ${process_object}=    Start Process
    ...    ncat
    ...    -k
    ...    -l
    ...    -n
    ...    -p
    ...    ${port}
    ...    stdout=/dev/null
    ...    stderr=/dev/null
    ...    alias=NcatListener_${port}

Copy Wireshark preferences
    Copy File    ${CURDIR}/config/wireshark_preferences    /home/ute/.config/wireshark/profiles/5G/preferences

Convert Pcap File To Pdml
    [Arguments]    ${pcap_filename}
    Convert Pcap To Pdml   pcap_file=${OUTPUT_DIR}/${TEST_NAME}/nsetapx/${pcap_filename}.pcap

Validate 5QI Specific Metrics In Bad Radio Conditions
    [Arguments]    ${pcap_filename}    ${dir}=${OUTPUT_DIR}/${TEST_NAME}/nsetapx
    Wait For Data
    Convert Pcap File To Pdml    pcap_filename=${pcap_filename}
    Validate Field And Children In Xml File     xml_file=${dir}/${pcap_filename}.xml
    ...    target_field_name=nsetapx.dl5qi1SpecificMetrics_element   child_field_name=@{metrics_to_check_DL}    condition=>0
    Validate Field And Children In Xml File     xml_file=${dir}/${pcap_filename}.xml
    ...    target_field_name=nsetapx.dl5qi1SpecificMetrics_element   child_field_name=@{metrics_to_check_DL_bad}    condition=>0
    Validate Field And Children In Xml File     xml_file=${dir}/${pcap_filename}.xml
    ...    target_field_name=nsetapx.ul5qi1SpecificMetrics_element   child_field_name=@{metrics_to_check_UL}    condition=>0
    Validate Field And Children In Xml File     xml_file=${dir}/${pcap_filename}.xml
    ...    target_field_name=nsetapx.ul5qi1SpecificMetrics_element   child_field_name=${sumOfMacPduRxTime}    condition=>0

Validate 5QI Specific Metrics In Good Radio Conditions
    [Arguments]    ${pcap_filename}    ${dir}=${OUTPUT_DIR}/${TEST_NAME}/nsetapx
    Wait For Data
    Convert Pcap File To Pdml    pcap_filename=${pcap_filename}
    Validate Field And Children In Xml File     xml_file=${dir}/${pcap_filename}.xml
    ...    target_field_name=nsetapx.dl5qi1SpecificMetrics_element   child_field_name=@{metrics_to_check_DL}    condition=>0
    Validate Field And Children In Xml File     xml_file=${dir}/${pcap_filename}.xml
    ...    target_field_name=nsetapx.dl5qi1SpecificMetrics_element   child_field_name=@{metrics_to_check_DL_bad}    condition==0
    Validate Field And Children In Xml File     xml_file=${dir}/${pcap_filename}.xml
    ...    target_field_name=nsetapx.ul5qi1SpecificMetrics_element   child_field_name=@{metrics_to_check_UL}    condition=>0
    Validate Field And Children In Xml File     xml_file=${dir}/${pcap_filename}.xml
    ...    target_field_name=nsetapx.ul5qi1SpecificMetrics_element   child_field_name=${sumOfMacPduRxTime}    condition==0

Validate Lack of 5QI Specific Metrics
    [Arguments]    ${pcap_filename}    ${dir}=${OUTPUT_DIR}/${TEST_NAME}/nsetapx
    Wait For Data
    Convert Pcap File To Pdml    pcap_filename=${pcap_filename}
    Validate Lack Of Field In Xml File    xml_file=${dir}/${pcap_filename}.xml   target_field_name=nsetapx.dl5qi1SpecificMetrics_element
    Validate Lack Of Field In Xml File    xml_file=${dir}/${pcap_filename}.xml   target_field_name=nsetapx.dl5qi2SpecificMetrics_element

Start DL and UL Data Traffic for UE#${first_UE}-UE#${last_UE} on 5QI1 and 5QI2
    FOR    ${UE}     IN RANGE   ${first_UE}    ${last_UE}+1
    Start Data Traffic for UE    UE_ID=${UE}    PDU_ID=1    QFI_ID=3    TRF_ID=3    DIR=dl    KBPS=200
    Start Data Traffic for UE    UE_ID=${UE}    PDU_ID=1    QFI_ID=3    TRF_ID=4    DIR=ul    KBPS=200
    Start Data Traffic for UE    UE_ID=${UE}    PDU_ID=1    QFI_ID=4    TRF_ID=5    DIR=dl    KBPS=200
    Start Data Traffic for UE    UE_ID=${UE}    PDU_ID=1    QFI_ID=4    TRF_ID=6    DIR=ul    KBPS=200
    END

Modify PDU Session For UE#${first_UE}-UE#${last_UE} by Adding 5QI5 5QI1 and 5QI2
    FOR    ${UE}     IN RANGE   ${first_UE}    ${last_UE}+1
    Trigger PDU Session Modify Procedure By Adding 5QI    ue_id=${UE}    5QI=5
    Trigger PDU Session Modify Procedure By Adding 5QI    ue_id=${UE}    5QI=1
    Trigger PDU Session Modify Procedure By Adding 5QI    ue_id=${UE}    5QI=2
    END

Verify DL and UL throughput For UE#${first_UE}-UE#${last_UE}
    FOR    ${UE}     IN RANGE   ${first_UE}    ${last_UE}+1
    Log To Console    Verify Throughput for UE#${UE}
    Verify UL thoughput for UE    UE_ID=${UE}    TPUT=1
    Verify DL thoughput for UE    UE_ID=${UE}    TPUT=1
    END

Simulate DTX For UE#${first_UE}-UE#${last_UE}
    Configure DTX Profile
    FOR    ${UE}     IN RANGE   ${first_UE}    ${last_UE}+1
    Log To Console    Simulating DTX for UE#${UE}
    Activate DTX Profile For UE    UE_ID=${UE}
    END

Stop simulate DTX for UE#${first_UE}-UE#${last_UE}
    FOR    ${UE}     IN RANGE   ${first_UE}    ${last_UE}+1
    Stop simulate DTX for UE    UE_ID=${UE}
    END

Attach Multiple Ues And Establish PDU Session with 5QI7 for UE#${first_UE}-UE#${last_UE}
    FOR    ${UE}     IN RANGE   ${first_UE}    ${last_UE}+1
    Attach UE    ue_id=${UE}
    ...    pass_regexp=Received REGISTRATION COMPLETE from UE
    Establish PDU Session    ue_id=${UE}    pdu_id=1   gw_id=1    nwslice=1
    ...    pass_regexp=UE${UE}: Established PDU session ID=1 using PDU Gateway ID=
    Wait For Data
    Start Data Traffic for UE    UE_ID=${UE}    PDU_ID=1    QFI_ID=1    TRF_ID=1    DIR=dl    KBPS=500
    Start Data Traffic for UE    UE_ID=${UE}    PDU_ID=1    QFI_ID=1    TRF_ID=2    DIR=ul    KBPS=500
    END

Verify StartRecordingSession Count
    [Arguments]    ${count}    ${pcap_filename}    ${dir}=${OUTPUT_DIR}/${TEST_NAME}/nsetapx
    Check NSETAPX Message Count   pcap_filename=${pcap_filename}    message_type=startRecordingSession    count=${count}    dir=${dir}

Verify StopRecordingSession Count
    [Arguments]    ${count}    ${pcap_filename}    ${dir}=${OUTPUT_DIR}/${TEST_NAME}/nsetapx
    Check NSETAPX Message Count   pcap_filename=${pcap_filename}    message_type=stopRecordingSession    count=${count}    dir=${dir}


Check NSETAPX Message Count
    [Documentation]    Checks if the number of NSETAPX messages of a specific type in a PDML file
    ...                is equal to an exact value.
    ...
    ...    Arguments:
    ...    - ${pcap_filename}: The filename of pcap file.
    ...    - ${message_type}: The specific message type string to search for (e.g., "startRecordingSession").
    ...    - ${count}: The exact number of messages expected.
    ...    - ${dir}: The directory to pcap file, default: ${OUTPUT_DIR}/${TEST_NAME}/nsetapx
    [Arguments]    ${pcap_filename}    ${message_type}    ${count}    ${dir}=${OUTPUT_DIR}/${TEST_NAME}/nsetapx

    Convert Pcap File To Pdml    pcap_filename=${pcap_filename}
    ${root_element}=    Parse XML    ${dir}/${pcap_filename}.xml
    ${actual_count}=    Set Variable    0

    # Find all 'proto' elements that represent NSETAPX messages
    ${nsetapx_protos}=    Get Elements    ${root_element}    .//proto[@name="nsetapx"]

    FOR    ${proto_element}    IN    @{nsetapx_protos}
        # Within each NSETAPX proto, find the 'field' element for 'nsetapx.TraceMessage'
        ${trace_message_field}=    Get Element    ${proto_element}    ./field[@name="nsetapx.TraceMessage"]

        # Corrected IF condition: Use '${trace_message_field}' is not '${NONE}'
        IF    '${trace_message_field}' != '${NONE}'
            ${showname}=    Get Element Attribute    ${trace_message_field}    showname
            # Check if the showname contains the specified message_type
            IF    '${message_type}' in '${showname}'
                ${actual_count}=    Evaluate    ${actual_count} + 1
            END
        END
    END

    Log To Console    Found ${actual_count} messages of type "${message_type}".
    Should Be Equal As Integers    ${actual_count}    ${count}
    ...    The count of "${message_type}" messages (${actual_count}) does not match the expected count (${count}).

Wait ${x:\d+}s For ${reason}
    Sleep    ${x}s    ${reason}

Perform PDU Session Modification By Adding 5QI Mobility Robustness
    [Arguments]    ${first_UE}    ${last_UE}    ${5QI}
    ${QoS_To_Add}=     Set variable if
    ...     '${5QI}'=='6'             3
    ...     '${5QI}'=='5'             1
    ...     '${5QI}'=='1'             2
    ...     '${5QI}'=='2'             4
    FOR    ${UE}     IN RANGE   ${first_UE}    ${last_UE}+1
    Modify Pdu Session       ue_id=${UE}    pdu_id=1    qos_to_add=${QoS_To_Add}    validation=on
    Wait 2s For PDU Session Modification
    END

Validate 5QI Specific Metrics In Moderate Radio Conditions
    [Arguments]    ${pcap_filename}    ${dir}=${OUTPUT_DIR}/${TEST_NAME}/nsetapx
    Wait For Data
    Convert Pcap File To Pdml    pcap_filename=${pcap_filename}
    Validate Field And Children In Xml File     xml_file=${dir}/${pcap_filename}.xml
    ...    target_field_name=nsetapx.dl5qi1SpecificMetrics_element   child_field_name=@{metrics_to_check_DL}    condition=>0
    Validate Field And Children In Xml File     xml_file=${dir}/${pcap_filename}.xml
    ...    target_field_name=nsetapx.dl5qi1SpecificMetrics_element   child_field_name=@{metrics_to_check_DL_bad}    condition=<20
    Validate Field And Children In Xml File     xml_file=${dir}/${pcap_filename}.xml
    ...    target_field_name=nsetapx.ul5qi1SpecificMetrics_element   child_field_name=@{metrics_to_check_UL}    condition=>0
    Validate Field And Children In Xml File     xml_file=${dir}/${pcap_filename}.xml
    ...    target_field_name=nsetapx.ul5qi1SpecificMetrics_element   child_field_name=${sumOfMacPduRxTime}    condition=<500
    Validate Field And Children In Xml File     xml_file=${dir}/${pcap_filename}.xml
    ...    target_field_name=nsetapx.dl5qi2SpecificMetrics_element   child_field_name=@{metrics_to_check_DL}    condition=>0
    Validate Field And Children In Xml File     xml_file=${dir}/${pcap_filename}.xml
    ...    target_field_name=nsetapx.dl5qi2SpecificMetrics_element   child_field_name=@{metrics_to_check_DL_bad}    condition=<20
    Validate Field And Children In Xml File     xml_file=${dir}/${pcap_filename}.xml
    ...    target_field_name=nsetapx.ul5qi2SpecificMetrics_element   child_field_name=@{metrics_to_check_UL}    condition=>0
    Validate Field And Children In Xml File     xml_file=${dir}/${pcap_filename}.xml
    ...    target_field_name=nsetapx.ul5qi2SpecificMetrics_element   child_field_name=${sumOfMacPduRxTime}    condition=<500

Setup PDU Session for UE#${first_UE}-UE#${last_UE}
    FOR    ${UE}     IN RANGE   ${first_UE}    ${last_UE}+1
    Establish Pdu Session    ue_id=${UE}    pdu_id=1    nwslice=1    gw_id=${UE}    check_timestamps=${False}
    Wait For Data
    END
