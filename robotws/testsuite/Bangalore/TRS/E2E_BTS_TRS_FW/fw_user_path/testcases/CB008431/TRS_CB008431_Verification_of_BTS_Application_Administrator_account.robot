*** Settings ***
Documentation
...     [Author]                    "SHREYA CHOUDHARY"
...     [Maintenance]               "TRS I&V Tools Bangalore Team"
...     [Date]                      "28:11:2022"
...     [QC_Path]                   "QC_Path in Test Plan"
...     [QC_ID]                     "QC_ID in Test Lab for reporting"
...     [Feature_ID]                "CB008431"
...     [Validated_TestLine]        "IAV_BLR_TL074"
...     [Procedure]                 "CB008431_VerificationOfCommands_Using_SystemAdministrator_User"
...     [Precondition]              "ASIL + ABIA hardware is required"
...     [Config]                    "Application Administrator User account should be created"
...     [Function_Hash_Tags]        "User Accounts System Admin System Security"

Variables         ta_e2e_bts_trs_fw
Resource        ${CURDIR}/resources/CB008431_common_keywords.robot
Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource        ${CURDIR}/../resources/common_keywords.robot

Suite Setup	    Run Keywords     Setup Oamops        bts_username=${ApplicationUsername}      bts_password=${ApplicationPassword}      bts_port=443
...    AND     Start Syslog     log_dir=${EXECDIR}/execution_logs       log_name=background_syslog.txt   file_limit=50000000     alias=collect_syslog
Suite Teardown    Run Keywords      Teardown Oamops
...    AND     Stop Syslog       alias=collect_syslog

*** Test Cases ***

[1.0]TRS_CB008431_Verification_of_BTS_Application_Administrator_account
    Run Keyword And Expect Error     ${DeniedAccess}         Certificate restore verification      ${Applicationalias}

    Active Alarms         ${Applicationalias}

    Run Keyword And Expect Error     ${DeniedAccess}         Certificate Automatic Management
    ...   ${Applicationalias}      ${ref_number}      ${presharedkey}

     SW Rollback Verification            ${Applicationalias}

     Snapshot Verification   ${Applicationalias}

     Synchronization Information        ${Applicationalias}

     Recommissioning Verification      ${Applicationalias}      ${delta_file}

     Mirroring Logs Verification        ${Applicationalias}

     Get User Login Details       ${Applicationalias}

     Nms State Verification       ${Applicationalias}

     Site Block        ${Applicationalias}

     Site Unblock      ${Applicationalias}
