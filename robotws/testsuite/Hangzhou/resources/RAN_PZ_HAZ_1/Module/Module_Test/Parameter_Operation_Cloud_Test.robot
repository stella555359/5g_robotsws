*** Settings ***
Documentation
...    Author: Du Ning
...    Contact: ning.du@nokia-sbell.com
...    This is a testing case to verify the functions of modules.

Resource                ../Module.robot
Resource                ../../../../RRM/RAN_PZ_HAZ_1/Resources/Cloud/AIC_Common_Resource.robot

Suite Setup             Common Suite Setup For AIC
Suite Teardown          Common Suite Teardown For AIC
Test Setup              Common Test Setup For AIC
Test Teardown           Common Test Teardown For AIC


Force Tags              RAN_5G
Test Timeout            120 minutes

*** Variables ***
${SCF_Foler}            /home/ute/MN/UTE/robotws/testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/Module/Module_Test/Parameter_Operation_SCF/

*** Test Cases ***
Parameter_Operation_Test_Operation_Typing_Error
    ${case_result}    ${out}    Run Keyword And Ignore Error    Parameter Operation    operation=asdf   product_type=vdu
    Log To Console    \nOutput is: ${out}
    Log To Console    \nCase Result: ${case_result}
    Should Be Equal    ${case_result}    FAIL

Parameter_Operation_Test_Delta_Plan_Delta_File_Path_Missing
    ${case_result}    ${out}    Run Keyword And Ignore Error    Parameter Operation    operation=delta_plan_update   product_type=vcu
    Log To Console    \nVCU delta plan update result: ${out}
    Log To Console    \nCase Result: ${case_result}
    Should Be Equal    ${case_result}    FAIL

Parameter_Operation_Test_Delta_Plan_Delta_File_Path_Wrong
    ${case_result}    ${out}    Run Keyword And Ignore Error    Parameter Operation    operation=delta_plan_update   product_type=vcu
    ...                                                                                delta_file_path=${SCF_Foler}vxx_delta_plan_true.xml
    Log To Console    \nVCU delta plan update result: ${out}
    Log To Console    \nCase Result: ${case_result}
    Should Be Equal    ${case_result}    FAIL

Parameter_Operation_Test_Scf_File_Path_Missing
    ${case_result}    ${out}    Run Keyword And Ignore Error    Parameter Operation    operation=full_commission   product_type=vcu
    Log To Console    \nVCU delta plan update result: ${out}
    Log To Console    \nCase Result: ${case_result}
    Should Be Equal    ${case_result}    FAIL

Parameter_Operation_Test_Scf_File_Path_Wrong
    ${case_result}    ${out}    Run Keyword And Ignore Error    Parameter Operation    operation=full_commission   product_type=vcu
    ...                                                                                delta_file_path=${SCF_Foler}vxx_scf_true.xml
    Log To Console    \nVCU delta plan update result: ${out}
    Log To Console    \nCase Result: ${case_result}
    Should Be Equal    ${case_result}    FAIL

Parameter_Operation_Delta_Plan_Update
    ${out}    Parameter Operation    operation=delta_plan_update   product_type=vdu    delta_file_path=${SCF_Foler}vdu_delta_plan_true.xml
    Log To Console    \nVDU delta plan update result: ${out}
    ${out}    Parameter Operation    operation=delta_plan_update   product_type=vcu    delta_file_path=${SCF_Foler}vcu_delta_plan_true.xml
    Log To Console    \nVCU delta plan update result: ${out}

    @{para_list}    Create List    actCDrx    actCDrxVoNR    actEnhancedVoNR    actVoNR
    @{mo_list_vdu}    Create List    MRBTS-1/NRBTS-1/NRCELL-1    MRBTS-1/NRBTS-1/NRCELL-1
    ...                              MRBTS-1/NRBTS-1/NRCELL-1    MRBTS-1/NRBTS-1/NRCELL-1
    @{mo_list_vcu}    Create List    MRBTS-1/NRBTS-1/NRCELL-1    MRBTS-1/NRBTS-1/NRCELL-1
    ...                              MRBTS-1/NRBTS-1/NRCELL-1    MRBTS-1/NRBTS-1/NRCELL-1
    ${out}    Parameter Operation    operation=parameter_value_check   product_type=vdu    para_list=@{para_list}    mo_list=@{mo_list_vdu}
    Log To Console    \nVDU Parameter Check Result: ${out}
    ${out}    Parameter Operation    operation=parameter_value_check   product_type=vcu    para_list=@{para_list}    mo_list=@{mo_list_vcu}
    Log To Console    \nVCU Parameter Check Result: ${out}

    Sleep    20s

    ${out}    Parameter Operation    operation=delta_plan_update   product_type=vdu    delta_file_path=${SCF_Foler}vdu_delta_plan_false.xml
    Log To Console    \nVDU delta plan update result: ${out}
    ${out}    Parameter Operation    operation=delta_plan_update   product_type=vcu    delta_file_path=${SCF_Foler}vcu_delta_plan_false.xml
    Log To Console    \nVCU delta plan update result: ${out}

    @{para_list}    Create List    actCDrx    actCDrxVoNR    actEnhancedVoNR    actVoNR
    @{mo_list_vdu}    Create List    MRBTS-1/NRBTS-1/NRCELL-1    MRBTS-1/NRBTS-1/NRCELL-1
    ...                              MRBTS-1/NRBTS-1/NRCELL-1    MRBTS-1/NRBTS-1/NRCELL-1
    @{mo_list_vcu}    Create List    MRBTS-1/NRBTS-1/NRCELL-1    MRBTS-1/NRBTS-1/NRCELL-1
    ...                              MRBTS-1/NRBTS-1/NRCELL-1    MRBTS-1/NRBTS-1/NRCELL-1
    ${out}    Parameter Operation    operation=parameter_value_check   product_type=vdu    para_list=@{para_list}    mo_list=@{mo_list_vdu}
    Log To Console    \nVDU Parameter Check Result: ${out}
    ${out}    Parameter Operation    operation=parameter_value_check   product_type=vcu    para_list=@{para_list}    mo_list=@{mo_list_vcu}
    Log To Console    \nVCU Parameter Check Result: ${out}

Parameter_Operation_Parameter_Update
    @{para_list}    Create List    actCDrx    actCDrxVoNR    actEnhancedVoNR    actVoNR
    @{mo_list_vdu}    Create List    MRBTS-1/NRBTS-1/NRCELL-1    MRBTS-1/NRBTS-1/NRCELL-1
    ...                              MRBTS-1/NRBTS-1/NRCELL-1    MRBTS-1/NRBTS-1/NRCELL-1
    @{mo_list_vcu}    Create List    MRBTS-1/NRBTS-1/NRCELL-1    MRBTS-1/NRBTS-1/NRCELL-1
    ...                              MRBTS-1/NRBTS-1/NRCELL-1    MRBTS-1/NRBTS-1/NRCELL-1
    @{value_list_true}    Create List    true    true    true    true
    @{value_list_false}    Create List    false    false    false    false

    ${out}    Parameter Operation    operation=parameter_value_check   product_type=vdu    para_list=@{para_list}    mo_list=@{mo_list_vdu}
    Log To Console    \nVDU Parameter Check Result: ${out}
    ${out}    Parameter Operation    operation=parameter_value_check   product_type=vcu    para_list=@{para_list}    mo_list=@{mo_list_vcu}
    Log To Console    \nVCU Parameter Check Result: ${out}

    ${out}    Parameter Operation    operation=parameter_update   product_type=vdu
    ...                              para_list=@{para_list}    value_list=@{value_list_true}    mo_list=@{mo_list_vdu}
    ${out}    Parameter Operation    operation=parameter_update   product_type=vcu
    ...                              para_list=@{para_list}    value_list=@{value_list_true}    mo_list=@{mo_list_vcu}

    ${out}    Parameter Operation    operation=parameter_value_check   product_type=vdu
    ...                              para_list=@{para_list}    mo_list=@{mo_list_vdu}
    Log To Console    \nVDU Parameter Check Result: ${out}
    ${out}    Parameter Operation    operation=parameter_value_check   product_type=vcu
    ...                              para_list=@{para_list}    mo_list=@{mo_list_vcu}
    Log To Console    \nVCU Parameter Check Result: ${out}

    ${out}    Parameter Operation    operation=parameter_update   product_type=vdu
    ...                              para_list=@{para_list}    value_list=@{value_list_false}    mo_list=@{mo_list_vdu}
    ${out}    Parameter Operation    operation=parameter_update   product_type=vcu
    ...                              para_list=@{para_list}    value_list=@{value_list_false}    mo_list=@{mo_list_vcu}

    ${out}    Parameter Operation    operation=parameter_value_check   product_type=vdu    para_list=@{para_list}    mo_list=@{mo_list_vdu}
    Log To Console    \nVDU Parameter Check Result: ${out}
    ${out}    Parameter Operation    operation=parameter_value_check   product_type=vcu    para_list=@{para_list}    mo_list=@{mo_list_vcu}
    Log To Console    \nVCU Parameter Check Result: ${out}

Parameter_Operation_Modify_List
    # List参数和简单参数混合修改（第二项为List参数）
    @{para_list}          Create List    btsName    refNrCellGroup/0
    @{value_list}         Create List    test_10868_bstname    1
    @{mo_list}            Create List    MRBTS-1    MRBTS-1/NRBTS-1/NRDU-1

    ${out}                Parameter Operation    operation=parameter_value_check   product_type=vdu    para_list=@{para_list}    mo_list=@{mo_list}
    Log To Console        \nVDU Parameter Check Result: ${out}

    ${res}                Parameter Operation    operation=parameter_update    product_type=vdu
    ...                                          para_list=${para_list}    value_list=${value_list}    mo_list=${mo_list}
    Log To Console        VDU paramter update result: ${res}

    ${out}                Parameter Operation    operation=parameter_value_check   product_type=vdu    para_list=@{para_list}    mo_list=@{mo_list}
    Log To Console        \nVDU Parameter Check Result: ${out}

Parameter_Operation_Modify_Staged
    # Staged参数修改
    @{para_list}          Create List    prachConfigurationIndex
    @{value_list}         Create List    89
    @{mo_list}            Create List    MRBTS-1/NRBTS-1/NRCELL-1

    ${out}                Parameter Operation    operation=parameter_value_check   product_type=vdu    para_list=@{para_list}    mo_list=@{mo_list}
    Log To Console        \nVDU Parameter Check Result: ${out}

    ${res}                Parameter Operation    operation=parameter_update    product_type=vdu
    ...                                          para_list=${para_list}    value_list=${value_list}    mo_list=${mo_list}
    Log To Console        VDU paramter update result: ${res}

    ${out}                Parameter Operation    operation=parameter_value_check   product_type=vdu    para_list=@{para_list}    mo_list=@{mo_list}
    Log To Console        \nVDU Parameter Check Result: ${out}

Parameter_Operation_Modify_Random
    # 简单参数修改，目标值为给出的多个值中随机选择
    @{para_list}          Create List    btsName
    @{value_list}         Create List    CU_10868_077+CU_10868_033+CU_10868_022
    @{mo_list}            Create List    MRBTS-1

    ${out}                Parameter Operation    operation=parameter_value_check   product_type=vcu    para_list=@{para_list}    mo_list=@{mo_list}
    Log To Console        \nVDU Parameter Check Result: ${out}

    ${res}                Parameter Operation    operation=parameter_update    product_type=vcu
    ...                                          para_list=${para_list}    value_list=${value_list}    mo_list=${mo_list}
    Log To Console        VDU paramter update result: ${res}

    ${out}                Parameter Operation    operation=parameter_value_check   product_type=vcu    para_list=@{para_list}    mo_list=@{mo_list}
    Log To Console        \nVDU Parameter Check Result: ${out}

Parameter_Operation_Full_Commission
    @{para_list}    Create List    actCDrx    actCDrxVoNR    actEnhancedVoNR    actVoNR
    @{mo_list_vdu}    Create List    MRBTS-1/NRBTS-1/NRCELL-1    MRBTS-1/NRBTS-1/NRCELL-1
    ...                              MRBTS-1/NRBTS-1/NRCELL-1    MRBTS-1/NRBTS-1/NRCELL-1
    @{mo_list_vcu}    Create List    MRBTS-1/NRBTS-1/NRCELL-1    MRBTS-1/NRBTS-1/NRCELL-1
    ...                              MRBTS-1/NRBTS-1/NRCELL-1    MRBTS-1/NRBTS-1/NRCELL-1

    ${out}    Parameter Operation    operation=parameter_value_check   product_type=vdu    para_list=@{para_list}    mo_list=@{mo_list_vdu}
    Log To Console    \nVDU Parameter Check Result: ${out}
    ${out}    Parameter Operation    operation=parameter_value_check   product_type=vcu    para_list=@{para_list}    mo_list=@{mo_list_vcu}
    Log To Console    \nVCU Parameter Check Result: ${out}

    ${out}    Parameter Operation    operation=full_commission   product_type=vdu    scf_path=${SCF_Foler}vdu_scf_true.xml
    Log To Console    \nVDU scf commission result: ${out}
    ${out}    Parameter Operation    operation=full_commission   product_type=vcu    scf_path=${SCF_Foler}vcu_scf_true.xml
    Log To Console    \nVCU scf commission result: ${out}

    ${out}    Parameter Operation    operation=parameter_value_check   product_type=vdu    para_list=@{para_list}    mo_list=@{mo_list_vdu}
    Log To Console    \nVDU Parameter Check Result: ${out}
    ${out}    Parameter Operation    operation=parameter_value_check   product_type=vcu    para_list=@{para_list}    mo_list=@{mo_list_vcu}
    Log To Console    \nVCU Parameter Check Result: ${out}

    ${out}    Parameter Operation    operation=full_commission   product_type=vdu    scf_path=${SCF_Foler}vdu_scf.xml
    Log To Console    \nVDU scf commission result: ${out}
    ${out}    Parameter Operation    operation=full_commission   product_type=vcu    scf_path=${SCF_Foler}vcu_scf.xml
    Log To Console    \nVCU scf commission result: ${out}

    ${out}    Parameter Operation    operation=parameter_value_check   product_type=vdu    para_list=@{para_list}    mo_list=@{mo_list_vdu}
    Log To Console    \nVDU Parameter Check Result: ${out}
    ${out}    Parameter Operation    operation=parameter_value_check   product_type=vcu    para_list=@{para_list}    mo_list=@{mo_list_vcu}
    Log To Console    \nVCU Parameter Check Result: ${out}


