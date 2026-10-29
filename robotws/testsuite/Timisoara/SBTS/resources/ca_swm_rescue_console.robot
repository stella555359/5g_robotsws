*** Settings ***
Documentation     [PURPOSE] SWM Keywords for FDSW18SP onwards Rescue Console from HZ
...               CA-SWM/COMPA    OWNER-wojciech.sikora@nokia.com  AUTHOR-wojciech.sikora@nokia.com
Library                 Collections
Library                 ute_admin_infomodel
Library                 DateTime
Library                 OperatingSystem
Library                 String
Library                 XML  use_lxml=${TRUE}
Library                 taf.fdsw.rc
Resource                hran_frame_sbts.robot
Resource                hran_infomodel.robot
Resource                hran_admin.robot
Resource                hran_general.robot
Resource                ca_swm_general.robot


*** Keywords ***
Connect to Rescue Console
    [Documentation]
    ...  Connect and authorize to FDSW Rescue Console
    ...
    ...  Parameters:
    ...  Parameter_name |TYPE  |
    ...  -----------------------------------------------------------------------------------------------
    ...  ip_address     |(str) | ie. 192.168.255.129
    ...  port           |(int) | ie. 443
    ...  username       |(str) | Username to authenticate to Rescue Console
    ...  password       |(str) | Password to authenticate to Rescue Console
    ...  fdsw_version   |(str) | Default: fdsw18sp .Specific FDSW version that you want to connect to
    ...                          needs to be in line with what is running on Node B NOTE: To use specific
    ...                          version, you need to disable auto_discover by setting it to False
    ...  auto_discover  |(bool)| Default: True, Enable auto-discovery of FDSW version that is running on
    ...                          Node B. Auto discover will try all supported FDSW versions from latest to oldest,
    ...                          and connect to first compliant version.
    ...  secure         |(bool)| Default: True, Enable secure connection to Node B (ie., https for http client)
    ...  name           |(str) | Name of returned connection. If not provided, this connection becomes default.
    ...
    ...
    ...  *AUTHOR*
    ...  wojciech.sikora@nokia.com

    [Arguments]  ${ip_address}=${SMOD1['TRS_IP']}  ${port}=443  ${username}=Nemuadmin  ${password}=nemuuser
    ...          ${fdsw_version}="fdsw18sp"  ${auto_discover}=${TRUE}  ${secure}=${TRUE}  ${name}=None

    ${aliases_check}  _Compare RC connection aliases  ${name}
    Run keyword if  ${aliases_check}  Run keywords
    ...  Log to console with time  Connection to RC already established using alias: ${name}
    ...  AND
    ...  Return from keyword
    Log    Trying to connect to FDSW Rescue Console (max 5 min)...  console=${TRUE}
    ${rc_started}  Run Keyword And Return Status  Wait Until Keyword Succeeds  5 min  15 sec
    ...    taf.fdsw.rc.Connect to  ip_address=${ip_address}  port=${port}  username=${username}  password=${password}
    ...                            fdsw_version=${fdsw_version}  auto_discover=${auto_discover}  secure=${secure}
    ...                            name=${name}
    Run keyword if    not ${rc_started}
    ...    Fail  Rescue Console connection did not start
    Set test variable  ${RC_STARTED}  ${TRUE}
    Set test variable  ${RC_ALIAS}    ${name}
    Log to console with time    Connection to Rescue Console successfully established!

_Compare RC connection aliases
    [Documentation]
    ...  Compare RC connection aliases
    ...  Return $TRUE if the same; $FALSE if different
    ...
    ...  *AUTHOR*
    ...  wojciech.sikora@nokia.com
    [Arguments]  ${alias_to_compare}
    ${status}  Run keyword and ignore error  Run keyword if  not ${RC_STARTED}  Run keywords
    ...  Set variable  ${FALSE}
    ...  AND
    ...  Return from keyword  ${FALSE}
    ${status}  Run keyword and return status  Should be equal  ${alias_to_compare}  ${RC_ALIAS}
    [Return]  ${status}

Teardown Rescue Console
    [Documentation]
    ...  Disconnects from RC and destroys node.js daemon
    ...
    ...  *AUTHOR*
    ...  wojciech.sikora@nokia.com

    [Arguments]  ${alias}=None
    Run keyword and ignore error  Run keyword if  ${RC_STARTED}
    ...  Log to console with time  Teardown connection to RC using alias: ${alias}
    ...  ELSE  Run keywords
    ...  Log to console with time  Connection to RC already closed
    ...  AND
    ...  Return from keyword
    ${teardown_status}  Run keyword and return status  taf.fdsw.rc.teardown  ${alias}
    Run keyword if  ${teardown_status}  Run keywords
    ...  Log to console with time  FDSW Rescue console teardown - successful
    ...  AND
    ...  Set test variable  ${RC_started}  ${FALSE}
    ...  ELSE
    ...  Log to console with time  FDSW Rescue console teardown FAILED!

Enable SSH via Rescue Console
    [Documentation]
    ...  Enables SSH via Rescue Console using library taf.fdsw.rc
    ...
    ...  *AUTHOR*
    ...  wojciech.sikora@nokia.com
    [Arguments]  ${timeout}=10  ${alias}=ssh_enabler  ${ip_address}=${SMOD1['TRS_IP']}  ${port}=443
    ...  ${username}=Nemuadmin  ${password}=nemuuser

    Log  Enable SSH using FDSW Rescue Console  console=${TRUE}
    ${rc_status}  Run Keyword And Return Status  Connect to Rescue Console
    ...  ip_address=${ip_address}  port=${port}  username=${username}  password=${password}  name=${alias}
    ${ssh_status}  Run keyword and return status
    ...  taf.fdsw.rc.Enable ssh service  timeout=${timeout}  connection=${alias}
    [Return]    ${ssh_status}
    [Teardown]  Teardown Rescue Console  connection=${alias}

Disable Ethernet port security via Rescue Console
    [Documentation]
    ...  Disables Ethernet port security via Rescue Console using library taf.fdsw.rc
    ...
    ...  *AUTHOR*
    ...  wojciech.sikora@nokia.com
    [Arguments]  ${timeout}=10  ${alias}=eps_disabler
    ...  ${ip_address}=${SMOD1['TRS_IP']}  ${port}=443  ${username}=Nemuadmin  ${password}=nemuuser

    Log  Enable SSH using FDSW Rescue Console  console=${TRUE}
    ${aliases_check}  _Compare RC connection aliases  ${alias}
    ${rc_status}  Run keyword if  ${aliases_check}
    ...  Log to console with time  Connection to RC already established using alias: ${alias}
    ...  ELSE
    ...  Run Keyword And Return Status  Connect to Rescue Console
    ...  ip_address=${ip_address}  port=${port}  username=${username}  password=${password}  name=${alias}
    ${disable_port_security_status}  Run keyword and return status
    ...  taf.fdsw.rc.Disable ethernet port security  timeout=${timeout}  connection=${alias}
    [Return]  ${disable_port_security_status}
    [Teardown]  Teardown Rescue Console  connection=${alias}

Get active and passive SW version from Rescue Console
    [Documentation]
    ...
    ...  *AUTHOR*
    ...  wojciech.sikora@nokia.com
    [Arguments]  ${ip_address}=${SMOD1['TRS_IP']}  ${port}=443  ${username}=Nemuadmin  ${password}=nemuuser
    ...  ${alias}=None

    Set Connection Parameters  ${SMOD1['TRS_IP']}
    Log  Get active and passive SW version from Rescue Console  console=${TRUE}
    ${aliases_check}  _Compare RC connection aliases  ${alias}
    ${rc_status}  Run keyword if  ${aliases_check}
    ...  Log to console with time  Connection to RC already established using alias: ${alias}
    ...  ELSE
    ...  Run Keyword And Return Status  Connect to Rescue Console
    ...  ip_address=${ip_address}  port=${port}  username=${username}  password=${password}  name=${alias}
    ${running_sw_version}  taf.fdsw.rc.Get running sw version name  connection=${alias}
    ${sw_version_1}  taf.fdsw.rc.Get sw version name  sw_slot_id=1  connection=${alias}
    ${sw_version_2}  taf.fdsw.rc.Get sw version name  sw_slot_id=2  connection=${alias}
    ${active_sw_version}  Set variable if  '${sw_version_1}'=='${running_sw_version}'  ${sw_version_1}
    ...  '${sw_version_2}'=='${running_sw_version}'  ${sw_version_2}  ${None}
    ${passive_sw_version}  Set variable if  '${sw_version_1}'=='${active_sw_version}'  ${sw_version_2}  ${sw_version_1}
    Log important message  Active SW: ${active_sw_version}${\n}Passive SW: ${passive_sw_version}
    [Return]  ${active_sw_version}  ${passive_sw_version}
    [Teardown]  Teardown Rescue Console  ${alias}
