*** Settings ***
Documentation   This is a keyword file for 5GC000710-C, part wts
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
Library         taf.config.wts    WITH NAME    wts

*** Variables ***

${wts_GNB_XN_ADDR}                    10.0.1.2
${wts_GNB3_XN_ADDR}                   10.0.1.3
${wts_GNB3_NG_ADDR}                   10.0.1.4
${wts_GNB3_CELL3_ADDR}                10.0.1.5
${wts_GNB3_CELL4_ADDR}                10.0.1.6

${cap_plmn1}   SEPARATOR=
...             E1A01000014F5E0302C002074001208367130F8509009B0083FF30C7942C0E09804062280C0298C01283E236B0C6D1D262A08FE59493283
...             40105B260901831E31FF9863CA160703878099D87619D8760A0F809AC31B47498A823F96524CA0D00416C9824060C78C7FE618F28581C0E
...             1E026761D86761D803001800000000388C00000000E020000000041060234046E4D0F80720800000520800001520800002524A000034C02
...             E06DE46D6E900504000025949010000196524040000A594901000039652504000125949090000552CA4802681C5D238BA15134AA22BB102
...             C00F0034020100000000000400801080

${cap_plmn1_lte}   SEPARATOR=
...             E1A01000014F5E0302C002074001208367130F8509009B0083FF30C7942C0E09804062280C0298C00283E236B0C6D1D262A08FE59493283
...             40105B260901831E31FF9863CA160703878099D87619D876008006000000000E2300000000210602372687C0390400000290400000A9040
...             0001292500001A6017036F236B7480282000012CA48080000CB29202000052CA48080001CB29282000092CA48480002A9652401340E2E91
...             C5D0A89A55115D8816007801A0100800000000002004008C5800125


*** Keywords ***

Create ips for simulated gnb
    [Documentation]    [PRIVATE]    create IPs used for WTS
    ...       :Autor: Sylvia Schneider
    Log To Console    \ncreate IPs ${wts_GNB3_XN_ADDR}, ${wts_GNB3_NG_ADDR}, ${wts_GNB3_CELL3_ADDR} and ${wts_GNB3_CELL4_ADDR} on VM eth3
    Configure IP on VM    ip=${wts_GNB3_XN_ADDR}       interface=eth3
    Configure IP on VM    ip=${wts_GNB3_NG_ADDR}       interface=eth3
    Configure IP on VM    ip=${wts_GNB3_CELL3_ADDR}    interface=eth3
    Configure IP on VM    ip=${wts_GNB3_CELL4_ADDR}    interface=eth3
    Log To Console    create IP 10.0.2.2 on VM eth4
    Configure IP on VM    ip=10.0.2.2                  interface=eth4


Update wts file for TC 710C plmn1
    [Documentation]    [PRIVATE]    update wts cfg file for plmn1 usage
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate wts cfg plmn1 ${SCF.mcc}:${SCF.mnc}
    ${wtsconfig}   Get WTS Config    target_dir=${resultBaseDir}
    wts.Load wts cfg             ${wtsconfig}
    wts.Insert    set GNB_XN_ADDR="${wts_GNB_XN_ADDR}"   after   set GNB_NG_ADDR="${wts_GNB_XN_ADDR}"
    wts.Insert    set GNB3_XN_ADDR="${wts_GNB3_XN_ADDR}"   after    set GNB_XN_ADDR="${wts_GNB_XN_ADDR}"
    wts.Insert    set GNB3_NG_ADDR="${wts_GNB3_NG_ADDR}"   after    set GNB3_XN_ADDR="${wts_GNB3_XN_ADDR}"
    wts.Insert    set GNB3_CELL3_ADDR="${wts_GNB3_CELL3_ADDR}"   after   set GNB3_NG_ADDR="${wts_GNB3_NG_ADDR}"
    wts.Insert    set GNB3_CELL4_ADDR="${wts_GNB3_CELL4_ADDR}"   after   set GNB3_CELL3_ADDR="${wts_GNB3_CELL3_ADDR}"
    wts.Insert    set PLMN="${SCF.mcc}:${SCF.mnc}"   after   set PROXY_SERVER_IP="10.0.2.80"
    wts.Modify    set_amf_region   	plmn=$PLMN
    wts.Modify    set_gnb id=2    plmn=$PLMN gnb_id=0x1:22 plmnList=${SCF.mcc}:${SCF.mnc},${SCF.mcc}:388 xn=$GNB_XN_ADDR
    wts.Modify    set_cell id=3 gnb=2     gscn=1582
    wts.Insert    set_gnb id=3 type=simulated plmn=$PLMN ng=$GNB3_NG_ADDR gnb_id=0x26:28   after   set_cell id=1 gnb=2
    wts.Modify    set_gnb id=3    daemon=$DAEMON_IP:$DAEMON_PORT x2_peers=none xn=$GNB3_XN_ADDR amf=1
    wts.Modify    set_gnb id=3    plmnList=${SCF.mcc}:${SCF.mnc},${SCF.mcc}:388 nssai=0x1:0xd143a5
    wts.Insert    set_cell id=1 gnb=3 pci=16:0 tac=${SCF.fiveGsTac} nrci=0x01 tdd_cell=off   after   set_gnb id=3
    wts.Modify    set_cell id=1 gnb=3   proxy=$GNB3_NG_ADDR:9999|$GNB3_NG_ADDR:8890
    wts.Modify    set_cell id=1 gnb=3   nr_arfcn=${SCF.nrarfcnUl}:${SCF.nrarfcnDl} mandatory_for_activation=off gscn=1582
    wts.Insert    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true   after   set_cell id=1 gnb=3
    wts.Insert    set_cell id=2 gnb=3 pci=16:1 tac=${SCF.fiveGsTac} nrci=0x02 tdd_cell=off   after   gnb_param id=3
    wts.Modify    set_cell id=2 gnb=3   proxy=$GNB3_XN_ADDR:9999|$GNB3_XN_ADDR:8891 nr_arfcn=135100:${redirFreqNr-0}
    wts.Modify    set_cell id=2 gnb=3   mandatory_for_activation=off gscn=1573
    wts.Insert    set_cell id=3 gnb=3 pci=15:1 tac=${SCF.fiveGsTac} nrci=0x03 tdd_cell=off   after   set_cell id=2 gnb=3
    wts.Modify    set_cell id=3 gnb=3   proxy=$GNB3_CELL3_ADDR:9999|$GNB3_CELL3_ADDR:8892 nr_arfcn=137200:${redirFreqNr-1}
    wts.Modify    set_cell id=3 gnb=3   mandatory_for_activation=off gscn=1600
    wts.Insert    set_cell id=4 gnb=3 pci=15:2 tac=${SCF.fiveGsTac} nrci=0x04 tdd_cell=off   after   set_cell id=3 gnb=3
    wts.Modify    set_cell id=4 gnb=3	proxy=$GNB3_CELL4_ADDR:9999|$GNB3_CELL4_ADDR:8893 nr_arfcn=167500:${redirFreqNr-2}
    wts.Modify    set_cell id=4 gnb=3	    mandatory_for_activation=off gscn=2204
    wts.Modify    set_ue simulated id=51   suci=0:$PLMN:0000:0:0:021645450
    wts.Modify    set_ue simulated id=52   suci=0:$PLMN:0000:0:0:021645451
    wts.Modify    set_ue simulated id=53   suci=0:$PLMN:0000:0:0:021645452
    wts.Modify    ue_param id=53    ue_nr_capabilities=${cap_plmn1}
    wts.Modify    set_nwslice id=1    ue=all
    wts.Insert    set_nwslice id=2 snssai=0x01:0xD143A6 ue=52 amf=1    after   set_nwslice id=1
    wts.Save wts cfg             	${resultBaseDir}/basic_wts_710C_plmn1.cfg
    Log To Console    wts cfg saved as ${resultBaseDir}/basic_wts_710C_plmn1.cfg


Update wts file for TC 710C plmn2
    [Documentation]    [PRIVATE]    update wts cfg file for plmn2 usage
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate wts cfg plmn2 ${SCF.mcc}:388
    wts.Load wts cfg             ${resultBaseDir}/basic_wts_710C_plmn1.cfg
    wts.Delete    set PLMN="${SCF.mcc}:${SCF.mnc}"
    wts.Insert    set PLMN="${SCF.mcc}:388"   after   set PROXY_SERVER_IP="10.0.2.80"
    wts.Save wts cfg             	${resultBaseDir}/basic_wts_710C_plmn2.cfg
    Log To Console    wts cfg saved as ${resultBaseDir}/basic_wts_710C_plmn2.cfg


Update wts file for TC 710C plmn1 LTE
    [Documentation]    [PRIVATE]    update wts cfg file for plmn1 LTE usage
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate wts cfg plmn1 ${SCF.mcc}:${SCF.mnc} for redirect to LTE
    wts.Load wts cfg             ${resultBaseDir}/basic_wts_710C_plmn1.cfg
    wts.Insert    set DAEMON_IP_2="10.0.2.2"    after    set DAEMON_IP=$CONTAINER_IP
    wts.Modify    set_enb id=1       plmn=$PLMN
    wts.Insert    set_cell id=2 enb=1 eci=0x1234601 pci=3:1 tac=222 proxy=$DAEMON_IP_2:12219|$DAEMON_IP_2:8889    after     set_cell id=1 enb=1
    wts.Modify    set_cell id=2 enb=1     earfcn=1800:19800 mandatory_for_activation=off
    wts.Modify    mme_pool_area id=1      eq_plmn=$PLMN
    wts.Modify    ue_param id=51     ue_nr_capabilities=${cap_plmn1_lte}
    wts.Insert    set_qosflow id=4 5qi=2   after   set_qosflow id=3
    wts.Modify    nwslice_set id=1    qos_flows=1,2,3,4
    wts.Save wts cfg             	${resultBaseDir}/basic_wts_710C_plmn1_LTE.cfg
    Log To Console    wts cfg saved as ${resultBaseDir}/basic_wts_710C_plmn1_LTE.cfg


Load wts file ${used_plmn}
    [Documentation]    [PRIVATE]    load wts for used plmn
    ...       :Autor: Sylvia Schneider
    Upload Customized WTS Config    config_path=${resultBaseDir}/basic_wts_710C_${used_plmn}.cfg


check wts in active state
    [Documentation]    [PRIVATE]    check that wts is in state active
    ...       :Autor: Sylvia Schneider
    Log To Console    \ncheck if wts in active state
    Wait Until Keyword Succeeds    5 min    20 sec    check wts state
    Log To Console    check if wts in active state ended


check wts state
    [Documentation]    [PRIVATE]    check that wts is in state active
    ...       :Autor: Sylvia Schneider
    ute_wtssim.execute egate command and wait for data
    ...    cmd=sim_state_disp
    ...    pass_regexp=The state is ACTIVE   alias=ap_egate

