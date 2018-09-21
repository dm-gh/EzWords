from flask import Flask, jsonify, request

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


@app.route('/words')
def get_words():
  return jsonify(words_list)


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
