# v0.2 Add lcid in stats
# v0.3 Add stats for PRB adn symbols (SLIV)
# v0.5 dlHarqRxDataArray: filter out lines which contain "ERROR" value
# v0.7 Nouveau calcul pour vslot
# v0.8 Add gestion inStats= 0, notInStats > 50

import re
import os
import datetime
import sqlite3


class dlMessage:

    def __init__(self, dlData, line):

        self.dlDataRef = dlData
        self.vslot = []  # liste des vslots calculés
        self.data = {}  # data par vslot

    def addDlFdSchedData(self, line):
        if self.dlDataRef.debug:
            self.dlDataRef.traceFilePerRnti_fd.write(str(line) + "\n")

        vslot = self.computeVslot2(line[self.dlDataRef.hfn], line[self.dlDataRef.sfn], line[self.dlDataRef.slot])
        # print("hfn: " +
        # line[self.dlDataRef.hfn] + ", sfn: " +
        # line[self.dlDataRef.sfn] + ", slot: " +
        # line[self.dlDataRef.slot] + ", vslot: " +
        # str(vslot))
        # print("data: " + str(self.data[vslot]))
        if self.data[vslot][3] != "":
            print("DL Sched Data already present")
            if self.dlDataRef.debug:
                self.dlDataRef.traceFilePerRnti_fd.write("\tDL Sched Data already present\n")
            if self.dlDataRef.debug:
                self.traceFilePerRnti_fd.close()
            # exit(-1)
            return

        self.data[vslot][self.dlDataRef.dataMcs] = line[self.dlDataRef.mcs]
        self.data[vslot][self.dlDataRef.dataTbSize] = line[self.dlDataRef.tbsize]
        self.data[vslot][self.dlDataRef.dataTxNumber] = line[self.dlDataRef.txNumber]
        self.data[vslot][self.dlDataRef.dataHarqId_fd] = line[self.dlDataRef.HarqId_fd]
        self.data[vslot][self.dlDataRef.dataPrb] = line[self.dlDataRef.numOfPrb]
        self.data[vslot][self.dlDataRef.dataSymbols] = self.dlDataRef.slivValue[int(line[self.dlDataRef.SLIV])][2]

        # expected vslot ack
        expected_ack_slot = (int(line[self.dlDataRef.slot]) + int(line[self.dlDataRef.K1])) % 20
        expected_ack_sfn = (int(line[self.dlDataRef.sfn]) + ((int(line[self.dlDataRef.slot]) +
                                                              int(line[self.dlDataRef.K1])) // 20)) % 1024
        expected_ack_hfn = (int(line[self.dlDataRef.hfn]) + ((int(line[self.dlDataRef.sfn]) +
                                                              ((int(line[self.dlDataRef.slot]) +
                                                                int(line[self.dlDataRef.K1])) // 20)) // 1024))  # %1024

        expected_ack_vslot = int(expected_ack_hfn) * 1024 * 20 + int(expected_ack_sfn) * 20 + int(expected_ack_slot)
        if self.dlDataRef.debug:
            self.dlDataRef.traceFilePerRnti_fd.write("\tExpected ACK - K1: " + line[self.dlDataRef.K1] + ", hfn: " +
                                                     str(expected_ack_hfn) + ", sfn: " + str(expected_ack_sfn) +
                                                     ", slot:" + str(expected_ack_slot) +
                                                     ", vslot:" + str(expected_ack_vslot) + "\n")
        self.data[vslot][self.dlDataRef.dataExpectedAckVslot] = expected_ack_vslot
        if self.dlDataRef.debug:
            self.dlDataRef.traceFilePerRnti_fd.write("\tDL Sched data - Vslot: " +
                                                     str(vslot) + ": " + str(self.data[vslot]) + "\n")

    def addDlHarqRxDataArray(self, line):
        if self.dlDataRef.debug:
            self.dlDataRef.traceFilePerRnti_fd.write(str(line) + "\n")

        # vslot = self.computeVslot(line[self.dlDataRef.sfn], line[self.dlDataRef.slot], "dlHarqRxDataArray")
        vslot = self.computeVslot2(line[self.dlDataRef.hfn], line[self.dlDataRef.sfn], line[self.dlDataRef.slot])
        self.data[vslot][self.dlDataRef.dataDtx] = line[self.dlDataRef.dtx]
        self.data[vslot][self.dlDataRef.dataAckNack] = line[self.dlDataRef.ackNack]
        if self.data[vslot][self.dlDataRef.dataHarqId_hq] == "":
            self.data[vslot][self.dlDataRef.dataHarqId_hq] = [line[self.dlDataRef.HarqId_hq]]
        else:
            try:
                self.data[vslot][self.dlDataRef.dataHarqId_hq].index(line[self.dlDataRef.HarqId_hq])
            except Exception as e:
                self.data[vslot][self.dlDataRef.dataHarqId_hq].append(line[self.dlDataRef.HarqId_hq])
            else:
                print("dlHarqRxDataArray Data already present")
                if self.dlDataRef.debug:
                    self.dlDataRef.traceFilePerRnti_fd.write("\tdlHarqRxDataArray Data already present\n")
                if self.dlDataRef.debug:
                    self.traceFilePerRnti_fd.close()
                # exit(-1)
                return

        if self.dlDataRef.debug:
            self.dlDataRef.traceFilePerRnti_fd.write("\tHARQ data - Vslot: " + str(vslot) + ": " +
                                                     str(self.data[vslot]) + "\n")

    def computeVslot2(self, hfn, sfn, slot):

        vslot = int(hfn) * 1024 * 20 + int(sfn) * 20 + int(slot)
        if self.dlDataRef.debug:
            self.dlDataRef.traceFilePerRnti_fd.write("\tComputed vslot: " + str(vslot) + "\n")

        try:
            self.vslot.index(vslot)
        except Exception as e:
            self.vslot.append(vslot)
            self.vslot.sort()
            self.data[vslot] = [hfn, sfn, slot, "", "", "", "", "", "", "", "", ""]

        return vslot


class createFileFilteredDL:

    def __init__(self, file_filtered):

        self.file_filtered_fd = open(file_filtered, 'w')

        # en tete et numero de colonne a extraire
        self.dlFdSchedData_hfn_field = "hfnTickCount"
        self.dlFdSchedData_hfn = None
        self.dlFdSchedData_sfn_field = "sfn"
        self.dlFdSchedData_sfn = None
        self.dlFdSchedData_slot_field = "slot"
        self.dlFdSchedData_slot = None
        self.dlFdSchedData_rnti_field = "rnti"
        self.dlFdSchedData_rnti = None
        self.dlFdSchedData_pci_field = "physCellId"
        self.dlFdSchedData_pci = None
        self.dlFdSchedData_mcs_field = "rrmDlUsedMcs"
        self.dlFdSchedData_mcs = None
        self.dlFdSchedData_tbSize_field = "tbSize"
        self.dlFdSchedData_tbSize = None
        self.dlFdSchedData_txNumber_field = "txNumber"
        self.dlFdSchedData_txNumber = None
        self.dlFdSchedData_harqId_field = "dlHarqProcessIndex"
        self.dlFdSchedData_harqId = None
        self.dlFdSchedData_K1_field = "K1"
        self.dlFdSchedData_K1 = None
        self.dlFdSchedData_layers_field = "numOfLayers"
        self.dlFdSchedData_layers = None
        self.dlFdSchedData_numOfPrb_field = "numOfPrb"
        self.dlFdSchedData_numOfPrb = None
        self.dlFdSchedData_SLIV_field = "SLIV"
        self.dlFdSchedData_SLIV = None

        self.dlHarqRx_hfn_field = "hfnTickCount"
        self.dlHarqRx_hfn = None
        self.dlHarqRx_sfn_field = "sfn"
        self.dlHarqRx_sfn = None
        self.dlHarqRx_slot_field = "slot"
        self.dlHarqRx_slot = None
        self.dlHarqRx_rnti_field = "rnti"
        self.dlHarqRx_rnti = None
        self.dlHarqRx_dtx_field = "dtx"
        self.dlHarqRx_dtx = None
        self.dlHarqRx_ackNack_field = "ackNack"
        self.dlHarqRx_ackNack = None
        self.dlHarqRx_harqId_field = "dlHarqProcessIndex"
        self.dlHarqRx_harqId = None
        self.nbHarqBlocks = 32   # A adapter
        self.nbOfFields = None

        self.first_dlFdSchedData = True   # Au premier msg, on recherche les index des champs
        self.first_dlHarqRxData = True  # Au premier msg, on recherche les index des champs

        # Format colonne du fichier filtre (Entete + Index)
        # ##### ATTENTION #####
        # reporter toutes  modifs des index dans la classe dlDataPerRnti
        # modifier rntiIndex dans la fonction principale
        enTete = "msg;hfn;sfn;slot;rnti;MCS;tbSize;txNumber;harqId Sched;K1;Layers;DTX;ackNack;HarqId\n"
        self.file_filtered_fd.write(enTete)
        self.dataSize = 16  # longueur totale de data
        self.msgName = 0
        self.hfn = 1
        self.sfn = 2
        self.slot = 3
        self.rnti = 4
        self.mcs = 5
        self.tbsize = 6
        self.txNumber = 7
        self.HarqId_fd = 8
        self.K1 = 9
        self.layers = 10
        self.numOfPrb = 11
        self.SLIV = 12
        self.dtx = 13
        self.ackNack = 14
        self.HarqId_hq = 15

    def closeFileFilter(self):
        self.file_filtered_fd.close()

    def findPos_dlFdSchedData(self, fields):
        offset_value = int(len(fields) / 2)
        self.dlFdSchedData_hfn = fields.index(self.dlFdSchedData_hfn_field) + offset_value
        self.dlFdSchedData_sfn = fields.index(self.dlFdSchedData_sfn_field) + offset_value
        self.dlFdSchedData_slot = fields.index(self.dlFdSchedData_slot_field) + offset_value
        self.dlFdSchedData_rnti = fields.index(self.dlFdSchedData_rnti_field) + offset_value
        self.dlFdSchedData_pci = fields.index(self.dlFdSchedData_pci_field) + offset_value
        self.dlFdSchedData_mcs = fields.index(self.dlFdSchedData_mcs_field) + offset_value
        self.dlFdSchedData_tbSize = fields.index(self.dlFdSchedData_tbSize_field) + offset_value
        self.dlFdSchedData_txNumber = fields.index(self.dlFdSchedData_txNumber_field) + offset_value
        self.dlFdSchedData_harqId = fields.index(self.dlFdSchedData_harqId_field) + offset_value
        self.dlFdSchedData_K1 = fields.index(self.dlFdSchedData_K1_field) + offset_value
        self.dlFdSchedData_layers = fields.index(self.dlFdSchedData_layers_field) + offset_value
        self.dlFdSchedData_numOfPrb = fields.index(self.dlFdSchedData_numOfPrb_field) + offset_value
        self.dlFdSchedData_SLIV = fields.index(self.dlFdSchedData_SLIV_field) + offset_value
        self.first_dlFdSchedData = False

    def findPos_dlHarqRxData(self, fields):
        offset_value = int(len(fields) / 2)
        self.dlHarqRx_hfn = fields.index(self.dlHarqRx_hfn_field) + offset_value
        self.dlHarqRx_sfn = fields.index(self.dlHarqRx_sfn_field) + offset_value
        self.dlHarqRx_slot = fields.index(self.dlHarqRx_slot_field) + offset_value
        self.dlHarqRx_rnti = [index for index, char in enumerate(fields) if
                              char == self.dlHarqRx_rnti_field][1] + offset_value
        self.nbOfFields = ([index for index, char in enumerate(fields) if char == self.dlHarqRx_rnti_field][2] -
                           [index for index, char in enumerate(fields) if char == self.dlHarqRx_rnti_field][1])
        # self.dlHarqRx_pci = fields.index(self.dlHarqRx_pci_field) + offset_value
        self.dlHarqRx_dtx = fields.index(self.dlHarqRx_dtx_field) + offset_value
        self.dlHarqRx_ackNack = fields.index(self.dlHarqRx_ackNack_field) + offset_value
        self.dlHarqRx_harqId = fields.index(self.dlHarqRx_harqId_field) + offset_value
        self.first_dlHarqRxData = False

    def addMsgTrace(self, current_line, nb_msg_per_rnti, rntiPci):

        current_line = current_line.replace("\n", "").replace(" ", "")
        # print('current_line: ' + current_line)

        data = []
        for i in range(self.dataSize):
            data.append("")

        msg_name = current_line.split(":")[0]
        fields = current_line.split(":")[1].split(",")

        if msg_name == "dlFdSchedData":
            if self.first_dlFdSchedData:
                self.findPos_dlFdSchedData(fields)
            data[self.msgName] = msg_name
            data[self.hfn] = fields[self.dlFdSchedData_hfn]
            data[self.sfn] = fields[self.dlFdSchedData_sfn]
            data[self.slot] = fields[self.dlFdSchedData_slot]
            data[self.rnti] = fields[self.dlFdSchedData_rnti]
            data[self.mcs] = fields[self.dlFdSchedData_mcs]
            data[self.tbsize] = fields[self.dlFdSchedData_tbSize]
            data[self.txNumber] = fields[self.dlFdSchedData_txNumber]
            data[self.HarqId_fd] = fields[self.dlFdSchedData_harqId]
            data[self.K1] = fields[self.dlFdSchedData_K1]
            data[self.layers] = fields[self.dlFdSchedData_layers]
            data[self.numOfPrb] = fields[self.dlFdSchedData_numOfPrb]
            data[self.SLIV] = fields[self.dlFdSchedData_SLIV]

            try:
                rntiPci[data[self.rnti]]
            except Exception as e:
                rntiPci[data[self.rnti]] = fields[self.dlFdSchedData_pci]
                print("New RNTI found in dlFdSchedData: " + str(data[self.rnti]))
            else:
                if rntiPci[data[self.rnti]] != fields[self.dlFdSchedData_pci]:
                    print("I Need your help boss. RNTI found on 2 PCIs")
                    exit(999)

            new_line = data[0]
            for i in range(self.dataSize - 1):
                new_line = new_line + ";" + data[i + 1]
            new_line = new_line + "\n"

            self.file_filtered_fd.write(new_line)

        if msg_name == "dlHarqRxDataArray":
            if self.first_dlHarqRxData:
                self.findPos_dlHarqRxData(fields)

            # nb_harq_block = (len(fields) - (6+self.nbHarqBlocks*self.nbOfFields + 30)) // self.nbOfFields
            # 386 car entete =  4 champs + 32 blocs HARQ * 11 champs et plus 4eres valeurs
            # print(len(fields))
            # print(nb_harq_block)
            for i in range(self.nbHarqBlocks):  # Plusieurs reponse HARQ dans un block"
                if fields[self.dlHarqRx_rnti + self.nbOfFields * i] == "0":
                    print(current_line)
                if fields[self.dlHarqRx_rnti + self.nbOfFields * i] == "":
                    break
                data[self.msgName] = msg_name
                data[self.hfn] = fields[self.dlHarqRx_hfn]
                data[self.sfn] = fields[self.dlHarqRx_sfn]
                data[self.slot] = fields[self.dlHarqRx_slot]
                data[self.rnti] = fields[self.dlHarqRx_rnti + self.nbOfFields * i]
                data[self.dtx] = fields[self.dlHarqRx_dtx + self.nbOfFields * i]
                data[self.ackNack] = fields[self.dlHarqRx_ackNack + self.nbOfFields * i]
                try:
                    data[self.HarqId_hq] = fields[self.dlHarqRx_harqId + self.nbOfFields * i]
                except Exception as e:
                    print(current_line)
                    print(data[self.rnti])

                new_line = data[0]
                for i in range(self.dataSize - 1):
                    new_line = new_line + ";" + data[i + 1]
                new_line = new_line + "\n"

                self.file_filtered_fd.write(new_line)

        # On compte les messages par rnti
        try:
            nb_msg_per_rnti[data[self.rnti]]
        except Exception as e:
            nb_msg_per_rnti[data[self.rnti]] = 1
        else:
            nb_msg_per_rnti[data[self.rnti]] += 1


class dlDataPerRnti:

    def __init__(self, current_rnti, dossier, fichier, debug):

        if debug:
            traceFilePerRnti = dossier + "/parser_" + fichier + "_" + current_rnti + ".txt"
            self.traceFilePerRnti_fd = open(traceFilePerRnti, 'w')
            traceFilePerRntiPdsch = dossier + "/parser_" + fichier + "_" + current_rnti + "_PDSCH.txt"
            self.traceFilePerRntiPdsch_fd = open(traceFilePerRntiPdsch, 'w')

        self.debug = debug

        # Index de chaque input dans les lignes du fichier filtre (fichier du step 1)
        self.msgName = 0
        self.hfn = 1
        self.sfn = 2
        self.slot = 3
        self.rnti = 4
        self.mcs = 5
        self.tbsize = 6
        self.txNumber = 7
        self.HarqId_fd = 8
        self.K1 = 9
        self.layers = 10
        self.numOfPrb = 11
        self.SLIV = 12
        self.dtx = 13
        self.ackNack = 14
        self.HarqId_hq = 15

        # Index des infos par vslot (class dlMessage)
        self.dataHfn = 0
        self.dataSfn = 1
        self.dataSlot = 2
        # Pour dlFdSchedData
        self.dataMcs = 3
        self.dataTbSize = 4
        self.dataTxNumber = 5
        self.dataHarqId_fd = 6
        self.dataExpectedAckVslot = 7
        self.dataPrb = 8
        self.dataSymbols = 9
        # Pour dlHarqRxDataArray
        self.dataDtx = 3
        self.dataAckNack = 4
        self.dataHarqId_hq = 5

        self.nbHargMsg = 0
        self.nbFdSchedMsg = 0

        self.dlFdSchedData = None
        self.dlHarqRxDataArray = None

        self.errors = {"missingHarqMsg": 0, "missingHarqProc": 0, "ulDtx": 0}
        self.slotStats = {"Total": 0, "inStats": 0, "notInStats": 0}

        self.harq = [0, 0]  # nb CRC OK, nb CRC KO
        self.totalTb = [0, 0]
        self.totalMCS = 0
        self.tbSizeList = {}  # dictionnaire. clef = tbSize. valeur = [nb CRC OK, ,nb CRC KO]
        self.mcsList = {}  # dictionnaire. clef = mcs. valeur = [nb CRC OK, ,nb CRC KO]
        self.slotList = {}  # dictionnaire. clef = slot. valeur = [nb CRC OK, ,nb CRC KO]
        self.slotPrb = {}
        self.slotSymbols = {}

        self.stats = [0, 0, 0, 0]  # Tput, Bler, Mcs, Issue

        self.slivValue = {}
        for L in range(3, 15):
            for S in range(0, 3):
                if (L+S) <= 14:
                    if L-1 <= 7:
                        SLIV = 14 * (L-1) + S
                    else:
                        SLIV = 14 * (14 - L + 1) + (14 - 1 - S)
                    self.slivValue[SLIV] = [L, S, L+S]

    def addData(self, line):
        if line[self.msgName] == "dlFdSchedData":
            if self.dlFdSchedData is None:
                if self.debug:
                    self.traceFilePerRnti_fd.write("Add Instance dlFdSchedData\n")
                self.dlFdSchedData = dlMessage(self, line)
            self.dlFdSchedData.addDlFdSchedData(line)
        elif line[self.msgName] == "dlHarqRxDataArray":
            if self.dlHarqRxDataArray is None:
                if self.debug:
                    self.traceFilePerRnti_fd.write("Add Instance dlHarqRxDataArray\n")
                self.dlHarqRxDataArray = dlMessage(self, line)
            self.dlHarqRxDataArray.addDlHarqRxDataArray(line)
        else:
            print("WRONG MSG")
            if self.debug:
                self.traceFilePerRnti_fd.close()
            exit(-1)

    def computeStats(self, stats_file_fd):
        if self.debug:
            self.traceFilePerRnti_fd.write("\n\nStats\n")
        if self.debug:
            self.traceFilePerRntiPdsch_fd.write("vslot;sfn;slot;roundSfn;MCS;tbSize;txNumber;CRC\n")

        if self.dlFdSchedData is None:
            print("No dlFdSched Data ")
            exit(-1)

        if self.dlHarqRxDataArray is None:
            print("No dlHarqRxDataArray Data ")
            exit(-1)
        # On parcourt dlFdSchedData et on recherche expected vslot dans dlHarqRxDataArray:
        for vslot in self.dlFdSchedData.vslot:
            self.slotStats["Total"] += 1
            expected_ack_vslot = self.dlFdSchedData.data[vslot][self.dataExpectedAckVslot]
            try:
                self.dlHarqRxDataArray.vslot.index(expected_ack_vslot)
            except Exception as e:
                self.errors["missingHarqMsg"] += 1
                self.slotStats["notInStats"] += 1
                if self.debug:
                    self.traceFilePerRnti_fd.write("\tmissingHarqMsg for vSlot :" + str(vslot) + "\n")
            else:
                if self.dlHarqRxDataArray.data[expected_ack_vslot][self.dataDtx] == "NON_DTX":
                    try:
                        (self.dlHarqRxDataArray.data[expected_ack_vslot][self.dataHarqId_hq].
                         index(self.dlFdSchedData.data[vslot][self.dataHarqId_fd]))
                    except Exception as e:
                        self.errors["missingHarqProc"] += 1
                    else:
                        self.slotStats["inStats"] += 1

                        curSfn = self.dlFdSchedData.data[vslot][self.dataSfn]
                        curSlot = int(self.dlFdSchedData.data[vslot][self.dataSlot])
                        curMcs = int(self.dlFdSchedData.data[vslot][self.dataMcs])
                        curTbSize = int(self.dlFdSchedData.data[vslot][self.dataTbSize])
                        curTxNumber = self.dlFdSchedData.data[vslot][self.dataTxNumber]
                        curPrb = self.dlFdSchedData.data[vslot][self.dataPrb]
                        curSymbols = self.dlFdSchedData.data[vslot][self.dataSymbols]
                        curAckNack = self.dlHarqRxDataArray.data[expected_ack_vslot][self.dataAckNack]

                        if self.debug:
                            self.traceFilePerRnti_fd.write(str(self.dlFdSchedData.data[vslot]) + ", " +
                                                           str(curAckNack) + "\n")
                        if self.debug:
                            self.traceFilePerRntiPdsch_fd.write(str(vslot) + ";" + str(curSfn) + ";" +
                                                                str(curSlot) + ";" + str(curMcs) + ";" +
                                                                str(curTbSize) + ";" + str(curTxNumber) + ";" +
                                                                str(curAckNack) + "\n")

                        self.totalMCS += curMcs

                        try:
                            self.tbSizeList[curTbSize]
                        except Exception as e:
                            self.tbSizeList[curTbSize] = [0, 0]
                        try:
                            self.mcsList[curMcs]
                        except Exception as e:
                            self.mcsList[curMcs] = [0, 0]
                        try:
                            self.slotList[curSlot]
                        except Exception as e:
                            self.slotList[curSlot] = [0, 0]
                        try:
                            self.slotPrb[int(curPrb)]
                        except Exception as e:
                            self.slotPrb[int(curPrb)] = 0
                        try:
                            self.slotSymbols[curSymbols]
                        except Exception as e:
                            self.slotSymbols[curSymbols] = 0

                        if curAckNack == "ACK":
                            self.harq[0] += 1
                            self.totalTb[0] = self.totalTb[0] + int(curTbSize)
                            self.totalTb[1] = self.totalTb[1] + int(curTbSize)
                            self.tbSizeList[curTbSize][0] += 1
                            self.mcsList[curMcs][0] += 1
                            self.slotList[curSlot][0] += 1
                            self.slotPrb[int(curPrb)] += 1
                            self.slotSymbols[curSymbols] += 1
                        elif curAckNack == "NACK":
                            self.harq[1] = self.harq[1] + 1
                            self.totalTb[1] = self.totalTb[1] + int(curTbSize)
                            self.tbSizeList[curTbSize][1] += 1
                            self.mcsList[curMcs][1] += 1
                            self.slotList[curSlot][1] += 1
                            self.slotPrb[int(curPrb)] += 1
                            self.slotSymbols[curSymbols] += 1
                        else:
                            print("Incoherence CRC")
                            if self.debug:
                                self.traceFilePerRnti_fd.write("Inchorence CRC\n")
                            if self.debug:
                                self.traceFilePerRnti_fd.close()
                            exit(-1)
                else:
                    self.errors["ulDtx"] = self.errors["ulDtx"] + 1

        # Gestion des erreurs
        if self.slotStats['inStats'] == 0:
            print("ISSUE: inStats = 0")
            return

        if self.slotStats['notInStats'] > 50:
            self.stats[3] = 1

        firstVSlot = self.dlFdSchedData.vslot[0]
        lastVSlot = self.dlFdSchedData.vslot[len(self.dlFdSchedData.vslot) - 1]
        delta = lastVSlot - firstVSlot
        totalTime = delta * 0.0005
        print("FD Sched Time: {} sec".format(totalTime))
        stats_file_fd.write("FD Sched Time: " + str(totalTime) + " sec\n")

        firstVSlot = self.dlHarqRxDataArray.vslot[0]
        lastVSlot = self.dlHarqRxDataArray.vslot[len(self.dlHarqRxDataArray.vslot) - 1]
        delta = lastVSlot - firstVSlot
        totalTime = delta * 0.0005
        print("Harq Time: {} sec".format(totalTime))
        stats_file_fd.write("Harq Time: " + str(totalTime) + " sec\n")

        print("Slot stats: {}".format(self.slotStats))
        stats_file_fd.write("Slot stats: " + str(self.slotStats) + "\n")
        print("Errors: {}".format(self.errors))
        stats_file_fd.write("Errors: " + str(self.errors) + "\n")

        globalBler = round((1 - (float(self.harq[0]) / (float(self.harq[0]) + float(self.harq[1])))) * 100, 2)
        # print("BLER: {}%".format(globalBler))
        stats_file_fd.write("BLER: " + str(globalBler) + "%\n")
        self.stats[1] = globalBler

        avgMCS = round(float(self.totalMCS) / self.slotStats["inStats"], 3)
        # print("Avg MCS: {}".format(avgMCS))
        stats_file_fd.write("Avg MCS: " + str(avgMCS) + "\n")
        self.stats[2] = avgMCS

        phyTput = round(self.totalTb[0] / totalTime / 1000000, 3)  # All blocks (in bits)
        # print("Avg Phy Tput: {} Mbps".format(phyTput))
        stats_file_fd.write("Avg Phy Tput: " + str(phyTput) + " Mbps\n")
        self.stats[0] = phyTput

        # print("\n\tTBS Distribution - BLER")
        stats_file_fd.write("\n\tTBS Distribution - BLER\n")
        for k in sorted(self.tbSizeList.keys()):
            totalTbSize = self.tbSizeList[k][0] + self.tbSizeList[k][1]
            distTbSize = round(totalTbSize / self.slotStats["inStats"] * 100, 2)
            bler = round(self.tbSizeList[k][1] / totalTbSize * 100, 2)
            # print("\t\t{} bits: {} {}% {}%".format(k, totalTbSize, distTbSize, bler))
            stats_file_fd.write("\t\t{} bits: {} {}% {}%\n".format(k, totalTbSize, distTbSize, bler))

        # print("\n\tMCS Distribution - BLER")
        stats_file_fd.write("\n\tMCS Distribution - BLER\n")
        for k in sorted(self.mcsList.keys()):
            totalMcs = self.mcsList[k][0] + self.mcsList[k][1]
            distMcs = round(totalMcs / self.slotStats["inStats"] * 100, 2)
            bler = round(self.mcsList[k][1] / totalMcs * 100, 2)
            # print("\t\t{}: {} {}% {}%".format(k, totalMcs, distMcs, bler))
            stats_file_fd.write("\t\t{}: {} {}% {}%\n".format(k, totalMcs, distMcs, bler))

        # print("\n\tSlot Distribution - BLER")
        stats_file_fd.write("\n\tSlot Distribution - BLER\n")
        for k in sorted(self.slotList.keys()):
            totalSlot = self.slotList[k][0] + self.slotList[k][1]
            distSlot = round(totalSlot / self.slotStats["inStats"] * 100, 2)
            bler = round(self.slotList[k][1] / totalSlot * 100, 2)
            # print("\t\t{}: {} {}% {}%".format(k, totalSlot, distSlot, bler))
            stats_file_fd.write("\t\t{}: {} {}% {}%\n".format(k, totalSlot, distSlot, bler))

        # print("\n\tPRB Distribution")
        stats_file_fd.write("\n\tPRB Distribution\n")
        # print(self.slotPrb)
        for k in sorted(self.slotPrb.keys()):
            distSlot = round(self.slotPrb[k] / self.slotStats["inStats"] * 100, 2)
            stats_file_fd.write("\t\t{}: {} {}%\n".format(k,  self.slotPrb[k], distSlot))

        # print("\n\Symbols Distribution")
        stats_file_fd.write("\n\tSymbols Distribution\n")
        for k in sorted(self.slotSymbols.keys()):
            distSlot = round(self.slotSymbols[k] / self.slotStats["inStats"] * 100, 2)
            stats_file_fd.write("\t\t{}: {} {}%\n".format(k,  self.slotSymbols[k], distSlot))

        stats_file_fd.write("\n" + "*" * 108 + "\n\n")

    def closeTraceFile(self):
        self.traceFilePerRnti_fd.close()
        self.traceFilePerRntiPdsch_fd.close()


def parse_dl(input_file):

    debug = False
    (dossier, fichier) = os.path.split(input_file)
    nom_fichier = os.path.splitext(fichier)[0]
    file_filtered = dossier + "/" + nom_fichier + "_Filtered.csv"

    nb_msg_per_rnti = {}
    rntiPci = {}
    rnti_list_filtered = []
    rnti_list = []
    rntiInstance = []

    rntiIndex = 4

    # Step 1 - Filtre Input File
    # Info: On extrait certains IE des msg dlFdSchedData, dlHarqRxDataArray
    # Chaque ligne est au format "msg;hfn;sfn;slot;rnti;MCS;tbSize;txNumber;harqId Sched;K1;Layers;DTX;ackNack;HarqId"
    # Par RNTI on compte le nb de message total (dlFdSchedData + dlHarqRxDataArray).
    # Le RNTI est detecte dans le msg dlFdSchedData
    print("Start File Filtering")
    input_file_fd = open(input_file, 'r')
    file_filtered_obj = createFileFilteredDL(file_filtered)
    while 1:
        buffer_in = input_file_fd.readline()
        if buffer_in == "":
            file_filtered_obj.closeFileFilter()
            break
        if buffer_in.find("ERROR") == -1:
            if re.match(r'dlFdSchedData', buffer_in):
                file_filtered_obj.addMsgTrace(buffer_in, nb_msg_per_rnti, rntiPci)
            if re.match(r'dlHarqRxDataArray', buffer_in):
                file_filtered_obj.addMsgTrace(buffer_in, nb_msg_per_rnti, None)
    input_file_fd.close()
    print("File Filtering Done\n")

    # Step 2 - Filtre les RNTI
    print("Start RNTI Filtering")
    for key in nb_msg_per_rnti.keys():
        if nb_msg_per_rnti[key] > 100:
            rnti_list_filtered.append(key)
            print("RNTI " + str(key) + " is kept: " + str(nb_msg_per_rnti[key]) + " messages")
        else:
            print("RNTI " + str(key) + " is discarded: " + str(nb_msg_per_rnti[key]) + " messages")
    print("RNTI Filtering Done\n")

    # Step 3 - Extract data par RNTI à partir du fichier filtre
    # On cree une instance dlDataPerRnti par RTNI
    print("Start Data Extraction")
    file_filtered_fd = open(file_filtered, 'r')
    buffer_in = file_filtered_fd.readline()  # skip ligne entete
    while 1:
        buffer_in = file_filtered_fd.readline().replace("\n", "")
        if buffer_in == "":
            break
        current_rnti = buffer_in.split(";")[rntiIndex]
        # Si le rnti n'est pas dans la liste filtre, on passe a la ligne suivante
        try:
            rnti_list_filtered.index(current_rnti)
        except Exception as e:
            pass
        else:
            # s'il n'y a pas d'instance dlDataPerRnti pour le rnti, il est cree
            try:
                rnti_list.index(current_rnti)
            except Exception as e:
                print("Add Instance dlDataPerRnti for RNTI:" + str(current_rnti))
                rnti_list.append(current_rnti)
                rntiInstance.append(dlDataPerRnti(current_rnti, dossier, nom_fichier, debug))
            rntiInstance[rnti_list.index(current_rnti)].addData(buffer_in.split(";"))
    file_filtered_fd.close()
    print("Data Extraction Done")

    # Calcul des stats
    if True:
        print("\nStart Stats Computation")
        stats_file = dossier + "/" + nom_fichier + "_DlSched_stats.txt"
        stats_file_fd = open(stats_file, 'w')
        stats = {}

        print('rnti_list: {}'.format(rnti_list))
        print('rntiPci: {}'.format(rntiPci))
        for rnti in rnti_list:
            print("\nRNTI: {} - PCI:".format(rnti, rntiPci[rnti]))
            stats_file_fd.write("RNTI: " + str(rnti) + "\n")
            rntiInstance[rnti_list.index(rnti)].computeStats(stats_file_fd)
            if debug:
                rntiInstance[rnti_list.index(rnti)].closeTraceFile()
            stats[rntiPci[rnti]] = rntiInstance[rnti_list.index(rnti)].stats
        stats_file_fd.close()

        file_filtered_fd.close()
        print("\nStats Done")

        sortedStats = {}
        for key in sorted(stats):
            sortedStats[key] = stats[key]

        return sortedStats


def myData(inputFile, myDataSet):
    testList = ["01_CB009836", "03_CB009836", "08_CB009836", "13_CB009836", "18_CB009836", "22_CB009836"]
    curDate = datetime.datetime.now().strftime("%Y-%m-%d")
    testId = ""
    inputFile_fd = open(inputFile, 'r')
    myDataSet_fd = open(myDataSet, 'a')
    while 1:
        buffer_in = inputFile_fd.readline()
        if buffer_in == "":
            inputFile_fd.close()
            myDataSet_fd.close()
            break

        if re.search(rf'\d\d_CB009836', buffer_in):
            testId = re.search(rf"\d\d_CB009836", buffer_in).group()

        if re.match(rf'Software:\s(.+)', buffer_in):
            sw = re.match(rf'Software:\s(.+)', buffer_in).groups()[0]

        myRegExp1 = r'(?P<PCI>PCI\s\d+):\s(?P<Tput>\d+).+Bler:\s(?P<Bler>\d+.\d+)'
        myRes = re.search(myRegExp1, buffer_in)
        if myRes:
            if testId in testList:
                print(curDate + ";" + sw + ";" + testId + ";" + myRes['PCI'] + ";" +
                      myRes['Tput'] + ";" + myRes['Bler'])
                myDataSet_fd.write(curDate + "," + sw + "," + testId + "," + myRes['PCI'] + "," +
                                   myRes['Tput'] + "," + myRes['Bler'] + "\n")
