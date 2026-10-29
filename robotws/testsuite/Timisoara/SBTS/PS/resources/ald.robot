*** Settings ***
Library  String
Library  OperatingSystem
Library  Process
Library  SSHLibrary
Library  Collections
Library  DateTime
Library  ute_syslog
Library  XML  use_lxml=true
Library  taf.sbts.oam.coam.admin  WITH NAME  admin


Documentation
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  Internal WRO1 resource library repetitive keywords in multiple tests.
...  ******************
...  History of changes
...  ******************
...  13.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-307 - Adaptation to CB008660. For parameters with isDistname=true
...                                                                 error type changed from relations error to deffinition error.
...  24.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-309 - Remove Comba RET antModel from Additional Data
...  13.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-494 - Fix for ALD.11_ALD_HDLC_Communication_management_in_runtime to handle RAE alarms
...  13.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-514 - Fix for tests related with fault 4141/4142. DC voltage in runtime...
...  xx.xx.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-xxx - xxx
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Variables ***
${ALD_expected_states}  administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled"


*** Keywords ***
Mapping RMOD_R To RMOD_A
    ${rmod_param}  admin.Get Managed Objects  RMOD_R
    ${RMOD_R_to_RMOD_A}  Create Dictionary
    FOR  ${ITEM}  IN  @{rmod_param}
        Set To Dictionary  ${RMOD_R_to_RMOD_A}  ${ITEM['distName']}  ${ITEM['parameters']['configDN']}
    END

    RETURN  ${RMOD_R_to_RMOD_A}
