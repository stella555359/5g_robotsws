*** Settings ***
Library     taf.transport.ssh    WITH NAME    ssh
Resource    ../CUDU_L2/common_setup_teardown.robot

*** Variables ***
${BIP_NAME}           5GBipL2L1_filtering_off
${BIP_NAME_COVERT}    5GBipL2L1_filtering_off_filter

*** Keywords ***
Download LUA And Convert BIP And Check A2A
    [Arguments]    ${A2A_path}    ${INDEX}=0
    Download And Unzip Lua File    ${sw_version_total}
    ${covert_cmd}    Catenate    tshark -X lua_script:${output_dir}/generated_luashark/luashark.lua -r
    ...    ${output_dir}/${BIP_NAME}.pcap${INDEX} -V > ${output_dir}/${BIP_NAME}${INDEX}.txt
    Process.Run Process    ${covert_cmd}    shell=True
    Wireshark Filter Msg    ${output_dir}/${BIP_NAME}${INDEX}.txt
    ...    ${output_dir}/${BIP_NAME_COVERT}${INDEX}.txt    PdschSendReq|PuschReceiveReq|PdcchSendReq
    Set Test Variable    ${INDEX}    ${INDEX}
    Check Log With Au2anlysis    ${CURDIR}${/}${A2A_path}${/}a2a.ini    w    save_log_directory=${output_dir}

Convert BIP To CSV
    [Arguments]    ${bip_dir}    ${bip_tag_name}      
    ${filter}=    Set Variable    dldata_pdcchsendreq|| uldata_puschreceivereq||dldata_pdschsendreq
    @{csv_title_list}=    Create List      DlData_PdschGrant.numOfLayers    DlData_PdschGrant.tbSize_bits     3gpp.subcellid    
    Convert BIP To CSV By MCShark   ${bip_dir}/5GBipL2L1_filtering_off.pcap*    ${bip_dir}/Bip_${bip_tag_name}.csv    ${filter}    ${csv_title_list}