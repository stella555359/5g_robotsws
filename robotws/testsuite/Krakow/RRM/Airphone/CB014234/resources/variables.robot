*** Settings ***
Documentation    Variables resource for the CB014234 feature


*** Variables ***
${cell_1_local_moid}    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
&{PSCELL_CHANGE_SUC}    id=M55112C00030     name=NX2CC_INTRA_CELL_PSCEL_CHG_SUC      mo_id=${cell_1_local_moid}      value=13
&{PSCELL_CHANGE_ATT}    id=M55112C00029     name=NX2CC_INTRA_CELL_PSCEL_CHG_ATT      mo_id=${cell_1_local_moid}      value=13
@{NX2CC_COUNTERS}       ${PSCELL_CHANGE_SUC}      ${PSCELL_CHANGE_ATT}

# Number of successful radio admissions for X DL Scells
&{SGNB_DL_SCELL_3_ADMI_SUCC}     id=M55114C01518     name=SGNB_DL_SCELL_3_ADMI_SUCC      mo_id=${cell_1_local_moid}      value=7
&{SGNB_DL_SCELL_2_ADMI_SUCC}     id=M55114C01517     name=SGNB_DL_SCELL_2_ADMI_SUCC      mo_id=${cell_1_local_moid}      value=5
@{SGNB_DL_SCELL_ADMI_SUCC}       ${SGNB_DL_SCELL_3_ADMI_SUCC}      ${SGNB_DL_SCELL_2_ADMI_SUCC}

# Number of successful selections for X DL SCell as the best SCell
&{SGNB_DL_SCELL_3_CONFIG_REQ}     id=M55118C11015     name=SGNB_DL_SCELL_3_CONFIG_REQ      mo_id=${cell_1_local_moid}      value=7
&{SGNB_DL_SCELL_2_CONFIG_REQ}     id=M55118C11014     name=SGNB_DL_SCELL_2_CONFIG_REQ      mo_id=${cell_1_local_moid}      value=5
@{SGNB_DL_SCELL_REQ}              ${SGNB_DL_SCELL_3_CONFIG_REQ}     ${SGNB_DL_SCELL_2_CONFIG_REQ}

#Total number of X DL SCells configured
&{SGNB_DL_SCELL_3_CONFIG_SUCC}     id=M55118C11025     name=SGNB_DL_SCELL_3_CONFIG_SUCC      mo_id=${cell_1_local_moid}      value=7
&{SGNB_DL_SCELL_2_CONFIG_SUCC}     id=M55118C11024     name=SGNB_DL_SCELL_2_CONFIG_SUCC      mo_id=${cell_1_local_moid}      value=5
@{SGNB_DL_SCELL_SUCC}              ${SGNB_DL_SCELL_3_CONFIG_SUCC}    ${SGNB_DL_SCELL_2_CONFIG_SUCC}

# RRC Reconfigurations attempts for X SCells Addition in DL for NSA mode
&{RRC_RECONF_3_SCELL_DL_ATT}     id=M55118C02004     name=RRC_RECONF_3_SCELL_DL_ATT      mo_id=${cell_1_local_moid}      value=7
&{RRC_RECONF_2_SCELL_DL_ATT}     id=M55118C02002     name=RRC_RECONF_2_SCELL_DL_ATT      mo_id=${cell_1_local_moid}      value=5
@{RRC_RECONF_DL_ATT}             ${RRC_RECONF_3_SCELL_DL_ATT}      ${RRC_RECONF_2_SCELL_DL_ATT}

# Successful RRC Reconfigurations attempts for X SCells Addition in DL for NSA mode
&{RRC_RECONF_3_SCELL_DL_SUCC}     id=M55118C03004     name=RRC_RECONF_3_SCELL_DL_SUCC      mo_id=${cell_1_local_moid}      value=7
&{RRC_RECONF_2_SCELL_DL_SUCC}     id=M55118C03002     name=RRC_RECONF_2_SCELL_DL_SUCC      mo_id=${cell_1_local_moid}      value=5
@{RRC_RECONF_DL_SUCC}             ${RRC_RECONF_3_SCELL_DL_SUCC}     ${RRC_RECONF_2_SCELL_DL_SUCC}

#Number of DL full SCell release attempts on PSCell for NSA
&{DL_RRC_FSCELL_REL_ATT_NSA}     id=M55118C11043     name=DL_RRC_FSCELL_REL_ATT_NSA      mo_id=${cell_1_local_moid}      value=10
&{DL_RRC_FSCELL_REL_SUC_NSA}     id=M55118C11044     name=DL_RRC_FSCELL_REL_SUC_NSA      mo_id=${cell_1_local_moid}      value=10
@{SUCC_DL_SCELL_RELEASE}         ${DL_RRC_FSCELL_REL_ATT_NSA}       ${DL_RRC_FSCELL_REL_SUC_NSA}

# Number of successful UL full SCell release attempts on PSCell for NSA
&{UL_RRC_FSCELL_REL_ATT_NSA}     id=M55118C11041     name=UL_RRC_FSCELL_REL_ATT_NSA      mo_id=${cell_1_local_moid}      value=6
&{UL_RRC_FSCELL_REL_SUC_NSA}     id=M55118C11042     name=UL_RRC_FSCELL_REL_SUC_NSA      mo_id=${cell_1_local_moid}      value=6
@{SUCC_UL_SCELL_RELEASE}         ${UL_RRC_FSCELL_REL_ATT_NSA}       ${UL_RRC_FSCELL_REL_SUC_NSA}

# Number of DL FR1/FR2 SCells released on PSCell due to ConfigRestrictInfo change for NSA
&{DL_CFGRSTC_SCELL_REL_ATT_NSA}     id=M55118C11045     name=DL_CFGRSTC_SCELL_REL_ATT_NSA      mo_id=${cell_1_local_moid}      value=26
&{DL_CFGRSTC_SCELL_REL_SUC_NSA}     id=M55118C11046     name=DL_CFGRSTC_SCELL_REL_SUC_NSA      mo_id=${cell_1_local_moid}      value=26
@{NUM_OF_DL_SCELLS_RELEASED}       ${DL_CFGRSTC_SCELL_REL_ATT_NSA}    ${DL_CFGRSTC_SCELL_REL_SUC_NSA}

# Number of outgoing SGNB MODIFICATION REQUEST REJECT sent due to cause other than No Radio Resources Available.
&{X2_SGNB_MOD_FAIL_MISC_UNSPC}      id=M55112C04003     name=X2_SGNB_MOD_FAIL_MISC_UNSPC       mo_id=${cell_1_local_moid}      value=1

${STD_UE_ATTACH_FAIL_REG}    Failure.*while applying|T.* expiration|No response from proxy








