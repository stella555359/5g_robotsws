*** Settings ***
Force Tags    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    CLOUD_5G_I_LO_AP_LO    CONFIGURED    RAN_5G_TDD
...           RAN_5G    PY310    SBTS00    CRT    NoResUsage    5G_TTI    TOOLS_PROFILE_WO_TTI    RF50

Documentation    :copyright: Nokia
...              :authors: Marcin Plawny
...              :contact: marcin.plawny@nokia.com

Resource    5GC001085_Keywords.robot

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/../initial_commissioning.xml
...            AND             Start Vm Ethernet Interfaces
...            AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_multi_anr_intra_freq.json
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_2c_tdd_sansa_multi_anr_config_intra.lua
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Backup And Modify Swconfig File    parameters_list=@{swconfig_rndFlag}
...            AND             Trigger Site Reset
...            AND             Check Radios Availability

Suite Teardown    Run Keywords    Stop Vm Ethernet Interfaces
...               AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/final_commissioning.xml
...               AND             Stop Default Processes And Gather Logs And Compress Logs
...               AND             Backup And Modify Swconfig File    parameters_list=@{swconfig_rndFlag_default}
...               AND             Send Full Commissioning    input_filepath=${OUTPUT_DIR}/../initial_commissioning.xml

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
Test Teardown    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Test Cases ***
5GC001085_C_003_Check_periodic_removal_of_various_NRREL_and_NRADJNRCELL
    [Documentation]    Testcase checks Relations Removal triggered by idleTimeForNrNbRemoval timeout.
    ...                NRREL-1, NRREL-2 (removeNotAllowed set true), NRREL-3(fake cell, Inter-Freq), NRREL-4 (sCellAdditionMethod set blind)
    ...                NRREL-256 is created by ANR HO to Cell 1 Gnb 3. Only Objects NRREL-1 and NRREL-256, NRADJNRCELL-12288 are removed.
    ...                NRREL-1 gets removed with NRADJNRCELL-12288 in next cycle because it status gets set CONFIRMED during handover
    ...                while NRADJNRCELL-12288 removal is triggered by missing NRREL-256.
    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_C_003.json

    Attach Ue And Establish Pdu Session    ue_id=1
    Send A5 Measurement And Attempt Handover    ue_id=1    target_phycell_id=150
    Wait And Verify Created NRREL Object    gnb_id=3
    Sleep    300s    reason=Wait for idle relation to not be removed

    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRANR-1    parameter=actAutoNrNbRemoval    value=true
    Sleep    600s    reason=Wait for idle relation to get removed

    Attach Ue And Establish Pdu Session    ue_id=2
    Send A5 Measurement And Attempt Handover    ue_id=2    target_phycell_id=51

    Wait For Object To Exist    object_name=NRCELL_A-1/NRREL_A-256    moc=NRREL_A    timeout=300
    Check Presence Of Three Initial NRREL And NRADJNRCELL
    Check If Object Exists    object_name=NRCELL_A-1/NRREL_A-1    moc=NRREL_A

    &{NRREL_256}    Get Managed Object    object_name=NRCELL_A-1/NRREL_A-256    moc=NRREL_A
    Verify Created NRREL Object    NRREL=&{NRREL_256}    mcc=311    mnc=489    mncLength=3    gNbId=3    gNbIdLength=22    lcrId=11

    &{NRADJNRCELL_12288}    Get Managed Object    object_name=NRADJNRCELL_A-12288    moc=NRADJNRCELL_A
    Verify Created NRADJNRCELL Object    NRADJNRCELL=&{NRADJNRCELL_12288}    mcc=311    mnc=489    mncLength=3    physCellId=150
    ...                                  cellDepType=SA+NSA    nrarfcn=636666    ssbFrequency=636576    gNbId=3    gNbIdLength=22    lcrId=11

    Wait For Object To Not Exist    object_name=NRCELL_A-1/NRREL_A-256    moc=NRREL_A    timeout=360
    Check Presence Of Three Initial NRREL And NRADJNRCELL
    Check If Object Exists    object_name=NRCELL_A-1/NRREL_A-1    moc=NRREL_A

    Wait For Object To Not Exist    object_name=NRADJNRCELL_A-12288    moc=NRADJNRCELL_A    timeout=360
    Wait For Object To Not Exist    object_name=NRCELL_A-1/NRREL_A-1    moc=NRREL_A    timeout=300
    Check Presence Of Three Initial NRREL And NRADJNRCELL

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
    ...            AND            Deregister UE Without Confirmation    ue_id=1
    ...            AND            Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...            AND            Deregister UE Without Confirmation    ue_id=2
    ...            AND            Get Bts Snapshot    output_filepath=${OUTPUT_DIR}/bts_snapshot_C003.zip
    ...            AND            Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRANRPR-1
    ...                           parameter=idleTimeForNrNbRemoval    value=72
    ...            AND            Remove NRBTS Objects    NRREL_A    parameter=removeNotAllowed
    ...            AND            Remove NRBTS Objects    NRADJNRCELL_A    parameter=cellDepType
    ...            AND            Run Keyword If Test Failed    Perform Parameter Commissioning
    ...                           dist_name=MRBTS-1/NRBTS-1/NRANR-1    parameter=actAutoNrNbRemoval    value=true

5GC001085_C_008_Removal_due_to_consecutive_HO_failures_-_intra-gnb_and_inter-gnb
    [Documentation]    Test case checks Relations Removal triggered by consecutive Handover Failures.
    ...                NRREL-1 and NRREL-5 are created via delta commisioning. NRREL-256 is created
    ...                by ANR to Cell 1 Gnb 3. For NRREL-5 sCellAdditionMethod is set to blind - removal is not allowed.
    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_C_008.json

    Attach And Establish Session For Multiple UEs    first_ue_id=3    last_ue_id=10
    Send A5 Measurement And Attempt Handover    ue_id=3    target_phycell_id=150
    Wait For Object To Exist    object_name=NRCELL_A-1/NRREL_A-256    moc=NRREL_A    timeout=${NRREL_OBJECT_CREATION_TIME}
    Check If Object Exists    object_name=NRCELL_A-1/NRREL_A-1    moc=NRREL_A
    Check If Object Exists    object_name=NRCELL_A-1/NRREL_A-5    moc=NRREL_A

    Attempt Failed Intra Gnb Handover For Multiple UEs    first_ue_id=4    last_ue_id=10

    Wait For Object To Not Exist    object_name=NRCELL_A-1/NRREL_A-1    moc=NRREL_A    timeout=${NRREL_OBJECT_CREATION_TIME}

    Attach And Establish Session For Multiple UEs    first_ue_id=11    last_ue_id=17
    Attempt Failed Inter Gnb Handover For Multiple UEs    first_ue_id=11    last_ue_id=17    target_phycell_id=150

    Wait For Object To Not Exist    object_name=NRCELL_A-1/NRREL_A-256    moc=NRREL_A    timeout=${NRREL_OBJECT_CREATION_TIME}
    Check If Object Doesnt Exist    object_name=NRCELL_A-1/NRREL_A-1    moc=NRREL_A

    Attach And Establish Session For Multiple UEs    first_ue_id=18    last_ue_id=24
    Attempt Failed Inter Gnb Handover For Multiple UEs    first_ue_id=18    last_ue_id=24    target_phycell_id=153

    Wait For Object To Exist    object_name=NRCELL_A-1/NRREL_A-5    moc=NRREL_A    timeout=${NRREL_OBJECT_CREATION_TIME}
    Check If Object Doesnt Exist    object_name=NRCELL_A-1/NRREL_A-1    moc=NRREL_A
    Check If Object Doesnt Exist    object_name=NRCELL_A-1/NRREL_A-256    moc=NRREL_A

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
    ...            AND            Deregister UE Without Confirmation    ue_id=all
    ...            AND            Remove NRBTS Objects    NRREL_A    parameter=removeNotAllowed
    ...            AND            Remove NRBTS Objects    NRADJNRCELL_A    parameter=cellDepType
