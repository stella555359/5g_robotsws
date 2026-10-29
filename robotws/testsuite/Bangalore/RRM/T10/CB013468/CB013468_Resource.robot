*** Settings ***
Documentation    Suite documentation

Variables       ta5g_global_var
Resource        taf/rfrl/common_resources/robot/coam.robot
Resource        taf/rfrl/common_resources/robot/libraries_instances.robot
Library         ../../../resources/NPS/SWENG/python_libs/luashark_tools.py
Resource        ../../../resources/NPS/SWENG/robot/PacketSearch.robot
Resource        ../../../resources/robot/Setup_Env.robot
Resource        ../../../resources/robot/common_log_collection.robot
Resource        ../../../resources/ECEcommon/common_file_operation.robot
Resource         ../../../resources/robot/Airphone.robot
Resource        ../../../resources/robot/wts_sim_keywords.robot
Resource         ../../../resources/robot/PM_Counters.robot
Resource         ../../../resources/robot/TTI_Traces.robot
Resource         ../../../resources/robot/Iperf_Traffic.robot
Library          ../../../resources/python/ssh_command.py
Library          ./python/increase_buffer_size.py
Library          ./python/fetch_counter_value.py
Library         luashark_tools.analyzer       WITH NAME       analyzer
#Library         ute_admin                         WITH NAME   ute_adm
Library         taf.collectors.btslog  WITH NAME   btslog
Library         taf.sbts.oam.coam.admin  WITH NAME   coam
Library         Collections
Library         OperatingSystem
Library         ta5g_tshark
Library         ta5g_commissioning
Library         taf.analyzer.pdml     WITH NAME    taf_pdml_analyser
Library         taf.transport.ssh                 WITH NAME    csn
Library         XML    use_lxml=True    WITH NAME    Myxml
Library         ../../../resources/python/TTI_Converter.py    WITH NAME    TtiConvert
Library         ../../../resources/python/BIP_Capture.py
Library         ../../../resources/python/CPRT_Capture.py
Library         DateTime
Library         taf.transport.ssh           WITH NAME    taf_ssh
Library         ta_a2a
Library         taf.rfrl.utilities.utf_lab.ute_utf_lab.UteUtfLab  WITH NAME  ute_utf_lab
Resource        ../../../resources/robot/Capture.robot
Resource        ../../../resources/NPS/SWENG/robot/Backup.robot



*** Variables ***
&{GNB_ASIK}                ip=192.168.255.129  username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik
&{AP_ASIK}                 ip=192.168.200.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=APAsik
${port}                    22

${pdu_mod_with_5qi-5}     Added QosFlow with QFI:2 fiveQI:5
${pdu_mod_with_5qi-1}     Added QosFlow with QFI:3 fiveQI:1

${ue_eutra_nr_cap}        SEPARATOR=
...                       A107C3083602009049230711800004D10080A0106C04012092460E2300000922F8980802410E14040006022E102227
...                       FE360200904385000182800028117081113FE1B010048218280388C00001C08B8488899F0D80802010C1401C460000
...                       10041091113241A01068240918388C00001288040500834020D0481230711800002117C48041A08070A02000181170
...                       81113FF1A01068201C28000C140000008B840889FF0D00834100E1400061180002045C24444C906804100834100E23
...                       000002220100040180B08211A020C028803101185D202C2191A74E9D3B639F0E34E9D3A76C73E1C49D3A16C73E1C69
...                       D3A14ED8E7C38D3A74E9DB1CF871A74E9D3B639F0E34E9D3A76C73E1C69D3A74ED8E7C3893A742D8E7C38D3A7429DB
...                       1CF871A74E9D3B639F0E34E9D3A76C73E184C182108431084210C4044321D170043A2E001809180008000002008080
...                       100202004000C000400000100404008010100400060002010000800000200808020042000100000040101006004600
...                       0200000140200010000802004300010040004000100200404008001000080200020000803002300010040004000100
...                       20000401002180008020002000080400002008010C0004010002800000200010040080


${ue_nsa_nr_cap}          SEPARATOR=
...                       E7A05380574F7E03560003084000B040040602441800260E12006241A013018062280C0299C0AE83614606B04610D0
...                       4083A41A00A2D954542439F40CFB027C639F30C7942C0E070F02E000BE0038002F8002C4001B280002800000A0F831
...                       AC1184341020F1068024B65515050E7D033E31CF9863CA16070387813FA000000FE800000541F107582308682041E2
...                       0D00496CAA2A0A1CFA067C639F30C7942C0E070F027F4000001FD000000161000304507C46D608C21A081078834012
...                       5B2A8A82873E819F18E7CC31E50B0381C3C09FC0000007F0000002A0D89BAC1184341020E9068028B65515090E7D03
...                       3EC09F18E7CC31E50B0381C3C138002F800E000BE000B10006CA0000A00000283E036B04610D04083C41A0092D9545
...                       41439F40CF8C73E618F28581C0E1E04FE0000003F8000000507C1BD608C21A0810788340125B2A8A82873E819F18E7
...                       CC31E50B0381C3C09FD0000007F4000000A0F801AC1184341020F1068024B65515050E7D033E31CF9863CA16070387
...                       813FF000000FFC00000540B41378E3087000A8F3F1434011FB660AA40078F0021C4106115028FDFC81B8FC71680003
...                       01502D03DE38C21C002A3CFC50D0047ED982A9001E3C0087104184540A3F7F206E3F1C5A0000C0740B4070378E3087
...                       000A8F3F1434011FB660AA40078F0021C4106115028FDFC81B8DC61680003002EA0E0A00E2080000C0913EA160600E
...                       2080061180024100EA17060003082061180004100EA160600C2081C46000022100EB0E0600E14040008080758B0300
...                       70A000308C000A080758B030070A00030500001080758B030060600E14000004080758785010184600068409958B85
...                       00018280308C000508132B170A000308C06118001E1026541E0C00060A0200E120EA17060003050061180012120EA1
...                       7060003050060A00000120EA17060003030060A00006120EA160600C1401C46000016120EA0E0A02E2300000E09132
...                       A160A00C1401C4600000C1226542C1401C46000C2300040244CA85C18000C0C018460001040150B8300018460308C0
...                       013080750B030060600E230000110802A160600E2300061180028100E02000803016104234041805100620230BA008
...                       09385E14E9DB2D78F1274E9DB2D78F1274E9DB2D78F1274E9DB2D78F0A742D96BC7893A14ED96BC7893A14ED96BC78
...                       93A742D96BC7850A76CB5E3C4853A76CB5E3C4853A76CB5E3C29D3B65AF1E24E9D3B65AF1E24E9D3B65AF1E24E9D3B
...                       65AF1E24E9D3B65AF1E14E9DB2D78F1274E9DB2D78F1274E9DB2D78F1274E9DB2D78F1274E9DB2D78F1274E9DB2D78
...                       F1274E9DB2D78E0108B884210C6318C631084210842108420F417801F001400180E0A00E0601280380030101088008
...                       216821000800190480104307C050040000000200000401000800000020000080100000600800004011953581979435
...                       81B5823403040000006C00100001000000400008000001000030000000D4AA2A81C5D288AA09142C01B805A070281C
...                       0E07000342108000A08040200301002000040080010080400002004008080100020100800C04020000100400040A01
...                       4014030048040060A010004030008050000A0040040080080100020300C002010000180600100A0000C00801801002
...                       2010020040400800010040004020040000801000020080104040200301006000202010000080300220100800C04008
...                       0001004000402010000080100202008000804020000100200004010020808010000201001840401801010040002020
...                       0C00008020042010020040401000010040004020040000802004020080008040200001008000040100210080400002
...                       010018080200020100800C040100001004000402010000080200402008000950B0000810182030385860889098C0C8
...                       D929313941697A0A320450

${ue_nr_cap}              SEPARATOR=
...                       E7A05380574F7E03560003084000B040040602441800260E12006241A013018062280C0299C0AE83614606B04610D0
...                       4083A41A00A2D954542439F40CFB027C639F30C7942C0E070F02E000BE0038002F8002C4001B280002800000A0F831
...                       AC1184341020F1068024B65515050E7D033E31CF9863CA16070387813FA000000FE800000541F107582308682041E2
...                       0D00496CAA2A0A1CFA067C639F30C7942C0E070F027F4000001FD000000161000304507C46D608C21A081078834012
...                       5B2A8A82873E819F18E7CC31E50B0381C3C09FC0000007F0000002A0D89BAC1184341020E9068028B65515090E7D03
...                       3EC09F18E7CC31E50B0381C3C138002F800E000BE000B10006CA0000A00000283E036B04610D04083C41A0092D9545
...                       41439F40CF8C73E618F28581C0E1E04FE0000003F8000000507C1BD608C21A0810788340125B2A8A82873E819F18E7
...                       CC31E50B0381C3C09FD0000007F4000000A0F801AC1184341020F1068024B65515050E7D033E31CF9863CA16070387
...                       813FF000000FFC00000540B41378E3087000A8F3F1434011FB660AA40078F0021C4106115028FDFC81B8FC71680003
...                       01502D03DE38C21C002A3CFC50D0047ED982A9001E3C0087104184540A3F7F206E3F1C5A0000C0740B4070378E3087
...                       000A8F3F1434011FB660AA40078F0021C4106115028FDFC81B8DC61680003002EA0F0A0003882000030244FA858180
...                       3882001C46000024100EA17060003882001C46000004100EA160600C2081C46000022100EB0E0600E1404000808075
...                       8B030070A000388C000028201D62C0C01C28000E14000001080758B030060600E140000040807587850101C4600001
...                       A1026562E1400060A00C2300014204CAC5C28000C230184600078409950783000182808038483A85C18000C1401846
...                       00048483A85C18000C140182800000483A85C18000C0C0182800018483A858180305007118000058483A83C28080E2
...                       300000E09132A160A00C1401C4600000C1226542C1401C46000C2300040244CA85C18000C0C018460001040150B830
...                       0018460308C0013080750B030060600E230000110802A160600E2300061180028100E0200080301610423404180510
...                       0620230BA00809385E14E9DB2D78F1274E9DB2D78F1274E9DB2D78F1274E9DB2D78F0A742D96BC7893A14ED96BC789
...                       3A14ED96BC7893A742D96BC7850A76CB5E3C4853A76CB5E3C4853A76CB5E3C29D3B65AF1E24E9D3B65AF1E24E9D3B6
...                       5AF1E24E9D3B65AF1E24E9D3B65AF1E14E9DB2D78F1274E9DB2D78F1274E9DB2D78F1274E9DB2D78F1274E9DB2D78F
...                       1274E9DB2D78F1274E9DB2D78E0108B884210C6318C631084210842108420F417801F001400180E0A00E0601280380
...                       030101088008216821000800190480104307C050040000000200000401000800000020000080100000600800004013
...                       9535819582B581B5823403040000006C00100001000000400008000001000030000000F4AA2A81C55058AA09142C01
...                       B805A070281C0E07000342108000A08040200301002000040080010080400002004008080100020100800C04020000
...                       100400040A014014030048040060A010004030008050000A0040040080080100020300C002010000180600100A0000
...                       C008018010022010020040400800010040004020040000801000020080104040200301006000202010000080300220
...                       100800C040080001004000402010000080100202008000804020000100200004010020808010000201001840401801
...                       0100400020200C00008020042010020040401000010040004020040000802004020080008040200001008000040100
...                       210080400002010018080200020100800C040100001004000402010000080200402008000950B00008101820303858
...                       60889098C0C8D929313941697A0A320450

${ue_eu_nr_cap}           SEPARATOR=
...                       A107C3083602009049230711800004D10080A0106C04012092460E2300000922F8980802410E14000006022E102227
...                       FE360200904385000182800028117081113FE1B010048218280388C00001C08B848889920D808020104821C4600001
...                       04441A01068240918388C00001288040500834020D0481230711800002117C48041A08070A0200018117081113FF1A
...                       01068201C28000C140000008B840889FF0D00834100E1400061180002045C24444C906804100834100E23000002220
...                       100040180B08211A020C028803101185D202C2191A74E9D3B639F0E34E9D3A76C73E1C49D3A16C73E1C69D3A14ED8E
...                       7C38D3A74E9DB1CF871A74E9D3B639F0E34E9D3A76C73E1C69D3A74ED8E7C3893A742D8E7C38D3A7429DB1CF871A74
...                       E9D3B639F0E34E9D3A76C73E184C182108431084210C4044321D170043A2E001809180008000002008080100202004
...                       000C000400000100404008010100400060002010000800000200808020042000100000040101006004600020000014
...                       0200010000802004300010040004000100200404008001000080200020000803002300010040004000100200004010
...                       0218000802000200000080002008010C0004010002800000200010040080

*** Keywords ***

Perform SCF Delta Commissioning with ${delta_commissioning_file_json}
    Find Scfc And Send Delta Commissioning      scfc_filename=${delta_commissioning_file_json}

Increase Buffer Size for VM and IPHY
    increase_buffer_size.increase_buffer_size     ${AP_ASIK.ip}      ${port}    ${AP_ASIK.username}     ${AP_ASIK.password}

Enhanced Buffer Size for VM and IPHY
    increase_buffer_size.enhanced_buffer_size    ${AP_ASIK.ip}      ${port}    ${AP_ASIK.username}     ${AP_ASIK.password}

Online modify gnb radparam using aashell
    [Arguments]    ${radparam}    ${radval}
    increase_buffer_size.online_mod_gnb_radparam_aashell
    ...     ${GNB_ASIK.ip}      ${port}    ${GNB_ASIK.username}     ${GNB_ASIK.password}    ${radparam}    ${radval}

Load CFG and verify cell status TMO
    [Arguments]     ${wts_cfg_file}		${cell_list}		${enb_id}=2
	Configure eth3 IP
	Start wts application and load CFG		${wts_cfg_file}
    sleep   1m
    Wait Until Keyword Succeeds     180s    5s	   TMO Verify Sib Mib for Cell		${cell_list}	${enb_id}
    Sleep   20s

TMO Verify Sib Mib for Cell
	[Arguments]		${cell_list}	${enb_id}=2
	FOR     ${cell}    IN     @{cell_list}
	${mib_disp_cmd}		SET VARIABLE	enb_cell_ib_disp cell=${cell} enb=${enb_id} type=mib
	${sib_disp_cmd}		SET VARIABLE	enb_cell_ib_disp cell=${cell} enb=${enb_id} type=sib1
	${sib_mib_disp_cmd}		SET VARIABLE	enb_cell_ib_disp cell=${cell} enb=${enb_id}
    #ute_wtssim.Execute Egate Command And Wait For Data ${mib_disp_cmd} pass_regexp=${mib_radiated_pattern}		timeout=${EGATE_COMMAND_TIMEOUT}
    Execute Egate Command And Wait For Data      ${sib_disp_cmd}     pass_regexp=${sib_radiated_pattern}
    ...     timeout=${EGATE_COMMAND_TIMEOUT}
    Execute Egate Command And Wait For Data		${sib_mib_disp_cmd}			fail_regexp=no
    ...     timeout=${EGATE_COMMAND_TIMEOUT}
	END

Add RD Parameters To GNB Swconfig File
    [Arguments]    ${rd_parametrs}
    [Documentation]    This keyword is to add new RD parameters to swconfig.txt
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${rd_parametrs} | Yes | str joined by symbol ;, like 0x580019=1;0x580011=0;0x580012=0; |
    ...
    ...    Examples:
    ...    | Add RD Parameters To GNB Swconfig File | 0x580019=1;0x580011=0;0x580012=0 |
    ...
    ${path}    Get Swconfig File From GNB    ${OUTPUT_DIR}
    Modify Swconfig File Parameters    ${path}    ${rd_parametrs}
    Send Swconfig File To GNB    ${path}

Get Swconfig File From GNB
    [Arguments]    ${save_dir}
    OperatingSystem.Run
    ...    sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.255.129:/ffs/run/swconfig.txt ${save_dir}/swconfig_gnb.txt
    OperatingSystem.Should Exist    ${save_dir}/swconfig_gnb.txt
    ${path}    Set Variable    ${save_dir}/swconfig_gnb.txt
    [Return]    ${path}

Send Swconfig File To GNB
    [Arguments]    ${path}
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p oZPS0POrRieRtu scp ${path} toor4nsn@192.168.255.129:/ffs/run/swconfig.txt
    Should Be Equal As Integers    ${rc}    0

MultiUE NSA Attach should be Successful and Fetch CRNTI
    [Arguments]    ${start_ue_id}   ${end_ue_id}    ${Trgt_Cell}=${Target_Cells}    ${meas_gap_config}=off
    ...    ${bc_list}=0:0    ${scellidx}=8:9    ${isDefCap}=True    ${gapTrig}=gnb_triggered    ${gap_pur}=perUE
    ...    ${measFreq}=off

    [Documentation]    This keyword is used at create the LTE Attach and checks the completion message in output file.
    ${crnti_list_nsa}       Create List
    FOR    ${NSA_UE_ID}    IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    ${cmd1}	SET VARIABLE	ue_attach id=${NSA_UE_ID}
    ${cmd2}	SET VARIABLE if	  ${isDefCap}==False
    ...     ue_attach id=${NSA_UE_ID} ue_nr_capabilities=${ue_nsa_nr_cap} ue_eutra_nr_capabilities=${ue_eutra_nr_cap}
    ${ue_attach_cmd}    set variable if    ${isDefCap}==True    ${cmd1}    ${cmd2}
    Execute Egate Command And Wait For Data   ${ue_attach_cmd}	pass_regexp=${LTE_attach_pattern}    timeout=${Timeout_NSA}
    BuiltIn.Log    lte_attach_is_ok
    #Configure Allowed BC List MRDC
    ${cmd1}    Set Variable    ue_enb_endc_param id=${NSA_UE_ID} allowed_bc_list_mrdc=${bc_list}
    log to console  executing_command-${cmd1}
    Execute Egate Command    ${cmd1}
    #Configure or Release Measurement Gaps
    ${a}    Set Variable
    ...    ue_enb_param id=${NSA_UE_ID} measurement_gap=${meas_gap_config} mgta=ms0 gap_purpose=${gap_pur} gap_trigger=${gapTrig}
    ${b}  Set Variable  override_meas_freq_mn=${measFreq} override_meas_gap_config_mn=on
    ${cmd2}    Catenate       ${a}    ${b}
    log to console  executing_command-${cmd2}
    Execute Egate Command    ${cmd2}
    #Configure serving_cell_index_range_scg
    ${cmd3}    Set Variable     enb_endc_param id=1 serving_cell_index_range_scg=${scellidx}
    log to console  executing_command-${cmd3}
    Execute Egate Command    ${cmd3}
    #5G Attach
    Start Log   cprt
    ${en_dc_start_cmd}=  catenate  SEPARATOR=${SPACE}
     ...  enb_ue_dc_start target_gnb=${Target_gNB} target_cells=${Trgt_Cell} ue=${NSA_UE_ID}
     ...  bearer=${Bearer_ID} type=split_scg
    ${output1}   Execute Egate Command And Wait For Data   ${en_dc_start_cmd}
    ...		pass_regexp=${UE_attach_pattern}    timeout=${Timeout_NSA}
    ${path}    Stop log     cprt    test_scenario=ue_${NSA_UE_ID}_5g_attach
    log to console      path-${path}
#    Get AllowedBC ListMRDC from SGNB Addition    ${path}[cprt]
    Create File     ${OUTPUT_DIR}/regst_nsa_${NSA_UE_ID}.txt     ${output1}
    ${crnti_value}=    Run     cat ${OUTPUT_DIR}/regst_nsa_${NSA_UE_ID}.txt|grep -i newUE-Identity |awk '{print $2}'|cut -d ',' -f 1
    BuiltIn.Log     ${crnti_value}
	Append To List  ${crnti_list_nsa}   ${crnti_value}
	Log to Console  crnti_list-${crnti_list_nsa}

    Log to Console             nsa_ue_register_is_ok with ${crnti_value}
    BuiltIn.Log                nsa_ue_register_is_ok with ${crnti_value}
    END
    [Return]      ${crnti_list_nsa}

Get AllowedBC ListMRDC from SGNB Addition
    [Arguments]    ${cprt_path}
    ${pdmlFile}    analyzer.pcap_to_pdml    ${cprt_path}/NODECPRT_GNB.pcap      x2ap
    ${crnti}      analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                        packetName=nr-rrc.newUE_Identity
    ...                                        path=.*newUE_Identity$
    ...                                        endPacket=1
    log to console     cnrti-${crnti}

    ${allowedBC}      analyzer.get_shownames           pdmlFile=${pdmlFile}
    ...                                                packetName=nr-rrc.allowedBC_ListMRDC
    ...                                                path=nr-rrc.allowedBC_ListMRDC.*bandCombinationIndex$
    ...                                                kind=show
    ...                                                endPacket=${1}

    log to console      allowedBC-${allowedBC}

 Trigger SgNB Modification with measConfigMN release
    [Arguments]    ${start_ue}    ${end_ue}    ${allowed-BC}    ${measGap}=forced_release
    ...    ${measFreq}=off    ${gap_pur}=none    ${gap_trig}=enb_and_gnb_triggered
    ...    ${isCsiOverride}=False   ${isFeatureTrue}=True   ${isbuf}=False

    ${regex}    Set Variable    x2ap::SgNBReconfigurationComplete sent to ENB-2
    FOR    ${idx}   IN RANGE    ${start_ue}    ${end_ue}+1
    Start Log   btslog  cprt
    ${cmd1}  Set Variable    ue_sgnb_mod_param id=${idx} allowed_bc_list_mrdc=${allowed-BC} exclude_sgnb_security_key=yes
    log to console  executing_command-${cmd1}
    Execute Egate Command    ${cmd1}

#    ${cmd2}  Set Variable
#    ...  ue_enb_param id=${idx} measurement_gap=${measGap} mgta=ms0 gap_purpose=${gap_pur} gap_trigger=${gap_trig} override_meas_freq_mn=${measFreq}
    ${a}  Set Variable  ue_enb_param id=${idx} measurement_gap=${measGap} mgta=ms0 gap_purpose=${gap_pur} gap_trigger=${gap_trig}
    ${b}  Set Variable  override_meas_freq_mn=${measFreq} override_meas_gap_config_mn=on
    ${cmd2}    Catenate       ${a}    ${b}
    log to console  executing_command-${cmd2}
    Execute Egate Command    ${cmd2}

    ${cmd3}  Set Variable   enb_ue_dc_modify ue=${idx} cause=RN_improve_user_bit_rate by=enb ambr=10000000000:10000000000
    log to console  executing_command-${cmd3}

    ${regex1}    Set Variable    x2ap::SgNBReconfigurationComplete sent to ENB-2
    ${regex2}    Set Variable    ENB-1: Ignoring received X2 message: No handling yet for SgNBModificationRequestReject
    ${regex3}    Set Variable    ENB-1: Ignoring received X2 message: No handling yet for SgNBModificationRequestReject
#    ${regex2}    Set Variable    ENB-1: UE${idx}: PDCP Status Report will not be sent to UE
#    ${regex3}    Set Variable    UEC-1: UE${idx}: IS IDLE

    ${x}    Set Variable if    ${isFeatureTrue}==False      ${regex2}   ${regex1}
    ${regex}     Set Variable if    ${isCsiOverride}==False    ${x}     ${regex3}

    ${output1}  Execute Egate Command And Wait For Data   ${cmd3}	pass_regexp=${regex}    timeout=120
    Run keyword if      '${isbuf}'=='True'
    ...    sleep   5s
    ${path}    Stop log     cprt   btslog    test_scenario=ue_${idx}_sgnb_modify
    log to console    sgnb-modification-path-${path}
    END

 Trigger SgNB Modification with measConfigMN Setup
    [Arguments]    ${start_ue}    ${end_ue}    ${allowed-BC}    ${measGap}=gp0:0
    ...    ${measFreq}=off    ${gap_pur}=perUE    ${gap_trig}=enb_and_gnb_triggered
    ...    ${isCsiOverride}=False   ${isFeatureTrue}=True   ${isbuf}=False

    FOR    ${idx}   IN RANGE    ${start_ue}    ${end_ue}+1
    Start Log   btslog  cprt
    ${cmd1}  Set Variable    ue_sgnb_mod_param id=${idx} allowed_bc_list_mrdc=${allowed-BC} exclude_sgnb_security_key=yes
    log to console  executing_command-${cmd1}
    Execute Egate Command    ${cmd1}

    #To Configure measuredFrquenciesMN enable meas_config_sn
    ${cmd2}  Set Variable    ue_sgnb_mod_param id=${idx} meas_config_sn=520110,125290,396970
    log to console  executing_command-${cmd2}
    Execute Egate Command    ${cmd2}

    ${a}  Set Variable  ue_enb_param id=${idx} measurement_gap=${measGap} mgta=ms0 gap_purpose=${gap_pur} gap_trigger=${gap_trig}
    ${b}  Set Variable  override_meas_freq_mn=${measFreq} override_meas_gap_config_mn=on
    ${cmd3}    Catenate       ${a}    ${b}
    log to console  executing_command-${cmd3}
    Execute Egate Command    ${cmd3}

    ${regex1}    Set Variable    x2ap::SgNBReconfigurationComplete sent to ENB-2
    ${regex2}    Set Variable    ENB-1: Ignoring received X2 message: No handling yet for SgNBModificationRequestReject
    ${regex3}    Set Variable    ENB-1: Ignoring received X2 message: No handling yet for SgNBModificationRequestReject
#    ${regex2}    Set Variable    ENB-1: UE${idx}: PDCP Status Report will not be sent to UE
#    ${regex3}    Set Variable    UEC-1: UE${idx}: IS IDLE

    ${x}    Set Variable if    ${isFeatureTrue}==False      ${regex2}   ${regex1}
    ${regex}     Set Variable if    ${isCsiOverride}==False    ${x}     ${regex3}

    ${cmd4}  Set Variable   enb_ue_dc_modify ue=${idx} cause=RN_improve_user_bit_rate by=enb ambr=10000000000:10000000000
    log to console  executing_command-${cmd4}
    ${output1}  Execute Egate Command And Wait For Data   ${cmd4}	pass_regexp=${regex}    timeout=120
    Run keyword if      '${isbuf}'=='True'
    ...    sleep   5s
    ${path}    Stop log     cprt   btslog    test_scenario=ue_${idx}_sgnb_modify
    END

MultiUE Get PDSCH UE Stats for Given CC
    [Arguments]    ${start_ue}    ${end_ue}    ${scell_id}=0
    FOR    ${idx}   IN RANGE    ${start_ue}    ${end_ue}+1
    Get PDSCH UE Stats for Given CC    ue_id=${idx}   scell_idx=${scell_id}
    END

MultiUE Get PUSCH UE Stats for Given CC
    [Arguments]    ${start_ue}    ${end_ue}    ${scell_id}=0
    FOR    ${idx}   IN RANGE    ${start_ue}    ${end_ue}+1
    Get PUSCH UE Stats for Given CC    ue_id=${idx}   scell_idx=${scell_id}
    END

Validate Counters
    [Arguments]     ${pm_files_location}    ${moc}    ${expected_val}
    [Documentation]    Validation of Below Counters will be done
     ...    M55112C04001: X2_SGNB_MOD_REQ_RECEIVD
     ...    M55112C04002: X2_SGNB_MOD_REQ_ACK_SNT
     ...    M55112C04003: X2_SGNB_MOD_FAIL_MISC_UNSPC
     ...    M55112C04004: X2_SGNB_MOD_FAIL_NO_RADIO_RS
     ...    M55112C00022: X2_SGNB_MEASGP_SETUP_REQST
     ...    M55112C00023: X2_SGNB_MEASGP_SETUP_ACK
     ...    M55112C00041: X2_SGNB_MEASGP_REL_MOD_REQ
     ...    M55112C00042: X2_SGNB_MEASGP_REL_MOD_ACK
     ...    M55112C00029: NX2CC_INTRA_CELL_PSCEL_CHG_ATT
     ...    M55112C00030: NX2CC_INTRA_CELL_PSCEL_CHG_SUC
     ...    M55114C00021: SGNB_SCELL_1_ADMISSION_REQ
     ...    M55114C00028: SGNB_SCELL_1_ADMISSION_SUCC
     ...    M55114C00035: SGNB_SCELL_ADMISSION_UNSUCC
     ...    M55114C00038: SGNB_NSA_AC_SUCC_DUE_CHANGE
     ...    M55118C02000: RRC_RECONF_1_SCELL_DL_ATT
     ...    M55118C03000: RRC_RECONF_1_SCELL_DL_SUCC
     ...    M55308C11001: SLOTS_UE_DRX_ACTIVE
     ...    M55308C11002: SLOTS_UE_DRX_SLEEP

    ${pi_list}    Get Dictionary Keys    ${expected_val}
    @{counter_value} =  Create List
    FOR    ${counter}    IN    @{pi_list}
    log to console    validation-of-${counter}-is-started
#    ${actual_pm_values}    Get PM counter value   pm_files_location=${pm_files_location}/gnb_pm_counters  moc=${moc}    pi_id=${counter}
#    ${actual_pm_values}   convert to integer    ${actual_pm_values}
    ${actual_pm_values}    fetch_counter_value.get_latest_counter_value  ${pm_files_location}/gnb_pm_counters   ${moc}   ${counter}
    Run keyword if    '${counter}'!='M55308C11001'
    ...     Run keywords
    ...     log to console     ${counter}-updated-with-${actual_pm_values}-expected-${expected_val}[${counter}]
    ...     AND     should be equal    ${expected_val}[${counter}]    ${actual_pm_values}
    ...     AND     log to console     validation-of-${counter}-is-completed
    ...     ELSE    Run keywords
    ...     log to console     ${counter}-updated-with-${actual_pm_values}
    ...     AND     Should Be True     ${actual_pm_values} > ${expected_val}[${counter}]
    ...     AND     log to console     validation-of-${counter}-is-completed
    END
    log to console    all-counters-validation-successful

Validation of measConfigMN
    [Arguments]    ${measConfig_val}    ${isBuffBasedScellAdd}=0

    #Get UE Ids using Get Dictionary Keys
    ${ue_list}    Get Dictionary Keys    ${measConfig_val}

    FOR     ${ue}   IN    @{ue_list}
    ${keys}    Get Dictionary Keys    ${measConfig_val}[${ue}]
    ${cprt_path}    Set Variable    ${LOG_PATH}/${TEST_NAME}/gNB/cprt/ue_${ue}_sgnb_modify
    ${fil1}    Set Variable     x2ap.SgNBModificationRequest_element
    ${fil2}    Set Variable     x2ap.SgNBModificationRequestAcknowledge_element
    ${fil3}    Set Variable     x2ap.SgNBModificationRequired_element

    ${pdmlFile1}    analyzer.pcap_to_pdml    ${cprt_path}/NODECPRT_GNB.pcap      ${fil1}
    ${pdmlFile2}    analyzer.pcap_to_pdml    ${cprt_path}/NODECPRT_GNB.pcap      ${fil2}
    ${pdmlFile3}    analyzer.pcap_to_pdml    ${cprt_path}/NODECPRT_GNB.pcap      ${fil3}

    Log to console    keys-@{keys}
    FOR    ${key}   IN  @{keys}
    ${packet}   Set variable if
    ...     '${key}'=='measGapConfig' or '${key}'=='gapPurpose'     ${fil1}
    ...     '${key}'=='bandCombinationIndex' and '${isBuffBasedScellAdd}'=='0'   ${fil2}
    ...     '${key}'=='bandCombinationIndex' and '${isBuffBasedScellAdd}'=='1'   ${fil3}
    ...     '${key}'=='sCellIndex' and '${isBuffBasedScellAdd}'=='0'   ${fil2}
    ...     '${key}'=='sCellIndex' and '${isBuffBasedScellAdd}'=='1'   ${fil3}
    ...     '${key}'=='physCellId' and '${isBuffBasedScellAdd}'=='0'   ${fil2}
    ...     '${key}'=='physCellId' and '${isBuffBasedScellAdd}'=='1'   ${fil3}
    ...     '${key}'=='drx_Config' and ${measConfig_val}[${ue}][${key}]==1     ${fil3}
    ...     '${key}'=='drx_Config' and ${measConfig_val}[${ue}][${key}]==0     ${fil2}

    log to console    selected-packet-${packet}

    ${packet_path}   Set variable if
    ...     '${key}'=='measGapConfig' or '${key}'=='gapPurpose'     ${pdmlFile1}
    ...     '${key}'=='bandCombinationIndex' and '${isBuffBasedScellAdd}'=='0'   ${pdmlFile2}
    ...     '${key}'=='bandCombinationIndex' and '${isBuffBasedScellAdd}'=='1'   ${pdmlFile3}
    ...     '${key}'=='sCellIndex' and '${isBuffBasedScellAdd}'=='0'   ${pdmlFile2}
    ...     '${key}'=='sCellIndex' and '${isBuffBasedScellAdd}'=='1'   ${pdmlFile3}
    ...     '${key}'=='physCellId' and '${isBuffBasedScellAdd}'=='0'   ${pdmlFile2}
    ...     '${key}'=='physCellId' and '${isBuffBasedScellAdd}'=='1'   ${pdmlFile3}
    ...     '${key}'=='drx_Config' and ${measConfig_val}[${ue}][${key}]==0     ${pdmlFile2}
    ...     '${key}'=='drx_Config' and ${measConfig_val}[${ue}][${key}]==1     ${pdmlFile3}

    log to console    selected-pdml-file-${pdmlFile3}

    ${var}   Run keyword if  '${key}'=='physCellId'
    ...     analyzer.get_shownames          pdmlFile=${packet_path}
    ...                                     packetName=${packet}
    ...                                     path=nr-rrc.${key}$
    ...                                     endPacket=1
    ...                                     kind=show
    ...     ELSE
    ...     analyzer.get_unique             pdmlFile=${packet_path}
    ...                                     packetName=${packet}
    ...                                     path=nr-rrc.${key}$
    ...                                     endPacket=1
    ...                                     kind=show
    log to console    ${var}
    should be equal    ${var}    ${measConfig_val}[${ue}][${key}]
    END
    END


Validation of X2AP Modification Failure
    [Arguments]    ${Start_ue}  ${end_ue}   ${isUpd}=False

    ${path}    Set Variable if   ${isUpd}==False    x2ap.misc    x2ap.protocol
    FOR     ${idx}  IN RANGE    ${Start_ue}  ${end_ue}+1
    ${cprt_path}    Set Variable    ${LOG_PATH}/${TEST_NAME}/gNB/cprt/ue_${idx}_sgnb_modify

    ${pdmlFile}    analyzer.pcap_to_pdml    ${cprt_path}/NODECPRT_GNB.pcap    x2ap.SgNBModificationRequestReject_element

    ${x2ap_cause}       analyzer.get_unique      pdmlFile=${pdmlFile}
    ...                                          packetName=x2ap.SgNBModificationRequestReject_element
    ...                                          path=${path}$
    ...                                          endPacket=1
    log to console     x2ap_cause-${x2ap_cause}
    should be equal    ${x2ap_cause}    4
    END

Validation of F1AP Context Modification Failure
    [Arguments]    ${Start_ue}  ${end_ue}

    FOR     ${idx}  IN RANGE    ${Start_ue}  ${end_ue}+1
    ${cprt_path}    Set Variable    ${LOG_PATH}/${TEST_NAME}/gNB/cprt/ue_${idx}_sgnb_modify

    ${pdmlFile}     analyzer.pcap_to_pdml    ${cprt_path}/NODECPRT_GNB.pcap   f1ap.UEContextModificationFailure_element

    ${f1ap_cause}       analyzer.get_unique      pdmlFile=${pdmlFile}
    ...                                          packetName=f1ap.UEContextModificationFailure_element
    ...                                          path=f1ap.radioNetwork$
    ...                                          endPacket=1
    log to console     f1ap_cause-${f1ap_cause}
    should be equal    ${f1ap_cause}    8
    END

A1 based SCell Addtion
    [Arguments]    ${start_ue}    ${end_ue}   ${CarrierFreq}=520110   ${phycellid}=53
    FOR   ${ue}    IN RANGE    ${start_ue}    ${end_ue}+1
    ${reg}     Set Variable    === UE${ue} NR MEASUREMENT IDENTITIES:(.|\r|\n)?======
    ${reg1}    Set Variable    ENB-1: UE${ue}: === SgNB Modification is successful ===.*
    Start log       btslog    cprt
    ${ue_meas_id}   Set Variable    ue_cfg_meas_disp id=${ue}
    ${output}	Execute Egate Command And Wait For Data   ${ue_meas_id}    pass_regex=${reg}   timeout=120
    Log to Console    ${output}
    Create File     ${OUTPUT_DIR}/covBaseA1_${ue}.txt     ${output}
    ${measObj}    Run   cat ${OUTPUT_DIR}/covBaseA1_${ue}.txt|grep -i NR.*${CarrierFreq}|awk '{print $1}'
    log to console    measurement-object-${measObj}
    ${NRrepConf}    Run   cat ${OUTPUT_DIR}/covBaseA1_${ue}.txt|grep -i NR.*EventA1|awk '{print $1}'
    log to console    NR-Report-Config-${NRrepConf}
    ${x}    Catenate    SEPARATOR=${SPACE * 9}    ${measObj}    ${NRrepConf}
    log to console  x-${x}
    ${NrMeasId}    Run    cat ${OUTPUT_DIR}/covBaseA1_${ue}.txt|grep -i '${x}'|awk '{print $1}'
    log to console    NR-Measurement-Id-${NrMeasId}
    #Trigger A1 measurement for SCell Addition
    ${cmd}  Set Variable
    ...     ue_measurement_send_nr id=${ue} meas_id=${NrMeasId} event=A1 srsrp_nr=42 ssinr_nr=42 srsrq_nr=44 phycell_id=${phycellid}
    ${output1}	Execute Egate Command And Wait For Data   ${cmd}    pass_regex=${reg1}   timeout=120
    Log to Console    ${output1}
    Stop log    cprt    btslog    test_scenario=ue_${ue}_A1_Based_SCell_Add
    END

Display UE Meas Config and Trigger A2
    [Arguments]    ${start_ue}    ${end_ue}    ${CarrierFreq}=125290
    FOR   ${ue}    IN RANGE    ${start_ue}    ${end_ue}+1
    ${reg}     Set Variable    === UE${ue} NR MEASUREMENT IDENTITIES:(.|\r|\n)?======
    ${reg1}    Set Variable    ENB-1: UE${ue}: === SgNB Modification is successful ===.*
    Start log       btslog    cprt
    ${ue_meas_id}   Set Variable    ue_cfg_meas_disp id=${ue}
    ${output}	Execute Egate Command And Wait For Data   ${ue_meas_id}    pass_regex=${reg}   timeout=120
    Log to Console    ${output}
    Create File     ${OUTPUT_DIR}/trig_A2_${ue}.txt     ${output}
    ${measObj}    Run   cat ${OUTPUT_DIR}/trig_A2_${ue}.txt|grep -i NR.*${CarrierFreq}|awk '{print $1}'
    log to console    measurement-object-${measObj}
    ${NRrepConf}    Run   cat ${OUTPUT_DIR}/trig_A2_${ue}.txt|grep -i NR.*EventA2|awk '{print $1}'
    log to console    NR-Report-Config-${NRrepConf}
    ${x}    Catenate    SEPARATOR=${SPACE * 9}    ${measObj}    ${NRrepConf}
    log to console  x-${x}
    ${NrMeasId}    Run    cat ${OUTPUT_DIR}/trig_A2_${ue}.txt|grep -i '${x}'|awk '{print $1}'
    log to console    NR-Measurement-Id-${NrMeasId}
    #Trigger A1 measurement for SCell Addition
    ${cmd}  Set Variable
    ...     ue_measurement_send_nr id=${ue} meas_id=${NrMeasId} event=A2 srsrp_nr=8 ssinr_nr=8 srsrq_nr=8
    ${output1}	Execute Egate Command And Wait For Data   ${cmd}    pass_regex=${reg1}   timeout=120
    Log to Console    ${output1}
    Stop log    cprt    btslog    test_scenario=ue_${ue}_trig_A2
    END

Validation of SCell Addition due to A1
    [Arguments]    ${scell_add_Val}
    #Get UE Ids using Get Dictionary Keys
    ${ue_list}    Get Dictionary Keys    ${scell_add_Val}
    FOR     ${ue}   IN    @{ue_list}
    ${keys}    Get Dictionary Keys    ${scell_add_Val}[${ue}]
    ${cprt_path}    Set Variable    ${LOG_PATH}/${TEST_NAME}/gNB/cprt/ue_${ue}_A1_Based_SCell_Add
    ${filter}    Set Variable     x2ap.SgNBModificationRequired_element && nr-rrc.sCellToAddModList == 1
    ${pdmlFile}    analyzer.pcap_to_pdml    ${cprt_path}/NODECPRT_GNB.pcap      ${filter}
    Log to console    keys-@{keys}
    FOR    ${key}   IN  @{keys}
    ${var}      analyzer.get_unique         pdmlFile=${pdmlFile}
    ...                                     packetName=x2ap.SgNBModificationRequired_element
    ...                                     path=nr-rrc.${key}$
    ...                                     endPacket=1
    ...                                     kind=show
    log to console    ${var}
    should be equal    ${var}    ${scell_add_Val}[${ue}][${key}]
    END
    END

Get Avg DL Data Traffic per CC
    [Arguments]    ${ue_lists}    ${pscell}=8     ${scell}=8
    #ue_lists is a dictionary with UE IDs as keys
    ${ue_list}    Get Dictionary Keys    ${ue_lists}
    FOR     ${ue}   IN    @{ue_list}
    ${tmp_list}     Create List
    FOR     ${cell}   IN RANGE     ${pscell}    ${scell}+1
    ${avg_data_dl}    Get Average DL DATA TRAFFIC For Given CC    ue_id=${ue}    scell_idx=${cell}
#    log to console     dl-avg-data-${avg_data_dl}
    Append To List    ${tmp_list}    ${avg_data_dl}
#    log to console    updated-${ue_lists}
    END
    Set To Dictionary	${ue_lists}    	${ue}=${tmp_list}
    END
    log to console    DL_AVG_DATA-${ue_lists}
    [return]    ${ue_lists}

Get Avg UL Data Traffic per CC
    [Arguments]    ${ue_lists}    ${pscell}=8     ${scell}=8
    #ue_lists is a dictionary with UE IDs as keys
    ${ue_list}    Get Dictionary Keys    ${ue_lists}
    FOR     ${ue}   IN    @{ue_list}
    ${tmp_list}     Create List
    FOR     ${cell}   IN RANGE     ${pscell}    ${scell}+1
    ${avg_data_ul}    Get Average UL DATA TRAFFIC For Given CC    ue_id=${ue}    scell_idx=${cell}
#    log to console     ul-avg-data-${avg_data_ul}
    Append To List    ${tmp_list}    ${avg_data_ul}
#    log to console    updated-${ue_lists}
    END
    Set To Dictionary	${ue_lists}    	${ue}=${tmp_list}
    END
    log to console    UL_AVG_DATA-${ue_lists}
    [return]    ${ue_lists}

Validation of Data before and After PSCell Change
    [Arguments]    ${avg_data_pre}    ${avg_data_post}
    ${status}  avg_dl_data.compare_pre_post_avg_data    ${avg_data_pre}    ${avg_data_post}
    Run Keyword And Ignore Error    Should Be True    '${status}' == 'Pass'

Trigger UE Capability IE Modification
   [Arguments]    ${st_nsa_ue}		${en_nsa_ue}	${inc_ue_cap}=True  #${ue_nr_cap}	${ue_eu_nr_cap}

   FOR    ${idx}   IN RANGE    ${st_nsa_ue}    ${en_nsa_ue}+1
    ${cmd1}  Set Variable
    ...   ue_sgnb_mod_addl_param id=${idx} include_ue_capabilities=on ue_nr_capabilities=${ue_nr_cap} ue_eutra_nr_capabilities=${ue_eu_nr_cap}

    ${cmd2}  Set Variable      ue_sgnb_mod_addl_param id=${idx} include_ue_capabilities=off
    ${cmd}  Set Variable if    '${inc_ue_cap}'=='True'    ${cmd1}   ${cmd2}
    log to console  executing_command-${cmd}
    Execute Egate Command    ${cmd}
    sleep   5s
    END
