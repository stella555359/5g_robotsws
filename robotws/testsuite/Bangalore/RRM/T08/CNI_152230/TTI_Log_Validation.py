from taf.analyzer.ttitrace_eventdecoder import TtitraceReader
import json


def get_ttievents_pre(file_name):
    #    result = defaultdict(list)
    output = {}
    print(file_name)
    with open(file_name, 'r') as f:
        data = json.load(f)
    for event in data.get("events", []):
        if "dlFdSchedData" not in event:
            continue
        slot = (
            event["dlFdSchedData"]
            .get("body", {})
            .get("eventHeader", {})
            .get("slot")
        )
        print("DEBUG slot =", slot)
        if slot in (8, 9, 18, 19):
            output["slot"] = slot
            return output
    return output
