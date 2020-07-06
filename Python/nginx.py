#!/usr/bin/env python
#-*- coding:utf-8 -*-
# Nginx 服务管理，管理员运行，可以用pyinstaller打包成exe
# 2020.07.06测试通过

import os
from tkinter import *
from tkinter.ttk import *
from time import sleep


class Application_ui(Frame):
    #这个类仅实现界面生成功能，具体事件处理代码在子类Application中。
    def __init__(self, master=None):
        Frame.__init__(self, master)
        self.master.title('Nginx服务管理')
        self.master.geometry('338x93')
        self.createWidgets()

    def createWidgets(self):
        self.top = self.winfo_toplevel()

        self.style = Style()

        self.style.configure('Command3.TButton',font=('宋体',9))
        self.Command3 = Button(self.top, text='重启', command=self.Command3_Cmd, style='Command3.TButton')
        self.Command3.place(relx=0.663, rely=0.172, relwidth=0.311, relheight=0.355)

        self.style.configure('Command2.TButton',font=('宋体',9))
        self.Command2 = Button(self.top, text='停止', command=self.Command2_Cmd, style='Command2.TButton')
        self.Command2.place(relx=0.331, rely=0.172, relwidth=0.287, relheight=0.355)

        self.style.configure('Command1.TButton',font=('宋体',9))
        self.Command1 = Button(self.top, text='启动', command=self.Command1_Cmd, style='Command1.TButton')
        self.Command1.place(relx=0.047, rely=0.172, relwidth=0.24, relheight=0.355)

        self.v = StringVar()
        self.style.configure('Label1.TLabel',anchor='w', font=('宋体',9))
        self.Label1 = Label(self.top, textvariable=self.v, style='Label1.TLabel')
        self.Label1.place(relx=0.024, rely=0.602, relwidth=0.95, relheight=0.269)


class Application(Application_ui):
    #这个类实现具体的事件处理回调函数。界面生成代码在Application_ui中。
    def __init__(self, master=None):
        Application_ui.__init__(self, master)

    def Command3_Cmd(self, event=None):
        os.popen("sc stop nginx")
        self.query()
        sleep(3)
        os.popen("sc start nginx")
        self.query()

    def Command2_Cmd(self, event=None):
        os.popen("sc stop nginx")
        self.query()

    def Command1_Cmd(self, event=None):
        os.popen("sc start nginx")
        self.query()

    def query(self):
        with os.popen('sc query nginx') as pipe:
            dd = pipe.read().split("\n")
        self.v.set(dd[3])
        self.master.after(100,self.update())
        return dd[3]

if __name__ == "__main__":
    top = Tk()
    Application(top).mainloop()
    try: top.destroy()
    except: pass
