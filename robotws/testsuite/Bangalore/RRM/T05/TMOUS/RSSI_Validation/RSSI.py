import json


def Convert_validate_RSSI(json_file, ANT):
    ANT_VAL = []
    Result = []
    Filter_ANT_VAL = []
    Value = Convert_json(json_file)
    print(
        "Validation : \n\t1. 1st value, last value and any one other value should be 0 ('-')"
        + " \n\t2. 2nd value and last but 2nd value should be between -40 and -70"
        + " \n\t3. Any one value should be between -70 and -80"
        + " \n\t4. Difference between all 4 antenna lines should be within -3 and +3 range\n"
    )

    for index in range(0, 4):
        Val, filter_val, res = Verify_RSSI(Value, index, ANT)
        ANT_VAL.append(Val)
        Result.append(res)
        Filter_ANT_VAL.append(filter_val)

    if False not in Result:
        res = Validate_ANT_VAL(ANT_VAL)
        return ANT_VAL, res
    else:
        return ANT_VAL, False


def Convert_json(json_file):
    with open(json_file, "r") as file:
        data = json.load(file)
    return data


def Verify_RSSI(RSSI_value, index, dist):
    Value = list(
        RSSI_value["RSSI"][0]["antennaLines"][int(index)]["measureDatas"][dist].values()
    )
    start = "-"
    Result = []
    Res = False
    for i in range(0, len(Value) - 1):
        if Value[i] == start:
            if Value[i + 1] != start:
                Result.append(Value[i])
                start = Value[i + 1]
    Result.append(Value[-1])
    print("RSSI value changes from WEBEM for ANT", int(index), ":", Result)
    Result = [x if x != "-" else 0 for x in Result]
    if Result.count(0) >= 4 and Result[0] == 0 and Result[-1] == 0:
        if -40 > Result[1] > -70 and -40 > Result[-2] > -70:
            for val in Result:
                if -70 > val > -80:
                    print("Result: RSSI validation passed for ANT", int(index), "\n")
                    Res = True
                    break
    if Res is False:
        print("Result: RSSI validation failed for ANT", int(index), "\n")
    return Value, Result, Res


def Validate_ANT_VAL(ANT_Val):
    res = []
    for index in range(0, len(ANT_Val[0])):
        ANT_Val[0] = [x if x != "-" else 0 for x in ANT_Val[0]]
        ANT_Val[1] = [x if x != "-" else 0 for x in ANT_Val[1]]
        ANT_Val[2] = [x if x != "-" else 0 for x in ANT_Val[2]]
        ANT_Val[3] = [x if x != "-" else 0 for x in ANT_Val[3]]

    for index in range(0, len(ANT_Val[0])):
        if -3 <= (ANT_Val[0][index]) - (ANT_Val[1][index]) <= 3:
            if -3 <= (ANT_Val[2][index]) - (ANT_Val[3][index]) <= 3:
                if -3 <= (ANT_Val[0][index]) - (ANT_Val[3][index]) <= 3:
                    res.append(True)
    if res.count(True) == len(ANT_Val[0]):
        print("Difference between each antenna line values are within range")
        return True
    else:
        print(
            "Difference between each antenna line values are not within range, please check individual values"
        )
        return False
