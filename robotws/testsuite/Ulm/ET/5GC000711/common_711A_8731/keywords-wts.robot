*** Settings ***
Documentation   This is a keyword file part wts
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
Library     taf.config.wts     WITH NAME    wts

*** Variables ***
${cap}    SEPARATOR=
...       e1a00000074e5a031e000380a03c1260c80008780818806804c020301c032a36146b04050d012cb2898087ad8202020e1de38720c38002064f1
...       f570004f001c0013c002a36266b04050d012cb2898087ad8202020e1de38720c38002064f1f570004f001c0013c002a3626eb04050d012cb289
...       8087ad8202020e1de38720c38002064f1f570004f001c0013c002a36276b04050d012cb2898087ad8202020e1de38720c38002064f1f5500000
...       5000000108389a00000000404d0103804044f60701800140e020381801c07000683e0000000000000e54d000100000965950034aaa8081c002c
...       000000100200462c4c0004080c1014181c202c4044484c648494989ca128

*** Keywords ***

Create ips for simulated gnb
    [Documentation]    [PRIVATE]    create IPs used for WTS
    ...       :Autor: Sylvia Schneider
    Log To Console    \ncreate IPs 10.0.1.3, 10.0.1.4, 10.0.1.5, 10.0.1.6, 10.0.1.7 and 10.0.1.121 on VM eth3
    Configure IP on VM    ip=10.0.1.3        interface=eth3
    Configure IP on VM    ip=10.0.1.4        interface=eth3
    Configure IP on VM    ip=10.0.1.5        interface=eth3
    Configure IP on VM    ip=10.0.1.6        interface=eth3
    Configure IP on VM    ip=10.0.1.7        interface=eth3
    Configure IP on VM    ip=10.0.1.121      interface=eth3


Load wts file
    [Documentation]    [PRIVATE]    load wts
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${wts_file}
    Upload Customized WTS Config    config_path=${resultBaseDir}/${wts_file}.cfg


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


Update wts file for TC 711A
    [Documentation]    [PRIVATE]    update wts cfg file for 711-A
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate wts
    ${wtsconfig}   Get WTS Config    target_dir=${resultBaseDir}
    wts.Load wts cfg             ${wtsconfig}
    wts.Insert  set GNB_XN_ADDR="10.0.1.2"    after    set GNB_NG_ADDR="10.0.1.2"
    wts.Insert  set GNB4_NG_ADDR="10.0.1.3"   after    set GNB_XN_ADDR="10.0.1.2"
    wts.Insert  set GNB4_S1_ADDR="10.0.1.4"   after    set GNB4_NG_ADDR="10.0.1.3"
    wts.Insert  set GNB4_XN_ADDR="10.0.1.5"   after    set GNB4_S1_ADDR="10.0.1.4"

    wts.Delete  set ENB1_X2_ADDR="10.0.1.137"
    wts.Insert  set ENB1_X2_ADDR="10.0.1.121"    after    set GNB_S1U_ADDR="10.0.1.112"

    wts.Delete  set_enb id=1
    wts.Delete  enb_param id=1
    wts.Delete  set_cell id=1 enb=1
    wts.Delete  enb_endc_param id=1

    wts.Delete  mme_pool_area id=1
    wts.Delete  set_mme id=1
    wts.Delete  set_sgw id=1
    wts.Delete  set_pgw id=1

    wts.Modify  set_gnb id=2    gnb_id=0x1:22 xn=$GNB_XN_ADDR

    wts.Insert  set_gnb id=4 type=simulated plmn=311:489 ng=$GNB4_NG_ADDR daemon=$SERVER_IP:$DAEMON_PORT     after   set_cell id=2 gnb=2
    wts.Modify  set_gnb id=4   gnb_id=0x12:28 nssai=0x01:0xD143A5 x2_peers=none xn=$GNB4_XN_ADDR
    wts.Insert  set_cell id=1 gnb=4 pci=3:2 earfcn=2000:20000 tac=200 proxy=$GNB4_NG_ADDR:12219 nrci=0x1     after   set_gnb id=4
    wts.Modify  set_cell id=1 gnb=4   tdd_cell=on bw=20MHz technology=lte mandatory_for_activation=off
    wts.Insert  gnb_param id=4 xn_listening_socket=1 send_xn_setup=false     after   set_cell id=1 gnb=4

    wts.Modify  ue_param id=1    ue_nr_capabilities=${cap}
    wts.Modify  ue_param id=2    ue_nr_capabilities=${cap}
    wts.Modify  ue_param id=3    ue_nr_capabilities=${cap}

    FOR   ${ue_id}   IN RANGE   101    111
       wts.Delete   set_ue simulated id=${ue_id}
       wts.Delete   ue_param id=${ue_id}
       wts.Delete   set_pdu_gateway id=${ue_id}
       wts.Delete   set_bearer id=2 ue=${ue_id}
    END
    FOR   ${ue_id}   IN RANGE   121    131
       wts.Delete   set_ue simulated id=${ue_id}
       wts.Delete   ue_param id=${ue_id}
       wts.Delete   set_pdu_gateway id=${ue_id}
       wts.Delete   set_bearer id=2 ue=${ue_id}
    END
    FOR   ${ue_id}   IN RANGE   151    161
       wts.Delete   set_ue simulated id=${ue_id}
       wts.Delete   ue_param id=${ue_id}
       wts.Delete   set_pdu_gateway id=${ue_id}
       wts.Delete   set_bearer id=2 ue=${ue_id}
    END
    FOR   ${ue_id}   IN RANGE   171    181
       wts.Delete   set_ue simulated id=${ue_id}
       wts.Delete   ue_param id=${ue_id}
       wts.Delete   set_pdu_gateway id=${ue_id}
       wts.Delete   set_bearer id=2 ue=${ue_id}
    END

    wts.Delete  uec_param id=1
    wts.Delete  trace enb=1
    wts.Delete  trace uec=1
    wts.Save wts cfg             	${resultBaseDir}/basic_wts_711A.cfg
    Log To Console    wts cfg saved as ${resultBaseDir}/basic_wts_711A.cfg
