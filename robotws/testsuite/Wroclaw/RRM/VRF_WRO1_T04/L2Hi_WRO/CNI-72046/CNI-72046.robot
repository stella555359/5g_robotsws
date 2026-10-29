*** Settings ***
Library    taf.ccs.aashell    WITH NAME    cli
Library    taf.config.wts     WITH NAME    wts
Resource   testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_keywords.robot

Documentation
...    author:      Michal Brychcy
...    maintainer:  Marcin Kotuła (marcin.kotula@nokia.com)
...    testline:    CLOUD_5G_I_LO_AP_LO
...    release:     22R4

*** Variables ***
${TRAFFIC_DURATION_SEC}=   20s

*** Keywords ***
CNI-72046_Verify_that_no_Uplane_resources_are_used_before_ues_attach_and_after_ues_detach
    Check Not Used L2hi Resources
    Attach Multiple 5g Ues Capable Of Supporting Vonr    num_of_ues=${5}
    Start Dl And Ul Data Traffic For Rtp Packet Stream For Five Ues
    Check Used L2hi Resources
    Deregister Multiple Ues    first_ue_id=1    last_ue_id=5
    Check Not Used L2hi Resources
    Modify Qosflow For Emergency Call
    Attach Multiple 5g Ues Capable Of Supporting Emergency Call    num_of_ues=${5}
    Start Dl And Ul Data Traffic For Rtp Packet Stream For Five Ues
    Check Used L2hi Resources
    Deregister Multiple Ues    first_ue_id=1    last_ue_id=5
    Check Not Used L2hi Resources

Modify Config To Default
    wts.Load Wts Cfg        ${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
    wts.Modify    set_qosflow id=1          5qi=6 default=on
    wts.Modify    set_qosflow id=2          5qi=5 default=off
    wts.Save Wts Cfg        ${EPCSIM_CFG_PATH_SANSA_TDD_FDD}

Enable Vonr and Emergency Call For Gnb
    Enable Vonr
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Vonr_and_Rohc/delta_enable_emergency_call.json

Modify Qosflow For Emergency Call
    Execute Egate Command    cmd=qosflow_modify qos_flow=2 priority=5
    Execute Egate Command    cmd=qosflow_modify qos_flow=3 priority=5

Attach Multiple 5g Ues Capable Of Supporting Emergency Call
    [Arguments]    ${num_of_ues}=${5}
    FOR    ${ue_id}    IN RANGE    ${1}    ${num_of_ues}+${1}
        Set Internal Traffic Type To UEs    ue_id=${ue_id}    pdu_id=${ue_id}
        Register Ue With Default Pdu Session    ue_id=${ue_id}    pdu_id=${ue_id}    gw=${ue_id}
        Modify Pdu Session And Wait For Regexp    ue_id=${ue_id}    pdu_id=${ue_id}    qos_id=3    qfi_id=2    5qi_id=1
    END

Attach Multiple 5g Ues Capable Of Supporting Vonr
    [Arguments]    ${num_of_ues}=${5}
    FOR    ${ue_id}    IN RANGE    ${1}    ${num_of_ues}+${1}
        Set Internal Traffic Type To UEs    ue_id=${ue_id}    pdu_id=${ue_id}
        Register Ue With Default Pdu Session    ue_id=${ue_id}    pdu_id=${ue_id}    gw=${ue_id}
        Modify Pdu Session And Wait For Regexp    ue_id=${ue_id}    pdu_id=${ue_id}    qos_id=1    qfi_id=2    5qi_id=8
        Modify Pdu Session And Wait For Regexp    ue_id=${ue_id}    pdu_id=${ue_id}    qos_id=3    qfi_id=3    5qi_id=1
    END

Start Dl And Ul Data Traffic For Rtp Packet Stream
    [Arguments]    ${ue_id}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${ue_id} qfi=3 dir=dl rtp_codec=amr_wb_23_85
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${ue_id} qfi=3 dir=ul rtp_codec=amr_wb_23_85

Start Dl And Ul Data Traffic For Rtp Packet Stream For Five Ues
    [Arguments]    ${num_of_ues}=${5}
    FOR    ${ue_id}    IN RANGE    ${1}    ${num_of_ues}+${1}
        Start Dl And Ul Data Traffic For Rtp Packet Stream    ue_id=${ue_id}
    END
    Sleep    ${TRAFFIC_DURATION_SEC}

Check Not Used L2hi Resources
    Sleep    20s
    Run Keyword    cli.create_aashell_cli    name=aashell
    Run Keyword    cli.setup     aashell
    ${used_all_resources}=    cli.get_resources_usage    aashell
    ${used_cpnrt_resources}=    Get_From_Dictionary    ${used_all_resources}    CPNRT
    Check That L2hi Resources Are Not Used    ${used_cpnrt_resources}
    [Teardown]    cli.teardown    aashell

Check Used L2hi Resources
    Run Keyword    cli.create_aashell_cli    name=aashell
    Run Keyword    cli.setup     aashell
    ${used_all_resources}=    cli.get_resources_usage    aashell
    ${used_cpnrt_resources}=    Get_From_Dictionary    ${used_all_resources}    CPNRT
    Check That L2hi Resources Are Used    ${used_cpnrt_resources}
    [Teardown]    cli.teardown    aashell
