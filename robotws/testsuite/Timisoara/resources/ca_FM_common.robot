*** Settings ***
Documentation  This resource contains all common keywords from CBTS and SBTS FM CA.

Library  SSHLibrary


*** Keywords ***
Get POOR Reset Counter From RMOD /var/log/BBOX5 File
    [Documentation]  This keyword is used to retrieve POOR Reset Counter value from RMOD.
    ...  Connection to Radio Modules is opened beforehand, for SBTS or CBTS.
    ...  "Unzip BBOX5.zip file on RMOD" keyword is used.
    [Arguments]  ${rmod_sn}

    Unzip BBOX5.zip file on RMOD  ${rmod_sn}
    SSHLibrary.Write  cat BBOX5 | grep POOR
    ${file_output}  SSHLibrary.Read Until Prompt
    ${lines}  Get Regexp Matches  ${file_output}  \nPOOR Reset Counter:.*[0-9]+
    ${counter_value}  Fetch From Right  ${lines}[0]  ${SPACE}
    Should Not Be Empty  ${counter_value}  msg=POOR Counter not found in /var/log location on RMOD with serial_number: ${rmod_sn}.

    RETURN  ${counter_value}


Verify The List Of Operations From RMOD /var/volatile/log/BBOX5 File
    [Documentation]  This keyword is used to verify Operations on RMOD(Reset Reason and Reset Cause).
    ...  Connection to Radio Modules is opened beforehand, for SBTS or CBTS.
    ...  "Unzip BBOX5.zip file on RMOD" keyword is used.
    [Arguments]  ${rmod_sn}  ${reset_reason}  ${reset_cause}  ${failed_service}=${EMPTY}

    # Date verification is skipped for now - not required at this stage.
    # ${current_date}  Get Current Date   time_zone=UTC
    # ${current_date}  Fetch From Left  ${current_date}  ${SPACE}

    Unzip BBOX5.zip file on RMOD  ${rmod_sn}
    SSHLibrary.Write  cat BBOX5 | grep -A 4 'Reset\\[0\\] Write:.*'
    ${file_output}  SSHLibrary.Read Until Prompt
    # ${date_line}  Get Lines Containing String  ${file_output}  Write
    # ${date_value}  Fetch From Left  ${date_line}  T
    # ${date_value}  Fetch From Right  ${date_value}  ${SPACE}
    # Should Be Equal As Strings  ${date_value}  ${current_date}  msg=Date is not correct for RMOD with serial number: ${rmod_sn}.
    ${reason_line}  Get Lines Containing String  ${file_output}  Reset Reason
    ${cause_line}  Get Lines Containing String  ${file_output}  Reset Cause
    Should Contain  ${reason_line}  ${reset_reason}  msg=Reset Reason is not ok for RMOD with serial number: ${rmod_sn}.
    Should Contain  ${cause_line}  ${reset_cause}  msg=Reset Cause is not ok for RMOD with serial number: ${rmod_sn}.
    IF  '${failed_service}' != '${EMPTY}'
        ${failed_service_line}  Get Lines Containing String  ${file_output}  Failed Service
        Should Contain  ${failed_service_line}  ${failed_service}  msg=Failed service is not ok for RMOD with serial number: ${rmod_sn}.
    END
    Log  Reset Reason and Cause are correct for RMOD with serial number: ${rmod_sn}. [OK]  console=true


Unzip BBOX5.zip file on RMOD
    [Documentation]  This keyword is used to unzip BBOX5.zip file on RMOD.
    ...  Connection to Radio Modules is opened beforehand, for SBTS or CBTS.
    [Arguments]  ${rmod_sn}

    SSHLibrary.Write  cd /var/log
    SSHLibrary.Set Client Configuration  prompt=REGEXP:(#|\\$)
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  ls
    ${ls_output}  SSHLibrary.Read Until Prompt
    Should Contain  ${ls_output}  BBOX5.zip  msg=BBOX5.zip not found in /var/log location on RMOD with serial_number: ${rmod_sn}.
    ${bbox5_matches}  Get Regexp Matches  ${ls_output}  BBOX5(?!\.zip)
    ${bbox5_exists}  Run Keyword And Return Status  Should Not Be Empty  ${bbox5_matches}
    IF  ${bbox5_exists}
        SSHLibrary.Write  rm BBOX5
        SSHLibrary.Set Client Configuration  prompt=?
        ${confirm_appeared}  Run Keyword And Return Status  SSHLibrary.Read Until Prompt
        SSHLibrary.Set Client Configuration  prompt=REGEXP:(#|\\$)
        IF  ${confirm_appeared}
            SSHLibrary.Write  yes
            SSHLibrary.Read Until Prompt
        END
    END
    SSHLibrary.Write  unzip BBOX5.zip
    SSHLibrary.Read Until Prompt