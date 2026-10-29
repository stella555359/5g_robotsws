*** Settings ***
Library   taf.transport.ssh   WITH NAME   ssh
Library   logcat_utility.py

*** Keywords ***
Verify UE 5G status
    ${uepc_alias}=  Connect to UEPC
    ssh.Execute             command=adb logcat -b main -d > /home/wro5grrm/5Gstatus.log
    ...                     connection=${uepc_alias}
    ssh.Download_File       remote_path=/home/wro5grrm/5Gstatus.log
    ...                     local_path=${LOG_PATH}/5Gstatus.log
    ...                     connection=${uepc_alias}
    check logcat attach     ${LOG_PATH}/5Gstatus.log
