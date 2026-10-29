*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
    ...    CLOUD_5G_I_LPQ_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation    :copyright: Nokia
...              :authors: Marcin Holowinski
...              :contact: Marcin.Holowinski@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Library      ta5g_tshark
Library      ta5g_iphy
Library      ta5g_enb
Library      ta5g_pm_counters
Library     taf.collectors.l2stream3     WITH NAME  tcl
Library     taf.collectors.core          WITH NAME  tcc
Library     taf.converters.eventdecoder  WITH NAME  tce

Suite Setup    Run Keywords    Remove And Replace File    new_file=${new_file}    target_path=${target_path}
...            AND             Log to console    Full scfc commissioning with iphy.xml upload
...            AND             Backup And Modify Swconfig File    parameters_list=@{SWCONFIG_FLAGS_LIST}
...            AND             Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_lpq_AVQL.xml
...            AND             Find Scfc And Fix And Send Full Commissioning    scfc_filename=scfc_bfr.xml
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/basic.lua
...            AND             Get Next Unpacked Full Pm Counters File

Suite Teardown    Run Keywords    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/SetupLogs
...               AND             Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${rdComponentBitMapProfile}=        0x5808FF=2
@{SWCONFIG_FLAGS_LIST}=        ${rdComponentBitMapProfile}
${LOGS_COMPRESSION}=    ${True}
${LOGGING_POLICY}=      FULL_POLICY
${UE_ID}=               1
${new_file}=          ${CURDIR}/config/packet_iphy.lua
${target_path}=       /home/ute/.local/lib/wireshark/plugins/packet_iphy.lua

*** Test Cases ***
CB012192_A_Beam_Failure_Recovery
    Activate CB012192 With nbrOfSsbPerRachOccasion value 4
    Setup Beam Control Test Profiles
    Activate Beam Control Test Profile    ue_id=${UE_ID}    profile_id=1    beamaction=attach
    Start TTI trace collection
    Attach UE And Establish PDU Session    ue_id=${UE_ID}    cell_id=6    enb_id=2
    Start Data Traffic    ue_id=${UE_ID}
    Sleep    5
    Activate Beam Control Test Profile    ue_id=${UE_ID}    profile_id=3    beamaction=recovery
    Sleep    15
    Activate Beam Control Test Profile    ue_id=${UE_ID}    profile_id=2    beamaction=recovery

    [Teardown]    Run Keywords    Stop TTI trace collection
    ...    AND    Get PM Counter File For Analysis
    ...    AND    Deregister UE    ue_id=1
    ...    AND    Add Scout Data Info To Testcase

*** Keywords ***

Setup Beam Control Test Profiles
    ${profile_1_beam_2}=  Catenate  SEPARATOR=
    ...                beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=2,0,1,3,4,5 ssbeam_bestbeam=2
    ...                \ ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120
    ${profile_2_beam_3}=  Catenate  SEPARATOR=
    ...                beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=3,0,1,3,4,5 ssbeam_bestbeam=3
    ...                \ ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120
    ${profile_3_beam_0}=  Catenate  SEPARATOR=
    ...                beam_control_testmode_nr profile_id=3 ueBeamIndexInitial=0,0,1,3,4,5 ssbeam_bestbeam=0
    ...                \ ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120

    Execute Egate Command    cmd=${profile_1_beam_2}
    Execute Egate Command    cmd=${profile_2_beam_3}
    Execute Egate Command    cmd=${profile_3_beam_0}

Activate Beam Control Test Profile
    [Arguments]    ${ue_id}    ${profile_id}    ${beamaction}
    Execute Egate Command   cmd=ue_testmode_set_nr id=${ue_id} testmode=beam_control beamaction=${beamaction} profile_id=${profile_id} action=activate

Start Data Traffic
    [Arguments]    ${ue_id}     ${pdu}=1
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu} trf_id=1 dir=dl mbps=10

Attach UE And Establish PDU Session
    [Arguments]    ${ue_id}    ${cell_id}    ${enb_id}=1    ${pdu_id}=1    ${gw_id}=1    ${pdu_session_setup_timeout}=15
    ...    ${nwslice}=1
    Attach UE    ue_id=${ue_id}    cell=${cell_id}    enb=${enb_id}
    ...    pass_regexp=Received REGISTRATION COMPLETE from UE
    Set Internal Traffic Type To UE    ue_id=${ue_id}    pdu_id=${pdu_id}
    Establish PDU Session    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}    nwslice=${nwslice}
    ...    timeout=${pdu_session_setup_timeout}
    ...    pass_regexp=UE${ue_id}: Established PDU session ID=${pdu_id} using PDU Gateway ID=
	Sleep    2

Set Internal Traffic Type To UE
    [Arguments]    ${ue_id}    ${pdu_id}
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal

Start TTI trace collection
    ${configurations}=  tcc.Load Configurations    ${CURDIR}/tti_trace_collectors.yaml
    tcc.Create Collectors    names=l2stream3    configurations=${configurations['collectors']}
    tcl.Set Suite Alias     alias=l2stream3
    tcc.Setup Collectors    names=l2stream3
    tcc.Start Collectors    names=l2stream3
    Log to console    ${\n}TTI traces collecting started
	Sleep    5

Stop TTI trace collection
    Log to console    Stopping TTI traces collecting
    tcc.Stop Collectors    names=l2stream3
    tcc.Collect Collectors    names=l2stream3
    tcc.Teardown Collectors    names=l2stream3


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
    Move Files      ${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/output*     ${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/${directory_name}/
    Move Directory  ${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/l2stream3/  ${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/${directory_name}/


Collect TTI Traces during ${duration} seconds and save to directory ${directory_name}
    ${parent_directory}  Set variable  ${directory_name}
    Set Test Variable  ${parent_directory}
    Start TTI trace collection
    Log to console    Collecting duration is ${duration}
    Sleep  ${duration}
    Stop TTI trace collection
    Convert TTI trace from pcap  format=excelCsv  directory_name=${directory_name}

Get PM Counter File For Analysis
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify Any Counters In File
        ...    M55306C00001    1      RA_ATT_CONT_A_PRMBL_SSB_00
        ...    M55306C00003    1      RA_ATT_CONT_A_PRMBL_SSB_02
        ...    M55306C00004    1      RA_ATT_CONT_A_PRMBL_SSB_03
        ...    M55305C10003    1      SUCC_BEAM_RECOVERY_BEAM_ID_2
        ...    M55305C10001    1      SUCC_BEAM_RECOVERY_BEAM_ID_0
        ...    M55305C11007    1      TIME_BEAM_BIN_7
        ...    M55305C11008    1      TIME_BEAM_BIN_8
        ...    M55305C12001    >150   UES_PER_BEAM_ID_0
        ...    M55305C12003    >50    UES_PER_BEAM_ID_2
        ...    M55305C12004    >50   UES_PER_BEAM_ID_3
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-6
        ...    file_path=${pm_counter_file}

Activate CB012192 With nbrOfSsbPerRachOccasion value 4
    Find Scfc and Send Delta Commissioning    scfc_filename=delta_nbrOfSsbPerRachOccasion_4.json
    Sleep    20

Remove And Replace File
    [Arguments]    ${new_file}    ${target_path}
    Log  \n==== Replace file to solve the problem with dissecting nr-rrc packets with ute-wireshark 4.4.7 ====  console=True
    # Ensure the new file exists
    File Should Exist    ${new_file}

    # Remove the target file if it exists
    Run Keyword And Ignore Error    Remove File    ${target_path}

    # Copy the new file to the target location
    Copy File    ${new_file}    ${target_path}
