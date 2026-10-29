*** Settings ***
Documentation
...    author: Zhang Yin
...    contact: yin.zhang@nokia-sbell.com
...    squal group: SG03
...    feature: CNI-156057
...    qosflow setting:
...        set_qosflow id=1 5qi=6
...        set_qosflow id=2 5qi=7 ue=all
...        set_qosflow id=3 5qi=8 ue=all
...        set_qosflow id=4 5qi=9 ue=all
...        set_qosflow id=5 5qi=5 ue=all default=on
...        set_qosflow id=6 5qi=1 ue=all
...        set_qosflow id=7 5qi=4 ue=all
Suite Setup       Common Suite Setup And Setup Airphone Env    tl_type=fddtdd_sansa_cmwv_tmo_65
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        CA_5G_RRM    release-SBTS26R2    tl-CLOUD_5G_I_LOO_AP_LOOO
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ET.robot

*** Variables ***
${ue_nr_capabilities_vonr}    SEPARATOR=
...    E1A01000074E5A031E000381A00F04983200021E0A018806804C020301C022A36146B04050D012CB2898183D6C10101070EF1C39061C00103
...    278FAB80027800E0009E00151B11B582028680965944C0C1EB608080838778E1C830E0008193C7D53FF4FFCA8D89BAC10143404B2CA26060F
...    5B0404041C3BC70E418700040C9E3EAE0009E003800278000610713400000041C2800000010711800000802809B00A20230380780C0440230
...    1000FF5555504C00E000A070500703007803800341F004000000000000000100795358194010400002596540000010074AAA881D0500E0016
...    00010008010020010040086AC4C0004080C1014181C202C4044484C648494989CA12986B40

${ue_nr_capabilities_non_vonr}    SEPARATOR=
...    E1A03E00474F7AEF7FFFAF084000F05C0407824F7CFFFFFF002600C6F3E00050370300FC7016A2F831EF13843B102087E5068020B65474031
...    27D620F2107840A12DF3F013FF0FC000FFC3F0000BC0001C00140A8BE147BC4E10EC40821F941A0082D951D00C49F5883C841E10284B7CFC0
...    2EEE3BE003BB8EF8002F500070005001B2800028000001000200002A2F85FEF13843B102087E5068020B6547403127D620F2107840A12DF3F
...    013F9EE7800FE7B9E000BC0001C00140A8BE20FBC4E10EC40821F941A0082D951D00C49F5883C841E10284B7CFC04FFC3F0003FF0FC0002F0
...    0007000502A2F88DEF13843B102087E5068020B6547403127D620F2107840A12DF3F0108002000BC0001C00140A8BE267BC4E10EC40821F94
...    1A0082D951D00C49F5883C841E10284B7CFC0220008002F500070005001B28000280000010002000003141E0C000611800007A27541C0C01C
...    460000027A27541E14000611800047A27541C1401C460000067A27541E140007118000021E89D50788C00184600029E89D503850100018C44
...    EA83C18000C140001CF44EA8381803850000020F44EA83C18000E140000093D13AA0F0A0003050000A3113EA0F060003030000B3D13A00A02
...    3402880302EC41120C853A76C93E0429D3B649F021469DB24F810A74ED927C0850A76C93E0429D3B649F02046D927C0853A76C93E0429D1B6
...    49F0214E81B24F810A34ED927C0853A76C93E002618318C6318C6318C603E060482432090482432090C824320900603F98000017801F00140
...    0180E0A00E062138038003800301F02C41000000208000011040000108200000C41000008208000051040000308200001C410008080208200
...    10100510400202808208004050140760CD64CD606D646D60EDE54D6065646501C1000009659404000065965010000296594040000E5965010
...    00049659504000165965410000696594040001E59650075068AA4D1540E2A91C5507ABA555541E2E95450B008402FC160F0583C160F0583C1
...    E0F0580001610700200600400C010028020040E00C0040200080300100800020E004004008008020010040001C0180380400900600E010020
...    41C0280580500B00C01A018030380300100800200C0040200008380500100A002018004030000700600E0100240180380400810700A01E014
...    03C030088060100E00C01C0200480300700801020E01C01C038038080090100101C0380080800100E00202000001C0480580A00B01601A030
...    03041C0080180100300400A008010380500100C00201400403000083801001002002008004010000700A0160180340280580600C107002006
...    00400C010028020040E01403C0300880500F00C02020E01402C0280580600D00C0181C0280080600100A00201800041C0080180100300400A
...    00801038010010040020040040100010B070103040B182F414677000000020

@{pass_regexp_ec_not_fallback}
...    PDU Session Resource Setup with PDU Session ID 2 was unsuccessful
...    due to RAN unspecified

@{pass_regexp_pdu_modificaiton_ec_fallback}
...    PDU Session Resource Modify Unsuccessful Transfer
#...    due to RAN ims voice eps fallback or rat fallback triggered
...    rrcRelease
...    eutraFrequency 2325
...    UE.*: IS IDLE

*** Test Cases ***
CNI-156057_A_B3_007_PDU_Session_Resource_Modify_with_RAC_Rejection_B1measurement_to_LTE
    log to console    case:PDU_Session_Resource_Modify_with_RAC_Rejection_no_vonr_capability_and_no_sim_card
    log to console    step1: set amf_param to make ICS with “Redirection for Voice EPS Fallback” = 'not-possible'
    execute egate command    amf_param id=1 full_nas_auth=on nia=null+aes nea=null+aes voice_fallback=off ims_voice_3gpp=on

    log to console    step2: online change to enable feature flag and support no sim card
    delta commission parameters    ${DELTA_ENABLE_CNI156057}
    delta commission parameters    ${DELTA_SUPPORT_NO_SIM_CARD}

    log to console    step3: UE1 (non VONR capability) ICS with 5QI6
    No Sim Card UE ICS without PDU Session   ue_id=1    ue_nr_capabilities=${ue_nr_capabilities_non_vonr}

    log to console    step4: UE1 triggers EC with pdu session setup contains 5QI5 and 5QI1,
    log to console    expect EC redirect to LTE with cause redirection in NGAP:UEContextReleaseRequest
    Setup PDU Session With EC 5QI5 And Modify With 5QI1    ue_id=1    pass_regexp=${pass_regexp_pdu_modificaiton_ec_fallback}
    idle ue count should be    ue_num=1
    check EC fallback to LTE from wireshark


*** Keywords ***
Modify Cfg
    # no sim card setting
    ${set_ue}     catenate    set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    sec_key=0102030405060708090A0B0C0D0EFF00 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc
    ...    suci=0:310:260:0000:0:0:021645401 imei=12345123:451234:1 mode=nr enb=2 cell=1
    Update Cfg    ${set_ue}
    # change default qosflow
    Update cfg    set_qosflow id=1 5qi=6
    Update cfg    set_qosflow id=5 5qi=5 ue=all default=on


No Sim Card UE ICS without PDU Session
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${ue_nr_capabilities}=${ue_nr_capabilities_vonr}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    execute egate command    ue_param id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities}
    execute egate command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=emergency
    execute egate command    amf_param id=1 bypassAuth_nullSecurity=on
    execute egate command    amf_param id=1 send_ics_registration=on
    Execute Egate Command    ue_register id=1 registration_type=EmergencyRegistration withSim=no
    ...    pass_regexp=Received REGISTRATION COMPLETE

Setup PDU Session With EC 5QI5 And 5QI1
    [Arguments]    ${ue_id}    ${pass_regexp}
    execute egate command    qosflow_modify qos_flow=5 default=on
    execute egate command    smf_param additional_qosflows_to_activate=6 id=1
    execute egate command    qosflow_modify qos_flow=5 priority=1
    execute egate command    qosflow_modify qos_flow=6 priority=1
    execute egate command    ue_pdu_session_setup ue=${ue_id} pdu=2 gw=1 nwslice=1    pass_regexp=${pass_regexp}

Setup PDU Session With EC 5QI5 And Modify With 5QI1
    [Arguments]    ${ue_id}    ${pass_regexp}
    execute egate command    qosflow_modify qos_flow=5 priority=1
    execute egate command    qosflow_modify qos_flow=6 priority=1
    execute egate command    qosflow_modify qos_flow=5 default=on
    execute egate command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1 request_type=initial-emergency-request
    ...    pass_regexp=PduId 1 Created FiveQi:Qfi mapping fiveQi 5 qfi 1
    ...    sleep_time=10
    execute egate command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=6    pass_regexp=${pass_regexp}

check EC fallback to LTE from wireshark
    ${wireshark_log_path}    stop capture wireshark log    tag=${EMPTY}    wait=60
    log   AMF receive NGAP: PDU Session Resource Modify Response with 'ims-voice-eps-fallback-or-rat-fallback-triggered'
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=(ngap.procedureCode == 26) && (ngap.radioNetwork == 36)
    ...                       check_fields=cause/radioNetwork=ims-voice-eps-fallback-or-rat-fallback-triggered
    ...                       packet_num=-1

    log    gNB-CU-CP sends F1AP: DLRRCMessageTransfer for RRCRelease with redirection to gNB-DU
    log    ....gNB-DU sends RRCRelease with redirectedCarrierInfo to UE
    Run Keyword And Continue On Failure    check_wireshark_fields
    ...                       pcap_file=${wireshark_log_path}
    ...                       filter=((f1ap.procedureCode == 12) && (nr-rrc.redirectedCarrierInfo == 1))
    ...                       check_fields=rrcRelease/redirectedCarrierInfo/eutra/eutraFrequency=2325

    log    NGAP:UEContextReleaseComplete
    Run Keyword And Continue On Failure    check_wireshark_fields
    ...                       pcap_file=${wireshark_log_path}
    ...                       filter=(ngap.procedureCode == 41) && (ngap.id == 60)
    ...                       check_fields=PDUSessionResourceListCxtRelCpl=1 item

    log    E1AP:BearerContextReleaseComplete
    Run Keyword And Continue On Failure    check_wireshark_fields
    ...                       pcap_file=${wireshark_log_path}
    ...                       filter=e1ap.procedureCode == 11
    ...                       check_fields=BearerContextReleaseComplete/protocolIEs=[RE].*
    ...                       packet_num=-1

    log    F1AP:UEContextReleaseComplete
    Run Keyword And Continue On Failure    check_wireshark_fields
    ...                       pcap_file=${wireshark_log_path}
    ...                       filter=f1ap.procedureCode == 6
    ...                       check_fields=UEContextReleaseComplete/protocolIEs=[RE].*
    ...                       packet_num=-1
