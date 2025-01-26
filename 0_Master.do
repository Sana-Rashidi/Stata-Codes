
	
	/*--------------------------------------------------------------------------------
						Master file for "STICERD Empirical Task"
						
						
			 ----> READ ATTACHED INSTRUCTION FILE BEFORE EXECUTING CODES <--
						
						0_Master
							|
							|______ 1_Clean.do
							|
							|______ 2_Main_Results.do
							|
							|______ 3_Tests.do
		
						
						Folder
							|
							|______ Data
							|
							|______ Do_File

						Authors: Sana Rashidi
						Date :  17 April 2024
						
	--------------------------------------------------------------------------------*/

	// write your directory between double quotation
	gl Project_Folder 		""

	/*--------------------------------------------------------------------------------
							Prepare folder paths
	--------------------------------------------------------------------------------*/
	// Data sets
	global Data				"${Project_Folder}/Data"
	
	// Outputs
	gl Output_Graph			"${Project_Folder}/Output/Graph"
	gl Output_Table  		"${Project_Folder}/Output/Table"

	// Do files
	gl Do_File				"${Project_Folder}/Do_file"
	
	
	// Run this part for the first time to build the needed directories
	// Directories
	mkdir "${Project_Folder}/Output"
	mkdir "${Project_Folder}/Output/Graph"
	mkdir "${Project_Folder}/Output/Table"
	
	
	/*--------------------------------------------------------------------------------
							Used Packages
	--------------------------------------------------------------------------------*/
	
	ssc install rdrobust
	ssc install rdmse
	ssc install cleanplots
	
	
	
	/*--------------------------------------------------------------------------------
							  Run Codes
	--------------------------------------------------------------------------------*/
	
	//------------------- Part 1: Data Cleaning and Preperation ---------------------
	do "${Do_File}/1_Clean.do"
	
	//------------------- Part 2: Deplication of Main Results -----------------------
	do "${Do_File}/2_Main_Results.do"
	
	//------------------- Part 3: Further Tests for Regression Discontinuity --------
	do "${Do_File}/3_Tests.do"
