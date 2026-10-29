*** Settings ***
Documentation    Wrappers for common shell operations.

Library    Process
Library    taf.transport.ssh    WITH NAME    ssh
Library    ./remote.py


*** Keywords ***
Run On Localhost
    [Arguments]    ${command}
    [Documentation]    Execute given ``command`` on the local machine.
    ...
    ...    A wrapper for `Run Process` to return commands output, and *Fail* test if command finishes with exit code other that 0.
    ${result}=    Process.Run Process    ${command}    shell=${True}
    Log Many    Output: ${result.stdout}    Error output: ${result.stderr}    Last command's exit code: ${result.rc}
    Run Keyword If    ${result.rc} != 0
    ...    Fail    Command `${command}` failed with STDERR: ${result.stderr}
    [Return]    ${result.stdout}

Run On Remote Host
    [Arguments]    ${command}    ${host}    ${user}    ${passwd}
    [Documentation]    Execute given ``command`` on the remote machine.
    ...
    ...    Fails test if command finishes with exit code other than 0.
    ${connection}=    ssh.Connect To    hostname=${host}    username=${user}    password=${passwd}
    ${output}=    remote.Remote Run    ${command}    ${connection}
    [Teardown]    ssh.Disconnect    connection=${connection}
    [Return]    ${output}

Run On Smod
    [Arguments]    ${command}
    [Documentation]    Bootstrap connection to the system module and execute given ``command``.
    ...
    ...    Fails test if command finishes with exit code other than 0.
    ${smod_connection}=    ssh.Connect To    hostname=192.168.255.129    username=toor4nsn    password=oZPS0POrRieRtu
    ${output}=    remote.Remote Run    ${command}    ${smod_connection}
    [Teardown]    ssh.Disconnect    connection=${smod_connection}
    [Return]    ${output}

Run On Iphy
    [Arguments]    ${command}
    [Documentation]    Bootstrap connection to the IPHY and execute given ``command``.
    ...
    ...    Fails test if command finishes with exit code other than 0.
    ${iphy_connection}=    ssh.Connect To    hostname=192.168.200.129    username=toor4nsn    password=oZPS0POrRieRtu
    ${output}=    remote.Remote Run    ${command}    ${iphy_connection}
    [Teardown]    ssh.Disconnect    connection=${iphy_connection}
    [Return]    ${output}

Put On Remote Host
    [Arguments]    ${source}    ${destination}    ${host}    ${user}    ${passwd}
    [Documentation]    Copy a file from the local machine to a location on the remote machine.
    ...
    ...    ``destination`` is a remote absolute path where the ``source`` should be copied to.
    ...
    ...    If ``destination`` is a non-exisiting path and it ends with "/", ``destination`` is created.
    ...
    ...    If ``destination`` is a file, the parent directory of ``destination`` is not created and keyword fails if it does not already exist.
    ...
    ...    Returns resulting remote path.
    ${connection}=    ssh.Connect To    hostname=${host}    username=${user}    password=${passwd}
    ${output}=    remote.Put   ${source}    ${destination}    ${connection}
    [Teardown]    ssh.Disconnect    connection=${connection}
    [Return]    ${output}

Put On Smod
    [Arguments]    ${source}    ${destination}
    [Documentation]    Copy a file from the local machine to a location on the system module.
    ...
    ...    See `Put On Remote Host` for an explanation how ``source`` and ``destination``  are being interpreted.
    ${smod_connection}=    ssh.Connect To    hostname=192.168.255.129    username=toor4nsn    password=oZPS0POrRieRtu
    ${output}=    remote.Put   ${source}    ${destination}    ${smod_connection}
    [Teardown]    ssh.Disconnect    connection=${smod_connection}
    [Return]    ${output}

Put On Iphy
    [Arguments]    ${source}    ${destination}
    [Documentation]    Copy a file from the local machine to a location on the IPHY.
    ...
    ...    See `Put On Remote Host` for an explanation how ``source`` and ``destination``  are being interpreted.
    ${iphy_connection}=    ssh.Connect To    hostname=192.168.200.129    username=toor4nsn    password=oZPS0POrRieRtu
    ${output}=    remote.Put   ${source}    ${destination}    ${iphy_connection}
    [Teardown]    ssh.Disconnect    connection=${iphy_connection}
    [Return]    ${output}

Fetch From Remote Host
    [Arguments]    ${source}    ${destination}    ${host}    ${user}    ${passwd}
    [Documentation]    Fetch a file from the remote machine and store it locally.
    ...
    ...    ``destination`` is a local absolute path where the ``source`` should be saved into.
    ...
    ...    If ``destination`` is a non-exisiting path and it ends with "/", ``destination`` is created.
    ...
    ...    If ``destination`` is a file, the parent directory of ``destination`` is not created and keyword fails if it does not already exist.
    ...
    ...    Returns resulting local path.
    ${connection}=    ssh.Connect To    hostname=${host}    username=${user}    password=${passwd}
    ${output}=    remote.fetch   ${source}    ${destination}    ${connection}
    [Teardown]    ssh.Disconnect    connection=${connection}
    [Return]    ${output}

Fetch From Smod
    [Arguments]    ${source}    ${destination}
    [Documentation]    Fetch a file from the system module and store it locally.
    ...
    ...    See `Fetch From Remote Host` for an explanation how ``source`` and ``destination``  are being interpreted.
    ${smod_connection}=    ssh.Connect To    hostname=192.168.255.129    username=toor4nsn    password=oZPS0POrRieRtu
    ${output}=    remote.fetch   ${source}    ${destination}    ${smod_connection}
    [Teardown]    ssh.Disconnect    connection=${smod_connection}
    [Return]    ${output}

Fetch From Iphy
    [Arguments]    ${source}    ${destination}
    [Documentation]    Fetch a file from the IPHY and store it locally.
    ...
    ...    See `Fetch From Remote Host` for an explanation how ``source`` and ``destination``  are being interpreted.
    ${iphy_connection}=    ssh.Connect To    hostname=192.168.200.129    username=toor4nsn    password=oZPS0POrRieRtu
    ${output}=    remote.fetch   ${source}    ${destination}    ${iphy_connection}
    [Teardown]    ssh.Disconnect    connection=${iphy_connection}
    [Return]    ${output}
