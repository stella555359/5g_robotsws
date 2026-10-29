*** Settings ***
Resource    CB013206_keywords.robot

Documentation
...    author: Paweł Konieczny
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    release: 24R3

*** Variables ***
${TRAFFIC_DURATION_SEC}=   10s

*** Keywords ***
CB013206-C_Abnorm_Sgnb_Insession_Release_Pmqap
    Attach Ue To Enb    ue_id=11
    Start Gnb Addition Procedure    ue=11    bearer=2    target_cells=1    dc_type=split_scg
    Start Dl And Ul Data Traffic And Display Bearer Stats
    Perform Abnormal Releases Initiated By Sgnb
    Check In Session Status    status=True
    Check Pm Counters For Abnormal Releases Initiated By Sgnb
    Check Pmqap Pm Counter For Abnormal Releases Initiated By Sgnb
    Detach Ue    ue_id=11

Enable Pmqap Moc Nsa Qci6
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Pm_counters/delta_enable_Pmqap_Moc_Nsa_Qci6.json

Check Pmqap Pm Counter For Abnormal Releases Initiated By Sgnb
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_RAB_REL_ABNRM_SGNB_INSES_PMQAP}
    ...    value=1    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    filepath=${PM_COUNTERS}
