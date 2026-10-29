*** Settings ***
Documentation    :copyright    : Nokia
                 ...              :author       : Vadivelan Manickavasagam
                 ...              :contact      : vadivlean.manickavasagam@nokia.com
                 ...              :Description  : Contains Keyword needed for CB008235-A
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,11.01.2025,vadivelan.manickavasagam@nokia.com
Library    BuiltIn
Library    String
Library    Collections
Library    OperatingSystem
Resource    ../Variables/L3_variables.robot
Resource    ../../../../resources/Keywords/general_common_keywords.robot

*** Keywords ***
L3 Suite Setup
     Log to console      "suite setup"

L3 Suite Teardown
     Log to console      "suite teardown"

UE Register and PDU Session
     Exe egate cmd      cmd=${CM_UE1_DTYPE_INTERNAL}      return_output=False
     Exe egate cmd      cmd=${CM_UE_1_REGISTER}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_1_PDU_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

UE Register and PDU Session for Multiple UEs with Range
    [Arguments]    ${start_cell}    ${end_cell}
    FOR    ${cell}    IN RANGE    ${start_cell}    ${end_cell}+1
        Log To Console    ---- Executing for CellIndex-${cell} ----

        ${dtype_cmd}=    Replace String    ${CM_UE1_DTYPE_INTERNAL}    ue=1    ue=${cell}
        ${reg_cmd}=      Replace String    ${CM_UE_1_REGISTER}          id=1    id=${cell}
        ${pdu_cmd}=      Replace String    ${CM_UE_1_PDU_SESSION}       ue=1    ue=${cell}

        Log To Console    Generated DTYPE cmd: ${dtype_cmd}
        Log To Console    Generated REGISTER cmd: ${reg_cmd}
        Log To Console    Generated PDU cmd: ${pdu_cmd}

        Exe egate cmd    cmd=${dtype_cmd}      return_output=False
        Exe egate cmd    cmd=${reg_cmd}
        Sleep      5
        Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
        ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
        Sleep    5
        Exe egate cmd    cmd=${pdu_cmd}
        Sleep    5
        Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
        ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
    END

UL Data
     Exe egate cmd      cmd=${CM_UE_1_UL_DATA}
     Sleep      1

UL Data for Multiple Cells with Range
    [Arguments]    ${start_UL_UE}    ${end_UL_UE}    ${start_trf_id}    ${end_trf_id}

    FOR    ${UL_UE}    IN RANGE    ${start_UL_UE}    ${end_UL_UE}+1
        Log To Console    ---- UE ${UL_UE} ----
        FOR    ${trf_id}    IN RANGE    ${start_trf_id}    ${end_trf_id}+1
            ${ul_data_cmd}=     Replace String     ${CM_UE_1_UL_DATA}     ue=1     ue=${UL_UE}
            ${ul_data_cmd}=     Replace String     ${ul_data_cmd}         trf_id=1     trf_id=${trf_id}
            Log To Console     Generated cmd: ${ul_data_cmd}

            Exe egate cmd    cmd=${ul_data_cmd}
            Sleep    5
        END
    END

DL Data
    Exe egate cmd      cmd=${CM_UE_1_UL_DATA}
     Sleep      1

DL Data for Multiple Cells with Range
    [Arguments]    ${start_DL_UE}    ${end_DL_UE}    ${start_dl_trf_id}    ${end_dl_trf_id}

    FOR    ${DL_UE}    IN RANGE    ${start_DL_UE}    ${end_DL_UE}+1
        Log To Console    ---- UE ${DL_UE} ----
        FOR    ${dl_trf_id}    IN RANGE    ${start_dl_trf_id}    ${end_dl_trf_id}+1
            ${dl_data_cmd}=     Replace String     ${CM_UE_1_DL_DATA}     ue=1     ue=${DL_UE}
            ${dl_data_cmd}=     Replace String     ${dl_data_cmd}         trf_id=1     trf_id=${dl_trf_id}
            Log To Console     Generated cmd: ${dl_data_cmd}

            Exe egate cmd    cmd=${dl_data_cmd}
            Sleep    5
        END
    END

PUSCH throughput
     Exe egate cmd      cmd=${CM_UE_1_UL_THRPUT}
     Sleep      1

PDSCH throughput
     Exe egate cmd      cmd=${CM_UE_1_DL_THRPUT}
     Sleep      1

Extract Full Cell Lines
    ${output}=    OperatingSystem.Get File    /opt/wts/latest/egate_console.log
    ${matches}=    Get Regexp Matches    ${output}    (?m)^CellIndex-.*$
    FOR    ${line}    IN    @{matches}
        Log To Console    ${line}
    END

UE Deregister
     Exe egate cmd      cmd=${CM_UE_1_DEREG}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE1_DEREG_REL}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

