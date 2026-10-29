*** Settings ***
Documentation    ...
#Resource    ./CB006137_resource.robot
#Resource    ./../CUDU_L2/common_setup_teardown.robot
#Suite Setup    Common Suite Setup
#Test Teardown    Common Test Teardown 2
#Suite Teardown    Common Suite Teardown 2
#Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    SBTS00    SBTS23R1    CN1_SG09_SM2
#...                RAN_5G    RAN_5G_TDD    CRT
#
#*** Variables ***
#${UE_ID}               1
#${PROFILE_ID}          1
#${GNB_ID}              2
#${CELL_ID}             1
#${BEARER_ID}           2
#${Egatelog_path}          ${CURDIR}
#${LOCAL_IPHY_DIR}         ${CURDIR}/config
#${SCF_DIR}                ${CURDIR}/config
#${6137_CB6_COMMON_SCF}    ${SCF_DIR}/SCF_C_B6_5cell.xml
#${6137_CB6_PC2a_SCF}      SCF_C_B6_5cell_PC2a.xml
#${SCF_6137_CB6_PC2b_2502}    SCF_C_B6_5cell_PC2b_2502.xml
#${6137_CB6_2503_SCF}    SCF_C_B6_2503.xml
#${WTS_CFG_CB6_2503}          wts_config_ASIB_ABIO_FDD_CPRI_cmwv_SANSA_4CC_6UE_2503.cfg
#${WTS_CFG_CB6_PC3}           wts_config_ASIB_ABIO_FDD_CPRI_cmwv_SANSA_4CC_6UE_PC3.cfg
#${WTS_CFG_CB6_PC2a}          wts_config_ASIB_ABIO_FDD_CPRI_cmwv_SANSA_4CC_6UE_PC2a.cfg
#${WTS_CFG_CB6_PC2b}          wts_config_ASIB_ABIO_FDD_CPRI_cmwv_SANSA_4CC_6UE_PC2b.cfg
#${IPHY}                      iphy_2T3F.xml
#${gnb_swconfig}              /home/ute/testline_init_results/configs/sm_swconfig.txt
#${4CC_SCELLS}                ('1', '50', '71'), ('2', '60', '77'), ('3', '61', '41')
#${6137_B6_COMMON_RD}         0x58067c=0x1;0x58057F=16;0x58057a=3;0x58023f=3
##0x58057F rdFeatureFlagBitmap4; bitmap;0 - RIM.COMMON, 1- RIM.RI, 2- RIM.RI_SELECTOR, 3- RIM.RS, 4- UL.INTERBAND_CA.POWER_SPLIT
##0x58057a rdFeatureFlagBitmapLevel; enum;0 - VIP, 1 - ERROR, 2 - WARNING, 3 - INFO, 4 - DEBUG, 5 - INVALID
##0x58067c 6137-C enabling
#
#*** Test Cases ***
#CB006137-ET-C-B2402_Verify_IWK_with_Single_UE_call_setup_for_power_class_2(a)_CA_UE_with_BF_enable
#    [Documentation]
#    ...    Precondition:
#    ...      Open 6137-C RD Flag in gnb Swconfig file
#    ...      TDD FR1 cell with optional sCellAdditionMethod parameter set to 0 (blind)
#    ...      Beamforming is enabled on TDD FR1 cell
#    ...      UE supports power class 2 for the FDD-TDD band combination, power class 3 on FDD band and TDD band
#    ...    The execution order will be:
#    ...      1) UE attach.
#    ...      2) Start DL&UL traffic, make sure the UL flow is in both pcell and scell.
#    ...      3) UE moves close to TDD cell edge.
#    ...    Check Point:
#    ...     1) gNB initiates blind SCell activation and SCell remains active for the duration of RRC connection
#    ...     2) In Ul overlapping slots, UE is scheduled with all available PRBs on both FDD Pcell and TDD Scell
#    ...     3) No dynamic powersplit triggered with PC2a
#    ...     4) UL CA related counters are updated correctly as described
#    [Tags]    caseCIWK2402    Manual_Abby    TA_Abby
#    [Setup]    Run Keywords    Setup TL For B6 Each Case    ${6137_CB6_PC2a_SCF}    ${IPHY}    ${WTS_CFG_CB6_PC2a}
#    ...    AND    Verify Coam Site Is Ready
#    ...    AND    Start GNB AP Syslog    ${TEST_LOG_DIRECTORY}
#    ...    AND    Start UTE WTS And Check Cell Setup    ${WTS_CFG_CB6_PC2a}
#    #Step1: UE Attach
#    Basic Flow For Ue Attach And Pdu Setup
#    #Step2: Start UL/DL Traffic and Check TP
#    Start SA UE Big UL Traffic Internal    ${UE_ID}    mbps=100
#    Start SA UE Big DL Traffic Internal    ${UE_ID}    mbps=350
#    Sleep    10s    reason=Wait for traffic
#    Check DL On Target    ${UE_ID}    0    1-3    200
#    Check UL On Target    ${UE_ID}    0    3    20
#    #Step3: Modify PHR and Collect Ttitrace
#    Start Ttitrace With Streaming Mode
#    Trigger PHR To GNB    profile_id=1    phr_start=5
#    Trigger PHR To GNB    profile_id=2    phr_start=10    cell_id=1
#    Sleep    5s    reason=Wait for Ttitrace Collection
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/initial/
#    #Step4: Check Dynamic Powersplit not Triggered and Related Counters equals to Zero
#    Wait Until Keyword Succeeds    10min    5min    Check PM Counter For CA Related Counters
#    SA 5G Detach    ue_id=${UE_ID}
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/initial/
#    Check DynamicPowerSplit not Start   ${TEST_LOG_DIRECTORY}/initial/
#    #Step5: Check all Available PRBs are Scheduled
#    Check UE Scheduled with all Available PRBs on both FDD and TDD   ${TEST_LOG_DIRECTORY}/initial/
#
#CB006137-ET-C-B2502_Verify_IWK_with_Single_UE_call_setup_for_power_class_2(b)_CA_UE_with_BF_enable
#    [Documentation]
#    ...    Precondition:
#    ...      Open 6137-C RD Flag in gnb Swconfig file
#    ...      TDD FR1 cell with optional sCellAdditionMethod parameter set to 0 (blind)
#    ...      Beamforming is enabled on TDD FR1 cell
#    ...      UE supports power class 2b for the FDD-TDD band combination, power class 3 on FDD band and TDD band
#    ...    Test steps:
#    ...      1) UE attach and start DL&UL traffic, make sure the UL flow is in both pcell and scell.
#    ...      2) Change PHR for Pcell and Scell to trigger overpower state
#    ...      3) Update weightRatioOfUePwrScellVsPcell from WeightRatio 0.01 to WeightRatio 100 on webEM to trigger Pcell suspend
#    ...      4) Recover PHR for Pcell and Scell to trigger Pcell resume
#    ...      5) UE dereigister and check counters
#    ...    Check Points:
#    ...      1) Scell blind add and blind act, traffic on both Pcell and Scell. Initial power split is correct.
#    ...      2) Pcell enters overpower state
#    ...      3) Pcell enters suspend state
#    ...      4) Pcell enters resume state
#    ...      5) UL CA related counters are updated correctly as described
#    [Tags]    caseCIWK2502    Manual_lilidong    TA_lilidong
#    [Setup]    Run Keywords    Setup TL For B6 Each Case    ${SCF_6137_CB6_PC2b_2502}    ${IPHY}    ${WTS_CFG_CB6_PC2b}
#    ...    AND    Verify Coam Site Is Ready
#    ...    AND    Start GNB AP Syslog    ${TEST_LOG_DIRECTORY}
#    ...    AND    Start UTE WTS And Check Cell Setup    ${WTS_CFG_CB6_PC2b}
#    #Step1: UE Attach And Start Traffic With Power Split
#    Online Change One Para With Admin    MRBTS-1/NRBTS-1/NRCELL-3    weightRatioOfUePwrScellVsPcell    WeightRatio 0.01
#    Basic SA Call With Initial Power Split For PC2b
#    Get And Check Scell Infos    ${4CC_SCELLS}
#    Check Initial Power Split Info    syslog1
#    Check DL On Target    ${UE_ID}    0    1-3    300
#    Check UL On Target    ${UE_ID}    0    3    85
#    #Step2: Change PHR To Trigger Overpower State
#    Start Ttitrace With Streaming Mode
#    Trigger PHR To GNB    profile_id=1    phr_start=-5    pc_max=14
#    Trigger PHR To GNB    profile_id=2    phr_start=10    pc_max=26    cell_id=3
#    Sleep    3s    reason=Wait for Ttitrace Collection
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/1
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/1
#    Check UE Enters Overpower State    csv_file_path=${TEST_LOG_DIRECTORY}/ttitrace/1
#    #Step3: Trigger And Check Pcell Suspend
#    Trigger Pcell Suspend By Change WeightRatio100
#    Check Pcell Suspend    csv_file_path=${TEST_LOG_DIRECTORY}/ttitrace/2
#    #Step4: Trigger And Check Pcell Resume
#    Trigger Pcell Resume By Recover PHR
#    Check Initial Power Split After Pcell Resume    syslog3
#    Check DL On Target    ${UE_ID}    0    1-3    300
#    Check UL On Target    ${UE_ID}    0    3    85
#
#
#CB006137-ET-C-B2503_Single_UE_UL_CA_Call_with_dynamic_UL_power_sharing_scell_suspend_resume_for_PC3
#    [Documentation]
#    ...    Precondition:
#    ...      Open 6137-C RD Flag in gnb Swconfig file
#    ...      TDD FR1 cell with optional sCellAdditionMethod parameter set to 0 (blind)
#    ...      Beamforming is enabled on TDD FR1 cell
#    ...      UE supports power class 2 for the FDD-TDD band combination, power class 3 on FDD band and TDD band
#    ...    The execution order will be:
#    ...      1) UE attach.
#    ...      2) Start DL&UL traffic, make sure the UL flow is in both pcell and scell.
#    ...      3) modify PHR, Scell will suspend.
#    ...      4) resume PHR, Scell weill resume.
#    ...    Check Point:
#    ...     1) gNB initiates blind SCell activation and SCell remains active for the duration of RRC connection
#    ...     2) scell UL THP is 0, when scell suspend
#    ...     3) scell UL THP is normal, when scell resume
#    [Tags]    caseCIWK2503    Manual_cora    TA_yuerong
#    [Setup]    Run Keywords    Setup TL For B6 Each Case    ${6137_CB6_2503_SCF}    ${IPHY}    ${WTS_CFG_CB6_2503}
#    ...    AND    Verify Coam Site Is Ready
#    ...    AND    Start GNB AP Syslog    ${TEST_LOG_DIRECTORY}
#    ...    AND    Start UTE WTS And Check Cell Setup    ${WTS_CFG_CB6_2503}
#    #Step1: UE Attach
#    Basic Flow For Ue Attach And Pdu Setup
#    #Step2: Start UL/DL Traffic and Check TP
#    Start SA UE Big UL Traffic Internal    ${UE_ID}    mbps=60
#    Sleep    10s    reason=Wait for traffic
#    Check UL On Target    ${UE_ID}    0    3    20
#    #Step3: Modify PHR and trigger scell suspend
#    ${savepoint1} =  Capture savepoint  alias=${GNB_SYSLOG.alias}
#    Send PHR To GNB    profile_id=1    phr_start=0    cell_id=0    pc_max=23
#    Send PHR To GNB    profile_id=2    phr_start=-6    cell_id=3     pc_max=23
#    Wait for message in syslog file  regexp=scellSuspend  timeout=60  alias=${GNB_SYSLOG.alias}
#    Collect from savepoint  savepoint=${savepoint1}  destination_file=${TEST_LOG_DIRECTORY}/syslog1  alias=${GNB_SYSLOG.alias}
#    Sleep    30s    reason=Wait for process
#    Check Scell UL Decreased    1    3    0
#    ${savepoint2} =  Capture savepoint  alias=${GNB_SYSLOG.alias}
#    #Step4: Modify PHR and trigger scell resume
#    Recover Default PH For Pcell And Scell    scell_id=3
#    Wait for message in syslog file  regexp=scellResume  timeout=60  alias=${GNB_SYSLOG.alias}
#    Collect from savepoint  savepoint=${savepoint2}  destination_file=${TEST_LOG_DIRECTORY}/syslog2  alias=${GNB_SYSLOG.alias}
#    Sleep    60s    reason=Wait for traffic
#    Check UL On Target    ${UE_ID}    0    1    20
#
#CB006137-ET-C-B2602_Verify_UE_UL_power_shared_by_PCell_and_Scell_in_FDD-TDD_FR1_UL_CA_with_actUlClosedLoopPwrCtrl_disable
#    [Documentation]
#    ...    Precondition:
#    ...      Open 6137-C RD Flag in gnb Swconfig file.
#    ...      Closed loop power control is deactivated:actUlClosedLoopPwrCtrl = 0 (disabled)
#    ...      actUlOpenLoopPwrCtrl is set to TRUE on both PCell and SCell.
#    ...      p0UePusch is set to -3 dB on PCell.
#    ...    The execution order will be:
#    ...      1)UE attach.
#    ...      2)Scell added and activated by A1 event.
#    ...      3)Start DL&UL traffic, make sure the UL flow is in both pcell and scell.
#    ...      4)Scell released by A2 event.
#    ...    Check Point:
#    ...      1)During UL Scell addition procedure,check P0 of P0-PUSCH-AlphaSet on Pcell is updated based on NIDD ulPowerControlCommon.p0UePusch.
#    ...      2)During transient phase,check rrmRescaledCorrAvgSinr is reduced based on NIDD parameter ulPowerControlCommon.p0UePusch.
#    ...      3)During UL Scell release procedure,check P0 of P0-PUSCH-AlphaSet on Pcell is reset to 0dB.
#    ...      4)After scell released,check Scell UL TP is reduced to zero.
#    [Tags]    caseCB2602    Manual_Susie    TA_Susie
#    [Setup]    Run Keywords    Setup TL For B6 Each Case    ${6137_CB6_COMMON_SCF}    ${IPHY}    ${WTS_CFG_CB6_PC3}
#    ...    AND    Verify Coam Site Is Ready
#    ...    AND    Start GNB AP Syslog    ${TEST_LOG_DIRECTORY}
#    ...    AND    Start UTE WTS And Check Cell Setup    ${WTS_CFG_CB6_PC3}
#    #Step1:UE attach
#    Basic Flow For Ue Attach And Pdu Setup
#    #Step2:Trigger scell addition by A1 event and caputre ttitrace,check P0 updated to -3,check sinr updated.
#    Start Ttitrace With Streaming Mode
#    ${output_A1}=    A1 ScellAdd And Blind ScellAct    ${UE_ID}    1    126
#    Sleep    5s    reason=Wait for log
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/0/
#    Check P0 Changed    ${output_A1}    A1    -3
#    Get And Check Scell Infos    ${4CC_SCELLS}
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/0/
#    Check Sinr Changed For Transient Period    ${TEST_LOG_DIRECTORY}/ttitrace/0/
#    #Step3:Start ul,dl and check TP.
#    Start SA UE Big UL Traffic Internal    ${UE_ID}    mbps=100
#    Start SA UE Big DL Traffic Internal    ${UE_ID}    mbps=350
#    Sleep    10s    reason=Wait for traffic
#    Check DL On Target    ${UE_ID}    0    1-3    200
#    Check UL On Target    ${UE_ID}    0    3    20
#    Trigger Scell Suspend And Scell Resume    20
#    #Step4:Trigger Scell released by A2 event and check P0 reset to zero,check TP.
#    ${output_A2}=    Trigger A2 Scell Release    ${UE_ID}    4    3    36
#    Check P0 Changed    ${output_A2}    A2    0
#    Check DL On Target    ${UE_ID}    0    1-3    200
#    Check UL On Target    ${UE_ID}    0    3    0
#
#*** Keywords ***
#Common Suite Setup
#    Suite Setup Update GNB    log=${False}
#    Modify UTE SCTP Timeout
#    Modify AP SCTP Timeout
#    Configure UTE ETH3
#    Send Swconfig for GNB    ${gnb_swconfig}
#
#Setup TL For B6 Each Case
#    [Arguments]    ${scf_file}    ${iphy_name}    ${wts_cfg_name}
#    Verify Coam Site Is Ready
#    Create Test Directory
#    Add RD Parameters To GNB Swconfig File    ${6137_B6_COMMON_RD}
#    Modify IPHY File And Send to Airphone    ${LOCAL_IPHY_DIR}/${iphy_name}
#    Full Commission With SCF File    ${scf_file}
#    Sleep    120S    wait gnb and airphone all reboot avaliable.
#    Reboot TL And Check Configured
#    Set WTS Files Name For Each Cases    ${wts_cfg_name}
#
#Start SA Internal Traffic
#    [Arguments]    ${ue_id}    ${pdu_id}    ${dir}    ${mbps}    ${trf_id}=1    ${seconds}=60
#    [Documentation]    This keyword is to start traffic on eGate.
#    ...    Expected output is: "UE IS ACTIVE" on eGate.
#    ...    | Input Parameters | Man. | Description |
#    ...    | ue_id | Yes | ue id |
#    ...    | bearer_id | Yes | bearer_id |
#    ...    | mbps | Yes | mbps |
#    ...    | trf_id | No | trf_id, default is 1 |
#    Log To Console    start Internal traffic...
#    ute_wtssim.Execute Egate Command
#    ...    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} dir\=${dir} mbps\=${mbps} trf_id\=${trf_id} seconds\=${seconds}
#    Sleep    5s    reason=wait traffic is stable
#
#Basic Flow For Ue Attach And Pdu Setup
#    [Arguments]    ${ue_id}=${UE_ID}
#    SA 5G Attach    ue_id=${ue_id}
#    SA Set Traffic Type To Internal    ue_id=${ue_id}    pdu_id=1
#    SA 5G PDU Session Setup    ue_id=${ue_id}
#
#Basic SA Call With Initial Power Split For PC2b
#    [Arguments]    ${ue_id}=${UE_ID}
#    SA 5G Attach    ue_id=${ue_id}
#    SA Set Traffic Type To Internal    ue_id=${ue_id}    pdu_id=1
#    ${savepoint1} =  Capture savepoint  alias=${GNB_SYSLOG.alias}
#    SA 5G PDU Session Setup    ue_id=${ue_id}
#    Start SA UE Big UL Traffic Internal    ${UE_ID}    mbps=100
#    Start SA UE Big DL Traffic Internal    ${UE_ID}    mbps=350
#    Sleep    10s    reason=Wait for traffic
#    ute_syslog.Wait For Message In Syslog File    regexp=Initial split power case    timeout=60    alias=${GNB_SYSLOG.alias}
#    Collect from savepoint  savepoint=${savepoint1}  destination_file=${TEST_LOG_DIRECTORY}/syslog1  alias=${GNB_SYSLOG.alias}
#
#Check Initial Power Split Info
#    [Arguments]    ${log_name}
#    ${initial_power_pcell}    Set Variable    initial power local cell:50.000000
#    ${rst_pcell}    Run    cat ${TEST_LOG_DIRECTORY}/${log_name}|grep -i "${initial_power_pcell}"|wc -l
#    Should Be True    ${rst_pcell} == 1
#    ${initial_power_scell}    Set Variable    initial power local cell:348.107086
#    ${rst_scell}    Run    cat ${TEST_LOG_DIRECTORY}/${log_name}|grep -i "${initial_power_scell}"|wc -l
#    Should Be True    ${rst_scell} == 1
#
#Check UE Enters Overpower State
#    [Arguments]    ${csv_file_path}
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_overpowerstate.ini    output_ul.csv    ${csv_file_path}
#
#Trigger Pcell Suspend By Change WeightRatio100
#    ${savepoint2} =  Capture savepoint  alias=${GNB_SYSLOG.alias}
#    Online Change One Para With Admin    MRBTS-1/NRBTS-1/NRCELL-3    weightRatioOfUePwrScellVsPcell    WeightRatio 100
#    ute_syslog.Wait For Message In Syslog File    regexp=pcellSuspend    timeout=60    alias=${GNB_SYSLOG.alias}
#    Collect from savepoint  savepoint=${savepoint2}  destination_file=${TEST_LOG_DIRECTORY}/syslog2  alias=${GNB_SYSLOG.alias}
#    Start Ttitrace With Streaming Mode
#    Sleep    3s    reason=Wait for Ttitrace Collection
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/2
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/2
#
#Check Pcell Suspend
#    [Arguments]    ${csv_file_path}
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_pcellsuspend.ini    output_ul.csv    ${csv_file_path}
#
#Trigger Pcell Resume By Recover PHR
#    ${savepoint3} =  Capture savepoint  alias=${GNB_SYSLOG.alias}
#    Trigger PHR To GNB    profile_id=1    phr_start=38    pc_max=23
#    Trigger PHR To GNB    profile_id=2    phr_start=38    pc_max=26    cell_id=3
#    ute_syslog.Wait For Message In Syslog File    regexp=pcellResume    timeout=60    alias=${GNB_SYSLOG.alias}
#    Collect from savepoint  savepoint=${savepoint3}  destination_file=${TEST_LOG_DIRECTORY}/syslog3  alias=${GNB_SYSLOG.alias}
#    Start Ttitrace With Streaming Mode
#    Sleep    3s    reason=Wait for Ttitrace Collection
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/3
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/3
#
#Check Initial Power Split After Pcell Resume
#    [Arguments]    ${log_name}
#    ${content}    Set Variable    Initial Split Power receive
#    ${rst}    Run    cat ${TEST_LOG_DIRECTORY}/${log_name}|grep -i "${content}"|wc -l
#    Should Be True    ${rst} == 1
#
#A1 ScellAdd And Blind ScellAct
#    [Arguments]    ${ue_id}=1    ${meas_id}=1    ${srsrp_nr}=126    ${scell_index}=3
#    Log To Console    start A1 event...
#    ${command}    Set Variable    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${srsrp_nr}
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
#    ...    ${command}    pass_regexp=SCellIndex ${scell_index} activated successfully at airphone    timeout=3minutes
#    [Return]    ${output}
#
#Trigger A2 Scell Release
#    [Arguments]    ${ue_id}    ${meas_id}    ${scell_index}    ${scell_rsrp}
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
#    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=${scell_index} scell_rsrp=${scell_rsrp}
#    ...    pass_regexp=rrcReconfigurationComplete    timeout=3minutes
#    [Return]    ${output}
#
#Check DL On Target
#    [Arguments]    ${ueId}    ${pcell_index}    ${scell_index}    ${target_dlsum_tp}
#    ${pcell_dlTP}    Get CA Cell Average Throughput    ${ueId}    dl    pcell    ${pcell_index}
#    Log To Console    Pcell's DL Troughput is ${pcell_dlTP}    console=True
#    ${scell_dlTP}    Get CA Cell Average Throughput    ${ueId}    dl    scell    ${scell_index}
#    Log To Console    Scell's DL Troughput is ${scell_dlTP}    console=True
#    ${dlsum_tp}    evaluate    ${pcell_dlTP}+${scell_dlTP}
#    Log To Console    DL Troughput is ${dlsum_tp}    console=True
#    Should Be True    ${dlsum_tp}>=${target_dlsum_tp}
#
#Check UL On Target
#    [Arguments]    ${ueId}    ${pcell_index}    ${scell_index}    ${target_ulsum_tp}
#    ${pcell_ulTP}    Get CA Cell Average Throughput    ${ueId}    ul    pcell    ${pcell_index}
#    Log To Console    Pcell's UL Troughput is ${pcell_ulTP}    console=True
#    ${scell_ulTP}    Get CA Cell Average Throughput    ${ueId}    ul    scell    ${scell_index}
#    Log To Console    Scell's UL Troughput is ${scell_ulTP}    console=True
#    ${ulsum_tp}    evaluate    ${pcell_ulTP}+${scell_ulTP}
#    Log To Console    UL Troughput is ${ulsum_tp}    console=True
#    Should Be True    ${ulsum_tp}>=${target_ulsum_tp}
#
#Check P0 Changed
#    [Arguments]    ${log}    ${flag}    ${p0_value}
#    ${regexp_A1}    Catenate    SEPARATOR=    pusch-Config setup :[\\s\\S]*?pusch-PowerControl[\\s\\S]*?
#    ...    p0-AlphaSets[\\s\\S]*?p0\\s(?P<P0value>-\\d),
#    ${regexp_A2}    Catenate    SEPARATOR=    pusch-Config setup :[\\s\\S]*?pusch-PowerControl[\\s\\S]*?
#    ...    p0-AlphaSets[\\s\\S]*?p0\\s(?P<P0value>\\d),
#    ${regexp}    Set Variable If    '${flag}' == 'A1'    ${regexp_A1}    ${regexp_A2}
#    ${ret}    String.Get Regexp Matches    ${log}    ${regexp}    P0value
#    ${new_ret}    Get From List    ${ret}    0
#    BuiltIn.Log    ${new_ret}
#    Should Be True    ${new_ret}==${p0_value}
#
#Check Sinr Changed For Transient Period
#    [Arguments]    ${csv_file_path}
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_sinr.ini    output_ul.csv    ${csv_file_path}
#
#Trigger PHR To GNB
#    [Arguments]    ${profile_id}    ${phr_start}    ${phr_min}=0    ${phr_max}=30    ${phr_step_size}=5
#    ...    ${phr_period}=10    ${pc_max}=23    ${phr_mode}=Fixed    ${ue_id}=1    ${cell_id}=0
#    Log To Console    start send Power Headroom Report to gnb...
#    ${cmd1}    Catenate    phr_override_testmode_nr profile_id=${profile_id} phr_mode=${phr_mode} phr_start=${phr_start}
#    ...    phr_min=${phr_min} phr_max=${phr_max} phr_step_size=${phr_step_size} phr_period=${phr_period} pc_max=${pc_max}
#    ute_wtssim.Execute Egate Command    ${cmd1}
#    ${cmd2}    Catenate    ue_testmode_set_nr id=${ue_id} testmode=phr_override action=activate
#    ...     profile_id=${profile_id} scell=${cell_id}
#    ute_wtssim.Execute Egate Command    ${cmd2}
#
#Check DynamicPowerSplit not Start By Gnb_syslog
#    [Arguments]    ${PowerSplit}
#    ute_syslog.Collect Syslog Results    alias=${GNB_SYSLOG.alias}    unzip=False    destination=${TEST_LOG_DIRECTORY}/Gnb_syslog.tar.gz
#    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    cd ${TEST_LOG_DIRECTORY};tar -xzvf ${TEST_LOG_DIRECTORY}/Gnb_syslog.tar.gz
#    Log    ${output}
#    ${syslog_names}    OperatingSystem.List Files In Directory    ${TEST_LOG_DIRECTORY}    Gnb_syslog_*    ${True}
#    ${count}    OperatingSystem.Run    cat ${TEST_LOG_DIRECTORY}/Gnb_syslog_*|grep -i "${PowerSplit}"|wc -l
#    Should Be True    ${count}!=0
#
#Check UE Scheduled with all Available PRBs on both FDD and TDD
#    [Arguments]    ${csv_file_path}
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_prb_schedule.ini    output_ul.csv    ${csv_file_path}
#
#Check DynamicPowerSplit not Start
#    [Arguments]    ${csv_file_path}
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_powersplit.ini    output_ul.csv    ${csv_file_path}
#
#Check PM Counter For CA Related Counters
#    Sleep    5s    reason=Wait for Weubi Checking
#
#Check Scell UL Decreased
#    [Arguments]    ${ueId}    ${scell_index}    ${target_ul_tp}
#    ${scell_ulTP}    Get CA Cell Average Throughput    ${ueId}    ul    scell    ${scell_index}
#    Log To Console    Scell's UL Troughput is ${scell_ulTP}    console=True
#    Should Be True    ${scell_ulTP}<=${target_ul_tp}
#
#Trigger Scell Suspend And Scell Resume
#    [Arguments]    ${ul_tp_threshold}
#    ${savepoint1} =  Capture savepoint  alias=${GNB_SYSLOG.alias}
#    Send PHR To GNB    profile_id=1    phr_start=0    cell_id=0    pc_max=23
#    Send PHR To GNB    profile_id=2    phr_start=10    cell_id=3     pc_max=26
#    Wait for message in syslog file  regexp=scellSuspend  timeout=60  alias=${GNB_SYSLOG.alias}
#    Collect from savepoint  savepoint=${savepoint1}  destination_file=${TEST_LOG_DIRECTORY}/syslog1  alias=${GNB_SYSLOG.alias}
#    Sleep    30s    reason=Wait for process
#    Check Scell UL Decreased    1    3    0
#    ${savepoint2} =  Capture savepoint  alias=${GNB_SYSLOG.alias}
#    Recover Default PH For Pcell And Scell    scell_id=3
#    Wait for message in syslog file  regexp=scellResume  timeout=60  alias=${GNB_SYSLOG.alias}
#    Collect from savepoint  savepoint=${savepoint2}  destination_file=${TEST_LOG_DIRECTORY}/syslog2  alias=${GNB_SYSLOG.alias}
#    Sleep    60s    reason=Wait for traffic
#    Check UL On Target    ${UE_ID}    0    1    ${ul_tp_threshold}
#
