*** Settings ***
Library         taf.rfrl.bts.devices.asir.asir_operations.AsirHubOperations         WITH NAME   asir

*** Keywords ***
Restore ASIR Configuration and Wait for onAir
     asir.Perform ASIR Commissioning                     scf_path=${LOG_PATH}/asir_backup_scf
     asir.Wait for ASIR to be OnAir
     Wait Until Keyword Succeeds     400 sec     15 sec      Verify All Cell Status
     Wait Until Keyword Succeeds     400 sec     15 sec      asir.Verify Status Of All Asir Cells Is Operational

Wait Untill All Hubs are Enabled
    ${expected_statuses}    Create Dictionary  operationalState=enabled
    Wait Until Keyword Succeeds     500sec    20sec    asir.Verify HubMod Status
    ...                                                                         hub_ids=${all_hub_ids}
    ...                                                                         expected_statuses=${expected_statuses}

Verify All Hubs are Enabled and not Commissioned
    ${expected_statuses}    Create Dictionary  operationalState=enabled  commissioned=No
    asir.Verify HubMod Status
    ...                             hub_ids=${all_hub_ids}
    ...                             expected_statuses=${expected_statuses}

Check Number of HUB IDs
    ${all_hub_ids}       asir.Get All HUB IDs
    Set Test Variable    ${all_hub_ids}
