#!/usr/bin/perl

#------------------------------------------------------------------------------ 
# Verilog HDL Test Bench Generation Module
#	by Jeremy Webb
#	
#	Rev 1.7, April 1, 2007
#
#	This utility is intended to make instantiation in verilog easier using
#	a good editor, such as VI.
#
#	As long as you set the top line to correctly point to your perl binary,
#	and place this script in a directory in your path, you can invoke it from VI.
#	Simply use the !! command and call this script with the filename you wish
#	to instantiate.  This script will create a new text file called 
#	"new_module_name_tb.v" when you type the following command:
#	
#		!! ver_tb.pl new_module_name.v
#		
#	The script will generate the empty Verilog HDL test bench for you. 
#	Note:  "new_module_name.v" is the name of the existing Verilog HDL 
#	file and "tb_new_module_name.v" is the name of the new Verilog HDL 
#	test bench file.
#
#	The keyword "module" must be left justified in the verilog file you are 
#	instantiating to work.
#
#	Revision History:
#		1.0	11/14/2004	Initial release
#		1.1     11/22/2004      Added usage display
#               1.2     12/02/2004      Changed the username grab to use getlogin();
#               1.3     02/04/2005      Changed header.
#               1.4     06/01/2005      Changed Confidential in header.
#               1.5     04/01/2006      Updated Input, Inout, Output declaration 
#                                       in new Test Bench file. The script now
#                                       removes the input, inout, and output 
#                                       identifiers and switches a wire to a reg
#                                       and vice-versa. It also determines the 
#                                       clock signals and generates the always
#                                       block for the clocks.
#               1.6     06/30/2006      Changed copyright date to update automatically.
#               1.7     04/01/2007      Changed company header.
#
#	Please report bugs, errors, etc.
#------------------------------------------------------------------------------

# Retrieve command line argument

use strict;

my $file = $ARGV[0];

# check to see if the user entered a file name.
die "syntax: ver_tb.pl existing_file.v\n" if ($file eq "");

# Read in the target file into an array of lines
open(inF, $file) or dienice ("file open failed");
my @data = <inF>;
close(inF);

my $orig_file = $file;
# strip .v from filename
$file =~ s/\x2e.*//;

# Strip newlines
my $i;
foreach $i (@data) {
	chomp($i);
	$i =~ s/\x2f\x2f.*//;		#strip any trailing //comments
}

my $inout = -1;
foreach $i (@data) {			#strip long comments
	if ($inout==1 || $i=~m/\/\*/) {
	if ($inout == -1) {
		if ($i =~ m/\*\//) {
			$i =~ s/\/\*.*\*\///;
			$inout = -1;
		} else {
			$i =~ s/\/\*.*$//;
			$inout = 1;
		}
	} else {
		if ($i =~ m/\*\//) {
			$i =~ s/^.*\*\///;
			$inout = -1;
		} else {
			$i = " ";
			$inout = 1;
		}
	}	 
	}
}

# initialize counters
my $lines = scalar(@data);		#number of lines in file
my $line = 0;
my $modfound = -1;

my @data2 = @data;

# find 'module' left justified in file
for ($line = 0; $line < $lines; $line++) {
	if ($data[$line] =~ m/^module/) {
		$modfound = $line;
		$line = $lines;	#break out of loop
	}
}

# if we didn't find 'module' then quit
if ($modfound == -1) {
	print("Unable to instantiate-no occurance of 'module' left justified in file.\n");
	exit;
}

#find opening paren for port list
my $pfound = -1;
for ($line = $modfound; $line < $lines; $line++) { #start looking from where we found module
#	 $data[$line] =~ s/\x2f\x2f.*//;	   #strip any trailing //comment
#	 $data[$line] =~ s/\/\*.*\*\///;	   #strip embedded comments
	$data[$line] =~ s/#\s*\x28//;		   #remove 2001 param parens
	if ($data[$line] =~ m/\x28/) {		   #0x28 is '('
		$pfound = $line;
                $data[$line] =~ s/.*\x28//;	   #consume up to first paren
		$line = $lines;									#break out of loop
	}
}

# if couldn't find '(', exit
if ($pfound == -1) {
	print("Unable to instantiate-no occurance of '(' after module keyword.\n");
	exit;
}

my @inports;
my @outports;
my @ports;

#collect port names
for ($line = $pfound; $line < $lines; $line++) {
	$data[$line] =~ s/\x2f\x2f.*//;		#strip any trailing //comment
	$data[$line] =~ s/\/\*.*\*\///;		#strip embedded comments
	# the following added for 2001...
	$data[$line] =~ s/\s*(input|output|inout|parameter)\s*//;
	$data[$line] =~ s/\s*signed\s*//;
	$data[$line] =~ s/\s*(reg|wire)\s*//;
	$data[$line] =~ s/\s*\x5b.*\x5d\s*//;

	while ($data[$line] =~ m/\s*(\w[\w\d]*)/) {	#find a port name
		push (@ports, $1);			#add portname to an array
		$data[$line] =~ s/\s*\w[\w\d]*\s*,?//;	#consume the port we just recovered
	}
        if ($data[$line] =~ m/\s*\x29/) {		#watch for end paren
		$line = $lines;				#break out of loop
	}
}


###################################################################################
#Try to create the input, inout, and output signal declarations from original module

#collect port names
for ($line = $pfound; $line < $lines; $line++) {
	$data2[$line] =~ s/\x2f\x2f.*//;   #strip any trailing //comment
	$data2[$line] =~ s/\/\*.*\*\///;   #strip embedded comments
        $data2[$line] =~ s/\x2c(\x20|\t).*//;       # strip commas
        $data2[$line] =~ s/,//;

        if ($data2[$line] =~  m/\s*(input|inout).*/) {
                push @inports, $data2[$line];
        } elsif ($data2[$line] =~  m/\s*(output).*/) {
                push @outports, $data2[$line];
        }
        
        
        if ($data2[$line] =~ m/\s*\x29/) {		#watch for end paren
		$line = $lines;				#break out of loop
	}
}

foreach my $i (@inports) {
        $i =~ s/\s*(input|inout)\s*/reg\t/;  # Remove Input or Inout text.
        $i =~ s/\s*(wire)\s*/reg\t/;      # Replace each wire with a reg identifier.
}

foreach my $i (@outports) {
        $i =~ s/\s*(output)\s*/wire\t/;  # Remove Input or Inout text.
        $i =~ s/\s*(reg)\s*/wire\t/;      # Replace each wire with a reg identifier.
}

my $out2= join ";\n", @outports;
my $in2 = join ";\n", @inports;

my @tmp = @inports;
my @inportsonly; # No range or semicolons.
my $lines = scalar(@inports);		#number of lines in file
my $line = 0;

for ($line = 0; $line < $lines; $line++) {
	$tmp[$line] =~ s/\x2f\x2f.*//;		#strip any trailing //comment
	$tmp[$line] =~ s/\/\*.*\*\///;		#strip embedded comments
	# the following added for 2001...
	$tmp[$line] =~ s/\s*(reg|wire)\s*//;
	$tmp[$line] =~ s/\s*\x5b.*\x5d\s*//;

	while ($tmp[$line] =~ m/\s*(\w[\w\d]*)/) {	#find a port name
		push (@inportsonly, $1);			#add portname to an array
		$tmp[$line] =~ s/\s*\w[\w\d]*\s*,?//;	#consume the port we just recovered
	}
}

my @clks;

foreach my $i (@ports) {
  if ($i =~ m/\s*(clk|clock)/) {
          push (@clks, $i);       # Grab any clocks;
  }
}


###################################################################################

# Make Date int MM/DD/YYYY
my $year      = 0;
my $month     = 0;
my $day       = 0;
($day, $month, $year) = (localtime)[3,4,5];

# Grab username from PC:
my $author= "$^O user";
if ($^O =~ /mswin/i)
{ 
  $author= $ENV{USERNAME} if defined $ENV{USERNAME};
}
else
{ 
  $author = getlogin();
}

# check to make sure that the file doesn't exist.
my $new_file = join "_", "tb", $file;
my $new_file_v = join ".",$new_file,"v";
my $old_file_v = join ".",$file,"v";
my $new_file_results = join "_",$new_file,"results.txt";
die "Oops! A file called '$new_file_v' already exists.\n" if -e $new_file_v;
open(my $inF, ">", $new_file_v);

# Generate new test bench file:
printf($inF "/*****************************************************************\n");
printf($inF "\n");
printf($inF " $new_file_v module\n");
printf($inF "\n");
printf($inF "******************************************************************\n");
printf($inF "\n");
printf($inF " created on:\t%02d/%02d/%04d \n", $month+1, $day, $year+1900);
printf($inF " created by:	$author\n");
printf($inF " last edit on:\t%02d/%02d/%04d \n", $month+1, $day, $year+1900);
printf($inF " last edit by:	$author\n");
printf($inF " revision:	v1.0\n");
printf($inF " Copyright © %04d \n", $year+1900);
printf($inF "\n");
printf($inF "******************************************************************\n");
printf($inF "\n");
printf($inF " This module implements the test bench for the $old_file_v module.\n");
printf($inF "\n");
printf($inF "******************************************************************/\n");
printf($inF "`timescale\t1ns/1ps\n");
printf($inF "\n");
printf($inF "\n");
printf($inF "module $new_file (); \n");
printf($inF "\n");
printf($inF "// *** Input, Inouts to UUT ***\n");
printf($inF "$in2;\n");
printf($inF "\n");
printf($inF "// *** Outputs from UUT ***\n");
printf($inF "$out2;\n");

printf($inF "\n");
printf($inF "// *** Local Variable Declarations ***\n");
printf($inF "// Local Parameter Declarations:\n");
printf($inF "// N/A\n");
printf($inF "// Local Wire Declarations:\n");
printf($inF "// N/A\n");
printf($inF "// Local Register Declarations:\n");
printf($inF "// N/A\n");
printf($inF "\n");
printf($inF "// *** Local Integer Declarations ***\n");
printf($inF "integer			j,i;\n");
printf($inF "integer			results_file;\n");
printf($inF "\n");
printf($inF "// Instantiate the UUT module:\n");

printf($inF "$file\tuut\t(");	#print first line
my $lastport = $ports[scalar(@ports)-1];
foreach $i (@ports) {
	printf($inF "\n\t\t\t.$i ($i)");	#print the ports
	if ($i ne $lastport) {	#print commas on all but last port
		printf($inF ",");
	}
}

printf($inF "\n\t\t\t);\n\n");
printf($inF "// Generate clock:\n");
foreach my $i (@clks) {
        printf($inF "always #10 $i = ~$i;\n\n");
}

printf($inF "// initial block\n");
printf($inF "initial\n");
printf($inF "begin\n");
printf($inF "\t// initialize signals");
foreach $i (@inportsonly) {
	printf($inF "\n\t$i = 0;");	#print the ports
}
printf($inF "\n");
printf($inF "\n");
printf($inF "\t// open results file, write header\n");
printf($inF "\tresults_file=\$fopen(\"$new_file_results\");\n");
printf($inF "\t\$fdisplay(results_file, \" $new_file testbench results\");\n");
printf($inF "\t\$fdisplay(results_file);\n");
printf($inF "\t\$fwrite(results_file, \"\\n\");\n");
printf($inF "\t\$fdisplay(results_file, \"\\t%s\\t\\t%s\", \"address\", \"data\");\n");
printf($inF "\t//\$fdisplay(results_file, \"\\t%h\\t\\t%h\", addr_for, data_out);\n");
printf($inF "\t\n");
printf($inF "\t// Add more test bench stuff here\n");
printf($inF "\t\n");
printf($inF "\t\n");
printf($inF "\t\n");
printf($inF "\t\$fclose(results_file);\n");
printf($inF "\t\$stop;\n");
printf($inF "end\n");
printf($inF "\n");
printf($inF "\n");
printf($inF "// Add more test bench stuff here as well\n");
printf($inF "\n");
printf($inF "\n");

#printf($inF "// Test Bench Tasks\n");
#printf($inF "\n");
#printf($inF "task CpuReset;\n");
#printf($inF "begin\n");
#printf($inF "\t@ (posedge clk);\n");
#printf($inF "\trst_n = 0;\n");
#printf($inF "\t@ (posedge clk);\n");
#printf($inF "\trst_n = 1;\n");
#printf($inF "\t@ (posedge clk);\n");
#printf($inF "end\n");
#printf($inF "endtask\n");

printf($inF "// Dump FSDB wave\n");
printf($inF "initial\n");
printf($inF "begin\n");
printf($inF "\t\$fsdbDumpfile(\"ic_design.fsdb\");\n");
printf($inF "\t\$fsdbDumpvars;\n");
printf($inF "end\n");
printf($inF "\n");
printf($inF "\n");
printf($inF "endmodule\n");
close(inF); 

print("\n");
print("The script has finished successfully! You can now use $new_file_v.");
print("\n");
print("\n");

exit;

#------------------------------------------------------------------------------ 
# Generic Error and Exit routine 
#------------------------------------------------------------------------------
sub dienice {
	my($errmsg) = @_;
	print"$errmsg\n";
	exit;
}

