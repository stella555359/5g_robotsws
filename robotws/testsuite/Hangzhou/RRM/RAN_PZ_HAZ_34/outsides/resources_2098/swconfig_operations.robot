*** Settings ***
Library    taf.rfrl.common_resources.python.SWConfig
Library    ./swconfig_operations.py
Resource   ../resources_570/connections.robot


*** Variables ***
${asik alias}              ASIK
${swconfig backup}         ${OUTPUT DIR}/swconfig_backup.txt
${swconfig working copy}   ${OUTPUT DIR}/swconfig.txt
@{MANDATORY_BTS_FLAGS}     0x1003F=1   0x10040=1   0x10041=1   0x420000=1

*** Keywords ***
Prepare TL with swconfig
    [Arguments]   @{custom_sw_flags}
    Preprate TL with swconfig   @{custom_sw_flags}


Preprate TL with swconfig
    [Arguments]   @{custom_sw_flags}
    Get swconfig file from ASIK
    @{flags}=    Create list   @{custom_sw_flags}   0x1003F=1   0x10040=1   0x10041=1   0x420000=1
    ${is_mod_needed}=    Is swconfig modification needed    ${swconfig working copy}    ${flags}
    Run keyword if   '${is_mod_needed}' == 'True'
    ...              Run keywords
    ...              Modify parameter in swconfig file  @{flags}    AND
    ...              Upload swconfig file to ASIK                   AND
    ...              wait until keyword succeeds  3x  500ms  Trigger Reset and wait    AND
    ...              Log    SWCONFIG HAS BEEN MODIFIED!!!    console=True


Prepare TL with swconfig without BTS restart
    [Arguments]  @{custom_sw_flags}
    Get swconfig file from ASIK
    @{flags}=    Create list   @{custom_sw_flags}   @{MANDATORY_BTS_FLAGS}
    ${is_mod_needed}=    Is swconfig modification needed    ${swconfig working copy}    ${flags}
    Run keyword if   '${is_mod_needed}' == 'True'
    ...              Run keywords
    ...              Modify parameter in swconfig file  @{flags}    AND
    ...              Upload swconfig file to ASIK                   AND
    ...              Log    SWCONFIG HAS BEEN MODIFIED!!!    console=True


Prepare and upload swconfig
    [Arguments]   @{custom_sw_flags}
    Get swconfig file from ASIK
    @{flags}=    Create list   @{custom_sw_flags}
    ${is_mod_needed}=    Is swconfig modification needed    ${swconfig working copy}    ${flags}
    Run keyword if   '${is_mod_needed}' == 'True'
    ...              Run keywords
    ...              Modify parameter in swconfig file  @{flags}    AND
    ...              Upload swconfig file to ASIK                   AND
    ...              wait until keyword succeeds  3x  500ms  Trigger Reset and wait    AND
    ...              Log    SWCONFIG HAS BEEN MODIFIED!!!    console=True


Trigger Reset and wait
    Trigger Site Reset and wait for availability
    Wait for all cells on air state


Get swconfig file from ASIK
    Connect to ASIK   ${asik alias}
    Download swconfig file from asik to test pc   localFilePath=${swconfig working copy}   asik_alias=${asik alias}
    Download swconfig file from asik to test pc   localFilePath=${swconfig backup}         asik_alias=${asik alias}
    ssh.Disconnect    connection=${asik alias}


Modify parameter in swconfig file
    [Documentation]   This keyword is to modify the parameter in swconfig.txt on ASIK.
    [Arguments]   @{modified content}
    Modify swconfig file   parametersList=@{modified content}   filePath=${swconfig working copy}


Upload swconfig file to ASIK
    Connect to ASIK   ${asik alias}
    Upload swconfig file to asik and crasign      localFilePath=${swconfig working copy}   asik_alias=${asik alias}
    ssh.Disconnect    connection=${asik alias}


Upload original swconfig file to ASIK
    Connect to ASIK   ${asik alias}
    Upload swconfig file to asik and crasign      localFilePath=${swconfig backup}         asik_alias=${asik alias}
    ssh.Disconnect    connection=${asik alias}
