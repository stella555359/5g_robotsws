# *** Settings ***
# 
# Documentation
# ...   author: y6lu
# ...   contact: lu.yu@nokia-sbell.com
# ...   squad group: MMW_SG3
# ...   Feature CB007199 in 5G22R3 program
# 
# Force Tags    CRT_TRUNK    CRT_22R3
# 
# Suite Setup
# Suite Teardown
# Test Timeout
# 
# Resource    Resources/CB007199_common_keyword.robot
# 
# 
# *** Variables ***
# ${bip_filter}    /usr/bin/tshark -r {pcap_file} -Y \"dldata_pdschsendreq\" -T pdml
# 
# ${MRBTS_ID}    ${tl.gnbs[0].instance_id}
# ${dist}    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
# *** Test Cases ***
# [1]CB007199-D_5GC002200-F_01_max_DL_Tput_with_4_resources_and_beamset_4
#     [Documentation]    *****************
#     ...    This test case is to verify 64TRX(4*8*2) or 32TRX（2*8*2） RU can do DL data transfer successfully when 2200
#     ...    feature enable with 4 CSI-RS resource configuration. DL tput can achieve to peak throughput and compare with
#     ...    DL tput when 1856 enabled, There should be no downgrade for the cell throughput with the same radio condition
#     ...    (good radio condition). It can be no need be better(better will be good), but it should be commit no aggravate.
#     ...    *******************
#     [Tags]
#     [Setup]    Preconditions
#     [Teardown]    run keyword and ignore error   disconnect interactive connection  alias=${alias}
#     ##Step 1: L3 Call Check On Feature 1856
#     Step 2: Check 4Resources Activated
#     Step 3: L3 Call Check On Feature 2200
#     Step 4: Capture Logs And Check
# 
#     ### For BIP Log ##
#     #Start L1L2 Bip Log Capture
#     #Stop L1L2 Bip Log Capture
#     #${BIP_value}=    Get values from BIP Log    bip_filter=${bip_filter}
#     ###For TTI Trace ##
#     #Start TTI Trace Capture
#     #Sleep    120s
#     #Stop TTI Trace Capture
# 
# 
# 
# 
# *** Keywords ***
# Step 1: L3 Call Check On Feature 1856
#     Make UE Attach
#     ${Tput_1856}    Start traffic and check result    tp_direction=dl
#     Set Test Variable    ${Tput_1856}
#     Make UE Detach
# 
# Step 2: Check 4Resources Activated
#     vDU Login
#     &{modify_parameter_dict}    Create Dictionary
#     ${ssPbchBlockPower}=    Online Get VDU Parameter Value    ${dist}    ssPbchBlockPower
#     ${csiRsPower}=    Evaluate    ${ssPbchBlockPower}+3
#     ${csiRsPower}    Convert To String    ${csiRsPower}
#     &{periodicCsiAcquisition}    Create Dictionary    periodicCsiAcquisition/0/maxCsirsNumber=4
#     ...    periodicCsiAcquisition/0/csirsNumberWithinReportPeriod_Set1=3    periodicCsiAcquisition/0/csirsPower=${csiRsPower}
#     ...    dlMimoMode=8x4 Closed Loop Spatial Multiplexing    beamSet/0/nrBtsBeamRefinementP2=false
#     FOR    ${para_name}    IN    @{periodicCsiAcquisition}
#         ${value}=    Online Get VDU Parameter Value    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1    ${para_name}
#         run keyword if    "${value}" != "${periodicCsiAcquisition}[${para_name}]"
#         ...    Set to Dictionary    ${modify_parameter_dict}    ${para_name}    ${periodicCsiAcquisition}[${para_name}]
#     END
#     Run Keyword If  &{modify_parameter_dict} != &{Empty}    Modify 2200 Parameters
#     ...    dist=${dist}   updated_paras_dict=${modify_parameter_dict}    wait_vdu_up=True
#     [Teardown]    Run Keyword And Ignore Error    vDU Logout
# 
# Step 3: L3 Call Check On Feature 2200
#     ${f1_pcap_file}    Start Capture Wireshark F1 On CU
# 
#     Make UE Attach
#     ${Tput_2200}    Start traffic and check result    tp_direction=dl
#     Set Test Variable    ${Tput_2200}
#     Make UE Detach
#     Stop Capture Wireshark F1 On CU    ${f1_pcap_file}
# 
# Step 4: Capture Logs And Check
#     #should be true    ${Tput_2200}>=${Tput_1856}
#     Check RRC message    resources_num=${4}
# 
# 
