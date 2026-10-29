*** Keywords ***
Hytem Initialization
    Log to console               \nHytem Attenuators initalization 4G and 5G part started
    vm_handler.connect           ${vm_ip}    ${vm_user}    ${vm_password}
    vm_handler.hytemTelnet323    ${custom['Hytem_IP']}   ${custom['Hytem_PORT_5G_5110']}   1   9350
    vm_handler.close
    vm_handler.connect           ${vm_ip}    ${vm_user}    ${vm_password}
    vm_handler.hytemTelnet323    ${custom['Hytem_IP']}   ${custom['Hytem_PORT_5G_5111']}   2   9350
    vm_handler.close
    vm_handler.connect           ${vm_ip}    ${vm_user}    ${vm_password}
    vm_handler.hytemTelnet323    ${custom['Hytem_IP']}   ${custom['Hytem_PORT_5G_5112']}   3   9350
    vm_handler.close
    vm_handler.connect           ${vm_ip}    ${vm_user}    ${vm_password}
    vm_handler.hytemTelnet323    ${custom['Hytem_IP']}   ${custom['Hytem_PORT_5G_5113']}   4   9350
    vm_handler.close
    vm_handler.connect           ${vm_ip}    ${vm_user}    ${vm_password}
    vm_handler.hytemTelnet323    ${custom['Hytem_IP']}   ${custom['Hytem_PORT_5G_5210']}   5   9350
    vm_handler.close
    vm_handler.connect           ${vm_ip}    ${vm_user}    ${vm_password}
    vm_handler.hytemTelnet323    ${custom['Hytem_IP']}   ${custom['Hytem_PORT_5G_5211']}   6   9350
    vm_handler.close
    vm_handler.connect           ${vm_ip}    ${vm_user}    ${vm_password}
    vm_handler.hytemTelnet323    ${custom['Hytem_IP']}   ${custom['Hytem_PORT_5G_5212']}   7   9350
    vm_handler.close
    vm_handler.connect           ${vm_ip}    ${vm_user}    ${vm_password}
    vm_handler.hytemTelnet323    ${custom['Hytem_IP']}   ${custom['Hytem_PORT_5G_5213']}   8   9350
    vm_handler.close
    Log to console               Hytem Attenuators initalization 4G and 5G part finished\n


Set Hytem Attenuations for gNB 0 cell 0
    [Arguments]     ${value}=935
    Log to console               \nHytem Attenuations for gNB 0 cell 0 started
    vm_handler.connect           ${vm_ip}    ${vm_user}    ${vm_password}
    vm_handler.hytemTelnet323    ${custom['Hytem_IP']}   ${custom['Hytem_PORT_5G_5110']}   1   ${value}
    vm_handler.close
    vm_handler.connect           ${vm_ip}    ${vm_user}    ${vm_password}
    vm_handler.hytemTelnet323    ${custom['Hytem_IP']}   ${custom['Hytem_PORT_5G_5111']}   2   ${value}
    vm_handler.close
    vm_handler.connect           ${vm_ip}    ${vm_user}    ${vm_password}
    vm_handler.hytemTelnet323    ${custom['Hytem_IP']}   ${custom['Hytem_PORT_5G_5112']}   3   ${value}
    vm_handler.close
    vm_handler.connect           ${vm_ip}    ${vm_user}    ${vm_password}
    vm_handler.hytemTelnet323    ${custom['Hytem_IP']}   ${custom['Hytem_PORT_5G_5113']}   4   ${value}
    vm_handler.close
    Log to console               Hytem Attenuations for gNB 0 cell 0 finished\n

Set Hytem Attenuations for gNB 0 cell 1
    [Arguments]     ${value}=935
    Log to console               \nHytem Attenuations for gNB 0 cell 1 started
    vm_handler.connect           ${vm_ip}    ${vm_user}    ${vm_password}
    vm_handler.hytemTelnet323    ${custom['Hytem_IP']}   ${custom['Hytem_PORT_5G_5210']}   5   ${value}
    vm_handler.close
    vm_handler.connect           ${vm_ip}    ${vm_user}    ${vm_password}
    vm_handler.hytemTelnet323    ${custom['Hytem_IP']}   ${custom['Hytem_PORT_5G_5211']}   6   ${value}
    vm_handler.close
    vm_handler.connect           ${vm_ip}    ${vm_user}    ${vm_password}
    vm_handler.hytemTelnet323    ${custom['Hytem_IP']}   ${custom['Hytem_PORT_5G_5212']}   7   ${value}
    vm_handler.close
    vm_handler.connect           ${vm_ip}    ${vm_user}    ${vm_password}
    vm_handler.hytemTelnet323    ${custom['Hytem_IP']}   ${custom['Hytem_PORT_5G_5213']}   8   ${value}
    vm_handler.close
    Log to console               Hytem Attenuations for gNB 0 cell 1 finished\n

Hytem Restoration
    Hytem Initialization
