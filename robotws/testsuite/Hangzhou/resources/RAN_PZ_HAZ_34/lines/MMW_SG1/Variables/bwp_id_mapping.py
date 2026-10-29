"""
Author: Ding Binmei
Please do not update this file without contacting with author.
"""

# Default predefined ID. Can diff based your own config.
# BWP_ID_MAPPING = {
#     'TDD_1116_0_100M': {'initial': '7', 'dedicate': '77'},
#     'TDD_1116_0_60M': {'initial': '7', 'dedicate': '73'},
#     'TDD_1116_3_100M': {'initial': '8', 'dedicate': '87'},
#     'TDD_1070_100M': {'initial': '6', 'dedicate': '67'},
#     'TDD_1070_60M': {'initial': '6', 'dedicate': '63'},
#     'TDD_1070_20M': {'initial': '6', 'dedicate': '60'},
#     'FDD_10M': {'initial': '2', 'dedicate': '21'},
#     'FDD_20M': {'initial': '5', 'dedicate': '35'}
# }

# TMP value for TL254 && TL049, will be updated to above default values when all 3 CA TLs has aligned BWP
BWP_ID_MAPPING = {
    'TDD_1116_0_100M': {'initial': '9', 'dedicate': '91'},
    'TDD_1116_0_60M': {'initial': '3', 'dedicate': '31'},
    'TDD_1116_3_100M': {'initial': '10', 'dedicate': '101'},
    'TDD_8406_100M': {'initial': '20', 'dedicate': '50'},
    'TDD_8406_60M': {'initial': '20', 'dedicate': '51'},
    'TDD_1070_100M': {'initial': '7', 'dedicate': '77'},
    'TDD_1070_60M': {'initial': '7', 'dedicate': '73'},
    'TDD_1070_20M': {'initial': '6', 'dedicate': '63'},
    'FDD_10M': {'initial': '5', 'dedicate': '35'},
    'FDD_20M': {'initial': '2', 'dedicate': '21'},
    'FDD_20M_2329': {'initial': '2', 'dedicate': '21'}  # Will be removed after other TLs has aligned BWP
}
