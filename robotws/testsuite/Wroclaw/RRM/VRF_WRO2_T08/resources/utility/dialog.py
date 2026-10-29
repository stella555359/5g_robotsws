def dialog(title, text):
    from tkinter.messagebox import showwarning
    from tkinter import Tk
    root = Tk()
    root.withdraw()
    showwarning(title, text)
    root.destroy()
