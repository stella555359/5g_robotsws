*** Settings ***
Documentation
...        maintainer:   Karol Rybak
...        contact:      karol.rybak@nokia.com
...        author:       Karol Rybak
...        description:  Test Cases for CB009267-B

Resource    ./resources/CB009267_KW.robot

Suite Setup     Prepare suite environment    egate_config=${lua_cfg_file}  scfc=${scfc}
Suite Teardown  Clean suite environment

Force Tags    CONFIGURED    CRT    PY39    RAN_5G    RAN_5G_TDD    SBTS00
    ...    CLOUD_5G_I_BOO_AP_LOO
    ...    VARIANT_PRIVATE_MMWV_NSA_CA_8CC_DL_4CC_UL

*** Variables ***
${lua_cfg_file}=             ${CURDIR}/config/egate_NSA_D.lua
${scfc}=                     ${CURDIR}/config/scfc_B.xml

*** Test Cases ***
CB009267_B_Number_of_DL_and_UL_NSA_SCell_configuration_attempts_and_success_counters_for_all_type_of_CA
	[Setup]  Prepare test environment

	Set maxNumScellsUl to 3 and maxNumScellsDl to 7
    Wait for next full pm interval
    Attach UE NSA  ue_id_first=1  ue_id_last=13
    Trigger PSCell change
	${pm_counters}=  Wait for next pm interval and get counters
	Run Keyword And Continue On Failure  Verify Last Counters In File
	...    M55114C01510    2             SGNB_DL_SCELL_2_ADMI_REQ
    ...    M55114C01511    2             SGNB_DL_SCELL_3_ADMI_REQ
    ...    M55114C01512    2             SGNB_DL_SCELL_4_ADMI_REQ
    ...    M55114C01513    2             SGNB_DL_SCELL_5_ADMI_REQ
    ...    M55114C01514    2             SGNB_DL_SCELL_6_ADMI_REQ
    ...    M55114C01515    2             SGNB_DL_SCELL_7_ADMI_REQ
    ...    M55114C01523    4             SGNB_UL_SCELL_1_ADMI_REQ
    ...    M55114C01524    4             SGNB_UL_SCELL_2_ADMI_REQ
    ...    M55114C01525    4             SGNB_UL_SCELL_3_ADMI_REQ
#...
	...    M55114C01517    2             SGNB_DL_SCELL_2_ADMI_SUCC
    ...    M55114C01518    2             SGNB_DL_SCELL_3_ADMI_SUCC
    ...    M55114C01519    2             SGNB_DL_SCELL_4_ADMI_SUCC
    ...    M55114C01520    2             SGNB_DL_SCELL_5_ADMI_SUCC
    ...    M55114C01521    2             SGNB_DL_SCELL_6_ADMI_SUCC
    ...    M55114C01522    2             SGNB_DL_SCELL_7_ADMI_SUCC
    ...    M55114C01526    4             SGNB_UL_SCELL_1_ADMI_SUCC
    ...    M55114C01527    4             SGNB_UL_SCELL_2_ADMI_SUCC
    ...    M55114C01528    4             SGNB_UL_SCELL_3_ADMI_SUCC
#...
	...    M55115C03513    2             SGNB_DU_DL_SCELL_2_ADMI_REQ
    ...    M55115C03514    2             SGNB_DU_DL_SCELL_3_ADMI_REQ
    ...    M55115C03515    2             SGNB_DU_DL_SCELL_4_ADMI_REQ
    ...    M55115C03516    2             SGNB_DU_DL_SCELL_5_ADMI_REQ
    ...    M55115C03517    2             SGNB_DU_DL_SCELL_6_ADMI_REQ
    ...    M55115C03518    2             SGNB_DU_DL_SCELL_7_ADMI_REQ
    ...    M55115C03526    4             SGNB_DU_UL_SCELL_1_ADMI_REQ
    ...    M55115C03527    4             SGNB_DU_UL_SCELL_2_ADMI_REQ
    ...    M55115C03528    4             SGNB_DU_UL_SCELL_3_ADMI_REQ
#...
	...    M55115C03520    2             SGNB_DU_DL_SCELL_2_ADMI_SUCC
    ...    M55115C03521    2             SGNB_DU_DL_SCELL_3_ADMI_SUCC
    ...    M55115C03522    2             SGNB_DU_DL_SCELL_4_ADMI_SUCC
    ...    M55115C03523    2             SGNB_DU_DL_SCELL_5_ADMI_SUCC
    ...    M55115C03524    2             SGNB_DU_DL_SCELL_6_ADMI_SUCC
    ...    M55115C03525    2             SGNB_DU_DL_SCELL_7_ADMI_SUCC
    ...    M55115C03529    4             SGNB_DU_UL_SCELL_1_ADMI_SUCC
    ...    M55115C03530    4             SGNB_DU_UL_SCELL_2_ADMI_SUCC
    ...    M55115C03531    4             SGNB_DU_UL_SCELL_3_ADMI_SUCC
#...
	...    M55118C11014    2             SGNB_DL_SCELL_2_CONFIG_REQ
    ...    M55118C11015    2             SGNB_DL_SCELL_3_CONFIG_REQ
    ...    M55118C11016    2             SGNB_DL_SCELL_4_CONFIG_REQ
    ...    M55118C11017    2             SGNB_DL_SCELL_5_CONFIG_REQ
    ...    M55118C11018    2             SGNB_DL_SCELL_6_CONFIG_REQ
    ...    M55118C11019    2             SGNB_DL_SCELL_7_CONFIG_REQ
    ...    M55118C11020    4             SGNB_UL_SCELL_1_CONFIG_REQ
    ...    M55118C11021    4             SGNB_UL_SCELL_2_CONFIG_REQ
    ...    M55118C11022    4             SGNB_UL_SCELL_3_CONFIG_REQ
#...
	...    M55118C11024    2             SGNB_DL_SCELL_2_CONFIG_SUCC
    ...    M55118C11025    2             SGNB_DL_SCELL_3_CONFIG_SUCC
    ...    M55118C11026    2             SGNB_DL_SCELL_4_CONFIG_SUCC
    ...    M55118C11027    2             SGNB_DL_SCELL_5_CONFIG_SUCC
    ...    M55118C11028    2             SGNB_DL_SCELL_6_CONFIG_SUCC
    ...    M55118C11029    2             SGNB_DL_SCELL_7_CONFIG_SUCC
    ...    M55118C11030    4             SGNB_UL_SCELL_1_CONFIG_SUCC
    ...    M55118C11031    4             SGNB_UL_SCELL_2_CONFIG_SUCC
    ...    M55118C11032    4             SGNB_UL_SCELL_3_CONFIG_SUCC
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

	Run Keyword And Continue On Failure  Verify Last Counters In File
	...    M55114C01510    1             SGNB_DL_SCELL_2_ADMI_REQ
    ...    M55114C01523    1             SGNB_UL_SCELL_1_ADMI_REQ
#...
	...    M55114C01517    1             SGNB_DL_SCELL_2_ADMI_SUCC
    ...    M55114C01526    1             SGNB_UL_SCELL_1_ADMI_SUCC
#...
	...    M55115C03513    1             SGNB_DU_DL_SCELL_2_ADMI_REQ
    ...    M55115C03526    1             SGNB_DU_UL_SCELL_1_ADMI_REQ
#...
	...    M55115C03520    1             SGNB_DU_DL_SCELL_2_ADMI_SUCC
    ...    M55115C03529    1             SGNB_DU_UL_SCELL_1_ADMI_SUCC
#...
	...    M55118C11014    1             SGNB_DL_SCELL_2_CONFIG_REQ
    ...    M55118C11020    1             SGNB_UL_SCELL_1_CONFIG_REQ
#...
	...    M55118C11024    1             SGNB_DL_SCELL_2_CONFIG_SUCC
    ...    M55118C11030    1             SGNB_UL_SCELL_1_CONFIG_SUCC
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${pm_counters}

    Detach UE NSA  ue_id_first=1  ue_id_last=13
    [Teardown]    Run Keyword And Ignore Error    Add Main BTS Metadata to Report




