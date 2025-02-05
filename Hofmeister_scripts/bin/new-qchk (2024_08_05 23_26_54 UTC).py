#!/usr/bin/python2.7

import sys
import math
import argparse
import os
import subprocess

p=subprocess.Popen(["/cm/shared/apps/pbspro-ce/14.1.2/bin/pbsnodes","-a"],stdout=subprocess.PIPE)

pbsnodes_data_tuple=p.communicate()

pbsnodes_data_list=list(pbsnodes_data_tuple)

pbsnodes_data=pbsnodes_data_list[0] #the 0 element is the standard out

chopped=pbsnodes_data.split("\n\n") #splits the pbsnodes -a data

pbs_split_data=[] #declare empty list

for entry in chopped:
	pbs_split_data.append(entry.split("\n")) #makes a list of lists

pbs_split_data.pop() #get rid of the last blank element

for i in range(len(pbs_split_data)):
	pbs_split_data[i] = [x.strip() for x in pbs_split_data[i]]#strips the whitespace from beginning and end

vars_get=['resources_available.mem','resources_available.ncpus','resources_assigned.mem','resources_assigned.ncpus','queue']
queues_to_check=['xeon3q','xeon4q','xeon5q','xeon5parq']
semi_final_data=[] #shrink down to just the raw data of the above queues
final_data=[[],[],[],[]]#will be a list of a lists of data corresponding to 3q,4q,5q,5parq: [[node,cores,mem],...]

for i in pbs_split_data:
	if 'queue = xeon3q' in i or 'queue = xeon4q' in i or 'queue = xeon5q' in i or 'queue = xeon5parq' in i:
		semi_final_data.append(i)



for i in range(len(semi_final_data)):
	node_name=semi_final_data[i][0]
	for j in semi_final_data[i]:
		if j.startswith(vars_get[0]):
			mem_avail_raw=j[25:]
			if mem_avail_raw.endswith('mb'):
				mem_on_node=int(mem_avail_raw.replace('mb',''))*1024 #put it so it is in kb
			elif mem_avail_raw.endswith('kb'):
				mem_on_node=int(mem_avail_raw.replace('kb','')) #in kb already
		elif j.startswith(vars_get[1]):
			cores_on_node=int(j[27:])	
		elif j.startswith(vars_get[2]):
			mem_assig_raw=j[24:]
                        if mem_assig_raw.endswith('mb'):
                                mem_assig=int(mem_assig_raw.replace('mb',''))*1024 #put it so it is in kb
                        elif mem_assig_raw.endswith('kb'):
                                mem_assig=int(mem_assig_raw.replace('kb','')) #in kb already
		elif j.startswith(vars_get[3]):
			cores_assig=int(j[27:])
		elif j.startswith(vars_get[4]):
			qq=j[8:]
	cores=cores_on_node-cores_assig
	mem_mb=float(mem_on_node-mem_assig)/1024.0
	mem=int(round(float(mem_mb/1024.0)))
	if cores>0 and qq=="xeon3q":
		final_data[0].append([node_name,str(cores),str(mem)+'gb'])
	elif cores>0 and qq=="xeon4q":
		final_data[1].append([node_name,str(cores),str(mem)+'gb'])
        elif cores>0 and qq=="xeon5q":
                final_data[2].append([node_name,str(cores),str(mem)+'gb'])
        elif cores>0 and qq=="xeon5parq":
                final_data[3].append([node_name,str(cores),str(mem)+'gb'])

final_data[0].sort()
final_data[1].sort()
final_data[2].sort()
final_data[3].sort()

lengths=[len(final_data[0]),len(final_data[1]),len(final_data[2]),len(final_data[3])]
max_length=max(lengths)

#put empty lists in to pad the columns
for idx,entry in enumerate(lengths):
        if entry==max_length:
                pass
        else:
                n_app=max_length-entry
                for i in range(n_app):
                        final_data[idx].append(['','',''])

#print to STDOUT
print("---------------------------------------------------------------------------------------------")
print("\txeon3q\t\t\txeon4q\t\t\txeon5q\t\t      xeon5parq")
print("---------------------\t---------------------\t---------------------\t---------------------")
print("Node\tCores\tMem\tNode\tCores\tMem\tNode\tCores\tMem\tNode\tCores\tMem")
print("---------------------\t---------------------\t---------------------\t---------------------")
for i in range(max_length):
	print(final_data[0][i][0]+'\t'+final_data[0][i][1]+'\t'+final_data[0][i][2]+'\t'\
+final_data[1][i][0]+'\t'+final_data[1][i][1]+'\t'+final_data[1][i][2]+'\t'\
+final_data[2][i][0]+'\t'+final_data[2][i][1]+'\t'+final_data[2][i][2]+'\t'\
+final_data[3][i][0]+'\t'+final_data[3][i][1]+'\t'+final_data[3][i][2])
print("---------------------------------------------------------------------------------------------")

sys.exit()

