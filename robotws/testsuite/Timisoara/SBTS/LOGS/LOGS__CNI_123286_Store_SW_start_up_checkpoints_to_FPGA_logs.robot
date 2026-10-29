*** Settings ***
Documentation    TC CNI_123286_Store_SW_start_up_checkpoints_to_FPGA_logs
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot


*** Keywords ***
TC__LOGS__CNI_123286_Store_SW_start_up_checkpoints_to_FPGA_logs

    Step 0: Connect to BTS
    Step 1: Check StartupCheckpointsLog content

Step 0: Connect to BTS
    [Documentation]
    ...   In this step test case connects to BTS

    Log    \nStep 0: Connecting to BTS    console=${True}
    SSH.Connect To      hostname=192.168.255.129    username=toor4nsn   password=oZPS0POrRieRtu     alias=connection_gnb
    Log    \nSuccesfully connected to the BTS    console=${True}
    Sleep   2


Step 1: Check StartupCheckpointsLog content
    [Documentation]
    ...   In this step we check the content of StartupCheckpointsLog file.
    Check StartupCheckpointsLog Content And Attributes


Check StartupCheckpointsLog Content And Attributes
    [Documentation]
    ...   In this step, we check the content of the StartupCheckpointsLog file and validate its attributes.
    Log    \nStep 1: Checking content of StartupCheckpointsLog file   console=${True}

    # Define the expected attributes for each checkpoint
    &{CHECKPOINT_ATTRIBUTES}=  Create Dictionary
    ...  STRTCP_BBP_SRVBRK_BOARD_RESET_START=KernelTime,BoardID,State,ResetType
    ...  STRTCP_BBP_SRVBRK_LFS_RESET_START=KernelTime
    ...  STRTCP_BBP_SRVBRK_ALL_APP_STOP=KernelTime,Owner
    ...  STRTCP_BBP_SRVBRK_APP_PREPARATION_STOP=KernelTime,Owner
    ...  STRTCP_BBP_SRVBRK_HWAPI_STOP=KernelTime
    ...  STRTCP_BBP_SRVBRK_CCS_STOP=KernelTime
    ...  STRTCP_BBP_SRVBRK_LFS_STOP=KernelTime,Owner
    ...  STRTCP_BBP_SRVBRK_ADDON_STOP=KernelTime,Owner
    ...  STRTCP_BBP_SRVBRK_LFS_BOOT_START=KernelTime,Owner
    ...  STRTCP_BBP_SRVBRK_LFS_SECONDARY_BOOT_START=KernelTime,Owner
    ...  STRTCP_BBP_SRVBRK_LFS_KERNEL_START=KernelTime,Owner
    ...  STRTCP_BBP_SRVBRK_ADDON_PREPARED=KernelTime,Owner
    ...  STRTCP_BBP_SRVBRK_ADDON_READY=KernelTime,Owner
    ...  STRTCP_BBP_SRVBRK_LFS_READY=KernelTime,Owner
    ...  STRTCP_BBP_SRVBRK_CCS_READY=KernelTime
    ...  STRTCP_BBP_SRVBRK_HWAPI_READY=KernelTime
    ...  STRTCP_BBP_SRVBRK_APP_PREPARATION_READY=KernelTime,Owner
    ...  STRTCP_BBP_SRVBRK_ALL_APP_STARTED=KernelTime,Owner
    ...  STRTCP_BBP_SRVBRK_TIME_SYNC=KernelTime,from(UTC time),to(UTC time),Difference
    ...  STRTCP_BBP_SRVBRK_FSP_DETECTED=KernelTime,Owner,SlotId,DeviceId,DomainId
    ...  STRTCP_BBP_SRVBRK_SWIMAGE_TO_FSP=KernelTime,Owner,SlotId,DeviceId,DomainId
    ...  STRTCP_BBP_SRVBRK_UNIT_ADET_READY=KernelTime,State,SlotId,BoardId,type
    ...  STRTCP_BBP_SRVBRK_L1_RELEASED_FROM_RESET=KernelTime,Owner,Slot,Device,DomainId
    ...  STRTCP_BBP_SRVBRK_CPU_ADET_READY=KernelTime,State,NodeId,DeviceId
    ...  STRTCP_BBP_SRVBRK_CONTAINER_TRIGGER_START=KernelTime,NodeIdTag
    ...  STRTCP_BBP_SRVBRK_CONTAINER_TRIGGER_START_RESP=KernelTime,NodeIdTag
    ...  STRTCP_BBP_SRVBRK_CONTAINER_STATE=KernelTime,NodeIdTag,State
    ...  STRTCP_BBP_SRVBRK_CONTAINER_TRIGGER_STOP=KernelTime,NodeIdTag
    ...  STRTCP_BBP_SRVBRK_CONTAINER_TRIGGER_STOP_RESP=KernelTime,NodeIdTag
    ...  STRTCP_BBP_SRVBRK_CONTAINER_TRIGGER_KILL=KernelTime,NodeIdTag
    ...  STRTCP_BBP_SRVBRK_CONTAINER_TRIGGER_KILL_RESP=KernelTime,NodeIdTag
    ...  STRTCP_BBP_SRVBRK_CONTAINER_TRIGGER_DELETE=KernelTime,NodeIdTag
    ...  STRTCP_BBP_SRVBRK_CONTAINER_TRIGGER_DELETE_RESP=KernelTime,NodeIdTag

    # Check if log file exists and get its content
    ${filepath}=    Set Variable    /ffs/run/logs/lfs/checkpoints/StartupCheckpointsLog
    SSH.Send Command    command=cat ${filepath}      connection=connection_gnb
    ${log_content}=     SSH.Read Output     connection=connection_gnb
    Should Not Contain    ${log_content}    FILE_NOT_FOUND    msg=StartupCheckpointsLog file not found at ${filepath}
    Log    \nStartupCheckpointsLog content:\n${log_content}   console=${True}

    # Process each line of the log
    @{lines}=    Split To Lines    ${log_content}
    FOR    ${line}    IN    @{lines}
        Run Keyword If    '${line}' == ''    Continue For Loop

        # Extract the checkpoint name
        @{parts}=    Split String    ${line}    ,
        Run Keyword If    len(${parts}) < 2    Continue For Loop
        ${checkpoint}=    Strip String     ${parts}[1]

        # Check if the checkpoint is one we need to validate
        ${is_in_dict}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${CHECKPOINT_ATTRIBUTES}    ${checkpoint}
        IF    ${is_in_dict}
            Log    Validating checkpoint: ${checkpoint}
            ${expected_attrs_str}=    Get From Dictionary    ${CHECKPOINT_ATTRIBUTES}    ${checkpoint}
            @{expected_attrs}=    Split String    ${expected_attrs_str}    ,

            # Check each expected attribute
            FOR    ${attr}    IN    @{expected_attrs}
                Should Contain    ${line}    ${attr}    msg=Checkpoint '${checkpoint}' is missing attribute '${attr}' in line: '${line}'
            END
            Log    Validation for checkpoint '${checkpoint}' passed.    console=${True}
        END
    END
    Log    \nStartupCheckpointsLog content validation complete! [OK]   console=${True}


Disconnect from BTS
    [Documentation]
    ...   In this step test cases disconnects from BTS

    Log    \nTerminating connection with BTS   console=${True}
    Sleep   2
    SSH.Disconnect      connection=connection_gnb

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    Disconnect from BTS
    ...    AND    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown
