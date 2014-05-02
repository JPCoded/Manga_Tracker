#! /usr/bin/perl -w

use strict;
use warnings;
use Gtk2 '-init';
use Glib qw/TRUE FALSE/;
use Gtk2::Ex::Simple::List;
use XML::Simple;
use XML::Writer;
use IO::File;
use Gtk2::Ex::Dialogs::Message(destory_with_parent => 0,modal => 0,no_separator => 1);


set_locale Gtk2;

	my $slManga = Gtk2::Ex::Simple::List->new('Title' => 'text', 'Last Chapter Read' => 'int', 'Date' => 'text', 'Site' => 'text');
		$slManga->signal_connect (row_activated => sub { my ($treeview, $path, $column) = @_; spin_window(); });
	my $in;
	my $scrlManga = Gtk2::ScrolledWindow->new;
	
	
	my $lblchap = new Gtk2::Label("  Chapter:");
	my $lblmonth = new Gtk2::Label("  Month:"); 
	my $lblday = new Gtk2::Label("  Day:");
	my $vbox2 = Gtk2::VBox->new(0,5);
		$vbox2->set_size_request(300,300);
	my $adjChap = new Gtk2::Adjustment( 1.0, 1.0, 1000.0, 1.0, 5.0, 0.0 );
	my $newChap = new Gtk2::SpinButton( $adjChap, 0, 0 );
	my $adjMonth = new Gtk2::Adjustment( 1.0, 1.0, 12.0, 1.0, 5.0, 0.0 );
	my $newMonth = new Gtk2::SpinButton( $adjMonth, 0, 0 );
	my $adjDay = new Gtk2::Adjustment( 1.0, 1.0, 31.0, 1.0, 5.0, 0.0 );
	my $newDay = new Gtk2::SpinButton( $adjDay, 0, 0 );	
	my $enTitle = Gtk2::Entry->new;
	my $enSite = Gtk2::Entry->new;
	my $lblTitle = new Gtk2::Label(" Title:");
	my $lblSite = new Gtk2::Label(" Site:");

	my $btnSNew = Gtk2::Button->new_with_label("Set");
	$btnSNew->signal_connect("clicked",\&set_new);
		$vbox2->pack_start($lblTitle,0,1,0);
		$vbox2->pack_start($enTitle,0,1,0);
		$vbox2->pack_start($lblchap,0,1,0);
		$vbox2->pack_start($newChap,0,1,0);
		$vbox2->pack_start($lblmonth,0,1,0);
		$vbox2->pack_start($newMonth,0,1,0);
		$vbox2->pack_start($lblday,0,1,0);
		$vbox2->pack_start($newDay,0,1,0);
				
		$vbox2->pack_start($lblSite,0,1,0);
		$vbox2->pack_start($enSite,0,1,0);
		$vbox2->pack_start($btnSNew,0,1,0);
		$vbox2->show_all();
	my $newWindow = Gtk2::Window->new();
		$newWindow->add($vbox2);
		$newWindow->signal_connect('delete_event'=>\&Gtk2::Widget::hide_on_delete);
	#update menu
	my $hbox = Gtk2::HBox->new(0,5);
	my $adj3 = new Gtk2::Adjustment( 1.0, 1.0, 1000.0, 1.0, 5.0, 0.0 );
	my $chap = new Gtk2::SpinButton( $adj3, 0, 0 );
	my $adj = new Gtk2::Adjustment( 1.0, 1.0, 12.0, 1.0, 5.0, 0.0 );
	my $month = new Gtk2::SpinButton( $adj, 0, 0 );
	my $adj2 = new Gtk2::Adjustment( 1.0, 1.0, 31.0, 1.0, 5.0, 0.0 );
	my $day = new Gtk2::SpinButton( $adj2, 0, 0 );	

	my $btnUpdate = Gtk2::Button->new_with_label("Set");
	$btnUpdate->signal_connect("clicked",\&set_value);
		$hbox->pack_start($lblchap,0,1,0);
		$hbox->pack_start($chap,0,1,0);
		$hbox->pack_start($lblmonth,0,1,0);
		$hbox->pack_start($month,0,1,0);
		$hbox->pack_start($lblday,0,1,0);
		$hbox->pack_start($day,0,1,0);
		$hbox->pack_start($btnUpdate,0,1,0);
		$hbox->show_all();
	my $spinWindow = Gtk2::Window->new();
		
		$spinWindow->add($hbox);
		$spinWindow->signal_connect('delete_event'=>\&Gtk2::Widget::hide_on_delete);
		
		#standard window creation, placement, and signal connecting
	my $window = Gtk2::Window->new('toplevel');
		$window->set_title('Manga Tracker');
		$window->signal_connect('delete_event' => sub { Gtk2->main_quit; });
		$window->set_border_width(5);
		$window->set_position('center_always');
		$window->set_default_size(600,600);
		
		$window->add(&ret_vbox);
		$window->show();
		
		

		$Gtk2::Ex::Dialogs::Message::parent_window = $window;
load_xml();

#our main event-loop
	Gtk2->main();

sub ret_vbox {
	my $vbox = Gtk2::VBox->new(0,5);
	$vbox->set_size_request(600,550);
	$scrlManga->add($slManga);
	$vbox->pack_start($scrlManga,1,1,0);
	$vbox->pack_start(&button_box,0,0,0);
	$vbox->show_all();
	return $vbox;
}

sub set_value {
	my $da = $month->get_value_as_int() . ":" . $day->get_value_as_int();
	$slManga->{data}[$in][1] = $chap->get_value_as_int();
	$slManga->{data}[$in][2] = $da;
	$spinWindow->hide();
	
}

sub set_new {
	my $da = $newMonth->get_value_as_int() . ":" . $newDay->get_value_as_int();
push @{$slManga->{data}}, [$enTitle->get_text, $newChap->get_value_as_int(),$da,$enSite->get_text];
	$spinWindow->hide();
	
}
sub spin_window {
	my @indice = $slManga->get_selected_indices;
	$in = $indice[0];
	$spinWindow->set_title($slManga->{data}[$in][0]);
	my $chapter = $slManga->{data}[$in][1];
	my $dd = $slManga->{data}[$in][2];
	my @date = split(/:/,$dd);
	$chap->set_value($chapter);
	$month->set_value($date[0]);
	$day->set_value($date[1]);
	$spinWindow->show();		
}
sub new_window {
	$newWindow->set_title("New Manga");
	$newChap->set_value(00);
	$newMonth->set_value(00);
	$newDay->set_value(00);
	$enTitle->set_text("");
	$enSite->set_text("");
	$newWindow->show();
}

sub button_box {
	my $bbox = new Gtk2::HButtonBox();
	my $button;
	my $frame = Gtk2::Frame->new();
	my $btnNew = Gtk2::Button->new_with_label("New");
		$btnNew->signal_connect("clicked",\&new_window);
	my $btnUpdates = Gtk2::Button->new_with_label("Update");
		$btnUpdates->signal_connect("clicked",\&spin_window);
	my $btnSave = Gtk2::Button->new_with_label("Save");
		$btnSave->signal_connect("clicked",\&save_xml);
		$bbox->add($btnNew);
		$bbox->add($btnUpdates);
		$bbox->add($btnSave);
		$frame->add($bbox);
	return $frame;
}

sub load_xml {
	my $xs1 = XML::Simple->new();
	my $doc = $xs1->XMLin('manga.xml');	
	my @MANGA;
	foreach my $key (keys (%{$doc->{'manga'}}))
	{
		 my $TITLE = $doc->{'manga'}->{$key}->{'title'};
		 my $CHAP = $doc->{'manga'}->{$key}->{'chapter'};
		 my $DATE = $doc->{'manga'}->{$key}->{'date'};
		 my $SITE = $doc->{'manga'}->{$key}->{'site'};
		 push(@MANGA,[$TITLE,$CHAP,$DATE,$SITE]);
	}
	my @M2 = (sort { $a->[0] cmp $b->[0] } @MANGA);
	@{$slManga->{data}} = @M2;
	
}

sub save_xml {
	my @MANGA2 = @{$slManga->{data}};
	my $output = new IO::File(">manga.xml");
	
	my $writer = new XML::Writer(OUTPUT => $output);
		$writer->startTag("mangalist");
	my $ii = 0;
	my $ij = 0;
		for my $i ( 0 .. $#MANGA2 ) {
			$writer->startTag("manga");
			$writer->dataElement("id",$ii++);
			$writer->dataElement("title",$MANGA2[$ij][0]);
			$writer->dataElement("chapter",$MANGA2[$ij][1]);
			$writer->dataElement("date",$MANGA2[$ij][2]);
			$writer->dataElement("site",$MANGA2[$ij][3]);		
			$writer->endTag("manga"); 
			$ij++;  
	   }
     
		$writer->endTag("mangalist");
		$writer->end();
		$output->close();
		
	new_and_run
		Gtk2::Ex::Dialogs::Message(title=>"Saved",text=>"Manga List Saved");
}
