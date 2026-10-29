*** Settings ***
Documentation  common KWs used to analyze pcap files
Library         taf.converters.pcaptopdml   WITH NAME   pcaptopdml
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/pcap_common.py
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common_kw.robot

*** Variables ***
${ABIO_FILTER}  ether[0x1c:2]!=0xe101 and ether[0x1c:2]!=0x131 and ether[0x1c:2]!=0xe206 and
...             ether[0x1c:2]!=0xe105 and ether[0x1c:2]!=0xe111 and ether[0x1c:2]!=0xe229  #gnbMirroringConfig.sh
${ABIL_FILTER}  ether[0x18:2]!=0xe101 and ether[0x18:2]!=0x131 and ether[0x18:2]!=0xe206 and
...             ether[0x18:2]!=0xe105 and ether[0x18:2]!=0xe111 and ether[0x18:2]!=0xe229  #gnbMirroringConfig.sh

*** Keywords ***
Check ASIL and ABIL
    [Arguments]     ${bb_slot_1}  ${bb_slot_2}  ${bb_slot_3}  ${bb_slot_4}  ${bb_slot_5}  ${bb_slot_6}  ${bb_slot_7}
    ${alias}        Set Variable  pcap
    ${asil}         Set Variable  ${False}
    ${abil}         Set Variable  ${False}
    &{bbmods}       Create dictionary
    ...             ${bb_slot_1}=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-1
    ...             ${bb_slot_2}=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-2
    ...             ${bb_slot_3}=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-3
    ...             ${bb_slot_4}=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-4
    ...             ${bb_slot_5}=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-5
    ...             ${bb_slot_6}=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-6
    ...             ${bb_slot_7}=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-7
    Connect with runtime release             alias=${alias}
    ${smod_id}      coam.get_ids_for_all     SMOD   connection=${alias}
    ${smod_param}   coam.get parameters for  SMOD   ${smod_id}[0]        300  ${alias}
    ${smod_name}    Set Variable             ${smod_param}[productName]
    ${asil_name}    check_if_asil            ${smod_name}
    ${asil}         Set Variable             ${asil_name}
    ${bbmod_param}  coam.get parameters for  BBMOD  ${bbmods}[true]      300  ${alias}
    ${bbmod_name}   Set Variable             ${bbmod_param}[productName]
    ${abil_name}    check_if_abil            ${bbmod_name}
    ${abil}         Set Variable             ${abil_name}
    ${asil&abil}    check_if_asil_and_abil   ${asil}  ${abil}
    [Return]        ${asil&abil}

Start L1L2 logs gathering
    [Arguments]     ${alias}=ASIK
    ...             ${script_folder}=${EXECDIR}/testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/gnbMirroring
    ...             ${time}=10
    ...             ${size}=10
    ...             ${num_of_files}=1
    ...             ${filtering}=on
    ...             ${filter}=${ABIL_FILTER}
    ...             ${bb_slot_1}=true
    ...             ${bb_slot_2}=false
    ...             ${bb_slot_3}=false
    ...             ${bb_slot_4}=false
    ...             ${bb_slot_5}=false
    ...             ${bb_slot_6}=false
    ...             ${bb_slot_7}=false
    Set Test Variable  ${alias}
    Set Test Variable  ${time}
    Set Test Variable  ${filtering}
    Log to console     Start L1L2 logs gathering
    Connect to asik    ${alias}
    Configure gnbmirroring script       file_path=${script_folder}/gnbMirroringConfig.sh  time=${time}  size=${size}
    ...                                 num_of_files=${num_of_files}  filtering=${filtering}  filter=${filter}
    ...                                 bb_slot_1=${bb_slot_1}  bb_slot_2=${bb_slot_2}  bb_slot_3=${bb_slot_3}
    ...                                 bb_slot_4=${bb_slot_4}  bb_slot_5=${bb_slot_5}  bb_slot_6=${bb_slot_6}
    ...                                 bb_slot_7=${bb_slot_7}
    Upload gnbmirroring script to asik   script_folder=${script_folder}
    ssh.Send command    bash /ffs/run/config/scripts/gnbMirroring.sh  connection=${alias}
    #TODO: Use below command for ASIL+ABIL config
#    ssh.Send command    bash /ffs/run/config/scripts/gnbMirroring.sh > /tmp/output.txt  connection=${alias}
#    ssh.Send command    command=rm /tmp/output.txt    connection=${alias}
    #TODO: Below solution doesn't generate a file, to be investigated
#    ${asil_abil_method}  Check ASIL and ABIL  bb_slot_1=${bb_slot_1}  bb_slot_2=${bb_slot_2}  bb_slot_3=${bb_slot_3}
#    ...                                       bb_slot_4=${bb_slot_4}  bb_slot_5=${bb_slot_5}  bb_slot_6=${bb_slot_6}
#    ...                                       bb_slot_7=${bb_slot_7}
#    Run keyword if  ${asil_abil_method}==${TRUE}
#    ...  ssh.Send command    bash /ffs/run/config/scripts/gnbMirroring.sh > /tmp/output.txt  connection=${alias}
#    ...  ELSE
#    ...  ssh.Send command    bash /ffs/run/config/scripts/gnbMirroring.sh  connection=${alias}
#    ssh.Send command    command=rm /tmp/output.txt    connection=${alias}

Stop L1L2 logs gathering and download pcap
    [Arguments]         ${remote_path}=${OUTPUT DIR}/tcpdump_L2L1_bip_filtering_${filtering}.pcap
    ...                 ${time}=${time}
    log to console      Wait for logs for ${${time}+10}s
    sleep               ${${time}+10}
    Log to console      Stop L1L2 logs gathering and get pcap file
    ${local_path}       ssh.execute      ls /tmp/tcpdump_L2L1_bip_filtering_*  connection=${alias}
    ${local_path}       Fetch from left  ${local_path}  \r
    ssh.Download file   ${local_path}    ${remote_path}      connection=${alias}
    [Teardown]          Run keywords     ssh.Send command    command=rm ${local_path}    connection=${alias}
    ...                 AND              ssh.Disconnect      connection=${alias}
    [Return]            ${remote_path}

Start capturing interface mirroring logs
    [Arguments]  ${cells_ids}  ${interface}=L1-L2  ${destination}=Local  ${mirroring_time}=5  ${timeout}=300
    ...          ${detailed_output}=False  ${connection}=interface_mirroring
    ${cell_path}  Create List
    FOR  ${cell_id}  IN  @{cells_ids}
        Append to List  ${cell_path}  MRBTS-${MRBTS_5G_ID}/NRBTS-${MRBTS_5G_ID}/NRCELL-${cell_id}
    END
    Connect with runtime release  ${connection}
    coam.interface_mirroring
    ...  operation=Start
    ...  interface=${interface}
    ...  destination=${destination}
    ...  mirroring_time=${mirroring_time}
    ...  nr_cell_dns=${cell_path}
    ...  timeout=${timeout}
    ...  detailed_output=${detailed_output}
    ...  connection=${connection}
    Log to console  Capturing logs for ${mirroring_time}
    Set Test Variable  ${mirroring_time}
    Set Test Variable  ${timeout}
    Set Test Variable  ${detailed_output}
    Set Test Variable  ${connection}

Collect interface mirroring logs
    [Arguments]  ${output_file_name}=L2L1_bip.pcap
    sleep  ${${mirroring_time}+${5}}
    Log to console  Downloading logs
    coam.collect_mirroring_logs
    ...  output_file_name=${EXECDIR}/interface_mirroring.zip
    ...  timeout=${timeout}
    ...  detailed_output=${detailed_output}
    ...  connection=${connection}
    coam.teardown  connection=${connection}
    Log to console  Extracting and merging pcaps from zip file
    Run  bash ${EXECDIR}/testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/pcap/interface_mirroring.sh ${output_file_name}
    [Return]  ${EXECDIR}/${output_file_name}

Start tcpdump on gnb ASIK master
    [Arguments]      ${name}=master    ${options}=-i any sctp
    &{vm_config}=    create dictionary     host=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...                                    user=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...                                    password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    taf.collectors.tcpdump.create tcpdump collector       name=${name}   options=${options}   executor=${vm_config}
    taf.collectors.tcpdump.set test alias                 ${name}
    core.setup collectors                  names=${name}
    core.start collectors                  names=${name}

Stop pcap collection in gNB ASIK master
    [Arguments]    ${name}=master    ${pcap_path}=/tmp
    core.Stop collectors    names=${name}
    core.Collect collectors    names=${name}    target_dir=${pcap_path}
    core.Teardown collectors    names=${name}
    ${pcap_file}    Join Path    ${pcap_path}    ${name}    ${name}.pcap
    [Return]    ${pcap_file}

Start cplane capture on LTE smod
    [Arguments]     ${name}=lte    ${options}=-i any sctp
    ${gateway}      Create Dictionary
    ...             host=${tl.test_pcs.default_ssh_connection_details.addr}
    ...             user=${tl.test_pcs.default_ssh_connection_details.username}
    ...             password=${tl.test_pcs.default_ssh_connection_details.password}
    ${smod_config}  Create Dictionary
    ...             host=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...             user=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...             password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...             proxy=${gateway}
    taf.collectors.tcpdump.create tcpdump collector
    ...             name=${name}
    ...             options=${options}
    ...             executor=${smod_config}
    taf.collectors.tcpdump.set test alias        ${name}
    core.setup collectors                  names=${name}
    core.start collectors                  names=${name}

Stop cplane capture on LTE smod
    [Arguments]     ${name}=lte  ${pcap_path}=/tmp
    core.Stop collectors      names=${name}
    core.Collect collectors   names=${name}  target_dir=${pcap_path}
    core.Teardown collectors  names=${name}
    ${pcap_file}  Join Path   ${pcap_path}   ${name}    ${name}.pcap
    [Return]    ${pcap_file}

Convert pcap to pdml
    [Arguments]    ${path}=/tmp/cplane_trace.pcap
    pcaptopdml.create_pcap_to_pdml_converter
    ...      name=converter
    ...      file_path_pattern=${path}
    pcaptopdml.convert    converter
    ${dir}              get dir from path      ${path}
    ${filename}         get file without ext   ${path}
    ${pdml_file}        Set variable           ${dir}${filename}.pdml
    [Return]    ${pdml_file}

