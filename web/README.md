# Flask app

## local test

You can run `docker-compose` on the root directory of this repo.

```{bash}
$ docker-compose build && docker-compose up
```

## deployment on GBE

```{bash}
cd ~/repos/rivas-lab/covid19_HGI

cp -r web/templates/covid19HGI/ /opt/biobankengine/GlobalBioBankEngineRepo/gbe_browser/templates/

cp -r fig /opt/biobankengine/GlobalBioBankEngineRepo/gbe_browser/static/covid19HGI/fig
```

You need to manually modify `gbe.py` to reflect changes in [`app.py`](app.py). Please note that you need to change the followings:

- the default paths in `covid19HGI_read_res_table` function
  - `covid19HGI_read_res_table(static_path='/biobankengine/app/static/', GBE_top='')`
- the `namespace` arg should be specified.
  - `namespace = 'RIVAS_HG19'` in `render_template()` function calls.
