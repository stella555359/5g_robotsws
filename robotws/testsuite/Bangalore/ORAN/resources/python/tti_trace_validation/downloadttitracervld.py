"""
    This File used to download TtiTracer.zip file.
"""
import zipfile
import os
import requests


class DownloadTtiTracerVld:
    """
    This class used to download TtiTracer.zip file.
    """

    def __init__(self):
        pass

    def _dwdvalidator(self, build, ttitracervalidatordownloadpath):
        count = 0
        if os.path.isfile(str(ttitracervalidatordownloadpath)+"/"+str(build)+"_TtiTracer.zip"):
            os.remove(str(ttitracervalidatordownloadpath)+"/"+str(build)+"_TtiTracer.zip")
        if not os.path.isfile(str(ttitracervalidatordownloadpath) + "/"
                              + str(build) + "_TtiTracer.zip"):
            while count < 2:
                linkbuilddownloadercreation = \
                    "https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build/"\
                    + str(build).split("_")[0] + "/" + str(build) + "_TtiTracer.zip"
                print(linkbuilddownloadercreation)
                response = \
                    requests.get(linkbuilddownloadercreation, stream=True, verify=False, timeout=60)
                cwd = ttitracervalidatordownloadpath
                build_residing = str(cwd) + "/" + str(build) + "_TtiTracer.zip"
                # if not os.path.isfile(build_Residing):
                with open(build_residing, "wb") as f:
                    for chunk in response.iter_content(chunk_size=10000000):
                        if chunk:
                            f.write(chunk)
                            file_info = os.stat(build_residing)
                            file_size_download = convert_bytes(file_info.st_size)
                            print(str({(file_size_download)}) + "Downloaded")
                        else:
                            break
                count += 1
                if int(file_size_download[0]) > 0:
                    ttibuild = ttitracervalidatordownloadpath+"/"+build+"_TtiTracer.zip"
                    ttiunzip = str(ttitracervalidatordownloadpath)+"/"+build+"_TtiTracer"
                    self.ttiexe = ttiunzip + "/TtiTracer/ExcelTraceAnalyzerTool/wmp/BinaryFileParser/" \
                                             "tti_trace_parser_wmp-linux.exe"
                    # unzip the zip file to same name folder
                    with zipfile.ZipFile(ttibuild, 'r') as zip_ref:
                        zip_ref.extractall(ttiunzip)
                    break
                build1 = build.split("_ENB")[0]
                build2 = build1.replace(build1, 'SBTS00')
                build = build2+"_ENB"+build.split("_ENB")[1]
                print(type(file_size_download), file_size_download[0])
        filesize = file_size_download
        print(filesize)
        if filesize == '0':
            raise Exception("Build not found in WFT")


def convert_bytes(num):
    """
        This Function will convert to string
    """
    for data in ['bytes', 'KB', 'MB', 'GB', 'TB']:
        if num < 1024.0:
            return "%3.1f %s" % (num, data)
        num /= 1024.0
