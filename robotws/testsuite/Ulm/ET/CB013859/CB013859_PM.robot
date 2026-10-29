*** Settings ***

Documentation
...    author: VRF ULM T01 01
...    Team: 'MN RAN RD VRF ULM 1'
...    Email: 'OU_MN_RAN_RD_VRF_ULM_1_53028392@internal.nsn.com'
...    Description: PM counters for CB013859-A and -B

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

*** Variables ***

@{A_B4_PM_PCELL}
...    M55118C00110  ==  3   Number of partially compliant SCell configurations based on slice ID (ADD_SCELL_CONF_SLICEALG)
...    M55118C00111  ==  0   Number of DRB assignments to partially compliant SCell in unsupported slice (DRB_NOSLICE_DEF_RG)

@{A_B6_PM_PCELL}
...    M55118C00110  ==  3   Number of partially compliant SCell configurations based on slice ID (ADD_SCELL_CONF_SLICEALG)
...    M55118C00111  ==  3   Number of DRB assignments to partially compliant SCell in unsupported slice (DRB_NOSLICE_DEF_RG)

@{B_IWK1_PM_PCELL}
...    (NRCELL-7)M55118C00110  ==  2   Number of partially compliant SCell configurations based on slice ID (ADD_SCELL_CONF_SLICEALG)
...    (NRCELL-1)M55118C00110  ==  3   Number of partially compliant SCell configurations based on slice ID (ADD_SCELL_CONF_SLICEALG)
...    (NRCELL-7)M55118C00111  ==  0   Number of DRB assignments to partially compliant SCell in unsupported slice (DRB_NOSLICE_DEF_RG)
...    (NRCELL-1)M55118C00111  ==  0   Number of DRB assignments to partially compliant SCell in unsupported slice (DRB_NOSLICE_DEF_RG)

@{B_IWK7_PM_PCELL}
...    M55118C00110  ==  3   Number of partially compliant SCell configurations based on slice ID (ADD_SCELL_CONF_SLICEALG)
...    M55118C00111  ==  0   Number of DRB assignments to partially compliant SCell in unsupported slice (DRB_NOSLICE_DEF_RG)
...    M55118C00030  ==  1   Number of A4 measurement activations for FR1 CA SCell Addition (A4_MEASUR_ACT_SCELL_ADD_SA)   #Legacy counter
...    M55118C00031  ==  3   Number of SCells added as A4-based SCells during FR1 CA SCell Addition (A4_SCELL_ADDED_SA)   #Legacy counter

@{B_IWK9_PM_PCELL_Slice-1_applicationType_enabled}
...    M55118C00110  ==  3   Number of partially compliant SCell configurations based on slice ID (ADD_SCELL_CONF_SLICEALG)
...    M55118C00111  ==  1   Number of DRB assignments to partially compliant SCell in unsupported slice (DRB_NOSLICE_DEF_RG)

@{B_IWK9_PM_PCELL_Slice-1_applicationType_disabled}
...    M55118C00110  ==  0   Number of partially compliant SCell configurations based on slice ID (ADD_SCELL_CONF_SLICEALG)
...    M55118C00111  ==  2   Number of DRB assignments to partially compliant SCell in unsupported slice (DRB_NOSLICE_DEF_RG)

@{D_IWK1_PM_PCELL}
...    M55118C00110  ==  1   Number of partially compliant SCell configurations based on slice ID (ADD_SCELL_CONF_SLICEALG)
...    M55118C00111  ==  0   Number of DRB assignments to partially compliant SCell in unsupported slice (DRB_NOSLICE_DEF_RG)

