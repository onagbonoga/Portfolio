''' this file is called to train all cycle gan models for all defects
    Usage: python3 train_all.py'''
import os 

valid_defects = {"center", "donut", "edge-loc", "edge-ring", "loc", "near-full", "random", "scratch"}
for defect in valid_defects:
    cmd = "python3 Agbonoga_ProjectPart2_training.py " + defect 
    os.system(cmd)