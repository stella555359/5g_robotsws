"""
    This file will do TtiTraceValidation.
"""
import os
import csv
from .downloadttitracervld import DownloadTtiTracerVld
from .mergetxtfiles import MergetxtFiles


class tti_trace_validation():
    """
    This class will do TtiTraceValidation.
    """
    def __init__(self):
        pass

    def _parsecsv(self, col1, val1, col2, val2):
        outputpath1 = self.outputpath.split(".txt")
        outputpath1 = outputpath1[0]+'.csv'
        with open(self.outputpath, 'r') as in_file:
            stripped = (line.strip() for line in in_file)
            lines = (line.split(",") for line in stripped if line)
            with open(outputpath1, 'w') as out_file:
                writer = csv.writer(out_file)
                writer.writerows(lines)
        csvpath = outputpath1
        with open(csvpath, 'r') as file:
            reader = csv.DictReader(file)
            abc = []
            for row in reader:
                abc.append(row[col1])
        with open(csvpath, 'r') as file:
            reader = csv.DictReader(file)
            abc1 = []
            for row in reader:
                abc1.append(row[col2])
        select_cmd = [i for i in abc]
        select_cmd1 = [i for i in abc1]
        self.matched = []
        self.matcheddict = {}
        for i in range(len(select_cmd)):
            if str(select_cmd[i]) in val1:
                if str(select_cmd1[i]) in val2:
                    self.matched.append((str(select_cmd[i]), select_cmd1[i]))
        for i in range(len(self.matched)):
            if self.matched[i] in self.matcheddict:
                self.matcheddict[self.matched[i]] += 1
            else:
                self.matcheddict[self.matched[i]] = 1

    def parse(self, log_directory, filetype, col1, val1, col2, val2, build="None"):
        cdc = []
        directory_files1 = os.listdir(log_directory)
        for ijk in directory_files1:
            if os.path.isdir(log_directory+"/"+ijk):
                abc = os.listdir(log_directory+"/"+ijk)
                if "4g" in abc:
                    abc1 = os.listdir(log_directory+"/"+ijk+"/4g")
                    if "condor" in abc1:
                        bcd = log_directory+"/"+ijk+"/4g/condor"
                        cdc.append(bcd)
        print(cdc)
        for log_directory1 in cdc:
            MergetxtFiles._convert_dat_to_txt(self, log_directory1, filetype, build)
            MergetxtFiles._mergefiles(self, log_directory1, self.typ)
            self._parsecsv(col1, val1, col2, val2)
        res = \
            [{'MCS': k[0], "Modulation Type":k[1], 'count': v}
                for k, v in self.matcheddict.items()]
        # if len(self.matched) > 0:
        if len(res) >= len(val1):
            print("*****Res:", res)
            print("******PASS*******")
            return res
        else:
            print("******Fail*******")
            cdc = []
            for ij1 in res:
                cdc.append(ij1['MCS'])
            sss = set(cdc)
            temp = [x for x in val1 if x not in sss]
            raise Exception(str(temp) + "These MCS value not found in CSV")
