msg1 = ["UlData_PrachReceiveInd"]
msg2 = ["DlData_PdschSendReq",
        "DlData_PdschPayloadTbSendReq", "DlData_PdcchSendReq"]
msg3 = ["UlData_PuschReceiveReq", "UlData_PuschReceiveRespLo",
        "UlData_PuschReceiveRespHarqU", "UlData_PuschReceiveRespPs"]
msg4 = ["DlData_PdcchSendReq"]
prach_message = [msg1, msg2, msg3, msg4]


def analyze_file(bi_file):
    fh = open(bi_file)
    data = fh.read()
    fh.close()
    i = 0
    ret = ""
    for msg_i in prach_message:
        i = i+1
        for msg in msg_i:
            n = data.count(msg)
            # print("n={},msg={}".format(n,msg))
            if n == 0:
                log1 = "ERR:There is 0 item {} in msg{}".format(msg, i)
                print(log1)
                if ret != "":
                    ret = ret+"\n"+log1
                else:
                    ret = ret+log1
            else:
                log1 = "There is {} items {} in msg{}".format(n, msg, i)
                print(log1)
                if ret != "":
                    ret = ret+"\n"+log1
                else:
                    ret = ret+log1
    return ret
# analyze_file("msg_file.txt")
