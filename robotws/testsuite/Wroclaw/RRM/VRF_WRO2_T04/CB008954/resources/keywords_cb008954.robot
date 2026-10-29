*** Settings ***
Documentation
...   Keywords for CB008954 feature - Up to 3 BWP for UE with different bandwidth capabilities

Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB008281/resources/variables_8281.py
Library    ute_ue
Library    ../../../resources/webui/interface.py

*** Keywords ***
Trigger HO
    Gradually Decrease Attenuation For Cell    cell_id=2    grad_step=15
    Gradually Increase Attenuation For Cell    cell_id=3    grad_step=15

Trigger Reestablishment
    Gradually Decrease Attenuation For Cell    cell_id=3    grad_step=15
    Gradually Increase Attenuation For Cell    cell_id=2    grad_step=15
    BuiltIn.Sleep    10    Wait for Reestablishment

Detach Ues
    ute_ue.Detach Ue    ${UE_1}
    ute_ue.Detach Ue    ${UE_2}
    ute_ue.Detach Ue    ${UE_3}
