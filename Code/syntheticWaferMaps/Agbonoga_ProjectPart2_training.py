'''
This code is for training the cycle GAN model for generating wafer defective maps.
Usage: python3 Agbonoga_ProjectPart2_training.py <defect>
defect can be "center", "donut", "edge-loc", "edge-ring", "loc", "near-full", "random", "scratch" 
'''
from __future__ import print_function

import os
from sched import scheduler
import sys
import torch
import torch.nn as nn
import torch.nn.parallel
import torch.optim as optim
import torch.utils.data
import torchvision.datasets as dset
import torchvision.transforms as transforms
import torchvision.utils as vutils
import numpy as np
import matplotlib.pyplot as plt
import itertools
import pdb 
from models import Generator, Discriminator

valid_defects = {"center", "donut", "edge-loc", "edge-ring", "loc", "near-full", "random", "scratch"}
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

print(f"Training for {defect} defect")

# load data
cwd = os.getcwd()
image_dir = os.getcwd() +"/EESC6364_Project_Dataset/Project_Part_2"

batch_size = 5 # Batch size during training
image_size = 128
num_channels = 3 # Number of channels in the training images.
ngpu = 1 # Number of GPUs available. Use 0 for CPU mode.

# create datasets, convert to tensor and normalize
norm_value = 0.5

X_train_dataset = dset.ImageFolder(root=image_dir+"/trainX",
                           transform = transforms.Compose([
                               transforms.Resize(image_size),
                               transforms.CenterCrop(image_size),
                               transforms.ToTensor(),
                               transforms.Normalize((norm_value,norm_value,norm_value), (norm_value,norm_value,norm_value)),
                           ]))

X_train_dataloader = torch.utils.data.DataLoader(X_train_dataset, batch_size=batch_size,
                                         shuffle=True, num_workers=2)
defect_folder = "/trainY/" + defect 
Y_train_dataset = dset.ImageFolder(root=image_dir+defect_folder,
                           transform = transforms.Compose([
                               transforms.Resize(image_size),
                               transforms.CenterCrop(image_size),
                               transforms.ToTensor(),
                               transforms.Normalize((norm_value,norm_value,norm_value), (norm_value,norm_value,norm_value)),
                           ]))

Y_train_dataloader = torch.utils.data.DataLoader(Y_train_dataset, batch_size=batch_size,
                                         shuffle=True, num_workers=2)

device = torch.device("cuda:0" if (torch.cuda.is_available() and ngpu > 0) else "cpu")

# get a fixed batch of training images
fixed_X = next(iter(X_train_dataloader))[0].to(device)
fixed_Y = next(iter(Y_train_dataloader))[0].to(device)
defect_folder = cwd + "/" + defect
if not os.path.exists(defect_folder):
    os.makedirs(defect_folder)
    os.makedirs(defect_folder + "/models")

def save(img,name):
    # function for saving images
    npimg = img.numpy()
    name = name.replace("_"," ") + defect
    plt.title(f"Generator output for {name}")
    plt.imshow(np.transpose(npimg, (1, 2, 0)), interpolation='nearest')
    plt.savefig(defect_folder + "/_" + name+".jpg")

generator_X2Y = Generator().to(device)
# Handle multi-gpu
if (device.type == 'cuda') and (ngpu > 1):
    generator_X2Y= nn.DataParallel(generator_X2Y, list(range(ngpu)))

generator_Y2X = Generator().to(device)
# Handle multi-gpu
if (device.type == 'cuda') and (ngpu > 1):
    generator_Y2X= nn.DataParallel(generator_Y2X, list(range(ngpu)))

discriminator_X2Y = Discriminator().to(device)
# Handle multi-gpu
if (device.type == 'cuda') and (ngpu > 1):
    discriminator_X2Y= nn.DataParallel(discriminator_X2Y, list(range(ngpu)))

discriminator_Y2X = Discriminator().to(device)
# Handle multi-gpu
if (device.type == 'cuda') and (ngpu > 1):
    discriminator_Y2X= nn.DataParallel(discriminator_Y2X, list(range(ngpu)))

# initialize weights of networks
def weights_init(m):
    classname = m.__class__.__name__
    if hasattr(m, 'weight') and (classname.find('Conv') != -1 or classname.find('Linear') != -1):
        nn.init.normal_(m.weight.data, 0.0, 0.02)
    elif classname.find('BatchNorm2d') != -1:  # BatchNorm Layer's weight is not a matrix; only normal distribution applies.
            nn.init.normal_(m.weight.data, 1.0, 0.02)
            nn.init.constant_(m.bias.data, 0.0)

generator_X2Y.apply(weights_init)
generator_Y2X.apply(weights_init)
discriminator_X2Y.apply(weights_init)
discriminator_Y2X.apply(weights_init)

criterionGAN = nn.MSELoss()
criterionCycle = nn.L1Loss()
criterionIDT = nn.L1Loss()

learning_rate_initial = 0.0002
learning_rate = 0.0002
beta1 = 0.5 # Beta1 hyperparam for Adam optimizers
g_optimizer = optim.Adam(itertools.chain(generator_X2Y.parameters(), generator_Y2X.parameters()), lr=learning_rate, betas=(beta1, 0.999))
d_optimizer = optim.Adam(itertools.chain(discriminator_X2Y.parameters(), discriminator_Y2X.parameters()), lr=learning_rate, betas=(beta1, 0.999))

num_epochs = 200


# weights for cycle loss
lambda_X = 20
lambda_Y = 20
lambda_idt = 0.5
def set_requires_grad(nets, requires_grad=False):
        """Set requires_grad=Fasle for all the networks to avoid unnecessary computations
        Parameters:
            nets (network list)   -- a list of networks
            requires_grad (bool)  -- whether the networks require gradients or not
        """
        if not isinstance(nets, list):
            nets = [nets]
        for net in nets:
            if net is not None:
                for param in net.parameters():
                    param.requires_grad = requires_grad

val_real_label = 1.0
val_fake_label = 0.0
G_losses = []
D_losses = []
label_real = torch.tensor(val_real_label,device=device)
label_fake = torch.tensor(val_fake_label,device=device)

def calculate_GAN_G_loss(prediction,is_real):
    ''' prediction(tensor) discriminator output
        is_real(bool) true for real_label and false for fake
    '''
    if is_real:
        target = label_real.expand_as(prediction)
    else:
        target = label_fake.expand_as(prediction)
    
    loss = criterionGAN(prediction, target)
    return loss

def calculate_GAN_D_loss(netD, real, fake):
    # Real
    pred_real = netD(real)
    loss_D_real = calculate_GAN_G_loss(pred_real, True)
    # Fake
    pred_fake = netD(fake.detach())
    loss_D_fake = calculate_GAN_G_loss(pred_fake, False)
    # Combined loss and calculate gradients
    loss_D = (loss_D_real + loss_D_fake) * 0.5
    loss_D.backward()
    return loss_D

# setup scheduler
n_epochs = 100 # number of epochs with the initial learning rate
n_epochs_decay = 100 # number of epochs to start linearly decay learning rate to 0
epoch_count = 1
def lambda_rule(epoch):
    lr_l = 1.0 - max(0, epoch + epoch_count - n_epochs) / float(n_epochs_decay + 1)
    return lr_l
schedlr_g = optim.lr_scheduler.LambdaLR(g_optimizer, lr_lambda=lambda_rule)
schedlr_d = optim.lr_scheduler.LambdaLR(d_optimizer, lr_lambda=lambda_rule)
iters = 0
for epoch in range(num_epochs):
    print(f"Epoch {epoch} Iters {iters}")
    
    # iterate throught the batches in the X and Y dataloaders
    for data_X, data_Y in zip(X_train_dataloader, Y_train_dataloader): # goes through each batch in the dataloader
        # get real images
        discriminator_X2Y.zero_grad()
        discriminator_Y2X.zero_grad()
        X_real_batch = data_X[0].to(device) # get real batch from domain X
        Y_real_batch = data_Y[0].to(device) # get real batch from domain Y
        if torch.cuda.is_available():
            X_real_batch.cuda()
            Y_real_batch.cuda()
            generator_X2Y.cuda()
            generator_Y2X.cuda()
            discriminator_X2Y.cuda()
            discriminator_Y2X.cuda()
        # generator forward pass, this will also be used for testing 
        fake_Y = generator_X2Y(X_real_batch) # generate Y from X
        recon_X = generator_Y2X(fake_Y) # reconstruct X from fake Y
        fake_X = generator_Y2X(Y_real_batch) # generate X from Y
        recon_Y = generator_X2Y(fake_X) # reconstruct Y from fake X
       
        # calculate loss for generators 
        set_requires_grad([discriminator_X2Y, discriminator_Y2X], False) # avoid unecessary computations on discriminators when optimizing G's
        g_optimizer.zero_grad()

        # if a real Y or X is fed into generator X2Y or generator Y2X, we should get the same thing (identity)
        loss_idt_X = 0
        loss_idt_Y = 0
        if lambda_idt > 0:
            idt_X = generator_X2Y(Y_real_batch)
            loss_idt_X = criterionIDT(idt_X, Y_real_batch) * lambda_Y * lambda_idt
            idt_Y = generator_Y2X(X_real_batch)
            loss_idt_Y = criterionIDT(idt_Y, X_real_batch) * lambda_X * lambda_idt
        
        # GAN loss and cycle consistency loss
        X2Y_output = discriminator_X2Y(fake_Y)
        loss_G_X2Y = calculate_GAN_G_loss(X2Y_output, True)
        Y2X_output = discriminator_Y2X(fake_X)
        loss_G_Y2X = calculate_GAN_G_loss(Y2X_output, True)
        loss_cycleX = criterionCycle(recon_X, X_real_batch) * lambda_X # loss || G_Y2X(G_X2Y(X) - X ||
        loss_cycleY = criterionCycle(recon_Y, Y_real_batch) * lambda_Y # loss || G_X2Y(G_Y2X(Y) - Y ||
        loss_G = loss_G_X2Y + loss_G_Y2X + loss_cycleX + loss_cycleY + loss_idt_X + loss_idt_Y
        loss_G.backward()
        g_optimizer.step()

        # calculate loss for discriminators
        set_requires_grad([discriminator_X2Y, discriminator_Y2X], True)
        d_optimizer.zero_grad()

        loss_D_X = calculate_GAN_D_loss(discriminator_X2Y, Y_real_batch, fake_Y)

        loss_D_Y = calculate_GAN_D_loss(discriminator_Y2X, X_real_batch, fake_X)
        
        d_optimizer.step()  
        loss_D = loss_D_X.item() + loss_D_Y.item()
        
        # save losses for plotting
        G_losses.append(round(loss_G.item(),3))
        D_losses.append(round(loss_D,3))
        #print(f"Epoch {epoch} G-loss: {loss_G}, D-loss: {loss_D}") #uncomment to view losses while printing
        
        # check how the generator is doing by saving generator outputs on fixed input
        save_interval = 25
        val1 = 20
        val2 = 199
        if defect == "Near-full":
            val1 = 10
            val2 = (10 * num_epochs) - 1

        if (iters % (val1*save_interval)) == 0 or ((epoch == num_epochs-1) and (iters % val2 == 0)):
            print(f"saving")
            with torch.no_grad():
                fake_X2Y = generator_X2Y(fixed_X).cpu()
            with torch.no_grad():
                fake_Y2X = generator_Y2X(fixed_Y).cpu()
            name1 = "X2Y epoch" + str(epoch)
            name2 = "Y2X epoch" + str(epoch)
            
            # save generated images
            save(vutils.make_grid(fake_X2Y, 3, padding=2, normalize=True),name1)
            save(vutils.make_grid(fake_Y2X, 3, padding=2, normalize=True),name2)

            # save network
            name_info = str(epoch) + ".pth"
            torch.save(generator_X2Y.cpu().state_dict(), defect_folder+"/models/GX2Y_"+name_info)
            torch.save(generator_Y2X.cpu().state_dict(), defect_folder+"/models/GY2X_"+name_info)
            torch.save(discriminator_X2Y.cpu().state_dict(), defect_folder+"/models/DX2Y_"+name_info)
            torch.save(discriminator_Y2X.cpu().state_dict(), defect_folder+"/models/DY2X_"+name_info)

        iters += 1

    # update learning rates
    schedlr_g.step()
    schedlr_d.step()
    
# save G_losses ad D_losses
print(f"saving loss files for {defect} and exiting")
losses = {"G":G_losses, "D":D_losses}
losses_file_dir = defect_folder+ "/" + defect + "_losses.txt"
outputFile = open(losses_file_dir,"w")
outputFile.write(str(losses))
        