#!/usr/bin/perl -w
use Data::Dumper;
use scripts::Lib::Common;
use strict;

my $file = "";
if( defined($ENV{'CurriculaParam'}))	{ $Common::command = $ENV{'CurriculaParam'};	}
if(defined($ARGV[0])) { $Common::command = shift or Util::halt("There is no command to process (i.e. AREA-INST)");	}

sub main()
{
	Common::set_initial_configuration($Common::command);
	#print Dumper(%{$Common::config{outcomes_map}}); exit;
        Common::read_pagerefs();
	
	Common::parse_courses(); 
        Common::filter_courses();
	
	
	Common::update_page_numbers(Common::get_template("out-big-graph-curricula-dot-file"));
 	Common::update_page_numbers_for_all_courses_maps();	
}

main();