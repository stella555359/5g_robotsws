*** Settings ***
Documentation
...    copyright: Nokia
...    maintainer: Wojciech Szczesniak (wojciech.szczesniak@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO
...    variant: SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC

Library      CB008249_keywords.py
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/CB008249/CB008249_keywords.robot

*** Variables ***
${input_file1_1116}=             ${OUTPUT_DIR}/BIP_L1L2_1.pcap
${input_file2_1116}=             ${OUTPUT_DIR}/BIP_L1L2_2.pcap
${input_file3_1116}=             ${OUTPUT_DIR}/BIP_L1L2_3.pcap

${filter_1116}=                  uldata_srsreceivereq

${dir_path1_1116}=               ${OUTPUT_DIR}/BIP_log_1.pdml
${dir_path2_1116}=               ${OUTPUT_DIR}/BIP_log_2.pdml
${dir_path3_1116}=               ${OUTPUT_DIR}/BIP_log_3.pdml

${bip_file1_1116}=               BIP_L1L2_1.pcap
${bip_file2_1116}=               BIP_L1L2_2.pcap
${bip_file3_1116}=               BIP_L1L2_3.pcap
${alias}=                        L1L2_BIP_Logs
${dir_path}=                     ${OUTPUT_DIR}
${delay}=                        0

${NOISE_POWER_FOR_RI_1116}=     SEPARATOR=
...                             -63,-65,-67,-69,-71,-73,-75,-79,-81,-83,-85,-87,-89,-93,-95,-98,-101,-104,-105,-99,-95,-90,
...                       	-85,-80,-75,-71,-67,-64,-60,-55,-50,-47

${RRC_POWER_RAMPING_STEP}=   nr-rrc.powerRampingStep == 1
${RRC_POWER_RAMPING_STEP_AFTER_RI}=    nr-rrc.powerRampingStep == 3

*** Keywords ***
CB008249-C_C1_Remote_interference_mitigation_actions_eCPRI_5GC001116_GP4_3ms_NSA
    Set Up X2 link
    Set SRS Beam Config    ue_id_1=11      ue_id_2=14
    Attach Ue To Enb And Start Gnb Addition And Verify TPC msg   ue_id=11   target_cells=1    msg2TPC_value=3
    Verify PowerRampingStep Configuration       filter=${RRC_POWER_RAMPING_STEP}
    Attach Ue To Enb And Start Gnb Addition And Verify TPC msg   ue_id=14   target_cells=1    msg2TPC_value=3
    Start Data Traffic In DL And In UL   ue_id=11   tput_dl=150   tput_ul=50
    Start Data Traffic In DL And In UL   ue_id=14   tput_dl=150   tput_ul=10
    Verify Tput For UE NSA    ue_id=11    id=2    dir=ul    unit=M    expected_tput=45
    Verify Tput For UE NSA    ue_id=11    id=2    dir=dl    unit=M    expected_tput=140
    Verify Tput For UE NSA    ue_id=14    id=2    dir=ul    unit=M    expected_tput=9.5
    Verify Tput For UE NSA    ue_id=14    id=2    dir=dl    unit=M    expected_tput=140
    Collect TTI Traces And Check DL MU-MIMO And DL SRS-based BF   duration=6   directory_name=CB008249_1    ini_path=tti_dl_features_enabled.ini
    Start Gathering BIP Logs And Wait 5s
    Stop gnbMirroring And Gather L1L2 Bip Logs C    ${alias}    ${dir_path}    ${delay}    ${bip_file1_1116}
    Convert pcap file to pdml    ${input_file1_1116}    ${filter_1116}    ${dir_path1_1116}
    Check If UL SRS-based BF Is Enabled     file=BIP_log_1.pdml
    Sleep    10s
    Verify If Admin Fault Is Down     fault_id=7525
    Generate RI    ${NOISE_POWER_FOR_RI_1116}
    Wait For Fault To Be Up     fault_id=7525   timeout=800
    Collect TTI Traces And Check DL MU-MIMO And DL SRS-based BF   duration=6   directory_name=CB008249_2    ini_path=tti_dl_features_disabled.ini
    Start Gathering BIP Logs And Wait 5s
    Stop gnbMirroring And Gather L1L2 Bip Logs C    ${alias}    ${dir_path}    ${delay}    ${bip_file2_1116}
    Convert pcap file to pdml    ${input_file2_1116}    ${filter_1116}    ${dir_path2_1116}
    Check If UL SRS-based BF Is Disabled     file=BIP_log_2.pdml
    Attach Ue To Enb And Start Gnb Addition And Verify TPC msg   ue_id=12   target_cells=1      msg2TPC_value=4
    Verify PowerRampingStep Configuration       filter=${RRC_POWER_RAMPING_STEP_AFTER_RI}
    Cancel RI
    Wait For Fault To Be Down     fault_id=7525   timeout=600
    Collect TTI Traces And Check DL MU-MIMO And DL SRS-based BF   duration=6   directory_name=CB008249_3    ini_path=tti_dl_features_enabled.ini
    Start Gathering BIP Logs And Wait 5s
    Stop gnbMirroring And Gather L1L2 Bip Logs C    ${alias}    ${dir_path}    ${delay}    ${bip_file3_1116}
    Convert pcap file to pdml    ${input_file3_1116}    ${filter_1116}    ${dir_path3_1116}
    Check If UL SRS-based BF Is Enabled     file=BIP_log_3.pdml
    Attach Ue To Enb And Start Gnb Addition And Verify TPC msg   ue_id=13   target_cells=1      msg2TPC_value=3
    Verify PowerRampingStep Configuration       filter=${RRC_POWER_RAMPING_STEP}
    [Teardown]    Stop All Data Transfers And Detach UE NSA
