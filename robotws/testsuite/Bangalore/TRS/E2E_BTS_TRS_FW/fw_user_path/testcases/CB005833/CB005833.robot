*** Settings ***
Documentation
...        [Procedure]        "[1][1.0] TRS_CB005833_eCPRI_Mplane_Transport_Resiliency_BFD_Alarm_verification"
...        [Date]             "28-05-2023"
...        [Author]           "Anshu Bhat"
...        [Feature_ID]       "CB005833"
...        [Maintenance]      "TRS I & V Tools Bangalore Team"
...        [Funtion_Hash_Tags] "Mplane resiliency,BFD ingress and egress"
...        [DELTA_FILE_DEPENDENCY]  "set_bfdActivation_to_true.json,set_bfdAdminup_to_true.json,set_bfdActivation_to_false.json,"
...                                    "set_bfdAdminup_to_false.json,FHFirewall.json,RUEnabled.json"}
...        [Validated_TestLine]     "IAV_BLR_3622"
...        [Config_Comments]         "Mplane resiliency with BFD sessions"
...        [Precondition]             "ENodeB should be integrated to Netact"

variables       ta_e2e_bts_trs_fw
Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/CB005833_Keywords.robot
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot

Force Tags      CA_E2ET_BTSTRSPZ        SBTS00        SBTS21B     SBTS25R1   SBTS25R2   4G_FDD       QCD_MN_RAN        QCP_RAN_VRF        CRT

Suite Setup             Run Keywords    Suite Setup Preconditions
...             AND             Setup Oamops
Suite Teardown     Run Keywords         Suite Teardown Postconditions
...             AND             Teardown Oamops

*** Variables ***
${rf_pswd}      oBrd1RgbOasUtYAeVfxrW9yGHb6ONl0w+MJUoKrBMGE=
${BFD_ID}       1

***Test Cases***
[1][1.0] TRS_CB005833_Transport_configuration_of_Mplane_for_eCPRI_Transport_Resilience_when_RU_connected_to_one_CC_ASIM
  Preconditions
  Fetching details
  Check Routes and vlans
  Generate Egress alarm for BFD-1         ${loopback_ip}     ${rf_pswd}
  Verify Alarm		fault_id=61606		should_exist=${True}
  Check Routes are deleted
  Check ping connectivity to loopback ip    1
  Verify Alarm		fault_id=61605		should_exist=${False}
  Making bfdAdminUp as false
  Verify Alarm		fault_id=61606		should_exist=${False}
  Verify Alarm		fault_id=61605		should_exist=${False}
  Check Admin state for BFD session     down
  Check ping connectivity to loopback ip    1
  Making bfdAdminUp as true
  Verify Alarm		fault_id=61606		should_exist=${True}
  Check Admin state for BFD session      down1
  Making bfdActivation as false
  Verify Alarm		fault_id=61606		should_exist=${False}
  Verify Alarm		fault_id=61605		should_exist=${False}
  Check ping connectivity to loopback ip    3
  Check Routes are deleted
  No BFD packets in wireshark
  Making bfdActivation as true
  Verify Alarm		fault_id=61606		should_exist=${True}
  Generate Ingress alarm for BFD-1         ${loopback_ip}     ${rf_pswd}
  Verify Alarm		fault_id=61605		should_exist=${True}
  Verify Alarm		fault_id=61606		should_exist=${False}
  Clear Ingress alarm for BFD        ${loopback_ip}     ${rf_pswd}
  Clear Egress alarm for BFD         ${loopback_ip}     ${rf_pswd}
  Check Routes are added
  Check Admin state for BFD session      up
  Verify Alarm		fault_id=61605		should_exist=${False}
  Verify Alarm		fault_id=61606		should_exist=${False}
  Change actEcpriRuMPlaneSecurity as RuProtectEnabled
  Enable FH Firewall
  Change preference value and verify
  Check ping connectivity to loopback ip    4
  Revert preference value and verify
  Check ping connectivity to loopback ip    5
  Change desMinTxInt and reqMinRxInt and verify modified value in tcpdump
  Change bfdSrcUdpPort and verify modified value in tcpdump
  [Teardown]  Teardown Ems  config_device=netact2005  alias=lab2005




