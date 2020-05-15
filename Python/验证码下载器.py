import requests
import tkinter.messagebox
import tkinter as tk
from PIL import Image, ImageTk
from shutil import copyfile
import pyautogui as pg


class DownCapcha(tk.Frame):
    def __init__(self,master=None):
        tk.Frame.__init__(self, master)
        self.num = 0
        self.master.geometry('330x120+380+260')  # 设置窗口大小和位置
        self.master.resizable(False, False)  # 不允许改变窗口大小
        self.master.title('验证码下载器')  # 设置窗口标题
        self.createWidgets()

    def downimg(self):
        cont = requests.get('http://jwxs.hebut.edu.cn/img/captcha.jpg')
        with open('temp.jpg', 'wb') as f:
            f.write(cont.content)

    def changePic(self):
        pic = 'temp.jpg'  # 获取要切换的图片文件名
        im = Image.open(pic)  # 创建Image对象并进行缩放
        im1 = ImageTk.PhotoImage(im)
        self.lbPic['image'] = im1
        self.lbPic.image = im1

    def btnNextClick(self,event=None):  # “下一张”按钮
        self.num += 1
        if self.num == 1:
            pg.press('shift')
        self.number.set('目前已经下载验证码%d张' % self.num)
        filename = self.textStr.get()
        copyfile('temp.jpg', 'temp1/{0}_{1}.jpg'.format(filename, self.num))
        self.downimg()
        self.textStr.set('')
        self.changePic()

    def createWidgets(self):
        self.btnNext = tk.Button(self.master, text='确定', command=self.btnNextClick)
        self.btnNext.place(x=210, y=40, width=100, height=30)
        self.lbPic = tk.Label(self.master, text='test', width=180, height=60)  # 用来显示图片的Label组件
        self.changePic()
        self.lbPic.place(x=10, y=5, width=180, height=60)
        self.number = tk.StringVar()
        self.number.set('目前已经下载验证码%d张' % self.num)
        self.lable = tk.Label(self.master, textvariable=self.number, font=(14))
        self.lable.place(x=0, y=80, width=200, height=30)
        self.textStr = tkinter.StringVar()
        self.text = tkinter.Entry(self.master, textvariable=self.textStr)
        self.text.place(x=210, y=5, width=100, height=30)
        self.text.bind('<Return>', self.btnNextClick)

if __name__ == '__main__':
    top = tk.Tk()
    DownCapcha(top).mainloop()
