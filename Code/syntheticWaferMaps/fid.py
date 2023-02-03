import numpy as np
from scipy.linalg import sqrtm
from keras.applications.inception_v3 import InceptionV3
from keras.applications.inception_v3 import preprocess_input
from skimage.transform import resize

model = InceptionV3(include_top=False, pooling='avg', input_shape=(299,299,3))

# scale an array of images to a new size
def scale_images(images, new_shape):
	images_list = list()
	for image in images:
		# resize with nearest neighbor interpolation
		new_image = resize(image, new_shape, 0)
		# store
		images_list.append(new_image)
	return np.asarray(images_list)

# calculate frechet inception distance
def calculate_fid(images1, images2):
    # convert integer to floating point values
    images1 = images1.astype('float32')
    images2 = images2.astype('float32')
    # resize images
    images1 = scale_images(images1, (299,299,3))
    images2 = scale_images(images2, (299,299,3))
    # pre-process images
    images1 = preprocess_input(images1)
    images2 = preprocess_input(images2)
	# calculate activations
    act1 = model.predict(images1)
    act2 = model.predict(images2)
	# calculate mean and covariance statistics
    mu1, sigma1 = act1.mean(axis=0), np.cov(act1, rowvar=False)
    mu2, sigma2 = act2.mean(axis=0), np.cov(act2, rowvar=False)
	# calculate sum squared difference between means
    ssdiff = np.sum((mu1 - mu2)**2.0)
	# calculate sqrt of product between cov
    covmean = sqrtm(sigma1.dot(sigma2))
	# check and correct imaginary numbers from sqrt
    if np.iscomplexobj(covmean):
        covmean = covmean.real
	# calculate score
    fid = ssdiff + np.trace(sigma1 + sigma2 - 2.0 * covmean)
    return fid

