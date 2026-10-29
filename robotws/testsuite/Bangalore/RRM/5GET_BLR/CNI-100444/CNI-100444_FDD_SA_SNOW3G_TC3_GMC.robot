*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO     RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_SC_FDD    5G_RAN
...    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE   SBTS00     CONFIGURED     PY39

Documentation
...
...             author:           Sruthi
...             maintainer:       sruthi.jacob@nokia.com
...
...             INTRODUCTION:     This user scenario checks the updation of INTEGRITY_VERIF_FAIL_DRB_SA counter,
...                               when the number of consecutive PDCP PDU discards due to the failure of integrity
...								   verification exceeds rdNumOfConsecutiveDrbIpFailures for a UL DRB in FDD.
...                               -Single UE /PDU/DRB used
...             TEST SET NAME:    CNI-100444
...             TESTING SPLIT:    Refer CNI100444 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CNI-100444  CFAM
...             Requirement ID:   5G_PM_1354

Resource          ./resource/CNI-100444_keywords.robot

Suite Setup         Run keywords     Log to console      "Suite Setup started"
...                 AND     BuiltIn.Log     ${SCFC}
...                 AND     Prepare TL with config files
...                 AND     Suite setup from scratch
...                 AND    Sleep    2min
...                 AND    Setup_Env.Reboot GNB System Module From Console And Check Airscale Is Ready
...                 AND    Start Default Logging Gnb ASIL_ABIO
...                 AND     WTS_Runner_Keywords.Start WTS Using WTS_Runner      ${LUA_CFG}

#Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
#...                 AND     Revert GNB RadParam
#...                 AND     Stop Default Logging Gnb ASIL_ABIO

*** Variables ***
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${sa_ue_id1}      ${51}
${sa_ue_id2}      ${52}
${sa_ue_id3}      ${76}
${sa_ue_id4}      ${77}
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID1}       1
${Pdu_session_ID2}       2
${TRF_ID}     1
${QFI_ID}     1
${TEST_NAME}     TC4

${LUA_CFG}=                ${CURDIR}/config/TC3/TC3_setup_CNI-100444_FDD_GMC.cfg
${SCFC}=                   ${CURDIR}/config/TC3/SCF_GMC.xml
${AP_XML}=                 ${CURDIR}/config/TC3/iphy.xml

*** Test Cases ***
[1]CNI-100444_3_FDD_SA_SNOW 3G_Multi_UE_PDU_DRB_Qos_UL_DRB_robustness_Intergrity_Verification_Failure_Counter_update_for_UP

    log to console     Suite setup done
    Run Keyword And Continue On Failure       Link SCOUT SCF to Configuration ID for Reporting
    Enable Max integrity dat rate    msg=pdu_session_setup     int_prot=required     conf_prot=required
    sleep    5s
    MultiUE Register should be Successful   start_ue_id=${sa_ue_id1}    end_ue_id=${sa_ue_id2}     pdu_id=${Pdu_session_ID1}
    ...     nw_id=${nwslice_ID}
    sleep    5s
    MultiUE Register should be Successful   start_ue_id=${sa_ue_id3}    end_ue_id=${sa_ue_id4}     pdu_id=${Pdu_session_ID1}
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
    Validate DL Traffic For MultiUE for SA    start_ue_id=${sa_ue_id1}    end_ue_id=${sa_ue_id1}     dl_rate=1
    ...     pdu_id=${Pdu_session_ID1}       qfi_id=2
    MultiUE Trigger UL Traffic for SA    start_ue_id=${sa_ue_id1}    end_ue_id=${sa_ue_id1}   Traffic_rate=mbps
    ...     ul_rate=1     pdu_id=${Pdu_session_ID1}     trf_id=3   qfi_id=2
     sleep    10s
    Validate UL Traffic For MultiUE for SA    start_ue_id=${sa_ue_id1}    end_ue_id=${sa_ue_id1}      ul_rate=1    pdu_id=${Pdu_session_ID1}
    ...     qfi_id=2
    sleep  5s
    MultiUE Trigger DL Traffic for SA    start_ue_id=${sa_ue_id2}     end_ue_id=${sa_ue_id2}   Traffic_rate=mbps     dl_rate=1
    ...     pdu_id=${Pdu_session_ID1}     trf_id=4    qfi_id=2
    sleep    10s
    Validate DL Traffic For MultiUE for SA    start_ue_id=${sa_ue_id2}    end_ue_id=${sa_ue_id2}    dl_rate=1    pdu_id=${Pdu_session_ID1}
    ...    qfi_id=2
    sleep    5s
    MultiUE Trigger UL Traffic for SA    start_ue_id=${sa_ue_id2}    end_ue_id=${sa_ue_id2}   Traffic_rate=mbps      ul_rate=1
    ...    pdu_id=${Pdu_session_ID1}     trf_id=5   qfi_id=2
    sleep    10s
    Validate UL Traffic For MultiUE for SA    start_ue_id=${sa_ue_id2}    end_ue_id=${sa_ue_id2}       ul_rate=1    pdu_id=${Pdu_session_ID1}
    ...    qfi_id=2
    sleep  5s
    MultiUE Trigger DL Traffic for SA    start_ue_id=${sa_ue_id2}     end_ue_id=${sa_ue_id2}   Traffic_rate=kbps     dl_rate=1
    ...    pdu_id=${Pdu_session_ID2}     trf_id=6    qfi_id=1
    sleep    10s
    Validate DL Traffic For MultiUE for SA    start_ue_id=${sa_ue_id2}    end_ue_id=${sa_ue_id2}    dl_rate=.001    pdu_id=${Pdu_session_ID2}
    ...    qfi_id=1
    sleep  5s
    MultiUE Trigger UL Traffic for SA    start_ue_id=${sa_ue_id2}    end_ue_id=${sa_ue_id2}   Traffic_rate=kbps      ul_rate=1
    ...    pdu_id=${Pdu_session_ID2}     trf_id=7   qfi_id=1
    sleep  10s
    Validate UL Traffic For MultiUE for SA    start_ue_id=${sa_ue_id2}   end_ue_id=${sa_ue_id2}       ul_rate=.001    pdu_id=${Pdu_session_ID2}
    ...     qfi_id=1
    sleep  5s
    MultiUE Trigger DL Traffic for SA    start_ue_id=${sa_ue_id3}     end_ue_id=${sa_ue_id3}   Traffic_rate=mbps     dl_rate=1
    ...    pdu_id=${Pdu_session_ID1}     trf_id=8    qfi_id=1
    sleep    10s
    Validate DL Traffic For MultiUE for SA    start_ue_id=${sa_ue_id3}    end_ue_id=${sa_ue_id3}     dl_rate=1    pdu_id=${Pdu_session_ID1}
    ...    qfi_id=1
    sleep  5s
    MultiUE Trigger UL Traffic for SA    start_ue_id=${sa_ue_id3}    end_ue_id=${sa_ue_id3}   Traffic_rate=mbps      ul_rate=1
    ...    pdu_id=${Pdu_session_ID1}     trf_id=9    qfi_id=1
    sleep    10s
    Validate UL Traffic For MultiUE for SA    start_ue_id=${sa_ue_id3}   end_ue_id=${sa_ue_id3}       ul_rate=1    pdu_id=${Pdu_session_ID1}
    ...    qfi_id=1
    sleep  5s
    MultiUE Trigger DL Traffic for SA    start_ue_id=${sa_ue_id4}     end_ue_id=${sa_ue_id4}   Traffic_rate=mbps     dl_rate=1
    ...    pdu_id=${Pdu_session_ID1}     trf_id=10   qfi_id=2
    sleep    10s
    Validate DL Traffic For MultiUE for SA    start_ue_id=${sa_ue_id4}    end_ue_id=${sa_ue_id4}     dl_rate=1    pdu_id=${Pdu_session_ID1}
    ...    qfi_id=2
    sleep  5s
    MultiUE Trigger UL Traffic for SA    start_ue_id=${sa_ue_id4}    end_ue_id=${sa_ue_id4}   Traffic_rate=mbps      ul_rate=1
    ...    pdu_id=${Pdu_session_ID1}     trf_id=11  qfi_id=2
    sleep    10s
    Validate UL Traffic For MultiUE for SA    start_ue_id=${sa_ue_id4}    end_ue_id=${sa_ue_id4}      ul_rate=1    pdu_id=${Pdu_session_ID1}
    ...    qfi_id=2
    sleep  5s
    MultiUE Trigger DL Traffic for SA    start_ue_id=${sa_ue_id4}     end_ue_id=${sa_ue_id4}   Traffic_rate=kbps     dl_rate=1
    ...    pdu_id=${Pdu_session_ID2}     trf_id=12   qfi_id=1
    sleep    10s
    Validate DL Traffic For MultiUE for SA    start_ue_id=${sa_ue_id4}    end_ue_id=${sa_ue_id4}    dl_rate=.001    pdu_id=${Pdu_session_ID2}
    ...    qfi_id=1
    sleep  5s
    MultiUE Trigger UL Traffic for SA    start_ue_id=${sa_ue_id4}    end_ue_id=${sa_ue_id4}   Traffic_rate=kbps      ul_rate=1
    ...    pdu_id=${Pdu_session_ID2}     trf_id=13    qfi_id=1
    sleep    10s
    Validate UL Traffic For MultiUE for SA    start_ue_id=${sa_ue_id4}    end_ue_id=${sa_ue_id4}      ul_rate=.001    pdu_id=${Pdu_session_ID2}
    ...    qfi_id=1
    sleep  5s
    Trigger MAC-I corruption    ue_id=${sa_ue_id2}    integrityProt_macI_corruption_string=1000:1000:1000
    sleep  2s
    Trigger MAC-I corruption    ue_id=${sa_ue_id3}    integrityProt_macI_corruption_string=1000:1000:1000
    sleep  2s
    #INTEGRITY_VERIF_FAIL_DRB_SA
    Verify CNI-100444 PM Counter     feature_id=CNI-100444     counter_id=M55350C00031
    Stop MultiUE Data Traffic for SA     start_ue_id=${sa_ue_id1}    end_ue_id=${sa_ue_id2}
    Stop MultiUE Data Traffic for SA     start_ue_id=${sa_ue_id3}    end_ue_id=${sa_ue_id4}
    MultiUE Deregister should be Successful   start_ue_id=${sa_ue_id1}    end_ue_id=${sa_ue_id2}
    MultiUE Deregister should be Successful   start_ue_id=${sa_ue_id3}    end_ue_id=${sa_ue_id4}

