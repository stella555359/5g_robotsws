*** Settings ***
Documentation
...    author:  susana.yan@nokia-sbell.com
...    contact: susana.yan@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/4cells_2F2T_8pipes
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     H091_Teardown
Force Tags    tl-CLOUD_5G_I_BOO_AP_LOO    release-25R1
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ET.robot

*** Variables ***
${TL_TYPE_PATH}    fddtdd_sansa_cmwv/4cells_2F2T_8pipes
${SYSCOM_FLAG}    True
${rdNumberOfUeCsirsSymbol}    0x580265
${rdCsiRsReconfigCellToUE}    0x590179
${rdMaxNumOfNBRPerCell}     0x590243
@{PARAMS_IN_SWCONFIG}
...    ${rdNumberOfUeCsirsSymbol}=1
...    ${rdCsiRsReconfigCellToUE}=1
...    ${rdMaxNumOfNBRPerCell}=13

${UE_NR_CAP_3CC}    SEPARATOR=
...    E9A09000575F5A13160003C1A00B0498B800CE1E82813641873E618F28581C130080C470
...    0FB8D85181AC1184341020E90186D6C98AB1A1CF88E3D033EC09F1891C790E7D473E639F28581C0E1E0B801FF800E000BE0005800702A
...    0D883AC1184341020F1018656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD8000000B000E0551B1375823
...    08682041D2030C2D931544439F11C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC000B000E0571F11B582308682041F28
...    0C2AB64C55850E7C471E300000000000000000000007809FC0000007F00000002C003801EF0F1340038820000042C040A83C28000E230
...    000010B02B0F11800388200000C2C0AC3C28000E208000010B02B0F13400388C0000042C0AC5C46000E20800710400002858158785000
...    1C4D00000C160562E2680071040038500000102C0AC5C4D000E23000711800001058158B850001C41000E230000020B02B170A0003882
...    001C41000004160562E26800710400388C0000082C0AC5C28000E23000711800001058158B89A001C46000E140000040B02B0F1180038
...    8C00000C2C0803808D00A2026C041074BB07C28913639F0E14489B1CF870A244D8E7C3851226C73E1C28913639F0E2448913639F0E140
...    81B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF810A040D8E7C
...    00170F18C6318C6318C6318C61E8260078005038280381803A01C0018090010180F824008000000040000080200000001000002008000
...    02004000018020000100100000A008004010040100000C0080000700400200000008000080040000480200000C010000140080000B004
...    002048120080000C0339535953582958195833582B594B5933580B581B58095811583B40D04000025949410000196525040000A594901
...    000039652404000125949010000596524040001A594901000079652404000225949010000996524040002A5949010000B965250400032
...    59490100003165240334AAAE955552A8BA55154162A82C55068AA531549A2A80C55028AA4D5541E28282F012A05028140A05028140A05
...    028140A05028140A0502800304040300601002004202004010080600C20100200404030060100C018202018030080600C201002004040
...    300601002004402018030080600C0201803040400802010020086A87C0004080C10181C282C30344044484C5060646C70747C8494989C
...    A0A4A8B4BD05060B40

#N71A_N41A CA ue cap
${UE_NR_CAP}    SEPARATOR=
...    E9A09000575F5A13160003C1A00B0498B800CE1E82813641873E618F28581C130080C4700FB8D85181AC1184341020E90186D6C98AB1A
...    1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE0005800702A0D883AC1184341020F1018656C98AB121CFB0
...    27C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD8000000B000E0551B137582308682041D2030C2D931544439F11C788E3D03
...    3EC09F18E7CC31E50B0381C3C17003FF001C00FFC000B000E0541B11B582308682041E2030CAD931562439F11C7B027C62471E439F51C
...    F9863CA1607038784FFF800003FFE0000016001C00F78789A001C4100000216020541E14000711800000858158788C001C41000006160
...    561E14000710400000858158789A001C46000002160562E2300071040038820000142C0AC3C28000E268000060B02B17134003882001C
...    28000008160562E26800711800388C0000082C0AC5C28000E20800711800001058158B850001C41000E208000020B02B1713400388200
...    1C46000004160562E14000711800388C0000082C0AC5C4D000E2300070A000002058158788C001C46000006160401C046805101360208
...    3A5D83E14489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B1CF871224489B1CF870A040D8E7C08902040D8E7C08902040D8
...    E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C0850206C73E000B878C6318C6318C6318C630F413
...    003C00281C1401C0C01D00E000C0480080C07C120040000000200000401000000008000010040000100200000C0100000800800005004
...    0020080200800006004000038020010000000400004002000024010000060080000A004000058020010240900400006019CA9ACA9AC14
...    AC0CAC19AC15ACA5AC99AC05AC0DAC04AC08AC1DA0682000012CA4A080000CB29282000052CA48080001CB29202000092CA48080002CB
...    292020000D2CA48080003CB29202000112CA48080004CB29202000152CA48080005CB29282000192CA480800018B292019A55574AAAA9
...    545D2A8AA0B154162A83455298AA4D154062A8145526AAA0F1414178095028140A05028140A05028140A05028140A0502814001820201
...    80300801002101002008040300610080100202018030080600C10100C018040300610080100202018030080100220100C018040300601
...    00C01820200401008010043543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A

${UE_MRDC_CAP}    SEPARATOR=
...    A11FF83BC4C0C03850001C46000000162205E260601C4D000E230000000B1102F130300E26800710400000058881789818070A0003882
...    0000002C040BC4C0C03882001C46000002160205E360601C46000E208007104000010580817898180713400385000000C2C040804808D
...    00A001C041809A1E80B907893A244D8E7C3893A244D8E7C3893A244D8E7C3893A244D8E7C3893A24498E7D1A7448912639F449D1224C7
...    3E01A0718C6318C60C02080002010100200804030061000040202004008080600C3000080404030060100C01804030061000040202004
...    010080100400000000

*** Test Cases ***
CB008195_SR_H_UPD003_91_Verify_success_and_unsuccess_NBR_setup_blind_CA_maxnumofNbrBeares_static_cell_limit_check_with_FAF_online_change_and_counter
    [Documentation]
    ...    1. Config:
    ...    [Configuration]:
    ...       set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=on band=n41 chBw=100MHz nr_arfcn=513300:513300 gscn=6480
    ...       set_cell id=12 gnb=2 pci=20:1 tac=200 nrci=0x0C tdd_cell=off band=n71 chBw=10MHz nr_arfcn=136620:127420 gscn=1592
    ...       SA UE1: PLMN 1, nwslice 1
    ...       NSA UE31: PLMN 1
    ...       GNB1: actNbrForNonGbrBearers=true, actEmergencyCall=true, ApplyCellRacForPrivilegedUE=false
    ...             maxNumOfUsersPerCell=20, maxNumOfUsersPerNRCell=20, numOfRadioResReservForEmergency=0
    ...       Cell1: maxNumOfNbrBearers=10, Cell11: maxNumOfNbrBearers=10, Cell12: maxNumOfNbrBearers=10
    ...       Cell1 RG1: minQuota=75, maxQuota=76
    ...       Cell1 RG2: minQuota=14, maxQuota=24
    ...       Cell1 NbrBearers: RG1 [7,7] RG2 [1,2] (maxNumOfNbrBearers*RGQuota)
    ...       Cell12 RG1: minQuota=0, maxQuota=26
    ...       Cell12 RG2: minQuota=24, maxQuota=74
    ...       Cell12 NbrBearers: RG1 [0,2] RG2 [2,7] (maxNumOfNbrBearers*RGQuota)
    ...       Cell paNbrReserveCell=3(rdMaxNumOfNBRPerCell - maxNumOfNbrBearers)
    ...    2. Test Case Steps:
    ...       Step1: Delta commission to enable 8195.
    ...       Step2: UE81 attach to cell1 and pdu session setup with slice2.
    ...       Step3: UE91 attach to cell12 and add scell cell1 with plmn2.
    ...       Step4: UE82 attach to cell1 and pdu session setup with slice2.
    ...       Step5: UE81,82 setup EC pdu with slice2.
    ...       Step6: UE83,UE84 attach to cell1, setup normal and EC pdu session setup with slice2.
    ...       Step7: Delta commission to enable ApplyCellRacForPrivilegedUE.
    ...       Step8: UE85 setup EC pdu with slice2.
     ...      Step9: Delta commission to modify RG1 minquota to 55, maxQuota to 80. RG2 minquota to 14, maxQuota to 24
    ...       Step10: UE1-UE2 attach to cell1, setup one normal pdu and EC pdu session with slice1
    ...       Step11: UE3 attach to cell1 and pdu session setup with slice1.
    ...       Step12: UE4 attach to cell1 and pdu session setup with slice1.
    ...       Step13: UE4 setup EC pdu with slice1.
    ...       Step14: Delta commission to modify RG1 minquota to 75, maxQuota to 80. RG2 minquota to 10, maxQuota to 20
    ...       Step15: UE5 attach to cell1 and pdu session setup with slice1.
    ...       Step16: UE5 setup EC pdu with slice1.
    ...       Step17: check counters
    ...    3. Expected Results:
    ...       Step1: Params can be changed successfully.
    ...       Step2: UE81 bearer is admitted as NBR bearer by CELL1 RG2.
    ...       Step3: UE91 bearer is admitted as NBR bearer by scell CELL1 RG2.
    ...       Step4: UE82 bearer is admitted as NON NBR bearer by CELL1 RG2 due to RG exceed limit.
    ...       Step5: UE81,82 EC bearer is admitted as NBR bearer by CELL1 RG2.
    ...       Step6: only UE83 EC bearer is admitted as NBR bearer by CELL1 RG2.
    ...              ---as maxquota exceed, paNbrReserveCell resource exhausted and ApplyCellRacForPrivilegedUE disabled.
    ...       Step7: Params can be changed successfully.
    ...       Step8: UE85 bearer is admitted as NBR bearer by CELL1 RG2.
    ...       Step9: Online change param successfully.
    ...       Step10: UE1-2 4 bearers are admitted as NBR bearer to reach maxNumOfNbrBearers
    ...       Step11: UE3 bearer is admitted as NBR bearer by CELL1 RG1 due to RG1 minquota not reach limit.
    ...       Step12: UE4 bearer is admitted as non NBR bearer by CELL1 RG1 due to RG1 minquota and maxNumOfNbrBearers exceed.
    ...       Step13: UE4 EC bearer is admitted as NBR bearer by CELL1 RG1 due to rdMaxNumOfNBRPerCell not reach.
    ...       Step14: Online change param successfully.
    ...       Step15: UE5 bearer is admitted as NBR bearer by CELL1 RG1 due to RG1 minquota enlarged.
    ...       Step16: UE5 EC bearer is admitted as non NBR bearer by CELL1 RG1 due to rdMaxNumOfNBRPerCell exceeds limit.
    ...       Step17: counters should be updated as expected.
    [Tags]    091
    Delta Commission Parameters     ${enable8195}
    clear counter files    wait=${False}
    UE Attach and Setup PDU session    ue_id=81    cell=1    pdu=1    nwslice=2    gw=1    nbr=1    #admit NBR--cell1 RG2-sum1
    NSA UE Initial ENDC    ue_id=91    target_cells=12    selected_plmn=311:406    bearer=3    nbr=1    #scell cell1 admit NBR--RG2 reach limit-sum2
    UE Attach and Setup PDU session    ue_id=82    cell=1    pdu=1    nwslice=2    gw=2    nbr=0    #admit nonNBR--cell1 RG2 exceed limit.
    Setup Emergency PDU Session for Multi Ues    ue_start=81    ue_count=2    nwslice=2    gw=3    nbr=1    #admit RG2 NBR--paNbrReserveCell-sum4
    UE Attach Setup Normal PDU and Emergency PDU Sessions    ue_start=83    cell=1    nwslice=2    gw=5    nbr=0    ecnbr=1    #admit EC RG2 NBR-sum5
    UE Attach Setup Normal PDU and Emergency PDU Sessions    ue_start=84    cell=1    nwslice=2    gw=7    nbr=0    ecnbr=0    #admit nonNBR
    Delta Commission Parameters     ${enableApplyCellRacForPrivilegedUEEC}
    UE Attach Setup Normal PDU and Emergency PDU Sessions    ue_start=85    cell=1    nwslice=2    gw=9    nbr=0    ecnbr=1    #admit EC RG2 NBR-sum6
    Delta Commission Parameters     ${Reducecell1RG1Quota}
    UE Attach Setup Normal PDU and Emergency PDU Sessions    ue_start=1    ue_count=2    cell=1    nwslice=1    gw=11    nbr=1    #admit RG1 NBR-sum10
    UE Attach and Setup PDU session    ue_id=3    cell=1    pdu=1    nwslice=1    gw=15    nbr=1    #admit NBR-->RG1 minquota reach---sum11
    UE Attach and Setup PDU session    ue_id=4    cell=1    pdu=1    nwslice=1    gw=16    nbr=0    #admit nonNBR---RG1 minquota NBR exceed
    Setup Emergency PDU Session    ue_id=4    pdu=2    nwslice=1    gw=17    priority=1    nbr=1    #admit NBR---rdMaxNumOfNBRPerCell not reach-sum12
    Delta Commission Parameters     ${Increasecell1RG1Quota}
    UE Attach and Setup PDU session    ue_id=5    cell=1    pdu=1    nwslice=1    gw=18    nbr=1    #admit NBR---RG1 minquota NBR+1---sum13
    Setup Emergency PDU Session    ue_id=5    pdu=2    nwslice=1    gw=19   priority=1    nbr=0    #admit nonNBR---rdMaxNumOfNBRPerCell exceed
    Check Counters    pm_counters_expression=${PM_Counters_H091}
    Release Ues    ue_type=all

*** Keywords ***
Modify Cfg
    ${cell_1}    catenate    set_cell id=1 gnb=2 pci=16:2 tac=0 nrci=0x01 tdd_cell=on
    ...    proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nr_arfcn=510000:510000 gscn=6372 mandatory_for_activation=off
    Update Cfg    ${cell_1}
    ${cell_2}    catenate    set_cell id=2 gnb=2 pci=17:0 tac=0 nrci=0x02 tdd_cell=on
    ...    proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nr_arfcn=528000:528000 gscn=6597 mandatory_for_activation=off
    Update Cfg    ${cell_2}
    ${cell_11}    catenate    set_cell id=11 gnb=2 pci=20:0 tac=0 nrci=0x0B tdd_cell=off
    ...    proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nr_arfcn=137780:128580 gscn=1599 mandatory_for_activation=off
    Update Cfg    ${cell_11}
    ${cell_12}    catenate    set_cell id=12 gnb=2 pci=20:1 tac=0 nrci=0x0C tdd_cell=off
    ...    proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nr_arfcn=134200:125020 gscn=1562 mandatory_for_activation=off
    Update Cfg    ${cell_12}
    Update Cfg    set_qosflow id=1 5qi=6 priority=1 default=off
    Update Cfg    set_qosflow id=2 5qi=8 default=on
    Update Cfg    ue_param id=91 ue_nr_capabilities=${UE_NR_CAP} dual_conn=eutra_nr ue_eutra_nr_capabilities=${UE_MRDC_CAP}
    Update Cfg    set_bearer id=3 ue=91 qci=8 pdn=1 preprovisioned=on filter=2 precedence=2
    Update Cfg    ue_param id=81 nr_usage_setting=voice_centric
    Update Cfg    ue_param id=82 nr_usage_setting=voice_centric
    Update Cfg    ue_param id=83 nr_usage_setting=voice_centric
    Update Cfg    ue_param id=84 nr_usage_setting=voice_centric
    Update Cfg    ue_param id=85 nr_usage_setting=voice_centric
    Update Cfg    ue_param id=1 nr_usage_setting=voice_centric
    Update Cfg    ue_param id=2 nr_usage_setting=voice_centric
    Update Cfg    ue_param id=3 nr_usage_setting=voice_centric
    Update Cfg    ue_param id=4 nr_usage_setting=voice_centric
    Update Cfg    ue_param id=5 nr_usage_setting=voice_centric
    Update Cfg    ue_param id=6 nr_usage_setting=voice_centric
    Update Cfg    ue_nr_capabilities id=81 voice_over_nr=on:on:off
    Update Cfg    ue_nr_capabilities id=82 voice_over_nr=on:on:off
    Update Cfg    ue_nr_capabilities id=83 voice_over_nr=on:on:off
    Update Cfg    ue_nr_capabilities id=84 voice_over_nr=on:on:off
    Update Cfg    ue_nr_capabilities id=85 voice_over_nr=on:on:off
    Update Cfg    ue_nr_capabilities id=1 voice_over_nr=on:on:off
    Update Cfg    ue_nr_capabilities id=2 voice_over_nr=on:on:off
    Update Cfg    ue_nr_capabilities id=3 voice_over_nr=on:on:off
    Update Cfg    ue_nr_capabilities id=4 voice_over_nr=on:on:off
    Update Cfg    ue_nr_capabilities id=5 voice_over_nr=on:on:off
    Update Cfg    ue_nr_capabilities id=6 voice_over_nr=on:on:off
    Update Cfg    ue_param id=81 ue_nr_capabilities=${UE_NR_CAP_3CC}
    Update Cfg    ue_param id=82 ue_nr_capabilities=${UE_NR_CAP_3CC}
    Update Cfg    ue_param id=83 ue_nr_capabilities=${UE_NR_CAP_3CC}
    Update Cfg    ue_param id=84 ue_nr_capabilities=${UE_NR_CAP_3CC}
    Update Cfg    ue_param id=85 ue_nr_capabilities=${UE_NR_CAP_3CC}
    Update Cfg    ue_param id=1 ue_nr_capabilities=${UE_NR_CAP_3CC}
    Update Cfg    ue_param id=2 ue_nr_capabilities=${UE_NR_CAP_3CC}
    Update Cfg    ue_param id=3 ue_nr_capabilities=${UE_NR_CAP_3CC}
    Update Cfg    ue_param id=4 ue_nr_capabilities=${UE_NR_CAP_3CC}
    Update Cfg    ue_param id=5 ue_nr_capabilities=${UE_NR_CAP_3CC}
    Update Cfg    ue_param id=6 ue_nr_capabilities=${UE_NR_CAP_3CC}
    Update Cfg    set_amf_region id=1 tac_list=0,200 plmn=311:489,311:406
    Update Cfg    set_nwslice id=1 snssai=0x01:13714341 default=on ue=all amf_region_id=1 plmn_list=311:489,311:406
    Update Cfg    set_nwslice id=2 snssai=0x01:13714342 ue=all amf_region_id=1 plmn_list=311:489,311:406
    Update Cfg    set_nwslice id=3 snssai=0x01:13714343 ue=all amf_region_id=1 plmn_list=311:489,311:406

H091_Teardown
    Delta Commission Parameters    ${RGQuotaRecover}
    Common Test Teardown And Stop Capture Logs

NSA UE Initial ENDC
    [Arguments]    ${ue_id}=91    ${target_cells}=12    ${selected_plmn}=311:489    ${pass_regexp}=Successfully reconfigured dual connectivity
    ...    ${bearer}=2    ${nbr}=1
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    enb_endc_param id=1 selected_plmn=${selected_plmn}
    Start To Capture Wireshark Log    ue${ue_id}_bearer${bearer}setup
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg
    ...    pass_regexp=${pass_regexp}
    Send Traffic NSA    ue_id=${ue_id}
    stop_capture_wireshark_log
    check_num_of_wireshark_as_excepted    ${SAVE LOG DIRECTORY}${/}/wireshark_ue${ue_id}_bearer${bearer}setup.pcap
    ...    itf_l2_ps_CellConfigParam_t.nrCellIdentity == 16385 && itf_l2_ps_NbrDrbSpecificParams.nbrDl_item == 200 @${nbr}

Setup PDU Session
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${nwslice}=1    ${gw}=1    ${pass_regexp}=${EMPTY}
    execute egate command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    execute egate command    ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=${nwslice} gw=${gw}    ${pass_regexp}

Setup Emergency PDU Session
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${nwslice}=1    ${gw}=1    ${pass_regexp}=Setup QosFlow with QFI:1 fiveQI:6    ${priority}=1    ${nbr}=1
    Execute Egate Command    qosflow_modify qos_flow=1 priority=${priority} default=on
    Execute egate command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    Start To Capture Wireshark Log    ue${ue_id}_pdu${pdu}ECsetup
    Execute egate command    ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=${nwslice} gw=${gw}    ${pass_regexp}
    Execute Egate Command    qosflow_modify qos_flow=2 priority=15 default=on
    stop_capture_wireshark_log
    check_num_of_wireshark_as_excepted    ${SAVE LOG DIRECTORY}${/}/wireshark_ue${ue_id}_pdu${pdu}ECsetup.pcap
    ...    itf_l2_ps_user_bearersetupreq && itf_l2_ps_DrbAddReqPs.nbrDrbSpecificParams.Length == ${nbr} @1

Setup Emergency PDU Session for Multi Ues
    [Arguments]    ${ue_start}=1    ${nwslice}=1    ${gw}=1    ${ue_count}=3    ${nbr}=1
    FOR    ${i}    IN RANGE    0    ${ue_count}
        ${ue_id}    Evaluate    ${ue_start}+${i}
        ${gw_id}    Evaluate    ${gw}+${i}
        Setup Emergency PDU Session    ue_id=${ue_id}    pdu=2    nwslice=${nwslice}    gw=${gw_id}    nbr=${nbr}    priority=2
        ...    pass_regexp=Setup QosFlow with QFI:1 fiveQI:6
    END

UE Attach Setup Normal PDU and Emergency PDU Sessions
    [Arguments]    ${ue_start}=1    ${ue_count}=1    ${cell}=1    ${nwslice}=1    ${gw}=1    ${nbr}=1    ${ecnbr}=1
    FOR    ${i}    IN RANGE    0    ${ue_count}
        ${ue_id}    Evaluate    ${ue_start}+${i}
        ${gw_id}    Evaluate    ${gw}+2*${i}
        ${gw_id2}       Evaluate    ${gw}+2*${i}+1
        UE Attach and Setup PDU session    ue_id=${ue_id}    cell=${cell}    pdu=1    nwslice=${nwslice}    gw=${gw_id}    nbr=${nbr}
        ...    pass_regexp=Setup QosFlow with QFI:1 fiveQI:8
        Setup Emergency PDU Session    ue_id=${ue_id}    pdu=2    nwslice=${nwslice}    gw=${gw_id2}    priority=1    nbr=${ecnbr}
        ...    pass_regexp=Setup QosFlow with QFI:1 fiveQI:6
    END

UE Attach and Setup PDU session
    [Arguments]    ${ue_id}=1    ${cell}=1    ${pdu}=1    ${nwslice}=1    ${gw}=1    ${nbr}=1    ${pass_regexp}=Setup QosFlow with QFI:1 fiveQI:8
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell}
    Execute Egate Command    qosflow_modify qos_flow=2 priority=15 default=on
    Start To Capture Wireshark Log    ue${ue_id}_pdu${pdu}setup
    Execute Egate Command    ue_register id=${ue_id}     pass_regexp=Received REGISTRATION COMPLETE
    Setup PDU Session    ue_id=${ue_id}    pdu=${pdu}    nwslice=${nwslice}    gw=${gw}    pass_regexp=${pass_regexp}
    Send Traffic SA    ue_id=${ue_id}
    stop_capture_wireshark_log
    check_num_of_wireshark_as_excepted    ${SAVE LOG DIRECTORY}${/}/wireshark_ue${ue_id}_pdu${pdu}setup.pcap
    ...    itf_l2_ps_user_bearersetupreq && itf_l2_ps_DrbAddReqPs.nbrDrbSpecificParams.Length == ${nbr} @1

Send Traffic SA
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 dir=dl mbps=1 trf_id=1    pass_regexp=Started Downlink Internal traffic

Send Traffic NSA
    [Arguments]    ${ue_id}=31
    Execute Egate Command    trf_data_start id=2 ue=${ue_id} dir=dl mbps=1

