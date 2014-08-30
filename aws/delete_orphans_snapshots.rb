#!/usr/bin/env ruby
require 'aws-sdk'

ec2_region = AWS_REGION
ec2 = AWS::EC2.new(:region => ec2_region,
  :access_key_id => AWS_ACCESS_KEY,
  :secret_access_key => AWS_SECRET_KEY )
   ec2.snapshots.with_owner(:self).select.each  do |snap_object|
   if ec2.volumes["#{snap_object.volume_id}"].exists?
       belong_instance_id = ec2.client.describe_instances(filters: [{ name: "block-device-mapping.volume-id", values: [snap_object.volume_id]}])[:reservation_set][0][:instances_set][0][:instance_id]
       ec2.instances[belong_instance_id].tags.each {|key,value| if key == 'Name' and !key.empty? then puts "the snapshot #{snap_object.id} belong to #{value}"  elsif key == 'Name' then puts "the snapshot #{snap_object.id} belong to #{belong_instance_id}" end }
   else
       puts "the snapshot #{snap_object.id} belongs to #{snap_object.volume_id} that doesn't exist anymore"
       snapshots_available = ec2.snapshots.filter('volume-id', snap_object.volume_id)
       snapshots_available.each do |snapold|
       puts "#{snapold.id} can be also deleted because belongs to the same non existent volume_id : #{snap_object.volume_id}"
       end
   end
end
