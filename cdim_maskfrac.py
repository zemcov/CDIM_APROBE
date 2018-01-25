#########################################################################
##
##  CDIM observation time calculator
##  Mike Zemcov (zemcov@cfd.rit.edu)
##
##  Changelog:
##  v1, June 2017, first (extremely simplistic) version.
##
#########################################################################

#!/usr/bin/python

import sys
import numpy  as np
import pylab as pl
import matplotlib.pyplot as plt
from scipy import constants as cst
from scipy.optimize import curve_fit
from scipy.signal import savgol_filter
from mpl_toolkits.mplot3d import Axes3D

def func(x, a, b, c):
    return a*(x/b)**(-0.75)*np.exp(-x/b)+c

verbose = 2 # control verbosity

if verbose == 2:
    fig=plt.figure(figsize=(6.5,5))
    ax = fig.add_subplot(1,1,1)

countfiles = ["counts_U.csv","counts_B.csv","g_data_all.sorted.txt","r_data_all.sorted.txt","counts_R.csv","i_data_all.sorted.txt","counts_I.csv","z_data_all.sorted.txt","Y_data_all.sorted.txt","j_data_all.sorted.txt","counts_H.csv","counts_K.csv","counts_36.csv","counts_45.csv","counts_58.csv","counts_80.csv"]
countlambda = np.asarray([0.36,0.438,0.467,0.560,0.641,0.680,0.798,0.892,1.02,1.24,1.63,2.19,3.6,4.5,5.8,8.0])
countzero = [1790,4063,3631,3631,3064,3631,2416,3631,3631,3631,1021,640,3631,3631,3631,3631]
countmag = np.arange(5,25,0.5)
countcolors = plt.cm.rainbow(np.linspace(0, 1, len(countlambda)))

abzero = 3631

Apert = 0.83 # Aperture in m
lmax  = 7.5 # maximum wavelength, microns
lmin  = 0.75 # minimum wavelength, microns
fnum  = 4.5 # fnumber
Pitch = 18. # detector pixel pitch, um
n_width = 2.5; # number of FWHM to cut out for each masked source

rtoa = 3600.*180./np.pi # constant radians to arcsec

# angle subtended by each pixel
th_pix   = rtoa*(Pitch*1.e-6)/(Apert*fnum)

# array of wavelengths
cdim_lambda = np.arange(lmin,lmax,0.1)

# this is the diffraction limit at each wavelength in arcsec
diffraction_limit = 1.03 * (cdim_lambda * 1e-6) / Apert * rtoa

# this is how many FWHM we would cut for each source based on
# the difftraction limt 
dl_safety = n_width * diffraction_limit

# make a copy we can do things with
cut_width = dl_safety

# everywhere the pixel size is larger than the number of pixels
# we would cut, turn into the pixel size
whpl = np.where(cut_width < th_pix)

cut_width[whpl] = th_pix

# now the previous number is in width, we want in area
cut_area = np.pi * (cut_width / 2)**2

# and fix to the closest integer
cut_area_fix = np.ceil(cut_area)

for counter, lam in enumerate(cut_area):
    if cut_area[counter] <= 1:
        cut_area_fix[counter] = 3
    if cut_area[counter] > 1 and cut_area[counter] <= 4:
        cut_area_fix[counter] = 4
    if cut_area[counter] > 4 and cut_area[counter] <= 9:
        cut_area_fix[counter] = 9
    if cut_area[counter] > 9 and cut_area[counter] <= 16:
        cut_area_fix[counter] = 16
    if cut_area[counter] > 16 and cut_area[counter] <= 25:
        cut_area_fix[counter] = 25

if verbose == 2:
    ax.plot(cdim_lambda,diffraction_limit,linestyle='-',label='Diffraction Limit, FWHM')
    ax.plot(cdim_lambda,np.sqrt(diffraction_limit**2 + 0.25**2),linestyle='-',label='Diffraction + Pointing Smear')
    ax.plot(cdim_lambda,np.repeat(th_pix,np.size(cdim_lambda)),linestyle='-',label='Pixel Size')
    ax.plot(cdim_lambda,cut_width,linestyle='-',label='Cut Function')
    ax.set_xlabel(r'$\lambda$ ($\mu$m)')
    ax.set_ylabel(r'Width (arcsec)')
    ax.set_xlim([0.75,7.5])

    plt.legend(loc=2)
    plt.tight_layout()
    plt.savefig('cdim_maskfrac_width.pdf')

    #plt.show()


if verbose == 2:
    fig=plt.figure(figsize=(6.5,5))
    ax = fig.add_subplot(1,1,1)
    
#print cdim_lambda

#print cut_area_fix

#print np.size(cdim_lambda)

magsurf = np.zeros([18,len(countfiles)])
#fluxes = 15.**(np.arange(-10,-1))
xmagab = np.arange(13,31)

markmag = np.array([31,30,29,30,32,29,26,26,26,26])
#markmag = np.array([26,26,26,26,26,26,26,26,26,26])

for ifile,thisfile in enumerate(countfiles):
    my_data = np.genfromtxt("lookup/"+thisfile, delimiter=',')
    thiscountmag = my_data[:,0]
    thiscountcount = my_data[:,1]
    ymagab = -2.5*np.log10(countzero[ifile]*10**(-thiscountmag/2.5)/abzero)
    try: 
        popt, pcov = curve_fit(func,ymagab,np.log10(thiscountcount), p0=(10,10,0))
    except RuntimeError:
        print("Error - curve_fit failed")
        popt = [0,0,0]
    #interpcount = np.polyfit(ymagab,np.log10(thiscountcount),2)

    #fitcount = interpcount[0] * xmagab**2 + interpcount[1] * xmagab + interpcount[2]
    fitcount = func(xmagab, *popt)
    ax.plot(ymagab,np.log10(thiscountcount),marker='o',linestyle='',color=countcolors[ifile])
    ax.plot(xmagab,fitcount,linestyle='-',color=countcolors[ifile],label=countlambda[ifile].astype('str')+r' $\mu$m')
    plt.show(block=False)
    #print popt
    #_ = raw_input("Press [enter] to continue.")
    #interpcount = 10**(interpcount)
    #print interpcount
    #print ymagab

    #whpl = np.where(xmagab >= markmag[ifile])
    #wheq = np.where(np.abs(xmagab-markmag[ifile]) == np.min(np.abs(xmagab-markmag[ifile]))) 
    #fitcount[whpl] = fitcount[wheq]
    
    magsurf[:,ifile] = fitcount

ax.set_xlim([13,30])
ax.set_xlabel('Mag (AB)')
ax.set_ylabel('N(>M) (deg$^{-2}$)')
plt.legend(loc=4,fontsize=8)
plt.savefig('cdim_maskfrac_counts.pdf')
#plt.show()


npersd = np.interp(cdim_lambda,countlambda,magsurf[len(xmagab)-1,:])

cut_as = cut_area * 10**(npersd)
    
numberperslice = (3600./th_pix)**2 

cut_frac = savgol_filter(cut_as / numberperslice,17,1)

if verbose == 2:
    fig=plt.figure(figsize=(6.5,5))
    ax = fig.add_subplot(1,1,1)
    ax.plot(cdim_lambda,cut_frac,linestyle='-')
    ax.set_xlabel(r'$\lambda$ ($\mu$m)')
    ax.set_ylabel(r'Fraction of Pixels Lost at m$_{\rm AB}=27$')
    ax.set_xlim([0.75,7.5])

    #plt.legend(loc=2)
    #plt.tight_layout()
    #plt.show()
    plt.savefig('cdim_maskfrac_pixlost.pdf')



### return
