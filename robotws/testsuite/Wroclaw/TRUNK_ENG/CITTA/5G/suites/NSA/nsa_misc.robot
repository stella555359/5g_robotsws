*** Settings ***
Documentation
...    Collection of unrelated tests that uses same configuration, in NSA Mode.
...
...    Suite verifies:
...    - Automatic Neighbour Relation (ANR) mechanism for
...    5G Non-Standalone Architecture (NSA) deployment for Intra Frequency, inter-gNB handover
...    - NSA Intra frequency handover procedures, after the runtime creation of
...    5G adjacencies configuration using the new object model
...    - if TTI trace decoder is able to decode TTI trace file into json and
...    legacyCsv formats
...
...    Subfeatures covered: 5GC001296-B, CB006030-A and CNI67972 5G TTI Trace Decoder

Metadata    branch    ${ENB_BRANCH}
Metadata    build    ${ENB_BUILD}
Metadata    topology    CLOUD_5G_I_LO_AP_LO
Metadata    variant    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC

Force Tags    OPTION_RELATED_ARTIFACTS_5G    TOOLS_PROFILE_AP_WTS    PY310    RF50

Resource    ../../resources/main_resources.robot

# -- extra resources --
Library     ta5g_admin_operations
Variables    ${RESOURCES}/messages_definition.py
Library    ${RESOURCES}/tti_traces_decoder.py

# -- setup/teardown --
Suite Setup    RUN KEYWORDS    Prepare Testing Environment
...    AND    Start Mandatory Logging
...    AND    Backup BTS Configuration Files
...    AND    Get Active BTS Alarms
...    AND    Test suite preconditions

Suite Teardown  RUN KEYWORDS
...    Get Active BTS Alarms    AND
...    Collect Mandatory Logs    AND
...    Cleanup Testing Environment

*** Variables ***
${RESOURCES}    ${CURDIR}/nsa_misc.resources
${RMODS_NUMBER}    4

# -- test scenario variables --
${LUA_CONFIG}    ${RESOURCES}/epcsim.cfg
${DELTA_CB006030}    ${RESOURCES}/delta_CB006030_A.json
${DELTA_5GC001296}    ${RESOURCES}/delta_5GC001296_B.json
${SCFC_CB006030}    ${RESOURCES}/scfc_CB006030_A.xml

*** Test Cases ***
5GC001296-B-B1_-_Successful_Intra_Frequency_Inter_GNB_PCI_Resolution_And_Neighbour_Addition
    [Documentation]    This test case verifies NSA Intra frequency handover procedures, after the runtime creation of
    ...    5G adjacencies configuration using the new object model.
    [Setup]    [PRE]5GC001296-B-B1_-_Successful_Intra_Frequency_Inter_GNB_PCI_Resolution_And_Neighbour_Addition
    [Teardown]    [POST]5GC001296-B-B1_-_Successful_Intra_Frequency_Inter_GNB_PCI_Resolution_And_Neighbour_Addition
    NSA Attach 5G UE
    Perform Inter gNB Intra_Frequency Handover
    Verify UE Supports NRCGI Report
    Verify Measurement Configuration
    Verify Inter gNB Intra_Frequency Handover
    Verify Created NRADJNRCELL And NRREL Objects

CB006030-A_-_5G_Adjacencies_and_Neighboring_Relations_model_redesign
    [Documentation]    This test case verifies NSA Intra frequency handover procedures, after the runtime creation of
    ...    5G adjacencies configuration using the new object model.
    [Setup]    [PRE]CB006030-A_-_5G_Adjacencies_and_Neighboring_Relations_model_redesign
    [Teardown]    [POST]CB006030-A_-_5G_Adjacencies_and_Neighboring_Relations_model_redesign
    Add NRADJNRCELL And NRREL Objects To Configuration
    NSA Start WTS
    NSA Attach 5G UE
    Perform Intra gNB Inter Cell Handover
    Verify Intra gNB Inter Cell Handover
    Perform Inter gNB Inter Cell Handover
    Verify Inter gNB Inter Cell Handover

CNI67972_5G_TTI_Trace_Decoder
    [Documentation]
    ...    This test case verify if TTI trace decoder is able to decode TTI trace file into json and legacyCsv formats.
    [Setup]    [PRE]CNI67972_5G_TTI_Trace_Decoder
    [Teardown]    [POST]CNI67972_5G_TTI_Trace_Decoder
    NSA Attach 5G UE
    Start DL And UL Traffic
    Get TTI Trace File From Snapshot
    Decode TTI Trace File Into Json File
    Decode TTI Trace File Into LegacyCsv File

*** Keywords ***
Test suite preconditions
    Add Eth    ip=10.0.1.3    mask=24    interface=eth3    label=eth3:gNB2

[PRE]5GC001296-B-B1_-_Successful_Intra_Frequency_Inter_GNB_PCI_Resolution_And_Neighbour_Addition
    Delta Commissisoning    ${DELTA_5GC001296}
    Start WTS    ${LUA_CONFIG}    nr_mode=NSA    check_version=False
    Check if BTS is OnAir

[POST]5GC001296-B-B1_-_Successful_Intra_Frequency_Inter_GNB_PCI_Resolution_And_Neighbour_Addition
    NSA Detach UE    ue_id=101
    Report miscellaneous KPIs
    Stop WTS
    Teardown All Aliases For Tshark
    Perform Commissioning    scfc_path=${__DEFAULT_SCFC__}
    Check if BTS is correctly configured    ${RMODS_NUMBER}

[PRE]CB006030-A_-_5G_Adjacencies_and_Neighboring_Relations_model_redesign
    Perform Commissioning    scfc_path=${SCFC_CB006030}
    Check if BTS is correctly configured    ${RMODS_NUMBER}

[POST]CB006030-A_-_5G_Adjacencies_and_Neighboring_Relations_model_redesign
    Report miscellaneous KPIs
    Stop WTS
    Teardown All Aliases For Tshark
    Perform Commissioning    scfc_path=${__DEFAULT_SCFC__}
    Check if BTS is correctly configured    ${RMODS_NUMBER}

[PRE]CNI67972_5G_TTI_Trace_Decoder
    Download TTI Decoder From Artifactory
    Start WTS    ${LUA_CONFIG}    nr_mode=NSA    check_version=False
    Check if BTS is OnAir

[POST]CNI67972_5G_TTI_Trace_Decoder
    Report miscellaneous KPIs
    Stop WTS
    Teardown All Aliases For Tshark
    Perform Commissioning    scfc_path=${__DEFAULT_SCFC__}
    Check if BTS is correctly configured    ${RMODS_NUMBER}

# -- test steps --
Perform Inter gNB Intra_Frequency Handover
    [Tags]    DESIGNSTEP
    Start Tshark Packet Capturing
    Perform Handover By Sending UE NR Measurements    enb=3    cell_id=1    pci=49
    SLEEP    5s
    Stop Tshark Packet Capturing

Verify Inter gNB Intra_Frequency Handover
    [Tags]    DESIGNSTEP
    FOR    ${message}    IN    @{INTER_GNB_HO_5GC001296}
        ${packets_count}    ute_tshark.get_packets_count
        ...    packet_filter=${message['filter']}
        ...    alias=default
        RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    "${packets_count}"=="${message['amount']}"
        ...    msg=Amount of ${message['name']}: ${packets_count} is not equal to expected amount: ${message['amount']}
    END

Verify UE Supports NRCGI Report
    [Tags]    DESIGNSTEP
    ${NRCGI_REPORT}    ute_tshark.get_packets_count
    ...    packet_filter=x2ap.SgNBAdditionRequest_element && nr-rrc.nr_CGI_Reporting_ENDC == 0
    ...    alias=default
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${NRCGI_REPORT}==${1}
    ...    msg=Number of NRCGI_REPORT packet are not as expected. Number of counted requests: ${NRCGI_REPORT}

Verify Measurement Configuration
    [Tags]    DESIGNSTEP
    FOR    ${message}    IN    @{NEW_MEAS_CONF_5GC001296}
        ${packets_count}    ute_tshark.get_packets_count
        ...    packet_filter=${message['filter']}
        ...    alias=default
        RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    "${packets_count}"=="${message['amount']}"
        ...    msg=Amount of ${message['name']}: ${packets_count} is not equal to expected amount: ${message['amount']}
    END

Verify Created NRADJNRCELL And NRREL Objects
    [Tags]    DESIGNSTEP
    Wait For Object To Exist    object_name=NRADJNRCELL_A-12288    moc=NRADJNRCELL_A    timeout=120
    Wait For Object To Exist    object_name=NRREL_A-256    moc=NRREL_A    timeout=120
    &{NRADJNRCELL}=    Get Managed Object    object_name=NRADJNRCELL_A-12288    moc=NRADJNRCELL_A
    &{NRREL}=    Get Managed Object    object_name=NRREL_A-256    moc=NRREL_A
    Verify Created NRADJNRCELL Object    NRADJNRCELL=&{NRADJNRCELL}    mcc=311    mnc=489    mncLength=3    physCellId=49    cellDepType=SA+NSA
    ...                                  nrarfcn=636666    ssbFrequency=636576    gNbId=3    gNbIdLength=22    lcrId=1
    Verify Created NRREL Object    NRREL=&{NRREL}    mcc=${NRADJNRCELL.gnbPlmn.mcc}    mnc=${NRADJNRCELL.gnbPlmn.mnc}
    ...                            mncLength=${NRADJNRCELL.gnbPlmn.mncLength}    gNbId=3    gNbIdLength=${NRADJNRCELL.gNbIdLength}
    ...                            lcrId=${NRADJNRCELL.lcrId}

Add NRADJNRCELL And NRREL Objects To Configuration
    [Tags]    DESIGNSTEP
    Delta Commissisoning    ${DELTA_CB006030}
    Check if BTS is correctly configured    ${RMODS_NUMBER}

NSA Start WTS
    [Tags]    DESIGNSTEP
    Start WTS    ${LUA_CONFIG}    nr_mode=NSA    check_version=False
    Check if BTS is OnAir

Perform Intra gNB Inter Cell Handover
    [Tags]    DESIGNSTEP
    Start Tshark Packet Capturing   alias=Intra_gNB
    Perform Handover By Sending UE NR Measurements    enb=2   cell_id=2   pci=51
    SLEEP    5s
    Stop Tshark Packet Capturing    alias=Intra_gNB

Perform Inter gNB Inter Cell Handover
    [Tags]    DESIGNSTEP
    Start Tshark Packet Capturing   alias=Inter_gNB
    Perform Handover By Sending UE NR Measurements    enb=3   cell_id=1   pci=49
    SLEEP    5s
    Stop Tshark Packet Capturing    alias=Inter_gNB

Verify Intra gNB Inter Cell Handover
    [Tags]    DESIGNSTEP
    FOR    ${message}    IN    @{INTRA_GNB_HO_CB006030}
        ${packets_count}    ute_tshark.get_packets_count
        ...    packet_filter=${message['filter']}
        ...    alias=Intra_gNB
        RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    "${packets_count}">="${message['amount']}"
        ...    msg=Amount of ${message['name']}: ${packets_count} is not equal to expected amount: ${message['amount']}
    END

Verify Inter gNB Inter Cell Handover
    [Tags]    DESIGNSTEP
    FOR    ${message}    IN    @{INTER_GNB_HO_CB006030}
        ${packets_count}    ute_tshark.get_packets_count
        ...    packet_filter=${message['filter']}
        ...    alias=Inter_gNB
        RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    "${packets_count}">="${message['amount']}"
        ...    msg=Amount of ${message['name']}: ${packets_count} is not equal to expected amount: ${message['amount']}
    END

NSA Attach 5G UE
    [Tags]    DESIGNSTEP
    NSA Attach 5G UE"101"

Start DL And UL Traffic
    [Tags]    DESIGNSTEP
    Start 'dl' Traffic To 5G
    Sleep    5
    Verify If Throughput Is Started    ue=101   dir=dl
    Start 'ul' Traffic To 5G
    Sleep    5
    Verify If Throughput Is Started    ue=101    dir=ul
    Sleep    60

Get TTI Trace File From Snapshot
    [Tags]    DESIGNSTEP
    Collect Snapshot
    Extract TTI File From Collected Snapshot

Decode TTI Trace File Into Json File
    [Tags]    DESIGNSTEP
    tti_traces_decoder.decode_tti_file    ${TTI_DECODER_PATH}    ${TTI_FILE_PATH}    json

Decode TTI Trace File Into LegacyCsv File
    [Tags]    DESIGNSTEP
    tti_traces_decoder.decode_tti_file    ${TTI_DECODER_PATH}    ${TTI_FILE_PATH}    legacyCsv

# -- internals --
Start Tshark Packet Capturing
    [Arguments]    ${alias}=default
    [Documentation]    Starts Tshark packet capturing for given alias.
    ...    Parameters:
    ...    alias: alias used to define tshark session
    ${tshark_logs}    Prepare Logs Directory Path    tshark/${alias}   with_timestamp=${FALSE}
    ute_tshark.setup_tshark
    ...    interface=eth3 lo
    ...    alias=${alias}
    ...    log_dir=${tshark_logs}
    ...    log_name=${alias}
    ute_tshark.start_capturing    capture_filter=sctp    alias=${alias}

Perform Handover By Sending UE NR Measurements
    [Arguments]    ${enb}    ${cell_id}    ${pci}
    ${operation}=    SET VARIABLE    ue_measurement_send_nr
    ${pass_regexp}=    SET VARIABLE    Proxy \\(eNB ${enb} cell ${cell_id}\\) reported successful RA
    ${egate_cmd}=    SET VARIABLE    ${operation} id=101 meas_id=1 event=A5 phycell_id=${pci} nrsrp_nr=101 srsrp_nr=19
    RUN KEYWORD AND CONTINUE ON FAILURE    ute_wtssim.execute_egate_command_and_wait_for_data
    ...    cmd=${egate_cmd}
    ...    pass_regexp=${pass_regexp}
    ...    timeout=${__EGATE_COMMAND_TIMEOUT___}

Stop Tshark Packet Capturing
    [Arguments]    ${alias}=default
    [Documentation]    Stops Tshark packet capturing for given alias.
    ...    Parameters:
    ...    alias: alias used to define tshark session
    ute_tshark.stop_capturing    alias=${alias}

Verify Created NRADJNRCELL Object
    [Arguments]    ${NRADJNRCELL}    ${mcc}    ${mnc}    ${mncLength}    ${physCellId}    ${cellDepType}    ${nrarfcn}    ${ssbFrequency}
    ...            ${gNbId}    ${gNbIdLength}    ${lcrId}
    SHOULD BE EQUAL AS INTEGERS    ${NRADJNRCELL.gnbPlmn.mcc}    ${mcc}
    SHOULD BE EQUAL AS INTEGERS    ${NRADJNRCELL.gnbPlmn.mnc}    ${mnc}
    SHOULD BE EQUAL AS INTEGERS    ${NRADJNRCELL.gnbPlmn.mncLength}    ${mncLength}
    SHOULD BE EQUAL AS INTEGERS    ${NRADJNRCELL.physCellId}     ${physCellId}
    SHOULD BE EQUAL    ${NRADJNRCELL.cellDepType}     ${cellDepType}
    SHOULD BE EQUAL AS INTEGERS    ${NRADJNRCELL.nrarfcn}    ${nrarfcn}
    SHOULD BE EQUAL AS INTEGERS    ${NRADJNRCELL.ssbFrequency}    ${ssbFrequency}
    SHOULD BE EQUAL AS INTEGERS    ${NRADJNRCELL.gNbId}    ${gNbId}
    SHOULD BE EQUAL AS INTEGERS    ${NRADJNRCELL.gNbIdLength}    ${gNbIdLength}
    SHOULD BE EQUAL AS INTEGERS    ${NRADJNRCELL.lcrId}    ${lcrId}

Verify Created NRREL Object
    [Arguments]    ${NRREL}    ${mcc}    ${mnc}    ${mncLength}    ${gNbId}    ${gNbIdLength}    ${lcrId}    ${removeNotAllowed}=${False}
    ...            ${cellIndividualSsbRsrpOffset}=0dB    ${cellIndividualSsbRsrqOffset}=0dB
    SHOULD BE EQUAL    ${NRREL.cellIndividualSsbRsrpOffset}    ${cellIndividualSsbRsrpOffset}
    SHOULD BE EQUAL    ${NRREL.cellIndividualSsbRsrqOffset}    ${cellIndividualSsbRsrqOffset}
    SHOULD BE EQUAL AS INTEGERS    ${NRREL.gnbPlmn.mcc}    ${mcc}
    SHOULD BE EQUAL AS INTEGERS    ${NRREL.gnbPlmn.mnc}    ${mnc}
    SHOULD BE EQUAL AS INTEGERS    ${NRREL.gnbPlmn.mncLength}    ${mncLength}
    SHOULD BE EQUAL AS INTEGERS    ${NRREL.gNbId}     ${gNbId}
    SHOULD BE EQUAL AS INTEGERS    ${NRREL.gNbIdLength}     ${gNbIdLength}
    SHOULD BE EQUAL AS INTEGERS    ${NRREL.lcrId}    ${lcrId}
    SHOULD BE EQUAL    ${NRREL.removeNotAllowed}    ${removeNotAllowed}

Start '${direction}' Traffic To 5G
    ${command}    SET VARIABLE    trf_data_start ue=101 id=2 dir=${direction} mbps=50
    ute_wtssim.execute_egate_command_and_wait_for_data    cmd=${command}    timeout=${__EGATE_COMMAND_TIMEOUT___}

Extract TTI File From Collected Snapshot
    ${logs_dir}=    Prepare Logs Directory Path    TTI_snapshot_file
    ${tti_file_path}=    tti_traces_decoder.extract_tti_file_from_snapshot    ${SNAPSHOT_TTI_PATH}    ${logs_dir}
    SET SUITE VARIABLE    ${TTI_FILE_PATH}  ${tti_file_path}

Collect Snapshot
    ${connection}=    SET VARIABLE    snapshot_tti
    ${logs_dir}=    Prepare Logs Directory Path    Snapshot_TTI
    admin.connect_to    bts_host=${__LOCAL_BTS_IP__}    admin_api_log_dir=${logs_dir}    name=${connection}
    admin.collect_snapshot    ${logs_dir}/snapshot_tti.zip    timeout=840    connection=${connection}
    SET SUITE VARIABLE    ${SNAPSHOT_TTI_PATH}    ${logs_dir}/snapshot_tti.zip
    [Teardown]    admin.teardown    connection=${connection}

Download TTI Decoder From Artifactory
    ${output_path}=    Prepare Logs Directory Path    TTI_decoder
    ${tti_decoder_file_path}=    tti_traces_decoder.download_tti_decoder    ${ENB_BRANCH.partition("_")[0]}    ${ENB_BUILD}    ${output_path}
    Run    tar -xJvf ${tti_decoder_file_path} -C ${output_path}
    SET SUITE VARIABLE    ${TTI_DECODER_PATH}    ${output_path}
