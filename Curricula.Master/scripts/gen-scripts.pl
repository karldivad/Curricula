#!/usr/bin/perl -w

use strict;
use File::Path qw(make_path);
use Lib::Common;
use Cwd;

$Common::command = shift or Util::halt("There is no command to process (i.e. AREA-INST)");
# pending
my %list_of_areas  = ();

# ok
sub gen_compileall_script()
{
	Util::precondition("read_institutions_list");
	my $compileall_file = Common::get_template("out-compileall-file");
	open(OUT, ">$compileall_file") or Util::halt("gen_compileall_script: $compileall_file does not open");
	print OUT "#!/bin/csh\n\n";
	my $body = "";
	my $rm_list = "";
	foreach my $inst (sort keys %Common::inst_list)
	{
		#print "($inst)";
		print OUT "rm -rf html/$Common::inst_list{$inst}{area}-$inst $Common::inst_list{$inst}{area}-$inst-big-main.*\n";
		$body    .= "./scripts/updatelog.pl \"$inst: Starting compilation ...\"\n";
		#$body   .= "set fecha = `date`\n";
		#$body   .= "./scripts/updatelog.pl \"$fecha\"\n";  ``
		$body    .= "./compile  $Common::inst_list{$inst}{area}-$inst \n";
		$body    .= "./gen-html $Common::inst_list{$inst}{area}-$inst\n\n";
	}
	#print OUT "rm -rf html";
	print OUT "\n$body";
	close(OUT);
	system("chmod 774 $compileall_file");
	Util::print_message("gen_compileall_script ok");
}

# ok
sub generate_institution($)
{
	my ($lang) = (@_);
	#my $lang = $Common::config{language_without_accents};
	Util::precondition("read_institutions_list");
	my $current_inst_file = Common::get_template("out-current-institution-file");

    my $output_txt = "";
	$output_txt .= "% This file was generated by gen-scripts.pl ... DO NOT TOUCH !!!\n";
	$output_txt .= "\\newcommand{\\currentinstitution}{$Common::institution}\n";
	$output_txt .= "\\newcommand{\\siglas}{\\currentinstitution}\n";
	my $area     = $Common::inst_list{$Common::institution}{area};
	$output_txt .= "\\newcommand{\\currentarea}{$area}\n";
	$output_txt .= "\\newcommand{\\CountryWithoutAccents}{$Common::config{country_without_accents}}\n";
	$output_txt .= "\\newcommand{\\Country}{$Common::config{country}}\n";
	$output_txt .= "\\newcommand{\\LanguageWithoutAccent}{$Common::config{language_without_accents}}\n";
	$output_txt .= "\\newcommand{\\LANG}{$Common::config{dictionaries}{$lang}{lang_prefix}}\n";
	$output_txt .= "\n";

	$output_txt .= "\\newcommand{\\basedir}{".getcwd()."}\n";
	$output_txt .= "\\newcommand{\\InDir}{\\basedir/".Common::get_template("InDir")."}\n";
	$output_txt .= "\\newcommand{\\InLangBaseDir}{\\basedir/".Common::get_template("InLangBaseDir")."}\n";
	$output_txt .= "\\newcommand{\\InLangDir}{\\basedir/".Common::get_template("InLangDir")."}\n";
	$output_txt .= "\\newcommand{\\InAllTexDir}{\\basedir/".Common::get_template("InAllTexDir")."}\n";
	$output_txt .= "\\newcommand{\\InTexDir}{\\basedir/".Common::get_expanded_template("InTexDir", $lang)."}\n";
	$output_txt .= "\\newcommand{\\InStyDir}{\\basedir/".Common::get_template("InStyDir")."}\n";
	$output_txt .= "\\newcommand{\\InTexAllDir}{\\basedir/".Common::get_template("InTexAllDir")."}\n";
    $output_txt .= "\\newcommand{\\InStyAllDir}{\\basedir/".Common::get_template("InStyAllDir")."}\n";

	$output_txt .= "\\newcommand{\\InCountryDir}{\\basedir/".Common::get_template("InCountryDir")."}\n";
	$output_txt .= "\\newcommand{\\InInstConfigDir}{\\basedir/".Common::get_template("InInstConfigDir")."}\n";
	
	$output_txt .= "\\newcommand{\\InCountryTexDir}{\\basedir/".Common::get_template("InCountryTexDir")."}\n";
	$output_txt .= "\\newcommand{\\InProgramTexDir}{\\basedir/".Common::get_template("InProgramTexDir")."}\n";
	
	$output_txt .= "\\newcommand{\\InSPCDir}{\\basedir/".Common::get_template("InCountryDir")."/$Common::config{discipline}/$Common::config{area}/SPC}\n";
 	$output_txt .= "\\newcommand{\\InProgramDir}{\\basedir/".Common::get_template("InProgramDir")."}\n";
	$output_txt .= "\\newcommand{\\InLogosDir}{\\basedir/".Common::get_template("InLogosDir")."}\n";

	$output_txt .= "\\newcommand{\\OutputTexDir}{\\basedir/".Common::get_template("OutputTexDir")."}\n";
 	$output_txt .= "\\newcommand{\\OutputFigDir}{\\basedir/".Common::get_template("OutputFigDir")."}\n";
 	$output_txt .= "\\newcommand{\\InSyllabiBaseDir}{\\basedir/".Common::get_template("InSyllabiContainerDir")."}\n";
 	$output_txt .= "\\newcommand{\\OutputPrereqDir}{\\basedir/".Common::get_template("OutputPrereqDir")."}\n";
 	$output_txt .= "\n";

	$output_txt .= "\\newcommand{\\TeamTitle}{$Common::config{dictionary}{TeamTitle}}\n";
	$output_txt .= "\\newcommand{\\FinalReport}{$Common::config{dictionary}{FinalReport}}\n";
	$output_txt .= "\\newcommand{\\LastModification}{$Common::config{dictionary}{LastModification}}\n";
	$output_txt .= "\\newcommand{\\BibliographySection}{$Common::config{dictionary}{BibliographySection}}\n";

	$output_txt .= "\\newcommand{\\PeopleDir}{\\basedir/$Common::config{InPeopleDir}}\n";

	$output_txt .= "\n";
	foreach my $lang (@{$Common::config{SyllabusLangsList}})
	{
		$output_txt .= "\\newcommand{\\Language$lang"."Prefix}{$Common::config{dictionaries}{$lang}{lang_prefix}}\n";
	}
	Util::write_file($current_inst_file, $output_txt);
	my $output_current_institution = Common::get_template("OutDir")."/tex/current-institution.tex";

	Util::print_message("Creating: $output_current_institution ...");
	Util::write_file($output_current_institution, $output_txt);
	Util::print_message("generate_institution ok");
}

# ok
sub update_acronyms()
{
	Util::precondition("read_institutions_list");
	my $txt = "";
	my $inst_info_root = Common::get_template("InCountryDir");
	my $out_txt = "";
	foreach my $inst (sort keys %Common::inst_list)
	{
		#system("mv institutions-info/institutions-$inst.tex institutions-info/info-$inst.tex");
		my $out_txt_name = Common::GetInstitutionInfo($Common::inst_list{$inst}{country}, $inst);
		if(-e $out_txt_name)
		{
            Util::print_message("Reading: $out_txt_name ...");
			$out_txt = Util::read_file($out_txt_name);
			if($out_txt =~ m/\\newcommand\{\\University\}\{(.*?)\}/)
			{
				my $univ = $1;
				$univ =~ s/\\xspace//g;
				$txt .= "\\acro{$inst}{$univ}\n";
			}
		}
        else
        {
            #Util::print_message("File: \"$out_txt_name\" does not exist ...");
        }
	}
	#print "$basetex/$area-acronyms.tex\n";
	my $acronym_base = Common::get_template("in-acronyms-base-file");
	   $out_txt 	 = Util::read_file($acronym_base);

	if($out_txt =~ m/%--LIST-OF-INSTITUTIONS--/)
	{
		my $pretxt = "\n%Text generated by gen-scripts.pl ... DO NOT TOUCH !!!\n";
		my $postxt = "%End of text generated\n";
		$out_txt =~ s/%--LIST-OF-INSTITUTIONS--/$pretxt$txt$postxt/g;
	}

	my $out_acronym_file = Common::get_template("out-acronym-file");
	Util::write_file($out_acronym_file, $out_txt);
	Util::print_message("update_acronyms ($out_acronym_file) OK!");
}

sub gen_batch_files()
{
	my $file = "";
	my ($input, $output) = ("", "");
	my $lang = Common::get_template("language_without_accents");
	foreach my $file ("compile1institucion", "gen-html-1institution")
	{
	    system("rm $file*");
	    $input     = Common::get_template("in-$file-base-file");
	    $output    = Common::get_template("out-$file-file");
	    Common::gen_batch($input, $output, $lang);
	    Util::print_message("Creating shorcut: ln -s $output");
	    system("cp $output .");
	}
	foreach my $file ("gen-eps-files", "gen-graph", "gen-book", "CompileTexFile", "compile-simple-latex", "gen-poster")
	{
	    $output    = Common::get_template("out-$file-file");
	    system("rm $output");
		$input     = Common::get_template("in-$file-base-file");
		Common::gen_batch($input, $output, $lang);
	}
	my $command = "cp ". Common::get_template("preamble0-file")." ". Common::get_template("OutputTexDir");
	Util::print_message($command);
	system($command);
}

sub main()
{
	Common::set_initial_configuration($Common::command);
	my $lang = Common::get_template("language_without_accents");
	gen_batch_files();
	gen_compileall_script();
	generate_institution($lang);
	update_acronyms();
	Util::print_message("End gen-scripts ...\n");
}

main();
