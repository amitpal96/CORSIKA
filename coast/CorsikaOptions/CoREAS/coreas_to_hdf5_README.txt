The coreas_to_hdf5.py python script converts the standard coreas output into a HDF5 based data format. In addition to ALL radio related output, also the longitudional profile (*.long) and the main shower parameters from the *.inp file are saved in the HDF5 file.
If the script is called with the optional option --highLevel, high-level radio quantities such as the energy fluence are calculated.

The usage of the skript is:

"python coreas_to_hdf5.py reas_input_file.reas"

For more information of command line arguments execute 
'python coreas_to_hdf5.py --help'

This script requieres the open source module "radiotools" which you can get from GitHub with:
git clone https://github.com/nu-radio/radiotools.git
Make sure that you source it to your enviorment, e.g., with:
export PYTHONPATH=$PYTHONPATH:/PATH/TO/RADIOTOOLS
