*** Settings ***
Resource    ./../CUDU_L2/common_setup_teardown.robot
Resource    ./../CUDU_L2/common_log_capture.robot
Resource    ./Resources/CB009855_resource.robot
Force Tags        CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD    SBTS00     RAN_5G    CRT

*** Variables ***
${LOCAL_WTS_DIR}     ${CURDIR}/Config
${SCF_PATH}          ${CURDIR}/Config
${SCF_9855_B8a_gnb1}    ${SCF_PATH}/SCF_11117_gnb1.xml
${SCF_9855_B8a_gnb2}    ${SCF_PATH}/SCF_11117_gnb2.xml
${IPHY_3T2F}        ${CURDIR}/Config/iphy_3T2F.xml
${WTS_CFG}           basic_setup_11117.cfg
@{LOG_NAME_LIST}     btslog    egatelog
${force_reboot}      ${True}
${RD}                  0x4B000F=1;0x58057A=4;0x58057f=8192;0x58012d=2;0x590287=1;0x59026A=1;0x590284=1
${PRIVATE_LOCAL_PATH}        /home/ute/kiss_files/private/
${PRIVATE_CONFIG_ADDRESS}     "https://gitlabe1.ext.net.nokia.com/hz_ran_l2_sw3_ta/ta_kiss_golden_files.git"
*** Test Cases ***
CB011117_A1b_case001_Scell_is_added_after_SRS_for_SB_BF_being_configured_at_Pcell_with_T+F_inter_gNB_CA_confiuration
    [Documentation]
    ...    CB009855 para:
    ...    NRBTS/NRDU. carrierAggregationSupportList contains an entry set to “700: ca_Fr1Tdd_Any_Sa”; AND
    ...    NRBTS/NRCELL. maxNumScellsDlFr1 is set to 4.
    ...                 scellAdditionMethod = blind
    ...                 scellActivationMethod = bufferBased
    ...                 scellDeactivationTimerGNB = ms1280
    ...   Test Steps:
    ...                 Step1. Attach UE to cell1_1, PDU session setup triggers blind SCell additio
    ...    Check points:
    ...                 1.UE is configured with 2CC CA with cell1_1 as PCell, cell2_1as SCell(s).
    [Tags]    TA_Susie    Mannual_Susie
    Download All Tools
   	Wts Execute Aashell Command   
	  ...   confmgmtdefscli set --domain NrUeDlPhy --name radPdcchApplyToSeparateStreams_AP --value 1 --change-type persistent --timeout 5
  	Get and Update BSR File		par_of_bsr_name=BSR_AEHC_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    Import Testline Variables For 2 GNBs
    Create Suite Directory
    Backup And Update Iphy Swconfig File    ${IPHY_3T2F}    ${RD}
    Modify Swconfig File Parameters for 2gnb
    log to console    Send scf to gnb2...
    Full Commission SCF File Through Mplane With Admin    ${SCF_9855_B8a_gnb2}    1    10.0.1.3
    log to console    Send scf to gnb1...
    Full Commission SCF File Through Mplane With Admin    ${SCF_9855_B8a_gnb1}    1    10.0.1.2
    Reboot TL And Check Configured For 2 GNBs
    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}    wts_cfg_file=${WTS_CFG}
    Sleep    60s    Wait for interGNB communication interface established stable
    Create Test Directory
    Start GNB AP Syslog    ${TEST_LOG_DIRECTORY}
    Suite Setup Start WTS And Check OnAir    log=${False}    gnb_num=2
    Sleep    60s    Wait for interGNB communication interface established stable
    Attach UE And Start Traffic    1
	Trigger A2 Scell Release    1    1    80    50    2
    [Teardown]    Common Test Teardown 2
    

*** Keywords ***
Attach UE And Start Traffic
    [Arguments]    ${UE_ID}
    SA 5G Attach    ue_id=${UE_ID}
    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
    SA 5G PDU Session Setup    ue_id=${UE_ID}
    Sleep    1s    wait for stable
    #step1  
    Run Keyword And Continue On Failure    Start DL Traffic    1    6
    #Run Keyword And Continue On Failure    Start UL Traffic    1    1
    Send Measurement Report To Trigger A1 Scell Addition    1
	CB009855_resource.Check Whether UE In CA Mode    ${UE_ID}    2
    Wait Untill Scell Activated    1    1
    Wait Until Keyword Succeeds    60s    5s    Check Traffic On Pcell and Scell
    #Stop DL Traffic    1    6
    #Stop UL Traffic    1    1
    #Sleep    3s    wait traffic stop..
    #Wait Untill Scell Deactivated    1    1
    Check UL And DL DTX From Ttitrace For 2GNB    log_id=1    duration=2

Send Measurement Report To Trigger A1 Scell Addition
    [Arguments]    ${UE_ID}
    ute_wtssim.Execute Egate Command    cmd=ue_measurement_send_nr id\=${UE_ID} meas_id=1 event=A1 srsrp_nr=80
    Sleep    2s

Send A3 MR to trigger interGNB intraFreqHo with blind Scell Addition
    [Arguments]    ${ue_id}=1    ${target_pci}=58
    ${command}    Set Variable    ue_measurement_send_nr id=${ue_id} meas_id=2 event=A3 srsrp_nr=10 phycell_id=${target_pci} nrsrp_nr=40
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    pass_regexp=Inter-eNB handover from EXT_ENB-2.4 to EXT_ENB-3.9 performed    timeout=3min
    Wait Until Keyword Succeeds    60s    5s    Check Traffic On Pcell and Scell    1    4    600


Suite Setup Start WTS For B6a
    Modify UTE SCTP Timeout
    Modify AP SCTP Timeout
    Configure UTE ETH3
    Start UTE WTS    ${WTS_CFG_B6a}
    UE SIB Decoding Should Be Successful
    Check All Cells Received SIB2


Modify Swconfig File Parameters for 2gnb
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@10.0.1.3 'echo "0x4B000F=1">>/ffs/run/swconfig.txt'
	Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@10.0.1.3 'crasign /ffs/run/swconfig.txt'
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@10.0.1.3 'echo "0x590287=1">>/ffs/run/swconfig.txt'
	Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@10.0.1.3 'crasign /ffs/run/swconfig.txt'
     Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@10.0.1.3 'echo "0x59026A=1">>/ffs/run/swconfig.txt'
	Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@10.0.1.3 'crasign /ffs/run/swconfig.txt'
     Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@10.0.1.3 'echo "0x590284=1">>/ffs/run/swconfig.txt'
	Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@10.0.1.3 'crasign /ffs/run/swconfig.txt'
Traffic Display
    Run Keyword And Ignore Error    ute_wtssim.Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 type=pdsch scell=0-4
    ...    pass_regexp=CellIndex-0    timeout=60s
    sleep    5s    #for traffic
    Run Keyword And Ignore Error    ute_wtssim.Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 type=pusch scell=0-4
    ...    pass_regexp=CellIndex-0    timeout=60s
Get and Update BSR File
     [Arguments]      ${par_of_bsr_name}=BSR_AEQE_6_H6_ALN60
     ${bsr_file_path}     get BSR file name      ${par_of_bsr_name}
     COAM.setup admin
     ${ret}     COAM.Update Software      ${bsr_file_path}
     COAM.teardown admin 
get BSR file name 
    [Arguments]       ${part_of_file_name}
     ${files}     List Files In Directory      ${PRIVATE_LOCAL_PATH}/BSR_FILE
     FOR     ${f}    IN    @{files}
         Return From Keyword if     '${part_of_file_name}' in '${f}'         ${PRIVATE_LOCAL_PATH}/BSR_FILE/${f}
     END
Wts Execute Aashell Command
    [Documentation]    This keyword is to execute command by 'nc 0 15007' with ute_fsmaccess.
    ...    Examples:
    ...    | Execute Aashell Command | confmgmtdefscli set --domain NrUeDlPhy --name a --value 1 --change-type persistent --timeout 5 |
    [Arguments]    ${command}
	${cmds}     split string    ${command}    ; 
    ute_fsmaccess.Setup Wts Fsm Access
	FOR     ${single}    IN    @{cmds} 
        ${ret}    ute_fsmaccess.Execute Command On Wts    bsh 1:1 "${single}"
	    log    ${ret}
  END       
    [Teardown]    ute_fsmaccess.Teardown Wts Fsm Access     
Download Common Config Files From Private Server
    [Arguments]    ${local_save_path}=${PRIVATE_LOCAL_PATH}
    [Documentation]    This keyword is to Download Common Config Files From Private Server ${PRIVATE_CONFIG_ADDRESS}
    ...    and return markdown file full path
    ...    Examples:
    ...    | Download Common Config Files From Private Server| |
    ...    | Download Common Config Files From Private Server| /tmp/ |
    git check and clone      ${PRIVATE_CONFIG_ADDRESS}     ${local_save_path}

    [Return]    ${local_save_path}/capability/ue_capability.md     
Download All Tools
    
    Run Keyword And Ignore Error    Download Common Config Files From Private Server
git check and clone
    [Arguments]    ${git_link}    ${local_save_path}
    ${date}    	Get Current Date   	result_format=datetime
    ${ret}    Run Keyword And Ignore Error     Directory Should Exist    ${local_save_path}
    ${run_ret}   Run Keyword If     '${ret[0]}'=='FAIL'    OperatingSystem.Run    
    ...    rm -rf ${local_save_path};mkdir -p ${local_save_path};git clone ${git_link} ${local_save_path}
    ${time_info}     OperatingSystem.Run     ls --full-time ${local_save_path}
    Run Keyword If     '${ret[0]}'=='FAIL'     Return From Keyword
    ${timestampe}    Split To Lines      ${time_info} 
    ${ret}   Run Keyword If     '${date.month}-${date.day}' not in '${timestampe[-1]}'   OperatingSystem.Run    
    ...    rm -rf ${local_save_path};mkdir -p ${local_save_path};git clone ${git_link} ${local_save_path} 
CUDU_L2 Capture And Decode TTitrace For 2GNB
    [Arguments]    ${log_id}=1    ${duration}=5
    Start Ttitrace With Streaming Mode For 2GNB
    Sleep    ${duration}s    reason=Wait for logs
    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${log_id}
    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${log_id}

Start Ttitrace With Streaming Mode For 2GNB
    [Arguments]    ${names}=l2stream3_ttitrace
    [Documentation]    This keyword is used to start ttitrace with streaming mode.
    ...    examples 1: catch all cells
    ...    Start Ttitrace With Streaming Mode
    log to console    setup admin for ttitrace...
    Run Keyword If    '${SW_BRANCH}'=='${EMPTY}'    Get Software Version
    ${executor}=  Create Dictionary
    ...  host=10.0.1.2
    ...  user=Nemuadmin
    ...  password=nemuuser
    ...  port=443
    ...  release=${SW_BRANCH}
    TCPDUMP.create tcpdump collector
    ...  name=tcpdump_ttitrace
    ...  options=-i eth3 udp and dst 10.0.1.1 and dst port 5678
    ...  sudo_password=ute
    L2STREAM3.create_sbts_l2stream_collector
    ...  name=${names}
    ...  destination_ip_addr=10.0.1.1
    ...  collector=tcpdump_ttitrace
    ...  l2_stream_configuration=${L2STREAM_COMPONENT_CONFIG}
    ...  webservice=${executor}
    ...  dscp=10
    L2STREAM3.Set Suite Alias
    ...  alias=${names}
    CORE.setup_collectors
    ...  names=${names}
   ${executor2}=  Create Dictionary
    ...  host=10.0.1.3
    ...  user=Nemuadmin
    ...  password=nemuuser
    ...  port=443
    ...  release=${SW_BRANCH}
    L2STREAM3.create_sbts_l2stream_collector
    ...  name=${names}
    ...  destination_ip_addr=10.0.1.1
    ...  collector=tcpdump_ttitrace
    ...  l2_stream_configuration=${L2STREAM_COMPONENT_CONFIG}
    ...  webservice=${executor2}
    ...  dscp=10
    L2STREAM3.Set Suite Alias
    ...  alias=${names}
    CORE.setup_collectors
    ...  names=${names}
    CORE.start_collectors
    ...  names=${names}
    log to console    finish admin process for ttitrace,start to catch ttitrace log...
Check UL And DL DTX From Ttitrace For 2GNB
    [Arguments]    ${log_id}    ${duration}
    CUDU_L2 Capture And Decode TTitrace For 2GNB   ${log_id}    ${duration}
    CUDU_L2 Check DTXNACK Rate    ${log_id}
    CUDU_L2 Check UL DTXCRC Rate    ${log_id}
    CUDU_L2 Check DL SUBBAND Rate   ${log_id}
CUDU_L2 Check DL SUBBAND Rate
    [Arguments]    ${log_id}    ${expect_rate}=0.5
    CUDU_L2 Check SUBBAND Rate    dlFdSchedData.beamType    ["SUBBAND","SSB","DFTNONTAPERING"]    ["SUBBAND"]    ${log_id}    ${expect_rate}   
CUDU_L2 Check SUBBAND Rate
    [Arguments]    ${name}=dlFdSchedData.ackNack    ${total}=["ACK", "NACK","DTX"]    ${failed}=["NACK","DTX"]    ${log_id}=dtxnack
    ...    ${expect_rate}=0.1
    [Documentation]    This keyword is to check rate.
    ...    | Input Parameters | Man. | Description |
    ...    | name | Yes |the column title to check, default is dlFdSchedData.ackNack |
    ...    | total | Yes | all the status , default is ["ACK", "NACK","DTX"]|
    ...    | failed  | Yes | failed status, default is ["NACK","DTX"] |
    ...    Example:
    ...    | Check Rate | dlFdSchedData.ackNack | ["ACK", "NACK","DTX"] | ["NACK","DTX"] |
    ${total_number}    CUDU_L2 Get Total Number    ${name}    ${total}    ${log_id}
    ${failed_number}    CUDU_L2 Get Total Failed Number    ${name}    ${failed}    ${log_id}
    ${rate}    Evaluate    float(${failed_number})/(${total_number})
    Log To Console    \n${name} rate is ${rate}\n
    Should Be True    ${rate}>${expect_rate}     
