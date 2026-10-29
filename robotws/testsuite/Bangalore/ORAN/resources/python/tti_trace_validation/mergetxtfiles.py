"""
    This File will Merge .txt Files
"""
import os
from .downloadttitracervld import DownloadTtiTracerVld


class MergetxtFiles():
    """
        Class which convert .dat to .txt files
    """

    def __init__(self):
        pass

    def _convert_dat_to_txt(self, log_directory, filetype, build="None"):
        directory_files = os.listdir(log_directory)
        dat_files = \
            [os.path.join(log_directory, dat_file) for dat_file in directory_files
             if dat_file.endswith(".dat")]
        if filetype == "UL":
            dat_files1 = [dat_file1 for dat_file1 in dat_files if "_UL_" in dat_file1]
        else:
            dat_files_dl = [dat_file1 for dat_file1 in dat_files if "_DL_" in dat_file1]
        if build == "None":
            exepath = "/home/ute/SBTS22R4_ENB_0000_000178_000000_TtiTracer\
            /TtiTracer/ExcelTraceAnalyzerTool/wmp/BinaryFileParser/tti_trace_parser_wmp-linux.exe "
        else:
            DownloadTtiTracerVld._dwdvalidator(
                self, build=build, ttitracervalidatordownloadpath=log_directory)
            exepath = self.ttiexe + ' '
            os.chmod(self.ttiexe, 0o777)
        if filetype == "UL":
            for ulfile in dat_files1:
                ulfile1 = ulfile.split(".dat")
                cmd = exepath + ulfile + " " + ulfile1[0] + ".txt"
                os.system(cmd)
            self.typ = "_UL_"
        else:
            for dlfile in dat_files_dl:
                dlfile1 = dlfile.split(".dat")
                cmd = exepath + dlfile + " " + dlfile1[0] + ".txt"
                os.system(cmd)
            self.typ = "_DL_"

    def _mergefiles(self, log_directory, typ):
        dat_files2 = [os.path.join(log_directory, dat_file2)
                      for dat_file2 in os.listdir(log_directory)
                      if typ in dat_file2 if dat_file2.endswith(".txt")]
        flag = 0
        self.outputpath = log_directory + "/file3.txt"
        with open(self.outputpath, 'w') as outfile:
            for names in dat_files2:
                with open(names) as infile:
                    if flag == 0:
                        next(infile)
                        outfile.write(infile.read())
                        flag = 1
                    else:
                        next(infile)
                        next(infile)
                        outfile.write(infile.read())
