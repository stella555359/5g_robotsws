*** Settings ***
Documentation    Suite description
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-Beam    owner-chunlan.yang
...    CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD    CRT    CB008246    release-SBTS23R3
...    STATE_CONFIGURED
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    NRBTS:actFullPlmnList=true
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    @{8246_related_modification}
...    @{8246_G_related_modification}

@{8246_related_modification}
...    NRCELL-1:cellDepType=SA
...    delete:NRCELL-1:configuredEpsTac
...    NRCELL-1:actLAForHiReliab=true
...    NRBTS-1/BWP_PROFILE-3/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS-1/BWP_PROFILE-4/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRCELL-1:actCceSplit=false
...    NRCELL-1:pdschHrLaConfig:dllaCqiOffsetHR=0
...    NRCELL-1:pdschHrLaConfig:dllaDeltaCqiMaxHR=150
...    NRCELL-1:pdschHrLaConfig:dllaDeltaCqiMinHR=-150
...    NRCELL-1:pdschHrLaConfig:dllaDeltaCqiStepdownHR=20
...    NRCELL-1:pdschHrLaConfig:dllaIniDeltaCqiHR=-50
...    NRCELL-1:pdschHrLaConfig:dllaIniMcsHR=3
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutageMcsThresh64qam=3
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutageMcsThresh64qamLowSE=2
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutagePercentage=50
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutagePeriod=20
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerRecoverMcsThresh64qam=5
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerRecoverMcsThresh64qamLowSE=5
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerRecoverPercentage=60
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerRecoverPeriod=20
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutageMcsThresh64qamLowSE=2
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutagePercentage=50
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutagePeriod=20
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerRecoverMcsThresh64qam=5
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerRecoverMcsThresh64qamLowSE=5
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerRecoverPercentage=60
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerRecoverPeriod=20
...    NRBTS-1/NRDRB-11:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-1
...    NRBTS-1/NRDRB-12:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-2
...    NRBTS/NRDU-1:carrierAggregationSupportList=none
...    NRBTS-1/NRPDSCHHRLA-1:dllaBlerTargetHR=10
...    NRBTS-1/NRPDSCHHRLA-2:dllaBlerTargetHR=10
...    NRBTS-1/BWP_PROFILE-3/PDCCH-1:alSelection=static
...    NRBTS-1/BWP_PROFILE-4/PDCCH-1:alSelection=static

@{8246_G_related_modification}
...    NRBTS/NRPDSCHHRLA-1:dllaBlerTargetHR=1
...    NRBTS/NRPDSCHHRLA-1:scalFactorForHRGbrDl=110
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutageMcsThresh64qam=3
...    NRBTS/NRPDSCHHRLA-2:dllaBlerTargetHR=3
...    NRBTS/NRPDSCHHRLA-2:scalFactorForHRGbrDl=130
...    NRBTS/NRPMRNL-1:miNrUlHarqOne=5min
...    NRCELL-1:pdschHrLaConfig:dllaMcsMax64qamLowSERANK1HR=25
...    NRCELL-1:pdschHrLaConfig:dllaMcsMax64qamLowSERANK2HR=25
...    NRCELL-1:pdschHrLaConfig:dllaMcsMax64qamLowSERANK3HR=20
...    NRCELL-1:pdschHrLaConfig:dllaMcsMax64qamLowSERANK4HR=20
...    NRCELL-1:pdschHrLaConfig:dllaMcsMax64qamRANK1HR=25
...    NRCELL-1:pdschHrLaConfig:dllaMcsMax64qamRANK2HR=25
...    NRCELL-1:pdschHrLaConfig:dllaMcsMax64qamRANK3HR=20
...    NRCELL-1:pdschHrLaConfig:dllaMcsMax64qamRANK4HR=20

${UE_Capa_Support_HRLA}    SEPARATOR=
...    E9A09000575F5A13160003C1A00B0498B800CE1E82813641873E618F28581C130080C4700FB8D85181AC1184341020E90186D6C98AB1A1CF
...    88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE0005800702A0D883AC1184341020F1018656C98AB121CFB027C471
...    E31238F21CFA8E7CC31E50B0381C3C27F6000001FD8000000B000E0551B137582308682041D2030C2D931544439F11C788E3D033EC09F18E
...    7CC31E50B0381C3C17003FF001C00FFC000B000E0541B11B582308682041E2030CAD931562439F11C7B027C62471E439F51CF9863CA16070
...    38784FFF800003FFE0000016001C00F78789A001C4100000216020541E14000711800000858158788C001C41000006160561E14000710400
...    000858158789A001C46000002160562E2300071040038820000142C0AC3C28000E268000060B02B17134003882001C28000008160562E268
...    00711800388C0000082C0AC5C28000E20800711800001058158B850001C41000E208000020B02B17134003882001C46000004160562E1400
...    0711800388C0000082C0AC5C4D000E2300070A000002058158788C001C46000006160401C0468051013602083A5D83E14489B1CF870A244D
...    8E7C3851226C73E1C28913639F0E14489B1CF871224489B1CF870A040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E
...    7C08902040D8E7C08902040D8E7C08902040D8E7C0850206C73E000B878C6318C6318C6318C630F413003C00281C1401C0C01D00E000C048
...    0080C07C120040000000200000401000000008000010040000100200000C0100000800800005004002008020080000600400003802001000
...    0000400004002000024010000060080000A004000058020010240900400006019CA9ACA9AC14AC0CAC19AC15ACA5AC99AC05AC0DAC04AC08
...    AC1DA0682000012CA4A080000CB29282000052CA48080001CB29202000092CA48080002CB292020000D2CA48080003CB29202000112CA480
...    80004CB29202000152CA48080005CB29282000192CA480800018B292019A55574AAAA9545D2A8AA0B154162A83455298AA4D154062A81455
...    26AAA0F1414178095028140A05028140A05028140A05028140A0502814001820201803008010021010020080403006100801002020180300
...    80600C10100C018040300610080100202018030080100220100C01804030060100C01820200401008010043543E00020406080C0E1416181
...    A2022242628303236383A3E424A4C4E5052545A5E828305A

*** Test Cases ***
CB008246_G_008_FR1_SA_TDD_Scheduling_5G_UE_with_multiple_nonGBR_HR_DRBs_in_DL_via_ICS_Not_Support_64QAM_MCS_TableAlt
    [Documentation]
    ...    1.Description
    ...    This user scenario validates the gNB behaviour for the setup and release of one or more non-GBR High
    ...    Reliability DRBs and data transmission in DL.
    ...    2.Configuration
    ...      a.SA,TDD.
    ...      b.Configured Link Adaptation High Reliability feature: NRBTS/NRCELL.actLAForHiReliab=true.
    ...      c.Default drb 5QI_6 & 5QI_7 is associated with NRPDSCHHRLA profile.
    ...      d.UE not support Dl-64QAM-MCS-TableAlt.
    ...    3.Test Steps
    ...      a.UE attach to target cell via ICS,5QI6&7 are setup via ICS.
    ...      b.UE detach.
    ...    4.Check Points
    ...      a.Check INITIAL CONTEXT SETUP REQUEST message,two non-GBR QoS Flow (5QI6 & 5QI7) with one PDU session.
    ...      b.Check UE CONTEXT SETUP REQUEST message to establish SRB2 and DRB(s) in the gNB-DU.
    ...      c.Check PsUser_BearerSetupReq message,gNB-DU-CPRT configures drbAddReqPs->HrLaProfile->pdschHrConfig for 5QI6 and 5QI7.
    ...      d.Check PsUser_UserModifyReq message, gNB-DU-CPRT configures cellConfigurationForModification->pdschConfig->msctable as "QAM64".
    ...      e.Check RRC RECONFIGURATION message,mcs-Table parameter of PDSCH-Config should not be present.
    [Tags]    QC_301728    owner-chunlan.yang
    Update UE capa    ue_id=81    SA_Capa_perUE_Full=${UE_Capa_Support_HRLA}
    UE Attach To Target Cell via ICS    ue_id=81    cell_id=1
    Send And Verify Throuput    ue_id=81    qfi=2    send_dl=40    send_ul=10    sleep_time=10s    pdu=1
    Send And Verify Throuput    ue_id=81    qfi=1    send_dl=40    send_ul=10    sleep_time=10s    pdu=1
    Smf Param Reset After case finished
    UE Deregister From gNB    ue_id=81
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008246_G_08${/}a2a.ini    wait_string=UEContextReleaseComplete::4

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F

Modify Cfg
    Delete Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=1 5qi=1
    Update Cfg    set_qosflow id=2 5qi=2 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=3 5qi=3 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=4 5qi=4 gfbr_ul=4000 gfbr_dl=10000 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=5 5qi=5
    Update Cfg    set_qosflow id=6 5qi=6 default=on
    Update Cfg    set_qosflow id=7 5qi=7
    Update Cfg    set_qosflow id=8 5qi=8

Update UE capa
    [Arguments]    ${ue_id}    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

UE Attach To Target Cell via ICS
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    qosflow_modify default=on qos_flow=6 priority=1
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=7
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    QoS Routing Table

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Send And Verify Throuput
    [Arguments]    ${ue_id}    ${qfi}    ${send_dl}    ${send_ul}    ${sleep_time}    ${pdu}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=dl mbps=${send_dl}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=ul mbps=${send_ul}
    Verify Throuput    ${ue_id}    ${qfi}    ${send_dl}*0.9    ${send_ul}*0.9    ${sleep_time}    ${pdu}

Verify Throuput
    [Arguments]    ${ue_id}    ${qfi}    ${Tput_dl}    ${Tput_ul}    ${sleep_time}    ${pdu}
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Smf Param Reset After case finished
    Execute Egate Command    smf_param id=1 reset
