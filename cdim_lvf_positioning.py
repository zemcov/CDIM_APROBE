
#!/usr/bin/python

import sys
import numpy  as np
import pylab as pl
import matplotlib.pyplot as plt
import matplotlib.colors as clr
import matplotlib.colorbar as clbr
from matplotlib.backends.backend_pdf import PdfPages

lmin = 0.75
lmax = 7.5
R = 500
pixelfac = 10.67  # 9.073 gets us to 7.5 pretty exactly.
nativeR = pixelfac*R 

pix_format = np.array([2048,2048])

fp_format = np.array([6,6])
fp_pix = pix_format * fp_format

print fp_format[0]

thislam = np.zeros(fp_pix[0])
thislam[0] = lmin

for ipix in range(1,fp_pix[0]):
    thislam[ipix] = thislam[ipix-1] * (1. + 1./nativeR)

for ipix in range(1,fp_format[0]+1):
    print thislam[ipix * pix_format[0]-1]

lammap = np.zeros((fp_pix[0],fp_pix[1]))


for ipix in range(0,fp_pix[1]):
    lammap[ipix,:] = thislam

fig=plt.figure(figsize=(7.5,5))

ax1 = fig.add_subplot(1,1,1)
ax1.imshow(lammap,clim=[0.5,7.7],extent=[0,fp_pix[0]/3600.,0,fp_pix[1]/3600.],cmap='rainbow')

ax1.set_xlim([0,fp_pix[0]/3600.])
ax1.set_ylim([0,fp_pix[1]/3600.])

ax1.set_xlabel('Degrees')
ax1.set_ylabel('Degrees')

for ipix in range(1,fp_format[0]+1):
    ax1.plot([(ipix * pix_format[0]-1)/3600.,\
              (ipix * pix_format[0]-1)/3600.],\
              [0,fp_pix[0]/3600.],\
              color='black',linestyle='-',linewidth=2)
    ax1.plot([0,fp_pix[0]/3600.],\
             [(ipix * pix_format[0]-1)/3600.,\
              (ipix * pix_format[0]-1)/3600.],\
              color='black',linestyle='-',linewidth=2)

ax1.autoscale(False)

norm = clr.Normalize(vmin=0.75,vmax=7.5)
cx1 = fig.add_axes([0.855,0.125,0.05,0.84])
cb1 = clbr.ColorbarBase(cx1,cmap='rainbow',norm=norm,orientation='vertical',\
                        )
cb1.set_label(r'Wavelength ($\mu$m)')
cb1.set_ticks([0.75,1.1,1.6,2.4,3.5,5.1,7.5])

#plt.show()
plt.tight_layout()
plt.savefig('lvf_positioning.pdf')
plt.close()
    
