def validate_ue(path):
    print(path)
    string_1_1 = "UE1: UE1: Released PDU session ID=3 using Gateway ID=3"
    string_1_2 = "UE2: UE2: Released PDU session ID=2 using Gateway ID=2"
    string_1_3 = "UE3: UE3: Released PDU session ID=1 using Gateway ID=1"
    string_2_1 = "UUE1: UE-1: pduSessioncontext not found for pduSessionId=3, Skipped stats logging!"
    string_2_2 = "UE1: detached"
    string_2_3 = "UE2: UE-2: pduSessioncontext not found for pduSessionId=2, Skipped stats logging!"
    string_3_1 = "UE2: detached"
    string_3_2 = "UE3: UE-3: pduSessioncontext not found for pduSessionId=1, Skipped stats logging!"
    string_3_3 = "UE3: detached"
    string_1_count = 0
    string_2_count = 0
    string_3_count = 0
    file1 = open(path)
    lines = file1.readlines()
    for line in lines:
        if string_1_1 in line:
            print(line)
        if string_1_2 in line:
            print(line)
        if string_1_3 in line:
            print(line)
            string_1_count = string_1_count + 1
        if string_2_1 in line:
            print(line)
        if string_2_2 in line:
            print(line)
        if string_2_3 in line:
            print(line)
            string_2_count = string_2_count + 1
        if string_3_1 in line:
            print(line)
        if string_3_2 in line:
            print(line)
        if string_3_3 in line:
            print(line)
            string_3_count = string_3_count + 1
    file1.close()

    if string_1_count == 1 and string_2_count == 1 and string_3_count == 1:
        print("Released PDU session", string_1_count, string_2_count, string_3_count)
        return True
    else:
        if string_1_count < 1:
            print("Released PDU session ID=3 using Gateway ID=3 count is :", string_1_count, ", which is less than 1")
        if string_2_count < 1:
            print("Released PDU session ID=2 using Gateway ID=2 count is :", string_2_count, ", which is less than 1")
        if string_3_count < 1:
            print("Released PDU session ID=1 using Gateway ID=1 count is :", string_3_count, ", which is less than 1")
        return False
