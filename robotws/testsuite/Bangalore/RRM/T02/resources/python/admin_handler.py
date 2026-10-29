# utf-8
from taf.sbts.oam.coam.admin import admin
import logging
"""
Author: Arunkumar A
email: arunkumar.a@nokia.com
Handling Admin operations
"""


def check_connection(func):
    def wrapper(self, *args, **kwargs):
        if self.connection is None:
            self.connection = self.coam.connect_to()
        return func(self, *args, **kwargs)
    return wrapper


class admin_handler(object):
    """
    Class does required admin functions.
    """
    def __init__(self):
        """
        estabilishing admin connection
        """
        self.coam = admin()
        self.connection = None
        logging.basicConfig(filename="Unexpected_alarm",
                            format="%(asctime)s %(levelname)s %(module)s %(funcName)s %(message)s",
                            filemode='w')
        self.logger = logging.getLogger()
        self.logger.setLevel(logging.DEBUG)

    @check_connection
    def delete_object_recommission(self, distname=None, params=[], operation="delete",
                                   skip_relation_error=True, activate=True):
        """
        delete object in current scf.
        """
        print(distname)
        try:
            if distname is not None:
                delete_obj = self.connection.perform_object_recommissioning(dist_name=distname,
                                                                            parameter=params,
                                                                            operation=operation,
                                                                            should_activate=activate)
                print(delete_obj)
                return True
            else:
                raise FileNotFoundError("dist name not provided.")
        except Exception as err:
            print(f"Object not deleted. \n<Reason: {err}>")

    @check_connection
    def get_object_by_admin(self, distname=None, params=[], output=True):
        '''
        Get the object(MOC) or the parametersin scf
        '''
        try:
            if distname is not None:
                print(f"dict_name: {distname}")
                get_object = self.connection.get_parameter_by_distname(dist_name=distname,
                                                                       parameter_list=params,
                                                                       detailed_output=output)
                print(get_object)
                try:
                    if get_object["errorCode"] != 0:
                        print("The Get object function successful")
                    elif get_object["errorCode"] != 7:
                        print("Unexpected error.!")
                except Exception as err:
                    raise err("Get object verification failed.")
                return True
        except Exception as err:
            raise err(f"get_object function failed. due to incorrect {distname} or admin issue")

    @check_connection
    def verfiy_unexpected_active_alarm(self, allowed_FID, target_path):
        """
        alarm verification by fault id's
        """
        try:
            alarm_verification = self.connection.get_active_alarms()
            for fault in allowed_FID:
                if fault == alarm_verification["faultId"]:
                    continue
                else:
                    print("Unexpected Alam Found.!")
                    self.logger.error(f"Unexpected Alarm:\n{fault}")
                    return False
        except Exception as err:
            raise err("Alarm verification failed.")
