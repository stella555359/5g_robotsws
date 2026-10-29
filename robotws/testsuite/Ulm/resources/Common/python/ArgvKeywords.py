from robot.api.deco import keyword
import os
import sys


class ArgvKeywords:

    @keyword("Get Absolute Variable File Path From CLI")
    def get_absolute_variable_file_path_from_cli(self):
        """
        Findet den Pfad, der mit -V oder --variablefile übergeben wurde,
        inklusive Form mit Doppelpunkt (--variablefile:<pfad>).
        Gibt den absoluten Pfad zurück oder None, wenn nicht gefunden.
        """
        args = sys.argv

        # 1. --variablefile <pfad> oder -V <pfad>
        for flag in ("--variablefile", "-V"):
            if flag in args:
                idx = args.index(flag)
                try:
                    return os.path.abspath(args[idx + 1])
                except IndexError:
                    return None

        # 2. --variablefile:<pfad>
        for arg in args:
            if arg.startswith("--variablefile:"):
                path = arg.split(":", 1)[1]
                return os.path.abspath(path)

        return None
