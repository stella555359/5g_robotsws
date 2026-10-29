*** Settings ***
Documentation
...   Author: dongjun.tong@nokia-sbell.com
...   Contact: dongjun.tong@nokia-sbell.com
...   Description: The user scenario related to AirPhone operation.


Suite Setup       Run keywords   Common Suite Setup For RRM  AND   Update bsr package
Suite Teardown    Common Suite Teardown For RRM

Force Tags
...      CRT             #Tag Item
...      RAN_VRF_HAZ_1             #Competence Area
...      RAN_VRF_HAZ1_T02  #Organization
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout    600 minutes

Resource          ../../../Resources/Classical/RRM_Common_Resource.robot
Resource          ../../../../../resources/RAN_PZ_HAZ_1/Module/Counter_Operation.robot
Resource          ../../../T02/Common_Case/common_resource_new.robot
Library             taf.sw.scout                      WITH NAME    scout
#C:\robotws\testsuite\Hangzhou\RRM\RAN_PZ_HAZ_1\Resources\Common\python\tak_airphone\tak_airphone\interface.py
#C:\robotws\testsuite\Hangzhou\RRM\RAN_PZ_HAZ_1\Resources\Common\Airphone.robot
#Library          ../../Resources/Common/python/airphone.py
# CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# tdd_sansa_cmwv_2cells_ecpri
*** Variables ***
&{dcap_info}    host=127.0.0.1    port=9443    username=${None}    password=${None}
${log_type}    emil
@{Setup_5QI1_Success}
...    Added QosFlow with QFI:2 fiveQI:1
...    QoS Routing Table
...    Unexpected XnAP: SNStatusTransfer in WAIT HANDOVER REQUEST

@{Add_5QI1_Success}
...    Added QosFlow with QFI:2 fiveQI:1
...    rrcReconfigurationComplete
...    QoS Routing Table


${SA_UE_VoNR_Capabilities}    SEPARATOR=
...    E1A00000074E5A031E000380A03C1260C80008780818806804C020301C032A36146B04050D012CB2898087AD8202020E1DE38720C3
...    8002064F1F570004F001C0013C002A36266B04050D012CB2898087AD8202020E1DE38720C38002064F1F570004F001C0013C002A36
...    26EB04050D012CB2898087AD8202020E1DE38720C38002064F1F570004F001C0013C002A36276B04050D012CB2898087AD8202020E
...    1DE38720C38002064F1F55000005000000108389A00000000404D0301C020227B058060005038080E0600B00E000D07C0000000000
...    001CA9A0002000012CB2A00695550103800580000002004008D58980008101820283038405880889098C909293139425389B40

${UE_Capabilities_with_ANR_VONR}    SEPARATOR=
...    E1A00000074E5A031E00038420007824C1900010F09003100D00980C0301C032A36146B04050D012CB28986801EB608080838778E1C830E000
...    8193C7D5C0013C0070004F000A8D899AC10143404B2CA261A007AD8202020E1DE38720C38002064F1F570004F001C0013C002A3626EB04050D
...    012CB28986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D89DAC10143404B2CA261A007AD8202020E1DE38720C380020
...    64F1F55000005000000108389A00000000404D1700007008089EC2E003E00281C1401C0C026007000683E0000000000000E54D000100000965
...    950034AAA85800E001600000008010023562600020406080A0C0E10162022242632424A4C4E5094E26D0

${UE_Capabilities_with_ANR_NoVoNR}    SEPARATOR=
...    E1A00000074E5A031E000380A03C1260C8000878180C4034026010180E01951B0A3582028680965944C043D6C10101070EF1C39061C0010327
...    8FAB80027800E0009E00151B133582028680965944C043D6C10101070EF1C39061C00103278FAB80027800E0009E00151B1375820286809659
...    44C043D6C10101070EF1C39061C00103278FAB80027800E0009E00151B13B582028680965944C043D6C10101070EF1C39061C00103278FAA80
...    00028000000841C4D00000000202682807008089EC1601B00140E0601C0C01601C001A0F8000000000000395340004000025965400D2AAA020
...    7000B000000040080118B130001020304050607080B101112131921252627284A0


${kill_btslog}     timeout 5 sudo kill -9 $(ps -ef|grep btslog|grep -v grep|awk '{print $2}') 1>/dev/null 2>&1
${kill_dpkg}       timeout 5 sudo kill -9 $(ps -ef|grep dpkg|grep tti-dec.deb|grep -v grep|awk '{print $2}') 1>/dev/null 2>&1
*** Test Cases ***

CB013550_Case01_ULBIN1
    [Tags]    QC_222876    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    [Setup]    Case Precondition
    sleep      30s
    start_log_collection    log_type=${log_type}
    sleep      15s
    UE VONR attach
    Activate CB013550ULBIN1
    sleep      15s
    ${local_file_path}  Log Collection  stop_and_download  ${log_type}  product_type=gnb  bts_index=${0}
    sleep      15s
    Check Records    ${local_file_path}
   COAM_Admin.Login    bts_host=192.168.255.129
   [Teardown]    Case Postcondition

CB013550_Case02_CBIN1
    [Tags]    QC_222875    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    [Setup]    Case Precondition
    sleep      30s
    start_log_collection    log_type=${log_type}
    sleep      15s
    UE VONR attach
    Activate CB013550CBIN1
    sleep      15s
    ${local_file_path}  Log Collection  stop_and_download  ${log_type}  product_type=gnb  bts_index=${0}
    sleep      15s
    Check RecordsDL    ${local_file_path}
   COAM_Admin.Login    bts_host=192.168.255.129
   [Teardown]    Case Postcondition



*** Keywords ***
start_log_collection
    [Arguments]  ${log_type}=emil
    ${dict_argument}  Create Dictionary   dcap_server=${dcap_info}
    Log Collection    start  ${log_type}  product_type=gnb  bts_index=${0}  cudu_index=${0}  dict_argument=${dict_argument}

Check Records
    [Arguments]    ${trace_file}
#    ${trace_message_count}    Create Dictionary    DuHoSrcTraceRecord=0    UeCtxModificationTraceRecord=0
#    ...                                      DuUeReleaseTraceRecord=0
    ${multi_filters}   catenate   SEPARATOR=    "Message number"="DDAC"
    ${json_file_list}=    Log Analysis   check   emil   ${trace_file}   filter_emil=${multi_filters}    convert_type=json    product_type=gnb
    ${trace_info}    Get trace info from json file    ${json_file_list}
    Should Contain    ${trace_info[0]['Message_number']}    DDAC

Check RecordsDL
    [Arguments]    ${trace_file}
#    ${trace_message_count}    Create Dictionary    DuHoSrcTraceRecord=0    UeCtxModificationTraceRecord=0
#    ...                                      DuUeReleaseTraceRecord=0
    ${multi_filters}   catenate   SEPARATOR=    "Message number"="DDA6"
    ${json_file_list}=    Log Analysis   check   emil   ${trace_file}   filter_emil=${multi_filters}    convert_type=json    product_type=gnb
    ${trace_info}    Get trace info from json file    ${json_file_list}
    Should Contain    ${trace_info[0]['Message_number']}    DDA6


Activate CB013550CBIN1
    Airphone Execute Egate Command    cmd=trf_data_start ue=7 pdu=1 qfi=3 dir=dl kbps=500
    sleep    3s
    Airphone Execute Egate Command    cmd=bler_testmode_nr profile_id=1 vonr_lcid=5 num_vonr_mac_sdus_to_drop=50 arg_mute_duration_in_slots=850
    sleep    3s
    Airphone Execute Egate Command    cmd=ue_testmode_set_nr id=7 profile_id=1 testmode=bler scell=0 action=activate
    sleep    10s
    Airphone Execute Egate Command    cmd=ue_testmode_set_nr id=7 profile_id=1 testmode=bler scell=0 action=deactivate
    sleep    3s
    Airphone Execute Egate Command    cmd=ue_deregister id=7 ue_deregister_type=switch_off
    sleep    3s


Get trace info from json file
    [Arguments]    ${file_path}
#    ${trace_info_list}    Create List
    FOR    ${file}    IN    @{file_path}
        ${parsed_json}    OperatingSystem.Get File    ${file}
        ${context_dict}    json.Loads    ${parsed_json}
        ${trace_info}=    Set Variable    ${context_dict}[emil_data][rows]
    END
    [Return]    ${trace_info}

Counter Operation
    [Arguments]    ${operation}
    ...    ${product_type}=gnb  #enb
    ...    ${bts_index}=${0}
    ...    ${cudu_index}=${0}
    ...    ${counter_rule}=${EMPTY}
    ...    ${interval}=5
    ...    ${timeout}=${None}
    ...    &{kwargs}
    [Documentation]     this keyword contain the classical BTS normal operation
    ...   Author: winnie he
    ...   Contact: winnie.he@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | operation  | yes | operation can support "start_collect_counter",
    ...                        "collect_counter", "collect_counter_and_check_rule", "compare"]  |
    ...   | product_type | yes | product type can support enb, gnb, vcu, vdu |
    ...   | bts_index | No | the index of the bts in tl's init.py, ${tl.gnbs[gnb_index]} |
    ...   | cudu_index | No |  the index of the bts du in tl's init.py, ${tl.gnbs[gnb_index].dus[vdu_vcu_index]} |
    ...   | counter_rule | No | counter rule string list or text file path  |
    ...   | timeout | No | Mostly you no need to change this value, most of operation have their own default time |
    ...   | kwargs | No | other parameters you want to pass to the kw |
    ${product_type}    Convert To Lower Case    ${product_type}
    ${value}    Run Keyword If    '${product_type}' in ["enb", "gnb", "vcu", "vdu"]
    ...    _counter_operation.interface    operation=${operation}
    ...    product_type=${product_type}
    ...    bts_index=${bts_index}
    ...    cudu_index=${cudu_index}
    ...    counter_rule=${counter_rule}
    ...    interval=${interval}
    ...    timeout=${timeout}
    ...    &{kwargs}
    ...    ELSE
    ...    Fail    msg=Your product_type ${product_type} no support yet. Please contact the model owner.
    [Return]    ${value}
UE VONR attach
    Airphone Execute Egate Command    cmd=ue_register id=7
    sleep    3s
    Airphone Execute Egate Command    cmd=set_pdu_param ue=7 pdu=1 trf_type=internal
    sleep    3s
    Airphone Execute Egate Command    cmd=ue_pdu_session_setup ue=7 pdu=1 gw=1 nwslice=1
    sleep    3s
    Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue=7 pdu=1 qosflows_to_add=2 by=amf
    sleep    3s
    Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue=7 pdu=1 qosflows_to_add=3 by=amf
    sleep    3s

Activate CB013550ULBIN1
    ${cmd13550}    Catenate    trf_data_start ue=7 pdu=1 qfi=3 dir=ul trf_id=1 rtp_codec=custom rtp_send_silence_period=500
    ...       period_ms=500 burst=1 rtp_sn_skip_count=10 rtp_sn_skip_packet_count_interval=1 rtp_sn_skip_num_cycles=1
    Airphone Execute Egate Command    cmd=${cmd13550}
    sleep    20s
    Airphone Execute Egate Command    cmd=ue_deregister id=7 ue_deregister_type=switch_off
    sleep    3s


Activate CB013550ULBIN11
    ${cmd13550}    Catenate    trf_data_start ue=7 pdu=1 qfi=3 dir=ul trf_id=1 rtp_codec=custom rtp_send_silence_period=5000
    ...       period_ms=5000 burst=1 rtp_sn_skip_count=50 rtp_sn_skip_packet_count_interval=1 rtp_sn_skip_num_cycles=1
    Airphone Execute Egate Command    cmd=${cmd13550}
    sleep    100s
    Airphone Execute Egate Command    cmd=ue_deregister id=7 ue_deregister_type=switch_off
    sleep    3s





Case Precondition
    Clean Up Env
    Airphone Common Setup    local_wts_dir=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/CB013550/TL_Airphone/config/wts.cfg
    ...                      scf_file_path=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/CB013550/TL_Airphone/config/scf.xml
    ...                      iphy_path=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/CB013550/TL_Airphone/config/iphy.xml
    ...             gnb_swconfig_local_path=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/CB013550/TL_Airphone/config/swconfigR.txt
    Run Keyword And Ignore Error    HAZ TC02 Get SCF Internal Id By Scout    no_ute=False
Case Precondition CB012209_07
    log to console    Case Precondition
    Common Test Setup For RRM
    Airphone Common Setup    local_wts_dir=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/TL_Airphone/config/wts.cfg
    ...                      iphy_path=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/TL_Airphone/config/iphy.xml
    ...                      scf_file_path=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/TL_Airphone/config/scf_07.xml
    Airphone Execute Egate Command    cmd=set_log flush
    Airphone Execute Egate Command    cmd=state_sim_disp
    Start Btslog Collect    names=btslog1

Case Postcondition
    log to console    Case Postcondition
    Airphone Common Teardown
    COAM_Admin.Logout

Prepare UE History Information
    Airphone Execute Egate Command    cmd=ue_change_location id=1-2 cell=1
    Airphone Execute Egate Command    cmd=ue_change_location id=3 cell=2
    Airphone Execute Egate Command    cmd=state_sim_disp
    Airphone Execute Egate Command    cmd=gnb_param id=3 xn_listening_socket=1 send_xn_setup=true measEvent=A3

Preconditions for UE HO Back
    Airphone Execute Egate Command    cmd=ue_reauth id=1 nr_sec_cap=aes|aes
    Airphone Execute Egate Command    cmd=amf_path_switch_param id=1 include_ue_sec_cap=on
    Airphone Execute Egate Command    cmd=smf_param id=1 security_indication=path_switch:preferred:preferred max_data_rate=20mbps

Trigger Xn links is Up
    [Arguments]    ${pass_regexp}=XnAP Link with GNB-2 .* is up
    sleep    120s
    ${cmd1}    Catenate    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true sib1_period=160ms
    Airphone Execute Egate Command    cmd=${cmd1}
    ${cmd2}    Catenate    gnb_xn_link_up gnb=3 target=2
    Airphone Execute Egate Command    cmd=${cmd2}    pass_regexp=${pass_regexp}
    sleep    5s

Delay Response to Xn Handover Preparation
    Airphone Execute Egate Command    cmd=gnb_xn_handover_preparation_param id=3 action=delayed_rsp time_to_wait=v5s

Reset Xn Handover Preparation Param
    Airphone Execute Egate Command    cmd=gnb_xn_handover_preparation_param id=3 reset

UE Attach
    [Arguments]    ${ue_id}=7    ${pass_regexp}=QoS Routing Table
#    sleep    120s
    Airphone Execute Egate Command    cmd=ue_register id=${ue_id}
    sleep    5s
    Airphone Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    sleep    5s
    Airphone Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1    pass_regexp=${pass_regexp}
    sleep    1min

Trigger intraFreANR with the concurrency
    [Arguments]    ${ue_id}=24    ${target_cell}=381    ${action}=send_nas_pdu_session_modify

    ${CGI_cmd}    Catenate    ue_nr_rrc_reconf_param id=${ue_id} if_contains=report_cgi anr_cgi_delay=100ms
    ...                      action=${action} pduSessionInfo=1:24:1:1:1:0 qosflows_to_add=2
    Airphone Execute Egate Command    cmd=${CGI_cmd}
    ${HO_cmd}    Catenate  ue_measurement_send_nr id=${ue_id} meas_id=3 event=A3 srsrp_nr=5 srsrq_nr=5
    ...               phycell_id=${target_cell} nrsrp_nr=100 nrsrq_nr=100
     Airphone Execute Egate Command    cmd=${HO_cmd}
#     ...    timeout=120    pass_regexp=${pass_regexp_ANR}
    sleep    2min

Trigger intraFreANR with the concurrency2
    [Arguments]    ${ue_id}=24    ${target_cell}=381    ${action}=send_nas_pdu_session_modify

    ${CGI_cmd}    Catenate    ue_nr_rrc_reconf_param id=${ue_id} if_contains=report_cgi anr_cgi_delay=100ms
    ...                      action=${action} pduSessionInfo=1:24:1:1:1:0 qosflows_to_add=2
    Airphone Execute Egate Command    cmd=${CGI_cmd}
    ${HO_cmd}    Catenate  ue_measurement_send_nr id=${ue_id} meas_id=7 event=A3 srsrp_nr=5 srsrq_nr=5
    ...               phycell_id=${target_cell} nrsrp_nr=100 nrsrq_nr=100
     Airphone Execute Egate Command    cmd=${HO_cmd}
#     ...    timeout=120    pass_regexp=${pass_regexp_ANR}
    sleep    2min

UEs Trigger Inter-gNB Intra-FreqANR HO
    [Arguments]    ${ue_id1}=24
    Trigger Inter-gNB Intra-FreqANR HO Concurrency With PDU Session Mofication    ${ue_id1}

Trigger Inter-gNB Intra-FreqANR HO Concurrency With PDU Session Mofication
    [Arguments]    ${ue_id}=24    ${target_cell}=381    ${action}=send_nas_pdu_session_modify
    Set PCI-ANR resolution time delay    ${ue_id}    ${action}
    ${cmd1}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=7 event=A3 srsrp_nr=5 srsrq_nr=5
    ${cmd2}    Catenate   phycell_id=${target_cell} nrsrp_nr=100 nrsrq_nr=100
    ${HO_cmd}    Catenate    ${cmd1}    ${cmd2}
    Airphone Execute Egate Command    cmd=${HO_cmd}

Set PCI-ANR resolution time delay
    [Arguments]    ${ue_id}    ${action}=send_nas_pdu_session_modify
    ${cmd_action}=    Catenate    action=${action} pduSessionInfo=1:${ue_id}:1:1:1:0 qosflows_to_add=2
    Airphone Execute Egate Command    cmd=ue_nr_rrc_reconf_param id=${ue_id} if_contains=report_cgi anr_cgi_delay=500ms ${cmd_action}

Intra fre Handover Return
    [Arguments]    ${ue_id}=24
    Airphone Execute Egate Command    cmd=ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    ${ho_cmd}    Catenate    ue_measurement_send_nr id=24 meas_id=3 event=A3 srsrp_nr=11 phycell_id=51 nrsrp_nr=85
    Airphone Execute Egate Command    cmd=${ho_cmd}

Delete NRREL
    ${rm_ob_list}    Create List
    ${rm_ob_name}    Set Variable    MRBTS-1/NRBTS-1/NRCELL-2/NRREL-256
    Wait Until Keyword Succeeds    3m    1m    COAM_Admin.Login
    ${ret}    ${value}     Run Keyword And Ignore Error
    ...    coam.get_parameters   dist_name=MRBTS-1/NRBTS-1/NRCELL-2/NRREL-256
    ...    connection=COAM
    Run Keyword If   '${ret}'=='Fail'    Fail    NRREL-256 doesn't deleted
    coam_admin.perform_object_recommissioning    dist_name=${rm_ob_name}    parameter_delta_list=${rm_ob_list}
    ...    operation=delete    connection=COAM
    [Teardown]    COAM_Admin.Logout

Concurrent PDU Modification during HO Preparation Based Feature Enabled
    [Arguments]    ${ue_id}=7    ${A2_meas_id}=1   ${A3_meas_id}=5    ${pass_regexp}=Added QosFlow with QFI:2 fiveQI:1
    Airphone Execute Egate Command    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${A2_meas_id} event=A2 srsrp_nr=7 srsrq_nr=7
    ...    pass_regexp=rrcReconfigurationComplete
    sleep    5s
    ${ho_cmd}  Catenate  ue_measurement_send_nr id=${ue_id} meas_id=${A3_meas_id} event=A3 srsrp_nr=11 phycell_id=381 nrsrp_nr=85
    Airphone Execute Egate Command    cmd=${ho_cmd}
    Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 by=amf
    ...    pass_regexp=${pass_regexp}
    sleep    5s
    Airphone Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=2 trf_id=1 mbps=5 dir=dl protocol=tcp
    sleep    5s
    #Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=3 by=amf
    #sleep    5s
    #Airphone Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=3 trf_id=1 mbps=5 dir=dl
    #sleep    5s

Concurrent PDU Modification during HO Preparation Based Feature and PCMD Enabled
    [Arguments]    ${ue_id}=7    ${A2_meas_id}=1   ${A3_meas_id}=6    ${pass_regexp}=Added QosFlow with QFI:2 fiveQI:1
    Airphone Execute Egate Command    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${A2_meas_id} event=A2 srsrp_nr=7 srsrq_nr=7
    ...    pass_regexp=rrcReconfigurationComplete
    sleep    5s
    ${ho_cmd}  Catenate  ue_measurement_send_nr id=${ue_id} meas_id=${A3_meas_id} event=A3 srsrp_nr=11 phycell_id=381 nrsrp_nr=85
    Airphone Execute Egate Command    cmd=${ho_cmd}
    Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 by=amf
    ...    pass_regexp=${pass_regexp}
    sleep    5s
    Airphone Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=2 trf_id=1 mbps=5 dir=dl protocol=tcp
    sleep    5s

Rejection of Voice Service during XN-HO Preparation
    [Arguments]    ${ue_id}=1    ${A2_meas_id}=1   ${A3_meas_id}=5
    Airphone Execute Egate Command    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${A2_meas_id} event=A2 srsrp_nr=7 srsrq_nr=7
    ...    pass_regexp=rrcReconfigurationComplete
    sleep    5s
    ${ho_cmd}  Catenate  ue_measurement_send_nr id=${ue_id} meas_id=${A3_meas_id} event=A3 srsrp_nr=11 phycell_id=381 nrsrp_nr=85
    Airphone Execute Egate Command    cmd=${ho_cmd}
    Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 by=amf
    sleep    5s
    Airphone Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=2 trf_id=1 mbps=5 dir=dl protocol=tcp
    sleep    5s
    Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=3 by=amf
    sleep    5s
    Airphone Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=3 trf_id=1 mbps=5 dir=dl
    sleep    5s

Concurrent PDU Modification during HO Execution Based Feature Enabled
#    [Arguments]    ${ue_id}=7    ${timeout}=150    ${pass_regexp}=${Add_5QI1_failed_and_HO_Success}
    [Arguments]    ${ue_id}=7
    sleep    5s
    Airphone Execute Egate Command    cmd=ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    Airphone Execute Egate Command    cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 event=A2 srsrp_nr=7 srsrq_nr=7
    ...    pass_regexp=rrcReconfigurationComplete
    sleep    5s
    Airphone Execute Egate Command    cmd=ue_nr_rrc_reconf_param id=${ue_id} reset
    Airphone Execute Egate Command    cmd=ue_nr_rrc_reconf_param id=${ue_id} if_contains=any delay=2000
    Airphone Execute Egate Command    cmd=ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    ${ho_cmd}  Catenate  ue_measurement_send_nr id=${ue_id} meas_id=5 event=A3 srsrp_nr=11 phycell_id=381 nrsrp_nr=85
    Airphone Execute Egate Command    cmd=${ho_cmd}
    Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 by=amf
#    Airphone Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=2 trf_id=1 mbps=5 dir=dl protocol=tcp
#    ...    timeout=${timeout}    pass_regexp=${pass_regexp}
#    Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=3 by=amf
#    Airphone Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=3 trf_id=1 mbps=5 dir=dl

Check Counter for CB013550
    Sleep   320s
	${pi_list}=  Create List    M55350C20034    M55350C20045
    ${expect_value}    Set Variable    0
    FOR  ${counter_ID}  IN  @{pi_list}
           ${counter_id_value_list}    Check counter value   counter_ID=${counter_ID}
           ...                                               expect_value=${expect_value}
    END

Check Counter for CB012209_03
    Sleep   500s
	${pi_list}=  Create List    M55125C00035    M55147C00024    M55124C02002    M55125C09517
    ${expect_value}    Set Variable    0
    FOR  ${counter_ID}  IN  @{pi_list}
           ${counter_id_value_list}    Check counter value   counter_ID=${counter_ID}
           ...                                               expect_value=${expect_value}
    END
	${counter_values_list2}    Check counter value equal expect value1    counter_ID=M55143C00003    expect_value=0

Get PM counter values
    [Arguments]    ${pi_list}=0    ${PM_counter_path}=${PM_counter_path}    ${oam_type}=coam
    [Documentation]    Get PI values at managed objects per measurement period for a given list of PI IDs.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | pi_list | No | define pi list |
    ...    | PM_counter_path | No | define path of PM counter |
    ...    | oam_type | No | define oam type |
    ...
    ...    | Return Value | Description |
    ...    | ${pi_value_list} | return list of Pi value |
    ...
    ...    Example
    ...    | Get_PM_counters_values | pi_list=0 | PM_counter_path=${PM_counter_path} | oam_type=coam |
    ...
    ${cmd}=    set variable if    '${oam_type}'=='mzoam'    cd "${PM_counter_path}";ls -dr1 *PM_*_SRAN |head -1
    ...    cd "${PM_counter_path}";ls -dr1 *PM.BTS-1*.xml |head -1
    ${pm_filename}    Run    ${cmd}
    ${pi_value_list}    get_pi_value    pi_list=${pi_list}    pi_dir=${PM_counter_path}    pi_file_pattern=${pm_filename}
    Set Suite Variable    ${pi_value_list}
    [Return]    ${pi_value_list}

Sum Counter Value Of Pi Value List
    [Arguments]    ${pi_list}    ${counter}    ${dn}=${None}
    ${counter_info_list}    Create List
    FOR    ${time_counter_infos}    IN    @{pi_list}
        ${counter_info}    Get Dictionary Values    ${time_counter_infos}
        ${counter_info_list}     Combine Lists    ${counter_info_list}    ${counter_info}
    END
    ${all counter values}    Create List
    FOR    ${counter_info}    IN    @{counter_info_list}
        ${is_contain}    Run Keyword And Return Status    Dictionary Should Contain Key
        ...    ${counter_info}    ${counter}
        Continue For Loop If    ${is_contain}==${False}
        ${is_contain_dn}    Run Keyword And Return Status    Dictionary Should Contain Key
        ...    ${counter_info}[${counter}]    ${dn}
        ${counter values}     Run Keyword If    '${is_contain_dn}'=='${True}'
        ...    Create List    ${counter_info}[${counter}][${dn}]
        ...    ELSE    Get Dictionary Values    ${counter_info}[${counter}]
        ${all counter values}    Combine Lists    ${counter values}    ${all counter values}
    END
    ${length}    Get Length    ${all counter values}
    ${sum_value}    Set Variable If    ${length}!=${0}    ${0}    ${None}
    FOR    ${i}    IN    @{all counter values}
        ${value}    Convert To Integer     ${i}
        ${sum_value}    evaluate    ${sum_value}+${value}
    END
    [Return]    ${sum_value}

Check PM Counters for CB012209_01
    Sleep   500s
    ${pi_list}    Create List    M55308C23002    M55308C32000    M55125C09031    M55143C00003    M55143C01504
    ${expect_value}    Set Variable    0
    FOR  ${counter_ID}  IN  @{pi_list}
           ${counter_id_value_list}    Check counter value   counter_ID=${counter_ID}
           ...                                               expect_value=${expect_value}
    END

Check PM Counters for CB012209_002
    Sleep   500s
    ${pi_list}    Create List    M55125C00035    M55125C09517    M55147C00024    M55124C02002
    ${expect_value}    Set Variable    0
    FOR  ${counter_ID}  IN  @{pi_list}
           ${counter_id_value_list}    Check counter value   counter_ID=${counter_ID}
           ...                                               expect_value=${expect_value}
    END
	${counter_values_list2}    Check counter value equal expect value1    counter_ID=M55143C00003    expect_value=0
 	${counter_values_list2}    Check counter value equal expect value1    counter_ID=M55143C01504    expect_value=0

Download wireshark plugin
    ${ver}   Run   ls ${plugin_folder}/
    ${exist}   Run   cd ${plugin_folder}/${ver}/epan;ls nsetapx*
    Run Keyword If   ${exist.count('No such file or directory')}>0   Run
    ...   cd ${plugin_folder}/${ver}/epan;sudo wget ${nsetapx_plugin_addr}

Start Tcpdump Log
    Log To Console    start tcpdump
    ${tcpdump_log_name}=    Start tcpdump in SBTS
    Set Suite Variable    ${tcpdump_log_name}

Stop Tcpdump Log
    Log To Console    stop tcpdump
    ${capture_file_path}    ${input_file}=    Stop Tcpdump in SBTS
    set test variable    ${capture_file_path}

Decode tcpdump
    [Arguments]    ${input_file}=${capture_file_path}    ${filter_expression}=nsetapx.result == 2
    ${tshark_comd}  catenate    tshark -r ${input_file} -o ntrstr.defragment:TRUE  -d tcp.port==49151,ntrstr
    ...  -d tcp.port==49148,ntrstr -d tcp.port==15000-15500,ntrstr -Y ${filter_expression}
    ${filtered_packets}    Run    ${tshark_comd}
    [Return]    ${filtered_packets}

Check tcpdump log
    Log To Console    check tcpdump log
    Decode tcpdump    input_file=${capture_file_path}   filter_expression=nsetapx.result == 2

Open DCAP
    OperatingSystem.Run    DCAP_Basic_controller start

Clean Up Env
    [Arguments]    ${host_ip}=localhost
    [Documentation]    This keyword is to clean up testline process such as btslog and so on.
    ...    Examples:
    ...    | Clean Up Env |
	Run Keyword If     '${host_ip}'=='127.0.0.1' or '${host_ip}'=='localhost'    Run Keywords    Run     ${kill_btslog}
	...     AND     Run   ${kill_dpkg}
	...     AND     Run    rm /tmp/admin_api_*.txt -f
	...     AND     Run    rm /tmp/disconnect*.ims2 -f
	...     AND     Run    rm /tmp/*.pcap* -rf
	...     AND     Run    sudo rm /tmp/*.pcap* -rf
	...     ELSE    Run keywords    SSH.Connect To    ${host_ip}    ute    ute    alias=remote_connection
	...     AND     SSH.Execute    ${kill_btslog}    connection=remote_connection
    ...     AND     SSH.Disconnect    connection=remote_connection

Update bsr package
    Run     mkdir ${CURDIR}/BSR
    ${dllink}   Set Variable     https://artifactory-espoo1.int.net.nokia.com:443/artifactory/mnpute-rotta-local/BSR
    ${filename}    Set variable     BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
    Run     wget ${dllink}/${filename} -P ${CURDIR}/BSR
    coam.setup admin
    ${ret}     coam.Update Software      ${CURDIR}/BSR/BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
    coam.teardown admin

Teardown_for_CNI-129708
    Log To Console    \nstop test
#    ute_wtssim.Execute Egate Command    cmd=ue_sgnb_mod_param id=${NSA_UE_ID} reset
#    ute_wtssim.Execute Egate Command    cmd=ue_enb_endc_param id=${NSA_UE_ID} reset
#    ute_wtssim.Execute Egate Command    cmd=enb_endc_param id=1 reset
#    ute_wtssim.Execute Egate Command    cmd=ue_detach id=${NSA_UE_ID}
#    ${local_file_path}    Run Keyword And Ignore Error  Log Collection  stop_and_download  ${log_type}  product_type=gnb
#      ...    bts_index=${0}
#    HAZ TC02 Get SCF Internal Id By Scout  no_ute=False