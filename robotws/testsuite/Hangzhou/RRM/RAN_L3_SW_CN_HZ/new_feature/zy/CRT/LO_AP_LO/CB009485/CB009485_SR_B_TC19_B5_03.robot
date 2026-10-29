*** Settings ***
Documentation
...    author: Li Zhiguo
...    contact: zhiguo.li@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup Airphone Env And Start TCE
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    release-SBTS26R1    tl-CLOUD_5G_I_LO_AP_LO
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ET.robot

*** Variables ***
@{FAULTS_EXCLUDED_CHECKING}    8000
${UE_capa}    SEPARATOR=
...    E9A09000575F5A13160003C5200016093170019C3D0B004D9061CF9863CA160704C060188E01F71B0A303582308682041D211001B5B262AC
...    6873E238F40CFB027C62471E439F51CF9863CA1607038782E007FE0038002F8003600001C0A83620EB04610D04083C4220032B64C55890E7
...    D813E238F1891C790E7D473E618F28581C0E1E13FB000000FEC000000D80000702A8D89BAC1184341020E908800C2D931544439F11C788E3
...    D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC001B00000E0541B11B582308682041E21100195B262AC4873E238F604F8C48E3C873
...    EA39F30C7942C0E070F09FFF000007FFC000006C00003801EF0F1340038820000042C040A83C28000E230000010B02B0F11800388200000C
...    2C0AC3C28000E208000010B02B0F13400388C0000042C0AC5C46000E208007104000028581587850001C4D00000C160562E2680071040038
...    500000102C0AC5C4D000E23000711800001058158B850001C41000E230000020B02B170A0003882001C41000004160562E26800710400388
...    C0000082C0AC5C28000E23000711800001058158B89A001C46000E140000040B02B0F11800388C00000C2C0803808D00A2026C0411B4002E
...    C1F0A244D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C3850206C73E044810206C73E044810206C73E0448
...    10206C73E044810206C73E044810206C73E044810206C73E044810206C73E0428103639F0005C3C6318C6318C6318C63187A0F8003C00281
...    C1401C0C02500700060240040603E09002000000010000020080000000400000802000008010000060080000400400002802001004010040
...    000300200001C010008000000200002001000012008000030040000500200002C01000812048020000300CE54D654D60A5606560CD60AD65
...    2D64CD602D606D6025604560ED0341000009652504000065949410000296524040000E594901000049652404000165949010000696524040
...    001E594901000089652404000265949010000A96524040002E5949410000C96524040000C594900CD2AABA55554AA2E95455058AA0B1541A
...    2A94C55268AA031540A2A93555078A1E005E02540A05028140A05028140A05028140A05028140A05000608080600C0200400840400802010
...    0C018402004008080600C02018030404030060100C018402004008080600C02004008804030060100C018040300608080100402004010D50
...    F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C96A510000210
${mba_ueReleaseRecord}    (nsetapx.traceActivationType == 0) && (nsetapx.CuVendorExtensionRecordDataType == 0)
@{ueReleaseRecord}    ueReleaseRecord/trigger=gNB
...                   ueReleaseRecord/reason=other
...                   ueReleaseRecord/ueCtxReleaseReqSendTime/seconds=[RE].*
...                   ueReleaseRecord/ueCtxReleaseReqSendTime/useconds=[RE].*
...                   ueReleaseRecord/ueCtxReleaseCmdRcvTime/seconds=[RE].*
...                   ueReleaseRecord/ueCtxReleaseCmdRcvTime/useconds=[RE].*
...                   ueReleaseRecord/ueCtxReleaseCmplSendTime/seconds=[RE].*
...                   ueReleaseRecord/ueCtxReleaseCmplSendTime/useconds=[RE].*

*** Test Cases ***
CB009485_SR_B_TC19_B5_03_gNB-CU UE Release Trace Record in case of Unaccepted RRC Reestablishment - Invalid RRCReestablishmentComplete from UE
    start to capture wireshark log    tag=invalidRRECmpl
    Ue with specified capabilitiy Register And Pdu Session Setup At Cell-1
    Sleep    5s
    UE Reestablish with invalid TID to Cell-2
    Sleep    30s
    download and check wireshark fields    tag=invalidRRECmpl
    ...                                    filter=${mba_ueReleaseRecord}
    ...                                    check_fields=${ueReleaseRecord}

*** Keywords ***
Common Suite Setup And Setup Airphone Env And Start TCE
    Common Suite Setup And Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/3cells_1T2F
    Start TCE    ${TCE_PORT}

Modify Cfg
    FOR    ${gateway_id}    IN RANGE    1    11
        Update Cfg    set_pdu_gateway id=${gateway_id} ue_nat_ip=72.23.${gateway_id}.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    END
    ${V2}    catenate
    ...    ue_param id=1-10 ue_nr_capabilities=${UE_capa}
    ${V3}    catenate
    ...    set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nea=null+snow3g+aes+zuc nia=null+snow3g+aes+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645400
    ...    enb=2 cell=1 mode=nr
    Update Cfg    ${V2}
    Update Cfg    ${V3}
    Update Cfg    sim_trace amf=1 protocol=ng on

Ue with specified capabilitiy Register And Pdu Session Setup At Cell-1
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_location_change id=${ue_id} enb=2 cell=1
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${ue_id} nwslice=1    pass_regexp=QoS Routing Table

UE Reestablish with invalid TID to Cell-2
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_rrc_reestablish_param id=${ue_id} if_contains=any action=invalid_tid
    Execute Egate Command    ue_rrc_reestablish id=${ue_id} cell=2

download and check wireshark fields
    [Arguments]    ${tag}    ${filter}    ${check_fields}    ${decode_filter}=tcp.port==49100    ${packet_num}=-1
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found    ${tag}    ${decode_filter}
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${filter}
    ...                       check_fields=${check_fields}
    ...                       packet_num=${packet_num}
