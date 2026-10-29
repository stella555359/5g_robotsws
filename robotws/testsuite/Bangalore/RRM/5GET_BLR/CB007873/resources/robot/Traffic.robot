*** Settings ***
Documentation
...                  == Purpose ==
...                  Module to manage Keywords for Uplink and/or Downlink Traffic on simulator WTS module set (Airphone, ePCSim, LTESim).
...
...                  == Description ==
...                  This library is used to generate UL, DL or UL&DL traffic on one or more UEs.
...
...                  *Main keywords are:*
...                                 - Traffic UE DL    : Launch a DL traffic session
...                                 - Traffic UE UL    : Launch a UL traffic session
...                                 - Traffic UE UL DL : Launch a UL+DL traffic session
...                                 - Traffic UEs DL   : Start the DL data traffic on several Ues
...                                 - Traffic UEs UL   : Start the UL data traffic on several Ues
...
...                 The Traffic library is part of the SWENG environment. So to use this library in a robot test,
...                 it is important to import the SWENG Setup.robot library to define the 'Setup Suite' and the 'Teardown Suite' keywords.
...                 Without the use of the 'Setup Suite' of the SWENG environment, the Traffic library could malfunction because
...                 variables linked to the environment would not be initialized.
...
...                 Keywords is based on a dictionary (mainly corresponding to the ueSetting argument) to describe the UE profile
...                 and which allows the expected good processing. This dictionary is also used by call setup keywords in the CallSetup.robot
...                 library (see CallSetup.robot).
...
...                 Overview of directory structure:
...                  - ue            : Ue id from config.cfg of Airphone.
...                  - profile       : Profile id or None (used in UE Attach NSA).
...                  - bearer        : One or more bearer id. In case of several bearer id, the format is a string containing a list of bearer id \
...                                    with each bearer id separated by a comma (2,8,...).
...                  - tesMode       : Should test mode be used (True or False) for NSA mode.
...                  - trf_id        : Id for the traffic.
...                  - pdu           : Used for SA mode.
...                  - qfi           : Used for SA mode.
...                  - target_gnb    : Used by UE Attach in NSA mode.
...                  - target_cells  : Camped cell of UE.
...                  - type          : Used by bearer stat for traffic checking.
...                  - burts         : Specific usage when start traffic.
...                  - throughput    : Throughput requested to be generated on the bearer.
...                  - testModeValue : Used in UE Attach gNB in NSA mode during RACH procedure.
...
...          4 variables based on the distionay structure to define UE profile in CallSetup library.
...
...          _3 variables for NSA call_:
...
...          *&{UE_NO_PROFILE}*
...            | ue            | 1                    |
...            | profile       | None                 |
...            | type          | l3                   |
...            | pdu           | ${None}              |
...            | bqfi          | ${None}              |
...            | bearer        | 2                    |
...            | testMode      | False                |
...            | trf_id        | 1                    |
...            | burst         | ${None}              |
...            | target_gnb    | 2                    |
...            | target_cells  | ${TARGET_CELLS}      |
...            | throughput    | ${DEFAUT_THROUGHPUT} |
...            | testModeValue | csi_report_override  |
...
...          *&{UE_SIMPLE}*
...            | ue            | 1                    |
...            | profile       | 1                    |
...            | type          | l3                   |
...            | pdu           | ${None}              |
...            | bqfi          | ${None}              |
...            | bearer        | 2                    |
...            | testMode      | False                |
...            | trf_id        | 1                    |
...            | burst         | ${None}              |
...            | target_gnb    | 2                    |
...            | target_cells  | ${TARGET_CELLS}      |
...            | throughput    | ${DEFAUT_THROUGHPUT} |
...            | testModeValue | csi_report_override  |
...
...          *&{UE_SIMPLE_TEST_MODE}*
...            | ue            | 1                    |
...            | profile       | 1                    |
...            | type          | l3                   |
...            | pdu           | ${None}              |
...            | bqfi          | ${None}              |
...            | bearer        | 2                    |
...            | testMode      | True                 |
...            | trf_id        | 1                    |
...            | burst         | ${None}              |
...            | target_gnb    | 2                    |
...            | target_cells  | ${TARGET_CELLS}      |
...            | throughput    | ${DEFAUT_THROUGHPUT} |
...            | testModeValue | csi_report_override  |
...
...          _1 variable for SA call_:
...
...          *&{BASIC_UE_SA}*
...            | ue            | 1                    |
...            | profile       | None                 |
...            | type          | ${None}              |
...            | pdu           | 1                    |
...            | bqfi          | 1                    |
...            | bearer        | ${None}              |
...            | testMode      | False                |
...            | trf_id        | 1                    |
...            | burst         | ${None}              |
...            | target_gnb    | ${None}              |
...            | target_cells  | ${TARGET_CELLS}      |
...            | throughput    | ${DEFAUT_THROUGHPUT} |
...            | testModeValue | csi_report_override  |
...
...        _Other variables are defined in CallSetup.robot library_:
...        | ${DEFAUT_THROUGHPUT} | 2 | Default throughtput is 2 mega |
...        | ${NO_THROUGHPUT}     | 0 | Define no throughput          |
...        | ${ENB_ID}            | 1 | Id for eNB (4G) as set in config file on WTS Changes these values ONLY accordingly deployed WTS confi file |
...        | ${GNB_ID}            | 2 | Id for gNB (5G) as set in config file on WTS Changes these values ONLY accordingly deployed WTS confi file |
...        | ${TARGET_CELLS}      | 1 |                               |
...
...        _Other variables are defined in Traffic.robot library_:
...        | ${MAX_THROUGHPUT_PER_TRANSFER} | ${140} | Max throughput FDD = 140 Mbps, TDD = 175 Mbps, default value = min value between FDD and TDD |

Library                             taf.transport.ssh                 WITH NAME    csn
Library                             taf.wts.runner                    WITH NAME    wtsemu
Resource                            Capture.robot
Resource                            Tools.robot

*** Variables ***
# Max throughput per data transfer (FDD = 140 Mbps, TDD = 175 Mbps)
# The default value = min value between FDD and TDD
${MAX_THROUGHPUT_PER_TRANSFER}         ${140}

*** Keywords ***
#===================================
# TRAFFIC Mono UE (UL/DL/UL+DL)
#===================================
Traffic UE DL
    [Documentation]                 Start the DL data traffic during a particular <duration>, then stop it.
    ...                             A check is performed to verify obtained traffic rate is in line with expected one.
    ...                             Optionnaly, a capture can be launched during first second of traffic (BIP Messages for instance).
    ...
    ...                             *Argument details:*
    ...                             - *ueSetting*:          Reference to UE Settings (default value: UE_NO_PROFILE).
    ...                             - *throughput*:         Traffic in Mega (default value: NO_THROUGHPUT).
    ...                             - *captureCallback*:    Reference to a KW call back or None (default value: None).
    ...                             - *capture*:            Associated <Capture> structure if Callback is provided (default value: None).
    ...                             - *captureDuration*:    Duration between statand stop of capture (default value: 1000ms).
    ...                             - *duration*:           Duration of Traffic (default value: 60s).
    ...                             - *shouldBeStop*:       Indicate if traffic should be stopped (default value: True).
    ...                             - *deviation*:          Indicate deviation in percentage (default value: 1).
    ...                             - *shouldBeCheck*:      Indicate if traffic check is needed (default value: True).
    ...                             - *maxThroughputPerTransfer*:  maxThroughputPerTransfer (default value: 140).
    ...                             - *size*:               Layer 3 packet size range (size includes all headers beginning from IP). \
    ...                                                     Maximum of 1358 for NB-IoT UEs. Maximum of 9000 for UEs configured with NR PDCP. \
    ...                                                     Otherwise, maximum is 8188 (default value: None).
    ...                             - *rtp_codec*:          rtp_codec (default value: None). When used throughput MUST be set to None.
    ...                             - *protocol*:           tcp or udp (default value: None).
    [Arguments]                     ${ueSetting}=${UE_NO_PROFILE}           # Reference to UE Settings
    ...                             ${throughput}=${NO_THROUGHPUT}          # Traffic in Mega
    ...                             ${captureCallback}=None                 # Reference to a KW call back or None
    ...                             ${capture}=None                         # Associated <Capture> structure if Callback is provided
    ...                             ${captureDuration}=1000ms               # Duration between statand stop of capture
    ...                             ${duration}=60s                         # Duration of Traffic
    ...                             ${shouldBeStop}=True                    # Indicate if traffic should be stopped
    ...                             ${deviation}=1                          # Indicate deviation in percentage
    ...                             ${shouldBeCheck}=${True}                # Indicate if traffic check is needed
    ...                             ${maxThroughputPerTransfer}=${MAX_THROUGHPUT_PER_TRANSFER}
    ...                             ${size}=${None}
    ...                             ${protocol}=${None}
    ...                             ${rtp_codec}=${None}
    Traffic UE                      ueSetting=${ueSetting}                  dir=dl
    ...                             captureCallback=${captureCallback}      capture=${capture}
    ...                             captureDuration=${captureDuration}      throughput=${throughput}
    ...                             duration=${duration}                    shouldBeStop=${shouldBeStop}
    ...                             deviation=${deviation}                  shouldBeCheck=${shouldBeCheck}
    ...                             size=${size}                            maxThroughputPerTransfer=${maxThroughputPerTransfer}
    ...                             protocol=${protocol}                    rtp_codec=${rtp_codec}

Traffic UE UL
    [Documentation]                 Start the UL data traffic during a particular <duration>, then stop it.
    ...                             A check is performed to verify obtained traffic rate is in line with expected one.
    ...                             Optionnaly, a capture can be launched during first second of traffic (BIP Messages for instance).
    ...
    ...                             *Argument details:*
    ...                             - *ueSetting*:          Reference to UE Settings (default value: UE_NO_PROFILE).
    ...                             - *throughput*:         Traffic in Mega (default value: NO_THROUGHPUT).
    ...                             - *captureCallback*:    Reference to a KW call back or None (default value: None).
    ...                             - *capture*:            Associated <Capture> structure if Callback is provided (default value: None).
    ...                             - *captureDuration*:    Duration between statand stop of capture (default value: 1000ms).
    ...                             - *duration*:           Duration of Traffic (default value: 60s).
    ...                             - *shouldBeStop*:       Indicate if traffic should be stopped (default value: True).
    ...                             - *deviation*:          Indicate deviation in percentage (default value: 1).
    ...                             - *shouldBeCheck*:      Indicate if traffic check is needed (default value: True).
    ...                             - *maxThroughputPerTransfer*:  maxThroughputPerTransfer (default value: 140).
    ...                             - *size*:               Layer 3 packet size range (size includes all headers beginning from IP). \
    ...                                                     Maximum of 1358 for NB-IoT UEs. Maximum of 9000 for UEs configured with NR PDCP. \
    ...                                                     Otherwise, maximum is 8188 (default value: None).
    ...                             - *rtp_codec*:          rtp_codec (default value: None). When used throughput MUST be set to None.
    ...                             - *protocol*:           tcp or udp (default value: None).
    [Arguments]                     ${ueSetting}=${UE_NO_PROFILE}           # Reference to UE Settings
    ...                             ${throughput}=${NO_THROUGHPUT}          # Traffic en Mega
    ...                             ${captureCallback}=None                 # Reference to a KW call back or None
    ...                             ${capture}=None                         # Associated <Capture> structure if Callback is provided
    ...                             ${captureDuration}=1000ms               # Duration between statand stop of capture
    ...                             ${duration}=60s                         # Duration of Traffic
    ...                             ${shouldBeStop}=True                    # Indicate if traffic should be stopped
    ...                             ${deviation}=1                          # Indicate deviation in percentage
    ...                             ${shouldBeCheck}=${True}                # Indicate if traffic check is needed
    ...                             ${maxThroughputPerTransfer}=${MAX_THROUGHPUT_PER_TRANSFER}
    ...                             ${size}=${None}
    ...                             ${protocol}=${None}
    ...                             ${rtp_codec}=${None}
    Traffic UE                      ueSetting=${ueSetting}                  dir=ul
    ...                             captureCallback=${captureCallback}      capture=${capture}
    ...                             captureDuration=${captureDuration}      throughput=${throughput}
    ...                             duration=${duration}                    shouldBeStop=${shouldBeStop}
    ...                             deviation=${deviation}                  shouldBeCheck=${shouldBeCheck}
    ...                             size=${size}                            maxThroughputPerTransfer=${maxThroughputPerTransfer}
    ...                             protocol=${protocol}                    rtp_codec=${rtp_codec}

Traffic UE
    [Documentation]                 INTERNAL USAGE
    ...                             Start the DL or UL data traffic during a particular <duration>, then stop it
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
    ...                             ${size}=${None}                         # Layer 3 packet size range
    ...                             ${maxThroughputPerTransfer}=${MAX_THROUGHPUT_PER_TRANSFER}
    ...                             ${protocol}=${None}
    ...                             ${rtp_codec}=${None}
    ${shouldBeCheck}                Set Variable If                         '${rtp_codec}'!='${None}'
    ...                             ${False}                                ${shouldBeCheck}
    ${alias}                        SSH Wait for connect                    host=${HOST_EPCSIM}
    ${ueRet}                        Traffic Start                           ueSetting=${ueSetting}      dir=${dir}
    ...                             throughput=${throughput}                maxThroughputPerTransfer=${maxThroughputPerTransfer}
    ...                             size=${size}                            protocol=${protocol}
    ...                             rtp_codec=${rtp_codec}
    Sleep                           3s
    Traffic Clear Stats             ueSetting=${ueRet}                      dir=${dir}
    Callback Run Capture            callback=${captureCallback}             capture=${capture}          duration=${captureDuration}
    Traced Sleep                    ${duration}
    Traffic Check if required       ueSetting=${ueRet}                      dir=${dir}
    ...                             throughput=${throughput}                shouldBeCheck=${shouldBeCheck}
    ...                             deviation=${deviation}                  shouldBeError=${True}
    [Teardown]                      Run Keyword if                          '${shouldBeStop}'=='True'
    ...                             Traffic Stop                            ueSetting=${ueRet}      dir=${dir}      throughput=${throughput}
    ...                             maxThroughputPerTransfer=${maxThroughputPerTransfer}

Traffic UE UL DL
    [Documentation]                 Start a UL and DL data traffic during a particular <duration>, then stop it.
    ...                             A check is performed to verify obtained traffic rate is in line with expected one.
    ...                             Optionnaly, a capture can be launched during first second of traffic (BIP Messages for instance).
    ...
    ...                             *Argument details:*
    ...                             - *ueSetting*:          Reference to UE Settings (default value: UE_NO_PROFILE).
    ...                             - *throughput*:         Traffic in Mega (default value: NO_THROUGHPUT).
    ...                             - *captureCallback*:    Reference to a KW call back or None (default value: None).
    ...                             - *capture*:            Associated <Capture> structure if Callback is provided (default value: None).
    ...                             - *captureDuration*:    Duration between statand stop of capture (default value: 1000ms).
    ...                             - *duration*:           Duration of Traffic (default value: 60s).
    ...                             - *shouldBeStop*:       Indicate if traffic should be stopped (default value: True).
    ...                             - *deviation*:          Indicate deviation in percentage (default value: 1).
    ...                             - *shouldBeCheck*:      Indicate if traffic check is needed (default value: True).
    ...                             - *maxThroughputPerTransfer*:  maxThroughputPerTransfer (default value: 140).
    ...                             - *rtp_codec*:          rtp_codec (default value: None). When used throughput MUST be set to None.
    ...                             - *protocol*:           tcp or udp (default value: None).
    [Arguments]                     ${ueSetting}=${UE_NO_PROFILE}           # Reference to UE Settings
    ...                             ${throughput}=${NO_THROUGHPUT}          # Traffic en Mega
    ...                             ${captureCallback}=None                 # Reference to a KW call back or None
    ...                             ${capture}=None                         # Associated <Capture> structure if Callback is provided
    ...                             ${captureDuration}=1000ms               # Duration between statand stop of capture
    ...                             ${duration}=60s                         # Duration of Traffic
    ...                             ${deviation}=1                          # indicate deviation in percentage
    ...                             ${shouldBeCheck}=${True}                # Indicate if traffic check is needed
    ...                             ${ulThroughput}=None                    # Uplink traffic in Mega
    ...                             ${dlThroughput}=None                    # Downlink traffic in Mega
    ...                             ${maxThroughputPerTransfer}=${MAX_THROUGHPUT_PER_TRANSFER}
    ...                             ${protocol}=${None}
    ...                             ${rtp_codec}=${None}
    ${shouldBeCheck}                Set Variable If                         '${rtp_codec}'!='${None}'
    ...                             ${False}                                ${shouldBeCheck}
    ${alias}                        SSH Wait for connect                    host=${HOST_EPCSIM}

    ${ul_throughput}                Set Variable If
    ...                             '${ulThroughput}'!='None'              ${ulThroughput}             ${throughput}
    ${dl_throughput}                Set Variable If
    ...                             '${dlThroughput}'!='None'              ${dlThroughput}             ${throughput}
    ${ueRetUl}                      Traffic Start                          ueSetting=${ueSetting}      dir=ul
    ...                             throughput=${ul_throughput}            maxThroughputPerTransfer=${maxThroughputPerTransfer}
    ...                             protocol=${protocol}                   rtp_codec=${rtp_codec}
    ${ueRetDl}                      Traffic Start                          ueSetting=${ueSetting}      dir=dl
    ...                             throughput=${dl_throughput}            maxThroughputPerTransfer=${maxThroughputPerTransfer}
    ...                             protocol=${protocol}                   rtp_codec=${rtp_codec}
    sleep    3s
    Traffic Clear Stats             ueSetting=${ueSetting}                  dir=ul
    Traffic Clear Stats             ueSetting=${ueSetting}                  dir=dl
    Callback Run Capture            callback=${captureCallback}             capture=${capture}          duration=${captureDuration}
    Traced Sleep                    ${duration}
    ${StatusUl}                     Traffic Check if required
    ...                             ueSetting=${ueRetUl}                    dir=ul
    ...                             throughput=${ul_throughput}             shouldBeCheck=${shouldBeCheck}
    ...                             deviation=${deviation}                  shouldBeError=${False}
    ${StatusDl}                     Traffic Check if required
    ...                             ueSetting=${ueRetDl}                    dir=dl
    ...                             throughput=${dl_throughput}             shouldBeCheck=${shouldBeCheck}
    ...                             deviation=${deviation}                  shouldBeError=${False}
    Should be True                  ${StatusUl}                             Traffic UL is KO
    Should be True                  ${StatusDl}                             Traffic DL is KO
    [Teardown]                      Run keywords
    ...                             Traffic Stop                            ueSetting=${ueRetUl}      dir=ul     throughput=${ul_throughput}
    ...                             maxThroughputPerTransfer=${maxThroughputPerTransfer}
    ...    AND                      Traffic Stop                            ueSetting=${ueRetDl}      dir=dl     throughput=${dl_throughput}
    ...                             maxThroughputPerTransfer=${maxThroughputPerTransfer}


#===================================
# TRAFFIC Multi UE (UL/DL/UL+DL)
#===================================
Traffic UEs DL
    [Documentation]                 Start the DL data traffic on several Ues during a particular <duration>, then stop it.
    ...                             A check is performed on each UE to verify obtained traffic rate is in line with expected one.
    ...                             This check may be avoided on demand (${shouldBeCheck}=${False}).
    ...                             If check is performed, Traffic will be checked for each UE, and KW will return the list of
    ...                             UEs for which traffic is in failure. (empty list will mean all are success).
    ...                             Optionnaly, a capture can be launched during first second of traffic (BIP Messages for instance).
    ...
    ...                             *Argument details:*
    ...                             - *ueSettingList*:      List of UE Settings.
    ...                             - *throughput*:         Traffic in Mega (default value: NO_THROUGHPUT).
    ...                             - *captureCallback*:    Reference to a KW call back or None (default value: None).
    ...                             - *capture*:            Associated <Capture> structure if Callback is provided (default value: None).
    ...                             - *captureDuration*:    Duration between statand stop of capture (default value: 1000ms).
    ...                             - *duration*:           Duration of Traffic (default value: 60s).
    ...                             - *shouldBeStop*:       Indicate if traffic should be stopped (default value: True).
    ...                             - *deviation*:          Indicate deviation in percentage (default value: 1).
    ...                             - *shouldBeCheck*:      Indicate if traffic check is needed (default value: True).
    ...                             - *rtp_codec*:          rtp_codec (default value: None). When used throughput MUST be set to None.
    ...                             - *protocol*:           tcp or udp (default value: None).
    [Arguments]                     ${ueSettingList}                        # List of UE Settings
    ...                             ${throughput}=${NO_THROUGHPUT}          # Traffic in Mega
    ...                             ${captureCallback}=None                 # Reference to a KW call back or None
    ...                             ${capture}=None                         # Associated <Capture> structure if Callback is provided
    ...                             ${captureDuration}=1000ms               # Duration between statand stop of capture
    ...                             ${duration}=60s                         # Duration of Traffic
    ...                             ${shouldBeStop}=${True}                 # Indicate if traffic should be stopped
    ...                             ${shouldBeCheck}=${True}                # Indicate if traffic should be checked for each UE
    ...                             ${deviation}=1                          # Indicate deviation in percentage
    ...                             ${protocol}=${None}
    ...                             ${rtp_codec}=${None}
    ${listUEKO}                     Traffic UEs
    ...                             ueSettingList=${ueSettingList}          dir=dl
    ...                             captureCallback=${captureCallback}      capture=${capture}
    ...                             captureDuration=${captureDuration}      throughput=${throughput}
    ...                             duration=${duration}                    shouldBeStop=${shouldBeStop}
    ...                             shouldBeCheck=${shouldBeCheck}
    ...                             deviation=${deviation}
    ...                             protocol=${protocol}
    ...                             rtp_codec=${rtp_codec}
    [Return]                        ${listUEKO}

Traffic UEs UL
    [Documentation]                 Start the DL data traffic on several Ues during a particular <duration>, then stop it.
    ...                             A check is performed on each UE to verify obtained traffic rate is in line with expected one.
    ...                             This check may be avoided on demand (${shouldBeCheck}=${False}).
    ...                             If check is performed, Traffic will be checked for each UE, and KW will return the list of
    ...                             UEs for which traffic is in failure. (empty list will mean all are success).
    ...                             Optionnaly, a capture can be launched during first second of traffic (BIP Messages for instance).
    ...
    ...                             *Argument details:*
    ...                             - *ueSettingList*:      List of UE Settings (default value: ueSettingList).
    ...                             - *throughput*:         Traffic in Mega (default value: NO_THROUGHPUT).
    ...                             - *captureCallback*:    Reference to a KW call back or None (default value: None).
    ...                             - *capture*:            Associated <Capture> structure if Callback is provided (default value: None).
    ...                             - *captureDuration*:    Duration between statand stop of capture (default value: 1000ms).
    ...                             - *duration*:           Duration of Traffic (default value: 60s).
    ...                             - *shouldBeStop*:       Indicate if traffic should be stopped (default value: True).
    ...                             - *deviation*:          Indicate deviation in percentage (default value: 1).
    ...                             - *shouldBeCheck*:      Indicate if traffic check is needed (default value: True).
    ...                             - *rtp_codec*:          rtp_codec (default value: None). When used throughput MUST be set to None.
    ...                             - *protocol*:           tcp or udp (default value: None).
    [Arguments]                     ${ueSettingList}                        # List of UE Settings
    ...                             ${throughput}=${NO_THROUGHPUT}          # Traffic in Mega
    ...                             ${captureCallback}=None                 # Reference to a KW call back or None
    ...                             ${capture}=None                         # Associated <Capture> structure if Callback is provided
    ...                             ${captureDuration}=1000ms               # Duration between statand stop of capture
    ...                             ${duration}=60s                         # Duration of Traffic
    ...                             ${shouldBeStop}=${True}                 # Indicate if traffic should be stopped
    ...                             ${shouldBeCheck}=${True}                # Indicate if traffic should be checked for each UE
    ...                             ${deviation}=1                          # Indicate deviation in percentage
    ...                             ${protocol}=${None}
    ...                             ${rtp_codec}=${None}
    ${listUEKO}                     Traffic UEs
    ...                             ueSettingList=${ueSettingList}          dir=ul
    ...                             captureCallback=${captureCallback}      capture=${capture}
    ...                             captureDuration=${captureDuration}      throughput=${throughput}
    ...                             duration=${duration}                    shouldBeStop=${shouldBeStop}
    ...                             shouldBeCheck=${shouldBeCheck}
    ...                             deviation=${deviation}
    ...                             protocol=${protocol}
    ...                             rtp_codec=${rtp_codec}
    [Return]                        ${listUEKO}

Traffic UEs
    [Documentation]                 INTERNAL USAGE
    ...                             generic KW to start UL or DL traffic on n UEs
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
    ...                             ${protocol}=${None}
    ...                             ${rtp_codec}=${None}
    ${shouldBeCheck}                Set Variable If                         '${rtp_codec}'!='${None}'
    ...                             ${False}                                ${shouldBeCheck}
    ${alias}                        SSH Wait for connect                    host=${HOST_EPCSIM}
    # Start traffic for all UEs
    FOR    ${ueSetting}    IN      @{ueSettingList}
            Traffic Start           ueSetting=${ueSetting}                  dir=${dir}                  throughput=${throughput}
            ...                     protocol=${protocol}                    rtp_codec=${rtp_codec}
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
            ...                     Traffic Stop                            ueSetting=${ueSetting}      dir=${dir}      throughput=${throughput}
    END
    ${nbUEKO}                       get length                              ${listUEKO}
    ${nbUE}                         get length                              ${ueSettingList}
    Dated log                       Traffic UEs ${dir}:${nbUEKO}/${nbUE} UE were KO (shouldBeCheck=${shouldBeCheck})
    [Return]                        ${listUEKO}

Traffic UEs UL DL
    [Documentation]                 Start a UL and DL data traffic on several Ues during a particular <duration>, then stop it.
    ...                             A check is performed to verify obtained traffic rate is in line with expected one.
    ...                             Optionnaly, a capture can be launched during first second of traffic (BIP Messages for instance).
    ...
    ...                             *Argument details:*
    ...                             - *ueSettingList*:      List of UE Settings (default value: ueSettingList).
    ...                             - *throughput*:         Traffic in Mega (default value: NO_THROUGHPUT).
    ...                             - *captureCallback*:    Reference to a KW call back or None (default value: None).
    ...                             - *capture*:            Associated <Capture> structure if Callback is provided (default value: None).
    ...                             - *captureDuration*:    Duration between statand stop of capture (default value: 1000ms).
    ...                             - *duration*:           Duration of Traffic (default value: 60s).
    ...                             - *shouldBeStop*:       Indicate if traffic should be stopped (default value: True).
    ...                             - *deviation*:          Indicate deviation in percentage (default value: 1).
    ...                             - *shouldBeCheck*:      Indicate if traffic check is needed (default value: True).
    ...                             - *maxThroughputPerTransfer*:  maxThroughputPerTransfer (default value: 140).
    ...                             - *rtp_codec*:          rtp_codec (default value: None). When used throughput MUST be set to None.
    ...                             - *protocol*:           tcp or udp (default value: None).
    [Arguments]                     ${ueSettingList}                        # List of UE Settings
    ...                             ${throughput}=${NO_THROUGHPUT}          # Traffic en Mega
    ...                             ${captureCallback}=None                 # Reference to a KW call back or None
    ...                             ${capture}=None                         # Associated <Capture> structure if Callback is provided
    ...                             ${captureDuration}=1000ms               # Duration between statand stop of capture
    ...                             ${duration}=60s                         # Duration of Traffic
    ...                             ${deviation}=1                          # indicate deviation in percentage
    ...                             ${shouldBeCheck}=${True}                # Indicate if traffic check is needed
    ...                             ${ulThroughput}=None                    # Uplink traffic in Mega
    ...                             ${dlThroughput}=None                    # Downlink traffic in Mega
    ...                             ${maxThroughputPerTransfer}=${MAX_THROUGHPUT_PER_TRANSFER}
    ...                             ${protocol}=${None}
    ...                             ${rtp_codec}=${None}
    ${shouldBeCheck}                Set Variable If                         '${rtp_codec}'!='${None}'
    ...                             ${False}                                ${shouldBeCheck}
    ${alias}                        SSH Wait for connect                    host=${HOST_EPCSIM}

    ${ul_throughput}                Set Variable If
    ...                             '${ulThroughput}'!='None'              ${ulThroughput}             ${throughput}
    ${dl_throughput}                Set Variable If
    ...                             '${dlThroughput}'!='None'              ${dlThroughput}             ${throughput}
    @{ueRetUl_List}                  create list
    @{ueRetDl_List}                  create list
    FOR    ${ueSetting}    IN      @{ueSettingList}
        ${ueRetUl}                      Traffic Start                          ueSetting=${ueSetting}      dir=ul
        ...                             throughput=${ul_throughput}            maxThroughputPerTransfer=${maxThroughputPerTransfer}
        ...                             protocol=${protocol}                   rtp_codec=${rtp_codec}
        ${ueRetDl}                      Traffic Start                          ueSetting=${ueSetting}      dir=dl
        ...                             throughput=${dl_throughput}            maxThroughputPerTransfer=${maxThroughputPerTransfer}
        ...                             protocol=${protocol}                   rtp_codec=${rtp_codec}
        Append to list                  ${ueRetUl_List}                        ${ueRetUl}
        Append to list                  ${ueRetDl_List}                        ${ueRetDl}
    END
    sleep    3s
    FOR    ${ueSetting}    IN      @{ueSettingList}
        Traffic Clear Stats             ueSetting=${ueSetting}                  dir=ul
        Traffic Clear Stats             ueSetting=${ueSetting}                  dir=dl
    END
    Callback Run Capture            callback=${captureCallback}             capture=${capture}          duration=${captureDuration}
    Traced Sleep                    ${duration}
    FOR    ${ueSetting}    IN      @{ueRetUl_List}
        ${StatusUl}                     Traffic Check if required
        ...                             ueSetting=${ueSetting}                    dir=ul
        ...                             throughput=${ul_throughput}             shouldBeCheck=${shouldBeCheck}
        ...                             deviation=${deviation}                  shouldBeError=${False}
                Should be True                  ${StatusUl}                             Traffic UL is KO
    END
    FOR    ${ueSetting}    IN      @{ueRetDl_List}
        ${StatusDl}                     Traffic Check if required
        ...                             ueSetting=${ueSetting}                    dir=dl
        ...                             throughput=${dl_throughput}             shouldBeCheck=${shouldBeCheck}
        ...                             deviation=${deviation}                  shouldBeError=${False}
        Should be True                  ${StatusDl}                             Traffic DL is KO
    END
    [Teardown]                      Run keywords
    ...                             Traffic Stop UEs                           ueSettingList=${ueRetUl_List}      dir=ul
    ...    AND                      Traffic Stop UEs                           ueSettingList=${ueRetDl_List}      dir=dl

Traffic Stop UEs
    [Documentation]                 INTERNAL USAGE
    ...                             Stop the traffic for all Ue from a ueSettingList
    [Arguments]                     ${ueSettingList}                        # List of UE Settings
    ...                             ${dir}=ul                               # Traffic direction : ul or dl
    FOR    ${ueSetting}    IN      @{ueSettingList}
            Traffic Stop            ueSetting=${ueSetting}                  dir=${dir}
    END

Traffic Check if required
    [Documentation]                 INTERNAL USAGE
    ...                             This KW check if an ue has a traffic in line with expected one
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

Get Number Of Transfers
    [Documentation]                 INTERNAL USAGE
    ...                             Get the number of data transfer needed to reach the requested throughput
    ...                             The max throughput per transfer is provided by maxThroughputPerTransfer parameter
    [Arguments]                     ${throughput}=${NO_THROUGHPUT}
    ...                             ${maxThroughputPerTransfer}=${MAX_THROUGHPUT_PER_TRANSFER}

    # For backward compatibility, if no throughput provided then consider that there is only 1 transfer
    Return From Keyword If          '${throughput}'=='${NO_THROUGHPUT}' or '${throughput}'=='${None}'
    ...                             ${1}

    ${nbTrf}                        Evaluate   ${throughput}/${maxThroughputPerTransfer}
    ${nbTrf1}                       Evaluate    ${nbTrf}+1
    ${remaining}                    Evaluate   ${throughput}%${maxThroughputPerTransfer}
    ${nbTrf}                        Set Variable If    ${remaining}>0
    ...                             ${nbTrf1}
    ...                             ${nbTrf}
    ${nbTrf}                        Convert to Integer    ${nbTrf}
    [Return]                        ${nbTrf}

Traffic Start
    [Documentation]                 INTERNAL USAGE
    ...                             Launch start traffic command on WTS, on a particular UE profile, in a particular direction (ul or dl)
    ...                             with a particular throughput
    [Arguments]                     ${ueSetting}=${UE_NO_PROFILE}
    ...                             ${dir}=ul
    ...                             ${throughput}=${NO_THROUGHPUT}
    ...                             ${maxThroughputPerTransfer}=${MAX_THROUGHPUT_PER_TRANSFER}
    ...                             ${size}=${None}
    ...                             ${protocol}=${None}
    ...                             ${rtp_codec}=${None}

    ${ueRet}                        Traffic Set Throughput                  ueSetting=${ueSetting}      throughput=${throughput}

    Dated Log New line
    ...    Start ${dir} data traffic : UE=${ueRet.ue} Bearer=${ueRet.bearer} TRF=${ueRet.trf_id} Throughput=${ueRet.throughput}M Burst=${ueRet.burst}

    ${nb_trf}                       Get Number Of Transfers
    ...                             throughput=${ueRet.throughput}
    ...                             maxThroughputPerTransfer=${maxThroughputPerTransfer}
    ${remaining_throughput}         Set Variable    ${ueRet.throughput}
    FOR  ${idx}    IN RANGE     ${nb_trf}
        ${trf_id}                   Evaluate    ${ueRet.trf_id}+${idx}
        ${trfThroughput}            Set Variable If
        ...                         ${remaining_throughput}==${None}                            ${None}
        ...                         ${remaining_throughput}>=${maxThroughputPerTransfer}        ${maxThroughputPerTransfer}
        ...                         ${remaining_throughput}<${maxThroughputPerTransfer}         ${remaining_throughput}
        wtsemu.Trf Data Start       ue=${ueRet.ue}
        ...                         id=${ueRet.bearer}                  dir=${dir}
        ...                         mbps=${trfThroughput}               trf_id=${trf_id}
        ...                         qfi=${ueRet.qfi}                    pdu=${ueRet.pdu}
        ...                         burst=${ueRet.burst}                size=${size}
        ...                         protocol=${protocol}                rtp_codec=${rtp_codec}
        ${remaining_throughput}     Run Keyword If                      ${remaining_throughput}!=${None}
        ...                         Evaluate                            ${remaining_throughput}-${trfThroughput}
    END

    # return the newly created UE
    [Return]    ${ueRet}

Traffic Stop
    [Documentation]                 INTERNAL USAGE
    ...                             Stop a traffic previously started
    [Arguments]                     ${ueSetting}=${UE_NO_PROFILE}
    ...                             ${dir}=dl
    ...                             ${throughput}=${NO_THROUGHPUT}
    ...                             ${maxThroughputPerTransfer}=${MAX_THROUGHPUT_PER_TRANSFER}

    Dated log                       Stop ${dir} data traffic : UE=${ueSetting.ue} Bearer=${ueSetting.bearer} TRF=${ueSetting.trf_id}

    ${ue_throughput}                Get Variable Value                  ${ueSetting.throughput}
    ${trf_throughput}               Set Variable If
    ...                             '${ue_throughput}'!='None'          ${ue_throughput}
    ...                             '${ue_throughput}'=='None'          ${throughput}
    ${nb_trf}                       Get Number Of Transfers
    ...                             throughput=${trf_throughput}
    ...                             maxThroughputPerTransfer=${maxThroughputPerTransfer}
    FOR  ${idx}    IN RANGE     ${nb_trf}
        ${trf_id}                   Evaluate                            ${ueSetting.trf_id}+${idx}
        wtsemu.Trf Data Stop        ue=${ueSetting.ue}                  id=${ueSetting.bearer}
        ...                         dir=${dir}                          trf_id=${trf_id}
        ...                         qfi=${ueSetting.qfi}                pdu=${ueSetting.pdu}
    END

Traffic Clear Stats
    [Documentation]                 INTERNAL USAGE
    ...                             Clear traffic statistics on WTS
    [Arguments]                     ${ueSetting}=${UE_NO_PROFILE}
    ...                             ${dir}=dl
    wtsemu.bearer_stats_clear       ue=${ueSetting.ue}        id=${ueSetting.bearer}    dir=${dir}
    ...                             type=${ueSetting.type}    qfi=${ueSetting.qfi}      pdu=${ueSetting.pdu}

Traffic Check
    [Documentation]                 INTERNAL USAGE
    ...                             Check in statistics that obtained data rate is in line with expected one
    ...                             ${dir}=ul
    ...                             ${throughput}=${NO_THROUGHPUT}
    ...                             ${deviation}=1
    [Arguments]                     ${ueSetting}=${UE_NO_PROFILE}
    ...                             ${dir}=ul
    ...                             ${throughput}=${NO_THROUGHPUT}
    ...                             ${deviation}=1
    ${ueRet}                        Traffic Set Throughput                  ueSetting=${ueSetting}      throughput=${throughput}
    wtsemu.Bearer Stats             ue=${ueRet.ue}                          id=${ueRet.bearer}
    ...                             dir=${dir}                              type=${ueSetting.type}
    ...                             trf_id=${ueRet.trf_id}                  #dc_cell_group=scg
    ...                             qfi=${ueRet.qfi}                        pdu=${ueRet.pdu}

    ${additional_info}              set variable if     '${ueRet.bearer}'=='${None}'     Call    id=${ueRet.bearer}
    ${status}    ${value}           Run Keyword And Ignore Error            Traffic Check Data Rate
    ...                             expected_data_rate=${ueRet.throughput}000000
    ...                             deviation_in_percent=${deviation}       additional_info=${additional_info}
    Run Keyword If                  '${status}'=='FAIL'                     Fail        Traffic ${dir} Data Failure

Traffic Check Data Rate
    [Documentation]                 INTERNAL USAGE
    ...                             Check average data rate in output of bearer_stats in egate console
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
    Dated Log                       Average data rate for ${additional_info}: ${statusStr}: expected = ${expected_data_rate}, current = ${data_rate}
    Run Keyword If                  '${statusError}'!='True'                 Fail    Data rate failure
    [Return]                        ${statusError}

Traffic Set Throughput
    [Documentation]                 INTERNAL USAGE
    ...                             Return a copy of input UE_SETTING with throughput key updated upon argument
    ...                             if no throughput key is found, a new key is added.
    ...                             if required throughput is 0, we set key yo default one (2M)
    ...                             if required throughput is 0 but key already exists, we keep it
    [Arguments]                     ${ueSetting}
    ...                             ${throughput}=${NO_THROUGHPUT}
    # Make a copy of input UE_PROFILE
    ${ueRet}                        Copy Dictionary                         ${ueSetting}
    return from keyword if          ${throughput}==${None}                  ${ueSetting}
    # Throughput force to UE one if key already exists and input throughput is 0
    ${throughput}                   Set variable if
    ...                             'throughput' in @{ueRet.keys()} and '${throughput}'=='${NO_THROUGHPUT}'
    ...                             ${ueRet.throughput}                     ${throughput}
    # Add key if not existing. Set to input value. Set to default value if input argument is 0
    Run keyword if                  'throughput' not in @{ueRet.keys()}
    ...                             Set to Dictionary                       ${ueRet}       throughput=${throughput}
    ${ueRet.throughput}             set variable                            ${throughput}
    ${ueRet.throughput}             set variable if                         '${throughput}'=='${NO_THROUGHPUT}'
    ...                             ${THROUGHPUT_DEFAULT}                   ${ueRet.throughput}
    [Return]                        ${ueRet}
