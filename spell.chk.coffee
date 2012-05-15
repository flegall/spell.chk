# Basic spell checker, very very inpired by
# http://norvig.com/spell-correct.html

fs = require ('fs')
util = require ('util')

# inspect an object
inspect = (object) ->
    console.log (util.inspect object, true, null, true)

# CL processing
if process.argv.length != 4
    console.error ('Usage coffee spell.chk.coffee file-to-check reference-file')
    return

# Extract words of an input text
extractWords = (text) ->
    text.toLowerCase().match /[a-z]+/g

# Count word occurences
learn = (words) ->
    ref = {}
    store = (word) ->
        ref[word] = if ref[word]? then ref[word]+1 else 1
    store word for word in words
    ref
  
# Possible letters
letters = 'abcdefghijklmnopqrstuvwxyz'

# Makes a set of unique objects from an array
## Actually just a JS object with properties where values are booleans
set = (array) ->
    s = {}
    s[item] = true for item in array
    s

# Makes an array of unique objects from an existing array
unique = (array) ->
    Object.keys (set (array))

# Returns all level1 mispellings from a word
edits_l1 = (word) ->
    splits = ([word[0..i], word[i+1..word.length]] for i in [0..word.length-2])
    splits = [].concat [[['', word]], splits, [[word, '']]]...
    deletes = (a + b[1..] for [a,b] in splits when b.length >= 1)
    transposes = (a + b[1] + b[0] + b[2..] for [a,b] in splits when b.length > 1)
    replaces = [].concat (a + c + b[1..] for c in letters for [a,b] in splits when b.length >= 1)...
    inserts = [].concat (a + c + b for c in letters for [a,b] in splits)...
    unique ([].concat [deletes, transposes, replaces, inserts]...)

# Returns all known words which are separarated from a level-2 distance from a word
known_edits_l2 = (word, wordsSet) ->
    edits2 = (e2 for e2 in edits_l1 e1 when wordsSet[e2] for e1 in edits_l1 word)
    unique ([].concat edits2...)

# Returns a subset of words which are part of wordsSet
known = (words, wordsSet) ->
    unique (w for w in words when wordsSet[w])
    
# Suggests candidates for a word
suggest = (word, wordsSet) ->
    empty = (array) ->
        array.length == 0
    candidates = known [word], wordsSet
    candidates = known (edits_l1 word), wordsSet if empty candidates
    candidates = known_edits_l2 word, wordsSet   if empty candidates
    candidates = [word]                          if empty candidates
    candidates

# Reading file
referenceTxt = fs.readFileSync process.argv[3], 'UTF-8'

# Count word occurences
referenceWords = extractWords (referenceTxt)
wordOccs = learn (referenceWords)
referenceWordsSet = set (referenceWords)

inspect (suggest 'lobstre', referenceWordsSet)

