*** Settings ***
Library    String
Library    Collections

Library    taf.config.scf            WITH NAME    scf


*** Variables ***
${P_COMISSIONING_REQUIRED}          ${True}
${P_console}                        ${False}           # output to console can be enabled via "Set Console Output" from testline.robot


*** Keywords ***
Check if Commissioning is needed
    [Documentation]
    ...  This Keyword should apply to all Test-Cases, that use both the `Generate Delta Commissioning File`
    ...  and `Execute Delta Commissioning`. The Keyword aims to reduce time spent on recurring and unnecessary SCF Commissioning.
    ...
    ...  | param_list | The list of parameters that should be checked before executing the SCF. |
    ...  | ..         | Schema is the same as described in `Generate Delta Commissioning File`. |
    ...
    [Arguments]   ${param_list}   ${scf_file}
    scf.load_scf    ${scf_file}
    ${changeList}   Create List
    FOR  ${value}   IN   @{param_list}
       ${status}   ${readValue}   Run Keyword And Ignore Error   scf.get_value_from_scf
       ...   dist_name=${value["dist_name"]}
       ...   p_name=${value["p_name"]}

       ${readValue}    String.Convert To Lower Case   ${readValue}
       ${value.value}  String.Convert to Lower Case  ${value['value']}

       ${readValue}     Set Variable If   '${status}'=='FAIL'   ${status}   ${readValue}
       Run Keyword If   '${readValue}'=='${value['value']}'   BuiltIn.Log   ${value['value']} already set!   console=${P_console}
       ...   ELSE   Collections.Append To List   ${changeList}   ${value}
    END
    ${length}   Get Length   ${changeList}
    ${P_COMISSIONING_REQUIRED}  Set Variable If   '${length}'=='0'   ${False}   ${True}
    Set Suite Variable   ${P_COMISSIONING_REQUIRED}
    BuiltIn.Log   Comissioning needed: ${P_COMISSIONING_REQUIRED}    console=${P_console}

