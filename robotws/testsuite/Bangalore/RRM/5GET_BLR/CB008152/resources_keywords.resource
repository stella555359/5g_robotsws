*** Settings ***

Library          OperatingSystem
Library          Collections
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          ../CB008983/resources/verify_reconfig.py
Library          ../resources/python/avg_dl_data.py
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Library          taf.sw.scout    WITH NAME     scout
Resource         ../resources/robot/common_log_collection.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../CB007113/resources/load_based_validation_keywords.resource
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/WTS_Runner_BF_CA_HO_Keywords.robot
Resource         ../5GC000937/resources/5GC000937_Keywords.robot
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot

*** Variables ***
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}     1
${INDEX2}     0
${reconf_filepath}      ${CURDIR}/../../../../../

*** Keywords ***
Start WTS Using WTS_Runner Check Redcap
    [Arguments]             ${wts_cfg_file}
    Stop Edaemon and Egate process
    Stop Sim_enb
    run    command=sudo rm -rf ${WTS_DIR}/*.log.*
    Connect To WTS VM
    wtsrunner.configure_wtsemu_edaemon    edaemon_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=22222
    ...                                   sudo_password=ute
    wtsrunner.configure_wtsemu_egate      egate_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=20000
    wtsrunner.start_wtsemu                egate_console_ip=${WTS.Ip}
    ...                                   egate_port=20000
    wtsrunner.configure                      file=${wts_cfg_file}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=SystemInformationBlockType4-NR updated    timeout=240
    ${output}       Get Lines Matching Regexp    ${output}    cellBarredRedCap2Rx     partial_match=${TRUE}
    Should contain   ${output}    cellBarredRedCap2Rx-r17 notBarred
    Sleep   100s

Redcap UE Register should be Successful
    [Arguments]    ${ue_id}     ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}      ${gw_id}=${gw_ID}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA variant
    wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_register   id=${ue_id}
    ${output}    Read WTS Output Until Pattern Matches    .*REGISTRATION COMPLETE.*    ${Timeout_SA}
    Log to Console    --->.*REGISTRATION COMPLETE.*
    Initial Success Message for UE Register and Rere gister   ${output}
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_id}    nwslice=${nw_id}    gw=${gw_id}
    ${output}    wtsrunner.read_wtsemu_output_until_re   expected=Initial Context Setup Successful    timeout=240
    ${ue_support}       Get Lines Matching Regexp    ${output}    supportOfRedCap-r17 supported    partial_match=${TRUE}
    #${pdcp_ln}          Get Lines Matching Regexp    ${output}    pdcp-SN-Size   partial_match=${TRUE}
    BuiltIn.Should Match Regexp     ${output}
    ...     pdcp-Config.*\\n.*\\n.*\\n.*\\n.*\\n.*pdcp-SN-SizeUL\\slen12bits.*\\n.*pdcp-SN-SizeDL\\slen12bits
    BuiltIn.Should Match Regexp     ${output}
    ...     rlc-Config.*\\n.*\\n.*ul-AM-RLC.*\\n.*\\n.*sn-FieldLength\\ssize12.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*dl-AM-RLC.*\\n.*\\n.*sn-FieldLength\\ssize12
    Should contain   ${ue_support}    supportOfRedCap-r17 supported
    BuiltIn.Log                first_ue_register_is_ok
    [Return]      ${output}

Verify locationAndBandwidth from egate_log
    [Arguments]     ${file_path}    ${st_ue_id}    ${en_ue_id}        ${sansa_flag}    ${l_bwp}
    [Documentation]    This KW extracts RRCReconfig message from egate log and validated the locationandBandwidth
    ...                value of scell
	verify_reconfig.check_reconfig_msg     ${file_path}    ${sansa_flag}
    FOR    ${INDEX}    IN RANGE    ${st_ue_id}    ${en_ue_id}+1
        ${INDEX2}    Evaluate   (${INDEX}*${INDEX})+(${st_ue_id}*${st_ue_id})
        OperatingSystem.Run    mv ${reconf_filepath}/Reconfig_MSG_* ${LOG_PATH}/
        ${output}    OperatingSystem.Get File   ${LOG_PATH}/Reconfig_MSG_${INDEX2}.txt
        BuiltIn.Should Match Regexp    ${output}
        ...    sCellConfigDedicated.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\n.*locationAndBandwidth\\s${l_bwp}
    END

Detach UE
    [Arguments]      ${st_ue_id}    ${en_ue_id}
    [Documentation]    detach the UE
    Stop MultiUE Data Traffic for SA     ${st_ue_id}    ${en_ue_id}
    MultiUE Deregister should be Successful   ${st_ue_id}    ${en_ue_id}

Validate THP and Dettach UE
    [Arguments]      ${UE_ID}    ${st_ue_id}    ${en_ue_id}      ${dl_thp}    ${ul_thp}
    [Documentation]    This KW validates the throughput in DL and UL and dettach the UE
    Run Keyword And Continue on Failure    Validate DL Traffic For SA   ue_id=${UE_ID}      dl_rate=${dl_thp}
    ...    qfi_id=${QFI_ID}
    Run Keyword And Continue on Failure    Validate UL Traffic For SA   ue_id=${UE_ID}      ul_rate=${ul_thp}
    ...    qfi_id=${QFI_ID}
    Detach UE     ${st_ue_id}    ${en_ue_id}

Verify DL THP for single cell config
    [Arguments]   ${st_ue_id}    ${en_ue_id}      ${scell_idx}      ${expected_thp}
    ${exp_dl_thp} 	Collections.Get From List	${expected_thp}	0
	log to console   ${exp_dl_thp}
    ${pcell_thp}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${st_ue_id}    scell_idx=${scell_idx}    unit=Mbps
    Should Be True    ${pcell_thp} > ${exp_dl_thp}
    log to console  ${en_ue_id}
Verify DL THP for two cell config
    [Arguments]   ${st_ue_id}    ${en_ue_id}      ${scell_idx}      ${expected_thp}
    Verify DL THP for single cell config    ${st_ue_id}    ${en_ue_id}    ${scell_idx}      ${expected_thp}
    ${exp_dl_thp} 	Collections.Get From List	${expected_thp}	1
	log to console   ${exp_dl_thp}
	${scell_idx} =	Evaluate      ${scell_idx}+1
	log to console   ${scell_idx}
    ${pcell_thp}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${st_ue_id}    scell_idx=${scell_idx}    unit=Mbps
    Should Be True    ${pcell_thp} > ${exp_dl_thp}

Verify DL THP for three cell config
    [Arguments]   ${st_ue_id}    ${en_ue_id}      ${scell_idx}      ${expected_thp}
    Verify DL THP for two cell config    ${st_ue_id}    ${en_ue_id}    ${scell_idx}      ${expected_thp}
    ${exp_dl_thp} 	Collections.Get From List	${expected_thp}	2
	log to console   ${exp_dl_thp}
	${scell_idx} =	Evaluate      ${scell_idx}+2
	log to console   ${scell_idx}
    ${pcell_thp}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${st_ue_id}    scell_idx=${scell_idx}    unit=Mbps
    Should Be True    ${pcell_thp} > ${exp_dl_thp}

Verify DL THP for four cell config
    [Arguments]   ${st_ue_id}    ${en_ue_id}      ${scell_idx}      ${expected_thp}
    Verify DL THP for three cell config    ${st_ue_id}    ${en_ue_id}    ${scell_idx}      ${expected_thp}
    ${exp_dl_thp} 	Collections.Get From List	${expected_thp}	3
	log to console   ${exp_dl_thp}
	${scell_idx} =	Evaluate      ${scell_idx}+3
	log to console   ${scell_idx}
    ${pcell_thp}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${st_ue_id}    scell_idx=${scell_idx}    unit=Mbps
    Should Be True    ${pcell_thp} > ${exp_dl_thp}


Verify UL THP for single cell config
    [Arguments]   ${UE_ID}      ${scell_idx}      ${ul_thp}
    ${ulcell_thp}=    Get AVG UL DATA TRAFFIC For Given CC    ue_id=${UE_ID}    scell_idx=${scell_idx}    unit=Mbps
    Should Be True    ${ulcell_thp} > ${ul_thp}


Verify UL THP for 2 cell config
     [Arguments]    ${UE_ID}  ${expected_pcell_thp}    ${expected_scell_thp}
     [Documentation]    This KW validates the UL data in Pcell and scell in 2CC scenario
        ${pcell_thp}=    load_based_validation_keywords.Get AVG UL DATA TRAFFIC For Given CC
        ...    ue_id=${UE_ID}    scell_idx=0    unit=Mbps
        ${scell_thp}=    load_based_validation_keywords.Get AVG UL DATA TRAFFIC For Given CC
        ...    ue_id=${UE_ID}    scell_idx=1    unit=Mbps
        Run Keyword And Continue on Failure     Should Be True    ${pcell_thp} > ${expected_pcell_thp}
        Run Keyword And Continue on Failure     Should Be True    ${scell_thp} > ${expected_scell_thp}


Verify DL THP For pcell_scells
    [Arguments]    ${st_ue_id}    ${en_ue_id}    ${varg_expected_thp}
    [Documentation]    This KW takes 3 parameters as argument.
    ...                The 3rd argument is a list which consist of first parameter SA/NSA (sa_flag: 1 means SA, 0 means NSA),
    ...                second parameter used to get how many component carriers are used (cc_count: 1 --> 1CC only pcell stats
    ...                are needed, 2 --> 2CC, pcell and one scell ). Third parameter will represent expected_dl_thp
    ...                for pcell, 4th argument in list will represent expected_dl_thp for scell_1 , 5th argument in
    ...                list will represent expected_dl_thp for scell_2 and so on.
    ...                cc_count and number of expected_dl_thp passed should mathc. Otherwise this KW will fail
    ${sa_flag}    Get From List	   ${varg_expected_thp}	0
    ${cc_count}    Get From List	   ${varg_expected_thp}	1
	${expected_thp}    Get Slice From List	${varg_expected_thp}	2
	log to console    ${expected_thp}
	${numofexpthp}    Get length    ${expected_thp}
	Should Be Equal As Integers    ${numofexpthp}    ${cc_count}
    ${scell_idx} =	Set Variable If	'${sa_flag}' > '0'      0      8
    log to console    ${scell_idx}
	Runkeyword IF   ${cc_count}==4    Verify DL THP for four cell config    ${st_ue_id}    ${en_ue_id}    ${scell_idx}      ${expected_thp}
	...   ELSE IF   ${cc_count}==3    Verify DL THP for three cell config    ${st_ue_id}    ${en_ue_id}    ${scell_idx}      ${expected_thp}
	...   ELSE IF   ${cc_count}==2    Verify DL THP for two cell config    ${st_ue_id}    ${en_ue_id}    ${scell_idx}      ${expected_thp}
	...   ELSE IF   ${cc_count}==1    Verify DL THP for single cell config    ${st_ue_id}    ${en_ue_id}    ${scell_idx}      ${expected_thp}

Attach SA Ue and start low DL data
    [Arguments]    ${st_ue_id}    ${en_ue_id}    ${trf_id_num}    ${varg_expected_thp}
    log to console   UE attach trigerring now...
    ${crnti_list}=     MultiUE Register should be Successful     ${st_ue_id}    ${en_ue_id}
    set test variable      ${crnti_list}
    sleep  10s
    FOR    ${trf_id}    IN RANGE    1    ${trf_id_num}
        MultiUE Trigger DL Traffic for SA    ${st_ue_id}    ${en_ue_id}    Traffic_rate=mbps     dl_rate=175
        ...    pdu_id=${Pdu_session_ID}    trf_id=${trf_id}       qfi_id=${qfi_id}
        MultiUE Trigger UL Traffic for SA    ${st_ue_id}    ${en_ue_id}    Traffic_rate=mbps     ul_rate=175
        ...    pdu_id=${Pdu_session_ID}    trf_id=${trf_id}       qfi_id=${qfi_id}
    END
    sleep  20s
    Verify DL THP For pcell_scells    ${st_ue_id}    ${en_ue_id}    ${varg_expected_thp}

Increase DL data and verify scell activation
    [Arguments]    ${st_ue_id}    ${en_ue_id}    ${trf_id_num}    ${varg_expected_thp}
    FOR    ${trf_id}    IN RANGE    3    ${trf_id_num}
        MultiUE Trigger DL Traffic for SA    ${st_ue_id}    ${en_ue_id}    Traffic_rate=mbps     dl_rate=175
        ...    pdu_id=${Pdu_session_ID}    trf_id=${trf_id}       qfi_id=${qfi_id}
    END
    sleep  30s
    Verify DL THP For pcell_scells    ${st_ue_id}    ${en_ue_id}     ${varg_expected_thp}

Start 700 Mbps Big DL Data Transfer And Check SCell Activation for 3CC
    [Arguments]     ${ue_id}
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=150       trf_id=1
    sleep   5s
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=150       trf_id=2
    sleep   5s    reason=Wait for successful traffic start
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=150       trf_id=3
    sleep   5s
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=150       trf_id=4
    sleep   5s    reason=Wait for successful traffic start
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=100       trf_id=5
    sleep   5s    reason=Wait for successful traffic start
