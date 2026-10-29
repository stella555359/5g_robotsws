*** Settings ***
Documentation    CBTS__TEST__WebEM
Variables    tc_variables/cbts_sbts__cm__cbts_cell_power_validation_with_fid_1900_check_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Keywords ***
TC__CBTS__TEST__WebEM
    [Documentation]
    VDU WebEM Setup  Master  VDU1
    # Reset VDU From VDU WebEM  Master  VDU1
    VDU WebEM Teardown  Master  VDU1

    VCU WebEM Setup  Master
    VCU WebEM Teardown  Master

TC Setup
    ${tech_preset_list}=  Create List  CBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown