import os
import shutil


class GetFileName:
    def __init__(self):
        pass

    def getFileIterFileName(self):
        listFile = os.listdir("/home/ute/Plan/")
        print(listFile)
        splitListLastItemWithDot = listFile[-1].split(".")
        splitListLastItemWithunderScore = splitListLastItemWithDot[0].split(
            "_")
        VariableInt = int(splitListLastItemWithunderScore[1]) + 1
        newFileNameConstruct = splitListLastItemWithunderScore[0]+"_" + str(
            VariableInt) + str(".") + str(splitListLastItemWithDot[1])
        print(newFileNameConstruct)
        shutil.copy2('/home/ute/Plan/' +
                     str(listFile[-1]), '/home/ute/Plan/' + str(newFileNameConstruct))

        return (newFileNameConstruct)
