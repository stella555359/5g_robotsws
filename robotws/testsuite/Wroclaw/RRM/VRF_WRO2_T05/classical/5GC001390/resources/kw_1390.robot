*** Settings ***
Documentation    Suite description
#Library     testsuite/RRM/Wroclaw/5GC002534/resources/keywords_2534.py
Resource    testsuite/Wroclaw/RRM/resources/pm_counters/pm_counters.robot

*** Keywords ***
Verify registration to FDD PCell
    # [Arguments]    ${file_path}=${OUTPUT DIR}/${SUITE NAME}/${test_name}.log
    unpack collected syslog
    ${condition}=     Run keyword and Return Status
    ...               check if exist in syslog    AddedServingCellsList     Store addedSCellList:AddedServingCellsList
    Run keyword if    ${condition} == False
    ...               check if exist in syslog    AddedServingCellItem     Store addedSCellList
    check if exist in syslog    ScellAddition
    ...                         ScellAddition procedure Completed with No ScellAddition Error

Verify TDD SCell activation
    # [Arguments]    ${file_path}=${OUTPUT DIR}/${SUITE NAME}/${test_name}.log
    unpack collected syslog
    check if exist in syslog    handleActivateMacCe     handleActivateMacCe done for UE

Read counters value 1390
    ${counters_values}=   Create List
    Collect Counters   n_last=15
    @{counters}   Create list  M55316C09000  M55118C05507  M55118C05508  M55311C42009  M55311C44009
    FOR    ${counter}    IN      @{counters}
        ${value}    Get sum of n last counter values   4  ${counter}
        Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}

Verify PM Counters
    log to console              Waiting for BTS Counters update 300s
    sleep   300s
    log to console              Verify PM counters values
    ${counters}                 Read Counters Value 1390
    ${pcell}                    get_counter_value_from_single_cell   ${counters}  104    M55316C09000
    ${ca_ues_scell}             get_counter_value_from_single_cell   ${counters}  101    M55118C05507
    ${ca_ues_pcell}             get_counter_value_from_single_cell   ${counters}  104    M55118C05508
    ${RLC_PDU_vol_over_pcell}   get_counter_value_from_single_cell   ${counters}  1      M55311C42009
    ${RLC_PDU_vol_over_scell}   get_counter_value_from_single_cell   ${counters}  1      M55311C44009
    Should Be True      0<${pcell}
    Should Be True      150<=${ca_ues_scell}
    Should Be True      150<=${ca_ues_pcell}
    ${calc1}           Evaluate  (${RLC_PDU_vol_over_pcell} * 8) / 300
    ${calc2}           Evaluate  (${RLC_PDU_vol_over_scell} * 8) / 300
    Log to console  ${calc1}
    Log to console  ${calc2}

Set attenuators for 1390L
    Turn off attenuation
    Turn off attenuation_2
    Set attenuation and check    lines=${lines_gNB_410_AHLOA_1_FDD}   value=0
    # Set attenuation and check    lines=${lines_gNB_410_AEHC_4_TDD}   value=90

Delete old DCAP folder
    ssh.connect to    hostname=${labpcip}    username=${labpcname}     password=${labpcpass}    alias=LabPC
    ssh.execute       rm -rf /cygdrive/c/robot_script_7-16-UTE5GCLOUD410/    connection=LabPC
    [Teardown]  ssh.Disconnect    connection=LabPC
