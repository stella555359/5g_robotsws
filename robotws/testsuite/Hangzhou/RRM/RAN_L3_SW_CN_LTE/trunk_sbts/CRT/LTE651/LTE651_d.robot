*** Settings ***
Documentation     LTE651 drop of active radio bearers \ \ \ # drops for active E-RABs with QCI 1..9 \ \ \ # drops for active E-RABs accumulated non-G
...               BR \ \ \ # in-session activity time for E-RABs with QCI 1..4 and accumulated non-GBR \ \ \ # number of eNB initiated release due to
...               loss of UE connection \ \ \ # number of established + released by detach data bearers
...
...               ... \ \ \ \ \ \ \ \ \ \ \ \ \ \ PM Counters for activity time and call drops per QCI are checked.
...
...               ... \ \ \ \ \ \ \ \ \ \ \ \ \ \ ERAB_IN_SESSION_TIME_QCIx:
...               ... \ \ \ \ \ \ \ \ \ \ \ \ \ \ This measurement provides the aggregated in-session activity time in seconds for
...               ... \ \ \ \ \ \ \ \ \ \ \ \ \ \ all E-RABs with QCI2 characteristics. The E-RAB is said to be "in session" if any
...               ... \ \ \ \ \ \ \ \ \ \ \ \ \ \ user data has been transferred in UL or DL direction within the last 100msec.
...
...               ... \ \ \ \ \ \ \ \ \ \ \ \ \ \ ERAB_REL_ENB_ACT_QCIx:
...               ... \ \ \ \ \ \ \ \ \ \ \ \ \ \ This measurement provides the number of released active E-RABs (that is when there
...               ... \ \ \ \ \ \ \ \ \ \ \ \ \ \ was user data in the queue at the time of release) with QCI1 characteristics. The
...               ... \ \ \ \ \ \ \ \ \ \ \ \ \ \ release is initiated by the eNB due to radio connectivity problems.
...
...               ... \ \ \ \ \ \ \ \ \ \ \ \ \ \ Bearers with different QCIs are established and data is sent in UL, DL or both directions, then UE
...               link is dropped.
...
...               ... \ \ \ \ \ \ \ \ \ \ \ \ \ \ Cell 1/ UE1:
...               ... \ \ \ \ \ \ \ \ \ \ \ \ \ \ Established QCIs: 1, 2, 5, 6, 8 (default)
...               ... \ \ \ \ \ \ \ \ \ \ \ \ \ \ Data sent on QCI/Direction: 1, 6, 8 / DL
...               ... \ \ \ \ \ \ \ \ \ \ \ \ \ \ Drop during active time: yes, after 20s
...
...               ... \ \ \ \ \ \ \ \ \ \ \ \ \ \ Cell 2/ UE2:
...               ... \ \ \ \ \ \ \ \ \ \ \ \ \ \ Established QCIs: 3, 4, 7, 8 (default), 9
...               ... \ \ \ \ \ \ \ \ \ \ \ \ \ \ Data sent on QCI/Direction: 4, 7 / UL
...               ... \ \ \ \ \ \ \ \ \ \ \ \ \ \ Drop during active time: yes, after 20s
...               ... \ \ \ \ \ \ \ \ \ \ \ \ \ \ Cell 3/ UE3:
...               ... \ \ \ \ \ \ \ \ \ \ \ \ \ \ Established QCIs: 1, 4, 5, 8 (default), 9
...               ... \ \ \ \ \ \ \ \ \ \ \ \ \ \ Data sent on QCI/Direction: 4, 5, 8, 9 / DL; 1, 4, 5, 8 / UL
...               ... \ \ \ \ \ \ \ \ \ \ \ \ \ \ Drop during active time: yes, after 20s
...               ... \ \ \ \ \ \ \ \ \ \ \ \ \ \ Cell 4/ UE4:
...               ... \ \ \ \ \ \ \ \ \ \ \ \ \ \ Established QCIs: 2, 4, 8 (default)
...               ... \ \ \ \ \ \ \ \ \ \ \ \ \ \ Data sent on QCI/Direction: 8 / DL; 2 / UL
...               ... \ \ \ \ \ \ \ \ \ \ \ \ \ \ Drop during active time: No
Suite Setup       Common Suite Setup And Setup Cus Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CLOUD_R4LAPO_CUS    CRT
...               DevHZ5_SG4    owner-bobsong    release-xL18
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...  LNBTS-1:qciTab1:lcgid=1
...  LNBTS-1:qciTab2:lcgid=2
...  LNBTS-1:qciTab3:lcgid=2
...  LNBTS-1:qciTab4:lcgid=2
...  LNBTS-1:qciTab5:lcgid=2
...  LNBTS-1:qciTab6:lcgid=3
...  LNBTS-1:qciTab7:lcgid=3
...  LNBTS-1:qciTab8:lcgid=3
...  LNBTS-1:qciTab9:lcgid=3
...  @{PARAMS_FOR_PMQAP}
...  LNBTS-1:actFlexQCIARPPMProfiles=true
...  LNBTS-1:actQCIPLMNIDProfiles=false
...  LNBTS-1:rlcProf1:maxRetxThresh=t1
...  LNBTS-1:rlcProf2:maxRetxThresh=t1
...  LNBTS-1:rlcProf3:maxRetxThresh=t1
...  LNCEL-1/SIB-0:t310=2000ms
...  LNCEL-1/SIB-0:t311=5000ms
@{PARAMS_FOR_PMQAP}
...  LNBTS-1/PMRNL-1/PMQAP-1:cfgQCIRange=1-4
...  LNBTS-1/PMRNL-1/PMQAP-1:cfgPRI=20
...  delete:LNBTS-1/PMRNL-1/PMQAP-1:cfgARPRange
...  delete:LNBTS-1/PMRNL-1/PMQAP-1:cfgUECategory
...  delete:LNBTS-1/PMRNL-1/PMQAP-1:pLMNID
...  LNBTS-1/PMRNL-1/PMQAP-2:cfgQCIRange=5-9
...  LNBTS-1/PMRNL-1/PMQAP-2:cfgPRI=20
...  LNBTS-1/PMRNL-1/PMQAP-2:cfgARPRange=${empty}
...  LNBTS-1/PMRNL-1/PMQAP-2:cfgUECategory=${empty}
...  LNBTS-1/PMRNL-1/PMQAP-2:pLMNID=${empty}
...  MNL-1/MNLENT-1/PMCADM-1:reportingIntervalPm=15min
...  LNBTS-1/PMRNL-1:mtERABPMQAPProfile=15min
...  LNBTS-1/PMRNL-1:mtDataVolThrPMQAPProfile=15min
...  LNBTS-1/PMRNL-1:mtActUsersLatencyPMQAPProfile=15min
...  LNBTS-1/PMRNL-1:mtRLFPMQAPProfile=15min
${V_1}
...  SEPARATOR=
...  c9b80488001040a208922864448ff85e47fc2f23fe1791ff0bc8ff85e47fc2f23fe1791ff0bc8ff85dfc3f728a0040334400e0b00000000017
...  104008000010800022000045000090000144000290000540000b2001123fe1791ff0bc8ff85e47fc2f23fe1791ff0bc8ff85e47fc2f23fe172
...  82000000
${V_2}
...  SEPARATOR=
...  c9b80488001040a208922864448ff85e47fc2f23fe1791ff0bc8ff85e47fc2f23fe1791ff0bc8ff85dfc3f728a0040334400e0b00000000017
...  104008000010800022000045000090000144000290000540000b2001123fe1791ff0bc8ff85e47fc2f23fe1791ff0bc8ff85e47fc2f23fe172
...  82000000
${V_3}
...  SEPARATOR=
...  c9b80488001040a208922864448ff85e47fc2f23fe1791ff0bc8ff85e47fc2f23fe1791ff0bc8ff85dfc3f728a0040334400e0b00000000017
...  104008000010800022000045000090000144000290000540000b2001123fe1791ff0bc8ff85e47fc2f23fe1791ff0bc8ff85e47fc2f23fe172
...  82000000
${V_4}
...  SEPARATOR=
...  c9b80488001040a208922864448ff85e47fc2f23fe1791ff0bc8ff85e47fc2f23fe1791ff0bc8ff85dfc3f728a0040334400e0b00000000017
...  104008000010800022000045000090000144000290000540000b2001123fe1791ff0bc8ff85e47fc2f23fe1791ff0bc8ff85e47fc2f23fe172
...  82000000

*** Test Cases ***
LTE651_d_01 Verification of PM counters for E-Rab Drop
    [Tags]
    Clear Counter files
    Start Rtpm Counter
    Cus UE attach to eNB1    ueid=${UE1}    ue_eutra_capabilities=${V_1}
    Establish Bearers With QCI 1, 2, 5, 6 And Start DL Traffic
    UE Entry Idle Mode
    Wait Rtpm Counter Collection
    Check Rtpm Counters    pm_reference_file=${CURDIR}${/}PM${/}PM_counters_reference_LTE651_d_01.txt

*** Keywords ***
Common Suite Setup And Setup Cus Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc,s1,x2 on
    Create Alias

Create Alias
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create mme alias    MME_1    mme_id=1    id_type=wts
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts

Cus UE attach to eNB1
    [Arguments]    ${ueid}=1    ${cellid}=1    ${ue_eutra_capabilities}=${ue_eutra_capabilities}    ${sleeptime}=0
    Execute Uex Command    ue_param id=${ueid} csfb_rat=utran_geran voice_domain_preference=lte_preferred
    Execute Uex Command    ue_param id=${ueid} ue_eutra_capabilities=${ue_eutra_capabilities}
    Execute Uex Command    ue_attach id=${ueid} cell=${cellid} selected_plmn=262:03
    sleep    ${sleeptime}

Establish Bearers With QCI 1, 2, 5, 6 And Start DL Traffic
    [Arguments]    ${ue}=${UE1}
    Execute Uex Command    bearer_add ue=${UE1} qci=1 mbr_ul=31 mbr_dl=31 gbr_dl=31 gbr_ul=31         # QCI=1 setup successfully
    Execute Uex Command    bearer_add ue=${UE1} qci=2 gbr_ul=144 gbr_dl=144 mbr_ul=144 mbr_dl=144    # QCI=2 setup successfully
    Execute Uex Command    bearer_add ue=${UE1} qci=5                                                # QCI=5 setup successfully
    Execute Uex Command    bearer_add ue=${UE1} qci=6                                                # QCI=6 setup successfully
    Execute Uex Command    trf_data_start ue=${UE1} qci=1 dir=dl protocol=udp Mbps=60 stats=true     #QCI1
    Execute Uex Command    trf_data_start ue=${UE1} qci=6 dir=dl protocol=udp Mbps=40 stats=true    # QCI6
    Execute Uex Command    trf_data_start ue=${UE1} qci=8 dir=dl protocol=udp Mbps=40 stats=true    # #QCI8
    Inquiry UE Throughput
    Sleep    15s    #sustained data for counter statistics
    Inquiry UE Throughput

Inquiry UE Throughput
    Execute Uex Command    ue_stats id=1 type=dl_mac scell=0..7 unit=kbps
    Execute Uex Command    ue_stats id=1 type=ul_mac scell=0..7 unit=kbps

UE Entry Idle Mode
    Expect Message Flow
    ...    MME_1:S1AP_UEContextReleaseComplete
    ...    alias=LTE651_d_01_flow    overall_timeout=20
    Execute Uex Command    ue_im_entry id=1
    Flow Occurred As Expected    alias=LTE651_d_01_flow
    Sleep    20s
    Execute Uex Command    ue_detach id=1

Wait Rtpm Counter Collection
    sleep    10s

