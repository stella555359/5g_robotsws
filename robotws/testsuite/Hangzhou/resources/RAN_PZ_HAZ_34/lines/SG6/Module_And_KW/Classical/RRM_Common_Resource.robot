*** Settings ***
Documentation
...    author: mengli yang
...    contact: mengli.yang@nokia-sbell.com
...    Common KWs related to Classicalbts.
...    Some common operation is put in this file
...    Please do not modify the file without notification to author
Library             BuiltIn
Library             Collections
Library             DateTime
Library             json
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet
Library             taf.analyzer.pmcounter
Library             taf.analyzer.journal
Library             taf.collectors.core                                    WITH NAME    cc
Library             taf.collectors.core                                    WITH NAME    core
Library             taf.collectors.journal                                 WITH NAME    journal
Library             taf.collectors.btslog                                  WITH NAME    btslog
Library             taf.collectors.snapshot                                WITH NAME    snapshot
Library             taf.collectors.tcpdump                                 WITH NAME    tcpdump
Library             taf.collectors.tshark                                  WITH NAME    tshark
Library             taf.collectors.pmcounters                              WITH NAME    pmcounters
Library             taf.config.scf                                         WITH NAME    scf
Library             taf.config.testline.info.testline_info.TestlineInfo    WITH NAME    testline_info
# Library             taf.epcsim                                             WITH NAME    epc
Library             taf.gnb.oam.commissioning                              WITH NAME    commissioning
Library             taf.hw.rf_attenuator                        WITH NAME    attenuator
Library             taf.hw.pdu                                             WITH NAME    pdu
Library             taf.sbts.oam.coam.admin                                WITH NAME    coam
Library             taf.selenium.gnb.oam.coam.classical                    WITH NAME    selenium_coam
Library             taf.transport.ssh                                      WITH NAME    csn
Library             taf.transport.ssh                                      WITH NAME    ssh
Library             taf.ue                                                 WITH NAME    ute_ue
Library             taf.ul.parser.pcap                                     WITH NAME    wireshark
Library             taf.sw.scout                                           WITH NAME    scout
# Library             ute_fsmaccess
Library             taf.sw.reporting_portal                                WITH NAME    rp
Library             ute_syslog
Library             ute_tshark                                             WITH NAME    TSK
Library             taf.ccs.aashell                                        WITH NAME    ccs_aashell
Library             taf.ul.oam_kpi_calculations                            WITH NAME    oam_kpi
Library             taf.ul.oam_kpi_calculations.utilities
Library             taf.collectors.l1l2bip                                 WITH NAME    l1l2bip
Library             taf.fdsw.rc                                            WITH NAME    fdswrc
Library             python/swconfig.py                        WITH NAME    swconf
Library             python/Get_latest_build_name.py
Library             python/common_commands.py                 WITH NAME    common_commands
Library             python/Get_latest_build_name.py           WITH NAME    wft
Library             python/rrm_variables.py
Library             python/utils/utils.py
Library             python/utils/file_operation.py
Library             ../Common/python/process_csv.py           WITH NAME    process_csv
Library             ../Common/python/basic.py    WITH NAME    basic
Library             ../Common/python/process_timed_remote_files.py
Library             process_timed_remote_files.TimedRemoteFileDownloader   WITH NAME    timed_file_downloader
############# dcap and emil ##########
Library             ../Common/python/dcap.py    WITH NAME    dcap
Library             taf.nms.netact                        WITH NAME    netact
Library             taf.ul.oam.netact.cm                  WITH NAME    netact_cm
Resource            RRM_Common_Setup_Teardown.robot
Resource            RRM_BTS.robot
Resource            RRM_Capture_Analysis_Log.robot
Resource            ../Common/AIC_UE.robot
Resource            ../Common/RRM_UE2.robot
Resource            ../Common/Config_File_Operation.robot
Resource            RRM_Counter_KPI.robot
Resource            RRM_Custom_Config.robot
Resource            RRM_File_Operation.robot
Resource            device_connection/PA.robot
Resource            device_connection/PB.robot
Resource            taf/rfrl/common_resources/common_step/interface.robot
############# ET Airphone ##########
Library             ute_wtssim
Library             ute_fsmaccess
#Resource            common_NSA_ue_command.robot
Resource            RRM_Airphone.robot
############# Module ##########
Resource          ../../../../../RAN_PZ_HAZ_1/Module/Module.robot
*** Variables ***
${PC_HOST}                         ${tl.test_pc.default_ssh_connection_details.addr}
${PC_USER}                         ${tl.test_pc.default_ssh_connection_details.username}
${PC_PASSWORD}                     ${tl.test_pc.default_ssh_connection_details.password}
${ASIB_IP_local}                   192.168.255.129
# ${ASIB_IP}                         ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
# ${ASIB_USERNAME}                   ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
# ${ASIB_PASSWORD}                   ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
&{BTS_PC_INFO}                     IP=${tl.test_pc.default_ssh_connection_details.addr}
...                                USERNAME=${tl.test_pc.default_ssh_connection_details.username}
...                                PASSWORD=${tl.test_pc.default_ssh_connection_details.password}
&{BTS_INFO}                        IP=192.168.255.129
...                                USERNAME=toor4nsn
...                                PASSWORD=oZPS0POrRieRtu
...                                LOCALIP=192.168.255.129
...                                http_USERNAME=Nemuadmin
...                                http_PASSWORD=nemuuser
...                                PORT=443
# ...                                MRBTS_ID=${tl.gnbs[0].instance_id}
# ...                                NRBTS_ID=${tl.gnbs[0].global_bts_id}
# ...                                RRUS=${tl.gnbs[0].dus[0].rus}
# ${CU_IP}                           ${tl.gnbs[0].cu.oam_http_connection_details.addr}
# ${http_USERNAME}                   ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${http_PASSWORD}                   ${tl.gnbs[0].cu.oam_http_connection_details.password}
#${ENB_IP}                          ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
# ${ABIL_MASTER_ADDR}                ${tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[0].addr}
#${pdu_gnb_addr}                    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
#@{pdu_gnb_port}                    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
${TL_Type}                         ${tl.tl_cloud_topology}
${Loner_addr}                      fsp-1-1c
${GNB_ABIL_addr}                   fsp-1-1a
${fsp_0a}                          192.168.255.129
${fsp_1a}                          192.168.253.20
${fsp_1b}                          fsp-1b
${fsp_1c}                          192.168.253.22
${fct_4a}                          192.168.253.32
${fsp_5a}                          fsp-5a
${fsp_5b}                          192.168.253.37
${fsp_5c}                          192.168.253.38
${Loner_username}                  toor4nsn
${Loner_password}                  oZPS0POrRieRtu
${SCF_FILE_PATH}                   /tmp/node_0xe000/opt/nokia/SS_MzOam/cloud-siteoam/siteoam/site_conf/5G19/5gClassicalBTS
${link_to_Artifact}                https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release/
${RESULT_DIR}                      /home/ute/test_results
${FileToRecordCurrentVersion}      ${OUTPUT DIR}/../current_version_for_rp.txt
# ${MRBTS_ID}                        ${tl.gnbs[0].instance_id}
# ${NRBTS_ID}                        ${tl.gnbs[0].global_bts_id}
${MRBTS_ID}                        ${None}
${NRBTS_ID}                        ${None}
${cbctest_ip}                      10.9.202.153
${cbctest_usr}                     cbctest
${cbctest_psw}                     cbctest
${cbctest_alias}                   cbctest
@{amfs}                            tang_amf    liang_amf    zhou_amf
${cbctest_path}                    /home/cbctest/RRM3
&{liang_amf}                       connect_hostname=10.108.221.101    mcc=460    mnc=02    tac=210
&{AMF6_Han}                        connect_hostname=10.107.180.36    mcc=460    mnc=02    tac=210
&{zhou_amf}                        connect_hostname=10.110.90.92    mcc=262    mnc=03    tac=210
&{01101_amf}                       connect_hostname=10.70.112.186    mcc=001    mnc=01    tac=210
${5G_arti}                         https://artifactory-hz1.ext.net.nokia.com/artifactory/mnp5g-central-public-remote/System_Release/
${arti}                            http://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build/
#${ATTENUATOR_ADDR}                 ${tl.attenuator.ip_addr}
#${attenuation_port}                ${tl.attenuator.port}
${ca}                              SRAN_Prod_RRM
${trunk_qc_lab_path}               Root\\Trunk_COMMON\\MN SRAN Prod RRMPz\\SRAN_Prod_HZH_RRM_3_Vrf\\CRT\\5GparityRRM
${branch_qc_lab_path}              Root\\Trunk_COMMON\\MN SRAN Prod RRMPz\\SRAN_Prod_HZH_RRM_3_Vrf\\CRT\\5GparityRRM
${username}                        mengyang
${qc_domain}                       MN_SRAN
${qc_project}                      SRAN_SBTS
${testline}                        10_5_UTESRAN001T${MRBTS_ID}
#${appserver_addr}                  ${tl.ues[0].ssh_connection_details.addr}
#${appserver_username}              ${tl.ues[0].ssh_connection_details.username}
#${appserver_password}              ${tl.ues[0].ssh_connection_details.password}
${QPSTexe}                         "/cygdrive/c/Program Files (x86)/Qualcomm/QPST/bin/QPSTConfig.exe"
${TS_LOG_PATH_BASE}                /home/ute/test_results
${tshark_path}                     /usr/bin/tshark
${luashark_path}                   /opt/luashark/luashark.lua
&{fault_61652}                     faultId=${61652}
&{fault_61524}                     faultId=${61524}
&{fault_61649}                     faultId=${61649}
&{fault_9000}                      faultId=${9000}
&{fault_6450}                      faultId=${6450}
&{fault_4592}                      faultId=${4592}
&{fault_4527}                      faultId=${4527}
&{fault_4654}                      faultId=${4654}
&{fault_4655}                      faultId=${4655}
&{fault_7311}                      faultId=${7311}
@{ALLOWED_FAULT}                   &{fault_61652}    &{fault_61524}    &{fault_61649}    &{fault_4654}    &{fault_6450}    &{fault_4592}
...                                &{fault_4655}    &{fault_7311}
${report_reporting_portal}         ${false}
${ABIO_master_slot1}               /tmp/node_L2RTa0
${ABIO_master_slot2}               /tmp/node_L2RTb0
${UPLOAD_SCF}                      0
${UPLOAD_SWCONFIG}                 0
${UTE_ARGFILE_PATH}                /home/ute/argfile.txt
${UTE_RESERVATION_CONTEXT_JSON}    /opt/ute/reservation.context.json
${UTE_RESERVATION_JSON}            /opt/ute/reservation.json
${UTE_EXECUTION_JSON}              /opt/ute/execution.context.json
${UTE_EXECUTION_INDEX}             ${0}
${GNB_BIP_MIRRORING_TOOL_LINK}     https://gitlabe2.ext.net.nokia.com/juhakang/tools.git
${MCSHARK_TOOL_LINK}               https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/MCShark
${TTITRACEHELPER_TOOL_LINK}        https://s3-china-1.eecloud.nsn-net.net/mMIMO-debug-tool/TtiTraceHelper
# config
${testline_configuration_path}     ~${/}testline_configuration
${tl_allow_faults_file_name}       testline_allow_faults.yml
@{Ohter_Allow_Alarms}
# for artifactory login
&{Artifactory_INFO}        path=/shared/TA2021/TA_Case/.netrc
...                        USERNAME=root
...                        PASSWORD=uteadmin
...                        Host=10.56.198.140
...                        local_path=/home/ute/.netrc
&{Nsetap_INFO}             path=/shared/TA2021/TA_Case/nsetap/nsetap-3.6-2.19.0.dll
...                        xpath=/shared/TA2021/TA_Case/nsetap/nsetapx-3.6-1.4.1.dll
...                        USERNAME=root
...                        PASSWORD=uteadmin
...                        Host=10.56.198.140
...                        file1=nsetap-3.6-2.19.0.dll
...                        file2=nsetapx-3.6-1.4.1.dll

&{Logserver_INFO}          USERNAME=ute
...                        PASSWORD=Ut3pa5s#ff97
...                        Host=10.69.69.233
${MoveLog_to_Logserver}    ${False}
${WTS_CFG}                 wts.cfg
${WTS_DIR}                 /opt/iphy/latest/
