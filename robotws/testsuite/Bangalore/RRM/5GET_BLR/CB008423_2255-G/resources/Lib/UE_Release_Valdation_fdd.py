def validate_ue(path):
    print(path)
    string_1_1 = "UE3: UE3: Released PDU session ID=1 using Gateway ID=1"
    string_1_2 = "UE4: UE4: Released PDU session ID=4 using Gateway ID=4"
    string_2_1 = "UE3: UE-3: pduSessioncontext not found for pduSessionId=1, Skipped stats logging!"
    string_2_2 = "UE3: detached"
    string_3_1 = "UE4: UE-4: pduSessioncontext not found for pduSessionId=4, Skipped stats logging!"
    string_3_2 = "UE4: detached"
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
            string_1_count = string_1_count + 1
        if string_2_1 in line:
            print(line)
        if string_2_2 in line:
            print(line)
            string_2_count = string_2_count + 1
        if string_3_1 in line:
            print(line)
        if string_3_2 in line:
            print(line)
            string_3_count = string_3_count + 1
    file1.close()

    if string_1_count == 1 and string_2_count == 1 and string_3_count == 1:
        print("Released PDU session ID=1 and ID=4 using gateways:", string_1_count, string_2_count)
        return True
    else:
        if string_1_count < 1:
            print("Released PDU session ID=1 using Gateway ID=1 count is :", string_1_count, ", which is less than 1")
        if string_2_count < 1:
            print("Released PDU session ID=4 using Gateway ID=4 count is :", string_2_count, ", which is less than 1")
        return False
