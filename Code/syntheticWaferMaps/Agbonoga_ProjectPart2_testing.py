'''
This code is for testing the saved generators for cycle gan model with the provided test data
Usage: python3 Agbonoga_ProjectPart2_testing.py <defect> <epoch>
Example: python test.py donut 175 (test the donut defect generator that was saved after epoch 175 during training )
defect can be "center", "donut", "edge-loc", "edge-ring", "loc", "near-full", "random", "scratch"
epoch is the saved generator to use (defautlts to 150 if nothing is selected)
'''
import os
import torch
import torchvision.utils as vutils
import torchvision.transforms as transforms
import torchvision.datasets as dset
from torchmetrics.image.kid import KernelInceptionDistance
import matplotlib.pyplot as plt
import numpy as np
from scipy.linalg import sqrtm
from models import Generator, Discriminator
from fid import calculate_fid
import pdb 
import sys 

#valid_defects = {"Center", "Donut", "Edge-Loc", "Edge-Ring", "Loc", "Near-Full", "Random", "Scratch"}
valid_defects = {"center", "donut", "edge-loc", "edge-ring", "loc", "near-full", "random", "scratch"}
epoch = 150
try:
    defect = str(sys.argv[1]).lower()
    if defect not in valid_defects:
        print("Please enter a valid defect. Options are: ")
        print(valid_defects)
        exit()
except IndexError:
    print("Please enter a valid defect. Options are: ")
    print(valid_defects)
    exit()

if defect == "edge-loc":
    defect = "Edge-Loc"
elif defect == "edge-ring":
    defect = "Edge-Ring"
elif defect == "near-full":
    defect = "Near-full"
else:
    defect = defect.capitalize()

try:
    epoch = int(sys.argv[2])
    if not(epoch % 25 == 0 or epoch == 199):
        exit()
except IndexError:
    print("defaulting to generator after epoch 199")
except ValueError:
    print("enter a valid number")
    exit()

# choose which saved model to test
X2Y_epoch = epoch
Y2X_epoch = epoch
print(f"Testing {defect} generator after epoch {epoch}")
cwd = os.getcwd()
defect_dir = cwd + "/" + defect
ngpu = 1

# create datasets, convert to tensor and normalize
norm_value = 0.5
image_size = 128
batch_size = 5
image_dir = os.getcwd() +"/EESC6364_Project_Dataset/Project_Part_2"
X_dataset = dset.ImageFolder(root=image_dir+"/testX",
                           transform = transforms.Compose([
                               transforms.Resize(image_size),
                               transforms.CenterCrop(image_size),
                               transforms.ToTensor(),
                               transforms.Normalize((norm_value,norm_value,norm_value), (norm_value,norm_value,norm_value)),
                           ]))

X_dataloader = torch.utils.data.DataLoader(X_dataset, batch_size=batch_size,
                                         shuffle=True, num_workers=2)

Y_dataset = dset.ImageFolder(root=image_dir+"/testY/" + defect,
                           transform = transforms.Compose([
                               transforms.Resize(image_size),
                               transforms.CenterCrop(image_size),
                               transforms.ToTensor(),
                               transforms.Normalize((norm_value,norm_value,norm_value), (norm_value,norm_value,norm_value)),
                           ]))

Y_dataloader = torch.utils.data.DataLoader(Y_dataset, batch_size=batch_size,
                                         shuffle=True, num_workers=2)

device = torch.device("cuda:0" if (torch.cuda.is_available() and ngpu > 0) else "cpu")

results_folder = defect_dir + "/test_results"
if not os.path.exists(results_folder):
    os.makedirs(results_folder)

def save(img,name,iters, kid_mean, kid_std):
    # function for saving images
    npimg = img.numpy()
    name = name.replace("_"," ")
    name = name + "\nkid_mean: " + str(round(kid_mean,3))+ " kid_std: " + str(round(kid_std,3))
    plt.title(f"Test output for {name}")
    plt.imshow(np.transpose(npimg, (1, 2, 0)), interpolation='nearest')
    name = name[0:4] + "_" + str(iters) + "_" +str(epoch)
    plt.savefig(results_folder + "/" + name+".jpg")

# load models
device = torch.device("cuda:0" if (torch.cuda.is_available() and ngpu > 0) else "cpu")
generator_X2Y = Generator().to(device)

X2Y_model_name = defect_dir+'/models/GX2Y_'+str(X2Y_epoch) + ".pth"
generator_X2Y.load_state_dict(torch.load(X2Y_model_name),strict=False)
generator_X2Y.eval()

generator_Y2X = Generator().to(device)

Y2X_model_name = defect_dir +'/models/GY2X_'+str(Y2X_epoch) + ".pth"
generator_Y2X.load_state_dict(torch.load(Y2X_model_name),strict=False)
generator_Y2X.eval()

# KID 
kid = KernelInceptionDistance(subset_size = 2)
if torch.cuda.is_available():
    kid.cuda()
def calculate_kid(real_image, fake_image):
    kid.update(real_image, real=True)
    kid.update(fake_image, real=False)
    kid_mean, kid_std = kid.compute()
    return kid_mean, kid_std

iters = 0
num_iters = 10
for data_X, data_Y in zip(X_dataloader, Y_dataloader): # goes through each batch in the dataloader
    X_real_batch = data_X[0].to(device) # get real batch from domain X
    Y_real_batch = data_Y[0].to(device) # get real batch from domain Y

    # generate images and save
    with torch.no_grad():
        generated_X2Y = generator_X2Y(X_real_batch)
    with torch.no_grad():
        generated_Y2X = generator_Y2X(Y_real_batch)
    
    # calculate kid
    kid_mean_X2Y, kid_std_X2Y = calculate_kid(Y_real_batch.type(torch.uint8), generated_X2Y.type(torch.uint8))
    kid_mean_Y2X, kid_std_Y2X = calculate_kid(X_real_batch.type(torch.uint8), generated_Y2X.type(torch.uint8))
    
    generated_X2Y = generated_X2Y.detach().cpu()
    generated_Y2X = generated_Y2X.detach().cpu()
    # calculate fid
    real_x_numpy = X_real_batch.cpu().detach().numpy()
    real_y_numpy = Y_real_batch.cpu().detach().numpy()
    fake_x_numpy = generated_Y2X.cpu().detach().numpy()
    fake_y_numpy = generated_X2Y.cpu().detach().numpy()
    fid_X2Y = calculate_fid(real_y_numpy, fake_y_numpy)
    fid_Y2X = calculate_fid(real_x_numpy, fake_x_numpy)
    

    name1 = "GX2Y_iter_"+str(iters) + "_fid_ " + str(round(fid_X2Y,4))
    name2 = "GY2X_iter_"+str(iters)+ "_fid_ " + str(round(fid_Y2X,4))
    save(vutils.make_grid(generated_X2Y, 3, padding=2, normalize=True),name1,iters, kid_mean_X2Y.item(), kid_std_X2Y.item())
    save(vutils.make_grid(generated_Y2X, 3, padding=2, normalize=True),name2,iters, kid_mean_Y2X.item(), kid_std_Y2X.item())
    iters += 1
    print(f"saved {iters}")
    if iters == num_iters:
        break 
