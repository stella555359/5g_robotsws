from threading import *
import time
import traceback
# from Tkinter import END
from .Cockpit_Config import ConfigClass
from robot.api import logger

try:
    _debugFile = open(ConfigClass.traceDirectory + "/cockpit.log", "w")
except IOError:
    _hasDebugFile = False
else:
    _hasDebugFile = True

_debugSemaphore = Semaphore()


def debugWrite(par1, par2="", par3="", par4=""):
    if _hasDebugFile:
        _debugSemaphore.acquire()
        traceBackInfo = traceback.extract_stack(None, 2)
        fileName = traceBackInfo[0][0].replace(
            '\\', '/').split('/')[-1].split('.')[0]
        debugString = fileName + "/" + traceBackInfo[0][2] + " - " + str(
            par1) + " " + str(par2) + " " + str(par3) + " " + str(par4)
        _debugFile.write(
            time.strftime("%Y/%m/%d-%H:%M:%S - ") +
            debugString +
            "\n")
        logger.debug(" " + debugString)
        _debugFile.flush()
        _debugSemaphore.release()


# ----------------
class DebugClass:
    # ----------------
    def __init__(self):
        pass
#    def __init__(self, level, Errlevel, filename, console):
#        self.inFile = None
#        self.setlevel = level
#        self.setErrlevel = Errlevel
#        self.initTime = time.time()
#        self.inConsole = (console > 0)
#        self.semaphore = Semaphore()
#        self.theLogScrolledText = None
#
#        if filename > "":
#            try:
#                self.f_debug = open(filename + time.strftime("-%Y%m%d-%H%M%S.txt", time.localtime(time.time())), 'w')
#                self.inFile = 1
#            except Exception:
#                print("ERR: cannot open debug file => debug written to standard output")
#
#    def write(self, level, param):
#        if level > self.setlevel:
#            return
#        self.semaphore.acquire()
#        currTime = str(int((time.time() - self.initTime) * 1000))
#        if self.inFile:
#            string = str(param)
#            self.f_debug.write(time.strftime("%Y/%m/%d-%H:%M:%S (") + currTime + "):\t " + string + "\n")
#            if (self.inConsole) or (level < 1):
#                print(time.strftime("%Y/%m/%d-%H:%M:%S (") + currTime + "):\t " + string)
#        else:
#            print(time.strftime("%Y/%m/%d-%H:%M:%S (") + currTime + "):\t " + param)
#        self.semaphore.release()
#
#    def writeErr(self, level, param):
#        if level > self.setErrlevel:
#            return
#        self.semaphore.acquire()
#        if self.inFile:
#            string = str(param)
#            self.f_debug.write(string + "\n")
#            if (self.inConsole) or (level < 1):
#                print(string)
#        else:
#            print(param)
#        self.semaphore.release()
#
#    def end(self):
#        if self.inFile:
#            self.f_debug.close()
#
#    def setMsgLabel(self, msglabel):
#        # make link to IHM to report error
#        self.MsgLabel = msglabel
#
#    def setLogScrolledText(self, theLogScrolledText):
#        # make link to IHM to report error
#        self.theLogScrolledText = theLogScrolledText
#
#    def HandleError(self, ErrorMsg):
#        self.writeErr(0, ErrorMsg)
#        self.MsgLabel.config(text=ErrorMsg, bg="red")
#        if self.theLogScrolledText is not None:
#            self.theLogScrolledText.insert(END, ErrorMsg + "\n")
#
#    def HandleMsg(self, Msg):
#        self.write(0, Msg)
#        self.MsgLabel.config(text=Msg, bg="white")
#        if self.theLogScrolledText is not None:
#            self.theLogScrolledText.insert(END, Msg + "\n")
#
#        # mainApp.update_idletasks()
#
#    def HandleMsgColor(self, Msg, color):
#        self.write(0, Msg)
#        self.MsgLabel.config(text=Msg, bg=color)
#        if self.theLogScrolledText is not None:
#            self.theLogScrolledText.insert(END, Msg + "\n")
