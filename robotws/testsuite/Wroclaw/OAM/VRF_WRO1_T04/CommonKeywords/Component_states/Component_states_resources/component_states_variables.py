proper_structure = {
    'ASIRMOD': '["radioModules"]["asirmod"]',
    'BBMOD':   '["basebandModules"]',
    'CABLINK': '["cables"]',
    'FAN':     '["cabinets"]',
    'GNCEL':   '["cells"]["gsm"]',
    'GNSSE':   '["gnsse"]',
    'LNCEL':   '["cells"]["lte"]',
    'NRCELL':  '["cells"]["nr"]',
    'NRDU':    '["nrDU"]',
    'RMOD':    '["radioModules"]["rmod"]',
    'SFP':     '',
    'SMOD':    '["systemModules"]'
}

common_statuses = {
    "availabilityStatus":  {
        "online":          ["Online", None],
        "degraded":        ["Degraded", "degraded"],
        "dependency":      ["Dependency", "dependency"],
        "failed":          ["Failed", "failed"],
        "notinstalled":    ["NotInstalled", "not installed"],
        "offline":         ["Offline", "off line"],
        "poweroff":        ["PowerOff", "power off"]
    },
    "administrativeState":  {
        "notknown":        ["NotKnown", None],
        "locked":          ["Locked", "locked"],
        "shuttingdown":    ["ShuttingDown", "Shutting Down", "shutting down"],
        "unlocked":        ["Unlocked", "unlocked"]
    },
    "operationalState":  {
        "commissioned":    ["Commissioned", "commissioned"],
        "configured":      ["Configured", "configured"],
        "disabled":        ["Disabled", "disabled"],
        "enabled":         ["Enabled", "enabled"],
        "initializing":    ["Initializing", "initializing"],
        "integratedtoran": ["IntegratedToRan", "integrated to RAN"],
        "notcommissioned": ["NotCommissioned", "notCommissioned"],
        "onair":           ["OnAir", "onAir"],
        "test":            ["Test", "test"],
        "testing":         ["Testing", "testing"]
    },
    "blockingState":  {
        "blocked":         ["Blocked"],
        "blocking":        ["Blocking"],
        "unblocked":       ["Unblocked"],
        "unblocking":      ["Unblocking"]
    },
    "usageState":  {
        "active":          ["Active"],
        "busy":            ["Busy", None],
        "idle":            ["Idle"]
    }
}
