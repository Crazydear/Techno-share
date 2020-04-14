import os
import tkinter
import requests
import tkinter.messagebox
from PIL import Image, ImageTk
from shutil import copyfile


def downimg():
    global render
    cont = requests.get('http://jwxs.hebut.edu.cn/img/captcha.jpg')
    with open('temp.jpg', 'wb') as f:
        f.write(cont.content)


def changePic():
    '''flag=-1表示上一个，flag=1表示下一个'''
    pic = 'temp.jpg'     # 获取要切换的图片文件名
    im = Image.open(pic)    # 创建Image对象并进行缩放
    im1 = ImageTk.PhotoImage(im)
    lbPic['image'] = im1
    lbPic.image = im1


def btnNextClick(event): # “下一张”按钮
    global num
    num += 1
    number.set('目前已经下载验证码%d张' % num)
    filename = textStr.get()
    copyfile('temp.jpg', 'temp/%s.jpg' % filename)
    downimg()
    textStr.set('')
    changePic()

num = 0
root = tkinter.Tk()     # 创建tkinter应用程序窗口
root.geometry('330x120+380+260')      # 设置窗口大小和位置
root.resizable(False, False)    # 不允许改变窗口大小
root.title('验证码下载器')   # 设置窗口标题
btnNext = tkinter.Button(root, text='确定', command=btnNextClick)
btnNext.place(x=210, y=40, width=100, height=30)
lbPic = tkinter.Label(root, text='test', width=180, height=60)     # 用来显示图片的Label组件
changePic()
lbPic.place(x=10, y=5, width=180, height=60)
number = tkinter.StringVar()
number.set('目前已经下载验证码%d张'%num)
lable = tkinter.Label(root,textvariable=number,font=(14))
lable.place(x=0,y=80,width=200,height=30)
textStr=tkinter.StringVar()
text = tkinter.Entry(root,textvariable=textStr)
text.place(x=210,y=5,width=100,height=30)
text.bind('<Return>',btnNextClick)
root.mainloop()     # 启动消息主循环
