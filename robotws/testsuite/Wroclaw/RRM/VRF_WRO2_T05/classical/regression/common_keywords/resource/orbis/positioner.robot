*** Settings ***
Documentation
...  author: Karol Palac
...  contact: karol.palac@nokia.com
...  Description: This is a library for controlling Orbis positioner using its REST API.
...  It is used to control azimuth and tilting angles of the positioner. In order to use this library,
...  Orbis.py and orbis.robot are sent to remote pc.

*** Variables ***
${positioner_script}=       testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/resource/orbis/orbis.robot
${positioner_functions}=    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/resource/orbis/Orbis.py


*** Keywords ***
Prepare Orbis files
    [Documentation]  This keyword is used to prepare Orbis files for remote pc.
    ${uepcip}=    Get UEPC IP address
    ${tl_name}    Get TL hostname
    Wait Until Keyword Succeeds    10 s    5 s
    ...                            robssh.Open Connection      ${uepcip}
    ...                            escape_ansi=True            newline=CRLF
    ...                            alias=uepc
    robssh.Login  username=${labpcname}    password=${labpcpass}
    robssh.execute_command  command=rm -r -v c:/robot_script_positioner_${tl_name}
    sleep  3s
    robssh.execute_command  command=mkdir c:/robot_script_positioner_${tl_name}/
    Run   sshpass -p '${labpcpass}' scp ${positioner_script} ${labpcname}@${uepcip}:C:/robot_script_positioner_${tl_name}/
    Run   sshpass -p '${labpcpass}' scp ${positioner_functions} ${labpcname}@${uepcip}:C:/robot_script_positioner_${tl_name}
    [Teardown]  robssh.Close Connection

Set positioner
    [Documentation]  This keyword is used to set positioner to given azimuth and tilting angles with given speed to
    ...              corresponding axis. It uses robot script that is sent to uepc with `Prepare Orbis files` keyword.
    [Arguments]  ${azimuth}  ${tilt}  ${azimuth_speed}=3  ${tilt_speed}=3  ${address}=http://10.45.172.210  ${port}=5000
    ${uepcip}=    Get UEPC IP address
    ${tl_name}    Get TL hostname
    Wait Until Keyword Succeeds    10 s    5 s
    ...                            robssh.Open Connection      ${uepcip}
    ...                            escape_ansi=True            newline=CRLF
    ...                            alias=uepc
    robssh.Login  username=${labpcname}    password=${labpcpass}
    ${command}=    Catenate
    ...    robot -v azimuth_angle:${azimuth}
    ...           -v tilting_angle:${tilt}
    ...           -v azimuth_speed:${azimuth_speed}
    ...           -v tilting_speed:${tilt_speed}
    ...           -v positioner_address:${address}
    ...           -v positioner_api_port:${port}
    ...           c:/robot_script_positioner_${tl_name}/orbis.robot
    Log           \n"Set positioner" keyword execution:\n${command}     level=TRACE    console=TRUE
    ${output}=    robssh.execute_command    command=${command}
    Log           ${output}    console=TRUE
