*** Settings ***
Documentation
...  Author: Filip Hein
...  Contact: filip.hein@nokia.com
...  Alternative contact: trsautowro@groups.nokia.com

Library     OperatingSystem
Library     DateTime
Library     coam_bts_operations.py
Resource    coam_connections_TRS_resource.robot

*** Keywords ***
Gather logs in setup cOAM
    ${date}=  DateTime.Get Current Date
    Set Global Variable  ${global_date}  ${date}
    Set Global Variable  ${logs_path}    ${OUTPUT DIR}/${SUITE_NAME}_${date[0:10]}/${date[11:19]}
    log to console  LOGS WILL BE GATHERED TO: ${logs_path}
    Run  mkdir -p ${logs_path}
    Collect swconfig from BTS  init_config.xml
    Collect snapshot from BTS  init_snapshot.zip

Gather logs in teardown cOAM
    Run keyword and ignore error  Collect snapshot from BTS  teardown_snapshot.zip
    Run keyword and ignore error  Collect swconfig from BTS  teardown_config.xml
#    Run keyword and continue on failure  Collect SCF from BTS       teardown_scf.xml

Start syslog
    Connect to cOAM as toor4nsn
    ssh.send command   command=journalctl -f > sys.log
    ...                connection=cOAM_toor4nsn
    [Teardown]  ssh.disconnect  connection=cOAM_toor4nsn

Collect syslog
    [Arguments]  ${filename}
    Connect to cOAM as toor4nsn
    ssh.download file  remote_path=sys.log
    ...                local_path=${logs_path}/${filename}
    ...                connection=cOAM_toor4nsn
    [Teardown]  Run keywords
    ...         ssh.execute  command=rm sys.log
    ...                      connection=cOAM_toor4nsn
    ...         AND
    ...         ssh.Disconnect  connection=cOAM_toor4nsn

Collect snapshot from BTS
    [Arguments]  ${filename}
    ${connection}=  Connect to admin TRS keyword
    get_snapshot_file   location=${logs_path}/${filename}
    ...                 coverage=Full
    ...                 timeout=1200
    ...                 connection=${connection}
    [Teardown]  Disconnect from admin

Collect swconfig from BTS
    [Arguments]  ${filename}
    Connect to cOAM as toor4nsn
    ssh.download file  remote_path=/ffs/run/swconfig.txt
    ...                local_path=${logs_path}/${filename}
    ...                connection=cOAM_toor4nsn
    [Teardown]  ssh.disconnect  connection=cOAM_toor4nsn

Collect SCF from BTS
    [Arguments]  ${filename}
    ${connection}=  Connect to admin TRS keyword
    coam_bts_operations.get_current_scf_file  ${connection}
    ...                                       filename=${logs_path}/${filename}
    [Teardown]  Disconnect from admin
