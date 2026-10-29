*** Settings ***
Documentation
...  Manipulate the 4082 sw inconsistent fallback by reboot the site 3 times.
...  Example of execution:
...  pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log -d results testsuite/WMP/SOAM3/SWM/SRAN_SWM/Trunk_Rel4/CRT/
...         Automated__SW_Management__BTS_SW_Fallback_Inconsistent_4082_Trunk_Trunk.robot
...
...  "Author: Lisa.m.li@nokia.com"

#Resource       ${EXECDIR}/testsuite/WMP/SOAM3/SWM/OAM_Common.robot
Library           taf.sbts.oam.coam.admin
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot


*** Variables ***
${BTS_CONF1_path}=                /MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1
${BTS_CONF2_path}=                /MRBTS-1/RAT-1/BTS_L-4/BTS_CONF-1
${destination_dir}=               /home/ute/robotlte/SW_T1/
${SW Activation Timeout}                          1800  # Given in seconds; That is a timeout for SW download and activation (without reset)
${Ping loss timeout}                              420  # Timeout for ping loss during reset
${Ping regain timeout}                            600  # Timeout for ping regain during reset
${BTS_OnAir_Timeout}                               15  # Timeout for BTS on Air (in minutes)
${Test_Timeout}                                    60  # Test timeout (in minutes)
${sleep_Timeout}                                    100
${sw_package_path}      /home/ute/btsauto/TARGET_SW
${First Cell On Air Timeout}                       15                             # Time to wait for first cell on Air (in minutes)
${Make Additional Checks}          ${FALSE}         # Set TRUE if additional check of BTS (cells, modules, alarms) should be taken at the end of TC
                                                                  # Check is performed to ensure that BTS is onAir for some period of time
${Additional Checks Number}        5                              # Number of checks which have to be perform to ensure that bts is onAir
${Sleep interval}                  1 min                    # Time interval between additional checks, if given in minutes, time unit must be added
${Pass If SW exists}               ${False}                # Set True if the test must finish as PASSED when the requested SW is installed yet
${Log KPIs}                        ${TRUE}                        # Parameter created to turn off KPIs logging on demand
${EXPECTED_BTS_STATUS}             OnAir                          # Expected BTS state before TC starts
${EXPECTED_BTS_STATUS_AFTER_SWDL}  OnAir                          # Expected BTS state after SW download and activation,
                                                                  # can be list of values separeted by commas (no spaces) e.g. OnAir,Degraded
${HARDWARE_CHECK_AFTER_UPDATE}     10                             # [min] Time to wait for hardware to have expected states
${onAir Check Number}              60


*** Keywords ***
OAM_LTE2866-R-g_SW_update_end_due_to_SW_already_active_in_BTS_in_dual_core_mode_when_two_half_are_same_and_valid
    [Documentation]    Short description.
                variable_update_define
                ${pre_update_enb_sw}=    Get active and passive eNB sw versions via infomodel in dual core bts
                #Run Keyword If     'T1' in '${pre_update_enb_sw['active_core1']}'
                Log To Console  pre_update_enb_sw['active_core1'] = ${pre_update_enb_sw['active_core1']}
                Log To Console  pre_update_enb_sw['passive_core1'] = ${pre_update_enb_sw['passive_core1']}

				Prepare full build ${destination_dir} ${pre_update_enb_sw['active_core1']}

				Log To Console    SW update to T1 load
				SW activation ${active_build_T}
				run_keyword_and_ignore_error     Check BTS state
				Log To Console  pre_update_enb_sw[active_core1] = ${pre_update_enb_sw['active_core1']}
                Log To Console  pre_update_enb_sw[passive_core1] = ${pre_update_enb_sw['passive_core1']}
                Sleep     ${sleep_Timeout}
				Log To Console    SW update to T0 load
				SW activation ${active_build}
				run_keyword_and_ignore_error     Check BTS state
				Remove SWDLreport.txt

				Log To Console    SW update to T0 load
				SW activation ${active_build}
                Sleep     ${sleep_Timeout}
				Log To Console  pre_update_enb_sw[active_core1] = ${pre_update_enb_sw['active_core1']}
                Log To Console  pre_update_enb_sw[active_core2] = ${pre_update_enb_sw['active_core2']}

                ${post_update_enb_sw}=      Get active and passive eNB sw versions via infomodel in dual core bts

               Check if sw has changed  post_update_sw=${post_update_enb_sw}  partition=active_core1  target_sw=${pre_update_enb_sw['active_core1']}
               Check if sw has changed  post_update_sw=${post_update_enb_sw}  partition=active_core2  target_sw=${pre_update_enb_sw['active_core2']}

               Get and check swdlReport and Targetbd
               Verify syslog against crashes
               Check BTS state
			   #Check if all cells onAir
			   #${enb_build}=    Run Keyword If    '9999' in '${pre_update_enb_sw['active_core1']}'
			   #...  Replace String Using Regexp    ${enb_build}   SBTS\\d{2,2}\\w[0-9]?_    SBTS00_
			   #ELSE    Set Variable    ${enb_build}
               #${Teardown_SW}=     Run Keyword If      '${enb_build}' not in ${release_list_1}     Set variable    ${release_list_1}
               #ELSE IF   '${enb_build}' not in ${release_list_2}     Set variable    ${release_list_2}
               #ELSE IF   '${enb_build}' not in ${release_list_3}      Set variable    ${release_list_3}
              # SW activation ${Teardown_SW}


*** Keywords ***
Prepare full build ${destination_dir} ${current_build}
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${destination_dir}: <description>
    ...        ${current_build}: <description>
    ${Directory_status}=    run keyword and return status  directory should exist    ${destination_dir}
    run keyword if      ${Directory_status}=='False'  Create Directory    ${destination_dir}
    run keyword if       ${Directory_status}    OperatingSystem.empty directory    ${destination_dir}
	${active_build}=  Download_Specify_Build_By_Aria    ${current_build}   Basic    ${destination_dir}
	${active_build_T}=  Download_Specify_Build_By_Aria    ${current_build}   T1    ${destination_dir}
#	${t2_load}=  Prepare build ${destination_dir} ${current_build} T2
    set test variable	   ${active_build}
	set test variable	   ${active_build_T}
#	set test variable	   ${t2_load}

Get active and passive eNB sw versions via infomodel in dual core bts
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${output}: <description>
    Log To Console    Acquire Software Versions on both partitions for dual core bts
    ${bts_conf1}=    ute_admin_infomodel.Get Infomodel Object   dist_name=/MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1   timeout=10
    ${bts_conf2}=    ute_admin_infomodel.Get Infomodel Object   dist_name=/MRBTS-1/RAT-1/BTS_L-4/BTS_CONF-1   timeout=10
    ${activeSW_core1}=      Set Variable    ${bts_conf1.activeSoftwareVersion}
    ${passiveSW_core1}=     Set Variable    ${bts_conf1.passiveSoftwareVersion}
    ${activeSW_core2}=      Set Variable    ${bts_conf2.activeSoftwareVersion}
    ${passiveSW_core2}=     Set Variable    ${bts_conf2.passiveSoftwareVersion}
    Log To Console    Active SW version core1: ${activeSW_core1}
    Log To Console    Passive SW version core1: ${passiveSW_core1}
    Log To Console    Active SW version core2: ${activeSW_core2}
    Log To Console    Passive SW version core2: ${passiveSW_core2}
    ${passiveSW_core1}=    Set Variable If   '${passiveSW_core1}' == '?'   ${activeSW_core1}   ${passiveSW_core1}   ## after fallback passiveSW = ?
    ${passiveSW_core2}=    Set Variable If   '${passiveSW_core2}' == '?'   ${activeSW_core2}   ${passiveSW_core2}   ## after fallback passiveSW = ?
    ${output}=  Create Dictionary
    ...         active_core1=${activeSW_core1}  passive_core1=${passiveSW_core1}  active_core2=${activeSW_core2}  passive_core2=${passiveSW_core2}
    [Return]  ${output}

Check swdlReport and syslog
    [Documentation]    Short description.
    swdlReport should contain "\Additional Information : completed successfully\"

Disable fault 6450 auto trigger snapshot
    [Documentation]    Short description.
	perform_parameter_recommissioning  	dist_name=MRBTS-${BTS_INFO.ID}/MNL-1/MNLENT-1/TRBLCADM-1   parameter=snapshotUploadDelayForFault6450
	...  operation=update value=0

Prepare different build from passive partition
    [Documentation]    Short description.
	${active_build_T}=     Run Keyword If  '${build_type}' != 'T1'    Prepare build ${destination_dir} ${pre_update_enb_sw['active']} ${load_t1}
    ...  ELSE     Prepare different build from passive partition with T1
#                Prepare build ${destination_dir} ${pre_update_enb_sw['active']} ${load_t2}
	set test variable      ${active_build_T}

Prepare different build from passive partition with T1
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${active_build_T}: <description>
    Prepare standby partition for T1 software update
    ${active_build_T}=   Prepare build ${destination_dir} ${pre_update_enb_sw['active']} ${load_t1}
    [Return]    ${active_build_T}

Repare standby partition for T1 software update
    [Documentation]    Short description.
        Execute Command On Enb  mount -o rw,remount /ffs/stb/
        Start Command On Enb  mv /ffs/stb/tmp/* /ffs/stb/
        Execute Command On Enb  rmdir /ffs/stb/tmp
        Sleep  5

Check which load should be downloaded
    [Documentation]    Short description.
    ${To_Down_Load}    Set Variable If
               ...      '${build_type}' !='T1'    ${t1_load}
               ...      '${build_type}' !='T2'    ${t2_load}
    set test variable    ${To_Down_Load}

Check if sw has changed
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${post_update_sw}: <description>
    ...        ${partition}: <description>
    ...        ${target_sw}: <description>
    [Arguments]  ${post_update_sw}=postUpdateSw  ${partition}=partition  ${target_sw}=targetSw

    Log To Console  Check if SW on ${partition} partition has been changed to ${target_sw}
    Should Be True  '${post_update_sw['${partition}']}' == '${target_sw}'
    ...  msg=Post update SW on ${partition} partition doesn't match target Sw.

Check BTS state
    [Documentation]    Short description.
    Log Step Header  step4: Check BTS state
    Log   Will now wait for first cell onAir  console=${TRUE}
    Set test variable  ${cells_LTE_expected_states}  ${cells_LTE_expected_states_after_update}
    Set test variable  ${cells_WCDMA_expected_states}  ${cells_WCDMA_expected_states_after_update}
    Set test variable  ${cells_GSM_expected_states}  ${cells_GSM_expected_states_after_update}
    Wait Until Keyword Succeeds  ${First Cell On Air Timeout} min  1 sec  Check if any cell is onAir
    ${first_cell_onair}=  Get current date
    Set test variable  ${first_cell_onair}
    Log   Will now check if SMODs and RMODs are in expected states:${\n}SMODs:${SMOD_expected_states}${\n}RMODs:${RMOD_expected_states}
    ...   console=${TRUE}
    Wait until keyword succeeds  ${HARDWARE_CHECK_AFTER_UPDATE} min  30 sec  Check System Modules and Radio Modules after update
    ${EXPECTED_BTS_STATUS_AFTER_SWDL}  Split String  ${EXPECTED_BTS_STATUS_AFTER_SWDL}  separator=,  max_split=-1
    Log  check if BTS state is in list of EXPECTED STATES:${EXPECTED_BTS_STATUS_AFTER_SWDL} up to ${onAir Check Number} times with 10s interval.
    ...  console=${TRUE}
    FOR  ${run}  IN RANGE  1  ${onAir Check Number}
        ${BTS check status}  ${BTS_status_after_SWDL}  Run keyword and ignore error  taf.sbts.oam.coam.admin.Get Mrbts State
        Run keyword if  '${BTS_status_after_SWDL}' in ${EXPECTED_BTS_STATUS_AFTER_SWDL}
        ...  Run Keywords  Log  BTS state is ${BTS_status_after_SWDL}! Check attempt: ${run}  console=${TRUE}  AND
        ...  Log  BTS state:${BTS_status_after_SWDL} in LIST of EXPECTED STATES:${EXPECTED_BTS_STATUS_AFTER_SWDL} - YES  console=${TRUE}  AND
        ...  Return from keyword
        Sleep  10
    END
    Set test failed
    ...  BTS state ${BTS_status_after_SWDL} NOT in LIST of EXPECTED STATES:${EXPECTED_BTS_STATUS_AFTER_SWDL} within timeout or the status not obtained

Remove SWDLreport.txt
    [Documentation]    Short description.
    Log To Console   Remove SWDLreport.txt from ENB
    Setup Enb Fsm Access  alias=remove
    Execute Command On Enb  cmd=rm /ffs/run/config/SWDLreport.txt  alias=remove
    Teardown Enb Fsm Access  alias=remove

Get and check swdlReport and Targetbd
    [Documentation]    Short description.
    Setup Enb Fsm Access
    Get eNB targetbd file     destination= ${CURDIR}/targetbd.xml
    Get Enb File  source=/rom/config/SWDLreport.txt  destination=${CURDIR}/
    ${passive_partition}=    Get Enb Partition Path    partition=passive   alias=default

Verify syslog against crashes
    [Documentation]    Short description.
    Run Keyword And Expect Error    *    ute_syslog.Message Should Exist In Syslog File
    ...  'ERR/LFS/LinuxSyslog,*ERR:*fatality*:*2*(EAaErrorFatality_System)'   alias=SMOD1
    Run Keyword And Expect Error    *    ute_syslog.Message Should Exist In Syslog File    'KERNEL ERROR'   alias=SMOD1
    Run Keyword And Expect Error    *    ute_syslog.Message Should Exist In Syslog File
    ...  'FDAR: Unit autonomous reset as recovery action'     alias=SMOD1
    Run Keyword And Expect Error    *    ute_syslog.Message Should Exist In Syslog File
    ...  'FDAR: Unit autonomous reset as recovery action'     alias=SMOD1

Check if all cells onAir
    [Documentation]    Short description.
    Log Step Header  step6: Check if all cells onAir
    Log  Will now wait for all cells to be online. Will check every 10 seconds.  level=INFO  console=${TRUE}
    FOR  ${run}  IN RANGE  1  420
        ${all_cell_status}  ${cell_state_table}  Infomodel Check If All Objects From Path Are Online  ${dist_cells}
        Run keyword if  ${all_cell_status} == ${True}  Run Keywords
        ...  Log  All cells online! Check attempt: ${run}  console=${TRUE}
        ...  AND  Exit For Loop
        Sleep  10
    END
    ${all_cells_onair}=  Get current date
    Run keyword if    ${Make Additional Checks}    Ensure that BTS remains OnAir
    Set test variable  ${all_cells_onair}
    #Log table  ${cell_state_table}
    ${MPLANE_IP}=  Admin Get MPLANE IP
    ${status}=  Run keyword and return status  Admin Check mplane connection  ${MPLANE_IP}
    Run keyword if    not ${status}  Set Test Restriction  Check mplane connection to admin failed!

SW activation ${target}
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${target}: <description>
    Log Step Header  step3: SW activation
    Log  Will now perform software update  console=${TRUE}
    ${sw_update_result}  ${sw_update_msg}=  Run keyword and ignore error
    ...  taf.sbts.oam.coam.admin.Update Software  ${target}  True  ${SW Activation Timeout}
    Run keyword if  '${sw_update_result}'=='FAIL'  Set Test Failed  Software activation failed: ${sw_update_msg}
    ${ping loss status}  Run keyword and return status  Wait For Target To Be Not Reachable  hostname=${SMOD1['TRS_IP']}  timeout=${Ping loss timeout}
    Run keyword if  ${ping loss status}==${FALSE}
    ...  Log  BTS RESET after successful SW activation DID NOT OCCUR  console=${TRUE}
    ...  ELSE
    ...  Log  BTS is resetting after successful SW activation...  console=${TRUE}
    ${ping regain status}  Run keyword and return status  Wait For Target To Be Reachable  hostname=${SMOD1['TRS_IP']}  timeout=${Ping regain timeout}
    Run keyword if  ${ping regain status}==${FALSE}
    ...  Set Test Failed  Ping has not been regained within timeout
    ...  ELSE
    ...  Log  BTS ping regained  console=${TRUE}
    Log  Waiting for stable ping...  console=${TRUE}
    ${ping stable status}  Run keyword and return status  Check If Target Is Stable  ${SMOD1['TRS_IP']}  min_uptime=360  max_downtime=0  timeout=361
    Run keyword if  ${ping stable status}==${FALSE}
    ...  Set Test Failed  Ping has not been available for 60 seconds
    ...  ELSE
    ...  Log  Ping is stable after SWM operation  console=${TRUE}
    Wait Until Keyword Succeeds  5 min  10 sec  Fail if connection with admin is not available
    Wait until keyword succeeds  5 min  10 sec  Fail if connection to infomodel is not available

Fail if connection with admin is not available
    [Documentation]    Short description.
    ${status}=  Run keyword and return status   taf.sbts.oam.coam.admin.Get mrbts state
    Run keyword if  ${status}  Return from keyword
    ${admin_reset_status}  Run keyword and return status  taf.sbts.oam.coam.admin.Reset admin
    ${status}=  Run keyword and return status   taf.sbts.oam.coam.admin.Get mrbts state
    Run keyword if  ${status}  Return from keyword
    Fail  ${admin_reset_status}

Fail if connection to infomodel is not available
    [Documentation]    Short description.
    ${status}=  Run keyword and return status   ute_admin_infomodel.Check infomodel object    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1
    Run keyword if  ${status}  Return from keyword
    ${infomodel_reset_status}  Run keyword and return status  ute_admin_infomodel.Reset infomodel  filename=${BTS Files}/IM/InfoModel_untilReset.ims2
    ${status}=  Run keyword and return status   ute_admin_infomodel.Check infomodel object    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1
    Run keyword if  ${status}  Return from keyword
    Fail  ${infomodel_reset_status}

variable_update_define
    [Documentation]    Short description.
    ${cells_LTE_expected_states_after_update}       set variable
    ...  administrativeState=${_Unlocked}, operationalState=${_Enabled}, blockingState=Unblocked              # expected cells states after upgrade.
    ${cells_WCDMA_expected_states_after_update}     set variable    operationalState=${_Enabled}, blockingState=Unblocked, usageState=Active
    ${cells_GSM_expected_states_after_update}       set variable
    ...  administrativeState=${_Unlocked}, operationalState=${_Enabled}, blockingState=Unblocked, usageState=Active
    set test variable    ${cells_LTE_expected_states_after_update}
    set test variable    ${cells_WCDMA_expected_states_after_update}
    set test variable    ${cells_GSM_expected_states_after_update}

Check if any cell is onAir
    [Documentation]    Short description.
    ${lte}=  Run keyword and return status  taf.sbts.oam.coam.admin.Assert Any  LNCEL  ${cells_LTE_expected_states}
    Run keyword if  ${lte}  Return from keyword
    ${wcdma}=  Run keyword and return status  taf.sbts.oam.coam.admin.Assert Any  WNCEL  ${cells_WCDMA_expected_states}
    Run keyword if  ${wcdma}  Return from keyword
    ${gsm}=  Run keyword and return status  taf.sbts.oam.coam.admin.Assert Any  GNCEL  ${cells_GSM_expected_states}
    Run keyword if  ${gsm}  Return from keyword
    Fail  Any cell is onAir

Check System Modules and Radio Modules after update
    [Documentation]    Short description.
    Log  ${\n}${\n}SMODs/RMODs states check:  console=${TRUE}
    ${are_all_smods_on}  Verify modules  SMOD   expected_states=${SMOD_expected_states}  scf_check=${FALSE}
    ${are_all_rmods_on}  Verify modules  RMOD   expected_states=${RMOD_expected_states}  scf_check=${FALSE}
    Should be true  ${are_all_smods_on} and ${are_all_rmods_on}

Ensure that BTS remains OnAir
    [Documentation]    Short description.
    Log   BTS will be checked ${Additional Checks Number} times with interval ${Sleep interval} if it remains onAir
    ...   console=${TRUE}
    FOR  ${i}  IN RANGE  ${Additional Checks Number}
        ${is_onAir}=    Verify states
        Log    BTS is onAir    console=${TRUE}
        Sleep   ${Sleep interval}
    END

Verify states
    [Documentation]    Short description.
    ${status}  ${system_modules_working}=   Run Keyword And Ignore Error    Verify system modules states
    ${status}  ${radio_modules_working}=    Run Keyword And Ignore Error    Verify radio modules states
    Run keyword if    not ${system_modules_working} and ${radio_modules_working}    Fail    msg=At least one module has state other than expected

    ${status}  ${cells_GSM_onair}=          Run Keyword And Ignore Error    Verify GSM cells states
    ${status}  ${cells_WCDMA_onair}=        Run Keyword And Ignore Error    Verify WCDMA cells states
    ${status}  ${cells_LTE_onair}=          Run Keyword And Ignore Error    Verify LTE cells states
    Run keyword if    not ${cells_GSM_onair} and ${cells_WCDMA_onair} and ${cells_LTE_onair}    Fail
    ...  msg=At least one cell has state other than expected

    ${IGNORED_ALARMS}=      Create Dictionary  severity=Minor
    ${CRITICAL_ALARMS1}=    Create Dictionary  severity=Major
    ${CRITICAL_ALARMS2}=    Create Dictionary  severity=Critical
    ${IGNORED_PATTERNS}=    Create List  ${IGNORED_ALARMS}
    ${CRITICAL_PATTERNS}=   Create List  ${CRITICAL_ALARMS1}   ${CRITICAL_ALARMS2}
    ${alarms_status}  ${alarms_msg}=    Run Keyword And Ignore Error    Admin Check Active Alarms
    ...  ignored_patterns=${IGNORED_PATTERNS}  critical_patterns=${CRITICAL_PATTERNS}
    Run keyword if    not '${alarms_status}'=='PASS'    Fail    msg=Major alarm found.
