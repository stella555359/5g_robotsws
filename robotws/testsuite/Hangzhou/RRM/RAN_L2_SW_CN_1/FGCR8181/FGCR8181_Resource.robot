*** Variables ***
${CMD_KILL_BIP_PROCESS}=    pkill -9 tcpdump
@{OPTLINKS}                 1.1    1.2    1.9    1.10

*** Keywords ***
MultiUE Attach With NSA
    [Arguments]    ${start_ue_num}    ${stop_ue_num}    ${profile_id}=1    ${bearer_id}=2
    :FOR    ${ue_id}    IN RANGE    ${start_ue_num}    ${stop_ue_num}+1
    \    Log To Console    ===============UE${ue_id} Attach:==============
    \    NSA LTE Attach    ${ue_id}    ${profile_id}
    \    NSA 5G Attach    ${ue_id}    2    1    ${bearer_id}
    \    NSA Verify If Attach Passed

MultiUE Do Traffic With NSA
    [Arguments]    ${start_ue_num}    ${stop_ue_num}    ${dl_traffic}=5    ${ul_traffic}=1
    :FOR    ${ue_id}    IN RANGE    ${start_ue_num}    ${stop_ue_num}+1
    \    Log To Console    ===============UE${ue_id} traffic:==============
    \    Run Keyword If    ${dl_traffic}!=0    NSA Start DL Traffic    ${ue_id}    ${bearer_id}    ${dl_traffic}    1
    \    Run Keyword If    ${ul_traffic}!=0    NSA Start UL Traffic    ${ue_id}    ${bearer_id}    ${ul_traffic}    1

Some UE Detach
    [Arguments]    ${start_ue_num}    ${stop_ue_num}
    :FOR    ${ue_id}    IN RANGE    ${start_ue_num}    ${stop_ue_num}+1
    \    Log To Console    ===============UE${ue_id} Dettached:==============
    \    NSA LTE Detach    ${ue_id}

MultiUE Check Tput
    [Arguments]    ${start_ue_num}    ${stop_ue_num}    ${bearer_id}    ${dir}    ${tp_rate}
    :FOR    ${ue_id}    IN RANGE    ${start_ue_num}    ${stop_ue_num}+1
    \    Log To Console    ===============UE${ue_id} traffic:==============
    \    NSA Check Average Traffic Bigger Than Target    ${ue_id}    ${bearer_id}    ${dir}    ${tp_rate}

Modify IPHY XML File
    [Arguments]    ${param_dict}
    ${iphy_path}    Get IPHY XML From Airphone    ${output_dir}
#    Add Optlink In IPHY XML    ${iphy_path}    ${optlinks}
    ${gscn_num}    Get GSCN From Scf File
    ${param_dict}    Collections.Set To Dictionary    ${param_dict}    GSCN=${gscn_num}
    Modify XML File    ${iphy_path}    ${param_dict}
    Send IPHY XML To Airphone    ${iphy_path}

Convert BIP And Check A2A
    [Arguments]    ${bip_log_dir}    ${index}=0
    ${dl_filter}    Set Variable    DlData_PdschSendReq
    @{dl_column_name}    Create List    DlData_PdschSendReq.PdschSendReq.subcellId    DlData_PdschSendReq.PdschSendReq.sfn
    ...    DlData_PdschSendReq.PdschSendReq.Slot    DlData_PdschSendReq.grants_item_15.rnti
    ...    DlData_PdschSendReq.grants_item_15.NumOfLayers
    ${ul_filter}    Set Variable    DlData_PdschSendReq
    @{ul_column_name}    Create List    UlData_PuschReceiveReq.subcells_item_3.subcellId    UlData_PuschReceiveReq.PuschReceiveReq.sfn
    ...    UlData_PuschReceiveReq.PuschReceiveReq.Slot    UlData_PuschReceiveReq.grants_item_15.rnti
    ...    UlData_PuschReceiveReq.grants_item_15.NumOfLayers
    ${bip_names}    OperatingSystem.List Files In Directory    ${bip_log_dir}    5GBipL2L1_filtering_off*.pcap*    ${true}
    :FOR    ${index}    ${name}    IN ENUMERATE    @{bip_names}
    \    Convert BIP Log Pcap To Csv    ${name}    ${dl_filter}    ${dl_column_name}    dl_trans_${index}
    \    Convert BIP Log Pcap To Csv    ${name}    ${ul_filter}    ${ul_column_name}    ul_trans_${index}

Get GSCN From Scf File
    common_admin.Backup Scf    ${output_dir}    backup
    ${content}    OperatingSystem.Get File    ${output_dir}/SCF_backup.xml
    ${res}    String.Get Regexp Matches    ${content}    <p name="gscnOrSsPbchArfcn">(?P<gscn>.*)</p>    gscn
    [Return]    ${res}[0]

Set Bler To UE
    [Arguments]    ${ue_id}    ${pro_id}    ${dlbler_rate}    ${ulbler_rate}
    ${cmd_bler_mode}    Catenate    SEPARATOR=${space}    bler_testmode_nr profile_id=${pro_id}
    ...    dl_bler=${dlbler_rate} ul_bler=${ulbler_rate}
    ${cmd_send_bler}    Catenate    SEPARATOR=${space}    ue_testmode_set_nr id=${ue_id}
    ...    testmode=bler action=activate profile_id=${pro_id} scell=0
    ${output}    ute_wtssim.Execute Egate Command    cmd=${cmd_bler_mode}
    ${output}    ute_wtssim.Execute Egate Command    cmd=${cmd_send_bler}
    ${output}    ute_wtssim.Execute Egate Command    cmd=bler_testmode_nr profile_id\=${pro_id}
    ...    pass_regexp=dl_bler    timeout=150
