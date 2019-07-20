#! /usr/bin/perl 

use strict;

open(my $dir, "> $ARGV[0]");

# Generate new test bench file:
printf($dir "//-----------------------------------------------------------------\n");
printf($dir "//\n");
printf($dir "// Project\t\t\t\t: \n");
printf($dir "// Module\t\t\t\t\t: $ARGV[0]\n");
printf($dir "// Description\t\t: \n");
printf($dir "// Designer\t\t\t\t: \n");
printf($dir "// Version\t\t\t\t: \n");
printf($dir "//\n");
printf($dir "//-----------------------------------------------------------------\n");
printf($dir "\nmodule \n");
printf($dir "\n");

printf($dir "//**************************************************\n");
printf($dir "//\n");
printf($dir "// Defination\n");
printf($dir "//\n");
printf($dir "//**************************************************\n");
printf($dir "\n");
printf($dir "\n");
printf($dir "\n");

printf($dir "//**************************************************\n");
printf($dir "//\n");
printf($dir "// always\n");
printf($dir "//\n");
printf($dir "//**************************************************\n");
printf($dir "\n");
printf($dir "\n");
printf($dir "\n");

printf($dir "endmodule\n");
printf($dir "//*****************************************************************\n");
printf($dir "//\n");
printf($dir "// END of Module\n");
printf($dir "//\n");
printf($dir "//*****************************************************************\n");

close(dir);

exit;

