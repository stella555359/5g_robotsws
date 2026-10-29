*** Settings ***
Documentation
...        maintainer:   Karol Rybak
...        contact:      karol.rybak@nokia.com
...        author:       Karol Rybak
...        description:  Test Cases for CB009884-F

Resource    ./resources/CB009884_KW.robot

Suite Setup  Prepare suite environment  egate_config=${lua_cfg_file}  x2=True
Suite Teardown  Clean suite environment

Force Tags    CONFIGURED    CRT    PY39    RAN_5G    RAN_5G_TDD    SBTS00
    ...    CLOUD_5G_I_BOO_AP_LOO

*** Variables ***
${lua_cfg_file}=  ${CONF_DIR}/egate_NSA.lua

*** Test Cases ***
CB009884_F_CBRA_Success_Rate_KPI_excluding_Ghost_preambles_FR2_NSA_Proc_3
    [Setup]  Prepare test environment
    Wait For Next Full Pm Interval
    Activate msg3 retx testmodel  ue_id_first=1  ue_id_last=3
    Attach UE NSA  ue_id_first=1  ue_id_last=3

    ${pm_counters}=  Wait for next pm interval and get counters
    Run Keyword And Continue On Failure  Verify Last Counters In File
    ...    M55306C00001    4           RA_ATT_CONT_A_PRMBL_SSB_00
    ...    M55306C03001    4           RA_COMP_CONT_A_PRMBL
    ...    M55306C10006    8           RA_CBRA_UL_GRANT_MSG3_RETX
    ...    M55306C10004    2           RA_CBRA_MSG3_RECV_DECODE_FAIL
    ...    M55306C06001    2           RA_MSG3_RECEP
    ...    M55306C10005    0           RA_CBRA_INI_MSG3_DTX
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

    Detach UE NSA  ue_id_first=1  ue_id_last=3
    [Teardown]    Run Keyword And Ignore Error    Add Main BTS Metadata to Report
