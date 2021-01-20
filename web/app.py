#Import the flask module
from flask import Flask, render_template

#Create a Flask constructor. It takes name of the current module as the argument
app = Flask(__name__)

#Create a route decorator to tell the application, which URL should be called for the #described function and define the function

@app.route('/')
@app.route('/covid19HGI')
def covid19HGI_main():
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
        _clumpp = '1e-5'
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

#Create the main driver function
if __name__ == '__main__':
    #call the run method
    app.run(debug=True,host='0.0.0.0')
