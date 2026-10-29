*** Settings ***
Documentation
...        maintainer:   Karol Rybak
...        contact:      karol.rybak@nokia.com
...        author:       Karol Rybak
...        description:  Test Cases for CB009267-A

Resource    ./resources/CB009267_KW.robot

Suite Setup  Prepare suite environment  egate_config=${lua_cfg_file}  x2=False
Suite Teardown  Clean suite environment

Force Tags    CONFIGURED    CRT    PY39    RAN_5G    RAN_5G_TDD    SBTS00
    ...    CLOUD_5G_I_BOO_AP_LOO

*** Variables ***
${lua_cfg_file}=  ${CURDIR}/config/egate_SA_D.cfg

*** Test Cases ***
CB009267_A_SA_CA_Counters_for_SCell_configuration_attempts_and_success
    Wait For Next Full Pm Interval
    Attach UE SA  ue_id_first=1  ue_id_last=9  pdu=1
    ${pm_counters}=  Wait for next pm interval and get counters
    Run Keyword And Continue On Failure  Verify Last Counters In File
    ...    M55138C03513    2            GNB_DL_SCELL_4_ADMI_REQ_SA
    ...    M55138C03514    2            GNB_DL_SCELL_5_ADMI_REQ_SA
    ...    M55138C03515    2            GNB_DL_SCELL_6_ADMI_REQ_SA
    ...    M55138C03516    2            GNB_DL_SCELL_7_ADMI_REQ_SA
    ...    M55138C03525    4            GNB_UL_SCELL_2_ADMI_REQ_SA
    ...    M55138C03526    4            GNB_UL_SCELL_3_ADMI_REQ_SA
#...
    ...    M55138C03520    2            GNB_DL_SCELL_4_ADMI_SUCC_SA
    ...    M55138C03521    2            GNB_DL_SCELL_5_ADMI_SUCC_SA
    ...    M55138C03522    2            GNB_DL_SCELL_6_ADMI_SUCC_SA
    ...    M55138C03523    2            GNB_DL_SCELL_7_ADMI_SUCC_SA
    ...    M55138C03528    4            GNB_UL_SCELL_2_ADMI_SUCC_SA
    ...    M55138C03529    4            GNB_UL_SCELL_3_ADMI_SUCC_SA
#...
    ...    M55118C11054    2            GNB_DL_SCELL_4_CONFIG_REQ_SA
    ...    M55118C11055    2            GNB_DL_SCELL_5_CONFIG_REQ_SA
    ...    M55118C11056    2            GNB_DL_SCELL_6_CONFIG_REQ_SA
    ...    M55118C11057    2            GNB_DL_SCELL_7_CONFIG_REQ_SA
    ...    M55118C11059    4            GNB_UL_SCELL_2_CONFIG_REQ_SA
    ...    M55118C11060    4            GNB_UL_SCELL_3_CONFIG_REQ_SA
#...
    ...    M55139C05505    2            GNB_DU_DL_SCELL_4_ADMI_REQ_SA
    ...    M55139C05506    2            GNB_DU_DL_SCELL_5_ADMI_REQ_SA
    ...    M55139C05507    2            GNB_DU_DL_SCELL_6_ADMI_REQ_SA
    ...    M55139C05508    2            GNB_DU_DL_SCELL_7_ADMI_REQ_SA
    ...    M55139C05517    4            GNB_DU_UL_SCELL_2_ADMI_REQ_SA
    ...    M55139C05518    4            GNB_DU_UL_SCELL_3_ADMI_REQ_SA
#...
    ...    M55139C05512    2            GNB_DU_DL_SCELL_4_ADMI_SUCC_SA
    ...    M55139C05513    2            GNB_DU_DL_SCELL_5_ADMI_SUCC_SA
    ...    M55139C05514    2            GNB_DU_DL_SCELL_6_ADMI_SUCC_SA
    ...    M55139C05515    2            GNB_DU_DL_SCELL_7_ADMI_SUCC_SA
    ...    M55139C05520    4            GNB_DU_UL_SCELL_2_ADMI_SUCC_SA
    ...    M55139C05521    4            GNB_DU_UL_SCELL_3_ADMI_SUCC_SA
#...
    ...    M55118C11064    2            GNB_DL_SCELL_4_CONFIG_SUCC_SA
    ...    M55118C11065    2            GNB_DL_SCELL_5_CONFIG_SUCC_SA
    ...    M55118C11066    2            GNB_DL_SCELL_6_CONFIG_SUCC_SA
    ...    M55118C11067    2            GNB_DL_SCELL_7_CONFIG_SUCC_SA
    ...    M55118C11069    4            GNB_UL_SCELL_2_CONFIG_SUCC_SA
    ...    M55118C11070    4            GNB_UL_SCELL_3_CONFIG_SUCC_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}
    Detach UE SA  ue_id_first=1  ue_id_last=9
    [Teardown]    Run Keyword And Ignore Error    Add Main BTS Metadata to Report





