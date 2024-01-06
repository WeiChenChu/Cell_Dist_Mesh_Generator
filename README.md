[![DOI](https://zenodo.org/badge/739574986.svg)](https://zenodo.org/doi/10.5281/zenodo.10463895)

# Cell_Dist_Mesh_Generator
This repository hosts the `Cell_Dist_Mesh_Generator_V5.ijm`, a FIJI/ImageJ macro tailored for the automated generation of distance meshes between cells, aiding in quantitative visualization.

## Prerequisites
Before using this macro, ensure the following plugins are activated through the FIJI Updater:
- clij
- clij2
- clijx-assistant
- clijx-assistant-extension
- 3D ImageJ Suite (dependency of clijx-assistant-extension)
- PTBIOP (LaRoMe)
- IJPB-Plugins (MorphoLibJ)

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
8. **Distance Mesh Dilation:** Dilates the distance mesh using Morphological Filters in MorpholibJ to enhance visualization.

## Output
The macro outputs a Distance Mesh image, representing the spatial relationships between cells, which is crucial for quantitative cellular analysis.


##Reference
1. **FIJI**:
   - Schindelin, J., Arganda-Carreras, I., Frise, E., Kaynig, V., Longair, M., Pietzsch, T., ... & Cardona, A. (2012). Fiji: an open-source platform for biological-image analysis. *Nature Methods, 9*(7), 676-682. [doi:10.1038/nmeth.2019](https://doi.org/10.1038/nmeth.2019)

2. **Huang Threshold Method (ImageJ / CLIJ)**:
   - Huang, L.-K., & Wang, M.-J. J. (1995). Image thresholding by minimizing the measures of fuzziness. *Pattern Recognition, 28*(1), 41-51. [doi:10.1016/0031-3203(94)e0043-k](https://doi.org/10.1016/0031-3203(94)e0043-k)

3. **CLIJ2**:
   - Haase, R., Royer, L. A., Steinbach, P., Schmidt, D., Dibrov, A., Schmidt, U., ... & Myers, E. W. (2020). CLIJ: GPU-accelerated image processing for everyone. *Nature Methods, 17*, 5-6. [doi:10.1038/s41592-019-0650-1](https://doi.org/10.1038/s41592-019-0650-1)
   - Vorkel, D., & Haase, R. GPU-accelerating ImageJ Macro image processing workflows using CLIJ. [*arXiv preprint*.](https://arxiv.org/abs/2008.11799)
   - Haase, R., Jain, A., Rigaud, S., Vorkel, D., Rajasekhar, P., Suckert, T., ... & Myers, E. W. Interactive design of GPU-accelerated Image Data Flow Graphs and cross-platform deployment using multi-lingual code generation. [*bioRxiv preprint*.](https://www.biorxiv.org/content/10.1101/2020.11.19.386565v1)

4. **MorphoLibJ**:
   - Legland, D., Arganda-Carreras, I., & Andrey, P. (2016). MorphoLibJ: integrated library and plugins for mathematical morphology with ImageJ. *Bioinformatics, 32*(22), 3532-3534. [doi:10.1093/bioinformatics/btw413](https://doi.org/10.1093/bioinformatics/btw413)

5. **LaRoMe (LABEL Image to ROI function bundle with PTBIOP)**:
   - GitHub - BIOP/ijp-LaRoMe: Some useful functions to get Label from ROIs and vice versa, and more! https://github.com/BIOP/ijp-LaRoMe



---

For any issues, suggestions, or contributions, please open an issue or submit a pull request. Your feedback is invaluable in improving this tool.
