'''This runs the testing code for a single defect (which can be modified in line 9) to generate
   an output for every epoch in the epochs list in line 7
   usage: python3 eval1.py
'''
import os 

epochs = [0,25,50,75,100,125,150,175,199]
for epoch in epochs:
    cmd = "python3 Agbonoga_ProjectPart2_testing.py " + "random " + str(epoch)
    os.system(cmd)