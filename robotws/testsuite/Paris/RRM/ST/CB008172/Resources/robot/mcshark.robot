*** Settings ***
Documentation
...                Download of MCShark plugin

Library         ../../../resources/scf_parameters.py
Library         OperatingSystem
Library         Process
Library         ${CURDIR}/remote_load_url.py      WITH NAME    rload
Library         Collections
Library         String


*** Keywords ***
Check MCShark Version
    [Documentation]    Format version:
    ...                5G21A_11.800.1548
    ...                SBTS00_ENB_9999_210915_000001
    [Arguments]    ${sw_version}=${SW_VERSION_TOTAL}

    ${list_version}=    Split String    ${sw_version}    _
    ${nb_item}=    Get length    ${list_version}
    ${new_version}=    Set variable if
    ...    ${nb_item} == 5    SBTS00_${list_version}[1]_${list_version}[2]_${list_version}[3]_${list_version}[4]
    ...    ${sw_version}
    #${rest}    ${last}=    Split String From Right    ${sw_version}    _    1
    #${new_version}=    Set Variable If    "${list_version}[0]"!="SBTS00" and "${list_version}[-1]"!="000000"
    #...    ${rest}_000000      ${sw_version}
    [Return]    ${new_version}


Get Tshark Version
    ${version}=    Run    tshark -v|grep TShark|grep -P v[0-9]+.[0-9]+ -o|cut -d "v" -f 2
    [Return]    ${version}


Download MCShark To UTE
    [Documentation]
    ...     08/10/21 - SCRO:
    ...     Remove keyword "Check MCShark Version" (useless?)
    ...     MCShark Plugin name for SBTS22R2 starts with SBTS00
    ...     Remove variable tashark_version from MCShark Plugin name
    [Arguments]    ${sw_version}=${SW_VERSION_TOTAL}
    #${sw_version}=    Check MCShark Version    ${sw_version}
    ${sw_version}=   Replace String   ${sw_version}    SBTS22R2    SBTS00
    ${cmd}=    Set Variable    wget -r -l0 --no-parent https://artifactory-hz1.int.net.nokia.com/artifactory/mcshark-local/${sw_version}/
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    ${cmd}
    Should Be True    "${rc}"=="0"    There is no MCShark downloaded! Please contact MCshark team!

    #${tashark_version}=    Get Tshark Version
    ${MCShark}=    OperatingSystem.Run
    ...    ls -1t ${EXECDIR}/artifactory-hz1.int.net.nokia.com/artifactory/mcshark-local/${sw_version}/mcshark-*buster.so
    ${MCShark_list}=    String.Split To Lines    ${MCShark}
    ${MCShark_newest}=    Set Variable    @{MCShark_list}[0]

    OperatingSystem.Run    sudo rm -f /usr/lib/x86_64-linux-gnu/wireshark/plugins/3.4/epan/mcshark-*buster.so
    ${rc}=    OperatingSystem.Run And Return Rc    sudo cp ${MCShark_newest} /usr/lib/x86_64-linux-gnu/wireshark/plugins/3.4/epan/
    Should Be True    "${rc}"=="0"    No MCSHark file is copied to the wireshark plugin folder

