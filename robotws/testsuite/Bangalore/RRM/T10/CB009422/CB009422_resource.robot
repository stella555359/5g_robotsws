*** Settings ***
Documentation    Suite documentation

Variables    ta5g_global_var
Resource       taf/rfrl/common_resources/robot/coam.robot
Resource       taf/rfrl/common_resources/robot/libraries_instances.robot
Library        ../../../resources/NPS/SWENG/python_libs/luashark_tools.py
Resource       ../../../resources/NPS/SWENG/robot/PacketSearch.robot
Resource       ../../../resources/robot/Setup_Env.robot
Resource       ../../../resources/robot/common_log_collection.robot
Resource        ../../../resources/ECEcommon/common_file_operation.robot
Resource         ../../../resources/robot/Airphone.robot
#Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource        ../../../resources/robot/wts_sim_keywords.robot
Resource         ../../../resources/robot/PM_Counters.robot
Resource         ../../../resources/robot/TTI_Traces.robot
Resource         ../../../resources/robot/Iperf_Traffic.robot
Library          ../../../resources/python/ssh_command.py
Library          ./python/increase_buffer_size.py
Library        luashark_tools.analyzer       WITH NAME       analyzer
Library        ute_admin                         WITH NAME   ute_adm
Library        taf.collectors.btslog  WITH NAME   btslog
Library        taf.sbts.oam.coam  WITH NAME   cOaM
Library        Collections
Library        OperatingSystem
Library        ta5g_tshark
Library        ta5g_commissioning
Library        taf.analyzer.pdml     WITH NAME    taf_pdml_analyser
Library        taf.transport.ssh                 WITH NAME    csn
Library           XML    use_lxml=True    WITH NAME    Myxml
Library          ../../../resources/python/TTI_Converter.py    WITH NAME    TtiConvert
Library          ../../../resources/python/BIP_Capture.py
Library          ../../../resources/python/CPRT_Capture.py
Library          ./python/CB009422_Verification.py
Library          DateTime
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          ta_a2a
Resource    ../../../resources/robot/Capture.robot
Resource    ../../../resources/NPS/SWENG/robot/Backup.robot
Resource    ../../../resources/robot/common_log_collection.robot

*** Variables ***
&{GNB_ASIK}                ip=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik
&{AP_ASIK}                 ip=192.168.200.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=APAsik
${port}                    22

${pdu_mod_with_5qi-5}     Added QosFlow with QFI:2 fiveQI:5
${pdu_mod_with_5qi-1}     Added QosFlow with QFI:3 fiveQI:1

${nsa_nr_cap_band66}       SEPARATOR=
...                        E1201000014F5E0302C002054004820D9C4C3E141C04D8041FF9863CA160704C020311406014C200141F107586368E9
...                        315047F2CA4D940E0416C9824060C78C7FE618F28581C0E1E026AA9C06AA9C0002106020F2687C03904000002904000
...                        00A90400001292500001A601F066F2A6F036B7580282000012CA4A080000CB29282000052CA4A080001CB2928200009
...                        2CA4A480002A9652501741B2E9565D03C9A55934AB22BB902401E0068040200000020

${nsa_nr_mrdc_band66}       A10181102C0C03882000000888160641C460000024400401C041200210000804040080108000802020040080

${sa_nr_cap_band66}         SEPARATOR=
...                         E1A01000014F5E0302C0020840009041B38987C284804D8041FF9863CA160704C060188A0300A63000A0F883AC31
...                         B47498A823F96524CA0D00416C9824060C78C7FE618F28581C0E1E026FFDC06FFDC001003882000000004041E4D0
...                         F8012080000040070668000800004B292001A0D142C00F00340201000000000004008010A41E070180018040

#UE Cap for 5MHz Band 71
${nsa_nr_cap_band71}       SEPARATOR=
...                         E1A01000014F5E0302C0020840009041B38987C284804D8041FF9863CA160704C060188A0300A63000A0F88DAC31
...                         B47498A823F96524CA0D00416C9824060C78C7FE618F28581C0E1E026FFFFF6FFFFF02001800000000388C000000
...                         00841808DC9A1F00E41000000A41000002A41000004A494000069806C0DAC05AC088C0DA0282000012CA4A080000
...                         CB29282000052CA4A080001CB29282000092CA4A480002A9652500D402AA80D5502AAA07542C00F0034020100000
...                         0000004008010A41E07018001804


${nsa_nr_mrdc_band71}       A10181102C0C03882000000888160641C460000024400401C041200210000804040080108000802020040080

${sa_nr_cap_band71}         SEPARATOR=
...                         E1A01000014F5E0302C0020840009041B38987C284804D8041FF9863CA160704C060188A0300A63000A0F88DAC31
...                         B47498A823F96524CA0D00416C9824060C78C7FE618F28581C0E1E026FFFFF6FFFFF02001800000000388C000000
...                         00841808DC9A1F00E41000000A41000002A41000004A494000069806C0DAC05AC088C0DA0282000012CA4A080000
...                         CB29282000052CA4A080001CB29282000092CA4A480002A9652500D402AA80D5502AAA07542C00F0034020100000
...                         0000004008010A41E07018001804


${small_bwp_sa}             SEPARATOR=
...                         FFA00000074E7A031E000386A00003C100101809306400043C34003120D0098140180E01951B0A35820286809659
...                         44C4C001EB608080838778E1C830E0008193C7D5C00FFC007003FF000A8D899AC10143404B2CA2626000F5B04040
...                         41C3BC70E418700040C9E3EAE003FE003800FF800546C4DD6080A1A02596513130007AD8202020E1DE38720C3800
...                         2064F1F57001FF001C007FC002A36276B04050D012CB289898003D6C10101070EF1C39061C00103278FAA8000028
...                         000000841C28000000002014148000001C020227B1780003000281C1401C0C026007000682400406024004060280
...                         000000003400202003E000000000000064CD0001000009659500149AA8B80003800580000002004008C589800081
...                         01820283038405880889098C909293139425

${medium_bwp_sa}            SEPARATOR=
...                         FFA00000074E7A031E000386A00003C100101809306400043C34003120D0098140180E01951B0A35820286809659
...                         44C4C001EB608080838778E1C830E0008193C7D5C00FFC007003FF000A8D899AC10143404B2CA2626000F5B04040
...                         41C3BC70E418700040C9E3EAE003FE003800FF800546C4DD6080A1A02596513130007AD8202020E1DE38720C3800
...                         2064F1F57001FF001C007FC002A36276B04050D012CB289898003D6C10101070EF1C39061C00103278FAA8000028
...                         000000841C28000000002014148000001C020227B1780003000281C1401C0C026007000682400406024004060280
...                         000000003400202003E0000000000000650D000100000965950014A2A8B80003800580000002004008C589800081
...                         01820283038405880889098C909293139425

${large_bwp_sa}             SEPARATOR=
...                         E1A03E00474F7BFFFFFFFF86A00003C170101E093DF3FFFFFC00D800C6F3E000503705007E380B5F7C18F789C21D
...                         881043F284C0020B6547403127D620F2107840A12DF3F009FF87E0007FE1F80008E0000038002815F7C28F789C23
...                         D881043F284C0020B6547403127D620F2107840A12DF3F005DDCFFC007773FF0008EA000038002800D9400014000
...                         000800100001517C2FF789C21D881043F284C0020B6547403127D620F2107840A12DF3F013F9EE7800FE7B9E0011
...                         C000007000502A2F883EF13843B102087E509800416CA8E80624FAC41E420F081425BE7E027FE1F8001FF87E0002
...                         3800000E000A0545F11BDE27087620410FCA1300082D951D00C49F5883C841E10284B7CFC04200080047000001C0
...                         0140A8BE267BC4E10EC40821F942600105B2A3A01893EB1079083C205096F9F80440010008EA000038002800D940
...                         001400000080010000018A0F06000308C00003D13AA0E0600E230000013D13AA0F0A000308C00023D13AA0E0A00E
...                         230000033D13AA0F0A000388C000010F44EA83C46000C2300014F44EA81C2808000C6227541E0C00060A0000E7A2
...                         7541C0C01C280000107A27541E0C00070A0000049E89D50785000182800051889F50783000181800059E89D00501
...                         1A014401829620004483214E9DB24F8B0A74ED927C5851A76C93E2C29D3B649F161429DB24F8B0A74ED927C5811B
...                         649F1614E9DB24F8B0A746D927C5853A06C93E2C28D3B649F1614E9DB24F8A09860C6318C6318C63180F81812090
...                         C82412090C82432090C8240180FE600000BE0001F001400180E0A00E062138038003800301F02C41000000208000
...                         011040000108200000C41000008208000051040000308200001C4100080802082001010051040020280820800405
...                         0140760CD64CD606D646D60EDE54D6065646501C1000009659404000065965010000296594040000E59650100004
...                         9659504000165965410000696594040001E59650075068AA4D1540E2A91C5507ABA555541E2E9545170002100BF0
...                         583C160F0583C160F0783C1600005841C0080180100300400A008010380300100800200C00402000083801001002
...                         002008004010000700600E0100240180380400810700A01601402C0300680600C0E00C0040200080300100800020
...                         E0140040280080600100C0001C0180380400900600E01002041C0280780500F00C022018040380300700801200C0
...                         1C0200408380700700E00E020024040040700E0020200040380080800000701201602802C0580680C00C10700200
...                         600400C010028020040E0140040300080500100C00020E004004008008020010040001C0280580600D00A0160180
...                         3041C0080180100300400A008010380500F00C02201403C0300808380500B00A016018034030060700A002018004
...                         0280080600010700200600400C010028020040E0040040100080100100400042C1C040C102C60BD0519DC000000080

*** Keywords ***

Perform SCF Delta Commissioning with ${delta_commissioning_file_json}
    Find Scfc And Send Delta Commissioning      scfc_filename=${delta_commissioning_file_json}

Increase Buffer Size for VM and IPHY
    increase_buffer_size.increase_buffer_size     ${AP_ASIK.ip}      ${port}    ${AP_ASIK.username}     ${AP_ASIK.password}

Online modify gnb radparam using aashell
    [Arguments]    ${radparam}    ${radval}
    increase_buffer_size.online_mod_gnb_radparam_aashell
    ...     ${GNB_ASIK.ip}      ${port}    ${GNB_ASIK.username}     ${GNB_ASIK.password}    ${radparam}    ${radval}

Load CFG and verify cell status with CPRT
    [Arguments]             ${wts_cfg_file}		${start_cell}	${end_cell}		${enb_id}=2
	Configure eth3 IP
    Start Log   btslog    cprt
	Start wts application and load CFG		${wts_cfg_file}
    Wait Until Keyword Succeeds     180s    5s	Verify_sib_mib_for_Cell		${start_cell}	${end_cell}		${enb_id}
    ${log_path_1}     Stop Log    cprt    btslog  test_scenario=cellsetup
    log to console      cprt-${log_path_1}
    set suite variable    ${log_path_1}
    Sleep   20s

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
    ...    sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.255.1:/ffs/run/swconfig.txt ${save_dir}/swconfig_gnb.txt
    OperatingSystem.Should Exist    ${save_dir}/swconfig_gnb.txt
    ${path}    Set Variable    ${save_dir}/swconfig_gnb.txt
    [Return]    ${path}

Send Swconfig File To GNB
    [Arguments]    ${path}
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p oZPS0POrRieRtu scp ${path} toor4nsn@192.168.255.1:/ffs/run/swconfig.txt
    Should Be Equal As Integers    ${rc}    0

Trigger A3 RsrpAndRsrq Measurement for intragnb HO
    [Arguments]    ${start_ue_id}    ${end_ue_id}    ${meas_event}=A3    ${source_phy_id}=50    ${dest_phycell_id}=51
    ...      ${actA3A5MRDuringDRXSetup}=True
    Log to Console   ${actA3A5MRDuringDRXSetup}
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Start log       btslog    cprt
    ${ue_meas_id}   Set Variable    ue_cfg_meas_disp id=${ue_id}
    ${output}	Execute Egate Command And Wait For Data   ${ue_meas_id}    pass_regex=UE1 NR MEASUREMENT IDENTITIES:(.|\r|\n)?======
    ...        timeout=10
    Log to Console    ${output}
#    ${data_cmd}	SET VARIABLE	ue_measurement_send_nr    id=${ue_id}    meas_id=3    event=A3    srsrp_nr=1
#    ...    srsrq_nr=1    phycell_id=${phycell_id}   nrsrp_nr=30    nrsrq_nr=20
    ${data_cmd}	SET VARIABLE    ue_measurement_send_nr id=${ue_id} meas_id=3 event=${meas_event}
    ...     srsrp_nr=19 phycell_id=${dest_phycell_id} nrsrp_nr=100
    ${output1}	Execute Egate Command And Wait For Data   ${data_cmd}    pass_regexp=rrcReconfigurationComplete    timeout=10
    Log to Console    ${output1}
    ${path_cprt}     Stop log    btslog    cprt   test_scenario=UE_${ue_id}/cprt_intra_du_ho_${source_phy_id}_to_${dest_phycell_id}
    END

Inter GNB HO SA UE measurements
    [Arguments]    ${start_ue_id}    ${end_ue_id}    ${meas_event}=A3    ${source_phy_id}=54    ${dest_phycell_id}=50
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Start log       btslog    cprt
    ${cmd1}    Set Variable
    ...     ue_history_information_list_add_ngran id=${ue_id} gnb_id=3 cell_type=medium nrcgi=311:489|0x03 time_ue_stayed_in_cell=100
    Execute Egate Command    ${cmd1}

    Execute Egate Command    cmd=ue_history_information_list id=${ue_id} action=commit
    Execute Egate Command    cmd=ue_enb_param id=${ue_id} ue_history_list=1
    Execute Egate Command    cmd=upf_param id=${ue_id} end_markers_delay=10s

    ${ue_meas_id}   Set Variable    ue_cfg_meas_disp id=${ue_id}
    ${output}	Execute Egate Command And Wait For Data   ${ue_meas_id}    pass_regex=UE1 NR MEASUREMENT IDENTITIES:(.|\r|\n)?======
    ...        timeout=10

    ${data_cmd}	 Set Variable    ue_measurement_send_nr id=${ue_id}  meas_id=1 event=${meas_event} srsrp_nr=19 phycell_id=50 nrsrp_nr=100
    ${output1}	Execute Egate Command And Wait For Data   ${data_cmd}    pass_regexp=rrcReconfigurationComplete    timeout=10
    Log to Console    ${output1}
    ${path_cprt}     Stop log    btslog    cprt   test_scenario=UE_${ue_id}/cprt_inter_gnb_ho_${source_phy_id}_to_${dest_phycell_id}
    END

Copy WTS Log Files
    ${egate_log_path}   Set Variable     ${LOG_PATH}/${TEST_NAME}/gNB/egate
    OperatingSystem.Run    mkdir ${egate_log_path}
    OperatingSystem.Run    cp ${WTS_DIR}/*.log.* ${egate_log_path}

Setup Simulator GNB
    ${cmd1}     Set variable    gnb_xn_link_up gnb=3 target=2
    ${reg1}     Set variable    GNB-3: XnAP Link with GNB-2 (10.0.1.2:38422[0]) is up
    ${output1}	Execute Egate Command And Wait For Data    ${cmd1}    pass_regex=${reg1}   timeout=10
    ${cmd_list}     Create List      gnb_param id=3 sib1_period=40      gnb_param id=3 sib2_period=40
    ...         gnb_param id=3 sib5_period=40
    FOR     ${cmd}    IN    @{cmd_list}
    Execute Egate Command        ${cmd}
    END

Location Update to Sim GNB
    [Arguments]    ${start_ue_id}    ${end_ue_id}   ${eNB}=3    ${cell}=1

    ${cmd1}     Set variable    gnb_xn_link_up gnb=3 target=2
    ${reg1}     Set variable    GNB-3: XnAP Link with GNB-2 (10.0.1.2:38422[0]) is up
    ${output1}	Execute Egate Command And Wait For Data    ${cmd1}    pass_regex=${reg1}   timeout=10

    ${cmd_list}     Create List      gnb_param id=3 sib1_period=40      gnb_param id=3 sib2_period=40
    ...         gnb_param id=3 sib5_period=40
    FOR     ${cmd}    IN    @{cmd_list}
    Execute Egate Command        ${cmd}
    END
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    ${ue_id}    Convert To String    ${ue_id}
    ${cmd2}     Set Variable    ue_change_location id=${ue_id} enb=${eNB} cell=${cell}
    ${reg2}     Set Variable    UE-${ue_id}\[OFF\]: location updated to eNB-${eNB} cell ${cell}
    ${output2}	Execute Egate Command And Wait For Data    ${cmd2}    pass_regex=${reg2}   timeout=10
    END

Intrafreq A3A5 trigger during XnHO in post HO phase leading to intra-gnb intra-DU HO SIM to Real gNB
    [Arguments]    ${start_ue_id}    ${end_ue_id}    ${meas_event}=A3    ${source_cell}=57   ${first_target}=50    ${sec_target}=51
    ...    ${if_contains}=drx_setup     ${action}=None    ${tgt_cell_ssb}=636576    ${source_sim_lcr}=1   ${first_target_real_lcr}=1
    ...    ${sec_target_real_lcr}=1

    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Start log       btslog    cprt
    ${c1}   set variable   ue_nr_rrc_reconf_param id=${ue_id} if_contains=${if_contains} action=${action} meas_type=${meas_event}
    ${c2}   set variable   tgt_phycell_id=${sec_target} tgt_cell_ssb_frequency=${tgt_cell_ssb}
    ${str1}   Catenate    ${c1}   ${c2}

    ${c3}   set variable   ue_nr_rrc_reconf_param id=${ue_id} if_contains=${if_contains} action=${action} meas_type=${meas_event}
    ${c4}   set variable   nth=2 tgt_phycell_id=${sec_target} tgt_cell_ssb_frequency=${tgt_cell_ssb}
    ${str2}   Catenate    ${c3}   ${c4}

    ${x}    set variable if    '${if_contains}'=='drx_setup'    ${str1}     ${str2}
    Execute Egate Command    ${x}

    Execute Egate Command    cmd=ue_history_information_list id=1 action=reset
    ${cmd1}    Set Variable
    ...     ue_history_information_list_add_ngran id=1 gnb_id=3 cell_type=medium nrcgi=311:489|0x01 time_ue_stayed_in_cell=100
    Execute Egate Command    ${cmd1}
    Execute Egate Command    cmd=ue_history_information_list id=1 action=commit
    Execute Egate Command    cmd=ue_enb_param id=${ue_id} ue_history_list=1

    ${ue_meas_id}   Set Variable    ue_cfg_meas_disp id=${ue_id}
    ${output}	Execute Egate Command And Wait For Data   ${ue_meas_id}    pass_regex=UE1 NR MEASUREMENT IDENTITIES:(.|\r|\n)?======
    ...        timeout=10
    ${m}    set variable if    '${meas_event}'=='A3'    1    3
    ${cmd2}	 Set Variable    ue_measurement_send_nr id=${ue_id} meas_id=${m} event=${meas_event} srsrp_nr=19 phycell_id=${first_target} nrsrp_nr=100
    ${output1}	Execute Egate Command And Wait For Data   ${cmd2}    pass_regexp=rrcReconfigurationComplete    timeout=10
    Log to Console    ${output1}
    ${reg1}    Set Variable     UE${ue_id}: Inter-eNB handover from ENB-3.${source_sim_lcr} to EXT_ENB-2.${first_target_real_lcr} performed
    ${reg2}    Set Variable     UE${ue_id}: Intra-eNB handover from EXT_ENB-2.${first_target_real_lcr} to EXT_ENB-2.${sec_target_real_lcr} performed
    BuiltIn.Should Match Regexp   ${output1}      ${reg1}
    BuiltIn.Should Match Regexp   ${output1}      ${reg2}
#    Create File     ${OUTPUT_DIR}/meas_${ue_id}.txt     ${output1}
#    ${rc1}  Run and Return Rc   cat ${OUTPUT_DIR}/meas_${ue_id}.txt |grep -i ${reg1}
#    Should Be Equal As Integers	    ${rc1}	 0
#    ${rc2}  Run and Return Rc   cat ${OUTPUT_DIR}/meas_${ue_id}.txt |grep -i ${reg2}
#    Should Be Equal As Integers	    ${rc2}	 0
    ${path_cprt}     Stop log    btslog    cprt   test_scenario=UE_${ue_id}/cprt_inter_gnb_ho_${source_cell}_to_${sec_target}
    END

Intrafreq A3A5 trigger during intra-du intra-gnb HO in post HO phase leading to XnHO Real to SIM gNB
    [Arguments]    ${start_ue_id}    ${end_ue_id}    ${meas_event}=A3    ${source_cell}=50   ${first_target}=51    ${sec_target}=58
    ...    ${if_contains}=drx_setup     ${action}=None    ${tgt_cell_ssb}=636576    ${source_real_lcr}=1   ${first_target_real_lcr}=1
    ...    ${sec_target_sim_lcr}=2

    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Start log       btslog    cprt
    ${c1}   set variable   ue_nr_rrc_reconf_param id=${ue_id} if_contains=${if_contains} action=${action} meas_type=${meas_event}
    ${c2}   set variable   tgt_phycell_id=${sec_target} tgt_cell_ssb_frequency=${tgt_cell_ssb}
    ${str1}   Catenate    ${c1}   ${c2}

    ${c3}   set variable   ue_nr_rrc_reconf_param id=${ue_id} if_contains=${if_contains} action=${action} meas_type=${meas_event}
    ${c4}   set variable   nth=2 tgt_phycell_id=${sec_target} tgt_cell_ssb_frequency=${tgt_cell_ssb}
    ${str2}   Catenate    ${c3}   ${c4}

    ${x}    set variable if    '${if_contains}'=='drx_setup'    ${str1}     ${str2}
    Execute Egate Command    ${x}
    ${ue_meas_id}   Set Variable    ue_cfg_meas_disp id=${ue_id}
    ${output}	Execute Egate Command And Wait For Data   ${ue_meas_id}
    ...   pass_regex=UE${ue_id} NR MEASUREMENT IDENTITIES:(.|\r|\n)?======        timeout=10
    ${m}    set variable if    '${meas_event}'=='A3'    3    4
    ${cmd2}	 Set Variable    ue_measurement_send_nr id=${ue_id} meas_id=${m} event=${meas_event} srsrp_nr=19 phycell_id=${first_target} nrsrp_nr=100
    ${reg3}   Set variable   GNB-3: UE${ue_id}: XN Handover Successfully completed at Target
    ${output1}	Execute Egate Command And Wait For Data   ${cmd2}    pass_regexp=${reg3}    timeout=10
    Log to Console    ${output1}
    ${reg1}    Set Variable     UE${ue_id}: Intra-eNB handover from EXT_ENB-2.${source_real_lcr} to EXT_ENB-2.${first_target_real_lcr} performed
    ${reg2}    Set Variable     UE${ue_id}: Inter-eNB handover from EXT_ENB-2.${first_target_real_lcr} to ENB-3.${sec_target_sim_lcr} performed
    BuiltIn.Should Match Regexp   ${output1}      ${reg1}
    BuiltIn.Should Match Regexp   ${output1}      ${reg2}
    ${path_cprt}     Stop log    btslog    cprt   test_scenario=UE_${ue_id}/cprt_inter_gnb_ho_${source_cell}_to_${sec_target}
    END

UE Change Location
    [Arguments]    ${st_ue_id_a3}    ${en_ue_id_a3}   ${gnb}=2    ${cell}=1
    FOR    ${ue_id}    IN RANGE    ${st_ue_id_a3}    ${en_ue_id_a3}+1
    ${cmd}    Set Variable      ue_change_location id=${ue_id} enb=${gnb} cell=${cell}
    ${output}	Execute Egate Command And Wait For Data      ${cmd}
    ...    pass_regex=UE-${ue_id}\[OFF\]: location updated to eNB-${gnb} cell ${cell}        timeout=10
    log to console      ${output}
    END

Verify UE Release Cause
    [Arguments]    ${path}
    ${pdmlFile}    analyzer.pcap_to_pdml     ${path}/NODECPRT_GNB.pcap         ngap.UEContextReleaseRequest_element
    ${cause_code}    analyzer.get_unique            pdmlFile=${pdmlFile}
    ...                                         packetName=ngap.UEContextReleaseRequest_element
    ...                                         path=.*misc$
    ...                                         endPacket=1
    Should BE Equal    ${cause_code}   5

Common TTI PCAP to CSV Converter
    [Arguments]    ${ttitrace_path}    ${dir}=dl
    ${TEST_NAME}      replace string    ${TEST_NAME}      ${SPACE}      _
    set suite variable     ${TEST_NAME}
    ${tti_path}      Set Variable     ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${ttitrace_path}
    ${tti_file_size}    Get File Size    ${tti_path}/tcpdump_ttitrace.pcap
    Run Keyword If  ${tti_file_size} <= 60000000
    ...   Decode TTI Trace    ${ttitrace_path}
    ...   ELSE
    ...   Decode TTI Trace For Large File Size    ${ttitrace_path}  ${dir}

Decode TTI Trace For Large File Size
    [Arguments]    ${ttitrace_path}  ${dir}
    Dated Log                        converting large ttitrace pcap to csv
    ${TEST_NAME}      replace string    ${TEST_NAME}      ${SPACE}      _
    set suite variable     ${TEST_NAME}
    ${tti_path}      Set Variable     ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${ttitrace_path}
    run     tcpdump -r ${tti_path}/tcpdump_ttitrace.pcap -w ${tti_path}/tti_split.pcap -C 20
    ${files}    OperatingSystem.List Files In Directory     ${tti_path}     tti_split.*
    log to console    file_list-${files}
    ${count}    Count Files In Directory    ${tti_path}     tti_split.*
    log to console    file_count-${count}
    #combine last two files
    ${a}    Evaluate    ${count}-1
    ${b}    Evaluate    ${count}-2
    ${x}    Set Variable
    ...     -w ${tti_path}/dummy.pcap ${tti_path}/tti_split.pcap${b} ${tti_path}/tti_split.pcap${a}
    ${rc}   Run And Return Rc   mergecap ${x}
    Run keyword if    ${rc}!=${0}    Fail    PCAP merging failed
    run     rm ${tti_path}/tti_split.pcap${b};rm ${tti_path}/tti_split.pcap${a}
    run     mv ${tti_path}/dummy.pcap ${tti_path}/tti_split.pcap${b}
    ${count}    Count Files In Directory    ${tti_path}     tti_split.*
    log to console    new_file_count-${count}
    FOR    ${i}  IN RANGE   0   ${count}
    Run keyword if  ${i}!=0 and 'tti_split.pcap${i}' in ${files}
    ...    run     mv ${tti_path}/tti_split.pcap${i} ${tti_path}/tti_split_${i}.pcap
    ...    ELSE
    ...    run     mv ${tti_path}/tti_split.pcap ${tti_path}/tti_split_${i}.pcap
    Dated Log         converting ${tti_path}/tti_split_${i}.pcap to ${tti_path}/output_${dir}_formated_${i}.csv
    Common Convert Ttitrace From Pcap To Excelcsv        ${tti_path}    filename=tti_split_${i}.pcap
    Common Format Tti In Stream Mode         ${tti_path}/output_${dir}.csv     ${tti_path}/output_${dir}_formated_${i}.csv
    run     rm ${tti_path}/tti_split_${i}.pcap
    END
    merge_multiple_csv      ${tti_path}   ${dir}

Decode TTI Trace For Large File Size older
    [Arguments]    ${ttitrace_path}  ${dir}
    Dated Log                        converting large ttitrace pcap to csv
    ${TEST_NAME}      replace string    ${TEST_NAME}      ${SPACE}      _
    set suite variable     ${TEST_NAME}
    ${tti_path}      Set Variable     ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${ttitrace_path}
    run     tcpdump -r ${tti_path}/tcpdump_ttitrace.pcap -w ${tti_path}/tti_split.pcap -C 22
    ${files}    OperatingSystem.List Files In Directory     ${tti_path}     tti_split.*
    log to console    file_list-${files}
    ${count}    Count Files In Directory    ${tti_path}     tti_split.*
    log to console    file_count-${count}
    FOR    ${i}  IN RANGE   0   ${count}
    Run keyword if  ${i}!=0 and 'tti_split.pcap${i}' in ${files}
    ...    run     mv ${tti_path}/tti_split.pcap${i} ${tti_path}/tti_split_${i}.pcap
    ...    ELSE
    ...    run     mv ${tti_path}/tti_split.pcap ${tti_path}/tti_split_${i}.pcap
    Dated Log         converting ${tti_path}/tti_split_${i}.pcap to ${tti_path}/output_${dir}_formated_${i}.csv
    Common Convert Ttitrace From Pcap To Excelcsv        ${tti_path}    filename=tti_split_${i}.pcap
    Common Format Tti In Stream Mode         ${tti_path}/output_${dir}.csv     ${tti_path}/output_${dir}_formated_${i}.csv
    run     rm ${tti_path}/tti_split_${i}.pcap
    END
    merge_multiple_csv      ${tti_path}   ${dir}

Decode TTI Trace For Large File Size old
    [Arguments]    ${ttitrace_path}
    Dated Log                        converting large ttitrace pcap to csv
    ${tti_path}      Set Variable     ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${ttitrace_path}
    run     /sbin/tcpdump -r ${tti_path}/tcpdump_ttitrace.pcap -w ${tti_path}/tti_split.pcap0 -C 10
    @{files}    List Files In Directory     ${tti_path}     tti_split.*
    Sort List   @{files}
    log to console    file_list-@{files}
    ${count}    Count Files In Directory    ${tti_path}     tti_split.*
    log to console    file_count-${count}
    FOR    ${i}  IN RANGE   0   ${count}
    run     cp ${tti_path}/${files}[${i}] ${tti_path}/tti_split_${i}.pcap
    Dated Log                        converting ${tti_path}/tti_split_${i}.pcap to csv
    Common Convert Ttitrace From Pcap To Excelcsv        ${tti_path}    filename=tti_split_${i}.pcap
    Common Format Tti In Stream Mode         ${tti_path}/output_dl.csv     ${tti_path}/output_dl_formated_${i}.csv
    Common Format Tti In Stream Mode         ${tti_path}/output_ul.csv     ${tti_path}/output_ul_formated_${i}.csv
    run     rm ${tti_path}/${files}[${i}];rm ${tti_path}/tti_split_${i}.pcap
    END
    merge_multiple_csv      ${tti_path}
    run     rm ${tti_path}/output_dl_formated_*.csv;rm ${tti_path}/output_ul_formated_*.csv

Add 5QI for VoNR and VINR
    [Arguments]    ${start_ue}   ${end_ue}   ${ue_to_bearer_list}   ${pdu_id}=1   ${isVoNR}=False   ${isViNR}=False

    FOR    ${ue_id}     IN RANGE    ${start_ue}      ${end_ue}+1
    ${add_5qi5}	SET VARIABLE	ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=2 by=amf
    ${output_5qi5}	Execute Egate Command And Wait For Data   ${add_5qi5}	pass_regexp=Added QosFlow with .* fiveQI:5
    ...     timeout=${Timeout_SA}
    ${ue_to_bearer_list}    Get Bearer Id and added 5QI     ${output_5qi5}    ${ue_id}    ${ue_to_bearer_list}
    BuiltIn.Log         ue=${ue_id} 5QI-5 added
	Log to Console      ue=${ue_id} 5QI-5 added
	Log to console      updated-bearer-list-${ue_to_bearer_list}
	sleep   1s

	#5QI-1 adition
	${add_5qi1}	   Set Variable if    ${isVoNR}==True	 ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=3 by=amf
    ${output_5qi1}   Run keyword if  ${isVoNR}==True
    ...     Execute Egate Command And Wait For Data   ${add_5qi1}	pass_regexp=Added QosFlow with .* fiveQI:1
    ...     timeout=${Timeout_SA}
    ${ue_to_bearer_list}   Run keyword if  ${isVoNR}==True
    ...     Get Bearer Id and added 5QI     ${output_5qi1}    ${ue_id}    ${ue_to_bearer_list}
    sleep   30s
	#5QI-2 adition
    ${add_5qi2}    Set Variable if    ${isViNR}==True    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=4 by=amf
    ${output_5qi2}   Run keyword if  ${isViNR}==True
    ...     Execute Egate Command And Wait For Data   ${add_5qi2}	pass_regexp=Added QosFlow with .* fiveQI:2
    ...     timeout=${Timeout_SA}
	 ${ue_to_bearer_list}   Run keyword if  ${isViNR}==True
    ...     Get Bearer Id and added 5QI     ${output_5qi2}    ${ue_id}    ${ue_to_bearer_list}

    Log to console      updated-bearer-list-${ue_to_bearer_list}
    END
    BuiltIn.Log       All_ue_added_an_extra_qosflow_successfully
	Log to Console    All_ue_added_an_extra_qosflow_successfully
	[return]    ${ue_to_bearer_list}

PDU Session Modification and Fetch 5QI and DRB added
    [Arguments]    ${start_ue}   ${end_ue}   ${ue_to_bearer_list}   ${qosflows_to_add}  ${5QIid}    ${pdu_id}=1
    FOR    ${ue_id}     IN RANGE    ${start_ue}      ${end_ue}+1
    ${add_5qi}	SET VARIABLE	ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qosflows_to_add} by=amf
    ${output_5qi}	Execute Egate Command And Wait For Data   ${add_5qi}	pass_regexp=Added QosFlow with .* fiveQI:${5QIid}
    ...     timeout=${Timeout_SA}
    ${ue_to_bearer_list}    Get Bearer Id and added 5QI     ${output_5qi}    ${ue_id}    ${ue_to_bearer_list}
    BuiltIn.Log         ue=${ue_id} 5QI-${5QIid} added
	Log to Console      ue=${ue_id} 5QI-${5QIid} added
	Log to console      updated-bearer-list-${ue_to_bearer_list}
	END

Get Bearer Id and added 5QI
    [Arguments]     ${output}   ${ue_id}    ${ue_to_bearer_list}
    ${bearer_list}       Create List
    Create File	    ${OUTPUT_DIR}/pdu_mod.txt	    ${output}
    ${bearer_id}    Run     cat ${OUTPUT_DIR}/pdu_mod.txt |grep -i "servedRadioBearer drb-Identity" |awk '{print $4}'|sed 's/,//g'
    ${qfi_id}       Run     cat ${OUTPUT_DIR}/pdu_mod.txt |grep -i "AMF-1: Added QosFlow with QFI:"|awk '{print $9}'|sed 's/,//g'
    ${qfi_id}       Replace String    ${qfi_id}    :    -
    log to console      ${qfi_id}_is_added_with_ue-${ue_id}
    Append To List	    ${bearer_list}    ${qfi_id}  ${bearer_id}
    Append To List	    ${ue_to_bearer_list}[${ue_id}]	    ${bearer_list}
    [return]    ${ue_to_bearer_list}

map bearer list to crnti
    [Arguments]     ${crnti_list}     ${ue_to_bearer_list}
    [Documentation]    st_sa_id  en_sa_id   variables need to define in main test case variable section
    ${crnti_to_bearer_list}    Create Dictionary
    ${Keys}   Get Dictionary Keys   ${ue_to_bearer_list}
    ${len_rnti}    Get Length      ${crnti_list}
    ${len_keys}    Get Length      ${Keys}
    should be equal     ${len_rnti}    ${len_keys}
    FOR    ${idx}   IN RANGE    ${len_rnti}
    ${rnti}    Set Variable    ${crnti_list}[${idx}]
    ${key}    Set Variable     ${Keys}[${idx}]
    Set To Dictionary   ${crnti_to_bearer_list}   ${rnti}     ${ue_to_bearer_list}[${key}]
    END
    log to console     crnti_to_bearer_list-${crnti_to_bearer_list}
    [return]    ${crnti_to_bearer_list}

Trigger MultiUE VoNR and VINR DL Traffic for SA
    [Arguments]    ${start_ue_id}   ${end_ue_id}   ${pdu_id}=1   ${isVoNR}=False   ${isViNR}=False    ${rtp_codec}=custom
    ...    ${Traffic_rate_5qi5}=kbps     ${dl_rate_5qi5}=256    ${Traffic_rate_5qi2}=mbps     ${dl_rate_5qi2}=30    ${trf_id}=1
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    #5QI-5 data
    ${data_cmd_5qi5}	Set Variable
    ... 	trf_data_start ue=${ue_idx} pdu=${pdu_id} qfi=2 dir=dl ${Traffic_rate_5qi5}=${dl_rate_5qi5} trf_id=${trf_id}
    ${output_5qi5}	 Execute Egate Command And Wait For Data   ${data_cmd_5qi5}
    ...    pass_regexp=Started Downlink Internal traffic*   timeout=10

#    ${output_5qi5}         Get Lines Matching Regexp    ${output_5qi5}    UDP DL TRF:    partial_match=${TRUE}
#    Log to Console    ${output_5qi5}

    ${data_cmd_5qi1}    Set Variable if    ${isVoNR}==True
    ...     trf_data_start ue=${ue_idx} pdu=${pdu_id} qfi=3 dir=dl trf_id=${trf_id} rtp_codec=${rtp_codec}
    ${output_5qi1}   Run keyword if  ${isVoNR}==True     #Run keywords
    ...    Execute Egate Command And Wait For Data   ${data_cmd_5qi1}
    ...    pass_regexp=Started Downlink Internal traffic Receiver*   timeout=10
#    ...    AND
#    ...    Log to Console    ue=${ue_idx} ${outpu1} VoNR_DL_traffic_data_is_started_successfully
#    ...    AND
#    ...    BuiltIn.Log       ue=${ue_idx} VoNR_DL_traffic_data_is_started_successfully

    ${data_cmd_5qi2}    Set Variable if    ${isViNR}==True
    ...    trf_data_start ue=${ue_idx} pdu=${pdu_id} qfi=4 dir=dl ${Traffic_rate_5qi2}=${dl_rate_5qi2} trf_id=1
    ${output_5qi2}   Run keyword if  ${isViNR}==True     #Run keywords
    ...     Execute Egate Command And Wait For Data   ${data_cmd_5qi2}
    ...     pass_regexp=Started Downlink Internal traffic*   timeout=10
#    ...     AND
#    ...     Log to Console    ue=${ue_idx} ${output2} VINR_DL_traffic_data_is_started_successfully
    END

Trigger MultiUE VoNR and VINR UL Traffic for SA
    [Arguments]    ${start_ue_id}   ${end_ue_id}   ${pdu_id}=1   ${isVoNR}=False   ${isViNR}=False    ${rtp_codec}=custom
    ...    ${Traffic_rate_5qi5}=kbps     ${ul_rate_5qi5}=256    ${Traffic_rate_5qi2}=mbps     ${ul_rate_5qi2}=30    ${trf_id}=1
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    ${data_cmd_5qi5}	SET VARIABLE
    ... 	trf_data_start ue=${ue_idx} pdu=${pdu_id} qfi=2 dir=ul ${Traffic_rate_5qi5}=${ul_rate_5qi5} trf_id=${trf_id}
    ${output_5qi5}	 Execute Egate Command And Wait For Data   ${data_cmd_5qi5}
    ...    pass_regexp=Started Uplink Internal traffic*   timeout=10
    ${output_5qi5}         Get Lines Matching Regexp    ${output_5qi5}    UDP UL TRF:    partial_match=${TRUE}
    Log to Console    ${output_5qi5}
    #5QI-1 data start
    ${data_cmd_5qi1}    Set Variable if    ${isVoNR}==True
    ...     trf_data_start ue=${ue_idx} pdu=${pdu_id} qfi=3 dir=ul trf_id=${trf_id} rtp_codec=${rtp_codec}
    ${output_5qi1}   Run keyword if  ${isVoNR}==True     #Run keywords
    ...    Execute Egate Command And Wait For Data   ${data_cmd_5qi1}
    ...    pass_regexp=Started Uplink Internal traffic Receiver*   timeout=10
#    ...    AND
#    ...    Log to Console    ue=${ue_idx} ${outpu1} VoNR_UL_traffic_data_is_started_successfully
#    ...    AND
#    ...    BuiltIn.Log       ue=${ue_idx} VoNR_UL_traffic_data_is_started_successfully
    #5QI-2 data start
    ${data_cmd_5qi2}    Set Variable if    ${isViNR}==True
    ...    trf_data_start ue=${ue_idx} pdu=${pdu_id} qfi=4 dir=ul ${Traffic_rate_5qi2}=${ul_rate_5qi2} trf_id=1
    ${output_5qi2}   Run keyword if  ${isViNR}==True     #Run keywords
    ...     Execute Egate Command And Wait For Data   ${data_cmd_5qi2}
    ...     pass_regexp=Started Uplink Internal traffic*   timeout=10
#    ...     AND
#    ...     Log to Console    ue=${ue_idx} ${output2} VINR_UL_traffic_data_is_started_successfully
    END

Change CFG File Value
    [Arguments]    ${file_path}    ${ul_arfcn}   ${dl_arfcn}    ${gscn}  ${sa_cap}   ${nsa_nr_cap}   ${nsa_mrdc_cap}
    ${x}    Set Variable    nr_arfcn
    ${y}    Set Variable    nr_arfcn=
    ${z}    Catenate    SEPARATOR=:   ${ul_arfcn}   ${dl_arfcn}
    ${nsa_pat}  Set Variable       ue_eutra_nr_capabilities
    ${sa_pat}   Set Variable       ue_nr_capabilities

    #arfcn change
    ${c1}   Set Variable    cat ${file_path}|grep -m 1 "${x}"|awk -F'${y}' '{print $2 }'|
    ${c2}   Set Variable    awk -F ' ' '{print $1}'|xargs -I {} sed -i 's/{}/${z}/g' ${file_path}
    Run    ${c1}${c2}
    #gscn change
    ${a1}   Set Variable    cat ${file_path}|grep -m 1 "${x}"|awk -F'gscn=' '{print $2}'|
    ${a2}   Set Variable    awk -F ' ' '{print $1}'|xargs -I {} sed -i 's/{}/${gscn}/g' ${file_path}
    Run    ${a1}${a2}

    #Below is for SA cap changes
    ${c1}   Set Variable    cat ${file_path}|grep -m 1 "${sa_pat}"|awk -F'${sa_pat}=' '{print $2}'|
    ${c2}   Set Variable    xargs -I {} sed -i 's/{}/${sa_cap}/g' ${file_path}
    Run    ${c1}${c2}
    #Below is for NSA cap changes
    #NSA_UE_NR cap changes
    ${c1}   Set Variable    cat ${file_path}|grep -m 1 "${nsa_pat}"|awk -F'${SPACE}${SPACE}dual_conn=eutra_nr' '
    ${c2}   Set Variable    {print $1}'|awk -F'${sa_pat}=' '{print $2}'|
    ${c3}   Set Variable    xargs -I {} sed -i 's/{}/${nsa_nr_cap}/g' ${file_path}
    Run    ${c1}${c2}${c3}
    #NSA DC cap changes
    ${c1}   Set Variable    cat ${file_path}|grep -m 1 "${nsa_pat}"|awk -F'${nsa_pat}=' '{print $2}'|
    ${c2}   Set Variable    xargs -I {} sed -i 's/{}/${nsa_mrdc_cap}/g' ${file_path}
    Run     ${c1}${c2}

Change ARFCN and GSCN of CFG File
    [Arguments]    ${file_path}    ${ul_arfcn}   ${dl_arfcn}    ${gscn}
    ${x}    Set Variable    nr_arfcn
    ${y}    Set Variable    nr_arfcn=
    ${z}    Catenate    SEPARATOR=:   ${ul_arfcn}   ${dl_arfcn}
    #arfcn change
    ${c1}   Set Variable    cat ${file_path}|grep -m 1 "${x}"|awk -F'${y}' '{print $2 }'|
    ${c2}   Set Variable    awk -F ' ' '{print $1}'|xargs -I {} sed -i 's/{}/${z}/g' ${file_path}
    Run    ${c1}${c2}
    #gscn change
    ${a1}   Set Variable    cat ${file_path}|grep -m 1 "${x}"|awk -F'gscn=' '{print $2}'|
    ${a2}   Set Variable    awk -F ' ' '{print $1}'|xargs -I {} sed -i 's/{}/${gscn}/g' ${file_path}
    Run    ${a1}${a2}

MultiUE NSA Attach should be Successful and Fetch CRNTI
    [Arguments]    ${start_ue_id}   ${end_ue_id}    ${Trgt_Cell}=${Target_Cells}    ${isDefCap}=True
    [Documentation]    This keyword is used at create the LTE Attach and checks the completion message in output file.
    ${crnti_list_nsa}       Create List
    FOR    ${NSA_UE_ID}    IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    ${cmd1}	SET VARIABLE	ue_attach id=${NSA_UE_ID}
    ${cmd2}	SET VARIABLE if	  ${isDefCap}==False
    ...     ue_attach id=${NSA_UE_ID} ue_nr_capabilities=${ue_nsa_nr_cap} ue_eutra_nr_capabilities=${ue_eutra_nr_cap}
    ${ue_attach_cmd}    set variable if    ${isDefCap}==True    ${cmd1}    ${cmd2}
    Execute Egate Command And Wait For Data   ${ue_attach_cmd}	pass_regexp=${LTE_attach_pattern}    timeout=${Timeout_NSA}
    BuiltIn.Log    lte_attach_is_ok
    ${en_dc_start_cmd}=  catenate  SEPARATOR=${SPACE}
     ...  enb_ue_dc_start target_gnb=${Target_gNB} target_cells=${Trgt_Cell} ue=${NSA_UE_ID}
     ...  bearer=${Bearer_ID} type=split_scg
    ${output1}  Execute Egate Command And Wait For Data   ${en_dc_start_cmd}
    ...		pass_regexp=${UE_attach_pattern}    timeout=${Timeout_NSA}
    Create File     ${OUTPUT_DIR}/regst_nsa_${NSA_UE_ID}.txt     ${output1}
    ${crnti_value}=    Run     cat ${OUTPUT_DIR}/regst_nsa_${NSA_UE_ID}.txt|grep -i newUE-Identity |awk '{print $2}'|cut -d ',' -f 1
    BuiltIn.Log     ${crnti_value}
	Append To List  ${crnti_list_nsa}   ${crnti_value}
	Log to Console  crnti_list-${crnti_list_nsa}

    Log to Console             nsa_ue_register_is_ok with ${crnti_value}
    BuiltIn.Log                nsa_ue_register_is_ok with ${crnti_value}
    END
    [Return]      ${crnti_list_nsa}

Get VM Time
    ${time}  Run    date +%d-%m-%Y
    log to console  time-${time}
    Set suite variable  ${time}
    ${cmd}  set variable
    ...   ssh toor4nsn@192.168.255.1 'timedatectl set-timezone UTC'
    Run    ${cmd}
    ${cmd1}  set variable
    ...   ssh toor4nsn@192.168.200.1 'timedatectl set-timezone UTC'
    Run    ${cmd1}

Trigger IntraFreq Intragnb A3 based HO
    [Arguments]    ${start_ue}  ${end_ue}    ${ue_to_bearer_list}    ${source_cell}=50  ${targetcell}=51
    ...    ${meas}=3    ${source_lcr}=1  ${target_lcr}=2
    Log to Console   ${source_cell}
    ${crnti_list_after_ho}      Create List
    ${crnt_to_bearer_list}      Create Dictionary
    FOR  ${ue_id}  IN RANGE    ${start_ue}    ${end_ue}+1
#    Start log       btslog    cprt
    ${ue_meas_id}   Set Variable    ue_cfg_meas_disp id=${ue_id}
    ${output}	Execute Egate Command And Wait For Data   ${ue_meas_id}
    ...   pass_regex=UE${ue_id} NR MEASUREMENT IDENTITIES:(.|\r|\n)?======        timeout=10
    ${cmd2}	 Set Variable    ue_measurement_send_nr id=${ue_id} meas_id=${meas} event=A3 srsrp_nr=19 phycell_id=${targetcell} nrsrp_nr=100
    ${output1}	Execute Egate Command And Wait For Data   ${cmd2}    pass_regexp=rrcReconfigurationComplete    timeout=10
    Log to Console    ${output1}
    ${reg1}    Set Variable     UE${ue_id}: Intra-eNB handover from EXT_ENB-2.${source_lcr} to EXT_ENB-2.${target_lcr} performed
    BuiltIn.Should Match Regexp   ${output1}      ${reg1}
    Create File	    ${OUTPUT_DIR}/crnti_list_after_ho_${ue_id}.txt	    ${output1}
    ${crnti_ho}    Run     cat ${OUTPUT_DIR}/crnti_list_after_ho_${ue_id}.txt |grep -i '${reg1}'|awk '{print $14}'
    Append To List	    ${crnti_list_after_ho}      ${crnti_ho}
    ${bearer_list}  Set Variable    ${ue_to_bearer_list}[${ue_id}]
    Set To Dictionary	${crnt_to_bearer_list} 	    ${crnti_ho}	    ${bearer_list}
#    ${path_cprt}     Stop log    btslog    cprt   test_scenario=UE_${ue_id}/intrafreq_intragnb_ho_${source_cell}_to_${targetcell}
    END
    [return]    ${crnti_list_after_ho}	 ${crnt_to_bearer_list}

Convert BIP To CSV By MCShark
    [Arguments]    ${bip_file}    ${output_file}    ${filter}    ${csv_title_list}
    [Documentation]    This keyword is to convert BIP log from pcap to csv
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${bip_log} | Yes | pcap bip log incloude bip log folder and bip log name |
    ...    | ${filter} | yes | the filter to filter the massage need to check |
    ...    | ${column_name} | yes | the column whose value need to check |
    ...    | ${csv_name_tag} | yes | the tag for BIP csv log name |

    #${tashark_version}=    Get Tshark Version
    ${mcshark_file}    Run    find /home/ute/ -name mcshark-*buster.so
    #${mcshark_file}    Set Variable    ${MCSHARK_PLUGIN}/${tashark_version}/epan/mcshark-*buster.so
    ${res}    Run Keyword And Return Status    OperatingSystem.Should Exist    ${mcshark_file}
    Run Keyword If    '${res}'=='False'    CB009422_resource.Download MCShark To UTE
    ${csv_title}=    Set Variable
    FOR    ${column}   IN    @{csv_title_list}
        ${csv_title}=    Set Variable    ${csv_title} -e ${column}
    END
    ${cmd}=    Catenate    tshark -r ${bip_file} -Y '${filter}' -T fields -e _ws.col.No. -e _ws.col.Info
    ...    ${csv_title} -E header=y -E separator=, -E quote=d -E occurrence=a > ${output_file}
    OperatingSystem.Run    ${cmd}
    OperatingSystem.File Should Not Be Empty    ${output_file}    msg=No CSV file is converted! Please check whether filter message name is changed!

Download MCShark To UTE
    [Arguments]    ${sw_version}=${SW_VERSION_TOTAL}
    ${sw_version}=    CB009422_resource.Check MCShark Version    ${sw_version}
    ${cmd}=    Set Variable    wget -r -np -nH ${MCSHARK_URL}/${sw_version}/
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    ${cmd}
    Should Be True    "${rc}"=="0"    There is no MCShark downloaded! Please contact MCshark team!
    ${tashark_version}=    Get Tshark Version
    ${MCShark}=    Run    ls -1t ${EXECDIR}/artifactory/wslte5g_plugins-local/MCShark/${sw_version}/mcshark-${tashark_version}*buster.so
    ${MCShark_list}=    String.Split To Lines    ${MCShark}
    ${MCShark_newest}=    Set Variable    @{MCShark_list}[0]
    OperatingSystem.Run    sudo rm -f ${MCSHARK_PLUGIN}/${tashark_version}/epan/mcshark-*buster.so
    ${rc}=    OperatingSystem.Run And Return Rc    sudo cp ${MCShark_newest} ${MCSHARK_PLUGIN}/${tashark_version}/epan/
    Should Be True    "${rc}"=="0"    No MCSHark file is copied to the wireshark plugin folder

Copy Preference For MCShark
    [Arguments]    ${preference_file}
    #${preference_file}=    Set Variable    /home/ute/Downloads/preferences
    Run    sudo cp ${preference_file} /home/ute/.config/wireshark/preferences
    Run    sudo cp ${preference_file} /usr/share/wireshark/preferences

Check MCShark Version
    [Arguments]    ${sw_version}=${SW_VERSION_TOTAL}
    ${list_version}=    Split String    ${sw_version}    _
    ${rest}    ${last}=    Split String From Right    ${sw_version}    _    1
    ${new_version}=    Set Variable If    "${list_version}[0]"!="SBTS00" and "${list_version}[-1]"!="000000"
    ...    ${rest}_000000      ${sw_version}
    [Return]    ${new_version}

Get Tshark Version
    ${version}=    Run    tshark -v|grep TShark|grep -P v[0-9]+.[0-9]+ -o|cut -d "v" -f 2
    [Return]    ${version}


Trigger A5 IntraFreq HO from TDD cell-1 to cell-2
    [Arguments]     ${start_ue_id}     ${end_ue_id}     ${pcell_id}
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    ${cmd1}  Set Variable    ue_measurement_send_nr id=${ue_id} meas_id=4 event=A5 srsrp_nr=18 phycell_id=${pcell_id} nrsrp_nr=85
    ${output1}  Execute Egate Command    ${cmd1}    pass_regexp=Handover will be triggered    timeout=30
    END

CB009422_Verification
    [Arguments]     ${max_ueperslot}
    Start TTI_TRACE custom     ${51}
    sleep   1s
    ${path_SCN_K1_K2}   Stop log    ttitrace    test_scenario=good_condition

    OperatingSystem.Run    cp ${WTS_DIR}/egate_console.log ${LOG_PATH}

    Common TTI PCAP to CSV Converter    good_condition   dir=dl
    Common TTI PCAP to CSV Converter    good_condition   dir=ul

#   Verification of Max UEs per slot from TTI trace
#    Verify_Max_UEs_PerSlot    ${path_SCN_K1_K2}[ttitrace]/output_dl_formated.csv    ${max_ueperslot}
#    Verify_Max_UEs_PerSlot    ${path_SCN_K1_K2}[ttitrace]/output_ul_formated.csv    ${max_ueperslot}

#   Verification of K2 against all DL_slots from TTI trace
    Verify_K2    ${path_SCN_K1_K2}[ttitrace]/output_ul_formated.csv

#   Verification of K1 against all DL_slots from TTI trace
    Verify_K1    ${path_SCN_K1_K2}[ttitrace]/output_dl_formated.csv    actEnhancedPDSCHSchSplSlot=${0}    guardPeriodLength=${6}

#   Verification of HARQ slots from TTI trace
    Verify_HARQ_slots    ${path_SCN_K1_K2}[ttitrace]/output_dl_formated.csv    actEnhancedPDSCHSchSplSlot=${0}    guardPeriodLength=${6}
    Log to Console   ${max_ueperslot}

CB009422_Verification_HO
    OperatingSystem.Run    cp ${WTS_DIR}/egate_console.log ${LOG_PATH}

#   Verification of K2 against all DL_slots from TTI trace
    Verify_K2    ${path_SCN_HO}[ttitrace]/output_ul_formated.csv

#   Verification of K1 against all DL_slots from TTI trace
    Verify_K1    ${path_SCN_HO}[ttitrace]/output_dl_formated.csv    actEnhancedPDSCHSchSplSlot=${0}    guardPeriodLength=${6}

#   Verification of HARQ slots from TTI trace
    Verify_HARQ_slots    ${path_SCN_HO}[ttitrace]/output_dl_formated.csv    actEnhancedPDSCHSchSplSlot=${0}    guardPeriodLength=${6}

CB009422_Verification_K1_K2_HARQ
    Start TTI_TRACE custom     ${51}
    sleep   1s
    ${path_SCN}   Stop log    ttitrace    test_scenario=good_condition
    OperatingSystem.Run    cp ${WTS_DIR}/egate_console.log ${LOG_PATH}

    Common TTI PCAP to CSV Converter    good_condition   dir=dl
    Common TTI PCAP to CSV Converter    good_condition   dir=ul

#   Verification of K2 against all DL_slots from TTI trace
    Verify_K2    ${path_SCN}[ttitrace]/output_ul_formated.csv

#   Verification of K1 against all DL_slots from TTI trace
    Verify_K1    ${path_SCN}[ttitrace]/output_dl_formated.csv    actEnhancedPDSCHSchSplSlot=${0}    guardPeriodLength=${6}

#   Verification of HARQ slots from TTI trace
    Verify_HARQ_slots    ${path_SCN}[ttitrace]/output_dl_formated.csv    actEnhancedPDSCHSchSplSlot=${0}    guardPeriodLength=${6}

CB009422_Verification_K1_K2_HARQ_SplitD
    Start TTI_TRACE custom     ${51}
    sleep   1s
    ${path_SCN}   Stop log    ttitrace    test_scenario=good_condition
    OperatingSystem.Run    cp ${WTS_DIR}/egate_console.log ${LOG_PATH}

    Common TTI PCAP to CSV Converter    good_condition   dir=dl
    Common TTI PCAP to CSV Converter    good_condition   dir=ul

#   Verification of K2 against all DL_slots from TTI trace
    Verify_K2    ${path_SCN}[ttitrace]/output_ul_formated.csv

#   Verification of HARQ slots from TTI trace
    Verify_HARQ_slots    ${path_SCN}[ttitrace]/output_dl_formated.csv    actEnhancedPDSCHSchSplSlot=${0}    guardPeriodLength=${6}

Start TTI_TRACE custom
    [Arguments]    ${cell_id}=${50}
    Common Start Ttitrace With Streaming Mode_3 custom        pysical_cell_ids=${cell_id}

Common Start Ttitrace With Streaming Mode_3 custom
    [Arguments]    ${pysical_cell_ids}=50    ${names}=l2stream3_ttitrace
    [Documentation]    This keyword is used to start ttitrace with streaming mode.
    ...    examples 1: catch 1 cell
    ...    Start Ttitrace With Streaming Mode
    ...    examples 2: catch 2 cells
    ...    Start Ttitrace With Streaming Mode    50,51
    ${executor}=  Create Dictionary
    ...  host=192.168.255.129
    ...  user=Nemuadmin
    ...  password=nemuuser
    ...  port=443
#    ${nr_phy_cell_ids}=    Common Get PhysCellId Of GNB Runtime
    ${nr_phy_cell_ids}    Create List    ${pysical_cell_ids}
    ${nr_phy_cell_ids}=    Evaluate  map(int, $nr_phy_cell_ids)
    Log Many    ${pysical_cell_ids}       ${nr_phy_cell_ids}
#    ${localIpAddr}=    Get localIpAddr Of GNB
#10.0.1.2 for ute
    ${localIpAddr}=    set variable    10.0.1.2
#    ${web_card}    ${dest_ip}=    Get EIF Info Of Control PC
    ${web_card}    ${dest_ip}=    Common Get EIF Info Of Control PC
    ${l2_stream_config_1}=  Create Dictionary
    ...  nr_phy_cell_ids=${nr_phy_cell_ids}
    @{l2_stream_configuration}=  Create List  ${l2_stream_config_1}
    TCPDUMP.create tcpdump collector
    ...  name=tcpdump_ttitrace
    ...  options=-i ${web_card} udp and dst ${dest_ip} and dst port 5678
    ...  sudo_password=ute
    L2STREAM3.Create Sbts L2stream Collector
    ...  name=${names}
    ...  destination_ip_addr=${dest_ip}
    ...  collector=tcpdump_ttitrace
    ...  l2_stream_configuration=${l2_stream_configuration}
    ...  webservice=${executor}
    L2STREAM3.Set Suite Alias
    ...  alias=${names}
    CORE.setup_collectors
    ...  names=${names}
    CORE.start_collectors
    ...  names=${names}

Update bsr package
    Run     mkdir ${CURDIR}/BSR
    ${dllink}   Set Variable     https://artifactory-espoo1.ext.net.nokia.com:443/artifactory/mnpute-rotta-local/BSR
    ${filename}    Set variable     BSR_AQQJ_4_H4_ALN30_ARP30_P00_6TO4_60_00421_00001.zip
    Run     sudo wget ${dllink}/${filename} --user=dheerajn --password=AP33ZXKC1P9cgS4SsiuoeE23c8C -P ${CURDIR}/BSR
    coam.setup admin    bts_host=192.168.255.129
    ${ret}     coam.Update Software      ${CURDIR}/BSR/BSR_AQQJ_4_H4_ALN30_ARP30_P00_6TO4_60_00421_00001.zip
    coam.teardown admin

Modify IPHY File And Send to Airphone Custom
    [Arguments]    ${iphy_path}
    ${RRU_type_list}    Get RRU Type From Local IPHY XML Custom   ${iphy_path}
    FOR    ${RRU_type}    IN    @{RRU_type_list}
    ${RRU_Version}    Get RRU Version From TargetBD File Custom    ${RRU_type}    ${OUTPUT_DIR}
    Modify RRU Version Of IPHY XML Custom    ${iphy_path}    ${RRU_type[0]}    ${RRU_Version}
    END
    Send IPHY XML To Airphone custom    ${iphy_path}

Get RRU Type From Local IPHY XML Custom
    [Arguments]    ${iphy_path}
    ${content}=    OperatingSystem.Get File    path=${iphy_path}
    ${x}  Set Variable  <RE>[\\s\\S]*?<cardName>(?P<RRU_type>\\w+)<\\/cardName>[\\s\\S]*?(?P<Ecpri_tag>[\\w]+)>\\n\\s+(?=<\\/RE>)
    @{RRU_type_for_version}    String.Get Regexp Matches    ${content}    ${x}    RRU_type    Ecpri_tag
    @{RRU_type_list}    String.Get Regexp Matches    ${content}    ${x}    RRU_type
    Set Suite Variable    ${RRU_TYPE_LIST}    ${RRU_type_list}
    Set Suite Variable    ${RRU_TYPE}    ${RRU_type_list[0]}
    Log To Console   RRU Type List from local iphy.xml: ${RRU_type_list}
     Log To Console    RRU Type from local iphy.xml: ${RRU_TYPE}
    [Return]    @{RRU_type_for_version}

Get RRU Version From TargetBD File Custom
    [Arguments]    ${RRU_type}    ${save_dir}
    ${RRU_type}=    Set Variable If    "${RRU_type[0]}"=="AAHF"    AAHF_C1
    ...    "${RRU_type[0]}"=="AEUB"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AEHC"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AEUD"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AWEUA"   ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AHLOA"   ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AHFIG"   ${RRU_type[0]}
    ...    "${RRU_type[1]}"=="ecpri"   ${RRU_type[0]}_E1
    ...    ${RRU_type[0]}
    OperatingSystem.Run
    ...    sshpass -p ${GNB_ASIK.password} scp ${GNB_ASIK.username}@${GNB_ASIK.ip}:/ffs/run/TargetBD*.xml ${save_dir}/TargetBD.xml
    OperatingSystem.Should Exist    ${save_dir}/TargetBD.xml
    ${content}=    OperatingSystem.Get File    path=${save_dir}/TargetBD.xml
    ${check_point_regexp}    Set Variable    resourceBuildKey="LTX_${RRU_type}".*resourceSWVersion="(?P<RRU_Version>.*)"
    @{RRU_Version_List}    String.Get Regexp Matches    ${content}    ${check_point_regexp}    RRU_Version
    ${RRU_Version}=    Set Variable If    ${RRU_Version_List}    ${RRU_Version_List[0]}    UNKNOWN
    [Return]    ${RRU_Version}


Modify RRU Version Of IPHY XML Custom
    [Arguments]    ${iphy_path}    ${RRU_type}    ${RRU_Version}
    ${content}    OperatingSystem.Get File    path=${iphy_path}
    ${bldVersion}=    String.Get Regexp Matches    ${content}
    ...    <cardName>${RRU_type}<\/cardName>[\\s\\S]*?<bldVersion>(?P<bldVersion>.*)<\/bldVersion>
    ...    bldVersion
    Log Many    ${bldVersion[0]}    ${RRU_Version}
    ${new_content}    String.Replace String    ${content}    ${bldVersion[0]}    ${RRU_Version}
    Log To Console    ${new_content}
    OperatingSystem.Create File    path=${iphy_path}    content=${new_content}


Send IPHY XML To Airphone custom
    [Arguments]    ${iphy_path}
    [Documentation]    This keyword is to send target iphy.xml to Airphone /ffs/run/simmode/
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${iphy_path} | Yes | iphy.xml located, eg:/home/ute/iphy.xml |
    ...
    ...    Examples:
    ...    | Send IPHY XML To Airphone | /home/ute/iphy.xml |
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} rm -f /ffs/run/simmode/*.xml
    Should Be Equal As Integers    ${rc}    0
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p ${AP_ASIK.password} scp ${iphy_path} ${AP_ASIK.username}@${AP_ASIK.ip}:/ffs/run/simmode/iphy_modify.xml
    Should Be Equal As Integers    ${rc}    0
    ${soft_link}=    Set Variable    ln -fs /ffs/run/simmode/iphy_modify.xml /ffs/run/simmode/iphy.xml
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} ${soft_link}
    Should Be Equal As Integers    ${rc}    0

Modify NIDD parameters
    [Documentation]     This Keyword modify NIDD parameter as per the requirement of the feature CB005788
    [Arguments]        ${paramDst}='None'                  ${operation}=update
     ...                ${paramName}='None'                 ${paramValue}='None'
    Log to Console      Modifying NIDD parameters
    admin.Setup admin
    Online NIDD parameter change    paramDst=${paramDst}        operation=${operation}
    ...          paramName=${paramName}         paramValue=${paramValue}
    sleep               60s
    [Teardown]          admin.Teardown admin

Online NIDD parameter change
     [Documentation]    This Keyword used to update NIDD parameter(one at a time)
     ...                and returns the result
     ...        [Arguments]    parameter        :  Parameter names to parsed
     ...                       paramDst         :  Dist name should be parsed
     ...                       paramValue       :  Value for the parameter to be assigned should be parsed
     ...                       operation        :  Deffault Value given as update, and can be parsed other operation if required
     ...                       should_activate  :  Deffault Value is True if you want to set this False then parse the parameter as False
     ...                       skip_parameter_relation_errors : Default Value is True if you want to set this False then parse the parameter as False
     [Arguments]        ${paramName}='None'                 ${paramValue}='None'              ${timeout}=300
     ...                ${paramDst}='None'                  ${operation}=update
     ...                ${should_activate}=${True}          ${skip_parameter_relation_errors}=${True}
     Builtin.Log     ${timeout}
    admin.perform_parameter_recommissioning          parameter=${paramName}
     ...        value=${paramValue}             operation=${operation}                         dist_name=${paramDst}
     ...        skip_parameter_relation_errors=${skip_parameter_relation_errors}
     ...        should_activate=${should_activate}

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
    ute_wtssim.Execute Egate Command And Wait For Data      ${sib_disp_cmd}     pass_regexp=${sib_radiated_pattern}
    ...     timeout=${EGATE_COMMAND_TIMEOUT}
    ute_wtssim.Execute Egate Command And Wait For Data		${sib_mib_disp_cmd}			fail_regexp=no
    ...     timeout=${EGATE_COMMAND_TIMEOUT}
	END

MultiUE Register should be Successful with UE Cap
    [Arguments]    ${start_ue_id}   ${end_ue_id}    ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}  ${ue_cap}=${EMPTY}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA varianti
    ${crnti_list}       Create List
    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
	${ue_reg_cmd}	SET VARIABLE	ue_register id=${ue_idx} ue_nr_capabilities=${ue_cap}
	${output}		ute_wtssim.Execute Egate Command And Wait For Data  ${ue_reg_cmd}   pass_regexp=${UE_reg_complete_pattern}
    ...      timeout=${EGATE_COMMAND_TIMEOUT}
	Create File     ${OUTPUT_DIR}/regst.txt     ${output}
	${crnti_value}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk -F 'crnti:' '{print $2}'|cut -d ' ' -f 2
	BuiltIn.Log     ${crnti_value}
	Log to Console             ue${ue_idx}_register_is_ok with ${crnti_value}
	Append To List  ${crnti_list}   ${crnti_value}
	${set_pdu_param_cmd}	SET VARIABLE	set_pdu_param ue=${ue_idx} pdu=${pdu_id} trf_type=internal
    ${pdu_setup_cmd}	SET VARIABLE	ue_pdu_session_setup pdu=${pdu_id} ue=${ue_idx} nwslice=${nw_id} gw=${ue_idx}
	ute_wtssim.Execute Egate Command    ${set_pdu_param_cmd}    timeout=${EGATE_COMMAND_TIMEOUT}
	 ute_wtssim.Execute Egate Command And Wait For Data  ${pdu_setup_cmd}
	...		pass_regexp=(\?\:${PDU_session_resource_setup_response}|${Initial_context_setup_pattern})        timeout=${EGATE_COMMAND_TIMEOUT}
    BuiltIn.Log        ue=${ue_idx} with crnti=${crnti_value} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
    END
    Log to Console             multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                CRntilist:${crnti_list}
    [Return]      ${crnti_list}

Validate of DL MultiBwp
    [Arguments]     ${file}    ${dl_slot}   ${K1}   ${csiperiod}
    ${result}   CB009422_Verification.dl_validation_multibwp     ${file}    ${dl_slot}   ${K1}   ${csiperiod}
    should be equal  ${result}    Pass

Validate of UL MultiBwp
    [Arguments]     ${file}    ${ul_slot}   ${K2}   ${csiperiod}
    ${result}   CB009422_Verification.ul_validation_multibwp     ${file}    ${ul_slot}   ${K2}   ${csiperiod}
    should be equal  ${result}    Pass
