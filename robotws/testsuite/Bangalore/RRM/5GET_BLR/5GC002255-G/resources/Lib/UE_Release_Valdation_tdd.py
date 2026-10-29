def validate_ue(path):
    print(path)
    Flag = True
    string_1 = "UE1: UE1: Released PDU session ID=3 using Gateway ID=3"
    string_2 = "UE2: UE2: Released PDU session ID=2 using Gateway ID=2"
    string_3 = "UE3: UE3: Released PDU session ID=1 using Gateway ID=1"
    string_4 = "UE1: UE-1: pduSessioncontext not found for pduSessionId=3, Skipped stats logging!"
    string_5 = "UE1: detached"
    string_6 = "UE2: UE-2: pduSessioncontext not found for pduSessionId=2, Skipped stats logging!"
    string_7 = "UE2: detached"
    string_8 = "UE3: UE-3: pduSessioncontext not found for pduSessionId=1, Skipped stats logging!"
    string_9 = "UE3: detached"

    for i in range(1, 10):
        globals()[f"string_{i}_count"] = 0

    file = open(path)
    for line in file.readlines():
        for i in range(1, 10):
            if eval('string_%s' % i) in line:
                print(line)
                globals()[f"string_{i}_count"] = eval(f"string_{i}_count") + 1
    file.close()

    for i in range(1, 10):
        if eval('string_%s_count' % i) == 0:
            print(eval('string_%s' % i), "is not present in the log")
            Flag = False
    if Flag:
        return True
    else:
        return False
