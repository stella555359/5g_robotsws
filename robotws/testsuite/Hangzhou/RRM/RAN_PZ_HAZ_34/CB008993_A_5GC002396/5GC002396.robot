# *** Settings ***
# Force Tags      RAN_5G_FDD    RAN_5G   SBTS00    SBTS22R3
# ...             PY36    CRT_TRUNK    CRT_22R3    CRT_22R4
#
# Documentation    :copyright: Nokia
# ...              :authors: zhang jin 2
# ...              :contact: jin.2.zhang@nokia-sbell.com
# ...              :testsuite description: 5GC002396 is mainly to support 3GPP R16 UE with full power TX mode0
#
# Resource          taf/rfrl/common_resources/robot/connection_alias_store.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# Resource     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000772/resources/keywords_cOAM.robot
# Resource     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000772/resources/5GC000772_Keywords.robot
# Resource         testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008993_A_5GC002396/5GC002396_Variables.robot
# #Resource      testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007271_C/5GC000545/resources/keywords_545.robot
#
# Library      testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000772/resources/5GC000772_Resources.py   WITH NAME       mylib772
# #Library              testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC002396/luashark.py       WITH NAME     luashark
# Library      taf.transport.ssh    WITH NAME    csn
# Library                                taf.transport.ssh                                 WITH NAME       ssh
# Library                                BuiltIn
# Library                                String
# Library                                ute_reporting_portal
# Library                                OperatingSystem
# Library                                DateTime
# Library                                XML
# Library                                ute_ue
# Library           taf.collectors.l1l2bip    WITH NAME    l1l2bip
# Library           taf.collectors.tcpdump    WITH NAME    tcpdump
# Library           taf.collectors.core    WITH NAME    core
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot
# Library     ./csvanalyzer.py
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/MTK_common_keywords.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Library            taf.hw.rf_attenuator    WITH NAME    PA_
# #Library    taf.rfrl.common_resources.python.ssh_common_commands    WITH NAME    ssh_common_commands
# #Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/bip.robot     WITH NAME     bip
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
#
# Suite Setup     Run Keywords    CI_interface.Common Suite Setup    AND    Common 5GC002396 Setup
#
# Suite Teardown    Run Keywords    QCT Generic Suite Teardown for 5GC002396
#
# *** Variables ***
# ${delta_activate_actCli}=               ${CURDIR}/delta_2396_activation.json
# ${delta_deactivate_actCli}=             ${CURDIR}/delta_2396_deactivation.json
# ${delta_activate_2396_D}=               ${CURDIR}/delta_2396_D_activate.json
# ${delta_deactivate_2396_D}=             ${CURDIR}/delta_2396_D_deactivate.json
# @{ALLOWED_ALARMS}=
# ...                                4592
# ...                                61524
# ...                                61649
# ...								   61652
# ...                                4334
# ...                                4655
# ...                                4654
# ...                                4681
# ...                                61029
#
# ${ue_type}                        mtk
# ${TS_CASE_LOG_PATH}              /home/ute/BIPlog
# ${gnb_index}                   0
# ${du_index}                    0
# ${UE_id}                       2
#
# ##PA
# ${5GRU_ANT3}    ${1}   #int  127
# ${5GRU_ANT4}    ${2}    #int  127
# @{att_connection_port2}      ${5GRU_ANT3}    ${5GRU_ANT4}
#
# ${5GRU_ANT5}    ${7}   #int  127
# ${5GRU_ANT6}    ${8}    #int  127
# @{att_connection_port3}      ${5GRU_ANT5}    ${5GRU_ANT6}
#
# ${5GRU_ANT1}    ${5}   #int
# ${5GRU_ANT2}    ${6}    #int
# @{att_connection_port}      ${5GRU_ANT1}    ${5GRU_ANT2}     #int list
#
# ${HBTE_max_value}           ${127}
# ${vendor}    HBTE
# #${att_ipaddr}    10.71.203.130
# ${att_api_port}    5000
#
#
# ${PA_INFO}            ${tl.attenuator}
#
#
#
# *** Test Cases ***
# [1]CB008993_SR_A_5GC002396_A_05_CPRI_SA_FDD_FR1_TX_power_mode0_for_PC3
#
#     [Tags]    test
#     [Documentation]    Test case checks if full power TX mode0 is supported for R16 UE for power class 3.
#     ...    Also checks if feature online activation is working properly.
#     ...    Covers also 5GC002396_A_B1_1_Full_Power_Mode0_For_Power_Class_3.
#     ...    5G_RAN_USR_RRM_4271, 5G_RAN_USR_RRM_6852
#
#     [Setup]   5GC002396_A_05 Setup
#     #ADB Reboot UE
#     #sleep  60s
#
#     keywords_cOAM.gNB Get CellId and BTSId DN in SCF
#     Campaign Test Setup                ${CAMPAIGN_NAME}    ${False}       ${False}
#     #power_ue.Prepare UE    ue_index=${UE_id}    ue_type=${ue_type}
#
#
#     Wait For Next Counter Files
#     QCT Launch Test With Traffic and Analysis for 5GC002396       ${UE_id}      ${CAMPAIGN_NAME}     ${ue_type}
#     Wait For Next Counter Files
#     Get and Check Counters Files for 5GC002396
#     power_ue.UE Detach      ue_index=${UE_id}    ue_type=${ue_type}
#
#     Get and Check BIP log for 5GC002396
#     ...    item=UlData_puschReceiveReqGrant_t.fullPowerPuschPowerScalingRatio
#     ...    value=40
#     ...    item_not_contain_value=0
#
#     [Teardown]  5GC002396_A_05 Teardown
#
#
# [1]CB008993_SR_A_5GC002396_D_08_CPRI _SA_FDD_FR1_TX power_mode0_PC3_single UE_with_actUlDftSOfdm_true
#     [Tags]    CRT
#     [Documentation]    Test case checks if full power TX mode0 is supported for R16 UE for power class 3.
#     ...    Also checks if feature online activation is working properly.
#     ...    Covers also 5GC002396_A_B1_1_Full_Power_Mode0_For_Power_Class_3.
#     ...    5G_RAN_USR_RRM_4271, 5G_RAN_USR_RRM_6852
#
#     [Setup]     5GC002396_D_08 Setup
#
#     keywords_cOAM.gNB Get CellId and BTSId DN in SCF
#     Campaign Test Setup                ${CAMPAIGN_NAME}    ${False}       ${False}
#
#     Wait For Next Counter Files
#     QCT Launch Test With Traffic and Analysis for 5GC002396_D_08      ${UE_id}       ${CAMPAIGN_NAME}     ${ue_type}
#     ...    ${5GRU_ANT1}      ${5GRU_ANT2}
#     Wait For Next Counter Files
#     Get and Check Counters Files for 5GC002396
#     power_ue.UE Detach      ue_index=${UE_id}    ue_type=${ue_type}
#
#     Get and Check BIP log for 5GC002396 New
#     ...    item=UlData_puschReceiveReqGrant_t.puschTransformPrecoderFlag
#     ...    value=1
#
#     Get and Check BIP log for 5GC002396
#     ...    item=UlData_puschReceiveReqGrant_t.fullPowerPuschPowerScalingRatio
#     ...    value=40
#     ...    item_not_contain_value=0
#
#     [Teardown]   5GC002396_D_08 Teardown
#
#
#
#
# *** Keywords ***
#
# ADB Reboot UE
#     [Documentation]  Use adb command to reboot the android ue device
#     [Arguments]    ${ue_index}=${0}   ${telnet}=${true}
#     ...             ${cpc_ip}=${tl.ues[${ue_index}].ssh_connection_details.addr}
#     ...             ${cpc_usrname}=${tl.ues[${ue_index}].ssh_connection_details.username}
#     ...             ${cpc_passwd}=${tl.ues[${ue_index}].ssh_connection_details.password}
#     ...             ${alias}=test
#
# 	csn.Connect to   ${cpc_ip}    ${cpc_usrname}    ${cpc_passwd}    alias=${alias}
# 	csn.execute    command=adb reboot   connection=test
# 	csn.disconnect      connection=test
#     sleep    20s
#     log to console   ADB Reboot UE successfully
#
#
# Common 5GC002396 Setup
#     #ADB Reboot UE
#     #sleep  60s
#     Connect to gnb coam via ssl        connection=coam_admin
#     Active Alarms List Should Be Empty
#     COAM Teardown gnb connections      connection=coam_admin
#
#     Activate FullPwrMode feature
#     Verify Site On Air
#
#     Download MCShark To UTE
#     #Download MCShark file To UTE
#
#     PA_.setup_attenuator    attenuator=${PA_INFO}
#     PA_.set_attenuation     port=${1}    value=${127}
#     PA_.set_attenuation     port=${2}    value=${127}
#
#     PA_.set_attenuation     port=${7}    value=${127}
#     PA_.set_attenuation     port=${8}    value=${127}
#
#     sleep  30s
#
#
# Download MCShark To UTE
#     ${wireshark_version}    Run    ls /usr/lib/x86_64-linux-gnu/wireshark/plugins
#     set suite variable     ${wireshark_version}
#
#     ${sw_version}    Get MCShark Version
#     ${cmd}    Set Variable    wget -r -np -nH https://artifactory-hz1.int.net.nokia.com/artifactory/mcshark-local/${sw_version}/
#     ${rc}    ${output}    OperatingSystem.Run And Return Rc And Output    ${cmd}
#     ${MCShark}    Run    ls ${EXECDIR}/artifactory/mcshark-local/${sw_version}/mcshark-${wireshark_version}*buster.so
#     set suite variable     ${MCShark}
#
#     ${is_MCShark_exist}    Run keyword and return status    Should not contain    ${MCShark}    No such file or directory
#
#     Run keyword if   ${is_MCShark_exist}==${True}   Download MCShark If Have
#     ...  ELSE         log to console    This version mcshark donot exit and use last version mcshark
#
#
# Download MCShark If Have
#     Run    sudo rm /usr/lib/x86_64-linux-gnu/wireshark/plugins/${wireshark_version}/epan/mcshark-*buster.so
#     Run    sudo cp ${MCShark} /usr/lib/x86_64-linux-gnu/wireshark/plugins/${wireshark_version}/epan/
#
#     log to console    download mcshark successfully to UTE
#
#
#
# 5GC002396_A_05 Setup
#     #Adjust Attenuation Value For 2396    ${5GRU_ANT1}    value=${127}   att_connection_port=@{att_connection_port}
#     #Adjust Attenuation Value For 2396    ${5GRU_ANT2}    value=${10}   att_connection_port=@{att_connection_port}
#
#     PA_.setup_attenuator    attenuator=${PA_INFO}
#     PA_.set_attenuation     port=${5}    value=${127}
#     PA_.set_attenuation     port=${6}    value=${10}
#
#
# 5GC002396_A_05 Teardown
#     #Adjust Attenuation Value For 2396    ${5GRU_ANT1}    value=${0}    att_connection_port=@{att_connection_port}
#     #Adjust Attenuation Value For 2396    ${5GRU_ANT2}    value=${0}    att_connection_port=@{att_connection_port}
#
#     PA_.setup_attenuator    attenuator=${PA_INFO}
#     PA_.set_attenuation     port=${5}    value=${0}
#     PA_.set_attenuation     port=${6}    value=${0}
#
#
# 5GC002396_D_08 Setup
#     Connect to gnb coam via ssl        connection=coam_admin
#     Active Alarms List Should Be Empty
#     COAM Teardown gnb connections      connection=coam_admin
#
#     #Adjust Attenuation Value For 2396    ${5GRU_ANT1}    value=${127}   att_connection_port=@{att_connection_port}
#     #Adjust Attenuation Value For 2396    ${5GRU_ANT2}    value=${15}    att_connection_port=@{att_connection_port}
#
#     PA_.setup_attenuator    attenuator=${PA_INFO}
#     PA_.set_attenuation     port=${5}    value=${127}
#     PA_.set_attenuation     port=${6}    value=${15}
#
#     Activate 2396_D feature
#     Verify Site On Air
#
#
# 5GC002396_D_08 Teardown
#     #Adjust Attenuation Value For 2396    ${5GRU_ANT1}    value=${0}     att_connection_port=@{att_connection_port}
#     #Adjust Attenuation Value For 2396    ${5GRU_ANT2}    value=${0}     att_connection_port=@{att_connection_port}
#
#     PA_.setup_attenuator    attenuator=${PA_INFO}
#     PA_.set_attenuation     port=${5}    value=${0}
#     PA_.set_attenuation     port=${6}    value=${0}
#
#     Deactivate 2396_D feature
#     Verify Site On Air
#
#
#
# Get and Check BIP log for 5GC002396
#    [Arguments]    ${item}    ${value}   ${item_not_contain_value}
#    Verify Special Item Value Exist
#    ...      file_path=${CSV_FILE}
#    ...      item=${item}
#    ...      item_value=${value}
#    ...      item_not_contain_value=${item_not_contain_value}
#
#
# Verify Special Item Value Exist
#     [Documentation]    jian.1.chen@nokia-sbell.com
#     [Arguments]    ${file_path}    ${item}    ${item_value}   ${item_not_contain_value}
#     ${special_item_value_list}    get_the_special_item_value    ${file_path}    ${item}
#     List Should Contain Value    ${special_item_value_list}    ${item_value}
#     List Should Not Contain Value    ${special_item_value_list}    ${item_not_contain_value}
#
# Get and Check BIP log for 5GC002396 New
#    [Arguments]    ${item}    ${value}
#    Verify Special Item Value Exist New
#    ...      file_path=${CSV_FILE}
#    ...      item=${item}
#    ...      item_value=${value}
#
#
#
# Verify Special Item Value Exist New
#     [Documentation]    jian.1.chen@nokia-sbell.com
#     [Arguments]    ${file_path}    ${item}    ${item_value}
#     ${special_item_value_list}    get_the_special_item_value    ${file_path}    ${item}
#     List Should Contain Value    ${special_item_value_list}    ${item_value}
#     #List Should Not Contain Value    ${special_item_value_list}    ${item_not_contain_value}
#
# Capture BIP Log And Convert To CSV
#     [Arguments]    ${filter}
#     ${result}    ${release}    Run Keyword And Ignore Error
#     ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
#     ${release_sbts}    Replace String    string=${release}    search_for=5G    replace_with=SBTS
#     Run keyword If  '${release_sbts}'=='SBTS22R3'   Capture BIP Log And Convert To CSV for 22R3   filter=${filter}
#     ...    ELSE       Capture BIP Log And Convert To CSV for Trunk       filter=${filter}
#
#
# Capture BIP Log And Convert To CSV for Trunk
#     [Arguments]    ${filter}
#     CreateDirectory       /home/ute/BIPlog/l1l2bip
#     Clear old log path
#     #Get L1L2 ABIN Traffic To ASIB New       target_dir=/home/ute/BIPlog
#     Start to collect bip log new     nr_phy_cell_ids=215
#     sleep  10s
#     Stop to collect bip log new     target_dir=/home/ute/BIPlog
#
#     ${bip_files}     Get BIP File List      log_path=/home/ute/BIPlog/l1l2bip
#     ${csv_file}    Replace String    ${bip_files}    .pcap    .csv
#
#     Set Suite Variable    ${CSV_FILE}    ${csv_file}
#     @{csv_title_list}    Create List    3gpp.slot    UlData_puschReceiveReqGrant_t.fullPowerPuschPowerScalingRatio
#     ...  UlData_puschReceiveReqGrant_t.puschTransformPrecoderFlag
#     Convert BIP To CSV By MCShark    bip_file=${bip_files}
#     ...    output_file=${csv_file}    filter=${filter}    csv_title_list=${csv_title_list}
#
#
# Capture BIP Log And Convert To CSV for 22R3
#     [Arguments]    ${filter}
#     CreateDirectory       /home/ute/BIPlog
#     Get L1L2 ABIN Traffic To ASIB for 22R3
#
#     Connect To BTS Csn Via Lmp
#     #${bip_files}    Download BIP Logs From ASIK To TestPC and rename it
#     ${bip_files}     Stop BIP capture on ASIK if needed and download BIP Logs to testPC
#     ${csv_file}    Replace String    ${bip_files}[0]    .pcap    .csv
#     Set Suite Variable    ${CSV_FILE}    ${csv_file}
#     @{csv_title_list}    Create List    3gpp.slot    UlData_puschReceiveReqGrant_t.fullPowerPuschPowerScalingRatio
#     ...  UlData_puschReceiveReqGrant_t.puschTransformPrecoderFlag
#     Convert BIP To CSV By MCShark    bip_file=${bip_files}[0]
#     ...    output_file=${csv_file}    filter=${filter}    csv_title_list=${csv_title_list}
#
#
#
# Connect To BTS Csn Via Lmp
#     [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}    ${alias}=ASIK Master
#     csn.Connect to    hostname=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
#     ...    username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
#     ...    password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
#     ...    alias=${alias}
#
#
# Clear old log path
#     csn.connect to
#     ...               hostname=${tl.test_pc.default_ssh_connection_details.addr}
#     ...               username=${tl.test_pc.default_ssh_connection_details.username}
#     ...               password=${tl.test_pc.default_ssh_connection_details.password}
#     ...               alias=test
#
#     csn.send_command    command=sudo rm -rf /home/ute/BIPlog/l1l2bip/*    connection=test
#     Sleep    10s
#     csn.disconnect    connection=test
#
#
# Enable mirror port on Loki
#     [Documentation]    Mirror ABIN traffic to ASIB cpu.
#     [Arguments]     ${mirror_port}=eths3    ${backplane_port}=C2B5(2)    ${slot_id}=6    ${asik_alias}=ASIK Master
#     ${command1}=      Catenate      /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L1_L2_UL
#                  ...      -b "${backplane_port}" -s ${slot_id} -l ${mirror_port} -v 303
#     ${command2}=      Catenate      /usr/bin//lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L1_L2_DL
#                  ...      -b "${backplane_port}" -s ${slot_id} -l ${mirror_port} -v 303
#     csn.Execute     command=${command1}      connection=${asik_alias}
#     csn.Execute     command=${command2}      connection=${asik_alias}
#     csn.Execute     command=ncp_portmirror -p xgmac96 -r
#     ...             connection=${asik_alias}
#     csn.Execute     command=ncp_portmirror -d netdriver -p xgmac96
#     ...             connection=${asik_alias}
#
#
# Start Bip Log Capture
#     [Arguments]     ${mirror_port}=eths2    ${asik_alias}=ASIK Master
#     Enable mirror port on Loki    mirror_port=${mirror_port}
#     csn.Send command     command=tcpdump -i eths2 -w /tmp/tcpdump_L2L1.pcap
#     ...                  connection=${asik_alias}
#
# Get L1L2 ABIN Traffic To ASIB for 22R3
#     Connect to Common Unit Master
#     Start Bip Log Capture
#
#
#
# #Get L1L2 ABIN Traffic To ASIB New
# #    [Arguments]    ${target_dir}
# #    #Connect to Common Unit Master
# #    #Start Bip Log Capture
# #    ${webservice}=  Create Dictionary
# #    ...  host=192.168.255.129
# #    ...  user=Nemuadmin
# #    ...  password=nemuuser
# #    ...  port=443
# #    create_interface_mirroring_l1l2bip_collector
# #    ...  name=l1l2bip
# #    ...  webservice=${webservice}
# #    ...  nr_phy_cell_ids=215
# #    ...  timeout=500
# #
# #    core.setup_collectors    names=l1l2bip
# #    core.start_collectors    names=l1l2bip
# #    sleep    5s
# #    core.stop_collectors    names=l1l2bip
# #    core.collect_collectors    names=l1l2bip    target_dir=${target_dir}
# #    core.teardown_collectors    names=l1l2bip
#
#
#
# Get MCShark Version
#     [Documentation]    jian.1.chen@nokia-sbell.com
#     Connect to gnb coam via ssl
#     ${sw_version}    coam.get_sw_version    connection=GNB_OAM
#     ${list_version}    Split String    ${sw_version}    _
#     ${first}    ${rest}    Split String    ${sw_version}    _    1
#     ${new_version}    Set Variable If    "${list_version}[2]"=="9999"
#     ...    SBTS00_${rest}      ${sw_version}
#     ${list_version}    Split String    ${new_version}    _
#     ${rest}    ${last}    Split String From Right    ${new_version}    _    1
#     ${latest_version}    Set Variable If    "${list_version}[0]"!="SBTS00" and "${list_version}[-1]"!="000000"
#     ...    ${rest}_000000      ${new_version}
#     [Return]    ${latest_version}
#     [Teardown]    COAM Teardown gnb connections
#
#
# Convert BIP To CSV By MCShark
#     [Documentation]    jian.1.chen@nokia-sbell.com
#     [Arguments]    ${bip_file}    ${output_file}    ${filter}    ${csv_title_list}
#     ${csv_title}    Set Variable
#     FOR    ${column}   IN    @{csv_title_list}
#         ${csv_title}    Set Variable    ${csv_title} -e ${column}
#     END
#     ${cmd}    Catenate    tshark -r ${bip_file} -Y '${filter}' -T fields -e _ws.col.No. -e _ws.col.Info
#     ...    ${csv_title} -E header=y -E separator=, -E quote=d -E occurrence=a > ${output_file}
#     OperatingSystem.Run    ${cmd}
#
#
# ADMIN Perform Delta Recommissioning
#     [Arguments]    ${delta_file}
#     ...            ${skip_parameter_relation_errors}
#     ...            ${should_activate}=${True}
#     ...            ${timeout}=300
#     ...            ${connection}=GNB_OAM
#     coam.Perform Delta Recommissioning
#     ...                                        delta_file=${delta_file}
#     ...                                        skip_parameter_relation_errors=${skip_parameter_relation_errors}
#     ...                                        should_activate=${should_activate}
#     ...                                        timeout=${timeout}
#     ...                                        connection=${connection}
#
# Activate FullPwrMode feature
#     Connect to gnb coam via ssl
#     ADMIN Perform Delta Recommissioning                 ${delta_activate_actCli}
#     ...                                                 skip_parameter_relation_errors=True
#     COAM Teardown gnb connections
#
# Deactivate FullPwrMode feature
#     Connect to gnb coam via ssl
#     ADMIN Perform Delta Recommissioning                 ${delta_deactivate_actCli}
#     ...                                                 skip_parameter_relation_errors=True
#     COAM Teardown gnb connections
#
# Activate 2396_D feature
#     Connect to gnb coam via ssl
#     ADMIN Perform Delta Recommissioning                 ${delta_activate_2396_D}
#     ...                                                 skip_parameter_relation_errors=True
#     COAM Teardown gnb connections
#
# Deactivate 2396_D feature
#     Connect to gnb coam via ssl
#     ADMIN Perform Delta Recommissioning                 ${delta_deactivate_2396_D}
#     ...                                                 skip_parameter_relation_errors=True
#     COAM Teardown gnb connections
#
#
# Verify Site On Air
#     Connect to gnb coam via ssl
#     Verify all cells should be onair
#     COAM Teardown gnb connections
#
#
# Active Alarms List Should Be Empty
#   ${active_alarms_list}  Run Keyword And Continue On Failure  Get Active Alarms
#   ${not_allowed_alarms_number}  Run Keyword And Continue On Failure  Remove Allowed Alarms From Active Alarm List
#   ...  ${active_alarms_list}  ${ALLOWED_ALARMS}
#   Run Keyword And Continue On Failure  Should Be Equal as Integers  ${not_allowed_alarms_number}  0
#
# Get Active Alarms
#   Run Keyword And Continue On Failure    Wait For Fault with Alarm to disappear    FaultID=7319
#   Run Keyword And Continue On Failure    Wait For Fault with Alarm to disappear    FaultID=7300
#   ${active_alarms_list}  Run Keyword And Continue On Failure   coam.get_active_alarms   connection=coam_admin
#   ...   timeout=600s
#   [Return]  ${active_alarms_list}
#
# Wait For Fault with Alarm to disappear
#   [Arguments]  ${FaultID}
#   wait until keyword succeeds  1200      5    Fault Should Not Be Present   ${FaultID}
#
# Fault Should Not Be Present
#   [Arguments]    ${fault_id}
#   ${active_alarms}    coam.get_active_alarms    timeout=600s    connection=coam_admin
#   ${len}    Get Length    ${active_alarms}
#   ${alarm_id_list}    Create List
#   FOR    ${i}    IN RANGE    ${len}
#       ${tmp_id}    Get From Dictionary    ${active_alarms[${i}]}    faultId
#       Append To List    ${alarm_id_list}    ${tmp_id}
#   END
#   ${list}     convert to string  ${alarm_id_list}
#   Should Not Contain     ${list}    ${fault_id}
#
# Remove Allowed Alarms From Active Alarm List
#   [Arguments]  ${active_alarms_list}=none  ${allowed_alarms_list}=none
#   ${active_alarms_number}  Run Keyword And Continue On Failure  Get Length  ${active_alarms_list}
#   ${not_allowed_alarms_list}  Run Keyword And Continue On Failure  Create List
#   FOR  ${alarm_id}  IN RANGE  ${active_alarms_number}
#       ${checked_alarm_faultId}  Run Keyword And Continue On Failure  Set Variable
#       ...    ${active_alarms_list[${alarm_id}]["faultId"]}
#       ${not_on_list}  Check If Alarm Allowed   allowed_alarms_list=${allowed_alarms_list}
#       ...   checked_alarm=${checked_alarm_faultId}
#       ${alarm}  Run Keyword And Continue On Failure   Get From List  ${active_alarms_list}   ${alarm_id}
#       Run Keyword If  ${not_on_list}   Append To List  ${not_allowed_alarms_list}   ${alarm}
#   END
#   ${not_allowed_alarms_number}  Run Keyword And Continue On Failure  Get Length  ${not_allowed_alarms_list}
#   [Return]  ${not_allowed_alarms_number}
#
# Check If Alarm Allowed
#   [Arguments]  ${allowed_alarms_list}=none  ${checked_alarm}=none
#   ${allowed_alarms_number}  Get Length  ${allowed_alarms_list}
#   FOR  ${allowed_alarms_id}  IN RANGE  ${allowed_alarms_number}
#     ${status}  Run Keyword And Return Status  Should Not Be Equal as Strings  ${checked_alarm}
#     ...   ${allowed_alarms_list[${allowed_alarms_id}]}
#     Exit For Loop If  ${status}==${FALSE}
#   END
#   [Return]  ${status}
#
#
#
#
#
#
#
#
#
#
#
#
