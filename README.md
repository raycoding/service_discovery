# service_discovery
This is POC documentation for Service Discovery for geo spatial region using MongoDB

###### Statement – Given a User location let us find services near to the User. Location is defined by latitude and longtitude. Services can be anything e.g hotels, plumbers, hospitals, libraries. Each Service has an address which again is a location (latitude and longtitude). Objective therefore is to find nearest geospatial services given the filter of service type. 


#### Environment : 

MongoDB – I would be using MongoDB as geospatial search is already a built in functionality of such a NoSQL data store. 
Ruby 2.1.2 – used for running few stuffs. 

#### Details : 

- Install MongoDB > 2.6 (I have done on 2.6.1) and start MongoDB

- `sudo service mongod start`

Okay now that our data store is running, Let's fill up some services data across some cities. These are seed data for our work. Obviously you can built an API around to register new sercvices to the data store. So I have created a seed data which I would import into our data store. The seed data contains services records across two cities (e.g Delhi and Kolkata). I have written a plain vanilla script in ruby to generate some random services data for cities.

- `$ > ruby generate_seed_data.rb`

This generates the file seed_data.json with sample data! Now lets import that into the data store of Mongo DB

- `$ >  mongoimport --db services_discovery --collection services --type json --file seed_data.json --jsonArray`

We now have 150 services populated into the DB services_discovery for collection called  services
We need to add index over location as we would query over it. 
And also a composite index over  the filter for location and service_tye and city

- `$mongo >   db.services.ensureIndex({location:"2d"})`
- `$mongo >   db.services.ensureIndex({location:"2d", service_type:1})`
- `$mongo >   db.services.ensureIndex({location:"2d", service_type:1,city:1})`

Okay now lets query this data!

##### Find all nearest services given a User Location. Lets say User location is (29.4,77) 

 - `$mongo > db.services.find({location: {$near:[29.4,77]}}).limit(5)`

`{ "_id" : ObjectId("54ef0069e030e74819f134ba"), "service_name" : "suez", "service_type" : "library", "city" : "Delhi", "location" : { "latitude" : 29.323346900212698, "lontitude" : 77.23878004541487 } }`

`{ "_id" : ObjectId("54ef0069e030e74819f134b9"), "service_name" : "solanum_crispum", "service_type" : "library", "city" : "Delhi", "location" : { "latitude" : 29.174547221381843, "lontitude" : 77.33087109262061 } }`

`{ "_id" : ObjectId("54ef0069e030e74819f134c1"), "service_name" : "corelli", "service_type" : "mobile_services", "city" : "Delhi", "location" : { "latitude" : 29.150844538801607, "lontitude" : 77.3296607174606 } }`

`{ "_id" : ObjectId("54ef0069e030e74819f134c5"), "service_name" : "vertical_circle", "service_type" : "mobile_services", "city" : "Delhi", "location" : { "latitude" : 29.549828897689466, "lontitude" : 77.39041498657666 } }`

`{ "_id" : ObjectId("54ef0069e030e74819f134ab"), "service_name" : "president_theodore_roosevelt", "service_type" : "hospital", "city" : "Delhi", "location" : { "latitude" : 29.347641167719832, "lontitude" : 77.449689114004 } }`

This returns all nearest possible services near to User location. 

##### If you want to apply filter such as Find by service_type : let's say “hospital”

 - `$mongo > db.services.find({location: {$near:[29.4,77]},"service_type": "hospital"}).limit(2)`

`{ "_id" : ObjectId("54ef0069e030e74819f134ab"), "service_name" : "president_theodore_roosevelt", "service_type" : "hospital", "city" : "Delhi", "location" : { "latitude" : 29.347641167719832, "lontitude" : 77.449689114004 } }`

`{ "_id" : ObjectId("54ef0069e030e74819f134af"), "service_name" : "chondrus_crispus", "service_type" : "hospital", "city" : "Delhi", "location" : { "latitude" : 29.60459133999355, "lontitude" : 77.48673376378049 } }`

We get two nearest Hospital Services near User Location.


#####  Lets say I want to find all services within a given city. City can be represented as a polygon of location points, We can use $geoWithin ($within) provided by MongoDB

- `db.services.find({location:{$within:{$geometry:{type : "Polygon",coordinates:[[[ 22.73, 89.30 ],[ 23.4404, 89.36 ], [ 89.36, 23.4404 ],[ 22.73, 89.30 ]]]}}}})`

`{ "_id" : ObjectId("54ef0069e030e74819f134d9"), "service_name" : "protea_cynaroides", "service_type" : "hotel", "city" : "Kolkata", "location" : { "latitude" : 23.440448049030106, "lontitude" : 89.30940153859086 } }`

`{ "_id" : ObjectId("54ef0069e030e74819f134e8"), "service_name" : "pisser", "service_type" : "library", "city" : "Kolkata", "location" : { "latitude" : 23.552384750426274, "lontitude" : 89.31403203157093 } }`

#####  Given the polygon region the query returns only relevant results which lies within this geo-spatial region. You can limit your results as per needed and apply filters. In the query below we have applied the service_type to be “library” and we are trying to find in Kolkata region.

- `db.services.find({"service_type":"library",location:{$within:{$geometry:{type : "Polygon",coordinates:[[[ 22.73, 89.30 ],[ 23.4404, 89.36 ], [ 89.36, 23.4404 ],[ 22.73, 89.30 ]]]}}}})`

`{ "_id" : ObjectId("54ef0069e030e74819f134e8"), "service_name" : "pisser", "service_type" : "library", "city" : "Kolkata", "location" : { "latitude" : 23.552384750426274, "lontitude" : 89.31403203157093 } }`
