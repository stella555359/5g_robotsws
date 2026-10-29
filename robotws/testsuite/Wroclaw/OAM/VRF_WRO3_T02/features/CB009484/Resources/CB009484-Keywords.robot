*** Settings ***
Documentation
...         Provides CB009484 specific keywords
...         test automation author: Robert Rozanski
...         contact: robert.rozanski@nokia.com

*** Variables ***
@{pspectreV2KernelState_list}=              spectreV2KernelState
@{ptiKernelState_list}=                     ptiKernelState
@{check_actPtiAndSpectreV2KernelFlag}=      actPtiAndSpectreV2KernelFlag

*** Keywords ***
Check flags spectreV2KernelState and ptiKernelState from Webem with disable actPtiAndSpectreV2KernelFlag
    [Documentation]    Keyword checks flags spectreV2KernelState and ptiKernelState from Webem
    ...                with disable actPtiAndSpectreV2KernelFlag
    [Arguments]    ${dist_name}    ${SM_or_BB}    ${connection}=Connection_Webem
    ${spectreV2KernelState_actual_state}    coam_admin.get_parameter_by_distname
    ...    ${dist_name}    ${pspectreV2KernelState_list}    connection=${connection}
    should be equal as strings
    ...    [{'distName': '${dist_name}', 'parameters': {'spectreV2KernelState': 'Disabled'}}]  ${spectreV2KernelState_actual_state}
    Log     spectreV2KernelState value for ${SM_or_BB} - ${spectreV2KernelState_actual_state}\n       console=True
    ${ptiKernelState_actual_state}    coam_admin.get_parameter_by_distname
    ...    ${dist_name}     ${ptiKernelState_list}    connection=${connection}
    should be equal as strings
    ...    [{'distName': '${dist_name}', 'parameters': {'ptiKernelState': 'Disabled'}}]  ${ptiKernelState_actual_state}
    Log     ptiKernelState value for ${SM_or_BB} - ${ptiKernelState_actual_state}\n       console=True

Check flags spectreV2KernelState and ptiKernelState from Webem with enable actPtiAndSpectreV2KernelFlag
    [Documentation]    Keyword checks flags spectreV2KernelState and ptiKernelState from Webem
    ...                with enable actPtiAndSpectreV2KernelFlag
    [Arguments]    ${dist_name}    ${SM_or_BB}
    ${spectreV2KernelState_actual_state}    coam_admin.get_parameter_by_distname
    ...    ${dist_name}     ${pspectreV2KernelState_list}    connection=Connection_Webem
    should be equal as strings
    ...    [{'distName': '${dist_name}', 'parameters': {'spectreV2KernelState': 'Enabled'}}]  ${spectreV2KernelState_actual_state}
    Log     spectreV2KernelState value for ${SM_or_BB} - ${spectreV2KernelState_actual_state}\n       console=True
    ${ptiKernelState_actual_state}    coam_admin.get_parameter_by_distname
    ...    ${dist_name}     ${ptiKernelState_list}    connection=Connection_Webem
    should be equal as strings
    ...    [{'distName': '${dist_name}', 'parameters': {'ptiKernelState': 'Enabled'}}]  ${ptiKernelState_actual_state}
    Log     ptiKernelStatev value for ${SM_or_BB} - ${ptiKernelState_actual_state}\n       console=True

Check flags spectreV2KernelState and ptiKernelState from Webem actPtiAndSpectreV2KernelFlag Negative
    [Documentation]    Keyword checks flags spectreV2KernelState and ptiKernelState from Webem
    ...                on unsupported hardware
    [Arguments]    ${dist_name}    ${SM_or_BB}
    ${spectreV2KernelState_actual_state}    coam_admin.get_parameter_by_distname
    ...    ${dist_name}      ${pspectreV2KernelState_list}    connection=Connection_Webem
    should be equal as strings
    ...    [{'distName': '${dist_name}', 'parameters': {}}]  ${spectreV2KernelState_actual_state}
    Log     spectreV2KernelState value for ${SM_or_BB} - ${spectreV2KernelState_actual_state}\n       console=True
    ${ptiKernelState_actual_state}    coam_admin.get_parameter_by_distname
    ...    ${dist_name}     ${ptiKernelState_list}    connection=Connection_Webem
    should be equal as strings
    ...    [{'distName': '${dist_name}', 'parameters': {}}]  ${ptiKernelState_actual_state}
    Log     ptiKernelState value for ${SM_or_BB} - ${ptiKernelState_actual_state}\n       console=True

Check flags spectreV2KernelState and ptiKernelState from Webem actPtiAndSpectreV2KernelFlag ASIM
    [Documentation]    Keyword checks flags spectreV2KernelState and ptiKernelState from Webem
    ...                on ASIM hardware
    [Arguments]    ${dist_name}    ${SM_or_BB}
    ${spectreV2KernelState_actual_state}    coam_admin.get_parameter_by_distname
    ...    ${dist_name}      ${pspectreV2KernelState_list}    connection=Connection_Webem
    should be equal as strings
    ...    [{'distName': '${dist_name}', 'parameters': {'spectreV2KernelState': 'Unsupported'}}]  ${spectreV2KernelState_actual_state}
    Log     spectreV2KernelState value for ${SM_or_BB} - ${spectreV2KernelState_actual_state}\n       console=True
    ${ptiKernelState_actual_state}    coam_admin.get_parameter_by_distname
    ...    ${dist_name}     ${ptiKernelState_list}    connection=Connection_Webem
    should be equal as strings
    ...    [{'distName': '${dist_name}', 'parameters': {'ptiKernelState': 'Unsupported'}}]  ${ptiKernelState_actual_state}
    Log     ptiKernelState value for ${SM_or_BB} - ${ptiKernelState_actual_state}\n       console=True

Check parameter actPtiAndSpectreV2KernelFlag
    [Documentation]    Keyword checks parameter actPtiAndSpectreV2KernelFlag from Webem
    [Arguments]    ${actPtiAndSpectreV2_value}
    ${actPtiAndSpectreV2KernelFlag_actual_state}    coam_admin.get_parameter_by_distname
    ...    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1      ${check_actPtiAndSpectreV2KernelFlag}    connection=Connection_Webem
    should be equal as strings
    ...    [{'distName': 'MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1', 'parameters': {'actPtiAndSpectreV2KernelFlag': ${actPtiAndSpectreV2_value}}}]
    ...    ${actPtiAndSpectreV2KernelFlag_actual_state}
    Log     actPtiAndSpectreV2KernelFlag value - ${actPtiAndSpectreV2KernelFlag_actual_state}\n       console=True
