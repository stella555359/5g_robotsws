*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN    SBTS22R2    SBTS22R3    SBTS23R1    CONFIGURED

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         ./CB008246_resource.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Library          python/CB008246_validation.py

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Update GSCN in AP Iphy Xml     gscn=7867
...                 AND     Perform SCF Delta Commissioning with Delta_CB008246_LB81_9427_TDD.json
...                 AND     sleep    180
...                 AND     gnb.Perform gNB reboot
...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Load CFG Config And Capture CPRT Traces      ${wts_cfg_file}
...                 AND     Run Keyword and Ignore Error    Start Log    btslog
...                 AND     Check gNB Bulid


Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Run Keyword and Ignore Error    Stop Log    btslog
...                 AND     Run Keyword and Ignore Error    Stop Log     snapshot    sosreport

Documentation
...
...				author       : B,Padmashree <padmashree.b@nokia.com>
...             maintainer   : B,Padmashree <padmashree.b@nokia.com>
...             INTRODUCTION:     This user scenario is aimed at verifying the TDD IWK between CB009427-A#1(Activation for adaptive 
...					UL BLER) & CB008246-E#1/2(DRB switch between basic reliability and high reliability link adaption for non-GBR in UL) 
...             TEST SET NAME:    [1]CB008246_L_B81_HR LA TDD interworking with Adaptive UL BLER for Spectral Efficiency 
...		                       Improvement-CB009427
...             TESTING SPLIT:     See CB008246 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008246 CFAM
...             Requirement ID:      5G_PM_462

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/basic_cfg_tdd.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${qfi_id}    1
${Q_O_ADD}      1
${RTP_COD}      1
${epc_log_path}    /tmp/
${st_ue_id}      ${1}
${en_ue_id}      ${1}
${TLConfig.isUTE}       True
${TEST_NAME}        test_case

*** Test Cases ***
[1]CB008246_L_B81_HR_LA_TDD_interworking_with_Adaptive_UL_BLER_for_Spectral_Efficiency_Improvement_CB009427
    set test variable      ${LOG_PATH}
    log to console   UE attach trigerring now...	
	Start Log    cprt

#Step 1. Attach  UEs with PDU session 5QI-6 nonGBR qosflow which is default
    ${crnti}    MultiUE Register should be Successful     ${st_ue_id}    ${en_ue_id}    pdu_id=1    nw_id=1
#Step 2.start data
    MultiUE Trigger UL Traffic for SA    ${st_ue_id}    ${en_ue_id}    Traffic_rate=kbps     ul_rate=32     trf_id=1
	
    Start Log       ttitrace

#Step 3.modify pdu with qos flow : 4 (HR)  and trigger data
    MultiUE PDU Modfication should be Successful     ${st_ue_id}    ${en_ue_id}    pdu_id=1   qosflows_to_add=4
    Sleep       2s
    MultiUE Trigger UL Traffic for SA    ${st_ue_id}    ${en_ue_id}    Traffic_rate=kbps     ul_rate=32     pdu_id=1    trf_id=1       qfi_id=2

#Step 4: Degrade UL radio conditions
    Introduce pathloss      1       1       loss=150
    Activate pathloss_for_UE    1   1
    Sleep       2s

#Step5: deactivate path loss
    Deactivate pathloss_for_UE  1   1
    Sleep   1s

    ${path_ttitrace}    Stop log    ttitrace    test_scenario=ttitrace_lb81_TDD
    MultiUE Deregister should be Successful   ${st_ue_id}    ${en_ue_id}	
    ${path_cprt}    Stop log    cprt       test_scenario=cprt
	
#Step 5.Decode and verify	
    Decode TTI Trace    ttitrace_lb81_TDD
    ${hr}   ${br_lowsinr}   ${br_highsinr}   ${status_fail}      SplitL9427verify     ulFdSchedData
    ...      ${crnti}[0]     ${path_ttitrace}[ttitrace]/output_ul_formated.csv
    Should Not Contain	${hr}	FAIL
    Should Not Contain  ${br_lowsinr}   FAIL
    Should Not Contain  ${br_highsinr}   FAIL
    Should Not Contain  ${status_fail}  FAIL
