*** Settings ***
Documentation
...    author: Deng xueqin
...    contact: xueqin.deng@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_2_SG

Library           taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library           XML  lxml=True
Library           taf.transport.ssh    WITH NAME    csn
Library           OperatingSystem
Library           Process
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          ../../common/common_1914_1583.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot

*** Variables ***
${WEBUI_URI}                    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_ADDR}                   ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USER}                   ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}               ${tl.gnbs[0].cu.oam_http_connection_details.password}
${dscp}                         0
${uplane_dst_port}              55900
${pcap_path}                    /sharedvolume/udptracer/_data/
${package_web_service}
...    https://artifactory-espoo1.int.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release/
${dcapuser_addr}    10.101.60.48
${dcapuser_username}    dcapuser
${dcapuser_password}    dcapadmin!
${uplane_destination}    ${dcapuser_addr}${:}${uplane_dst_port}

*** Keywords ***
Suite setup
    CI_interface.Common Suite Setup
    admin_cli.connect to    bts_host=${WEBUI_ADDR}
    Get localIpAddr
    Du login page via webUI
    Get PCI id and MRBTS id
    Configure Logging Agent
    sleep    5s

Suite teardown
    admin_cli.teardown    connection=default
    Run Keyword and Ignore Error    DU COAM selenium logout

Download and TAR TTI Decorder Tool to TAF VM
    Create Directory    /home/ute/Downloads
    Set Suite Variable   ${ttidecoder_path}   /home/ute/Downloads/ttitrace-${SW_vesion}
    Run    rm -rf /home/ute/Downloads/ttitrace-*
    ${package_download_dir}=   Set Variable
    ...   ${package_web_service}/${SW_vesion}
    ${package_download_path}=
    ...   Set Variable   ${package_download_dir}/${COAM_version}_tti-dec_qemux86-64-static.txz
    Log    \n Start to Download Package From WFT!    INFO
    Run   rm -f wget-log*
    Run   wget -b ${package_download_path} -P /home/ute/Downloads
    sleep    60s
    OperatingSystem.File Should Exist   /home/ute/Downloads/${COAM_version}_tti-dec_qemux86-64-static.txz
    Log To Console    Download Package Finished!
    Set Suite Variable    ${tti-dec_file}    /home/ute/Downloads/${COAM_version}_tti-dec_qemux86-64-static.txz
    Run   mkdir ${ttidecoder_path}
    Run   tar xJvf ${tti-dec_file} -C ${ttidecoder_path}
    [Return]   ${ttidecoder_path}

TTI Decoder Run Bin or Pcap to Json
    [Arguments]    ${inputfile_path}    ${ttidecoder_path}
    Run    rm -rf /${ttidecoder_path}/tti-dec-bin/*.json
    ${inputfile}    Fetch From Right    ${inputfile_path}    /
    Copy File    ${inputfile_path}     ${ttidecoder_path}/tti-dec-bin
    ${output}    Run
    ...  cd ${OUTPUT_DIR};python3 ${ttidecoder_path}/tti-dec-bin/TtiTraceDecoder.py ${ttidecoder_path}/tti-dec-bin/${inputfile} json
    Should Not Contain    ${output}    error
    sleep    2min
    File Should Not Be Empty    ${OUTPUTDIR}/decoderOutput.json
    ${jsonfile_path}    set variable   ${OUTPUTDIR}/decoderOutput.json
    [Return]    ${jsonfile_path}

Get the DCAP file and check its size is not zero
    csn.connect_to    hostname=${dcapuser_addr}
    ...    username=${dcapuser_username}    password=${dcapuser_password}    alias=DCAP
    ${all_pcap_file}    csn.execute
    ...    command=find ${pcap_path} -name \:\:ffff\:${WEBUI_ADDR}*.pcap    connection=DCAP
    Should not be empty    ${all_pcap_file}
    ${pcap_file_list}    Split String    string=${all_pcap_file}    separator=\r\n
    ${pcap_file}    set variable    ${pcap_file_list}[0]
    ${pcap_size}    csn.execute
    ...    command=stat ${pcap_file} | grep "Size:" |cut -d":" -f2 |cut -c2-12     connection=DCAP
    log    ${pcap_size}
    ${pcap_size}    Convert To Integer     ${pcap_size}
    Should not Be Equal    ${pcap_size}    ${0}
    [Teardown]    csn.disconnect    connection=DCAP

Stop uplane component traces
    [Arguments]    ${uplane_component_name}    ${source}=${EMPTY}
    ${stop_status}    run keyword and ignore error    selenium_coam.stop_component_trace
    ...    uplane_component_name=${uplane_component_name}    source=${source}
    should contain    ${stop_status[1]}    Stop succeeded

Stop uplane sherpa traces
    [Arguments]    ${uplane_sherpa_name}    ${source}=${EMPTY}
    ${stop_status}    run keyword and ignore error
    ...    selenium_coam.stop_sherpa_trace    uplane_sherpa_name=${uplane_sherpa_name}    source=${source}
    should contain    ${stop_status[1]}    Stop succeeded

Delete generated DCAP file
    csn.connect_to    hostname=${dcapuser_addr}    username=${dcapuser_username}    password=${dcapuser_password}    alias=DCAP
    run keyword and ignore error    csn.execute
    ...    command=sudo find ${pcap_path} -name \:\:ffff\:${WEBUI_ADDR}*.pcap |xargs rm -rf
    ...    connection=DCAP
    csn.disconnect    connection=DCAP
    sleep    2s

Connect to DCAP server and start udptracer
    csn.connect_to    hostname=${dcapuser_addr}    username=${dcapuser_username}    password=${dcapuser_password}    alias=DCAP
    csn.Execute    command=docker stop udptracer    connection=DCAP
    run keyword and ignore error    csn.execute
    ...    command=sudo find ${pcap_path} -name \:\:ffff\:${WEBUI_ADDR}*.pcap |xargs rm -rf
    ...    connection=DCAP
    sleep    5s
    ${res}   csn.Execute    command=docker start udptracer    connection=DCAP
    Should Contain   ${res}   udptracer
    csn.disconnect    connection=DCAP

Get current active version
    ${version}    wait until keyword succeeds    2min    30s    selenium_coam.check_current_software_version
    ${result}    split string    string=${version}[Active]    separator=_
    ${result1}    convert to integer    ${result}[-1]
    ${result2}    convert to integer    ${result}[-2]
    ${result3}    convert to integer    ${result}[-3]
    ${trunk_build}     convert to string    ${result}[-5]
    set suite variable    ${trunk_build}
    set suite variable    ${COAM_version}    ${version}[Active]
    set suite variable    ${SW_vesion}    ${result3}.${result2}.${result1}    

Delete local tti-decoder and trace file
    run keyword and ignore error    run    command=rm -rf ${tti-dec_file}
    run keyword and ignore error    run    command=rm -rf ${ttidecoder_path}
    run keyword and ignore error    run    command=rm -rf ${local_pcap_path}
    run keyword and ignore error    run    command=rm -rf ${decoded_file}

download logs from dcap to local
    [Arguments]    ${dcap_log_path}
    ${scp_command}  set variable  scp ${dcapuser_username}@${dcapuser_addr}:${dcap_log_path} ${OUTPUTDIR}/dcap_log.pcap
    Run Keyword And Ignore Error  run process    sshpass -p ${dcapuser_password} ${scp_command}  shell=yes
    sleep    15s
    ${local_pcap_path}    set variable    ${OUTPUTDIR}/dcap_log.pcap
    OperatingSystem.File Should Exist    ${local_pcap_path}
    [Return]    ${local_pcap_path}

Configure Logging Agent
    [Arguments]   ${uplane_destination}=${uplane_destination}   ${source_ip}=${WEBUI_ADDR}
    Run Keyword and Ignore Error   selenium_coam.deactivate_internal_trace
    selenium_coam.configure_logging_agent    source_ip=${WEBUI_ADDR}   vlan=${EMPTY}   dscp=${dscp}
    ...   cplane_destination=${EMPTY}   uplane_destination=${uplane_destination}
    Run Keyword and Ignore Error   selenium_coam.activate_internal_trace
    Log To Console   Logging Agent: ${WEBUI_ADDR}, DSCP: ${dscp}, Service: ${uplane_destination}

Get PCI id and MRBTS id
    ${MRBTS_ID}   selenium_coam.get_bts_id
    ${PCI_ID}   selenium_coam.get_parameter_value   dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    ...   filter_param=Physical cell identifier
    set suite variable    ${PCI_ID}
    set suite variable    ${MRBTS_ID}
