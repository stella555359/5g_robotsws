*** Settings ***
Documentation
...         TODO

*** Variables ***
${hytem_ip}                           10.0.116.251
${hytem_user}                         admin
${hytem_password}                     admin

*** Keywords ***
Set Hytem Attenuations for gNB 0 cell 0
    [Arguments]     ${value}=935
    Log to console               \nHytem Attenuations for gNB 0 cell 0 started
    vm_handler.hytemTelnet323    ${hytem_ip}   10004   1   ${value}
    Log to console               Hytem Attenuations for gNB 0 cell 0 finished

Set Hytem Attenuations for gNB 0 cell 1
    [Arguments]     ${value}=935
    Log to console               \nHytem Attenuations for gNB 0 cell 1 started
    vm_handler.connect           ${vm_ip}    ${vm_user}    ${vm_password}
    vm_handler.hytemTelnet323    ${custom['Hytem_IP']}   ${custom['Hytem_PORT_5G_RU2_AEQE_RADIO1']}   5   ${value}
    vm_handler.close
    vm_handler.connect           ${vm_ip}    ${vm_user}    ${vm_password}
    vm_handler.hytemTelnet323    ${custom['Hytem_IP']}   ${custom['Hytem_PORT_5G_RU2_AEQE_RADIO2']}   6   ${value}
    vm_handler.close
    vm_handler.connect           ${vm_ip}    ${vm_user}    ${vm_password}
    vm_handler.hytemTelnet323    ${custom['Hytem_IP']}   ${custom['Hytem_PORT_5G_RU2_AEQE_RADIO3']}   7   ${value}
    vm_handler.close
    vm_handler.connect           ${vm_ip}    ${vm_user}    ${vm_password}
    vm_handler.hytemTelnet323    ${custom['Hytem_IP']}   ${custom['Hytem_PORT_5G_RU2_AEQE_RADIO4']}   8   ${value}
    vm_handler.close
    Log to console               Hytem Attenuations for gNB 0 cell 1 finished

Hytem Initialization
    Log to console               \nHytem Attenuators initalization 5G part started
    Set Hytem Attenuations for gNB 0 cell 0   value=9350
    Set Hytem Attenuations for gNB 0 cell 1   value=9350
    Log to console               Hytem Attenuators initalization 5G part ended

Hytem Restoration
    Hytem Initialization
