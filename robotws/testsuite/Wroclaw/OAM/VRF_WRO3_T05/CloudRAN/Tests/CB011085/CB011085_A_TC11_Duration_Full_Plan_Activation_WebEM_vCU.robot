*** Settings ***
Documentation    Test Case purpose is to verify the duration of Full SCF download operation in WebEM for vCU
...              According to the requirement OM_GEN_SFS_PERF_CAP.11002

*** Variables ***
${SCF_dir_TC11}=    /home/ute/Downloads
${activate_SCF_target}=    680s

*** Keywords ***
CB011085_A_TC11_Duration_Full_Plan_Activation_Service_Outage_WebEM_vCU

    ${start_test_timestamp}=    Get Current Date

    Download SCF    scf_path=${SCF_dir_TC11}/vCU_Full_SCF.xml    hw_type=vCU    include_runtime_data=True
#    Download SCF    scf_path=${SCF_dir_TC11}/vDU_Full_SCF.xml    hw_type=vDU    include_runtime_data=True

    &{plan_vCU}=    Upload SCF    scf_path=${SCF_dir_TC11}/vCU_Full_SCF.xml    hw_type=vCU
#    &{plan_vDU}=    Upload SCF    scf_path=${SCF_dir_TC11}/vDU_Full_SCF.xml    hw_type=vDU

    Validate SCF    hw_type=vCU    plan_id=${plan_vCU['plan_id']}
#    Validate SCF    hw_type=vDU    plan_id=${plan_vDU['plan_id']}

    Activate SCF    hw_type=vCU    plan_id=${plan_vCU['plan_id']}
#    Activate SCF    hw_type=vDU    plan_id=${plan_vDU['plan_id']}

    ${end_test_timestamp}=    Get Current Date
    Sleep    10s    #Sleep to let the system update the operation history

    ${activate_SCF_vCU_operation}=    Get Operation History    hw_type=vCU    operation_name=Activate plan
    ...   start_time=${start_test_timestamp}    end_time=${end_test_timestamp}
    ${KPI_1_status}    ${KPI_1_measure}=    Check If Operation Meets Target    ${activate_SCF_vCU_operation[0]}    ${activate_SCF_target}

#    ${activate_SCF_vDU_operation}=    Get Operation History    hw_type=vDU    operation_name=Activate plan
#    ...   start_time=${start_test_timestamp}    end_time=${end_test_timestamp}
#    ${KPI_2_status}    ${KPI_2_measure}=    Check If Operation Meets Target    ${activate_SCF_vDU_operation[0]}    ${activate_SCF_target}

    IF    not ${KPI_1_status}    #or not ${KPI_2_status}
        Fail    Operation did not meet target: ${activate_SCF_target}
    ELSE
        Log To Console    vCU: ${KPI_1_measure}s meets target ${activate_SCF_target}
#        Log To Console    vDU: ${KPI_2_measure}s meets target ${activate_SCF_target}
    END

    #TODO: ADD Alarm check