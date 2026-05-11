import os
from flask import Flask

app = Flask(__name__)

@app.route('/')
def say_hello():
    return os.environ.get('MSG', 'Hello World!')

@app.route('/health')
def health():
    return {'status': 'healthy'}, 200

if __name__ == '__main__':
    app.run(
        debug=os.environ.get('FLASK_DEBUG') == '1',
        port=int(os.environ.get('PORT', '5000')),
        host='0.0.0.0',
    )
