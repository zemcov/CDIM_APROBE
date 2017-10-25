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

Apert = 1.0 # Aperture in m
fnum  = 3.74/Apert # fnumber
R     = 500 # lambda / delta lambda spectral resolution
lmax  = 7.5 # maximum wavelength, microns
lmin  = 0.75 # minimum wavelength, microns
Area_dp = 300 # deep survey area, sq deg
Tmission = 2. # mission length, years
obs_eff = 0.8 # observation efficiency (that is, fraction of time
              # spent surveying)
pixelfac = 9.073  # the number of pixels that measure a single resolution
                  # element of width R
                  # 9.073 gets us to 7.5 pretty exactly.
nativeR = pixelfac*R # native resolution per pixel column
Pitch = 18. # detector pixel pitch, um
# angle subtended by a single detector
th_pix   = 3600.*180./np.pi*(Pitch*1.e-6)/(Apert*fnum)
pix_format = np.array([2048,2048]) # array format
fp_format = np.array([6,6]) # number and layout of detectors
t_int = 200. # integration time, s

redun_fac = 1.0 # redundancy factor of overlap between bandpasses
                # of different pointings - 1 means exactly 1 filter
                # FWHM@R moved each pointing

verbose = 1
sec_in_year = 60 * 60 * 24 * 365 # number of seconds in a year

# the width of a "constant"-R slice of a single pointing, in angle
single_pane = np.floor(th_pix * pixelfac / redun_fac)

# the height of a "constant"-R slice of a single pointing, in angle
single_height = np.floor(th_pix * pix_format[1] * fp_format[1])

# assume the survey field is square to simplify math
survey_aspect = np.sqrt(Area_dp)

# number of rows required to cover a square field
num_rows = np.ceil(survey_aspect / (single_height / 3600.))
if verbose == 1:
    print("Require "+str(num_rows)+" rows to cover deep field.")

# number of columns required to cover a square field    
num_cols = np.ceil(survey_aspect / (single_pane / 3600.))
if verbose == 1:
    print("Require "+str(num_cols)+" columns to cover deep field.")

# total number of pointings    
n_pointings = num_rows * num_cols
if verbose == 1:
    print("Require "+str(n_pointings)+" pointings to cover deep field.")

# calculate the total time, in seconds, required to cover the deep field    
total_time = n_pointings * t_int / obs_eff

print("Total survey time is {0:.3f} years per deep field.".format(total_time / sec_in_year))

