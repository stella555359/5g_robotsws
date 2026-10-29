# Copyright (c) 2020 Nokia. All rights reserved.

*** Settings ***
Documentation  Script for  archive
Library    BuiltIn
Library    Collections
Library    OperatingSystem
Library    taf.transport.ssh  WITH NAME  SSH
Library    String


*** Variables ***
${htmlRedirectionTemplate}=
...    <!DOCTYPE html>
...    <html lang="en">
...      <head>
...        <meta charset="UTF-8">
...        <meta http-equiv="refresh" content="2"; URL="url_redirection_template">
...        <title>automatic redirection to 'SosReport_buildId_template' in 2 secondes</title>
...      </head>
...      <body>
...        The sosReport result is beeing archived on a distant FTP Server, follow the link:
...        <a href="url_redirection_template"> SosReport_buildId_template </a><br/><br/>
...        NOTE: For Bangalore testline the link above will only work once you are authenticated on
...        <a href="https://blrmtplabs.srnblr.nsn-rdnet.net:6082/php/uid.php?vsys=1&rule=0"> BGL firewall</a>
...      </body>
...    </html>

*** Keywords ***
Store In Archive Server
    [Arguments]    ${localPath}    ${file}
    [Documentation]    Send a (huge) file to an archive server, the goal is twofold:
    ...                - spare space on QT jenkins server
    ...                - faster transfer by targetting a local server
    @{files}                            Split String    ${file}
    Multiple Store In Archive Server    ${localPath}    ${files}

Multiple Store In Archive Server
    [Arguments]    ${localPath}    ${files}
    [Documentation]    Send several (huge) files to an archive server, the goal is twofold:
    ...                - spare space on QT jenkins server
    ...                - faster transfer by targetting a local server
    ${ArchiveServerDefined}    Get Variable Value    ${ymlArchiveServer}    ${NONE}
    Log To Console             Is Archive Server defined? ${ArchiveServerDefined}
    Return From Keyword If     ${ArchiveServerDefined} == ${NONE}
    Control Archive Space      host=${ymlArchiveServer}
    FOR    ${file}    IN    @{files}
        Move To Archive Server    ${localPath}    ${file}    host=${ymlArchiveServer}
    END

Move To Archive Server
    [Arguments]    ${localPath}    ${file}    ${host}=${NONE}
    ${buildTag}                  Get Environment Variable    BUILD_TAG
    ${targetDir}                 Catenate    ${host}[ArchivePath]/${buildTag}
    ${commandCreateDir}          Catenate    sshpass -p ${host}[Password] ssh ${host}[Username]@${host}[Ip]
    ...                          mkdir -p ${targetDir}
    ${resultCreateDir}           Run    command=${commandCreateDir}
    ${targetFile}                Catenate    ${targetDir}/${file}
    ${localFile}                 Catenate    ${localPath}/${file}
    Log To Console               archiving ${localFile} to ${targetFile}
    # "Upload File" keyword is not used here below as it's several times slower
    ${scpCommand}                Catenate    sshpass -p ${host}[Password] scp
    ...                          ${localFile}
    ...                          ${host}[Username]@${host}[Ip]:${targetFile}
    Run                          ${scpCommand}
    ${targetFileExists}          Run Keyword and Return Status
    ...                          Assert file exists    ${targetFile}    connection=${host}[Connection]
    Run Keyword if               ${targetFileExists}    Run Keywords
    ...                          Build Redirection File    ${targetDir}    ${localPath}    ${buildTag}
    ...                          host=${host}
    ...                          AND    Remove File    ${localFile}
    ...                          AND    Log To Console    Archiving to ${host}[Ip] completed

Control Archive Space
    [Arguments]    ${host}=${NONE}    ${threshold}=75    ${olderThan}=5
    [Documentation]   Ensure that the archive space exists on the server
    ...               and its size remains under under control
    Create Archive Space      host=${host}
    ${usedSpacePcent}         Get Used Space    host=${host}
    Return From Keyword If    int(${usedSpacePcent}) <= int(${threshold})
    Reclaim Archive Space     host=${host}    olderThan=${olderThan}

Create Archive Space
    [Arguments]    ${host}=${NONE}
    Log To Console    Ensure that ${host}[ArchivePath] exists
    ${command}        Catenate    sshpass -p ${host}[Password] ssh ${host}[Username]@${host}[Ip]
    ...               mkdir -p ${host}[ArchivePath]
    ${result}         Run    command=${command}

Reclaim Archive Space
    [Arguments]    ${host}=${NONE}    ${olderThan}=5
    Log To Console     Removing archived files, older than ${olderThan} days
    ${rmOldFiles}      Catenate    sshpass -p ${host}[Password] ssh ${host}[Username]@${host}[Ip]
    ...                find ${host}[ArchivePath] -type f -ctime +${olderThan} | xargs rm -fv
    Run                ${rmOldFiles}
    ${rmOldDirs}       Catenate    sshpass -p ${host}[Password] ssh ${host}[Username]@${host}[Ip]
    ...                find ${host}[ArchivePath] -type d -ctime +${olderThan} | xargs rm -fvd
    Run                ${rmOldDirs}

Get Used Space
    [Arguments]    ${host}=${NONE}
    Log To Console    Get Used Space
    ${command}        Catenate    sshpass -p ${host}[Password] ssh ${host}[Username]@${host}[Ip]
    ...               df -h --output=pcent /${host}[ArchiveVolume] | tail -1
    ${result}         Run    ${command}
    ${match}          should match regexp    ${result}    \\d+
    Log To Console    used space = ${match} (%)
    [Return]    ${match}

Build Redirection File
    [Arguments]    ${targetPath}    ${localPath}    ${buildTag}    ${host}=${NONE}
    [Documentation]    build the html file which will be loaded in jenkins logs,
    ...                and redirects to the actual sosReport archive directory
    ${htmlUrl}                  Catenate
    ...                         ${host}[LinkProtocol]://${host}[Ip]/${targetPath}
    ${htmlFile}                 Catenate
    ...                         ${localPath}/sosReportArchiveLink.html
    Log To Console              target url: ${htmlUrl}
    Log To Console              link file: ${htmlFile}
    Run                         echo ${htmlRedirectionTemplate} > ${htmlFile}
    Log To Console              Created html link
    Run                         sed -i -e 's/url_redirection_template/${htmlUrl}/' ${htmlFile}
    Log To Console              Adjusted template url to actual one
    Run                         sed -i -e 's/SosReport_buildId_template/SosReport link build ${buildTag}/' ${htmlFile}
    Log To Console              Adjusted template build id to actual one
    Set Environment Variable    sosReportUrl    "${htmlUrl}"
