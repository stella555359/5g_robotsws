*** Settings ***
Documentation
...    author: Agnieszka Bylica
...    contact: agnieszka.bylica@nokia.com
...    Common Robot keywords for Hub.

Library     ${CURDIR}/../python/keywords/Hub_keywords.py

*** Variables ***
${debug_dir}=  ${OUTPUT DIR}/debug/hub1/


*** Keywords ***

Collect Logs From Hub And Save To Local Directory
    ${filename} =    Hub_keywords.Collect Snapshot From Hub
    Hub_keywords.Download Snapshot From Hub    output_dir=${debug_dir}    filename=${filename}
