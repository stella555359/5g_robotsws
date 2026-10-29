import time
import shutil


def validate_ue(path):
    print(path)
    Flag = True
    string_1 = "UE3: UE3: Released PDU session ID=1 using Gateway ID=1"
    string_2 = "UE4: UE4: Released PDU session ID=4 using Gateway ID=4"
    string_3 = "UE3: UE-3: pduSessioncontext not found for pduSessionId=1, Skipped stats logging!"
    string_4 = "UE3: detached"
    string_5 = "UE4: UE-4: pduSessioncontext not found for pduSessionId=4, Skipped stats logging!"
    string_6 = "UE4: detached"

    for i in range(1, 7):
        globals()[f"string_{i}_count"] = 0
    time.sleep(10)
    shutil.copy2(path, '/home/ute/Downloads/runtime_test.log')
    file = open(path)
    for line in file.readlines():
        for i in range(1, 7):
            if eval('string_%s' % i) in line:
                print(line)
                globals()[f"string_{i}_count"] = eval(f"string_{i}_count") + 1
    file.close()

    for i in range(1, 7):
        if eval('string_%s_count' % i) == 0:
            print(eval('string_%s' % i), "is not present in the log")
            Flag = False
    return Flag
