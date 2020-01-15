#1. Article nr 2:
#Title: Multistage expansion planning for active distribution networks under demand and Distributed Generation uncertainties
#Authors:Carmen Lucia Tancredo Borges, Vinícius Ferreira Martins
#Year: 2012
#Link: https://www.sciencedirect.com/science/article/pii/S0142061511002808

#Genetic operators:
#mutation - 1bit, mutation Rate - variable
#Crossover - twopoint. Crossover Rate - 0.7
#Selection - tournament

#Result: The solution obtained by the proposed algorithm has good quality and provides alarge   
#reduction in relation to total costs for the configuration of the planning horizon.
#For all tests the proposed GA found the solution corresponding to the global minimum


#2. Article nr 4:
#Title: Reconfiguration of distribution network for loss reduction and reliability improvement based on an enhanced genetic algorithm 
#Authors:Dong-Li Duan, Xiao-Dong Ling, Xiao-Yue Wu, BinZhong
#Year: 2015
#Link: https://www.sciencedirect.com/science/article/abs/pii/S0142061514004682

#Genetic operators:
#mutation - random insertion.
#Crossover and mutation rate - established by sort-based adaptive
#Selection - tournament

#Results: An enhanced genetic algorithm is designed to handle the reconfiguration problem. 
#The method can solve the feeder reconfiguration more effectively and stably with less iteration and fewer time.
#The effectiveness of the proposed method is demonstrated on 33-bus, 69-bus, and 136-bus radial distribution systems.



#3. Article nr 7:
#Title: A Memory-Based Genetic Algorithm for Optimization of Power Generation in a Microgrid
#Authors:Alireza Askarzadeh 
#Year: 2017
#Link: https://ieeexplore.ieee.org/document/8078257

#Genetic operators:
#Mutation-operator is applied by the probability of Pm to each gene of the offspring generation. In
#this paper, the value of the mutated gene is replaced by a random value from the possible range.
#Crossover - 
#If a and b are the parents and ab and ba are the generated offspring, the offspring are as follows:
#ab = λ1 × a + λ2 × b
#ba = λ2 × a + λ1 × b
#s.t. λ1 + λ2 = 1 (6) where λ1 and λ2 are positive constant
#Selection - roulette

#Results:Simulated results reveal that results obtained by MGA are more accurate than results found by GA, PSOw and PSOcf .
#MGA not only finds the minimal generation cost but also solvesthe scheduling problem around 2 sec.
