"""
Spark MultiUE Helper Library for CB014095
Provides simplified access to sparkMultiUE_yiyuan library internals

Author: Hongye.fu
Contact: Hongye.fu@nokia-sbell.com
"""

from robot.libraries.BuiltIn import BuiltIn


class CB014095_Spark_Helper:
    """Helper library to access Spark MultiUE internal data structures"""

    ROBOT_LIBRARY_SCOPE = 'GLOBAL'

    def get_spark_ue_config(self, ue_alias, key):
        """Get Spark UE configuration value from library store.

        Args:
            ue_alias: UE alias name (e.g., 'spark_UE')
            key: Configuration key ('host', 'username', 'password', 'apppath')

        Returns:
            Configuration value

        Example:
            | ${ue_host} | Get Spark UE Config | spark_UE | host |
        """
        # Try sparkMultiUE_yiyuan first (for T845)
        try:
            lib = BuiltIn().get_library_instance('sparkMultiUE_yiyuan')
            if ue_alias in lib.store:
                return lib.store[ue_alias].ue_config[key]
        except Exception:
            pass

        # Try sigspark_mmw3 (for T929 and CB010636)
        try:
            lib = BuiltIn().get_library_instance('sigspark_mmw3')
            if ue_alias in lib.store:
                return lib.store[ue_alias].ue_config[key]
        except Exception:
            pass

        raise KeyError(f"UE alias '{ue_alias}' not found in any Spark library store")

    def get_spark_log_config(self, ue_host, key):
        """Get Spark log configuration value from library client store.

        Args:
            ue_host: UE PC hostname/IP
            key: Log config key ('logpath', 'logname')

        Returns:
            Log configuration value

        Example:
            | ${log_path} | Get Spark Log Config | ${ue_host} | logpath |
        """
        # Try sparkMultiUE_yiyuan first
        try:
            lib = BuiltIn().get_library_instance('sparkMultiUE_yiyuan')
            if ue_host in lib.client:
                return lib.client[ue_host]['log'][key]
        except Exception:
            pass

        # Try sigspark_mmw3
        try:
            lib = BuiltIn().get_library_instance('sigspark_mmw3')
            if ue_host in lib.client:
                return lib.client[ue_host]['log'][key]
        except Exception:
            pass

        raise KeyError(f"UE host '{ue_host}' not found in any Spark library client store")

    def get_spark_ue_object(self, ue_alias):
        """Get Spark UE object from library store.

        Args:
            ue_alias: UE alias name

        Returns:
            Spark UE object

        Example:
            | ${spark_obj} | Get Spark UE Object | spark_UE |
        """
        # Try sparkMultiUE_yiyuan first
        try:
            lib = BuiltIn().get_library_instance('sparkMultiUE_yiyuan')
            if ue_alias in lib.store:
                return lib.store[ue_alias]
        except Exception:
            pass

        # Try sigspark_mmw3
        try:
            lib = BuiltIn().get_library_instance('sigspark_mmw3')
            if ue_alias in lib.store:
                return lib.store[ue_alias]
        except Exception:
            pass

        raise KeyError(f"UE alias '{ue_alias}' not found in any Spark library store")

    def export_spark_message_detail(self, ue_alias, xml_path, saf_path):
        """Export Spark L3 message detail from .saf to XML format.

        Args:
            ue_alias: UE alias name
            xml_path: Full path to output XML file
            saf_path: Full path to input .saf file

        Returns:
            Export command success status

        Example:
            | ${success} | Export Spark Message Detail |
            | ... | spark_UE | C:/tmp/output.xml | C:/tmp/input.saf |
        """
        # Try sparkMultiUE_yiyuan first
        try:
            lib = BuiltIn().get_library_instance('sparkMultiUE_yiyuan')
            if ue_alias in lib.store:
                return lib.store[ue_alias]._send_common_msg(
                    "ExportMessageDetail",
                    param={"ExportFileName": xml_path, "Logfile": saf_path}
                )
        except Exception:
            pass

        # Try sigspark_mmw3
        try:
            lib = BuiltIn().get_library_instance('sigspark_mmw3')
            if ue_alias in lib.store:
                return lib.store[ue_alias]._send_common_msg(
                    "ExportMessageDetail",
                    param={"ExportFileName": xml_path, "Logfile": saf_path}
                )
        except Exception:
            pass

        raise KeyError(f"UE alias '{ue_alias}' not found in any Spark library store")

    def get_spark_message_response(self, ue_alias, message_type):
        """Get Spark message response.

        Args:
            ue_alias: UE alias name
            message_type: Message type (e.g., 'ExportMessageDetail')

        Returns:
            Message response

        Example:
            | ${response} | Get Spark Message Response |
            | ... | spark_UE | ExportMessageDetail |
        """
        # Try sparkMultiUE_yiyuan first
        try:
            lib = BuiltIn().get_library_instance('sparkMultiUE_yiyuan')
            if ue_alias in lib.store:
                return lib.store[ue_alias]._get_msg(message_type)
        except Exception:
            pass

        # Try sigspark_mmw3
        try:
            lib = BuiltIn().get_library_instance('sigspark_mmw3')
            if ue_alias in lib.store:
                return lib.store[ue_alias]._get_msg(message_type)
        except Exception:
            pass

        raise KeyError(f"UE alias '{ue_alias}' not found in any Spark library store")
