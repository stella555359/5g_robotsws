LEGACY_CELL_ENERGY_SAVING_STATES_REQUIREMENTS = {
    "notenergysaving": {
        "assert": 'operationalState=regex"(?i)Enabled"',
        "assert_no": 'availabilityStatus=regex"(?i)Degraded"',
    },
    "energysaving": {
        "assert": 'operationalState=regex"(?i)Disabled", availabilityStatus=regex"(?i)off line"',
        "assert_no": 'availabilityStatus=regex"(?i)Degraded"',
    },
    "reducedenergysaving": {
        "assert": 'operationalState=regex"(?i)Enabled"',
        "assert_no": 'availabilityStatus=regex"(?i)Degraded"',
    },
    "switchingoffrtx": {
        "assert": 'operationalState=regex"(?i)Enabled"',
        "assert_no": 'availabilityStatus=regex"(?i)Degraded"',
    },
    "switchingoff": {
        "assert": 'operationalState=regex"(?i)Enabled"',
        "assert_no": 'availabilityStatus=regex"(?i)Degraded"',
    },
    "switchingontx": {
        "assert": 'operationalState=regex"(?i)Enabled"',
        "assert_no": 'availabilityStatus=regex"(?i)Degraded"',
    }
}
