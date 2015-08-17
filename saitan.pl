#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use feature qw(say);

# Goal node
my $goal = "";

# 配列へ格納
my @map;
{
    open (my $fh, "<","data.txt") or die $!;
    my $i=0;
    while (<$fh>){
        chomp;
        my @line = split(//);
        my $char=0;
        for (@line){
            $map[$i][$char]={
                data => $_,
                status => "none",
                c => 0,
                h => 0,
                s => 0, 
                parent => ""
            };
            if ($map[$i][$char]->{data} eq "G"){
                $goal="${i}-$char";
            }
            $char++;
        }
        $i++;
    }
}
# スコア計算
sub next_node {
    my $start;
    my $r = 0;
    my @next;
    while ($r <= $#map){
        my $c = 0;
        for (@{$map[$r]}){
            $start = "$r-$c" if $_->{data} eq "S";
            push(@next, "$r-$c") if $_->{status} eq "open";
            $c++;
        }
        $r++;
    }
    my $score = sub {
        my ($r,$c) = split(/\-/,$_[0]);
        return $map[$r]->[$c]->{s};
    };
    if (@next > 0){
        @next = sort { $score->($a) <=> $score->($b) } @next;
        return $next[0];
    }
    else {
        return $start;
    }
}
sub open_node {
    calc_node($_[0],"up");
    calc_node($_[0],"down");
    calc_node($_[0],"left");
    calc_node($_[0],"right");
    calc_node($_[0],"base");
}
sub calc_node {
    my ($r,$c) = split(/\-/,$_[0]);
    my $op = $_[1];
    if ($op eq "up"){
        $r -= 1;
    }
    elsif ($op eq "down"){
        $r += 1;
    }
    elsif ($op eq "left"){
        $c -= 1;
    }
    elsif ($op eq "right"){
        $c += 1;
    }
    elsif ($op eq "base"){
        $map[$r]->[$c]->{status} = "close";
        return;
    }
    my $node = $map[$r]->[$c];
    unless ($node->{status} eq "none" and $node->{data} eq " "){
        return;
    }
    my $parent_cost = sub {
        my ($r,$c) = split(/\-/,$_[0]);
        return $map[$r]->[$c]->{c}+0;
    };
    my $distance = sub {
        my $r1 = shift;
        my $c1 = shift;
        my ($r2,$c2) = split(/\-/,$goal);
        return abs($r1-$r2);
    };
    $map[$r]->[$c]->{status} = "open";
    $map[$r]->[$c]->{parent} = "$_[0]";
    $map[$r]->[$c]->{c}      = $parent_cost->($_[0])+1;
    $map[$r]->[$c]->{h}      = $distance->($r,$c);
    $map[$r]->[$c]->{s}      = $map[$r]->[$c]->{c} + $map[$r]->[$c]->{h};
}
open_node(next_node());
open_node("2-1");
open_node("3-1");
open_node("4-1");
open_node("4-2");
open_node("4-3");
open_node("4-4");
open_node("3-3");
open_node("3-4");
open_node("2-3");
open_node("3-5");
open_node("1-3");
open_node("2-5");
say next_node();
print Dumper $map[3][5];
