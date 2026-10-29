*** Settings ***
Resource  ./Resources/keywords_12486_CR.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_Cloud.robot
Resource    ${BASIC_PATH_CLOUD}/Cloud_Setup_and_Teardown.robot
Resource    ${BASIC_PATH_CLOUD}/Cloud_General_SiSo_vDU_Reset.robot

Suite Setup         Cloud Suite Setup
Suite Teardown      Cloud Suite Teardown
Test Setup          Test Setup
Test Teardown       Cloud Test Teardown

Documentation
...    Author:Yang Liqin
...    contact:liqin.yang@nokia-sbell.com
...    squad group:SG_05
...    Feature CB012486
 
Force Tags    SBTS00
...   PY36
 
*** Variables ***
${line_case_dir}    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG4/Cloud/cases
${stability_l3_duration}    ${21600}
${is_dc}    ${True}
${if_commissioning}    ${False}
*** Test Cases ***
Manual_SiSo_SM_BTS_Site_Reset
  [Documentation]  Cloud
  Cloud_Manual_SiSo_SM_BTS_Site_Reset
