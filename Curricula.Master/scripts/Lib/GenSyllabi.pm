package GenSyllabi;
use warnings;
use Data::Dumper;
use Scalar::Util qw(blessed dualvar isdual readonly refaddr reftype
                        tainted weaken isweak isvstring looks_like_number
                        set_prototype);
                        # and other useful utils appearing below
use scripts::Lib::Common;
use strict;

sub get_environment($$$)
{
	my ($codcour, $txt, $env) = (@_);

	if($txt =~ m/\\begin\{$env\}\s*\n((?:.|\n)*)\\end\{$env\}/g)
	{	return $1;	}
# 	Util::print_warning("$codcour does not have $env");
	return "";
}

sub process_syllabus_units($$$$)
{
	my ($codcour, $lang, $syllabus_in, $unit_struct)	= (@_);
	my ($unit_count, $total_hours) 			= (0, 0);
	my %accu_hours     				= ();
	
	#                        \begin{unit}{\AL}{}   {Guttag13,Thompson11,Zelle10}{2}{C1,C5}
	$unit_count = 0;
	while($syllabus_in =~ m/(\\begin\{unit\}.*?\s*(?:.|\n)*?\\end\{unit\})/g)
	{	
		my $this_unit = $1;
		$unit_count++;
		#                        \begin{unit}{\AL}{}   {Guttag13,Thompson11,Zelle10}{2}{C1,C5}
		if( not $this_unit =~ m/\\begin\{unit\}\{.*?\}\{.*?\}\{.*?\}\{.*?\}\s*(?:.|\n)*?\\end\{unit\}/g )
		{    Util::print_warning("Codcour=$codcour, Unit $unit_count out of format:\n$this_unit\n");
		}
	}

	$unit_count = 0;
	while($syllabus_in =~ m/\\begin\{unit\}\{.*?\}\{.*?\}\{.*?\}\{(.*?)\}\{.*?\}\s*((?:.|\n)*?)\\end\{unit\}/g)
	{
		$unit_count++;
		my $nhours 	= $1;
		$total_hours   += $nhours;
		if( not looks_like_number($nhours) )
		{	Util::print_warning("Codcour=$codcour, Unit $unit_count, number of hours is wrong ($nhours)");		}
		$accu_hours{$unit_count}  = $total_hours;
	}

	my $all_units_txt     = "";
	my $unit_captions = "";
	$unit_count       = 0;
	$Common::course_info{$codcour}{allbibitems}             = "";
	$Common::course_info{$codcour}{n_units}			= 0;
	$Common::course_info{$codcour}{units}{unit_caption}	= [];
	$Common::course_info{$codcour}{units}{bib_items}	= [];
	$Common::course_info{$codcour}{units}{hours}		= [];
	$Common::course_info{$codcour}{units}{bloom_level}	= [];
	$Common::course_info{$codcour}{units}{topics}    	= [];
	$Common::course_info{$codcour}{units}{unitgoals}	= [];

	my $sep = "";
	while($syllabus_in =~ m/\\begin\{unit\}\{(.*?)\}\{(.*?)\}\{(.*?)\}\{(.*?)\}\{(.*?)\}\s*((?:.|\n)*?)\\end\{unit\}/g)
	{	
		$unit_count++;
		$Common::course_info{$codcour}{n_units}++;
		my ($unit_caption, $alternative_caption, $unit_bibitems, $unit_hours, $level_of_competence, $unit_body) = ($1, $2, $3, $4, $5, $6);
		$unit_bibitems =~ s/ //g;
		
		push(@{$Common::course_info{$codcour}{units}{unit_caption}}, $unit_caption);
		push(@{$Common::course_info{$codcour}{units}{alternative_caption}}, $alternative_caption);
		push(@{$Common::course_info{$codcour}{units}{bib_items}}   , $unit_bibitems);
		push(@{$Common::course_info{$codcour}{units}{hours}}       , $unit_hours);
# 		if($codcour eq "CS1D1")
# 		{
# 		    print Dumper (\%{$Common::course_info{$codcour}{units}}); exit;
# 		    #print Dumper (\%{$Common::map_hours_unit_by_course{$lang}{DSSetsRelationsandFunctions}}); exit;
# 		}
		push(@{$Common::course_info{$codcour}{units}{level_of_competence}} , $level_of_competence);
		$Common::course_info{$codcour}{allbibitems} .= "$sep$unit_bibitems";

		$unit_captions   .= "\\item $unit_caption\n";
		my %map = ();
		$map{UNIT_TITLE}  	= $unit_caption;
		$map{UNIT_BIBITEMS}	= $unit_bibitems;
		
		$map{LEVEL_OF_COMPETENCE}	= $level_of_competence;
		my $codcour_label = Common::get_label($codcour);
		if($unit_caption =~ m/^\\(.*)/) 
		{
			$unit_caption = $1;
			#Util::print_message("Course: $codcour_label: \\$unit_caption found ...");
			#print Dumper (\%$Common::config{topics_priority}); exit;
			if(not defined($Common::map_hours_unit_by_course{$lang}{$unit_caption}{$codcour_label}))
			{	$Common::map_hours_unit_by_course{$lang}{$unit_caption}{$codcour_label} = 0;		}
			$Common::map_hours_unit_by_course{$lang}{$unit_caption}{$codcour_label} += $unit_hours;

			if(not defined($Common::acc_hours_by_course{$lang}{$codcour_label}))
			{	$Common::acc_hours_by_course{$lang}{$codcour_label}  = 0;						}
			$Common::acc_hours_by_course{$lang}{$codcour_label} += $unit_hours;

			if(not defined($Common::acc_hours_by_course{$lang}{$unit_caption}))
			{	$Common::acc_hours_by_unit{$lang}{$unit_caption}  = 0;						}
			$Common::acc_hours_by_unit{$lang}{$unit_caption} += $unit_hours;
			
# 			if( $unit_caption eq "DSSetsRelationsandFunctions" )
# 			{	print Dumper (\%Common::map_hours_unit_by_course{$lang}{$unit_caption}); 		}
		}
		$sep = ",";
		my ($topics, $unitgoals) = ("", "");
		if($unit_body =~ m/(\\begin\{topics\}\s*((?:.|\n)*?)\\end\{topics\})/g)
		{	$topics = $1; }
		elsif($unit_body =~ m/(\\.*?AllTopics)/g)
		{	$topics = $1; }

		if($unit_body =~ m/(\\begin\{learningoutcomes\}\s*(?:.|\n)*?\\end\{learningoutcomes\})/g)
		{	$unitgoals = $1; }
		elsif($unit_body =~ m/(\\.*?AllObjectives)/g)
		{	$unitgoals = $1; }
		push(@{$Common::course_info{$codcour}{units}{topics}},   $topics);
		push(@{$Common::course_info{$codcour}{units}{unitgoals}}, $unitgoals);

		my $thisunit            = $unit_struct;
		$map{HOURS}		= "$unit_hours";
		$map{FULL_HOURS}	= "$unit_hours $Common::config{dictionary}{hours}";
		$map{UNIT_GOAL}		= $unitgoals;
		$map{UNIT_CONTENT}	= $topics;
		$map{PERCENTAGE} 	= 0;
		$map{PERCENTAGE} 	= int(100*$accu_hours{$unit_count}/$total_hours+0.5) if($total_hours  > 0 );

		$sep = "";
		my $bib_citations = "";
		foreach my $bibitem (split(",", $unit_bibitems))
		{	$bib_citations .= "$sep\\cite{$bibitem}";	$sep = ", ";		}
		$map{CITATIONS} = $bib_citations;
		$thisunit = Common::replace_tags($thisunit, "--", "--", %map);
		$all_units_txt .= $thisunit;
	}
	Util::check_point("process_syllabus_units");
	#print Dumper (\%Common::map_hours_unit_by_course); exit;
	return ($all_units_txt, $unit_captions);
}

sub read_syllabus_info($$$)
{
	my ($codcour, $semester, $lang)   = (@_);
	my $count       = 0;
	my $fullname 	= Common::get_syllabus_full_path($codcour, $semester, $lang);
	my $syllabus_in	= Util::read_file($fullname);
# 	Util::print_message("GenSyllabi::read_syllabus_info $codcour ...");

	$syllabus_in =~ s/\\ExpandOutcome\{/\\ShowOutcome\{/g;
	$syllabus_in =~ s/\\Competence\{/\\ShowCompetence\{/g;
	$syllabus_in =~ s/\{unitgoals\}/\{learningoutcomes\}/g;
	Util::write_file($fullname, $syllabus_in);
	
# 	my $count_old_macros = 0;
# 	($syllabus_in, $count_old_macros) = Common::replace_old_macros($syllabus_in);
# 	Util::write_file($fullname, $syllabus_in);
# 	Util::print_message("Replaced $count_old_macros old macros in file: \"$fullname\"") if($count_old_macros > 0);

	my %map = ();
	
	$map{SOURCE_FILE_NAME} = $fullname;
	# 1st: Get general information from this syllabus
	$Common::course_info{$codcour}{unitcount}	= 0;
# 	$Common::course_info{$codcour}{justification}	= get_environment($codcour, $syllabus_in, "justification");
# 	$Common::course_info{$codcour}{goals}         	= get_environment($codcour, $syllabus_in, "goals");
	foreach my $env ("outcomes", "competences", "justification", "goals")
	{
	      $Common::course_info{$codcour}{$lang}{$env}{txt} 	= get_environment($codcour, $syllabus_in, $env);
	}

	# 2nd: Process its outcomes and learningoutcomes
	foreach my $env ("outcomes", "competences")
	{
	      $Common::course_info{$codcour}{$env}{itemized}	= "";
	      $Common::course_info{$codcour}{$env}{array}	= [];
	      $Common::course_info{$codcour}{$env}{count}     	= 0;
	}

	my %macro_for_env = ("outcomes" => "ShowOutcome", "competences"=>"ShowCompetence");
	foreach my $env ("outcomes", "competences")
	{
	      foreach my $one_line ( split("\n", $Common::course_info{$codcour}{$lang}{$env}{txt}) )
	      {
		      my ($key, $level)     = ("", "");
		      my $reg_exp =  "\\\\".$macro_for_env{$env}."\\{(.*)\\}\\{(.*?)\\}";
		      if( $one_line =~ m/$reg_exp/g )
		      { 
			      ($key, $level) = ($1, $2);
			      $Common::course_info{$codcour}{$env}{$key} = $2; # Instead of "" we must put the level of this outcome/LO
			      push(@{$Common::course_info{$codcour}{$env}{array}}, $key); # Sequential to list later
			      $Common::course_info{$codcour}{$env}{count}++;
			      my $prefix	        = "";
 			      if(defined($Common::config{$env."_map"}) and defined($Common::config{$env."_map"}{$key}) ) # outcome: a), b), c) ... Competence
			      {	$prefix = $Common::config{$env."_map"}{$key};	}
			      $Common::course_info{$codcour}{$env}{itemized} .= "\\item \\".$macro_for_env{$env}."{$key}{$level}\n";
		      }
	      }
	}
	
	$map{COURSE_CODE} 	= $codcour;
	$map{COURSE_NAME} 	= $Common::course_info{$codcour}{course_name}{$lang};
	$map{COURSE_TYPE}	= $Common::config{dictionaries}{$lang}{$Common::course_info{$codcour}{course_type}};

	$semester 		= $Common::course_info{$codcour}{semester};
	$map{SEMESTER}    	= $semester;
	$map{SEMESTER}         .= "\$^{$Common::config{dictionary}{ordinal_postfix}{$semester}}\$ ";
	$map{SEMESTER}         .= "$Common::config{dictionary}{Semester}.";
	$map{CREDITS}		= $Common::course_info{$codcour}{cr};
	$map{JUSTIFICATION}	= $Common::course_info{$codcour}{$lang}{justification}{txt};
	
	$map{FULL_GOALS}	= "\\begin{itemize}\n$Common::course_info{$codcour}{$lang}{goals}{txt}\n\\end{itemize}";
	$map{GOALS_ITEMS}	= $Common::course_info{$codcour}{$lang}{goals}{txt};
	
	$map{FULL_OUTCOMES}	= "\\begin{description}\n$Common::course_info{$codcour}{outcomes}{itemized}\\end{description}";
	$map{OUTCOMES_ITEMS}	= $Common::course_info{$codcour}{outcomes}{itemized};
	
	$map{FULL_COMPETENCES}	= "\\begin{description}\n$Common::course_info{$codcour}{competences}{itemized}\\end{description}";
	$map{COMPETENCES_ITEMS}	= $Common::course_info{$codcour}{competences}{itemized};

	$map{EVALUATION} 	= $Common::config{general_evaluation};

	#Util::print_message("map{EVALUATION} =\n$map{EVALUATION}");
	if( defined($Common::course_info{$codcour}{$lang}{specific_evaluation}) )
	{	$map{EVALUATION} = $Common::course_info{$codcour}{$lang}{specific_evaluation};	}
	#Util::print_message("Common::course_info{$codcour}{$lang}{specific_evaluation}=\n$Common::course_info{$codcour}{$lang}{specific_evaluation}");	exit;
	
	#Util::print_message("course $codcour\nmap{EVALUATION}=\n$map{EVALUATION}"); 
	#exit;

	($map{PROFESSOR_NAMES}, $map{PROFESSOR_SHORT_CVS}, $map{PROFESSOR_JUST_GRADE_AND_FULLNAME}) = ("", "", "");
	my $sep    = "";
	if(defined($Common::antialias_info{$codcour}))
	{	$codcour = $Common::antialias_info{$codcour}	}
	my $alias = Common::get_alias($codcour);
	if(defined($Common::config{distribution}{$alias}))
	{
		foreach my $email (sort {$Common::config{faculty}{$b}{fields}{degreelevel} <=> $Common::config{faculty}{$a}{fields}{degreelevel}} keys %{$Common::config{distribution}{$alias}})
		{
			if(defined($Common::config{faculty}{$email}{fields}{name}))
			{	
				$map{PROFESSOR_NAMES} 			.= "$Common::config{faculty}{$email}{fields}{name} ";
				$map{PROFESSOR_SHORT_CVS}		.= "\\noindent $Common::config{faculty}{$email}{fields}{prefix} $Common::config{faculty}{$email}{fields}{name}\n";
				$map{PROFESSOR_SHORT_CVS} 		.= "\\begin{itemize}\n";
				$map{PROFESSOR_SHORT_CVS} 		.= "$Common::config{faculty}{$email}{fields}{shortcv}";
				$map{PROFESSOR_SHORT_CVS} 		.= "\\end{itemize}\n\n";
				#$map{PROFESSOR_JUST_GRADE_AND_FULLNAME} .= "$sep$Common::config{faculty}{$email}{fields}{title} $Common::config{faculty}{$email}{fields}{name}";
			}
			$sep = ", ";
		}
	}
	else
	{
 		#Util::print_message("There is no professor assigned to $codcour ($alias) (Sem #$Common::course_info{$codcour}{semester})");
	}
	$Common::course_info{$codcour}{docentes_names}  	= $map{PROFESSOR_NAMES};
	$Common::course_info{$codcour}{docentes_titles}  	= $map{PROFESSOR_TITLES};
	$Common::course_info{$codcour}{docentes_shortcv} 	= $map{PROFESSOR_SHORT_CVS};
	#if($codcour eq "FG101")
	#{     Util::print_message("Professor for course $codcour\n$map{PROFESSOR_SHORT_CVS}");	      exit;	}

	my $horastxt = "";
	$horastxt 			.= "$Common::course_info{$codcour}{th} HT; " if($Common::course_info{$codcour}{th} > 0);
	$horastxt 			.= "$Common::course_info{$codcour}{ph} HP; " if($Common::course_info{$codcour}{ph} > 0);
	$horastxt 			.= "$Common::course_info{$codcour}{lh} HL; " if($Common::course_info{$codcour}{lh} > 0);
	$map{HOURS}			 = $horastxt;
	($map{THEORY_HOURS}, $map{PRACTICE_HOURS}, $map{LAB_HOURS})	= ("", "", "");

	if($Common::course_info{$codcour}{th} > 0)
	{   $map{THEORY_HOURS} = "$Common::course_info{$codcour}{th} $Common::config{dictionary}{THEORY}";	}

	if($Common::course_info{$codcour}{ph} > 0)
	{   $map{PRACTICE_HOURS} = "$Common::course_info{$codcour}{ph} $Common::config{dictionary}{PRACTICE}";	}

	if($Common::course_info{$codcour}{lh} > 0)
	{   $map{LAB_HOURS} = "$Common::course_info{$codcour}{lh} $Common::config{dictionary}{LABORATORY}";	}

	$map{PREREQUISITES} 			= $Common::course_info{$codcour}{code_name_and_sem_prerequisites};
	if($Common::course_info{$codcour}{n_prereq} == 0)
	{	$map{PREREQUISITES_JUST_CODES}	= $Common::config{dictionary}{None};								}
	else
	{	$map{PREREQUISITES_JUST_CODES}	= $Common::course_info{$codcour}{prerequisites_just_codes};		}


	my $syllabus_template = $Common::config{syllabus_template};
	my $unit_struct = "";
	if($syllabus_template =~ m/--BEGINUNIT--\s*\n((?:.|\n)*)--ENDUNIT--/)
	{	$unit_struct = $1;	}
	($map{UNITS_SYLLABUS}, $map{SHORT_DESCRIPTION}) = process_syllabus_units($codcour, $lang, $syllabus_in, $unit_struct);
# 	if($codcour eq "CS1D1")
#  	{	print Dumper (\%Common::map_hours_unit_by_course{$lang}{DSSetsRelationsandFunctions}); 
#  	}
 	
# 	my $sumilla_template = $Common::config{sumilla_template};
# 	$unit_struct = "";
# 	if($sumilla_template =~ m/--BEGINUNIT--\s*\n((?:.|\n)*)--ENDUNIT--/)
# 	{	$unit_struct = $1;	}
# 	($map{UNITS_SUMILLA}, $_)                       = process_syllabus_units($codcour, $lang, $syllabus_in, $unit_struct);
# 	if($codcour eq "CS1D1")
#  	{	print Dumper (\%Common::map_hours_unit_by_course{$lang}{DSSetsRelationsandFunctions}); exit;
#  	}
	
	$map{LIST_OF_TOPICS} = $map{SHORT_DESCRIPTION};
	$map{SHORT_DESCRIPTION} = "\\begin{inparaenum}\n$map{SHORT_DESCRIPTION}\\end{inparaenum}";

	my ($bibfile_in, $bibfile_out) = ("", "");
	if($syllabus_in =~ m/\\bibfile\{(.*?)\}/g)
	{	$bibfile_in = $1;	$bibfile_in     =~ s/ //g;	}

	$map{BIBSTYLE}	= $Common::config{bibstyle};
	if( $bibfile_in =~ m/.*\/(.*)/)
	{	$bibfile_out 	= $1;	
		$Common::course_info{$codcour}{short_bibfiles} = $1;
	}
	$map{IN_BIBFILE} 	= $bibfile_in;
	$map{BIBFILE} 		= $bibfile_out.".bib";
	$Common::course_info{$codcour}{bibfiles} = $bibfile_in;

	foreach (keys %{$Common::course_info{$codcour}{extra_tags}})
	{	$map{$_} = $Common::course_info{$codcour}{extra_tags}{$_};		}
	# TEXT TO CUT
# 	if( $codcour eq "FG170" )
# 	{	print Dumper(\%map);	exit;
# 	    exit;
# 	}
	return %map;
}

sub genenerate_tex_syllabus_file($$$$$%)
{
	my ($codcour, $file_template, $units_field, $output_file, $lang, %map)   = (@_);

# 	my $unit_struct = "";
# 	if($file_template =~ m/--BEGINUNIT--\s*\n((?:.|\n)*)--ENDUNIT--/)
# 	{	$unit_struct = $1;	}
	$file_template =~ s/--BEGINUNIT--\s*\n((?:.|\n)*)--ENDUNIT--/$map{$units_field}/g;
	
	$file_template =~ s/\\newcommand\{\\INST\}\{\}/\\newcommand\{\\INST\}\{$Common::institution\}/g;
	$file_template =~ s/\\newcommand\{\\AREA\}\{\}/\\newcommand\{\\AREA\}\{$Common::area\}/g;

	Util::print_message("genenerate_tex_syllabus_file $codcour: $output_file ...");
	for(my $i = 0 ; $i < 2; $i++ )
	{
	    $file_template = Common::replace_tags($file_template, "--", "--", %map);
	    $file_template = Common::replace_tags($file_template, "<<", ">>", %{$Common::config{dictionaries}{$lang}});
	}
	
        #$file_template =~ s/--.*?--//g;
        system("rm $output_file");
	Util::write_file($output_file, $file_template);

# 	Util::print_message("Syllabi $output_file ... generated ok!");
# 	Util::print_message($output_file);      exit;
}

sub read_sumilla_template()
{
	my $template_file = Common::get_template("in-sumilla-template-file");
	if(not -e $template_file)
	{	Util::halt("It seems that you forgot the template sumilla file ... verify \"$template_file\"");		}
	$Common::config{sumilla_template} = Util::read_file($template_file);
}

sub read_syllabus_template()
{
	my $template_file = Common::get_template("in-syllabus-template-file");
	if(not -e $template_file)
	{	Util::halt("It seems that you forgot the syllabus template file ... verify \"$template_file\"");		}
	$Common::config{syllabus_template} = Util::read_file($template_file);

	if( $Common::config{syllabus_template} =~ m/\\begin\{evaluation\}\s*\n((?:.|\n)*?)\n\\end\{evaluation\}/g )
	{
	      $Common::config{general_evaluation} = $1;
	      $Common::config{syllabus_template}  =~ s/\\begin\{evaluation\}\s*\n(?:.|\n)*?\n\\end\{evaluation\}/--EVALUATION--/;
	      Util::print_message("File General Evaluation detected ok!");
	}
	else
	{
	      Util::print_error("It seems you did not write General Evaluation Criteria on your Syllabus template (See file: $template_file) ...");
	}
}

# ok, Here we generate syllabi, prerequisitite files
sub process_syllabi()
{
	Common::read_faculty(); 
	Common::read_distribution();
	Common::read_aditional_info_for_silabos(); # Days, time for each class, etc.

	# It generates all the sillabi
	read_sumilla_template();   # 1st Read template for sumilla
	read_syllabus_template();  # 2nd Read the syllabus template
	gen_course_general_info(); # 3th Generate files containing Prerequisites, etc
	gen_prerequisites_map($Common::config{language_without_accents});   # 4th Generate dot files 
	
	# 4th: Read evaluation info for this institution
	Common::read_specific_evaluacion_info(); # It loads the field: $Common::course_info{$codcour}{specific_evaluation} for each course with specific evaluation
	
# 	Util::print_message("Common::config{syllabus_template}=\n$Common::config{syllabus_template}"); exit;
	
	generate_tex_syllabi_files();
        generate_syllabi_include();
 	gen_batch_to_compile_syllabi();
	
	foreach my $lang (@{$Common::config{SyllabusLangsList}})
	{
	    gen_book("Syllabi", "../syllabi/", "", $lang);
	    if( $Common::config{flags}{DeliveryControl} && $Common::config{flags}{DeliveryControl} == 1 )
	    {	gen_book("Syllabi", "../pdf/", "-delivery-control", $lang);	
	    }
	}
	Util::check_point("gen_syllabi");
}

# ok
sub generate_tex_syllabi_files()
{ 
	Util::precondition("parse_courses");
	
	# Generate all the syllabi
	my $count_courses 	= 0;
	my $OutputTexDir = Common::get_template("OutputTexDir");
	for(my $semester = $Common::config{SemMin}; $semester <= $Common::config{SemMax}; $semester++)
	{
		#foreach my $codcour (@{$Common::courses_by_semester{$semester}})
                foreach my $codcour (sort {$Common::config{prefix_priority}{$Common::course_info{$a}{prefix}} <=> $Common::config{prefix_priority}{$Common::course_info{$b}{prefix}}} 
                                         @{$Common::courses_by_semester{$semester}})
		{
			my $codcour_label = Common::get_label($codcour);
			foreach my $lang (@{$Common::config{SyllabusLangsList}})
			{
			      my %map = read_syllabus_info($codcour, $semester, $lang);
			      $map{AREA}	= $Common::config{area};
			      $map{LANG}	= $lang;
			      $map{lang}	= $Common::config{lang_for_latex}{$lang};
			      #Util::print_message("A. Common::course_info{$codcour}{$lang}{specific_evaluation}=\n$Common::course_info{$codcour}{$lang}{specific_evaluation}");	exit;
			      #Util::print_message("Common::config{syllabus_template}=$Common::config{syllabus_template}");	
			      #Util::print_warning("map{EVALUATION}=$map{EVALUATION}");	exit;
			      
			      
			      my $output_file = "$OutputTexDir/$codcour_label-$Common::config{dictionaries}{$lang}{lang_prefix}.tex";
			      #Util::print_message("Generating Syllabus: $output_file");
			      genenerate_tex_syllabus_file($codcour_label, $Common::config{syllabus_template}, "UNITS_SYLLABUS", $output_file, $lang, %map);
      
			      # Copy bib files
			      my $syllabus_bib = Common::get_template("InSyllabiContainerDir")."/$map{IN_BIBFILE}.bib";
			      #Util::print_message("cp $syllabus_bib $OutputTexDir");
			      eval { system("cp $syllabus_bib $OutputTexDir"); }
			      
			      #eval { system("cp $syllabus_bib $OutputTexDir"); }
			      #warn $@ if $@;
			}
			#print Dumper(\%{$Common::config{dictionaries}{English}}); exit;
# 			genenerate_tex_syllabus_file($codcour, $Common::config{sumilla_template} , "UNITS_SUMILLA" , "$OutputTexDir/$codcour-sumilla.tex", %map);
		}
	}
	system("chgrp curricula $OutputTexDir/*");
	Util::check_point("generate_tex_syllabi_files");
}

# ok 
sub gen_batch_to_compile_syllabi()
{
	Util::precondition("set_global_variables");
# 	Util::print_message("gen_batch_to_compile_syllabi starting ...");
	my $out_gen_syllabi = Common::get_template("out-gen-syllabi.sh-file");
	
	my $output = "";
	#$output .= "rm *.ps *.pdf *.log *.dvi *.aux *.bbl *.blg *.toc\n\n";
	$output .= "#!/bin/csh\n";
	$output .= "set course=\$1\n";
	$output .= "if(\$course == \"\") then\n";
	$output .= "set course=\"all\"\n";
	$output .= "endif\n";
# 	$output .= "echo \"codigo=\$course\";\n";
	
	$output .= "\n";
	my $html_out_dir 		 = Common::get_template("OutputHtmlDir");
	my $html_out_dir_syllabi = $html_out_dir."/syllabi";
	$output .= "if(\$course == \"all\") then\n";
	$output .= "rm -rf $html_out_dir_syllabi\n";
	$output .= "endif\n";
	$output .= "mkdir -p $html_out_dir_syllabi\n";

	my $tex_out_dir_syllabi	 = Common::get_template("OutputSyllabiDir");
	$output .= "if(\$course == \"all\") then\n";
	$output .= "rm -rf $tex_out_dir_syllabi\n";
	$output .= "endif\n";
	$output .= "mkdir -p $tex_out_dir_syllabi\n\n";
	
	my ($gen_syllabi, $cp_bib) = ("", "");
	my $scripts_dir 		= Common::get_template("InScriptsDir");
	my $output_tex_dir 		= Common::get_template("OutputTexDir");
	my $OutputInstDir 		= Common::get_template("OutputInstDir");
	
	my $syllabus_container_dir 	= Common::get_template("InSyllabiContainerDir");
	my $count_courses 		= 0;
	my ($parallel_sep)   = ("");
        $parallel_sep = "&" if($Common::config{parallel} == 1);

	for(my $semester = $Common::config{SemMin}; $semester <= $Common::config{SemMax}; $semester++)
	{
		#foreach my $codcour (@{$Common::courses_by_semester{$semester}})
		$output .= "#Semester #$semester\n";
		foreach my $codcour (sort {$Common::config{prefix_priority}{$Common::course_info{$a}{prefix}} <=> $Common::config{prefix_priority}{$Common::course_info{$b}{prefix}}}  @{$Common::courses_by_semester{$semester}})
		{
			my $codcour_label = Common::get_label($codcour);
			$output .= "if(\$course == \"$codcour\" || \$course == \"$codcour_label\" || \$course == \"all\") then\n";
# 			Util::print_message("codcour = $codcour, bibfiles=$Common::course_info{$codcour}{bibfiles}");
			foreach (split(",", $Common::course_info{$codcour}{bibfiles}))
			{
				$output .= "cp $syllabus_container_dir/$_.bib $output_tex_dir\n";
 				#Util::print_message("$syllabus_container_dir/$_");
			}
			foreach my $lang (@{$Common::config{SyllabusLangsList}})
			{
				$output .= "$scripts_dir/gen-syllabus.sh $codcour_label-$Common::config{dictionaries}{$lang}{lang_prefix} $OutputInstDir$parallel_sep\n";
			}
			$output .= "endif\n\n";
			$count_courses++;
		}
	}
	#$output .= "\n$cp_bib\n$gen_syllabi";
	Util::write_file($out_gen_syllabi, $output);
	system("chmod 774 $out_gen_syllabi");
	Util::print_message("gen_batch_to_compile_syllabi $Common::institution ($count_courses courses) OK!");
}

sub get_hidden_chapter_info($)
{
	my ($semester) = (@_);
	my $output_tex .= "\% $semester$Common::config{dictionary}{ordinal_postfix}{$semester} $Common::config{dictionary}{Semester}\n";
	$output_tex .= "\\addtocounter{chapter}{1}\n";
	$output_tex .= "\\addcontentsline{toc}{chapter}{$Common::config{dictionary}{semester_ordinal}{$semester} $Common::config{dictionary}{Semester}}\n";
	$output_tex .= "\\setcounter{section}{0}\n";
	return $output_tex;
}

sub write_book_files($$$)
{
      my ($InBook, $lang, $output_tex) = (@_);
      system("cp ".Common::get_template("in-Book-of-$InBook-face-file")." ".Common::get_template("OutputTexDir"));
      
      my $InBookContent = Util::read_file(Common::get_template("in-Book-of-$InBook-main-file"));
      $InBookContent =~ s/<LANG>/$Common::config{dictionaries}{$lang}{lang_prefix}/g;
      my $OutBookFile = Common::get_template("out-Book-of-$InBook-main-file");
      $OutBookFile =~ s/<LANG>/$Common::config{dictionaries}{$lang}{lang_prefix}/g;
      Util::print_message("Generating $OutBookFile ok");
      Util::write_file($OutBookFile, $InBookContent);
      
      my $OutputIncludeListFile = Common::get_template("out-$InBook-includelist-file");
      $OutputIncludeListFile =~ s/<LANG>/$Common::config{dictionaries}{$lang}{lang_prefix}/g;
      
      Util::print_message("Generating $OutputIncludeListFile ok");
      Util::write_file($OutputIncludeListFile, $output_tex);
}
# ok
# GenSyllabi::gen_book("Syllabi", "syllabi/", "");
# GenSyllabi::gen_book("Syllabi", "../pdf/", "-delivery-control");
sub gen_book($$$$)
{
	my ($InBook, $prefix, $postfix, $lang) = (@_);
	Util::precondition("set_global_variables");	
	
	my $output_tex = "";
	#$output_tex .="rm *.ps *.pdf *.log *.dvi *.aux *.bbl *.blg *.toc\n\n";
	my $count = 0;
	for(my $semester = $Common::config{SemMin}; $semester <= $Common::config{SemMax} ; $semester++)
	{
		$output_tex .= get_hidden_chapter_info($semester);
		#foreach my $codcour (@{$Common::courses_by_semester{$semester}})
		foreach my $codcour (sort {$Common::config{prefix_priority}{$Common::course_info{$a}{prefix}} <=> $Common::config{prefix_priority}{$Common::course_info{$b}{prefix}}}  @{$Common::courses_by_semester{$semester}})
		{
		    my $codcour_label = Common::get_label($codcour);
		    #-$Common::config{dictionaries}{$lang}{lang_prefix}.tex";
		    $output_tex .= "\\includepdf[pages=-,addtotoc={1,section,1,{$codcour_label. $Common::course_info{$codcour}{course_name}{$Common::config{language_without_accents}}},$codcour_label-$Common::config{dictionaries}{$lang}{lang_prefix}}]";
		    $output_tex .= "{$prefix$codcour_label-$Common::config{dictionaries}{$lang}{lang_prefix}$postfix}\n";
		    $count++;
		}
		$output_tex .= "\n";
	}
	write_book_files("Syllabi", $lang, $output_tex);
# 	Util::print_message("gen_book ($count courses) in $OutputFile OK!");
}

# ok
sub gen_book_of_descriptions($)
{
      my ($lang) = (@_);
      Util::precondition("set_global_variables");
      my $output_tex = "";
      my $count = 0;
      for(my $semester = $Common::config{SemMin}; $semester <= $Common::config{SemMax} ; $semester++)
      {
	      $output_tex .= get_hidden_chapter_info($semester);
	      foreach my $codcour (sort {$Common::config{prefix_priority}{$Common::course_info{$a}{prefix}} <=> $Common::config{prefix_priority}{$Common::course_info{$b}{prefix}}}  @{$Common::courses_by_semester{$semester}})
	      {
		      #Util::print_message("codcour = $codcour    ");
		      my $codcour_label = Common::get_label($codcour);
		      my $sec_title = "$codcour_label. $Common::course_info{$codcour}{course_name}{$Common::config{language_without_accents}}";
  # 			$sec_title 	.= "($semester$Common::config{dictionary}{ordinal_postfix}{$semester} ";
  # 			$sec_title 	.= "$Common::config{dictionary}{Semester})";
		      $output_tex .= "\\section{$sec_title}\\label{sec:$codcour_label}\n";
		      $output_tex .= "$Common::course_info{$codcour}{$lang}{justification}{txt}\n\n";
		      $count++;
	      }
	      $output_tex .= "\n";
      }
      write_book_files("Descriptions", $lang, $output_tex);
      Util::print_message("gen_book_of_descriptions ($count courses) OK!");
}

# ok
sub gen_list_of_units_by_course()
{
	Util::precondition("set_global_variables");
	my $file_name = Common::get_template("out-list-of-unit-by-course-file");
	my $output_tex = "";
	my $count = 0;
	for(my $semester = $Common::config{SemMin}; $semester <= $Common::config{SemMax} ; $semester++)
	{
		$output_tex .= get_hidden_chapter_info($semester);
		#foreach my $codcour (@{$Common::courses_by_semester{$semester}})
                foreach my $codcour (sort {$Common::config{prefix_priority}{$Common::course_info{$a}{prefix}} <=> $Common::config{prefix_priority}{$Common::course_info{$b}{prefix}}}  @{$Common::courses_by_semester{$semester}})
		{
			my $codcour_label 	= Common::get_label($codcour);
			my $i = 0;
			my $sec_title = "$codcour_label. $Common::course_info{$codcour}{course_name}{$Common::config{language_without_accents}}";
 			#$sec_title 	.= "($semester$Common::config{dictionary}{ordinal_postfix}{$semester} ";
 			#$sec_title 	.= "$Common::config{dictionary}{Semester})";
			$output_tex .= "\\section{$sec_title}\\label{sec:$codcour}\n";
			#for($i = 0 ; $i < $Common::course_info{$codcour}{outcomes}{count}; $i++)
			$output_tex .= "\\subsection{Resultados}\n";
			$output_tex .= "\\begin{itemize}\n";
			my $outcomes_txt = "";
			foreach my $outcome_key (@{$Common::course_info{$codcour}{outcomes}{array}}) # Sequential to list later
			{
				my $bloom 	= $Common::course_info{$codcour}{outcomes}{$outcome_key};
				$outcomes_txt  .= "\\item \\ref{out:Outcome$outcome_key}) \\Outcome$outcome_key"."Short [$bloom, ~~~~~]\n";
			}
			if( $Common::course_info{$codcour}{outcomes}{count} == 0 )
			{	$output_tex .= "\t\\item $Common::config{dictionary}{None}\n";	}
			$output_tex .= $outcomes_txt;
			$output_tex .= "\\end{itemize}\n\n";

			$output_tex .= "\\subsection{Unidades}\n";
			$output_tex .= "\\begin{itemize}\n";
			my $units_txt = "";
			for($i = 0 ; $i < $Common::course_info{$codcour}{n_units}; $i++)
			{
			      $units_txt .= "\t\\item $Common::course_info{$codcour}{units}{unit_caption}[$i], ";
			      $units_txt .= "$Common::course_info{$codcour}{units}{hours}[$i] $Common::config{dictionary}{hrs}, ";
			      $units_txt .= "[$Common::course_info{$codcour}{units}{bloom_level}[$i], ~~~~~]\n";
			}
			#if( $Common::course_info{$codcour}{n_units} == 0 )
			if( $i == 0 )
			{	$units_txt = "\t\\item $Common::config{dictionary}{None}\n";	}
			$output_tex .= $units_txt;
			$output_tex .= "\\end{itemize}\n\n";
			$count++;
		}
		$output_tex .= "\n";
	}
	Util::write_file($file_name, $output_tex);
	system("cp ".Common::get_template("in-Book-of-units-by-course-main-file")." ".Common::get_template("OutputTexDir"));
	system("cp ".Common::get_template("in-Book-of-units-by-course-face-file")." ".Common::get_template("OutputTexDir"));
	Util::print_message("gen_list_of_units_by_course $file_name ($count courses) OK!");
}

sub gen_book_of_bibliography($)
{
      my ($lang) = (@_);
      Util::precondition("set_global_variables");
      my $count = 0;
      my $output_tex = "";

      for(my $semester = $Common::config{SemMin}; $semester <= $Common::config{SemMax} ; $semester++)
      {
	      $output_tex .= get_hidden_chapter_info($semester);
	      #foreach my $codcour (@{$Common::courses_by_semester{$semester}})
	      foreach my $codcour (sort {$Common::config{prefix_priority}{$Common::course_info{$a}{prefix}} <=> $Common::config{prefix_priority}{$Common::course_info{$b}{prefix}}}  @{$Common::courses_by_semester{$semester}})
	      {
		      # print "codcour=$codcour ...\n";
		      my $bibfiles = $Common::course_info{$codcour}{short_bibfiles};
		      #print "codcour = $codcour    ";
		      my $sec_title = "$codcour. $Common::course_info{$codcour}{course_name}{$Common::config{language_without_accents}} ";
# 			$sec_title .= "($semester$Common::rom_postfix{$semester} sem)";
		      $output_tex .= "\\section{$sec_title}\\label{sec:$codcour}\n";
		      $output_tex .= "\\begin{btUnit}%\n";
		      $output_tex .= "\\nocite{$Common::course_info{$codcour}{allbibitems}}\n";
		      $output_tex .= "\\begin{btSect}[apalike]{$bibfiles}%\n";
		      $output_tex .= "\\btPrintCited\n";
		      $output_tex .= "\\end{btSect}%\n";	
		      $output_tex .= "\\end{btUnit}%\n\n";
		      #$output_tex .= "$Common::course_info{$codcour}{justification}\n\n";
		      $count++;
	      }
	      $output_tex .= "\n";
      }
      write_book_files("Bibliography", $lang, $output_tex);
      Util::print_message("gen_book_of_bibliography ($count courses) OK!");
}

sub generate_syllabi_include()
{
        my $output_file = Common::get_template("out-list-of-syllabi-include-file");
        my $output_tex  = "";

        $output_tex  .= "%This file is generated automatically ... do not touch !!! (GenSyllabi.pm: generate_syllabi_include())\n";
        $output_tex  .= "\\newcounter{conti}\n";

        my $OutputTexDir = Common::get_template("OutputTexDir");
        my $ncourses    = 0;
	my $newpage = "";
        for(my $semester = $Common::config{SemMin}; $semester <= $Common::config{SemMax} ; $semester++)
        {
                $output_tex .= "\n";
                $output_tex .= "\\addcontentsline{toc}{section}{$Common::config{dictionary}{semester_ordinal}{$semester} ";
                $output_tex .= "$Common::config{dictionary}{Semester}}\n";
                foreach my $codcour (sort {$Common::config{prefix_priority}{$Common::course_info{$a}{prefix}} <=> $Common::config{prefix_priority}{$Common::course_info{$b}{prefix}}}  
			    @{$Common::courses_by_semester{$semester}})
                {
		    my $codcour_label = Common::get_label($codcour);
		    my $course_fullpath = Common::get_syllabus_full_path($codcour, $semester, Common::get_template("language_without_accents"));
		    system("cp $course_fullpath $OutputTexDir/.");
		    Util::print_message("cp $course_fullpath $OutputTexDir/.");
		    $course_fullpath =~ s/(.*)\.tex/$1/g;
		    $output_tex .= "$newpage\\input{$OutputTexDir/$codcour}";
		    $output_tex .= "% $codcour_label $Common::course_info{$codcour}{course_name}{$Common::config{language_without_accents}}\n";
		    $ncourses++;
		    $newpage = "\\newpage";
                }
                $output_tex .= "\n";
        }
        Util::write_file($output_file, $output_tex);
        Util::print_message("generate_syllabi_include() OK!");
}

sub gen_course_general_info()
{
	my $OutputPrereqDir = Common::get_template("OutputPrereqDir");
	my $OutputFigDir = Common::get_template("OutputFigDir");
	
	
	for(my $semester = $Common::config{SemMin}; $semester <= $Common::config{SemMax} ; $semester++)
	{
		#foreach my $codcour (@{$Common::courses_by_semester{$semester}})
                foreach my $codcour (sort {$Common::config{prefix_priority}{$Common::course_info{$a}{prefix}} <=> $Common::config{prefix_priority}{$Common::course_info{$b}{prefix}}}  @{$Common::courses_by_semester{$semester}})
		{
			my $normal_header   = "\\begin{itemize}\n";

			my $codcour_label = Common::get_label($codcour);
			# Semester: 5th Sem.
			$normal_header .= "\\item {\\bf $Common::config{dictionary}{Semester}}: ";
			$normal_header .= "$semester\$^{$Common::config{dictionary}{ordinal_postfix}{$semester}}\$ ";
			$normal_header .= "$Common::config{dictionary}{Sem}. ";

			# Credits
			$normal_header .= "{\\bf $Common::config{dictionary}{Credits}}: $Common::course_info{$codcour}{cr}\n";

			# Hours of this course
			$normal_header .= "\\item {\\bf $Common::config{dictionary}{HoursOfThisCourse}}: ";
			if($Common::course_info{$codcour}{th} > 0)
			{	$normal_header .= "{\\bf $Common::config{dictionary}{Theory}}: $Common::course_info{$codcour}{th} $Common::config{dictionary}{hours}; ";	}
			if($Common::course_info{$codcour}{ph} > 0)
			{	$normal_header .= "{\\bf $Common::config{dictionary}{Practice}}: $Common::course_info{$codcour}{ph} $Common::config{dictionary}{hours}; ";	}
			if($Common::course_info{$codcour}{lh} > 0)
			{	$normal_header .= "{\\bf $Common::config{dictionary}{Laboratory}}: $Common::course_info{$codcour}{lh} $Common::config{dictionary}{hours}; ";	}
			$normal_header .= "\n";

			my $syllabus_link = "";
			$syllabus_link .= "\t\\begin{htmlonly}\n";
			$syllabus_link .= "\t\\item {\\bf $Common::config{dictionary}{Syllabus}}:\n";
			$syllabus_link .= "\t\t\\begin{rawhtml}\n";
			$syllabus_link .= Common::get_pdf_icon_link("\t\t\t", $codcour_label)."-";
			$syllabus_link .=  "\t\t\\end{rawhtml}\n";
			$syllabus_link .=  "\t\\end{htmlonly}\n";
			$normal_header .= $syllabus_link;
			
			my $prereq_txt = "\\item {\\bf $Common::config{dictionary}{Prerequisites}}: ";
			if($Common::course_info{$codcour}{n_prereq} == 0)
			{	$prereq_txt .= "$Common::config{dictionary}{None}\n";	}
			else
			{
				$prereq_txt .= "\n\t\\begin{itemize}\n";
				foreach my $course (@{$Common::course_info{$codcour}{full_prerequisites}})
				{
					$prereq_txt .= "\t\t\\item $course\n";
				}
				$prereq_txt .= "\t\\end{itemize}\n";
			}
			$normal_header .= $prereq_txt;
			$normal_header    .= "\\end{itemize}\n";
			
			my $output_file = "$OutputPrereqDir/$codcour_label";
			Util::write_file("$output_file.tex", $normal_header);
# 			Util::print_message("$codcour, $output_file.tex ok!");
			
			my $output_tex  = "";
			$output_tex    .= "\\input{$output_file}\n\n";
			$output_tex    .= "\\begin{figure}\n";
			$output_tex    .= "\\centering\n";
			$output_tex    .= "\\includegraphics[scale=0.66]{\\OutputFigDir/$codcour_label}\n";
			$output_tex    .= "\\caption{Cursos relacionados con \\htmlref{$codcour_label}{sec:$codcour_label}}\n";
			$output_tex    .= "\\label{fig:prereq:$codcour_label}\n";
			$output_tex    .= "\\end{figure}\n";

			Util::write_file("$output_file-html.tex", $output_tex);
# 			Util::print_message("$output_file-html.tex ok!");
			
		}
	 }
	 #Util::print_error("TODO: XYZ Aqui falta poner varios silabos en idiomas !");
}

sub gen_prerequisites_map($)
{
        my ($lang) = (@_);
	my $size = "big";
	my $template_file = Common::get_template("in-$size-graph-item.dot");
	my $course_tpl 	= Util::read_file($template_file);
# 	$course_tpl =~ s/<FULLNAME>/<FULLNAME> \(<SEM>\)/g;
	#Util::print_message("course_tpl = $course_tpl ... ");
	
	Util::print_message("Reading $template_file ... ");

	my $OutputDotDir  		= Common::get_template("OutputDotDir");
	my $OutputFigDir 		= Common::get_template("OutputFigDir");
	my $update_page_numbers_file 	= Common::get_template("update-page-numbers");

	my $batch_replace_pages = "";
	my $batch_txt 		= "#!/bin/csh\n\n";
	
	for(my $semester = $Common::config{SemMin}; $semester <= $Common::config{SemMax} ; $semester++)
	{
		$batch_txt .= "# Semester #$semester\n";
		foreach my $codcour (@{$Common::courses_by_semester{$semester}})
		{
			my $codcour_label = Common::get_label($codcour);
			my $min_sem_to_show 	= $Common::course_info{$codcour}{semester};
			my $max_sem_to_show 	= $Common::course_info{$codcour}{semester};
			my %courses_by_semester = ();
			push(@{$courses_by_semester{$Common::course_info{$codcour}{semester}}}, $codcour);
			
			my $output_file = "$OutputDotDir/$codcour_label.dot";
			my $prev_courses_dot = "";
			# Map PREVIOUS courses
			foreach my $codprev (@{$Common::course_info{$codcour}{prerequisites_for_this_course}})
			{	
				my $codprev_label = Common::get_label($codprev);
				$prev_courses_dot .= Common::generate_course_info_in_dot_with_sem($codprev, $course_tpl, $lang)."\n";	

				$prev_courses_dot .= "\t\"$codprev_label\"->\"$codcour_label\" [lhead=cluster$codcour_label];\n";
				$min_sem_to_show = $Common::course_info{$codprev}{semester} if($Common::course_info{$codprev}{semester} < $min_sem_to_show);
				push(@{$courses_by_semester{$Common::course_info{$codprev}{semester}}}, $codprev);
			}
			
 			my $this_course_dot = $course_tpl;
 			my %map = ("FONTCOLOR"	=> "black",
				   "FILLCOLOR"	=> "yellow",
				   "BORDERCOLOR" => "black");
 			$this_course_dot = Common::replace_tags($this_course_dot, "<", ">", %map);
 			$this_course_dot = Common::generate_course_info_in_dot_with_sem($codcour, $this_course_dot, $lang)."\n";
 			
 			# Map courses AFTER this course
			my $post_courses_dot = "";
			foreach my $codpost (@{$Common::course_info{$codcour}{courses_after_this_course}})
			{	
				my $codpost_label = Common::get_label($codpost);
				$post_courses_dot .= Common::generate_course_info_in_dot_with_sem($codpost, $course_tpl, $lang)."\n";	

				$post_courses_dot .= "\t\"$codcour_label\"->\"$codpost_label\" [ltail=cluster$codcour_label];\n";
				$max_sem_to_show = $Common::course_info{$codpost}{semester} if($Common::course_info{$codpost}{semester} > $max_sem_to_show);
				push(@{$courses_by_semester{$Common::course_info{$codpost}{semester}}}, $codpost);
			}
			
			my $sem_col 		= "";
			my $sem_definitions 	= "";
			my $same_rank 		= "";
			my $sep 		= "";
			for( my $sem_count = $min_sem_to_show; $sem_count <= $max_sem_to_show; $sem_count++)
			{	
				my $sem_label = Common::sem_label($sem_count);
				my $this_sem = "\t{ rank = same; $sem_label; "; 
				foreach my $one_cour (@{$courses_by_semester{$sem_count}})
				{	$this_sem .= "\"".Common::get_label($one_cour)."\"; ";		}
				$same_rank .= "$this_sem }\n";
				$sem_col .= "$sep$sem_label";
# 				,fillcolor=black,style=filled,fontcolor=white
				$sem_definitions .= "\t$sem_label [shape=box];\n";
				$sep = "->";
			}
			my $output_tex  = "";
			# Semester: Ej. 5th Sem.
			$output_tex .= "digraph $codcour_label\n";
			$output_tex .= "{\n";
			$output_tex .= "\tbgcolor=white;\n";
			$output_tex .= "\tcompound=true;\n";
 			$output_tex .= "\t$sem_col;\n";
 			$output_tex .= "\n";
			$output_tex .= $sem_definitions;
			if(not $prev_courses_dot eq "")
			{	$output_tex .= "$prev_courses_dot\n";	}
			
			$output_tex .= "\tsubgraph cluster$codcour_label\n";
			$output_tex .= "\t{\n";
# 			$output_tex .= "\t\tbgcolor=yellow;\n";
# 			$output_tex .= "\t\tcolor=yellow;\n";
			$output_tex .= "\t$this_course_dot\n";
			$output_tex .= "\t}\n";
			
			if(not $post_courses_dot eq "")
			{	$output_tex .= "$post_courses_dot\n";	}
			$output_tex .= "$same_rank\n";
			
			$output_tex .= "}\n";
			
			Util::write_file($output_file, $output_tex);
			Util::print_message("Generating $output_file ok!");
			#$batch_txt	.= "dot -Gcharset=$Common::config{encoding} -Tps $output_file -o $OutputFigDir/$codcour_label.ps; \n";
			$batch_txt	.= "dot -Tps $output_file -o $OutputFigDir/$codcour_label.ps; \n";
			$batch_txt	.= "convert $OutputFigDir/$codcour_label.ps $OutputFigDir/$codcour_label.png&\n\n";
			#exit;
		}
	 }
	 my $batch_map_for_course_file = Common::get_template("out-gen-map-for-course");
	 Util::write_file($batch_map_for_course_file, $batch_txt);
	 system("chmod 774 $batch_map_for_course_file");
}

1;