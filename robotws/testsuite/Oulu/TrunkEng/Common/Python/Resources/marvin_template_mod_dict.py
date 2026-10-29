"""
This dictionary is used for modifying the Marvin templates.
Using this dictionary, it is possible to have test-specific modifications all in one place
for easy modification in the future. Below is an example of an entry in the dictionary.
All entries should follow the format as-is.

Example entry:
    "test_name": {
        "technology": "4G",
        "details": [
            {
                "name": "SET1",
                "modifications": {
                    "ignore_regex_pattern": ["aaa", "bbb", "ccc"],
                    "operator": "<",
                    "limit": 5,
                    "verdict": "warning",
                }
            }
        ]
    }
"""

MARVIN_MOD_DICT = {
    "kill_rrom_from_smod": {
        "technology": "4G",
        "details": [
            {
                "name": "SET5",
                "modifications": {
                    "limit": 112
                }
            },
            {
                "name": "SET6",
                "modifications": {
                    "limit": 32
                }
            },
            {
                "name": "SET7",
                "modifications": {
                    "limit": 48
                }
            }
        ]
    }
}
