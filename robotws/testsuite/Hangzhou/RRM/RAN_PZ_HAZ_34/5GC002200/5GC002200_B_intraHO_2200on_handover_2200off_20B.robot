# # #*** Settings ***
# # #Documentation
# # #...           author: liujia
# # #...           contact:jia-rebecca.liu@nokia-sbell.com
# # #...           squad group: SG_03
# # #...           feature : 5GC002200
# # #
# # #Force Tags    CA_5G_RRM
# # #...    PY36
# # #
# # #Suite Setup    Run Keywords
# # #...    Run Keyword And Ignore Error    Common Suite Setup for COAM    AND
# # #...                            ASKEY UE parameter setup
# # #
# # #Suite Teardown      Run Keyword And Ignore Error     Common Suite Teardown for COAM
# # #
# # #Resource       Resources/5GC002200_coam_common_keywords.robot
# # #Resource       Resources/TOPYOUNG_MCS_common_keywords.robot
# # #Variables      testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC002200/Resources/variables.py
# # #Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
# # #
# # #*** Variables ***
# # #${GoldenSCF_22R2}            MRBTS-10318_TL362_golden_scf.xml
# # #${TL362_scf}                 interFintragNBHO.xml
# # #${TL362_scf_21B}             interFintragNBHO_21B_backup.xml
# # #${swconfig}                 /opt/workspace/SCF/2200/swconfig/swconfig.txt
# # #${topyoung_ip_362}           ${tl.attenuator[0].ip_addr}
# # #${model}                     ${tl.attenuator[0].model}
# # #${ASKEY_DL_PORT}             ${ue_param['data_transfer']['iperf_options']['qci'][5]}
# # #${Send_Tput_DL}              1500M
# # #${On_off_HO_2200}            On_off_HO_2200.pcap
# # #${dl_throughput}             1500M
# # #${Expect_DOWNLINK}           30    #not key point  TA check only around 200M will debug
# # #${TL362_enbx2_dist}          MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-1
# # #${TL362_enb_AEQV}            MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-1
# # #${command_template_with_Y}    {tshark_path} -r {pcap_file} -Y  \"x2ap\"  -T pdml
# # #
# # #*** Test Cases ***
# # #[1]5GC002200_B_025_Interworking_with_Intra_HO_when_feature_enable_with_1_resources_and_4_resource_NSA
# # #    [Documentation]
# # #    ...    This user scenario describes the gNB behaviour with 2200, when a UE for which Inter-frequency A3
# # #    ...    measurements have been configured sends a Inter-frequency A3 measurement report and gNB
# # #    ...    performs handover based on the measurement report to a cell in the different gNB-DU with 2200 0n to off
# # #    [Tags]      10.1800     classical
# # #    [Setup]
# # #    run keyword if    '${release_info}' == 'SBTS21B_ENB_0000'    Prepare testline to cell onair for NSA
# # #    ...    localFilePath=${swconfig}    tl_scf_filename=${TL362_scf_21B}    enbx2_dist=${TL362_enbx2_dist}
# # #    run keyword if    '${release_info}' == 'SBTS22R2_ENB_0000'    Modify SCF Only and Perform Commission    scf_file_name=${GoldenSCF_22R2}
# # #    ...    ParameterToDelete=${B025_DeleteLIST_22R2}    ParamterToModify=${B025_modify_para_22R2}
# # #    ...    ListToAdd=${B025_ADDLIST_22R2}    ListParamterToModify=${B025_modify_list_22R2}
# # #    Set nrcellid suit varaible    cellid=2
# # #    Connect and Modify the parameter on enblte    dist_name=${TL362_enb_AEQV}    parameter=defaultLnRelGnbCellId    value=0
# # #    MCS Prepare and set frequency    ip=${topyoung_ip_362}
# # #    Set TOPYOUNG ATT for AZQO   att_value=${25}
# # #    Set TOPYOUNG ATT    att_value=${40}
# # #    Start To Capture ENB Logs    filename=${On_off_HO_2200}
# # #    Start DL date on askey for fixed UE ip    traffic=${dl_throughput}
# # #    Power UE Precondition
# # #    Power UE Attach And Verify Attach For Askey    4g_check=True
# # #    sleep    60s
# # #    Power UE check throughput    dlexpect=${Expect_DOWNLINK}
# # #    Run Keyword And Ignore Error    Close the iperf process on APPserver    dl_port=${ASKEY_DL_PORT}
# # #    Stop and download ENB Logs    filename=${On_off_HO_2200}
# # #    Check HO process on wireshark    #AEQV HO to AZQO could not adjust att seperately
# # #    [Teardown]    Run Keyword And Ignore Error     Tests Recover
# # #
# # #*** Keywords ***
# # #Start DL date on askey for fixed UE ip
# # #    [Arguments]    ${ue_index}=${0}    ${DL_port}=${ASKEY_DL_PORT}    ${time}=${DL_TIME}    #${UE_IP}=172.252.65.7
# # #    ...            ${interval}=1    ${traffic}=${dl_throughput}    ${buffer_size}=${DL_LENGTH}
# # #    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP    ue_index=${ue_index}    hostname=${iperf_hostname}
# # #    ...    username=${iperf_username}    password=${iperf_password}
# # #    sleep   2s
# # #    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${DL_port}| awk '{print $2}' |xargs kill -9    connection=EPCAPP
# # #    csn.send_command
# # #    ...    command=iperf -c 172.252.65.7 -u -t ${time} -i ${interval} -p ${DL_port} -P 1 -f m -b ${traffic} -l ${buffer_size} -T 64 &
# # #    ...    connection=EPCAPP
# # #
# # #Start To Capture ENB Logs
# # #    [Arguments]     ${filename}    ${connection}=ENB
# # #    wait until keyword succeeds    5 min    10 sec    Connect to ENB    alias=ENB
# # #    csn.send command    command=tcpdump -i any sctp -w ${enb_path}${filename}    connection=${connection}
# # #
# # #Stop and download ENB Logs
# # #    [Arguments]     ${filename}=enblog.pcap    ${connection}=ENB
# # #    wait until keyword succeeds    5 min    10 sec    Connect to ENB    alias=ENB
# # #    csn.send command    command=killall tcpdump     connection=${connection}
# # #    sleep    5
# # #    csn.download_file    ${enb_path}${filename}    ${epc_log_path}${filename}    connection=${connection}
# # #
# # #Power UE check throughput
# # #    [Arguments]    ${dlexpect}    ${gnb_index}=${0}    ${ue_type}=${ue_type}
# # #    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
# # #    ${dl_tp_l2l0}    Wait Until Keyword Succeeds   5x    10s    power_ue.Check Throughput    sample=${6}
# # #    ...    ue_type=${ue_type}    direction=dl    throughput=${dlexpect}    sleep_time=${20}    cellid=${nrcellid}
# # #    [Return]     ${dl_tp_l2l0}
# # #
# # #Set TOPYOUNG ATT for AZQO
# # #    [Arguments]    ${att_value}
# # #    Set Odd ATT By Output_port    begin_output_port=5    end_output_port=8    attenuation=${att_value}    B_Odd=True
# # #    Set Even ATT By Output_port    begin_output_port=5    end_output_port=8    attenuation=90    B_Odd=True
# # #    Set Odd ATT By Output_port    begin_output_port=5    end_output_port=8    attenuation=90    B_Odd=False
# # #    Set Even ATT By Output_port    begin_output_port=5    end_output_port=8    attenuation=${att_value}    B_Odd=False
# # #
# # #Check HO process on wireshark
# # #    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${On_off_HO_2200}    tshark_path=${tshark_path}
# # #    ...    command_template=${command_template_with_Y}
# # #    ${filter_expression}=    Catenate    x2ap.procedureCode == 27 and x2ap.X2AP_PDU == 1
# # #    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}
# # #    ${nrofPorts}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.nrofPorts
# # #    should contain x times    ${nrofPorts}    3    1
# # #    ${cdm_Type}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.cdm_Type
# # #    should contain    ${cdm_Type}    2
# # #    ${density}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.density
# # #    should contain    ${density}    1
# # #    ${n1-n2}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.n1_n2
# # #    should contain    ${n1-n2}    2    #four_one
# # #    ${SinglePanel_ri}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.typeI_SinglePanel_ri_Restriction
# # #    should contain    ${SinglePanel_ri}    0f
# # #    ${filter_expression}=    Catenate    x2ap.procedureCode == 30 and nr-rrc.csi_MeasConfig == 1
# # #    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}
# # #    ${nrofPorts}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.nrofPorts
# # #    should contain x times    ${nrofPorts}    2    1
# # #    ${cdm_Type}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.cdm_Type
# # #    should contain    ${cdm_Type}    1
# # #    ${density}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.density
# # #    should contain    ${density}    1
# # #    ${SinglePanel_ri}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.typeI_SinglePanel_ri_Restriction
# # #    should contain    ${SinglePanel_ri}    0f
# # #
# # #Tests Recover
# # #    run keyword and ignore error        Connect and Modify the parameter on enblte
# # #    ...    dist_name=${TL362_enb_AEQV}    parameter=defaultLnRelGnbCellId    value=1
# # #    #Modify the COAM parameter with admin API    parameters=${UNLOCK_GNB1_CELL1}
# # #    #Get product brand
# # #    Run Keyword And Ignore Error    Askey UE stop dl traffic on appserver and detach
# # #    MCS teardown    mcs_alias=${${mcs_alias}}
# # #    disconect all connections
# # #
# # #Modify SCF Only and Perform Commission
# # #    [Documentation]
# # #    ...              Description: This keyword can only support to modify elements parameter and list elements in scf
# # #    ...              Element under MOs, Add if element not present
# # #    ...              Element under List/Items match by index
# # #    ...              two ways can be used for commission:
# # #    ...              '${scf_file_name}' != '${None}, commission with given ${scf_path}/${scf_file_name}
# # #    ...              set ${scf_file_name} to ${None}, download current scf from cluster, modify it and perform commission.
# # #    ...              ${scf_dir_path}: Refer to the scf folder for storing the modified scf file
# # #    [Arguments]       ${scf_file_name}=${None}
# # #    ...               ${scf_path}=/opt/workspace/SCF/
# # #    ...               ${scf_dir_path}=${epc_log_path}
# # #    ...               ${is_pdl_checking_needed}=${True}
# # #    ...               ${ParameterToDelete}='NULL'
# # #    ...               ${MOsToAdd}='NULL'
# # #    ...               ${ParamterToModify}='NULL'
# # #    ...               ${ListParamterToModify}='NULL'
# # #    ...               ${ListToAdd}='NULL'
# # #    ...               ${gnb_type}='SA'
# # #    ...               ${is_x2_check_from_gnb_needed}=${False}
# # #    Connect to gnb coam via ssl
# # #    ${commssion_scf_file_path}    Run keyword if    '${scf_file_name}'!= '${None}'    Join Path    ${scf_path}    ${scf_file_name}
# # #    ${scf_file_path}    set variable if    '${scf_file_name}'!= '${None}'    ${commssion_scf_file_path}    ${Golden_SCF_Path}
# # #    ${modified_scf_file_path}    Load SCF and Define modified scf path    scf_file_path=${scf_file_path}    scf_dir_path=${scf_dir_path}
# # #    run keyword unless    ${ParameterToDelete}=='NULL'     Remove object or Mo or list or element in SCF    parameter
# ...s_lists=${ParameterToDelete}
# # #    run keyword unless    ${MOsToAdd}=='NULL'    Add MOs To SCF with Given version
# # #    ...                                                   parameters_lists=${MOsToAdd}
# # #    run keyword unless    ${ParamterToModify}=='NULL'     Add or Modify elements to scf
# # #    ...                                                   parameters_lists=${ParamterToModify}
# # #    run keyword unless    ${ListParamterToModify}=='NULL'     Modify ListElements only to scf
# # #    ...                                                       parameters_lists=${ListParamterToModify}
# # #    run keyword unless    ${ListToAdd}=='NULL'     AddLists to SCF    parameters_lists=${ListToAdd}
# # #    scf.Save scf    ${modified_scf_file_path}
# # #    Log to console    Start to modify scf files and commission, please wait...
# # #    COAM Commission with scf file    scf_file_path=${modified_scf_file_path}    timeout=900
# # #    ...    is_pdl_checking_needed=${is_pdl_checking_needed}
# # #    sleep    60s
# # #    COAM Wait For Gnb Ready And Cell Setup    timeout=15 min    gnb_type=${gnb_type}    is_x2_check_from_gnb_needed=$
# ...{is_x2_check_from_gnb_needed}
# # #
# # #Load SCF and Define modified scf path
# # #    [Documentation]      Description: This keyword load scf and return modified scf path for future use.
# # #    ...              ${scf_dir_path}: Refer to the scf folder for storing the modified scf file
# # #    [Arguments]      ${scf_file_path}    ${scf_dir_path}=${epc_log_path}
# # #    ${default_scf_file_path}    Copy file    source=${scf_file_path}    destination=${scf_dir_path}
# # #    ${scf_file_name}    Fetch from right    ${scf_file_path}    /
# # #    ${file_name_without_extention}    String.Replace string    ${scf_file_name}    .xml    ${EMPTY}
# # #    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
# # #    ${scf_file_name_after_modify}    catenate  SEPARATOR=${EMPTY}    ${file_name_without_extention}    _${timestamp}_updated.xml
# # #    ${modified_scf_file_path}    set variable    ${scf_dir_path}/${scf_file_name_after_modify}
# # #    scf.Load scf    ${default_scf_file_path}
# # #    [Return]    ${modified_scf_file_path}
# # #
# # #Remove object or Mo or list or element in SCF
# # #    [Documentation]   Remove object , Mo, List, Element with p_name.
# # #    [Arguments]     ${parameters_lists}
# # #    FOR    ${item}    IN    @{parameters_lists}
# # #        ${res_dist_name}=    Run Keyword And Ignore error    set suite variable    ${dist_name_to_delete}   &{item}[dist_name]
# # #        ${res_list_name}=    Run Keyword And Ignore error    set suite variable    ${list_name_to_delete}   &{item}[list_name]
# # #        ${res_p_name}=    Run Keyword And Ignore error    set suite variable    ${p_name_to_delete}   &{item}[p_name]
# # #        Run Keyword If   ${res_p_name}== ('PASS', None)
# # #        ...              Run Keyword And Ignore error    scf.Remove Element From Scf    &{item}
# # #        Run Keyword If   ${res_list_name}== ('PASS', None) and ${res_p_name}!= ('PASS', None)
# # #        ...              Run Keyword And Ignore error    scf.remove_list_from_scf    dist_name=&{item}[dist_name]   list_name=&{item}[list_name]
# # #        Run Keyword If   ${res_list_name}!= ('PASS', None) and ${res_p_name}!= ('PASS', None)
# # #        ...              Run Keyword And Ignore error    scf.remove_mo_with_descendant_mos    dist_name=&{item}[dist_name]
# # #    END
# # #
# # #Add or Modify elements to scf
# # #    [Documentation]    add or modify the item with p_name
# # #    [Arguments]   ${parameters_lists}
# # #    FOR    ${item}    IN    @{parameters_lists}
# # #        ${res}    scf.is_element_in_object    dist_name=&{item}[dist_name]    p_name=&{item}[p_name]
# # #        Run Keyword If    '${res}'=='True'     scf.modify_scf_element    value=&{item}[value]   &{item}
# # #        ...      ELSE                          scf.add element to scf
# # #        ...                                    value=&{item}[value]   dist_name=&{item}[dist_name]    p_name=&{item}[p_name]
# # #    END
# # #
# # #Modify ListElements only to scf
# # #    [Documentation]   Modify List element. report error If not present
# # #    [Arguments]   ${parameters_lists}
# # #    FOR    ${item}    IN    @{parameters_lists}
# # #        ${res}    scf.is_list_in_object    dist_name=&{item}[dist_name]    list_name=&{item}[list_name]
# # #        Run Keyword If    '${res}'=='True'  Modify only SCF ListElements   dist_name=&{item}[dist_name]  list_name=&{item}[list_name]
# # #        ...        elements=&{item}[elements]
# # #    END
# # #
# # #Modify only SCF ListElements
# # #    [Arguments]   ${dist_name}    ${list_name}    ${elements}
# # #    FOR    ${item}   IN    @{elements}
# # #        scf.modify_scf_element    value=&{item}[value]   dist_name=${dist_name}  list_name=${list_name}
# # #        ...    p_name=&{item}[p_name]    index=&{item}[index]
# # #    END
# # #
# # #AddLists to SCF
# # #    [Documentation]   add List items and elements, if the items are present, remove it first.
# # #    [Arguments]    ${parameters_lists}
# # #    FOR    ${item}    IN    @{parameters_lists}
# # #        ${res}    scf.is_list_in_object    dist_name=&{item}[dist_name]    list_name=&{item}[list_name]
# # #        Run Keyword If    '${res}'!='True'     scf.add_list_to_scf    dist_name=&{item}[dist_name]    list_name=&{item}[list_name]
# # #        ${res}=    Run Keyword And Ignore error    scf.add item to list
# # #        ...        dist_name=&{item}[dist_name]    list_name=&{item}[list_name]    elements=&{item}[elements]
# # #        Run keyword if    ${res} != ('PASS', None)    scf.add_elements_to_list
# # #        ...        dist_name=&{item}[dist_name]    list_name=&{item}[list_name]    elements=&{item}[elements]
# # #    END
