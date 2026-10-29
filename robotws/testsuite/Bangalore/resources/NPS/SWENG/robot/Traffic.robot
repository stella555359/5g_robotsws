*** Settings ***
Documentation                       Module to manage Keywords for Uplink and/or Downlink Traffic
...                                 Main Keywords are :
...                                 - Traffic UE DL    : Launch a DL traffic session
...                                 - Traffic UE UL    : Launch a UL traffic session
...                                 - Traffic UE UL DL : Launch a UL+DL traffic session

Library                             taf.transport.ssh                 WITH NAME    csn
Library                             taf.wts.runner                    WITH NAME    wtsemu

#Resource                            Capture.robot
Resource                            Tools.robot

*** Keywords ***
#===================================
# TRAFFIC Mono UE (UL/DL/UL+DL)
#===================================
Traffic UE DL
    [Documentation]                 Start the DL data traffic during a particular <duration>, then stop it
    ...                             A check is performed to verify obtained traffic rate is in line with expected one
    ...                             Optionnaly, a capture can be launched during first second of traffic (BIP Messages for instance)
    [Arguments]                     ${ueSetting}=${UE_NO_PROFILE}           # Reference to UE Settings
    ...                             ${throughput}=${NO_THROUGHPUT}          # Traffic in Mega
    ...                             ${captureCallback}=None                 # Reference to a KW call back or None
    ...                             ${capture}=None                         # Associated <Capture> structure if Callback is provided
    ...                             ${captureDuration}=1000ms               # Duration between statand stop of capture
    ...                             ${duration}=60s                         # Duration of Traffic
    ...                             ${shouldBeStop}=True                    # Indicate if traffic should be stopped
    ...                             ${deviation}=1                          # Indicate deviation in percentage
    ...                             ${shouldBeCheck}=${True}                # Indicate if traffic check is needed
    Traffic UE                      ueSetting=${ueSetting}                  dir=dl
    ...                             captureCallback=${captureCallback}      capture=${capture}
    ...                             captureDuration=${captureDuration}      throughput=${throughput}
    ...                             duration=${duration}                    shouldBeStop=${shouldBeStop}
    ...                             deviation=${deviation}                  shouldBeCheck=${shouldBeCheck}

Traffic UE UL
    [Documentation]                 Start the UL data traffic during a particular <duration>, then stop it
    ...                             A check is performed to verify obtained traffic rate is in line with expected one
    ...                             Optionnaly, a capture can be launched during first second of traffic (BIP Messages for instance)
    [Arguments]                     ${ueSetting}=${UE_NO_PROFILE}           # Reference to UE Settings
    ...                             ${throughput}=${NO_THROUGHPUT}          # Traffic en Mega
    ...                             ${captureCallback}=None                 # Reference to a KW call back or None
    ...                             ${capture}=None                         # Associated <Capture> structure if Callback is provided
    ...                             ${captureDuration}=1000ms               # Duration between statand stop of capture
    ...                             ${duration}=60s                         # Duration of Traffic
    ...                             ${shouldBeStop}=True                    # Indicate if traffic should be stopped
    ...                             ${deviation}=1                          # Indicate deviation in percentage
    ...                             ${shouldBeCheck}=${True}                # Indicate if traffic check is needed
    Traffic UE                      ueSetting=${ueSetting}                  dir=ul
    ...                             captureCallback=${captureCallback}      capture=${capture}
    ...                             captureDuration=${captureDuration}      throughput=${throughput}
    ...                             duration=${duration}                    shouldBeStop=${shouldBeStop}
    ...                             deviation=${deviation}                  shouldBeCheck=${shouldBeCheck}

Traffic UE
    [Documentation]                 Start the DL or UL data traffic during a particular <duration>, then stop it
    ...                             A check is performed to verify obtained traffic rate is in line with expected one
    ...                             Optionnaly, a capture can be launched during first second of traffic (BIP Messages for instance)
    [Arguments]                     ${ueSetting}=${UE_NO_PROFILE}           # Reference to UE Settings
    ...                             ${dir}=ul                               # Traffic direction : ul or dl
    ...                             ${throughput}=${NO_THROUGHPUT}          # Traffic en Mega
    ...                             ${captureCallback}=None                 # Reference to a KW call back or None
    ...                             ${capture}=None                         # Associated <Capture> structure if Callback is provided
    ...                             ${captureDuration}=1000ms               # Duration between statand stop of capture
    ...                             ${duration}=60s                         # Duration of Traffic
    ...                             ${shouldBeStop}=True                    # Indicate if traffic should be stopped
    ...                             ${deviation}=1                          # Indicate deviation in percentage
    ...                             ${shouldBeCheck}=${True}                # Indicate if traffic check is needed
    ${alias}                        SSH Wait for connect                    host=${HOST_EPCSIM}
    Traffic Start                   ueSetting=${ueSetting}                  dir=${dir}                  throughput=${throughput}
    Sleep                           3s
    Traffic Clear Stats             ueSetting=${ueSetting}                  dir=${dir}
    Callback Run Capture            callback=${captureCallback}             capture=${capture}          duration=${captureDuration}
    Traced Sleep                    ${duration}
    Traffic Check if required       ueSetting=${ueSetting}                  dir=${dir}
    ...                             throughput=${throughput}                shouldBeCheck=${shouldBeCheck}
    ...                             deviation=${deviation}                  shouldBeError=${True}
    [Teardown]                      Run Keyword if                          '${shouldBeStop}'=='True'
    ...                             Traffic Stop                            ueSetting=${ueSetting}      dir=${dir}

Traffic UE UL DL
    [Documentation]                 Start a UL and DL data traffic during a particular <duration>, then stop it
    ...                             A check is performed to verify obtained traffic rate is in line with expected one
    ...                             Optionnaly, a capture can be launched during first second of traffic (BIP Messages for instance)
    [Arguments]                     ${ueSetting}=${UE_NO_PROFILE}           # Reference to UE Settings
    ...                             ${throughput}=${NO_THROUGHPUT}          # Traffic en Mega
    ...                             ${captureCallback}=None                 # Reference to a KW call back or None
    ...                             ${capture}=None                         # Associated <Capture> structure if Callback is provided
    ...                             ${captureDuration}=1000ms               # Duration between statand stop of capture
    ...                             ${duration}=60s                         # Duration of Traffic
    ...                             ${deviation}=1                          # indicate deviation in percentage
    ...                             ${shouldBeCheck}=${True}                # Indicate if traffic check is needed
    ${alias}                        SSH Wait for connect                    host=${HOST_EPCSIM}
    Traffic Start                   ueSetting=${ueSetting}                  dir=ul                      throughput=${throughput}
    Traffic Start                   ueSetting=${ueSetting}                  dir=dl                      throughput=${throughput}
    sleep    3s
    Traffic Clear Stats             ueSetting=${ueSetting}                  dir=ul
    Traffic Clear Stats             ueSetting=${ueSetting}                  dir=dl
    Callback Run Capture            callback=${captureCallback}             capture=${capture}          duration=${captureDuration}
    Traced Sleep                    ${duration}
    ${StatusUl}                     Traffic Check if required
    ...                             ueSetting=${ueSetting}                  dir=ul
    ...                             throughput=${throughput}                shouldBeCheck=${shouldBeCheck}
    ...                             deviation=${deviation}                  shouldBeError=${False}
    ${StatusDl}                     Traffic Check if required
    ...                             ueSetting=${ueSetting}                  dir=dl
    ...                             throughput=${throughput}                shouldBeCheck=${shouldBeCheck}
    ...                             deviation=${deviation}                  shouldBeError=${False}
    Should be True                  ${StatusUl}                             Traffic UL is KO
    Should be True                  ${StatusDl}                             Traffic DL is KO
    [Teardown]                      Run keywords
    ...                             Traffic Stop                            ueSetting=${ueSetting}      dir=ul
    ...    AND                      Traffic Stop                            ueSetting=${ueSetting}      dir=dl


#===================================
# TRAFFIC Multi UE (UL/DL/UL+DL)
#===================================
Traffic UEs DL
    [Documentation]                 Start the DL data traffic on several Ues during a particular <duration>, then stop it
    ...                             A check is performed on each UE to verify obtained traffic rate is in line with expected one
    ...                             This check may be avoided on demand (${shouldBeCheck}=${False})
    ...                             If check is performed, Traffic will be checked for each UE, and KW will return the list of
    ...                             UEs for which traffic is in failure. (empty list will mean all are success)
    ...                             Optionnaly, a capture can be launched during first second of traffic (BIP Messages for instance)
    [Arguments]                     ${ueSettingList}                        # List of UE Settings
    ...                             ${throughput}=${NO_THROUGHPUT}          # Traffic in Mega
    ...                             ${captureCallback}=None                 # Reference to a KW call back or None
    ...                             ${capture}=None                         # Associated <Capture> structure if Callback is provided
    ...                             ${captureDuration}=1000ms               # Duration between statand stop of capture
    ...                             ${duration}=60s                         # Duration of Traffic
    ...                             ${shouldBeStop}=${True}                 # Indicate if traffic should be stopped
    ...                             ${shouldBeCheck}=${True}                # Indicate if traffic should be checked for each UE
    ...                             ${deviation}=1                          # Indicate deviation in percentage
    ${listUEKO}                     Traffic UEs
    ...                             ueSettingList=${ueSettingList}          dir=dl
    ...                             captureCallback=${captureCallback}      capture=${capture}
    ...                             captureDuration=${captureDuration}      throughput=${throughput}
    ...                             duration=${duration}                    shouldBeStop=${shouldBeStop}
    ...                             shouldBeCheck=${shouldBeCheck}
    ...                             deviation=${deviation}
    [Return]                        ${listUEKO}

Traffic UEs UL
    [Documentation]                 Start the DL data traffic on several Ues during a particular <duration>, then stop it
    ...                             A check is performed on each UE to verify obtained traffic rate is in line with expected one
    ...                             This check may be avoided on demand (${shouldBeCheck}=${False})
    ...                             If check is performed, Traffic will be checked for each UE, and KW will return the list of
    ...                             UEs for which traffic is in failure. (empty list will mean all are success)
    ...                             Optionnaly, a capture can be launched during first second of traffic (BIP Messages for instance)
    [Arguments]                     ${ueSettingList}                        # List of UE Settings
    ...                             ${throughput}=${NO_THROUGHPUT}          # Traffic in Mega
    ...                             ${captureCallback}=None                 # Reference to a KW call back or None
    ...                             ${capture}=None                         # Associated <Capture> structure if Callback is provided
    ...                             ${captureDuration}=1000ms               # Duration between statand stop of capture
    ...                             ${duration}=60s                         # Duration of Traffic
    ...                             ${shouldBeStop}=${True}                 # Indicate if traffic should be stopped
    ...                             ${shouldBeCheck}=${True}                # Indicate if traffic should be checked for each UE
    ...                             ${deviation}=1                          # Indicate deviation in percentage
    ${listUEKO}                     Traffic UEs
    ...                             ueSettingList=${ueSettingList}          dir=ul
    ...                             captureCallback=${captureCallback}      capture=${capture}
    ...                             captureDuration=${captureDuration}      throughput=${throughput}
    ...                             duration=${duration}                    shouldBeStop=${shouldBeStop}
    ...                             shouldBeCheck=${shouldBeCheck}
    ...                             deviation=${deviation}
    [Return]                        ${listUEKO}

Traffic UEs
    [Documentation]                 generic KW to start UL or DL traffic on n UEs
    ...                             A check is performed on each UE to verify obtained traffic rate is in line with expected one
    ...                             This check may be avoided on demand (${shouldBeCheck}=${False})
    ...                             If check is performed, Traffic will be checked for each UE, and KW will return number of
    ...                             UEs for which traffic is in failure. (0 will mean all are success)
    ...                             Optionnaly, a capture can be launched during first second of traffic (BIP Messages for instance)
    [Arguments]                     ${ueSettingList}                        # List of UE Settings
    ...                             ${dir}=ul                               # Traffic direction : ul or dl
    ...                             ${captureCallback}=None                 # Reference to a KW call back or None
    ...                             ${capture}=None                         # Associated <Capture> structure if Callback is provided
    ...                             ${captureDuration}=1000ms               # Duration between statand stop of capture
    ...                             ${throughput}=${NO_THROUGHPUT}          # Traffic in Mega
    ...                             ${duration}=60s                         # Duration of Traffic
    ...                             ${shouldBeStop}=${True}                 # Indicate if traffic should be stopped
    ...                             ${shouldBeCheck}=${True}                # Indicate if traffic should be checked for each UE
    ...                             ${deviation}=1                          # indicate deviation in percentage
    ${alias}                        SSH Wait for connect                    host=${HOST_EPCSIM}
    # Start traffic for all UEs
    FOR    ${ueSetting}    IN      @{ueSettingList}
            Traffic Start           ueSetting=${ueSetting}                  dir=${dir}                  throughput=${throughput}
    END
    Sleep                           3s
    # Clear stats and wait for duration (1 wait for all UEs)
    FOR    ${ueSetting}    IN      @{ueSettingList}
            Traffic Clear Stats  ueSetting=${ueSetting}                     dir=${dir}
    END
    Traced Sleep                    ${duration}
    # Run capture if required
    Callback Run Capture            callback=${captureCallback}             capture=${capture}          duration=${captureDuration}
    # Check if required
    @{listUEKO}                     Create list
    FOR    ${ueSetting}    IN      @{ueSettingList}
            ${status}               Traffic Check if required
            ...                         ueSetting=${ueSetting}              dir=${dir}
            ...                         throughput=${throughput}            shouldBeCheck=${shouldBeCheck}
            ...                         deviation=${deviation}              shouldBeError=${False}
            Run keyword if          ${status}==${False}
            ...                     Append to list                          ${listUEKO}                 ${ueSetting.ue}
    # Stop Traffic if required
    END
    FOR    ${ueSetting}    IN      @{ueSettingList}
            Run Keyword if          '${shouldBeStop}'=='True'
            ...                     Traffic Stop                            ueSetting=${ueSetting}      dir=${dir}
    END
    ${nbUEKO}                       get length                              ${listUEKO}
    ${nbUE}                         get length                              ${ueSettingList}
    Dated log                       Traffic UEs ${dir}:${nbUEKO}/${nbUE} UE were KO (shouldBeCheck=${shouldBeCheck})
    [Return]                        ${listUEKO}

Traffic Stop UEs
    [Documentation]                 Stop the traffic for all Ue from a ueSettingList
    [Arguments]                     ${ueSettingList}                        # List of UE Settings
    ...                             ${dir}=ul                               # Traffic direction : ul or dl
    FOR    ${ueSetting}    IN      @{ueSettingList}
            Traffic Stop            ueSetting=${ueSetting}                  dir=${dir}


    END
Traffic Check if required
    [Documentation]                 This KW check if an ue has a traffic in line with expected one
    ...                             This check is done ONLY if shouldBeCheck flag is true (propagated from Traffic UEs)
    ...                             An error is raised in case traffic is not correct,
    ...                             except if shouldBeError is set to False
    [Arguments]                     ${ueSetting}=${UE_NO_PROFILE}
    ...                             ${dir}=ul
    ...                             ${throughput}=${NO_THROUGHPUT}
    ...                             ${shouldBeCheck}=${True}
    ...                             ${deviation}=1
    ...                             ${shouldBeError}=${True}
    # If no check is required : check is OK and we exit the KW
    return from keyword if          ${shouldBeCheck}==${False}              ${True}
    # Otherwise, we check it
    ${status}                       Run keyword and return status           Traffic Check
    ...                             ueSetting=${ueSetting}                  dir=${dir}
    ...                             throughput=${throughput}
    ...                             deviation=${deviation}
    ${ErrorMsg}                     Set variable                            Traffic ${dir} on UE:${ueSetting.ue} was Failed !
    Run keyword if                  ${status}==${False}
    ...                             Dated Log                               ${ErrorMsg}
    run keyword if                  ${shouldBeError}
    ...                             Should be True
    ...                             ${status}                               ${ErrorMsg}
    [Return]                        ${status}


#===================================
# Internal TOOLS:Start, Clear stats,Stop
#===================================
Traffic Start
    [Documentation]                 Launch start traffic command on WTS, on a particular UE profile, in a particular direction (ul or dl)
    ...                             with a particular throughput
    [Arguments]                     ${ueSetting}=${UE_NO_PROFILE}
    ...                             ${dir}=ul
    ...                             ${throughput}=${NO_THROUGHPUT}
    ${ueRet}                        Traffic Set Throughput                  ueSetting=${ueSetting}      throughput=${throughput}
    Dated Log New line
    ...    Start ${dir} data traffic : UE=${ueRet.ue} Bearer=${ueRet.bearer} TRF=${ueRet.trf_id} Throughput=${ueRet.throughput}M Burst=${ueRet.burst}
    wtsemu.Trf Data Start           ue=${ueRet.ue}
    ...                             id=${ueRet.bearer}                  dir=${dir}
    ...                             mbps=${ueRet.throughput}            trf_id=${ueRet.trf_id}
    ...                             burst=${ueRet.burst}

Traffic Stop
    [Documentation]                 Stop a traffic previously started
    [Arguments]                     ${ueSetting}=${UE_NO_PROFILE}
    ...                             ${dir}=dl
    Dated log                       Stop ${dir} data traffic : UE=${ueSetting.ue} Bearer=${ueSetting.bearer} TRF=${ueSetting.trf_id}
    wtsemu.Trf Data Stop            ue=${ueSetting.ue}                      id=${ueSetting.bearer}
    ...                             dir=${dir}                              trf_id=${ueSetting.trf_id}


Traffic Clear Stats
    [Documentation]                 Clear traffic statistics on WTS
    [Arguments]                     ${ueSetting}=${UE_NO_PROFILE}
    ...                             ${dir}=dl
    ${alias}                        SSH Wait for connect                    host=${HOST_EPCSIM}
    csn.execute
    ...            sudo echo "bearer_stats_clear ue\=${ueSetting.ue} id\=${ueSetting.bearer} dir\=${dir} type\=l3" | telnet 0 ${tl.core.egate_port}
    ...            ${alias}

Traffic Check
    [Documentation]                 Check in statistics that obtained data rate is in line with expected one
    [Arguments]                     ${ueSetting}=${UE_NO_PROFILE}
    ...                             ${dir}=ul
    ...                             ${throughput}=${NO_THROUGHPUT}
    ...                             ${deviation}=1
    ${ueRet}                        Traffic Set Throughput                  ueSetting=${ueSetting}      throughput=${throughput}
    wtsemu.Bearer Stats             ue=${ueRet.ue}                          id=${ueRet.bearer}
    ...                             dir=${dir}                              type=l3
    ...                             trf_id=${ueRet.trf_id}                  #dc_cell_group=scg
    ${status}    ${value}           Run Keyword And Ignore Error            Traffic Check Data Rate
    ...                             expected_data_rate=${ueRet.throughput}000000
    ...                             deviation_in_percent=${deviation}       additional_info=id=${ueRet.bearer}
    Run Keyword If                  '${status}'=='FAIL'                     Fail        Traffic ${dir} Data Failure

Traffic Check Data Rate
    [Documentation]                 Check average data rate in output of bearer_stats in egate console
    ...                             Return 'True' or 'False' upon Real Averaged data rate is in bounds with expected
    ...                             If out of bounds, KW will be FAIL
    ...                             Code refactored, Initial author : Georg.Klein-Hessling@nokia.com (Check Average Data Rate)
    [Arguments]                     ${expected_data_rate}                   # expected data rate in mbps
    ...                             ${deviation_in_percent}                 # allowed deviation from expected data rate (in percent)
    ...                             ${additional_info}                      # information to be printed to the console log
    ${status}    ${output}          Run Keyword And Ignore Error            wtsemu.read_wtsemu_output_until
    ...                             expected=Average packet interval        timeout=10
    Run Keyword If                  '${status}'=='FAIL'                     Fail                    No entry for Average data rate found
    Return From Keyword If          '${status}'=='FAIL'
    ${output}=                      Get Lines Containing String             ${output}               Average data rate
    ${output}=                      Replace String      ${output}           Average data rate       ${EMPTY}
    @{words}=                       Split String        ${output}           (
    ${data_rate}=                   Strip String        ${words[0]}
    ${min}=                         Evaluate                                ${expected_data_rate} * (100 - ${deviation_in_percent}) / 100
    ${max}=                         Evaluate                                ${expected_data_rate} * (100 + ${deviation_in_percent}) / 100
    ${statusError}=                 Evaluate                                ${min} <= ${data_rate}
    ${statusWarn}=                  Evaluate                                ${data_rate} <= ${max}
    ${statusStr}                    Set variable if                         '${statusError}'=='True'
    ...                             REACHED                                 NOT REACHED
    ${statusStr}                    Set variable if                         '${statusWarn}'=='True'
    ...                             ${statusStr}                            EXCEEDED
    Dated Log                       Average data rate for ${additional_info} ${statusStr}: expected = ${expected_data_rate}, current = ${data_rate}
    Run Keyword If                  '${statusError}'!='True'                 Fail    Data rate failure
    [Return]                        ${statusError}

Traffic Set Throughput
    [Documentation]                 Return a copy of input UE_SETTING with throughput key updated upon argument
    ...                             if no throughput key is found, a new key is added.
    ...                             if required throughput is 0, we set key yo default one (2M)
    ...                             if required throughput is 0 but key already exists, we keep it
    [Arguments]                     ${ueSetting}
    ...                             ${throughput}=${NO_THROUGHPUT}
    # Make a copy of input UE_PROFILE
    ${ueRet}                        Copy Dictionary                         ${ueSetting}
    # Throughput force to UE one if key already exists and input throughput is 0
    ${throughput}                   Set variable if                         'throughput' in @{ueRet.keys()} and '${throughput}'=='${NO_THROUGHPUT}'
    ...                             ${ueRet.throughput}                     ${throughput}
    # Add key if not existing. Set to input value. Set to default value if input argument is 0
    Run keyword if                  'throughput' not in @{ueRet.keys()}
    ...                             Set to Dictionary                       ${ueRet}       throughput=${throughput}
    ${ueRet.throughput}             set variable                            ${throughput}
    ${ueRet.throughput}             set variable if                         '${throughput}'=='${NO_THROUGHPUT}'
    ...                             ${THROUGHPUT_DEFAULT}                   ${ueRet.throughput}
    [Return]                        ${ueRet}
