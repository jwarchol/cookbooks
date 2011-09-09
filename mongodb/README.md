# Mongodb

Installs and configures 1-n mongo instances for each node.

## Usage

Depend on this cookbook within your cookbook and create instances of mongod's in your recipes via the LWRP:

```
mongod_instance 'instance_name' do
  name 'instance_name' (optional)
  port 'instance_port'
  sharded true|false
  replication_set 'replSet name'
  enable_rest true|false
  config_servers Array|false
  additional_settings 'extra flags to pass mongod option line'
end
```

For extra points, use the data-bag driven databases::mongodb recipe to create 
         
Thanks to Custom Ink for getting this started with their mongodb cookbook!
https://github.com/customink/customink-cookbooks

## LICENSE and AUTHORS:

Authors:: Ryan C. Creasey (<mailto:rcreasey@ign.com>) 
Authors:: Nathen Harvey (<mailto:nharvey@customink.com>) and Jake Vanderdray (<jvanderdray@customink.com>)

Copyright:: 2011, IGN Entertainment
Copyright:: 2010, CustomInk, LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.