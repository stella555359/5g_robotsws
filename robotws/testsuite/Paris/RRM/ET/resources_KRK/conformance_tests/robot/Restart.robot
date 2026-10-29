*** Settings ***
Documentation
...               GNB Restart Management


Library                             taf.sbts.oam.coam.admin           WITH NAME   admin

Resource                            Tools.robot
Resource                            Connect.robot
Resource                            Oam.robot
Resource                            CallSetup.robot
Resource                            Capture.robot
Resource                            Setup.robot
Resource                            Container.robot
#Resource                            ../../../../../testsuite/FRT/resources/robot/common_frt.robot
Library                             ../python/Airscale.py
Variables                           ../python/ReadConfig.py


*** Variables ***
${GNSS_SYNC_SCRIPT}                 gnss_sync.sh                    # Name of script for GNSS synchronization
${WA_GNB_Script}                    WA_GNB_auto.sh                  # Name of script for GNB configuration
${WA_AP_Script}                     WA_AP_auto.sh                   # Name of script for AP configuration

*** Keywords ***
#===================================
# RESTART
#===================================

Restart Gnb Cloud OLD
    [Documentation]                 Restart sequence for case GNB is in cloud megazone configuration
    [Arguments]                     ${GNBCallback}=None
    ...                             ${optOperation}=None                    ${params}=
    OAM Reset Site                  ${AIRSCALE_GNB.oam}
    #following line "OAM Wait site Available" not supported by taf.gnb.oam.coam.cu lib
    OAM Wait Site Available         ${AIRSCALE_GNB.oam}                     callback=${GNBCallback}
    # Airscale Soft Reboot            ${AIRSCALE_GNB}
    # Airscale Soft Reboot            ${AIRSCALE_AP}
    # Airscale Soft Reboot            ${AIRSCALE_GNB}
    WA Airscale Wait for Ready      ${AIRSCALE_AP}
    Run Optional Action             ${optOperation}                         ${params}
    WA Airscale Wait for Ready      ${AIRSCALE_GNB}
    Get TL Info Struct
    Sleep                           60s
    #OAM Check VMs                   ${AIRSCALE_GNB.oam}
    WA DCI Wait For Service         ${AIRSCALE_GNB}
    WA DCI Wait For Service         ${AIRSCALE_AP}
    IRfHead Check Service
    DCI Port Restart If Required
    # Loop until gnss status is OK, fail if MaxLoopRestartAP is reached
    ${MaxLoopRestartAP}             Set Variable                            5
    FOR    ${i}                     IN RANGE        1                       ${MaxLoopRestartAP}
        ${status}                   GNSS Check and run
        run keyword if              '${status}'!='True'                     Airscale Soft Reboot        ${AIRSCALE_AP}
        Exit For Loop If            '${status}'=='True'
    END
    run keyword if                  '${status}'!='True'
    ...                             Fail                                    Max loop of restart AP reached, but unable to sync GNSS
    Run Keyword if                  ${TLConfig.isL1BP}==${True}          Run WA scripts
    F1 Wait Link Cloud

Restart Gnb Classical
    [Documentation]                 Restart sequence for case GNB is in classical configuration
    [Arguments]                     ${GNBCallback}=None                     ${APCallback}=None
    ...                             ${isOAMRebooted}=False
    Dated log                       Restart Gnb Classical :isOAMRebooted=${isOAMRebooted}
    Run Keyword if                  ${isOAMRebooted}==False
    ...                             Airscale Soft Reboot                    ${AIRSCALE_GNB}
    Airscale Soft Reboot            ${AIRSCALE_AP}
    Dated Log                       Waiting for airscales to come back
    sleep                           2m
    ${gnb_status}=                  WA Airscale Wait For Ready              ${AIRSCALE_GNB}
    Run Keyword If                  '${gnb_status}'!='Ready'                Fail    GNB is not ready
    ${ap_status}=                   WA Airscale Wait For Ready              ${AIRSCALE_AP}
    Run Keyword If                  '${gnb_status}'!='Ready'                Fail    AP is not ready
    Get TL Info Struct
    Run Keyword if                  '${GNBCallback}'!='None'                ${GNBCallback}
    Run Keyword if                  '${APCallback}'!='None'                 ${APCallback}
    WA DCI Wait for service         ${AIRSCALE_AP}
    # Skipping Wait for DCI (Feature 6765-D activated on GNB side)
    # WA DCI Wait for service         ${AIRSCALE_GNB}
    F1 Wait Link Classical
    GNSS Check and run
    IRfHead Check Service

Restart Gnb Cloud
    [Documentation]                 Restart sequence for case GNB is in classical configuration
    [Arguments]                     ${GNBCallback}=None                     ${APCallback}=None
    ...                             ${isOAMRebooted}=False
    Dated log                       Restart Gnb Cloud :isOAMRebooted=${isOAMRebooted}
    Run Keyword if                  ${isOAMRebooted}==False
    ...                             Airscale Soft Reboot                    ${AIRSCALE_GNB}
    Airscale Soft Reboot            ${AIRSCALE_AP}
    Dated Log                       Waiting for airscales to come back
    sleep                           2m
    ${gnb_status}=                  WA Airscale Wait For Ready              ${AIRSCALE_GNB}
    Run Keyword If                  '${gnb_status}'!='Ready'                Fail    GNB is not ready
    ${ap_status}=                   WA Airscale Wait For Ready              ${AIRSCALE_AP}
    Run Keyword If                  '${gnb_status}'!='Ready'                Fail    AP is not ready
    Get TL Info Struct
    Run Keyword if                  '${GNBCallback}'!='None'                ${GNBCallback}
    Run Keyword if                  '${APCallback}'!='None'                 ${APCallback}
    WA DCI Wait for service         ${AIRSCALE_AP}
    # Skipping Wait for DCI (Feature 6765-D activated on GNB side)
    # WA DCI Wait for service         ${AIRSCALE_GNB}
    F1 Wait Link Classical
    GNSS Check and run
    IRfHead Check Service

#===================================
# AIRSCALE : reboot and status
#===================================
Airscale Soft Reboot
    [Documentation]                 Execute a reboot on the ASIK of an airscale
    [Arguments]                     ${airscale}
    # Should not use "reboot -f" as it takes a long time to finish (~ 10m)
    # ${command}=                   Set Variable    reboot
    # ${command}=                   Set Variable    sync; reboot
    # ${command}=                   Set Variable    ddal -s ddal_boot_set_reset_loop_count 0; sync; reboot
    ${command}=                     Set Variable    sync;system-module-reboot
    Dated log                       Soft Reboot on ${airscale.name} (command =${command})
    wait until keyword succeeds     1min      20s
    ...                             SSH Wait For Connect and Cmd                readOuput=${False}       command=${command}
    ...                             timeout=20    host=${airscale.entryCard[0]}

WA Airscale Wait for Ready
    [Documentation]                 Wait until all nodes of an airscale are in READY state
    ...                             <airscale> may be one of ${AIRSCALE_GNB} or ${AIRSCALE_AP}
    ...                             List of node ids to check are set in
    ...                             @{airscaleNodeID} or @{AIRPHONE_airscaleNodeID}
    ...                             If timeout is reached and airscale is still not Ready,
    ...                             reboot and try a second time
    [Arguments]                     ${airscale}
    ...                             ${timeout}=600
    ...                             ${every}=30
    ${status}                       Airscale Wait for Ready    ${airscale}    timeout=${timeout}    every=${every}
    Run Keyword If                  '${status}'=='Ready'
    ...                                 Return From Keyword     ${status}
    ${reboot_again}=                Run Keyword If    ('${status}'=='ModuleInfoInvalid' or '${status}'=='Uninitialized')
    ...                                 Set Variable     ${True}
    ...                             ELSE
    ...                                 Set Variable     ${False}
    ${wait_again}=                  Run Keyword If
    ...                             ('${status}'=='ModuleInfoInvalid' or '${status}'=='Uninitialized' or '${status}'=='Rebooting')
    ...                                 Set Variable     ${True}
    ...                             ELSE
    ...                                 Set Variable     ${False}
    Return From Keyword If          (${reboot_again}==${False} and ${wait_again}==${False})
    ...                             ${status}
    Run Keyword If                  ${reboot_again}==${True}
    ...                             Airscale Soft Reboot    ${airscale}
    ${status}=                      Run Keyword If    ${wait_again}==${True}
    ...                             Airscale Wait for Ready    ${airscale}    timeout=${timeout}    every=${every}
    [Return]                        ${status}

Airscale Wait for Ready
    [Documentation]                 Wait until all nodes of an airscale are in READY state or timeout
    [Arguments]                     ${airscale}
    ...                             ${timeout}=600
    ...                             ${every}=30
    ${maxIter}=                     Evaluate     ${timeout} / ${every}
    FOR    ${i}    IN RANGE    1    ${maxIter}
         sleep    ${every}s
         ${status}=    Airscale Check Status    ${airscale}
         Dated Log     Airscale Wait for Ready : status=${status}
         Return From Keyword If    '${status}'=='Ready'    ${status}
    END
    [Return]    ${status}

Airscale Check Status
    [Documentation]                 Compute state of all node ids for an airscale
    ...                             Return : "Ready, "ModuleInfoInvalid", "Uninitialized", "Rebooting"
    ...                                            or the string provided by Airscale.checkAirscaleStatus
    [Arguments]                     ${airscale}
    ${errorStr}                     Set Variable                            ${EMPTY}
    ${alias}                        SSH Wait For Connect                    ${airscale.entryCard[0]}
    # getNodeId generates failures if the Airscale is not fully up
    ${kw_status}    ${nodeId}      Run Keyword And Ignore Error             Airscale.getNodeId    ${alias}
    Dated Log                      kw_status=${kw_status}, nodeId=${nodeId}
    Return From Keyword If         '${kw_status}'!='PASS'                   Rebooting
    Dated Log                      \tStart checkAirscaleStatus (ListNodeId=${airscale.listNodeId}, on nodeId=${nodeId})
    # may get a connection reset here
    ${kw_status}    ${result}      Run Keyword And Ignore Error
    ...                                 Airscale.checkAirscaleStatus        ${alias}    ${nodeId}    @{airscale.listNodeId}
    Return From Keyword If         '${kw_status}'!='PASS'                   Rebooting
    Dated Log                      Result=${result}
    ${status}=                     Run Keyword If    '${result}'=='${EMPTY}'
    ...                                Set Variable    Ready
    ...                            ELSE IF    'NOT EXIST' in "'${result}'"
    ...                                Set Variable    Rebooting
    ...                            ELSE IF    'uninitialized' in "'${result}'"
    ...                                Set Variable    Uninitialized
    ...                            ELSE IF    'moduleInfoValid is FALSE' in "'${result}'"
    ...                                Set Variable    ModuleInfoInvalid
    ...                            ELSE
    ...                                Set Variable    ${result}
    [Return]                        ${status}

#===================================
# DCI
#===================================
WA DCI Wait For Service
    [Documentation]                 Wait until DCI is active on an airscale, if still not after 5 mn,
    ...                             attempt a reboot, wait for ADET ready status, an wait a second time for DCI service to be up
    [Arguments]                     ${airscale}
    # If airscale is AIRPHONE_AP and AP=AP_LO, skip
    ${tag}                          call method             ${TLConfig.topo}
    ...                             getSimuTag
    return from keyword if          '${airscale.hw}'=='AP' and '${tag}'=='AP_LO'
    ${status}                       Run Keyword and return status
    ...                             DCI Wait For Service                        ${airscale}
    Run keyword if                  '${status}'=='False'                        Run Keywords
    ...                             Airscale Soft Reboot                        ${airscale}
    ...     AND                     WA Airscale Wait For Ready                  ${airscale}
    ...     AND                     DCI Wait For Service                        ${airscale}

DCI Wait For Service
    [Documentation]                 Wait until DCI is active on an airscale
    [Arguments]                     ${airscale}
    Dated log                       Waiting for DCI service on ${airscale.name}
    wait until keyword succeeds     5min    20s    DCI Check service            airscale=${airscale}

DCI Check Service
    [Documentation]                 Check the DCI service on an airscale
    ...                             Lead to FAIL if not the case
    [Arguments]                     ${airscale}
    ${output}                       SSH Wait For Connect and Cmd
    ...                             command=systemctl status airphone-dci-link-network-config.service
    ...                             host=${airscale.entryCard[0]}
    Should Contain                  ${output}                               Active: active (exited)
    ${status}                       run keyword and return status
    ...                             Should Contain                  ${output}
    ...                             >>> DCI LINK NETWORK CONF: DCI link network configuration done
    Dated log                       Check : >>> DCI LINK NETWORK CONF: DCI link network configuration done : STATUS=(${status})
    Dated log                       \tDCI service is ACTIVE on ${airscale.name}

DCI Port Restart If Required
    [Documentation]                 Restart DCI service if port 15 is not Up
    ${status}                       Run keyword and return status       DCI Port Check
    Return From Keyword If          '${status}'=='True'
    Dated Log                       CMD=systemctl stop airphone-dci-link-network-config.service
    SSH cmd                         command=systemctl stop airphone-dci-link-network-config.service
    ...                             alias=${AIRSCALE_GNB.entryCard[0].alias}
    Sleep                           2
    Dated Log                       CMD=systemctl restart airphone-dci-link-network-config.service
    SSH cmd                         command=systemctl restart airphone-dci-link-network-config.service
    ...                             alias=${AIRSCALE_GNB.entryCard[0].alias}
    ...                             timeout=600
    DCI Port Check

DCI Port Check
    [Documentation]                 Check port 15 is UP
    ${isUpLines}                    SSH Connect and Cmd
    ...                             command=dbgrrc show port 15 | grep -c "up"
    ...                             host=${AIRSCALE_GNB.entryCard[0]}
    ${isUpLines}                    Strip String        ${isUpLines}
    Should be equal                 ${isUpLines}        1

#===================================
# F1 Link
#===================================
F1 Wait Link Classical
    [Documentation]                 Wait until F1 link is operational (classical case)
    Dated Log                       Check F1 link ...
    wait until keyword succeeds     15 min      20s                          F1 Check Setup Classical

F1 Check Setup Classical
    [Documentation]                 Check F1 is successfully setup (classical case)
    ${log}                          Get Log                                 name=CPRT
    ${result}                       SSH Connect and Cmd
    ...                             command= [[ -f ${log.path} ]] && printf "exists" || printf "missing"
    ...                             host=${AIRSCALE_GNB.sys[0].S}
    ${result2}                      SSH Connect and Cmd
    ...                             command= [[ -f ${log.path}.xz ]] && printf "exists" || printf "missing"
    ...                             host=${AIRSCALE_GNB.sys[0].S}
    ${extractor}                    Set Variable                            xz -d -c
    ${nb}                           Run Keyword If                          '${result}'=='exists'
    ...                             Grep and Check Log                      cmd=cat
    ...                             filepath=${log.path}
    ...    ELSE IF                  '${result2}'=='exists'                  Grep and Check Log
    ...                             cmd=${extractor}
    ...                             filepath=${log.path}.xz
    ...    ELSE                     Run Keywords                            Fail       msg=log not found error
    ...                             AND                                     Dated log
    ...                             ${log.path} Log File NOT found in any of uncompressed or xz format
    ${nb}                           Get Substring                           ${nb}    0    -1
    Dated log                       \tF1 Setup=${nb}
    ${nb_float}                     Convert To Number                       ${nb}
    Should Not Be Equal As Numbers  0      ${nb_float}                      F1 setup not successfull

F1 Check Setup Classical Old
    [Documentation]                 Check F1 is successfully setup (classical case)
    ${log}                          Get Log                                 name=CPRT
    ${result}                       SSH Connect and Cmd
    ...                             command= [[ -f /tmp/${nodeName}/tmp/startup_cp_rt.log ]] && printf "exists" || printf "missing"
    ...                             host=${AIRSCALE_GNB.sys[0].S}
    ${result2}                      SSH Connect and Cmd
    ...                             command= [[ -f /tmp/${nodeName}/tmp/startup_cp_rt.log.xz ]] && printf "exists" || printf "missing"
    ...                             host=${AIRSCALE_GNB.sys[0].S}
    ${extractor}                    Set Variable                            xz -d -c
    ${nb}                           Run Keyword If                          '${result}'=='exists'
    ...                             Grep and Check Log                      cmd=cat
    ...                             filepath=/tmp/${nodeName}/tmp/startup_cp_rt.log
    ...    ELSE IF                  '${result2}'=='exists'                  Grep and Check Log
    ...                             cmd=${extractor}
    ...                             filepath=/ffs/run/logs/CPRT00_aasyslog/startup_cp_rt.log.xz
    ...    ELSE                     Run Keywords                            Fail       msg=log not found error
    ...                             AND                                     Dated log
    ...                             startup_cp_rt Log File NOT found in /ffs/run/logs/CPRT00_aasyslog/ in any of uncompressed or xz format
    ${nb}                           Get Substring                           ${nb}    0    -1
    Dated log                       \tF1 Setup=${nb}
    ${nb_float}                     Convert To Number                       ${nb}
    Should Not Be Equal As Numbers  0      ${nb_float}                      F1 setup not successfull

Grep and Check Log
    [Arguments]                     ${cmd}                                  ${filepath}
    ${nb}                           SSH Connect and Cmd
    ...                             command=${cmd} ${filepath} | grep -ic "f1 setup successful"
    ...                             host=${AIRSCALE_GNB.sys[0].S}
    [Return]                        ${nb}

F1 Wait Link Cloud
    [Documentation]                 Wait until F1 link is operational (cloud case)
    Dated Log                       Check F1 link : F1 Setup (cloud case)
    wait until keyword succeeds     8 min      10s                          F1 Check Setup Cloud

F1 Check Setup Cloud
    [Documentation]                 Check SCTP connections on a F1 link on Cloud cOAM 5gnb Full stack
    ${LogCPRT}                      Get Log                              name=CPRT
    ${nb}                           SSH Connect and Cmd
    ...                             command=cat ${logCPRT.path} |grep -i "F1 setup successfully"
    ...                             host=${AIRSCALE_GNB.sys[0].M}
    Dated log                       \tF1 Setup=${nb}
    Should contain                  ${nb}                                   F1 setup successfully

#===================================
# IRFHEAD
#===================================
IRfHead Check Service
    [Documentation]                 Check IRfHead service is activated
    ${tag}                          call method             ${TLConfig.topo}
    ...                             getSimuTag
    return from keyword if          '${tag}'=='AP_LO'
    Dated Log                       Check IRfHead service is activated
    ${output}                       SSH Connect and Cmd
    ...                             command=ps -edf | grep [i]rfhead
    ...                             host=${AIRSCALE_AP.entryCard[0]}
    Should Not Be Empty             ${output}
    Should Contain                  ${output}                               /opt/airphone_irfhead/IRFHeadExe
    Dated log                       \tIRFHeadExe process is RUNNING
    ${output}                       SSH Connect and Cmd
    ...                             command=systemctl status irfheadexe
    ...                             host=${AIRSCALE_AP.entryCard[0]}
    Should Not Be Empty             ${output}
    Should Contain                  ${output}                               Active: active (exited)
    Dated log                       \tIRFHEAD service is ACTIVE

#===================================
# GNSS
#===================================
GNSS Check and run
    [Documentation]                 Check GNSS status and launch sync script if required
    ...                             a post check is performed in case the sync script is launched
    Dated log                       Check GNSS status (and sync if required)
    ${gnss_status}                  GNSS Check Status
    Run Keyword If                  '${gnss_status}'=='True'
    ...                             Return From keyword      ${gnss_status}
    SSH Run Script                  host=${AIRSCALE_AP.entryCard[0]}                scriptFile=${GNSS_SYNC_SCRIPT}
    ${gnss_status}                  GNSS Check Status
    [Return]                        ${gnss_status}

GNSS Check Status
    [Documentation]                 Launch script to get GNSS status on AP Asik. OK if both commonBcnStatus and btsRtcTimeStatus are OK
    ${check_cmd}                    Set Variable
    ...  /opt/hwmt/python/sendommessage.sh -s 0x04db -d HWATIME-1/CONFIG-1 --proto TIME/config -t query | grep -e commonBcnStatus -e btsRtcTimeStatus
    ${output_stuff}                 csn.execute
    ...                             ${check_cmd}
    ...                             connection=${AIRSCALE_AP.entryCard[0].alias}
    ${checked1}                     Run Keyword And Return Status         Should Contain    ${output_stuff}    commonBcnStatus: EStatus_Ok
    ${checked2}                     Run Keyword And Return Status         Should Contain    ${output_stuff}    btsRtcTimeStatus: EBtsRtcTimeStatus_Ok
    Dated log                       \tGNSS status:commonBcnStatus=${checked1} btsRtcTimeStatus=${checked2}
    ${gnss_status}                  set variable                            False
    ${gnss_status}                  set variable if     '${checked1}'=='True' and '${checked2}'=='True'     True
    [return]                        ${gnss_status}


#===================================
# MISC
#===================================
Run WA scripts
    [Documentation]                 Download and run some WA scripts on ASIK (GNB and AP)
    Dated log                       Running WA Scripts (${WA_GNB_Script} and ${WA_AP_Script})
    SSH Run script                  ${AIRSCALE_GNB.entryCard[0]}                    scriptFile=${WA_GNB_Script}
    SSH Run script                  ${AIRSCALE_AP.entryCard[0]}                     scriptFile=${WA_AP_Script}

