def cbra_rach(path):
    path = "/tmp/btslogs/CFRA/Syslog/syslog_5g.log"
    string_1_1 = "UE attached: xsfn="
    string_1_2 = "rnti="
    string_2_1 = "handleRaContResSuccessUe: rnti="
    string_2_2 = "raState=dl_awaitUlNsaContResAck subCellIndex=0"
    string_1_count = 0
    string_2_count = 0
    with open(path, "r") as file1:
        for line in file1:
            if string_1_1 in line and string_1_2 in line:
                string_1_count = string_1_count + 1
            if string_2_1 in line and string_2_2 in line:
                string_2_count = string_2_count + 1
        file1.close()

    if string_1_count == 3 and string_2_count == 3:
        print("handleAckNackForContRes and handleRaContResSuccessUe count is ", string_1_count, string_2_count)
        return True
    else:
        if string_1_count < 3:
            print("handleAckNackForContRes count is :", string_1_count, ", which is less than 3")
        if string_2_count < 3:
            print("handleRaContResSuccessUe count is :", string_2_count, ", which is less than 3")
        return False
