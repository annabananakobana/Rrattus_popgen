
version: conda 23.10.0

# add nobackup directory path to your /home/claan927/.condarc file under envs_dirs
# make sure you do this before creating the environment or you will have to supply full path at every activation
# and make sure theres an environment.txt file in /home/claan927/.conda
i.e., - D:\scale_wlg_nobackup\filesets\nobackup\uoo03627\qt_rat_sequencing\feems

# the best way to create this environment is to generate an environments.yml and do as follows.
#1: create the yaml (looks like below)

name: feems_env
channels:
  - conda-forge
  - defaults
dependencies:
  - python=3.8.3
  - geos
  - numpy==1.22.3 
  - scipy==1.5.0 
  - scikit-learn==0.23.1
  - matplotlib==3.2.2 
  - pyproj==2.6.1.post1 
  - networkx==2.4.0
  - shapely=1.7.1
  - fiona
  - pytest==5.4.3 
  - pep8==1.7.1 
  - flake8==3.8.3
  - click==7.1.2 
  - setuptools 
  - pandas-plink
  - msprime==1.0.0 
  - statsmodels==0.12.2 
  - PyYAML==5.4.1
  - xlrd==2.0.1
  - openpyxl==3.0.7
  - suitesparse=5.7.2
  - scikit-sparse=0.4.4
  - cartopy=0.18.0

#2: create the environment

conda env create --prefix /scale_wlg_nobackup/filesets/nobackup/uoo03627/qt_rat_sequencing/feems/feems_env -f environment.yml

#3: Install feems

pip install git+https://github.com/NovembreLab/feems

#4: Create a py kernal to run jupyter notebook in

conda install ipykernel
ipython kernel install --user --name=feems_env

##NOTE: CHECK python --version after every step above. Using py 3.8.* is crucial.

# the below is text I used for troubleshooting that was somewhat useless
###
# you will likely need to purge all modules
module purge

# create environment in nobackup directory
conda create --prefix feems_env python=3.8.3

# activate the envir (if the below doesnt work, troubleshoot adding full path to the .condarc file)
conda activate feems_env

# FIRST CHECK PYTHON VERSION
python --version

# either:
# install using conda install (we dont use this due to shapely issue, see below)
##conda install -c bioconda feems -c conda-forge

# OR install all the dependencies listed under Alternative installation instructions (Python 3.8)
# NOTE: there is an issue with the shapely dependency so we use the modified pip install below
# also scikit-sparse doesn't seem to get added properly with conda so use pip for that too
## BEFORE installing feems
pip install geos
pip install shapely --no-binary shapely==1.7.1
#pip install scikit-sparse --no-binary scikit-sparse==0.4.4
conda install numpy==1.22.3 scipy==1.5.0 scikit-learn==0.23.1
conda install matplotlib==3.2.2 pyproj==2.6.1.post1 networkx==2.4.0 
conda install fiona
conda install pytest==5.4.3 pep8==1.7.1 flake8==3.8.3
conda install click==7.1.2 setuptools pandas-plink
conda install msprime==1.0.0 statsmodels==0.12.2 PyYAML==5.4.1
conda install xlrd==2.0.1 
conda install openpyxl==3.0.7
conda install suitesparse=5.7.2
conda install scikit-sparse=0.4.4 
conda install cartopy=0.18.0
pip install cartopy --no-binary cartopy=0.18.0

#and then install feems
pip install git+https://github.com/NovembreLab/feems

# for jupyter notebook compatibility
conda install ipykernel
ipython kernel install --user --name=feems_env
# restart jupyter notebook
# you should see your environment in the list when you select different kernals

##TROUBLESHOOTING
#>>ImportError: cannot import name lgeos = try force reinstalling shapely
pip install shapely==1.7.1 --force-reinstall

# you may also need to force reinstall cartopy and geos, since there will likely be compatibility issues

pip install cartopy==0.18.0 --force-reinstall

#HOWEVER, these force reinstalls result in the upgrade of python to 3.11.*
# try purging this newer version and continuing
module purge Python

## once the dependencies all work for your system, its a good idea to export 
## the environment to a yaml file to save trobleshooting if you ever need to recreate the envir
# Activate the environment
conda activate my_env

# Export current environment to YAML
conda env export > environment.yml

# Update environment from updated YAML
conda env update -f environment.yml --prune

# Remove environment if needed
conda env remove -n my_env
