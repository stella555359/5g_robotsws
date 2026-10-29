*** Settings ***
Resource    ./../Resources/CB008140_common_keywords_multiUE.robot
Variables    ./Resources/CB008140_G_variables_2gnb.py

Documentation
...   author: qingqing.zhang
...   contact: qingqing.zhang@nokia-sbell.com
...   squad group: SG_03
...   Feature CB008140-GG

Suite Setup    Run Keywords
...            robot_common_operations.Common Suite Setup
...            AND    Common Suite Setup for COAM


Suite Teardown    Run Keywords
...               Enb TestLine Setup recover    AND
...               robot_common_operations.Common Suite Teardown    AND
...               Run Keyword And Ignore Error    Common Suite Teardown for COAM   AND
...               Run Keyword And Ignore Error    COAM Teardown gnb connections


*** Variables ***
${tl_scf_gnb0}    SCF_GNB1_
${tl_scf_gnb1}    SCF_GNB2_
${filename_003_gnb0}    log1_name_GG_003_gNB1.pcap
${filename_003_gnb1}    log1_name_GG_003_gNB2.pcap
${filename1_003_gnb0}    log2_name_GG_003_gNB1.pcap
${filename1_003_gnb1}    log2_name_GG_003_gNB2.pcap
@{filename_GG003}    filename_003_gnb    filename1_003_gnb
#${filename_004_gnb0}    log1_name_GG_004_gNB1.pcap
#${filename_004_gnb1}    log1_name_GG_004_gNB2.pcap
#${filename1_004_gnb2}    log2_name_GG_004_gNB2.pcap
#${filename1_004_gnb3}    log2_name_GG_004_gNB4.pcap
#@{filename_GG004}    filename_004_gnb    filename1_004_gnb
#${filename_008_gnb2}    log1_name_GG_008_gNB3.pcap
#${filename_008_gnb3}    log1_name_GG_008_gNB4.pcap
#@{filename_GG008}    filename_008_gnb
@{gnb_ips_GG}    ${bts_host0}    ${bts_host1}
@{gnb_list_GG}    ${0}    ${1}
@{scell_index_list_GG003}    ${1}
@{extgnb_index_list_GG003}    ${0}
${PMfile_gnb1}    8140_GG_008_counter_gnb1.xml
${PMfile_gnb2}    8140_GG_008_counter_gnb2.xml

${epc_log_path}    /opt/workspace/CRT/Master/Case_Logs/

${normal_release}    10
@{expected_xml_value_GG008_gnb1}    1    1
@{expected_xml_value_GG008_gnb2}    1
@{cell_id_GG008_gnb1}    ${1}    ${1}
@{cell_id_GG008_gnb2}    ${0}
@{counter_gnb3_GG008_value}    ${1}    ${1}    ${1}
@{counter_gnb4_GG008_value}    ${1}    ${1}    ${1}    ${1}    ${1}

${Send_Tput_DL_F_F}    250M
${expected_tput_dl_F}    390
${expected_tput_dl_F_IMS}    100
@{branch}    SBTS23R4_ENB_0000    SBTS23R3_ENB_0000    SBTS24R2_ENB_9999
*** Test Cases ***
[1]CB008140-5G-GG_003_Successful_ext-scell_addition_with_slicing_and_RanSharing
    [Documentation]  This user scenario describes the successful IgNB-CA SCell Addition procedure when the candidate ext-SCells
    ...     support the same slices of the UE’s PCell and with RAN sharing enabled either in prime- or in ext-gNB or in both.
    [Tags]     classical    CRT_TRUNK
    [Timeout]    2 hour
    [Setup]    robot_common_operations.Common Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    Common Case TestLine Setup for GG003
    MultiUE.Prepare UE
    Adjust gNB_RU Attenuation for 2gnb    gnb2_cell2_value=${0}
    Start capture multi gNB log    filename=filename_003_gnb    gnb_list=${gnb_list_GG}
    MultiUE.Attach
    Stop capture multi gNB log    filename=filename_003_gnb    gnb_list=${gnb_list_GG}
    Check wireshark log for GG003    logname=${filename_003_gnb1}    logname1=${filename_003_gnb0}
    MultiUE.Detach
    Modify Parameters for HD006
    Adjust gNB_RU Attenuation for 2gnb    gnb2_cell2_value=${0}    gnb1_cell1_value=${0}
    Start capture multi gNB log    filename=filename1_003_gnb    gnb_list=${gnb_list_GG}
    MultiUE.Attach
    Stop capture multi gNB log    filename=filename1_003_gnb    gnb_list=${gnb_list_GG}
    MultiUE.Start DLUL traffic and check 2CC tput    scellid=${1}    pcellid=${2}    tput_dl_pcell=${expected_tput_dl_F}
    ...    tput_dl_scell=${expected_tput_dl_F}    gnb_prime=${1}    gnb_external=${0}    dl_throughput=${Send_Tput_DL_F_F}
    ...    process_num=${5}
    MultiUE.Stop DLUL traffic
    Start DL traffic with IMS IP    traffic=${Send_Tput_DL_F_F}    logname=${filename1_003_gnb1}
    sleep    30s
    Check 2CC DLUL tput     tput_dl_pcell=${expected_tput_dl_F_IMS}    tput_dl_scell=${expected_tput_dl_F_IMS}
    ...     scellid=${1}    pcellid=${2}    gnb_prime=${1}    gnb_external=${0}
    MultiUE.Stop DLUL traffic
    MultiUE.Detach
    Hanging resource test    gnb_ips=@{gnb_ips_GG}    gnb_list=${gnb_list_GG}
    [Teardown]    run keywords
    ...    robot_common_operations.Common Case Teardown    AND
    ...    MultiUE.Detach    AND
    ...    Run Keyword And Ignore Error    Case Teardown    filename=${filename_GG003}    AND
    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation

#[1]CB008140-5G-GG_004_Successful_ext-scell_addition_with_slicing_and_RanSharing_and_TransportRanSharing
#    [Documentation]  This user scenario describes the successful IgNB-CA SCell Addition procedure when the candidate
#    ...      ext-SCells support the same slices of the UE’s PCell and with RAN sharing and TransportRanSharingenabled
#    ...      either in prime- or in ext-gNB or in both.
#    [Tags]     classical    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]    robot_common_operations.Common Case Setup
#    Common Case TestLine Setup for GG004
#    MultiUE.Prepare UE
#    Adjust gNB_RU Attenuation    gnb3_cell1_value=${0}
#    Start capture multi gNB log    filename=filename_004_gnb    gnb_list=${gnb_list_GG}
#    MultiUE.Attach
#    Stop capture multi gNB log    filename=filename_004_gnb    gnb_list=${gnb_list_GG}
#    Check wireshark log for GG004    logname=${filename_004_gnb2}    logname1=${filename_004_gnb3}
#    MultiUE.Detach
#    Common Case TestLine Setup with singe BTS    gnb_index=${2}    ModifySCF_Beforecommission=True
#         ...    golden_scf_name=${golden_scf_name_gnb2}
#         ...    MOsToAdd=${MOS_ADD_GNB3_GG004}    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB3_GG004_2}
#         ...    ListToAdd=${LIST_TO_ADD_GNB3_GG004_2}    ParameterToDelete=${PARAMETERS_TO_DELETE_GNB3_GG004_2}
#    Start capture multi gNB log    filename=filename1_004_gnb    gnb_list=${gnb_list_GG}
#    MultiUE.Attach
#    Stop capture multi gNB log    filename=filename1_004_gnb    gnb_list=${gnb_list_GG}
#    Check wireshark log for GG004    logname=${filename1_004_gnb2}    logname1=${filename1_004_gnb3}
#    MultiUE.Detach
#    Hanging resource test    gnb_ips=@{gnb_ips_GG}    gnb_list=${gnb_list_GG}
#    [Teardown]    run keywords
#    ...    robot_common_operations.Common Case Teardown    AND
#    ...    MultiUE.Detach    AND
#    ...    Run Keyword And Ignore Error    Case Teardown    filename=${filename_GG004}    AND
#    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation
#
#[1]CB008140-5G-GG_008_Ext-scell_addition_fail_due_to_incompatible_IP_protocol_version
#    [Documentation]  his user scenario describes the failure in of the IgNB-CA SCell Addition procedure when no valid DRB
#    ...    group can be found for the DRB to split.
#    [Tags]     classical    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]    robot_common_operations.Common Case Setup
#    Common Case TestLine Setup for GG008
#    MultiUE.Prepare UE
#    Adjust gNB_RU Attenuation    gnb3_cell1_value=${0}
#    Prepare with PM counter time to caculate    period=start
#    Start capture multi gNB log    filename=filename_008_gnb    gnb_list=${gnb_list_GG}
#    MultiUE.Attach
#    Stop capture multi gNB log    filename=filename_008_gnb    gnb_list=${gnb_list_GG}
#    Check wireshark log for GG008    logname=${filename_008_gnb2}    logname1=${filename_008_gnb3}
#    Wait until keyword succeeds    3min    20s    Check counter for GG008
#    MultiUE.Detach
#    Hanging resource test    gnb_ips=@{gnb_ips_GG}    gnb_list=${gnb_list_GG}
#    [Teardown]    run keywords
#    ...    robot_common_operations.Common Case Teardown    AND
#    ...    MultiUE.Detach    AND
#    ...    Run Keyword And Ignore Error    Case Teardown    filename=${filename_GG008}    AND
#    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation

*** Keywords ***
Common Case TestLine Setup for GG003
    ${release_info}    Get sagnb release
    @{scf_list}    Create List
    ${scf_gnb0}    Only Modify SCF before Perform Commission    gnb_index=${0}
    ...    golden_scf_name=${tl_scf_gnb0}${release_info}.xml
    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB1_GG003}    ListToAdd=${LIST_TO_ADD_GNB1_GG003}
    ...    ParameterToDelete=${PARAMETERS_TO_DELETE_GNB1_GG003}
#    ${scf_gnb1}    Run keyword if    '${gnb_instance0}' == '@{gnb_id}[1]'
#    ...    Only Modify SCF before Perform Commission    gnb_index=${1}
#    ...    golden_scf_name=${tl_scf_gnb1}${release_info}.xml    ListToAdd=${LIST_TO_ADD_GNB3_GG003_386}
#    ...    ListParamterToModify=${LIST_TO_modify_GNB2_GG003}     MOsToAdd=${MOS_ADD_GNB3_GG003_386}
#    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB3_GG003_386}
#    ...    ParameterToDelete=${PARAMETERS_TO_DELETE_GNB2_GG003}
#     ...   ELSE
    ${scf_gnb1}    Only Modify SCF before Perform Commission    gnb_index=${1}
    ...    golden_scf_name=${tl_scf_gnb1}${release_info}.xml    ListToAdd=${LIST_TO_ADD_GNB2_GG003}
    ...    ListParamterToModify=${LIST_TO_modify_GNB2_GG003}     MOsToAdd=${MOS_ADD_GNB2_GG003}
    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB2_GG003}
    Append to List    ${scf_list}    ${scf_gnb0}    ${scf_gnb1}
    Log to console    Start to modify scf files and commission, please wait...
    Multi-gNB commission    index_list=${gnb_list_GG}    scf_list=${scf_list}
    Check the MultiBTS cells status on air    gnb_list=${gnb_list_GG}
    Run keyword if    '${gnb_instance0}' == '${gnb_id}[2]'
    ...    Run keywords    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-372    parameter=administrativeState     value=locked
    ...    AND    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-375    parameter=administrativeState     value=locked
    ...    AND    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-376    parameter=administrativeState     value=locked
    ...    ELSE    Run keywords    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-362    parameter=administrativeState     value=locked
    ...    AND    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-365    parameter=administrativeState     value=locked

Enb TestLine Setup recover
    Run keyword if    '${gnb_instance0}' == '${gnb_id}[2]'
    ...    Run keywords    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-372    parameter=administrativeState     value=unlocked
    ...    AND    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-375    parameter=administrativeState     value=unlocked
    ...    AND    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-376    parameter=administrativeState     value=unlocked
    ...    ELSE    Run keywords    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-362    parameter=administrativeState     value=unlocked
    ...    AND    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-365    parameter=administrativeState     value=unlocked

Common Case TestLine Setup for GG004
    @{scf_list}    Create List
    ${scf_gnb2}    Only Modify SCF before Perform Commission    gnb_index=${2}
    ...    golden_scf_name=${golden_scf_name_gnb2}
    ...    MOsToAdd=${MOS_ADD_GNB3_GG004}    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB3_GG004}
    ...    ListToAdd=${LIST_TO_ADD_GNB3_GG004}    ParameterToDelete=${PARAMETERS_TO_DELETE_GNB3_GG004}
    ${scf_gnb3}    Only Modify SCF before Perform Commission    gnb_index=${3}
    ...    golden_scf_name=${golden_scf_name_gnb3}
    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB4_GG008}    ListToAdd=${LIST_TO_ADD_GNB4_GG004}
    ...    ParameterToDelete=${PARAMETERS_TO_DELETE_GNB4_GG008}
    Append to List    ${scf_list}    ${scf_gnb2}    ${scf_gnb3}
    Log to console    Start to modify scf files and commission, please wait...
    Multi-gNB commission    index_list=${gnb_list_GG}    scf_list=${scf_list}
    Check the MultiBTS cells status on air    gnb_list=${gnb_list_GG}

Common Case TestLine Setup for GG008
    @{scf_list}    Create List
    ${scf_gnb2}    Only Modify SCF before Perform Commission    gnb_index=${2}
    ...    golden_scf_name=${golden_scf_name_gnb2}    ListToAdd=${LIST_TO_ADD_GNB3_GG008}
    ...    MOsToAdd=${MOS_ADD_GNB3_GG008}    ParameterToDelete=${MO_TO_DELETE_GNB3_GG008}
    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB3_GG008}
    ${scf_gnb3}    Only Modify SCF before Perform Commission    gnb_index=${3}
    ...    golden_scf_name=${golden_scf_name_gnb3}
    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB4_GG008}    ListToAdd=${LIST_TO_ADD_GNB4_GG008}
    ...    ParameterToDelete=${PARAMETERS_TO_DELETE_GNB4_GG008}
    Append to List    ${scf_list}    ${scf_gnb2}    ${scf_gnb3}
    Log to console    Start to modify scf files and commission, please wait...
    Multi-gNB commission    index_list=${gnb_list_GG}    scf_list=${scf_list}
    Check the MultiBTS cells status on air    gnb_list=${gnb_list_GG}

Modify Parameters for HD006
    Modify Parameters for Cases   gnb_index=${1}    Add_Para_Online=${LIST_TO_ONLINE_ADD_GNB2_HD006}
    Modify Parameters for Cases   gnb_index=${0}    Add_Para_Online=${LIST_TO_ONLINE_ADD_GNB1_HD006}
    ...    Delete_Para_Online=${PARAMETERS_TO_DELETE_GNB1_HD006}

Check counter for GG008
    ${release_info}    Get sagnb release
    Run keyword if    '${release_info}' == '${branch}[2]'    Check counter for GG008 for trunk
    ...    ELSE    Check counter for GG008 for branch

Check counter for GG008 for trunk
    Check the PM counter should be value
    ...    gnb_index=${2}    counter_id=${counter_id_GG008_gNB3}
    ...    dic_path=${counter_dic_path_GG008_gNB3_trunk}    value=@{counter_gnb3_GG008_value}
    Check the PM counter should be value
    ...    gnb_index=${3}    counter_id=${counter_id_GG008_gNB4}
    ...    dic_path=${counter_dic_path_GG008_gNB4_trunk}    value=@{counter_gnb4_GG008_value}

Check counter for GG008 for branch
    Check the PM counter should be value
    ...    gnb_index=${2}    counter_id=${counter_id_GG008_gNB3}
    ...    dic_path=${counter_dic_path_GG008_gNB3}    value=@{counter_gnb3_GG008_value}
    Check the PM counter should be value
    ...    gnb_index=${3}    counter_id=${counter_id_GG008_gNB4}
    ...    dic_path=${counter_dic_path_GG008_gNB4}    value=@{counter_gnb4_GG008_value}

Check wireshark log for GG008
    [Arguments]    ${logname}    ${logname1}
    Get cell id multignb    lcrid_pcell=${1}    scell_index_list=${scell_index_list_GG003}
    ...    PrimegNB_index=${2}    extgnb_index_list=${extgnb_index_list_GG003}
    ${xgU_addr_gnb1}=    Check value of parameter xgUplane address    WEBUI_COAM=${WEBUI_host2}
    ...    xgU_addr=ipV6AddressDN1    filter_param_DN=IPv6 address 1 distinguished name    filter_param_local=Local IPv6 address
    ${xgU_addr_gnb2}=    Check value of parameter xgUplane address    WEBUI_COAM=${WEBUI_host3}
    ...    xgU_addr=ipV4AddressDN1    filter_param_DN=IPv4 address 1 distinguished name    filter_param_local=Local IPv4 address
    ###check prime log
    Check 1st IgNBCAUeContextModificationRequest message has igNBCASetup on PrimegNB   logname=${logname}
    Check IgNBCAUeContextModificationResponse has transport messages on PrimegNB    logname=${logname}    xgU_addr=${xgU_addr_gnb1}
    ...    xpath=.//nokiaf1ap.transportLayerAddressIPv6
    Check IgNBCAAdditionRequest message has pGNBIP and pcellid and scellid on PrimegNB   logname=${logname}
    ...    xpath=.//nokiaxnap.TransportLayerAddressIPv6    xpu_gnb=${xgU_addr_gnb1}
    Check IgNBCAAdditionRequestReject message on PrimegNB and ExtgNB    logname=${logname}
    Check 2st IgNBCAUeContextModificationRequest message with CA cancel on PrimegNB    logname=${logname}
    Check 2st IgNBCAUeContextModificationResponse message with CA cancel on PrimegNB    logname=${logname}
    ###check ExtgNB log###
    Check IgNBCAContextSetupFailure message on extgNB    logname=${logname1}
    Check IgNBCAAdditionRequestReject message on PrimegNB and ExtgNB    logname=${logname1}

Check wireshark log for GG003
    [Arguments]    ${logname}    ${logname1}
    ${xgU_addr_gnb1}=    Check value of parameter xgUplane address    WEBUI_COAM=${WEBUI_host1}    SNSSAI=false
    ...    xgU_addr=ipV4AddressDN1    filter_param_DN=IPv4 address 1 distinguished name    filter_param_local=Local IPv4 address
    ${xgU_addr_gnb2}=    Check value of parameter xgUplane address    WEBUI_COAM=${WEBUI_host0}    SNSSAI=true
    ...    xgU_addr=ipV4AddressDN1    filter_param_DN=IPv4 address 1 distinguished name    filter_param_local=Local IPv4 address
    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${logname}
    ...    pcell_index=${2}    scell_index_list=${scell_index_list_GG003}
    ...    Primegnb_index=${1}    extgnb_index_list=${extgnb_index_list_GG003}
    Check IgNBCAUeContextModificationResponse has transport messages on PrimegNB    logname=${logname}    xgU_addr=${xgU_addr_gnb1}
    ...    xpath=.//nokiaf1ap.transportLayerAddressIPv4
    Check IgNBCAUeContextSetupResponse has transport messages on ExtgNB    logname=${logname1}    xgU_addr=${xgU_addr_gnb2}
    ...    xpath=.//nokiaf1ap.transportLayerAddressIPv4

Check wireshark log for GG004
    [Arguments]    ${logname}    ${logname1}    ${Primegnb_index}=${0}    ${extgnb_index}=${1}
    Get cell id multignb    lcrid_pcell=${1}    scell_index_list=${scell_index_list_GG003}
    ...    PrimegNB_index=${2}    extgnb_index_list=${extgnb_index_list_GG003}
    ${xgU_addr_gnb1}=    Check value of parameter xgUplane address    WEBUI_COAM=${WEBUI_host2}    SNSSAI=false
    ...    xgU_addr=ipV6AddressDN1    filter_param_DN=IPv6 address 1 distinguished name    filter_param_local=Local IPv6 address
    ${xgU_addr_gnb2}=    Check value of parameter xgUplane address    WEBUI_COAM=${WEBUI_host3}    SNSSAI=true
    ...    xgU_addr=ipV6AddressDN1    filter_param_DN=IPv6 address 1 distinguished name    filter_param_local=Local IPv6 address
    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${logname}
    ...    pcell_index=${1}    scell_index_list=${scell_index_list_GG003}
    ...    Primegnb_index=${2}    extgnb_index_list=${extgnb_index_list_GG003}
    Check IgNBCAUeContextModificationResponse has transport messages on PrimegNB    logname=${logname}    xgU_addr=${xgU_addr_gnb1}
    ...    xpath=.//nokiaf1ap.transportLayerAddressIPv6
    Check IgNBCAUeContextSetupResponse has transport messages on ExtgNB    logname=${logname1}    xgU_addr=${xgU_addr_gnb2}
    ...    xpath=.//nokiaf1ap.transportLayerAddressIPv6
    Check IgNBCAUeContextSetupResponse has no transport ip on ExtgNB  logname=${logname1}
    ...    xpath=.//nokiaf1ap.transportLayerAddressIPv4

#### get value from GNB
Check value of parameter xgUplane address
    [Arguments]    ${WEBUI_COAM}=${WEBUI_host0}   ${SNSSAI}=true
    ...    ${xgU_addr}=ipV6AddressDN1    ${filter_param_DN}=IPv6 address 1 distinguished name
    ...    ${filter_param_local}=Local IPv6 address
    ${sw_version}    Get sagnb version for selenium
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}    version=${sw_version}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Run keyword If    '${SNSSAI}'=='true'
    ...    Set suite Variable    ${xgUplane_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/SNSSAI-1    ELSE
    ...    Set suite Variable    ${xgUplane_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/NRDU-1
    ${xgUplane_address_value}=    selenium_coam.get_parameter_value    dist_name=${xgUplane_distname}
    ...    filter_param=${filter_param_DN}    abbr=${xgU_addr}
    ${xgUplane_address}=    selenium_coam.get_parameter_value    dist_name=${xgUplane_address_value}
    ...    filter_param=${filter_param_local}    abbr=localIpAddr
    selenium_coam.logout
    selenium_coam.disable_virtual_display
    [Return]    ${xgUplane_address}

Start DL traffic with IMS IP
    [Arguments]    ${logname}    ${ue_index}=${ue_index_${gnb_instance0}}
    ...            ${DL_port}=${tl.ues[${ue_index}].iperf_details.port}    ${time}=600
    ...            ${interval}=1    ${traffic}=10.00M    ${buffer_size}=1024B
    ...            ${process_num}=${1}   ${cap_index}=${0}
    ${UE_IP}    Get UE IP from wirehsark    logname=${logname}
    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP    ue_index=${ue_index}
    sleep   2s
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${DL_port}| awk '{print $2}' |xargs kill -9    connection=EPCAPP
    csn.send_command
    ...    command=iperf -c ${UE_IP} -u -t ${time} -i ${interval} -p ${DL_port} -P ${process_num} -f m -b ${traffic} -l ${buffer_size} -T 64&
    ...    connection=EPCAPP
    log to console    .....UE_${ue_index} udp dl iperf start....

Get UE IP from wirehsark
    [Arguments]    ${logname}
    ...    ${message_filter}=ngap.procedureCode == 29 and nas-5gs.sm.pdu_addr_inf_ipv4
    ...    ${xpath}=.//nas-5gs.sm.pdu_addr_inf_ipv4
    Log    Get UE IP from wirehsark
    ${UE_IP}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    [Return]    ${UE_IP}[0]
