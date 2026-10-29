*** Settings ***
Documentation
...        maintainer:   Karol Rybak
...        contact:      karol.rybak@nokia.com
...        author:       Karol Rybak
...        description:  Test Cases for CB009884-F

Resource    ./resources/CB009884_KW.robot

Suite Setup  Prepare suite environment  egate_config=${lua_cfg_file}  x2=False
Suite Teardown  Clean suite environment

Force Tags    CONFIGURED    CRT    PY39    RAN_5G    RAN_5G_TDD    SBTS00
    ...    CLOUD_5G_I_BOO_AP_LOO

*** Variables ***
${lua_cfg_file}=  ${CONF_DIR}/egate_SA.cfg

*** Test Cases ***
CB009884_F_CBRA_Success_Rate_KPI_excluding_Ghost_preambles_FR2_SA_Proc_1
    [Setup]  Prepare test environment
    Wait For Next Full Pm Interval
    Activate missed rach testmodel  ue_id_first=1  ue_id_last=3
    Attach UE SA  ue_id_first=1  ue_id_last=3  pdu=1

    ${pm_counters}=  Wait for next pm interval and get counters
    Run Keyword And Continue On Failure  Verify Last Counters In File
    ...    M55306C06001    2           RA_MSG3_RECEP
    ...    M55306C03001    12          RA_COMP_CONT_A_PRMBL
    ...    M55306C10005    10          RA_CBRA_INI_MSG3_DTX
    ...    M55306C00001    12          RA_ATT_CONT_A_PRMBL_SSB_00
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

#    ${pm_counters}=  get latest unpacked full pm counters file
#    Run Keyword And Continue On Failure  Verify Last Counters In File
#    ...    M55202C00005    5           CBRA_INI_MSG3_DTX_SSBPM
#    ...    M55202C00003    6           CBRA_ATT_SSBPM
#    ...    M55202C00004    1           CBRA_MSG3_RECEP_SSBPM
#    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
#    ...    local_moid=PLMN-PLMN/SSBPM-0
#    ...    file_path=${pm_counters}

    Detach UE SA  ue_id_first=1  ue_id_last=3
    [Teardown]    Run Keyword And Ignore Error    Add Main BTS Metadata to Report




