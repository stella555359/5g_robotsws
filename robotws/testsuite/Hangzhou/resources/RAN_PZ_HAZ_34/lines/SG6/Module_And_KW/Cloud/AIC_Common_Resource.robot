*** Settings ***
Documentation
...    Author: mengli yang
...    Email address: mengli.yang@nokia-sbell.com
...    Maintainer: mengli yang
...    Email address: mengli.yang@nokia-sbell.com
...    This robot file related to AIC common resource.
...    All the bugs/new keyword needs/improvement should be raised in Jira and assign to the Maintainer.
...    Jira link: https://jiradc.ext.net.nokia.com/projects/PZ1HAZTA/issues
...    Guideline: https://confluence.ext.net.nokia.com/display/SRANPRODHZHTA/09.+AIC+Common+Resource+Supporting+Mode+Improvement)

Library           Collections
Library           re
Library           DateTime
Library           OperatingSystem
Library           Process
Library           Screenshot
Library           String
Library           yaml
Library           XML
Library           Telnet
Library           json
Library           Selenium2Library        run_on_failure=NONE
Library           SSHLibrary
Library           taf.hw.rf_attenuator       WITH NAME    attenuator
Library           taf.ue                                WITH NAME    ute_ue
Library           taf.hw.pdu                            WITH NAME    pdu
Library           taf.transport.ssh                     WITH NAME    tafssh
Library           taf.hw.fhgw.cli                       WITH NAME    issh
Library           taf.config.scf                        WITH NAME    scf
Library           taf.analyzer.pdml                     WITH NAME    cpdml
Library           taf.ul.parser.pcap                    WITH NAME    pcap
Library           taf.gnb.oam.commissioning             WITH NAME    commissioning
Library           taf.ul.vdu.helm                       WITH NAME    helm
Library           taf.gnb.oam.coam.cu.interface.cu      WITH NAME    cu
Library           taf.gnb.oam.coam.vdu.interface.Vdu    WITH NAME    vdu
Library           taf.selenium.gnb.oam.coam.vdu         WITH NAME    svdu
Library           taf.selenium.gnb.oam.coam.cu         WITH NAME     scu
Library           taf.selenium.nms.nom                  WITH NAME    nom_selenium
Library           taf.nms.nom                           WITH NAME    nom_rest
Library           taf.cloud.cbam                        WITH NAME    cbam
Library           taf.nms.nsp.nfmp                      WITH NAME    nfmp
Library           taf.collectors.simple                 WITH NAME    simple_collect
Library           taf.collectors.core                   WITH NAME    core_collect
Library           taf.collectors.kubernetes             WITH NAME    kubelog_collect
Library           taf.collectors.docker                 WITH NAME    dockerlog
Library           taf.transport.bmc                     WITH NAME    bmc
Library           taf.nms.netact                        WITH NAME    netact
Library           taf.ul.oam.netact.cm                  WITH NAME    netact_cm
Library           taf.ccs.aashell                       WITH NAME    aashell
Library           taf.sw.reporting_portal               WITH NAME    rp
Library           taf.config.testline.info.testline_info.TestlineInfo    WITH NAME    tl_info
Library           taf.transport.ssh    WITH NAME    csn
Library           taf.ue.pioneer.client            WITH NAME    client
Library           python/collect_and_analysis_bip_log.py    WITH NAME    bip
Library           python/collect_wireshark_log.py    WITH NAME    wireshark
Library           python/collect_k8s_log.py    WITH NAME    k8s
Library           python/collect_and_analysis_tti_log.py    WITH NAME    tti
Library           python/collect_counter.py    WITH NAME    counter
Library           python/basic.py    WITH NAME    basic
Library           python/aic_parameter.py    WITH NAME    aic_param
Library           ../Common/python/dcap.py    WITH NAME    dcap
Library           ../Common/python/process_timed_remote_files.py
Library           process_timed_remote_files.TimedRemoteFileDownloader   WITH NAME    timed_file_downloader
Library           python/process_csv.py    WITH NAME    process_csv
Library           python/truck_roll.py    WITH NAME    truck_roll
Library           ../Common/python/ue.py
Library           ../Common/python/file_operation.py
Library           python/rrm_variables.py
Library           python/netact.py    WITH NAME    na
Resource          AIC_Common_Setup_Teardown.robot
Resource          AIC_BTS.robot
Resource          AIC_Capture_Analysis_Log.robot
Resource          ../Common/AIC_UE.robot
Resource          ../Common/RRM_UE2.robot
Resource          ../Common/Config_File_Operation.robot
Resource          AIC_Counter_KPI.robot
Resource          AIC_CN.robot
Resource          device_connection/PA.robot
Resource          taf/rfrl/common_resources/common_step/interface.robot
Resource          AIC_Nom.robot
Resource          AIC_NetAct.robot
Resource          ../Common/AIC_DCAP.robot
Resource          AIC_Selenium.robot
Resource          AIC_Airphone.robot
Library           python/xml_handle.py
Library           xml_handle.OperateXml
Variables         Configuration/NetAct.py
Library             ../Common/python/sigspark.py
Library             sigspark.SigSpark     WITH NAME    SigSpark
############# Module ##########
Resource          ../../../../resources/RAN_PZ_HAZ_1/Module/Module.robot

*** Variables ***
${RESULT_DIR}                ${OUTPUT DIR}
${PC_HOST}                   ${tl.test_pc.default_ssh_connection_details.addr}
${PC_USER}                   ${tl.test_pc.default_ssh_connection_details.username}
${PC_PASSWORD}               ${tl.test_pc.default_ssh_connection_details.password}
${MRBTS_ID}                  ${tl.gnbs[0].instance_id}
${NRBTS_ID}                  ${tl.gnbs[0].global_bts_id}
${MRBTS_ID_vDU}              ${tl.gnbs[0].dus[0].instance_id}
# ${vdu1_attenuator_port_1}    ${tl.gnbs[0].dus[0].fhgws[0].rus[0].attenuation_ports[0].port_no}
# ${vdu1_attenuator_port_2}    ${tl.gnbs[0].dus[0].fhgws[0].rus[0].attenuation_ports[1].port_no}
${QPSTexe}                   "/cygdrive/c/Program Files (x86)/Qualcomm/QPST/bin/QPSTConfig.exe"
${MCSHARK_TOOL_LINK}         https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/MCShark
${cbctest_ip}                10.9.202.153
${cbctest_usr}               cbctest
${cbctest_psw}               cbctest
${cbctest_alias}             cbctest
@{amfs}                      tang_amf    liang_amf    zhou_amf
${cbctest_path}              /home/cbctest/RRM3
&{amf2-amfsui1}              connect_hostname=10.110.66.229    mcc=262    mnc=03    tac=280
&{amf1-amf1-zheng}           connect_hostname=10.110.133.97    mcc=262    mnc=03    tac=280
&{Artifactory_INFO}        path=/shared/TA2021/TA_Case/.netrc
...                        USERNAME=root
...                        PASSWORD=uteadmin
...                        Host=10.56.198.140
...                        local_path=/home/ute/.netrc
&{Logserver_INFO}          USERNAME=ute
...                        PASSWORD=Ut3pa5s#ff97
...                        Host=10.69.69.233
${MoveLog_to_Logserver}    ${False}
${UTE_EXECUTION_JSON}              /opt/ute/execution.context.json
${UTE_RESERVATION_CONTEXT_JSON}    /opt/ute/reservation.context.json
${UTE_RESERVATION_JSON}            /opt/ute/reservation.json
${DEBUG_MODE}              ${False}

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
@{ALLOWED_FAULT}           &{fault_61652}    &{fault_61524}    &{fault_61649}    &{fault_4654}    &{fault_6450}    &{fault_4592}
...                        &{fault_4655}    &{fault_7311}
