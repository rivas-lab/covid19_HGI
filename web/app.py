#Import the flask module
from flask import Flask, render_template

#Create a Flask constructor. It takes name of the current module as the argument
app = Flask(__name__)

#Create a route decorator to tell the application, which URL should be called for the #described function and define the function

@app.route('/')
def main_page():
    return render_template('main.html')

#Create the main driver function
if __name__ == '__main__':
    #call the run method
    app.run(debug=True,host='0.0.0.0')
