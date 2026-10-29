*** Settings ***
Documentation
...   author: Tomasz Godlewski
...   contact: tomasz.godlewski@nokia.com

Library    resources/keywords_9408.py
Variables    resources/variables_9408.py
Resource     resources/keywords_9408.robot

*** Keywords ***
TC05_CB009408-B-B1_An_enbControlled_LNADJGNB_instance_with_conflicting_parameter_values_already_exists
    Set Attenuation For Cell With Id    1_1    0dB    att_id=1
    Set Preferred Cell    14    cell_type=lte    lnbts_id=40896
    Require Ue If Not Reserved    ${UE_1}
    Switch Ue Mode To NR LTE    UE_1
    Remove Lnadjgnb Object    adj_gnb_id=0
    ${EXPECTED_IP_V4}=    Get Cplane Ip Addr    version=v4
    ${EXPECTED_IP_V6}=    Get Cplane Ip Addr    version=v6

    # STEP 1
    Create Lnadjgnb Object    adj_gnb_id_length=${INCORRECT_GNB_LENGTH}
    Check If Lnadjgnb Is Unavailable    adj_gnb_id=0

    #STEP 2
    Activate 9408 Feature
    Check If Lnadjgnb Is Available    adj_gnb_id=31
    ${lnadj_check}    Check If Lnadjgnb Exists    adj_gnb_id=0
    Should Not Be True    ${lnadj_check}

    #STEP3
    Wait Until Keyword Succeeds  3x  5s    Start L3 Call And Verify NSA    UE_1
    Check If LNRELGNBCELL Is Available

    #STEP4
    Deactivate 9408 Feature
    Activate Dualstack IP For S1 X2
    Wait For Onair    lte
    Create Lnadjgnb Object    ip_version=v6    mcc=${INCORRECT_MCC}
    Check If Lnadjgnb Is Unavailable    adj_gnb_id=0

    #STEP5
    Activate 9408 Feature
    Check If Lnadjgnb Is Available    adj_gnb_id=31
    ${lnadj_check}    Check If Lnadjgnb Exists    adj_gnb_id=0
    Should Not Be True    ${lnadj_check}
    Check If Lnadjgnb Has Correct Parameter    cPlaneIpAddr    ${EXPECTED_IP_V6}    adj_gnb_id=31

    #STEP9
    Deactivate 9408 Feature
    Remove Lnadjgnb Object    adj_gnb_id=31
    Create Lnadjgnb Object    cplane_ip_addr=${INCORRECT_IP_V6}
    Check If Lnadjgnb Is Unavailable    adj_gnb_id=0

    #STEP10
    Activate 9408 Feature
    Check If Lnadjgnb Is Available    adj_gnb_id=0

    #STEP11
    Wait Until Keyword Succeeds  3x  5s    Start L3 Call And Verify NSA    UE_1
    Check If LNRELGNBCELL Is Available

    #STEP6
    Save Current Scf Modify Gnb ID And Reload Scf
    Check If Lnadjgnb Is Unavailable    adj_gnb_id=0

    #STEP7
    Activate 9408 Feature
    Check If Lnadjgnb Is Available    adj_gnb_id=31

    #STEP8
    Wait Until Keyword Succeeds  3x  5s    Start L3 Call And Verify NSA    UE_1
    Check If LNRELGNBCELL Is Available

    #STEP12
    Deactivate 9408 Feature
    Deactivate Dualstack IP For S1 X2
    Wait For Onair    lte
    Remove Lnadjgnb Object    adj_gnb_id=31
    Create Lnadjgnb Object    cplane_ip_addr=${INCORRECT_IP_V4}
    Check If Lnadjgnb Is Unavailable    adj_gnb_id=0

    #STEP13
    Activate 9408 Feature
    Check If Lnadjgnb Is Available    adj_gnb_id=0
    Check If Lnadjgnb Has Correct Parameter    cPlaneIpAddr    ${EXPECTED_IP_V4}    adj_gnb_id=0

    #STEP14
    Wait Until Keyword Succeeds  3x  5s    Start L3 Call And Verify NSA    UE_1
    Check If LNRELGNBCELL Is Available
    [Teardown]    Run Keywords
    ...    Deactivate Dualstack IP For S1 X2    AND
    ...    Deactivate 9408 Feature    AND
    ...    Restore LNADJGNB0    AND
    ...    Detach Ue    UE_1    AND
    ...    Set Preferred Cell    15    cell_type=lte    lnbts_id=40896    AND
    ...    Switch Ue Mode To NR LTE    UE_1

Restore LNADJGNB0
    ${lnadjgnb0_exist}    Check If Lnadjgnb Exists    adj_gnb_id=0
    Run Keyword If    not ${lnadjgnb0_exist}
    ...    Run Keywords
    ...    Remove Lnadjgnb Object    adj_gnb_id=31    AND
    ...    Create Lnadjgnb Object    AND
    ...    Check If Lnadjgnb Is Available    adj_gnb_id=0
