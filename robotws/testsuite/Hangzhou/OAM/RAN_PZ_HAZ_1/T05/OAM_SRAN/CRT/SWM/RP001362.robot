*** Settings ***
Documentation     [PURPOSE]
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ca_swm_general.robot

Library    taf.sbts.oam.coam.admin
Library    String
Library    DateTime
Library    OperatingSystem
Library    ute_async


*** Variables ***
#${sw_package_path}     /home/ute/btsauto/TARGET_SW
#${SW Update Timeout}                        1800  # Given in seconds; That is a timeout for SW download and activation (without reset)
#${ping_loss_timeout}                         240  # Timeout for ping loss during reset
${BTS_OnAir_Timeout}                          30  # Timeout for ping regain during reset
#${restore_timeout}                           240  # Timeout for cells to go OnAir after last update
&{TRSsshConfig}          host_ip=192.168.255.129    ssh_port=22    ssh_username=toor4nsn    ssh_password=oZPS0POrRieRtu


*** Keywords ***
RP001362_SWM__fallback_to_3rd_Airscale_partition
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-9883
    ...
    ...  *****************
    ...  Basic information
    ...  ********************
    ...  **Request ID:** TAT-9883
    ...  *****************
    ...  Main purpose of TC is checking BTS can be back to FDSWon fs3 and start up successfully:
    ...      ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-9883.png

    Set Tags    PHASE-COMPA    CA-SWM    RP001362

    #Pre-Conditions
    Step 0: Suite configuration
    Step 1: Check active and passive sw version
    Step 2: Software fallback to FDSW on fs3
    Step 3: Wait till BTS is stable
    Step 4: Check BTS Running with FDSW on FS3
    Step 5: Recovery BTS

Pre-Conditions
    [Documentation]    Short description.
    #Change parameter to disconnect netact with BTS
    Log    This part of doing upgrade to tested package and downgrade branch package to make sure the meta difference between active and passive
    ${Tested_package}=    Common_Find SW name    ${Target SW dir}
    taf.sbts.oam.coam.admin.update software    ${Tested_package}    True    ${SW Update Timeout}
    check BTS is onair after SW update

Step 0: Suite configuration
    [Documentation]    Short description.
    Log step header  Step 0: Suite configuration
    Set global variable  ${ACTIVE_SW_PATTERN}   SBTS\\d[^7]
    Set global variable  ${PASSIVE_SW_PATTERN}  SBTS\\d[^7]
    taf.sbts.oam.coam.admin.enable ssh access
    ${sm_variant}=  Get SM variant
    Set test variable  ${sm_variant}

    ${GSM_esm}  Run keyword and return status  Checking if GSM on ESM
    Log  GSM cells on ESM: ${GSM_esm}  console=${TRUE}
    ${WCDMA_esm}  Run keyword and return status  Checking if WCDMA on ESM
    Log  WCDMA cells on ESM: ${WCDMA_esm}  console=${TRUE}
    Set test variable  ${GSM_esm}
    Set test variable  ${WCDMA_esm}

Step 1: Check active and passive sw version
    [Documentation]    Short description.
    Log step header  Step 1: Check active and passive sw version
    ${active_sw_before_master}  ${passive_sw_before_master}=  Infomodel Get SW Versions  module=MSM
    #Create Table  sw_table  State  Active  Passive
    #add row  sw_table  Before Master  ${active_sw_before_master}  ${passive_sw_before_master}
    Set tags for software  SW_BEFORE_FALLBACK_MASTER  ${active_sw_before_master}  ${passive_sw_before_master}
    Check if software match software pattern  ${active_sw_before_master}  ${ACTIVE_SW_PATTERN}
    Check if software match software pattern  ${passive_sw_before_master}  ${PASSIVE_SW_PATTERN}
    Set test variable  ${active_sw_before_master}
    Set test variable  ${passive_sw_before_master}

Step 2: Software fallback to FDSW on fs3
    [Documentation]    Short description.
    Log step header  Step 2: Software fallback to FDSW on fs3
    Log  Checking hardware version  console=${TRUE}
    ${command_ASIA}    set variable    memdump -d 0x30800020D8 0x000000BA
    ${command_ASIB}    set variable    memdump -d 0xd0040020D8 0xBA
    ${command_ASIL}    set variable    pcotool -r 0x20d8 0xBA
    ${command}    set variable if   '${BTS_INFO.SYSTEM_MODEL_TYPE}'=='ASIA'    ${command_ASIA}    '${BTS_INFO.SYSTEM_MODEL_TYPE}'=='ASIB'
    ...    ${command_ASIB}    '${BTS_INFO.SYSTEM_MODEL_TYPE}'=='ASIL'    pcotool -r 0x20d8 0xBA
    ...    '${BTS_INFO.SYSTEM_MODEL_TYPE}'=='ASIM'    pcotool -r 0x20d8 0xBA
    ${tcpdumpoutput}    Execute Remote Command and Return Output    ${command}    ssh    &{TRSsshConfig}

Step 3: Wait till BTS is stable
    [Documentation]    Short description.
    Log step header  Step 3: Wait till BTS is stable
    ${ping_loss}  Run keyword and return status  Wait for target to be not reachable  hostname=192.168.255.129  timeout=480
    Run keyword if    not ${ping_loss}  Fail  BTS reset to FS3 can't triggered by command.
    Log  Waiting for ping return  console=${TRUE}
    ${ping_regain}  Run keyword and return status  Wait for target to be reachable  hostname=192.168.255.129  timeout=240
    Run keyword if    not ${ping_regain}  Fail  Ping has not been regained within timeout

    ${ping_status}  Check If Target Is Stable  192.168.255.129  min_uptime=360  max_downtime=420  timeout=1500
    Run keyword if    not ${ping_status}  Fail  BTS is not stable after fallback.
    Log  BTS is stable after fallback to FS3.  console=${TRUE}
    #${admin_working_state}  Run keyword and return status  hran_admin.Admin and Infomodel connections reset  reset_req=${TRUE}
    #Run keyword if    not ${admin_working_state}  Fail  Admin and/or infomodel failure after reset. Interface reset did not help.  console=${TRUE}
    #Log  Wait till Secondary core is stable
    #${ping_status}=  Check If Target Is Stable  192.168.255.119    min_uptime=200    max_downtime=360    remote_host=192.168.255.129
    #...    remote_host_username=toor4nsn   remote_host_password=oZPS0POrRieRtu    timeout=1400
    #Run keyword if    not ${ping_status}  Log  Secondary core lost ping after fallback.

Step 4: Check BTS Running with FDSW on FS3
    [Documentation]    Short description.
    Log step header  Step 4: Check BTS startup with FDSW running on FS3
    Connected to BTS with FDSW RC    ${BTS_INFO.IP}
    Check BTS SW information

Step 5: Recovery BTS
    [Documentation]    Short description.
    Log step header  Step 5: Recovery BTS
    ${active sw partition}=    fdsw.Get active sw partition
    run keyword and ignore error    fdsw.software rollback    ${active sw partition}    timeout=600s
    run keyword and ignore error    taf.fdsw.rc.teardown
    #set dnr counter temp
    sleep    120
    taf.sbts.oam.coam.admin.teardown_admin    alias=default
    Start Admin
    Run Keyword If     ${smod2_variable_exists}      wait until keyword succeeds    95min    30s    _check provision triggered by NE
    Run Keyword If     ${smod2_variable_exists}      set test variable      ${BTS_OnAir_Timeout}      100
    Wait Until Keyword Succeeds  ${BTS_OnAir_Timeout}min  10 sec  Admin Check BTS Procedural and Blocking states  OnAir

Common_Find SW name
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${SW_PATH}: <description>
    ...
    ...    Returns:
    ...        ${SW_PATH_package}: <description>
    [Arguments]    ${SW_PATH}
    ${package name}  OperatingSystem.List files in directory  ${SW_PATH}
    should not be empty  ${package name}  Required package not present in ${SW_PATH}
    ${SW_PATH_package}=  Join Path 	${SW_PATH}  ${package name[0]}
    OperatingSystem.File should exist  ${SW_PATH_package}
    [Return]    ${SW_PATH_package}

check BTS is onair after SW update
    [Documentation]    Short description.
    ${ping loss status}  Run keyword and return status  Wait For Target To Be Not Reachable  hostname=${SMOD1['TRS_IP']}    timeout=900
    Run keyword if  ${ping loss status}==${FALSE}
    ...  Log  BTS RESET after successful SW activation DID NOT OCCUR  console=${TRUE}
    ...  ELSE
    ...  Log  BTS is resetting after successful SW activation  console=${TRUE}
    ${ping regain status}  Run keyword and return status  Wait For Target To Be Reachable  hostname=${SMOD1['TRS_IP']}   timeout=300
    Run keyword if  ${ping regain status}==${FALSE}
    ...  Set Test Failed  Ping has not been regained within timeout
    ...  ELSE
    ...  Log  BTS ping regained  console=${TRUE}
    Log  Waiting for stable ping  console=${TRUE}
    ${ping stable status}  Run keyword and return status  Check If Target Is Stable  ${SMOD1['TRS_IP']}  min_uptime=360  max_downtime=0  timeout=361
    Run keyword if  ${ping stable status}==${FALSE}
    ...  Set Test Failed  Ping has not been available for 60 seconds
    ...  ELSE
    ...  Log  Ping is stable after SWM operation  console=${TRUE}
    Wait Until Keyword Succeeds    5 min    15 sec    taf.sbts.oam.coam.admin.Setup Admin    bts_host=192.168.255.129    bts_port=443
    ...    username=Nemuadmin    password=nemuuser    use_ssl=TRUE    alias=recovery    update_interval=1000    admin_api_log_dir=${Temp Logs Dir}
    Wait until keyword succeeds  15min  10 sec    Admin Check BTS Procedural and Blocking states    OnAir    alias=recovery
    Log Important Message  BTS is OnAir, all cells and modules are in expected states
    taf.sbts.oam.coam.admin.teardown admin    alias=recovery

Connected to BTS with FDSW RC
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${ip_address}: <description>
    ...        ${port}: <description>
    ...        ${username}: <description>
    ...        ${password}: <description>
    ...        ${fdsw_version}: <description>
    ...        ${auto_discover}: <description>
    ...        ${secure}: <description>
    ...        ${name}: <description>
    [Arguments]    ${ip_address}=192.169.255.129   ${port}=443    ${username}=Nemuadmin   ${password}=nemuuser  ${fdsw_version}=fdsw22a
    ...   ${auto_discover}=True    ${secure}=True    ${name}=default
    #taf.fdsw.rc.connect to    ${ip_address}   ${port}    ${username}    ${password}    ${fdsw_version}    ${auto_discover}    ${secure}    ${true}
    taf.fdsw.rc.connect to    ip_address=${ip_address}   port=${port}    username=${username}    password=${password}
    ...    fdsw_version=${fdsw_version}    auto_discover=${auto_discover}    secure=${secure}    name=${name}
    Log  FDSW RC Connected to BTS successfully with MplaneIP

Check BTS SW information
    [Documentation]    Short description.
    Log  start to check BTS sw version
    ${Act_sw_version}=  fdsw.get active sw version name
    ${active_sw_number}  Should match regexp  ${Act_sw_version}  [0-9]{4}_[0-9]{6}_[0-9]{6}
    run keyword and ignore error    should contain    ${active_sw_before_master}    ${active_sw_number}
    ${Run_sw_version}=  fdsw.Get running sw version name
    log  now is running on ${Run_sw_version}  console=true
    run keyword and ignore error    should contain    ${Run_sw_version}    'FDSW'

Check if modules states ok after sw updates
    [Documentation]    Short description.
    Log  Will now check if modules states are correct, for maximum of 60 times with 10s interval  console=True
    FOR  ${run}  IN RANGE  1  60
        ${modules_status}=  Verify modules  RMOD  scf_check=${FALSE}
        run keyword if  '${modules_status}' == 'True'  Run Keywords  Log  Modules states are correct. Check attempt: ${run}  console=true
        ...  AND  Return from keyword  ${modules_status}
        Sleep  10
    END
    Set Test Failed  Modules states not correct within timeout

Verify cells states
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${cells_state_check}: <description>
    ...
    ...    Returns:
    ...        ${cells_state}: <description>
    [Arguments]  ${cells_state_check}
    ${cells_state}=  Run keyword and return status  Wait Until Keyword Succeeds  ${restore_timeout}  5s  ${cells_state_check}
    [Return]  ${cells_state}

Fail if not all cells are on air
    [Documentation]    Short description.
    ${cells_GSM_onair}=  Verify cells  GSM  expected_states=administrativeState=${_Unlocked}, operationalState=${_Enabled},
    ... availabilityStatus=${_Degraded}, blockingState=Unblocked, usageState=Active  scf_check=${scf_parser_started}
    ${cells_WCDMA_onair}=  Verify cells  WCDMA  expected_states=operationalState=${_Enabled}, availabilityStatus=${_Degraded},
    ... blockingState=Unblocked, usageState=Active  scf_check=${scf_parser_started}
    ${cells_LTE_onair}=   Verify cells  LTE  expected_states=administrativeState=${_Unlocked}, operationalState=${_Enabled},
    ... availabilityStatus=${_Degraded}, blockingState=Unblocked  scf_check=${scf_parser_started}
    Run keyword if    not ${cells_GSM_onair} and ${cells_WCDMA_onair} and ${cells_LTE_onair}
    ...  Fail  GSM:${cells_GSM_onair} WCDMA:${cells_WCDMA_onair} LTE:${cells_LTE_onair}

Fail if connection with admin is not available
    [Documentation]    Short description.
    ${status}=  Run keyword and return status   taf.sbts.oam.coam.admin.Get mrbts state
    Run keyword if  ${status}  return from keyword  ${True}
    ${admin_reset_status}  Run keyword and return status  taf.sbts.oam.coam.admin.reset admin
    ${infomodel_reset_status}  Run keyword and return status  ute_admin_infomodel.reset infomodel
    ...  filename=${BTS Files}/IM/InfoModel_untilReset.ims2
    ${status}=  Run keyword and return status   taf.sbts.oam.coam.admin.Get mrbts state
    Run keyword if  ${status}  return from keyword  ${True}
    Fail  ${admin_reset_status}/${infomodel_reset_status}

SW update for RMODs
    [Documentation]    Short description.
    Log  Will now perform SW update on RMODs  console=${TRUE}
    ${sw_update_result}  ${sw_update_msg}=  Run keyword and ignore error
    ...            taf.sbts.oam.coam.admin.Update Software  ${SW path}  True  ${SW Update Timeout}
    run keyword if  '${sw_update_result}'=='FAIL'  Set Test Failed  SW update failed. Reason: ${sw_update_msg}
    Log  Wait until rmods operationalState Enabled  console=${TRUE}
    Wait until keyword succeeds  10 min  30 sec  taf.sbts.oam.coam.admin.Assert Every  RMOD  operationalState=${_Enabled}

Checking if GSM on ESM
    [Documentation]    Short description.
    ${object_parameter}=  Infomodel Get Objects Parameter
    ...  /MRBTS-1/RAT-1/MCTRL-1/BBTOP_M-1/MRBTS_M-1/GNBTS_M-*/CELL_M-*/CHANNEL_GROUP_M-*/CHANNEL_M-*/PATH-*  devicesDNInPath
    ${list_size}  Get Length  ${object_parameter}
    FOR  ${index}  IN RANGE  0  ${list_size}
      ${list}  Get From List  ${object_parameter}  ${index}
      ${status}  Run Keyword And Return Status  Should Contain  ${list[0]}  /BTS_L-4/
      run keyword if  '${status}'=='True'  Return from keyword  ${TRUE}
    END

Checking if WCDMA on ESM
    [Documentation]    Short description.
    ${object_parameter}=  Infomodel Get Objects Parameter
    ...  /MRBTS-1/RAT-1/MCTRL-1/BBTOP_M-1/MRBTS_M-1/WNBTS_M-*/CELL_M-*/CHANNEL_GROUP_M-*/CHANNEL_M-*/PATH-*  devicesDNInPath
    ${list_size}  Get Length  ${object_parameter}
    FOR  ${index}  IN RANGE  0  ${list_size}
      ${list}  Get From List  ${object_parameter}  ${index}
      ${status}  Run Keyword And Return Status  Should Contain  ${list[0]}  /BTS_L-4/
      Run keyword if  '${status}'=='True'  Return from keyword  ${TRUE}
    END

set dnr counter temp
    [Documentation]    Short description.
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    10min    1min    taf.fdsw.rc.enable_ethernet_port_security
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    10min    1min    taf.fdsw.rc.enable_ssh_service
    Set Connection Parameters     192.168.255.129
    ${commands}    set variable    uboot_env del boot_dnr_counter
    ca_swm_general.Run Remote Linux Command    ${commands}
    ca_swm_general.Run Remote Linux Command    reboot
