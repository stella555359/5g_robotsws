sfp_lock_action_dict = {
    "1": {
        "expected_alarms": {},
        "need_unlock_to_on_air": False,
        "impacted_cells": [1, 2, 3, 4],
        "timeout": "5 min"
    },
    "2": {
        "expected_alarms": {},
        "need_unlock_to_on_air": False,
        "impacted_cells": [1, 2, 3, 4],
        "timeout": "5 min"
    },
    "7": {
        "expected_alarms": {
            "10": "No connection to unit"
        },
        "need_unlock_to_on_air": True,
        "impacted_cells": [5, 6],
        "timeout": "10 min"
    },
    "8": {
        "expected_alarms": {
            "1868": "BTS configuration error (not enough HW for LCR)"
        },
        "need_unlock_to_on_air": True,
        "impacted_cells": [5, 6],
        "timeout": "20 min"
    },
    "9": {
        "expected_alarms": {
            "1868": "BTS configuration error (not enough HW for LCR)"
        },
        "need_unlock_to_on_air": True,
        "impacted_cells": [5, 6],
        "timeout": "20 min"
    },
    "10": {
        "expected_alarms": {
            "10": "No connection to unit"
        },
        "need_unlock_to_on_air": True,
        "impacted_cells": [7, 8],
        "timeout": "10 min"
    },
    "11": {
        "expected_alarms": {
            "1868": "BTS configuration error (not enough HW for LCR)"
        },
        "need_unlock_to_on_air": True,
        "impacted_cells": [7, 8],
        "timeout": "20 min"
    },
    "12": {
        "expected_alarms": {
            "1868": "BTS configuration error (not enough HW for LCR)"
        },
        "need_unlock_to_on_air": True,
        "impacted_cells": [7, 8],
        "timeout": "20 min"
    },
}
