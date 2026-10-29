*** Settings ***
Documentation
...   Author: zhixia.qin@nokia-sbell.com
...   Contact: zhixia.qin@nokia-sbell.com
...   Description: This user scenario describes



Suite Setup       Common Suite Setup For RRM
Test Setup        Common Test Setup For RRM
Suite Teardown    Common Suite Teardown For RRM

Test Timeout    120 minutes

Resource          ../../../Resources/Classical/RRM_Common_Resource.robot
Resource          CommonKeyword/CB012629_Common_KeyWord.robot
Resource          CommonKeyword/CB012629_ET_KeyWord.robot

*** Variables ***
${MRBTS_ID}   1
${NRBTS_ID}   1
${SA_Capa_Inactive_N3_N28_N77}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C47013B8D80D81AC1184341020E9068036B64C558D0E7C471E81
...    9F604F8C48E3C873EA39F30C7942C0E070F05C00FFC0070005F0005C0000E0541B00B582308682041E20D00656C98AB121CFB027C471E31238F21CFA8E
...    7CC31E50B0381C3C27F6000001FD800000170000381546C4CD608C21A0810748340185B262A88873E238F11C7A067D813E31CF9863CA1607038782E007
...    FE003801FF8002E0000702A0D837AC1184341020F1068032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001
...    C0EE36147FEB04610D04083A41A00DAD931563439F11C7A067D813E31238F21CFA8E7CC31E50B0381C3C17AABFFAA9EAAFFEAA17000038026B0F130003
...    8980000002C0AC5C4C000E26000713000000858158B80400184C0309800020B02B1F008003836001C4C000E260000030B02B170080030040606C000816
...    0563E0100060180C0D8184D0002858158B80400181B0309800060B02B0F00800309800070B02B0F00800300400080B02B0F06C00303600090B02B0F008
...    00300C000A0B02B0F018003036000B0B02B1700800300C0606C0018160563E0D800713000309806130001A160562E2600061300C01000382C0AC780203
...    89800184C03098000F0B02B171300030040606C0020160563E2680060080C030181B0008858158F80400180203098061300024160402401B800D013200
...    1402817400F709C28913639F0E2448913639F0E2448913639F0E344891226C73E1C4891226C73E1C68912244D8E7C38912244D8E7C3851226C73E1C289
...    13639F0E14489B1CF870A244D8E7C3851226C73E1C4891226C73E1C28913639F0E2448913639F0E344891226C73E1C4891226C73E1C68912244D8E7C38
...    D1224489B1CF861B1318C6318C6318C6318C6318C7E82E003C00281C1401C0C02500700060240040603E09002000000010008000000200000C01000002
...    00800002004000018020000100100000A008004010040100000C0080000700400200000008000080040000480200000C010000140080000B0040020481
...    20080000C0339535953582958195833582B594B7933780B581B58095811583B40D04000025949410000196526040000659490100003965240400012594
...    9010000596526040001A594901000079652404000225949010000996524040002A5949010000B96525040003259490100003165240334AAAE955552A8B
...    A55154162A82C55068AA531549A2A80C55028AA4D5541E285805E02540A05028140A05028140A05028140A05028140A050012080801002020040088040
...    080101002004040080110080600A02004008080100230100C014040300501002004040080110080800A02020028080B01630100C01804030050100C018
...    040080110080600A02018028080100210100C014040080108080600A02018028404030060100C018202018030080600A10100C014040300510080600A0
...    2018030080600A30100C018040080101002004040080110080100202004008080600A30100C01404008010100200404008011008010020201803008060
...    0C30100200404030050100C018040300518080600A02018028080100202004008D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139
...    414951697A0A0C96A510000210

*** Test Cases ***
[TC18]CB012629_SR_A_B103_18_PCMD_records_from_gNB_DU_during_RRC_Inactive_to_Fallback_to_RRC_Setup_CB008225_D_B7
    [Tags]    QC_25189       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...   Description: This user scenario describes gNB’s behaviour when a ‘B2 Measurement Report’ is received from the UE
    Airphone Edaemon Egate Setup
    Airphone Cfg Configuration    wts_cfg_name=${CURDIR}/config/CB008225/wts_2_gnbs.cfg
    wait until keyword succeeds    3 min    10 sec    Airphone Verify bts status
#    Log Collection    operation=start   log_type=syslog   product_type=gnb   bts_index=${0}
#    Log Collection    operation=start   log_type=syslog   product_type=gnb   bts_index=${1}
    Start Collect Wireshark For GNB     bts_index=${0}
    ${tcpdump_log_name_T}   Start Tcpdump Log on Target gNB
#   Start Subscriber Trace    ue_id=${ue_id}   trace_rec_session_ref_id=${ue_id}   trace_ref_id=${ue_id}
    Update UE capa    ue_id=1    SA_Capa_perUE_Full=${SA_Capa_Inactive_N3_N28_N77}
    UE Register And PDU Session Setup    ue_id=1    pass_regexp=${releasePreference_check}
    UE setup new PDU    ue_id=1   pdu=2    nwslice=2    gateway=2
    Start traffic to Active    ue_id=1
    Stop traffic to Inactive   ue_id=1    pass_regexp=${inactive_check}
    Trigger RRC Resume wo Action  ue_id=1  gnb_id=3  cell_id=13  cause=rna_Update  msg=resume_request
    sleep  20s
    ${local_file_path_gNB1}   Stop Wireshark log For GNB    bts_index=${0}
    ${local_file_path_gNB2}   Stop Tcpdump Log on Target gNB      tcpdump_log_name_T=${tcpdump_log_name_T}
    ${rrc_setup_gnb2_cell13}    Check common tracerecords   tracerecords=${rrc_setup_gnb2_cell13}   capture_file_path=${local_file_path_gNB2}
    ${start_sesstion}   Check tracerecords   tracerecords=${start_sesstion}   capture_file_path=${rrc_setup_gnb2_cell13}  host=mba
    Should Not Be Empty     ${start_sesstion}
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords_after_resume}   capture_file_path=${rrc_setup_gnb2_cell13}   host=mba
#    Check multi tracerecords   tracerecords=${duup_tracerecords}   capture_file_path=${local_file_path}   host=sba
#    Check common tracerecords  tracerecords=${f1ap_trace_activate}   capture_file_path=${local_file_path}
    [Teardown]    TC018 Teardown

[TC19]CB012629_SR_A_B103_16_PCMD_records_from_gNB_DU_during_RRC_Inactive_to_Fallback_to_RRC_Setup_CB008225_D_E9
    [Tags]    QC_25190       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...   Description: This user scenario describes gNB’s behaviour when a ‘B2 Measurement Report’ is received from the UE
    Airphone Edaemon Egate Setup
    Airphone Cfg Configuration    wts_cfg_name=${CURDIR}/config/CB008225/wts_2_gnbs.cfg
    wait until keyword succeeds    3 min    10 sec    Airphone Verify bts status
    Start Collect Wireshark For GNB     bts_index=${0}
    ${tcpdump_log_name_T}   Start Tcpdump Log on Target gNB
#   Start Subscriber Trace    ue_id=${ue_id}   trace_rec_session_ref_id=${ue_id}   trace_ref_id=${ue_id}
    Update UE capa    ue_id=1    SA_Capa_perUE_Full=${SA_Capa_Inactive_N3_N28_N77}
    UE Register And PDU Session Setup    ue_id=1    pass_regexp=${releasePreference_check}
    UE setup new PDU    ue_id=1   pdu=2    nwslice=2    gateway=2
    Start traffic to Active    ue_id=1
    Start Collect Wireshark For GNB     bts_index=${0}
    Start Collect Wireshark For GNB     bts_index=${1}
    Stop traffic to Inactive   ue_id=1    pass_regexp=${inactive_check}
    Trigger RRC Resume wo Action  ue_id=1  gnb_id=3  cell_id=13  cause=rna-Update  msg=resume_request1
    sleep  20s
    ${local_file_path_gNB1}   Stop Wireshark log For GNB    bts_index=${0}
    ${local_file_path_gNB2}   Stop Tcpdump Log on Target gNB      tcpdump_log_name_T=${tcpdump_log_name_T}
#    ${start_sesstion}   Check tracerecords   tracerecords=${start_sesstion}   capture_file_path=${local_file_path}  host=mba
#    Should Not Be Empty     ${start_sesstion}
#    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}   capture_file_path=${local_file_path}   host=mba
#    Check multi tracerecords   tracerecords=${duup_tracerecords}   capture_file_path=${local_file_path}   host=sba
#    Check common tracerecords  tracerecords=${f1ap_trace_activate}   capture_file_path=${local_file_path}
    [Teardown]    TC019 Teardown

*** Keywords ***
TC018 Teardown
    UE Deregister From gNB    ue_id=1
    Log Collection    operation=stop_and_download   log_type=syslog   product_type=gnb   bts_index=${0}
TC019 Teardown
    UE Deregister From gNB    ue_id=1
#    Add or Delete A New MOC    moc_jason=delete_NRMTRACEDU-1.json
    Log Collection    operation=stop_and_download   log_type=syslog   product_type=gnb   bts_index=${0}

