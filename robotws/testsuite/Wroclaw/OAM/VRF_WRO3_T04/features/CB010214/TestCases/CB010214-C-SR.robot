*** Settings ***
Documentation
...  author:      Marta Gal
...  contact:     marta.gal@nokia.com
...  description: The test cases about testing the CB010214-C


Resource    ../Resources/CB010214-SR_Resources.robot
Resource    ../../../common_resources/mantaray/mantaray.robot
Resource    ../../../common_resources/connections/connections.robot
Resource    ../../../common_resources/commissioning/parameters.robot
Resource    ../../../common_resources/admin/admin.robot
Resource    ../../../common_resources/commissioning/commissioning.robot
Resource    ../../../common_resources/commissioning/parameters.robot
Resource    ../../../common_resources/alarms/alarm.robot
Resource    ../../../common_resources/rest_api/rest_api.robot
Resource    ../../../common_resources/passwords/password_change.robot

Library      taf.config.scf    WITH NAME   scf
Library      OperatingSystem
Library      SSHLibrary
Library      BuiltIn
Library      taf.selenium.sbts  WITH NAME    sbts_selenium

*** Variables ***
${value2}=                NoRWsessionAllowed
${readonly_username}=     BTSRead
${readonly_password}=     QAws123!@#
${Nemuadmin}=             BTSSystem
${nemuadmin_password}=    QAws123!@#
${app_user}=              BTSApplication
${app_password}=          QAws123!@#

*** Keywords ***
CB010214-C_btsEMRestrictAccSession_modification-local_users
    Log    Step 1: Setting the BTSRead, BTSApplication and Nemuadmin account    console=True
    Turn Off TLS
    ${LAB_NMS}=     Integrate BTS to MantaRay without TLS
    Setup Local user account                   account_type=BTSRead     new_password=${readonly_password}
    Setup Local user account                   account_type=BTSApplication    new_password=${app_password}
    Change Local User Account Credentials      old_username=Nemuadmin        old_password=nemuuser
    ...                                        new_username=${Nemuadmin}    new_password=${nemuadmin_password}
    ${connect_admin}=   Connect to ADMIN
    ...                 username=${Nemuadmin}
    ...                 password=${nemuadmin_password}
    ...                 timeout=${180}
    ${scf_path}=  admin.Download SCF  connection=${connect_admin}
    Reset Site And Reconnect       connection=${connect_admin}    wait_for_reconnection=False
    Wait Until Keyword Succeeds    20 min    30 sec    Check If BTS Is Pingable
    ${conn_adm}=        Wait Until Keyword Succeeds    5 min    30 sec    Connect to ADMIN
    ...                 username=${Nemuadmin}
    ...                 password=${nemuadmin_password}
    ...                 timeout=${180}
    ...                 alias=connection_after_reset
    Wait Until Keyword Succeeds    10 min    30 sec    Wait Until BTS Reach Configured Or OnAir State
    ...     connection=${conn_adm}
    Disconnect from ADMIN      connection=${conn_adm}
    Disconnect from ADMIN      connection=${connect_admin}
    Sleep      120s      reason=Wait after reset

    Log        Step 2-4: Configure parameters via MantaRay    console=True
    Change Parameter with NMS
	...        MOC_DN=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1    param_name=btsEMMaxSimulSession
	...	       param_value=10    LAB_NAME=${LAB_NMS}
    Sleep      180s      reason=Wait for NMS
	Change Parameter with NMS
	...        MOC_DN=MRBTS-${BTS_ID}/MNL-1/AMGR-1    param_name=btsEMRestrictedAccessLogoutTimer
	...	       param_value=30    LAB_NAME=${LAB_NMS}
    Sleep      180s      reason=Wait for NMS
    Change Parameter with NMS
	...        MOC_DN=MRBTS-${BTS_ID}/MNL-1/AMGR-1    param_name=btsEMRestrictAccSession
	...	       param_value=1    LAB_NAME=${LAB_NMS}
    Sleep      180s      reason=Wait for NMS

    Log         Step 5: Open 8 read-only sessions and 2 read-write sessions   console=True
    Connect to ADMIN Read-Only    number=8    username=${readonly_username}    password=${readonly_password}
    Connect to ADMIN              username=${Nemuadmin}    password=${nemuadmin_password}    timeout=${180}
    ...                           alias=readwrite11
    Run Keyword And Expect Error      *       Connect to ADMIN    username=${Nemuadmin}
    ...                                       password=${nemuadmin_password}    timeout=${180}    alias=readwrite12
    Disconnect from ADMIN Read-Only           number=8
    Run Keyword And Ignore Error              Disconnect from ADMIN    readwrite11

#    Log         Step 6: Open 11 readonly sessions   console=True
#    Connect to ADMIN Read-Only                number=10    username=${readonly_username}    password=${readonly_password}
#    Run Keyword And Expect Error      *       Connect to ADMIN    username=${readonly_username}    password=${readonly_password}
#    ...                                       timeout=${180}    alias=read12
#    Disconnect from ADMIN Read-Only           number=10

    Log         Step 7: Open 9 readonly sessions and 1 read/write session  console=True
    Connect to ADMIN Read-Write               number=1    username=${Nemuadmin}    password=${nemuadmin_password}
    Connect to ADMIN Read-Only                number=9    username=${readonly_username}    password=${readonly_password}
    Disconnect from ADMIN Read-Only           number=9

    Log         Step 8: Configure btsEMRestrictAccSession via MantaRay   console=True
    Change Parameter with NMS
	...         MOC_DN=MRBTS-${BTS_ID}/MNL-1/AMGR-1    param_name=btsEMRestrictAccSession
	...	        param_value=2    LAB_NAME=${LAB_NMS}
    Sleep      300s      reason=Wait for NMS

	Log         Step 9: Verify if all R/W session are closed   console=True
    ${read_conn}=         Connect to ADMIN    username=${readonly_username}    password=${readonly_password}    timeout=${180}
    Wait Until Keyword Succeeds     15m    30s     Check NMS Statuses on BTS     conn=${read_conn}
    Run Keyword And Ignore Error              Disconnect from ADMIN       connection=${read_conn}
    Sleep       120s      reason=Wait for automatic closing the r/w session
	${read_conn}=         Connect to ADMIN    username=${readonly_username}    password=${readonly_password}    timeout=${180}
	${sessions_list}=     Get Username From Sessions List   pre-conn=${read_conn}
    List Should Not Contain Value             ${sessions_list}            BTSSystem
    Run Keyword And Ignore Error              Disconnect from ADMIN       connection=${read_conn}

    Log         Step 10: Close connection to MantaRay  console=True
    Change Parameter with NMS
	...        MOC_DN=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1   param_name=oamTls
	...	       param_value=1    LAB_NAME=${LAB_NMS}
    Sleep      960s       reason=Wait for NMS disconnection

    Log         Step 11: Create one R/W sessions  console=True
    ${read_conn}=         Connect to ADMIN    username=${readonly_username}    password=${readonly_password}    timeout=${180}
	${sessions_list}=     Get Username From Sessions List   pre-conn=${read_conn}
    List Should Not Contain Value             ${sessions_list}      BTSSystem
    Run Keyword And Ignore Error              Disconnect from ADMIN       connection=${read_conn}
    ${adm}=               Connect to ADMIN    username=${Nemuadmin}    password=${nemuadmin_password}    timeout=${180}

    Log         Step 12: Verify the value of btsEMRestrictAccSessionStatus  console=True
    ${parameter_value1}=      Check current parameter value      dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/AMGR_R-1
    ...                       param_name=btsEMRestrictAccSessionStatus     connection=${adm}
    ${string}=                Convert To String      ${parameter_value1}[0]
    Should Be Equal           ${string}              OneRWsessionAllowed

    Log         Step 13: Try to create second R/W sessions  console=True
    Run Keyword And Expect Error     *       Connect to ADMIN    username=${Nemuadmin}     password=${nemuadmin_password}

    Log         Step 14: Restor connection to MantaRay  console=True
    Change Parameter on BTS        dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1    param_name=oamTls
    ...                            param_value=off    connection=${adm}
    Sleep     240s       reason=Wait for NMS connection
#    Log         Step 15: Verify the value of btsEMRestrictAccSessionStatus  console=True
     #Do sprawdzenia czy moze byc readonly connection bo cos nie dziala
#    ${parameter_value2}=      Check current parameter value      param_name=btsEMRestrictAccSessionStatus
#    ...         dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/AMGR_R-1   connection=${read_conn}
#    ${string2}=      Convert To String      ${parameter_value2}
#    Should Be Equal       ${string2}       ['NoRWsessionAllowed']
#    Run Keyword And Ignore Error           Disconnect from ADMIN       connection=${read_conn}

    Log         Step 16: Verify if all R/W session are closed   console=True
    ${read_conn}=         Connect to ADMIN     username=${readonly_username}    password=${readonly_password}    timeout=${180}
    Wait Until Keyword Succeeds     15m    30s     Check NMS Statuses on BTS     conn=${read_conn}
    Run Keyword And Ignore Error               Disconnect from ADMIN       connection=${read_conn}
	${read_conn}=         Connect to ADMIN    username=${readonly_username}    password=${readonly_password}    timeout=${180}
	${sessions_list}=     Get Username From Sessions List    pre-conn=${read_conn}
    List Should Not Contain Value              ${sessions_list}      BTSSystem
    Run Keyword And Ignore Error               Disconnect from ADMIN       connection=${read_conn}

    Log        Step 17: Configure btsEMRestrictAccSession via MantaRay   console=True
    Change Parameter with NMS
	...        MOC_DN=MRBTS-${BTS_ID}/MNL-1/AMGR-1    param_name=btsEMRestrictAccSession
	...	       param_value=1    LAB_NAME=${LAB_NMS}
    Sleep      180s      reason=Wait for NMS

    Log       Step 18: Create one R/W sessions  console=True
    Connect to ADMIN    username=${Nemuadmin}    password=${nemuadmin_password}    timeout=${180}

    Log         Step 19: Configure btsEMRestrictAccSession via MantaRay   console=True
    Change Parameter with NMS
	...        MOC_DN=MRBTS-${BTS_ID}/MNL-1/AMGR-1    param_name=btsEMRestrictAccSession
	...	       param_value=2    LAB_NAME=${LAB_NMS}
    Sleep      240s      reason=Wait for NMS

	Log         Step 20: Close connection to MantaRay  console=True
    Change Parameter with NMS
	...        MOC_DN=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1   param_name=oamTls
	...	       param_value=1    LAB_NAME=${LAB_NMS}
    Sleep      960s       reason=Wait for NMS disconnection

	Log         Step 21: Verify if all R/W session are closed   console=True
    ${read_conn}=         Connect to ADMIN     username=${readonly_username}    password=${readonly_password}    timeout=${180}
	${sessions_list}=     Get Username From Sessions List    pre-conn=${read_conn}
    List Should Not Contain Value              ${sessions_list}      BTSSystem
    Run Keyword And Ignore Error               Disconnect from ADMIN       connection=${read_conn}

    Log         Step 22: Create one R/W sessions  console=True
    ${conn_admin}=        Connect to ADMIN    username=${Nemuadmin}    password=${nemuadmin_password}    timeout=${900}

    Log         Step 23: Configure btsEMRestrictAccSession via WebEM  console=True
    Change Parameter on BTS        dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1    param_name=btsEMRestrictAccSession
    ...                            param_value=OneRWsessionAllowed    connection=${conn_admin}
    ${read_conn}=         Connect to ADMIN     username=${readonly_username}    password=${readonly_password}    timeout=${180}
	${sessions_list}=     Get Username From Sessions List    pre-conn=${read_conn}
    List Should Contain Value                  ${sessions_list}      BTSSystem
    Run Keyword And Ignore Error               Disconnect from ADMIN       connection=${read_conn}

    Log         Step 24: Restor connection to MantaRay  console=True
    Change Parameter on BTS        dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1    param_name=oamTls
    ...                            param_value=off    connection=${conn_admin}
    Sleep     120s       reason=Wait for NMS connection

    Log         Step 25: Verify if R/W session is still connected       console=True
    ${read_conn}=         Connect to ADMIN    username=${readonly_username}    password=${readonly_password}    timeout=${180}
    Wait Until Keyword Succeeds     15m    30s     Check NMS Statuses on BTS     conn=${read_conn}
    Run Keyword And Ignore Error               Disconnect from ADMIN       connection=${read_conn}
	${read_conn}=         Connect to ADMIN    username=${readonly_username}    password=${readonly_password}    timeout=${180}
	${sessions_list}=     Get Username From Sessions List   pre-conn=${read_conn}
    List Should Contain Value                 ${sessions_list}      BTSSystem
    Run Keyword And Ignore Error              Disconnect from ADMIN       connection=${read_conn}

    Log         Step 26: Close connection to MantaRay     console=True
    Change Parameter with NMS
	...        MOC_DN=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1   param_name=oamTls
	...	       param_value=1    LAB_NAME=${LAB_NMS}
    Sleep      960s       reason=Wait for NMS disconnection
	${read_conn}=         Connect to ADMIN    username=${readonly_username}    password=${readonly_password}    timeout=${180}
	${sessions_list}=     Get Username From Sessions List   pre-conn=${read_conn}
    List Should Contain Value                 ${sessions_list}      BTSSystem
    Run Keyword And Ignore Error              Disconnect from ADMIN       connection=${read_conn}

    Log         Step 27: Configure btsEMRestrictAccSession via WebEM       console=True
    Change Parameter on BTS        dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1    param_name=btsEMRestrictAccSession
    ...                            param_value=NoRWsessionAllowed    connection=${conn_admin}

    Log         Step 28: Verify if R/W session is still connected       console=True
	${read_conn}=         Connect to ADMIN    username=${readonly_username}    password=${readonly_password}    timeout=${180}
	${sessions_list}=     Get Username From Sessions List   pre-conn=${read_conn}
    List Should Contain Value                 ${sessions_list}      BTSSystem
    Run Keyword And Ignore Error              Disconnect from ADMIN       connection=${read_conn}

#    Log         Step 29-30: Reset site and check parameter value   console=True
#    ${parameter_value_before_reset}=      Check current parameter value      param_name=btsEMRestrictAccSession
#    ...                                   dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/AMGR_R-1   connection=${conn_admin}
#	Reset Site And Reconnect              connection=${conn_admin}
#    ${parameter_value_after_reset}=       Check current parameter value      param_name=btsEMRestrictAccSession
#    ...                                   dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/AMGR_R-1        connection=${conn_admin}
#    Should Be Equal     ${parameter_value_before_reset}       ${parameter_value_after_reset}
#    Sleep      300s      reason=Wait before integration with MantaRay
    Log         Step 31: Restor connection to MantaRay and Open 11 readonly sessions    console=True
    Change Parameter on BTS        dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1    param_name=oamTls
    ...                            param_value=off    connection=${conn_admin}
    Sleep     120s       reason=Wait for NMS connection

    Connect to ADMIN Read-Only                number=10    username=${readonly_username}    password=${readonly_password}
    Run Keyword And Expect Error      *       Connect to ADMIN    username=${readonly_username}    password=${readonly_password}
    ...                                       timeout=${180}    alias=read12
    Disconnect from ADMIN Read-Only           number=10

#    Log         Step 32: Open 9 readonly sessions and 1 read/write session  console=
#    Run Keyword And Expect Error     *       Connect to ADMIN    username=${Nemuadmin}     password=${nemuadmin_password}
#    Connect to ADMIN Read-Only               number=9    username=${readonly_username}    password=${readonly_password}
#    Disconnect from ADMIN Read-Only          number=9

#    Log         Step 33: Open 10 readonly sessions   console=True
#    Connect to ADMIN Read-Only         number=10    username=${readonly_username}    password=${readonly_password}
#    Disconnect from ADMIN Read-Only    number=10

    Log         Step 34: Configure btsEMRestrictAccSession via MantaRay   console=True
    Change Parameter with NMS
	...         MOC_DN=MRBTS-${BTS_ID}/MNL-1/AMGR-1    param_name=btsEMRestrictAccSession
	...	        param_value=1    LAB_NAME=${LAB_NMS}
    Sleep      180s      reason=Wait for NMS

	Log         Step 35: Open 9 readonly sessions and 1 read/write session  console=True
    ${rw_conn}=         Connect to ADMIN    username=${Nemuadmin}    password=${nemuadmin_password}    timeout=${180}
    Connect to ADMIN Read-Only    number=8    username=${readonly_username}    password=${readonly_password}
    ${read_conn}=         Connect to ADMIN    username=${readonly_username}    password=${readonly_password}    timeout=${180}

    Log         Step 36: Close connection to MantaRay  console=True
    Change Parameter with NMS
	...        MOC_DN=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1   param_name=oamTls
	...	       param_value=1    LAB_NAME=${LAB_NMS}
    Sleep      960s       reason=Wait for NMS disconnection

	Log         Step 37: Verify if R/W session is still connected       console=True
	${sessions_list}=     Get Username From Sessions List    pre-conn=${read_conn}
    List Should Contain Value         ${sessions_list}      BTSSystem

    Log         Step 38: Verify the value of btsEMRestrictAccSessionStatus  console=True
    ${parameter_value}=      Check current parameter value      param_name=btsEMRestrictAccSessionStatus
     ...         dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/AMGR_R-1         connection=${rw_conn}
    ${string}=                               Convert To String      ${parameter_value}
    Should Be Equal                          ${string}       ['OneRWsessionAllowed']
    Run Keyword And Ignore Error             Disconnect from ADMIN       connection=${read_conn}

    Disconnect from ADMIN Read-Only          number=8

    Log         Step 39: Restor connection to MantaRay  console=True
    Change Parameter on BTS        dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1    param_name=oamTls
    ...                            param_value=off    connection=${rw_conn}
    Run Keyword And Ignore Error             Disconnect from ADMIN    connection=${rw_conn}
    Sleep     120s       reason=Wait for NMS connection

    Log         Step 40: Configure btsEMRestrictAccSession via WebEM as Application user  console=True
    ${connection_app}=    Connect to ADMIN    username=${app_user}    password=${app_password}    timeout=${180}

    Run Keyword And Expect Error      *     Change Parameter on BTS        dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                                     param_name=btsEMMaxSimulSession    param_value=8     connection=${connection_app}

    Run Keyword And Ignore Error           Disconnect from ADMIN      connection=${connection_app}

    Log         Step 41: Configure btsEMRestrictAccSession via WebEM as Readonly user  console=True
    ${connection_readonly}=                 Connect to ADMIN    username=${readonly_username}    password=${readonly_password}
    ...                                     timeout=${180}

    Run Keyword And Expect Error      *     Change Parameter on BTS        dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                                     param_name=btsEMMaxSimulSession    param_value=8     connection=${connection_readonly}
    Run Keyword And Ignore Error            Disconnect from ADMIN      connection=${connection_readonly}

    Log         Step 42-44: Configure parameters via MantaRay    console=True
    Change Parameter with NMS
	...        MOC_DN=MRBTS-${BTS_ID}/MNL-1/AMGR-1    param_name=btsEMRestrictAccSession
	...	       param_value=0    LAB_NAME=${LAB_NMS}
    Sleep      180s      reason=Wait for NMS
	Change Parameter with NMS
	...        MOC_DN=MRBTS-${BTS_ID}/MNL-1/AMGR-1    param_name=btsEMRestrictedAccessLogoutTimer
	...	       param_value=120    LAB_NAME=${LAB_NMS}
    Sleep      180s      reason=Wait for NMS

    Connect to ADMIN Read-Write   number=10    username=${Nemuadmin}    password=${nemuadmin_password}

    Run Keyword And Expect Error      *       Connect to ADMIN    username=${Nemuadmin}
    ...                                       password=${nemuadmin_password}    timeout=${180}    alias=read12
    Disconnect from ADMIN Read-Write    number=10

#    Log         Step 46: Open 11 readonly sessions   console=True
#    Connect to ADMIN Read-Only    number=10    username=${readonly_username}    password=${readonly_password}
#    Run Keyword And Expect Error      *       Connect to ADMIN    username=${readonly_username}
#    ...                                        password=${readonly_password}    timeout=${180}    alias=read12
#
#    Disconnect from ADMIN Read-Only     number=10
#
#    Log         Step 47: Open 10 R/W sessions   console=True
#    Connect to ADMIN Read-Write   number=10    username=${Nemuadmin}    password=${nemuadmin_password}
#
#    Log         Step 48: Configure parameters via MantaRay    console=True
#    Change Parameter with NMS
#	...        MOC_DN=MRBTS-${BTS_ID}/MNL-1/AMGR-1    param_name=btsEMRestrictAccSession
#	...	       param_value=1    LAB_NAME=${LAB_NMS}
#
#	Sleep      120s      reason=Wait for sessions termination
#	Log         Step 49: Verify if all r/w session are terminated except one   console=True
#	${read_conn}=         Connect to ADMIN    username=${readonly_username}    password=${readonly_password}    timeout=${180}
#	${sessions_list}=                         Get Username From Sessions List    pre-conn=${read_conn}
#    List Should Contain Value                 ${sessions_list}      BTSSystem
#    Run Keyword And Ignore Error              Disconnect from ADMIN       connection=${read_conn}
#
#    Log         Step 50: Open 8 readonly sessions and 2 read/write session  console=True
#    Connect to ADMIN Read-Only                number=8    username=${readonly_username}    password=${readonly_password}
#    Run Keyword And Expect Error      *       Connect to ADMIN    username=${Nemuadmin}
#    ...                                       password=${nemuadmin_password}    timeout=${180}
#    ...                                       alias=read12
#    Disconnect from ADMIN Read-Only           number=8

    [Teardown]   Run Keywords     Run Keyword and Ignore Error   MantaRay Teardown with Restriction   LAB_NMS=${LAB_NMS}
    ...    AND                    Configuration Reset    new_pass=${nemuadmin_password}   scf_path=${scf_path}
    ...                           new_username=${Nemuadmin}      reset_type=3
