*** Settings ***

Documentation
...   This resource file provides specific helper KWs for commissioning.

Library    String
Library    Collections

Library    taf.config.scf            WITH NAME    scf


*** Variables ***
${P_COMISSIONING_REQUIRED}          ${True}
${P_console}                        ${False}           # output to console can be enabled via "Set Console Output" from testline.robot


*** Keywords ***
Check If Commissioning Is Needed
    [Documentation]
    ...  This Keyword should apply to all Test-Cases, that use both the `Generate Delta Commissioning File`
    ...  and `Execute Delta Commissioning`. The Keyword aims to reduce time spent on recurring and unnecessary SCF Commissioning.
    ...
    ...  | param_list | The list of parameters that should be checked before executing the SCF. |
    ...  | ..         | Schema is the same as described in `Generate Delta Commissioning File`. |
    ...
    [Arguments]   ${param_list}   ${scf_file}
    scf.Load SCF    ${scf_file}
    ${changeList}   Create List
    FOR  ${value}   IN   @{param_list}
       ${status}   ${readValue}   Run Keyword And Ignore Error   scf.Get Value From SCF
       ...   dist_name=${value["dist_name"]}
       ...   p_name=${value["p_name"]}

       ${readValue}    String.Convert To Lower Case   ${readValue}
       ${value.value}  String.Convert To Lower Case  ${value['value']}

       ${readValue}     Set Variable If   '${status}'=='FAIL'   ${status}   ${readValue}
       IF   '${readValue}'=='${value['value']}'   Log   ${value['value']} already set!   console=${P_console}
       ...   ELSE   Collections.Append To List   ${changeList}   ${value}
    END
    ${length}   Get Length   ${changeList}
    ${P_COMISSIONING_REQUIRED}  Set Variable If   '${length}'=='0'   ${False}   ${True}
    Set Suite Variable   ${P_COMISSIONING_REQUIRED}
    Log   Comissioning needed: ${P_COMISSIONING_REQUIRED}    console=${P_console}

