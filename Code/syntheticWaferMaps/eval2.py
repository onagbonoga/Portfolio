'''This runs the testing code for all defects with a specified generator
   Usage: python3 eval2.py '''
import os 

valid_defects = {"center":125, "donut":150, "edge-loc":150, "edge-ring":175, 
        "loc":150, "near-full":150, "random":150, "scratch":125}

for defect in valid_defects:
    defect_name = defect
    epoch = valid_defects[defect]
    cmd = "python3 Agbonoga_ProjectPart2_testing.py " + defect_name + " " + str(epoch)
    os.system(cmd)