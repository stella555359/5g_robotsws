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
...     [Config]                    "Security Administrator User account should be created"
...     [Function_Hash_Tags]        "User Accounts System Admin System Security"


Variables         ta_e2e_bts_trs_fw
Resource        ${CURDIR}/resources/CB008431_common_keywords.robot
Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource        ${CURDIR}/../resources/common_keywords.robot

Suite Setup	    Run Keywords    Setup Oamops      bts_username=${SecurityUser}      bts_password=${SecurityPassword}      bts_port=443
...    AND     Start Syslog     log_dir=${EXECDIR}/execution_logs       log_name=background_syslog.txt   file_limit=50000000     alias=collect_syslog
Suite Teardown    Run Keywords      Teardown Oamops
...    AND     Stop Syslog       alias=collect_syslog

*** Test Cases ***
[1.0] TRS_CB008431_Verification_of_BTS_Security_Administrator_account
    Run Keyword And Expect Error     ${DeniedAccess}         Reset Configuration      ${Securityuser}

    Certificate Automatic Management       ${Securityuser}      ${ref_number}      ${presharedkey}

     Reset RAT      ${Securityuser}

     Snapshot Verification   ${Securityuser}

     Synchronization Information        ${Securityuser}

     Recommissioning Verification      ${Securityuser}      ${delta_file}

     Mirroring Logs Verification        ${Securityuser}

     Get User Login Details       ${Securityuser}

     Nms State Verification       ${Securityuser}

     Run Keyword And Expect Error     ${DeniedAccessPermission}     Site Block        ${Securityuser}

     Run Keyword And Expect Error     ${DeniedAccessPermission}     Site Unblock      ${Securityuser}
