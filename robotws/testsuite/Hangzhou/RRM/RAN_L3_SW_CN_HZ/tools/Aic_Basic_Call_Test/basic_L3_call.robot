*** Settings ***
Documentation
...  Basic L3 call test for vRAN2.0 2vDU
...  Manitenance: Zhubaijie
Suite setup     SANSA Common Suite Setup
Suite teardown    SANSA Common Suite Teardown

Resource    common_resources.robot

*** Variables ***
${WTS_DIR}    /opt/iphy/latest
${WTS_CFG}    ${WTS_DIR}/basic_setup.cfg
#${WTS_CFG_PATH}    ${CURDIR}/cfg/wts_config_dR2.0_2vDU_AP_LO_TDD_eCPRI_cmwv_SANSA_FS.cfg

*** Test Cases ***
SA L3 call
    SA attach  id=1
    Setup PDU session  pdu=1  ue=1  nwslice=1  gw=1
    SA attach  id=2
    Setup PDU session  pdu=1  ue=2  nwslice=1  gw=2
    Start SA traffic  ue=1  pdu=1  qfi=1  dir=dl  trf_id=1  protocol=udp  mbps=10
    Start SA traffic  ue=1  pdu=1  qfi=1  dir=ul  trf_id=2  protocol=udp  mbps=10
    Start SA traffic  ue=2  pdu=1  qfi=1  dir=dl  trf_id=1  protocol=udp  mbps=10
    Start SA traffic  ue=2  pdu=1  qfi=1  dir=ul  trf_id=2  protocol=udp  mbps=10
    Verify SA Throughput
    Stop SA traffic  ue=1  pdu=1  qfi=1  dir=dl
    Stop SA traffic  ue=1  pdu=1  qfi=1  dir=ul
    Stop SA traffic  ue=2  pdu=1  qfi=1  dir=dl
    Stop SA traffic  ue=2  pdu=1  qfi=1  dir=ul
    Release PDU session  ue=1  pdu=1
    SA detach  id=1  ue_deregister_type=switch_off  by=ue
    Release PDU session  ue=2  pdu=1
    SA detach  id=2  ue_deregister_type=switch_off  by=ue

NSA L3 call
    Trigger X2 link    enb=1  target=2
    NSA attach  ue=11  enb=1  gnb=2  target_cells=1  bearer=2
    NSA attach  ue=12  enb=1  gnb=2  target_cells=2  bearer=2
    Start NSA traffic  ue=11  id=2  dir=dl  trf_id=3  protocol=udp  mbps=10
    Start NSA traffic  ue=11  id=2  dir=ul  trf_id=4  protocol=udp  mbps=10
    Start NSA traffic  ue=12  id=2  dir=dl  trf_id=3  protocol=udp  mbps=10
    Start NSA traffic  ue=12  id=2  dir=ul  trf_id=4  protocol=udp  mbps=10
    Verify NSA Throughput
    Stop NSA traffic  ue=11  id=2  dir=dl  trf_id=3
    Stop NSA traffic  ue=11  id=2  dir=ul  trf_id=4
    Stop NSA traffic  ue=12  id=2  dir=dl  trf_id=3
    Stop NSA traffic  ue=12  id=2  dir=ul  trf_id=4
    NSA Detach  ue=11  bearer=2  by=enb  cause=MISC_CauseMisc_unspecified
    LTE detach  id=11
    NSA Detach  ue=12  bearer=2  by=enb  cause=MISC_CauseMisc_unspecified
    LTE detach  id=12
