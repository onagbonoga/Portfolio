import torch.nn as nn
import torch

#define residual blocks for generator model
norm_layer = nn.InstanceNorm2d
use_bias = True
ngpu = 1

device = torch.device("cuda:0" if (torch.cuda.is_available() and ngpu > 0) else "cpu")
class ResidualBlock(nn.Module):
    def __init__(self, chan):
        super(ResidualBlock, self).__init__()
        self.dim = chan
        self.conv_block = nn.Sequential(nn.Conv2d(self.dim, self.dim, kernel_size=3, padding=1, bias=use_bias), norm_layer(self.dim))

    def forward(self, input):
        return input + self.conv_block(input)

# define the generator model
generator_depth = 32 # Size of feature maps in generator

class Generator(nn.Module):
    def __init__(self):
        super(Generator, self).__init__()
        self.main = nn.Sequential(
            # layer 1
            nn.Conv2d(in_channels = 3, out_channels = generator_depth, kernel_size = 7, stride = 1, padding = 0,bias=use_bias), norm_layer(generator_depth), nn.ReLU(True),
            # layer 2
            nn.Conv2d(generator_depth, generator_depth*2, 3, 2, 1,bias=False), norm_layer(generator_depth*2), nn.ReLU(True),
            # layer 3
            nn.Conv2d(generator_depth*2, generator_depth*4, 3, 2, 1,bias=False), norm_layer(generator_depth*4), nn.ReLU(True),
            # layer 4 - 12
            
            nn.Conv2d(generator_depth*4,generator_depth*4,3,1,1,bias=False), norm_layer(generator_depth*4),
            ResidualBlock(generator_depth*4),nn.ReLU(True),
            nn.Conv2d(generator_depth*4,generator_depth*4,3,1,1,bias=False), norm_layer(generator_depth*4),
            ResidualBlock(generator_depth*4),nn.ReLU(True),
            nn.Conv2d(generator_depth*4,generator_depth*4,3,1,1,bias=False), norm_layer(generator_depth*4),
            ResidualBlock(generator_depth*4),nn.ReLU(True),
            nn.Conv2d(generator_depth*4,generator_depth*4,3,1,1,bias=False), norm_layer(generator_depth*4),
            ResidualBlock(generator_depth*4),nn.ReLU(True), 
            nn.Conv2d(generator_depth*4,generator_depth*4,3,1,1,bias=False), norm_layer(generator_depth*4),
            ResidualBlock(generator_depth*4),nn.ReLU(True),
            nn.Conv2d(generator_depth*4,generator_depth*4,3,1,1,bias=False), norm_layer(generator_depth*4),
            ResidualBlock(generator_depth*4),nn.ReLU(True),
            nn.Conv2d(generator_depth*4,generator_depth*4,3,1,1,bias=False), norm_layer(generator_depth*4),
            ResidualBlock(generator_depth*4),nn.ReLU(True),
            nn.Conv2d(generator_depth*4,generator_depth*4,3,1,1,bias=False), norm_layer(generator_depth*4),
            ResidualBlock(generator_depth*4),nn.ReLU(True),
            nn.Conv2d(generator_depth*4,generator_depth*2,3,1,1,bias=False), norm_layer(generator_depth*2),
            ResidualBlock(generator_depth*2),nn.ReLU(True),
            # layer 13
            nn.Conv2d(generator_depth*2, generator_depth*2, 3, 2, 1,bias=False), norm_layer(generator_depth*2),
            nn.ConvTranspose2d(generator_depth*2, generator_depth, 4, 4, 0), norm_layer(generator_depth), nn.ReLU(True),
            # layer 14
            nn.Conv2d(generator_depth, generator_depth, 3, 2, 1,bias=False), norm_layer(generator_depth),
            nn.ConvTranspose2d(generator_depth, 3, 4, 4, 0), norm_layer(3), nn.ReLU(True),
            # layer 15
            nn.Conv2d(3, 3, 7, 1, padding=3),norm_layer(3),
            nn.Tanh()
        )
        
   
    def forward(self, input):
        return self.main(input)
        
discriminator_depth = 64 # Size of feature maps in discriminator

norm_layer = nn.BatchNorm2d
use_bias = False
class Discriminator(nn.Module):
    def __init__(self):
        super(Discriminator, self).__init__()
        self.main = nn.Sequential(
            
            # layer 1
            nn.utils.spectral_norm(nn.Conv2d(in_channels = 3, out_channels = 64, kernel_size = 4, stride = 2, padding = 0, bias=use_bias)),
            nn.LeakyReLU(0.2, inplace=True),

            # layer 2
            nn.utils.spectral_norm(nn.Conv2d(64, 128, 4, 2, 0, bias=use_bias)),
            nn.LeakyReLU(0.2, inplace=True),

            # layer 3
            nn.utils.spectral_norm(nn.Conv2d(128, 256, 4, 2, 0, bias=use_bias)),
            nn.LeakyReLU(0.2, inplace=True),

            # layer 4
            nn.utils.spectral_norm(nn.Conv2d(256, 512, 4, 2, 0, bias=use_bias)),
            nn.LeakyReLU(0.2, inplace=True),

            # layer 5
            nn.utils.spectral_norm(nn.Conv2d(in_channels = 512, out_channels = 1, kernel_size = 4, stride = 2, padding = 0, bias=use_bias)),
            nn.LeakyReLU(0.2, inplace=True),
            
        )

    def forward(self, input):
        # adding some gaussian noise to input
        mean = 0.5
        std = 0.5
        #input = input + torch.randn(input.size(),device=device) * std + mean
        return self.main(input)
