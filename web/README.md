# Interactive data browser

We have implemented a Flask app to browse the results of the PRS-PheWAS analysis.
We deploy it to [Global Biobank Engine](https://gbe.stanford.edu/covid19HGI) but you can also run the browser on your local computer as well.

## How to run the browser onn your local computer?

The flask app can be hosted via Docker container. Please install Docker if you don't have it on your computer.

After installing Docker, you can simply run `docker-compose` command on the root directory of this repository.

```{bash}
$ docker-compose build && docker-compose up
```

## How to deploy the app on Global Biobank Engine (GBE)

The Global Biobank Engine (GBE is also hosted using flask app.
You can copy the Jinja2 template into the following file paths and update the corresponding section of the `gbe.py` script.

```{bash}
cd ~/repos/rivas-lab/covid19_HGI

cp -r web/templates/covid19HGI/ /opt/biobankengine/GlobalBioBankEngineRepo/gbe_browser/templates/

cp -r fig /opt/biobankengine/GlobalBioBankEngineRepo/gbe_browser/static/covid19HGI/fig
```

After copying the template files, you need to manually modify `gbe.py` to reflect changes in [`app.py`](app.py). Please note that you need to change the followings:

- the default paths in `covid19HGI_read_res_table` function
  - `covid19HGI_read_res_table(static_path='/biobankengine/app/static/', GBE_top='')`
- the `namespace` arg should be specified.
  - `namespace = 'RIVAS_HG19'` in `render_template()` function calls.

Once you performe those updates and restarting the docker container, you should be able to see the `covid19_HGI` page.
