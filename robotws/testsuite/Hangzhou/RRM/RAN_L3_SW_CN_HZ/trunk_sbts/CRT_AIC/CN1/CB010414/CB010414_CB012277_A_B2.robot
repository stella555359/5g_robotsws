*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env Aic
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    CRT    shuang.zou    release-5G24R3
...    CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC    SANSA_FS_ECPRI_CMWV_TDD_CPRI_CMWV_FDD    master_vDU    vDUCNF00    
Resource    ../../../../resources_aic/DevHZ5_resource_aic.robot

*** Variables ***
${TL_TYPE_PATH}    tddfdd_sansa_cmwv/FS/1du/4cells_2T2F

@{PARAMS_IN_SCF_CU}    @{HO}    @{inter_freq_inter_gnb}    @{NRHOIF}   @{EVENT}    
...                    @{SRB3}    @{CGI}
@{PARAMS_IN_SCF_DU1}    @{SSB}     @{DU_NRREL}  

@{HO}
...    NRBTS-1:actIntraFreqInterGnbMobilityNSA3x=true
...    NRBTS-1:actInterFreqInterGnbMobilityNSA=true
...    NRBTS-1:actInterFreqIntraGnbMobilityNSA=true
...    NRCELL-1:absThreshSsbRsrpConsolidation=0
...    NRCELL-1:sMeasConfigSsbRsrp=10

@{inter_freq_inter_gnb}
...    NRADJNRCELL-1:cellDepType=SA+NSA
...    NRADJNRCELL-1:cellReservedForOperatorUse=notReserved
...    NRADJNRCELL-1:fiveGsTac=0
...    NRADJNRCELL-1:gNbId=35
...    NRADJNRCELL-1:gNbIdLength=22
...    NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRADJNRCELL-1:lcrId=1
...    NRADJNRCELL-1:nrarfcn=2071591
...    NRADJNRCELL-1:physCellId=384
...    NRADJNRCELL-1:ssbFrequency=2071387
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=35
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-1:isRplCellForPSCell=false
...    NRCELL-1/NRREL-1:lcrId=1
...    NRCELL-1/NRREL-1:removeNotAllowed=true

@{NRHOIF}
...    NRCELL-1/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=none  
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=rsrp  
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0  
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=10
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=30
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA  
...    NRCELL-1/NRHOIF-1:deriveSsbIndexFromCell=true  
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=261  
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=120 KHz  
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1  
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam  
...    NRCELL-1/NRHOIF-1:ssbFrequency=2071387

@{EVENT}
...    NRCELL-1:a1MeashoEnabled=rsrp
...    NRCELL-1:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=34
...    NRCELL-1:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-1:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL-1:a2MeashoEnabled=rsrp
...    NRCELL-1:a2MeasRedirectSsbRsrp:a2HysteresisRedirectSsbRsrp=0
...    NRCELL-1:a2MeasRedirectSsbRsrp:a2TimeToTriggerRedirectSsbRsrp=ms480
...    NRCELL-1:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=34
...    NRCELL-1:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...    NRCELL-1:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL-1:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-1:a3MeasEnabled=none
...    NRCELL-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=75
...    NRCELL-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=85
...    NRCELL-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL-1:absThreshSsbRsrpConsolidation=1
...    NRCELL-1:filterCoeffSsbRsrp=fc4
...    NRCELL-1:sMeasConfigSsbRsrp=1
...    NRCELL-1:actCDrx=true


@{SRB3}
...    NRBTS-1:srb3SupportEnabled=true
...    NRBTS-1:cipherPrefL:nea0=1
...    NRBTS-1:cipherPrefL:nea1_128=3
...    NRBTS-1:cipherPrefL:nea2_128=4
...    NRBTS-1:cipherPrefL:nea3_128=2
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=3
#...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=4
#...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=2
#...    NRBTS-1:integrityProtPrefL:nia3_128=9

@{SSB}
...    NRCELL:cbraPreamblesPerSsb=n60
...    NRCELL:rsrpThresholdSSB=11

@{CGI}
...    NRCELL:actCGIProvInterGnbMobilityNSA=true

@{DU_NRREL}
...    NRCELL/NRREL-1
...    NRCELL:mgta=ms0dot5

${ue_id}    31

${ue_nr_capabilities}    SEPARATOR=
...    ED007000479A4BBF5FFFFEF8005BD409A00CFDBFCB98AD7FFBF900001F53FFFFC000104880000073BF
...    79FFF9FFFF60000FBC00BFFF0000163C03F148200DFFF785FFF5E00F2A6A7000158800000000023007
...    CAA080E0 
${ue_eutra_nr_capabilities}    SEPARATOR=
...    BD1BA083058380713400000018062B000060400C1001830030600E268000010300C160801C4D000006
...    060182C000389A00000C0C03058100713400001018060B0600E26800002030001005D0400000801002
...    E2680074100000289178A028400040201002004AE00200804010080201004020080401008020100402
...    0080401008020100402008040200804010080201000000080401008000000000008040000000000000
...    0008040100802010040200000010080201000000000001008000000000000000100802010040200804
...    0100800000040200804010080000000000000001008000000000000000000002013800404010080101
...    0020200000008080101000000000000808000000000000000080402008020100402008040100802010
...    0402008040100802010040200804010100402004040000001010020200000008080000000000040400
...    0000000002020080400808010100000004040080800000000000404008080000000000040400000000
...    00000000404E0020100402008040000002010040200000010080000000000080400000000000402008
...    0401008000000402008040000002010000000000010080000000000080201004020080401008020100
...    4020080401008020100402008040100802010080201004020000001008020100000008040000002010
...    0000008040000000000040200000000000201380040400808010100202004040000001010020200404
...    0000000000020200000008080101002020040400808000000202004040080800000000000404000000
...    1010020200404008080101000000040400808010100000000000080800000020100402008040100802
...    0100402008040100802010040200804010080201004020080401008020100802E00201002020000000
...    8080101000000000000000010100000000000000000000040200404000000101002020000000000000
...    0002020000000000000000000008040080800000020200404000000000000000040400000000000000
...    0000001008010100000004040080801010000000000008080000002020040400000000000000004040
...    000001013880100300200600400C0080180100300200600400C0080180100300200600400C00801801
...    00300200600400C0080180100300200600400C0080180100300200600400C008018010030020060040
...    0C0080180100300200600400C0080180100300200600400C0080180100300200600400C00801801003
...    00200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0
...    0801801002100008040400801080008020200400800804018010020040100600400C008010


*** Test Cases ***
TC03_CB012277_A_B2_Inter_Frequency_inter_en_gNB_PSCell_change_with_CGI_provisioning_without_ANR_for_NSA_Opt_3x
    [Documentation]
    ...    Verify Cloud NSA TDD cmWave Intra-freq inter-gNB handover  is successful
    [Tags]    QC_32519    QCD_MN_RAN    QCP_RAN_VRF
    X2 Link for simulated gNB-35
    UE attach and traffic
    UE Tigger Inter-gnb HO From RealGNB to SimGNB    phycell_id=384
    Check CGI info Wireshark-log
    [Teardown]     Common Test Teardown And Stop Capture Logs Aic

*** Keywords ***
Modify Cfg Aic
    ${V_1}    catenate
    ...    ue_param id=31 ue_nr_capabilities=${ue_nr_capabilities} dual_conn=eutra_nr
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    ${V_2}    catenate
    ...    set_cell id=1 gnb=3 pci=128:0 tac=3 nrci=0x02 tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=2071591:2071591
    ...    gscn=22446 mandatory_for_activation=off
    ${V_4}    catenate
    ...    set_ue simulated id=31 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    sec_key=0102030405060708090A0B0C0D0EFF00 nea=null+zuc nia=null+zuc imsi=311:489:21645400
    Update Cfg Aic    ${V_1}
    Update Cfg Aic    gnb_set id=3 s1u=10.0.1.138 plmn=311:489 gnb_id=0x23:22 type=simulated daemon=:22222 x2=10.0.1.138:36422
    Update Cfg Aic    ${V_2}
    Update Cfg Aic    gnb_endc_param id=3 use_nr_ran_cont=true scg_dl_dist_percent=0 enable_dud_poll_bit=0
    Update Cfg Aic    ${V_4}

X2 Link for simulated gNB-35
    Execute Egate Command    enb_x2_link_up enb=1 target=3
    ...    pass_regexp=is UP

UE attach and traffic
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=1 bearer=2 type=split_scg    reported successful RA
    Send Throughput
    Verify Throughput

UE tigger Inter-gnb HO From RealGNB to SimGNB
    [Arguments]    ${phycell_id}    ${ue_id}=31
    Execute Egate Command    ue_enb_param id=${ue_id} measurement_gap=gp0:2 gap_trigger=gnb_triggered
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=636576    event_type=A2
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=30 srsrq_nr=30
    ...    pass_regexp=rrcReconfigurationComplete
    Execute Egate Command    ue_enb_param id=${ue_id} measurement_gap=off
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=2071387    event_type=A5
    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A5 srsrp_nr=1 srsrq_nr=1 phycell_id=${phycell_id} nrsrp_nr=60 nrsrq_nr=60
    ...    pass_regexp=Bearer-type change from MCG to SCG-split is successful

Send Throughput
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=ul mbps=5 trf_id=1    UDP UL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=5 trf_id=2    UDP DL

Verify Throughput
    [Arguments]    ${sleep_time}=10s
    sleep    ${sleep_time}
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>4.5
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${dl_throuput}/1000>4.5

Check CGI info Wireshark-log
    #Verify Throughput
    traffic data stop    ue_id=${ue_id}
    check wireshark log aic    ${CURDIR}${/}a2a_12277_B2${/}a2a.ini    wait_string=cgi-Info::1
