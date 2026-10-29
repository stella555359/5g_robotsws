*** Settings ***
Documentation
...     [Author]                    "SHREYA CHOUDHARY"
...     [Maintenance]               "TRS I&V Tools Bangalore Team"
...     [Date]                      "28:11:2022"
...     [QC_Path]                   "QC_Path in Test Plan"
...     [QC_ID]                     "QC_ID in Test Lab for reporting"
...     [Feature_ID]                "CB008431"
...     [Validated_TestLine]        "IAV_BLR_TL074"
...     [Procedure]                 "CB008431_VerificationOfCommands_Using_ReadOnlyUser"
...     [Precondition]              "ASIL + ABIA hardware is required"
...     [Config]                    "Read Only User account should be created"
...     [Function_Hash_Tags]        "User Accounts System Admin System Security"


Variables         ta_e2e_bts_trs_fw
Resource        ${CURDIR}/resources/CB008431_common_keywords.robot
Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource        ${CURDIR}/../resources/common_keywords.robot

Suite Setup	        Run Keywords    Setup Oamops       bts_username=${ReadUsername}       bts_password=${ReadPassword}       bts_port=443
...    AND     Start Syslog     log_dir=${EXECDIR}/execution_logs       log_name=background_syslog.txt   file_limit=50000000     alias=collect_syslog
Suite Teardown    Run Keywords      Teardown Oamops
...    AND     Stop Syslog       alias=collect_syslog


*** Test Cases ***

[1.0]TRS_CB008431_Verification_of_BTS_Read_only_account
    Run Keyword And Expect Error     ${DeniedAccess}     Certificate restore verification     ${ReadOnlyUser}

    Run Keyword And Expect Error     ${DeniedAccess}     Certificate deletion verification     ${ReadOnlyUser}

    Run Keyword And Expect Error     ${DeniedAccess}     Get Certificate List     ${ReadOnlyUser}

    Run Keyword And Expect Error     ${DeniedAccess}     Reset Configuration     ${ReadOnlyUser}

    Run Keyword And Expect Error     ${DeniedAccess}     Certificate Automatic Management     ${ReadOnlyUser}
    ...     ${ref_number}     ${presharedkey}

     Run Keyword And Expect Error     ${DeniedAccessPermission}     Reset RAT     ${ReadOnlyUser}

     Run Keyword And Expect Error     ${DeniedAccessPermission}     Snapshot Verification     ${ReadOnlyUser}

     Synchronization Information     ${ReadOnlyUser}

     Run Keyword And Expect Error     ${DeniedAccess}     Commissioning Verification     ${ReadOnlyUser}     ${scf_file}

     Run Keyword And Expect Error     ${DeniedAccess}
     ...     Recommissioning Verification     ${ReadOnlyUser}     ${delta_file}

     Run Keyword And Expect Error     ${DeniedAccessPermission}
     ...     Mirroring Logs Verification     ${ReadOnlyUser}

     Get User Login Details     ${ReadOnlyUser}

     Nms State Verification     ${ReadOnlyUser}

     Run Keyword And Expect Error     ${DeniedAccessPermission}     Site Block     ${ReadOnlyUser}

     Run Keyword And Expect Error     ${DeniedAccessPermission}     Site Unblock     ${ReadOnlyUser}
