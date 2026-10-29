*** Settings ***
Documentation
...   author: cheng xianbiao
...   contact: xianbiao.cheng@nokia-sbell.com

Library           Collections
Library           DateTime
Library           OperatingSystem
Library           Process
Library           Screenshot
Library           String
Library           yaml
Library           XML
Library           Telnet
Library           json
# Library           FtpLibrary
Library           taf.hw.rf_attenuator       WITH NAME    att
Library           taf.ue                                WITH NAME    ute_ue
Library           taf.pdu                               WITH NAME    pdu
Library           taf.transport.ssh                     WITH NAME    tafssh
Library           taf.hw.fhgw.cli                       WITH NAME    issh
Library           taf.config.scf                        WITH NAME    scf
Library           taf.analyzer.pdml                     WITH NAME    cpdml
Library           taf.gnb.oam.commissioning             WITH NAME    commissioning
Library           taf.ul.vdu.helm                       WITH NAME    helm
Library           taf.gnb.oam.coam.cu.interface.cu      WITH NAME    cu
Library           taf.gnb.oam.coam.vdu.interface.Vdu    WITH NAME    vdu
Library           taf.selenium.gnb.oam.coam.vdu         WITH NAME    svdu
Library           taf.selenium.nms.nom                  WITH NAME    nom_selenium
Library           taf.nms.nom                           WITH NAME    nom_rest
Library           taf.cloud.cbam                        WITH NAME    taf_cbam
Library           taf.nms.nsp.nfmp                      WITH NAME    nfmp
Library           taf.collectors.simple                 WITH NAME    simple_collect
Library           taf.collectors.core                   WITH NAME    core_collect
Library           taf.collectors.kubernetes             WITH NAME    kubelog_collect
Library           taf.collectors.docker                 WITH NAME    dockerlog
Library           taf.transport.bmc                     WITH NAME    bmc
Library           taf.nms.netact                        WITH NAME    taf_netact
Library           taf.ul.oam.netact.cm                  WITH NAME    netact_cm
Library           taf.ul.oam.netact.swm                 WITH NAME    netact_swm
Library           taf.selenium.gnb.oam.coam.cu          WITH NAME    scu
Library           taf.config.testline.info.testline_info.TestlineInfo    WITH NAME    tl_info
Library           taf.analyzer.pcap                     WITH NAME    pcap
Library           taf.cloud.lcmaas                      WITH NAME    lcmaas
Library           taf.sw.dcap.rd                        WITH NAME    dcap_rest
Library           ute_reporting_portal                  WITH NAME    rp
Library           ./py_tool/utils.py
Library           ./py_tool/vdu_cli.py
Library           ./py_tool/get_csv_data.py
Library           ./py_tool/cu_config_modify.py
Library           ./py_tool/global_variables.py
Library           ./py_tool/scf_netact.py
Library           ./py_tool/cu_api.py
Library           ./py_tool/yaml_parse.py
Library           ./py_tool/cu_api.py
Library           ./py_tool/vdu_create_multi_cells_scf.py
Library           ./py_tool/jenkins_x_doctor.py  WITH NAME  jenkins
Resource          cu_oam_fm.robot
Resource          vdu_oam_fm.robot
Resource          ru.robot
Resource          ue.robot
Resource          rrm.robot
Resource          variables.robot
Resource          common_pre_post_condition.robot
Resource          common_setup_teardown.robot
Resource          nom_oam_cli.robot
Resource          nom_oam_fm.robot
Resource          nom_oam_integration.robot
Resource          nom_oam_cm.robot
Resource          nom_oam_selenium.robot
Resource          nom_testline_configuration.robot
Resource          nom_oam_cloud.robot
Resource          fhgw.robot
Resource          cbam.robot
Resource          emil.robot
Resource          taf/rfrl/common_resources/common_step/interface.robot
Resource          taf/rfrl/cbts/robot/netact/netact.robot
Resource          taf/rfrl/cbts/robot/vcu/vcu_operations.robot
Resource          x_Tower.robot
Resource          nsp.robot
Resource          pcmd.robot
Resource          netact_testline_configuration.robot
Resource          netact.robot
Resource          pcap_parse.robot

Resource      cu_trs_conn.robot
Resource      cu_trs_tls.robot
Resource      cu_trs_others.robot
Resource      vdu_trs_conn.robot
Resource      vdu_trs_fw.robot
Resource      vdu_trs_others.robot
Resource      vdu_trs_sync.robot
Resource      vdu_trs_tls.robot
Resource      vran_trs_ip.robot
Resource      vran_trs_qos.robot
Resource      vran_trs_switch.robot
Resource      vran_others.robot
Resource      cu_testline_configuration.robot
Resource      cu_sec_cert.robot
Resource      cu_sec_ipsec.robot
Resource      cu_oam_state.robot
Resource      cu_oam_cm.robot
Resource      cu_cloud_recovery.robot
Resource      vdu_testline_configuration.robot
Resource      vdu_sec_cert.robot
Resource      vdu_sec_authorization.robot
Resource      vdu_sec_ipsec.robot
Resource      vdu_oam_state.robot
Resource      vdu_oam_cm.robot
Resource      vdu_cloud_swm.robot
Resource      vdu_cloud_recovery.robot
Resource      vdu_cloud_deployment.robot
Resource      cu_cloud_deployment.robot
Resource      cu_cloud_swm.robot
Resource      cu_oam_pm.robot
Resource      cu_oam_selenium.robot
Resource      vdu_oam_pm.robot

Resource      cu_log_containerlog.robot
Resource      common_log.robot
Resource      vdu_oam_pm.robot
Resource      vdu_log_wireshark.robot
Resource      vdu_log_startuplog.robot
Resource      vdu_log_snapshot.robot
Resource      vdu_log_other.robot
Resource      vdu_log_containerlog.robot
Resource      vdu_log_bip.robot
Resource      fhgw_log.robot
Resource      cu_log_wireshark.robot
Resource      cu_log_startuplog.robot
Resource      cu_log_snapshot.robot
Resource      cu_log_journey.robot
Resource      cu_log_cnf_wireshark.robot
Resource      cu_trs_fw.robot
Resource      pst.robot

Resource      kw_to_be_optimized.robot
Resource      aic_common_resources_new.robot
Resource          taf/rfrl/cbts/robot/fhgw/fhgw_log.robot
Resource          taf/rfrl/cbts/robot/ru/ru_operations.robot
Resource          taf/rfrl/cbts/robot/ue/real_ue.robot

##### feature resources ############
Resource      feature/cni-81588.robot
Resource      feature/cb008184.robot
Resource      feature/cb007257.robot



*** Variables ***
# @{IGNORED_ALARM_LIST}


*** Keyword ***




