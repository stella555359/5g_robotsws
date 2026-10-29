def decode_uci(received_csi_report, SR_Flag=1):
    # Function converts the received CSI report to readable SR, RI, PMI and CQI.
    # Returns all the afore mentioned values as binary values
    # Req : 5G_RAN_UP_17831
    info_flag = 0
    MSN = format(int(received_csi_report[:2], 16), '0>8b')
    # Extract the most significant nibbles and represent as binary
    if SR_Flag == 0:
        if info_flag == 1:
            print("INFO : Scheduling Requests disabled")
        SR = "0"
        RI = MSN[0]
        PMI = MSN[1:3]
        CQI = MSN[3:7]
        reportHex = RI+PMI+CQI+'0'
    if SR_Flag == 1:
        if info_flag == 1:
            print("INFO : Scheduling Requests enabled")
        SR = MSN[:1]
        RI = MSN[1:2]
        PMI = MSN[2:4]
        CQI = MSN[4:8]
        reportHex = RI + PMI + CQI
    return str(SR), str(RI), str(PMI), str(CQI), hex(int(reportHex, 2))
