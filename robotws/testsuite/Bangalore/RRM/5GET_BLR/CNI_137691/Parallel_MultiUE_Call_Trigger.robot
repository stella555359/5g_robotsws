*** Settings ***

Force Tags        CLOUD_5G_I_LO_AP_LO     VARIANT_SANSA_FS_ECPRI_CMWV_TDD
...               RAN_5G_TDD    RAN_5G      5G_RAN     SBTS00    CONFIGURED   CRT

Documentation    :copyright: Nokia
...              :authors: Megha Dm, Navin

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          Collections
Resource         ../CB008541/resources/CB008541_Keywords.robot
Resource         ../resources/robot/common_log_collection.robot
Resource         ../resources/robot/wts_sim_keywords.robot
Library        ../resources/NPS/SWENG/python_libs/luashark_tools.py

Suite Setup         Run Keyword and Ignore Error      Suite setup from scratch

Suite Teardown      Run Keywords    Log To console  Suitetardown
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

Test Teardown    Run Keywords       Link SCOUT SCF to Configuration ID for Reporting
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
...                 AND     Run Keyword and Ignore Error    Stop Log     snapshot    sosreport

*** Variables ***
${TLConfig.isUTE}   True
${wts_cfg_file}     ${CURDIR}/config/wts/vonr_eme_ho_gbr_ngbr.cfg
${delta_file}       vonr_eme_ho_gbr_ngbr.json
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${scf_file_path}    ${CURDIR}/config/
${WTS_DIR}          /opt/iphy/latest
${nwslice_ID}   1
${epc_log_path}    /tmp/
${XnHo_success}     rrcReconfigurationComplete
${pdu_id}   1
${Traffic_rate}     mbps
${VoNR_Traffic_rate}	kbps
${Traffic_unit}     kbps
${qfi}       1
${start_ue_id}      1
${end_ue_id}        10
${gbr_startue}      1
${gbr_endue}        2
${ngbr_startue}     3
${ngbr_endue}       4
${vonr_startue}     5
${vonr_endue}       6
${eme_startue}      7
${eme_endue}        8
${xnho_startue}     9
${xnho_endue}       10
${meas_id}      1
${sim_gNBPCI}       52
${real_gNBPCI}      50
${trf_id}    1
${qci1_qos}     3
${emeqos_qci1}  2

*** Test Cases ***
[1.0] CNI_137691 Parallel Test scenario to execute HO, VoNR, GBR, NonGBR and Emergency Call

    Execute HO, VoNR, Emergency, GBR and Non-GBR Test   ${delta_file}    ${wts_cfg_file}  1     52    50    mbps    kbps   30	 10   25.1	150   75	1

*** Keywords ***

Execute HO, VoNR, Emergency, GBR and Non-GBR Test
    [Arguments]     ${delta_file}   ${wts_cfg}  ${meas_id}    ${sim_gNBPCI}     ${real_gNBPCI}      ${Traffic_rate}    ${VoNR_Traffic_rate}
    ...      ${gbr_drate}      ${ngbr_drate}    ${vonr_drate}     ${ho_dlrate}      ${ho_ulrate}     ${pdu_id}
    Perform commissioning and load cfg      ${delta_file}       ${wts_cfg}
    Make gbr call and Validate     ${gbr_startue}    ${gbr_endue}       ${Traffic_rate}    ${gbr_drate}
    Make non-gbr call and Validate  ${ngbr_startue}    ${ngbr_endue}      ${Traffic_rate}     ${ngbr_drate}
    Make VoNR call and Validate     ${vonr_startue}    ${vonr_endue}    ${pdu_id}	${VoNR_Traffic_rate}    ${vonr_drate}
    Make Emergency call and Validate     ${eme_startue}    ${eme_endue}     ${pdu_id}   ${VoNR_Traffic_rate}  ${vonr_drate}
    Perform XnHO from Real to Sim & Sim to Real     ${xnho_startue}    ${xnho_endue}    ${meas_id}    ${sim_gNBPCI}     ${real_gNBPCI}
    ...     ${Traffic_rate}     ${ho_dlrate}   ${ho_ulrate}     ${pdu_id}
    wts_sim_keywords.MultiUE Deregister should be Successful     ${start_ue_id}      ${end_ue_id}

Perform commissioning and load cfg
    [Arguments]      ${delta_file}      ${wts_cfg}
     Perform SCF Delta Commissioning with ${delta_file}
     sleep    60
     OperatingSystem.Run    sudo ip addr add 10.0.1.3/24 dev eth3
     OperatingSystem.Run    sudo ip addr add 10.0.1.4/24 dev eth3
     sleep    10
     Load CFG and verify cell status   ${wts_cfg}   1   1


Make VoNR call and Validate
    [Arguments]     ${start_ue_id}     ${end_ue_id}    ${pdu_id}    ${VoNR_Traffic_rate}   ${vonr_drate}
    Start Log     cprt
    UE Register Should be successfull  ${start_ue_id}      ${end_ue_id}
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
     ute_wtssim.execute_egate_command   cmd=set_pdu_param ue=${ue_idx} pdu=${pdu_id} trf_type=internal

    ${modify_pdu1}   SET VARIABLE    ue_pdu_session_modify ue=${ue_idx} pdu=${pdu_id} qosflows_to_add=2 by=amf
    ${output1}  ute_wtssim.Execute Egate Command And Wait For Data  ${modify_pdu1}
    ...     pass_regexp=Added QosFlow with QFI:2 fiveQI:5        timeout=10s
    sleep   3s
    ${modify_pdu2}   SET VARIABLE    ue_pdu_session_modify ue=${ue_idx} pdu=${pdu_id} qosflows_to_add=3 by=amf
    ${output2}  ute_wtssim.Execute Egate Command And Wait For Data  ${modify_pdu2}
    ...     pass_regexp=Added QosFlow with QFI:3 fiveQI:1        timeout=10s
	Trigger VONR custom data    ${ue_idx}    ul    ${pdu_id}    ${trf_id}    ${qci1_qos}    ${VoNR_Traffic_rate}   ${vonr_drate}    custom
    Trigger VONR custom data    ${ue_idx}    dl    ${pdu_id}    ${trf_id}    ${qci1_qos}    ${VoNR_Traffic_rate}   ${vonr_drate}    custom
    END
    ${path3}    Stop Log      cprt      test_scenario=${ue_idx}_vonr
    ${ue_count}=    Evaluate    ${end_ue_id} - ${start_ue_id} + 1
    Verify VoNR From PCAP    ${path3}[cprt]/NODECPRT_GNB.pcap     ngap      ${ue_count}

UE Register Should be successfull
    [Arguments]     ${start_ue_id}      ${end_ue_id}
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    ${cmd}        Set variable    ue_register id=${ue_idx}
    ute_wtssim.execute_egate_command   cmd=set_pdu_param ue=${ue_idx} pdu=1 trf_type=internal
    ${output}  ute_wtssim.Execute Egate Command And Wait For Data  ${cmd}
    ...     pass_regexp=(\?\:${UE_register_complete_pattern})        timeout=10s
    ${pdu_setup_cmd2}   SET VARIABLE    ue_pdu_session_setup ue=${ue_idx} pdu=${pdu_id} nwslice=1 gw=${ue_idx}

    ${output2}  ute_wtssim.Execute Egate Command And Wait For Data  ${pdu_setup_cmd2}
    ...     pass_regexp=(\?\:${PDU_session_resource_setup_response}|${Initial_context_setup_pattern})        timeout=10s
    END

Verify VoNR From PCAP
    [Arguments]      ${logpath}       ${filter_req}     ${ue_count}
    ${pdmlFile} =    Get filtered PDML file from pcap     ${logpath}       ${filter_req}
    ${Output} =   analyzer.get_shownames    ${pdmlFile}
    ...          packetName=ngap.fiveQI
    ...          path=.*fiveQI$
    ${fiveQI5Count}=    Evaluate    ${Output}.count("fiveQI: 5")
    ${fiveQI1Count}=    Evaluate    ${Output}.count("fiveQI: 1")

    Run Keyword If    ${fiveQI5Count} == ${ue_count} and ${fiveQI1Count} == ${ue_count}
    ...    Log to Console    Both fiveQI: 5 and fiveQI: 1 are present in the output.
    ...    ELSE
    ...    Fail    Either fiveQI: 5 or fiveQI: 1 is missing in the output.

Trigger VONR custom data
	[Arguments]    ${ue_idx}    ${dir}		${pdu_id}     ${trf_id}		${qfi}		${Traffic_unit}		${Traffic_rate}		${rtp_codec}
    [Documentation]    This keyword starts the vonr data
    Log to Console    \nRunning Traffic ${Traffic_unit}    ${Traffic_rate}
	${data_cmd}	SET VARIABLE	trf_data_start ue=${ue_idx} pdu=${pdu_id} qfi=${qfi} dir=${dir} trf_id=${trf_id} rtp_codec=${rtp_codec}
    ute_wtssim.Execute Egate Command And Wait For Data		${data_cmd}		timeout=${EGATE_COMMAND_TIMEOUT}

Make Emergency call and Validate
    [Arguments]     ${start_ue_id}     ${end_ue_id}    ${pdu_id}	  ${VoNR_Traffic_rate}   ${vonr_drate}
    Start Log     cprt
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Emergency call  ${ue_idx}  ${pdu_id}
    Trigger VONR custom data    ${ue_idx}    ul    ${pdu_id}    ${trf_id}    ${emeqos_qci1}    ${VoNR_Traffic_rate}   ${vonr_drate}    custom
    Trigger VONR custom data    ${ue_idx}    dl    ${pdu_id}    ${trf_id}    ${emeqos_qci1}    ${VoNR_Traffic_rate}   ${vonr_drate}    custom
    END
    ${path5}    Stop Log      cprt      test_scenario=${ue_idx}_emergency_call
    ${ue_count}=    Evaluate    ${end_ue_id} - ${start_ue_id} + 1
    Verify emergency call    ${path5}[cprt]/NODECPRT_GNB.pcap      ngap		${ue_count}

Emergency call
    [Arguments]    ${ue_idx}    ${pdu_id}    ${ics_wo_pdu}=${-1}
    ${crnti_list}       Create List
    ${Initial_context_setup_pattern}    setvariable if    ${ics_wo_pdu}==${1}
    ...      Pdu Session Resource Setup Response Message with RAN UE NGAP ID    ${Initial_context_setup_pattern}
    ute_wtssim.execute_egate_command    cmd=qosflow_modify default=on ue=${ue_idx} qos_flow=2
    ute_wtssim.execute_egate_command    cmd=ue_nr_rrc_setup_param id=${ue_idx} establishment_cause=emergency
    ute_wtssim.execute_egate_command    cmd=qosflow_modify qos_flow=2 priority=1
    ute_wtssim.execute_egate_command    cmd=qosflow_modify qos_flow=3 priority=1
    ute_wtssim.execute_egate_command    cmd=set_pdu_param ue=${ue_idx} pdu=${pdu_id} trf_type=internal
    ${cmd}        Set variable    ue_register id=${ue_idx} registration_type=EmergencyRegistration
    ${output}  ute_wtssim.Execute Egate Command And Wait For Data  ${cmd}
    ...     pass_regexp=(\?\:${UE_register_complete_pattern})        timeout=10s
    ${gw_id}     Set variable if    ${1}==${pdu_id}   ${pdu_id}    ${ue_idx}
    ${tmp_var}    set variable     request_type=initial-emergency-request
    ${pdu_setup_cmd2}   SET VARIABLE    ue_pdu_session_setup ue=${ue_idx} pdu=${pdu_id} nwslice=1 gw=${ue_idx}
    ${output2}  ute_wtssim.Execute Egate Command And Wait For Data  ${pdu_setup_cmd2}
    ...     pass_regexp=(\?\:${PDU_session_resource_setup_response}|${Initial_context_setup_pattern})        timeout=10s
    ute_wtssim.execute_egate_command    cmd=smf_param id=1 reset
    wts_sim_keywords.UE PDU Modfication should be Successful     ${ue_idx}    ${pdu_id}    3

Verify emergency call
   [Arguments]      ${logpath}       ${filter_req}     ${ue_count}
    ${pdmlFile} =    Get filtered PDML file from pcap     ${logpath}       ${filter_req}
    ${Output1} =   analyzer.get_shownames    ${pdmlFile}
    ...          packetName=ngap.fiveQI
    ...          path=.*fiveQI$
    ${Output2}=    analyzer.Get Shownames
    ...          ${pdmlFile}
    ...          packetName=ngap
    ...           path=.*RRCEstablishmentCause$
    ${fiveQI5Count}=    Evaluate    ${Output1}.count("fiveQI: 5")
    ${fiveQI1Count}=    Evaluate    ${Output1}.count("fiveQI: 1")
    ${RestablishmentCauseCount}=     BuiltIn.Evaluate    ${Output2}.count("RRCEstablishmentCause: emergency (0)")

    Run Keyword If    ${fiveQI5Count} == ${ue_count} and ${fiveQI1Count} == ${ue_count} and ${RestablishmentCauseCount} == ${ue_count}
    ...    Log to Console    Both fiveQI: 5, fiveQI: 1 and RestablishmentCauseCount: emergency are present in the output.
    ...    ELSE
    ...    Fail    Either fiveQI: 5 or fiveQI: 1 or RestablishmentCauseCount: emergencyis missing in the output

Perform XnHO from Real to Sim & Sim to Real
     [Arguments]     ${start_ue_id}      ${end_ue_id}     ${meas_id}    ${sim_phycell_id}     ${real_phycell_id}    ${Traffic_rate}   ${ho_dlrate}
    ...      ${ho_ulrate}	${pdu_id}    ${qfi_id}=1
    Start Log     cprt
    ${ue_count}=    Evaluate    ${end_ue_id} - ${start_ue_id} + 1
    UE Register Should be successfull   ${start_ue_id}      ${end_ue_id}

    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    ${start_ue_id}    ${end_ue_id}    Traffic_rate=${Traffic_rate}     dl_rate=${ho_dlrate}
    ...     pdu_id=${pdu_id}    trf_id=${trf_id}       qfi_id=${qfi_id}
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    ${start_ue_id}    ${end_ue_id}    Traffic_rate=${Traffic_rate}     ul_rate=${ho_ulrate}
    ...     pdu_id=${pdu_id}    trf_id=${trf_id}       qfi_id=${qfi_id}
    sleep   10s
    Validate DL Traffic For MultiUE SA      ${start_ue_id}    ${end_ue_id}  ${ho_dlrate}   ${pdu_id}    ${qfi}
   FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Trigger XnHO from real to simulator     ${ue_idx}       ${meas_id}       ${sim_phycell_id}      311:490|0x01
    END

    ${path6}    Stop Log      cprt      test_scenario=${ue_idx}_ho_real_to_sim
    Verify XnAP Messages from PCAP   ${path6}[cprt]/NODECPRT_GNB.pcap   xnap    ${ue_count}
    Start Log     cprt
    Validate DL Traffic For MultiUE SA      ${start_ue_id}    ${end_ue_id}  ${ho_dlrate}   ${pdu_id}    ${qfi}
    Validate UL Traffic For MultiUE SA      ${start_ue_id}    ${end_ue_id}  ${ho_ulrate}   ${pdu_id}    ${qfi}
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Trigger XnHO from simulator to real     ${ue_idx}       ${meas_id}       ${real_phycell_id}      311:490|0x01
    END

    ${path7}    Stop Log      cprt      test_scenario=${ue_idx}_ho_sim_to_real
    Verify XnAP Messages from PCAP   ${path7}[cprt]/NODECPRT_GNB.pcap   xnap    ${ue_count}

Trigger XnHO from real to simulator
    [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id}     ${nrcgi}
    ${history}     SET VARIABLE    ue_history_information_list_add_ngran id=1 gnb_id=3 cell_type=medium nrcgi=${nrcgi} time_ue_stayed_in_cell=100
    ute_wtssim.execute_egate_command    ${history}
    ute_wtssim.execute_egate_command    cmd=ue_history_information_list action=commit id=1
    ute_wtssim.execute_egate_command    cmd=ue_enb_param id=${ue_id} ue_history_list=1
    ute_wtssim.execute_egate_command    cmd=ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    ${tmp2}    set variable    nrsrp_nr=30 nrsrq_nr=20
    ${msr}      SET VARIABLE    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=1 srsrq_nr=1 phycell_id=${phycell_id} ${tmp2}
    ute_wtssim.Execute Egate Command And Wait For Data      ${msr}     pass_regexp=${XnHo_success}      timeout=30s

Trigger XnHO from simulator to real
    [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id}     ${nrcgi}
    ${history}     SET VARIABLE      ue_history_information_list_add_ngran id=2 gnb_id=2 cell_type=medium nrcgi=${nrcgi} time_ue_stayed_in_cell=100
    ute_wtssim.execute_egate_command    ${history}
    ute_wtssim.execute_egate_command    cmd=ue_history_information_list action=commit id=2
    ute_wtssim.execute_egate_command    cmd=ue_enb_param id=${ue_id} ue_history_list=2
    ute_wtssim.execute_egate_command    cmd=ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    ${tmp2}    set variable    nrsrp_nr=30 nrsrq_nr=20
    ${msr}      SET VARIABLE    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=1 srsrq_nr=1 phycell_id=${phycell_id} ${tmp2}
    ute_wtssim.Execute Egate Command And Wait For Data      ${msr}     pass_regexp=${XnHo_success}      timeout=30s

Verify XnAP Messages from PCAP
    [Arguments]    ${logpath}    ${filter_req}    ${ue_count}
    ${pdmlFile} =  Get filtered PDML file from pcap   ${logpath}    ${filter_req}
    ${Output} =  analyzer.Get Shownames   ${pdmlFile}
    ...         packetName=xnap
    ...         path=.*HandoverRequestAcknowledge.*
    ...         endPacket=-${1}
    Run Keyword If    ${Output} == None    Fail    No matching packets found in PDML file: ${pdmlFile}
    ${count} =  Collections.Get Match Count   ${Output}    HandoverRequestAcknowledge
    Run Keyword If    ${count} != ${ue_count}    Fail    Expected ${ue_count} matches, but found ${count}.
   BuiltIn.Log To Console    Verification successful: ${count} matches found.

Fetch filtered PDML file from pcap
    [Arguments]                     ${pcapFile}       ${filterExp}=None        ${filterName}=None
    [Documentation]                 Takes a PDML file as input, and returns it into a PDML file
    ${filterPcap}                   analyzer.filter_pcap            ${pcapFile}
    ...                             filterName=${filterName}        filterExp=${filterExp}
    ${pdmlFile}=                    analyzer.pcap_to_pdml           ${filterPcap}
    [Return]    ${pdmlFile}

Make gbr call and Validate
    [Arguments]     ${start_ue_id}      ${end_ue_id}     ${Traffic_rate}   ${gbr_drate}     ${pdu_id}=1    ${qfi_id}=2
     Start Log     cprt
    UE Register Should be successfull      ${start_ue_id}      ${end_ue_id}
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
        ute_wtssim.execute_egate_command   cmd=set_pdu_param ue=${ue_idx} pdu=${pdu_id} trf_type=internal
        ${modify_pdu1}   SET VARIABLE    ue_pdu_session_modify ue=${ue_idx} pdu=${pdu_id} qosflows_to_add=5 by=amf
        ${output1}  ute_wtssim.Execute Egate Command And Wait For Data  ${modify_pdu1}
        ...     pass_regexp=Added QosFlow with QFI:2 fiveQI:3        timeout=10s
        sleep   3s
        END
     wts_sim_keywords.MultiUE Trigger DL Traffic for SA    ${start_ue_id}    ${end_ue_id}    Traffic_rate=${Traffic_rate}     dl_rate=${gbr_drate}
    ...     pdu_id=${pdu_id}    trf_id=${trf_id}       qfi_id=${qfi_id}
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    ${start_ue_id}    ${end_ue_id}    Traffic_rate=${Traffic_rate}     ul_rate=${gbr_drate}
    ...     pdu_id=${pdu_id}    trf_id=${trf_id}       qfi_id=${qfi_id}
    sleep   5s
    Validate DL Traffic For MultiUE SA      ${start_ue_id}    ${end_ue_id}  ${gbr_drate}   ${pdu_id}    qfi_id=2
    Validate UL Traffic For MultiUE SA      ${start_ue_id}    ${end_ue_id}  ${gbr_drate}   ${pdu_id}    qfi_id=2
    ${path3}    Stop Log      cprt      test_scenario=${ue_idx}_gbr
    ${ue_count}=    Evaluate    ${end_ue_id} - ${start_ue_id} + 1
    Verify gbr From PCAP    ${path3}[cprt]/NODECPRT_GNB.pcap     ngap      ${ue_count}

Verify gbr From PCAP
    [Arguments]      ${logpath}       ${filter_req}     ${ue_count}
    ${pdmlFile} =    Get filtered PDML file from pcap     ${logpath}       ${filter_req}
    ${Output} =   analyzer.get_shownames    ${pdmlFile}
    ...          packetName=ngap.fiveQI
    ...          path=.*fiveQI$
    ${fiveQI3Count}=    Evaluate    ${Output}.count("fiveQI: 3")
    Run Keyword If    ${fiveQI3Count} == ${ue_count}
    ...    Log to Console    Both fiveQI: 3 and fiveQI is present in the output.
    ...    ELSE
    ...    Fail    Either fiveQI: 3 is missing in the output.

Make non-gbr call and Validate
    [Arguments]     ${start_ue_id}      ${end_ue_id}     ${Traffic_rate}   ${ngbr_drate}     ${pdu_id}=1    ${qfi_id}=1
    UE Register Should be successfull_non_gbr      ${start_ue_id}      ${end_ue_id}
    sleep   20s
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    ${start_ue_id}    ${end_ue_id}    Traffic_rate=${Traffic_rate}     dl_rate=${ngbr_drate}
    ...     pdu_id=${pdu_id}    trf_id=${trf_id}       qfi_id=${qfi_id}
     wts_sim_keywords.MultiUE Trigger UL Traffic for SA    ${start_ue_id}    ${end_ue_id}    Traffic_rate=${Traffic_rate}     ul_rate=${ngbr_drate}
    ...     pdu_id=${pdu_id}    trf_id=${trf_id}       qfi_id=${qfi_id}
    sleep   5s
    Validate DL Traffic For MultiUE SA      ${start_ue_id}    ${end_ue_id}  ${ngbr_drate}   ${pdu_id}    ${qfi_id}
    Validate UL Traffic For MultiUE SA      ${start_ue_id}    ${end_ue_id}  ${ngbr_drate}   ${pdu_id}    ${qfi_id}

UE Register Should be successfull_non_gbr
    [Arguments]     ${start_ue_id}      ${end_ue_id}
     Start Log     cprt
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    ${cmd}        Set variable    ue_register id=${ue_idx}
    ${output}  ute_wtssim.Execute Egate Command And Wait For Data  ${cmd}
    ...     pass_regexp=(\?\:${UE_register_complete_pattern})        timeout=10s
    ute_wtssim.execute_egate_command   cmd=set_pdu_param ue=${ue_idx} pdu=${pdu_id} trf_type=internal
    ${pdu_setup_cmd2}   SET VARIABLE    ue_pdu_session_setup ue=${ue_idx} pdu=${pdu_id} nwslice=1 gw=${ue_idx}
    ${output2}  ute_wtssim.Execute Egate Command And Wait For Data  ${pdu_setup_cmd2}
    ...     pass_regexp=(\?\:${PDU_session_resource_setup_response}|${Initial_context_setup_pattern})        timeout=10s
    ${path4}    Stop Log      cprt      test_scenario=ue_${ue_idx}_non_gbr
    log to console      cprt-path-${path4}
    Verify non_gbr From PCAP    ${path4}[cprt]/NODECPRT_GNB.pcap     ngap
    END
    [Return]    ${path4}

Verify non_gbr From PCAP
    [Arguments]      ${logpath}       ${filter_req}     #${ue_count}
    ${pdmlFile} =    Get filtered PDML file from pcap     ${logpath}       ${filter_req}
    ${Output} =   analyzer.get_shownames    ${pdmlFile}
    ...          packetName=ngap.fiveQI
    ...          path=.*fiveQI$
    Log to Console    ${Output}[0]
    should contain      fiveQI: 6     ${Output}[0]
