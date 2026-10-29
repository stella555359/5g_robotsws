***Settings***
Documentation
     ...    [Procedure] "The test case is planned to validate automatic X2, Xn Ipsec tunnel addition & removal by ANR
     ...                  procedure, with same & different ipsec template for dedicated GNB collapsed"
     ...    [Date] "2-07-2022"
     ...    [Author] "Shadab"
     ...    [QC_Path] "QC_Path in Test Plan"
     ...    [QC_ID] "QC_ID in Test Lab for reporting"
     ...    [Feature_ID] "CB007228"
     ...    [Validation_status] "Validated"
     ...    [Validated_TestLine] "TL006"
     ...    [Commissioning_comment] "This script requires 5G SA configuration with IPSEC Enabled "

variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource    	${CURDIR}/resources/CB007228_common_resource.robot

Suite setup     Run Keywords    setup oamops
...            AND      Setup Oamops    dut=x2_target_enb      alias=remote
Suite Teardown      Run Keywords    Teardown oamops
...            AND      Teardown Oamops     alias=remote

***Test Cases***
[1][1.0] [2.0]TRS_CB012471_Verify_X2_link_established_to_eNB _controlled _neighbor eNB_with_CB012471,SR001034_ASIB
       Perform Commissioning       scf_file=${Basic_scf_with_ipsectemp}   verify_bts_status=False     timeout=400
        Sleep      20
        Perform Commissioning       scf_file=${x2_target_enb['scf_neighbour_side_ipsec_temp']}     verify_bts_status=False
        ...     timeout=400     alias=remote
        Sleep       800
       Perform Recommissioning     type=param      rat=lte     param_path=MRBTS-1/MNL-1/MNLENT-1/FEATCADM-1:actFaultSignature
       ...    operation=update     value=true      timeout=600
       Read parameter values
        Verify Calls for IPSEC
        Sleep   20
        Analyse Pcap SON Transport Messages
        Verify X2 Link Status
        Verify X2 Link Status      remote
#        Traffic Capture Start        capture_device=oam_device    mode=file              measurement_point=NE_Terminated
#        ...          uplane_capturing=True        timeout=120            alias=pointA_after_FAF
        Perform Recommissioning     type=param      rat=lte     param_path=ANR-0:actX2IpV4Prioritization   operation=update
        ...     value=true      timeout=600
        Run     sudo ip a d fc01::1/120 dev eth3.2540
        Run     sudo ip a d fc01::138/120 dev eth3.2540
        Traffic Capture Start        capture_device=oam_device    mode=file              measurement_point=NE_Terminated
        ...    uplane_capturing=True        timeout=600            alias=pointA_after_FAF
        Sleep   800
        ${ipsec_capture}=     Traffic Capture Stop    capture_device=oam_device    mode=file     timeout=180     alias=pointA_after_FAF
        Set Suite Variable      ${ipsec_capture}
        Analyse Pcap for IPSECTLA Messages
        Verify X2 Link Status unavailable
        Verify X2 Link Status unavailable       remote
        Run     sudo ip a a fc01::1/120 dev eth3.2540
        Run     sudo ip a a fc01::138/120 dev eth3.2540
        Run     sudo killall egate edaemon