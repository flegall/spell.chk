fs = require('fs')
util = require('util')

# inspect an object
inspect = (object) ->
    console.log (util.inspect object, true, null, true)

# CL processing
#inspect process.argv
if process.argv.length != 3
    console.error 'Usage coffee spell.chk reference-file'
    return

# Reading file
txt = fs.readFileSync process.argv[2], 'UTF-8'

# Extract words of an input text
extractWords = (text) ->
    txt.toLowerCase().match /[a-z]+/g

# Count word occurences
learn = (words) ->
    ref = {}
    store = (word) ->
        ref[word] = if ref[word]? then ref[word]+1 else 1
    store word for word in words
    ref
    
alphabet = 'abcdefghijklmnopqrstuvwxyz'
wordOccs = learn (extractWords txt)
inspect wordOccs

