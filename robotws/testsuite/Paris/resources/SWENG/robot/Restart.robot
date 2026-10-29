*** Settings ***
Documentation
...            == Purpose ==
...            Library to manage services related to Restart procedures.
...
...            == Description ==
...            Proposed keywords will offer the following services:
...             - restart the test line
...             - do a soft reboot of an Airscale
...             - wait for the ready state of the Airscale or the F1 link or the DCI Port
...             - get GNSS or IRfHead status
...
...            *Main keywords are:*
...            | =Keyword Name=             | =Param1=        |
...            | Restart TL                 | <isOAMRebooted> |
...            | Airscale Soft Reboot       | <airscale> |
...            | Airscale Wait for Ready    | <airscale> |
...            | WA Airscale Wait for Ready | <airscale> |
...            | WA DCI Wait For Service    | <airscale> |
...            | F1 Wait Link Classical     | <timeout>  |
...            | F1 Wait Link Cloud         | <timeout>  |
...            | F1 Wait Link AIC           | <timeout>  |
...            | IRfHead Check Service      |
...            | GNSS Check and run         |
...

Library                             taf.sbts.oam.coam.admin                WITH NAME   admin
Library                             taf.gnb.oam.coam.vdu.interface.Vdu     WITH NAME   vdu
Library                             taf.gnb.oam.coam.cu                    WITH NAME   cu

Resource                            Tools.robot
Resource                            Connect.robot
Resource                            Oam.robot
Resource                            CallSetup.robot
Resource                            Capture.robot
Resource                            Setup.robot
Resource                            Container.robot

# AIC temporary resource
Resource                            Airframes.robot
Resource                            AicTools.robot

Library                             ../python/Airscales.py
Variables                           ../python/ReadConfig.py


*** Variables ***
${GNSS_SYNC_SCRIPT}                 gnss_sync.sh                    # Name of script for GNSS synchronization
${WA_GNB_Script}                    WA_GNB_auto.sh                  # Name of script for GNB configuration
${WA_AP_Script}                     WA_AP_auto.sh                   # Name of script for AP configuration

*** Keywords ***
#===================================
# RESTART
#===================================
Restart TL
    [Documentation]                 Entry point for the restart of a TL, whatever its configuration.
    ...
    ...                             *Argument details:*
    ...                             - GNBCallback: Optional callback to execute after GNB restart (default None)
    ...                             - APCallback: Optional callback to execute after AP restart (default None)
    ...                             - isOAMRebooted: if True, the GNB_DU is NOT rebooted. Otherwise, it is rebooted. (default False)
    ...                             - F1waitTime: time to wait for F1 link up (default 15min)
    ...
    ...                             Multiple VMwts are supported, and the keyword will clear all WTSs
    ...                             before restarting the GNB and AP.
    ...                             The keyword will also log the number of GNBs and VMwts in the topology.
    ...
    ...                             *Example:*
    ...                             | Restart TL \ \ \ \${GNBCallback}\ \ \ \ \ ${APCallback}\ \ \ \ \ ${isOAMRebooted}\ \ \ \ ${F1waitTime}|
    [Arguments]                     ${GNBCallback}=None                     ${APCallback}=None
    ...                             ${isOAMRebooted}=False                  ${F1waitTime}=15min
    Dated Log                       Start Restart TL ${TLConfig.configName}. Is GNB Cloud: ${TLConfig.isGnbCloud}
    ...                             first=True

    IF    ${nbVMwts} <= 1
    WTS Clear
    ELSE
            FOR    ${idx}       IN RANGE    0    ${nbVMwts}

                    ${host_alias}=         Evaluate    Connect.get_alias_by_index(${idx})    modules=Connect
                    ${host_object}=        Evaluate    Connect.get_host("${host_alias}")    modules=Connect

                    # Dated Log New Line     DEBUG: wts clear idx ${idx} alias >${host_alias}< from Restart TL
                    # Dated Log              DEBUG: wts clear AP idx ${idx} host_object >${host_object}< from Restart TL

                    ${host_object}=        Get From Dictionary    ${Connect.DicHOSTSwts}    ${host_alias}
                    Dated Log              WTS Clear for DicHOSTSwts[key:${host_alias}}] => ${host_object}
                    WTS Clear mwts         ${idx}    host=${host_object}
            END
    END

    Run Keyword if                  ${isClassical}
    ...                             Restart Gnb Classical
    ...                                 GNBCallback=${GNBCallback}          APCallback=${APCallback}
    ...                                 isOAMRebooted=${isOAMRebooted}      F1waitTime=${F1waitTime}
    Run Keyword if                  ${isAic}
    ...                             Restart Gnb Aic
    ...                                 GNBCallback=${GNBCallback}          APCallback=${APCallback}
#    ...                                 optOperation=${optOperation}        params=${params}
    ...                                 isOAMRebooted=${isOAMRebooted}      F1waitTime=${F1waitTime}

    Dated Log                       Restart TL is perhaps due to SCF modification => Global variables update
    Get TL Info From Oam            entity=${TGNB_DU[${0}]}
    OAM Build FDD TDD Cells Dict

Restart Gnb Classical
    [Documentation]                 INTERNAL USAGE
    ...                             Restart sequence for case GNB is in classical configuration
    [Arguments]                     ${GNBCallback}=None                     ${APCallback}=None
    ...                             ${isOAMRebooted}=False                  ${F1waitTime}=15min
    Dated log                       Restart Gnb Classical :isOAMRebooted=${isOAMRebooted}
    Run Keyword if                  ${isOAMRebooted}==False
    ...                             Airscale Soft Reboot                    ${GNB_DU}
    WA DCI link drop
    Airscale Soft Reboot            ${AP_DU}
    Dated Log                       Waiting for airscales to come back
    sleep                           2m
    ${gnb_status}=                  WA Airscale Wait For Ready              ${GNB_DU}
    Run Keyword If                  '${gnb_status}'!='Ready'                Fail    GNB is not ready
    ${ap_status}=                   WA Airscale Wait For Ready              ${AP_DU}
    Run Keyword If                  '${gnb_status}'!='Ready'                Fail    AP is not ready
    Get TL Info Struct
    Run Keyword if                  '${GNBCallback}'!='None'                ${GNBCallback}
    Run Keyword if                  '${APCallback}'!='None'                 ${APCallback}
    WA DCI Wait for service         ${AP_DU}
    # Skipping Wait for DCI (Feature 6765-D activated on GNB side)
    # WA DCI Wait for service         ${GNB_DU}
    F1 Wait Link Classical          timeout=${F1waitTime}
    GNSS Check and run
    IRfHead Check Service

WA DCI link drop
    Dated Log                       WA DCI link drop
    ${alias}                        SSH Connect                          ${AP_DU.sys[0].M}
    ${file}                         SSH Cmd                              command=ddal -s ddal_boot_set_reset_loop_count 0
    ...                             alias=${alias}

Restart Gnb Cloud
    [Documentation]                 INTERNAL USAGE
    ...                             Restart sequence for case GNB is in Cloud configuration
    [Arguments]                     ${GNBCallback}=None                     ${APCallback}=None
    ...                             ${isOAMRebooted}=False                  ${F1waitTime}=15min
#    ...                             ${optOperation}=None                    ${params}=

    Dated log                       Restart Gnb Cloud :isOAMRebooted=${isOAMRebooted}
    Run Keyword if                  ${isOAMRebooted}==False
    ...                             Airscale Soft Reboot                    ${GNB_DU}
    Airscale Soft Reboot            ${AP_DU}
    CU Restart
    Dated Log                       Waiting for airscales to come back
    sleep                           2m
    ${cu_status}=                   CU Wait For Ready
    Run Keyword If                  '${cu_status}'!='Ready'                 Fail    CU is not ready
    ${gnb_status}=                  WA Airscale Wait For Ready              ${GNB_DU}
    Run Keyword If                  '${gnb_status}'!='Ready'                Fail    GNB is not ready
    ${ap_status}=                   WA Airscale Wait For Ready              ${AP_DU}
    Run Keyword If                  '${gnb_status}'!='Ready'                Fail    AP is not ready
    Get TL Info Struct
    Run Keyword if                  '${GNBCallback}'!='None'                ${GNBCallback}
    Run Keyword if                  '${APCallback}'!='None'                 ${APCallback}
    WA DCI Wait for service         ${AP_DU}
    # Skipping Wait for DCI (Feature 6765-D activated on GNB side)
    # WA DCI Wait for service         ${GNB_DU}
    F1 Wait Link Classical           timeout=${F1waitTime}
    GNSS Check and run
    IRfHead Check Service

Restart Vcu And Vdu
    [Documentation]                 INTERNAL USAGE
    ...                             Restart VCU then VDU

    Dated log                       Restart Vcu And Vdu
    Call method                     ${GNB_CU.oam}    startReset
    Call method                     ${GNB_DU.oam}    startReset

Wait Vcu And Vdu Available
    [Documentation]                 INTERNAL USAGE
    ...                             Wait VCU and VDU to be ready

    Dated Log                       Waiting for VCU & VDU to come back: Just sleep 3min
    sleep                           3m

Restart Airphone
    [Documentation]                 INTERNAL USAGE
    ...                             Wait Airphone to be ready

    Airscale Soft Reboot            ${AP_DU}

Wait Airphone Available
    [Documentation]                 INTERNAL USAGE
    ...                             Wait Airphone to be ready

    Dated Log                       Waiting for Airphone to come back

    # "DCI Wait for service" cannot be used as it looks for "systemctl status airphone-dci-link-network-config.service" which
    # does not exist for AIC --> use of "Airscale Wait for Ready" which has 10m timeout

    Airscale Wait For Ready          ${AP_DU}

#Remove And Create Ruproxy Pod
#    [Documentation]                 INTERNAL USAGE
#    ...                             Remove then re-create the RU proxy pod on FHGW
#    ## Normally below KW should be call in "teardown" step
#    Remove ruproxy Pod
#    sleep                          10s
#    ## recreate proxy on Vdu (no effect if there are already running processes)
#    Create ruproxy Pod

Restart Gnb Aic
    [Documentation]                 INTERNAL USAGE
    ...                             Restart sequence for case GNB is in AIC
    [Arguments]                     ${GNBCallback}=None                     ${APCallback}=None
    ...                             ${isOAMRebooted}=False                  ${F1waitTime}=15min
#    ...                             ${optOperation}=None                    ${params}=

    Dated log                       Restart Gnb AIC: isOAMRebooted=${isOAMRebooted}
    Restart Vcu And Vdu
#    Run Keyword If                  '${duplexMode}'=='FDD'                  Remove And Create Ruproxy Pod
    Wait Vcu And Vdu Available
    Restart Airphone
    Run Keyword if                  '${GNBCallback}'!='None'                ${GNBCallback}
    Run Keyword if                  '${APCallback}'!='None'                 ${APCallback}
    Wait Airphone Available
    # Run sync command on AP (not sure if it's really needed --> TBC)
    Run Keyword if                  '${duplexMode}'=='FDD'                  Run Sync Command On AP
#    Run Keyword If                  '${duplexMode}'=='FDD'                  Check FHGW MRI States       "2"
    F1 Wait Link AIC                timeout=${F1waitTime}
    Get TL Info Struct
    GNSS Check and run
#    Run Keyword if                  '${duplexMode}'=='FDD'                  Adding DCI BIP route in vDU L2RT

#===================================
# AIRSCALE : reboot and status
#===================================
Restart Vcu
    [Documentation]                 INTERNAL USAGE
    ...                             To restart only VCU
    Call method    ${GNB_CU.oam}    startReset
    OAM wait available              oam=${GNB_CU.oam}    wait_time=300

Restart Vdu
    [Documentation]                 INTERNAL USAGE
    ...                             To restart only VDU
    Call method    ${GNB_DU.oam}    startReset
    OAM wait available              oam=${GNB_DU.oam}    wait_time=300

CU Restart
    [Documentation]                 INTERNAL USAGE
    ...                             Execute a reboot on the CU of a testline.
    Dated log                       CU Restart
    ${command}=                     Set Variable    sudo reboot
    wait until keyword succeeds     1min    20s
    ...                             SSH Wait For Connect and Cmd                readOuput=${False}
    ...                             command=${command}                          timeout=20
    ...                             host=${GNB_CU.oam}
    sleep                           10s

CU Wait For Ready
    [Documentation]                 INTERNAL USAGE
    ...                             Wait until the CU is in ready state or timeout
    [Arguments]                     ${timeout}=180
    ...                             ${sleepTime}=10
    Dated log                       CU Wait For Ready
    # loop checking if the CU is back
    ${maxIter}=                         Evaluate     ${timeout} / ${sleepTime}
    FOR    ${i}    IN RANGE    1    ${maxIter}
         sleep                          ${sleepTime}s
         ${kwStatus}    ${cmdOutput}    Run Keyword And Ignore Error
         ...                            SSH Connect and Cmd
         ...                            command=who
         ...                            host=${GNB_CU.oam}
         Return From Keyword If         '${kwStatus}'=='PASS'                   Ready
    END
    [Return]                        NotReady


Airscale Soft Reboot
    [Documentation]                 Execute a reboot on the ASIx board in the specified Airscale
    ...
    ...                             *Argument details:*
    ...                             - airscale: may be GNB_DU or AP_DU
    [Arguments]                     ${airscale}
    ${command}=                     Set Variable    sync;system-module-reboot
    Dated log                       Soft Reboot on ${airscale.name} (command =${command})
    wait until keyword succeeds     1min      20s
    ...                             SSH Wait For Connect and Cmd                readOuput=${False}       command=${command}
    ...                             timeout=20    host=${airscale.entryCard[0]}
    csn.reset_cache

WA Airscale Wait for Ready
    [Documentation]                 Wait until all nodes of an Airscale are in READY state.
    ...                             If timeout is reached and Airscale is still not Ready, reboot and try a second time.
    ...
    ...                             The keyword returns the Airscale status:
    ...                             "Ready, "ModuleInfoInvalid", "Uninitialized", "Rebooting"
    ...                             or the string provided by Airscales.checkAirscaleStatus
    ...
    ...                             *Argument details:*
    ...                             - airscale: may be GNB_DU or AP_DU
    [Arguments]                     ${airscale}
    ...                             ${timeout}=600
    ...                             ${every}=10
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
    [Documentation]                 Wait until all nodes of an Airscale are in READY state or timeout
    ...
    ...                             The keyword returns the Airscale status:
    ...                             "Ready, "ModuleInfoInvalid", "Uninitialized", "Rebooting"
    ...                             or the string provided by Airscales.checkAirscaleStatus
    ...
    ...                             *Argument details:*
    ...                             - airscale: may be GNB_DU or AP_DU
    [Arguments]                     ${airscale}
    ...                             ${timeout}=600
    ...                             ${every}=10
    ${maxIter}=                     Evaluate     ${timeout} / ${every}
    FOR    ${i}    IN RANGE    1    ${maxIter}
         sleep    ${every}s
         ${status}=    Airscale Check Status    ${airscale}
         Dated Log     Airscale Wait for Ready : status=${status}
         Return From Keyword If    '${status}'=='Ready'    ${status}
    END
    [Return]    ${status}

Airscale Check Status
    [Documentation]                 INTERNAL USAGE
    ...                             Compute state of all node ids for an airscale
    ...
    ...                             The keyword returns the Airscale status:
    ...                             "Ready, "ModuleInfoInvalid", "Uninitialized", "Rebooting"
    ...                             or the string provided by Airscales.checkAirscaleStatus
    ...
    ...                             *Argument details:*
    ...                             - airscale: may be GNB_DU or AP_DU
    [Arguments]                     ${airscale}
    ${errorStr}                     Set Variable                            ${EMPTY}
    ${alias}                        SSH Wait For Connect                    ${airscale.entryCard[0]}
    # getNodeId generates failures if the Airscale is not fully up
    ${kw_status}    ${nodeId}       Run Keyword And Ignore Error            Airscales.getNodeId    ${alias}
    Dated Log                       kw_status=${kw_status}, nodeId=${nodeId}
    Return From Keyword If          '${kw_status}'!='PASS'                   Rebooting
    Dated Log                       \tStart checkAirscaleStatus (ListNodeId=${airscale.listNodeId}, on nodeId=${nodeId})
    # may get a connection reset here
    ${kw_status}    ${result}       Run Keyword And Ignore Error
    ...                                 Airscales.checkAirscaleStatus        ${alias}    ${nodeId}    @{airscale.listNodeId}
    Return From Keyword If          '${kw_status}'!='PASS'                   Rebooting
    # Dated Log                       Result=${result}
    ${status}=                      Run Keyword If    '${result}'=='${EMPTY}'
    ...                                 Set Variable    Ready
    ...                             ELSE IF    'NOT EXIST' in "'${result}'"
    ...                                 Set Variable    Rebooting
    ...                             ELSE IF    'uninitialized' in "'${result}'"
    ...                                 Set Variable    Uninitialized
    ...                             ELSE IF    'moduleInfoValid is FALSE' in "'${result}'"
    ...                                 Set Variable    ModuleInfoInvalid
    ...                             ELSE
    ...                                 Set Variable    ${result}
    [Return]                        ${status}

#===================================
# DCI
#===================================
WA DCI Wait For Service
    [Documentation]                 Wait until DCI is active on an Airscale.
    ...                             If still not after 5 mn, attempt a reboot, wait for ADET ready status,
    ...                             and wait a second time for DCI service to be up.
    ...
    ...                             *Argument details:*
    ...                             - airscale: may be GNB_DU or AP_DU
    [Arguments]                     ${airscale}
    # If airscale is AIRPHONE_AP and AP=AP_LO, skip
    ${tag}                          call method             ${TLConfig.topo}
    ...                             getSimuTag
    return from keyword if          '${airscale.hw}'=='AP' and '${tag}'=='AP_LO'
    return from keyword if          '${airscale.hw}'=='AP' and '${tag}'=='AP_LOO'
    return from keyword if          '${airscale.hw}'=='AP' and '${tag}'=='AP_LOOO'
    ${status}                       Run Keyword and return status
    ...                             DCI Wait For Service                        ${airscale}
    Run keyword if                  '${status}'=='False'                        Run Keywords
    ...                             Airscale Soft Reboot                        ${airscale}
    ...     AND                     WA Airscale Wait For Ready                  ${airscale}
    ...     AND                     DCI Wait For Service                        ${airscale}

DCI Wait For Service
    [Documentation]                 INTERNAL USAGE
    ...                             Wait until DCI is active on an airscale
    ...
    ...                             *Argument details:*
    ...                             - airscale: may be GNB_DU or AP_DU
    [Arguments]                     ${airscale}
    Dated log                       Waiting for DCI service on ${airscale.name}
    wait until keyword succeeds     5min    20s    DCI Check service            airscale=${airscale}

DCI Check Service
    [Documentation]                 INTERNAL USAGE
    ...                             Check the DCI service on an airscale
    ...                             Lead to FAIL if not the case
    ...
    ...                             *Argument details:*
    ...                             - airscale: may be GNB_DU or AP_DU
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
    [Documentation]                 INTERNAL USAGE
    ...                             Restart DCI service if port 15 is not Up.
    ${status}                       Run keyword and return status       DCI Port Check
    Return From Keyword If          '${status}'=='True'
    Dated Log                       CMD=systemctl stop airphone-dci-link-network-config.service
    SSH cmd                         command=systemctl stop airphone-dci-link-network-config.service
    ...                             alias=${GNB_DU.entryCard[0].alias}
    Sleep                           2
    Dated Log                       CMD=systemctl restart airphone-dci-link-network-config.service
    SSH cmd                         command=systemctl restart airphone-dci-link-network-config.service
    ...                             alias=${GNB_DU.entryCard[0].alias}
    ...                             timeout=600
    DCI Port Check

DCI Port Check
    [Documentation]                 INTERNAL USAGE
    ...                             Check port 15 is UP
    ${isUpLines}                    SSH Connect and Cmd
    ...                             command=dbgrrc show port 15 | grep -c "up"
    ...                             host=${GNB_DU.entryCard[0]}
    ${isUpLines}                    Strip String        ${isUpLines}
    Should be equal                 ${isUpLines}        1

#===================================
# F1 Link
#===================================

F1 Wait Link Classical
    [Documentation]                 Wait until F1 link is operational (classical case).
    ...
    ...                             *Argument details:*
    ...                             - F1waitTime: time to wait for F1 link up (default 15min)
    [Arguments]                     ${timeout}=15min
    Dated Log                       Check F1 link in progress (Classical case - Best effort)
    Run keyword and ignore error    Check F1 Link With Best Effort          ${timeout}

Check F1 Link With Best Effort
    [Documentation]                 INTERNAL USAGE
    [Arguments]                     ${timeout}
    wait until keyword succeeds     ${timeout}      20s                     F1 Check Setup Classical New

F1 Check Setup Classical New
    [Documentation]                 INTERNAL USAGE
    ...                             Check if F1 is successfully setup.
    ...                             If analyzed file is compressed, then a last check is done and then F1 check loop is stopped.
    ${f1_pattern}                   set variable                            F1 setup successfully
    ${log}                          Get Log                                 name=CPRT
    Node Log Update Name            ${log}
    ${host}                         call method                             ${GNB_DU}
    ...                             getSysSlaveHost
    ${alias}                        SSH Connect                             host=${host}
    ${nb}                           SSH Cmd                                 command= xzgrep -ic "${f1_pattern}" ${log.path}
    ...                                                                     alias=${alias}
    ${nb}                           Set variable                            ${nb.replace("\n","").replace("\r","")}
    Dated log                       \tF1 Setup=${nb}

    # ONLY FOR DEBUG - THE TWO FOLLOWING LINES SHOULD BE REMOVED BEFORE FINAL DELIVERY
    # Dated log                       \t>>>>>>> RDH debug : F1 status is forced to OFF
    # ${nb}                           set variable                            0

    ${nb_float}                     Convert To Number                       ${nb}
    ${log_is_zipped}=               Run Keyword And Return Status           Should Contain              ${log.path}     .xz
    Run Keyword If                  ${log_is_zipped}                        F1 Log File Is Compressed   ${log}          ${f1_pattern}
    ...         ELSE                Should Not Be Equal As Numbers          0       ${nb_float}         F1 setup not successfully

F1 Log File Is Compressed
    [Documentation]                 INTERNAL USAGE
    ...                             Will do a last check on compressed file and then F1 check loop is stopped.
    [Arguments]                     ${log}      ${f1_pattern}
    Dated log                       \t>>>>> WARNING: The CPRT log file is compressed => this means it is the end of F1 Setup Check.
    Traced Sleep                    20                                      msg="the last F1 Setup Check"
    ${host}                         call method                             ${GNB_DU}
    ...                             getSysSlaveHost
    ${alias}                        SSH Connect                             host=${host}
    ${nb}                           SSH Cmd                                 command= xzgrep -ic "${f1_pattern}" ${log.path}
    ...                                                                     alias=${alias}
    ${nb}                           Set variable                            ${nb.replace("\n","").replace("\r","")}
    ${nb_float}                     Convert To Number                       ${nb}
    Run keyword if                  ${nb_float}==0
    ...                             Dated log New Line                      \tWARNING: F1 Setup Was Not Found But We Continue In Best Effort.
    ...         ELSE                Dated log New Line                      \tGOOD NEWS: the F1 Setup Status Was Found In The Compressed Log File.

Grep and Check Log
    [Documentation]                 INTERNAL USAGE
    [Arguments]                     ${alias}
    ...                             ${cmd}
    ...                             ${filepath}
    ${nb}                           SSH Cmd
    ...                             command=${cmd} ${filepath} | grep -ic "f1 setup successful"
    ...                             alias=${alias}
    [Return]                        ${nb}

F1 Wait Link Cloud
    [Documentation]                 Wait until F1 link is operational (Cloud case)
    ...                             *Argument details:*
    ...                             - F1waitTime: time to wait for F1 link up (default 15min)
    [Arguments]                     ${timeout}=15min
    Dated Log                       Check F1 link in progress (cloud case)
    wait until keyword succeeds     ${timeout}      10s                          F1 Check Setup Cloud

F1 Check Setup Cloud
    [Documentation]                 INTERNAL USAGE
    ...                             Check SCTP connections on a F1 link on Cloud cOAM 5gNB Full stack
    ${LogCPRT}                      Get Log                              name=CPRT
    ${nb}                           SSH Connect and Cmd
    ...                             command=cat ${logCPRT.path} |grep -i "F1 setup successfully"
    ...                             host=${GNB_DU.sys[0].M}
    Dated log                       \tF1 Setup=${nb}
    Should contain                  ${nb}                                   F1 setup successfully

F1 Check Setup AIC
    [Documentation]                 INTERNAL USAGE
    ...                             Check F1 link on AIC DU
    ${vdu_state_data}               Call method    ${GNB_DU.oam}    getVduStateData
    ${vdu_f1_status}                Set Variable    ${vdu_state_data}[f1_c_link_status_du]
    Dated log                       F1 link status = ${vdu_f1_status}
    should be true                  "${vdu_f1_status}"=="available"

F1 Wait Link AIC
    [Documentation]                 Wait until F1 link is operational (AIC case)
    ...                             *Argument details:*
    ...                             - F1waitTime: time to wait for F1 link up (default 15min)
    [Arguments]                     ${timeout}=15min
    Dated Log                       Check F1 link in progress (AIC case)
    wait until keyword succeeds     ${timeout}      10s      F1 Check Setup AIC

#===================================
# IRFHEAD
#===================================
IRfHead Check Service
    [Documentation]                 Check IRfHead service is active
    ${tag}                          call method             ${TLConfig.topo}
    ...                             getSimuTag
    return from keyword if          '${tag}'=='AP_LO' or '${tag}'=='AP_LOO' or '${tag}'=='AP_LOOO'
    Dated Log                       Check IRfHead service is activated
    ${output}                       SSH Connect and Cmd
    ...                             command=ps -edf | grep [i]rfhead
    ...                             host=${AP_DU.entryCard[0]}
    Should Not Be Empty             ${output}
    Should Contain                  ${output}                               /opt/airphone_irfhead/IRFHeadExe
    Dated log                       \tIRFHeadExe process is RUNNING
    ${output}                       SSH Connect and Cmd
    ...                             command=systemctl status irfheadexe
    ...                             host=${AP_DU.entryCard[0]}
    Should Not Be Empty             ${output}
    Should Contain                  ${output}                               Active: active (exited)
    Dated log                       \tIRFHEAD service is ACTIVE

#===================================
# GNSS
#===================================
GNSS Check and run
    [Documentation]                 Check GNSS status and launch gnss sync script if required.
    ...                             A post check is performed in case the sync script is launched.
    ...
    ...                             The keyword returns the GNSS Status.
    Dated log                       Check GNSS status (and sync if required)
    ${gnss_status}                  GNSS Check Status
    Run Keyword If                  '${gnss_status}'=='True'
    ...                             Return From keyword      ${gnss_status}
    SSH Run Script                  host=${AP_DU.entryCard[0]}              scriptFile=${GNSS_SYNC_SCRIPT}
    ${gnss_status}                  GNSS Check Status
    [Return]                        ${gnss_status}

GNSS Check Status
    [Documentation]                 INTERNAL USAGE
    ...                             Launch script to get GNSS status on AP Asik.
    ...                             OK if both commonBcnStatus and btsRtcTimeStatus are OK.
    ...
    ...                             The keyword returns the GNSS Status.

    ${check_cmd}                    Set Variable
    ...  /opt/hwmt/python/sendommessage.sh -s 0x04db -d HWATIME-1/CONFIG-1 --proto TIME/config -t query | grep -e commonBcnStatus -e btsRtcTimeStatus
    ${output_stuff}                 SSH Connect and Exec                    command=${check_cmd}
    ...                             host=${AP_DU.entryCard[0]}
    ${checked1}                     Run Keyword And Return Status
    ...                                 Should Contain    ${output_stuff}   commonBcnStatus: EStatus_Ok
    ${checked2}                     Run Keyword And Return Status
    ...                                 Should Contain    ${output_stuff}   btsRtcTimeStatus: EBtsRtcTimeStatus_Ok
    Dated log                       \tGNSS status:commonBcnStatus=${checked1} btsRtcTimeStatus=${checked2}
    ${gnss_status}                  set variable                            False
    ${gnss_status}                  set variable if                         '${checked1}'=='True' and '${checked2}'=='True'     True
    [return]                        ${gnss_status}

Run Sync Command On AP
    [Documentation]                 INTERNAL USAGE
    ...                             Run sync command on Airphone

    ${sync_cmd}                    Set Variable
    ...  /opt/hwmt/python/sendommessage.sh -s 0x04dc -d HWASYNC-1/CLOCKOUTPUTS-1/SYNCOUT-1 --proto SYNC/sync_out - t query
    ${output}                      SSH Connect and Exec                    command=${sync_cmd}
    ...                            host=${AP_DU.entryCard[0]}
    Dated Log                      sync_out command output = ${output}
