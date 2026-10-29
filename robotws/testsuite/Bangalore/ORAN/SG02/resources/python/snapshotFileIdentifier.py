
import time
import yaml
import re
import logging
import os
from zipfile import ZipFile
import os
import tarfile
import lzma


class snapshotFileIdentifier():

    def unzip(self, fileName):
        fileNamex = fileName

        fileNamexSplit = fileNamex.split(".z")

        with ZipFile(fileName, 'r') as f:
            f.extractall(fileNamexSplit[0])

    def untarFile(self, filename):
        tempList = lzma.open(filename).read()
        return len(tempList), tempList, filename

    def __opensnapshotHistory__(self, directoryToBeChanged, path, fileToBeChecked):

        current_working_directory = os.getcwd()
        fileDescriptor = open(path + "/" + directoryToBeChanged + "/snapshot_file_list.txt")
        snapshotHistoryFileDescriptor = fileDescriptor.readlines()
        fileContentinFile, extractFileName = self.__returnFileNameNetconfSnapshotCollection__(
                snapshotHistoryFileDescriptor, fileToBeChecked)
        print("*************")
        print(fileContentinFile)
        extractFileNameSplitWithcolon = extractFileName.split(":")

        print(extractFileNameSplitWithcolon)
        self.unzip(path + "/" + directoryToBeChanged + "/" + extractFileNameSplitWithcolon[0])
        extractFileNameSplit = extractFileNameSplitWithcolon[0].split(".")
        fileContentinFile = fileContentinFile.strip()
        print("*******************************************************")
        print(fileContentinFile)
        file_path, filepathList, filename = self.untarFile(
                path + "/" + directoryToBeChanged + "/" + extractFileNameSplit[0] + "/" + fileContentinFile)
        print(file_path)
        print(filepathList)
        print(filename)
        return file_path, filepathList, filename

    def __openNetconfSnapshot__(self, file):
        fileDescriptorNetconfSnapshot = open(file)
        return fileDescriptorNetconfSnapshot

    def __returnFileNameNetconfSnapshotCollection__(self, snapshotHistoryFileDescriptor, fileToBeChecked):
        fileNameCounter = 0
        extractFileName = ""
        NetconfSnapshotCollectionCounter = 0
        counter = 0
        fileContentinFile = ""
        for fileContent in snapshotHistoryFileDescriptor:
            if fileContent.startswith(' '):
                if fileToBeChecked in fileContent:
                    fileContentinFile = fileContent
                    break
            elif fileNameCounter == 0:
                extractFileName = fileContent
                fileNameCounter = fileNameCounter + 1
            elif fileNameCounter == 1:
                extractFileName = fileContent
        return fileContentinFile, extractFileName

    def snapshotGetWithoutFilter(self, filename, path, fileToBeChecked):
        filepath = path + filename
        self.unzip(filepath)
        file_path, filepathList, filename = self.__opensnapshotHistory__('Snapshotfile', path, fileToBeChecked)
        return file_path, filepathList, filename
