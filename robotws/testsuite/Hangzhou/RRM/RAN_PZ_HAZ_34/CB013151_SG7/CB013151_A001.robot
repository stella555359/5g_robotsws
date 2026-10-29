*** Settings ***
Documentation
...    author:  dandan.chen@nokia-sbell.com
...    contact: dandan.chen@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup Airphone Env    tl_type=fddtdd_sansa_cmwv_tmo_65    ue_count=100
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        release-SBTS26R2    tl-CLOUD_5G_I_LOO_AP_LOOO
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ET.robot
*** Variables ***
${SYSCOM_FLAG}    true
@{FAULTS_EXCLUDED_CHECKING}    8000
@{pucchF1ResOccConf_3_3_0_occ}
...    NRCELL-1:pucchF1ResOccConf=3-3-0_OCCs
...    NRCELL-2:pucchF1ResOccConf=3-3-0_OCCs

@{pucchF1ResOccConf_2_2_0_occ}
...    NRCELL-1:pucchF1ResOccConf=2-2-0_OCCs
...    NRCELL-2:pucchF1ResOccConf=2-2-0_OCCs

${cell1_UE1}    SEPARATOR=
...    nr-rrc.startingPRB == 243 && nr-rrc.pucch_ResourceId == 0 &&
...    nr-rrc.initialCyclicShift == 0 && nr-rrc.timeDomainOCC == 0 &&
...    nr-rrc.initialCyclicShift == 0 && nr-rrc.timeDomainOCC == 1

${cell1_UE18}    SEPARATOR=
...    nr-rrc.startingPRB == 243 && nr-rrc.pucch_ResourceId == 0 &&
...    nr-rrc.initialCyclicShift == 11 && nr-rrc.timeDomainOCC == 2 &&
...    nr-rrc.initialCyclicShift == 0 && nr-rrc.timeDomainOCC == 0 &&
...    nr-rrc.startingPRB == 2 && nr-rrc.pucch_ResourceId == 0

${cell2_UE1}    SEPARATOR=
...    nr-rrc.startingPRB == 1 && nr-rrc.pucch_ResourceId == 0 &&
...    nr-rrc.initialCyclicShift == 0 && nr-rrc.timeDomainOCC == 0 &&
...    nr-rrc.initialCyclicShift == 1 && nr-rrc.timeDomainOCC == 1

${cell2_UE18}    SEPARATOR=
...    nr-rrc.startingPRB == 1 && nr-rrc.pucch_ResourceId == 0 &&
...    nr-rrc.initialCyclicShift == 10 && nr-rrc.timeDomainOCC == 2 &&
...    nr-rrc.initialCyclicShift == 0 && nr-rrc.timeDomainOCC == 0 &&
...    nr-rrc.startingPRB == 243 && nr-rrc.pucch_ResourceId == 0

${CA_UE_CAP}
...    E1A03E00474F7AEF7FFFAF084000F05C0407824F7CFFFFFF002600C6F3E00050370300FC7016A2F831EF13843B102087E5068020B65474031
...    27D620F2107840A12DF3F013FF0FC000FFC3F0000BC0001C00140A8BE147BC4E10EC40821F941A0082D951D00C49F5883C841E10284B7CFC0
...    2EEE3BE003BB8EF8002F500070005001B2800028000001000200002A2F85FEF13843B102087E5068020B6547403127D620F2107840A12DF3F
...    013F9EE7800FE7B9E000BC0001C00140A8BE20FBC4E10EC40821F941A0082D951D00C49F5883C841E10284B7CFC04FFC3F0003FF0FC0002F0
...    0007000502A2F88DEF13843B102087E5068020B6547403127D620F2107840A12DF3F0108002000BC0001C00140A8BE267BC4E10EC40821F94
...    1A0082D951D00C49F5883C841E10284B7CFC0220008002F500070005001B28000280000010002000003143E0C00061180E1400070A0000001
...    E89D50703007118000009E89D50785000184600011E89D50705007118000019E89D507850001C460000087A27541E230006118000A7A27540
...    E140400063113AA0F06000305000073D13AA0E0600E140000083D13AA0F060003850000024F44EA83C28000C1400028C44FA83C18000C0C00
...    02CF44E802808D00A200C0BB104683234E9D0206C93E1C29D3B649F021469DB24F810A74ED927C0850A76C93E0429D3B649F02046D927C085
...    3A76C93E0429D1B649F0214E81B24F810A34ED927C0853A76C93E0009860C6318C6318C63180F81812090C82412090C82432090C8240180FE
...    6000005E007C0050006038280381884E00E000E000C07C0B104000000820000044100000420800003104000020820000144100000C2080000
...    710400202008208004040144100080A020820010140501D8335933581B591B583B79535819591940704000025965010000196594040000A59
...    6501000039659404000125965410000596595040001A596501000079659401D41A2A93455038AA471541EAE95555078BA55142C02100BF058
...    3C160F0583C160F0783C16000058C1C0080180100300400A008010380300100800200C004020000100C018040300608380100100200200800
...    4010000700600E0100240180380400810700A01601402C0300680600C0E00C0040200080300100800020E0140040280080600100C0001C018
...    0380400900600E01002041C0280780500F00C022018040380300700801200C01C0200408380700700E00E020024040040700E002020004038
...    0080800000701201602802C0580680C00C10700200600400C010028020040E0140040300080500100C00020E004004008008020010040001C
...    0280580600D00A01601803041C0080180100300400A008010380500F00C02201403C0300808380500B00A016018034030060700A002018004
...    0280080600010700200600400C010028020040E0040040100080100100400042C1C040C102C60BD0519DC000000080
*** Test Cases ***
CB013151_A001_Verify Activation with 3-3-0_OCCs for HARQ AN 1170 frame structure 90M Single BWP SANSA multiple UE
    [Documentation]
    ...    CELL-1 framestructure 1170 semi ulDlDataSlotRatio 1/4  90M phycellid-50
    ...    CELL-2 framestructure 1170 semi ulDlDataSlotRatio 1/4  90M phycellid-51
    ...    pucchsize=PRB(SR)+PRB(HARQ_AN)+k*PRB(pCSI)=2+8+8=18
    ...    SR PRB:(0,244) slot:(4,9,14,19)
    ...    HARQ PRB:(1,2,3,4,243,242,241,240)
    ...    CSI PRB:(5,6,7,8,239,238,237,236) slot:(4,9,14,19)
    ...    cell-1 HARQ OCC:0 CS:(0,2,4,6,8,10) OCC:1 CS:(0,2,4,6,8,10) OCC:2 CS:(1,3,5,7,9,11)
    ...    cell-2 HARQ OCC:0 CS:(0,2,4,6,8,10) OCC:1 CS:(1,3,5,7,9,11) OCC:2 CS:(0,2,4,6,8,10)
    ...    [step]:
    ...       a. with 3_3_0_occ, one SA ue attach to cell-1 cell-2, check traffic is ok
    ...       b. with 3_3_0_occ, one NSA ue attach to cell-1 cell-2, check traffic is ok
    ...       c. lock and unlock cell-1 and cell-2, check pucchsize
    ...       d. attach many UEs without pdu, check pucch resource of cell-1 cell-2
    ...       f. online pucchF1ResOccConf_3_3_0_occ
    ...       g. attach many UEs with pdu, check pucch resource of cell-1 cell-2
    [Tags]    A001
    Online Change And Wait Cell Onair    ${pucchF1ResOccConf_3_3_0_occ}
    ONE SA UE with traffic
    ONE NSA UE with traffic
    Lock And Unlock cell to make sure UE position no change And Check Pucch Size    cell_id=1    pucchsize=18
    Lock And Unlock cell to make sure UE position no change And Check Pucch Size    cell_id=2    pucchsize=18
    Attach Multi UEs And Check PUCCH Resource For Cell And Then Release All UEs    cell_id=1    ue_count=99
    Attach Multi UEs And Check PUCCH Resource For Cell And Then Release All UEs    cell_id=2    ue_count=99
    Online Change And Wait Cell Onair    ${pucchF1ResOccConf_2_2_0_occ}
    Online Change And Wait Cell Onair    ${pucchF1ResOccConf_3_3_0_occ}
    UE attach and release and attach again on cell-1    cell_id=1
    UE attach and release and attach again on cell-2    cell_id=2

*** Keywords ***
Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=none    ${ue_id}=1
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

UE attach and release and attach again on cell-1
    [Arguments]    ${cell_id}=1
#    Start To Capture Gnb Ttitrace    tag=Test_N2${cell_id}    cell_id=${cell_id}
    object should exist    NRCELL-${cell_id}:pucchConfig:pucchSize=18
    Start To Capture Wireshark Log    cell${cell_id}_UE1
    Register For Normal Call Successfully with pdu    ue_id=1    cell_id=${cell_id}
    stop capture wireshark log    cell${cell_id}_UE1
    ${number}=    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}${/}wireshark_cell${cell_id}_UE1.pcap    ${cell1_UE1}
    Should Be True    ${number}>1
    Multi SA UE attach with traffic    cell_id=${cell_id}    ue_id_start=2    ue_id_end_before=18
    Start To Capture Wireshark Log    cell${cell_id}_UE18
    Register For Normal Call Successfully with pdu    ue_id=18    cell_id=${cell_id}
    stop capture wireshark log    cell${cell_id}_UE18
    ${number}=    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}${/}wireshark_cell${cell_id}_UE18.pcap    ${cell1_UE18}
    Should Be True    ${number}>1
    Start To Capture Wireshark Log    cell${cell_id}_N2
    Multi SA UE attach with traffic    cell_id=${cell_id}    ue_id_start=19    ue_id_end_before=61
    Multi NSA UE attach with traffic    cell_id=${cell_id}
    check active SA UE
    check active NSA UE
    release SA UE30-60
    Multi SA UE attach with traffic    cell_id=${cell_id}    ue_id_start=30    ue_id_end_before=61
    check active SA UE    ue_id_start=30    ue_id_end_before=61
    Check Pucch Resource    92    cell${cell_id}_N2
    Release Ues    ue_type=all
    Run keyword and ignore error    Release ues    ue_type=all
#    Stop Capture Gnb Ttitrace    tag=Test_N2${cell_id}

UE attach and release and attach again on cell-2
    [Arguments]    ${cell_id}=1
    object should exist    NRCELL-${cell_id}:pucchConfig:pucchSize=18
    Start To Capture Wireshark Log    cell${cell_id}_UE1
    Register For Normal Call Successfully with pdu    ue_id=1    cell_id=${cell_id}
    stop capture wireshark log    cell${cell_id}_UE1
    ${number}=    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}${/}wireshark_cell${cell_id}_UE1.pcap    ${cell2_UE1}
    Should Be True    ${number}>1
    Multi SA UE attach with traffic    cell_id=${cell_id}    ue_id_start=2    ue_id_end_before=18
    Start To Capture Wireshark Log    cell${cell_id}_UE18
    Register For Normal Call Successfully with pdu    ue_id=18    cell_id=${cell_id}
    stop capture wireshark log    cell${cell_id}_UE18
    ${number}=    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}${/}wireshark_cell${cell_id}_UE18.pcap    ${cell2_UE18}
    Should Be True    ${number}>1
    Start To Capture Wireshark Log    cell${cell_id}_N2
    Multi SA UE attach with traffic    cell_id=${cell_id}    ue_id_start=19    ue_id_end_before=61
    Multi NSA UE attach with traffic    cell_id=${cell_id}
    check active SA UE
    check active NSA UE
    release SA UE30-60
    Multi SA UE attach with traffic    cell_id=${cell_id}    ue_id_start=30    ue_id_end_before=61
    check active SA UE    ue_id_start=30    ue_id_end_before=61
    Check Pucch Resource    92    cell${cell_id}_N2
    Release Ues    ue_type=all
    Run keyword and ignore error    Release ues    ue_type=all

check active SA UE
    [Arguments]    ${ue_id_start}=1    ${ue_id_end_before}=61
    FOR    ${i}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
        ${cell_tputdl}    Execute Egate Command    ue_stats_nr id=${i} scell=0-7 type=pdsch    Throughput
        ${cell_tputul}    Execute Egate Command    ue_stats_nr id=${i} scell=0-7 type=pusch    Throughput
    END

check active NSA UE
    [Arguments]    ${ue_id_start}=101    ${ue_id_end_before}=133
    FOR    ${i}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
        ${cell_tputdl}    Execute Egate Command    ue_stats_nr id=${i} scell=8-9 type=pdsch    Throughput
        ${cell_tputul}    Execute Egate Command    ue_stats_nr id=${i} scell=8-9 type=pusch    Throughput
    END

release SA UE30-60
    FOR    ${ue_id}    IN RANGE    30    61
        Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off
    END

ONE SA UE with traffic
    Register For Normal Call Successfully with pdu    ue_id=1    cell_id=1
    start more traffic and verify traffic for SA call
    Trigger RRCReestablishment    ue_id=1    cell_id=1    RRE_check=rrcReestablishmentComplete
    Release Ues    ue_type=all
    Register For Normal Call Successfully with pdu    ue_id=1    cell_id=2
    start more traffic and verify traffic for SA call
    Trigger RRCReestablishment    ue_id=1    cell_id=2    RRE_check=rrcReestablishmentComplete
    Release Ues    ue_type=all

Verify Throughput
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${Tput_dl}=200    ${Tput_ul}=16
    sleep    10s    #wait throughput
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=ul    rate_type=ave
    ${scell_tputdl}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    ${scell_tputul}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pusch    Throughput
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Verify NSA dl Throughput For DL
    [Arguments]    ${ue_id}=101    ${total_dl_tput}=150    ${total_ul_tput}=10
    ${pcell_dl}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pdsch    rate_type=ave
    ${scell_tputdl}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=8-10 type=pdsch    Throughput
    ${scell_tputul}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=8-10 type=pusch    Throughput
    Should Be True    ${pcell_dl}/1000 > 0
    ${pcell_ul}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pusch    rate_type=ave
    Should Be True    ${pcell_dl}/1000>${total_dl_tput}
    Should Be True    ${pcell_ul}/1000>${total_ul_tput}


start more traffic and verify traffic for SA call
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=20 trf_id=10    UE ${ue_id}: UDP UL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=175 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=175 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=175 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=175 trf_id=5    UE ${ue_id}: UDP DL
    Wait Until Keyword Succeeds    60s    10s    Verify Throughput    Tput_dl=650    Tput_ul=15

Trigger RRCReestablishment
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${RRE_check}=RRC
    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${cell_id} cause=reconfigurationFailure    pass_regexp=${RRE_check}
    Wait Until Keyword Succeeds    60s    10s    Verify Throughput    Tput_dl=650    Tput_ul=18

start more traffic and verify traffic for NSA call
    [Arguments]    ${ue_id}=101
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=ul mbps=20 trf_id=10
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=175 trf_id=2
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=175 trf_id=3
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=175 trf_id=4
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=175 trf_id=5
    Wait Until Keyword Succeeds    60s    10s    Verify NSA dl Throughput For DL    ue_id=${ue_id}    total_dl_tput=650    total_ul_tput=15

ONE NSA UE with traffic
    UE Attach To ENB And Set ENDC with traffic    ue_id=101    cell_id=1
    start more traffic and verify traffic for NSA call
    Release Ues    ue_type=all
    UE Attach To ENB And Set ENDC with traffic    ue_id=101    cell_id=2
    start more traffic and verify traffic for NSA call
    Release Ues    ue_type=all

Multi SA UE attach with traffic
    [Arguments]    ${cell_id}=1    ${ue_id_start}=2    ${ue_id_end_before}=61
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
        Register For Normal Call Successfully with pdu    ${ue_id}    ${cell_id}
    END

Multi NSA UE attach with traffic
    [Arguments]    ${cell_id}=1    ${ue_id_start}=101    ${ue_id_end_before}=133
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
        UE Attach To ENB And Set ENDC with traffic    ${ue_id}    ${cell_id}
    END

UE Attach To ENB And Set ENDC with traffic
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_attach id=${ue_id} profile=1    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${cell_id} bearer=2 type=split_scg    reported successful RA
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=10 trf_id=2
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=ul mbps=1 trf_id=1
    sleep    2s

Register For Normal Call Successfully with pdu
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${pdu_id}=1    ${gw_id}=1
    Update UE capa    ${CA_UE_CAP}    ${ue_id}
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id}    ${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Reg
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id}
    ...    QoS Routing Table
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=1 trf_id=1    UE ${ue_id}: UDP DL

Lock And Unlock cell to make sure UE position no change And Check Pucch Size
    [Arguments]    ${cell_id}=1    ${pucchsize}=18
    lock NRCell${cell_id}
    Unlock NRCell${cell_id}
    Cells Should Be Onair    ${cell_id}
    object should exist    NRCELL-${cell_id}:pucchConfig:pucchSize=${pucchsize}

Online Change And Wait Cell Onair
    [Arguments]    ${parameters}
    delta commission parameters    ${parameters}
    Cells Should Be Onair    cell_id=1
    Cells Should Be Onair    cell_id=2

Register For Normal Call Successfully
  [Arguments]    ${ue_id}    ${cell_id}
  Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id}    ${cell_id}
  Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Reg

Register For Number Of Normal Calls
    [Arguments]    ${cell_id}    ${ue_id_start}    ${ue_id_end_before}
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
        Register For Normal Call Successfully    ${ue_id}    ${cell_id}
    END

UE Attach To ENB And Set ENDC
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_attach id=${ue_id} profile=1    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${cell_id} bearer=2 type=split_scg    reported successful RA

Attach And Set ENDC For Number Of Normal Calls
    [Arguments]    ${cell_id}    ${ue_id_start}    ${ue_id_end_before}
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
        UE Attach To ENB And Set ENDC    ${ue_id}    ${cell_id}
    END

Check PUCCH Size For Cell
    [Arguments]    ${cell_id}    ${pucchsize}
    object should exist    NRCELL-${cell_id}:pucchConfig:pucchSize=${pucchsize}

Attach Multi UEs And Check PUCCH Resource For Cell And Then Release All UEs
    [Arguments]    ${cell_id}    ${ue_count}
    Start To Capture Wireshark Log    cell${cell_id}
    Register For Number Of Normal Calls    cell_id=${cell_id}    ue_id_start=1    ue_id_end_before=31
    Register For Number Of Normal Calls    cell_id=${cell_id}    ue_id_start=31    ue_id_end_before=61
    Attach And Set ENDC For Number Of Normal Calls    cell_id=${cell_id}    ue_id_start=101    ue_id_end_before=131
    Register For Number Of Normal Calls    cell_id=${cell_id}    ue_id_start=61    ue_id_end_before=${ue_count}+1
    Check Pucch Resource    ${ue_count}    cell${cell_id}
    Release Ues    ue_type=all
    Run keyword and ignore error    Release ues    ue_type=all
