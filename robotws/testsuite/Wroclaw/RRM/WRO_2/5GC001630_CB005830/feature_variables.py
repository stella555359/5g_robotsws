DELTA_ACTIVATE_BARRING_WITH_EXPLICIT_LIST = 'delta_activate_barring_with_explicit_list.json'
DELTA_ACTIVATE_BARRING_WITH_IMPLICIT_LIST = 'delta_activate_barring_with_implicit_list.json'
DELTA_DEACTIVATE_BARRING = 'delta_deactivate_barring.json'

CPRT_DEBUG_ACTIVATION_COMMAND = 'echo -e "[control]\nLoggingSeverity=trace" > /ffs/run/cp_runtime.ini && ' \
                                'crasign /ffs/run/cp_runtime.ini'

BARRING_INFO_ABSENCE_FILTER = 'nr-rrc.c1 == 1 && !nr-rrc.uac_BarringInfo_element && nr-rrc.plmn_IdentityList == 6'

UAC_BARRING_PER_PLMN_LIST_EXPLICIT = 'nr-rrc.uac_BarringPerPLMN_List == 1 && ' \
                                     'nr-rrc.plmn_IdentityIndex == 1 &&' \
                                     'nr-rrc.uac_ACBarringListType == 1 &&' \
                                     'nr-rrc.uac_ExplicitACBarringList == 1 &&' \
                                     'nr-rrc.accessCategory == 1 &&' \
                                     'nr-rrc.uac_barringInfoSetIndex == 1'

UAC_BARRING_PER_PLMN_LIST_IMPLICIT = 'nr-rrc.uac_BarringPerPLMN_List == 1 && ' \
                                     'nr-rrc.plmn_IdentityIndex == 1 &&' \
                                     'nr-rrc.uac_ACBarringListType == 0 &&' \
                                     'nr-rrc.uac_ImplicitACBarringList == 63 &&' \
                                     'nr-rrc.UAC_BarringInfoSetIndex == 1'

ABSENCE_OF_UAC_BARRING_PER_PLMN_LIST_IMPLICIT = '!nr-rrc.uac_BarringPerPLMN_List && ' \
                                                '!nr-rrc.plmn_IdentityIndex &&' \
                                                '!nr-rrc.uac_ACBarringListType &&' \
                                                '!nr-rrc.uac_ImplicitACBarringList &&' \
                                                '!nr-rrc.UAC_BarringInfoSetIndex'

UAC_BARRING_INFO_SET_LIST = 'nr-rrc.uac_BarringInfoSetList == 1 &&' \
                            'nr-rrc.uac_BarringFactor == 1 &&' \
                            'nr-rrc.uac_BarringTime == 1 &&' \
                            'nr-rrc.uac_BarringForAccessIdentity == 04'

UAC_ACCESS_CATEGORY1_SELECTION_ASSISTANCE_INFO = 'nr-rrc.uac_AccessCategory1_SelectionAssistanceInfo == 1 &&' \
                                                 'nr-rrc.individualPLMNList == 6 &&' \
                                                 'nr-rrc.UAC_AccessCategory1_SelectionAssistanceInfo == 0 &&' \
                                                 'nr-rrc.UAC_AccessCategory1_SelectionAssistanceInfo == 1 &&' \
                                                 'nr-rrc.UAC_AccessCategory1_SelectionAssistanceInfo == 2'

ABSENCE_OF_UAC_ACCESS_CATEGORY1_SELECT_ASSIST_INFO = '!nr-rrc.uac_AccessCategory1_SelectionAssistanceInfo == 1 &&' \
                                                     '!nr-rrc.individualPLMNList == 6 &&' \
                                                     '!nr-rrc.UAC_AccessCategory1_SelectionAssistanceInfo == 0 &&' \
                                                     '!nr-rrc.UAC_AccessCategory1_SelectionAssistanceInfo == 1 &&' \
                                                     '!nr-rrc.UAC_AccessCategory1_SelectionAssistanceInfo == 2'

SIB1_BARRING_INFO_EXPLICIT_FILTER = ' && '.join([UAC_BARRING_PER_PLMN_LIST_EXPLICIT,
                                                 UAC_BARRING_INFO_SET_LIST,
                                                 UAC_ACCESS_CATEGORY1_SELECTION_ASSISTANCE_INFO])

SIB1_BARRING_INFO_IMPLICIT_FILTER = ' && '.join([UAC_BARRING_PER_PLMN_LIST_IMPLICIT,
                                                 UAC_BARRING_INFO_SET_LIST,
                                                 UAC_ACCESS_CATEGORY1_SELECTION_ASSISTANCE_INFO])

SIB1_BARRING_INFO_WITH_UAC_BARRING_INFO_SET_LIST_ONLY = ' && '.join(
    [ABSENCE_OF_UAC_BARRING_PER_PLMN_LIST_IMPLICIT,
     UAC_BARRING_INFO_SET_LIST,
     ABSENCE_OF_UAC_ACCESS_CATEGORY1_SELECT_ASSIST_INFO])
