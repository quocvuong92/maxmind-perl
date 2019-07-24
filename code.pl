#!/usr/bin/perl


use strict;
use warnings;
use feature qw( say );
use local::lib 'local';
 
use MaxMind::DB::Reader::XS;
use MaxMind::DB::Reader;
use MaxMind::DB::Writer::Tree;
use Net::Works::Network;
use Data::Dumper;
use LWP::Simple;
use Archive::Tar;
 
my $download = 'http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz';
my $local = 'GeoLite2-City.mmdb';
my $output = '/home/vuonghq3/GeoLite2-Custom1.mmdb';
 


my $reader = MaxMind::DB::Reader->new( file => $local );

my %types = (
    names                  => 'map',
    city                   => 'map',
    continent              => 'map',
    registered_country     => 'map',
    represented_country    => 'map',
    country                => 'map',
    location               => 'map',
    postal                 => 'map',
    traits                 => 'map',

    geoname_id             => 'uint32',

    type                   => 'utf8_string',
    en                     => 'utf8_string',
    de                     => 'utf8_string',
    es                     => 'utf8_string',
    fr                     => 'utf8_string',
    ja                     => 'utf8_string',
    'pt-BR'                => 'utf8_string',
    ru                     => 'utf8_string',
    'zh-CN'                => 'utf8_string',

    locales                => [ 'array', 'utf8_string' ],
    code                   => 'utf8_string',
    geoname_id             => 'uint32',
    ip_address             => 'utf8_string',
    subdivisions           => [ 'array' , 'map' ],
    iso_code               => 'utf8_string',
    environments           => [ 'array', 'utf8_string' ],
    expires                => 'uint32',
    name                   => 'utf8_string',
    time_zone              => 'utf8_string',
    accuracy_radius        => 'uint32',
    latitude               => 'float',
    longitude              => 'float',
    metro_code             => 'uint32',
    time_zone              => 'utf8_string',
    is_in_european_union   => 'utf8_string',
    is_satellite_provider   => 'utf8_string',
    is_anonymous_proxy     => 'utf8_string',
);


my $tree = MaxMind::DB::Writer::Tree->new(

    database_type => 'GeoLite2-City',
    description => { en => 'GeoLite2 City database' },
    ip_version => 4,
    map_key_type_callback => sub { $types{ $_[0] } },
    merge_strategy => 'recurse',
    record_size => 28,
    remove_reserved_networks => 0,
);

$reader->iterate_search_tree(
  sub {
        my $ip_as_integer = shift;
        my $mask_length   = shift;
        my $data          = shift;
        my $net_address;

        if ($ip_as_integer > 2**32-1) {
          return;
        }

        my $address = Net::Works::Address->new_from_integer( integer => $ip_as_integer );
        $net_address = join '/', $address->as_ipv4_string, $mask_length - 96;

        if($mask_length > 127) { return; }

        #say join '/', $address->as_ipv4_string, $mask_length - 96;
        #say Dumper($data);

        $tree->insert_network( $net_address, $data );
  }
);


my %custom_ranges = (

    '21.0.0.0/8' => {
      continent => {
        code => "AS",
        geoname_id => 6255147,
        names => {
          de => "Asien",
          en => "Asia",
          es => "Asia",
          fr => "Asie",
          ja => "Asia",
          "pt-BR" => "Asia",
          ru => "Asia",
          "zh-CN" => "Asia",
        },
      },
      country => {
        geoname_id => 1562822,
        iso_code => "VN",
        names => {
          de => "Vietnam",
          en => "Vietnam",
          es => "Vietnam",
          fr => "Vietnam",
          ja => "Vietnam",
          "pt-BR" => "Vietnam",
          ru => "Vietnam",
          "zh-CN" => "Vietnam",
        },
      },
      registered_country => {
        geoname_id => 1562822,
        iso_code => "VN",
        names => {
          de => "Vietnam",
          en => "Vietnam",
          es => "Vietnam",
          fr => "Vietnam",
          ja => "Vietnam",
          "pt-BR" => "Vietnam",
          ru => "Vietnam",
          "zh-CN" => "Vietnam",
        },
      },
    },
    '26.0.0.0/8' => {
      continent => {
        code => "AS",
        geoname_id => 6255147,
        names => {
          de => "Asien",
          en => "Asia",
          es => "Asia",
          fr => "Asie",
          ja => "Asia",
          "pt-BR" => "Asia",
          ru => "Asia",
          "zh-CN" => "Asia",
        },
      },
      country => {
        geoname_id => 1562822,
        iso_code => "VN",
        names => {
          de => "Vietnam",
          en => "Vietnam",
          es => "Vietnam",
          fr => "Vietnam",
          ja => "Vietnam",
          "pt-BR" => "Vietnam",
          ru => "Vietnam",
          "zh-CN" => "Vietnam",
        },
      },
      registered_country => {
        geoname_id => 1562822,
        iso_code => "VN",
        names => {
          de => "Vietnam",
          en => "Vietnam",
          es => "Vietnam",
          fr => "Vietnam",
          ja => "Vietnam",
          "pt-BR" => "Vietnam",
          ru => "Vietnam",
          "zh-CN" => "Vietnam",
        },
      },
    },
);


for my $range ( keys %custom_ranges ) {
  my $metadata = $custom_ranges{$range};
  my $network = Net::Works::Network->new_from_string ( string => $range );
  $tree->insert_network($network, $metadata);
}


open my $fh, '>:raw', $output;
$tree->write_tree( $fh );
close $fh;
