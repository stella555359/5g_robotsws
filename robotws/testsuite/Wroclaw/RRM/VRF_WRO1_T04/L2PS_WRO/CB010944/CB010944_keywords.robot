*** Settings ***
Documentation
...    author: Mariusz Waczynski
...    maintainer: Marcin Kotula (marcin.kotula@nokia.com)
...    testline: CLOUD_5G_I_MP_AP_LOOO
...    release: 25R3

Library    taf.transport.ssh  WITH NAME  ssh
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    taf.collectors.l1l2bip    WITH NAME    l1l2bip
Library    taf.collectors.core    WITH NAME    core
Library    ta5g_pm_counters
Library    ta5g_tshark
Library    BuiltIn
Library    Collections
Library    ta_a2a
Library    taf.sbts.oam.coam.admin    WITH NAME   COAM
Library    ute_admin_infomodel
Library    CB010944_keywords.py
Library    testsuite.Wroclaw.RRM.VRF_WRO1_T04.resources.Tokens

*** Variables ***
${ARTIFACTORY_ROTTA}           https://artifactory-espoo1.ext.net.nokia.com/artifactory/list/mnpute-rotta-local
${download_path}               ${ARTIFACTORY_ROTTA}/waczynsk/BSR/BSR_AVQL_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00002.zip
${BSR_FILENAME}                BSR_AVQL_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00002.zip
${ADMIN_INFOMODEL_ALIAS}       infomodel_1
${ADMIN_INFOMODEL_LOG_DIR}     ${OUTPUT_DIR}
${ADMIN_INFOMODEL_FILENAME}    infomodel.ims2

*** Keywords ***
Verify Target Beam Candidates
    Start Infomodel Logging
    FOR    ${ID}    IN RANGE    ${1}    ${6}
    ${object_exists}=       Check infomodel object        dist_name=/MRBTS-1//NRCELL_A-1/NRBEAM_EMF_A-${ID}    alias=${ADMIN_INFOMODEL_ALIAS}
    Should Be True         ${object_exists}               msg= NRBEAM_EMF_A-${ID} found in InfoModel.
    END
    Stop Infomodel Logging      address=192.168.255.129

Check Selected Beam Candidates
    [Arguments]      ${expected_value}
    Start Infomodel Logging
    Query Infomodel And Expect Parameter Value
    ...    dist_name=/MRBTS-1/RAT-1//NRCELL_A-1
    ...    parameter=emfBeamDNList[0]
    ...    value=${expected_value}
    Stop Infomodel Logging      address=192.168.255.129

Verify Target Beam Candidates Not Exist
    Start Infomodel Logging
    FOR    ${ID}    IN RANGE    ${1}    ${6}
    ${object_exists}=       Check infomodel object        dist_name=/MRBTS-1//NRCELL_A-1/NRBEAM_EMF_A-${ID}    alias=${ADMIN_INFOMODEL_ALIAS}
    Should Be True         ${object_exists}==${False}               msg= NRBEAM_EMF_A-${ID} not found in InfoModel.
    END
    Stop Infomodel Logging      address=192.168.255.129

Active beam
    Send Delta Commissioning    input_filepath=${CURDIR}/config/emfbeam_2_7_2e.json

Enable Emf
    Send Delta Commissioning    input_filepath=${CURDIR}/config/delta_enable_emf.json

Deactive Emf Test Mode
    Send Delta Commissioning    input_filepath=${CURDIR}/config/deactive_emf_2_7_2e.json

Get and Update BSR File
     [Arguments]  ${download_path}=${download_path}    ${bsr_file_path}=${OUTPUTDIR}/${BSR_FILENAME}
     ${token}=   get_ca_ute_artifactory_token
     Run  sudo wget -d --header='Authorization:Bearer ${token}' ${download_path} -O ${bsr_file_path}
     COAM.setup admin
     ${ret}     COAM.Update Software      ${bsr_file_path}
     COAM.teardown admin

Start Data Traffic In DL and UL
    [Arguments]   ${ue_id}    ${pdu}    ${tput_ul}      ${tput_dl}
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu} dir=ul mbps=${tput_ul}
    ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu} dir=dl mbps=${tput_dl}

Setup X2 Link
    Execute Egate Command    cmd=enb_x2_link_up enb=1 target=2
    Sleep    10s    Wait For X2 Establishment

Stop Infomodel Logging
    [Arguments]    ${address}
    ...            ${filename}=${ADMIN_INFOMODEL_FILENAME}
    ...            ${log_dir}=${ADMIN_INFOMODEL_LOG_DIR}
    ...            ${alias}=${ADMIN_INFOMODEL_ALIAS}

    ute_admin_infomodel.Save Infomodel Log    filename=${log_dir}/${filename}_${address}  alias=${alias}
    ute_admin_infomodel.Disconnect Infomodel  alias=${alias}
    ute_admin_infomodel.Teardown Infomodel    alias=${alias}

Query Infomodel And Expect Parameter Value
    [Arguments]    ${dist_name}
    ...            ${parameter}
    ...            ${value}
    ...            ${timeout}=60
    ${out_query_result}=   ute_admin_infomodel.Query Infomodel    query=${dist_name} is [${parameter}=${value}]
    ...    timeout=${timeout}  alias=${ADMIN_INFOMODEL_ALIAS}

Start Infomodel Logging
    ute_admin_infomodel.Setup infomodel    address=192.168.255.129    port=443    alias=${ADMIN_INFOMODEL_ALIAS}
    ute_admin_infomodel.Connect infomodel    alias=${ADMIN_INFOMODEL_ALIAS}

Start Gathering BIP Logs
    [Arguments]    ${target_file_name}=tcpdump
     ${webservice}=  Create Dictionary
     ...  host=192.168.255.129
     ...  user=Nemuadmin
     ...  password=nemuuser
     ...  port=443

     create_interface_mirroring_l1l2bip_collector
     ...  name=tcpdump
     ...  webservice=${webservice}
     ...  target_file_name=tcpdump
     ...  timeout=1300
     ...  remove_zip_file=False
     core.setup_collectors    names=tcpdump
     core.start_collectors    names=tcpdump
     core.Set Suite Alias     ${target_file_name}
     Sleep    50

Stop gnbMirroring And Gather L1L2 Bip Logs
     [Arguments]
     ...     ${alias}=L1L2_BIP_Logs
     ...     ${dir_path}=${OUTPUT_DIR}
     ...     ${delay}=0
     Sleep  ${delay}
     Create directory  path=${dir_path}/${alias}
     Create directory  path=/tmp/${alias}
     core.stop_collectors    names=tcpdump
     core.collect_collectors    names=tcpdump    target_dir=${OUTPUT_DIR}
     core.teardown_collectors    names=tcpdump
     ${rc}=    Run And Return Rc  mergecap -a ${dir_path}/tcpdump/*mirroring_L2L1*.pcap* -w /tmp/${alias}/tcpdump.pcap
     Run keyword if    ${rc}!=0    Fail    PCAP merging failed, check if alias does not contain spaces
     OperatingSystem.Copy File    /tmp/${alias}/tcpdump.pcap    ${dir_path}/BIP_L1L2.pcap
     Remove Directory    ${OUTPUT_DIR}/tcpdump
     ...                 recursive=True
     Sleep    10s

Stop Second gnbMirroring And Gather L1L2 Bip Logs
     [Arguments]
     ...     ${alias}=L1L2_BIP_Logs
     ...     ${dir_path}=${OUTPUT_DIR}
     ...     ${delay}=0
     Sleep  ${delay}
     Create directory  path=${dir_path}/${alias}
     Create directory  path=/tmp/${alias}
     core.stop_collectors    names=tcpdump
     core.collect_collectors    names=tcpdump    target_dir=${OUTPUT_DIR}
     core.teardown_collectors    names=tcpdump
     ${rc}=    Run And Return Rc  mergecap -a ${dir_path}/tcpdump/*mirroring_L2L1*.pcap* -w /tmp/${alias}/tcpdump.pcap
     Run keyword if    ${rc}!=0    Fail    PCAP merging failed, check if alias does not contain spaces
     OperatingSystem.Copy File    /tmp/${alias}/tcpdump.pcap    ${dir_path}/BIP_L1L2_second.pcap
     Remove Directory    ${OUTPUT_DIR}/tcpdump
     ...                 recursive=True
     Sleep    10s

Set Internal Traffic Type To MUE
    Execute Egate Command   cmd=set_pdu_param ue=1 pdu=1 trf_type=internal
    Execute Egate Command   cmd=set_pdu_param ue=2 pdu=2 trf_type=internal
    Execute Egate Command   cmd=set_pdu_param ue=3 pdu=3 trf_type=internal
    Execute Egate Command   cmd=set_pdu_param ue=4 pdu=4 trf_type=internal

Attach SA UE And Verify msg2TPC
    [Arguments]   ${ue_id}      ${msg2TPC_value}
    Execute Egate Command    cmd=ue_register id=${ue_id}
    ...    pass_regexp=msg2TPC: ${msg2TPC_value}

Start Data Traffic In UL
    [Arguments]   ${ue_id}    ${pdu}    ${tput_ul}
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu} dir=ul mbps=${tput_ul}

Collect TTI Traces And Check DL MU-MIMO And DL SRS-based BF
    [Arguments]  ${duration}    ${directory_name}   ${ini_path}
    Collect And Convert TTI Traces      duration=${duration}    directory_name=${directory_name}
    Check DL MU-MIMO And DL SRS-based BF in TTiTrace        directory_name=${directory_name}    ini_path=${ini_path}

Collect And Convert TTI Traces
    [Arguments]  ${duration}    ${directory_name}
    ${parent_directory}  Set variable  ${directory_name}
    Set Test Variable  ${parent_directory}
    Start TTI trace collection
    Log to console    Collecting duration is ${duration}
    Sleep  ${duration}
    Stop TTI trace collection
    Convert TTI trace from pcap  format=excelCsv  directory_name=${directory_name}

Start TTI trace collection
    ${configurations}=  core.Load Configurations    ${CURDIR}/config/tti_trace_collectors.yaml
    core.Create Collectors    names=l2stream3    configurations=${configurations['collectors']}
    tcl.Set Suite Alias     alias=l2stream3
    core.Setup Collectors    names=l2stream3
    core.Start Collectors    names=l2stream3
    Log to console    ${\n}TTI traces collecting started

Stop TTI trace collection
    Log to console    Stopping TTI traces collecting
    core.Stop Collectors    names=l2stream3
    core.Collect Collectors    names=l2stream3
    core.Teardown Collectors    names=l2stream3

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
    Remove Directory    ${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/${directory_name}/    recursive=True
    Move File           ${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/output_dl.csv         ${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/${directory_name}/
    Move File           ${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/output_ul.csv         ${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/${directory_name}/
    Move Directory      ${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/l2stream3/            ${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/${directory_name}/

Check DL MU-MIMO And DL SRS-based BF in TTiTrace
    [Arguments]  ${directory_name}      ${ini_path}
    check_log_with_au2anlysis    ini_path=${CURDIR}/config/${ini_path}    log_need_to_check=i
    ...    save_log_directory=${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/${directory_name}

Download and Modify Vendor File and perform commissioning
    [Arguments]  ${scf}
    ${oam_alias}=    connect.Setup OAM session
    ${vendor_path}=    Set Variable    ${OUTPUT_DIR}/vendor_lte.xml
    Find And Fix Scfc   scfc_filename=${scf}.xml
    admin.download_vendor_file    target_file_name=${vendor_path}    connection=${oam_alias}
    Backup Vendor File  file_path=${vendor_path}
    Modify Vendor
    admin.set_vendor_file  vendor_file=${vendor_path}  connection=${oam_alias}
    ${paths} =    List Directory    ${OUTPUT_DIR}    ${scf}*MOD*.xml
    admin.perform_commissioning    scf_file=${OUTPUT_DIR}/${paths}[0]
    ...                            connection=${oam_alias}
    ...                            skip_parameter_relation_errors=True
    ...                            timeout=600
    connect.Teardown OAM session    connection=${oam_alias}

Backup Vendor File
    [Arguments]  ${file_path}
    Copy File    ${file_path}  ${file_path}.orig

Modify Vendor
    ${filter_criteria}=    Create Dictionary
    ...  xEc=20

    ${data_to_be_modified}=    Create Dictionary
    ...  xEc=14


    ${path_in_xml}=  vendor_file_modifier.get_xml_path_for_xec
    vendor_file_modifier.modify_vendor_file
    ...  filter_criteria=${filter_criteria}
    ...  data_to_be_modified=${data_to_be_modified}
    ...  path_to_reference_vendor_file=${OUTPUT_DIR}/vendor_lte.xml
    ...  path_to_modified_vendor_file=${OUTPUT_DIR}/vendor_lte.xml
    ...  xml_path=${path_in_xml}

Start Gathering BIP Logs And Wait 5s
    [Arguments]    ${target_file_name}=tcpdump
     ${webservice}=  Create Dictionary
     ...  host=192.168.255.129
     ...  user=Nemuadmin
     ...  password=nemuuser
     ...  port=443

     create_interface_mirroring_l1l2bip_collector
     ...  name=tcpdump
     ...  webservice=${webservice}
     ...  target_file_name=tcpdump
     ...  timeout=500
     ...  remove_zip_file=False
     core.setup_collectors    names=tcpdump
     core.start_collectors    names=tcpdump
     core.Set Suite Alias     ${target_file_name}
     Sleep    5

Convert pcap file to pdml
    [Documentation]     Using luashark converting BIP log from pcap to pdml.
    [Arguments]   ${tshark_filters}    ${input_file}=${OUTPUT_DIR}/BIP_L1L2.pcap
    Log to console    Converting pcap to pdml
        ${tshark_cmd} =   Catenate    tshark
    ...    -r ${input_file}
    ...    -Y "${tshark_filters}"
    ...    -T pdml > ${OUTPUT_DIR}/BIP_log_1.pdml
    Run    ${tshark_cmd}
    Check File Size    file_path=${OUTPUT_DIR}/BIP_log_1.pdml
    Log to console    Pcap->Pdml conversion done...
    Sleep    5s
