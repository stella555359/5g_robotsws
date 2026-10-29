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
Resource         ../../../resources/robot/wts_sim_keywords.robot
Resource         ../../../resources/robot/PM_Counters.robot
Resource         ../../../resources/robot/TTI_Traces.robot
Resource         ../../../resources/robot/Iperf_Traffic.robot
Library          ../../../resources/python/ssh_command.py
Library          ./resource/python/increase_buffer_size.py
Library        luashark_tools.analyzer       WITH NAME       analyzer
#Library        ute_admin                         WITH NAME   ute_adm
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
Library          ./python/CNI_135068_Verification.py
Library          DateTime
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          ta_a2a

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
    ...    sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.255.129:/ffs/run/swconfig.txt ${save_dir}/swconfig_gnb.txt
    OperatingSystem.Should Exist    ${save_dir}/swconfig_gnb.txt
    ${path}    Set Variable    ${save_dir}/swconfig_gnb.txt
    [Return]    ${path}

Send Swconfig File To GNB
    [Arguments]    ${path}
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p oZPS0POrRieRtu scp ${path} toor4nsn@192.168.255.129:/ffs/run/swconfig.txt
    Should Be Equal As Integers    ${rc}    0

Trigger A3 RsrpAndRsrq Measurement for intragnb HO
    [Arguments]    ${start_ue_id}    ${end_ue_id}    ${meas_event}=A3    ${source_phy_id}=50    ${dest_phycell_id}=51
#    ...      ${actA3A5MRDuringDRXSetup}=True
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
    ${output1}	 Execute Egate Command And Wait For Data   ${data_cmd}    pass_regexp=rrcReconfigurationComplete    timeout=10
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
    [Arguments]    ${start_ue_id}    ${end_ue_id}   ${gnb}=2    ${cell}=1
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    ${cmd}    Set Variable      ue_change_location id=${ue_id} enb=${gnb} cell=${cell}
    ${output}	Execute Egate Command And Wait For Data      ${cmd}
    ...    pass_regex=UE-${ue_id}\[OFF\]: location updated to eNB-${gnb} cell ${cell}        timeout=10
    log to console      ${output}
    END


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
    run     tcpdump -r ${tti_path}/tcpdump_ttitrace.pcap -w ${tti_path}/tti_split.pcap -C 22
    ${files}    OperatingSystem.List Files In Directory     ${tti_path}     tti_split.*
    log to console    file_list-${files}
    ${count}    Count Files In Directory    ${tti_path}     tti_split.*
    log to console    file_count-${count}
    ${file_to_merge_into}    Get From List    ${files}    ${-2}
    ${file_to_add}           Get From List    ${files}    ${-1}
    Log To Console    Merging '${file_to_add}' into '${file_to_merge_into}'
    #combine last two files
#    ${a}    Evaluate    ${count}-1
#    ${b}    Evaluate    ${count}-2
#    ${c}    Evaluate    ${count}-3
    ${x}    Set Variable
    ...    ${tti_path}/${file_to_merge_into} ${tti_path}/${file_to_add} -w ${tti_path}/dummy.pcap
    ${rc}   Run And Return Rc   mergecap ${x}
    Run keyword if    ${rc}!=${0}    Fail    PCAP merging failed
    run     rm ${tti_path}/${file_to_merge_into};rm ${tti_path}/${file_to_add}
    run     mv ${tti_path}/dummy.pcap ${tti_path}/${file_to_merge_into}
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


TM Profile creation for varying channel condition
    [Arguments]  ${target_bler}    ${target_mcs}    ${report_cqi}    ${profile_id}=0
    log to console       TM Profile creation started for varying channel condition
    ${len1}  Get length  ${target_mcs}
    ${len2}  Get length  ${target_bler}
    ${len3}  Get length  ${report_cqi}
    should be equal     ${len1}    ${len2}
    should be equal     ${len1}    ${len3}
    log to console    before-${profile_id}
    FOR    ${idx}   IN RANGE    ${len1}
    ${profile_id}    Evaluate    ${profile_id}+1
    ${a}    Set Variable     ${target_bler}[${idx}]
    ${b}    Set Variable     ${target_mcs}[${idx}]
    ${c}    Set Variable     ${report_cqi}[${idx}]
    ${adv_bler_profile_1}    Set Variable
    ...    adv_bler_testmode_nr profile_id=${profile_id} target_bler_profile_id=1 target_bler=${a} target_mcs=${b}
    ${csi_profile_1}    Set Variable
    ...    csi_override_testmode_nr profile_id=${profile_id} cqi_mode=fixed cqi=${c}
    Execute Egate Command        ${adv_bler_profile_1}
    Execute Egate Command        ${csi_profile_1}
    sleep   1s
    log to console    created_profile-${profile_id}
    END
    log to console       TM Profile creation finished for varying channel condition
    [return]    ${profile_id}


TM Profile activation for varying channel condition
    [Arguments]    ${ue_id}    ${target_mcs}    ${profile_id}=0    ${pausetime}=10s
    [Documentation]    for Multiple UE provide UE ids with comma sepearted e.g 1,2,3

    Log to console    TM Profile activation started for varying channel condition
    ${len1}  Get length  ${target_mcs}
    FOR    ${idx}   IN RANGE    ${profile_id}+1     ${profile_id}+${len1}+1
    ${adv_bler_profile_activate}    Set Variable
    ...    ue_testmode_set_nr id=${ue_id} scell=0-31 testmode=adv_bler profile_id=${idx} action=activate
    ${csi_profile_activate}    Set Variable
    ...    ue_testmode_set_nr id=${ue_id} scell=0-31 testmode=csi_override profile_id=${idx} action=activate
    Execute Egate Command        ${adv_bler_profile_activate}
    Execute Egate Command        ${csi_profile_activate}
    sleep    ${pausetime}
    log to console    profile_id-${idx} activated
    END
    Log to console    TM Profile activation finished for varying channel condition

TM Profile deactivation for varying channel condition
    [Arguments]    ${ue_id}     ${profile_id}
    [Documentation]    for Multiple UE provide UE ids with comma sepearted e.g 1,2,3
    ...     for ${profile_id} need to provide last profile id used in TM Profile deactivation for varying channel condition
    log to console      TM Profile deactivation Started for varying channel condition
    ${adv_bler_profile_deactivate}    Set Variable
    ...    ue_testmode_set_nr id=${ue_id} scell=0-31 testmode=adv_bler profile_id=${profile_id} action=deactivate
    ${csi_profile_deactivate}    Set Variable
    ...    ue_testmode_set_nr id=${ue_id} scell=0-31 testmode=csi_override profile_id=${profile_id} action=deactivate
    Execute Egate Command        ${adv_bler_profile_deactivate}
    sleep   20ms
    Execute Egate Command        ${csi_profile_deactivate}
    sleep   20ms
    log to console      TM Profile deactivation Finished for varying channel condition

Add 5QI for VoNR and VINR
    [Arguments]    ${start_ue}   ${end_ue}   ${ue_to_bearer_list}   ${pdu_id}=1   ${isVoNR}=False   ${isViNR}=False

    FOR    ${ue_id}     IN RANGE    ${start_ue}      ${end_ue}+1
    ${add_5qi5}	SET VARIABLE	ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=2 by=amf
    ${output_5qi5}	 Execute Egate Command And Wait For Data   ${add_5qi5}	pass_regexp=Added QosFlow with .* fiveQI:5
    ...     timeout=${Timeout_SA}
    ${ue_to_bearer_list}    Get Bearer Id and added 5QI     ${output_5qi5}    ${ue_id}    ${ue_to_bearer_list}
    BuiltIn.Log         ue=${ue_id} 5QI-5 added
	Log to Console      ue=${ue_id} 5QI-5 added
	Log to console      updated-bearer-list-${ue_to_bearer_list}
	sleep   1s

	#5QI-1 adition
	${add_5qi1}	   Set Variable if    ${isVoNR}==True	 ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=3 by=amf
    ${output_5qi1}   Run keyword if  ${isVoNR}==True
    ... 	Execute Egate Command And Wait For Data   ${add_5qi1}	pass_regexp=Added QosFlow with .* fiveQI:1
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
    ...   ssh toor4nsn@192.168.255.129 'timedatectl set-timezone UTC'
    Run    ${cmd}
    ${cmd1}  set variable
    ...   ssh toor4nsn@192.168.200.1 'timedatectl set-timezone UTC'
    Run    ${cmd1}

Verify Rank Downgrade Entry Exit
    [Arguments]    ${filepath}  ${crnti}    ${shortTermBlerThreshold1}=${12}    ${shortTermBlerThreshold2}=${10}
    ...    ${rdLowCqiThresholdRank1}=${3}    ${rdLowCqiThresholdRank2}=${3}
    ...    ${rdLowCqiThresholdRank3}=${3}    ${rdLowCqiThresholdRank4}=${3}
    ...    ${rdHighCqiThresholdRank1}=${5.5}    ${rdHighCqiThresholdRank2}=${5.5}
    ...    ${rdHighCqiThresholdRank3}=${5.5}    ${rdHighCqiThresholdRank4}=${5.5}

    ${res}   verify_rankdowngrade    ${filepath}   ${crnti}    ${shortTermBlerThreshold1}   ${shortTermBlerThreshold2}
    ...    ${rdLowCqiThresholdRank1}    ${rdLowCqiThresholdRank2}    ${rdLowCqiThresholdRank3}    ${rdLowCqiThresholdRank4}
    ...    ${rdHighCqiThresholdRank1}    ${rdHighCqiThresholdRank2}    ${rdHighCqiThresholdRank3}    ${rdHighCqiThresholdRank4}
    should be equal  ${res}  Pass


Trigger IntraFreq Intragnb A3 based HO
    [Arguments]    ${start_ue}  ${end_ue}    ${ue_to_bearer_list}    ${meas}=3    ${source_lcr}=1  ${target_lcr}=2
    ...    ${targetcell}=51    #${source_cell}=50
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

Verification of rrmDeltaCqi Handin
    [Arguments]    ${filepath}  ${crnti}    ${targetcell}   ${deltaCqiOffsetAdjHo}
    ${res}   verify_rrmdeltacqi_handin     ${filepath}  ${crnti}    ${targetcell}   ${deltaCqiOffsetAdjHo}
    should be equal  ${res}  Pass

Verify low SE
    [Arguments]    ${filepath}  ${crnti}    ${targetbler}   ${sethrtargetblerreduct}    ${dlladeltacqistepdown}=${0.25}
    ${res}   verify_low_se_region    ${filepath}    ${crnti}    ${targetbler}   ${sethrtargetblerreduct}    ${dlladeltacqistepdown}
    should be equal  ${res}  Pass

MultiUE Register should be Successful with Fetch Bearer ID
    [Arguments]    ${start_ue_id}   ${end_ue_id}    ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}   ${sa_ue_nr_cap}=None  #${ue_cap_p}=${-1}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA varianti
    ${crnti_list}           Create List
    ${ue_to_bearer_list}    Create Dictionary
    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
    ${cmd1}	    Set Variable	ue_register id=${ue_idx}
	${cmd2}	    Set Variable	ue_register id=${ue_idx} ue_nr_capabilities=${sa_ue_nr_cap}
	${ue_reg_cmd}   Set Variable if     '${sa_ue_nr_cap}'=='None'    ${cmd1}    ${cmd2}
	${output}		Execute Egate Command And Wait For Data  ${ue_reg_cmd}   pass_regexp=${UE_reg_complete_pattern}
    ...      timeout=${EGATE_COMMAND_TIMEOUT}
	Create File     ${OUTPUT_DIR}/regst.txt     ${output}
	${crnti_value}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk -F 'crnti:' '{print $2}'|cut -d ' ' -f 2
	BuiltIn.Log     ${crnti_value}
	Log to Console             ue${ue_idx}_register_is_ok with ${crnti_value}
	Append To List  ${crnti_list}   ${crnti_value}
	${set_pdu_param_cmd}	SET VARIABLE	set_pdu_param ue=${ue_idx} pdu=${pdu_id} trf_type=internal
    ${pdu_setup_cmd}	SET VARIABLE	ue_pdu_session_setup pdu=${pdu_id} ue=${ue_idx} nwslice=${nw_id} gw=${ue_idx}
	Execute Egate Command    ${set_pdu_param_cmd}    timeout=${EGATE_COMMAND_TIMEOUT}
	${output1}      Execute Egate Command And Wait For Data  ${pdu_setup_cmd}
	...		pass_regexp=(\?\:${PDU_session_resource_setup_response}|${Initial_context_setup_pattern})      timeout=${EGATE_COMMAND_TIMEOUT}
	${bearer_list}       Create List
	${dummy_list}        Create List
    Create File	    ${OUTPUT_DIR}/bearer.txt	    ${output1}
    ${bearer_id}    Run     cat ${OUTPUT_DIR}/bearer.txt |grep -i "servedRadioBearer drb-Identity" |awk '{print $4}'|sed 's/,//g'
    ${qfi_id}       Run     cat ${OUTPUT_DIR}/bearer.txt |grep -i "AMF-1: Setup QosFlow with QFI:"|awk '{print $9}'|sed 's/,//g'
    ${qfi_id}       Replace String    ${qfi_id}    :    -
    log to console     qfi-${qfi_id}
    Append To List	    ${dummy_list}    ${qfi_id}  ${bearer_id}
    Append To List	    ${bearer_list}    ${dummy_list}
    Set To Dictionary	${ue_to_bearer_list} 	${ue_idx}	    ${bearer_list}
    BuiltIn.Log        ue=${ue_idx} with crnti=${crnti_value} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
    END
    Log to Console             multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                CRntilist:${crnti_list}
    [Return]      ${crnti_list}     ${ue_to_bearer_list}
