#########################################################################
##
##  CDIM surface brightness sensitivty calculator
##  Mike Zemcov (zemcov@cfd.rit.edu)
##
##  Changelog:
##  v0, Late 2016, baseline for NASA APROBES call.
##  v1, June 2017, improved commenting for public distribution.
##
#########################################################################

#!/usr/bin/python

import sys
import numpy  as np
import pylab as pl
import matplotlib.pyplot as plt
from scipy import constants as cst

verbose = 1 # control verbosity

if verbose == 2:
    fig=plt.figure(figsize=(6.5,5))
    ax = fig.add_subplot(1,1,1)

## Physical cst
c0 = cst.value('speed of light in vacuum')*1.e6 #um/s
h0 = cst.value('Planck constant') # J.s
kb = cst.value('Boltzmann constant') # J/K
hc = c0*h0 # um.J

Apert = 1.0 # Aperture in m
fnum  = 3.74/Apert # fnumber
R     = 500 # lambda / delta lambda spectral resolution
lmax  = 7.5 # maximum wavelength, microns
lmin  = 0.75 # minumin wavelength, microns
Area_dp = 300 # deep survey area, sq deg
Tmission = 2. # mission length, years
obs_eff = 0.8 # observation efficiency (that is, fraction of time
              # spent surveying)
Pitch = 18. # detector pixel pitch, um
ZL_fac = 1.5 # multiplicative factor describing mean Zodiacal Light
             # brightness above the NEP minimum  
dQ = [10,10.5,10.5,21./np.sqrt(2)] # read noise, single sample, e-
T_samp = 1.5 # sample time, s
t_int = 200. # integration time, s
T_det = 35. # detector temperature, K
T_scope = 120. # telescope temperature, K
n_optics = 5 # number of optics in optical chain
eta_lvf = 0.80 # optical efficiency of lvf

pixelfac = 10.67  # the number of pixels that measure a single resolution
                  # element of width R
                  # 9.073 gets us to 7.5 pretty exactly.
nativeR = pixelfac*R # native resolution per pixel column 
pix_format = np.array([2048,2048]) # array format
fp_format = np.array([6,6]) # number and layout of detectors

# angle subtended by a single detector
th_pix   = 3600.*180./np.pi*(Pitch*1.e-6)/(Apert*fnum)
if verbose:
    print th_pix

# number of pixels in the entire array
fp_pix = pix_format * fp_format
if verbose:
    print fp_format[0]

# this hard codes the type of detector (H2RG_NN) in each element of the array 
fp_det_type = np.zeros(fp_pix[0])
fp_det_type[0:2048] = 1
fp_det_type[2048:3*2048] = 2
fp_det_type[3*2048:5*2048] = 3
fp_det_type[5*2048:6*2048] = 4

# set up the beginning wavelength
lam = np.zeros(fp_pix[0])
lam[0] = lmin

# loop through array asigning wavelength according to the
# pre-computed wavelength jump
for ipix in range(1,fp_pix[0]):
    lam[ipix] = lam[ipix-1] * (1. + 1./nativeR)

# read in optical efficiency of mirrors
text_file = open('lookup/eta_au.txt')
rows = [[float(x) for x in line.split(',')[:]] for line in text_file]
cols = [list(col) for col in zip(*rows)]
text_file.close

# make optical efficiency
eta_au_l = np.asarray(cols[0])
eta_au_e = np.asarray(cols[1])
eta_au = np.interp(lam,eta_au_l,eta_au_e)

# read in optical efficiency of detector
text_file = open('lookup/eta_fpa.txt')
rows = [[float(x) for x in line.split(',')[:]] for line in text_file]
cols = [list(col) for col in zip(*rows)]
text_file.close

# make detective efficiency
eta_fpa_l = np.asarray(cols[0])
eta_fpa_e = np.asarray(cols[1])
eta_fpa = np.interp(lam,eta_fpa_l,eta_fpa_e)

# efficiency assumes 
eta_opt = eta_au**n_optics
eta_lvf = eta_lvf * np.ones(fp_pix[0])
eta_tot = eta_opt * eta_fpa * eta_lvf

if verbose == 2:
    ax.semilogx(lam,eta_opt,linestyle='-',label='AU Optics, 5 reflections')
    ax.semilogx(lam,eta_lvf,linestyle='-',label='Dispersive Element')
    ax.semilogx(lam,eta_fpa,linestyle='-',label='FPA QE')
    ax.semilogx(lam,eta_tot,linestyle='-',marker='',\
                label='Total System Efficiency',linewidth=2)
    ax.set_xlabel(r'$\lambda$ ($\mu$m)')
    ax.set_ylabel(r'Optical Efficiency')
    ax.set_xlim([0.75,7.5])

    plt.legend(loc=4)
    plt.tight_layout()
    plt.savefig('cdim_sbsens_eta.pdf')

# compute entendue of a detector
AOmega     = 0.25*np.pi*(Apert**2)*(((th_pix/3600)*np.pi/180.)**2) #m^2/sr
if verbose:
    print AOmega

# generate an array of appropriate read noise
dQ_lam = np.zeros(fp_pix[0])
dQ_lam[np.where(fp_det_type == 1)] = dQ[0]
dQ_lam[np.where(fp_det_type == 2)] = dQ[1]
dQ_lam[np.where(fp_det_type == 3)] = dQ[2]
dQ_lam[np.where(fp_det_type == 4)] = dQ[3]

# convert to read noise appropriate to sample up the ramp
dQ_rin  = dQ_lam*np.sqrt(6.*T_samp/t_int)
if verbose:
    print dQ_rin

# compute the sky background assuming two black bodies consistent
# with reflected solar and thermal ZL 
sky_bkg = 6.7e3/lam**4/(np.exp(hc/(kb*5500.*lam))-1.) \
          + 5.120*1.e9/lam**4/(np.exp(hc/(kb*250.*lam))-1.) # in nW/m^2/sr
# include the "above minimum" factor
sky_bkg    *= ZL_fac
if verbose:
    print sky_bkg

# compute the bakcground from the telescope
tele_bkg = 2. * hc * c0 * 1e-12 / ((1e-6*lam)**4*(np.exp(hc/(kb*T_scope*lam)) - 1)) * (1.-eta_au) * lam * 1e-6 * 1e9
if verbose:
    print tele_bkg

# Compute the photocurrent from these contributions
i_sky  = 1.e-9*sky_bkg*AOmega*eta_tot/(R*hc/lam) # e-/s
i_tele = 1.e-9*tele_bkg*np.pi*1.8e-5**2/(R*hc/lam) # e-/s

# compute the total photocurrent
i_photo = i_sky + i_tele
if verbose:
    print i_photo

if verbose == 2:
    plt.clf()

    ax = fig.add_subplot(1,1,1)

    ax.loglog(lam,i_photo,linestyle='-',marker='',\
              label=r'Total $i_{\rm photo}$')
    ax.loglog(lam,i_sky,linestyle='-.',marker='',\
              label=r'$i_{\rm photo}$ from sky in $T_{\rm int}=200$s')
    ax.loglog(lam,i_tele,linestyle='-',marker='',\
              label=r'$i_{\rm photo}$ from telescope at T=120K')

# compute dark current - these come from empirical measurements
# taken from the literature
dc_one = 0;
dc_two = 1.8e14 * np.exp(-4280/T_det) + 1.1e9 * np.exp(-np.sqrt(57500/T_det)) + 1.2e-3
dc_three = 1.8e15 * np.exp(-2800/T_det) + 2.5e12 * np.exp(-np.sqrt(62000/T_det)) + 1.5e-3
dc_four = np.exp((T_det-42.5)/1.445) + 1.6e-1

# populate the array
DC = np.zeros(fp_pix[0])
DC[np.where(fp_det_type == 1)] = dc_one
DC[np.where(fp_det_type == 2)] = dc_two
DC[np.where(fp_det_type == 3)] = dc_three
DC[np.where(fp_det_type == 4)] = dc_four

if verbose == 2:
    ax.loglog(lam,DC,linestyle='-',marker='',label=r'$i_{\rm dark}$ at T=35 K')

# total photocurrent measured by the detector    
i_tot = i_photo + DC

if verbose == 2:
    ax.loglog(lam,i_tot,linestyle='--',marker='',label=r'$i_{\rm total}$')

    ax.set_xlabel(r'$\lambda$ ($\mu$m)')
    ax.set_ylabel(r'Current at Detector (e$^{-}$/s)')
    ax.set_xlim([0.5,7.5])
    ax.set_ylim([1e-3,5e1])

    plt.legend(loc=1,fontsize=12)
    plt.tight_layout()
    plt.savefig('cdim_sbsens_iphoto.pdf')

# rms noise on the detector per integration
dnIn_ppix = np.sqrt(i_tot*t_int+dQ_rin**2)/t_int/i_sky*sky_bkg
dnIn_ppix_rn = np.sqrt(DC*t_int+dQ_rin**2)/t_int/i_sky*sky_bkg
dnIn_ppix_sky = np.sqrt(i_photo*t_int)/t_int/i_sky*sky_bkg

if verbose == 2:
    plt.clf()

    ax = fig.add_subplot(1,1,1)

    ax.loglog(lam,dnIn_ppix_rn,linestyle='-',marker='',\
              label='Detector Components')
    ax.loglog(lam,dnIn_ppix_sky,linestyle='-',marker='',label='Photon Noise')
    ax.loglog(lam,dnIn_ppix,linestyle='-',marker='',label='Total')

    ax.set_xlabel(r'$\lambda$ ($\mu$m)')
    ax.set_ylabel(r'$\delta \nu I_{\nu}$ / pixel / 200s (nW m$^{-2}$ sr$^{-1}$, $1 \sigma$)')
    ax.set_xlim([0.75,7.5])
    ax.set_ylim([1e0,1e4])

    plt.legend(loc=3,fontsize=12)
    plt.tight_layout()
    plt.savefig('cdim_sbsens_dnIn.pdf')

if verbose == 2:
    plt.clf()

    ax = fig.add_subplot(1,1,1)

    ax.semilogx(lam,dnIn_ppix_sky/dnIn_ppix_rn,linestyle='-',marker='')
    ax.semilogx([0.5,7.5],[1,1],marker='',linestyle=':',color='black')

    ax.set_xlabel(r'$\lambda$ ($\mu$m)')
    ax.set_ylabel(r'Ratio of photon noise to detector noise')
    ax.set_xlim([0.75,7.5])
    ax.set_ylim([0,3.1])

    plt.tight_layout()
    plt.savefig('cdim_sbsens_ratio.pdf')

# compute flux uncertainty in uJy
dF = 1.e-9*1.e26*1.e6*((np.pi/180.)*(th_pix/3600.))**2*dnIn_ppix*(lam/c0) # uJy

# assume some number of sigma
Nsig   = 1
# convert to Mab
Mab = -2.5*np.log10(Nsig*1.e-6*dF/3631.)

if verbose == 2:
    plt.clf()

    ax = fig.add_subplot(1,1,1)

    ax.loglog(lam,dF,linestyle='-',marker='')
    ax.set_xlabel(r'$\lambda$ ($\mu$m)')
    ax.set_ylabel(r'$\delta F$ ($\mu$Jy, 1$\sigma$)')
    ax.set_xlim([0.5,7.5])
    ax.set_ylim([0.5,50])

    plt.tight_layout()
    plt.savefig('cdim_sbsens_dF.pdf')

if verbose == 2:
    plt.clf()

    ax = fig.add_subplot(1,1,1)

    ax.semilogx(lam,Mab,linestyle='-',marker='')
    ax.set_xlabel(r'$\lambda$ ($\mu$m)')
    ax.set_ylabel(r'$M_{\rm AB}$ (1$\sigma$)')
    ax.set_xlim([0.75,7.5])
    ax.set_ylim([20,25])

    plt.tight_layout()
    plt.savefig('cdim_sbsens_Mab.pdf')

if verbose == 2:
    plt.close()

# save the result of our labors
dout = np.zeros(lam.size,dtype=[('var1',float),('var2',float),('var3',float)])
dout['var1'] = lam
dout['var2'] = dF
dout['var3'] = Mab

np.savetxt('cdim_sbsens_out.txt',dout,fmt='%f, %f, %f')

### return
