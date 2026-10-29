*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CLOUD_5G_I_BOO_AP_LOO
...    team-SG1    owner-xiujuan.sun    release-SBTS23R1
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${GNB1_CONFIG}    fdd_sansa_cmwv/2cells

@{FAULTS_EXCLUDED_CHECKING}    6450

${cuUeIdToLinkMappingUpdateDelay500ms}    NRBTS:cuUeIdToLinkMappingUpdateDelay=500ms

@{PARAMS_IN_SCF}    ${cuUeIdToLinkMappingUpdateDelay500ms}

${SA_Capa_perUE_Full}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6C98AB1A1
...    CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A0D883AC1184341020F10480CAD931562439F604F
...    88E3C62471E439F51CF9863CA1607038784FEC000003FB000000260001C0AA36266B04610D04083A412030B64C55110E7C471E238F40CFB0
...    27C639F30C7942C0E070F05C007FC007001FF0004C000381506C46D608C21A0810788240656C98AB121CF88E3D813E31238F21CFA8E7CC31
...    E50B0381C3C27FFC00001FFF00000130000E007BC3C28000E230000010B0102A0F0A000388C0000042C0AC3C46000E208000030B02B0F0A0
...    0038820000042C0AC3C4C000E230000010B02B17118003882001C4100000A160561E26000713000003058158B898001C41000E140000040B
...    02B1713000388C001C46000004160562E14000710400388C0000082C0AC5C28000E20800710400001058158B898001C41000E230000020B0
...    2B170A000388C001C46000004160562E2600071180038500000102C0AC3C46000E230000030B0200E0234028809B01043D0AEC1F0A244D8E
...    7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C3850206C73E044810206C73E044810206C73E044810206C73E04
...    4810206C73E044810206C73E044810206C73E044810206C73E0428103639F0005C3C6318C6318C6318C631800C07A09801E00140E0A00E06
...    01280380030120020301F0480100000000800001004000000020000040100000400800003004000020020000140100080200802000018010
...    0000E00800400000010000100080000900400001802000028010000160080040902401000018063266B2A6B052B032B066B056B296B266B0
...    16B036B012B022B07681A0800004B29282000032CA4A0800014B29202000072CA480800024B292020000B2CA480800034B292020000F2CA4
...    80800044B29202000132CA480800054B29202000172CA4A0800064B29202000062CA480629355526AAA55174AA2A82C55058AA0D154A62A9
...    3455018AA051549AAA83C5090178095028140A05028140A05028140A05028140A05028140018202018030080100210100200804030061008
...    0100202018030080600C10100C018040300610080100202018030080100220100C01804030060100C01820200401008010043543E0002040
...    6080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A

*** Test Cases ***
CB008926-SR-A-B2_ET_01_15_ABIO locking trigger partial reset in Classical gNB
    [Tags]
    UE1 UE2 UE31 attach to cell1
    UE3 UE4 UE32 attach to cell2
    Lock ABIO1
    sleep    2s    checking all SA on NRCELL-1 shall be released, and NSA ENDC will be released too
    Unlock ABIO1
    Check WireShark Log    a2a_ini_file=${CURDIR}${/}A2A_A-B2-15${/}a2a.ini    wait_string=procedureCode: id-Reset::4

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=${GNB1_CONFIG}

Modify Cfg
    Update Cfg    ue_param id=1-4 ue_nr_capabilities=${SA_Capa_perUE_Full}


UE1 UE2 UE31 attach to cell1
    [Return]    ${sa1_ueID}    ${sa2_ueID}    ${nsa_enb_x2apId}    ${nsa_gnb_x2apid}
    ${sa1_ueID}    Register For Normal Call and create PDU Successfully    ue_id=1    cell_id=1
    ${sa2_ueID}    Register For Normal Call and create PDU Successfully    ue_id=2    cell_id=1
    ${nsa_enb_x2apId}    ${nsa_gnb_x2apid}    NSA UE ICS and setup ENDC to TargetGnbCell    ue_id=31    target_gnbCell=1
    Set Test Variable    \${sa1_ueID}    ${sa1_ueID}
    Set Test Variable    \${sa2_ueID}    ${sa2_ueID}
    Set Test Variable    \${nsa_enb_x2apId}    ${nsa_enb_x2apId}
    Set Test Variable    \${nsa_gnb_x2apid}    ${nsa_gnb_x2apid}

UE3 UE4 UE32 attach to cell2
    [Return]    ${sa3_ueID}    ${sa4_ueID}    ${nsa_enb_x2apId2}    ${nsa_gnb_x2apid2}
    ${sa3_ueID}    Register For Normal Call and create PDU Successfully    ue_id=3    cell_id=2
    ${sa4_ueID}    Register For Normal Call and create PDU Successfully    ue_id=4    cell_id=2
    ${nsa_enb_x2apId2}    ${nsa_gnb_x2apid2}    NSA UE ICS and setup ENDC to TargetGnbCell    ue_id=32    target_gnbCell=2
    Set Test Variable    \${sa3_ueID}    ${sa3_ueID}
    Set Test Variable    \${sa4_ueID}    ${sa4_ueID}
    Set Test Variable    \${nsa_enb_x2apId2}    ${nsa_enb_x2apId2}
    Set Test Variable    \${nsa_gnb_x2apid2}    ${nsa_gnb_x2apid2}

Lock ABIO1
    delta commission parameters    MRBTS/EQM-1/APEQM-1/CABINET-1/BBMOD-1:administrativeState=Locked

Unlock ABIO1
    delta commission parameters    MRBTS/EQM-1/APEQM-1/CABINET-1/BBMOD-1:administrativeState=Unlocked

Modify UE Establishemnt Cause
    [Arguments]    ${ue_id}    ${cause}
    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=${cause}

Register For Normal Call Successfully
    [Arguments]    ${ue_id}    ${cell_id}    ${enb_id}=2
    [Return]    ${sa_ueID}
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Modify UE Establishemnt Cause    ${ue_id}    mo-Signalling
    ${sa_ueID}    UE Register To GNB    ${ue_id}

Register For Normal Call and create PDU Successfully
    [Arguments]    ${ue_id}    ${cell_id}
    [Return]    ${sa_ueID}
    ${sa_ueID}    Register For Normal Call Successfully    ${ue_id}    ${cell_id}
    UE PDU Session Setup    ${ue_id}    ${ue_id}

UE Register To GNB
    [Arguments]    ${ue_id}
    [Return]    ${ngapID}[0]
    ${output}    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Reg
    ${ngapID}    Get Regexp Matches    ${output}    Starting Authentication Procedure for UE with RAN UE NGAP ID (\\d+)    1

UE PDU Session Setup
    [Arguments]    ${ue_id}=1    ${gw_id}=1
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${gw_id}    QoS Routing Table

NSA UE ICS and setup ENDC to TargetGnbCell
    [Arguments]    ${ue_id}    ${target_gnbCell}
    [Return]    ${MeNB_x2apIDList[0]}    ${sgNB_x2apIDList[0]}
    UE Attach To ENB    ${ue_id}
    ${output}    Execute Egate Command
    ...    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_gnbCell} bearer=2 type=split_scg
    ...    pass_regexp=SgNBAdditionRequestAcknowledge
    ${MeNB_x2apIDList}    Get Regexp Matches    ${output}    value UE-X2AP-ID : (\\d+)    1
    ${sgNB_x2apIDList}    Get Regexp Matches    ${output}    value SgNB-UE-X2AP-ID : (\\d+)    1

UE Attach To ENB
    [Arguments]    ${ue_id}=31
    Execute Egate Command    ue_attach id=${ue_id}    pass_regexp=UE IS ACTIVE

