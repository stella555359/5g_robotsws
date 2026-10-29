commands_to_trigger_alarm_on_ru = [
    {
        "echo": [
            "\"/ action create ConfigAccess /CI/ConfigAccess_Module /module\"",
            "'/CI/ConfigAccess_Module action fetch DECODED \"tempest_inst1.bin\" \"/ram/tempest_inst1.json\"'"
        ]
    },
    {
        "cp": {}
    },
    {
        "sed": [r" -i '0,/\"tempOffset\": [-+]\?[0-9.]\+/s//\"tempOffset\": 62.0/'"]
    },
    {
        "echo": [
            "'/CI/ConfigAccess_Module action store TEMPORARY DECODED \"tempest_inst1.bin\" "
            "\"/ram/tempest_inst1.json\"'",
            "'/CI/ConfigAccess_Module action update'"
        ]
    }
]

commands_to_change_time_on_ru = [
    {
        "echo": [
            "\"/ action create ConfigAccess /CI/ConfigAccess_Module /module \"",
            '\'/CI/ConfigAccess_Module action fetch DECODED "black_box_logger.bin" "/tmp/black_box_logger.json"\''
        ]
    },
    {
        "cp": []
    },
    {
        "sed": [
            r"-i 's#\"timeBetweenSaveOnNVM\": [-+]\?[0-9.]\+,#\"timeBetweenSaveOnNVM\": 60,#g'",
            r"-i 's#\"periodicTime\": [-+]\?[0-9.]\+,#\"periodicTime\": 40,#g'"
        ]
    },
    {
        "echo": [
            '\'/CI/ConfigAccess_Module action store PERMANENT DECODED "black_box_logger.bin" '
            '"/tmp/black_box_logger.json"\'',

        ]
    }
]

expected_items_rf_bbox_5 = [
    r"Item type: Isti",
    r"Reset Counter: (\d+)",
    r"Item id: MADE0:PALAU",  # r"Item type: Temperature",
    r"Item type: Voltage",
    r"Item type: cpu_load",
    r"Item type: Optical_lvl_signal"
]

occur_items_rf_bbox_5 = [
    {
        "item": "Periodical trigger occur times:",
        "change": True,
        "first_occurence": "",
        "second_occurence": ""
    },
    {
        "item": "Temperature gradient trigger occur times:",
        "change": False,
        "first_occurence": "",
        "second_occurence": ""
    },
    {
        "item": "Reset trigger occur times:",
        "change": True,
        "first_occurence": "",
        "second_occurence": ""
    },
]

ADDITIONAL_ALARMS_FOR_TESTS = {
    "trigger_occur": ["No connection to unit", "Fault signature for crash or failure"],
    "enhancement_of_temerature": ["No connection to unit", "Fault signature for crash or failure",
                                  "Radio Diagnostic Files collected"],
    "fault_history": ["Unit (module) dangerously overheating", "RF Power decreased", "No connection to unit",
                      "Fault signature for crash or failure", "Pipe dangerously overheating",
                      "Radio Diagnostic Files collected"],
    "after_ru_reboot": ["Radio Diagnostic Files collected", "BTS Reset Cause"]
}
