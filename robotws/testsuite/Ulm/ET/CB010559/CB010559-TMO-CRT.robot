*** Settings ***
Documentation
...    author: VRF ULM T04 01
...    Team: 'MN RAN RD VRF ULM 4'
...    Email: 'OU_MN_RAN_RD_VRF_ULM_4_53245007_GMS <OU_MN_RAN_RD_VRF_ULM_4_53245007@internal.nsn.com>'
...    Description: Robot SE TCs for  CB010559:RRC connection re-establishment to an unprepared gNB.
...    CLOUD_5G_I_LOO_AP_LOOO+VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Resource               CB010559-Keywords.robot
Resource               CB010559-Commissioning.robot
Library                taf.config.wts       WITH NAME    wts_conf

Suite Setup            CB010559 Setup    # 1 real,2 sim gNBs

Test Setup             Perform Precondition Of Test Scenario
Test Teardown          CB010559-Keywords.Perform Postconditions Of Test Scenario

*** Variables ***

${SET_SIM_GNB3}        type=simulated plmn=310:260 ng=$GNB3_NG_ADDR gnb_id=0x3:22 daemon=$SERVER_IP:$DAEMON_PORT s1u=$GNB3_S1U_ADDR
...                    x2=$GNB3_X2_ADDR:36422 x2_peers=none xn=$GNB3_XN_ADDR nssai=0x1:0xd143a5,0x1:1000 amf=1 plmnList=310:260
${SIM_GNB3_PARAM}      x2_listening_socket=1 sib1_period=40 send_xn_setup=false measEvent=A3
...                    ng_data_forwarding_HO=on gbr_data_forwarding_HO=on sa_ho=xn_based
...                    ciphering_algorithm=nea2 integrityprotection_algorithm=nia2
${SET_SIM_GNB3_CELL}   gnb=3 pci=30:0 tac=200 nrci=0x30 tdd_cell=on proxy=$GNB3_NG_ADDR:5555 nr_arfcn=528000:528000
...                    mandatory_for_activation=off gscn=6501

${SET_SIM_GNB4}        type=simulated plmn=310:260 ng=$GNB4_NG_ADDR gnb_id=0x4:22 daemon=$SERVER_IP:$DAEMON_PORT s1u=$GNB4_S1U_ADDR
...                    x2=$GNB4_X2_ADDR:36422 x2_peers=none xn=$GNB4_XN_ADDR nssai=0x1:0xd143a5,0x1:1000 amf=1 plmnList=310:260
${SIM_GNB4_PARAM}      x2_listening_socket=1 sib1_period=40 send_xn_setup=false measEvent=A3
...                    ng_data_forwarding_HO=on gbr_data_forwarding_HO=on sa_ho=xn_based
${SET_SIM_GNB4_CELL}   gnb=4 pci=30:0 tac=200 nrci=0x40 tdd_cell=off proxy=$GNB4_NG_ADDR:5556 nr_arfcn=381000:397000
...                    mandatory_for_activation=off gscn=4961 suggested_band=25

${SA_CAPA_VONR}        SEPARATOR=
...                    E1A03E00474F7AEF7FFFAF0A40003C170101E093DF3FFFFFC00B8018DE7C000A06E0601F8E02D45F063DE27087620410FCA1100105B2A3A01893EB1079083C
...                    205096F9F809FF87E0007FE1F80007600001C00140A8BE147BC4E10EC40821F94220020B6547403127D620F2107840A12DF3F00BBB8EF800EEE3BE000ED400
...                    038002800D9400014000000800100001517C2FF789C21D881043F284400416CA8E80624FAC41E420F081425BE7E027F3DCF001FCF73C001D800007000502A2
...                    F883EF13843B102087E50880082D951D00C49F5883C841E10284B7CFC04FFC3F0003FF0FC0003B00000E000A0545F11BDE27087620410FCA1100105B2A3A01
...                    893EB1079083C205096F9F80840010007600001C00140A8BE267BC4E10EC40821F94220020B6547403127D620F2107840A12DF3F0088002000ED4000380028
...                    00D940001400000080010000018A0F06000308C00003D13AA0E0600E230000013D13AA0F0A000308C00023D13AA0E0A00E230000033D13AA0F0A000388C000
...                    010F44EA83C46000C2300014F44EA81C2808000C6227541E0C00060A0000E7A27541C0C01C280000107A27541E0C00070A0000049E89D50785000182800051
...                    889F50783000181800059E89D005011A01440181D6201120C853A76C93E2C29D3B649F161469DB24F8B0A74ED927C5850A76C93E2C29D3B649F16046D927C5
...                    853A76C93E2C29D1B649F1614E81B24F8B0A34ED927C5853A76C93E282618318C6318C6318C603E060482432090482432090C824320900603F980000238003
...                    E002800301C1401C0C4270070007000603E058820000004100000220800002104000018820000104100000A2080000610400003882001010041040020200A2
...                    08004050104100080A0280EC19AC99AC0DAC8DAC1DBCA9AC0CAC8CA0382000012CB28080000CB2CA02000052CB28080001CB2CA02000092CB2A080002CB2CA
...                    820000D2CB28080003CB2CA00EA0D1549A2A81C55238AA0F574AAAA83C5D2A8A1E0042017E0B0782C1E0B0782C1E0F0782C0000B0838010030020060080140
...                    10020700600201000401800804000107002002004004010008020000E00C01C0200480300700801020E01402C0280580600D00C0181C018008040010060020
...                    1000041C0280080500100C002018000380300700801200C01C0200408380500F00A01E018044030080700600E0100240180380400810700E00E01C01C04004
...                    8080080E01C0040400080700101000000E02402C0500580B00D01801820E00400C008018020050040081C0280080600100A00201800041C008008010010040
...                    02008000380500B00C01A01402C03006083801003002006008014010020700A01E0180440280780601010700A01601402C0300680600C0E014004030008050
...                    0100C00020E00400C008018020050040081C008008020010020020080009583808182058C17A0A33B80000001114

@{msg_list_A_B1_ALT1}
...                    c1 : rrcReestablishmentRequest
...                    RetrieveUEContextRequest
...                    RetrieveUEContextResponse
...                    c1 : rrcReestablishment
...                    c1 : rrcReestablishmentComplete
...                    XnUAddressIndication
...                    SNStatusTransfer
...                    (PATH SWITCH REQUEST ACK|UEContextRelease)
...                    (PATH SWITCH REQUEST ACK|UEContextRelease)

@{msg_list_I_B9}
...                    c1 : rrcReestablishmentRequest
...                    RetrieveUEContextRequest
...                    RetrieveUEContextFailure
...                    c1 : rrcSetup
...                    c1 : rrcSetupComplete

@{msg_list_P_B1}
...                    RetrieveUEContextRequest
...                    RetrieveUEContextResponse
...                    XnUAddressIndication

*** Test Cases ***

CB010559_A_SE_TC02_B1_ALT1_Successful_RRE_unpreparedgNB_no_HO_3gNB
    [Documentation]    Successful RRC Re-establishment in unprepared gNB without ongoing handover,
    ...                multiple UE Context Retrieve Requests are sent
    ...                (3 gNBs: Reestablish target gNB, UE's last serving gNB, Other non-last serving gNB)
    [Tags]    CRT  A_B1_ALT1
    # TI1: real gNB acting as Reestablish target gNB
    # test scope: multiple UE Context Retrieve Requests are sent to diff. gNBs, Responses handled accordingly
    Wait Until The Next Measurement Period Starts
    ${log_dir}                                      testline.Get Testcase Log Directory
    Set Suite Variable                              ${SRC_GNB}          &{GNB2}
    Set Suite Variable                              ${TGT_GNB}          &{GNB1}             # real, RR TGT
    UE Attach And Start Traffic
    tcpdump.Start Tcpdump On TestPc                 options=-i eth3 udp and port 2152     collector=gtp-u
    CB010559-Keywords.RRC Reestablishment Request
    Sleep                                           2s
    tcpdump.Stop Tcpdump On TestPc                  target_dir=${log_dir}       collector=gtp-u
    Verify Bearer Stats
    Verify RRE Counters                             ref_table=${RRE_COUNTERS_OTH_FAIL}
    Verify Msgs In Egate Console Log                ${msg_list_A_B1_ALT1}
    Deregister UE

    # TI2: real gNB acting as Other non-last serving gNB
    # test scope: UE Context Retrieve Failure message sent correctly
    Set Suite Variable                              ${SRC_GNB}          &{GNB3}
    Set Suite Variable                              ${TGT_GNB}          &{GNB2}
    Set Suite Variable                              ${OTH_GNB}          &{GNB1}
    UE Attach And Start Traffic
    CB010559-Keywords.RRC Reestablishment Request   pass_regexp=RetrieveUEContextFailure.*Cause : radioNetwork : ue-context-id-not-known

CB010559_I_SE_TC08_B9_UE_Ctxt_is_found_on_Src_HO_gNB_during_intra-gNB_handover_2_gNBs_Reestablish_target_gNB_UEs_last_serving_gNB
    [Documentation]  USCB010559-I#B9: UE Ctxt is found on Src HO gNB during intra-gNB handover(2 gNBs: Reestablish target gNB, UE's last serving gNB)
    [Tags]    CRT  I_B9
    Set Suite Variable                              ${SRC_GNB}          &{GNB1}
    Set Suite Variable                              ${TGT_GNB}          &{GNB2}

    UE Attach And Start Traffic
    CB010559-Keywords.RRC Reestablishment Request
    Deregister UE

    UE Attach And Start Traffic
    CB008574_Keywords.Ignore RRC Reconfig And Trigger RRCReestablishmentRequest
    ...                                             tgt_gnb=${TGT_GNB['apId']}  target_cell=${TGT_GNB['cellId']}  cause=handoverFailure
    Intra GNB HO                                    pass_regexp=rrcSetupComplete
    Verify Msgs In Egate Console Log                ${msg_list_I_B9}
    Sleep                                           5s   #(ctxt rel due to inactivity)

CB010559_P_SE_TC01_B1_Monitoring_CB010559_related_messages_in_Cell_Trace_functionality
    [Documentation]  USCB010559-P#B1 based on:
    ...              USCB010559-A#B1: Successful RRC Re-establishment without incoming handover on reestablishment target gNB
    [Tags]    CRT  P_B1
    Set Suite Variable                              ${VONR}             ${FALSE}
    RRE For Cell Trace Verification

    Reset WTS

    Set Suite Variable                              ${SRC_GNB}          &{GNB2}
    Set Suite Variable                              ${TGT_GNB}          &{GNB1}
    RRE For Cell Trace Verification

*** Keywords ***

RRE For Cell Trace Verification
    Start TCE Tracing
    UE Attach And Start Traffic
    CB010559-Keywords.RRC Reestablishment Request
    Deregister UE
    Sleep               10s
    Verify Cell Trace   ${msg_list_P_B1}

CB010559 Setup
    Setup Global Vars
    Sqd65 Common Setup                                   skip_precheck=${True}
    Setup WTS Cfg
    Bring Airphone TL To F1 Up Status
    Commissioning
    Bring Airphone TL To On Air Status Without Reboot    remove_logs=${True}
    Set Suite Variable                                   ${SW_BRANCH}      testline.Get gNB SW Branch

Perform Precondition Of Test Scenario
    IF    '${PREV_TEST_STATUS}'=='FAIL'    Bring Airphone TL To On Air Status
    Run Keyword And Ignore Error           UE Deregister
    Start Logging                          pmcounter_enabled=${FALSE}
    Get Resources Taken Before Test
    Setup SimGnb To Trigger RetrieveUeContextReq

Setup Global Vars
    Set Suite Variable     ${TGT_NODE}     ${0}
    Set Suite Variable     ${SRC_NODE}     ${0}

    &{GNB1}=            Create Dictionary    node=0  nrBtsId=1  cellId=1  apId=2  pci=51  nrci=1   nrarfcn=528000  ssbfreq=520110  freqband=41
    Set Suite Variable  ${GNB1}     &{GNB1}
    Set Suite Variable  ${SRC_GNB}  &{GNB1}
    &{GNB2}=            Create Dictionary    node=0  nrBtsId=2  cellId=1  xnIpAddr=10.0.1.7  apId=3  pci=90  nrci=48  nrarfcn=528000
    ...                                      ssbfreq=520110  freqband=41
    Set Suite Variable  ${GNB2}     &{GNB2}
    Set Suite Variable  ${SIM_GNB}  &{GNB2}
    Set Suite Variable  ${TGT_GNB}  &{GNB2}
    &{GNB3}=            Create Dictionary    node=0  nrBtsId=3  cellId=1  xnIpAddr=10.0.1.8  apId=4  pci=90  nrci=64  nrarfcn=397000
    ...                                      ssbfreq=396970  freqband=25
    Set Suite Variable  ${GNB3}     &{GNB3}
    Set Suite Variable  ${OTH_GNB}  &{GNB3}

    Set Suite Variable  @{IP_LIST_eth3_add}  10.0.1.3  10.0.1.4  10.0.1.5  10.0.1.6  ${TGT_GNB['xnIpAddr']}  ${OTH_GNB['xnIpAddr']}
    ...                                      10.0.1.114  10.0.1.115

Setup WTS Cfg
    ${ts_conf_dir}=         Get Test Suite Config Directory
    Copy File               ${tl.core.dir_path}/${tl.core.cfg_filename}   ${ts_conf_dir}/${tl.core.cfg_filename}.orig
    Copy File               ${tl.core.dir_path}/${tl.core.cfg_filename}   ${tl.core.dir_path}/${tl.core.cfg_filename}.orig

    wts_conf.Load Wts Cfg   ${tl.core.dir_path}/${tl.core.cfg_filename}
    wts_conf.Insert         set GNB3_NG_ADDR="10.0.1.3"            after    set GNB_NG_ADDR="10.0.1.2"
    wts_conf.Insert         set GNB4_NG_ADDR="10.0.1.4"            after    set GNB3_NG_ADDR="10.0.1.3"
    wts_conf.Insert         set GNB3_S1U_ADDR="10.0.1.114"         after    set GNB_S1U_ADDR="10.0.1.112"
    wts_conf.Insert         set GNB4_S1U_ADDR="10.0.1.115"         after    set GNB3_S1U_ADDR="10.0.1.114"
    wts_conf.Insert         set GNB3_X2_ADDR="10.0.1.5"            after    set GNB_X2_ADDR="10.0.1.2"
    wts_conf.Insert         set GNB4_X2_ADDR="10.0.1.6"            after    set GNB3_X2_ADDR="10.0.1.5"
    wts_conf.Insert         set GNB3_XN_ADDR="${TGT_GNB['xnIpAddr']}"       after    set GNB4_X2_ADDR="10.0.1.6"
    wts_conf.Insert         set GNB4_XN_ADDR="${OTH_GNB['xnIpAddr']}"       after    set GNB3_XN_ADDR="10.0.1.7"

    wts_conf.Insert         set_gnb id=3 ${SET_SIM_GNB3}           before   set_uec id=1
    wts_conf.Insert         gnb_param id=3 ${SIM_GNB3_PARAM}       after    set_gnb id=${SIM_GNB['apId']}
    wts_conf.Insert         set_cell id=1 ${SET_SIM_GNB3_CELL}     after    gnb_param id=${SIM_GNB['apId']}

    wts_conf.Insert         set_gnb id=4 ${SET_SIM_GNB4}           before   set_uec id=1
    wts_conf.Insert         gnb_param id=4 ${SIM_GNB4_PARAM}       after    set_gnb id=${GNB3['apId']}
    wts_conf.Insert         set_cell id=1 ${SET_SIM_GNB4_CELL}     after    gnb_param id=${GNB3['apId']}

    wts_conf.Modify         set_ue simulated id=1                  modification=nia=null+zuc+aes+snow3g
    wts_conf.Modify         set_ue simulated id=1                  modification=nea=null+zuc+aes+snow3g

    wts_conf.Modify         set_qosflow id=1                       modification=5qi=5
    wts_conf.Modify         set_qosflow id=5                       modification=5qi=6

    Run Keyword And Ignore Error  wts_conf.Delete                  sim_param_set
    wts_conf.Insert         sim_param_set ${DISABLE_CLUBBING}      after    uec_param id=1
    wts_conf.Insert         sim_debug_log level=4 enb=${SIM_GNB['apId']}   before   link_ctrl_param
    wts_conf.Insert         sim_debug_log level=4 enb=4            before   link_ctrl_param
    wts_conf.Insert         sim_trace enb=3 protocol=xn on         before   cfg_end
    wts_conf.Insert         sim_trace enb=4 protocol=xn on         before   cfg_end

    wts_conf.Save Wts Cfg   ${tl.core.dir_path}/${tl.core.cfg_filename}
    wts_conf.Save Wts Cfg   ${tl.core.dir_path}/${tl.core.cfg_filename}.new
    wts_conf.Save Wts Cfg   ${ts_conf_dir}/${tl.core.cfg_filename}

Intra GNB HO
    [arguments]   ${pass_regexp}
    ${meas_ids}                            sqd65_keywords.Get NR Measurement IDs     event_type=A3  ue_id=${UE_ID}  carrier_freq=520110
    Send Egate Command And Verify Output   ue_measurement_send_nr id=${UE_ID} meas_id=${meas_ids}[0] event=A3 srsrp_nr=19 phycell_id=53 nrsrp_nr=100
    ...                                    pass_regexp=${pass_regexp}

Verify Cell Trace
    [arguments]   ${msg_list}
    ${tce_trc_cu}            Collect Trace And Stop TCE      collector=trace_session_cu
    ${tce_trc_pdml}          Convert Nsetapx Trace To PDML   pcap_file=${tce_trc_cu}   pdml_file=trc-gnb-cu  port=${TCE_PORT_NUMBER}
    ${date_time}             DateTime.Get Current Date   result_format=%Y%m%d-%H%M%S
    Copy File                ${tce_trc_cu}    ${tce_trc_cu}_${date_time}.pcap
    Verify Sequence In File  ${tce_trc_pdml}  @{msg_list}
