from temporary_alarms_definition import *


def _build_variable_list():
    var_dict = {}

    var_dict["MASTER_EXPECTED_ALARMS_4220"] = [{"alarmId": "7116", "faultId": "4220"}]

    var_dict["MASTER_EXPECTED_ALARMS_4661_IMS"] = [
        {
            "alarmId": "7115",
            "faultId": "4661",
            "visibleForEM": False,
            "visibleForNetAct": False,
            "visibleForOnap": False,
        }
    ]

    var_dict["MASTER_ALARMS_SYNC"] = [
        {"alarmId": "7101|7108|7115", "faultId": "1898|4385"}
    ]

    var_dict["MASTER_ALARMS_X2"] = [
        {"alarmId": "7104", "faultId": "7100"},
        {"alarmId": "7114", "faultId": "7107"},
        {"alarmId": "7107|7657", "faultId": "6327|6328"},
        {"alarmId": "7107", "faultId": "7300|7308|7319"},
    ]

    var_dict["MASTER_ALARMS_XP_DSS"] = [{"alarmId": "7107|7657", "faultId": "62003"}]

    var_dict["MASTER_ALARMS_NR_DSS"] = [
        {"alarmId": "7114", "faultId": "7509|7511|7513"}
    ]

    var_dict["MASTER_ALARMS_LTE_DSS_CNI_127210"] = [
        {"alarmId": "7115|7107|7112", "faultId": "6129|6132|6134"}
    ]

    var_dict["MASTER_ALARMS_LTE_DSS_NO_CNI_127210"] = [
        {"alarmId": "7115", "faultId": "6129|6132|6134"}
    ]

    var_dict["MASTER_IGNORED_ALARMS_NO_CNI_127210"] = (
        [{"alarmId": "7222", "faultId": "9000"}]
        + SBTS_TEMP_IGNORED_ALARMS
        + ADMIN_ADDITIONAL_COMMON_IGNORED_ALARMS_NO_CNI_127210
    )

    var_dict["MASTER_IGNORED_ALARMS_CNI_127210"] = [
        {"alarmId": "7222", "faultId": "9000"}
    ] + SBTS_TEMP_IGNORED_ALARMS

    var_dict["MASTER_IGNORED_ALARMS_STABLE_BTS_POWERED_OFF"] = (
        [
            {"alarmId": "7115", "faultId": "7523|4405|6280"},
            {"alarmId": "7114", "faultId": "4452"},
            {"alarmId": "61029", "faultId": "61029"},
        ]
        + var_dict["MASTER_ALARMS_SYNC"]
        + var_dict["MASTER_ALARMS_X2"]
        + var_dict["MASTER_ALARMS_XP_DSS"]
    )

    var_dict["SLAVE_EXPECTED_ALARMS_4220"] = [{"alarmId": "7116", "faultId": "4220"}]

    var_dict["SLAVE_EXPECTED_ALARMS_4661_IMS"] = [
        {
            "alarmId": "7115",
            "faultId": "4661",
            "visibleForEM": False,
            "visibleForNetAct": False,
            "visibleForOnap": False,
        }
    ]

    var_dict["SLAVE_ALARMS_SYNC"] = [
        {"alarmId": "7101|7108|7115", "faultId": "1898|4385"}
    ]

    var_dict["SLAVE_ALARMS_X2"] = [
        {"alarmId": "7104", "faultId": "7100"},
        {"alarmId": "7114", "faultId": "7107"},
        {"alarmId": "7107|7657", "faultId": "6327|6328"},
        {"alarmId": "7107", "faultId": "7300|7308|7319"},
    ]

    var_dict["SLAVE_ALARMS_XP_DSS"] = [{"alarmId": "7107|7657", "faultId": "62003"}]

    var_dict["SLAVE_ALARMS_NR_DSS"] = [{"alarmId": "7114", "faultId": "7509|7511|7513"}]

    var_dict["SLAVE_ALARMS_LTE_DSS_CNI_127210"] = [
        {"alarmId": "7115|7107|7112", "faultId": "6129|6132|6134"}
    ]

    var_dict["SLAVE_ALARMS_LTE_DSS_NO_CNI_127210"] = [
        {"alarmId": "7115", "faultId": "6129|6132|6134"}
    ]

    var_dict["SLAVE_IGNORED_ALARMS_NO_CNI_127210"] = (
        [{"alarmId": "7222", "faultId": "9000"}]
        + SBTS_TEMP_IGNORED_ALARMS
        + ADMIN_ADDITIONAL_COMMON_IGNORED_ALARMS_NO_CNI_127210
    )

    var_dict["SLAVE_IGNORED_ALARMS_CNI_127210"] = [
        {"alarmId": "7222", "faultId": "9000"}
    ] + SBTS_TEMP_IGNORED_ALARMS

    var_dict["SLAVE_IGNORED_ALARMS_STABLE_BTS_POWERED_OFF"] = (
        [
            {"alarmId": "7115", "faultId": "7523|4405|6280"},
            {"alarmId": "7114", "faultId": "4452"},
            {"alarmId": "61029", "faultId": "61029"},
        ]
        + var_dict["SLAVE_ALARMS_SYNC"]
        + var_dict["SLAVE_ALARMS_X2"]
        + var_dict["SLAVE_ALARMS_XP_DSS"]
    )

    var_dict["SLAVE1_EXPECTED_ALARMS_4220"] = [{"alarmId": "7116", "faultId": "4220"}]

    var_dict["SLAVE1_EXPECTED_ALARMS_4661_IMS"] = [
        {
            "alarmId": "7115",
            "faultId": "4661",
            "visibleForEM": False,
            "visibleForNetAct": False,
            "visibleForOnap": False,
        }
    ]

    var_dict["SLAVE1_ALARMS_SYNC"] = [
        {"alarmId": "7101|7108|7115", "faultId": "1898|4385"}
    ]

    var_dict["SLAVE1_ALARMS_X2"] = [
        {"alarmId": "7104", "faultId": "7100"},
        {"alarmId": "7114", "faultId": "7107"},
        {"alarmId": "7107|7657", "faultId": "6327|6328"},
        {"alarmId": "7107", "faultId": "7300|7308|7319"},
    ]

    var_dict["SLAVE1_ALARMS_XP_DSS"] = [{"alarmId": "7107|7657", "faultId": "62003"}]

    var_dict["SLAVE1_ALARMS_NR_DSS"] = [
        {"alarmId": "7114", "faultId": "7509|7511|7513"}
    ]

    var_dict["SLAVE1_ALARMS_LTE_DSS_CNI_127210"] = [
        {"alarmId": "7115|7107|7112", "faultId": "6129|6132|6134"}
    ]

    var_dict["SLAVE1_ALARMS_LTE_DSS_NO_CNI_127210"] = [
        {"alarmId": "7115", "faultId": "6129|6132|6134"}
    ]

    var_dict["SLAVE1_IGNORED_ALARMS_NO_CNI_127210"] = (
        [{"alarmId": "7222", "faultId": "9000"}]
        + SBTS_TEMP_IGNORED_ALARMS
        + ADMIN_ADDITIONAL_COMMON_IGNORED_ALARMS_NO_CNI_127210
    )

    var_dict["SLAVE1_IGNORED_ALARMS_CNI_127210"] = [
        {"alarmId": "7222", "faultId": "9000"}
    ] + SBTS_TEMP_IGNORED_ALARMS

    var_dict["SLAVE1_IGNORED_ALARMS_STABLE_BTS_POWERED_OFF"] = (
        [
            {"alarmId": "7115", "faultId": "7523|4405|6280"},
            {"alarmId": "7114", "faultId": "4452"},
            {"alarmId": "61029", "faultId": "61029"},
        ]
        + var_dict["SLAVE1_ALARMS_SYNC"]
        + var_dict["SLAVE1_ALARMS_X2"]
        + var_dict["SLAVE1_ALARMS_XP_DSS"]
    )

    var_dict["SLAVE2_EXPECTED_ALARMS_4220"] = [{"alarmId": "7116", "faultId": "4220"}]

    var_dict["SLAVE2_EXPECTED_ALARMS_4661_IMS"] = [
        {
            "alarmId": "7115",
            "faultId": "4661",
            "visibleForEM": False,
            "visibleForNetAct": False,
            "visibleForOnap": False,
        }
    ]

    var_dict["SLAVE2_ALARMS_SYNC"] = [
        {"alarmId": "7101|7108|7115", "faultId": "1898|4385"}
    ]

    var_dict["SLAVE2_ALARMS_X2"] = [
        {"alarmId": "7104", "faultId": "7100"},
        {"alarmId": "7114", "faultId": "7107"},
        {"alarmId": "7107|7657", "faultId": "6327|6328"},
        {"alarmId": "7107", "faultId": "7300|7308|7319"},
    ]

    var_dict["SLAVE2_ALARMS_XP_DSS"] = [{"alarmId": "7107|7657", "faultId": "62003"}]

    var_dict["SLAVE2_ALARMS_NR_DSS"] = [
        {"alarmId": "7114", "faultId": "7509|7511|7513"}
    ]

    var_dict["SLAVE2_ALARMS_LTE_DSS_CNI_127210"] = [
        {"alarmId": "7115|7107|7112", "faultId": "6129|6132|6134"}
    ]

    var_dict["SLAVE2_ALARMS_LTE_DSS_NO_CNI_127210"] = [
        {"alarmId": "7115", "faultId": "6129|6132|6134"}
    ]

    var_dict["SLAVE2_IGNORED_ALARMS_NO_CNI_127210"] = (
        [{"alarmId": "7222", "faultId": "9000"}]
        + SBTS_TEMP_IGNORED_ALARMS
        + ADMIN_ADDITIONAL_COMMON_IGNORED_ALARMS_NO_CNI_127210
    )

    var_dict["SLAVE2_IGNORED_ALARMS_CNI_127210"] = [
        {"alarmId": "7222", "faultId": "9000"}
    ] + SBTS_TEMP_IGNORED_ALARMS

    var_dict["SLAVE2_IGNORED_ALARMS_STABLE_BTS_POWERED_OFF"] = (
        [
            {"alarmId": "7115", "faultId": "7523|4405|6280"},
            {"alarmId": "7114", "faultId": "4452"},
            {"alarmId": "61029", "faultId": "61029"},
        ]
        + var_dict["SLAVE2_ALARMS_SYNC"]
        + var_dict["SLAVE2_ALARMS_X2"]
        + var_dict["SLAVE2_ALARMS_XP_DSS"]
    )

    var_dict["MASTER_CRITICAL_ALARMS"] = [] + SBTS_TEMP_CRITICAL_ALARMS

    var_dict["SLAVE_CRITICAL_ALARMS"] = [] + SBTS_TEMP_CRITICAL_ALARMS

    var_dict["SLAVE1_CRITICAL_ALARMS"] = [] + SBTS_TEMP_CRITICAL_ALARMS

    var_dict["SLAVE2_CRITICAL_ALARMS"] = [] + SBTS_TEMP_CRITICAL_ALARMS

    var_dict["MASTER_ALARMS_CNI_127210"] = {
        "MASTER_ALARMS_LTE_DSS": "MASTER_ALARMS_LTE_DSS_CNI_127210",
        "MASTER_IGNORED_ALARMS": "MASTER_IGNORED_ALARMS_CNI_127210",
    }

    var_dict["MASTER_ALARMS_NO_CNI_127210"] = {
        "MASTER_ALARMS_LTE_DSS": "MASTER_ALARMS_LTE_DSS_NO_CNI_127210",
        "MASTER_IGNORED_ALARMS": "MASTER_IGNORED_ALARMS_NO_CNI_127210",
    }

    var_dict["SLAVE_ALARMS_CNI_127210"] = {
        "SLAVE_ALARMS_LTE_DSS": "SLAVE_ALARMS_LTE_DSS_CNI_127210",
        "SLAVE_IGNORED_ALARMS": "SLAVE_IGNORED_ALARMS_CNI_127210",
    }

    var_dict["SLAVE_ALARMS_NO_CNI_127210"] = {
        "SLAVE_ALARMS_LTE_DSS": "SLAVE_ALARMS_LTE_DSS_NO_CNI_127210",
        "SLAVE_IGNORED_ALARMS": "SLAVE_IGNORED_ALARMS_NO_CNI_127210",
    }

    var_dict["SLAVE1_ALARMS_CNI_127210"] = {
        "SLAVE1_ALARMS_LTE_DSS": "SLAVE1_ALARMS_LTE_DSS_CNI_127210",
        "SLAVE1_IGNORED_ALARMS": "SLAVE1_IGNORED_ALARMS_CNI_127210",
    }

    var_dict["SLAVE1_ALARMS_NO_CNI_127210"] = {
        "SLAVE1_ALARMS_LTE_DSS": "SLAVE1_ALARMS_LTE_DSS_NO_CNI_127210",
        "SLAVE1_IGNORED_ALARMS": "SLAVE1_IGNORED_ALARMS_NO_CNI_127210",
    }

    var_dict["SLAVE2_ALARMS_CNI_127210"] = {
        "SLAVE2_ALARMS_LTE_DSS": "SLAVE2_ALARMS_LTE_DSS_CNI_127210",
        "SLAVE2_IGNORED_ALARMS": "SLAVE2_IGNORED_ALARMS_CNI_127210",
    }

    var_dict["SLAVE2_ALARMS_NO_CNI_127210"] = {
        "SLAVE2_ALARMS_LTE_DSS": "SLAVE2_ALARMS_LTE_DSS_NO_CNI_127210",
        "SLAVE2_IGNORED_ALARMS": "SLAVE2_IGNORED_ALARMS_NO_CNI_127210",
    }

    return var_dict


test_alarms_list = _build_variable_list()
