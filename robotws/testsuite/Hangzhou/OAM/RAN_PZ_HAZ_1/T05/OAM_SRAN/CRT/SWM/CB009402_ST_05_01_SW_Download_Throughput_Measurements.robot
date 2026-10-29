*** Settings ***
Documentation     [PURPOSE]
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ca_swm_general.robot
Library    taf.sbts.oam.coam.admin
Library    DateTime
Library    OperatingSystem


*** Variables ***
${SW Update Timeout}     3000      # Given in seconds; That is a timeout for SW download and activation (without reset)
${Ping loss timeout}     240       # Timeout for ping loss during reset
${Ping regain timeout}   600       # Timeout for ping regain during reset
${onAir Check Number}              60
# Number of checks for proceduralStatus: onAir (probably since the reset beginning); check interval = 10s
${First Cell On Air Timeout}       15                             # Time to wait for first cell on Air (in minutes)
${Test Timeout}                    7200                           # Test timeout (in minutes)
${EXPECTED_BTS_STATUS}             OnAir                          # Expected BTS state before TC starts
${EXPECTED_BTS_STATUS_AFTER_SWDL}  OnAir                         # Expected BTS state after SW download and activation,
# can be list of values separeted by commas (no spaces) e.g. OnAir,Degraded


*** Keywords ***
TC__CB009402_ST_05_01_SW_Download_Throughput_Measurements
    [Documentation]    Short description.
    Set Tags    CA-SWM    PHASE-CRT
    prepare N_1 package on SBTS    sw_release=25R3
    variable_update_define
    step1: Find path to SW package
    step2: Check SW versions
    step3: SW update
    step4: Calculate the download throughput
    step4: Check BTS state
    step5: Check SW versions
    step6: Check if all cells onAir
    ${SCF_ID}=    Run keyword and ignore error    Request SCFID    ${TESTLINE_NAME}

prepare N_1 package on SBTS
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${sw_release}: <description>
    ...        ${target_path}: <description>
    [Arguments]    ${sw_release}=23R3    ${target_path}=/home/ute/
    #${build_num}=    get_p7p8_build_info  ${sw_release}
    ${N_1_pkg_list}   get_enb    SBTS${sw_release}
    #${N_1_pkg_num}    set variable if   '${build_num}'==' '   ${N_1_pkg_list[-1]}    ${build_num}
    ${N_1_pkg_num}    set variable  ${N_1_pkg_list[1]}
    ${fullpath}=  Download_Specify_Build_By_Aria  enb_build=${N_1_pkg_num}  Package_type=Basic  target_path=${target_path}
    #${fullpath}    set variable    /home/ute/SBTS00_ENB_9999_230824_000005_release_BTSSM_downloadable_A54.zip
    prepare pre release build on SBTS   release=${sw_release}    pkg_full_path=${fullpath}

variable_update_define
    [Documentation]    Short description.
    ${cells_LTE_expected_states_after_update}       set variable
    ...   administrativeState=${_Unlocked}, operationalState=${_Enabled}, blockingState=Unblocked              # expected cells states after upgrade.
    ${cells_WCDMA_expected_states_after_update}     set variable
    ...    operationalState=${_Enabled}, blockingState=Unblocked, usageState=Active                      # expected cells states after upgrade.
    ${cells_GSM_expected_states_after_update}       set variable
    ...    administrativeState=${_Unlocked}, operationalState=${_Enabled}, blockingState=Unblocked, usageState=Active
    ## expected cells states after upgrade. Default - the same as expected cells states before upgrade
    set test variable    ${cells_LTE_expected_states_after_update}
    set test variable    ${cells_WCDMA_expected_states_after_update}
    set test variable    ${cells_GSM_expected_states_after_update}

step2: Check SW versions
    [Documentation]    Short description.
    Log Step Header  step2: Check SW versions
    Check SW version    2    ${Pass If SW exists}
    Run keyword and ignore error  Log NIDD change and collect SCF

step5: Check SW versions
    [Documentation]    Short description.
    Log Step Header   step5: Check SW versions
    Wait until keyword succeeds  5 min  10 sec  Fail if connection to infomodel is not available
    ${After_update_active_SW}   Infomodel Get Active SW Version
    ...    module=MSM  im_param=activeBuildDescriptorId  alias=default
    ${After_update_passive_SW}  Infomodel Get Passive SW Version
    ...    module=MSM  im_param=passiveBuildDescriptorId  alias=default
    Should match Regexp   ${After_update_active_SW}    ${SW_BEFORE_UPDATE_active}

step1: Find path to SW package
    [Documentation]    Short description.
    Log Step Header  step1: Find path to SW package
    Find path to SW package
    Run Keyword If  '${Target SW path}'== ${None}   Fail
    ${file_name}    OperatingSystem.List Directory    ${Target SW dir}
    ${ENB_Trunk_Version}    should match regexp
    ...    ${file_name[0]}    SBTS[0-9][0-9][A-Z]?[0-9]?_ENB_[0-9]{4}(_[0-9]{6})+
    set test variable    ${ENB_Trunk_Version}
    ${size}    Get File Size    ${Target SW path}
    set test variable    ${sw_package_size}    ${size}

sw update
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${Target SW path}: <description>
    [Arguments]  ${Target SW path}=123

    ${sw_update_result}  ${sw_update_msg}=  Run keyword and ignore error
    ...  taf.sbts.oam.coam.admin.Update Software  ${Target SW path}  True  ${SW Update Timeout}
    Run keyword if  '${sw_update_result}'=='FAIL'  Set Test Failed  Software update failed: ${sw_update_msg}
    ${ping loss status}  Run keyword and return status
    ...  Wait For Target To Be Not Reachable  hostname=${SMOD1['TRS_IP']}  timeout=${Ping loss timeout}
    Run keyword if  ${ping loss status}==${FALSE}
    ...   Log    BTS RESET after successful sw update DID NOT OCCUR   console=${TRUE}
    ...       ELSE      Log    BTS is resetting after successful sw update          console=${TRUE}
    ${ping_loss}=  Get current date
    ${ping regain status}  Run keyword and return status
    ...  Wait For Target To Be Reachable  hostname=${SMOD1['TRS_IP']}  timeout=${Ping regain timeout}
    Run keyword if  ${ping regain status}==${False}  Set Test Failed  Ping has not been regained within timeout
    ${ping_regain}=  Get current date
    ${ping stable status}  Run keyword and return status
    ...  Check If Target Is Stable  ${SMOD1['TRS_IP']}  min_uptime=60  max_downtime=0  timeout=61
    Run keyword if  ${ping stable status}==${False}  Set Test Failed  Ping has not been available for 60 seconds

step3: SW update
    [Documentation]    Short description.
    Log Step Header  step3: SW update
    Log  Will now perform software update  console=${TRUE}
    ${software_download_start}    Get current date
    ${sw_update_result}  ${sw_update_msg}=  Run keyword and ignore error
    ...  taf.sbts.oam.coam.admin.Update Software  ${Target SW path}  False  ${SW Update Timeout}
    Run keyword if  '${sw_update_result}'=='FAIL'  Set Test Failed  Software update failed: ${sw_update_msg}
    ${software_download_end}=  Get current date
    set test variable    ${software_download_start}
    set test variable    ${software_download_end}

step4: Calculate the download throughput
    [Documentation]    Short description.
    ${timedelta}  Subtract Date From Date   ${software_download_end}  ${software_download_start}
    ${throughput}  Evaluate    ${sw_package_size}/${timedelta}
    set test variable    ${Download_Throughput}    ${throughput}
    Set tags    Download_Throughput:${Download_Throughput}bytes/s

step4: Check BTS state
    [Documentation]    Short description.
    Log Step Header  step4: Check BTS state
    Log   Will now wait for first cell onAir  console=${TRUE}
    Set test variable  ${cells_LTE_expected_states}  ${cells_LTE_expected_states_after_update}
    Set test variable  ${cells_WCDMA_expected_states}  ${cells_WCDMA_expected_states_after_update}
    Set test variable  ${cells_GSM_expected_states}  ${cells_GSM_expected_states_after_update}
    Wait Until Keyword Succeeds  ${First Cell On Air Timeout} min  1 sec  Check if any cell is onAir
    ${first_cell_onair}=  Get current date
    Set test variable  ${first_cell_onair}
    Log   check if SMODs,RMODs are in expected :${\n}SMODs:${SMOD_expected_states}${\n}RMODs:${RMOD_expected_states}
    ...  console=${TRUE}
    Wait until keyword succeeds
    ...  ${HARDWARE_CHECK_AFTER_UPDATE} min  30 sec  Check System Modules and Radio Modules after update
    ${EXPECTED_BTS_STATUS_AFTER_SWDL}  Split String  ${EXPECTED_BTS_STATUS_AFTER_SWDL}  separator=,  max_split=-1
    Log  check if BTS state is in EXPECTED:${EXPECTED_BTS_STATUS_AFTER_SWDL} up to ${onAir Check Number} times with 10s
    ...  console=${TRUE}
    FOR  ${run}  IN RANGE  1  ${onAir Check Number}
        ${BTS check status}  ${BTS_status_after_SWDL}
        ...  Run keyword and ignore error  taf.sbts.oam.coam.admin.Get Mrbts State
        Run keyword if  '${BTS_status_after_SWDL}' in ${EXPECTED_BTS_STATUS_AFTER_SWDL}
        ...  Run Keywords  Log  BTS state is ${BTS_status_after_SWDL}! Check attempt: ${run}  console=${TRUE}  AND
        ...  Log  BTS state:${BTS_status_after_SWDL} in EXPECTED STATES:${EXPECTED_BTS_STATUS_AFTER_SWDL} - YES
        ...  console=${TRUE}  AND
        ...  Return from keyword
        Sleep  10
    END
    Set test failed
    ...  BTS state:${BTS_status_after_SWDL} NOT in EXPECTED:${EXPECTED_BTS_STATUS_AFTER_SWDL} orstatus not obtained

step6: Check if all cells onAir
    [Documentation]    Short description.
    Log Step Header  step6: Check if all cells onAir
    Check if all cells onAir

Check if all cells onAir
    [Documentation]    Short description.
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

step7: Check active alarms
    [Documentation]    Short description.
    Log Step Header  step7: Check active alarms
    ${CRITICAL_ALARMS1}=    Create Dictionary  severity=Major
    ${CRITICAL_ALARMS2}=    Create Dictionary  severity=Critical
    ${CRITICAL_PATTERNS}=   Create List  ${CRITICAL_ALARMS1}   ${CRITICAL_ALARMS2}
    ${alarms_status}  ${alarms_return}=    Run Keyword And Ignore Error    Admin Check Active Alarms
    ...  critical_patterns=${CRITICAL_PATTERNS}
    Run keyword if   '${alarms_status}'=='FAIL'  Fail                  Major/Critical alarm found.
    Run keyword if    ${alarms_return}           Set Test Restriction  Minor alarm found.

Check if any cell is onAir
    [Documentation]    Short description.
    ${lte}=  Run keyword and return status  taf.sbts.oam.coam.admin.Assert Any  LNCEL  ${cells_LTE_expected_states}
    Run keyword if  ${lte}  Return from keyword
    ${wcdma}=  Run keyword and return status  taf.sbts.oam.coam.admin.Assert Any  WNCEL  ${cells_WCDMA_expected_states}
    Run keyword if  ${wcdma}  Return from keyword
    ${gsm}=  Run keyword and return status  taf.sbts.oam.coam.admin.Assert Any  GNCEL  ${cells_GSM_expected_states}
    Run keyword if  ${gsm}  Return from keyword
    ${nr}=  Run keyword and return status  taf.sbts.oam.coam.admin.Assert Any  NRCEL  ${cells_NR_expected_states}
    Run keyword if  ${nr}  Return from keyword
    Fail  Any cell is onAir

Log NIDD change and collect SCF
    [Documentation]    Short description.
    Log  Log NIDD change, collect and validate SCF before download and activation  console=${TRUE}
    ${active_package_name}  Get TargetBD Attribute Value From Active Partition  swReleaseVersionPackageName
    ${target_package_name}  Get TargetBD Node Attribute Value  swReleaseVersionPackageName  ${Target SW path}
    Log  active sw: ${active_package_name}\ntarget swReleaseVersionPackageName: ${target_package_name}  console=${TRUE}
    ${active_sw}  Should match regexp  ${active_package_name}  SBTS.+_ENB_[0-9]{4}_[0-9]{6}_[0-9]{6}
    ${target_sw}  Should match regexp  ${target_package_name}  SBTS.+_ENB_[0-9]{4}_[0-9]{6}_[0-9]{6}
    taf.sbts.oam.coam.admin.Collect SCF  ${BTS Files}/SCF_${active_sw}_before_SW_Download.xml
    ${scf_valid}  ${msg}  Run Keyword And Ignore Error
    ...  taf.sbts.oam.coam.admin.Validate Scf
    ...    scf_file=${BTS Files}/SCF_${active_sw}_before_SW_Download.xml  timeout=240
    Run Keyword If  '${scf_valid}'=='FAIL'  Set Test Restriction
    ...  SCF Validation on BASE SW:${active_sw} failed:\n${msg}
    Log  SCF has been saved under ${BTS Files}/SCF_${active_sw}_before_SW_Download.xml  console=${TRUE}
    ${NIDD_CHANGE}=  wft.Check Nidd Change  ${active_sw}  ${target_sw}
    Log  Between ${active_sw} and ${target_sw} NIDD_RADIO, SBTS_NIDD change: ${NIDD_CHANGE}  console=${TRUE}

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
    ${status}=  Run keyword and return status   ute_admin_infomodel.Check infomodel object
    ...    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1
    Run keyword if  ${status}  Return from keyword
    ${infomodel_reset_status}  Run keyword and return status
    ...  ute_admin_infomodel.Reset infomodel  filename=${BTS Files}/IM/InfoModel_untilReset.ims2
    ${status}=  Run keyword and return status   ute_admin_infomodel.Check infomodel object
    ...    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1
    Run keyword if  ${status}  Return from keyword
    Fail  ${infomodel_reset_status}

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
    Run keyword if    not ${system_modules_working} and ${radio_modules_working}    Fail
    ...    msg=At least one module has state other than expected

    ${status}  ${cells_GSM_onair}=          Run Keyword And Ignore Error    Verify GSM cells states
    ${status}  ${cells_WCDMA_onair}=        Run Keyword And Ignore Error    Verify WCDMA cells states
    ${status}  ${cells_LTE_onair}=          Run Keyword And Ignore Error    Verify LTE cells states
    Run keyword if    not ${cells_GSM_onair} and ${cells_WCDMA_onair} and ${cells_LTE_onair}    Fail
    ...    msg=At least one cell has state other than expected

    ${IGNORED_ALARMS}=      Create Dictionary  severity=Minor
    ${CRITICAL_ALARMS1}=    Create Dictionary  severity=Major
    ${CRITICAL_ALARMS2}=    Create Dictionary  severity=Critical
    ${IGNORED_PATTERNS}=    Create List  ${IGNORED_ALARMS}
    ${CRITICAL_PATTERNS}=   Create List  ${CRITICAL_ALARMS1}   ${CRITICAL_ALARMS2}
    ${alarms_status}  ${alarms_msg}=    Run Keyword And Ignore Error    Admin Check Active Alarms
    ...  ignored_patterns=${IGNORED_PATTERNS}  critical_patterns=${CRITICAL_PATTERNS}
    Run keyword if    not '${alarms_status}'=='PASS'    Fail    msg=Major alarm found.

Check System Modules and Radio Modules after update
    [Documentation]    Short description.
    Log  ${\n}${\n}SMODs/RMODs states check:  console=${TRUE}
    ${are_all_smods_on}  Verify modules  SMOD   expected_states=${SMOD_expected_states}  scf_check=${FALSE}
    ${are_all_rmods_on}  Verify modules  RMOD   expected_states=${RMOD_expected_states}  scf_check=${FALSE}
    Should be true  ${are_all_smods_on} and ${are_all_rmods_on}

Request SCFID
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${scout_testline_name}: <description>
    [Arguments]   ${scout_testline_name}
    scout.setup_scout  scout_testline_name=${scout_testline_name}
    ${external_scf_id}=   scout.request_scf   use_scout_internal_id=False
    scout.teardown_scout_api
