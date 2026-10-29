*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env Aic
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic
Force Tags    QCD_MN_RAN    QCP_RAN_ET    master_vDU    RAN_5G    RAN_Aic    CIT    CLOUD_5GC_dR2.0_1vDU_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    owner-jianfen.shen    release-5G21B    team-DevHZ5_SG02    vDUCNF00

Resource    ../../../../resources_aic/DevHZ5_resource_aic.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/1du/2cell

${UE1}    31
${UE2}    32

*** Test Cases ***
CB007467-5G-ET-E001_Verify_resource_released_and_cp-nrt_container_recovered_after_cp-nrt_process_failure
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...    UE resource can be released after cp-nrt process failure.
    ...    cp-nrt container can be recovered after cp-nrt process failure.
    ...    UE resource can be created after cp-nrt container resovered.
    ...    2. Test Case Steps:
    ...         a. Kill cp-nrt process by using:
    ...            kubectl -ti exec -n <namespace> <cp-nrt pod name> -c <cp-nrt contianer> bash
    ...            kill -9 <cp-nrt process_id>
    ...         b. Stop tcpdump and check UE1 resource is released by pcap
    ...         c. Check cell in webEM
    ...         d. UE1 make L3 call again, Attach UE2 and traffic
    ...    3. Expected Results:
    ...         Step a: cp-nrt container is restart and CP-NRT POD is not restart.
    ...         Step b: E1 full reset and F1/X2 partial reset should be triggered
    ...            F1PartialReset: sctp.data_payload_proto_id == 62 and f1ap.procedureCode == 0 and f1ap.F1AP_PDU == 0 and f1ap.ResetType == 1
    ...            F1PartialResetAcknowledge: sctp.data_payload_proto_id == 62 and f1ap.procedureCode == 0 and f1ap.F1AP_PDU == 1
    ...            X2PartialReset: sctp.data_payload_proto_id == 27 and x2ap.procedureCode == 40 and x2ap.X2AP_PDU == 0
    ...            X2PartialResetConfirm: sctp.data_payload_proto_id == 27 and x2ap.procedureCode == 40 and x2ap.X2AP_PDU == 1
    ...            E1Reset:sctp.data_payload_proto_id == 64 " and e1ap.procedureCode == 0 and e1ap.E1AP_PDU == 0 and e1ap.ResetType == 0
    ...            E1ResetAcknowledge: sctp.data_payload_proto_id == 64 and e1ap.procedureCode == 0 and e1ap.E1AP_PDU == 1
    ...         Step c: cell is 'Online'
    ...         step d: UE1 and UE2 L3 call make successful
    [Tags]    QC_91023
    NSA UE Attach and Get E1F1X2 UEID    ${UE1}
    Restart cpnrt Container By Kill cp-nrt process And Check cpnrt Pod Is Not Restart
    Check ${UE1} Should Be Released
    Cells Should Be Onair DU
    Attach UE1 UE2 Should Be Successful
    Release Ues    ue_id=${UE1}-${UE2}    ue_type=nsa


*** Keywords ***
Modify Cfg Aic
    ${V_1}    catenate
    ...    ue_param id=${UE2} ue_nr_capabilities=${SA_Capa_perUE_Full} dual_conn=eutra_nr
    ...    ue_eutra_nr_capabilities=${Capa_LTE}
    Update Cfg Aic    ${V_1}

Check ${ue_id} Should Be Released
    Check WireShark Log Aic    ${CURDIR}/a2a_E001/a2a_UE${ue_id}_release.ini    name=UE${ue_id}_release    wait_string=ResetAcknowledge::3

Attach UE1 UE2 Should Be Successful
    Attach UE Again    ${UE1}
    NSA UE Attach and Traffic    ue_id=${UE2}

Attach UE Again
    [Arguments]    ${ue_id}=1    ${cmd_endc_regexp}=reported successful RA
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=1 bearer=2 type=split_scg    ${cmd_endc_regexp}
    traffic should be ok    ue_id=${ue_id}    type=NSA

NSA UE Attach and Traffic
    [Arguments]    ${ue_id}=1    ${cmd_regexp}=UE IS ACTIVE    ${target_gnb}=2    ${target_cells}=1    ${cmd_endc_regexp}=reported successful RA
    Execute Egate Command    ue_attach id=${ue_id}    ${cmd_regexp}
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb} target_cells=1 bearer=2 type=split_scg    ${cmd_endc_regexp}
    traffic should be ok    ue_id=${ue_id}    type=NSA

Restart ${ctr_name} Container By Kill ${kill_pro} process And Check ${pod_name} Pod Is Not Restart
    Start To Capture Wireshark Log Aic    UE${UE1}_release
    Get Full Pod Name And Container Name    ${pod_name}    ${ctr_name}
    ${restart_times_1}    Get Pod Restart Times    ${pod_fullname}
    ${pid}    Get Specified Pid    ${kill_pro}    ${pod_fullname}    ${container_fullname}
    execute_cmd_on_vcu    kubectl -ti exec -n ${VCU_NAMESPACE} ${pod_fullname} -c ${container_fullname} -- kill -9 ${pid}
    Sleep    2s    Make Sure Process killed
    wait all pods running vcu    namespace=${VCU_NAMESPACE}    interrupt_once_fail=False
    ${restart_times_2}    Get Pod Restart Times    ${pod_fullname}
    ${result}     Evaluate    ${restart_times_2}==${restart_times_1}+1
    Should Be True    ${result}

Get Full Pod Name And Container Name
    [Arguments]    ${pod_name}    ${ctr_name}
    ${pod_fullname}    Find Pod Fullname In Aic vCU    ${pod_name}
    Set Test Variable    ${pod_fullname}
    ${container_fullname}    Find Container Fullname In Aic vCU    ${pod_name}    ${ctr_name}
    Set Test Variable    ${container_fullname}

NSA UE Attach and Get E1F1X2 UEID
    [Arguments]    ${ue_id}
    Start To Capture Wireshark Log Aic    UE${ue_id}_attach
    NSA UE Attach and Traffic    ue_id=${ue_id}
    Check WireShark Log Aic    ${CURDIR}/a2a_E001/a2a_UE${ue_id}_attach.ini    name=UE${ue_id}_attach
    ...    wait_string=BearerContextModificationResponse::6
    Get UE attach interface UEID    ${ue_id}    GNB-CU-UP-UE-E1AP-ID
    Get UE attach interface UEID    ${ue_id}    GNB-CU-CP-UE-E1AP-ID
    Get UE attach interface UEID    ${ue_id}    SgNB-UE-X2AP-ID
    Get UE attach interface UEID    ${ue_id}    GNB-CU-UE-F1AP-ID
    Get UE attach interface UEID    ${ue_id}    GNB-DU-UE-F1AP-ID

Get Pod Restart Times
    [Arguments]    ${pod_name}
    ${pod_content}    execute_cmd_on_vcu    kubectl get pod -n ${VCU_NAMESPACE} | grep -i ${pod_name}
    ${restart_times}    Set Variable    ${pod_content.splitlines()[-1].split()[3].strip()}
    [Return]    ${restart_times}

Get Specified Pid
    [Arguments]    ${kill_pro}    ${pod_name}    ${container_name}
    ${cmd}    execute_cmd_on_vcu    kubectl -ti exec -n ${VCU_NAMESPACE} ${pod_name} -c ${container_name} -- ps -elf |grep ${kill_pro}
    ${pid}    Set Variable    ${cmd.splitlines()[0].split()[3]}
    [Return]    ${pid.strip()}

Get UE attach interface UEID
    [Arguments]    ${ue_id}    ${interface_id}
    ${id_content}    Run    cat ${SAVE LOG DIRECTORY}/a2a_logs_succeed/cu_cpif_wireshark_UE${ue_id}_attach.txt.a2a_decode | grep ${interface_id}
    ${id_list}    Get Regexp Matches    ${id_content}     ${interface_id} = (\\d+)    1
    Set Test Variable    ${attach_UE${ue_id}_${interface_id}}    ${id_list}[0]    #${attach_UE1_GNB-CU-UP-UE-E1AP-ID}
