*** Settings ***
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    ../resources/bts_states.robot
Resource    ../resources/infomodel.robot
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library     ../resources/connection.py
Library     ../resources/bts_alarms.py

*** Variables ***
${load_t1}    	   		        T1
${load_t2}    	   		        T2
${TRUNK_VERSION}                SBTS24R3
${TDD_TRUNK_VERSION}            TL19
${jenkins_url}                  ${BUILD_PATH}
${G_BTSAlias}                   BTSSession
${G_bts_host}                   192.168.255.129
${G_bts_user}                   toor4nsn
${G_bts_passwd}                 oZPS0POrRieRtu


*** Keywords ***
TC__LOGS__CB006772-A_Sanity_Checker_by_uncommission_state_major_fault_of_missing_model_5_ims2_on_both_partitions

    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24357
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Purpose of this test case is verify if multi check points fail (triggered when BTS turns into state of not commissioned),
    ...  only major fault will be raised, and minor fault will be filtered.
    ...  ******************
    ...  History of changes
    ...  ******************

    ...  - 02.01.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24357 - Test rewritten based on BOAM ET test -
    ...  [1.0] CB006772-A_01_Sanity Checker triggered by un-commission state raises major fault of missing model_5.ims2
    ...  on active and passive partition
    ...  - 10.03.2023 - TAT-24917 - Hran_frame resource name change to ca_pm_logs_frame
    ...  - 01.06.2023 - TAT-25054 - due to CB008329 adding value: uboot_env set netboot=unknown

    ...  *******************
    ...  Test case flowchart: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/SBTS/
    ...  LOGS__CB006772-A_Sanity_Checker_triggered_by_un_commission_state_raises_major_fault_of_missing_model_5_ims2_on_active_
    ...  and_passive_partition.png
    ...

    Set Tags      CA-PM  OWNER-iuliia.taupeka@nokia.com  AUTHOR-jiajun.jin@nokia-sbell.com  MAINTAINER-jakub.kokoszka@nokia.com
    ...           GROUP_IN_CHARGE-WRO_6_Vrf PHASE-CRT  SW-SBTS23R1  FEATURE-CB006772-A

    Step 0: Preconditions
    Step 1: Sanity Checker triggered by uncommission state raises major fault of missing model_5.ims2 on active and passive partition


Step 0: Preconditions
    [Documentation]
    ...  In this step test prepare path variable and create taf.sbts.oam.coam.admin connection
    ...  check SW on passive and active partition
    ...  prepare different build from passive partition
    ...  Update software to T1 or T2 SW version

    Log  \nStep 0: Preconditions  console=${True}

    #TAT-25054 BEGIN
    Set Test Variable  ${netboot_change_MSM}  ${False}
    Set Test Variable  ${netboot_change_ESM}  ${False}
    pm_logs_general.Check if MSM is FSMF
    Run Keyword If    ${MSM_is_FSMF}
    ...    Log    The MSM is FSMF in that case: "Set netboot to unknown on MSM" is not needed    console=${True}
    ...    ELSE
    ...    pm_logs_general.Set netboot to unknown on MSM
    pm_logs_general.Check if it is DualCore
    Run Keyword If    ${Dual}    pm_logs_general.Perform netboot to unknown for DualCore
    #TAT-25054 END

    ${bts_connection}=  coam.connect_to
    Set Test Variable  ${BTS_CONNECTION}  ${bts_connection}
    ${SMOD_DN}    coam.Get_Id_For_Current    SMOD
    Set Test Variable  ${SMOD_DN}
    ${enb_release}  coam.get sw release name
    Run Keyword If  '${enb_release}'=='SBTS23R1'
    ...  23R1_failed_sanity_check_point_results
    ...  ELSE   failed_sanity_check_point_results
    ${bts_id}  bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}  ${bts_id}
    Set Test Variable  ${SW_UPDATE}  ${False}
    set test variable  ${destination_dir}  ${BTS Files}/
    set test variable  ${TEST_LOG_DIR}  ${BTS Files}/
    ${fullplan} =    coam.Get Current SCF File
    ...  ${TEST_LOG_DIR}    scf.xml  timeout=120    export_type=configuration  parameters_save_variant=actualValues
	log    ${fullplan}
	Set Test Variable    ${fullplan}
    Get SW load and Type
    Log  Prepare different build from passive partition  console=${True}
	Prepare different build from passive partition
    Log  Update software to ${active_build_T}  console=${True}
	coam.update software    ${destination_dir}${active_build_T}    timeout=3600
    Set Test Variable  ${SW_UPDATE}  ${True}
    Log  Wait for eNB configure and RF swCheckDone status  console=${True}
    Wait for eNB configure and RF swCheckDone status

failed_sanity_check_point_results
    SMOD_check_dual_single
    ${sanity_check_point_results}    Set Variable    Failed sanity check point results:${SMOD_DN_un_commission}:{1a,1b}
    Set Test Variable  ${sanity_check_point_results}
23R1_failed_sanity_check_point_results
    SMOD_check_dual_single
    ${sanity_check_point_results}    Set Variable  Failed sanity check point results: ${SMOD_DN_un_commission}:{1a, 1b}
    Set Test Variable  ${sanity_check_point_results}

SMOD_check_dual_single
    ${rest}  ${last}=  Split String From Right  ${SMOD_DN}  separator=-  max_split=1
    log    ${rest}
    log    ${last}
    ${SMOD_DN_un_commission}    Set Variable If
    ...  ${last}==2    ${rest}-1
    ...  ${last}!=2    ${SMOD_DN}
    Set Test Variable    ${SMOD_DN_un_commission}

Prepare different build from passive partition
    [Documentation]
    ...  This KW Prepare different build from passive partition
	${active_build_T}=     Run Keyword If  '${build_type}' != 'T1'    Prepare build ${destination_dir} ${pre_update_enb_sw['active']} ${load_t1}
    ...  ELSE  Prepare build ${destination_dir} ${pre_update_enb_sw['active']} ${load_t2}
	set test variable      ${active_build_T}

Get SW load and Type
    [Documentation]
    ...  This KW Get SW load and Type
	${pre_update_enb_sw}=  Get active and passive eNB sw versions
	${build_type}=  Should Match Regexp  ${pre_update_enb_sw['passive']}  .{2}$
	set test variable      ${pre_update_enb_sw}
	set test variable	   ${build_type}

Get active and passive eNB sw versions
    [Documentation]
    ...  This KW Get active and passive eNB sw versions
    ${active_sw}=  coam.Get Sw Version
    Log  Active SW - ${active_sw}  console=${True}
    ${passive_sw}=  infomodel.Infomodel Get Passive SW Version
    Log  Passive SW - ${passive_sw}  console=${True}
    ${output}=  Create Dictionary  active=${active_sw}  passive=${passive_sw}

    [Return]  ${output}

Prepare build ${destination_dir} ${current_build} ${load_type}
    [Documentation]
    ...  This KW Prepare build T1 or T2
   ${split_build}=    Split string          ${current_build}    separator=\_
   ${trunk_flag}=     Get from list         ${split_build}     2
   ${version_flag}=   Get from list         ${split_build}     0
   ${download_build}=    Run keyword if    '${trunk_flag}'=='0000'    Set Variable   ${current_build}
					 ...     ELSE IF       '${trunk_flag}'=='1000'    Set Variable   ${current_build}
					 ...     ELSE IF       '${trunk_flag}'=='2000'    Set Variable   ${current_build}
                     ...     ELSE IF       '${version_flag}'=='${TRUNK_VERSION}'  Replace String  ${current_build}  ${TRUNK_VERSION}  SBTS00   #FL00
					 ...     ELSE IF       '${version_flag}'=='${TDD_TRUNK_VERSION}'  Replace String   ${current_build}  ${TDD_TRUNK_VERSION}   TL00
					 ...     ELSE   		Set Variable   ${current_build}
  ${t0_relative_url}=   Set Variable     ${download_build}_release_BTSSM_downloadable_A54.zip
  ${t1_relative_url}=   Set Variable     ${download_build}_release_BTSSM_downloadable_testpackage_T1_A54.zip
  ${t2_relative_url}=   Set Variable     ${download_build}_release_BTSSM_downloadable_testpackage_T2_A54.zip
  ${download_relative_url}   Run keyword if     '${load_type}'=='T0'     Set Variable    ${t0_relative_url}
					 ...     ELSE IF        '${load_type}'=='T1'     Set Variable    ${t1_relative_url}
					 ...     ELSE IF        '${load_type}'=='T2'     Set Variable    ${t2_relative_url}
					 ...     ELSE            Fail  Unexpected load type

  ${SW}  coam.Get Sw Version
  Log    Active Sw Version: ${SW}  console=${true}
  @{SW_splited}    Split String    ${SW}    _
  ${BRANCH}=    Remove String Using Regexp  ${SW_splited[0]}  SBTS
  Run Keyword If  ${SW_splited[2]}==9999
  ...  Wget to file 	     ${jenkins_url}/SBTS00/${download_build}/${download_relative_url}  ${destination_dir}${/}${download_relative_url}
  ...  ELSE
  ...  Wget to file 	     ${jenkins_url}/SBTS${BRANCH}/${download_build}/${download_relative_url}  ${destination_dir}${/}${download_relative_url}
  [Return]              ${download_relative_url}

Wget to file
	[Arguments]       ${url}              ${destination}
	${status}         ${output}=          Run and return rc and output    wget -O ${destination} ${url}
	Run keyword if    '${status}'!='0'    Log    ${output}
	Should be equal   '${status}'         '0'   msg=wget failed (exit code ${status})

Wait for eNB configure and RF swCheckDone status
    [Documentation]
    ...  This KW check if BTS in online after reset
  Wait for Site is pingable
  Wait Until Keyword Succeeds  20m  30s  Check All Modules And All Cells Working States

Wait for Site is pingable
    [Documentation]
    ...  This KW check if Site is pingable
    Log  Waiting Until Host:192.168.255.129 Is Available  console=${True}
    Sleep  180s
    ${is_SMOD_pingable}=    run keyword and return status    wait until keyword succeeds    10 min    30 sec    Check ping on SMOD
    run keyword if    '${is_SMOD_pingable}'=='False'    run keywords    log
    ...    SMOD is not responding still after SW update. Test suite is canceled.    level=WARN    AND    FAIL
	Log  The site is pingable  console=${True}

Check ping on SMOD
    ${output}   Run       ping -c 1 -W 10 192.168.255.129
    Should contain      ${output}   1 packets transmitted, 1 received




Step 1: Sanity Checker triggered by uncommission state raises major fault of missing model_5.ims2 on active and passive partition
    [Documentation]
    ...  In this step test check if Sanity Checker triggered by uncommission state raises major fault of missing model_5.ims2 on active
    ...  and passive partition

    Log  \nStep 1: SanityChecker triggered by uncommission state raises major fault of missing model_5.ims2 on act and pass partition  console=${True}

    @{S_fault_4681_info_major_2}    Create List    7115    BASE STATION INFORMATION    4681    Major    Sanity Check Error
    ...    ${sanity_check_point_results}
	${C_fault_4681}    Create Fault List With SupplAlarmInfo    @{S_fault_4681_info_major_2}
	${num_of_BBMODs_online}=  Query Infomodel  get count //BTS_L-1/EQM_L-1/CABINET_L-1/BBMOD_L-* is [stateInfo.availabilityStatus=Online]
	Set Test Variable  ${num_of_BBMODs_online}
	Connect to bts
	Log  Execute Shell Command: mount -o rw,remount /ffs/stb  console=${True}
	Execute Shell Command    mount -o rw,remount /ffs/stb
	Log  Execute Shell Command: cp /rom/config/model_5.ims2 /ram  console=${True}
	Execute Shell Command    cp /rom/config/model_5.ims2 /ram
	Log  Execute Shell Command: cp /ffs/stb/config/model_5.ims2 /tmp  console=${True}
	Execute Shell Command    cp /ffs/stb/config/model_5.ims2 /tmp
	Log  Execute Shell Command: rm /rom/config/model_5.ims2  console=${True}
	Execute Shell Command    rm /rom/config/model_5.ims2
	Log  Execute Shell Command: rm /ffs/stb/config/model_5.ims2  console=${True}
	Execute Shell Command    rm /ffs/stb/config/model_5.ims2
	Log  Execute Shell Command: reboot  console=${True}
	Execute Shell Command    reboot
    Log  reboot ongoing...  console=${True}
    Wait Until Keyword Succeeds  10m  30s    Check All BBMODs Are Back Online  ${num_of_BBMODs_online}
    sleep    300s    wait BTS can connect
    Disconnect to bts
	${active_alarms}=    coam.Get Active Alarms    timeout=30
	Log    ${active_alarms}
    Check Alarm Exist	${active_alarms}	${C_fault_4681}
	${result_1}    ${output}    Run Keyword And Ignore Error    coam.run_sanity_check
	log    ${result_1}
	${output_string} =    Convert To String    ${output}
	log    ${output_string}
	should Contain    ${output_string}    Check failed
	${active_alarms}=    coam.Get Active Alarms    timeout=30
	Log    ${active_alarms}
	Log  Check if fault 4681 exist  console=${True}
	Check Alarm Exist	${active_alarms}	${C_fault_4681}
	Log  Fault 4681 exist, test end !  console=${True}




Check All BBMODs Are Back Online
    [Arguments]  ${num_BBMODS_expected}
    ${num_of_BBMODs_decommissioned}=  Query Infomodel  get count //BTS_L-1/EQM_L-1/CABINET_L-1/BBMOD_L-* is [stateInfo.availabilityStatus=Online]
    Log  Checking if Online BBMODs num (${num_of_BBMODs_decommissioned}) is = to expected ${num_of_BBMODs_decommissioned}  console=${True}
    Should Be Equal    ${num_BBMODS_expected}  ${num_of_BBMODs_decommissioned}

Create Fault List With SupplAlarmInfo
    [Arguments]    @{faultinfolist}
    ${Alarm_Fault_Info_list}    Create List    faultId=@{faultinfolist}[2]    severity=@{faultinfolist}[3]    faultName=@{faultinfolist}[4]
    ...    supplAlarmInfo=@{faultinfolist}[5]
    Set Test Variable    ${Alarm_Fault_Info_list}
    [Return]    ${Alarm_Fault_Info_list}

Connect to bts
    [Arguments]    ${Alias}=${G_BTSAlias}
    ${BTS_connection}    connection.Connect    ${G_bts_host}    ${G_bts_user}    ${G_bts_passwd}    ${Alias}
    Set Suite Variable    ${BTS_connection}
    [Return]    ${BTS_connection}

Disconnect to bts
    [Arguments]    ${Alias}=${G_BTSAlias}
    Disconnectt    ${Alias}

Custom Test Teardown
    Log  \nCustom Test Teardown  console=${True}

    #TAT-25054 BEGIN
    Run Keyword If    ${netboot_change_MSM}    pm_logs_general.Back netboot to netboot_first on MSM
    Run Keyword If    ${netboot_change_ESM}    pm_logs_general.Back netboot to netboot_first on ESM
    #TAT-25054 END

    Run Keyword If  ${SW_UPDATE}  Run Keywords
    ...  Log    Perform Commissioning   console=${True}
    ...  AND    Wait Until Keyword Succeeds  10m  30s    coam.Perform Commissioning   scf_file=${fullplan}    timeout=900
    ...  AND    Wait for eNB configure and RF swCheckDone status
    ...  AND    Log    Rollback Software    console=${True}
    ...  AND    coam.Rollback Software
    ...  AND    Set Test Variable   ${SW_UPDATE}  ${False}
    ...  AND    Sleep    300
    ...  AND    Wait Until Keyword Succeeds  10m  30s    Check All BBMODs Are Back Online  ${num_of_BBMODs_online}
    ...  AND    Run  rm ${BTS Files}/${active_build_T}
    ...  AND    Log    Perform Commissioning   console=${True}
    ...  AND    Wait Until Keyword Succeeds  10m  30s    coam.Perform Commissioning   scf_file=${fullplan}    timeout=900
    ...  AND    Wait for eNB configure and RF swCheckDone status
    Connect to bts
    Execute Shell Command    cp /ram/SWDLreport.txt /rom/config
	Execute Shell Command    cp /ram/model_5.ims2 /rom/config
	Execute Shell Command    cp /tmp/model_5.ims2 /ffs/stb/config/
    Execute Shell Command    cp /ram/SWDLreport.txt /rom/config
	Execute Shell Command    cp /ram/model_5.ims2 /rom/config
    Disconnect to bts


TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Custom Test Teardown
    ...    AND    Common Test Teardown
