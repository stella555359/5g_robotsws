*** Settings ***
Documentation
...     Keywords Purpose:
...         Keywords for COAM features

Library             taf.gnb.oam.coam.admin          WITH NAME       coam
# Library             taf.ul.oam.selenium_coam        WITH NAME       sc
Library             taf.selenium.gnb.oam.coam.classical     WITH NAME       sc
Library             taf.gnb.oam.commissioning       WITH NAME       cms

Library             Collections
Library             DateTime


*** Keywords ***

Create Sessions
    [Documentation]         open coam connection to webEm
    coam.connect to         bts_host=${GN_WEBUI_ASIx}     bts_port=443    name=coam_admin

Create Sessions LMP
    [Documentation]         open coam connection to webEm
    coam.connect to         bts_host=${LMP_IP}     bts_port=3600    name=coam_admin

Teardown Sessions
    [Documentation]         teardown coam connection
    coam.teardown           connection=coam_admin

Software update with coam
    [Documentation]        Download and activate gNB load with coam library via webem
    [Arguments]            ${dl_dir}        ${vers}      ${FSM}      ${FBB}
    ${status}   coam.update_software        sw_package=${dl_dir}/AirScale-${vers}_${FSM}_${FBB}.zip
    ...                                     should_activate=${True}
    ...                                     timeout=1800
    ...                                     connection=coam_admin
    Log                 ${status}
    sleep       60s

Perform gNB Site Reset
    [Documentation]         perform site reset on webEm based on coam connection
    coam.reset_site         connection=coam_admin

Create Snapshot
    [Documentation]         generate Snapshot on webEm based on coam connection
    coam.get_snapshot       target_file_name=${PATH_STORAGE}/snapshot_${current_date}.zip
    ...                     coverage=Full     force=True    connection=coam_admin
    ...                     timeout=600s

Check Rack Type
    [Documentation]         purpose is to check type of sub-rack on webEm based on coam connection
    &{hw_info}=             coam.get_detected_hw_info          connection=coam_admin

    Log          Rack: ${hw_info.cabinets[0].productName}
    Should be equal         ${hw_info.cabinets[0].productName}      AMOD AirScale Outdoor Subrack   msg=Wrong Rack Type

Check AMOB Rack Type
    [Documentation]         purpose is to check type of sub-rack on webEm based on coam connection
    &{hw_info}=             coam.get_detected_hw_info          connection=coam_admin

    Log          Rack: ${hw_info.cabinets[0].productName}
    Should be equal         ${hw_info.cabinets[0].productName}      AMOB AirScale Outdoor Subrack   msg=Wrong Rack Type

Check FSM Status From WEBUI
    [Documentation]         Check AirScale FSM status on webEm based on coam connection

    ${output}=    coam.get_fsm_info    timeout=30    connection=coam_admin
    FOR    ${elem}    IN    @{output}
          Should contain    ${elem['status']['operationalState']}      Enabled
          Should contain    ${elem['status']['availabilityStatus']}    Online
    END

Check FBBs Status From WEBUI
    [Documentation]         Check AirScale FBBs status on webEm based on coam connection
    ${output}=    coam.get_fbb_info    timeout=30    connection=coam_admin
    FOR    ${elem}    IN    @{output}
          Should contain    ${elem['status']['operationalState']}      Enabled
          Should contain    ${elem['status']['availabilityStatus']}    Online
    END

Check RUs Status
    [Documentation]         Verify all Radio modules status on webEm based on coam connection
    ${output}=    coam.get_frm       timeout=30    connection=coam_admin
    Should Not Be Empty    ${output}
    ${nb_lines}       Get Length         ${output}
    FOR    ${i}    IN RANGE   ${nb_lines}
          Should contain     ${output[${i}]['status']['operationalState']}      Enabled
          Should contain     ${output[${i}]['status']['availabilityStatus']}    Online
    END

Check Sync Status
    [Documentation]         Check status of GNSS Sync on webEm based on coam connection
    ${output}=    coam.get_gnsses_statuses    timeout=30    connection=coam_admin
    Should be equal    ${output['GNSSE_R-1']['operationalState']}      Enabled
    Should be equal    ${output['GNSSE_R-1']['availabilityStatus']}    Online

Check Cell Status
    [Documentation]         Check status of all Cells on webEm based on coam connection
    &{dict}=            coam.get_bts_info          connection=coam_admin
    ${nbcells}=     get length      ${dict.cells.nr}
    FOR  ${i}     IN RANGE     0       ${nbcells}
        Should be equal   ${dict.cells.nr[${i}].status.usageState}            Active       msg=Wrong usageState
        Should be equal   ${dict.cells.nr[${i}].status.proceduralStatus}      configured   msg=Wrong proceduralStatus
        Should be equal   ${dict.cells.nr[${i}].status.administrativeState}   Unlocked     msg=Wrong administrativeState
        Should be equal   ${dict.cells.nr[${i}].status.operationalState}      Enabled      msg=Wrong operationalState
        Should be equal   ${dict.cells.nr[${i}].status.blockingState}         Unblocked    msg=Wrong blockingState
    END

Check gNB Status
    &{dict}=            coam.get_bts_info          connection=coam_admin
    Should be equal     ${dict.status.operationalState}      Enabled                  msg=Wrong operationalState
    Should be equal     ${dict.status.blockingState}         Unblocked                msg=Wrong blockingState
    Should be equal     ${dict.status.proceduralState}       OnAir                    msg=Wrong proceduralState

Reset RU Selenium
    [Documentation]         Perform Reset on Radio Module based on coam Selenium Web driving
    sc.enable_virtual_display
    sc.login    https://${GN_WEBUI_ASIx}    ${GN_WEBUI_USER}  ${GN_WEBUI_PASSWORD}
    sc.disable_screen_lock

    sc.reset_ru
    sleep               300s
    [Teardown]          sc.logout

Reset ABIL Selenium
    [Documentation]         Perform Reset on ABIL based on coam Selenium Web driving
    sc.enable_virtual_display
    sc.login    https://${GN_WEBUI_ASIx}    ${GN_WEBUI_USER}  ${GN_WEBUI_PASSWORD}
    sc.disable_screen_lock

    sc.reset_abil
    sleep               300s
    [Teardown]          sc.logout

Enable ssh on WebEM
    [Documentation]         Disable ethernet security and enable SSH access on webEm based on coam connection
    coam.disable_ethernet_port_security         connection=coam_admin
    coam.enable_ssh_access         connection=coam_admin

Commission with scf file
    [Documentation]         Load an SCF file and perform commissioning on webEm based on coam connection
    &{result}    coam.perform_commissioning    scf_file=${scf_file_path}
    ...    timeout=600s    skip_parameter_relation_errors=True    connection=coam_admin

    Should be equal as strings
    ...    ${result['commissioningResult']['activationResult']['resultNode']['parameters']['result']}    Success
    ...       msg=Commissioned with error exists, activation result is not in success status.    ignore_case=${True}
    Should be equal as strings    ${result['validationResult']['niddValidationResult']['status']}    OK
    ...       msg=Commissioned with error exists, nidd validation result is not in OK status    ignore_case=${True}

Cell_Lock_Unlock
    [Documentation]         Perform all Cells lock, then unlock based on coam Selenium Web driving
    &{dict}=            coam.get_bts_info          connection=coam_admin
    ${nbcells}=     get length      ${dict.cells.nr}
    Lock_Cells      ${nbcells}
    Sleep           30s
    Unlock_Cells    ${nbcells}

Lock_Cells
    [Documentation]         Perform Lock on all Cells given in argument based on coam Selenium Web driving
    [Arguments]      ${nbcells}
    sc.enable_virtual_display
    sc.login    https://${GN_WEBUI_ASIx}    ${GN_WEBUI_USER}  ${GN_WEBUI_PASSWORD}
    sc.disable_screen_lock

    FOR  ${i}     IN RANGE     1       ${nbcells}+1
            Log      Locking cell ${i}...
            sc.Lock Cell        cell_idx=${i}
            sleep   30s
            sc.disable_screen_lock
    END
    [Teardown]      sc.logout


Unlock_Cells
    [Documentation]         Perform Unlock on all Cells given in argument based on coam Selenium Web driving
    [Arguments]     ${nbcells}
    sc.enable_virtual_display
    sc.login    https://${GN_WEBUI_ASIx}    ${GN_WEBUI_USER}  ${GN_WEBUI_PASSWORD}
    sc.disable_screen_lock

    FOR  ${i}     IN RANGE     1       ${nbcells}+1
            Log      Unlocking cell ${i}...
            sc.Unlock Cell      cell_idx=${i}
            sleep   30s
            sc.disable_screen_lock
    END
    [Teardown]      sc.logout

Uncommissioned Check with WebEm
    [Documentation]     Check FSM and FBB from webem in uncommissioned mode after power off/on or reset
    ...                 Check if reset time is in KPI
    [Arguments]         ${RESET_MAX_TIME}
    ${Time_Now}=        Get current date
    sleep               120s
    Wait Until Keyword Succeeds         300s         10s      Check FSM Status From WEBUI
    Wait Until Keyword Succeeds         300s         10s      Check FBBs Status From WEBUI
    ${Time_Now}=        Get current date                result_format=%Y-%m-%d_%H:%M:%S
    ${DiffTime}=        Subtract Date from Date         ${Time_Now}     ${RESET_START_DATE}     result_format=number
    ${out}              Convert Time                    ${DiffTime}     verbose
    Run Keyword IF      ${DiffTime} > ${RESET_MAX_TIME}
    ...     Run Keyword and continue on failure     Result_Failure
    ...     ${RESET_START_DATE}      ${Time_Now}       ${out}        Fail       ${TEST_LOOP}
    ...     ELSE
    ...     Run Keyword and continue on failure     Result_success
    ...     ${RESET_START_DATE}      ${Time_Now}       ${out}        Success    ${TEST_LOOP}

Uncommissioned Check with Adet command and WebEM
    [Documentation]     Check FSM and FBB with adet command and from webem after power off/on or reset.
    ...                 Check if reset time is in KPI
    [Arguments]         ${RESET_MAX_TIME}
    ${Time_Now}=        Get current date
    sleep               120s
    Wait Until Keyword Succeeds         300s         10s      Connect To LMP
    Wait Until Keyword Succeeds         300s         10s      Check boards with Adet command
    ${Time_Now}=        Get current date                result_format=%Y-%m-%d_%H:%M:%S
    ${DiffTime}=        Subtract Date from Date         ${Time_Now}     ${RESET_START_DATE}     result_format=number
    ${out}              Convert Time                    ${DiffTime}     verbose
    Run Keyword IF      ${DiffTime} > ${RESET_MAX_TIME}
    ...     Run Keyword and continue on failure     Result_Failure
    ...     ${RESET_START_DATE}      ${Time_Now}       ${out}        Fail       ${TEST_LOOP}
    ...     ELSE
    ...     Run Keyword and continue on failure     Result_success
    ...     ${RESET_START_DATE}      ${Time_Now}       ${out}        Success    ${TEST_LOOP}
    ${out}  run keyword and return status     Check Boards Status from webem
    Run Keyword IF      ${out} == False
    ...     Run Keyword and continue on failure     Result_Failure
    ...     ---------        ---------       Webem        Fail       ${TEST_LOOP}
    ...     ELSE
    ...     Run Keyword and continue on failure     Result_success
    ...     ---------        ---------       Webem        Success    ${TEST_LOOP}

Check Boards Status from webem
    [Documentation]     Check FSM and FBB status from webem
    Wait Until Keyword Succeeds         60s         10s      Check FSM Status From WEBUI
    Wait Until Keyword Succeeds         60s         10s      Check FBBs Status From WEBUI

Get Active Alarms List
    ${active_alarms_list}    Run Keyword And Continue On Failure
    ...                      coam.get_active_alarms   connection=coam_admin   timeout=1
    ${active_alarms_number}  Get Length  ${active_alarms_list}
    ${alarms_list}     Create List
    FOR  ${alarm_id}  IN RANGE  ${active_alarms_number}
                       Append To List  ${alarms_list}   ${active_alarms_list[${alarm_id}]["faultId"]}
    END
    [Return]           @{alarms_list}

Check If Alarm Allowed
    [Arguments]           ${active_alarms}=none   ${allowed_alarms_list}=none
    ${alarms_number}      Get Length              ${active_alarms}
    FOR  ${alarm}        IN RANGE                ${alarms_number}
          ${_alarm}       Get from list           ${active_alarms}      ${alarm}
                          List Should Contain Value       ${allowed_alarms_list}      ${_alarm}
    END

Check status of gNB until cell OnAir
    [Documentation]     Check FSM and FBB with adet command and from webem after power off/on or reset.
    ...                 Check if reset time is in KPI
    [Arguments]         ${RESET_MAX_TIME}
    ${Time_Now}=        Get current date
    sleep               120s
    Wait Until Keyword Succeeds         300s         10s       Connect To LMP
    ${passed}=          Run Keyword and Return Status
    ...                 Wait Until Keyword Succeeds     300s        10s       Check boards with Adet command
    Run Keyword if      ${passed}==False
    ...                 Run Keyword and continue on failure     Result_Failure
    ...                 ${RESET_START_DATE}        ---------       Adet command      Fail      ${TEST_LOOP}
    Run Keyword IF      ${passed}==False                Fail

    ${passed}=          run keyword and return status
     ...                Wait Until Keyword Succeeds     300S        10s       Check Boards Status from webem
    Run Keyword IF      ${passed}==False
    ...                 Run Keyword and continue on failure     Result_Failure
    ...                 ${RESET_START_DATE}        ---------       Webem            Fail       ${TEST_LOOP}
    Run Keyword IF      ${passed}==False                Fail

    ${passed}=          run keyword and return status
    ...                 Wait Until Keyword Succeeds     300S        10s       Check gNB ASIB ABIO containers are running
    Run Keyword if      ${passed}==False
    ...                 Run Keyword and continue on failure     Result_Failure
    ...                 ${RESET_START_DATE}        ---------       gNB containers   Fail       ${TEST_LOOP}
    Run Keyword IF      ${passed}==False                Fail

    ${passed}=          run keyword and return status
    ...                 Wait Until Keyword Succeeds     300S        10s       Check RUs Status
    Run Keyword if      ${passed}==False
    ...                 Run Keyword and continue on failure     Result_Failure
    ...                 ${RESET_START_DATE}        ---------       RU Status         Fail      ${TEST_LOOP}
    Run Keyword IF      ${passed}==False                Fail

    ${passed}=          run keyword and return status
    ...                 Wait Until Keyword Succeeds     300S        10s       Check Cell Status
    Run Keyword if      ${passed}==False
    ...                 Run Keyword and continue on failure     Result_Failure
    ...                 ${RESET_START_DATE}        ---------       Cell Status        Fail     ${TEST_LOOP}
    Run Keyword IF      ${passed}==False                Fail

    ${passed}=          run keyword and return status
    ...                 Wait Until Keyword Succeeds     300S        10s       Check gNB Status
    Run Keyword if      ${passed}==False
    ...                 Run Keyword and continue on failure     Result_Failure
    ...                 ${RESET_START_DATE}        ---------       gNB Status        Fail      ${TEST_LOOP}
    Run Keyword IF      ${passed}==False                Fail

    ${Time_Now}=        Get current date                result_format=%Y-%m-%d_%H:%M:%S
    ${DiffTime}=        Subtract Date from Date         ${Time_Now}     ${RESET_START_DATE}     result_format=number
    ${out}              Convert Time                    ${DiffTime}     verbose
    Run Keyword IF      ${DiffTime} > ${RESET_MAX_TIME}
    ...     Run Keyword and continue on failure     Result_Failure
    ...     ${RESET_START_DATE}      ${Time_Now}       ${out}        Fail       ${TEST_LOOP}
    ...     ELSE
    ...     Run Keyword and continue on failure     Result_success
    ...     ${RESET_START_DATE}      ${Time_Now}       ${out}        Success    ${TEST_LOOP}

Reset configuration gnb
    coam.reset configuration        connection=coam_admin

Save current scf
    coam.get_current_scf_file       local_dir_path=%{HOME}/SCF         file_name=SCF.xml          connection=coam_admin

Backup SCF Parameters
    Create Directory                 ${LOCAL_SCF_DIR_PATH}
    coam.get_current_scf_file        ${LOCAL_SCF_DIR_PATH}            ${ORIG_SCF_FILE_NAME}       connection=coam_admin

Modify SCF Parameters for band
    [Arguments]     ${NRCELL_ID}        ${chBw_value}       ${nrarfcnDl_value}          ${nrarfcnUl_value}
    ...             ${gscn_value}     ${type0CoresetConfigurationIndex_value}
    ...             ${frequencyDensityThresNrb_value}
    &{chBwDl}=      create dictionary   value=${chBw_value}        dist_name=${NRCELL_ID}/NRCELL_FDD-1   p_name=chBwDl
    &{chBwUl}=      create dictionary   value=${chBw_value}        dist_name=${NRCELL_ID}/NRCELL_FDD-1   p_name=chBwUl

    &{nrarfcnDl}=   create dictionary   value=${nrarfcnDl_value}   dist_name=${NRCELL_ID}/NRCELL_FDD-1  p_name=nrarfcnDl
    &{nrarfcnUl}=   create dictionary   value=${nrarfcnUl_value}   dist_name=${NRCELL_ID}/NRCELL_FDD-1  p_name=nrarfcnUl

    &{gscn}=        create dictionary   value=${gscn_value}        dist_name=${NRCELL_ID}                p_name=gscn

    &{frequencyDensityThresNrb0}=   create dictionary   value=${frequencyDensityThresNrb_value}   dist_name=${NRCELL_ID}
    ...                   p_name=frequencyDensityThresNrb0
    &{frequencyDensityThresNrb1}=   create dictionary   value=${frequencyDensityThresNrb_value}   dist_name=${NRCELL_ID}
    ...                   p_name=frequencyDensityThresNrb1

    &{type0CoresetConfigurationIndex}=       create dictionary       value=${type0CoresetConfigurationIndex_value}
    ...         dist_name=${NRCELL_ID}      p_name=type0CoresetConfigurationIndex

    @{scf_parameters}=      create list     ${chBwDl}      ${chBwUl}      ${gscn}      ${type0CoresetConfigurationIndex}
    ...                     ${nrarfcnDl}            ${nrarfcnUl}
    ...                     ${frequencyDensityThresNrb0}        ${frequencyDensityThresNrb1}

    cms.modify_scf                  ${ORIG_SCF}     ${MODIFIED_SCF}     ${scf_parameters}
    coam.perform_commissioning   ${MODIFIED_SCF}   timeout=600s   skip_parameter_relation_errors=True
    ...                              connection=coam_admin
    sleep               120s

Restore SCF Parameters
    coam.perform_commissioning       ${ORIG_SCF}            connection=coam_admin
