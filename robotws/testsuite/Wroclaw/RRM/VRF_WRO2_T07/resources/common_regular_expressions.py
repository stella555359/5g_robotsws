class RegularExpressionsTrunk():
    REE_REQUEST_REGEX = r'RrcReestablishmentRequest[\s\S]*otherFailure|Received[\s\S]*RrcReestablishmentRequest'
    REE_COMPLETE_REGEX = r'*received message: messages::nr_rrc::RRCReestablishmentComplete*'
    RRC_RECONFIG_COMPLETE = r'*received message: messages::nr_rrc::RRCReconfigurationComplete*'
    UE_CONTEXT_MOD_RESPONSE = r'[\s\S]*UeContextModificationResponse[\s\S]*{}'


class RegularExpressions22R4():
    REE_REQUEST_REGEX = r'RrcReestablishmentRequest[\s\S]*otherFailure|Received[\s\S]*RrcReestablishmentRequest'
    REE_COMPLETE_REGEX = r'*received message: messages::nr_rrc::RRCReestablishmentComplete*'
    RRC_RECONFIG_COMPLETE = r'*received message: messages::nr_rrc::RRCReconfigurationComplete*'
    UE_CONTEXT_MOD_RESPONSE = r'[\s\S]*UeContextModificationResponse[\s\S]*{}'


class RegularExpressions22R3():
    REE_REQUEST_REGEX = r'RrcReestablishmentRequest[\s\S]*otherFailure'
    REE_COMPLETE_REGEX = r'*received message: messages::nr_rrc::RRCReestablishmentComplete*'
    RRC_RECONFIG_COMPLETE = r'*received message: messages::nr_rrc::RRCReconfigurationComplete*'
    UE_CONTEXT_MOD_RESPONSE = r'[\s\S]*UeContextModificationResponse[\s\S]*{}'


class RegularExpressions22R2():
    REE_REQUEST_REGEX = r'RrcReestablishmentRequest[\s\S]*otherFailure | Received[\s\S]*RrcReestablishmentRequest'
    REE_COMPLETE_REGEX = r'*received message: messages::nr_rrc::RRCReestablishmentComplete*'
    RRC_RECONFIG_COMPLETE = r'*received message: messages::nr_rrc::RRCReconfigurationComplete*'
    UE_CONTEXT_MOD_RESPONSE = r'[\s\S]*UeContextModificationResponse[\s\S]*{}'
