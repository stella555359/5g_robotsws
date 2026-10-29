class StateLogger:
    # static parameters

    # methods
    def __init__(self, pFilename):
        self.filename_ = pFilename
        self.file_ = None
        self.isEraseNeeded_ = False
        self.isOpen_ = False
        self.varName_ = ""

    def getVarName(self):
        return self.varName_

    def setVarName(self, pVarName):
        self.varName_ = pVarName

    def getFilename(self):
        return self.filename_

    def open(self):
        if self.isOpen_ is False:
            if self.isEraseNeeded_:
                self.file_ = open(self.filename_, "w+")
            else:
                self.file_ = open(self.filename_, "a")
            self.isOpen_ = True

    def close(self):
        if self.isOpen_ is True:
            self.file_.close()
            self.isOpen_ = False

    def erase(self, pIsEraseNeeded):
        self.close()
        self.isEraseNeeded_ = pIsEraseNeeded
        self.open()

    def write(self, pText, pEndOfLine="\n"):
        self.close()
        self.file_ = open(self.filename_, "a")
        self.file_.write(pText)
        self.file_.write(pEndOfLine)
        self.file_.close()
