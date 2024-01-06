[![DOI](https://zenodo.org/badge/739574986.svg)](https://zenodo.org/doi/10.5281/zenodo.10463895)

# Cell_Dist_Mesh_Generator
This repository hosts the `Cell_Dist_Mesh_Generator_V5.ijm`, a FIJI/ImageJ macro tailored for the automated generation of distance meshes between cells, aiding in quantitative visualization.

## Prerequisites
Before using this macro, ensure the following plugins are activated through the FIJI Updater:
- CLIJ
- CLIJ2
- PTBIOP
- MorpholibJ

## Usage Instructions
1. Load the `Cell_Dist_Mesh_Generator_V5.ijm` macro in FIJI and click 'Run'.
2. Select the input image folders and specify a destination folder for the output results.
3. Use single-channel, whole-cell signal images in TIF format for input.

**Note:** It is recommended to adjust the macro parameters and `Scale_calibration_ratio` according to your specific experimental images.

## Processing Workflow
The macro initiates an automated batch image processing and exporting procedure, encompassing the following steps:

1. **Pre-processing:** Applies a Difference of Gaussian filter to reduce noise.
2. **Segmentation:** Utilizes the Huang threshold method (implemented in CLIJ2) for segmentation.
3. **Mask Refinement:** Processes the binary masks through 'fill holes', 'opening box', and 'watershed' operations, followed by connected component labeling.
4. **Label Extension:** Extends the labels using a Voronoi-like method until contact is made between them.
5. **Post-Processing:** Removes labels in contact with image edges and applies quality control filters, including size, Geodesic Elongation ratio, and Touching Neighbor counting, to minimize edge artifacts from the Voronoi-like extension.
6. **Distance Mesh Generation:** Employs the `drawDistanceMeshBetweenTouchingLabels` function from the CLIJ2 libraries to create the Distance Mesh.
7. **Scale Calibration:** Multiplies the resulting Distance Mesh image by the `Scale_calibration_ratio` to convert units from pixels to micrometers (µm).

## Output
The macro outputs a Distance Mesh image, representing the spatial relationships between cells, which is crucial for quantitative cellular analysis.

---

For any issues, suggestions, or contributions, please open an issue or submit a pull request. Your feedback is invaluable in improving this tool.
