*** Settings ***
Documentation
...    This file contains keywords used for testing Feature 5GC000782 on Cloud RINLINE.

*** Keywords ***
Enable AiC srb3Support
    Perform CU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/5GC000782/delta_enable_srb3Support_CU.json

Start tcpdump
    [Arguments]    ${file_name}
    ${alias}=    Start Tshark For Custom Interface  eth_interface=lo
    ${pid}=    TcpdumpCU.Tcpdump F1 Start    sctp    ${OUTPUT_DIR}/${file_name}.pcap    any
    set global variable    ${pid}
    set global variable    ${alias}

Stop tcpdump
    TcpdumpCU.tcpdump F1 Stop   ${pid}
    Sleep    10s

Verity Tshark Messages
    [Arguments]    ${alias}    ${message}    ${file_name}
    Verify Tshark
    ...    alias=${alias}
    ...    packet_filter=${message}
    ...    pass_criteria=>=1
    ...    pcap_file_path=${OUTPUT_DIR}/${file_name}.pcap

Check Wireshark Pcap For Exisitng Messages
    [Arguments]    ${alias}    ${file_name}    ${ciphering_algoritm}
    Verity Tshark Messages    ${alias}    x2ap.nRencryptionAlgorithms == e0:00    ${file_name}
    Verity Tshark Messages    ${alias}    x2ap.id == 214    ${file_name}
    Verity Tshark Messages    ${alias}    f1ap.id == 9    ${file_name}
    Verity Tshark Messages    ${alias}    f1ap.id == 39    ${file_name}
    Verity Tshark Messages    ${alias}    nr-rrc.cipheringAlgorithm == ${ciphering_algoritm}    ${file_name}
    Verity Tshark Messages    ${alias}    e1ap.cipheringAlgorithm == ${ciphering_algoritm}    ${file_name}
    Verity Tshark Messages    ${alias}    e1ap.id == 16    ${file_name}

Modify AiC Config Ciphering 5GC000782-A
    wts.Load Wts Cfg        ${EPCSIM_CFG_PATH_SANSA_TDD_FDD_AIC}
    wts.Delete    set_ue simulated id=11
    wts.Insert    set_ue simulated id=11 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56    before    ue_param id=11
    wts.Modify    set_ue simulated id=11       sec_key=0102030405060708090A0B0C0D0EFF00 nia=aes+zuc+snow3g+null nea=null+aes imsi=311:489:21645527
    wts.Delete    set_ue simulated id=12
    wts.Insert    set_ue simulated id=12 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56    before    ue_param id=12
    wts.Modify    set_ue simulated id=12       sec_key=0102030405060708090A0B0C0D0EFF00 nia=aes+zuc+snow3g+null nea=snow3g+zuc imsi=311:489:21645528
    wts.Delete    set_ue simulated id=13
    wts.Insert    set_ue simulated id=13 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56    before    ue_param id=13
    wts.Modify    set_ue simulated id=13       sec_key=0102030405060708090A0B0C0D0EFF00 nia=aes+zuc+snow3g+null nea=snow3g+aes imsi=311:489:21645529
    wts.Delete    set_ue simulated id=14
    wts.Insert    set_ue simulated id=14 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56    before    ue_param id=14
    wts.Modify    set_ue simulated id=14
    ...    sec_key=0102030405060708090A0B0C0D0EFF00 nia=aes+zuc+snow3g+null nea=aes+zuc+snow3g+null imsi=311:489:21645530
    wts.Save Wts Cfg        ${EPCSIM_CFG_PATH_SANSA_TDD_FDD_AIC}

Modify AiC Config Ciphering 5GC000782-B
    wts.Load Wts Cfg        ${EPCSIM_CFG_PATH_SANSA_TDD_FDD_AIC}
    wts.Delete    set_ue simulated id=11
    wts.Insert    set_ue simulated id=11 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56    before    ue_param id=11
    wts.Modify    set_ue simulated id=11
    ...    sec_key=0102030405060708090A0B0C0D0EFF00 nia=aes+zuc+snow3g+null nea=null+zuc+snow3g+aes imsi=311:489:21645527
    wts.Save Wts Cfg        ${EPCSIM_CFG_PATH_SANSA_TDD_FDD_AIC}