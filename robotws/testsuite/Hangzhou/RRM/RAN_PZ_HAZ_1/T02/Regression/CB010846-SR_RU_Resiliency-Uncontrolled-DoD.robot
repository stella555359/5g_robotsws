
*** Settings ***

Documentation
...    Author: jun.6.ma
...    Contact: jun.6.ma@nokia-sbell@nokia-sbell.com
...    This is a robot scripts for CB010846-D uncontrolled RU Resiliency DoD testing

Force Tags
...      TRUNK          #Tag Item
...      VRF_RRM        #Competence Area
...      VRF_HAZ1_T02   #Organization
...      TA_LEVEL_23    #Detailed Automation Level[TA_LEVEL_21, TA_LEVEL_22, TA_LEVEL_23]

Test Timeout           6h

Suite Setup       Common Suite Setup For RRM
Suite Teardown    Common Suite Teardown For RRM
Test Setup        Common Test Setup For RRM
Test Teardown     Common Test Teardown For RRM


Resource    ../../Resources/Classical/RRM_Common_Resource.robot
Resource    ../../T02/Common_Case/common_resource_new.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/Module/BTS_Operation.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/Module/Log_Collection.robot
Library     ../../../../resources/RAN_PZ_HAZ_1/Module/Commercial_UE_Operation.py
Library     taf.sw.scout    WITH NAME    scout
Library     SSHLibrary


*** Variables ***
#${TestLine_Name}          10_5_UTESRAN001T37096
#${SELECTED_SW_VERSION}    SBTS00_ENB_9999_241016_000001
#${serials}                R3CRC011CQD
#RFCNC0RNFJH
#${syslog_path}          /home/ute/btslog2
#&{syslog_filter_conditions}      line_regex=Averaged Measurements    element_regex=slotDelay\=\\d
#&{analysis_dict_syslog_1}        filter_conditions=${uncntrldResetMplaneBreakTime : 300}
#${csirs_keyword}    uncntrldResetMplaneBreakTime : 300
${host}    10.56.201.211
${alias}    ASIK
${connection}   ABIL
${usrname}      toor4nsn
${pwd}      oZPS0POrRieRtu
${fingerprint}            fingerprint
${yes_no}                 yes

*** Test Cases ***
Case_CB010846-D#10_RU_resiliency_to_BTS-DU_L1Soc_and_Capacity_Unit_reset-Uncontrolled_case_on-line_activation
    [Tags]    QC_122400    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
     ...    Author: jun.6.ma@nokia-sbell.com
     ...    27.11.2024,jun.6.ma@nokia-sbell.com, draft
     ...    this is draft for RU resiliency activation for uncontrolled scenarios
    [Setup]    Common Test Setup For RRM
    Uncontrolled_Active
    BTS Operation    operation=verify    product_type=gnb    bts_index=0    verify_status=CELL_ONAIR
    log to console    \n Site and Cells are onair
    ${local_file_path}    Log Collection    start    snapshot    product_type=gnb    bts_index=${0}
    Log To Console    \nSnapshot log: ${local_file_path}
    [Teardown]    Teardown_for_CB010846

Case_CB010846-D#53_eCPRI_RU_resiliency_to_BTS-DU_Capacity_Unit_reset-Uncontrolled_case
    [Tags]    QC_122399    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
     ...    Author: jun.6.ma@nokia-sbell.com
     ...    27.11.2024,jun.6.ma@nokia-sbell.com, draft
     ...    this is draft for RU resiliency via Capacity Unit crash with FID: 4383 in uncontrolled scenarios
    [Setup]    Common Test Setup For RRM
    BTS Operation    operation=verify    product_type=gnb    bts_index=0    verify_status=CELL_ONAIR
    log to console    \n Site and Cells are onair
    ${cmd1}    Set Variable    ssh toor4nsn@fsp1s0icom # bsh 1:0
    ${cmd2}    Set Variable    ps -aux | grep CCS
    ${cmd3}    Set Variable    pkill -11 -f '/opt/CCS_RT/CCSRTDaemonExe --startup=nid=0x1731'
    SSHLibrary.Open Connection    ${host}
    SSHLibrary.Login    ${usrname}    ${pwd}
    SSHLibrary.Write    ${cmd1}
    sleep   5s
    ${output0}      SSHLibrary.Read     delay=5s
    ${contains}=    Run Keyword And Return Status    Should Contain    ${output0}    ${fingerprint}
    Run Keyword IF      ${contains}
    ...     SSHLibrary.Write    ${yes_no}
    ...     ELSE    log to console      \n login to the 1st BBMOD's 1st loki
    sleep   5s
    SSHLibrary.Write    ${pwd}  #oZPS0POrRieRtu
    SSHLibrary.Write    ${cmd2}
    SSHLibrary.Write    ${cmd3}
    sleep       60s
    log to console      \n Success
    ${local_file_path}    Log Collection    start    snapshot    product_type=gnb    bts_index=${0}
    Log To Console    \nSnapshot log: ${local_file_path}
    [Teardown]    Teardown_for_CB010846

Case_CB010846-D#23_eCPRI_RU_resiliency_to_BTS-DU_L1Soc_reset-Uncontrolled_case
    [Tags]    QC_122398    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
     ...    Author: jun.6.ma@nokia-sbell.com
     ...    27.11.2024,jun.6.ma@nokia-sbell.com, draft
     ...    this is draft for RU resiliency via L1SoC crash with FID: 2087 in uncontrolled scenarios
    [Setup]    Common Test Setup For RRM
    BTS Operation    operation=verify    product_type=gnb    bts_index=0    verify_status=CELL_ONAIR
    log to console    \n Site and Cells are onair
    SSHLibrary.Open Connection    ${host}
    SSHLibrary.Login    ${usrname}    ${pwd}
    SSHLibrary.Write    ssh toor4nsn@fsp1s2icom  # bsh 1:2

    ${output0}      SSHLibrary.Read     delay=5s
    ${contains}=    Run Keyword And Return Status    Should Contain    ${output0}    ${fingerprint}
    Run Keyword IF      ${contains}
    ...     SSHLibrary.Write    ${yes_no}
    ...     ELSE    log to console      \n login to the 1st BBMOD's 3rd loki
    sleep   5s
    SSHLibrary.Write    ${pwd}
    sleep   5s
    #Wait Until Keyword Succeeds    3x    1s    SSHLibrary.Read Until    :~#

    SSHLibrary.Write    ps aux | grep l1
    ${output}    SSHLibrary.Read    delay=2s
    ${list}    split string    ${output}    root         # output is string, split with 'root', take the 2nd one
    ${PID0}=    Get Substring    ${list}[1]    0    12   # the first 12 str from ${list}
    ${PID}=    Remove String    ${PID0}    ${SPACE}      # remove the space
    log to console      \n the first process ID is ${PID}
    SSHLibrary.Write    kill -11 ${PID}
    sleep       60s
    log to console      \n Success
    ${local_file_path}    Log Collection    start    snapshot    product_type=gnb    bts_index=${0}
    Log To Console    \nSnapshot log: ${local_file_path}
    [Teardown]    Teardown_for_CB010846

*** Keywords ***
Uncontrolled_Active
    @{para_list}      Create List     actRuResetResiliency        uncntrldResetMplaneBreakTime
    @{mo_list}        Create List     MRBTS-37096/MNL-1/MNLENT-1/FEATCADM-1       MRBTS-37096/MNL-1/MNLENT-1/FEATCADM-1
    @{value_list}     Create List     true        300||600||900

    ${out}            Parameter Operation    operation=parameter_update    product_type=gnb
    ...                                      para_list=${para_list}        value_list=${value_list}    mo_list=${mo_list}
    Log To Console    \n >>> Paramter update result: ${out}

Teardown_for_CB010846
    Get SCF Internal Id By Scout    no_ute=False
    #Common Test Teardown For RRM