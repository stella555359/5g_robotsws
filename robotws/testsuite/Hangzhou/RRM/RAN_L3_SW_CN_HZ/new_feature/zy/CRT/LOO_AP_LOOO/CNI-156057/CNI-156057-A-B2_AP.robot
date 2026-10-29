*** Settings ***
Documentation
...    author: Zhang Yin
...    contact: yin.zhang@nokia-sbell.com
...    squal group: SG03
...    feature: CNI-156057
...    qosflow setting:
...        set_qosflow id=1 5qi=6 default=on
...        set_qosflow id=2 5qi=7 ue=all
...        set_qosflow id=3 5qi=8 ue=all
...        set_qosflow id=4 5qi=9 ue=all
...        set_qosflow id=5 5qi=5 ue=all
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

@{pass_regexp_ec_fallback}
...    PDU Session Resource Setup with PDU Session ID 2 was unsuccessful
...    due to RAN ims voice eps fallback or rat fallback triggered
...    rrcRelease
...    eutraFrequency 2325
...    UE.*: IS IDLE

*** Test Cases ***
CNI-156057_A-B2_004_PDU_Session_Resource_Setup_with_RAC_Rejection_no_resource_redirect_to_LTE
    #CNI-156057_A#B2_005
    log to console    case:CNI-156057_A#B2_005_PDU_Session_Resource_Setup_with_RAC_Rejection_without_Vonr_capable_fallback_to_LTE
    log to console    step1.1: set amf_param to make ICS with “Redirection for Voice EPS Fallback” = 'not-possible'
    clear counter files    wait=${False}
    execute egate command    amf_param id=1 voice_fallback=off ims_voice_3gpp=on

    log to console    step1.2: online change to enable feature flag
    delta commission parameters    ${DELTA_ENABLE_CNI156057}

    log to console    step1.3: UE1 (non VONR capability) ICS with 5QI6
    SA Attach UE With 5QI6   ue_id=1    ue_nr_capabilities=${ue_nr_capabilities_non_vonr}

    log to console    step1.4: UE1 triggers EC with pdu session setup contains 5QI5 and 5QI1,
    log to console    expect EC redirect to LTE with cause redirection in NGAP:UEContextReleaseRequest
    Setup PDU Session With EC 5QI5 And 5QI1    ue_id=1    pass_regexp=${pass_regexp_ec_fallback}
    idle ue count should be    ue_num=1
    Run Keyword And Continue On Failure    Check Counters    ${AB2_005_COUNTERS}

    # CNI-156057-A#EC1
    log to console    case:CNI-156057-A#EC1_008_PDU_Session_Resource_Modify_with_RAC_Rejection_actIgnoreAmfVoiceEpsFbEc_FALSE
    clear counter files    wait=${False}

    log to console    step1.2: online disable feature flag
    delta commission parameters    ${DELTA_DISABLE_CNI156057}

    log to console    step1.3: UE2 (non VONR capability) ICS with 5QI6
    SA Attach UE With 5QI6   ue_id=2    ue_nr_capabilities=${ue_nr_capabilities_non_vonr}

    log to console    step1.4: UE2 triggers EC with pdu session setup contains 5QI5 and 5QI1,
    log to console    expect PDU session setup failed and EC not redirect to LTE, UE is active
    Setup PDU Session With EC 5QI5 And 5QI1    ue_id=2    pass_regexp=${pass_regexp_ec_not_fallback}
    active ue count should be    ue_num=1
    idle ue count should be    ue_num=1
    Check Counters    ${A_EC1_COUNTERS}

*** Keywords ***
Modify Cfg
    Update Cfg    set_qosflow id=1 5qi=6 default=on


SA Attach UE With 5QI6
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${ue_nr_capabilities}=${ue_nr_capabilities_vonr}
    ...    ${pass_regexp}=Initial Context Setup Successful
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    ue_enb_param id=${ue_id} ue_history_list=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    execute egate command    ue_param id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=${pass_regexp}

Setup PDU Session With EC 5QI5 And 5QI1
    [Arguments]    ${ue_id}    ${pass_regexp}
    execute egate command    qosflow_modify qos_flow=5 default=on
    execute egate command    smf_param additional_qosflows_to_activate=6 id=1
    execute egate command    qosflow_modify qos_flow=5 priority=1
    execute egate command    qosflow_modify qos_flow=6 priority=1
    execute egate command    ue_pdu_session_setup ue=${ue_id} pdu=2 gw=1 nwslice=1    pass_regexp=${pass_regexp}

download and check wireshark fields
    [Arguments]    ${tag}    ${filter}    ${check_fields}    ${times}=1
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found    ${tag}    ${filter}    ${times}
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${filter}
    ...                       check_fields=${check_fields}
    ...                       packet_num=all
