*** Settings ***

Documentation
...    author: Ulm SQD 65
...    Team: 'MN RAN L3 SW ULM L3NRT SQD 65'
...    Email: 'I_MN_RAN_L3_SW_ULM_SQD_65@internal.nsn.com'
...    Description: CB009059 PM counters

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

*** Variables ***

@{A_B1_PM_PCELL}
...    M55310C01005  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 05
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01009  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 09

@{A_B1_PM_SCELL}
...    M55310C01005  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 05
...    M55310C01006  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01009  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 09

@{A_B2_PM_PCELL}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01009  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 09

@{A_B2_PM_SCELL}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01009  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 09

@{A_B6_PM_PCELL}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01005  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 05
...    M55310C01008  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 08
...    M55310C01009  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 09
...    M55125C00039  ==  1       SCELL_ADDN_ALLOW_DRB_PRFL_CA (Number of times SCell addition is allowed for a UE due to DRB profile-based CA)
...    M55125C00040  ==  1       SCELL_ADDN_PREVENT_DRB_PRFL_CA (Number of times SCell addition is prevented for a UE due to DRB profile-based CA)

@{A_B6_PM_SCELL}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  ==  0  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01005  ==  0  DL RLC data PDU volume transmitted by Low RLC - QoS Group 05
...    M55310C01008  ==  0  DL RLC data PDU volume transmitted by Low RLC - QoS Group 08
...    M55310C01009  ==  0  DL RLC data PDU volume transmitted by Low RLC - QoS Group 09

@{A_B7_1_PM_PCELL}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55125C00039  ==  1       SCELL_ADDN_ALLOW_DRB_PRFL_CA (Number of times SCell addition is allowed for a UE due to DRB profile-based CA)

@{A_B7_1_PM_SCELL}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06

@{A_B7_PM_PCELL_after_pdu_mod}
...    M55310C01009  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06

@{A_B7_PM_SCELL_after_pdu_mod}
...    M55310C01009  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06

@{A_B7_2_PM_PCELL}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01009  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 09
...    M55125C00039  ==  1       SCELL_ADDN_ALLOW_DRB_PRFL_CA (Number of times SCell addition is allowed for a UE due to DRB profile-based CA)
...    M55125C00040  ==  1       SCELL_ADDN_PREVENT_DRB_PRFL_CA (Number of times SCell addition is prevented for a UE due to DRB profile-based CA)

@{A_B7_2_PM_SCELL}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01009  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 09

@{A_B7_3_PM_PCELL}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55125C00039  ==  1       SCELL_ADDN_ALLOW_DRB_PRFL_CA (Number of times SCell addition is allowed for a UE due to DRB profile-based CA)
...    M55125C00040  ==  1       SCELL_ADDN_PREVENT_DRB_PRFL_CA (Number of times SCell addition is prevented for a UE due to DRB profile-based CA)

@{A_B7_3_PM_SCELL}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06

@{A_B10_1_PM_PCELL_SCell_Allocations_disabled}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55125C00039  ==  1       SCELL_ADDN_ALLOW_DRB_PRFL_CA (Number of times SCell addition is allowed for a UE due to DRB profile-based CA)

@{A_B10_1_PM_SCELL_SCell_Allocations_disabled}
...    M55310C01006  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 06

@{A_B10_1_PM_PCELL_SCell_Allocations_enabled}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01009  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 09

@{A_B10_1_PM_SCELL_SCell_Allocations_enabled}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01009  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 09

@{A_B10_2_PM_PCELL_SCell_Allocations_disabled}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55125C00039  ==  1       SCELL_ADDN_ALLOW_DRB_PRFL_CA (Number of times SCell addition is allowed for a UE due to DRB profile-based CA)

@{A_B10_2_PM_SCELL_SCell_Allocations_disabled}
...    M55310C01006  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 06

@{A_B10_2_PM_PCELL_SCell_Allocations_enabled}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07

@{A_B10_2_PM_SCELL_SCell_Allocations_enabled}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 07

@{A_B10_3_PM_PCELL_SCell_Allocations_disabled}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55125C00039  ==  1       SCELL_ADDN_ALLOW_DRB_PRFL_CA (Number of times SCell addition is allowed for a UE due to DRB profile-based CA)

@{A_B10_3_PM_SCELL_SCell_Allocations_disabled}
...    M55310C01006  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 06

@{A_B10_3_PM_PCELL_SCell_Allocations_enabled}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01008  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 08
...    M55310C01009  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 09
...    M55125C00040  ==  1       SCELL_ADDN_PREVENT_DRB_PRFL_CA (Number of times SCell addition is prevented for a UE due to DRB profile-based CA)

@{A_B10_3_PM_SCELL_SCell_Allocations_enabled}
...    M55310C01006  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01008  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 08
...    M55310C01009  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 09

@{AC_001_1_PM_PCELL_initial_condition_featureflag_disabled}
...    M55310C01007  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07

@{AC_001_1_PM_SCELL_initial_condition_featureflag_disabled}
...    M55310C01007  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07

@{AC_001_1_PM_PCELL_after_online_modify_featureflag_enabled}
...    M55310C01007  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07

@{AC_001_1_PM_SCELL_after_online_modify_featureflag_enabled}
...    M55310C01007  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07

@{AC_001_1_PM_PCELL_after_second_pdu_session_setup}
...    M55310C01007  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06

@{AC_001_1_PM_SCELL_after_second_pdu_session_setup}
...    M55310C01007  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06

@{AC_001_3_PM_PCELL_initial_condition_featureflag_enabled}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07

@{AC_001_3_PM_SCELL_initial_condition_featureflag_enabled}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 07

@{AC_001_3_PM_PCELL_after_online_modify_featureflag_disabled}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07

@{AC_001_3_PM_SCELL_after_online_modify_featureflag_disabled}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 07

@{AC_001_3_PM_PCELL_after_second_pdu_session_setup}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01008  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 08

@{AC_001_3_PM_SCELL_after_second_pdu_session_setup}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01008  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 08

@{AC_002_1_PM_PCELL_initial_condition_featureflag_disabled}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07

@{AC_002_1_PM_SCELL_initial_condition_featureflag_disabled}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07

@{AC_002_1_PM_PCELL_after_online_modify_featureflag_enabled}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07

@{AC_002_1_PM_SCELL_after_online_modify_featureflag_enabled}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07

@{AC_002_1_PM_PCELL_after_second_pdu_session_setup}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01004  >=  1000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 04

@{AC_002_1_PM_SCELL_after_second_pdu_session_setup}
...    M55310C01006  ==  0  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  ==  0  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01004  ==  0  DL RLC data PDU volume transmitted by Low RLC - QoS Group 04

@{AC_002_2_PM_PCELL_initial_condition_featureflag_enabled}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07

@{AC_002_2_PM_SCELL_initial_condition_featureflag_enabled}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 07

@{AC_002_2_PM_PCELL_after_online_modify_featureflag_disabled}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07

@{AC_002_2_PM_SCELL_after_online_modify_featureflag_disabled}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 07

@{AC_002_2_PM_PCELL_after_second_pdu_session_setup}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01004  >=  1000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 04

@{AC_002_2_PM_SCELL_after_second_pdu_session_setup}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01004  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 04

@{AC_003_1_PM_PCELL_initial_condition_drb_profile_FR1_CA_eligible}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01018  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 18
...    M55310C01019  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 19

@{AC_003_1_PM_SCELL_initial_condition_drb_profile_FR1_CA_eligible}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01018  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 18
...    M55310C01019  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 19

@{AC_003_1_PM_PCELL_after_online_modify_drb_profile_Not_FR1_CA_eligible}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01018  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 18
...    M55310C01019  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 19

@{AC_003_1_PM_SCELL_after_online_modify_drb_profile_Not_FR1_CA_eligible}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01018  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 18
...    M55310C01019  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 19

@{AC_003_1_PM_PCELL_after_second_pdu_session_setup}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01009  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 09
...    M55310C01018  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 18
...    M55310C01019  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 19
...    M55310C01017  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 17

@{AC_003_1_PM_SCELL_after_second_pdu_session_setup}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01009  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 09
...    M55310C01018  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 18
...    M55310C01019  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 19
...    M55310C01017  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 17

@{AC_003_2_PM_PCELL_initial_condition_drb_profile_Not_FR1_CA_eligible}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07

@{AC_003_2_PM_SCELL_initial_condition_drb_profile_Not_FR1_CA_eligible}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 07

@{AC_003_2_PM_PCELL_after_online_modify_drb_profile_FR1_CA_eligible}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07

@{AC_003_2_PM_SCELL_after_online_modify_drb_profile_FR1_CA_eligible}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 07

@{AC_003_2_PM_PCELL_after_second_pdu_session_setup}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01009  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 09

@{AC_003_2_PM_SCELL_after_second_pdu_session_setup}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01009  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 09

@{C_B7_PM_PCELL}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01018  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 18
...    M55310C01019  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 19

@{C_B7_PM_SCELL}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01018  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 18
...    M55310C01019  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 19

@{C_B7_PM_PCELL_After_SCell_Change}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01018  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 18
...    M55310C01019  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 19

@{C_B7_PM_SCELL_After_SCell_Change}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01018  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 18
...    M55310C01019  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 19

@{C_B8_PM_PCELL}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01018  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 18
...    M55310C01019  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 19

@{C_B8_PM_SCELL}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01018  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 18
...    M55310C01019  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 19

@{C_B8_PM_PCELL_After_SCell_Swap_1}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01018  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 18
...    M55310C01019  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 19

@{C_B8_PM_SCELL_After_SCell_Swap_1}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01018  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 18
...    M55310C01019  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 19

@{C_B8_PM_PCELL_After_SCell_Swap_2}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01018  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 18
...    M55310C01019  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 19

@{C_B8_PM_SCELL_After_SCell_Swap_2}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01018  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 18
...    M55310C01019  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 19

@{E_B1_1_PM_PCELL_before_nrdc_setup}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C03006  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 06

@{E_B1_1_PM_SCELL_before_nrdc_setup}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C03006  ==  0       UL RLC data PDU volume received by Low RLC - QoS Group 06

@{E_B1_1_PM_PCELL_after_nrdc_released}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01009  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 09
...    M55310C03006  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 06
...    M55310C03007  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 07
...    M55310C03009  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 09

@{E_B1_1_PM_SCELL_after_nrdc_released}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01009  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 09
...    M55310C03006  ==  0       UL RLC data PDU volume received by Low RLC - QoS Group 06
...    M55310C03007  ==  0       UL RLC data PDU volume received by Low RLC - QoS Group 07
...    M55310C03009  ==  0       UL RLC data PDU volume received by Low RLC - QoS Group 09

@{E_B1_2_PM_PCELL_before_nrdc_setup}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01009  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 09
...    M55310C03006  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 06
...    M55310C03007  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 07
...    M55310C03009  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 09

@{E_B1_2_PM_SCELL_before_nrdc_setup}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01009  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 09
...    M55310C03006  ==  0       UL RLC data PDU volume received by Low RLC - QoS Group 06
...    M55310C03007  ==  0       UL RLC data PDU volume received by Low RLC - QoS Group 07
...    M55310C03009  ==  0       UL RLC data PDU volume received by Low RLC - QoS Group 09

@{E_B1_2_PM_PCELL_after_nrdc_released}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01009  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 09
...    M55310C03006  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 06
...    M55310C03007  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 07
...    M55310C03009  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 09

@{E_B1_2_PM_SCELL_after_nrdc_released}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01009  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 09
...    M55310C03006  ==  0       UL RLC data PDU volume received by Low RLC - QoS Group 06
...    M55310C03007  ==  0       UL RLC data PDU volume received by Low RLC - QoS Group 07
...    M55310C03009  ==  0       UL RLC data PDU volume received by Low RLC - QoS Group 09

@{E_B1_3_PM_PCELL_before_nrdc_setup}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01009  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 09
...    M55310C03006  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 06
...    M55310C03007  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 07
...    M55310C03009  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 09

@{E_B1_3_PM_SCELL_before_nrdc_setup}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01009  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 09
...    M55310C03006  ==  0       UL RLC data PDU volume received by Low RLC - QoS Group 06
...    M55310C03007  ==  0       UL RLC data PDU volume received by Low RLC - QoS Group 07
...    M55310C03009  ==  0       UL RLC data PDU volume received by Low RLC - QoS Group 09

@{E_B1_3_PM_PCELL_after_nrdc_released}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01009  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 09
...    M55310C03006  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 06
...    M55310C03007  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 07
...    M55310C03009  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 09

@{E_B1_3_PM_SCELL_after_nrdc_released}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01009  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 09
...    M55310C03006  ==  0       UL RLC data PDU volume received by Low RLC - QoS Group 06
...    M55310C03007  ==  0       UL RLC data PDU volume received by Low RLC - QoS Group 07
...    M55310C03009  ==  0       UL RLC data PDU volume received by Low RLC - QoS Group 09

@{E_B1_4_PM_PCELL_before_nrdc_setup}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C03006  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 06

@{E_B1_4_PM_SCELL_before_nrdc_setup}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C03006  ==  0       UL RLC data PDU volume received by Low RLC - QoS Group 06

@{E_B1_4_PM_PCELL_after_nrdc_released}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01009  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 09
...    M55310C03006  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 06
...    M55310C03007  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 07
...    M55310C03009  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 09

@{E_B1_4_PM_SCELL_after_nrdc_released}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01009  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 09
...    M55310C03006  ==  0       UL RLC data PDU volume received by Low RLC - QoS Group 06
...    M55310C03007  ==  0       UL RLC data PDU volume received by Low RLC - QoS Group 07
...    M55310C03009  ==  0       UL RLC data PDU volume received by Low RLC - QoS Group 09

@{E_B2_PM_PCELL_before_nrdc_setup}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C03006  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 06

@{E_B2_PM_SCELL_before_nrdc_setup}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C03006  ==  0       UL RLC data PDU volume received by Low RLC - QoS Group 06

@{E_B2_PM_PCELL_after_nrdc_released}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01008  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 08
...    M55310C03006  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 06
...    M55310C03008  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 08

@{E_B2_PM_SCELL_after_nrdc_released}
...    M55310C01006  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01008  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 08
...    M55310C03006  ==  0       UL RLC data PDU volume received by Low RLC - QoS Group 06
...    M55310C03008  ==  0       UL RLC data PDU volume received by Low RLC - QoS Group 08

@{E_B3_PM_PCELL_before_nrdc_setup}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C03006  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 06

@{E_B3_PM_SCELL_before_nrdc_setup}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C03006  ==  0       UL RLC data PDU volume received by Low RLC - QoS Group 06

@{E_B3_PM_PCELL_after_nrdc_released}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01009  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 09
...    M55310C03006  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 06
...    M55310C03007  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 07
...    M55310C03009  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 09

@{E_B3_PM_SCELL_after_nrdc_released}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01009  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 09
...    M55310C03006  ==  0       UL RLC data PDU volume received by Low RLC - QoS Group 06
...    M55310C03007  ==  0       UL RLC data PDU volume received by Low RLC - QoS Group 07
...    M55310C03009  ==  0       UL RLC data PDU volume received by Low RLC - QoS Group 09

@{BA_B10_PM_PCELL_before_overheating_step}
...    M55310C01005  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 05
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01018  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 18

@{BA_B10_PM_SCELL_before_overheating_step}
...    M55310C01005  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 05
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01018  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 18

@{BA_B10_PM_PCELL_after_overheating_step}
...    M55310C01007  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01009  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 09
...    M55310C01018  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 18
...    M55310C01019  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 19

@{BA_B10_PM_SCELL_after_overheating_step}
...    M55310C01007  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01009  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 09
...    M55310C01018  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 18
...    M55310C01019  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 19

@{BA_B11_PM_PCELL_after_SCell_activation}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07

@{BA_B11_PM_SCELL_after_SCell_activation}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 07

@{BA_B11_PM_PCELL_after_SCell_release}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07

@{BA_B11_PM_SCELL_after_SCell_release}
...    M55310C01006  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 07

@{BA_B1_PM_PCELL_Before_Dl_Buffer_Activated}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07

@{BA_B1_PM_SCELL_Before_Dl_Buffer_Activated}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 07

@{BA_B1_PM_PCELL_After_Dl_Buffer_Activated}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07

@{BA_B1_PM_SCELL_After_Dl_Buffer_Activated}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 07

@{BA_B4_PM_PCELL_before_sending_A1_MR}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07

@{BA_B4_PM_SCELL_before_sending_A1_MR}
...    M55310C01006  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 07

@{BA_B4_PM_PCELL_after_sending_A1_MR}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07

@{BA_B4_PM_SCELL_after_sending_A1_MR}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 07

@{BA_B4_PM_PCELL_after_second_pdu_session_setup}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01008  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07

@{BA_B4_PM_SCELL_after_second_pdu_session_setup}
...    M55310C01006  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01008  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 07

@{BA_B2_PM_PCELL}
...    M55310C01005  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 05
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01009  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 09
...    M55310C01018  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 18

@{BA_B2_PM_SCELL}
...    M55310C01005  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 05
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01009  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 09
...    M55310C01018  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 18

@{BA_B3_PM_PCELL}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01008  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 08
...    M55310C01018  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 18

@{BA_B3_PM_SCELL}
...    M55310C01006  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01007  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 07
...    M55310C01008  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 08
...    M55310C01018  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 18

@{BE_B2_PM_PCELL_Scenario_1}
...    M55310C01005  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 05
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01001  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 01

@{BE_B2_PM_SCELL_Scenario_1}
...    M55310C01005  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 05
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01001  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 01

@{BE_B2_PM_PCELL_Scenario_2}
...    M55310C01005  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 05
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01001  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 01

@{BE_B2_PM_SCELL_Scenario_2}
...    M55310C01005  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 05
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01001  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 01

@{BE_B2_PM_PCELL_Scenario_3}
...    M55310C01005  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 05
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01001  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 01

@{BE_B2_PM_SCELL_Scenario_3}
...    M55310C01005  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 05
...    M55310C01006  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01001  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 01

@{BE_B1_PM_PCELL_UE-1_UE-4}
...    M55310C01005  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 05
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C03005  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 05
...    M55310C03006  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 06
...    M55310C01017  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 17
...    M55310C01018  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 18
...    M55310C03017  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 17
...    M55310C03018  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 18

@{BE_B1_PM_SCELL_1_UE-1_UE-4}
...    M55310C01005  >=  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 05
       #As per US, data (M55310C01005) may not be split to SCell as too much data cannot be initiated since DRB is non-GBR signaling DRB.
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01017  >=  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 17
       #As per US, data (M55310C01017) may not be split to SCell as too much data cannot be initiated since DRB is non-GBR signaling DRB.
...    M55310C01018  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 18

@{BE_B1_PM_SCELL_2_UE-1_UE-4}
...    M55310C01005  >=  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 05
       #As per US, data (M55310C01005) may not be split to SCell as too much data cannot be initiated since DRB is non-GBR signaling DRB.
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C03005  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 05
...    M55310C03006  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 06
...    M55310C01017  >=  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 17
       #As per US, data (M55310C01017) may not be split to SCell as too much data cannot be initiated since DRB is non-GBR signaling DRB.
...    M55310C01018  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 18
...    M55310C03017  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 17
...    M55310C03018  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 18
...    M55316C00003  ==  1       SCELL_UL_SUSP_UE_NOT_SUPP_LCH (incremented by 1 in DL/UL SCell when UL data scheduling is suspended on the SCell)

@{BE_B1_PM_PCELL_after_VoNR_setup_UE-1_UE-4}
...    M55310C01005  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 05
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C03005  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 05
...    M55310C03006  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 06
...    M55310C01017  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 17
...    M55310C01018  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 18
...    M55310C03017  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 17
...    M55310C03018  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 18

@{BE_B1_PM_SCELL_1_after_VoNR_setup_UE-1_UE-4}
...    M55310C01005  >=  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 05
       #As per US, data (M55310C01005) may not be split to SCell as too much data cannot be initiated since DRB is non-GBR signaling DRB.
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01017  >=  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 17
       #As per US, data (M55310C01017) may not be split to SCell as too much data cannot be initiated since DRB is non-GBR signaling DRB.
...    M55310C01018  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 18

@{BE_B1_PM_SCELL_2_after_VoNR_setup_UE-1_UE-4}
...    M55310C01005  >=  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 05
       #As per US, data (M55310C01005) may not be split to SCell as too much data cannot be initiated since DRB is non-GBR signaling DRB.
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C03005  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 05
...    M55310C03006  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 06
...    M55310C01017  >=  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 17
       #As per US, data (M55310C01017) may not be split to SCell as too much data cannot be initiated since DRB is non-GBR signaling DRB.
...    M55310C01018  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 18
...    M55310C03017  ==  0       UL RLC data PDU volume received by Low RLC - QoS Group 17
...    M55310C03018  ==  0       UL RLC data PDU volume received by Low RLC - QoS Group 18

@{BE_B1_PM_PCELL_after_VoNR_release_UE-1_UE-4}
...    M55310C01005  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 05
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C03005  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 05
...    M55310C03006  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 06
...    M55310C01017  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 17
...    M55310C01018  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 18
...    M55310C03017  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 17
...    M55310C03018  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 18
...    M55316C00001  >=  1000000  DUR_UL_SCELL_SCHED_SUSP (Duration for which UL SCell scheduling is suspended)
...    M55316C00002  ==  1        DUR_UL_SCELL_SCHED_SUSP_DNOM (incremented by 1 when suspended UL SCells are released or recovered for a UE)

@{BE_B1_PM_SCELL_1_after_VoNR_release_UE-1_UE-4}
...    M55310C01005  >=  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 05
       #As per US, data (M55310C01005) may not be split to SCell as too much data cannot be initiated since DRB is non-GBR signaling DRB.
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01017  >=  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 17
       #As per US, data (M55310C01017) may not be split to SCell as too much data cannot be initiated since DRB is non-GBR signaling DRB.
...    M55310C01018  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 18

@{BE_B1_PM_SCELL_2_after_VoNR_release_UE-1_UE-4}
...    M55310C01005  >=  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 05
       #As per US, data (M55310C01005) may not be split to SCell as too much data cannot be initiated since DRB is non-GBR signaling DRB.
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C03005  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 05
...    M55310C03006  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 06
...    M55310C01017  >=  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 17
       #As per US, data (M55310C01017) may not be split to SCell as too much data cannot be initiated since DRB is non-GBR signaling DRB.
...    M55310C01018  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 18
...    M55310C03017  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 17
...    M55310C03018  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 18

@{BE_B1_PM_PCELL_UE-2_UE-5}
...    M55310C01005  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 05
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C03005  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 05
...    M55310C03006  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 06
...    M55310C01017  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 17
...    M55310C01018  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 18
...    M55310C03017  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 17
...    M55310C03018  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 18

@{BE_B1_PM_SCELL_1_UE-2_UE-5}
...    M55310C01005  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 05
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01017  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 17
...    M55310C01018  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 18

@{BE_B1_PM_SCELL_2_UE-2_UE-5}
...    M55310C01005  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 05
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C03005  ==  0       UL RLC data PDU volume received by Low RLC - QoS Group 05
...    M55310C03006  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 06
...    M55310C01017  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 17
...    M55310C01018  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 18
...    M55310C03017  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 17
...    M55310C03018  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 18
...    M55316C00003  ==  1       SCELL_UL_SUSP_UE_NOT_SUPP_LCH (incremented by 1 in DL/UL SCell when UL data scheduling is suspended on the SCell)

@{BE_B1_PM_PCELL_after_VoNR_setup_UE-2_UE-5}
...    M55310C01005  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 05
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C03005  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 05
...    M55310C03006  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 06
...    M55310C01017  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 17
...    M55310C01018  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 18
...    M55310C03017  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 17
...    M55310C03018  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 18

@{BE_B1_PM_SCELL_1_after_VoNR_setup_UE-2_UE-5}
...    M55310C01005  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 05
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01017  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 17
...    M55310C01018  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 18

@{BE_B1_PM_SCELL_2_after_VoNR_setup_UE-2_UE-5}
...    M55310C01005  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 05
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C03005  ==  0       UL RLC data PDU volume received by Low RLC - QoS Group 05
...    M55310C03006  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 06
...    M55310C01017  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 17
...    M55310C01018  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 18
...    M55310C03017  ==  0       UL RLC data PDU volume received by Low RLC - QoS Group 17
...    M55310C03018  ==  0       UL RLC data PDU volume received by Low RLC - QoS Group 18

@{BE_B1_PM_PCELL_after_VoNR_release_UE-2_UE-5}
...    M55310C01005  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 05
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C03005  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 05
...    M55310C03006  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 06
...    M55310C01017  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 17
...    M55310C01018  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 18
...    M55310C03017  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 17
...    M55310C03018  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 18
...    M55316C00001  >=  1000000  DUR_UL_SCELL_SCHED_SUSP (Duration for which UL SCell scheduling is suspended)
...    M55316C00002  ==  1        DUR_UL_SCELL_SCHED_SUSP_DNOM (incremented by 1 when suspended UL SCells are released or recovered for a UE)

@{BE_B1_PM_SCELL_1_after_VoNR_release_UE-2_UE-5}
...    M55310C01005  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 05
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01017  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 17
...    M55310C01018  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 18

@{BE_B1_PM_SCELL_2_after_VoNR_release_UE-2_UE-5}
...    M55310C01005  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 05
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C03005  ==  0       UL RLC data PDU volume received by Low RLC - QoS Group 05
...    M55310C03006  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 06
...    M55310C01017  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 17
...    M55310C01018  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 18
...    M55310C03017  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 17
...    M55310C03018  >=  100000  UL RLC data PDU volume received by Low RLC - QoS Group 18

@{BE_B1_PM_PCELL_UE-3}
...    M55310C01005  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 05
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06

@{BE_B1_PM_SCELL_UE-3}
...    M55310C01005  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 05
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06

@{BE_B1_PM_PCELL_after_VoNR_setup_UE-3}
...    M55310C01005  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 05
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06

@{BE_B1_PM_SCELL_after_VoNR_setup_UE-3}
...    M55310C01005  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 05
...    M55310C01006  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 06

@{BE_B1_PM_PCELL_after_VoNR_release_UE-3}
...    M55310C01005  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 05
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06

@{BE_B1_PM_SCELL_after_VoNR_release_UE-3}
...    M55310C01005  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 05
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06

@{BB_B4_PM_PCELL}
...    M55310C01006  >=  100000   DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01004  >=  3000     DL RLC data PDU volume transmitted by Low RLC - QoS Group 04
...    M55310C03006  >=  100000   UL RLC data PDU volume received by Low RLC - QoS Group 06
...    M55310C03004  >=  100000   UL RLC data PDU volume received by Low RLC - QoS Group 04

@{BB_B4_PM_SCELL}
...    M55310C01006  >=  100000  DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01004  ==  0       DL RLC data PDU volume transmitted by Low RLC - QoS Group 04
...    M55310C03006  ==  0       UL RLC data PDU volume received by Low RLC - QoS Group 06
...    M55310C03004  ==  0       UL RLC data PDU volume received by Low RLC - QoS Group 04

@{BB_B4_PM_PCELL_After_PDU_Mod}
...    M55310C01006  >=  100000   DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01004  ==  0        DL RLC data PDU volume transmitted by Low RLC - QoS Group 04
...    M55310C03006  >=  100000   UL RLC data PDU volume received by Low RLC - QoS Group 06
...    M55310C03004  ==  0        UL RLC data PDU volume received by Low RLC - QoS Group 04

@{BB_B4_PM_SCELL_After_PDU_Mod}
...    M55310C01006  >=  100000   DL RLC data PDU volume transmitted by Low RLC - QoS Group 06
...    M55310C01004  ==  0        DL RLC data PDU volume transmitted by Low RLC - QoS Group 04
...    M55310C03006  >=  100000   UL RLC data PDU volume received by Low RLC - QoS Group 06
...    M55310C03004  ==  0        UL RLC data PDU volume received by Low RLC - QoS Group 04

