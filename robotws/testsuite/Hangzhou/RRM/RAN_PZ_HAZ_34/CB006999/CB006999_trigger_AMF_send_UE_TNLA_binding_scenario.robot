# *** Settings ***
# Force Tags    PY36
# Documentation     author: criscai
# ...               contact: cris.cai@nokia-sbell.com
# ...               squad group: SG_03
# ...               feature : CB006999_B
# 
# Resource          ./Resources/CB006999_common_kw.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
# Variables         Resources/__init__.py
# 
# 
# Suite Setup    Run Keywords
# ...            Run Keyword And Ignore Error    Common Suite Setup for COAM    AND
# ...            Load SCF for each TL
# 
# Suite Teardown    Run Keywords
# ...               Run Keyword And Ignore Error
# ...               Common Suite Teardown for COAM    gnb_index=${1}   AND
# ...               Run Keyword And Ignore Error    COAM Teardown gnb connections   AND
# ...               Common Suite Teardown for AMF ZHOU
# 
# 
# 
# *** Variables ***
# #${epc_log_path}            /tmp/
# #${tl_scf_dir_path}         /opt/workspace/SCF/
# #${tl_scf_filename}         CB006999_A.xml
# #${tl_scf_filename}         gy-CB006999_A.xml
# ${interface}               any
# ${duration}                1500
# ${gNB1_nglogname}          gNB_6999.pcap
# #${gnb_path}                /tmp/
# ${tshark_path}             /usr/bin/tshark
# ${asik_addr}              ${tl.gnbs[0].cu.oam_http_connection_details.addr}
# ${command_template_with_Y}    {tshark_path} -r {pcap_file} -Y  \"f1ap\"  -T pdml
# 
# *** Test Cases ***
# 
# [1]CB006999_B_002_gnb_receive_UE_TNLA_BINDING_RELEASE_REQUEST_without _backupAMFname_in_ASI_with_actAmfPlannedRemoval _true
#     [Documentation]    AMF STATUS INDICATION has been received and processing is ongoing, with all GUAMIs using
#     ...    the Timer approach.  amfPlannedRemovalTimer duration has still not expired for the specific AMF/GUAMI
#     ...    associated with the UE Context.  UE TNLA BINDING RELEASE REQUEST message is received by the UE Context,
#     ...    indicating that the binding has to be released immediately (current usage stopped immediately).
#     ...    There are no ongoing procedures over the NGAP interface.
#     [Tags]    classical    CB006999-B_002    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_22R4
#     [Setup]
#     robot_common_operations.Common Case Setup
#     Prepare the atten for each TL
#     Online modify NIDD on gnb1 and gnb2    Modify_Para_Online_GNB2=${gnb2_Lock_AMF1_Unlock_AMF2}
#     ...    ModifySCF_Aftercommission_for_GNB2=True
#     power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
#     Start capture gNB log on master    filename=${gNB1_nglogname}   gNB_index=${1}
#     Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${1}
#     sleep    10s
#     power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput}    duration=${duration}
#     ...    ue_index=${0}    iperf_port=${dl_port}
#     Online modify NIDD on gnb1 and gnb2    Modify_Para_Online_GNB2=${gnb2_Unlock_AMF3}
#     ...    ModifySCF_Aftercommission_for_GNB2=True
#     power_ue.Check throughput    ue_type=${ue_type}    direction=dl
#     ...    throughput=${dl_expect_throughput}    gnb_index=${1}
# #    make amf-zhou maitain on amf account and alarm 7115 will be raised    status=@{gumistatus}[0]
# #    trigger ul behaviour for each TL
#     sleep    10s
#     power_ue.Check throughput    ue_type=${ue_type}    direction=dl
#     ...    throughput=${dl_expect_throughput}    gnb_index=${1}
#     Stop UL DL data transfer    ue_index=${1}    dl_port=${DL_PORT}    ul_port=${UL_PORT}
#     power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#     Stop and download the Logs    filename=${gNB1_nglogname}   gNB_index=${1}
#     [Teardown]    Run Keywords
#     ...    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}    AND
#     ...    check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${0}    AND
#     ...    Test recover
# 
# *** Keywords ***
# Set nrcellid suit varaible
#     [Arguments]    ${cellid}    ${gnb_index}=${0}
#     ${nrcellid}    COAM Get nrcellid with the lcrid    lcrid=${cellid}    gnb_index=${gnb_index}
#     set suite variable    ${nrcellid}
# 
# Get sagnb release
#     [Arguments]   ${host}=${asik_addr}   ${username}=${asik_username}   ${password}=${asik_password}
#     csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=release_info
#     ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=release_info
# #    ${release_info}     set variable    ${info.split('_')[1]}
#     ${release_info}    set variable    ${info.split('_')[1]}_${info.split('_')[2]}_${info.split('_')[3]}
#     [Return]    ${release_info}
#     [Teardown]   csn.Disconnect   connection=release_info
# 
# Test recover
#     run keyword and ignore error    coam.teardown    connection=ASIK
#     run keyword and ignore error    Stop Logs capture    filename=${gNB1_nglogname}
#     run keyword and ignore error    Power UE stop dl traffic
