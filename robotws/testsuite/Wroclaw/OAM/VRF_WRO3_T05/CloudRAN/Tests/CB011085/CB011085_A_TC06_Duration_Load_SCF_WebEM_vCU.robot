*** Settings ***
Documentation    Test Case purpose is to verify the duration of Load SCF operation in WebEM for vCU
...              According to the requirement OM_GEN_SFS_PERF_CAP.8676

*** Variables ***
${SCF_dir_TC06}=    /home/ute/Downloads
${load_SCF_target}=    70s

*** Keywords ***
CB011085_A_TC06_Duration_Load_SCF_WebEM_vCU

    ${start_test_timestamp}=    Get Current Date

    Download SCF    scf_path=${SCF_dir_TC06}/vCU_Full_SCF.xml    hw_type=vCU    include_runtime_data=True
#    Download SCF    scf_path=${SCF_dir_TC06}/vDU_Full_SCF.xml    hw_type=vDU    include_runtime_data=True

    &{plan_vCU}=    Upload SCF    scf_path=${SCF_dir_TC06}/vCU_Full_SCF.xml    hw_type=vCU
#    &{plan_vDU}=    Upload SCF    scf_path=${SCF_dir_TC06}/vDU_Full_SCF.xml    hw_type=vDU

    ${end_test_timestamp}=    Get Current Date
    Sleep    15s    #Sleep to let the system update the operation history

    ${upload_SCF_vCU_operation}=    Get Operation History    hw_type=vCU    operation_name=Load SCF
    ...   start_time=${start_test_timestamp}    end_time=${end_test_timestamp}
    ${KPI_1_status}    ${KPI_1_measure}=    Check If Operation Meets Target    ${upload_SCF_vCU_operation[0]}    ${load_SCF_target}

#    ${upload_SCF_vDU_operation}=    Get Operation History    hw_type=vDU    operation_name=Load SCF
#    ...   start_time=${start_test_timestamp}    end_time=${end_test_timestamp}
#    ${KPI_2_status}    ${KPI_2_measure}=    Check If Operation Meets Target    ${upload_SCF_vDU_operation[0]}    ${load_SCF_target}

    IF    not ${KPI_1_status}     #or not ${KPI_2_status}
        Fail    vCU: ${KPI_1_measure}s did not meet target ${load_SCF_target}!
    ELSE
#        Log To Console    vCU: ${KPI_1_measure}s & vDU: ${KPI_2_measure}s meets target ${load_SCF_target}
        Log To Console    vCU: ${KPI_1_measure}s meets target ${load_SCF_target}
    END

    #TODO: ADD Alarm check, ADD Remove Plan SCF in teardown