*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Damian Rzeczkowski
...              :contact: rzeczkowski.damian@gmail.com

*** Variables ***
${LOGGING_POLICY}=    NO_TRAFFIC_LOGS_POLICY
@{UES_LIST}=    1    2    3    4    5    6
@{BEAMS_LIST}=  1    2    3    4    5    6
@{BIP_columns}=
...                  UlData_detectedPrachPreambles_t.prachPreambleIndex

*** Keywords ***
Register 6 UEs
    ute_wtssim.execute_egate_command    cmd=ue_register id=1-6
    Sleep    5

Deregister 6 UEs
    FOR    ${first_ue_id_index}    IN    @{UES_LIST}
        ute_wtssim.execute_egate_command    cmd=ue_deregister id=${first_ue_id_index}
    END

Verify If All 6 UEs Are Active
    ute_wtssim.execute_egate_command    cmd=ue_disp id=1-6    pass_regexp=ACTIVE

gNB Detect All 6 Preambles In Single RO Dedicated
    ${result}=    verify_rach_occasion_with_6_different_preambles    file_path=${OUTPUT_DIR}/BIP_LOGS/BIP_logs.csv
    Should Be True    ${result}

