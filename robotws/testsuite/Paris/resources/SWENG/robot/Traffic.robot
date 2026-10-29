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
...                                 - Traffic UEs UL DL: Start the UL and DL data traffic on several Ues
...                                 - Send UE DL packets : Start the DL data traffic bursts during a particular <period_ms>, then stop it.
...                                 - Send UE UL packets : Start the UL data traffic bursts during a particular <period_ms>, then stop it.
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
...                  - size          : Layer 3 packet size range (size includes all headers beginning from IP).
...                                    Maximum of 1358 for NB-IoT UEs. Maximum of 9000 for UEs configured with NR PDCP.
...                                    Otherwise, maximum is 8188 (default value: None).
...                  - period_ms     : Time interval between each emission of a burst.
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
...            | qfi           | ${None}              |
...            | bearer        | 2                    |
...            | testMode      | False                |
...            | trf_id        | 1                    |
...            | burst         | ${None}              |
...            | target_gnb    | 2                    |
...            | target_cells  | ${TARGET_CELLS}      |
...            | throughput    | ${DEFAUT_THROUGHPUT} |
...            | testModeValue | csi_report_override  |
...            | period_ms     | ${None}              |
...            | size          | ${None}              |
...
...          *&{UE_SIMPLE}*
...            | ue            | 1                    |
...            | profile       | 1                    |
...            | type          | l3                   |
...            | pdu           | ${None}              |
...            | qfi           | ${None}              |
...            | bearer        | 2                    |
...            | testMode      | False                |
...            | trf_id        | 1                    |
...            | burst         | ${None}              |
...            | target_gnb    | 2                    |
...            | target_cells  | ${TARGET_CELLS}      |
...            | throughput    | ${DEFAUT_THROUGHPUT} |
...            | testModeValue | csi_report_override  |
...            | period_ms     | ${None}              |
...            | size          | ${None}              |
...
...          *&{UE_SIMPLE_TEST_MODE}*
...            | ue            | 1                    |
...            | profile       | 1                    |
...            | type          | l3                   |
...            | pdu           | ${None}              |
...            | qfi           | ${None}              |
...            | bearer        | 2                    |
...            | testMode      | True                 |
...            | trf_id        | 1                    |
...            | burst         | ${None}              |
...            | target_gnb    | 2                    |
...            | target_cells  | ${TARGET_CELLS}      |
...            | throughput    | ${DEFAUT_THROUGHPUT} |
...            | testModeValue | csi_report_override  |
...            | period_ms     | ${None}              |
...            | size          | ${None}              |
...
...          _1 variable for SA call_:
...
...          *&{BASIC_UE_SA}*
...            | ue            | 1                    |
...            | profile       | None                 |
...            | type          | ${None}              |
...            | pdu           | 1                    |
...            | qfi           | 1                    |
...            | bearer        | ${None}              |
...            | testMode      | False                |
...            | trf_id        | 1                    |
...            | burst         | ${None}              |
...            | target_gnb    | ${None}              |
...            | target_cells  | ${TARGET_CELLS}      |
...            | throughput    | ${DEFAUT_THROUGHPUT} |
...            | testModeValue | csi_report_override  |
...            | period_ms     | ${None}              |
...            | size          | ${None}              |
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
    ...                             - *use_uestatsnr*:      Use ue_stats_nr for traffic check (default value: False).
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
    ...                             ${use_uestatsnr}=${False}               # Use ue_stats_nr for traffic check
    ...                             ${NSA_UE}=${True}                       # Use an NSA UE for traffic check
    Traffic UE                      ueSetting=${ueSetting}                  dir=dl
    ...                             captureCallback=${captureCallback}      capture=${capture}
    ...                             captureDuration=${captureDuration}      throughput=${throughput}
    ...                             duration=${duration}                    shouldBeStop=${shouldBeStop}
    ...                             deviation=${deviation}                  shouldBeCheck=${shouldBeCheck}
    ...                             size=${size}                            maxThroughputPerTransfer=${maxThroughputPerTransfer}
    ...                             protocol=${protocol}                    rtp_codec=${rtp_codec}
    ...                             use_uestatsnr=${use_uestatsnr}          NSA_UE=${NSA_UE}

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
    ...                             - *use_uestatsnr*:      Use ue_stats_nr for traffic check (default value: False).
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
    ...                             ${use_uestatsnr}=${False}
    ...                             ${NSA_UE}=${True}                       # Use an NSA UE for traffic check
    Traffic UE                      ueSetting=${ueSetting}                  dir=ul
    ...                             captureCallback=${captureCallback}      capture=${capture}
    ...                             captureDuration=${captureDuration}      throughput=${throughput}
    ...                             duration=${duration}                    shouldBeStop=${shouldBeStop}
    ...                             deviation=${deviation}                  shouldBeCheck=${shouldBeCheck}
    ...                             size=${size}                            maxThroughputPerTransfer=${maxThroughputPerTransfer}
    ...                             protocol=${protocol}                    rtp_codec=${rtp_codec}
    ...                             use_uestatsnr=${use_uestatsnr}          NSA_UE=${NSA_UE}

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
    ...                             ${use_uestatsnr}=${False}               # Use ue_stats_nr for traffic check
    ...                             ${NSA_UE}=${True}                       # Use an NSA UE for traffic check

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
    Tools.Traced Sleep              ${duration}                             waiting fo ${duration}, then will check traffic
    Traffic Check if required       ueSetting=${ueRet}                      dir=${dir}
    ...                             throughput=${throughput}                shouldBeCheck=${shouldBeCheck}
    ...                             deviation=${deviation}                  shouldBeError=${True}
    ...                             use_uestatsnr=${use_uestatsnr}          NSA_UE=${NSA_UE}
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
    ...                             - *ulThroughput*:       Uplink traffic in Mega (default value: None).
    ...                             - *dlThroughput*:       Downlink traffic in Mega (default value: None).
    ...                             - *use_uestatsnr*:      Use ue_stats_nr for traffic check (default value: False).
    ...                             - *shouldStopTraffic*:  Indicate if traffic should be stopped at teardown (default value: True).
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
    ...                             ${use_uestatsnr}=${False}               # Use ue_stats_nr for traffic check
    ...                             ${NSA_UE}=${True}                       # Use an NSA UE for traffic check
    ...                             ${shouldStopTraffic}=True               # Indicate if traffic should be stopped at teardown
    ${shouldBeCheck}                Set Variable If                         '${rtp_codec}'!='${None}'
    ...                             ${False}                                ${shouldBeCheck}
    ${alias}                        SSH Wait for connect                    host=${HOST_EPCSIM}

    ${ul_traffic_throughput}        Set Variable If
    ...                             '${ulThroughput}'!='None'              ${ulThroughput}             ${throughput}
    ${dl_traffic_throughput}        Set Variable If
    ...                             '${dlThroughput}'!='None'              ${dlThroughput}             ${throughput}
    ${ueRetUl}                      Traffic Start                          ueSetting=${ueSetting}      dir=ul
    ...                             throughput=${ul_traffic_throughput}    maxThroughputPerTransfer=${maxThroughputPerTransfer}
    ...                             protocol=${protocol}                   rtp_codec=${rtp_codec}
    ${ueRetDl}                      Traffic Start                          ueSetting=${ueSetting}      dir=dl
    ...                             throughput=${dl_traffic_throughput}    maxThroughputPerTransfer=${maxThroughputPerTransfer}
    ...                             protocol=${protocol}                   rtp_codec=${rtp_codec}
    sleep    3s
    Traffic Clear Stats             ueSetting=${ueSetting}                  dir=ul
    Traffic Clear Stats             ueSetting=${ueSetting}                  dir=dl
    Callback Run Capture            callback=${captureCallback}             capture=${capture}          duration=${captureDuration}
    Tools.Traced Sleep              ${duration}                             waiting fo ${duration}, then will check traffic
    ${StatusUl}                     Traffic Check if required
    ...                             ueSetting=${ueRetUl}                    dir=ul
    ...                             throughput=${ul_traffic_throughput}     shouldBeCheck=${shouldBeCheck}
    ...                             deviation=${deviation}                  shouldBeError=${False}
    ...                             use_uestatsnr=${use_uestatsnr}          NSA_UE=${NSA_UE}
    ${StatusDl}                     Traffic Check if required
    ...                             ueSetting=${ueRetDl}                    dir=dl
    ...                             throughput=${dl_traffic_throughput}     shouldBeCheck=${shouldBeCheck}
    ...                             deviation=${deviation}                  shouldBeError=${False}
    ...                             use_uestatsnr=${use_uestatsnr}          NSA_UE=${NSA_UE}
    Should be True                  ${StatusUl}                             Traffic UL is KO
    Should be True                  ${StatusDl}                             Traffic DL is KO
    [Teardown]                      Run Keyword If    '${shouldStopTraffic}'=='True'        Run keywords
    ...                             Traffic Stop                            ueSetting=${ueRetUl}      dir=ul     throughput=${ul_traffic_throughput}
    ...                             maxThroughputPerTransfer=${maxThroughputPerTransfer}
    ...    AND                      Traffic Stop                            ueSetting=${ueRetDl}      dir=dl     throughput=${dl_traffic_throughput}
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
    ...                             - *use_uestatsnr*:      Use ue_stats_nr for traffic check (default value: False).
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
    ...                             ${use_uestatsnr}=${False}
    ...                             ${NSA_UE}=${True}                       # Use an NSA UE for traffic check
    ${listUEKO}                     Traffic UEs
    ...                             ueSettingList=${ueSettingList}          dir=dl
    ...                             captureCallback=${captureCallback}      capture=${capture}
    ...                             captureDuration=${captureDuration}      throughput=${throughput}
    ...                             duration=${duration}                    shouldBeStop=${shouldBeStop}
    ...                             shouldBeCheck=${shouldBeCheck}          deviation=${deviation}
    ...                             protocol=${protocol}                    rtp_codec=${rtp_codec}
    ...                             use_uestatsnr=${use_uestatsnr}          NSA_UE=${NSA_UE}
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
    ...                             - *use_uestatsnr*:      Use ue_stats_nr for traffic check (default value: False).
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
    ...                             ${use_uestatsnr}=${False}               # Use ue_stats_nr for traffic check
    ${listUEKO}                     Traffic UEs
    ...                             ueSettingList=${ueSettingList}          dir=ul
    ...                             captureCallback=${captureCallback}      capture=${capture}
    ...                             captureDuration=${captureDuration}      throughput=${throughput}
    ...                             duration=${duration}                    shouldBeStop=${shouldBeStop}
    ...                             shouldBeCheck=${shouldBeCheck}          deviation=${deviation}
    ...                             protocol=${protocol}                    rtp_codec=${rtp_codec}
    ...                             use_uestatsnr=${use_uestatsnr}
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
    ...                             ${use_uestatsnr}=${False}               # Use ue_stats_nr for traffic check
    ...                             ${NSA_UE}=${True}                       # Use NSA UEs for traffic check

    ${shouldBeCheck}                Set Variable If                         '${rtp_codec}'!='${None}'
    ...                             ${False}                                ${shouldBeCheck}
    ${alias}                        SSH Wait for connect                    host=${HOST_EPCSIM}
    # Start traffic for all UEs
    FOR    ${ueSetting}    IN      @{ueSettingList}
            ${ue_size}              Get Variable Value                      ${ueSetting.size}           ${None}
            Traffic Start           ueSetting=${ueSetting}                  dir=${dir}                  throughput=${throughput}
            ...                     protocol=${protocol}                    rtp_codec=${rtp_codec}      size=${ue_size}
    END
    Sleep                           3s
    # Clear stats and wait for duration (1 wait for all UEs)
    FOR    ${ueSetting}    IN      @{ueSettingList}
            Traffic Clear Stats  ueSetting=${ueSetting}                     dir=${dir}
    END
    Tools.Traced Sleep              ${duration}                             waiting for ${duration} capture callback
    # Run capture if required
    Callback Run Capture            callback=${captureCallback}             capture=${capture}          duration=${captureDuration}
    # Check if required
    @{listUEKO}                     Create list
    FOR    ${ueSetting}    IN      @{ueSettingList}
            ${status}               Traffic Check if required
            ...                         ueSetting=${ueSetting}              dir=${dir}
            ...                         throughput=${throughput}            shouldBeCheck=${shouldBeCheck}
            ...                         deviation=${deviation}              shouldBeError=${False}
            ...                         use_uestatsnr=${use_uestatsnr}      NSA_UE=${NSA_UE}
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
    ...                             - *ulThroughput*:       Uplink traffic in Mega (default value: None).
    ...                             - *dlThroughput*:       Downlink traffic in Mega (default value: None).
    ...                             - *use_uestatsnr*:      Use ue_stats_nr for traffic check (default value: False).
    [Arguments]                     ${ueSettingList}                        # List of UE Settings
    ...                             ${throughput}=${NO_THROUGHPUT}          # Traffic en Mega
    ...                             ${captureCallback}=None                 # Reference to a KW call back or None
    ...                             ${capture}=None                         # Associated <Capture> structure if Callback is provided
    ...                             ${captureDuration}=1000ms               # Duration between statand stop of capture
    ...                             ${duration}=60s                         # Duration of Traffic
    ...                             ${deviation}=1                          # indicate deviation in percentage
    ...                             ${shouldBeCheck}=${True}                # Indicate if traffic check is needed
    ...                             ${shouldBeStop}=${True}                # Indicate if traffic check is needed
    ...                             ${ulThroughput}=None                    # Uplink traffic in Mega
    ...                             ${dlThroughput}=None                    # Downlink traffic in Mega
    ...                             ${maxThroughputPerTransfer}=${MAX_THROUGHPUT_PER_TRANSFER}
    ...                             ${protocol}=${None}
    ...                             ${rtp_codec}=${None}
    ...                             ${use_uestatsnr}=${False}               # Use ue_stats_nr for traffic check
    ...                             ${NSA_UE}=${True}                       # Use an NSA UE for traffic check
    ${shouldBeCheck}                Set Variable If                         '${rtp_codec}'!='${None}'
    ...                             ${False}                                ${shouldBeCheck}
    ${alias}                        SSH Wait for connect                    host=${HOST_EPCSIM}

    ${ul_traffic_throughput}        Set Variable If
    ...                             '${ulThroughput}'!='None'              ${ulThroughput}             ${throughput}
    ${dl_traffic_throughput}        Set Variable If
    ...                             '${dlThroughput}'!='None'              ${dlThroughput}             ${throughput}
    @{ueRetUl_List}                  create list
    @{ueRetDl_List}                  create list
    FOR    ${ueSetting}    IN      @{ueSettingList}
        ${ue_size}                      Get Variable Value                     ${ueSetting.size}               ${None}
        ${ueRetUl}                      Traffic Start                          ueSetting=${ueSetting}      dir=ul
        ...                             throughput=${ul_traffic_throughput}    maxThroughputPerTransfer=${maxThroughputPerTransfer}
        ...                             protocol=${protocol}                   rtp_codec=${rtp_codec}          size=${ue_size}
        ${ueRetDl}                      Traffic Start                          ueSetting=${ueSetting}      dir=dl
        ...                             throughput=${dl_traffic_throughput}    maxThroughputPerTransfer=${maxThroughputPerTransfer}
        ...                             protocol=${protocol}                   rtp_codec=${rtp_codec}          size=${ue_size}
        Append to list                  ${ueRetUl_List}                        ${ueRetUl}
        Append to list                  ${ueRetDl_List}                        ${ueRetDl}
    END
    sleep    3s
    FOR    ${ueSetting}    IN      @{ueSettingList}
        Traffic Clear Stats             ueSetting=${ueSetting}                  dir=ul
        Traffic Clear Stats             ueSetting=${ueSetting}                  dir=dl
    END
    Callback Run Capture            callback=${captureCallback}             capture=${capture}          duration=${captureDuration}
    Tools.Traced Sleep              ${duration}                             waiting for ${duration}, then will check traffic
    FOR    ${ueSetting}    IN      @{ueRetUl_List}
        ${StatusUl}                     Traffic Check if required
        ...                             ueSetting=${ueSetting}                  dir=ul
        ...                             throughput=${ul_traffic_throughput}     shouldBeCheck=${shouldBeCheck}
        ...                             deviation=${deviation}                  shouldBeError=${False}
        ...                             use_uestatsnr=${use_uestatsnr}          NSA_UE=${NSA_UE}
        Should be True          ${StatusUl}                             Traffic UL is KO
    END
    FOR    ${ueSetting}    IN      @{ueRetDl_List}
        ${StatusDl}                     Traffic Check if required
        ...                             ueSetting=${ueSetting}                  dir=dl
        ...                             throughput=${dl_traffic_throughput}     shouldBeCheck=${shouldBeCheck}
        ...                             deviation=${deviation}                  shouldBeError=${False}
        ...                             use_uestatsnr=${use_uestatsnr}          NSA_UE=${NSA_UE}
        Should be True          ${StatusDl}                             Traffic DL is KO
    END
    [Teardown]                      Run Keyword if                          '${shouldBeStop}'=='True'
    ...                             Run keywords
    ...                             Traffic Stop UEs                           ueSettingList=${ueRetUl_List}      dir=ul
    ...    AND                      Traffic Stop UEs                           ueSettingList=${ueRetDl_List}      dir=dl

Traffic Stop UEs
    [Documentation]                 INTERNAL USAGE
    ...                             Stop the traffic for all Ue from a ueSettingList
    [Arguments]                     ${ueSettingList}                        # List of UE Settings
    ...                             ${dir}=ul                               # Traffic direction : ul or dl
    FOR     ${ueSetting}    IN      @{ueSettingList}
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
    ...                             ${use_uestatsnr}=${False}
    ...                             ${NSA_UE}=${True}
    # If no check is required : check is OK and we exit the KW
    return from keyword if          ${shouldBeCheck}==${False}              ${True}
    # Otherwise, we check it
    ${status}                       Run keyword and return status           Traffic Check
    ...                             ueSetting=${ueSetting}                  dir=${dir}
    ...                             throughput=${throughput}                deviation=${deviation}
    ...                             use_uestatsnr=${use_uestatsnr}          NSA_UE=${NSA_UE}
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
    ...    Start ${dir} data traffic: UE=${ueRet.ue} Bearer=${ueRet.bearer} TRF=${ueRet.trf_id} Throughput=${ueRet.throughput}M Burst=${ueRet.burst}

    ${nb_trf}                       Get Number Of Transfers
    ...                             throughput=${ueRet.throughput}
    ...                             maxThroughputPerTransfer=${maxThroughputPerTransfer}

    ${remaining_throughput}         Set Variable    ${ueRet.throughput}
    FOR  ${idx}    IN RANGE     ${nb_trf}
        ${trf_id}                   Evaluate    ${ueRet.trf_id}+${idx}
        ${trfThroughput}            Set Variable If
        ...                         ${ueRet.burst}!=${None} and ${ueRet.period_ms}!=${None}    ${None}
        ...                         ${remaining_throughput}==${None}                            ${None}
        ...                         ${remaining_throughput}>=${maxThroughputPerTransfer}        ${maxThroughputPerTransfer}
        ...                         ${remaining_throughput}<${maxThroughputPerTransfer}         ${remaining_throughput}
        Run Keyword If              '${size}'!='${None}'
        ...                         wtsemu.Trf Data Start       ue=${ueRet.ue}
        ...                         id=${ueRet.bearer}                  dir=${dir}
        ...                         mbps=${trfThroughput}               trf_id=${trf_id}
        ...                         qfi=${ueRet.qfi}                    pdu=${ueRet.pdu}
        ...                         burst=${ueRet.burst}                size=${size}
        ...                         protocol=${protocol}                rtp_codec=${rtp_codec}
        ...                         period_ms=${ueRet.period_ms}
        ...    ELSE
        ...                         wtsemu.Trf Data Start       ue=${ueRet.ue}
        ...                         id=${ueRet.bearer}                  dir=${dir}
        ...                         mbps=${trfThroughput}               trf_id=${trf_id}
        ...                         qfi=${ueRet.qfi}                    pdu=${ueRet.pdu}
        ...                         burst=${ueRet.burst}
        ...                         protocol=${protocol}                rtp_codec=${rtp_codec}
        ...                         period_ms=${ueRet.period_ms}
        ${remaining_throughput}     Run Keyword If                      ${remaining_throughput}!=${None} and ${ueRet.period_ms}==${None}
        ...                         Evaluate                            ${remaining_throughput}-${trfThroughput}
    END

    # Code added for feature CB008238-D - Please contact the feature owner before any modification
    ${TIME_LAST_TRAFFIC_START}      DateTime.Get Current Date
    Set Suite Variable              ${TIME_LAST_TRAFFIC_START}

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
    ${nb_trf}                       Set Variable If                   ${ueSetting.period_ms}!=${None}
    ...                             ${1}                              ${nb_trf}

    # Code added for feature CB008238-D - Please contact the feature owner before any modification
    ${TIME_LAST_TRAFFIC_STOP}       DateTime.Get Current Date
    Set Suite Variable              ${TIME_LAST_TRAFFIC_STOP}

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
    [Arguments]                     ${ueSetting}=${UE_NO_PROFILE}
    ...                             ${dir}=ul
    ...                             ${throughput}=${NO_THROUGHPUT}
    ...                             ${deviation}=1
    ...                             ${use_uestatsnr}=${False}
    ...                             ${NSA_UE}=${True}
    ${ueRet}                        Traffic Set Throughput                  ueSetting=${ueSetting}      throughput=${throughput}
    IF    '${NSA_UE}'=='${True}'
        ${scell}    Set Variable    8
    ELSE
        ${scell}    Set Variable    0
    END
    # Only for DL + NSA option dc_cell_group=scg
    IF                  '${dir}'=='dl' and '${ueRet.pdu}'=='${None}' and '${ueRet.qfi}'=='${None}' and '${use_uestatsnr}'=='${False}'
            wtsemu.Bearer Stats                 ue=${ueRet.ue}              id=${ueRet.bearer}         dir=dl
            ...        type=${ueSetting.type}        trf_id=${ueRet.trf_id}      dc_cell_group=scg
            ...        qfi=${ueRet.qfi}              pdu=${ueRet.pdu}
    ELSE IF             '${dir}'=='dl' and '${use_uestatsnr}'=='${True}'
            wtsemu.UE Stats Nr                       id=${ueRet.ue}            scell=${scell}      type=pdsch
    ELSE IF             '${dir}'=='ul' and '${use_uestatsnr}'=='${True}'
            wtsemu.UE Stats Nr                       id=${ueRet.ue}            scell=${scell}      type=pusch
    ELSE
            wtsemu.Bearer Stats                 ue=${ueRet.ue}            id=${ueRet.bearer}
            ...        dir=${dir}                    type=${ueSetting.type}
            ...        trf_id=${ueRet.trf_id}        qfi=${ueRet.qfi}            pdu=${ueRet.pdu}
    END

    ${additional_info}              set variable if     '${ueRet.bearer}'=='${None}'     Call    id=${ueRet.bearer}
    IF    ${ueRet.period_ms}!=${None}
        ${calculated_throughput}    Evaluate    1000/${ueRet.period_ms}*${ueRet.size}*8*${ueRet.burst}
    ELSE
        ${calculated_throughput}    Set Variable    ${ueRet.throughput}000000
    END
    ${status}    ${value}           Run Keyword And Ignore Error            Traffic Check Data Rate
    ...                             expected_data_rate=${calculated_throughput}         deviation_in_percent=${deviation}
    ...                             additional_info=${additional_info}                  use_uestatsnr=${use_uestatsnr}
    ...                             NSA_UE=${NSA_UE}
    Run Keyword If                  '${status}'=='FAIL'                     Fail        Traffic ${dir} Data Failure

Traffic Check Data Rate
    [Documentation]                 INTERNAL USAGE
    ...                             Check data rate in output of bearer_stats or ue_stats_nrin egate console
    ...                             Return 'True' or 'False' upon Real Averaged data rate is in bounds with expected
    ...                             If out of bounds, KW will be FAIL
    [Arguments]                     ${expected_data_rate}                   # expected data rate in mbps
    ...                             ${deviation_in_percent}                 # allowed deviation from expected data rate (in percent)
    ...                             ${additional_info}                      # information to be printed to the console log
    ...                             ${use_uestatsnr}=${False}               # Use ue_stats_nr for traffic check instead of bearer_stats
    ...                             ${NSA_UE}=${True}                       # Use an NSA UE for traffic check
    Dated log New line
    ...    Check data rate: expected=${expected_data_rate}mbps deviation=${deviation_in_percent}%
    Dated log New line
    ...    ${additional_info}
    IF    ${use_uestatsnr}==${False}
        ${expected_stuff}           Set Variable    Average packet interval
        ${str_tosearch}             Set Variable    Average data rate
    ELSE
        ${expected_stuff}           Set Variable    1 cell
        IF    '${NSA_UE}'=='${True}'
            ${str_tosearch}    Set Variable    CellIndex-8
        ELSE
            ${str_tosearch}    Set Variable    CellIndex-0
        END
    END
    ${status}    ${output}    Run Keyword And Ignore Error    wtsemu.read_wtsemu_output_until
    ...    expected=${expected_stuff}    timeout=10
    Run Keyword If    '${status}'=='FAIL'    Fail    No entry for ${str_tosearch} found
    Return From Keyword If    '${status}'=='FAIL'
    ${output}=    Get Lines Containing String    ${output}    ${str_tosearch}
    ${output}=    Replace String    ${output}    ${str_tosearch}    ${EMPTY}
    IF    ${use_uestatsnr}==${True}
        @{words}=    Split String    ${output}
        ${data_rate}=    Strip String    ${words[6]}
        ${data_rate}=    Evaluate    ${data_rate} * 1000000
    ELSE
        @{words}=    Split String    ${output}    (
        ${data_rate}=    Strip String    ${words[0]}
    END
    ${data_rate}                    Convert To Integer                       ${data_rate}
    ${min}=                         Evaluate                                ${expected_data_rate} * (100 - ${deviation_in_percent}) / 100
    ${max}=                         Evaluate                                ${expected_data_rate} * (100 + ${deviation_in_percent}) / 100
    ${statusError}=                 Evaluate                                ${min} <= ${data_rate}
    ${statusWarn}=                  Evaluate                                ${data_rate} <= ${max}
    IF    '${statusError}'=='True'
        ${statusStr}    Set Variable    REACHED
    ELSE
        ${statusStr}    Set Variable    NOT REACHED
    END
    IF    '${statusWarn}'=='True'
        ${statusStr}    Set Variable    ${statusStr}
    ELSE
        ${statusStr}    Set Variable    EXCEEDED
    END
    Dated Log                       Average data rate for ${additional_info}: ${statusStr}: expected = ${expected_data_rate}, current = ${data_rate}
    Run Keyword If                  '${statusError}'!='True'                 Fail    Data rate failure


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

Send UE DL packets
    [Documentation]                 Start the DL data traffic bursts during a particular <period_ms>, then stop it.
    ...                             A check is performed to verify obtained traffic rate is in line with expected one.
    ...                             Optionnaly, a capture can be launched during first second of traffic (BIP Messages for instance).
    ...
    ...                             *Argument details:*
    ...                             - *ueSetting*:          Reference to UE Settings (default value: UE_NO_PROFILE).
    ...                             - *captureCallback*:    Reference to a KW call back or None (default value: None).
    ...                             - *capture*:            Associated <Capture> structure if Callback is provided (default value: None).
    ...                             - *captureDuration*:    Duration between statand stop of capture (default value: 1000ms).
    ...                             - *duration*:           Duration of Traffic (default value: 60s).
    ...                             - *shouldBeStop*:       Indicate if traffic should be stopped (default value: True).
    ...                             - *deviation*:          Indicate deviation in percentage (default value: 1).
    ...                             - *shouldBeCheck*:      Indicate if traffic check is needed (default value: True).
    ...                             - *size*:               Layer 3 packet size range (size includes all headers beginning from IP). \
    ...                                                     Maximum of 1358 for NB-IoT UEs. Maximum of 9000 for UEs configured with NR PDCP. \
    ...                                                     Otherwise, maximum is 8188 (default value: None).
    ...                             - *protocol*:           tcp or udp (default value: None).
    ...                             - *burst*:          Indicate deviation in percentage (default value: 1).
    ...                             - *period_ms*:      For each period burst is send. To not be used with throughput.
    ...                             - *use_uestatsnr*:      Use ue_stats_nr for traffic check (default value: False).
    [Arguments]                     ${ueSetting}=${UE_NO_PROFILE}           # Reference to UE Settings
    ...                             ${captureCallback}=None                 # Reference to a KW call back or None
    ...                             ${capture}=None                         # Associated <Capture> structure if Callback is provided
    ...                             ${captureDuration}=1000ms               # Duration between statand stop of capture
    ...                             ${duration}=60s                         # Duration of Traffic
    ...                             ${shouldBeStop}=${True}                 # Indicate if traffic should be stopped
    ...                             ${deviation}=1                          # Indicate deviation in percentage
    ...                             ${shouldBeCheck}=${True}                # Indicate if traffic check is needed
    ...                             ${size}=100
    ...                             ${protocol}=${None}
    ...                             ${burst}=1
    ...                             ${period_ms}=10
    ...                             ${use_uestatsnr}=${False}               # Use ue_stats_nr for traffic check

    Dated Log New line
    ...    Start DL data traffic : UE=${ueSetting.ue} period_ms=${period_ms} Burst=${burst} Size=${size}
    ${ueSetting.burst}              Set Variable            ${burst}
    ${ueSetting.period_ms}          Set Variable            ${period_ms}
    ${ueSetting.size}               Set Variable            ${size}
    Set Global Variable             ${ueSetting}

    Traffic UE                      ueSetting=${ueSetting}                  dir=dl
    ...                             throughput=${None}
    ...                             captureCallback=${captureCallback}      capture=${capture}
    ...                             captureDuration=${captureDuration}
    ...                             duration=${duration}                    shouldBeStop=${False}
    ...                             deviation=${deviation}                  shouldBeCheck=${shouldBeCheck}
    ...                             size=${size}                            protocol=${protocol}
    ...                             use_uestatsnr=${use_uestatsnr}

    [Teardown]                     Run Keyword if              '${shouldBeStop}'=='True'
    ...                            wtsemu.Trf Data Stop        ue=${ueSetting.ue}                  id=${ueSetting.bearer}
    ...                            dir=dl                      trf_id=${ueSetting.trf_id}
    ...                            qfi=${ueSetting.qfi}        pdu=${ueSetting.pdu}


Send UE UL packets
    [Documentation]                 Start the UL data traffic bursts during a particular <period_ms>, then stop it.
    ...                             A check is performed to verify obtained traffic rate is in line with expected one.
    ...                             Optionnaly, a capture can be launched during first second of traffic (BIP Messages for instance).
    ...
    ...                             *Argument details:*
    ...                             - *ueSetting*:          Reference to UE Settings (default value: UE_NO_PROFILE).
    ...                             - *captureCallback*:    Reference to a KW call back or None (default value: None).
    ...                             - *capture*:            Associated <Capture> structure if Callback is provided (default value: None).
    ...                             - *captureDuration*:    Duration between statand stop of capture (default value: 1000ms).
    ...                             - *duration*:           Duration of Traffic (default value: 60s).
    ...                             - *shouldBeStop*:       Indicate if traffic should be stopped (default value: True).
    ...                             - *deviation*:          Indicate deviation in percentage (default value: 1).
    ...                             - *shouldBeCheck*:      Indicate if traffic check is needed (default value: True).
    ...                             - *size*:               Layer 3 packet size range (size includes all headers beginning from IP). \
    ...                                                     Maximum of 1358 for NB-IoT UEs. Maximum of 9000 for UEs configured with NR PDCP. \
    ...                                                     Otherwise, maximum is 8188 (default value: None).
    ...                             - *protocol*:           tcp or udp (default value: None).
    ...                             - *burst*:              Indicate deviation in percentage (default value: 1).
    ...                             - *period_ms*:          For each period burst is send. To not be used with throughput.
    ...                             - *use_uestatsnr*:      Use ue_stats_nr for traffic check (default value: False).
    [Arguments]                     ${ueSetting}=${UE_NO_PROFILE}           # Reference to UE Settings
    ...                             ${captureCallback}=None                 # Reference to a KW call back or None
    ...                             ${capture}=None                         # Associated <Capture> structure if Callback is provided
    ...                             ${captureDuration}=1000ms               # Duration between statand stop of capture
    ...                             ${duration}=60s                         # Duration of Traffic
    ...                             ${shouldBeStop}=${True}                 # Indicate if traffic should be stopped
    ...                             ${deviation}=1                          # Indicate deviation in percentage
    ...                             ${shouldBeCheck}=${True}                # Indicate if traffic check is needed
    ...                             ${size}=100
    ...                             ${protocol}=${None}
    ...                             ${burst}=1
    ...                             ${period_ms}=10
    ...                             ${use_uestatsnr}=${False}               # Use ue_stats_nr for traffic check

    Dated Log New line
    ...    Start UL data traffic : UE=${ueSetting.ue} period_ms=${period_ms} Burst=${burst} Size=${size}
    ${ueSetting.burst}              Set Variable            ${burst}
    ${ueSetting.period_ms}          Set Variable            ${period_ms}
    ${ueSetting.size}               Set Variable            ${size}
    Set Global Variable             ${ueSetting}

    Traffic UE                      ueSetting=${ueSetting}                  dir=ul
    ...                             throughput=${None}
    ...                             captureCallback=${captureCallback}      capture=${capture}
    ...                             captureDuration=${captureDuration}
    ...                             duration=${duration}                    shouldBeStop=${False}
    ...                             deviation=${deviation}                  shouldBeCheck=${shouldBeCheck}
    ...                             size=${size}                            protocol=${protocol}
    ...                             use_uestatsnr=${use_uestatsnr}

    [Teardown]                     Run Keyword if              '${shouldBeStop}'=='True'
    ...                            wtsemu.Trf Data Stop        ue=${ueSetting.ue}                  id=${ueSetting.bearer}
    ...                            dir=ul                      trf_id=${ueSetting.trf_id}
    ...                            qfi=${ueSetting.qfi}        pdu=${ueSetting.pdu}
