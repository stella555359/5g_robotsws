import time
import subprocess
import os
import logging
import zipfile
Author_emil = "arunkumar.a@nokia.com"


class file_handler(object):
    '''
    file handler
    '''
    def logging_mechanism(self):
        logging.basicConfig(filename="file_hander.log",
                                     format="%(asctime)s %(message)s",
                                     filemode='w')
        logger = logging.getLogger()
        logger.setLevel(logging.DEBUG)
        return logger

    @staticmethod
    def remove_file_from_linux_machine(File_path, File_name=None, delete_all_file=True):
        '''
        Main scope to remove file from host machine.
        Handled scenario: Test execution is failed due to VM space overloaded with sw builds.
        '''
        class_object = file_handler()  # for access instance method from static method
        log = class_object.logging_mechanism()
        log.info("*** Logging is started ****")
        try:
            file_existance = os.path.exists(File_path)
            if bool(file_existance):
                try:
                    if delete_all_file:
                        result = subprocess.call(f"cd {File_path}; rm -rf *", shell=True)
                        log.info(f"result: {result}")
                        if result:
                            log.error(f" Files are not deleted under {File_path}\n retrun code: {result}")
                        else:
                            log.info(f"Under the {File_path} all files are deleted\n retrun code: {result}")
                        return not result
                    else:
                        result = subprocess.call(f"cd {File_path}; rm -rf {File_name}", shell=True)
                        if result:
                            log.error(f" Files are not deleted under {File_path}\n retrun code: {result}")
                        else:
                            log.info(f"Under the {File_path} all files are deleted\n retrun code: {result}")
                        return not result
                except subprocess.CalledProcessError as err:
                    log.error(f"Subprocess module failed.\nReason <{err}>")
        except os.error as err:
            log.error(f"File not found\n Reason: <{err}>")

    def unzip_folder(self, zip_file_path: str, target_path: str) -> bool:
        """
        Unzip files in folder using zipfile module.
        :Params zip_file_path = zipped file path
        :Params target_path = unzip file path
        """
        if zip_file_path:
            list_of_file = os.listdir(zip_file_path)
            for item in list_of_file:
                print(f"list of files :{item}")
                print(type(item))
                if item.endswith(".zip"):
                    file_path = os.path.join(zip_file_path, item)
                    with zipfile.ZipFile(file_path, "r") as fd:
                        fd.extractall(target_path)
                    return True
        return False
