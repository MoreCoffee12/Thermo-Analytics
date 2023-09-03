//////////////////////////////////////////////////////////////////////
// This program serves as a test harness for	
// the CFilterCDF class					
//////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////
// Written by:	Brian Howard									
// Date:		28 Dec 2001									
//////////////////////////////////////////////////////////////////////
// Significant Updates:
// V000.008    Revised to compile under Visual C++ 2008 Express Edition
//             Brian Howard, 07 Jun 2009
//////////////////////////////////////////////////////////////////////
// Significant Updates:
// V000.010    Revised to compile under Visual C++ 2010 Express Edition
//             Increased MAXSTRING from 2097152 to 4194304 to handle
//             the larger files generated by the ADRE Sxp ripper.
//             Brian Howard, 06 Nov 2011
//////////////////////////////////////////////////////////////////////
//
// Revision, 9 Sep 2023
// Upgraded to Visual  Studio 2022; corrected errors in test harness
// Brian Howard
// 
//////////////////////////////////////////////////////////////////////

#include "stdio.h"
#include <iostream>
#include "string.h"
#include "stdlib.h"
#include "filtercdf.h"

//////////////////////////////////////////////////////////////////////
// Display the .csv file data
//////////////////////////////////////////////////////////////////////
bool displaydata( CFilterCDF *filter, FILE *stream, char *filename )
{

	//local variables
	int j;
	int i;
	int colcount;
	int rowcount;
	char outputline[2048];
	double indep[4096];
	double dep[2048];
	bool jsctime;

	//initialize local variables
	j = 0;
	i = 0;
	colcount = 0;
	rowcount = 0;
	strcpy_s(outputline, "");
	for( i=0; i<4096; i++ )
		indep[i] = 0;
	for( i=0; i<2048; i++ )
		dep[i] = 0;
	jsctime = false;

	//Retrieve number of columns in file
	colcount = filter->GetCols( filename );
	//Retrieve number of rows in file
	rowcount = filter->GetRows( filename, colcount );
	//Retrieve JSC time stamp
	jsctime = filter->IsJSCTime( filename );

     //////////////////////////////////////////////////////////////////////
	// Testing of case 1 of LoadData( filename, indep, dep, recordcount)	
     //////////////////////////////////////////////////////////////////////
	if( !filter->LoadData( filename, indep, dep, 9 ) )
		return false;

	//Begin by outputting column headings
	strcpy_s( outputline, "Independent," );
	printf( outputline );
	fprintf( stream, outputline );
	for( j=1; j < ( colcount - 1 ); j++ )
	{
		printf( "Dependendent%i,", j );
		fprintf( stream, "Dependendent%i,", j );
	}
	printf( "Dependendent%i\n", ( colcount - 1 ) );
	fprintf( stream, "Dependendent%i\n", ( colcount - 1 ) );

	//and now output the first three lines
	for( i=0; i < 3; i++ )
	{
		if( jsctime )
		{
			filter->jsctime.abstime			= indep[i];
			filter->jsctime.ConvertTime2Text();
			printf( "%s,", filter->jsctime.timestring );
			fprintf( stream, "%s,", filter->jsctime.timestring );
		}
		else
		{
			printf( "%f,", indep[i] );
			fprintf( stream, "%f,", indep[i] );
		}

		//output the dependendent column(s)
		for( j=0; j< ( colcount - 2 ); j++ )
		{

			printf( "%f,", dep[j + ( i * (colcount - 1 ) )] );
			fprintf( stream, "%f,", dep[j + ( i * (colcount - 1 ) )] );

		}

		printf( "%f\n", dep[( colcount - 2 ) + ( i * (colcount - 1 ) )] );
		fprintf( stream, "%f\n", dep[( colcount - 2 ) + ( i * (colcount - 1 ) )] );

	}

     //////////////////////////////////////////////////////////////////////
	// Testing of case 2 of LoadData( filename, dep, recordcount)
     //////////////////////////////////////////////////////////////////////
	if( !filter->LoadData( filename, dep, 9 ) )
		return false;

	//Begin by outputting column headings
	strcpy_s( outputline, "Independent," );
	printf( outputline );
	fprintf( stream, outputline );
	for( j=1; j < ( colcount ); j++ )
	{
		printf( "Dependendent%i,", j );
		fprintf( stream, "Dependendent%i,", j );
	}
	printf( "Dependendent%i\n", colcount );
	fprintf( stream, "Dependendent%i\n", colcount );

	//and now output the first three lines
	for( i=0; i < 3; i++ )
	{
		printf( "%f,", (double)i );
		fprintf( stream, "%f,", (double)i );

		//output the dependendent column(s)
		for( j=0; j< ( colcount - 1 ); j++ )
		{

			printf( "%f,", dep[j + ( i * colcount )] );
			fprintf( stream, "%f,", dep[j + ( i * colcount )] );

		}

		printf( "%f\n", dep[( colcount - 1 ) + ( i * colcount )] );
		fprintf( stream, "%f\n", dep[( colcount - 1 ) + ( i * colcount )] );

	}

     //////////////////////////////////////////////////////////////////////
	// Testing of case 4 of LoadData( filename, indep, dep)
     //////////////////////////////////////////////////////////////////////
	if( !filter->LoadData( filename, indep, dep ) )
		return false;

	//Begin by outputting column headings
	strcpy_s( outputline, "Independent," );
	printf( outputline );
	fprintf( stream, outputline );
	for( j=1; j < ( colcount - 1 ); j++ )
	{
		printf( "Dependendent%i,", j );
		fprintf( stream, "Dependendent%i,", j );
	}
	printf( "Dependendent%i\n", ( colcount - 1 ) );
	fprintf( stream, "Dependendent%i\n", ( colcount - 1 ) );

	//and now output the first three lines
	for( i=0; i < 3; i++ )
	{

		if( jsctime )
		{
			filter->jsctime.abstime			= indep[i];
			filter->jsctime.ConvertTime2Text();
			printf( "%s,", filter->jsctime.timestring );
			fprintf( stream, "%s,", filter->jsctime.timestring );
		}
		else
		{
			printf( "%f,", indep[i] );
			fprintf( stream, "%f,", indep[i] );
		}

		//output the dependendent column(s)
		for( j=0; j< ( colcount - 2 ); j++ )
		{

			printf( "%f,", dep[j + ( i * (colcount - 1 ) )] );
			fprintf( stream, "%f,", dep[j + ( i * (colcount - 1 ) )] );

		}

		printf( "%f\n", dep[( colcount - 2 ) + ( i * (colcount - 1 ) )] );
		fprintf( stream, "%f\n", dep[( colcount - 2 ) + ( i * (colcount - 1 ) )] );

	}

	//success
	return true;
}

//////////////////////////////////////////////////////////////////////
// The main routine
//////////////////////////////////////////////////////////////////////
void main()
{
	
	//local variables
	int i;
	int j;
	int colcount;
	int rowcount;
     int iRowCount;
     long lRowsFound;
     long lColsFound;
	char filename01[_MAX_PATH];
	char filename02[_MAX_PATH];
	char filename03[_MAX_PATH];
	char outputline[2048];
     char szTestString[2048];
     char szRecordString[2048];
     bool bTemp;
     bool bValueMatchCol;
     bool bValueMatchRow;
     double dCSVArray[1024];
     double dCSVExpectedCol[1024];
     double dCSVExpectedRow[1024];
	FILE *stream;
	CFilterCDF *filter;
     errno_t err;
	
	//initialize variables
	i = 0;
	j = 0;
	colcount = 0;
	rowcount = 0;
	strcpy_s( filename01, "" );
	strcpy_s( filename02, "" );
	strcpy_s( filename03, "" );
	strcpy_s( outputline, "" );
	stream = NULL;
	filter = NULL;
     bValueMatchCol = true;
     bValueMatchRow = true;

     //////////////////////////////////////////////////////////////////////
	// The remainder of this program serves as a container and harness	
	// to test the object members and methods.  Tests also include		
	// exception handling										
     //////////////////////////////////////////////////////////////////////

     //////////////////////////////////////////////////////////////////////
     // Test Sequence
	//	- Verify class instantiation	
	//	- Verify member initialization
	//	- Verify method performance
     //////////////////////////////////////////////////////////////////////
	
	//Open the log file
	err = fopen_s( &stream, "CFilterCDFHarness.csv" , "w"); 
     if( err != 0)
		return;

	//Intro line
	strcpy_s( outputline, "CFilterCDF Test Harness.\n" );
	printf( outputline );
	fprintf(stream, outputline );

	//These files have unique characteristics.  The
	//file inddep.csv has lines that end with the \n character
	//and the fftsample.csv has lines that end with the ascii 13 character
	//the file Dad01.csv uses jsc time stamps
	strcpy_s( filename01, "inddep.csv" );
	strcpy_s( filename02, "fftsample.csv" );
	strcpy_s( filename03, "dad01.csv" );

	//Instantiate the class
	filter = new CFilterCDF();

	//Document instantiation of class
	strcpy_s( outputline, "CFilterCDF Instantiated.\n" );
	printf( outputline );
	fprintf( stream, outputline );

     //////////////////////////////////////////////////////////////////////
	// Begin with verification of object characteristices
     //////////////////////////////////////////////////////////////////////
     bTemp = filter->bGetMaxStringCount( &i );
	 // Revision, 9 Sep 2023
	 // The following line was changed from 4194304 to 8388607
	 if( i != 8388608)
     {
		strcpy_s( outputline, "Verification of max string count via bGetMaxStringCount failed.\n" );
		printf( outputline );
		fprintf(stream, outputline );
     	fclose( stream );

          //delete current object
	     delete filter;

          return;
     }
	fprintf(stream, "CFilterCDF characteristics verification successful.\n" );


     //////////////////////////////////////////////////////////////////////
	// Test methods for string processing
     //////////////////////////////////////////////////////////////////////
     err = strcpy_s( szTestString, "1,2" );
	strcpy_s( outputline, "+------------------------+\n" );
	strcat_s( outputline, "Testing String\n" );
	strcat_s( outputline, szTestString );
     strcat_s( outputline, "\n------------------------+\n" );
	printf( outputline );
	fprintf( stream, outputline );
     dCSVExpectedRow[0] = 1.0;
     dCSVExpectedRow[1] = 2.0;

     //load the local string into the object
     bTemp = filter->bSetStringData( szTestString );
     if( !bTemp )
     {
		strcpy_s( outputline, "bSetStringData failed for first test string. \n");
		printf( outputline );
		fprintf(stream, outputline );
     	fclose( stream );

          //delete current object
	     delete filter;

          return;
     }
     else
     {
          fprintf( stream, "bSetStringData completed successfully for first test string.\n" );
     }

     //see if we can get the column count correct
     bTemp = filter->bGetColCount( &i );
     if( !bTemp || i!= 2 )
     {
		strcpy_s( outputline, "bGetColCount failed for first test string. \n");
		printf( outputline );
		fprintf(stream, outputline );
     	fclose( stream );

          //delete current object
	     delete filter;

          return;
     }
     else
     {
          fprintf( stream, "bGetColCount completed successfully for first test string.\n" );
     }

     //see if we can get the row count correct
     bTemp = filter->bGetRowCount( &i );
     if( !bTemp || i!= 1 )
     {
		strcpy_s( outputline, "bGetRowCount failed for first test string. \n");
		printf( outputline );
		fprintf(stream, outputline );
     	fclose( stream );

          //delete current object
	     delete filter;

          return;
     }
     else
     {
          fprintf( stream, "bGetRowCount completed successfully for first test string.\n" );
     }

     //Retrieve the second column of data
     bTemp = filter->bGetColAsDoubleArray( dCSVArray, _countof( dCSVArray ), 2, &lRowsFound ); 
     if( !bTemp || dCSVArray[0] != 2.0 )
     {
		strcpy_s( outputline, "bGetColAsDoubleArray failed for first test string. \n");
		printf( outputline );
		fprintf(stream, outputline );
     	fclose( stream );

          //delete current object
	     delete filter;

          return;
     }
     else
     {
          fprintf( stream, "bGetColAsDoubleArray completed successfully for first test string.\n" );
     }

     //Retrieve the first row of data
     bTemp = filter->bGetRowAsDoubleArray( dCSVArray, _countof( dCSVArray ), 1, &lColsFound ); 
     i = 0;
     bValueMatchRow = true;
     do
     {
          if( dCSVArray[i] != dCSVExpectedRow[i] )
               bValueMatchRow = false;
          i++;
     } while ( i < lColsFound );
     
     if( !bTemp || !bValueMatchRow )
     {
		strcpy_s( outputline, "bGetRowAsDoubleArray failed for first test string. \n");
		printf( outputline );
		fprintf(stream, outputline );
     	fclose( stream );

          //delete current object
	     delete filter;

          return;
     }
     else
     {
          fprintf( stream, "bGetRowAsDoubleArray completed successfully for first test string.\n" );
     }

     //Retrieve the row 1, column 1 string
     bTemp = filter->bGetRecordAsString( 1, 1, szRecordString );
     if( !bTemp || ( strncmp( szRecordString, "1", 2 ) != 0.0 ) )
     {
		strcpy_s( outputline, "bGetRecordAsString failed for first test string. \n");
		printf( outputline );
		fprintf(stream, outputline );
     	fclose( stream );

          //delete current object
	     delete filter;

          return;
     }
     else
     {
          fprintf( stream, "bGetRecordAsString completed successfully for first test string.\n" );
     }

     err = strcpy_s( szTestString, "1,2,3\n4,5\n7,8,9\n" );
	strcpy_s( outputline, "+-----------------------+\n" );
	strcat_s( outputline, "Testing String\n" );
	strcat_s( outputline, szTestString );
     strcat_s( outputline, "\n------------------------+\n" );
	printf( outputline );
	fprintf( stream, outputline );
     dCSVExpectedCol[0] = 3.0;
     dCSVExpectedCol[1] = 9.0;
     dCSVExpectedRow[0] = 4.0;
     dCSVExpectedRow[1] = 5.0;

     //load the local string into the object
     bTemp = filter->bSetStringData( szTestString );
     if( !bTemp )
     {
		strcpy_s( outputline, "bSetStringData failed for second test string. \n");
		printf( outputline );
		fprintf(stream, outputline );
     	fclose( stream );

          //delete current object
	     delete filter;

          return;
     }
     else
     {
          fprintf( stream, "bSetStringData completed successfully for second test string.\n" );
     }

     //see if we can get the column count correct
     bTemp = filter->bGetColCount( &i );
     if( !bTemp || i!= 3 )
     {
		strcpy_s( outputline, "bGetColCount failed for second test string. \n");
		printf( outputline );
		fprintf(stream, outputline );
     	fclose( stream );

          //delete current object
	     delete filter;

          return;
     }
     else
     {
          fprintf( stream, "bGetColCount completed successfully for second test string.\n" );
     }

     //see if we can get the row count correct
     bTemp = filter->bGetRowCount( &iRowCount );
     if( !bTemp || iRowCount!= 3 )
     {
		strcpy_s( outputline, "bGetRowCount failed for second test string. \n");
		printf( outputline );
		fprintf(stream, outputline );
     	fclose( stream );

          //delete current object
	     delete filter;

          return;
     }
     else
     {
          fprintf( stream, "bGetRowCount completed successfully for second test string.\n" );
     }

     //Retrieve the third column of data check against expected values
     bTemp = filter->bGetColAsDoubleArray( dCSVArray, _countof( dCSVArray ), 3, &lRowsFound ); 
     i = 0;
     bValueMatchCol = true;
     do
     {
          if( dCSVArray[i] != dCSVExpectedCol[i] )
               bValueMatchCol = false;
          i++;
     } while ( i < lRowsFound );
     
     if( !bTemp || !bValueMatchCol )
     {
		strcpy_s( outputline, "bGetColAsDoubleArray failed for second test string. \n");
		printf( outputline );
		fprintf(stream, outputline );
     	fclose( stream );

          //delete current object
	     delete filter;

          return;
     }
     else
     {
          fprintf( stream, "bGetColAsDoubleArray completed successfully for second test string.\n" );
     }

     //Retrieve the second row of data
     bTemp = filter->bGetRowAsDoubleArray( dCSVArray, _countof( dCSVArray ), 2, &lColsFound ); 
     i = 0;
     bValueMatchRow = true;
     do
     {
          if( dCSVArray[i] != dCSVExpectedRow[i] )
               bValueMatchRow = false;
          i++;
     } while ( i < lColsFound );
     
     if( !bTemp || !bValueMatchRow )
     {
		strcpy_s( outputline, "bGetRowAsDoubleArray failed for second test string. \n");
		printf( outputline );
		fprintf(stream, outputline );
     	fclose( stream );

          //delete current object
	     delete filter;

          return;
     }
     else
     {
          fprintf( stream, "bGetRowAsDoubleArray completed successfully for second test string.\n" );
     }

     //Retrieve the row 2, column 1 string
     bTemp = filter->bGetRecordAsString( 1, 2, szRecordString );
     if( !bTemp || ( strncmp( szRecordString, "4", 2 ) != 0.0 ) )
     {
		strcpy_s( outputline, "bGetRecordAsString failed for second test string. \n");
		printf( outputline );
		fprintf(stream, outputline );
     	fclose( stream );

          //delete current object
	     delete filter;

          return;
     }
     else
     {
          fprintf( stream, "bGetRecordAsString completed successfully for second test string.\n" );
     }


     //////////////////////////////////////////////////////////////////////
	// Then test case in filename01 (the one with the \n eol char)
     //////////////////////////////////////////////////////////////////////
	//Retrieve number of columns in file
	colcount	= filter->GetCols( filename01 );
	//Retrieve number of rows in file
	rowcount	= filter->GetRows( filename01, colcount );

	//Document the source of the data
	strcpy_s( outputline, "+------------------------" );
	strcat_s( outputline, filename01 );
	strcat_s( outputline, "------------------------+\n" );
	printf( outputline );
	fprintf( stream, outputline );

	//For the case of filename01, there should be three (3) columns
	if( colcount == 3 )
     {
          printf( "CFilterCDF found %i of 3 column(s)\n", colcount );
	     fprintf( stream, "CFilterCDF found %i of 3 column(s)\n", colcount );
     }
     else
     {
		strcpy_s( outputline, "Verification of column count for " );
          strcat_s( outputline, filename01 );
          strcat_s( outputline, " failed. \n");
		printf( outputline );
		fprintf(stream, outputline );
     	fclose( stream );

          //delete current object
	     delete filter;

          return;
     }

	//and seventeen (17) rows
	printf( "CFilterCDF found %i of 17 row(s)\n", rowcount );
	fprintf( stream, "CFilterCDF found %i of 17 row(s)\n", rowcount );
	
	//This file doesn't use the JSC time format, so the method
	//should return a false
	if( filter->IsJSCTime( filename01 ))
		printf("JSC time stamp not present incorrectly identified\n");
	else
		printf("JSC time stamp not present correctly identified\n");
	
	//Document data
	if( !displaydata( filter, stream, filename01 ) )
	{
		strcpy_s( outputline, "Data output failed.\n" );
		printf( outputline );
		fprintf(stream, outputline );
		return;
	}

     //////////////////////////////////////////////////////////////////////
     // Begin with test case in filename02 (the one with the 13 eol char)
     //////////////////////////////////////////////////////////////////////
	//Retrieve number of columns in file
	colcount	= filter->GetCols( filename02 );
	//Retrieve number of rows in file
	rowcount	= filter->GetRows( filename02, colcount );

	//Document the source of the data
	strcpy_s( outputline, "+------------------------" );
	strcat_s( outputline, filename02 );
	strcat_s( outputline, "------------------------+\n" );
	printf( outputline );
	fprintf( stream, outputline );

	//For the case of filename01, there should be three (3) columns
	printf( "CFilterCDF found %i of 2 column(s)\n", colcount );
	fprintf( stream, "CFilterCDF found %i of 2 column(s)\n", colcount );

	//and seventeen (17) rows
	printf( "CFilterCDF found %i of 2048 row(s)\n", rowcount );
	fprintf( stream, "CFilterCDF found %i of 2048 row(s)\n", rowcount );
	
	//This file doesn't use the JSC time format, so the method
	//should return a false
	if( filter->IsJSCTime( filename02 ))
		printf("JSC time stamp not present incorrectly identified\n");
	else
		printf("JSC time stamp not present correctly identified\n");
	
	//Document data
	if( !displaydata( filter, stream, filename02 ) )
	{
		strcpy_s( outputline, "Data output failed.\n" );
		printf( outputline );
		fprintf_s(stream, outputline );
     	fclose( stream );

          //delete current object
	     delete filter;
          
          return;
	}

     //////////////////////////////////////////////////////////////////////
     // Cont. with test case in filename03 (the one with the jsc time)
     //////////////////////////////////////////////////////////////////////
	//Retrieve number of columns in file
	colcount	= filter->GetCols( filename03 );
	//Retrieve number of rows in file
	rowcount	= filter->GetRows( filename03, colcount );

	//Document the source of the data
	strcpy_s( outputline, "+------------------------" );
	strcat_s( outputline, filename03 );
	strcat_s( outputline, "------------------------+\n" );
	printf( outputline );
	fprintf( stream, outputline );

	//This file doesn't use the JSC time format, so the method
	//should return a false
	if( filter->IsJSCTime( filename03 ))
		printf("JSC time stamp present correctly identified\n");
	else
		printf("JSC time stamp present incorrectly identified\n");
	
	//Document data
	if( !displaydata( filter, stream, filename03 ) )
	{
		strcpy_s( outputline, "Data output failed.\n" );
		printf( outputline );
		fprintf(stream, outputline );
		return;
	}

	//delete current object
	delete filter;

	//Document successful test
	printf("Test completed successfully.\n" );
	fprintf(stream, "Test completed successfully.\n" );

     //Document destruction of object
	fprintf(stream, "CFilterCDF Destructed.\n" );

	//close the output file
	fclose( stream );

	//return all clear
	return;
}