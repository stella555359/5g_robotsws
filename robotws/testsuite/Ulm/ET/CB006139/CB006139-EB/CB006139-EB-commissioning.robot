*** Settings ***
Documentation   This is a keyword file for CB006139-EB, part commissioning
...             Team: 'MN RAN RD VRF ULM 2'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------


*** Keywords ***

Bring NRBTS-1 And NRBTS-2 To OnAir
    [Documentation]    [PRIVATE]    Bring NRBTS-1 And NRBTS-2 To onAir
    ...       :Autor: Sylvia Schneider
    wts_ue.Kill WTS Services
    CB006139-keywords-wireshark.Start Wireshark Trace
    CB006139-keywords.Check All Radio Units Online
    Log To Console    start to bring tl on air without reboot
    ute_workarounds.Bring Airphone TL To On Air Status Without Reboot
    CB006139-keywords-wireshark.Stop Wireshark Trace For Setup
    CB006139-keywords-wts.Check WTS In Active State
    Setup 2nd X2link
    gnb.Wait Until All GNBs To Be Onair State


Open Http Session For 2nd Gnb Commissioning
    [Documentation]    [PRIVATE]    Open Http Session For 2nd Gnb Commissioning
    ...       :Autor: Sylvia Schneider
    ${oam_alias_2}    connect.Setup OAM HTTP Session    node_type=gnb  node_id=${1}
    Set Test Variable   ${oam_alias_2}


Close Http Session For 2nd Gnb Commissioning
    [Documentation]    [PRIVATE]    Close Http Session For 2nd Gnb Commissioning
    ...       :Autor: Sylvia Schneider
    connect.Teardown OAM HTTP Session    node_type=gnb  node_id=${1}


Set NRBTS-2 NRCELL-7 maxNumOfSCellAlloc To 1
    [Documentation]    [PRIVATE]    Set NRBTS-2 NRCELL-7 maxNumOfSCellAlloc To 1
    ...       :Autor: Sylvia Schneider
    Log To Console    \ndelta commissioning set NRBTS-2/NRCELL-7 param maxNumOfSCellAlloc to 1
    Open Http Session For 2nd Gnb Commissioning
    admin.Perform Delta Recommissioning
    ...    ${CURDIR}/NRBT2_scell7_maxNumOfSCellAlloc_1.json
    ...    should_activate=True
    ...    timeout=300
    ...    connection=${oam_alias_2}
    Close Http Session For 2nd Gnb Commissioning
    gnb.Get SCF From GNB With COAM          gnbScfName=SCFC_upd_2nd.xml   resultConfigDir=${resultDir}   gnb_id=1


Setup 2nd X2link
    [Documentation]    [PRIVATE]    setup 2nd X2link
    ...       :Autor: Sylvia Schneider
    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=enb_x2_link_up enb=1 target=3    pass_regexp=X2AP Link with GNB-3 .* is up     alias=ap_egate
