*** Settings ***
Documentation
...   contact: Oleksandr Kulieshov

Library       taf.config.scf
Library       taf.sbts.oam.coam.admin    WITH NAME    admin
Resource      ../../resources/ca_IWK.robot


*** Variables ***
${DUAL_SECTOR_WITH_NBIOT_SCF_PATH}               # Absolute path to SCF for dual sector with NB-IoT
${SINGLE_SECTOR_WITH_NBIOT_SCF_PATH}             # Absolute path to SCF for single sector with NB-IoT
${DUAL_SECTOR_NBIOT_LNCEL_LIST}                  # List of LNCEL IDs for NB-IoT cells for dual sector
${SINGLE_SECTOR_NBIOT_LNCEL_LIST}                # List of LNCEL IDs for NB-IoT cells for single sector
${CHANGED_SECTOR_LNCEL_LIST}                     # List of LNCEL IDs for which sector type will be changed during test
${REVERT_TO_ORIGNAL}                             # Boolean value determining if at the end of test it should revert to original SCF
${LOOPS_COUNT}                                   # Number of loops + 1 for steps 1-8

*** Keywords ***
TC__RRM__Configuration_change_sector_type_NBIoT_used__LTE4852_LTE4529_CB007256

    Set Tags    CA-RRM    AUTHOR-monika.ceglarek@nokia.com    OWNER-piotr.smolak@nokia.com
    ...         MAINTAINER-monika.ceglarek@nokia.com    PHASE-CRT   SW-SBTS23R1    FEATURE-LTE4852
    ...         FEATURE-LTE4529  FEATURE-CB007256  GROUP_IN_CHARGE-Pz_2_WRO_2


    Preconditions
    Looped Steps


Looped Steps
    FOR  ${loop}  IN RANGE  1  ${LOOPS_COUNT}
        Set Test Variable  ${LOOP}  ${loop}
        Log  \n--- LOOP${LOOP} START ---  console=True
        Step 1: Perform Offline Recomissioning To Dual Sector With NB-IoT
        Step 2: Check If Configuration Has Dual Sector And NB-IoT
        Step 3: Perform Online Recomissioning To Dual Sector Without NB-IoT
        Step 4: Check If Configuration Has Dual Sector And No NB-IoT
        Step 5: Perform Offline Recomissioning To Single Sector With NB-IoT
        Step 6: Check If Configuration Has Single Sector And NB-IoT
        Step 7: Perform Online Recomissioning To Single Sector Without NB-IoT
        Step 8: Check If Configuration Has Single Sector And No NB-IoT
        Log  --- LOOP${LOOP} END ---\n  console=True
    END


Preconditions
    Log  \n==== Preconditions ====  console=True
    ${lnbts_id} =  Get BTS ID From ADMIN
    Set Test Variable  ${LNBTS_ID}  ${lnbts_id}
    Get Current SCF File  ${LOG_PATH}/misc_logs  SCF_original.xml  export_type=configuration


Step ${index}: Perform Offline Recomissioning To ${sector_type} With NB-IoT
    Log  \n==== Step ${index}: Perform Offline Recomissioning To ${sector_type} With NB-IoT ====  console=True
    ${scf_path} =  Set Variable If
    ...  "${sector_type}" == "Dual Sector"  ${DUAL_SECTOR_WITH_NBIOT_SCF_PATH}
    ...  "${sector_type}" == "Single Sector"  ${SINGLE_SECTOR_WITH_NBIOT_SCF_PATH}
    Perform Commissioning  bts_id=${LNBTS_ID}  scf_file=${scf_path}  timeout=600s
    Wait Until Keyword Succeeds  7m  20s  _verify bts states for iwk test helper


Step ${index}: Check If Configuration Has ${sector_type} And ${nb_iot_exists}
    Log  \n==== Step ${index}: Check If Configuration Has ${sector_type} And ${nb_iot_exists} ====  console=True

    ${_}  ${parsed_scf}=  Save And Parse SCF  SCF_step${index}_loop${LOOP}
    ${nbiot_cells} =  Set Variable If  "${sector_type}" == "Single Sector"
    ...  ${SINGLE_SECTOR_NBIOT_LNCEL_LIST}  ${DUAL_SECTOR_NBIOT_LNCEL_LIST}
    Run Keyword If  "${nb_iot_exists}" == "NB-IoT"  Check Existing NB-IoT Cells  ${parsed_scf}  ${nbiot_cells}
    ...  ELSE  Check Removed NB-IoT Cells  ${parsed_scf}  ${nbiot_cells}
    RRM__Configuration_change_sector_type_NBIoT_used__LTE4852_LTE4529_CB007256.Check Sector Type  ${parsed_scf}  ${sector_type}


Check Existing NB-IoT Cells
    [Arguments]  ${parsed_scf}  ${nbiot_cells}
    ${correct_configuration} =  Set Variable  True
    FOR  ${nbiot_cell_id}  IN  @{nbiot_cells}
        ${cell_exists} =  Run Keyword And Return Status  Check If Element Exists In SCF  ${parsed_scf}
        ...  LNCEL  LNCEL-${nbiot_cell_id}  dist_name_substring=True
        ${correct_configuration} =  Set Variable If  ${cell_exists}  ${correct_configuration}  False
    END
    Should Be True  ${correct_configuration}  msg=Not all NB-IoT cell(s) were found in SCF.


Check Removed NB-IoT Cells
    [Arguments]  ${parsed_scf}  ${nbiot_cells}
    ${correct_configuration} =  Set Variable  True
    FOR  ${nbiot_cell_id}  IN  @{nbiot_cells}
        ${cell_exists} =  Run Keyword And Return Status  Check If Element Exists In SCF  ${parsed_scf}
        ...  LNCEL  LNCEL-${nbiot_cell_id}  dist_name_substring=True
        ${correct_configuration} =  Set Variable If  ${cell_exists}  False  ${correct_configuration}
    END
    Should Be True  ${correct_configuration}  msg=NB-IoT cell(s) still exist in SCF.


Check Sector Type
    [Arguments]  ${parsed_scf}  ${sector_type}
    ${sector_string} =  Set Variable If  "${sector_type}" == "Single Sector"
    ...  SingleSectorBFProf\\(0 degree\\)  DualSectorBFProf\\([-+]30 degree\\)
    FOR  ${lncel_id}  IN  @{CHANGED_SECTOR_LNCEL_LIST}
        Check Element In SCF  ${parsed_scf}  LNCEL_FDD  LNCEL-${lncel_id}/
        ...  /p[@name='mMimoHorizontalSectorBFProf']  <p name="mMimoHorizontalSectorBFProf">${sector_string}</p>
        ...  is_regexp=True
    END


Step ${index}: Perform Online Recomissioning To ${sector_type} Without NB-IoT
    Log  \n==== Step ${index}: Perform Online Recomissioning To ${sector_type} Without NB-IoT ====  console=True

    ${nbiot_cells} =  Set Variable If  "${sector_type}" == "Single Sector"
    ...  ${SINGLE_SECTOR_NBIOT_LNCEL_LIST}  ${DUAL_SECTOR_NBIOT_LNCEL_LIST}
    ${scf_path}  ${parsed_scf}=  Save And Parse SCF  SCF_step${index}_loop${LOOP}
    Load SCF  ${scf_path}
    FOR  ${nbiot_lncel_id}  IN  @{nbiot_cells}
        Log  Creating delta for LNCEL-${nbiot_lncel_id}.  console=True
        ${dist_name_lncel} =  Get DistName Attribute From SCF  ${parsed_scf}  LNCEL  LNCEL-${nbiot_lncel_id}
        ...  dist_name_substring=True
        ${lcr_id} =  Get Parameter Value From SCF  ${parsed_scf}  LNCEL  LNCEL-${nbiot_lncel_id}
        ...  /p[@name='lcrId']  dist_name_substring=True
        ${dist_name_celmapping} =  Get DistName Attribute From SCF  ${parsed_scf}  LCELL  LCELL-${lcr_id}
        ...  dist_name_substring=True
        ${lncel_id} =  Get Parameter Value From SCF  ${parsed_scf}  LNCEL  LNCEL-${nbiot_lncel_id}
        ...  /p[@name='nbIotLinkedCellId']  dist_name_substring=True
        Creating Delta For NB-IoT  ${lncel_id}  ${dist_name_lncel}  ${dist_name_celmapping}
    END

    Save SCF  ${LOG_PATH}/misc_logs/modified_SCF_step${index}_loop${LOOP}.xml
    ${delta_path}  ${_} =  Calculate Delta Between SCFs
    ...  ${scf_path}
    ...  ${LOG_PATH}/misc_logs/modified_SCF_step${index}_loop${LOOP}.xml
    ...  NBIoT_delta_step${index}_loop${LOOP}
    Log  Performing delta recommissioning...  console=True
    Perform Delta Recommissioning  ${delta_path}
    Wait Until Keyword Succeeds  7m  20s  _verify bts states for iwk test helper


Creating Delta For NB-IoT
    [Arguments]  ${lncel_id}  ${dist_name_lncel}  ${dist_name_celmapping}
    Remove MO With Descendant MOs  ${dist_name_lncel}
    Remove MO With Descendant MOs  ${dist_name_celmapping}
    ${modifications_list} =  Create List  modify:LNCEL-${lncel_id}:nbIoTMode=disabled
    ...  delete:LNCEL-${lncel_id}:nbIotLinkedCellId
    Perform SCF Modification  ${modifications_list}


Revert to Original SCF
    Log  Reverting to original SCF. Path:${LOG_PATH}/misc_logs/SCF_original.xml  console=True
    Perform Commissioning  bts_id=${LNBTS_ID}  scf_file=${LOG_PATH}/misc_logs/SCF_original.xml  timeout=600s
    Wait Until Keyword Succeeds  7m  20s  _verify bts states for iwk test helper


TC Setup
    IWK Test Setup   single_bts=True


TC Teardown
    [Timeout]  30 min
    Log  \n === TC Teardown ===   console=True
    Run Keyword If  ${REVERT_TO_ORIGNAL}  Revert to Original SCF
    IWK Test Teardown  single_bts=True
