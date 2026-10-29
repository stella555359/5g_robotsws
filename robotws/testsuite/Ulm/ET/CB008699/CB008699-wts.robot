*** Settings ***
Documentation   This is a keyword file for CB008699, part wts
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

Library     taf.config.wts     WITH NAME    wts

*** Variables ***

${ue1_cap_nr}   SEPARATOR=
...             03800000020008000001A00080420020001000000140420E800000008004000000DE00000000000004E8000200000000020023B4000004008010


*** Keywords ***
Update wts file for TC CB008699
    [Documentation]    [PRIVATE]    update wts cfg file for CB008699
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate wts
    ${wtsconfig}   Get WTS Config    target_dir=${resultBaseDir}
    wts.Load wts cfg             ${wtsconfig}

    wts.Insert    set GNB_XN_ADDR="10.0.1.2"    after    set GNB_X2_ADDR="10.0.1.2"
    wts.Insert    set GNB3_XN_ADDR="10.0.1.3"   after    set GNB_XN_ADDR="10.0.1.2"
    wts.Insert    set GNB3_NG_ADDR="10.0.1.4"   after    set GNB3_XN_ADDR="10.0.1.3"

    wts.Modify    set_gnb id=2   xn=$GNB_XN_ADDR gnb_id=0x01:22
    wts.Insert    set_gnb id=3 type=simulated plmn=311:489 ng=$GNB3_NG_ADDR gnb_id=0x03:22     after   set_cell id=2 gnb=2
    wts.Modify    set_gnb id=3   daemon=$DAEMON_IP:$DAEMON_PORT x2_peers=none xn=$GNB3_XN_ADDR amf=1 plmnList=311:489 nssai=0x1:0xd143a5
    wts.Insert    set_cell id=1 gnb=3 pci=16:0 tac=200 nrci=0x01 tdd_cell=on    after   set_gnb id=3
    wts.Modify    set_cell id=1 gnb=3   proxy=$GNB3_NG_ADDR:9999|$GNB3_NG_ADDR:8890 nr_arfcn=633364:633364 gscn=7847 mandatory_for_activation=off
    wts.Insert    gnb_param id=3 xn_listening_socket=1 send_xn_setup=false measEvent=A3 sa_ho=xn_based    after   set_cell id=1 gnb=3
    wts.Insert    set_cell id=2 gnb=3 pci=16:1 tac=200 nrci=0x02 tdd_cell=on    after   set_cell id=1 gnb=3
    wts.Modify    set_cell id=2 gnb=3   proxy=$GNB3_XN_ADDR:9999|$GNB3_XN_ADDR:8891 nr_arfcn=636666:636666 gscn=7880 mandatory_for_activation=off
    wts.Insert    set_qosflow id=4 5qi=7                   after   set_qosflow id=3
    wts.Insert    set_qosrule id=3 proto=tcp qos_flow=4    after   set_qosrule id=2
    wts.Modify    nwslice_set id=1      qos_flows=1,2,3,4 qos_rules=1,2,3

    wts.Save wts cfg              ${resultBaseDir}/basic_wts_CB008699.cfg
    Log To Console    wts cfg saved as ${resultBaseDir}/basic_wts_CB008699.cfg
    Upload Customized WTS Config    config_path=${resultBaseDir}/basic_wts_CB008699.cfg


Update wts file for TC CB008699-FR2
    [Documentation]    [PRIVATE]    update wts cfg file for CB008699-FR2
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate wts
    ${wtsconfig}   Get WTS Config    target_dir=${resultBaseDir}
    wts.Load wts cfg             ${wtsconfig}

    wts.Insert    set GNB_XN_ADDR="10.0.1.2"    after    set GNB_X2_ADDR="10.0.1.2"
    wts.Insert    set GNB3_XN_ADDR="10.0.1.3"   after    set GNB_XN_ADDR="10.0.1.2"
    wts.Insert    set GNB3_NG_ADDR="10.0.1.4"   after    set GNB3_XN_ADDR="10.0.1.3"

    wts.Modify    set_gnb id=2   xn=$GNB_XN_ADDR gnb_id=0x01:22
    wts.Insert    set_gnb id=3 type=simulated plmn=311:489 ng=$GNB3_NG_ADDR gnb_id=0x03:22     after   set_cell id=2 gnb=2
    wts.Modify    set_gnb id=3   daemon=$DAEMON_IP:$DAEMON_PORT x2_peers=none xn=$GNB3_XN_ADDR amf=1 plmnList=311:489 nssai=0x1:0xd143a5
    wts.Insert    set_cell id=1 gnb=3 pci=16:0 tac=200 nrci=0x01 tdd_cell=on    after   set_gnb id=3
    wts.Modify    set_cell id=1 gnb=3   proxy=$GNB3_NG_ADDR:9999|$GNB3_NG_ADDR:8890 nr_arfcn=2077819:2077819
    wts.Modify    set_cell id=1 gnb=3   gscn=22468 mandatory_for_activation=off suggested_band=257
    wts.Insert    gnb_param id=3 xn_listening_socket=1 send_xn_setup=false measEvent=A3 sa_ho=xn_based    after   set_cell id=1 gnb=3

    wts.Modify    ue_param id=1   ue_nr_capabilities=${ue1_cap_nr}

    wts.Modify    set_qosflow id=1    priority=3
    wts.Insert    set_qosflow id=2 5qi=7 priority=6     after   set_qosflow id=1
    wts.Insert    set_qosflow id=3 5qi=8 priority=4     after   set_qosflow id=2
    wts.Insert    set_qosflow id=4 5qi=9 priority=5     after   set_qosflow id=3
    wts.Modify    nwslice_set id=1      qos_flows=1,2,3,4

    wts.Save wts cfg              ${resultBaseDir}/basic_wts_CB008699-FR2.cfg
    Log To Console    wts cfg saved as ${resultBaseDir}/basic_wts_CB008699-FR2.cfg
    Upload Customized WTS Config    config_path=${resultBaseDir}/basic_wts_CB008699-FR2.cfg