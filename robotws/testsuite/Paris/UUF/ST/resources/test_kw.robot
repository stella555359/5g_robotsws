*** Settings ***

Resource    kw_UUF_Software_upgrade.robot
Resource    kw_UUF_Reset.robot


*** Variables ***
${NUMBER_OF_LOOPS}=  5
${tribe}=            RAN_PZ_NPS_1
${site}=             ParisSaclay


*** Test Cases ***
Reset_kw
   Reset of eNB without HWF in loop
   [Teardown]  Teardown Reset of eNB without HWF in loop


Software_upgrade_kw
    UUF Software Upgrade
