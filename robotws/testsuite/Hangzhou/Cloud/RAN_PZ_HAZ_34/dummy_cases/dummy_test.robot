*** Settings ***
Documentation    CI interface keywords, trigger all CI related step keyword.
...              Please do not modify the file without notification to author
...              Author: Civen Chen
...              Contact: civen.chen@nokia-sbell.com

#Library    taf.rfrl.common_resources.common_step.sleep_cell_check.ru_transmit_power    WITH NAME    scc
Resource    taf/rfrl/common_resources/common_step/interface.robot

Force Tags    PY36

*** Variables ***

*** Test Cases ***
Dummy Test
    interface.Common step trigger
    interface.Common step trigger    pass_ru_power_check=${True}
#    ${ru_power1}    Run Keyword And Return Status    scc.check_ecpri_ru_transmit_power_in_normal_range
#    ${ru_power2}    Run Keyword And Return Status    scc.check_ecpri_ru_transmit_power_in_normal_range    pass_ru_power_check=${True}


*** Keywords ***
