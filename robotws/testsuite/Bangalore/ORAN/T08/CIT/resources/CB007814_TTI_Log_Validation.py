from collections import defaultdict
from taf.analyzer.ttitrace_eventdecoder import TtitraceReader


def get_ttievents(file_name):
    result = defaultdict(list)
    output = {}

    print(file_name)

    with open(file_name, 'rb') as file_obj:
        for event in TtitraceReader(file_obj=file_obj):
            if event.type == "dlFdSchedData":
                result[event.type].append(dict(event.data))

        for value in result.values():
            for i in range(len(value)):
                if (value[i]["numOfPrb"] == 106 and
                        value[i]["rrmDlUsedMcs"] == 27 and
                        value[i]["numOfLayers"] == "RANK3"):
                    output["numOfPrb"] = value[i]["numOfPrb"]
                    output["rrmDlUsedMcs"] = value[i]["rrmDlUsedMcs"]
                    output["numOfLayers"] = value[i]["numOfLayers"]

    return output
