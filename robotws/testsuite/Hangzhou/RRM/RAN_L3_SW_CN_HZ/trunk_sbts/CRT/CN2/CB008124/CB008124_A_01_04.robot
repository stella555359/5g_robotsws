*** Settings ***
Documentation    Suite description
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-Beam    owner-chunlan.yang
...    CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    CRT    CB008124    release-SBTS23R2
...    STATE_CONFIGURED
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    @{8124_related_modification}
...    @{5qi80_related_modification}
...    @{CA_related}

@{8124_related_modification}
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL:actUlCgType2=true
...    NRCELL-1:actUlCgType2=false
...    NRBTS/NRDRB-15:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-1
...    NRBTS/NRULCG_PROFILE-1:grantedPacketSize=10
...    NRBTS/NRULCG_PROFILE-1:maxNumPrbs=4
...    NRBTS/NRULCG_PROFILE-1:periodicity=ms2
...    delete:NRBTS-1/NRDRB-15:nrPdschHRLaDN

@{5qi80_related_modification}
...    NRBTS-1/NRDRB-15:discardTimer=infinity
...    NRBTS/NRDRB-15:discardTimerUl=infinity
...    NRBTS-1/NRDRB-15:dscp=40
...    NRBTS-1/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRBTS-1/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS-1/NRDRB-15:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS-1/NRDRB-15:schedulWeight=1
...    NRBTS-1/NRDRB-15:nsaDrbParam:actPrioritizeX2AfterInactivity=true
...    NRBTS/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS-1/NRDRB_5QI-3:fiveqiValueList=80
...    NRBTS-1/NRDRB_5QI-3:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRBTS-1/NRDRB-15:rlcMode=RLC_AM
...    NRBTS-1/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1

@{CA_related}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:caConfigurationSupport=2CCDL_2CCUL
...    NRBTS/NRDU-1:carrierAggregationSupportList=ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:sCellActivationMethod=blind
#for blind
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRCELL-14/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-14/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-14/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-14/NRREL-1:gNbIdLength=22
...    NRCELL-14/NRREL-1:gNbId=1
...    NRCELL-14/NRREL-1:removeNotAllowed=false
...    NRCELL-14/NRREL-1:nrDcAllowed=false
...    NRCELL-14/NRREL-1:lcrId=1
...    NRCELL-14/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-14/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-14/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-14/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-1:cellDepType=SA
...    delete:NRCELL-1:configuredEpsTac
...    NRCELL-14:cellDepType=SA
...    delete:NRCELL-14:configuredEpsTac

@{ca_disable}
...    delete:MRBTS-1/NRBTS-1/NRCELL-14/NRREL-1:sCellAdditionMethod
...    delete:NRCELL-14/NRREL-1:sCellOperationalMode

@{ca_enable}
...    NRCELL-14/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-14/NRREL-1:sCellOperationalMode=dlOnly

${UE_Capa_Support_CG2_1}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6C98AB1A
...    1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A0D883AC1184341020F10480CAD931562439F60
...    4F88E3C62471E439F51CF9863CA1607038784FEC000003FB000000260001C0AA3626EB04610D04083A412030B64C55110E7C471E238F40C
...    FB027C639F30C7942C0E070F05C00FFC007003FF0004C000381506C46D608C21A0810788240656C98AB121CF88E3D813E31238F21CFA8E7
...    CC31E50B0381C3C27FFC00001FFF000001201808400C007BC3C4D000E208000010B0102A0F0A000388C0000042C0AC3C46000E208000030
...    B02B0F0A00038820000042C0AC3C4D000E230000010B02B17118003882001C4100000A160561E14000713400003058158B89A001C41000E
...    140000040B02B1713400388C001C46000004160562E14000710400388C0000082C0AC5C28000E20800710400001058158B89A001C41000E
...    230000020B02B170A000388C001C46000004160562E2680071180038500000102C0AC3C46000E230000030B0200E0234028809B01043D02
...    EC1F0A244D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C3850206C73E044810206C73E044810206C73E04
...    4810206C73E044810206C73E044810206C73E044810206C73E044810206C73E0428103639F0005C3C6318C6318C6318C63187A09801E001
...    40E0A00E0601280380030120020301F04801000000008000010040000000200000401000004008000030040000200200001401000802008
...    020000180100000E008004000000100001000800009004000018020000280100001600800409024010000180672A6B2A6B052B032B066B0
...    56B296B266B016B036B012B022B07681A0800004B29282000032CA4A0800014B29202000072CA480800024B292020000B2CA480800034B2
...    92020000F2CA480800044B29202000132CA480800054B29202000172CA4A0800064B29202000062CA480669555D2AAAA55174AA2A82C550
...    58AA0D154A62A93455018AA051549AAA83C5090178095028140A05028140A05028140A05028140A05028140018202018030080100210100
...    2008040300610080100202018030080600C10100C018040300610080100202018030080100220100C01804030060100C018202004010080
...    10043543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A

${SYSCOM_FLAG}    ${True}

*** Test Cases ***
CB008124_A_01_Success_Configure_CG2_with_ICS_FDD_SANSA
    [Documentation]
    ...    1. Configured UL Grants Type 2 Profile(s): NRULCG_PROFILE-1
    ...    2. 5QI-80 DRB profile is configured and DRB mapped NRULCG_PROFILE-1
    ...    3. Configured UL Grants Type 2 feature is enabled for NRCELL12
    [Tags]    QC_250678    owner-chunlan.yang
    OnlineParamChange    ${ca_disable}
    Update UE capa    ue_id=81    SA_Capa_perUE_Full=${UE_Capa_Support_CG2_1}
    UE Attach To Target Cell in Idle    ue_id=81    cell_id=12
    UE Deregister From gNB    ue_id=81
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008124_A01${/}a2a.ini    wait_string=UEContextReleaseComplete::4

CB008124_A_04_CA_FT_Pcell_CG2_Scell_nCG2_with_ICS_SA
    [Documentation]
    ...    1. FR1 SA CA is enabled for FDD PCells and TDD SCells.
    ...    2. NECELL1 is configured as SCell of NRCELL14 via NRREL object with scellAdditionMethod set to "blind"
    ...    3. Pcell is Configured UL Grants Type 2 and Scell is not Configured UL Grants Type 2
    ...    4. 5QI-80 DRB profile is configured and DRB mapped to NRULCG_PROFILE-1
    ...    5. Initial Context Setup with PDU session
    [Tags]    QC_252757    owner-chunlan.yang
    OnlineParamChange    ${ca_enable}
    Update UE capa    ue_id=81    SA_Capa_perUE_Full=${UE_Capa_Support_CG2_1}
    UE Attach To Target Cell    ue_id=81    cell_id=14
    UE Deregister From gNB    ue_id=81
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008124_A04${/}a2a.ini    wait_string=UEContextReleaseComplete::4

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/L1B/6cells_2T4F_2N41_2N71_2N66

Modify Cfg
    Delete Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=1 5qi=1
    Update Cfg    set_qosflow id=2 5qi=2 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=3 5qi=3 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=4 5qi=4 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=5 5qi=5
    Update Cfg    set_qosflow id=6 5qi=6
    Update Cfg    set_qosflow id=7 5qi=7
    Update Cfg    set_qosflow id=8 5qi=80 default=on

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${False}

Update UE capa
    [Arguments]    ${ue_id}    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

UE Attach To Target Cell
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    qosflow_modify default=on qos_flow=8 priority=1
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    QoS Routing Table

UE Attach To Target Cell in Idle
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    amf_param empty_pdu_session_list=on id=1
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    QoS Routing Table
    Execute Egate Command    ue_ng_ctx_release id=${ue_id} by=amf cause=RN_successful_handover    UE Context Release Complete
    Execute Egate Command    ue_im_exit id=${ue_id} by=ue    Initial Context Setup Successful
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s
