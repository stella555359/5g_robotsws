*** Settings ***
Documentation
...  author: Jakub Kupiec, Marcin Szlapa
...  contact: jakub.kupiec@nokia.com, marcin.szlapa@nokia.com

Resource  testsuite/Krakow/TRS/features/FR5GC001250_JA_5GC000269/resources/Keywords.robot
Library   testsuite/Krakow/resources/RAN_PZ_KRK4/linux_hardening/check_SUID_SGID.py   WITH NAME   ID

*** Keywords ***
DU_Crypto_Agent_certificates_protected
    ${perms}=   ssh.execute    command=ls -la /ffs/run/etc      connection=BB1
    run keyword and continue on failure
    ...  check_if_private_perms_assured_by_cryptoagent   ${perms}
    ${perms}=   ssh.execute    command=ls -la /ffs/run/etc/cryptoagent      connection=BB1
    run keyword and continue on failure
    ...  check_if_private_perms_list       ${perms}
    ${perms}=   ssh.execute    command=ls -la /ffs/run/etc/keys.d      connection=BB1
    run keyword and continue on failure
    ...  check_if_private_perms_list       ${perms}

DU_Crypto_Agent_Private_Keys
    ${perms}=   ssh.execute    command=ls -la /ffs/run/etc/keys.d/private      connection=BB1
    check_if_private_perms_list     ${perms}
    check_if_private_perms_list     ${perms}

DU_Crypto_Agent_Private_Keys_B
    ${perms}=   ssh.execute    command=ls -la /etc/keys.d/board      connection=BB1
    check_if_private_perms_list     ${perms}

[1]TRSSEC_5GC000269_PLATFORM_Execution_Environment
    Find BTSSW Process on BB1

DU_File_Permission_Rules
    Check file permissions BB1

DU_Process_user_accounts
    Check all processes on BB1

DU_System_Executables_SUID_SGID
    ID.check system executables SUID SGID  BB1

DU_Temporary_accounts
    Check Temporary accounts on  BB1
