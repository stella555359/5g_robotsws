from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")

MRBTS_ID = tl.gnbs[0].instance_id
# NRBTS_ID = tl.gnbs[0].global_bts_id
MRBTS = "MRBTS-" + str(MRBTS_ID)
# NRBTS = "NRBTS-" + str(NRBTS_ID)

add_note_object = [
    {
        "distName": MRBTS + "/" + "MNL-1/NOTES-1",
        "operation": "create",
        "parameters": []
    },
    {
        "distName": MRBTS + "/" + "MNL-1/NOTES-1/NOTE-1",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "attribute",
                "value": [
                    {"attribName": "enableInformativeAlarmReport", "attribValue": "R5C6"}
                ],
                "operation": "update"
            }
        ]
    }
]

delete_note_object = [
    {
        "distName": MRBTS + "/" + "MNL-1/NOTES-1",
        "operation": "delete",
        "parameters": []
    }
]
