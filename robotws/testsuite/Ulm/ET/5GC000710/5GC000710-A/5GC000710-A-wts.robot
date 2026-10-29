*** Settings ***
Documentation   This is a keyword file for 5GC000710-A, part wts
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

Library         taf.config.wts   WITH NAME   wts

*** Variables ***

${wts_GNB_X2_ADDR}                     10.0.1.2
${wts_GNB3_X2_ADDR}                    10.0.1.3
${wts_GNB3_S1U_ADDR}                   10.0.1.4
${wts_GNB3_X2U_ADDR}                   10.0.1.5


*** Keywords ***

Create ips for simulated gnb
    [Documentation]    [PRIVATE]    create IPs used for WTS
    ...       :Autor: Sylvia Schneider
    Log To Console    \ncreate IPs ${wts_GNB3_X2_ADDR}, ${wts_GNB3_S1U_ADDR} and ${wts_GNB3_X2U_ADDR} on VM eth3
    Configure IP on VM    ip=${wts_GNB3_X2_ADDR}     interface=eth3
    Configure IP on VM    ip=${wts_GNB3_S1U_ADDR}    interface=eth3
    Configure IP on VM    ip=${wts_GNB3_X2U_ADDR}    interface=eth3


Setup 2nd X2link
    [Documentation]    [PRIVATE]    setup 2nd X2link
    ...       :Autor: Sylvia Schneider
    ute_wtssim.execute egate command and wait for data
    ...    cmd=enb_x2_link_up enb=1 target=3    pass_regexp=X2AP Link with GNB-3 .* is up     alias=ap_egate


Update wts file for TC 710A plmn1
    [Documentation]    [PRIVATE]    update wts cfg file for plmn1 usage
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate wts cfg plmn1 ${mcc_SCF}:${mnc_SCF}
    ${wtsconfig}   Get WTS Config    target_dir=${resultBaseDir}
    wts.Load wts cfg             ${wtsconfig}
    wts.Insert    set GNB3_X2_ADDR="${wts_GNB3_X2_ADDR}"      after   set GNB_X2_ADDR="${wts_GNB_X2_ADDR}"
    wts.Insert    set GNB3_S1U_ADDR="${wts_GNB3_S1U_ADDR}"   after    set GNB3_X2_ADDR="${wts_GNB3_X2_ADDR}"
    wts.Insert    set GNB3_X2U_ADDR="${wts_GNB3_X2U_ADDR}"   after    set GNB3_S1U_ADDR="${wts_GNB3_S1U_ADDR}"
    wts.Insert    set PLMN="${mcc_SCF}:${mnc_SCF}"   after   set PROXY_SERVER_IP="10.0.2.80"
    wts.Modify    set_enb id=1     plmn=$PLMN
    wts.Modify    mme_pool_area    eq_plmn=$PLMN
    wts.Modify    set_gnb id=2     plmnList=311:489,311:388
    wts.Insert    set_gnb id=3 type=simulated plmn=311:489 s1u=$GNB3_S1U_ADDR x2=$GNB3_X2_ADDR:36422 gnb_id=0x26:22    after   set_cell id=1 gnb=2
    wts.Modify    set_gnb id=3     daemon=$DAEMON_IP:$DAEMON_PORT x2_peers=none amf=1 plmnList=311:489,311:388 nssai=0x1:0xd143a5
    wts.Insert    set_cell id=1 gnb=3 nr_arfcn=135760:126380 pci=16:0 tac=200 proxy=$GNB3_X2_ADDR:9999|$GNB3_X2_ADDR:8890    after    set_gnb id=3
    wts.Modify    set_cell id=1 gnb=3    nrci=0x01 tdd_cell=off mandatory_for_activation=off gscn=1582
    wts.Insert
    ...    set_cell id=2 gnb=3 nr_arfcn=137200:128000 pci=16:1 tac=200 proxy=$GNB3_S1U_ADDR:9999|$GNB3_X2_ADDR:8891   after   set_cell id=1 gnb=3
    wts.Modify    set_cell id=2 gnb=3    nrci=0x02 tdd_cell=off mandatory_for_activation=off gscn=1600
    wts.Insert
    ...    set_cell id=3 gnb=3 nr_arfcn=167500:176500 pci=15:1 tac=200 proxy=$GNB3_X2U_ADDR:9999|$GNB3_X2_ADDR:8892   after   set_cell id=2 gnb=3
    wts.Modify    set_cell id=3 gnb=3    nrci=0x03 tdd_cell=off mandatory_for_activation=off gscn=2204
    wts.Modify    set_ue simulated id=151                    imsi=$PLMN:21645500
    wts.Save wts cfg             	${resultBaseDir}/basic_wts_710A_plmn1.cfg
    Log To Console    wts cfg saved as ${resultBaseDir}/basic_wts_710A_plmn1.cfg


Update wts file for TC 710A plmn2
    [Documentation]    [PRIVATE]    update wts cfg file for plmn2 usage
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate wts cfg plmn2 ${mcc_SCF}:388
    wts.Load wts cfg             ${resultBaseDir}/basic_wts_710A_plmn1.cfg
    wts.Delete    set PLMN="${mcc_SCF}:${mnc_SCF}"
    wts.Insert    set PLMN="${mcc_SCF}:388"   after   set PROXY_SERVER_IP="10.0.2.80"
    wts.Save wts cfg             	${resultBaseDir}/basic_wts_710A_plmn2.cfg
    Log To Console    wts cfg saved as ${resultBaseDir}/basic_wts_710A_plmn2.cfg


Update wts file for TC 710A 2 cell config
    [Documentation]    [PRIVATE]    update wts cfg file for 2 cell config
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate wts cfg 2 cell configuration
    ${wtsconfig}   Get WTS Config    target_dir=${resultBaseDir}
    wts.Load wts cfg             ${wtsconfig}
    wts.Insert    set PLMN="311:489"      after   set PROXY_SERVER_IP="10.0.2.80"
    wts.Modify    set_enb id=1            plmn=$PLMN
    wts.Modify    mme_pool_area id=1      plmn=$PLMN
    wts.Modify    set_amf_region id=1     tac_list=0,100,258,788,200 plmn=$PLMN
    wts.Modify    set_cell id=1 gnb=2     tac=200 nr_arfcn=647666:647666 nrci=0x1 gscn=7995
    wts.Modify    set_cell id=2 gnb=2     tac=200 nr_arfcn=636666:636666 nrci=0x2 gscn=7880
    wts.Modify    set_ue simulated id=101   imsi=$PLMN:21645500
    wts.Modify    ue_param id=101     ue_nr_capabilities=21000000010800000004DE4E008401807800000000000011500000000000001500
    wts.Save wts cfg             	${resultBaseDir}/basic_wts_710A_2cells.cfg
    Log To Console    wts cfg saved as ${resultBaseDir}/basic_wts_710A_2cells.cfg


Load wts file ${used_plmn}
    [Documentation]    [PRIVATE]    load wts for used plmn
    ...       :Autor: Sylvia Schneider
    Upload Customized WTS Config    config_path=${resultBaseDir}/basic_wts_710A_${used_plmn}.cfg


Load wts 2 cell config file
    [Documentation]    [PRIVATE]    load wts for 2 cell config
    ...       :Autor: Sylvia Schneider
    Upload Customized WTS Config    config_path=${resultBaseDir}/basic_wts_710A_2cells.cfg


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

