import time
import os
from zipfile import ZipFile
import tarfile
import lzma
import re


class snapshotFileIdentifier:

    def unzip(self, fileName):
        fileNamex = fileName
        fileNamexSplit = fileNamex.split(".z")
        with ZipFile(fileName, 'r') as f:
            f.extractall(fileNamexSplit[0])
        return fileNamexSplit

    def untarFile(self, filename):
        tempList = lzma.open(filename).read()
        return len(tempList), tempList, filename

    def __opensnapshotHistory__(
        self,
        directoryToBeChanged,
        path,
        fileToBeChecked,
    ):
        file_pathList = []
        filenameList = []

        current_working_directory = os.getcwd()
        fileDescriptor = open(
            directoryToBeChanged + "/snapshot_file_list.txt"
        )
        snapshotHistoryFileDescriptor = fileDescriptor.readlines()

        extractFileNameNestedList = (
            self.__returnFileNameNetconfSnapshotCollection__(
                snapshotHistoryFileDescriptor,
                fileToBeChecked,
            )
        )

        for extractFileNameList in extractFileNameNestedList:
            extractFileNameListWithcolon = (
                extractFileNameList[0].split(":")
            )
            self.unzip(
                directoryToBeChanged
                + "/"
                + extractFileNameListWithcolon[0]
            )

            extractFileNameSplit = (
                extractFileNameListWithcolon[0].split(".")
            )
            fileContentinFile = extractFileNameList[1].strip()

            file_path, filepathList, filename = self.untarFile(
                directoryToBeChanged
                + "/"
                + extractFileNameSplit[0]
                + "/"
                + fileContentinFile
            )

            file_pathList.append(file_path)
            filenameList.append(filename)

        return file_pathList, filepathList, filenameList

    def __openNetconfSnapshot__(self, file):
        fileDescriptorNetconfSnapshot = open(file)
        return fileDescriptorNetconfSnapshot

    def __returnFileNameNetconfSnapshotCollection__(
        self,
        snapshotHistoryFileDescriptor,
        fileToBeChecked,
    ):
        extractFile = ""
        extractFileName = []
        NetconfSnapshotCollectionCounter = 0
        counter = 0

        tuppletest = []
        fileContentinFile = ""

        if "NetconfRpcMessage" in fileToBeChecked:
            list_file = ["NetconfRpcMessageTrace", "RPC.log"]
        else:
            list_file = []

        for fileContent in snapshotHistoryFileDescriptor:
            if fileContent.startswith(" "):
                if (
                    list_file
                    and list_file[0] in fileContent
                    and counter == 1
                ):
                    fileContentinFile = fileContent
                    NetconfSnapshotCollectionCounter = 1

                elif (
                    list_file
                    and list_file[1] in fileContent
                    and counter == 1
                ):
                    fileContentinFile = fileContent
                    NetconfSnapshotCollectionCounter = 1

            elif counter == 0 and NetconfSnapshotCollectionCounter == 0:
                extractFile = fileContent
                counter = 1

            elif counter == 1 and NetconfSnapshotCollectionCounter == 0:
                extractFile = fileContent
                counter = 1

            if NetconfSnapshotCollectionCounter == 1:
                tuppletest = [extractFile, fileContentinFile]
                extractFileName.append(tuppletest)
                tuppletest = []
                NetconfSnapshotCollectionCounter = 0

        return extractFileName

    def snapshotGetWithoutFilter(
        self,
        filename,
        path,
        fileToBeChecked,
    ):
        filepath = path + filename
        fileNamexSplit = self.unzip(filepath)
        file_path, filepathList, filename = (
            self.__opensnapshotHistory__(
                fileNamexSplit[0],
                path,
                fileToBeChecked,
            )
        )
        return file_path, filepathList, filename

    def get_file_contents(self, file_path):
        try:
            with open(file_path, "r", encoding="utf-8") as f:
                return f.read()
        except FileNotFoundError:
            print(
                f"Error: The file '{file_path}' was not found."
            )
            return ""
        except Exception as e:
            print(
                f"An error occurred while reading the file "
                f"'{file_path}': {e}"
            )
            return ""

    def software_slot_info(self, file_path, build_name):
        build_nums = build_name[:]
        master = []

        log_file_contents = self.get_file_contents(file_path)
        print("---test----")

        pattern = (
            r"<software-slot><name>(.*?)</name>.*?"
            r"<active>(.*?)</active>.*?"
            r"<running>(.*?)</running>.*?"
            r"<build-name>(.*?)</build-name>"
        )

        matches = re.findall(
            pattern,
            log_file_contents,
            re.DOTALL,
        )

        for match in matches:
            slot_name, active, running, build_name = match
            print(
                f"Software Slot: {slot_name}, "
                f"Active: {active}, "
                f"Running: {running}, "
                f"Build Name: {build_name}"
            )
            master.append(
                [slot_name, active, running, build_name]
            )

        build_nums.remove(master[-1][3])
        build_nums.remove(master[-2][3])
        print(build_nums[0])

        return build_nums[0], master[-1], master[-2]
