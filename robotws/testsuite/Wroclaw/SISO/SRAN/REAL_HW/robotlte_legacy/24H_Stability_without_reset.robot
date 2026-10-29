*** Settings ***
Documentation  Maintainers: @I_SRAN_PROD_SISO_WRO_CRTDEV_GMS

Resource    ../Resources/Setup/setup_and_teardown.robot
#Resource  ./common_setup.robot
#Resource  ./site_operations.robot
#Resource  ./site_verifications.robot
#Resource  ./variables.robot


Library  BuiltIn
Library  Collections
Library  String
Library  taf.sbts.oam.coam.admin    WITH NAME    admin
Library  ute_admin_infomodel    WITH NAME    admin_im



*** Keywords ***

Perform Stability Test Without Reset
    [Arguments]
    ...  ${alias}=${cfg.primary_node_bts_id}

    ${status_total_time}=  Run Keyword And Return Status  Variable Should Exist  ${Total_Time}
    ${total_time}=  Set Variable If  ${status_total_time}  ${Total_Time}  1440

    ${status_interval}=  Run Keyword And Return Status  Variable Should Exist  ${Interval}
    ${interval}=  Set Variable If  ${status_interval}  ${Interval}  60

    @{STABILITY_ALLOWED_ALARMS}=  Copy List  ${GLO_ADMIN_ALLOWED_ALARMS}
    Append To List  ${STABILITY_ALLOWED_ALARMS}  faultId=49, severity=Critical

    FOR  ${loop_number}  IN RANGE  1  ${total_time}/${interval}
        Log To Console  Cycle number: ${loop_number}
        Log To Console  Standing by for ${interval} minutes.
        Sleep  ${interval} minutes
        Log To Console  Standby ended. Resuming.
        Perform Stability test On Every Node
    END

    ${historical_alarms}=  admin.Get Historic Alarms  connection=${alias}
    @{alarms_to_check}=  Create List
    FOR  ${alarm}  IN  @{historical_alarms}
        ${fault_id}=  Get From Dictionary  ${alarm}  faultId
        ${severity}=  Get From Dictionary  ${alarm}  severity
        Append To List  ${alarms_to_check}  faultId=${fault_id}, severity=${severity}
    END
    ${alarms_to_check_clean}=  Remove Duplicates  ${alarms_to_check}
    Log To Console  Following historical alarms found: ${alarms_to_check_clean}

    FOR  ${alarm_a}  IN  @{alarms_to_check_clean}
        List Should Contain Value  ${STABILITY_ALLOWED_ALARMS}  ${alarm_a}
    END

    [Teardown]  Run Keywords
    ...  Verify Multi BTS State
    ...  AND  Verify Alarms  alias=${alias}

Perform Stability test On Every Node
    FOR  ${node}  IN  @{cfg.active_bts_list}
        Stability Without Reset Steps  ${node}
    END

Stability Without Reset Steps
    [Arguments]  ${alias}=${cfg.primary_node_bts_id}
    Step 1: Gather Snapshot  alias=${alias}
    Step 2: Execute Cell Block Unblock On Every Node
    Step 3: Start/stop Antenna Line Monitoring  alias=${alias}

Step 1: Gather Snapshot
    [Arguments]  ${alias}=${cfg.primary_node_bts_id}
    Log To Console  Collecting snapshot . . .
    ${status}  Run Keyword And Return Status
    ...  admin.Collect Snapshot
    ...  target_file_name=${TEST_LOGS_DIR_PATH}/snapshot_stability.zip    timeout=1800    alias=${alias}
    Run Keyword If  ${status}
    ...  Log To Console  Snapshot collected !
    ...  ELSE
    ...  Run Keyword And Continue On Failure  Fail  Snapshot collecting fail !

Step 2: Execute Cell Block Unblock On Every Node
    FOR  ${bts}  IN  @{CFG.active_bts_list}
      Perform Cell Block Unblock On Every Cell  ${cfg}  ${bts}
    END

Step 3: Start/stop Antenna Line Monitoring
    [Arguments]  ${alias}=${cfg.primary_node_bts_id}
    Log To Console  Gathering Antenna Lines Information.
    ${antl_r_list}=  Get ANTL_R Distnames List All RATs  ${alias}
    Log To Console  Antenna lines list: ${antl_r_list}
    Run Keyword And Continue On Failure  Start ANTL online monitoring  ${antl_r_list}  connection=${alias}
    Log To Console  Started ANTL online monitoring.
    Sleep  60
    Run Keyword And Continue On Failure  Stop ANTL online monitoring  ${TEST_LOGS_DIR_PATH}/output.json  connection=${alias}
    Log To Console  Stopped ANTL online monitoring

Get ANTL_R Distnames List All RATs
    [Arguments]  ${alias}=${cfg.primary_node_bts_id}
    ${antl_list}  Create list
    ${cells_dict}  admin.Get cell list  connection=${alias}
    ${nr_cells}  Get from dictionary  ${cells_dict["cells"]}  nr
    ${lte_cells}  Get from dictionary  ${cells_dict["cells"]}  lte
    ${wcdma_cells}  Get from dictionary  ${cells_dict["cells"]}  wcdma
    ${gsm_cells}  Get from dictionary  ${cells_dict["cells"]}  gsm
    ${nlwg_cells}  Combine lists  ${nr_cells}  ${lte_cells}  ${wcdma_cells}  ${gsm_cells}
    Should not be empty  ${nlwg_cells}  There are no cells in configuration!
    FOR  ${cell}  IN  @{nlwg_cells}
        ${is_iot}  Run keyword and return status  Should contain  ${cell["technology"]}  NB-IoT-FDD
        Continue for loop if  ${is_iot}
        ${carrier_list}  Get from dictionary  ${cell}  carrierList
        ${antl_distNames}  _Get ANTL Distnames All RATs  ${carrier_list}
        ${antl_list}  Combine lists  ${antl_list}  ${antl_distNames}
    END
    ${antl_list}  Remove duplicates  ${antl_list}
    [Return]  ${antl_list}

_Get ANTL Distnames All RATs
    [Arguments]  ${carrier_list}
    ${antl_list}  Create list
    FOR  ${carrier}  IN  @{carrier_list}
        ${is_phyant}  Run keyword and return status  Should contain  ${carrier["antennaLineId"]["internal"]}  PHYANT
        Continue for loop if  ${is_phyant}
        Append to list  ${antl_list}  ${carrier["antennaLineId"]["internal"]}
    END
    [Return]  ${antl_list}
