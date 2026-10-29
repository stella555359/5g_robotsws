*** Settings ***
Suite Setup       Common Suite Setup And Setup IPHY Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...               team-DevHZ5_SG1    owner-carol.an   release-SBTS23R1
Resource          ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${GNB1_CONFIG}    tdd_sansa_cmwv/FS/3cells_ecpri
${uplane_6878}    0x5901AB=1
@{PARAMS_IN_SWCONFIG}
...    ${rdPCsiPoolHkfPeriod_min}
...    ${rdHkfMinPCsiResPerSlot}
...    ${rdHkfMinPCsiRepPeriod}
...    ${rdHkfPCsiPoolMaxRCUsFactor}
...    ${uplane_6878}
...    ${rdPCsiPoolHkfRate_millisec}
#...    ${rdEnableTrafficManager}
#...    ${rdEnableUeIdRangeAllocationViaSdl}
#...    ${rdEnableUeMappingRemovalFromCpIf}
...    @{l2psRD}

@{l2psRD}    0x58057b=16842887    0x58057c=278396928    0x58057d=606077441    0x58057e=2

${rdPCsiPoolHkfRate_millisec}    0x5901B2=3000
${rdPCsiPoolHkfPeriod_min}    0x5901A6=2
${rdHkfMinPCsiResPerSlot}    0x5901A7=8
${rdHkfMinPCsiRepPeriod}    0x5901A8=40
${rdHkfPCsiPoolMaxRCUsFactor}    0x5901A9=6
${rdEnableTrafficManager}    0x89001C=0
${rdEnableUeIdRangeAllocationViaSdl}    0x89001D=0
${rdEnableUeMappingRemovalFromCpIf}    0x89001E=1

@{PARAMS_IN_SCF}
...    ${actFdmEnhancedScheduling}
...    @{CB008962}
...    @{5GC002145}

@{CB008962}
...    NRBTS:actNsaSlice=true
...    NRBTS/NRDRB_QCI-98:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-6
...    NRBTS/NRDRB_QCI-98:qciValueList=98
...    NRBTS/NRNWSLICE_NSA-1:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRNWSLICE_NSA-1:operatorSpecificQCIList=98
...    NRBTS/NRNWSLICE_NSA-1:s1Uplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1

${actFdmEnhancedScheduling}    NRBTS-1:actFdmEnhancedScheduling=true

@{5GC002145}
...    NRBTS/TRACKINGAREA-200:fiveGsTac=200
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2 
...    NRPLMN-2:mcc=311
...    NRPLMN-2:mnc=402
...    NRPLMN-2:mncLength=3
...    NRBTS-1:actRanSharing=true

...    NRBTS-1:actNgcFlexSaMode=true
...    delete:NRCELL:trackingAreaDN
...    delete:NRCELL:configuredEpsTac
...    NRCELL/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRCELL/NRPLMNSET_SA-1:nrPlmnDNList=${NRPLMNDNLIST}
...    NRCELL/NRPLMNSET_NSA-1:configuredEpsTac=200
...    NRCELL/NRPLMNSET_NSA-1:nrPlmnDNList=${NRPLMNDNLIST}
...    SNSSAI-2:administrativeState=Unlocked
...    SNSSAI-2:nrPlmnDNList=${NRPLMNDNLIST}
...    SNSSAI-2:sst=1
...    SNSSAI-2:sd=13714342
${NRPLMNDNLIST}    MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
@{Lock_Slice}
...    SNSSAI-1:administrativeState=Locked

*** Test Cases ***
CB008926-SR-A-B5_ET_01_01_E1 reset for SA UE due to the used snssai is Locked in classicalgNB
    [Tags]
    [Documentation]    Trigger X2 Link reset with below:
    ...    1st SA UE1 register to Gnb cell1, and set PDU session with SA slice which configured with snssai1
    ...    2nd SA UE2 register to Gnb cell2 and set PDU session with SA Slice which configured with snssai2
    ...    3rd Lock snssai1
    UE Register To GNB    ue_id=1
    ${sgNB_NGapIDList}    PDU session setup on UE    ue=1    pdu=1    nwslice=1
    UE Register To GNB    ue_id=2    cell_id=2    nwslice=2
    PDU session setup on UE    ue=2    pdu=1    nwslice=2
    Lock Slice1
    Set Test Variable    ${sgNB_NGapIDList}    ${sgNB_NGapIDList}
    Check WireShark Log    ${CURDIR}${/}a2a_CB008926-A_B5_01${/}a2a.ini    wait_string=id-UE-associatedLogicalNG-connectionList
    Release Ues    ue_type=all

*** Keywords ***
PDU session setup on UE
    [Arguments]    ${ue}=1    ${pdu}=1    ${gw}=${None}    ${nwslice}=1    ${cmd_pdu_regexp}=QoS Routing Table
    [Return]    ${sgNB_NGapIDList[0]}
    ${gw}    Evaluate    ${ue}+${pdu}-1
    ${cmd_pdu_param}    Catenate    set_pdu_param ue=${ue} pdu=${pdu} trf_type=internal
    ${cmd_pdu_session}    Catenate    ue_pdu_session_setup ue=${ue} pdu=${pdu} nwslice=${nwslice} gw=${gw}
    Execute Egate Command    ${cmd_pdu_param}
    ${outputID}    Execute Egate Command    ${cmd_pdu_session}    pass_regexp=${cmd_pdu_regexp}
    ${sgNB_NGapIDList}    Get Regexp Matches    ${outputID}    RAN_UE_NGAP_ID=(\\d+)    1
    Execute Egate Command    ue_disp

Lock Slice1
    ${lockSlice1}=    OnlineParamChange    ${Lock_Slice}
    Execute Egate Command    ue_disp

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

Common Suite Setup And Setup IPHY Env
    Common Suite Setup
    Setup Airphone Env    tl_type=${GNB1_CONFIG}
    Execute Egate Command    enb_x2_link_up enb=1 target=2    is up

Modify Cfg
    Update Cfg    enb_param id=1 drb_id_begin=3 endc_capable_qci=98
    Update Cfg    qci_set qci=98 gbr=no priority=9 delay=300
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 amf=1-2 default=off ue=all
    Update Cfg    set_amf_region id=1 tac_list=0,100,200,210,258,788 plmn=311:489,311:402
    ${set_ue2}    catenate    set_ue simulated id=2 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:402:0000:0:0:021645401 mode=nr enb=2 cell=1
    Update Cfg    ${set_ue2}
    ${set_gnb2_cell2}    catenate    set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 tdd_cell=on proxy=10.0.2.80:9999|10.0.2.80:8888
    ...    nr_arfcn=636666:636666 gscn=7880 mandatory_for_activation=off
    Update Cfg    ${set_gnb2_cell2}

UE Register To GNB
    [Arguments]    ${ue_id}    ${cell_id}=1    ${nwslice}=1
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Reg
