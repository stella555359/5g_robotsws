*** Setting ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_TDD    RAN_4G    RAN_4G_TDD    CIT
...               CLOUD_R4P    owner-zhiguo.li,annie.nie    OAM2    release-SBTS16    team-CN3ET
Resource          ../../../resources/DevHZ5_resource.robot

*** Variable ***
@{PARAMS_IN_SCF}
...    LNBTS:actSelMobPrf=true
...    LNBTS:moProfileSelect=spid
...    LNBTS:actIfHo=enabled
...    LNBTS:actRedirect=disabled
...    LNBTS:actCSFBRedir=Disabled
...    LNBTS/LNADJ-1:cPlaneIpAddr=10.0.1.31
...    LNBTS/MOPR-1:freqLayListLte=38000
...    LNCEL-1/LNCEL_TDD-0:earfcn=38100
...    LNCEL-1:inactivityTimer=1000
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=38000
...    LNCEL-1:moPrMappingList:mcc=262|moPrId=1
...    LNCEL-1:moPrMappingList:mnc=3|moPrId=1
...    LNCEL-1:moPrMappingList:mncLength=2|moPrId=1
...    LNCEL-1:moPrMappingList:spid=100|moPrId=1
...    LNCEL-1:moPrMappingList:spidLast=101|moPrId=1
@{RedirectTargetInMored}
...    LNBTS:moProfileSelect=plmn
...    LNBTS:actIfHo=disabled
...    MOPR-1/MORED-1:redirRAT=utraFDD
...    MOPR-1/MORED-1:redirFreqUtra=1500
...    MOPR-2:idleLBPercentageOfUes=0
...    MOPR-2/MORED-1:redirRAT=utraFDD
...    MOPR-2/MORED-1:redirFreqUtra=1501
...    LNCEL-1/REDRT-1:redirRat=utraFDD
...    LNCEL-1/REDRT-1:redirFreqUtra=1502
...    LNCEL-1:moPrMappingList:mcc=262|moPrId=1
...    LNCEL-1:moPrMappingList:mnc=3|moPrId=1
...    LNCEL-1:moPrMappingList:mncLength=2|moPrId=1
...    LNCEL-1:moPrMappingList:spid=100|moPrId=1
...    LNCEL-1:moPrMappingList:spidLast=101|moPrId=1
...    LNCEL-1:moPrMappingList:mcc=262|moPrId=2
...    LNCEL-1:moPrMappingList:mnc=4|moPrId=2
...    LNCEL-1:moPrMappingList:mncLength=2|moPrId=2
...    LNCEL-1:moPrMappingList:spid=200|moPrId=2
...    LNCEL-1:moPrMappingList:spidLast=201|moPrId=2
...    LNCEL-1:furtherPlmnIdL:mcc=262
...    LNCEL-1:furtherPlmnIdL:mnc=4
...    LNCEL-1:furtherPlmnIdL:mncLength=2
...    delete:LNCEL:a2TimeToTriggerActInterFreqMeas
...    delete:LNCEL-1:threshold2aHpue
@{ActivateRedirect}
...    LNBTS:actRedirect=enabled
...    @{RedirectTargetInMored}
@{RemoveRedirectTargetInMored}
...    LNBTS:moProfileSelect=spid
...    LNBTS:actIfHo=enabled
...    LNCEL:a2TimeToTriggerActInterFreqMeas=480ms
...    delete:MOPR-2
...    delete:LNCEL-1:moPrMappingList:moPrId=2
...    LNCEL-1:furtherPlmnIdL:mcc=262
...    LNCEL-1:furtherPlmnIdL:mnc=2
...    LNCEL-1:furtherPlmnIdL:mncLength=2
@{DeactivateRedirect}
...    LNBTS:actRedirect=disabled
...    @{RemoveRedirectTargetInMored}
${UeCapabilityForRedirect}    C59FF419B2C10381FFFFFFFFF2022082008295010000
${PLMN1}          262:03
${PLMN2}          262:04
${redirecinfo1}    releaseCause eq "other" and redirectedCarrierInfo contains (utra-FDD eq 1500)
${redirecinfo2}    releaseCause eq "other" and redirectedCarrierInfo contains (utra-FDD eq 1501)
${no_redirecinfo1}    redirectedCarrierInfo contains (utra-FDD eq 1501) or redirectedCarrierInfo contains (utra-FDD eq 1502)
${no_redirecinfo2}    redirectedCarrierInfo contains (utra-FDD eq 1500) or redirectedCarrierInfo contains (utra-FDD eq 1502)
*** Test Case ***
LTE486_01_08_RRC Connection Release with Redirect_virtual SPID mapped
    [Documentation]    LTE486_01_08 RRC Connection Release with Redirect_virtual SPID mapped. Need MO: MOPR/MORED, actRedirect=enabled. Enable 490
    ...    and 486 feature, and UE with two different PLMN mapping to different MOPR
    [Tags]
    Set Further PLMN
    Activate Redirect And Configure Target    ${ActivateRedirect}
    L3 Call With Redirect    ${PLMN1}    ${redirecinfo1}    ${no_redirecinfo1}
    L3 Call With Redirect    ${PLMN2}    ${redirecinfo2}    ${no_redirecinfo2}
    [Teardown]    Deactivate Redirect And Remove Target

*** Keyword ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs
    Create Alias
    execute egate command    trace_sim on mme=1 protocol=s1
    execute egate command    trace uec=1 protocol=rrc on

Create Alias
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts

Modify Yaml
    add yaml    EPC/MME_POOL_AREA
    ...    - id: 2
    ...      plmn: '262:04'
    ...      mmegi: 2
    ...      tac_list: 33

Set Further PLMN
    execute egate command    mme_config_update pool=1:3 pool=2:4 relative_cap=2
    execute egate command    mme_disp id=1 type=enb_info enb=1

Activate Redirect And Configure Target
    [Arguments]    ${param}=${EMPTY}
    [Documentation]    Activate Redirect / CSFB / interFreqHo / interRatHo feature flag and configure related object including MOPR / MORED / freqLay
    ...    Li
    ...    stLte / freqLayListRat / MODPR / MODRED / REDRT / LNHOIF / LNHOW, if need to add multi value in a list that can be separated by commas suc
    ...    has "MOPR-1:freqLayListPsHoWcdma=1500,1501".
    Delta Commission Parameters    ${param}
    cells should be onair

L3 Call With Redirect
    [Arguments]    ${plmn}=262:03    ${redirecinfo}=${redirecinfo1}    ${no_redirecinfo}=${no_redirecinfo1}}
    execute egate command    ue_mme_param id=1 spid=100
    expect message flow
    ...    UE_1:RRC_RRCConnectionReconfigurationComplete    alias=attach_ok    overall_timeout=20
    execute uex command    ue_attach id=1 cell=1 ue_eutra_capabilities=${UeCapabilityForRedirect} selected_plmn=${plmn}
    flow occurred as expected    alias=attach_ok
    expect message flow
    ...    UE_1:RRC_RRCConnectionRelease (${redirecinfo})
    ...    alias=redirect_car    overall_timeout=30
    expect message will not occur
    ...    UE_1:RRC_RRCConnectionRelease (${no_redirecinfo})
    ...    alias=no_redirect    overall_timeout=30
    execute uex command    ue_measurement_send id=1 event=A2 srsrp=10 srsrq=10
    flow occurred as expected    alias=redirect_car
    flow not occurred for message    alias=no_redirect
    execute uex command    ue_detach id=1

Deactivate Redirect And Remove Target
    Delta Commission Parameters    ${DeactivateRedirect}
    Common Test Teardown And Stop Capture Logs



