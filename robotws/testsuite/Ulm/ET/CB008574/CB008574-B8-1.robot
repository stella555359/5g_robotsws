*** Settings ***
Documentation
...    author: Ulm SQD 65
...    Team: 'MN RAN L3 SW ULM L3NRT SQD 65'
...    Email: 'I_MN_RAN_L3_SW_ULM_SQD_65@internal.nsn.com'
...    Description: RRC Connection Re-establishment under a prepared gNB via RRCSetup


Resource                   CB008574_Keywords.robot

Library                    taf.config.wts       WITH NAME    wts_conf

Suite Setup                Setup TL for CB008574-B8-1

Test Setup                 Perform Precondition of Test Scenario
Test Teardown              Perform Postconditions of Test Scenario

*** Variables ***

@{IP_LIST_eth3_add}        10.0.1.3
${TGT_NODE}                ${0}
${TGT_GNB}                 2
${TGT_CELL}                1

${UE_CAPA_TDD}             SEPARATOR=
...                        E9A01000074F5A130200020940004824C5800260D42C013601873E618F28581C130180623825506C4ED608C21A08107CA0F002CB64C550D0E7C471E819
...                        F604F8C73E618F28581C0E1E0B80000000E00000000C80000E0541B137582308682041F283C00B2D931543439F11C7A067D813E31CF9863CA160703878
...                        2E0009E00380027800320000381507C46D608C21A08107CA0F0024B64C55050E7C471E31CF9863CA16070387813F8000000FE0000000C80000E0541F10
...                        7582308682041F283C0092D931541439F11C78C73E618F28581C0E1E04FE0000003F8000000320000381D06C28C0D608C21A08107CA0F002CB64C550D0
...                        E7C471E819F604F8C73E618F28581C0E1E0B80025800E00096000C80000E0541F06F582308682041F283C0092D931541439F11C78C73E618F28581C0E1
...                        E04FE8000003FA000000320000381507C18D608C21A08107CA0F0024B64C55050E7C471E31CF9863CA16070387813F8000000FE0000000C80000E0541F
...                        01B582308682041F283C0092D931541439F11C78C73E618F28581C0E1E04FE0000003F8000000320000381507C02D608C21A08107CA0F0024B64C55050
...                        E7C471E31CF9863CA16070387813F8000000FE0000000C80000E0541F007582308682041F283C0092D931541439F11C78C73E618F28581C0E1E04FE000
...                        0003F8000000320000381507C00D608C21A08107CA0F0024B64C55050E7C471E31CF9863CA16070387813FB000000FEC000000C80000E0541B0BF58230
...                        8682041F283C00B2D931543439F11C7A067D813E31CF9863CA1607038784E0009000380024000320000381506C27D608C21A08107CA0F002CB64C550D0
...                        E7C471E819F604F8C73E618F28581C0E1E1380004800E00012000C80000E0541B097582308682041F283C00B2D931543439F11C7A067D813E31CF9863C
...                        A1607038784E0008000380020000320000381507C13D608C21A08107CA0F0024B64C55050E7C471E31CF9863CA16070387813F8000000FE0000000C800
...                        00E0541F037582308682041F283C0092D931541439F11C78C73E618F28581C0E1E04F80000003E0000000320000381507C0BD608C21A08107CA0F0024B
...                        64C55050E7C471E31CF9863CA16070387813F0000000FC0000000C80000E0541F01F582308682041F283C0092D931541439F11C78C73E618F28581C0E1
...                        E04FE0000003F8000000320000381507C04D608C21A08107CA0F0024B64C55050E7C471E31CF9863CA16070387813F8000000FE0000000C80000E00184
...                        1C4D000000B070A0200008083A83C28000E230000020902024010040941502B06E0F81F46EC028194001080E044D8E7C3853A76C73E1C060FFC1803818
...                        C63F41B000E000A070500603009001C030140140F81400800000004000008020000080100000600800004004000028020000180100000E008000080040
...                        00048020000280A654DE54D6065606D60A560CD64CD652D646D602560450301000009652504000065949410000296525040000E5949010000496524040
...                        00165949010000696524040001E594901000051652404000225949010000996524040002A5949010000B9652402D4AAAE9555503AAA0B1541A2A9545D2
...                        A8AA4D154A62A91C55018AA05143400E80550281C0E07038140A050381C0008002004008004008010808010020200C018D5018120A12320450

${SET_SIM_GNB}             type=simulated plmn=311:489 ng=$GNB3_NG_ADDR daemon=$SERVER_IP:$DAEMON_PORT
...                        gnb_id=0x3:22 x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5
${SIM_GNB_PARAM}           xn_listening_socket=1 sa_ho=ng_based sib1_period=160 measEvent=A3 measEvent=A2
...                        ng_data_forwarding_HO=on srb1_rlc_sn_field_size=size_12 ciphering_algorithm=nea3 integrityprotection_algorithm=nia3
${SET_SIM_GNB_CELL}        gnb=${SIM_GNB} pci=10:1 tac=200 nrci=0x05 tdd_cell=on proxy=$PROXY_SERVER1_IP:9999
...                        nr_arfcn=518580:518580 gscn=6486 mandatory_for_activation=off



*** Test Cases ***

[1]CB008574_B_B8_Interaction_with_CB008699_Full_RRC_Configuration_for_SA_Handover
    [Documentation]  This user scenario describes the interaction with CB008699 Full RRC Configuration for SA Handover:
    ...              During Inter-gNB handover via NG, target gNB detects that full configuration is needed
    ...              and fullConfig IE shall be included in RRCReconfiguration RRC Reestablishment request received by target gNB,
    ...              if internal flag "fullConfigTriggered" is true from the HO context,
    ...              gNB-CU-CP falls back to RRC Setup procedure by sending the RRCSetup message and follows the steps from
    ...              idle to connected state transition procedure.
    ...              [1] Source DRB to QoS flow mapping is missing at target gNB during NG based handover
    [Tags]    B8  B8.1
    Test CB008574-A-B3 RRE to Target Cell after NG HO ACK before RRC ReconfigComplete
    Wait Until The Next Measurement Period Starts
    Set actFullRRCConfigurationSaHo
    Register UE on simGnb and start traffic
    Remove QosFlow Mapping List in HandOverRequired
    Ignore RRC Reconfig and Trigger RRCReestablishmentRequest   cause=handoverFailure
    Trigger HO       phycell_id=50  carrier_freq=636576  pass_regexp=rrcReestablishmentRequest.*rrcSetup
    B8-1 Verification

*** Keywords ***

Setup TL for CB008574-B8-1
    Set Console Output
    Sqd65 Common Setup    skip_precheck=${True}
    Setup WTS cfg
    Bring Airphone TL to F1 up status
    Bring Airphone TL to on Air status without reboot    remove_logs=${True}
    ${SW_BRANCH}=                           testline.Get gNB SW Branch
    Set Suite Variable                      ${SW_BRANCH}
    Commissioning

B8-1 Verification
    [Arguments]    ${target_cell}=${TGT_CELL}  ${cause}=handoverFailure
    Verify FullConfig             ${target_cell}
    Set RRC_REESTAB_FAIL_TARGET_CELL counters                        target_cell=${target_cell}   fail_cause=${cause}
    Set Counter Value             ${RRC_REESTAB_FAIL_TARGET_CELL}    HO_PREP_SUCC_FULLCONF_TRG    1

    ${lcid}               Set Variable If  '${target_cell}' == '${PREP_CELL}'         ${2}  ${1}
    ${pmqap_ref_table}    Set Variable If  '${target_cell}' == '${PREP_CELL}'
    ...                                     ${RRC_REESTAB_FAIL_PREP_CELL_PMQAP}       ${RRC_REESTAB_FAIL_TARGET_CELL_PMQAP}
    ${ng_flow_ref_table}  Set Variable If  '${target_cell}' == '${PREP_CELL}'
    ...                                     ${RRC_REESTAB_FAIL_PREP_CELL_NG_FLOW}     ${RRC_REESTAB_FAIL_TARGET_CELL_NG_FLOW}

    ${pm_files_tgt}               Collect PM counters from target gNB

    Verify PM Counter Reference Table
    ...       reference_table=${RRC_REESTAB_FAIL_TARGET_CELL}        pm_dir=${pm_files_tgt}   distname_suffix=NRBTS-1/NRCELL-1
    Verify PM Counter Reference Table
    ...       reference_table=${RRC_REESTAB_FAIL_PREP_CELL}          pm_dir=${pm_files_tgt}   distname_suffix=NRBTS-1/NRCELL-2

    Verify PM Counter Reference Table
    ...       reference_table=${pmqap_ref_table}                     pm_dir=${pm_files_tgt}   distname_suffix=NRCELL-1/PLMN-PLMN/NRPMQAP-1
    Verify PM Counter Reference Table
    ...       reference_table=${ng_flow_ref_table}                   pm_dir=${pm_files_tgt}   distname_suffix=NRBTS-1/NRCELL-1

    Verify PM Counter Reference Table
    ...       reference_table=${RRC_REESTAB_FAIL_TARGET_DU}          pm_dir=${pm_files_tgt}   distname_suffix=NRBTS-1/NRDU-1

Setup WTS cfg
    ${ts_conf_dir}=         Get Test Suite Config Directory
    Copy File               ${tl.core.dir_path}/${tl.core.cfg_filename}   ${ts_conf_dir}/${tl.core.cfg_filename}.orig
    Copy File               ${tl.core.dir_path}/${tl.core.cfg_filename}   ${tl.core.dir_path}/${tl.core.cfg_filename}.orig

    wts_conf.Load Wts Cfg   ${tl.core.dir_path}/${tl.core.cfg_filename}

    wts_conf.insert         set SA_UE_CAPABILITIES_TDD=${UE_CAPA_TDD}      before  ue_param id=1
    wts_conf.insert         ue_param id=1 nr_usage_setting=voice_centric   after   ue_param id=1

    wts_conf.insert         set GNB3_NG_ADDR="10.0.1.3"        after    set GNB_NG_ADDR="10.0.1.2"
    wts_conf.insert         set PROXY_SERVER1_IP="10.0.2.90"   after    set PROXY_SERVER_IP="10.0.2.80"

    wts_conf.insert         set_gnb id=${SIM_GNB} ${SET_SIM_GNB}              before   set_uec id=1
    wts_conf.insert         gnb_param id=${SIM_GNB} ${SIM_GNB_PARAM}          after    set_gnb id=${SIM_GNB}
    wts_conf.insert         set_cell id=${SIM_CELL} ${SET_SIM_GNB_CELL}       after    gnb_param id=${SIM_GNB}

    wts_conf.modify         set_qosflow id=1    modification=5qi=5
    wts_conf.modify         set_qosflow id=2    modification=5qi=1
    wts_conf.modify         set_qosflow id=3    modification=5qi=2
    wts_conf.delete         set_qosrule id=1
    wts_conf.delete         set_qosrule id=2
    wts_conf.insert         set_qosrule id=1 proto=udp qos_flow=1  after  set_qosflow id=3
    wts_conf.insert         set_qosrule id=2 proto=udp qos_flow=2  after  set_qosrule id=1
    wts_conf.insert         set_qosrule id=3 proto=udp qos_flow=3  after  set_qosrule id=2

    wts_conf.Save Wts Cfg   ${tl.core.dir_path}/${tl.core.cfg_filename}
    wts_conf.Save Wts Cfg   ${tl.core.dir_path}/${tl.core.cfg_filename}.new
    wts_conf.Save Wts Cfg   ${ts_conf_dir}/${tl.core.cfg_filename}

Commissioning
    ${current_scf}=         Load current SCF
    Set Object  class_name=NRPMQAP  dist_name=NRBTS-1/NRPMRNL-1/NRPMQAP-1
    FOR   ${dist_name}  ${p_name}  ${value}  IN
    ...             NRBTS-1                      actIntraNrNgHo                  targetOnly
    ...             NRBTS-1                      actInterFreqHoSA                true
    ...             NRBTS-1                      rrcReestabTypeSA                sameGNB
    ...             NRBTS-1                      tNgRelocExecDeltN               3000
    ...             NRBTS-1                      timerXnDataFwdGuard             2000
    ...             NRBTS-1                      suppCnPartialAdNgHo             false
    ...             NRBTS-1                      actFullRRCConfigurationSaHo     enabled
    ...             NRBTS-1                      actInterGnbRREPreparedCell      true
    ...             NRBTS-1                      actNrpmqapProfiles              true
    ...             NRBTS-1/NRCELL-1             actVoNR                         true
    ...             NRBTS-1/NRPMRNL-1            miNrRelReportCu                 5min
    ...             NRBTS-1/NRPMRNL-1            miNrNgInterfaceNrpmqap          5min
    ...             NRBTS-1/NRPMRNL-1/NRPMQAP-1  actCplaneCounters               true
    ...             NRBTS-1/NRPMRNL-1/NRPMQAP-1  cfgProfType                     SA
    Set Element     dist_name=${dist_name}       p_name=${p_name}                value=${value}
    END
    IF   '${SW_BRANCH}'!='SBTS24R3'
         Set Element  NRBTS-1/NRPMRNL-1/NRPMQAP-1  actUPlaneGroup1Counters       false
         Set Element  NRBTS-1/NRPMRNL-1/NRPMQAP-1  actUPlaneGroup2Counters       false
    ELSE
         Set Element  NRBTS-1/NRPMRNL-1/NRPMQAP-1  actL2Counters                 false
         Set Element  NRBTS-1/NRPMRNL-1/NRPMQAP-1  actPacketSchedulerCounters    false
    END
    IF   '${SW_BRANCH}' in ['SBTS00', 'SBTS26R1', 'SBTS26R2']
         Set Element  NRBTS-1/NRPMRNL-1/NRPMQAP-1  cfgUECategoryFR1               All UEs
         Set Element  NRBTS-1/NRPMRNL-1/NRPMQAP-1  cfgUECategoryFR2               All UEs
    END
    Apply Delta SCF         ${current_scf}  enable_VoNR

Test CB008574-A-B3 RRE to Target Cell after NG HO ACK before RRC ReconfigComplete
    Register UE on simGnb and start traffic
    Ignore RRC Reconfig and Trigger RRCReestablishmentRequest   cause=handoverFailure
    Trigger HO                phycell_id=50  carrier_freq=636576  pass_regexp=NR RRC Reestablishment sucessfully completed
    Set Counter Value         ${A-B3_1_PM_CU}   RRC_RECONF_ADD1DLSCELL_ATT_SA    0
    Set Counter Value         ${A-B3_1_PM_CU}   RRC_RECONF_ADD1DLSCELL_SUCC_SA   0
    Verify B3_1 PM Counters
    UE Deregister
