*** Settings ***
Documentation      Author: jia-rebecca.liu@nokia-sbell.com
...                squad group: SG_03
...                feature : CB012810_A & CB012810_B & CB012810_C

Resource         Resources/CB012810_case_step.robot



Suite Setup         Run Keyword     CB012810_suite_setup    If_swconfig=True    reset_site=True

Suite Teardown      CB012810_suite_teardown


*** Variables ***
${TS_LOG_PATH_BASE}         /home/ute/test_results/
${target_dir}               /home/ute/test_results/
@{12810_allow_fault_list}     7107    4681
${A2B2015_wireshark_attach_N1}            A2B2015_wireshark_attach_N1.pcap
${A2B2015_wireshark_attach_N2}            A2B2015_wireshark_attach_N2.pcap
${A2B2015_wireshark_attach_EMC}           A2B2015_wireshark_attach_EMC.pcap
${A2B2015_wireshark_attach_PA}            A2B2015_wireshark_attach_PA.pcap
${A3IWK3001_wireshark_attach_N1}            A3IWK3001_wireshark_attach_N1.pcap
${A3IWK3001_wireshark_attach_N2}            A3IWK3001_wireshark_attach_N2.pcap
${A3IWK3001_wireshark_attach_N3}            A3IWK3001_wireshark_attach_N3.pcap
${C3B1_wireshark_attach_N1}                C3B1_wireshark_attach_N1.pcap
${C3B1_wireshark_attach_N2}                C3B1_wireshark_attach_N2.pcap
${C3B1_wireshark_attach_EMC}               C3B1_wireshark_attach_EMC.pcap
${C3B1_wireshark_attach_N3_failed}          C3B1_wireshark_attach_N3_failed.pcap
${C3B1_wireshark_attach_N3_success}         C3B1_wireshark_attach_N3_success.pcap
${C3B1_wireshark_HO}                        C3B1_wireshark_HO.pcap
${C4B1_wireshark_attach}                    C4B1_wireshark_attach.pcap
${C4B1_wireshark_HO}                        C4B1_wireshark_HO.pcap
${BIWK2015_wireshark_true}                   BIWK2015_wireshark_true.pcap
${BIWK2015_wireshark_false}                  BIWK2015_wireshark_false.pcap


*** Test Cases ***
[1]CB012810_A2_B2_015_Fallback_from_service_specific_DRB_SR_resources_to_cell_level_SR_resources_during_RAC
    [Documentation]
    ...    cover A_B1_001，A_B1_002,A_EC_004，A_EC_005,A_IWK1_007，A_IWK1_008,A2_B1_012，A2_B1_013,A2_B1_014
    [Tags]    A2_B2_015    CDRT
    [Setup]
    CB012810_case_setup
    ...                    online_ModifySCF=True
    ...                    Modify_Para_Online=${Online_Modify_A2B2015}
    ...                    Delete_Para_Online=${Online_Delete_A2B2015}
    UE_and_PA_prepare    gnb_cell1_value=${0}
    Prepare to caculate PM counter     period=start
    Comment     sdx65 attach success
    ${attachlog_UE1}    The 1st normal UE attached success A2B2015
    Comment    S24 attach failed at first time, then make 911 success
    ${attachlog_UE2}    ${EMCcall_UE2}    The 2nd normal UE attached failed then make EMC call A2B2015
    Comment    S23 MPS UE attach success with PA SR resource
    ${attachlog_UE3}    The 3rd PA UE attached success A2B2015    #RRC and DRB all success, use PA resource.
    Prepare to caculate PM counter     period=end
    A2B2015 counter check
    A2B2015 log check    attachlog_UE1=${attachlog_UE1}    attachlog_UE2=${attachlog_UE2}
    ...                  EMCcall_UE2=${EMCcall_UE2}        attachlog_UE3=${attachlog_UE3}
    [Teardown]     Run keywords
    ...    A2B2015_case_recovery
    ...    AND    CB012810_case_teardown

[1]CB012810-A3#IWK3_001_Successful_cell_level_admission_control_adaptive_SR_Normal_UE_with_preemption
    [Documentation]
    ...    cover A3#B2_001, A3#B2_002, A3#B2_003, A3#IWK1_001, B_B1_001, B_B1_002, B_B2_003, B_B2_004, B_B3_007, B_B3_008
    ...    B_B5_013, B_IWK1_014, B_EC1_016, B_EC2_017
    [Tags]    A3#IWK3_001
    [Setup]
    CB012810_case_setup
    ...                    online_ModifySCF=True
    ...                    Modify_Para_Online=${Online_Modify_A3IWK3001}
    UE_and_PA_prepare    gnb_cell3_value=${0}
    Switch APN to Test_need_APN for S21    ue_index=${3}    target_APN=${APN_DXDATA1}    APN_ui_version=one ui 3.1    ue_type=${ue_type_samsung}
    sleep    5s
    Prepare to caculate PM counter     period=start    counter_time=900
    Comment    S21 attach success and use 4 SR resource
    ${attachlog_UE1}    The 1st normal UE attached success A3IWK3001
    Comment    S23 attach success and use 1 SR resource
    ${attachlog_UE2}    The 2nd normal UE attached success A3IWK3001
    Comment    S24 attach success and preempt S21, S21 will re-attach
    ${attachlog_UE3}    The 3rd normal UE preempt the 1st UE A3IWK001
    Prepare to caculate PM counter     period=end    counter_time=900
    A3IWK3001 counter check
    A3IWK3001 log check    attachlog_UE1=${attachlog_UE1}    attachlog_UE2=${attachlog_UE2}    attachlog_UE3=${attachlog_UE3}
    [Teardown]     Run keywords
    ...    A3IWK3001_case_recovery
    ...    AND    CB012810_case_teardown

[1]CB012810-C3_B1_RG_level_admission_control_for_SR_resource_for_a_UE_at_handover_RRC-DRB_setup_combined_Level5
    [Documentation]
    ...    cover C1,C2_B1, C2_3C1_B1 C2_IWK1,C3_B1,handover from cell3 to cell1
    [Tags]    C3_B1
    [Setup]
    CB012810_case_setup
    ...                    online_ModifySCF=True
    ...                    Modify_Para_Online=${Online_Modify_C3B1}
    UE_and_PA_prepare    gnb_cell1_value=${0}
    Prepare to caculate PM counter     period=start
    Comment    the SDX65 UE attach to TDD_CELL1
    ${attachlog_UE1}    The 1st normal UE attached success C3B1
    Comment    the S24 UE attach to TDD_CELL1
    ${EMCcall_UE2}    The 2nd normal UE make EMC call C3B1
    log to console    S24 emc check
    check emc call if setup success    file_path=${EMCcall_UE2}
    Prepare to caculate PM counter     period=end
    C3B1 counter check cell1
    comment    cellbarred TDD_CELL1
    Common Case TestLine Setup     ModifySCF_Aftercommission=True
    ...                            Modify_Para_Online=${TDD_CELL1_barred}
    Comment    gnb_cell3_PA
    Adjust the HBTE attenuation value for 12810    gnb_cell1_value=${0}    gnb_cell3_value=${0}
    Comment    the S21 UE attach to FDD_CELL3 failed
    ${attachlog_UE3_fail}    The 3rd normal UE attached failed on FDD C3B1    ue_index=${3}
#    C3B1 counter check cell3_failed
    Comment    modify parameter maxQuato
    Common Case TestLine Setup     ModifySCF_Aftercommission=True
    ...                            Modify_Para_Online=${Modify_maxQuato_C3B1}
    Prepare to caculate PM counter     period=start
    Comment    the S21 UE re-attach to FDD_CELL3 success
    ${attachlog_UE3_success}    The 3rd normal UE attached success C3B1    ue_index=${3}
    Comment    make S21 HO from CELL3 to CELL1
    Common Case TestLine Setup     ModifySCF_Aftercommission=True
    ...                            Modify_Para_Online=${TDD_cell1_notBarred}
    Start capture wireshark log on master     filename=${C3B1_wireshark_HO}    gNB_index=${0}
    Adjust the HBTE attenuation value for 12810    gnb_cell1_value=${0}    gnb_cell3_value=${25}
    sleep    10s    reason=ue3 handover from CELL3 to CELL1
    ${attachlog_UE3_HO}    Stop and download the wiresharklog from master    filename=${C3B1_wireshark_HO}    gNB_index=${0}
    Prepare to caculate PM counter     period=end
    C3B1_counter_handover_CELL1_CELL3
    C3B1 log check    attachlog_UE1=${attachlog_UE1}    EMCcall_UE2=${EMCcall_UE2}    attachlog_UE3_fail=${attachlog_UE3_fail}
    ...               attachlog_UE3_success=${attachlog_UE3_success}    attachlog_UE3_HO=${attachlog_UE3_HO}
##    [Teardown]    C3B1_case_recovery
    [Teardown]     Run keywords
    ...    C3B1_case_recovery
    ...    AND    CB012810_case_teardown

[1]CB012810-C4_B1_Successful_RG_level_admission_control_for_SR_resource_for_a_UE_RRC-DRB_setup_combined_BB_pool
    [Documentation]
    ...    cover C4, handover from cell3 to cell1, FDD-TDD CA,
    [Tags]    C4_B1
    [Setup]
    CB012810_case_setup
    ...                    online_ModifySCF=True
    ...                    Modify_Para_Online=${Online_Modify_C4B1}
    UE_and_PA_prepare    gnb_cell1_value=${0}    gnb_cell3_value=${0}
    Prepare to caculate PM counter     period=start
    Comment    the samsungS24 attach to FDD_cell3
    ${C4B1_attachlog_UE1}    SamsungS24 UE attached success C4B1
    Prepare to caculate PM counter     period=end
    C4B1 counter check cell3
    Comment    make samsungS24 HO from cell3 to cell1
    Common Case TestLine Setup     ModifySCF_Aftercommission=True
    ...                            Modify_Para_Online=${TDD_cell1_notBarred}
    Prepare to caculate PM counter     period=start
    Start capture wireshark log on master     filename=${C4B1_wireshark_HO}    gNB_index=${0}
    Adjust the HBTE attenuation value for 12810    gnb_cell1_value=${0}    gnb_cell3_value=${25}
    sleep    10s    reason=ue3 handover from cell3 to cell1
    ${C4B1_HO_UE1}    Stop and download the wiresharklog from master    filename=${C4B1_wireshark_HO}    gNB_index=${0}
    Prepare to caculate PM counter     period=end
    C4B1 counter check cell1
    C4B1 log check    C4B1_attachlog_UE1=${C4B1_attachlog_UE1}    C4B1_HO_UE1=${C4B1_HO_UE1}
    [Teardown]     Run keywords
    ...    C4B1_case_recovery
    ...    AND    CB012810_case_teardown

[1]CB012810_B_IWK2_015_Successful_SR_resource_allocation_with_optimized_algorithm_for_VoNR_UE_when_CB009849-D_is_activated
    [Documentation]
    [Tags]    B_IWK2_015
    [Setup]
    CB012810_case_setup
    ...                    online_ModifySCF=True
    ...                    Modify_Para_Online=${Online_Modify_BIWK2015}
    UE_and_PA_prepare    gnb_cell3_value=${0}
    Comment    actVonr40msProGrant = TRUE
    ${BIWK2015_wireshark_01}    UE attach and make vonr call BIWK2015    filename=${BIWK2015_wireshark_true}
    Comment    actVonr40msProGrant = FALSE
    Common Case TestLine Setup     ModifySCF_Aftercommission=True
    ...                            Modify_Para_Online=${BIWK2015_online_false}
    ${BIWK2015_wireshark_02}    UE attach and make vonr call BIWK2015    filename=${BIWK2015_wireshark_false}
    BIWK2015_log_check    BIWK2015_wireshark_01=${BIWK2015_wireshark_01}    BIWK2015_wireshark_02=${BIWK2015_wireshark_02}
    [Teardown]     Run keywords
    ...    BIWK2015_case_recovery
    ...    AND    CB012810_case_teardown




