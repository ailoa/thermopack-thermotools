#!/usr/bin/python
#Modify system path
import sys
sys.path.insert(0,'../pycThermopack/')
# Importing pyThermopack
from thermopack.cubic import cubic
# Importing Numpy (math, arrays, etc...)
import numpy as np
# Importing Matplotlib (plotting)
import matplotlib.pyplot as plt

# Instanciate and init SRK object.
eos = cubic("C1,C2", "PR")
cindices = range(1,eos.nc+1)
Tclist = np.array([eos.critical_temperature(i) for i in cindices])
Pclist = np.array([eos.critical_pressure(i) for i in cindices])
acflist = np.array([eos.acentric_factor(i) for i in cindices])
Mwlist = np.array([eos.compmoleweight(i)*1e-3 for i in cindices]) # kg/mol

kijmat = [[eos.get_kij(i,j) for i in cindices] for j in cindices]

print (Tclist)
print (Pclist)
print (acflist)
print (Mwlist)

eos = cubic("C1,PSEUDO", "PR")
eos.init_pseudo(comps="C1,C20", Tclist=Tclist, Pclist=Pclist, acflist=acflist, Mwlist=Mwlist)
_ = [[eos.set_kij(i,j,kijmat[i-1][j-1]) for i in cindices] for j in cindices]


