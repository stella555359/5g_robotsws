def cfra_rach(path):
    path = "/tmp/btslogs/CFRA/Syslog/syslog_5g.log"
    string_1_1 = "handleAckCRCOkForMsg3CFRA: UE attached after CFRA: xsfn="
    string_1_2 = "rnti="
    string_2_1 = "handleSuccessfulCrcWithCfra: rnti"
    string_2_2 = "raState=dl_awaitMsg3 subCellId=0"
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
        print("handleAckCRCOkForMsg3CFRA and handleSuccessfulCrcWithCfra count is ", string_1_count, string_2_count)
        return True
    else:
        if string_1_count < 3:
            print("handleAckCRCOkForMsg3CFRA count is :", string_1_count, ", which is less than 3")
        if string_2_count < 3:
            print("handleSuccessfulCrcWithCfra count is :", string_2_count, ", which is less than 3")
        return False
