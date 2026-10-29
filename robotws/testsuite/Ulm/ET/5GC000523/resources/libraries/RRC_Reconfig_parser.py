from taf.analyzer.pdml import PdmlReader
import re

dict_slotPeriodicity = {0: 4, 1: 5, 2: 8, 3: 10, 4: 16, 5: 20, 6: 40, 7: 80, 8: 160, 9: 320}
RRC_Extract = {}


def Extract(filename):
    with open(filename, "rb") as file_obj:
        print("Extracting data from RRC Reconfiguration")
        for entry in PdmlReader(file_obj=file_obj):
            root = entry.packet
            if "nr-rrc.newUE_Identity" in root:
                rnti = ((int(root.xpath("x2ap//x2ap.X2AP_PDU//nr-rrc.spCellConfig_element//"
                                        "nr-rrc.reconfigurationWithSync_element//nr-rrc.newUE_Identity")[0].show)))

                slot_periodicity_index = (root.xpath("x2ap//x2ap.X2AP_PDU/x2ap.successfulOutcome_element//"
                                                     "nr-rrc.periodic_element//nr-rrc.reportSlotConfig")[0].show)

                csiReportSlotOffset = int(root.xpath(
                    "x2ap//x2ap.X2AP_PDU//x2ap.successfulOutcome_element//x2ap.value_element//"
                    "nr-rrc.reportSlotConfig//*")[0].show)

                csiReportPeriodicity = dict_slotPeriodicity[int(slot_periodicity_index)]

                path_im = "x2ap//x2ap.X2AP_PDU//x2ap.successfulOutcome_element//x2ap.value_element//" \
                          "nr-rrc.CSI_IM_Resource_element//nr-rrc.periodicityAndOffset"
                CsiRsSlotOffset = int(root.xpath(path_im + '/*')[0].show)

                csi_im_periodicity_extract_tmp = root.xpath(path_im)[0].showname
                match = re.search('slots(.+?) ', csi_im_periodicity_extract_tmp)
                CsiRsPeridocity = int(match.group(1))

            if "nr-rrc.rf_Parameters_element" in root:
                band = root.xpath("x2ap//..//nr-rrc.supportedBandListNR//..//nr-rrc.bandNR")[0].show
                if int(band) >= 200:
                    tl_config = "Above6GHz"
                elif int(band) < 200:
                    tl_config = "Below6GHz"
                else:
                    print("Invalid Band")
            try:
                RRC_Extract[rnti] = {"CSI_Report_Periodicity": csiReportPeriodicity,
                                     "CSI_RS_Periodicity": CsiRsPeridocity,
                                     "TL_Config": tl_config, "CSI_RS_SlotOffset": CsiRsSlotOffset,
                                     "CSI_Report_SlotOffset": csiReportSlotOffset}
            except UnboundLocalError:
                pass

    return RRC_Extract
