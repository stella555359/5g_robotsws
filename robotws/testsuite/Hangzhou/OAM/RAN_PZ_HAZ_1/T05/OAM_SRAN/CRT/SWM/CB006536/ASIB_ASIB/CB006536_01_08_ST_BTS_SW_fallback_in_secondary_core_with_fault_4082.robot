*** Settings ***
Documentation     [PURPOSE]
Resource    ../../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource    ../../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource    ../../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource    ../../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Resource    ../../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ca_swm_general.robot
Resource    ../../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Mrat_resource_new.robot


*** Variables ***
${sw_package_path}     /home/ute/btsauto/TARGET_SW
${SW Update Timeout}   1800  # Given in seconds; That is a timeout for SW download and activation (without reset)
${ping_loss_timeout}                         240  # Timeout for ping loss during reset
${ping_regain_timeout}                       900  # Timeout for ping regain during reset
${restore_timeout}                           240  # Timeout for cells to go OnAir after last update
${esm_ip}                        192.168.255.119  # ESM trs ip
${FAULT_4001_TIMEOUT}                         15  # How long should KW wait for fault 4001 [in minutes]
${PC_IP2}                           10.108.152.144


*** Keywords ***
LTE2866-R_01_06_ST BTS SW fallback in secondary core with fault 4082
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-9883
    ...
    ...  *****************
    ...  Main purpose of TC is checking fallback functionality of SBTS SW in dual core configuration:
    ...  fallback from SBTS_SOAM to SBTS_SOAM

    Set Tags    OWNER-henry
    ...         SW-SBT22R4
    ...         FEATURE-CB006536
    Pre-Condition
    Step 1: Check active and passive sw version and import to netact
    Step 2: Software fallback
    Step 3: Critical fault 4082 verification
    Step 4: Check provision triggered by NE
    Step 5: Check BTS is onair

Pre-Condition
    [Documentation]    Short description.
    Run keyword and ignore error    Change parameter to connect netact with BTS
    Log
    ...    Doing upgrade to tested package to make sure the meta difference between active and passive
    ${Tested_package}=    Common_Find SW name    ${Target SW dir}
    set test variable    ${Tested_package}
    taf.sbts.oam.coam.admin.update software    ${Tested_package}    True    ${SW Update Timeout}
    check BTS is onair after update to tested software

check BTS is onair after update to tested software
    [Documentation]    Short description.
    ${ping loss status}  Run keyword and return status
    ...  Wait For Target To Be Not Reachable  hostname=${SMOD1['TRS_IP']}    timeout=900
    Run keyword if  ${ping loss status}==${FALSE}
    ...  Log  BTS RESET after successful SW activation DID NOT OCCUR  console=${TRUE}
    ...  ELSE
    ...  Log  BTS is resetting after successful SW activation...  console=${TRUE}
    ${ping regain status}  Run keyword and return status
    ...  Wait For Target To Be Reachable  hostname=${SMOD1['TRS_IP']}   timeout=300
    Run keyword if  ${ping regain status}==${FALSE}
    ...  Set Test Failed  Ping has not been regained within timeout
    ...  ELSE
    ...  Log  BTS ping regained  console=${TRUE}
    Log  Waiting for stable ping...  console=${TRUE}
    ${ping stable status}  Run keyword and return status  Check If Target Is Stable
    ...  ${SMOD1['TRS_IP']}   min_uptime=360  max_downtime=0  timeout=361
    Run keyword if  ${ping stable status}==${FALSE}
    ...  Set Test Failed  Ping has not been available for 60 seconds
    ...  ELSE
    ...  Log  Ping is stable after SWM operation  console=${TRUE}
    Wait until keyword succeeds  15min  10 sec    Admin Check BTS Procedural and Blocking states
    ...    OnAir    alias=default
    Log Important Message  BTS is OnAir, all cells and modules are in expected states

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

Step 1: Check active and passive sw version and import to netact
    [Documentation]    Short description.
    Log step header  Step 1: Check active and passive sw version
    ${active_sw_before_master}  ${passive_sw_before_master}=  Infomodel Get SW Versions  module=MSM
    ${active_sw_before_ext}  ${passive_sw_before_ext}=  Infomodel Get SW Versions  module=ESM
    Set tags for software  SW_BEFORE_FALLBACK_MASTER  ${active_sw_before_master}  ${passive_sw_before_master}
    Set test variable  ${active_sw_before_master}
    Set test variable  ${passive_sw_before_master}
    Create Directory    /home/ute/btsauto/BASIC_SW/
    ${active_sw_before_master_normal}    Run keyword If    '000000'in'${active_sw_before_master}'
    ...    set variable    ${active_sw_before_master}
    ...    ELSE IF    '9999'in'${active_sw_before_master}'    Replace String Using Regexp
    ...    ${active_sw_before_master}    SBTS[0-9][0-9][A-Z][0-9]?_    SBTS00_
    ${SW_basic_path}=    set variable    /home/ute/btsauto/BASIC_SW/
    ${full_path}    Set Variable  ${SW_basic_path}${active_sw_before_master}_release_BTSSM_downloadable_A54.zip
    Login_with_multiway    ${PC_IP1}    ute    uteUTE!
    ${rc}=    SSHLibrary.Execute Command    find ${full_path}    return_stdout=False    return_rc=True
    ${full_path}    Run keyword if    ${rc}!=0    OperatingSystem.empty directory    /home/ute/btsauto/BASIC_SW/
    ${full_path}    Run keyword if    ${rc}!=0
    ...    Run keyword    Download_Specify_Build_By_Aria    ${active_sw_before_master}    Basic    ${SW_basic_path}
    Set test variable     ${full_path}
    ${passive_sw_before_master_normal}    Run keyword If    '000000'in'${passive_sw_before_master}'
    ...    set variable    ${passive_sw_before_master}
    ...    ELSE IF    '9999'in'${passive_sw_before_master}'    Replace String Using Regexp
    ...    ${passive_sw_before_master}    SBTS[0-9][0-9][A-Z][0-9]?_    SBTS00_
    ${release_NUM}=    should match regexp    ${active_sw_before_master}    SBTS\\d+..
    set test variable    ${release_NUM}
    Log  Check build in Netact otherwise Import
    ${Mid_Server}  ${Mid_Server_usr}  ${Mid_Server_pwd}=  Choose_Mid_Server4Netact  ${NETACT_SERVER_INFO.IP}
    build_download_upload_on_remote_server_and_import_to_Netact  target_sw=${active_sw_before_master_normal}
                                                            ...  release_NUM=${release_NUM}
                                                            ...  remote_ip=${Mid_Server}
                                                            ...  remote_usr=${Mid_Server_usr}
                                                            ...  remote_pwd=${Mid_Server_pwd}

Step 2: Software fallback
    [Documentation]    Short description.
    Log step header  Step 2: Software fallback
    Log  Checking hardware version  console=${TRUE}
    ${sm_variant}    hran_infomodel.Get SM variant
    Software Fallback secondary  ${sm_variant[1]}

Step 3: Wait till Secondary core is stable
    [Documentation]    Short description.
    Log step header  Step 3: Wait till Secondary core is stable
    ${ping_status}=  Check If Target Is Stable  192.168.255.119    min_uptime=200    max_downtime=360
    ...    remote_host=192.168.255.129    remote_host_username=toor4nsn   remote_host_password=oZPS0POrRieRtu
    ...    timeout=1400
    Run keyword if    not ${ping_status}  Log  Secondary core lost ping after fallback.

Step 3: Critical fault 4082 verification
    [Documentation]    Short description.
    Log step header  Step 4: Critical fault 4082 verification and RMOD fault 10 on secondcore
    ${EXPECTED_ALARM}=     Create Dictionary  faultId=4082  severity=Critical
    ${EXPECTED_ALARM_1}=     Create Dictionary  faultId=10  severity=Critical
    ${EXPECTED}=            Create List  ${EXPECTED_ALARM}
#   append to list    ${EXPECTED}    ${EXPECTED_ALARM_1}
    log    ${EXPECTED}
    ${CRITICAL_ALARM1}=     Create Dictionary  severity=Critical|Major
    ${CRITICAL}=            Create List  ${CRITICAL_ALARM1}
    ${alarms_status}  ${alarms_msg}  Run Keyword And Ignore Error  Wait until keyword succeeds
    ...   15min   30s  Admin Check Active Alarms  expected_patterns=${EXPECTED}  critical_patterns=${CRITICAL}
    Run Keyword If  '${alarms_status}'=='FAIL'
    ...  Fail  No Fault 4082 with Critical severity found or other Major|Critical occured
    ...  ELSE IF  ${alarms_msg}
    ...  Set Test Restriction  FID4082 active on BTS with severity=Critical, but some minor faults found: ${alarms_msg}
    ...  ELSE
    ...  Log  Alarm with Fault 4082 active on BTS with severity=Macritical. No other active alarms.  console=${TRUE}

Step 4: Check provision triggered by NE
    [Documentation]    Short description.
    Log step header  Step 4: Check provision triggered by NE
    wait until keyword succeeds    125min    15s    _check provision triggered by NE

Step 5: Check BTS is onair
    [Documentation]    Short description.
    Log step header  Step 5: Check BTS is onair
	sleep  15min
    Wait until keyword succeeds  15min  10 sec  Admin Check BTS Procedural and Blocking states  OnAir  alias=default
    Verify BTS states

Wait fault 4352 disappearred
    [Documentation]    Short description.
    Wait Until Keyword Succeeds    10min   10   taf.sbts.oam.coam.admin.assert alarm inactive
    ...    faultId=4352, severity=Critical

Check if modules states ok after sw updates
    [Documentation]    Short description.
    Log  Will now check if modules states are correct, for maximum of 60 times with 10s interval...  console=True
    FOR  ${run}  IN RANGE  1  60
        ${modules_status}=  Verify modules  RMOD  scf_check=${FALSE}
        run keyword if  '${modules_status}' == 'True'  Run Keywords
        ...  Log  Modules states are correct. Check attempt: ${run}  console=true
        ...  AND  Return from keyword  ${modules_status}
        Sleep  10
    END
    Set Test Failed  Modules states not correct within timeout

Fail if connection with admin is not available
    [Documentation]    Short description.
    ${status}=  Run keyword and return status   taf.sbts.oam.coam.admin.Get mrbts state
    Run keyword if  ${status}  return from keyword  ${True}
    ${admin_reset_status}  Run keyword and return status  taf.sbts.oam.coam.admin.reset admin
    ${infomodel_reset_status}  Run keyword and return status
    ...    ute_admin_infomodel.reset infomodel  filename=${BTS Files}/IM/InfoModel_untilReset.ims2
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
    Wait until keyword succeeds  10 min  30 sec  taf.sbts.oam.coam.admin.Assert Every
    ...  RMOD  operationalState=${_Enabled}

Check ping on ESM after SW update to ESM
    [Documentation]    Short description.
    ${ping_loss_status_ESM_after_ESM_up}  Run keyword and return status
    ...  Wait For Target To Be Not Reachable  hostname=${esm_ip}  timeout=${ping_loss_timeout}
    ...  remote_host=${PC_IP2}
    Run keyword if  ${ping_loss_status_ESM_after_ESM_up}==${False}  Fail  Ping has not been lost within timeout
    Log  ESM lost ping after update  console=${TRUE}
    ${ping_regain_status_ESM_after_ESM_up}  Run keyword and return status
    ...  Wait For Target To Be Reachable  hostname=${esm_ip}  timeout=${ping_regain_timeout}
    ...  remote_host=${PC_IP2}
    Set test variable  ${ping_regain_status_ESM_after_ESM_up}
    Run keyword if  ${ping_regain_status_ESM_after_ESM_up}==${False}  Fail  Ping has not been regained within timeout
    Log  ESM regained ping after reset  console=${TRUE}

Checking if GSM on ESM
    [Documentation]    Short description.
    ${object_parameter}=  Infomodel Get Objects Parameter
    ...  /MRBTS-1/RAT-1/MCTRL-1/BBTOP_M-1/MRBTS_M-1/GNBTS_M-*/CELL_M-*/CHANNEL_GROUP_M-*/CHANNEL_M-*/PATH-*
    ...  devicesDNInPath
    ${list_size}  Get Length  ${object_parameter}
    FOR  ${index}  IN RANGE  0  ${list_size}
      ${list}  Get From List  ${object_parameter}  ${index}
      ${status}  Run Keyword And Return Status  Should Contain  ${list[0]}  /BTS_L-4/
      run keyword if  '${status}'=='True'  Return from keyword  ${TRUE}
    END

Checking if WCDMA on ESM
    [Documentation]    Short description.
    ${object_parameter}=  Infomodel Get Objects Parameter
    ...  /MRBTS-1/RAT-1/MCTRL-1/BBTOP_M-1/MRBTS_M-1/WNBTS_M-*/CELL_M-*/CHANNEL_GROUP_M-*/CHANNEL_M-*/PATH-*
    ...  devicesDNInPath
    ${list_size}  Get Length  ${object_parameter}
    FOR  ${index}  IN RANGE  0  ${list_size}
      ${list}  Get From List  ${object_parameter}  ${index}
      ${status}  Run Keyword And Return Status  Should Contain  ${list[0]}  /BTS_L-4/
      Run keyword if  '${status}'=='True'  Return from keyword  ${TRUE}
    END

Post update ping check without 2G or 3G cells on ESM
    [Documentation]    Short description.
    [Teardown]  Stop async
    Start async  hran_tools  Check If Target Is Stable  ${SMOD1['TRS_IP']}  min_uptime=240  max_downtime=0  timeout=250
    Check ping on ESM after SW update to ESM
    ${ping_status_MSM_after_ESM_up}  Get async result
    Log  ${\n}Was MSM ping stable after update on ESM: ${ping_status_MSM_after_ESM_up}  console=${TRUE}
    Run keyword if    not ${ping_status_MSM_after_ESM_up}  Fail  MSM is not stable after update on ESM.

Post update ping check with 2G or 3G cells on ESM
    [Documentation]    Short description.
    Check ping on ESM after SW update to ESM
    Log  Waiting ${FAULT_4001_TIMEOUT}min for fault 4001  console=${TRUE}
    ${fault_4001_status}  Run keyword and return status  Wait until keyword succeeds
    ...  ${FAULT_4001_TIMEOUT} min  5 sec  Check Fault 4001 after update
    Run keyword if  ${fault_4001_status}
    ...  Run keywords
    ...  Log Important Message  Alarm with Fault 4001 active on BTS  AND
    ...  Reset after 4001
    ...  ELSE
    ...  Log Important Message  Fault 4001 DID NOT APPEAR  level=WARN

Get RMOD by module node id
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${nodeid}: <description>
    ...
    ...    Returns:
    ...        ${RF List}: <description>
    [Arguments]   ${nodeid}
    ${RF List}    create list
    ${module_ID}    taf.sbts.oam.coam.admin.get module id by node id    ${nodeid}
    FOR  ${i}  IN RANGE  1  7
         ${RF}=  taf.sbts.oam.coam.admin.get_rmod_id_by_module_connector    ${module_ID}    RF${i}
         run keyword if  '${RF}'!=''  append to list  ${RF List}   ${RF}
    END
    [return]  ${RF List}

Get RMOD on SecondCore
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${RF_List_on_Second}: <description>
    taf.sbts.oam.coam.admin.Setup Admin    bts_host=${BTS_INFO.IP}    timeout=90
    ${RF_List_on_Second}    create list
    @{MODULE_LIST}    create list    ${22}  ${23}  ${24}
    #@{MODULE_LIST}    create list    ${12}  ${22}  ${13}  ${14}
    FOR  ${module}  IN  @{MODULE_LIST}
         ${RFlistResult}  run keyword and ignore error   Get RMOD by module node id    0x${module}
         ${RF_List_on_module}    run keyword if  '${RFlistResult[0]}'=='PASS'  Evaluate
         ...  ${RF_List_on_Second}+${RFlistResult}[1]
         ${RF_List_on_Second}    set variable if  '${RFlistResult[0]}'=='PASS'
         ...    ${RF_List_on_module}    ${RF_List_on_Second}
    END
    [return]  ${RF_List_on_Second}

_Put_buid_from_local_to_netact_and_import
	[Arguments]    ${sw_release}
	[Documentation]      ${sw_release} is the sw name installed on BTS e.g. SBTS21B_ENB_9999_200727_000001
	Precondition Netact with TAF
	${SWpackagename}    Run keyword If    '000000'in'${sw_release}'    set variable    ${sw_release}
    ...    ELSE IF    '9999'in'${sw_release}'    Replace String Using Regexp    ${sw_release}
    ...  SBTS[0-9][0-9][A-Z][0-9]?_    SBTS00_
    ${status}    taf.nms.netact.Is Imported    ${sw_release}
    Run Keyword If    '${status}'=='False'    Put_buid_from_local_to_netact
    ...    ${Tested_package}    ${SWpackagename}    ${sw_release}
    Run Keyword If    '${status}'=='False'   taf.nms.netact.Import Build
    ...    cd /d/oss/global/swmanager/swm_temp/${sw_release}.zip
    ${status}    taf.nms.netact.Is Imported    ${sw_release}
    Should Be True    ${status}
    [Teardown]    Postcondition Netact with TAF

TC_Custom Setup
    [Documentation]    Short description.
    Common Test Setup
    Delete_uboot_parameters

TC_Custom Teardown
    [Documentation]    Short description.
    Common Test Teardown
    Add_uboot_parameters
