import numpy as np
import pkg_resources
from sklearn.impute import SimpleImputer
from pandas_plink import read_plink
from pathlib import Path

# viz
import matplotlib.pyplot as plt
import cartopy.crs as ccrs

# feems
from feems.utils import prepare_graph_inputs
from feems import SpatialGraph, Viz

# change matplotlib fonts
plt.rcParams["font.family"] = "Arial"
plt.rcParams["font.sans-serif"] = "Arial"

# all south island samples
data_path = Path("/nesi/nobackup/uoo03627/qt_rat_sequencing/RRATTUS_ALL_SI/results/09_genotyped_GATK/plinkpca")
prefix = "allvariants_gatk_dp_m05_pca_subsample1_10k_sorted"
# Next we read the plink formatted genotype data and impute any missing SNPs with the mean at each SNP: (thiis is in their pipeline so try this first)

# read the genotype data and mean impute missing data
(bim, fam, G) = read_plink(str(data_path / prefix))
imp = SimpleImputer(missing_values=np.nan, strategy="mean")
genotypes = imp.fit_transform((np.array(G)).T)

print("n_samples={}, n_snps={}".format(genotypes.shape[0], genotypes.shape[1]))
print("Done reading genotypes")

# setup graph
feems_path = "/nesi/nobackup/uoo03627/qt_rat_sequencing/feems"

print("reading coords")
coord = np.loadtxt("{}/rats_coords_SI_nonames2.txt".format(feems_path))  # sample coordinates, no names, in order they are in the vcf
print("reading poly")
outer = np.loadtxt("{}/SI_polygon.outer".format(feems_path))  # outer coordinates
print("reading shp")
grid_path = "{}/SI_grid/NZ_triangular_grid_0.1.shp".format(feems_path)  # path to discrete global grid, WGS84

outer, edges, grid, _ = prepare_graph_inputs(coord=coord, 
                                          ggrid=grid_path,
                                          translated=False, 
                                          buffer=0,
                                          outer=outer)

print("Done preparing graph inputs")

# spatial graphs
sp_graph = SpatialGraph(genotypes, coord, grid, edges, scale_snps=True)

# projection from cartopy's coordinate reference system (ccrs) module, centered in the middle of the south island of nz near Peel Forest, -43.644076, 170.786516
projection = ccrs.EquidistantConic(central_longitude=170.786516, central_latitude=-43.644076)

# we first of all visualise the graph and sample locations. The black points are the observed locations for each sample and the grey points show the nodes theyy were assigned to. 
fig = plt.figure(dpi=300)
ax = fig.add_subplot(1, 1, 1, projection=projection)  
v = Viz(ax, sp_graph, projection=projection, edge_width=.5, 
        edge_alpha=1, edge_zorder=100, sample_pt_size=10, 
        obs_node_size=7.5, sample_pt_color="black", 
        cbar_font_size=10)
v.draw_map()
v.draw_samples()
v.draw_edges(use_weights=False)
v.draw_obs_nodes(use_ids=False)

fig.savefig('/nesi/nobackup/uoo03627/qt_rat_sequencing/feems/output_spatialplot_10k_0.1.png', dpi=300, bbox_inches='tight')