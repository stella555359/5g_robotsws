*** Settings ***
Documentation
...   Keywords for basic Propsim procedure.
...   author: Tomasz Krol
...   contact: tomasz.krol@nokia.com


Resource    ./resources/robot/propsim_procedure.robot

Suite Setup       Suite Setup
Suite Teardown    Suite Teardown

*** Variables ***
# Common Varibles are defined in propsim_procedure.robot
# If you need to change some value ony for particular test case please overwrite it below

${PROPSIM_PROFILE_DIR}      D:\\\\User Emulations\\\\Jarek\\\\GMC\\\\
${duration}                 180s
${tput}                     150 Mbits/sec

*** Test Cases ***
AZHL_4T4R_UMLa_CDCL_NO_SHADOWING_RANK2
#    [Setup]    Common Preconditions

    Set Test Variable       ${propsim_emu_file}
    ...                     ${PROPSIM_PROFILE_DIR}AZHL_4T4R_UMLa_CDCL_NO_SHADOWING_RANK2.gcm\\\\AZHL_4T4R_UMLa_CDCL_NO_SHADOWING_RANK2.smu

    Propsim Procedure       capabilities=${capabilities}
    ...                     duration=${duration}
    ...                     tput=${tput}
    ...                     protocol=${protocol}
    ...                     parallel_streams=${parallel_streams}
    ...                     size_packet=${size_packet}
    ...                     buffer_client=${buffer_client}
    ...                     buffer_server=${buffer_server}
    ...                     interval=${interval}
    ...                     qci=${qci}
    ...                     reboot_ue=${reboot_ue}
    ...                     timeout_reboot_ue=${timeout_reboot_ue}
    ...                     propsim_emu_file=${propsim_emu_file}

#    [Teardown]    Run Keywords
#    ...           Common Postconditions
#    ...           AND
#    ...           Run Keyword If Test Failed    Restore gNB Configuration After Test

AZHL_4T2R_UMLa_CDCL_NO_SHADOWING_RANK2
#    [Setup]    Common Preconditions

    Set Test Variable       ${propsim_emu_file}
    ...                     ${PROPSIM_PROFILE_DIR}AZHL_4T2R_UMLa_CDCL_NO_SHADOWING_RANK2.gcm\\\\AZHL_4T2R_UMLa_CDCL_NO_SHADOWING_RANK2.smu

    Propsim Procedure       capabilities=${capabilities}
    ...                     duration=${duration}
    ...                     tput=${tput_dl}
    ...                     protocol=${protocol}
    ...                     parallel_streams=${parallel_streams}
    ...                     size_packet=${size_packet}
    ...                     buffer_client=${buffer_client}
    ...                     buffer_server=${buffer_server}
    ...                     interval=${interval}
    ...                     qci=${qci}
    ...                     reboot_ue=${reboot_ue}
    ...                     timeout_reboot_ue=${timeout_reboot_ue}
    ...                     propsim_emu_file=${propsim_emu_file}

#    [Teardown]    Run Keywords
#    ...           Common Postconditions
#    ...    AND    Run Keyword If Test Failed    Restore gNB Configuration After Test

AZQG_4T4R_ULMa_CLDC_NO_SHADOWING
#    [Setup]    Common Preconditions

    Set Test Variable       ${propsim_emu_file}
    ...                     ${PROPSIM_PROFILE_DIR}AZQG_4T4R_ULMa_CLDC_NO_SHADOWING.gcm\\\\AZQG_4T4R_ULMa_CLDC_NO_SHADOWING.smu

    Propsim Procedure       capabilities=${capabilities}
    ...                     duration=${duration}
    ...                     tput=${tput_dl}
    ...                     protocol=${protocol}
    ...                     parallel_streams=${parallel_streams}
    ...                     size_packet=${size_packet}
    ...                     buffer_client=${buffer_client}
    ...                     buffer_server=${buffer_server}
    ...                     interval=${interval}
    ...                     qci=${qci}
    ...                     reboot_ue=${reboot_ue}
    ...                     timeout_reboot_ue=${timeout_reboot_ue}
    ...                     propsim_emu_file=${propsim_emu_file}

#    [Teardown]    Run Keywords
#    ...           Common Postconditions
#    ...           AND
#    ...           Run Keyword If Test Failed    Restore gNB Configuration After Test

AZQG_4T2R_ULMa_CLDC_NO_SHADOWING
#    [Setup]    Common Preconditions

    Set Test Variable       ${propsim_emu_file}
    ...                     ${PROPSIM_PROFILE_DIR}AZQG_4T2R_ULMa_CLDC_NO_SHADOWING.gcm\\\\AZQG_4T2R_ULMa_CLDC_NO_SHADOWING.smu

    Propsim Procedure       capabilities=${capabilities}
    ...                     duration=${duration}
    ...                     tput=${tput_dl}
    ...                     protocol=${protocol}
    ...                     parallel_streams=${parallel_streams}
    ...                     size_packet=${size_packet}
    ...                     buffer_client=${buffer_client}
    ...                     buffer_server=${buffer_server}
    ...                     interval=${interval}
    ...                     qci=${qci}
    ...                     reboot_ue=${reboot_ue}
    ...                     timeout_reboot_ue=${timeout_reboot_ue}
    ...                     propsim_emu_file=${propsim_emu_file}

#    [Teardown]    Run Keywords
#    ...           Common Postconditions
#    ...           AND
#    ...           Run Keyword If Test Failed    Restore gNB Configuration After Test
