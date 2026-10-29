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
Library         luashark_tools.analyzer       WITH NAME       analyzer
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
Library         taf.rfrl.utilities.utf_lab.ute_utf_lab.UteUtfLab  WITH NAME  ute_utf_lab
Resource        ../../../resources/robot/Capture.robot
Resource        ../../../resources/NPS/SWENG/robot/Backup.robot


*** Variables ***
&{GNB_ASIK}                ip=192.168.255.129  username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik
&{AP_ASIK}                 ip=192.168.200.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=APAsik
${port}                    22

${pdu_mod_with_5qi-5}     Added QosFlow with QFI:2 fiveQI:5
${pdu_mod_with_5qi-1}     Added QosFlow with QFI:3 fiveQI:1

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
    [Arguments]     ${wts_cfg_file}		${cell_list}		${enb_id}=1
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
    ute_wtssim.Execute Egate Command And Wait For Data      ${sib_disp_cmd}     pass_regexp=${sib_radiated_pattern}
    ...     timeout=${EGATE_COMMAND_TIMEOUT}
    ute_wtssim.Execute Egate Command And Wait For Data		${sib_mib_disp_cmd}			fail_regexp=no
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
    ...    ${bc_list}=0:0    ${scellidx}=8:16    ${isDefCap}=True

    [Documentation]    This keyword is used at create the LTE Attach and checks the completion message in output file.
    ${crnti_list_nsa}       Create List
    FOR    ${NSA_UE_ID}    IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    ${cmd1}	SET VARIABLE	ue_attach id=${NSA_UE_ID}
    ${cmd2}	SET VARIABLE if	  ${isDefCap}==False
    ...     ue_attach id=${NSA_UE_ID} ue_nr_capabilities=${ue_nsa_nr_cap} ue_eutra_nr_capabilities=${ue_eutra_nr_cap}
    ${ue_attach_cmd}    set variable if    ${isDefCap}==True    ${cmd1}    ${cmd2}
    ute_wtssim.Execute Egate Command And Wait For Data   ${ue_attach_cmd}	pass_regexp=${LTE_attach_pattern}    timeout=${Timeout_NSA}
    BuiltIn.Log    lte_attach_is_ok
    #Configure Allowed BC List MRDC
    ${cmd1}    Set Variable    ue_enb_endc_param id=${NSA_UE_ID} allowed_bc_list_mrdc=${bc_list}
    log to console  executing_command-${cmd1}
    ute_wtssim.Execute Egate Command    ${cmd1}
    #Configure or Release Measurement Gaps
    ${cmd2}    Set Variable
    ...    ue_enb_param id=${NSA_UE_ID} measurement_gap=${meas_gap_config} mgta=ms0 gap_purpose=perUE gap_trigger=enb_and_gnb_triggered
    log to console  executing_command-${cmd2}
    ute_wtssim.Execute Egate Command    ${cmd2}
    #Configure serving_cell_index_range_scg
    ${cmd3}    Set Variable     enb_endc_param id=1 serving_cell_index_range_scg=${scellidx}
    log to console  executing_command-${cmd3}
    ute_wtssim.Execute Egate Command    ${cmd3}
    #5G Attach
    Start Log   cprt
    ${en_dc_start_cmd}=  catenate  SEPARATOR=${SPACE}
     ...  enb_ue_dc_start target_gnb=${Target_gNB} target_cells=${Trgt_Cell} ue=${NSA_UE_ID}
     ...  bearer=${Bearer_ID} type=split_scg
    ${output1}  ute_wtssim.Execute Egate Command And Wait For Data   ${en_dc_start_cmd}
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


MultiUE NSA Attach should be Successful and Fetch CRNTI with A2 trigger
    [Arguments]    ${start_ue_id}   ${end_ue_id}    ${Trgt_Cell}=${Target_Cells}    ${meas_gap_config}=off
    ...    ${bc_list}=0:0    ${scellidx}=8:16    ${isDefCap}=True

    [Documentation]    This keyword is used at create the LTE Attach and checks the completion message in output file.
    ${crnti_list_nsa}       Create List
    FOR    ${NSA_UE_ID}    IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    ${cmd1}	SET VARIABLE	ue_attach id=${NSA_UE_ID}
    ${cmd2}	SET VARIABLE if	  ${isDefCap}==False
    ...     ue_attach id=${NSA_UE_ID} ue_nr_capabilities=${ue_nsa_nr_cap} ue_eutra_nr_capabilities=${ue_eutra_nr_cap}
    ${ue_attach_cmd}    set variable if    ${isDefCap}==True    ${cmd1}    ${cmd2}
    ute_wtssim.Execute Egate Command And Wait For Data   ${ue_attach_cmd}	pass_regexp=${LTE_attach_pattern}    timeout=${Timeout_NSA}
    BuiltIn.Log    lte_attach_is_ok
    #Configure Allowed BC List MRDC
    ${cmd1}    Set Variable    ue_enb_endc_param id=${NSA_UE_ID} allowed_bc_list_mrdc=${bc_list}
    log to console  executing_command-${cmd1}
    ute_wtssim.Execute Egate Command    ${cmd1}
    #Configure or Release Measurement Gaps
    ${cmd2}    Set Variable
    ...    ue_enb_param id=${NSA_UE_ID} measurement_gap=${meas_gap_config} mgta=ms0 gap_purpose=perUE gap_trigger=enb_and_gnb_triggered
    log to console  executing_command-${cmd2}
    ute_wtssim.Execute Egate Command    ${cmd2}
    #Configure serving_cell_index_range_scg
    ${cmd3}    Set Variable     enb_endc_param id=1 serving_cell_index_range_scg=${scellidx}
    log to console  executing_command-${cmd3}
    ute_wtssim.Execute Egate Command    ${cmd3}
    #5G Attach
    Start Log   cprt
    ${en_dc_start_cmd}=  catenate  SEPARATOR=${SPACE}
     ...  enb_ue_dc_start target_gnb=${Target_gNB} target_cells=${Trgt_Cell} ue=${NSA_UE_ID}
     ...  bearer=${Bearer_ID} type=split_scg
    ${output1}  ute_wtssim.Execute Egate Command And Wait For Data   ${en_dc_start_cmd}
    ...		pass_regexp=${UE_attach_pattern}    timeout=${Timeout_NSA}
    ${cmd}     Set Variable     ue_measurement_send_nr id=${NSA_UE_ID} meas_id=1 event=A2
    ${output2}  ute_wtssim.Execute Egate Command And Wait For Data   ${cmd}
    ...		pass_regexp=eventId eventA3    timeout=30
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
    ...    ${measFreq}=off     ${gap_trig}=enb_and_gnb_triggered
    ...    ${isCsiOverride}=False   ${isFeatureTrue}=True

    ${regex}    Set Variable    x2ap::SgNBReconfigurationComplete sent to ENB-2
    FOR    ${idx}   IN RANGE    ${start_ue}    ${end_ue}+1
    Start Log   btslog  cprt
    ${cmd1}  Set Variable    ue_sgnb_mod_param id=${idx} allowed_bc_list_mrdc=${allowed-BC} exclude_sgnb_security_key=yes
    log to console  executing_command-${cmd1}
    ute_wtssim.Execute Egate Command    ${cmd1}

#    ${cmd2}  Set Variable
#    ...  ue_enb_param id=${idx} measurement_gap=${measGap} mgta=ms0 gap_purpose=${gap_pur} gap_trigger=${gap_trig} override_meas_freq_mn=${measFreq}
    ${a}  Set Variable  ue_enb_param id=${idx} measurement_gap=${measGap} mgta=ms0 gap_trigger=${gap_trig}
    ${b}  Set Variable  override_meas_freq_mn=${measFreq} override_meas_gap_config_mn=${measFreq}
    ${cmd2}    Catenate       ${a}    ${b}
    log to console  executing_command-${cmd2}
    ute_wtssim.Execute Egate Command    ${cmd2}

    ${cmd3}  Set Variable   enb_ue_dc_modify ue=${idx} cause=RN_improve_user_bit_rate by=enb ambr=10000000000:10000000000
    log to console  executing_command-${cmd3}

    ${regex1}    Set Variable    x2ap::SgNBReconfigurationComplete sent to ENB-2
    ${regex2}    Set Variable    ENB-1: Ignoring received X2 message: No handling yet for SgNBModificationRequestReject
    ${regex3}    Set Variable    ENB-1: Ignoring received X2 message: No handling yet for SgNBModificationRequestReject
#    ${regex2}    Set Variable    ENB-1: UE${idx}: PDCP Status Report will not be sent to UE
#    ${regex3}    Set Variable    UEC-1: UE${idx}: IS IDLE

    ${x}    Set Variable if    ${isFeatureTrue}==False      ${regex2}   ${regex1}
    ${regex}     Set Variable if    ${isCsiOverride}==False    ${x}     ${regex3}

    ${output1}  ute_wtssim.Execute Egate Command And Wait For Data   ${cmd3}	pass_regexp=${regex}    timeout=120
    Create File     ${OUTPUT_DIR}/sgnb_mod_nsa_${idx}.txt     ${output1}
    ${path}    Stop log     cprt   btslog    test_scenario=ue_${idx}_sgnb_modify
    log to console    sgnb-modification-path-${path}
    END
    [Return]        ${path}


 Trigger SgNB Modification with measConfigMN release with A1 trigger
    [Arguments]    ${start_ue}    ${end_ue}    ${allowed-BC}    ${measGap}=forced_release
    ...    ${measFreq}=off    ${gap_trig}=enb_and_gnb_triggered    #${check_scell_added}=False

    ${regex}    Set Variable    x2ap::SgNBReconfigurationComplete sent to ENB-2
    FOR    ${idx}   IN RANGE    ${start_ue}    ${end_ue}+1
    Start Log   btslog  cprt

     ${cmd}  Set Variable
    ...  ue_measurement_send_nr id=${idx} meas_id=3 event=A1 srsrp_nr=80
    log to console  executing_command-${cmd}
    ${output1}  ute_wtssim.Execute Egate Command And Wait For Data   ${cmd}	pass_regexp=x2ap::SgNBModificationConfirm sent to ENB-2    timeout=120

    ${cmd1}  Set Variable    ue_sgnb_mod_param id=${idx} allowed_bc_list_mrdc=${allowed-BC} exclude_sgnb_security_key=yes
    log to console  executing_command-${cmd1}
    ute_wtssim.Execute Egate Command    ${cmd1}

    ${cmd2}  Set Variable
    ...  ue_enb_param id=${idx} measurement_gap=${measGap} mgta=ms0 gap_trigger=${gap_trig} override_meas_freq_mn=${measFreq}
    log to console  executing_command-${cmd2}
    ute_wtssim.Execute Egate Command    ${cmd2}

    ${cmd3}  Set Variable   enb_ue_dc_modify ue=${idx} by=enb cause=RN_tDCprep_expiry
    log to console  executing_command-${cmd3}
    ${output1}  ute_wtssim.Execute Egate Command And Wait For Data   ${cmd3}	pass_regexp=${regex}    timeout=120
    Create File     ${OUTPUT_DIR}/sgnb_mod_nsa_${idx}.txt     ${output1}
    ${path}    Stop log     cprt   btslog    test_scenario=ue_${idx}_sgnb_modify
    log to console    sgnb-modification-path-${path}
    END
    [Return]        ${path}

 Trigger SgNB Modification with measConfigMN Setup
    [Arguments]    ${start_ue}    ${end_ue}    ${allowed-BC}    ${measGap}=gp0:0
    ...    ${measFreq}=off    ${gap_pur}=perUE    ${gap_trig}=enb_and_gnb_triggered
    ...    ${isCsiOverride}=False   ${isFeatureTrue}=True

    FOR    ${idx}   IN RANGE    ${start_ue}    ${end_ue}+1
    Start Log   btslog  cprt
    ${cmd1}  Set Variable    ue_sgnb_mod_param id=${idx} allowed_bc_list_mrdc=${allowed-BC} exclude_sgnb_security_key=yes
    log to console  executing_command-${cmd1}
    ute_wtssim.Execute Egate Command    ${cmd1}

    #To Configure measuredFrquenciesMN enable meas_config_sn
    ${cmd2}  Set Variable    ue_sgnb_mod_param id=${idx} meas_config_sn=600
    log to console  executing_command-${cmd2}
    ute_wtssim.Execute Egate Command    ${cmd2}

    ${a}  Set Variable  ue_enb_param id=${idx} measurement_gap=${measGap} mgta=ms0 gap_purpose=${gap_pur} gap_trigger=${gap_trig}
    ${b}  Set Variable  override_meas_freq_mn=${measFreq} override_meas_gap_config_mn=on
    ${cmd3}    Catenate       ${a}    ${b}
    log to console  executing_command-${cmd3}
    ute_wtssim.Execute Egate Command    ${cmd3}

    ${regex1}    Set Variable    x2ap::SgNBReconfigurationComplete sent to ENB-2
    ${regex2}    Set Variable    ENB-1: Ignoring received X2 message: No handling yet for SgNBModificationRequestReject
    ${regex3}    Set Variable    ENB-1: Ignoring received X2 message: No handling yet for SgNBModificationRequestReject
#    ${regex2}    Set Variable    ENB-1: UE${idx}: PDCP Status Report will not be sent to UE
#    ${regex3}    Set Variable    UEC-1: UE${idx}: IS IDLE

    ${x}    Set Variable if    ${isFeatureTrue}==False      ${regex2}   ${regex1}
    ${regex}     Set Variable if    ${isCsiOverride}==False    ${x}     ${regex3}

    ${cmd4}  Set Variable   enb_ue_dc_modify ue=${idx} cause=RN_improve_user_bit_rate by=enb ambr=10000000000:10000000000
    log to console  executing_command-${cmd4}
    ${output1}  ute_wtssim.Execute Egate Command And Wait For Data   ${cmd4}	pass_regexp=${regex}    timeout=120
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
    ${actual_pm_values}    Get PM counter value   pm_files_location=${pm_files_location}/gnb_pm_counters  moc=${moc}    pi_id=${counter}
    ${actual_pm_values}   convert to integer    ${actual_pm_values}
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

    ${var}   Run keyword if  '${key}'=='physCellId' or '${key}'=='sCellIndex'
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

#Validation of measConfigMN
#    [Arguments]    ${measConfig_val}
#
#    #Get UE Ids using Get Dictionary Keys
#    ${ue_list}    Get Dictionary Keys    ${measConfig_val}
#
#    FOR     ${ue}   IN    @{ue_list}
#    ${keys}    Get Dictionary Keys    ${measConfig_val}[${ue}]
#    ${cprt_path}    Set Variable    ${LOG_PATH}/${TEST_NAME}/gNB/cprt/ue_${ue}_sgnb_modify
#    ${fil1}    Set Variable     x2ap.SgNBModificationRequest_element
#    ${fil2}    Set Variable     x2ap.SgNBModificationRequestAcknowledge_element
#    ${fil3}    Set Variable     x2ap.SgNBModificationRequired_element
#
#    ${pdmlFile1}    analyzer.pcap_to_pdml    ${cprt_path}/NODECPRT_GNB.pcap      ${fil1}
#    ${pdmlFile2}    analyzer.pcap_to_pdml    ${cprt_path}/NODECPRT_GNB.pcap      ${fil2}
#    ${pdmlFile3}    analyzer.pcap_to_pdml    ${cprt_path}/NODECPRT_GNB.pcap      ${fil3}
#
#    Log to console    keys-@{keys}
#    FOR    ${key}   IN  @{keys}
#    ${packet}   Set variable if
#    ...     '${key}'=='bandCombinationIndex' or '${key}'=='sCellIndex' or '${key}'=='physCellId'   ${fil2}
#    ...     '${key}'=='measGapConfig' or '${key}'=='gapPurpose'     ${fil1}
#    ...     '${key}'=='drx_Config' and ${measConfig_val}[${ue}][${key}]==1     ${fil3}
#    ...     '${key}'=='drx_Config' and ${measConfig_val}[${ue}][${key}]==0     ${fil2}
#
#    ${packet_path}   Set variable if
#    ...   '${key}'=='bandCombinationIndex' or '${key}'=='sCellIndex' or '${key}'=='physCellId'     ${pdmlFile2}
#    ...   '${key}'=='measGapConfig' or '${key}'=='gapPurpose'            ${pdmlFile1}
#    ...   '${key}'=='drx_Config' and ${measConfig_val}[${ue}][${key}]==1     ${pdmlFile3}
#    ...   '${key}'=='drx_Config' and ${measConfig_val}[${ue}][${key}]==0     ${pdmlFile2}
#
#    log to console    ${packet}
#    ${var}   Run keyword if  '${key}'=='physCellId' or '${key}'=='sCellIndex'
#    ...     analyzer.get_shownames          pdmlFile=${packet_path}
#    ...                                     packetName=${packet}
#    ...                                     path=nr-rrc.${key}$
#    ...                                     endPacket=1
#    ...                                     kind=show
#    ...     ELSE
#    ...     analyzer.get_unique          pdmlFile=${packet_path}
#    ...                                     packetName=${packet}
#    ...                                     path=nr-rrc.${key}$
#    ...                                     endPacket=1
#
#    log to console    ${var}
#    should be equal    ${var}    ${measConfig_val}[${ue}][${key}]
#    END
#    END

Validation of MeasGapCsiOverlap
    [Arguments]    ${Start_ue}  ${end_ue}
    FOR     ${idx}  IN RANGE    ${Start_ue}  ${end_ue}+1
    ${cprt_path}    Set Variable    ${LOG_PATH}/${TEST_NAME}/gNB/cprt/ue_${ue}_sgnb_modify
    ${pdmlFile1}    analyzer.pcap_to_pdml    ${cprt_path}/NODECPRT_GNB.pcap      f1ap.UEContextModificationFailure_element
    ${pdmlFile2}    analyzer.pcap_to_pdml    ${cprt_path}/NODECPRT_GNB.pcap      x2ap.SgNBModificationRequestReject_element

    ${f1ap_cause}       analyzer.get_unique      pdmlFile=${pdmlFile1}
    ...                                          packetName=f1ap.UEContextModificationFailure_element
    ...                                          path=f1ap.radioNetwork$
    ...                                          endPacket=1
    log to console     f1ap_cause-${f1ap_cause}
    should be equal    ${x2ap_cause}    8

    ${x2ap_cause}       analyzer.get_unique      pdmlFile=${pdmlFile2}
    ...                                          packetName=x2ap.SgNBModificationRequestReject_element
    ...                                          path=x2ap.misc$
    ...                                          endPacket=1
    log to console     f1ap_cause-${x2ap_cause}
    should be equal    ${x2ap_cause}    4

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

UE Detach
    [Arguments]    ${start_ue}    ${end_ue}
    FOR     ${ue}   IN RANGE    ${start_ue}    ${end_ue}+1
    wts_sim_keywords.NSA UE Detach Should Be Successful      ${ue}
    sleep    2s
    END

Validation of X2AP Modification Failure
    [Arguments]    ${Start_ue}  ${end_ue}

    FOR     ${idx}  IN RANGE    ${Start_ue}  ${end_ue}+1
    ${cprt_path}    Set Variable    ${LOG_PATH}/${TEST_NAME}/gNB/cprt/ue_${idx}_sgnb_modify

    ${pdmlFile}    analyzer.pcap_to_pdml    ${cprt_path}/NODECPRT_GNB.pcap    x2ap.SgNBModificationRequestReject_element

    ${x2ap_cause}       analyzer.get_unique      pdmlFile=${pdmlFile}
    ...                                          packetName=x2ap.SgNBModificationRequestReject_element
    ...                                          path=x2ap.protocol$
    ...                                          endPacket=1
    log to console     x2ap_cause-${x2ap_cause}
    should be equal    ${x2ap_cause}    4
    END

Validation of X2AP Modification Failure Disabled
    [Arguments]    ${Start_ue}  ${end_ue}

    FOR     ${idx}  IN RANGE    ${Start_ue}  ${end_ue}+1
    ${cprt_path}    Set Variable    ${LOG_PATH}/${TEST_NAME}/gNB/cprt/ue_${idx}_sgnb_modify

    ${pdmlFile}    analyzer.pcap_to_pdml    ${cprt_path}/NODECPRT_GNB.pcap    x2ap.SgNBModificationRequestReject_element

    ${x2ap_cause}       analyzer.get_unique      pdmlFile=${pdmlFile}
    ...                                          packetName=x2ap.SgNBModificationRequestReject_element
    ...                                          path=x2ap.misc$
    ...                                          endPacket=1
    log to console     x2ap_cause-${x2ap_cause}
    should be equal    ${x2ap_cause}    4
    END
