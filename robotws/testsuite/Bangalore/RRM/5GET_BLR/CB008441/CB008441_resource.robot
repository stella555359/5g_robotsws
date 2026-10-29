*** Settings ***
Documentation    :copyright: Nokia

Variables    ta5g_global_var

Resource       taf/rfrl/common_resources/robot/coam.robot
Resource       taf/rfrl/common_resources/robot/libraries_instances.robot
Library        ../resources/NPS/SWENG/python_libs/luashark_tools.py
Resource       ../resources/NPS/SWENG/robot/PacketSearch.robot
Resource       ../resources/robot/Setup_Env.robot
Resource       ../resources/robot/common_log_collection.robot
Resource       ../resources/ECEcommon/common_file_operation.robot
Resource       ../resources/robot/Airphone.robot
Resource       ../resources/robot/WTS_Runner_Keywords.robot
Resource       ../resources/robot/PM_Counters.robot
Resource         ../resources/robot/TTI_Traces.robot
Resource         ../resources/robot/Iperf_Traffic.robot
Library          ../resources/python/ssh_command.py
Library        luashark_tools.analyzer       WITH NAME       analyzer
Library        	taf.sbts.oam.coam.admin                  WITH NAME   ute_adm
Library        taf.collectors.btslog  WITH NAME   btslog
Library        Collections
Library        OperatingSystem
Library        ta5g_tshark
Library        ta5g_commissioning
Library        taf.analyzer.pdml     WITH NAME    taf_pdml_analyser
Library        taf.transport.ssh                 WITH NAME    csn
Library           XML    use_lxml=True    WITH NAME    Myxml
Library          ../resources/python/TTI_Converter.py    WITH NAME    TtiConvert
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Library          ./resources/python/increase_buffer_size.py
Library          DateTime
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          ta_a2a

*** Variables ***
${delta_set_collecting_counters_to_five_minutes}=
    ...    /home/ute/Auto5G/testsuite/RRM/5G_SW_WRO/resources/config/5G21B/delta_set_collecting_counters_to_five_minutes.json
@{FIELDS_CellSetupReq}     cellBwpList_item_0     cellBwpList_item_1
${BIP_SCRIPT_PATH}      ${CURDIR}/../resources/NPS/SWENG/config/script
${WEBEM_USERNAME}      ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBEM_PASSWORD}      ${tl.gnbs[0].cu.oam_http_connection_details.password}

&{GNB_ASIK}                ip=192.168.255.129    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik
&{AP_ASIK}                 ip=192.168.200.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=APAsik
${port}                    22
${radparam}                SEPARATOR=${EMPTY}   0x5A0622=1;0x590072=1

*** Keywords ***
Increase Buffer Size for VM and IPHY
    increase_buffer_size.increase_buffer_size     ${AP_ASIK.ip}      ${port}    ${AP_ASIK.username}     ${AP_ASIK.password}


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

Configure in VM for RANK-4
    [Documentation]    This keyword is to configure RANK-4 in VM
    Log To Console    configure VM for RANK-4..
    OperatingSystem.Run    sudo sysctl -w net.core.wmem_max=20971520
    OperatingSystem.Run    sudo sysctl -w net.core.wmem_default=20971520
    OperatingSystem.Run    sudo sysctl -w net.core.rmem_max=20971520
    OperatingSystem.Run    sudo sysctl -w net.core.rmem_default=20971520

Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces
    [Arguments]    ${wts_cfg_file}  ${cellid}=1
    Fetch board type
    Configure UTE ETH3 IPs
    Wait Until Keyword Succeeds    5min    20sec     Check gNB Airscale is Ready - ${BBoard_Type}
    ${oam_alias}=    Setup OAM session
    Wait Until Keyword Succeeds    10min    20sec    Verify Single Radio is Online      connection=${oam_alias}
    #${file_name}    set variable     NODECPRT_GNB_cellsetup.pcap
    Check gNB Airscale is Ready - ${BBoard_Type}

    Log To console     loading cfg file
    Start Log   btslog    cprt
    Check Cell On Air      ${wts_cfg_file}  ${cellid}
    ${cprt_log_1}     Stop Log  cprt  test_scenario=cellsetup
    set suite variable    ${cprt_log_1}
    ${cell_sys_log}     Stop Log   btslog   test_scenario=cellsetup_sys
    set suite variable    ${cell_sys_log}

Perform SCF Delta Commissioning with ${delta_commissioning_file_json}
    Find Scfc And Send Delta Commissioning      scfc_filename=${delta_commissioning_file_json}

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


Modify NIDD parameters
    [Documentation]      This Keyword modify NIDD parameter as per the requirement of the feature
    [Arguments]      ${paramName}='None'      ${paramValue}='None'       ${operation}=update      ${paramDst}='None'
    Log to Console      Modifying NIDD parameters
    admin.Setup admin
    Online NIDD parameter change    paramName=${paramName}         paramValue=${paramValue}        operation=${operation}
    ...                             paramDst=${paramDst}
    sleep               60s
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
    log to console    unused-${timeout}

Check Cell On Air
    [Arguments]    ${wts_cfg_file}  ${cellid}
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

    wtsrunner.read_wtsemu_output_until_re    expected=UEC-1: eNB 2 cell ${cellid}: SystemInformationBlockType4-NR updated     timeout=240

#=====================================added after cb8927_a_b201_5=================================================
Start Multiue Iperf TCP Sporadic DL Data
    [Arguments]      ${start_ue_id}     ${end_ue_id}       ${bytes}         ${duration}
    ${port}         Set Variable        7072
    FOR     ${id}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    ${idx}     Evaluate    ${id}+${1}
    ${dl_ue_ip}       Set Variable        1.2.4.${idx}
    ${dl_port}      Evaluate    ${port}+${1}
    Start TCP DL Iperf Data    ${dl_ue_ip}    ${dl_port}    ${id}     ${bytes}    ${duration}
    wtsrunner.ue_stats_nr    id=${id}
    ${output}    wtsrunner.read_wtsemu_output_until_prompt    timeout=10
#    Sleep     2s
    ${port}         Set Variable        ${dl_port}
    END

Start NSA Multiue Iperf TCP Sporadic DL Data
    [Arguments]      ${start_ue_id}     ${end_ue_id}       ${bytes}         ${duration}
    ${port}         Set Variable        7070
    FOR     ${id}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    ${x}       Evaluate    ${id}-${30}
    ${dl_ue_ip}       Set Variable    4.7.254.${x}
    ${dl_port}  Set Variable    ${port}
    Start TCP DL Iperf Data    ${dl_ue_ip}    ${dl_port}    ${id}     ${bytes}    ${duration}
    wtsrunner.ue_stats_nr    id=${id}
    ${output}    wtsrunner.read_wtsemu_output_until_prompt    timeout=10
#    Sleep     2s
    END

Start TCP DL Iperf Data
    [Arguments]    ${dl_ue_ip}    ${dl_port}    ${id}    ${bytes}    ${duration}
    [Documentation]    Run TCP DL Iperf Data Traffic
    Iperf in Linux             args=-s -p ${dl_port} -i 1 -B 10.0.2.1
    Iperf in Linux             args=-c ${dl_ue_ip} -p ${dl_port} -i 2 -l ${bytes} -t ${duration} -B 10.0.2.1
    ...                                pipeArgs=| tee /tmp/iperf_DL_${id}.txt
    Log to Console                     Running TCP DL Traffic from iperf

Check MultiUE UE State Display
    [Arguments]     ${start_ue_id}    ${end_ue_id}
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    wtsrunner.ue_stats_nr    id=${ue_idx}
    ${output}    wtsrunner.read_wtsemu_output_until_prompt    timeout=10
    Log to Console    ${output}
    END


MultiUE Attach for NSA
    [Arguments]    ${start_ue_id}    ${stop_ue_id}  ${Trgt_Cell}=${Target_Cells}
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
    LTE Attach should be Successful    ${ue_id}
    UE Attach should be Successful     ${ue_id}     ${Trgt_Cell}
    END

MultiUE DL Traffic Start for NSA
    [Arguments]    ${start_ue_id}    ${stop_ue_id}    ${Traffic_rate}    ${dl_rate}    ${id}=${Bearer_ID}    ${trf_id}=${TRF_ID}
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
    Trigger DL Traffic for NSA    ${ue_id}    ${Traffic_rate}    ${dl_rate}    id=${id}    trf_id=${TRF_ID}
    END

MultiUE UL Traffic Start for NSA
    [Arguments]    ${start_ue_id}    ${stop_ue_id}    ${Traffic_rate}    ${ul_rate}    ${id}=${Bearer_ID}    ${trf_id}=${TRF_ID}
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
    Trigger UL Traffic for NSA    ${ue_id}    ${Traffic_rate}    ${ul_rate}    id=${id}    trf_id=${TRF_ID}
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

#Add RD Parameters To GNB Swconfig File
#    [Arguments]    ${rd_parametrs}
#    [Documentation]    This keyword is to add new RD parameters to swconfig.txt
#    ...
#    ...    | Input Parameters | Man. | Description |
#    ...    | ${rd_parametrs} | Yes | str joined by symbol ;, like 0x580019=1;0x580011=0;0x580012=0; |
#    ...
#    ...    Examples:
#    ...    | Add RD Parameters To GNB Swconfig File | 0x580019=1;0x580011=0;0x580012=0 |
#    ...
#    ${path}    Get Swconfig File From GNB    ${OUTPUT_DIR}
#    Modify Swconfig File Parameters    ${path}    ${rd_parametrs}
#    Send Swconfig File To GNB    ${path}
#
#Get Swconfig File From GNB
#    [Arguments]    ${save_dir}
#    OperatingSystem.Run
#    ...    sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.255.1:/ffs/run/swconfig.txt ${save_dir}/swconfig_gnb.txt
#    OperatingSystem.Should Exist    ${save_dir}/swconfig_gnb.txt
#    ${path}    Set Variable    ${save_dir}/swconfig_gnb.txt
#    [Return]    ${path}
#
#Send Swconfig File To GNB
#    [Arguments]    ${path}
#    ${rc}    OperatingSystem.Run And Return Rc
#    ...    sshpass -p oZPS0POrRieRtu scp ${path} toor4nsn@192.168.255.1:/ffs/run/swconfig.txt
#    Should Be Equal As Integers    ${rc}    0
#    ${rc1}    OperatingSystem.Run And Return Rc
#    ...    ssh toor4nsn@192.168.255.1 crasign /ffs/run/swconfig.txt
#    Should Be Equal As Integers    ${rc1}    0

MultiUE NSA Attach should be Successful and Fetch CRNTI  #NSA
    [Arguments]    ${start_ue_id}   ${end_ue_id}    ${Trgt_Cell}=${Target_Cells}    #${allocType}=rat0
    [Documentation]    This keyword is used at create the LTE Attach and checks the completion message in output file.
    ${crnti_list}       Create List
    FOR    ${NSA_UE_ID}    IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    wtsrunner.ue_attach    id=${NSA_UE_ID}
    ${output}    Read WTS Output For Pattern And Print matching Lines    ${LTE_attach_pattern}    ${Timeout_NSA}
    BuiltIn.Log    lte_attach_is_ok
    wtsrunner.enb_ue_dc_start    target_gnb=${Target_gNB}    target_cells=${Trgt_Cell}    ue=${NSA_UE_ID}
    ...  bearer=${Bearer_ID}    type=split_scg
    ${output1}    Read WTS Output For Pattern And Print matching Lines    ${UE_attach_pattern}    ${Timeout_NSA}
    Create File     ${OUTPUT_DIR}/regst_nsa_${NSA_UE_ID}.txt     ${output1}
    ${crnti_value}=    Run     cat ${OUTPUT_DIR}/regst_nsa_${NSA_UE_ID}.txt|grep -i newUE-Identity |awk '{print $2}'|cut -d ',' -f 1
    BuiltIn.Log     ${crnti_value}
	Append To List  ${crnti_list}   ${crnti_value}
	Log to Console  crnti_list-${crnti_list}
#    ${x}    Set variable if   ${allocType}==rat0    0   1
#    BuiltIn.Should Match Regexp   ${output1}   spCellConfigDedicated((.|\n)*)resourceAllocation resourceAllocationType${x}
    Log to Console             nsa_ue_register_is_ok with ${crnti_value}
    BuiltIn.Log                nsa_ue_register_is_ok with ${crnti_value}
    END
    [Return]      ${crnti_list}

MultiUE SA Register should be Successful Generalised
    [Arguments]    ${start_ue_id}   ${end_ue_id}    ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}
    ...  ${trf_type}=internal   #${rat_alloc}=rat0
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA varianti
    Log to Console     UE Register with Trf type external
    ${crnti_list}       Create List
    set global variable   ${crnti_list}
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    wtsrunner.ue_register   id=${ue_idx}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Create File     ${OUTPUT_DIR}/regst.txt     ${output}
    ${crnti_string}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk -F 'crnti:' '{print $2}'|cut -d ' ' -f 2
    Append To List  ${crnti_list}   ${crnti_string}
    BuiltIn.Log     ${crnti_string}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}
    wtsrunner.set_pdu_param     ue=${ue_idx}    pdu=${pdu_id}    trf_type=${trf_type}
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_idx}    nwslice=${nw_id}    gw=${ue_idx}
#    ${x}    Set Variable if     '${rat_alloc}'=='rat0'  0   1
    ${output1}   Read WTS Output For Pattern And Print matching Lines    ${Initial_context_setup_pattern}    ${Timeout_SA}
#    Should Match Regexp   ${output1}   spCellConfig.*\\n.*\\n.*spCellConfigDedicated((.*\n){1,}).*resourceAllocation resourceAllocationType${x}
#    Log to Console     ue=${ue_idx} with crnti=${crnti_string} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
#    BuiltIn.Log        ue=${ue_idx} with crnti=${crnti_string} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
    END
    Log to Console             multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                CRntilist:${crnti_list}
    [Return]      ${crnti_list}




#===========Iperf3 KW addition===================================
Iperf3 in Linux
    [Arguments]    ${args}=${EMPTY}    ${pipeArgs}=${EMPTY}
#    ${result}    Run Keyword    Start Process    iperf3     ${args}    ${pipeArgs}    shell=${TRUE}
    ${command}      Catenate    iperf3     ${args}    ${pipeArgs}
    ${result}    Run Keyword    Start Process    ${command}    shell=${TRUE}
    [Return]    ${result}

Start TCP Iperf3 Data
    [Arguments]    ${ue_ip}    ${port}    ${id}    ${bytes}    ${duration}    ${stream}    ${BW}    ${dir}    ${protocol}
    [Documentation]    Run TCP ${dir} Iperf Data Traffic

#    ${arg_s}    Set Variable if    '${protocol}'!='TCP'     -s -u -p ${port} -i 1 -B 10.0.2.1       -s -p ${port} -i 1 -B 10.0.2.1
#    log to console  Server_${arg_s}

    ${arg_s}    Set Variable       -s -p ${port} -i 1 -B 10.0.2.1 --logfile /tmp/iperf3_s_${dir}_${id}.txt
    ${arg_c}    Set Variable if   '${protocol}'!='TCP'
    ...      -c ${ue_ip} -u -p ${port} -i 1 -l ${bytes} -t ${duration} -P ${stream} -b ${BW}M -B 10.0.2.1 -V --logfile /tmp/iperf3_c_${dir}_${id}.txt
    ...      -c ${ue_ip} -p ${port} -i 1 -l ${bytes} -t ${duration} -P ${stream} -B 10.0.2.1 -V --logfile /tmp/iperf3_c_${dir}_${id}.txt
    log to console  Client_${arg_c}

#    Iperf3 in Linux             args=${arg_s}      pipeArgs=| tee -i /tmp/iperf3_s_${dir}_${id}.txt
#    Iperf3 in Linux             args=${arg_c}      pipeArgs=| tee -i /tmp/iperf3_c_${dir}_${id}.txt

    Iperf3 in Linux             args=${arg_s}
    Iperf3 in Linux             args=${arg_c}
    Log to Console                     Running TCP Traffic ${dir} from iperf

Start Multiue Iperf3 TCP Sporadic Data
    [Arguments]      ${start_ue_id}    ${end_ue_id}    ${bytes}    ${duration}    ${stream}
    ...    ${dir}    ${ue_type}    ${BW}=0    ${protocol}=TCP
#    1    6    1000    60   4   DL    SA
    ${port}         Set Variable if
    ...           '${dir}'=='DL' and '${ue_type}'=='SA'      7073
    ...           '${dir}'=='UL' and '${ue_type}'=='SA'      7173
    ...           '${dir}'=='DL' and '${ue_type}'=='NSA'     8073
    ...           '${dir}'=='UL' and '${ue_type}'=='NSA'     8173

    FOR     ${id}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    ${y}    Run Keyword if     '${ue_type}'=='SA' and '${dir}'=='DL'
    ...     Evaluate    ${id}+${1}
    ...     ELSE IF     '${ue_type}'=='NSA' and '${dir}'=='UL'
    ...     Evaluate    ${id}-${30}+${1}
    ...     ELSE
    ...     Set Variable    ${id}

    ${ue_ip}        Set Variable if
    ...     '${ue_type}'=='SA' and '${dir}'=='DL'       1.2.4.${y}
    ...     '${ue_type}'=='SA' and '${dir}'=='UL'       72.23.${y}.1
    ...     '${ue_type}'=='NSA' and '${dir}'=='DL'      4.7.254.${y}
    ...     '${ue_type}'=='NSA' and '${dir}'=='UL'      72.22.0.${y}

    Start TCP Iperf3 Data   ${ue_ip}    ${port}    ${id}    ${bytes}    ${duration}  ${stream}    ${BW}    ${dir}   ${protocol}
#    sleep   1s
#    ${x}    Set Variable if    '${dir}'=='DL'    pdsch     pusch
#    wtsrunner.ue_stats_nr   id=${id}    type=${x}     scell=0-1
#    ${output}    wtsrunner.read_wtsemu_output_until_prompt    timeout=10
#    log to console      ${output}

    ${port}      Evaluate    ${port}+${1}
#    ${port}         Set Variable        ${dl_port}
    END

Stop Iperf3 Traffic
    [Documentation]    Stop Iperf Traffic
    Kill Processes with PID    "iperf3"    pgrepArgs=-d ' '
    ...                                sudo=sudo -S
