*** Settings ***
Variables    ta5g_global_var

Resource       taf/rfrl/common_resources/robot/coam.robot
Resource       taf/rfrl/common_resources/robot/libraries_instances.robot
Library        ../resources/NPS/SWENG/python_libs/luashark_tools.py
Resource       ../resources/NPS/SWENG/robot/PacketSearch.robot
Resource       ../resources/robot/Setup_Env.robot
Resource       ../resources/robot/common_log_collection.robot
Resource        ../resources/ECEcommon/common_file_operation.robot
Resource         ../resources/robot/Airphone.robot
#Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/wts_sim_keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         ../resources/robot/TTI_Traces.robot
Resource         ../resources/robot/Iperf_Traffic.robot
Library          ../resources/python/ssh_command.py
Library          ./resource/python/increase_buffer_size.py
Library        luashark_tools.analyzer       WITH NAME       analyzer
Library        ute_admin                         WITH NAME   ute_adm
Library        taf.collectors.btslog  WITH NAME   btslog
Library        Collections
Library        OperatingSystem
Library        ta5g_tshark
Library        ta5g_commissioning
Library        taf.analyzer.pdml     WITH NAME    taf_pdml_analyser
Library        taf.transport.ssh                 WITH NAME    csn
Library           XML    use_lxml=True    WITH NAME    Myxml
Library          ../resources/python/TTI_Converter.py    WITH NAME    TtiConvert
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Library          DateTime
Library          taf.transport.ssh           WITH NAME    taf_ssh
#Library          taf.wts.runner              WITH NAME    wtsrunner
Library          ta_a2a

Documentation
...
...             author:           Samik Sarkar
...              :contact: samik.sarkar@nokia.com
*** Variables ***
&{GNB_ASIK}                ip=192.168.255.129    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik
&{AP_ASIK}                 ip=192.168.200.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=APAsik
${port}                    22

${pdu_mod_with_5qi-5}     Added QosFlow with QFI:2 fiveQI:5
${pdu_mod_with_5qi-1}     Added QosFlow with QFI:3 fiveQI:1

*** Keywords ***
Perform SCF Delta Commissioning with ${delta_commissioning_file_json}
    Find Scfc And Send Delta Commissioning      scfc_filename=${delta_commissioning_file_json}

Increase Buffer Size for VM and IPHY
    increase_buffer_size.increase_buffer_size     ${AP_ASIK.ip}      ${port}    ${AP_ASIK.username}     ${AP_ASIK.password}

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
    ...      ${actA3A5MRDuringDRXSetup}=True
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Start log       btslog    cprt
    ${ue_meas_id}   Set Variable    ue_cfg_meas_disp id=${ue_id}
    ${output}	ute_wtssim.Execute Egate Command And Wait For Data   ${ue_meas_id}    pass_regex=UE1 NR MEASUREMENT IDENTITIES:(.|\r|\n)?======
    ...        timeout=10
    Log to Console    ${output}
#    ${data_cmd}	SET VARIABLE	ue_measurement_send_nr    id=${ue_id}    meas_id=3    event=A3    srsrp_nr=1
#    ...    srsrq_nr=1    phycell_id=${phycell_id}   nrsrp_nr=30    nrsrq_nr=20
    ${data_cmd}	SET VARIABLE    ue_measurement_send_nr id=${ue_id} meas_id=3 event=${meas_event}
    ...     srsrp_nr=19 phycell_id=${dest_phycell_id} nrsrp_nr=100
    ${output1}	ute_wtssim.Execute Egate Command And Wait For Data   ${data_cmd}    pass_regexp=rrcReconfigurationComplete    timeout=10
    Log to Console    ${output1}
    ${path_cprt}     Stop log    btslog    cprt   test_scenario=UE_${ue_id}/cprt_intra_du_ho_${source_phy_id}_to_${dest_phycell_id}
    Log to Console  ${actA3A5MRDuringDRXSetup}
    END

Inter GNB HO SA UE measurements
    [Arguments]    ${start_ue_id}    ${end_ue_id}    ${meas_event}=A3    ${source_phy_id}=54    ${dest_phycell_id}=50
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Start log       btslog    cprt
    ${cmd1}    Set Variable
    ...     ue_history_information_list_add_ngran id=${ue_id} gnb_id=3 cell_type=medium nrcgi=311:489|0x03 time_ue_stayed_in_cell=100
    ute_wtssim.Execute Egate Command    ${cmd1}

    ute_wtssim.Execute Egate Command    cmd=ue_history_information_list id=${ue_id} action=commit
    ute_wtssim.Execute Egate Command    cmd=ue_enb_param id=${ue_id} ue_history_list=1
    ute_wtssim.Execute Egate Command    cmd=upf_param id=${ue_id} end_markers_delay=10s

    ${ue_meas_id}   Set Variable    ue_cfg_meas_disp id=${ue_id}
    ${output}	ute_wtssim.Execute Egate Command And Wait For Data   ${ue_meas_id}    pass_regex=UE1 NR MEASUREMENT IDENTITIES:(.|\r|\n)?======
    ...        timeout=10

    ${data_cmd}	 Set Variable    ue_measurement_send_nr id=${ue_id}  meas_id=1 event=${meas_event} srsrp_nr=19 phycell_id=50 nrsrp_nr=100
    ${output1}	ute_wtssim.Execute Egate Command And Wait For Data   ${data_cmd}    pass_regexp=rrcReconfigurationComplete    timeout=10
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
    ${output1}	ute_wtssim.Execute Egate Command And Wait For Data    ${cmd1}    pass_regex=${reg1}   timeout=10
    ${cmd_list}     Create List      gnb_param id=3 sib1_period=40      gnb_param id=3 sib2_period=40
    ...         gnb_param id=3 sib5_period=40
    FOR     ${cmd}    IN    @{cmd_list}
    ute_wtssim.Execute Egate Command        ${cmd}
    END

Location Update to Sim GNB
    [Arguments]    ${start_ue_id}    ${end_ue_id}   ${eNB}=3    ${cell}=1

    ${cmd1}     Set variable    gnb_xn_link_up gnb=3 target=2
    ${reg1}     Set variable    GNB-3: XnAP Link with GNB-2 (10.0.1.2:38422[0]) is up
    ${output1}	ute_wtssim.Execute Egate Command And Wait For Data    ${cmd1}    pass_regex=${reg1}   timeout=10

    ${cmd_list}     Create List      gnb_param id=3 sib1_period=40      gnb_param id=3 sib2_period=40
    ...         gnb_param id=3 sib5_period=40
    FOR     ${cmd}    IN    @{cmd_list}
    ute_wtssim.Execute Egate Command        ${cmd}
    END
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    ${ue_id}    Convert To String    ${ue_id}
    ${cmd2}     Set Variable    ue_change_location id=${ue_id} enb=${eNB} cell=${cell}
    ${reg2}     Set Variable    UE-${ue_id}\[OFF\]: location updated to eNB-${eNB} cell ${cell}
    ${output2}	ute_wtssim.Execute Egate Command And Wait For Data    ${cmd2}    pass_regex=${reg2}   timeout=10
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
    ute_wtssim.Execute Egate Command    ${x}

    ute_wtssim.Execute Egate Command    cmd=ue_history_information_list id=1 action=reset
    ${cmd1}    Set Variable
    ...     ue_history_information_list_add_ngran id=1 gnb_id=3 cell_type=medium nrcgi=311:489|0x01 time_ue_stayed_in_cell=100
    ute_wtssim.Execute Egate Command    ${cmd1}
    ute_wtssim.Execute Egate Command    cmd=ue_history_information_list id=1 action=commit
    ute_wtssim.Execute Egate Command    cmd=ue_enb_param id=${ue_id} ue_history_list=1

    ${ue_meas_id}   Set Variable    ue_cfg_meas_disp id=${ue_id}
    ${output}	ute_wtssim.Execute Egate Command And Wait For Data   ${ue_meas_id}    pass_regex=UE1 NR MEASUREMENT IDENTITIES:(.|\r|\n)?======
    ...        timeout=10
    ${m}    set variable if    '${meas_event}'=='A3'    1    3
    ${cmd2}	 Set Variable    ue_measurement_send_nr id=${ue_id} meas_id=${m} event=${meas_event} srsrp_nr=19 phycell_id=${first_target} nrsrp_nr=100
    ${output1}	ute_wtssim.Execute Egate Command And Wait For Data   ${cmd2}    pass_regexp=rrcReconfigurationComplete    timeout=10
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
    ute_wtssim.Execute Egate Command    ${x}
    ${ue_meas_id}   Set Variable    ue_cfg_meas_disp id=${ue_id}
    ${output}	ute_wtssim.Execute Egate Command And Wait For Data   ${ue_meas_id}
    ...   pass_regex=UE${ue_id} NR MEASUREMENT IDENTITIES:(.|\r|\n)?======        timeout=10
    ${m}    set variable if    '${meas_event}'=='A3'    3    4
    ${cmd2}	 Set Variable    ue_measurement_send_nr id=${ue_id} meas_id=${m} event=${meas_event} srsrp_nr=19 phycell_id=${first_target} nrsrp_nr=100
    ${reg3}   Set variable   GNB-3: UE${ue_id}: XN Handover Successfully completed at Target
    ${output1}	ute_wtssim.Execute Egate Command And Wait For Data   ${cmd2}    pass_regexp=${reg3}    timeout=10
    Log to Console    ${output1}
    ${reg1}    Set Variable     UE${ue_id}: Intra-eNB handover from EXT_ENB-2.${source_real_lcr} to EXT_ENB-2.${first_target_real_lcr} performed
    ${reg2}    Set Variable     UE${ue_id}: Inter-eNB handover from EXT_ENB-2.${first_target_real_lcr} to ENB-3.${sec_target_sim_lcr} performed
    BuiltIn.Should Match Regexp   ${output1}      ${reg1}
    BuiltIn.Should Match Regexp   ${output1}      ${reg2}
    ${path_cprt}     Stop log    btslog    cprt   test_scenario=UE_${ue_id}/cprt_inter_gnb_ho_${source_cell}_to_${sec_target}
    END

UE Change Location
    [Arguments]    ${start_ue_id}    ${end_ue_id}   ${gnb}=2    ${cell}=1
    FOR    ${ue_id}    IN RANGE    ${st_ue_id_a3}    ${en_ue_id_a3}+1
    ${cmd}    Set Variable      ue_change_location id=${ue_id} enb=${gnb} cell=${cell}
    ${output}	ute_wtssim.Execute Egate Command And Wait For Data      ${cmd}
    ...    pass_regex=UE-${ue_id}\[OFF\]: location updated to eNB-${gnb} cell ${cell}        timeout=10
    log to console      ${output}
    log to console      ${start_ue_id}
    log to console      ${end_ue_id}
    END

Handover failure During Preparation phase of intra-du intra gnb resulted in post inter freq intra-du HO
    [Arguments]    ${start_ue_id}    ${end_ue_id}    ${meas_event}=A3    ${source_cell}=50   ${first_target}=52    ${sec_target}=53
    ...    ${if_contains}=drx_setup     ${action}=None    ${tgt_cell_ssb}=126530    ${source_real_lcr}=1   ${first_target_real_lcr}=3
    ...    ${sec_target_sim_lcr}=4
    log to console      ${sec_target_sim_lcr}
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Start log       btslog    cprt
    ${c1}   set variable   ue_nr_rrc_reconf_param id=${ue_id} if_contains=${if_contains} action=${action} meas_type=${meas_event}
    ${c2}   set variable   tgt_phycell_id=${sec_target} tgt_cell_ssb_frequency=${tgt_cell_ssb}
    ${str1}   Catenate    ${c1}   ${c2}

    ${c3}   set variable   ue_nr_rrc_reconf_param id=${ue_id} if_contains=${if_contains} action=${action} meas_type=${meas_event}
    ${c4}   set variable   nth=2 tgt_phycell_id=${sec_target} tgt_cell_ssb_frequency=${tgt_cell_ssb}
    ${str2}   Catenate    ${c3}   ${c4}

    ${x}    set variable if    '${if_contains}'=='drx_setup'    ${str1}     ${str2}
    ute_wtssim.Execute Egate Command    ${x}

    ${ue_meas_id}   Set Variable    ue_cfg_meas_disp id=${ue_id}
    ${output}	ute_wtssim.Execute Egate Command And Wait For Data   ${ue_meas_id}
    ...   pass_regex=UE${ue_id} NR MEASUREMENT IDENTITIES:(.|\r|\n)?======        timeout=10

#    ${a2_meas}   Set Variable    ue_measurement_send_nr id=${ue_id} meas_id=2 event=A2 srsrp_nr=8 srsrq_nr=8   #old LO-LO
    ${a2_meas}   Set Variable    ue_measurement_send_nr id=${ue_id} meas_id=1 event=A2 srsrp_nr=8 srsrq_nr=8
    ${output}	ute_wtssim.Execute Egate Command And Wait For Data   ${a2_meas}
    ...   pass_regex=criticalExtensions rrcReconfigurationComplete        timeout=10

    log to console    After A2 measurement
    ${ue_meas_id1}   Set Variable    ue_cfg_meas_disp id=${ue_id}
    ${output_1}	ute_wtssim.Execute Egate Command And Wait For Data   ${ue_meas_id1}
    ...   pass_regex=UE${ue_id} NR MEASUREMENT IDENTITIES:(.|\r|\n)?======        timeout=10

    ${m}    set variable if    '${meas_event}'=='A3'    6    7
    ${cmd2}	 Set Variable    ue_measurement_send_nr id=${ue_id} meas_id=${m} event=${meas_event} srsrp_nr=19 phycell_id=${first_target} nrsrp_nr=100
    ${reg3}   Set variable   UE${ue_id}: IS IDLE
    ${output2}	ute_wtssim.Execute Egate Command And Wait For Data   ${cmd2}    pass_regexp=${reg3}    timeout=10
    Log to Console    ${output2}
    ${reg1}    Set Variable     UE${ue_id}: Intra-eNB handover from EXT_ENB-2.${source_real_lcr} to EXT_ENB-2.${first_target_real_lcr} performed
    BuiltIn.Should Match Regexp   ${output2}      ${reg1}
    ${path_cprt}     Stop log    btslog    cprt   test_scenario=UE_${ue_id}/cprt_inter_gnb_ho_${source_cell}_to_${sec_target}
    Verify UE Release Cause    ${path_cprt}[cprt]
    END

Verify UE Release Cause
    [Arguments]    ${path}
    ${pdmlFile}    analyzer.pcap_to_pdml     ${path}/NODECPRT_GNB.pcap         ngap.UEContextReleaseRequest_element
    ${cause_code}    analyzer.get_unique            pdmlFile=${pdmlFile}
    ...                                         packetName=ngap.UEContextReleaseRequest_element
#    ...                                         path=.*misc$
    ...                                         path=.*radioNetwork$
    ...                                         endPacket=1
#    Should BE Equal    ${cause_code}   5       CORRECT VALUE. NEED TO CHECK
    Should BE Equal    ${cause_code}   21
