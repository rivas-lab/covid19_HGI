import os

from flask import Flask, render_template
import pandas

#Create a Flask constructor. It takes name of the current module as the argument
app = Flask(__name__)

#Create a route decorator to tell the application, which URL should be called for the #described function and define the function

def covid19HGI_read_res_table(static_path='/web/static/', GBE_top='https://gbe.stanford.edu'):
    tbl=os.path.join(static_path, 'covid19HGI/fig/HGIrel5.PRS_PheWAS.1e-5.tsv.gz')
    subset_map={
        'eur_leave_ukbb_23andme': 'EUR (-UKB)',
        'eur_leave_23andme': 'EUR',
        'leave_UKBB_23andme': 'All (-UKB)',
        'leave_23andme': 'All'
    }

    df = pandas.read_csv(tbl, sep='\t')

    df['GBE_short_name'] = ['<a href="{}/RIVAS_HG19/coding/{}">{}</a>'.format(GBE_top, x[0], x[1]) for x in zip(df['GBE_ID'], df['GBE_short_name'])]
    df = df.drop('GBE_ID',axis=1)
    df = df.drop('z_or_t_value',axis=1)
    for col in ['GBE_category']:
        df[col] = df[col].map(lambda x: x.replace('_', ' '))
    for col in ['HGI_suffix']:
        df[col] = df[col].map(lambda x: subset_map[x])
    for col in ['estimate', 'SE']:
        df[col] = df[col].map(lambda x: str(round(x, 3)))
    for col in ['clump_p1']:
        df[col] = df[col].map(lambda x: '{:.0e}'.format(x).replace('-0', '-') )
    for col in ['P']:
        df[col] = df[col].map(lambda x: '{:.2e}'.format(x))

    return(df)


@app.route('/')
@app.route('/covid19HGI')
def covid19HGI_main():
    df=covid19HGI_read_res_table()

    table_body_str=''.join(['<tr>{}</tr>'.format(
        ''.join(['<td>{}</td>'.format(x) for x in df.iloc[row]])
    ) for row in range(df.shape[0])])
    table_cols=['HGI', 'subset', 'clump p1', 'category', 'trait', 'BETA', 'SE', 'P']
    table_cols_select=['HGI', 'subset', 'clump p1', 'category']

    return render_template(
        'covid19HGI/main.html',
        #=======================#
        _HGI_v = 'HGIrel5',
        _HGI_case_controls=['B2', 'C2', 'B1', 'A2'],
        _HGI_suffices=['eur_leave_ukbb_23andme', 'eur_leave_23andme', 'leave_UKBB_23andme', 'leave_23andme'],
        _clump_p1s=['1e-5', '1e-4', '1e-3'],
        #=======================#
        _HGI_sx = 'eur_leave_ukbb_23andme',
        _HGI_cc = 'B2',
        _clumpp = '1e-5',
        table_cols        = table_cols,
        table_cols_select = table_cols_select,
        table_body_str    = table_body_str
    )

@app.route('/covid19HGI/PRS_PheWAS/<HGI_sx>/')
def covid19HGI_prs_phewas(HGI_sx):
    return render_template(
        'covid19HGI/prs_phewas.html',
        #=======================#
        _HGI_v = 'HGIrel5',
        _HGI_case_controls=['B2', 'C2', 'B1', 'A2'],
        _HGI_suffices=['eur_leave_ukbb_23andme', 'eur_leave_23andme', 'leave_UKBB_23andme', 'leave_23andme'],
        _clump_p1s=['1e-5', '1e-4', '1e-3'],
        #=======================#
        HGI_sx = HGI_sx,
        _HGI_cc = 'B2',
        _clumpp = '1e-5'
    )

@app.route('/covid19HGI/PRS_PheWAS/<HGI_sx>/<HGI_cc>')
def covid19HGI_prs_phewas_more(HGI_sx, HGI_cc):
    return render_template(
        'covid19HGI/prs_phewas_more.html',
        #=======================#
        _HGI_v = 'HGIrel5',
        _HGI_case_controls=['B2', 'C2', 'B1', 'A2'],
        _HGI_suffices=['eur_leave_ukbb_23andme', 'eur_leave_23andme', 'leave_UKBB_23andme', 'leave_23andme'],
        _clump_p1s=['1e-5', '1e-4', '1e-3'],
        _GBE_IDs=['INI30130', 'INI30190', 'INI30610', 'INI10030610'],
        #=======================#
        HGI_sx = HGI_sx,
        HGI_cc = HGI_cc,
        _clumpp = '1e-5'
    )

#Create the main driver function
if __name__ == '__main__':
    #call the run method
    app.run(debug=True,host='0.0.0.0')
