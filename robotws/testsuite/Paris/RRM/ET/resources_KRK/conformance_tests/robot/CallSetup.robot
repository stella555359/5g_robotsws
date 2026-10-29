*** Settings ***
Documentation                       Module to manage main actions required to setup a call
...                                 Main services are :
...                                     - WTS Setup             : start, configure and establish X2 link on WTS
...                                     - SgNB Addition to ENB  : Launch procedure to attach gNB to eNB

Library                             ../python/ReadConfig.py
Resource                            SetConfig.robot
Resource                            Capture.robot

*** Variables ***
# Default throughtput is 2 mega.
${DEFAUT_THROUGHPUT}                2
${NO_THROUGHPUT}                    0

# Ids for eNB (4G) and gNB (5G) as set in configuration file on WTS
# Changes these calues ONLY accordingly deployed WTS config file
${ENB_ID}                           1
${GNB_ID}                           2
${TARGET_CELLS}                     1

# UE Profile for call Setup         : Dictionary to define different settings required fro call setting
#       ue       :  Ue id
#       profile  : Profile id or None
#       bearer   : bearer id or comma list of bearer ids (2,8,...)
#       tesMode  : should test mode be used (True or False)
#       trf_id   : identifier for the traffic
# List of common useful profiles for traffic
&{UE_NO_PROFILE}                    ue=1                                    profile=None
...                                 bearer=2                                testMode=False
...                                 trf_id=1                                burst=${None}
...                                 target_gnb=2                            target_cells=${TARGET_CELLS}
...                                 throughput=${DEFAUT_THROUGHPUT}         testModeValue=csi_report_override

&{UE_SIMPLE}                        ue=1                                    profile=1
...                                 bearer=2                                testMode=False
...                                 trf_id=1                                burst=${None}
...                                 target_gnb=2                            target_cells=${TARGET_CELLS}
...                                 throughput=${DEFAUT_THROUGHPUT}         testModeValue=csi_report_override

&{UE_SIMPLE_TEST_MODE}              ue=1                                    profile=1
...                                 bearer=2                                testMode=True
...                                 trf_id=1                                burst=${None}
...                                 target_gnb=2                            target_cells=${TARGET_CELLS}
...                                 throughput=${DEFAUT_THROUGHPUT}         testModeValue=csi_report_override

*** Keywords ***
WTS Configure upon format
    [Arguments]                     ${shouldUseLua}=${True}
    ...                             ${luaFile}=${EMPTY}
    Run Keyword if                  ${shouldUseLua}
    ...                             WTS Configure                           ConfigFileName=${luaFile}
    ...   ELSE                      WTS Configure                           ConfigFileName=${tl.core.cfg_filename}

WTS Set Backhaul IP
    [Documentation]                 Retrieve "dynamic" IP@ of UPUE backhaul, then update configuration file on WTS consequently
    [Arguments]                     ${alias}=${HOST_EPCSIM.alias}
    ${output}                       SSH Wait For Connect and Cmd
    ...                             command=sudo ip addr show backhaul | grep -Po 'inet \\K[\\d.]+'
    ...                             host=${HOST_GNB_UPUE}
    ${ip}                           Strip String                            ${output}
    Should Not Be Empty             ${ip}
    Dated log                       \tgNB UPUE backhaul IP: ${ip}
    ${file}                         set variable                            ${tl.core.dir_path}/${tl.core.cfg_filename}
    SSH Cmd                         command= sudo sed -i 's/set ENB2_S1_ADDR=.*/set ENB2_S1_ADDR="${ip}"/g' ${file}
    ...                             alias=${alias}
    SSH Cmd                         sudo fuser -k 2152/udp                  alias=${alias}

#===================================
# GNB Attach to ENB
#===================================
SgNB Addition to ENB
    [Documentation]                 Start gnb attach to enb. A SCTP capture is also started during the SgNB addition
    ...                             Also, another capture (for instance, for BIP messages) may be performed on demand
    ...                             Meaning if a <captureCallback> and its asociated <capture> structure is provided
    [Arguments]                     ${ueSetting}=${UE_NO_PROFILE}           # Reference to UE Settings
    ...                             ${captureCallback}=None                 # Reference to a KW call back or None
    ...                             ${capture}=None                         # Associated <Capture> structure if Callback is provided
    ...                             ${expected_gnb_log}=Successfully reconfigured dual connectivity
    ...                             ${withTN}=${False}
    Dated Log New Line              Starting GNB attach to ENB
    ${captureCORE}                  Capture CORE Set Upon Config
    Capture Init                    ${captureCORE}
    ...                                 withTN=${WithTN}
    ...                                 suffix=_GNB_ADDITION_UE${ueSetting.ue}
    Capture Start                   ${captureCORE}
    UE Attach Enb                   ueSetting=${ueSetting}
    Traced Sleep                    duration=5s                    msg=Workaround for pb Attach Gnb
    UE Attach Gnb                   ueSetting=${ueSetting}
    ...                             captureCallback=${captureCallback}
    ...                             capture=${capture}
    ...                             expected_gnb_log=${expected_gnb_log}
    Capture Stop                    ${captureCORE}
    [Teardown]                      Run keyword if                          '${KEYWORD_STATUS}'!='PASS'
    ...                             Capture Stop                            ${captureCORE}
    [Return]                        ${captureCORE.path}

UE Attach Detach
    [Documentation]                 Attempt a re attach then a detach on GNB
    [Arguments]                     ${ueSetting}=${UE_NO_PROFILE}           # Reference to UE Settings
    UE Attach Enb                   ueSetting=${ueSetting}
    sleep                           30s
    UE Attach Gnb                   ueSetting=${ueSetting}
    sleep                           20s
    UE Detach Enb                   ueSetting=${ueSetting}

UE Attach Check
    [Documentation]                 Check in AP that attach is OK
    ...                             previously : Verify AP Classical UE attach
    Grep and check in file          host=${AIRSCALE_AP.sys[0].M}            file=/tmp/APL3.log
    ...                             grep=crnti    pattern=crnti=

UE Cell Setup Check
    [Documentation]                 Check in AP that cell setup is OK
    ...                             previously : Verify AP Classical Cell Setup
    [Arguments]                     ${waitTime}=60s
    Traced Sleep                    duration=${waitTime}                    msg=UE Cell Setup check
    Grep and check in file          host=${AIRSCALE_AP.sys[0].M}            file=/tmp/APL3.log
    ...                             grep=complete                           pattern=Cell Setup completed

Grep and check in file
    [Arguments]                     ${host}                                 ${file}
    ...                             ${grep}                                 ${pattern}
    Dated log                       Check on ${host.alias}:file ${file} contain pattern [${pattern}]
    ${alias}                        SSH Connect                             ${host}
    ${output}                       SSH Cmd
    ...                                 grep ${grep} ${file}
    ...                                 alias=${alias}
    should contain	                ${output}	                            ${pattern}

Check For SaNsa
    ${UE_SIMPLE.ue}              set variable if    ${isSANSA}    11    1
    ${UE_SIMPLE_TEST_MODE.ue}    set variable if    ${isSANSA}    11    1
    ${UE_NO_PROFILE.ue}          set variable if    ${isSANSA}    11    1


