** Settings ***
Resource        ../resources/robot/wts_sim_keywords.robot

#Suite Setup     Load CFG and verify cell status   ${wts_cfg_file}   1   2
#Suite Teardown      Run Keyword and Ignore error    Clean edaemon and egate

*** Variables ***
${wts_cfg_file}     vonr_tdd.cfg
${WTS_DIR}          /opt/iphy/latest/

*** Test cases ***
Test
    [Timeout]   300s
    Load CFG and verify cell status   ${wts_cfg_file}   1   2
    UE Register should be Successful     ue_id=1     pdu_id=1     nw_id=1     gw_id=1
    Trigger data        ue_id=1     dir=dl      pdu_id=1     trf_id=1       qfi=1   Traffic_unit=kbps       traffic_rate=2
    Stop data       ue_id=1    pdu_id=1    dir=dl    trf_id=1   qfi=1
    UE PDU Session release      ue_id=1     pdu_id=1
    UE Deregister should be Successful  ue_id=1
    [Teardown]  Clean edaemon and egate

Test1
    [Timeout]   300s
    ${crnti}    MultiUE Register should be Successful   1   2   1   1
    MultiUE Trigger DL Traffic for SA   1    2   Traffic_rate=mbps    dl_rate=2    pdu_id=1     trf_id=1    qfi_id=1
    [Teardown]    MultiUE Deregister should be Successful   1   2

Test2
    [Timeout]   300s
    MultiUE Register should be Successful   1   1   1   1
    MultiUE PDU Addition should be Successful       1   1    nw_id=1    pdu_id=2
    MultiUE PDU Modfication should be Successful     1  1    pdu_id=2   qosflows_to_add=2
    Sleep   3s
    MultiUE PDU Modfication should be Successful     1  1    pdu_id=2   qosflows_to_add=3
    Trigger MultiUE VoNR DL Traffic for SA    1     1    pdu_id=2     trf_id=2     qfi_id=3    rtp_codec=custom
    Stop MultiUE Data Traffic for SA    1   1
    [Teardown]  MultiUE Deregister should be Successful   1   1


