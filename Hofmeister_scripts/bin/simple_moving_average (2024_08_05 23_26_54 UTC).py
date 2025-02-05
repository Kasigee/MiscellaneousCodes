#!/cm/software/apps/python/3.7.3/bin/python
import sys
import os
import pandas as pd
import matplotlib.pyplot as plt
from scipy.signal import savgol_filter

for filename in sys.argv[1:]:
    print(filename)
    data=pd.read_csv(filename, sep="\t",  header=None)
    data.head()
    #print(data.head())
    #y_data=data.rolling(20).mean()
    y_data1=data.iloc[:,2]
    y_data2=savgol_filter(y_data1, 51, 2)
    y_data=savgol_filter(y_data2, 51, 2)
    x_data=data.iloc[:,0]
    tmp=max(y_data)
    max_x = x_data[y_data.argmax()]
    print(max_x)
    #tmp=y_data.idxmax()
    #tmp2=tmp.iloc[2]
    #tmp3=data.iloc[tmp2,0]
    #print(tmp2,tmp3)

    #y_data=data.iloc[:,2]
    #plt.scatter(x=x_data, y=y_data, label=filename, linestyle='solid', linewidths=0.5, marker=None)
    plt.plot(x_data, y_data, label=filename) 
    #plt.plot(data, color='blue',linewidth=3,figsize=(12,6))
plt.show()
exit()
