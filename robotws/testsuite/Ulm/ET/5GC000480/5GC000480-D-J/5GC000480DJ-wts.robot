** Settings ***
Documentation   This is a keyword file for 5GC000480-D-J, part wts update and start
...             Team: 'MN 5G&SC SW Eng ULM L2PS 60 SG'
...             Email: 'I_ECE_RD_ULM_SQD_60_GMS@internal.nsn.com'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
Library          taf.config.wts    WITH NAME    wts

*** Variables ***
${cap_eutra}    SEPARATOR=
...             A10CF11A118000203040C081C389A00000008723A110003030040C081C389A00000408723A11000203060C0081C389A0000080872320D8000203240C5C4
...             D0000064641A00060640818B89A0000108C83400080C9831071340000291D06800101830700E26800006023F2320D800020304061C4D00000E4641A0006
...             060080C389A0000208C8260000800389A0000248E8160041C4D00001404391D08C0C01030206040E1C4D00000004391D0880C18300206040E1C4D000002
...             04391D06C0C010182060E26800007021C8E83406080C18300713400005810E46413032040E1C4D0000184641203260E01C4D00001A46016026800006018
...             0384D17780BE88C80085B1CF87200216C73E1C80085B1CF8718085B1CF8718085B1CF8718085B1CF8718085B1CF8718085B1CF8718085B1CF8710216C73
...             E1C2216C73E1C80085B1CF87200216C73E1C60216C73E1C60216C73E1C4085B1CF8710216C73E181508800000000000000000091100000009110000000D
...             110000000000603480001010000400000100000080002004009000020000008080002000001000040080120000400000100000040400020000801002300
...             0080800060000018000400801180004000003010000C0002004008C00020000018000006020100200460001000000400000201008010023000080800020
...             0000080004008011800040000010100004000200400880002020000800040080108000C0402004008C00020000008000002020100200440003010000800
...             02004008800060000010080400801


*** Keywords ***


Setup 2nd X2link
    [Documentation]    [PRIVATE]    setup 2nd X2link
    ...       :Autor: Sylvia Schneider
    Log To Console    \nsetup 2nd X2link to GNB-3 and check successful setup
    ute_wtssim.execute egate command and wait for data
    ...    cmd=enb_x2_link_up enb=1 target=3    pass_regexp=X2AP Link with GNB-3 .* is up     alias=ap_egate


Update Wts File For TC 480DJ
    [Documentation]    [PRIVATE]    update wts cfg file
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate wts cfg
    ${wtsconfig}   Get WTS Config    target_dir=${resultBaseDir}
    wts.Load Wts Cfg             ${wtsconfig}
    wts.Insert    set GNB3_X2_ADDR="${wts_GNB3_X2_ADDR}"    after   set GNB_X2_ADDR="${wts_GNB_X2_ADDR}"
    wts.Insert    set GNB3_S1U_ADDR="${wts_GNB3_S1U_ADDR}"   after   set GNB3_X2_ADDR="${wts_GNB3_X2_ADDR}"
    wts.Insert    set_gnb id=3 type=simulated plmn=311:489 s1u=$GNB3_S1U_ADDR x2=$GNB3_X2_ADDR:36422    after   set_cell id=2 gnb=2
    wts.Modify    set_gnb id=3        gnb_id=0x26:22 daemon=$DAEMON_IP:$DAEMON_PORT x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5
    wts.Insert    set_cell id=1 gnb=3 nr_arfcn=135760:126380 pci=16:0 tac=200 proxy=$GNB3_X2_ADDR:9999|$GNB3_X2_ADDR:8890     after   set_gnb id=3
    wts.Modify    set_cell id=1 gnb=3           nrci=0x01 tdd_cell=off mandatory_for_activation=off gscn=1582
    wts.Insert    set_bearer id=3 ue=151 default=off qci=6     after   set_bearer id=2 ue=151
    wts.Insert    set_bearer id=4 ue=151 default=off qci=7     after   set_bearer id=3 ue=151
    wts.Save Wts Cfg             	${resultBaseDir}/basic_wts_480DJ.cfg
    Log To Console    \nwts cfg saved as ${resultBaseDir}/basic_wts_480DJ.cfg


Update Wts File For TC 480D Strong Cell
    [Documentation]    [PRIVATE]    update wts cfg file for TC 480D strong cell
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate wts cfg
    ${wtsconfig}   Get WTS Config    target_dir=${resultBaseDir}
    wts.Load Wts Cfg             ${wtsconfig}
    wts.Delete    set GNB3_XN_ADDR="10.0.1.122"
    wts.Delete    set GNB3_NG_ADDR="10.0.1.123"
    wts.Delete    set PROXY_SERVER4_IP="10.0.2.90"
    wts.Delete    set GNB4_XN_ADDR="10.0.1.124"
    wts.Delete    set GNB4_NG_ADDR="10.0.1.125"
    wts.Delete    set PROXY_SERVER5_IP="10.0.2.91"
    wts.Insert    set GNB3_X2_ADDR="${wts_GNB3_X2_ADDR}"     after   set PGW_ADDR="4.7.254.207"
    wts.Insert    set GNB3_S1U_ADDR="${wts_GNB3_S1U_ADDR}"   after   set GNB3_X2_ADDR="${wts_GNB3_X2_ADDR}"
    wts.Modify    set_cell id=1 gnb=2    nr_arfcn=640000:640000 gscn=7916
    wts.Modify    set_cell id=2 gnb=2    nr_arfcn=640000:640000 gscn=7916
    wts.Modify    set_cell id=3 gnb=2    nr_arfcn=640000:640000 gscn=7916
    wts.Modify    set_cell id=4 gnb=2    nr_arfcn=640000:640000 gscn=7916
    wts.Delete    set_gnb id=3
    wts.Delete    set_cell id=1 gnb=3
    wts.Delete    gnb_param id=3
    wts.Insert    set_gnb id=3 type=simulated plmn=311:489 s1u=$GNB3_S1U_ADDR x2=$GNB3_X2_ADDR:36422    after   set_cell id=4 gnb=2
    wts.Modify    set_gnb id=3        gnb_id=0x26:22 daemon=$SERVER_IP:$EDAEMON_PORT x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5
    wts.Insert    set_cell id=1 gnb=3 nr_arfcn=640000:640000 pci=16:0 tac=200 proxy=$GNB3_X2_ADDR:9999|$GNB3_X2_ADDR:8890    after   set_gnb id=3
    wts.Modify    set_cell id=1 gnb=3        nrci=0x01 tdd_cell=on mandatory_for_activation=off gscn=7916 suggested_band=78
    wts.Delete    set_gnb id=4
    wts.Delete    set_cell id=1 gnb=4
    wts.Delete    gnb_param id=4
    wts.Modify    ue_param id=11    ue_nr_capabilities=21000000010800000004DE4E008401807800000000000011500000000000001500
    wts.Modify    ue_param id=11    ue_eutra_nr_capabilities=${cap_eutra}
    wts.Modify    ue_param id=12    ue_nr_capabilities=21000000010800000004DE4E008401807800000000000011500000000000001500
    wts.Modify    ue_param id=12    ue_eutra_nr_capabilities=${cap_eutra}
    wts.Modify    ue_param id=13    ue_nr_capabilities=21000000010800000004DE4E008401807800000000000011500000000000001500
    wts.Modify    ue_param id=13    ue_eutra_nr_capabilities=${cap_eutra}

    wts.Save Wts Cfg              ${resultBaseDir}/basic_wts_480D_strongCell.cfg
    Log To Console    \nwts cfg saved as ${resultBaseDir}/basic_wts_480D_strongCell.cfg
