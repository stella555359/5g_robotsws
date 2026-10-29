import logging.handlers
import inspect


class Logger(object):
    theStaticLogger = None

    def __init__(self, name):
        logger = logging.getLogger(name)
        # logger.setLevel(logging.DEBUG)
        # logger.setLevel(logging.ERROR)
        logger.setLevel(logging.INFO)
        if not logger.handlers:
            # Log file printing
            handlerLogFile = logging.handlers.RotatingFileHandler(
                name, maxBytes=5000000, backupCount=1000)
            formatterLogFile = logging.Formatter(
                '%(asctime)s %(levelname)s %(message)s')
            handlerLogFile.setFormatter(formatterLogFile)
            handlerLogFile.setLevel(logging.INFO)
            logger.addHandler(handlerLogFile)

            # console printing
            handlerConsole = logging.StreamHandler()
            formatterConsole = logging.Formatter('%(levelname)s %(message)s')
            handlerConsole.setFormatter(formatterConsole)
            # logger.addHandler(handlerConsole)
        self._logger = logger
        if Logger.theStaticLogger is None:
            Logger.theStaticLogger = self
        else:
            print("[ERROR]" +
                  __file__ +
                  ":" +
                  str(inspect.currentframe().f_lineno) +
                  "> Logger already exists!")

    @staticmethod
    def logDEBUG(pCurrentFileName, pMessage):
        if Logger.theStaticLogger is not None:
            if Logger.theStaticLogger._logger.level <= logging.DEBUG:
                Logger.theStaticLogger._logger.debug(
                    pCurrentFileName + ":" + str(inspect.currentframe().f_back.f_lineno) + "> " + pMessage)
        else:
            print("[ERROR]" +
                  __file__ +
                  ":" +
                  str(inspect.currentframe().f_lineno) +
                  "> Logger not created")

    @staticmethod
    def logINFO(pCurrentFileName, pMessage):
        if Logger.theStaticLogger is not None:
            if Logger.theStaticLogger._logger.level <= logging.INFO:
                Logger.theStaticLogger._logger.info(
                    pCurrentFileName + ":" + str(inspect.currentframe().f_back.f_lineno) + "> " + pMessage)
        else:
            print("[ERROR]" +
                  __file__ +
                  ":" +
                  str(inspect.currentframe().f_lineno) +
                  "> Logger not created")

    @staticmethod
    def logERROR(pCurrentFileName, pMessage):
        if Logger.theStaticLogger is not None:
            if Logger.theStaticLogger._logger.level <= logging.ERROR:
                Logger.theStaticLogger._logger.error(
                    pCurrentFileName + ":" + str(inspect.currentframe().f_back.f_lineno) + "> " + pMessage)
        else:
            print("[ERROR]" +
                  __file__ +
                  ":" +
                  str(inspect.currentframe().f_lineno) +
                  "> Logger not created")
