#!/usr/bin/python2.7

import sys
import math
import argparse
import os
import subprocess


xeon3q_limit=0
xeon4q_limit=0
xeon5q_limit=0
xeon5parq_limit=0
v100q_limit=0
k80q_limit=0
ajpgpuq_limit=0
#v100q_limit= #no limit but resources are different - look at later
user="kpg600"
#user="c3349605"
#user="dip757"

#run the qstat -u c3162723 command
p=subprocess.Popen(["/cm/shared/apps/pbspro-ce/19.1.3/bin/qstat","-u",user],stdout=subprocess.PIPE)

qstatu_data_tuple=p.communicate()

qstatu_data_list=list(qstatu_data_tuple)

qstatu_data=qstatu_data_list[0] #the 0 element is the standard out

chopped=qstatu_data.split("\n") #splits into this: 1497240.rcgbcm  c3162723 xeon5par 33.hgf.li+ 268868   1  16   18gb 100:0 R 00:11

del chopped[0:5] #delete the header information

chopped.pop() #remove the last entry (its blank)

qstatu_split_data=[] #declare empty list

for entry in chopped:
        qstatu_split_data.append(entry.split()) #makes a list of lists where the internal list is [####.rcgbcm, username, queue, jobname, proc_id, nodes, cores, mem, walltime, status, elapsed_time]


qstatu_final=[[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0]] #list of lists where the internal lists hold data for each queue: [#jobs_running, #cores_running, #jobs_queued]

for idx,entry in enumerate(qstatu_split_data):
	if qstatu_split_data[idx][2] == "xeon3q":
		if qstatu_split_data[idx][9] == "R":
			qstatu_final[0][0]+=1
			qstatu_final[0][1]+=int(qstatu_split_data[idx][6])
			#qstatu_final[0][1]+=int(qstatu_split_data[idx][5])*int(qstatu_split_data[idx][6])
		elif qstatu_split_data[idx][9] == "Q":
			qstatu_final[0][2]+=1
		else:
			print "job not queued or running: " + qstatu_split_data[idx][0]
	elif qstatu_split_data[idx][2] == "xeon4q":
                if qstatu_split_data[idx][9] == "R":
                        qstatu_final[1][0]+=1
			qstatu_final[1][1]+=int(qstatu_split_data[idx][6])
                        #qstatu_final[1][1]+=int(qstatu_split_data[idx][5])*int(qstatu_split_data[idx][6])
                elif qstatu_split_data[idx][9] == "Q":
                        qstatu_final[1][2]+=1
                else:
			print "job not queued or running: " + qstatu_split_data[idx][0]
        elif qstatu_split_data[idx][2] == "xeon5q":
                if qstatu_split_data[idx][9] == "R":
                        qstatu_final[2][0]+=1
			qstatu_final[2][1]+=int(qstatu_split_data[idx][6])
                        #qstatu_final[2][1]+=int(qstatu_split_data[idx][5])*int(qstatu_split_data[idx][6])
                elif qstatu_split_data[idx][9] == "Q":
                        qstatu_final[2][2]+=1
                else:
			print "job not queued or running: " + qstatu_split_data[idx][0]
        elif qstatu_split_data[idx][2] == "xeon5par":
                if qstatu_split_data[idx][9] == "R":
                        qstatu_final[3][0]+=1
			qstatu_final[3][1]+=int(qstatu_split_data[idx][6])
                        #qstatu_final[3][1]+=int(qstatu_split_data[idx][5])*int(qstatu_split_data[idx][6])
                elif qstatu_split_data[idx][9] == "Q":
                        qstatu_final[3][2]+=1
                else:
			print("job not queued or running: " + qstatu_split_data[idx][0])
        elif qstatu_split_data[idx][2] == "v100q":
                if qstatu_split_data[idx][9] == "R":
                        qstatu_final[4][0]+=1
                        qstatu_final[4][1]+=int(qstatu_split_data[idx][6])
                        #qstatu_final[3][1]+=int(qstatu_split_data[idx][5])*int(qstatu_split_data[idx][6])
                elif qstatu_split_data[idx][9] == "Q":
                        qstatu_final[4][2]+=1
                else:
                        print("job not queued or running: " + qstatu_split_data[idx][0])
        elif qstatu_split_data[idx][2] == "k80q":
                if qstatu_split_data[idx][9] == "R":
                        qstatu_final[5][0]+=1
                        qstatu_final[5][1]+=int(qstatu_split_data[idx][6])
                        #qstatu_final[3][1]+=int(qstatu_split_data[idx][5])*int(qstatu_split_data[idx][6])
                elif qstatu_split_data[idx][9] == "Q":
                        qstatu_final[5][2]+=1
                else:
                        print("job not queued or running: " + qstatu_split_data[idx][0])
        elif qstatu_split_data[idx][2] == "ajpgpuq":
                if qstatu_split_data[idx][9] == "R":
                        qstatu_final[6][0]+=1
                        qstatu_final[6][1]+=int(qstatu_split_data[idx][6])
                        #qstatu_final[3][1]+=int(qstatu_split_data[idx][5])*int(qstatu_split_data[idx][6])
                elif qstatu_split_data[idx][9] == "Q":
                        qstatu_final[6][2]+=1
                else:
                        print("job not queued or running: " + qstatu_split_data[idx][0])

p=subprocess.Popen(["/cm/shared/apps/pbspro-ce/19.1.3/bin/qstat","-Qf","xeon3q"],stdout=subprocess.PIPE)
qstatQfx3_data_tuple=p.communicate()
qstatQfx3_data_list=list(qstatQfx3_data_tuple)
qstatQfx3_data=qstatQfx3_data_list[0] #the 0 element is the standard out
qstatQfx3_split_data=qstatQfx3_data.split("\n") #splits the pbsnodes -a data
for i in range(len(qstatQfx3_split_data)):
        qstatQfx3_split_data = [x.strip() for x in qstatQfx3_split_data]#strips the whitespace from beginning and end
for line in qstatQfx3_split_data:
	if 'max_run_res.ncpus = [u:'+user in line:
		xeon3q_limit=int(line[32:-1])
	elif "max_run_res.ncpus = [u:PBS_GENERIC" in line:
		xeon3q_limit=int(line[35:-1])


p=subprocess.Popen(["/cm/shared/apps/pbspro-ce/19.1.3/bin/qstat","-Qf","xeon4q"],stdout=subprocess.PIPE)
qstatQfx4_data_tuple=p.communicate()
qstatQfx4_data_list=list(qstatQfx4_data_tuple)
qstatQfx4_data=qstatQfx4_data_list[0] #the 0 element is the standard out
qstatQfx4_split_data=qstatQfx4_data.split("\n") #splits the pbsnodes -a data
for i in range(len(qstatQfx4_split_data)):
        qstatQfx4_split_data = [x.strip() for x in qstatQfx4_split_data]#strips the whitespace from beginning and end
for line in qstatQfx4_split_data:
	if 'max_run_res.ncpus = [u:'+user in line:
		xeon4q_limit=int(line[32:-1])
	elif "max_run_res.ncpus = [u:PBS_GENERIC" in line:
		xeon4q_limit=int(line[35:-1])


p=subprocess.Popen(["/cm/shared/apps/pbspro-ce/19.1.3/bin/qstat","-Qf","xeon5q"],stdout=subprocess.PIPE)
qstatQfx5_data_tuple=p.communicate()
qstatQfx5_data_list=list(qstatQfx5_data_tuple)
qstatQfx5_data=qstatQfx5_data_list[0] #the 0 element is the standard out
qstatQfx5_split_data=qstatQfx5_data.split("\n") #splits the pbsnodes -a data
for i in range(len(qstatQfx5_split_data)):
        qstatQfx5_split_data = [x.strip() for x in qstatQfx5_split_data]#strips the whitespace from beginning and end
for line in qstatQfx5_split_data:
	if 'max_run_res.ncpus = [u:'+user in line:
		xeon5q_limit=int(line[32:-1])
	elif "max_run_res.ncpus = [u:PBS_GENERIC" in line:
		xeon5q_limit=int(line[35:-1])

p=subprocess.Popen(["/cm/shared/apps/pbspro-ce/19.1.3/bin/qstat","-Qf","xeon5parq"],stdout=subprocess.PIPE)
qstatQfx5p_data_tuple=p.communicate()
qstatQfx5p_data_list=list(qstatQfx5p_data_tuple)
qstatQfx5p_data=qstatQfx5p_data_list[0] #the 0 element is the standard out
qstatQfx5p_split_data=qstatQfx5p_data.split("\n") #splits the pbsnodes -a data
for i in range(len(qstatQfx5p_split_data)):
        qstatQfx5p_split_data = [x.strip() for x in qstatQfx5p_split_data]#strips the whitespace from beginning and end
for line in qstatQfx5p_split_data:
	if 'max_run_res.ncpus = [u:'+user in line:
		xeon5parq_limit=int(line[32:-1])
	elif "max_run_res.ncpus = [u:PBS_GENERIC" in line:
		xeon5parq_limit=int(line[35:-1])

p=subprocess.Popen(["/cm/shared/apps/pbspro-ce/19.1.3/bin/qstat","-Qf","v100q"],stdout=subprocess.PIPE)
qstatQfv100q_data_tuple=p.communicate()
qstatQfv100q_data_list=list(qstatQfv100q_data_tuple)
qstatQfv100q_data=qstatQfv100q_data_list[0] #the 0 element is the standard out
qstatQfv100q_split_data=qstatQfv100q_data.split("\n") #splits the pbsnodes -a data
for i in range(len(qstatQfv100q_split_data)):
        qstatQfv100q_split_data = [x.strip() for x in qstatQfv100q_split_data]#strips the whitespace from beginning and end
for line in qstatQfv100q_split_data:
        if 'max_run_res.ncpus = [u:'+user in line:
                v100q_limit=int(line[32:-1])
        elif "max_run_res.ncpus = [u:PBS_GENERIC" in line:
                v100q_limit=int(line[35:-1])

p=subprocess.Popen(["/cm/shared/apps/pbspro-ce/19.1.3/bin/qstat","-Qf","k80q"],stdout=subprocess.PIPE)
qstatQfk80q_data_tuple=p.communicate()
qstatQfk80q_data_list=list(qstatQfk80q_data_tuple)
qstatQfk80q_data=qstatQfk80q_data_list[0] #the 0 element is the standard out
qstatQfk80q_split_data=qstatQfk80q_data.split("\n") #splits the pbsnodes -a data
for i in range(len(qstatQfk80q_split_data)):
        qstatQfk80q_split_data = [x.strip() for x in qstatQfk80q_split_data]#strips the whitespace from beginning and end
for line in qstatQfk80q_split_data:
        if 'max_run_res.ncpus = [u:'+user in line:
                k80q_limit=int(line[32:-1])
        elif "max_run_res.ncpus = [u:PBS_GENERIC" in line:
                k80q_limit=int(line[35:-1])

p=subprocess.Popen(["/cm/shared/apps/pbspro-ce/19.1.3/bin/qstat","-Qf","ajpgpuq"],stdout=subprocess.PIPE)
qstatQfajpg_data_tuple=p.communicate()
qstatQfajpg_data_list=list(qstatQfajpg_data_tuple)
qstatQfajpg_data=qstatQfajpg_data_list[0] #the 0 element is the standard out
qstatQfajpg_split_data=qstatQfajpg_data.split("\n") #splits the pbsnodes -a data
for i in range(len(qstatQfajpg_split_data)):
        qstatQfajpg_split_data = [x.strip() for x in qstatQfajpg_split_data]#strips the whitespace from beginning and end
for line in qstatQfajpg_split_data:
        if 'max_run_res.ncpus = [u:'+user in line:
                ajpgpuq_limit=int(line[32:-1])
        elif "max_run_res.ncpus = [u:PBS_GENERIC" in line:
                ajpgpuq_limit=int(line[35:-1])






q_limits=[xeon3q_limit,xeon4q_limit,xeon5q_limit,xeon5parq_limit,v100q_limit, k80q_limit, ajpgpuq_limit]

for idx,entry in enumerate(q_limits):
	if entry==0:
		q_limits[idx]=' - '

q_names=['xeon3q', 'xeon4q', 'xeon5q', 'x5parq', 'v100q','k80q','ajpgpuq']

dash_width=37
print("-"*dash_width)
print("Queue\tQ\tR\tCores\tLimit")
print("-"*dash_width)
for i in range(7):
	print(q_names[i]+"\t"+str(qstatu_final[i][2])+"\t"+str(qstatu_final[i][0])+"\t"+str(qstatu_final[i][1])+"\t"+str(q_limits[i]))
print("-"*dash_width)


sys.exit()

