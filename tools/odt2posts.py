#!/usr/bin/python
import sys, os, json, codecs
from subprocess import call
from parsedom import parseDOM

def domMeta(dom, name):
    return parseDOM(dom, 'meta', ret='content', attrs={'name':name})[0]


if len(sys.argv) < 3:
    print('[output directory] <input files>')
    sys.exit(1)

dirOut = sys.argv[1]
listInput = sys.argv[2:]

print('Output directory "%s"' % dirOut)

for inputFile in listInput:
    print("\n=== Processing file %s ===" % inputFile)
    ret = call(['odt2html', inputFile])

    if ret != 0:
        print('Failed converting "%s"' % inputFile)
        sys.exit(1)

    baseInput = inputFile.split('/')[-1][:-4]
    date = baseInput.split('_')[0]
    htmlFileSrc = '%s.html' % inputFile[:-4]

    fd = open(htmlFileSrc, 'r')
    buf = fd.read()
    fd.close()

    rawHead = parseDOM(buf, 'head')
    rawBody = parseDOM(buf, 'body')[0]

    dataTitle = parseDOM(rawHead, 'title')[0]
    dataTags = domMeta(rawHead, 'keywords').split(', ')
    dataShortTitle = domMeta(rawHead, 'classification')

    print('Title: %s' % dataTitle)
    print('Short title: %s' % dataShortTitle)
    print('Tags: %s' % dataTags)

    meta = {
        'longTitle' : dataTitle,
        'shortTitle' : dataShortTitle,
        'tags' : dataTags }

    dirDst = '%s/%s' % (dirOut, date)
    print('Creating directory "%s"' % dirDst)
    try:
        os.mkdir(dirDst)
    except:
        print('Failed to create directory')

    outFileMeta = '%s/meta.json' % dirDst
    outFileContent = '%s/content.html' % dirDst

    print('Writing meta file "%s"' % outFileMeta)
    with open(outFileMeta, 'w') as fd:
        json.dump(meta, fd)

    print('Writing content file "%s" (%d b)' % (outFileContent, len(rawBody)))
    with codecs.open(outFileContent, 'wb', 'utf-8') as fd:
        fd.write(rawBody)

    print('Cleanig up html input file')
    os.unlink(htmlFileSrc)

