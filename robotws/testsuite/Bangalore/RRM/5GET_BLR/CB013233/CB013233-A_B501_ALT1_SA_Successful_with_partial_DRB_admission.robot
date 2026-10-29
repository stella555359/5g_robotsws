*** Settings ***
Force Tags      CLOUD_5G_I_MP_AP_LO     RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_SC_FDD    5G_RAN
...    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE   SBTS00     CONFIGURED     PY39

Documentation
...
...             author:           Sruthi
...             maintainer:       sruthi.jacob@nokia.com
...
...             INTRODUCTION:     TThe user scenario targets the DRX configuration for SA UE during ICS when gNB-DU partially
...                               admits DRBs. F1AP: UEContextSetupRequest message to gNB-DU to setup DRB, includes DRXCycle IE.
...                               gNB-DU partially admits DRBsand configures DRX considering admitted DRBs. First RRCReconfiguration
...                               to UE includes DRX configuration. After NGAP:InitialContextSetupResponse to AMF gNB does not send
...                               dedicated RRCReconfiguration to configure DRX to UE
...             TEST SET NAME:    CB013233
...             TESTING SPLIT:    Refer CB013233 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB013233 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_26393

Resource          ../CNI-100444/resource/CNI-100444_keywords.robot

Suite Setup         Run keywords     Log to console      "Suite Setup started"
...                 AND     BuiltIn.Log     ${SCFC}
...                 AND     Prepare TL with config files
...                 AND     Suite setup from scratch
...                 AND    Sleep    2min
...                 AND    Setup_Env.Reboot GNB System Module From Console And Check Airscale Is Ready
...                 AND    Start Default Logging Gnb ASIL_ABIO
...                 AND     WTS_Runner_Keywords.Start WTS Using WTS_Runner      ${LUA_CFG}

Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Revert GNB RadParam
...                 AND     Stop Default Logging Gnb ASIL_ABIO

*** Variables ***
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${sa_ue_id1}      ${1}
${sa_ue_id2}      ${2}
${sa_ue_id3}      ${3}
${sa_ue_id4}      ${4}
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID1}       1
${Pdu_session_ID2}       2
${TRF_ID}     1
${QFI_ID}     1
${TEST_NAME}     None

${LUA_CFG}=                ${CURDIR}/config/A_B201_ALT_1/CB013233_A_B501_ALT1_TDD.cfg
${SCFC}=                   ${CURDIR}/config/A_B201_ALT_1/SCF_CB013233_A_B501_ALT1_TDD.xml
${AP_XML}=                 ${CURDIR}/config/A_B201_ALT_1/iphy_CB013233_A_B501_ALT1_TDD.xml

*** Test Cases ***
[1]CB013233-A#B501_ALT1_Successful early DRX setup for UE in SA mode with partial DRB admission (non-emtpy PDU)
    log to console     Suite setup done
    Enable Max integrity dat rate    msg=pdu_session_setup     int_prot=required     conf_prot=required
    sleep    5s
    MultiUE Register should be Successful   start_ue_id=${sa_ue_id1}    end_ue_id=${sa_ue_id4}     pdu_id=${Pdu_session_ID1}
    ...     nw_id=${nwslice_ID}
    sleep    5s
    MultiUE PDU Addition should be Successful    start_ue_id=${sa_ue_id2}  end_ue_id=${sa_ue_id2}   pdu_id=${Pdu_session_ID2}
    ...    nw_id=${nwslice_ID}
    sleep    5s
    MultiUE PDU Addition should be Successful    start_ue_id=${sa_ue_id4}    end_ue_id=${sa_ue_id4}  pdu_id=${Pdu_session_ID2}
    ...   nw_id=${nwslice_ID}
    sleep    5s
     #QCI-9
    MultiUE PDU Modfication should be Successful   start_ue_id=${sa_ue_id1}   end_ue_id=${sa_ue_id1}    pdu_id=${Pdu_session_ID1}  qosflows_to_add=4
    sleep    5s
    #QCI-9
    MultiUE PDU Modfication should be Successful   start_ue_id=${sa_ue_id2}   end_ue_id=${sa_ue_id2}    pdu_id=${Pdu_session_ID1}   qosflows_to_add=4
    sleep    5s
     #QCI-3
    MultiUE PDU Modfication should be Successful   start_ue_id=${sa_ue_id2}   end_ue_id=${sa_ue_id2}    pdu_id=${Pdu_session_ID2}   qosflows_to_add=5
    sleep    5s
     #QCI-9
    MultiUE PDU Modfication should be Successful   start_ue_id=${sa_ue_id4}   end_ue_id=${sa_ue_id4}    pdu_id=${Pdu_session_ID1}   qosflows_to_add=4
    sleep    5s
     #QCI-3
    MultiUE PDU Modfication should be Successful   start_ue_id=${sa_ue_id4}   end_ue_id=${sa_ue_id4}    pdu_id=${Pdu_session_ID2}   qosflows_to_add=5
    sleep    5s
    MultiUE Trigger DL Traffic for SA   start_ue_id=${sa_ue_id1}   end_ue_id=${sa_ue_id1}   Traffic_rate=mbps   dl_rate=1
    ...     pdu_id=${Pdu_session_ID1}  trf_id=2  qfi_id=2
    sleep    10s
    Validate DL Traffic For MultiUE for SA    start_ue_id=1  end_ue_id=1     dl_rate=1    pdu_id=${Pdu_session_ID1}       qfi_id=2
    MultiUE Trigger UL Traffic for SA    start_ue_id=${sa_ue_id1}    end_ue_id=${sa_ue_id1}   Traffic_rate=mbps
    ...     ul_rate=1     pdu_id=${Pdu_session_ID1}     trf_id=3   qfi_id=2
     sleep    10s
    Validate UL Traffic For MultiUE for SA    start_ue_id=1   end_ue_id=1       ul_rate=1    pdu_id=${Pdu_session_ID1}      qfi_id=2
    sleep  5s
    MultiUE Trigger DL Traffic for SA    start_ue_id=${sa_ue_id2}     end_ue_id=${sa_ue_id2}   Traffic_rate=mbps     dl_rate=1
    ...     pdu_id=${Pdu_session_ID1}     trf_id=4    qfi_id=2
    sleep    10s
    Validate DL Traffic For MultiUE for SA    start_ue_id=2  end_ue_id=2    dl_rate=1    pdu_id=${Pdu_session_ID1}       qfi_id=2
    sleep    5s
    MultiUE Trigger UL Traffic for SA    start_ue_id=${sa_ue_id2}    end_ue_id=${sa_ue_id2}   Traffic_rate=mbps      ul_rate=1
    ...    pdu_id=${Pdu_session_ID1}     trf_id=5   qfi_id=2
    sleep    10s
    Validate UL Traffic For MultiUE for SA    start_ue_id=2   end_ue_id=2       ul_rate=1    pdu_id=${Pdu_session_ID1}      qfi_id=2
    sleep  5s
    MultiUE Trigger DL Traffic for SA    start_ue_id=${sa_ue_id2}     end_ue_id=${sa_ue_id2}   Traffic_rate=kbps     dl_rate=1
    ...    pdu_id=${Pdu_session_ID2}     trf_id=6    qfi_id=1
    sleep    10s
    Validate DL Traffic For MultiUE for SA    start_ue_id=2  end_ue_id=2     dl_rate=.001    pdu_id=${Pdu_session_ID2}       qfi_id=1
    sleep  5s
    MultiUE Trigger UL Traffic for SA    start_ue_id=${sa_ue_id2}    end_ue_id=${sa_ue_id2}   Traffic_rate=kbps      ul_rate=1
    ...    pdu_id=${Pdu_session_ID2}     trf_id=7   qfi_id=1
    sleep  10s
    Validate UL Traffic For MultiUE for SA    start_ue_id=2   end_ue_id=2       ul_rate=.001    pdu_id=${Pdu_session_ID2}      qfi_id=1
    sleep  5s
    MultiUE Trigger DL Traffic for SA    start_ue_id=${sa_ue_id3}     end_ue_id=${sa_ue_id3}   Traffic_rate=mbps     dl_rate=1
    ...    pdu_id=${Pdu_session_ID1}     trf_id=8    qfi_id=1
    sleep    10s
    Validate DL Traffic For MultiUE for SA    start_ue_id=3  end_ue_id=3     dl_rate=1    pdu_id=${Pdu_session_ID1}       qfi_id=1
    sleep  5s
    MultiUE Trigger UL Traffic for SA    start_ue_id=${sa_ue_id3}    end_ue_id=${sa_ue_id3}   Traffic_rate=mbps      ul_rate=1
    ...    pdu_id=${Pdu_session_ID1}     trf_id=9    qfi_id=1
    sleep    10s
    Validate UL Traffic For MultiUE for SA    start_ue_id=3   end_ue_id=3       ul_rate=1    pdu_id=${Pdu_session_ID1}      qfi_id=1
    sleep  5s
    MultiUE Trigger DL Traffic for SA    start_ue_id=${sa_ue_id4}     end_ue_id=${sa_ue_id4}   Traffic_rate=mbps     dl_rate=1
    ...    pdu_id=${Pdu_session_ID1}     trf_id=10   qfi_id=2
    sleep    10s
    Validate DL Traffic For MultiUE for SA    start_ue_id=4  end_ue_id=4     dl_rate=1    pdu_id=${Pdu_session_ID1}       qfi_id=2
    sleep  5s
    MultiUE Trigger UL Traffic for SA    start_ue_id=${sa_ue_id4}    end_ue_id=${sa_ue_id4}   Traffic_rate=mbps      ul_rate=1
    ...    pdu_id=${Pdu_session_ID1}     trf_id=11  qfi_id=2
    sleep    10s
    Validate UL Traffic For MultiUE for SA    start_ue_id=4   end_ue_id=4      ul_rate=1    pdu_id=${Pdu_session_ID1}      qfi_id=2
    sleep  5s
    MultiUE Trigger DL Traffic for SA    start_ue_id=${sa_ue_id4}     end_ue_id=${sa_ue_id4}   Traffic_rate=kbps     dl_rate=1
    ...    pdu_id=${Pdu_session_ID2}     trf_id=12   qfi_id=1
    sleep    10s
    Validate DL Traffic For MultiUE for SA    start_ue_id=4  end_ue_id=4    dl_rate=.001    pdu_id=${Pdu_session_ID2}       qfi_id=1
    sleep  5s
    MultiUE Trigger UL Traffic for SA    start_ue_id=${sa_ue_id4}    end_ue_id=${sa_ue_id4}   Traffic_rate=kbps      ul_rate=1
    ...    pdu_id=${Pdu_session_ID2}     trf_id=13    qfi_id=1
    sleep    10s
    Validate UL Traffic For MultiUE for SA    start_ue_id=4   end_ue_id=4       ul_rate=.001    pdu_id=${Pdu_session_ID2}      qfi_id=1
    sleep  5s
    Stop MultiUE Data Traffic for SA     start_ue_id=${sa_ue_id1}    end_ue_id=${sa_ue_id4}
    MultiUE Deregister should be Successful   start_ue_id=${sa_ue_id1}    end_ue_id=${sa_ue_id4}

