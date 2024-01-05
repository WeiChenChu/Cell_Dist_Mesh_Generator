/*  Cell_Dist_Mesh_Generator 
 *  ImageJ Macro Written by Wei-Chen CHU
 *  ICOB Imaging Core, Academia Sinica, Taiwan
 *  
 *  Last update: 2024/1/6
 *  Require CLIJ series, PTBIOP and MorphilibJ.
 *  
 *  BSD 3-Clause License
 *  Copyright (c) 2024, Wei-Chen CHU
*/

//Difference Of Gaussian2D Parameters
sigma1x = 3.0;
sigma1y = 3.0;
sigma2x = 6.0;
sigma2y = 6.0;

//Mask opening parameter
number_of_erotions_and_dilations = 1.0;

//Size Filter parameters (in pixel)
Vor_min_size = 10;
Vor_max_size = 3000;

//Touching count filter parameters (to be removed)
touching_min = 1;
touching_max = 2;

//Geodesic_elongation filter parameters (to be removed)
Geodesic_elongation_min = 1.3;
Geodesic_elongation_max = 9.9;

//Here You can decide the min and max for the calibration bar (Mesh)
mesh_calibration_BAR_min = 0;
mesh_calibration_BAR_max = 120;

area_map_calibration_BAR_min = 0;
area_map_calibration_BAR_max = 1500;

//Scale bar calibrate
Scale_calibration_ratio = 3.2471; //1 pixel = how many um

//Distance_Mesh_Dilation parameter
mesh_dilation_radius = 1;


Analysis_Folder = getDirectory("Choose Directory for Analysis");
Result_Output = getDirectory("Choose Directory for the Result output");

File_List = getFileList(Analysis_Folder);
Num_Files = lengthOf(File_List);

//Functions
function roi_rearrange() {
	roi_count = roiManager("count");
	for (i = 0; i < roi_count; i++) {
		roiManager("select", i);
		roiManager("rename", "cell-" + i + 1);
	}
	roiManager("deselect");
}

function pixel_scale_calibrate(){
	Stack.setXUnit("um");
	run("Properties...", "channels=1 slices=1 frames=1 pixel_width=" + Scale_calibration_ratio + " pixel_height=" + Scale_calibration_ratio + " voxel_depth=1000.0000");
	Stack.setXUnit("um");
}

// Init GPU
run("CLIJ2 Macro Extensions", "cl_device=");

// Main workflow
for (f=0;f<Num_Files;f++){
	if (endsWith(File_List[f], ".tif")) {
		open(Analysis_Folder + File_List[f]);
		img = getTitle();
		Title_Length = lengthOf(File_List[f]);
		Main_File_Name = substring(File_List[f], 0, Title_Length-4);	
	
		Ext.CLIJ2_clear();
		run("Clear Results");
		roiManager("reset");
		
		Ext.CLIJ2_pushCurrentZStack(img);

		// Difference Of Gaussian2D
		Ext.CLIJ2_differenceOfGaussian2D(img, img_blur, sigma1x, sigma1y, sigma2x, sigma2y);
		Ext.CLIJ2_pull(img_blur);

		// Threshold Huang
		Ext.CLIJ2_thresholdHuang(img_blur, mask);
		Ext.CLIJ2_release(img_blur);

		// Binary Fill Holes
		Ext.CLIJ2_binaryFillHoles(mask, mask_filled);
		Ext.CLIJ2_release(mask);

		// Opening Box
		Ext.CLIJ2_openingBox(mask_filled, mask_filled_opening, number_of_erotions_and_dilations);
		Ext.CLIJ2_release(mask_filled);

		// Image J Watershed
		Ext.CLIJx_imageJWatershed(mask_filled_opening, mask_filled_opening_watershed);
		Ext.CLIJ2_release(mask_filled_opening);

		// Connected Components Labeling Box
		Ext.CLIJ2_connectedComponentsLabelingBox(mask_filled_opening_watershed, label);
		Ext.CLIJ2_release(mask_filled_opening_watershed);

		// Extend Labeling Via Voronoi
		Ext.CLIJ2_extendLabelingViaVoronoi(label, vor);
		Ext.CLIJ2_release(label);

		// Exclude Labels On Edges
		Ext.CLIJ2_excludeLabelsOnEdges(vor, vor_exclude_edge);
		Ext.CLIJ2_release(vor);
		Ext.CLIJ2_pull(vor_exclude_edge);
		run("glasbey_on_dark");

		//Size Filter
		Ext.CLIJ2_excludeLabelsOutsideSizeRange(vor_exclude_edge, vor_size_filtered, Vor_min_size , Vor_max_size);
		Ext.CLIJ2_release(vor_exclude_edge);
	
		//GeodesicElongationMap and filter
		Ext.CLIJx_morphoLibJGeodesicElongationMap(vor_size_filtered, Geodesic_elongation_Map);
		Ext.CLIJ2_excludeLabelsWithValuesWithinRange(Geodesic_elongation_Map, vor_size_filtered, vor_major_elongation_filtered, Geodesic_elongation_min, Geodesic_elongation_max);
		Ext.CLIJ2_pull(Geodesic_elongation_Map);
		pixel_scale_calibrate();
		run("Green Fire Blue");
		saveAs("tif", Result_Output + Main_File_Name +"_Geodesic_elongation_Map");
		Ext.CLIJ2_release(Geodesic_elongation_Map);
		
		//Touching Neighbor count filter
		Ext.CLIJ2_touchingNeighborCountMap(vor_major_elongation_filtered, toching_count_map);
		Ext.CLIJ2_pull(toching_count_map);
		Ext.CLIJ2_excludeLabelsWithValuesWithinRange(toching_count_map, vor_major_elongation_filtered, final_vor, touching_min, touching_max);
		Ext.CLIJ2_pull(toching_count_map);
		run("Green Fire Blue");
		pixel_scale_calibrate();
		saveAs("tif", Result_Output + Main_File_Name + "_neighbor_count_map");
		Ext.CLIJ2_release(toching_count_map);
		
		Ext.CLIJ2_pull(final_vor);
		run("glasbey_on_dark");
		pixel_scale_calibrate();
		saveAs("tif", Result_Output + Main_File_Name + "_label");

		//Convert Labbel to ROI
		run("Label image to ROIs");
		roi_rearrange();
		roiManager("save", Result_Output + Main_File_Name + "_roi.zip");
		
		// Draw Distance Mesh Between Touching Labels
		Ext.CLIJ2_drawDistanceMeshBetweenTouchingLabels(final_vor, distance_mesh);
		Ext.CLIJ2_pull(distance_mesh);
		run("Green Fire Blue");
		run("Multiply...", "value=" + Scale_calibration_ratio);
		setMinAndMax(mesh_calibration_BAR_min, mesh_calibration_BAR_max);
		pixel_scale_calibrate();
		run("Morphological Filters", "operation=Dilation element=Square radius=" + mesh_dilation_radius);
		saveAs("tif", Result_Output + Main_File_Name + "_Distance_mesh_um");
		run("Calibration Bar...", "location=[Separate Image] fill=White label=Black number=5 decimal=0 font=12 zoom=5 overlay");
		saveAs("tif", Result_Output + Main_File_Name + "_mesh_C_Bar_um");
		Ext.CLIJ2_release(distance_mesh);

		// Area Map
		Ext.CLIJx_morphoLibJAreaMap(final_vor, area_map);
		Ext.CLIJ2_pull(area_map);
		//run("Multiply...", "value=" + Scale_calibration_ratio);
		setMinAndMax(area_map_calibration_BAR_min, area_map_calibration_BAR_max);
		run("Green Fire Blue");
		pixel_scale_calibrate();
		saveAs("tif", Result_Output + Main_File_Name + "_Area_map_pixel");
		run("Calibration Bar...", "location=[Separate Image] fill=White label=Black number=5 decimal=0 font=12 zoom=5 overlay");
		saveAs("tif", Result_Output + Main_File_Name + "_Area_C_Bar_pixel");
		Ext.CLIJ2_release(area_map);
		
		// Reduce Labels To Voronoi Centroids
		Ext.CLIJ2_reduceLabelsToCentroids(final_vor, centroids);
		Ext.CLIJ2_pull(centroids);		
		run("glasbey_on_dark");
		pixel_scale_calibrate();
		saveAs("tif", Result_Output + Main_File_Name + "_centroids");

		// Labelled Spots To Point List
		Ext.CLIJ2_labelledSpotsToPointList(centroids, centroid_list);
		Ext.CLIJ2_release(centroids);

		// Generate Distance Matrix
		Ext.CLIJ2_generateDistanceMatrix(centroid_list, centroid_list, distance_matrix);
		Ext.CLIJ2_release(centroid_list);

		// Generate Touch Matrix
		Ext.CLIJ2_generateTouchMatrix(final_vor, touch_matrix);
		Ext.CLIJ2_release(final_vor);
		
		// Average Distance Of Touching Neighbors
		Ext.CLIJ2_averageDistanceOfTouchingNeighbors(distance_matrix, touch_matrix, ave_distance_touching_neighbors);
		Ext.CLIJ2_release(distance_matrix);
		Ext.CLIJ2_release(touch_matrix);

		Ext.CLIJ2_pullToResultsTableColumn(ave_distance_touching_neighbors, "Average_Distance", 0);
		Table.deleteRows(0, 0);
		Ext.CLIJ2_release(ave_distance_touching_neighbors);
		
		for (i = 0; i < nResults; i++) {
			distance_pixel = getResult("Average_Distance", i);
			setResult("Average_Distance_um", i, distance_pixel * Scale_calibration_ratio);
		}
		
		saveAs("results", Result_Output + Main_File_Name + "_result.csv");

		close("*");
		Ext.CLIJ2_clear();
	}
}