from pyhive import hive
import os
import sasl
from flask import Flask, render_template, request

app = Flask(__name__)

@app.route('/')
def home():
    return render_template('index.html')

# Connect to the Hive server
conn = hive.Connection(host='10.0.0.10', port=10000, auth='CUSTOM',database = 'hive', username='hiveuser', password='thepassword')
@app.route('/upload', methods=['POST'])
def upload():
    if 'file' not in request.files:
        return 'No file uploaded.'
    file = request.files['file']
    if file.filename == '':
        return 'No file selected.'
    if file:
        # Connect to Hive
        cursor = conn.cursor()

        # Create a table to store the pictures
        cursor.execute('CREATE TABLE IF NOT EXISTS pictures (name STRING, data BLOB)')

        # Read the picture data and insert it into the table
        data = file.read()
        cursor.execute('INSERT INTO pictures VALUES (%s, %s)', (file.filename, data))

        # Close the connection
        cursor.close()
        conn.close()

        return 'Picture uploaded.'
    return 'An error occurred.'
if __name__ == '__main__':
    app.run()
