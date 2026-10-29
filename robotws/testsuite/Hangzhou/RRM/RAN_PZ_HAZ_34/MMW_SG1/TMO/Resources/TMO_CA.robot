*** Settings ***
Resource     ./TMO_Variables.robot
Variables    commissionings/HGZ/${testline_name}/__init__.py
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/CA_Common_New/ca_specifical_step.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/CA_keywords.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/CA_Common_New/L3_call_check_based_on_RRC.robot
#Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/TestData/Parameters_modify_lib.py    WITH NAME    param_modify_lib
#Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/lib/online_nidd_process.py    WITH NAME    nidd_modify
