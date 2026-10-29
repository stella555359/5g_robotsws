*** Settings ***
Documentation
...  author: Jakub Migdalek
...  contact: jakub.migdalek@nokia.com
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/FGCR-8741/resources/keywords_fgcr.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC001348/resources/resources.robot


*** Variables ***
${resource_path_FGCR-8741}    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/FGCR-8741/resources/
${SCF_5MHz}             scf_FGCR-8741_5MHz.xml
${SCF_15MHz}            scf_FGCR-8741_15MHz.xml
${tput_DL_bandwith}     35Mbits/sec
${tput_UL_bandwith}     15MBits/sec
${tput_deviation}       10%
${tput_duration}        450s
${Packet_Size}          1200
@{lines_gNB_157_AHCA_1}        1   2   3   4
@{lines_gNB_157_AHCA_2}        5   6   7   8
@{lines_gNB_157_AHCA_3}        9   10   11   12
@{lines_LTE_157}
${start_cnt}            1
${stop_cnt}             45



*** Keywords ***
[1]FGCR-8741_SA_FDD_5MHz_One_UE_Attach_In_Good_Radio_Conditions_UL_Traffic_MPR_Enabled
    [Documentation]  This FGCR checks if UL link adaptation is properly managed by 5GNB when radio
	...    conditions are progressively degraded from good (near cell) to bad (edge cell), with a particular
	...    focus on cell edge as ATB (Adaptive Transmission Bandwidth) is enabled where MPR is enabled or disabled.
    Load scf for NR    ${resource_path_FGCR-8741}    FGCR-8741_SCFs    scf_FGCR-8741_5MHz.xml
    Set attenuation and check  lines=${lines_gNB_157_AHCA_1}   value=0
    Set attenuation and check  lines=${lines_gNB_157_AHCA_2}   value=90
    Set attenuation and check  lines=${lines_gNB_157_AHCA_3}   value=90
    Log to console  Attenuate set as 0
    sleep  5s
    Attach UE SA For test
    Log to console  UE Attach
	Log to console  Gathering L1L2 log
	Starting UL UDP SA  70MBits/sec    200s
	Log to console  Starting Uplink
    Start L1L2 Logs  100  150
    Log to console  Gathering L1L2 log
    Decreasing Radio Conditions
    Log to console  Decreasing radio conditions
    Stop L1L2 Logs And Download PCAP
	Log to console  Downloading L1L2 log
    Check Amount Of PRBs For Specific MCS For One UE
    Log to console  Checking PRBs for specific MCS



[1]FGCR-8741_SA_FDD_15MHz_Two_UE_Attach_In_Good_Radio_Conditions_UL_Traffic_MPR_Enabled
     [Documentation]  This FGCR checks if UL link adaptation is properly managed by 5GNB when radio
 	...    conditions are progressively degraded from good (near cell) to bad (edge cell), with a particular
 	...    focus on cell edge as ATB (Adaptive Transmission Bandwidth) is enabled where MPR is enabled or disabled.
    Run Keyword And Ignore Error  Check adb devices
    Load scf for NR    ${resource_path_FGCR-8741}    FGCR-8741_SCFs    scf_FGCR-8741_15MHz.xml
    Set attenuation and check  lines=${lines_gNB_157_AHCA_1}   value=0
    Set attenuation and check  lines=${lines_gNB_157_AHCA_2}   value=90
    Set attenuation and check  lines=${lines_gNB_157_AHCA_3}   value=90
    Log to console  Attenuate set as 0
    sleep  5s
    Set AT command to MTK   SA
    Attach UE SA For test
    Log to console  SA_1 UE Attach
    Attach UE SA_NSA For test
    Start L1L2 Logs  100  150
    Log to console  Gathering L1L2 log
    Log to console  SA_2 UE Attach
    Starting UL UDP SA  10MBits/sec    200s
    Log to console  Uplink for SA_1
    Starting UL UDP SA_NSA  10MBits/sec    200s
    Log to console  Uplink for SA_2
    Decreasing Radio Conditions
    Log to console  Decreasing radio conditions
    Stop L1L2 Logs And Download PCAP
	Log to console  Downloading L1L2 log
    Check Amount Of PRBs For Specific MCS For Two UEs
    Log to console  Checking PRBs for specific MCS
