class Physical_parameters:
    def __init__(self,t):
        self.t = t
        self.Phy =  {30:{"mu":801.5e-6,"rou":995.7,"Pr":5.42,"lamda":61.8},
                     40:{"mu":653.3e-6,"rou":992.2,"Pr":4.31,"lamda":63.5},
                     50:{"mu":549.4e-6,"rou":988.1,"Pr":3.54,"lamda":64.8},
                     60:{"mu":469.9e-6,"rou":983.1,"Pr":2.99,"lamda":65.9},
                     70:{"mu":406.1e-6,"rou":977.8,"Pr":2.55,"lamda":66.8},
                     80:{"mu":355.1e-6,"rou":971.8,"Pr":2.21,"lamda":67.4},
                     90:{"mu":314.9e-6,"rou":965.3,"Pr":1.95,"lamda":68.0},
                    100:{"mu":282.5e-6,"rou":958.4,"Pr":1.75,"lamda":68.3}
                     }
    def __t_to_any(self,cashu):
        '''温度转黏度'''
        if 30 <= self.t < 40:
            return self.Phy[30][cashu] + (self.Phy[40][cashu] - self.Phy[30][cashu]) * (self.t - 30) / 10
        elif 40<= self.t < 50:
            return self.Phy[40][cashu] + (self.Phy[50][cashu] - self.Phy[40][cashu]) * (self.t - 40) / 10
        elif 50<= self.t <60:
            return self.Phy[50][cashu] + (self.Phy[60][cashu] - self.Phy[50][cashu]) * (self.t - 50) / 10
        elif 60<= self.t <70:
            return self.Phy[60][cashu] + (self.Phy[70][cashu] - self.Phy[60][cashu]) * (self.t - 60) / 10
        elif 70<= self.t <80:
            return self.Phy[70][cashu] + (self.Phy[80][cashu] - self.Phy[70][cashu]) * (self.t - 70) / 10
        elif 80<= self.t <90:
            return self.Phy[80][cashu] + (self.Phy[90][cashu] - self.Phy[80][cashu]) * (self.t - 80) / 10
        elif 90<= self.t <=100:
            return self.Phy[90][cashu] + (self.Phy[100][cashu] - self.Phy[90][cashu]) * (self.t - 90) / 10
        else:
            return "不在计算范围内"
    def to_mu(self):
        return self.__t_to_any("mu")
    def to_rou(self):
        return self.__t_to_any("rou")
    def to_Pr(self):
        return self.__t_to_any("Pr")
    def to_lamda(self):
        return self.__t_to_any("lamda")
