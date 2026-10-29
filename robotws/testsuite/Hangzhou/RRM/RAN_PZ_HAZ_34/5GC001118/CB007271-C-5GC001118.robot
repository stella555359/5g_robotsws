# *** Settings ***
# Force Tags    PY36     RAN_5G_FDD    SBTS00     CRT_TRUNK      CRT_22R3
# Documentation  Tests for feature 1118 - support of 256QAM in uplink
# 
# Library    OperatingSystem
# Library    ../outsides/resources_1118/attenuator_keywords.py
# Resource   ../outsides/resources_2098/setup_teardown.robot
# Resource   ../outsides/resources_570/logs.robot
# Resource   ./resources/keywords_1118.robot
# Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/bip.robot
# Variables  ./resources/att_port_mapping.py
# 
# 
# 
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# Suite Setup    Run Keywords      Download MCShark If Exist
# ...    AND      Download SCF with connection
# ...    AND     GNB Configuration Setup        ${SCF}
# ...    AND     robot_common_operations.Common Suite Setup
# 
# Suite Teardown   robot_common_operations.Common Suite Teardown
# Test Setup       Run Keywords   Get The SW
# ...  AND       robot_common_operations.Common Case Setup
# Test Teardown    Run Keywords    1118 Test Teardown
# ...  AND      robot_common_operations.Common Case Teardown
# 
# 
# *** Variables ***
# ${256_mcs_max}=  27
# ${256_mcs_min}=  0
# 
# ${64_mcs_max}=  28
# ${64_mcs_min}=  0
# 
# ${256_mod_ord_8_mcs_min}=  20
# ${256_mod_ord_6_mcs_max}=  19
# ${64_mod_ord_6_mcs_min}=  18
# ${SCF}=  CV1910_2Cell_For_CB007271_CRT.xml
# 
# *** Test Cases ***
# [1]CB007271_5G_C_001_256_QAM_for_PUSCH_Feature_Activation_20MHz_Max_UL_t-put_SA
#     [Tags]    1118_1    CRT_22R4
#     [Documentation]   This test case validates the successful activation of the 256QAM modulation scheme in UL
#     ...               and DL and checking max t-puts for 20MHz bandwidth in SA mode. For this purpose, the condition on
#     ...               the air interface shall allow UL transmissions using MCSes related to the 256QAM modulation scheme.
#     Set Ul 256QAM Activation State For All Cells  false
#     Initialise Attenuator
#     attenuator_keywords.Set Attenuation  0dB  confirm=${TRUE}  port=${ATTENUATOR_CELLS[0]['ports']}
#     attenuator_keywords.Set Attenuation  90dB  confirm=${TRUE}  port=${ATTENUATOR_CELLS[1]['ports']}
#     Set actUlDftSOfdm Activation State For All Cells  false
# 
#     @{UE_NAMES}=  Create list  UE_1  UE_2
#     Set Test Variable  ${UE_NAMES}
#     Samsung UE Attach  UE_1  nr_only=${TRUE}
#     Set actUlDftSOfdm Activation State For All Cells  false
# 
#     256_QAM_for_PUSCH_Feature_Activation_20MHz_Max_DL_and_UL_t-put  nr_only=${TRUE}
# 
# [1]CB007271_5G_C_003_256_QAM_for_PUSCH_Feature_Activated_Handover_64QAM_256QAM_20MHz_SA
#     [Tags]    1118_3    CRT_22R4
#     [Documentation]   This test case describes handover behavior between 2 cells, which supports UL 256QAM for 20MHz
#     ...               bandwidth in SA mode. UE starts UL traffic with 1st cell and by simulation bad cell conditions
#     ...               (programmable attenuator) switching to 2nd cell.
#     Initialise Attenuator
#     attenuator_keywords.Set Attenuation   0dB   confirm=${TRUE}  port=${ATTENUATOR_CELLS[0]['ports']}
#     attenuator_keywords.Set Attenuation   20dB  confirm=${TRUE}  port=${ATTENUATOR_CELLS[1]['ports']}
#     Set Ul 256QAM Activation State For All Cells  true
#     Set actUlDftSOfdm Activation State For All Cells  false
# 
#     @{UE_NAMES}=  Create list  UE_1
#     Set Test Variable  ${UE_NAMES}
#     Attach UEs  nr_only=${TRUE}
# 
#     Start Tracing On SMOD
#     keywords_1118.Start Traffic  DT_UL_1  UE_1  ul  tcp  200
# 
#     Log To Console  Performing handover...
# 
#     Perform Handover  initial_port=${ATTENUATOR_CELLS[0]['ports']}
#     ...               target_port=${ATTENUATOR_CELLS[1]['ports']}
#     ...               open_value=0
#     ...               closed_value=40
#     ...               period=20
#     ...               interval=2
# 
#     Log To Console  Handover done.
# 
#     ue.Check Data Transfer Is Alive  DT_UL_1
#     ue.Stop Data Transfers For All UEs
# 
#     ${filename_path}=    Stop tracing and download logs from SMOD
# 
#     Verify Handover    ${filename_path}  ${ATTENUATOR_CELLS[0]['id']}  ${ATTENUATOR_CELLS[1]['id']}
# 
#     [Teardown]  1118 Test Teardown
# 
# [1]CB007271_5G_C_005_256_QAM_for_Transform_Precoder_activation_256QAM_SA_UE
#     [Tags]    1118_5    CRT_22R4
#     Set Ul 256QAM Activation State For All Cells  true
#     Set actUlDftSOfdm Activation State For All Cells  true
#     Initialise Attenuator
#     attenuator_keywords.Set Attenuation  0dB  confirm=${TRUE}
# 
#     #Set Trans Precode For All Cells  sinr_off=20    sinr_on=18
# 
#     ${result}    ${release}    Run Keyword And Ignore Error
#     ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
#     ${release_sbts}    Replace String    string=${release}    search_for=5G    replace_with=SBTS
#     Run keyword If  '${release_sbts}'=='SBTS23R2'
#     ...     Set Trans Precode For All Cells 23R2  sinr_off=20    sinr_on=18
#     ...    ELSE       Set Trans Precode For All Cells  sinr_off=20    sinr_on=18
# 
# 
#     Start Tracing On SMOD
# 
#     @{UE_NAMES}=  Create list  UE_1
#     Set Test Variable  ${UE_NAMES}
#     Attach UEs  nr_only=${TRUE}
# 
#     keywords_1118.Start Traffic  DT_UL_1  UE_1  ul  tcp  200
#     Sleep  1  reason=Wait for log collection
#     #attenuator_keywords.Set Attenuation  47dB  confirm=${TRUE}
#     attenuator_keywords.Set Attenuation  40dB  confirm=${TRUE}
#     Sleep  2  reason=Wait for log collection
#     attenuator_keywords.Set Attenuation  0dB  confirm=${TRUE}
#     Sleep  5  reason=Wait for log collection
# 
#     ue.Check Data Transfer Is Alive  DT_UL_1
#     ue.Stop Data Transfers For All UEs
# 
#     ${filename_path}=    Stop tracing and download logs from SMOD
#     Verify Transform Precoder Activation  ${filename_path}
# 
# 
# [1]CB007271_5G_C_002_256_QAM_for_PUSCH_Feature_Activation_20MHz_Max_UL_t-put_NSA
#     [Tags]    1118_2
#     [Documentation]   This test case validates the successful activation of the 256QAM modulation scheme in UL
#     ...               and DL and checking max t-puts for 20MHz bandwidth in SA mode. For this purpose, the condition on
#     ...               the air interface shall allow UL transmissions using MCSes related to the 256QAM modulation scheme.
#     Set Servedamf State  Locked
#     Set Ul 256QAM Activation State For All Cells  false
#     Initialise Attenuator
#     attenuator_keywords.Set Attenuation  0dB  confirm=${TRUE}  port=${ATTENUATOR_CELLS[1]['ports']}
#     attenuator_keywords.Set Attenuation  90dB  confirm=${TRUE}  port=${ATTENUATOR_CELLS[0]['ports']}
#     Set actUlDftSOfdm Activation State For All Cells  false
# 
#     @{UE_NAMES}=  Create List  UE_1  UE_2
#     Set Test Variable  ${UE_NAMES}
#     Samsung UE Attach  UE_1
# 
#     256_QAM_for_PUSCH_Feature_Activation_20MHz_Max_DL_and_UL_t-put
# 
# 
# 
# *** Keywords ***
# Download Luashark File    
#     [Documentation]                    Download luashark file
#     Get The SW
#     Run    sudo rm -rf /home/ute/luashark
#     OperatingSystem.Create Directory    /home/ute/luashark
#     OperatingSystem.List Files In Directory    /home/ute    *luashark*
#     OperatingSystem.Remove Files    /home/ute/*luashark.zip*
#     OperatingSystem.Remove Files    /home/ute/luashark*.zip*
#     OperatingSystem.List Files In Directory    /home/ute    *luashark* 
#     ${files}    get_file_for_Load    ${SW_Version}     
#     Run Keyword Unless    'No' in '${files}'    unzip_file    ${files}
#     OperatingSystem.Directory Should Not Be Empty      /home/ute/luashark/generated_luashark
# 
# Download MCShark If Exist
#     ${sw_version}    Get MCShark Version
#     run     curl https://artifactory-hz1.int.net.nokia.com/artifactory/mcshark-local/${sw_version}/ -o /tmp/output.html
#     ${result}    run     cat /tmp/output.html|grep mcshark-.*-${sw_version}+buster.so|wc -l
#     ${mcshark_status}    Evaluate     ${result.replace('\n','').strip()}!=0
#     Run Keyword If    ${mcshark_status}==${True}      Download MCShark To UTE
#     ...    ELSE    log to console   mcshark version ${sw_version} not exist, use old mcshark.
