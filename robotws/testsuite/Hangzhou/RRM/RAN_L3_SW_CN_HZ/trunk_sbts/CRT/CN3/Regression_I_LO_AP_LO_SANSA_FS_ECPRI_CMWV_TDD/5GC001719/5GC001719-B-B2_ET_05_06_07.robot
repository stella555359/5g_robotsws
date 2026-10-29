*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN  QCP_RAN_ET  SBTS00  RAN_5G  CRT  CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD  team-DevHZ5_SG1
...               owner-taotao.hu    release-SBTS00
Resource          ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${AP_LOG_LEVEL}  0
${DEBUG_LOG_LEVEL}  0
@{PARAMS_IN_SCF}
...    @{5GC000706}
@{5GC000706}

...    NRBTS:actConflictConfiguration=true
...    NRBTS:actIncXn=true
@{delta_for_case5}
...    XNLINK-1:cPlaneIpAddr=10.0.1.143
...    XNLINK-2:cPlaneIpAddr=10.0.1.141
...    XNLINK-3:cPlaneIpAddr=10.0.1.142
...    NRADJGNB-1:administrativeState=Unlocked
...    NRADJGNB-1:gNbIdLength=22
...    NRADJGNB-1:gNodeBId=36
...    NRADJGNB-1:xnLinkRef=${EMPTY}
...    NRADJGNB-1:xnLinkRef2=${EMPTY}
...    NRADJGNB-1:gnbPlmn:mcc=311|mncLength=3
...    NRADJGNB-1:gnbPlmn:mnc=489|mncLength=3
...    NRADJGNB-2:administrativeState=Unlocked
...    NRADJGNB-2:gNbIdLength=22
...    NRADJGNB-2:gNodeBId=37
...    NRADJGNB-2:xnLinkRef=1
...    NRADJGNB-2:xnLinkRef2=${EMPTY}
...    NRADJGNB-2:gnbPlmn:mcc=311|mncLength=3
...    NRADJGNB-2:gnbPlmn:mnc=489|mncLength=3
...    NRADJGNB-3:administrativeState=Unlocked
...    NRADJGNB-3:gNbIdLength=22
...    NRADJGNB-3:gNodeBId=38
...    NRADJGNB-3:xnLinkRef=2
...    NRADJGNB-3:xnLinkRef2=3
...    NRADJGNB-3:gnbPlmn:mcc=311|mncLength=3
...    NRADJGNB-3:gnbPlmn:mnc=489|mncLength=3
@{delta_for_case6_1}
...    XNLINK-20:cPlaneIpAddr=10.0.1.122
...    XNLINK-21:cPlaneIpAddr=10.0.1.124
...    XNLINK-22:cPlaneIpAddr=10.0.1.126
...    XNLINK-23:cPlaneIpAddr=10.0.1.128
...    XNLINK-5:cPlaneIpAddr=10.0.1.142
...    XNLINK-6:cPlaneIpAddr=10.0.1.143
...    XNLINK-7:cPlaneIpAddr=10.0.1.144
...    XNLINK-8:cPlaneIpAddr=10.0.1.145
...    XNLINK-9:cPlaneIpAddr=10.0.1.146
...    XNLINK-10:cPlaneIpAddr=10.0.1.147
...    XNLINK-11:cPlaneIpAddr=10.0.1.148
...    XNLINK-12:cPlaneIpAddr=10.0.1.149
...    NRADJGNB-1:administrativeState=Unlocked
...    NRADJGNB-1:gNbIdLength=22
...    NRADJGNB-1:gNodeBId=40
...    NRADJGNB-1:xnLinkRef=20
...    NRADJGNB-1:xnLinkRef2=5
...    NRADJGNB-1:gnbPlmn:mcc=311|mncLength=3
...    NRADJGNB-1:gnbPlmn:mnc=489|mncLength=3
...    NRADJGNB-2:administrativeState=Unlocked
...    NRADJGNB-2:gNbIdLength=22
...    NRADJGNB-2:gNodeBId=36
...    NRADJGNB-2:xnLinkRef=6
...    NRADJGNB-2:xnLinkRef2=7
...    NRADJGNB-2:gnbPlmn:mcc=311|mncLength=3
...    NRADJGNB-2:gnbPlmn:mnc=489|mncLength=3
...    NRADJGNB-3:administrativeState=Unlocked
...    NRADJGNB-3:gNbIdLength=22
...    NRADJGNB-3:gNodeBId=41
...    NRADJGNB-3:xnLinkRef=8
...    NRADJGNB-3:xnLinkRef2=21
...    NRADJGNB-3:gnbPlmn:mcc=311|mncLength=3
...    NRADJGNB-3:gnbPlmn:mnc=489|mncLength=3
...    NRADJGNB-4:administrativeState=Unlocked
...    NRADJGNB-4:gNbIdLength=22
...    NRADJGNB-4:gNodeBId=37
...    NRADJGNB-4:xnLinkRef=9
...    NRADJGNB-4:xnLinkRef2=10
...    NRADJGNB-4:gnbPlmn:mcc=311|mncLength=3
...    NRADJGNB-4:gnbPlmn:mnc=489|mncLength=3
...    NRADJGNB-10:administrativeState=Unlocked
...    NRADJGNB-10:gNbIdLength=22
...    NRADJGNB-10:gNodeBId=42
...    NRADJGNB-10:xnLinkRef=1
...    NRADJGNB-10:xnLinkRef2=22
...    NRADJGNB-10:gnbPlmn:mcc=311|mncLength=3
...    NRADJGNB-10:gnbPlmn:mnc=489|mncLength=3
...    NRADJGNB-11:administrativeState=Unlocked
...    NRADJGNB-11:gNbIdLength=22
...    NRADJGNB-11:gNodeBId=38
...    NRADJGNB-11:xnLinkRef=2
...    NRADJGNB-11:xnLinkRef2=12
...    NRADJGNB-11:gnbPlmn:mcc=311|mncLength=3
...    NRADJGNB-11:gnbPlmn:mnc=489|mncLength=3
...    NRADJGNB-12:administrativeState=Unlocked
...    NRADJGNB-12:gNbIdLength=22
...    NRADJGNB-12:gNodeBId=43
...    NRADJGNB-12:xnLinkRef=3
...    NRADJGNB-12:xnLinkRef2=23
...    NRADJGNB-12:gnbPlmn:mcc=311|mncLength=3
...    NRADJGNB-12:gnbPlmn:mnc=489|mncLength=3
...    NRADJGNB-13:administrativeState=Unlocked
...    NRADJGNB-13:gNbIdLength=22
...    NRADJGNB-13:gNodeBId=39
...    NRADJGNB-13:xnLinkRef=11
...    NRADJGNB-13:xnLinkRef2=4
...    NRADJGNB-13:gnbPlmn:mcc=311|mncLength=3
...    NRADJGNB-13:gnbPlmn:mnc=489|mncLength=3
@{delta_for_case7}
...    XNLINK-1:cPlaneIpAddr=10.0.1.122
...    XNLINK-2:cPlaneIpAddr=10.0.1.124
...    XNLINK-3:cPlaneIpAddr=10.0.1.126
...    XNLINK-4:cPlaneIpAddr=10.0.1.141
...    XNLINK-5:cPlaneIpAddr=10.0.1.142
...    XNLINK-6:cPlaneIpAddr=10.0.1.143
...    XNLINK-7:cPlaneIpAddr=10.0.1.144
...    XNLINK-8:cPlaneIpAddr=10.0.1.145
...    XNLINK-9:cPlaneIpAddr=10.0.1.146
...    NRADJGNB-1:administrativeState=Unlocked
...    NRADJGNB-1:gNbIdLength=22
...    NRADJGNB-1:gNodeBId=40
...    NRADJGNB-1:xnLinkRef=1
...    NRADJGNB-1:xnLinkRef2=4
...    NRADJGNB-1:gnbPlmn:mcc=311|mncLength=3
...    NRADJGNB-1:gnbPlmn:mnc=489|mncLength=3
...    NRADJGNB-2:administrativeState=Unlocked
...    NRADJGNB-2:gNbIdLength=22
...    NRADJGNB-2:gNodeBId=36
...    NRADJGNB-2:xnLinkRef=5
...    NRADJGNB-2:xnLinkRef2=${EMPTY}
...    NRADJGNB-2:gnbPlmn:mcc=311|mncLength=3
...    NRADJGNB-2:gnbPlmn:mnc=489|mncLength=3
...    NRADJGNB-3:administrativeState=Unlocked
...    NRADJGNB-3:gNbIdLength=22
...    NRADJGNB-3:gNodeBId=41
...    NRADJGNB-3:xnLinkRef=6
...    NRADJGNB-3:xnLinkRef2=2
...    NRADJGNB-3:gnbPlmn:mcc=311|mncLength=3
...    NRADJGNB-3:gnbPlmn:mnc=489|mncLength=3
...    NRADJGNB-4:administrativeState=Unlocked
...    NRADJGNB-4:gNbIdLength=22
...    NRADJGNB-4:gNodeBId=37
...    NRADJGNB-4:xnLinkRef=7
...    NRADJGNB-4:xnLinkRef2=${EMPTY}
...    NRADJGNB-4:gnbPlmn:mcc=311|mncLength=3
...    NRADJGNB-4:gnbPlmn:mnc=489|mncLength=3
...    NRADJGNB-5:administrativeState=Unlocked
...    NRADJGNB-5:gNbIdLength=22
...    NRADJGNB-5:gNodeBId=42
...    NRADJGNB-5:xnLinkRef=8
...    NRADJGNB-5:xnLinkRef2=3
...    NRADJGNB-5:gnbPlmn:mcc=311|mncLength=3
...    NRADJGNB-5:gnbPlmn:mnc=489|mncLength=3
...    NRADJGNB-6:administrativeState=Unlocked
...    NRADJGNB-6:gNbIdLength=22
...    NRADJGNB-6:gNodeBId=38
...    NRADJGNB-6:xnLinkRef=${EMPTY}
...    NRADJGNB-6:xnLinkRef2=${EMPTY}
...    NRADJGNB-6:gnbPlmn:mcc=311|mncLength=3
...    NRADJGNB-6:gnbPlmn:mnc=489|mncLength=3
@{clean_NRADJGNB_XNLINK}
...    delete:NRADJGNB.*
...    delete:XNLINK.*
@{clean_gnbcontolled_NRADJGNB}
...    delete:NRADJGNB-1
...    delete:NRADJGNB-2
...    delete:NRADJGNB-3
...    delete:NRADJGNB-4
${7311_fault_name}    No Xn link available
${7311_fault_id}    7311
${7311_alarm_id}    7107
*** Test Cases ***
5GC001719-B-B2_ET_06_01_Local gNB establish xnlink by new slected NRADJGNB wirh xnlinkRef2 configured when XN Setup procedure start from Local
    [Documentation]    step1: trigger xn setup from local gnbid mismatch NRADJGNB-1 by xnlinkref
    ...    and trigger xn setup from local gnbid mismatch NRADJGNB-2 by xnlinkref2
    ...    step2: check xnlink status and xnlinkref updated for selected NRADJGNB,
    ...    and check xnlink and NRADJGNB cleanup
    ...    step3: trigger xn setup from local gnbid mismatch NRADJGNB-10 by xnlinkref and with gnbcontrolled xnlink
    ...    step4: check xnlink status and xnlinkref updated for selected NRADJGNB,
    ...    and check xnlink and NRADJGNB cleanup
    ...    step5: trigger xn setup from local gnbid mismatch NRADJGNB-12 by xnlinkref and with gnbcontrolled xnlink
    ...    step6: check xnlink status and xnlinkref2 updated for selected NRADJGNB,
    ...    and check xnlink and NRADJGNB cleanup
    [Tags]
    Created gnbControlled xnlink
    OnlineParamChange    ${delta_for_case6_1}
    Check Xnlink setup with new selected NRADJGNB by Xnlinref and cleanup previous NRADJGNB and xnlinks    new_nradjgnb=2
    ...    pre_nradjgnb=1    xnlink_id=20    conflict_xnlink_id_1=5    conflict_xnlink_id_2=6
    Check Xnlink setup with new selected NRADJGNB by Xnlinref and cleanup previous NRADJGNB and xnlinks    new_nradjgnb=4
    ...    pre_nradjgnb=3    xnlink_id=21    conflict_xnlink_id_1=8    conflict_xnlink_id_2=9
    Check Xnlink setup with new selected NRADJGNB by Xnlinref and cleanup previous NRADJGNB and gnbcontoled xnlinks    new_nradjgnb=11
    ...    pre_nradjgnb=10    xnlink_id=22    delete_xnlink_id_1=1    delete_xnlink_id_2=2
    Check Xnlink setup with new selected NRADJGNB by Xnlinref2 and cleanup previous NRADJGNB and gnbcontoled xnlinks    new_nradjgnb=13
    ...    pre_nradjgnb=12    xnlink_id=23    delete_xnlink_id_1=3    delete_xnlink_id_2=4
    [Teardown]    Recover Env And Test Teardown

5GC001719-B-B2_ET_07_01_Local gNB establish xnlink by new selected NRADJGNB with no xnlinkRef2 configured When XN Setup start from Local
    [Documentation]
    ...    CB010672 changed the behavior when xnlinkRef2 is empty ,xnlinkref will be selected when conflicting
    ...    step1: trigger xn setup from local gnbid mismatch NRADJGNB-1 by xnlinkref
    ...    step2: check xnlink status and xnlinkref updated for selected NRADJGNB,
    ...    and check xnlink and NRADJGNB cleanup
    ...    step3: trigger xn setup from local gnbid mismatch NRADJGNB-3 by xnlinkref
    ...    step4: check xnlink status and xnlinkref updated for selected NRADJGNB,
    ...    and check xnlink and NRADJGNB cleanup
    ...    step5: trigger xn setup from local gnbid mismatch NRADJGNB-5 by xnlinkref
    ...    step6: check xnlink status and xnlinkref updated for selected NRADJGNB,
    ...    and check xnlink and NRADJGNB cleanup
    [Tags]
    OnlineParamChange    ${delta_for_case7}
    Check Xnlink setup with new selected NRADJGNB by Xnlinref and cleanup previous NRADJGNB    new_nradjgnb=2
    ...    pre_nradjgnb=1    xnlink_id=1    conflict_xnlink_id=4
    Check Xnlink setup with new selected NRADJGNB by Xnlinref and cleanup previous NRADJGNB    new_nradjgnb=4
    ...    pre_nradjgnb=3    xnlink_id=2    conflict_xnlink_id=6
    Check Xnlink setup with new selected NRADJGNB by Xnlinref and cleanup previous NRADJGNB    new_nradjgnb=6
    ...    pre_nradjgnb=5    xnlink_id=3    conflict_xnlink_id=8
    [Teardown]    Recover Env And Test Teardown

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env  tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Modify Cfg
    ${V_1}    catenate
    ...    set_gnb id=2 type=external plmn=311:489  ng=10.0.1.2 gnb_id=0x76C daemon=10.0.2.1:22222 x2_peers=none
    ...    xn=10.0.1.2 amf=1 plmnList=311:489 nssai=0x1:0xd143a5
    ${V_2}    catenate
    ...    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.123 gnb_id=0x24:22 daemon=10.0.2.1:22222 x2_peers=none
    ...    xn=10.0.1.122 nssai=0x1:0xd143a5 amf=1
    ${V_3}    catenate
    ...    set_gnb id=4 type=simulated plmn=311:489 ng=10.0.1.125 gnb_id=0x25:22 daemon=10.0.2.1:22222 x2_peers=none
    ...    xn=10.0.1.124 nssai=0x1:0xd143a5 amf=1
    ${V_4}    catenate
    ...    set_gnb id=5 type=simulated plmn=311:489 ng=10.0.1.127 gnb_id=0x26:22 daemon=10.0.2.1:22222 x2_peers=none
    ...    xn=10.0.1.126 nssai=0x1:0xd143a5 amf=1
    ${V_5}    catenate
    ...    set_gnb id=6 type=simulated plmn=311:489 ng=10.0.1.129 gnb_id=0x27:22 daemon=10.0.2.1:22222 x2_peers=none
    ...    xn=10.0.1.128 nssai=0x1:0xd143a5 amf=1
    ${V_6}    catenate
    ...    set_gnb id=7 type=simulated plmn=311:489 ng=10.0.1.131 gnb_id=0x28:22 daemon=10.0.2.1:22222 x2_peers=none
    ...    xn=10.0.1.130 nssai=0x1:0xd143a5 amf=1
    ${V_7}    catenate
    ...    set_gnb id=8 type=simulated plmn=311:489 ng=10.0.1.141 gnb_id=0x29:22 daemon=10.0.2.1:22222 x2_peers=none
    ...    xn=10.0.1.132 nssai=0x1:0xd143a5 amf=1
    ${V_8}    catenate
    ...    set_gnb id=9 type=simulated plmn=311:489 ng=10.0.1.139 gnb_id=0x2a:22 daemon=10.0.2.1:22222 x2_peers=none
    ...    xn=10.0.1.140 nssai=0x1:0xd143a5 amf=1
    ${V_9}    catenate
    ...    set_gnb id=10 type=simulated plmn=311:489 ng=10.0.1.143 gnb_id=0x2b:22 daemon=10.0.2.1:22222 x2_peers=none
    ...    xn=10.0.1.138 nssai=0x1:0xd143a5 amf=1
    Update Cfg    ${V_1}
    Update Cfg    ${V_2}
    Update Cfg    ${V_3}
    Update Cfg    ${V_4}
    Update Cfg    ${V_5}
    Update Cfg    ${V_6}
    Update Cfg    ${V_7}
    Update Cfg    ${V_8}
    Update Cfg    ${V_9}
    FOR    ${gnb_id}    IN RANGE    3    11
        Update Cfg    gnb_param id=${gnb_id} xn_listening_socket=1 send_xn_setup=true
    END
    Update Cfg
    ...    set_cell id=1 gnb=3 pci=16:0 tac=788 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=633364:633364 gscn=7845
    Update Cfg
    ...    set_cell id=1 gnb=4 pci=16:0 tac=788 nrci=0x01 tdd_cell=on proxy=10.0.2.91:9999 nr_arfcn=633364:633364 gscn=7845
    Update Cfg
    ...    set_cell id=1 gnb=5 pci=16:0 tac=788 nrci=0x01 tdd_cell=on proxy=10.0.2.92:9999 nr_arfcn=633364:633364 gscn=7845
    Update Cfg
    ...    set_cell id=1 gnb=6 pci=16:0 tac=788 nrci=0x01 tdd_cell=on proxy=10.0.2.93:9999 nr_arfcn=633364:633364 gscn=7845
    Update Cfg
    ...    set_cell id=1 gnb=7 pci=16:0 tac=788 nrci=0x01 tdd_cell=on proxy=10.0.2.94:9999 nr_arfcn=633364:633364 gscn=7845
    Update Cfg
    ...    set_cell id=1 gnb=8 pci=16:0 tac=788 nrci=0x01 tdd_cell=on proxy=10.0.2.95:9999 nr_arfcn=633364:633364 gscn=7845
    Update Cfg
    ...    set_cell id=1 gnb=9 pci=16:0 tac=788 nrci=0x01 tdd_cell=on proxy=10.0.2.96:9999 nr_arfcn=633364:633364 gscn=7845
    Update Cfg
    ...    set_cell id=1 gnb=10 pci=16:0 tac=788 nrci=0x01 tdd_cell=on proxy=10.0.2.97:9999 nr_arfcn=633364:633364 gscn=7845

Trigger Xn Setup From Remote GNB
    [Arguments]    ${gnb_id}=3
    Execute Egate Command    gnb_param id=${gnb_id} send_xn_setup=true
    Execute Egate Command    gnb_xn_link_up gnb=${gnb_id} target=2    GNB-${gnb_id}: XnAP Link with GNB-2

Check Xnlink available By XnlinkRef
    [Arguments]    ${xnlinkref}=xnLinkRef    ${NRAGJGNB_id}=0    ${xnlink_id}=0
    ...    ${gNodeBIdCtrl}=oamControlled    ${cPlaneIpAddrCtrl}=oamControlled
    Object Should Exist    NRADJGNB-${NRAGJGNB_id}:${xnlinkref}=${xnlink_id}
    Object Should Exist    NRADJGNB-${NRAGJGNB_id}:gNodeBIdCtrl=${gNodeBIdCtrl}
    Object Should Exist    XNLINK-${xnlink_id}:xnLinkStatus=available
    Object Should Exist    XNLINK-${xnlink_id}:cPlaneIpAddrCtrl=${cPlaneIpAddrCtrl}

Check Xnlink Status Change To Conflict
    [Arguments]    ${xnlink_id}=0
    Object Should Exist    XNLINK-${xnlink_id}:xnLinkStatus=conflicting

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${False}

Recover Env And Test Teardown
    Delta Commission Parameters    ${clean_NRADJGNB_XNLINK}
    Fm Fault Should Be Cleared    fault_id=${7311_fault_id}
    Common Test Teardown And Stop Capture Logs

Check Fault 7311 Raised
    [Arguments]    ${nradjgnb_id}
    ${fault}  Create List    fault_id=${7311_fault_id}    alarm_id=${7311_alarm_id}    severity=Major
    ...    alarming_object=MRBTS-1/NRBTS-1/NRADJGNB-${nradjgnb_id}
    ...    fault_name=${7311_fault_name}
    Fm Fault Should Be Raised    ${fault}    40

Created gnbControlled xnlink
    Trigger Xn Setup From Remote GNB    gnb_id=7
    Trigger Xn Setup From Remote GNB    gnb_id=8
    Trigger Xn Setup From Remote GNB    gnb_id=9
    Trigger Xn Setup From Remote GNB    gnb_id=10
    Check Xnlink available By XnlinkRef    NRAGJGNB_id=1   xnlink_id=1    gNodeBIdCtrl=gnbControlled    cPlaneIpAddrCtrl=gnbControlled
    Check Xnlink available By XnlinkRef    NRAGJGNB_id=2    xnlink_id=2    gNodeBIdCtrl=gnbControlled    cPlaneIpAddrCtrl=gnbControlled
    Check Xnlink available By XnlinkRef    NRAGJGNB_id=3    xnlink_id=3    gNodeBIdCtrl=gnbControlled    cPlaneIpAddrCtrl=gnbControlled
    Check Xnlink available By XnlinkRef    NRAGJGNB_id=4    xnlink_id=4    gNodeBIdCtrl=gnbControlled    cPlaneIpAddrCtrl=gnbControlled
    OnlineParamChange    ${clean_gnbcontolled_NRADJGNB}

Check Xnlink not exist
    [Arguments]    ${xnlink_id}
    Object Should Not Exist    XNLINK-${xnlink_id}:cPlaneIpAddrCtrl=gnbControlled

CHeck Xnlink setup with new selected NRADJGNB by Xnlinref2 and cleanup previous NRADJGNB
    [Arguments]    ${new_nradjgnb}    ${pre_nradjgnb}    ${xnlink_id}    ${conflict_xnlink_id}
    Check Xnlink available By XnlinkRef    xnlinkref=xnLinkRef2    NRAGJGNB_id=${new_nradjgnb}    xnlink_id=${xnlink_id}
    Check Fault 7311 Raised    nradjgnb_id=${pre_nradjgnb}
    Check Xnlink Status Change To Conflict    xnlink_id=${conflict_xnlink_id}

CHeck Xnlink setup with new selected NRADJGNB by Xnlinref and cleanup previous NRADJGNB
    [Arguments]    ${new_nradjgnb}    ${pre_nradjgnb}    ${xnlink_id}    ${conflict_xnlink_id}
    Check Xnlink available By XnlinkRef    NRAGJGNB_id=${new_nradjgnb}    xnlink_id=${xnlink_id}
    Check Fault 7311 Raised    nradjgnb_id=${pre_nradjgnb}
    Check Xnlink Status Change To Conflict    xnlink_id=${conflict_xnlink_id}

Check Xnlink setup with new selected NRADJGNB by Xnlinref and cleanup previous NRADJGNB and xnlinks
    [Arguments]    ${new_nradjgnb}    ${pre_nradjgnb}    ${xnlink_id}    ${conflict_xnlink_id_1}    ${conflict_xnlink_id_2}
    Check Xnlink available By XnlinkRef    NRAGJGNB_id=${new_nradjgnb}    xnlink_id=${xnlink_id}
    Check Fault 7311 Raised    nradjgnb_id=${pre_nradjgnb}
    Check Xnlink Status Change To Conflict    xnlink_id=${conflict_xnlink_id_1}
    Check Xnlink Status Change To Conflict    xnlink_id=${conflict_xnlink_id_2}

Check Xnlink setup with new selected NRADJGNB by Xnlinref and cleanup previous NRADJGNB and gnbcontoled xnlinks
    [Arguments]    ${new_nradjgnb}    ${pre_nradjgnb}    ${xnlink_id}    ${delete_xnlink_id_1}    ${delete_xnlink_id_2}
    Check Fault 7311 Raised    nradjgnb_id=${pre_nradjgnb}
    Check Xnlink available By XnlinkRef    NRAGJGNB_id=${new_nradjgnb}    xnlink_id=${xnlink_id}
    Check Xnlink not exist    xnlink_id=${delete_xnlink_id_1}
    Check Xnlink not exist    xnlink_id=${delete_xnlink_id_2}

Check Xnlink setup with new selected NRADJGNB by Xnlinref2 and cleanup previous NRADJGNB and gnbcontoled xnlinks
    [Arguments]    ${new_nradjgnb}    ${pre_nradjgnb}    ${xnlink_id}    ${delete_xnlink_id_1}    ${delete_xnlink_id_2}
    Check Fault 7311 Raised    nradjgnb_id=${pre_nradjgnb}
    Check Xnlink available By XnlinkRef    xnlinkref=xnLinkRef2    NRAGJGNB_id=${new_nradjgnb}    xnlink_id=${xnlink_id}
    Check Xnlink not exist    xnlink_id=${delete_xnlink_id_1}
    Check Xnlink not exist    xnlink_id=${delete_xnlink_id_2}
