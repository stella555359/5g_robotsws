*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    CONFIGURED    RAN_5G_TDD    RAN_5G
...           CRT    SBTS00    NoResUsage    PY310    RF50

Documentation
...   author: Tomasz Niedzwiedzki
...   contact: tomasz.niedzwiedzki@nokia.com
...   description: 5GC001085-D sub-feature:

Resource    5GC001085_Keywords.robot

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/../initial_commissioning.xml
...            AND             Start Vm Ethernet Interfaces
...            AND             Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/SNSSAI-1  parameter=administrativeState  value=Locked
...            AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_7883.json
...            AND             Check Radios Availability
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/scfc_after_delta.xml
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_7883.lua
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords    Stop Default Processes And Gather Logs And Compress Logs
...               AND             Stop Vm Ethernet Interfaces
...               AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/final_commissioning.xml
...               AND             Send Full Commissioning    input_filepath=${OUTPUT_DIR}/../initial_commissioning.xml

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown    Run Keywords    Add Scout External Execution ID To Reporting Portal
...              AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Test Cases ***
[1]CB007883_5G_A_029_2287053_Ignore_Inactive_Or_Locked_AMF_Tigger_SON_Configuration_Transfer_To_Active_AMF
    [Documentation]    Purpose of this testcase is to check if correct AMF has been chosen to perform
    ...                the SON Configuration Transfer procedure in case when first AMF is inactive or first AMF is locked.
    ...                5G_RAN_USR_RRM_2935

    Removal Restriction Modification Of MIB Cell Barred Status
    Attach UE    ue_id=1
    Establish PDU Session    ue_id=1    pdu_id=1    gw_id=1
    Send UE Measurement NR Event A3 With Aligned Meas ID    ue_id=1    cell_id=1    phycell_id=150    nrsrp_nr=90    srsrp_nr=20
    Find Scfc And Send Delta Commissioning    amf1_unlocked_amf2_added.json
    Attach UE    ue_id=2
    Establish PDU Session    ue_id=2    pdu_id=2    gw_id=2
    Send UE Measurement NR Event A3 With Aligned Meas ID    ue_id=2    cell_id=1    phycell_id=150    nrsrp_nr=90    srsrp_nr=20
    Verify Created NRADJGNB And XNLINK Objects
    Find Scfc And Send Delta Commissioning    scfc_filename=amf2_deleted.json
    Attach UE    ue_id=3
    Establish PDU Session    ue_id=3    pdu_id=3    gw_id=3
    Send UE Measurement NR Event A3 With Aligned Meas ID    ue_id=3    cell_id=1    phycell_id=150    nrsrp_nr=90    srsrp_nr=20
    ...                                                     pass_regexp=Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed
    ...                                                     timeout=7
    Find Scfc And Send Delta Commissioning    scfc_filename=amf1_locked_amf2_added.json
    Removal Restriction Modification Of MIB Cell Barred Status
    Attach UE    ue_id=4
    Establish PDU Session    ue_id=4    pdu_id=4    gw_id=4
    Send UE Measurement NR Event A3 With Aligned Meas ID    ue_id=4    cell_id=1    phycell_id=150    nrsrp_nr=90    srsrp_nr=20
    Verify Created NRADJGNB And XNLINK Objects

*** Keywords ***
 Verify Created NRADJGNB And XNLINK Objects
    Wait For Object To Exist    object_name=NRADJGNB_A-1    moc=NRADJGNB_A    timeout=150
    Wait For Object To Exist    object_name=XNLINK_A-1    moc=XNLINK_A    timeout=150
    &{NRADJGNB}=    Get Managed Object    object_name=NRADJGNB_A-1    moc=NRADJGNB_A
    &{XNLINK}=    Get Managed Object    object_name=XNLINK_A-1    moc=XNLINK_A
    Verify Created XNLINK Object    XNLINK=&{XNLINK}    cPlaneIpAddr=10.0.1.101    cPlaneIpAddrCtrl=oamControlled
    Verify Created NRADJGNB Object    NRADJGNB=&{NRADJGNB}    mcc=311    mnc=489    mncLength=3    gNodeBIdCtrl=oamControlled
    ...                               gNbIdLength=22    xnLinkRef=1    administrativeState=Unlocked

