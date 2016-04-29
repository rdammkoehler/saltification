# README for Saltification Experiements/Learning

So you say you want to use Pillar Tree (pillar_tree) in your SaltStack Implementation.

Turns out that's not very straight forward. I know I spent several days searching for the "How To" on the internets and could not find a helpful one. Now I'm kinda a n00b when it comes to SaltStack, I've been using it for about 2 weeks in the space between meetings and code reviews. So maybe I'm overblowing how hard it was to figure this out.

After two days of self abuse I finally went begging for help from my good friend and team-mate @magnusstahre. Here is what we figured out;

1) You need to tweak the configuration of your salt master so that it knows you are using pillar tree, this first part just adds an external pillar. The idea here is you want to create a pillar that is not exposed (we're going to put SSL Certs in here) but is accessible when the Salt Master is installing things on the Salt Minion.

	- Add the file /etc/salt/master.d/ext_pillar.conf
        - The following lines of text should be present in that file;

		ext_pillar:
 		  - file_tree:
		    root_dir: /srv/pillar_tree
		    follow_dir_links: False

	- What does that do? It tells Salt that you have an external pillar stored at /srv/pillar_tree. It also specifies that symbolic links should NOT be followed. The file_tree bit is important, that is what pillar_tree will use to find your tree of files.

2) Go create your pillar_tree. This is not as intuitive as we thought it should be, but basically its an 'easy' thing to do. These files are not included in this repository because, well I don't think you need our server keys.

	- Execute the following;

		mkdir -p /srv/pillar_tree/hosts

	- What does that do? Well the first bit, /srv/pillar_tree is the same location you specified in the ext_pillar.conf file in the first step. The hosts folder is used by the contents_pillar that we will use later. It has some funny requirements for how the pillar_tree is layed out.

	- For each minion you wish to have files for;

		mkdir -p /srv/pillar_tree/hosts/{{ minion name }}/files

	- What does that do? That creates a place to put files for your minions. It has to have the same name as the minion to work, not the FQDN, but the minions name. The you actually need to explicitly create a files subdirectory there. Seems klunky, but it does work.

3) Create a state to try this out. In our case we want to put our server certificates in place for NGINX. So we have a state called nginx in our /srv/salt/nginx folder (init.sls) that does this work. It fetches the certificates from the pillar_tree as part of contents_pillar (the source for the managed file) and places them on the minion in the specified location. It looks like this;

	copy ssl cert:
	  file.managed:
	    - name: /etc/nginx/ssl/{{ grains['fqdn'] }}.cert.pem
	    - contents_pillar: files:ssl:{{ grains['fqdn'] }}.cert.pem

	- Here we have a step called 'copy ssl cert', it manages a file named /etc/nginx/ssl/saltminion1.local.cert.pem [Note: This is a demo, the file name typically matches the hosts real name, and in our case that a is a vagrant instance]. 
	- The source of the file is our contents_pillar, the file we want is sss/saltminion1.local.cert.pem. This means back in /srv/pillar_tree/hosts/minion1/files we created a subdirectory called ssl and moved the certificate file saltminion1.local.cert.pem into the folder. 
	- Another note, so we can do this generically, we used grains to specify the file name. The fqdn (Fully Qualified Domain Name) grain is convienently already defined and matches our certificate naming strategy of {fqdn}.{[cert|key]}.pem. Obviously you'll need your own strategy for this.

4) Just to put a bow on this, if you keep reading the content of this repo you will see that we use a Jinja Template when we copy the default site configuration for nginx, and in that file we set the ssl_certificate and ssl_certificate_key values using Jinja to access the grain 'fdqn' again. This helps us get the files to match without any additional incantations. 

The end result is you have nginx installed using only HTTPS with valid keys installed in the correct locations. The keys and certs are not visible to any minion other than the one that is intended to be used by AND they are not pasted into a pillar someplace. I don't know what everyone else things but I think the notion of pasting my SSL key into a text file is about the dumbest thing ever. In particular, had we choosed to use DER keys we'd have not succeeded (darn binary data). 

Anyway, we'll keep updating. I'm sure there are pieces of our description that are missing, feel free to message and ask for additons and modifications.
