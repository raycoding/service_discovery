require 'rubygems'
require 'random-word'
require 'json'

cities = ["Delhi","Kolkata","Bangalore"]
city_location = {
	"Delhi" => ["28.6100","77.2300"], #Latitude and Longitude
	"Kolkata" => ["22.5667","88.3667"],
	"Bangalore" => ["12.9667","77.5667"]
}
service_types = ["plumbering","hotel","hospital","library","mobile_services"]
documents = []
# lets populate a total of 150 services
cities.each do |city_name|
	service_types.each do |service_type|
		(1..10).each do |i| # just generating 10 random service providers for each city each service_type!
			documents <<  {
											"service_name"=>RandomWord.nouns.next,
											"service_type"=>service_type,
											"city"=>city_name,
											"location"=>{
																		"latitude"=>(city_location[city_name][0].to_f+rand),
																		"lontitude"=>(city_location[city_name][1].to_f+rand)
																	}
										}
		end
	end
end
File.open("seed_data.json", 'w') { |file| file.write(documents.to_json) }