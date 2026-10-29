*** Settings ***
Documentation
...    copyright: Nokia
...    maintainer: Wojciech Szczesniak (wojciech.szczesniak@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO
...    variant: SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC

Library      CB008249_keywords.py
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/CB008249/CB008249_keywords.robot

*** Variables ***
${input_file1_1070}=             ${OUTPUT_DIR}/BIP_L1L2_1.pcap
${input_file2_1070}=             ${OUTPUT_DIR}/BIP_L1L2_2.pcap
${input_file3_1070}=             ${OUTPUT_DIR}/BIP_L1L2_3.pcap

${filter_1070}=                  uldata_srsreceivereq

${dir_path1_1070}=               ${OUTPUT_DIR}/BIP_log_1.pdml
${dir_path2_1070}=               ${OUTPUT_DIR}/BIP_log_2.pdml
${dir_path3_1070}=               ${OUTPUT_DIR}/BIP_log_3.pdml

${bip_file1_1070}=               BIP_L1L2_1.pcap
${bip_file2_1070}=               BIP_L1L2_2.pcap
${bip_file3_1070}=               BIP_L1L2_3.pcap
${alias}=                        L1L2_BIP_Logs
${dir_path}=                     ${OUTPUT_DIR}
${delay}=                        0

${NOISE_POWER_FOR_RI_1070}=      SEPARATOR=
...                              -63,-65,-67,-69,-71,-73,-75,-79,-81,-83,-85,-87,-89,-93,-95,-98,-101,-104,
...                              -105,-99,-95,-90,-85,-80,-75,-71,-67,-64,-60,-55,-50,-47

${RRC_POWER_RAMPING_STEP}=   ${SIB1} && nr-rrc.powerRampingStep == 1
${RRC_POWER_RAMPING_STEP_AFTER_RI}=  ${SIB1} && nr-rrc.powerRampingStep == 2

*** Keywords ***
CB008249-C_C1_Remote_interference_mitigation_actions_eCPRI_5GC001070_GP2_SA
    Set Internal Traffic Type To UE
    Set SRS Beam Config    ue_id_1=1      ue_id_2=4
    Attach SA UE And Verify msg2TPC     ue_id=1      msg2TPC_value=3
    Verify PowerRampingStep Configuration       filter=${RRC_POWER_RAMPING_STEP}
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Attach SA UE And Verify msg2TPC     ue_id=4      msg2TPC_value=3
    Establish Pdu Session    ue_id=4    pdu_id=4    gw_id=1
    Airphone override to rank2
    Start Double Data Traffic In DL And Single In UL   ue_id=1    pdu=1   tput_dl=150   tput_ul=50
    Start Double Data Traffic In DL And Single In UL   ue_id=4    pdu=4   tput_dl=150   tput_ul=10
    Verify Tput For UE    ue_id=1   dir=ul    expected_tput=30
    Verify Tput For UE    ue_id=1   dir=dl    expected_tput=280
    Verify Tput For UE    ue_id=4   dir=ul    expected_tput=9
    Verify Tput For UE    ue_id=4   dir=dl    expected_tput=280
    Collect TTI Traces And Check DL MU-MIMO And DL SRS-based BF   duration=6   directory_name=CB008249_1    ini_path=tti_dl_features_enabled.ini
    Start Gathering BIP Logs And Wait 5s
    Stop gnbMirroring And Gather L1L2 Bip Logs C    ${alias}    ${dir_path}    ${delay}    ${bip_file1_1070}
    Convert pcap file to pdml    ${input_file1_1070}    ${filter_1070}    ${dir_path1_1070}
    Check If UL SRS-based BF Is Enabled     file=BIP_log_1.pdml
    Sleep   10s
    Verify If Admin Fault Is Down     fault_id=7525
    Generate RI    ${NOISE_POWER_FOR_RI_1070}
    Wait For Fault To Be Up     fault_id=7525   timeout=800
    Collect TTI Traces And Check DL MU-MIMO And DL SRS-based BF   duration=6   directory_name=CB008249_2    ini_path=tti_dl_features_disabled.ini
    Start Gathering BIP Logs And Wait 5s
    Stop gnbMirroring And Gather L1L2 Bip Logs C    ${alias}    ${dir_path}    ${delay}    ${bip_file2_1070}
    Convert pcap file to pdml    ${input_file2_1070}    ${filter_1070}    ${dir_path2_1070}
    Check If UL SRS-based BF Is Disabled     file=BIP_log_2.pdml
    Attach SA UE And Verify msg2TPC     ue_id=2      msg2TPC_value=6
    Verify PowerRampingStep Configuration       filter=${RRC_POWER_RAMPING_STEP_AFTER_RI}
    Cancel RI
    Wait For Fault To Be Down     fault_id=7525   timeout=600
    Collect TTI Traces And Check DL MU-MIMO And DL SRS-based BF   duration=6   directory_name=CB008249_3    ini_path=tti_dl_features_enabled.ini
    Start Gathering BIP Logs And Wait 5s
    Stop gnbMirroring And Gather L1L2 Bip Logs C    ${alias}    ${dir_path}    ${delay}    ${bip_file3_1070}
    Convert pcap file to pdml    ${input_file3_1070}    ${filter_1070}    ${dir_path3_1070}
    Check If UL SRS-based BF Is Enabled     file=BIP_log_3.pdml
    Attach SA UE And Verify msg2TPC     ue_id=3      msg2TPC_value=3
    Verify PowerRampingStep Configuration       filter=${RRC_POWER_RAMPING_STEP}
    [Teardown]    Stop All Data Transfers And Detach UE SA
