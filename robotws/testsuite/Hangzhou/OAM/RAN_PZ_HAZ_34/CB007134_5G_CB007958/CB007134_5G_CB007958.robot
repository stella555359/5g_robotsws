# *** Setting ***
# Documentation         author: Shi Taotao
# ...                   contact: taotao.shi@nokia-sbell.com
# ...                   squard group: SG_01
# ...                   feature: CB007134_5G_CB007958
# Suite Setup           Setup Suite
# Suite Teardown        Teardown Suite
# Force Tags        RAN_5G  RAN_5G_FDD  STATE_SW_UPLOADED  SBTS00  SBTS22R4
# ...   CLOUD_5G_CLASSICAL_ANDROID_ASIBL_ABINB1_3xAHLOA_ENB
# ...   CLOUD_5G_CLASSICAL_FULLRACK_QC_SA_ASIBL_ABIOB1_AWHQN-ASIBR_ABINB4_AWHQX   PY36
# 
# Resource              ../../../RRM/RAN_PZ_HAZ_34/CB007958/Resources/CB007958_Resources.robot
# 
# *** Test Cases ***
# [1]CB007134-5G-C_03_Configuration reset to trigger AC with DHCP less
#     [Documentation]    This case is to verify Autoconnection will be triggered with DHCP less while gNB configuration reset
#     [Tags]   CRT_UTE    CRT_TRUNK    CRT_22R4
#     [Setup]  KW.CaseSetup
#     [Teardown]  KW.Case03Teardown
#     [Timeout]  60 minutes
#     TC.CB007958-5G_03_Configuration reset to trigger AC with DHCP less
# 
# 
# *** Keywords ***
# Setup Suite
#     KW.SuiteSetup
# 
# Teardown Suite
#     KW.SuiteTeardown
