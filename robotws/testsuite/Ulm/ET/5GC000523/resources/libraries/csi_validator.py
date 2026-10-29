import numpi as numpy
import csv
import csi_report_decode
import os
import logging

logging.basicConfig(filename='csi_report_validator.log', level=logging.DEBUG)


class reportValidator:
    def __init__(self, NoOfSlotsPerFrame):
        self.sfn = []
        self.slots = []
        self.periodicity = []
        self.expected_periodicity = "Not Defined"
        self.NoOfSlotsPerFrame = NoOfSlotsPerFrame

    def periodictyValidation(self, sfn, slots, expected_periodicity, offset):
        verdict = 0
        for itr in range((len(sfn)-1)):
            if int(sfn[itr+1], 16) - int(sfn[itr], 16) < 0:
                self.periodicity.append((((int(sfn[itr+1], 16)+1)+1023)*self.NoOfSlotsPerFrame) -
                                        (int(sfn[itr], 16)*self.NoOfSlotsPerFrame))
            else:
                self.periodicity.append((int(sfn[itr+1], 16)*self.NoOfSlotsPerFrame) -
                                        (int(sfn[itr], 16)*self.NoOfSlotsPerFrame))
                periodicty_detected = numpy.unique(self.periodicity)
                if len(periodicty_detected) > 1:
                    logging.info("%s %s", sfn[itr], sfn[itr+1])
                    logging.error("ERR : Invalid Periodicity Detected")
                    verdict = 1
                    logging.info("Found Periodicities %s", periodicty_detected)
        if len(numpy.unique(self.periodicity)) == 1 and numpy.unique(self.periodicity)[0] == expected_periodicity:
            logging.info("INF: Expected Periodicity matches detected periodicity %s slots", expected_periodicity)
        elif len(numpy.unique(self.periodicity)) > 1:
            logging.error("ERR: Multiple Values of Periodicity found %s", self.periodicity)
            verdict = 1
        elif numpy.unique(self.periodicity)[0] != expected_periodicity and len(numpy.unique(self.periodicity)) == 1:
            logging.error("ERR: Detected Periodicity %s slots does not match expected periodicity of %s slots",
                          numpy.unique(self.periodicity)[0], expected_periodicity)
            verdict = 1
        # Validating Slots ######
        if len(numpy.unique(slots)) > 1:
            logging.error("ERR: Slot Validation Failed! Expected one unique slot per report, found multiple %s",
                          numpy.unique(slots))
            verdict = 1
        else:
            detected_slot = int(numpy.unique(slots)[0], 16)
            logging.info("Report detected at slot %s", detected_slot)
        # Compute expected slot from slot offset from RRC Reconfig
        if ((offset + 1) / self.NoOfSlotsPerFrame) == 0:
            expected_slot = offset
            logging.info("Expected slot : %s", expected_slot)
        else:
            expected_slot = (offset - ((offset/self.NoOfSlotsPerFrame)*self.NoOfSlotsPerFrame))
            logging.info("Expected slot : ", expected_slot)
        if expected_slot == detected_slot:
            logging.info("Expected slot matches detected slot")
        else:
            logging.error("Slot Validation Failed ! Expected slot :", expected_slot, "| detected slot:", detected_slot)
            verdict = 1
        return verdict

    def reportValidation(self, pucchReceiveReq_sfn, pucchReceiveReq_slots, pucchReceiveResp_sfn,
                         pucchReceiveResp_slots, pucchReceiveResp_dtx, pucchReceiveResp_crc, report_detected,
                         report_expected, PERM_DTX_PERCENTAGE):
        verdict = 0
        SR = []
        RI = []
        PMI = []
        CQI = []
        detectedReportHex = []
        report_detected_subset = []
        ind = []
        report_sfn = []
        report_slot = []
        report_dtx = []
        report_crc = []
        dtx_counter = 0
        crc_counter = 0
        for itr in range(len(pucchReceiveReq_sfn)):
            # Remove the second for loop during refactoring for faster execution
            for ctr in range(len(pucchReceiveResp_sfn)):
                if pucchReceiveReq_sfn[itr] == pucchReceiveResp_sfn[ctr] and pucchReceiveResp_slots[ctr] == \
                        pucchReceiveReq_slots[itr]:
                    ind.append(ctr)
                    report_sfn.append(pucchReceiveResp_sfn[ctr])
                    report_slot.append(pucchReceiveResp_slots[ctr])
                    report_detected_subset.append(report_detected[ctr])
                    break
        for list_ind in ind:
            if pucchReceiveResp_dtx[list_ind] == 1:
                logging.info("DTX Found ! in SFN : %s and SLOT : %s", pucchReceiveResp_sfn[list_ind],
                             pucchReceiveResp_slots[list_ind])
                report_dtx.append(1)
                dtx_counter += 1
            elif pucchReceiveResp_crc[list_ind] == 1:
                logging.info("CRC Found ! in SFN : %s and SLOT : %s", pucchReceiveResp_sfn[list_ind],
                             pucchReceiveResp_slots[list_ind])
                report_crc.append(1)
                crc_counter += 1
            else:
                report_dtx.append(0)
                report_crc.append(0)
        logging.info("DTX COUNT : %s", dtx_counter)
        logging.info("CRC COUNT : %s", crc_counter)
        report_dtx_percentage = (float(dtx_counter) / float(len(ind))) * 100
        report_crc_percentage = (float(crc_counter) / float(len(ind))) * 100
        logging.info("%s percent of CSI Reports have DTX", report_dtx_percentage)
        logging.info("%s percent of CSI Reports have CRC", report_crc_percentage)
        if int(report_dtx_percentage) > PERM_DTX_PERCENTAGE or int(report_crc_percentage) > PERM_DTX_PERCENTAGE:
            logging.error("Permissible threshold for number of invalid reports exceeded")
            verdict = 1
        for item in report_detected_subset:
            SR.append(csi_report_decode.decode_uci(item)[0])
            RI.append(csi_report_decode.decode_uci(item)[1])
            PMI.append(csi_report_decode.decode_uci(item)[2])
            CQI.append(csi_report_decode.decode_uci(item)[3])
            detectedReportHex.append(csi_report_decode.decode_uci(item)[4])
        logging.info("No. of reports expected: %s | No. of reports detected: %s ",
                     len(pucchReceiveReq_sfn), len(report_detected_subset))
        if numpy.unique(detectedReportHex)[0] == report_expected and len(
                numpy.unique(detectedReportHex)) == 1:
            logging.info("CSI Report detected matches expected value | Expected Report : %s Detected Report %s",
                         report_expected, numpy.unique(detectedReportHex))
        else:
            logging.error("CSI Report Mismatch ! Expected Report : %s | Detected Report %s", report_expected,
                          numpy.unique(detectedReportHex))
            verdict = 1

        return report_sfn, report_slot, SR, RI, PMI, CQI, report_dtx, verdict

    def writeDataToFile(self, report_detected, rnti, rootdir):
        fieldnames = ["SFN", "Slot", "SR", "RI", "PMI", "CQI", "DTX"]
        rows = zip(report_detected[0], report_detected[1], report_detected[2], report_detected[3],
                   report_detected[4], report_detected[5], report_detected[6])

        dirname = rootdir+'ExtractedReport/'
        if not os.path.exists(dirname):
            os.makedirs(dirname)

        filename = "CSI_RS_Report_" + rnti + ".csv"
        with open(rootdir+'ExtractedReport/'+filename, mode='wb') as csi_rs_reports:
            writer = csv.writer(csi_rs_reports)
            writer.writerow(fieldnames)
            for row in rows:
                writer.writerow(row)


class RefSignalValidator:

    def __init__(self, NoOfSlotsPerFrame):
        self.sfn = []
        self.slots = []
        self.periodicity = []
        self.expected_periodicity = "Not Defined"
        self.NoOfSlotsPerFrame = NoOfSlotsPerFrame

    def periodictyValidation(self, sfn, slots, expected_periodicity, offset, EXPECTED_RNTI_FROM_RRC):
        verdict = 0
        ue_cnt = 0
        detected_csirs_on_slots = []
        expected_slot = []

        for slot in numpy.unique(slots):
            detected_csirs_on_slots.append(int(slot, 16))

        for elem_offset in offset:
            if ((int(elem_offset) + 1) / self.NoOfSlotsPerFrame) == 0:
                expected_slot.append(int(elem_offset))
            else:
                expected_slot.append(int(elem_offset) -
                                     ((int(elem_offset)/self.NoOfSlotsPerFrame)*self.NoOfSlotsPerFrame))

        if len(set(list(numpy.unique(expected_slot))).difference(detected_csirs_on_slots)) == 0:
            logging.info("INF: Slot offsets found in Trace match expected slot offsets in RRC Reconfiguration : %s",
                         detected_csirs_on_slots)
        else:
            missing_slot = set(list(numpy.unique(expected_slot))).difference(detected_csirs_on_slots)
            unknown_csisendreq = set(detected_csirs_on_slots).difference(list(numpy.unique(expected_slot)))
            logging.error("CSI Send Requests not found in SLOT %s", missing_slot)
            logging.error("CSI Send Request not expected for slot %s", unknown_csisendreq)
            verdict = 1

        if verdict == 1:
            return verdict

        """Sort SFNs for each UE"""

        for slot_exp in list(numpy.unique(expected_slot)):
            sfn_validate = []
            for iterator in range(len(slots)):
                if int(slot_exp) == int(slots[iterator], 16):
                    sfn_validate.append(sfn[iterator])

            for itr in range((len(sfn_validate) - 1)):
                if int(sfn_validate[itr + 1], 16) - int(sfn_validate[itr], 16) < 0:
                    self.periodicity.append((((int(sfn_validate[itr + 1], 16) + 1) + 1023) * self.NoOfSlotsPerFrame) -
                                            (int(sfn_validate[itr], 16) * self.NoOfSlotsPerFrame))
                else:
                    self.periodicity.append((int(sfn_validate[itr + 1], 16) * self.NoOfSlotsPerFrame) -
                                            (int(sfn_validate[itr], 16) * self.NoOfSlotsPerFrame))
                    periodicty_detected = numpy.unique(self.periodicity)
                    if len(periodicty_detected) > 1:
                        logging.info("%s %s", sfn_validate[itr], sfn_validate[itr + 1])
                        logging.error("ERR : Invalid Periodicity Detected for UE with RNTI: %s",
                                      EXPECTED_RNTI_FROM_RRC[ue_cnt])
                        verdict = 1
                        logging.info("Found Periodicities %s ", periodicty_detected)

            if len(numpy.unique(self.periodicity)) == 1 and int((numpy.unique(self.periodicity)[0])) == \
                    int(expected_periodicity[0]):
                logging.info("Expected CSI Reference Signal Periodicity matches detected periodicity %s slots "
                             "for RNTI : %s ", periodicty_detected, EXPECTED_RNTI_FROM_RRC[ue_cnt])
            elif len(numpy.unique(self.periodicity)) > 1:
                logging.error("Multiple Values of Periodicity found %s ", self.periodicity)
                verdict = 1

            ue_cnt += 1
        return verdict
