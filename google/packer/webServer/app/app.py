from flask import render_template # Lets us fetch and load html files
from flask import Flask

app = Flask(__name__)

# decorators define which URLs will load the index.hmtl template

@app.route('/')     
@app.route('/index')
def index():
    return render_template('index.html', title='Hammer Time')

# Lets us run the server from command line easily without any arguments.
if __name__=='__main__':
    app.run(debug=True, host='0.0.0.0')
