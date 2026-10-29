*** Settings ***
Documentation
...   Author: liping.hong@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***
${actInternalTrace_xpath}   cmData/managedObject[@class="com.nokia.srbts.mnl:TRBLCADM"]/p[@name="actInternalTrace"]
${actInternalTrace_dist}   MRBTS-861/MNL-1/MNLENT-1/TRBLCADM-1

*** Keyword ***
5GC001542-GA_Activate_internal_trace_-_unsucceeded
    Log To Console   5GC001542-GA_Activate_internal_trace_-_unsucceeded
    ${status}   Run Keyword And Return Status   Check Parameter Value from SCF   ${actInternalTrace_xpath}   false
    run keyword if  not ${status}   Run Keywords
    ...   Modify Parameter via COAM Admin   dist_name=${actInternalTrace_dist}   parameter=actInternalTrace   value=false
    ...   AND   Check Parameter Value from SCF   ${actInternalTrace_xpath}   false
    ${fail_delta_plan}   Catenate  SEPARATOR=
    ...   [{
    ...      "distName": "${MRBTS}/MNL-1/MNLENT-1/TRBLCADM-1",
    ...      "operation": "update",
    ...      "parameters": [{
    ...          "parameterName": "actInternalTrace",
    ...          "parameters": "cokolwiek",
    ...          "operation": "update"
    ...       }]
    ...    }]
    Run Keyword And Expect Error           *provided value is not consistent with parameter NIDD definition*
    ...                                    Perform Delta Recommission via COAM Admin
    ...                                    delta_plan=${fail_delta_plan}

5GC001542-GA_Commission_Plan_with_productVariantPlanned_=_31_and_without_actInternalTrace_parameter
    ${delete_delta_plan}   Catenate  SEPARATOR=
    ...   [{
    ...      "distName":"${MRBTS}/MNL-1/MNLENT-1/TRBLCADM-1",
    ...      "operation":"delete",
    ...      "parameters":[]
    ...   }]
    Run Keyword And Expect Error           *AdminApiProcedureFailureException:*
    ...                                    Perform Delta Recommission via COAM Admin
    ...                                    delta_plan=${delete_delta_plan}

5GC001542-GA_Deactivate_internal_trace_-_unsucceeded
    Log To Console   5GC001542-GA_Deactivate_internal_trace_-_unsucceeded
    ${status}   Run Keyword And Return Status   Check Parameter Value from SCF   ${actInternalTrace_xpath}   true
    run keyword if  not ${status}   Run Keywords
    ...   Modify Parameter via COAM Admin   dist_name=${actInternalTrace_dist}   parameter=actInternalTrace   value=true
    ...   AND   Check Parameter Value from SCF   ${actInternalTrace_xpath}   true
    ${fail_delta_plan}   Catenate  SEPARATOR=
    ...   [{
    ...      "distName": "${MRBTS}/MNL-1/MNLENT-1/TRBLCADM-1",
    ...      "operation": "update",
    ...      "parameters": [{
    ...          "parameterName": "actInternalTrace",
    ...          "parameters": "cokolwiek",
    ...          "operation": "update"
    ...       }]
    ...    }]
    Run Keyword And Expect Error           *provided value is not consistent with parameter NIDD definition*
    ...                                    Perform Delta Recommission via COAM Admin
    ...                                    delta_plan=${fail_delta_plan}
