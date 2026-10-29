*** Settings ***
Documentation
...     [Procedure]     "eCPRI Transport for O-RAN and Time Sensitive Network"
...     [Author]        "Santhosh KG"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [QC_Path]       "QC_Path in Test Plan"
...     [QC_ID]         ". . . ."
...     [Feature_ID]    "CB008833"
...     [Requirement ID]   "TT_L2.3103;TT_L2.2873;TT_GEN_COMMON_USCR_451;TT_L2.2875;TT_L2.3110;TT_L2.3104;
...     TT_GEN_COMMON_USCR_468;OM_GEN_SFS_RNWINT.6688;TT_GEN_COMMON_USCR_480;TT_L2.2875;TT_L2.3117;TT_L2.3114;
...     TT_L2.3115;TT_GEN_COMMON_USCR_467"
...     [Funtion_Hash_Tags] "Fronthaul ORAN and TSN"
...     [Domain_Hash_Tags] "Fronthaul"
...     [Validated_TestLine]    "2322"
...     [Config]    "Base configuration with feature related configs loaded while execution"
...     [Runtime param]   "bts_id is provided at run time."


Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/Common_keywords_cb008833.robot

Suite setup    Run Keywords    setup oamops
...            AND    Setup Oamops     dut=chained_bts     alias=secondary
Suite Teardown     Run Keywords     Teardown oamops
...            AND    Teardown Oamops    dut=chained_bts    alias=secondary




*** Test Cases ***
[1]CB008833_B_Verification of Mplane DSCP PCP configuration and CU Plane PCP Marking for traffic flows in p2p network
    Perform Commissioning       scf_file=${base_scf}   verify_bts_status=${True}     timeout=300     alias=default
    Continue Keyword Execution On Failure    ${True}
    Log   Configure BTS with actECPRITransportForORAN feature flag
    Perform Recommissioning    type=delta    delta_file=${bts_config}        timeout=300
    Sleep   720
    Verify BTS Status      should_be_onair=${True}     rat=5g
    Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active
    Sleep   120
    Get AEQY IP
    DSCP PCP Verification AEQY      verify_mplane_dscp_pcp_bbmod_RM_as_src      verify_mplanedscppcp_rmod_AEQY_src
    Reset      operation=reset_unit
    ...     dist_name=MRBTS-${basebandAEQY}      reset_type=Warm      timeout=300    verify_bts=${True}
    Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active
    DSCP PCP Verification AEQY      verify_mplane_dscp_pcp_bbmod_RM_as_src      verify_mplanedscppcp_rmod_AEQY_src
    Reset      operation=reset_unit  dist_name=${RadioAEQY}      reset_type=Hard      timeout=600  verify_bts=${True}
    Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active
    DSCP PCP Verification AEQY       verify_mplane_dscp_pcp_bbmod_RM_as_src      verify_mplanedscppcp_rmod_AEQY_src
    DSCP PCP Verification AEQY Modification   verify_mplane_dscp_pcp_bbmod_RM_as_src_mod
    ...     verify_mplane_dscp_pcp_AEQY_as_src_mod
    Reload BTS
