# Dockerized consul-template

Much thanks to the guys at belly for inspiration in this example: https://github.com/bellycard/docker-loadbalancer

# What's here?

Checkout the docker branch to see the docker build for this repo

The master branch is a demonstration of how to use this run a load balanced nginx container

# Usage

By default the consul-template container expects you to specify three environment variables:

- TEMPLATE_PATH : where the template to run lives
- TEMPLATE_TARGET_PATH : the file to write out to
- ON_RERENDER : a script you'd like to execute each time a service change triggers updates

## Example

Specifying just those variables is enough to make a load balancer

Here's an excerpt from the docker-compose that kicks things off:
```
    environment:
        - TEMPLATE_PATH=/data/templates/nginx.conf
        - TEMPLATE_TARGET_PATH=/etc/nginx/conf.d/app.conf
        - ON_RERENDER=reset_nginx.sh
```

### TEMPLATE_PATH

First, let's talk about the TEMPLATE_PATH and the file therein.
The template is where all the logic lives, and if we look inside:
```
## Generated: {{timestamp}}
{{ range services }} {{ range $svc := service .Name }} {{ range $svc.Tags }} {{ if eq "web" . }}
```

Those two lines do most of what we care about. The first line makes a comment for when this
file was last generated.
The second line, read aloud, would sound like this:

- Loop over all services (the same as ```curl http://my.consul.host/v1/catalog/services``` piping it as JSON)
- Loop over service port entry
- Loop over each Tag in that port's listing
- Check if the tag matches 'web'

This set of logic will pull out any service ports you've tagged as 'web' and plops them
into the nginx server list.

### TEMPLATE_TARGET_PATH
Second, let's look at the target path.

From the compose file again:
```
        - TEMPLATE_TARGET_PATH=/etc/nginx/conf.d/app.conf
```

This is simply where the template results land. No
other steps are taken unless you specify the next option...

### ON_RERENDER

If the template has to be updated, any text specified in this
environment variable will be run. In this case, the ```reset_nginx.sh```
is run.

### Other variables

- CONSUL_HOST : hostname/FQDN for consul host
- CONSUL_PORT : port on which consul api is kept
- SERVICE_PATH : override all the things runit does


## FAQ

### Only one template? Why not support multiple?

I think it's idiomatic to have one service and one config
per container.

I assume this would be easily added if you need it by adding a for-loop.
If you would like this or have a PR, please enter an issue.

### What if I need a secure api token? Are there no env vars for that?

To keep things secure, I recommend that you volume mount a config file.
It's only slightly safer than putting secrets into an env variable, but
I think it's worth it.

To see how to add a token to your consul-template config, see
https://github.com/hashicorp/consul-template#configuration-files


