*** Settings ***
Library     ta_pcmd
Library     ../../../resources/PCMD/verifier_msg_for_pcmd.py

*** Variables ***
${CuUeSetupRecord1}=                              ${CURDIR}/ueSetupTraceRecord_without_guami.yaml
${CuUeSetupRecord2}=                              ${CURDIR}/ueSetupTraceRecord_with_guami.yaml


*** Keywords ***

Verify CuUeSetupTraceRecord in BI002-1
    set variable for record yaml
    ...     variable=ueSetupResult
    ...     value=success
    ...     yaml_path=${CuUeSetupRecord1}
    set variable for record yaml
    ...     variable=ueSetupTrigger
    ...     value=other
    ...     yaml_path=${CuUeSetupRecord1}

    set variable for record yaml
    ...     variable=ueSetupResult
    ...     value=success
    ...     yaml_path=${CuUeSetupRecord2}
    set variable for record yaml
    ...     variable=ueSetupTrigger
    ...     value=other
    ...     yaml_path=${CuUeSetupRecord2}

    set_variable_from_single_message_for_record_yaml
    ...     yaml_path=${CuUeSetupRecord1}
    ...     message_name=DownlinkNASTransport
    set_variable_from_single_message_for_record_yaml
    ...     yaml_path=${CuUeSetupRecord2}
    ...     message_name=UEContextModificationResponse

    Add record for verification
    ...     record_name_with_alias=CuUeSetupTraceRecord
    ...     yaml_path=${CuUeSetupRecord1}
    Add record for verification
    ...     record_name_with_alias=CuUeSetupTraceRecord
    ...     yaml_path=${CuUeSetupRecord2}


    Wait for PCMD records
    ...     record_num=2
    ...     record_name=CuUeSetupTraceRecord
    ...     timeout=20

    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=3
    ...     record_name=CuUeSetupTraceRecord
    ...     timeout=20

    Perform Records Verification
