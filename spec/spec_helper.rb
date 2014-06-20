require 'rubygems'

require File.expand_path(File.dirname(__FILE__) + '/../lib/mpi_client.rb')

include MPIClient

MPIClient.server_url = 'https://3dsecure.begateway.com/3dsecure/xml'
