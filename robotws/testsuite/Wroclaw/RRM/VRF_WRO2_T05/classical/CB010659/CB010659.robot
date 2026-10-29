*** Settings ***
Documentation
...  author: Kamil Kluz
...  contact: kamil.kluz@nokia.com
...  Description: This user scenario describes the successful addition of a new DRB in the ext-gNB for a UE context
...               already in IgNB-CA mode

Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002015/resources/keywords_2015.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002534/resources/keywords_2534.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC001348/resources/resources.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB010659/keywords.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008662/resources/keywords.robot
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_kw.py
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008662/resources/keywords_8662.py
Library      taf.rfrl.bts.devices.du.alarm_verification.GnbAlarmVerification    WITH NAME    alarm_verification
Variables    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002534/resources/variables.py

*** Variables ***
${resource_path_10659}    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB010659


*** Keywords ***
[1][1.0] TC[1]_CB010659-A_B1_Enabling_adaptive_retransmission_in_UL_on_ABIL_Activation_Deactivation_FDD_64qam_SA
    #Run Keyword And Ignore Error  Check adb devices
    #Load scf for NR   ${resource_path_10659}    SCFs    scf_10659_64QAM.xml
    #Prepare and check TL
    Load scf for NR   ${resource_path_10659}    SCFs    scf_10659_64QAM.xml
    Set attenuation and check  lines=@{lines_gNB_153_AHLOA_1}     value=0
    Attach UE SA_NSA for test
    Start Data Transfer    dt_name=DT_DL_SA_NSA   ue_alias=UE_3  direction=dl    duration=300s    throughput=50Mbits/sec
    ...                    protocol=tcp
    Start Data Transfer    dt_name=DT_UL_SA_NSA   ue_alias=UE_3  direction=ul    duration=300s    throughput=50Mbits/sec
    ...                    protocol=tcp
    Start New L1L2 Logs
    Decrease radio conditions AHLOA
    Cell lock 10659
    Sleep  20s
    Cell unlock 10659
    Increase radio conditions AHLOA
    Sleep   30s
    Run keyword and ignore error   Detach Ue   UE_3
    Stop New L1L2 Logs And Download PCAP    dir=${OUTPUT DIR}/PCAPs/${TEST NAME}.pcap
    Verify reserved MCS for uplink
    Verify PM counters 10659

[1]TC[4]_CB010659-A_B1_Enabling_adaptive_retransmission_in_UL_on_ABIL_Activation_Deactivation_TDD_256qam_SA
    #Load scf for NR   ${resource_path_10659}    SCFs    scf_10659_B1.xml
    #Prepare and check TL
    Load scf for NR   ${resource_path_10659}    SCFs    scf_10659_B1.xml
    Test case scenario   cell_lock=False

[1]TC[7]_CB010659-A_B2_Interworking_with_Adaptive_UL_BLER_for_spectral_efficiency_improvement_TDD_256qam_SA_CutOffMcs
    #Load scf for NR   ${resource_path_10659}    SCFs    scf_10659_B2.xml
    #Prepare and check TL
    Load scf for NR   ${resource_path_10659}    SCFs    scf_10659_B2.xml    verify_cells_on_air=False
    Update Software If Necessary
    Test case scenario   cell_lock=False

[1]TC[9]_CB010659-A_B3_Interworking_with_CB009198_DFT-s-OFDM_for_PUSCH-FR1_TDD_ABIL_TDD_64qam_NSA_CutOffMcs
    #Load scf for NR   ${resource_path_10659}    SCFs    scf_10659_B3.xml
    #Prepare and check TL
    Load scf for NR   ${resource_path_10659}    SCFs    scf_10659_B3.xml    verify_cells_on_air=False
    Update Software If Necessary
    Test case scenario   cell_lock=False

[1][2.0] TC[10]_CB010659-A_B4_Interworking_with_CB006137_Inter_band_FDD+TDD_FR1_UL_CA_2CCs_FDD_256qam_SA
    #Load scf for NR   ${resource_path_10659}    SCFs    scf_10659_B4.xml
    #Prepare and check TL
    Load scf for NR   ${resource_path_10659}    SCFs    scf_10659_B4.xml    verify_cells_on_air=False
    Update Software If Necessary
    Set attenuation and check  lines=@{lines_gNB_153_AHLOA_3}     value=0
    Set attenuation and check  lines=@{lines_gNB_153_AHLOA_1}     value=0
    Attach UE SA for test
    Start ULDL UDP SA    200Mbits/sec   50MBits/sec
    Start New L1L2 Logs
    Decrease radio conditions AHLOA
    Sleep  20s
    Increase radio conditions AHLOA
    Sleep   30s
    Stop Data Transfer    DT_DL_SA
    Stop Data Transfer    DT_UL_SA
    Run keyword and ignore error   Detach Ue   UE_2
    Stop New L1L2 Logs And Download PCAP    dir=${OUTPUT DIR}/PCAPs/${TEST NAME}.pcap
    Verify reserved MCS for uplink
