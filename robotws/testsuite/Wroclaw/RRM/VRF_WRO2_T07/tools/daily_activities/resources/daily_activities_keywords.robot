*** Settings ***
Documentation
...   maintainer: Bartosz Kozlowski
...   contact: bartosz.1.kozlowski@nokia.com
...   Keywords for daily activities script

Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/common.robot
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/tools/daily_activities/resources/daily_activities_keywords.py
Library      testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils    WITH NAME    AdminUtils
Library      taf.sbts.oam.coam.admin    WITH NAME    coam
Library      taf.rfrl.bts.devices.du.pm_counters.GnbPmCounter   WITH NAME      GnbCounter


*** Variables ***

${rats}                     ${None}
${SYSLOG_ALIAS}             syslog_daily_activities
${SUSPICIOUS_PRINTS}        "FATAL DSPHWAPI ERROR|-=-=|Invalid memory reference|Please contact the owner|
...                        btsbts  fatality|Abort signal received|Bus error"    # Same prints that UUF scripts check for
${WHITELIST_FILE}           testsuite/Wroclaw/RRM/VRF_WRO2_T07/tools/daily_activities/resources/whitelist.json

*** Keywords ***
Setup Test Variables
    ${result}    Get Active RATs
    Set Global Variable    ${rats}    ${result}

Start Syslog
    log to console    Starting syslog capture
    Start syslog capture    log_name=${SYSLOG_ALIAS}.LOG    alias=${SYSLOG_ALIAS}

Stop And Verify Syslog
    log to console    Stopping syslog capture
    Stop syslog capture    alias=${SYSLOG_ALIAS}
    log to console    Verifying syslog
    Verify syslog daily

Check for active alarms
    [Arguments]         ${ommitted_alarms}
    ${active_alarms}    AdminUtils.get active alarms
    ${major_alarms}     Filter alarms by severity   ${active_alarms}    Major
    ${valid alarms}     Omit alarms                ${major_alarms}  ${ommitted_alarms}
    Should be empty    ${valid_alarms}

Create file with filtered prints for syslog cleanup
    [Arguments]    ${ERR_WARN}
    ...            ${syslog_alias_cleanup}=syslog_cleanup
    ...            ${syslog_path}=${OUTPUT_DIR}/'Daily Activities'/${TEST_NAME}/${syslog_alias_cleanup}.LOG
    ...            ${filtered_prints_path}=${OUTPUT_DIR}/Daily Activities/${TEST_NAME}/ERR_WARN_FILTERED_PRINTS.txt
    log to console      Wait for all cells onair
    AdminUtils.wait_for_all_cells_on_air_state
    log to console    Starting syslog capture for syslog cleanup
    Start syslog capture    log_name=${syslog_alias_cleanup}.LOG    alias=${syslog_alias_cleanup}
    Builtin.Sleep    30s
    log to console    Stopping syslog capture
    Stop syslog capture    alias=${syslog_alias_cleanup}
    Builtin.Sleep    5s
    ${found_grep}    Run    grep -iE ${ERR_WARN} ${syslog_path}
    log to console      Check if there are any valid prints for syslog cleanup and if so - create a file in ${filtered_prints_path}
    ${filtered_prints}   Check for filtered prints    ${found_grep}    ${WHITELIST_FILE}    ${filtered_prints_path}
    Should be empty      ${filtered_prints}

Collect Snapshot
    [Arguments]     ${path_to_snapshot}=${OUTPUT_DIR}/Daily Activities/${TEST_NAME}/snapshot.tar.gz
    log to console    Collecting snapshot
    AdminUtils.Collect snapshot    ${path_to_snapshot}

Backup SCF
    [Arguments]    ${path_to_backup_scf}
    log to console    Performing SCF backup
    AdminUtils.Download current scf    ${path_to_backup_scf}

Revert SCF
    [Arguments]    ${path_to_scf}
    log to console   Reverting SCF
    AdminUtils.Perform Commissioning    scf_file=${path_to_scf}

Download software and perform upgrade
    [Arguments]    ${target_sw_version}
    log to console  Downloading software and performing upgrade
    Check disk space is at least 9 GB
    ${current_sw_version}  AdminUtils.Get Active Sw
    Prevent downgrade   ${target_sw_version}    ${current_sw_version}
    Run Keyword If  '${current_sw_version}' != '${target_sw_version}'
    ...     Update software    ${target_sw_version}

Rollback software
    Rollback software for daily activities
    BuiltIn.Sleep         5m
    AdminUtils.wait_for_all_cells_on_air_state

Update software
    [Arguments]    ${version}
    ${file_exists}     Run keyword and return status
    ...     check if file exists    ${version}
    Run Keyword If     '${file_exists}'=='False'
    ...      Run Keywords
    ...      log to console     Is package present in local dir: ${file_exists}, downloading
    ...     AND     Download SBTS package    ${version}
    ${checksum_status}    Run keyword and return status    Check SHA256 sum    ${version}
    Run Keyword If     '${checksum_status}'=='False'
    ...     Run Keywords
    ...     log to console    Checksum failed, redownloading SBTS software
    ...     AND    Download SBTS package      ${version}
    ...     AND    Check SHA256 sum    ${version}
    Log To Console       Uploading software
    Update software for daily activities     /home/ute/SW_SW/${version}/${version}_release_BTSSM_downloadable_A54.zip
    BuiltIn.Sleep         5m
    AdminUtils.wait_for_all_cells_on_air_state

Download SBTS package
    [Arguments]          ${version}
    ${pkg_url}    Get Software Download Link     ${version}
    ${pkg_url_sha256}    Set Variable    ${pkg_url}.sha256
    Check disk space is at least 9 GB
    Log To Console       Downloading: ${pkg_url_sha256}
    Run          wget ${pkg_url_sha256} -P /home/ute/SW_SW/${version}
    Log To Console       Downloading: ${pkg_url}
    Run          aria2c -x 16 -s 16 ${pkg_url} -d /home/ute/SW_SW/${version}

Check if file exists
    [Arguments]        ${version}
    ${pkg}     Set Variable    ${version}_release_BTSSM_downloadable_A54.zip
    ${result}    Run    find /home/ute/SW_SW/${version}/ -name '${pkg}'
    log to console    ${result}
    should contain    ${result}     ${pkg}

Check SHA256 sum
    [Arguments]        ${version}
    ${pkg}     Set Variable    ${version}_release_BTSSM_downloadable_A54.zip
    ${sum}    Set Variable    ${pkg}.sha256
    ${result}   Run   echo $(cat /home/ute/SW_SW/${version}/${sum}) /home/ute/SW_SW/${version}/${pkg} | sha256sum -c
    should contain    ${result}     OK

Verify syslog daily
    [Arguments]          ${syslog_path}=${OUTPUT_DIR}/'Daily Activities'/${TEST_NAME}/${SYSLOG_ALIAS}.LOG
    ${found_grep}   Run  grep -iE ${SUSPICIOUS_PRINTS} ${syslog_path}
    Should Be Empty  ${found_grep}

Perform Cell Block Unblock
    log to console    Performing cell block/unblock
    Block and unblock all cells     ${rats}
    Wait for OnAir for all RATs     ${rats}

Perform RU Lock Unlock
    log to console    Performing RU lock/unlock
    Lock and unlock all rus
    Wait for OnAir for all RATs     ${rats}

Perform RAT Resets
    log to console    Performing RAT resets
    Reset RATs        ${rats}
    Wait for OnAir for all RATs     ${rats}

Perform BBMOD Resets
    log to console    Performing BBMod resets
    Reset BBMODs
    AdminUtils.Wait For All BBMods Online State

Perform Site Reset
    log to console    Performing Site reset
    AdminUtils.Trigger Site Reset
    Wait for OnAir for all RATs     ${rats}

Perform Site Block and Reset
    log to console    Blocking site and performing site reset
    Block Site
    BuiltIn.Sleep     10
    AdminUtils.Trigger Site Reset
    Wait for OnAir for all RATs     ${rats}

Perform Counters Check
    [Arguments]    ${counters}    ${counter_params}
    log to console    Setting up counter timers to 5 minutes
    Setup Counters Daily               ${counter_params}
    GnbCounter.Wait for next pm period   interval=5
    log to console    Performing counters check
    Check Counters Daily Activities    ${counters}

Perform Random Activities
    log to console    Performing different activites in random order
    ${cell_info}      Get cell ids for each rat     ${rats}
    Shuffle activities   ${cell_info}

Perform Power reset
    log to console    Performing power reset
    power_reset_via_admin
    Wait for OnAir for all RATs     ${rats}
