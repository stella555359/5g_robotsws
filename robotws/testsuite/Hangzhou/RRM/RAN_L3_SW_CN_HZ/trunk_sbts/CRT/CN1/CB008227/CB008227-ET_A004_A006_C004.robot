*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G    RAN_5G_TDD    SBTS00    CRT    CLOUD_5G_I_MP_AP_LO
...           owner-liupei.fang    team-CN1ET    release-SBTS24R3
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}    ${True}
${RECREATE_WIRESHARK_FLAG}    ${False}

@{PARAMS_IN_SCF}
...    @{5GC000732_Base}
...    @{IntragNB_IntraDU_HO_Config}
...    @{CB008227_parameters}
...    NRBTS-1:actMultiDrbNSA=true

@{IntragNB_IntraDU_HO_Config}
...    NRBTS-1:actIntraFreqHoSA=true
...    NRBTS-1/NRPMRNL-1:miNrRelReportCu=5min
...    NRBTS/NRCELL:a3MeasEnabled=rsrp


@{5GC000732_Base}
...    NRBTS-1:rrcReestabTypeSA=sameGNB


@{CB008227_parameters}
...    NRBTS-1/NRDRB-14:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS-1/NRDRB-6:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS-1/NRDRB-2:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS-1/NRDRB-7:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS-1/NRDRB-4:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS-1/NRDRB-3:nsaDrbParam:nsa3xBearerAllowed=true
...    NRCELL:congDetectPeriod=ms100
...    NRBTS-1:actNonGbrServiceDiff=true
...    NRCELL-1:actNbrForNonGbrBearers=true
...    NRCELL-1:congWeightAlg=arpPrioPerVul
...    NRCELL-1:maxNbrTrafficLimit=80
...    NRCELL-1:maxPrbsPerNbrUe=30
...    NRCELL-1:nbrPdcchCongHandlingDl=true
...    NRCELL-1:nbrPdcchCongHandlingUl=true
...    NRCELL-1:nbrPdschCongHandling=true
...    NRCELL-1:nbrPuschCongHandling=true
...    NRCELL-2:actNbrForNonGbrBearers=true
...    NRCELL-2:congWeightAlg=arpPrioPerVul
...    NRCELL-2:maxNbrTrafficLimit=80
...    NRCELL-2:maxPrbsPerNbrUe=30
...    NRCELL-2:nbrPdcchCongHandlingDl=true
...    NRCELL-2:nbrPdcchCongHandlingUl=true
...    NRCELL-2:nbrPdschCongHandling=true
...    NRCELL-2:nbrPuschCongHandling=true
...    NRBTS-1/NRDRB_5QI-80:fiveqiValueList=80
...    NRBTS-1/NRDRB_5QI-80:nrDrbDN=MRBTS-2/NRBTS-1/NRDRB-14
...    NRBTS-1/NRDRB_MAC-1:nbrDl=10
...    NRBTS-1/NRDRB_MAC-1:nbrUl=10
...    NRBTS-1/NRDRB_MAC-1:schedulBSD=50ms
...    NRCELL:maxNumOfNbrBearers=30
...    NRBTS/NRDRB-13:nrDrbMacDN=MRBTS-2/NRBTS-1/NRDRB_MAC-1
...    NRBTS/NRDRB-13:priorityLevel=80
...    NRBTS/NRDRB-14:priorityLevel=68
...    NRBTS/NRDRB-14:nrDrbMacDN=MRBTS-2/NRBTS-1/NRDRB_MAC-2
...    NRBTS/NRDRB-3:nrDrbMacDN=MRBTS-2/NRBTS-1/NRDRB_MAC-2



@{Online_Param_NSA}
...    NRBTS-1:actRanSharing=true
...    delete:NRCELL:configuredEpsTac
...    delete:NRCELL:trackingAreaDN
...    NRCELL/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-2/NRBTS-1/TRACKINGAREA-200
...    NRCELL/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-2/NRBTS-1/NRPLMN-1
...    NRCELL/NRPLMNSET_NSA-1:configuredEpsTac=200
...    NRCELL/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-2/NRBTS-1/NRPLMN-1

@{maxNumOfNbrBearers_to1}
...    NRBTS-1/NRCELL-1:maxNumOfNbrBearers=1

@{maxNumOfNbrBearers_to0}
...    NRBTS-1/NRCELL-1:maxNumOfNbrBearers=0

@{pm_counter_Check_A004}
...    NRCELL-1:${SA_DU_DRB_NBR_DL}>1
...    NRCELL-1:${SA_DU_DRB_NBR_UL}>1
...    NRCELL-1:${SA_DRB_NBR_DENOM}>1
...    NRCELL-1:${SA_DU_DRB_NBR_REQ}=4
...    NRCELL-1:${SA_DU_DRB_NBR_ADMIT_WITH_NBR}=4
...    NRCELL-2:${SA_DU_DRB_NBR_DL}>1
...    NRCELL-2:${SA_DU_DRB_NBR_UL}>1
...    NRCELL-2:${SA_DRB_NBR_DENOM}>1
...    NRCELL-2:${SA_DU_DRB_NBR_REQ}=7
...    NRCELL-2:${SA_DU_DRB_NBR_ADMIT_WITH_NBR}=7

@{pm_counter_Check_A006}
...    NRCELL-1:${NSA_DU_DRB_NBR_DL}>1
...    NRCELL-1:${NSA_DU_DRB_NBR_UL}>1
...    NRCELL-1:${NSA_DRB_NBR_DENOM}>1
...    NRCELL-1:${NSA_DU_DRB_NBR_REQ}=2
...    NRCELL-1:${NSA_DU_DRB_NBR_ADMIT_WITH_NBR}=2

@{pm_counter_Check_C004}
...    NRCELL-1:${NSA_DU_DRB_NBR_DL}>1
...    NRCELL-1:${NSA_DU_DRB_NBR_UL}>1
...    NRCELL-1:${NSA_DRB_NBR_DENOM}>1
...    NRCELL-1:${NSA_DU_DRB_NBR_REQ}=2
...    NRCELL-1:${NSA_DU_DRB_NBR_ADMIT_WITH_NBR}=1
...    NRCELL-1:${NSA_DU_DRB_NBR_ADMIT_NOT_NBR}=1
#after CB008227-E-UPD implement NSA_DU_DRB_NBR_ADMIT_WITH_NBR change to 1
#And NSA_DU_DRB_NBR_ADMIT_NOT_NBR will change to 1 

${SA_DU_DRB_NBR_DL}    M55139C03509    #Cumulative number of non-GBR bearers with configured NBR in DL for SA    
${SA_DU_DRB_NBR_UL}    M55139C03510    #Cumulative number of non-GBR bearers with configured NBR in UL for SA
${SA_DRB_NBR_DENOM}    M55139C03511    #Denominator for NBR DRB counters for SA
${SA_DU_DRB_NBR_REQ}    M55139C03506    #Number of non-GBR bearers with configured NBR admission requests for SA
${SA_DU_DRB_NBR_ADMIT_WITH_NBR}    M55139C03507    #Non-GBR bearers with configured NBR successfully admitted with applying NBR during RAC for SA

${NSA_DU_DRB_NBR_DL}    M55115C03509    #Cumulative number of non-GBR bearers with configured NBR in DL for NSA 
${NSA_DU_DRB_NBR_UL}    M55115C03510    #Cumulative number of non-GBR bearers with configured NBR in UL for NSA
${NSA_DRB_NBR_DENOM}    M55115C03511    #Denominator for NBR DRB counters for NSA
${NSA_DU_DRB_NBR_REQ}    M55115C03506    #Number of non-GBR bearers with configured NBR admission requests for NSA
${NSA_DU_DRB_NBR_ADMIT_WITH_NBR}    M55115C03507    #Non-GBR bearers with configured NBR successfully admitted with applying NBR during RAC for NSA
${NSA_DU_DRB_NBR_ADMIT_NOT_NBR}     M55115C03508    #Number of non-GBR bearers with configured NBR admitted without applying NBR during RAC for NSA


*** Test Cases ***
CB008227-ET_A004_Multi_PDU_ADD_modification_Delete_with_NBR_and_RRE_should_be_successfully_after_Intra-GNB_HO_with_target_NBR_in_SA
    [Documentation]
    ...    1. This user scenario describes the gNB behaviour for the successful setup of Non GBR QoS Flow with configured DL/UL Nominal 
    ...       Bit Rate in DRB profile which is triggered by PDU Session Setup procedure. 
    ...    2. Configuration:
    ...       cell id=1 gnb=2 pci=16:2 band:n78 tdd_cell=on chBw=100MHz
    ...       cell id=2 gnb=2 pci=17:0 band:n78 tdd_cell=on chBw=100MHz
    ...       configure 5QI-80:MRBTS-2/NRBTS-1/NRDRB-14: MRBTS-2/NRBTS-1/NRDRB_MAC-2: without NBR configured; Qosflow id=3
    ...       configure 5QI-8:MRBTS-2/NRBTS-1/NRDRB-13: MRBTS-2/NRBTS-1/NRDRB_MAC-1: with NBR configured; Qosflow id=2; default =on
    ...    3. Test Case Steps:
    ...        1.UE register to cell-1 
    ...        2.setup multi PDUs for both PDU1 and PDU2 anc check traffic with both NBR qosflow=2
    ...        3.Add and delete DRB without NBR and check traffic
    ...        4.Trigger Intra handover from cell-1 to cell-2 and check NBR config ,also traffic
    ...        5.Trigger RRE from cell2 to cell-2 and check traffic 
    ...        6.Trigger RRE from cell2 to cell-1 and check traffic  
    ...        7.Add DRB without NBR and check throughput
    ...        8.trigger RRE from cell-1 to cell-2 should working fine
    ...        9.Delete and Add DRB with NBR and check throughput
    ...        10.check counter and wireshark
    ...    4. Expected Results:
    ...        1.UE register to cell-1 succeed
    ...        2.Both PDU1 and PDU2 setup with NBR configruation
    ...        3.Add and delete DRB without NBR should not effect traffic 
    ...        4.Intra Ho should successfully and traffic working fine with NBR 
    ...        5.RRE should working fine from cell-2 to cell-2 and traffic also working fine 
    ...        6.RRE should working fine from cell-2 to cell-1 and traffic also working fine 
    ...        7.Add DRB without NBR and check throughput should be working fine 
    ...        8.RRE should working fine from cell-1 to cell-1 and traffic also working fine
    ...        9.Delete and Add DRB with NBR and check throughput should be fine
    ...        10.check counter and wireshark 
    [Tags]    QC_306052    A004    liufang
    Clear Counter Files    wait=${False}
    Ue Attach to Cell1    ue_id=1    gw_id=1
    Setup multi PDUs with NBR  
    Add and delete DRB without NBR    
    Trigger IntraGNB-HO from cell-1 to cell-2   
    Trigger RRC Reestablish and check throughput    ue_id=1    cell_id=2    pdu=2   
    Trigger RRC Reestablish and check throughput    ue_id=1    cell_id=1    pdu=2    
    Add DRB without NBR and check throughput
    Trigger RRC Reestablish and check throughput with both PDUs QFIs    ue_id=1    cell_id=2    pdu=2   
    Delete and Add DRB with NBR and check throughput    ue_id=1    pdu=2    
    check counters    ${pm_counter_Check_A004}
    Check Wireshark Log    ${CURDIR}${/}a2a_A004${/}a2a.ini    wait_string=UEContextModificationResponse::50
    
CB008227-ET_A006_NBR_in_Pscell_should_be_configured_during_DRB_addtion_and_sgNB_addtion_and_modification_with_NBR_for_NSA
    [Documentation]
    ...    1. This user scenario describes the gNB behaviour for the successful setup of Non GBR QoS Flow with configured DL/UL Nominal 
    ...       Bit Rate in DRB profile which is triggered by PDU Session Setup procedure. 
    ...    2. Configuration:
    ...       cell id=1 gnb=2 pci=16:2 band:n78 tdd_cell=on chBw=100MHz
    ...       cell id=2 gnb=2 pci=17:0 band:n78 tdd_cell=on chBw=100MHz
    ...       configure bearid=2,QCI-9:MRBTS-2/NRBTS-1/NRDRB-6: MRBTS-2/NRBTS-1/NRDRB_MAC-1: with NBR configured; default=on
    ...       configure bearid=4,QCI-7:MRBTS-2/NRBTS-1/NRDRB-4: MRBTS-2/NRBTS-1/NRDRB_MAC-1: with NBR configured;
    ...       configure bearid=3,QCI-6:MRBTS-2/NRBTS-1/NRDRB-3:MRBTS-2/NRBTS-1/NRDRB_MAC-2: without NBR configured;
    ...    3. Test Case Steps:
    ...        1.UE register to cell-1 
    ...        2.Add two bearers: one is bear 3(without NBR) and another is bear 4(with NBR)
    ...        3.start and check traffic should be fine on both DRB
    ...        4.Delete DRB with NBR(bearid 4) and check throughput
    ...        5.check counter and wireshark
    ...    4. Expected Results:
    ...        1.UE register to cell-1 succeed
    ...        2.Add two bearers: one is bear 3(without NBR) and another is bear 4(with NBR) 
    ...          should be successfully and message should be configured with bearid 3 without NBR 
    ...          and bearid 4 should be configured with NBR configuraiton
    ...        3.start and check traffic is always fine on bear 3 and bear 4
    ...        4.release bearid 4(with NBR configuration) should be successfully and traffic still fine 
    ...        10.check counter and wiresahrk all correct 
    [Tags]    QC_324791    A006    liufang
    Clear Counter Files    wait=${True}
    OnlineParamChange    ${Online_Param_NSA}
    NSA UE Attach To Target Cell   
    NSA UE Add More NBR bear and without NBR bear
    Trigger DRB delete NSA    ue_id=31    bearer_id=4
    check counters    ${pm_counter_Check_A006}
    Check Wireshark Log    ${CURDIR}${/}a2a_A006${/}a2a.ini    wait_string=UEContextModificationResponse::12    


CB008227-ET_C004_NBR_DRB_Should_admit_as_normal_Non-GBR-DRB_as_NBR_bearers_Exceed_Cells_NBR_max_amount_Limitationin_with_NBR_Call
    [Documentation]
    ...    1. This user scenario describes the gNB behaviour for normal Non-GBR-DRB as NBR bearers Exceed Cell's NBR max amount
    ...       Limitationin with NBR Call with sgNB addition. 
    ...       NBR_DRB_Should_be_admit_as_normal_Non-GBR-DRB_as_NBR_bearers_Exceed_Cells_NBR_max_amount_Limitationin_with_NBR_Call
    ...       with_sgNB_addition_NSA
    ...    2. Configuration:
    ...       cell id=1 gnb=2 pci=16:2 band:n78 tdd_cell=on chBw=100MHz
    ...       cell id=2 gnb=2 pci=17:0 band:n78 tdd_cell=on chBw=100MHz
    ...       configure bearid=2,QCI-9:MRBTS-2/NRBTS-1/NRDRB-6: MRBTS-2/NRBTS-1/NRDRB_MAC-1: with NBR configured; default=on
    ...       configure bearid=4,QCI-7:MRBTS-2/NRBTS-1/NRDRB-4: MRBTS-2/NRBTS-1/NRDRB_MAC-1: with NBR configured;
    ...       configure bearid=3,QCI-6:MRBTS-2/NRBTS-1/NRDRB-3:MRBTS-2/NRBTS-1/NRDRB_MAC-2: without NBR configured;
    ...    3. Test Case Steps:
    ...        precondition: maxNumOfNbrBearers set to 1
    ...        1.UE register to cell-1,default bearer 2 is setup
    ...        2.Add new bearers(without NBR) bearer 3
    ...        3.check traffic should be fine on both bearer 2 and bearer 3
    ...        4.online modify parameter: maxNumOfNbrBearers to 0
    ...        5.Add bearer 4(with NBR) 
    ...        6.check traffic should be fine on both bearer 2 and bearer 3 and bearer 4
    ...        7.check counter and wireshark
    ...    4. Expected Results:
    ...        1.UE register to cell-1 succeed
    ...        2.Add two bearers: one is bear 3(without NBR) and another is bear 4(with NBR) 
    ...          should be successfully and message should be configured with bearer 3 without NBR 
    ...          and bearid 4 should be configured with NBR configuraiton
    ...        3.check traffic is always fine on bear 2 and bear 3
    ...        4.online modify should be successfully 
    ...        5.add bearer 4 should be working (with NBR configruation)
    ...        6.check traffic should be fine on both bearer 2 and bearer 3 and bearer 4
    ...        7. check counter and wiresahrk all correct 
    [Tags]    QC_323232    C004    liufang    NSA
    Clear Counter Files    wait=${True}
    OnlineParamChange    ${maxNumOfNbrBearers_to1}
    NSA UE Attach To Target Cell   
    Add new bearer 3 with check traffic     ue_id=31    bearer_id=3 
    OnlineParamChange    ${maxNumOfNbrBearers_to0}
    Add new bearer 4 with check traffic     ue_id=31    bearer_id=4
    check counters    ${pm_counter_Check_C004}
    Check Wireshark Log    ${CURDIR}${/}a2a_C004${/}a2a.ini    wait_string=UEContextModificationResponse::8



*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Modify Cfg
    [Arguments]    ${ue_id}=31    ${bearer_id3}=3    ${bearer_id4}=4
    Update Cfg    enb_param id=1 drb_id_begin=3 endc_capable_qci=all
    Update Cfg    set_qosflow id=1 5qi=6 default=off
    Update Cfg    set_qosflow id=2 5qi=8 default=on 
    Update Cfg    set_qosflow id=3 5qi=80 
    Update Cfg    set_bearer id=2 ue=${ue_id} qci=9 pdn=1 ip=4.7.254.209 default=on trf_type=internal
    Update Cfg    set_bearer id=3 ue=${ue_id} qci=6 pdn=1 default=off preprovisioned=on filter=3 precedence=3
    Update Cfg    set_bearer id=4 ue=${ue_id} qci=7 pdn=1 default=off preprovisioned=on filter=4 precedence=4
    ${set_ue1}    catenate    set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 
    ...     nr_arfcn=636666:636666 gscn=7880 mandatory_for_activation=off
    Update Cfg    ${set_ue1}
    ${set_ue2}    catenate    set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 
    ...    nr_arfcn=636666:636666 gscn=7880 mandatory_for_activation=off    
    Update Cfg     ${set_ue2}
    ${set_ue3}    catenate    set_cell id=1 bw=10MHz enb=1 eci=0x1234601 pci=3:2 tac=222 proxy=$SERVER_IP:12219|$SERVER_IP:22219 
    ...    earfcn=2000:20000 mapped_earfcn=4200:22200
    Update Cfg     ${set_ue3}
    Update Cfg     sim_param_set TTI=3

Setup PDU Session
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${nwslice}=1    ${gw}=1    ${pass_regexp}=${EMPTY}
    execute egate command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    execute egate command    ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=${nwslice} gw=${gw}    ${pass_regexp}
    
Setup multi PDUs with NBR
   [Arguments]    ${ue_id}=1    ${pdu1}=1    ${pdu2}=2
   Setup PDU Session    ue_id=${ue_id}    pdu=${pdu1}    nwslice=1    gw=1    pass_regexp=Setup QosFlow with QFI:1 fiveQI:8
   Setup PDU Session    ue_id=${ue_id}    pdu=${pdu2}    nwslice=1    gw=2    pass_regexp=Setup QosFlow with QFI:1 fiveQI:8
   Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu1} qfi=1 dir=dl mbps=2 trf_id=1    pass_regexp=Started Downlink
   Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu1} qfi=1 dir=ul mbps=1 trf_id=1    pass_regexp=Started Uplink
   Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu2} qfi=1 dir=dl mbps=2 trf_id=2    pass_regexp=Started Downlink
   Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu2} qfi=1 dir=ul mbps=1 trf_id=2    pass_regexp=Started Uplink
   Verify Throughput for both PDUs and single QFI    ue_id=${ue_id}    Tput_dl=3.6    Tput_ul=1.8  
   
   
Add and delete DRB without NBR
    [Arguments]    ${ue_id}=1    ${pdu}=2    ${qos}=3    ${qfi}=1  
   execute egate command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=${qos} by=amf validation=on    
   ...    pass_regexp=QosFlow with QFI:2 5QI:80
   Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=2 dir=dl mbps=2 trf_id=2    pass_regexp=Started Downlink
   Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=2 dir=ul mbps=1 trf_id=2    pass_regexp=Started Uplink
   Verify Throughput for both PDUs and both QFI    ue_id=1    Tput_dl=5.4    Tput_ul=2.7   
   execute egate command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_del=${qos} by=amf validation=on
   ...    pass_regexp=PduId 2 Removed FiveQi:Qfi mapping fiveQi 80 qfi 2
   Verify Throughput for both PDUs and single QFI    ue_id=1    Tput_dl=3.6    Tput_ul=1.8    qfi=${qfi}
   
   
Add DRB without NBR and check throughput
     [Arguments]    ${ue_id}=1    ${pdu}=2    ${qos2}=2    ${qos3}=3    ${Tput_dl}=5.4    ${Tput_ul}=2.7  
    execute egate command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=${qos3} by=amf validation=on
    ...    pass_regexp=Added QosFlow with QFI:2 fiveQI:80
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=2 dir=dl mbps=2 trf_id=2    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=2 dir=ul mbps=1 trf_id=2    pass_regexp=Started Uplink
    Verify Throughput for both PDUs and both QFI    ue_id=1    Tput_dl=${Tput_dl}    Tput_ul=${Tput_ul}    
   
   
Delete and Add DRB with NBR and check throughput
    [Arguments]    ${ue_id}=1     ${pdu}=2    ${Tput_dl}=3.6    ${Tput_ul}=1.8    ${qfi}=2    ${Tput_dl_all}=5.4    ${Tput_ul_all}=2.7
    execute egate command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_del=2 by=amf validation=on
    ...    pass_regexp=PduId 2 Removed FiveQi:Qfi mapping fiveQi 8 qfi 1
    Verify Throughput for both PDUs and single QFI    ue_id=1    Tput_dl=${Tput_dl}    Tput_ul=${Tput_ul}    qfi=${qfi}
    execute egate command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=2 by=amf validation=on
    ...    pass_regexp=Added QosFlow with QFI:1 fiveQI:8
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=1 dir=dl mbps=2 trf_id=2    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=1 dir=ul mbps=1 trf_id=2    pass_regexp=Started Uplink
    Verify Throughput for both PDUs and both QFI    ue_id=1    Tput_dl=${Tput_dl_all}    Tput_ul=${Tput_ul_all} 
   
   
Trigger IntraGNB-HO from cell-1 to cell-2 
    [Arguments]    ${ue_id}=1    ${carrierfreq}=636576    ${event}=A3
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=${event}
    execute egate command  
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event} srsrp_nr=5 srsrq_nr=5 phycell_id=51 nrsrp_nr=100 nrsrq_nr=100
    ...    pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
    Verify Throughput for both PDUs and single QFI    ue_id=1    Tput_dl=3.6    Tput_ul=1.8    qfi=1 
      

Ue Attach to Cell1
    [Arguments]    ${ue_id}    ${gw_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=1
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registered

  
Verify Throughput for both PDUs and both QFI
    [Arguments]    ${ue_id}=1    ${Tput_dl}=5    ${Tput_ul}=2    ${sleep_time}=10s   
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${dl_throughput2}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=2    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput2}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=2    qfi=1    direction=ul    rate_type=ave
    ${dl_throughput3}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=2    qfi=2    direction=dl    rate_type=ave
    ${ul_throughput3}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=2    qfi=2    direction=ul    rate_type=ave
    Should Be True    (${dl_throughput}+${dl_throughput2}+${dl_throughput3})/1000>${Tput_dl}
    Should Be True    (${ul_throughput}+${ul_throughput2}+${ul_throughput3})/1000>${Tput_ul}
    
Verify Throughput for both PDUs and single QFI  
    [Arguments]    ${ue_id}=1    ${Tput_dl}=5.4    ${Tput_ul}=2.7    ${sleep_time}=10s    ${qfi}=1   
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${dl_throughput2}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=2    qfi=${qfi}    direction=dl    rate_type=ave
    ${ul_throughput2}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=2    qfi=${qfi}    direction=ul    rate_type=ave
    Should Be True    (${dl_throughput}+${dl_throughput2})/1000>${Tput_dl}
    Should Be True    (${ul_throughput}+${ul_throughput2})/1000>${Tput_ul}

Trigger RRC Reestablish and check throughput
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${pdu}=1    ${Tput_dl}=3.6    ${Tput_ul}=1.8    ${qfi}=1    
    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${cell_id} cause=reconfigurationFailure
    ...    pass_regexp=NR RRC Reestablishment sucessfully completed  
    Verify Throughput for both PDUs and single QFI     ue_id=${ue_id}    Tput_dl=${Tput_dl}    Tput_ul=${Tput_ul}    qfi=${qfi}       
    
Trigger RRC Reestablish and check throughput with both PDUs QFIs   
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${pdu}=1    ${Tput_dl}=5.4    ${Tput_ul}=2.7    ${qfi}=1    
    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${cell_id} cause=reconfigurationFailure
    ...    pass_regexp=NR RRC Reestablishment sucessfully completed  
    Verify Throughput for both PDUs and both QFI    ue_id=${ue_id}    Tput_dl=${Tput_dl}    Tput_ul=${Tput_ul}  


NSA UE Attach To Target Cell
    [Arguments]    ${ue_id}=31  
    Set x2 gnb link up
    Update Cfg    sim_debug_log level=0
    Update Cfg    debug_log level=0
    Execute Egate Command     sim_debug_log level=0
    Execute Egate Command    ue_attach id=${ue_id} profile=1    UE IS ACTIVE
    Execute Egate Command
    ...    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=1 bearer=2 type=split_scg
    ...    pass_regexp=reported successful RA
    Send And Verify Nsa Throuput
    Execute Egate Command    bearer_disp ue=${ue_id} at=enb
    
Add new bearID
    [Arguments]    ${ue_id}=31    ${bearer_id}=4   
    Execute Egate Command    enb_ue_dc_modify ue=${ue_id} bearer_to_add=${bearer_id} by=enb cause=RN_CauseRadioNetwork_unspecified type=split_scg
     ...    Successfully reconfigured dual connectivity
    Send And Verify Nsa Throuput    ue_id=${ue_id}    bearer_id=${bearer_id}  
    

NSA UE Add More NBR bear and without NBR bear
    Add new bearID    ue_id=31    bearer_id=3  
    Send And Verify Nsa Throuput       ue_id=31    bearer_id=3  
    Add new bearID    ue_id=31    bearer_id=4  
    Send And Verify Nsa Throuput       ue_id=31    bearer_id=4  
    
Set x2 gnb link up
    Execute Egate Command    enb_x2_link_up enb=1 target=2    ENB-1: X2AP Link with GNB-2


Send And Verify Nsa Throuput
    [Arguments]    ${ue_id}=31    ${bearer_id}=2    ${Tput_dl}=1.8    ${Tput_ul}=0.9    ${sleep_time}=10s
    Execute Egate Command    data_trf_start ue=${ue_id} id=${bearer_id} dir=dl mbps=2    pass_regexp=UE 31: UDP DL TRF
    Execute Egate Command    data_trf_start ue=${ue_id} id=${bearer_id} dir=ul mbps=1    pass_regexp=UE 31: UDP UL TRF 
    Verify Throuput    ${ue_id}    ${bearer_id}    ${Tput_dl}    ${Tput_ul}    ${sleep_time}

Verify Throuput
    [Arguments]    ${ue_id}=31    ${bearer_id}=2    ${Tput_dl}=1.8    ${Tput_ul}=0.9    ${sleep_time}=10
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=${bearer_id}    direction=dl    dc_cell_group=all    rate_type=ave
    ${ul_throughput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=${bearer_id}    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul} 
 
Trigger DRB delete NSA
    [Arguments]    ${ue_id}=31    ${bearer_id}=3
    ${ret1}    execute egate command    enb_ue_dc_modify ue=${ue_id} bearer_to_release=${bearer_id} by=enb cause=RN_mCG_Mobility type=split_scg
    ...    pass_regexp=SgNBReconfigurationComplete
    Verify Throuput    ${ue_id}    bearer_id=2    Tput_dl=1.8    Tput_ul=0.9    sleep_time=10
    Verify Throuput    ${ue_id}    bearer_id=3    Tput_dl=1.8    Tput_ul=0.9    sleep_time=10 
 
OnlineParamChange
    [Arguments]    ${Online_Param_NSA}    
    Delta Commission Parameters    ${Online_Param_NSA}
    Cells Should Be OnAir

Add new bearer 3 with check traffic 
    [Arguments]    ${ue_id}=31    ${bearer_id}=3    ${Tput_dl}=3.6    ${Tput_ul}=1.8    ${sleep_time}=10        
    Add new bearID    ue_id=31     bearer_id=3
    ${dl_throughput1}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=dl    dc_cell_group=all    rate_type=ave
    ${ul_throughput1}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    ${dl_throughput2}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=3    direction=dl    dc_cell_group=all    rate_type=ave
    ${ul_throughput2}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=3    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${dl_throughput1}+${dl_throughput2}/1000>${Tput_dl}
    Should Be True    ${ul_throughput1}+${ul_throughput2}/1000>${Tput_ul} 
    
Add new bearer 4 with check traffic 
    [Arguments]    ${ue_id}=31    ${bearer_id}=3    ${Tput_dl}=5.4    ${Tput_ul}=2.7    ${sleep_time}=10        
    Add new bearID    ue_id=31     bearer_id=4
    ${dl_throughput1}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=dl    dc_cell_group=all    rate_type=ave
    ${ul_throughput1}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    ${dl_throughput2}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=3    direction=dl    dc_cell_group=all    rate_type=ave
    ${ul_throughput2}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=3    direction=ul    dc_cell_group=all    rate_type=ave
    ${dl_throughput3}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=4    direction=dl    dc_cell_group=all    rate_type=ave
    ${ul_throughput3}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=4    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    (${dl_throughput1}+${dl_throughput2}+${dl_throughput3})/1000>${Tput_dl}
    Should Be True    (${ul_throughput1}+${ul_throughput2}+${ul_throughput3})/1000>${Tput_ul} 
    
