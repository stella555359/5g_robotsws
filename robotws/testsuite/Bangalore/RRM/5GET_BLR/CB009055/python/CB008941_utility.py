class pucch_receive_req:
    count = 0
    invalid = 0
    regions_found = {}
    max_number_pucch_boundary = 8  # Update it to 8
    no_of_stored_records = 0

    def __init__(self):
        self.numPucchBoundaries = 0
        self.numOfPrb = []
        self.startPrb = []
        self.startSymbol = []
        self.numOfSymbol = []
        self.next_node = None

    def verify_regions(self, regions, multided_ps_dyn=0):
        tmp = self
        if multided_ps_dyn == 1:
            region_cat = ["p_csi_region_lower_bh",
                          "p_csi_region_lower_ah",
                          "p_csi_region_upper_bh",
                          "p_csi_region_upper_ah",
                          "p_csi_p_csi_region_bh",
                          "p_csi_p_csi_region_ah",
                          "sr_region_lower_bh",
                          "sr_region_lower_ah",
                          "harq_region_lower_bh",
                          "harq_region_lower_ah",
                          "sr_region_upper_bh",
                          "sr_region_upper_ah",
                          "harq_region_upper_bh",
                          "harq_region_upper_ah",
                          "sr_lower_harq_lower_bh",
                          "sr_lower_harq_lower_ah",
                          "sr_lower_sr_upper_bh",
                          "sr_lower_sr_upper_ah",
                          "sr_lower_harq_upper_bh",
                          "sr_lower_harq_upper_ah",
                          "harq_lower_sr_upper_bh",
                          "harq_lower_sr_upper_ah",
                          "harq_lower_harq_upper_bh",
                          "harq_lower_harq_upper_ah",
                          "sr_upper_harq_upper_bh",
                          "sr_upper_harq_upper_ah",
                          "dynamic_p_csi_lower_bh",
                          "dynamic_p_csi_lower_ah",
                          "dynamic_p_csi_upper_bh",
                          "dynamic_p_csi_upper_ah",
                          "dynamic_p_csi_lower_p_csi_upper_bh",
                          "dynamic_p_csi_lower_p_csi_upper_ah",
                          "commonpucch_upper_bh",
                          "commonpucch_upper_ah",
                          "commonpucch_lower_bh",
                          "commonpucch_lower_ah"

                          ]
        else:
            region_cat = ["p_csi_region_lower_bh",
                          "p_csi_region_lower_ah",
                          "harq_region_lower_bh",
                          "harq_region_lower_ah",
                          "sr_region_lower_bh",
                          "sr_region_lower_ah",
                          "harq_region_upper_bh",
                          "harq_region_upper_ah",
                          "sr_region_upper_bh",
                          "sr_region_upper_ah",
                          "p_csi_region_upper_bh",
                          "p_csi_region_upper_ah",
                          "p_csi_harq_sr_upper_bh",
                          "p_csi_harq_sr_upper_ah",
                          "harq_sr_upper_bh",
                          "harq_sr_upper_ah",
                          "p_csi_harq_upper_bh",
                          "p_csi_harq_upper_ah",
                          "sr_harq_lower_bh",
                          "sr_harq_lower_ah",
                          "sr_harq_upper_bh",
                          'sr_harq_upper_ah',
                          "harq_p_csi_lower_bh",
                          "harq_p_csi_lower_ah",
                          "sr_harq_p_csi_lower_bh",
                          "sr_harq_p_csi_lower_ah",
                          "dynamic_sr_harq_p_csi_lower_bh",
                          "dynamic_sr_harq_p_csi_lower_ah",
                          "dynamic_harq_p_csi_lower_bh",
                          "dynamic_harq_p_csi_lower_ah",
                          "dynamic_p_csi_region_lower_bh",
                          "dynamic_p_csi_region_lower_ah",
                          "dynamic_p_csi_region_upper_bh",
                          "dynamic_p_csi_region_upper_ah",
                          "dynamic_p_csi_harq_upper_bh",
                          "dynamic_p_csi_harq_upper_ah",
                          "dynamic_p_csi_harq_sr_upper_ah",
                          "dynamic_p_csi_harq_sr_upper_bh",
                          "commonpucch_upper_bh",
                          "commonpucch_upper_ah",
                          "commonpucch_lower_bh",
                          "commonpucch_lower_ah"
                          ]

        for area in region_cat:
            pucch_receive_req.regions_found[area] = 0
        while tmp is not None:
            total_count = len(tmp.numOfPrb)
            for idx in range(total_count):
                if int(tmp.numOfPrb[idx]) != 0:
                    startPrb = tmp.startPrb[idx]
                    numOfPrb = tmp.numOfPrb[idx]
                    startSymbol = tmp.startSymbol[idx]
                    numOfSymbol = tmp.numOfSymbol[idx]
                    flag = 1
                    if flag == 1 and (regions["commonpucch_upper"].startPRB + 1) == startPrb and 1 == numOfPrb:
                        flag = 0
                        if (startSymbol == regions["commonpucch_upper"].startSym[0] and
                                numOfSymbol == regions["commonpucch_upper"].numOfSym):
                            pucch_receive_req.regions_found["commonpucch_upper_bh"] += 1
                        elif (startSymbol == regions["commonpucch_upper"].startSym[1] and
                              numOfSymbol == regions["commonpucch_upper"].numOfSym):
                            pucch_receive_req.regions_found["commonpucch_upper_ah"] += 1
                        else:
                            pucch_receive_req.invalid += 1
                            print("Invalid boundary: commonpucch_upper startprb{0} numprb:{1} ss:{2} "
                                  "ns:{3}".format(startPrb, numOfPrb, startSymbol, numOfSymbol))

                    if flag == 1 and regions["commonpucch_upper"].startPRB == startPrb and \
                            (regions["commonpucch_upper"].numOfPrb == numOfPrb or numOfPrb == 1):
                        flag = 0
                        if (startSymbol == regions["commonpucch_upper"].startSym[0] and
                                numOfSymbol == regions["commonpucch_upper"].numOfSym):
                            pucch_receive_req.regions_found["commonpucch_upper_bh"] += 1
                        elif (startSymbol == regions["commonpucch_upper"].startSym[1] and
                              numOfSymbol == regions["commonpucch_upper"].numOfSym):
                            pucch_receive_req.regions_found["commonpucch_upper_ah"] += 1
                        else:
                            pucch_receive_req.invalid += 1
                            print("Invalid boundary: commonpucch_upper startprb{0} numprb:{1} ss:{2} "
                                  "ns:{3}".format(startPrb, numOfPrb, startSymbol, numOfSymbol))

                    if flag == 1 and (regions["commonpucch_lower"].startPRB + 1) == startPrb and 1 == numOfPrb:
                        flag = 0
                        if (startSymbol == regions["commonpucch_lower"].startSym[0] and
                                numOfSymbol == regions["commonpucch_lower"].numOfSym):
                            pucch_receive_req.regions_found["commonpucch_lower_bh"] += 1
                        elif (startSymbol == regions["commonpucch_lower"].startSym[1] and
                              numOfSymbol == regions["commonpucch_lower"].numOfSym):
                            pucch_receive_req.regions_found["commonpucch_lower_ah"] += 1
                        else:
                            pucch_receive_req.invalid += 1
                            print("Invalid boundary: commonpucch_lower startprb{0} numprb:{1} ss:{2} "
                                  "ns:{3}".format(startPrb, numOfPrb, startSymbol, numOfSymbol))

                    if flag == 1 and regions["commonpucch_lower"].startPRB == startPrb and \
                            (regions["commonpucch_lower"].numOfPrb == numOfPrb or numOfPrb == 1):
                        flag = 0
                        if (startSymbol == regions["commonpucch_lower"].startSym[0] and
                                numOfSymbol == regions["commonpucch_lower"].numOfSym):
                            pucch_receive_req.regions_found["commonpucch_lower_bh"] += 1
                        elif (startSymbol == regions["commonpucch_lower"].startSym[1] and
                              numOfSymbol == regions["commonpucch_lower"].numOfSym):
                            pucch_receive_req.regions_found["commonpucch_lower_ah"] += 1
                        else:
                            pucch_receive_req.invalid += 1
                            print("Invalid boundary: commonpucch_upper startprb{0} numprb:{1} ss:{2} "
                                  "ns:{3}".format(startPrb, numOfPrb, startSymbol, numOfSymbol))
                    if multided_ps_dyn == 1:
                        if flag == 1 and regions["p_csi_region_lower"].startPRB == startPrb and \
                                regions["p_csi_region_lower"].numOfPrb == numOfPrb:
                            flag = 0
                            if (startSymbol == regions["p_csi_region_lower"].startSym[0] and
                                    numOfSymbol == regions["p_csi_region_lower"].numOfSym):
                                pucch_receive_req.regions_found["p_csi_region_lower_bh"] += 1
                            elif (startSymbol == regions["p_csi_region_lower"].startSym[1] and
                                  numOfSymbol == regions["p_csi_region_lower"].numOfSym):
                                pucch_receive_req.regions_found["p_csi_region_lower_ah"] += 1
                            else:
                                pucch_receive_req.invalid += 1
                                print("Invalid boundary: p_csi_region_lower startprb{0} numprb:{1} ss:{2} "
                                      "ns:{3}".format(startPrb, numOfPrb, startSymbol, numOfSymbol))

                        if flag == 1 and regions["p_csi_region_upper"].startPRB == startPrb and \
                                regions["p_csi_region_upper"].numOfPrb == numOfPrb:
                            flag = 0
                            if (startSymbol == regions["p_csi_region_upper"].startSym[0] and
                                    numOfSymbol == regions["p_csi_region_upper"].numOfSym):
                                pucch_receive_req.regions_found["p_csi_region_upper_bh"] += 1
                            elif (startSymbol == regions["p_csi_region_upper"].startSym[1] and
                                  numOfSymbol == regions["p_csi_region_upper"].numOfSym):
                                pucch_receive_req.regions_found["p_csi_region_upper_ah"] += 1
                            else:
                                pucch_receive_req.invalid += 1
                                print("Invalid boundary: p_csi_region_upper startprb{0} numprb:{1} ss:{2} "
                                      "ns:{3}".format(startPrb, numOfPrb, startSymbol, numOfSymbol))

                        if flag == 1 and regions["p_csi_p_csi_region"].startPRB == startPrb and \
                                regions["p_csi_p_csi_region"].numOfPrb == numOfPrb:
                            flag = 0
                            if (startSymbol == regions["p_csi_p_csi_region"].startSym[0] and
                                    numOfSymbol == regions["p_csi_p_csi_region"].numOfSym):
                                pucch_receive_req.regions_found["p_csi_p_csi_region_bh"] += 1
                            elif (startSymbol == regions["p_csi_p_csi_region"].startSym[1] and
                                  numOfSymbol == regions["p_csi_p_csi_region"].numOfSym):
                                pucch_receive_req.regions_found["p_csi_p_csi_region_ah"] += 1
                            else:
                                pucch_receive_req.invalid += 1
                                print("Invalid boundary: p_csi_p_csi_region startprb{0} numprb:{1} ss:{2} "
                                      "ns:{3}".format(startPrb, numOfPrb, startSymbol, numOfSymbol))

                        if flag == 1 and regions["sr_region_lower"].startPRB == startPrb and \
                                regions["sr_region_lower"].numOfPrb == numOfPrb:
                            flag = 0
                            if (startSymbol == regions["sr_region_lower"].startSym[0] and
                                    numOfSymbol == regions["sr_region_lower"].numOfSym):
                                pucch_receive_req.regions_found["sr_region_lower_bh"] += 1
                            elif (startSymbol == regions["sr_region_lower"].startSym[1] and
                                  numOfSymbol == regions["sr_region_lower"].numOfSym):
                                pucch_receive_req.regions_found["sr_region_lower_ah"] += 1
                            else:
                                pucch_receive_req.invalid += 1
                                print("Invalid boundary: sr_region_lower startprb{0} numprb:{1} ss:{2} "
                                      "ns:{3}".format(startPrb, numOfPrb, startSymbol, numOfSymbol))

                        if flag == 1 and regions["harq_region_lower"].startPRB == startPrb and \
                                regions["harq_region_lower"].numOfPrb == numOfPrb:
                            flag = 0
                            if (startSymbol == regions["harq_region_lower"].startSym[0] and
                                    numOfSymbol == regions["harq_region_lower"].numOfSym):
                                pucch_receive_req.regions_found["harq_region_lower_bh"] += 1
                            elif (startSymbol == regions["sr_region_lower"].startSym[1] and
                                  numOfSymbol == regions["sr_region_lower"].numOfSym):
                                pucch_receive_req.regions_found["harq_region_lower_ah"] += 1
                            else:
                                pucch_receive_req.invalid += 1
                                print("Invalid boundary: harq_region_lower startprb{0} numprb:{1} ss:{2} "
                                      "ns:{3}".format(startPrb, numOfPrb, startSymbol, numOfSymbol))

                        if flag == 1 and regions["sr_region_upper"].startPRB == startPrb and \
                                regions["sr_region_upper"].numOfPrb == numOfPrb:
                            flag = 0
                            if (startSymbol == regions["sr_region_upper"].startSym[0] and
                                    numOfSymbol == regions["sr_region_upper"].numOfSym):
                                pucch_receive_req.regions_found["sr_region_upper_bh"] += 1
                            elif (startSymbol == regions["sr_region_upper"].startSym[1] and
                                  numOfSymbol == regions["sr_region_upper"].numOfSym):
                                pucch_receive_req.regions_found["sr_region_upper_ah"] += 1
                            else:
                                pucch_receive_req.invalid += 1
                                print("Invalid boundary: sr_region_upper startprb{0} numprb:{1} ss:{2} "
                                      "ns:{3}".format(startPrb, numOfPrb, startSymbol, numOfSymbol))

                        if flag == 1 and regions["harq_region_upper"].startPRB == startPrb and \
                                regions["harq_region_upper"].numOfPrb == numOfPrb:
                            flag = 0

                            if (startSymbol == regions["harq_region_upper"].startSym[0] and
                                    numOfSymbol == regions["harq_region_upper"].numOfSym):
                                pucch_receive_req.regions_found["harq_region_upper_bh"] += 1
                            elif (startSymbol == regions["harq_region_upper"].startSym[1] and
                                  numOfSymbol == regions["harq_region_upper"].numOfSym):
                                pucch_receive_req.regions_found["harq_region_upper_ah"] += 1
                            else:
                                pucch_receive_req.invalid += 1
                                print("Invalid boundary: harq_region_upper_ah startprb{0} numprb:{1} ss:{2} "
                                      "ns:{3}".format(startPrb, numOfPrb, startSymbol, numOfSymbol))

                        if flag == 1 and regions["sr_lower_harq_lower"].startPRB == startPrb and \
                                regions["sr_lower_harq_lower"].numOfPrb == numOfPrb:
                            flag = 0
                            if (startSymbol == regions["sr_lower_harq_lower"].startSym[0] and
                                    numOfSymbol == regions["sr_lower_harq_lower"].numOfSym):
                                pucch_receive_req.regions_found["sr_lower_harq_lower_bh"] += 1
                            elif (startSymbol == regions["sr_lower_harq_lower"].startSym[1] and
                                  numOfSymbol == regions["sr_lower_harq_lower"].numOfSym):
                                pucch_receive_req.regions_found["sr_lower_harq_lower_ah"] += 1
                            else:
                                pucch_receive_req.invalid += 1
                                print("Invalid boundary: sr_lower_harq_lower startprb{0} numprb:{1} ss:{2} "
                                      "ns:{3}".format(startPrb, numOfPrb, startSymbol, numOfSymbol))

                        if flag == 1 and regions["sr_lower_sr_upper"].startPRB == startPrb and \
                                regions["sr_lower_sr_upper"].numOfPrb == numOfPrb:
                            flag = 0
                            if (startSymbol == regions["sr_lower_sr_upper"].startSym[0] and
                                    numOfSymbol == regions["sr_lower_sr_upper"].numOfSym):
                                pucch_receive_req.regions_found["sr_lower_sr_upper_bh"] += 1
                            elif (startSymbol == regions["sr_lower_sr_upper"].startSym[1] and
                                  numOfSymbol == regions["sr_lower_sr_upper"].numOfSym):
                                pucch_receive_req.regions_found["sr_lower_sr_upper_ah"] += 1
                            else:
                                pucch_receive_req.invalid += 1
                                print("Invalid boundary: sr_lower_sr_upper_ah startprb{0} numprb:{1} ss:{2} "
                                      "ns:{3}".format(startPrb, numOfPrb, startSymbol, numOfSymbol))

                        if flag == 1 and regions["sr_lower_harq_upper"].startPRB == startPrb and \
                                regions["sr_lower_harq_upper"].numOfPrb == numOfPrb:
                            flag = 0
                            if (startSymbol == regions["sr_lower_harq_upper"].startSym[0] and
                                    numOfSymbol == regions["sr_lower_harq_upper"].numOfSym):
                                pucch_receive_req.regions_found["sr_lower_harq_upper_bh"] += 1
                            elif (startSymbol == regions["sr_lower_harq_upper"].startSym[1] and
                                  numOfSymbol == regions["sr_lower_harq_upper"].numOfSym):
                                pucch_receive_req.regions_found["sr_lower_harq_upper_ah"] += 1
                            else:
                                pucch_receive_req.invalid += 1
                                print("Invalid boundary: sr_lower_harq_upper startprb{0} numprb:{1} ss:{2} "
                                      "ns:{3}".format(startPrb, numOfPrb, startSymbol, numOfSymbol))

                        if flag == 1 and regions["harq_lower_sr_upper"].startPRB == startPrb and \
                                regions["harq_lower_sr_upper"].numOfPrb == numOfPrb:
                            flag = 0
                            if (startSymbol == regions["harq_lower_sr_upper"].startSym[0] and
                                    numOfSymbol == regions["harq_lower_sr_upper"].numOfSym):
                                pucch_receive_req.regions_found["harq_lower_sr_upper_bh"] += 1
                            elif (startSymbol == regions["sr_lower_harq_upper"].startSym[1] and
                                  numOfSymbol == regions["harq_lower_sr_upper"].numOfSym):
                                pucch_receive_req.regions_found["harq_lower_sr_upper_ah"] += 1
                            else:
                                pucch_receive_req.invalid += 1
                                print("Invalid boundary: pucch_receive_req startprb{0} numprb:{1} ss:{2} "
                                      "ns:{3}".format(startPrb, numOfPrb, startSymbol, numOfSymbol))

                        if flag == 1 and regions["harq_lower_harq_upper"].startPRB == startPrb and \
                                regions["harq_lower_harq_upper"].numOfPrb == numOfPrb:
                            flag = 0
                            if (startSymbol == regions["harq_lower_harq_upper"].startSym[0] and
                                    numOfSymbol == regions["harq_lower_harq_upper"].numOfSym):
                                pucch_receive_req.regions_found["harq_lower_harq_upper_bh"] += 1
                            elif (startSymbol == regions["harq_lower_harq_upper"].startSym[1] and
                                  numOfSymbol == regions["harq_lower_harq_upper"].numOfSym):
                                pucch_receive_req.regions_found["harq_lower_harq_upper_ah"] += 1
                            else:
                                pucch_receive_req.invalid += 1
                                print("Invalid boundary: harq_lower_harq_upper_ah startprb{0} numprb:{1} ss:{2} "
                                      "ns:{3}".format(startPrb, numOfPrb, startSymbol, numOfSymbol))

                        if flag == 1 and regions["sr_upper_harq_upper"].startPRB == startPrb and \
                                regions["sr_upper_harq_upper"].numOfPrb == numOfPrb:
                            flag = 0
                            if (startSymbol == regions["sr_upper_harq_upper"].startSym[0] and
                                    numOfSymbol == regions["sr_upper_harq_upper"].numOfSym):
                                pucch_receive_req.regions_found["sr_upper_harq_upper_bh"] += 1
                            elif (startSymbol == regions["sr_upper_harq_upper"].startSym[1] and
                                  numOfSymbol == regions["sr_upper_harq_upper"].numOfSym):
                                pucch_receive_req.regions_found["sr_upper_harq_upper_ah"] += 1
                            else:
                                pucch_receive_req.invalid += 1
                                print("Invalid boundary: sr_upper_harq_upper startprb{0} numprb:{1} ss:{2} "
                                      "ns:{3}".format(startPrb, numOfPrb, startSymbol, numOfSymbol))

                        if flag == 1 and regions["p_csi_region_lower"].startPRB == startPrb and \
                                regions["p_csi_region_lower"].numOfPrb > numOfPrb:
                            flag = 0
                            if (startSymbol == regions["p_csi_region_lower"].startSym[0] and
                                    numOfSymbol == regions["p_csi_region_lower"].numOfSym):
                                pucch_receive_req.regions_found["dynamic_p_csi_lower_bh"] += 1
                            elif (startSymbol == regions["p_csi_region_lower"].startSym[1] and
                                  numOfSymbol == regions["p_csi_region_lower"].numOfSym):
                                pucch_receive_req.regions_found["dynamic_p_csi_lower_ah"] += 1
                            else:
                                pucch_receive_req.invalid += 1
                                print("Invalid boundary: dynamic_p_csi_lower_ah startprb{0} numprb:{1} ss:{2} "
                                      "ns:{3}".format(startPrb, numOfPrb, startSymbol, numOfSymbol))

                        if flag == 1 and regions["p_csi_region_upper"].startPRB == startPrb and \
                                regions["p_csi_region_upper"].numOfPrb > numOfPrb:
                            flag = 0
                            if (startSymbol == regions["p_csi_region_upper"].startSym[0] and
                                    numOfSymbol == regions["p_csi_region_upper"].numOfSym):
                                pucch_receive_req.regions_found["dynamic_p_csi_upper_bh"] += 1
                            elif (startSymbol == regions["p_csi_region_upper"].startSym[1] and
                                  numOfSymbol == regions["p_csi_region_upper"].numOfSym):
                                pucch_receive_req.regions_found["dynamic_p_csi_upper_ah"] += 1
                            else:
                                pucch_receive_req.invalid += 1
                                print("Invalid boundary: dynamic_p_csi_upper_ah startprb{0} numprb:{1} ss:{2} "
                                      "ns:{3}".format(startPrb, numOfPrb, startSymbol, numOfSymbol))

                        if flag == 1 and regions["p_csi_p_csi_region"].startPRB == startPrb and \
                                regions["p_csi_p_csi_region"].numOfPrb > numOfPrb > \
                                regions["p_csi_region_lower"].numOfPrb:
                            flag = 0
                            if (startSymbol == regions["p_csi_region_lower"].startSym[0] and
                                    numOfSymbol == regions["p_csi_region_lower"].numOfSym):
                                pucch_receive_req.regions_found["dynamic_p_csi_lower_p_csi_upper_bh"] += 1
                            elif (startSymbol == regions["p_csi_region_lower"].startSym[1] and
                                  numOfSymbol == regions["p_csi_region_lower"].numOfSym):
                                pucch_receive_req.regions_found["dynamic_p_csi_lower_p_csi_upper_ah"] += 1
                            else:
                                pucch_receive_req.invalid += 1
                                print("Invalid bounda:dynamic_p_csi_lower_p_csi_upper_ah startprb{0} numprb:{1} ss:{2}"
                                      "ns:{3}".format(startPrb, numOfPrb, startSymbol, numOfSymbol))
                    else:
                        if flag == 1 and regions["p_csi_region_lower"].startPRB == startPrb and \
                                regions["p_csi_region_lower"].numOfPrb == numOfPrb:
                            flag = 0

                            if (startSymbol == regions["p_csi_region_lower"].startSym[0] and
                                    numOfSymbol == regions["p_csi_region_lower"].numOfSym):
                                pucch_receive_req.regions_found["p_csi_region_lower_bh"] += 1
                            elif (startSymbol == regions["p_csi_region_lower"].startSym[1] and
                                  numOfSymbol == regions["p_csi_region_lower"].numOfSym):
                                pucch_receive_req.regions_found["p_csi_region_lower_ah"] += 1
                            else:
                                pucch_receive_req.invalid += 1
                                print("Invalid boundary: p_csi_region_lower startprb{0} numprb:{1} ss:{2} "
                                      "ns:{3}".format(startPrb, numOfPrb, startSymbol, numOfSymbol))

                        if flag == 1 and regions["harq_region_lower"].startPRB == startPrb and \
                                regions["harq_region_lower"].numOfPrb == numOfPrb:
                            flag = 0
                            if (startSymbol == regions["harq_region_lower"].startSym[0] and
                                    numOfSymbol == regions["harq_region_lower"].numOfSym):
                                pucch_receive_req.regions_found["harq_region_lower_bh"] += 1
                            elif (startSymbol == regions["harq_region_lower"].startSym[1] and
                                  numOfSymbol == regions["harq_region_lower"].numOfSym):
                                pucch_receive_req.regions_found["harq_region_lower_ah"] += 1
                            else:
                                pucch_receive_req.invalid += 1
                                print("Invalid boundary: harq_region_lower_ah startprb{0} numprb:{1} ss:{2} "
                                      "ns:{3}".format(startPrb, numOfPrb, startSymbol, numOfSymbol))

                        if flag == 1 and regions["sr_region_lower"].startPRB == startPrb and \
                                regions["sr_region_lower"].numOfPrb == numOfPrb:
                            flag = 0
                            if (startSymbol == regions["sr_region_lower"].startSym[0] and
                                    numOfSymbol == regions["sr_region_lower"].numOfSym):
                                pucch_receive_req.regions_found["sr_region_lower_bh"] += 1
                            elif (startSymbol == regions["sr_region_lower"].startSym[1] and
                                  numOfSymbol == regions["sr_region_lower"].numOfSym):
                                pucch_receive_req.regions_found["sr_region_lower_ah"] += 1
                            else:
                                pucch_receive_req.invalid += 1
                                print("Invalid boundary: sr_region_lower_ah startprb{0} numprb:{1} ss:{2} "
                                      "ns:{3}".format(startPrb, numOfPrb, startSymbol, numOfSymbol))
                        if flag == 1 and regions["harq_region_upper"].startPRB == startPrb and \
                                regions["harq_region_upper"].numOfPrb == numOfPrb:
                            flag = 0
                            if (startSymbol == regions["harq_region_upper"].startSym[0] and
                                    numOfSymbol == regions["harq_region_upper"].numOfSym):
                                pucch_receive_req.regions_found["harq_region_upper_bh"] += 1
                            elif (startSymbol == regions["harq_region_upper"].startSym[1] and
                                  numOfSymbol == regions["harq_region_upper"].numOfSym):
                                pucch_receive_req.regions_found["harq_region_upper_ah"] += 1
                            else:
                                pucch_receive_req.invalid += 1
                                print("Invalid boundary: harq_region_upper_ah startprb{0} numprb:{1} ss:{2} "
                                      "ns:{3}".format(startPrb, numOfPrb, startSymbol, numOfSymbol))

                        if flag == 1 and regions["sr_region_upper"].startPRB == startPrb and \
                                regions["sr_region_upper"].numOfPrb == numOfPrb:
                            flag = 0
                            if (startSymbol == regions["sr_region_upper"].startSym[0] and
                                    numOfSymbol == regions["sr_region_upper"].numOfSym):
                                pucch_receive_req.regions_found["sr_region_upper_ah"] += 1
                            elif (startSymbol == regions["sr_region_upper"].startSym[1] and
                                  numOfSymbol == regions["sr_region_upper"].numOfSym):
                                pucch_receive_req.regions_found["sr_region_upper_bh"] += 1
                            else:
                                pucch_receive_req.invalid += 1
                                print("Invalid boundary: sr_region_upper_bh startprb{0} numprb:{1} ss:{2} "
                                      "ns:{3}".format(startPrb, numOfPrb, startSymbol, numOfSymbol))
                        if flag == 1 and regions["p_csi_region_upper"].startPRB == startPrb and \
                                regions["p_csi_region_upper"].numOfPrb == numOfPrb:
                            flag = 0
                            if (startSymbol == regions["p_csi_region_upper"].startSym[0] and
                                    numOfSymbol == regions["p_csi_region_upper"].numOfSym):
                                pucch_receive_req.regions_found["p_csi_region_upper_bh"] += 1
                            elif (startSymbol == regions["p_csi_region_upper"].startSym[1] and
                                  numOfSymbol == regions["p_csi_region_upper"].numOfSym):
                                pucch_receive_req.regions_found["p_csi_region_upper_ah"] += 1
                            else:
                                pucch_receive_req.invalid += 1
                                print("Invalid boundary: p_csi_region_upper startprb{0} numprb:{1} ss:{2} "
                                      "ns:{3}".format(startPrb, numOfPrb, startSymbol, numOfSymbol))

                        if flag == 1 and regions["p_csi_harq_sr_upper"].startPRB == startPrb and \
                                regions["p_csi_harq_sr_upper"].numOfPrb == numOfPrb:
                            flag = 0
                            if (startSymbol == regions["p_csi_harq_sr_upper"].startSym[0] and
                                    numOfSymbol == regions["p_csi_harq_sr_upper"].numOfSym):
                                pucch_receive_req.regions_found["p_csi_harq_sr_upper_bh"] += 1
                            elif (startSymbol == regions["p_csi_harq_sr_upper"].startSym[1] and
                                  numOfSymbol == regions["p_csi_harq_sr_upper"].numOfSym):
                                pucch_receive_req.regions_found["p_csi_harq_sr_upper_ah"] += 1
                            else:
                                pucch_receive_req.invalid += 1
                                print("Invalid boundary: p_csi_harq_sr_upper_ah startprb{0} numprb:{1} ss:{2} "
                                      "ns:{3}".format(startPrb, numOfPrb, startSymbol, numOfSymbol))
                        if flag == 1 and regions["harq_sr_upper"].startPRB == startPrb and \
                                regions["harq_sr_upper"].numOfPrb == numOfPrb:
                            flag = 0
                            if (startSymbol == regions["harq_sr_upper"].startSym[0] and
                                    numOfSymbol == regions["harq_sr_upper"].numOfSym):
                                pucch_receive_req.regions_found["harq_sr_upper_bh"] += 1
                            elif (startSymbol == regions["harq_sr_upper"].startSym[1] and
                                  numOfSymbol == regions["harq_sr_upper"].numOfSym):
                                pucch_receive_req.regions_found["harq_sr_upper_ah"] += 1
                            else:
                                pucch_receive_req.invalid += 1
                                print("Invalid boundary: harq_sr_upper_ah startprb{0} numprb:{1} ss:{2} "
                                      "ns:{3}".format(startPrb, numOfPrb, startSymbol, numOfSymbol))
                        if flag == 1 and regions["p_csi_harq_upper"].startPRB == startPrb and \
                                regions["p_csi_harq_upper"].numOfPrb == numOfPrb:
                            flag = 0
                            if (startSymbol == regions["p_csi_harq_upper"].startSym[0] and
                                    numOfSymbol == regions["p_csi_harq_upper"].numOfSym):
                                pucch_receive_req.regions_found["p_csi_harq_upper_bh"] += 1
                            elif (startSymbol == regions["p_csi_harq_upper"].startSym[1] and
                                  numOfSymbol == regions["p_csi_harq_upper"].numOfSym):
                                pucch_receive_req.regions_found["p_csi_harq_upper_ah"] += 1
                            else:
                                pucch_receive_req.invalid += 1
                                print("Invalid boundary: p_csi_harq_upper_ah startprb{0} numprb:{1} ss:{2} "
                                      "ns:{3}".format(startPrb, numOfPrb, startSymbol, numOfSymbol))

                        if flag == 1 and regions["sr_harq_lower"].startPRB == startPrb and \
                                regions["sr_harq_lower"].numOfPrb == numOfPrb:
                            flag = 0
                            if (startSymbol == regions["sr_harq_lower"].startSym[0] and
                                    numOfSymbol == regions["sr_harq_lower"].numOfSym):
                                pucch_receive_req.regions_found["sr_harq_lower_bh"] += 1
                            elif (startSymbol == regions["sr_harq_lower"].startSym[1] and
                                  numOfSymbol == regions["sr_harq_lower"].numOfSym):
                                pucch_receive_req.regions_found["sr_harq_lower_ah"] += 1
                            else:
                                pucch_receive_req.invalid += 1
                                print("Invalid boundary: sr_harq_lower_ah startprb{0} numprb:{1} ss:{2} "
                                      "ns:{3}".format(startPrb, numOfPrb, startSymbol, numOfSymbol))

                        if flag == 1 and regions["harq_p_csi_lower"].startPRB == startPrb and \
                                regions["harq_p_csi_lower"].numOfPrb == numOfPrb:
                            flag = 0
                            if (startSymbol == regions["harq_p_csi_lower"].startSym[0] and
                                    numOfSymbol == regions["harq_p_csi_lower"].numOfSym):
                                pucch_receive_req.regions_found["harq_p_csi_lower_bh"] += 1
                            elif (startSymbol == regions["harq_p_csi_lower"].startSym[1] and
                                  numOfSymbol == regions["harq_p_csi_lower"].numOfSym):
                                pucch_receive_req.regions_found["harq_p_csi_lower_ah"] += 1
                            else:
                                pucch_receive_req.invalid += 1
                                print("Invalid boundary: harq_p_csi_lower_ah startprb{0} numprb:{1} ss:{2} "
                                      "ns:{3}".format(startPrb, numOfPrb, startSymbol, numOfSymbol))
                        if regions["sr_harq_p_csi_lower"].startPRB == startPrb and \
                                regions["sr_harq_p_csi_lower"].numOfPrb == numOfPrb:

                            if (startSymbol == regions["sr_harq_p_csi_lower"].startSym[0] and
                                    numOfSymbol == regions["sr_harq_p_csi_lower"].numOfSym):
                                pucch_receive_req.regions_found["sr_harq_p_csi_lower_bh"] += 1
                            elif (startSymbol == regions["sr_harq_p_csi_lower"].startSym[1] and
                                  numOfSymbol == regions["sr_harq_p_csi_lower"].numOfSym):
                                pucch_receive_req.regions_found["sr_harq_p_csi_lower_ah"] += 1
                            else:
                                pucch_receive_req.invalid += 1
                                print("Invalid boundary: sr_harq_p_csi_lower_ah startprb{0} numprb:{1} ss:{2} "
                                      "ns:{3}".format(startPrb, numOfPrb, startSymbol, numOfSymbol))

                        if flag == 1 and regions["sr_harq_p_csi_lower"].startPRB == startPrb and \
                                regions["sr_harq_p_csi_lower"].numOfPrb > numOfPrb > regions["sr_harq_lower"].numOfPrb:
                            flag = 0
                            if (startSymbol == regions["sr_harq_p_csi_lower"].startSym[0] and
                                    numOfSymbol == regions["sr_harq_p_csi_lower"].numOfSym):
                                pucch_receive_req.regions_found["dynamic_sr_harq_p_csi_lower_bh"] += 1
                            elif (startSymbol == regions["sr_harq_p_csi_lower"].startSym[1] and
                                  numOfSymbol == regions["sr_harq_p_csi_lower"].numOfSym):
                                pucch_receive_req.regions_found["dynamic_sr_harq_p_csi_lower_ah"] += 1
                            else:
                                pucch_receive_req.invalid += 1
                                print("Invalid boundary: dynamic_sr_harq_p_csi_lower_ah startprb{0} numprb:{1} ss:{2} "
                                      "ns:{3}".format(startPrb, numOfPrb, startSymbol, numOfSymbol))

                        if flag == 1 and regions["harq_p_csi_lower"].startPRB == startPrb and \
                                regions["harq_p_csi_lower"].numOfPrb > numOfPrb > regions["harq_region_lower"].numOfPrb:
                            flag = 0
                            if (startSymbol == regions["harq_p_csi_lower"].startSym[0] and
                                    numOfSymbol == regions["harq_p_csi_lower"].numOfSym):
                                pucch_receive_req.regions_found["dynamic_harq_p_csi_lower_bh"] += 1
                            elif (startSymbol == regions["harq_p_csi_lower"].startSym[1] and
                                  numOfSymbol == regions["harq_p_csi_lower"].numOfSym):
                                pucch_receive_req.regions_found["dynamic_harq_p_csi_lower_ah"] += 1
                            else:
                                pucch_receive_req.invalid += 1
                                print("Invalid boundary: dynamic_harq_p_csi_lower_ah startprb{0} numprb:{1} ss:{2} "
                                      "ns:{3}".format(startPrb, numOfPrb, startSymbol, numOfSymbol))

                        if flag == 1 and regions["p_csi_region_lower"].startPRB == startPrb and \
                                regions["p_csi_region_lower"].numOfPrb > numOfPrb:
                            flag = 0

                            if (startSymbol == regions["p_csi_region_lower"].startSym[0] and
                                    numOfSymbol == regions["p_csi_region_lower"].numOfSym):
                                pucch_receive_req.regions_found["dynamic_p_csi_region_lower_bh"] += 1
                            elif (startSymbol == regions["p_csi_region_lower"].startSym[1] and
                                  numOfSymbol == regions["p_csi_region_lower"].numOfSym):
                                pucch_receive_req.regions_found["dynamic_p_csi_region_lower_ah"] += 1
                            else:
                                pucch_receive_req.invalid += 1
                                print("Invalid boundary: dynamic_p_csi_region_lower_ah startprb{0} numprb:{1} ss:{2} "
                                      "ns:{3}".format(startPrb, numOfPrb, startSymbol, numOfSymbol))

                        if flag == 1 and regions["p_csi_region_upper"].startPRB < startPrb and \
                                (regions["harq_region_upper"].startPRB) == (startPrb + numOfPrb) and \
                                regions["p_csi_region_lower"].numOfPrb > numOfPrb:
                            flag = 0

                            if (startSymbol == regions["p_csi_region_upper"].startSym[0] and
                                    numOfSymbol == regions["p_csi_region_upper"].numOfSym):
                                pucch_receive_req.regions_found["dynamic_p_csi_region_upper_bh"] += 1
                            elif (startSymbol == regions["p_csi_region_upper"].startSym[1] and
                                  numOfSymbol == regions["p_csi_region_upper"].numOfSym):
                                pucch_receive_req.regions_found["dynamic_p_csi_region_upper_ah"] += 1
                            else:
                                pucch_receive_req.invalid += 1
                                print("Invalid boundary: dynamic_p_csi_region_upper_ah startprb{0} numprb:{1} ss:{2} "
                                      "ns:{3}".format(startPrb, numOfPrb, startSymbol, numOfSymbol))

                        if flag == 1 and regions["p_csi_harq_upper"].startPRB < startPrb and \
                                (regions["sr_region_upper"].startPRB) == (startPrb + numOfPrb) and \
                                regions["p_csi_harq_upper"].numOfPrb > numOfPrb:
                            flag = 0

                            if (startSymbol == regions["p_csi_harq_upper"].startSym[0] and
                                    numOfSymbol == regions["p_csi_harq_upper"].numOfSym):
                                pucch_receive_req.regions_found["dynamic_p_csi_harq_upper_bh"] += 1
                            elif (startSymbol == regions["p_csi_harq_upper"].startSym[1] and
                                  numOfSymbol == regions["p_csi_harq_upper"].numOfSym):
                                pucch_receive_req.regions_found["dynamic_p_csi_harq_upper_ah"] += 1
                            else:
                                pucch_receive_req.invalid += 1
                                print("Invalid boundary: dynamic_p_csi_harq_upper_ah startprb{0} numprb:{1} ss:{2} "
                                      "ns:{3}".format(startPrb, numOfPrb, startSymbol, numOfSymbol))

                        if flag == 1 and regions["p_csi_harq_sr_upper"].startPRB < startPrb and \
                                (regions["p_csi_harq_sr_upper"].startPRB + regions["p_csi_harq_sr_upper"].numOfPrb) == \
                                (startPrb + numOfPrb) and regions["p_csi_harq_sr_upper"].numOfPrb > numOfPrb:
                            flag = 0

                            if (startSymbol == regions["p_csi_harq_sr_upper"].startSym[0] and
                                    numOfSymbol == regions["p_csi_harq_sr_upper"].numOfSym):
                                pucch_receive_req.regions_found["dynamic_p_csi_harq_sr_upper_bh"] += 1
                            elif (startSymbol == regions["p_csi_harq_sr_upper"].startSym[1] and
                                  numOfSymbol == regions["p_csi_harq_sr_upper"].numOfSym):
                                pucch_receive_req.regions_found["dynamic_p_csi_harq_sr_upper_ah"] += 1
                            else:
                                pucch_receive_req.invalid += 1
                                print("Invalid boundary: dynamic_p_csi_harq_sr_upper_ah startprb{0} numprb:{1} ss:{2} "
                                      "ns:{3}".format(startPrb, numOfPrb, startSymbol, numOfSymbol))
                    if flag == 1:
                        print("Invalid boundary: startprb{0} numprb:{1}".format(startPrb, numOfPrb))
                        pucch_receive_req.invalid += 1
            tmp = tmp.next_node

    def update(self, numPucchBoundaries, startPrb, numOfPrb, startSymbol, numOfSymbol):

        self.numPucchBoundaries = int(numPucchBoundaries.split(":")[1].strip())
        if self.numPucchBoundaries != 0 and self.numPucchBoundaries < 9:
            pucch_receive_req.no_of_stored_records += 1
            for indx in range(self.numPucchBoundaries):

                self.numOfPrb.append(int(numOfPrb[indx].split(":")[1].strip()))
                self.startPrb.append(int(startPrb[indx].split(":")[1].strip()))
                s_sym = int(startSymbol[indx].split(":")[1].strip())
                if s_sym != 0 and s_sym != 7:
                    pucch_receive_req.invalid += 1
                    print("symoble is not correct=> ", s_sym)

                self.startSymbol.append(s_sym)
                num_of_sym = int(numOfSymbol[indx].split(":")[1].strip())
                self.numOfSymbol.append(num_of_sym)
                if num_of_sym != 7:
                    pucch_receive_req.invalid += 1
                    print("num of symoble is not correct=> ", numOfSymbol)

        elif self.numPucchBoundaries > 8:
            pucch_receive_req.invalid = pucch_receive_req.invalid + 1
            print("Error add frame number to grab it")

    def disp(self):
        tmp = self
        print("Invalid", pucch_receive_req.invalid)
        print("Stored records", pucch_receive_req.no_of_stored_records)
        print("numPucchBoundaries:{0} startPrb:{1} numOfPrb:{2}  startSymbol:{3} numOfSymbol:{4}".format(
            tmp.numPucchBoundaries, tmp.startPrb, tmp.numOfPrb, tmp.startSymbol, tmp.numOfSymbol))
        while tmp.next_node is not None:
            tmp = tmp.next_node
            print("numPucchBoundaries:{0} startPrb:{1} numOfPrb:{2}  startSymbol:{3} numOfSymbol:{4}".format(
                tmp.numPucchBoundaries, tmp.startPrb, tmp.numOfPrb, tmp.startSymbol, tmp.numOfSymbol))
        print("regions mtach as below")
        for key in pucch_receive_req.regions_found:
            if pucch_receive_req.regions_found[key] != 0:
                print("Region {0}==>match count{1}".format(key, pucch_receive_req.regions_found[key]))


class pucch_regions:
    matched_regions = 0

    def __init__(self, startprb, numofprb):
        self.startPRB = startprb
        self.numOfPrb = numofprb
        self.startSym = [0, 7]
        self.numOfSym = 7


def form_pucch_pkt_struct_verify(path_count, numPucchBoundaries, startPrb, numOfPrb, startSymbol, numOfSymbol,
                                 longPucchStartSr1Prb, longPucchStartSr2Prb, longPucchStartHarq1Prb,
                                 longPucchStartHarq2Prb,
                                 longPucchStartPcsi1Prb, longPucchStartPcsi2Prb, longPucchNumSrPrb, longPucchNumHarqPrb,
                                 longPucchNumPcsiPrb, CommonPucchHighPartstartprb, CommonPucchLowPartstartprb,
                                 NumPrbCommonPucch, multided_ps_dyn=0, scen=0):
    longPucchStartSr1Prb = int(longPucchStartSr1Prb)
    longPucchStartSr2Prb = int(longPucchStartSr2Prb)
    longPucchStartHarq1Prb = int(longPucchStartHarq1Prb)
    longPucchStartHarq2Prb = int(longPucchStartHarq2Prb)
    longPucchStartPcsi1Prb = int(longPucchStartPcsi1Prb)
    longPucchStartPcsi2Prb = int(longPucchStartPcsi2Prb)
    longPucchNumSrPrb = int(longPucchNumSrPrb)
    longPucchNumHarqPrb = int(longPucchNumHarqPrb)
    longPucchNumPcsiPrb = int(longPucchNumPcsiPrb)
    CommonPucchHighPartstartprb = int(CommonPucchHighPartstartprb)
    CommonPucchLowPartstartprb = int(CommonPucchLowPartstartprb)
    NumPrbCommonPucch = int(NumPrbCommonPucch)
    possible_pucch_regions = {}

    possible_pucch_regions["commonpucch_upper"] = pucch_regions(CommonPucchHighPartstartprb, NumPrbCommonPucch)
    possible_pucch_regions["commonpucch_lower"] = pucch_regions(CommonPucchLowPartstartprb, NumPrbCommonPucch)

    if multided_ps_dyn == 1:

        possible_pucch_regions["p_csi_region_lower"] = pucch_regions(longPucchStartPcsi1Prb, longPucchNumPcsiPrb)
        possible_pucch_regions["p_csi_region_upper"] = pucch_regions(longPucchStartPcsi2Prb, longPucchNumPcsiPrb)
        n_prb = longPucchNumPcsiPrb * 2
        possible_pucch_regions["p_csi_p_csi_region"] = pucch_regions(longPucchStartPcsi1Prb, n_prb)
        possible_pucch_regions["sr_region_lower"] = pucch_regions(longPucchStartSr1Prb, longPucchNumSrPrb)
        possible_pucch_regions["harq_region_lower"] = pucch_regions(longPucchStartHarq1Prb, longPucchNumHarqPrb)
        possible_pucch_regions["sr_region_upper"] = pucch_regions(longPucchStartSr2Prb, longPucchNumSrPrb)
        possible_pucch_regions["harq_region_upper"] = pucch_regions(longPucchStartHarq2Prb, longPucchNumHarqPrb)
        n_prb = longPucchNumSrPrb + longPucchNumHarqPrb
        possible_pucch_regions["sr_lower_harq_lower"] = pucch_regions(longPucchStartSr1Prb, n_prb)
        n_prb = (2 * longPucchNumSrPrb) + longPucchNumHarqPrb
        possible_pucch_regions["sr_lower_sr_upper"] = pucch_regions(longPucchStartSr1Prb, n_prb)
        n_prb = (2 * longPucchNumSrPrb) + (2 * longPucchNumHarqPrb)
        possible_pucch_regions["sr_lower_harq_upper"] = pucch_regions(longPucchStartSr1Prb, n_prb)
        n_prb = longPucchNumSrPrb + longPucchNumHarqPrb
        possible_pucch_regions["harq_lower_sr_upper"] = pucch_regions(longPucchStartHarq1Prb, n_prb)
        n_prb = longPucchNumSrPrb + (2 * longPucchNumHarqPrb)
        possible_pucch_regions["harq_lower_harq_upper"] = pucch_regions(longPucchStartHarq1Prb, n_prb)
        n_prb = longPucchNumSrPrb + longPucchNumHarqPrb
        possible_pucch_regions["sr_upper_harq_upper"] = pucch_regions(longPucchStartSr2Prb, n_prb)

    else:
        p_csi_region_lower = pucch_regions(longPucchStartPcsi1Prb, longPucchNumPcsiPrb)
        possible_pucch_regions["p_csi_region_lower"] = p_csi_region_lower
        harq_region_lower = pucch_regions(longPucchStartHarq1Prb, longPucchNumHarqPrb)
        possible_pucch_regions["harq_region_lower"] = harq_region_lower
        sr_region_lower = pucch_regions(longPucchStartSr1Prb, longPucchNumSrPrb)
        possible_pucch_regions["sr_region_lower"] = sr_region_lower

        harq_region_upper = pucch_regions(longPucchStartHarq2Prb, longPucchNumHarqPrb)
        possible_pucch_regions["harq_region_upper"] = harq_region_upper
        sr_region_upper = pucch_regions(longPucchStartSr2Prb, longPucchNumSrPrb)
        possible_pucch_regions["sr_region_upper"] = sr_region_upper
        p_csi_region_upper = pucch_regions(longPucchStartPcsi2Prb, longPucchNumPcsiPrb)
        possible_pucch_regions["p_csi_region_upper"] = p_csi_region_upper

        reg_startPrb = p_csi_region_upper.startPRB
        up_low_reg_num_of_prb = (
                harq_region_upper.numOfPrb + sr_region_upper.numOfPrb + p_csi_region_upper.numOfPrb)
        p_csi_harq_sr_upper = pucch_regions(reg_startPrb, up_low_reg_num_of_prb)
        possible_pucch_regions["p_csi_harq_sr_upper"] = p_csi_harq_sr_upper

        reg_startPrb = harq_region_upper.startPRB
        up_low_reg_num_of_prb = (harq_region_upper.numOfPrb + sr_region_upper.numOfPrb)
        harq_sr_upper = pucch_regions(reg_startPrb, up_low_reg_num_of_prb)
        possible_pucch_regions["harq_sr_upper"] = harq_sr_upper

        reg_startPrb = p_csi_region_upper.startPRB
        up_low_reg_num_of_prb = (p_csi_region_upper.numOfPrb + harq_region_upper.numOfPrb)
        p_csi_harq_upper = pucch_regions(reg_startPrb, up_low_reg_num_of_prb)
        possible_pucch_regions["p_csi_harq_upper"] = p_csi_harq_upper

        reg_startPrb = sr_region_lower.startPRB
        up_low_reg_num_of_prb = (sr_region_lower.numOfPrb + harq_region_lower.numOfPrb)
        sr_harq_lower = pucch_regions(reg_startPrb, up_low_reg_num_of_prb)
        possible_pucch_regions["sr_harq_lower"] = sr_harq_lower

        reg_startPrb = harq_region_lower.startPRB
        up_low_reg_num_of_prb = (harq_region_lower.numOfPrb + p_csi_region_lower.numOfPrb)
        harq_p_csi_lower = pucch_regions(reg_startPrb, up_low_reg_num_of_prb)
        possible_pucch_regions["harq_p_csi_lower"] = harq_p_csi_lower

        up_low_reg_num_of_prb = (
                harq_region_lower.numOfPrb + harq_region_lower.numOfPrb + p_csi_region_lower.numOfPrb)
        reg_startPrb = sr_region_lower.startPRB
        sr_harq_p_csi_lower = pucch_regions(reg_startPrb, up_low_reg_num_of_prb)
        possible_pucch_regions["sr_harq_p_csi_lower"] = sr_harq_p_csi_lower
    # max possible pucch boundary
    max_number_pucch_boundary = 8  # This needs to be updated to 8 frag or number of pucchboundary
    head = pucch_receive_req()
    head.update(numPucchBoundaries[0], startPrb[0:max_number_pucch_boundary], numOfPrb[0:max_number_pucch_boundary],
                startSymbol[0:max_number_pucch_boundary], numOfSymbol[0:max_number_pucch_boundary])
    pucch_receive_req.count = 1

    print("numb of pucch boundery", len(startPrb))
    # Each pucchreceivereq contains one  numPucchBoundaries element so 10 pucch has sub boundary 10 boundary*8 at max
    for idx in range(1, len(numPucchBoundaries)):
        tmp = pucch_receive_req()
        start_stuct = idx * max_number_pucch_boundary
        end_struct = start_stuct + max_number_pucch_boundary
        # print(" ====>", pucch_receive_req.count)
        pucch_receive_req.count = pucch_receive_req.count + 1
        tmp.update(numPucchBoundaries[idx], startPrb[start_stuct:end_struct], numOfPrb[start_stuct:end_struct],
                   startSymbol[start_stuct:end_struct], numOfSymbol[start_stuct:end_struct])
        tmp.next_node = head
        head = tmp

    # print(head.count, "<==>", path_count)
    print("=============================")

    head.verify_regions(possible_pucch_regions, multided_ps_dyn)
    # head.disp()
    print("Below is all possible regions")
    for key in possible_pucch_regions:
        reg = possible_pucch_regions[key]
        print("region {0} startprb{1} numprb{2} startsym{3} numsym{4}".format(key, reg.startPRB, reg.numOfPrb,
                                                                              reg.startSym, reg.numOfSym))
    if scen == 0:
        if pucch_receive_req.invalid == 0 and pucch_receive_req.no_of_stored_records != 0:
            return "pass"
        else:
            return "fail"
    elif scen == 1:
        if pucch_receive_req.no_of_stored_records == 0:
            return "pass"
        else:
            return "fail"
