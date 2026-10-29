*** Settings ***
Documentation    Suite description
...    Author:Frank Luo
...    contact:frank.s.luo@nokia-sbell.com
Resource    ./CB008445_Resource.robot
Variables             CaseSCFDelta.py
*** Variables ***
${PB_BTS_IP}       ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${PB_BTS_PORT}     ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
#${PB_RU0_IP}       ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
#${PB_RU0_PORT}     ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}
${PA_INFO}            ${tl.attenuator}

##################define these variable for convenient#########################
${ALIAS_ASIK}            ASIK Master                                         ##
${ALIAS_ASIK_SLAVE}      asik_slave                                          ##
${ALIAS_ABIL}            abil                                                ##
${ALIAS_ABIL_SLAVE}      abil_slave                                          ##
${ALIAS_LONER}           loner                                               ##
${ALIAS_UTE}             ute                                                 ##
${ALIAS_ENBCTLPC}        ENB_PC                                              ##
${ALIAS_SHP}             SHP                                                 ##
${ALIAS_E500}            E500                                                ##
${ALIAS_PRISMA}          Prisma                                              ##
${ALIAS_AMF}             AMF                                                 ##
########################END of alias Define####################################
*** Keywords ***
TC.01_Attach SR on different PRACH configuration recommison
    [Documentation]   detail steps 4Gonly
    ...       1.commission with correct prach parameters
    ...       2.Call and Capture BIP log
    ...       3.Check Prach Message success and no retry
    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF_LTE_10M}
    # 10M Testing
    ${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${scf}    TCID=TC01
    run keyword if  '${scf}'!='NULL'  COAM_Admin.commission  scf_file=${casescf}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    #Log.StartCaptureBip
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['dl']}    target_throughput=5M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['ul']}    target_throughput=5M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']}    script_path=ViViScriptLTE/
    DoTputCall
TC.01LTE5M_Attach SR on different PRACH configuration recommison
    [Documentation]   detail steps 4Gonly
    ...       1.commission with correct prach parameters
    ...       2.Call and Capture BIP log
    ...       3.Check Prach Message success and no retry
    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF_LTE_5M}
    # 10M Testing
    ${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${scf}    TCID=TC01
    run keyword if  '${scf}'!='NULL'  COAM_Admin.commission  scf_file=${casescf}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    #Log.StartCaptureBip
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['dl']}    target_throughput=5M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['ul']}    target_throughput=5M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']}    script_path=ViViScriptLTE5M/
    DoTputCall
TC.02_Attach SR on different PRACH FreqOffset chagne
    [Documentation]   detail steps
    ...       1.commission with correct prach Freqoffset parameters
    ...       2.Call and Capture BIP log
    ...       3.Check Prach Message success and no retry
    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF_LTE_10M}
    # 10M Testing
    ${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${scf}    TCID=TC02
    run keyword if  '${scf}'!='NULL'  COAM_Admin.commission  scf_file=${casescf}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    #Log.StartCaptureBip
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['dl']}    target_throughput=5M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['ul']}    target_throughput=5M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']}    script_path=ViViScriptLTE/
    DoTputCall

TC.03_Peak throughput with DL 64QAM Modulation on different bandwidth
    [Documentation]   detail steps
    ...       1.commission with correct 5M/10M 64QAM parameters
    ...       2.Call and check tput
    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF_NR_10M}
    # 10M Testing
    ${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${scf}    TCID=TC03_10M
    run keyword if  '${scf}'!='NULL'  COAM_Admin.commission  scf_file=${casescf}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['dl']}    target_throughput=157.3M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['ul']}    target_throughput=103.8M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']}    script_path=ViViScript/
    DoTputCall     direction=dl

TC.04_Peak throughput with UL 64QAM Modulation on different bandwidth
    [Documentation]   detail steps
    ...       1.commission with correct 5M/10M 64QAM parameters
    ...       2.Call and check tput
    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF_NR_10M}
    ${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${scf}    TCID=TC04_10M
    run keyword if  '${scf}'!='NULL'  COAM_Admin.commission  scf_file=${casescf}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['dl']}    target_throughput=157.3M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['ul']}    target_throughput=103.8M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']}    script_path=ViViScript/
    DoTputCall    direction=both
TC.05_Peak throughput with DL 256QAM Modulation on different bandwidth
    [Documentation]   detail steps
    ...       1.commission with correct 5M/10M 256QAM parameters
    ...       2.Call and check tput
    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF_NR_10M}
    ${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${scf}    TCID=TC05_10M
    run keyword if  '${scf}'!='NULL'  COAM_Admin.commission  scf_file=${casescf}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['dl']}    target_throughput=212.3M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['ul']}    target_throughput=103.8M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']}    script_path=ViViScript/
    DoTputCall    direction=dl
TC.06_Peak throughput with UL 256QAM Modulation on different bandwidth
    [Documentation]   detail steps
    ...       1.commission with correct 5M/10M 256QAM parameters
    ...       2.Call and check tput
    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF_NR_10M}
    ${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${scf}    TCID=TC06_10M
    run keyword if  '${scf}'!='NULL'  COAM_Admin.commission  scf_file=${casescf}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['dl']}    target_throughput=212.3M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['ul']}    target_throughput=103.8M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']}    script_path=ViViScript/
    DoTputCall    direction=both
TC.03NR5M_Peak throughput with DL 64QAM Modulation on different bandwidth
    [Documentation]   detail steps
    ...       1.commission with correct 5M/10M 64QAM parameters
    ...       2.Call and check tput
    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF_NR_5M}
    ${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${scf}    TCID=TC03_5M
    run keyword if  '${scf}'!='NULL'  COAM_Admin.commission  scf_file=${casescf}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['dl']}    target_throughput=75.24M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['ul']}    target_throughput=42.1M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']}    script_path=ViViScript5M/
    DoTputCall     direction=dl
TC.04NR5M_Peak throughput with UL 64QAM Modulation on different bandwidth
    [Documentation]   detail steps
    ...       1.commission with correct 5M/10M 64QAM parameters
    ...       2.Call and check tput
    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF_NR_5M}
    ${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${scf}    TCID=TC04_5M
    run keyword if  '${scf}'!='NULL'  COAM_Admin.commission  scf_file=${casescf}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['dl']}    target_throughput=75.24M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['ul']}    target_throughput=42.1M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']}    script_path=ViViScript5M/
    DoTputCall    direction=both
TC.05NR5M_Peak throughput with DL 256QAM Modulation on different bandwidth
    [Documentation]   detail steps
    ...       1.commission with correct 5M/10M 256QAM parameters
    ...       2.Call and check tput
    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF_NR_5M}
    ${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${scf}    TCID=TC05_5M
    run keyword if  '${scf}'!='NULL'  COAM_Admin.commission  scf_file=${casescf}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['dl']}    target_throughput=100.21M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['ul']}    target_throughput=42.1M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']}    script_path=ViViScript5M/
    DoTputCall     direction=dl
TC.06NR5M_Peak throughput with UL 256QAM Modulation on different bandwidth
    [Documentation]   detail steps
    ...       1.commission with correct 5M/10M 256QAM parameters
    ...       2.Call and check tput
    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF_NR_5M}
    ${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${scf}    TCID=TC06_5M
    run keyword if  '${scf}'!='NULL'  COAM_Admin.commission  scf_file=${casescf}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['dl']}    target_throughput=100.21M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['ul']}    target_throughput=42.1M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']}    script_path=ViViScript5M/
    DoTputCall    direction=both

TC.03LTE_Peak throughput with DL 64QAM Modulation on different bandwidth
    [Documentation]   detail steps
    ...       1.commission with correct 5M/10M 64QAM parameters
    ...       2.Call and check tput
    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF_LTE_10M}
    # 10M Testing
    ${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${scf}    TCID=TC03_10M_LTE
    run keyword if  '${scf}'!='NULL'  COAM_Admin.commission  scf_file=${casescf}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['dl']}    target_throughput=71M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['ul']}    target_throughput=34M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']}    script_path=ViViScriptLTE/
    DoTputCall     direction=dl

TC.04LTE_Peak throughput with UL 64QAM Modulation on different bandwidth
    [Documentation]   detail steps
    ...       1.commission with correct 5M/10M 64QAM parameters
    ...       2.Call and check tput
    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF_LTE_10M}
    ${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${scf}    TCID=TC04_10M_LTE
    run keyword if  '${scf}'!='NULL'  COAM_Admin.commission  scf_file=${casescf}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['dl']}    target_throughput=71M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['ul']}    target_throughput=34M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']}    script_path=ViViScriptLTE/
    DoTputCall    direction=both
TC.05LTE_Peak throughput with DL 256QAM Modulation on different bandwidth
    [Documentation]   detail steps
    ...       1.commission with correct 5M/10M 256QAM parameters
    ...       2.Call and check tput
    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF_LTE_10M}
    ${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${scf}    TCID=TC05_10M_LTE
    run keyword if  '${scf}'!='NULL'  COAM_Admin.commission  scf_file=${casescf}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['dl']}    target_throughput=190M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['ul']}    target_throughput=35M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']}    script_path=ViViScriptLTE/
    DoTputCall    direction=dl
TC.06LTE_Peak throughput with UL 256QAM Modulation on different bandwidth
    [Documentation]   detail steps
    ...       1.commission with correct 5M/10M 256QAM parameters
    ...       2.Call and check tput
    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF_LTE_10M}
    ${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${scf}    TCID=TC06_10M_LTE
    run keyword if  '${scf}'!='NULL'  COAM_Admin.commission  scf_file=${casescf}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['dl']}    target_throughput=190M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['ul']}    target_throughput=35M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']}    script_path=ViViScriptLTE/
    DoTputCall    direction=both
TC.03LTE5M_Peak throughput with DL 64QAM Modulation on different bandwidth
    [Documentation]   detail steps
    ...       1.commission with correct 5M/10M 64QAM parameters
    ...       2.Call and check tput
    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF_LTE_5M}
    ${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${scf}    TCID=TC03_5M_LTE
    run keyword if  '${scf}'!='NULL'  COAM_Admin.commission  scf_file=${casescf}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['dl']}    target_throughput=35M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['ul']}    target_throughput=14M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']}    script_path=ViViScriptLTE5M/
    DoTputCall     direction=dl
TC.04LTE5M_Peak throughput with UL 64QAM Modulation on different bandwidth
    [Documentation]   detail steps
    ...       1.commission with correct 5M/10M 64QAM parameters
    ...       2.Call and check tput
    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF_LTE_5M}
    ${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${scf}    TCID=TC04_5M_LTE
    run keyword if  '${scf}'!='NULL'  COAM_Admin.commission  scf_file=${casescf}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['dl']}    target_throughput=35M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['ul']}    target_throughput=14M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']}    script_path=ViViScriptLTE5M/
    DoTputCall    direction=both
TC.05LTE5M_Peak throughput with DL 256QAM Modulation on different bandwidth
    [Documentation]   detail steps
    ...       1.commission with correct 5M/10M 256QAM parameters
    ...       2.Call and check tput
    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF_LTE_5M}
    ${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${scf}    TCID=TC05_5M_LTE
    run keyword if  '${scf}'!='NULL'  COAM_Admin.commission  scf_file=${casescf}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['dl']}    target_throughput=82M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['ul']}    target_throughput=15M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']}    script_path=ViViScriptLTE5M/
    DoTputCall     direction=dl
TC.06LTE5M_Peak throughput with UL 256QAM Modulation on different bandwidth
    [Documentation]   detail steps
    ...       1.commission with correct 5M/10M 256QAM parameters
    ...       2.Call and check tput
    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF_LTE_5M}
    ${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${scf}    TCID=TC06_5M_LTE
    run keyword if  '${scf}'!='NULL'  COAM_Admin.commission  scf_file=${casescf}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['dl']}    target_throughput=82M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['ul']}    target_throughput=15M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']}    script_path=ViViScriptLTE5M/
    DoTputCall    direction=both

TC.07_uDTX function activation
    [Documentation]   detail steps
    ...    1. Do a call and get RSSI from UE
    ...    2. Start DL data and get the RSSI from UE
    ...    3. data RSSI should be grater than without data RSSI
    [Arguments]   ${scf}=${TL_BASE_SCF}
    ${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${scf}    TCID=TC07
    #run keyword if  '${scf}'!='NULL'  COAM_Admin.commission  scf_file=${casescf}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    VIVI.8445Attach
    Sleep    2s
    Fail    How to get RSSSI not clear
#    ${RSSI_withoutData}    VIVI.GetRSSI
#    VIVI.8445StartDLTraffic
#    Sleep    2s
#    ${RSSI_withData}    VIVI.GetRSSI
#    ${res}    Evaluate    ${RSSI_withoutData}<${RSSI_withData}
#    should be true    ${res}

TC.08_RRH recovery time
    [Documentation]   detail steps
    ...    1. Commission with correct scf and wait onair
    ...    2. Power off RU xxx
    ...    3. Check alarm xxx present in time xxx
    ...    4. Power on RU xxx
    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF_NR_10M}    ${ru_Index}=0
    ${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${scf}    TCID=TC08
    run keyword if  '${scf}'!='NULL'  COAM_Admin.commission  scf_file=${casescf}
    wait until keyword succeeds   15min   1min    COAM_WebEM.VerifyAllCellsAreOnline
    Power.OnOff    pdu_ip=${tl.gnbs[0].dus[0].rus[${ru_Index}].pdu_port.pdu.addr}
    ...    Port_Number=${tl.gnbs[0].dus[0].rus[${ru_Index}].pdu_port.port_no}
    ...    Action=power_off
    ...    model=${tl.gnbs[0].dus[0].rus[${ru_Index}].pdu_port.pdu}
    COAM_WebEM.Login
    wait until keyword succeeds   5min   1min    COAM_WebEM.CheckAlarm  id=7116
    Power.OnOff    pdu_ip=${tl.gnbs[0].dus[0].rus[${ru_Index}].pdu_port.pdu.addr}
    ...    Port_Number=${tl.gnbs[0].dus[0].rus[${ru_Index}].pdu_port.port_no}
    ...    Action=power_on
    ...    model=${tl.gnbs[0].dus[0].rus[${ru_Index}].pdu_port.pdu}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    wait until keyword succeeds   5min   1min    COAM_WebEM.CheckAlarm  id=7116    present=false
    COAM_WebEM.Logout
    [Teardown]   Power.OnOff    pdu_ip=${tl.gnbs[0].dus[0].rus[${ru_Index}].pdu_port.pdu.addr}
    ...    Port_Number=${tl.gnbs[0].dus[0].rus[${ru_Index}].pdu_port.port_no}
    ...    Action=power_on
    ...    model=${tl.gnbs[0].dus[0].rus[${ru_Index}].pdu_port.pdu}

TC.11_Paging
    [Documentation]   detail steps
    ...    1. Commission with correct scf and wait onair
    ...    2. Attach UE and sleep to idle state
    ...    3. Ping UE from Server
    ...    4. Check paging message in CPIF?BIP?
    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF_NR_10M}
    # 10M Testing
    ${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${scf}    TCID=TC11
    run keyword if  '${scf}'!='NULL'  COAM_Admin.commission  scf_file=${casescf}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['dl']}    target_throughput=5M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['ul']}    target_throughput=5M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']}    script_path=ViViScript/
    ${ueip}    Wait Until Keyword Succeeds    3 times    60s    DoAttach    ue_index=0    dail=false
    Sleep    170s
    ${response}    ViVi.FlushOutput
    Should Contain    ${response}    DISCONNECTION IND
    ViVi.Start traffic   ue_index=0    direction=dl
    Sleep    5s
    ${response}    ViVi.FlushOutput
    Should Contain    ${response}    Random Access Complete
    Should Contain    ${response}    CONNECTION IND
    [Teardown]    Run Keyword And Continue On Failure    run keywords    ViVi.Stop traffic    ue_index=0    direction=dl
    ...    AND    ViVi.UE Detach    ue_index=0

TC.11LTE_Paging
    [Documentation]   detail steps
    ...    1. Commission with correct scf and wait onair
    ...    2. Attach UE and sleep to idle state
    ...    3. Ping UE from Server
    ...    4. Check paging message in CPIF?BIP?
    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF_LTE_10M}
    # 10M Testing
    ${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${scf}    TCID=TC11_LTE
    run keyword if  '${scf}'!='NULL'  COAM_Admin.commission  scf_file=${casescf}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['dl']}    target_throughput=5M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['ul']}    target_throughput=5M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']}    script_path=ViViScriptLTE/
    ${ueip}    Wait Until Keyword Succeeds    3 times    60s    DoAttach    ue_index=0    dail=false
    Sleep    170s
    ${response}    ViVi.FlushOutput
    Should Contain    ${response}    DISCONNECTION IND
    ViVi.Start traffic   ue_index=0    direction=dl
    Sleep    5s
    ${response}    ViVi.FlushOutput
    Should Contain    ${response}    Random Access Complete
    Should Contain    ${response}    CONNECTION IND
    [Teardown]    Run Keyword And Continue On Failure    run keywords    ViVi.Stop traffic    ue_index=0    direction=dl
    ...    AND    ViVi.UE Detach    ue_index=0

TC.12_RRC-idle to RRC-connected mode transition using ping from UE side
    [Documentation]   detail steps
    ...    1. Commission with correct scf and wait onair
    ...    2. Attach and wait to Idle state
    ...    3. ping from UE side with 32 bytes and get first ping time
    ...    4. Detach and Check RRC message
    ...    5. Modify BTS parameters
    ...    6. Attach and wait to Idle state
    ...    3. ping from UE side with 1400 bytes and get first ping time
    ...    4. Detach and Check RRC reconnect message
    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF_NR_10M}
    # 10M Testing
    ${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${scf}    TCID=TC12
    run keyword if  '${scf}'!='NULL'  COAM_Admin.commission  scf_file=${casescf}
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['dl']}    target_throughput=5M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['ul']}    target_throughput=5M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']}    script_path=ViViScript/
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    ${ueip}    Wait Until Keyword Succeeds    3 times    60s    DoAttach    ue_index=0    dail=false
    Sleep    170s
    ${response}    ViVi.FlushOutput
    Should Contain    ${response}    DISCONNECTION IND
    ${response}    wait until keyword succeeds   5x   20s    ViVi.DialUp      ue_index=0
    #ViVi.Start traffic   ue_index=0    direction=ul
    #${response}    ViVi.FlushOutput
    Should Contain    ${response}    Random Access Complete
    Should Contain    ${response}    CONNECTION IND
    [Teardown]    Run Keyword And Continue On Failure    ViVi.UE Detach    ue_index=0

TC.12LTE_RRC-idle to RRC-connected mode transition using ping from UE side
    [Documentation]   detail steps
    ...    1. Commission with correct scf and wait onair
    ...    2. Attach and wait to Idle state
    ...    3. ping from UE side with 32 bytes and get first ping time
    ...    4. Detach and Check RRC message
    ...    5. Modify BTS parameters
    ...    6. Attach and wait to Idle state
    ...    3. ping from UE side with 1400 bytes and get first ping time
    ...    4. Detach and Check RRC reconnect message
    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF_LTE_10M}
    # 10M Testing
    ${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${scf}    TCID=TC12
    run keyword if  '${scf}'!='NULL'  COAM_Admin.commission  scf_file=${casescf}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['dl']}    target_throughput=5M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['ul']}    target_throughput=5M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']}    script_path=ViViScriptLTE/
    ${ueip}    Wait Until Keyword Succeeds    3 times    60s    DoAttach    ue_index=0    dail=false
    Sleep    170s
    ${response}    ViVi.FlushOutput
    Should Contain    ${response}    DISCONNECTION IND
    ${response}    wait until keyword succeeds   5x   20s    ViVi.DialUp      ue_index=0
    #ViVi.Start traffic   ue_index=0    direction=ul
    #${response}    ViVi.FlushOutput
    Should Contain    ${response}    Random Access Complete
    Should Contain    ${response}    CONNECTION IND
    [Teardown]    Run Keyword And Continue On Failure    ViVi.UE Detach    ue_index=0

TC.11DSS_Paging
    [Documentation]   detail steps
    ...    1. Commission with correct scf and wait onair
    ...    2. Attach UE and sleep to idle state
    ...    3. Ping UE from Server
    ...    4. Check paging message in CPIF?BIP?
    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF_DSS}
    # 10M Testing
    ${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${scf}    TCID=TC11
    run keyword if  '${scf}'!='NULL'  COAM_Admin.commission  scf_file=${casescf}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['dl']}    target_throughput=80M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['ul']}    target_throughput=65M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']}    script_path=ViViScriptNRDSS/
    ${ueip}    Wait Until Keyword Succeeds    3 times    60s    DoAttach    ue_index=0    dail=false
    Sleep    170s
    ${response}    ViVi.FlushOutput
    Should Contain    ${response}    DISCONNECTION IND
    ViVi.Start traffic   ue_index=0    direction=dl
    Sleep    5s
    ${response}    ViVi.FlushOutput
    Should Contain    ${response}    Random Access Complete
    Should Contain    ${response}    CONNECTION IND
    KW.CheckTP
    [Teardown]    Run Keyword And Continue On Failure    run keywords    ViVi.Stop traffic    ue_index=0    direction=dl
    ...    AND    ViVi.UE Detach    ue_index=0

TC.11DSSLTE_Paging
    [Documentation]   detail steps
    ...    1. Commission with correct scf and wait onair
    ...    2. Attach UE and sleep to idle state
    ...    3. Ping UE from Server
    ...    4. Check paging message in CPIF?BIP?
    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF_DSS}
    # 10M Testing
    ${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${scf}    TCID=TC11_LTE
    run keyword if  '${scf}'!='NULL'  COAM_Admin.commission  scf_file=${casescf}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['dl']}    target_throughput=70M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['ul']}    target_throughput=27M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']}    script_path=ViViScriptLTEDSS/
    ${ueip}    Wait Until Keyword Succeeds    3 times    60s    DoAttach    ue_index=0    dail=false
    Sleep    170s
    ${response}    ViVi.FlushOutput
    Should Contain    ${response}    DISCONNECTION IND
    ViVi.Start traffic   ue_index=0    direction=dl
    Sleep    5s
    ${response}    ViVi.FlushOutput
    Should Contain    ${response}    Random Access Complete
    Should Contain    ${response}    CONNECTION IND
    KW.CheckTP
    [Teardown]    Run Keyword And Continue On Failure    run keywords    ViVi.Stop traffic    ue_index=0    direction=dl
    ...    AND    ViVi.UE Detach    ue_index=0

TC.12DSS_RRC-idle to RRC-connected mode transition using ping from UE side
    [Documentation]   detail steps
    ...    1. Commission with correct scf and wait onair
    ...    2. Attach and wait to Idle state
    ...    3. ping from UE side with 32 bytes and get first ping time
    ...    4. Detach and Check RRC message
    ...    5. Modify BTS parameters
    ...    6. Attach and wait to Idle state
    ...    3. ping from UE side with 1400 bytes and get first ping time
    ...    4. Detach and Check RRC reconnect message
    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF_DSS}
    # 10M Testing
    ${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${scf}    TCID=TC12
    run keyword if  '${scf}'!='NULL'  COAM_Admin.commission  scf_file=${casescf}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['dl']}    target_throughput=80M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['ul']}    target_throughput=65M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']}    script_path=ViViScriptNRDSS/
    ${ueip}    Wait Until Keyword Succeeds    3 times    60s    DoAttach    ue_index=0    dail=false
    Sleep    170s
    ${response}    ViVi.FlushOutput
    Should Contain    ${response}    DISCONNECTION IND
    ${response}    wait until keyword succeeds   5x   20s    ViVi.DialUp      ue_index=0
    #${response}    ViVi.FlushOutput
    Should Contain    ${response}    Random Access Complete
    Should Contain    ${response}    CONNECTION IND
    KW.CheckTP    direction=ul
    [Teardown]    Run Keyword And Continue On Failure    ViVi.UE Detach    ue_index=0

TC.12DSSLTE_RRC-idle to RRC-connected mode transition using ping from UE side
    [Documentation]   detail steps
    ...    1. Commission with correct scf and wait onair
    ...    2. Attach and wait to Idle state
    ...    3. ping from UE side with 32 bytes and get first ping time
    ...    4. Detach and Check RRC message
    ...    5. Modify BTS parameters
    ...    6. Attach and wait to Idle state
    ...    3. ping from UE side with 1400 bytes and get first ping time
    ...    4. Detach and Check RRC reconnect message
    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF_DSS}
    # 10M Testing
    ${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${scf}    TCID=TC12
    run keyword if  '${scf}'!='NULL'  COAM_Admin.commission  scf_file=${casescf}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['dl']}    target_throughput=70M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['ul']}    target_throughput=27M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']}    script_path=ViViScriptLTEDSS/
    ${ueip}    Wait Until Keyword Succeeds    3 times    60s    DoAttach    ue_index=0    dail=false
    Sleep    170s
    ${response}    ViVi.FlushOutput
    Should Contain    ${response}    DISCONNECTION IND
    ${response}    wait until keyword succeeds   5x   20s    ViVi.DialUp      ue_index=0
    #ViVi.Start traffic   ue_index=0    direction=ul
    #${response}    ViVi.FlushOutput
    Should Contain    ${response}    Random Access Complete
    Should Contain    ${response}    CONNECTION IND
    KW.CheckTP    direction=ul
    [Teardown]    Run Keyword And Continue On Failure    ViVi.UE Detach    ue_index=0

KW.CheckTP
    [Arguments]   ${direction}=dl
    Run Keyword And Continue On Failure    run keyword if    '${direction}'=='ul'
    ...    ViVi.Start traffic     ue_index=0    direction=${direction}
    sleep  30
    Run Keyword And Continue On Failure   ViVi.Check throughput   ue_index=0   direction=${direction}
    ViVi.Stop traffic    ue_index=0    direction=${direction}

TC.13_U-Plane Latency 32Bytes / 1400 Bytes, High SINR
    [Documentation]   detail steps
    ...    1)Config parameter
    ...    2)UE attach
    ...    3)Send ping command to server,using 32-bytes
    ...    4)Check buffer size in UE
    ...    5)Check no ping lost in server
    ...    6)Check Minimum, maximum, average RTT times in server,like below:
    ...    7)UE detach and attach again
    ...    8)Repeat step3 to step6 by using 1400-bytes
    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF_NR_10M}
    # 10M Testing
    ${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${scf}    TCID=TC13
    run keyword if  '${scf}'!='NULL'  COAM_Admin.commission  scf_file=${casescf}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']}    script_path=ViViScript/
    ${ueip}    Wait Until Keyword Succeeds    3 times    60s    DoAttach    ue_index=0
    ${loss}    ${first}    ${rtt}    PingAndGetResult    ue_index=0    len=32
    ${loss}    ${first}    ${rtt}    PingAndGetResult    ue_index=0    len=1400
    [Teardown]    Run Keyword And Continue On Failure    ViVi.UE Detach    ue_index=0

TC.13LTE_U-Plane Latency 32Bytes / 1400 Bytes, High SINR
    [Documentation]   detail steps
    ...    1)Config parameter
    ...    2)UE attach
    ...    3)Send ping command to server,using 32-bytes
    ...    4)Check buffer size in UE
    ...    5)Check no ping lost in server
    ...    6)Check Minimum, maximum, average RTT times in server,like below:
    ...    7)UE detach and attach again
    ...    8)Repeat step3 to step6 by using 1400-bytes
    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF_LTE_10M}
    # 10M Testing
    ${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${scf}    TCID=TC15
    run keyword if  '${scf}'!='NULL'  COAM_Admin.commission  scf_file=${casescf}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']}    script_path=ViViScriptLTE/
    ${ueip}    Wait Until Keyword Succeeds    3 times    60s    DoAttach    ue_index=0
    ${loss}    ${first}    ${rtt}    PingAndGetResult    ue_index=0    len=32
    ${loss}    ${first}    ${rtt}    PingAndGetResult    ue_index=0    len=1400
    [Teardown]    Run Keyword And Continue On Failure    ViVi.UE Detach    ue_index=0

TC.14_RRC Connection Reestablishment
    [Documentation]   detail steps
    ...    1)Set radio network configuration/LNCEL parameter in enb
    ...    2)Remove all neighbors in enb
    ...    3)Set Radio Network Configuration/LNBTS parameter
    ...    4)UE attach
    ...    5)Do DL traffic
    ...    6)Degrade the RF connection between the UE and eNB
    ...    7)Quickly remove the additional attenuation
    ...    8)Check RRCConnectionReestablishmentRequest message to the eNB to start the reestablishment procedure
    ...    9)Check DL data continue
    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF_NR_10M}
    # 10M Testing
    ${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${scf}    TCID=TC14
    run keyword if  '${scf}'!='NULL'  COAM_Admin.commission  scf_file=${casescf}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['dl']}    target_throughput=5M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['ul']}    target_throughput=5M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']}    script_path=ViViScript/
    ${ueip}    Wait Until Keyword Succeeds    3 times    60s    DoAttach    ue_index=0    dail=false
    sleep    10s
    ${response}    ViVi.SendScript    filename=ForceSyncLoss.txt    ue_index=0
    sleep    200s
    ${response}    ViVi.FlushOutput
    Should Contain    ${response}    RRC Connection Re-establishment Success
    [Teardown]    Run Keyword And Continue On Failure    ViVi.UE Detach    ue_index=0

TC.14LTE_RRC Connection Reestablishment
    [Documentation]   detail steps
    ...    1)Set radio network configuration/LNCEL parameter in enb
    ...    2)Remove all neighbors in enb
    ...    3)Set Radio Network Configuration/LNBTS parameter
    ...    4)UE attach
    ...    5)Do DL traffic
    ...    6)Degrade the RF connection between the UE and eNB
    ...    7)Quickly remove the additional attenuation
    ...    8)Check RRCConnectionReestablishmentRequest message to the eNB to start the reestablishment procedure
    ...    9)Check DL data continue
    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF_LTE_10M}
    # 10M Testing
    ${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${scf}    TCID=TC12
    run keyword if  '${scf}'!='NULL'  COAM_Admin.commission  scf_file=${casescf}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['dl']}    target_throughput=5M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['ul']}    target_throughput=5M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']}    script_path=ViViScriptLTE/
    ${ueip}    Wait Until Keyword Succeeds    3 times    60s    DoAttach    ue_index=0    dail=false
    sleep    10s
    ${response}    ViVi.SendScript    filename=ForceSyncLoss.txt    ue_index=0
    sleep    200s
    ${response}    ViVi.FlushOutput
    Should Contain    ${response}    RRC Connection Re-establishment Success
    [Teardown]    Run Keyword And Continue On Failure    ViVi.UE Detach    ue_index=0

TC.15_DL TCP single user throughput
    [Documentation]   detail steps
    ...    1)Set the "maximum number of PDCCH symbols"to 1.
    ...    2)Lock all cells except the 5G/4G cell we need to test
    ...    3)set LTE and NR carriers parameter
    ...    4)Set cell resouce parameter
    ...    5)set radio network configuration/LNCEL parameter
    ...    6)Confirm the LNBTS/LNADJGNB are configured to enable sGnb addition
    ...    7)UE attach
    ...    8)Start DL traffic in app server
    ...    9)Check DL TP for 60secs
    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF_NR_10M}    ${direction}=both
    ${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${scf}    TCID=TC06_10M
    run keyword if  '${scf}'!='NULL'  COAM_Admin.commission  scf_file=${casescf}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['dl']}    target_throughput=210M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['ul']}    target_throughput=103M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']}    script_path=ViViScript/
    DoTputCall    direction=${direction}    protocal=TCP

TC.15LTE_DL TCP single user throughput
    [Documentation]   detail steps
    ...    1)Set the "maximum number of PDCCH symbols"to 1.
    ...    2)Lock all cells except the 5G/4G cell we need to test
    ...    3)set LTE and NR carriers parameter
    ...    4)Set cell resouce parameter
    ...    5)set radio network configuration/LNCEL parameter
    ...    6)Confirm the LNBTS/LNADJGNB are configured to enable sGnb addition
    ...    7)UE attach
    ...    8)Start DL traffic in app server
    ...    9)Check DL TP for 60secs
    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF_LTE_10M}    ${direction}=both
    ${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${scf}    TCID=TC06_10M_LTE
    run keyword if  '${scf}'!='NULL'  COAM_Admin.commission  scf_file=${casescf}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['dl']}    target_throughput=182M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['ul']}    target_throughput=34M
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']}    script_path=ViViScriptLTE/
    DoTputCall    direction=${direction}    protocal=TCP
TC.16_UL TCP single user throughput
    [Documentation]   detail steps
    ...    1)Set the "maximum number of PDCCH symbols"to 1.
    ...    2)Lock all cells except the 5G/4G cell we need to test
    ...    3)set LTE and NR carriers parameter
    ...    4)Set cell resouce parameter
    ...    5)set radio network configuration/LNCEL parameter
    ...    6)Confirm the LNBTS/LNADJGNB are configured to enable sGnb addition
    ...    7)UE attach
    ...    8)Start DL traffic in app server
    ...    9)Check DL TP for 60secs
    TC.15_DL TCP single user throughput    direction=ul
TC.16LTE_UL TCP single user throughput
    [Documentation]   detail steps
    ...    1)Set the "maximum number of PDCCH symbols"to 1.
    ...    2)Lock all cells except the 5G/4G cell we need to test
    ...    3)set LTE and NR carriers parameter
    ...    4)Set cell resouce parameter
    ...    5)set radio network configuration/LNCEL parameter
    ...    6)Confirm the LNBTS/LNADJGNB are configured to enable sGnb addition
    ...    7)UE attach
    ...    8)Start DL traffic in app server
    ...    9)Check DL TP for 60secs
    TC.15LTE_DL TCP single user throughput    direction=ul
TC.17_Intra-eNB Handover
    [Documentation]   detail steps
    ...    1. Commission with correct SCF
    ...    2. Attach with dl data transfer
    ...    3. handover
    ...    4. check handover message and throught put
    [Arguments]   ${scf}=${TL_BASE_SCF}
    ${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${scf}    TCID=TC17
    #run keyword if  '${scf}'!='NULL'  COAM_Admin.commission  scf_file=${casescf}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    DoHandoverCall

TC.18_X2 based Handover (intra-frequency)
    [Documentation]   detail steps
    ...    1. Commission with correct SCF
    ...    2. Attach with dl data transfer
    ...    3. handover
    ...    4. check handover message and throught put
    [Arguments]   ${scf}=${TL_BASE_SCF}
    ${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${scf}    TCID=TC18
    #run keyword if  '${scf}'!='NULL'  COAM_Admin.commission  scf_file=${casescf}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    DoHandoverCall

TC.19_S1 based Handover (intra-frequency)
    [Documentation]   detail steps
    ...    1. Commission with correct SCF
    ...    2. Attach with dl data transfer
    ...    3. handover
    ...    4. check handover message and throught put
    [Arguments]   ${scf}=${TL_BASE_SCF}
    ${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${scf}    TCID=TC19
    #run keyword if  '${scf}'!='NULL'  COAM_Admin.commission  scf_file=${casescf}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    DoHandoverCall

TC.20_Attach
    [Documentation]   detail steps
    ...    1. Commission with correct SCF
    ...    2. Attach and check attach success
    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF_NR_10M}    ${direction}=both    ${RetryTimes}=50
    ${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${scf}    TCID=TC06_10M
    run keyword if  '${scf}'!='NULL'  COAM_Admin.commission  scf_file=${casescf}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']}    script_path=ViViScript/
    ${ue_ip}    Wait Until Keyword Succeeds    3 times    60s    DoAttach      ue_index=0    dail=false
    ViVi.UE Detach    ue_index=0
    FOR    ${i}    IN RANGE    ${RetryTimes}
        ${ue_ip}    ViVi.UE Attach     ue_index=0    dail=false
        ViVi.UE Detach    ue_index=0
    END

TC.20_AttachLTE
    [Documentation]   detail steps
    ...    1. Commission with correct SCF
    ...    2. Attach and check attach success
    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF_LTE_10M}    ${direction}=both    ${RetryTimes}=50
    ${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${scf}    TCID=TC06_10M_LTE
    run keyword if  '${scf}'!='NULL'  COAM_Admin.commission  scf_file=${casescf}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both

    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']}    script_path=ViViScriptLTE/

    ${ue_ip}    Wait Until Keyword Succeeds    3 times    60s    DoAttach      ue_index=0    dail=false
    ViVi.UE Detach    ue_index=0
    FOR    ${i}    IN RANGE    ${RetryTimes}
        ${ue_ip}    ViVi.UE Attach     ue_index=0    dail=false
        ViVi.UE Detach    ue_index=0
    END
TC.21_Peak throughput test TCP
    [Documentation]   detail steps
    ...    1. Commission with correct SCF
    ...    2. Call with TCP TPUT and check TPUT
    [Arguments]   ${scf}=${TL_BASE_SCF}
    ${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${scf}    TCID=TC21
    #run keyword if  '${scf}'!='NULL'  COAM_Admin.commission  scf_file=${casescf}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    DoTputCall    protocal=TCP

TC.22_Peak throughput test UDP
    [Documentation]   detail steps
    ...    1. Commission with correct SCF
    ...    2. Call with TCP UDP and check TPUT
    [Arguments]   ${scf}=${TL_BASE_SCF}
    ${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${scf}    TCID=TC22
    #run keyword if  '${scf}'!='NULL'  COAM_Admin.commission  scf_file=${casescf}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    DoTputCall

Log.StartCaptureBip
    log    capture bip
    gNB.Connect
    Precondition for bip capture with gnbMirroring scripts
    Bip Capture with gnbMirroring scripts

Log.CollectBip
    log    collect bip
    ${filename}    Stop BIP capture on ASIK if needed and download BIP Logs to testPC    log_path=${LOG_PATH}
    gNB.Disconnect
    [Return]   ${filename}

Log.CheckMessageInPcap
    [Arguments]    ${filename}=22   ${message}=80     ${filter}=f1ap     ${present}=true
    log     check message
    Wireshark.ReadLog    filename=${filename}    filter=${filter}
    Wireshark.CheckExpression   expression=${message}    present=${present}

Conn.ConnectUEAppServer
    [Arguments]   ${ue_index}=0    ${alias}=UE0APPServer
    Conn.ConnectToDev  ip=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}
    ...    alias=${alias}