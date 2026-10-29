*** Settings ***
Documentation    TC__NRL__CM__LTE_Recomissioning_pmax_with_LTE_template
Variables    tc_variables/nrl__cm__lte_recommissioning_pmax_with_lte_template.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${RECOMMISSIONING_LTE_PMAX}      # Absolute path for SCF file with pmax commissioning for LTE RAT (i.e. /home/ute/btsauto/SCF_01_SBTS19.xml).
                                 # 4G radio carrier power (pmax param.) is incresed such as the total power on RFM (4G+5G) to be over the maximum
                                 # power of RFM (ex. AHLOA over 60W per Tx)
                                 # Fault ID 1900 "Radio module configuring failed" is rased on 4G, 5G cell is not affected
${REPEAT_COUNTER}          3     # Number of LTE Recommissioning operations, default value 3
${LTE_SCF_VALIDATION}      True  # Validate LTE SCF; can be True or False

*** Keywords ***
TC__NRL__CM__LTE_Recomissioning_pmax_with_LTE_template
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-21561
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  NR-LTE test case for Planned_Recommissioning_LTE_template, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for both NR and LTE technologies
    ...  - set if needed primary CPRI on requested technology
    ...  - get initial RESET info from blackbox files for NR and LTE
    ...  - save initial SCF
    ...  - planned Recommissioning pmax parameter with LTE SCF file
    ...  - check after recommissioning state and alarms for both NR and LTE technologies
    ...  - check reset behavior on NR and LTE based on initial and final RESET info as follows:
    ...    - NR site: reset number is 0
    ...    - LTE site: reset number is 1
    ...  - return to initial SCF configuration
    ...  - check final state and alarms for both NR and LTE technologies
    ...  Pass criteria: Planned Recommissioning operation works as expected, states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 15.02.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-21561 -
    ...  [5G][MT] New NRL scenario NRL__CM__LTE_Recomissioning_pmax_with_LTE_template
    ...  - 03.05.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23036 - [5G][NR-NR] Robot for NR_NR__STATE__NR_RM_LockUnlock_from_WEBEM
    ...  must ignore "blockingState" check
    ...  - 16.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29822 -
    ...  Unify alarm list names in order alarm list to begin with upper case Alias - NRL
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-21561_NRL__CM__LTE_Recomissioning_pmax_with_LTE_template.png

    Set Tags    CA-CM    OWNER-denisa.grigore@nokia.com    AUTHOR-lia.caraiman@nokia.com    PHASE-QT
    ...    SW-SBTS00

    TC Parameters check
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get all RMOD info
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 4: Planned pmax LTE Recommissioning
        Step 5: Check after recommissioning all BTS state
        Step 6: Check after recommissioning all BTS alarms
        Step 7: Check NR and LTE reset behavior
        Step 8: Recover initial scf configuration
        Step 9: Check final all BTS state
        Step 10: Check final all BTS alarms
        Step 11: Check final number and state of Cells and RMs
    END
    [Teardown]  Particular Teardown

TC Parameters check
    Log  TC parameters check verification started  console=True
    Run Keyword If  '${RECOMMISSIONING_LTE_PMAX}' == ''  Run Keywords
    ...  Log Long String  Variable RECOMMISSIONING_LTE_PMAX not defined. User must set variable as absolute path for SCF file related to modify
    ...   pmax parameter value on LTE.  level=ERROR
    ...  AND  Fail  Execution ended
    ${scf_path_tmp}=  Admin Collect scf.xml with timestamp TAF  alias=Slave  folder_path=${BTSFiles}/Slave
    OperatingSystem.File Should Exist  ${scf_path_tmp}
    ${bts_info_tmp}=  Admin Get BTS state info  alias=Slave
    Set Test Variable  ${scf_path_initial}  ${scf_path_tmp}
    Set Test Variable  ${bts_info}  ${bts_info_tmp}
    Log  Initial scf saved in location ${scf_path_tmp}  console=True

Step ${index}: Check ${when} all BTS state
    [Documentation]
    ...  SBTS state is checked according to Admin for BTS and each configured RAT

    Log  Step ${index}: Check ${when} all BTS state  console=True
    FOR  ${alias}  IN  @{alias_list}
        Log  ***** Check ${when} BTS ${alias} state *****  console=True
        Admin Check BTS RAT Procedural State  alias=${alias}  timeout=600
        Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  alias=${alias}
        Log  BTS ${alias} site - proceduralState: OnAir, blockingState: Unblocked  console=True
    END

Step ${index}: Check ${when} all BTS alarms
    [Documentation]
    ...  SBTS alarms are compared with values from expected, ignored and critical alarms lists. SBTS alarms are get
    ...  from Admin

    Log  Step ${index}: Check ${when} all BTS alarms  console=True
    FOR  ${alias}  IN  @{alias_list}
        Log  ***** Check ${when} BTS ${alias} alarms *****  console=True
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
        ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True
    END

Step ${index}: Get all RMOD info
    Log  Step ${index}: Get all RMOD info  console=True
    ${Master_shared_RM_list}  ${Slave_shared_RM_list}  ${Master_dedicated_RM_list}  ${Slave_dedicated_RM_list}=
    ...  Admin Get Shared And Dedicated RM List for Master and Slave  Master  Slave
    Sort List  ${Master_shared_RM_list}
    Sort List  ${Slave_shared_RM_list}
    Set Test Variable  ${Master_shared_RM_list}
    Set Test Variable  ${Slave_shared_RM_list}
    ${shared_RMOD_count}=  Get Length  ${Master_shared_RM_list}
    Set Test Variable  ${shared_RMOD_count}
    Get LTE cell list from shared RM


Step ${index}: Planned pmax LTE Recommissioning
    [Documentation]
    ...  Planned pmax LTE recommissioning with SCF file is triggered. The new SCF file is loaded on LTE SM and a reboot should be triggered after

    [Timeout]  15 min
    Log  Step ${index}: Planned pmax LTE Recommissioning  console=True
    Get Current Date UTC info  start
    Perform LTE Recommissioning using ${RECOMMISSIONING_LTE_PMAX}
    Check SW configuration did not change
    Get Current Date UTC info  end

Step ${index}: Recover initial scf configuration
    [Documentation]
    ...  Change pmax parameter to its initial value

    [Timeout]  15 min
    Log  Step ${index}: Recover initial scf configuration  console=True
    Perform LTE Recommissioning using ${scf_path_initial}

Step ${index}: Check NR and LTE reset behavior
    [Documentation]
    ...  Final RESET info are compared with initial RESET info for both NR and LTE. Reset behavior as expected if:
    ...  - NR site: reset number is 0
    ...  - LTE site: reset number is 1
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.

    Log  Step ${index}: Check NR and LTE reset behavior  console=True
    Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=Master  remove_ims_file=False
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}
    Get and check BTS RESET info from IMS file  expected_reset_number=1  alias=Slave  remove_ims_file=False
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Perform LTE Recommissioning using ${scf_path}
    Log  Commissioning via ADMIN will be performed using ${scf_path}  console=True
    coam.Perform Commissioning  bts_id=${bts_info[0]}  scf_file=${scf_path}  skip_parameter_relation_errors=True
    ...  should_activate=True  timeout=400  alias=Slave
    Log  LTE commissioning has been performed  console=True
    Get Current Time  lte_initial
    Run Keyword If  ${LTE_SCF_VALIDATION}  Run Keywords
    ...  Log  Validate LTE SCF after Recommissioning  console=True
    ...  AND  Admin Validate SCF TAF  alias=Slave
    ...  AND  Admin Validate SCF With Detected Hardware  alias=Slave
    Check SW configuration did not change

Check SW configuration did not change
    [Documentation]
    ...  Extract Master and Slave active and passive SWs using Admin and compare to initial values. Fail if something changed

    ${current_active_SW_Master}  ${current_passive_SW_Master}=  Wait Until Keyword Succeeds  5m  20s  Admin Get BTS SW Version  Master
    ${current_active_SW_Slave}  ${current_passive_SW_Slave}=  Wait Until Keyword Succeeds  5m  20s  Admin Get BTS SW Version  Slave
    ${initial_SW_list}=  Create List  ${Master active SW}  ${Master passive SW}  ${Slave active SW}  ${Slave passive SW}
    ${current_SW_list}=  Create List  ${current_active_SW_Master}  ${current_passive_SW_Master}
    ...  ${current_active_SW_Slave}  ${current_passive_SW_Slave}
    ${no_sw_change}=  Run Keyword And Return Status  Should Be Equal  ${initial_SW_list}  ${current_SW_list}
    Run Keyword If  not ${no_sw_change}  Run Keywords
    ...  Log Long String  SW configuration changed! Master SW active/passive: ${current_active_SW_Master}/${current_passive_SW_Master};
    ...  Slave SW active/passive: ${current_active_SW_Slave}/${current_passive_SW_Slave}  console=True
    ...  AND  Fail  SW configuration changed!

Check LTE cells and RMs states and alarms after recommissioning LTE pmax
    Log  Get LTE RM state after recommissioning :  console=True
    ${RM_state}=  Admin Get RMOD state info  Slave
    FOR  ${RM_item}  IN  @{RM_state}
        Log Long String  ${RM_item[2]} ${RM_item[0]} - operationalState=${RM_item[3]}, administrativeState=${RM_item[4]},
        ...  availabilityStatus=${RM_item[5]}, usageState=${RM_item[7]}  console=True
    END
    Log  Get LTE cells state after recommissioning :  console=True
    FOR  ${item}  IN  @{LTE_CELL_RM_list}
         Assert  LNCEL  ${item}  availabilityStatus=${Failed_}, operationalState=${Disabled_}  timeout=300  alias=Slave
         Log  LTE cell - ${item} availabilityStatus=Failed, operationalState=Disabled  console=True
    END
    ${SLAVE_EXPECTED_ALARMS_full}=  Create List  @{EMPTY}
    ${SLAVE_EXPECTED_ALARMS_1900_multiplicated}=  Prepare expected alarms list  ${SLAVE_EXPECTED_ALARMS_1900}  ${shared_RMOD_count}
    Append To List  ${SLAVE_EXPECTED_ALARMS_full}  @{SLAVE_EXPECTED_ALARMS_1900_multiplicated}
    Log  LTE "RF Module configuring failed (1900)" alarm, expected count: ${shared_RMOD_count}  console=True
    Get and Check Alarms SOAM  alias=Slave  expected_alarms=${SLAVE_EXPECTED_ALARMS_full}  ignored_alarms=${SLAVE_IGNORED_ALARMS}
    ...  critical_alarms=${SLAVE_CRITICAL_ALARMS}
    Log  LTE "RF Module configuring failed (1900)" alarm, found count: ${shared_RMOD_count}, as expected!  console=True

Get LTE cell list from shared RM
    ${LTE_CELL_RM_list}=  Create List
    FOR  ${item}  IN  @{Slave_shared_RM_list}
        ${LTE_CELL_RM_list_temp}=  Get Cell Mapping By Module Id  module_id=${item}  alias=Slave
        Append To List  ${LTE_CELL_RM_list}  @{LTE_CELL_RM_list_temp}
    END
    ${LTE_CELL_RM_list}=  Remove Duplicates  ${LTE_CELL_RM_list}
    Set Test Variable  ${LTE_CELL_RM_list}
    ${LTE_CELL_RM_count}=  Get Length  ${LTE_CELL_RM_list}
    Set Test Variable  ${LTE_CELL_RM_count}

Particular Teardown
    Run Keyword And Continue On Failure  Perform LTE Recommissioning using ${scf_path_initial}

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  connection_type=ssh_tunnel  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
