*** Settings ***

Documentation
...   author: Karol Palac & Jakub Migdalek & Kacper Bukowiec
...   contact: karol.palac@nokia.com & jakub.migdalek@nokia.com & kacper.bukowiec@nokia.com
...   Description: Test case verifies presence or lack of CSI reports in PRACH slots depending on DSS being enabled
...                or disabled.
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC001348/resources/resources.robot
Resource        testsuite/Wroclaw/RRM/resources/logs.robot

*** Variables ***
${resource_path_1348-B}    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC001348/resources
${SCF_5MHz}              scf_1348_5MHz.xml

*** Keywords ***

[1]5GC001348_B_9_5GC001348_B_NSA_Uplink_Channel_Multeplixing_Activated_1_Ue_PUCCH_Check_Ack_Nack_Cell_BW_20M
    logs.Upload GnbMirroring Script To ASIK
    Require Ue    UE_3    capabilities=REAL_ANDROID_UE_SA_NSA
    ${stream}  Get stream name
    ${tlname}  Get TL hostname
    Commission with scf file  ${resource_path_1348-B}/SCFs/${tlname}/${stream}_20MHz.xml  is_pdl_checking_needed=${True}
    Wait until keyword succeeds    20 min    1 min    Verify all cells are onair with admin
    Wait until keyword succeeds    10 min    1 min      X2-C is available
    Run Keyword And Ignore Error   Detach Ue    UE_3
    Attach UE SA_NSA for test
    Start L1L2 Logs         200    200
    Log to console          >L1L2 logs collection and throughput has begun.<
    Start ULDL UDP SA_NSA   200Mbits/sec   200MBits/sec   40s
    Sleep                   40s
    Stop L1L2 Logs And Download PCAP    30    SA_NSA   ASIK    dir=${OUTPUT DIR}/PCAPs/1348-B_9.pcap
    Run Keyword And Ignore Error   Detach Ue    UE_3
    Log to Console    >Logs have been collected. UE is detached.<
    Check L1L2 harqd    dir=${OUTPUT DIR}/PCAPs/1348-B_9.pcap


[1]5GC001348_B_23_5GC001348_B_NSA_Uplink_Channel_Multeplixing_Activated_DSS_ON_1_Ue_Check_CQI_In_PUCCH_CSI_Report_Cell_BW_15M
    ${tl_hostname}=  Get TL hostname
    Run keyword if   '${tl_hostname}'=='7-16-UTE5GCLOUDT153'
    ...              Set attenuation and check  lines=${lines_gNB_153_AHLOA_1}   value=90
    Run keyword if   '${tl_hostname}'=='7-16-UTE5GCLOUDT153'
    ...              Set attenuation and check  lines=${lines_gNB_153_AHLOA_2}   value=0
    Run keyword if   '${tl_hostname}'=='7-16-UTE5GCLOUDT153'
    ...              Set attenuation and check  lines=${lines_gNB_153_AHLOA_3}   value=90
    Run keyword if   '${tl_hostname}'=='7-16-UTE5GCLOUDT186'
    ...              Set attenuation and check  lines=${lines_gNB_186_AHLOA_1}   value=0
    Run keyword if   '${tl_hostname}'=='7-16-UTE5GCLOUDT186'
    ...              Set attenuation and check  lines=${lines_gNB_186_AHLOA_2}   value=90
    Run keyword if   '${tl_hostname}'=='7-16-UTE5GCLOUDT186'
    ...              Set attenuation and check  lines=${lines_gNB_186_AHLOA_3}   value=90
    Replace swconfig    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC001348/resources/swconfig.txt
    ...    /ffs/run/swconfig.txt
    ${stream}  Get stream name
    Run Keyword And Ignore Error  Check adb devices
    resources.Load scf for LTE   ${resource_path_1348-B}    SCFs    scf_LTE_1348-B_23_${stream}_DSSon.xml
    Load scf for NR    ${resource_path_1348-B}    SCFs    scf_NR_1348-B_23_${stream}_DSSon.xml
    Wait until keyword succeeds    20 min    1 min    Verify all cells are onair with admin
    Wait until keyword succeeds    10 min    1 min      X2-C is available
#    Require Ue    UE_2    capabilities=REAL_ANDROID_UE_SA
    Require Ue    UE_3    capabilities=REAL_ANDROID_UE_SA_NSA
    Attach UE NSA for test
    Attach UE SA for test
    Attach UE SA_NSA for test
    Start ULDL UDP SA       10Mbits/sec   150MBits/sec   300s
    Start ULDL UDP NSA      10Mbits/sec   150MBits/sec   300s
    Start ULDL UDP SA_NSA   10Mbits/sec   150MBits/sec   300s
    Start L1L2 Logs         100    150
    Log to console          >L1L2 logs collection and throughput has begun.<
    Sleep                   15s
    Stop L1L2 Logs And Download PCAP    30    NSA   ASIK    dir=${OUTPUT DIR}/PCAPs/1348-B_23-DSSon.pcap
    Detach Ue    UE_1
    Detach Ue    UE_2
    Detach Ue    UE_3
    Log to Console    >Logs have been collected. UEs are detached.<
    Verify CSI reports    dir=${OUTPUT DIR}/PCAPs/1348-B_23-DSSon.pcap    presence=false

[1]5GC001348_B_NSA_Uplink_Channel_Multeplixing_Activated_DSS_OFF_1_Ue_Check_CQI_In_PUCCH_CSI_Report_Cell_BW_15M
    ${tl_hostname}=  Get TL hostname
    Run keyword if   '${tl_hostname}'=='7-16-UTE5GCLOUDT153'
    ...              Set attenuation and check  lines=${lines_gNB_153_AHLOA_1}   value=90
    Run keyword if   '${tl_hostname}'=='7-16-UTE5GCLOUDT153'
    ...              Set attenuation and check  lines=${lines_gNB_153_AHLOA_2}   value=0
    Run keyword if   '${tl_hostname}'=='7-16-UTE5GCLOUDT153'
    ...              Set attenuation and check  lines=${lines_gNB_153_AHLOA_3}   value=90
    Run keyword if   '${tl_hostname}'=='7-16-UTE5GCLOUDT186'
    ...              Set attenuation and check  lines=${lines_gNB_186_AHLOA_1}   value=0
    Run keyword if   '${tl_hostname}'=='7-16-UTE5GCLOUDT186'
    ...              Set attenuation and check  lines=${lines_gNB_186_AHLOA_2}   value=90
    Run keyword if   '${tl_hostname}'=='7-16-UTE5GCLOUDT186'
    ...              Set attenuation and check  lines=${lines_gNB_186_AHLOA_3}   value=90
    Replace swconfig    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC001348/resources/swconfig.txt
    ...    /ffs/run/swconfig.txt
    ${stream}  Get stream name
    resources.Load scf for LTE   ${resource_path_1348-B}    SCFs    scf_LTE_1348-B_23_${stream}_noDSS.xml
    Load scf for NR    ${resource_path_1348-B}    SCFs    scf_NR_1348-B_23_${stream}_noDSS.xml
    Wait until keyword succeeds    20 min    1 min    Verify all cells are onair with admin
    Wait until keyword succeeds    10 min    1 min      X2-C is available
#    Require Ue    UE_2    capabilities=REAL_ANDROID_UE_SA
    Require Ue    UE_3    capabilities=REAL_ANDROID_UE_SA_NSA
    Attach UE NSA for test
    Attach UE SA for test
    Attach UE SA_NSA for test
    Log to console          >L1L2 logs collection and throughput has begun.<
    Start ULDL UDP SA       5Mbits/sec   150MBits/sec   300s
    Start ULDL UDP NSA      5Mbits/sec   150MBits/sec   300s
    Start ULDL UDP SA_NSA   5Mbits/sec   150MBits/sec   300s
    Start L1L2 Logs         100    150
    Sleep    15s
    Await Data Transfer Finish    DT_UL_SA
    Stop L1L2 Logs And Download PCAP    35    NSA   ASIK    dir=${OUTPUT DIR}/PCAPs/1348-B-with-noDSS.pcap
    Run Keyword And Ignore Error   Detach Ue    UE_1
    Run Keyword And Ignore Error   Detach Ue    UE_2
    Run Keyword And Ignore Error   Detach Ue    UE_3
    Log to Console        >Logs have been collected. UE is detached.<
    Verify CSI reports    dir=${OUTPUT DIR}/PCAPs/1348-B-with-noDSS.pcap    presence=true

[1]5GC001348_B_11_5GC001348_B_NSA_Uplink_Channel_Multeplixing_Activated_PUSCH_Received_and_decoded_Cell_BW_5M
    [Documentation]  This sub feature is for L1/L2/control plane/ OAM components to enable uplink channel
    ...    multiplexing in long preamble format
    ${stream}  Get stream name
    ${tlname}  Get TL hostname
    logs.Upload GnbMirroring Script To ASIK
    Commission with scf file  ${resource_path_1348-B}/SCFs/${tlname}/${stream}/scf_1348_5MHz.xml  is_pdl_checking_needed=${True}
    #Load scf for NR    ${resource_path_1348-B}    SCFs    scf_1348_5MHz.xml
    Wait until keyword succeeds    20 min    1 min    Verify all cells are onair with admin
    Run Keyword And Ignore Error  Check adb devices
    Attach UE NSA For test
    Start New L1L2 Logs
    Log to console  Gathering L1L2 log
    Start ULDL UDP NSA   50Mbits/sec   30MBits/sec   50s
    Log to console  Downlink and Uplink
    Stop New L1L2 Logs And Download PCAP
	Log to console  Downloading L1L2 log
    Check L1L2 dtx
    Log to console  Checking DTX
    Check L1L2 sfn
    Log to console  Checking SFN


