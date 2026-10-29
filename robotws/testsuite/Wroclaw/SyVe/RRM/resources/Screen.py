class Screen(object):

    @staticmethod
    def create(name):
        """
        Function creates screen command
        :param name: Unique name for the screen.
         When screen names are the same, they are distinguished by random number -
         not handled by this module.
        :return: create screen command
        """
        return "screen -dmS {}".format(name)

    @staticmethod
    def execute(name, command):
        """
        Function creates screen command for executing bash commands inside the existing screen
        :param name: Unique name of the created screen
        :param command: the command to be executed inside the screen
        :return: execute command
        """
        return "screen -S {} -X stuff '{}\r'".format(name, command)

    @staticmethod
    def delete(name):
        """
        Function creates a command for deleting existing screen
        :param name: Unique name of the created screen
        :return: delete screen command
        """
        return "screen -S {} -X kill".format(name)

    @staticmethod
    def list_screens(name):
        """
        Function lists existing screens and greps for specific name
        :param name: Searched name of the screen
        :return: list of screens found by grep command
        """
        return "screen -ls | grep {}".format(name)
