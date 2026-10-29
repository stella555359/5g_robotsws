*** Settings ***
Suite Setup    robot_common_operations.Common Suite Setup
Suite Teardown    robot_common_operations.Common Suite Teardown

Documentation
...    author: Xiao Hou
...    contact: susie.hou@nokia-sbell.com

Resource    ./Resources/CB008927_common_keywords.robot

*** Test Cases ***
5GC002200-ET-E-B1 001 DL CL MIMO interworking with FDM on N1N2=2x2 mode on SA
    [Tags]    CRT_TRUNK    caseB1_1
    [Setup]    Case Setup
    Commissionin SCF For TL
    OperatingSystem.Run    cp ${scf} ${TS_CASE_LOG_PATH}
    ${scf_file}    Set Variable    ${TS_CASE_LOG_PATH}/8927_ST10_scf.xml
    &{modified_parameters}    Create Dictionary    UElayersDL=${3}    UEDLmodulation256QAM=${1}    UEULmodulation256QAM=${1}
    ...    ULdmrsAdditionalPosition=${1}
    ${theoretical_dl}    ${theoretical_ul}    throughput_computation.Get Theoretical Throughput
    ...    scf_path=${scf_file}    cell_id=304    UEmaxData=1    mod_params=${modified_parameters}
    Log To Console    ${theoretical_dl}
    Log To Console    ${theoretical_ul}
    Block Cell By Admin
    # *** UE Prepare ***
    UE Setup
    # *** UE Attach ***
    BuiltIn.Log To Console    \n ### UE attach ###
    ${5Grach_ed}    power_ue.UE Attach    ue_type=askey
    # *** Verify Attach ***
    power_ue.Verify Attach    ue_type=askey    5Grach_ed=${5Grach_ed}    4G_check=False
    # *** Start And Check Traffic ***
    Run keyword and ignore error    Start And Check UL And DL traffic    target_ul=${theoretical_ul}    target_dl=${theoretical_dl}
    #${case_start_time_info}    Prepare for counter log
    #Capture And Check Counters    starting_log_timestamp=${case_start_time_info['log_generator_timestamp']}
    #Capture And Decode TTI log
    #Stop UL And DL Traffic
    #Check Beam Info From Tti
    #Check DL And UL By TTI
    [Teardown]    Case Teardown
