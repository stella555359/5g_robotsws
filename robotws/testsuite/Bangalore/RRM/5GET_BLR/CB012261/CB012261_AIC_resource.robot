*** Settings ***
Variables    ta5g_global_var

Resource       taf/rfrl/common_resources/robot/coam.robot
Resource       taf/rfrl/common_resources/robot/libraries_instances.robot
Library        ../resources/NPS/SWENG/python_libs/luashark_tools.py
Resource       ../resources/NPS/SWENG/robot/PacketSearch.robot
Resource       ../resources/robot/Setup_Env.robot
Resource       ../resources/robot/common_log_collection.robot
Resource        ../resources/ECEcommon/common_file_operation.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         ../resources/robot/TTI_Traces.robot
Resource         ../resources/robot/Iperf_Traffic.robot
Library          ../resources/python/ssh_command.py
Library        luashark_tools.analyzer       WITH NAME       analyzer
Library        taf.sbts.oam.coam.admin              WITH NAME   ute_adm
Library        taf.collectors.btslog  WITH NAME   btslog
Library        Collections
Library        OperatingSystem
Library        ta5g_tshark
Library        ta5g_commissioning
Library        taf.analyzer.pdml     WITH NAME    taf_pdml_analyser
Library        taf.transport.ssh                 WITH NAME    csn
Library           XML    use_lxml=True    WITH NAME    Myxml
Library         ./python/execute_command.py
Library         ./python/tti_utility.py
Library          ../resources/python/TTI_Converter.py    WITH NAME    TtiConvert
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Library          ./python/CB012261_Verification.py
Library          DateTime
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          ta_a2a

*** Variables ***
${enhancedSkipUplink_pattern}    *enhancedSkipUplinkTxConfigured-r16*
${RD_PARAM}          0x5901C9=1;0x600012=1;0x5901CA=0;0x190297=1;
${RD_PARAM_DIS}      0x5901C9=0;0x600012=0;0x5901CA=0;0x190297=0;
${UE_attach_pattern}    reported successful RA
${Bearer_ID2}          3
${delta_set_collecting_counters_to_five_minutes}=
    ...    /home/ute/Auto5G/testsuite/RRM/5G_SW_WRO/resources/config/5G21B/delta_set_collecting_counters_to_five_minutes.json
@{FIELDS_CellSetupReq}     cellBwpList_item_0     cellBwpList_item_1
${BIP_SCRIPT_PATH}      ${CURDIR}/../resources/NPS/SWENG/config/script
${WEBEM_USERNAME}      ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBEM_PASSWORD}      ${tl.gnbs[0].cu.oam_http_connection_details.password}

*** Keywords ***

Configure UTE ETH3 IPs
    [Documentation]    This keyword is to configure VM interfaces.
    Log To Console    configure VM interfaces...
    OperatingSystem.Run    sudo ip addr add 10.0.1.131/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.132/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.133/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.134/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.135/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.136/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.99/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.121/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.137/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.3/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.4/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.127/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.124/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.125/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.122/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.123/24 dev eth3

Configure in VM for RANK-4
    [Documentation]    This keyword is to configure RANK-4 in VM
    Log To Console    configure VM for RANK-4..
    OperatingSystem.Run    sudo sysctl -w net.core.wmem_max=20971520
    OperatingSystem.Run    sudo sysctl -w net.core.wmem_default=20971520
    OperatingSystem.Run    sudo sysctl -w net.core.rmem_max=20971520
    OperatingSystem.Run    sudo sysctl -w net.core.rmem_default=20971520

Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces
    [Arguments]    ${wts_cfg_file}
    Fetch board type
    Configure UTE ETH3 IPs
    Wait Until Keyword Succeeds    5min    20sec     Check gNB Airscale is Ready - ${BBoard_Type}
    ${oam_alias}=    Setup OAM session
    Wait Until Keyword Succeeds    10min    20sec    Verify Single Radio is Online      connection=${oam_alias}
    #${file_name}    set variable     NODECPRT_GNB_cellsetup.pcap
    Check gNB Airscale is Ready - ${BBoard_Type}

    Log To console     loading cfg file
    Start Log   btslog    cprt
    Start WTS Using WTS_Runner      ${wts_cfg_file}
    ${cprt_log_1}     Stop Log  cprt  test_scenario=cellsetup
    set suite variable    ${cprt_log_1}
    ${cell_sys_log}     Stop Log   btslog   test_scenario=cellsetup_sys
    set suite variable    ${cell_sys_log}

Load CFG Config And Capture CPRT Traces
    [Arguments]    ${wts_cfg_file}
    Fetch board type
    Configure UTE ETH3 IPs
    Wait Until Keyword Succeeds    5min    20sec     Check gNB Airscale is Ready - ${BBoard_Type}
    ${oam_alias}=    Setup OAM session
    Wait Until Keyword Succeeds    10min    20sec    Verify Single Radio is Online      connection=${oam_alias}
    Check gNB Airscale is Ready - ${BBoard_Type}
    Log To console     loading cfg file
    Start Log   btslog    cprt    bip
    Check Cell On Air      ${wts_cfg_file}
    ${log_path_1}     Stop Log    cprt    bip    btslog  test_scenario=cellsetup
    log to console      cprt-${log_path_1}
    set suite variable    ${log_path_1}

Load wts CFG Config And Capture CPRT Traces
    [Arguments]    ${wts_cfg_file}     ${start_cell}	${end_cell}
    Start CPRT capture
    Load CFG and verify cell status    ${wts_cfg_file}	 ${start_cell}	${end_cell}
    Stop CPRT capture common     log_dir=${LOG_PATH}

Perform SCF Delta Commissioning with ${delta_commissioning_file_json}
    Find Scfc And Send Delta Commissioning      scfc_filename=${delta_commissioning_file_json}

MultiUE Attach for NSA Old
    [Arguments]    ${start_ue_id}    ${stop_ue_id}    ${Target_Cell}     ${chk_fail}=${-1}
    ${nsa_rnti_list}      Create List
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
    LTE Attach should be Successful    ${ue_id}
    ${nsa_rnti}    NSA UE Attach    ${UE_ID}    ${Target_Cell}    chk_fail=${chk_fail}
    Append To List  ${nsa_rnti_list}   ${nsa_rnti}
    BuiltIn.Log     ${nsa_rnti_list}
    END
    [Return]    ${nsa_rnti_list}

MultiUE Register should be Successful fixed
    [Arguments]    ${start_ue_id}   ${end_ue_id}    ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA varianti
    ${crnti_list}       Create List
    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
    wtsrunner.ue_register   id=${ue_idx}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Create File	    ${OUTPUT_DIR}/regst.txt	    ${output}
    ${crnti_string}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk -F 'crnti:' '{print $2}'|cut -d ' ' -f 2
    Append To List  ${crnti_list}   ${crnti_string}
    BuiltIn.Log     ${crnti_string}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}
    wtsrunner.set_pdu_param     ue=${ue_idx}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_idx}    nwslice=${nw_id}    gw=${ue_idx}
    Read WTS Output For Pattern And Print matching Lines    ${Initial_context_setup_pattern}    ${Timeout_SA}
    Read WTS Output For Pattern And Print matching Lines    ${enhancedSkipUplink_pattern}    ${Timeout_SA}
#    ${rrc_rec}     Read WTS Output For Pattern And Print matching Lines    ${enhancedSkipUplink_pattern}    ${Timeout_SA}
#    Create File	    ${OUTPUT_DIR}/rrc_rec${ue_idx}.txt	    ${rrc_rec}
    Log to Console     ue=${ue_idx} with crnti=${crnti_string} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
    BuiltIn.Log        ue=${ue_idx} with crnti=${crnti_string} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
    END
    Log to Console             multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                CRntilist:${crnti_list}
    [Return]      ${crnti_list}

MultiUE PDU Modfication should be Successful deletion
    [Arguments]     ${start_ue_id}    ${end_ue_id}     ${pdu_id}=${Pdu_session_ID}      ${qosflows_to_del}=${Q_O_DEL}
	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    wtsrunner.ue_pdu_session_modify      ue=${ue_idx}       pdu=${pdu_id}    qosflows_to_del=${qosflows_to_del}    by=amf
    ${output}    Read WTS Output Until Pattern Matches    ${Pdu_session_qos_patten}     ${Timeout_SA}
    Print Matching Lines from Output File    ${output}    ${Pdu_session_mod_patten}
    BuiltIn.Log               ue=${ue_idx} qosflow=${qosflows_to_del} deleted
	Log to Console            ue=${ue_idx} qosflow=${qosflows_to_del} deleted
    END
    BuiltIn.Log       All_ue_deleted_an_extra_qosflow_successfully
	Log to Console    All_ue_deleted_an_extra_qosfl

Change IPHY File Value
    [Arguments]    ${RU_TYPE}   ${GSCN}
    ${file_path}    Get IPHY XML From Airphone    ${OUTPUT_DIR}
    ${c1}    Set Variable    cat ${file_path}|grep -m 1 "card"|awk -F'>' '{print $2 }'|awk -F '<' '{print $1}'|
    ${c2}    Set Variable    xargs -I {} sed -i 's/{}/${RU_TYPE}/g' ${file_path}
    Run    ${c1}${c2}

    ${c1}    Set Variable    cat ${file_path}|grep -m 1 "GSCN"|awk -F'>' '{print $2 }'|
    ${c2}    Set Variable    awk -F '<' '{print $1}'|xargs -I {} sed -i 's/{}/${GSCN}/g' ${file_path}
    Run    ${c1}${c2}
    Send IPHY XML To Airphone   ${file_path}
    Run    ssh toor4nsn@192.168.200.1 reboot
    sleep  120s

Change IPHY File Value AP ABIO
    [Arguments]    ${RU_TYPE}   ${GSCN}
#    ${OUTPUT_DIR}   Set variable    /home/ute/robotws
    ${file_path}    Get IPHY XML From Airphone    ${OUTPUT_DIR}

    ${targetbd_fn}=    Run      ssh toor4nsn@192.168.255.129 ls -ltr /ffs/run/|grep TargetBD.*xml$|awk '{ print $9 }'
    Run     scp toor4nsn@192.168.255.129:/ffs/run/${targetbd_fn} ${OUTPUT_DIR}
    Should Exist    ${OUTPUT_DIR}/${targetbd_fn}
    ${target_bd_path}    Set Variable    ${OUTPUT_DIR}/${targetbd_fn}

    ${c1}    Set Variable    cat ${file_path}|grep -m 1 "card"|awk -F'>' '{print $2 }'|awk -F '<' '{print $1}'|
    ${c2}    Set Variable    xargs -I {} sed -i 's/{}/${RU_TYPE}/g' ${file_path}
    Run    ${c1}${c2}

    ${c1}    Set Variable    grep -m 1 ${RU_TYPE}|awk -F resourceSWVersion= '{print $2}'|sed 's/"//g;s/>//g'
    ${new_version}    Run   cat ${target_bd_path}|${c1}
    log to console     ${new_version}
    ${c1}    Set Variable    cat ${file_path}|grep -m 1 '<version>'|awk -F '<version>' '{print $2}'|awk -F '</version>' '{print $1}'|
    ${c2}    Set Variable    xargs -I {} sed -i 's/{}/${new_version}/' ${file_path}
    Run     ${c1}${c2}

    ${c1}    Set Variable    cat ${file_path}|grep -m 1 "GSCN"|awk -F'>' '{print $2 }'|
    ${c2}    Set Variable    awk -F '<' '{print $1}'|xargs -I {} sed -i 's/{}/${GSCN}/g' ${file_path}
    Run    ${c1}${c2}

    ${x}   ${y}    get_board_type    192.168.200.1   22    toor4nsn    oZPS0POrRieRtu
    Run Keyword if    '${x}'=='ASIL' and '${y}'=='ABIO'
    ...    update_iphy_7145    ${file_path}
    sleep   4s
    Send IPHY XML To Airphone   ${file_path}
    Run    ssh toor4nsn@192.168.200.1 reboot
    sleep  125s

Change CFG File Value
    [Arguments]    ${file_path}    ${ul_arfcn}   ${dl_arfcn}    ${sa_cap}   ${nsa_nr_cap}   ${nsa_mrdc_cap}
    ${x}    Set Variable    nr_arfcn
    ${y}    Set Variable    nr_arfcn=
    ${z}    Catenate    SEPARATOR=:   ${ul_arfcn}   ${dl_arfcn}
    ${nsa_pat}  Set Variable       ue_eutra_nr_capabilities
    ${sa_pat}   Set Variable       ue_nr_capabilities


    ${c1}   Set Variable    cat ${file_path}|grep -m 1 "${x}"|awk -F'${y}' '{print $2 }'|
    ${c2}   Set Variable    awk -F ' ' '{print $1}'|xargs -I {} sed -i 's/{}/${z}/g' ${file_path}
    Run    ${c1}${c2}

    #Below is for SA cap changes
    ${c1}   Set Variable    cat ${file_path}|grep -m 1 "${sa_pat}"|awk -F'${sa_pat}=' '{print $2}'|
    ${c2}   Set Variable    xargs -I {} sed -i 's/{}/${sa_cap}/g' ${file_path}
    Run    ${c1}${c2}
    #Below is for NSA cap changes
    #NSA_UE_NR cap changes
    ${c1}   Set Variable    cat ${file_path}|grep -m 1 "${nsa_pat}"|awk -F'${SPACE}${SPACE}dual_conn=eutra_nr' '
    ${c2}   Set Variable    {print $1}'|awk -F'${sa_pat}=' '{print $2}'|
    ${c3}   Set Variable    xargs -I {} sed -i 's/{}/${nsa_nr_cap}/g' ${file_path}
    Run    ${c1}${c2}${c3}
    #NSA DC cap changes
    ${c1}   Set Variable    cat ${file_path}|grep -m 1 "${nsa_pat}"|awk -F'${nsa_pat}=' '{print $2}'|
    ${c2}   Set Variable    xargs -I {} sed -i 's/{}/${nsa_mrdc_cap}/g' ${file_path}
    Run     ${c1}${c2}

Change dl_ul arfcn in CFG File
    [Arguments]    ${file_path}    ${ul_arfcn}   ${dl_arfcn}
    ${x}    Set Variable    nr_arfcn
    ${y}    Set Variable    nr_arfcn=
    ${z}    Catenate    SEPARATOR=:   ${ul_arfcn}   ${dl_arfcn}
    ${nsa_pat}  Set Variable       ue_eutra_nr_capabilities
    ${sa_pat}   Set Variable       ue_nr_capabilities


    ${c1}   Set Variable    cat ${file_path}|grep -m 1 "${x}"|awk -F'${y}' '{print $2 }'|
    ${c2}   Set Variable    awk -F ' ' '{print $1}'|xargs -I {} sed -i 's/{}/${z}/g' ${file_path}
    Run    ${c1}${c2}

Simulate cqi
    [Documentation]    This keyword simulate csi_override testmode command
    [Arguments]    ${cqi}     ${prf_id}   ${start_ue_id}    ${end_ue_id}
    Introduce csi_override_cqi      ${cqi}    ${prf_id}
    Activate csi_override_for_UE     ${prf_id}    ${start_ue_id}    ${end_ue_id}

Introduce csi_override_cqi
    [Documentation]    This keyword introduces csi_override testmode command
    [Arguments]    ${cqi}    ${prf_id}
    wtsrunner.csi_override_testmode_nr    profile_id=${prf_id}   cqi=${cqi}     cqi_mode=fixed
    wtsrunner.csi_override_testmode_nr      profile_id=${prf_id}
    sleep    5s

Simulate bler_testmode
    [Documentation]    This keyword simulate csi_override testmode command
    [Arguments]    ${start_ue_id}    ${end_ue_id}
    Introduce bler_testmode
    Activate bler_testmode_for_UE        ${start_ue_id}    ${end_ue_id}

Introduce bler_testmode
    [Documentation]    This keyword introduces bler testmode command
    wtsrunner.bler_testmode_nr      profile_id=4        target_mcs=2        target_bler=100,100,100,95,90,50,10,1,0.5,0.1,0,0,0,0,0
    ...     mcs_table=qam64LowSE        rank=0
    wtsrunner.bler_testmode_nr      profile_id=4
    sleep    5s

Introduce pathloss
    [Arguments]    ${start_ue_id}    ${end_ue_id}
    FOR  ${ue_idx}   IN RANGE   ${start_ue_id}    ${end_ue_id}+1
    wtsrunner.ul_sinr_testmode_nr    profile_id=3    pathloss=75
    END

Activate pathloss_for_UE
    [Arguments]    ${start_ue_id}    ${end_ue_id}
    FOR  ${ue_idx}   IN RANGE   ${start_ue_id}    ${end_ue_id}+1
    wtsrunner.ue_testmode_set_nr        id=${ue_idx}     testmode=ul_sinr        profile_id=3        action=activate
    END

Vary pathloss
    [Arguments]    ${pathloss_start_dB}=75    ${pathloss_end_dB}=130    ${pathloss_step_dB}=1
    FOR    ${pathloss}    IN RANGE    ${pathloss_start_dB}    ${pathloss_end_dB}    ${pathloss_step_dB}
    wtsrunner.ul_sinr_testmode_nr    profile_id=3    pathloss=${pathloss}
    END

Deactivate pathloss_for_UE
    [Arguments]    ${start_ue_id}    ${end_ue_id}
    FOR  ${ue_idx}   IN RANGE   ${start_ue_id}    ${end_ue_id}+1
    wtsrunner.ue_testmode_set_nr        id=${ue_idx}     testmode=ul_sinr        profile_id=3        action=deactivate
    END

Activate bler_testmode_for_UE
    [Documentation]    This keyword activate bler testmode for n UEs
    [Arguments]    ${start_ue_id}    ${end_ue_id}
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    wtsrunner.ue_testmode_set_nr        id=${ue_idx}        scell=primary       testmode=bler       profile_id=4        action=activate
    END

Deactivate bler_testmode_for_UE
    [Documentation]    This keyword deactivate bler testmode for n UEs
    [Arguments]    ${start_ue_id}    ${end_ue_id}
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    wtsrunner.ue_testmode_set_nr        id=${ue_idx}        scell=primary       testmode=bler       profile_id=4        action=deactivate
    END

Activate csi_override_for_UE
    [Documentation]    This keyword activate csi_override testmode for n UEs
    [Arguments]    ${prf_id}    ${start_ue_id}    ${end_ue_id}
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    wtsrunner.ue_testmode_set_nr        id=${ue_idx}        scell=0       testmode=csi_override       profile_id=${prf_id}        action=activate
    END

Check MCShark Version
    [Arguments]    ${sw_version}=${SW_VERSION_TOTAL}
    ${list_version}=    Split String    ${sw_version}    _
    ${rest}    ${last}=    Split String From Right    ${sw_version}    _    1
    ${new_version}=    Set Variable If    "${list_version}[0]"!="SBTS00" and "${list_version}[-1]"!="000000"
    ...    ${rest}_000000      ${sw_version}
    [Return]    ${new_version}

Get Tshark Version
    ${version}=    Run    tshark -v|grep TShark|grep -P v[0-9]+.[0-9]+ -o|cut -d "v" -f 2
    [Return]    ${version}

Download MCShark To UTE
    [Arguments]    ${sw_version}=${SW_VERSION_TOTAL}
    ${sw_version}=    CB008927_resource.Check MCShark Version    ${sw_version}
    ${cmd}=    Set Variable    wget -r -np -nH ${MCSHARK_URL}/${sw_version}/
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    ${cmd}
    Should Be True    "${rc}"=="0"    There is no MCShark downloaded! Please contact MCshark team!
    ${tashark_version}=    Get Tshark Version
    ${MCShark}=    Run    ls -1t ${EXECDIR}/artifactory/wslte5g_plugins-local/MCShark/${sw_version}/mcshark-${tashark_version}*buster.so
    ${MCShark_list}=    String.Split To Lines    ${MCShark}
    ${MCShark_newest}=    Set Variable    @{MCShark_list}[0]
    OperatingSystem.Run    sudo rm -f ${MCSHARK_PLUGIN}/${tashark_version}/epan/mcshark-*buster.so
    ${rc}=    OperatingSystem.Run And Return Rc    sudo cp ${MCShark_newest} ${MCSHARK_PLUGIN}/${tashark_version}/epan/
    Should Be True    "${rc}"=="0"    No MCSHark file is copied to the wireshark plugin folder

Copy Preference For MCShark
    [Arguments]    ${preference_file}
    #${preference_file}=    Set Variable    /home/ute/Downloads/preferences
    Run    sudo cp ${preference_file} /home/ute/.config/wireshark/preferences
    Run    sudo cp ${preference_file} /usr/share/wireshark/preferences

Convert BIP To CSV By MCShark
    [Arguments]    ${bip_file}    ${output_file}    ${filter}    ${csv_title_list}
    [Documentation]    This keyword is to convert BIP log from pcap to csv
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${bip_log} | Yes | pcap bip log incloude bip log folder and bip log name |
    ...    | ${filter} | yes | the filter to filter the massage need to check |
    ...    | ${column_name} | yes | the column whose value need to check |
    ...    | ${csv_name_tag} | yes | the tag for BIP csv log name |

    #${tashark_version}=    Get Tshark Version
    ${mcshark_file}    Run    find /home/ute/ -name mcshark-*buster.so
    #${mcshark_file}    Set Variable    ${MCSHARK_PLUGIN}/${tashark_version}/epan/mcshark-*buster.so
    ${res}    Run Keyword And Return Status    OperatingSystem.Should Exist    ${mcshark_file}
    Run Keyword If    '${res}'=='False'    CB008927_resource.Download MCShark To UTE
    ${csv_title}=    Set Variable
    FOR    ${column}   IN    @{csv_title_list}
        ${csv_title}=    Set Variable    ${csv_title} -e ${column}
    END
    ${cmd}=    Catenate    tshark -r ${bip_file} -Y '${filter}' -T fields -e _ws.col.No. -e _ws.col.Info
    ...    ${csv_title} -E header=y -E separator=, -E quote=d -E occurrence=a > ${output_file}
    OperatingSystem.Run    ${cmd}
    OperatingSystem.File Should Not Be Empty    ${output_file}    msg=No CSV file is converted! Please check whether filter message name is changed!

Modify NIDD parameters
    [Documentation]      This Keyword modify NIDD parameter as per the requirement of the feature
    [Arguments]      ${paramName}='None'      ${paramValue}='None'       ${operation}=update      ${paramDst}='None'
    Log to Console      Modifying NIDD parameters
    admin.Setup admin
    Online NIDD parameter change    paramName=${paramName}         paramValue=${paramValue}        operation=${operation}
    ...                             paramDst=${paramDst}
    sleep               3s
    [Teardown]          admin.Teardown admin

Online NIDD parameter change
     [Documentation]    This Keyword used to update NIDD parameter(one at a time)
     ...                and returns the result
     ...        [Arguments]    parameter        :  Parameter names to parsed
     ...                       paramDst         :  Dist name should be parsed
     ...                       paramValue       :  Value for the parameter to be assigned should be parsed
     ...                       operation        :  Deffault Value given as update, and can be parsed other operation if required
     ...                       should_activate  :  Deffault Value is True if you want to set this False then parse the parameter as False
     ...                       skip_parameter_relation_errors : Default Value is True if you want to set this False then parse the parameter as False
     [Arguments]        ${paramName}='None'                 ${paramValue}='None'              ${timeout}=300
     ...                ${paramDst}='None'                  ${operation}=update
     ...                ${should_activate}=${True}          ${skip_parameter_relation_errors}=${True}
    admin.perform_parameter_recommissioning          parameter=${paramName}
     ...        value=${paramValue}             operation=${operation}                         dist_name=${paramDst}
     ...        skip_parameter_relation_errors=${skip_parameter_relation_errors}
     ...        should_activate=${should_activate}

Check Cell On Air
    [Arguments]             ${wts_cfg_file}
    Stop Edaemon and Egate process
    Stop Sim_enb
    run    command=sudo rm -rf ${WTS_DIR}/*.log.*
    Connect To WTS VM
    wtsrunner.configure_wtsemu_edaemon    edaemon_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=22222
    ...                                   sudo_password=ute
    wtsrunner.configure_wtsemu_egate      egate_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=20000
    wtsrunner.start_wtsemu                egate_console_ip=${WTS.Ip}
    ...                                   egate_port=20000
    wtsrunner.configure                   file=${wts_cfg_file}
#    wtsrunner.read_wtsemu_output_until_re    expected=Airphone: Cell Setup completed     timeout=240
    wtsrunner.read_wtsemu_output_until_re    expected=UEC-1: eNB 2 cell 1: SystemInformationBlockType4-NR updated     timeout=240


Verify rat1_active
    [Arguments]     ${log_path}     ${packet}     ${ratalloc}
    Log To console   ${log_path}
    Log To console   ${packet}
    Log To console   ${ratalloc}
    ${pdmlFile}    analyzer.pcap_to_pdml      ${log_path}/NODECPRT_GNB.pcap       itf_l2_ps_cell_cellsetupreq

    ${var}      analyzer.get_shownames       pdmlFile=${pdmlFile}
    ...      packetName=${packet}
    ...      path=${ratalloc}

    Should Contain    ${var[${0}]}     True


Verify rat1_inactive
    [Arguments]    ${log_path}   ${packet}    ${ratalloc}
    ${pdmlFile}    analyzer.pcap_to_pdml      ${log_path}/NODECPRT_GNB.pcap       itf_l2_ps_cell_cellsetupreq

    ${var}      analyzer.get_shownames       pdmlFile=${pdmlFile}
    ...      packetName=${packet}
    ...      path=${ratalloc}

    Should Contain    ${var[${0}]}     False


Change IPHY File Value LOAPLO 4cells FDD 35MHZ
    [Arguments]    ${RU_TYPE}   ${GSCN}
#    ${OUTPUT_DIR}   Set variable    /home/ute/robotws
    ${file_path}    Get IPHY XML From Airphone    ${OUTPUT_DIR}

    ${targetbd_fn}=    Run      ssh toor4nsn@192.168.255.129 ls -ltr /ffs/run/|grep TargetBD_SBTS.*xml$|awk '{ print $9 }'
    Run     scp toor4nsn@192.168.255.129:/ffs/run/${targetbd_fn} ${OUTPUT_DIR}
    Should Exist    ${OUTPUT_DIR}/${targetbd_fn}
    ${target_bd_path}    Set Variable    ${OUTPUT_DIR}/${targetbd_fn}

    ${c1}    Set Variable    cat ${file_path}|grep -m 1 "AHLOA"|awk -F'>' '{print $2 }'|awk -F '<' '{print $1}'|
    ${c2}    Set Variable    xargs -I {} sed -i 's/{}/${RU_TYPE}/g' ${file_path}
    Run    ${c1}${c2}

    ${c1}    Set Variable    grep -m 1 ${RU_TYPE}|awk -F resourceSWVersion= '{print $2}'|sed 's/"//g;s/>//g'
    ${new_version}    Run   cat ${target_bd_path}|${c1}

    log to console     ${new_version}
    ${c1}    Set Variable    cat ${file_path}|grep -m 1 '<version>RF.FRM'|awk -F '<version>' '{print $2}'|awk -F '</version>' '{print $1}'|
    ${c2}    Set Variable    xargs -I {} sed -i 's/{}/${new_version}/' ${file_path}
    Run     ${c1}${c2}

    ${a}    Set Variable    grep -m 1 '<swFileKey>LTX_${RU_TYPE}'|awk -F '<swFileKey>' '{print $2}'|awk -F '</swFileKey>' '{print $1}'
    ${swFileKey}     OperatingSystem.Run     cat ${target_bd_path}|${a}
    log to console     swFileKey-${swFileKey}

    ${x}    Set Variable    cat ${file_path}|grep -m 1 '<name>FRM'|awk -F '<name>' '{print $2}'|awk -F '</name>' '{print $1}'|
    ${y}    Set Variable    xargs -I {} sed -i 's/{}/${swFileKey}/' ${file_path}
    log to console     ${x}${y}
    Run     ${x}${y}

    ${c1}    Set Variable    cat ${file_path}|grep -m 1 "1582"|awk -F'>' '{print $2 }'|
    ${c2}    Set Variable    awk -F '<' '{print $1}'|xargs -I {} sed -i 's/{}/${GSCN}/g' ${file_path}
    Run    ${c1}${c2}

    ${x}   ${y}    ssh_command.get_board_type    192.168.200.1   22    toor4nsn    oZPS0POrRieRtu
    Run Keyword if    '${x}'=='ASIL' and '${y}'=='ABIO'
    ...    ssh_command.update_iphy_7145    ${file_path}
    sleep   4s
    Send IPHY XML To Airphone   ${file_path}
    Run    ssh toor4nsn@192.168.200.1 reboot
    sleep  125s


Rat1 Allocation Verification
    [Arguments]    ${filepath}    ${physcellid}
    log to console    filepath-${filepath}
    log to console    physcellid-${physcellid}
    ${result}    verify_rat1_alocation    ${filepath}    ${physcellid}
    Should Contain    ${result}    Pass

Common TTI PCAP to CSV Converter
    [Arguments]    ${ttitrace_path}    ${dir}=dl
    ${tti_path}      Set Variable     ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${ttitrace_path}
    ${tti_file_size}    Get File Size    ${tti_path}/tcpdump_ttitrace.pcap
    Run Keyword If  ${tti_file_size} <= 60000000
    ...   Decode TTI Trace    ${ttitrace_path}
    ...   ELSE
    ...   Decode TTI Trace For Large File Size    ${ttitrace_path}  ${dir}

Decode TTI Trace For Large File Size
    [Arguments]    ${ttitrace_path}  ${dir}
    Dated Log                        converting large ttitrace pcap to csv
    ${tti_path}      Set Variable     ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${ttitrace_path}
    run     /sbin/tcpdump -r ${tti_path}/tcpdump_ttitrace.pcap -w ${tti_path}/tti_split.pcap -C 22
    ${files}    OperatingSystem.List Files In Directory     ${tti_path}     tti_split.*
    log to console    file_list-${files}
    ${count}    Count Files In Directory    ${tti_path}     tti_split.*
    log to console    file_count-${count}
    FOR    ${i}  IN RANGE   0   ${count}
    Run keyword if  ${i}!=0 and 'tti_split.pcap${i}' in ${files}
    ...    run     mv ${tti_path}/tti_split.pcap${i} ${tti_path}/tti_split_${i}.pcap
    ...    ELSE
    ...    run     mv ${tti_path}/tti_split.pcap ${tti_path}/tti_split_${i}.pcap
    Dated Log         converting ${tti_path}/tti_split_${i}.pcap to ${tti_path}/output_${dir}_formated_${i}.csv
    Common Convert Ttitrace From Pcap To Excelcsv        ${tti_path}    filename=tti_split_${i}.pcap
    Common Format Tti In Stream Mode         ${tti_path}/output_${dir}.csv     ${tti_path}/output_${dir}_formated_${i}.csv
    run     rm ${tti_path}/tti_split_${i}.pcap
    END
    merge_multiple_csv      ${tti_path}   ${dir}

Decode TTI Trace For Large File Size old
    [Arguments]    ${ttitrace_path}
    Dated Log                        converting large ttitrace pcap to csv
    ${tti_path}      Set Variable     ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${ttitrace_path}
    run     /sbin/tcpdump -r ${tti_path}/tcpdump_ttitrace.pcap -w ${tti_path}/tti_split.pcap0 -C 10
    @{files}    List Files In Directory     ${tti_path}     tti_split.*
    Sort List   @{files}
    log to console    file_list-@{files}
    ${count}    Count Files In Directory    ${tti_path}     tti_split.*
    log to console    file_count-${count}
    FOR    ${i}  IN RANGE   0   ${count}
    run     cp ${tti_path}/${files}[${i}] ${tti_path}/tti_split_${i}.pcap
    Dated Log                        converting ${tti_path}/tti_split_${i}.pcap to csv
    Common Convert Ttitrace From Pcap To Excelcsv        ${tti_path}    filename=tti_split_${i}.pcap
    Common Format Tti In Stream Mode         ${tti_path}/output_dl.csv     ${tti_path}/output_dl_formated_${i}.csv
    Common Format Tti In Stream Mode         ${tti_path}/output_ul.csv     ${tti_path}/output_ul_formated_${i}.csv
    run     rm ${tti_path}/${files}[${i}];rm ${tti_path}/tti_split_${i}.pcap
    END
    merge_multiple_csv      ${tti_path}
    run     rm ${tti_path}/output_dl_formated_*.csv;rm ${tti_path}/output_ul_formated_*.csv
#    Run keyword if  '${dir}'=='both'
#    ...    Run keywords
#    ...    Common Format Tti In Stream Mode         ${tti_path}/output_dl.csv     ${tti_path}/output_dl_formated_${i}.csv
#    ...    AND
#    ...    Common Format Tti In Stream Mode         ${tti_path}/output_ul.csv     ${tti_path}/output_ul_formated_${i}.csv
#    ...    AND
#    ...    run     rm ${tti_path}/tti_split_${i}.pcap
#    Run keyword if    '${dir}'=='dl'
#    ...    Run keywords
#    ...    Common Format Tti In Stream Mode         ${tti_path}/output_dl.csv     ${tti_path}/output_dl_formated_${i}.csv
#    ...    AND
#    ...    run     rm ${tti_path}/tti_split_${i}.pcap
#    Run keyword if    '${dir}'=='ul'
#    ...    Run keywords
#    ...    Common Format Tti In Stream Mode         ${tti_path}/output_ul.csv     ${tti_path}/output_ul_formated_${i}.csv
#    ...    AND
#    ...    run     rm ${tti_path}/tti_split_${i}.pcap

Read Cellsetup msg for uplink 1cell
    [Arguments]    ${cprt_path}     ${cellid1}     ${cellid2}
    ${x}    Set Variable    itf_l2_ps_cell_CellSetupReq_t.physCellId==${cellid1}
    ${y}    Set Variable    itf_l2_ps_cell_CellSetupReq_t.physCellId==${cellid2}
    ${pdmlFile}    analyzer.pcap_to_pdml        ${cprt_path}/NODECPRT_GNB.pcap         ${x}
	${pdmlFile2}    analyzer.pcap_to_pdml        ${cprt_path}/NODECPRT_GNB.pcap         ${y}
	${z}    Set Variable    UlCell_SetupReq_t.physCellId==${cellid1}
	${pdmlFile3}    analyzer.pcap_to_pdml        ${cprt_path}/NODECPRT_GNB.pcap         ${z}
#Verify from CPRT to L2PS
	${l2_flag1}      analyzer.get_shownames         pdmlFile=${pdmlFile}
    ...                                        packetName=itf_l2_ps_cell_cellsetupreq
    ...                                        kind=show
    ...                                        path=itf_l2_ps_cell_CellSetupReq_t.actPrachMultiplexingLevel$
    ...                                        endPacket=1
    Should Contain      ${l2_flag1}        1
#Verify from CPRT to L1
	${l1_flag}      analyzer.get_shownames         pdmlFile=${pdmlFile3}
    ...                                        packetName=UlCell_SetupReq_t
    ...                                        kind=show
    ...                                        path=UlCell_SetupReq_t.actPrachMultiplexingLevel$
    ...                                        endPacket=1
    Should Contain      ${l1_flag}        1

    ${chk_pucch}      analyzer.count_path     pdmlFile=${pdmlFile}
    ...                                                packetName=itf_l2_ps_cell_cellsetupreq
    ...                                                path=itf_l2_ps_cell_BwpDefinitionUl.longPucchStartPuschPrb_item$

    ${pucch_format}     Run Keyword If  ${chk_PUCCH} == 0	    Set Variable         short
    ...   ELSE       Set Variable         long

    ${short_bwp_numofprb}      Run Keyword If  '${pucch_format}' == 'short'         analyzer.get_shownames         pdmlFile=${pdmlFile}
    ...                                        packetName=itf_l2_ps_cell_cellsetupreq
    ...                                        kind=show
    ...                                        path=itf_l2_ps_cell_BwpDefinitionUl.bandwidth$
    ...                                        endPacket=1

    ${long_bwp_start}      Run Keyword If  '${pucch_format}' == 'long'               analyzer.get_shownames         pdmlFile=${pdmlFile}
    ...                                        packetName=itf_l2_ps_cell_cellsetupreq
    ...                                        kind=show
    ...                                        path=itf_l2_ps_cell_BwpDefinitionUl.longPucchStartPuschPrb_item$
    ...                                        endPacket=1

    ${long_bwp_numofprb}      Run Keyword If  '${pucch_format}' == 'long'               analyzer.get_shownames         pdmlFile=${pdmlFile}
    ...                                        packetName=itf_l2_ps_cell_cellsetupreq
    ...                                        kind=show
    ...                                        path=itf_l2_ps_cell_BwpDefinitionUl.longPucchNumPuschPrb_item$
    ...                                        endPacket=1

    ${pusch_BW}         Run Keyword If  '${pucch_format}' == 'long'         Calculate uplink bw      ${long_bwp_start}      ${long_bwp_numofprb}
    ...   ELSE       convert to integer    ${short_bwp_numofprb}[1]

    ${prach_prb_off}      analyzer.get_shownames         pdmlFile=${pdmlFile}
    ...                                        packetName=itf_l2_ps_cell_cellsetupreq
    ...                                        kind=show
    ...                                        path=.*prachPrbOffset$
    ...                                        endPacket=1
    ${prach_prb_off}      convert to integer    ${prach_prb_off}[0]

    ${msg1fdm_int}      analyzer.get_shownames         pdmlFile=${pdmlFile}
    ...                                        packetName=itf_l2_ps_cell_cellsetupreq
    ...                                        kind=show
    ...                                        path=.*msg1Fdm$
    ...                                        endPacket=1
#    msg1Fdm (itf_l2_ps_Msg1Fdm): one (0)    pcap format
    ${msg1fdm_int}      convert to integer      ${msg1fdm_int}[0]
    ${msg1fdm}      Run Keyword If  ${msg1fdm_int} == 0 	    Set Variable             ${1}

    [return]    ${pusch_BW}    ${prach_prb_off}      ${msg1fdm}

Read Cellsetup msg for uplink
    [Arguments]    ${cprt_path}     ${cellid1}     ${cellid2}      ${pusch}=static
    ${cell1_l2}    Set Variable    itf_l2_ps_cell_CellSetupReq_t.physCellId==${cellid1}
    ${cell2_l2}    Set Variable    itf_l2_ps_cell_CellSetupReq_t.physCellId==${cellid2}
	${cell1_l1}    Set Variable    UlCell_SetupReq_t.physCellId==${cellid1}

#	${pdmlFile}    analyzer.pcap_to_pdml        ${cprt_path}/NODECPRT_GNB.pcap         ${cell1_l2}
#	${pdmlFile2}    analyzer.pcap_to_pdml        ${cprt_path}/NODECPRT_GNB.pcap         ${cell2_l2}
#	${pdmlFile3}    analyzer.pcap_to_pdml        ${cprt_path}/NODECPRT_GNB.pcap         ${cell1_l1}

    ${pdmlFile}    analyzer.pcap_to_pdml        ${cprt_path}        ${cell1_l2}
	${pdmlFile2}    analyzer.pcap_to_pdml        ${cprt_path}       ${cell2_l2}
	${pdmlFile3}    analyzer.pcap_to_pdml        ${cprt_path}        ${cell1_l1}
##Verify from CPRT to L2PS
#	${l2_flag1}      analyzer.get_shownames         pdmlFile=${pdmlFile}
#    ...                                        packetName=itf_l2_ps_cell_cellsetupreq
#    ...                                        kind=show
#    ...                                        path=itf_l2_ps_cell_CellSetupReq_t.actPrachMultiplexingLevel$
#    ...                                        endPacket=1
#    Should Contain      ${l2_flag1}        1
#	${l2_flag2}      analyzer.get_shownames         pdmlFile=${pdmlFile2}
#    ...                                        packetName=itf_l2_ps_cell_cellsetupreq
#    ...                                        kind=show
#    ...                                        path=itf_l2_ps_cell_CellSetupReq_t.actPrachMultiplexingLevel$
#    ...                                        endPacket=1
#    Should Contain      ${l2_flag2}        0
##Verify from CPRT to L1
#	${l1_flag}      analyzer.get_shownames         pdmlFile=${pdmlFile3}
#    ...                                        packetName=UlCell_SetupReq_t
#    ...                                        kind=show
#    ...                                        path=UlCell_SetupReq_t.actPrachMultiplexingLevel$
#    ...                                        endPacket=1
#    Should Contain      ${l1_flag}        1

    ${chk_pucch}      analyzer.count_path     pdmlFile=${pdmlFile}
    ...                                                packetName=itf_l2_ps_cell_cellsetupreq
    ...                                                path=itf_l2_ps_cell_BwpDefinitionUl.longPucchStartPuschPrb_item$

    ${pucch_format}     Run Keyword If  ${chk_PUCCH} == 0	    Set Variable         short
    ...   ELSE       Set Variable         long

    ${short_bwp_numofprb}      Run Keyword If  '${pucch_format}' == 'short'         analyzer.get_shownames         pdmlFile=${pdmlFile}
    ...                                        packetName=itf_l2_ps_cell_cellsetupreq
    ...                                        kind=show
    ...                                        path=itf_l2_ps_cell_BwpDefinitionUl.bandwidth$
    ...                                        endPacket=1

    ${long_bwp_start}      Run Keyword If  '${pucch_format}' == 'long' and '${pusch}' == 'static'
    ...         analyzer.get_shownames         pdmlFile=${pdmlFile}
    ...                                        packetName=itf_l2_ps_cell_cellsetupreq
    ...                                        kind=show
    ...                                        path=itf_l2_ps_cell_BwpDefinitionUl.longPucchStartPuschPrb_item$
    ...                                        endPacket=1

    ${long_bwp_numofprb}      Run Keyword If  '${pucch_format}' == 'long' and '${pusch}' == 'static'
    ...         analyzer.get_shownames         pdmlFile=${pdmlFile}
    ...                                        packetName=itf_l2_ps_cell_cellsetupreq
    ...                                        kind=show
    ...                                        path=itf_l2_ps_cell_BwpDefinitionUl.longPucchNumPuschPrb_item$
    ...                                        endPacket=1

    ${long_bwp_start_dyn}      Run Keyword If  '${pucch_format}' == 'long' and '${pusch}' == 'dynamic'
    ...         analyzer.get_shownames         pdmlFile=${pdmlFile}
    ...                                        packetName=itf_l2_ps_cell_cellsetupreq
    ...                                        kind=show
    ...                                        path=itf_l2_ps_cell_BwpDefinitionUl.longPucchStartDynPuschPrb_item$
    ...                                        endPacket=1

    ${long_bwp_numofprb_dyn}      Run Keyword If  '${pucch_format}' == 'long' and '${pusch}' == 'dynamic'
    ...         analyzer.get_shownames         pdmlFile=${pdmlFile}
    ...                                        packetName=itf_l2_ps_cell_cellsetupreq
    ...                                        kind=show
    ...                                        path=itf_l2_ps_cell_BwpDefinitionUl.longPucchNumDynPuschPrb_item$
    ...                                        endPacket=1

    ${pusch_BW}         Run Keyword If  '${pucch_format}' == 'long' and '${pusch}' == 'static'
    ...              Calculate uplink bw      ${long_bwp_start}      ${long_bwp_numofprb}
    ...   ELSE       Run Keyword If  '${pucch_format}' == 'long' and '${pusch}' == 'dynamic'
    ...              Calculate uplink bw dynamic      ${long_bwp_start_dyn}      ${long_bwp_numofprb_dyn}
    ...   ELSE       convert to integer    ${short_bwp_numofprb}[1]

    ${prach_prb_off1}      analyzer.get_shownames         pdmlFile=${pdmlFile}
    ...                                        packetName=itf_l2_ps_cell_cellsetupreq
    ...                                        kind=show
    ...                                        path=.*prachPrbOffset$
    ...                                        endPacket=1
    ${prach_prb_off1}      convert to integer    ${prach_prb_off1}[0]

    ${prach_prb_off2}      analyzer.get_shownames         pdmlFile=${pdmlFile2}
    ...                                        packetName=itf_l2_ps_cell_cellsetupreq
    ...                                        kind=show
    ...                                        path=.*prachPrbOffset$
    ...                                        endPacket=1
    ${prach_prb_off2}      convert to integer    ${prach_prb_off2}[0]

    ${prach_prb_off}        Create Dictionary        ${cellid1}=${prach_prb_off1}          ${cellid2}=${prach_prb_off2}

    ${msg1fdm_int}      analyzer.get_shownames         pdmlFile=${pdmlFile}
    ...                                        packetName=itf_l2_ps_cell_cellsetupreq
    ...                                        kind=show
    ...                                        path=.*msg1Fdm$
    ...                                        endPacket=1
#    msg1Fdm (itf_l2_ps_Msg1Fdm): one (0)    pcap format
    ${msg1fdm_int}      convert to integer      ${msg1fdm_int}[0]
    ${msg1fdm}      Run Keyword If  ${msg1fdm_int} == 0 	    Set Variable             ${1}

    [return]    ${pusch_BW}    ${prach_prb_off}      ${msg1fdm}

Calculate uplink bw
    [Arguments]    ${long_bwp_start}        ${long_bwp_numofprb}
    ${long_bwp_start}      convert to integer        ${long_bwp_start}[1]
    ${long_bwp_numofprb}      convert to integer      ${long_bwp_numofprb}[1]
    ${BW}         Evaluate     ${long_bwp_start}+${long_bwp_numofprb}
    [return]    ${BW}

Calculate uplink bw dynamic
    [Arguments]    ${long_bwp_start}        ${long_bwp_numofprb}
    ${long_bwp_start}      convert to integer        ${long_bwp_start}[0]
    ${long_bwp_numofprb}      convert to integer      ${long_bwp_numofprb}[0]
    ${BW}         Evaluate     ${long_bwp_start}+${long_bwp_numofprb}
    [return]    ${BW}

MultiUE Attach for NSA
    [Arguments]    ${start_ue_id}    ${stop_ue_id}  ${Trgt_Cell}=${Target_Cells}
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
    LTE Attach should be Successful    ${ue_id}
    UE Attach should be Successful     ${ue_id}     ${Trgt_Cell}
    END

MultiUE SgNB addtion for NSA
    [Arguments]    ${start_ue_id}    ${stop_ue_id}  ${Trgt_Cell}=${Target_Cells}
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
    UE Attach should be Successful     ${ue_id}     ${Trgt_Cell}
    END

MultiUE DL Traffic Start for NSA
    [Arguments]    ${start_ue_id}    ${stop_ue_id}    ${Traffic_rate}    ${dl_rate}    ${id}=${Bearer_ID}    ${trf_id}=${TRF_ID}
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
    Trigger DL Traffic for NSA    ${ue_id}    ${Traffic_rate}    ${dl_rate}    id=${Bearer_ID}    trf_id=${TRF_ID}
    END

MultiUE UL Traffic Start for NSA
    [Arguments]    ${start_ue_id}    ${stop_ue_id}    ${Traffic_rate}    ${ul_rate}    ${id}=${Bearer_ID}    ${trf_id}=${TRF_ID}
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
    Trigger UL Traffic for NSA    ${ue_id}    ${Traffic_rate}    ${ul_rate}    id=${Bearer_ID}    trf_id=${TRF_ID}
    END

MultiUE DL Traffic Stop for NSA
    [Arguments]    ${start_ue_id}    ${stop_ue_id}    ${Bearer_ID}    ${trf_id}
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
    TRF Data Stop for NSA    ${ue_id}    ${Bearer_ID}    dl    ${trf_id}
    END

MultiUE UL Traffic Stop for NSA
    [Arguments]    ${start_ue_id}    ${stop_ue_id}    ${Bearer_ID}    ${trf_id}
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
    TRF Data Stop for NSA    ${ue_id}    ${Bearer_ID}    ul    ${trf_id}
    END

MultiUE Detach for NSA
    [Arguments]    ${start_ue_id}    ${stop_ue_id}
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
    UE Detach should be Successful    ${ue_id}
    END

Validate PRACH_PM_Counters
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}    ${moc}
    PM_Counters.Check PM counter value equal or bigger than    expected_value=${expected_value}   pm_files_location=${PM_dir}
    ...  pi_id=${PM_counter}    moc=${moc}

Verify PRACH_PM_Counters
    [Arguments]     ${EXPECTED_PCELL_VALUE}
    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER8}       expected_value=${EXPECTED_PCELL_VALUE}
    ...     moc=NRCELL-2
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER11}       expected_value=${EXPECTED_PCELL_VALUE}
    ...     moc=NRCELL-2
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER12}       expected_value=${EXPECTED_PCELL_VALUE}
    ...     moc=NRCELL-2
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER14}       expected_value=${EXPECTED_PCELL_VALUE}
    ...     moc=NRCELL-2
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER15}       expected_value=${EXPECTED_PCELL_VALUE}
    ...     moc=NRCELL-2
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER17}       expected_value=${EXPECTED_PCELL_VALUE}
    ...     moc=NRCELL-2
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER18}       expected_value=${EXPECTED_PCELL_VALUE}
    ...     moc=NRCELL-2
    Validate PM Counters_pcell_scell    PM_dir=${l}    PM_counter=${PM_PCELL_COUNTER19}       expected_value=${EXPECTED_PCELL_VALUE}
    ...     moc=NRCELL-2
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER20}       expected_value=${EXPECTED_PCELL_VALUE}
    ...     moc=NRCELL-2
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER21}       expected_value=${EXPECTED_PCELL_VALUE}
    ...     moc=NRCELL-2
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER22}       expected_value=${EXPECTED_PCELL_VALUE}
    ...     moc=NRCELL-2


Lock_cell and deactivate CB012261
    [Arguments]        ${paramDstName}=MRBTS-1/NRBTS-1/NRCELL-1         ${operation}=update
    log to console   Locking NRCELL-1 and deactivating CB012261 now...
    ${nidd_param}=      Create Dictionary      administrativeState=Locked
    ...                                        actPrachMultiplexingLevel=enabled_Level1
    FOR    ${key}   IN    @{nidd_param}
    Modify NIDD parameters        ${key}     ${nidd_param.${key}}     ${operation}    ${paramDstName}
    END
    sleep     60s

Unlock_cell
    [Arguments]        ${paramDstName}=MRBTS-1/NRBTS-1/NRCELL-1         ${operation}=update
    log to console   Unlocking NRCELL-1 now...
    ${nidd_param}=      Create Dictionary      administrativeState=Unlocked
    FOR    ${key}   IN    @{nidd_param}
    Modify NIDD parameters        ${key}     ${nidd_param.${key}}     ${operation}    ${paramDstName}
    END
    sleep     60s

Lock_cell and activate CB012261
    [Arguments]        ${paramDstName}=MRBTS-1/NRBTS-1/NRCELL-1         ${operation}=update
    log to console   Locking NRCELL-1 and activating CB012261 now...
    ${nidd_param}=      Create Dictionary      administrativeState=Locked
    ...                                        actPrachMultiplexingLevel=enabled_Level1
    FOR    ${key}   IN    @{nidd_param}
    Modify NIDD parameters        ${key}     ${nidd_param.${key}}     ${operation}    ${paramDstName}
    END
    sleep     60s

MultiUE attach dettach
    FOR    ${x}    IN RANGE    1     1001
    wtsrunner.ue_register   id=2
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    sleep     60ms
    wtsrunner.ue_deregister  id=2    ue_deregister_type=switch_off
    sleep     1s
    END

MultiUE Trigger UL Traffic for SA with duration
    [Arguments]    ${start_ue_id}    ${end_ue_id}    ${Traffic_rate}    ${ul_rate}    ${duration}   ${pdu_id}=${Pdu_session_ID}
    ...     ${trf_id}=${TRF_ID}    ${qfi_id}=${QFI_ID}
    [Documentation]    This keyword starts the DL Traffic for the SA variant
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Log to Console    \nRunning UL Traffic for ${ul_rate} ${Traffic_rate}...
    wtsrunner.trf_data_start     ue=${ue_idx}    pdu=${pdu_id}   qfi=${qfi_id}    dir=ul    trf_id=${trf_id}      ${Traffic_rate}=${ul_rate}
    ...         seconds=${duration}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Uplink Internal traffic*    timeout=10
#    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    ${output}         Get Lines Matching Regexp    ${output}    UDP UL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
	END
    BuiltIn.Log    UL_traffic_data_is_started_successfully

Trigger UL Traffic for NSA with duration
    [Arguments]      ${start_ue_id}       ${end_ue_id}    ${Traffic_rate}     ${ul_rate}     ${duration}
    ...       ${id}=${Bearer_ID}    ${trf_id}=${TRF_ID}
    [Documentation]    This keyword starts the UL Traffic for the NSA variant
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Log to Console    \nRunning UL Traffic for ${ul_rate} ${Traffic_rate}...
    wtsrunner.trf_data_start     ue=${ue_idx}    id=${id}   dir=ul    trf_id=${trf_id}     ${Traffic_rate}=${ul_rate}
    ...         seconds=${duration}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=UDP.*    timeout=10
#    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    ${output}         Get Lines Matching Regexp    ${output}    UDP UL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
    END
    BuiltIn.Log    UL_traffic_data_is_started_successfully

Validate SA UL Traffic
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. UL/DL Bytes Received must be equal to ALL Bytes Sent
    [Arguments]    ${ue_id}     ${rate}    ${call_dur}    ${dir}=ul    ${data_unit}=mbps   ${pdu_id}=${Pdu_session_ID}    ${qfi_id}=${QFI_ID}

    wtsrunner.bearer_stats  ue=${ue_id}   pdu=${pdu_id}   qfi=${qfi_id}   dir=${dir}
    ${bearer_stat}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    ${tp}      Check Average Data Rate     ${bearer_stat}    ${dir}    ${rate}    ${data_unit}    ${call_dur}
    Log to Console     UE${ue_id} ${dir} Throughput: ${tp} ${data_unit}
    [Return]    ${tp}

Check Average Data Rate
    [Arguments]    ${bearer_stat}    ${dir}    ${mbps}      ${data_rate}    ${call_dur}

    ${speed}         Set variable if      '${data_rate}' == 'mbps'      ${1048576}      ${1024}
    ${rcv_bytes}     Get Regexp Matches    ${bearer_stat}    Bytes received +(\\d+)    1
    ${sent_byts}     Get Regexp Matches    ${bearer_stat}    Bytes sent +(\\d+)    1
    Run Keyword And Ignore Error
    ...     Should be equal     ${rcv_bytes[0]}    ${sent_byts[0]}      receive bytes equal to sent bytes
    ${rcv_bits}       Evaluate      ((float(${rcv_bytes[0]})*8)/ ${call_dur})
    ${result}         Evaluate    (${mbps} * ${speed} * 1.1) > ${rcv_bits} > (${mbps} * ${speed} * 0.9)
    Run Keyword if    ${result}    Log to Console    ${dir} Average data rate: ${rcv_bits}
    ...               ELSE    BuiltIn.Log     ${dir} Average data rate: ${rcv_bits}    level=ERROR
    ${tot_bps}      Run Keyword if    '${data_rate}' == 'mbps'       Evaluate     float(${rcv_bits}/${1000000})
    ...      ELSE      Evaluate     float(${rcv_bits}/${1000})
    [Return]    ${tot_bps}

Validate NSA UL Traffic
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. UL/DL Bytes Received must be equal to ALL Bytes Sent
    [Arguments]    ${ue_id}     ${rate}    ${call_dur}    ${dir}=ul    ${data_unit}=mbps
    ...       ${id}=${Bearer_ID}    ${trf_id}=${TRF_ID}
    wtsrunner.bearer_stats  ue=${ue_id}   id=${id}      dir=ul
    ${bearer_stat}      wtsrunner.read_wtsemu_output_until     expected=Average packet interval      timeout=30
    ${tp}      Check Average Data Rate     ${bearer_stat}    ${dir}    ${rate}    ${data_unit}    ${call_dur}
    Log to Console     UE${ue_id} ${dir} Throughput: ${tp} ${data_unit}
    [Return]    ${tp}

Compare UL Traffic
    [Arguments]     ${tp_cell1}       ${tp_cell2}     ${pucch}
    ${tp_status}       Run Keyword If  '${pucch}' == 'long'
    ...         Evaluate    ${tp_cell1} > ${tp_cell2}
    ...         ELSE        Run Keyword If    '${pucch}' == 'short'
    ...         Evaluate    ${tp_cell1} == ${tp_cell2}
    Run Keyword if    ${tp_status}    Log to Console    UL Throughput Verified Cell1: ${tp_cell1} Cell2: ${tp_cell2}
    ...               ELSE    BuiltIn.Log     Failure in UL Throughput Cell1: ${tp_cell1} Cell2: ${tp_cell2}    level=ERROR
#    Should Contain     ${tp_status}     True
    ${chk}     Evaluate    ${tp_cell1} - ${tp_cell2}
    ${tp_chk}     Set Variable If    ${chk} == ${0}     Same
    ...                              ${chk} > ${0}     Increased
    ...                              ${chk} < ${0}     Decreased
    Log to Console    Cell1 and Cell2 Throughput difference is ${chk} and Cell1 throughput is ${tp_chk} compare to Cell2

Stop MultiUE Data Traffic for SA Call
    [Arguments]    ${start_ue_id}   ${end_ue_id}
    [Documentation]    This keyword stops the Data Traffic for the SA variant
	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Log to Console    \nStopping Data Traffic...
    wtsrunner.trf_data_stop     ue=${ue_idx}    pdu=1    qfi=1    trf_id=1
    ${output}   wtsrunner.read_wtsemu_output_until_re     expected=Stopped*    timeout=10
    ${output1}         Get Lines Matching Regexp    ${output}    Traffic was stopped   partial_match=${TRUE}
    Log to Console     ${output1}
	END

Verify Counters
    [Arguments]       ${PM_counter}        ${exp-value}
    ${pm_counters_dir}=  Collect PM Counter  target_dir=${OUTPUT_DIR}/PMC
    Set Suite variable  ${pm_counters_dir}
    FOR    ${item}    IN    @{PM_counter}
        ${cell1}        CB012261_resource.Get PM counter value   ${OUTPUT_DIR}/PMC/gnb_pm_counters/      ${item}     MRBTS-1/NRBTS-1/NRCELL-1
        Should Contain      ${cell1}        ${exp-value}
        Log to console   NRCELL-1/${item}= ${cell1}
        ${cell2}        CB012261_resource.Get PM counter value   ${OUTPUT_DIR}/PMC/gnb_pm_counters/      ${item}     MRBTS-1/NRBTS-1/NRCELL-2
        Should Contain      ${cell2}        ${exp-value}
        Log to console   NRCELL-2/${item}= ${cell2}
    END


Get PM counter value
    [Arguments]    ${pm_files_location}   ${pi_id}    ${moc}
    Builtin.Log     ${pm_files_location}
    ${pi_list}=  Create List
    ...  ${pi_id}
    ${PM_report_dict_list}=  check_pm.get_pi_value
    ...  pi_list=${pi_list}
    ...  pi_dir=${pm_files_location}
    ...  pi_file_pattern=PM*
    Builtin.Log     ${PM_report_dict_list}
    ${last_report}    Get From List   ${PM_report_dict_list}     -1
    ${pi_dict}   Get Dictionary Values   ${last_report}
    ${first_pi}    Get From List   ${pi_dict}     0
    ${cell_dict_list}   Get Dictionary Values   ${first_pi}
    ${cell_dict}   Get From List   ${cell_dict_list}     0
    ${moc_list}   get dictionary keys   ${cell_dict}
    ${full_moc}    Set Variable     empty
    FOR  ${key}  IN   @{moc_list}
       ${key_is_moc}  Run Keyword And Return Status    Should Contain  ${key}   ${moc}
       ${full_moc}  Set Variable If   ${key_is_moc}   ${key}    ${full_moc}
    END
    ${pi_value}     Get From Dictionary      ${cell_dict}    ${full_moc}
    BuiltIn.Log    ${pi_id} value: ${pi_value}   console=${P_console}
    [Return]    ${pi_value}



####### DSS wts commands#####
Setup XP LINK
    [Arguments]    ${enb_id}    ${target_id}
    ${pattern}=    Set Variable    ENB-1: XpAP Link with GNB-2 .* is up
    ${result}=     execute_command.setup_xp_link    1    2    ${pattern}
    Should contain    ${result}    Pass

Set LTE NR DSS Mode
    [Documentation]    This keyword is for setting LTE NR DSS MODE.
    Log To Console   \nSet LTE NR DSS Mode...\n
    wtsrunner.enb_cell_param   id=1   enb=2   lte_nr_dss_mode=DL_CRS_TDM_UL_FDM   antenna_ports_num=2

Setup DSS Link
    [Arguments]    ${enb_id}    ${target_id}
    ${pattern}=    Set Variable    ENB-2: Cell 1: EN DSS UL Cell Subcarrier Resource Coordination success on remote NE
    ${result}=     execute_command.setup_dss_link   2    1    ${pattern}
    Should contain    ${result}    Pass


Set DL UL RESOURCE Cell Reservation
    [Arguments]    ${enb_id}    ${target_id}    ${min_dss_ratio}    ${max_dss_ratio}
    ${pattern}=    Set Variable    ENB-2: Cell 1: Update Indication : EN DSS UL Cell Subcarrier Resource Coordination: both NEs synchronized
    ${result}=     execute_command.set_dl_ul_cell_reservation   2    1    ${min_dss_ratio}    ${max_dss_ratio}    ${pattern}
    Should contain    ${result}    Pass


