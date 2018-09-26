import os
import json
import flask
from flask import Flask, Response, jsonify, request

app = Flask(__name__)

words_list = [
    { 'word': 'disaster', 'translation': 'катастрофа' },
    {'word': 'competitor', 'translation': 'соперник'}, 
    {'word': 'client', 'translation': 'клиент'},
    {'word': 'colleague', 'translation': 'коллега'},
    {'word': 'family', 'translation': 'семья'},
    {'word': 'parents', 'translation': 'родители'},
    {'word': 'father', 'translation': 'отец'},
    {'word': 'dad (dy)', 'translation': 'папа'},
    {'word': 'mother', 'translation': 'мать'},
    {'word': 'mum (my)', 'translation': 'мама'},
    {'word': 'husband', 'translation': 'муж'},
    {'word': 'wife', 'translation': 'жена'},
    {'word': 'son', 'translation': 'сын'},
    {'word': 'daughter', 'translation': 'дочь'},
    {'word': 'brother', 'translation': 'брат'},
    {'word': 'sister', 'translation': 'сестра'},
    {'word': 'grandfather', 'translation': 'дед '},
    {'word': 'uncle', 'translation': 'дядя'},
    {'word': 'aunt', 'translation': 'тетя'},
    {'word': 'cousin', 'translation': 'кузен' },
    {'word': 'nephew', 'translation': 'племянник'}
]


@app.route('/api/words')
def get_words():
    resp = jsonify(words_list)
    resp.headers.add('Access-Control-Allow-Origin', '*')
    resp.headers.add('Content-Type', 'application/json')
    return resp


@app.route('/api/config.json')
def get_config():
    data = {'words': 'api/words'}
    resp = jsonify(data)
    resp.headers.add('Access-Control-Allow-Origin', '*')
    resp.headers.add('Content-Type', 'application/json')
    return resp


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
